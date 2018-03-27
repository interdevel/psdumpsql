#!/bin/bash

#
# Generates SQL dump file for a Prestashop database.
# Extracts database name, user name and password from settings.inc.php.
# Requires mysqldump.
# 
# Usage:
#     cd /var/www/vhosts/<myproject>
#     psdumpsql <dest-file> [<settings-location>]
#
# Parameters:
#     dest-file            Output file, where you want to save the dump file
#     settings-location    [Optional] Path to Prestashop settings file.
#
# Example:
#     cd /var/www/vhosts/example.com/example
#     psdumpsql db/latest.sql
# 
# Author: Luis Molina <lgallardo@trevenque.es>
# Created: 2018-03-27
# 

set -o errexit

usage () {
	echo "Usage: $0 <dest-file> [<settings-location>]"
}

#
# Some constants.
#
DUMPEXEC=$(which mysqldump)
DEFAULT_SETTINGS_FILE="config/settings.inc.php"

# 
# Process parameters.
# 
if [ -z "$1" ]; then
	echo "Invalid parameter: you must specify output file as first parameter"
	usage
	exit
fi
DUMPFILE=$1

if [ "$2" != "" ]; then
	SETTINGS_FILE=$2
else
	SETTINGS_FILE=$DEFAULT_SETTINGS_FILE
fi

if [ ! -f "$SETTINGS_FILE" ]; then
	echo "Invalid settings file, or settings file not found"
	exit
fi

#
# Extract database credentials.
# 
DBNAME=$(cat $SETTINGS_FILE | grep _DB_NAME_   | cut -d \' -f 4)
DBUSER=$(cat $SETTINGS_FILE | grep _DB_USER_   | cut -d \' -f 4)
DBPASS=$(cat $SETTINGS_FILE | grep _DB_PASSWD_ | cut -d \' -f 4)

#
# The real work.
# 
echo "Using $SETTINGS_FILE to save Prestashop database in $DUMPFILE..."

$DUMPEXEC --verbose --user=$DBUSER --password=$DBPASS $DBNAME > $DUMPFILE

if [ $? -eq 0 ]; then
	echo "Prestashop database saved in $DUMPFILE"
else
	echo "Could not generate SQL dump." >&2
fi

