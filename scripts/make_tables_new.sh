#!/usr/bin/env bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

# Get preferred FER IDs:

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

# Get used FER IDs and combine with table above:

curl -L \
  -o tables/fer-ids.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAjyN5uK7O91bogeShAv9f1iJrXrvbxFmcbZydeyzWYqQ/get-fer-ids

csvjoin -d ',' -q '"' -c 'np_pre_pubkey_hash' \
  tables/fer-ids.pre.csv tables/fer-pref-ids.pre.csv \
  > tables/fer-ids-long.pre.csv

# Get GFF qualifications and combine with table above:

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

# Make FER duplicate table:

csvcut -d ',' -q '"' -c 'resource_id' tables/fer-ids.csv > tables/fer-ids-unsorted.pre.csv
csvsort -d ',' -q '"' -c 'resource_id' tables/fer-ids-unsorted.pre.csv > tables/fer-ids-sorted.pre.csv
echo "resource_id" > tables/fer-ids-duplicates.pre.csv
tail -n +2 tables/fer-ids-sorted.pre.csv | uniq -d >> tables/fer-ids-duplicates.pre.csv
csvjoin -d ',' -q '"' --left -c 'resource_id' tables/fer-ids-duplicates.pre.csv tables/fer-ids.csv > tables/fer-ids-duplicates.csv

# Get FER declarations:

curl -L \
  -o tables/fip-decl-in-index.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAL8F7s1oIwAooPdg8jLmtRYz9xIigSbt8pgQd1QiXDh0/get-fip-decl-in-index

curl -L \
  -o tables/fip-decl-details.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAJJY0gSdHbzFc1q2sLIPs4ZKSnSFMq_IxxLjixKn80XU/get-fip-decl-details

csvjoin -d ',' -q '"' -c 'decl_np' \
  tables/fip-decl-in-index.pre.csv tables/fip-decl-details.pre.csv \
  > tables/fip-declarations.pre.csv

curl -L \
  -o tables/fip-supercommunities.pre.csv \
  -H "Accept: text/csv" \
  https://query.petapico.org/api/RAz76URtDXiLs-16LwzK-zNyzbIugXW8OjhUQdh5jPdtw/get-fip-supercommunities

csvjoin -d ',' -q '"' --left -c 'community' \
  tables/fip-declarations.pre.csv tables/fip-supercommunities.pre.csv \
  > tables/fip-declarations.csv

# Creating matrix table:

csvjoin -d ',' -q '"' --left -c 'resource_id_used,resource_id' \
  tables/fip-declarations.csv tables/fer-ids.csv \
  > tables/matrix.csv

csvcut -c fip_title,resource_pref_id,reslabel \
  tables/matrix.csv \
  > tables/matrix_reduced.csv

# Removing all preliminary files:

rm tables/*.pre.csv
