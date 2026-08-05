--[[
TODO
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
	new2Index = 1,

	updateColors = true
}
local colors = {
	{ 255, 255, 255 },
	{   0,   0,   0 },
	{ 255,   0,   0 },
	{   0, 255,   0 },
	{   0,   0, 255 },
	{ 255, 255,   0 },
	{ 255,   0, 255 },
	{   0, 255, 255 },

	{ 128, 128, 128 },
	{ 128,   0,   0 },
	{   0, 128,   0 },
	{   0,   0, 128 },
	{ 128, 128,   0 },
	{ 128,   0, 128 },
	{   0, 128, 128 }
}

if beattools and beattools.test and beattools.test.compare then
	modlog(mod, "compare: loading from cache")
	compare = beattools.test.compare
end

compare.parts = {
	velocity = { -1, 132, 260, 420, 596, 788, 948, 1012, 1124 }
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
				return tonumber(g) or "merged"
			end
		end
	end
	return "merged"
end
function compare.getPartBounds(part)
	if part == "merged" then
		return 132, 1012
	end
	return compare.parts[compare.currentCollab][part], compare.parts[compare.currentCollab][part + 1]
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
			local function update()
				index = compare["new" .. (new2 and "2" or "1") .. "Index"]
				change = changes[index]
				temp = change and (change.event2 or change.event)
			end
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
				update()
			end
			imgui.SameLine()
			if imgui.Button("NEW") then
				change.resolved = "NEW"
				jumpToNext()
				update()
			end
			imgui.SameLine()
			if imgui.Button("ALL NEW") then
				for _, change in ipairs(changes) do
					if not change.resolved then change.resolved = "NEW" end
				end
				jumpToNext()
				update()
			end
			--[[ imgui.SameLine()
			if imgui.Button("SPECIAL ORIG") then
				while change and not (change.withinTime) do
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
					update()
				end
			end ]]
			--[[ imgui.SameLine()
			if imgui.Button("SPECIAL NEW") then
				while change and not (temp.type == "ease" and temp.var == "scrollSpeed" and compare.inTime(temp, 5)) do
					change.resolved = "NEW"
					jumpToNext()
					update()
				end
			end ]]
			--[[ imgui.SameLine()
			if imgui.Button("10 NEW") then
				for i = 1, 10 do
					change.resolved = "NEW"
					jumpToNext()
					update()
					index = compare["new" .. (new2 and "2" or "1") .. "Index"]
					change = changes[index]
				end
			end ]]
			--[[ imgui.SameLine()
			if imgui.Button("100 NEW") then
				for i = 1, 100 do
					change.resolved = "NEW"
					jumpToNext()
					update()
					index = compare["new" .. (new2 and "2" or "1") .. "Index"]
					change = changes[index]
				end
			end ]]
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
			compare.updateColors = utilitools.imguiHelpers.inputBool("Change Outline", compare.updateColors, true, "")
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
					if imgui.Button("DO MERGE") then
						compare.merge()
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
			decoIds = {}, decoSprites = {}, textdecoIds = {}
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
			decoLastHide = {}, textdecoLastHide = {}
		},
		mapConverted = {},
		total = {},
		part = part
	}

	local function inTime(event)
		return compare.inTime(event, part)
	end
	local function found(event1, event2, text)
		newStats.set.origEventsMatched[tostring(event1)] = true
		newStats.set.newEventsMatched[tostring(event2)] = true
		local check, reason = utilitools.files.beattools.undo.areSimilar(event1, event2, nil, 1)
		if text and not check then
			if text == "CHANGED ANGLE" then
				if #reason <= 1 then
					newStats.map.angleChanged[tostring(event2)] = event2
				else
					text = "CHANGED"
				end
			end
			if not inTime(event1) then
				text = text .. " OUTSIDE"
				newStats.map.outsideChanged[tostring(event2)] = event2
			end
			newStats.map.changed[tostring(event2)] = event1
			newStats.map.changed2[tostring(event2)] = event2
			newStats.map.changedText[tostring(event2)] = text
			newStats.map.changedReason[tostring(event2)] = reason
		end
	end
	local function search(event1, checks, text)
		for _, event2 in ipairs(new) do
			if not newStats.set.newEventsMatched[tostring(event2)] then
				local valid = true
				if checks then
					for _, check in ipairs(checks) do
						if event1[check] ~= event2[check] then
							valid = false break
						end
					end
				else
					local event1Changed, event2Changed = event1, event2
					if event1.editorOutline then
						event1Changed = helpers.copy(event1)
						event1Changed.editorOutline = nil
					end
					if event2.editorOutline then
						event2Changed = helpers.copy(event2)
						event2Changed.editorOutline = nil
					end
					valid = utilitools.files.beattools.undo.areSimilar(event1Changed, event2Changed)
				end
				if valid then found(event1, event2, text) return false end
			end
		end
		return true
	end

	local progress = { name = "", step = 1, max = 1, index = 0, progressAt = 0.05 }
	local function startProgress(name, max, progressAt, step, index)
		if progress.name ~= "" then
			modlog(mod, "finished", progress.name, utilitools.files.beattools.stopwatch.get())
		end
		if name ~= false then
			progress.name = name or "unnamed"
			progress.max = max or 1
			progress.progressAt = progressAt or progress.progressAt
			progress.step = step or 1
			progress.index = index or 0
			modlog(mod, "starting", progress.name, progress.max)
			utilitools.files.beattools.stopwatch.set()
		end
	end
	local function doProgress(index)
		local prevProgress = progress.index / progress.max

		local newIndex = index or (progress.index + 1)
		local newProgress = newIndex / progress.max

		local prevSection, newSection = math.floor(prevProgress / progress.progressAt), math.floor(newProgress / progress.progressAt)
		if prevSection ~= newSection then
			if prevSection > newSection and newIndex <= 1 then
				modlog(mod, "  reset", progress.name)
			else
				modlog(mod, "  ", progress.name, helpers.round((newProgress - newProgress % progress.progressAt) * 100), "%")
			end
		end

		progress.index = newIndex
	end

	startProgress("ORIG", #compare.orig)
	for i, event in ipairs(compare.orig) do
		doProgress()
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
	startProgress("NEW", #new)
	for i, event2 in ipairs(new) do
		doProgress()
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
			elseif event2.type == "textdeco" then
				newStats.set.textdecoIds[event2.id] = true
				local lastHide = newStats.map.textdecoLastHide[event2.id]
				if event2.hide ~= nil and (not lastHide or lastHide.time < event2.time or (lastHide.time == event2.time and (lastHide.order or 0) <= (event2.order or 0))) then
					newStats.map.textdecoLastHide[event2.id] = event2
				end
			elseif compare.origStats.set.origEventTypes[event2.type] then
				newStats.map.origTypeAdded[tostring(event2)] = event2
			end
		end
	end
	startProgress(false)

	compare.convert(newStats)

	local function addToTotal(event1, event2, text, reason)
		table.insert(newStats.total, {
			event = event1,
			event2 = event2,
			text = text,
			reason = reason,
			withinTime = inTime(event2 or event1)
		})
	end

	local function setColor(event2, r, g, b)
		if not compare.updateColors then return end
		newStats.map.linkedNew[tostring(event2)].editorOutline = { r = r, g = g, b = b }
	end

	do
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
		for _, textdecoId in ipairs(newStats.setConverted.textdecoIds) do
			local event2 = newStats.map.textdecoLastHide[textdecoId]
			if not event2 or event2.hide ~= true then
				local _, time = compare.getPartBounds(part)
				local newEvent = {
					type = "textdeco",
					time = time,
					angle = 0,
					id = textdecoId,
					hide = true
				}
				table.insert(new, newEvent)
				table.insert(cs.level.events, newEvent)
				addToTotal(nil, newEvent, "TEXTDECO UNHIDDEN")
			end
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
		"\n\tDECO SPRITES", table.concat(newStats.setConverted.decoSprites, ", "),
		"\n\tTEXTDECO IDS", table.concat(newStats.setConverted.textdecoIds, ", ")
	)

	compare["new" .. (new2 and "2" or "1")] = new
	compare["new" .. (new2 and "2" or "1") .. "Stats"] = newStats
	compare["new" .. (new2 and "2" or "1") .. "Index"] = 1
	modlog(mod, "DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE! DANDADAN! DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE!")
end

function compare.checkMerge()
	modlog(mod, "STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING")
	modlog(mod, compare.new1Stats.part, compare.new2Stats.part, compare.getPartBounds(compare.new1Stats.part), compare.getPartBounds(compare.new2Stats.part), nil)
	if compare.new1Stats.part == compare.new2Stats.part then
		modlog(mod, "SAME PART")
		modlog(mod, "DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE! DANDADAN! DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE!")
		return false
	end
	if compare.getPartBounds(compare.new1Stats.part) > compare.getPartBounds(compare.new2Stats.part) then
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
		if compare.new2Stats.map.missing[tostring(event1)] then
			modlog(mod, "EVENT", event1.time, event1.angle, event1.type, event1.var)
		end
	end
	local function checkEvent2(event2)
		if compare.new2Stats.map.changed2[tostring(event2)] then
			modlog(mod, "EVENT", event2.time, event2.angle, event2.type, event2.var)
		end
	end
	for _, event1 in ipairs(compare.new1Stats.mapConverted.missing) do
		checkEvent(event1)
	end
	for _, event2 in ipairs(compare.new1Stats.mapConverted.changed2) do
		checkEvent2(event2)
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
	for _, id in ipairs(compare.new1Stats.setConverted.textdecoIds) do
		if compare.new2Stats.set.textdecoIds[id] then
			modlog(mod, "TEXTDECO ID", id)
		end
	end
	modlog(mod, "DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE! DANDADAN! DONE! DONE! DONE! DONE! DONE! DONEDODONE! DONE! DONE! DONE! DONE! DONE!")
end

function compare.merge()
	modlog(mod, "start=========================================================")
	local merged = helpers.copy(compare.orig)
	local toRemove = {}
	setmetatable(merged, nil)
	function eventIndex(event)
		if event == nil then
			modwarn(mod, "NO EVENT")
			return -1
		end
		for i, v in ipairs(compare.orig) do
			if v == event then return i end
		end
		modlog(mod, "compare.merge: couldnt find event", event)
		return -1
	end
	local function setColor(event, r, g, b)
		event.editorOutline = { r = r, g = g, b = b }
	end
	local function getColor(new2)
		local newStats = compare["new" .. (new2 and "2" or "1") .. "Stats"]
		if type(newStats.part) ~= "number" then
			return
		end
		return unpack(colors[newStats.part % #colors])
	end
	local function doRemove(event1)
		table.insert(toRemove, { i = eventIndex(event1), event = event1 })
	end
	local function doAdd(event2, new2)
		event2 = helpers.copy(event2)
		if getColor(new2) then
			setColor(event2, getColor(new2))
		end
		table.insert(merged, event2)
	end
	local function doChange(event2, new2)
		doRemove(compare["new" .. (new2 and "2" or "1") .. "Stats"].map.changed[tostring(event2)])
		doAdd(event2, new2)
	end
	for _, event2 in ipairs(compare.new1Stats.mapConverted.changed2) do doChange(event2) end
	for _, event2 in ipairs(compare.new2Stats.mapConverted.changed2) do doChange(event2, true) end

	for _, event1 in ipairs(compare.new1Stats.mapConverted.missing) do doRemove(event1) end
	for _, event1 in ipairs(compare.new2Stats.mapConverted.missing) do doRemove(event1) end

	for _, event2 in ipairs(compare.new1Stats.mapConverted.added) do doAdd(event2) end
	for _, event2 in ipairs(compare.new2Stats.mapConverted.added) do doAdd(event2, true) end

	table.sort(toRemove, function(a, b) return a.i < b.i end)
	for i = #toRemove, 1, -1 do
		local check, reason = utilitools.files.beattools.undo.areSimilar(toRemove[i].event, merged[toRemove[i].i])
		if not check then
			modlog(mod, toRemove[i].i, reason)
		end
		table.remove(merged, toRemove[i].i)
	end

	cs.level.events = merged
	modlog(mod, compare.new1Stats.part, getColor(false))
	modlog(mod, "end=========================================================", #cs.level.events, compare.new2Stats.part, getColor(true))
end

return compare