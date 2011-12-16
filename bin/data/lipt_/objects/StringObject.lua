StringObject = class(Object, function(o, x, y, string, font)
	o.font = font or "_futura_30"
	o.string = tostring(string)
	Object.init(o, x, y, 0, 0)
	-- should build all the subobjs here, and then just loop them in draw... something to do in the future
	StringObject.buildSubs(o)
	o.last = {}	
end)

function StringObject:buildSubs()
	self.subs = {}
	local o = Object(self.pos.x, self.pos.y, 0, 0)
	local h = 0
	local left = self.pos.x
	for i=1,#self.string do
		o = Object(left, self.pos.y, 0, 0)
		o.tint = self.tint
		o.scrollFactor = self.scrollFactor
		o.layer = self.layer
		o.sprite = sprites[self.string:byte(i) .. self.font .. ".png"]
		if o.sprite then
			o.w = o.sprite:getWidth()
			o.h = o.sprite:getHeight()
			h = math.max(o.h, h)
			table.insert(self.subs, o)
			left = left + o.w
		elseif self.string:byte(i) == 32 then
			left = left + sprites["88" .. self.font .. ".png"]:getWidth()
		else
			print("missing char: " .. self.string:byte(i) .. self.font .. ".png")
		end
	end
	self.w = o.pos.x + o.w - self.pos.x
	self.h = h
end
-- runs params though the proper updaters if they have changed
function StringObject:update()
	if not self.last.tint.r or self.last.tint.r ~= self.tint.r or self.last.tint.g ~= self.tint.g or self.last.tint.b ~= self.tint.b or self.last.tint.a ~= self.tint.a then
		self:setColor(self.tint.r, self.tint.g, self.tint.b, self.tint.a)
	end
	if not self.last.pos or self.last.pos ~= self.pos then
		self:setPosition(self.pos.x, self.pos.y)
	end
	if self.subs then
		for i,v in ipairs(self.subs) do
			v:update()
		end
	end

end
function StringObject:setPosition(x, y)
	Object.setPosition(self, x, y)
	self:buildSubs()
end
function StringObject:setColor(r,g,b,a)
	self.tint.r = r;
	self.tint.g = g;
	self.tint.b = b;
	self.tint.a = a or 255;
	self.last.tint = self.tint
	for i,v in ipairs(self.subs) do
		v:setColor(r,g,b,a)
	end
end
function StringObject:setLayer(layer)
	self.layer = layer
	for i,v in ipairs(self.subs) do
		v.layer = layer
	end
end
function StringObject:setScrollFactor(scrollFactor)
	self.scrollFactor = scrollFactor
	for i,v in ipairs(self.subs) do
		v.scrollFactor = scrollFactor
	end
end
-- should memoize this function
-- store all the objects in a table and draw that on further runs
function StringObject:draw()
	local ipairs = ipairs
	for i,v in ipairs(self.subs) do
		v:draw()
	end
end
function StringObject:setValue(value)
	self.string = tostring(value)
	self:buildSubs()
end
function StringObject:getValue()
	return self.string
end
