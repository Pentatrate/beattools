local configHelpers = utilitools.configHelpers
configHelpers.setMod(mod)

if imgui.BeginTabBar("beattoolsConfig") then
	if imgui.BeginTabItem("General##beattoolsConfig") then
		configHelpers.treeNode("Menu Options", function()
			configHelpers.doc("general_menuOptions")
			configHelpers.presets.menuOptions()
			imgui.Separator()
			configHelpers.presets.menuButtons()
			imgui.Separator()
			configHelpers.presets.updateOptions()
		end, 2 ^ 5)
		configHelpers.treeNode("Advanced", function()
			configHelpers.doc("general_advanced")
			configHelpers.input("speedScrolling")
			imgui.Separator()
			configHelpers.input("scanMargin")
			imgui.Separator()
			configHelpers.input("keyHandling")
			imgui.Separator()
			configHelpers.input("randomizeWindows")
			configHelpers.input("imguiGuide")
			if imgui.Button("Style Manager##beattools") then
				local imguiStyleManager = utilitools.files.beattools.imguiStyle
				utilitools.prompts.custom({
					title = "Style Manager", message = "Choose an action.",
					buttonsTable = {
						{ "Apply style", function() utilitools.prompts.custom({
							title = "Style Manager > Apply", message = "Choose style",
							func = function()
								for _, v in ipairs(imguiStyleManager.allSavedStyles) do
									if imgui.Button(v .. "##beattoolsChooseStyle") then
										imguiStyleManager.applyStyle(v)
									end
								end
							end
						}) end },
						{ "New Style", function() utilitools.prompts.custom({
							title = "Style Manager > New", message = "Choose creation method",
							buttonsTable = {
								{ "Save current style", function()
									imguiStyleManager.promptStyleName(imguiStyleManager.saveStyle)
								end },
								{ "Import from clipboard", function()
									utilitools.prompts.custom({
										title = "Style Manager > Import",
										message = "Choose import format",
										buttonsTable = {
											{ "Beattools Format", function() utilitools.try(mod, function()
												local jsonData = json.decode(love.system.getClipboardText())
												if ({ [""] = true, default = true, ["from old format"] = true })[jsonData.name] then
													jsonData = "default"
												end
												if mods.beattools.config.imguiStyles[jsonData.name] ~= nil then
													imguiStyleManager.promptStyleName(function(styleName)
														jsonData.name = styleName
														mods.beattools.config.imguiStyles[jsonData.name] = jsonData
														modlog(mod, "Imported beattools format " .. tostring(jsonData.name))
													end)
												else
													mods.beattools.config.imguiStyles[jsonData.name] = jsonData
													modlog(mod, "Imported beattools format " .. tostring(jsonData.name))
												end
											end) end },
											{ "ImGui Colors Format", imguiStyleManager.promptStyleName(imguiStyleManager.imguiColorsFormat) }
										}
									})
								end }
							}
						}) end },
						{ "Remove style", function() utilitools.prompts.custom({
							title = "Style Manager > Remove", message = "Choose style",
							func = function()
								for _, v in ipairs(imguiStyleManager.allSavedStyles) do
									if v ~= "default" and imgui.Button(v .. "##beattoolsChooseStyle") then
										imguiStyleManager.removeStyle(v)
									end
								end
							end
						}) end },
						{ "Rename style", function() utilitools.prompts.custom({
							title = "Style Manager > Rename", message = "Choose style",
							func = function()
								for _, v in ipairs(imguiStyleManager.allSavedStyles) do
									if v ~= "default" and imgui.Button(v .. "##beattoolsChooseStyle") then
										imguiStyleManager.promptStyleName(function(styleName)
											mod.config.imguiStyles[styleName] = mod.config.imguiStyles[v]
											mod.config.imguiStyles[v] = nil
											mod.config.imguiStyles[styleName].name = styleName

											if v == mod.config.currentImguiStyle then mod.config.currentImguiStyle = styleName end
											imguiStyleManager.updateAllSavedStyles()
										end)
									end
								end
							end
						}) end },
						{ "Export style", function() utilitools.prompts.custom({
							title = "Style Manager > Export", message = "Choose style",
							func = function()
								for _, v in ipairs(imguiStyleManager.allSavedStyles) do
									if v ~= "default" and imgui.Button(v .. "##beattoolsChooseStyle") then
										local text = json.encode(mod.config.imguiStyles[v], function(a, b) return a < b end)
										modlog(mods.beattools, "Copied to clipboard: " .. text)
										love.system.setClipboardText(text)
									end
								end
							end
						}) end }
					}
				})
			end
			imgui.Separator()
			configHelpers.input("testKey")
			configHelpers.input("testKey2")
			configHelpers.input("testKey3")
		end)
		configHelpers.condTreeNode("Full Mod Description", "documentation", "none", false, function()
			configHelpers.doc("general_fullDescription")
		end)
		configHelpers.condTreeNode("ImGui User Guide", "documentation", "long", true, function()
			imgui.ShowUserGuide()
		end)
		imgui.EndTabItem("General##beattoolsConfig")
	end
	if imgui.BeginTabItem("Game##beattoolsConfig") then
		configHelpers.treeNode("Visuals", function()
			configHelpers.doc("game_visuals")
			configHelpers.input("customLevelVisuals")
			configHelpers.condTreeNode("Colors", "customLevelVisuals", true, true, function()
				configHelpers.input("customWhiteColor")
				configHelpers.input("customBlackColor")
			end)
			imgui.Separator()
			configHelpers.input("accBar")
			configHelpers.condTreeNode("Bar Visuals", "accBar", true, true, function()
				configHelpers.input("accBarWidth")
				configHelpers.input("accBarSide")
				configHelpers.input("accBarReverse")
				configHelpers.input("accBarColors")
				configHelpers.input("accBarSmooth")
			end)
		end)
		configHelpers.treeNode("Features", function()
			configHelpers.doc("game_features")
			configHelpers.input("lagBack")
			configHelpers.condTreeNode("Lag Back Options", "lagBack", true, true, function()
				configHelpers.input("lagThreshhold")
				configHelpers.input("lagOffset")
				configHelpers.input("lagUseSeconds")
			end)
		end)
		imgui.EndTabItem("Game##beattoolsConfig")
	end
	if imgui.BeginTabItem("Level Select##beattoolsConfig") then
		configHelpers.treeNode("Visuals", function()
			configHelpers.doc("levelSelect_visuals")
			configHelpers.input("levelSelectMultiplyBpm")
			imgui.BeginDisabled()
			configHelpers.input("levelSelectShowIncompatible")
			imgui.EndDisabled()
		end)
		configHelpers.treeNode("Features", function()
			configHelpers.doc("levelSelect_features")
			configHelpers.input("ignoreLoopPoints")
			configHelpers.input("rateModLimits")
			imgui.Separator()
			imgui.BeginDisabled() configHelpers.input("levelSelectDynamicLoading") imgui.EndDisabled()
			imgui.Separator()
			if imgui.Button("Scan Duplicates") then
				utilitools.prompts.confirm(
					"You will scan all custom levels for duplicate level folder names\nThe results will be printed in the console",
					function()
						local levels = {}
						local function scanDuplicates(path)
							local content = love.filesystem.getDirectoryItems(path)
							for i, v in ipairs(content) do
								if love.filesystem.getInfo(path .. "/" .. v .. "/manifest.json") then
									if levels[v] == nil then
										levels[v] = {}
									else
									end
									table.insert(levels[v], {
										type = "manifest",
										path = path .. "/" .. v
									})
								elseif love.filesystem.getInfo(path .. "/" .. v .. "/level.json") then
									if levels[v] == nil then
										levels[v] = {}
									else
									end
									table.insert(levels[v], {
										type = "no manifest",
										path = path .. "/" .. v
									})
								else
									local folderInfo = love.filesystem.getInfo(path .. "/")
									if folderInfo and folderInfo.type == "directory" then
										scanDuplicates(path .. "/" .. v)
									end
								end
							end
						end
						scanDuplicates("Custom Levels")
						for k, v in pairs(levels) do
							if #v > 1 then
								forceprint('"' .. k .. '"')
								for i, vv in ipairs(v) do
									forceprint("   " .. vv.path .. " (" .. vv.type .. ")")
								end
							end
						end
					end
				)
			end
		end)
		imgui.EndTabItem("Level Select##beattoolsConfig")
	end
	if imgui.BeginTabItem("Editor##beattoolsConfig") then
		configHelpers.treeNode("Visuals", function()
			configHelpers.treeNode("General", function()
				configHelpers.doc("editor_visuals_general")
				configHelpers.input("editorBgColor")
				configHelpers.input("editorSnapColor")
				configHelpers.input("editorBlackColor")
				imgui.Separator()
				configHelpers.input("whiteSelected")
				if mod.config.whiteSelected ~= "off" then
					configHelpers.input("selectedBorderColor")
				end
				imgui.Separator()
				configHelpers.input("betterBookmarks")
				imgui.Separator()
				configHelpers.input("zoomMin")
				configHelpers.input("zoomMax")
				imgui.Separator()
				configHelpers.input("editorBeats")
				configHelpers.input("scrollPast", nil, nil, "%.2f")
				imgui.Separator()
				configHelpers.input("livelyCranky")
			end)
			configHelpers.treeNode("Windows", function()
				configHelpers.doc("editor_visuals_windows")
				configHelpers.input("easeList")
				configHelpers.input("bookmarkList")
				configHelpers.input("showEventGroups")
				configHelpers.input("editorCalculator")
				configHelpers.input("undoHistory")
			end)
			configHelpers.treeNode("Tracking", function()
				configHelpers.doc("editor_visuals_tracking")
				configHelpers.input("colorPreview")
				configHelpers.input("colorEasePreview")
				configHelpers.input("coordsDisplay")
				configHelpers.condTreeNode("Ease List", "easeList", true, true, function()
					configHelpers.input("easeListUse")
					configHelpers.input("easeListUsed")
					configHelpers.input("easeListSerious")
					configHelpers.input("easeListSelectChanged")
					configHelpers.input("easeListSelected")
					configHelpers.input("easeListRound")
					configHelpers.input("easeListUsedVars")
				end)
				imgui.Separator()
				configHelpers.input("currentPaddle")
				configHelpers.input("currentSprite")
				imgui.Separator()
				configHelpers.condTreeNode("Coords colors", "mouseCoordsButton", true, true,
					function()
						configHelpers.input("lineColor")
						configHelpers.input("shadow2")
						configHelpers.input("fgColor2")
						configHelpers.input("bgColor2")
					end)
			end)
			configHelpers.treeNode("Markers", function()
				configHelpers.doc("editor_visuals_markers")
				configHelpers.input("markRepeat")
				configHelpers.input("showDuration")
				imgui.Separator()
				configHelpers.input("markSameEasing")
				if (mod.config.markRepeat ~= "off" or mod.config.showDuration ~= "off" or mod.config.markSameEasing) then
					configHelpers.treeNode("Marker Colors", function()
						if mod.config.showDuration == "on" then
							configHelpers.input("durationColor")
						end
						if mod.config.markRepeat ~= "off" or mod.config.showDuration ~= "off" then
							configHelpers.input("durationSelectedColor")
						end
						if mod.config.markSameEasing then
							configHelpers.input("durationSameEasingColor")
						end
					end)
				end
				imgui.Separator()
				configHelpers.input("markEndAnglePosition")
				configHelpers.input("displayEndAngle")
				imgui.Separator()
				configHelpers.input("showParam")
				configHelpers.condTreeNode("Text Colors", "showParam", "none", false,
					function()
						configHelpers.input("shadow")
						configHelpers.input("fgColor")
						configHelpers.input("bgColor")
					end)
			end)
			configHelpers.treeNode("Stacking", function()
				configHelpers.doc("editor_visuals_stacking")
				configHelpers.input("xOffset")
				configHelpers.input("yOffset")
				imgui.Separator()
				configHelpers.input("alpha", nil, nil, "%.3f")
				configHelpers.input("stackingNotes")
			end)
			configHelpers.treeNode("UI", function()
				configHelpers.doc("editor_visuals_UI")
				configHelpers.input("shortenParams")
				configHelpers.input("fullSize")
				if not mod.config.fullSize then
					configHelpers.input("inputSize")
				end
				configHelpers.input("hideHelpMarkers")
				imgui.Separator()
				configHelpers.input("preciseTimeInput")
				configHelpers.input("betterCombo")
				configHelpers.input("easeCurrentValues")
			end)
		end)
		configHelpers.treeNode("Features", function()
			configHelpers.treeNode("Metadata", function()
				configHelpers.doc("editor_features_metadata")
				configHelpers.input("browserCharter")
				configHelpers.inputText("charter")
			end)
			configHelpers.treeNode("Adjustments", function()
				configHelpers.doc("editor_features_adjustments")
				configHelpers.input("dragThreshhold")
				configHelpers.input("rememberMultiselectDelta")
				imgui.Separator()
				configHelpers.input("roundSelectedTimes")
				configHelpers.input("autoFixSides")
				imgui.Separator()
				configHelpers.input("betterMoveSelection")
				configHelpers.input("betterUntagging")
				imgui.Separator()
				configHelpers.input("menuMusicInEditor")
				configHelpers.input("sillyNisenenGimmick")
				configHelpers.input("decoRotation")
			end)
			configHelpers.treeNode("Features", function()
				configHelpers.doc("editor_features_features")
				configHelpers.input("deleteNothing")
				imgui.Separator()
				configHelpers.input("saveAngleBeatSnap")
				configHelpers.condTreeNode("Angle/Beat Defaults", "saveAngleBeatSnap", false,
					true,
					function()
						configHelpers.input("angleDefault")
						configHelpers.input("customAngleDefault")
						configHelpers.input("beatDefault")
						configHelpers.input("customBeatDefault")
					end)
				configHelpers.treeNode("Snap List", function()
					configHelpers.inputList("angleSnapValues")
					configHelpers.inputList("beatSnapValues")
				end)
				imgui.Separator()
				configHelpers.input("bounceDragging")
				configHelpers.input("bounceDoubleClick")
				imgui.Separator()
				configHelpers.input("convertSingle")
				configHelpers.input("copySingle")
				configHelpers.input("ctrlSelect")
				imgui.Separator()
				configHelpers.input("fakeRepeat")
				imgui.Separator()
				configHelpers.input("ignoreUntagPrompt")
				imgui.Separator()
				configHelpers.input("groupTimeDifference", nil, nil, "%.3f")
				imgui.Separator()
				configHelpers.condTreeNode("Spreading", "spreadButtons", true, true,
					function()
						configHelpers.input("spreadSnap")
						configHelpers.input("spreadType")
					end)
			end)
			configHelpers.treeNode("Buttons", function()
				configHelpers.doc("editor_features_buttons")
				configHelpers.input("untaggingButtons")
				configHelpers.input("spreadButtons")
				configHelpers.input("mouseCoordsButton")
				configHelpers.input("angleDials")
			end)
			configHelpers.treeNode("Hotkeys", function()
				configHelpers.doc("editor_features_hotkeys")
				configHelpers.input("selectNoneInPalette")
				configHelpers.input("hideMenus")
				configHelpers.input("restartInPlaytest")
				imgui.Separator()
				configHelpers.input("undoHotkeys")
				configHelpers.input("untaggingHotkeys")
				imgui.Separator()
				configHelpers.input("selectAll")
				configHelpers.input("jumpEvents")
			end)
		end)
		imgui.EndTabItem("Editor##beattoolsConfig")
	end
	if imgui.BeginTabItem("Search##beattoolsConfig") then
		configHelpers.presets.search()
		imgui.EndTabItem("Search##beattoolsConfig")
	end
	imgui.EndTabBar()
end
