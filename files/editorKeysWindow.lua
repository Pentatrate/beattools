local editorKeysWindow = {}

function editorKeysWindow.imgui(text)
	local splits = { { type = "text", text = text } }
	local function replace(id, pattern, replaceText)
		-- for some reason gsub doesnt work??? im confungled
		local matchStart, matchEnd = splits[1].text:find(pattern, 1, true)
		if matchStart then
			splits[1].text = splits[1].text:sub(1, matchStart - 1) .. replaceText .. splits[1].text:sub(matchEnd + 1)
		else
			splits[1].text = "REPLACING FAILED: " .. id .. "\n" .. splits[1].text
		end
	end
	local function split(pattern, category, keyId, modded, replaceText)
		local fullPattern = "\n" .. pattern .. " - "
		local i = 1
		while splits[i] do
			local part = splits[i]
			if part and part.type == "text" then
				local prevText = part.text
				local patternStart, patternEnd = 1, #fullPattern - 1
				local patternBegins = true
				if prevText:sub(patternStart, patternEnd) ~= fullPattern:sub(2) then
					patternBegins = false
					patternStart, patternEnd = prevText:find(fullPattern, 1, true)
				end
				if patternStart then
					if replaceText then
						if patternBegins then
							part.text = ""
						else
							part.text = prevText:sub(1, patternStart)
						end
						part.text = part.text .. replaceText .. prevText:sub(patternEnd - 2)
					else
						local i2 = i
						if patternBegins then
							table.remove(splits, i2)
							i2 = i2 - 1
						else
							part.text = prevText:sub(1, patternStart)
						end
						local labelEnd = prevText:find("\n", patternEnd + 1, true)
						if labelEnd then
							table.insert(splits, i2 + 1, { type = "key", label = prevText:sub(patternEnd + 1, labelEnd - 1), category = category, key = keyId, modded = modded })
							if prevText:sub(labelEnd + 1) ~= "" then
								table.insert(splits, i2 + 2, { type = "text", text = prevText:sub(labelEnd + 1) })
							end
						else
							part.text = part.text .. "\n--"
							table.insert(splits, i2 + 1, { type = "key", label = prevText:sub(patternEnd + 1), category = category, key = keyId })
						end
					end
				end
			end
			i = i + 1
		end
	end
	-- replacing text
	replace("jump to next/previous section", "\nAlt + Left/Right - Jump to next/previous section\n", "\nAlt + Left - Jump to previous section\nAlt + Right - Jump to next section\n")
	replace("ctrl click", "\nAlt + LMB + drag - Multi select events (alternate)\n  Selects events only in the highlighted area\n", "\nAlt + LMB + drag - Multi select events (alternate)\n  Selects events only in the highlighted area\nCtrl (modded) -  + LMB on an event - Ctrl select events\n  Add/remove events to/from the selection one by one\n")

	-- inserting keybind text
	split("Ctrl + LMB", nil, nil, nil, (mod.config.ctrlSelect and utilitools.keybinds.text.generate("controltable", "c", false, true) or utilitools.keybinds.text.generate("keyboardEditor", "modifier", false, true)) .. " + LMB on an event")

	-- inserting modded keybinds
	split("Ctrl (modded)", mods.beattools, "ctrlSelectKey", true)

	-- inserting editor keybinds
	split("Esc", "keyboardMenu", "back", false)
	split("S", "keyboardEditor", "save", false)

	split("P", "keyboardEditor", "play", false)
	split("Shift + P", nil, nil, nil, utilitools.keybinds.text.generate("controltable", "shift", false, true) .. " + " .. utilitools.keybinds.text.generate("keyboardEditor", "play", false, true))
	split("Ctrl + P", nil, nil, nil, utilitools.keybinds.text.generate("controltable", "ctrl", false, true) .. " + " .. utilitools.keybinds.text.generate("keyboardEditor", "play", false, true))

	-- inserting custom editor keybinds
	split("F", mods.beattools, "editorKeybind jump to event position", true)
	split("Ctrl + R", mods.beattools, "editorKeybind reset window positions", true)

	split("Shift + ]", mods.beattools, "editorKeybind speedmod UP", true)
	split("Shift + [", mods.beattools, "editorKeybind speedmod DOWN", true)

	-- inserting hard coded editor keybinds
	split("Hold Alt", mods.beattools, "hardCodedEditorKeybind show navigation wheel", true)
	split("Alt + Left", mods.beattools, "hardCodedEditorKeybind jump to previous section", true)
	split("Alt + Right", mods.beattools, "hardCodedEditorKeybind jump to next section", true)

	for i, part in ipairs(splits) do
		if part.type == "text" then
			imgui.Text(part.text)
		elseif part.type == "key" then
			utilitools.imguiHelpers.inputKey(part.label, part.category, part.key, utilitools.keybinds.text.generate(part.category, part.key, part.modded, false), part.modded)
		end
	end
end

function editorKeysWindow.reroute(keybindName, func)
end

return editorKeysWindow