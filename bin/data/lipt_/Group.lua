-- group
-- getNearest(vec2) -- returns the member closest to point
-- remove(Object)   -- marks the object for removal from its member list and returns it
-- add(Object)      -- adds the object to the list

Group = class(function(o)
  o.members = {}
  o.alive = true
  o.exists = true
end)
function Group:getNearest(o)
  assert(o.pos, "The object being passed to nearest does not apper to have a position")
  local low; local nearest;
  if self.members then
    for i, v in pairs(self.members) do
      if v.alive then
        dist = v.pos:distance(o.pos)
        if low == nil or dist < low then low = dist; nearest = v end
      end
    end
    return nearest
  end
end
function Group:clear()
  self.members = {}
end
function Group:add(o)
  assert(o, "nil group member added")
  table.insert(self.members, o)
  return o
end
function Group:addRecycle(o)
  for i=table.maxn(self.members),1,-1 do
    if not self.members[i].exists then self.members[i] = o; return o; end
  end
  return self:add(o)
end
function Group:remove(o)
  for i=table.maxn(self.members),1,-1 do
    if self.members[i] == o then
      table.remove(self.members, i);
      -- allows the group to clean up any groups that it has added around
      if o.afterRemove then
        o:afterRemove()
      end
    end
  end
end
function Group:callAll(functionName)
  if self.members then
    for i, v in pairs(self.members) do if v[functionName] then v[functionName](v) end end
  end
end
function Group:countLiving()
  local count = 0
  for i, v in pairs(self.members) do if v.alive then count = count+1 end end
  return count
end
function Group:draw()
  if self.members then
    for i, v in ipairs(self.members) do
      if v.exists and v.draw then v:draw() end
    end
  end
end
function Group:update()
  if debug == true then print("update") end
  if self.members then
    for i, v in pairs(self.members) do
      if v.exists and v.update then v:update() end
    end
  end
end
-- check to see if this object is in the group
function Group:inGroup(o)
  for i,v in pairs(self.members) do
    if v == o then return true end
  end
  return false
end
-- check to see if this object overlaps with another one
function Group:overlap(other, ...)
  local arg = {...}
  local notifyCallback = arg[1]
  local r_val = false
  if self.members then
    for i, v in pairs(self.members) do
      if other:is_a(Group) then
        for j, w in pairs(other.members) do
          if v.alive and v:overlap(w, notifyCallback) then r_val = true end
        end
      elseif other:is_a(Object) then
        if v.alive and v:overlap(other, notifyCallback) then r_val = true end
      end
    end
  end
  return r_val
end

-- all of the touch functions loop through the group in reverse order so that the touches are passed to the objects that render last. This way buttons that are in front should get touches first.
function Group:touchDown(x, y, id)
  if self.members then
    for i=table.maxn(self.members),1,-1 do
      v = self.members[i]
      if v.exists and v.touchDown then 
        if v:touchDown(x,y,id) == false then
          return false
        end
      end
    end
  end
  return true
end
function Group:touchMoved(x, y, id)
  if self.members then
    for i=table.maxn(self.members),1,-1 do
      v = self.members[i]
      if v.exists and v.touchMoved then 
        if v:touchMoved(x,y,id) == false then
          return false
        end
      end
    end
  end
  return true
end
function Group:touchUp(x, y, id)
  if self.members then
    for i=table.maxn(self.members),1,-1 do
      v = self.members[i]
      if v.exists and v.touchUp then 
        if v:touchUp(x,y,id) == false then
          return false
        end
      end
    end
  end
  return true
end
function Group:sync()
  if debug then print("sync") end
  self:callAll("sync")
end
function Group:kill()
  self:callAll("kill")
  self.alive = false
  self.exists = false
end