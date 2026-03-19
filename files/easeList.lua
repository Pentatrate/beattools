local configHelpers = utilitools.configHelpers
local imguiHelpers = utilitools.imguiHelpers
configHelpers.setMod(mod)

return function(window_flag, inputFlag)
	helpers.SetNextWindowPos(750, 420, window_flag)
	helpers.SetNextWindowSize(200, 300, window_flag)
	if imgui.Begin("Ease List", nil, (inputFlag or 0) + (mods.beattools.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mods.beattools.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0)) then
		if imgui.TreeNode_Str("Filters") then
			configHelpers.input("easeListUse")
			configHelpers.input("easeListUsed")
			configHelpers.input("easeListSerious")
			configHelpers.input("easeListSelectChanged")
			configHelpers.input("easeListSelected")
			configHelpers.input("easeListRound")
			configHelpers.input("easeListUsedVars")
			imgui.TreePop()
		end
		imgui.BeginTable("easeList", 2, imgui.ImGuiTableFlags_RowBg + imgui.ImGuiTableFlags_BordersInnerH + imgui.ImGuiTableFlags_BordersInnerV + imgui.ImGuiTableFlags_SizingFixedFit)
		for i, different in ipairs(beattools.easeList.sorted) do
			if ((not mods.beattools.config.easeListUse) or beattools.easeList.unsorted.uselessEases[different] == nil)
			and ((not mods.beattools.config.easeListSerious) or beattools.easeList.unsorted.troll[different] == nil)
			and ((not mods.beattools.config.easeListSelected) or beattools.easeList.selected[different]) then
				local ease, count = utilitools.files.beattools.easing.getEase("ease", different, cs.editorBeat, nil, nil)
				if ((not mods.beattools.config.easeListUsed) or count.total > 0)
				and ((not mods.beattools.config.easeListUsedVars) or different == "vfx.vars0" or different:sub(1, #"vfx.vars") ~= "vfx.vars" or count.total > 0) then
					imgui.TableNextRow()
					imgui.TableNextColumn()

					local text
					if type(beattools.easeList.unsorted.all[different]) == "boolean" then
						text = tostring(ease.value)
					elseif type(beattools.easeList.unsorted.all[different]) == "number" or different == "outline" then
						if ease.value == nil or not mods.beattools.config.easeListRound then
							text = tostring(ease.value)
						else
							text = tostring(helpers.round(ease.value * 1e3) / 1e3)
						end
					end
					if mods.beattools.config.easeListSelectChanged then
						beattools.easeList.selected[different] = ease.value ~= beattools.easeList.unsorted.all[different] or nil
					end

					imgui.Selectable_Bool(text, beattools.easeList.selected[different], imgui.ImGuiSelectableFlags_SpanAllColumns)
					imguiHelpers.tooltip((beattools.easeList.unsorted.desc[different] and tostring(beattools.easeList.unsorted.desc[different]) .. "\n" or "") .. count.index .. "/" .. count.total .. " events")

					if imgui.IsItemClicked(0) then modlog(mod, "yes, im selecting eases rn") utilitools.files.beattools.easing.select("ease", different) end
					if imgui.IsItemClicked(1) then utilitools.string.toClipboard(text) end
					if imgui.IsItemClicked(2) then
						if type(beattools.easeList.unsorted.all[different]) == "boolean" then
							cs.placeEvent = "beattoolsEvent;setBoolean;var," .. different .. ",string;enable," .. text .. ",boolean"
						else
							cs.placeEvent = "beattoolsEvent;ease;var," .. different .. ",string;value," .. text .. "," .. (type(beattools.easeList.unsorted.all[different]) == "number" and "number" or "nil")
						end
					end

					imgui.TableNextColumn()
					if count.total == 0 then
						imgui.TextDisabled(different)
					else
						imgui.Text(different)
					end
				end
			end
		end
		imgui.EndTable()

		imgui.End()
	end
end
