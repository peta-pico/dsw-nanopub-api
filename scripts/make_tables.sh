#!/usr/bin/env bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd ..

QUERY_API_URL=https://query.petapico.org

function call_api {
  for i in {0..2}; do
    QUERY=$QUERY_API_URL/api/$1
    OUTFILE=tables/$2
    echo "Calling $QUERY"
    curl -f -L -o $OUTFILE -H "Accept: text/csv" $QUERY
    # Work-around because the API URLs don't return proper HTTP error codes:
    if [ $(head -n 1 $OUTFILE | tr -d '\r\n') = "<html>" ]; then
      echo "Error retrieving $QUERY"
      if [[ $i = "2" ]]; then
        exit 1
      else
        sleep 1
      fi
    fi
  done
}

# Get preferred FER IDs:

call_api RAOmIiB2U3ocW6XNRjsfP9MWxHvhN8GeHKdTJONIrYFLo/get-fer-pref-ids fer-pref-ids-main.pre.csv

call_api RAkVaxm_xPxkZsOGEWQ0NhJPr8HouSjT9VRkkVkb_r7Ko/get-fer-pref-ids-extra-available fer-pref-ids-extra-available.pre.csv

call_api RAqSFhdnn0xvryQOpaLsm2e8rwlZYpWYWzx7fnuu6wk18/get-fer-pref-ids-extra-to-be-developed fer-pref-ids-extra-to-be-developed.pre.csv

csvstack -d ',' -q '"' \
  tables/fer-pref-ids-main.pre.csv \
  tables/fer-pref-ids-extra-available.pre.csv \
  tables/fer-pref-ids-extra-to-be-developed.pre.csv \
  > tables/fer-pref-ids.pre.csv

# Get used FER IDs and combine with table above:

call_api RAjyN5uK7O91bogeShAv9f1iJrXrvbxFmcbZydeyzWYqQ/get-fer-ids fer-ids.pre.csv

csvjoin -d ',' -q '"' -c 'np_pre_pubkey_hash' \
  tables/fer-ids.pre.csv tables/fer-pref-ids.pre.csv \
  > tables/fer-ids-long.pre.csv

# Get GFF qualifications and combine with table above:

call_api RA-60tM5ao6hpkklW3vInQdBL77M41z5zud3TUGKrx5Q8/get-gff-qualifications gff-qualifications.pre.csv

csvjoin -d ',' -q '"' --left -c 'res_np' \
  tables/fer-ids-long.pre.csv tables/gff-qualifications.pre.csv \
  > tables/fer-ids-full.pre.csv

csvcut -d ',' -q '"' -c 'resource_id,resource_pref_id,res,reslabel,res_np,res_np_date,resourcetype,qualification_np' \
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

call_api RAEY8_rG74ZFJZ6wAZ2npoCZoUBafVECzqhPLgwHihiig/get-fip-decl-in-index fip-decl-in-index.pre.csv

call_api RAJJY0gSdHbzFc1q2sLIPs4ZKSnSFMq_IxxLjixKn80XU/get-fip-decl-details fip-decl-details.pre.csv

csvjoin -d ',' -q '"' -c 'decl_np' \
  tables/fip-decl-in-index.pre.csv tables/fip-decl-details.pre.csv \
  > tables/fip-declarations.pre.csv

call_api RAz76URtDXiLs-16LwzK-zNyzbIugXW8OjhUQdh5jPdtw/get-fip-supercommunities fip-supercommunities.pre.csv

csvjoin -d ',' -q '"' --left -c 'community' \
  tables/fip-declarations.pre.csv tables/fip-supercommunities.pre.csv \
  > tables/fip-declarations.csv

# Creating matrix table:

csvjoin -d ',' -q '"' --left -c 'resource_id_used,resource_id' \
  tables/fip-declarations.csv tables/fer-ids.csv \
  > tables/matrix.csv

csvcut -d ',' -q '"' -c fip_title,resource_pref_id,reslabel \
  tables/matrix.csv \
  > tables/matrix_reduced.csv

# Removing all preliminary files:

rm tables/*.pre.csv
