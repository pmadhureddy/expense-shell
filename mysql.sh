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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL-server"     

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled MySQL server"     

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Started MySQL server"     

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
VALIDATE $? "Setting up root password"     


