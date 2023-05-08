#!/usr/bin/env bash

set -e

curl -o tables/resource_ids.pre.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/get_resource_ids"
echo "tables/resource_ids.pre.csv count:" && cat tables/resource_ids.pre.csv | wc -l
cat tables/resource_ids.pre.csv | uniq -u > tables/resource_ids.csv
echo "tables/resource_ids.csv count:" && cat tables/resource_ids.csv | wc -l

curl -o tables/declarations.pre.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/get_declarations"
echo "tables/declarations.pre.csv count:" && cat tables/declarations.pre.csv | wc -l
cat tables/declarations.pre.csv | uniq -u > tables/declarations.csv
echo "tables/declarations.csv count:" && cat tables/declarations.csv | wc -l

csvjoin --left -c 'resource_id_used,resource_id' tables/declarations.csv tables/resource_ids.csv  > tables/new_matrix.csv

curl -o tables/matrix.pre.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/make_matrix"
echo "tables/matrix.pre.csv count:" && cat tables/matrix.pre.csv | wc -l
cat tables/matrix.pre.csv | uniq -u > tables/matrix.csv
echo "tables/matrix.csv count:" && cat tables/matrix.csv | wc -l

rm tables/*.pre.csv
