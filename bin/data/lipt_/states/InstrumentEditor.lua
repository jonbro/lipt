-- should be able to load samples
InstrumentEditor = class(Group, function(o, instNum, phraseNum, song)
	Group.init(o)
  	-- fix the scroll
  	bludG.camera.scroll = Vec2(0,0)
  	o.song = song
  	o.fromPhrase = phraseNum

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
	-- todo: add all of the other instrument editor things
	-- back to phrase button
	o.toPhrase = o:add(RoundedButton(bludG.camera.w-80, 0, 80, 80, "P"))
	o.toPhrase.scrollFactor = Vec2(0,0)	
	o.toPhrase.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, PhraseEditor(nil, o.fromPhrase, 0, song))
	end
end)