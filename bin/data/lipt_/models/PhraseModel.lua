numPositions = 16
LPhraseModel = class(function(o, phraseData, song)
	o.phraseData = phraseData
	o.steps = {}
	-- setup the steps in the chain
	for i=0,numPositions-1 do
		o.steps[i] = {hasNote=false,note=0,instrument=0}
	end
	-- retain a reference to the song so that we can do loading
	o.song = song
end)

function LPhraseModel:set(step, value, instrument)
	self.phraseData:set(step, value, instrument)
	self.steps[step] = {hasNote=true,note=value, instrument=instrument}
	self.song.last_note = value
end
function LPhraseModel:clearNote(step)
	self.phraseData:clearNote(step)
	self.steps[step] = {hasNote=false}
end
function LPhraseModel:saveTo(data)
	data.steps = self.steps
	return data
end
function LPhraseModel:loadFrom(data)
	for i,v in pairs(data.steps) do
		if v.hasNote then
			self:set(i, v.note, v.instrument)
		end
	end	
end