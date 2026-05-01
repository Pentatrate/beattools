local intersection = {
	dontAdd = {
		startTime = true, endTime = true
	}
}

function intersection.root(a, r)
	if a >= 0 then
		return a ^ (1/r)
	elseif r % 2 == 1 then
		return -((-a) ^ (1/r))
	else
		modwarn(mod, "intersection.root: non real root", a, r)
		return
	end
end
function intersection.noDuplicates(t)
	t = utilitools.table.valuesToKeys(t)
	t = utilitools.table.keysToValues(t)
	table.sort(t)
	return t
end

function intersection.inTime(func, time)
	if func.startTime and time < func.startTime then
		return false
	end
	if func.endTime and time > func.endTime then
		return false
	end
	return true
end
function intersection.isTimeOverlapping(func1, func2, full)
	if func1.startTime and func2.endTime and (full and func1.startTime > func2.endTime or not full and func1.startTime >= func2.endTime) then
		return false
	end
	if func2.startTime and func1.endTime and (full and func2.startTime > func1.endTime or not full and func2.startTime >= func1.endTime) then
		return false
	end
	return true
end
function intersection.isTimeIdentical(func1, func2)
	return func1.startTime == func2.startTime and func1.endTime == func2.endTime
end
function intersection.getOverlappingTime(func1, func2)
	local startTime = (func1.startTime or func2.startTime) and math.max(func1.startTime or func2.startTime, func2.startTime or func1.startTime) or nil
	local endTime = (func1.endTime or func2.endTime) and math.min(func1.endTime or func2.endTime, func2.endTime or func1.endTime) or nil
	return startTime, endTime
end
function intersection.forceTimeIdentical(func1, func2)
	local startTime, endTime = intersection.getOverlappingTime(func1, func2)
	func1.startTime = startTime
	func2.startTime = startTime
	func1.endTime = endTime
	func2.endTime = endTime
end
function intersection.cutOut(func, startTime, endTime)
	func = helpers.copy(func)
	local fake = { startTime = startTime, endTime = endTime }
	if (not startTime and not endTime) or (intersection.inTime(fake, func.startTime) and intersection.inTime(fake, func.endTime)) then
		-- modwarn(mod, "complete cutout", func, startTime, endTime)
		return {}
	end
	if not intersection.isTimeOverlapping(func, fake) then return { func } end
	local startOverlap, endOverlap = intersection.getOverlappingTime(func, fake)
	local funcs = {}
	if func.startTime < startOverlap then
		local func2 = helpers.copy(func)
		func2.endTime = startOverlap
		table.insert(funcs, func2)
		if func2.startTime == func2.endTime then
			modwarn(mod, "SAME TIMESSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSsss")
		end
	end
	if endOverlap < func.endTime then
		local func2 = helpers.copy(func)
		func2.startTime = endOverlap
		table.insert(funcs, func2)
		if func2.startTime == func2.endTime then
			modwarn(mod, "SAME TIMESSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSsss")
		end
	end
	return funcs
end
function intersection.getXor(func1, func2)
	local startTime, endTime = intersection.getOverlappingTime(func1, func2)
	local funcs1 = {}
	local funcs2 = {}
	if not intersection.isTimeIdentical(func1, { startTime = startTime, endTime = endTime }) then
		funcs1 = intersection.cutOut(func1, startTime, endTime)
	end
	if not intersection.isTimeIdentical(func2, { startTime = startTime, endTime = endTime }) then
		funcs2 = intersection.cutOut(func2, startTime, endTime)
	end
	return funcs1, funcs2
end
function intersection.remove(funcs, startTime, endTime)
	local fake = { startTime = startTime, endTime = endTime }
	local returnFuncs = {}
	for _, func in ipairs(funcs) do
		if intersection.isTimeOverlapping(func, fake) then
			for _, func2 in ipairs(intersection.cutOut(func, startTime, endTime)) do
				table.insert(returnFuncs, func2)
			end
		else
			table.insert(returnFuncs, func)
		end
	end
	return returnFuncs
end
function intersection.cutOutFromFuncs(funcs, startTime, endTime)
	local fake = { startTime = startTime, endTime = endTime }
	local returnFuncs = {}
	for _, func in ipairs(funcs) do
		if intersection.isTimeOverlapping(func, fake) then
			local cutOut = intersection.cutOut(func, startTime, endTime)
			for _, func2 in ipairs(cutOut) do
				table.insert(returnFuncs, func2)
			end
		else
			table.insert(returnFuncs, func)
		end
	end
	return returnFuncs
end

function intersection.useFunc(func, time)
	if not intersection.inTime(func, time) then
		modwarn(mod, "TIME NOT WITHIN FUNCTION", func, time)
	end
	local value = 0
	for i = 0, 5 do
		value = value + (func["a" .. i] or 0) * (time ^ i)
	end
	return value
end
function intersection.useFuncs(funcs, time)
	for _, func in ipairs(funcs) do
		if intersection.inTime(func, time) then
			return intersection.useFunc(func, time)
		end
	end
end
function intersection.derive(func)
	local func2 = helpers.copy(func)
	for i = 1, 5 do func2["a" .. (i - 1)] = func["a" .. i] and func["a" .. i] ~= 0 and (func["a" .. i] or 0) * i or nil end
	return func2
end

function intersection.validateFunctions(funcs, fullEvaluation)
	for i, func in ipairs(funcs) do
		if func.startTime and func.startTime == func.endTime then
			return false
		end
		local prevFunc = funcs[i - 1]
		if prevFunc then
			local prevVal = intersection.useFunc(prevFunc, prevFunc.endTime)
			local nextVal = intersection.useFunc(func, func.startTime)
			local diff = math.abs(nextVal - prevVal)
			if prevFunc.endTime ~= func.startTime or (fullEvaluation and diff > 1e-9) then
				if prevFunc.endTime == func.startTime then
					modwarn(mod, "NOT GLUED", i, func.startTime, prevVal, nextVal, math.abs(nextVal - prevVal), prevFunc, func)
				end
				-- modwarn(mod, "NOT VALID", i, prevFunc.endTime, func.startTime, math.abs(nexVal - prevVal), funcs)
				return false, prevFunc.endTime ~= func.startTime and "prev endTime ~= current startTime" or "not glued"
			end
		end
	end
	return true
end
function intersection.functionIdentical(func1, func2)
	for i = 0, 5 do
		if func1["a" .. i] ~= func2["a" .. i] then
			return false
		end
	end
	return true
end
function intersection.glueFuncsTogether(funcs)
	for i, func in ipairs(funcs) do
		if func.startTime and func.startTime == func.endTime then
			return false
		end
		local prevFunc = funcs[i - 1]
		if prevFunc then
			local prevVal = intersection.useFunc(prevFunc, prevFunc.endTime)
			local nexVal = intersection.useFunc(func, func.startTime)
			local diff = math.abs(nexVal - prevVal) % 360
			if diff > 180 then diff = math.abs(diff - 360) end
			if prevFunc.endTime ~= func.startTime or (true and diff > 1e-9) then
				-- modwarn(mod, "NOT VALID", i, prevFunc.endTime, func.startTime, prevVal, nexVal, math.abs(nexVal - prevVal), funcs)
				return false
			end
		end
	end
	local i = 1
	while funcs[i] do
		local func1 = funcs[i]

		local j = 1
		while funcs[j] do
			local func2 = funcs[j]

			if func1 ~= func2 and intersection.isTimeOverlapping(func1, func2, true) and intersection.functionIdentical(func1, func2) then
				func1.startTime = math.min(func1.startTime, func2.startTime)
				func1.endTime = math.max(func1.endTime, func2.endTime)
				table.remove(funcs, j)
				j = j - 1
			end

			j = j + 1
		end
		i = i + 1
	end
	return funcs
end
function intersection.sort(funcs, dontValidate)
	table.sort(funcs, function(a, b)
		if not b.startTime then
			return false
		end
		if not a.startTime then
			return true
		end
		return a.startTime < b.startTime
	end)
	if not dontValidate and not intersection.validateFunctions(funcs) then
		modwarn(mod, "INVALID FUNCS", funcs)
	end
end

function intersection.intersectConstant(a0)
	if not a0 or a0 == 0 then
		return -- infinite intersections
	else
		return {} -- no intersections
	end
end
function intersection.intersectLinear(a1, a0)
	if a1 == 0 then -- why are you even using this function then lol
		return intersection.intersectConstant(a0)
	elseif a0 == 0 then
		return intersection.noDuplicates({ 0, unpack(intersection.intersectConstant(a1) or {}) })
	end
	-- a1*x + a0 = 0
	-- x = -a0/a1
	return { -a0 / a1 }
end
function intersection.intersectQuad(a2, a1, a0)
	if a2 == 0 then -- why are you even using this function then lol
		return intersection.intersectLinear(a1, a0)
	elseif a0 == 0 then
		return intersection.noDuplicates({ 0, unpack(intersection.intersectLinear(a2, a1) or {}) })
	end
	local a, b, c = a2, a1, a0
	-- ax² + bx + c = 0
	-- x1 = (-b + sqrt(b² - 4ac)) / (2a)
	-- x2 = (-b - sqrt(b² - 4ac)) / (2a)
	local discriminant = b*b - 4 * a * c
	local vertex = -b / (2 * a)
	if discriminant < 0 then
		return {} -- no intersections
	elseif discriminant == 0 then
		return { vertex }
	elseif discriminant > 0 then
		return { vertex + intersection.root(discriminant, 2) / (2 * a), vertex - intersection.root(discriminant, 2) / (2 * a) }
	end
end
function intersection.intersectCubic(a3, a2, a1, a0)
	if a3 == 0 then -- why are you even using this function then lol
		return intersection.intersectQuad(a2, a1, a0)
	elseif a0 == 0 then
		return intersection.noDuplicates({ 0, unpack(intersection.intersectQuad(a3, a2, a1) or {}) })
	end
	local a, b, c, d = a3, a2, a1, a0
	-- https://en.wikipedia.org/wiki/Cubic_equation
	-- convert to depressed
	local p = (3 * a * c - b * b) / (3 * a * a)
	local q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (27 * a * a * a)
	local discriminant = -(4 * p * p * p + 27 * q * q)
	local roots = {}

	if discriminant == 0 then -- if discriminant is zero and all coefficients are real, all roots are real
		if p == 0 then
			roots = { 0 } -- triple root
		else
			roots = { (3 * q) / p, -(3 * q) / (2 * p) } -- single + double root
		end
	elseif discriminant < 0 then
		-- Cardano's formula
		local u1 = -q / 2 + intersection.root((q * q) / 4 + (p * p * p) / 27, 2)
		local u2 = -q / 2 - intersection.root((q * q) / 4 + (p * p * p) / 27, 2)
		roots = { intersection.root(u1, 3) + intersection.root(u2, 3) } -- single real root + 2 non real roots
	elseif discriminant > 0 then -- all root are real
		-- modlog(mod, "casus irreducibilis?", p)
		-- casus irreducibilis when there is no rational root
		local function tk(k)
			return 2 * intersection.root(-p / 3, 2) * math.cos(1 / 3 * math.acos((3 * q) / (2 * p) * intersection.root(-3 / p, 2)) - (2 * math.pi * k) / 3)
		end
		roots = { tk(0), tk(1), tk(2) }
	end

	for i, t in ipairs(roots) do
		-- x = t - b / (3 * a)
		roots[i] = t - b / (3 * a)
	end
	return roots
end
function intersection.intersectQuartic(a4, a3, a2, a1, a0)
	if a4 == 0 then -- why are you even using this function then lol
		return intersection.intersectCubic(a3, a2, a1, a0)
	elseif a0 == 0 then
		return intersection.noDuplicates({ 0, unpack(intersection.intersectCubic(a4, a3, a2, a1) or {}) })
	end

	-- https://en.wikipedia.org/wiki/Quartic_function
	local b, c, d, e = a3 / a4, a2 / a4, a1 / a4, a0 / a4
	-- convert to depressed
	-- y⁴ + py² + qy + r
	local p = (8 * c - 3 * b * b) / 8
	local q = (b * b * b - 4 * b * c + 8 * d) / 8
	local r = (-3 * b * b * b * b + 256 * e - 64 * b * d + 16 * b * b * c) / 256

	local roots = {}
	if r == 0 then
		roots = intersection.noDuplicates({ 0, unpack(intersection.intersectCubic(1, 0, p, q) or {}) })
	elseif q == 0 then -- biquadratic
		-- x⁴ + p*x² + r
		-- z = x²
		-- z² + p*z + r
		local zRoots = intersection.intersectQuad(1, p, r)
		if zRoots then
			for _, z in ipairs(zRoots) do
				-- z = +-sqrt(z)
				if z >= 0 then
					local sqrt = intersection.root(z, 2)
					table.insert(roots, sqrt)
					table.insert(roots, -sqrt)
				end
			end
			roots = intersection.noDuplicates(roots)
		else
			roots = nil
		end
	else
		-- resolvent qubic
		-- 8n³ + 8pn² + (2p² - 8r)n - q² = 0
		local nRoots = intersection.intersectCubic(8, 8 * p, 2 * p * p - 8 * r, q * q)
		-- choose one of the mRoots, if n ~= 0
		-- this is always possible unless it is a easier special case and gets resolved beforehand already
		local n
		if nRoots then
			for _, n2 in ipairs(nRoots) do
				if n2 ~= 0 then n = n2 break end
			end
		end

		if n then
			local plusMinus = { -1, 1 }
			for pm1 in ipairs(plusMinus) do
				for pm2 in ipairs(plusMinus) do
					table.insert(roots, pm1 * intersection.root(2 * n, 2) + pm2 * intersection.root(-(2 * p + 2 * n + pm1 * intersection.root(2, 2) * q / intersection.root(n, 2)), 2))
				end
			end
			roots = intersection.noDuplicates(roots)
		else
			modwarn(mod, "WAHT", a4, a3, a2, a1, a0, "bcde", b, c, d, e, "pqr", 1, 0, p, q, r, "rootshift", -b / 4, "mRoots", nRoots, "mEquation", 8, 8 * p, 2 * p * p - 8 * r, q * q)
		end
	end
	local roots2 = helpers.copy(roots)
	if roots then
		for i, root in ipairs(roots) do
			-- convert back from depressed
			-- x = y - b / 4
			roots[i] = root - b / 4
		end
	end
	return roots
end
--[[ function intersection.intersectQuintic(a5, a4, a3, a2, a1, a0)
	if a5 == 0 then -- why are you even using this function then lol
		return intersection.intersectQuartic(a4, a3, a2, a1, a0)
	elseif a0 == 0 then
		return intersection.noDuplicates({ 0, unpack(intersection.intersectQuartic(a5, a4, a3, a2, a1) or {}) })
	end

	-- https://en.wikipedia.org/wiki/Quintic_function
	local a, b, c, d, e, f = a5, a4, a3, a2, a1, a0
	-- convert to depressed
	-- y⁴ + py² + qy + r
	local p = (5 * a * c - 2 * b * b) / (5 * a * a)
	local q = (25 * a * a * d - 15 * a * b * c + 4 * b * b * b) / (25 * a * a * a)
	local r = (125 * a * a * a * e - 50 * a * a * b * d + 15 * a * b * b * c - 3 * b * b * b * b) / (125 * a * a * a * a)
	local s = (3125 * a * a * a * a * f - 625 * a * a * a * b * e + 125 * a * a * b * b * d - 25 * a * b * b * b * c + 4 * b * b * b * b * b) / (3125 * a * a * a * a * a)

	local roots = {}

	local roots2 = helpers.copy(roots)
	if roots then
		for i, root in ipairs(roots) do
			-- convert back from depressed
			-- x = y - b / 5a
			roots[i] = root - b / (5 * a)
		end
	end
	modlog(mod, "ROOTS", a4, a3, a2, a1, a0, "bcde", b, c, d, e, "pqr", 1, 0, p, q, r, "rootshift", -b / (5 * a), "roots", roots2, roots)
	return roots
end ]]

function intersection.intersect(func)
	local intersections
	-- for now, only polynomial functions are defined
	intersections = intersection.intersectQuartic(func.a4 or 0, func.a3 or 0, func.a2 or 0, func.a1 or 0, func.a0 or 0)
	if intersections then
		local times = {}
		for i, time in ipairs(intersections) do
			if intersection.inTime(func, time) then
				table.insert(times, time)
			end
		end
		times = intersection.noDuplicates(times)
		return times
	else
		return -- always intersect
	end
end

function intersection.getCriticalPoints(func)
	local derivative = intersection.derive(func)
	local candidates = intersection.intersect(derivative) or {} -- if all intersect then just say none do
	table.insert(candidates, intersection.useFunc(func, func.startTime))
	table.insert(candidates, intersection.useFunc(func, func.endTime))
	return intersection.noDuplicates(candidates)
end
function intersection.getHighest(func)
	local candidates = intersection.getCriticalPoints(func)
	return math.max(unpack(candidates))
end
function intersection.getLowest(func)
	local candidates = intersection.getCriticalPoints(func)
	return math.min(unpack(candidates))
end

function intersection.intersectPerpetually(func, printing) -- for intersecting with the x-axis in the use case of only having numbers in [0, 360[ (without 360)
	local lowest = intersection.getLowest(func)
	local highest =  intersection.getHighest(func)
	lowest, highest = lowest + (lowest % 360 == 0 and 0 or 360) - lowest % 360, highest - highest % 360
	lowest = (lowest + 180) - (lowest + 180) % 360
	if printing then modlog(mod, "printing", lowest, highest, lowest > highest) end
	if lowest > highest then
		return {} -- no intersections
	else
		local intersections = {}
		for i = lowest, highest, 360 do
			if printing then modlog(mod, "DOINT ITTTTTTTT", i) end
			local func2 = intersection.subtractFunction(func, { a0 = i }, true)
			local newIntersections = intersection.intersect(func2)
			if newIntersections then
				for _, time in ipairs(newIntersections) do
					table.insert(intersections, time)
				end
			else
				return
			end
		end
		intersections = intersection.noDuplicates(intersections)
		return intersections
	end
end
function intersection.intersectPerpetuallyMultiple(funcs1, funcs2, getLowest)
	-- both funcs are continuous in their domain
	-- they are not neccessarily differentiable
	-- a single func within the funcs is differentiable though
	local returnRoots = {}
	local fullOverlap = {}
	local lowest, highest
	for _, func1 in ipairs(funcs1) do
		for _, func2 in ipairs(funcs2) do
			if intersection.isTimeOverlapping(func1, func2) then
				local func = intersection.subtractFunction(func1, func2, true)
				if getLowest then
					local low, high = intersection.getLowest(func), intersection.getHighest(func)
					if not lowest or lowest > low then lowest = low end
					if not highest or highest > high then highest = high end
				else
					local printing
					if 2.25 < func.startTime and func.endTime < 2.35 then
						local startV = intersection.useFunc(func, func.startTime) % 360
						local endV = intersection.useFunc(func, func.endTime) % 360
						local diff = math.abs(endV - startV) % 360
						modlog(mod, startV, endV, diff, func)
						printing = diff > 270
					end
					local roots = intersection.intersectPerpetually(func, printing)
					if roots then
						for _, root in ipairs(roots) do
							table.insert(returnRoots, root)
						end
					else
						table.insert(fullOverlap, { intersection.getOverlappingTime(func1, func2) })
					end
				end
			elseif intersection.isTimeOverlapping(func1, func2, true) then
				local time
				if func1.startTime == func2.endTime then time = func1.startTime end
				if func2.startTime == func1.endTime then time = func2.startTime end
				if getLowest then
					local low = intersection.useFunc(func1, time) - intersection.useFunc(func2, time)
					if not lowest or lowest > low then lowest = low end
				else
					local diff = math.abs(intersection.useFunc(func1, time) - intersection.useFunc(func2, time)) % 360
					if diff > 180 then diff = math.abs(diff - 360) end
					if diff <= 1e-9 then
						table.insert(returnRoots, time)
					end
				end
			end
		end
	end
	if getLowest then
		return lowest, highest
	end
	returnRoots = intersection.noDuplicates(returnRoots)
	return returnRoots, fullOverlap
end

function intersection.getFunction(time, duration, startVal, endVal, ease, secondTime) -- secondTime in prep for out eases
	ease = ease or "linear"
	if not flux.easing[ease] and not secondTime then ease = "linear" end
	local func = { startTime = math.min(time, time + duration), endTime = math.max(time, time + duration) }
	if duration == 0 then -- what are you even doing here
		modwarn(mod, "intersection.getFunction: duration is 0", time, duration, startVal, endVal, ease)
	elseif startVal == endVal then -- constant
		func.a0 = startVal
		return { func }
	elseif ease == "linear" then
		func.a1 = (endVal - startVal) / duration
		func.a0 = startVal - func.a1 * time
		return { func }
	elseif not secondTime and not ({ inQuad = true, outQuad = true, inOutQuad = true, inCubic = true, outCubic = true, inOutCubic = true, inQuart = true, outQuart = true, inOutQuart = true, inBack = true, outBack = true, inOutBack = true })[ease] then
		-- modwarn(mod, "intersection.getFunction: approximating", time, duration, startVal, endVal, ease)
		local d = endVal - startVal
		local funcs = {}
		local step = 1 / 32 * duration / math.abs(duration)
		for i = step, duration, step do
			if i <= duration then
				table.insert(
					funcs,
					intersection.getFunction(
						time + i - step, step,
						startVal + flux.easing[ease](helpers.clamp((i - step) / duration, 0, 1)) * d,
						startVal + flux.easing[ease](helpers.clamp(i / duration, 0, 1)) * d
					)[1]
				)
			end
		end
		if duration % step ~= 0 then
			local delta = duration % step
			modlog(mod, "delta", delta)
			table.insert(
				funcs,
				intersection.getFunction(
					time + duration - delta, delta,
					startVal + flux.easing[ease]((duration - delta) / duration) * d,
					endVal
				)[1]
			)
		end
		return funcs
	elseif ease:sub(1, #"inOut") == "inOut" then
		local ease2 = ease:sub(#"inOut" + 1, #"inOut" + 1):lower() .. ease:sub(#"inOut" + 2)
		local mid = (startVal + endVal) / 2
		return {
			unpack(intersection.getFunction(time, duration / 2, startVal, mid, ease2, true)),
			unpack(intersection.getFunction(time + duration, -duration / 2, endVal, mid, ease2, true))
		}
	elseif ease:sub(1, #"in") == "in" then
		local ease2 = ease:sub(#"in" + 1, #"in" + 1):lower() .. ease:sub(#"in" + 2)
		func = intersection.getFunction(time, duration, startVal, endVal, ease2, true)
		return { unpack(func) }
	elseif ease:sub(1, #"out") == "out" then
		local ease2 = ease:sub(#"out" + 1, #"out" + 1):lower() .. ease:sub(#"out" + 2)
		func = intersection.getFunction(time + duration, -duration, endVal, startVal, ease2, true)
		return { unpack(func) }
	elseif not secondTime then
		modwarn(mod, "intersection.getFunction: not implemented", time, duration, startVal, endVal, ease)
		func.a1 = (endVal - startVal) / duration
		func.a0 = startVal - func.a1 * time
		return { func }
	elseif ease == "quad" then
		-- a(x - b)² + c = ax² - 2abx + ab² + c
		local d = endVal - startVal
		-- a*duration² = d <=> a = d / duration²
		func.a2 = d / (duration ^ 2)
		func.a1 = func.a2 * -2 * (time ^ 1)
		func.a0 = func.a2 * 1 * (time ^ 2) + startVal
		return { func }
	elseif ease == "cubic" then
		-- a(x - b)³ + c = ax³ - 3abx² + 3ab²x - ab³ + c
		local d = endVal - startVal
		-- a*duration³ = d <=> a = d / duration³
		func.a3 = d / (duration ^ 3)
		func.a2 = func.a3 * -3 * (time ^ 1)
		func.a1 = func.a3 * 3 * (time ^ 2)
		func.a0 = func.a3 * -1 * (time ^ 3) + startVal
		return { func }
	elseif ease == "quart" then
		-- a(x - b)⁴ + c = ax⁴ - 4abx³ + 6ab²x² - 4ab³x + ab⁴ + c
		local d = endVal - startVal
		-- a*duration⁴ = d <=> a = d / duration⁴
		func.a4 = d / (duration ^ 4)
		func.a3 = func.a4 * -4 * (time ^ 1)
		func.a2 = func.a4 * 6 * (time ^ 2)
		func.a1 = func.a4 * -4 * (time ^ 3)
		func.a0 = func.a4 * 1 * (time ^ 4) + startVal
		return { func }
	--[[ elseif ease == "quint" then -- quintic not really feasable to solve, so we approximate it
		-- a(x - b)⁵ + c = ax⁵ - 5abx⁴ + 10ab²x³ - 10ab³x² + 5ab⁴x - ab⁵ + c
		local d = endVal - startVal
		-- a*duration⁵ = d <=> a = d / duration⁵
		func.a5 = d / (duration ^ 5)
		func.a4 = func.a5 * -5 * (time ^ 1)
		func.a3 = func.a5 * 10 * (time ^ 2)
		func.a2 = func.a5 * -10 * (time ^ 3)
		func.a1 = func.a5 * 5 * (time ^ 4)
		func.a0 = func.a5 * -1 * (time ^ 5) + startVal
		return { func } ]]
	elseif ease == "back" then
		local d = endVal - startVal
		-- p * p * (2.7 * p - 1.7) -- flux
		-- 2.7(m(x - time))³ - 1.7(m(x - time))²
		-- 2.7m³(x³ - 3timex² + 3time²x - time³) - 1.7m²(x² - 2timex + time²)
		-- (2.7m³x³ - 3*2.7m³timex² + 3*2.7m³time²x - 2.7m³time³) - (1.7m²x² - 2*1.7m²timex + 1.7m²time²)
		-- 2.7m³x³ - 8.1m³timex² + 8.1m³time²x - 2.7m³time³ - 1.7m²x² + 3.4m²timex - 1.7m²time²
		-- (2.7m³x³) + (-8.1m³timex² - 1.7m²x²) + (8.1m³time²x + 3.4m²timex) + (-2.7m³time³ - 1.7m²time²)
		-- (2.7m³)x³ + (-8.1m³time - 1.7m²)x² + (8.1m³time² + 3.4m²time)x + (-2.7m³time³ - 1.7m²time²)
		-- and then everything times d

		-- x = duration
		-- solve for m
		-- 2.7(mx)³ - 1.7(mx)² = 1
		-- 2.7x³m³ - 1.7x²m² - 1 = 0
		local mRoots = intersection.intersectCubic(2.7 * duration * duration * duration, -1.7 * duration * duration, 0, -1)
		if mRoots then
			local m = mRoots[1]
			func.a3 = 2.7 * d * m * m * m
			func.a2 = -8.1 * d * m * m * m * time - 1.7 * d * m * m
			func.a1 = 8.1 * d * m * m * m * time * time + 3.4 * d * m * m * time
			func.a0 = -2.7 * d * m * m * m * time * time * time - 1.7 * d * m * m * time * time + startVal
		else
			-- a(x - b)³ + c = ax³ - 3abx² + 3ab²x - ab³ + c

			-- a*duration³ = d <=> a = d / duration³ normal cubic, just in case, mane i really dont know
			func.a3 = d / (duration ^ 3)
			func.a2 = func.a3 * -3 * (time ^ 1)
			func.a1 = func.a3 * 3 * (time ^ 2)
			func.a0 = func.a3 * -1 * (time ^ 3) + startVal
		end
		if not (mRoots and #mRoots == 1) then
			modlog(mod, "aRoots", mRoots)
		end

		return { func }
	else
		modwarn(mod, "intersection.getFunction: second time not implemented", time, duration, startVal, endVal, ease)
		func.a1 = (endVal - startVal) / duration
		func.a0 = startVal - func.a1 * time
		return { func }
	end
end

function intersection.addFunction(func1, func2, allowCutoff)
	if not intersection.isTimeOverlapping(func1, func2) then
		modwarn(mod, "FUNCTIONS NOT DEFINED NEAR EACH OTHER", func1, func2)
	end
	local funcA = helpers.copy(func1)
	local funcB = helpers.copy(func2)
	if not intersection.isTimeIdentical(funcA, funcB) then
		if not allowCutoff then modwarn(mod, "FUNCTIONS ARE GETTING CUT OFF", funcA, funcB) end
		funcB = helpers.copy(funcB)
		intersection.forceTimeIdentical(funcA, funcB)
	end
	for k, v in pairs(funcB) do
		if not intersection.dontAdd[k] then
			funcA[k] = (funcA[k] or 0) + v
			if funcA[k] == 0 then funcA[k] = nil end
		end
	end
	if not intersection.validateFunctions({ funcA }) then
		modwarn(mod, "INVALID ADDITION", funcA, funcB, func1, func2, allowCutoff)
	end
	return funcA
end
function intersection.subtractFunction(func1, func2, allowCutoff)
	local funcB = helpers.copy(func2)
	for i = 0, 5 do
		if funcB["a" .. i] then
			funcB["a" .. i] = -funcB["a" .. i]
		end
	end
	return intersection.addFunction(func1, funcB, allowCutoff)
end
function intersection.addFunctions(funcs1, funcs2)
	if not (intersection.validateFunctions(funcs1) and intersection.validateFunctions(funcs2)) then
		modwarn(mod, "INVALID FUNCS", funcs1, funcs2)
		return {}
	end
	if not funcs1 or #funcs1 == 0 then
		modwarn(mod, "funcs1 is empty")
	end
	if not funcs2 or #funcs2 == 0 then
		modwarn(mod, "funcs1 is empty")
	end
	local resultFuncs = {}
	local funcsA = helpers.copy(funcs1)
	local funcsB = helpers.copy(funcs2)
	local i = 1
	local j = 1
	local func1 = funcsA[i]
	local func2 = funcsB[j]
	while func1 do
		if func2 then
			while func2 and (not func1 or func2.startTime < func1.endTime) do
				if func1 then
					local overlapping = intersection.isTimeOverlapping(func1, func2)
					if overlapping then
						local xor1, xor2 = intersection.getXor(func1, func2)
						local startOverlap, endOverlap = intersection.getOverlappingTime(func1, func2)
						local overlapped = intersection.addFunction(func1, func2, true)
						if xor1 then
							for k, func in ipairs(xor1) do
								if func.startTime < endOverlap then -- this func wasnt overlapping and is before the overlap
									table.insert(resultFuncs, func)
								else -- this func wasnt overlapping and is after the overlap
									funcsA[i] = func
									func1 = func
									if k ~= #xor1 then -- xor only returns 2 funcs max before and after the overlap
										modwarn(mod, "WHAT", k, xor1, endOverlap)
									end
									break
								end
							end
						end
						if xor2 then
							for k, func in ipairs(xor2) do
								if func.startTime < endOverlap then -- this func wasnt overlapping and is before the overlap
									table.insert(resultFuncs, func)
								else -- this func wasnt overlapping and is after the overlap
									funcsB[j] = func
									func2 = func
									if k ~= #xor2 then -- xor only returns 2 funcs max before and after the overlap
										modwarn(mod, "WHAT", k, xor2, endOverlap)
									end
									break
								end
							end
						end
						table.insert(resultFuncs, overlapped)
						if func1.startTime < endOverlap then
							-- dont insert to funcs
							i = i + 1
							func1 = funcsA[i]
						end
						if func2.startTime < endOverlap then
							-- dont insert to funcs
							j = j + 1
							func2 = funcsB[j]
						end
					else
						table.insert(resultFuncs, func2)
						j = j + 1
						func2 = funcsB[j]
					end
				elseif func2 then
					table.insert(resultFuncs, func2)
					j = j + 1
					func2 = funcsB[j]
				end
			end
		end
		if func1 then
			table.insert(resultFuncs, func1)
			i = i + 1
			func1 = funcsA[i]
		end
	end
	if not intersection.validateFunctions(resultFuncs) or resultFuncs[1].startTime ~= math.min(funcs1[1].startTime, funcs2[1].startTime) or resultFuncs[#resultFuncs].endTime ~= math.max(funcs1[#funcs1].endTime, funcs2[#funcs2].endTime) then
		modwarn(mod, "INVALID ADDITIONS", resultFuncs, funcs1, funcs2, i, j)
	end
	return resultFuncs
end

return intersection