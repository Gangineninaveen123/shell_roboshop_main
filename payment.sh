#!/bin/bash
source ./commoncode.sh
#appname or module name
App_Name=payment

#checking app is running with root access or not and calling function
check_root




#app setup
#Creating system user roboshop to run the roboshop app
#while, running it on second time, i got an error at system user gort failed, so using idempotency : sol for this is idempotency->, which irrespective of the number of times you run, nothing changes
app_setup

#python setup
python_setup

#sytem d setup
systemd_setup

# endtime of script
print_time

