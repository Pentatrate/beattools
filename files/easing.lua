--[[
Different: Split the eases based off of a parameter, like `var` in the ease event
Parallel:  Split the parameter to ease them separately, like `r`, `g`, and `b` in the setColor event

It can be both like in the set paddle event

TODO:
- deco

local decoDefault = {
	["sprite"] = "",
	["parentid"] = "",
	["rotationinfluence"] = 1,
	["orbit"] = false,
	["x"] = 300,
	["y"] = 180,
	["r"] = 0,
	["sx"] = 1,
	["sy"] = 1,
	["ox"] = 0,
	["oy"] = 0,
	["kx"] = 0,
	["ky"] = 0,
	["mirror"] = "none",
	["exclusiveMirror"] = false,
	["drawLayer"] = "fg",
	["drawOrder"] = 0,
	["recolor"] = -1,
	["outline"] = false,
	["hide"] = false,
	["tiling"] = false,
	["uvx"] = 0,
	["uvy"] = 0,
	["uvdx"] = 0,
	["uvdy"] = 0,
	["alphadither"] = false,
	["ditherpercent"] = 1,
	["effectCanvas"] = false,
	["effectCanvasType"] = "recolor",
	["effectCanvasRaw"] = false,
	["ecRecolorR"] = 255,
	["ecRecolorG"] = 255,
	["ecRecolorB"] = 255,
	["ecRecolorA"] = 255

}
local easable = {
	["rotationinfluence"] = true,
	["x"] = true,
	["y"] = true,
	["r"] = true,
	["sx"] = true,
	["sy"] = true,
	["ox"] = true,
	["oy"] = true,
	["kx"] = true,
	["ky"] = true,
	["uvx"] = true,
	["uvy"] = true,
	["uvdx"] = true,
	["uvdy"] = true,
	["ditherpercent"] = true,
	["ecRecolorR"] = true,
	["ecRecolorG"] = true,
	["ecRecolorB"] = true,
	["ecRecolorA"] = true
}
local nonEasable = {
	["sprite"] = true,
	["parentid"] = true,
	["orbit"] = true,
	["mirror"] = true,
	["exclusiveMirror"] = true,
	["drawLayer"] = true,
	["drawOrder"] = true,
	["recolor"] = true,
	["outline"] = true,
	["hide"] = true,
	["tiling"] = true,
	["alphadither"] = true,
	["effectCanvas"] = true,
	["effectCanvasType"] = true,
	["effectCanvasRaw"] = true
}
if easable[k] then
	beattoolsAddEasing("decos", v, i, { k, "duration", "ease" }, v.id, k)
end
if nonEasable[k] then
	beattoolsAddEasing("decos", v, i, { k }, v.id, k)
end
]]

local easing = {
	track = {
		ease = {
			different = "var", parallel = false, duration = { value = true }, start = { value = "start" }, repeats = true,
			params = { value = true, start = true },
			default = function(different)
				local v = beattools.easeList.unsorted.all[different]
				if v == "nil" then return { value = nil } else return { value = v } end
			end
		},
		setColor = {
			different = "color", parallel = true, duration = { r = true, g = true, b = true }, start = false,
			params = { r = true, g = true, b = true },
			default = function(different)
				local v = ({ [0] = 255, [1] = 127, [2] = 191 })[different] or 0
				return { r = v, g = v, b = v }
			end
		},
		paddles = {
			different = "paddle", parallel = true, duration = { newWidth = true, newAngle = true }, start = false,
			params = { newWidth = true, newAngle = true, enabled = true },
			default = function(different) return { enabled = different == 1, newWidth = 70, newAngle = 0 } end
		},
		bookmark = {
			different = false, parallel = false, duration = false, start = false,
			params = { name = true, description = true, r = true, g = true, b = true },
			default = function(different) return { name = "Start", description = "", r = 0, g = 0, b = 0 } end
		},
		forcePlayerSprite = {
			different = false, parallel = true, duration = false, start = false,
			params = { spriteName = true, useFaceStencil = true, shader = true },
			default = function(different) return { spriteName = "" } end
		},
		songNameOverride = {
			different = false, parallel = false, duration = false, start = false,
			params = { newname = true },
			default = function(different) return { newname = nil } end
		}
	},
	convert = {
		paddles = {
			type = false,
			different = function(event) if event.paddle == 0 then return { 1, 2, 3, 4, 5, 6, 7, 8 } else return { event.paddle } end end,
			convert = false
		},
		setBoolean = {
			type = "ease",
			different = false, -- function(event) return { event.var } end, -- same as ease event, no need to specify
			convert = function(event, different, parallel) return { value = event.enable } end,
			params = { enable = true }
		},
		outline = {
			type = "ease",
			different = function(event) return { "outline" } end,
			convert = function(event, different, parallel) return { value = event.enable and event.color or nil } end,
			params = { enable = true }
		},
		hom = {
			type = "ease",
			different = function(event) return { "vfx.hom" } end,
			convert = function(event, different, parallel) return { value = event.enable } end,
			params = { enable = true }
		},
		setBgColor = {
			type = "ease",
			different = function(event)
				local t = {}
				if event.color ~= nil then table.insert(t, "bgColor") end
				if event.voidColor ~= nil then table.insert(t, "voidColor") end
				return t
			end,
			convert = function(event, different, parallel) return { value = event[({ bgColor = "color", voidColor = "voidColor" })[different]] } end,
			params = { color = true, bgColor = true }
		},
		noise = {
			type = "ease",
			different = function(event)
				local t = { "vfx.bgNoise", "vfx.bgNoiseColor" }
				if event.timeStep ~= nil then table.insert(t, "vfx.bgNoiseTimeStep") end
				if event.pixelate ~= nil then table.insert(t, "vfx.bgNoisePixelate") end
				return t
			end,
			convert = function(event, different, parallel) return { value = event[({ ["vfx.bgNoise"] = "chance", ["vfx.bgNoiseColor"] = "color", ["vfx.bgNoiseTimeStep"] = "timeStep", ["vfx.bgNoisePixelate"] = "pixelate" })[different]] } end,
			params = { chance = true, color = true, timeStep = true, pixelate = true }
		},
		toggleParticles = {
			type = "ease",
			different = function(event)
				local t = {}
				if event.block ~= nil then table.insert(t, "vfx.noteParticles.block") end
				if event.miss ~= nil then table.insert(t, "vfx.noteParticles.miss") end
				if event.mine ~= nil then table.insert(t, "vfx.noteParticles.mine") end
				if event.mineHold ~= nil then table.insert(t, "vfx.noteParticles.mineHold") end
				if event.mineHoldHit ~= nil then table.insert(t, "vfx.noteParticles.mineHoldHit") end
				if event.mineHoldEnd ~= nil then table.insert(t, "vfx.noteParticles.mineHoldEnd") end
				if event.side ~= nil then table.insert(t, "vfx.noteParticles.side") end
				return t
			end,
			convert = function(event, different, parallel) return { value = event[({ ["vfx.noteParticles.block"] = "block", ["vfx.noteParticles.miss"] = "miss", ["vfx.noteParticles.mine"] = "mine", ["vfx.noteParticles.mineHold"] = "mineHold", ["vfx.noteParticles.mineHoldHit"] = "mineHoldHit", ["vfx.noteParticles.mineHoldEnd"] = "mineHoldEnd", ["vfx.noteParticles.side"] = "side" })[different]] } end,
			params = { block = true, miss = true, mine = true, mineHold = true, mineHoldHit = true, mineHoldEnd = true, side = true }
		}
	},
	list = {},
	cache = {},
	access = {},
	index = 0
}

function easing.clearCache()
	easing.cache = {}
	easing.access = {}
	easing.index = 0
end

function easing.init()
	easing.list = {}
	easing.clearCache()
end

function easing.getIndex(event)
	return utilitools.files.beattools.undo.events[tostring(event)] or -1
end

function easing.print(arr)
	modlog(mod, "TABLE\n===========================================")
	for i, ease in ipairs(arr) do
		modlog(mod, "\t\t" .. i .. " | " .. tostring(ease.event.time) .. " " .. tostring(ease.event.angle) .. " " .. tostring(ease.event.order) .. " " .. tostring(ease.repeated) .. " | " .. tostring(easing.getIndex(ease.event)) .. (i == #arr and "\n===========================================" or ""))
	end
end

function easing.search(arr, time, order, index, track)
	if index then order = order or 0 end
	local low = 1
	local high = #arr
	if low > high then return 0 end
	local mid
	local r
	local function setLow()
		low = mid + 1
		if low > high then r = mid end
	end
	local function setHigh()
		high = mid - 1
		if low > high then r = mid - 1 end
	end
	while low <= high do
		mid = math.floor((high + low) / 2)
		local event = arr[mid].event
		local midTime = event.time + (arr[mid].repeated and arr[mid].repeated * (event.repeatDelay or 1) or 0)
		if time == midTime then
			if not order then
				setLow() if r then return r end
			else
				order = order or 0
				local midOrder = event.order or 0
				if order == midOrder then
					if not index then
						setLow() if r then return r end
					else
						local midIndex = easing.getIndex(event) or 0
						if index == midIndex then
							return mid
						elseif index < midIndex then
							setHigh() if r then return r end
						else
							setLow() if r then return r end
						end
					end
				elseif order < midOrder then
					setHigh() if r then return r end
				else
					setLow() if r then return r end
				end
			end
		elseif time < midTime then
			setHigh() if r then return r end
		else
			setLow() if r then return r end
		end
	end
	modwarn(mod, "WOAH WHAT HAPPENED ", arr, time, order, index)
	return 0
end

function easing.getArr(event, k, fakeDifferent)
	if type(event) ~= "table" then modwarn(mod, "Not table: ", event, k, fakeDifferent) return end
	if not fakeDifferent and not event.time then modwarn(mod, "No time: ", event, k, fakeDifferent) return end
	if not event.type then modwarn(mod, "No type: ", event, k, fakeDifferent) return end

	local convert = easing.convert[event.type]
	local type = convert and convert.type or event.type
	local track = easing.track[type]
	if not track then if fakeDifferent then modwarn(mod, "No track: ", type, event.type, event, k, fakeDifferent) end return end
	if track.different and not (fakeDifferent or event[track.different] or convert and convert.different) then --[[ modwarn(mod, "No different: ", event, k, fakeDifferent) ]] return end

	local keyCheck
	if not k then keyCheck = true
	elseif ({ time = true, order = true })[k] then keyCheck = true
	elseif track.repeats and ({ repeats = true, repeatDelay = true })[k] then keyCheck = true
	-- elseif track.duration and k == "duration" then param = true -- auto updated via table reference
	elseif track.different and k == track.different then keyCheck = true
	-- convert here
	elseif track.params and track.params[k] then keyCheck = true -- auto updated via table reference, except when converting, ill implement that laterrrrrr
	elseif convert and convert.params and convert.params[k] then keyCheck = true end

	if not keyCheck then
		if track.duration and k == "duration" then easing.clearCache() end
		return
	end

	local differents = track.different and (fakeDifferent and { fakeDifferent } or (convert and convert.different and convert.different(event)) or { event[track.different] }) or { "_" }

	local function init(arr, k2) arr[k2] = arr[k2] or {} return arr[k2] end
	init(easing.list, type)

	local tables = {}
	for _, different in ipairs(differents) do
		local arr = init(easing.list[type], different)
		for parallel, _ in pairs(track.parallel and track.params or { ["_"] = true }) do
			if fakeDifferent or not track.parallel or ((convert and convert.convert and convert.convert(event, different, parallel) or event)[parallel] and (not k or not track.params[k] or parallel == k)) then
				tables[parallel] = tables[parallel] or {}
				table.insert(tables[parallel], init(arr, parallel))
			end
		end
	end
	return tables, track, convert
	--[[ if type == "paddles" and (event.paddle == 0 or fakeDifferent == 0) then
		for i = 1, 8 do
			init(arr, i)
		end

		local arr2 = {}
		for param2, _ in pairs(track.params) do
			if fakeDifferent or (event[param2] and (not k or not track.params[k] or param2 == k)) then
				arr2[param2] = {}
				for i = 1, 8 do
					table.insert(arr2[param2], init(arr[i], param2))
				end
			end
		end
		return arr2, track
	else
		arr = init(arr, different)
		if track.parallel then
			local arr2 = {}
			for param2, _ in pairs(track.params) do
				if fakeDifferent or (event[param2] and (not k or not track.params[k] or param2 == k)) then
					arr2[param2] = { init(arr, param2) }
				end
			end
			return arr2, track
		else
			return { ["_"] = { init(arr, "_") } }, track
		end
	end ]]
end

function easing.cacheEvent(event, remove, k)
	-- if true then return end
	local arr, track, convert = easing.getArr(event, k)
	if not arr or not track then --[[ modwarn(mod, "Invalid input") ]] return end

	local function cache(repeated)
		local function cacheParam(parallel)
			if not arr[parallel] then return end
			for _, list in ipairs(arr[parallel]) do
				local i = easing.search(list, event.time + (repeated and repeated * (event.repeatDelay or 1) or 0), event.order or 0, easing.getIndex(event), track)

				if list[i] and list[i].event == event and list[i].repeated == repeated then
					if remove then
						table.remove(list, i)
						-- modlog(mod, "[" .. parallel .. "] event removed " .. tostring(i))
					else
						-- nothing
						-- modlog(mod, "[" .. parallel .. "] event already exists " .. tostring(i))
					end
				else
					if remove then
						modwarn(mod, "[" .. parallel .. "] failed to remove event " .. tostring(i))
					else
						table.insert(list, i + 1, { event = event, repeated = repeated })
						-- modlog(mod, "[" .. parallel .. "] event inserted " .. tostring(i + 1))
					end
				end
				-- easing.print(arr2)
			end
		end
		if track.parallel then
			for parallel, _ in pairs(arr) do
				cacheParam(parallel)
			end
		else
			cacheParam("_")
		end
	end

	cache()
	if track.repeats and event.repeats and event.repeats > 0 and (not event.repeatDelay or event.repeatDelay >= 0) then
		for i = 1, event.repeats do
			cache(i)
		end
	end

	easing.clearCache()
end

function easing.getEase(eventId, different, time, order, index)
	local arr, track = easing.getArr({ type = eventId }, nil, different or true)
	if not arr or not track or not time then modwarn(mod, "Invalid input") return end
	if cs.level and cs.level.properties and cs.level.properties.loadBeat and time < cs.level.properties.loadBeat then
		time = cs.level.properties.loadBeat
		order = nil
		index = nil
	end
	if cs.level and cs.level.properties and cs.level.properties.startingBeat and time < cs.level.properties.startingBeat then
		time = cs.level.properties.startingBeat
		order = nil
		index = nil
	end
	local keys = table.concat({ eventId, track.different and different or "_", time, order or "_", index or "_" }, " | ")

	while easing.cache[1] and easing.cache[1].time + 1 < love.timer.getTime() do
		local element = table.remove(easing.cache)
		easing.index = easing.index + 1
		easing.access[element.keys] = nil
	end
	if easing.access[keys] then
		local cached = easing.cache[easing.access[keys] - easing.index]
		if not cached then modwarn(mod, "No cache? ", eventId, different, time, order, index) end
		return cached.values, cached.count
	end

	local values = track.default(different)
	local prevValues = track.duration and helpers.copy(values)
	local count = {}
	if track.parallel then
		count.event = {}
		for param, _ in pairs(track.params) do count[param] = { index = 0, total = 0 } end
	else
		count.index = 0
		count.total = 0
	end

	local function get(parallel)
		local list = arr[parallel][1]
		local i = easing.search(list, time, order, index, track)

		if track.parallel then
			count[parallel].total = #list
		else
			count.total = #list
		end

		if list[i] then
			local function get2(param)
				local originalEvent = list[i].event
				local convert = easing.convert[originalEvent.type]
				local event = convert and convert.convert and convert.convert(originalEvent, different, parallel)

				if not event then
					event = {}
					for param2, _ in pairs(track.params) do
						event[param2] = originalEvent[param2]
					end
					event.duration = originalEvent.duration
					event.ease = originalEvent.ease
				end
				event.order = originalEvent.order

				local repeated = list[i].repeated
				event.time = originalEvent.time + (track.repeats and repeated and repeated * originalEvent.repeatDelay or 0)

				if track.parallel then
					count[param].index = i
					count.event[param] = originalEvent
				else
					count.index = i
					count.event = originalEvent
				end

				if track.duration and track.duration[param] and event.duration and event.duration ~= 0 then
					if track.start and track.start[param] and event[track.start[param]] then
						-- start cannot be parallel
						prevValues[param] = event[track.start[param]]
					elseif list[i - 1] then
						prevValues[param] = list[i - 1].event[param]
					elseif i - 1 ~= 0 then
						modwarn(mod, "easing.getEase: This shouldnt happen 2: [", parallel, "] [", param, "] ", eventId, different, time, order, index)
					end

					if type(event[param]) == "number" and type(prevValues[param]) == "number" then
						local completion = helpers.clamp((time - event.time) / event.duration, 0, 1)
						completion = (flux.easing[event.ease] or flux.easing["linear"])(completion)
						local diff = event[param] - prevValues[param]
						values[param] = prevValues[param] + diff * completion
					else
						values[param] = event[param]
						modwarn(mod, "[" .. parallel .. "] [" .. param .. "] NaN " .. values[param])
						event.duration = nil
						event.ease = nil
					end
				else
					values[param] = event[param]
					event.duration = nil
					event.ease = nil
				end


			end

			if track.parallel then get2(parallel) else for param2, _ in pairs(track.params) do get2(param2) end end
		elseif i ~= 0 then
			modwarn(mod, "easing.getEase: This shouldnt happen 2: [", parallel, "] ", eventId, different, time, order, index)
		end
	end

	if track.parallel then for parallel, _ in pairs(arr) do get(parallel) end else get("_") end

	table.insert(easing.cache, { time = love.timer.getTime(), values = values, keys = keys, count = count })
	easing.access[keys] = #easing.cache + easing.index

	return values, count
end

function easing.select(eventId, different)
	local arr, track = easing.getArr({ type = eventId }, nil, different or true)
	if not arr or not track then modwarn(mod, "Invalid input") return end

	local selected = {}
	if cs.multiselect then
		for i = #cs.multiselect.events, 1, -1 do
			local v2 = cs.multiselect.events[i]
			if shouldSelect(v2) then
				table.remove(cs.multiselect.events, i)
				easesDeleted = easesDeleted + (v2.r and 1) + (v2.g and 1) + (v2.b and 1)
				eventsDeleted = eventsDeleted + 1
			end
		end
	elseif cs.selectedEvent then
		if shouldSelect(cs.selectedEvent) then
			easesDeleted = easesDeleted + (cs.selectedEvent.r and 1) + (cs.selectedEvent.g and 1) + (cs)
			eventsDeleted = eventsDeleted + 1
			cs.selectedEvent = nil
		end
	end
end

return easing
