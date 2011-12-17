#pragma once

#import "FlurryAnalytics.h"
#import "lunar.h"

id lua_objc_topropertylist(lua_State* state,int stack_index);

class bludAnalytics{
    public:
        static const char className[];
        static Lunar<bludAnalytics>::RegType methods[];
        bludAnalytics(lua_State *L) {
        };
        int logEvent(lua_State *L){
            // check to see if we have a table attached to the event code
            if (lua_istable(L, 2)) {
                id table = lua_objc_topropertylist(L, 2);
                [FlurryAnalytics logEvent:[NSString stringWithUTF8String:luaL_checkstring(L, 1)] withParameters:table];
            }else{
                [FlurryAnalytics logEvent:[NSString stringWithUTF8String:luaL_checkstring(L, 1)]];
            }
            return 1;
        };
};