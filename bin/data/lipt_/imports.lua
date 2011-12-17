package.path = package.path .. ";"..blud.bundle_root.."lipt_/?.lua"
package.path = package.path .. ";"..blud.bundle_root.."lipt_/socket/?.lua"
package.path = package.path .. ";"..blud.bundle_root.."lipt_/utils/?.lua"
do
  local filesToImport = {"class",
    "underscore",
    "Rectangle",
    "Group",
    "Object",
    "bludGlobal",
    "oscHooks",
    "Particles",
    "tablePersistance",
    "compression/bit",
    "compression/LibStub",
    "compression/LibCompress",
    
    "objects/StringObject",
    "objects/Button",
    "objects/RoundedButton",
    "objects/MultilineString",
    "objects/RoundedRect",
    "objects/DragArea",
    "objects/NoteEditor",
    "objects/ByteEditor",

    "profiler",
    "Camera",

    "models/SongModel",
    "models/ChainModel",
    "models/PhraseModel",

    "states/PlayState",
    "states/EditArea",
    "states/SongEditor",
    "states/PhraseEditor",
    "states/ChainEditor",

    "Tweener",
    "SoundBank",
    "oscHooks"
    }
  for i, v in ipairs(filesToImport) do
    dofile(blud.bundle_root .. "/lipt_/".. v ..".lua")
  end
end

_ = require 'underscore'
