-- Revert pgdd:002 from pg

BEGIN;

	DROP VIEW dd.functions;

	COMMENT ON VIEW dd.schemas IS NULL;
	COMMENT ON VIEW dd.tables IS NULL;
	COMMENT ON VIEW dd.columns IS NULL;

COMMIT;
