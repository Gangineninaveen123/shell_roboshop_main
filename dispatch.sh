#!/bin/bash
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

# Checking user has root previlages to run or not
if [ $USERID -ne 0 ]
then
    echo -e " $R ERROR:: Please run the shell script with root user $N" | tee -a $LOG_FILE # here $R which starts colour as Red, and at ending $N ll make it as Normal.
    exit 1 # give other than zero[1-127] as exit code, so it ll not move forward from this step.
else
    echo "You are running with root user" | tee -a $LOG_FILE

fi

#, here $1 -> means takes exit code $? as input $2 argument, which is given in the code, while calliong function

VALIDATE()
{
     if [ $1 -eq 0 ]  # the exit code represents always sucess
    then
        echo -e " $2 is $G  Sucessfull.... $N" | tee -a $LOG_FILE
    else
        echo -e " $2 $R  is failure.... $N" | tee -a $LOG_FILE
        exit 1 # when ever the failure is there in shell script, then we should automatically give exit than zero, mainly 1
    fi
}

#Creating system user roboshop to run the roboshop app
#while, running it on second time, i got an error at system user gort failed, so using idempotency : sol for this is idempotency->, which irrespective of the number of times you run, nothing changes

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user roboshop"
else
    echo -e "System user roboshop already created ... $Y Skipping $N"
fi


# Creating app directory to store our user code info
mkdir -p /app # if already create also, it ll not show error at run time [-p]
VALIDATE $? "Creating app directory"

#Downloading dispatch code in tmp folder
curl -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading user code"

#Unzipping dispatch code info into app directory
rm -rf /app/* # i am deleteing the content in app directory, because in log files , its asking for oveeride the previous content, so simply ll delete the data, so no ovveride needed.
cd /app 
unzip /tmp/dispatch.zip &>>$LOG_FILE
VALIDATE $? "Unzipping payment code info into app directory"

#downloading the dependencies & build the software.
cd /app 
go mod init dispatch
go get 
go build
VALIDATE $? "Downloading dependencies of dispatch"

#setup a new service in systemd so systemctl can manage this service for dispatch server
cp $SCRIPT_DIR/12-dispatch.service /etc/systemd/system/dispatch.service &>>$LOG_FILE

#Daemon reload tp tll the systemd that dispactch servies has been added so need to re load
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading daemon service"

#Enable and starting services
systemctl enable dispatch &>>$LOG_FILE
systemctl start dispatch &>>$LOG_FILE
VALIDATE $? "Enable and starting server of dispatch"
