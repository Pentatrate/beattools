local eventVisuals = {
	step = 4,
	eventCache = {},
	holds = { hold = true, mineHold = true, trace = true, tashold = true },
	hasRepeat = {
		ease = true,
		tag = true,
		setJoystickColor = true,
		["c-me_b-me_iconsEase"] = true,
		shinamon_offset = true,
		shinamon_offsetAll = true,
		shinamon_offsetEvenOdd = true,
		shader_uniform = true
	},
	listen = { type = true, time = true, duration = true, bounces = true, delay = true, repeats = true, repeatDelay = true }
}

local canv = love.graphics.newCanvas(project.res.x, project.res.y)

-- love.graphics.newCanvas(project.res.x, project.res.y)

-- love.graphics.setCanvas(self.layerCanvas.gameplay)
-- love.graphics.clear()

local color = { r = 1, g = 1, b = 1, a = 1 }
local function setColor(r, g, b, a)
	r = r or color.r
	g = g or color.g
	b = b or color.b
	a = a or color.a
	if r ~= color.r or g ~= color.g or b ~= color.b or a ~= color.a then
		love.graphics.setColor(r, g, b, a)
		color.r = r
		color.g = g
		color.b = b
		color.a = a
	end
end

local globalAlpha = 1

local function isVisible(x, y, low, high)
	y = y or x
	low = low or cs.editorBeat
	high = high or cs.editorBeat + cs.drawDistance
	return y >= low and x <= high
end
local function inBounds(pos, width)
	return isVisible(pos[1], nil, -width, 600 + width) and isVisible(pos[2], nil, -width, 360 + width)
end
local function beattoolsSameEasing(event, selected)
	if not (mod.config.markSameEasing and selected and event ~= selected and event.type == selected.type) then return false end
	local paramForType = { ease = "var", setColor = "color", deco = "id" }
	if paramForType[event.type] == nil then return false end
	return event[paramForType[event.type]] == selected[paramForType[event.type]]
end

function eventVisuals.reset()
	eventVisuals.eventCache = {}
end

function eventVisuals.getTime(time)
	return time - time % eventVisuals.step
end
function eventVisuals.cacheEvent(event, remove)
	local function add(time)
		time = eventVisuals.getTime(time)
		if remove then
			if eventVisuals.eventCache[time] then
				eventVisuals.eventCache[time][tostring(event)] = nil
				if utilitools.table.emptyTable(eventVisuals.eventCache[time]) then eventVisuals.eventCache[time] = nil end
			end
		else
			eventVisuals.eventCache[time] = eventVisuals.eventCache[time] or {}
			eventVisuals.eventCache[time][tostring(event)] = event
		end
	end

	local duration = event.duration or 0
	local bounces = event.type == "bounce" and (event.bounces or 1) * (event.delay or 1) or 0
	local repeated = eventVisuals.hasRepeat[event.type] and (event.repeats or 0) * (event.repeatDelay or 1) or 0

	for i = eventVisuals.getTime(event.time), eventVisuals.getTime(event.time + duration + bounces + repeated), eventVisuals.step do
		add(i)
	end
end

local function drawEventOnLayer(event, beattoolsLayer)
	if beattoolsLayer == nil then
		modlog(mod, "beattoolsDrawEvent: Invalid beattoolsLayer")
		return
	else
		if beattoolsLayer == "endAngleMarker" or beattoolsLayer == "selectedEndAngleMarker" then
			eventVisuals.drawEndAngleMarker(event, beattoolsLayer)
		elseif beattoolsLayer == "duration" or beattoolsLayer == "sameEasingDuration" or beattoolsLayer == "selectedDuration" then
			eventVisuals.drawDuration(event, beattoolsLayer)
		elseif beattoolsLayer == "repeatMarker" or beattoolsLayer == "sameEasingRepeatMarker" or beattoolsLayer == "selectedRepeatMarker" then
			eventVisuals.drawRepeat(event, beattoolsLayer)
		else
			local alpha = 1
			if utilitools.files.beattools.eventStacking.inStack(event) then alpha = alpha * mod.config.alpha end
			local t = { transparent = mod.config.alphaTransparent, ghost = mod.config.alphaGhost }
			if t[utilitools.files.beattools.eventGroups.eventVisibility(event)] then alpha = alpha * t[utilitools.files.beattools.eventGroups.eventVisibility(event)] end

			eventVisuals.drawSprite(event, alpha, beattoolsLayer)
		end
	end
end

function eventVisuals.drawParam(event, pos1)
	if mod.config.showParam ~= "none" and event[mod.config.showParam] and isVisible(event.time) and inBounds(pos1, 8) then
		local beattoolsParam = event[mod.config.showParam]
		beattoolsParam = helpers.round(beattoolsParam * 1e3) / 1e3
		if beattoolsParam > 99 then
			beattoolsParam = ">99"
		elseif beattoolsParam < -99 then
			beattoolsParam = "<-99"
		else
			beattoolsParam = tostring(beattoolsParam)
		end
		local pos = {}
		pos[1] = helpers.round(pos1[1]) + utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.xOffset - 6 - 20
		pos[2] = helpers.round(pos1[2]) - utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.yOffset - 2
		setColor(mod.config.bgColor.r, mod.config.bgColor.g, mod.config.bgColor.b, 1)
		if mod.config.shadow then
			love.graphics.printf(beattoolsParam, pos[1] + 1, pos[2] + 1, 13 + 20, "right")
		else
			love.graphics.printf(beattoolsParam, pos[1] + 1, pos[2], 13 + 20, "right")
			love.graphics.printf(beattoolsParam, pos[1], pos[2] + 1, 13 + 20, "right")
			love.graphics.printf(beattoolsParam, pos[1] - 1, pos[2], 13 + 20, "right")
			love.graphics.printf(beattoolsParam, pos[1], pos[2] - 1, 13 + 20, "right")
		end
		setColor(mod.config.fgColor.r, mod.config.fgColor.g, mod.config.fgColor.b, 1)
		love.graphics.printf(beattoolsParam, pos[1], pos[2], 13 + 20, "right")
	end
end

function eventVisuals.drawEndAngleMarker(event, beattoolsLayer)
	if beattoolsLayer ~= "endAngleMarker" and beattoolsLayer ~= "selectedEndAngleMarker" then
		modlog(mod, "eventVisuals.drawEndAngleMarker: Invalid beattoolsLayer: " .. beattoolsLayer)
		return
	end

	if isVisible(event.time) then
		local pos = cs:getPosition(mod.config.displayEndAngle and event.angle or event.endAngle, event.time)
		if inBounds(pos, 3) then
			local sprite = beattoolsLayer == "endAngleMarker" and sprites.editor.endAngleMarker or sprites.editor.endAngleMarkerSelected
			love.graphics.draw(sprite, pos[1], pos[2], 0, 1, 1, 11, 11)
		end
	end
end
function eventVisuals.drawDuration(event, beattoolsLayer)
	if beattoolsLayer ~= "duration" and beattoolsLayer ~= "sameEasingDuration" and beattoolsLayer ~= "selectedDuration" then
		modlog(mod, "eventVisuals.drawDuration: Invalid beattoolsLayer: " .. beattoolsLayer)
		return
	end

	for i = 0, (eventVisuals.hasRepeat[event.type] and event.repeats and event.repeats > 0 and event.repeatDelay ~= 0 and event.repeats) or 0 do
		local time = event.time + i * (event.repeatDelay or 1)
		if isVisible(time, time + event.duration) then
			local pos1 = cs:getPosition(event.angle, math.max(time, cs.editorBeat))
			local pos2 = cs:getPosition(event.angle, math.max(time + event.duration, cs.editorBeat))
			if inBounds(pos1, 2) or inBounds(pos2, 2) then
				love.graphics.line(pos1[1], pos1[2], pos2[1], pos2[2])
			end
		end
	end
end
function eventVisuals.drawRepeat(event, beattoolsLayer)
	if beattoolsLayer ~= "repeatMarker" and beattoolsLayer ~= "sameEasingRepeatMarker" and beattoolsLayer ~= "selectedRepeatMarker" then
		modlog(mod, "eventVisuals.drawRepeat: Invalid beattoolsLayer: " .. beattoolsLayer)
		return
	end

	local sprite = (beattoolsLayer == "repeatMarker" and sprites.editor.repeatMarker) or (beattoolsLayer == "sameEasingRepeatMarker" and sprites.editor.repeatMarkerSameEasing) or sprites.editor.repeatMarkerSelected
	local repeating = eventVisuals.hasRepeat[event.type] and event.repeats and event.repeats > 0 and (not event.repeatDelay or event.repeatDelay >= 0)

	local stackX = repeating and 0 or utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.xOffset
	local stackY = repeating and 0 or utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.yOffset
	for i = repeating and 1 or 0, repeating and event.repeats or 0 do
		local time = event.time + i * (event.repeatDelay or 1)
		if isVisible(time) then
			local pos = cs:getPosition(mod.config.displayEndAngle and event.endAngle or event.angle, time)
			if inBounds(pos, 8) then
				love.graphics.draw(
					sprite,
					helpers.round(pos[1] + stackX), helpers.round(pos[2] - stackY),
					0, 1, 1, 11, 11
				)
			end
		end
	end
end
function eventVisuals.drawSprite(event, alpha, beattoolsLayer)
	if beattoolsLayer ~= "note" and beattoolsLayer ~= "event" and beattoolsLayer ~= "sameEasing" and beattoolsLayer ~= "selected" then
		modlog(mod, "eventVisuals.drawSprite: Invalid beattoolsLayer: " .. beattoolsLayer)
		return
	end
	alpha = alpha or 1

	local eventDraw = Event.editorDraw[event.type] or sprites.editor.genericevent

	if alpha ~= 1 then
		love.graphics.setCanvas(canv)
		love.graphics.clear()
	end

	local beattoolsTemp2 = event.angle
	if type(eventDraw) == "function" then
		if mod.config.displayEndAngle and event.endAngle then
			utilitools.files.beattools.undo.undoing = true
			utilitools.files.beattools.undo.fakeRepeating = true
			event.angle = event.endAngle
			utilitools.files.beattools.undo.undoing = false
			utilitools.files.beattools.undo.fakeRepeating = false
		end

		setColor(1, 1, 1, 1)
		eventDraw(event, cs.editorBeat, cs.editorBeat + cs.drawDistance, 1.0)
		color.r, color.g, color.b, color.a = love.graphics.getColor()
	end
	if isVisible(event.time) then
		local pos = cs:getPosition(event.angle, event.time)
		if inBounds(pos, 8) then
			if type(eventDraw) ~= "function" then
				setColor(1, 1, 1, 1)
				love.graphics.draw(eventDraw, pos[1] + utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.xOffset, pos[2] - utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.yOffset, 0, 1, 1, 8, 8)
			end

			if not event.isCursor and beattoolsLayer == "sameEasing" then
				setColor(mod.config.durationSameEasingColor.r, mod.config.durationSameEasingColor.g, mod.config.durationSameEasingColor.b, 1)
				love.graphics.draw(sprites.editor.sameEasing, pos[1] + utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.xOffset, pos[2] - utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.yOffset, 0, 1, 1, 11, 11)
			end
			eventVisuals.drawParam(event, pos)
		end
	end
	if not event.isCursor and beattoolsLayer == "selected" then
		local time = event.time
		local angle = event.angle

		if mod.config.bounceDragging and cs.bounceSelected then
			angle, time = angle + (event.rotation or 0) * cs.bounceSelected, time + (event.delay or 1) * cs.bounceSelected
		elseif cs.holdEndSelected then
			angle, time = event.angle2, time + event.duration
		end

		if isVisible(time) then
			local pos = cs:getPosition(angle, time)
			if inBounds(pos, 11) then
				if mod.config.whiteSelected ~= "off" then
					setColor(mod.config.selectedBorderColor.r, mod.config.selectedBorderColor.g, mod.config.selectedBorderColor.b, mod.config.selectedBorderColor.a)
				else
					setColor(1, 1, 1, 1)
				end
				local sprite = sprites.editor[mod.config.whiteSelected ~= "off" and (mod.config.whiteSelected == "on" and "whiteSelected" or "whiteSelectedCut") or "selected"]
				love.graphics.draw(sprite, pos[1] + utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.xOffset, pos[2] - utilitools.files.beattools.eventStacking.getIndex(event) * mod.config.yOffset, 0, 1, 1, 11, 11)
			end
		end
	end
	if type(eventDraw) == "function" and mod.config.displayEndAngle and event.endAngle then
		utilitools.files.beattools.undo.undoing = true
		utilitools.files.beattools.undo.fakeRepeating = true
		event.angle = beattoolsTemp2
		utilitools.files.beattools.undo.undoing = false
		utilitools.files.beattools.undo.fakeRepeating = false
	end

	if alpha ~= 1 then
		love.graphics.setCanvas(cs.canv)
		setColor(1, 1, 1, alpha)
		love.graphics.draw(canv)
	end
end

function eventVisuals.drawEvents()
	-- Penta: beattools layer code
	local layerNote, layerEndAngleMarker, layerDuration, layerEvent, layerRepeatMarker, layerSameEasingDuration, layerSameEasing, layerSameEasingRepeatMarker, layerSelectedDuration, layerSelectedRepeatMarker, layerSelected, layerSelectedEndAngleMarker = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

	local selectedEvents = {}
	-- this isnt much better, bah its fine ig
	if cs.multiselect and cs.multiselect.events then
		for _, v in ipairs(cs.multiselect.events) do selectedEvents[tostring(v)] = v end
	end
	local eventsToDraw = {}
	for i = eventVisuals.getTime(cs.editorBeat), eventVisuals.getTime(cs.editorBeat + cs.drawDistance), eventVisuals.step do
		if eventVisuals.eventCache[i] then
			for eventId, event in pairs(eventVisuals.eventCache[i]) do
				eventsToDraw[eventId] = event
			end
		end
	end
	for _, v in pairs(eventsToDraw) do
		if Event.info[v.type] and utilitools.files.beattools.eventGroups.eventVisibility(v) ~= "hide" then
			local visibility = utilitools.files.beattools.eventGroups.eventVisibility(v)
			local selected = v == cs.selectedEvent or selectedEvents[tostring(v)] or (mod.config.fakeRepeat and cs.selectedEvent and cs.selectedEvent.beattoolsRepeatParent and v.beattoolsRepeatChild == cs.selectedEvent.beattoolsRepeatParent)
			local sameEase = selected or beattoolsSameEasing(v, cs.selectedEvent)

			-- ok this is horrible, so limit it to 100
			if not selected and cs.multiselect and cs.multiselect.events and #cs.multiselect.events <= 100 then
				for _, vv in ipairs(cs.multiselect.events) do
					if mod.config.fakeRepeat and vv.beattoolsRepeatParent and v.beattoolsRepeatChild == vv.beattoolsRepeatParent then
						selected = true
						break
					end
					if beattoolsSameEasing(v, cs.selectedEvent) then
						sameEase = true
					end
				end
			end
			local repeating = eventVisuals.hasRepeat[v.type] and v.repeats and v.repeats > 0 and (not v.repeatDelay or v.repeatDelay >= 0) and v.time + v.repeats * (v.repeatDelay or 1)

			local function addTo(list)
				list[visibility] = list[visibility] or {}
				list[visibility][tostring(v)] = v
			end
			local function checkMarkerSelected(k)
				return mod.config[k] ~= "off" and selected
			end
			local function checkMarker(k)
				return mod.config[k] == "on" and not selected
			end

			if not eventVisuals.holds[v.type] and v.duration and v.duration > 0 and isVisible(v.time, (repeating or v.time) + v.duration) then
				if checkMarkerSelected("showDuration") then
					addTo(layerSelectedDuration)
				elseif checkMarker("showDuration") then
					if sameEase then
						addTo(layerSameEasingDuration)
					else
						addTo(layerDuration)
					end
				end
			end
			if mod.config.fakeRepeat and v.beattoolsRepeatChild then -- is child
				if isVisible(v.time) then
					if checkMarkerSelected("markRepeat") then
						addTo(layerSelectedRepeatMarker)
					elseif checkMarker("markRepeat") then
						if sameEase then
							addTo(layerSameEasingRepeatMarker)
						else
							addTo(layerRepeatMarker)
						end
					end
					if v.endAngle then
						if checkMarkerSelected("markEndAnglePosition") then
							addTo(layerSelectedEndAngleMarker)
						elseif checkMarker("markEndAnglePosition") then
							addTo(layerEndAngleMarker)
						end
					end
				end
			else
				if Event.checkActiveRange[v.type](v, cs.editorBeat, cs.editorBeat + cs.drawDistance) then
					if selected then -- cannot be child, must be selected parent
						addTo(layerSelected)
						if v.endAngle and checkMarkerSelected("markEndAnglePosition") and isVisible(v.time) then
							addTo(layerSelectedEndAngleMarker)
						end
					elseif sameEase then
						addTo(layerSameEasing)
					else
						if type(Event.editorDraw[v.type]) == "function" then
							addTo(layerNote)
							if v.endAngle and checkMarker("markEndAnglePosition") and isVisible(v.time) then
								addTo(layerEndAngleMarker)
							end
						else
							addTo(layerEvent)
						end
					end
				end
				if repeating and isVisible(v.time + (v.repeatDelay or 1), repeating) then
					if checkMarkerSelected("markRepeat") then
						addTo(layerSelectedRepeatMarker)
					elseif checkMarker("markRepeat") then
						if sameEase then
							addTo(layerSameEasingRepeatMarker)
						else
							addTo(layerRepeatMarker)
						end
					end
				end
			end
		end
	end

	love.graphics.setCanvas(cs.canv)
	color.r, color.g, color.b, color.a = love.graphics.getColor()

	local function drawLayer(table, layer, drawColor, alphaOverride)
		local function drawVisibility(visibility)
			if not table[visibility] then return end
			if drawColor then
				local alpha = 1
				local t = { transparent = mod.config.alphaTransparent, ghost = mod.config.alphaGhost }
				if t[visibility] then alpha = t[visibility] end
				setColor(drawColor.r, drawColor.g, drawColor.b, (alphaOverride or drawColor.a or 1) * alpha)
			end
			for _, v in pairs(table[visibility]) do
				drawEventOnLayer(v, layer)
			end
		end
		drawVisibility("ghost")
		drawVisibility("transparent")
		drawVisibility("show")
	end

	drawLayer(layerNote, "note")
	-- Penta: Stacked notes marker
	if mod.config.stackingNotes then
		setColor(1, 1, 1, 1) -- add coloring
		for time, angles in pairs(utilitools.files.beattools.eventStacking.gameplayStack) do
			if time >= cs.editorBeat and time <= cs.editorBeat + cs.drawDistance then
				for angle, _ in pairs(angles) do
					local pos = cs:getPosition(angle, time)
					love.graphics.draw(sprites.editor.stackingNotes, pos[1], pos[2], 0, 1, 1, 11, 11)
				end
			end
		end
	end
	if mod.config.markEndAnglePosition == "on" then
		drawLayer(layerEndAngleMarker, "endAngleMarker", { r = 1, g = 1, b = 1 })
	end
	if mod.config.showDuration == "on" then
		love.graphics.setLineWidth(2)
		drawLayer(layerDuration, "duration", mod.config.durationColor)
	end
	drawLayer(layerEvent, "event")
	if mod.config.markRepeat == "on" then
		drawLayer(layerRepeatMarker, "repeatMarker", { r = 1, g = 1, b = 1 })
	end

	-- same easing
	if mod.config.showDuration == "on" then
		love.graphics.setLineWidth(2)
		drawLayer(layerSameEasingDuration, "sameEasingDuration", mod.config.durationSameEasingColor)
	end
	drawLayer(layerSameEasing, "sameEasing")
	if mod.config.markRepeat == "on" then
		drawLayer(layerSameEasingRepeatMarker, "sameEasingRepeatMarker", mod.config.durationSameEasingColor, 1)
	end

	-- selected
	if mod.config.showDuration ~= "off" then
		love.graphics.setLineWidth(2)
		drawLayer(layerSelectedDuration, "selectedDuration", mod.config.durationSelectedColor)
	end
	if mod.config.markRepeat ~= "off" then
		drawLayer(layerSelectedRepeatMarker, "selectedRepeatMarker", mod.config.durationSelectedColor, 1)
	end
	drawLayer(layerSelected, "selected")
	if mod.config.markEndAnglePosition ~= "off" then
		drawLayer(layerSelectedEndAngleMarker, "selectedEndAngleMarker", { r = 1, g = 1, b = 1 })
	end

	setColor(1, 1, 1, 1)

	--[[ --draw layers
	love.graphics.setColor(1,1,1,0.3)
	if cs.layers.vfx == 2 then
		love.graphics.draw(cs.layerCanvas.vfx)
	end
	if cs.layers.gameplay == 2 then
		love.graphics.draw(cs.layerCanvas.gameplay)
	end

	love.graphics.setColor(1,1,1,1)
	if cs.layers.vfx == 1 then
		love.graphics.draw(cs.layerCanvas.vfx)
	end
	if cs.layers.gameplay == 1 then
		love.graphics.draw(cs.layerCanvas.gameplay)
	end ]]

	if beattoolsRecordPosition and beattoolsRecordFunc then
		setColor(mod.config.lineColor.r, mod.config.lineColor.g, mod.config.lineColor.b, 1)
		love.graphics.setLineWidth(2)
		love.graphics.line(helpers.round(mouse.rx / beattoolsRecordPrecision) * beattoolsRecordPrecision - 5, helpers.round(mouse.ry / beattoolsRecordPrecision) * beattoolsRecordPrecision - 5, helpers.round(mouse.rx / beattoolsRecordPrecision) * beattoolsRecordPrecision + 5, helpers.round(mouse.ry / beattoolsRecordPrecision) * beattoolsRecordPrecision + 5)
		love.graphics.line(helpers.round(mouse.rx / beattoolsRecordPrecision) * beattoolsRecordPrecision + 5, helpers.round(mouse.ry / beattoolsRecordPrecision) * beattoolsRecordPrecision - 5, helpers.round(mouse.rx / beattoolsRecordPrecision) * beattoolsRecordPrecision - 5, helpers.round(mouse.ry / beattoolsRecordPrecision) * beattoolsRecordPrecision + 5)
		local beattoolsParam = helpers.round(mouse.rx / beattoolsRecordPrecision) * beattoolsRecordPrecision .. "/" ..  helpers.round(mouse.ry / beattoolsRecordPrecision) * beattoolsRecordPrecision .. " (press \"r\")"
		local leftside = helpers.round(mouse.rx) <= 300
		local pos = { helpers.round(mouse.rx / beattoolsRecordPrecision) * beattoolsRecordPrecision - (leftside and -10 or 210), helpers.round(mouse.ry / beattoolsRecordPrecision) * beattoolsRecordPrecision - 3 + (helpers.round(mouse.ry) <= 180 and 10 or -10) }
		setColor(mod.config.bgColor2.r, mod.config.bgColor2.g, mod.config.bgColor2.b, 1)
		if mod.config.shadow2 then
			love.graphics.printf(beattoolsParam, pos[1] + 1, pos[2] + 1, 200, (leftside and "left" or "right"))
		else
			love.graphics.printf(beattoolsParam, pos[1] + 1, pos[2], 200, (leftside and "left" or "right"))
			love.graphics.printf(beattoolsParam, pos[1], pos[2] + 1, 200, (leftside and "left" or "right"))
			love.graphics.printf(beattoolsParam, pos[1] - 1, pos[2], 200, (leftside and "left" or "right"))
			love.graphics.printf(beattoolsParam, pos[1], pos[2] - 1, 200, (leftside and "left" or "right"))
		end
		setColor(mod.config.fgColor2.r, mod.config.fgColor2.g, mod.config.fgColor2.b, 1)
		love.graphics.printf(beattoolsParam, pos[1], pos[2], 200, (leftside and "left" or "right"))
	end

	--draw cursor event
	if cs.placeEvent ~= '' and not imgui.love.GetWantCaptureMouse() then
		local eventAlpha = 0.5
		if cs.blockPlacement then
			eventAlpha = 0.25
		end
		eventVisuals.drawSprite({ type = cs.placeEvent, angle = cs.cursorAngle, time = cs.cursorBeat, isCursor = true }, eventAlpha, "selected")
	end
end

return eventVisuals