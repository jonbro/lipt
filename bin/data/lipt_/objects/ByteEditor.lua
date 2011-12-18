ByteEditor = class(NoteEditor, function(o, x, y, root)
	NoteEditor.init(o, x, y, root)
	o.string:setValue("--")
	o.w, o.h = o.string.w, o.string.h
end)

-- todo: need to split the hori and vert values so that shift a bit to the left or right doesn't cause huge changes on the value

function ByteEditor:changeValue(vec)
	-- this is how many notes one drag across the screen changes
	local vScale = ((vec.y*-1)/bludG.camera.h)*8
	local hScale = (vec.x/bludG.camera.h)*3

	if not self.hasVal then
		self.value = self.root.last_inst_value
		self.hasVal = true
	end

	local newvalue = self.value + vScale + hScale*16

	if math.floor(newvalue) ~= math.floor(self.value) then
		-- prepend a 0
		self.string:setValue(dtoh(math.floor(newvalue)))
		self.w, self.h = self.string.w, self.string.h
		if self.onChange then
			self.onChange(math.floor(newvalue))
		end
	end
	self.value = newvalue
	if self.value < 0 then self.value = 127 + self.value end
	self.value = self.value % 127
end

-- calculate the value based on the octave and value
function ByteEditor:getValue()
	return math.floor(self.value)
end

function ByteEditor:setValue(value)
	self.value = value
	self.hasVal = true
	self.string:setValue(dtoh(math.floor(self.value)))
	self.w, self.h = self.string.w, self.string.h
	if self.onChange then
		self.onChange(math.floor(value))
	end
end
