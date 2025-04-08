# API and Tables for Nanopub Integration in Data Stewardship Wizard (DSW)

Trigger creation of automatic table creation [here](https://github.com/peta-pico/dsw-nanopub-api/actions/workflows/make_tables.yml).

## Explore Matrix

Explore the matrix CSV here:

- [Full version](https://knowledgepixels.com/csv_viewer/?u=https%3A%2F%2Fraw.githubusercontent.com%2Fpeta-pico%2Fdsw-nanopub-api%2Frefs%2Fheads%2Fmain%2Ftables%2Fmatrix.csv)
- [Reduced version](https://knowledgepixels.com/csv_viewer/?u=https%3A%2F%2Fraw.githubusercontent.com%2Fpeta-pico%2Fdsw-nanopub-api%2Frefs%2Fheads%2Fmain%2Ftables%2Fmatrix_reduced.csv)

## Auxiliary Queries

`list_nonqualifed_fsr`:

    curl -L -H 'Accept: text/csv' https://query.petapico.org/api/RAZkMXCwJE_moP0PBZy3QshV8HyOvZwTwxT26fPcAXh7k/list_nonqualifed_fsr

`find_gofair_qualified_things`:

    curl -L -H 'Accept: text/csv' 'https://query.petapico.org/api/RASY_-DeGHg18-zzNyZWnU8S3HGAqKcDpoOFTIVbCruQ0/find-gofair-qualified-things?searchterm=abc&type=https://w3id.org/fair/fip/terms/FAIR-Enabling-Resource'
