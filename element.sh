
#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]
then
  CONDITION="e.atomic_number = $1"
else
  CONDITION="e.symbol = '$1' OR e.name = '$1'"
fi

ELEMENT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol,
  TRIM(TRAILING '.' FROM TRIM(TRAILING '0' FROM p.atomic_mass::text)),
  t.type, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  WHERE $CONDITION")

if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
else
  echo "$ELEMENT" | while IFS='|' read -r NUMBER NAME SYMBOL MASS TYPE MELTING BOILING
  do
    echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
