#!/usr/bin/env bash

set -e


curl -L \
  -o tables/fer-pref-ids-main.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAOmIiB2U3ocW6XNRjsfP9MWxHvhN8GeHKdTJONIrYFLo/get-fer-pref-ids

curl -L \
  -o tables/fer-pref-ids-extra-available.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAkVaxm_xPxkZsOGEWQ0NhJPr8HouSjT9VRkkVkb_r7Ko/get-fer-pref-ids-extra-available

curl -L \
  -o tables/fer-pref-ids-extra-to-be-developed.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAqSFhdnn0xvryQOpaLsm2e8rwlZYpWYWzx7fnuu6wk18/get-fer-pref-ids-extra-to-be-developed

csvstack \
  tables/fer-pref-ids-main.pre.csv \
  tables/fer-pref-ids-extra-available.pre.csv \
  tables/fer-pref-ids-extra-to-be-developed.pre.csv \
  > tables/fer-pref-ids.pre.csv


curl -L \
  -o tables/fer-ids.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAjyN5uK7O91bogeShAv9f1iJrXrvbxFmcbZydeyzWYqQ/get-fer-ids

csvjoin -d ',' -q '"' -c 'np_pre_pubkey_hash' \
  tables/fer-ids.pre.csv tables/fer-pref-ids.pre.csv \
  > tables/fer-ids-long.pre.csv


curl -L \
  -o tables/gff-qualifications.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RA-60tM5ao6hpkklW3vInQdBL77M41z5zud3TUGKrx5Q8/get-gff-qualifications

csvjoin -d ',' -q '"' --left -c 'res_np' \
  tables/fer-ids-long.pre.csv tables/gff-qualifications.pre.csv \
  > tables/fer-ids-full.pre.csv

csvcut -c 'resource_id,resource_pref_id,res,reslabel,res_np,res_np_date,resourcetype,qualification_np' \
  tables/fer-ids-full.pre.csv \
  | uniq \
  > tables/fer-ids.csv


rm tables/*.pre.csv
