-- song:setChain(0, 0, 0)    -- sets a channel position to a chain
-- chain = song:getChain(0)  -- gets a chain
-- chain:set(0, 0, 0)      -- set chain to phrase and transpose at position

sample = SampleData()
-- sample:loadSample(blud.bundle_root .. "/test/guitar2d.wav")

instrument = song.songData:getInstrument(0)
fs = PFileSystem();
fs:loadSample("sampleLib/Bari_Sax_Db1.mp3", sample)
instrument:setSample(sample)

-- sample2 = SampleData()
-- sample2:loadSample(blud.bundle_root .. "/test/test.wav")

-- instrument = song.songData:getInstrument(1)
-- instrument:setSample(sample2)

-- phrase = song:getPhrase(0)  -- get the phrase
-- phrase:set(0, 60, 0)      -- set position the note, instrument, and effects (to come)

player:setSong(song.songData)
player:startChan(1,0)

-- mainState = PlayState();

-- print("here")


-- -- This function will return a string filetree of all files
-- -- in the folder and files in all subfolders
-- function recursiveEnumerate(folder, fileTree)

--     local filesTable = fs:enumerate(folder)
--     for i,v in ipairs(filesTable) do
--         local file = folder.."/"..v
--         if not fs:isDirectory(file) then
--             fileTree = fileTree.."\n"..file
--         elseif fs:isDirectory(file) then
--             fileTree = fileTree.."\n"..file.." (DIR)"
--             fileTree = recursiveEnumerate(file, fileTree)
--         end
--     end
--     return fileTree
-- end

-- filesString = recursiveEnumerate("", "")

-- print(filesString)