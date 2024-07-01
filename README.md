# devops_domainTask_107123138

So I made 2 scripts 1st one name create_users.sh is the basic task requirement and the second create_users_log_interactive.sh is the both tasks which I completed.

## Running the scripts and all setup required on the system

1. Move both the scripts to **usr/local/bin** directory to get access of the script from anywhere on the system
2. Copy the username.csv file to **/data/** folder in Ubuntu to access this file to pass as an argument to the script later.
3. Paste sudo `chmod +x create_users.sh` and `sudo chmod +x create_users_log_interactive.sh` this command in the terminal to make scripts executable.

4. ### For non-interactive mode
   `./create_users.sh /data/usernames.csv` use this command for non-interactive mode

   ### For interactive mode
   `./create_users_log_interactive.sh -i` use this command in terminal for interactive mode

5. Log file will be created in the current directory.
