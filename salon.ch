#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ -z $1 ]]
  then
    echo -e "\nWelcome to My Salon, how can I help you?"
  else
    echo -e "\n$1"
  fi
  SERVICES_RETURNED=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES_RETURNED"  | while IFS="|" read SERVICE_ID_SELECTED CUSTOMER_NAME
  do
    echo "$SERVICE_ID_SELECTED) $CUSTOMER_NAME"
  done
  read SERVICE_ID_SELECTED
  #check if valid
  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    #check for service id
    SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    #if valid
    if [[ -z $SERVICE_ID_SELECTED ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
    # get phone
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    USER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # check if valid
    if [[ -z $USER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      RETURN_NEW_USER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      USER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$USER_ID'")
    
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    
    RETURN_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values('$USER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")
    if [[ -z $RETURN_NEW_APPOINTMENT ]]
    then
      MAIN_MENU "We could not set your appointment, try again"
    else
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
    #if [[ -z $RETURN_USER_ID ]]
    #then

    #fi
    # if not, register

    #get time of appointment
    
    #register appointment
    
    #leave
    fi
  fi
}

MAIN_MENU
