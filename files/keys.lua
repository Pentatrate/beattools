return {
	testKey = function()
		utilitools.files.beattools.test()
	end,
	testKey2 = function()
		utilitools.files.beattools.test2()
	end,
	testKey3 = function()
		utilitools.try(mod, function ()
			for k, v in pairs(mods.DetailedAcc) do
				modlog(mod, k .. " " .. type(v))
			end
		end)
	end
}