#!/bin/bash

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Autor: Otávio Ribeiro <ribeitemp@gmail.com.br>
#  Created on: 21/08/2020
#  Reason: Automation in creating a database from CSV files.
#  --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "
-------------------------------------------------------------------------------------------
|#########################################################################################|
|#########################  CSV to MySql database creator  ###############################|
|#########################################################################################|
-------------------------------------------------------------------------------------------"
echo "-"
echo "-"
echo "Database connection parameters"
echo "-"
echo "-"

# define database connectivity
_dbi="xxxx"
read -p "Legacy Name (BD): " -e -i "$_dbi" input
_db="${input:-$_dbi}"
echo "-"
_db_useri="xxxx"
read -p "User (BD): " -e -i "$_db_useri" input
_db_user="${input:-$_db_useri}"
echo "-"
_db_passwordi="xxxx"
read -p "Password $_db_user: " -e -i "$_db_passwordi" input
_db_password="${input:-$_db_passwordi}"
echo "-"
_db_hosti="xxxx"
read -p "Host (BD): " -e -i "$_db_hosti" input
_db_host="${input:-$_db_hosti}"
echo "-"
echo "-"

# set directory containing CSV files
_csv_directoryi="/home"
read -p "Directory path where the CSV files are located: " -e -i "$_csv_directoryi" input
_csv_directory="${input:-$_csv_directoryi}"

# go to directory
cd $_csv_directory

# renames files
echo "
|---------------------------------------------------------------------------------------|
|-------------------Renaming files if necessary-----------------------------------------|
|---------------------------------------------------------------------------------------|"
repeat="0"
totalfiles=$( expr `ls *XXXX* | wc -l` + 1 )
echo "-"
echo "-"
while [ "$repeat" != "$totalfiles" ]; 
do 
name=$( ls *XXXX* | head -n$repeat | tail -n1 )
newname=$( ls ** | head -n$repeat | tail -n1 | sed 's/XXXX//g' )
mv $name $newname
repeat=$( expr $repeat + 1 )
done
echo "-"
echo "-"
echo "Renamed files"
echo "-"
echo "-"

echo "
|---------------------------------------------------------------------------------------|
|---------------------------Converts file encoding---------------------------------------|
|---------------------------------------------------------------------------------------|"
# Conversion files
_csv=`ls *.csv`

# enter the input encoding here
_FROM_encoding="ISO-8859-1"

# output encoding (UTF-8)
_TO_encoding="UTF-8"

# converter
_convert="iconv -f $_FROM_encoding -t $_TO_encoding//TRANSLIT"

# convert multiple files 
echo "Starting Conversion of all files"
echo "-"
echo "-"
for _file in $_csv ; do
echo "-"
echo "-"
echo "Converting $_file"
echo "-"
echo "-"
echo $_convert "$_file" -o "${_file%.csv}.csv"
done
echo "-"
echo "-"
echo "Conversion Finished!"

echo "
|-------------------------------------------------------------------------------------|
|------------------------Creating Database $_db
|-------------------------------------------------------------------------------------|"
# Creates and recreates the schema
echo "----Drop database $_db...----";
mysql -u$_db_user -p$_db_password -h$_db_host -e "DROP DATABASE IF EXISTS $_db;";
echo "Database $_db clean";
echo "-"
echo "-"
echo "----Creating database $_db...----";
mysql -u$_db_user -p$_db_password -h$_db_host -e "CREATE DATABASE IF NOT EXISTS $_db CHARACTER SET utf8 COLLATE utf8_general_ci;";
echo "Databese $_db created";

# browse csv files
for _csv in ${_csv[@]}
do
# remove file extension
_csv_file_extensionless=`echo $_csv | sed 's/\(.*\)\..*/\1/'`

# define table name
_table_name="${_csv_file_extensionless}"

# get CSV file header columns
_header_columns=`head -1 $_csv_directory/$_csv | sed 's/;/,/g' | tr ',' '\n' | sed 's/^"//' | sed 's/"$//' | sed 's/ /_/g'` 
_header_columns_string=`head -1 $_csv_directory/$_csv | sed 's/;/,/g' | sed 's/ /_/g' | sed 's/"//g'`


# Create tables
echo "
|-----------------------------------------------------------------------------------|
|------------------------Creating table $_table_name      
|-----------------------------------------------------------------------------------|"

mysql -u$_db_user -p$_db_password -h$_db_host $_db << eof
CREATE TABLE IF NOT EXISTS \`$_table_name\` (
temp int NOT NULL auto_increment,
PRIMARY KEY (temp)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
eof

# scroll through header columns
for _header in ${_header_columns[@]}
do

# add column
echo "|-----Add column $_header"

mysql -u $_db_user -p$_db_password -h$_db_host $_db --execute="ALTER TABLE \`$_table_name\` ADD COLUMN \`$_header\` TEXT"

done 

# remove temporary column
mysql -u $_db_user -p$_db_password -h$_db_host $_db --execute="ALTER TABLE \`$_table_name\` DROP COLUMN temp"

# import csv to mysql
echo "
|-----------------------------------------------------------------------------------|
|------------------------Importing data from file $_csv
|-----------------------------------------------------------------------------------|"

mysqlimport --local --compress --verbose --fields-terminated-by=',' --fields-enclosed-by='"' --lines-terminated-by="\n" --ignore-lines='1' --columns=$_header_columns_string -u $_db_user -p$_db_password -h$_db_host $_db $_csv_directory/$_csv

done
echo "-"
echo "-"
echo "Database $_db successfully created!"
echo "-"
echo "-
-------------------------------------------------------------------------------------------
|                                                                                         |
|                                       END                                               |
|                                                                                         |
-------------------------------------------------------------------------------------------"
exit
