local eventPacking = {
	ids = {},
	handlers = { fakeRepeat2 = true, tag = true },
	default = "fakeRepeat2"
}

function eventPacking.init()
	eventPacking.ids  = {}
end

function eventPacking.makeNewIndex()
	local i = 0
	while eventPacking.ids[i] do i = i + 1 end
	return i
end

function eventPacking.cacheEvent(event, remove, k, from, to, isFullSave)
	if k == "beattoolsRepeatParent" or event.beattoolsRepeatParent then
		if not utilitools.files.beattools.undo.undoing and not remove and eventPacking.ids[event.beattoolsRepeatParent] and eventPacking.ids[event.beattoolsRepeatParent] ~= event then
			-- modlog(mod, "already exists", event.beattoolsRepeatParent)
			local temp = event.beattoolsRepeatParent
			local temp2 = eventPacking.ids[event.beattoolsRepeatParent]
			event.beattoolsRepeatParent = eventPacking.makeNewIndex()
			eventPacking.ids[temp] = temp2
		end
		eventPacking.ids[event.beattoolsRepeatParent] = not remove and event or nil
	end
end

function eventPacking.pack(levelevents, targetId, modifyDirectly, ...) -- pack vanilla events into custom ones (returns a new array)
	levelevents = levelevents or cs and cs.level and cs.level.events
	levelevents = not modifyDirectly and helpers.copy(levelevents) or levelevents
	if not levelevents then return {} end

	local ids = {}
	local function insert(id, event, parent)
		if targetId and targetId ~= id then return end
		if not parent then event.beattoolsRepeatParent = nil event.beattoolsRepeatHandler = nil end
		if type(id) ~= "number" or id % 1 ~= 0 then event[parent and "beattoolsRepeatParent" or "beattoolsRepeatChild"] = nil event.beattoolsRepeatHandler = nil return end

		ids[id] = ids[id] or { children = {} }
		if parent then
			ids[id].parent = event
		else
			table.insert(ids[id].children, event)
		end
		return true
	end
	for i = #levelevents, 1, -1 do
		local event = levelevents[i]
		if event.beattoolsRepeatChild or event.beattoolsRepeatParent then
			if insert(event.beattoolsRepeatChild or event.beattoolsRepeatParent, event, not event.beattoolsRepeatChild) then
				table.remove(levelevents, i)
			end
		end
	end
	local function insertEvents(id, data, ...)
		if not data.parent then modlog(mod, "no parent", id, data) end
		local handler = data.parent and data.parent.beattoolsRepeatHandler and eventPacking.handlers[data.parent.beattoolsRepeatHandler] and data.parent.beattoolsRepeatHandler or eventPacking.default

		if eventPacking.ids[id] and eventPacking.ids[id] ~= data.parent then
			data.parent.beattoolsRepeatParent = eventPacking.makeNewIndex()
			id = data.parent.beattoolsRepeatParent
			for _, event in ipairs(data.children) do event.beattoolsRepeatChild = id end
		end

		local events, failed
		if utilitools.files.beattools[handler].pack then
			events, failed = utilitools.files.beattools[handler].pack(data, id, ...)
			if failed then events = { data.parent, unpack(data.children) } end
		else events = { data.parent, unpack(data.children) } end

		if type(events) == "table" then for _, event in ipairs(events) do table.insert(levelevents, event) end end
	end
	for id, data in pairs(ids) do insertEvents(id, data, ...) end
	return levelevents
end
function eventPacking.unpack(levelevents, targetId, modifyDirectly, ...) -- unpack custom events into vanilla ones (returns a new array)
	levelevents = levelevents or cs and cs.level and cs.level.events
	levelevents = not modifyDirectly and helpers.copy(levelevents) or levelevents
	if not levelevents then return {} end

	local ids = {}
	local function insert(id, event, parent)
		if targetId and targetId ~= id then return end
		if not parent then event.beattoolsRepeatParent = nil event.beattoolsRepeatHandler = nil end
		if type(id) ~= "number" or id % 1 ~= 0 then event[parent and "beattoolsRepeatParent" or "beattoolsRepeatChild"] = nil event.beattoolsRepeatHandler = nil return end

		ids[id] = ids[id] or { children = {} }
		if parent then
			ids[id].parent = event
		else
			table.insert(ids[id].children, event)
		end
		return true
	end
	for i = #levelevents, 1, -1 do
		local event = levelevents[i]
		if event.beattoolsRepeatChild or event.beattoolsRepeatParent then
			if insert(event.beattoolsRepeatChild or event.beattoolsRepeatParent, event, not event.beattoolsRepeatChild) then
				table.remove(levelevents, i)
			end
		end
	end
	local function insertEvents(id, data, ...)
		if not data.parent then modlog(mod, "no parent", id, data) end
		local handler = data.parent and data.parent.beattoolsRepeatHandler and eventPacking.handlers[data.parent.beattoolsRepeatHandler] and data.parent.beattoolsRepeatHandler or eventPacking.default

		local events, failed
		if utilitools.files.beattools[handler].unpack then
			events, failed = utilitools.files.beattools[handler].unpack(data, id, ...)
			if failed then events = { data.parent, unpack(data.children) } end
		else events = { data.parent, unpack(data.children) } end

		if type(events) == "table" then for _, event in ipairs(events) do table.insert(levelevents, event) end end
	end
	for id, data in pairs(ids) do insertEvents(id, data, ...) end
	return levelevents
end

return eventPacking