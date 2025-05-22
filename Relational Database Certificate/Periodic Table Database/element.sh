PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

: <<'END_COMMENT'
# UPDATE type_id
ELEMENTS=$($PSQL "SELECT atomic_number, type, types.type_id FROM properties FULL JOIN elements USING(atomic_number) FULL JOIN types USING(type_id)")

echo "$ELEMENTS" | while read ATOMIC_NUMBER BAR TYPE BAR TYPE_ID
do
  echo "$ATOMIC_NUMBER - $TYPE with type_id=$TYPE_ID"
  UPDATE_RESULT=$($PSQL "UPDATE properties SET type_id=$TYPE_ID WHERE atomic_number=$ATOMIC_NUMBER")
  echo $UPDATE_RESULT
done

# Capitalize symbol in elements
ELEMENTS=$($PSQL "SELECT atomic_number, symbol FROM elements")
echo "$ELEMENTS" | while read ATOMIC_NUMBER BAR SYMBOL
do
  echo "$ATOMIC_NUMBER - $SYMBOL"

  FORMATTED_SYMBOL=$(echo $SYMBOL | sed -E 's/^(.)/\U\1/')
  
  UPDATE_RESULT=$($PSQL "UPDATE elements SET symbol='$FORMATTED_SYMBOL' WHERE atomic_number=$ATOMIC_NUMBER")
  echo $UPDATE_RESULT
done

# REMOVE TRAILING ZEROS after decimal for atomic_mass in properties
# ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;
# UPDATE properties SET atomic_mass=trim(trailing '00' FROM atomic_mass::TEXT)::DECIMAL;

# ADD VALUES
# INSERT INTO properties(atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES(9, 18.998, -220, -188.1, 2), (10, 20.18, -248.6, -246.1, 2);
END_COMMENT

if [[ ! -z $1 ]]
then
  if [[ ! $1 =~ ^[0-9]+$ ]] 
  then
    ELEMENTS=$($PSQL "SELECT * FROM properties FULL JOIN elements USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol='$1' OR name='$1'")
  else
    ELEMENTS=$($PSQL "SELECT * FROM properties FULL JOIN elements USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$1")
  fi

  if [[ ! -z $ELEMENTS ]]
  then
    echo "$ELEMENTS" | while read ATOMIC_NUMBER BAR ATOMIC_NUMBER BAR ATOMIC_MASS BAR MELTING_POINT_CELSIUS BAR BOILING_POINT_CELSIUS BAR SYMBOL BAR NAME BAR TYPE
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius." 
    done
  else
    echo "I could not find that element in the database."
  fi
  
else
  echo "Please provide an element as an argument."
fi
