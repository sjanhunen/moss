#include <string.h>
#include <gnumake.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int plugin_is_GPL_compatible;
static lua_State *ls;

char *gm_luamake(const char *nm, unsigned int argc, char **argv)
{
    int status = luaL_dostring(ls, argv[0]);
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
    gmk_add_function ("lua", gm_luamake, 1, 1, 0);
    return 1;
}

// TODO: where do we lua_close(ls)
