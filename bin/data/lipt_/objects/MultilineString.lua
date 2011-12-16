MultilineString = class(Object, function(o, x, y, w, string, font)
	Object.init(o, x, y, w, 0)
	o.lines = Group()
	o.font = font or "_futura_30"
	o.string = string
	-- figure out where the word breaks are
	local e = o:createLines()
	if e then
		print(e .. " is too long. Hyphenate.")
	end
	print("completed loading")
	o.last = {}
end)
function MultilineString:createLines()
	local currentWidth = 0
	local currentLine = ""
	local currentWord = ""
	local currentWordStart = 1
	local wordFailCount = 0
	local lines = {}
	local i = 1
	while i < #self.string do
		sprite = sprites[self.string:byte(i) .. self.font .. ".png"]
		if sprite then
			w = sprite:getWidth()
			currentWidth = currentWidth + w
			currentWord = currentWord .. self.string:sub(i, i)
		elseif self.string:byte(i) == 32 or self.string:byte(i) == 10 then
			-- if we haven't rolled past the target width
			if currentWidth < self.w then
				-- add the current word to the end of the current line, and start on the next width
				currentWidth = currentWidth + sprites["88" .. self.font .. ".png"]:getWidth()
				currentLine = currentLine .. currentWord .. " "
				currentWordStart = i
				wordFailCount = 0
			else
				-- otherwise, roll i back, and start on the next line
				-- and commit the current line to the lines
				i = currentWordStart
				currentWidth = 0
				table.insert(lines, currentLine)
				currentLine = ""
				wordFailCount = wordFailCount + 1
				if wordFailCount >= 2 then
					return currentWord
				end
			end
			currentWord = ""
		end
		i = i+1
	end
	-- make sure to commit the last line
	currentWord = currentWord .. self.string:sub(i, i)
	currentLine = currentLine .. currentWord .. " "
	table.insert(lines, currentLine)

	-- create string objects from them
	local y = self.pos.y
	local h = 0
	self.lines = Group()
	for i,v in ipairs(lines) do
		local line = self.lines:add(StringObject(self.pos.x, y, v, self.font))
		-- copy over all the settings
		line.scrollFactor = self.scrollFactor
		line.tint = self.tint
		line.layer = self.layer
		line:setPosition(self.pos.x, y)
		y = y + line.h
		h = h + line.h
	end
	self.h = h
	return false
end
function MultilineString:draw()
	self.lines:draw()
end
-- runs params though the proper updaters if they have changed
function MultilineString:update()
	if not self.last.tint.r or self.last.tint.r ~= self.tint.r or self.last.tint.g ~= self.tint.g or self.last.tint.b ~= self.tint.b or self.last.tint.a ~= self.tint.a then
		self:setColor(self.tint.r, self.tint.g, self.tint.b, self.tint.a)
	end
	if not self.last.pos or self.last.pos ~= self.pos then
		self:setPosition(self.pos.x, self.pos.y)
	end
	if self.lines then
		for i,v in ipairs(self.lines.members) do
			v:update()
		end
	end
end
function MultilineString:setPosition(x, y)
	Object.setPosition(self, x, y)

	if self.last and self.lines then
		local posDiff = Vec2(x, y)
		if self.last.pos then
			posDiff:sub(self.last.pos)
		end
		for i,v in ipairs(self.lines.members) do
			v:setPosition(v.pos.x+posDiff.x, v.pos.y+posDiff.y)
		end
	end
	if self.last then
		self.last.pos = Vec2(self.pos.x, self.pos.y)
	end

end
function MultilineString:setColor(r,g,b,a)
	self.tint.r = r;
	self.tint.g = g;
	self.tint.b = b;
	self.tint.a = a or 255;
	self.last.tint = self.tint
	for i,v in ipairs(self.lines.members) do
		v:setColor(r,g,b,a)
	end
end
function MultilineString:setScrollFactor(scrollFactor)
	self.scrollFactor = scrollFactor
	for i,v in ipairs(self.lines.members) do
		v:setScrollFactor(scrollFactor)
	end
end
function MultilineString:setLayer(layer)
	self.layer = layer
	for i,v in ipairs(self.lines.members) do
		v:setLayer(layer)
	end
end
function MultilineString:setValue(value)
	self.string = tostring(value)
	self:createLines()
end