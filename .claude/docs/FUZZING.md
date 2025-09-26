# Fuzz Testing Guide

This project includes comprehensive fuzz testing for the DS-Math library using Noir's built-in fuzzer.

## Quick Start

```bash
# Run all fuzz tests with default settings
npm run fuzz

# Quick run (10s timeout, 4 threads)
npm run fuzz:quick

# Thorough run (300s timeout, 8 threads)
npm run fuzz:thorough

# List all available fuzz harnesses
npm run fuzz:list
```

## Using the Fuzz Script

The `scripts/fuzz.sh` script provides flexible configuration for running fuzz tests:

### Basic Usage

```bash
# Run all fuzz tests
./scripts/fuzz.sh

# Run tests matching a pattern
./scripts/fuzz.sh add              # Tests with 'add' in the name
./scripts/fuzz.sh math_properties   # Property tests

# Run specific test categories
./scripts/fuzz.sh --properties     # Mathematical property tests only
./scripts/fuzz.sh --overflow       # Overflow detection tests only
```

### Configuration Options

```bash
# Set timeout (seconds per harness, 0 = unlimited)
./scripts/fuzz.sh --timeout 120

# Set number of threads
./scripts/fuzz.sh --threads 8

# Limit maximum executions (0 = unlimited)
./scripts/fuzz.sh --max-exec 10000

# Combine options
./scripts/fuzz.sh --timeout 60 --threads 4 --max-exec 50000

# Use corpus directory for saving/loading test cases
./scripts/fuzz.sh --corpus ./fuzz-corpus

# Save failing test cases to specific directory
./scripts/fuzz.sh --failure-dir ./fuzz-failures
```

### Preset Modes

```bash
# Quick mode: 10 second timeout, 4 threads
./scripts/fuzz.sh --quick

# Thorough mode: 300 second timeout, 8 threads
./scripts/fuzz.sh --thorough
```

### Environment Variables

You can also configure defaults using environment variables:

```bash
# Set default timeout to 120 seconds
export FUZZ_TIMEOUT=120

# Set default thread count
export FUZZ_THREADS=8

# Set maximum executions
export FUZZ_MAX_EXECUTIONS=100000

# Set corpus directory
export FUZZ_CORPUS_DIR=./my-corpus

# Now run with these defaults
npm run fuzz
```

## Available Fuzz Tests

### Mathematical Properties (`math_properties_fuzz.nr`)
Tests that verify mathematical invariants and properties:

#### Arithmetic Properties (5 tests)
- `fuzz_add_identity` - Addition with zero: x + 0 = x
- `fuzz_sub_identity` - Subtraction with zero: x - 0 = x
- `fuzz_mul_zero` - Multiplication by zero: x * 0 = 0
- `fuzz_mul_identity` - Multiplication by one: x * 1 = x
- `fuzz_add_sub_inverse` - Add/subtract inverse: (x + y) - y = x

#### Comparison Properties (4 tests)
- `fuzz_min_max_commutative` - Commutativity: min(a,b) = min(b,a)
- `fuzz_min_max_identity` - Identity: min(x,x) = max(x,x) = x
- `fuzz_min_max_ordering` - Ordering: min(a,b) ≤ max(a,b)
- `fuzz_min_max_absorption` - Absorption: min(x, max(x,y)) = x

#### Precision Properties (5 tests)
- `fuzz_wad_identity` - WAD precision: wmul(x, WAD) = x
- `fuzz_ray_identity` - RAY precision: rmul(x, RAY) = x
- `fuzz_wmul_wdiv_inverse` - Division inverses multiplication
- `fuzz_precision_rounding_down` - Rounding always goes down
- `fuzz_mul_over_add` - Limited distributive property

### Overflow Detection (`math_overflow_fuzz.nr`)
Tests that hunt for overflow and edge cases:

#### Addition Overflow (3 tests)
- `fuzz_find_add_positive_overflow` - Find x + y > U128_MAX
- `fuzz_find_add_negative_underflow` - Find x < |y| underflow
- `fuzz_add_near_boundary` - Test near-boundary operations

#### Multiplication Overflow (3 tests)
- `fuzz_find_mul_x_overflow` - Find x > I64_MAX overflow
- `fuzz_find_mul_result_overflow` - Find x * y overflow
- `fuzz_mul_i64_min_edge` - Test I64_MIN edge cases

#### Precision Overflow (6 tests)
- `fuzz_find_wmul_overflow` - WAD multiplication overflow
- `fuzz_find_wdiv_overflow` - WAD division overflow
- `fuzz_find_wdiv_zero` - Division by zero (WAD)
- `fuzz_find_rmul_overflow` - RAY multiplication overflow
- `fuzz_find_rdiv_overflow` - RAY division overflow
- `fuzz_find_rdiv_zero` - Division by zero (RAY)

#### Edge Cases (2 tests)
- `fuzz_detect_precision_loss` - Precision loss detection
- `fuzz_boundary_transitions` - Behavior at boundaries

## Running Specific Tests

To run a specific fuzz harness:

```bash
# Run by exact name
./scripts/fuzz.sh fuzz_add_identity

# Run by partial match
./scripts/fuzz.sh add_identity

# Run with custom configuration
./scripts/fuzz.sh fuzz_add_overflow --timeout 120 --threads 4

# Run and save corpus
./scripts/fuzz.sh fuzz_mul_overflow --corpus ./overflow-corpus
```

## Understanding Fuzz Output

The fuzzer provides real-time metrics during execution:

```
Running 1 fuzz harnesses
test::fuzz::math_properties_fuzz::fuzz_add_identity

[NEW]  CNT: 1234  CRPS: 45  AB_NEW: 12  B_NEW: 3  A_TIME: 5.2s  B_TIME: 1.1s  M_TIME: 0.3s
[LOOP] CNT: 5678  CRPS: 47  AB_NEW: 14  B_NEW: 4  A_TIME: 12.3s B_TIME: 2.5s  M_TIME: 0.7s
```

- **CNT**: Total number of test cases executed
- **CRPS**: Active test cases in corpus
- **AB_NEW**: New ACIR test cases found
- **B_NEW**: New Brillig test cases found
- **A_TIME**: Time spent in ACIR execution mode
- **B_TIME**: Time spent in Brillig execution mode
- **M_TIME**: Time spent mutating inputs

## Continuous Integration

For CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Quick Fuzz Test
  run: npm run fuzz:quick

# For nightly thorough testing
- name: Thorough Fuzz Test
  run: npm run fuzz:thorough
  timeout-minutes: 30
```

## Corpus Management

The fuzzer maintains a corpus of interesting test cases:

```bash
# Save corpus for regression testing
./scripts/fuzz.sh --corpus ./corpus --timeout 300

# Reuse corpus in future runs (start from saved cases)
./scripts/fuzz.sh --corpus ./corpus

# Save failing test cases separately
./scripts/fuzz.sh --failure-dir ./failures
```

## Interpreting Results

### Success Output
```
✓ Fuzz tests completed successfully
```
All harnesses ran without finding failures within the time/execution limits.

### Failure Output
```
✗ Fuzz tests found failures
```
One or more harnesses found inputs that violate assertions. Check the output for details and the failure directory if specified.

## Troubleshooting

### Out of Memory
Reduce thread count:
```bash
./scripts/fuzz.sh --threads 1
```

### Tests Running Too Long
Use quick mode or reduce timeout:
```bash
./scripts/fuzz.sh --quick
# or
./scripts/fuzz.sh --timeout 10
```

### Finding Specific Failures
Use targeted harnesses with longer timeouts:
```bash
./scripts/fuzz.sh fuzz_find_mul_overflow --timeout 300 --threads 8
```

### Debugging Failures
When a failure is found:
1. Note the failing harness name
2. Check the failure directory if using `--failure-dir`
3. The fuzzer will show the failing input values
4. Add the failing case as a regression test

## Best Practices

1. **Start Quick**: Use `--quick` for development iterations
2. **Go Deep**: Use `--thorough` before commits
3. **Save Corpus**: Maintain a corpus directory for regression
4. **Target Specific**: Run specific harnesses when debugging
5. **Monitor Resources**: Adjust threads based on your system

## Advanced Usage

### Custom Configurations

Create project-specific configurations:

```bash
#!/bin/bash
# my-fuzz-config.sh

# Ultra-thorough configuration
FUZZ_TIMEOUT=600 \
FUZZ_THREADS=16 \
FUZZ_MAX_EXECUTIONS=1000000 \
./scripts/fuzz.sh
```

### Differential Testing

Compare implementations across versions:
```bash
# Test v1 properties
git checkout v1
./scripts/fuzz.sh --properties --corpus ./v1-corpus

# Test v2 with v1's corpus
git checkout v2
./scripts/fuzz.sh --properties --corpus ./v1-corpus
```

## Writing New Fuzz Tests

When adding fuzz tests:

1. Add to appropriate file:
   - `math_properties_fuzz.nr` for invariant testing
   - `math_overflow_fuzz.nr` for failure hunting

2. Use proper attributes:
   ```noir
   #[fuzz]                           // Basic fuzz test
   #[fuzz(should_fail)]              // Should find any failure
   #[fuzz(should_fail_with = "msg")] // Should find specific failure
   #[fuzz(only_fail_with = "msg")]   // Ignore other failures
   ```

3. Include helper functions for complex checks

4. Document the property being tested

5. Test your harness:
   ```bash
   ./scripts/fuzz.sh your_new_test --timeout 10
   ```

## Contributing

When submitting PRs with fuzz tests:
1. Run quick fuzz before commit: `npm run fuzz:quick`
2. Include corpus if finding interesting cases
3. Document any new harnesses in this file
4. Add failing cases as regression tests