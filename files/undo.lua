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
	fakeRepeating = false
}

undo.keyTracked = function(k)
	return (mods.beattools.config.keyHandling == "blacklist" and not beattoolsKeysBlacklist[k]) or (mods.beattools.config.keyHandling == "whitelist" and beattoolsKeysWhiteList[k])
end

undo.init = function()
	utilitools.files.beattools.eventStacking.init()
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
			t[k] = v
		end
	})
	undo.injectSub()
	utilitools.files.beattools.fakeRepeat.updateList()
end

undo.newChangePre = function()
	if #undo.changes > undo.index then
		modlog(mod, "overwriting change history")
	end
	while #undo.changes > undo.index do
		table.remove(undo.changes)
	end
	undo.lastCheck = love.timer.getTime()
end
undo.newChangeSub = function()
	undo.index = undo.index + 1
end

undo.areSimilar = function (list1, list2, dontRepeat)
	dontRepeat = dontRepeat or {}
	dontRepeat[tostring(list1)] = true
	dontRepeat[tostring(list2)] = true
	local function compare(list3, list4)
		for k, v in pairs(list3) do
			if undo.keyTracked(k) then
				if type(list4[k]) ~= type(v) then
					modlog(mod, "different type: " .. tostring(k) .. ": " .. tostring(v) .. " ~= " .. tostring(list4[k]))
					return false
				elseif type(v) == "table" and not dontRepeat[tostring(v)] and not dontRepeat[tostring(list4[k])] then
					if not undo.areSimilar(v, list4[k]) then return false end
				else
					if list4[k] ~= v then
						modlog(mod, "different: " .. tostring(k) .. ": " .. tostring(v) .. " ~= " .. tostring(list4[k]))
						return false
					end
				end
			end
		end
		return true
	end
	return compare(list1, list2) and compare(list2, list1)
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
	if value == nil then
		value = pos
		pos = #list + 1
	end
	if cs and cs.name == "Editor" and cs.level and cs.level.events and list == cs.level.events then
		if utilitools.files.beattools.undo.fakeRepeating or value.beattoolsRepeatChild == nil then
			if getmetatable(value) == nil or not getmetatable(value).beattoolsUndoInject then
				undo.meta(value)
			end

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

			undo.shiftIndices(true, pos, value)
			beattools.moremetamethods.insert(list, pos, value)
			utilitools.files.beattools.eventStacking.addToStack(value)

			if not utilitools.files.beattools.undo.fakeRepeating then
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
	if cs and cs.name == "Editor" and cs.level and cs.level.events and list == cs.level.events then
		local returnValue
		if utilitools.files.beattools.undo.fakeRepeating or list[pos].beattoolsRepeatChild == nil then
			if undo.changes[undo.index + 1] and
				undo.changes[undo.index + 1].type == "remove" and
				undo.changes[undo.index + 1].ref == list[pos] and
				undo.changes[undo.index + 1].index == pos
			and undo.areSimilar(undo.changes[undo.index + 1].ref, list[pos]) then
				-- modlog(mod, "Manual redo")
				undo.index = undo.index + 1
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

				undo.shiftIndices(false, pos, list[pos])
			end

			utilitools.files.beattools.eventStacking.removeFromStack(list[pos])
			returnValue = beattools.moremetamethods.remove(list, pos)

			if undo.changes[undo.index].ref.beattoolsRepeatParent then
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
	if not utilitools.files.beattools.undo.undoing and cs and cs.name == "Editor" and cs.level and cs.level.events and hidden[k] ~= v then
		if undo.keyTracked(k) then
			if utilitools.files.beattools.undo.fakeRepeating or (hidden.beattoolsRepeatChild == nil and k ~= "beattoolsRepeatChild") then
				if undo.events[tostring(t)] == nil then modlog("INDEX IS NIL!!!\nINDEX IS NIL!!!\nINDEX IS NIL!!!\nINDEX IS NIL!!!") end
				if undo.changes[undo.index + 1] and
					undo.changes[undo.index + 1].type == "change" and
					undo.changes[undo.index + 1].ref == t and
					undo.changes[undo.index + 1].index == undo.events[tostring(t)] and
					undo.changes[undo.index + 1].key == k and
					undo.changes[undo.index + 1].from == hidden[k]
				and undo.changes[undo.index + 1].to == v then
					-- modlog(mod, "Manual redo")
					undo.index = undo.index + 1
				else
					undo.newChangePre()
					--[[ modlog(mod,
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

				local temp = not utilitools.files.beattools.undo.fakeRepeating and (k == "time" and v - hidden[k] or v)


				if ({ type = true, time = true, angle = true, order = true })[k] then utilitools.files.beattools.eventStacking.removeFromStack(t) end
				hidden[k] = v
				if ({ type = true, time = true, angle = true, order = true })[k] then utilitools.files.beattools.eventStacking.addToStack(t) end

				if not utilitools.files.beattools.undo.fakeRepeating then
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
			return utilitools.files.beattools.undo.pairs(...)
		end
	end
	if beattools.moremetamethods.insert == nil then
		beattools.moremetamethods.insert = table.insert
		---@diagnostic disable-next-line: duplicate-set-field
		table.insert = function(...)
			if utilitools.files.beattools.undo.insert(...) then
				beattools.moremetamethods.insert(...)
			end
		end
	end
	if beattools.moremetamethods.remove == nil then
		beattools.moremetamethods.remove = table.remove
		---@diagnostic disable-next-line: duplicate-set-field
		table.remove = function(...)
			local override, returnValue = utilitools.files.beattools.undo.remove(...)
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
		cs.selectedEvent = nil
		cs.holdEndSelected = false
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
		utilitools.files.beattools.eventStacking.addToStack(v)
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
			undo.fullSave()
		end
	end
end

undo.keybind = function(doUndo, doMultiple)
	if utilitools.files.beattools.undo.index < 0 then utilitools.files.beattools.undo.index = 0 end
	if utilitools.files.beattools.undo.index > #utilitools.files.beattools.undo.changes then utilitools.files.beattools.undo.index = #utilitools.files.beattools.undo.changes end
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
			if not undo.areSimilar(data.ref, data.event) then
				modlog(mod, "EVENT PARAMS DO NOT MATCH: " .. tostring(action))
				undo.setParams(data.ref, data.event)
			end
			-- forceprint(action .. " add " .. data.index)
			undo.shiftIndices(true, data.index, data.ref)
			beattools.moremetamethods.insert(cs.level.events, data.index, data.ref)
			utilitools.files.beattools.eventStacking.addToStack(data.ref)
			if data.ref.beattoolsRepeatParent or data.ref.beattoolsRepeatChild then
				-- forceprint("Added " .. tostring(data.ref.beattoolsRepeatParent) .. " " .. tostring(data.ref.beattoolsRepeatChild))
				changedFakeRepeat = true
			end
			return true
		end
		local function reRemove(action, data)
			if cs.level.events[data.index] then
				if cs.level.events[data.index] == data.ref then
					if not undo.areSimilar(cs.level.events[data.index], data.event) then
						modlog(mod, "EVENT PARAMS DO NOT MATCH: " .. tostring(action))
						undo.setParams(data.ref, data.event)
					end
					undo.unselect(data.ref)
					-- forceprint(action .. " remove " .. data.index)
					if data.ref.beattoolsRepeatParent or data.ref.beattoolsRepeatChild then
						-- forceprint("Removed " .. tostring(data.ref.beattoolsRepeatParent) .. " " .. tostring(data.ref.beattoolsRepeatChild))
						changedFakeRepeat = true
					end
					utilitools.files.beattools.eventStacking.removeFromStack(data.ref)
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
						if not undo.areSimilar(cs.level.events[i], change.events[i].event) then
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
							if ({ type = true, time = true, angle = true, order = true })[change.key] then utilitools.files.beattools.eventStacking.removeFromStack(cs.level.events[change.index]) end
							cs.level.events[change.index][change.key] = helpers.copy(change[doUndo and "from" or "to"])
							if ({ type = true, time = true, angle = true, order = true })[change.key] then utilitools.files.beattools.eventStacking.addToStack(cs.level.events[change.index]) end
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