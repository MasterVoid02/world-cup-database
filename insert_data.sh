#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $TEAM_ID ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    fi 
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $TEAM_ID ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID")
    if [[ -z $GAME_ID ]]
    then
      echo $($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)")
    fi
  fi
done
