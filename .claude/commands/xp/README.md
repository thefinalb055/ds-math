# Noir Test Command Suite

This directory contains Cloud Code commands that replicate the bulloak Solidity testing workflow for Noir smart contracts. Each command mirrors a stage in the Branching Tree Technique (BTT) pipeline—scan, spec, tree generation, scaffolding, implementation, and orchestration—so you can move from raw Noir source to a fully realized test suite.

## Commands

| Command | Purpose |
| --- | --- |
| `/noir-scan` | Discover Noir contracts and emit structured `.tree`/`.spec` data summarizing hierarchy, state, access patterns, and events. |
| `/noir-spec` | Merge manual specifications with scan data to enrich scenarios, coverage targets, and invariants. |
| `/noir-treegen` | Produce BTT `.tree` files (bulloak style) from structured specs and code analysis. |
| `/noir-scaffold` | Turn tree files into organized Noir test skeletons (unit/integration/fuzz) while preserving custom code. |
| `/noir-implement` | Fill scaffolds with executable Noir tests covering happy paths, failures, fuzz properties, and events. |
| `/noir-test-suite` | Orchestrate the full pipeline end-to-end, optionally prompting for interactive overrides. |

All command definitions live alongside this README as Markdown metadata consumed by the Codex CLI.

## Workflow

1. **Scan** — Run `/noir-scan --dir <contracts>` to analyze `.nr` files. The command extracts contract names, function signatures, state dependencies, invariants, access-control markers, and events, producing a structured `.spec` artifact.
2. **Spec Enhance** — Use `/noir-spec --input <spec> --contracts <dir>` to merge manual requirements with scan output. The tool attaches test types (unit/integration/fuzz/security/performance), edge cases, and coverage targets without overwriting custom notes.
3. **Tree Generation** — Call `/noir-treegen --input <spec> --output noir.tree` to render Branching Tree Technique files identical in style to bulloak’s `.tree` specs. Trees use `When`/`Given` for conditions and `It` for actions, supporting multiple function roots via `Contract::function` notation.
4. **Scaffold** — Execute `/noir-scaffold --tree noir.tree --output-dir tests` to create test skeletons. The scaffolder organizes files into `tests/unit`, `tests/integration`, `tests/fuzz`, and `tests/test_utils`, updating only marked regions so hand-written logic persists.
5. **Implement** — Run `/noir-implement --tests tests --tree noir.tree` to populate scaffolds with Noir test logic, including setup, assertions, failure expectations, fuzz harnesses, and event verification.
6. **Pipeline** — For a one-shot experience, `/noir-test-suite --dir <contracts> --output tests` chains all steps, managing artifacts in `.artifacts/` and summarizing coverage.

Rerun any command as contracts evolve—the suite is designed to be stateless and idempotent, integrating with incremental development workflows.

## Tree Format (BTT)

The Branching Tree Technique structures tests as hierarchical trees:

```tree
TokenContractTest
├── When sender has sufficient balance
│   └── It should transfer tokens.
└── When sender has insufficient balance
    └── It should revert with "InsufficientBalance".
```

Key rules (mirroring bulloak):
- One modifier per unique condition (`When`/`Given`). Reusing titles shares modifiers across the tree.
- Top-level `It ...` actions must be unique. Nested actions that collide are auto-disambiguated by prepending ancestor conditions (PascalCase) or numeric suffixes.
- Comments start with `//` and are preserved through rebuilds.
- Multiple functions share a file via `Contract::function` roots separated by blank lines.
- Box-drawing characters (`├`, `└`, `│`) are the canonical representation; ASCII fallback is available via `--format ascii`.

The resulting `.tree` files drive scaffolding and implementation, just as bulloak’s `scaffold` and `check` commands rely on `.tree` specs for Solidity.

## Attribution

This command suite is a Noir-centric reimagining of the [bulloak](https://github.com/alexfertel/bulloak) Solidity test generator by Alex Fertel. bulloak’s Branching Tree Technique, tree grammar, and scaffolding semantics directly inform the Noir equivalents provided here. Please refer to bulloak’s repository for the original implementation, additional examples, and the broader context around BTT.

## Contributing

Adjust command behavior by editing the corresponding Markdown files in this directory. Because commands are stateless, you can iterate safely: run scans, tweak specs, regenerate trees, and re-run scaffolding without losing manual refinements. When introducing new stages or options, document them here to keep the workflow accessible.
