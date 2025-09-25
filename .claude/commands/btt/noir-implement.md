---
allowed-tools: Bash, Read, Write, MultiEdit, Glob, Grep
argument-hint: [--tests <test-dir>] [--tree <tree-file>]
description: Fill scaffolded tests with implementation logic
---

# Noir Test Implementation Generator

Implement scaffolded test functions with actual test logic based on tree specifications.

## Arguments
- `--tests <test-dir>`: Directory containing scaffolded tests (default: src/test/)
- `--tree <tree-file>`: Tree specification file for context (optional)

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Locate scaffolded test files with TODO placeholders
3. Load tree specification for implementation details
4. Generate test implementations based on function signatures
5. Add assertions, setup, and verification logic

## Implementation Patterns

### Happy Path Tests
```noir
#[test]
fn test_transfer_success() {
    let mut env = TestEnvironment::new();
    let sender = env.create_account();
    let recipient = env.create_account();

    // Setup initial state
    let initial_balance = 1000;
    contract.mint(sender, initial_balance);

    // Execute transfer
    let transfer_amount = 100;
    let result = contract.transfer(sender, recipient, transfer_amount);

    // Verify balances
    assert_eq(contract.balance_of(sender), initial_balance - transfer_amount);
    assert_eq(contract.balance_of(recipient), transfer_amount);
    assert(result == true);
}
```

### Edge Case Tests
```noir
#[test(should_fail_with = "insufficient balance")]
fn test_transfer_insufficient_balance() {
    let mut env = TestEnvironment::new();
    let sender = env.create_account();
    let recipient = env.create_account();

    // Setup: sender has less than transfer amount
    contract.mint(sender, 50);

    // Attempt transfer of 100 (should fail)
    contract.transfer(sender, recipient, 100);
}
```

### Fuzz Tests
```noir
#[test]
fn fuzz_transfer_preserves_total_supply(
    sender_balance: u64,
    transfer_amount: u64
) {
    // Bound inputs to valid ranges
    let sender_balance = sender_balance % 10000;
    let transfer_amount = transfer_amount % sender_balance.max(1);

    let mut env = TestEnvironment::new();
    let sender = env.create_account();
    let recipient = env.create_account();

    // Setup
    contract.mint(sender, sender_balance);
    let initial_supply = contract.total_supply();

    // Transfer
    if transfer_amount <= sender_balance {
        contract.transfer(sender, recipient, transfer_amount);

        // Invariant: total supply unchanged
        assert_eq(contract.total_supply(), initial_supply);

        // Invariant: sum of balances preserved
        let sum = contract.balance_of(sender) + contract.balance_of(recipient);
        assert_eq(sum, sender_balance);
    }
}
```

### State Transition Tests
```noir
#[test]
fn test_state_machine_transitions() {
    let mut env = TestEnvironment::new();

    // State 1: Uninitialized
    assert_eq(contract.state(), State::Uninitialized);

    // Transition to State 2: Active
    contract.initialize(admin);
    assert_eq(contract.state(), State::Active);

    // Transition to State 3: Paused
    contract.pause();
    assert_eq(contract.state(), State::Paused);

    // Verify paused behavior
    let result = contract.try_transfer(sender, recipient, 100);
    assert(result.is_err());
}
```

## Test Data Generation

### Account Setup
```noir
fn create_test_accounts(env: &mut TestEnvironment, count: u32) -> Vec<Account> {
    let mut accounts = Vec::new();
    for i in 0..count {
        let account = env.create_account();
        accounts.push(account);
    }
    accounts
}
```

### Parameter Generation
```noir
fn generate_test_amounts() -> Vec<u64> {
    vec![
        0,              // Zero case
        1,              // Minimum
        100,            // Normal
        u64::MAX - 1,   // Near maximum
        u64::MAX,       // Maximum
    ]
}
```

## Assertion Patterns

### Value Assertions
- `assert_eq(actual, expected)` - Exact equality
- `assert(condition)` - Boolean conditions
- `assert_ne(a, b)` - Inequality

### Error Assertions
- `#[test(should_fail)]` - Expect any failure
- `#[test(should_fail_with = "message")]` - Specific error

### Event Assertions
```noir
// Check event emission
let events = env.get_events();
assert_eq(events.len(), 1);
assert_eq(events[0].name, "Transfer");
assert_eq(events[0].args.from, sender);
```

## Implementation Strategy

1. **Analyze Function Signature**
   - Identify parameters and return types
   - Determine setup requirements
   - Plan assertion strategy

2. **Generate Setup Code**
   - Initialize test environment
   - Create necessary accounts
   - Set initial state

3. **Implement Test Logic**
   - Call function under test
   - Handle return values
   - Check side effects

4. **Add Assertions**
   - Verify return values
   - Check state changes
   - Validate events

5. **Handle Special Cases**
   - Revert scenarios
   - Edge cases
   - Boundary conditions

## Coverage Considerations

Ensure implementations cover:
- All function parameters
- Each conditional branch
- Error conditions
- State transitions
- Event emissions
- Return value variations

Track and report coverage metrics for implemented tests.