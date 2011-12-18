-- the overlay that pops up when we need to pick a value from the byte editor
ByteEditorPicker = class(Group, function(o)
	Group.init(o)

	o.menuCamera = Camera(0, 0, bludG.camera.w, bludG.camera.h)
	o.menuCamera.scroll = Vec2(0, 0)

	o.bkg = o:add(Object(0,0,bludG.camera.w, bludG.camera.h))
	o.bkg.sprite = sprites["white.png"]
	o.bkg.drawType = "stretched"
	o.bkg:setColor(0,0,0,0)
	o.bkgFade = Tweener:addTween(o.bkg.tint, {a=200}, {time=0.4})
	o.bkg.scrollFactor = Vec2(0, 0)

	o.size = Vec2(60, 60)

	o.selCenter = Vec2(0,0)
	o.drag = o:add(DragArea(0,0,bludG.camera.w, bludG.camera.h))
	o.drag.onMove = function(da,x,y,id)
		local p = Vec2(x, y)
		p:sub(da.lastPos[id])
		if id == 1 then
			o:setFades()
			o.menuCamera.scroll:sub(p)
			-- check to see if the camera is past the size
			if math.abs(o.menuCamera.scroll.x) > o.size.x then
				if o.menuCamera.scroll.x > o.size.x then
					-- rebuild the selectors
					o.selCenter.x = o.selCenter.x + 1
				else
					o.selCenter.x = o.selCenter.x - 1
				end
				o:buildSelectors(o.selCenter.x, o.selCenter.y)
				o.menuCamera.scroll.x = 0
			end
			if math.abs(o.menuCamera.scroll.y) > o.size.y then
				if o.menuCamera.scroll.y > o.size.y then
					-- rebuild the selectors
					o.selCenter.y = o.selCenter.y + 1
				else
					o.selCenter.y = o.selCenter.y - 1
				end
				o:buildSelectors(o.selCenter.x, o.selCenter.y)
				o.menuCamera.scroll.y = 0
			end
		end
	end
	o:buildSelectors(0,0)
end)
function ByteEditorPicker:update()
	Group.update(self)
	if self.bkgFade and not self.bkgFade.complete then
		self:setFades()
	else
		self.bkgFade = nil
	end
end
function ByteEditorPicker:setFades()
	local center = Vec2(3*self.size.x, 3*self.size.y)
	local sCenter = Vec2(bludG.camera.w/2-center.x, bludG.camera.h/2-center.y)
	for i,so in pairs(self.sos.members) do
		local dist = so.pos:distance(Vec2(sCenter.x+center.x+self.menuCamera.scroll.x, sCenter.y+center.y+self.menuCamera.scroll.y))
		if not so.bg then
			so:setColor(255, 10, 255, math.max(0, 255-dist*1.5)*(self.bkg.tint.a/200))
		end
	end
end
function ByteEditorPicker:buildSelectors(x, y)
	x, y = x-2, y-2
	if self.sos then self:remove(self.sos) end
	-- add all the objects
	local center = Vec2(3*self.size.x, 3*self.size.y)
	local sCenter = Vec2(bludG.camera.w/2-center.x, bludG.camera.h/2-center.y)
	self.sos = self:add(Group())

	bg = self.sos:add(Object(sCenter.x+self.size.x*3-self.size.x/4, sCenter.y+self.size.y*3-self.size.x/8, self.size.x, self.size.y))
	bg.sprite = sprites["white.png"]
	bg.drawType = "stretched"
	bg:setColor(190,200,190, 220)
	bg.cameras = {self.menuCamera}
	bg.bg = true
	for i=1,5 do
		for j=1,5 do
			local so = self.sos:add(StringObject(sCenter.x+self.size.x*i, sCenter.y+self.size.y*j, dtoh((i-1+x)%16*16+(j-1+y)%16)))
			so:setLayer(4)
			local dist = so.pos:distance(Vec2(sCenter.x+center.x, sCenter.y+center.y))
			if i == 3 and j == 3 then
				so.bg = true
			end
			so:setColor(10, 10, 10, 255-dist*1.5)	
			so:setCameras({self.menuCamera})
		end
	end
	self:setFades()
end
function ByteEditorPicker:setValue(val)
	self.selCenter = Vec2(math.floor(val/16), val%16)
	self:buildSelectors(self.selCenter.x, self.selCenter.y)
	self.menuCamera.scroll = Vec2(0, 0)
end


function ByteEditorPicker:getValue()
	return (self.selCenter.x)%16*16+(self.selCenter.y)%16
end