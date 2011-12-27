-- this is just placeholdered in for now... doesn't really work in the least
NoteEditorPicker = class(ByteEditorPicker, function(o)
	ByteEditorPicker.init(o)
	local so = StringObject(0,0,"")
	o.size = Vec2(so.fixedWidth*5, 60)
	o:buildSelectors(0,0)
end)

function NoteEditorPicker:buildSelectors(x, y)
	x, y = x-2, y-2
	if self.sos then self:remove(self.sos) end
	-- add all the objects
	local center = Vec2(3*self.size.x, 3*self.size.y)
	local sCenter = Vec2(bludG.camera.w/2-center.x, bludG.camera.h/2-center.y)
	self.sos = self:add(Group())

	bg = self.sos:add(Object(sCenter.x+self.size.x*3-self.size.x/5/2, sCenter.y+self.size.y*3, self.size.x, self.size.y))
	bg.sprite = sprites["white.png"]
	bg.drawType = "stretched"
	bg:setColor(190,200,190, 220)
	bg.cameras = {self.menuCamera}
	bg.bg = true
	for i=1,5 do
		for j=1,5 do
			local so = self.sos:add(StringObject(sCenter.x+self.size.x*i, sCenter.y+self.size.y*j, numToNote((i-1+x)%12*12+(j-1+y)%12)))
			so:setLayer(4)
			local dist = so.pos:distance(Vec2(sCenter.x+center.x, sCenter.y+center.y))
			if i == 3 and j == 3 then
				so.bg = true
			end
			so:setColor(10, 10, 10, 255-dist*2.5)
			so:setCameras({self.menuCamera})
		end
	end
	self:setFades()
end

function NoteEditorPicker:getValue()
	return (self.selCenter.x)%12*12+(self.selCenter.y)%12
end

function NoteEditorPicker:setValue(val)
	self.selCenter = Vec2(math.floor(val/12), val%12)
	self:buildSelectors(self.selCenter.x, self.selCenter.y)
	self.menuCamera.scroll = Vec2(0, 0)
end