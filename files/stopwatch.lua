local stopwatch = {
	rounding = 1e2
}

stopwatch.last = love.timer.getTime()

function stopwatch.set()
	stopwatch.last = love.timer.getTime()
end
function stopwatch.get(reset)
	local last = stopwatch.last
	local time = love.timer.getTime()
	if reset then stopwatch.last = time end
	return utilitools.number.round(time - last, stopwatch.rounding)
end
function stopwatch.time(message)
	local last = stopwatch.last
	stopwatch.last = love.timer.getTime()
	modlog(mod, tostring(message) .. " | Time: " .. tostring(utilitools.number.round(stopwatch.last, stopwatch.rounding)) .. " (" .. tostring(utilitools.number.round(stopwatch.last - last, stopwatch.rounding)) .. ")")
end

return stopwatch