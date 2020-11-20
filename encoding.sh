#!/bin/bash

#enter input encoding here
FROM_ENCODING="ISO-8859-1"

read -p "From enconding: " -e -i "$FROM_ENCODING" input

FROM_ENCODING="${input:-$FROM_ENCODING}"

#output encoding(UTF-8)
TO_ENCODING="UTF-8"

read -p "From enconding: " -e -i "$TO_ENCODING" input

FROM_ENCODING="${input:-$TO_ENCODING}"

#convert
CONVERT=" iconv  -f   $FROM_ENCODING  -t   $TO_ENCODING"

echo "Iniciando Conversão"

#loop to convert multiple files 
for  file  in  *.csv; do
     $CONVERT   "$file"   -o  "${file%.csv}"
done

echo "Conversão Finalizada!"

exit
