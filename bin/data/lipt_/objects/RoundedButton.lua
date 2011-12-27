RoundedButton = class(Button, function(o, x, y, w, h, text)
	Button.init(o, x, y, w, h, nil)
	o.templateSprite = "rounded"
	o.padding = Vec2(20, 4)
	if not retina then o.padding:mult(0.5) end
	if text then
		o.text = StringObject(x, y, text)
		o.text.scrollFactor = Vec2(1,1)
		o.text:setColor(181, 128, 68)

		o.textDrop = StringObject(x, y, text)
		o.textDrop.scrollFactor = Vec2(1,1)
		o.textDrop:setColor(133, 93, 46)
	end
	o:setPosition(o.pos.x, o.pos.y)
	o.last = {}
end)
function RoundedButton:setLayer(layer)
	Object.setLayer(self, layer)
	self.text.layer = layer
	self.textDrop.layer = layer
	-- reset the position so that it kicks in
	self:setPosition(self.pos.x, self.pos.y)
end
-- runs params though the proper updaters if they have changed
function RoundedButton:update()
	if self.text.scrollFactor ~= self.scrollFactor then
		self.text:setScrollFactor(self.scrollFactor)
		self.textDrop:setScrollFactor(self.scrollFactor)
	end
	if self.last.tint then
		if not self.last.tint.r or self.last.tint.r ~= self.tint.r or self.last.tint.g ~= self.tint.g or self.last.tint.b ~= self.tint.b or self.last.tint.a ~= self.tint.a then
			self:setColor(self.tint.r, self.tint.g, self.tint.b, self.tint.a)
		end
	end
	if not self.last.pos or self.last.pos ~= self.pos then
		self:setPosition(self.pos.x, self.pos.y)
	end
end
function RoundedButton:setColor(r,g,b,a)
	Object.setColor(self, r,g,b,a)
	self.last.tint = self.tint
end
function RoundedButton:setPosition(x, y)
	Object.setPosition(self, x, y)
	if self.text then
		local dropOff = 2
		if not retina then dropOff = dropOff/2 end
		self.text:setPosition(self.pos.x+self.w/2-self.text.w/2, self.pos.y+self.padding.y)
		self.textDrop:setPosition(self.pos.x+self.w/2-self.text.w/2, self.pos.y-dropOff+self.padding.y)
	end
	if self.last then
		self.last.pos = Vec2(self.pos.x, self.pos.y)
	end
end
function RoundedButton:draw()
		-- self.attachmentPoints:draw()

	local op = Vec2(self.pos.x, self.pos.y)
	local ow = self.w
	local oh = self.h
	local roundOuter = sprites[self.templateSprite .. "_tl_outer.png"]:getWidth()
	-- draw the top left corner
	local s = sprites[self.templateSprite .. "_tl_outer.png"]
	local o = Object(self.pos.x, self.pos.y, s:getWidth(), s:getHeight())	
	
	o.tint = self.tint
	o.sprite = s
	o.scrollFactor = self.scrollFactor
	o.layer = self.layer
	o:draw()

	-- move the draw position over to the top right corner
	o.pos.x = o.pos.x + s:getWidth()

	-- draw the top wall
	o.w = ow - (o.pos.x - op.x) - roundOuter
	o.sprite = sprites[self.templateSprite .. "_t.png"]
	o:drawStretched()

	-- top right corner
	o.pos.x = o.pos.x + o.w
	o.sprite = sprites[self.templateSprite .. "_tr_outer.png"]
	o:draw()	

	-- draw the left wall
	o.pos = Vec2(op.x, op.y)
	o.w = sprites[self.templateSprite .. "_l.png"]:getWidth()
	o.pos.y = o.pos.y + roundOuter
	o.h = self.h - roundOuter*2
	o.sprite = sprites[self.templateSprite .. "_l.png"]
	o:drawStretched()

	-- draw the bl corner
	o.pos.y = o.pos.y + o.h
	o.sprite = sprites[self.templateSprite .. "_bl_outer.png"]
	o.w = roundOuter
	o:draw()
	o.pos.x = o.pos.x + o.w


	o.pos.y = op.y + oh - roundOuter;
	o.w = ow - (o.pos.x - op.x) - roundOuter
	o.h = roundOuter
	o.sprite = sprites[self.templateSprite .. "_b.png"]
	o:drawStretched()
	
	-- draw bottom right
	o.pos.x = o.pos.x + o.w
	o.sprite = sprites[self.templateSprite .. "_br_outer.png"]
	o:draw()

	-- draw right wall
	o.pos.x = op.x + ow - roundOuter;
	o.pos.y = op.y + roundOuter;
	o.w = roundOuter
	o.h = oh - roundOuter*2
	o.sprite = sprites[self.templateSprite .. "_r.png"]
	o:drawStretched()

	-- draw the inner
	o.pos.x = op.x + roundOuter
	o.pos.y = op.y + roundOuter
	o.w = ow - roundOuter*2
	o.h = oh - roundOuter*2
	o.sprite = sprites[self.templateSprite .. "_fill.png"] or sprites["white.png"]
	o:drawStretched()
	if self.text then
		self.textDrop:draw()
		self.text:draw()
	end
end

RoundedCameraButton = class(RoundedButton, function(o, x, y, w, h, text)
	RoundedButton.init(o, x, y, w, h, text)
end)

function RoundedCameraButton:touchDown(x, y, id)
	return CameraButton.touchDown(self, x, y, id)
end

function RoundedCameraButton:touchUp(x, y, id)
	return CameraButton.touchUp(self, x, y, id)
end