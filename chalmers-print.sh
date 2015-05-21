# Script for printing from your own machine using the remote computer

#!/bin/sh

# variables
FIRST="$1"
SECOND="$2"

FILENAME=""
PRINTER=""
COPIES=1
SIDES="y"
PAGES="y"
OPTIONS=""

# Printer information
NICKS=("torget" "dd" "fb" "bulten")
PRINTER_NAME=("f-7207b-color1" "ft-4011-laser3" "f-7105a-laser1" "m-1117-laser2")
PRINTER_DESCRIPTION=("Forskarhuset lvl 7, pantry" "Computer room physics (new Djungel Data)" "Physics building lvl 7 next to FB" "Study hall next to Bulten")

if [[ "$FIRS"="nicklist" ]]; then
	for index in ${!NICKS[*]}; do
		printf "%s\t %s\t %s\n" ${NICKS[$index]} ${PRINTER_NAME[$index]} "${PRINTER_DESCRIPTION[$index]}"
	done
	exit 0
fi

# checks if file is set, else prompt 
if [[ -z "$FIRST" ]]; then 
	printf "Path to file: ";
	read FILENAME;
else
	FILENAME="$FIRST"
fi

# checks if printer is set, else prompt 
if [[ -z "$SECOND" ]]; then 
	printf "Skrivare: ";
	read PRINTER;
else
	PRINTER="$SECOND"
fi

# number of copies
printf "Number of copies: "
read COPIES
OPTIONS="-#$COPIES"

# range of pages
printf "Print all pages (y,n):"
read PAGES
# if not all pages, select range of pages
if [[ "$PAGES" = "n" ]]; then
	printf "Choose range of pages (ex: 1-2 or 1-2,5): "
	read PAGES
	OPTIONS="$OPTIONS -o page-ranges=$PAGES"
fi

# promps for duplex
printf "Duplex? (y,n): "
read SIDES
if [[ "$SIDES" = "n" ]]; then
	SIDES="one-sided"
else
	SIDES="two-sided-long-edge"
fi
OPTIONS="$OPTIONS -o sides=$SIDES"

# looks for nicknames and askes for printer specific options
if [ "$PRINTER" = "torget" ] || [ "$PRINTER" = "f-7207b-color1" ]; then
	PRINTER="f-7207b-color1"
	
	printf "Color? (y,n): "
	read COLOR

	if [[ "$COLOR" = "n" ]]; then
		COLOR="Gray"
	else
		COLOR="CMYK"
	fi
	OPTIONS="$OPTIONS -o ColorModel=$COLOR"

	printf "Stapled? (y,n): "
	read STAPLES

	# staples put on up to the left
	if [[ "$STAPLES" = "y" ]]; then
		STAPLES="UpperLeft"
		OPTIONS="$OPTIONS -o StapleLocation=$STAPLES"
	fi

elif [[ "$PRINTER" = "dd" ]]; then
	PRINTER="ft-4011-laser3"
elif [[ "$PRINTER" = "bulten" ]]; then
	PRINTER="m-1117-laser2"	
elif [[ "$PRINTER" = "fb" ]]; then
	PRINTER="f-7105a-laser1"
fi

# promps for username
printf "CID: "
read CID

# command for printing
ssh $CID@remote11.chalmers.se lpr "$OPTIONS" -P "$PRINTER" < "$FILENAME"
