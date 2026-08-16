local undo

local beattoolsKeysWhiteList = {   -- Add your parameters here if you want changes to this parameter to get saved and be undo-/redoable
	type = true,
	time = true,
	angle = true,
	order = true,
	angle2 = true,
	duration = true,
	segments = true,
	holdEase = true,
	endAngle = true,
	spinEase = true,
	speedMult = true,
	tap = true,
	startTap = true,
	endTap = true,
	tickRate = true,
	name = true,
	r = true,
	g = true,
	b = true,
	description = true,
	tag = true,
	angleOffset = true,
	enabled = true,
	paddle = true,
	newWidth = true,
	newAngle = true,
	ease = true,
	file = true,
	bpm = true,
	volume = true,
	offset = true,
	id = true,
	sprite = true,
	parentid = true,
	rotationinfluence = true,
	orbit = true,
	x = true,
	y = true,
	sx = true,
	sy = true,
	ox = true,
	oy = true,
	kx = true,
	ky = true,
	drawLayer = true,
	drawOrder = true,
	recolor = true,
	outline = true,
	hide = true,
	effectCanvas = true,
	effectCanvasRaw = true,
	var = true,
	start = true,
	value = true,
	repeats = true,
	repeatDelay = true,
	spriteName = true,
	enable = true,
	chance = true,
	color = true,
	sound = true,
	pitch = true,
	voidColor = true,
	block = true,
	miss = true,
	mine = true,
	mineHold = true,
	side = true,
	a = true, -- depreciated or dev only event parameters in the vanilla game
	paddles = true,
	objectName = true,
	variableName = true,
	reps = true,
	delay = true,
	intensity = true,
	traceEase = true,
	doDithering = true,
	beattoolsLayer = true        -- Mod: "Beattools" by Pentatrate
}
local beattoolsKeysBlacklist = { -- Add your parameters here if you dont want changes to this parameter to get saved and be undo-/redoable (especially when the parameter gets auto updated)
	-- Mod: "Beattools" by Pentatrate
}

undo = {
	changes = {},
	index = 0,
	lastCheck = 0,
	events = {},
	meta = function (event)
		local hidden = helpers.copy(event)
		for k, v in pairs(event) do
			event[k] = nil
		end
		event.beattoolsArbitraryKeyThatMustNeverBeNil = "arbitraryValueThatMustNeverBeNil"
		-- we put this here so json.lua converts it to an object, not an array and dpf.lua saves it correctly
		setmetatable(event, {
			__index = function (t, k) return hidden[k] end,
			__newindex = function (t, k, v) utilitools.files.beattools.undo.change(t, k, v, hidden) end,
			__metatable = { beattoolsUndoInject = true, hidden = hidden }
		})
	end,
	undoing = false,
	fakeRepeating = false,
	linkFiles = {
		eventVisuals = false,
		eventStacking = false,
		easing = false,
		biggestBeat = false,
		eventGroups = false,
		tag = false,
		fakeRepeat2 = true,
		moreSuggestions = false
	}
}

function undo.dontTrack(func)
	if type(func) ~= "function" then return end
	undo.undoing = true
	undo.fakeRepeating = true
	func()
	undo.undoing = false
	undo.fakeRepeating = false
end

undo.link = function(event, remove, k)
	for file, _ in pairs(undo.linkFiles) do
		if not k or type(utilitools.files.beattools[file].listen) ~= "table" or utilitools.files.beattools[file].listen[k] then
			if utilitools.files.beattools[file].cacheEvent then
				utilitools.files.beattools[file].cacheEvent(event, remove, k)
			end
		end
	end
end
undo.checkLink = function(event, remove, k)
	local deny = false
	for file, denyable in pairs(undo.linkFiles) do
		if not denyable then
			if not k or type(utilitools.files.beattools[file].listen) ~= "table" or utilitools.files.beattools[file].listen[k] then
				if utilitools.files.beattools[file].checkEvent then
					local denied = utilitools.files.beattools[file].checkEvent(event, remove, k)
					deny = deny or denied
				end
			end
		end
	end
	return deny
end

undo.keyTracked = function(k)
	return (mods.beattools.config.keyHandling == "blacklist" and not beattoolsKeysBlacklist[k]) or (mods.beattools.config.keyHandling == "whitelist" and beattoolsKeysWhiteList[k])
end

undo.init = function()
	for file, _ in pairs(undo.linkFiles) do
		if utilitools.files.beattools[file].init then
			utilitools.files.beattools[file].init()
		end
	end
	utilitools.files.beattools.eventGroups.init()
	undo.changes = {}
	undo.index = 0
end

undo.shiftIndices = function(up, pos, event)
	if up then
		for k, _ in pairs(undo.events) do
			if undo.events[k] >= pos then
				undo.events[k] = undo.events[k] + 1
			end
		end
		undo.events[tostring(event)] = pos
	else
		undo.events[tostring(event)] = nil
		for k, _ in pairs(undo.events) do
			if undo.events[k] > pos then
				undo.events[k] = undo.events[k] - 1
			end
		end
	end
end

undo.injectSub = function ()
	local amount = 0
	for i, event in ipairs(cs.level.events) do
		if getmetatable(event) == nil then
			setmetatable(event, nil)
			undo.meta(event)
			amount = amount + 1
		end
		undo.events[tostring(cs.level.events[i])] = i
	end
	-- modlog(mod, "Injected metatable into " .. amount .. " events")
end
undo.inject = function()
	setmetatable(cs.level.events, {
		__newindex = function (t, k, v)
			modlog(mod, "newindex GAHHHHHHHHHHHHHHH\nGAHHHHHHHHHHHHHHH\nGAHHHHHHHHHHHHHHH\nGAHHHHHHHHHHHHHHH\nGAHHHHHHHHHHHHHHH\nGAHHHHHHHHHHHHHHH\nGAHHHHHHHHHHHHHHH\nGAHHHHHHHHHHHHHHH")
			rawset(t, k, v)
		end
	})
	undo.injectSub()
	utilitools.files.beattools.fakeRepeat.updateList()
end

undo.newChangePre = function()
	--[[ if #undo.changes > undo.index then
		-- modlog(mod, "overwriting change history")
	end ]]
	while #undo.changes > undo.index do
		table.remove(undo.changes)
	end
	undo.lastCheck = love.timer.getTime()
end
undo.newChangeSub = function()
	undo.index = undo.index + 1
end

function undo.areSimilar(list1, list2, doReason, dontRepeat, path, realPath)
	if type(path or "") ~= "string" then modwarn(mod, "undo.areSimilar: invalid path", path) path = nil end
	if type(realPath or {}) ~= "table" then modwarn(mod, "undo.areSimilar: invalid realPath", realPath) realPath = nil end
	if type(dontRepeat or {}) ~= "table" then modwarn(mod, "undo.areSimilar: invalid dontRepeat", dontRepeat) dontRepeat = nil end
	path = path or "base"
	realPath = realPath or {}
	dontRepeat = dontRepeat or {}
	dontRepeat[tostring(list1)] = path .. " (A)"
	dontRepeat[tostring(list2)] = path .. " (B)"

	local reason = doReason and ({ readableTable = {}, changeTable = {}, log = nil, single = "" })[doReason]
	local singleChange = not doReason or ({ readableTable = false, changeTable = false, log = true, single = true })[doReason]

	local function addReason(path, realPath, text, key, value, value2, additional, additional2, overrideAdd)
		if doReason then
			local add
			if overrideAdd then
				add = overrideAdd
			else
				add = "[" .. path .. "] " .. text .. ": " .. tostring(key)
				if value ~= nil or value2 ~= nil then add = add .. ": " .. tostring(value) end
				if value2 ~= nil then add = add .. " >> " .. tostring(value2) end
				if additional ~= nil or additional2 ~= nil then add = add .. ": " .. tostring(additional) end
				if additional2 ~= nil then add = add .. " >> " .. tostring(additional2) end
			end
			local action = {
				readableTable = function() table.insert(reason, add) end,
				changeTable = function() table.insert(reason, { path = path, realPath = realPath, text = text, key = key, value = value, value2 = value2, additional = additional, additional2 = additional2 }) end,
				log = function() modlog(mod, add) end,
				single = function() reason = add end
			}
			if action[doReason] then action[doReason]() end
		end
	end

	local recheck = {}
	local function compare(list3, list4)
		local valid = true
		local first = list3 == list1

		if type(list3) ~= "table" or type(list4) ~= "table" then
			addReason(path, realPath, first, "] expected table: " .. tostring(list3) .. ", " .. tostring(list4))
			return false
		end
		for k, v in pairs(list3) do
			if undo.keyTracked(k) then
				if list4[k] == nil then
					if first then
						addReason(path, realPath, "removed", k, v, nil)
					else
						addReason(path, realPath, "added", k, nil, v)
					end
					if singleChange then return false else valid = false end
				elseif first then
					if type(list4[k]) ~= type(v) then
						addReason(path, realPath, "type", k, v, list4[k])
						if singleChange then return false else valid = false end
					elseif type(v) == "table" then
						if dontRepeat[tostring(v)] or dontRepeat[tostring(list4[k])] then
							if list4[k] ~= v then
								addReason(path, realPath, "circular", k, v, list4[k], dontRepeat[tostring(v)], dontRepeat[tostring(list4[k])])
								if singleChange then return false else valid = false end
							end
						else
							recheck[k] = true
						end
					elseif list4[k] ~= v then
						addReason(path, realPath, "changed", k, v, list4[k])
						if singleChange then return false else valid = false end
					end
				end
			end
		end
		return valid
	end
	local valid1, valid2 = compare(list1, list2), compare(list2, list1)
	local valid = valid1 and valid2
	for k, _ in ipairs(recheck) do
		local realPath2 = { unpack(realPath) }
		table.insert(realPath2, k)
		local valid3, reasons = undo.areSimilar(list1[k], list2[k], doReason, dontRepeat, path .. "." .. tostring(k), realPath2)
		if not valid3 then
			valid = false
			if singleChange then
				if not reasons then break end
				if type(reasons) == "table" then modwarn(mod, "undo.areSimilar: singleChange but reasons is a table?!?", reasons) end
				addReason(nil, nil, nil, nil, nil, nil, nil, nil, reasons)
				break
			elseif type(reasons) == "table" then
				for _, reason2 in ipairs(reasons) do
					table.insert(reason, reason2)
				end
			else modwarn(mod, "undo.areSimilar: not singleChange but reasons is not a table?!?", reasons) end
		end
	end
	return valid, reason
end
undo.setParams = function(event, params)
	for k, v in pairs(event) do event[k] = nil end
	for k, v in pairs(params) do event[k] = helpers.copy(v) end
end

undo.pairs = function(list)
	if cs and cs.name == "Editor" and cs.level and cs.level.events and getmetatable(list) and getmetatable(list).beattoolsUndoInject then
		return beattools.moremetamethods.pairs(getmetatable(list).hidden)
	end
	return beattools.moremetamethods.pairs(list)
end
undo.insert = function(list, pos, value)
	if value == nil and list then
		value = pos
		pos = #list + 1
	end
	if cs and cs.name == "Editor" and cs.level and cs.level.events and list == cs.level.events then
		if undo.fakeRepeating or value.beattoolsRepeatChild == nil then
			if getmetatable(value) == nil or not getmetatable(value).beattoolsUndoInject then
				undo.meta(value)
			end

			if
				undo.changes[undo.index + 1] and
				undo.changes[undo.index + 1].type == "add" and
				-- undo.changes[undo.index + 1].ref == value and
				-- undo.changes[undo.index + 1].index == pos and
				undo.areSimilar(undo.changes[undo.index + 1].ref, value)
			then
				value = undo.changes[undo.index + 1].ref
				undo.changes[undo.index + 1].index = pos

				-- modlog(mod, "Manual redo insert")
				undo.index = undo.index + 1
			elseif
				undo.changes[undo.index] and
				undo.changes[undo.index].type == "remove" and
				-- undo.changes[undo.index].ref == value and
				-- undo.changes[undo.index].index == pos and
				undo.areSimilar(undo.changes[undo.index].ref, value)
			then
				value = undo.changes[undo.index].ref
				undo.changes[undo.index].index = pos

				-- modlog(mod, "Manual undo delete")
				undo.index = undo.index - 1
			else
				-- modlog(mod, tostring(undo.changes[undo.index]) .. " " .. tostring(undo.changes[undo.index].type == "remove") .. " " .. tostring(undo.changes[undo.index].index == pos) .. " " .. tostring(undo.areSimilar(undo.changes[undo.index].ref, value)))
				undo.newChangePre()
				--[[ modlog(mod,
					"Adding: " ..
					"\tindex: " .. tostring(pos)
				) ]]
				table.insert(undo.changes, {
					type = "add",
					event = helpers.copy(value),
					ref = value,
					index = pos,
					time = undo.lastCheck
				})
				undo.newChangeSub()
			end

			undo.shiftIndices(true, pos, value)
			beattools.moremetamethods.insert(list, pos, value)
			undo.link(value)

			if not undo.fakeRepeating then
				utilitools.files.beattools.fakeRepeat.update(value)
			end
			cs:updateBiggestBeat()
		else
			-- forceprint("add refused " .. pos)
		end

		return false
	end
	return true
end
undo.remove = function(list, pos)
	if cs and cs.name == "Editor" and cs.level and cs.level.events and list == cs.level.events and list[pos] then
		local returnValue
		if undo.fakeRepeating or list[pos].beattoolsRepeatChild == nil then
			if
				undo.changes[undo.index + 1] and
				undo.changes[undo.index + 1].type == "remove" and
				undo.changes[undo.index + 1].ref == list[pos] and
				undo.changes[undo.index + 1].index == pos and
				undo.areSimilar(undo.changes[undo.index + 1].ref, list[pos])
			then
				-- modlog(mod, "Manual redo delete")
				undo.index = undo.index + 1
			elseif
				undo.changes[undo.index] and
				undo.changes[undo.index].type == "add" and
				undo.changes[undo.index].ref == list[pos] and
				undo.changes[undo.index].index == pos and
				undo.areSimilar(undo.changes[undo.index].ref, list[pos])
			then
				-- modlog(mod, "Manual undo insert")
				undo.index = undo.index - 1
			else
				undo.newChangePre()
				--[[ modlog(mod,
					"Removing:" ..
					"\tindex: " .. tostring(pos)
				) ]]
				table.insert(undo.changes, {
					type = "remove",
					event = helpers.copy(list[pos]),
					ref = list[pos],
					index = pos,
					time = undo.lastCheck
				})
				undo.newChangeSub()
			end

			local event = list[pos]

			undo.link(list[pos], true)
			returnValue = beattools.moremetamethods.remove(list, pos)
			undo.shiftIndices(false, pos, list[pos])

			if event.beattoolsRepeatParent then
				utilitools.files.beattools.fakeRepeat.remove(undo.changes[undo.index].ref.beattoolsRepeatParent)
			end
			cs:updateBiggestBeat()
		else
			-- forceprint("remove refused " .. pos)
		end
		return false, returnValue
	end
	return true
end
undo.change = function(t, k, v, hidden)
	if not undo.undoing and cs and cs.name == "Editor" and cs.level and cs.level.events and hidden[k] ~= v then
		if undo.keyTracked(k) then
			if undo.fakeRepeating or (hidden.beattoolsRepeatChild == nil and k ~= "beattoolsRepeatChild") then
				if undo.events[tostring(t)] == nil then
					modwarn(mod, "INDEX IS NIL!!!\nINDEX IS NIL!!!\nINDEX IS NIL!!!\nINDEX IS NIL!!!")
					undo.injectSub()
					-- utilitools.files.beattools.fakeRepeat.updateList()
				end
				if
					undo.changes[undo.index + 1] and
					undo.changes[undo.index + 1].type == "change" and
					undo.changes[undo.index + 1].ref == t and
					undo.changes[undo.index + 1].index == undo.events[tostring(t)] and
					undo.changes[undo.index + 1].key == k and
					undo.changes[undo.index + 1].from == hidden[k] and
					undo.changes[undo.index + 1].to == v
				then
					-- modlog(mod, "Manual redo change")
					undo.index = undo.index + 1
				elseif
					undo.changes[undo.index] and
					undo.changes[undo.index].type == "change" and
					undo.changes[undo.index].ref == t and
					undo.changes[undo.index].index == undo.events[tostring(t)] and
					undo.changes[undo.index].key == k and
					undo.changes[undo.index].from == v and
					undo.changes[undo.index].to == hidden[k]
				then
					-- modlog(mod, "Manual undo change")
					undo.index = undo.index - 1
				else
					undo.newChangePre()
					--[[ modwarn(mod,
						"Changing:" ..
						"\tindex: " .. tostring(undo.events[tostring(t)]) .. "\n"..
						"\tkey: " .. tostring(k) .. "\n"..
						"\tfrom: " .. tostring(hidden[k]) .. "\n"..
						"\tto: " .. tostring(v)
					) ]]
					table.insert(undo.changes, {
						type = "change",
						ref = t,
						index = undo.events[tostring(t)],
						key = k,
						from = hidden[k],
						to = v,
						time = undo.lastCheck
					})
					undo.newChangeSub()
				end

				local temp = not undo.fakeRepeating and (k == "time" and v - hidden[k] or v)

				undo.link(t, true, k)
				hidden[k] = v
				undo.link(t, nil, k)

				if not undo.fakeRepeating then
					utilitools.files.beattools.fakeRepeat.update(t, false, k, temp)
				end
				if undo.keyTracked(k) then
					cs:updateBiggestBeat()
				end
			else
				-- forceprint("change refused " .. k .. " from " .. tostring(hidden[k]) .. " to " .. tostring(v))
			end
		end
	else
		hidden[k] = v
	end
end
undo.firstTime = function()
	beattools = beattools or {}
	beattools.moremetamethods = beattools.moremetamethods or {}
	if beattools.moremetamethods.pairs == nil then
		beattools.moremetamethods.pairs = pairs
		_G.pairs = function(...)
			return undo.pairs(...)
		end
	end
	if beattools.moremetamethods.insert == nil then
		beattools.moremetamethods.insert = table.insert
		---@diagnostic disable-next-line: duplicate-set-field
		table.insert = function(...)
			if undo.insert(...) then
				beattools.moremetamethods.insert(...)
			end
		end
	end
	if beattools.moremetamethods.remove == nil then
		beattools.moremetamethods.remove = table.remove
		---@diagnostic disable-next-line: duplicate-set-field
		table.remove = function(...)
			local override, returnValue = undo.remove(...)
			if override then
				return beattools.moremetamethods.remove(...)
			else
				return returnValue
			end
		end
	end
end

undo.unselect = function(event)
	if cs.selectedEvent == event then
		cs:noSelection()
		cs.selectedEvent = nil
	end
	if cs.multiselect and cs.multiselect.eventTypes[event.type] then
		for _, v in ipairs(cs.multiselect.events) do
			if v == event then
				cs:beattoolsCtrlSelect(event, true)
			end
		end
	end
end

undo.fullSave = function()
	undo.newChangePre()
	local events = {}
	for i, v in ipairs(cs.level.events) do
		events[i] = { event = helpers.copy(v), ref = v, index = i }
		undo.link(v)
	end
	table.insert(undo.changes, {
		type = "fullSave",
		events = events,
		time = undo.lastCheck
	})
	undo.newChangeSub()
	utilitools.files.beattools.eventGroups.process()
end

undo.update = function()
	if cs.level then
		if getmetatable(cs.level.events) == nil then
			undo.init()
			undo.inject()
		end
		if #undo.changes == 0 then
			utilitools.files.beattools.stopwatch.time("Start")
			undo.fullSave()
			utilitools.files.beattools.stopwatch.time("First Full Save")
		end
	end
end

undo.keybind = function(doUndo, doMultiple)
	if undo.index < 0 then undo.index = 0 end
	if undo.index > #undo.changes then undo.index = #undo.changes end
	local hasChanged = false
	if doUndo == nil then doUndo = not maininput:down("shift") end
	if doMultiple == nil then doMultiple = maininput:down("ctrl") end
	local success = true
	local change = undo.changes[undo.index + (doUndo and 0 or 1)]
	local tempTime = change and change.time or 0
	local changedFakeRepeat = false

	while success and change and (change.type == "fullSave" or not hasChanged or math.abs(tempTime - change.time) < (doMultiple and mods.beattools.config.groupTimeDifference or 0.01)) do
		-- modlog(mod, (doUndo and "un" or "re") .. "doing " .. change.type .. " " .. (undo.index + (doUndo and 0 or 1)))
		success = false

		local function reAdd(action, data)
			if not undo.areSimilar(data.ref, data.event, "log") then
				modlog(mod, "EVENT PARAMS DO NOT MATCH: " .. tostring(action))
				undo.setParams(data.ref, data.event)
			end
			-- forceprint(action .. " add " .. data.index)
			undo.shiftIndices(true, data.index, data.ref)
			beattools.moremetamethods.insert(cs.level.events, data.index, data.ref)
			undo.link(data.ref)

			if data.ref.beattoolsRepeatParent or data.ref.beattoolsRepeatChild then
				-- forceprint("Added " .. tostring(data.ref.beattoolsRepeatParent) .. " " .. tostring(data.ref.beattoolsRepeatChild))
				changedFakeRepeat = true
			end
			return true
		end
		local function reRemove(action, data)
			if cs.level.events[data.index] then
				if cs.level.events[data.index] == data.ref then
					if not undo.areSimilar(cs.level.events[data.index], data.event, "log") then
						modlog(mod, "EVENT PARAMS DO NOT MATCH: " .. tostring(action))
						undo.setParams(data.ref, data.event)
					end
					undo.unselect(data.ref)
					-- forceprint(action .. " remove " .. data.index)
					if data.ref.beattoolsRepeatParent or data.ref.beattoolsRepeatChild then
						-- forceprint("Removed " .. tostring(data.ref.beattoolsRepeatParent) .. " " .. tostring(data.ref.beattoolsRepeatChild))
						changedFakeRepeat = true
					end

					undo.link(data.ref, true)
					beattools.moremetamethods.remove(cs.level.events, data.index)
					undo.shiftIndices(false, data.index, data.ref)

					return true
				else
					modlog(mod, "EVENT DOES NOT MATCH: " .. tostring(action))
				end
			else
				modlog(mod, "EVENT DOES NOT EXIST: " .. tostring(action) .. ": " .. tostring(data.index))
			end
		end

		local funcs = {
			fullSave = function()
				if #cs.level.events ~= #change.events then -- full recreate
					-- modlog(mod, "full recreate start")
					while #cs.level.events > 0 do
						undo.unselect(cs.level.events[#cs.level.events])
						if cs.level.events[#cs.level.events].beattoolsRepeatParent or cs.level.events[#cs.level.events].beattoolsRepeatChild then
							changedFakeRepeat = true
						end
						beattools.moremetamethods.remove(cs.level.events)
					end
					for i, v in ipairs(change.events) do
						reAdd("full recreate", v)
					end
					-- modlog(mod, "full recreate end")
					return true
				else -- lazy
					for i, v in ipairs(cs.level.events) do
						if v ~= change.events[i].ref then
							modlog(mod, "EVENT DOES NOT MATCH: lazy recreate")
							undo.unselect(cs.level.events)
							if cs.level.events[i].beattoolsRepeatParent or cs.level.events[i].beattoolsRepeatChild then
								changedFakeRepeat = true
							end
							cs.level.events[i] = change.events[i].ref
						end
						if not undo.areSimilar(cs.level.events[i], change.events[i].event, "log") then
							modlog(mod, "EVENT PARAMS DO NOT MATCH: lazy recreate")
							if cs.level.events[i].beattoolsRepeatParent or cs.level.events[i].beattoolsRepeatChild then
								changedFakeRepeat = true
							end
							undo.setParams(cs.level.events[i], change.events[i].event)
							if cs.level.events[i].beattoolsRepeatParent or cs.level.events[i].beattoolsRepeatChild then
								changedFakeRepeat = true
							end
						end
					end
					return true
				end
			end,
			change = function()
				if cs.level.events[change.index] then
					if cs.level.events[change.index] == change.ref then
						if cs.level.events[change.index][change.key] == change[doUndo and "to" or "from"] then
							-- forceprint((doUndo and "un" or "re") .. "do " .. change.key .. " from " .. tostring(cs.level.events[change.index][change.key]) .. " to " .. tostring(change[doUndo and "from" or "to"]))

							undo.link(cs.level.events[change.index], true, change.key)
							cs.level.events[change.index][change.key] = helpers.copy(change[doUndo and "from" or "to"])
							undo.link(cs.level.events[change.index], nil, change.key)

							if cs.level.events[change.index].beattoolsRepeatParent or change.key == "beattoolsRepeatParent" then
								changedFakeRepeat = true
							end
							return true
						else
							modlog(mod, "EVENT VALUE DOES NOT MATCH: " .. tostring(cs.level.events[change.index][change.key]) .. " ~= " .. tostring(change[doUndo and "to" or "from"]))
						end
					else
						modlog(mod, "EVENT DOES NOT MATCH: " .. tostring(cs.level.events[change.index]) .. " ~= " .. tostring(change.ref))
					end
				else
					modlog(mod, "EVENT DOES NOT EXIST: " .. tostring(change.index))
				end
			end,
			add = function()
				if doUndo then
					return reRemove("undo add", change)
				else
					return reAdd("redo add", change)
				end
			end,
			remove = function()
				if doUndo then
					return reAdd("undo remove", change)
				else
					return reRemove("redo remove", change)
				end
			end
		}

		if change then
			if change.type and funcs[change.type] then
				undo.undoing = true
				if funcs[change.type]() then
					if not hasChanged and change.type ~= "fullSave" then hasChanged = true end
					undo.index = undo.index + (doUndo and -1 or 1)
					tempTime = change.time
					success = true
				end
				undo.undoing = false
			else
				modlog(mod, "NO CHANGE TYPE: " .. tostring(change.type))
			end
		else
			modlog(mod, "NO CHANGE")
		end
		change = undo.changes[undo.index + (doUndo and 0 or 1)]
	end
	if undo.index < 1 then
		undo.index = 1
	end
	if changedFakeRepeat then
		-- forceprint("UPDATING lIST")
		utilitools.files.beattools.fakeRepeat.updateList()
	end
end

if cs and cs.name == "Editor" and cs.level and cs.level.events then
	setmetatable(cs.level.events, nil)
	-- forceprint("setting it to nothing")
end

return undo