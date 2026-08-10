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
--[[ for index, change in ipairs(utilitools.files.beattools.compare.new1Stats.total) do
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