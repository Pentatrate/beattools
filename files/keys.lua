return {
	testKey = function() utilitools.files.beattools.test() end,
	testKey2 = function() utilitools.files.beattools.test2() end,
	testKey3 = function() utilitools.files.beattools.test3() end,
	testKey4 = function() utilitools.files.beattools.test4() end,
	testKey5 = function() utilitools.files.beattools.test5() end,
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