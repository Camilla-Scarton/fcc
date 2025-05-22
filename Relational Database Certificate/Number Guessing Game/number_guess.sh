#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(echo $((1 + $RANDOM % 1000)))
#echo $NUMBER

echo -e "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT * FROM players WHERE username='$USERNAME'")

if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
else
  USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")

  USER=$($PSQL "SELECT username FROM players WHERE user_id=$USER_ID")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID GROUP BY user_id")
  BEST_GAME=$($PSQL "SELECT MIN(number_guess) FROM games WHERE user_id=$USER_ID GROUP BY user_id")

  echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "Guess the secret number between 1 and 1000:"
GUESS_NUMBER=0

while read INPUT
do
  ((GUESS_NUMBER++))
  if [[ (-z $INPUT) || (! $INPUT =~ ^[0-9]+$) ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $INPUT == $NUMBER ]]
    then
      echo "You guessed it in $GUESS_NUMBER tries. The secret number was $NUMBER. Nice job!"

      USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")
      UPDATE_GAME=$($PSQL "INSERT INTO games(user_id, number_guess) VALUES($USER_ID, $GUESS_NUMBER)")
      break
    elif [[ $INPUT > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done
