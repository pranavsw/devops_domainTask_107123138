#!/bin/bash

# Check if the input file is provided

# -z checks if the length of the string is zero or not 

# $1 refers to the first positional parameter (the first argument) passed to the script. If the script is called without any arguments, $1 will be empty

if [ -z "$1" ]; then
    echo "Usage: $0 usernames.csv"
    # $0 exits the name of the script to see which script we forgot to give argument
    
    exit 1
fi

INPUT_FILE="$1" 

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "File not found: $INPUT_FILE"
    exit 1
fi


# Set Up Specific Permissions and Group Assignments:

# Process each line in the input file with IFS
while IFS=, read -r username group permission; do
    # Check if the group exists, create if it doesn't
    if ! getent group "$group" > /dev/null; then
        sudo groupadd "$group"
        echo "Group $group created"
    fi

    # Creating the user with the specified group
    sudo useradd -m -g "$group" "$username"
    
    # Set the permission for the user's home directory
    sudo chmod "$permission" "/home/$username"
    
    # Creating a password combining the username and group(extra to access the user right away after creation)
    password="${username}${group}"
    echo "$username:$password" | sudo chpasswd
    
    echo "User $username created with home directory permission $permission and password $password"

      
    # Create the projects directory and README.md file
    sudo -u "$username" mkdir -p "/home/$username/projects"
    echo "Welcome, $username! some intro message here." | sudo tee "/home/$username/projects/README.md" > /dev/null
    sudo chown "$username:$group" "/home/$username/projects/README.md"
    sudo chmod 644 "/home/$username/projects/README.md"
    
    echo "Created projects directory and README.md for $username"
done < "$INPUT_FILE"
