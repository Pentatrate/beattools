return {
	testKey = function()
		utilitools.files.beattools.test()
	end,
	testKey2 = function()
		utilitools.files.beattools.test2()
	end,
	testKey3 = function()
		-- modlog(mod, tostring(love.filesystem.getRealDirectory("Workshop/")))
		-- error("Force crash hotkey pressed")
		-- modlog(mod, utilitools.keybinds.generateText("keyboardEditor", "play", false))
		--[[ for url, data in pairs(utilitools.internet.cache) do
			modlog(mod, url, data.code)
		end ]]
		-- local e = utilitools.internet.cache["https://api.github.com/repos/Pentatrate/test-dummy/releases"].body
		-- modlog(mod, e, type(e))
		-- modlog(mod, utilitools.table.tableAmount(utilitools.internet.cache))
		-- modlog(mod, 30 + (mods.beattools.config.gearshiftPopulation - 1) * 2)
		local imguiStyle = imgui.GetStyle()
		local separatorHeight = imguiStyle.ItemSpacing.y
		local imguiInputHeight = imguiStyle.ItemSpacing.y + imgui.GetFontSize() + imguiStyle.FramePadding.y * 2
		local separatorAmount = 2
		local imguiInputAmount = 3
		if mods["devonly-events"] and mods["devonly-events"].enabled then
			imguiInputAmount = imguiInputAmount + 1
		end
		modlog(mod, imguiInputHeight * imguiInputAmount + separatorHeight * separatorAmount)
	end,
	toggleMenuMusic = function()
		if cs.menuMusicManager then
			savedata.options.audio.playMenuMusic = not savedata.options.audio.playMenuMusic
			if savedata.options.audio.playMenuMusic then
				cs.menuMusicManager:play()
			else
				cs.menuMusicManager:stop()
			end
		end
	end
}