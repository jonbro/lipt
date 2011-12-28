local effectTypes = {"----", "VOLM", "PLOF"}
numPositions = 16
LPhraseModel = class(function(o, phraseData, song)
	o.phraseData = phraseData
	o.steps = {}
	-- setup the steps in the chain
	for i=0,numPositions-1 do
		o.steps[i] = {
			hasNote=false,
			note=0,
			instrument=0,
			hasEffect1=false,
			effect1Type=0,
			effect1Val1=0,
			effect1Val2=0,
			hasEffect2=false,
			effect2Type=0,
			effect2Val1=0,
			effect2Val2=0
		}
	end
	-- retain a reference to the song so that we can do loading
	o.song = song
end)

function LPhraseModel:set(step, value, instrument)
	self.phraseData:set(step, value, instrument)
	self.steps[step].hasNote=true;
	self.steps[step].note=value;
	self.steps[step].instrument=instrument
	self.song.last_note = value
end
function LPhraseModel:clearNote(step)
	self.phraseData:clearNote(step)
	self.steps[step] = {hasNote=false}
end
function LPhraseModel:setEffect(step, column, effectType, val1, val2)
	print("setting effect", effectType, val1, val2)
	if effectType == 0 then
		self.steps[step]["hasEffect" .. column] = false
		self.phraseData:removeEffect(step, column)
	else
		self.steps[step]["hasEffect" .. column] = true
		self.steps[step]["effect" .. column .. "Type"] = effectType
		self.steps[step]["effect" .. column .. "Val1"] = val1
		self.steps[step]["effect" .. column .. "Val2"] = val2
		self.phraseData:setEffect(step, column, effectType, val1, val2)
	end
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
		-- set the effects if the data has them
		if v.hasEffect1 then
			print("loading effect")
			self:setEffect(i, 1, v.effect1Type, v.effect1Val1, v.effect1Val2)
		end
		if v.hasEffect2 then
			self:setEffect(i, 2, v.effect2Type, v.effect2Val1, v.effect2Val2)
		end
	end
end