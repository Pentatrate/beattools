local eventStacking = {
	stacks = {},
	gameplayStack = {},
	events = {},
	listen = { type = true, time = true, angle = true, order = true }
}

--[[
todo
- update biggest beat
]]

function eventStacking.init()
	eventStacking.stacks = {}
	eventStacking.gameplayStack = {}
	eventStacking.events = {}
end

local chartTypeExceptions = {
	paddles = true,
	setBounceHeight = true,
	ladybug_coin = true,
	extraTap = true
}
function eventStacking.getType(event)
	local eventType
	if type(event) == "table" then
		if not (event and event.type and event.time and event.angle) then modwarn(mod, "eventStacking.getType: Invalid event: ", event) return "func" end
		eventType = event.type
	elseif type(event) == "string" then
		eventType = event
	end
	if not Event.info[eventType] then modwarn(mod, "eventStacking.getType: Invalid event type: ", event) return "func" end
	if Event.editorDraw[eventType] == nil then return "img" end -- genericevent
	return Event.info[eventType].storeInChart and not chartTypeExceptions[eventType] and "func" or "img"
end
function eventStacking.getOppositeType(event)
	return eventStacking.getType(event) == "func" and "img" or "func"
end

function eventStacking.getAngle(event)
	return (mods.beattools.config.displayEndAngle and event.endAngle or event.angle) % 360
end

function eventStacking.cacheEvent(event, remove, _k, dontCheck)
	if not (event and event.type and event.time and event.angle) then modwarn(mod, "eventStacking.cacheEvent: Invalid event: ", event) return end
	local k = eventStacking.getType(event)
	local angle = eventStacking.getAngle(event)

	if not dontCheck then
		local visibility, type = utilitools.files.beattools.eventGroups.eventVisibility(event, true)
		if type ~= 1 then
			modlog(mod, "refused " .. tostring(event.type) .. " " .. tostring(visibility) .. " " .. tostring(type))
			return
		end
	end

	eventStacking.stacks[event.time] = eventStacking.stacks[event.time] or {}
	eventStacking.stacks[event.time][angle] = eventStacking.stacks[event.time][angle] or {}
	eventStacking.stacks[event.time][angle][k] = eventStacking.stacks[event.time][angle][k] or {}

	local t = eventStacking.stacks[event.time][angle][k]

	if remove then
		local i = 1
		while i <= #t do
			local v = t[i]
			-- i could make this O(log(n)) instead of O(n), if it lags too much
			if v.type < event.type or (v.type == event.type and ((v.order or 0) < (event.order or 0) or ((v.order or 0) == (event.order or 0) and (tostring(v) < tostring(event))))) then
			elseif v == event then
				eventStacking.events[tostring(v)] = nil
				if k == "func" and #t <= 2 and eventStacking.gameplayStack[event.time] and eventStacking.gameplayStack[event.time][angle] then
					eventStacking.gameplayStack[event.time][angle] = nil
					local bool = true
					for _, _ in pairs(eventStacking.gameplayStack[event.time]) do
						bool = false
						break
					end
					if bool then eventStacking.gameplayStack[event.time] = nil end
				end
				table.remove(t, i)
				i = i - 1
			elseif k == "img" then
				if eventStacking.events[tostring(v)] == i - 1 then modwarn(mod, "DOESNT EXIST") break end
				eventStacking.events[tostring(v)] = i - 1
			else break end
			i = i + 1
		end

		if #t == 0 then
			eventStacking.stacks[event.time][angle][k] = nil
			t = nil
			if eventStacking.stacks[event.time][angle][eventStacking.getOppositeType(event)] == nil then
				eventStacking.stacks[event.time][angle] = nil
				for _, _ in pairs(eventStacking.stacks[event.time]) do
					return
				end
				eventStacking.stacks[event.time] = nil
			end
		end
	else
		local bool = true
		local i = 1
		while i <= #t do
			local v = t[i]
			-- i could make this O(log(n)) instead of O(n), if it lags too much
			if v.type < event.type or (v.type == event.type and ((v.order or 0) < (event.order or 0) or ((v.order or 0) == (event.order or 0) and (tostring(v) < tostring(event))))) then
			elseif v == event then
				bool = false
				-- modlog(mod, "duplicate")
				return
			elseif bool then
				table.insert(t, i, event)
				bool = false
				if k == "img" then
					eventStacking.events[tostring(event)] = i - 1
				elseif #t > 1 then
					eventStacking.gameplayStack[event.time] = eventStacking.gameplayStack[event.time] or {}
					eventStacking.gameplayStack[event.time][angle] = true
				end
			elseif k == "img" then
				if eventStacking.events[tostring(v)] == i - 1 then break end
				eventStacking.events[tostring(v)] = i - 1
			else return end
			i = i + 1
		end
		if bool then
			table.insert(t, event)
			bool = false
			if k == "img" then
				eventStacking.events[tostring(event)] = #t - 1
			elseif #t > 1 then
				eventStacking.gameplayStack[event.time] = eventStacking.gameplayStack[event.time] or {}
				eventStacking.gameplayStack[event.time][angle] = true
			end
		end
	end
end

function eventStacking.getIndex(event)
	if not (event and event.type and event.time and event.angle) then modwarn(mod, "eventStacking.getIndex: Invalid event: ", event) return "func" end
	local k = eventStacking.getType(event)
	local angle = eventStacking.getAngle(event)

	if event and event.time and event.angle and k == "img" and eventStacking.stacks[event.time] and eventStacking.stacks[event.time][angle] then
		local index = eventStacking.events[tostring(event)]
		if not index then
			if eventStacking.stacks[event.time][angle][k] then
				-- cursor event
				index = #eventStacking.stacks[event.time][angle][k]
			else
				index = 0
			end
		end

		if eventStacking.stacks[event.time][angle][eventStacking.getOppositeType(event)] then
			return index + 1
		elseif cs.placeEvent ~= "" and eventStacking.getType(cs.placeEvent) == "func" and cs.cursorBeat == event.time and cs.cursorAngle % 360 == angle then
			return index + 1
		end
		return index
	end
	return 0
end

function eventStacking.inStack(event)
	if not (event and event.type and event.time and event.angle) then modwarn(mod, "eventStacking.inStack: Invalid event: ", event) return "func" end
	local k = eventStacking.getType(event)
	local angle = eventStacking.getAngle(event)

	if event and event.time and event.angle and k == "img" and eventStacking.stacks[event.time] and eventStacking.stacks[event.time][angle] then
		local t = eventStacking.stacks[event.time][angle][k]
		return t and (#t > 1 or eventStacking.stacks[event.time][angle][eventStacking.getOppositeType(event)])
	end
	return false
end

return eventStacking