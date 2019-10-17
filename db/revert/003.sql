-- Revert pgdd:003 from pg

BEGIN;

	DROP VIEW dd.views;

COMMIT;
