#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n*******Fresh Cuts******\n"

MAIN_MENU() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo $1
  echo "$SERVICES" | while read LIST_SERVICE_ID BAR LIST_SERVICE_NAME
  do
    echo "$LIST_SERVICE_ID) $LIST_SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Please enter a number."
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    
    if [[ -z $SERVICE_NAME ]]; then
      MAIN_MENU "Invalid service. Please select a valid service"
    else
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      if [[ -z $CUSTOMER_NAME ]]; then
        while [[ -z $CUSTOMER_NAME ]] 
        do
          echo -e "What is your name?"
          read CUSTOMER_NAME
        done
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nEnter a time for your appointment"
      read SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]; then
        NAME_FMT=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
        SERVICE_FMT=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
        echo -e "I have put you down for a $SERVICE_FMT at $SERVICE_TIME, $NAME_FMT."
      fi
    fi
  fi
}

MAIN_MENU "Welcome please select a service."