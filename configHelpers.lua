if beattoolsOptions == nil then beattoolsOptions = dofile("Mods/beattools/configOptions.lua") end
local returnValue = {}
returnValue.Tooltip = function (key, overwrite)
	if mod.config.tooltipsInMenu ~= "none" then
		local tooltip = overwrite or (key and beattoolsOptions[key] and beattoolsOptions[key].tooltips)
		if tooltip then
			if type(overwrite) ~= "string" then
				if mod.config.tooltipsInMenu == "long" and not tooltip[mod.config.tooltipsInMenu] then
					tooltip = tooltip.short
				else
					tooltip = tooltip[mod.config.tooltipsInMenu]
				end
			end
			if tooltip and imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.PushTextWrapPos(imgui.GetFontSize() * 35)
				imgui.TextUnformatted(tooltip)
				imgui.PopTextWrapPos()
				imgui.EndTooltip()
			end
		end
	end
end
returnValue.SetWidth = function (key)
	imgui.SetNextItemWidth(-imgui.GetFontSize() * 7 / 13 * string.len(beattoolsOptions[key].name))
end
returnValue.InputBool = function (key)
	if mod.config[key] == nil then mod.config[key] = beattoolsOptions[key].default end
	local valptr = ffi.new("bool[1]", { mod.config[key] })
	imgui.Checkbox(beattoolsOptions[key].name .. "##BeattoolsConfig", valptr)
	returnValue.Tooltip(key)
	mod.config[key] = valptr[0]
end
returnValue.InputInt = function (key, step, step_fast)
	if mod.config[key] == nil then mod.config[key] = beattoolsOptions[key].default end
	local valptr = ffi.new("int[1]", { mod.config[key] })
	returnValue.SetWidth(key)
	imgui.InputInt(beattoolsOptions[key].name .. "##BeattoolsConfig", valptr, step or 0, step_fast, beattoolsOptions[key].flags or 2^12)
	returnValue.Tooltip(key)
	mod.config[key] = valptr[0]
end
returnValue.InputFloat = function (key, step, step_fast, format)
	if mod.config[key] == nil then mod.config[key] = beattoolsOptions[key].default end
	local valptr = ffi.new("float[1]", { mod.config[key] })
	returnValue.SetWidth(key)
	imgui.InputFloat(beattoolsOptions[key].name .. "##BeattoolsConfig", valptr, step or 0, step_fast, format, beattoolsOptions[key].flags or 2^12)
	returnValue.Tooltip(key)
	mod.config[key] = valptr[0]
end
returnValue.InputText = function (key, size)
	if mod.config[key] == nil then mod.config[key] = beattoolsOptions[key].default end
	size = size or 256
	local buffer = ffi.new("char[?]", size)
	ffi.copy(buffer, mod.config[key], #mod.config[key])
	returnValue.SetWidth(key)
	imgui.InputText(beattoolsOptions[key].name .. "##BeattoolsConfig", buffer, size, beattoolsOptions[key].flags or 2^12)
	mod.config[key] = ffi.string(buffer)
end
returnValue.InputCombo = function (key)
	if mod.config[key] == nil then mod.config[key] = beattoolsOptions[key].default end
	local isOpen = imgui.BeginCombo(beattoolsOptions[key].name .. "##BeattoolsConfig", mod.config[key], beattoolsOptions[key].flags or 2^4 + 2^5 + 2^7)
	returnValue.Tooltip(key)
	if isOpen then
		for i, v in ipairs(beattoolsOptions[key].values) do
			local isSelected = imgui.Selectable_Bool(v .. "##BeattoolsConfig", v == mod.config[key])
			returnValue.Tooltip(nil, beattoolsOptions[key].valueTooltips[i])
			if isSelected then
				mod.config[key] = v
			end
		end
		imgui.EndCombo()
	end
end
returnValue.InputColor = function (key)
	if mod.config[key] == nil then mod.config[key] = beattoolsOptions[key].default end
	local valptr = ffi.new("float[" .. (mod.config[key].a and 4 or 3) .. "]", mod.config[key].a and { mod.config[key].r, mod.config[key].g, mod.config[key].b, mod.config[key].a } or { mod.config[key].r, mod.config[key].g, mod.config[key].b })
	imgui["ColorEdit" .. (mod.config[key].a and 4 or 3)](beattoolsOptions[key].name, valptr, beattoolsOptions[key].flags or 2^5)
	returnValue.Tooltip(key)
	mod.config[key].r, mod.config[key].g, mod.config[key].b, mod.config[key].a = valptr[0], valptr[1], valptr[2], mod.config[key].a and valptr[3] or nil
end
returnValue.InputList = function (key, size)
	if mod.config[key] == nil then mod.config[key] = beattoolsOptions[key].default end
	local formatted = table.concat(mod.config[key], ", ")
	size = size or 256
	local buffer = ffi.new("char[?]", size)
	ffi.copy(buffer, formatted, #formatted)
	returnValue.SetWidth(key)
	imgui.InputText(beattoolsOptions[key].name .. "##BeattoolsConfig", buffer, size, beattoolsOptions[key].flags or 2^12)
	returnValue.Tooltip(key)
	local value = ffi.string(buffer)
	if formatted ~= value and value ~= mod.config[key .. "2"] then
		mod.config[key] = {}
		mod.config[key .. "2"] = value
		for v in string.gmatch(value, "(%d+)") do
			local v2 = tonumber(v)
			if v2 ~= nil and v2 ~= 0 then
				table.insert(mod.config[key], v2)
			end
		end
	end
end
returnValue.ConditionalTreeNode = function (label, var, target, same, func)
	local condition = (mod.config[var] == target) == same
	if not condition then
		imgui.BeginDisabled()
		imgui.SetNextItemOpen(false, 2^0)
	elseif mod.config.foldAll then
		imgui.SetNextItemOpen(not not (flags and flags % 2 ^ (5 + 1) >= 2^5), 2^0)
	end
	if imgui.TreeNode_Str(label .. "##BeattoolsConfig") then
		func()
		imgui.TreePop()
	end
	if not condition then
		imgui.EndDisabled()
		if imgui.IsItemHovered(2^10) then
			imgui.BeginTooltip()
			imgui.PushTextWrapPos(imgui.GetFontSize() * 35)
			imgui.TextUnformatted(beattoolsOptions[var].name .. " needs to " .. (same and "" or "not ") .. "be set to " .. tostring(target))
			imgui.PopTextWrapPos()
			imgui.EndTooltip()
		end
	end
end
returnValue.TreeNode = function (label, flags)
	if mod.config.foldAll then imgui.SetNextItemOpen(not not (flags and flags % 2^(5 + 1) >= 2^5), 2^0) end
	if flags then return imgui.TreeNodeEx_Str(label .. "##BeattoolsConfig", flags) end
	return imgui.TreeNode_Str(label .. "##BeattoolsConfig")
end
return returnValue