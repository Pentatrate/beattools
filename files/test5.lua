-- print workshop folder ========== ========== ========== ========== ==========
-- modlog(mod, tostring(love.filesystem.getRealDirectory("Workshop/")))

-- force crash ========== ========== ========== ========== ==========
-- error("Force crash hotkey pressed")

-- internet stuff ========== ========== ========== ========== ==========
--[[ for url, data in pairs(utilitools.internet.cache) do
	modlog(mod, url, data.code)
end ]]

-- local e = utilitools.internet.cache["https://api.github.com/repos/Pentatrate/test-dummy/releases"].body
-- modlog(mod, e, type(e))
-- modlog(mod, utilitools.table.tableAmount(utilitools.internet.cache)))

-- velocity ========== ========== ========== ========== ==========
-- prepend folder to deco sprite
--[[ for _, event in ipairs(cs.level.events) do
	if event.type == "deco" and event.sprite ~= nil then
		event.sprite = "r22/" .. event.sprite
	end
end ]]

-- print stacked notes
--[[ for time, angles in pairs(utilitools.files.beattools.eventStacking.gameplayStack) do
	for angle, _ in pairs(angles) do
		modlog(mod, time, angle)
	end
end ]]

-- change editor outline color
--[[ for _, event in ipairs(cs.level.events) do
	if event.editorOutline and event.editorOutline.r == 255 and event.editorOutline.g == 0 and event.editorOutline.b == 255 then
		event.editorOutline = { r = 255, g = 255,   b = 0 }
	end
end ]]

-- print changes to gameplay
--[[ modlog(mod, "print changes to gameplay")
for index, change in ipairs(utilitools.files.beattools.compare.new1Stats.total) do
	local temp = change.event2 or change.event
	if utilitools.files.beattools.eventStacking.getType(temp) == "func" then
		modlog(mod, index, change.text, temp.time, change.withinTime, temp.angle, utilitools.string.concat(utilitools.string.concat(temp.type, temp.var), temp.id), change.reason and table.concat(change.reason, ", ") or nil)
	end
end ]]

-- print changes
--[[ for index, change in ipairs(utilitools.files.beattools.compare.new1Stats.total) do
	if not change.resolved then
		local temp = change.event2 or change.event
		-- if utilitools.files.beattools.eventStacking.getType(temp) == "func" then
		modlog(mod, index, change.text, temp.time, change.withinTime, temp.angle, utilitools.string.concat(utilitools.string.concat(temp.type, temp.var), temp.id), change.reason and table.concat(change.reason, ", ") or nil)
		modlog(mod, temp)
		-- end
		break
	end
end ]]

-- compare the first two events
--[[ local check, reason = utilitools.files.beattools.undo.areSimilar(cs.level.events[1], cs.level.events[2], nil, 1)
if not check then
	modlog(mod, reason)
end ]]

local function levelsPaletteFromFolder(palette, folder, total)
	local directoryItems = love.filesystem.getDirectoryItems(folder)
	for _, item in ipairs(directoryItems) do
		local itemPath = folder .. "/" .. item
		if love.filesystem.getInfo(itemPath).type == "directory" then
			local manifest = love.filesystem.getInfo(itemPath .. "/manifest.json")
			if manifest or love.filesystem.getInfo(itemPath .. "/level.json") then
				local prefix = "Custom Levels/"
				if itemPath:sub(1, #prefix) == prefix then
					itemPath = itemPath:sub(#prefix + 1)
				end
				local level
				if utilitools.try(mod, function()
					level = LevelManager:loadMetadata("Custom Levels" .. itemPath .. "/")
				end) then
					local saveName, variant = "", nil
					if manifest then -- load default variant
						local variantname = level.defaultVariant or ""
						for _, v in ipairs(level.variants) do
							if v.name == variantname then variant = v break end
						end
					end
					if not utilitools.try(mod, function()
						saveName = LevelManager:getLevelSaveName(level, variant)
					end, true) then
						modlog(mod, "failed", level)
						return
					end
					local saveName2 = (saveName):gsub("/", "."):gsub("\\", "."):gsub(":", "."):gsub("%*", "."):gsub("%?", "."):gsub("\"", "."):gsub("<", "."):gsub(">", "."):gsub("|", "."):gsub("[^%w%s%p]", ".")
					local newLevel = {
						songName = saveName,
						saveName = saveName2,
						newPath = prefix .. "{All}/" .. saveName2,
						orig = prefix .. "{All}/" .. saveName,
						path = itemPath,
						realPath = prefix:sub(1, -2) .. itemPath
					}
					if false and saveName ~= saveName2 then modlog(mod, saveName, saveName2) end
					for _, otherLevel in ipairs(total) do
						if otherLevel.newPath == newLevel.newPath then
							otherLevel.duplicate = true
							newLevel.duplicate = true
							break
						end
					end
					local duplicate = true
					while duplicate do
						duplicate = false
						for _, otherLevel in ipairs(palette) do
							if otherLevel.songName == newLevel.songName then
								newLevel.songName = newLevel.songName .. "##"
								duplicate = true
								break
							end
						end
					end
					table.insert(palette, newLevel)
					table.insert(total, newLevel)
				end
			else
				palette[item] = {}
				levelsPaletteFromFolder(palette[item], itemPath, total)
			end
		end
	end
	_G.globalLevelsPalette = palette
end

if cs and cs.name == "Menu" then
	local total = {}
	levelsPaletteFromFolder({ "" }, "Custom Levels/", total)
	for _, level in ipairs(total or {}) do
		if not level.duplicate then
			if level.realPath ~= level.newPath then
				-- modlog(mod, level.newPath, level.realPath)
				-- modlog(mod, level.realPath:sub(1, -1 - #level.realPath:match("([^/]+)$")) .. level.saveName, level.newPath .. "/")
				-- utils.moveDirectory(level.realPath, level.newPath)
				utilitools.folderManager.copy(level.newPath, level.realPath)
				utilitools.folderManager.delete(level.realPath)
				local redirectPath = level.realPath:sub(1, -1 - #level.realPath:match("([^/]+)$")) .. level.saveName .. ".redirect"
				local success, e = love.filesystem.write(redirectPath, level.newPath .. "/")
				if not success then forceprint(e) end
			end
		end
	end
else
end
