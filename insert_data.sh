#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"

# Clear existing data
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;"

# Read the CSV file
cat games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the header row
  if [[ $YEAR != "year" ]]
  then
    # Insert winner team if not exists
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    if [[ -z $WINNER_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER');" >/dev/null
    fi

    # Insert opponent team if not exists
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    if [[ -z $OPPONENT_ID ]]
    then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');" >/dev/null
    fi

    # Get the team IDs
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    # Insert the game
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);" >/dev/null
  fi
done
