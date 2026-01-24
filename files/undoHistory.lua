local function summary(changes)
	local list = {
		fullSave = { "Autosaved" },
		add = { "Placed", "%count", "%type" },
		remove = { "Deleted", "%count", "%type" },
		change = { "Edited", "%key", "for", "%count", "%type" }
	}
	local countCache
	local function subSummary(category)
		if category:sub(1, 1) ~= "%" then return "INVALID" end
		if category == "%count" and countCache then return countCache end
		local types = {
			["%count"] = {
				start = {},
				func = function(change, value)
					value[tostring(change.ref)] = true
					return value
				end,
				count = function(value)
					local temp = 0
					for k, v in pairs(value) do temp = temp + 1 end
					return temp
				end,
				nothing = "no"
			},
			["%type"] = {
				different = "event",
				func = function(change, value) return Event.info[change.ref.type].name:lower() end,
				count = true
			},
			["%key"] = {
				different = "parameters",
				func = function(change, value) return change.key end
			}
		}
		if types[category] == nil then return "INVALID" end
		if type(types[category].func) ~= "function" then return "INVALID FUNC" end
		if #changes < 1 then return types[category].nothing or "nothing" end

		local value = types[category].different and types[category].func(changes[1], types[category].start) or types[category].start
		for i, change in ipairs(changes) do
			if types[category].different then
				if value ~= types[category].different and value ~= types[category].func(change, value) then
					value = types[category].different
				end
			else
				value = types[category].func(change, value)
			end
		end
		if types[category].count then
			if type(types[category].count) == "boolean" and subSummary("%count") > 1 then
				value = value .. "s"
			elseif type(types[category].count) == "function" then
				value = types[category].count(value)
			end
		end
		if category == "%count" then countCache = value or "nil" end
		return value or "nil"
	end

	if #changes < 1 then return "Nothing" end

	local same = changes[1].type
	local place = same == "add" and true

	for i, change in ipairs(changes) do
		if same ~= change.type then
			same = nil
		end
		if place then
			if same == "add" then
			else
				if change.type ~= "change" then
					place = false
				end
			end
		end
	end

	if same == nil and place then
		same = "add"
	end
	if same then
		if list[same] == nil then return "Invalid type" end
		local text = ""

		for i, v in ipairs(list[same]) do
			local val = v:sub(1, 1) == "%" and subSummary(v) or v
			if v ~= "%count" or val ~= 1 then
				text = text .. (i == 1 and "" or " ") .. val
			end
		end
		return text
	else
		return "Multiple changes"
	end
end
return function(window_flag, inputFlag)
	helpers.SetNextWindowPos(750, 400, window_flag)
	helpers.SetNextWindowSize(200, 320, window_flag)
	if imgui.Begin("Undo History", nil, (inputFlag or 0) + (mods.beattools.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mods.beattools.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0)) then
		if imgui.BeginTabBar("beattoolsUndo") then
			local first
			local changes = {}
			if imgui.BeginTabItem("History##beattoolsUndo") then
				imgui.Text(utilitools.files.beattools.undo.index .. "/" .. #utilitools.files.beattools.undo.changes)
				for i, change in ipairs(utilitools.files.beattools.undo.changes) do
					if #changes == 0 then first = i end
					table.insert(changes, change)
					if utilitools.files.beattools.undo.changes[i + 1] == nil or math.abs(change.time - utilitools.files.beattools.undo.changes[i + 1].time) >= 0.01 then
						if imgui.Selectable_Bool(summary(changes) .. "##" .. i, i <= utilitools.files.beattools.undo.index) then
							local temp = 0
							while utilitools.files.beattools.undo.index < first and temp < 1e3 do
								temp = temp + 1
								utilitools.files.beattools.undo.keybind(false, false)
							end
							temp = 0
							while utilitools.files.beattools.undo.index > i and temp < 1e3 do
								temp = temp + 1
								utilitools.files.beattools.undo.keybind(true, false)
							end
						end
						changes = {}
					end
				end
				imgui.EndTabItem("History##beattoolsUndo")
			end
		end

		imgui.End()
	end
end