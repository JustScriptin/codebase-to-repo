# Combine Codebase Script

**Script Name**: `repo-file.sh`  
**Description**:  
This Bash script combines your project’s folder structure and file contents (filtered by file extensions and exclusion lists) into a single timestamped text file. It is particularly useful when you want to share or inspect your entire codebase in one file—minus large auto-generated folders (e.g., `node_modules`) and config files you don’t want to include (e.g., `.env`).

## Table of Contents
1. [Features](#features)  
2. [Prerequisites](#prerequisites)  
3. [Installation](#installation)  
4. [Usage](#usage)  
5. [Output](#output)  
6. [Customization](#customization)  
7. [Contributing](#contributing)  
8. [License](#license)  

## Features
- Recursively generates a “tree” representation of your directories.
- Excludes specified directories (e.g., `node_modules`, `.git`) from both the tree and the final output.
- Excludes certain files (e.g., `.env`) from the final output.
- Allows inclusion of only specific file extensions (e.g., `js`, `ts`, `md`) or exact file names (like `Dockerfile`).
- Produces a single comprehensive file, timestamped to avoid overwriting previous runs.

## Prerequisites
- **Bash shell** (Generally available on macOS, Linux, and WSL on Windows).
- **File permissions**: Ensure the script has execution rights if running on Unix-like systems (`chmod +x`).

## Installation
1. Clone or download this repository.
2. Place `combine_codebase.sh` in your project’s root directory (or wherever you want to run it).
3. *(Optional)* If the script is not executable, grant permissions:
   ```bash
   chmod +x combine_codebase.sh
   ```

## Usage
1. Open your terminal or command prompt.
2. Navigate to the root directory of your project:
   ```bash
   cd /path/to/your/project
   ```
3. Run the script:
   ```bash
   ./combine_codebase.sh
   ```
   On Windows (with Git Bash or WSL), the same command should work.

4. After it completes, the script will display where the output file is located.  
   Look for a file named `combined_YYYYMMDD_HHMMSS.txt`.

## Output
- The script creates a file named `combined_YYYYMMDD_HHMMSS.txt` (where `YYYYMMDD_HHMMSS` is the timestamp).
- This file contains:
  1. **CODEBASE FOLDER STRUCTURE**: A tree-like visualization of your folders.
  2. **CODEBASE FILES WITH THEIR RESPECTIVE PATHS**: A concatenation of all the allowed files’ contents, prefixed by a header indicating each file’s relative path.

## Customization
- **Excluded Directories**: Edit the array named `excluded_dirs` inside `combine_codebase.sh` to add or remove directories you don’t want to include in the final output.
- **Excluded Files**: Update `excluded_files` with any filenames you wish to skip.
- **Allowed Extensions**: Modify the `allowed_extensions` array to include or exclude particular file types (e.g., `js`, `jsx`, `ts`, `tsx`, etc.).
- **Dockerfile Inclusion**: The script explicitly checks for files named `Dockerfile` and includes them; remove this check if you don’t need it.

## Contributing
1. **Fork** this repository.
2. Create a **Feature Branch**:  
   ```bash
   git checkout -b feature/YourFeature
   ```
3. **Commit Changes**:  
   ```bash
   git commit -m "Add your feature"
   ```
4. **Push to Branch**:  
   ```bash
   git push origin feature/YourFeature
   ```
5. **Open a Pull Request** on GitHub (or your chosen git platform). We welcome all improvements, bug fixes, and suggestions.

## License
[MIT](LICENSE)