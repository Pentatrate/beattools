log = print
print = function(...)
    if mods and mods.beattools and mods.beattools.config and mods.beattools.config.isolateLogs ~= nil and not mods.beattools.config.isolateLogs then
        log(...)
	end
end