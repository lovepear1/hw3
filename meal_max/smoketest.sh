#!/bin/bash

# Define the base URL for the Flask API
BASE_URL="http://localhost:5000/api"

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
    -d "{\"meal\":\"$meal_name\", \"cuisine\":\"$cuisine\", \"price\":$price, \"difficulty\":\"$difficulty\"}" | grep -q '"status": "success"'

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
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal deleted successfully by ID ($meal_id)."
  else
    echo "Failed to delete meal by ID ($meal_id)."
    exit 1
  fi
}

get_all_meals() {
  echo "Getting all meals in the kitchen..."
  response=$(curl -s -X GET "$BASE_URL/get-all-meals")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "All meals retrieved successfully."
    if [ "$ECHO_JSON" = true ]; then
      echo "Meals JSON:"
      echo "$response" | jq .
    fi
  else
    echo "Failed to get meals."
    exit 1
  fi
}

###############################################
#
# Battle Management
#
###############################################

prep_combatant() {
  meal_id=$1

  echo "Prepping meal with ID $meal_id for battle..."
  response=$(curl -s -X POST "$BASE_URL/prep-combatant/$meal_id")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal prepped for battle successfully."
  else
    echo "Failed to prep meal for battle."
    exit 1
  fi
}

start_battle() {
  echo "Starting battle between the prepped meals..."
  response=$(curl -s -X POST "$BASE_URL/start-battle")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Battle completed successfully."
    if [ "$ECHO_JSON" = true ]; then
      echo "Battle Result JSON:"
      echo "$response" | jq .
    fi
  else
    echo "Failed to start battle."
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

# Meal creation
create_meal "Spaghetti" "Italian" 10 "MED"
create_meal "Burger" "American" 8 "LOW"
create_meal "Sushi" "Japanese" 12 "HIGH"

# Get all meals
get_all_meals

# Prep two meals for battle
prep_combatant 1
prep_combatant 2

# Start battle
start_battle

# Get leaderboard
get_leaderboard

# Clean up - delete meals
delete_meal_by_id 1
delete_meal_by_id 2
delete_meal_by_id 3

echo "All smoketests completed successfully!"
