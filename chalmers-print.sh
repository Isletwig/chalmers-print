# Script for printing from your own machine using the remote computer

# TODO: more options for example grayscale/color jobs. 
# It's tricky because each printer has different commands

# TODO: more printers with nicknames for easier use

#!/bin/sh

# variables
FILENAME="$1"
PRINTER="$2"
COPIES=1
SIDES="y"
PAGES="y"

# checks if file is set, else prompt 
if [[ -z "$FILENAME" ]]; then 
	printf "Path to file: ";
	read FILENAME;
fi

# checks if printer is set, else prompt 
if [[ -z "$PRINTER" ]]; then 
	printf "Skrivare: ";
	read PRINTER;
fi

# looks for nicknames
if [[ "$PRINTER" = "torget" ]]; then
	PRINTER="f-7207b-color1"
elif [[ "$PRINTER" = "dd" ]]; then
	PRINTER="ft-4011-laser3"
elif [[ "$PRINTER" = "bulten" ]]; then
	PRINTER="m-1117-laser2"	
elif [[ "$PRINTER" = "fb" ]]; then
	PRINTER="f-7105a-laser1"
fi

# number of copies
printf "Number of copies: "
read COPIES

# range of pages
printf "Print all pages (y,n):"
read PAGES
# if not all pages, select range of pages
if [[ "$PAGES" = "n" ]]; then
	printf "Choose range of pages (ex: 1-2 or 1-2,5): "
	read PAGES
fi

# promps for duplex
printf "Duplex? (y,n): "
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
ssh $CID@remote11.chalmers.se lpr -#"$COPIES" -o "page-ranges=$PAGES" -o "sides=$SIDES" -P "$PRINTER" < "$FILENAME"
