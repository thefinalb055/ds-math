# Tasks: [FEATURE NAME]

**Input**: Plan artifacts from `/specs/[###-feature-name]/`  
Required files: `plan.md`, `contract.aztec-spec.yaml`, `flows.md`, `btt.seed.tree`, `test-plan.md`

## Execution Flow (main)
```
1. Load plan.md and referenced artifacts
   → If any required file missing: ERROR "Missing plan artifact {file}"
2. Parse contract.aztec-spec.yaml
   → Build dependency graph of contracts/functions (state reads, writes, calls)
   → Compute dependency weight per function (direct deps + invariants + flows)
3. Order contracts by ascending dependency weight
   → Within each contract, order functions topologically (least dependent first)
4. For each ordered function:
   a. Identify corresponding BTT branches (btt.seed.tree) and test scenarios (test-plan.md)
   b. Generate minimal failing test task(s) to unlock implementation
   c. Add implementation task scoped to code needed to pass those tests only
   d. Queue refactor/extension tests if additional behavior unlocked
5. Insert prerequisite setup tasks only when required by ordered tests (e.g., fixtures, utilities)
6. Annotate task dependencies and parallelism
   → Tests must precede implementation touching same function
   → Tasks touching same file remain serial (no [P])
7. Validate ordering satisfies minimal-code TDD constraint
   → If any implementation precedes its enabling tests: ERROR "TDD ordering violated"
8. Emit numbered task list with dependency notes
```

## Task Format
`[T###] [P?] Description (File Path)  — Dependencies: [...]`
- Include absolute workspace-relative file paths (e.g., `tests/unit/vault/test_deposit.nr`)
- `[P]` only when tasks touch disjoint files and have no dependency relationship
- Dependency list references preceding task IDs

---

## Dependency Analysis Rules
- **Function Graph**: Use `functions[].state_effects`, `functions[].roles_allowed`, and `flows[].stages` from the YAML to infer ordering. Functions with zero inbound edges highest priority.
- **Invariant Binding**: If a function enforces invariants referenced by others, treat as dependency target.
- **Privacy Transitions**: Private-to-public functions may require preceding private flows; ensure enabling functions are scheduled first.
- **Shared Utilities**: If multiple functions rely on the same helper/fixture, generate a single setup task before dependent tests.

---

## Task Categories & Ordering

1. **Environment Setup (only if required)**
   - Fixture or test harness updates necessary for first test batch.
2. **Test Seeds**
   - For each function (ordered by dependency weight):
     - Primary failing test from BTT branch (unit or integration) covering simplest happy path.
     - Additional edge/failure tests only after happy path implemented.
3. **Minimal Implementation**
   - Implement just enough contract or library logic to satisfy preceding tests.
   - Update shared utilities incrementally.
4. **Expansion Tests**
   - Introduce next BTT branches/invariants once previous implementation passes.
5. **Refinements & Cleanup**
   - Refactor duplicated code, finalize documentation, run coverage checks.

All tasks must explicitly state whether they produce or modify tests vs implementation.

---

## Example Ordering Snippet
```
[T001] Write test for happy-path deposit (tests/unit/vault/test_deposit.nr) — Dependencies: []
[T002] Implement minimal deposit logic (src/contracts/vault.nr) — Dependencies: [T001]
[T003] [P] Add helper to mint test notes (tests/utilities/notes.nr) — Dependencies: []
[T004] Write test for deposit failure on invalid proof (tests/unit/vault/test_deposit_invalid.nr) — Dependencies: [T002, T003]
[T005] Extend deposit logic to validate proof (src/contracts/vault.nr) — Dependencies: [T004]
```

---

## Parallelism Guidelines
- Only mark `[P]` when tasks involve different files and no dependency path.
- Parallel tests allowed across separate contracts/functions when their setups are independent.
- Implementation tasks modifying the same contract/file must remain serial.

---

## Validation Checklist
- [ ] Every implementation task has at least one preceding test task unlocking it.
- [ ] Contract ordering follows dependency graph (least dependent first).
- [ ] No task modifies same file as a parallel `[P]` task.
- [ ] Each task lists explicit dependencies and file paths.
- [ ] Coverage of all BTT branches confirmed in final tasks.
- [ ] Minimal-code principle satisfied (each implementation limited to tests in scope).

---

## Dependency Table (auto-generated)
Use this table in the task list to document ordering rationale.

| Contract/Function | Dependencies | Initial Test Task | Initial Implementation Task |
| --- | --- | --- | --- |
| Vault.deposit | [] | T001 | T002 |
| Vault.withdraw | [Vault.deposit] | T010 | T011 |
| ... | ... | ... | ... |

Populate rows based on parsed YAML and flows.

---

## Notes for Agents
- Re-run dependency analysis if YAML spec changes mid-plan.
- Keep task descriptions concise but explicit (state intent + file).
- Document clarifications inline if a dependency is assumed.
- Stop once minimal set of tasks cover all planned tests; defer optimizations to later phases.
