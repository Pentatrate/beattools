--[[

configs

results screen

]]

local noiseDither = {}

noiseDither.appliedNoise = false
noiseDither.appliedDither = false

noiseDither.canvas = love.graphics.newCanvas(project.res.x, project.res.y, { format = "stencil8" })
noiseDither.canvasDither = love.graphics.newCanvas(project.res.x, project.res.y, { format = "stencil8" })
noiseDither.old = nil

noiseDither.noiseMap = {}
noiseDither.ditherMap = {}

for i = 1, 600 do
	for j = 1, 360 do
		local temp2 = math.random(0, 254)
		local temp = 1
		noiseDither.noiseMap[temp2] = noiseDither.noiseMap[temp2] or {}
		while noiseDither.noiseMap[temp2][temp] and #noiseDither.noiseMap[temp2][temp] > 2000 do
			temp = temp + 1
		end
		noiseDither.noiseMap[temp2][temp] = noiseDither.noiseMap[temp2][temp] or {}
		table.insert(noiseDither.noiseMap[temp2][temp], i - 0.5)
		table.insert(noiseDither.noiseMap[temp2][temp], j - 0.5)

		if (i + j) % 2 == 0 then
			temp2 = 255
		end
		temp = 1
		noiseDither.ditherMap[temp2] = noiseDither.ditherMap[temp2] or {}
		while noiseDither.ditherMap[temp2][temp] and #noiseDither.ditherMap[temp2][temp] > 2000 do
			temp = temp + 1
		end
		noiseDither.ditherMap[temp2][temp] = noiseDither.ditherMap[temp2][temp] or {}
		table.insert(noiseDither.ditherMap[temp2][temp], i - 0.5)
		table.insert(noiseDither.ditherMap[temp2][temp], j - 0.5)
	end
end

function noiseDither.apply(doDither)
	if type(love.graphics.getCanvas()) ~= "table" then
		noiseDither.old = love.graphics.getCanvas()
	end
	love.graphics.setCanvas({ noiseDither.old, depthstencil = noiseDither[doDither and "canvasDither" or "canvas"] })

	if noiseDither[doDither and "appliedDither" or "appliedNoise"] then
		return
	end
	noiseDither[doDither and "appliedDither" or "appliedNoise"] = true

	love.graphics.clear(false, true, false)
	color()
	local temp = love.graphics.getPointSize()
	love.graphics.setPointSize(1)

	for i = 0, 255 do
		if (doDither and noiseDither.ditherMap or noiseDither.noiseMap)[i] then
			for _, v in ipairs((doDither and noiseDither.ditherMap or noiseDither.noiseMap)[i]) do
				love.graphics.stencil(function()
					love.graphics.points(unpack(v))
				end, "replace", i, true)
			end
		end
	end

	love.graphics.setPointSize(temp)
end

function noiseDither.clamp(minInvisAt, maxInvisAt, minStartInvis, maxStartInvis, minCombo, maxCombo)
	local precision = 1e2
	local maxValue = 1e3
	local comboLimit = 1e5
	local function rnd(v)
		return math.max(0, math.min(helpers.round(v * precision) / precision, maxValue))
	end
	minInvisAt = rnd(minInvisAt)
	maxInvisAt = rnd(maxInvisAt)
	minStartInvis = math.max(minInvisAt, rnd(minStartInvis))
	maxStartInvis = math.max(maxInvisAt, rnd(maxStartInvis))
	minCombo = math.max(0, math.min(math.floor(minCombo), comboLimit))
	maxCombo = math.max(minCombo, math.min(math.floor(maxCombo), comboLimit))
	if minInvisAt == maxInvisAt and minStartInvis == maxStartInvis then
		minCombo = 0
		maxCombo = 0
	end
	if minCombo == maxCombo then
		minCombo = 0
		maxCombo = 0
		minInvisAt = maxInvisAt
		minStartInvis = maxStartInvis
	end
	return minInvisAt, maxInvisAt, minStartInvis, maxStartInvis, minCombo, maxCombo
end

function noiseDither.dither(note, doDither)
	local pct
	if note == nil then
		return
	elseif note == false then
		love.graphics.setCanvas(noiseDither.old)
		love.graphics.setStencilTest()
		return
	end
	if (cs.name ~= "Editor" or cs.editMode == false) then
		local minInvisAt, maxInvisAt, minStartInvis, maxStartInvis, minCombo, maxCombo = utilitools.files.beattools.noiseDither.clamp(mod.config.minInvisAt, mod.config.maxInvisAt, mod.config.minStartInvis, mod.config.maxStartInvis, mod.config.minCombo, mod.config.maxCombo)

		local combo
		if minCombo == maxCombo then
			combo = 1
		else
			combo = helpers.clamp(math.max(0, cs.combo - minCombo) / (maxCombo - minCombo), 0, 1)
		end

		pct = math.max(0, (note.hb or 0) - minInvisAt - (maxInvisAt - minInvisAt) * combo - (cs.cBeat or 0))
		local d = 0
		if minCombo ~= maxCombo then
			d = (maxStartInvis - maxInvisAt - (minStartInvis - minInvisAt)) * combo + minStartInvis - minInvisAt
		end
		if d ~= 0 then
			pct = pct / d
		elseif minStartInvis + (maxStartInvis - minStartInvis) * combo == 0 then
			pct = pct >= 0 and 1 or 0
		else
			pct = pct > 0 and 1 or 0
		end
		pct = helpers.clamp(pct, 0, 1)
	elseif doDither then
		pct = 1
	else
		if type(love.graphics.getCanvas()) ~= "table" then
			noiseDither.old = love.graphics.getCanvas()
		end
		return
	end
	pct = math.floor(pct * 255)

	noiseDither.apply(doDither)
	love.graphics.setStencilTest("less", pct)
end

return noiseDither
