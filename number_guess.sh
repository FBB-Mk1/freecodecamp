#!/bin/bash
# Number Guessing Game
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( $RANDOM % 1000 + 1 ))

GUESSING_LOOP(){
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    (( GUESSES++ ))
    if [[ $1 > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read NEW_GUESS
      GUESSING_LOOP $NEW_GUESS
    elif [[ $1 < $NUMBER  ]]
    then
      echo "It's higher than that, guess again:"
      read NEW_GUESS
      GUESSING_LOOP $NEW_GUESS
    else
      echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
    fi
  else
    echo "That is not an integer, guess again:"
    read NEW_GUESS
    GUESSING_LOOP $NEW_GUESS
  fi
}

echo "Enter your username:"
read USERNAME

# CHECK IF NEW OR RETURNING USER
RETURN_USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")
# IF NEW THEN REGISTER ON DB
if [[ -z $RETURN_USER ]]
then
  NEW=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
fi

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
if [[ -z $GAMES_PLAYED ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# START GUESSING LOOP
echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESSING_LOOP $GUESS
# end of loop

(( GAMES_PLAYED++ ))
if [[ -z $BEST_GAME ]]
then
  BEST_GAME=$GUESSES
elif [[ $GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$GUESSES
fi
#commit to db and finish
COMMIT=$($PSQL "UPDATE users SET games_played='$GAMES_PLAYED', best_game='$BEST_GAME' WHERE username='$USERNAME';")
