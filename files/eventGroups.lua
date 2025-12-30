local function makeSpace(index, reverse)
	if type(reverse) ~= "number" then reverse = reverse and -1 or 1 end
	for k, v in pairs(cs.level.properties.beattools.eventGroups) do
		if v.index >= index then
			v.index = v.index + reverse
		end
	end
	if cs.level.properties.beattools.customEventGroups then
		for k, v in pairs(cs.level.properties.beattools.customEventGroups) do
			if v.index >= index then
				v.index = v.index + reverse
			end
		end
	end
end
return function(window_flag, inputFlag)
	if cs.level then
		if cs.level.properties.beattools == nil then cs.level.properties.beattools = {} end
		if cs.beattools.eventGroups.maxIndex == -1 then
			if cs.level.properties.beattools.eventGroups == nil then
				cs.level.properties.beattools.eventGroups = helpers.copy(utilitools.files.beattools.configOptions.eventGroups.default)
			end
			cs:beattoolsUpdateEventGroups()
		end
	end
	helpers.SetNextWindowPos(750, 420, window_flag)
	helpers.SetNextWindowSize(200, 300, window_flag)
	if imgui.Begin("Event Groups", nil, inputFlag) then
		if cs.level then
			local function checkOverlapping(group, index)
				local overlapping = false
				if cs.beattools.eventGroups.indices[index] then
					if cs.beattools.eventGroups.indices[index].events.custom or group.events.custom then
						overlapping = true
					else
						for k, v in pairs(group.events) do
							if cs.beattools.eventGroups.indices[index].events[k] then
								overlapping = true
								break
							end
						end
					end
				end
				return overlapping
			end
			if imgui.Button("Reset##EditorLayers") then
				if cs.level.properties.beattools.customEventGroups then
					makeSpace(1, 3)
				end
				cs.level.properties.beattools.eventGroups = helpers.copy(utilitools.files.beattools.configOptions.eventGroups.default)
				cs:beattoolsUpdateEventGroups()
				if cs.level.properties.beattools.customEventGroups then
					for k, v in pairs(cs.level.properties.beattools.customEventGroups) do
						v.visibility = " - "
					end
					local i = 1
					while i <= cs.beattools.eventGroups.maxIndex do
						local v = cs.beattools.eventGroups.indices[i]
						if v then
							while cs.beattools.eventGroups.indices[i - 1] == nil and i > 1 do
								makeSpace(i, true)
								cs:beattoolsUpdateEventGroups()
								i = i - 1
							end
						end
						i = i + 1
					end
				end
				changing = true
			end

			local changing = false
			if true then
				local buffer = ffi.new("char[?]", 256)
				ffi.copy(buffer, "Add Custom Group", #("Add Custom Group"))
				imgui.SetNextItemWidth(-1e-9)
				imgui.InputText("##addCustomEditorLayers", buffer, 256, 2^12)
				local value = ffi.string(buffer)
				if imgui.IsItemDeactivatedAfterEdit() and value and value ~= "" and value ~= "Add Custom Group" then
					if cs.level.properties.beattools.customEventGroups == nil then cs.level.properties.beattools.customEventGroups = {} end
					if cs.level.properties.beattools.eventGroups[value] or cs.level.properties.beattools.customEventGroups[value] then utilitools.prompts.error(mods.beattools, "Group name already exists") else
						cs.level.properties.beattools.customEventGroups[value] = {
							events = { custom = true },
							visibility = " - ",
							index = #cs.beattools.eventGroups.indices + 1
						}
						cs:beattoolsUpdateEventGroups()
						changing = true
					end
				end
			end
			local indexGroup = 0
			for i, v in ipairs(cs.beattools.eventGroups.groups) do
				if v.index ~= indexGroup then
					imgui.Separator()
					indexGroup = v.index
				end
				imgui.AlignTextToFramePadding()
				local currentPosition = imgui.GetCursorScreenPos()
				imgui.PushClipRect(imgui.ImVec2_Float(currentPosition.x, currentPosition.y), imgui.ImVec2_Float(currentPosition.x + cs.beattools.eventGroups.longest, currentPosition.y + 20), true)
				imgui.Text(v.name)
				imgui.PopClipRect()
				if v.name ~= "all" then
					if not changing and (v.index > 1 or cs.beattools.eventGroups.indices[v.index].groups > 1) then
						imgui.SameLine(cs.beattools.eventGroups.longest + 10)
						if imgui.Button("^##" .. v.name .. "_editorLayers") then
							if cs.beattools.eventGroups.indices[v.index].groups > 1 then
								makeSpace(v.index)
								v.index = v.index - 1
							else
								makeSpace(v.index, true)
								if checkOverlapping(v, v.index) then
									makeSpace(v.index)
									v.index = v.index - 1
								end
							end
							cs:beattoolsUpdateEventGroups()
							changing = true
						end
					end
					if not changing and (cs.beattools.eventGroups.indices[v.index + 1] or cs.beattools.eventGroups.indices[v.index].groups > 1) then
						imgui.SameLine(cs.beattools.eventGroups.longest + 28)
						if imgui.Button("v##" .. v.name .. "_editorLayers") then
							if cs.beattools.eventGroups.indices[v.index].groups > 1 then
								makeSpace(v.index + 1)
								v.index = v.index + 1
							else
								makeSpace(v.index + 1, true)
								if checkOverlapping(v, v.index + 1) then
									makeSpace(v.index + 1)
									v.index = v.index + 1
								end
							end
							cs:beattoolsUpdateEventGroups()
							changing = true
						end
					end
					if not changing then
						imgui.SameLine(cs.beattools.eventGroups.longest + 46)
						local valptr = ffi.new("int[1]", { v.index })
						imgui.SetNextItemWidth(15)
						imgui.InputInt("##" .. v.name .. "_insertEditorLayers", valptr, 0, nil, 2^12)
						local value = valptr[0]
						if imgui.IsItemDeactivatedAfterEdit() and value and value ~= v.index then
							local origIndex = v.index
							if value < 1 then
								value = 1
							elseif value > #cs.beattools.eventGroups.indices + 1 then
								value = #cs.beattools.eventGroups.indices + 1
							end
							if checkOverlapping(v, value) then
								makeSpace(value)
							end
							v.index = value
							if cs.beattools.eventGroups.indices[origIndex].groups <= 1 then
								makeSpace(origIndex + 1, true)
							end
							cs:beattoolsUpdateEventGroups()
							changing = true
						end
					end
				end
				imgui.SameLine(cs.beattools.eventGroups.longest + 64)
				local isOpen = imgui.BeginCombo("##" .. v.name .. "_visibilityEditorLayers", v.visibility, 2^4 + 2^5 + 2^7)
				if isOpen then
					for _, vv in ipairs(v.name ~= "all" and { " - ", "show", "transparent", "ghost", "hide" } or { "show", "transparent", "ghost", "hide" }) do
						local selected = imgui.Selectable_Bool(vv, vv == v.visibility)
						if selected and vv ~= v.visibility then
							v.visibility = vv
							cs.beattools.eventGroups.visibility = {}
							cs:noSelection()
						end
					end
					imgui.EndCombo()
				end
				if v.events.custom then
					imgui.SameLine()
					if imgui.Button("Delete##" .. v.name .. "_deleteEditorLayers") then
						cs.level.properties.beattools.customEventGroups[v.name] = nil
						local customEventsAmount = 0
						for _, _ in pairs(cs.level.properties.beattools.customEventGroups) do
							customEventsAmount = customEventsAmount + 1
						end
						if customEventsAmount == 0 then
							cs.level.properties.beattools.customEventGroups = nil
						end
						makeSpace(v.index + 1, true)
						cs:beattoolsUpdateEventGroups()
						changing = true
					end
				end
			end
		end
		imgui.End()
	end
end