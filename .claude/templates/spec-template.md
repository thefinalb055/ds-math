# Feature Specification: [FEATURE NAME]

**Feature Branch**: `[###-feature-name]`  
**Created**: [DATE]  
**Status**: Draft  
**Input**: User description: "$ARGUMENTS"

## Execution Flow (main)
```
0. Entry Reflection
   → Summarize intent, unknowns, and proposed approach
   → Ask user to confirm priorities, data boundaries, and collaboration cadence
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract Aztec-specific concepts
   → Identify: user roles, privacy scope (private/public), note types, Noir entrypoints
3. Map protocol touchpoints and dependencies
   → Highlight: Aztec contracts, rollup services, bridges, external L1 interactions
4. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
5. Outline User Scenarios & Testing with private/public flows
   → If no clear user flow: ERROR "Cannot determine Aztec user journey"
6. Generate Functional Requirements
   → Each requirement must be testable and respect privacy boundaries
   → Mark ambiguous requirements
7. Identify Key Entities and data residency (private notes vs public state)
8. Capture Privacy & Security Considerations
9. Exit Reflection (pre-sign-off)
   → Summarize completed sections, open questions, next actions
   → Request explicit user approval before finalizing the phase
10. Return: SUCCESS (spec ready for planning once user approves)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on user value within Aztec's hybrid private/public execution model
- ✅ Describe expected Noir circuit outcomes without specifying code, opcodes, or selectors
- ❌ Avoid low-level implementation details (contract ABIs, circuit gates, gas estimates)
- 👥 Write for product + protocol stakeholders; assume familiarity with Aztec primitives

### Collaboration Cadence
- Always begin with the Entry Reflection to align on goals, assumptions, and decision rights.
- Record any user decisions directly in the relevant sections to preserve context for later phases.
- Do not advance to `/plan` or downstream artifacts until the user explicitly signs off during the Exit Reflection.

### Aztec/Noir Discovery Prompts
- Clarify which interactions must stay private vs which produce public outputs
- Identify required Noir modules, entrypoints, or composable components (e.g., note validators, oracle adapters)
- Document assumptions about data availability, rollup inclusion, and settlement timelines
- Confirm proof verification responsibilities (local client vs L1/L2 contract)
- Capture dependencies on wallets, SDK surfaces, or bridge infrastructure

---

## Entry Reflection *(mandatory before drafting)*
- Current understanding of the feature’s intent and target Aztec user types.
- Key uncertainties or decisions that require user input.
- Proposed approach for structuring the spec and any checkpoints.
- Explicit questions for user confirmation (privacy scope, assets, timelines, collaborators).

---

## User Scenarios & Testing *(mandatory once entry reflection approved)*

### Primary User Story
[Describe how an Aztec account holder completes the end-to-end flow. Mention private actions, expected public signals, and any Noir circuit invocations.]

### Acceptance Scenarios
1. **Given** an Aztec account controls a private [asset] note, **When** they invoke the Noir contract to [primary action], **Then** the rollup produces a new note commitment and emits the agreed public summary event.
2. **Given** a relayer submits the user's proof bundle, **When** validation succeeds, **Then** the system updates both private state (notes, nullifiers) and any linked public registry.

### Edge Cases
- What happens when a proof references a spent or stale note commitment?
- How does the feature respond if the rollup slot is missed or the settlement bridge reorgs?

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: Aztec account holders MUST be able to [shield/unshield/transfer] assets through the designated Noir entrypoint.
- **FR-002**: Noir circuit MUST verify [predicate] before accepting a proof (e.g., ownership, balance, membership).
- **FR-003**: System MUST surface the minimal public summary required (events, view functions) without leaking private state.
- **FR-004**: Feature MUST persist resulting notes/nullifiers in the Aztec data tree once the rollup finalizes.
- **FR-005**: System MUST communicate failure reasons when a proof, note sync, or bridge dependency cannot be satisfied.

*Example of marking unclear requirements:*
- **FR-006**: Noir circuit MUST enforce membership against [NEEDS CLARIFICATION: which note set or commitment tree?]
- **FR-007**: Feature MUST finalize on L1 within [NEEDS CLARIFICATION: number of rollup blocks / settlement window?]

### Key Entities *(include if feature involves data)*
- **Aztec Note Type**: [What the note represents, private fields, linkage to public metadata]
- **Noir Module / Contract**: [Purpose of the module, required inputs/outputs, integration points]
- **Public Registry / View**: [What observers can query, update cadence, retention expectations]

---

## Privacy & Security Considerations *(recommended)*
- Outline how the feature prevents leakage of note values, identities, or linkage attacks.
- Specify trust assumptions (e.g., relayers, bridge sequencers) and how failures are surfaced to users.
- Capture compliance or policy constraints (AML thresholds, regional availability, custody rules).

---

## Exit Reflection & Sign-off *(mandatory before closing phase)*
- Summarize what was drafted, including confirmed user decisions.
- Enumerate outstanding clarifications or risks that block `/plan`.
- Propose next steps, especially items that feed into the Aztec spec YAML (entities, flows, BTT seeds).
- Request explicit user sign-off: e.g., “✅ Ready to proceed to `/plan`?”

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [ ] No implementation details (languages, frameworks, bytecode specifics)
- [ ] Uses Aztec/Noir terminology consistently and correctly
- [ ] Focused on user value and protocol fit
- [ ] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and respect privacy boundaries
- [ ] Success criteria cover both private and public outcomes
- [ ] Scope is clearly bounded with dependencies noted

### Privacy & Security
- [ ] Privacy model documented (private vs public data surfaces)
- [ ] Proof validation and settlement responsibilities assigned
- [ ] Failure modes and observability defined

---

## Execution Status
*Updated by main() during processing*

- [ ] Entry reflection completed and approved
- [ ] User description parsed
- [ ] Key concepts extracted (roles, privacy scope, dependencies)
- [ ] Ambiguities marked
- [ ] User scenarios defined (private/public split)
- [ ] Requirements generated
- [ ] Entities identified
- [ ] Privacy & security constraints captured
- [ ] Exit reflection recorded and approved
- [ ] Review checklist passed

---

> ℹ️ Once the user signs off on this high-level spec, run `/plan` to generate the detailed Noir/Aztec contract workbook (YAML spec, flows, BTT seed, test planning). The Aztec spec YAML phase also requires Entry and Exit Reflections—confirm user alignment on data schemas, interaction flows, and testing seeds before writing artifacts. Pair this with the [Aztec contract meta-language reference](../docs/aztec-contract-meta-language.md) and Noir design patterns docs when breaking work into stories.
