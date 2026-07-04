--[[
TODO
- check decos hidden
- check for ease modes
]]
local compare = {
	orig = {},
	origStats = {},
	new1 = {},
	new1Stats = {},
	new1Index = 1,
	new2 = {},
	new2Stats = {},
	new2Index = 1
}

if beattools and beattools.test and beattools.test.compare then
	modlog(mod, "compare: loading from cache")
	compare = beattools.test.compare
end

compare.parts = {
	velocity = { 132, 260, 420, 596, 788, 948, 1012, 1124 }
}
compare.currentCollab = "velocity"

function compare.getPart()
	if not cLevel then return 0 end

	local reversed = cLevel:reverse()
	local b = reversed:find("/", 2)
	if b then
		local c = #cLevel + 1 - b - 1
		local d = reversed:find("/", b + 1)
		if d then
			local e = #cLevel + 1 - d + 1
			local f = cLevel:sub(e, c):find(" ")
			if f then
				f = e + f - 1
				local g = cLevel:sub(e, f)
				return tonumber(g)
			end
		end
	end
	return 0
end
function compare.getPartBounds(part)
	return compare.parts[compare.currentCollab][part - 1], compare.parts[compare.currentCollab][part]
end

function compare.getNextChange(new2)
	local changes = compare["new" .. (new2 and "2" or "1") .. "Stats"].total
	if not changes then return -1, 0 end
	local remainingChanges = 0
	local smallestIndex

	for i, change in ipairs(changes) do
		if not change.resolved then
			remainingChanges = remainingChanges + 1
			smallestIndex = smallestIndex or i
		end
	end

	return smallestIndex, remainingChanges
end
function compare.showChanges(new2)
	local newStats = compare["new" .. (new2 and "2" or "1") .. "Stats"]
	local changes = newStats.total
	if not changes then return end
	local index = compare["new" .. (new2 and "2" or "1") .. "Index"]
	local change = changes[index]
	if change then
		local smallestIndex, remainingChanges = compare.getNextChange(new2)
		local function jumpToNext()
			smallestIndex, remainingChanges = compare.getNextChange(new2)
			compare["new" .. (new2 and "2" or "1") .. "Index"] = smallestIndex or 0
		end
		imgui.Text(utilitools.string.concat("REMAINING", remainingChanges))
		if change.resolved then
			imgui.Text(utilitools.string.concat("Resolved", change.resolved))
			if imgui.Button("Jump to next change") then jumpToNext() end
		else
			local temp = change.event2 or change.event
			imgui.Text(utilitools.string.concat(index, change.text, "\n", temp.time, change.withinTime, temp.angle, "\n", utilitools.string.concat(utilitools.string.concat(temp.type, temp.var), temp.id), change.reason and "\n" .. table.concat(change.reason, ",\n") or nil))
			if imgui.Button("JUMP") then
				cs.editorBeat = temp.time
			end
			imgui.SameLine()
			if imgui.Button("ORIG") then
				change.resolved = "ORIG"
				local function orig(array, event2)
					function eventIndex()
						if event2 == nil then return -1 end
						for i, v in ipairs(array) do
							if v == event2 then return i end
						end
						return -1
					end
					local i = -1
					if change.event2 then
						i = eventIndex()
					end
					if i == -1 then
						i = #array + 1
					end
					-- doing the -1 thing instead of a nil check so my lua extension doesnt complain
					table.remove(array, i)
					if change.event then
						table.insert(array, i, change.event)
					end
				end
				orig(cs.level.events, newStats.map.linkedNew[tostring(change.event2)])
				orig(compare["new" .. (new2 and "2" or "1")], change.event2)
				jumpToNext()
			end
			imgui.SameLine()
			if imgui.Button("NEW") then
				change.resolved = "NEW"
				jumpToNext()
			end
			imgui.SameLine()
			if imgui.Button("ALL NEW") then
				for _, change in ipairs(changes) do
					if not change.resolved then change.resolved = "NEW" end
				end
				jumpToNext()
			end
		end
	end
end
function compare.window(window_flag, inputFlag)
	if mod.config.compareWindow then
		helpers.SetNextWindowPos(750, 400, window_flag)
		helpers.SetNextWindowSize(200, 320, window_flag)
		mod.config.compareWindow = imgui.Begin("Merge Manager", true, (inputFlag or 0) + (mod.config.stopImGuiMove and imgui.ImGuiWindowFlags_NoMove or 0) + (mod.config.stopImGuiResize and imgui.ImGuiWindowFlags_NoResize or 0))

		if imgui.Button("Cache") then
			beattools.test = beattools.test or {}
			beattools.test.compare = {
				orig = compare.orig,
				origStats = compare.origStats,
				new1 = compare.new1,
				new1Stats = compare.new1Stats,
				new1Index = compare.new1Index,
				new2 = compare.new2,
				new2Stats = compare.new2Stats,
				new2Index = compare.new2Index
			}
		end
		imgui.SameLine()
		if imgui.Button("TEST") then
			modlog(mod, compare.getPartBounds(compare.getPart()))
		end

		if imgui.Button("Load Orig" .. (compare.origStats.array and " (Override)" or "")) then
			compare.load()
		end
		if compare.origStats.array then
			if imgui.Button("Load New1" .. (compare.new1Stats.array and " (Override)" or "")) then
				compare.compare()
			end
			if compare.new1Stats.array and not compare.getNextChange() then
				if imgui.Button("Load New2" .. (compare.new2Stats.array and " (Override)" or "")) then
					compare.compare(true)
				end
				if compare.new2Stats.array and not compare.getNextChange(true) then
					if imgui.Button("CHECK MERGE") then
						compare.checkMerge()
					end
				end
			end
		end

		compare.showChanges()
		compare.showChanges(true)

		imgui.End()
	end
end

function compare.sortArray(array)
	table.sort(array, function(a, b)
		local function isDifferent(k) return a[k] ~= b[k] end
		local function getComparison(k) return a[k] < b[k] end
		if type(a) ~= type(b) then return type(a) < type(b) end
		if type(a) == "boolean" then if a == b then return false end return b or not a end
		if type(a) ~= "table" then return a < b end
		if isDifferent("time") then return getComparison("time") end
		if isDifferent("angle") then return getComparison("angle") end
		if isDifferent("type") then return getComparison("type") end
		return tostring(a) < tostring(b)
	end)
end
function compare.convertSet(set)
	return utilitools.table.keysToValues(set)
end
function compare.convertMap(map)
	local array = {}
	for _, v in pairs(map) do table.insert(array, v) end
	return array
end
function compare.convert(stats)
	for k, set in pairs(stats.set) do
		stats.setConverted[k] = compare.convertSet(set)
		compare.sortArray(stats.setConverted[k])
	end
	for k, map in pairs(stats.map) do
		stats.mapConverted[k] = compare.convertMap(map)
		compare.sortArray(stats.mapConverted[k])
	end
end

function compare.inTime(event, part)
	local timeMin, timeMax = compare.getPartBounds(part)
	return (not timeMin or timeMin <= event.time) and (not timeMax or event.time <= timeMax)
end

function compare.load()
	compare.orig = helpers.copy(cs.level.events)
	compare.origStats = {
		array = {},
		set = {
			origEventTypes = {},
			origEases = {}
		},
		setConverted = {},
		map = {
			origIndex = {}
		},
		mapConverted = {}
	}

	for i, event in ipairs(compare.orig) do
		compare.origStats.set.origEventTypes[event.type] = true
		if event.type == "ease" or event.type == "setBoolean" then
			compare.origStats.set.origEases[event.var] = true
		end
		compare.origStats.map.origIndex[tostring(event)] = i
	end

	compare.convert(compare.origStats)

	modlog(mod,
		"\nORIGINAL:",
		"\n\tEVENTS", table.concat(compare.origStats.setConverted.origEventTypes, ", "),
		"\n\tEASES ", table.concat(compare.origStats.setConverted.origEases, ", ")
	)
end

function compare.compare(new2)
	modlog(mod, "STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING")
	local new = helpers.copy(cs.level.events)
	if not new or not compare.orig or #new == 0 or #compare.orig == 0 then modwarn(mod, "FAILED", new, compare.orig) return end

	local part = compare.getPart()

	local newStats = {
		array = {},
		set = {
			newEases = {},
			origEventsMatched = {}, newEventsMatched = {},
			decoIds = {}, decoSprites = {}
		},
		setConverted = {},
		map = {
			newEasesMin = {}, newEasesMax = {},
			newIndex = {},
			linkedNew = {},
			missing = {}, added = {},
			origTypeAdded = {}, origEaseAdded = {}, outsideAdded = {},
			changed = {}, changed2 = {}, angleChanged = {}, outsideChanged = {},
			changedText = {}, changedReason = {},
			decoLastHide = {}
		},
		mapConverted = {},
		total = {},
		part = part
	}

	local function inTime(event)
		return compare.inTime(event, part)
	end
	local function found(event, event2, text)
		newStats.set.origEventsMatched[tostring(event)] = true
		newStats.set.newEventsMatched[tostring(event2)] = true
		local check, reason = utilitools.files.beattools.undo.areSimilar(event, event2, nil, 1)
		if not check then
			if text == "CHANGED ANGLE" then
				if #reason <= 1 then
					newStats.map.angleChanged[tostring(event2)] = event2
				else
					text = "CHANGED"
				end
			end
			if not inTime(event) then
				text = text .. " OUTSIDE"
				newStats.map.outsideChanged[tostring(event2)] = event2
			end
			newStats.map.changed[tostring(event2)] = event
			newStats.map.changed2[tostring(event2)] = event2
			newStats.map.changedText[tostring(event2)] = text
			newStats.map.changedReason[tostring(event2)] = reason
		end
	end
	local function search(event, checks, text)
		for _, event2 in ipairs(new) do
			if not newStats.set.newEventsMatched[tostring(event2)] then
				local valid = true
				if checks then
					for _, check in ipairs(checks) do
						if event[check] ~= event2[check] then
							valid = false break
						end
					end
				else
					valid = utilitools.files.beattools.undo.areSimilar(event, event2)
				end
				if valid then found(event, event2, text) return false end
			end
		end
		return true
	end
	for _, event in ipairs(compare.orig) do
		if search(event) then
			if search(event, { "type", "time", "angle", "var" }, "CHANGED") then
				if search(event, { "type", "time", "var" }, "CHANGED ANGLE") then
				end
			end
		end

		if not newStats.set.origEventsMatched[tostring(event)] then
			newStats.map.missing[tostring(event)] = event
		end
	end
	for i, event2 in ipairs(new) do
		newStats.map.newIndex[tostring(event2)] = i
		newStats.map.linkedNew[tostring(event2)] = cs.level.events[i]
		if not newStats.set.newEventsMatched[tostring(event2)] then
			newStats.map.added[tostring(event2)] = event2
			if not inTime(event2) then
				newStats.map.outsideAdded[tostring(event2)] = event2
			end
			if (event2.type == "ease" or event2.type == "setBoolean") then
				if compare.origStats.set.origEases[event2.var] then
					newStats.map.origEaseAdded[tostring(event2)] = event2
				else
					if not newStats.set.newEases[event2.var] then
						newStats.map.newEasesMin[event2.var] = event2
						newStats.map.newEasesMax[event2.var] = event2
					else
						local min, max = newStats.map.newEasesMin[event2.var], newStats.map.newEasesMax[event2.var]
						if event2.time < min.time then
							newStats.map.newEasesMin[event2.var] = event2
						end
						if max.time + (max.duration or 0) + (max.repeats or 0) * (max.repeatDelay or 1) < event2.time + (event2.duration or 0) + (event2.repeats or 0) * (event2.repeatDelay or 1) then
							newStats.map.newEasesMax[event2.var] = event2
						end
					end
					newStats.set.newEases[event2.var] = true
				end
			elseif event2.type == "deco" then
				newStats.set.decoIds[event2.id] = true
				if event2.sprite then
					newStats.set.decoSprites[event2.sprite] = true
				end
				local lastHide = newStats.map.decoLastHide[event2.id]
				if event2.hide ~= nil and (not lastHide or lastHide.time < event2.time or (lastHide.time == event2.time and (lastHide.order or 0) <= (event2.order or 0))) then
					newStats.map.decoLastHide[event2.id] = event2
				end
			elseif compare.origStats.set.origEventTypes[event2.type] then
				newStats.map.origTypeAdded[tostring(event2)] = event2
			end
		end
	end

	compare.convert(newStats)

	local function addToTotal(event, event2, text, reason)
		table.insert(newStats.total, {
			event = event,
			event2 = event2,
			text = text,
			reason = reason,
			withinTime = inTime(event2 or event)
		})
	end

	local function setColor(event2, r, g, b)
		newStats.map.linkedNew[tostring(event2)].editorOutline = { r = r, g = g, b = b }
	end

	for _, event in ipairs(newStats.mapConverted.missing) do
		addToTotal(event, nil, "MISSING")
	end
	for _, event2 in ipairs(newStats.mapConverted.added) do -- green
		setColor(event2, 0, 255, 0)
	end
	for _, event2 in ipairs(newStats.mapConverted.origTypeAdded) do -- orange
		setColor(event2, 255, 128, 0)
		if not newStats.map.outsideAdded[tostring(event2)] then addToTotal(nil, event2, "ADDED EVENT") end
	end
	for _, event2 in ipairs(newStats.mapConverted.origEaseAdded) do -- yellow
		setColor(event2, 255, 255, 0)
		if not newStats.map.outsideAdded[tostring(event2)] then addToTotal(nil, event2, "ADDED EASE") end
	end
	for _, event2 in ipairs(newStats.mapConverted.changed2) do -- purple
		setColor(event2, 255, 0, 255)
		if not newStats.map.angleChanged[tostring(event2)] and not newStats.map.outsideChanged[tostring(event2)] then
			addToTotal(newStats.map.changed[tostring(event2)], event2, newStats.map.changedText[tostring(event2)], newStats.map.changedReason[tostring(event2)])
		end
	end
	for _, event2 in ipairs(newStats.mapConverted.angleChanged) do -- darkblue
		setColor(event2, 0, 0, 255)
		if not newStats.map.outsideChanged[tostring(event2)] then
			addToTotal(newStats.map.changed[tostring(event2)], event2, newStats.map.changedText[tostring(event2)], newStats.map.changedReason[tostring(event2)])
		end
	end

	for _, event2 in ipairs(newStats.mapConverted.outsideAdded) do -- red
		setColor(event2, 255, 0, 0)
		if not newStats.map.origTypeAdded[tostring(event2)] and not newStats.map.origEaseAdded[tostring(event2)] then
			addToTotal(nil, event2, "ADDED" .. (newStats.map.origTypeAdded[tostring(event2)] and " EVENT" or (newStats.map.origEaseAdded[tostring(event2)] and " EASE" or "")) .. " OUTSIDE")
		end
	end
	for _, event2 in ipairs(newStats.mapConverted.outsideChanged) do -- pink
		setColor(event2, 255, 0, 128)
		addToTotal(newStats.map.changed[tostring(event2)], event2, newStats.map.changedText[tostring(event2)], newStats.map.changedReason[tostring(event2)])
	end

	for _, decoId in ipairs(newStats.setConverted.decoIds) do
		local event2 = newStats.map.decoLastHide[decoId]
		if not event2 or event2.hide ~= true then
			local _, time = compare.getPartBounds(part)
			local newEvent = {
				type = "deco",
				time = time,
				angle = 0,
				id = decoId,
				hide = true
			}
			table.insert(new, newEvent)
			table.insert(cs.level.events, newEvent)
			addToTotal(nil, newEvent, "DECO UNHIDDEN")
		end
	end

	local function printChange(index)
		local change = newStats.total[index]
		if change.resolved then modlog(mod, "resolved") return end
		local temp = change.event2 or change.event
		modlog(mod, index, change.text, temp.time, change.withinTime, temp.angle, utilitools.string.concat(utilitools.string.concat(temp.type, temp.var), temp.id), change.reason and table.concat(change.reason, ", ") or nil)
	end

	for i = 1, #newStats.total do printChange(i) end

	local timeMin, timeMax = compare.getPartBounds(part)

	modlog(mod,
		"\nBOUNDS",
		"\n\tMIN", timeMin, "MAX", timeMax,
		"\nCOMPARING",
		"\n\tMISSING", #newStats.mapConverted.missing,
		"\n\t ADDED ", #newStats.mapConverted.added,
		"\n\t\tEVENTS ", #newStats.mapConverted.origTypeAdded, "added events with event types that already exist in the original",
		"\n\t\t EASES ", #newStats.mapConverted.origEaseAdded, "added events that ease eases from the original",
		"\n\t\tOUTSIDE", #newStats.mapConverted.outsideAdded, "added events outside the beatrange of the dedicated part",
		"\n\tCHANGED", #newStats.mapConverted.changed2,
		"\n\t\t ANGLE ", #newStats.mapConverted.angleChanged, "changed events where only the angle was changed",
		"\n\t\tOUTSIDE", #newStats.mapConverted.outsideChanged, "changed events outside the beatrange of the dedicated part",

		"\nNEW",
		"\n\t   EASES    ", table.concat(newStats.setConverted.newEases, ", "),
		"\n\t  DECO IDS  ", table.concat(newStats.setConverted.decoIds, ", "),
		"\n\tDECO SPRITES", table.concat(newStats.setConverted.decoSprites, ", ")
	)

	compare["new" .. (new2 and "2" or "1")] = new
	compare["new" .. (new2 and "2" or "1") .. "Stats"] = newStats
	compare["new" .. (new2 and "2" or "1") .. "Index"] = 1
	modlog(mod, "DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE! DANDADAN! DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE!")
end

function compare.checkMerge()
	modlog(mod, "STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING")
	if compare.new1Stats.part == compare.new2Stats.part then
		modlog(mod, "SAME PART")
		modlog(mod, "DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE! DANDADAN! DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE!")
		return false
	end
	if compare.new1Stats.part > compare.new2Stats.part then
		compare.new1, compare.new2 = compare.new2, compare.new1
		compare.new1Stats, compare.new2Stats = compare.new2Stats, compare.new1Stats
		compare.new1Index, compare.new2Index = compare.new2Index, compare.new1Index
	end
	for _, ease in ipairs(compare.new1Stats.setConverted.newEases) do
		if compare.new2Stats.set.newEases[ease] then
			local new1 = compare.new1Stats.map.newEasesMax[ease]
			local new2 = compare.new2Stats.map.newEasesMin[ease]
			local new1Time = new1.time + (new1.duration or 0) + (new1.repeats or 0) * (new1.repeatDelay or 1)
			local new2Time = new2.time
			local overlap = new1Time > new2Time or new1.time == new2.time
			if overlap then
				modlog(mod, "EASE", ease, new1.time, new1Time, new2Time, overlap)
			end
		end
	end
	local function checkEvent(event1)
		if compare.new2Stats.map.missing[tostring(event1)] or compare.new2Stats.map.changed[tostring(event1)] then
			modlog(mod, "EVENT", event1.time, event1.angle, event1.type, event1.var)
		end
	end
	for _, event1 in ipairs(compare.new1Stats.mapConverted.missing) do
		checkEvent(event1)
	end
	for _, event1 in ipairs(compare.new1Stats.mapConverted.changed) do
		checkEvent(event1)
	end
	for _, id in ipairs(compare.new1Stats.setConverted.decoIds) do
		if compare.new2Stats.set.decoIds[id] then
			modlog(mod, "DECO ID", id)
		end
	end
	for _, sprite in ipairs(compare.new1Stats.setConverted.decoSprites) do
		if compare.new2Stats.set.decoSprites[sprite] then
			modlog(mod, "DECO SPRITE", sprite)
		end
	end
	modlog(mod, "DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE! DANDADAN! DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE!")
end

return compare