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
-- grid()
-- boxes()

-- add alpha dither on beams