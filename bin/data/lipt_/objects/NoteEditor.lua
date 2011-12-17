local notes = {"C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#", "A ", "A#", "B "}

NoteEditor = class(Object, function(o, x, y, root)
	o.string = StringObject(x, y, "----")
	o.string:setColor(0,0,0)
	Object.init(o, x, y, o.string.w, o.string.h)
	o.hasVal = false
	o.value = 0 -- these can go to partial, but when returned are calculated from the ints
	o.octave = 4
	o.root = root
end)

-- all of the editors should take a vector, signifyng the movement of the finger while the editor is highlighted
function NoteEditor:changeValue(vec)
	-- this is how many notes one drag across the screen changes
	local vScale = ((vec.y*-1)/bludG.camera.h)*8
	local hScale = (vec.x/bludG.camera.h)*3

	if not self.hasVal then
		self.value = self.root.last_note_val
		self.octave = self.root.last_note_oct
		self.hasVal = true
	end
	
	local newvalue = self.value % 13 + vScale
	if newvalue < 1 then newvalue = 13 - newvalue end

	local newoctave = self.octave % 9 + hScale
	if newoctave < 1 then newoctave = 9 - newoctave end
	
	if math.floor(newvalue) ~= math.floor(self.value) or math.floor(newoctave) ~= math.floor(self.octave) then
		local octave = " " .. math.floor(newoctave)
		if math.floor(newoctave) < 0 then
			octave = math.floor(newoctave)
		end
		self.string:setValue(notes[math.min(12, math.floor(newvalue))] .. octave)
		self.w, self.h = self.string.w, self.string.h
		self.root.last_note_oct = octave
		self.root.last_note_val = math.floor(newvalue)
		self.value = newvalue
		self.octave = newoctave
		if self.onChange then
			self.onChange(self:getValue())
		end
	end
	self.value = newvalue
	self.octave = newoctave
end
function NoteEditor:draw()
	self.string:draw()
end
function NoteEditor:setPosition(x, y)
	Object.setPosition(self, x, y)
	self.string:setPosition(x, y)
end
function NoteEditor:setValue(newValue)
	self.value = newValue%12
	self.octave = math.floor(newValue/12);
	self.string:setValue(notes[math.min(12, math.floor(self.value))] .. tostring(self.octave-1))
	self.w, self.h = self.string.w, self.string.h	
end
-- calculate the value based on the octave and value
function NoteEditor:getValue()
	return math.min(128, math.max(1, 60 + (math.floor(self.octave)-4)*12 + math.floor(self.value)))
end