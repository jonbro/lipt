LInstrumentModel = class(function(o, iData, song)
	o.song = song
	o.iData = iData
	o.loopMode = 2
	o.loopModes = {"none", "loop"}
end)

-- takes a filename
function LInstrumentModel:setSample(sample)
	-- look up to see if the filename is already in use
	if self.song.samples[sample] then
		self.iData:setSample(self.song.samples[sample])
	else
		-- otherwise, attempt to load it
		-- TODO: should copy it into the songs data folder at some point
		-- for now, just load in place
		sd = SampleData()
		fs:loadSample(sample, sd)
		-- store it in the song and the instrument
		self.song.samples[sample] = sd
		self.iData:setSample(sd)
	end
	-- store the sample name so that we can display it in the instrument editor later
	self.sampleName = sample
end
function LInstrumentModel:setLoopMode(value)
	print("setting loop mode", value)
	self.iData:setLoopMode(value-1)
	self.loopMode = value
end
function LInstrumentModel:saveTo(data)
	data.sampleName = self.sampleName
	data.loopMode = self.loopMode
	return data
end
function LInstrumentModel:loadFrom(data)
	if data.sampleName then
		self:setSample(data.sampleName)
	end
	if data.loopMode then
		self:setLoopMode(data.loopMode)
	end
end