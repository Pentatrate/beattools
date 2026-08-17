local textChart = {
	string = "",
	head = { time = 0, angle = 0, note = "block" },
	index = 1,

	mines = { mine = true, mineHold = true },

	isHalved = false,
	isTriplet = false,
	isLiteral = false,
	isForced = false,
	tap = false,
	endTap = false,
	holdDistance = 0,
	holdDuration = 1,
	holdEase = nil,
	bounceCount = 1,
	bookmark = "",

	direction = 1,
	nextDirection = 1,

	beatStep = 0,
	angleStep = 0,
	lastAngle = 0,
	lastAngleStep = 0,

	log = "",
	result = nil,

	headers = {
		name = "",
		artist = "",
		charter = ""
	}
}

function textChart.err(...)
	local t = {...}
	table.insert(t, "found")
	table.insert(t, textChart.readChar())
	textChart.index = textChart.index - 1
	table.insert(t, "at index")
	table.insert(t, textChart.index)
	if textChart.log ~= "" then modwarn(mod, "second error", unpack(t)) return false end
	textChart.log = debug.traceback(utilitools.string.concat(unpack(t)))
	return false
end

function textChart.readChar()
	local char = textChart.string:sub(textChart.index, textChart.index)
	textChart.index = textChart.index + 1
	return char
end

function textChart.isEnd()
	local char = textChart.readChar()
	textChart.index = textChart.index - 1
	return not char or char == ""
end

function textChart.potential(char)
	textChart.skipEmpty()
	local char2 = textChart.readChar()
	if char2 ~= char then
		textChart.index = textChart.index - 1 return nil, char
	end
	return true, char
end

function textChart.expect(char)
	local found, char2 =  textChart.potential(char)
	if not found then
		return textChart.err("expected", char, "found", char2), char2
	end
	return found or false, char2
end

function textChart.multiPotential(t, expect)
	textChart.skipEmpty()
	local char = textChart.readChar()
	if not (not char or char == "") and t[char] then
		local result = t[char]()
		if not result then textChart.index = textChart.index - 1 end
		return result, char
	end
	textChart.index = textChart.index - 1
	if expect then
		return textChart.err("expected", utilitools.table.keysToValues(t), "found", char), char
	end
	return nil, char
end

function textChart.skipEmpty()
	local char = textChart.readChar()
	local skipped = false
	while ({ [" "] = true, ["\n"] = true })[char] do
		skipped = true
		char = textChart.readChar()
	end
	textChart.index = textChart.index - 1
	return skipped
end

function textChart.readDigit(char)
	local digit = char or textChart.readChar()
	if digit:find("[%d]") then return tonumber(digit), digit end
	if char then return nil, digit end
	textChart.index = textChart.index - 1
	return nil, digit
end

function textChart.readNumber()
	textChart.skipEmpty()
	local number = 0
	local digit, char = textChart.readDigit()
	local digits = 0
	local decimalMode = false
	local decimals = 0
	while digit or (not decimalMode and char == ".") do
		if char == "." then
			decimalMode = true
			textChart.index = textChart.index + 1
		else
			if decimalMode then decimals = decimals + 1 end
			digits = digits + 1
			number = number * 10 + digit
		end
		digit, char = textChart.readDigit()
	end
	if digits > 0 then return number / math.pow(10, decimals), char end
	return textChart.err("expected number", "found", char, digits, decimalMode, char == "."), char
end

function textChart.readText()
	textChart.skipEmpty()
	local string = ""
	local char = textChart.readChar()
	while char:find("[%u%l]") do
		string = string .. char
		char = textChart.readChar()
	end
	textChart.index = textChart.index - 1
	return string
end

function textChart.readHeader(last, bookmark)
	textChart.skipEmpty()
	local string = ""
	local char = textChart.readChar()
	local tillChar = ","
	if last then tillChar = "|" end
	if bookmark then tillChar = "*" end
	while char ~= tillChar do
		if not char or char == "" then break end
		string = string .. char
		char = textChart.readChar()
	end
	return string:gsub("\n+", "")
end

function textChart.readSnap()
	local number = textChart.readNumber()
	if not number then return false end
	textChart.angleStep = 360 / number

	if not textChart.expect(",") then return false end

	number = textChart.readNumber()
	if not number then return false end
	textChart.beatStep = 1 / number

	return textChart.expect("|")
end

function textChart.readPrefix(sameTime)
	local action = {
		["\""] = function()
			if textChart.isLiteral then
				return textChart.err("already in literal mode")
			end
			textChart.isLiteral = true
			return true -- repeat
		end,
		v = function()
			if sameTime then
				return textChart.err("no time")
			end
			if textChart.isHalved or textChart.isTriple then return end -- accept
			textChart.isHalved = true
			return true -- repeat
		end,
		q = function()
			if sameTime then
				return textChart.err("no time")
			end
			if textChart.isHalved or textChart.isTriple then return end -- accept
			textChart.isTriple = true
			return true -- repeat
		end
	}
	return textChart.multiPotential(action)
end

function textChart.readHold(isBounce)
	if not textChart.potential("[") then return true end -- no hold data, accept
	if textChart.potential("]") then return true end -- empty hold data, accept

	local isNegative = 1
	if textChart.potential("-") then isNegative = -1 end -- negative number

	local number = textChart.readNumber()
	if not number then return false end -- expect number for distance
	textChart.holdDistance = number * isNegative

	if textChart.potential("]") then return true end -- only distance, accept
	if not textChart.expect(",") then return false end

	number = textChart.readNumber()
	if not number then return false end -- expect number for duration
	textChart.holdDuration = number

	if textChart.potential("]") then return true end -- only distance and duration, accept
	if not textChart.expect(",") then return false end

	if isBounce then
		number = textChart.readNumber()
		if not number then return false end -- expect number for bounce count
		textChart.bounceCount = number
	else
		textChart.skipEmpty()
		local eases = {
			IS = "inSine", OS = "outSine", IOS = "inOutSine",
			IQ = "inQuad", OQ = "outQuad", IOQ = "inOutQuad",
			IC = "inCubic", OC = "outCubic", IOC = "inOutCubic"
		}
		local ease = textChart.readText()
		if ease == "" or ((not eases[ease:upper()] or not flux.easing[eases[ease:upper()] or ""]) and not flux.easing[ease]) then return textChart.err("expected", "ease", "found", ease) end -- expect ease
		textChart.holdEase = eases[ease:upper()] or ease
	end

	return textChart.expect("]")
end

function textChart.readSuffix(sameTime)
	local action = {
		["\""] = function()
			if not textChart.isLiteral then return end -- accept
			textChart.isLiteral = false
			return true -- repeat
		end,
		I = function()
			if textChart.head.note ~= "block" then
				return textChart.err("already in not a block")
			end
			textChart.head.note = "inverse"
			return true -- repeat
		end,
		S = function()
			if textChart.head.note ~= "block" then
				return textChart.err("already in not a block")
			end
			textChart.head.note = "side"
			return true -- repeat
		end,
		M = function()
			if textChart.head.note ~= "block" then
				return textChart.err("already in not a block")
			end
			textChart.head.note = "mine"
			return true -- repeat
		end,
		H = function()
			if textChart.head.note ~= "block" then
				return textChart.err("already in not a block")
			end
			textChart.head.note = "hold"
			return textChart.readHold()
		end,
		W = function()
			if textChart.head.note ~= "block" then
				return textChart.err("already in not a block")
			end
			textChart.head.note = "mineHold"
			return textChart.readHold()
		end,
		B = function()
			if textChart.head.note ~= "block" then
				return textChart.err("already in not a block")
			end
			textChart.head.note = "bounce"
			return textChart.readHold(true)
		end,
		F = function()
			if sameTime then
				return textChart.err("no time")
			end
			if textChart.head.note ~= "block" then
				return textChart.err("already in not a block")
			end
			textChart.head.note = "fake"
			return true -- repeat
		end,
		["("] = function()
			if textChart.isForced then
				return textChart.err("already in isForced mode")
			end

			local mode = 0
			local action2 = {
				["+"] = function() mode = 1 return true end,
				["-"] = function() mode = -1 return true end
			}
			if textChart.multiPotential(action2) == false then return false end

			local number = textChart.readNumber()
			if not number then return false end -- error
			if mode == 0 then
				textChart.head.angle = number * textChart.angleStep
			else
				textChart.head.angle = textChart.lastAngle + number * textChart.angleStep * mode
			end

			action2 = {
				[")"] = function() return true end,
				["+"] = function()
					textChart.direction = 1
					textChart.nextDirection = 1
					return textChart.expect(")")
				end,
				["-"] = function()
					textChart.direction = -1
					textChart.nextDirection = -1
					return textChart.expect(")")
				end
			}
			textChart.isForced = true
			return textChart.multiPotential(action2, true)
		end,
		h = function()
			if textChart.tap and textChart.endTap then
				return textChart.err("limit of taps reached")
			end
			if textChart.tap then
				textChart.tap = false
				textChart.endTap = true
			else textChart.tap = true end
			return true -- repeat
		end,
		t = function()
			if sameTime then
				return textChart.err("no time")
			end
			textChart.nextDirection = -textChart.direction
			return true -- repeat
		end,
		["&"] = function() return true end -- dummy for compatibility
	}
	return textChart.multiPotential(action)
end

function textChart.resetTemp()
	textChart.head.note = "block"
	textChart.isHalved = false
	textChart.isTriple = false
	textChart.isForced = false
	textChart.tap = false
	textChart.endTap = false
	textChart.holdDistance = 0
	textChart.holdDuration = 1
	textChart.holdEase = nil
	textChart.bounceCount = 1
	textChart.bookmark = ""
end

function textChart.readData(sameTime)
	local direction
	local angleStep
	local replaceNumber = false
	local rememberStep = false
	local dontMove = false

	if sameTime then
		local action = {
			["+"] = function() direction = 1 return true end,
			["-"] = function() direction = -1 return true end
		}
		local result = textChart.multiPotential(action)
		if not result then return result end
	end
	if textChart.isEnd() then return end -- stop
	if textChart.potential("|") then
		if sameTime then
			return textChart.err("no time")
		end
		textChart.resetTemp()
		return textChart.readSnap() -- expect snap data
	end

	local repeats = textChart.readPrefix(sameTime)
	if repeats == false then return false end -- error
	while repeats do repeats = textChart.readPrefix(sameTime) if repeats == false then return false end end

	if textChart.isHalved or textChart.isTriple then
		if textChart.isHalved then
			textChart.head.time = textChart.head.time - textChart.beatStep / 2
			textChart.head.angle = textChart.lastAngle + textChart.lastAngleStep / 2
		else
			textChart.head.time = textChart.head.time - textChart.beatStep * 2 / 3
			textChart.head.angle = textChart.lastAngle + textChart.lastAngleStep / 3
		end
	end

	local action = {
		["*"] = function()
			if sameTime then
				return textChart.err("no time")
			end
			if textChart.isLiteral then
				return textChart.err("in literal mode")
			end
			dontMove = true
			textChart.bookmark = textChart.readHeader(nil, true)
			textChart.head.note = "bookmark"
			return true
		end,
		["#"] = function()
			if sameTime then
				return textChart.err("no time")
			end
			if textChart.isLiteral then
				return textChart.err("in literal mode")
			end
			replaceNumber = true
			textChart.head.note = "fake"
			return true
		end,
		E = function()
			if textChart.isLiteral then
				return textChart.err("in literal mode")
			end
			replaceNumber = true
			textChart.head.note = "extraTap"
			return true
		end
	}
	local result = textChart.multiPotential(action)
	if result == false then return result end
	if not result then
		if textChart.isLiteral then
			angleStep = textChart.readNumber()
		else
			textChart.skipEmpty()
			angleStep, char = textChart.readDigit()
		end
		if not angleStep then
			if textChart.isHalved or textChart.isTriple then
				replaceNumber = true
				textChart.head.note = "fake"
				rememberStep = true
			else
				if not textChart.isLiteral then return textChart.err("expected digit") end
				return false
			end
		else
			repeats = textChart.readSuffix(sameTime)
			while repeats do repeats = textChart.readSuffix(sameTime) if repeats == false then return false end end
		end
	end

	if textChart.mines[textChart.head.note] and textChart.tap then
		return textChart.err("type mine has tap")
	end
	if textChart.head.note == "fake" and textChart.tap then
		return textChart.err("fake has tap")
	end
	if textChart.head.note ~= "hold" and textChart.endTap then
		return textChart.err("end tap but no hold")
	end
	if textChart.head.note ~= "fake" then
		local isHold = utilitools.files.beattools.eventVisuals.holds[textChart.head.note]
		local isBounce = textChart.head.note == "bounce"
		local isExtraTap = textChart.head.note == "extraTap"
		local isBookmark = textChart.head.note == "bookmark"
		local angle = 0
		if not isExtraTap and not isBookmark then
			angle = textChart.head.angle
			if sameTime then
				angle = angle + (sameTime and angleStep * textChart.angleStep * textChart.direction * direction or 0)
			end
			angle = angle % 360
		end
		local event = {
			type = textChart.head.note,
			time = textChart.head.time,
			angle = angle,
			tap = isHold and nil or textChart.tap or nil,

			startTap = isHold and textChart.tap or nil,
			endTap = isHold and textChart.endTap or nil,
			angle2 = isHold and angle + textChart.holdDistance * textChart.angleStep * textChart.direction or nil,
			duration = isHold and textChart.holdDuration * textChart.beatStep or nil,
			holdEase = isHold and textChart.holdEase or nil,

			bounces = isBounce and textChart.bounceCount or nil,
			rotation = isBounce and textChart.holdDistance * textChart.angleStep * textChart.direction or nil,
			delay = isBounce and textChart.holdDuration * textChart.beatStep or nil,

			name = isBookmark and textChart.bookmark or nil,
			r = isBookmark and 0 or nil,
			g = isBookmark and 0 or nil,
			b = isBookmark and 0 or nil
		}
		table.insert(cs.level.events, event)
	end

	textChart.resetTemp()

	if (replaceNumber or dontMove) and not sameTime then
		if not dontMove then textChart.head.time = textChart.head.time + textChart.beatStep end
		if rememberStep then
			textChart.lastAngle = textChart.head.angle
			textChart.head.angle = textChart.head.angle + textChart.lastAngleStep
		end
		return true
	end

	if sameTime then return true end

	repeats = textChart.readData(true)
	while repeats do repeats = textChart.readData(true) if repeats == false then return false end end

	textChart.head.time = textChart.head.time + textChart.beatStep

	textChart.direction = textChart.nextDirection
	textChart.lastAngle = textChart.head.angle
	textChart.lastAngleStep = angleStep * textChart.angleStep * textChart.direction
	textChart.head.angle = textChart.head.angle + textChart.lastAngleStep
	return true
end

function textChart.read(s)
	local function real()
		textChart.log = ""
		textChart.result = nil
		textChart.index = 1

		if not cs or cs.name ~= "Editor" or not cs.editMode or not cs.level or not cs.level.events then
			return textChart.err("Not in Editor")
		end

		textChart.string = s
		textChart.head.time = 0
		textChart.head.angle = 0

		textChart.resetTemp()

		textChart.isLiteral = false

		textChart.direction = 1
		textChart.nextDirection = 1

		textChart.headers.name = textChart.readHeader()
		textChart.headers.artist = textChart.readHeader()
		textChart.headers.charter = textChart.readHeader(true)

		if not textChart.readSnap() then return false end -- expect snap data
		textChart.lastAngleStep = 0
		textChart.lastAngle = 0

		local repeats = textChart.readData()
		while repeats do repeats = textChart.readData() if repeats == false then return false end end
	end
	textChart.result = real()
end

function textChart.imgui()
	imgui.Text("Text 2 Chart")
	textChart.string = utilitools.imguiHelpers.inputMultiline("##textChartInput", textChart.string, "")
	textChart.string = utilitools.files.beattools.imguiPopOut.imgui("##textChartInput", textChart.string, true)
	if imgui.Button("Run Parser") then textChart.read(textChart.string) end
	if imgui.Button("Quick Clipboard") then textChart.read("-,-,-|24,2|" .. tostring(love.system.getClipboardText())) end
	if textChart.result == false then imgui.TextWrapped("Error: " .. tostring(textChart.log)) end
end

return textChart