#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICE_MENU() {
  
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi


  #get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo -e "\nWelcome to My Salon. How can I help you?"
  #display available services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  #ask for bike to rent
  read SERVICE_ID_SELECTED

  #if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      SERVICE_MENU "That is not a valid service number."
    else
      SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        #if not available
        if [[ -z $SERVICE_AVAILABILITY ]]
          then
            # send to service menu
            SERVICE_MENU "I could not find that service. What would you like today?"
          else
            #get customer info
              echo -e "\nWhat's your phone numbner?"
              read CUSTOMER_PHONE
              CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
                #if customer doesn't exist
                if [[ -z $CUSTOMER_NAME ]]
                  then
                    #get customer name
                    echo -e "I don't have a record for that phone number, what's your name?"
                    read CUSTOMER_NAME

                    #insert new customer
                    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
                fi
              #get customer_id
              CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        # get service time
        echo -e "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME

        #insert an appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        #get info appointment
       
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  fi

}


SERVICE_MENU
