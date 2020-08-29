# IFComp Scripts

For each of the scripts listed below, further details on the purpose and usage
may be found within the script itself.

## Comp Management scripts

 * `archive_cover_art.pl` - This script rolls the current comp's cover art into its permanent location.
 * `compute_final_scores.pl` - This script computes all qualifying entries' final scores and other information based on qualifying votes, and updates these entries' database records appropriately.
 * `current_author_emails.pl` - Prints a list of author email addresses for the current comp.
 * `current_author_forum_handles.pl` - Prints a list of author forum handles for the current comp.
 * `delete_unfulfilled_intents.pl` - This script marks every entry without a main file as disqualified. Useful for marking unfulfilled intents, post-deadline.
 * `populate_ifdb_ids.pl` - This script does its best to update the IFDB ID field for every game in the current year's comp.
 * `rebuild_entry_content_dirs` - This script rebuilds the 'content' directory for every entry. Useful if you change what's stored in those directories while a comp is underway.
 * `recreate_web_covers.pl` - Re-processes all the current comp's entries' covers, creating scaled-down versions for use by the ballot webpage. Useful if we wish to change the maximum image size displayed by the ballot.
 * `update_current_rating_tallies` - This script updates various derived-value fields for the current comp's qualified entry records. Can be cron as a regular crontask.

## Database utility scripts

Various scripts for working with the database.

 * `ifcomp_deploy_db.pl` - Deploy (or redeploy) a new IFComp database.
 * `ifcomp_dump_schema.pl` - Update the `IFComp::Schema` classes to match the database.

## Encryption scripts

These PHP scripts are used to provide authentication services to the federated sites. They are called by `IFComp::Controller::Profile`.

 * `decrypt-rijndael-256.php`
 * `encrypt-rijndael-256.php`

## Standard Catalyst Scripts

These are the standard scripts created and used with a Catalyst application. See
each script, or the corresponding perl module for details - eg see
`Catalyst::Script::CGI` for `ifcomp_cgi.pl`.

 * `ifcomp_cgi.pl` - Run a Catalyst application as a cgi script.
 * `ifcomp_create.pl` - Create a new Catalyst Component.
 * `ifcomp_fastcgi.pl` - Run a Catalyst application as fastcgi.
 * `ifcomp_server.pl` - Run a Catalyst Testserver for this application.
 * `ifcomp_test.pl` - Run a Catalyst action from the command line.

