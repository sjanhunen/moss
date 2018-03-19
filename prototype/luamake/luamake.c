#include <string.h>
#include <gnumake.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int plugin_is_GPL_compatible;
static lua_State *ls;

char *gm_lua_dostring(const char *nm, unsigned int argc, char **argv)
{
    // TODO: add proper error handling
    int status = luaL_dostring(ls, argv[0]);
    if(status) {
        const char *msg = lua_tostring(ls, -1);
        char *buf = gmk_alloc(strlen(msg) + 1);
        strcpy(buf, msg);
        return buf;
    }

    return 0;
}

char *gm_lua_pcall(const char *nm, unsigned int argc, char **argv)
{
    // TODO: add proper error handling
    lua_getglobal(ls, argv[0]);
    int status = lua_pcall(ls, 0, 0, 0);
    if(status) {
        const char *msg = lua_tostring(ls, -1);
        char *buf = gmk_alloc(strlen(msg) + 1);
        strcpy(buf, msg);
        return buf;
    }

    return 0;
}

int luamake_gmk_setup ()
{
    ls = luaL_newstate();
    luaL_openlibs(ls);
    gmk_add_function ("lua-dostring", gm_lua_dostring, 1, 1, 0);
    gmk_add_function ("lua-pcall", gm_lua_pcall, 1, 1, 0);
    return 1;
}

// TODO: where do we lua_close(ls)
