#!/bin/bash
source ./commoncode.sh

App_Name=shipping

#checking app is running with root access or not and calling function
check_root

#Setting up shipping ROOT PASSWORD - RoboShop@1
echo "Please enter the root password"
read -s MYSQL_ROOT_PASSWORD
echo -e "$MYSQL_ROOT_PASSWORD"



#app setup
#Creating system user roboshop to run the roboshop app
#while, running it on second time, i got an error at system user gort failed, so using idempotency : sol for this is idempotency->, which irrespective of the number of times you run, nothing changes
app_setup


#maven setup calling
maven_setup

#Copying of Setup SystemD Shipping Service
systemd_setup

# installing mysql client. We need to load the schema to mysql db
dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Installing MYSQL client"

#loading data to mysql db by the help of below query
mysql -h mysql.muruga.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if [ $? -ne 0 ]
then
    #Load Schema, Schema in database is the structure to it like what tables to be created and their necessary application layouts.
    mysql -h mysql.muruga.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql  &>> $LOG_FILE
    # Create app user, MySQL expects a password authentication, Hence we need to create the user in mysql database for shipping app to connect.
    mysql -h mysql.muruga.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>> $LOG_FILE
    #Load Master Data, This includes the data of all the countries and their cities with distance to those cities.
    mysql -h mysql.muruga.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>> $LOG_FILE
    VALIDATE $? "Loading data into mysql"
else
    echo -e "Data is already loaded into mysql DB.. $Y SKIPPING $N"
fi



#Restarting shipping
systemctl restart shipping &>> $LOG_FILE
VALIDATE $? "Restarting shipping"

# endtime of script
print_time

