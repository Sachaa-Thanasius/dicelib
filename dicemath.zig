const std = @import("std");

fn binomial_coeff(n: u64, k: u64) u64 {
    if (k == 0) {
        return 1;
    }
    if (n <= k) {
        return 0;
    }
    return @divExact(n * binomial_coeff(n - 1, k - 1), k);
}

export fn ev_roll_xdy_keep_bestn(x: u16, y: u16, n: u16) f64 {
    var ret: f64 = 0;

    const _x = @intToFloat(f64, x);
    const _y = @intToFloat(f64, y);
    const _n = @intToFloat(f64, n);
    _ = _n;

    for (0..(n)) |k| {
        var _k = @intToFloat(f64, k);
        _ = _k;

        for (1..(y + 1)) |j| {
            var _j = @intToFloat(f64, j);

            var inner_sum: f64 = 0;

            for (0..(k + 1)) |i| {
                var _i = @intToFloat(f64, i);
                var bc: f64 = @intToFloat(f64, binomial_coeff(x, i));

                var p1: f64 = std.math.pow(f64, ((_y - _j) / _y), _i) * std.math.pow(f64, (_j / _y), (_x - _i));
                var p2: f64 = std.math.pow(f64, ((_y - _j + 1) / _y), _i) * std.math.pow(f64, ((_j - 1) / _y), _x - _i);

                inner_sum = inner_sum + bc * (p1 - p2);
            }

            ret = ret + _j * inner_sum;
        }
    }
    return ret;
}

export fn ev_roll_xdy_keep_worstn(x: u16, y: u16, n: u16) f64 {
    var ret: f64 = 0;

    const _x = @intToFloat(f64, x);
    const _y = @intToFloat(f64, y);
    const _n = @intToFloat(f64, n);
    _ = _n;

    for (1..(n + 1)) |k| {
        var _k = @intToFloat(f64, k);
        _ = _k;

        for (1..(y + 1)) |j| {
            var _j = @intToFloat(f64, j);

            var inner_sum: f64 = 0;

            for (0..(x - k + 1)) |i| {
                var _i = @intToFloat(f64, i);
                var bc: f64 = @intToFloat(f64, binomial_coeff(x, i));

                var p1: f64 = std.math.pow(f64, ((_y - _j) / _y), _i) * std.math.pow(f64, (_j / _y), (_x - _i));
                var p2: f64 = std.math.pow(f64, ((_y - _j + 1) / _y), _i) * std.math.pow(f64, ((_j - 1) / _y), _x - _i);

                inner_sum = inner_sum + bc * (p1 - p2);
            }

            ret = ret + _j * inner_sum;
        }
    }
    return ret;
}
