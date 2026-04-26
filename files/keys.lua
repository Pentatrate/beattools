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

		--[[ for url, data in pairs(utilitools.internet.cache) do
			modlog(mod, url, data.code)
		end ]]

		-- local e = utilitools.internet.cache["https://api.github.com/repos/Pentatrate/test-dummy/releases"].body
		-- modlog(mod, e, type(e))
		-- modlog(mod, utilitools.table.tableAmount(utilitools.internet.cache)))
		-- modlog(mod, "e")
		-- modlog(mod, savedata.utilitools.bindings)

		local tooly = utilitools.files.beattools.tooly
		beattools.test = tooly.getRangesBetween()
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