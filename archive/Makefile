EXTENSION = pgdd
DATA = pgdd--0.1.sql \
		pgdd--0.1.0--0.1.sql \
		pgdd--0.1--0.2.sql \
		pgdd--0.2--0.3.sql \
		pgdd--0.3--0.4alpha1.sql
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
