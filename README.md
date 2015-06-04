# chalmers-print
Script for easy printing from your own machine at Chalmers University of Technology

## How to install

# Automatic install (tested and developed for mac)
1. Download the latest realease
2. Unzip the zip file
3. Start the terminal and cd into the new chalmers-print folder that you unzipped
4. Run *./chalmers-print.sh install*
5. Restart your terminal and your good to go!

# Manually install
1. Download the latest realease
2. Unzip the zip file
3. Place the file *chalmers-print.sh* in a desired location
3. Create an alias (recommended alias: *chprint*) by adding this line: *alias chprint="path-to-your-chosen-folder/chalmers-print.sh"* in the file *.bash_profile* in your home directory
4. Restart your terminal and your good to go!

## How to use

# Printing
1. Call the script with command *chprint* (or correct alias if you have choosen another)
2. Answer the questions that the script prompt you for

You can also give optional arguments to the command to speed things up
> chprint [ filepath ] [ full name or nickname of printer]

*(brackets should not be included)**

# Update
You can automatically update by running
> chprint update

The script will check for a later realease and you will be asked if you would like to automatically update. This is recommended if you use the standard alias and have used the automatic install. Otherwise you can download the new version from GitHub and manually update by replacing the files.

# Other commands
The following commands also exist at the moment:
1. printlist - directs you to a complete list of available printers and their names
2. nicklist - prints a list of all nicknamed printers. These also have full customisation available

#### Nicknamed printers
* *torget* - color printer in Forskarhuset level 7
* *dd* - laser printer in old computer room called DjungelData
* *bulten* - laser printer in study hall next to Bulten
* *fb* - printer in computer room next to lecture hall FB

A complete list of printers on Chalmers can be found here: [List of printers](http://print.chalmers.se/public/showprinters.cgi)
