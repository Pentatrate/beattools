return {
	testKey = function()
		utilitools.files.beattools.test()
	end,
	testKey2 = function()
		utilitools.files.beattools.test2()
	end,
	testKey3 = function()
		-- modlog(mod, tostring(love.filesystem.getRealDirectory("Workshop/")))

		-- error("Force crash hotkey pressed")

		--[[ for url, data in pairs(utilitools.internet.cache) do
			modlog(mod, url, data.code)
		end ]]

		-- local e = utilitools.internet.cache["https://api.github.com/repos/Pentatrate/test-dummy/releases"].body
		-- modlog(mod, e, type(e))
		-- modlog(mod, utilitools.table.tableAmount(utilitools.internet.cache)))

		-- local tooly = utilitools.files.beattools.tooly
		-- beattools.test = tooly.calculatePath()

		-- utilitools.files.beattools.tag.getList()

		--[[ for _, event in ipairs(cs.level.events) do
			if event.type == "deco" and event.sprite ~= nil then
				event.sprite = "r22/" .. event.sprite
			end
		end ]]

		--[[ for time, angles in pairs(utilitools.files.beattools.eventStacking.gameplayStack) do
			for angle, _ in pairs(angles) do
				modlog(mod, time, angle)
			end
		end ]]

		--[[ for _, event in ipairs(cs.level.events) do
			if event.editorOutline and event.editorOutline.r == 255 and event.editorOutline.g == 0 and event.editorOutline.b == 255 then
				event.editorOutline = { r = 255, g = 255,   b = 0 }
			end
		end ]]

		--[[ for index, change in ipairs(utilitools.files.beattools.compare.new1Stats.total) do
			local temp = change.event2 or change.event
			if utilitools.files.beattools.eventStacking.getType(temp) == "func" then
				modlog(mod, index, change.text, temp.time, change.withinTime, temp.angle, utilitools.string.concat(utilitools.string.concat(temp.type, temp.var), temp.id), change.reason and table.concat(change.reason, ", ") or nil)
			end
		end ]]
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
		-- Penta: copied from BBP and modified
		local function getLovelyInjectorWarnings()
			local lovelyLogsPath = "Mods/lovely/log"

			-- get the newest log file
			local logPath = nil
			local newestTime = 0
			for _, item in ipairs(love.filesystem.getDirectoryItems(lovelyLogsPath)) do
				if item:match("%.log$") then
					local path = lovelyLogsPath .. "/" .. item
					local info = love.filesystem.getInfo(path)

					if info and info.modtime > newestTime then
						newestTime = info.modtime
						logPath = path
					end
				end
			end

			local warnList = {}

			if logPath then
				local content = love.filesystem.read(logPath)
				for line in content:gmatch("[^\r\n]+") do
					-- lovely warnings sometimes accidentally break up into two lines and this combines them again
					local warning, count = line:gsub("^WARN %- %[♥%] ' on target '", "", 1)
					if count > 0 and #warnList > 0 then
						warnList[#warnList] = warnList[#warnList].."' on target '"..warning
					else
						-- regular warnings
						warning, count = line:gsub("^WARN %- %[♥%]", "", 1)
						if count > 0 then
							table.insert(warnList, warning)
						end
					end
				end
			else
				return "log file not found"
			end

			for i = #warnList, 1, -1 do
				if not (warnList[i]:find("beattools\\lovely", 1, true) or warnList[i]:find("utilitools\\lovely", 1, true)) then
					table.remove(warnList, i)
				end
			end

			if #warnList == 0 then
				return nil
			end

			return table.concat(warnList, "\n")
		end
		local warnings = getLovelyInjectorWarnings()
		if warnings then modlog(mod, "BEATTOOLS LOVELY WARNINGS:\n" .. warnings) end
	end,
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