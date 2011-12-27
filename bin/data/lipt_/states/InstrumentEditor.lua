-- should be able to load samples
InstrumentEditor = class(Group, function(o, instNum, phraseNum, song)
	Group.init(o)
  	-- fix the scroll
  	bludG.camera.scroll = Vec2(0,0)
  	o.song = song
  	o.fromPhrase = phraseNum

	o.editors = Group()
	o:add(o.editors)	
	o.editControl = o:add(EditArea(o.editors))

	o.instNum = instNum
	o.instrument = song:getInstrument(instNum)  -- gets a chain
	local offsetx = 20
	-- display the current sample
	o.sampleName = o:add(StringObject(offsetx,80,tostring(o.instrument.sampleName)))
	-- add a button to select the sample
	o.sampleButton = o:add(RoundedCameraButton(offsetx, 120, 200, 80, "Select Sample"))
	o.sampleButton.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, SamplePickerState(o.instrument, {}))
	end
	o.sampleButton:setLayer(2)

	-- todo: should pack up all of the controls on this screen into a table for easier placement
	-- a volume selector
	-- a selector for loop mode
	o.loopMode = o.editors:add(ListEditor(0,300, {}, o.instrument.loopModes, "loop mode: "))
	-- should attempt to load the tempo from the song
	o.loopMode:setValue(o.instrument.loopMode)
	o.loopMode.onChange = function(newVal)
		o.instrument:setLoopMode(newVal)
	end

	-- todo: add all of the other instrument editor things
	-- back to phrase button
	o.toPhrase = o:add(RoundedButton(bludG.camera.w-80, 0, 80, 80, "P"))
	o.toPhrase.scrollFactor = Vec2(0,0)	
	o.toPhrase.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, PhraseEditor(nil, o.fromPhrase, 0, song))
	end
end)

function InstrumentEditor:draw()
	self.editControl:drawBg()
	Group.draw(self)
end