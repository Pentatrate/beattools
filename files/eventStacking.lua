local eventStacking = {
	stacks = {}
}

function eventStacking.addToStack(event)
	local t
	local k = type(Event.editorDraw[event.type]) == "function" and "func" or "img"

	eventStacking.stacks[event.time] = eventStacking.stacks[event.time] or {}
	eventStacking.stacks[event.time][event.angle % 360] = eventStacking.stacks[event.time][event.angle % 360] or {}
	eventStacking.stacks[event.time][event.angle % 360][k] = eventStacking.stacks[event.time][event.angle % 360][k] or {}

	t = eventStacking.stacks[event.time][event.angle % 360][k]

	table.insert(t, event)
end

function eventStacking.removeFromStack(event)
	local t
	local k = type(Event.editorDraw[event.type]) == "function" and "func" or "img"

	eventStacking.stacks[event.time] = eventStacking.stacks[event.time] or {}
	eventStacking.stacks[event.time][event.angle % 360] = eventStacking.stacks[event.time][event.angle % 360] or {}
	eventStacking.stacks[event.time][event.angle % 360][k] = eventStacking.stacks[event.time][event.angle % 360][k] or {}

	t = eventStacking.stacks[event.time][event.angle % 360][k]

	table.insert(t, event)
end

return eventStacking