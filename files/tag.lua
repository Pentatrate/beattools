local tag = {
	events = {},
	bounds = {},
	modtime = {},
	lastModtimeChecked = {},

	cache = {},
	access = {},
	index = 0
}

function tag.clearCache()
	tag.cache = {}
	tag.access = {}
	tag.index = 0
end
function tag.init()
	tag.events = {}
	tag.bounds = {}
	tag.modtime = {}
	tag.clearCache()
end
function tag.cacheEvent(event, remove, k)
	tag.clearCache()
end

function tag.initTag(tagName) -- false if successful, true if failed, nil if first time or changed
	if type(tagName) ~= "string" then return true end

	if tag.lastModtimeChecked[tagName] and tag.lastModtimeChecked[tagName] + 1 < love.timer.getTime() then
		return false
	end

	local path = cLevel .. "tags/" .. tagName .. ".json"
	local info = love.filesystem.getInfo(path)
	if not info then
		tag.events[tagName] = nil
		tag.modtime[tagName] = nil
		tag.bounds[tagName] = nil
		tag.lastModtimeChecked[tagName] = nil
		return true
	end

	tag.lastModtimeChecked[tagName] = love.timer.getTime()
	if tag.events[tagName] and info.modtime == tag.modtime[tagName] then return false end

	-- i could add more checks for invalid stuff, but it was never needed before this tag system rework anyways
	tag.events[tagName] = dpf.loadJson(path)
	tag.modtime[tagName] = info.modtime
	tag.bounds[tagName] = {}
	for _, event in ipairs(tag.getEvents(tagName)) do
		if not tag.bounds[tagName].min or tag.bounds[tagName].min > event.time then
			tag.bounds[tagName].min = event.time
		end
		if not tag.bounds[tagName].max or tag.bounds[tagName].max < event.time then
			tag.bounds[tagName].max = event.time
		end
	end
end

function tag.getEvents(tagName)
	if tag.initTag(tagName) then return {} end
	return tag.events[tagName]
end
function tag.moveEvents(tagName, time, angle, cache)
	if tag.initTag(tagName) then return {} end
	if angle == 0 then angle = nil end
	local keys = table.concat({ time, angle or 0 }, " | ")

	while tag.cache[1] and tag.cache[1].time + 1 < love.timer.getTime() do
		local element = table.remove(tag.cache)
		tag.index = tag.index + 1
		tag.access[element.keys] = nil
	end
	if tag.access[keys] then
		local cached = tag.cache[tag.access[keys] - tag.index]
		if not cached then
			modwarn(mod, "No cache? ", tagName, time, angle, cache)
		else
			return cached.events
		end
	end

	local events = helpers.copy(tag.getEvents(tagName))

	for _, event in ipairs(events) do
		event.time = event.time + time
		event.angle = event.angle or 0
		if angle then
			event.angle = event.angle + angle
			if mod.config.betterUntagging then
				if event.angle2 then event.angle2 = event.angle2 + angle end
				if event.endAngle then event.endAngle = event.endAngle + angle end
			end
		end
	end

	if cache then
		table.insert(tag.cache, { time = love.timer.getTime(), events = events, keys = keys })
		tag.access[keys] = #tag.cache + tag.index
	end

	return events
end
function tag.placeEvents(tagName, time, angle, multiselect)
	if tag.initTag(tagName) then return end
	if angle == 0 then angle = nil end

	local events = tag.moveEvents(tagName, time, angle)

	for i, event in ipairs(events) do
		table.insert(cs.level.events, event)
		if multiselect then
			if not cs.multiselect or not cs.multiselect.events or not cs.multiselect.eventTypes then
				modlog(mods.beattools, "Multiselect nil - What?", i, tagName, time, angle, multiselect)
			elseif multiselect then
				table.insert(cs.multiselect.events, event)
				cs.multiselect.eventTypes[event.type] = true
			end
		end
	end
end

function tag.untag(event, multiselect) -- true is successful, nil if failed
	if type(event) ~= "table" or event.type ~= "tag" then return end
	local tagName = event.tag
	if tag.initTag(tagName) then return end

	tag.placeEvents(tagName, event.time, event.angleOffset and event.angle, multiselect)
	table.remove(cs.level.events, cs:eventIndex(event))
	return true
end

function tag.untagEvent(event)
	if type(event) ~= "table" or event.type ~= "tag" then return end
	local tagName = event.tag
	if tag.initTag(tagName) then return end

	cs:newMulti()

	local success = tag.untag(event, true)

	cs.p:hurtPulse()
	if success then
		cs.multiselectStartBeat = tag.bounds[tagName].min + event.time
		cs.multiselectEndBeat = tag.bounds[tagName].max + event.time
		cs:updateBiggestBeat()
		cs.unsavedChanges = true
	else
		cs:noSelection()
	end
end
function tag.untagEvents(events)
	if type(events) ~= "table" then return end

	cs:newMulti()
	local min
	local max
	local success = false

	local function checkEvent(event)
		if type(event) ~= "table" or event.type ~= "tag" then return end
		local tagName = event.tag
		if tag.initTag(tagName) then return end

		local singleSuccess = tag.untag(event, true) or false
		if not singleSuccess then return end

		success = true
		local minTime = tag.bounds[tagName].min + event.time
		local maxTime = tag.bounds[tagName].max + event.time
		min = min and math.min(min, minTime) or minTime
		max = max and math.max(max, maxTime) or maxTime
	end
	for _, event in ipairs(events) do
		checkEvent(event)
	end

	cs.p:hurtPulse()
	if success then
		cs.multiselectStartBeat = min
		cs.multiselectEndBeat = max
		cs:updateBiggestBeat()
		cs.unsavedChanges = true
	else
		cs:noSelection()
	end
end
function tag.untagTagName(tagName)
	if tag.initTag(tagName) then return end

	cs:newMulti()
	local min
	local max
	local success = false

	local i = 0
	while i < #cs.level.events do
		i = i + 1
		local event = cs.level.events[i]
		if event.type == "tag" and event.tag == tagName then
			i = i - 1
			local singleSuccess = tag.untag(event, true) or false
			success = success or singleSuccess

			if singleSuccess then
				local minTime = tag.bounds[tagName].min + event.time
				local maxTime = tag.bounds[tagName].max + event.time
				min = min and math.min(min, minTime) or minTime
				max = max and math.max(max, maxTime) or maxTime
			end
		end
	end

	cs.p:hurtPulse()
	if success then
		cs.multiselectStartBeat = min
		cs.multiselectEndBeat = max
		cs:updateBiggestBeat()
		cs.unsavedChanges = true
	else
		cs:noSelection()
	end
end
function tag.untagTagNames(tagNames)
	if type(tagNames) ~= "table" then return end

	cs:newMulti()
	local min
	local max
	local success = false

	local function checkEvent(event, tagName)
		if event.type ~= "tag" or event.tag ~= tagName then return end

		local singleSuccess = tag.untag(event, true) or false
		if not singleSuccess then return end

		success = true
		local minTime = tag.bounds[tagName].min + event.time
		local maxTime = tag.bounds[tagName].max + event.time
		min = min and math.min(min, minTime) or minTime
		max = max and math.max(max, maxTime) or maxTime

		return true
	end
	local function checkTagName(tagName)
		if tag.initTag(tagName) then return end

		local i = 0
		while i < #cs.level.events do
			i = i + 1
			local event = cs.level.events[i]
			if checkEvent(event, tagName) then i = i - 1  end
		end
	end
	for _, tagName in ipairs(tagNames) do
		checkTagName(tagName)
	end

	cs.p:hurtPulse()
	if success then
		cs.multiselectStartBeat = min
		cs.multiselectEndBeat = max
		cs:updateBiggestBeat()
		cs.unsavedChanges = true
	else
		cs:noSelection()
	end
end

function tag.getList()
	local tagFileNames = love.filesystem.getDirectoryItems(cLevel .. "tags/")
	local indexed = {}
	for _, tagFileName in ipairs(tagFileNames) do
		local tagName = tagFileName:sub(1, -6)
		if not tag.initTag(tagName) then
			table.insert(indexed, tagName)
		end
	end
	return indexed
end

return tag