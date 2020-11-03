EXTENSION = telbot_send_message
MODULE_big = telbot_send_message

CURL_CONFIG = curl-config
PG_CONFIG = pg_config
DATA = telbot_send_message--0.0.1.sql
OBJS = telbot_send_message.o

CFLAGS += $(shell $(CURL_CONFIG) --cflags)
LIBS += $(shell $(CURL_CONFIG) --libs)
SHLIB_LINK := $(LIBS)

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
