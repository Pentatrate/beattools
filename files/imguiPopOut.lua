local imguiPopOut = {
	lastLabel = nil,
	lastUsed = 0,
	lastHovered = 0,
	x = nil,
	y = nil,
	offset = 0,
	offset2 = 0,
	inUse = false,

	hoverTime = 0.25,
	additionalOffset = 0.01,
	itemPadding = 2
}

function imguiPopOut.imgui(label, value, multiline)
	if imguiPopOut.inUse or not mod.config.textPopOut then return value end

	local imguiHelpers = utilitools.imguiHelpers
	local necessaryWidth = imgui.GetFontSize() * 7 / 13 * (imguiHelpers.stringLength(tostring(value)) + imguiPopOut.itemPadding) + imgui.GetStyle().FramePadding.x * 2
	local usedWidth = imgui.CalcItemWidth()

	local itemHovered = imgui.IsItemHovered() or imgui.IsItemActive()
	local invalidSingleLine = not multiline and value:find("\n", 1, true)
	local necessary = invalidSingleLine or necessaryWidth - (imgui.GetFontSize() * 7 / 13 * imguiPopOut.itemPadding) > usedWidth

	if (itemHovered and necessary) or (love.timer.getTime() - imguiPopOut.lastHovered < imguiPopOut.hoverTime and label == imguiPopOut.lastLabel) then
		if love.timer.getTime() - imguiPopOut.lastHovered >= imguiPopOut.hoverTime then
			if mods["imgui-scale-fix"].enabled then
				imguiPopOut.x = imgui.GetIO().MousePos.x
				imguiPopOut.y = imgui.GetIO().MousePos.y
			else
				imguiPopOut.x = mouse.rx * imgui.canvasScale
				imguiPopOut.y = mouse.ry * imgui.canvasScale
			end

			imguiPopOut.offset = 0 - imguiPopOut.additionalOffset
			imguiPopOut.offset2 = -1
			if mouse.rx > 400 then
				imguiPopOut.offset = 1 + imguiPopOut.additionalOffset
				imguiPopOut.offset2 = 1
			end
			imgui.SetNextWindowPos(imgui.ImVec2_Float(imguiPopOut.x, imguiPopOut.y), imgui.ImGuiCond_Appearing, imgui.ImVec2_Float(imguiPopOut.offset, 0.5))
		end

		imgui.Begin("##beattoolsTooltip", nil, imgui.ImGuiWindowFlags_NoTitleBar + imgui.ImGuiWindowFlags_NoResize + imgui.ImGuiWindowFlags_NoCollapse + imgui.ImGuiWindowFlags_AlwaysAutoResize + imgui.ImGuiWindowFlags_NoFocusOnAppearing + imgui.ImGuiWindowFlags_NoDocking) -- intentionally left the tooltip flag as false, due to tooltips following your mouse

		imguiPopOut.inUse = true

		imgui.Text("Edit Text")
		value = imguiHelpers.inputMultiline(label .. "##beattoolsEditText", tostring(value), tostring(value), nil, 0, nil, necessaryWidth)
		-- for some reason these flags dont work, some other flags do though
		-- imgui.ImGuiInputTextFlags_EnterReturnsTrue + imgui.ImGuiInputTextFlags_AutoSelectAll

		if not multiline and not invalidSingleLine and value:find("\n", 1, true) then
			value = value:gsub("\n", "")
		end

		imguiPopOut.inUse = false

		if itemHovered or imgui.IsWindowHovered() or imgui.IsItemHovered() or imgui.IsItemActive() then
			imguiPopOut.lastHovered = love.timer.getTime()
			imguiPopOut.lastLabel = label
		end

		imgui.End()
	end
	return value
end

return imguiPopOut