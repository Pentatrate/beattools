--[[
Different: Split the eases based off of a parameter, like `var` in the ease event
Parallel:  Split the parameter to ease them separately, like `r`, `g`, and `b` in the setColor event
]]

local easing = {
	track = {
		ease = { different = "var", parallel = false, duration = true, params = { value = true, start = true } }
	},
	list = {}
}

function easing.init()
	easing.list = {}
end

function easing.getIndex(event)
	return utilitools.files.beattools.undo.events[tostring(event)]
end

function easing.print(arr)
	modlog(mod, "===========================================")
	for i, ease in ipairs(arr) do
		modlog(mod, i .. " | " .. tostring(ease.event.time) .. " " .. tostring(ease.event.angle) .. " " .. tostring(ease.event.order) .. " | " .. tostring(easing.getIndex(ease.event)))
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

function easing.getArr(event, k)
	if type(event) ~= "table" then return end
	if not event.time then return end
	if not event.type then return end

	local track = easing.track[event.type]
	if not track then return end
	if track.different and not event[track.different] then return end

	local param
	if not k then param = true
	elseif ({ time = true, order = true })[k] then param = true
	elseif track.duration and k == "duration" then param = true
	elseif track.different and k == track.different then param = true
	elseif track.params and track.params[k] then param = true end

	if param then
		local function init(arr, k2) arr[k2] = arr[k2] or {} return arr[k2] end
		local arr = easing.list
		arr = init(arr, event.type)
		arr = init(arr, track.different and event[track.different] or "_")
		if track.parallel then
			local arr2 = {}
			for param2, _ in pairs(track.params) do
				arr2[param2] = init(arr, param2)
			end
			return arr2, track
		else
			return { ["_"] = init(arr, "_") }, track
		end
	end
end

function easing.createEase(event, track, param)
	local arr = { event = event, values = {} }

	if track.duration and event.duration then arr.values.duration = event.duration end
	if track.parallel then
		if event[param] == nil then return end -- exclude false

		arr.values[param] = event[param]
	else
		for param2, _ in pairs(track.params) do

		end
	end
	return arr
end

function easing.cacheEvent(event, remove, k)
	if true then return end
	local arr, track = easing.getArr(event, k)
	if not arr or not track then return end

	for param, _ in pairs(track.params) do
		local arr2 = arr[param]
		local i = easing.search(arr2, event.time, event.order or 0, easing.getIndex(event))

		if arr2[i] and arr2[i].event == event then
			if remove then
				table.remove(arr2, i)
			else
				-- nothing
			end
		else
			if remove then
				modlog(mod, "[" .. param .. "] failed to remove event " .. tostring(i))
			else
				local ease = easing.createEase(event, track, param)
				if ease then table.insert(arr2, i + 1, ease) end
			end
		end
		easing.print(arr2)
	end
end

-- local t = { { event = { time = 1 } }, { event = { time = 2 } }, { event = { time = 2 } }, { event = { time = 3 } }, { event = { time = 4 } } }
-- local function f(v)
-- 	local i = easing.search(t, v)
-- 	local e = (t[i] or { time = "default" })
-- 	modlog(mod, i .. " " .. e.time .. " " .. v)
-- end
-- f(0.5)
-- f(1)
-- f(1.5)
-- f(2)
-- f(2.5)
-- f(3)
-- f(3.5)
-- f(4)
-- f(4.5)

return easing
