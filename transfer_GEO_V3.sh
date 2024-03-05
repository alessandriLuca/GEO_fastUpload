#!/bin/bash

# Function to transfer a single file or directory
transfer_item() {
    local item="$1"
    local username="$2"
    local password="$3"
    local server="$4"
    local remote_dir="$5"
    local checksum_file="$6"

    # Perform the file transfer
    curl -T "$item" -u "$username:$password" "ftp://$server/$remote_dir/"

    # Calculate and save the checksum of the file
    local checksum=$(md5sum "$item" | awk '{print $1}')
    echo "$checksum  $(basename "$item")" >> "$checksum_file"
}

# Function to create the remote directory
create_remote_dir() {
    local username="$1"
    local password="$2"
    local server="$3"
    local remote_dir="$4"

    curl -u "$username:$password" --ftp-create-dirs "ftp://$server/$remote_dir/.dummy" > /dev/null 2>&1
}

# Export functions to make them available in parallel contexts
export -f transfer_item
export -f create_remote_dir

# Show usage if arguments are not provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 LOCAL_DIR REMOTE_DIR SERVER PASSWORD USERNAME"
    echo "Transfer files from LOCAL_DIR to REMOTE_DIR on FTP SERVER"
    exit 1
fi

LOCAL_DIR="$1"
REMOTE_DIR="$2/$(basename "$LOCAL_DIR")"
SERVER="$3"
PASSWORD="$4"
USERNAME="$5"
CHECKSUM_FILE="$(basename "$LOCAL_DIR").txt"

# Remove the checksum file if it already exists
rm -f "$CHECKSUM_FILE"

# Create the remote directory if it doesn't exist
create_remote_dir "$USERNAME" "$PASSWORD" "$SERVER" "$REMOTE_DIR"

# Find all files and directories in the local path and transfer each item in parallel
find "$LOCAL_DIR" -mindepth 1 -print0 | parallel -0 -j+0 transfer_item "{}" "$USERNAME" "$PASSWORD" "$SERVER" "$REMOTE_DIR" "$CHECKSUM_FILE"

echo "Checksums of files transferred are saved in $CHECKSUM_FILE"
