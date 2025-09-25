// BTT Tree Specification for Math Min/Max/Diff Functions
// ========================================================
// Math::min
// |-- When x equals y
// |   `-- It should return x (or y, they're equal)
// |-- When x is less than y
// |   `-- It should return x
// `-- When x is greater than y
//     `-- It should return y
//
// Math::max
// |-- When x equals y
// |   `-- It should return x (or y, they're equal)
// |-- When x is greater than y
// |   `-- It should return x
// `-- When x is less than y
//     `-- It should return y
//
// Math::diff
// |-- When x equals y
// |   `-- It should return 0
// |-- When x is greater than y
// |   |-- When difference fits in I64_MAX
// |   |   `-- It should return x - y as positive i64
// |   `-- When difference exceeds I64_MAX
// |       `-- It should revert with "diff overflow"
// `-- When x is less than y
//     |-- When difference magnitude fits in |I64_MIN|
//     |   `-- It should return x - y as negative i64
//     `-- When difference magnitude exceeds |I64_MIN|
//         `-- It should revert with "diff overflow"

use crate::{I64_MAX, I64_MIN};
use crate::{min, max};
// TODO: Import diff once implemented
// use crate::diff;

// ============ Helper Functions for Branch Conditions ============

mod helpers {
    use crate::test::utils::i64_min_abs;

    // Test constants to avoid magic numbers
    pub fn TEST_BASE_VALUE() -> u128 { 100 }
    pub fn TEST_SMALL_VALUE() -> u128 { 50 }
    pub fn TEST_OFFSET() -> u128 { 100 }

    // min helpers
    pub fn setup_min_equal() -> (u128, u128) {
        (TEST_BASE_VALUE(), TEST_BASE_VALUE())
    }

    pub fn setup_min_x_less() -> (u128, u128) {
        (TEST_SMALL_VALUE(), TEST_BASE_VALUE())
    }

    pub fn setup_min_x_greater() -> (u128, u128) {
        (TEST_BASE_VALUE(), TEST_SMALL_VALUE())
    }

    // max helpers
    pub fn setup_max_equal() -> (u128, u128) {
        (TEST_BASE_VALUE(), TEST_BASE_VALUE())
    }

    pub fn setup_max_x_greater() -> (u128, u128) {
        (TEST_BASE_VALUE(), TEST_SMALL_VALUE())
    }

    pub fn setup_max_x_less() -> (u128, u128) {
        (TEST_SMALL_VALUE(), TEST_BASE_VALUE())
    }

    // diff helpers (for future implementation)
    pub fn setup_diff_equal() -> (u128, u128) {
        (TEST_BASE_VALUE(), TEST_BASE_VALUE())
    }

    pub fn setup_diff_x_greater_no_overflow() -> (u128, u128) {
        (TEST_BASE_VALUE(), TEST_SMALL_VALUE())
    }

    pub fn setup_diff_x_greater_overflow() -> (u128, u128) {
        ((crate::I64_MAX as u128) + TEST_OFFSET(), 0)
    }

    pub fn setup_diff_x_less_no_overflow() -> (u128, u128) {
        (TEST_SMALL_VALUE(), TEST_BASE_VALUE())
    }

    pub fn setup_diff_x_less_overflow() -> (u128, u128) {
        (0, i64_min_abs() + TEST_OFFSET())
    }
}

// ============ min tests ============

#[test]
fn test_min_equal() {
    // Branch: Math::min -> When x equals y -> It should return x (or y, they're equal)
    let (x, y) = helpers::setup_min_equal();

    let result = min(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE());
}

#[test]
fn test_min_x_less() {
    // Branch: Math::min -> When x is less than y -> It should return x
    let (x, y) = helpers::setup_min_x_less();

    let result = min(x, y);

    assert_eq(result, helpers::TEST_SMALL_VALUE());
}

#[test]
fn test_min_x_greater() {
    // Branch: Math::min -> When x is greater than y -> It should return y
    let (x, y) = helpers::setup_min_x_greater();

    let result = min(x, y);

    assert_eq(result, helpers::TEST_SMALL_VALUE());
}

// ============ max tests ============

#[test]
fn test_max_equal() {
    // Branch: Math::max -> When x equals y -> It should return x (or y, they're equal)
    let (x, y) = helpers::setup_max_equal();

    let result = max(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE());
}

#[test]
fn test_max_x_greater() {
    // Branch: Math::max -> When x is greater than y -> It should return x
    let (x, y) = helpers::setup_max_x_greater();

    let result = max(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE());
}

#[test]
fn test_max_x_less() {
    // Branch: Math::max -> When x is less than y -> It should return y
    let (x, y) = helpers::setup_max_x_less();

    let result = max(x, y);

    assert_eq(result, helpers::TEST_BASE_VALUE());
}

// ============ diff tests ============

#[test]
fn test_diff_equal() {
    // Branch: Math::diff -> When x equals y -> It should return 0
    // TODO: Implement once diff is available
    // let (x, y) = helpers::setup_diff_equal();
    // let result = diff(x, y);
    // assert_eq(result, 0);
}

#[test]
fn test_diff_x_greater_no_overflow() {
    // Branch: Math::diff -> When x is greater than y -> When difference fits in I64_MAX -> It should return x - y
    // TODO: Implement once diff is available
    // let (x, y) = helpers::setup_diff_x_greater_no_overflow();
    // let result = diff(x, y);
    // assert_eq(result, 50);
}

#[test(should_fail_with = "diff overflow")]
fn test_diff_x_greater_overflow() {
    // Branch: Math::diff -> When x is greater than y -> When difference exceeds I64_MAX -> It should revert
    // TODO: Implement once diff is available
    // let (x, y) = helpers::setup_diff_x_greater_overflow();
    // let _result = diff(x, y);
}

#[test]
fn test_diff_x_less_no_overflow() {
    // Branch: Math::diff -> When x is less than y -> When difference magnitude fits -> It should return x - y
    // TODO: Implement once diff is available
    // let (x, y) = helpers::setup_diff_x_less_no_overflow();
    // let result = diff(x, y);
    // assert_eq(result, -50);
}

#[test(should_fail_with = "diff overflow")]
fn test_diff_x_less_overflow() {
    // Branch: Math::diff -> When x is less than y -> When difference magnitude exceeds |I64_MIN| -> It should revert
    // TODO: Implement once diff is available
    // let (x, y) = helpers::setup_diff_x_less_overflow();
    // let _result = diff(x, y);
}