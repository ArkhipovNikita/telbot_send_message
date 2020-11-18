-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION telbot" to load this file. \quit

CREATE SCHEMA IF NOT EXISTS telbot;

CREATE TABLE IF NOT EXISTS telbot.conf (
    key VARCHAR(100) PRIMARY KEY,
    value VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS telbot.sent_messages (
    id SERIAL PRIMARY KEY,
    datetime TIMESTAMP,
    message TEXT
);

-- When pg_dump these tables and sequences will be dumped
-- If it's not necessary, comment out it
SELECT pg_catalog.pg_extension_config_dump('telbot.conf', '');
SELECT pg_catalog.pg_extension_config_dump('telbot.sent_messages', '');
SELECT pg_catalog.pg_extension_config_dump('telbot.sent_messages_id_seq', '');

CREATE FUNCTION telbot.set_param(param varchar(100), val varchar(100)) RETURNS void 
    AS $$ INSERT INTO telbot.conf VALUES (param, val) ON CONFLICT (key) DO UPDATE SET value = val WHERE telbot.conf.key = param $$ 
    LANGUAGE SQL;

CREATE FUNCTION telbot.set_chat_id(param varchar(100)) RETURNS void 
    AS $$ INSERT INTO telbot.conf VALUES ('chat_id', param) $$
    LANGUAGE SQL;

CREATE FUNCTION telbot.set_token(param varchar(100)) RETURNS void 
    AS $$ INSERT INTO telbot.conf VALUES ('token', param) $$
    LANGUAGE SQL;

CREATE FUNCTION telbot.send_message(chat_id varchar(50), token text, message text) RETURNS BOOLEAN
    AS '$libdir/telbot'
    LANGUAGE C STRICT;

CREATE FUNCTION telbot.send_message_confd(message text) 
    RETURNS BOOLEAN AS $$
        DECLARE 
            passed BOOLEAN;
            chat_id VARCHAR(100);
            token VARCHAR(100);
        BEGIN
            SELECT value INTO chat_id FROM telbot.conf WHERE key = 'chat_id';
            SELECT value INTO token FROM telbot.conf WHERE key = 'token';
            IF chat_id IS NULL OR token IS NULL THEN
                RAISE EXCEPTION 'Not all parametrs are configured';
            END IF;
            SELECT telbot.send_message(chat_id, token, message) INTO passed;
            IF passed THEN
                INSERT INTO telbot.sent_messages (datetime, message) VALUES (now(), message);
            END IF;
            RETURN passed;
        END;
    $$ LANGUAGE plpgsql;
