local fakeRepeat2 = {}

function fakeRepeat2.pack(data, id) -- pack vanilla events into custom ones (returns a new array)
	if not mods.beattools.config.fakeRepeat then return {}, true end
	return { data.parent }
end
function fakeRepeat2.unpack(data, id, irreversible) -- unpack custom events into vanilla ones (returns a new array)
	if not mods.beattools.config.fakeRepeat then return {}, true end
	local events = { data.parent }
	if utilitools.files.beattools.eventVisuals.hasRepeat[data.parent.type] then
		data.parent.beattoolsRepeatParent = nil
		data.parent.beattoolsRepeatHandler = nil
	else
		for i = 1, data.parent.repeats do
			local newEvent = helpers.copy(data.parent)

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