return function(window_flag, inputFlag)
	if mod.config.bookmarkList then
		helpers.SetNextWindowPos(750, 420, window_flag)
		helpers.SetNextWindowSize(200, 300, window_flag)
		mod.config.bookmarkList = imgui.Begin("Bookmarks", true, (inputFlag or 0) + (mod.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mod.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0))
		if utilitools.files.beattools.easing.list.bookmark and utilitools.files.beattools.easing.list.bookmark["_"] and utilitools.files.beattools.easing.list.bookmark["_"]["_"] and #utilitools.files.beattools.easing.list.bookmark["_"]["_"] > 0 then
			local _, count = utilitools.files.beattools.easing.getEase("bookmark", nil, cs.editorBeat, nil, nil)
			for i, bookmark in ipairs(utilitools.files.beattools.easing.list.bookmark["_"]["_"]) do
				if i ~= 1 then imgui.Separator() end
				imgui.ColorButton("", imgui.ImVec4_Float(love.math.colorFromBytes(bookmark.event.r or 0, bookmark.event.g or 0, bookmark.event.b or 0, 255)), 2^1, imgui.ImVec2_Float(20, 20))
				imgui.SameLine()
				local name = "Unnamed Bookmark"
				if bookmark.event.name and bookmark.event.name ~= "" then name = bookmark.event.name end
				if imgui.Selectable_Bool(name .. " (Time: " .. (helpers.round(bookmark.event.time * 1e3) / 1e3) .. ")", count.index == i) then
					cs.editorBeat = bookmark.event.time
					cs:noSelection()
					cs.selectedEvent = cs.level.events[utilitools.files.beattools.easing.getIndex(bookmark.event)]
				end
				if bookmark.event.description and bookmark.event.description ~= "" then imgui.Indent() imgui.TextWrapped(bookmark.event.description) imgui.Unindent() end
			end
		else
			imgui.Text("No Bookmarks")
		end
		imgui.End()
	end
end