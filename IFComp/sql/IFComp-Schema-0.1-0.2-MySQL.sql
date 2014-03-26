-- Convert schema '/Users/jjohn/src/ifcomp/IFComp/script/../sql/IFComp-Schema-0.1-MySQL.sql' to 'IFComp::Schema v0.1':;

BEGIN;

ALTER TABLE federated_site;

ALTER TABLE user DROP FOREIGN KEY user_fk_site_id,
                 DROP INDEX user_idx_site_id,
                 DROP COLUMN site_id;


COMMIT;

