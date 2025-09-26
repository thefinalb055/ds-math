// BTT Tree Specification for Math::add
// =====================================
// Math::add
// |-- When y is positive
// |   |-- When x + y does not overflow
// |   |   `-- It should return x + y
// |   `-- When x + y would overflow U128_MAX
// |       `-- It should revert with "overflow"
// |-- When y is negative
// |   |-- When x >= |y|
// |   |   `-- It should return x - |y|
// |   `-- When x < |y|
// |       `-- It should revert with "underflow"
// `-- When y is zero
//     `-- It should return x unchanged

use crate::add;
use crate::test::utils::i64_min_abs;

// ============ Helper Functions for Branch Conditions ============

mod helpers {
    use crate::test::utils::{max_i64, max_u128, min_i64};
    use crate::WAD;

    // Test constants to avoid magic numbers
    pub fn TEST_BASE_VALUE() -> u128 {
        100
    }
    pub fn TEST_SMALL_VALUE() -> u128 {
        30
    }
    pub fn TEST_POSITIVE_DELTA() -> i64 {
        50
    }
    pub fn TEST_NEGATIVE_DELTA() -> i64 {
        -50
    }
    pub fn TEST_TINY_VALUE() -> i64 {
        1
    }
    pub fn TEST_ARBITRARY_VALUE() -> u128 {
        12345
    }
    pub fn TEST_LARGE_VALUE() -> u128 {
        WAD * 10
    } // 10 WAD
    pub fn TEST_ETH_LIKE_VALUE() -> u128 {
        WAD
    }

    // Setup for "When y is positive" with no overflow
    pub fn setup_positive_no_overflow() -> (u128, i64) {
        (TEST_BASE_VALUE(), TEST_POSITIVE_DELTA())
    }

    // Setup for "When y is positive" with overflow
    pub fn setup_positive_overflow() -> (u128, i64) {
        (max_u128(), TEST_TINY_VALUE())
    }

    // Setup for "When y is negative" with no underflow
    pub fn setup_negative_no_underflow() -> (u128, i64) {
        (TEST_BASE_VALUE(), TEST_NEGATIVE_DELTA())
    }

    // Setup for "When y is negative" with underflow
    pub fn setup_negative_underflow() -> (u128, i64) {
        (TEST_SMALL_VALUE(), TEST_NEGATIVE_DELTA())
    }

    // Setup for "When y is zero"
    pub fn setup_zero() -> (u128, i64) {
        (TEST_ARBITRARY_VALUE(), 0)
    }

    // Setup for edge case with I64_MIN
    pub fn setup_i64_min_safe() -> (u128, i64) {
        (TEST_LARGE_VALUE(), min_i64())
    }

    // Setup for large positive values
    pub fn setup_large_positive() -> (u128, i64) {
        (TEST_ETH_LIKE_VALUE(), max_i64()) // ETH-like value + I64_MAX
    }
}

// ============ When y is positive ============

#[test]
fn test_add_positive_no_overflow() {
    // Branch: Math::add -> When y is positive -> When x + y does not overflow -> It should return x + y
    let (x, y) = helpers::setup_positive_no_overflow();

    let result = add(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE() + (helpers::TEST_POSITIVE_DELTA() as u128));
}

#[test(should_fail_with = "overflow")]
fn test_add_positive_overflow() {
    // Branch: Math::add -> When y is positive -> When x + y would overflow -> It should revert
    let (x, y) = helpers::setup_positive_overflow();

    let _result = add(x, y); // Should panic with "overflow"
}

// ============ When y is negative ============

#[test]
fn test_add_negative_no_underflow() {
    // Branch: Math::add -> When y is negative -> When x >= |y| -> It should return x - |y|
    let (x, y) = helpers::setup_negative_no_underflow();

    let result = add(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE() - (helpers::TEST_POSITIVE_DELTA() as u128));
}

#[test(should_fail_with = "underflow")]
fn test_add_negative_underflow() {
    // Branch: Math::add -> When y is negative -> When x < |y| -> It should revert
    let (x, y) = helpers::setup_negative_underflow();

    let _result = add(x, y); // Should panic with "underflow"
}

// ============ When y is zero ============

#[test]
fn test_add_zero() {
    // Branch: Math::add -> When y is zero -> It should return x unchanged
    let (x, y) = helpers::setup_zero();

    let result = add(x, y);

    assert_eq(result, x);
}

// ============ Edge Cases ============

#[test]
fn test_add_i64_min() {
    // Branch: Math::add -> When y is negative (I64_MIN) -> When x >= |y| -> It should return x - |y|
    let (x, y) = helpers::setup_i64_min_safe();

    let result = add(x, y);

    assert_eq(result, x - i64_min_abs());
}

#[test]
fn test_add_large_positive() {
    // Branch: Math::add -> When y is positive -> When x + y does not overflow -> It should return x + y
    let (x, y) = helpers::setup_large_positive();

    let result = add(x, y);

    assert_eq(result, x + (y as u128));
}
