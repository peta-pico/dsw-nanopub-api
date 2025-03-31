# API and Tables for Nanopub Integration in Data Stewardship Wizard (DSW)

Trigger creation of automatic table creation [here](https://github.com/peta-pico/dsw-nanopub-api/actions/workflows/make_tables.yml).

## New Versions at Latest Nanopub Services

`list_nonqualifed_fsr` has this new version:

    curl -L -H 'Accept: text/csv' https://query.petapico.org/api/RAZkMXCwJE_moP0PBZy3QshV8HyOvZwTwxT26fPcAXh7k/list_nonqualifed_fsr

`find_gofair_qualified_things` has this new version:

    curl -L -H 'Accept: text/csv' 'https://query.petapico.org/api/RASY_-DeGHg18-zzNyZWnU8S3HGAqKcDpoOFTIVbCruQ0/find-gofair-qualified-things?searchterm=abc&type=https://w3id.org/fair/fip/terms/FAIR-Enabling-Resource'
