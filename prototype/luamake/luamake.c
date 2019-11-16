#include <string.h>
#include <gnumake.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int plugin_is_GPL_compatible;
static lua_State *ls;

static void error(const char *msg)
{
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
        gmk_free(err_msg);
    }
}

static void require(const char *module)
{
    lua_getglobal(ls, "require");
    lua_pushstring(ls, module);
    int status = lua_pcall(ls, 1, 1, 0);
    const char *msg = lua_tostring(ls, -1);
    if(status) {
        error(msg);
    }
}

char *gm_lua_pcall(const char *nm, unsigned int argc, char **argv)
{
    if(argc >= 1) {
        lua_getglobal(ls, "luafile");
        for(int i = 0; i < argc; ++i) {
            lua_pushstring(ls, argv[i]);
        }
        int status = lua_pcall(ls, argc, 1, 0);
        const char *result = lua_tostring(ls, -1);
        if(status) {
            error(result);
        }
        else if(result != NULL) {
            char *definition = gmk_alloc(strlen(result) + 1);
            if (definition) {
                strcpy(definition, result);
                gmk_eval(definition, NULL);
                gmk_free(definition);
            }
        }
    }

    return NULL;
}

int luamake_gmk_setup ()
{
    ls = luaL_newstate();
    luaL_openlibs(ls);

    require("luafile");

    gmk_add_function("luafile", gm_lua_pcall, 1, 32, GMK_FUNC_NOEXPAND);

    return 1;
}

// TODO: where do we lua_close(ls)
