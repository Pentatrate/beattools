local configHelpers = utilitools.configHelpers
local imguiHelpers = utilitools.imguiHelpers

return function(inputFlag)
	helpers.SetNextWindowPos(750, 420, window_flag or 'ImGuiCond_FirstUseEver')
	helpers.SetNextWindowSize(200, 300, window_flag or 'ImGuiCond_FirstUseEver')
	if imgui.Begin("Ease List", nil, inputFlag) then
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
		for i, v in ipairs(beattools.easeList.sorted) do
			if ((not mods.beattools.config.easeListUse) or beattools.easeList.unsorted.uselessEases[v] == nil)
			and ((not mods.beattools.config.easeListSerious) or beattools.easeList.unsorted.troll[v] == nil)
			and ((not mods.beattools.config.easeListSelected) or beattools.easeList.selected[v]) then
				cs:beattoolsCurrentEasing("ease", "var", "editorBeat", v)
				if ((not mods.beattools.config.easeListUsed) or #(cs.beattoolsEasings.ease[v] or {}) > 0)
				and ((not mods.beattools.config.easeListUsedVars) or v == "vfx.vars0" or v:sub(1, #"vfx.vars") ~= "vfx.vars" or #(cs.beattoolsEasings.ease[v] or {}) > 0) then
					imgui.TableNextRow()
					imgui.TableNextColumn()

					local text
					if type(beattools.easeList.unsorted.all[v]) == "boolean" then
						text = tostring(cs.beattoolsCurrentEasings.editorBeat.ease[v].enable)
					elseif type(beattools.easeList.unsorted.all[v]) == "number" or v == "outline" then
						if cs.beattoolsCurrentEasings.editorBeat.ease[v].value == nil or not mods.beattools.config.easeListRound then
							text = tostring(cs.beattoolsCurrentEasings.editorBeat.ease[v].value)
						else
							text = tostring(helpers.round(cs.beattoolsCurrentEasings.editorBeat.ease[v].value * 1e3) / 1e3)
						end
					end
					if mods.beattools.config.easeListSelectChanged then
						beattools.easeList.selected[v] = cs.beattoolsCurrentEasings.editorBeat.ease[v][type(beattools.easeList.unsorted.all[v]) == "boolean" and "enable" or "value"] ~= beattools.easeList.unsorted.all[v] or nil
					end

					local pressed = imgui.Selectable_Bool(text, beattools.easeList.selected[v], imgui.ImGuiSelectableFlags_SpanAllColumns)
					imguiHelpers.tooltip((cs.beattoolsCurrentEasings.editorBeat.ease[v].runEvents - 1) .. "/" .. #(cs.beattoolsEasings.ease[v] or {}) .. " events")

					if pressed then
						local function shouldSelect(v2)
							if v == "bgColor" and v2.type == "setBgColor" and v2.color ~= nil then return true end
							if v == "voidColor" and v2.type == "setBgColor" and v2.voidColor ~= nil then return true end
							if v == "outline" then return v2.type == "outline" and (v2.enable ~= nil or v2.color ~= nil) end
							if v == "vfx.bgNoise" and v2.type == "noise" and v2.chance ~= nil then return true end
							if v == "vfx.bgNoiseColor" and v2.type == "noise" and v2.color ~= nil then return true end
							if v:sub(1, 18) == "vfx.noteParticles." and v2.type == "toggleParticles" and v2[v:sub(19)] ~= nil then return true end
							return v2.type == (type(beattools.easeList.unsorted.all[v]) == "boolean" and "setBoolean" or "ease") and v2.var == v
						end
						local eventsDeleted = 0
						if cs.multiselect ~= nil then
							for i2 = #cs.multiselect.events, 1, -1 do
								local v2 = cs.multiselect.events[i2]
								if shouldSelect(v2) then
									table.remove(cs.multiselect.events, i2)
									eventsDeleted = eventsDeleted + 1 + (v2.type == "ease" and v2.repeats and v2.repeats > 0 and (v2.repeatDelay or 1) ~= 0 and v2.repeats or 0)
								end
							end
						end
						local function addEases()
							if cs.multiselect == nil then
								cs:newMulti()
								cs.multiselectStartBeat = nil
								cs.multiselectEndBeat = nil
							end
							local function addToMultiSelect(v2)
								table.insert(cs.multiselect.events, v2)
								cs.multiselect.eventTypes[v2.type] = true
								if cs.multiselectStartBeat == nil then
									cs.multiselectStartBeat = v2.time
									cs.multiselectEndBeat = v2.time
								else
									if cs.multiselectStartBeat > v2.time then
										cs.multiselectStartBeat = v2.time
									end
									if cs.multiselectEndBeat < v2.time then
										cs.multiselectEndBeat = v2.time
									end
								end
							end
							if (cs.selectedEvent and shouldSelect(cs.selectedEvent)) or eventsDeleted == 1 or cs.beattoolsCurrentEasings.editorBeat.ease[v].runEvents == 1 then
								for i2, v2 in ipairs(cs.level.events) do
									if shouldSelect(v2) then addToMultiSelect(v2) end
								end
							elseif eventsDeleted == 0 then
								local v3
								for i2, v2 in ipairs(cs.level.events) do
									if shouldSelect(v2) and v2.time <= cs.editorBeat and (v3 == nil or v2.time > v3.time or (v2.time == v3.time and (v2.order or 0) >= (v3.order or 0))) then
										v3 = v2
									end
								end
								if v3 ~= nil then
									addToMultiSelect(v3)
								end
							end
							if cs.multiselectStartBeat == nil then
								cs.multiselectStartBeat = 0
								cs.multiselectEndBeat = 360
							end

							cs.p:hurtPulse()
						end
						if not mods.beattools.config.easeListSelectChanged then
							if beattools.easeList.selected[v] and (#(cs.beattoolsEasings.ease[v] or {}) == 0 or eventsDeleted == #(cs.beattoolsEasings.ease[v] or {})) then
								beattools.easeList.selected[v] = nil
							else
								beattools.easeList.selected[v] = true
								if #(cs.beattoolsEasings.ease[v] or {}) > 0 then addEases() end
							end
						elseif #(cs.beattoolsEasings.ease[v] or {}) > 0 and (eventsDeleted == 0 or eventsDeleted ~= #(cs.beattoolsEasings.ease[v] or {})) then
							addEases()
						end
					end
					if imgui.IsItemClicked(1) then
						modlog(mods.beattools, "Copied to clipboard: " .. text)
						love.system.setClipboardText(text)
						cs.p:hurtPulse()
					end
					if imgui.IsItemClicked(2) then
						if type(beattools.easeList.unsorted.all[v]) == "boolean" then
							cs.placeEvent = "beattoolsEvent;setBoolean;var," .. v .. ",string;enable," .. text .. ",boolean"
						else
							cs.placeEvent = "beattoolsEvent;ease;var," .. v .. ",string;value," .. text .. "," .. (type(beattools.easeList.unsorted.all[v]) == "number" and "number" or "nil")
						end
					end

					imgui.TableNextColumn()
					if #(cs.beattoolsEasings.ease[v] or {}) == 0 then
						imgui.TextDisabled(v)
					else
						imgui.Text(v)
					end
				end
			end
		end
		imgui.EndTable()

		imgui.End()
	end
end
