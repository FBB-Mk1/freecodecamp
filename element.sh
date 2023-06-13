#!/bin/bash
#Search for data on an element of the periodic table from a provided argument
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
else
  # SEARCH AND OUTPUT LOGIC
  # CHECK IF ARGUMENT IS NUMBER
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # SEARCH DATABASE WITH ATOMIC_NUMBER
    RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types on properties.type_id=types.type_id WHERE elements.atomic_number=$1 ;")
  else
    # TRY AS SYMBOL
    RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types on properties.type_id=types.type_id WHERE elements.symbol='$1' ;")
    if [[ -z $RESULT ]]
    then
      # TRY IS NAME
      RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types on properties.type_id=types.type_id WHERE elements.name='$1' ;")
    fi
  fi
  # CHECK IF A RESULT WAS FOUND
  if [[ -z $RESULT ]]
  then
  echo -e "I could not find that element in the database."
    else
      echo "$RESULT" | while IFS='|' read ATOMIC_NUMBER SYMBOL NAME ATOMIC_NUMBER ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID TYPE_ID TYPE
      do
        echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      done
  fi
fi
