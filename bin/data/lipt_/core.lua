dofile(blud.bundle_root .. "/lipt_/imports.lua")
fs = PFileSystem();

-- this is just a defaulty thing to make things easy on me
player = tPlayer()
song = LSongModel(SongModel())         -- contains all of the song data. This is a more lua-y object
song:setPlayer(player)
-- check to see if there is a song to load
saveData = persistence.load(blud.doc_root .. "/songdata.lua");
if saveData  then
  song:loadFrom(saveData)
end
player:setSong(song.songData)


function dtoh(IN)
    local oi = IN
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    if oi == 0 then 
      OUT = "00"
    elseif oi < 16 then
      OUT = "0" .. OUT
    end
    return OUT
end

function htod(IN)
  return tonumber("0x" .. IN)
end
local notes = {"C ", "C#", "D ", "D#", "E ", "F ", "F#", "G ", "G#", "A ", "A#", "B "}
function numToNote(num)
  value = num%12
  octave = math.floor(num/12)-3;
  if octave >= 0 then octave = " " .. octave end
  return notes[math.max(0, math.min(11, math.floor(value)))+1] .. tostring(octave)
end

-- utility for getting around tables
function findNode(rootNode, name)
  if rootNode.name == name then
    return rootNode
  else
    if type(rootNode) == "table" then
      for i, v in ipairs(rootNode) do
        found = findNode(v, name)
        if(found ~= false) then
          return found
        end
      end
    end
  end
  return false
end

bg = bludGraphics();

local loadStart = os.time()
pd = bludPd();

vgridSize = 50
hgridSize = 50

includeOsc = true
if oscRec == nil and includeOsc then
  oscRec = Receiver();
  oscSender = bludOsc();
  oscSender:setup("localhost", 9002)
  oscPrint = function(s)
    local m = bludOscMessage();
    m:setAddress("/print")
    m:addStringArg(s)
    oscSender:sendMessage(m)
  end
end

print("imports load time: ", os.time() - loadStart)

-- we need to customize the sprites on importing, so they can't come frome the import list
if bg:getWidth() > 320 then
  vgridSize = vgridSize*2
  hgridSize = hgridSize*2
  retina = true
end
function loadSprites()
  spriteLoader = dofile(blud.bundle_root ..  "/lipt_/setupSprites.lua")
  sheet, sprites = spriteLoader("cute")
end
function math.randomRange(min, max)
  return min + (math.random() * (max - min))
end
function math.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


PI = 3.14159265
DEG_TO_RAD = 1/360*2*PI

function lerp(start, stop, amt)
	return start + (stop-start) * amt;
end
if bludG == nil then
  bludG = bludGlobal()
  -- bludG:startRecording()
end

particles = ParticleSystems();

loadSprites();
mainState = PlayState();

function blud.draw()
  mainState:draw();
  bludG:draw();
  if sheet then
    sheet:draw();
  end
end
function blud.update(t)
  if sheet then
    sheet:clear();
  end
  Tweener:update();
  if sheet then
    sheet:update(t);
  end
  mainState:update();
  bludG:update(t);
  particles:update()
  if oscRec then
    oscRec:update();
  end
end

function blud.touch.down(x, y, id)
  mainState:touchDown(x, y, id)
  bludG:touchDown(x, y, id)
end
function blud.touch.moved(x, y, id)
  mainState:touchMoved(x, y, id)
  bludG:touchMoved(x, y, id)
end
function blud.touch.up(x, y, id)
  mainState:touchUp(x, y, id)
  bludG:touchUp(x, y, id)
end
function blud.gotFocus()
  bludG.last_t = bg:getMillis()/1000
end
function blud.exit()
  local songdata = song:saveTo({})
  persistence.store(blud.doc_root .. "/songdata.lua", songdata);
end

-- seed the thing
math.randomseed(bludG:seedRandom())