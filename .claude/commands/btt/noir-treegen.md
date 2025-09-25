---
allowed-tools: Bash, Read, Write, MultiEdit, Glob
argument-hint: [--input <spec-file>] [--contracts <dir>] [--output <tree-file>]
description: Generate/enhance tree specification from manual input or existing scan
---

# Noir Tree Generator

Transform a tree specification file into BTT format.

## Arguments
- `--input <spec-file>`: Input specification file (YAML/JSON)
- `--contracts <dir>`: Directory containing Noir contracts to analyze
- `--output <tree-file>`: Output tree file (default: noir-spec.tree)

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Load existing specification if provided
3. Scan contracts if directory specified
4. Merge specifications with contract data
5. Apply BTT (Branching Tree Technique) patterns
6. Generate comprehensive tree file

## BTT Pattern Application

Transform function specifications into BTT format:
- **Conditions**: Use `when` or `given` for preconditions
- **Actions**: Use `it` for test assertions
- **Structure**: Nested conditions create modifier chains

Example transformation:
```
FunctionName
├── When parameter is zero
│   └── It should return default value
├── When parameter is negative
│   └── It should revert with error
└── When parameter is positive
    ├── When value exceeds maximum
    │   └── It should cap at maximum
    └── When value is within range
        └── It should process normally
```

## Specification Schema

Input specification format:
```yaml
test_config:
  coverage_target: 80
  test_types:
    - unit
    - integration
    - fuzz

contracts:
  - name: ContractName
    functions:
      - name: function_name
        scenarios:
          - condition: "when parameter is zero"
            action: "should return default"
            type: edge_case
          - condition: "when caller is unauthorized"
            action: "should revert"
            type: security
        invariants:
          - "total supply never decreases"
          - "balances sum equals total supply"
```

## Enhancement Rules

When merging specifications:
1. **Preserve manual scenarios** - User-defined tests take priority
2. **Add missing coverage** - Identify untested branches
3. **Suggest edge cases** - Based on parameter types
4. **Include security checks** - For state-modifying functions
5. **Add fuzz properties** - For functions with numeric inputs

## Test Categories

Categorize tests by type:
- **Unit Tests**: Single function behavior
- **Integration Tests**: Multi-function interactions
- **Fuzz Tests**: Property-based testing
- **Security Tests**: Access control and invariants
- **Performance Tests**: Gas/constraint optimization

## Output Generation

Create enhanced tree file with:
1. Complete function coverage
2. Categorized test scenarios
3. Invariant specifications
4. Performance benchmarks
5. Security considerations

The output should follow BTT format for compatibility with scaffold generation.