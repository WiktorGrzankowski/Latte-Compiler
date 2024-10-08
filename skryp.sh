#!/bin/bash

# Compiler command
compiler="./latc_x86_64"

# Function to process .lat files in a given directory
process_lat_files() {
    local input_dir="$1"
    local output_dir="$2"
    local all_tests_passed=true

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Iterate over all .lat files in the input directory
    for file in "$input_dir"/*.lat; do
        # Get the base name without extension
        base_name=$(basename "$file" .lat)
        rm "$input_dir/$base_name.myoutput"

        # Check if an input file exists
        input_file="$input_dir/$base_name.input"
        if [ -f "$input_file" ]; then
            # If an input file exists, execute with input redirection
            "$compiler" "$file"
            ./"$output_dir/$base_name" < "$input_file" > "$output_dir/$base_name.myoutput"
        else
            # If no input file, execute without input redirection
            "$compiler" "$file"
            ./"$output_dir/$base_name" > "$output_dir/$base_name.myoutput"
        fi

        # Compare the output with the expected output
        if ! diff -q "$output_dir/$base_name.myoutput" "$input_dir/$base_name.output" >/dev/null; then
            # Output does not match
            echo -e "\e[31m$base_name: bad\e[0m"
            all_tests_passed=false
        else
            # Output matches, test passed
            echo -e "\e[32m$base_name: OK\e[0m"
        fi
    done

    if [ "$all_tests_passed" = true ]; then
        echo -e "\e[32mAll tests in $input_dir passed\e[0m"
    fi
}
process_lat_files_bad() {
    local input_dir="$1"
    local output_dir="$2"
    local all_tests_passed=true

    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Iterate over all .lat files in the input directory
    for file in "$input_dir"/*.lat; do
        # Get the base name without extension
        base_name=$(basename "$file" .lat)

        # Compile and execute the program
        "$compiler" "$file" && ./"$output_dir/$base_name" > "$output_dir/$base_name.myoutput"

        # Check if the compilation or execution failed, which is expected
        if [ $? -ne 0 ]; then
            # Test failed as expected
            echo -e "\e[32m$base_name: OK\e[0m"
        else
            # Test unexpectedly passed
            echo -e "\e[31m$base_name: BAD\e[0m"
            all_tests_passed=false
        fi
    done

    if [ "$all_tests_passed" = true ]; then
        echo -e "\e[32mAll tests in $input_dir failed as expected\e[0m"
    fi
}


# Process .lat files in good and extension directories
process_lat_files "lattests/good" "lattests/good"
process_lat_files "lattests/extensions/arrays1" "lattests/extensions/arrays1"
process_lat_files "lattests/extensions/objects1" "lattests/extensions/objects1"

# Process .lat files in bad directory
# process_lat_files_bad "lattests/bad" "lattests/bad"