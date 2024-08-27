#!/bin/bash

# Fullname: Kim Tran
# Student ID: 10657323

# Assign arguments passed from the command line to appropriate variables
input_ram=$1
input_storage=$2
source_file=$3

if [[ -z $input_ram ]] || [[ ! $input_ram =~ ^[1-9]+$ ]]; then  # Check if RAM is empty and is not a number
    echo "Please input a valid capacity for RAM"    # Print invalid message
    exit 1      # Exit program with status code 1 on failed validation
fi

if [[ -z $input_storage ]] || [[ ! $input_storage =~ ^[1-9]+$ ]]; then  # Check if Storage is empty and is not a number
    echo "Please input a valid capacity for Storage"  # Print invalid message
    exit 1      # Exit program with status code 1 on failed validation
fi

if [[ -z $source_file ]] || [[ ! $source_file =~ ^[A-Za-z]+\.csv$ ]] || [[ ! -f $source_file ]]; then  # Check if Source file is empty or is not a .csv file or not existed
    echo "Please input a valid Source file"  # Print invalid message
    exit 1      # Exit program with status code 1 on failed validation
fi

filtered_items=""   # Create a sring to store filtered products

# IFS value set to comma to accomodate the source file format
while IFS=',' read -r smartphone brand model ram storage color price || [ -n "$item" ]; do  # Use while loop to read the source file line by line, with each field in matching header
    if [[ $input_ram == $ram ]] && [[ $input_storage == $storage ]]; then   # If ram and storage capacity of current line match input arguments
        if [[ -n "$filtered_items" ]] && [[ ! -z "$filtered_items" ]]; then   # If the string doesn't contain a new line character (not the end of the file)
            filtered_items+="\n"    # Append a new line to the end of the string
        fi
        filtered_items+="$brand,$model,$color,$price" # Append the string with new entry
    fi
done < $source_file     # The source file argument provided from the command line as input source

# Use echo with the -e flag to correctly interpret escape characters (\n) and
    # use process substitution to write the string to the "temp.txt" file
echo -e "$filtered_items" > temp.txt

line_count=$(grep -cve '^\s*$' temp.txt)    # Use grep command to count non-empty lines in the "temp.txt" file

# If the line count is greater than 0 ("temp.txt" is not empty)
if [ $line_count -gt 0 ]; then
    # Print a message with the number of products found from provided arguments
    echo "$line_count devices were found with ${input_ram}GB RAM and ${input_storage}GB Storage from:"

    declare -a unique_brands    # Create an array to store unique brands

    while read -r line; do  # Read each line from the extracted column
        matched=0   # Set a flag to detect a matched item with initial value of 0
        for brand in "${unique_brands[@]}"; do  # Loop through the "unique_brands" array
            if [[ "$brand" == "$line" ]]; then  # If the current array element matches the current line
                matched=1   # Set the flag to 1 to indicate a match found
                break   # Exit the for loop
            fi
        done
        if [[ $matched -eq 0 ]]; then   # If no matches found
            unique_brands+=("$line")    # Add the line to the "unique_brands" array
        fi
    done < <(cut -d',' -f1 temp.txt)    # Extract 1st column (phone brand) from the "temp.txt" file
                                            # and use process substitution to treat the "cut" command as a file so while loop can process it

    for brand in "${unique_brands[@]}"; do  # Loop through the unique brands array
        # Print current brand and a count of matching lines in the "temp.txt" file
        printf "%-12s %-5s\n" "$brand" "($(grep -c $brand temp.txt))"
    done

    BLUE='\e[1;34m'   # Color for headers
    NC='\e[m'    # No colour
    printf "${BLUE}%-18s | %-18s | %-18s | %-18s${NC}\n" "BRAND" "MODEL" "COLOR" "PRICE"   # Print specified column headers with stipulated format

    while IFS=',' read -r brand model color price || [ -n "$item" ]; do  # Read line by line until reach new line
        printf "%-18s | %-18s | %-18s | %-18s \n" "$brand" "$model" "$color" "\$$price"   # Print each field in matching headers, precede $price with \$ to escape special character
    done < "temp.txt"      # "temp.txt" as input source for while loop
else
    echo "No devices were found with ${input_ram}GB RAM and ${input_storage}GB Storage."    # Otherwise, print no results message
fi

rm -r temp.txt  # Delete the temp.txt file before exiting program

exit 0  # exit program