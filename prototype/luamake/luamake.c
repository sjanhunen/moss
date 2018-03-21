#include <string.h>
#include <gnumake.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int plugin_is_GPL_compatible;
static lua_State *ls;

char *gm_lua_pcall(const char *nm, unsigned int argc, char **argv)
{
    if(argc >= 1) {
        lua_getglobal(ls, argv[0]);
        for(int i = 1; i < argc; ++i) {
            lua_pushstring(ls, argv[i]);
        }
        int status = lua_pcall(ls, argc - 1, 1, 0);
        const char *msg = lua_tostring(ls, -1);
        if(status) {
            const char *format =
                "define _lua_error_\n"
                "%s\n"
                "endef\n"
                "$(error $(_lua_error_))\n";

            // Formatted string is guaranteed to be shorter than format + msg
            size_t len = strlen(msg) + strlen(format);
            char *err_msg = gmk_alloc(len);
            if(err_msg) {
                snprintf(err_msg, len, format, msg);
                gmk_eval(err_msg, NULL);
            }
        }
        else if(msg != NULL) {
            size_t len = strlen(msg) + 1;
            char *result = gmk_alloc(strlen(msg) + 1);
            if(result) {
                strncpy(result, msg, len);
                return result;
            }
        }
    }

    return NULL;
}

int luamake_gmk_setup ()
{
    ls = luaL_newstate();
    luaL_openlibs(ls);

    gmk_add_function ("lua", gm_lua_pcall, 1, 32, 0);

    return 1;
}

// TODO: where do we lua_close(ls)
