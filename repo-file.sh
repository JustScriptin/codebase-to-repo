#!/bin/bash
#
# -------------------------------------------------------------------------
#  combine_codebase.sh
#
#  A Bash script that:
#    1. Generates a directory tree of your project, excluding specified 
#       directories.
#    2. Recursively finds and appends the contents of allowed files 
#       (based on extensions or exact file names like Dockerfile) into
#       a single combined output file.
#
#  Output file format: combined_YYYYMMDD_HHMMSS.txt
#
#  Usage:
#    1. Make the script executable:
#         chmod +x combine_codebase.sh
#    2. Run it from the root of your repository:
#         ./combine_codebase.sh
#
#  Author: JustScriptin
#  License: MIT
# -------------------------------------------------------------------------

# Store the current directory (which should be the project root)
src_dir=$(pwd)

# Get the project's base name (for informational purposes if needed)
repo_name=$(basename "$src_dir")

# Generate a timestamp for creating a unique output file name
timestamp=$(date +%Y%m%d_%H%M%S)

# Define the name and path for the combined output file
combined_file="${src_dir}/combined_${timestamp}.txt"

# -------------------------------------------------------------------------
# Directories and files to exclude from both the folder tree and the code
# combination process. Update these lists as needed.
# -------------------------------------------------------------------------
excluded_dirs=(
    "node_modules"
    ".next"
    "build"
    "coverage"
    "public"
    "docs"
    "tests"
    ".git"
)
excluded_files=(
    ".env"
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    ".eslintrc.json"
    ".prettierrc"
    ".gitignore"
    ".prettierignore"
    "next.config.js"
    "babel.config.js"
    "jest.config.js"
    "tsconfig.json"
    "postcss.config.mjs"
    "next-env.d.ts"
    "components.json"
)

# -------------------------------------------------------------------------
# File extensions that we want to include in the combination process.
# The script also includes a check for files literally named 'Dockerfile'.
# -------------------------------------------------------------------------
allowed_extensions=("js" "jsx" "ts" "tsx" "html" "json" "css" "scss" "sass" "md" "yml" "yaml")

# -------------------------------------------------------------------------
# Clear (truncate) the combined output file if it already exists or create
# an empty one if it doesn't.
# -------------------------------------------------------------------------
: > "$combined_file"

# -------------------------------------------------------------------------
# A recursive function to generate a directory tree structure, skipping
# excluded directories. The output is appended to $combined_file.
#
# Arguments:
#   1. dir_path: The directory to process.
#   2. prefix:   A string used to print the tree connectors, e.g. "├──".
#   3. indent:   A string used for indentation in subdirectories.
# -------------------------------------------------------------------------
generate_tree() {
    local dir_path=$1
    local prefix=$2
    local indent=$3

    # Print the current directory's name
    echo "${prefix}${dir_path##*/}/" >> "$combined_file"

    # Build the indentation prefix for subdirectories
    local new_indent="${indent}│   "

    # Gather both normal and hidden items (excluding . and ..)
    local items=("$dir_path"/* "$dir_path"/.*)
    items=("${items[@]}")

    # Count only the visible items to handle an empty directory properly
    local visible_count=0
    for item in "${items[@]}"; do
        local basename=$(basename "$item")
        if [[ "$basename" != "." && "$basename" != ".." ]]; then
            ((visible_count++))
        fi
    done

    # If no visible files/folders are present, stop processing
    if [ $visible_count -eq 0 ]; then
        return
    fi

    local count=${#items[@]}
    local index=0

    # Iterate over each item in the current directory
    for item in "${items[@]}"; do
        local basename=$(basename "$item")

        # Skip the "." and ".." special directories
        if [[ "$basename" == "." || "$basename" == ".." ]]; then
            continue
        fi

        # Adjust the tree connector for the last item
        ((index++))
        local connector="├──"
        if [ $index -eq $count ]; then
            connector="└──"
        fi

        # Check if this item is in the excluded directories list
        local excluded=false
        for excluded_dir in "${excluded_dirs[@]}"; do
            if [[ "$basename" == "$excluded_dir" ]]; then
                echo "${new_indent}${connector} ${excluded_dir}/" >> "$combined_file"
                excluded=true
                break
            fi
        done

        # If it's excluded, skip processing its contents
        if [ "$excluded" = true ]; then
            continue
        fi

        # If it's a directory, recurse into it
        if [ -d "$item" ]; then
            generate_tree "$item" "${new_indent}${connector} " "$new_indent"
        else
            # Otherwise, just print the filename
            echo "${new_indent}${connector} ${basename}" >> "$combined_file"
        fi
    done
}

# -------------------------------------------------------------------------
# Write an initial header for the folder structure in the output file
# and invoke generate_tree for the current directory.
# -------------------------------------------------------------------------
echo "==== CODEBASE FOLDER STRUCTURE ====" > "$combined_file"
generate_tree "$src_dir" "" ""

# -------------------------------------------------------------------------
# Construct a 'find' command dynamically. This will look for files,
# excluding specified directories and file names, and then print them
# in a null-delimited fashion (-print0) for safe processing.
# -------------------------------------------------------------------------
find_command=("find" "$src_dir" "-type" "f")

# Exclude directories (case-sensitive check)
for dir in "${excluded_dirs[@]}"; do
  find_command+=("-not" "-path" "$src_dir/$dir/*")
done

# Exclude specific file names
for file in "${excluded_files[@]}"; do
  find_command+=("-not" "-name" "$file")
done

# Ensure null-delimited printing of paths
find_command+=("-print0")

# -------------------------------------------------------------------------
# Write a new header for file contents in the output file.
# -------------------------------------------------------------------------
echo -e "\n==== CODEBASE FILES WITH THEIR RESPECTIVE PATHS ====\n" >> "$combined_file"

# -------------------------------------------------------------------------
# Execute the constructed 'find' command. For each file found:
#   1. Check if its extension (or file name) matches our allowlist.
#   2. If it does, print a header containing its relative path and
#      append its contents to the combined file.
#
# Note: We specifically handle "Dockerfile" by name, in addition to our
#       allowed_extensions list.
# -------------------------------------------------------------------------
while IFS= read -r -d '' file; do
  filename=$(basename "$file")
  extension="${filename##*.}"

  # If the file is literally 'Dockerfile' or its extension is in the allowlist
  if [ "$filename" == "Dockerfile" ] || [[ " ${allowed_extensions[@]} " =~ " ${extension} " ]]; then
    # Print a clear delimiter header for this file
    echo -e "\n\n### ${file#$src_dir/} ###\n" >> "$combined_file"

    # Append the file contents
    cat "$file" >> "$combined_file"
  fi
done < <("${find_command[@]}")

# Print a completion message to the screen
echo "Done. Output in: $combined_file"
