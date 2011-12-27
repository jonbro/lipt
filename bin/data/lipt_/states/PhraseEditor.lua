
-- this is the song editor. Should probably change the language here to reflect that
PhraseEditor = class(Group, function(o, root, phraseNum, fromChain, song)
  Group.init(o)
  o.song = song
  o.editors = Group()
  o:add(o.editors)
  o.editControl = o:add(EditArea(o.editors, o.song))
  
  o.phrase = song:getPhrase(phraseNum)  -- get the phrase

  o.notes = Group()
  o.instruments = Group()
  o.root = root
  local padding = 40
  if not retina then padding = padding/2 end
  local s = StringObject(0,0,"A")
  for y=1,16 do
    local nedit = o.editors:add(NoteEditor(0,(y-1)*s.h, o.root))
    o.notes:add(nedit)
    local insEdit = o.editors:add(ByteEditor(nedit.w+padding, nedit.pos.y, o.root))
    o.instruments:add(insEdit)
    
    insEdit.onChange = function(newVal)
      if nedit.hasVal then
        o.phrase:set(y-1, nedit:getValue(), newVal)
      else
        o.phrase:set(y-1, 0, newVal)
      end
    end

    nedit:setColor(0,0,0,255)
    if o.phrase.steps[y-1].hasNote then
      nedit:setValue(o.phrase.steps[y-1].note)
      insEdit:setValue(o.phrase.steps[y-1].instrument)
    end
    
    nedit.onChange = function(newVal)
      if insEdit.hasVal then
        o.phrase:set(y-1, newVal, insEdit:getValue())
      else
        o.phrase:set(y-1, newVal, 0)
      end
    end
    nedit.onClear = function()
      o.phrase:clearNote(y-1)
      nedit:clearValue()
    end
  end

  o.toPhrase = o:add(RoundedButton(0,0,80,80, "P"))
  o.toPhrase.scrollFactor = Vec2(0,0)
  o.toPhrase.onPress = function()
    mainState.edit = mainState:replaceState(mainState.edit, ChainEditor(o.root, fromChain))
  end

  o.toInstrument = RoundedButton(bludG.camera.w-80, 0, 80, 80, "I")
  o.toInstrument.scrollFactor = Vec2(0,0) 
  o.toInstrument.onPress = function()
    mainState.edit = mainState:replaceState(mainState.edit, InstrumentEditor(o.editControl.currentEdit:getValue(), phraseNum, song))
  end
  o.showingInstrument = false
end)

function PhraseEditor:draw()
  self.editControl:drawBg()
  Group.draw(self)
end

function PhraseEditor:update()
  Group.update(self)
  if not self.showingInstrument and self.editControl.currentEdit and self.editControl.currentEdit.hasVal and self.instruments:inGroup(self.editControl.currentEdit) then
    -- show the phrase button
    self:add(self.toInstrument)
    self.showingInstrument = true
  elseif self.showingInstrument and ( not self.editControl.currentEdit or not self.editControl.currentEdit.hasVal ) then
    self:remove(self.toInstrument)
    self.showingInstrument = false
  end
end