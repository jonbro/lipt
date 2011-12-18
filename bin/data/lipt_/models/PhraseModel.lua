numPositions = 16
LPhraseModel = class(function(o, phraseData)
	o.phraseData = phraseData
	o.steps = {}
	-- setup the steps in the chain
	for i=0,numPositions-1 do
		o.steps[i] = {hasNote=false,note=0,instrument=0}
	end

end)

function LPhraseModel:set(step, value, instrument)
	self.phraseData:set(step, value, instrument)
	self.steps[step] = {hasNote=true,note=value, instrument=instrument}
end

function LPhraseModel:saveTo(data)
	data.steps = self.steps
	return data
end
function LPhraseModel:loadFrom(data)
	for i,v in pairs(data.steps) do
		if v.hasPhrase then
			self:set(i, v.note, v.instrument)
		end
	end	
end