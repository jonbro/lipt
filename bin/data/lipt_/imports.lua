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
    
    "objects/StringObject",
    "objects/Button",
    "objects/RoundedButton",
    "objects/MultilineString",
    "objects/RoundedRect",
    "objects/DragArea",
    "objects/NoteEditor",
    "objects/ByteEditor",
    "objects/TempoEditor",
    "objects/ListEditor",
    "objects/ByteEditorPicker",
    "objects/NoteEditorPicker",
    "objects/ListEditorPicker",

    "profiler",
    "Camera",

    "models/SongModel",
    "models/ChainModel",
    "models/PhraseModel",
    "models/InstrumentModel",

    "states/PlayState",
    "states/EditArea",
    "states/SongEditor",
    "states/PhraseEditor",
    "states/ChainEditor",
    "states/ProjectEditor",
    "states/InstrumentEditor",
    "states/SamplePickerState",
    
    "Tweener",
    "SoundBank",
    "oscHooks"
    }
  for i, v in ipairs(filesToImport) do
    dofile(blud.bundle_root .. "/lipt_/".. v ..".lua")
  end
end

_ = require 'underscore'
