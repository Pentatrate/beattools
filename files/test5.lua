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
--[[ local check, reason = utilitools.files.beattools.undo.areSimilar(cs.level.events[1], cs.level.events[2], "readableTable")
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
						data = level,
						manifest = manifest,
						variant = variant,
						songName = level.metadata.songName,
						name = level.metadata.songName,
						saveName = saveName2,
						newPath = prefix .. "{All}/" .. saveName2,
						newDir = prefix .. "{All}/",
						root = prefix,
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
end

if cs and cs.name == "Menu" then
	local total = {}
	levelsPaletteFromFolder({ "" }, "Custom Levels/", total)
	cs.playedLevelsJson = LevelManager:loadPlayedLevels()
	utilitools.folderManager.delete("Custom Levels/{Ranks}")
	utilitools.folderManager.delete("Custom Levels/{ABC}")
	utilitools.folderManager.delete("Custom Levels/{Diff}")
	utilitools.folderManager.delete("Custom Levels/{Variants}")
	utilitools.folderManager.delete("Custom Levels/{Song Name}")
	for _, level in ipairs(total or {}) do
		if not level.duplicate then
			if level.realPath ~= level.newPath then
				modlog(mod, "Moving", level.name)
				-- modlog(mod, level.newPath, level.realPath)
				-- modlog(mod, level.realPath:sub(1, -1 - #level.realPath:match("([^/]+)$")) .. level.saveName, level.newPath .. "/")
				-- utils.moveDirectory(level.realPath, level.newPath)
				utilitools.folderManager.copy(level.newPath, level.realPath)
				utilitools.folderManager.delete(level.realPath)
				love.filesystem.createDirectory(level.newDir)
				local redirectPath = level.realPath:sub(1, -1 - #level.realPath:match("([^/]+)$")) .. level.saveName .. ".redirect"
				local success, e = love.filesystem.write(redirectPath, level.newPath .. "/")
				if not success then forceprint(e) end
			end
			local function doStuffCrankless(variant)
				do -- rank
					local saveName = LevelManager:getLevelSaveName(level.data, variant)
					local playedData = cs.playedLevelsJson[saveName]
					local rank, add = nil, "none"
					if playedData then
						rank, add = GameManager:gradeCalc(playedData.pctGrade)
						if playedData.gotShinyPRank and rank == "perfect" then
							add = "plus"
						end
						if playedData.misses == 0 and rank ~= "perfect" then
							rank, add = "FC", "none"
						end
						local almost = mods["happy-almost-rank"] and mods["happy-almost-rank"].enabled and ({ owo = ";3", happy = ";)" })[mods["happy-almost-rank"].config.face] or ";("
						if playedData.misses + playedData.barelies == 1 then
							rank, add = almost, "none"
							if playedData.misses == 0 and mods.expanded_almost_ranks and mods.expanded_almost_ranks.enabled then
								add = "plus"
							end
						end
					end
					rank = ({ what = "WHAT", perfect = "P" })[rank or "Unplayed"] or rank
					add = ({ none = "", plus = "+", minus = "-" })[add] or "."
					rank = rank and rank:upper() .. add or "Unplayed"

					local path = "Custom Levels/{Ranks}/{" .. rank .. "}/"

					love.filesystem.createDirectory(path)

					local success, e = love.filesystem.write(path .. level.saveName .. ".redirect", level.newPath .. "/")
					if not success then forceprint(e) end
				end

				do -- difficulty
					local diff = variant and variant.difficulty or level.data.metadata.difficulty or "Invalid"

					diff = ({ [-1] = "Unknown", [-2] = "PH", [-3] = "" })[diff] or diff

					local path = "Custom Levels/{Diff}/{" .. diff .. "}/"

					love.filesystem.createDirectory(path)

					local success, e = love.filesystem.write(path .. level.saveName .. ".redirect", level.newPath .. "/")
					if not success then forceprint(e) end
				end

				do -- variant
					local hasVariants = variant ~= nil and (#level.data.variants) or "None"

					local path = "Custom Levels/{Variants}/{" .. hasVariants .. "}/"

					love.filesystem.createDirectory(path)

					local success, e = love.filesystem.write(path .. level.saveName .. ".redirect", level.newPath .. "/")
					if not success then forceprint(e) end
				end
			end
			if level.manifest and level.data.variants then
				for _, variant in ipairs(level.data.variants) do
					doStuffCrankless(variant)
				end
			else
				doStuffCrankless()
			end
			do -- first letter
				local firstLetter = rtf:sanitize_text(level.saveName):sub(1, 1):upper()
				local path = "Custom Levels/{ABC}/{" .. firstLetter .. "}/"

				love.filesystem.createDirectory(path)

				local success, e = love.filesystem.write(path .. level.saveName .. ".redirect", level.newPath .. "/")
				if not success then forceprint(e) end
			end
		else
			modlog(mod, "Duplicate", level.name, level.realPath)
		end
	end
else
end
