local numChannels = 8
local numPositions = 20
local numDatas = 128
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
		o.chains[i] = LChainModel(o.songData:getChain(i))
	end

end)

function LSongModel:setChain(position, channel, value)
	self.songData:setChain(channel, position, value)
	self.channels[channel][position].hasChain = true
	self.channels[channel][position].chain = value
end
function LSongModel:getChain(value)
	-- this should return the LChainModel at some point
	return self.chains[math.floor(value)]
end
function LSongModel:getPhrase(value)
	-- this should return the LPhraseModel at some point
	return self.songData:getPhrase(value)
end
function LSongModel:getInstrument(value)
	-- this should return the LInstrumentModel at some point
	return self.songData:getInstrument(value)
end

function LSongModel:saveTo(data)
	data.channels = self.channels
	-- save all the chains
	data.chains = {}
	for i,v in pairs(self.chains) do
		data.chains[i] = v:saveTo({})
	end
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
	-- load up the chains
	for i,v in pairs(data.chains) do
		self.chains[i]:loadFrom(v)
	end
end