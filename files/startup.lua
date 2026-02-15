_G.beattools = beattools or {}
beattools.moremetamethods = beattools.moremetamethods or {}
beattools.noFakeRepeat = {
	ease = true,
	tag = true,
	setJoystickColor = true,
	["c-me_b-me_iconsEase"] = true,
	shinamon_offset = true,
	shinamon_offsetAll = true,
	shinamon_offsetEvenOdd = true
}
beattools.easeList = {
	unsorted = {
		all = dpf.loadJson(utilitools.folderManager.modPath(mods.beattools) .. "/easeList/all.json"),
		uselessEases = dpf.loadJson(utilitools.folderManager.modPath(mods.beattools) .. "/easeList/useless.json"),
		troll = dpf.loadJson(utilitools.folderManager.modPath(mods.beattools) .. "/easeList/troll.json")
	},
	sorted = {
	},
	selected = {},
	eases = {},
	bools = {}
}

for k, v in pairs(beattools.easeList.unsorted.all) do
	table.insert(beattools.easeList.sorted, k)
	if type(v) == "boolean" then table.insert(beattools.easeList.bools, k) else table.insert(beattools.easeList.eases, k) end
end
table.sort(beattools.easeList.sorted, function(a, b)
	if type(beattools.easeList.unsorted.all[a]) ~= type(beattools.easeList.unsorted.all[b]) then
		if type(beattools.easeList.unsorted.all[a]) == "number" then return true end
		if type(beattools.easeList.unsorted.all[b]) == "number" then return false end
		return type(beattools.easeList.unsorted.all[a]) == "boolean"
	end
	if a:sub(1, #"vfx.vars") == "vfx.vars" and b:sub(1, #"vfx.vars") == "vfx.vars" then
		return tonumber(a:sub(#"vfx.vars" + 1)) < tonumber(b:sub(#"vfx.vars" + 1))
	end
	return a < b
end)

utilitools.files.beattools.undo.firstTime()