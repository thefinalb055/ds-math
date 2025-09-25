<!-- Sync Impact Report
Version change: 0.0.0 → 1.0.0
Modified principles: N/A (initial constitution)
Added sections: All sections (initial creation)
Removed sections: N/A
Templates requiring updates:
✅ spec-template.md - References to constitution added
✅ plan-template.md - References to constitution added
✅ tasks-template.md - References to constitution added
Follow-up TODOs: None
-->

# Noir/Aztec Smart Contract Development Constitution

## Core Principles

### I. Contract-Focused Scope
Every feature development session MUST focus on a single contract or tightly coupled contract group. Features spanning multiple independent contracts require separate development sessions. This constraint ensures manageable complexity, testable boundaries, and clear ownership.

### II. Test-Driven Development (NON-NEGOTIABLE)
TDD is mandatory for all contract development. The cycle MUST follow: Write failing tests → Get user approval → Tests fail → Implement minimal code to pass → Refactor. No implementation code shall be written before its corresponding test exists and fails. This applies to both unit tests and integration tests.

### III. Privacy-First Architecture
All state transitions MUST explicitly consider privacy implications. Private state uses note-based UTXO model. Public-private interactions require careful orchestration through enqueuing. Every function MUST declare its privacy domain (#[private], #[public]) and document cross-domain validation requirements.

### IV. Collaborative Development
The AI agent translates user intent into structured workflows but the user drives all decisions. Every significant design choice requires user confirmation. The agent MUST present options, explain trade-offs, and wait for user direction before proceeding. No autonomous architectural decisions.

### V. Branching Tree Testing (BTT)
All test planning follows BTT methodology. Start with contract entry points as roots, branch on critical conditions, document each path with clear intent. Test scaffolds generate from BTT seeds. Coverage targets derive from BTT branches. This ensures systematic, traceable test coverage.

### VI. Zero-Knowledge Proof Awareness
Code MUST respect ZK circuit constraints. Optimize for constraint count over traditional performance metrics. Document circuit complexity implications. Use Noir's type system to enforce provable properties. Test both correctness and constraint efficiency.

### VII. Incremental Complexity
Start with simplest viable implementation. Add complexity only when tests demand it. Each feature increment must be independently testable. Avoid premature optimization or abstraction. Let requirements drive architecture evolution.

## Technical Standards

### Noir Language Requirements
- Use latest stable Noir version unless specified otherwise
- Leverage Noir standard library before custom implementations
- Follow Rust-like module organization patterns
- Document constraint implications in comments
- Prefer explicit types over inference for clarity

### Aztec Framework Standards
- Use #[aztec] macro for all contracts
- Implement proper storage patterns with #[storage]
- Follow note lifecycle best practices
- Use appropriate function decorators (#[public], #[private], #[initializer])
- Generate TypeScript bindings for all public interfaces

### Testing Infrastructure
- Unit tests in tests/unit/ using Noir test framework
- Integration tests in tests/integration/ using Aztec sandbox
- Fuzz tests for critical invariants
- BTT-derived test organization
- Minimum 80% code coverage target

## Development Workflow

### Phase 0: Discovery
- Research Aztec/Noir patterns for feature requirements
- Identify privacy model implications
- Document technical constraints
- Resolve all clarifications before modeling

### Phase 1: Specification
- Create high-level feature specification
- Mark all ambiguities with [NEEDS CLARIFICATION]
- Define acceptance criteria
- Get user approval before proceeding

### Phase 2: Contract Modeling
- Generate YAML IR using Aztec meta-language
- Map privacy-aware flows
- Create BTT seed from specifications
- Design test coverage plan

### Phase 3: Test-First Implementation
- Generate test scaffolds from BTT
- Write failing tests for simplest case
- Implement minimal passing code
- Iterate through BTT branches

### Phase 4: Validation
- Run all tests in sandbox environment
- Verify constraint counts
- Check privacy guarantees
- Document deployment requirements

## Governance

### Constitution Authority
This constitution supersedes all other development practices. Any deviation requires explicit documentation and user approval. All design decisions must reference applicable principles.

### Amendment Process
1. Proposed changes require clear rationale
2. User must approve all amendments
3. Version bump follows semantic versioning
4. Update all dependent templates

### Compliance Review
- Every PR must verify constitutional compliance
- Complexity additions require justification
- Test-first discipline is auditable via commit history
- Privacy violations block deployment

### Review Gates
- No implementation without failing test
- No merge without passing tests
- No deployment without privacy review
- No feature without user approval

**Version**: 1.0.0 | **Ratified**: 2025-09-25 | **Last Amended**: 2025-09-25