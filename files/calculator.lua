local function calc(math)
	func = loadstring("return tostring(" .. math .. ")")
	if func then
		return pcall(func)
	else
		return false, ""
	end
end

helpers.SetNextWindowPos(750, 400, window_flag or 'ImGuiCond_FirstUseEver')
helpers.SetNextWindowSize(200, 320, window_flag or 'ImGuiCond_FirstUseEver')
if imgui.Begin("Calculate", true) then
	local saveToHistory = false
	imgui.TextWrapped(mods.beattools.config.calculator.output)

	local newInput = utilitools.imguiHelpers.inputMultiline("##beattoolsCalculator",
		mods.beattools.config.calculator.input, "", nil, nil, nil)

	if imgui.BeginTabBar("beattoolsCalculator") then
		if imgui.BeginTabItem("Number Pad##beattoolsCalculator") then
			local function sl() imgui.SameLine() end
			local function numPad(name, value, before)
				name = name or "?"
				value = value or name
				if #name == 1 then name = " " .. name .. " " end
				name = name .. "##beattoolsCalculator"
				before = before or ""
				if imgui.Button(name) then
					newInput = before .. newInput .. value
				end
			end
			local function numRow(start)
				for i = 0, 2 do
					numPad(tostring(start + i), tostring(start + i))
					imgui.SameLine()
				end
			end

			numPad("SRT", "^(1/2)")
			sl()
			numPad("SPC", " ")
			sl()
			if imgui.Button("CLR") then newInput = "" end
			sl()
			if imgui.Button("DEL") then newInput = newInput:sub(1, -2) end
			numPad("(")
			sl()
			numPad(")")
			sl()
			numPad("^")
			sl()
			numPad("/")
			numRow(7)
			numPad("*")
			numRow(4)
			numPad("-")
			numRow(1)
			numPad("+")
			numPad("RND", ")", "helpers.round(")
			sl()
			numPad("0")
			sl()
			numPad(".")
			sl()
			if imgui.Button(" = ") then saveToHistory = true end

			imgui.EndTabItem("Number Pad##beattoolsCalculator")
		end
		if imgui.BeginTabItem("History##beattoolsCalculator") then
			if imgui.Button("Save to history") then saveToHistory = true end
			for i, v in ipairs(mods.beattools.config.calculator.history) do
				imgui.Separator()
				imgui.TextDisabled(v.input)
				if imgui.Selectable_Bool(v.output, false) then
					newInput = newInput .. " " .. v.output
				end
			end
			imgui.EndTabItem("History##beattoolsCalculator")
		end
		if imgui.BeginTabItem("Lua Syntax##beattoolsCalculator") then
			imgui.TextWrapped(
				"Newlines possible\n+ - * / ^ symbols\nmath.sin( / .cos( etc.\nmath.floor( / .ceil( etc.\nhelpers.round(")
			imgui.EndTabItem("Lua Syntax##beattoolsCalculator")
		end
	end

	if mods.beattools.config.calculator.input ~= newInput then
		if newInput == "" then
			mods.beattools.config.calculator.output = "-"
		else
			local success, result = calc(newInput)
			if success then
				mods.beattools.config.calculator.output = result
			end
		end
		mods.beattools.config.calculator.input = newInput
	end
	if saveToHistory then
		local lastEntry = mods.beattools.config.calculator.history[#mods.beattools.config.calculator.history]
		if lastEntry.input ~= mods.beattools.config.calculator.input or lastEntry.output ~= mods.beattools.config.calculator.output then
			table.insert(mods.beattools.config.calculator.history, {
				input = mods.beattools.config.calculator.input, output = mods.beattools.config.calculator.output
			})
			while #mods.beattools.config.calculator.history > 20 do
				table.remove(mods.beattools.config.calculator.history, 1)
			end
		end
	end

	imgui.End()
end