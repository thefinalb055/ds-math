// BTT Tree Specification for Math::sub
// =====================================
// Math::sub
// |-- When y is positive
// |   |-- When x >= y
// |   |   `-- It should return x - y
// |   `-- When x < y
// |       `-- It should revert with "underflow"
// |-- When y is negative
// |   |-- When x + |y| does not overflow
// |   |   `-- It should return x + |y|
// |   `-- When x + |y| would overflow U128_MAX
// |       `-- It should revert with "overflow"
// `-- When y is zero
//     `-- It should return x unchanged

use crate::sub;

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
    pub fn TEST_BOUNDARY_OFFSET() -> u128 {
        1000
    }

    // Setup for "When y is positive" with no underflow
    pub fn setup_positive_no_underflow() -> (u128, i64) {
        (TEST_BASE_VALUE(), TEST_POSITIVE_DELTA())
    }

    // Setup for "When y is positive" with underflow
    pub fn setup_positive_underflow() -> (u128, i64) {
        (TEST_SMALL_VALUE(), TEST_POSITIVE_DELTA())
    }

    // Setup for "When y is negative" with no overflow
    pub fn setup_negative_no_overflow() -> (u128, i64) {
        (TEST_BASE_VALUE(), TEST_NEGATIVE_DELTA())
    }

    // Setup for "When y is negative" with overflow
    pub fn setup_negative_overflow() -> (u128, i64) {
        (max_u128(), -TEST_TINY_VALUE())
    }

    // Setup for "When y is zero"
    pub fn setup_zero() -> (u128, i64) {
        (TEST_ARBITRARY_VALUE(), 0)
    }

    // Setup for I64_MIN edge case with overflow
    pub fn setup_i64_min_overflow() -> (u128, i64) {
        (max_u128() - TEST_BOUNDARY_OFFSET(), min_i64())
    }

    // Setup for I64_MAX subtraction
    pub fn setup_i64_max() -> (u128, i64) {
        (TEST_LARGE_VALUE(), max_i64())
    }

    // Setup for exact boundary
    pub fn setup_exact_boundary() -> (u128, i64) {
        (TEST_BASE_VALUE(), TEST_BASE_VALUE() as i64)
    }
}

// ============ When y is positive ============

#[test]
fn test_sub_positive_no_underflow() {
    // Branch: Math::sub -> When y is positive -> When x >= y -> It should return x - y
    let (x, y) = helpers::setup_positive_no_underflow();

    let result = sub(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE() - (helpers::TEST_POSITIVE_DELTA() as u128));
}

#[test(should_fail_with = "underflow")]
fn test_sub_positive_underflow() {
    // Branch: Math::sub -> When y is positive -> When x < y -> It should revert
    let (x, y) = helpers::setup_positive_underflow();

    let _result = sub(x, y); // Should panic with "underflow"
}

// ============ When y is negative ============

#[test]
fn test_sub_negative_no_overflow() {
    // Branch: Math::sub -> When y is negative -> When x + |y| does not overflow -> It should return x + |y|
    let (x, y) = helpers::setup_negative_no_overflow();

    let result = sub(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE() + (helpers::TEST_POSITIVE_DELTA() as u128));
}

#[test(should_fail_with = "overflow")]
fn test_sub_negative_overflow() {
    // Branch: Math::sub -> When y is negative -> When x + |y| would overflow -> It should revert
    let (x, y) = helpers::setup_negative_overflow();

    let _result = sub(x, y); // Should panic with "overflow"
}

// ============ When y is zero ============

#[test]
fn test_sub_zero() {
    // Branch: Math::sub -> When y is zero -> It should return x unchanged
    let (x, y) = helpers::setup_zero();

    let result = sub(x, y);

    assert_eq(result, x);
}

// ============ Edge Cases ============

#[test(should_fail_with = "overflow")]
fn test_sub_i64_min_overflow() {
    // Branch: Math::sub -> When y is negative (I64_MIN) -> When x + |y| would overflow -> It should revert
    let (x, y) = helpers::setup_i64_min_overflow();

    let _result = sub(x, y); // Should panic with "overflow"
}

#[test]
fn test_sub_i64_max() {
    // Branch: Math::sub -> When y is positive -> When x >= y -> It should return x - y
    let (x, y) = helpers::setup_i64_max();

    let result = sub(x, y);

    assert_eq(result, x - (y as u128));
}

#[test]
fn test_sub_exact_boundary() {
    // Branch: Math::sub -> When y is positive -> When x >= y -> It should return x - y
    let (x, y) = helpers::setup_exact_boundary();

    let result = sub(x, y);

    assert_eq(result, 0);
}
