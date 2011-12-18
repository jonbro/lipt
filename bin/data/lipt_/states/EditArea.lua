-- the edit area manages changing a bunch of values if they are on the screen
-- TODO: put the copy paste stuff in here
EditArea = class(Group, function(o, editors)
	Group.init(o)
	o.center = Vec2(bludG.camera.w/2, bludG.camera.h/2)
	o.editors = editors
end)
function EditArea:drawBg()
  -- draw a square behind the current edit box
  if self.currentEdit then
    local o = Object(self.currentEdit.pos.x, self.currentEdit.pos.y, self.currentEdit.w, self.currentEdit.h)
    o.sprite = sprites["white.png"]
    o.drawType = "stretched"
    o.tint = {r=200, g=255, b=200, a=255}
    o:draw()
  end
end
function EditArea:addPicker()
  if self.currentEdit then
    if self.currentEdit:is_a(ByteEditor) then
      self.picker = self:add(ByteEditorPicker())
      if self.currentEdit.hasVal then self.picker:setValue(self.currentEdit:getValue()) end
    elseif self.currentEdit:is_a(NoteEditor) then
      self.picker = self:add(NoteEditorPicker())
      if self.currentEdit.hasVal then
        self.picker:setValue(self.currentEdit:getValue())
      else
        -- set the default value
        self.picker:setValue(60)
      end
    end

  end
end

function EditArea:removePicker()
  if self.picker then
    self:remove(self.picker)
    self.picker = nil
  end
end
function EditArea:hasPicker()
  return self.picker
end

function EditArea:update()
  Group.update(self)
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
  if self:hasPicker() and self.currentEdit and self.currentEdit.setValue then
    self.currentEdit:setValue(self.picker:getValue())
  end
end

-- this is the vector of how much the finger moved
function EditArea:changeValue(vec)
  if self.currentEdit.changeValue then
    self.currentEdit:changeValue(vec)
    return
  end
end
