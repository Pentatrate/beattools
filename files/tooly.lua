--[[
TODO:
minehold:
- sine
- expo
- circ
- elastic
- back
- squaredCirc
- bounce

angle ease sequences
retime

minehold tail ease sequences
better holds
better sides
]]

local tooly = {
	sidePadding = 1,
	round = 1e2,
	merge = 0.01,
	barelyWindow = 30,
	holdLeniency = false,
	noSides = false,
	sidesAfter = false,
	supported = {
		block = true,
		mine = true,
		inverse = true,
		bounce = true,
		hold = true,
		mineHold = true,
		side = true
	},
	mine = {
		mine = true,
		mineHold = true,
		sideDodge = true
	},
	inverse = {
		inverse = true
	},
	hold = {
		hold = true,
		mineHold = true
	},
	bounce = {
		bounce = true
	},
	noBarely = {
		lenient = true
	},
	lenient = {
		hold = true
	},
	side = {
		side = true,
		sideDodge = true
	},
	prevAngle = 0,
	prevTime = 0,
	cacheMineholds = {},
	currentTunnelIndex = 0,
	retime = {},
	allEvents = {},
	retimeIndex = 0,
	retimeValue = 0
}

local function isBetween(x, low, high)
	local lowFullfilled, highFullfilled = x >= low, x <= high
	if low <= high then
		return lowFullfilled and highFullfilled
	end
	return lowFullfilled or highFullfilled
end
function tooly.checkPaddleId(paddleId)
	if not (1 <= paddleId and paddleId <= 8 and paddleId % 1 == 0) then modwarn(mod, "tooly.checkPaddleId: stupid paddleId", paddleId) return true end
end
function tooly.msToBeat(time, ms)
	local bpm, bpmC = utilitools.files.beattools.easing.getEase("setBPM", nil, time, nil, nil)
	return GameManager:msToBeat(ms, bpm.bpm)
end
function tooly.getWidth(range)
	local a1, a2 = range[1], range[2]
	local width = a2 - a1
	if math.abs(width) == 360 then return 360 end
	return width % 360
end
function tooly.holdLeniencyBeats(time)
	local negative, negativeC = utilitools.files.beattools.easing.getEase("ease", "allowNegativeHoldLeniencyPleaseOnlyEnableThisIfYouKnowWhatYouAreDoing", time, nil, nil)
	local extraLeniency, extraLeniencyC = utilitools.files.beattools.easing.getEase("ease", "extraHoldLeniency", time, nil, nil)
	local leniency = math.max(negative.value and 0 or 15, 15 + extraLeniency.value) -- in frames
	leniency = leniency / 60 / 1e3 -- in milliseconds
	leniency = tooly.msToBeat(time, leniency) -- in beats
	return leniency
end
function tooly.getRangeForEventAndPaddle(eventTime, eventAngle, eventAngle2, paddleId, dontShift, mine, side, inverse, noBarely)
	if tooly.checkPaddleId(paddleId) then modwarn(mod, "tooly.getAnglesForEventAndPaddle: stupid paddleId", eventTime, eventAngle, eventAngle2, paddleId, dontShift, mine, side, inverse, noBarely) return {} end
	local paddle, paddleC = utilitools.files.beattools.easing.getEase("paddles", paddleId, eventTime, nil, nil)
	if paddle.enabled then
		local padding = paddle.newWidth
		if padding >= 360 then -- hacky fix
			local paddle2, paddleC2 = utilitools.files.beattools.easing.getEase("paddles", paddleId, eventTime + tooly.msToBeat(eventTime, 20), nil, nil)
			if paddle2.newWidth < 360 then
				padding = padding + paddle2.newWidth - paddle.newWidth
			end
		end
		if inverse then padding = math.min(padding + 22.5, padding * 1.2, padding * 0.875 + 45) end
		if noBarely then padding = padding + tooly.barelyWindow end
		if mine then padding = 360 - math.max(0.001, padding) eventAngle, eventAngle2 = eventAngle + 180, eventAngle2 and eventAngle2 + 180 or nil end
		padding = padding / 2
		if side then padding = padding - tooly.sidePadding end

		local a1, a2
		if eventAngle2 then -- 0 duration minehold
			local totalWidth = tooly.getWidth({ eventAngle , eventAngle2 })
			if totalWidth + (360 - padding * 2) >= 360 then
				return {} -- level is impossible
			end
			a1, a2 = eventAngle2 - padding, eventAngle + padding
		else
			if padding < 0 then
				return {} -- level is impossible
			end
			if padding >= 179.999 then
				return -- all angles possible
			end
			a1, a2 = eventAngle - padding, eventAngle + padding
		end
		if not dontShift then
			a1, a2 = a1 + paddle.newAngle, a2 + paddle.newAngle
			local objectRotation, objectRotationC = utilitools.files.beattools.easing.getEase("ease", "objectRotation", eventTime, nil, nil)
			a1, a2 = a1 + objectRotation.value, a2 + objectRotation.value
		end
		a1, a2 = a1 % 360, a2 % 360
		return { { a1, a2 } }
	end
	-- no paddle, no hitbox
end
function tooly.overlapRange(range1, range2, canBeEither, justGetData)
	local a1, a2 = range1[1], range1[2]
	local b1, b2 = range2[1], range2[2]
	local a1InB, a2InB = isBetween(a1, b1, b2), isBetween(a2, b1, b2)
	local b1InA, b2InA = isBetween(b1, a1, a2), isBetween(b2, a1, a2)
	local partiallyOverlapping = a1InB or a2InB or b1InA or b2InA -- dont need the last condition, but its no biggie
	local aInB = partiallyOverlapping and a1InB and a2InB
	local bInA = partiallyOverlapping and b1InA and b2InA
	local totallyOverlapping = partiallyOverlapping and (aInB or bInA)
	if justGetData then
		return totallyOverlapping, partiallyOverlapping, aInB, bInA, a1InB, a2InB, b1InA, b2InA
	end
	if totallyOverlapping then
		if a1 == b1 and a2 == b2 then
			return { { a1, a2 } }
		elseif aInB and bInA then
			if canBeEither then
				return -- all angles allowed
			else
				return { { a1, b2 }, { b1, a2 } }
			end
		elseif aInB then
			if canBeEither then
				return { { b1, b2 } }
			else
				return { { a1, a2 } }
			end
		else -- bInA
			if canBeEither then
				return { { a1, a2 } }
			else
				return { { b1, b2 } }
			end
		end
	elseif partiallyOverlapping then
		if canBeEither then
			return { { b1InA and a1 or b1, b2InA and a2 or b2 } } -- is bigger than either
		else
			return { { b1InA and b1 or a1, b2InA and b2 or a2 } } -- is smaller than either
		end
	else
		if canBeEither then
			return { { a1, a2 }, { b1, b2 } }
		else
			return {} -- level is impossible (in most cases)
		end
	end
	modwarn(mod, "tooly.overlapAngles: no match?", a1, a2, b1, b2, canBeEither)
	return {} -- lets just say the level is impossible
end
function tooly.overlapRanges(ranges1, ranges2, canBeEither)
	if not ranges1 or not ranges2 then -- if either allows all angles
		if canBeEither then
			return -- all angles possible
		else
			return ranges1 or ranges2
		end
	end
	if #ranges1 == 0 or #ranges2 == 0 then -- if either allows no angles
		if canBeEither then
			return #ranges1 ~= 0 and ranges1 or ranges2
		else
			return {} -- level is impossible
		end
	end

	local totalRanges = {}
	if canBeEither then
		for _, range in ipairs(ranges1) do
			table.insert(totalRanges, range)
		end
		for _, range in ipairs(ranges2) do
			table.insert(totalRanges, range)
		end
	else
		for _, range1 in ipairs(ranges1) do
			for _, range2 in ipairs(ranges2) do
				local singleCompare = tooly.overlapRange(range1, range2, false)
				if not singleCompare then
					return -- all angles possible
				end
				if #singleCompare == 0 then
					-- do nothing
				else
					for _, range in ipairs(singleCompare) do
						table.insert(totalRanges, range)
					end
				end
			end
		end
	end

	local finalRanges = {}
	local i = 1
	while #totalRanges > 0 do
		i = i + 1
		if i > 1000 then modwarn(mod, "STACK OVERFLOW 1") return end

		local rangeToCompare = table.remove(totalRanges)
		local remainingRanges = {}
		local j = 1
		while #totalRanges > 0 do
			j = j + 1
			if j > 1000 then modwarn(mod, "STACK OVERFLOW 2") return end

			local singleCompare = tooly.overlapRange(rangeToCompare, table.remove(totalRanges), true)
			if not singleCompare then
				return -- all angles possible
			end
			if #singleCompare == 0 then
				for _, range in ipairs(totalRanges) do
					table.insert(remainingRanges, range)
				end
				rangeToCompare = true
				totalRanges = {}
			else
				rangeToCompare = table.remove(singleCompare, 1)
				for _, range in ipairs(singleCompare) do
					table.insert(remainingRanges, range)
				end
			end
		end
		if rangeToCompare ~= true then
			table.insert(finalRanges, rangeToCompare)
		end
		totalRanges = remainingRanges
	end
	return finalRanges
end

function tooly.getRangesForEvent(eventTime, eventAngle, eventAngle2, mine, side, inverse, noBarely)
	local ranges
	for i = 1, 8 do
		local moreRanges = tooly.getRangeForEventAndPaddle(eventTime, eventAngle, eventAngle2, i, false, mine, side, inverse, noBarely)
		if moreRanges then
			if ranges then
				if mine then
					ranges = tooly.overlapRanges(ranges, moreRanges, false)
				else
					ranges = tooly.overlapRanges(ranges, moreRanges, true)
				end
			else
				ranges = moreRanges
			end
		end
	end
	return ranges
end

local function holdBetween(time, low, high)
	return time >= low and time <= high
end
function tooly.getRangesForTime(time, tunnels, antiTunnels)
	local ranges = tooly.tunnelsGetRanges(tunnels, antiTunnels, time)
	local eventVisuals = utilitools.files.beattools.eventVisuals
	local timeStepped

	local function checkEvent(event)
		if tooly.supported[event.type] and not (tooly.side[event.type] and tooly.noSides) then
			local eventTime = tooly.getTime(event.time)
			local inTime = math.abs(eventTime - time) < tooly.merge
			if not inTime then
				if tooly.hold[event.type] then
					inTime = holdBetween(time, eventTime, eventTime + event.duration)
				elseif tooly.bounce[event.type] then
					inTime = (helpers.round((time - eventTime) / event.delay * tooly.round) / tooly.round) % 1 == 0 and eventTime < time and time <= eventTime + event.bounces * event.delay
				elseif tooly.side[event.type] then
					inTime = math.abs(eventTime - tooly.msToBeat(eventTime, 100) - time) < tooly.merge
					if not inTime and tooly.sidesAfter then
						inTime = eventTime + tooly.msToBeat(eventTime, 50) == time
					end
				end
			end

			if inTime then
				local eventAngle = (event.endAngle or event.angle) % 360
				local moreRanges

				if tooly.hold[event.type] then
					if event.duration == 0 then
						local a1, a2 = (event.endAngle or event.angle), event.angle2
						local width = math.abs(a2 - a1)
						if tooly.mine[event.type] then
							if width % 360 ~= 0 then -- not magic minehold, has hitbox
								if width >= 360 then
									moreRanges = {}
								else
									a1, a2 = math.min(a1, a2), math.max(a1, a2)
									moreRanges = tooly.getRangesForEvent(time, a1 % 360, a2 % 360, true, false, false, false)
								end
							end
						else
							moreRanges = tooly.overlapRanges(
								tooly.getRangesForEvent(time, eventAngle, nil, false, false, false, false),
								tooly.getRangesForEvent(time, event.angle2 % 360, nil, false, false, false, true),
								false
							)
						end
					elseif eventTime == time then
						moreRanges = tooly.getRangesForEvent(time, eventAngle, nil, tooly.mine[event.type], false, false, false)
					elseif eventTime + event.duration == time then
						moreRanges = tooly.getRangesForEvent(time, event.angle2 % 360, nil, tooly.mine[event.type], false, false, tooly.lenient[event.type])
					elseif not (tooly.lenient[event.type] and ((tooly.holdLeniency or tooly.holdLeniencyBeats(time) >= eventTime + event.duration - time) or math.min(time % 0.5, 0.5 - (time % 0.5)) >= tooly.merge)) then
						-- hacky fix for hold leniency, have to improve later
						local angle = (eventAngle + (event.angle2 - (event.endAngle or event.angle)) * (flux.easing[event.holdEase] or flux.easing["linear"])((time - eventTime) / event.duration)) % 360
						moreRanges = tooly.getRangesForEvent(time, angle, nil, tooly.mine[event.type], false, false, tooly.lenient[event.type])
					end
				elseif tooly.bounce[event.type] then
					if time == eventTime then
						moreRanges = tooly.getRangesForEvent(time, eventAngle, nil, false, false, false, false)
					else
						local i = (time - eventTime) / event.delay
						moreRanges = tooly.getRangesForEvent(time, (eventAngle + event.rotation * i) % 360, nil, false, false, false, false)
					end
				elseif tooly.side[event.type] then
					if math.abs(eventTime - tooly.msToBeat(eventTime, 100) - time) < tooly.merge then
						moreRanges = tooly.getRangesForEvent(time, eventAngle, nil, true, true, false, false)
					else
						moreRanges = tooly.getRangesForEvent(time, eventAngle, nil, false, true, false, false)
					end
				else
					moreRanges = tooly.getRangesForEvent(time, eventAngle, nil, tooly.mine[event.type], false, tooly.inverse[event.type], false)
				end

				if moreRanges then
					if ranges then
						ranges = tooly.overlapRanges(ranges, moreRanges, false)
					else
						ranges = moreRanges
					end
				end
			end
		end
	end
	for i = -1, 1 do
		timeStepped = eventVisuals.getTime(time + eventVisuals.step * i)
		if eventVisuals.eventCache[timeStepped] then
			for _, event in pairs(eventVisuals.eventCache[timeStepped]) do
				checkEvent(event)
			end
		end
	end

	return ranges
end



-- tunnels = { tunnel: { startTime = ..., endTime = ..., a1 = { func: { startTime, endTime, ..., a1, a0 }, ... }, a2 = {...} }, ... }
function tooly.getTunnelForBaseEvent(event) -- minehold
	-- the tunnel is unfinished, you have to manipulate it with paddle width, paddle angle, and objectRotation
	-- intersection.subtractFunction(func, { a0 = i }, true)
	local intersection = utilitools.files.beattools.intersection
	local funcs
	local eventTime = event.time
	if tooly.cacheMineholds[tostring(event)] then
		funcs = tooly.cacheMineholds[tostring(event)]
	else
		funcs = intersection.getFunction(eventTime, event.duration, event.endAngle or event.angle, event.angle2, event.holdEase)
		tooly.cacheMineholds[tostring(event)] = funcs
	end
	local tunnel = {
		startTime = eventTime, endTime = eventTime + event.duration,
		a1 = intersection.addFunctions(
			funcs,
			{ { startTime = eventTime, endTime = eventTime + event.duration, a0 = 180 --[[ - 0.001 ]] } },
			true
		),
		a2 = intersection.addFunctions(
			funcs,
			{ { startTime = eventTime, endTime = eventTime + event.duration, a0 = 180 --[[ + 0.001 ]] } },
			true
		)
	}
	tooly.validateTunnels({ tunnel })
	return tunnel
end
function tooly.sortTunnel(tunnel)
	local intersection = utilitools.files.beattools.intersection
	intersection.sort(tunnel.a1)
	intersection.sort(tunnel.a2)
end
function tooly.sortTunnels(tunnels)
	for _, tunnel in ipairs(tunnels) do
		tooly.sortTunnel(tunnel)
	end
	table.sort(tunnels, function(a, b)
		if a.startTime == b.startTime then
			return a.endTime < b.endTime
		end
		return a.startTime < b.startTime
	end)
end
function tooly.addFuncsToTunnels(tunnels, funcs, a1)
	local intersection = utilitools.files.beattools.intersection
	local startTime, endTime = funcs[1].startTime, funcs[#funcs].endTime
	local fake = { startTime = startTime, endTime = endTime }
	local returnTunnels = helpers.copy(tunnels)
	local added = false
	for i, tunnel in ipairs(returnTunnels) do
		if intersection.isTimeOverlapping(tunnel, fake) then
			if a1 ~= false then
				tunnel.a1 = intersection.addFunctions(tunnel.a1, funcs)
			end
			if a1 ~= true then
				tunnel.a2 = intersection.addFunctions(tunnel.a2, funcs)
			end
			added = true
		end
	end
	if not added then
		modlog(mod, "DIDNT ADD ANYTHING LOL")
	end
	return returnTunnels
end
function tooly.cutTunnels(tunnels, startTime, endTime)
	local intersection = utilitools.files.beattools.intersection
	local fake = { startTime = startTime, endTime = endTime }
	local returnTunnels = {}
	for _, tunnel in ipairs(tunnels) do
		if intersection.isTimeOverlapping(tunnel, fake) then
			if intersection.inTime(fake, tunnel.startTime) and intersection.inTime(fake, tunnel.endTime) then
				-- nothing
			else
				local cutTunnel1 = helpers.copy(tunnel)
				local cutTunnel2 = helpers.copy(tunnel)
				cutTunnel1.a1 = intersection.cutOutFromFuncs(cutTunnel1.a1, startTime)
				cutTunnel1.a2 = intersection.cutOutFromFuncs(cutTunnel1.a2, startTime)
				cutTunnel2.a1 = intersection.cutOutFromFuncs(cutTunnel2.a1, nil, endTime)
				cutTunnel2.a2 = intersection.cutOutFromFuncs(cutTunnel2.a2, nil, endTime)
				local cutTunnels1 = intersection.cutOut(cutTunnel1, startTime)
				local cutTunnels2 = intersection.cutOut(cutTunnel2, nil, endTime)
				for _, cutTunnelA in ipairs(cutTunnels1) do
					table.insert(returnTunnels, cutTunnelA)
				end
				for _, cutTunnelB in ipairs(cutTunnels2) do
					table.insert(returnTunnels, cutTunnelB)
				end
			end
		else
			table.insert(returnTunnels, tunnel)
		end
	end
	return returnTunnels
end
function tooly.getTunnelsForEventAndPaddle(event, paddleId)
	local intersection = utilitools.files.beattools.intersection
	local baseTunnel = tooly.getTunnelForBaseEvent(event)

	local globalStart = baseTunnel.startTime
	local globalEnd = baseTunnel.endTime
	local tunnels = { helpers.copy(baseTunnel) }
	local startValues, startCount = utilitools.files.beattools.easing.getEase("paddles", paddleId, globalStart, nil, nil)
	local endValues, endCount = utilitools.files.beattools.easing.getEase("paddles", paddleId, globalEnd, nil, nil)

	local function splitTunnels(time)
		local tunnels2 = {}
		for _, tunnel in ipairs(tunnels) do
			if intersection.inTime(tunnel, time) and tunnel.startTime ~= time and tunnel.endTime ~= time then
				tunnel = helpers.copy(tunnel)
				local tunnel2 = helpers.copy(tunnel)
				tunnel.endTime = time
				tunnel.a1 = intersection.cutOutFromFuncs(tunnel.a1, time, nil)
				tunnel.a2 = intersection.cutOutFromFuncs(tunnel.a2, time, nil)
				tunnel2.startTime = time
				tunnel2.a1 = intersection.cutOutFromFuncs(tunnel2.a1, nil, time)
				tunnel2.a2 = intersection.cutOutFromFuncs(tunnel2.a2, nil, time)
				table.insert(tunnels2, tunnel)
				table.insert(tunnels2, tunnel2)
			else
				table.insert(tunnels2, tunnel)
			end
		end
		tunnels = tunnels2
	end
	local function doCutTunnels(startTime, endTime)
		tunnels = tooly.cutTunnels(tunnels, startTime, endTime)
	end

	if startCount.newWidth.total == 0 then
		local add = { { startTime = globalStart, endTime = globalEnd, a0 = -(360 - startValues.newWidth) / 2 } }
		tunnels = tooly.addFuncsToTunnels(tunnels, add, true)
		add[1].a0 = -add[1].a0
		tunnels = tooly.addFuncsToTunnels(tunnels, add, false)
	else
		local list = utilitools.files.beattools.easing.list.paddles[paddleId].newWidth
		local i = math.max(1, startCount.newWidth.index)
		local time = globalStart
		while startCount.newWidth.index <= i and i <= endCount.newWidth.index and list[i] and list[i].event.time < tunnels[#tunnels].endTime do -- a few double checks dont hurt
			local ease = list[i].event
			if i + 1 > endCount.newWidth.index or not list[i + 1] or list[i + 1].event.time ~= ease.time then
				if time < ease.time then
					-- the paddle width before the ease
					local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
					local add = { { startTime = time, endTime = ease.time, a0 = -(360 - value.newWidth) / 2 } }
					tunnels = tooly.addFuncsToTunnels(tunnels, add, true)
					add[1].a0 = -add[1].a0
					tunnels = tooly.addFuncsToTunnels(tunnels, add, false)
					time = ease.time
				end

				if ease.duration and ease.duration ~= 0 and ease.time + ease.duration > globalStart then
					-- event is easing
					local startValue
					if false and ease.start then -- paddles events dont have a start, why did i do this
						-- event has start, split the tunnel
						splitTunnels(ease.time)
						startValue = ease.start
					else
						local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
						startValue = value.newWidth
					end
					if startValue ~= ease.newWidth then
						local endTime = math.min(ease.time + (ease.duration or 0), globalEnd)
						if i + 1 <= endCount.newWidth.index and list[i + 1] then
							endTime = math.min(endTime, list[i + 1].event.time)
						end
						local add = intersection.getFunction(ease.time, ease.duration, -(360 - startValue) / 2, -(360 - ease.newWidth) / 2, ease.ease)
						add = intersection.remove(add, nil, time)
						add = intersection.remove(add, endTime, nil)
						tunnels = tooly.addFuncsToTunnels(tunnels, add, true)
						add = intersection.getFunction(ease.time, ease.duration, (360 - startValue) / 2, (360 - ease.newWidth) / 2, ease.ease)
						add = intersection.remove(add, nil, time)
						add = intersection.remove(add, endTime, nil)
						tunnels = tooly.addFuncsToTunnels(tunnels, add, false)
						time = endTime
					end
				elseif ease.time ~= globalStart then
					-- event is instant, split the tunnel
					splitTunnels(ease.time)
				end
			end
			i = i + 1
		end
		if time < globalEnd then
			-- the paddle width after the eases
			local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
			local add = { { startTime = time, endTime = globalEnd, a0 = -(360 - value.newWidth) / 2 } }
			tunnels = tooly.addFuncsToTunnels(tunnels, add, true)
			add[1].a0 = -add[1].a0
			tunnels = tooly.addFuncsToTunnels(tunnels, add, false)
			time = globalEnd
		end
	end

	if startCount.newAngle.total == 0 then
		if startValues.newAngle ~= 0 then
			local add = { { startTime = globalStart, endTime = globalEnd, a0 = startValues.newAngle } }
			tunnels = tooly.addFuncsToTunnels(tunnels, add)
		end
	else
		local list = utilitools.files.beattools.easing.list.paddles[paddleId].newAngle
		local i = math.max(1, startCount.newAngle.index)
		local time = globalStart
		while startCount.newAngle.index <= i and i <= endCount.newAngle.index and list[i] and list[i].event.time < tunnels[#tunnels].endTime do -- a few double checks dont hurt
			local ease = list[i].event
			if i + 1 > endCount.newAngle.index or not list[i + 1] or list[i + 1].event.time ~= ease.time then
				if time < ease.time then
					-- the paddle width before the ease
					local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
					local add = { { startTime = time, endTime = ease.time, a0 = value.newAngle } }
					tunnels = tooly.addFuncsToTunnels(tunnels, add)
					time = ease.time
				end

				if ease.duration and ease.duration ~= 0 and ease.time + ease.duration > globalStart then
					-- event is easing
					local startValue
					if false and ease.start then -- paddles events dont have a start, why did i do this
						-- event has start, split the tunnel
						splitTunnels(ease.time)
						startValue = ease.start
					else
						local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
						startValue = value.newAngle
					end
					if startValue ~= ease.newAngle then
						local endTime = math.min(ease.time + (ease.duration or 0), globalEnd)
						if i + 1 <= endCount.newAngle.index and list[i + 1] then
							endTime = math.min(endTime, list[i + 1].event.time)
						end
						local add = intersection.getFunction(ease.time, ease.duration, startValue, ease.newAngle, ease.ease)
						add = intersection.remove(add, nil, time)
						add = intersection.remove(add, endTime, nil)
						tunnels = tooly.addFuncsToTunnels(tunnels, add)
						time = endTime
					end
				elseif ease.time ~= globalStart then
					-- event is instant, split the tunnel
					splitTunnels(ease.time)
				end
			end
			i = i + 1
		end
		if time < globalEnd then
			-- the paddle width after the eases
			local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
			local add = { { startTime = time, endTime = globalEnd, a0 = value.newAngle } }
			tunnels = tooly.addFuncsToTunnels(tunnels, add)
			time = globalEnd
		end
	end

	local startValues2, startCount2 = utilitools.files.beattools.easing.getEase("ease", "objectRotation", globalStart, nil, nil)
	local endValues2, endCount2 = utilitools.files.beattools.easing.getEase("ease", "objectRotation", globalEnd, nil, nil)

	if startCount2.total == 0 then
		if startValues2.value ~= 0 then
			local add = { { startTime = globalStart, endTime = globalEnd, a0 = startValues2.value } }
			tunnels = tooly.addFuncsToTunnels(tunnels, add)
		end
	else
		local list = utilitools.files.beattools.easing.list.ease.objectRotation["_"]
		local i = math.max(1, startCount2.index)
		local time = globalStart
		while startCount2.index <= i and i <= endCount2.index and list[i] and list[i].event.time < tunnels[#tunnels].endTime do -- a few double checks dont hurt
			local ease = list[i].event
			if i + 1 > endCount2.index or not list[i + 1] or list[i + 1].event.time ~= ease.time then
				if time < ease.time then
					-- the paddle width before the ease
					local value, count = utilitools.files.beattools.easing.getEase("ease", "objectRotation", time, nil, nil)
					local add = { { startTime = time, endTime = ease.time, a0 = value.value } }
					tunnels = tooly.addFuncsToTunnels(tunnels, add)
					time = ease.time
				end

				if ease.duration and ease.duration ~= 0 and ease.time + ease.duration > globalStart then
					-- event is easing
					local startValue
					if ease.start then
						-- event has start, split the tunnel
						splitTunnels(ease.time)
						startValue = ease.start
					else
						local value, count = utilitools.files.beattools.easing.getEase("ease", "objectRotation", time, nil, nil)
						startValue = value.value
					end
					if startValue ~= ease.value then
						local endTime = math.min(ease.time + (ease.duration or 0), globalEnd)
						if i + 1 <= endCount2.index and list[i + 1] then
							endTime = math.min(endTime, list[i + 1].event.time)
						end
						local add = intersection.getFunction(ease.time, ease.duration, startValue, ease.value, ease.ease)
						add = intersection.remove(add, nil, time)
						add = intersection.remove(add, endTime, nil)
						tunnels = tooly.addFuncsToTunnels(tunnels, add)
						time = endTime
					end
				elseif ease.time ~= globalStart then
					-- event is instant, split the tunnel
					splitTunnels(ease.time)
				end
			end
			i = i + 1
		end
		if time < globalEnd then
			-- the paddle width after the eases
			local value, count = utilitools.files.beattools.easing.getEase("ease", "objectRotation", time, nil, nil)
			local add = { { startTime = time, endTime = globalEnd, a0 = value.value } }
			tunnels = tooly.addFuncsToTunnels(tunnels, add)
			time = globalEnd
		end
	end

	if startCount.enabled.total == 0 then
		if not startValues.enabled then
			tunnels = {}
		end
	else
		local list = utilitools.files.beattools.easing.list.paddles[paddleId].enabled
		local i = math.max(1, startCount.enabled.index)
		local time = globalStart
		while startCount.enabled.index <= i and i <= endCount.enabled.index and list[i] and list[i].event.time < tunnels[#tunnels].endTime do -- a few double checks dont hurt
			local ease = list[i].event
			if i + 1 > endCount.enabled.index or not list[i + 1] or list[i + 1].event.time ~= ease.time then
				if time < ease.time then
					-- the paddle width before the ease
					local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
					if value.enabled ~= ease.enabled then
						if not value.enabled then
							doCutTunnels(time, ease.time)
						end
						time = ease.time
					end
				end
			end
			i = i + 1
		end
		if time < globalEnd then
			-- the paddle width after the eases
			local value, count = utilitools.files.beattools.easing.getEase("paddles", paddleId, time, nil, nil)
			if not value.enabled then
				doCutTunnels(time, globalEnd)
			end
			time = globalEnd
		end
	end

	tooly.sortTunnels(tunnels)

	return tunnels
end
function tooly.tunnelGetRange(tunnel, time) -- returns ranges, not range, since its easier that way
	local intersection = utilitools.files.beattools.intersection
	if not intersection.inTime(tunnel, time) then
		modwarn(mod, "NOT IN TIME", tunnel, time)
	end
	local a1 = intersection.useFuncs(tunnel.a1, time) or 0
	local a2 = intersection.useFuncs(tunnel.a2, time) or 0
	--[[ if a1 > a2 then -- i dont think this works
		return {} -- impossible
	end
	if a2 - a1 >= 360 then
		return -- all possible
	end ]]
	return { { a1 % 360, a2 % 360 } }
end
function tooly.validateTunnels(tunnels)
	local intersection = utilitools.files.beattools.intersection
	local totalValid = true

	for _, tunnel in ipairs(tunnels) do
		local validated, reason = true, ""
		if validated then
			validated = tunnel.startTime == tunnel.a1[1].startTime and tunnel.startTime == tunnel.a2[1].startTime
			if not validated then reason = utilitools.string.concat("tunnel startTime ~= func startTime ", tunnel.startTime, tunnel.a1[1].startTime, tunnel.a2[1].startTime) end
		end
		if validated then
			validated = tunnel.endTime == tunnel.a1[#tunnel.a1].endTime and tunnel.endTime == tunnel.a2[#tunnel.a2].endTime
			if not validated then reason = utilitools.string.concat("tunnel endTime ~= func endTime", tunnel.endTime, tunnel.a1[#tunnel.a1].endTime, tunnel.a2[#tunnel.a2].endTime) end
		end
		if validated then
			local valid1, reason1 = intersection.validateFunctions(tunnel.a1, true)
			local valid2, reason2 = intersection.validateFunctions(tunnel.a2, true)
			validated = valid1 and valid2
			if not validated then reason = "tunnel invalid " .. (reason1 or reason2) end
		end
		if validated and false then
			local lowest = intersection.intersectPerpetuallyMultiple(tunnel.a2, tunnel.a1, true)
			validated = not lowest or lowest >= 0
			if not validated then reason = utilitools.string.concat("lower than 0", lowest) end
		end
		if not validated then
			totalValid = false
			modwarn(mod, "INVALID TUNNEL IN TUNNELS", reason, tooly.currentTunnelIndex) -- , tunnel, tunnels)
		end
	end

	return totalValid
end
function tooly.glueTunnelsTogether(tunnels) -- mutates the tunnels directly
	local intersection = utilitools.files.beattools.intersection

	tooly.sortTunnels(tunnels)

	local i = 1
	while tunnels[i] do
		local tunnelA = tunnels[i]

		local j = 1
		while tunnels[j] do
			local tunnelB  = tunnels[j]

			if tunnelA ~= tunnelB and tunnelA.endTime == tunnelB.startTime then
				local diff1 = math.abs(intersection.useFuncs(tunnelA.a1, tunnelA.endTime) - intersection.useFuncs(tunnelB.a1, tunnelA.endTime)) % 360
				if diff1 > 180 then diff1 = math.abs(diff1 - 360) end
				local diff2 = math.abs(intersection.useFuncs(tunnelA.a2, tunnelA.endTime) - intersection.useFuncs(tunnelB.a2, tunnelA.endTime)) % 360
				if diff2 > 180 then diff2 = math.abs(diff2 - 360) end
				if diff1 <= 0.01 and diff2 <= 0.01 then
					tunnelA.endTime = tunnelB.endTime
					for _, func in ipairs(tunnelB.a1) do
						table.insert(tunnelA.a1, func)
					end
					for _, func in ipairs(tunnelB.a2) do
						table.insert(tunnelA.a2, func)
					end
					intersection.glueFuncsTogether(tunnelA.a1)
					intersection.glueFuncsTogether(tunnelA.a2)
					table.remove(tunnels, j)
					j = 0
				end
			end

			j = j + 1
		end

		i = i + 1
	end

	return tunnels
end
function tooly.tunnelOverlapping(tunnel1, tunnel2)
	local intersection = utilitools.files.beattools.intersection
	if not intersection.isTimeOverlapping(tunnel1, tunnel2) then
		return { tunnel1, tunnel2 }
	end

	local returnValue
	local function getIntersections(funcs1, funcs2)
		local returnRoots, fullOverlap = intersection.intersectPerpetuallyMultiple(funcs1, funcs2)
		if returnRoots and #returnRoots ~= 0 then
			returnValue = true
		end
		if fullOverlap and #fullOverlap ~= 0 then
			returnValue = true
		end
	end
	getIntersections(tunnel1.a1, tunnel2.a1)
	getIntersections(tunnel1.a2, tunnel2.a1)
	getIntersections(tunnel1.a1, tunnel2.a2)
	getIntersections(tunnel1.a2, tunnel2.a2)

	return returnValue
end
function tooly.mergeTunnel(tunnel1, tunnel2, canBeEither, onlyOverlap)
	local intersection = utilitools.files.beattools.intersection
	if not intersection.isTimeOverlapping(tunnel1, tunnel2) then
		if onlyOverlap then return {} end
		return { tunnel1, tunnel2 }
	end

	tunnel1 = helpers.copy(tunnel1)
	tunnel2 = helpers.copy(tunnel2)

	local startOverlap, endOverlap = intersection.getOverlappingTime(tunnel1, tunnel2)

	local times = { startOverlap, endOverlap }
	local function getIntersections(funcs1, funcs2)
		local returnRoots, fullOverlap = intersection.intersectPerpetuallyMultiple(funcs1, funcs2)
		for _, time in ipairs(returnRoots) do
			table.insert(times, time)
		end
	end
	getIntersections(tunnel1.a1, tunnel2.a1)
	getIntersections(tunnel1.a2, tunnel2.a1)
	getIntersections(tunnel1.a1, tunnel2.a2)
	getIntersections(tunnel1.a2, tunnel2.a2)
	times = intersection.noDuplicates(times)

	local tunnels = {}
	if not onlyOverlap then
		tunnels = { tunnel1, tunnel2 }
		tunnels = tooly.cutTunnels(tunnels, startOverlap, endOverlap)
	end

	local function mergeTunnelSection(prevTime, time)
		local between = (time + prevTime) / 2
		local ranges1 = tooly.tunnelGetRange(tunnel1, between)
		local ranges2 = tooly.tunnelGetRange(tunnel2, between)
		local function doAddTunnel(tunnel)
			tunnel = helpers.copy(tunnel)
			local addTunnels = { tunnel }
			addTunnels = tooly.cutTunnels(addTunnels, time, nil)
			addTunnels = tooly.cutTunnels(addTunnels, nil, prevTime)
			for _, addTunnel in ipairs(addTunnels) do
				table.insert(tunnels, addTunnel)
			end
		end
		if not ranges1 or not ranges2 then
			if not ranges1 and not ranges2 then
				modwarn(mod, "WHATTTTTTTTTTTTTT", tunnel1, tunnel2)
			elseif ranges1 then
				if not canBeEither then doAddTunnel(tunnel1) end
			else
				if not canBeEither then doAddTunnel(tunnel2) end
			end
		elseif #ranges1 == 0 or #ranges2 == 0 then
			if not canBeEither then
				-- level is impossible, like what are we even supposed to do mane :cranksive:
				modwarn(mod, "LEVEL IS IMPOSSIBLE", prevTime, time)
			elseif #ranges1 == 0 then
				doAddTunnel(tunnel2)
			else
				doAddTunnel(tunnel1)
			end
		else
			local range1 = ranges1[1] -- #ranges2 can only be max of length 1
			local range2 = ranges2[1]
			local totallyOverlapping, partiallyOverlapping, aInB, bInA, a1InB, a2InB, b1InA, b2InA = tooly.overlapRange(range1, range2, false, true)
			local a1, a2 = range1[1], range1[2]
			local b1, b2 = range2[1], range2[2]

			local addTunnels1 = { tunnel1 }
			local addTunnels2 = { tunnel2 }

			addTunnels1 = tooly.cutTunnels(addTunnels1, nil, prevTime)
			addTunnels1 = tooly.cutTunnels(addTunnels1, time, nil)

			addTunnels2 = tooly.cutTunnels(addTunnels2, nil, prevTime)
			addTunnels2 = tooly.cutTunnels(addTunnels2, time, nil)

			local addTunnel1 = addTunnels1[1]
			local addTunnel2 = addTunnels2[1]

			-- time to copy paste the code from the ranges merging hehe
			if totallyOverlapping then
				if a1 == b1 and a2 == b2 then
					-- return { { a1, a2 } }
					table.insert(tunnels, addTunnel1)
				elseif aInB and bInA then
					--[[ if canBeEither then
						return -- all angles allowed
					else
						return { { a1, b2 }, { b1, a2 } }
					end ]]
					if not canBeEither then
						addTunnel1.a2, addTunnel2.a2 = addTunnel2.a2, addTunnel1.a2
						table.insert(tunnels, addTunnel1)
						table.insert(tunnels, addTunnel2)
					end
				elseif aInB then
					--[[ if canBeEither then
						return { { b1, b2 } }
					else
						return { { a1, a2 } }
					end ]]
					if canBeEither then
						table.insert(tunnels, addTunnel2)
					else
						table.insert(tunnels, addTunnel1)
					end
				else -- bInA
					--[[ if canBeEither then
						return { { a1, a2 } }
					else
						return { { b1, b2 } }
					end ]]
					if canBeEither then
						table.insert(tunnels, addTunnel1)
					else
						table.insert(tunnels, addTunnel2)
					end
				end
			elseif partiallyOverlapping then
				--[[ if canBeEither then
					return { { b1InA and a1 or b1, b2InA and a2 or b2 } } -- is bigger than either
				else
					return { { b1InA and b1 or a1, b2InA and b2 or a2 } } -- is smaller than either
				end ]]
				if b1InA ~= canBeEither then
					addTunnel1.a1 = addTunnel2.a1
				else
					-- nothing
				end
				if b2InA ~= canBeEither then
					addTunnel1.a2 = addTunnel2.a2
				else
					-- nothing
				end
				table.insert(tunnels, addTunnel1)
			else
				--[[ if canBeEither then
					return { { a1, a2 }, { b1, b2 } }
				else
					return {} -- level is impossible (in most cases)
				end ]]
				if canBeEither then
					table.insert(tunnels, addTunnel1)
					table.insert(tunnels, addTunnel2)
				else
					-- turns out this is not that bad when it happens, hmmmm
					-- modwarn(mod, "LEVEL IS IMPOSSIBLE", prevTime, time, tooly.currentTunnelIndex, range1, range2)
				end
			end
		end
	end
	if #times == 0 then
		modwarn(mod, "WHAT", tunnel1, tunnel2, canBeEither, onlyOverlap)
	end
	for i, time in ipairs(times) do
		if i ~= 1 then
			mergeTunnelSection(times[i - 1], time)
		end
	end

	tooly.glueTunnelsTogether(tunnels)

	return tunnels
end
function tooly.mergeTunnels(tunnels1, tunnels2, canBeEither)
	local intersection = utilitools.files.beattools.intersection
	if not tunnels1 or not tunnels2 then -- if either allows all angles
		if canBeEither then
			return -- all angles possible
		else
			return tunnels1 or tunnels2
		end
	end
	if #tunnels1 == 0 or #tunnels2 == 0 then -- if either allows no angles
		return #tunnels1 ~= 0 and tunnels1 or tunnels2
	end

	tunnels1 = helpers.copy(tunnels1)
	tunnels2 = helpers.copy(tunnels2)

	local function splitTunnels(tunnels, time)
		local i = 1
		while tunnels[i] do
			local tunnel = tunnels[i]
			if intersection.inTime(tunnel, time) and tunnel.startTime ~= time and tunnel.endTime ~= time then
				local tunnel2 = helpers.copy(tunnel)
				tunnel.endTime = time
				tunnel.a1 = intersection.cutOutFromFuncs(tunnel.a1, time, nil)
				tunnel.a2 = intersection.cutOutFromFuncs(tunnel.a2, time, nil)
				tunnel2.startTime = time
				tunnel2.a1 = intersection.cutOutFromFuncs(tunnel2.a1, nil, time)
				tunnel2.a2 = intersection.cutOutFromFuncs(tunnel2.a2, nil, time)
				table.insert(tunnels, tunnel2)
			end
			i = i + 1
		end
	end
	local tunnelStartsEnds = {}
	for _, tunnel in ipairs(tunnels1) do table.insert(tunnelStartsEnds, tunnel.startTime) table.insert(tunnelStartsEnds, tunnel.endTime) end
	for _, tunnel in ipairs(tunnels2) do table.insert(tunnelStartsEnds, tunnel.startTime) table.insert(tunnelStartsEnds, tunnel.endTime) end
	tunnelStartsEnds = intersection.noDuplicates(tunnelStartsEnds)
	for _, time in ipairs(tunnelStartsEnds) do
		splitTunnels(tunnels1, time)
		splitTunnels(tunnels2, time)
	end

	local totalTunnels = {}
	local finalTunnels = {}
	if canBeEither and false then -- never gets used
		for _, tunnel in ipairs(tunnels1) do
			table.insert(totalTunnels, tunnel)
		end
		for _, tunnel in ipairs(tunnels2) do
			table.insert(totalTunnels, tunnel)
		end

		tooly.glueTunnelsTogether(totalTunnels)

		local i = 1
		while #totalTunnels > 0 do
			i = i + 1
			if i > 1000 then modwarn(mod, "STACK OVERFLOW 1") return end

			local tunnelToCompare = table.remove(totalTunnels)
			local remainingTunnels = {}
			local j = 1
			while #totalTunnels > 0 do
				j = j + 1
				if j > 1000 then modwarn(mod, "STACK OVERFLOW 2") return end

				local singleCompare = tooly.mergeTunnel(tunnelToCompare, table.remove(totalTunnels), true)
				if not singleCompare then
					-- return -- all angles possible
				elseif #singleCompare == 0 then
					for _, tunnel in ipairs(totalTunnels) do
						table.insert(remainingTunnels, tunnel)
					end
					tunnelToCompare = true
					totalTunnels = {}
				else
					tunnelToCompare = table.remove(singleCompare, 1)
					for _, tunnel in ipairs(singleCompare) do
						table.insert(remainingTunnels, tunnel)
					end
				end
			end
			if tunnelToCompare ~= true then
				table.insert(finalTunnels, tunnelToCompare)
			end
			totalTunnels = remainingTunnels
		end
	else
		local i = 1
		while tunnels1[i] do
			local tunnel1 = tunnels1[i]
			local overlapping

			local j = 1
			while tunnels2[j] do
				local tunnel2 = tunnels2[j]

				if intersection.isTimeOverlapping(tunnel1, tunnel2) then
					overlapping = true
					local singleCompare = tooly.mergeTunnel(tunnel1, tunnel2, canBeEither, true)
					if singleCompare then
						table.remove(tunnels2, j)
						for _, tunnel in ipairs(singleCompare) do
							table.insert(tunnels2, tunnel)
						end
						j = -1
					end
				end

				j = j + 1
			end

			if not overlapping then
				table.insert(finalTunnels, tunnel1)
			end

			i = i + 1
		end
		for _, tunnel in ipairs(tunnels2) do table.insert(finalTunnels, tunnel) end

		--[[ for _, tunnel in ipairs(tunnels1) do tunnelsB = tooly.cutTunnels(tunnelsB, tunnel.startTime, tunnel.endTime) end
		for _, tunnel in ipairs(tunnels2) do tunnelsA = tooly.cutTunnels(tunnelsA, tunnel.startTime, tunnel.endTime) end

		for _, tunnel in ipairs(tunnelsA) do table.insert(finalTunnels, tunnel) end
		for _, tunnel in ipairs(tunnelsB) do table.insert(finalTunnels, tunnel) end ]]

		tooly.glueTunnelsTogether(finalTunnels)
	end

	tooly.glueTunnelsTogether(finalTunnels)

	tooly.validateTunnels(finalTunnels)

	return finalTunnels
end
function tooly.getTunnelsForEvent(event)
	local tunnels
	for i = 1, 8 do
		local moreTunnels = tooly.getTunnelsForEventAndPaddle(event, i)
		if moreTunnels then
			if tunnels then
				tunnels = tooly.mergeTunnels(tunnels, moreTunnels, false)
			else
				tunnels = moreTunnels
			end
		end
	end

	return tunnels
end
function tooly.getTunnelsAreas(tunnels)
	local intersection = utilitools.files.beattools.intersection
	local areas = helpers.copy(tunnels)
	local i = 1
	while areas[i] do
		local area1 = { startTime = areas[i].startTime, endTime = areas[i].endTime }
		areas[i] = area1

		local j = i + 1
		while areas[j] do
			local area2 = areas[j]

			if area1 ~= area2 and intersection.isTimeOverlapping(area1, area2, true) then
				area1.startTime = math.min(area1.startTime, area2.startTime)
				area1.endTime = math.max(area1.endTime, area2.endTime)
				table.remove(areas, j)
				j = j - 1
			end

			j = j + 1
		end

		i = i + 1
	end
	return areas
end
function tooly.tunnelsGetRanges(tunnels, antiTunnels, time)
	local intersection = utilitools.files.beattools.intersection
	local ranges
	local startRanges
	local endRanges
	local antiRanges
	if tunnels then
		for _, tunnel in ipairs(tunnels) do
			if intersection.inTime(tunnel, time) then
				local moreRanges = tooly.tunnelGetRange(tunnel, time)
				if moreRanges then
					if tunnel.startTime == time then
						if startRanges then startRanges = tooly.overlapRanges(startRanges, moreRanges, true) else startRanges = moreRanges end
					elseif tunnel.endTime == time then
						if endRanges then endRanges = tooly.overlapRanges(endRanges, moreRanges, true) else endRanges = moreRanges end
					else
						if ranges then ranges = tooly.overlapRanges(ranges, moreRanges, true) else ranges = moreRanges end
					end
				end
			end
		end
	end
	if antiTunnels then
		for _, tunnel in ipairs(antiTunnels) do
			if intersection.inTime(tunnel, time) then
				local moreRanges = tooly.tunnelGetRange(tunnel, time)
				if moreRanges then
					if antiRanges then antiRanges = tooly.overlapRanges(antiRanges, moreRanges, false) else antiRanges = moreRanges end
				end
			end
		end
	end
	startRanges = tooly.overlapRanges(startRanges, endRanges, false)
	ranges = tooly.overlapRanges(startRanges, ranges or {}, true)
	ranges = tooly.overlapRanges(ranges, antiRanges, false)
	return ranges
end

function tooly.getTime(time, delta, retimes)
	if not delta then return time end
	local deltaTime = 0
	if (retimes or tooly.retime) and (retimes or tooly.retime)[1] and time > (retimes or tooly.retime)[1].time then
		local startTime = time
		for _, retime in ipairs(retimes or tooly.retime) do
			if startTime > retime.time then
				time = time - retime.retime
				deltaTime = deltaTime - retime.retime
			else
				break
			end
		end
	end
	return delta and deltaTime or time
end



function tooly.getRangesBetween()
	tooly.retimeIndex = 0
	tooly.retimeValue = 0
	tooly.prevAngle = 0
	tooly.prevTime = 0

	tooly.data = {
		timedRanges = {},
		times = {},
		impossibleRanges = {},
		allTunnels = {}
	}
	local tried = {}
	local progress = { name = "", step = 1, max = 1, index = 0, progressAt = 0.25 }

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

	modlog(mod, "\t\t\tSTARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING STARTING")

	tooly.retime = {}
	tooly.allEvents = {}
	if cs.level.events and #cs.level.events > 0 then
		for _, event in ipairs(cs.level.events) do
			if event.type == "retime" then
				table.insert(tooly.retime, { time = event.time, retime = event.offset })
			end
			if tooly.supported[event.type] then
				table.insert(tooly.allEvents, helpers.copy(event))
			end
		end
	end
	if #tooly.retime > 0 then
		modlog(mod, "retimes", #tooly.retime, tooly.retime[1].retime)

		table.sort(tooly.retime, function(a, b) return a.time < b.time end)

		tooly.data.retime = tooly.retime

		for _, event in ipairs(tooly.allEvents) do
			if event.time > tooly.retime[1].time and false then
				local startTime = event.time
				for _, retime in ipairs(tooly.retime) do
					if startTime > retime.time then
						event.time = event.time - retime.retime
					else
						break
					end
				end
			end
		end
	end

	-- actual start

	if tooly.allEvents and #tooly.allEvents > 0 then
		startProgress("tunnels", #tooly.allEvents)
		tooly.currentTunnelIndex = 0
		for i, event in ipairs(tooly.allEvents) do
			doProgress(i)
			local eventTime = event.time
			if event.type == "mineHold" and (event.duration or 1) ~= 0 then
				utilitools.try(mod, function()
					local moreTunnels = tooly.getTunnelsForEvent(event)
					if moreTunnels then
						if not tooly.validateTunnels(moreTunnels) then
							modlog(mod, event, eventTime, eventTime + event.duration)
						end
						if tooly.data.tunnels then
							tooly.data.tunnels = tooly.mergeTunnels(tooly.data.tunnels, moreTunnels, false)
						else
							tooly.data.tunnels = moreTunnels
						end
					end
					tooly.data.allTunnels[tooly.currentTunnelIndex] = helpers.copy(tooly.data.tunnels)
					tooly.currentTunnelIndex = tooly.currentTunnelIndex + 1
				end)
			end
		end
	end
	if tooly.data.tunnels and #tooly.data.tunnels > 0 then
		tooly.glueTunnelsTogether(tooly.data.tunnels)
		tooly.data.areas = tooly.getTunnelsAreas(tooly.data.tunnels)

		tooly.holdLeniency = true
		tooly.noSides = true

		local eventVisuals = utilitools.files.beattools.eventVisuals
		local i, restart = 1, false
		startProgress("culling", #tooly.data.tunnels)
		while tooly.data.tunnels[i] do
			doProgress(i)
			local tunnel = tooly.data.tunnels[i]
			local success = true
			local intersection = utilitools.files.beattools.intersection

			local function checkRanges(time, overrideTime)
				local ranges = tooly.getRangesForTime(time, tooly.data.tunnels, tooly.data.antiTunnels)
				local rangesTunnel = tooly.tunnelGetRange(tunnel, overrideTime or time)
				if math.abs(rangesTunnel[1][1] - rangesTunnel[1][2]) < 2e-9 then
					rangesTunnel[1][1] = rangesTunnel[1][1] - 1e-9
					rangesTunnel[1][2] = rangesTunnel[1][2] + 1e-9
				end
				local result = tooly.overlapRanges(ranges, rangesTunnel, false)
				return (result and (#result ~= 0 or false)) or (not result and true)
			end

			local diff = math.abs(intersection.useFuncs(tunnel.a1, tunnel.startTime) - intersection.useFuncs(tunnel.a2, tunnel.startTime)) % 360
			if diff > 180 then diff = math.abs(diff - 360) end
			if diff <= 0.01 then
				success = checkRanges(tunnel.startTime - 0.01, tunnel.startTime)
			end
			if success then
				diff = math.abs(intersection.useFuncs(tunnel.a1, tunnel.endTime) - intersection.useFuncs(tunnel.a2, tunnel.endTime)) % 360
				if diff > 180 then diff = math.abs(diff - 360) end
				if diff <= 0.01 then
					success = checkRanges(tunnel.endTime + 0.01, tunnel.endTime)
				end
			end

			if success then
				for time = eventVisuals.getTime(tunnel.startTime) - eventVisuals.step, eventVisuals.getTime(tunnel.endTime) + eventVisuals.step, eventVisuals.step do
					if eventVisuals.eventCache[time] then
						for _, event in pairs(eventVisuals.eventCache[time]) do
							local eventTime = tooly.getTime(event.time)
							if intersection.inTime(tunnel, eventTime) then
								success = success and checkRanges(eventTime)
								if not success then break end
							end
							if tooly.side[event.type] and intersection.inTime(tunnel, eventTime - tooly.msToBeat(eventTime, 100)) then -- hacky fix: a bit scuffed, but it should work in most cases
								success = success and checkRanges(eventTime - tooly.msToBeat(eventTime, 100))
								if not success then break end
							end
							if tooly.hold[event.type] and intersection.inTime(tunnel, eventTime + event.duration) then
								success = success and checkRanges(eventTime + event.duration)
								if not success then break end
							end
						end
						if not success then break end
					end
				end
			end
			if not success then
				table.remove(tooly.data.tunnels, i)
				tooly.data.antiTunnels = tooly.data.antiTunnels or {}
				tunnel.a1, tunnel.a2 = intersection.addFunctions(tunnel.a2,
					{ { startTime = tunnel.startTime, endTime = tunnel.endTime, a0 = 0.01 --[[ + 0.001 ]] } }
				), intersection.addFunctions(tunnel.a1,
					{ { startTime = tunnel.startTime, endTime = tunnel.endTime, a0 = -0.01 --[[ + 0.001 ]] } }
				)
				table.insert(tooly.data.antiTunnels, tunnel)
				restart = true
				i = i - 1
			end

			i = i + 1
			if not tooly.data.tunnels[i] and restart then
				restart = false
				i = 1
				progress.max = #tooly.data.tunnels
			end
		end

		tooly.holdLeniency = false
		tooly.noSides = false

		if tooly.data.antiTunnels then
			tooly.glueTunnelsTogether(tooly.data.antiTunnels)
			tooly.validateTunnels(tooly.data.antiTunnels)
		end

		tooly.validateTunnels(tooly.data.tunnels)

		modlog(mod, #tooly.data.tunnels) -- , tooly.data.tunnels)
	end

	local function addTime(time)
		if tried[time] then return end
		tried[time] = true
		local did = "normal"
		tooly.data.timedRanges[time] = tooly.getRangesForTime(time, tooly.data.tunnels, tooly.data.antiTunnels)
		if tooly.data.timedRanges[time] then
			if #tooly.data.timedRanges[time] == 0 then
				tooly.holdLeniency = true
				did = "hold leniency"
				tooly.data.timedRanges[time] = tooly.getRangesForTime(time, tooly.data.tunnels, tooly.data.antiTunnels)
				if tooly.sidesAfter then -- hacky fix, have to improve this later
					did = "hold leniency, sides after"
				elseif tooly.data.timedRanges[time] and #tooly.data.timedRanges[time] == 0 then
					tooly.noSides = true
					did = "hold leniency, no sides"
					tooly.data.timedRanges[time] = tooly.getRangesForTime(time, tooly.data.tunnels, tooly.data.antiTunnels)
					tooly.noSides = false

					if not (tooly.data.timedRanges[time] and #tooly.data.timedRanges[time] == 0) then
						tooly.sidesAfter = true
						addTime(time + tooly.msToBeat(time, 50))
						tooly.sidesAfter = false
					end
				end
				tooly.holdLeniency = false
			end
			if tooly.data.timedRanges[time] and #tooly.data.timedRanges[time] == 0 then
				modlog(mod, time, "IMPOSSIBLE GAMEPLAY?", did, tooly.data.timedRanges[time])
				tooly.data.timedRanges[time] = nil
				tooly.data.impossibleRanges[time] = true
			end
			if tooly.data.timedRanges[time] then table.insert(tooly.data.times, time) end
		end
	end
	if tooly.allEvents and #tooly.allEvents > 0 then
		startProgress("events", #tooly.allEvents)
		for i, event in ipairs(tooly.allEvents) do
			doProgress(i)
			if tooly.supported[event.type] then
				local eventTime = event.time
				addTime(eventTime)
				if tooly.hold[event.type] then
					addTime(eventTime + event.duration)
				end
				if tooly.bounce[event.type] then
					for j = 1, event.bounces do
						addTime(eventTime + j * event.delay)
					end
				end
				if tooly.side[event.type] then -- hacky fix: a bit scuffed, but it should work in most cases
					addTime(eventTime - tooly.msToBeat(eventTime, 100))
				end
			end
		end
	end
	if tooly.data.tunnels and #tooly.data.tunnels > 0 then
		startProgress("tunnelEnds", #tooly.data.tunnels)
		for i, tunnel in ipairs(tooly.data.tunnels) do
			doProgress(i)
			addTime(tunnel.startTime)
			addTime(tunnel.endTime)
		end
	end

	--[[ local biggestBeat = utilitools.files.beattools.biggestBeat
	startProgress("holds", biggestBeat.max - biggestBeat.min, nil, 1 / 4 / 3)
	for i = biggestBeat.min, biggestBeat.max, step do
		doProgress(i - biggestBeat.min)
		addTime(i)
	end ]]

	if tooly.data.times and #tooly.data.times > 0 then
		startProgress("merging", #tooly.data.times)
		local function removeIndex(i)
			tooly.data.timedRanges[tooly.data.times[i]] = nil
			table.remove(tooly.data.times, i)
		end
		table.sort(tooly.data.times) local i = 1
		while tooly.data.times[i] do
			local time = tooly.data.times[i]
			if i ~= 1 then
				if math.abs(time - tooly.data.times[i - 1]) < tooly.merge then
					local moreRanges = tooly.data.timedRanges[time]
					local prevTime = tooly.data.times[i - 1]
					local ranges = tooly.data.timedRanges[prevTime]
					local merged = tooly.overlapRanges(moreRanges, ranges, false)
					if merged then
						if #merged == 0 then
							modlog(mod, prevTime, time, "IMPOSSIBLE GAMEPLAY?", "merged", ranges, moreRanges, merged)
							-- dont remove, keep the same
							-- removeIndex(i)
							-- i = i - 1
							-- tooly.data.impossibleRanges[prevTime] = true
							-- removeIndex(i)
							-- i = i - 1
							-- tooly.data.impossibleRanges[time] = true
						else
							tooly.data.timedRanges[prevTime] = merged
							tooly.data.timedRanges[time] = merged
						end
					else -- all angles possible
						removeIndex(i)
						i = i - 1
						removeIndex(i)
						i = i - 1
					end
				end
			end
			i = i + 1
		end
		startProgress(false)
	end
	modlog(mod, "\t\t\tDONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE! DONE!")
	return tooly.data
end



function tooly.getClosestDelta(a1, a2)
	local delta = a2 - a1
	if math.abs(delta) >= 360 then delta = (math.abs(delta) % 360) * (delta < 0 and -1 or 1) end
	if math.abs(delta) >= 180 then delta = delta - 360 * (delta < 0 and -1 or 1) end
	return delta
end
function tooly.getClosestData(data, time)
	tooly.data = data
	for _, nextTime in ipairs(tooly.data.times) do
		if nextTime >= time then
			return tooly.data.timedRanges[nextTime], nextTime
		end
	end
	return tooly.data.timedRanges[tooly.data.times[#tooly.data.times]], tooly.data.times[#tooly.data.times]
end
function tooly.play(data, time)
	tooly.data = data
	cs.autoplay = false
	if not (cs.name == "Game" or (cs.name == "Editor" and not cs.editMode)) or not cs.p or not time or not mod.config.tooly then return end

	local delta = -tooly.getTime(time, true, tooly.data.retime)

	local nextRanges, nextTime = tooly.getClosestData(tooly.data, tooly.prevTime + delta)
	if not nextRanges or #nextRanges == 0 or not nextTime then return end

	local nextAngles = {}
	for i, range in ipairs(nextRanges) do
		local width = tooly.getWidth(range)
		nextAngles[i] = {
			a = range[1] + width / 2,
			b = math.min(
				math.abs(tooly.getClosestDelta(tooly.prevAngle, range[1] + width / 2)),
				math.abs(tooly.getClosestDelta(tooly.prevAngle, range[1])),
				math.abs(tooly.getClosestDelta(tooly.prevAngle, range[2]))
			)
		}
		--[[ if width < 180 or true then
		elseif isBetween(tooly.prevAngle, (range[1] + 15) % 360, (range[2] - 15) % 360) then
			nextAngles[i] = tooly.prevAngle
		else
			nextAngles[i] = math.abs(tooly.getClosestDelta(tooly.prevAngle, range[1])) <= math.abs(tooly.getClosestDelta(tooly.prevAngle, range[2])) and range[1] + 15 or range[2] - 15
		end ]]
	end
	table.sort(nextAngles, function(a, b) return a.b < b.b end)
	local prevAngle = tooly.prevAngle
	local nextAngle = nextAngles[1].a
	local angle = prevAngle + tooly.getClosestDelta(prevAngle, nextAngle) * (nextTime - (tooly.prevTime + delta) <= 0 and 0 or math.max(0, math.min(1, (time - tooly.prevTime) / (nextTime - (tooly.prevTime + delta)))))
	angle = cs.p.angle + tooly.getClosestDelta(cs.p.angle, angle)

	-- modlog(mod, nextTime - (tooly.prevTime + delta))

	cs.autoplay = true
	cs.p.anglePrevFrame = cs.p.angle
	cs.p.angle = angle
	tooly.prevAngle = angle
	tooly.prevTime = time
end

return tooly