# ds-math (Noir Port)

## Overview

This starter is a Noir port of the MakerDAO `DSMath` helpers. It exposes safe
arithmetic utilities for WAD (10¹⁸) and RAY (10²⁷) fixed-point domains together
with the overflow-checked primitives (`add`, `sub`, `mul`, `diff`) expected by
the original Solidity contracts. The library is packaged as a `nargo`
workspace, with TypeScript tooling provided for integration in Aztec rollup
projects.

## Runtime & Tooling

| Component          | Purpose                                                |
|--------------------|--------------------------------------------------------|
| `nargo` / Noir     | Compiles the library and executes the `#[test]` suites |
| `@aztec/*` packages| JS bindings and codegen helpers used by downstream apps|
| `bun`              | Script runner + package manager for the TS harness     |

The smart-contract code itself only relies on Noir’s standard library. All
tests documented below run via `nargo test`; the Aztec JS packages are used
only when building or integrating the generated artifacts.

## Core Algorithms

### Safe Exponentiation (`rpow`)

`rpow` performs binary exponentiation in RAY precision while matching the
round-to-nearest semantics of MakerDAO’s reference implementation. Noir limits
integers to 128 bits, so the function introduces explicit 256-bit arithmetic:

1. **Wide multiplication** – `mul_wide_u128` multiplies two 128-bit values via
   32-bit limbs, accumulating into a 256-bit buffer (Knuth schoolbook method).
2. **Wide addition with rounding** – `add_wide_u128` adds the rounding bias
   (`base / 2`) before division, preserving full precision in the high limb.
3. **Knuth-style long division** – `div_wide_u128_double` implements the
   normalized base-2³² division algorithm so the widened result can be reduced
   back to RAY space without relying on Noir’s native division.
4. **Overflow detection** – high limbs are compared against `base` before each
   reduction, emitting `"rpow overflow"` instead of the runtime multiply panic
   the compiler would otherwise raise.

This approach was chosen because Noir currently lacks a built-in `u256` type
or checked wide-multiply helpers. Alternative ideas—such as projecting the
intermediate results into `Field` or truncating intermediate multiplies—were
discarded because they either altered rounding behaviour or masked legitimate
overflow conditions demanded by downstream contracts.

### Signed Difference (`diff`)

`diff` emulates Maker’s signed subtraction while guaranteeing the result fits
inside `i64`. The implementation branches on the relation between the inputs:

- For `x ≥ y` the unsigned difference must not exceed `I64_MAX`. The result is
  cast to `i64` without loss.
- For `x < y` the unsigned delta may be at most `I64_MAX + 1`, the magnitude of
  `I64_MIN`. When the bound is tight we return `I64_MIN`; otherwise we cast the
  delta and negate it.

Both branches revert with `"diff overflow"` when the constraints are violated,
matching Maker’s revert strings.

## Project Structure

```
src/
  lib.nr                     # Library entry point (public math helpers)
  test/
    utils.nr                 # Shared fixtures & precision helpers
    unit/                    # Branch-targeted unit suites
    integration/             # Flow scenarios exercising multiple helpers
    fuzz/                    # nargo-backed fuzz harnesses
scripts/                     # Shell runners for fuzzing & CI glue
```

### Test Organisation

- **Unit tests (`src/test/unit`)** follow the Branching Tree Technique (BTT)
  captured in the file headers. Each helper file exposes a `helpers` module for
  setup data and asserts on the exact revert string or numeric result.
- **Integration flows (`src/test/integration`)** stitch together multiple math
  helpers to model collateral ratios, interest accrual, liquidation checks,
  etc.
- **Fuzz tests (`src/test/fuzz`)** lean on Noir’s property test harness to
  search for arithmetic edge cases and overflow regressions.

Shared fixtures live in `src/test/utils.nr`. Recent clean-up extracted WAD/RAY
fractions (`wad_ratio`, `ray_ratio`), boundary constants, and helper functions
such as `approx_eq` so individual test modules avoid re-declaring magic numbers.

### Running the test suites

```bash
# Execute the full Noir test matrix
nargo test

# Optional fuzz campaign (see scripts/fuzz.sh for options)
nargo fuzz --test fuzz
```

The repository still ships Aztec JS scripts (`bun run compile`, etc.), but they
are not required when iterating on the Noir sources.

## Development Notes

- Precision constants (`WAD`, `RAY`, `RAD`) are defined once in `src/lib.nr`
  and re-used everywhere, including tests.
- Avoid scattering large literals in tests—leverage the helpers in
  `src/test/utils.nr` for fractional WAD/RAY values or add new helpers there.
- Match revert strings exactly (`"rpow overflow"`, `"diff overflow"`, …) to
  honour the semantics expected by dependent contracts.

## Further Reading

- [Noir Integer Data Types](https://noir-lang.org/docs/noir/concepts/data_types/integers)
- [Noir Fields & Coercions](https://noir-lang.org/docs/noir/concepts/data_types/fields)
- MakerDAO’s original [DSMath.sol](https://github.com/makerdao/dss/blob/master/src/ds-note.sol)
