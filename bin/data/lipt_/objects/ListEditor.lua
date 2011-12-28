-- can pick a value from a list
ListEditor = class(ByteEditor, function(o, x, y, root, list, prefix)
	ByteEditor.init(o, x, y, root)
	o.list = list
	o.prefix = prefix or ""
	o:setValue(1)
	o.w, o.h = o.string.w, o.string.h
	o.picker = ListEditorPicker(o.list)
end)

function ListEditor:setValue(value)
	self.value = value
	self.hasVal = true
	self.string:setValue(self.prefix .. self.list[math.floor(self.value)])
	self.w, self.h = self.string.w, self.string.h
	if self.onChange then
		self.onChange(math.floor(value))
	end
end
