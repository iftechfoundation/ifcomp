# Shipping IFComp games to IFDB and IF Archive

## Before judging starts

1. IFComp dev team will generate the start-of-comp big zip using [`build_zip_of_zips.pl`](https://github.com/iftechfoundation/ifcomp/blob/main/IFComp/script/build_zip_of_zips.pl).

## ASAP on comp start day

2. IFDB dev team will run [Phase 1 of the IFDB importer](https://github.com/iftechfoundation/ifdb/tree/main/importers/ifcomp). All IFDB entries will be immediately created based on the HTML content of [https://ifcomp.org/ballot](https://ifcomp.org/ballot), with links pointing to the IFComp ballot.

## Pretty soon after that (no rush)

3. IFComp dev team will run [`populate_ifdb_ids.pl`](https://github.com/iftechfoundation/ifcomp/blob/main/IFComp/script/populate_ifdb_ids.pl).
4. IFComp dev team will upload the start-of-comp big zip to the archive.
5. Archive team will archive the start-of-comp big zip to the `/games/competitionYYYY` directory, but we won't extract it.

## In preparation for the end of voting

6. Archive team will test [`ifcomp-index-generator.py`](https://github.com/iftechfoundation/ifarchive-admintool/blob/main/scripts/ifcomp-index-generator.py) using the start-of-comp zip, to make sure it looks sane. If needed, we'll fix bugs in the `Index` generator.

## When voting ends (processing_votes phase)

7. IFComp dev team will upload the end-of-comp big zip to the archive.
8. If IFComp dev team hasn't already run [`populate_ifdb_ids.pl`](https://github.com/iftechfoundation/ifcomp/blob/main/IFComp/script/populate_ifdb_ids.pl) (see Step 2 above), IFComp dev team will run it now. (We *can* run this as early as Step 3, but we *must* run it before winners are announced, or the IFComp results page will have nowhere to link to.)
9. The Archive team will use the "Extract Zip" button to extract the end-of-comp zip directly into `/games/competitionYYYY`.
10. The Archive team will use [`ifcomp-index-generator.py`](https://github.com/iftechfoundation/ifarchive-admintool/blob/main/scripts/ifcomp-index-generator.py) to generate an `Index` file for the `/games/competitionYYYY` directory.
11. The Archive team will then trash the end-of-comp zip. (We will continue to archive the start-of-comp zip in perpetuity.)
12. IFDB dev team will run [Phase 2 of the IFDB importer](https://github.com/iftechfoundation/ifdb/tree/main/importers/ifcomp). The IFDB entries will be updated to point to the IF Archive.

## After the competition ends and winners are announced

13. IFDB dev team will run [Phase 3 of the IFDB importer](https://github.com/iftechfoundation/ifdb/tree/main/importers/ifcomp), removing links to the IFComp ballot.

## References

* [IFDB IFComp Importer](https://github.com/iftechfoundation/ifdb/tree/main/importers/ifcomp)
  * Phase 1: (Day 1, ASAP) Create IFDB listings linking to ifcomp.org/ballot
  * Phase 2: (Voting ends, processing_votes) Add IF Archive links to IFDB entries
  * Phase 3: (Winners announced) Remove ifcomp.org/ballot links from IFDB listings
* [IF Archive volunteer procedures](https://ifarchive.org/misc/org-procedures.html): See the section on "IFComp games" and the section on "IFComp zips" in the "IFTF services backups" section. (The doc you're reading should agree with that doc.)
* [`populate_ifdb_ids.pl`](https://github.com/iftechfoundation/ifcomp/blob/main/IFComp/script/populate_ifdb_ids.pl): Adds IFDB TUIDs to the IFComp database. Can be run any time after IFDB listings have been created; must be run before the competition ends and winners are announced
* [`build_zip_of_zips.pl`](https://github.com/iftechfoundation/ifcomp/blob/main/IFComp/script/build_zip_of_zips.pl): Builds the IFComp zip-of-zips in a standard structure that `ifcomp-index-generator.py` can parse and cross-reference with ifcomp.org/comp/YYYY/json
* [`ifcomp-index-generator.py`](https://github.com/iftechfoundation/ifarchive-admintool/blob/main/scripts/ifcomp-index-generator.py): Automatically builds an `Index` file for the `/games/competitionYYYY` directory, based on a zip-of-zips, IFComp JSON at `ifcomp.org/comp/YYYY/json`, and IFDB search results.