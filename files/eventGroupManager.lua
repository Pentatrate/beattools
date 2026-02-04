local eventGroupManager = {}

local function processEventGroup(name, group)
	group.name = name

	local textLength = imgui.GetFontSize() * 7 / 13 * group.name:len()
	if cs.beattools.eventGroups.longest < textLength then cs.beattools.eventGroups.longest = textLength end

	if cs.beattools.eventGroups.maxIndex < group.index then cs.beattools.eventGroups.maxIndex = group.index end

	if cs.beattools.eventGroups.indices[group.index] == nil then cs.beattools.eventGroups.indices[group.index] = { events = {}, groups = 0 } end
	cs.beattools.eventGroups.indices[group.index].groups = cs.beattools.eventGroups.indices[group.index].groups + 1
	for event, _ in pairs(group.events) do
		cs.beattools.eventGroups.indices[group.index].events[event] = true
	end

	local inserted = false
	for i, vv in ipairs(cs.beattools.eventGroups.groups) do
		if not (group.index > vv.index or (group.index == vv.index and group.name > vv.name)) then
			table.insert(cs.beattools.eventGroups.groups, i, group)
			inserted = true
			break
		end
	end
	if not inserted then table.insert(cs.beattools.eventGroups.groups, group) end
end

function eventGroupManager.beattoolsUpdateEventGroups()
	cs:noSelection()

	cs.beattools.eventGroups.groups = {}
	cs.beattools.eventGroups.indices = {}
	cs.beattools.eventGroups.maxIndex = 1
	cs.beattools.eventGroups.longest = 0
	cs.beattools.eventGroups.visibility = {}
	for name, group in pairs(cs.level.properties.beattools.eventGroups) do
		processEventGroup(name, group)
	end
	if cs.level.properties.beattools.customEventGroups then
		for name, group in pairs(cs.level.properties.beattools.customEventGroups) do
			processEventGroup(name, group)
		end
	end

	cs:updateBiggestBeat()
end

return eventGroupManager