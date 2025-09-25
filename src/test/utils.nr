use crate::{WAD, RAY, I64_MAX, I64_MIN};

// --- generated start ---
// Test utilities for Math library tests
// Generated from BTT tree specification

pub unconstrained fn setup() {
    // Simple setup function for tests
}

// ============ Boundary Value Fixtures ============

pub fn max_u128() -> u128 {
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}

pub fn min_u128() -> u128 {
    0
}

pub fn near_max_u128() -> u128 {
    max_u128() - 1000
}

pub fn near_min_u128() -> u128 {
    1000
}

pub fn max_i64() -> i64 {
    I64_MAX
}

pub fn min_i64() -> i64 {
    I64_MIN
}

pub fn i64_min_abs() -> u128 {
    9223372036854775808  // abs(I64_MIN)
}

// Helper to create WAD-scaled values
pub fn wad(value: u128) -> u128 {
    value * WAD
}

// Helper to create RAY-scaled values
pub fn ray(value: u128) -> u128 {
    value * RAY
}

// Helper to check if two values are approximately equal (for precision tests)
pub fn approx_eq(a: u128, b: u128, tolerance: u128) -> bool {
    if a > b {
        a - b <= tolerance
    } else {
        b - a <= tolerance
    }
}

// Test data generators for fuzz testing
pub fn generate_safe_u128_pair() -> (u128, u128) {
    // Returns two u128 values that won't overflow when multiplied
    let x = 1000000000000000; // 10^15
    let y = 1000000000000000; // 10^15
    (x, y)
}

pub fn generate_safe_i64() -> i64 {
    // Returns an i64 value safe for most operations
    1000000
}

pub fn generate_boundary_values() -> [u128; 5] {
    [
        0,
        1,
        WAD,
        near_max_u128() / 2,
        near_max_u128()
    ]
}
// --- generated end ---
