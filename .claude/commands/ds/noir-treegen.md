---
allowed-tools: Bash, Read, Write, MultiEdit, Glob, Grep
argument-hint: [--input <spec-file>] [--contracts <dir>] [--output <tree-file>] [--format <tree|ascii>]
description: Produce Branching Tree Technique specs for Noir contracts
---

# Noir Tree Generator

Generate Branching Tree Technique (BTT) `.tree` files that describe Noir contract behavior, inspired by the bulloak Solidity workflow.

## Arguments
- `--input <spec-file>`: Optional YAML/JSON spec containing structured scenarios.
- `--contracts <dir>`: Directory of Noir sources to analyze when building the tree from code.
- `--output <tree-file>`: Destination `.tree`; default prints to stdout.
- `--format <tree|ascii>`: Emit canonical BTT (`tree`) or bulloak-style ASCII guide (`ascii`).

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Load manual spec (`--input`) and normalize schema (YAML/JSON → internal model).
3. If `--contracts` provided, scan Noir `.nr` files to infer functions, visibility, and state dependencies.
4. Merge manual and inferred data to build a hierarchical scenario tree per contract function.
5. Emit `.tree` content honoring BTT grammar, ordering, and naming constraints.
6. When writing to disk, preserve existing custom branches by round-tripping and merging.

## BTT Primer (bulloak reference)
- **Root** maps to the test contract/class (e.g. `TokenContractTest`).
- **Condition nodes** start with `When`/`Given` and translate to modifiers.
- **Action nodes** start with `It` and translate to tests.
- **Action descriptions** nest under actions for rationale/comments.
- Multiple function trees share a contract by using `Contract::function` roots, as in bulloak's `Utils::hashPair` examples.

## Example Trees

Single function (mirrors bulloak README):
```tree
TokenContractTest
├── When sender has sufficient balance
│   └── It should transfer tokens
└── When sender has insufficient balance
    └── It should revert with "InsufficientBalance"
```

Multiple functions in one file (bulloak pattern, adapted to Noir):
```tree
Vault::deposit
├── It should increase the depositor balance.
└── When amount exceeds limit
    └── It should revert with "DepositLimitExceeded".

Vault::withdraw
├── It should decrease the depositor balance.
├── When caller is not owner
│   └── It should revert with "Unauthorized".
└── When vault is paused
    └── It should revert with "Paused".
```

Deep nesting with reused conditions:
```tree
Rollup::submitBlock
├── When proof is valid
│   ├── It should append the block.
│   └── When fee is non-zero
│       └── It should emit a FeePaid event.
└── When proof is invalid
    └── It should revert with "InvalidProof".
```

## Tree Construction Rules
- **One modifier per unique condition**: reuse identical `When condition` nodes across the file, matching bulloak semantics.
- **Unique top-level actions**: ensure top-level `It ...` nodes do not collide; append clarifying phrases when deduplicating.
- **Automatic disambiguation**: For nested action collisions, prepend nearest ancestor condition titles (PascalCase) and fallback to numeric suffixes.
- **Comments**: Prefix lines with `//` to embed rationale copied from spec or docstrings.
- **Unicode characters**: Use box-drawing (`├`, `└`, `│`) for canonical trees; switch to ASCII (`|--`) when `--format ascii` is requested.
- **Whitespace**: Separate multiple root trees with exactly one blank line.

## Spec Mapping
- **State dependencies** → convert to `When` branches (e.g. balances, ownership).
- **Invariant list** → map to top-level `It` actions that assert properties such as "It should conserve total supply.".
- **Events** → add action descriptions referencing emission expectations.
- **Access control** → produce branches like `When caller is not admin` leading to revert actions.
- **Performance hints** → optional `When gas exceeds target` branches for benchmarking scaffolds.

## Merge & Diff Strategy
- Parse existing tree when `--output` already exists and merge child nodes by title.
- Preserve manual comments and ordering; append newly discovered scenarios at the end of their parent.
- Emit change summary listing added/modified branches to mirror bulloak's check scaffolding UX.

## Validation & Errors
- Detect malformed indentation (missing `├/└`) similar to bulloak compiler errors; report path and line.
- Warn when a Noir function inferred from code lacks a matching tree branch.
- Validate that root contract names align with Noir file/module names.
- When required metadata is missing, suggest running `/noir-scan` or updating the manual spec.

## Next Steps
- Generated `.tree` files feed `/noir-scaffold` to create test skeletons.
- Re-run `/noir-treegen` after code changes to refresh branches while preserving manual adjustments.
- Use the upcoming README for guidance and attribution back to the bulloak project.
