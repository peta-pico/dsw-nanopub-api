# Notes

Autoreplace in multiple queries:

    find . -type f -name '*.rq' | xargs sed -i 's|old|new|g'

## FIP version filter in `get-fip-decl-in-index` (draft fix, 2026-10-29)

The query behind `tables/fip-decl-in-index.pre.csv` (`RALx4mcnF84op6E-q-voMr19X80Sy_Khy2I1dMmachJ3o/get-fip-decl-in-index`)
is meant to keep only the newest index per FIP. It recognises an older version by a newer nanopublication
with the **same title** and the same key. That fails in both directions:

- A FIP whose title changed between versions keeps all its versions. On 2026-10-29 the Wizard had
  republished 63 FIPs with underscores replaced by spaces in the title (e.g. `LifeWatch_Ecosystems_FIP_2021`,
  2022-07-20 → `LifeWatch Ecosystems FIP 2021`, 2024-01-22), so 66 superseded indexes were still in
  `matrix.csv`: 235 "FIPs" in the FIP Matrix app instead of 168, each old version adding its declarations.
- A FIP whose title is shared by a *non-index* nanopublication is dropped (the PARC Toxicology rFIP and the
  NanoPharos FIP, both titled like their own FIP nanopublication).

`queries/get-fip-decl-in-index.rq` (SPARQL) and `queries/get-fip-decl-in-index.trig` (the nanopublication
draft, unsigned, superseding `RALx4mcnF84…`) replace the filter by two rules, both restricted to
`npx:NanopubIndex` nanopublications: a newer valid index derived from the same Wizard source
(`prov:wasDerivedFrom` in the index's pubinfo), or a newer valid index with the same title (a FIP re-created
as a new Wizard project keeps its title but gets a new source; four such cases exist, all within one community).
The two filters sit in a sub-select that yields one row per index, so they run ~235 times rather than once
per declaration row; this is what makes the query faster than the live one despite the second rule.
Tested through the query API with `_nanopub_trig` on 2026-10-29: 168 indexes / 4729 declaration rows
(live: 232 / 6677), one index per source and per title, 1.8 s (live: 3 s; the same filters applied per
declaration row took 7.5 s). No split into several queries is needed.

Published 2026-10-29 as a new, non-superseding query (signed with the local key; the old one is signed with the
Nanodash key): `RAFQGybSJZmBGu-zu2wX5-bvjVJlJbBvMA1esw3S6KfbA/get-fip-decl-in-index`, derived from `RALx4mcnF84…`
(`prov:wasDerivedFrom`). `scripts/make_tables.sh` now calls it. The old query `RALx4mcnF84…` can be retracted
from Nanodash; nothing in this repo references it any more.

### Follow-up: retracted FIPs and rFIP indexes (published 2026-10-30)

Two remaining errors in the FIP count of `matrix.csv` (171 FIP indexes after the version fix):

- **Retracted FIPs were kept.** GFF FIP, Test FIP and Copy of ADVANCE FIP have indexes whose FIP
  nanopublications are all retracted. The new version drops an index when FIP nanopublications refer to it and
  all of them are invalidated; an index no FIP nanopublication refers to (COS FIP, Stockholm Convention,
  JB-test) is still kept.
- **rFIP indexes competed with the rFIP query.** The Reference AOP FIP and the PARC Toxicology rFIP also have
  a Wizard index. Because `make_tables.sh` only adds rFIP declarations not already covered by an index, those
  indexes claimed declarations for themselves: the PARC rFIP appeared under two FIP indexes (its March index
  and its current rFIP nanopublication). The new version leaves out indexes of valid rFIP nanopublications, so
  rFIPs come only from `get-rfip-decl-in-context`.

Tested on 2026-10-30 by emulating the merge in `make_tables.sh` on both query outputs: 167 FIP indexes
(160 current FIPs, 4 rFIPs, 3 indexes without any FIP nanopublication) instead of 171, every title once,
no declaration listed twice; the PARC rFIP now has one entry (4 rows), the AOP rFIP keeps its 13 rows,
and the one declaration of the retracted GFF FIP moves to the GFF R-FIP. 1.9 s (live 1.5 s).
Published as `RATC_tCEzOumv1KQ-sIeiB62qJ5BljQ5PBSLvRtVLRSQ0/get-fip-decl-in-index`, superseding
`RAFQGybSJZmBGu-zu2wX5-bvjVJlJbBvMA1esw3S6KfbA` (same key); `scripts/make_tables.sh` calls it.
