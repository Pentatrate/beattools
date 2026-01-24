return {
	testKey = function()
		utilitools.files.beattools.test()
	end,
	testKey2 = function()
		utilitools.files.beattools.test2()
	end,
	testKey3 = function()
		for k, v in pairs(log.display) do
			if v ~= 0 then
				modlog(mod, "\tLog Display: \"" .. k .. "\": " .. v)
			end
		end
	end
}