EXTENSION = telbot
MODULE_big = telbot

CURL_CONFIG = curl-config
PG_CONFIG = pg_config
DATA = telbot--0.0.1.sql
OBJS = telbot.o

CFLAGS += $(shell $(CURL_CONFIG) --cflags)
LIBS += $(shell $(CURL_CONFIG) --libs)
SHLIB_LINK := $(LIBS)

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
