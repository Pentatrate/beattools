local st = Gamestate:new('Editor') -- Penta: This comment is neccessary

utilitools.files.beattools.undo.init()

local beattoolsTime = 0
local beattoolsEditorBeat = 0
local beattoolsSelect
local beattoolsPrevSelect
beattoolsAngleSnap = 4

local beattoolsOverlap = {}  -- event stacking

local beattoolsStartBeat  -- restart in playtest

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
	table.insert(beattoolsAllEasesSorted, k)
	if type(v) == "boolean" then
		table.insert(beattoolsOnlyBooleans, k)
	else
		table.insert(beattoolsOnlyEases, k)
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
		table.insert(params, "time")
		table.insert(params, "order")
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
				table.insert(beattoolsEasings[type][sub][subsub], value)
			else
				table.insert(beattoolsEasings[type][sub], value)
			end
		else
			table.insert(beattoolsEasings[type], value)
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

local function beattoolsUntag(self, tags2)
	local tags = {}
	for i, v in ipairs(tags2) do
		table.insert(tags, v)
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
			table.insert(beattoolsEventGroups, temp)
		else
			local inserted = false
			for i, vv in ipairs(beattoolsEventGroups) do
				if not (temp.index > vv.index or (temp.index == vv.index and temp.name > vv.name)) then
					table.insert(beattoolsEventGroups, i, temp)
					inserted = true
					break
				end
			end
			if not inserted then table.insert(beattoolsEventGroups, temp) end
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

st.beattoolsCtrlSelect = function(event, force)
	if not mods.beattools.config.ctrlSelect and not force then return end
	st.ctrlSelectPending = false
	st.deletePending = false
	local function addToMulti(event2)
		table.insert(st.multiselect.events, event2)
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
			table.remove(st.multiselect.events, remove)

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