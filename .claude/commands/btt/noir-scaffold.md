---
allowed-tools: Bash, Read, Write, MultiEdit, Glob
argument-hint: [--tree <tree-file>] [--output-dir <test-dir>]
description: Generate test file structure from tree specification
---

# Noir Test Scaffolder

Convert tree specification files into scaffolded Noir test files with proper structure.

## Arguments
- `--tree <tree-file>`: Input tree specification file (required)
- `--output-dir <test-dir>`: Output directory for tests (default: src/test/)

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Load and validate tree specification file
3. Create test directory structure
4. Generate test files with scaffolded functions
5. Create helper utilities and setup files

## Directory Structure

Generate organized test structure based on BTT branches:
```
src/test/
├── {contract_name}/
│   ├── {function_name}/
│   │   ├── when_{condition1}.nr  # Tests for specific scenarios
│   │   ├── when_{condition2}.nr
│   │   └── mod.nr
│   ├── utils.nr                  # Contract-specific setup functions
│   └── mod.nr
├── integration/
│   ├── {flow_name}_test.nr
│   └── mod.nr
├── fuzz/
│   ├── {contract_name}_properties.nr
│   └── mod.nr
├── utils.nr                      # Global test utilities
└── mod.nr
```

## Test Generation Rules

### From BTT Tree to Test Modules

Transform tree nodes into organized test modules with scenario-specific setups:
- **Root node** → Contract test directory
- **Function branches** → Function-specific subdirectory
- **When/Given branches** → Scenario setup functions and test modules
- **It branches** → Individual test functions

Example transformation:
```
Tree:
Voting::cast_vote
├── When vote has not ended
│   ├── When voter has not voted
│   │   └── It should record the vote
│   └── When voter has already voted
│       └── It should revert with "already exists"
└── When vote has ended
    └── It should revert with "Vote has ended"

Generated Structure:
src/test/voting/cast_vote/
├── when_vote_not_ended.nr
├── when_vote_ended.nr
└── mod.nr
```

### Test Organization Pattern

Each BTT condition branch becomes a module with:
1. **Setup function** specific to that scenario
2. **Test functions** for each "it" branch
3. **Shared context** for related tests

Naming conventions:
- Module files: `when_{condition}.nr` or `given_{condition}.nr`
- Setup functions: `setup_{scenario_description}()`
- Test functions: `test_{action_description}()`
- Revert tests: Add `#[test(should_fail_with = "error message")]`

## Scaffold Templates

### Scenario Module Template (when_{condition}.nr)
```noir
use dep::aztec::{
    test::helpers::test_environment::TestEnvironment,
    protocol_types::address::AztecAddress,
};
use crate::{ContractName, ContractNameInterface};
use crate::test::utils;

// Scenario-specific setup for: {condition_description}
unconstrained fn setup_{scenario}() -> (TestEnvironment, AztecAddress, /* scenario-specific returns */) {
    // Start with base setup
    let (mut env, contract_address, admin) = utils::setup();

    // Configure scenario-specific state
    // TODO: Set up the specific condition
    // e.g., mint tokens, create accounts, set permissions

    (env, contract_address, /* return scenario data */)
}

#[test]
fn test_{action_description}() {
    let (env, contract, /* scenario data */) = setup_{scenario}();

    // Execute the action
    // TODO: Perform the test action

    // Assert the expected outcome
    // TODO: Verify results
}

#[test(should_fail_with = "{expected_error}")]
fn test_revert_when_{condition}() {
    let (env, contract, /* scenario data */) = setup_{scenario}();

    // Execute the failing action
    // TODO: Perform action that should revert
}
```

### Fuzz Test Template (fuzz/{contract_name}_properties.nr)
```noir
use dep::aztec::test::helpers::test_environment::TestEnvironment;
use crate::test::utils;
use crate::{ContractName, ContractNameInterface};

#[test]
fn fuzz_{property_name}(input1: u32, input2: u32) {
    // Property: {invariant_description}
    let (mut env, contract_address, _) = utils::setup();

    // Bound inputs to valid ranges
    let bounded_input1 = input1 % MAX_VALUE;
    let bounded_input2 = input2 % MAX_VALUE;

    // Setup test state with fuzz inputs
    // TODO: Configure based on inputs

    // Execute operations
    // TODO: Perform operations with bounded inputs

    // Verify invariant holds
    assert(/* property check */, "Property violated: {description}");
}
```

### Integration Test Template (integration/{flow_name}_test.nr)
```noir
use dep::aztec::{
    test::helpers::test_environment::TestEnvironment,
    protocol_types::address::AztecAddress,
};
use crate::test::utils;

#[test]
unconstrained fn test_{flow_name}_complete_flow() {
    // Integration test: {flow_description}
    let (mut env, contract_address, admin) = utils::setup();

    // Create test actors
    let alice = env.create_light_account();
    let bob = env.create_light_account();

    // Step 1: {step_description}
    env.call_public(alice, ContractName::at(contract_address).{method1}(/* params */));

    // Verify intermediate state
    env.public_context_at(contract_address, |context| {
        // TODO: Check state after step 1
    });

    // Step 2: {step_description}
    env.call_private(bob, ContractName::at(contract_address).{method2}(/* params */));

    // Verify final state
    env.public_context_at(contract_address, |context| {
        // TODO: Assert final conditions
    });
}
```

## Helper Generation

Create utility files with real implementations:

### Global utils.nr
```noir
use dep::aztec::{
    protocol_types::address::AztecAddress,
    test::helpers::test_environment::TestEnvironment,
};
use crate::ContractName;

pub unconstrained fn setup() -> (TestEnvironment, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();
    let admin = env.create_light_account();

    let initializer = ContractName::interface().constructor(admin);
    let contract_address = env.deploy("ContractName")
        .with_public_initializer(admin, initializer);

    (env, contract_address, admin)
}

pub unconstrained fn create_accounts(
    env: &mut TestEnvironment,
    count: u32
) -> Vec<AztecAddress> {
    let mut accounts = Vec::new();
    for _ in 0..count {
        accounts.push(env.create_light_account());
    }
    accounts
}
```

### Contract-specific utils.nr
```noir
use super::utils;
use dep::aztec::protocol_types::storage::map::derive_storage_slot_in_map;

// Scenario: Setup with initial token distribution
pub unconstrained fn setup_with_balances(
    amounts: Vec<u32>
) -> (TestEnvironment, AztecAddress, Vec<AztecAddress>) {
    let (mut env, contract, admin) = utils::setup();
    let accounts = utils::create_accounts(&mut env, amounts.len());

    for i in 0..accounts.len() {
        env.call_public(admin,
            ContractName::at(contract).mint(accounts[i], amounts[i]));
    }

    (env, contract, accounts)
}

// Scenario: Setup with contract in specific state
pub unconstrained fn setup_in_paused_state() -> (TestEnvironment, AztecAddress, AztecAddress) {
    let (env, contract, admin) = utils::setup();
    env.call_public(admin, ContractName::at(contract).pause());
    (env, contract, admin)
}
```

## Implementation Steps

1. **Parse Tree File**
   - Load YAML/JSON tree specification
   - Validate structure and required fields
   - Extract test scenarios and invariants

2. **Generate Test Structure**
   - Create directory hierarchy
   - Generate mod.nr files for imports
   - Scaffold individual test files

3. **Create Test Functions**
   - Transform tree nodes to test functions
   - Add appropriate decorators
   - Include descriptive comments
   - Add TODO placeholders for implementation

4. **Generate Utilities**
   - Create setup helpers
   - Add common assertions
   - Include test data factories

5. **Report Summary**
   - List generated files
   - Count scaffolded tests
   - Highlight next steps