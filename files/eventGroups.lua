local eventGroups = {
	eventCache = {},
	groupCache = {},
	type = { [" - "] = 0, show = 1, transparent = 1, ghost = 1, hide = 2 },
	length = 0,
	indices = {},
	groups = {},
	types = {},
	custom = {},
	eventNames = {},
	eventMap = {},
	newEventType = ""
}

for eventId, info in pairs(Event.info) do
	if info.name then
		if eventGroups.eventMap[info.name] then
			local overlap = eventGroups.eventMap[info.name]
			if overlap ~= true then
				eventGroups.eventNames[overlap.index] = info.name .. " (" .. overlap.id .. ")"
				eventGroups.eventMap[info.name .. " (" .. overlap.id .. ")"] = overlap
				eventGroups.eventMap[info.name] = true
			end

			table.insert(eventGroups.eventNames, info.name .. " (" .. eventId .. ")")
			eventGroups.eventMap[info.name .. " (" .. eventId .. ")"] = { id = eventId, index = #eventGroups.eventNames }
		else
			table.insert(eventGroups.eventNames, info.name)
			eventGroups.eventMap[info.name] = { id = eventId, index = #eventGroups.eventNames }
		end
	end
end

local groups

function eventGroups.invalidLevel()
	return not (cs and cs.name == "Editor" and cs.level and cs.level.properties)
end

function eventGroups.noGroups()
	return eventGroups.invalidLevel() or not (cs.level.properties.beattools and cs.level.properties.beattools.eventGroups)
end

function eventGroups.invalidGroups()
	return eventGroups.noGroups() or not (cs.level.properties.beattools.eventGroups[1])
end

function eventGroups.updateTable()
	if eventGroups.noGroups() then return end
	groups = cs.level.properties.beattools.eventGroups
end

function eventGroups.convert()
	if eventGroups.invalidLevel() then return end
	cs.level.properties.beattools = cs.level.properties.beattools or {}
	cs.level.properties.beattools.eventGroups = cs.level.properties.beattools.eventGroups or {}
	eventGroups.updateTable()
	-- cs.level.properties.beattools.eventGroups = helpers.copy(utilitools.files.beattools.configOptions.eventGroups.default)
	if groups.all then
		local tempGroups = helpers.copy(groups)
		cs.level.properties.beattools.eventGroups = {}
		eventGroups.updateTable()

		for name, group in pairs(tempGroups) do
			if type(name) ~= "number" then
				tempGroups[name] = nil
				group.name = name
				if name == "all" then group.events = "all" end
				local i = 1
				while groups[i] and (groups[i].index == nil or group.index == nil or groups[i].index < group.index or (groups[i].index == group.index and groups[i].name < group.name)) do
					i = i + 1
				end
				table.insert(groups, i, group)
			end
		end

		if cs.level.properties.beattools.customEventGroups then
			for name, group in pairs(cs.level.properties.beattools.customEventGroups) do
				cs.level.properties.beattools.customEventGroups[name] = nil
				group.name = name
				group.events = "custom"
				local i = 1
				while groups[i] and (groups[i].index == nil or group.index == nil or groups[i].index < group.index or (groups[i].index == group.index and groups[i].name < group.name)) do
					i = i + 1
				end
				table.insert(groups, i, group)
			end
			cs.level.properties.beattools.customEventGroups = nil
		end
		for i, _ in ipairs(groups) do
			groups[i].index = nil
		end
	end
end

function eventGroups.emptyTable(t)
	if type(t) ~= "table" then return false end
	for _, _ in pairs(t) do return false end
	return true
end

function eventGroups.overlapping(group1, group2)
	if eventGroups.invalidGroups() then return false end
	eventGroups.updateTable()

	if (type(group1.events) ~= "table" and (group2.name or not eventGroups.emptyTable(group2.events))) or (type(group2.events) ~= "table" and (group1.name or not eventGroups.emptyTable(group1.events))) then return true end
	if type(group1.events) ~= "table" or type(group2.events) ~= "table" then return false end
	for event, _ in pairs(group1.events) do
		if group2.events[event] then return true end
	end
	return false
end

function eventGroups.process()
	if eventGroups.noGroups() then return end
	eventGroups.convert()
	eventGroups.length = 0

	eventGroups.indices = { [0] = { events = {} } }
	eventGroups.groups = {}
	local index = 0
	local i = 1
	while i <= #groups do
		local group = groups[i]
		eventGroups.groups[group.name] = group

		group.index = index
		group.time = i
		group.temp = nil
		if group.events == "custom" and not eventGroups.custom[group.name] then eventGroups.custom[group.name] = group end
		if group.events == "all" and group.visibility == " - " then group.visibility = "show" end

		if (group.index == 0 or eventGroups.overlapping(group, eventGroups.indices[group.index]) or eventGroups.overlapping(group, eventGroups.indices[group.index - 1])) then
			if eventGroups.overlapping(group, eventGroups.indices[group.index]) then
				index = index + 1
				group.index = index
				eventGroups.indices[group.index] = eventGroups.indices[group.index] or { events = {} }
			else
				table.remove(groups, i)
				for j = i, 1, -1 do
					local group2 = groups[j - 1]
					if j == 1 or group2.index < group.index or (group2.index == group.index and group2.name < group.name) then
						table.insert(groups, j, group)
						group.time = j
						break
					end
				end
			end
		else
			table.remove(groups, i)
			for index2 = group.index - 1, 0, -1 do
				if (index2 == 0 or eventGroups.overlapping(group, eventGroups.indices[index2 - 1])) then
					for j = i, 1, -1 do
						local group2 = groups[j - 1]
						if j == 1 or group2.index < index2 or (group2.index == index2 and group2.name < group.name) then
							table.insert(groups, j, group)
							group.index = index2
							group.time = j
							break
						end
					end
					break
				end
			end
		end

		local size = imgui.GetFontSize() * 7 / 13 * #group.name + imgui.GetStyle().WindowPadding.x + imgui.GetStyle().ItemInnerSpacing.x
		if eventGroups.length < size then eventGroups.length = size end

		if type(group.events) ~= "table" then
			eventGroups.indices[group.index].events = group.events
		else
			for event, _ in pairs(group.events) do
				eventGroups.indices[group.index].events[event] = true
			end
		end

		i = i + 1
	end
end

function eventGroups.addToGroup(group, eventCache)
	if not eventCache or type(group) ~= "table" then return end

	eventGroups.groupCache[group.name] = eventGroups.groupCache[group.name] or {}
	eventGroups.groupCache[group.name][tostring(eventCache.event)] = true

	if group.visibility ~= " - " then
		eventCache.group = group
	end
	eventCache.groups[group.name] = true
end

function eventGroups.eventVisibility(event)
	if eventGroups.eventCache[tostring(event)] and eventGroups.eventCache[tostring(event)].group and eventGroups.eventCache[tostring(event)].group.visibility then
		local visibility = eventGroups.eventCache[tostring(event)].group.visibility
		local visibility2 = eventGroups.eventCache[tostring(event)].visibility
		if visibility ~= visibility2 then
			if eventGroups.type[visibility] ~= eventGroups.type[visibility2] then
				eventGroups.eventCache[tostring(event)].visibility = visibility
				if eventGroups.type[visibility] == 1 then
					utilitools.files.beattools.eventStacking.addToStack(event, true)
				else
					utilitools.files.beattools.eventStacking.removeFromStack(event)
				end
			end
			eventGroups.eventCache[tostring(event)].visibility = visibility
		end
		if visibility ~= " - " then return visibility, eventGroups.type[visibility] end
	end
	if type(event) ~= "table" then
		error("eventGroups.eventVisibility: wtf are you doing, the event is not a table, but " .. type(event) .. " instead")
	end
	if type(event.type) ~= "string" then
		error("eventGroups.eventVisibility: wtf are you doing, the event type is not a string, but " .. type(event.type) .. " instead")
	end

	eventGroups.types[event.type] = eventGroups.types[event.type] or {}
	eventGroups.types[event.type][tostring(event)] = true

	local eventCache = {
		group = "all",
		groups = {},
		event = event
	}

	if eventGroups.noGroups() then return "show", 1 end
	eventGroups.convert()

	for _, group in ipairs(groups) do
		if group.events == "all" or (type(group.events) == "table" and group.events[event.type]) or (group.events == "custom" and event.beattoolsCustomEventGroups and event.beattoolsCustomEventGroups[group.name]) then
			eventGroups.addToGroup(group, eventCache)
		end
	end

	---@diagnostic disable-next-line: undefined-field
	eventCache.visibility = eventCache.group.visibility

	if eventGroups.eventCache[tostring(event)] and eventGroups.eventCache[tostring(event)].visibility then
		local visibility = eventCache.visibility
		local visibility2 = eventGroups.eventCache[tostring(event)].visibility

		if visibility ~= visibility2 and eventGroups.type[visibility] ~= eventGroups.type[visibility2] then
			if eventGroups.type[visibility] == 1 then
				utilitools.files.beattools.eventStacking.addToStack(event, true)
			else
				utilitools.files.beattools.eventStacking.removeFromStack(event)
			end
		end
	end
	eventGroups.eventCache[tostring(event)] = eventCache

	return eventCache.visibility, eventGroups.type[eventCache.visibility]
end

function eventGroups.eventCustomGroup(event)
	if eventGroups.emptyTable(eventGroups.custom) then
		if event.beattoolsCustomEventGroups then event.beattoolsCustomEventGroups = nil end
		return
	end
	if imgui.TreeNode_Str("Event Groups##beattoolsSelectedEventGroups") then
		local hasAllCustomGroups = true
		for groupName, _ in pairs(eventGroups.custom) do
			if not (event.beattoolsCustomEventGroups and event.beattoolsCustomEventGroups[groupName]) then
				hasAllCustomGroups = false
				break
			end
		end
		if not hasAllCustomGroups then
			local isOpen = imgui.BeginCombo("##beattoolsAddSelectedEventGroup", "Add Custom Event Group", 2^4 + 2^5 + 2^7)
			if isOpen then
				for groupName, _ in pairs(eventGroups.custom) do
					if not (event.beattoolsCustomEventGroups and event.beattoolsCustomEventGroups[groupName]) then
						local selected = imgui.Selectable_Bool(groupName .. "##beattoolsAddSelectedEventGroup")
						if selected then
							event.beattoolsCustomEventGroups = event.beattoolsCustomEventGroups or {}
							event.beattoolsCustomEventGroups[groupName] = true
							eventGroups.addToGroup(eventGroups.groups[groupName], eventGroups.eventCache[tostring(event)])
						end
					end
				end
				imgui.EndCombo()
			end
		end
		local selectedCustomEventGroups = 0
		if event.beattoolsCustomEventGroups then
			for groupName, group in pairs(event.beattoolsCustomEventGroups) do
				if not eventGroups.custom[groupName] or imgui.Selectable_Bool(groupName .. "##beattoolsSelectedEventGroup") then
					local eventCache = eventGroups.eventCache[tostring(event)]
					local groupCache = eventGroups.groupCache[groupName]

					eventCache.groups[groupName] = nil
					groupCache[tostring(event)] = nil
					event.beattoolsCustomEventGroups[groupName] = nil
				else
					selectedCustomEventGroups = selectedCustomEventGroups + 1
				end
			end
			if selectedCustomEventGroups == 0 then
				event.beattoolsCustomEventGroups = nil
			end
		end
		imgui.TreePop()
	end
	imgui.Separator()
end

return eventGroups