# Test Writing Guidelines for BTT (Branching Tree Technique)

This document defines the patterns and conventions for writing tests that follow the Branching Tree Technique specification.

## Core Principles

1. **Every test maps to a tree branch** - Each test function should correspond to exactly one leaf node in the BTT tree
2. **Tree structure in comments** - The relevant tree branches must be documented at the top of each test file
3. **Use helper functions for conditions** - Complex branch conditions should have dedicated setup functions
4. **Consistent naming** - Test names should reflect their tree path

## File Structure

Each test file should follow this structure:

```noir
// BTT Tree Specification for this file:
// =====================================
// Math::function_name
// ├── When [condition A]
// │   ├── It should [outcome 1]
// │   └── It should [outcome 2]
// └── When [condition B]
//     └── It should [outcome 3]

use crate::{function_under_test, constants};
use crate::test::utils::{fixtures, helpers};

// Helper functions for branch conditions
mod helpers {
    // Setup function for "When condition A"
    pub fn setup_condition_a() -> TestInputs { ... }

    // Setup function for nested conditions
    pub fn setup_condition_a_with_edge_case() -> TestInputs { ... }
}

// Tests organized by tree structure
#[test]
fn test_condition_a_outcome_1() {
    // Branch: Math::function -> When condition A -> It should outcome 1
    let (x, y) = helpers::setup_condition_a();
    // ... test implementation
}
```

## Naming Conventions

### Test Function Names
- Format: `test_{condition}_{expected_outcome}`
- Use underscores to separate logical parts
- Examples:
  - `test_positive_y_no_overflow`
  - `test_negative_y_underflow`
  - `test_i64_min_edge_case`

### Helper Function Names
- Format: `setup_{condition}` or `create_{scenario}`
- Should describe what state they create
- Examples:
  - `setup_overflow_scenario()`
  - `create_near_boundary_values()`
  - `setup_i64_min_with_safe_x()`

## Helper Function Patterns

### Basic Condition Setup
```noir
// For simple "When X" conditions
pub fn setup_positive_y() -> (u128, i64) {
    (100, 50)  // x=100, y=50 (positive)
}
```

### Nested Condition Setup
```noir
// For "When X AND When Y" nested conditions
pub fn setup_positive_y_near_overflow() -> (u128, i64) {
    let x = max_u128() - 10;
    let y = 20;  // Will overflow when added
    (x, y)
}
```

### Edge Case Helpers
```noir
// Dedicated helpers for specific edge cases
pub fn setup_i64_min_scenario() -> (u128, i64) {
    (safe_value_for_i64_min(), I64_MIN)
}
```

## Fixture Usage

Always use fixtures from `utils.nr` instead of inline constants:

### ❌ Bad
```noir
let max_val = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
```

### ✅ Good
```noir
use crate::test::utils::max_u128;
let max_val = max_u128();
```

## Available Fixtures (from utils.nr)

- `max_u128()` - Maximum u128 value
- `near_max_u128()` - Close to maximum (max - 1000)
- `near_min_u128()` - Close to minimum (1000)
- `wad(value)` - Convert to WAD precision
- `ray(value)` - Convert to RAY precision
- `approx_eq(a, b, tolerance)` - Check approximate equality
- `generate_safe_u128_pair()` - Generate values that won't overflow
- `generate_safe_i64()` - Generate safe i64 value
- `generate_boundary_values()` - Array of boundary test values

## Test Organization

### By Tree Structure
Group related tests together following the tree hierarchy:

```noir
// ============ When y is positive ============
#[test]
fn test_positive_no_overflow() { ... }

#[test(should_fail_with = "overflow")]
fn test_positive_overflow() { ... }

// ============ When y is negative ============
#[test]
fn test_negative_no_underflow() { ... }

#[test(should_fail_with = "underflow")]
fn test_negative_underflow() { ... }

// ============ When y is zero ============
#[test]
fn test_zero_unchanged() { ... }
```

### Documentation Comments
Each test should have a comment indicating its BTT path:

```noir
#[test]
fn test_add_positive_overflow() {
    // Branch: Math::add -> When y is positive -> When x + y would overflow -> It should revert
    let (x, y) = setup_overflow_scenario();
    let _result = add(x, y); // Should panic
}
```

## Complex Branch Patterns

For deeply nested branches, create a hierarchy of helpers:

```noir
// Level 1: Basic condition
pub fn with_i64_min() -> i64 {
    I64_MIN
}

// Level 2: Nested condition
pub fn with_i64_min_and_zero_x() -> (u128, i64) {
    (0, with_i64_min())
}

// Level 3: Deep nesting
pub fn with_i64_min_overflow_scenario() -> (u128, i64) {
    (2, with_i64_min())  // Will overflow when multiplied
}
```

## Fuzz Test Patterns

For property-based tests, create generators that respect invariants:

```noir
pub fn generate_inputs_for_property(iteration: u32) -> TestInputs {
    // Use iteration as seed for deterministic generation
    // Ensure generated values respect the property being tested
}

#[test]
fn test_fuzz_property() {
    for i in 0..100 {
        let inputs = generate_inputs_for_property(i);
        // Test the property holds
    }
}
```

## Anti-Patterns to Avoid

1. **Don't use magic numbers** - Use named constants or fixtures
2. **Don't duplicate setup code** - Extract to helper functions
3. **Don't test multiple branches in one test** - Each test should map to one leaf
4. **Don't forget tree documentation** - Always include the BTT spec
5. **Don't mix concerns** - Separate setup, execution, and assertion clearly

## Example: Complete Test File

See `math_add_test.nr` for a complete example following all these patterns.

## Fuzz Testing Guidelines

Noir includes a powerful fuzzer for property-based testing and finding edge cases. Fuzz tests use the `#[fuzz]` attribute and let the fuzzer generate test inputs automatically.

### When to Use Fuzz Tests vs Regular Tests

**Use Fuzz Tests (`#[fuzz]`) for:**
- Testing mathematical properties that should hold for ALL inputs
- Finding edge cases and boundary conditions automatically
- Detecting overflow/underflow conditions
- Verifying precision guarantees across random inputs
- Differential testing against oracles

**Use Regular Tests (`#[test]`) for:**
- Known edge cases and regression tests
- Specific scenarios with expected outputs
- Integration tests with complex setup
- Deterministic property verification

### Fuzz Test Structure

```noir
#[fuzz]
fn fuzz_property_name(x: u128, y: i64) {
    // Fuzzer will generate x and y values
    // Test a property that should always hold
    assert(some_property(x, y));
}

#[fuzz(should_fail_with = "overflow")]
fn fuzz_find_overflow(x: u128, y: i64) {
    // Fuzzer will try to find inputs that cause overflow
    let _result = add(x, y);
}

#[fuzz(only_fail_with = "specific error")]
fn fuzz_specific_failure(x: u128) {
    // Only interested in one specific failure mode
    // Other failures are ignored
}
```

### Fuzz Test Helpers

Create helper functions for:
- **Boundary checks**: `is_safe_for_operation(x, y)`
- **Property validation**: `check_invariant(result)`
- **Input transformation**: `make_overflow_prone(x)`

### Naming Convention

- **Fuzz test functions**: `fuzz_<property>_<condition>`
- **Property validators**: `check_<property>`
- **Safety checkers**: `is_safe_for_<operation>`
- **Files**:
  - `*_fuzz.nr` for actual fuzz tests
  - `*_test.nr` for deterministic tests

### Running Fuzz Tests

```bash
# Run all fuzz tests
nargo fuzz

# Run specific fuzz harness
nargo fuzz fuzz_add_overflow

# Run with custom timeout (seconds)
nargo fuzz --timeout 60

# Run with multiple threads
nargo fuzz --num-threads 4

# Save corpus for regression testing
nargo fuzz --corpus-dir ./fuzz-corpus
```

### Best Practices

1. **Keep fuzz tests focused** - Test one property at a time
2. **Use helper functions** - Extract complex property checks
3. **Transform inputs when needed** - Guide the fuzzer toward interesting cases
4. **Document the property** - Clearly state what invariant is being tested
5. **Combine with regular tests** - Use both approaches for comprehensive coverage

## Maintenance

When updating tests:
1. Update the BTT tree comment if the specification changes
2. Ensure helper functions remain aligned with their conditions
3. Keep fixture functions general and reusable
4. Document any new patterns discovered
5. Run fuzz tests periodically to find new edge cases
6. Add interesting fuzz findings as regression tests