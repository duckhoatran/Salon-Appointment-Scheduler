#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"


SERVICES_MENU(){

AVAILABLE_SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")"
echo -e "\nHere are the services we have available:\n"
#Print list of available service
echo "$AVAILABLE_SERVICES" | tr -d '|' | while read SERVICE_ID NAME
  do
  echo "$SERVICE_ID) $NAME"
  done
#Get service chosen by customer
read SERVICE_ID_SELECTED
 # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    SERVICES_MENU
  else
    # get service availability
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if not available
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
    # send to main menu
    SERVICES_MENU
    else 
      # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      fi
      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # get service time
      SERVICE_NAME_CHOSE=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
      echo -e "\nWhat time would you like your$SERVICE_NAME_CHOSE, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # insert new customer
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME_CHOSE at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
  fi

}
SERVICES_MENU
