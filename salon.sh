#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Hairtastic Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  else
    # First message 
    echo -e "\nWelcome to our hair salon. How can I be of help?\n"
  fi

  # Display available services
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # Read user input
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
  then
    # Send to main menu
    MAIN_MENU "Please enter a valid number."
  else
    # Look up service
    LOOK=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # If no such service
    if [[ -z $LOOK ]]
    then
      # Send to main menu
      MAIN_MENU "No such service. Enter a valid service number."
    else
      # Ask for phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # Look up customer 
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # If customer name is not found
      if [[ -z $CUSTOMER_NAME ]]
      then
        # Ask for name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        # Add new customer
        CUST_IN=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # Ask for appointment time
      echo -e "\nWhen would you like your appointment?"
      read SERVICE_TIME

      # Add to appointments
      # Read customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      APP_IN=$($PSQL "INSERT INTO appointments(customer_id,time,service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")

      # Get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      # Format 
      SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
      SERVICE_TIME=$(echo $SERVICE_TIME | sed -E 's/^ *| *$//g')       

      # Message entry
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
