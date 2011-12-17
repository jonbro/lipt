/*
 *  bludGameKit.mm
 *  ld48_21
 *
 *  Created by jonbroFERrealz on 9/3/11.
 *  Copyright 2011 Heavy Ephemera Industries. All rights reserved.
 *
 */


#import "bludGameKit.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonCryptor.h>

void bludGK::createMatch() {
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            // Process the error.
            NSLog(@"error: %@", error);
        }
        else if (match != nil)
        {
            this->myMatch = [match retain];
            this->delegate = [[bludGKDelegate alloc] init:this];
            this->myMatch.delegate = this->delegate;
            NSLog(@"found match");
        }
    }];	
}

int bludGK::connect(lua_State *L) {
    if(lua_isfunction(L, 1)){
        // push the value of the function (that is at position 1), onto the top of the stack
        lua_pushvalue(L, 1);
        // store this stack position in the registry index
        connectCallback = luaL_ref(L, LUA_REGISTRYINDEX);
    }else{
        // should raise an error here.
    }
    // this is the meat of the game center connection, handles setting up game kit and connecting to a match.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            lua_rawgeti( L, LUA_REGISTRYINDEX, connectCallback );
            if(lua_pcall(L, 0, 0, 0) != 0){
                ofLog(OF_LOG_ERROR, "connect callback error");
                ofLog(OF_LOG_ERROR, lua_tostring(L, -1));
            }
            this->connected = true;
        }else {
            NSLog(@"connection error: %@", [error description]);
            this->error = error;
        }
    }];
    return 1;
}
int bludGK::isConnected(lua_State *L) {
    lua_pushboolean(L, this->connected);
    return 1;
}
int bludGK::getId(lua_State *L) {
    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
    lua_pushstring(L, [lp.playerID cStringUsingEncoding:NSASCIIStringEncoding]);
    return 1;
}

// returns a hashed and salted id to lua so that this client can be authenticated to the server
int bludGK::getHashedId(lua_State *L) {
    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
    lua_pushstring(L, [[[lp.playerID stringByAppendingString:@"uwNhwzjksp6k^cjr3yqky"] MD5] cStringUsingEncoding:NSASCIIStringEncoding]);
    return 1;    
}
int bludGK::getFriends(lua_State *L) {
    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
    int lfInt;
    if(lua_isfunction(L, 1)){
        // push the value of the function (that is at position 1), onto the top of the stack
        lua_pushvalue(L, 1);
        // store this stack position in the registry index
        lfInt = luaL_ref(L, LUA_REGISTRYINDEX);
    }
    if (lp.authenticated)
    {
        [lp loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
            if (friends != nil)
            {
                // should hit the lua with the data in the friends, or even better, provide a user data object that could be further manipulated by the lua
                this->getFriendData(friends, L, lfInt);
                //[self loadPlayerData: friends];
            }
        }];
    }
    return 1;
}
int bludGK::reportAchievementProgress(lua_State *L) {
    int lfInt;
    if(lua_isfunction(L, 3)){
        // push the value of the function (that is at position 1), onto the top of the stack
        lua_pushvalue(L, 3);
        // store this stack position in the registry index
        lfInt = luaL_ref(L, LUA_REGISTRYINDEX);
    }
    // todo: should throw an error here if we don't have a completion callback
    NSString *identifier = [[NSString alloc] initWithCString:luaL_checkstring(L, 1) encoding:NSASCIIStringEncoding];
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
    NSLog(@"achievement ident: %@", identifier);
    achievement.showsCompletionBanner = YES;
    
    __block bool e = false;
    if (achievement)
    {
        achievement.percentComplete = luaL_checknumber(L, 2);
        NSLog(@"achievement percent: %f", achievement.percentComplete);
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 e = true;
                 NSLog(@"error: %@", error);
             }
             
             mutex->lock();
             lua_rawgeti( L, LUA_REGISTRYINDEX, lfInt );
             lua_pushboolean(L, e);
             if(lua_pcall(L, 1, 0, 0) != 0){
                 ofLog(OF_LOG_ERROR, "achievement callback error");
                 ofLog(OF_LOG_ERROR, lua_tostring(L, -1));
             }
             mutex->unlock();
         }];
    }else{
        NSLog(@"couldn't load achievement");
    }
    return 1;
}
void bludGK::getFriendData(NSArray *identifiers, lua_State *L, int function) {
    __block GKPlayer *player;
    __block NSEnumerator *e;
    __block NSMutableArray *toLua = [[NSMutableArray alloc]init];
    [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil)
        {
            // Handle the error.
        }
        if (players != nil)
        {
            // this should be passed back into lua as a data table.
            NSLog(@"friends %@", players);
            e = [players objectEnumerator];
            
            while (player = [e nextObject]) {
                [toLua addObject:[[NSString alloc] initWithFormat:@"{[\"playerID\"]=\"%@\", [\"alias\"]=\"%@\", [\"status\"]=\"\"}", player.playerID, player.alias]];
            }
            
            // construct a string representation of the player array
            lua_rawgeti( L, LUA_REGISTRYINDEX, function );
//            test = string([[[NSString alloc]initWithFormat:@"return {%s};", [toLua componentsJoinedByString:@","]]cStringUsingEncoding:NSASCIIStringEncoding]).c_str();
//            cout << "friend value: " << test << endl;
            NSLog(@"%@", toLua);
            NSLog(@"%@", [[NSString alloc]initWithFormat:@"return {%@};", [toLua componentsJoinedByString:@","]]);
            lua_pushstring(L, [[[NSString alloc]initWithFormat:@"return {%@};", [toLua componentsJoinedByString:@","]]cStringUsingEncoding:NSASCIIStringEncoding]);
            if(lua_pcall(L, 1, 0, 0) != 0){
                ofLog(OF_LOG_ERROR, "friend data callback error");
                ofLog(OF_LOG_ERROR, lua_tostring(L, -1));
            }
        }
    }];
}
int bludGK::displayAchievementView(lua_State *L) {
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if(lua_isfunction(L, 1)){
        // push the value of the function (that is at position 1), onto the top of the stack
        lua_pushvalue(L, 1);
        // store this stack position in the registry index
        achievementViewComplete = luaL_ref(L, LUA_REGISTRYINDEX);
        lua = L;
    }
    if (achievements != nil)
    {
        if(hasAchievementView){
            [avc release];
        } 
        avc = [[bludGKAchievementViewController alloc] init:this];
        hasAchievementView = true;
        achievements.achievementDelegate = avc;
        [avc presentModalViewController:achievements animated:YES];
    }else{
        // call the completion immedietaly 
        lua_rawgeti( lua, LUA_REGISTRYINDEX, achievementViewComplete );
        if(lua_pcall(lua, 0, 0, 0) != 0){
            ofLog(OF_LOG_ERROR, "achievement view callback error");
            ofLog(OF_LOG_ERROR, lua_tostring(lua, -1));
        }
    }
    [achievements release];
    return 1;
}
void bludGK::completeAchievementView(){
    mutex->lock();
    lua_rawgeti( lua, LUA_REGISTRYINDEX, achievementViewComplete );
    if(lua_pcall(lua, 0, 0, 0) != 0){
        ofLog(OF_LOG_ERROR, "achievement view callback error");
        ofLog(OF_LOG_ERROR, lua_tostring(lua, -1));
    }
    mutex->unlock();
}
const char bludGK::className[] = "bludGK";

Lunar<bludGK>::RegType bludGK::methods[] = {
	method(bludGK, connect),
    method(bludGK, isConnected),
	method(bludGK, sendData),
    method(bludGK, getFriends),
    method(bludGK, getId),
    method(bludGK, getHashedId),
    method(bludGK, reportAchievementProgress),
    method(bludGK, displayAchievementView),
	{0,0}
};

@implementation bludGKDelegate

//--------------------------------------------------------------
- (id) init: (bludGK *) _gk
{
	if(self = [super init])
	{			
		
		gk = _gk;
	}
	return self;
}
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if ([unarchiver containsValueForKey:@"data"])
    {
        NSString *data =[unarchiver decodeObjectForKey:@"data"];
		NSLog(@"just got data: %@", data);
	}
}
@end


@implementation bludGKAchievementViewController
- (id) init: (bludGK *) _gk
{
    completedLoading = false;
	if(self = [super init])
	{
		gk = _gk;
        // make our view a full screen thing, and attach to the ofx view
        CGSize size = [ofxiPhoneGetUIWindow() frame].size;
        [self.view setFrame:CGRectMake(0,0, size.width, size.height)];
        [ofxiPhoneGetUIWindow() addSubview:self.view];
        [ofxiPhoneGetUIWindow() makeKeyAndVisible];
	}
    completedLoading = true;    
    return self;
}
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    // callback to the achievement screen being dismissed
    gk->completeAchievementView();
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"view came back");
    if (completedLoading) {
        [self.view removeFromSuperview];
    }
}
@end
