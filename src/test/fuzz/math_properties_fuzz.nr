// BTT Tree Specification for Math Property Fuzz Tests
// ====================================================
// Mathematical Properties (Fuzz Testing)
// |-- Arithmetic Properties
// |   |-- Addition identity: x + 0 = x
// |   |-- Subtraction identity: x - 0 = x
// |   |-- Multiplication by zero: x * 0 = 0
// |   |-- Multiplication identity: x * 1 = x
// |   `-- Add/Sub inverse: (x + y) - y = x
// |-- Comparison Properties
// |   |-- Min/Max commutativity: min(a,b) = min(b,a)
// |   |-- Min/Max identity: min(x,x) = max(x,x) = x
// |   |-- Min/Max ordering: min(a,b) <= max(a,b)
// |   `-- Min/Max absorption: min(x, max(x,y)) = x
// |-- Precision Properties
// |   |-- WAD identity: wmul(x, WAD) = x
// |   |-- RAY identity: rmul(x, RAY) = x
// |   |-- Division inverse: wdiv(wmul(x,y), y) ~= x (when no overflow)
// |   `-- Rounding direction: always rounds down
// `-- Overflow Properties
//     |-- Safe operations within bounds
//     `-- Controlled failure at boundaries

use crate::{add, I64_MAX, max, min, mul, RAY, rmul, sub, WAD, wdiv, wmul};

// ============ Helper Functions for Property Validation ============

mod helpers {
    use crate::{I64_MAX, I64_MIN};

    // Check if a value is within safe bounds for operations
    pub fn is_safe_for_add(x: u128, y: i64) -> bool {
        if y >= 0 {
            x <= (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - (y as u128))
        } else if y == I64_MIN {
            // Special case: -I64_MIN would overflow
            false
        } else {
            x >= ((-y) as u128)
        }
    }

    // Check if multiplication would overflow
    pub fn is_safe_for_mul(x: u128, y: i64) -> bool {
        if y == 0 {
            x <= (I64_MAX as u128) // x must be valid for mul even with 0
        } else if y == I64_MIN {
            x <= 1
        } else {
            x <= (I64_MAX as u128)
        }
    }

    // Check if values are safe for precision operations
    pub fn is_safe_for_precision_ops(x: u128, y: u128) -> bool {
        // Avoid overflow in intermediate calculations
        if (x == 0) | (y == 0) {
            true
        } else {
            // Check if x * y would overflow
            x <= (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF / y)
        }
    }

    // Approximate equality with tolerance
    pub fn approx_eq(a: u128, b: u128, tolerance: u128) -> bool {
        if a > b {
            a - b <= tolerance
        } else {
            b - a <= tolerance
        }
    }
}

// ============ Arithmetic Property Fuzz Tests ============

#[fuzz]
fn fuzz_add_identity(x: u128) {
    // Property: x + 0 = x
    let result = add(x, 0);
    assert_eq(result, x);
}

#[fuzz]
fn fuzz_sub_identity(x: u128) {
    // Property: x - 0 = x
    let result = sub(x, 0);
    assert_eq(result, x);
}

#[fuzz]
fn fuzz_mul_zero(x: u128) {
    // Property: x * 0 = 0 (when x is within valid range)
    if helpers::is_safe_for_mul(x, 0) {
        let result = mul(x, 0);
        assert_eq(result, 0);
    }
}

#[fuzz]
fn fuzz_mul_identity(x: u128) {
    // Property: x * 1 = x (when x <= I64_MAX)
    if x <= (I64_MAX as u128) {
        let result = mul(x, 1);
        assert_eq(result, x as i64);
    }
}

#[fuzz]
fn fuzz_add_sub_inverse(x: u128, y: i64) {
    // Property: (x + y) - y = x (when operations are safe)
    if helpers::is_safe_for_add(x, y) {
        let added = add(x, y);
        if helpers::is_safe_for_add(added, -y) {
            let result = add(added, -y);
            assert_eq(result, x);
        }
    }
}

// ============ Comparison Property Fuzz Tests ============

#[fuzz]
fn fuzz_min_max_commutative(a: u128, b: u128) {
    // Property: min(a,b) = min(b,a) and max(a,b) = max(b,a)
    assert_eq(min(a, b), min(b, a));
    assert_eq(max(a, b), max(b, a));
}

#[fuzz]
fn fuzz_min_max_identity(x: u128) {
    // Property: min(x,x) = max(x,x) = x
    assert_eq(min(x, x), x);
    assert_eq(max(x, x), x);
}

#[fuzz]
fn fuzz_min_max_ordering(a: u128, b: u128) {
    // Property: min(a,b) <= max(a,b)
    let min_val = min(a, b);
    let max_val = max(a, b);
    assert(min_val <= max_val);
}

#[fuzz]
fn fuzz_min_max_absorption(x: u128, y: u128) {
    // Property: min(x, max(x,y)) = x
    let max_val = max(x, y);
    let result = min(x, max_val);
    assert_eq(result, x);

    // Property: max(x, min(x,y)) = x
    let min_val = min(x, y);
    let result2 = max(x, min_val);
    assert_eq(result2, x);
}

// ============ Precision Property Fuzz Tests ============

#[fuzz]
fn fuzz_wad_identity(x: u128) {
    // Property: wmul(x, WAD) = x (when safe)
    if helpers::is_safe_for_precision_ops(x, WAD) {
        let result = wmul(x, WAD);
        assert_eq(result, x);
    }
}

#[fuzz]
fn fuzz_ray_identity(x: u128) {
    // Property: rmul(x, RAY) = x (when safe)
    if helpers::is_safe_for_precision_ops(x, RAY) {
        let result = rmul(x, RAY);
        assert_eq(result, x);
    }
}

#[fuzz]
fn fuzz_wmul_wdiv_inverse(x: u128, y: u128) {
    // Property: wdiv(wmul(x, y), y) <= x (always rounds down or equal)
    // This is a weaker but more realistic property for integer division
    if (y > 0) & (y <= WAD * 2) {
        if helpers::is_safe_for_precision_ops(x, y) {
            let multiplied = wmul(x, y);
            // Skip test if multiplication results in 0 (complete precision loss)
            if multiplied > 0 {
                let result = wdiv(multiplied, y);
                // The result should never exceed the original value
                // (integer division always rounds down)
                assert(result <= x);

                // Additionally, if y == WAD, result should equal x
                if y == WAD {
                    assert_eq(result, x);
                }
            }
        }
    }
}

#[fuzz]
fn fuzz_precision_rounding_down(x: u128, y: u128) {
    // Property: Division always rounds down
    if y > 0 & y <= WAD {
        if helpers::is_safe_for_precision_ops(x, WAD) {
            let result = wdiv(x, y);
            // result * y should be <= x * WAD (accounting for rounding down)
            if helpers::is_safe_for_precision_ops(result, y) {
                let back = wmul(result, y);
                assert(back <= x);
            }
        }
    }
}

// ============ Distributive Property Fuzz Tests ============

#[fuzz]
fn fuzz_mul_over_add(x: u128, y: i64, z: i64) {
    // Property: x * (y + z) = (x * y) + (x * z) when safe
    // This is complex due to signed arithmetic, so we test specific safe cases
    if x <= 1000 & (y >= 0 & y <= 100) & (z >= 0 & z <= 100) {
        let sum = y + z;
        if helpers::is_safe_for_mul(x, sum) {
            let left = mul(x, sum);

            if helpers::is_safe_for_mul(x, y) & helpers::is_safe_for_mul(x, z) {
                let right1 = mul(x, y);
                let right2 = mul(x, z);
                let right = right1 + right2;
                assert_eq(left, right);
            }
        }
    }
}
