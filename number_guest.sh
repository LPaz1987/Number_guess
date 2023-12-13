#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN() {
echo "Enter your username:"
read USERNAME
MIN=1
MAX=1000
RANDOM_NUMBER=$(($RANDOM%($MAX-MIN+1)+$MIN))
echo $RANDOM_NUMBER
declare -i TRIES=0
#check username
CHECK_USER=$($PSQL "select name from users where name = '$USERNAME'")

if [[ -z $CHECK_USER ]];then
	INSERT_USER=$($PSQL "insert into users(name) values('$USERNAME')")
	echo "Welcome, $USERNAME! It looks like this is your first time here."
	GUESS
else
	GAMES_PLAYED=$($PSQL "select games_played from users where name = '$USERNAME'")
	BEST_GAME=$($PSQL  "select best_game from users where name = '$USERNAME'")
	echo $BEST_GAME
	echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
	GUESS

fi
}

GUESS() {
	echo "Guess the secret number between 1 and 1000:"
	read NUMBER_SELECTED
	TRIES=$TRIES+1
	while [ $NUMBER_SELECTED != $RANDOM_NUMBER ]
		do
			if ! [[ $NUMBER_SELECTED =~ ^[0-9]+$ ]]
				then
					echo "That is not an integer, guess again:"
					read NUMBER_SELECTED
				elif [[ $NUMBER_SELECTED -gt $RANDOM_NUMBER ]];then
					echo "It's lower than that, guess again:"
					read NUMBER_SELECTED
					TRIES=$TRIES+1
					
				elif [[ $NUMBER_SELECTED -lt $RANDOM_NUMBER ]];then
					echo "It's higher than that, guess again:"
					read NUMBER_SELECTED
					TRIES=$TRIES+1
								
			fi
		done
		echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
		
		GET_GAMES_PLAYED=$($PSQL "SELECT games_played from users where name = ('$USERNAME')")
		
		if [[ -z $GET_GAMES_PLAYED ]];then
			INSERT_GAMES_PLAYED=$($PSQL "update users set games_played = 1 WHERE name = '$USERNAME' ")
		else
			ADD_GAMES=$GET_GAMES_PLAYED+1
			
			UPDATE_GAMES_PLAYED=$($PSQL "update users set games_played = $ADD_GAMES WHERE name = '$USERNAME' ")
		fi

		CHECK_BEST_GAME=$($PSQL "select best_game from users where name = '$USERNAME'")
		if [[ -z $CHECK_BEST_GAME ]];then
			INSERT_BEST_GAME=$($PSQL "update users set best_game = ('$TRIES') WHERE name = '$USERNAME' ")
		elif [[  $TRIES  -lt $CHECK_BEST_GAME ]];then
			UPDATE_BEST_GAME=$($PSQL "update users set best_game = ('$TRIES') where name = '$USERNAME' ")
		fi

}
MAIN
