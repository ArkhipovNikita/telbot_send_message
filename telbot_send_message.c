#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include <stdio.h>
#include <curl/curl.h>


PG_MODULE_MAGIC;
PG_FUNCTION_INFO_V1(telbot_send_message);


Datum telbot_send_message(PG_FUNCTION_ARGS) {
    CURL *curl;
    CURLcode res;

    int chatId = PG_GETARG_INT32(0);
    text *token = PG_GETARG_TEXT_P(1);
    text *message = PG_GETARG_TEXT_P(2);

    curl_global_init(CURL_GLOBAL_ALL);

    curl = curl_easy_init();
    if (curl) {
        char* url = (char*)malloc(VARSIZE(token) * sizeof(char));
        sprintf(url, "https://api.telegram.org/bot%s/sendMessage", VARDATA(token));
        curl_easy_setopt(curl, CURLOPT_URL, url);
        char* parametrs = (char*)malloc(VARSIZE(message) * sizeof(char));
        sprintf(parametrs, "chat_id=%d&text=%s", chatId, curl_easy_escape(curl, VARDATA(message), VARSIZE(message)));
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, parametrs);


        res = curl_easy_perform(curl);
        if(res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\n",
                    curl_easy_strerror(res));
            PG_RETURN_BOOL(false);
        }

        curl_easy_cleanup(curl);
    }
    curl_global_cleanup();
    PG_RETURN_BOOL(true);
}
