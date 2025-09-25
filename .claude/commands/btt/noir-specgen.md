---
allowed-tools: Bash, Read, Write, Grep, Glob, MultiEdit
argument-hint: [--dir <path>] [--output <filename>]
description: Scan Noir contracts and generate tree specification
---

# Noir Specification Generator

Analyze Noir contracts in the specified directory and generate a tree specification file.

## Arguments
- `--dir <path>`: Directory to scan for .nr files (default: current directory)
- `--output <filename>`: Output file name (default: noir-contracts.tree)

## Tasks

1. Parse command arguments: $ARGUMENTS
2. Scan for all .nr files in the specified directory
3. Parse each file to extract:
   - Contract/module names
   - Function signatures (public, private, unconstrained)
   - Parameters and return types
   - Struct definitions
   - State variables/storage
4. Generate tree specification in YAML format
5. Save to output file

## Specification Generation Rules

For each contract/module found:
- Create root node with contract name
- Add branches for each public function
- Include test scenarios based on:
  - Happy path execution
  - Edge cases (zero values, max values)
  - Error conditions (should_fail scenarios)
  - Access control checks
- Add invariants section for critical properties

## Output Format

Generate a YAML Spec file with:
```yaml
contracts:
  - name: ContractName
    path: src/path/to/contract.nr
    functions:
      - name: function_name
        visibility: public/private/unconstrained
        parameters: [param1: Type, param2: Type]
        return_type: Type
        tests_needed:
          - happy_path
          - edge_cases
          - failure_scenarios
    invariants:
      - property_description
```

## Implementation Steps

1. **Scan Phase**
   - Use Glob to find all .nr files
   - Filter out test files (ending in .test.nr or in test/ directories)

2. **Parse Phase**
   - Read each .nr file
   - Extract function definitions using regex patterns:
     - `pub fn` for public functions
     - `fn` for private functions
     - `unconstrained fn` for unconstrained functions
     - `#[test]` decorated functions (to exclude from contract functions)

3. **Analysis Phase**
   - For each function, determine test scenarios:
     - Functions with numeric parameters: test boundaries
     - Functions with arrays: test empty/single/multiple elements
     - Functions with conditionals: test all branches
     - Functions that modify state: test state transitions

4. **Generation Phase**
   - Create YAML structure
   - Write to specified output file
   - Report summary of contracts and functions found

Execute the scanning and generate the tree specification file.