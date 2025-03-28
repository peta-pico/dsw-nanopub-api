#!/usr/bin/env bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

QUERY_API_URL=https://query.knowledgepixels.com

# Get preferred FER IDs:

QUERY=$QUERY_API_URL/api/RAOmIiB2U3ocW6XNRjsfP9MWxHvhN8GeHKdTJONIrYFLo/get-fer-pref-ids
echo "Calling $QUERY"
curl -L \
  -o tables/v3/fer-pref-ids-main.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

QUERY=$QUERY_API_URL/api/RAkVaxm_xPxkZsOGEWQ0NhJPr8HouSjT9VRkkVkb_r7Ko/get-fer-pref-ids-extra-available
echo "Calling $QUERY"
curl -L \
  -o tables/v3/fer-pref-ids-extra-available.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

QUERY=$QUERY_API_URL/api/RAqSFhdnn0xvryQOpaLsm2e8rwlZYpWYWzx7fnuu6wk18/get-fer-pref-ids-extra-to-be-developed
echo "Calling $QUERY"
curl -L \
  -o tables/v3/fer-pref-ids-extra-to-be-developed.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

csvstack \
  tables/v3/fer-pref-ids-main.pre.csv \
  tables/v3/fer-pref-ids-extra-available.pre.csv \
  tables/v3/fer-pref-ids-extra-to-be-developed.pre.csv \
  > tables/v3/fer-pref-ids.pre.csv

# Get used FER IDs and combine with table above:

QUERY=$QUERY_API_URL/api/RAjyN5uK7O91bogeShAv9f1iJrXrvbxFmcbZydeyzWYqQ/get-fer-ids
echo "Calling $QUERY"
curl -L \
  -o tables/v3/fer-ids.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

csvjoin -d ',' -q '"' -c 'np_pre_pubkey_hash' \
  tables/v3/fer-ids.pre.csv tables/v3/fer-pref-ids.pre.csv \
  > tables/v3/fer-ids-long.pre.csv

# Get GFF qualifications and combine with table above:

QUERY=$QUERY_API_URL/api/RA-60tM5ao6hpkklW3vInQdBL77M41z5zud3TUGKrx5Q8/get-gff-qualifications
echo "Calling $QUERY"
curl -L \
  -o tables/v3/gff-qualifications.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

csvjoin -d ',' -q '"' --left -c 'res_np' \
  tables/v3/fer-ids-long.pre.csv tables/v3/gff-qualifications.pre.csv \
  > tables/v3/fer-ids-full.pre.csv

csvcut -c 'resource_id,resource_pref_id,res,reslabel,res_np,res_np_date,resourcetype,qualification_np' \
  tables/v3/fer-ids-full.pre.csv \
  | uniq \
  > tables/v3/fer-ids.csv

# Make FER duplicate table:

csvcut -d ',' -q '"' -c 'resource_id' tables/v3/fer-ids.csv > tables/v3/fer-ids-unsorted.pre.csv
csvsort -d ',' -q '"' -c 'resource_id' tables/v3/fer-ids-unsorted.pre.csv > tables/v3/fer-ids-sorted.pre.csv
echo "resource_id" > tables/v3/fer-ids-duplicates.pre.csv
tail -n +2 tables/v3/fer-ids-sorted.pre.csv | uniq -d >> tables/v3/fer-ids-duplicates.pre.csv
csvjoin -d ',' -q '"' --left -c 'resource_id' tables/v3/fer-ids-duplicates.pre.csv tables/v3/fer-ids.csv > tables/v3/fer-ids-duplicates.csv

# Get FER declarations:

QUERY=$QUERY_API_URL/api/RAYcBdAQWI6gveZKNCMJAbGwRblLja04h2ct78GxAw5w0/get-fip-decl-in-index
echo "Calling $QUERY"
curl -L \
  -o tables/v3/fip-decl-in-index.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

QUERY=$QUERY_API_URL/api/RAJJY0gSdHbzFc1q2sLIPs4ZKSnSFMq_IxxLjixKn80XU/get-fip-decl-details
echo "Calling $QUERY"
curl -L \
  -o tables/v3/fip-decl-details.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

csvjoin -d ',' -q '"' -c 'decl_np' \
  tables/v3/fip-decl-in-index.pre.csv tables/v3/fip-decl-details.pre.csv \
  > tables/v3/fip-declarations.pre.csv

QUERY=$QUERY_API_URL/api/RAz76URtDXiLs-16LwzK-zNyzbIugXW8OjhUQdh5jPdtw/get-fip-supercommunities
echo "Calling $QUERY"
curl -L \
  -o tables/v3/fip-supercommunities.pre.csv \
  -H "Accept: text/csv" \
  $QUERY

csvjoin -d ',' -q '"' --left -c 'community' \
  tables/v3/fip-declarations.pre.csv tables/v3/fip-supercommunities.pre.csv \
  > tables/v3/fip-declarations.csv

# Creating matrix table:

csvjoin -d ',' -q '"' --left -c 'resource_id_used,resource_id' \
  tables/v3/fip-declarations.csv tables/v3/fer-ids.csv \
  > tables/v3/matrix.csv

csvcut -c fip_title,resource_pref_id,reslabel \
  tables/v3/matrix.csv \
  > tables/v3/matrix_reduced.csv

# Removing all preliminary files:

rm tables/v3/*.pre.csv
