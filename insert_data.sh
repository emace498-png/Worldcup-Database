#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
TRUNCATE=$($PSQL "TRUNCATE teams, games")
if [[ $TRUNCATE == 'TRUNCATE TABLE' ]]
then
  echo TRUNCATED ALL TABLES!
fi
while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
    [[ "$YEAR" == "YEAR" ]] && continue
    [[ "$WINNER" == "winner" ]] && continue
    [[ "$OPPONENT" == "opponent" ]] && continue

    for team in "$WINNER" "$OPPONENT"; do
        result=$($PSQL "INSERT INTO teams(name) VALUES('$team') ON CONFLICT (name) DO NOTHING")
        [[ "$result" == "INSERT 0 1" ]] && echo "Inserted $team"
    done
    [[ "$YEAR" == "YEAR" ]] && continue
    [[ "$WINNER" == "winner" ]] && continue
    [[ "$OPPONENT" == "opponent" ]] && continue

    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    result=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR','$ROUND','$winner_id','$opponent_id','$WINNER_GOALS','$OPPONENT_GOALS')")
    [[ "$result" == "INSERT 0 1" ]] && echo "Inserted game: $YEAR, round: $ROUND"
done < games.csv
exit 0