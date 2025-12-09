utilitools.try(mod, function()

	-- utilitools.modUpdater.downloadMod(mods.utilitools, nil, true)
	-- utilitools.modUpdater.downloadMod(mods.themeable, nil, true)
	-- forceprint(utilitools.request("https://github.com/ImPurplez/Themeable/releases/latest")) -- webpage

	-- forceprint(utilitools.modUpdater.checkModVersion(mods.utilitools))

	-- utilitools.modUpdater.updateMods()
	forceprint(love.filesystem.getRealDirectory("Workshop/"))

end)