-- Revert pgdd:001 from pg

BEGIN;

	DROP SCHEMA dd CASCADE;

COMMIT;
