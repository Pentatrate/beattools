local function recalculateVisibility(eventCache)
	local eventGroups = utilitools.files.beattools.eventGroups
	if type(eventCache) ~= "table" then return end
	eventCache.group = eventGroups.groups.all
	for groupName, _ in pairs(eventCache.groups) do
		local group = eventGroups.groups[groupName]
		if group.visibility ~= " - " and group.index > eventCache.group.index then
			eventCache.group = group
		end
	end
end

local function updateEventVisibilities(group, moveDown)
	local eventGroups = utilitools.files.beattools.eventGroups
	if not (eventGroups.groupCache and eventGroups.groupCache[group.name]) then return end

	local groupCache = eventGroups.groupCache[group.name]
	for eventId, _ in pairs(groupCache) do
		local eventCache = eventGroups.eventCache[eventId]
		local event = eventCache.event

		if (type(group.events) == "table" and not group.events[event.type]) or (group.events == "custom" and not (event.beattoolsCustomEventGroups and event.beattoolsCustomEventGroups[group.name])) then
			-- event is no longer part of group
			eventCache.groups[group.name] = nil
			groupCache[tostring(event)] = nil
			if event.beattoolsCustomEventGroups and event.beattoolsCustomEventGroups[group.name] then
				event.beattoolsCustomEventGroups[group.name] = nil
				if eventGroups.emptyTable(event.beattoolsCustomEventGroups) then
					event.beattoolsCustomEventGroups = nil
				end
			end
			if eventCache.group == group then
				recalculateVisibility(eventCache)
			end
		elseif eventCache.group.index > group.index then
			-- nothing, another group has higher priority
		elseif eventCache.group.index < group.index and group.visibility ~= " - " then
			-- the group becomes highest priority
			eventCache.group = group
		elseif eventCache.group == group and (group.visibility == " - " or moveDown) then
			-- the group stops becoming highest priority
			recalculateVisibility(eventCache)
		else
			modlog(mod, "invalid group wtf " .. tostring(group.name) .. " " .. tostring(group.index) .. " " .. tostring(eventCache.group.name) .. " " .. tostring(eventCache.group.index))
		end
	end
end

local function addType(group, type)
	local eventGroups = utilitools.files.beattools.eventGroups
	if not eventGroups.types[type] then return end

	for eventId, _ in pairs(eventGroups.types[type]) do
		eventGroups.addToGroup(group, eventGroups.eventCache[eventId])
	end
end

local function innerImgui()
	local eventGroups = utilitools.files.beattools.eventGroups
	if eventGroups.invalidLevel() then imgui.Text("Invalid level") return end
	if eventGroups.noGroups() then
		if imgui.Button("Create Event Groups##beattoolsEventGroupsCreate") then
			cs.level.properties.beattools = cs.level.properties.beattools or {}
			cs.level.properties.beattools.eventGroups = {
				{
					events = "all",
					index = 0,
					name = "all",
					time = 1,
					visibility = "show"
				}
			}
		end
		return
	end

	eventGroups.convert()
	local groups = cs.level.properties.beattools.eventGroups

	local newGroupName = utilitools.imguiHelpers.inputText("##beattoolsEventGroupsInputGroup", "", "", "Click away or press enter to create the group", nil, nil)
	if imgui.IsItemDeactivatedAfterEdit() and newGroupName ~= "" and not eventGroups.groups[newGroupName] then
		table.insert(groups, {
			name = newGroupName,
			events = "custom"
		})
		eventGroups.process()
		return
	end
	if imgui.Button("Remove##beattoolsEventGroupsRemove") then
		cs.level.properties.beattools = nil
		return
	end
	imgui.SameLine()
	if imgui.Button("Clear##beattoolsEventGroupsClear") then
		cs.level.properties.beattools.eventGroups = {
			{
				events = "all",
				index = 0,
				name = "all",
				time = 1,
				visibility = "show"
			}
		}
		eventGroups.process()
		return
	end
	imgui.SameLine()
	if imgui.Button("Preset##beattoolsEventGroupsPreset") then
		cs.level.properties.beattools.eventGroups = helpers.copy(utilitools.files.beattools.configOptions.eventGroups.default)
		eventGroups.process()
		return
	end
	for i = 1, #groups do
		local group = groups[i]
		if i == 1 or groups[i - 1].index ~= group.index then imgui.Separator() end
		imgui.AlignTextToFramePadding()
		if imgui.Selectable_Bool(tostring(group.name), group.events == "custom", imgui.ImGuiSelectableFlags_AllowOverlap) and group.name ~= "all" then
			eventGroups.newEventType = ""
			utilitools.prompts.custom({
				title = "Event Groups > " .. group.name,
				func = function ()
					eventGroups.newEventType = utilitools.imguiHelpers.inputText("##beattoolsEventGroupsInputGroup", eventGroups.newEventType, "", "Click away or press enter to add an event type\nThis will convert custom groups to normal ones", nil, nil)
					eventGroups.newEventType = utilitools.suggest.suggest(eventGroups.newEventType, eventGroups.eventNames)
					local deactivated = imgui.IsItemDeactivated()
					if imgui.IsItemActive() then
						local cursorPos = imgui.GetCursorScreenPos()
						imgui.SetCursorScreenPos(imgui.ImVec2_Float(0, 0))
						-- dummy input for the tab feature to work
						utilitools.imguiHelpers.inputText("##beattoolsEventGroupsInputHidden", "", "", nil, nil, 1)
						imgui.SetCursorScreenPos(cursorPos)
					end
					if deactivated and eventGroups.newEventType ~= "" and eventGroups.eventMap[eventGroups.newEventType] then
						eventGroups.newEventType = eventGroups.eventMap[eventGroups.newEventType].id
						if type(group.events) ~= "table" or not group.events[eventGroups.newEventType] then
							if type(group.events) ~= "table" then group.events = {} end
							group.events[eventGroups.newEventType] = true
							addType(group, eventGroups.newEventType)
							eventGroups.process()
							eventGroups.newEventType = ""
							return
						end
					end
					imgui.Separator()
					if imgui.Button("Delete##beattoolsEventGroupsDeleteGroup") then
						if group.events == "custom" then
							eventGroups.custom[group.name] = nil
						end
						group.events = {}
						updateEventVisibilities(group)
						table.remove(groups, i)
						eventGroups.process()
						utilitools.prompts.close()
					end
					imgui.Separator()
					if type(group.events) ~= "table" then
						imgui.Text(tostring(group.events))
						return
					end
					--[[ if imgui.Button("Convert to custom##beattoolsEventGroupsButtonConvert") then
						group.events = "custom"
						eventGroups.custom[group.name] = group
						updateEventVisibilities(group)
						eventGroups.process()
						return
					end ]]
					---@diagnostic disable-next-line: param-type-mismatch
					for event, _ in pairs(group.events) do
						if imgui.Selectable_Bool(tostring(Event.info[event].name), nil, imgui.ImGuiSelectableFlags_NoAutoClosePopups) then
							group.events[event] = nil
							if eventGroups.emptyTable(group.events) then
								group.events = "custom"
								eventGroups.custom[group.name] = group
							end
							updateEventVisibilities(group)
							eventGroups.process()
							return
						end
					end
				end
			})
		end
		imgui.SameLine(eventGroups.length)
		if group.name ~= "all" then
			if group.index > 1 then
				if imgui.Button("^##beattoolsEventGroups" .. i) then
					table.remove(groups, i)
					for j = i, 1, -1 do
						if j == 1 or groups[j - 1].index < group.index - 1 then
							table.insert(groups, j, group)
							group.index = group.index - 1
							break
						end
					end
					updateEventVisibilities(group, true)
					eventGroups.process()
					break
				end
				imgui.SameLine()
			end
			if eventGroups.indices[group.index + 1] then
				local index2 = group.temp or group.index + 1
				if not group.temp then
					while eventGroups.indices[index2] do
						if eventGroups.overlapping(group, eventGroups.indices[index2]) then
							index2 = -2
							break
						end
						index2 = index2 + 1
					end
				end
				if index2 == -2 then
					group.temp = index2
					if imgui.Button("v##beattoolsEventGroups" .. i) then
						table.remove(groups, i)
						for j = i + 1, #groups + 1 do
							if j > #groups or (groups[j - 1].index ~= group.index and groups[j].index ~= groups[j - 1].index and eventGroups.overlapping(group, eventGroups.indices[groups[j - 1].index])) then
								group.index = groups[j] and groups[j].index or groups[j - 1].index + 1
								table.insert(groups, j, group)
								updateEventVisibilities(group)
								break
							end
						end
						eventGroups.process()
						break
					end
					imgui.SameLine()
				end
			end
		end
		local t = group.visibility
		group.visibility = utilitools.imguiHelpers.inputCombo("##beattoolsEventGroupsCombo" .. i, group.visibility, group.events == "all" and "show" or " - ", "Visibility for group " .. group.name, nil, group.events == "all" and { "show", "transparent", "ghost", "hide" } or { " - ", "show", "transparent", "ghost", "hide" }, {})
		if t ~= group.visibility then updateEventVisibilities(group) break end
	end
end

return function(window_flag, inputFlag)
	helpers.SetNextWindowPos(750, 420, window_flag)
	helpers.SetNextWindowSize(200, 300, window_flag)
	if imgui.Begin("Event Groups##beattoolsEventGroups", nil, (inputFlag or 0) + (mods.beattools.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mods.beattools.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0)) then
		innerImgui()
		imgui.End()
	end
end