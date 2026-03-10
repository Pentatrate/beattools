--[[
Different: Split the eases based off of a parameter, like `var` in the ease event
Parallel:  Split the parameter to ease them separately, like `r`, `g`, and `b` in the setColor event

It can be both like in the set paddle event

TODO:
- ease: repeats
]]

local easing = {
	track = {
		ease = { different = "var", parallel = false, duration = { value = true }, start = { value = "start" }, params = { value = true, start = true } },
		setColor = { different = "color", parallel = true, duration = { r = true, g = true, b = true }, start = false, params = { r = true, g = true, b = true } },
		paddles = { different = "paddle", parallel = true, duration = { newWidth = true, newAngle = true }, start = false, params = { newWidth = true, newAngle = true, enabled = true } },
		bookmark = { different = false, parallel = false, duration = false, start = false, params = { name = true, description = true, r = true, g = true, b = true } },
		forcePlayerSprite = { different = false, parallel = true, duration = false, start = false, params = { spriteName = true, useFaceStencil = true, shader = true } },
		songNameOverride = { different = false, parallel = false, duration = false, start = false, params = { newname = true } }
	},
	list = {},
	cache = {},
	access = {},
	index = 0
}

function easing.convert(event)

end

function easing.default(eventId, different)
	local defaults = {
		ease = function()
			local v = beattools.easeList.unsorted.all[different]
			if v == "nil" then return { value = nil } else return { value = v } end
		end,
		setColor = function()
			local v = 0
			if different == 0 then v = 255
			elseif different == 2 then v = 127
			elseif different == 3 then v = 191 end
			return { r = v, g = v, b = v }
		end,
		paddles = function()
			return { enabled = different == 1, newWidth = 70, newAngle = 0 }
		end,
		bookmark = function()
			return { name = "Start", description = "", r = 0, g = 0, b = 0 }
		end,
		forcePlayerSprite = function()
			return { spriteName = "" }
		end,
		songNameOverride = function()
			return { newname = nil }
		end
	}
	if defaults[eventId] then return defaults[eventId]() end
	modwarn(mod, "easing.default: No default for event ", eventId, " and different ", different)
end

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
	return utilitools.files.beattools.undo.events[tostring(event)]
end

function easing.print(arr)
	modlog(mod, "TABLE\n===========================================")
	for i, ease in ipairs(arr) do
		modlog(mod, "\t\t" .. i .. " | " .. tostring(ease.event.time) .. " " .. tostring(ease.event.angle) .. " " .. tostring(ease.event.order) .. " | " .. tostring(easing.getIndex(ease.event)) .. (i == #arr and "\n===========================================" or ""))
	end
end

function easing.search(arr, time, order, index)
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
		local midTime = arr[mid].event.time
		if time == midTime then
			if not order then
				setLow() if r then return r end
			else
				order = order or 0
				local midOrder = arr[mid].event.order or 0
				if order == midOrder then
					if not index then
						setLow() if r then return r end
					else
						local midIndex = easing.getIndex(arr[mid].event) or 0
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
	modlog(mod, "WOAH WHAT HAPPENED")
	return 0
end

function easing.getArr(event, k, fakeDifferent)
	if type(event) ~= "table" then modwarn(mod, "Not table: ", event, k, fakeDifferent) return end
	if not fakeDifferent and not event.time then modwarn(mod, "No time: ", event, k, fakeDifferent) return end
	if not event.type then modwarn(mod, "No type: ", event, k, fakeDifferent) return end

	local track = easing.track[event.type]
	if not track then if fakeDifferent then modwarn(mod, "No track: ", event.type, event, k, fakeDifferent) end return end
	if track.different and not (fakeDifferent or event[track.different]) then modwarn(mod, "No different: ", event, k, fakeDifferent) return end

	local param
	if not k then param = true
	elseif ({ time = true, order = true })[k] then param = true
	-- elseif track.duration and k == "duration" then param = true -- auto updated via table reference
	elseif track.different and k == track.different then param = true
	-- convert here
	elseif track.params and track.params[k] then param = true end -- auto updated via table reference, except when converting, ill implement that laterrrrrr

	if not param then
		if track.duration and k == "duration" then easing.clearCache() end
		return
	end

	local function init(arr, k2) arr[k2] = arr[k2] or {} return arr[k2] end
	local arr = easing.list
	local different = track.different and (fakeDifferent or event[track.different])

	-- convert here
	if event.type == "paddles" and (event.paddle == 0 or fakeDifferent == 0) then
		arr = init(arr, event.type)
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
		arr = init(arr, event.type)
		arr = init(arr, track.different and (fakeDifferent or event[track.different]) or "_")
		if track.parallel then
			local arr2 = {}
			-- convert here
			for param2, _ in pairs(track.params) do
				if fakeDifferent or (event[param2] and (not k or not track.params[k] or param2 == k)) then
					arr2[param2] = { init(arr, param2) }
				end
			end
			return arr2, track
		else
			return { ["_"] = { init(arr, "_") } }, track
		end
	end
end

function easing.cacheEvent(event, remove, k)
	-- if true then return end
	local arr, track = easing.getArr(event, k)
	if not arr or not track then return end

	local function cache(param)
		if not arr[param] then return end
		for _, list in ipairs(arr[param]) do
			local i = easing.search(list, event.time, event.order or 0, easing.getIndex(event))

			if list[i] and list[i].event == event then
				if remove then
					table.remove(list, i)
					-- modlog(mod, "[" .. param .. "] event removed " .. tostring(i))
				else
					-- nothing
					-- modlog(mod, "[" .. param .. "] event already exists " .. tostring(i))
				end
			else
				if remove then
					modlog(mod, "[" .. param .. "] failed to remove event " .. tostring(i))
				else
					table.insert(list, i + 1, { event = event })
					-- modlog(mod, "[" .. param .. "] event inserted " .. tostring(i + 1))
				end
			end
			-- easing.print(arr2)
		end
	end
	if track.parallel then
		for param, _ in pairs(arr) do
			cache(param)
		end
	else
		cache("_")
	end

	easing.clearCache()
end

function easing.getEase(eventId, different, time, order, index)
	local arr, track = easing.getArr({ type = eventId }, nil, different or true)
	if not arr or not track or not time then return end
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

	local values = easing.default(eventId, different)
	local prevValues = track.duration and helpers.copy(values)
	local count = {}
	if track.parallel then
		count.event = {}
		for param, _ in pairs(track.params) do count[param] = { index = 0, total = 0 } end
	else
		count.index = 0
		count.total = 0
	end

	local function get(param)
		local list = arr[param][1]
		local i = easing.search(list, time, order, index)

		if count[param] then count[param].total = #list end

		if list[i] then
			local function get2(param2)
				local event = list[i].event

				if track.parallel then
					count[param2].index = i
					count[param2].total = #list
					count.event[param2] = event
				else
					count.index = i
					count.total = #list
					count.event = event
				end

				-- convert here
				if track.duration and track.duration[param2] and event.duration and event.duration ~= 0 then
					if track.start and track.start[param2] and event[track.start[param2]] then
						-- start cannot be parallel
						prevValues[param2] = event[track.start[param2]]
					elseif list[i - 1] then
						prevValues[param2] = list[i - 1].event[param2]
					elseif i - 1 ~= 0 then
						modwarn(mod, "easing.getEase: This shouldnt happen 2: [", param, "] [", param2, "] ", eventId, different, time, order, index)
					end

					if type(event[param2]) == "number" and type(prevValues[param2]) == "number" then
						local completion = helpers.clamp((time - event.time) / event.duration, 0, 1)
						completion = (flux.easing[event.ease] or flux.easing["linear"])(completion)
						local diff = event[param2] - prevValues[param2]
						values[param2] = prevValues[param2] + diff * completion
					else
						values[param2] = event[param2]
						modlog(mod, "[" .. param .. "] [" .. param2 .. "] NaN " .. values[param2])
					end
				else
					values[param2] = event[param2]
				end
				-- modlog(mod, "[" .. param .. "] [" .. param2 .. "] " .. values[param2])
			end

			if track.parallel then get2(param) else for param2, _ in pairs(track.params) do get2(param2) end end
		elseif i ~= 0 then
			modwarn(mod, "easing.getEase: This shouldnt happen 2: [", param, "] ", eventId, different, time, order, index)
		end
	end

	if track.parallel then for param, _ in pairs(arr) do get(param) end else get("_") end

	table.insert(easing.cache, { time = love.timer.getTime(), values = values, keys = keys, count = count })
	easing.access[keys] = #easing.cache + easing.index

	return values, count
end

return easing
