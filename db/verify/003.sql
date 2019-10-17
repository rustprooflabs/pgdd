-- Verify pgdd:003 on pg

BEGIN;

	SELECT s_name, v_name, description
		FROM dd.views
		WHERE False;

ROLLBACK;
