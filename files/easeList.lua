local configHelpers = utilitools.configHelpers
local imguiHelpers = utilitools.imguiHelpers
local easeList = beattools.easeList

local function config()
	configHelpers.setMod(mod)
	utilitools.imguiHelpers.treeNode("Filters", function()
		configHelpers.input("easeListUse")
		configHelpers.input("easeListUsed")
		configHelpers.input("easeListSerious")
		configHelpers.input("easeListSelectChanged")
		configHelpers.input("easeListSelected")
		configHelpers.input("easeListRound")
		configHelpers.input("easeListUsedVars")
	end)
end

local function checkEase(different)
	if mod.config.easeListUse and easeList.unsorted.uselessEases[different] then return false end
	if mod.config.easeListSerious and easeList.unsorted.troll[different] then return false end
	if mod.config.easeListSelected and not easeList.selected[different] then return false end

	local ease, count = utilitools.files.beattools.easing.getEase("ease", different, cs.editorBeat, nil, nil)

	if mod.config.easeListUsed and count.total <= 0 then return false end
	if mod.config.easeListUsedVars and different ~= "vfx.vars0" and different:sub(1, #"vfx.vars") == "vfx.vars" and count.total <= 0 then return false end

	return ease, count
end

local function drawEase(different)
	local ease, count = checkEase(different)
	if not ease or not count then return end

	local defaultValues = utilitools.files.beattools.easing.getDefault("ease", different)

	local text, min, max, default
	text, default = ease.value, defaultValues.value or "?"
	if ease.random then min, max = ease.valueMin, ease.valueMax end
	-- if type(easeList.unsorted.all[different]) == "boolean" then
	if type(easeList.unsorted.all[different]) == "number" or different == "outline" then
		if text ~= nil and mod.config.easeListRound then
			text = helpers.round(text * 1e3) / 1e3
			default = defaultValues.value and helpers.round(defaultValues.value * 1e3) / 1e3 or default
			if ease.random then min, max = helpers.round(min * 1e3) / 1e3, helpers.round(max * 1e3) / 1e3 end
		end
	end
	if ease.random then
		min, max = tostring(min), tostring(max)
		text = string.format("%s (%s-%s)", text, min, max)
	end
	text, default = tostring(text), tostring(default)

	if mod.config.easeListSelectChanged then easeList.selected[different] = ease.value ~= easeList.unsorted.all[different] or nil end

	imgui.TableNextRow()
	imgui.TableNextColumn()

	imgui.Selectable_Bool(text, easeList.selected[different], imgui.ImGuiSelectableFlags_SpanAllColumns)
	imguiHelpers.tooltip((easeList.unsorted.desc[different] and tostring(easeList.unsorted.desc[different]) .. "\n" or "") .. "Default: " .. default .. "\n" .. tostring(count.index) .. "/" .. tostring(count.total) .. " events")

	if imgui.IsItemClicked(0) then modlog(mod, "yes, im selecting eases rn") utilitools.files.beattools.easing.select("ease", different) end
	if imgui.IsItemClicked(1) then utilitools.string.toClipboard(text) end
	if imgui.IsItemClicked(2) then
		if type(easeList.unsorted.all[different]) == "boolean" then
			cs.placeEvent = "beattoolsEvent;setBoolean;var," .. different .. ",string;enable," .. text .. ",boolean"
		else
			cs.placeEvent = "beattoolsEvent;ease;var," .. different .. ",string;value," .. text .. "," .. (type(easeList.unsorted.all[different]) == "number" and "number" or "nil")
		end
	end

	imgui.TableNextColumn()

	if count.total == 0 then imgui.TextDisabled(different) else imgui.Text(different) end
end

local function doList()
	config()

	local hasStuff
	for _, different in ipairs(easeList.sorted) do
		if checkEase(different) then hasStuff = true break end
	end
	if not (mod.config.easeList and hasStuff) then return end

	if not imgui.BeginTable("easeList", 2, imgui.ImGuiTableFlags_RowBg + imgui.ImGuiTableFlags_BordersInnerH + imgui.ImGuiTableFlags_BordersInnerV + imgui.ImGuiTableFlags_SizingFixedFit) then return end

	for _, different in ipairs(easeList.sorted) do
		drawEase(different)
	end

	imgui.EndTable()
end

return function(window_flag, inputFlag)
	if not mod.config.easeList then return end

	helpers.SetNextWindowPos(750, 420, window_flag)
	helpers.SetNextWindowSize(200, 300, window_flag)
	mod.config.easeList = imgui.Begin("Ease List", true, (inputFlag or 0) + (mod.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mod.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0))

	doList()

	imgui.End()
end
