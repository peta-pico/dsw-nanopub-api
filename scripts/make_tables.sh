#!/usr/bin/env bash

set -e

API="https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api"

curl -o tables/resource_ids.csv -H "Accept: text/csv" "$API/get_resource_ids"

echo "1"
csvcut -c 'resource_id' tables/resource_ids.csv > tables/resource_ids_unsorted.pre.csv
echo "1.1"
head tables/resource_ids_unsorted.pre.csv
csvsort -c 'resource_id' tables/resource_ids_unsorted.pre.csv > tables/resource_ids.pre.csv
echo "2"
echo "resource_id" > tables/resource_ids_duplicates.pre.csv
echo "3"
tail -n +2 tables/resource_ids.pre.csv | uniq -d >> tables/resource_ids_duplicates.pre.csv
echo "4"
csvjoin --left -c 'resource_id' tables/resource_ids_duplicates.pre.csv tables/resource_ids.csv > tables/resource_ids_duplicates.csv
echo "5"

curl -o tables/declarations.csv -H "Accept: text/csv" "$API/get_declarations"

csvjoin --left -c 'resource_id_used,resource_id' tables/declarations.csv tables/resource_ids.csv  > tables/new_matrix.csv

curl -o tables/matrix.csv -H "Accept: text/csv" "$API/make_matrix"

rm tables/*.pre.csv
