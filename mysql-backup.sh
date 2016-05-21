#!/bin/sh

# Config
backupPath="."
configFile="/etc/mysqlbackup.conf"

# Execs
mysqldump="mysqldump"

error_exit() {
	echo $1
	exit 1
}

get_conf_file() {
	# Check if the confile exists and include it and check the mandatory parameters
	if [ ! -f $configFile ]; then
		error_exit "Config file: $configFile: no such file or directory"
	fi
	echo "Parsing configuration file: $configFile"
	. $configFile

	if [ ! -n "$DBHOST" ]; then
		error_exit "Database host missing in $configFile"
	fi
	if [ ! -n "$DBUSER" ]; then
		error_exit "Database user missing in $configFile"
	fi
	if [ ! -n "$DBPASS" ]; then
		error_exit "Database password missing in $configFile"
	fi
	if [ ! -n "$DBDATABASE" ]; then
		error_exit "Database missing in $configFile"
	fi
}

run_backup() {
	# Create the custom backup path if it's changed from the default one
	if [ "$backupPath" != "." ]; then
		mkdir -p "$backupPath"
	fi
	# Get a timestamped backup filename
	currentTime=`date +%Y%m%d%H%M%S`
	dbBackupName="$backupPath/$DBDATABASE-$currentTime.sql"
	# Run the backup
	echo "Backup $DBHOST $DBDATABASE in $dbBackupName"
	$mysqldump --host="$DBHOST" --user="$DBUSER" --password="$DBPASS" $DBDATABASE > $dbBackupName
}

# Check if we have mysqldump (otherwise this script is useless
if [ -x $mysqldump ]; then
	error_exit "$mysqldump: command doesn't exists"
fi

# Parse the arguement befor the actual db backup
for key in "$@"
do
	case $key in
		-c|--config)
			configFile="$2"
			shift 2
		;;
		-p|--path)
			backupPath="$2"
			shift 2
		;;
	esac
done

# Load the config file and check the mandatory configuration
get_conf_file

# Run the backup itself
run_backup
