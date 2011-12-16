local numChannels = 8
local numPositions = 20
-- should eventually break this into screens
SongEditor = class(Group, function(o, root)
	Group.init(o)
	o.editors = Group()
	o.editControl = o:add(EditArea(o.editors))
	o:add(o.editors)
	
	o.root = root
	local size = Vec2(60, 60)
	if not retina then size:mult(0.5) end
	-- should display a bunch of byte editors, for the channels and the number of positions supported
	-- eventually these should be loaded from the root object.
	for j=0,numPositions-1 do
		-- add a position indicator
		local pi = o:add(StringObject(0, j*size.y, dtoh(j)))
		pi:setColor(200, 120, 120)
		for i=0,numChannels-1 do
			-- move over by one to account for the position indicator
			local e = o.editors:add(ByteEditor(size.x*(i+1), size.y*j, o.root))
			e.onChange = function(newVal)
				song:setChain(i, j, newVal)
			end
		end
	end

	o.toChain = Button(bludG.camera.w-40, 0, 40, 40)
	o.toChain.onPress = function()
		-- this should be some type of wrapper state at some point. lets keep it raw for now though
		mainState:remove(mainState.edit)
		-- extract the chain value, and switch to the chain editor
		mainState.edit = mainState:add(ChainEditor(o.root, o.editControl.currentEdit.value))
	end
	o.showingPhrase = false
end)

function SongEditor:update()
	Group.update(self)
	if not self.showingPhrase and self.editControl.currentEdit and self.editControl.currentEdit.hasVal then
		-- show the phrase button
		self:add(self.toChain)
		self.showingPhrase = true
	elseif self.showingPhrase then
		self:remove(self.toChain)
		self.showingPhrase = false
	end
end