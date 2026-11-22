local imguiStyle = {
	allSavedStyles = {},
	tempStyleName = ""
}

imguiStyle.saveStyle = function(styleName, notCurrent)
	mod.config.imguiStyles[styleName] = { name = styleName, vars = {} }
	if styleName ~= "default" then
		mod.config.imguiStyles[styleName].colors = {}
		for i = 0, imgui.ImGuiCol_COUNT - 1 do
			local v = imgui.GetStyleColorVec4(i)
			mod.config.imguiStyles[styleName].colors[tostring(i)] = { v.x, v.y, v.z, v.w }
		end
	end
	for i = 0, imgui.ImGuiStyleVar_COUNT - 1 do
		local v = imguiStyle.styleObj[imguiStyle.styleVarNames[i]]
		if type(v) == "number" then
			mod.config.imguiStyles[styleName].vars[imguiStyle.styleVarNames[i]] = v
		else
			mod.config.imguiStyles[styleName].vars[imguiStyle.styleVarNames[i]] = { v.x, v.y }
		end
	end
	if not notCurrent then mod.config.currentImguiStyle = styleName end
	modlog(mod, "Saving " .. styleName)
	imguiStyle.updateAllSavedStyles()
end
imguiStyle.promptStyleName = function(func)
	if type(func) ~= "function" then error("imguiStyle.promptStyleName: Expected type function for parameter: " .. type(func) .. " " .. tostring(func)) end
	imguiStyle.tempStyleName = ""
	utilitools.prompts.custom({
		title = "Style Manager > Style name", message = "Name the style",
		func = function()
			imguiStyle.tempStyleName = utilitools.imguiHelpers.inputText("##beattoolsStyleName", imguiStyle
				.tempStyleName, "", "The name your style will have in this menu")
		end,
		confirmFunc = function()
			if ({ [""] = true, default = true, ["from old format"] = true })[imguiStyle.tempStyleName] then
				imguiStyle.promptStyleName(func)
			else
				if mod.config.imguiStyles[imguiStyle.tempStyleName] ~= nil then
					utilitools.prompts.custom({
						title = "Style Manager > Select style name > Confirm", message = "Do you want to overrite the current saved style?",
						buttonsTable = {
							{ "Overwrite", function() func(imguiStyle.tempStyleName) end },
							{ "Choose new name", function() imguiStyle.promptStyleName(func) end }
						}
					})
				else func(imguiStyle.tempStyleName) end
			end
		end
	})
end
imguiStyle.removeStyle = function(styleName)
	if mod.config.imguiStyles[styleName] == nil then error("imguiStyle.removeStyle: styleName doesn't exist: " .. tostring(styleName)) end
	if styleName == "default" then error("imguiStyle.removeStyle: styleName mustn't be default") end
	mod.config.imguiStyles[styleName] = nil
	imguiStyle.updateAllSavedStyles()
	if mod.config.currentImguiStyle == styleName then imguiStyle.applyStyle("default") end
end
imguiStyle.applyStyle = function(styleName)
	if mod.config.imguiStyles[styleName] == nil then error("imguiStyle.applyStyle: styleName doesn't exist: " .. tostring(styleName)) end
	modlog(mod, "Applying " .. styleName)
	if styleName == "default" then imgui.StyleColorsDark(imguiStyle.styleObj) else
		for i = 0, imgui.ImGuiCol_COUNT - 1 do
			if mod.config.imguiStyles[styleName].colors[tostring(i)] then
				local v = mod.config.imguiStyles[styleName].colors[tostring(i)]
				imguiStyle.styleObj.Colors[i] = imgui.ImVec4_Float(v[1], v[2], v[3], v[4])
			end
		end
	end
	for k, v in pairs(mod.config.imguiStyles[styleName].vars) do
		if type(v) == "number" then
			imguiStyle.styleObj[k] = v
		else
			imguiStyle.styleObj[k] = imgui.ImVec2_Float(v[1], v[2])
		end
	end
	mod.config.currentImguiStyle = styleName
end
imguiStyle.updateAllSavedStyles = function()
	local styles = {}
	for k, v in pairs(mod.config.imguiStyles) do if v.name ~= k then modlog(mod, "imguiStyle.updateAllSavedStyles: " .. k .. " doesnt have a name") v.name = k end table.insert(styles, k) end
	table.sort(styles)
	imguiStyle.allSavedStyles = styles
	modlog(mod, "Updated style list")
end
imguiStyle.imguiColorsFormat = function(styleName)
	mod.config.imguiStyles[styleName] = { name = styleName, vars = mod.config.imguiStyles.default.vars }
	local function fail() modlog(mod, "Failed.") utilitools.prompts.error(mod, "ImGui data detected, but it's invalid :skull:") end
	local text = love.system.getClipboardText()
	for w in string.gmatch(string.gsub(text, "colors%[", "?"), "[^?]+") do
		local i1 = string.find(w, "]", 1, true)
		if i1 then
			local _, i2 = string.find(w, "= ImVec4(", i1 + 1, true)
			if i2 then
				local i3 = string.find(w, "f);", i2 + 1, true)
				if i3 then
					local values = {}
					for ww in string.gmatch(string.gsub(string.sub(w, i2 + 1, i3 - 1), "f, ", "?"), "[^?]+") do
						table.insert(values, tonumber(ww))
					end
					if #values == 4 then
						-- modlog(mod, string.sub(w, 1, i1 - 1) .. " " .. values[1] .. " " .. values[2] .. " " .. values[3] .. " " .. tostring(values[4]))
						-- imgui.PushStyleColor_Vec4(imgui[string.sub(w, 1, i1 - 1)], imgui.ImVec4_Float(values[1], values[2], values[3], values[4]))
						mod.config.imguiStyles[styleName].colors[tostring(imgui[string.sub(w, 1, i1 - 1)])] = values
						-- mod.config.imguiColors[string.sub(w, 1, i1 - 1)] = values
					else fail() end
				else fail() end
			else fail() end
		elseif string.find(w, "ImVec4* colors = ImGui::GetStyle().Colors;", 1, true) == nil then
			utilitools.prompts.error(mod, "You have to export your ImGui colors to the clipboard\n(which you didnt do apparently)")
		end
	end
end

imguiStyle.styleObj = imgui.GetStyle()

imguiStyle.styleVarNames = {}
for k, v in pairs(imgui) do
	if k:sub(1, #"ImGuiStyleVar_") == "ImGuiStyleVar_" then
		imguiStyle.styleVarNames[v] = k:sub(#"ImGuiStyleVar_" + 1)
	end
end

if mod.config.imguiStyles.default == nil then
	imguiStyle.saveStyle("default", true)
else
	imguiStyle.updateAllSavedStyles()
end

if mod.config.imguiStyles[mod.config.currentImguiStyle] == nil then
	mod.config.currentImguiStyle = "default"
end

imguiStyle.applyStyle(mod.config.currentImguiStyle)

return imguiStyle
