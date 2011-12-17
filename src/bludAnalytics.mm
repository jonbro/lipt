/*
 *  bludAnalytics.cpp
 *  spaceHero
 *
 *  Created by jonbroFERrealz on 6/1/11.
 *  Copyright 2011 Heavy Ephemera Industries. All rights reserved.
 *
 */


#include "bludAnalytics.h"

const char bludAnalytics::className[] = "bludAnalytics";

Lunar<bludAnalytics>::RegType bludAnalytics::methods[] = {
	method(bludAnalytics, logEvent),
	{0,0}
};

// this code came from http://gusmueller.com/lua/
/*
 LICENSE:
 Copyright (c) 2006, Flying Meat Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 Neither the name of the Flying Meat nor the names of its contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 It would also be cool if you put something in the about box that you're using
 the LuaCore framework.
 */

id lua_objc_topropertylist(lua_State* state,int stack_index){
	if(stack_index<0){
		stack_index=lua_gettop(state)+(stack_index+1);
    }
    
	//
	// Convert the value on the top of the stack
	//
    
	id result;
	switch(lua_type(state,stack_index)){
            
            //
            // Numbers
            //
            
		case LUA_TNUMBER:{
			result=[NSNumber numberWithDouble:lua_tonumber(state,stack_index)];
			break;
        }
            
            //
            // Boolean values
            //
            
		case LUA_TBOOLEAN:{
			result=[NSNumber numberWithBool:lua_toboolean(state,stack_index)];
			break;
        }
            
            //
            // Strings
            //
            
		case LUA_TSTRING:{
			result=[NSString stringWithUTF8String:lua_tostring(state,stack_index)];
			break;
        }
            
            //
            // Tables
            //
            
		case LUA_TTABLE:{
			NSMutableArray* keys=[NSMutableArray array];
			NSMutableArray* values=[NSMutableArray array];
			double key;
			BOOL array=YES;
			lua_pushnil(state);
			for(key=1;lua_next(state,stack_index);key++){
                
				//
				// If the Lua Table has so far conformed to the conditions for an array...
				//
                
				if(array){
                    
					//
					// ..but this key either not a number, or not the number we expect..
					//
					
					if((lua_type(state,-2)!=LUA_TNUMBER)||(key!=lua_tonumber(state,-2))){
                        
						//
						// ..nor is it the "n" key accompanied by a number indicating the size of the array...
						//
                        
						if((lua_type(state,-2)!=LUA_TSTRING)||(strcmp(lua_tostring(state,-2),"n")!=0)||(lua_type(state,-1)!=LUA_TNUMBER)){
                            
							//
							// ..then this table is not an array, it's a dictionary.
							//
                            
							array=NO;
                        }
                    }
                }
				[values addObject:lua_objc_topropertylist(state,-1)];
				[keys addObject:lua_objc_topropertylist(state,-2)];
				lua_pop(state,1);
            }
			if(array){
				result=values;
            }
			else{
				result=[NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
            }
			break;
        }
            
            //
            // All other Lua types are treated as Null values
            //
            
		case LUA_TFUNCTION:
		case LUA_TUSERDATA:
		case LUA_TNIL:
		case LUA_TTHREAD:
		case LUA_TLIGHTUSERDATA:
		default:{
			result=[NSNull null];
			break;
        }
    }
    
	return result;
}
