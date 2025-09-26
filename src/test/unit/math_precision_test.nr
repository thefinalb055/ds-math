// BTT Tree Specification for Math Precision Functions
// =====================================================
// Math::wmul
// |-- When either x or y is zero
// |   `-- It should return 0
// |-- When x * y / WAD does not overflow
// |   |-- When division is exact
// |   |   `-- It should return exact quotient
// |   `-- When there is a remainder
// |       `-- It should round down
// `-- When x * y would overflow U128_MAX
//     `-- It should revert with "wmul overflow"
//
// Math::wdiv
// |-- When y is zero
// |   `-- It should revert with "division by zero"
// |-- When x is zero
// |   `-- It should return 0
// `-- When x * WAD / y does not overflow
//     `-- It should return x * WAD / y
//
// Math::rmul
// |-- When either x or y is zero
// |   `-- It should return 0
// `-- When x * y / RAY does not overflow
//     `-- It should return x * y / RAY
//
// Math::rdiv
// |-- When y is zero
// |   `-- It should revert with "division by zero"
// `-- When x * RAY / y does not overflow
//     `-- It should return x * RAY / y
//
// Math::to_rad
// |-- When wad is zero
// |   `-- It should return 0 as Field
// `-- When wad * 10^27 does not overflow Field
//     `-- It should return wad * 10^27 as Field

use crate::{WAD, RAY, RAD, wmul, wdiv, rmul, rdiv, to_rad};

// ============ Helper Functions for Branch Conditions ============

mod helpers {
    use crate::{WAD, RAY};
    use crate::test::utils::{max_u128, wad_ratio, ray_ratio};

    // Test constants to avoid magic numbers
    pub fn TEST_VALUE() -> u128 { 12345 }
    pub fn TEST_VALUE_SMALL() -> u128 { 2 }
    pub fn WAD_ONE_POINT_FIVE() -> u128 { wad_ratio(3, 2) }  // 1.5 in WAD
    pub fn WAD_ONE_POINT_THREE() -> u128 { wad_ratio(4, 3) }  // 1.333... in WAD
    pub fn WAD_TWO() -> u128 { wad_ratio(2, 1) }  // 2.0 in WAD
    pub fn RAY_ONE_POINT_ONE() -> u128 { ray_ratio(11, 10) }  // 1.1 in RAY
    pub fn RAD_TEN_TO_27() -> Field { 1_000_000_000_000_000_000_000_000_000 }  // 10^27

    // wmul helpers
    pub fn setup_wmul_zero() -> [(u128, u128); 2] {
        [(0, TEST_VALUE()), (TEST_VALUE(), 0)]
    }

    pub fn setup_wmul_exact() -> (u128, u128) {
        (WAD, TEST_VALUE_SMALL())  // WAD * 2 / WAD = 2 (exact)
    }

    pub fn setup_wmul_rounds_down() -> (u128, u128) {
        (WAD_ONE_POINT_FIVE(), WAD_ONE_POINT_THREE())  // 1.5 * 1.333... rounds down
    }

    pub fn setup_wmul_overflow() -> (u128, u128) {
        (max_u128(), TEST_VALUE_SMALL())
    }

    // wdiv helpers
    pub fn setup_wdiv_zero_denominator() -> (u128, u128) {
        (TEST_VALUE(), 0)
    }

    pub fn setup_wdiv_zero_numerator() -> (u128, u128) {
        (0, TEST_VALUE())
    }

    pub fn setup_wdiv_exact() -> (u128, u128) {
        (TEST_VALUE_SMALL(), TEST_VALUE_SMALL())  // 2 * WAD / 2 = WAD
    }

    // rmul helpers
    pub fn setup_rmul_zero() -> [(u128, u128); 2] {
        [(0, TEST_VALUE()), (TEST_VALUE(), 0)]
    }

    pub fn setup_rmul_no_overflow() -> (u128, u128) {
        (RAY, TEST_VALUE_SMALL())  // RAY * 2 / RAY = 2
    }

    // rdiv helpers
    pub fn setup_rdiv_zero_denominator() -> (u128, u128) {
        (TEST_VALUE(), 0)
    }

    pub fn setup_rdiv_no_overflow() -> (u128, u128) {
        (TEST_VALUE_SMALL(), TEST_VALUE_SMALL())  // 2 * RAY / 2 = RAY
    }

    // to_rad helpers
    pub fn setup_to_rad_zero() -> u128 {
        0
    }

    pub fn setup_to_rad_conversion() -> u128 {
        1  // Will convert to 10^27
    }

    pub fn setup_to_rad_wad() -> u128 {
        WAD  // Will convert to RAD
    }
}

// ============ wmul tests ============

#[test]
fn test_wmul_zero() {
    // Branch: Math::wmul -> When either x or y is zero -> It should return 0
    let zero_cases = helpers::setup_wmul_zero();

    for case in zero_cases {
        let (x, y) = case;
        let result = wmul(x, y);
        assert_eq(result, 0);
    }
}

#[test]
fn test_wmul_exact() {
    // Branch: Math::wmul -> When x * y / WAD does not overflow -> When division is exact -> It should return exact quotient
    let (x, y) = helpers::setup_wmul_exact();

    let result = wmul(x, y);

    assert_eq(result, helpers::TEST_VALUE_SMALL());  // WAD * 2 / WAD = 2
}

#[test]
fn test_wmul_rounds_down() {
    // Branch: Math::wmul -> When x * y / WAD does not overflow -> When there is a remainder -> It should round down
    let (x, y) = helpers::setup_wmul_rounds_down();

    let result = wmul(x, y);

    // 1.5 * 1.333... = 1.9999... which rounds down to less than 2.0
    assert(result < helpers::WAD_TWO());
}

#[test(should_fail_with = "wmul overflow")]
fn test_wmul_overflow() {
    // Branch: Math::wmul -> When x * y would overflow U128_MAX -> It should revert
    let (x, y) = helpers::setup_wmul_overflow();

    let _result = wmul(x, y);
}

// ============ wdiv tests ============

#[test(should_fail_with = "division by zero")]
fn test_wdiv_zero_denominator() {
    // Branch: Math::wdiv -> When y is zero -> It should revert
    let (x, y) = helpers::setup_wdiv_zero_denominator();

    let _result = wdiv(x, y);
}

#[test]
fn test_wdiv_zero_numerator() {
    // Branch: Math::wdiv -> When x is zero -> It should return 0
    let (x, y) = helpers::setup_wdiv_zero_numerator();

    let result = wdiv(x, y);

    assert_eq(result, 0);
}

#[test]
fn test_wdiv_exact() {
    // Branch: Math::wdiv -> When x * WAD / y does not overflow -> It should return x * WAD / y
    let (x, y) = helpers::setup_wdiv_exact();

    let result = wdiv(x, y);

    assert_eq(result, WAD);  // 2 * WAD / 2 = WAD
}

// ============ rmul tests ============

#[test]
fn test_rmul_zero() {
    // Branch: Math::rmul -> When either x or y is zero -> It should return 0
    let zero_cases = helpers::setup_rmul_zero();

    for case in zero_cases {
        let (x, y) = case;
        let result = rmul(x, y);
        assert_eq(result, 0);
    }
}

#[test]
fn test_rmul_no_overflow() {
    // Branch: Math::rmul -> When x * y / RAY does not overflow -> It should return x * y / RAY
    let (x, y) = helpers::setup_rmul_no_overflow();

    let result = rmul(x, y);

    assert_eq(result, helpers::TEST_VALUE_SMALL());  // RAY * 2 / RAY = 2
}

// ============ rdiv tests ============

#[test(should_fail_with = "division by zero")]
fn test_rdiv_zero_denominator() {
    // Branch: Math::rdiv -> When y is zero -> It should revert
    let (x, y) = helpers::setup_rdiv_zero_denominator();

    let _result = rdiv(x, y);
}

#[test]
fn test_rdiv_no_overflow() {
    // Branch: Math::rdiv -> When x * RAY / y does not overflow -> It should return x * RAY / y
    let (x, y) = helpers::setup_rdiv_no_overflow();

    let result = rdiv(x, y);

    assert_eq(result, RAY);  // 2 * RAY / 2 = RAY
}

// ============ to_rad tests ============

#[test]
fn test_to_rad_zero() {
    // Branch: Math::to_rad -> When wad is zero -> It should return 0 as Field
    let wad = helpers::setup_to_rad_zero();

    let result = to_rad(wad);

    let expected: Field = 0;
    assert_eq(result, expected);
}

#[test]
fn test_to_rad_conversion() {
    // Branch: Math::to_rad -> When wad * 10^27 does not overflow Field -> It should return wad * 10^27 as Field
    let wad = helpers::setup_to_rad_conversion();

    let result = to_rad(wad);

    // 1 * 10^27 = 10^27
    let expected = helpers::RAD_TEN_TO_27();
    assert_eq(result, expected);
}

#[test]
fn test_to_rad_wad_to_rad() {
    // Branch: Math::to_rad -> When wad * 10^27 does not overflow Field -> It should return wad * 10^27 as Field
    let wad = helpers::setup_to_rad_wad();

    let result = to_rad(wad);

    // RAD is 10^45, WAD is 10^18, so WAD * 10^27 = 10^45 = RAD
    let expected: Field = RAD;
    assert_eq(result, expected);
}
