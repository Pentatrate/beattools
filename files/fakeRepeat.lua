local fakeRepeat = {
	indices = {}
}

fakeRepeat.newIndex = function(neg)
	step = neg and -1 or 1
	local i = neg and -1 or 0
	while fakeRepeat.indices[i] do
		i = i + step
	end
	return i
end
fakeRepeat.addIndex = function(index)
	if fakeRepeat.indices[index] == nil then
		fakeRepeat.indices[index] = { events = {}, indices = {}, amount = 0 }
	end
end
fakeRepeat.addChild = function(index, event)
	fakeRepeat.indices[index].events[tostring(event)] = event
	table.insert(fakeRepeat.indices[index].indices, tostring(event))
	fakeRepeat.indices[index].amount = fakeRepeat.indices[index].amount + 1
end
fakeRepeat.removeChild = function(index, event)
	fakeRepeat.indices[index].events[tostring(event)] = nil
	for i = #fakeRepeat.indices[index].indices, 1, -1 do
		if fakeRepeat.indices[index].indices[i] == tostring(event) then
			table.remove(fakeRepeat.indices[index].indices, i)
			break
		end
	end
	fakeRepeat.indices[index].amount = fakeRepeat.indices[index].amount - 1
end
fakeRepeat.remove = function(index, onlyChildren, indicesIncomplete)
	if not mods.beattools.config.fakeRepeat then return end
	if not fakeRepeat.indices[index] then return end

	utilitools.files.beattools.undo.fakeRepeating = true
	for i = #cs.level.events, 1, -1 do
		local v = cs.level.events[i]
		if onlyChildren and v.beattoolsRepeatParent == index and (indicesIncomplete or fakeRepeat.indices[index].events[tostring(v)]) then
			fakeRepeat.removeChild(index, v)
			fakeRepeat.indices[index].parent = nil

			v.beattoolsRepeatParent = nil
		elseif (indicesIncomplete and (v.beattoolsRepeatParent == index or v.beattoolsRepeatChild == index)) or fakeRepeat.indices[index].events[tostring(v)] then
			table.remove(cs.level.events, i)
			fakeRepeat.removeChild(index, v)
			if v.beattoolsRepeatParent == index then
				fakeRepeat.indices[index].parent = nil
			end
		end
	end
	fakeRepeat.indices[index] = nil
	utilitools.files.beattools.undo.fakeRepeating = false
end
fakeRepeat.updateList = function()
	fakeRepeat.indices = {}

	for _, v in ipairs(cs.level.events) do
		if v.beattoolsRepeatParent ~= nil then
			fakeRepeat.addIndex(v.beattoolsRepeatParent)
			if fakeRepeat.indices[v.beattoolsRepeatParent].parent then
				modlog(mod, "Double repeat index " .. v.beattoolsRepeatParent)
				modlog(mod, "Check  events:\n" ..
					"\ttype: " .. tostring(fakeRepeat.indices[v.beattoolsRepeatParent].type) .. "\n" ..
					"\ttime: " .. tostring(fakeRepeat.indices[v.beattoolsRepeatParent].time) .. "\n" ..
					"\tangle: " .. tostring(fakeRepeat.indices[v.beattoolsRepeatParent].angle) .. "\n" ..
					"and\n" ..
					"\ttype: " .. tostring(v.type) .. "\n" ..
					"\ttime: " .. tostring(v.time) .. "\n" ..
					"\tangle: " .. tostring(v.angle)
				)
				fakeRepeat.remove(v.beattoolsRepeatParent, true, true)
			else
				fakeRepeat.addChild(v.beattoolsRepeatParent, v)
				fakeRepeat.indices[v.beattoolsRepeatParent].parent = v

				if not (v.repeats ~= nil and v.repeats > 0) then
					fakeRepeat.remove(v.beattoolsRepeatParent, true, true)
				end
			end
		end
		if v.beattoolsRepeatChild ~= nil then
			fakeRepeat.addIndex(v.beattoolsRepeatChild)
			fakeRepeat.addChild(v.beattoolsRepeatChild, v)
		end
	end

	for k, v in pairs(fakeRepeat.indices) do
		if v.parent == nil then
			-- forceprint("no parent")
			fakeRepeat.remove(k)
		elseif v.parent.repeats + 1 ~= v.amount then
			-- forceprint("INCOMPLETE REPEAT | wanted: " .. v.parent.repeats + 1 .. " | has: " .. v.amount)
			fakeRepeat.reGenerate(v.parent)
		end
	end
end
fakeRepeat.reGenerate = function(event, irreversible, first)
	local index = first or event.beattoolsRepeatParent
	if index == nil then return end

	if not first then fakeRepeat.remove(index, true) end
	fakeRepeat.addIndex(index)

	utilitools.files.beattools.undo.fakeRepeating = true
	for i = 1, event.repeats do
		local newEvent = helpers.copy(event)

		newEvent.beattoolsRepeatParent, newEvent.repeats, newEvent.repeatDelay = nil, nil, nil
		newEvent.time = event.time + i * (event.repeatDelay or 1)
		if not irreversible then
			newEvent.beattoolsRepeatChild = index

			utilitools.files.beattools.undo.meta(newEvent)

			table.insert(cs.level.events, newEvent)

			fakeRepeat.addChild(index, newEvent)
		else
			table.insert(cs.level.events, newEvent)
		end
	end

	if irreversible then
		event.beattoolsRepeatParent, event.repeats, event.repeatDelay = nil, nil, nil
		fakeRepeat.indices[index] = nil
	else
		event.beattoolsRepeatParent = index
		fakeRepeat.addChild(index, event)
		fakeRepeat.indices[index].parent = event
	end
	utilitools.files.beattools.undo.fakeRepeating = false
end
fakeRepeat.updateChildren = function(index, key, value)
	utilitools.files.beattools.undo.fakeRepeating = true
	for i, v in ipairs(fakeRepeat.indices[index].indices) do
		if v ~= tostring(fakeRepeat.indices[index].parent) then
			fakeRepeat.indices[index].events[v][key] = key == "time" and (fakeRepeat.indices[index].events[v][key] + value) or value
		end
	end
	utilitools.files.beattools.undo.fakeRepeating = false
end
fakeRepeat.update = function(event, irreversible, key, value)
	if (not mods.beattools.config.fakeRepeat) and (not irreversible) then return end
	if utilitools.files.beattools.eventVisuals.hasRepeat[event.type] then event.beattoolsRepeatParent = nil fakeRepeat.updateList() return end
	-- forceprint("CALLED THIS SHIT METHTABLE MY ASS")

	if ({ repeats = true, repeatDelay = true })[key] or irreversible or event.beattoolsRepeatParent == nil or fakeRepeat.indices[event.beattoolsRepeatParent] == nil or fakeRepeat.indices[event.beattoolsRepeatParent].parent ~= event then
		if key == "repeats" then
			if (event.beattoolsRepeatParent == nil or fakeRepeat.indices[event.beattoolsRepeatParent] == nil or fakeRepeat.indices[event.beattoolsRepeatParent].parent ~= event) and event.repeats ~= nil and event.repeats > 0 then
				utilitools.files.beattools.undo.fakeRepeating = true
				event.repeatDelay = 1
				utilitools.files.beattools.undo.fakeRepeating = false
				fakeRepeat.reGenerate(event, false, fakeRepeat.newIndex())
			end
			if event.repeats == nil or event.repeats == 0 then
				-- forceprint("no parent")
				fakeRepeat.remove(event.beattoolsRepeatParent, true)
				utilitools.files.beattools.undo.fakeRepeating = true
				event.repeatDelay = nil
				utilitools.files.beattools.undo.fakeRepeating = false
			elseif event.repeats + 1 ~= fakeRepeat.indices[event.beattoolsRepeatParent].amount then
				-- forceprint("incomplete repeat | wanted: " .. event.repeats + 1 .. " | has: " .. fakeRepeat.indices[event.beattoolsRepeatParent].amount)
				fakeRepeat.reGenerate(event)
			end
		end
		-- forceprint("EEEEEEEEEEEEEEEEEE")
		fakeRepeat.updateList()
		if event.beattoolsRepeatParent and event.repeats ~= nil and event.repeats > 0 then
			if key == "repeatDelay" or irreversible then
				fakeRepeat.reGenerate(event, irreversible)
			end
		else
			event.beattoolsRepeatParent = nil
		end
	else
		fakeRepeat.updateChildren(event.beattoolsRepeatParent, key, value)
	end
	-- forceprint("ENDENDENDENDENDEND")
end

return fakeRepeat