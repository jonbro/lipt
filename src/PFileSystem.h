// a wrapper around some of physicsfs

#pragma once
#include "lunar.h"
#include "physfs.h"
#include "SongModel.h"
#import <AudioToolbox/AudioToolbox.h>

class PFileSystem {
public:
	static const char className[];
	static Lunar<PFileSystem>::RegType methods[];
	PFileSystem(lua_State *L) {
    }
    int enumerate(lua_State *L);
    int isDirectory(lua_State *L);
    int loadSample(lua_State *L);
	~PFileSystem() {}
};

static OSStatus MyAudioFile_ReadProc(void *inClientData, SInt64   inPosition, UInt32 requestCount, void *buffer, UInt32 *actualCount);
static SInt64 MyAudioFile_GetSizeProc (void  *inClientData);

static void printErrorMessage(NSString *errorString, OSStatus result ){
    
    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';
    
    NSLog (@"*** %@ error: %@ %08X %4.4s\n", errorString, (char*) &resultString);
};

static void CheckResult(OSStatus error, const char *operation)
{
	if (error == noErr) return;
	char errorString[20]; 
	// See if it appears to be a 4-char-code 
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error); 
	if (isprint(errorString[1]) && isprint(errorString[2]) && 
		isprint(errorString[3]) && isprint(errorString[4])) { 
		errorString[0] = errorString[5] = '\''; 
		errorString[6] = '\0';
	} else 
		// No, format it as an integer 
		sprintf(errorString, "%d", (int)error);
    
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString); 
	exit(1);
}