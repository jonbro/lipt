local numPositions = 16
-- should eventually break this into screens
ChainEditor = class(Group, function(o, root, chainNum)
	Group.init(o)
	o.editors = Group()
	o:add(EditArea(o.editors))
	o:add(o.editors)
	o.chainNum = chainNum
	o.chain = song:getChain(chainNum)  -- gets a chain

	o.root = root
	local size = Vec2(60, 60)
	if not retina then size:mult(0.5) end
	local columns = {"phrases", "transpose"}

	-- should display a bunch of byte editors, for the channels and the number of positions supported
	for j=0,numPositions-1 do
		-- add a position indicator
		local pi = o:add(StringObject(0, j*size.y, dtoh(j)))
		pi:setColor(200, 120, 120)
		for i,v in ipairs(columns) do
			-- move over by one to account for the position indicator
			local e = o.editors:add(ByteEditor(size.x*(i+1), size.y*j, o.root))
			-- should link these into the non existant data model somehow
			e.onChange = function(newVal)
				o.chain:set(j, newVal, 0)      -- set chain to phrase and transpose at position
			end
		end
	end
	o.toPhrase = Button(bludG.camera.w-40, 0, 40, 40)
	o.toPhrase.onPress = function()
		-- this should be some type of wrapper state at some point. lets keep it raw for now though
		mainState:remove(mainState.edit)
		-- extract the chain value, and switch to the chain editor
		mainState.edit = mainState:add(PhraseEditor(o.root, o.editControl.currentEdit.value))
	end
	o.showingPhrase = false
	o.toSong = o:add(Button(0,0,40,40))
	o.toSong.onPress = function()
		-- this should be some type of wrapper state at some point. lets keep it raw for now though
		mainState:remove(mainState.edit)
		-- extract the chain value, and switch to the chain editor
		mainState.edit = mainState:add(SongEditor(o.root))
	end
end)

function ChainEditor:update()
	Group.update(self)
	if not self.showingPhrase and self.editControl.currentEdit and self.editControl.currentEdit.hasVal then
		-- show the phrase button
		self:add(self.toPhrase)
		self.showingPhrase = true
	elseif self.showingPhrase then
		self:remove(self.toPhrase)
		self.showingPhrase = false
	end
end