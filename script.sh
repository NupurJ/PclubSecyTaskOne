#!/bin/bash

# PRINT NON-OFFICIAL NAMES
echo 'The non-official names are:'
# names satisfying any of the 3 criteria given are stored here temporarily
# so it may contain duplicates
myfile=$(mktemp)
# criteria: lowercase only
sed -n '2,$ s/^\([a-z]*\),.*,.*/\1/p' out.csv >> $myfile
# criteria: one word only
sed -n '2,$ s/^\([^ ]*\),.*,.*/\1/p' out.csv >> $myfile
# criteria: special symbols included
sed -n '2,$ s/^\([^,]*[^a-zA-Z ,][^,]*\),.*,.*/\1/p' out.csv >> $myfile
# remove duplicate entries from temporary file and print
sort $myfile |uniq
# delete temporary file
rm $myfile

# CREATE SECOND CSV FILE
# bunch of temporary files that are used later
beautjson=$(mktemp)
namesjson=$(mktemp)
namescsv=$(mktemp)
commonnames=$(mktemp)

# extract official names from csv 
sed -n -e '2,$ s/\([A-Za-z]* [A-Za-z]*\),.*,.*/\1/p' out.csv | sed '/^\([a-z]* [a-z]*\),.*,.*/d' >$namescsv

# 'beautify' json file and store in beautjson so each entry starts on a new line and we can use sed easily
sed -n 's/},{/}\n{/g p' students.json >$beautjson
# extract names from beautified json and store in namesjson
sed -n 's/[\[]*{.*"n":"\([A-Z a-z]*\)".*/\1/p' $beautjson >$namesjson
# remove duplicate names from namesjson
sort -u $namesjson -o $namesjson
# merge names from csv and names from json, sort, and get duplicate entries - these are the common names
cat $namescsv >>$namesjson
sort $namesjson | uniq -d >$commonnames

# delete temp files we don't need anymore
rm $namesjson
rm $namescsv

# this will contain the final data, the required csv file
final=$(mktemp)

# the purpose of these temporary files is only to ensure that whitespace does not appear
# between the different fields of an entry in the csv when we start concatenating the data in the file in the loop
tmp1=$(mktemp)
tmp2=$(mktemp)
tmp3=$(mktemp)

# for each common name
cat $commonnames | while read name
do
    # get name and add it to the first temp variable
    echo "$name," >$tmp1
    # get roll number and branch and add them to the second temp variable
    grep "$name" $beautjson | sed -n 's/^.*"d":"\([A-Z a-z.]*\)".*"i":"\([0-9]*\)".*/\2,\1,/p' >$tmp2
    # get project name and organisation and add them to the third temp variable
    grep "$name" out.csv | sed -n 's/.*,\(.*\),\(.*\)$/\2,\1/p' >$tmp3

    #combine all three pieces of data and append it to the final file
    echo "$(cat $tmp1)$(cat $tmp2)$(cat $tmp3)" >>$final
done

#copy final file (which is in /tmp/) into a file in the current folder called final.csv
cp $final final.csv

# clean up files
rm $final
rm $beautjson
rm $commonnames
rm $tmp3
rm $tmp2
rm $tmp1
