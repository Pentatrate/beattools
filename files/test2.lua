utilitools.try(mod, function()
	local data = {}
	local pathes = {}
	local function recursion(t, prev, recursions)
		prev = prev or ""
		recursions = recursions and recursions + 1 or 0
		if recursions > 20 then modlog(mod, "too much recursions!!!") forceprint(prev) return end
		for k, v in pairs(t) do
			if type(k) == "string" and ({ table = true, boolean = true, number = true, ["nil"] = true })[type(v)] and k ~= "__index" and k ~= "class" and not ({ playedLevelsJson = true, beattools = true, utilitools = true, replay = true, beattoolsPrevAcc = true, CHEATlagBack = true, lastReplayState = true })[k] then
				local path = (prev ~= "" and prev .. "." or "") .. k
				if type(v) == "table" then
					recursion(v, path, recursions)
				else
					table.insert(pathes, path)
					data[path] = v
				end
			end
		end
	end
	utilitools.try(mod, function() recursion(cs) end)
	table.sort(pathes, function(a, b)
		if a:sub(1, #"vfx.vars") == "vfx.vars" and b:sub(1, #"vfx.vars") == "vfx.vars" then
			return tonumber(a:sub(#"vfx.vars" + 1)) < tonumber(b:sub(#"vfx.vars" + 1))
		end
		return a < b
	end)
	local jsonText = "{\n"
	for i, path in ipairs(pathes) do
		local v = data[path]
		if beattools.easeList.unsorted.all[path] ~= v then
			jsonText = jsonText .. "\t\"" .. path .. "\": " .. ({ ["boolean"] = tostring(v), string = '"' .. tostring(v) .. '"', number = v, ["nil"] = "null" })[type(v)] .. ",\n"
			if beattools.easeList.unsorted.all[path] ~= nil then
				jsonText = jsonText .. "\t\"" .. path .. (type(v) ~= type(beattools.easeList.unsorted.all[path]) and " ||||| " .. type(v) .. " was originally " .. type(beattools.easeList.unsorted.all[path]) or "") .. " ||||| original value" .. "\": " .. ({ ["boolean"] = tostring(beattools.easeList.unsorted.all[path]), string = '"' .. tostring(beattools.easeList.unsorted.all[path]) .. '"', number = beattools.easeList.unsorted.all[path], ["nil"] = "null" })[type(beattools.easeList.unsorted.all[path])] .. ",\n"
			end
		end
	end
	jsonText = jsonText:sub(1, -3) .. "\n}"
	forceprint(jsonText)

	if cLevel == "Custom Levels/###test/" then
		forceprint("SAVINGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGg")
		if not love.filesystem.inSaveData(cLevel) then love.filesystem.forceSaveInSource(true) end
		local success, e = love.filesystem.write(cLevel .. "test2.json", jsonText)
		if not success then forceprint(e) end
		love.filesystem.forceSaveInSource(false)
	end
end)