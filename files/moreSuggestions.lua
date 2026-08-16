local moreSuggestions = {
	decoIds = {},
	listen = { type = true, id = true }
}

function moreSuggestions.init()
	moreSuggestions.decoIds = {}
end

function moreSuggestions.cacheEvent(event, remove, k)
	if event.type == "deco" and event.id and event.id ~= "" then
		moreSuggestions.decoIds[event.id] = moreSuggestions.decoIds[event.id] or {}
		if remove then
			moreSuggestions.decoIds[event.id][tostring(event)] = nil
		else
			moreSuggestions.decoIds[event.id][tostring(event)] = event
		end
		if utilitools.table.emptyTable(moreSuggestions.decoIds[event.id]) and remove then -- if its not remove
			moreSuggestions.decoIds[event.id] = nil
		end
	end
end

function moreSuggestions.getDecoIds(event)
	local r = {}
	for k, v in pairs(moreSuggestions.decoIds) do
		if utilitools.table.tableAmount(v) > 1 or not v[tostring(event)] then
			table.insert(r, k)
		end
	end
	return r
end

return moreSuggestions