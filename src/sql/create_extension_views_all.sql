CREATE OR REPLACE VIEW dd.schemas AS
SELECT * FROM dd.schemas()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.tables AS
SELECT * FROM dd.tables()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.views AS
SELECT * FROM dd.views()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.columns AS
SELECT * FROM dd.columns()
    WHERE NOT system_object
;

CREATE OR REPLACE VIEW dd.functions AS
SELECT * FROM dd.functions()
    WHERE NOT system_object
;


COMMENT ON VIEW dd.schemas IS 'Data dictionary view: Lists schemas, excluding system schemas.';
COMMENT ON VIEW dd.tables IS 'Data dictionary view: Lists tables, excluding system tables.';
COMMENT ON VIEW dd.views IS 'Data dictionary view: Lists views, excluding system views.';
COMMENT ON VIEW dd.columns IS 'Data dictionary view: Lists columns, excluding system columns.';
COMMENT ON VIEW dd.functions IS 'Data dictionary view: Lists functions, excluding system functions.';

COMMENT ON FUNCTION dd.about IS 'Basic details about PgDD extension';

COMMENT ON FUNCTION dd.schemas IS 'Data dictionary function: Lists all schemas';
COMMENT ON FUNCTION dd.tables IS 'Data dictionary function: Lists all tables';
COMMENT ON FUNCTION dd.views IS 'Data dictionary function: Lists all views.';
COMMENT ON FUNCTION dd.columns IS 'Data dictionary function: Lists all columns';
COMMENT ON FUNCTION dd.functions IS 'Data dictionary function: Lists all functions';
