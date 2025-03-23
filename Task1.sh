#!/bin/bash



# Constants
BACKUP_DIR="Backup"
LOG_FILE="backup_log.txt"
MAX_BACKUP_SIZE=500 # Size in MB

# Function to log operations
log_operation() {
    local operation="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $operation" >> "$LOG_FILE"
    echo "Operation logged: $operation"
}

# Function to check if backup directory size exceeds limit
check_backup_size() {
    if [ -d "$BACKUP_DIR" ]; then
        local size=$(du -sm "$BACKUP_DIR" | cut -f1)
        if [ "$size" -ge "$MAX_BACKUP_SIZE" ]; then
            echo "WARNING: Backup directory size ($size MB) exceeds the limit of $MAX_BACKUP_SIZE MB!"
            log_operation "WARNING: Backup directory size exceeded limit ($size MB)"
            return 1
        fi
    fi
    return 0
}

# Function to list files in a directory
list_files() {
    local dir="${1:-.}" # Default to current directory if none specified
    
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist."
        log_operation "Failed to list files: Directory '$dir' does not exist"
        return 1
    fi
    
    echo "Listing files in '$dir':"
    echo "-----------------------------------------"
    ls -lh "$dir" | awk '{if (NR>1) {print $9 " | Size: " $5 " | Last Modified: " $6 " " $7 " " $8}}'
    log_operation "Listed files in directory '$dir'"
}

# Function to move a file
move_file() {
    read -p "Enter the source file path: " source
    read -p "Enter the destination directory: " destination
    
    if [ ! -f "$source" ]; then
        echo "Error: Source file '$source' does not exist."
        log_operation "Failed to move: Source file '$source' does not exist"
        return 1
    fi
    
    if [ ! -d "$destination" ]; then
        read -p "Destination directory does not exist. Create it? (Y/N): " create
        if [[ "$create" =~ ^[Yy]$ ]]; then
            mkdir -p "$destination"
            echo "Created directory '$destination'"
            log_operation "Created directory '$destination'"
        else
            echo "Operation cancelled."
            log_operation "Move operation cancelled: destination directory doesn't exist"
            return 1
        fi
    fi
    
    filename=$(basename "$source")
    if [ -f "$destination/$filename" ]; then
        read -p "File already exists in destination. Overwrite? (Y/N): " overwrite
        if [[ "$overwrite" =~ ^[Yy]$ ]]; then
            mv "$source" "$destination"
            echo "File moved and overwritten."
            log_operation "Moved and overwrote file '$source' to '$destination/$filename'"
        else
            read -p "Enter new name for the file: " new_name
            mv "$source" "$destination/$new_name"
            echo "File moved with new name '$new_name'."
            log_operation "Moved file '$source' to '$destination/$new_name'"
        fi
    else
        mv "$source" "$destination"
        echo "File moved successfully."
        log_operation "Moved file '$source' to '$destination/$filename'"
    fi
}

# Function to rename a file
rename_file() {
    read -p "Enter the file path to rename: " file_path
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File '$file_path' does not exist."
        log_operation "Failed to rename: File '$file_path' does not exist"
        return 1
    fi
    
    read -p "Enter new name for the file: " new_name
    
    directory=$(dirname "$file_path")
    if [ -f "$directory/$new_name" ]; then
        echo "Error: A file with name '$new_name' already exists in that directory."
        log_operation "Failed to rename: Name conflict with '$new_name'"
        return 1
    fi
    
    mv "$file_path" "$directory/$new_name"
    echo "File renamed successfully."
    log_operation "Renamed file '$file_path' to '$directory/$new_name'"
}

# Function to delete a file
delete_file() {
    read -p "Enter the file path to delete: " file_path
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File '$file_path' does not exist."
        log_operation "Failed to delete: File '$file_path' does not exist"
        return 1
    fi
    
    read -p "Are you sure you want to permanently delete this file? (Y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm "$file_path"
        echo "File deleted permanently."
        log_operation "Deleted file '$file_path'"
    else
        echo "Deletion cancelled."
        log_operation "File deletion cancelled for '$file_path'"
    fi
}

# Function to backup a file
backup_file() {
    read -p "Enter the file path to backup: " file_path
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File '$file_path' does not exist."
        log_operation "Failed to backup: File '$file_path' does not exist"
        return 1
    fi
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "Created backup directory."
        log_operation "Created backup directory '$BACKUP_DIR'"
    fi
    
    # Check backup directory size
    check_backup_size
    
    # Create timestamped backup
    filename=$(basename "$file_path")
    timestamp=$(date "+%Y%m%d_%H%M%S")
    backup_name="${filename}_${timestamp}"
    
    cp "$file_path" "$BACKUP_DIR/$backup_name"
    echo "File backed up as '$BACKUP_DIR/$backup_name'."
    log_operation "Backed up file '$file_path' to '$BACKUP_DIR/$backup_name'"
    
    # Check size again after backup
    check_backup_size
}

# Function to display the main menu
display_menu() {
    echo ""
    echo "===== UNIVERSITY FILE MANAGEMENT SYSTEM ====="
    echo "1. List files in a directory"
    echo "2. Move a file"
    echo "3. Rename a file"
    echo "4. Delete a file"
    echo "5. Backup a file"
    echo "6. Exit"
    echo "=============================================="
    read -p "Select an option (1-6): " choice
}

# Initialize log file if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    log_operation "File Management System started"
fi

# Main program loop
while true; do
    display_menu
    
    case $choice in
        1)
            read -p "Enter directory path (press Enter for current directory): " dir
            list_files "${dir:-.}"
            ;;
        2)
            move_file
            ;;
        3)
            rename_file
            ;;
        4)
            delete_file
            ;;
        5)
            backup_file
            ;;
        6)
            read -p "Are you sure you want to exit? (Y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                echo "Bye!"
                log_operation "File Management System exited"
                exit 0
            fi
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
