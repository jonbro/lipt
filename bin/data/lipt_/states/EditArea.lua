-- the edit area manages changing a bunch of values if they are on the screen
-- TODO: put the copy paste stuff in here
EditArea = class(Group, function(o, editors)
	Group.init(o)
	o.center = Vec2(bludG.camera.w/2, bludG.camera.h/2)
	o.editors = editors
end)
function EditArea:draw()
  -- draw a square behind the current edit box
  if self.currentEdit then
    local o = Object(self.currentEdit.pos.x, self.currentEdit.pos.y, self.currentEdit.w, self.currentEdit.h)
    o.sprite = sprites["white.png"]
    o.drawType = "stretched"
    o.tint = {r=200, g=255, b=200, a=255}
    o:draw()
  end
end

function EditArea:update()
  -- clear the background on the currently editable object
  -- find the newest object that is nearest to the center
  self.currentEdit = nil
  for i,v in pairs(self.editors.members) do
    local ox, oy = v:getCameraOffset(bludG.camera)
    local distToCenter = self.center:distance(Vec2(ox, oy))
    if not self.currentEdit or distToCenter < lowestDistance then
      lowestDistance = distToCenter
      self.currentEdit = v
    end
  end
end

-- this is the vector of how much the finger moved
function EditArea:changeValue(vec)
  if self.currentEdit.changeValue then
    self.currentEdit:changeValue(vec)
    return
  end
end
