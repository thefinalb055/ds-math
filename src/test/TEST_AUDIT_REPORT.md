# Test Style Guidelines Audit Report

## Summary
**Compliance Score: 65%**

While we have made progress with `math_add_test.nr` and `math_mul_test.nr` following the guidelines well, several test files still need refactoring to meet the standards defined in CLAUDE.md.

## ✅ Files Following Guidelines

### 1. `math_add_test.nr` - **95% Compliant**
- ✅ Has BTT tree specification at top
- ✅ Uses helper functions module pattern
- ✅ Each test has Branch documentation
- ✅ Tests organized by tree structure with section headers
- ✅ Uses fixtures from utils (max_u128, i64_min_abs)
- ✅ Clear helper function naming (setup_positive_overflow, etc.)

### 2. `math_mul_test.nr` - **95% Compliant**
- ✅ Has BTT tree specification at top
- ✅ Uses helper functions module pattern
- ✅ Each test has Branch documentation
- ✅ Tests organized by tree structure
- ✅ Clear helper function naming
- ⚠️ Minor: Some helpers still use inline I64_MAX instead of fixtures

## ❌ Files Violating Guidelines

### 1. `math_sub_test.nr` - **30% Compliant**
**Violations:**
- ❌ Missing BTT tree specification at top
- ❌ No helper functions module
- ❌ No Branch documentation in tests
- ❌ Inline hex constants: `0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
- ❌ Magic numbers: `12345`, `10000000000000000000`
- ❌ No test grouping with section headers

**Required Changes:**
```noir
// Add BTT tree spec at top
// Create helpers module
// Replace 0xFFFF... with max_u128()
// Add Branch comments to each test
```

### 2. `math_precision_test.nr` - **40% Compliant**
**Violations:**
- ❌ Missing BTT tree specification
- ❌ No helper functions for test scenarios
- ❌ Inline hex constant: `0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
- ❌ Magic numbers throughout: `1500000000000000000`, `1333333333333333333`
- ❌ No Branch documentation
- ⚠️ Tests grouped by function but no section headers

**Required Changes:**
```noir
// Add BTT tree for wmul, wdiv, rmul, rdiv
// Create helpers for precision test scenarios
// Use fixtures for max values
// Add Branch documentation
```

### 3. `math_minmax_test.nr` - **25% Compliant**
**Violations:**
- ❌ Missing BTT tree specification
- ❌ No helper functions (just inline values)
- ❌ No Branch documentation
- ❌ Direct values instead of helpers

**Required Changes:**
```noir
// Add BTT tree for min/max/diff
// Create setup helpers
// Add Branch documentation
```

### 4. `math_rpow_test.nr` - **20% Compliant**
**Violations:**
- ❌ Missing BTT tree specification
- ❌ No helper functions
- ❌ No Branch documentation
- ❌ Magic numbers: `1100000000000000000000000000`
- ❌ No test organization

### 5. `math_invariants_test.nr` (fuzz) - **35% Compliant**
**Violations:**
- ❌ Inline hex constant: `0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF`
- ❌ Should use max_u128() fixture
- ❌ Missing BTT tree (though fuzz tests are different)
- ⚠️ Has some helper functions but not consistently used

### 6. `math_flows_test.nr` (integration) - **50% Compliant**
**Violations:**
- ❌ Missing BTT tree specification
- ❌ Magic numbers throughout
- ⚠️ Has helper usage but inconsistent

## 📊 Violation Statistics

| Violation Type | Count | Files Affected |
|---|---|---|
| Missing BTT Tree Spec | 5 | sub, precision, minmax, rpow, flows |
| No Helper Functions | 4 | sub, precision, minmax, rpow |
| Inline Hex Constants | 5 | sub(2), precision(1), invariants(2) |
| No Branch Documentation | 5 | sub, precision, minmax, rpow, flows |
| Magic Numbers | 20+ | Most files |
| No Section Headers | 4 | sub, minmax, rpow, flows |

## 🔧 Priority Fixes

### High Priority (Security/Clarity)
1. Replace all `0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF` with `max_u128()`
2. Add BTT tree specifications to all test files

### Medium Priority (Maintainability)
3. Create helper functions for all test scenarios
4. Add Branch documentation to each test

### Low Priority (Organization)
5. Add section headers for test grouping
6. Replace magic numbers with named constants or helpers

## 📝 Action Items

1. **Refactor `math_sub_test.nr`** - Highest priority as it's a core function
   - Add BTT tree
   - Create helpers module
   - Fix inline constants

2. **Update `math_precision_test.nr`** - Important for precision operations
   - Add BTT trees for each precision function
   - Create helpers for precision scenarios
   - Remove magic numbers

3. **Fix inline hex constants globally**
   - Run: `sed -i 's/0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF/max_u128()/g'`

4. **Add BTT trees to remaining files**
   - Generate from existing `.tree` file
   - Convert to ASCII format

## ✅ Good Examples to Follow

From `math_add_test.nr`:
```noir
// BTT tree at top
// Helper module with clear names
mod helpers {
    pub fn setup_positive_overflow() -> (u128, i64) {
        (max_u128(), 1)
    }
}

// Test with branch documentation
#[test]
fn test_add_positive_overflow() {
    // Branch: Math::add -> When y is positive -> When x + y would overflow -> It should revert
    let (x, y) = helpers::setup_positive_overflow();
    let _result = add(x, y);
}
```

## 🚫 Anti-Patterns Found

1. **Direct hex values**: `let x: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;`
2. **Magic numbers**: `let x: u128 = 12345;`
3. **No branch context**: Tests without explaining which BTT branch they test
4. **Inline setup**: Test setup directly in test body instead of helpers

## Recommendation

We should prioritize fixing `math_sub_test.nr` and `math_precision_test.nr` first as they test core implemented functions. The pattern established in `math_add_test.nr` should be the template for all refactoring.