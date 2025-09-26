// BTT Tree Specification for Math::rpow Function
// ===============================================
// Math::rpow
// |-- When n is 0
// |   `-- It should return base (1 in the given precision)
// |-- When n is 1
// |   `-- It should return x unchanged
// |-- When x is 0
// |   |-- When n > 0
// |   |   `-- It should return 0
// |   `-- When n = 0
// |       `-- It should return base (1 in the given precision)
// |-- When x is base (representing 1)
// |   `-- It should return base (1^n = 1)
// |-- When performing binary exponentiation
// |   |-- When result does not overflow
// |   |   |-- When result is exact
// |   |   |   `-- It should return the exact result
// |   |   `-- When result needs rounding
// |   |       `-- It should round down
// |   `-- When result would overflow
// |       `-- It should revert with "rpow overflow"
// `-- Edge cases
//     |-- When exponent is very large
//     |   `-- It should compute correctly or overflow
//     `-- When base is at boundary values
//         `-- It should handle correctly


use crate::{rpow, RAY};
use crate::test::utils::approx_eq;

// ============ Helper Functions for Branch Conditions ============

mod helpers {
    use crate::RAY;
    use crate::test::utils::ray_ratio;

    // Test constants to avoid magic numbers
    pub fn TEST_EXPONENT_SMALL() -> u128 { 2 }
    pub fn TEST_EXPONENT_MEDIUM() -> u128 { 5 }
    pub fn TEST_EXPONENT_LARGE() -> u128 { 100 }
    pub fn TEST_EXPONENT_HUGE() -> u128 { 200 }
    pub fn TEST_EXPONENT_VERY_LARGE() -> u128 { 1000 }
    pub fn RAY_ONE_POINT_ONE() -> u128 { ray_ratio(11, 10) }  // 1.1 in RAY
    pub fn RAY_ONE_POINT_FIVE() -> u128 { ray_ratio(3, 2) }  // 1.5 in RAY
    pub fn RAY_ONE_POINT_ZERO_ZERO_ONE() -> u128 { ray_ratio(1001, 1000) }  // 1.001 in RAY

    // Setup for when n is 0
    pub fn setup_n_zero() -> (u128, u128, u128) {
        (TEST_EXPONENT_SMALL() * RAY, 0, RAY)  // x, n, base
    }

    // Setup for when n is 1
    pub fn setup_n_one() -> (u128, u128, u128) {
        (TEST_EXPONENT_SMALL() * RAY, 1, RAY)
    }

    // Setup for when x is 0
    pub fn setup_x_zero() -> (u128, u128, u128) {
        (0, TEST_EXPONENT_MEDIUM(), RAY)
    }

    // Setup for when x is base (representing 1)
    pub fn setup_x_is_base() -> (u128, u128, u128) {
        (RAY, TEST_EXPONENT_LARGE(), RAY)
    }

    // Setup for binary exponentiation without overflow
    pub fn setup_binary_exp_no_overflow() -> (u128, u128, u128) {
        (RAY_ONE_POINT_ONE(), TEST_EXPONENT_SMALL(), RAY)  // 1.1^2 in RAY
    }

    // Setup for binary exponentiation with overflow
    pub fn setup_binary_exp_overflow() -> (u128, u128, u128) {
        (TEST_EXPONENT_SMALL() * RAY, TEST_EXPONENT_HUGE(), RAY)  // 2^200 will overflow
    }

    // Setup for result that needs rounding
    pub fn setup_rounding() -> (u128, u128, u128) {
        (RAY_ONE_POINT_FIVE(), 3, RAY)  // 1.5^3 in RAY
    }

    // Setup for large exponent edge case
    pub fn setup_large_exponent() -> (u128, u128, u128) {
        (RAY_ONE_POINT_ZERO_ZERO_ONE(), TEST_EXPONENT_VERY_LARGE(), RAY)  // 1.001^1000 in RAY
    }
}

// ============ Core rpow tests ============

#[test]
fn test_rpow_n_zero() {
    // Branch: Math::rpow -> When n is 0 -> It should return base
    let (x, n, base) = helpers::setup_n_zero();
    let result = rpow(x, n, base);
    assert_eq(result, base); // Should return 1 in RAY precision
}

#[test]
fn test_rpow_n_one() {
    // Branch: Math::rpow -> When n is 1 -> It should return x unchanged
    let (x, n, base) = helpers::setup_n_one();
    let result = rpow(x, n, base);
    assert_eq(result, x);
}

#[test]
fn test_rpow_x_zero() {
    // Branch: Math::rpow -> When x is 0 -> When n > 0 -> It should return 0
    let (x, n, base) = helpers::setup_x_zero();
    let result = rpow(x, n, base);
    assert_eq(result, 0);
}

#[test]
fn test_rpow_x_is_base() {
    // Branch: Math::rpow -> When x is base (representing 1) -> It should return base
    let (x, n, base) = helpers::setup_x_is_base();
    let result = rpow(x, n, base);
    assert_eq(result, RAY); // 1^100 = 1
}

// ============ Binary Exponentiation tests ============

#[test]
fn test_rpow_binary_exp_no_overflow() {
    // Branch: Math::rpow -> When performing binary exponentiation -> When result does not overflow -> It should return the result
    let (x, n, base) = helpers::setup_binary_exp_no_overflow();
    let result = rpow(x, n, base);

    let expected: u128 = (RAY * 121) / 100; // 1.21 RAY
    assert_eq(result, expected); // 1.1^2 = 1.21
}

#[test(should_fail_with = "rpow overflow")]
fn test_rpow_binary_exp_overflow() {
    // Branch: Math::rpow -> When performing binary exponentiation -> When result would overflow -> It should revert
    let (x, n, base) = helpers::setup_binary_exp_overflow();
    let _result = rpow(x, n, base);
}

#[test]
fn test_rpow_rounding() {
    // Branch: Math::rpow -> When performing binary exponentiation -> When result needs rounding -> It should round down
    let (x, n, base) = helpers::setup_rounding();
    let result = rpow(x, n, base);

    let expected: u128 = (RAY * 3375) / 1000; // 3.375 RAY
    assert_eq(result, expected); // 1.5^3 = 3.375 -> stays within u128
}

// ============ Edge Cases ============

#[test]
fn test_rpow_large_exponent() {
    // Branch: Math::rpow -> Edge cases -> When exponent is very large -> It should compute correctly or overflow
    let (x, n, base) = helpers::setup_large_exponent();
    let result = rpow(x, n, base);

    let expected: u128 = 2_716_923_932_235_892_457_383_088_084;
    let tolerance: u128 = 10; // Allow minimal rounding drift

    assert(approx_eq(result, expected, tolerance));
    assert(result > base); // Sanity: growth over base
}
