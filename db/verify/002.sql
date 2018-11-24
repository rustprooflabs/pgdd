-- Verify pgdd:002 on pg

BEGIN;

	SELECT * FROM dd.functions 
		WHERE False;

ROLLBACK;
