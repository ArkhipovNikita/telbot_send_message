CREATE OR REPLACE FUNCTION telbot_send_message(chat_id int, token text, message text) RETURNS boolean
AS '$libdir/telbot_send_message'
LANGUAGE C STRICT;
