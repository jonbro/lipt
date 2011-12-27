TempoEditor = class(ByteEditor, function(o, x, y, root)
	ByteEditor.init(o, x, y, root)
	o:setValue(60)
	o.w, o.h = o.string.w, o.string.h
	o.picker = ByteEditorPicker()	
end)

function TempoEditor:setValue(value)
	self.value = value
	self.hasVal = true
	self.string:setValue("tempo: " .. math.floor(self.value) .. "[" .. dtoh(math.floor(self.value)) .. "]")
	self.w, self.h = self.string.w, self.string.h
	if self.onChange then
		self.onChange(math.floor(value))
	end
end
