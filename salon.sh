#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services")

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

while true; do
echo -e "$SERVICES" | while IFS="|" read -r SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

read SERVICE_ID_SELECTED

SERVICE_IDS=$($PSQL "SELECT service_id FROM services where service_id=$SERVICE_ID_SELECTED")
if [[ -z $SERVICE_IDS ]]
then
  echo "I could not find that service. What would you like today?"
else
  SERVICE_NAME=$($PSQL "Select name from services where service_id=$SERVICE_ID_SELECTED")
  break
fi
done

echo -e "\nWhat's your phone number?\n"
read CUSTOMER_PHONE

CHECK_PHONE=$($PSQL "SELECT phone FROM customers where phone='$CUSTOMER_PHONE'")

if [[ -z $CHECK_PHONE ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?\n"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')"
  CUSTOMER_ID=$($PSQL "Select customer_id from customers where name='$CUSTOMER_NAME'")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?\n"
  read SERVICE_TIME
  $PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')"

  
  
else
  CUSTOMER_NAME=$($PSQL "Select name from customers where phone='$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?\n"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "Select customer_id from customers where phone='$CUSTOMER_PHONE'")

  $PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')"
  
  

fi

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
