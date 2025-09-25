# Aztec/Noir Contract Specification Meta-Language

This document defines the YAML schema used as the intermediate representation (IR) for Aztec/Noir contracts. The schema enables humans and agents to collaborate on contract design before any code or tests are generated. Downstream tooling (tree generation, scaffolding, implementation) consumes this YAML to derive Branching Tree Technique (BTT) specs and Noir test suites.

- **File type**: YAML (`.aztec-spec.yaml` recommended)
- **Audience**: Product engineers, protocol designers, automation agents
- **Goals**:
  - Capture behavioral intent, invariants, and privacy guarantees
  - Describe state, roles, and flows without specifying implementation
  - Serve as the single source of truth for later transformations (BTT, tests, docs)

## Top-Level Structure

```yaml
version: 0.1
metadata: { ... }
contract: { ... }
documentation: { ... }
roles: [ ... ]
state: { ... }
notes: [ ... ]
events: [ ... ]
functions: [ ... ]
flows: [ ... ]
invariants: [ ... ]
external: { ... }
sequence_diagrams: [ ... ]
btt_seed: { ... }
annotations: { ... }
```

All sections are optional unless marked **required**. Remove unused sections to keep specs concise.

### `version` *(required)*
Semantic version of the schema. Current value: `0.1`.

### `metadata`
General information about the spec itself.

| Field | Type | Description |
| --- | --- | --- |
| `id` | string | Unique identifier for the spec (slug or UUID). |
| `created` | date | ISO-8601 creation timestamp. |
| `updated` | date | Last update timestamp. |
| `owners` | list<string> | Stakeholders responsible for the spec. |
| `source` | string | Freeform notes on prompt, ticket, or conversation source. |

### `contract` *(required)*
Describes the contract or library being specified.

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | Contract or library name. |
| `type` | enum | `contract`, `library`, `module`, `component`. |
| `path` | string | Expected Noir source path (e.g. `src/contracts/vault.nr`). |
| `aztec_kind` | enum | `public_contract`, `private_contract`, `hybrid`, `kernel_module`. |
| `description` | string | High-level summary of responsibilities. |
| `status` | enum | `draft`, `in_discovery`, `approved`, `implemented`. |
| `tags` | list<string> | Keywords (e.g. `defi`, `governance`, `bridge`). |

### `documentation`
NatSpec-style descriptions and references.

| Field | Type | Description |
| --- | --- | --- |
| `summary` | string | One-paragraph overview. |
| `motivation` | string | Why the contract exists. |
| `rationale` | string | Design reasoning, trade-offs. |
| `references` | list<object> | External docs (`{ title, url, note }`). |
| `security_considerations` | string | Known risks, assumptions. |
| `audit_notes` | string | Links to past audits or issues. |

### `roles`
Enumerates actors interacting with the contract.

Each role entry:

```yaml
roles:
  - name: Admin
    description: Controls circuit upgrades and pausing
    privileges:
      - upgrade_contract
      - set_fee_parameters
    constraints:
      - multisig_required
```

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | Role name. |
| `description` | string | Responsibilities. |
| `privileges` | list<string> | Actions allowed. |
| `constraints` | list<string> | Requirements (e.g. `must_be_registered_note`). |

### `state`
Defines stored data and how it is partitioned between public and private domains.

```yaml
state:
  public:
    - name: total_supply
      type: field
      description: Total minted tokens visible on L2
      visibility: read_only
  private:
    - name: balances
      type: map<address, field>
      description: Note commitments per user
  commitments:
    - name: vault_commitment
      description: Commitment representing vault reserves
  nullifiers:
    - name: spend_nullifier
      description: Prevents double spends of notes
```

Common fields:

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | Identifier. |
| `type` | string | Abstract type (`field`, `u128`, `map<k,v>`, `array<n>`). |
| `description` | string | Purpose. |
| `visibility` | enum | `read_only`, `write_only`, `mutable`. |
| `constraints` | list<string> | Additional invariants. |

### `notes`
Represents Aztec note types involved.

```yaml
notes:
  - name: DepositNote
    description: Confidential record of a deposit
    fields:
      - name: owner
        type: address
      - name: amount
        type: field
    lifecycle:
      created_by: deposit
      consumed_by: withdraw
```

### `events`
Emitters observable on-chain or via logs.

```yaml
events:
  - name: DepositSubmitted
    visibility: public
    description: Signals a user deposit
    fields:
      - name: account
        type: address
      - name: amount
        type: field
      - name: commitment
        type: field
```

### `functions`
Core section describing callable logic. Separate entries per function.

```yaml
functions:
  - name: deposit
    kind: public_function
    description: User deposits assets into the vault
    docs:
      notice: Adds a private note representing the deposit
      dev: Requires commitment curve validation
    visibility: public
    mutability: state_changing
    selector: 0x12345678
    roles_allowed: [User]
    inputs:
      - name: amount
        type: field
        origin: public
        description: Amount to deposit
      - name: proof
        type: proof
        origin: private
        description: Zero-knowledge proof of funds
    outputs:
      - name: commitment
        type: field
        visibility: public
    state_effects:
      reads: [balances]
      writes: [balances, total_supply]
      nullifiers: [spend_nullifier]
      commitments: [vault_commitment]
    events_emitted: [DepositSubmitted]
    invariants_checked:
      - total_supply_conserved
    errors:
      - code: INSUFFICIENT_BALANCE
        description: Deposit proof invalid
    security:
      - Requires user note ownership proof
    performance:
      - max_constraints: 25000
    test_guidance:
      happy_paths:
        - "Valid deposit updates private state and emits event"
      negative_paths:
        - "Proof with mismatched owner reverts"
      fuzz_properties:
        - "Deposits conserve total supply across random inputs"
```

Function fields:

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | Function identifier. |
| `kind` | enum | `public_function`, `private_function`, `unconstrained_function`, `library_call`. |
| `description` | string | Summary. |
| `docs.notice` | string | User-level description. |
| `docs.dev` | string | Additional developer notes. |
| `visibility` | enum | `public`, `private`, `internal`. |
| `mutability` | enum | `pure`, `view`, `state_changing`. |
| `selector` | string | Optional ABI selector (hex). |
| `roles_allowed` | list<string> | Roles permitted to call. |
| `inputs` | list<object> | Parameter metadata. |
| `outputs` | list<object> | Return metadata. |
| `state_effects` | object | Read/write/nullifier/commitment interactions. |
| `events_emitted` | list<string> | References entries in `events`. |
| `invariants_checked` | list<string> | References entries in `invariants`. |
| `errors` | list<object> | Expected failure codes/messages. |
| `security` | list<string> | Threat model notes per function. |
| `performance` | object | Constraints, gas-likely requirements. |
| `test_guidance` | object | Seeds for later test generation. |

Parameter entries (`inputs`/`outputs`) support:

| Field | Type | Description |
| --- | --- | --- |
| `name` | string | Parameter name. |
| `type` | string | Noir type or higher-level alias. |
| `origin` | enum | `public`, `private`, `note`, `witness`, `context`. |
| `description` | string | Purpose. |
| `constraints` | list<string> | Value bounds or validations. |

### `flows`
Captures multi-step sequences across functions.

```yaml
flows:
  - name: DepositLifecycle
    description: From user deposit to note creation
    stages:
      - step: submit_deposit
        function: deposit
        visibility_transition: public_to_private
        notes_consumed: []
        notes_created: [DepositNote]
      - step: emit_event
        function: deposit
        visibility_transition: private_to_public
        events: [DepositSubmitted]
```

Each stage can reference privacy transitions (`public_to_private`, `private_to_public`, `private_to_private`, `public_to_public`).

### `invariants`
Global rules the contract must always satisfy.

```yaml
invariants:
  - id: total_supply_conserved
    description: Sum of private balances equals public total_supply
    scope: global
    enforcement:
      checked_in: [deposit, withdraw]
      proofs_required: [consistency_proof]
```

### `external`
Dependencies outside the contract.

```yaml
external:
  interfaces:
    - name: L1Portal
      description: Interacts with layer1 bridge
      functions:
        - name: send_message
          direction: outbound
  oracles:
    - name: PriceOracle
      availability: l2_public
```

### `sequence_diagrams`
References to diagrams or inline Mermaid definitions.

```yaml
sequence_diagrams:
  - id: deposit_flow
    title: Deposit from user to vault
    format: mermaid
    content: |
      sequenceDiagram
        participant User
        participant Contract
        participant NoteRegistry
        User->>Contract: deposit(amount, proof)
        Contract->>NoteRegistry: create note
        NoteRegistry-->>Contract: commitment
        Contract-->>User: event DepositSubmitted
```

For external diagram files, use `format: link` and `content: ./diagrams/deposit.png`.

### `btt_seed`
Optional scaffold for tree generation.

```yaml
btt_seed:
  default_root: VaultTest
  mappings:
    deposit:
      root: Vault::deposit
      highlight: ["When proof is valid", "When proof fails"]
```

### `annotations`
Freeform metadata for downstream tooling.

```yaml
annotations:
  generate_tests: true
  owner_team: aztec-core
```

## Authoring Guidelines

1. **Start from the template**: Populate metadata, contract basics, and high-level docs first.
2. **Iterate collaboratively**: Agents can ask for clarifications where `[NEEDS CLARIFICATION: ...]` markers are inserted.
3. **Defer implementation**: Avoid code-level details. Describe behavior, constraints, and flows.
4. **Keep privacy explicit**: Always state whether data is public or private, when notes are created/consumed, and which nullifiers apply.
5. **Reference invariants**: Define invariants once and link to them from functions and flows.
6. **Document transitions**: Use `flows` and `sequence_diagrams` to explain public↔private execution paths.
7. **Prepare for BTT**: The `test_guidance` and `btt_seed` sections inform automatic tree generation later.

## Example Specification

```yaml
version: 0.1
metadata:
  id: vault-v1
  created: 2024-05-01
  owners: ["@noir-dev"]
contract:
  name: Vault
  type: contract
  path: src/contracts/vault.nr
  aztec_kind: hybrid
  description: Confidential vault supporting shielded deposits and public withdrawals
roles:
  - name: User
    description: Initiates deposits and withdrawals
    privileges: [deposit, request_withdrawal]
state:
  public:
    - name: total_supply
      type: field
      description: Sum of all deposits
  private:
    - name: balances
      type: map<address, field>
      description: Shielded balance per user
notes:
  - name: DepositNote
    description: Represents a shielded deposit
    fields:
      - name: owner
        type: address
      - name: amount
        type: field
functions:
  - name: deposit
    kind: public_function
    description: Accepts a user deposit into the shielded vault
    visibility: public
    mutability: state_changing
    roles_allowed: [User]
    inputs:
      - name: amount
        type: field
        origin: public
        description: Value committed into the vault
      - name: proof
        type: proof
        origin: private
        description: Validates ownership of funds
    outputs:
      - name: commitment
        type: field
        visibility: public
    state_effects:
      reads: [total_supply]
      writes: [total_supply, balances]
      commitments: [DepositNote]
    events_emitted: [DepositSubmitted]
    invariants_checked: [total_supply_conserved]
    test_guidance:
      happy_paths:
        - "Valid deposit increases balances and emits event"
      negative_paths:
        - "Invalid proof reverts"
flows:
  - name: DepositLifecycle
    stages:
      - step: deposit_request
        function: deposit
        visibility_transition: public_to_private
        notes_created: [DepositNote]
sequence_diagrams:
  - id: deposit_flow
    title: Deposit sequence
    format: mermaid
    content: |
      sequenceDiagram
        participant User
        participant Vault
        participant NoteRegistry
        User->>Vault: deposit(amount, proof)
        Vault->>NoteRegistry: create DepositNote
        NoteRegistry-->>Vault: commitment hash
        Vault-->>User: emit DepositSubmitted
invariants:
  - id: total_supply_conserved
    description: Sum of private balances equals public total_supply
```

## Relationship to Tooling

- `/noir-spec` consumes this YAML to enrich or validate specs.
- `/noir-treegen` transforms the `functions`, `flows`, `test_guidance`, and `btt_seed` sections into `.tree` files.
- `/noir-scaffold` and `/noir-implement` rely on consistent function names and invariants defined herein.

Keep this reference alongside the template so contributors understand how to populate each field.
