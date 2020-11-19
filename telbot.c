#include "postgres.h"
#include "fmgr.h"
#include "utils/builtins.h"
#include <stdio.h>
#include <curl/curl.h>


PG_MODULE_MAGIC;
PG_FUNCTION_INFO_V1(send_message);

Datum send_message(PG_FUNCTION_ARGS) {
    CURL *curl;
    CURLcode res;

    char *chatId = TextDatumGetCString(PG_GETARG_DATUM(0));
    char *token = TextDatumGetCString(PG_GETARG_DATUM(1));
    char *message = TextDatumGetCString(PG_GETARG_DATUM(2));

    curl_global_init(CURL_GLOBAL_ALL);

    curl = curl_easy_init();
    if (curl) {
        int parametrAmount = 2;
        int parametrNamesLength = 11;
        int messageLength = strlen(message);
        int chatIdLength = strlen(chatId);
        int tokenLength = strlen(token);

        char* urlBase = "https://api.telegram.org/bot%s/sendMessage";
        char* url = (char*)malloc((tokenLength + strlen(urlBase) - 2) * sizeof(char));
        sprintf(url, urlBase, token);
        
        curl_easy_setopt(curl, CURLOPT_URL, url);

        char* escapedMessage = curl_easy_escape(curl, message, messageLength);

        messageLength = strlen(escapedMessage);
        int generalLength = parametrNamesLength + (parametrAmount - 1) + parametrAmount + messageLength + chatIdLength;

        char *parametrs = (char *) malloc(generalLength * sizeof(char));
        sprintf(parametrs, "chat_id=%s&text=%s", chatId, escapedMessage);

        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, strlen(parametrs));
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, parametrs);

        res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            fprintf(stderr, "curl_easy_perform() failed: %s\ntoken: %s\nchat_id: %s\n",
                    curl_easy_strerror(res), token, chatId);
            PG_RETURN_BOOL(false);
        }

        curl_easy_cleanup(curl);
    }
    curl_global_cleanup();
    PG_RETURN_BOOL(true);
}
