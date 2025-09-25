---
allowed-tools: Bash, Read, Write, MultiEdit, Glob, Grep
argument-hint: [--tests <test-dir>] [--tree <tree-file>] [--focus <pattern>]
description: Implement Noir test scaffolds with executable logic
---

# Noir Test Implementation Builder

Fill scaffolded Noir tests with executable logic using tree specifications and contract metadata.

## Arguments
- `--tests <test-dir>`: Directory containing scaffolded tests (default: tests/).
- `--tree <tree-file>`: Tree/spec file providing scenario guidance.
- `--focus <pattern>`: Optional glob or contract/function filter limiting implementation scope.

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Discover scaffold files containing generated placeholders or TODO markers.
3. Load tree spec to understand scenarios, invariants, and account roles.
4. Synthesize test bodies for happy paths, boundary conditions, negative cases, and fuzz properties.
5. Ensure helper utilities exist and update them with required fixtures.

## Implementation Guidelines
- Derive setup steps from state dependencies (initialize storage, mint tokens, configure roles).
- Choose assertion style (`assert_eq`, `assert`, `constrain`) based on expected outcomes.
- Generate event verification by reading test environment logs and matching against tree `events`.
- Use fuzz macros (`#[test]` with parameters) to encode invariants listed in the tree.

## Failure and Edge Handling
- Mark failure expectations with `#[test(should_fail_with = "...")]`.
- For revert scenarios, wrap calls with `assert_panics` helper when available.
- When invariants apply globally, include follow-up asserts after each state mutation.

## Idempotence and Preservation
- Only replace regions between generated markers; never overwrite custom code sections.
- Respect manual overrides indicated by `// manual:` tags by skipping generation.
- Emit a summary report noting files untouched due to custom implementations.

## Suggested Helpers
```noir
fn mint_and_transfer(env: &mut TestEnv, sender: Account, recipient: Account, amount: u64) {
    contract.mint(sender, amount);
    contract.transfer(sender, recipient, amount);
}
```

## Coverage Tracking
- Record implemented scenarios back into the tree (e.g. set `status: implemented`) when write access is permitted.
- Output a coverage snapshot listing remaining TODOs to guide future runs.
