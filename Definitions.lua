

---@class npccolordb : {[number]: npccolortable} dictionary of npccolortable indexed by npcId
---@class npccolortable : {key1: boolean, key2: boolean, key3: string} [1] enabled [2] scriptOnly [3] colorID

---@class castcolordb : {[number]: castcolortable} dictionary of castcolortable indexed by spellId
---@class castcolortable : {key1: boolean, key2: string, key3: string} [1] enabled [2] colorId [3] renamed spellname 

---@class audiocuedb : {[number]: string} dictionary of strings with the path for the audio to play indexed by spellId
