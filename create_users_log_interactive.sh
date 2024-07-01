#!/bin/bash

# Here in this script I'm using different functions to do logging, usercreation and Interactive mode


LOG_FILE="manage_users.log"

# Function to log messages with timestamps
log() {

    #here log function take 1 argument which is whatever the log message we want print and print it infront of date and time

    # and >> append output to the LOG_FILE

    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to create a new user
create_user() {

    # This is fuction to create new user and ittake three argument then that can from file or may be from interactive mode 

    local username=$1
    local group=$2
    local permission=$3
    
    # Here we check if a particular group exist or not with getent group command and the output will go to /dev/null and erased

    if ! getent group "$group" > /dev/null; then
        sudo groupadd "$group"
        log "Group $group created"
    fi
    
    # Adding users and setting permission

    sudo useradd -m -g "$group" "$username"
    sudo chmod "$permission" "/home/$username"
    
    # I created a password doe each user which is the combination of username and group with no space

    local password="${username}${group}"
    echo "$username:$password" | sudo chpasswd

    # Logging all the above activities with log function

    log "User $username created with home directory permission $permission and password $password"
    
    # Making project directory with welcome message

    sudo -u "$username" mkdir -p "/home/$username/projects"
    echo "Welcome, $username! some intro message here." | sudo tee "/home/$username/projects/README.md" > /dev/null
    sudo chown "$username:$group" "/home/$username/projects/README.md"
    sudo chmod 644 "/home/$username/projects/README.md"
    log "Created projects directory and README.md for $username"
}

# Interactive mode function
interactive_mode() {
    echo "=== Interactive Mode ==="
    echo "Choose an option:"
    echo "1. Add a new user"
    echo "2. Delete a user"
    echo "3. Modify user permissions"
    echo "4. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter username: " username
            read -p "Enter group: " group
            read -p "Enter permission: " permission
            create_user "$username" "$group" "$permission"
            ;;
        2)
            read -p "Enter username to delete: " username
            sudo userdel -r "$username"
            log "User $username deleted"
            ;;
        3)
            read -p "Enter username to modify: " username
            read -p "Enter new permission: " permission
            sudo chmod "$permission" "/home/$username"
            log "Permission changed for $username to $permission"
            ;;
        4)
            echo "Exiting interactive mode."
            exit 0
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac

    interactive_mode  # Loop back to continue interactive mode
}

# Main script starts here

# Check if log file exists, create if not
if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
fi

# Initial log entry
log "Script started"

# Check if running in interactive mode
if [ "$1" == "-i" ]; then
    interactive_mode
    exit 0
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
    echo "File not found: $INPUT_FILE"
    exit 1
fi

# Process each line in the input file

while IFS=, read -r username group permission; do
    create_user "$username" "$group" "$permission"
done < "$INPUT_FILE"

# Final log entry
log "Script completed"