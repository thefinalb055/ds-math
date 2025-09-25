---
allowed-tools: Bash, Read, Write, MultiEdit, Glob, Grep
argument-hint: [--dir <contract-dir>] [--output <test-dir>] [--interactive]
description: Run the full Noir contract testing pipeline end-to-end
---

# Noir Test Suite Orchestrator

Execute the end-to-end pipeline from contract scanning to implemented tests with optional interactivity.

## Arguments
- `--dir <contract-dir>`: Root directory containing Noir contracts.
- `--output <test-dir>`: Target directory for generated tests (default: tests/).
- `--interactive`: Enable prompts for customization at each stage.

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Run `/noir-scan` to produce or refresh the tree/spec artifact.
3. Invoke `/noir-spec` to enrich specs with scenarios and coverage goals.
4. Call `/noir-scaffold` to (re)generate test skeletons.
5. Execute `/noir-implement` to fill in concrete logic and summarize coverage.

## Pipeline Behavior
- Share context artifacts via a temp workspace (e.g. `.artifacts/noir.tree`) unless overridden.
- Provide hooks before each stage to allow skipping or custom command substitution.
- Collect logs from every stage and surface consolidated status at the end.

## Interactivity
- When `--interactive` is set, prompt for scan filters, spec merge strategy, scaffolding overrides, and implementation focus areas.
- Offer preview diffs before applying filesystem changes.
- Support `--yes`/`--no` responses for automation-friendly runs.

## Reporting
- Emit final summary including contracts processed, tests generated, and scenarios still pending.
- Generate optional coverage report skeleton (e.g. JSON with per-function status) to feed external dashboards.
- Persist run metadata (timestamp, git commit, settings) under `.artifacts/last-run.json`.

## Failure Recovery
- Stop on critical errors but keep partial artifacts for inspection.
- Provide rerun hints (e.g. `rerun with --focus transfer`) when downstream stages depend on missing data.
- Ensure reruns are idempotent by reusing caches and respecting existing customizations.
