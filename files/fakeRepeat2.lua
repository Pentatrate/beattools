local fakeRepeat2 = {

}

function fakeRepeat2.init()
end

function fakeRepeat2.cacheEvent(event, remove, k)
end
function fakeRepeat2.checkEvent(event, remove, k)
end

function fakeRepeat2.pack(events, variant, dontCopy)
	if not dontCopy then events = helpers.copy(events) end
	for i = #events, 1, -1 do
		local event = events[i]
		if event.beattoolsRepeatChild then
			table.remove(events, i)
		end
	end
	return events
end
function fakeRepeat2.unpack(events, variant, dontCopy)
	if not dontCopy then events = helpers.copy(events) end
	for i = #events, 1, -1 do
		local event = events[i]
		if utilitools.files.beattools.eventVisuals.hasRepeat[event.type] then
			event.beattoolsRepeatParent = nil
		else
			if event.beattoolsRepeatParent then
			end
		end
	end
	return events
end

return fakeRepeat2