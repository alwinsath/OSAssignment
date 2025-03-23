#!/bin/bash

# Directories and files
SUBMISSIONS_DIR="submissions"
LOG_FILE="submission_log.txt"
MAX_SIZE=$((5 * 1024 * 1024))  # 5MB in bytes

# Create submissions directory if it doesn't exist
mkdir -p "$SUBMISSIONS_DIR"

# Log a message with timestamp
log_submission() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
    echo "LOG: $message"
}

# Compute SHA256 hash of a file
compute_hash() {
    sha256sum "$1" | awk '{print $1}'
}

# Submit an assignment
submit_assignment() {
    read -p "Enter student name: " student
    read -p "Enter path to assignment file: " filepath

    if [ ! -f "$filepath" ]; then
        echo "File does not exist."
        return
    fi

    filename=$(basename "$filepath")
    extension="${filename##*.}"
    extension=$(echo "$extension" | tr '[:upper:]' '[:lower:]')

    if [[ "$extension" != "pdf" && "$extension" != "docx" ]]; then
        echo "Invalid file type. Only .pdf and .docx files are accepted."
        return
    fi

    filesize=$(stat -c%s "$filepath")
    if [ "$filesize" -gt "$MAX_SIZE" ]; then
        echo "File is too large. Maximum size is 5MB."
        return
    fi

    filehash=$(compute_hash "$filepath")
    destination="$SUBMISSIONS_DIR/$filename"

    if [ -f "$destination" ]; then
        existing_hash=$(compute_hash "$destination")
        if [ "$filehash" == "$existing_hash" ]; then
            echo "Duplicate submission detected! File with the same name and content already submitted."
            log_submission "Duplicate submission attempt by $student for file $filename"
            return
        fi
    fi

    cp "$filepath" "$destination"
    echo "Assignment submitted successfully."
    log_submission "Assignment submitted by $student: $filename, hash: $filehash"
}

# Check if a file has already been submitted
check_submission() {
    read -p "Enter the file name to check: " fname
    if [ -f "$SUBMISSIONS_DIR/$fname" ]; then
        echo "File '$fname' has already been submitted."
        filehash=$(compute_hash "$SUBMISSIONS_DIR/$fname")
        echo "Hash: $filehash"
    else
        echo "File '$fname' has not been submitted."
    fi
}

# List all submitted assignments
list_submissions() {
    echo "Submitted Assignments:"
    ls -lh "$SUBMISSIONS_DIR"
}

# Main menu loop
menu() {
    while true; do
        echo "-----------------------------"
        echo "Examination Submission System"
        echo "1. Submit an assignment"
        echo "2. Check if a file has already been submitted"
        echo "3. List all submitted assignments"
        echo "4. Exit"
        echo "-----------------------------"
        read -p "Choose an option: " option
        case "$option" in
            1) submit_assignment ;;
            2) check_submission ;;
            3) list_submissions ;;
            4)
                read -p "Are you sure you want to exit? (Y/N): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    echo "Exiting system."
                    exit 0
                fi
                ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

menu
