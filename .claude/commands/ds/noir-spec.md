---
allowed-tools: Bash, Read, Write, MultiEdit, Glob, Grep
argument-hint: [--input <spec-file>] [--contracts <dir>] [--output <tree-file>]
description: Merge manual specs with scan data and emit enhanced tree
---

# Noir Specification Enhancer

Transform manual requirements and scan data into a rich test tree describing coverage and scenarios.

## Arguments
- `--input <spec-file>`: Optional YAML/JSON spec authored by the user.
- `--contracts <dir>`: Directory containing Noir sources or previously generated scan output.
- `--output <tree-file>`: Destination for merged tree (default: stdout).

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Load existing tree/spec artifacts from `--input` or run an inline scan when only `--contracts` is provided.
3. Normalize schema (convert JSON <-> YAML) and validate required nodes.
4. Enrich each contract with test categories, scenario outlines, edge cases, invariants, and security/performance requirements.
5. Persist the enhanced tree, preserving manual notes and ordering.

## Merge Strategy
- Deep-merge on contract `name` keys; add new functions without deleting user-authored sections.
- Preserve `tests_needed` arrays while appending new scenarios (e.g. `reentrancy`, `overflow`).
- Support `x-custom` namespaces that are left untouched during regeneration.
- When conflicts arise, annotate with `conflict: manual_override` and surface the diff summary.

## Scenario Templates
For each function, synthesize the following baseline categories unless already specified:
- `unit`: deterministic success/failure coverage (happy path, boundary values).
- `integration`: cross-contract or multi-call flows.
- `fuzz`: property-based invariants using value generators.
- `security`: access control, reentrancy, and invariant checks.
- `performance`: gas/constraint weight targets when hints exist.

## Output Guarantees
- Sorted and stable output ordering (contracts, functions, tests) for idempotent reruns.
- Rich metadata describing coverage status, owner notes, and dependencies between tests and state.
- Optionally emit a summary section with coverage tallies when `--output` points to stdout.

## Validation
- Validate against schema; if issues arise, print actionable errors referencing offending path (e.g. `contracts[0].functions[2].tests_needed`).
- Highlight missing invariants or unsupported types and guide the user to add manual annotations.
