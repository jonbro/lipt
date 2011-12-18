local numPositions = 16
-- should eventually break this into screens
ChainEditor = class(Group, function(o, root, chainNum)
	Group.init(o)
	o.editors = Group()
	o.positions = o:add(Group())
	o:add(o.editors)
	o.editControl = o:add(EditArea(o.editors))
	o.chainNum = chainNum
	o.chain = song:getChain(chainNum)  -- gets a chain

	o.root = root
	local size = Vec2(60, 60)
	if not retina then size:mult(0.5) end
	local columns = {"phrases", "transpose"}

	-- should display a bunch of byte editors, for the channels and the number of positions supported
	for j=0,numPositions-1 do
		-- add a position indicator
		local pi = o.positions:add(StringObject(0, j*size.y, dtoh(j)))
		pi:setColor(200, 120, 120)
		pi:setLayer(0)
		for i,v in ipairs(columns) do
			-- move over by one to account for the position indicator
			local e = o.editors:add(ByteEditor(size.x*(i+1), size.y*j, o.root))
			-- should link these into the non existant data model somehow
			if o.chain.steps[j].hasPhrase then
				e:setValue(o.chain.steps[j].phrase)
			end
			e.onChange = function(newVal)
				o.chain:set(j, newVal, 0)      -- set chain to phrase and transpose at position
			end
		end
	end
	o.toPhrase = RoundedButton(bludG.camera.w-80, 0, 80, 80, "P")
	o.toPhrase.scrollFactor = Vec2(0,0)	
	o.toPhrase.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, PhraseEditor(o.root, o.editControl.currentEdit:getValue(), o.chainNum))
	end
	o.showingPhrase = false

	o.toSong = o:add(RoundedButton(0,0,80,80, "S"))
	o.toSong.scrollFactor = Vec2(0,0)
	o.toSong.onPress = function()
		mainState.edit = mainState:replaceState(mainState.edit, SongEditor(o.root))
	end
end)
function ChainEditor:draw()
	self.editControl:drawBg()
	Group.draw(self)
end
function ChainEditor:update()
	Group.update(self)
	if not self.showingPhrase and self.editControl.currentEdit and self.editControl.currentEdit.hasVal then
		-- show the phrase button
		self:add(self.toPhrase)
		self.showingPhrase = true
	elseif self.showingPhrase and ( not self.editControl.currentEdit or not self.editControl.currentEdit.hasVal ) then
		self:remove(self.toPhrase)
		self.showingPhrase = false
	end
end