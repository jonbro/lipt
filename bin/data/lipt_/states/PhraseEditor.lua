
-- this is the song editor. Should probably change the language here to reflect that
PhraseEditor = class(Group, function(o, root, phraseNum, fromChain)
  Group.init(o)
  o.editors = Group()
  o.editControl = o:add(EditArea(o.editors))
  o:add(o.editors)
  
  o.phrase = song:getPhrase(phraseNum)  -- get the phrase

  o.notes = Group()
  o.root = root
  local padding = 40
  if not retina then padding = padding/2 end
  local s = StringObject(0,0,"A")
  for y=1,16 do
    local nedit = o.editors:add(NoteEditor(0,(y-1)*s.h, o.root))
    o.notes:add(nedit)
    local insEdit = o.editors:add(ByteEditor(nedit.w+padding, nedit.pos.y, o.root))

    nedit:setColor(0,0,0,255)
    if o.phrase.steps[y-1].hasNote then
      nedit:setValue(o.phrase.steps[y-1].note)
    end
    nedit.onChange = function(newVal)
      if insEdit.hasVal then
        o.phrase:set(y-1, newVal, insEdit:getValue())
      else
        o.phrase:set(y-1, newVal, 0)
      end
    end
  end

  o.toPhrase = o:add(RoundedButton(0,0,80,80, "P"))
  o.toPhrase.scrollFactor = Vec2(0,0)
  o.toPhrase.onPress = function()
    -- this should be some type of wrapper state at some point. lets keep it raw for now though
    mainState:remove(mainState.edit)
    -- extract the chain value, and switch to the chain editor
    mainState.edit = mainState:add(ChainEditor(o.root, fromChain))
  end

end)