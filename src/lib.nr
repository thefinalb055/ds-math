// Math helpers ported from Solidity Math library

pub global WAD: u128 = 1_000_000_000_000_000_000;
pub global RAY: u128 = 1_000_000_000_000_000_000_000_000_000;
pub global RAD: Field = 1_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000;
pub global U128_MAX: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
pub global U64_MASK: u128 = 0xFFFFFFFFFFFFFFFF;
pub global U64_BASE: u128 = 0x10000000000000000;

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
            (I64_MAX as u128) + 1  // abs(I64_MIN)
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
            (I64_MAX as u128) + 1  // abs(I64_MIN)
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

pub fn diff(x: u128, y: u128) -> i64 {
    if x >= y {
        let delta: u128 = x - y;
        let max_positive: u128 = I64_MAX as u128;
        assert(delta <= max_positive, "diff overflow");
        delta as i64
    } else {
        let delta: u128 = y - x;
        let max_negative: u128 = (I64_MAX as u128) + 1;
        assert(delta <= max_negative, "diff overflow");

        if delta == max_negative {
            I64_MIN
        } else {
            let delta_i64: i64 = delta as i64;
            0 - delta_i64
        }
    }
}

// ============ Precision Conversion ============

pub fn to_rad(wad: u128) -> Field {
    // Convert from WAD (10^18) to RAD (10^45) by multiplying by 10^27
    let rad_multiplier: Field = RAY as Field; // 10^27
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
        let max_allowed = U128_MAX / y;
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
        let max_allowed = U128_MAX / WAD;
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
        let max_allowed = U128_MAX / y;
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
        let max_allowed = U128_MAX / RAY;
        assert(x <= max_allowed, "rdiv overflow");

        let scaled = x * RAY;
        // Round down by default
        scaled / y
    }
}

fn mul_wide_u128(a: u128, b: u128) -> (u128, u128) {
    let base: u128 = (1 as u128) << 32; // 2^32
    let mask: u128 = base - 1;

    let a_limbs: [u128; 4] = [
        a & mask,
        (a >> 32) & mask,
        (a >> 64) & mask,
        (a >> 96) & mask
    ];

    let b_limbs: [u128; 4] = [
        b & mask,
        (b >> 32) & mask,
        (b >> 64) & mask,
        (b >> 96) & mask
    ];

    let mut tmp: [u128; 9] = [0, 0, 0, 0, 0, 0, 0, 0, 0];

    for i in 0..4 {
        for j in 0..4 {
            let idx = i + j;
            let product = a_limbs[i] * b_limbs[j];
            tmp[idx] = tmp[idx] + product;
        }
    }

    for i in 0..8 {
        let carry = tmp[i] / base;
        tmp[i] = tmp[i] % base;
        tmp[i + 1] = tmp[i + 1] + carry;
    }

    assert(tmp[8] == 0, "rpow overflow");

    let lo: u128 = tmp[0]
        | (tmp[1] << 32)
        | (tmp[2] << 64)
        | (tmp[3] << 96);

    let hi: u128 = tmp[4]
        | (tmp[5] << 32)
        | (tmp[6] << 64)
        | (tmp[7] << 96);

    (hi, lo)
}

fn add_wide_u128(hi: u128, lo: u128, addend: u128) -> (u128, u128) {
    let max_u128: u128 = U128_MAX;
    let new_lo = lo + addend;
    let carry = if new_lo < lo { 1 } else { 0 };
    if carry == 1 {
        assert(hi < max_u128, "rpow overflow");
    }
    let new_hi = hi + carry;
    (new_hi, new_lo)
}

fn bit_length_u128(mut value: u128) -> u32 {
    let mut computed: u32 = 0;

    if value != 0 {
        let mut bits: u32 = 0;

        if value >> 64 != 0 {
            value = value >> 64;
            bits = bits + 64;
        }
        if value >> 32 != 0 {
            value = value >> 32;
            bits = bits + 32;
        }
        if value >> 16 != 0 {
            value = value >> 16;
            bits = bits + 16;
        }
        if value >> 8 != 0 {
            value = value >> 8;
            bits = bits + 8;
        }
        if value >> 4 != 0 {
            value = value >> 4;
            bits = bits + 4;
        }
        if value >> 2 != 0 {
            value = value >> 2;
            bits = bits + 2;
        }
        let mut final_bits = bits + 1;
        if value >> 1 != 0 {
            final_bits = bits + 2;
        }
        computed = final_bits;
    }

    computed
}

fn div_wide_u128_single(hi: u128, lo: u128, divisor: u128) -> (u128, u128) {
    let mask64: u128 = U64_MASK;

    let mut u_digits: [u128; 4] = [0, 0, 0, 0];
    u_digits[0] = lo & mask64;
    u_digits[1] = (lo >> 64) & mask64;
    u_digits[2] = hi & mask64;
    u_digits[3] = (hi >> 64) & mask64;

    let mut remainder: u128 = 0;
    let mut q_digits: [u128; 4] = [0, 0, 0, 0];

    for idx_rev in 0..4 {
        let i = 3 - idx_rev;
        let combined = (remainder << 64) | u_digits[i];
        let q_digit = combined / divisor;
        let new_remainder = combined - (q_digit * divisor);

        q_digits[i] = q_digit;
        remainder = new_remainder;
    }

    assert(q_digits[3] == 0, "rpow overflow");
    assert(q_digits[2] == 0, "rpow overflow");

    let quotient = q_digits[0] | (q_digits[1] << 64);

    (quotient, remainder)
}

fn normalize_digits(u: [u128; 5], v: [u128; 2], shift: u32) -> ([u128; 5], [u128; 2]) {
    let mask64: u128 = U64_MASK;
    let mut un: [u128; 5] = [0, 0, 0, 0, 0];
    let mut vn: [u128; 2] = [0, 0];

    if shift == 0 {
        un = u;
        vn = v;
    } else {
        let shift_u128: u128 = shift as u128;
        let inv_shift: u128 = 64 - shift_u128;

        vn[0] = (v[0] << shift_u128) & mask64;
        let carry_v = v[0] >> inv_shift;
        vn[1] = ((v[1] << shift_u128) & mask64) | carry_v;

        let mut carry: u128 = 0;
        for idx in 0..5 {
            let value = u[idx];
            let shifted = (value << shift_u128) & mask64;
            un[idx] = shifted | carry;
            carry = value >> inv_shift;
        }
        un[4] = carry;
    }

    (un, vn)
}

fn denormalize_remainder(un: [u128; 5], shift: u32) -> u128 {
    let combined = (un[1] << 64) | un[0];
    if shift == 0 {
        combined
    } else {
        let shift_u128: u128 = shift as u128;
        combined >> shift_u128
    }
}

fn div_wide_u128_double(hi: u128, lo: u128, divisor: u128) -> (u128, u128) {
    let base64: u128 = U64_BASE;
    let mask64: u128 = U64_MASK;

    let mut u_digits: [u128; 5] = [0, 0, 0, 0, 0];
    u_digits[0] = lo & mask64;
    u_digits[1] = (lo >> 64) & mask64;
    u_digits[2] = hi & mask64;
    u_digits[3] = (hi >> 64) & mask64;
    u_digits[4] = 0;

    let v_digits: [u128; 2] = [divisor & mask64, (divisor >> 64) & mask64];

    let v1_bits = bit_length_u128(v_digits[1]);
    let mut shift: u32 = 0;
    if v1_bits < 64 {
        shift = 64 - v1_bits;
    }

    let normalized = normalize_digits(u_digits, v_digits, shift);
    let mut un = normalized.0;
    let vn = normalized.1;

    let mut q_digits: [u128; 3] = [0, 0, 0];

    for idx_rev in 0..3 {
        let j = 2 - idx_rev;

        let numerator_high = un[j + 2];
        let numerator_mid = un[j + 1];
        let numerator_low = un[j];

        let combined = (numerator_high << 64) | numerator_mid;
        let mut q_hat = combined / vn[1];
        let mut r_hat = combined - (q_hat * vn[1]);

        if q_hat >= base64 {
            q_hat = base64 - 1;
            r_hat = r_hat + vn[1];
            if r_hat >= base64 {
                r_hat = r_hat - base64;
            }
        }

        let mut left = q_hat * vn[0];
        let mut right = (r_hat << 64) + numerator_low;

        for _ in 0..2 {
            if left > right {
                q_hat = q_hat - 1;
                r_hat = r_hat + vn[1];
                if r_hat >= base64 {
                    r_hat = r_hat - base64;
                }
                left = q_hat * vn[0];
                right = (r_hat << 64) + numerator_low;
            }
        }

        let mut borrow: u128 = 0;

        for k in 0..2 {
            let idx = j + k;
            let product = q_hat * vn[k];
            let sub = product + borrow;
            let sub_low = sub & mask64;
            borrow = sub >> 64;

            if un[idx] >= sub_low {
                un[idx] = un[idx] - sub_low;
            } else {
                un[idx] = un[idx] + base64 - sub_low;
                borrow = borrow + 1;
            }
        }

        if un[j + 2] >= borrow {
            un[j + 2] = un[j + 2] - borrow;
            borrow = 0;
        } else {
            un[j + 2] = un[j + 2] + base64 - borrow;
            borrow = 1;
        }

        if borrow != 0 {
            q_hat = q_hat - 1;

            let mut carry: u128 = 0;
            let sum0 = un[j] + vn[0];
            if sum0 >= base64 {
                un[j] = sum0 - base64;
                carry = 1;
            } else {
                un[j] = sum0;
                carry = 0;
            }

            let sum1 = un[j + 1] + vn[1] + carry;
            if sum1 >= base64 {
                un[j + 1] = sum1 - base64;
                carry = 1;
            } else {
                un[j + 1] = sum1;
                carry = 0;
            }

            let sum2 = un[j + 2] + carry;
            if sum2 >= base64 {
                un[j + 2] = sum2 - base64;
            } else {
                un[j + 2] = sum2;
            }
        }

        q_digits[j] = q_hat;
    }

    assert(q_digits[2] == 0, "rpow overflow");

    let quotient = q_digits[0] | (q_digits[1] << 64);
    let remainder = denormalize_remainder(un, shift);

    (quotient, remainder)
}

fn div_wide_u128(hi: u128, lo: u128, divisor: u128) -> (u128, u128) {
    assert(divisor != 0, "rpow overflow");

    let high_word = (divisor >> 64) & U64_MASK;

    if high_word == 0 {
        div_wide_u128_single(hi, lo, divisor & U64_MASK)
    } else {
        div_wide_u128_double(hi, lo, divisor)
    }
}

pub fn rpow(x: u128, n: u128, base: u128) -> u128 {
    // Binary exponentiation with rounding to nearest base using wide arithmetic.
    let mut result = 0;

    if x == 0 {
        if n == 0 {
            result = base;
        } else {
            result = 0;
        }
    } else {
        assert(base != 0, "rpow overflow");

        let half = base / 2;
        let mut exponent = n / 2;
        let mut current = x;
        let mut z = if n % 2 == 0 { base } else { x };

        for _ in 0..128 {
            if exponent != 0 {
                let xx = mul_wide_u128(current, current);
                let xx_round = add_wide_u128(xx.0, xx.1, half);
                assert(xx_round.0 < base, "rpow overflow");
                let div_current = div_wide_u128(xx_round.0, xx_round.1, base);
                current = div_current.0;

                if exponent % 2 == 1 {
                    let zx = mul_wide_u128(z, current);
                    let zx_round = add_wide_u128(zx.0, zx.1, half);
                    assert(zx_round.0 < base, "rpow overflow");
                    let div_z = div_wide_u128(zx_round.0, zx_round.1, base);
                    z = div_z.0;
                }

                exponent = exponent / 2;
            }
        }

        result = z;
    }

    result
}

mod test;
