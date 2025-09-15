#!/bin/bash
#wherever the previos validate command is there, there its going to work
set -e

failure()
{
    echo "Failed at the line no and command is at :: $1 $2"

}
#trap function gives exactly which line got error and which command got failed
#calling failure function
trap 'failure "${LINENO}" "${BASH_COMMAND}"' ERR

#start time
START_TIME=$(date +%s)
# Checking root access 
USERID=$(id -u)

# Creating Variables for Colours
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# Creatring Logs folder variable , where logs ll be saved
LOGS_FOLDER="/var/log/roboshop-logs"
# not to have two end endpoints extension, so removing .sh for our convienince
SCRIPT_NAME=$(echo $0 | awk -F "." '{print $1F}')
# Creating Log file ending with .log ectenstion, ex: var/log/roboshop-logs/13-logs.log
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
#Creating absolute path, so we can access the app in any location with out any error, for ex: /app-> from this location also i can acces caatalogue code i app tier
SCRIPT_DIR=$PWD

# ************** note vvvvvv imp, where ever log is store in LOG_FILE, which shows on screen as output ex: echo, there i am going to use tee command [tee -a $LOG_FILE], so it can show  in screen as well as it store the info in LOG_FILE too.

# creating LOGS_FOLDER so, we can store our logs in it. [-p -> means, if same folder already created also it wont give error]
mkdir -p $LOGS_FOLDER
# script starting date and time, so easy like like which script executes at what time and need to store in LOG_FILE
echo "Script started and executed at: $(date)" | tee -a $LOG_FILE

App_Name=frontend

#checking app is running with root access or not and calling function
check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e " $R ERROR:: Please run the shell script with root user $N" | tee -a $LOG_FILE # here $R which starts colour as Red, and at ending $N ll make it as Normal.
        exit 1 # give other than zero[1-127] as exit code, so it ll not move forward from this step.
    else
        echo "You are running with root user" | tee -a $LOG_FILE

    fi
}

#Disabling nginx
dnf module disable nginx -y &>>$LOG_FILE


#Enabling nginx version 1.24
dnf module enable nginx:1.24 -y &>>$LOG_FILE


#Installing nginx
dnf install nginxxxx -y &>>$LOG_FILE


#enabling nginx
systemctl enable nginx &>>$LOG_FILE


#Start nginx
systemctl start nginx &>>$LOG_FILE


# Removing default content present in the html folder
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE


#Downloading frontend code
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE


#Unziping frontend code in html folder
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE


#Removing default content present in the nginx.conf file
rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE


#Adding new content to nginx to frontend with app tier connections
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf


#Restart nginx
systemctl restart nginx 


# endtime of script
print_time