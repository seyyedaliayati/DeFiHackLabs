#!/bin/bash

# Set the directory path containing the contract files
CONTRACT_DIR="src/test"

# Name of the log file
LOG_FILE="test_logs.txt"

# Function to run forge test for a contract file
run_forge_test() {
    local contract_file="$1"
    local contract_name=$(basename "${contract_file%.sol}")

    echo "Running tests for contract: $contract_name"
    forge test --contracts "$contract_file" # -vv > "$LOG_FILE" 2>&1
}

# Export the function so it can be used by parallel subshells
export -f run_forge_test

# Set the maximum number of parallel jobs
MAX_JOBS=4

# Initialize a counter for parallel jobs
job_counter=0

# Loop through all contract files inside the directory
for contract_file in "$CONTRACT_DIR"/*.sol; do
    # Check if the current job_counter exceeds the maximum number of jobs
    if ((job_counter >= MAX_JOBS)); then
        # Wait for all background jobs to complete before continuing
        wait
        # Reset the job_counter
        job_counter=0
    fi

    # Run the forge test command for the current contract file in the background
    run_forge_test "$contract_file" &
    
    # Increment the job_counter
    ((job_counter++))
done

# Wait for any remaining background jobs to complete
wait
