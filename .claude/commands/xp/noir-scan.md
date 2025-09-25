---
allowed-tools: Bash, Read, Write, MultiEdit, Glob, Grep
argument-hint: [--dir <path>] [--output <filename>]
description: Analyze Noir contracts and emit specification tree
---

# Noir Contract Scanner

Perform a structural scan over Noir sources and emit a tree/spec file summarizing discoverable contract data.

## Arguments
- `--dir <path>`: Root directory to scan (default: current workspace).
- `--output <filename>`: Path for generated tree or spec file (default: stdout).

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Resolve scan root and collect `.nr` files recursively.
3. Extract contracts, modules, functions, visibility, state variables, events, and doc comments.
4. Detect invariants, constraints, and access control cues from function annotations and naming.
5. Derive dependency graph (state <-> function <-> events) and write `.tree`/`.spec` output.

## Analysis Heuristics
- Treat files containing `contract` or `mod` definitions as entry points; follow `use` statements to map modules.
- Map functions by recording signature, visibility, parameter metadata, return type, and mutability markers (`mut`/`self` usage).
- Detect state references by locating `self.` or storage collections and track read/write orientation.
- Infer invariants by capturing assertions (`constrain`, `assert`, `assert_eq`) and doc tags like `@invariant`.
- Record access control via decorators (e.g. `#[only_owner]`) and guard clauses referencing roles.

## Output Schema
Emit YAML or JSON with the following top-level shape:

```yaml
contracts:
  - name: <ContractName>
    path: <relative/path.nr>
    state_variables:
      - name: balances
        type: Map<felt, felt>
        visibility: private
    functions:
      - name: transfer
        visibility: public
        parameters:
          - name: sender
            type: felt
        returns: bool
        mutates_state: true
        reads_state: ["balances"]
        emits: ["Transfer"]
        invariants: ["balances[sender] >= amount"]
    events:
      - name: Transfer
        fields: [from, to, amount]
    access_control:
      - guard: only_owner
        applies_to: ["mint"]
```

## Error Handling & Idempotence
- If no contracts are found, return a descriptive warning and produce an empty tree skeleton.
- Preserve existing output by merging when `--output` already exists; update discovered sections while keeping custom metadata.
- Normalize paths and sort collections for deterministic diffs.
