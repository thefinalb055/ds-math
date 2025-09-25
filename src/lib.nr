// Math helpers ported from Solidity Math library

pub global WAD: u128 = 1_000_000_000_000_000_000;
pub global RAY: u128 = 1_000_000_000_000_000_000_000_000_000;
pub global RAD: Field = 1_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;

pub global I64_MAX: i64 = 9_223_372_036_854_775_807;
pub global I64_MIN: i64 = -9_223_372_036_854_775_808;

pub fn add(x: u128, y: i64) -> u128 {
    if y >= 0 {
        let y_u: u128 = y as u128;
        let z: u128 = x + y_u;
        assert(z >= x, "overflow");
        z
    } else {
        let abs_y_i: i64 = 0 - y;
        let abs_y: u128 = abs_y_i as u128;
        assert(x >= abs_y, "underflow");
        x - abs_y
    }
}

pub fn sub(x: u128, y: i64) -> u128 {
    if y >= 0 {
        let y_u: u128 = y as u128;
        assert(x >= y_u, "underflow");
        x - y_u
    } else {
        let abs_y_i: i64 = 0 - y;
        let abs_y: u128 = abs_y_i as u128;
        let z: u128 = x + abs_y;
        assert(z >= x, "overflow");
        z
    }
}

pub fn mul(x: u128, y: i64) -> i64 {
    let max_i64_u: u128 = I64_MAX as u128;
    assert(x <= max_i64_u, "x > max int128");

    let y_is_zero: bool = y == 0;
    let result: i64 = if y_is_zero {
        0
    } else {
        // Compute |y| in u128 without overflowing when y == i64::MIN
        let y_abs_u: u128 = if y < 0 {
            // i64::MIN is -I64_MAX - 1; handle it specially
            if y == I64_MIN {
                (I64_MAX as u128) + 1
            } else {
                let pos: i64 = 0 - y;
                pos as u128
            }
        } else {
            y as u128
        };

        // Choose limit magnitude based on sign of y
        let limit_u: u128 = if y < 0 {
            (I64_MAX as u128) + 1
        } else {
            I64_MAX as u128
        };
        let threshold_u: u128 = limit_u / y_abs_u;
        assert(x <= threshold_u, "mul overflow");

        let x_i: i64 = x as i64;
        x_i * y
    };

    result
}
