#include <stdlib.h>
#include <stdio.h>

#include <sqlite3ext.h>
#include <json.h>

#include "json-functions.h"

SQLITE_EXTENSION_INIT1

__attribute__((visibility("default")))
int sqlite3_extension_init(sqlite3 *db, char **pzErr,
        const sqlite3_api_routines *pApi) {
    SQLITE_EXTENSION_INIT2(pApi);

    sqlite3_create_function_v2(db, "json_extract",
        // args
        -1, SQLITE_UTF8 | SQLITE_DETERMINISTIC,
        // private
        (void *)json_tokener_new(),
        // function
        json_extract_func,
        // for aggregates
        NULL, NULL,
        // destroy
        (void(*)(void*))json_tokener_free);

    sqlite3_create_function_v2(db, "json_unquote",
        // args
        1, SQLITE_UTF8 | SQLITE_DETERMINISTIC,
        // private
        (void *)json_tokener_new(),
        // function
        json_unquote_func,
        // for aggregates
        NULL, NULL,
        // destroy
        (void(*)(void*))json_tokener_free);

    return SQLITE_OK;
}
