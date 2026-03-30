return {
	testKey = function()
		utilitools.files.beattools.test()
	end,
	testKey2 = function()
		utilitools.files.beattools.test2()
	end,
	testKey3 = function()
		-- modlog(mod, utilitools.files.beattools.biggestBeat.min, utilitools.files.beattools.biggestBeat.max)
		-- modlog(mod, tostring(love.filesystem.getRealDirectory("Workshop/")))
		-- error("Force crash hotkey pressed")
		-- modlog(mod, utilitools.git.buildUrl("https://api.github.com/repos/{user}/{repo}", { user = "Pentatrate", repo2 = "utilitools" }))
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