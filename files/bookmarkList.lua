return function(window_flag, inputFlag)
	helpers.SetNextWindowPos(750, 420, window_flag)
	helpers.SetNextWindowSize(200, 300, window_flag)
	if imgui.Begin("Bookmarks", nil, inputFlag) then
		cs:beattoolsCurrentEasing("bookmarks", "bookmark", "editorBeat")
		for i, v in ipairs(cs.beattoolsEasings.bookmarks) do
			if i ~= 1 then imgui.Separator() end
			imgui.ColorButton("", imgui.ImVec4_Float((v.r or 0) / 255, (v.g or 0) / 255, (v.b or 0) / 255, 1), 2^1, imgui.ImVec2_Float(20, 20))
			imgui.SameLine()
			local name = "Unnamed Bookmark"
			if v.name and v.name ~= "" then name = v.name end
			if imgui.Selectable_Bool(v.name .. " (Time: " .. (helpers.round(v.time * 1e3) / 1e3) .. ")", v.indexInLevel == cs.beattoolsCurrentEasings.editorBeat.bookmarks.indexInLevel) then
				cs.editorBeat = v.time
				cs.selectedEvent = cs.level.events[v.indexInLevel]
			end
			if v.description and v.description ~= "" then imgui.Indent() imgui.TextWrapped(v.description) imgui.Unindent() end
		end
		imgui.End()
	end
end