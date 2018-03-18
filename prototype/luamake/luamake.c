#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(int argc, char *argv[])
{
    lua_State *ls;
    int status;

    ls = luaL_newstate();

    if(argc > 1) {
        status = luaL_dostring(ls, argv[1]);
        if(status) {
            printf("ERROR: %s\n", lua_tostring(ls, -1));
        }
    }

    lua_close(ls);

    return 0;
}
