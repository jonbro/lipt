Object = class(Rectangle, function(o, x, y, width, height)
  Rectangle.init(o, x, y, width, height)
  o.alive = true
  o.exists = true
  o.scrollFactor = Vec2(1, 1)
  o.offset = Vec2(0,0)
  o.rot = 0
  o.layer = 0
end)
function Object:setColor(r,g,b,a)
  self.tint.r = r;
  self.tint.g = g;
  self.tint.b = b;
  self.tint.a = a or 255
end
function Object:setLayer(layer)
  self.layer = layer
end
function Object:draw()
  local cameras = self.cameras or bludG.cameras
  if not self.cam then
    self.cam = Rectangle(0, 0, bludG.camera.w, bludG.camera.h)
  end
  if self.drawType and self.drawType == "stretched" then
    return self:drawStretched()
  end
  local flip = 0
  if self.flip then flip = self.flip end
  if self.sprite then
    -- loop through all the cameras
    for i,camera in pairs(cameras) do
      local px, py = self.pos.x, self.pos.y
      self.pos.x, self.pos.y = self:getCameraOffset(camera)
      -- draw the sprite if it is on the current camera
      if self:doesRectangleTouch(self.cam) or self.forceDraw then
        -- calculate the position on the current camera
        sheet:addTile(self.sprite, self.pos.x, self.pos.y, self.layer, flip, self.tint.r, self.tint.g, self.tint.b, self.tint.a)
      end
      self.pos.x, self.pos.y = px, py
    end
  else
    Rectangle.draw(self)
  end
end
function Object:drawStretched()
  local cameras = self.cameras or bludG.cameras
  if self.sprite then
    -- loop through all the cameras
    for i,camera in pairs(cameras) do
      local pos = Vec2(self.pos.x, self.pos.y)
      self.pos.x, self.pos.y = self:getCameraOffset(camera)
      -- draw the sprite if it is on the current camera
      local cam = Rectangle(0, 0, camera.w, camera.h)
      if self:doesRectangleTouch(cam) then
        -- calculate the position on the current camera
        local c = {self.pos.x, self.pos.y, self.w, self.h}
        local tl = {c[1], c[2]}
        local tr = {c[1]+c[3], c[2]}
        local bl = {c[1], c[2]+c[4]}
        local br = {c[1]+c[3], c[2]+c[4]}
        sheet:addCornerTile(self.sprite, tl[1],tl[2], tr[1],tr[2], br[1],br[2], bl[1],bl[2], self.layer, self.tint.r, self.tint.g, self.tint.b, self.tint.a)
      end
      self.pos.x, self.pos.y = pos.x, pos.y
    end
  end  
end
function Object:getCameraOffset(camera)
  _x = (self.pos.x - (camera.scroll.x*self.scrollFactor.x) - self.offset.x) + camera.pos.x
  _y = (self.pos.y - (camera.scroll.y*self.scrollFactor.y) - self.offset.y) + camera.pos.y
  local _x, junk = math.modf(_x)
  local _y, junk = math.modf(_y)
  return _x, _y
end
function Object:update()
end
function Object:overlap(other, ...)
  local arg = {...}
  local notifyCallback = arg[1]
  if other:is_a(Group) then
    return other:overlap(self, unpack(arg))
  else
    if self.alive and Rectangle.doesRectangleTouch(self, other) then
      if notifyCallback then notifyCallback(self, other) end
      return true
    end
  end
  return false
end
function Object:kill()
  self.alive = false
  self.exists = false
end

CenteredObject = class(Object, function(o, x, y, width, height)
  Object.init(o, x, y, width, height)
  o.scale = 1
end)

function CenteredObject:draw()
  local flip = 0
  if self.flip then flip = self.flip end
  if self.sprite then
    -- loop through all the cameras
    for i,camera in pairs(bludG.cameras) do
      local pos = Vec2(self.pos.x, self.pos.y)
      self.pos.x, self.pos.y = self:getCameraOffset(camera)
      -- draw the sprite if it is on the current camera
      local cam = Rectangle(0-self.w, 0-self.h, camera.w+self.h, camera.h+self.h)
      if self:doesRectangleTouch(cam) or self.forceDraw then
        -- calculate the position on the current camera
        sheet:addCenterRotatedTile(self.sprite, self.pos.x, self.pos.y, self.layer, flip, self.scale, self.rot, self.tint.r,self.tint.g,self.tint.b, self.tint.a)
      end
      self.pos.x, self.pos.y = pos.x, pos.y
    end
  else
    Rectangle.draw(self)
  end
end