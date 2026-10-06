local halfBlinkSpeed = 0.05
local blinkSpeed = 0.1
local boredSpeed = 60
local sleepySpeed = 75
local sleepSpeed = 90
local blinkInterval = 5
local livelyCranky = {
	time = 0,
	animDuration = 0,
	animStart = 0,
	anim = nil,
	anims = {
		current = {
			order = 0
		},
		sleep = {
			lively = true,
			order = 1,
			duration = -1
		},
		blink = {
			lively = true,
			order = 2,
			duration = halfBlinkSpeed * 2 + blinkSpeed
		},
		ctrl = {
			lively = true,
			order = 3,
			sprite = "happy"
		},
		afterPlaytest = {
			lively = true,
			order = 4,
			duration = 1
		},
		afterError = {
			lively = true,
			order = 5,
			duration = blinkSpeed * 10
		}
	},
	faceSprites = {}
}

function livelyCranky.anims.sleep.run()
	if livelyCranky.idleTime <= boredSpeed then livelyCranky.anim = nil end
	if livelyCranky.idleTime > sleepSpeed then return "closed" end
	if livelyCranky.idleTime > sleepySpeed then return "halfclosed" end
	return "unimpressed"
end
function livelyCranky.anims.blink.run()
	if livelyCranky.idleTime > sleepSpeed then
		livelyCranky.anim = nil
		return "closed"
	end
	if livelyCranky.idleTime > sleepySpeed then
		if livelyCranky.animDuration > blinkSpeed then livelyCranky.anim = nil end
		return "closed"
	end
	if livelyCranky.animDuration > livelyCranky.anim.duration - halfBlinkSpeed then return "halfclosed" end
	if livelyCranky.animDuration > livelyCranky.anim.duration - halfBlinkSpeed - blinkSpeed then return "closed" end
	return "halfclosed"
end
function livelyCranky.anims.afterPlaytest.run()
	if livelyCranky.animDuration > livelyCranky.anim.duration - halfBlinkSpeed then
		if livelyCranky.idleTime > sleepySpeed then
			livelyCranky.anim = nil
		end
		return "halfclosed"
	end
	if livelyCranky.animDuration > livelyCranky.anim.duration - halfBlinkSpeed - blinkSpeed then
		if livelyCranky.idleTime > sleepSpeed then
			livelyCranky.anim = nil
		end
		return "closed"
	end
	return "><"
end
function livelyCranky.anims.afterError.run()
	if livelyCranky.animDuration % (2 * blinkSpeed) > blinkSpeed then
		return "spiral"
	end
	return "miss"
end

function livelyCranky.startAnim(animId)
	if type(animId) ~= "string" then return end
	local anim = livelyCranky.anims[animId]
	if not anim then return end
	if anim == livelyCranky.anim then return end
	if livelyCranky.anim and (anim.order or 0) <= (livelyCranky.anim.order or 0) then return end
	if not mods.beattools.config.livelyCranky and anim.lively then return end
	livelyCranky.anim = anim
	livelyCranky.animStart = livelyCranky.time
	livelyCranky.animDuration = 0
end

function livelyCranky.updateCurrent()
	if not mods.beattools.config.currentSprite then return end
	local currentSprite = utilitools.files.beattools.easing.getEase("forcePlayerSprite", nil, cs.editorBeat, nil, nil)
	if currentSprite.spriteName == "" then return end

	local spriteName = currentSprite.spriteName

	if spriteName:sub(-4):lower() == ".png" then
		local filename = cLevel .. spriteName
		if love.filesystem.exists(filename) then
			local modTime = love.filesystem.getInfo(cLevel .. spriteName, "file").modtime
			if not livelyCranky.faceSprites[spriteName] or livelyCranky.faceSprites[spriteName].modTime ~= modTime then
				livelyCranky.faceSprites[spriteName] = {
					time = livelyCranky.time,
					modTime = modTime
				}
			end
			if livelyCranky.time - livelyCranky.faceSprites[spriteName].time > 1 then
				cs.p.spr[spriteName] = love.graphics.newImage(filename)
			end
		end
	end

	if ({ [""] = true, none = true, idle = true, happy = true, miss = true, ["><"] = true, [":3"] = true })[spriteName] or cs.p.spr[spriteName] ~= nil then
		livelyCranky.anims.current.sprite, livelyCranky.anims.current.stencil = spriteName, currentSprite.useFaceStencil
		livelyCranky.startAnim("current")
	end
end

function livelyCranky.update()
	if not cs.editMode then return end
	livelyCranky.time = love.timer.getTime()
	if livelyCranky.anim then livelyCranky.animDuration = livelyCranky.time - livelyCranky.animStart end
	local undo = utilitools.files.beattools.undo
	livelyCranky.idleTime = #undo.changes > 0 and livelyCranky.time - undo.changes[#undo.changes].time or 0

	-- blink + sleep
	if maininput:down("modifier") then livelyCranky.startAnim("ctrl") end
	if livelyCranky.time % blinkInterval < blinkSpeed then livelyCranky.startAnim("blink") end
	if livelyCranky.idleTime > boredSpeed then livelyCranky.startAnim("sleep") end
	livelyCranky.updateCurrent()

	cs.p.forceSprite = ""
	cs.p.useFaceStencil = false
	if livelyCranky.anim then
		if livelyCranky.anim.sprite ~= nil then
			cs.p.forceSprite = livelyCranky.anim.sprite
		end
		if livelyCranky.anim.stencil ~= nil then
			cs.p.useFaceStencil = livelyCranky.anim.stencil
		end
		if livelyCranky.anim.run then
			cs.p.forceSprite, cs.p.useFaceStencil = livelyCranky.anim.run()
			if not livelyCranky.anim then return end
		end
		if livelyCranky.anim.duration then
			if livelyCranky.animDuration >= 0 and livelyCranky.animDuration > livelyCranky.anim.duration then
				livelyCranky.anim = nil
			end
		else
			livelyCranky.anim = nil
		end
	end
end

return livelyCranky