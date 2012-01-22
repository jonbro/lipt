#import "PFileSystem.h"

const char PFileSystem::className[] = "PFileSystem";

Lunar<PFileSystem>::RegType PFileSystem::methods[] = {
	method(PFileSystem, enumerate),
	method(PFileSystem, isDirectory),
	method(PFileSystem, loadSample),
	{0,0}
};


int PFileSystem::enumerate(lua_State *L){
    char **rc = PHYSFS_enumerateFiles(luaL_checkstring(L, 1));
    char **i;
    lua_newtable(L);    /* We will pass a table */
    int count = 1;
    for (i = rc; *i != NULL; i++){
        lua_pushnumber(L, count);   /* Push the table index */
        lua_pushstring(L, *i); /* Push the cell value */
        lua_rawset(L, -3);      /* Stores the pair in the table */
        count++;
    }
    PHYSFS_freeList(rc);
    return 1;
}
int PFileSystem::isDirectory(lua_State *L){
    lua_pushboolean(L, PHYSFS_isDirectory(luaL_checkstring(L, 1)));
    return 1;
}

// https://github.com/dichodaemon/flatland/blob/master/src/flatland/SoundBuffer.cpp

int PFileSystem::loadSample(lua_State *L){

    AudioFileID myAudioFileID = 0;
    ExtAudioFileRef inputFile;
    OSStatus result;
    // load the file from physfs
    PHYSFS_file* myfile = PHYSFS_openRead(luaL_checkstring(L, 1));
    result = AudioFileOpenWithCallbacks(myfile, MyAudioFile_ReadProc, NULL, MyAudioFile_GetSizeProc, NULL, 0, &myAudioFileID);
    NSLog(@"open with callbacks %@", result);
    result = ExtAudioFileWrapAudioFileID(myAudioFileID, false, &inputFile);
    NSLog(@"file wrap %@", result);
    // grab the buffers from the file

    
    AudioStreamBasicDescription inputFileFormat;
    
    UInt32 propSize = sizeof( AudioStreamBasicDescription );
    ExtAudioFileGetProperty( 
                            inputFile, kExtAudioFileProperty_FileDataFormat, &propSize, &inputFileFormat 
                            );
    
    AudioStreamBasicDescription outputFormat = {0};
    outputFormat.mSampleRate       = inputFileFormat.mSampleRate; 
    outputFormat.mFormatID         = kAudioFormatLinearPCM; 
    outputFormat.mFormatFlags      = kAudioFormatFlagsCanonical;
    outputFormat.mChannelsPerFrame = inputFileFormat.mChannelsPerFrame; 
    outputFormat.mBitsPerChannel   = 16;
    
    propSize = sizeof( AudioStreamBasicDescription ); 
    AudioFormatGetProperty( 
                           kAudioFormatProperty_FormatInfo, 0, NULL, &propSize, &outputFormat
                           );
    
    ExtAudioFileSetProperty( 
                            inputFile, 
                            kExtAudioFileProperty_ClientDataFormat, 
                            sizeof( outputFormat ), 
                            &outputFormat
                            );
    
    SInt64 inputFileLengthInFrames; 
    propSize = sizeof(SInt64); 
    ExtAudioFileGetProperty(
                            inputFile, 
                            kExtAudioFileProperty_FileLengthFrames, 
                            &propSize, 
                            &inputFileLengthInFrames
                            );
    
    UInt32 dataSize = ( inputFileLengthInFrames * outputFormat.mBytesPerFrame ); 
    void *theData = malloc( dataSize ); 
    AudioBufferList dataBuffer; 
    dataBuffer.mNumberBuffers = 1;
    dataBuffer.mBuffers[0].mDataByteSize = dataSize; 
    dataBuffer.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
    dataBuffer.mBuffers[0].mData = theData;

    ExtAudioFileRead( inputFile, (UInt32*)&inputFileLengthInFrames, &dataBuffer ); 
    
    printf("num buffers: %lu\n", dataBuffer.mBuffers[0].mDataByteSize);
    
    // copy the buffers out
    // should failout earlier if we don't have a sample
    SampleData *s = Lunar<SampleData>::check(L, 2);
    
    s->sample.myData = (char *)dataBuffer.mBuffers[0].mData;
    s->sample.length = inputFileLengthInFrames;
    s->sample.hasData = false;
    return 1;
}

static OSStatus MyAudioFile_ReadProc(void *inClientData, SInt64 inPosition, UInt32 requestCount, void *buffer, UInt32 *actualCount)
{
    // seek to the proper position
    PHYSFS_seek((PHYSFS_File*)inClientData, inPosition);
    *actualCount = PHYSFS_read((PHYSFS_File*)inClientData, buffer, sizeof(char), requestCount);
    return noErr;
}

static SInt64 MyAudioFile_GetSizeProc (void  *inClientData){
    return PHYSFS_fileLength((PHYSFS_File*)inClientData);
}
