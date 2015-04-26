# Script for printing from your own machine using the remote computer

# TODO: more options for example grayscale/color jobs. 
# It's tricky because each printer has different commands

# TODO: more printers with nicknames for easier use

#!/bin/sh

# variables
FILENAME="$1"
PRINTER="$2"
SIDES="y"
COLOR="n"

# checks if printer is set, else prompt 
if [[ -z "$PRINTER" ]]; then 
	printf "Skrivare: ";
	read PRINTER;
fi

# looks for codenames
if [[ "$PRINTER" = "torget" ]]; then
	PRINTER="f-7207b-color1"
elif [[ "$PRINTER" = "dd" ]]; then
	PRINTER="ft-4011-laser3"
elif [[ "$PRINTER" = "bulten" ]]; then
	PRINTER="m-1117-laser2"	
fi

# promps for duplex
printf "Dubbelsidigt? (y,n): "
read SIDES
if [[ "$SIDES" = "n" ]]; then
	SIDES="one-sided"
else
	SIDES="two-sided-long-edge"
fi

# promps for username
printf "CID: "
read CID

# command for printing
ssh $CID@remote11.chalmers.se lpr -o "sides=$SIDES" -P "$PRINTER" < "$FILENAME"	