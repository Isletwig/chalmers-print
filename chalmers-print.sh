# Script for printing from your own machine using the remote computer

#!/bin/sh


#............... Variables .....................

# script intformation
VERSION="v1.0"

# arguments
FIRST="$1"
SECOND="$2"

# print specific
FILENAME=""
PRINTER=""
COPIES=1
SIDES="y"
PAGES="y"
OPTIONS=""

# printer information
NICKS=("torget" "dd" "fb" "bulten")
PRINTER_NAME=("f-7207b-color1" "ft-4011-laser3" "f-7105a-laser1" "m-1117-laser2")
PRINTER_DESCRIPTION=("Forskarhuset lvl 7, pantry" "Computer room physics (new Djungel Data)" "Physics building lvl 7 next to FB" "Study hall next to Bulten")

# makes all string comparisons non case sensitive
shopt -s nocasematch

#............... Startup commands ..................

# Installation 

# if install command is requested
if [[ "$FIRST" = "install" ]]; then
	
	# the name of this script
	me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
	# create name of installation directory
	directory="/Applications/Chprint"
	# name of alias
	alias_name="chprint"

	# find profile file
	if [[ ! -s "$HOME/.bash_profile" && -s "$HOME/.profile" ]] ; then
  		profile_file="$HOME/.profile"
	else
  		profile_file="$HOME/.bash_profile"
	fi

	# create installation directory
	mkdir -p "$directory"
	# move script file to installation directory
	cp ./$me "$directory/$me"

	# check if alias exist
	if grep -q 'chprinttest' "${profile_file}" ; then
		# Remove old alias
		sed -i '' '/chprinttest/d' $profile_file
	fi
	# add new alias
	echo "alias $alias_name='$directory/$me'" >> $profile_file

	# delete old file if it exist
	rm -f $HOME/chalmers-print.sh

	# terminate script
	exit 0
fi

# Update

# checks for updates and automatically download the latest version
if [[ "$FIRST" = "update" ]]; then
	update_answer="n"

	# finds the url to the latest realease
	latets_url=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/Isletwig/chalmers-print/releases/latest)
	# extract the version number from the url
	latest_version="${latets_url//[!0-9]/}"
	# cleans the version string to a number
	current_version="${VERSION//[!0-9]/}"

	# if the latets version is installed
	if [[ "$latest_version" -gt "$current_version" ]]; then
		# askes if the user would like to install the latest realease
		printf "%s\n" "There is a newer realease ready for download." "Do you like to automatically update? (y,n): "
		read update_answer
	else
		# no need for updating
		printf "%s\n" "You are currently running ($VERSION) which is the latest version."
	fi

	# terminate script
	exit 0
fi

# Printlist command

# if prinlist command is requested
if [[ "$FIRST" = "nicklist" ]]; then
	for index in ${!NICKS[*]}; do
		printf "%s\t %s\t %s\n" ${NICKS[$index]} ${PRINTER_NAME[$index]} "${PRINTER_DESCRIPTION[$index]}"
	done

	# terminate script
	exit 0
fi


#................. Welcome screen ......................

printf "%s\n" "" "" "" ""
printf "%s\t%s\t%s\t%s\n" "" "" "" "Welcome to Chalmers Print!"
printf "%s\t%s\t%s\t%s\t%s\n%s\n" "" "" "" "" "$VERSION" ""

#................. Collect print information .....................

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


#................. Printer specific options ..................

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


#..................... Login ....................
# promps for username
printf "CID: "
read CID


#.................... Printing ..................

# command for printing
ssh $CID@remote11.chalmers.se lpr "$OPTIONS" -P "$PRINTER" < "$FILENAME"
