local easing = {}

function easing.search(arr, time, order, index)
	local low = 1
	local high = #arr
	local mid
	local function setLow()
		low = mid + 1
		if low > high then r = mid end
	end
	local function setHigh()
		high = mid - 1
		if low > high then r = mid - 1 end
	end
	local r
	while low <= high do
		mid = math.floor((high + low) / 2)
		if time == arr[mid].event.time then
			if not order and not index then
				setLow() if r then return r end
			else
				order = order or 0
				if order == (arr[mid].event.order or 0) then
					if not index then
						setLow() if r then return r end
					else
						if index == (utilitools.files.beatools.undo.events[tostring(arr[mid].event)] or 0) then
							return mid
						else
							if index < (utilitools.files.beatools.undo.events[tostring(arr[mid].event)] or 0) then
								setHigh() if r then return r end
							else
								setLow() if r then return r end
							end
						end
					end
				else
					if order < (arr[mid].event.order or 0) then
						setHigh() if r then return r end
					else
						setLow() if r then return r end
					end
				end
			end
		else
			if time < arr[mid].event.time then
				setHigh() if r then return r end
			else
				setLow() if r then return r end
			end
		end
	end
	modlog(mod, "WOAH WHAT HAPPENED")
	return -1
end

function easing.insert(arr, v)

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
