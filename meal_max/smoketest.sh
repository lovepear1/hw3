#!/bin/bash

# Define the base URL for the Flask API
BASE_URL="http://localhost:9000/api"

# Function to echo JSON responses if needed
ECHO_JSON=false

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
  case $1 in
    --echo-json) ECHO_JSON=true ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

###############################################
#
# Health checks
#
###############################################

check_health() {
  echo "Checking health status..."
  curl -s -X GET "$BASE_URL/health" | grep -q '"status": "healthy"'
  if [ $? -eq 0 ]; then
    echo "Service is healthy."
  else
    echo "Health check failed."
    exit 1
  fi
}

# Function to check the database connection
check_db() {
  echo "Checking database connection..."
  curl -s -X GET "$BASE_URL/db-check" | grep -q '"database_status": "healthy"'
  if [ $? -eq 0 ]; then
    echo "Database connection is healthy."
  else
    echo "Database check failed."
    exit 1
  fi
}


clear_catalog() {
  echo "Clearing the playlist..."
  curl -s -X DELETE "$BASE_URL/clear-catalog" | grep -q '"status": "success"'
}


###############################################
#
# Meal Management
#
###############################################

create_meal() {
  meal_name=$1
  cuisine=$2
  price=$3
  difficulty=$4

  echo "Adding meal ($meal_name - $cuisine, $price) to the kitchen..."
  curl -s -X POST "$BASE_URL/create-meal" -H "Content-Type: application/json" \
    -d "{\"meal\":\"$meal_name\", \"cuisine\":\"$cuisine\", \"price\":$price, \"difficulty\":\"$difficulty\"}" | grep -q '"status": "combatant added"'

  if [ $? -eq 0 ]; then
    echo "Meal added successfully."
  else
    echo "Failed to add meal."
    exit 1
  fi
}

delete_meal_by_id() {
  meal_id=$1

  echo "Deleting meal by ID ($meal_id)..."
  response=$(curl -s -X DELETE "$BASE_URL/delete-meal/$meal_id")
  if echo "$response" | grep -q '"status": "meal deleted"'; then
    echo "Meal deleted successfully by ID ($meal_id)."
  else
    echo "Failed to delete meal by ID ($meal_id)."
    exit 1
  fi
}

get_meal_by_id() {
  meal_id=$1

  echo "Retrieving meal by ID ($meal_id)..."
  response=$(curl -s -X GET "$BASE_URL/get-meal-by-id/$meal_id")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal retrieved successfully by ID ($meal_id)."
    if [ "$ECHO_JSON" = true ]; then
      echo "Meal JSON (ID $meal_id):"
      echo "$response" | jq .
    fi
  else
    echo "Failed to retrieve meal by ID ($meal_id)."
    exit 1
  fi
}

get_meal_by_name() {
  name_id=$1
  echo "Retrieving meal by name ($name_id)..."
  response=$(curl -s -X GET "$BASE_URL/get-meal-by-name/$name_id")

  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal retrieved successfully by name ($name_id)."
    if [ "$ECHO_JSON" = true ]; then
      echo "Meal JSON: (ID $name_id)"
      echo "$response" | jq .
    fi
  else
    echo "Failed to retrieve meal by name ($name_id)."
    exit 1
  fi
}


###############################################
#
# Battle Management
#
###############################################

prep_combatant() {
  meal=$1

  echo "Prepping combatant for battle: $meal"
  response=$(curl -s -X POST "$BASE_URL/prep-combatant" \
    -H "Content-Type: application/json" -d "{\"meal\":\"$meal\"}")

  if echo "$response" | grep -q '"status": "combatant prepared"'; then
    echo "Meal prepped successfully."
    if [ "$ECHO_JSON" = true ]; then
      echo "Meal JSON:"
      echo "$response" | jq .
    fi
  else
    echo "Failed to prep meal for battle."
    exit 1
  fi
}

clear_combatants() {
  echo "Clearing combatants..."
  response=$(curl -s -X POST "$BASE_URL/clear-combatants")

  if echo "$response" | grep -q '"status": "combatants cleared"'; then
    echo "Combatants cleared successfully."
  else
    echo "Failed to clear combatants."
    exit 1
  fi
}



start_battle() {
  echo "Initiating a battle..."
response=$(curl -s -X GET "$BASE_URL/battle")

  if echo "$response" | grep -q '"status": "battle complete"'; then
    echo "Battle completed."
    if [ "$ECHO_JSON" = true ]; then
      echo "Battle JSON:"
      echo "$response" | jq .
    fi
  else
    echo "Failed to carry out the battle."
    exit 1
  fi
}


get_leaderboard() {
  echo "Retrieving leaderboard..."
  response=$(curl -s -X GET "$BASE_URL/leaderboard")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Leaderboard retrieved successfully."
    if [ "$ECHO_JSON" = true ]; then
      echo "Leaderboard JSON:"
      echo "$response" | jq .
    fi
  else
    echo "Failed to retrieve leaderboard."
    exit 1
  fi
}

###############################################
#
# Execute Smoke Tests
#
###############################################

# Health check
check_health
check_db
clear_catalog

# Meal creation
create_meal "Spaghetti" "Italian" 10 "MED"
create_meal "Burger" "American" 8 "LOW"
create_meal "Sushi" "Japanese" 12 "HIGH"

# Get meals
get_meal_by_id 1
get_meal_by_name "Sushi"

# Prep two meals for battle
clear_combatants
prep_combatant "Spaghetti"
prep_combatant "Burger"

# Start battle
start_battle
clear_combatants
# Get leaderboard
get_leaderboard

# Clean up - delete meals
delete_meal_by_id 1
delete_meal_by_id 2
delete_meal_by_id 3

echo "All smoketests completed successfully!"
