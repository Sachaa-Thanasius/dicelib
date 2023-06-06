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

fn binomial_coeff(n: u64, k: u64) u64 {
    if (k == 0) return 1;
    if (n <= k) return 0;
    return @divExact(n * binomial_coeff(n - 1, k - 1), k);
}

/// x: number of dice
/// y: sides
/// n: number of dice to keep
export fn ev_xdy_keep_best_n(x: u16, y: u16, n: u16) f64 {
    var ret: f64 = 0;
    const _x = @intToFloat(f64, x);
    const _y = @intToFloat(f64, y);
    for (0..(n)) |k| {
        for (1..(y + 1)) |j| {
            const _j = @intToFloat(f64, j);
            var inner_sum: f64 = 0;
            for (0..(k + 1)) |i| {
                const _i = @intToFloat(f64, i);
                const bc: f64 = @intToFloat(f64, binomial_coeff(x, i));
                const p1: f64 = std.math.pow(f64, ((_y - _j) / _y), _i) * std.math.pow(f64, (_j / _y), (_x - _i));
                const p2: f64 = std.math.pow(f64, ((_y - _j + 1) / _y), _i) * std.math.pow(f64, ((_j - 1) / _y), _x - _i);
                inner_sum = inner_sum + bc * (p1 - p2);
            }
            ret = ret + _j * inner_sum;
        }
    }
    return ret;
}

/// x: number of dice
/// y: sides
/// n: number of dice to keep
export fn ev_xdy_keep_worst_n(x: u16, y: u16, n: u16) f64 {
    var ret: f64 = 0;
    const _x = @intToFloat(f64, x);
    const _y = @intToFloat(f64, y);
    for (1..(n + 1)) |k| {
        for (1..(y + 1)) |j| {
            const _j = @intToFloat(f64, j);
            var inner_sum: f64 = 0;
            for (0..(x - k + 1)) |i| {
                const _i = @intToFloat(f64, i);
                const bc: f64 = @intToFloat(f64, binomial_coeff(x, i));
                const p1: f64 = std.math.pow(f64, ((_y - _j) / _y), _i) * std.math.pow(f64, (_j / _y), (_x - _i));
                const p2: f64 = std.math.pow(f64, ((_y - _j + 1) / _y), _i) * std.math.pow(f64, ((_j - 1) / _y), _x - _i);
                inner_sum = inner_sum + bc * (p1 - p2);
            }
            ret = ret + _j * inner_sum;
        }
    }
    return ret;
}
