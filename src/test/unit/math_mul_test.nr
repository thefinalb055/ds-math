// BTT Tree Specification for Math::mul
// =====================================
// Math::mul
// |-- When y is zero
// |   `-- It should return 0
// |-- When x exceeds I64_MAX
// |   `-- It should revert with "x > max int128"
// |-- When y equals I64_MIN
// |   |-- When x is zero
// |   |   `-- It should return 0
// |   |-- When x * (I64_MAX + 1) does not overflow
// |   |   `-- It should return -(x * (I64_MAX + 1))
// |   `-- When x * (I64_MAX + 1) would overflow
// |       `-- It should revert with "mul overflow"
// |-- When y is positive
// |   |-- When x * y does not overflow I64_MAX
// |   |   `-- It should return x * y as i64
// |   `-- When x * y would overflow I64_MAX
// |       `-- It should revert with "mul overflow"
// `-- When y is negative
//     |-- When x * |y| does not overflow I64_MAX + 1
//     |   `-- It should return -(x * |y|) as i64
//     `-- When x * |y| would overflow I64_MAX + 1
//         `-- It should revert with "mul overflow"

use crate::{mul, I64_MAX, I64_MIN};
use crate::test::utils::{max_i64, min_i64};

// ============ Helper Functions for Branch Conditions ============

mod helpers {
    use crate::{I64_MAX, I64_MIN};

    // Test constants to avoid magic numbers
    pub fn TEST_VALUE_LARGE() -> u128 { 123456789 }
    pub fn TEST_VALUE_SMALL() -> u128 { 1000 }
    pub fn TEST_VALUE_MEDIUM() -> u128 { 1000000000 }
    pub fn TEST_MULTIPLIER_SMALL() -> i64 { 2 }
    pub fn TEST_MULTIPLIER_LARGE() -> i64 { 2000 }
    pub fn TEST_EXPECTED_PRODUCT() -> i64 { 2000000 }
    pub fn TEST_EXPECTED_LARGE_PRODUCT() -> i64 { 1000000000000000000 }

    // Setup for "When y is zero"
    pub fn setup_y_zero() -> (u128, i64) {
        (TEST_VALUE_LARGE(), 0)
    }

    // Setup for "When x exceeds I64_MAX"
    pub fn setup_x_exceeds_max() -> (u128, i64) {
        ((I64_MAX as u128) + 1, 1)
    }

    // Setup for "When y equals I64_MIN and x is zero"
    pub fn setup_i64_min_x_zero() -> (u128, i64) {
        (0, I64_MIN)
    }

    // Setup for "When y equals I64_MIN" with no overflow
    pub fn setup_i64_min_no_overflow() -> (u128, i64) {
        (1, I64_MIN)
    }

    // Setup for "When y equals I64_MIN" with overflow
    pub fn setup_i64_min_overflow() -> (u128, i64) {
        (2, I64_MIN)
    }

    // Setup for "When y is positive" with no overflow
    pub fn setup_positive_no_overflow() -> (u128, i64) {
        (TEST_VALUE_SMALL(), TEST_MULTIPLIER_LARGE())
    }

    // Setup for "When y is positive" with overflow
    pub fn setup_positive_overflow() -> (u128, i64) {
        (I64_MAX as u128, TEST_MULTIPLIER_SMALL())
    }

    // Setup for "When y is negative" with no overflow
    pub fn setup_negative_no_overflow() -> (u128, i64) {
        (TEST_VALUE_SMALL(), -TEST_MULTIPLIER_LARGE())
    }

    // Setup for "When y is negative" with overflow
    pub fn setup_negative_overflow() -> (u128, i64) {
        (I64_MAX as u128, -TEST_MULTIPLIER_SMALL())
    }

    // Setup for maximum safe multiplication
    pub fn setup_max_safe() -> (u128, i64) {
        (TEST_VALUE_MEDIUM(), TEST_VALUE_MEDIUM() as i64)
    }
}

// ============ When y is zero ============

#[test]
fn test_mul_y_zero() {
    // Branch: Math::mul -> When y is zero -> It should return 0
    let (x, y) = helpers::setup_y_zero();

    let result = mul(x, y);

    assert_eq(result, 0);
}

// ============ When x exceeds I64_MAX ============

#[test(should_fail_with = "x > max int128")]
fn test_mul_x_exceeds_max() {
    // Branch: Math::mul -> When x exceeds I64_MAX -> It should revert
    let (x, y) = helpers::setup_x_exceeds_max();

    let _result = mul(x, y); // Should panic with "x > max int128"
}

// ============ When y equals I64_MIN ============

#[test]
fn test_mul_i64_min_x_zero() {
    // Branch: Math::mul -> When y equals I64_MIN -> When x is zero -> It should return 0
    let (x, y) = helpers::setup_i64_min_x_zero();

    let result = mul(x, y);

    assert_eq(result, 0);
}

#[test]
fn test_mul_i64_min_no_overflow() {
    // Branch: Math::mul -> When y equals I64_MIN -> When x * (I64_MAX + 1) does not overflow -> It should return result
    let (x, y) = helpers::setup_i64_min_no_overflow();

    let result = mul(x, y);

    assert_eq(result, I64_MIN);
}

#[test(should_fail_with = "mul overflow")]
fn test_mul_i64_min_overflow() {
    // Branch: Math::mul -> When y equals I64_MIN -> When x * (I64_MAX + 1) would overflow -> It should revert
    let (x, y) = helpers::setup_i64_min_overflow();

    let _result = mul(x, y); // Should panic with "mul overflow"
}

// ============ When y is positive ============

#[test]
fn test_mul_positive_no_overflow() {
    // Branch: Math::mul -> When y is positive -> When x * y does not overflow -> It should return x * y
    let (x, y) = helpers::setup_positive_no_overflow();

    let result = mul(x, y);

    assert_eq(result, helpers::TEST_EXPECTED_PRODUCT());
}

#[test(should_fail_with = "mul overflow")]
fn test_mul_positive_overflow() {
    // Branch: Math::mul -> When y is positive -> When x * y would overflow -> It should revert
    let (x, y) = helpers::setup_positive_overflow();

    let _result = mul(x, y); // Should panic with "mul overflow"
}

// ============ When y is negative ============

#[test]
fn test_mul_negative_no_overflow() {
    // Branch: Math::mul -> When y is negative -> When x * |y| does not overflow -> It should return -(x * |y|)
    let (x, y) = helpers::setup_negative_no_overflow();

    let result = mul(x, y);

    assert_eq(result, -helpers::TEST_EXPECTED_PRODUCT());
}

#[test(should_fail_with = "mul overflow")]
fn test_mul_negative_overflow() {
    // Branch: Math::mul -> When y is negative -> When x * |y| would overflow -> It should revert
    let (x, y) = helpers::setup_negative_overflow();

    let _result = mul(x, y); // Should panic with "mul overflow"
}

// ============ Edge Cases ============

#[test]
fn test_mul_max_safe() {
    // Branch: Math::mul -> When y is positive -> When x * y does not overflow -> It should return x * y
    let (x, y) = helpers::setup_max_safe();

    let result = mul(x, y);

    assert_eq(result, helpers::TEST_EXPECTED_LARGE_PRODUCT());
}