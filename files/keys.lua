return {
	testKey = function()
		utilitools.files.beattools.test()
	end,
	testKey2 = function()
		utilitools.files.beattools.test2()
	end,
	testKey3 = function()
		modlog(mod, "1 / 0 = " .. tostring(1 / 0))
		--[[ utilitools.try(mod, function ()
			for k, v in pairs(mods.utilitools) do
				modlog(mod, k .. " " .. type(v))
			end
			utilitools.config.save(mods.utilitools)
		end) ]]
	end
}