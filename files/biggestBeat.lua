local biggestBeat = {
	min = 0,
	max = 0,
	listen = { type = true, time = true, duration = true, bounces = true, delay = true, repeats = true, repeatDelay = true },
	radiiSmallest = {},
	radiiBiggest = {},
	multiselectMin = nil,
	multiselectMax = nil,
	drawMultiselect = false
}

function biggestBeat.init()
	biggestBeat.min = 0
	biggestBeat.max = 0
	biggestBeat.radiiSmallest = {}
	biggestBeat.radiiBiggest = {}
	biggestBeat.multiselectMin = nil
	biggestBeat.multiselectMax = nil
	biggestBeat.drawMultiselect = false
end

function biggestBeat.cacheEvent(event, remove, k)
	local eventVisuals = utilitools.files.beattools.eventVisuals

	local duration = event.duration or 0
	local bounces = event.type == "bounce" and (event.bounces or 1) * (event.delay or 1) or 0
	local repeated = eventVisuals.hasRepeat[event.type] and (event.repeats or 0) * (event.repeatDelay or 1) or 0

	if remove then
		if biggestBeat.min == event.time then
			biggestBeat.min = 0
			for i = eventVisuals.getTime(event.time), eventVisuals.getTime(-eventVisuals.step), eventVisuals.step do
				i = eventVisuals.getTime(i)
				if eventVisuals.eventCache[i] then
					biggestBeat.min = i + eventVisuals.step
					for _, event2 in pairs(eventVisuals.eventCache[i]) do
						if event ~= event2 then
							biggestBeat.min = math.min(biggestBeat.min, event2.time)
						end
					end
					break
				end
			end
		end
		if biggestBeat.max == event.time + duration + bounces + repeated then
			biggestBeat.max = 0
			for i = eventVisuals.getTime(event.time), eventVisuals.getTime(0), -eventVisuals.step do
				i = eventVisuals.getTime(i)
				if eventVisuals.eventCache[i] then
					biggestBeat.max = i
					for _, event2 in pairs(eventVisuals.eventCache[i]) do
						if event ~= event2 then
							local duration2 = event2.duration or 0
							local bounces2 = event2.type == "bounce" and (event2.bounces or 1) * (event2.delay or 1) or 0
							local repeated2 = eventVisuals.hasRepeat[event2.type] and (event2.repeats or 0) * (event2.repeatDelay or 1) or 0

							biggestBeat.max = math.max(biggestBeat.max, event2.time + duration2 + bounces2 + repeated2)
						end
					end
					break
				end
			end
		end
	else
		biggestBeat.min = math.min(biggestBeat.min, event.time)
		biggestBeat.max = math.max(biggestBeat.max, event.time + duration + bounces + repeated)
	end
end

function biggestBeat.drawBiggestBeat()
	biggestBeat.radiiSmallest = {}
	biggestBeat.radiiBiggest = {}
	biggestBeat.multiselectMin = nil
	biggestBeat.multiselectMax = nil
	biggestBeat.drawMultiselect = false

	local function addRadius(beat, biggest, data)
		biggest = biggest and "radiiBiggest" or "radiiSmallest"
		data = data or {}
		biggestBeat[biggest][beat] = biggestBeat[biggest][beat] or {}
		table.insert(biggestBeat[biggest][beat], data or {})
	end
	local function drawBeat(time, biggest, data, offset)
		-- modlog(mod, biggest, offset)
		if offset == 0 or (biggest and offset <= 1) then
			love.graphics.setLineWidth(2)
		else
			offset = offset - 0.5
		end
		offset = offset * (biggest and 1 or -1)

		if data.color and (data.color.r or data.color.g or data.color.b) then
			love.graphics.setColor(data.color.r, data.color.g, data.color.b)
		else
			love.graphics.setColor(unpack(data.color or { 1, 1, 1 }))
		end

		if data.angleStart and data.angleEnd and math.abs(data.angleEnd - data.angleStart) < 360 then
			love.graphics.arc("line", "open", project.res.cx, project.res.cy, cs:beatToRadius(time) + offset, math.rad(data.angleStart - 90), math.rad(data.angleEnd - 90))
			if data.multi then
				if biggest then
					biggestBeat.multiselectMax = cs:beatToRadius(time) + offset + 1.5 * (biggest and 1 or -1)
				else
					biggestBeat.multiselectMin = cs:beatToRadius(time) + offset + 1.5 * (biggest and 1 or -1)
				end
			end
		else
			love.graphics.circle("line", project.res.cx, project.res.cy, cs:beatToRadius(time) + offset)
			if data.multi then
				if biggest then
					biggestBeat.multiselectMax = cs:beatToRadius(time) + offset + 1.5 * (biggest and 1 or -1)
				else
					-- biggestBeat.multiSelectMin = cs:beatToRadius(time) + offset + 1.5 * (biggest and 1 or -1)
				end
			end
		end
		if offset == 0 then
			love.graphics.setLineWidth(3)
		end
	end
	local function drawAllBeats(biggest)
		local t = biggestBeat[biggest and "radiiBiggest" or "radiiSmallest"]
		local t2 = biggestBeat[not biggest and "radiiBiggest" or "radiiSmallest"]
		---@diagnostic disable-next-line: param-type-mismatch
		for time, radii in pairs(t) do
			local onBeatLine = (
				(
					time == cs.editorBeat
				) or (
					not mod.config.multiselectRings and cs.multiselectStartBeat and time == cs.multiselectStartBeat
				) or (
					not mod.config.multiselectRings and cs.multiselectEndBeat and time == cs.multiselectEndBeat
				) or (
					time % 1 == 0
				) or (
					cs.beatSnap ~= 0 and (time % 1) % (1 / cs:getBeatSnapValue()) == 0
				)
			) and 0 or -2
			onBeatLine = onBeatLine + (onBeatLine == -2 and t2 and t2[time] and #t2[time] > 0 and 1 or 0)
			if cs.editorBeat <= time and time <= cs.editorBeat + cs.drawDistance then
				for i = #radii, 1, -1 do
					local data = radii[i]
					if not data.dontDraw then
						drawBeat(time, biggest, data, i * 2 + onBeatLine)
					end
				end
			end
		end
	end

	if mod.config.bookmarkRings and utilitools.files.beattools.easing.list.bookmark and utilitools.files.beattools.easing.list.bookmark["_"] and utilitools.files.beattools.easing.list.bookmark["_"]["_"] then
		for i, bookmark in ipairs(utilitools.files.beattools.easing.list.bookmark["_"]["_"]) do
			local event = bookmark.event
			addRadius(event.time, false, { color = { love.math.colorFromBytes(event.r, event.g, event.b) } })
			addRadius(event.time, true, { color = { love.math.colorFromBytes(event.r, event.g, event.b) } })
		end
	end

	if mod.config.biggestBeatsRings then
		addRadius(biggestBeat.min, false, { color = mod.config.biggestBeatsColor })
		addRadius(biggestBeat.max, true, { color = mod.config.biggestBeatsColor })
	end
	if cs.level and cs.level.properties then
		if mod.config.startingBeatRing then
			addRadius(cs.level.properties.startingBeat or -8, false, { color = mod.config.startingBeatColor })
		end
		if mod.config.loadBeatRing and cs.level.properties.loadBeat then
			addRadius(cs.level.properties.loadBeat, true, { color = mod.config.loadBeatColor })
		end
	end

	if mod.config.multiselectRings and cs.multiselectStartBeat then
		if cs.multiselectEndBeat >= cs.editorBeat or cs.multiselectStartBeat == cs.editorBeat then
			addRadius(math.max(cs.editorBeat, cs.multiselectStartBeat), cs.multiselectEndBeat < cs.multiselectStartBeat, { color = mod.config.multiselectColor, angleStart = cs.multiselectStartAngle, angleEnd = cs.multiselectEndAngle, multi = true })
		end
		if math.max(cs.editorBeat, cs.multiselectEndBeat) == cs.editorBeat then
			biggestBeat.drawMultiselect = true
		end
		addRadius(math.max(cs.editorBeat, cs.multiselectEndBeat), cs.multiselectEndBeat >= cs.multiselectStartBeat, { color = mod.config.multiselectColor, angleStart = cs.multiselectStartAngle, angleEnd = cs.multiselectEndAngle, multi = true })
	end

	love.graphics.setLineWidth(3)
	drawAllBeats(false)
	drawAllBeats(true)
	love.graphics.setLineWidth(2)
end

function biggestBeat.drawAboveBeatLines()
	if mod.config.multiselectRings and not biggestBeat.multiselectMin and biggestBeat.multiselectMax and biggestBeat.drawMultiselect then
		love.graphics.setLineWidth(3)
		love.graphics.setColor(mods.beattools.config.multiselectColor.r, mods.beattools.config.multiselectColor.g, mods.beattools.config.multiselectColor.b, 1)

		if cs.multiselectStartAngle and cs.multiselectEndAngle and math.abs(cs.multiselectEndAngle - cs.multiselectStartAngle) < 360 then
			love.graphics.arc("line", "open", project.res.cx, project.res.cy, biggestBeat.multiselectMax - 1.5, math.rad(cs.multiselectStartAngle - 90), math.rad(cs.multiselectEndAngle - 90))
		else
			love.graphics.circle("line", project.res.cx, project.res.cy, biggestBeat.multiselectMax - 1.5)
		end

		love.graphics.setLineWidth(2)
	end
end

function biggestBeat.drawMultiAngles()
	(function()
		if not (mod.config.multiselectRings and biggestBeat.multiselectMin and biggestBeat.multiselectMax) then return end

		love.graphics.setLineWidth(2)
		love.graphics.setColor(mods.beattools.config.multiselectColor.r, mods.beattools.config.multiselectColor.g, mods.beattools.config.multiselectColor.b, 1)

		local pos1 = helpers.rotate(biggestBeat.multiselectMin, cs.multiselectStartAngle, project.res.cx, project.res.cy)
		local pos2 = helpers.rotate(biggestBeat.multiselectMax, cs.multiselectStartAngle, project.res.cx, project.res.cy)
		love.graphics.line(pos1[1], pos1[2], pos2[1], pos2[2])

		pos1 = helpers.rotate(biggestBeat.multiselectMin, cs.multiselectEndAngle, project.res.cx, project.res.cy)
		pos2 = helpers.rotate(biggestBeat.multiselectMax, cs.multiselectEndAngle, project.res.cx, project.res.cy)
		love.graphics.line(pos1[1], pos1[2], pos2[1], pos2[2])
	end)()



	if not beattools.test or not beattools.test.timedRanges then return end
	if mod.config.test == -1 then
		love.graphics.setColor(love.math.colorFromBytes(0, 0, 128, 255))
		for time, ranges in pairs(beattools.test.timedRanges) do
			if cs.editorBeat <= time and time <= cs.editorBeat + cs.drawDistance then
				if not ranges then
					love.graphics.circle("line", project.res.cx, project.res.cy, cs:beatToRadius(time))
				else
					local tooly = utilitools.files.beattools.tooly
					for _, range in ipairs(ranges) do
						local width = tooly.getWidth(range)
						love.graphics.arc("line", "open", project.res.cx, project.res.cy, cs:beatToRadius(time), math.rad(range[1] - 90), math.rad(range[1] + width - 90))
					end
				end
			end
		end
		love.graphics.setColor(love.math.colorFromBytes(255, 0, 0))
		for time, _ in pairs(beattools.test.impossibleRanges) do
			if cs.editorBeat <= time and time <= cs.editorBeat + cs.drawDistance then
				love.graphics.circle("line", project.res.cx, project.res.cy, cs:beatToRadius(time))
			end
		end
	end

	local intersection = utilitools.files.beattools.intersection
	local oldSize = love.graphics.getPointSize()
	love.graphics.setPointSize(2)
	local pointAccuracy = 1 / 16 / 16
	local function drawTunnels(tunnels, pastel)
		local function drawFunc(func, i)
			for t = func.startTime + pointAccuracy, func.endTime + pointAccuracy, pointAccuracy do
				local time = helpers.clamp(t, math.min(func.startTime + pointAccuracy, func.endTime), func.endTime)
				local prevTime = helpers.clamp(t - pointAccuracy, func.startTime, func.endTime)
				if time ~= prevTime and cs.editorBeat <= time and prevTime <= cs.editorBeat + cs.drawDistance then
					local prevAngle = intersection.useFunc(func, prevTime) + i * 0.01
					local prevPos = cs:getPosition(prevAngle, prevTime)
					local angle = intersection.useFunc(func, time) + i * 0.01
					local pos = cs:getPosition(angle, time)
					love.graphics.line(prevPos[1], prevPos[2], pos[1], pos[2])
				end
			end
		end
		for i, tunnel in pairs(tunnels) do
			local max = math.min(#tunnels, 8)
			love.graphics.setColor(utilitools.color.hsvToRgb(((i - 1) % max) / max * 360, pastel and 0.25 or 1, pastel and 0.5 or 1))
			if intersection.isTimeOverlapping(tunnel, { startTime = cs.editorBeat, endTime = cs.editorBeat + cs.drawDistance }) then
				for _, a in ipairs({ "a1", "a2" }) do
					local funcs = tunnel[a]
					for _, func in ipairs(funcs) do
						if intersection.isTimeOverlapping(func, { startTime = cs.editorBeat, endTime = cs.editorBeat + cs.drawDistance }) then
							drawFunc(func, i)
						end
					end
				end
			end
		end
	end
	if beattools.test.tunnels then
		local tunnelsToDraw = mod.config.test and mod.config.test ~= -1 and beattools.test.allTunnels and beattools.test.allTunnels[mod.config.test] or beattools.test.tunnels
		drawTunnels(tunnelsToDraw, false)
	end
	if mod.config.test == -1 and beattools.test.antiTunnels then
		drawTunnels(beattools.test.antiTunnels, true)
	end
	love.graphics.setPointSize(oldSize)
end

return biggestBeat