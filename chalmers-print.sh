# Script for printing from your own machine on Chalmers printers using the remote computer

#!/bin/sh


#............... Variables .....................

# script intformation
VERSION="v1.1"

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

#................. Welcome screen ......................

printf "%s\n" "" ""
printf "%s\t%s\t%s\t%s\n" "" "" "" "Chalmers Print"
printf "%s\t%s\t%s\t%s\n%s\n" "" "" "" "     $VERSION" ""


#................. Functions ...........................

# installation function
function install {
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
	if grep -q $alias_name "$profile_file" ; then
		# Remove old alias
		sed -i '' "/$alias_name/d" "$profile_file"
	fi
	# add new alias
	echo "alias $alias_name='$directory/$me'" >> $profile_file

	# delete old file in homefolder if it exist
	rm -f $HOME/chalmers-print.sh

	# end message
	printf "%s\n" "Installation is finished. Please restart your terminal before using." ""

	# terminate script
	exit 0
}

# update up_to_date variable
up_to_date="y"
function check_for_updates {
	# finds the url to the latest realease
	latets_url=$(curl -Ls -I -o /dev/null -w %{url_effective} https://github.com/Isletwig/chalmers-print/releases/latest)
	# locate the versionnumber
	# TODO create a more stable extraction that are independent of lenght
	latest_version="${latets_url: -4}"
	# makes the version number only digits
	latest_version_number="${latest_version//[!0-9]/}"
	# cleans the version string to a number
	current_version_number="${VERSION//[!0-9]/}"

	# check if the system needs to update
	if [[ "$latest_version_number" -gt "$current_version_number" ]]; then
		up_to_date="n"
	fi
}

# warn the user is the current version is old
function old_realease_warning {
	check_for_updates
	if [[ "$up_to_date" = "n" ]]; then
		printf "%s\n" "There is a newer realease of Chalmers Print ($latest_version) ready for download. Please consider updating with update command or manually download from Github." ""
	fi
}


#............... Startup commands ..................

# if install command is requested
if [[ "$FIRST" = "install" ]]; then
	install
fi

# if update command is requested
if [[ "$FIRST" = "update" ]]; then
	update_answer="n"

	# update the up_to_date variable
	check_for_updates

	# check if the system needs to update
	if [[ "$up_to_date" = "n" ]]; then
		# askes if the user would like to install the latest realease
		printf "%s\n" "There is a newer realease ready for download." "Do you like to automatically update? (y,n): "
		read update_answer

		if [[ "$update_answer" = "y" ]]; then
			# create temporary directory
			mkdir -p tmp_directory
			# move to the new directory
			cd tmp_directory

			# information about download
			printf "%s\n" "" "Downloading..." ""
			# download the latest version from Github
			curl -LO https://github.com/Isletwig/chalmers-print/archive/$latest_version.zip
			
			# information about unzipping
			printf "%s\n" "" "Unzipping..." ""
			# unzip the download
			unzip $latest_version.zip
			# move into program directory
			cd chalmers-print-${latest_version:1:3}
			# run the script with install command
			./chalmers-print.sh install
			# remove the temporary directory
			cd ../..
			rm -r tmp_directory
		fi
	else
		# no need for updating
		printf "%s\n" "You are currently running $VERSION which is the latest version." ""
	fi

	# terminate script
	exit 0
fi

# if printlist command is requested
if [[ "$FIRST" = "printlist" ]]; then
	# direct to site with printerlist
	printf "%s\n" "A complete list of printers can be found here: " "" "http://print.chalmers.se/public/showprinters.cgi" "" "Note that not all of these have full customisation yet." ""

	# warn the user for old version
	old_realease_warning

	# terminate script
	exit 0
fi

# if nicklist command is requested
if [[ "$FIRST" = "nicklist" ]]; then
	#informative title
	printf "%s\n" "The following nicknames exist in this version:" ""

	for index in ${!NICKS[*]}; do
		printf "%s\t %s\t %s\n" ${NICKS[$index]} ${PRINTER_NAME[$index]} "${PRINTER_DESCRIPTION[$index]}"
	done

	# adds extra enpty line for easy reading
	printf "%s\n" ""

	# warn the user for old version
	old_realease_warning

	# terminate script
	exit 0
fi

#................. Collect print information .....................

printf "%s\n" "Please answer the following questions about your print job:" ""

# checks if file is set, else prompt 
if [[ -z "$FIRST" ]]; then 
	printf "%s\n" "Path to file: ";
	read FILENAME;
else
	FILENAME="$FIRST"
fi

# checks if printer is set, else prompt 
if [[ -z "$SECOND" ]]; then 
	printf "%s\n" "Skrivare: ";
	read PRINTER;
else
	PRINTER="$SECOND"
fi

# number of copies
printf "%s\n" "Number of copies: "
read COPIES
OPTIONS="-#$COPIES"

# range of pages
printf "%s\n" "Print all pages (y,n):"
read PAGES
# if not all pages, select range of pages
if [[ "$PAGES" = "n" ]]; then
	printf "%s\n" "Choose range of pages (ex: 1-2 or 1-2,5): "
	read PAGES
	OPTIONS="$OPTIONS -o page-ranges=$PAGES"
fi

# promps for duplex
printf "%s\n" "Duplex? (y,n): "
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
	
	printf "%s\n" "Color? (y,n): "
	read COLOR

	if [[ "$COLOR" = "n" ]]; then
		COLOR="Gray"
	else
		COLOR="CMYK"
	fi
	OPTIONS="$OPTIONS -o ColorModel=$COLOR"

	printf "%s\n" "Stapled? (y,n): "
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
printf "%s\n" "CID: "
read CID


#.................... Printing ..................

# command for printing
ssh $CID@remote11.chalmers.se lpr "$OPTIONS" -P "$PRINTER" < "$FILENAME"

# end message
printf "%s\n" "Done!" ""

# warn the iser if the system is old
old_realease_warning


