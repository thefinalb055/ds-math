#!/bin/bash

# DS-Math Fuzz Test Runner
# Configurable script for running Noir fuzz tests

# Default configuration
DEFAULT_TIMEOUT=0  # 0 means no timeout in nargo fuzz
DEFAULT_THREADS=1
DEFAULT_MAX_EXECUTIONS=0  # 0 means no limit in nargo fuzz
SKIP_CHECKS="--skip-underconstrained-check"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display help
show_help() {
    echo "DS-Math Fuzz Test Runner"
    echo ""
    echo "Usage: $0 [options] [harness_pattern]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -t, --timeout SEC    Set timeout per harness in seconds (0 = no timeout)"
    echo "  -j, --threads NUM    Number of threads to use (default: $DEFAULT_THREADS)"
    echo "  -m, --max-exec NUM   Maximum number of executions (0 = unlimited)"
    echo "  -q, --quick          Quick mode: 10 second timeout, 4 threads"
    echo "  -T, --thorough       Thorough mode: 300 second timeout, 8 threads"
    echo "  -l, --list           List all available fuzz harnesses"
    echo "  -p, --properties     Run only property fuzz tests"
    echo "  -o, --overflow       Run only overflow detection fuzz tests"
    echo "  -c, --corpus DIR     Use/save corpus in specified directory"
    echo ""
    echo "Examples:"
    echo "  $0                   # Run all fuzz tests with defaults"
    echo "  $0 --quick           # Quick run of all tests"
    echo "  $0 --thorough        # Thorough run of all tests"
    echo "  $0 add               # Run only tests matching 'add'"
    echo "  $0 -t 120 -j 4       # 120s timeout, 4 threads"
    echo "  $0 --properties      # Run only property tests"
    echo "  $0 --max-exec 10000  # Limit to 10000 executions per harness"
    echo ""
    echo "Environment Variables:"
    echo "  FUZZ_TIMEOUT         Override default timeout"
    echo "  FUZZ_THREADS         Override default thread count"
    echo "  FUZZ_MAX_EXECUTIONS  Override default max executions"
    echo "  FUZZ_CORPUS_DIR      Override default corpus directory"
}

# Parse command line arguments
TIMEOUT=${FUZZ_TIMEOUT:-$DEFAULT_TIMEOUT}
THREADS=${FUZZ_THREADS:-$DEFAULT_THREADS}
MAX_EXECUTIONS=${FUZZ_MAX_EXECUTIONS:-$DEFAULT_MAX_EXECUTIONS}
CORPUS_DIR=""
HARNESS_PATTERN=""
LIST_MODE=false
FAILURE_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -j|--threads)
            THREADS="$2"
            shift 2
            ;;
        -m|--max-exec)
            MAX_EXECUTIONS="$2"
            shift 2
            ;;
        -q|--quick)
            TIMEOUT=10
            THREADS=4
            shift
            ;;
        -T|--thorough)
            TIMEOUT=300
            THREADS=8
            shift
            ;;
        -l|--list)
            LIST_MODE=true
            shift
            ;;
        -p|--properties)
            HARNESS_PATTERN="math_properties_fuzz"
            shift
            ;;
        -o|--overflow)
            HARNESS_PATTERN="math_overflow_fuzz"
            shift
            ;;
        -c|--corpus)
            CORPUS_DIR="$2"
            shift 2
            ;;
        -f|--failure-dir)
            FAILURE_DIR="$2"
            shift 2
            ;;
        *)
            HARNESS_PATTERN="$1"
            shift
            ;;
    esac
done

# Build the nargo fuzz command
build_fuzz_cmd() {
    local cmd="nargo fuzz"

    # Add options first (before the harness pattern)
    cmd="$cmd $SKIP_CHECKS"

    if [ "$LIST_MODE" = true ]; then
        cmd="$cmd --list-all"
    else
        # Only add non-zero timeout
        if [ "$TIMEOUT" -ne 0 ]; then
            cmd="$cmd --timeout $TIMEOUT"
        fi

        cmd="$cmd --num-threads $THREADS"

        # Only add non-zero max-executions
        if [ "$MAX_EXECUTIONS" -ne 0 ]; then
            cmd="$cmd --max-executions $MAX_EXECUTIONS"
        fi

        if [ ! -z "$CORPUS_DIR" ]; then
            cmd="$cmd --corpus-dir $CORPUS_DIR"
        fi

        if [ ! -z "$FAILURE_DIR" ]; then
            cmd="$cmd --fuzzing-failure-dir $FAILURE_DIR"
        fi
    fi

    # Add harness pattern last (positional argument)
    if [ ! -z "$HARNESS_PATTERN" ]; then
        cmd="$cmd $HARNESS_PATTERN"
    fi

    echo "$cmd"
}

# Main execution
main() {
    local cmd=$(build_fuzz_cmd)

    if [ "$LIST_MODE" = true ]; then
        echo -e "${BLUE}Available fuzz harnesses:${NC}"
        $cmd 2>/dev/null | grep "test::fuzz::" | sed 's/\t/  /'
    else
        echo -e "${GREEN}DS-Math Fuzz Test Runner${NC}"
        echo -e "${YELLOW}Configuration:${NC}"
        if [ "$TIMEOUT" -eq 0 ]; then
            echo "  Timeout:     unlimited"
        else
            echo "  Timeout:     ${TIMEOUT}s per harness"
        fi
        echo "  Threads:     $THREADS"
        if [ "$MAX_EXECUTIONS" -eq 0 ]; then
            echo "  Max Executions: unlimited"
        else
            echo "  Max Executions: $MAX_EXECUTIONS"
        fi
        if [ ! -z "$CORPUS_DIR" ]; then
            echo "  Corpus Dir:  $CORPUS_DIR"
        fi
        if [ ! -z "$HARNESS_PATTERN" ]; then
            echo "  Pattern:     $HARNESS_PATTERN"
        fi
        echo ""
        echo -e "${BLUE}Running command:${NC}"
        echo "  $cmd"
        echo ""
        echo -e "${GREEN}Starting fuzz tests...${NC}"
        echo "----------------------------------------"

        # Run the fuzz command
        $cmd

        # Check exit code
        if [ $? -eq 0 ]; then
            echo "----------------------------------------"
            echo -e "${GREEN}✓ Fuzz tests completed successfully${NC}"
        else
            echo "----------------------------------------"
            echo -e "${RED}✗ Fuzz tests found failures${NC}"
            exit 1
        fi
    fi
}

# Run main function
main