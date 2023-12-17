#!/bin/bash

# Directory containing .lat files
input_dir="lattests/good"

# Compiler command
compiler="./latc_x86_64"

# Create output directory
output_dir="lattests/good"
mkdir -p "$output_dir"

# Iterate over all .lat files in the input directory
for file in "$input_dir"/*.lat; do
    # Get the base name without extension
    base_name=$(basename "$file" .lat)

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
    if diff -q "$output_dir/$base_name.myoutput" "$input_dir/$base_name.output" >/dev/null; then
        # Output matches
        echo -e "\e[32m$base_name: ok\e[0m"
    else
        # Output does not match
        echo -e "\e[31m$base_name: bad\e[0m"
    fi
done
