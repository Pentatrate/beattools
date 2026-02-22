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
			eventGroups.initMinimal()
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
		utilitools.files.beattools.eventGroups.init()
		return
	end
	imgui.SameLine()
	if imgui.Button("Clear##beattoolsEventGroupsClear") then
		eventGroups.initMinimal()
		return
	end
	imgui.SameLine()
	if imgui.Button("Preset##beattoolsEventGroupsPreset") then
		cs.level.properties.beattools.eventGroups = {
			{
				events = "all",
				name = "all",
				visibility = "show"
			},
			{
				events = "chart",
				name = "chart",
				visibility = " - "
			},
			{
				events = "level",
				name = "level",
				visibility = " - "
			},
			{
				events = {
					bookmark = true
				},
				name = "bookmarks",
				visibility = " - "
			},
			{
				events = {
					block = true,
					bounce = true,
					extraTap = true,
					hold = true,
					inverse = true,
					mine = true,
					mineHold = true,
					paddles = true,
					setBounceHeight = true,
					side = true
				},
				name = "gameplay",
				visibility = " - "
			},
			{
				events = {
					play = true,
					playSound = true,
					retime = true,
					setBPM = true,
					showResults = true
				},
				name = "song",
				visibility = " - "
			},
			{
				events = {
					advancetextdeco = true,
					aft = true,
					deco = true,
					ease = true,
					easeSequence = true,
					forcePlayerSprite = true,
					hom = true,
					noise = true,
					outline = true,
					setBgColor = true,
					setBoolean = true,
					setColor = true,
					songNameOverride = true,
					textdeco = true,
					toggleParticles = true
				},
				name = "visuals",
				visibility = " - "
			},
			{
				events = {
					hom = true,
					noise = true,
					outline = true,
					setBgColor = true,
					setColor = true
				},
				name = "color",
				visibility = " - "
			},
			{
				events = {
					tag = true
				},
				name = "tags",
				visibility = " - "
			},
			{
				events = {
					advancetextdeco = true,
					deco = true,
					textdeco = true
				},
				name = "deco",
				visibility = " - "
			},
			{
				events = {
					ease = true,
					easeSequence = true,
					setBoolean = true
				},
				name = "eases",
				visibility = " - "
			}
		}
		eventGroups.process()
		utilitools.files.beattools.eventGroups.init()
		return
	end
	eventGroups.officialLayers()
	for i = 1, #groups do
		local group = groups[i]
		if i == 1 or groups[i - 1].index ~= group.index then imgui.Separator() end
		imgui.AlignTextToFramePadding()
		if imgui.Selectable_Bool(tostring(group.name), group.events == "custom", imgui.ImGuiSelectableFlags_AllowOverlap) and not eventGroups.permanent[group.name] then
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
						eventGroups.updateEventVisibilities(group)
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
							if utilitools.table.emptyTable(group.events) then
								group.events = "custom"
								eventGroups.custom[group.name] = group
							end
							eventGroups.updateEventVisibilities(group)
							eventGroups.process()
							return
						end
					end
				end
			})
		end
		imgui.SameLine(eventGroups.length)
		if not eventGroups.permanent[group.name] then
			if group.index > 2 then
				if imgui.Button("^##beattoolsEventGroups" .. i) then
					table.remove(groups, i)
					for j = i, 1, -1 do
						if j == 1 or groups[j - 1].index < group.index - 1 then
							table.insert(groups, j, group)
							group.index = group.index - 1
							break
						end
					end
					eventGroups.updateEventVisibilities(group, true)
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
								eventGroups.updateEventVisibilities(group)
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
		if t ~= group.visibility then
			if group.name == "all" then
				if eventGroups.groups.chart.visibility ~= " - " then
					eventGroups.groups.chart.visibility = " - "
					eventGroups.updateEventVisibilities(eventGroups.groups.chart)
				end
				if eventGroups.groups.level.visibility ~= " - " then
					eventGroups.groups.level.visibility = " - "
					eventGroups.updateEventVisibilities(eventGroups.groups.level)
				end
			end
			eventGroups.updateEventVisibilities(group)
			break
		end
	end
end

return function(window_flag, inputFlag)
	helpers.SetNextWindowPos(750, 420, window_flag)
	helpers.SetNextWindowSize(200, 300, window_flag)
	if imgui.Begin("Event Groups##beattoolsEventGroups", nil, (inputFlag or 0) + (mod.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mod.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0)) then
		innerImgui()
		imgui.End()
	end
end