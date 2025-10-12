--[[
	option = {
		name = "Option",
		tooltips = { long = "", short = "" },
		default = false,
		off = false
	},
]]
return { -- Penta: I'm sorry I really cannot be bothered to update the order of this table to match the new config order and grouping :(
	-- General
	--   Menu Options
	editorMenu = {
		name = "Configs in Editor",
		tooltips = { long = "Adjust the configs directly in the editor in the same menu format", short = "Show this menu in the editor" },
		default = true
	}, docInMenu = {
		name = "Documentation",
		tooltips = { short = "How to explain the mod in the menu" },
		values = { "long", "short", "none" },
		valueTooltips = {
			{ long = "Thoroughly explains all noteworthy modifications with great detail\nMay require you to scroll a lot", short = "Show detailed explanation" },
			{ short = "Shorten explanation" }
		},
		default = "none"
	}, tooltipsInMenu = {
		name = "Tooltips",
		tooltips = { short = "Tooltip length when hovering" },
		values = { "long", "short", "none" },
		valueTooltips = {
			{ long = "When hovering over menu options, display a detailed tooltip", short = "Display detailed tooltip" },
			{ short = "Shorten tooltip" }
		},
		default = "long"
	},
	--   Non Editor Options
	levelSelectMultiplyBpm = {
		name = "Multiply Bpm",
		tooltips = { short = "Multiply bpm with game speed (rateMod) in level select" },
		default = true,
		off = false
	}, levelSelectShowIncompatible = {
		name = "Show Incompatible",
		tooltips = { short = "Shows incompatible files in custom level folders" },
		default = true,
		off = false
	}, levelSelectDynamicLoading = {
		name = "Dynamic Loading",
		tooltips = { short = "Loads levels as you scroll to reduce initial lag" },
		default = true,
		off = false
	}, lagBack = {
		name = "Lag Back",
		tooltips = { long = "Sets you back some time before you started lagging\nYou will not miss any notes because of lag anymore this way\nHold ctrl to ignore the lagback", short = "Turns back time when you lag" },
		default = false,
		off = false
	}, lagThreshhold = {
		name = "Lag Threshhold",
		tooltips = { short = "Duration of lag to trigger" },
		default = 0.25
	}, lagOffset = {
		name = "Backtrack Amount",
		tooltips = { long = "Lag back to this amount of time before you started lagging", short = "Lag back to this offset" },
		default = 2
	}, lagUseSeconds = {
		name = "Use Seconds",
		tooltips = { short = "Make options in seconds instead of in beats\nThis is recommended as using beats may result in unneccessary lagback on high bpms" },
		default = true
	}, customLevelVisuals = {
		name = "Custom Level Visuals",
		tooltips = { short = "Default colors for vfx-less levels" },
		default = true,
		off = false
	}, customWhiteColor = {
		name = "White Color",
		tooltips = { short = "White color for the level" },
		default = { r = 1, g = 1, b = 1 }
	}, customBlackColor = {
		name = "Black Color",
		tooltips = { short = "Black color for the level" },
		default = { r = 0, g = 0, b = 0 }
	}, accBar = {
		name = "Accuracy Bar",
		tooltips = { long = "Draws an accuracy bar from the previous grade to the next grade", short = "Accuracy bar within grade ingame" },
		default = true,
		off = false
	}, accBarWidth = {
		name = "Bar Width",
		tooltips = { short = "Width in pixels of the accuracy bar" },
		default = 6
	}, accBarSide = {
		name = "Bar Side",
		tooltips = { short = "Side of the bar" },
		values = { "top", "bottom", "left", "right" },
		valueTooltips = {
			{ short = "Display bar along top of screen" },
			{ short = "Display bar along bottom of screen" },
			{ short = "Display bar along left of screen" },
			{ short = "Display bar along right of screen" }
		},
		default = "top"
	}, accBarReverse = {
		name = "Reverse Bar",
		tooltips = { short = "Reverse the direction of the bar\nleft to right or top to bottom by default" },
		default = false
	}, accBarColors = {
		name = "Bar Colors",
		tooltips = { short = "Colors channels the bar uses" },
		values = { "note", "player", "UI/BG", "outline/BG", "auto" },
		valueTooltips = {
			{ short = "Use the colors channels of notes" },
			{ short = "Use the color channels of the player" },
			{ short = "Use the color channels of the UI and the BG" },
			{ short = "Use the color channels of the outline and the BG" },
			{ short = "Use the color channels of the presets that have the greatest contrast" }
		},
		default = "auto"
	}, accBarSmooth = {
		name = "Bar Smooth",
		tooltips = { short = "1 is harsh, 0.1 is smooth" },
		default = 0.35
	},
	--   Advanced
	scanMargin = {
		name = "Scan Margin",
		tooltips = { long = "How many beats outside of the visible area to scan for event stacks. Too small values result results in lag when scrolling. Too large values result results in one lag* spike when the margin is reached.\n(Generally, the scan for event stacks is not laggy enough to even require this measure, so you can input large values)", short = "Beat margin for calculating event stacks" },
		default = 64
	}, scanInterval = {
		name = "Scan Interval",
		tooltips = { long = "Scan for changes to undo/redo in this interval in seconds\nMaybe would be a smart idea to keep this lower than the Group Time Difference (Features/Features)", short = "Scan interval for undo/redo in seconds" },
		default = 0.1
	}, keyHandling = {
		name = "Property Filter",
		tooltips = { long = "Which filter to use when searching for changes within events to undo/redo\nThe whitelist is out of date", short = "Parameter filter for undo/redo\nWhitelist out of date" },
		values = { "whitelist", "blacklist" },
		valueTooltips = {
			{ long = "Ignores all unsupported event parameters added by other mods (especially when they are editor-only mods that auto update event parameters with irrelevant paramter changes (that you wouldnt want to be able to undo/redo), overriding your undo history, making you unable to redo anymore)", short = "Ignores unsupported parameters" },
			{ long = "Save changes of all unsupported event parameters added by other mods (especially when you want to be able to undo/redo them and they dont auto update, basically a gameplay altering mod or custom events)", short = "Takes unsupported parameters into account" }
		},
		default = "blacklist"
	}, loopVisibleEventsAmount = {
		name = "Visible Threshold",
		tooltips = { long = "When checking for changes, only loop through events visible in the editor once the level has this many events. Will still loop through the selected/multiselected events regardless of them being visible", short = "After this threshhold for the level, only scan visible events for changes" },
		default = 5000
	}, loopEventsDuringSelectionAmount = {
		name = "During Threshold",
		tooltips = { long = "When checking for changes, only loop through events within the selection area (not the selection itself) once the multiselection has this many events (You will lag if you ctrl select events (Using \"Ctrl Select\" by Kakadu) at the start and end of the level, because almost the full level will be within the selection area)", short = "After this threshhold for the selection, scan events within selection area instead of within multiselection itself" },
		default = 2000
	}, loopSingleSelectionEventAmount = {
		name = "Single Threshold",
		tooltips = { long = "When checking for changes, only loop through one event in the selection once the multiselection has this many events (You could argue that when a single event in the selection changes, all events change, and therefore could make this value lower) (This is mainly designed for those who ctrl + a large levels and expect the game to run smoothly)", short = "After this threshhold for the selection, scan one event instead of full selection" },
		default = 2000
	}, randomizeWindows = {
		name = "Randomize UI",
		tooltips = { short = "Randomizes editor UI position and size" },
		values = { "off", "edit", "playtest" },
		valueTooltips = { {}, { short = "Randomize upon entering the editor" }, { short = "Randomize upon playtest" } },
		default = "off",
		off = "off"
	}, imguiGuide = {
		name = "ImGui Manual",
		tooltips = { short = "The official ImGui manual" },
		default = false,
		off = false
	},

	-- Visuals
	--   Editor
	editorBgColor = {
		name = "White Color",
		tooltips = { short = "White color for the editor" },
		default = { r = 1, g = 1, b = 1 },
		off = { r = 1, g = 1, b = 1 }
	}, editorSnapColor = {
		name = "Grey Color",
		tooltips = { short = "Grey color for the editor" },
		default = { r = 0.75, g = 0.75, b = 0.75 },
		off = { r = 0.75, g = 0.75, b = 0.75 }
	}, editorBlackColor = {
		name = "Black Color",
		tooltips = { short = "Black color for the editor" },
		default = { r = 0, g = 0, b = 0 },
		off = { r = 0, g = 0, b = 0 }
	}, colorPreview = {
		name = "Color Preview",
		tooltips = { long = "Adds the ability to preview the current colors of all color channels, even while they are eased, respecting load beat as well", short = "Shows current color channel color" },
		default = true,
		off = false
	}, colorEasePreview = {
		name = "Channel Preview",
		tooltips = { short = "Adds an overlay tracking bgColor, outline, noise and HoM" },
		default = true,
		off = false
	}, easeList = {
		name = "Ease List",
		tooltips = { short = "Shows a list of all eases and their values" },
		default = true,
		off = false
	}, easeListUse = {
		name = "Hide Useless",
		tooltips = { short = "Hides eases that apparently do nothing" },
		default = false
	}, easeListUsed = {
		name = "Hide Unused",
		tooltips = { short = "Hides eases not used in the level" },
		default = true
	}, easeListSerious = {
		name = "Hide Troll",
		tooltips = { short = "Hides eases that softlock you or crash the game" },
		default = false
	}, easeListSelectChanged = {
		name = "Select Changed",
		tooltips = { short = "Auto selects non default values" },
		default = true
	}, easeListSelected = {
		name = "Hide Unselected",
		tooltips = { short = "Hides eases not selected by the user" },
		default = false
	}, easeListRound = {
		name = "Round decimals",
		tooltips = { short = "Rounds to the third decimal" },
		default = true
	}, coordsDisplay = {
		name = "Mouse Coordinates",
		tooltips = { short = "Shows the mouse coordinates" },
		default = false,
		off = false
	}, zoomMin = {
		name = "Min Zoom",
		tooltips = { short = "Minimum distance between beat circles" },
		default = 2,
		off = 20
	}, zoomMax = {
		name = "Max Zoom",
		tooltips = { short = "Maximum distance between beat circles" },
		default = 120,
		off = 100
	}, editorBeats = {
		name = "Editor Beats",
		tooltips = { short = "Amount of beats drawn in the editor" },
		default = 24,
		off = 10
	}, scrollPast = {
		name = "Scroll Past",
		tooltips = { long = "Amount of beats you can scroll past the beginning of the level", short = "Beats past the beginning" },
		default = 1,
		off = 0
	}, shortenParams = {
		name = "Shorten Params",
		tooltips = { long = "Use Abbreviations to shorten the event parameter names in the event editor", short = "Abbreviate event parameter names" },
		default = false,
		off = false
	}, fullSize = {
		name = "Full size",
		tooltips = { long = "Widens the input fields in the event/level properties editor as much as possible", short = "Widens input fields to the max" },
		default = true,
		off = false
	}, inputSize = {
		name = "Input Size",
		tooltips = { long = "Set the size for the input fields in the event editor", short = "Size for input fields" },
		default = 150,
		off = 0
	}, betterCombo = {
		name = "Better Select",
		tooltips = { long = "Makes the popup menu for the selection input as large as possible and the width resize to the selected option, removing the arrow for space", short = "Adjusts visuals for the selection input" },
		default = true,
		off = false
	}, preciseTimeInput = {
		name = "Precise Time",
		tooltips = { short = "More decimals for the time parameter" },
		default = false,
		off = false
	}, hideHelpMarkers = {
		name = "Hide Help Markers",
		tooltips = { long = "Makes the tooltip display over the label and input field instead of creating a help marker for that", short = "Remove the help marker for a tooltip" },
		default = false,
		off = false
	}, livelyCranky = {
		name = "Lively Cranky",
		tooltips = { long = "Makes cranky (blink, fall asleep NOT IN EA), happy when holding the modifier hotkey, and >< after playtesting", short = "Animates cranky's face" },
		default = true,
		off = false
	}, currentPaddle = {
		name = "Current Paddle",
		tooltips = { long = "Shows how the paddle looks like ingame at this beat", short = "Visualizes paddle events in the editor" },
		default = true,
		off = false
	}, currentSprite = {
		name = "Current Sprite",
		tooltips = { long = "Shows how cranky's face looks like ingame at this beat", short = "Visualizes player sprite events in the editor" },
		default = true,
		off = false
	}, easeCurrentValues = {
		name = "Current ease value",
		tooltips = { short = "Reveals the current value for the selected ease" },
		default = true,
		off = false
	}, betterBookmarks = {
		name = "Better Bookmarks",
		tooltips = { short = "Small (visual) adjustments to the alt wheel" },
		default = true,
		off = false
	},
	--   Markers
	whiteSelected = {
		name = "Custom Select Border",
		tooltips = { short = "Select borders will be white instead of black" },
		values = { "cut corners", "on", "off" },
		valueTooltips = {
			{ short = "Cut the corners to match a popular texture pack" },
		},
		default = "off",
		off = "off"
	}, selectedBorderColor = {
		name = "Border Color",
		tooltips = { short = "Color used for the selection border" },
		default = { r = 0, g = 0, b = 0, a = 1 }
	}, markRepeat = {
		name = "Mark Repeat",
		tooltips = { long = "Visually marks the positions or repeated eases and events", short = "Mark repeated eases and events" },
		values = { "on", "selected", "off" },
		valueTooltips = {
			nil,
			{ short = "Only show for the selected event" }
		},
		default = "on",
		off = "off"
	}, showDuration = {
		name = "Show Duration",
		tooltips = { long = "Visually indicates the length of the durations of eases and events as lines following the event", short = "Durations are drawn as lines" },
		values = { "on", "selected", "off" },
		valueTooltips = {
			nil,
			{ short = "Only show for the selected event" }
		},
		default = "on",
		off = "off"
	}, durationColor = {
		name = "Line Color",
		tooltips = { short = "Color used for the line" },
		default = { r = 0, g = 1, b = 0, a = 0.5 }
	}, durationSelectedColor = {
		name = "Selected Color",
		tooltips = { short = "Color used for the line when selected" },
		default = { r = 1, g = 0, b = 0, a = 0.5 }
	}, durationSameEasingColor = {
		name = "Same Easing Color",
		tooltips = { short = "Color used for the line when the event eases the same thing" },
		default = { r = 0, g = 0, b = 1, a = 0.5 }
	}, markSameEasing = {
		name = "Same Easing Markers",
		tooltips = { long = "Visually marks events easing the same value as the selected event", short = "Mark events easing the selected events value" },
		default = true,
		off = false
	}, markEndAnglePosition = {
		name = "End Angle Markers",
		tooltips = { long = "Visually marks the start or end postitons of notes with end angles", short = "Mark start or end angles" },
		values = { "on", "selected", "off" },
		valueTooltips = {
			nil,
			{ short = "Only show for the selected event" }
		},
		default = "on",
		off = "off"
	}, displayEndAngle = {
		name = "At End Angle",
		tooltips = { short = "Draw notes at their end angle instead" },
		default = true,
		off = false
	}, showParam = {
		name = "Quick Property",
		tooltips = { long = "Draws one property of an event as a number on its sprite", short = "Draws numbers on events" },
		values = { "none", "order", "speedMult" },
		valueTooltips = {},
		default = "order",
		off = "none"
	}, shadow = {
		name = "Shadow",
		tooltips = { short = "Draw a shadow instead of an outline" },
		default = true
	}, fgColor = {
		name = "Text Color",
		tooltips = { short = "Color used for the text" },
		default = { r = 1, g = 0.5, b = 0 }
	}, bgColor = {
		name = "Background Color",
		tooltips = { short = "Color used for the outline/shadow" },
		default = { r = 0, g = 0, b = 0 }
	}, lineColor = {
		name = "Marker Color",
		tooltips = { short = "Color used for the position marker" },
		default = { r = 0.373, g = 0.373, b = 0.373, a = 0.5 }
	}, shadow2 = {
		name = "Shadow",
		tooltips = { short = "Draw a shodow instead of an outline" },
		default = false
	}, fgColor2 = {
		name = "Text Color",
		tooltips = { short = "Color used for the text" },
		default = { r = 0, g = 0.259, b = 1 }
	}, bgColor2 = {
		name = "Background Color",
		tooltips = { short = "Color used for the outline/shadow" },
		default = { r = 1, g = 1, b = 1 }
	},
	--   Stacking
	xOffset = {
		name = "X Offset",
		tooltips = { long = "Offsets non-notes by this amount horizontally visually in the editor when stacked", short = "Visual x offset between stacked events" },
		default = 4,
		off = 0
	}, yOffset = {
		name = "Y Offset",
		tooltips = { long = "Offsets non-notes by this amount vertically visually in the editor when stacked", short = "Visual y offset between stacked events" },
		default = 4,
		off = 0
	}, alpha = {
		name = "Alpha",
		tooltips = { long = "Draws non-notes with this opacity when stacked\n(1 = opaque)", short = "Opacity of stacked events" },
		default = 0.5,
		off = 1
	}, stackingNotes = {
		name = "Stacked Notes",
		tooltips = { short = "Mark stacked gameplay" },
		default = true,
		off = false
	},

	-- Features
	--   Metadata
	browserCharter = {
		name = "Charter in Browser",
		tooltips = { short = "Ability to edit the charter credited in the browser" },
		default = true,
		off = false
	}, charter = {
		name = "Default Charter",
		tooltips = { long = "The name that will be automatically set when creating a new level or variant", short = "Default name for a new variant" },
		default = "Me"
	},
	--   Adjustments
	dragThreshhold = {
		name = "Drag Threshhold",
		tooltips = { long = "Distance you need to move your mouse to initiate dragging", short = "Start event drag after distance" },
		default = 5,
		off = 10
	}, roundSelectedTimes = {
		name = "Round Event Time",
		tooltips = { short = "Rounds selected event times to the third decimal" },
		default = false,
		off = false
	},
	--   Features
	deleteNothing = {
		name = "Quick Deselect",
		tooltips = { long = "Right click nothing to select \"None\" in the event palette", short = "Right click nothing to deselect placable event" },
		default = true,
		off = false
	}, saveAngleBeatSnap = {
		name = "Save Angle/Beat Snap",
		tooltips = { short = "Save angle/beat snap between editor sessions" },
		default = true,
		off = false
	}, angleDefault = {
		name = "Angle Snap",
		tooltips = { long = "Default index for the angle snap list\nStarts from 1 which is the first entry of the list till the length of the list\nDefaults to the custom angle snap if invalid", short = "Default index for the angle snap list" },
		default = 3,
		off = 3
	}, customAngleDefault = {
		name = "Custom Angle",
		tooltips = { short = "Default custom angle snap" },
		default = 32,
		off = 32
	}, beatDefault = {
		name = "Beat Snap",
		tooltips = { long = "Default index for the beat snap list\nStarts from 1 which is the first entry of the list till the length of the list\nDefaults to the custom beat snap if invalid", short = "Default index for the beat snap list" },
		default = 2,
		off = 2
	}, customBeatDefault = {
		name = "Custom Beat",
		tooltips = { short = "Default custon beat snap" },
		default = 16,
		off = 16
	}, angleSnapValues = {
		name = "Angle List",
		tooltips = { short = "Cycle between these angle snap values" },
		default = { 8, 12, 16, 24, 32 },
		off = { 8, 12, 16, 24, 32 }
	}, beatSnapValues = {
		name = "Beat List",
		tooltips = { short = "Cycle between these beat snap values" },
		default = { 1, 2, 3, 4, 6, 8, 12, 16 },
		off = { 1, 2, 3, 4, 6, 8, 12, 16 }
	}, betterMoveSelection = {
		name = "Better Move Selection",
		tooltips = { long = "Moving the selection also takes the end angle into account", short = "Support for end angle" },
		default = true,
		off = false
	}, betterUntagging = {
		name = "Better Untagging",
		tooltips = { long = "Untagging also takes angle2 and end angle into account\nThis is not default behavior for unmodded", short = "Support for angle2 and end angle" },
		default = true,
		off = false
	}, fakeRepeat = {
		name = "Fake Repeat",
		tooltips = { long = "Adds a fake repeat option by updating hidden events, which are visible when unmodded, making it basically compatible\nReminder to convert repeated events instead of trying to edit them with this option off because when it's on again, they may auto update, losing your progress", short = "Fakes a unmodded-compatible repeat option for non ease events" },
		default = true,
		off = false
	}, ignoreUntagPrompt = {
		name = "Ignore Untag Prompt",
		tooltips = { long = "Ignore the prompt that appears to confirm untagging all tags with the same name as the selected one (short: untag same tag name) and instead immediately untag the same tags", short = "Auto-confirm the prompt for untagging same tags" },
		default = false
	}, groupTimeDifference = {
		name = "Group Time Diff",
		tooltips = { long = "Grouped changes (that get undone/redone in one ctrl button press) have this much time difference to the next change in seconds", short = "Minimum time difference for a undo/redo change group to form" },
		default = 0.5
	}, spreadSnap = {
		name = "Spread Snap",
		tooltips = { long = "The angle snap that events will try to spread at when the button for it is pressed", short = "Angle snap events will try to spread to" },
		default = 32
	}, spreadType = {
		name = "Spread Type",
		tooltips = { short = "How events get spread" },
		values = { "around", "clockwise", "counterclockwise", "absolute" },
		valueTooltips = {
			{ short = "Around original angle" },
			{ short = "Clockwise to original angle" },
			{ short = "Counterclockwise to original angle" },
			{ short = "Clockwise to angle 0" }
		},
		default = "around"
	}, showEventGroups = {
		name = "Event Groups",
		tooltips = { short = "Adjust visibility of different events by grouping them together" },
		default = true,
		off = false
	},
	--   Buttons
	untaggingButtons = {
		name = "(Un)Tagging Buttons",
		tooltips = { long = "Buttons to tag the selected event or untag the current selected tag or all tags with the same name as the selected one (short: untag same tag name)", short = "Buttons for tagging/untagging" },
		default = true,
		off = false
	}, spreadButtons = {
		name = "Spread Buttons",
		tooltips = { long = "Button to spread the overlapping events you've selected" },
		default = true,
		off = false
	}, mouseCoordsButton = {
		name = "Mouse Coords Button",
		tooltips = { short = "Button to copy coordinates of mouse to parameter" },
		default = true,
		off = false
	},
	--   Hotkeys
	selectNoneInPalette = {
		name = "Deselect Hotkey",
		tooltips = { long = "Hotkey to select \"None\" in the event palette (n)", short = "n" },
		default = true,
		off = false
	}, hideMenus = {
		name = "Hide Menus Hotkey",
		tooltips = { long= "Hotkey to toggle hiding the editor menus (h)", short = "Hotkey to hide editor menus" },
		default = true,
		off = false
	}, restartInPlaytest = {
		name = "Restart In Playtest",
		tooltips = { long = "Hotkey to restart to the begin of playtest (restart hotkey)", short = "restart hotkey" },
		default = true,
		off = false
	}, undoHotkeys = {
		name = "Undo Hotkeys",
		tooltips = { long = "Hotkeys to undo (z) / redo (shift + z) single or multiple (ctrl) changes close in time to each other", short = "(ctrl) + (shift) + z" },
		default = true,
		off = false
	}, untaggingHotkeys = {
		name = "(Un)Tagging Hotkeys",
		tooltips = { long = "Hotkeys to tag selected events (t),\nuntag selected events (shift + t) or\nuntag all tags with same tag as the selected ones (ctrl + t)", short = "(ctrl) + (shift) + t" },
		default = true,
		off = false
	}, selectAll = {
		name = "Select All",
		tooltips = { long = "Hotkey to select all events (ctrl + a)", short = "Hotkey to select all events" },
		default = true,
		off = false
	}, jumpEvents = {
		name = "Jump To Events",
		tooltips = { long = "Hotkeys to jump to the next/previous selected events (ctrl + up/down arrow)", short = "ctrl + up/down arrow" },
		default = true,
		off = false
	},

	-- newer options i couldnt be bothered to sort, especially after the config menu got reordered and i didnt reorder it in this file
	damoclismCataclism = {
		name = "Damoclism Cataclism",
		tooltips = { short = "Forces the gimmick from Damoclism on all levels" },
		default = false,
		off = false
	}, bookmarkList = {
		name = "Bookmark List",
		tooltips = { short = "Lists all bookmarks of a level" },
		default = true,
		off = false
	}, sillyNisenenGimmick = {
		name = "Nisenen Gimmick",
		tooltips = { short = "Show the hidden event parameter" },
		default = true,
		off = false
	}, bounceDragging = {
		name = "Bounce Dragging",
		tooltips = { short = "Drag bounces like holds" },
		default = true,
		off = false
	}, bounceDoubleClick = {
		name = "Bounce Amount Dragging",
		tooltips = { short = "Double click to adjust bounce amount through dragging" },
		default = true,
		off = false
	}, speedScrolling = {
		name = "Speed Scrolling",
		tooltips = { short = "Removes cooldown when scrolling some menus" },
		default = true,
		off = false
	}, autoFixSides = {
		name = "Fix Sides",
		tooltips = { short = "Normalizes the angle of sides in any level you edit" },
		default = false,
		off = false
	},

	-- Internal Variables (as a replacement instead of using global variables)
	keysWhiteList = {
		name = "[internal] keysWhiteList",
		default = {
			repeats = "rep",
			repeatDelay = "delay",
			var = true,
			pitch = "ptch",
			voidColor = "void",
			drawLayer = "dLayer",
			tap = true,
			id = true,
			file = true,
			description = "desc",
			enabled = "on",
			spriteName = "sprName",
			sx = true,
			sy = true,
			time = true,
			objectName = "obj",
			duration = "dur",
			a = true,
			paddles = "pdls",
			ox = true,
			color = "col",
			kx = true,
			ky = true,
			newWidth = "nWidth",
			newAngle = "nAngle",
			enable = "on",
			intensity = "inten",
			reps = true,
			startTap = "stTap",
			endTap = true,
			value = "val",
			x = true,
			y = true,
			recolor = "col",
			paddle = "pdl",
			effectCanvas = "fxCanv",
			type = true,
			tickRate = "tickR",
			sprite = "spr",
			chance = true,
			sound = true,
			tag = true,
			parentid = "par",
			g = true,
			block = "blk",
			drawOrder = "dOrd",
			segments = "seg",
			outline = "outl",
			hide = true,
			orbit = true,
			angle2 = "ang2",
			endAngle = "endAng",
			spinEase = "spEase",
			r = true,
			mine = true,
			offset = "off",
			doDithering = "dither",
			rotationinfluence = "rotInf",
			miss = true,
			effectCanvasRaw = "fxCanvR",
			delay = true,
			order = "ord",
			ease = true,
			angleOffset = "angOff",
			volume = "vol",
			mineHold = "mineH",
			holdEase = "ease",
			start = true,
			name = true,
			b = true,
			bpm = true,
			speedMult = "spdMlt",
			oy = true,
			angle = "ang",
			traceEase = "trEase",
			side = true,
			variableName = "var"
		}
	}, confirmationTexts = {
		name = "[internal] confirmationTexts",
		default = {
			"Confirm",
			"Accept",
			"Yes",
			"Yeah",
			"Ye",
			"Sure",
			"True",
			"Positive",
			"Okay",
			"Ok",
			"Do it",
			"Ready",
			"Yippee!"
		}
	}, eventGroups = { -- Penta: lingering code from when event groups were saved in the mod config. this is still needed though
		name = "[internal] eventGroups",
		default = {
			all = {
				events = { bookmark = true, tag = true, paddles = true, play = true, setBPM = true, showResults = true, block = true, extraTap = true, hold = true, inverse = true, mine = true, mineHold = true, side = true, deco = true, ease = true, forcePlayerSprite = true, hom = true, noise = true, outline = true, playSound = true, setBgColor = true, setBoolean = true, setColor = true, toggleParticles = true --[[EA events]], advancetextdeco = true, aft = true, easeSequence = true, retime = true, songNameOverride = true, textdeco = true, bounce = true, setBounceHeight = true },
				visibility = "show", index = 0
			},
			gameplay = {
				events = { paddles = true, block = true, extraTap = true, hold = true, inverse = true, mine = true, mineHold = true, side = true --[[EA events]], bounce = true, setBounceHeight = true },
				visibility = " - ", index = 1
			},
			song = {
				events = { play = true, setBPM = true, showResults = true, playSound = true --[[EA events]], retime = true },
				visibility = " - ", index = 1
			},
			visuals = {
				events = { deco = true, ease = true, forcePlayerSprite = true, hom = true, noise = true, outline = true, setBgColor = true, setBoolean = true, setColor = true, toggleParticles = true --[[EA events]], advancetextdeco = true, aft = true, easeSequence = true, songNameOverride = true, textdeco = true },
				visibility = " - ", index = 1
			},
			color = {
				events = { hom = true, noise = true, outline = true, setBgColor = true, setColor = true },
				visibility = " - ", index = 2
			},
			bookmarks = {
				events = { bookmark = true },
				visibility = " - ", index = 3
			},
			tags = {
				events = { tag = true },
				visibility = " - ", index = 3
			},
			deco = {
				events = { deco = true, advancetextdeco = true, textdeco = true },
				visibility = " - ", index = 3
			},
			eases = {
				events = { ease = true, setBoolean = true, easeSequence = true },
				visibility = " - ", index = 3
			}
		}
	}
}