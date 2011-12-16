
-- this is the song editor. Should probably change the language here to reflect that
PhraseEditor = class(Group, function(o, root, phraseNum)
  Group.init(o)
  o.editors = Group()
  o:add(EditArea(o.editors))
  o:add(o.editors)
  
  o.phrase = song:getPhrase(phraseNum)  -- get the phrase

  o.notes = Group()

  local padding = 40
  if not retina then padding = padding/2 end
  local s = StringObject(0,0,"A")
  for y=1,c do
    local nedit = o.editors:add(NoteEditor(0,(y-1)*s.h, o.root))
    o.notes:add(nedit)
    local insEdit = o.editors:add(ByteEditor(nedit.w+padding, nedit.pos.y, o.root))
    nedit:setColor(0,0,0,255)
    nedit.onChange = function(newVal)
      o.phrase:set(y-1, newVal, 0)
    end
  end
end)