local st = Gamestate:new('Editor') -- Penta: This comment is neccessary

st.beattools = {}

utilitools.files.beattools.undo.init()

local beattoolsTime = 0
beattools.angleSnap = 4

beattoolsRecordPosition = false -- record position
beattoolsRecordFunc = nil

local beattoolsPlayerSpriteChanged = {}
local beattoolsLastSpriteModified = 0

beattools.randomizeWindows = mods.beattools.config.randomizeWindows ~= "off"

beattools.playerSprite = "idle"
beattools.lastSpriteChange = 0

function beattools.rgb2hex(r, g, b) return ("%02X%02X%02X"):format(r, g, b) end

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

function st:beattoolsCtrlSelect(event, force)
	if not mods.beattools.config.ctrlSelect and not force then return end
	self.ctrlSelectPending = false
	self.deletePending = false
	local function addToMulti(event2)
		table.insert(self.multiselect.events, event2)
		self.multiselect.eventTypes[event2.type] = true
		if self.multiselectStartBeat > event2.time then
			self.multiselectStartBeat = event2.time
		end
		if self.multiselectEndBeat < event2.time then
			self.multiselectEndBeat = event2.time
		end
	end
	if self.multiselect then
		local remove
		for i, v in ipairs(self.multiselect.events) do
			if v == event then
				remove = i
				break
			end
		end
		if remove then
			table.remove(self.multiselect.events, remove)

			local typeExists
			local checkStart = event.time == self.multiselectStartBeat and self.multiselectEndBeat
			local checkEnd = event.time == self.multiselectEndBeat and self.multiselectStartBeat

			for i, v in ipairs(self.multiselect.events) do
				if not typeExists and v.type == event.type then typeExists = true end
				if checkStart or checkEnd then
					if v.time == event.time then
						checkStart = false
						checkEnd = false
					end
					if checkStart and v.time < checkStart then checkStart = v.time end
					if checkEnd and v.time > checkEnd then checkEnd = v.time end
				end
				if typeExists and not checkStart and not checkEnd then
					break
				end
			end
			if not typeExists then self.multiselect.eventTypes[event.type] = nil end
			if checkStart then self.multiselectStartBeat = checkStart end
			if checkEnd then self.multiselectEndBeat = checkEnd end
		else
			addToMulti(event)
		end
	elseif event == self.lastSelected then
		self:noSelection()
	else
		self:newMulti()
		self.multiselectStartBeat = event.time
		self.multiselectEndBeat = event.time
		addToMulti(event)
		if self.lastSelected then
			for i, v in ipairs(self.level.events) do
				if v == self.lastSelected then
					addToMulti(self.lastSelected)
					break
				end
			end
		end
	end
	if mods.beattools.config.convertSingle and self.multiselect and #self.multiselect.events == 1 and #self.markers == 0 then
		local event2 = self.multiselect.events[1]
		self:noSelection()
		self.selectedEvent = event2
	end
end