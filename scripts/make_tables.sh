#!/usr/bin/env bash

set -e

curl -o tables/resource_ids.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/get_resource_ids"
curl -o tables/matrix.csv -H "Accept: text/csv" "https://grlc.petapico.org/api-git/peta-pico/dsw-nanopub-api/make_matrix"
