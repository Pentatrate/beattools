return {
	testKey = function()
		utilitools.files.beattools.test()
	end,
	testKey2 = function()
		utilitools.files.beattools.test2()
	end,
	testKey3 = function()
		utilitools.files.beattools.test3()
	end,
	testKey4 = function() utilitools.try(mod, function()
		forceprint(#utilitools.files.beattools.undo.changes .. " " .. utilitools.files.beattools.undo.index)
		utilitools.files.beattools.fakeRepeat.updateList()
	end) end
}