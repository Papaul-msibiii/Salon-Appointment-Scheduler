#!/bin/bash

# Connect to salon database
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display services
DISPLAY_SERVICES() {
    echo -e "\n~~~~~ MY SALON ~~~~~"
    echo -e "\nWelcome to My Salon, how can I help you?"

    $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS='|' read SERVICE_ID SERVICE_NAME; do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
    echo
}

# Main script
MAIN() {
    # Display services
    DISPLAY_SERVICES

    # Get service selection
    read SERVICE_ID_SELECTED

    # Validate service selection
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]; then
        echo "I could not find that service. What would you like today?"
        MAIN
        return
    fi

    # Prompt for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # If customer doesn't exist, get name and insert
    if [[ -z $CUSTOMER_ID ]]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    # Get appointment time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Confirm appointment
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Run main script
MAIN