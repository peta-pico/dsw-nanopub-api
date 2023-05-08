#!/usr/bin/env bash

echo "This is a test"

curl -o tables/matrix.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/make_matrix"
