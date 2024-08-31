#!/bin/bash


LOGS_FOLDER="/var/logs/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER


USERID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"


echo "Script started excecuting at: $(date)" | tee -a $LOG_FILE


VALIDATE(){

    if [ $1 -ne 0 ]
    then echo -e "$2 is ..... $R Failed $N" | tee -a $LOG_FILE
         exit 1
    else
        echo -e "$2 is .... $G succcess $N" | tee -a $LOG_FILE
    fi         
}

if [ $USERID -ne 0 ]
then
   echo "please run this script with root privileges" | tee -a $LOG_FILE
   exit 1
fi  

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default node js"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodej:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install node js" 

id expense &>>$LOG_FILE

if [ $? -ne 0 ]
then
   echo -e "Expense user is not exist. $G So, Creating... $N"
   useradd expense &>>$LOG_FILE 
   VALIDATE $? "Creating Expense User" 
else 
   echo -e "Expense User already exist... $Y Skipping... $N"
fi   

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app folder" 


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading Backend app Code" 

cd /app

rm -rf /app/* #Removing the existing code

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting Backend app Code" 



npm install &>>$LOG_FILE
VALIDATE $? "Installing the dependencies..." 

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service


#Load the DB data before running backend


dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing the MYSQL..." 

mysql -h mysql.daws81.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Schema loading..." 

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload..." 

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabled Backend..." 

  
systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarted Backend..." 





