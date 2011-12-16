-- going to make a singleton out of the sound bank so that we don't load things more times than they need to be loaded

SoundBank = class(function(s)
  s.bank = {}
  s.filenames = {} 
end)

function SoundBank:addSound(filename)
  if(self.bank[filename] == nil) then
    self.bank[filename] = bludSynth()
    self.bank[filename]:load(filename)
    self.filenames[self.bank[filename]] = filename
  end
  return self.bank[filename]
end

function SoundBank:getFilename(sound)
  return self.filenames[sound]
end