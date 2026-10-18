local fakeRepeat2 = {
}

function fakeRepeat2.init()
end

function fakeRepeat2.cacheEvent(event, remove, k)
	if remove and (k == "beattoolsRepeatParent" or event.beattoolsRepeatParent) then

	end
end
function fakeRepeat2.checkEvent(event, remove, k)
end

function fakeRepeat2.pack(data) -- pack vanilla events into custom ones (returns a new array)
	if not mods.beattools.config.fakeRepeat then return {}, true end
	return { data.parent }
end
function fakeRepeat2.unpack(parent, id, irreversible) -- unpack custom events into vanilla ones (returns a new array)
	if not mods.beattools.config.fakeRepeat then return {}, true end
	local events = { parent }
	if utilitools.files.beattools.eventVisuals.hasRepeat[parent.type] then
		parent.beattoolsRepeatParent = nil
		parent.beattoolsRepeatHandler = nil
	else
		for i = 1, parent.repeats do
			local newEvent = helpers.copy(parent)

			newEvent.time = newEvent.time + i * (newEvent.repeatDelay or 1)
			newEvent.beattoolsRepeatParent, newEvent.beattoolsRepeatHandler, newEvent.repeats, newEvent.repeatDelay = nil, nil, nil, nil
			if not irreversible then
				newEvent.beattoolsRepeatChild = id
			end
			table.insert(events, newEvent)
		end
	end
	return events
end

return fakeRepeat2