local st = Gamestate:new('Editor') -- Penta: This comment is neccessary

utilitools.files.beattools.undo.init()
utilitools.files.beattools.ctrlSelect.init(st)

-- will want to overhaul the code below soon
beattools.angleSnap = 4

beattoolsRecordPosition = false -- record position
beattoolsRecordFunc = nil

local beattoolsPlayerSpriteChanged = {}
local beattoolsLastSpriteModified = 0

beattools.randomizeWindows = mods.beattools.config.randomizeWindows ~= "off"

beattools.playerSprite = "idle"
beattools.lastSpriteChange = 0

function st:eventIndex(event)
	if event == nil then return end
	for i, v in ipairs(self.level.events) do
		if v == event then return i end
	end
end

function st:noSelection()
	self.selectedEvent = nil
	self.multiselect = nil

	self.multiselectStartBeat = nil
	self.multiselectEndBeat = nil
	self.multiselectStartAngle = nil
	self.multiselectEndAngle = nil

	self.holdEndSelected = nil
	self.deletePending = nil
	self.bounceSelected = nil
	self.bounceSelectTime = 0
	self.bounceSelectAccumulation = 0
end
function st:newMulti()
	self.selectedEvent = nil
	self.multiselect = {}
	self.multiselect.events = {}
	self.multiselect.eventTypes = {}

	self.multiselectStartBeat = 0
	self.multiselectEndBeat = 0
	self.multiselectStartAngle = 0
	self.multiselectEndAngle = 360

	self.holdEndSelected = nil
	self.deletePending = nil
	self.bounceSelected = nil
	self.bounceSelectTime = 0
	self.bounceSelectAccumulation = 0
end