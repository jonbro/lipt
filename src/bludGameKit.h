// a minimal wrapper around a tiny chunk of game kit

// connect
// send
// receive

#pragma once
#import <GameKit/GameKit.h>
#import "lunar.h"
#include "ofTypes.h"
#include "ofLog.h"
#import "bludLock.h"
#import "ofxiPhoneExtras.h"
#import "NSData+AESCrypt.h"

class bludGK;

@interface bludGKDelegate : NSObject <GKMatchDelegate>
{
	bludGK *gk;
}
- (id) init: (bludGK *) _gk;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end

@interface bludGKAchievementViewController : UIViewController <GKAchievementViewControllerDelegate>
{
	bludGK *gk;
    bool completedLoading;
}
- (id) init: (bludGK *) _gk;
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
- (void)viewDidAppear:(BOOL)animated;
@end

class bludGK {
public:
	GKMatch *myMatch;
    bludGKAchievementViewController *avc;
	static const char className[];
	static Lunar<bludGK>::RegType methods[];
	bludGK(lua_State *L) {
        connected = false;
        mutex = bludLock::getInstance();
        hasAchievementView = false;
    }
	
    int connect(lua_State *L);
    int getFriends(lua_State *L);
    int getId(lua_State *L);
    int getHashedId(lua_State *L);
    int reportAchievementProgress(lua_State *L);
    void getFriendData(NSArray *identifiers, lua_State *L, int function);
	void createMatch();
    int displayAchievementView(lua_State *L);
    int isConnected(lua_State *L);
    void completeAchievementView();
	int sendData(lua_State *L){
		NSMutableData *dataToSend = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
		[archiver encodeObject:[NSString stringWithUTF8String:luaL_checkstring(L, 1)] forKey: [NSString stringWithString:@"data"]];
		[archiver finishEncoding];
		NSError* error;
		//int reliableEnum = GKMatchSendDataReliable;
		int reliableEnum = GKMatchSendDataUnreliable; 
		if ( ! [this->myMatch sendDataToAllPlayers:dataToSend withDataMode:reliableEnum error:&error])
		{
			if (error != nil) {
				NSLog(@"error=%@", [error localizedDescription]);
			}
		}
		[archiver release];
		[dataToSend release];
		return 1;
	}
	~bludGK() {}
private:
    ofMutex* mutex;
	bludGKDelegate *delegate;
    bool connected, hasAchievementView;
    int connectCallback, achievementViewComplete;
    NSError *error;
    lua_State *lua;
};
