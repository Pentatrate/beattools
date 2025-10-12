local doc = {
	general_fullDescription = {
		long = "Editor quality-of-life mod\
Should be compatible with all other editor qol mods\
For now largest mod with the for now largest configs menu\
Gameplay:\
  Accessibility option to revert time back to before you lagged (will show in results screen)\
  Accuracy bar from the previous subgrade to the next subgrade\
Editor:\
  Ability to customize basic editor colors and the selection border\
  Adjustable zoom limits. Scroll past the beginning of the level\
  Saves angle/beat snap (idea: unity)\
  Allows custom angle/beat snap defaults/lists for cycling through\
  Shows current paddle arrangement in-editor\
  Shows color channel's current color (includes easing and loadBeat)\
  Show color channels used for bgColor, voidColor, outline, noise, player colors, etc. (idea: unity)\
  Also shows the current song name override\
  Adds an ease list to see current value of all eases or filter them\
  Adds a bookmark list to easily teleport between bookmarks (idea: tunne_123)\
  Click on ease or color channel to select event responsible for value or all events setting that var\
  Right click on ease or color channel to copy value/hex code (idea: unity)\
  Make the input sizes fit the window size or a custom size and cleans the select input\
  Replaces the help marker with a tooltip, making more space\
  Shows the current forced player sprite in-editor (idea: unity)\
  Lively (cranky blinks, falls asleep (Doesnt work in EA!)), is happy when holding the modifier key or >< after playtesting\
  Shows beats progressed within the bookmark and a bit more (idea: bean)\
  Shows the Nisenen event parameter (idea: crisp_chip)\
Event Visuals:\
  Marks position of repeated events and eases\
  Marks duration of (repeated) events and eases\
  Offsets directly overlapping (stacked) non note events\
  Also makes them transparent when stacked\
  Notes are rendered under non notes. Overlapping note events are marked\
  Option to draw notes at endAngle instead (idea: whenpigfly666)\
  Set endAngle to angle when toggling it on (idea: piger)\
  Can draw some parameter values on events (order, speedMult)\
  Marks events that ease the same value\
Metadata:\
  Edit the total level charter option (idea: _play_)\
  Auto-insert a predefined one when creating a variant (idea: _play_)\
Buttons:\
  Button to spread stacked events (idea: crisp_chip)\
  Buttons to (un)tag event(s)\
  Button to use mouse coordinates for inputs (idea: crisp_chip)\
Features:\
  Drag bounces around like holds (idea: crisp_chip)\
  Double click and drag to adjust bounce amount (idea: k4kadu)\
  Ctrl select (original: k4kadu)\
  Fakes an option to repeat events. Compatible with unmodded\
  Mod specific confirmation, prompts and error popups (some text by: k4kadu, something4803, irember135)\
  Rounds time for all selected events to prevent float inaccuracy\
Hotkeys:\
  Config Hotkeys\
  - \"r\" to reload the config in the editor\
  - \"f\" to fold all tree nodes but the by default open ones\
  During Playtest\
  - \"restart hotkey\" to restart in editor playtest (to the position you started playtesting)\
  Undo in Editor:\
  - \"z\" to undo a single change\
  - \"shift + z\" to redo a single change\
  - \"ctrl + z\" to undo multiple changes grouped by time difference\
  - \"ctrl + shift + z\" to redo multiple changes grouped by time difference\
  Select in Editor\
  - Right click empty space or \"n\" while placing event to deselect the placable event\
	(select \"None\" in event palette)\
  Multiselect in Editor\
  - \"ctrl + a\" to select all events\
  - \"ctrl + up/down arrow\" to snap to the next event\
  Tagging in Editor\
  - \"t\" to tag selection\
  - \"shift + t\" to untag a single tag\
  - \"ctrl + t\" to untag same tag name (all tags with the same tag name)\
\
Contributions:\
  - Pentatrate: (Almost) All code\
  - K4kadu: Reworking most editor marker images"
-- Penta: der Rest vom Schützenfest (saying) (jk this is just a comment to prevent folding weirdness)
	}, general_menuOptions = {
		long = "The mod config is designed to be very flexible, accessible in the editor in real time and adjustable for when you need more information or know what you're doing and want to keep it simple",
		short = "Edit the way this menu is displayed and arranged"
	}, general_advanced = {
		long = "Advanced settings the normal user shouldnt need to touch, like controlling compatibility with other mods, lag reduction by setting limits or niche stuff\nThese settings may severely effect lag in larger levels and/or require the user to know what they are doing",
		short = "Advanced settings for compatibility, lag reduction or niche features that require knowledge to use"
	}, game_visuals = {
		long = "Adjust and toggle the additional user interface elements added by this mod (Accuracy Bar) or the custom visuals for vfx-less levels during gameplay",
		short = "Adjust and toggle the modded UI or custom vfx during gameplay"
	}, game_features = {
		long = "Adjust and toggle new features added by this mod during gameplay",
		short = "Adjust and toggle modded features during gameplay"
	}, levelSelect_visuals = {
		long = "Allows displaying more stats or updates them relative to the game speed and allows displaying incompatible files that are unselectable",
		short = "Allows displaying more stats and incompatible files"
	}, levelSelect_features = {
		long = "Loads levels dynamically as you scroll or logs duplicate folder names of levels",
		short = "Loads levels as you scroll or logs duplicate folder names"
	}, editor_visuals_general = {
		long = "Visually customize editor colors, zoom, displayed beats, scrolling past the beginning of the level, enhance the bookmark slider and breath life into cranky's face",
		short = "Visually customize editor colors, zoom, scroll limits, the bookmark slider and cranky's face"
	}, editor_visuals_tracking = {
		long = "Display current values/states for level colors, variables, player sprites, paddles or mouse coordinates in the editor",
		short = "Display current values for level/player variables and colors"
	}, editor_visuals_markers = {
		long = "Visual tweaks in the editor to indicate the positions of repeated eases or events and their duration\nIndicates or draws gameplay at their end angle\nShows an event parameter visually as a number near the event",
		short = "Visually indicate repeated eases or events, their durations, end angle and supported event parameters"
	}, editor_visuals_stacking = {
		long = "Visual tweaks in the editor to indicate gameplay notes or to separate non-notes that are stacked on top of each other with same time and angle while moving their selection hitboxes as well\nEspecially useful when editing levels of other people or merged collabs out of multiple parts",
		short = "Visually indicate or separate events with the same time and angle"
	}, editor_visuals_UI = {
		long = "Shorten event parameter names, adjust input sizes and behavior or hide help markers",
		short = "Adjust input size behavior, names and help markers"
	}, editor_features_metadata = {
		long = "Adds an additional option in the level properties for the charter that the browser displays and it's default setting when creating a new level",
		short = "Adds an additional option for the charter in the browser"
	}, editor_features_adjustments = {
		long = "Adjusts existing editor behavior for more intuitive use, mainly for odd beat snaps or including angle2",
		short = "Adjustments to existing editor behavior"
	}, editor_features_features = {
		long = "New editor behaviors and features added by this mod",
		short = "Newly added features"
	}, editor_features_buttons = {
		short = "Enable/Disable/Configure button features"
	}, editor_features_hotkeys = {
		short = "Enable/Disable hotkeys"
	}
}
if beattoolsOptions == nil then beattoolsOptions = dofile("Mods/beattools/configOptions.lua") end
local function Doc(key)
	if mod.config.docInMenu ~= "none" and doc[key] then
		local txt = doc[key][mod.config.docInMenu]
		if mod.config.tooltipsInMenu == "long" and not txt then
			txt = doc[key].short
		end
		if txt then
			imgui.TextWrapped(txt)
			imgui.Separator()
		end
	end
end
if beattoolsConfigHelpers == nil then -- config helpers
	local chunk, e = love.filesystem.load("Mods/beattools/configHelpers.lua")
	if e then beattoolsError("Error while loading the config helper functions of Beattools") print("[BT] Error while loading the config helper functions of Beattools. " .. e) else
		beattoolsConfigHelpers = setfenv(chunk, setmetatable({ mod = mod }, { __index = _G }))()
	end
end

if imgui.BeginTabBar("beattoolsConfig") then
	if imgui.BeginTabItem("General##beattoolsConfig") then
		if beattoolsConfigHelpers.TreeNode("Menu Options", 2 ^ 5) then
			Doc("general_menuOptions")
			beattoolsConfigHelpers.InputBool("editorMenu")
			imgui.Separator()
			beattoolsConfigHelpers.InputCombo("docInMenu")
			beattoolsConfigHelpers.InputCombo("tooltipsInMenu")
			imgui.Separator()
			if imgui.Button("Default") then
				beattoolsConfirmationOpen = true
				beattoolsConfirmationText2 = "You will reset all config options for this large mod back to default"
				beattoolsConfirmationFunc2 = function()
					mods.beattools.config.imguiColors = nil
					for key, v in pairs(beattoolsOptions) do
						mod.config[key] = v.default
					end
				end
				beattoolsConfirmationRandomized2 = math.random()
			end
			imgui.SameLine()
			if imgui.Button("Off") then
				beattoolsConfirmationOpen = true
				beattoolsConfirmationText2 = "You will turn all mod features off"
				beattoolsConfirmationFunc2 = function()
					mods.beattools.config.imguiColors = nil
					for key, v in pairs(beattoolsOptions) do
						if v.off ~= nil then mod.config[key] = v.off end
					end
				end
				beattoolsConfirmationRandomized2 = math.random()
			end
			imgui.TreePop()
		end
		if beattoolsConfigHelpers.TreeNode("Advanced") then
			Doc("general_advanced")
			beattoolsConfigHelpers.InputBool("speedScrolling")
			imgui.Separator()
			beattoolsConfigHelpers.InputInt("scanMargin")
			imgui.Separator()
			beattoolsConfigHelpers.InputFloat("scanInterval", nil, nil, "%.2f")
			beattoolsConfigHelpers.InputCombo("keyHandling")
			beattoolsConfigHelpers.InputInt("loopVisibleEventsAmount")
			beattoolsConfigHelpers.InputInt("loopEventsDuringSelectionAmount")
			beattoolsConfigHelpers.InputInt("loopSingleSelectionEventAmount")
			imgui.Separator()
			beattoolsConfigHelpers.InputCombo("randomizeWindows")
			beattoolsConfigHelpers.InputBool("imguiGuide")
			if imgui.Button("Save Colors Permanently") then
				local function fail()
					beattoolsErrorText2 = "ImGui data detected, but it's invalid :skull:"
					beattoolsErrorRandomized2 = math.random()
					beattoolsErrorOpen2 = true
				end
				local text = love.system.getClipboardText()
				for w in string.gmatch(string.gsub(text, "colors%[", "?"), "[^?]+") do
					local i1 = string.find(w, "]", 1, true)
					if i1 then
						local _, i2 = string.find(w, "= ImVec4(", i1 + 1, true)
						if i2 then
							local i3 = string.find(w, "f);", i2 + 1, true)
							if i3 then
								local values = {}
								for ww in string.gmatch(string.gsub(string.sub(w, i2 + 1, i3 - 1), "f, ", "?"), "[^?]+") do
									table --[[stop wrong injection]].insert(values, tonumber(ww))
								end
								if #values == 4 then
									-- print(string.sub(w, 1, i1 - 1) .. " " .. values[1] .. " " .. values[2] .. " " .. values[3] .. " " .. tostring(values[4]))
									imgui.PushStyleColor_Vec4(imgui[string.sub(w, 1, i1 - 1)],
										imgui.ImVec4_Float(values[1], values[2], values[3], values[4]))
									if mods.beattools.config.imguiColors == nil then mods.beattools.config.imguiColors = {} end
									mods.beattools.config.imguiColors[string.sub(w, 1, i1 - 1)] = values
                                else
									fail()
									print("[BT] Failed.")
								end
                            else
								fail()
								print("[BT] Failed.")
							end
                        else
							fail()
							print("[BT] Failed.")
						end
                    elseif string.find(w, "ImVec4* colors = ImGui::GetStyle().Colors;", 1, true) == nil then
						beattoolsErrorText2 = "You have to export your ImGui colors to your clipboard\n(which you didnt do apparently)"
						beattoolsErrorRandomized2 = math.random()
						beattoolsErrorOpen2 = true
                        print("[BT] Failed.")
					end
				end
			end
			if imgui.Button("Reset Colors") then
				beattoolsConfirmationOpen = true
				beattoolsConfirmationText2 = "You will reset your custom ImGui colors to default"
				beattoolsConfirmationFunc2 = function()
					mods.beattools.config.imguiColors = nil
					imgui.PopStyleColor(100)
				end
				beattoolsConfirmationRandomized2 = math.random()
			end
			imgui.TreePop()
		end
		beattoolsConfigHelpers.ConditionalTreeNode("Full Mod Description", "docInMenu", "long", true, function()
			Doc("general_fullDescription")
		end)
		beattoolsConfigHelpers.ConditionalTreeNode("ImGui User Guide", "docInMenu", "long", true, function()
			imgui.ShowUserGuide()
		end)
		imgui.EndTabItem("General##beattoolsConfig")
	end
	if imgui.BeginTabItem("Game##beattoolsConfig") then
		if beattoolsConfigHelpers.TreeNode("Visuals") then
			Doc("game_visuals")
			beattoolsConfigHelpers.InputBool("customLevelVisuals")
			beattoolsConfigHelpers.ConditionalTreeNode("Colors", "customLevelVisuals", true, true, function()
				beattoolsConfigHelpers.InputColor("customWhiteColor")
				beattoolsConfigHelpers.InputColor("customBlackColor")
			end)
			imgui.Separator()
			beattoolsConfigHelpers.InputBool("accBar")
			beattoolsConfigHelpers.ConditionalTreeNode("Bar Visuals", "accBar", true, true, function()
				beattoolsConfigHelpers.InputInt("accBarWidth")
				beattoolsConfigHelpers.InputCombo("accBarSide")
				beattoolsConfigHelpers.InputBool("accBarReverse")
				beattoolsConfigHelpers.InputCombo("accBarColors")
				beattoolsConfigHelpers.InputFloat("accBarSmooth")
			end)
			imgui.TreePop()
		end
		if beattoolsConfigHelpers.TreeNode("Features") then
			Doc("game_features")
			beattoolsConfigHelpers.InputBool("damoclismCataclism")
			imgui.Separator()
			beattoolsConfigHelpers.InputBool("lagBack")
			beattoolsConfigHelpers.ConditionalTreeNode("Lag Back Options", "lagBack", true, true, function()
				beattoolsConfigHelpers.InputFloat("lagThreshhold")
				beattoolsConfigHelpers.InputFloat("lagOffset")
				beattoolsConfigHelpers.InputBool("lagUseSeconds")
			end)
			imgui.TreePop()
		end
		imgui.EndTabItem("Game##beattoolsConfig")
	end
	if imgui.BeginTabItem("Level Select##beattoolsConfig") then
		if beattoolsConfigHelpers.TreeNode("Visuals") then
			Doc("levelSelect_visuals")
			beattoolsConfigHelpers.InputBool("levelSelectMultiplyBpm")
			imgui.BeginDisabled()
			beattoolsConfigHelpers.InputBool("levelSelectShowIncompatible")
			imgui.EndDisabled()
			imgui.TreePop()
		end
		if beattoolsConfigHelpers.TreeNode("Features") then
			Doc("levelSelect_features")
			imgui.BeginDisabled()
			beattoolsConfigHelpers.InputBool("levelSelectDynamicLoading")
			imgui.EndDisabled()
			imgui.Separator()
			if imgui.Button("Scan Duplicates") then
				beattoolsConfirmationOpen = true
				beattoolsConfirmationText2 =
				"You will scan all custom levels for duplicate level folder names\nThe results will be printed in the console"
				beattoolsConfirmationFunc2 = function()
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
							print('"' .. k .. '"')
							for i, vv in ipairs(v) do
								print("   " .. vv.path .. " (" .. vv.type .. ")")
							end
						end
					end
				end
				beattoolsConfirmationRandomized2 = math.random()
			end
			imgui.TreePop()
		end
		imgui.EndTabItem("Level Select##beattoolsConfig")
	end
	if imgui.BeginTabItem("Editor##beattoolsConfig") then
		if beattoolsConfigHelpers.TreeNode("Visuals") then
			if beattoolsConfigHelpers.TreeNode("General") then
				Doc("editor_visuals_general")
				beattoolsConfigHelpers.InputColor("editorBgColor")
				beattoolsConfigHelpers.InputColor("editorSnapColor")
				beattoolsConfigHelpers.InputColor("editorBlackColor")
				imgui.Separator()
				beattoolsConfigHelpers.InputCombo("whiteSelected")
				if mod.config.whiteSelected ~= "off" then
					beattoolsConfigHelpers.InputColor("selectedBorderColor")
				end
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("betterBookmarks")
				imgui.Separator()
				beattoolsConfigHelpers.InputInt("zoomMin")
				beattoolsConfigHelpers.InputInt("zoomMax")
				imgui.Separator()
				beattoolsConfigHelpers.InputInt("editorBeats")
				beattoolsConfigHelpers.InputFloat("scrollPast", nil, nil, "%.2f")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("livelyCranky")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("showEventGroups")
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("Tracking") then
				Doc("editor_visuals_tracking")
				beattoolsConfigHelpers.InputBool("colorPreview")
				beattoolsConfigHelpers.InputBool("colorEasePreview")
				beattoolsConfigHelpers.InputBool("coordsDisplay")
				beattoolsConfigHelpers.InputBool("easeList")
				beattoolsConfigHelpers.InputBool("bookmarkList")
				beattoolsConfigHelpers.ConditionalTreeNode("Ease List", "easeList", true, true, function()
					beattoolsConfigHelpers.InputBool("easeListUse")
					beattoolsConfigHelpers.InputBool("easeListUsed")
					beattoolsConfigHelpers.InputBool("easeListSerious")
					beattoolsConfigHelpers.InputBool("easeListSelectChanged")
					beattoolsConfigHelpers.InputBool("easeListSelected")
					beattoolsConfigHelpers.InputBool("easeListRound")
				end)
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("currentPaddle")
				beattoolsConfigHelpers.InputBool("currentSprite")
				imgui.Separator()
				beattoolsConfigHelpers.ConditionalTreeNode("Coords colors", "mouseCoordsButton", true, true, function()
					beattoolsConfigHelpers.InputColor("lineColor")
					beattoolsConfigHelpers.InputBool("shadow2")
					beattoolsConfigHelpers.InputColor("fgColor2")
					beattoolsConfigHelpers.InputColor("bgColor2")
				end)
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("Markers") then
				Doc("editor_visuals_markers")
				beattoolsConfigHelpers.InputCombo("markRepeat")
				beattoolsConfigHelpers.InputCombo("showDuration")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("markSameEasing")
				if (mod.config.markRepeat ~= "off" or mod.config.showDuration ~= "off" or mod.config.markSameEasing) and beattoolsConfigHelpers.TreeNode("Marker Colors") then
					if mod.config.showDuration == "on" then
						beattoolsConfigHelpers.InputColor("durationColor")
					end
					if mod.config.markRepeat ~= "off" or mod.config.showDuration ~= "off" then
						beattoolsConfigHelpers.InputColor("durationSelectedColor")
					end
					if mod.config.markSameEasing then
						beattoolsConfigHelpers.InputColor("durationSameEasingColor")
					end
					imgui.TreePop()
				end
				imgui.Separator()
				beattoolsConfigHelpers.InputCombo("markEndAnglePosition")
				beattoolsConfigHelpers.InputBool("displayEndAngle")
				imgui.Separator()
				beattoolsConfigHelpers.InputCombo("showParam")
				beattoolsConfigHelpers.ConditionalTreeNode("Text Colors", "showParam", "none", false, function()
					beattoolsConfigHelpers.InputBool("shadow")
					beattoolsConfigHelpers.InputColor("fgColor")
					beattoolsConfigHelpers.InputColor("bgColor")
				end)
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("Stacking") then
				Doc("editor_visuals_stacking")
				beattoolsConfigHelpers.InputInt("xOffset")
				beattoolsConfigHelpers.InputInt("yOffset")
				imgui.Separator()
				beattoolsConfigHelpers.InputFloat("alpha", nil, nil, "%.3f")
				beattoolsConfigHelpers.InputBool("stackingNotes")
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("UI") then
				Doc("editor_visuals_UI")
				beattoolsConfigHelpers.InputBool("shortenParams")
				beattoolsConfigHelpers.InputBool("fullSize")
				if not mod.config.fullSize then
					beattoolsConfigHelpers.InputInt("inputSize")
				end
				beattoolsConfigHelpers.InputBool("hideHelpMarkers")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("preciseTimeInput")
				beattoolsConfigHelpers.InputBool("betterCombo")
				beattoolsConfigHelpers.InputBool("easeCurrentValues")
				imgui.TreePop()
			end
			imgui.TreePop()
		end
		if beattoolsConfigHelpers.TreeNode("Features") then
			if beattoolsConfigHelpers.TreeNode("Metadata") then
				Doc("editor_features_metadata")
				beattoolsConfigHelpers.InputBool("browserCharter")
				beattoolsConfigHelpers.InputText("charter")
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("Adjustments") then
				Doc("editor_features_adjustments")
				beattoolsConfigHelpers.InputInt("dragThreshhold")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("roundSelectedTimes")
				beattoolsConfigHelpers.InputBool("autoFixSides")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("betterMoveSelection")
				beattoolsConfigHelpers.InputBool("betterUntagging")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("sillyNisenenGimmick")
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("Features") then
				Doc("editor_features_features")
				beattoolsConfigHelpers.InputBool("deleteNothing")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("saveAngleBeatSnap")
				beattoolsConfigHelpers.ConditionalTreeNode("Angle/Beat Defaults", "saveAngleBeatSnap", false, true,
					function()
						beattoolsConfigHelpers.InputInt("angleDefault")
						beattoolsConfigHelpers.InputInt("customAngleDefault")
						beattoolsConfigHelpers.InputInt("beatDefault")
						beattoolsConfigHelpers.InputInt("customBeatDefault")
					end)
				if beattoolsConfigHelpers.TreeNode("Snap List") then
					beattoolsConfigHelpers.InputList("angleSnapValues")
					beattoolsConfigHelpers.InputList("beatSnapValues")
					imgui.TreePop()
				end
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("bounceDragging")
				beattoolsConfigHelpers.InputBool("bounceDoubleClick")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("ctrlSelect")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("fakeRepeat")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("ignoreUntagPrompt")
				imgui.Separator()
				beattoolsConfigHelpers.InputFloat("groupTimeDifference", nil, nil, "%.3f")
				imgui.Separator()
				beattoolsConfigHelpers.ConditionalTreeNode("Spreading", "spreadButtons", true, true, function()
					beattoolsConfigHelpers.InputInt("spreadSnap")
					beattoolsConfigHelpers.InputCombo("spreadType")
				end)
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("Buttons") then
				Doc("editor_features_buttons")
				beattoolsConfigHelpers.InputBool("untaggingButtons")
				beattoolsConfigHelpers.InputBool("spreadButtons")
				beattoolsConfigHelpers.InputBool("mouseCoordsButton")
				imgui.TreePop()
			end
			if beattoolsConfigHelpers.TreeNode("Hotkeys") then
				Doc("editor_features_hotkeys")
				beattoolsConfigHelpers.InputBool("selectNoneInPalette")
				beattoolsConfigHelpers.InputBool("hideMenus")
				beattoolsConfigHelpers.InputBool("restartInPlaytest")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("undoHotkeys")
				beattoolsConfigHelpers.InputBool("untaggingHotkeys")
				imgui.Separator()
				beattoolsConfigHelpers.InputBool("selectAll")
				beattoolsConfigHelpers.InputBool("jumpEvents")
				imgui.TreePop()
			end
			imgui.TreePop()
		end
		imgui.EndTabItem("Editor##beattoolsConfig")
	end
	if mod.config.foldAll then mod.config.foldAll = false end
end

if true then -- Prompts
	if beattoolsConfirmationOpen and not imgui.IsPopupOpen("beattoolsConfirmation2") then
		imgui.OpenPopup_Str("beattoolsConfirmation2")
	end
	beattoolsConfirmationOpen = false
	if imgui.BeginPopup("beattoolsConfirmation2") then
		imgui.PushTextWrapPos(imgui.GetFontSize() * 35)
		imgui.TextUnformatted("Are you sure?")
		imgui.TextUnformatted(tostring(beattoolsConfirmationText2))
		imgui.PopTextWrapPos()
		local confirmationTexts = mods.beattools.config.confirmationTexts
		if imgui.Button(tostring(confirmationTexts[math.floor(beattoolsConfirmationRandomized2 * #confirmationTexts) + 1]) .. "##beattools") then
			local tempFunc = beattoolsConfirmationFunc2
			beattoolsConfirmationText2 = ""
			beattoolsConfirmationFunc2 = function () end
			beattoolsConfirmationRandomized2 = 0
			if tempFunc then tempFunc() end
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup("beattoolsConfirmation2")
	elseif beattoolsConfirmationText2 ~= "" then
		beattoolsConfirmationText2 = ""
		beattoolsConfirmationFunc2 = function() end
		beattoolsConfirmationRandomized2 = 0
	end

	if beattoolsErrorOpen2 and not imgui.IsPopupOpen("beattoolsError2") then
		imgui.OpenPopup_Str("beattoolsError2")
	end
	beattoolsErrorOpen2 = false
	if imgui.BeginPopup("beattoolsError2") then
		imgui.PushTextWrapPos(imgui.GetFontSize() * 35)
		-- Penta: I can imagine ppl screenshotting their error code to report it just to realize its just a random number :skull:
		-- Penta: Don't think it's gonna happen though :/
		local errorTexts = { "Error", "Curses!", "Dammit!", "Darn!", "Dang!", "Dangit!", "Task failed successfully.", ":(", "):", ":C", ":c", --[[ k4kadu: ]] "naurr!", "That can't be healthy...", --[[ something4803: ]] "This error sucks:", --[[ irember135: "ypu fked upo the beat blokc you" ]] "you fked up the beat blocked you" }
		table--[[stop wrong injection]].insert(errorTexts, 1, "Error Code " .. tostring(math.floor(beattoolsErrorRandomized2 * (#errorTexts + 1) * 999)))
		imgui.TextUnformatted(tostring(errorTexts[math.floor(beattoolsErrorRandomized2 * #errorTexts) + 1]))
		imgui.Separator()
		imgui.TextUnformatted(tostring(beattoolsErrorText2))
		imgui.PopTextWrapPos()
		imgui.EndPopup("beattoolsError2")
	elseif beattoolsErrorText2 ~= "" then
		beattoolsErrorText2 = ""
		beattoolsErrorRandomized2 = 0
	end
end