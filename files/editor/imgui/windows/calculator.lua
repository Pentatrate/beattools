local function calc(math)
	func = loadstring("return tostring(" .. math .. ")")
	if func then
		return pcall(func)
	else
		return false, ""
	end
end

return function(window_flag, inputFlag)
	if mod.config.editorCalculator then
		helpers.SetNextWindowPos(750, 400, window_flag)
		helpers.SetNextWindowSize(200, 320, window_flag)
		mod.config.editorCalculator = imgui.Begin("Calculate", true, (inputFlag or 0) + (mod.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mod.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0))
		local saveToHistory = false
		imgui.TextWrapped(mod.config.calculator.output)
		if imgui.IsItemClicked(1) then -- right click
			utilitools.string.toClipboard(mod.config.calculator.output)
		end

		local newInput = utilitools.imguiHelpers.inputMultiline("##beattoolsCalculator", mod.config.calculator.input, "", nil, nil, nil)

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

				numPad("SRT", "^(1/2)") sl() numPad("SPC", " ") sl() if imgui.Button("CLR") then newInput = "" end sl() if imgui.Button("DEL") then newInput = newInput:sub(1, -2) end
				numPad("(") sl() numPad(")") sl() numPad("^") sl() numPad("/")
				numRow(7) numPad("*")
				numRow(4) numPad("-")
				numRow(1) numPad("+")
				numPad("RND", ")", "helpers.round(") sl() numPad("0") sl() numPad(".") sl() if imgui.Button(" = ") then saveToHistory = true end

				imgui.EndTabItem("Number Pad##beattoolsCalculator")
			end
			if imgui.BeginTabItem("History##beattoolsCalculator") then
				if imgui.Button("Save to history") then saveToHistory = true end
				for i, v in ipairs(mod.config.calculator.history) do
					imgui.Separator()
					imgui.TextDisabled(v.input)
					if imgui.Selectable_Bool(v.output, false) then
						newInput = newInput .. " " .. v.output
					end
					if imgui.IsItemClicked(1) then -- right click
						utilitools.string.toClipboard(v.output)
					end
				end
				imgui.EndTabItem("History##beattoolsCalculator")
			end
			if imgui.BeginTabItem("Lua Syntax##beattoolsCalculator") then
				imgui.TextWrapped("Newlines possible\n+ - * / ^ symbols\nmath.sin( / .cos( etc.\nmath.floor( / .ceil( etc.\nhelpers.round(")
				imgui.EndTabItem("Lua Syntax##beattoolsCalculator")
			end
			imgui.EndTabBar()
		end

		if mod.config.calculator.input ~= newInput then
			if newInput == "" then
				mod.config.calculator.output = "-"
			else
				local success, result = calc(newInput)
				if success then
					mod.config.calculator.output = result
				end
			end
			mod.config.calculator.input = newInput
		end
		if saveToHistory then
			local lastEntry = mod.config.calculator.history[#mod.config.calculator.history]
			if lastEntry.input ~= mod.config.calculator.input or lastEntry.output ~= mod.config.calculator.output then
				table.insert(mod.config.calculator.history, {
					input = mod.config.calculator.input, output = mod.config.calculator.output
				})
				while #mod.config.calculator.history > 20 do
					table.remove(mod.config.calculator.history, 1)
				end
			end
		end

		imgui.End()
	end
end