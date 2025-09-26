---
description: Create and collaboratively fill out a Noir contract specification workbook with the user.
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS = [SPEC_PATH] [FEATURE_DESCRIPTION]

Given the spec path and optional feature description provided as arguments, do this:

## Execution Flow

1. **Parse Arguments**:
   - Extract SPEC_PATH (e.g., `/Users/abuusama/repos/aztec/starters/ds-math/.claude/spec/001-noir-math-refactor`)
   - Extract FEATURE_DESCRIPTION (optional context about the contract or feature)
   - If SPEC_PATH is missing: ERROR "Missing spec path argument"

2. **Setup Workbook**:
   - Create the spec directory if it doesn't exist: `mkdir -p $SPEC_PATH`
   - Copy the contract workbook template:
     ```bash
     cp /Users/abuusama/repos/aztec/starters/ds-math/.claude/templates/contract-workbook.md $SPEC_PATH/workbook.md
     ```
   - Open the workbook for editing

3. **Initialize Workbook Context**:
   - Replace `[CONTRACT OR FEATURE]` with the feature name extracted from path
   - Replace `[DATE]` with today's date
   - If FEATURE_DESCRIPTION provided, populate the Input Context field
   - Update file paths based on project structure

4. **Interactive Collaboration Mode**:
   - Present the workbook sections to the user systematically
   - For each mandatory section:
     a. Show current section content
     b. Ask user for specific information needed
     c. Fill in the section based on user input
     d. Confirm with user before proceeding to next section
   - Mark `[NEEDS CLARIFICATION]` for any unclear requirements

5. **Section-by-Section Workflow**:

   **Phase 1: Documentation & Context**
   - Gather summary, motivation, and rationale
   - Identify security considerations
   - Collect references if any

   **Phase 2: YAML Specification**
   - Work with user to define:
     * Contract metadata (name, type, path)
     * Roles and permissions
     * State variables (public/private)
     * Events and notes
     * Functions with signatures
   - Validate against meta-language schema

   **Phase 3: Behavioral Flows**
   - Map out key user journeys
   - Document privacy transitions
   - Create flow exhaustive list table

   **Phase 4: BTT Seed & Testing**
   - Draft initial BTT branches based on YAML
   - Create test coverage matrix
   - Set coverage targets

6. **Review & Validation**:
   - Run through the Review Checklist
   - Identify any remaining clarifications needed
   - Save the completed workbook
   - Generate a summary of what was documented

7. **Output & Next Steps**:
   - Report the workbook location: `$SPEC_PATH/workbook.md`
   - List any `[NEEDS CLARIFICATION]` items
   - Suggest next commands:
     * `/spec:clarify` if clarifications needed
     * `/noir-treegen` to generate BTT tree from YAML
     * `/noir-scaffold` to create test scaffolds

## Error Handling
- If template not found: ERROR "Contract workbook template missing"
- If spec path invalid: ERROR "Invalid spec path provided"
- If YAML validation fails: WARN "YAML spec needs corrections" and help fix

## Interactive Guidelines
- Always explain what you're about to do before doing it
- Ask for user confirmation before moving to next major section
- Provide examples when asking for complex information
- Save workbook incrementally after each major section
- Keep user informed of progress through the checklist

Use absolute paths with the repository root for all file operations to avoid path issues.