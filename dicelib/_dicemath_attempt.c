#include <stdlib.h>
#include <stdint.h>
#include <math.h>

uint64_t actual_binomial_coeff_c(uint64_t n, uint64_t k)
{
    if (k == 0)
        return 1;
    if (n <= k)
        return 0;

    return lldiv(n * actual_binomial_coeff_c(n - 1, k - 1), k).quot;
}

uint64_t binomial_coeff_c(uint64_t n, uint64_t k)
{
    if (k == 0)
        return 1;
    if (n <= k)
        return 0;

    uint64_t min = __min(k, n - k);
    return actual_binomial_coeff_c(n, min);
}

/*
 * A function that provides the expected value for rolling X dice with Y sides and only keeping the Z best results.
 *
 * x: The number of dice
 * y: The number of sides for each die.
 * n: The number of dice to keep.
 *
 * Returns NaN if the number of dice or sides of dice is greater than 100, or if the number of dice to keep exceeds the
 * number of dice. Otherwise, returns an expected value.
 */
static double ev_xdy_keep_best_n(uint16_t x, uint16_t y, uint16_t n)
{
    double ret = 0.0;

    if ((x > 60) || (y > 100) || (n > x))
        return nan("");

    // fast special case
    if (x == n)
        return ((double)x * (y + 1)) / 2.0;

    double _x = (double)x;
    double _y = (double)y;

    for (int k = 0; k < n; k++)
    {
        for (int j = 1; j < y + 1; j++)
        {
            double _j = (double)j;
            double inner_sum = 0.0;
            for (int i = 0; i < k + 1; i++)
            {
                double _i = (double)i;
                double bc = (double)binomial_coeff_c(x, i);
                double p1 = pow(((_y - _j) / _y), _i) * pow((_j / _y), (_x - _i));
                double p2 = pow(((_y - _j + 1) / _y), _i) * pow(((_j - 1) / _y), _x - _i);
                inner_sum += bc * (p1 - p2);
            }
            ret += _j * inner_sum;
        }
    }
    return ret;
}

/*
 * A function that provides the expected value for rolling X dice with Y sides and only keeping the N worst results.
 *
 * x: The number of dice
 * y: The number of sides for each die.
 * n: The number of dice to keep.
 *
 * Returns NaN if the number of dice or sides of dice is greater than 100, or if the number of dice to keep exceeds the
 * number of dice. Otherwise, returns an expected value.
 */
static double ev_xdy_keep_worst_n(uint16_t x, uint16_t y, uint16_t n)
{
    double ret = 0.0;

    if ((x > 60) || (y > 100) || (n > x))
        return nan("");

    if (x == n)
        return ((double)x * (y + 1)) / 2.0;

    double _x = (double)x;
    double _y = (double)y;

    for (int k = 1; k < n + 1; k++)
    {
        for (int j = 1; j < y + 1; j++)
        {
            double _j = (double)j;
            double inner_sum = 0.0;
            for (int i = 0; i < (x - k + 1); i++)
            {
                double _i = (double)i;
                double bc = (double)binomial_coeff_c(x, i);
                double p1 = pow(((_y - _j) / _y), _i) * pow((_j / _y), (_x - _i));
                double p2 = pow(((_y - _j + 1) / _y), _i) * pow(((_j - 1) / _y), _x - _i);
                inner_sum += bc * (p1 - p2);
            }
            ret += _j * inner_sum;
        }
    }
    return ret;
}
