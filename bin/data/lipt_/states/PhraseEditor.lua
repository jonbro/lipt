local effectTypes = {"----", "VOLM", "PLOF"}
-- this is the song editor. Should probably change the language here to reflect that
PhraseEditor = class(Group, function(o, root, phraseNum, fromChain, song)
  Group.init(o)
  o.song = song
  o.editors = Group()
  o:add(o.editors)
  o.editControl = o:add(EditArea(o.editors, o.song))
  
  o.phrase = song:getPhrase(phraseNum)  -- get the phrase
  o.phrase.used = true

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
      o.song.last_instrument_set = newVal
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
        -- check to see if there is a last set instrument
        if o.song.last_instrument_set then
          insEdit:setValue(o.song.last_instrument_set)
        else
          o.phrase:set(y-1, newVal, 0)
        end
      end
    end
    nedit.onClear = function()
      o.phrase:clearNote(y-1)
      nedit:clearValue()
    end

    -- add the effect editors
    local efx1 = o.editors:add(ListEditor(insEdit.pos.x+insEdit.w+padding, nedit.pos.y, {}, effectTypes))
    local efxbyte1 = o.editors:add(ByteEditor(efx1.pos.x+efx1.w+padding/2, nedit.pos.y, o.root))
    local efxbyte2 = o.editors:add(ByteEditor(efxbyte1.pos.x+efxbyte1.w, nedit.pos.y, o.root))
    -- print(y-1, o.phrase.steps[y-1].hasEffect1)
    if o.phrase.steps[y-1].hasEffect1 then
      efx1:setValue(o.phrase.steps[y-1].effect1Type+1)
      efxbyte1:setValue(o.phrase.steps[y-1].effect1Val1)
      efxbyte2:setValue(o.phrase.steps[y-1].effect1Val2)
    end

    -- the storage is handled higher up, this just bundles up all of the changes and chucks them over to c
    efx1.onChange = function(newVal)
      o.phrase:setEffect(y-1, 1, efx1:getValue()-1, efxbyte1:getValue(), efxbyte2:getValue())
    end
    efxbyte1.onChange = efx1.onChange
    efxbyte2.onChange = efx1.onChange
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