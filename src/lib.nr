// Math helpers ported from Solidity Math library

pub global WAD: u128 = 1_000_000_000_000_000_000;
pub global RAY: u128 = 1_000_000_000_000_000_000_000_000_000;
pub global RAD: Field = 1_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;

pub global I64_MAX: i64 = 9_223_372_036_854_775_807;
pub global I64_MIN: i64 = -9_223_372_036_854_775_808;

pub fn add(x: u128, y: i64) -> u128 {
    if y >= 0 {
        let y_u: u128 = y as u128;
        let z: u128 = x + y_u;
        assert(z >= x, "overflow");
        z
    } else {
        // Special handling for I64_MIN
        let abs_y: u128 = if y == I64_MIN {
            9223372036854775808  // abs(I64_MIN)
        } else {
            let abs_y_i: i64 = 0 - y;
            abs_y_i as u128
        };
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
        // Special handling for I64_MIN
        let abs_y: u128 = if y == I64_MIN {
            9223372036854775808  // abs(I64_MIN)
        } else {
            let abs_y_i: i64 = 0 - y;
            abs_y_i as u128
        };
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

// ============ Min/Max Functions ============

pub fn min(x: u128, y: u128) -> u128 {
    if x < y {
        x
    } else {
        y
    }
}

pub fn max(x: u128, y: u128) -> u128 {
    if x > y {
        x
    } else {
        y
    }
}

// ============ Precision Conversion ============

pub fn to_rad(wad: u128) -> Field {
    // Convert from WAD (10^18) to RAD (10^45) by multiplying by 10^27
    let rad_multiplier: Field = 1_000_000_000_000_000_000_000_000_000; // 10^27
    let wad_as_field: Field = wad as Field;
    wad_as_field * rad_multiplier
}

// ============ WAD Precision Operations ============

pub fn wmul(x: u128, y: u128) -> u128 {
    // Multiply with WAD precision: (x * y) / WAD
    // First check for overflow in multiplication
    if (x == 0) | (y == 0) {
        0
    } else {
        // Check if x * y would overflow u128
        let max_allowed = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF / y;
        assert(x <= max_allowed, "wmul overflow");

        let product = x * y;
        // Round down by default
        product / WAD
    }
}

pub fn wdiv(x: u128, y: u128) -> u128 {
    // Divide with WAD precision: (x * WAD) / y
    assert(y != 0, "division by zero");

    if x == 0 {
        0
    } else {
        // Check if x * WAD would overflow u128
        let max_allowed = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF / WAD;
        assert(x <= max_allowed, "wdiv overflow");

        let scaled = x * WAD;
        // Round down by default
        scaled / y
    }
}

// ============ RAY Precision Operations ============

pub fn rmul(x: u128, y: u128) -> u128 {
    // Multiply with RAY precision: (x * y) / RAY
    if (x == 0) | (y == 0) {
        0
    } else {
        // Check if x * y would overflow u128
        let max_allowed = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF / y;
        assert(x <= max_allowed, "rmul overflow");

        let product = x * y;
        // Round down by default
        product / RAY
    }
}

pub fn rdiv(x: u128, y: u128) -> u128 {
    // Divide with RAY precision: (x * RAY) / y
    assert(y != 0, "division by zero");

    if x == 0 {
        0
    } else {
        // Check if x * RAY would overflow u128
        let max_allowed = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF / RAY;
        assert(x <= max_allowed, "rdiv overflow");

        let scaled = x * RAY;
        // Round down by default
        scaled / y
    }
}

mod test;
