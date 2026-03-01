local stopwatch = {
	rounding = 1e2
}

stopwatch.last = love.timer.getTime()

function stopwatch.time(message)
	local last = stopwatch.last
	stopwatch.last = love.timer.getTime()
	modlog(mod, tostring(message) .. " | Time: " .. tostring(utilitools.number.round(love.timer.getTime(), stopwatch.rounding)) .. " (" .. tostring(utilitools.number.round(love.timer.getTime() - last, stopwatch.rounding)) .. ")")
end

return stopwatch