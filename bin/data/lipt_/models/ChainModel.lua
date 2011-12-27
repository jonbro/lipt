numPositions = 16
LChainModel = class(function(o, chainData, song)
	o.chainData = chainData
	o.steps = {}
	-- setup the steps in the chain
	for i=0,numPositions-1 do
		o.steps[i] = {hasPhrase=false,phrase=0}
	end
	-- retain a reference to the song so that we can do loading
	o.song = song
end)

function LChainModel:set(step, value)
	self.chainData:set(step, value)
	self.steps[step] = {hasPhrase=true,phrase=value}
end
function LChainModel:clearStep(step)
	self.steps[step].hasPhrase=false
	self.chainData:clearPhrase(step)
end

function LChainModel:saveTo(data)
	data.steps = self.steps
	return data
end
function LChainModel:loadFrom(data)
	for i,v in pairs(data.steps) do
		if v.hasPhrase then
			print("loading, has phrase")
			self:set(i, v.phrase)
		end
	end	
end