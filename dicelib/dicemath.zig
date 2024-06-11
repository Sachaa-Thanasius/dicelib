//   Copyright 2020-present Michael Hall
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

const std = @import("std");

// Math used below based on these formulas
//
// #########################################################################################
// # Roll X d Y Keep Best/Worst                                                            #
// #########################################################################################
// # $$\mathbb{E}(\text{Roll } X \text{ d}Y \text{ and keep highest } Z) =                 #
// # \sum_{k=0}^{Z-1} \sum_{j=1}^Y j \sum_{l=0}^k                                          #
// # \binom{X}{l}\Big(\Big(\frac{Y-j}{Y}\Big)^l\Big(\frac{j}{Y}\Big)^{X-l}                 #
// # - \Big(\frac{Y-j+1}{Y}\Big)^l\Big(\frac{j-1}{Y}\Big)^{X-l}\Big)$$                     #
// #                                                                                       #
// # $$\mathbb{E}(\text{Roll } X \text{ d}Y \text{ and keep lowest } Z) =                  #
// # \sum_{k=1}^{Z} \sum_{j=1}^Y j \sum_{l=0}^{X-k}                                        #
// # \binom{X}{l}\Big(\Big(\frac{Y-j}{Y}\Big)^l\Big(\frac{j}{Y}\Big)^{X-l}                 #
// # - \Big(\frac{Y-j+1}{Y}\Big)^l\Big(\frac{j-1}{Y}\Big)^{X-l}\Big)$$                     #
// #########################################################################################

// Functions must not panic.
// Caller is assumed to potentially be utilizing user-provided data, and may not trust it.

fn binomial_coeff(n: u64, k: u64) u64 {
    if (k == 0) return 1;
    if (n <= k) return 0;
    return actual_binomial_coeff(n, @min(k, n - k));
}

fn actual_binomial_coeff(n: u64, k: u64) u64 {
    if (k == 0) return 1;
    if (n <= k) return 0;
    return @divExact(n * actual_binomial_coeff(n - 1, k - 1), k);
}

/// x: number of dice
/// y: sides
/// n: number of dice to keep
/// returns nan if the number of dice or sides of dice is greater than 100,
/// or if the number of dice to keep exceeds the number of dice.
export fn ev_xdy_keep_best_n(x: u16, y: u16, n: u16) f64 {
    var ret: f64 = 0;
    // signal out with nan if input is unsafe or unreasonable.
    // due to the method used to calculate the binomial coefficient, the upper bound for
    // these to be safe mathematically: x < 62, n <=x
    // x < 62 fits all the math into u64s, and may be a desirable application bound.
    // x < 125 can be done with u128s, but would require other changes.
    // values of y are safe to an extremely high value beyond what I want to allow right now.
    // Limits allowed here currently are lower than what can be done safely.
    // If you find yourself needing values larger than this, feel free to reach out.
    // The most dice I've seen ever needed as a single dice component in a real game is 40
    // and that was for meteor swarm in a max level one-shot, and wasn't even a "keep n" situation.

    // Note: I'm aware that llvm manages to make it work with ReleaseFast for values 5000 > x > 62
    // I'd rather not rely on non-guranateed compiler behavior and whatever it figured out.
    if ((x > 60) or (y > 100) or (n > x)) return std.math.nan(f64);
    // fast special case
    if (x == n) return @as(f64, @floatFromInt(x * (y + 1))) / 2.0;

    const _x = @as(f64, @floatFromInt(x));
    const _y = @as(f64, @floatFromInt(y));
    for (0..(n)) |k| {
        for (1..(y + 1)) |j| {
            const _j = @as(f64, @floatFromInt(j));
            var inner_sum: f64 = 0;
            for (0..(k + 1)) |i| {
                const _i = @as(f64, @floatFromInt(i));
                const bc: f64 = @as(f64, @floatFromInt(binomial_coeff(x, i)));
                const p1: f64 = std.math.pow(f64, ((_y - _j) / _y), _i) * std.math.pow(f64, (_j / _y), (_x - _i));
                const p2: f64 = std.math.pow(f64, ((_y - _j + 1) / _y), _i) * std.math.pow(f64, ((_j - 1) / _y), _x - _i);
                inner_sum += bc * (p1 - p2);
            }
            ret += _j * inner_sum;
        }
    }
    return ret;
}

/// x: number of dice
/// y: sides
/// n: number of dice to keep
/// returns nan if the number of dice or sides of dice is greater than 100,
/// or if the number of dice to keep exceeds the number of dice.
export fn ev_xdy_keep_worst_n(x: u16, y: u16, n: u16) f64 {
    var ret: f64 = 0;
    // signal out with nan if input is unsafe or unreasonable.
    // due to the method used to calculate the binomial coefficient, the upper bound for
    // these to be safe mathematically: x < 62, n <=x
    // x < 62 fits all the math into u64s, and may be a desirable application bound.
    // x < 125 can be done with u128s, but would require other changes.
    // values of y are safe to an extremely high value beyond what I want to allow right now.
    // Limits allowed here currently are lower than what can be done safely.
    // If you find yourself needing values larger than this, feel free to reach out.
    // The most dice I've seen ever needed as a single dice component in a real game is 40
    // and that was for meteor swarm in a max level one-shot, and wasn't even a "keep n" situation.

    // Note: I'm aware that llvm manages to make it work with ReleaseFast for values 5000 > x > 62
    // I'd rather not rely on non-guranateed compiler behavior and whatever it figured out.
    if ((x > 60) or (y > 100) or (n > x)) return std.math.nan(f64);
    // fast special case

    if (x == n) return @as(f64, @floatFromInt(x * (y + 1))) / 2.0;

    const _x = @as(f64, @floatFromInt(x));
    const _y = @as(f64, @floatFromInt(y));
    for (1..(n + 1)) |k| {
        for (1..(y + 1)) |j| {
            const _j = @as(f64, @floatFromInt(j));
            var inner_sum: f64 = 0;
            for (0..(x - k + 1)) |i| {
                const _i = @as(f64, @floatFromInt(i));
                const bc: f64 = @as(f64, @floatFromInt(binomial_coeff(x, i)));
                const p1: f64 = std.math.pow(f64, ((_y - _j) / _y), _i) * std.math.pow(f64, (_j / _y), (_x - _i));
                const p2: f64 = std.math.pow(f64, ((_y - _j + 1) / _y), _i) * std.math.pow(f64, ((_j - 1) / _y), _x - _i);
                inner_sum += bc * (p1 - p2);
            }
            ret += _j * inner_sum;
        }
    }
    return ret;
}
