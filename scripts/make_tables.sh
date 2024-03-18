#!/usr/bin/env bash

set -e

API="https://grlc.knowledgepixels.com/api-git/peta-pico/dsw-nanopub-api"

curl -o tables/resource_ids.csv -H "Accept: text/csv" "$API/get_resource_ids"

csvcut -d ',' -q '"' -c 'resource_id' tables/resource_ids.csv > tables/resource_ids_unsorted.pre.csv
csvsort -d ',' -q '"' -c 'resource_id' tables/resource_ids_unsorted.pre.csv > tables/resource_ids.pre.csv
echo "resource_id" > tables/resource_ids_duplicates.pre.csv
tail -n +2 tables/resource_ids.pre.csv | uniq -d >> tables/resource_ids_duplicates.pre.csv
csvjoin -d ',' -q '"' --left -c 'resource_id' tables/resource_ids_duplicates.pre.csv tables/resource_ids.csv > tables/resource_ids_duplicates.csv

curl -o tables/declarations.csv -H "Accept: text/csv" "$API/get_declarations"

csvjoin -d ',' -q '"' --left -c 'resource_id_used,resource_id' tables/declarations.csv tables/resource_ids.csv  > tables/new_matrix.csv

csvcut -c fip_title,reslabel,res_np tables/new_matrix.csv > tables/new_matrix_reduced.csv

curl -o tables/matrix.csv -H "Accept: text/csv" "$API/make_matrix"

rm tables/*.pre.csv
