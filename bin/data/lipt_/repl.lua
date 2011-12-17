-- song:setChain(0, 0, 0)    -- sets a channel position to a chain
-- chain = song:getChain(0)  -- gets a chain
-- chain:set(0, 0, 0)      -- set chain to phrase and transpose at position

sample = SampleData()
sample:loadSample(blud.bundle_root .. "/test/test.wav")

instrument = song:getInstrument(0)
instrument:setSample(sample)
-- phrase = song:getPhrase(0)  -- get the phrase
-- phrase:set(0, 60, 0)      -- set position the note, instrument, and effects (to come)

player:setSong(song)
player:startChan(0,0)

