local editorKeysWindow = {}

function editorKeysWindow.imgui(text)
	local splits = { { type = "text", text = text } }
	local function split(pattern, category, keyId, replaceText)
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
							table.insert(splits, i2 + 1, { type = "key", label = prevText:sub(patternEnd + 1, labelEnd - 1), category = category, key = keyId })
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
	split("Esc", "keyboardMenu", "back")
	split("S", "keyboardEditor", "save")
	split("P", "keyboardEditor", "play")
	split("Ctrl + P", nil, nil, utilitools.keybinds.generateText("keyboardEditor", "modifier", false, true) .. " + " .. utilitools.keybinds.generateText("keyboardEditor", "play", false, true))
	split("Ctrl + LMB", nil, nil, (mod.config.ctrlSelect and "C" or utilitools.keybinds.generateText("keyboardEditor", "modifier", false, true)) .. " + LMB")
	for i, part in ipairs(splits) do
		if part.type == "text" then
			imgui.Text(part.text)
		elseif part.type == "key" then
			utilitools.imguiHelpers.inputKey(part.label, part.category, part.key, utilitools.keybinds.generateText(part.category, part.key, false), false)
		end
	end
end

return editorKeysWindow