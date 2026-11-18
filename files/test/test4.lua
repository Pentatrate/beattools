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

	local pentasMods = {}
	local addedMods = {}
	for modId, data in pairs(utilitools.modLinks) do
		local function addMod(modId)
			if addedMods[modId] then return end
			table.insert(pentasMods, modId)
			addedMods[modId] = true
		end
		if data.organisation == "Pentatrate" or data.fork and data.fork.Pentatrate then
			addMod(modId)
			addMod(data.repository)
		end
	end
	for i = #warnList, 1, -1 do
		local remove = true
		for _, modId in ipairs(pentasMods) do
			if warnList[i]:find(modId .. "\\lovely", 1, true) then remove = false break end
		end
		if remove then table.remove(warnList, i) end
	end

	if #warnList == 0 then
		return nil
	end

	return table.concat(warnList, "\n")
end
local warnings = getLovelyInjectorWarnings()
if warnings then modlog(mod, "BEATTOOLS LOVELY WARNINGS:\n" .. warnings) end