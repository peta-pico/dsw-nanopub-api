#!/usr/bin/env bash

set -e

curl -o tables/resource_ids.pre.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/get_resource_ids"
cat tables/resource_ids.pre.csv | uniq -u > tables/resource_ids.csv

curl -o tables/matrix.pre.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/make_matrix"
cat tables/matrix.pre.csv | uniq -u > tables/matrix.csv
