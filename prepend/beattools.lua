local st = Gamestate:new('Editor') -- Penta: This comment is neccessary

local beattoolsKeysWhiteList = {   -- Add your parameters here if you want changes to this parameter to get saved and be undo-/redoable
	type = true,
	time = true,
	angle = true,
	order = true,
	angle2 = true,
	duration = true,
	segments = true,
	holdEase = true,
	endAngle = true,
	spinEase = true,
	speedMult = true,
	tap = true,
	startTap = true,
	endTap = true,
	tickRate = true,
	name = true,
	r = true,
	g = true,
	b = true,
	description = true,
	tag = true,
	angleOffset = true,
	enabled = true,
	paddle = true,
	newWidth = true,
	newAngle = true,
	ease = true,
	file = true,
	bpm = true,
	volume = true,
	offset = true,
	id = true,
	sprite = true,
	parentid = true,
	rotationinfluence = true,
	orbit = true,
	x = true,
	y = true,
	sx = true,
	sy = true,
	ox = true,
	oy = true,
	kx = true,
	ky = true,
	drawLayer = true,
	drawOrder = true,
	recolor = true,
	outline = true,
	hide = true,
	effectCanvas = true,
	effectCanvasRaw = true,
	var = true,
	start = true,
	value = true,
	repeats = true,
	repeatDelay = true,
	spriteName = true,
	enable = true,
	chance = true,
	color = true,
	sound = true,
	pitch = true,
	voidColor = true,
	block = true,
	miss = true,
	mine = true,
	mineHold = true,
	side = true,
	a = true, -- depreciated or dev only event parameters in the vanilla game
	paddles = true,
	objectName = true,
	variableName = true,
	reps = true,
	delay = true,
	intensity = true,
	traceEase = true,
	doDithering = true,
	beattoolsLayer = true        -- Mod: "Beattools" by Pentatrate
}
local beattoolsKeysBlacklist = { -- Add your parameters here if you dont want changes to this parameter to get saved and be undo-/redoable (especially when the parameter gets auto updated)
	beattoolsIndex = true,       -- Mod: "Beattools" by Pentatrate
	beattoolsInStack = true,
	beattoolsRepeatIndex = true,
	beattoolsRepeats = true
}

local beattoolsTime = 0
local beattoolsEditorBeat = 0
local beattoolsPrevEvents
local beattoolsSelect
local beattoolsPrevSelect
beattoolsAngleSnap = 4

local beattoolsOverlap = {}       -- event stacking

local beattoolsStartBeat          -- restart in playtest

local beattoolsRepeatIndices = {} -- fake repeat

local beattoolsChangeList = {}    -- undo/redo
local beattoolsChangeIndex = 0
local beattoolsLastCheck = 0

beattoolsRecordPosition = false -- record position
beattoolsRecordFunc = nil

local beattoolsPlayerSpriteChanged = {}
local beattoolsLastSpriteModified = 0

local beattoolsRandomizeWindows = mods.beattools.config.randomizeWindows ~= "off" -- randomize windows

local beattoolsPlayerSprite = "idle"
local beattoolsLastSpriteChange = 0

local beattoolsAllEases = dpf.loadJson("Mods/beattools/easeList/all.json")
local beattoolsUselessEases = dpf.loadJson("Mods/beattools/easeList/apparentlyUseless.json")
local beattoolsTrollEases = dpf.loadJson("Mods/beattools/easeList/trollEases.json")
local beattoolsAllEasesSorted = {}
local beattoolsEasesSelected = {}
beattoolsOnlyEases = {}
beattoolsOnlyBooleans = {}
local beattoolsTrackEasables
local beattoolsDefaultEasings = {
	color = {
		{ r = { r = 255 }, g = { g = 255 }, b = { b = 255 } },
		{ r = { r = 0 },   g = { g = 0 },   b = { b = 0 } },
		{ r = { r = 127 }, g = { g = 127 }, b = { b = 127 } },
		{ r = { r = 191 }, g = { g = 191 }, b = { b = 191 } },
		{ r = { r = 0 },   g = { g = 0 },   b = { b = 0 } },
		{ r = { r = 0 },   g = { g = 0 },   b = { b = 0 } },
		{ r = { r = 0 },   g = { g = 0 },   b = { b = 0 } },
		{ r = { r = 0 },   g = { g = 0 },   b = { b = 0 } }
	},
	ease = {},
	paddles = {
		{ enabled = { enabled = true },  newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } },
		{ enabled = { enabled = false }, newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } },
		{ enabled = { enabled = false }, newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } },
		{ enabled = { enabled = false }, newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } },
		{ enabled = { enabled = false }, newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } },
		{ enabled = { enabled = false }, newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } },
		{ enabled = { enabled = false }, newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } },
		{ enabled = { enabled = false }, newWidth = { newWidth = 70 }, newAngle = { newAngle = 0 } }
	},
	bookmarks = { name = "Start", description = "", r = 0, g = 0, b = 0, time = -1e9, order = 1e9, start = true },
	playerSprites = { spriteName = "" },
	songNameOverride = { newname = nil },
	decos = { }
}
local decoDefault = {
	["sprite"] = "",
	["parentid"] = "",
	["rotationinfluence"] = 1,
	["orbit"] = false,
	["x"] = 300,
	["y"] = 180,
	["r"] = 0,
	["sx"] = 1,
	["sy"] = 1,
	["ox"] = 0,
	["oy"] = 0,
	["kx"] = 0,
	["ky"] = 0,
	["mirror"] = "none",
	["exclusiveMirror"] = false,
	["drawLayer"] = "fg",
	["drawOrder"] = 0,
	["recolor"] = -1,
	["outline"] = false,
	["hide"] = false,
	["tiling"] = false,
	["uvx"] = 0,
	["uvy"] = 0,
	["uvdx"] = 0,
	["uvdy"] = 0,
	["alphadither"] = false,
	["ditherpercent"] = 1,
	["effectCanvas"] = false,
	["effectCanvasType"] = "recolor",
	["effectCanvasRaw"] = false,
	["ecRecolorR"] = 255,
	["ecRecolorG"] = 255,
	["ecRecolorB"] = 255,
	["ecRecolorA"] = 255

}
local beattoolsEasings = {}
local beattoolsCurrentEasings = {}
local beattoolsEasingFor = {
	color = ipairs,
	ease = pairs,
	paddles = { ipairs, pairs },
	bookmarks = true,
	playerSprites = true,
	songNameOverride = true,
	decos = { pairs, pairs }
}

local beattoolsEventGroups = {}
local beattoolsEventIndices = {}
local beattoolsHighestEventGroupIndex = -1
local beattoolsEventGroupLongest = 0
local beattoolsEventVisibilities = {}

for k, v in pairs(beattoolsAllEases) do
	table --[[stop wrong injection]].insert(beattoolsAllEasesSorted, k)
	if type(v) == "boolean" then
		table --[[stop wrong injection]].insert(beattoolsOnlyBooleans, k)
	else
		table --[[stop wrong injection]].insert(beattoolsOnlyEases, k)
	end
	if v == "nil" then v = nil end
	beattoolsDefaultEasings.ease[k] = { [type(v) == "boolean" and "enable" or "value"] = v }
end
table.sort(beattoolsAllEasesSorted, function(a, b)
	if type(beattoolsAllEases[a]) ~= type(beattoolsAllEases[b]) then
		if type(beattoolsAllEases[a]) == "number" then return true end
		if type(beattoolsAllEases[b]) == "number" then return false end
		return type(beattoolsAllEases[a]) == "boolean"
	end
	if a:sub(1, #"vfx.vars") == "vfx.vars" and b:sub(1, #"vfx.vars") == "vfx.vars" then
		return tonumber(a:sub(#"vfx.vars" + 1)) < tonumber(b:sub(#"vfx.vars" + 1))
	end
	return a < b
end)
for k, v in pairs(beattoolsDefaultEasings) do beattoolsEasings[k] = {} end
if true then -- add easing
	local function beattoolsAddEasing(type, v, i, params, sub, subsub, convert)
		local value = { indexInLevel = i }
		table --[[stop wrong injection]].insert(params, "time")
		table --[[stop wrong injection]].insert(params, "order")
		for i, k in ipairs(params) do
			value[k] = v[k]
		end
		if convert == "bgColor" then
			value.var = sub
			value.value = v.color
		elseif convert == "voidColor" then
			value.var = sub
			value.value = v.voidColor
		elseif convert == "outline" then
			value.var = sub
			value.value = v.enable and v.color or nil
		elseif convert == "bgNoise" then
			value.var = sub
			value.value = v.chance
		elseif convert == "bgNoiseColor" then
			value.var = sub
			value.value = v.color
		elseif convert == "particlesBlock" then
			value.var = sub
			value.enable = v.block
		elseif convert == "particlesMiss" then
			value.var = sub
			value.enable = v.miss
		elseif convert == "particlesMine" then
			value.var = sub
			value.enable = v.mine
		elseif convert == "particlesMineHold" then
			value.var = sub
			value.enable = v.mineHold
		elseif convert == "particlesSide" then
			value.var = sub
			value.enable = v.side
		end
		if sub then
			if beattoolsEasings[type][sub] == nil then
				beattoolsEasings[type][sub] = {}
			end
			if subsub then
				if beattoolsEasings[type][sub][subsub] == nil then
					beattoolsEasings[type][sub][subsub] = {}
				end
				table --[[stop wrong injection]].insert(beattoolsEasings[type][sub][subsub], value)
			else
				table --[[stop wrong injection]].insert(beattoolsEasings[type][sub], value)
			end
		else
			table --[[stop wrong injection]].insert(beattoolsEasings[type], value)
		end
	end
	beattoolsTrackEasables = {
		setColor = function(v, i)
			if v.color ~= nil then
				local temp = false
				if v.r ~= nil then
					beattoolsAddEasing("color", v, i, { "r", "duration", "ease" }, v.color + 1, "r")
					temp = true
				end
				if v.g ~= nil then
					beattoolsAddEasing("color", v, i, { "g", "duration", "ease" }, v.color + 1, "g")
					temp = true
				end
				if v.b ~= nil then
					beattoolsAddEasing("color", v, i, { "b", "duration", "ease" }, v.color + 1, "b")
					temp = true
				end
				if temp then
					beattoolsEasings.color[v.color + 1].eventAmount = (beattoolsEasings.color[v.color + 1].eventAmount or 0) +
						1
				end
			end
		end,
		setBgColor = function(v, i)
			if v.color ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "bgColor", nil, "bgColor")
			end
			if v.voidColor ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "voidColor", nil, "voidColor")
			end
		end,
		outline = function(v, i)
			if v.color ~= nil and v.enable ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "outline", nil, "outline")
			end
		end,
		noise = function(v, i)
			if v.chance ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "vfx.bgNoise", nil, "bgNoise")
			end
			if v.color ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "vfx.bgNoiseColor", nil, "bgNoiseColor")
			end
		end,
		ease = function(v, i)
			if v.var ~= nil and v.var ~= "" and type(beattoolsAllEases[v.var]) == "number" then
				beattoolsAddEasing("ease", v, i, { "value", "start", "duration", "ease" }, v.var)
				if v.repeats and v.repeats > 0 and (v.repeatDelay or 1) ~= 0 then
					local v2 = helpers.copy(v)
					for i = 1, v.repeats do
						v2.time = v2.time + (v.repeatDelay or 1)
						beattoolsAddEasing("ease", v2, i, { "value", "start", "duration", "ease" }, v.var)
					end
				end
			end
		end,
		hom = function(v, i)
			if v.enable ~= nil then
				beattoolsAddEasing("ease", v, i, { "enable" }, "vfx.hom")
			end
		end,
		paddles = function(v, i)
			if v.paddle ~= nil then
				local function addEasing(i)
					if v.enabled ~= nil then
						beattoolsAddEasing("paddles", v, i, { "enabled" }, i, "enabled")
					end
					if v.newWidth ~= nil then
						beattoolsAddEasing("paddles", v, i, { "newWidth", "duration", "ease" }, i, "newWidth")
					end
					if v.newAngle ~= nil then
						beattoolsAddEasing("paddles", v, i, { "newAngle", "duration", "ease" }, i, "newAngle")
					end
				end
				if v.paddle == 0 then
					for i = 1, 7 do
						addEasing(i)
					end
				else
					addEasing(v.paddle)
				end
			end
		end,
		bookmark = function(v, i)
			if v.name ~= nil and v.name ~= "" then
				beattoolsAddEasing("bookmarks", v, i, { "name", "description", "r", "g", "b" })
			end
		end,
		forcePlayerSprite = function(v, i)
			if v.spriteName ~= nil then
				beattoolsAddEasing("playerSprites", v, i, { "spriteName", "useFaceStencil" })
			end
		end,
		setBoolean = function(v, i)
			if v.var ~= nil and v.var ~= "" and type(beattoolsAllEases[v.var]) == "boolean" then
				beattoolsAddEasing("ease", v, i, { "enable" }, v.var)
			end
		end,
		toggleParticles = function(v, i)
			if v.block ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "vfx.noteParticles.block", nil, "particlesBlock")
			end
			if v.miss ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "vfx.noteParticles.miss", nil, "particlesMiss")
			end
			if v.mine ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "vfx.noteParticles.mine", nil, "particlesMine")
			end
			if v.mineHold ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "vfx.noteParticles.mineHold", nil, "particlesMineHold")
			end
			if v.side ~= nil then
				beattoolsAddEasing("ease", v, i, {}, "vfx.noteParticles.side", nil, "particlesSide")
			end
		end,
		songNameOverride = function(v, i)
			if v.newname ~= nil then
				beattoolsAddEasing("songNameOverride", v, i, { "newname" })
			end
		end,
		deco = function(v, i)
			if v.id ~= nil then
				for k, _ in pairs(v) do
					local easable = {
						["rotationinfluence"] = true,
						["x"] = true,
						["y"] = true,
						["r"] = true,
						["sx"] = true,
						["sy"] = true,
						["ox"] = true,
						["oy"] = true,
						["kx"] = true,
						["ky"] = true,
						["uvx"] = true,
						["uvy"] = true,
						["uvdx"] = true,
						["uvdy"] = true,
						["ditherpercent"] = true,
						["ecRecolorR"] = true,
						["ecRecolorG"] = true,
						["ecRecolorB"] = true,
						["ecRecolorA"] = true
					}
					local nonEasable = {
						["sprite"] = true,
						["parentid"] = true,
						["orbit"] = true,
						["mirror"] = true,
						["exclusiveMirror"] = true,
						["drawLayer"] = true,
						["drawOrder"] = true,
						["recolor"] = true,
						["outline"] = true,
						["hide"] = true,
						["tiling"] = true,
						["alphadither"] = true,
						["effectCanvas"] = true,
						["effectCanvasType"] = true,
						["effectCanvasRaw"] = true
					}
					if easable[k] then
						beattoolsAddEasing("decos", v, i, { k, "duration", "ease" }, v.id, k)
					end
					if nonEasable[k] then
						beattoolsAddEasing("decos", v, i, { k }, v.id, k)
					end
				end
			end
		end,
	}
end

local function beattoolsRGB2Hex(r, g, b) return ("%02X%02X%02X"):format(r, g, b) end

local function beattoolsRemoveParameters(self)
	for k, v in pairs(self.level.events) do
		v.beattoolsIndex, v.beattoolsInStack = nil, nil
	end
end

local function beattoolsGetCurrentEasing(self, type2, vars, time2, sub, subsub, excludeIndex)
	local time = 0
	if time2 == "editorBeat" then
		time = self.editorBeat or 0
	elseif type(time2) == "number" then
		time = time2 or 0
	end
	local beattoolsCurrentEased, beattoolsPrev, beattoolsCurrent, easingArray, easingVars
	if beattoolsCurrentEasings[time2] == nil then
		beattoolsCurrentEasings[time2] = {}
	end
	if type2 == "decos" then
		beattoolsCurrentEased = { [subsub] = decoDefault[subsub]}
	else
		if sub then
			if subsub then
				if beattoolsDefaultEasings[type2][sub] == nil then
					beattoolsDefaultEasings[type2][sub] = {}
				end
				beattoolsCurrentEased = beattoolsDefaultEasings[type2][sub][subsub]
			else
				beattoolsCurrentEased = beattoolsDefaultEasings[type2][sub]
			end
		else
			beattoolsCurrentEased = beattoolsDefaultEasings[type2]
		end
	end
	if sub then
		if beattoolsEasings[type2] == nil then
			beattoolsEasings[type2] = {}
		end
		if beattoolsCurrentEasings[time2][type2] == nil then
			beattoolsCurrentEasings[time2][type2] = {}
		end
		if subsub then
			if beattoolsEasings[type2][sub] == nil then
				beattoolsEasings[type2][sub] = {}
			end
			if beattoolsCurrentEasings[time2][type2][sub] == nil then
				beattoolsCurrentEasings[time2][type2][sub] = {}
			end
			easingArray = beattoolsEasings[type2][sub][subsub]
			beattoolsCurrent = helpers.copy(beattoolsCurrentEasings[time2][type2][sub][subsub])
		else
			easingArray = beattoolsEasings[type2][sub]
			beattoolsCurrent = helpers.copy(beattoolsCurrentEasings[time2][type2][sub])
		end
	else
		easingArray = beattoolsEasings[type2]
		beattoolsCurrent = helpers.copy(beattoolsCurrentEasings[time2][type2])
	end

	if beattoolsCurrent ~= nil and beattoolsCurrent.lastCheckTime == time then
		return beattoolsCurrent
	end

	if vars == "rgb" then
		easingVars = { r = true, g = true, b = true }
	elseif vars == "bookmark" then
		easingVars = { name = true, description = true, r = true, g = true, b = true }
	elseif vars == "var" then
		if type(beattoolsAllEases[sub]) == "number" or sub == "outline" then
			easingVars = { value = true }
		elseif type(beattoolsAllEases[sub]) == "boolean" then
			easingVars = { enable = true }
		end
	else
		easingVars = { [vars] = true }
	end

	if beattoolsCurrentEased == nil then
		beattoolsCurrentEased = {}
		log(mods.beattools, "There's no default value for " ..
			type2 .. "." .. tostring(sub) .. "." .. tostring(subsub) .. " => " .. vars)
	end

	local i = 1
	if easingArray and #easingArray > 0 then
		-- Get last ease
		while easingArray[i] ~= nil and ((self.level ~= nil and self.level.properties ~= nil and self.level.properties.loadBeat ~= nil and easingArray[i].time <= self.level.properties.loadBeat) or easingArray[i].time <= time) and (excludeIndex == nil or easingArray[i].indexInLevel ~= excludeIndex) do
			beattoolsPrev = beattoolsCurrentEased
			beattoolsCurrentEased = helpers.copy(easingArray[i])
			--[[for k, v in pairs(easingVars) do
				if beattoolsCurrentEased[k] == nil then
					beattoolsCurrentEased[k] = beattoolsPrev[k]
				end
			end]]
			i = i + 1
		end

		for k, v in pairs(easingVars) do
			if beattoolsCurrentEased[k] == nil and (type2 ~= "ease" or sub ~= "outline" or subsub ~= nil) then
				log(mods.beattools, "There's no ease value for " ..
					type2 .. " . " .. tostring(sub) .. " . " .. tostring(subsub) .. " . " .. k)
			end
			if beattoolsPrev and beattoolsPrev[k] == nil and (type2 ~= "ease" or sub ~= "outline" or subsub ~= nil) then
				log(mods.beattools, "There's no previous ease value for " ..
					type2 .. " . " .. tostring(sub) .. " . " .. tostring(subsub) .. " . " .. k)
			end
		end

		if beattoolsCurrentEased.time ~= nil then
			local beattoolsEventTime = (function()
				if self.level ~= nil and self.level.properties ~= nil and self.level.properties.loadBeat ~= nil and beattoolsCurrentEased.time <= self.level.properties.loadBeat then
					if self.level.properties.startingBeat ~= nil then
						return self.level.properties.startingBeat
					else
						return -8
					end
				else
					return beattoolsCurrentEased.time
				end
			end)()
			if beattoolsCurrentEased.duration ~= nil and beattoolsCurrentEased.duration > 0 and time < beattoolsEventTime + beattoolsCurrentEased.duration and beattoolsPrev then
				local beattoolsEase = (flux.easing[beattoolsCurrentEased.ease] or flux.easing["linear"])((time - beattoolsEventTime) /
					beattoolsCurrentEased.duration)
				if vars == "var" and beattoolsCurrentEased.start ~= nil then
					beattoolsPrev.value = beattoolsCurrentEased.start
				end

				for k, v in pairs(easingVars) do
					beattoolsCurrentEased[k] = beattoolsPrev[k] +
						beattoolsEase * (beattoolsCurrentEased[k] - beattoolsPrev[k])
				end
			end
		end
	end

	if type(beattoolsCurrentEased) ~= "table" then
		log(mods.beattools,
			"Not a table: " .. type2 .. "." .. sub .. "." .. subsub .. " => " .. tostring(beattoolsCurrentEased))
	end
	beattoolsCurrentEased.lastCheckTime = time
	beattoolsCurrentEased.runEvents = i
	if sub then
		if subsub then
			beattoolsCurrentEasings[time2][type2][sub][subsub] = beattoolsCurrentEased
		else
			beattoolsCurrentEasings[time2][type2][sub] = beattoolsCurrentEased
		end
	else
		beattoolsCurrentEasings[time2][type2] = beattoolsCurrentEased
	end

	return beattoolsCurrentEased
end

local function beattoolsGetEventIndex(self, event)
	if event == nil then return end
	for i, v in ipairs(self.level.events) do
		if v == event then return i end
	end
end

local function beattoolsOverrideChanges()
	while #beattoolsChangeList > beattoolsChangeIndex do
		table --[[stop wrong injection]].remove(beattoolsChangeList, #beattoolsChangeList)
	end
end

local function beattoolsNewMultiSelection()
	st.selectedEvent = nil
	st.multiselect = {}
	st.multiselect.events = {}
	st.multiselect.eventTypes = {}

	st.multiselectStartBeat = 0
	st.multiselectEndBeat = 0
	st.multiselectStartAngle = 0
	st.multiselectEndAngle = 360
end
local function beattoolsGetEventVisibility(event)
	if not mods.beattools.config.showEventGroups then return "show" end
	if type(event) ~= "table" then
		utilitools.try(mods.beattools, function() error(tostring(event)) end)
		log(mods.beattools, "eventVisibility: Parameter type is not table: " .. tostring(event))
		return "transparent"
	end
	if event.type == nil then log(mods.beattools, "eventVisibility: Event type is nil: " .. tostring(event)) return "transparent" end
	if beattoolsEventVisibilities[event.type] == nil then beattoolsEventVisibilities[event.type] = {} end
	if beattoolsEventVisibilities[event.type][""] then return beattoolsEventVisibilities[event.type][""] end
	local visibility = "hide"
	for i, v in ipairs(beattoolsEventGroups) do
		if v.visibility ~= " - " then
			if v.events[event.type] or v.name == "all" then
				visibility = v.visibility
			elseif v.events.custom and event.beattoolsCustomEventGroups and event.beattoolsCustomEventGroups[v.name] then
				visibility = v.visibility
			end
		end
	end
	if not event.beattoolsCustomEventGroups then beattoolsEventVisibilities[event.type][""] = visibility end
	return visibility
end

local beattoolsRemoveRepeated, beattoolsRepeatExists, beattoolsUpdateRepeat
local function beattoolsHasChanges(table1, table2, tableType, trackChanges, content, checkAll, overrideKeyHandling, lastResort)
	if table1 == nil or table2 == nil then return true end

	if tableType == "array" then
		if #table1 ~= #table2 and (not trackChanges) then return true end
		local valuesChanged, originalIndex, valueChanges, eventsAdded, eventsRemoved = {}, {}, {}, {}, {}

		local function shouldGetLooped(event)
			if checkAll or content ~= "events" or #st.level.events <= mods.beattools.config.loopVisibleEventsAmount then return true end
			if st.multiselect then
				if trackChanges and #st.multiselect.events > mods.beattools.config.loopSingleSelectionEventAmount then
					if st.multiselect.events[1] == event then return true end
				else
					if #st.multiselect.events > mods.beattools.config.loopEventsDuringSelectionAmount then
						if st.multiselectStartBeat <= event.time and event.time <= st.multiselectEndBeat and st.multiselect.eventTypes[event.type] then return true end
					else
						for i, v in ipairs(st.multiselect.events) do
							if event == v then return true end
						end
					end
				end
			end
			if event == st.selectedEvent or (st.editorBeat <= event.time and event.time <= st.editorBeat + st.drawDistance) then return true end
			return false
		end

		for i, v in ipairs(table1) do -- creates an array with "holes", will get fixed later so that the length operator works properly
			if shouldGetLooped(v) then
				valuesChanged[i] = v
				if trackChanges then originalIndex[i] = i end
			end
		end

		for i = #table2, 1, -1 do
			local v = table2[i]
			if shouldGetLooped(v) then
				if content == "events" then
					if table1[i] == nil then
						if not trackChanges then return true --[[ Penta: should be impossible to trigger, see line 122 ]] end
						table --[[stop wrong injection]].insert(eventsAdded, 1, { event = helpers.copy(v), index = i })
						beattoolsPrevEvents[i] = v
					else
						if beattoolsHasChanges(table1[i], v, "object") then
							if not trackChanges then return true end
							local tempChanges = beattoolsHasChanges(table1[i], v, "object", true)
							table --[[stop wrong injection]].insert(valueChanges, { index = i, changes = tempChanges })
							for ii, vv in ipairs(tempChanges) do
								-- forceprint(table1[i].type .. " in comparison to " .. v.type)
								-- forceprint("Set " .. vv.key .. " from " .. (vv.valueBefore == nil and "nil" or vv.valueBefore .. " originally " .. beattoolsPrevEvents[i][vv.key]) .. " to " .. (vv.valueAfter == nil and "nil" or vv.valueAfter))
								beattoolsPrevEvents[i][vv.key] = vv.valueAfter
							end
						end
						table --[[stop wrong injection]].remove(valuesChanged, i)
						if trackChanges then table --[[stop wrong injection]].remove(originalIndex, i) end
					end
				else
					-- missing code: table does not contain events, can ignore for now, doesnt get called, like ever
				end
			else
				table --[[stop wrong injection]].remove(valuesChanged, i)
				if trackChanges then table --[[stop wrong injection]].remove(originalIndex, i) end -- in the end, originalIndex and valuesChanged should be without "holes"
			end
		end

		if #valuesChanged > 0 then
			if not trackChanges then return true end -- Penta: should be impossible to trigger, see line 122
			for i, v in ipairs(valuesChanged) do
				table --[[stop wrong injection]].insert(eventsRemoved,
					{ event = helpers.copy(v), index = originalIndex[i] })
			end
			for i = #valuesChanged, 1, -1 do
				table --[[stop wrong injection]].remove(beattoolsPrevEvents, originalIndex[i])
			end
		end

		if trackChanges then
			local hasChanges = #eventsAdded > 0 or #eventsRemoved > 0 or #valueChanges > 0
			if (not hasChanges) and #table1 ~= #table2 then return true end
			if hasChanges and lastResort and beattoolsPrevEvents == nil then return false end
			if hasChanges then beattoolsOverrideChanges() end
			if #eventsAdded > 0 then
				log(mods.beattools, "EVENTS .ADDED. NOT TAKEN INTO ACCOUNT Amount " ..
					#eventsAdded .. " Type first " .. eventsAdded[1].event.type .. " Time " .. beattoolsTime)
				table --[[stop wrong injection]].insert(beattoolsChangeList, {
					action = "place",
					time = beattoolsTime,
					events = eventsAdded
				})
				st:updateBiggestBeat()
				-- for i, v in ipairs(eventsAdded) do
				-- 	if v.event.beattoolsRepeatIndex ~= nil then
				-- 		beattoolsRemoveRepeated(st, v.event.beattoolsRepeatIndex)
				-- 	end
				-- 	if v.event.beattoolsRepeats ~= nil and (not beattoolsRepeatExists(st, v.event.beattoolsRepeats)) then
				-- 		beattoolsRemoveRepeated(st, v.event.beattoolsRepeats)
				-- 	end
				-- end
			end
			if #eventsRemoved > 0 then
				log(mods.beattools, "EVENTS REMOVED NOT TAKEN INTO ACCOUNT Amount " ..
					#eventsRemoved .. " Type first " .. eventsRemoved[1].event.type .. " Time " .. beattoolsTime)
				table --[[stop wrong injection]].insert(beattoolsChangeList, {
					action = "delete",
					time = beattoolsTime,
					events = eventsRemoved
				})
				st:updateBiggestBeat()
				if mods.beattools.config.fakeRepeat then
					for i, v in ipairs(eventsRemoved) do
						if v.event.beattoolsRepeatIndex ~= nil then
							beattoolsRemoveRepeated(st, v.event.beattoolsRepeatIndex)
						elseif v.event.beattoolsRepeats ~= nil and (not beattoolsRepeatExists(st, v.event.beattoolsRepeats)) then
							beattoolsRemoveRepeated(st, v.event.beattoolsRepeats)
						end
					end
				end
			end
			if #valueChanges > 0 then
				table --[[stop wrong injection]].insert(beattoolsChangeList, {
					action = "change",
					time = beattoolsTime,
					changes = valueChanges
				})
				if mods.beattools.config.fakeRepeat then
					for i, changes in ipairs(valueChanges) do
						if st.level.events[changes.index].type ~= "ease" then
							if st.level.events[changes.index].beattoolsRepeatIndex ~= nil then
								beattoolsUpdateRepeat(st, st.level.events[changes.index])
							else
								for ii, change in ipairs(changes.changes) do
									if change.key == "repeats" then
										beattoolsUpdateRepeat(st, st.level.events[changes.index])
									end
								end
							end
						end
					end
				end
				st:updateBiggestBeat()
				-- log(mods.beattools, "CHANGES!!!")
				-- for i, changes in ipairs(valueChanges) do
				-- 	for ii, change in ipairs(changes.changes) do
				-- 		forceprint("at " .. tostring(st.level.events[changes.index].type) .. " time " .. tostring(st.level.events[changes.index].time) .. " angle " .. tostring(st.level.events[changes.index].angle) .. " set " .. tostring(change.key) .. " from " .. tostring(change.valueBefore) .. " (type " .. type(change.valueBefore) .. ") to " .. tostring(change.valueAfter) .. " (type " .. type(change.valueAfter) .. ") same? " .. tostring(change.valueBefore == change.valueAfter))
				-- 	end
				-- end
			end
			beattoolsChangeIndex = #beattoolsChangeList
			return false
		end
	elseif tableType == "object" then
		local changes, keyHandling, keysRemoved = {}, mods.beattools.config.keyHandling, {}
		if overrideKeyHandling then keyHandling = overrideKeyHandling end

		for k, v in pairs(table1) do
			local function keepChecking()
				keysRemoved[k] = v
			end
			if keyHandling == "blacklist" then
				if not beattoolsKeysBlacklist[k] then keepChecking() end
			elseif keyHandling == "whitelist" then
				if beattoolsKeysWhiteList[k] then keepChecking() end
			else
				log(mods.beattools, "WARNING: INVALID KEYHANDLING " .. keyHandling)
			end
		end

		for k, v in pairs(table2) do
			local function keepChecking()
				if keysRemoved[k] ~= nil then
					if v ~= keysRemoved[k] then
						if not trackChanges then
							return true
						end
						table --[[stop wrong injection]].insert(changes,
							{ key = k, valueBefore = keysRemoved[k], valueAfter = v })
					end
					keysRemoved[k] = nil
				else
					if not trackChanges then
						return true
					end
					table --[[stop wrong injection]].insert(changes, { key = k, valueAfter = v })
				end
			end
			if keyHandling == "blacklist" then
				if (not beattoolsKeysBlacklist[k]) and keepChecking() then return true end
			elseif keyHandling == "whitelist" then
				if beattoolsKeysWhiteList[k] and keepChecking() then return true end
			else
				log(mods.beattools, "WARNING: INVALID KEYHANDLING " .. keyHandling)
			end
		end

		for k, v in pairs(keysRemoved) do
			if not trackChanges then return true end
			table --[[stop wrong injection]].insert(changes, { key = k, valueBefore = v })
		end

		if trackChanges then return changes end
	end

	return false
end
local function beattoolsCheckEvents(self)
	beattoolsLastCheck = beattoolsTime
	if beattoolsHasChanges(beattoolsPrevEvents, self.level.events, "array", false, "events") then
		if beattoolsHasChanges(beattoolsPrevEvents, self.level.events, "array", true, "events") and beattoolsHasChanges(beattoolsPrevEvents, self.level.events, "array", true, "events", true, false, true) then
			local temp = helpers.copy(self.level.events)
			if beattoolsPrevEvents ~= nil then
				log(mods.beattools,
					"Bad sign: Undo was forced to save all events to history, not just changes, causing much lag")
				beattoolsOverrideChanges()
				table --[[stop wrong injection]].insert(beattoolsChangeList, {
					action = "all",
					time = beattoolsTime,
					eventsBefore = helpers.copy(beattoolsPrevEvents),
					eventsAfter = temp
				})
				beattoolsChangeIndex = #beattoolsChangeList
			end
			beattoolsPrevEvents = temp
		end
	end
end
local function beattoolsPlaceEvent(...)
	local events, event = ...
	if st ~= nil and events == st.level.events then
		if mods.beattools.config.fakeRepeat and event.beattoolsRepeats ~= nil then
			return false
		end
		table --[[stop wrong injection]].insert(beattoolsPrevEvents, helpers.copy(event))
		beattoolsOverrideChanges()
		table --[[stop wrong injection]].insert(beattoolsChangeList, {
			action = "place",
			time = beattoolsTime,
			events = {
				{ event = helpers.copy(event), index = #st.level.events + 1 }
			}
		})
		beattoolsChangeIndex = #beattoolsChangeList
		if mods.beattools.config.fakeRepeat and event.beattoolsRepeatIndex ~= nil then
			event.beattoolsRepeatIndex = nil
			beattoolsUpdateRepeat(st, event)
		end
	end
	return true
end
local function beattoolsDeleteEvent(...)
	local events, i = ...
	if st ~= nil and events == st.level.events then
		for ii, v in ipairs(beattoolsPrevEvents) do
			if not beattoolsHasChanges(v, events[i], "object") then
				table --[[stop wrong injection]].remove(beattoolsPrevEvents, ii)
				break
			end
		end
		beattoolsOverrideChanges()
		table --[[stop wrong injection]].insert(beattoolsChangeList, {
			action = "delete",
			time = beattoolsTime,
			events = {
				{ event = helpers.copy(events[i]), index = i }
			}
		})
		beattoolsChangeIndex = #beattoolsChangeList
		if mods.beattools.config.fakeRepeat then
			if events[i].beattoolsRepeatIndex ~= nil then
				beattoolsRemoveRepeated(st, events[i].beattoolsRepeatIndex, i)
			elseif events[i].beattoolsRepeats ~= nil and (not beattoolsRepeatExists(st, events[i].beattoolsRepeats)) then
				beattoolsRemoveRepeated(st, events[i].beattoolsRepeats, i)
			end
		end
	end
end
local function beattoolsUndo(self, type, group)
	if (type == "undo" and beattoolsChangeIndex == 0) or (type == "redo" and beattoolsChangeIndex == #beattoolsChangeList) then
		utilitools.prompts.error(mods.beattools, "Undo failed. End of history")
		log(mods.beattools, "Undo failed. End of history")
		return nil
	end
	local lastChangeTime = nil
	beattoolsNewMultiSelection()
	self.multiselectStartBeat = nil
	self.multiselectEndBeat = nil
	while ((type == "undo" and beattoolsChangeIndex ~= 0) or (type == "redo" and beattoolsChangeIndex ~= #beattoolsChangeList)) and (lastChangeTime == nil or ((group or (beattoolsChangeIndex ~= 0 and beattoolsChangeIndex ~= #beattoolsChangeList and beattoolsChangeList[beattoolsChangeIndex].action == "place" and beattoolsChangeList[beattoolsChangeIndex + 1].action == "change")) and math.abs(lastChangeTime - beattoolsChangeList[beattoolsChangeIndex + (type == "redo" and 1 or 0)].time) < mods.beattools.config.groupTimeDifference * 60)) do -- Penta: at this point i dont even know what "dt" in the update loop is (undoTime based off of dt), maybe ill find out later? maybe its centiseconds? maybe its frames?
		if type == "redo" then beattoolsChangeIndex = beattoolsChangeIndex + 1 end
		lastChangeTime = beattoolsChangeList[beattoolsChangeIndex].time
		if beattoolsChangeList[beattoolsChangeIndex].action == "place" or beattoolsChangeList[beattoolsChangeIndex].action == "delete" then
			if (beattoolsChangeList[beattoolsChangeIndex].action == "place" and type == "undo") or (beattoolsChangeList[beattoolsChangeIndex].action == "delete" and type == "redo") then
				for i = #beattoolsChangeList[beattoolsChangeIndex].events, 1, -1 do
					local event = beattoolsChangeList[beattoolsChangeIndex].events[i]
					table --[[stop wrong injection]].remove(self.level.events, event.index)
					table --[[stop wrong injection]].remove(beattoolsPrevEvents, event.index)
				end
			else
				for i, event in ipairs(beattoolsChangeList[beattoolsChangeIndex].events) do
					local event2 = helpers.copy(event.event)
					table --[[stop wrong injection]].insert(self.level.events, event.index, event2)
					table --[[stop wrong injection]].insert(beattoolsPrevEvents, event.index, helpers.copy(event2))
					table.insert(self.multiselect.events, event2)
					self.multiselect.eventTypes[event2.type] = true
					if self.multiselectStartBeat == nil then
						self.multiselectStartBeat, self.multiselectEndBeat = event2.time, event2.time
					elseif self.multiselectStartBeat > event2.time then
						self.multiselectStartBeat = event2.time
					elseif self.multiselectEndBeat < event2.time then
						self.multiselectEndBeat = event2.time
					end
				end
			end
		elseif beattoolsChangeList[beattoolsChangeIndex].action == "change" then
			for i, changes in ipairs(beattoolsChangeList[beattoolsChangeIndex].changes) do
				for ii, change in ipairs(changes.changes) do
					self.level.events[changes.index][change.key] = type == "undo" and change.valueBefore or
						change.valueAfter
					beattoolsPrevEvents[changes.index][change.key] = type == "undo" and change.valueBefore or
						change.valueAfter
					table.insert(self.multiselect.events, self.level.events[changes.index])
					self.multiselect.eventTypes[self.level.events[changes.index].type] = true
					if self.multiselectStartBeat == nil then
						self.multiselectStartBeat, self.multiselectEndBeat = self.level.events[changes.index].time,
							self.level.events[changes.index].time
					elseif self.multiselectStartBeat > self.level.events[changes.index].time then
						self.multiselectStartBeat = self.level.events[changes.index].time
					elseif self.multiselectEndBeat < self.level.events[changes.index].time then
						self.multiselectEndBeat = self.level.events[changes.index].time
					end
				end
			end
		elseif beattoolsChangeList[beattoolsChangeIndex].action == "all" then
			self.level.events, beattoolsPrevEvents =
				helpers.copy(type == "undo" and beattoolsChangeList[beattoolsChangeIndex].eventsBefore or
					beattoolsChangeList[beattoolsChangeIndex].eventsAfter),
				helpers.copy(type == "undo" and beattoolsChangeList[beattoolsChangeIndex].eventsBefore or
					beattoolsChangeList[beattoolsChangeIndex].eventsAfter)
		else
			utilitools.prompts.error(mods.beattools, "Undo failed. Unrecognized change type")
			log(mods.beattools, "Undo failed. Unrecognized change type")
			return
		end
		if type == "undo" then beattoolsChangeIndex = beattoolsChangeIndex - 1 end
	end
	if self.multiselectStartBeat == nil then
		self.multiselectStartBeat = 0
		self.multiselectEndBeat = 360
	end
	self.p:hurtPulse()
	self:updateBiggestBeat()
end

local function beattoolsFreeIndex(step)
	step = step or 1
	local i = 0
	while beattoolsRepeatIndices[i] do
		i = i + step
	end
	return i
end
local function beattoolsMoveIndex(self, event, newIndex, events)
	if event.beattoolsRepeatIndex == nil then return end
	events = events or self.level.events
	newIndex = newIndex or beattoolsFreeIndex()
	for i, v in ipairs(events) do
		if v.beattoolsRepeats == event.beattoolsRepeatIndex then
			v.beattoolsRepeats = newIndex
		end
	end
	beattoolsRepeatIndices[newIndex] = event
	beattoolsRepeatIndices[event.beattoolsRepeatIndex] = nil
	event.beattoolsRepeatIndex = newIndex
end
beattoolsRemoveRepeated = function(self, index, deleteIndex)
	if not mods.beattools.config.fakeRepeat then return end
	local i = 1
	local tempEvents = {}
	while i <= #self.level.events do
		local v = self.level.events[i]
		if v.beattoolsRepeats == index then
			table --[[stop wrong injection]].insert(tempEvents,
				{ event = helpers.copy(v), index = i - ((deleteIndex ~= nil and deleteIndex < i and 1) or 0) })
			table --[[stop wrong injection]].remove(self.level.events, i)
			table --[[stop wrong injection]].remove(beattoolsPrevEvents,
				i - ((deleteIndex ~= nil and deleteIndex < i and 1) or 0))
			if deleteIndex ~= nil and deleteIndex >= i then deleteIndex = deleteIndex - 1 end
			i = i - 1
		end
		i = i + 1
	end
	if #tempEvents > 0 then
		beattoolsOverrideChanges()
		table --[[stop wrong injection]].insert(beattoolsChangeList, {
			action = "delete",
			time = beattoolsTime,
			events = tempEvents
		})
		beattoolsChangeIndex = #beattoolsChangeList
	end
end
beattoolsRepeatExists = function(self, index)
	for i, v in ipairs(self.level.events) do
		if v.beattoolsRepeatIndex == index then
			return true
		end
	end
	return false
end
beattoolsUpdateRepeat = function(self, event, irreversible)
	if (not mods.beattools.config.fakeRepeat) and (not irreversible) then return end
	if event.beattoolsRepeatIndex == nil then
		event.beattoolsRepeatIndex = -1
	end
	beattoolsRepeatIndices = {}

	for i, v in ipairs(self.level.events) do
		if v.beattoolsRepeatIndex ~= nil then
			if beattoolsRepeatIndices[v.beattoolsRepeatIndex] then
				log(mods.beattools, "Double repeat index " .. v.beattoolsRepeatIndex)
				v.beattoolsRepeatIndex = beattoolsFreeIndex(-1)
			end
			beattoolsRepeatIndices[v.beattoolsRepeatIndex] = v
		end
	end

	if true then
		local i = -1
		while beattoolsRepeatIndices[i] do
			if i == -1 and (not (event.repeats ~= nil and event.repeats > 0)) then
				beattoolsRepeatIndices[i] = nil
			else
				beattoolsMoveIndex(self, beattoolsRepeatIndices[i])
			end
			i = i - 1
		end
	end

	beattoolsRemoveRepeated(self, event.beattoolsRepeatIndex)
	if event.repeats ~= nil and event.repeats > 0 then
		local tempEvents = {}
		for i = 1, event.repeats do
			local newEvent = helpers.copy(event)
			if irreversible then
				newEvent.beattoolsRepeatIndex, newEvent.repeats, newEvent.repeatDelay, newEvent.time = nil, nil, nil,
					newEvent.time + i * (newEvent.repeatDelay or 1)
			else
				newEvent.beattoolsRepeatIndex, newEvent.repeats, newEvent.repeatDelay, newEvent.beattoolsRepeats, newEvent.time =
					nil, nil, nil, newEvent.beattoolsRepeatIndex, newEvent.time + i * (newEvent.repeatDelay or 1)
			end
			table --[[stop wrong injection]].insert(beattoolsPrevEvents, helpers.copy(newEvent))
			table --[[stop wrong injection]].insert(self.level.events, newEvent)
			table --[[stop wrong injection]].insert(tempEvents,
				{ event = helpers.copy(newEvent), index = #st.level.events })
		end
		beattoolsOverrideChanges()
		table --[[stop wrong injection]].insert(beattoolsChangeList, {
			action = "place",
			time = beattoolsTime,
			events = tempEvents
		})
		beattoolsChangeIndex = #beattoolsChangeList
		if irreversible then
			event.beattoolsRepeatIndex, event.repeats, event.repeatDelay = nil, nil, nil
		end
	else
		event.beattoolsRepeatIndex = nil
	end
end
local function beattoolsCheckForRepeatUpdate(self, event, key, value)
	beattoolsOverrideChanges()
	table --[[stop wrong injection]].insert(beattoolsChangeList, {
		action = "change",
		time = beattoolsTime,
		changes = {
			{
				index = beattoolsGetEventIndex(self, event),
				changes = {
					{ key = key, valueBefore = event[key], valueAfter = value }
				}
			}
		}
	})
	beattoolsChangeIndex = #beattoolsChangeList
	beattoolsPrevEvents[beattoolsGetEventIndex(self, event)][key] = value
	if mods.beattools.config.fakeRepeat and event.type ~= "ease" and event.beattoolsRepeatIndex ~= nil then
		local temp = helpers.copy(event)
		temp[key] = value
		beattoolsUpdateRepeat(self, temp)
	end
end

local function beattoolsUntag(self, tags2)
	local tags = {}
	for i, v in ipairs(tags2) do
		table --[[stop wrong injection]].insert(tags, v)
	end

	beattoolsNewMultiSelection()

	local earliest, latest, tagEvents, tagName = nil, nil, nil, ""

	local function getTagEvents(tagName2)
		if tagName ~= "" and tagName == tagName2 then return true end
		if love.filesystem.getInfo(cLevel .. "tags/" .. tagName2 .. ".json") then
			tagEvents = dpf.loadJson(cLevel .. "tags/" .. tagName2 .. ".json")
			tagName = tagName2
			return true
		else
			log(mods.beattools, "Untagging failed: Tag doesnt exist")
			utilitools.prompts.error(mods.beattools, "Untagging failed: \"" .. tagName2 .. ".json\" doesnt exist")
			return false
		end
	end

	local function untagSingleTag(currentTag)
		local temp = {}
		if getTagEvents(currentTag.tag) then
			for i, event in ipairs(helpers.copy(tagEvents)) do
				event.time = event.time + currentTag.time
				event.angle = event.angle or 0
				if currentTag.angleOffset then
					event.angle = event.angle + currentTag.angle
					if mods.beattools.config.betterUntagging then
						if event.angle2 then event.angle2 = event.angle2 + currentTag.angle end
						if event.angle2 then event.endAngle = event.endAngle + currentTag.angle end
					end
				end
				table.insert(self.level.events, event)
				if self.multiselect == nil then
					log(mods.beattools, "Multiselect nil - What? " .. i .. " " .. currentTag.tag)
				end
				table.insert(self.multiselect.events, event)
				self.multiselect.eventTypes[event.type] = true

				if earliest == nil then
					earliest, latest = event.time, event.time
				end
				if earliest > event.time then earliest = event.time end
				if latest < event.time then latest = event.time end
			end
			table.remove(self.level.events, beattoolsGetEventIndex(self, currentTag))
			return false
		end
		return true
	end

	if #tags == 1 then
		local tag = tags[1]
		if type(tag) == "string" then
			local i = 0
			while i < #self.level.events do
				i = i + 1
				local event = self.level.events[i]
				if event.type == "tag" and event.tag == tag then
					i = i - 1
					if untagSingleTag(event) then return end
				end
			end
		elseif tag.type == "tag" then
			untagSingleTag(tag)
		end
	else
		if type(tags[1]) == "string" then
			for ii, vv in ipairs(tags) do
				local i = 0
				while i < #self.level.events do
					i = i + 1
					local event = self.level.events[i]
					if event.type == "tag" and event.tag == vv then
						i = i - 1
						if untagSingleTag(event) then return end
					end
				end
			end
		else
			for i, v in ipairs(tags) do
				if v.type == "tag" then
					untagSingleTag(v)
				end
			end
		end
	end

	self.multiselectStartBeat = earliest
	self.multiselectEndBeat = latest
	self.p:hurtPulse()
	self:updateBiggestBeat()
	self.unsavedChanges = true
end

local function moveMultiselection(self, time, angle)
	self.unsavedChanges = true
	for i, event in ipairs(self.multiselect.events) do
		event.time = event.time + time
		event.angle = event.angle + angle
		if event.angle2 then event.angle2 = event.angle2 + angle end
		if mods.beattools.config.betterMoveSelection and event.endAngle then event.endAngle = event.endAngle + angle end
	end
	self.multiselectStartBeat, self.multiselectEndBeat = self.multiselectStartBeat + time,
		self.multiselectEndBeat + time
	self:updateBiggestBeat()
end

local function beattoolsSameEasing(event, selected)
	if not (mods.beattools.config.markSameEasing and selected and event ~= selected and event.type == selected.type) then return false end
	local paramForType = { ease = "var", setColor = "color", deco = "id" }
	if paramForType[event.type] == nil then return false end
	return event[paramForType[event.type]] == selected[paramForType[event.type]]
end
local function beattoolsUpdateEventGroups()
	st.selectedEvent = nil
	st.multiselect = nil

	st.multiselectStartBeat = nil
	st.multiselectEndBeat = nil
	st.multiselectStartAngle = nil
	st.multiselectEndAngle = nil

	beattoolsEventGroups = {}
	beattoolsEventIndices = {}
	beattoolsHighestEventGroupIndex = 1
	beattoolsEventVisibilities = {}
	local function processEventGroup(k, v)
		local temp = v
		temp.name = k

		local textLength = imgui.GetFontSize() * 7 / 13 * temp.name:len()
		if beattoolsEventGroupLongest < textLength then beattoolsEventGroupLongest = textLength end

		if beattoolsHighestEventGroupIndex < temp.index then beattoolsHighestEventGroupIndex = temp.index end

		if beattoolsEventIndices[temp.index] == nil then beattoolsEventIndices[temp.index] = { events = {}, groups = 0 } end
		beattoolsEventIndices[temp.index].groups = beattoolsEventIndices[temp.index].groups + 1
		for kk, vv in pairs(temp.events) do
			beattoolsEventIndices[temp.index].events[kk] = true
		end

		if #beattoolsEventGroups == 0 then
			table --[[stop wrong injection]].insert(beattoolsEventGroups, temp)
		else
			local inserted = false
			for i, vv in ipairs(beattoolsEventGroups) do
				if not (temp.index > vv.index or (temp.index == vv.index and temp.name > vv.name)) then
					table --[[stop wrong injection]].insert(beattoolsEventGroups, i, temp)
					inserted = true
					break
				end
			end
			if not inserted then table --[[stop wrong injection]].insert(beattoolsEventGroups, temp) end
		end
	end
	for k, v in pairs(st.level.properties.beattools.eventGroups) do
		processEventGroup(k, v)
	end
	if st.level.properties.beattools.customEventGroups then
		for k, v in pairs(st.level.properties.beattools.customEventGroups) do
			processEventGroup(k, v)
		end
	end

	st:updateBiggestBeat()
end
local function beattoolsMakeSpace(index, reverse)
	if type(reverse) ~= "number" then reverse = reverse and -1 or 1 end
	for k, v in pairs(st.level.properties.beattools.eventGroups) do
		if v.index >= index then
			v.index = v.index + reverse
		end
	end
	if st.level.properties.beattools.customEventGroups then
		for k, v in pairs(st.level.properties.beattools.customEventGroups) do
			if v.index >= index then
				v.index = v.index + reverse
			end
		end
	end
end

local function beattoolsCtrlSelect(event)
	if not mods.beattools.config.ctrlSelect then return end
	st.ctrlSelectPending = false
	st.deletePending = false
	local function addToMulti(event2)
		table --[[stop wrong injection]].insert(st.multiselect.events, event2)
		st.multiselect.eventTypes[event2.type] = true
		if st.multiselectStartBeat > event2.time then
			st.multiselectStartBeat = event2.time
		end
		if st.multiselectEndBeat < event2.time then
			st.multiselectEndBeat = event2.time
		end
	end
	if st.multiselect then
		local remove
		for i, v in ipairs(st.multiselect.events) do
			if v == event then
				remove = i
				break
			end
		end
		if remove then
			table --[[stop wrong injection]].remove(st.multiselect.events, remove)

			local typeExists
			local checkStart = event.time == st.multiselectStartBeat and st.multiselectEndBeat
			local checkEnd = event.time == st.multiselectEndBeat and st.multiselectStartBeat

			for i, v in ipairs(st.multiselect.events) do
				if not typeExists and v.type == event.type then typeExists = true end
				if checkStart or checkEnd then
					if v.time == event.time then
						checkStart = false
						checkEnd = false
					end
					if checkStart and v.time < checkStart then checkStart = v.time end
					if checkEnd and v.time > checkEnd then checkEnd = v.time end
				end
				if typeExists and not checkStart and not checkEnd then
					break
				end
			end
			if not typeExists then st.multiselect.eventTypes[event.type] = nil end
			if checkStart then st.multiselectStartBeat = checkStart end
			if checkEnd then st.multiselectEndBeat = checkEnd end
		else
			addToMulti(event)
		end
	else
		beattoolsNewMultiSelection()
		st.multiselectStartBeat = event.time
		st.multiselectEndBeat = event.time
		addToMulti(event)
		if st.lastSelected then
			for i, v in ipairs(st.level.events) do
				if v == st.lastSelected then
					addToMulti(st.lastSelected)
					break
				end
			end
		end
	end
end