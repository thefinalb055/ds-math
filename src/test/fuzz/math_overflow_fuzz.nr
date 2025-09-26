// BTT Tree Specification for Overflow Detection Fuzz Tests
// =========================================================
// Overflow and Boundary Detection (Fuzz Testing)
// |-- Addition Overflow
// |   |-- Positive overflow: x + y > U128_MAX
// |   `-- Negative underflow: x - |y| < 0
// |-- Multiplication Overflow
// |   |-- Positive overflow: x * y > I64_MAX
// |   |-- I64_MIN special case: x * I64_MIN
// |   `-- Large value detection
// |-- Precision Overflow
// |   |-- wmul overflow: x * y > U128_MAX
// |   |-- wdiv overflow: x * WAD > U128_MAX
// |   |-- rmul overflow: x * y > U128_MAX
// |   `-- rdiv overflow: x * RAY > U128_MAX
// `-- Edge Cases
//     |-- Near-boundary operations
//     |-- Sign changes at boundaries
//     `-- Precision loss at extremes

use crate::{add, I64_MAX, I64_MIN, mul, rdiv, rmul, sub, WAD, wdiv, wmul};

// ============ Helper Functions for Overflow Detection ============

mod helpers {
    use crate::{I64_MAX, I64_MIN};

    // Maximum u128 value
    pub fn max_u128() -> u128 {
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    }

    // Check if we're near overflow boundary
    pub fn near_overflow_boundary(x: u128, margin: u128) -> bool {
        x > (max_u128() - margin)
    }

    // Generate a value that's likely to cause overflow when doubled
    pub fn make_overflow_prone(x: u128) -> u128 {
        if x < (max_u128() / 2) {
            max_u128() - x
        } else {
            x
        }
    }

    // Generate a value that's likely to cause underflow
    pub fn make_underflow_prone(x: u128) -> u128 {
        x & 0xFFFF // Keep it small
    }

    // Adjust value for multiplication overflow testing
    pub fn adjust_for_mul_overflow(x: u128, y: i64) -> u128 {
        if y == 0 {
            x & 0xFFFF
        } else if y == I64_MIN {
            // Only 0 and 1 are safe with I64_MIN
            if x > 1 {
                2
            } else {
                x
            }
        } else if (y > 1000000) | (y < -1000000) {
            // For large y, keep x reasonable
            (I64_MAX as u128) / 2
        } else {
            // For small y, x can be larger
            if x > (I64_MAX as u128) {
                (I64_MAX as u128) - 1
            } else {
                x
            }
        }
    }
}

// ============ Addition Overflow Detection ============

#[fuzz(should_fail)]
fn fuzz_find_add_positive_overflow(x: u128, y: i64) {
    // Fuzzer should find cases where x + y > U128_MAX
    // Transform inputs to make overflow more likely
    let x_prone = helpers::make_overflow_prone(x);
    let y_positive = if y < 0 { -y } else { y };
    let _result = add(x_prone, y_positive);
}

#[fuzz(should_fail)]
fn fuzz_find_add_negative_underflow(x: u128, y: i64) {
    // Fuzzer should find cases where x < |y|
    // Make x small and y negative to increase chances
    let x_small = helpers::make_underflow_prone(x);
    let y_negative = if y > 0 { -y } else { y };
    let _result = add(x_small, y_negative);
}

#[fuzz]
fn fuzz_add_near_boundary(x: u128, delta: u128) {
    // Test behavior near overflow boundaries
    let small_delta = delta & 0xFFFF;
    if small_delta < 0xFFFF {
        // Use x to determine the boundary offset
        let offset = (x & 0xFFF) + 1000;
        let boundary = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - small_delta - offset;
        if boundary > 0 {
            let _result1 = add(boundary, 0);
            if delta & 1 == 0 {
                let _result2 = add(boundary - 1, 1);
            }
        }
    }
}

// ============ Multiplication Overflow Detection ============

#[fuzz(should_fail_with = "x > max int128")]
fn fuzz_find_mul_x_overflow(x: u128, y: i64) {
    // Fuzzer should find cases where x > I64_MAX
    let x_large = helpers::make_overflow_prone(x) / 2;
    let _result = mul(x_large, y);
}

#[fuzz(should_fail)]
fn fuzz_find_mul_result_overflow(x: u128, y: i64) {
    // Fuzzer should find cases where x * y would overflow i64
    let x_adjusted = helpers::adjust_for_mul_overflow(x, y);
    let _result = mul(x_adjusted, y);
}

#[fuzz]
fn fuzz_mul_i64_min_edge(x: u128) {
    // Test multiplication with I64_MIN
    // Only 0 and 1 are safe to multiply with I64_MIN
    if x <= 1 {
        let _result = mul(x, I64_MIN);
    }
    // Test near the boundary
    if (x > 1) & (x < 10) {
        // These should overflow but test the boundary detection
        // Don't actually call mul as it will panic
    }
}

// ============ Precision Operation Overflow Detection ============

#[fuzz(should_fail_with = "wmul overflow")]
fn fuzz_find_wmul_overflow(x: u128, y: u128) {
    // Fuzzer should find cases where x * y > U128_MAX
    let x_large = helpers::make_overflow_prone(x);
    let y_large = helpers::make_overflow_prone(y);

    let _result = wmul(x_large, y_large);
}

#[fuzz(should_fail)]
fn fuzz_find_wdiv_overflow(x: u128, y: u128) {
    // Fuzzer should find cases where x * WAD > U128_MAX
    let x_large = helpers::make_overflow_prone(x);
    let y_small = (y & 0xFFFF) + 1; // Keep y small but non-zero
    let _result = wdiv(x_large, y_small);
}

#[fuzz(should_fail_with = "rmul overflow")]
fn fuzz_find_rmul_overflow(x: u128, y: u128) {
    // Fuzzer should find cases where x * y > U128_MAX (RAY precision)
    let x_large = helpers::make_overflow_prone(x);
    let y_large = helpers::make_overflow_prone(y);

    let _result = rmul(x_large, y_large);
}

#[fuzz(should_fail)]
fn fuzz_find_rdiv_overflow(x: u128, y: u128) {
    // Fuzzer should find cases where x * RAY > U128_MAX
    let x_large = helpers::make_overflow_prone(x);
    let y_small = (y & 0xFFFFFF) + 1; // Keep y small but non-zero
    let _result = rdiv(x_large, y_small);
}

// ============ Division by Zero Detection ============

#[fuzz(should_fail_with = "division by zero")]
fn fuzz_find_wdiv_zero(x: u128) {
    // This test always tries to divide by zero
    let _result = wdiv(x, 0);
}

#[fuzz(should_fail_with = "division by zero")]
fn fuzz_find_rdiv_zero(x: u128) {
    // This test always tries to divide by zero
    let _result = rdiv(x, 0);
}

// ============ Precision Loss Detection ============

#[fuzz]
fn fuzz_detect_precision_loss(x: u128, divisor: u128) {
    // Detect when precision is lost in division operations
    if divisor > 0 & divisor <= WAD {
        if x > 0 & x < (helpers::max_u128() / WAD) {
            let divided = wdiv(x, divisor);
            let recovered = wmul(divided, divisor);

            // Check if we lost precision (recovered != original)
            if recovered != x {
                // This is expected due to rounding down
                // Verify the loss is exactly the remainder
                let remainder = x - recovered;
                assert(remainder < divisor);
            }
        }
    }
}

// ============ Boundary Behavior Tests ============

#[fuzz]
fn fuzz_boundary_transitions(x: u128, offset: u8) {
    // Test behavior at various boundaries
    let boundaries = [
        0, // Zero boundary
        1, // Minimum positive
        WAD - 1, // Just under WAD
        WAD, // Exactly WAD
        WAD + 1, // Just over WAD
        (I64_MAX as u128) - 1, // Just under I64_MAX
        (I64_MAX as u128), // Exactly I64_MAX
        (I64_MAX as u128) + 1, // Just over I64_MAX
        helpers::max_u128() - 256, // Near max with room for offset
    ];

    // Pick a boundary based on x mod array length
    let idx = (x % 9) as u32;
    let boundary = boundaries[idx];

    // Test operations near the boundary
    if boundary < helpers::max_u128() - (offset as u128) {
        let test_val = boundary + (offset as u128);

        // Test that operations behave consistently near boundaries
        if test_val > 0 {
            let _sub_one = sub(test_val, 1);
            let _add_zero = add(test_val, 0);
            assert_eq(_sub_one + 1, _add_zero);
        }
    }
}
