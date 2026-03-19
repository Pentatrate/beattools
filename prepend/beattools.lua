local st = Gamestate:new('Editor') -- Penta: This comment is neccessary

utilitools.files.beattools.undo.init()
utilitools.files.beattools.ctrlSelect.init(st)

-- will want to overhaul the code below soon

local beattoolsTime = 0
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

function st:beattoolsUntag(tags2)
	local tags = {}
	for i, v in ipairs(tags2) do
		table.insert(tags, v)
	end

	st:newMulti()

	local earliest, latest, tagEvents, tagName = nil, nil, nil, ""

	local function getTagEvents(tagName2)
		if tagName ~= "" and tagName == tagName2 then return true end
		if love.filesystem.getInfo(cLevel .. "tags/" .. tagName2 .. ".json") then
			tagEvents = dpf.loadJson(cLevel .. "tags/" .. tagName2 .. ".json")
			tagName = tagName2
			return true
		else
			modlog(mods.beattools, "Untagging failed: Tag doesnt exist")
			utilitools.prompts.error(mods.beattools, "Untagging failed: \"" .. tagName2 .. ".json\" doesnt exist")
			return false
		end
	end

	local function untagSingleTag(currentTag)
		local temp = {}
		if getTagEvents(currentTag.tag) then
			for i, event in ipairs(helpers.copy(tagEvents)) do
				event.time = event.time + currentTag.time
				event.angle = event.angle or 0
				if currentTag.angleOffset then
					event.angle = event.angle + currentTag.angle
					if mods.beattools.config.betterUntagging then
						if event.angle2 then event.angle2 = event.angle2 + currentTag.angle end
						if event.angle2 then event.endAngle = event.endAngle + currentTag.angle end
					end
				end
				table.insert(self.level.events, event)
				if self.multiselect == nil then
					modlog(mods.beattools, "Multiselect nil - What? " .. tostring(i) .. " " .. tostring(currentTag.tag))
				end
				table.insert(self.multiselect.events, event)
				self.multiselect.eventTypes[event.type] = true

				if earliest == nil then
					earliest, latest = event.time, event.time
				end
				if earliest > event.time then earliest = event.time end
				if latest < event.time then latest = event.time end
			end
			table.remove(self.level.events, self:eventIndex(currentTag))
			return false
		end
		return true
	end

	if #tags == 1 then
		local tag = tags[1]
		if type(tag) == "string" then
			local i = 0
			while i < #self.level.events do
				i = i + 1
				local event = self.level.events[i]
				if event.type == "tag" and event.tag == tag then
					i = i - 1
					if untagSingleTag(event) then return end
				end
			end
		elseif tag.type == "tag" then
			untagSingleTag(tag)
		end
	else
		if type(tags[1]) == "string" then
			for ii, vv in ipairs(tags) do
				local i = 0
				while i < #self.level.events do
					i = i + 1
					local event = self.level.events[i]
					if event.type == "tag" and event.tag == vv then
						i = i - 1
						if untagSingleTag(event) then return end
					end
				end
			end
		else
			for i, v in ipairs(tags) do
				if v.type == "tag" then
					untagSingleTag(v)
				end
			end
		end
	end

	self.multiselectStartBeat = earliest
	self.multiselectEndBeat = latest
	self.p:hurtPulse()
	self:updateBiggestBeat()
	self.unsavedChanges = true
end