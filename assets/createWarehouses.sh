#!/bin/bash
# must create the database first using something like this
# ./macos-x86_64/bin/cblite --create pbwarehouses.cblite2
#define filename
filename="warehouse.json"
dbFileName='pbwarehouses.cblite2'

scope='warehouses'
collection='locations'

#get amount of records to get out of file and split into new files
length=`cat $filename | jq -r '. | length'`

#create scope and collection
./macos-x86_64/bin/cblite mkcoll $dbFileName $scope/$collection

#loop through child array to get values out and save as seperate documents
for ((count=0;count<$length;count++))
do
	#get the json index for the current element in the array 
	itemIndex=".[$count]"

	#get the field that we want to use the name the file
	idIndex=".warehouseId"

	#get the json
	json=$(cat $filename | jq $itemIndex)
	id=$(echo $json | jq $idIndex)
	./macos-x86_64/bin/cblite put --scope $scope --collection $collection --create $dbFileName $id "$json"

	# use if you don't want to use scope and collections
	#./macos-x86_64/bin/cblite put --create $dbFileName $id "$json"
done

# you can check by listing the files in the database
# $cblite ls -l --limit 10 $dbFileName
