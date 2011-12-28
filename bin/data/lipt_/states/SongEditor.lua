local numChannels = 8
local numPositions = 20
-- should eventually break this into screens
SongEditor = class(Group, function(o, root)
	Group.init(o)
	o.editors = Group()
	o.positions = o:add(Group())
	o:add(o.editors)
	o.editControl = o:add(EditArea(o.editors))
	o.song = song
	o.root = root
	local size = Vec2(60, 60)
	if not retina then size:mult(0.5) end
	-- should display a bunch of byte editors, for the channels and the number of positions supported
	-- eventually these should be loaded from the root object.
	for j=0,numPositions-1 do
		-- add a position indicator
		local pi = o.positions:add(StringObject(0, j*size.y, dtoh(j)))
		pi:setColor(200, 120, 120)
		pi:setLayer(0)
		for i=0,numChannels-1 do
			-- move over by one to account for the position indicator
			local e = o.editors:add(ByteEditor(size.x*(i+1), size.y*j, o.root))
			-- set the value from the song data
			e.channel = i
			e.position = j
			if song.channels[i][j].hasChain then
				e:setValue(song.channels[i][j].chain)
			end
			e.onChange = function(newVal)
				song:setChain(j, i, newVal)
				song.last_chain = newVal
			end
			function e:getDefault()
				if song.last_chain then return song.last_chain end
				return 0
			end
			e.onClear = function()
		      o.song:clearChain(j, i)
		      e:clearValue()
		    end
		end
	end
	
	o.toProject = o:add(RoundedButton(0, 0, 80, 80, "Prj"))
	o.toProject.scrollFactor = Vec2(0,0)
	o.toProject:setLayer(2)
	o.toProject.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, ProjectEditor())
	end

	o.toChain = RoundedButton(bludG.camera.w-80, 0, 80, 80, "C")
	o.toChain.scrollFactor = Vec2(0,0)
	o.toChain.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, ChainEditor(o.root, o.editControl.currentEdit:getValue()))
	end
	o.showingPhrase = false

	o.runPhrase = o:add(RoundedButton(bludG.camera.w-80,bludG.camera.h-80, 80, 80, "Run"))
	o.runPhrase.onPress = function()
		if o.editControl.currentEdit then
			player:startChan(o.editControl.currentEdit.channel, o.editControl.currentEdit.position)
		end
	end
	o.runPhrase.scrollFactor = Vec2(0,0)
	o.runPhrase:setLayer(2)

	o.runRow = o:add(RoundedButton(o.runPhrase.pos.x-80,bludG.camera.h-80, 80, 80, "Row"))
	o.runRow.onPress = function()
		if o.editControl.currentEdit then
			for i=0,numChannels-1 do
				player:startChan(i, o.editControl.currentEdit.position)
			end
		end
	end
	o.runRow.scrollFactor = Vec2(0,0)
	o.runRow:setLayer(2)
	
end)

function SongEditor:update()
	Group.update(self)
	if not self.showingPhrase and self.editControl.currentEdit and self.editControl.currentEdit.hasVal then
		-- show the phrase button
		self:add(self.toChain)
		self.showingPhrase = true
	elseif self.showingPhrase and ( not self.editControl.currentEdit or not self.editControl.currentEdit.hasVal ) then
		self:remove(self.toChain)
		self.showingPhrase = false
	end
end
function SongEditor:draw()
	self.editControl:drawBg()
	Group.draw(self)
end
function SongEditor:onMove(x, y, id)
	Group.onMove(self, x, y, id)
	print("song editor moving")
end