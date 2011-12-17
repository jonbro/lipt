-- an area that handles drags that start within it
DragArea = class(Button, function(o,x,y,w,h)
	Button.init(o,x,y,w,h)
	o.lastPos = {}
	-- o.tint.a = 100
	-- o.sprite = sprites["description_box.png"]
	-- o.scrollFactor = Vec2(0,0)
end)
function DragArea:touchDown(x, y, id)
  if Rectangle.doesPointTouch(self, Vec2(x, y)) then
    self.fingerDown[id] = true
    self.lastPos[id] = Vec2(x, y)
    if self.onStart then return self.onStart(self,x, y, id) end
  end
  -- allow bubbling to continue
  return true
end
function DragArea:touchMoved(x,y,id)
	if self.fingerDown[id] then
    	if self.onMove then
	    	local r_val = self.onMove(self,x,y,id)
	    end
		  self.lastPos[id] = Vec2(x, y)
	    return true
  	end
	return true
end
function DragArea:touchUp(x, y, id)
  -- commit when the finger goes up, even if it is not within the button
  if self.fingerDown[id] then
    self.fingerDown[id] = nil
    if self.onPress then self.onPress(self, x, y, id) end  
    return true
  end
  self.fingerDown[id] = nil
  return true
end
function DragArea:draw()
	-- don't do anything, keep it blank
	Object.drawStretched(self)
end
