local numChannels = 8
local numPositions = 20
local numDatas = 256

-- should be able to determine the stack of loaded screens from this, and roll them back.
-- like if we are deep in the table should be able to loop back through the instrument, phrase, chain that got us there

LSongModel = class(function(o, songData)
	o.songData = songData
	o.channels = {}
	for i=0,numChannels do
		o.channels[i] = {}
		for j=0,numPositions do
			o.channels[i][j] = {hasChain=false,chain=0}
		end
	end
	-- setup the chains
	o.chains = {}
	for i=0,numDatas-1 do
		o.chains[i] = LChainModel(o.songData:getChain(i), o)
	end

	-- setup the phrases
	o.phrases = {}
	for i=0,numDatas-1 do
		o.phrases[i] = LPhraseModel(o.songData:getPhrase(i), o)
	end
	
	-- setup the instruments
	o.instruments = {}
	for i=0,numDatas-1 do
		o.instruments[i] = LInstrumentModel(o.songData:getInstrument(i), o)
	end

	o.samples = {} -- hold lua refs to the samples that we have loaded so far
	o.tempo = 120
end)
function LSongModel:nextFreeChain()
	for i=0,numDatas-1 do
		if not self.chains[i].used then
			return i
		end
	end
end
function LSongModel:nextFreePhrase()
	for i=0,numDatas-1 do
		if not self.phrases[i].used then
			return i
		end
	end
end
function LSongModel:clearChain(position, channel)
	self.songData:clearChain(channel, position)
	self.channels[channel][position].hasChain = false
end
function LSongModel:setChain(position, channel, value)
	self.songData:setChain(channel, position, value)
	self.channels[channel][position].hasChain = true
	self.channels[channel][position].chain = value
end
function LSongModel:getChain(value)
	return self.chains[math.floor(value)]
end
function LSongModel:getPhrase(value)
	return self.phrases[math.floor(value)]
end
function LSongModel:getInstrument(value)
	return self.instruments[math.floor(value)]
end
function LSongModel:setTempo(value)
	self.tempo = value
	player:setTempo(value)
end
function LSongModel:setPlayer(player)
	self.player = player
end

function LSongModel:saveTo(data)
	data.channels = self.channels
	local toSave = {"chains", "phrases", "instruments"}
	for i,x in pairs(toSave) do
		-- save all the x
		data[x] = {}
		for i,v in pairs(self[x]) do
			data[x][i] = v:saveTo({})
		end
	end
	data.tempo = self.tempo
	return data
end
function LSongModel:loadFrom(data)
	for i,v in pairs(data.channels) do
		for j,v in pairs(v) do
			if v.hasChain then
				self:setChain(j, i, v.chain)
			end
		end
	end
	local toLoad = {"chains", "phrases", "instruments"}
	for i,x in pairs(toLoad) do
		-- load all the x
		if data[x] then
			for i,v in pairs(data[x]) do
				self[x][i]:loadFrom(v)
			end
		end
	end
	if data.tempo then
		self:setTempo(data.tempo)
	end
end