local stopwatch = {
	rounding = 1e2
}

stopwatch.last = love.timer.getTime()

function stopwatch.set()
	stopwatch.last = love.timer.getTime()
end
function stopwatch.get(reset)
	local last = stopwatch.last
	if reset then stopwatch.last = love.timer.getTime() end
	return utilitools.number.round(love.timer.getTime() - last, stopwatch.rounding)
end
function stopwatch.time(message)
	local last = stopwatch.last
	stopwatch.last = love.timer.getTime()
	modlog(mod, tostring(message) .. " | Time: " .. tostring(utilitools.number.round(love.timer.getTime(), stopwatch.rounding)) .. " (" .. tostring(utilitools.number.round(love.timer.getTime() - last, stopwatch.rounding)) .. ")")
end

return stopwatch