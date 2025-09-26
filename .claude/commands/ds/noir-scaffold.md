---
allowed-tools: Bash, Read, Write, MultiEdit, Glob, Grep
argument-hint: [--tree <tree-file>] [--output-dir <test-dir>] [--dry-run]
description: Scaffold Noir test skeletons from tree specification
---

# Noir Test Scaffold Generator

Convert tree specifications into organized Noir test skeletons while preserving existing custom code.

## Arguments
- `--tree <tree-file>`: Path to enriched tree/spec file (YAML or JSON).
- `--output-dir <test-dir>`: Root directory for generated tests (default: tests/).
- `--dry-run`: Print planned changes without writing to disk.

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Load tree specification and validate required sections.
3. Plan filesystem layout (unit/integration/fuzz directories and shared utilities).
4. Generate or update test files with module headers, imports, setup scaffolds, and annotated placeholders.
5. Record scaffolding summary including skipped files (existing custom implementations) and next steps.

## File Layout
- `tests/unit/<contract>_<fn>_test.nr` for focused unit cases.
- `tests/integration/<contract>_flow_test.nr` for composed scenarios.
- `tests/fuzz/<contract>_properties_test.nr` for property-based suites.
- `tests/test_utils/{setup,helpers}.nr` for shared utilities.

## Scaffold Rules
- Only replace regions wrapped with markers (e.g. `// --- generated start/end ---`); leave custom code untouched.
- Insert `#[test]` annotations, function signatures mirroring contract APIs, TODO assertions, and doc comments referencing `tests_needed`.
- Generate helper stubs (environment builders, fixture factories) when declared in tree `utilities`.

## Idempotence
- In dry-run mode emit a diff-style plan listing files to be added, updated, or skipped.
- When files already exist, perform structured merge: update imports and placeholders, keep manual blocks intact.
- Sort imports and format code using Noir conventions to maintain consistent diffs.

## Error Handling
- If a contract in the tree lacks associated `.nr` source, emit a warning but continue with remaining items.
- Provide actionable messages for missing `tests_needed` or unsupported test type sections.
