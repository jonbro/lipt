-- screen to edit the bpm and song name
ProjectEditor = class(Group, function(o, root)
	Group.init(o)
	o.editors = Group()
	o:add(o.editors)
	
	o.editControl = o:add(EditArea(o.editors))
	o.song = song
	o.root = root

	o.tempo = o.editors:add(TempoEditor(0,0, o.root))
	-- should attempt to load the tempo from the song
	o.tempo:setValue(o.song.tempo)
	o.tempo.onChange = function(newVal)
		o.song:setTempo(newVal)
	end

	o.toSong = o:add(RoundedButton(bludG.camera.w-80, 0, 80, 80, "Sng"))
	o.toSong.scrollFactor = Vec2(0,0)
	o.toSong.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, SongEditor(o.root))
	end

end)

function ProjectEditor:draw()
	self.editControl:drawBg()
	Group.draw(self)
end
