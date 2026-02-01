local indices = {}
local function getFreeIndex(startTime, endTime)
	local i = 0
	while (function()
		if indices[i] == nil then indices[i] = {} return false end
		for _, v in ipairs(indices[i]) do if v.startTime <= endTime and v.endTime >= startTime then return true end end
		return false
	end)() do i = i + 1 end
	table.insert(indices[i], { startTime = startTime, endTime = endTime })
	return i
end

local function grid()
	local events = {}
	local gridSize = 30
	local gridLineWidth = 2
	local gridWidth = 45
	local gridNormal = 45
	local moveDuration = 0.5
	local appearDuration = 32

	for i = -1, 1, 2 do
		table.insert(events, {
			time = 0, angle = 0, type = "deco", order = 0,
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_shift",
			hide = true,
			x = 0, y = 0
		})
		table.insert(events, {
			time = 1 - moveDuration, angle = 0, type = "deco", order = 1,
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_shift",
			x = gridNormal * -i,
			duration = moveDuration, ease = "outQuad"
		})
		table.insert(events, {
			time = 1 + appearDuration, angle = 0, type = "deco",
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_shift",
			x = 0,
			duration = moveDuration, ease = "outQuad"
		})
		table.insert(events, {
			time = 0, angle = 0, type = "deco",
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_main",
			parentid = "generated_grid_" .. (i == -1 and "right" or "left") .. "_shift",
			hide = false,
			sprite = "pixel.png", ox = 0.5, oy = 0, recolor = 6,
			sx = gridLineWidth, sy = 360,
			x = 300 + 300 * i, y = 0
		})
		table.insert(events, {
			time = 1 + appearDuration + moveDuration, angle = 0, type = "deco",
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_main",
			hide = true
		})
		table.insert(events, {
			time = 0, angle = 0, type = "deco",
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_0",
			parentid = "generated_grid_" .. (i == -1 and "right" or "left") .. "_main",
			hide = true,
			x = 0, y = 0
		})
		table.insert(events, {
			time = 0, angle = 0, type = "deco",
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_1",
			parentid = "generated_grid_" .. (i == -1 and "right" or "left") .. "_main",
			hide = true,
			x = 0, y = 0
		})
		table.insert(events, {
			time = 0, angle = 0, type = "deco",
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_0_1",
			parentid = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_0",
			hide = true,
			x = 0, y = 0
		})
		table.insert(events, {
			time = 0, angle = 0, type = "deco",
			id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_1_1",
			parentid = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_1",
			hide = true,
			x = 0, y = 0
		})
		for j = 1, math.ceil((360 + gridWidth) / gridSize) do
			table.insert(events, {
				time = 0, angle = 0, type = "deco",
				id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_" .. j .. "_0",
				parentid = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_0_1",
				hide = false,
				sprite = "pixel.png", ox = (-i + 1) / 2, oy = 0.5, recolor = 6,
				sx = gridWidth * math.sqrt(2) + gridLineWidth / 2 * 0, sy = gridLineWidth,
				x = 0, y = j * gridSize - gridWidth * (i + 1) / 2 - gridSize, r = 45
			})
			table.insert(events, {
				time = 0, angle = 0, type = "deco",
				id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_" .. j .. "_1",
				parentid = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_1_1",
				hide = false,
				sprite = "pixel.png", ox = (-i + 1) / 2, oy = 0.5, recolor = 6,
				sx = gridWidth * math.sqrt(2) + gridLineWidth / 2, sy = gridLineWidth,
				x = 0, y = j * gridSize - gridWidth * (-i + 1) / 2 - gridSize, r = -45
			})
			table.insert(events, {
				time = 1 + appearDuration + moveDuration, angle = 0, type = "deco",
				id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_" .. j .. "_0",
				hide = true,
			})
			table.insert(events, {
				time = 1 + appearDuration + moveDuration, angle = 0, type = "deco",
				id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_" .. j .. "_1",
				hide = true,
			})
		end
	end

	local function move(index, time, dir)
		for i = -1, 1, 2 do
			table.insert(events, {
				time = time, angle = 0, type = "deco",
				id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_" .. index .. "_1",
				y = 0
			})
			table.insert(events, {
				time = time, angle = 0, type = "deco", order = 0,
				id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_" .. index,
				y = dir == 1 and 0 or gridSize
			})
			table.insert(events, {
				time = time, angle = 0, type = "deco", order = 1,
				id = "generated_grid_" .. (i == -1 and "right" or "left") .. "_delta_" .. index,
				y = dir == 1 and gridSize or 0,
				duration = moveDuration, ease = "outQuad"
			})
		end
	end

	for i = 1, appearDuration + 1 - moveDuration, moveDuration * 4 do
		move(0, i, 1)
		move(1, i, -1)
		i = i + moveDuration
		move(0, i, 1)
		move(1, i, 1)
		i = i + moveDuration
		move(0, i, -1)
		move(1, i, 1)
		i = i + moveDuration
		move(0, i, -1)
		move(1, i, -1)
	end

	if not love.filesystem.inSaveData(cLevel) then love.filesystem.forceSaveInSource(true) end
	dpf.saveJson(cLevel .. "tags/generated.json", events)
	love.filesystem.forceSaveInSource(false)
end
local function boxes()
	local events = {}
	local repeats = 22
	local repeatDelay = 1

	local startSize = 30
	local maxSize = 60
	local edgeWidth = 200
	local appearDuration = 1
	local duration = 0.5
	local pulse = 0.25
	local hasBeams = true

	local function createBox(i)
		local index = getFreeIndex(i - appearDuration, i + appearDuration)
		local index2 = getFreeIndex(i, i + appearDuration)
		local index3 = getFreeIndex(i, i + appearDuration)
		local index4 = getFreeIndex(i, i + appearDuration)
		local pos = math.random(2) * 2 - 3
		local rot = math.random(2) * 2 - 3
		local x = 300 + math.random(300 - edgeWidth + maxSize / 2, 300 - maxSize / 2) * pos
		local y = math.random(maxSize / 2, 360 - maxSize / 2)
		table.insert(events, {
			time = i - appearDuration, angle = 0, type = "deco", order = 0,
			id = "generated_box_" .. index,
			hide = false,
			sprite = "pixel.png", ox = 0.5, oy = 0.5, recolor = 5,
			drawLayer = hasBeams and "fg" or "bg", drawOrder = 0,
			sx = startSize, sy = startSize,
			x = x, y = y, r = 0,
			alphadither = true, ditherpercent = 0
		})
		table.insert(events, {
			time = i - appearDuration, angle = 0, type = "deco", order = 1,
			id = "generated_box_" .. index,
			sx = maxSize, sy = maxSize,
			ditherpercent = 1,
			duration = appearDuration, ease = "linear"
		})
		table.insert(events, { -- pulse outer
			time = i, angle = 0, type = "deco", order = 0,
			id = "generated_box_" .. index, recolor = 6,
			drawLayer = "fg", drawOrder = 2,
			sx = 0, sy = 0,
			alphadither = false
		})
		table.insert(events, {
			time = i, angle = 0, type = "deco", order = 1,
			id = "generated_box_" .. index,
			sx = maxSize, sy = maxSize,
			duration = pulse, ease = "outQuad"
		})
		table.insert(events, {
			time = i + pulse + duration, angle = 0, type = "deco",
			id = "generated_box_" .. index,
			sx = 0, sy = 0, r = 45 * rot,
			duration = pulse, ease = "inQuad"
		})
		table.insert(events, { -- pulse inner
			time = i, angle = 0, type = "deco", order = 0,
			id = "generated_box_" .. index2,
			hide = false,
			sprite = "pixel.png", ox = 0.5, oy = 0.5, recolor = 5,
			drawLayer = "fg", drawOrder = 3,
			x = x, y = y, r = 0,
			sx = 0, sy = 0
		})
		table.insert(events, {
			time = i, angle = 0, type = "deco", order = 1,
			id = "generated_box_" .. index2,
			sx = maxSize * 0.7, sy = maxSize * 0.7,
			duration = pulse, ease = "outQuad"
		})
		table.insert(events, {
			time = i + pulse + duration, angle = 0, type = "deco",
			id = "generated_box_" .. index2,
			sx = 0, sy = 0, r = 45 * rot,
			duration = pulse, ease = "inQuad"
		})
		table.insert(events, { -- pulse ring outer
			time = i, angle = 0, type = "deco", order = 0,
			id = "generated_box_" .. index3,
			hide = false,
			sprite = "pixel.png", ox = 0.5, oy = 0.5, recolor = 6,
			drawLayer = "fg", drawOrder = 4,
			x = x, y = y, r = 0,
			sx = 0, sy = 0
		})
		table.insert(events, {
			time = i, angle = 0, type = "deco", order = 1,
			id = "generated_box_" .. index3,
			sx = maxSize * 0.4, sy = maxSize * 0.4,
			duration = pulse, ease = "outQuad"
		})
		table.insert(events, {
			time = i + pulse + duration, angle = 0, type = "deco",
			id = "generated_box_" .. index3,
			sx = 0, sy = 0, r = 45 * rot,
			duration = pulse, ease = "inQuad"
		})
		table.insert(events, { -- pulse ring inner
			time = i, angle = 0, type = "deco", order = 0,
			id = "generated_box_" .. index4,
			hide = false,
			sprite = "pixel.png", ox = 0.5, oy = 0.5, recolor = 5,
			drawLayer = "fg", drawOrder = 5,
			x = x, y = y, r = 0,
			sx = 0, sy = 0
		})
		table.insert(events, {
			time = i, angle = 0, type = "deco", order = 1,
			id = "generated_box_" .. index4,
			sx = maxSize * 0.3, sy = maxSize * 0.3,
			duration = pulse, ease = "outQuad"
		})
		table.insert(events, {
			time = i + pulse + duration, angle = 0, type = "deco",
			id = "generated_box_" .. index4,
			sx = 0, sy = 0, r = 45 * rot,
			duration = pulse, ease = "inQuad"
		})
	end

	for i = 0, repeats, repeatDelay do if i > 7 then hasBeams = false end createBox(i) forceprint(i) end
	createBox(22) createBox(22.5) createBox(22.5)

	if not love.filesystem.inSaveData(cLevel) then love.filesystem.forceSaveInSource(true) end
	dpf.saveJson(cLevel .. "tags/generated.json", events)
	love.filesystem.forceSaveInSource(false)
end
local function beams()
	modlog(mod, "BEAMS")
	local events = {}
	local beamShaders = {}

	local pulseDuration = 0.125
	local inactiveTime = 1

	local speedMult = 50

	local function setInactiveTime(time, val)
		table.insert(
			events,
			{
				type = "shader_uniform",
				time = time, angle = 0,
				var = "inactiveTime",
				value = val
			}
		)
	end

	local function asin(value) if math.abs(value) > 1 then modlog(mod, table.concat({"ASIN INVALID:", value}, " ")); end return 90 - math.asin(value) / math.pi * 180 end
	local function randomValue(min, range) return math.floor(math.random() * range) + min; end

	local function mineHold(time, angle, duration, rotateSpeed, ease)
		table.insert(events, { type = "mineHold", time = time, angle = angle, angle2 = angle + rotateSpeed * duration, duration = duration, holdEase = ease, speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide" .. duration })
	end

	local function newBeam(time, r, rotateSpeed, x, width, activeTime, ease, easeIn, easeOut, parent, type)
		type = type or 0
		table.insert(beamShaders, { time = time, angle = r * math.pi / 180, distance = x, width = width / 2, type = type })
		if x + width / 2 > 30 and x - width / 2 < -30 then
			modlog(mod, table.concat({ "BEAM TOO LARGE:", 30, time, r, x, width }, " "))
		elseif x - width / 2 > 42 or x + width / 2 < -42 then -- Beam out of range
			-- do nothing
		elseif x + width / 2 > 30 and x - width / 2 >= 0 then
			table.insert( -- Beam covers less than top half
				events,
				{
					type = "mineHold",
					time = time,
					angle = r + asin((x - width / 2) / 42) + 90,
					angle2 = r - asin((x - width / 2) / 42) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			mineHold(time, r + asin((x - width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x - width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
		elseif x - width / 2 < -30 and x + width / 2 <= 0 then -- Beam covers less than bottom half
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r + asin((x + width / 2) / 42) + 90,
					angle2 = r - asin((x + width / 2) / 42) + 90 + 360,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			mineHold(time, r + asin((x + width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x + width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
		elseif x + width / 2 > 30 then -- Beam covers more than top half
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r + asin((x - width / 2) / 30) + 90,
					angle2 = r - asin((x - width / 2) / 30) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			mineHold(time, r + asin((x - width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x - width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
		elseif x - width / 2 < -30 then -- Beam covers more than bottom half
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r + asin((x + width / 2) / 30) + 90,
					angle2 = r - asin((x + width / 2) / 30) + 90 + 360,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			mineHold(time, r + asin((x + width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x + width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
		elseif x + width / 2 >= 0 and x - width / 2 <= 0 then -- Beam is in the middle
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r + asin((x - width / 2) / 30) + 90,
					angle2 = r + asin((x + width / 2) / 30) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r - asin((x - width / 2) / 30) + 90,
					angle2 = r - asin((x + width / 2) / 30) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			mineHold(time, r + asin((x - width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x - width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r + asin((x + width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x + width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
		elseif x - width / 2 >= 0 then -- Beam is in the upper area
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r + asin((x - width / 2) / 42) + 90,
					angle2 = r + asin((x + width / 2) / 30) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r - asin((x - width / 2) / 42) + 90,
					angle2 = r - asin((x + width / 2) / 30) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			mineHold(time, r + asin((x - width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x - width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r + asin((x + width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x + width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
		elseif x + width / 2 < 0 then -- Beam is in the lower area
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r + asin((x - width / 2) / 30) + 90,
					angle2 = r + asin((x + width / 2) / 42) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			table.insert(
				events,
				{
					type = "mineHold",
					time = time,
					angle = r - asin((x - width / 2) / 30) + 90,
					angle2 = r - asin((x + width / 2) / 42) + 90,
					duration = 0,
					speedMult = speedMult, segments = 1, easeSequence = "hide", tailEaseSequence = "hide"
				}
			)
			mineHold(time, r + asin((x - width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x - width / 2) / 30) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r + asin((x + width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
			mineHold(time, r - asin((x + width / 2) / 42) + 90, activeTime, rotateSpeed, ease)
		else -- calc wrong
			modlog(mod, "WTF " .. tostring(x + width / 2) .. " " .. tostring(x - width / 2))
		end
	end
	local function randomBeam(time, amt, timeDiff, width, activeTime, r, ease, secondBeam, easeIn, easeOut, outOfRange, parent)
		for i = 1, amt do
			if secondBeam then
				--[[ local angle = randomValue(0, 360), angleDir = randomValue(-0.5, 2) * 2;
				newBeam(time, angle, 0, 0, width, activeTime, undefined, undefined, undefined, parent),
					newBeam(time + activeTime, angle, r * angleDir, 0, width, secondBeam, ease, easeIn, easeOut, parent);
				const start = time - inactiveTime, end = time + activeTime + secondBeam + pulseDuration;
				let freeIndex = beamTurns.indexOf(beamTurns.filter(turn => turn.every(active => end < active.start || active.end < start))[0]), startOrder, endOrder;
				freeIndex == -1 && (freeIndex = beamTurns.length, beamTurns.push([])),
					startOrder = 0, endOrder = 0,
					beamTurns[freeIndex].push({ start: start, end: end, startOrder: startOrder, endOrder: endOrder }),
					events.push({
						time: time - inactiveTime, type: "deco", order: 0, hide: false,
						id: beamTurnPrefix + "_" + freeIndex,
						sprite: "pixel.png",
						x: 300, y: 180,
						sx: 0, sy: 0,
						ox: 0.5, oy: 0.5,
						r: angle - r * angleDir * (inactiveTime + activeTime) * 2,
						drawLayer: "fg", drawOrder: 2, recolor: inactive
					}, {
						time: time - inactiveTime, type: "deco", order: 1,
						id: beamTurnPrefix + "_" + freeIndex,
						r: angle + r * angleDir * (secondBeam + pulseDuration) * 2,
						duration: inactiveTime + activeTime + secondBeam + pulseDuration
					}, {
						time: time - inactiveTime, type: "deco", order: 2,
						id: beamTurnPrefix + "_" + freeIndex,
						sx: 20, sy: 20,
						duration: inactiveTime, ease: "outQuad"
					}, {
						time: time + activeTime, type: "deco",
						id: beamTurnPrefix + "_" + freeIndex,
						sx: 0, sy: 0,
						duration: secondBeam + pulseDuration, ease: "inQuad"
					}, {
						time: time + activeTime + secondBeam + pulseDuration, type: "deco",
						id: beamTurnPrefix + "_" + freeIndex,
						hide: true
					}),
					time += timeDiff; ]]
			else
				if r then
					-- newBeam(time, randomValue(0, 360), r * randomValue(-0.5, 2) * 2, 0, width, activeTime, ease, easeIn, easeOut, parent), time += timeDiff;
				else
					newBeam(time, randomValue(0, 360), 0, outOfRange and randomValue(42 + width + 10, 180 - width) or randomValue(-42 - width / 2, 42 * 2 + 1 + width / 2), width, activeTime, nil, nil, nil, parent)
					time = time + timeDiff;
				end
			end
		end
	end
	-- Part 1
	setInactiveTime(16 - 1, 1)
	randomBeam(16 + 0, 8, 2, 25, 0.25)
	randomBeam(16 + 1, 8, 2, 15, 0.125)
	randomBeam(16 + 1.5, 8, 2, 15, 0.125)
	-- Part 3
	setInactiveTime(48 - 1, 0.75)
	randomBeam(48 + 0, 64, 0.5, 20, 0.125)
	randomBeam(48 + 1.75, 8, 4, 10, 0.0)

	local function shaderFloat(x)
		return tostring(math.floor(x) .. "." .. tostring(x % 1):sub(3))
	end
	local function shaderBeamText()
		local s = "\n"
		for i, v in ipairs(beamShaders) do
			s = s .. "\t\tbeam(" .. shaderFloat(v.time) .. "," .. shaderFloat(v.angle) .. "," .. shaderFloat(v.distance) .. "," .. shaderFloat(v.width) .. "," .. tostring(math.floor(v.type)) .. ")"
			if i ~= #beamShaders then s = s .. ",\n" end
		end
		s = s .. "\n"
		return s
	end
	table.sort(beamShaders, function(a, b)
		return a.time < b.time
	end)
	table.insert(
		events,
		{
			type = "shader_background",
			time = 0,
			angle = 0,
			effectCanvasType = "recolor",
			shaderCode = [[
				vec3 col2 = vec3(0.0f);

				squareduv *= 360.0;
				squareduv.x += 120.0;

				switch (drawShapes(squareduv, beat)) {
					case inactiveColor: col2 = vec3(250.0 / 255.0, 199.0 / 255.0, 109.0 / 255.0); break;
					case activeColor: col2 = vec3(251.0 / 255.0, 109.0 / 255.0, 182.0 / 255.0); break;
					case pulseColor: col2 = vec3(1.0); break;
					default: col2 = vec3(250.0 / 255.0, 198.0 / 255.0, 136.0 / 255.0); break;
				}

				col = vec4(col2, 1.0f);
			]],
			uniformCode = [[
				const float pulseTime = 0.125;
				uniform float inactiveTime = 1.0;
				const float activeTime = 0.5;

				const int bgColor = 2;
				const int inactiveColor = 5;
				const int activeColor = 6;
				const int pulseColor = 7;

				const float beamOffset = 0.05;
				const float beamShake = 5.0;

				// Rotate normally
				vec2 rotate(in vec2 uv, in float r) {
					uv = mat2(cos(r), -sin(r), sin(r), cos(r)) * uv;
					return uv;
				}

				// Random
				vec2 hash(vec2 n) {
					n = mod(n, 100.0);
					return fract(sin(vec2(dot(n, vec2(3.51952376878, 4.96156194003) // random values
					), dot(n, vec2(9.97374336327, 2.50070889434) // random values
					))) * 90485.93983084019 // random values
					);
				}
				vec2 hash(float a, float b) {
					return hash(vec2(a, b));
				}

				// https://iquilezles.org/articles/distfunctions2d/
				// 2d sdf
				float sdCircle(in vec2 p, in float r) {
					return length(p) - r;
				}
				float sdBox(in vec2 p, in vec2 b) {
					vec2 d = abs(p) - b;
					return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
				}

				struct beam {
					float time;
					float angle;
					float distance;
					float width;
					int type;
				};

				const struct _1 {
					int beam;
				}
				amounts = _1(]] .. #beamShaders .. [[);

				const struct _2 {
					beam[amounts.beam] beam;
				}
				shapes = _2(
					beam[amounts.beam](
						// time angle distance width type
						]] .. shaderBeamText() .. [[
					)
				);

				bool calcBeamLunge(vec2 pos, beam current, float offset, float lunge, bool require) {
					// 180.0 = c * x - current.width * s
					// 300.0 = s * x - current.width * c

					// 180.0 / c + current.width * t = x
					if (require && current.type != 0) return false;
					if (!require && current.type == 2) return false;
					float s = sin(current.angle);
					float c = cos(current.angle);
					float t = tan(current.angle);
					lunge = (lunge + offset) / (1.0 + offset);
					float d1 = abs(180.0 / c) + abs(current.width * t);
					float d2 = abs(300.0 / s) + abs(current.width / t);
					float pos1 = ((pos.y + current.distance * t) / d1 + 1.0) / 2.0;
					float pos2 = ((pos.y + current.distance / t) / d2 + 1.0) / 2.0;
					float pos3 = (pos.y / 350.0 + 1.0) / 2.0;
					return min(min(pos1, pos2), pos3) <= lunge;
				}

				int drawBeam(vec2 pos, int color, beam current, float inactiveT, float activeT, float beat) {
					vec2 pos2 = rotate(pos - vec2(300.0, 180.0), current.angle);
					pos2.x -= current.distance;
					float sdf = 1.0;
					if (color == pulseColor) return color;

					if (current.type == 0 && beat > current.time - pulseTime && beat <= current.time + activeT - pulseTime) {
						pos2.x -= (hash(beat, current.angle).x * 2.0 - 1.0) * beamShake * min(1.0, 1.0 - (beat - current.time) / (activeT - pulseTime));
					}
					if (abs(pos2.x) < current.width) {
						if (beat < current.time) {
							if (beat > current.time - pulseTime) {
								float time = (beat - current.time + pulseTime) / pulseTime;
								if (calcBeamLunge(pos2, current, (current.type == 0 ? beamOffset : 0.0), (current.type == 0 ? time * time : 1.0 - (1.0 - time) * (1.0 - time)), false) && (current.type == 0 || abs(pos2.x) < current.width * time)) {
									color = pulseColor;
								} else if (color != activeColor && 1.0 - time > hash(pos / 10.0).x) {
									color = inactiveColor;
								}
							} else if (color != activeColor) {
								float time = (beat - current.time + inactiveT) / (inactiveT - pulseTime);
								if (calcBeamLunge(pos2, current, beamOffset * time, 0.0, true)) {
									color = activeColor;
								} else if (abs(pos2.x) < current.width - 2.0) {
									if (abs(pos2.x) < (current.width - 2.0) * time && time > hash(pos / 10.0).x) color = inactiveColor;
								} else color = inactiveColor;
							}
						} else {
							if (beat > current.time + activeT) {
								float time = (beat - current.time - activeT) / pulseTime;
								if (current.type != 0) {
									if (abs(pos2.x) < current.width * (1.0 - time)) if (1.0 - time > hash(pos / 10.0).x) { color = activeColor; } else color = inactiveColor;
								} else if (calcBeamLunge(pos2, current, 0.0, 1.0 - time * time, true)) color = activeColor;
							} else color = activeColor;
						}
					}
					return color;
				}

				int drawShapes(vec2 pos, float beat) {
					int i = 0;
					int color = bgColor;

					float activeT;
					float inactiveT;

					// because nested arrays are not supported, i have to copy and paste this code... im suffering
					activeT = activeTime;
					inactiveT = inactiveTime;
					// i could make this O(log(n)) instead of O(n), if it lags too much
					for (; i < amounts.beam && beat > shapes.beam[i].time + activeT + pulseTime; i++);
					for (; i < amounts.beam && beat > shapes.beam[i].time - inactiveT; i++) {
						color = drawBeam(pos, color, shapes.beam[i], inactiveT, activeT, beat);
					}

					return color;
				}
			]]
		}
	)

	if not love.filesystem.inSaveData(cLevel) then love.filesystem.forceSaveInSource(true) end
	dpf.saveJson(cLevel .. "tags/generated.json", events)
	love.filesystem.forceSaveInSource(false)
end
-- grid()
-- boxes()
utilitools.try(mod, beams)

-- add alpha dither on beams