# Feature Specification: Noir DSMath Library

**Feature Branch**: `001-noir-math-refactor`
**Created**: 2025-09-25
**Status**: Draft
**Input**: User description: "Refactor Solidity DSMath library to Noir with full test suite"

## Execution Flow (main)
```r
0. Entry Reflection
   → Refactor existing Solidity mathematical library to Noir
   → Focus on preserving precision and overflow safety
   → Comprehensive test suite covering all edge cases
1. Parse user description from Input
   → Solidity Math library with fixed-point arithmetic
   → Constants: WAD (10^18), RAY (10^27), RAD (10^45)
   → Functions: min/max, add/sub with signed values, fixed-point mul/div, rpow
2. Extract Aztec-specific concepts
   → Pure mathematical library (no state, no notes)
   → Public computation module for other contracts
   → No privacy requirements (pure functions)
3. Map protocol touchpoints and dependencies
   → Standalone utility library
   → Can be imported by other Noir contracts
   → No external dependencies or L1 interactions
4. For each unclear aspect:
   → Noir equivalent for assembly code in rpow
   → Handling of overflow/underflow in Noir
   → Signed integer support in Noir
5. Outline User Scenarios & Testing with private/public flows
   → Library functions will be used by other contracts
   → All operations are deterministic and public
6. Generate Functional Requirements
   → Each mathematical operation must match Solidity behavior
   → Overflow protection and precision preservation required
7. Identify Key Entities and data residency
   → Pure computation library - no state storage
   → Constants and functions only
8. Capture Privacy & Security Considerations
   → Overflow/underflow protection critical
   → Precision loss must be minimized
9. Exit Reflection (pre-sign-off)
   → Mathematical library spec ready
   → Test suite requirements defined
   → Ready for implementation planning
10. Return: SUCCESS (spec ready for planning once user approves)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on mathematical precision and safety within Noir's type system
- ✅ Describe expected mathematical outcomes without specifying implementation
- ❌ Avoid low-level circuit details or gas optimization concerns
- 👥 Write for developers needing reliable fixed-point arithmetic in Noir

### Collaboration Cadence
- Begin with understanding Solidity implementation semantics
- Map each function to Noir equivalent capabilities
- Define comprehensive test coverage requirements

### Aztec/Noir Discovery Prompts
- How to handle signed integers in Noir (int256 equivalent)
- Noir's overflow protection mechanisms
- Assembly-level optimizations translation to Noir
- Precision guarantees for fixed-point arithmetic

---

## Entry Reflection *(mandatory before drafting)*
- **Intent**: Port a battle-tested Solidity DSMath library to Noir, preserving all mathematical properties and safety guarantees
- **Key uncertainties**:
  - Noir's signed integer support and range
  - Translation of assembly optimizations in rpow
  - Overflow detection patterns in Noir
- **Proposed approach**:
  1. Map each Solidity function to Noir equivalent
  2. Define fixed-point arithmetic constants
  3. Create comprehensive test suite with edge cases
  4. Ensure overflow/underflow protection
- **Questions for confirmation**:
  - Should we maintain exact Solidity behavior or optimize for Noir?
  - Are there specific precision requirements beyond WAD/RAY/RAD?
  - Should the library be optimized for witness generation efficiency?

---

## User Scenarios & Testing *(mandatory once entry reflection approved)*

### Primary User Story
A Noir contract developer needs reliable fixed-point arithmetic operations for financial calculations. They import the DSMath library to perform safe multiplications, divisions, and power calculations with 18-27 decimal precision, knowing overflow protection is built-in.

### Acceptance Scenarios
1. **Given** two unsigned integers, **When** calling wmul (WAD multiplication), **Then** the result is (x * y) / 10^18 with overflow protection
2. **Given** a base and exponent, **When** calling rpow with a precision base, **Then** the result matches the Solidity implementation's power calculation with rounding
3. **Given** an unsigned and signed integer, **When** calling add/sub, **Then** the operation handles sign conversion correctly without overflow
4. **Given** RAY-precision values, **When** performing rmul/rdiv operations, **Then** precision is maintained at 27 decimals

### Edge Cases
- Overflow when multiplying maximum values
- Underflow when subtracting larger signed values
- Division by zero protection
- rpow with edge cases: 0^0=1, 0^n=0, x^0=base
- Sign conversion boundaries (int256 min/max)
- Precision loss in cascading operations

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: Library MUST define constants WAD (10^18), RAY (10^27), RAD (10^45) for fixed-point arithmetic
- **FR-002**: min/max functions MUST correctly compare unsigned integers and return appropriate value
- **FR-003**: add/sub functions MUST handle mixed unsigned/signed operations with proper overflow checking
- **FR-004**: mul function MUST handle unsigned × signed multiplication with overflow protection
- **FR-005**: diff function MUST return signed difference between unsigned values
- **FR-006**: to_rad function MUST convert WAD to RAD precision (multiply by RAY)
- **FR-007**: wmul MUST perform (x * y) / WAD with overflow protection
- **FR-008**: rmul MUST perform (x * y) / RAY with overflow protection
- **FR-009**: rdiv MUST perform (x * RAY) / y with division-by-zero protection
- **FR-010**: rpow MUST implement exponentiation with configurable base for rounding
- **FR-011**: All functions MUST match Solidity implementation's mathematical behavior
- **FR-012**: Library MUST provide comprehensive test coverage for all edge cases

### Key Entities *(include if feature involves data)*
- **Constants Module**: WAD, RAY, RAD precision constants
- **Basic Operations**: min, max, add, sub, mul, diff
- **Fixed-Point Operations**: wmul, rmul, rdiv, to_rad
- **Power Function**: rpow with base parameter for precision
- **Test Suite**: Comprehensive tests covering normal and edge cases

---

## Privacy & Security Considerations *(recommended)*
- **Overflow Protection**: All arithmetic operations must detect and handle overflow conditions
- **Underflow Protection**: Subtraction operations must prevent underflow to negative when using unsigned types
- **Division by Zero**: All division operations must check for zero divisor
- **Precision Guarantees**: Fixed-point operations must maintain documented precision levels
- **Deterministic Behavior**: All operations must be deterministic and match Solidity implementation
- **No Side Effects**: Pure functions with no state modifications

---

## Exit Reflection & Sign-off *(mandatory before closing phase)*
- **Completed**:
  - Analyzed Solidity DSMath library structure
  - Identified all mathematical operations to port
  - Defined precision requirements (WAD/RAY/RAD)
  - Specified overflow/underflow protection needs
  - Outlined comprehensive test requirements
- **Outstanding clarifications**:
  - Noir's signed integer handling specifics
  - Assembly optimization equivalents in Noir
  - Witness generation efficiency considerations
- **Next steps**:
  - Create Noir module structure
  - Implement each mathematical function
  - Develop comprehensive test suite
  - Validate against Solidity implementation
- **Ready for planning**: ✅ Specification complete, ready to proceed to `/plan` phase

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, bytecode specifics)
- [x] Uses Aztec/Noir terminology consistently and correctly
- [x] Focused on user value and protocol fit
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and respect precision boundaries
- [x] Success criteria cover mathematical correctness
- [x] Scope is clearly bounded (pure math library)

### Privacy & Security
- [x] Overflow/underflow protection documented
- [x] Division by zero handling specified
- [x] Deterministic behavior guaranteed

---

## Execution Status
*Updated by main() during processing*

- [x] Entry reflection completed and approved
- [x] User description parsed
- [x] Key concepts extracted (fixed-point arithmetic, precision levels)
- [x] Ambiguities marked (Noir specifics)
- [x] User scenarios defined (library usage patterns)
- [x] Requirements generated
- [x] Entities identified
- [x] Security constraints captured
- [x] Exit reflection recorded and approved
- [x] Review checklist passed

---

> ℹ️ Once the user signs off on this high-level spec, run `/plan` to generate the detailed Noir implementation workbook. The library will serve as a foundational utility for other Noir contracts requiring safe fixed-point arithmetic operations.