return {
	general_fullDescription = {
		long = [[
Editor quality-of-life mod
Should be compatible with all other editor qol mods
For now largest mod with the for now largest configs menu
Level Select:
  Changes song pitch and speed based off of rateMod (code: k4kadu)
  Optionally previews the full song to act as an ingame mp3 player (who uses Spitofy anyways? BB is the best mp3 player)
Gameplay:
  Accessibility option to revert time back to before you lagged (will show in results screen)
  Accuracy bar from the previous subgrade to the next subgrade
Editor:
  Ability to customize basic editor colors and the selection border
  Adjustable zoom limits. Scroll past the beginning of the level
  Saves angle/beat snap (idea: unity)
  Allows custom angle/beat snap defaults/lists for cycling through
  Shows current paddle arrangement in-editor
  Shows color channel's current color (includes easing and loadBeat)
  Show color channels used for bgColor, voidColor, outline, noise, player colors, etc. (idea: unity)
  Also shows the current song name override
  Adds an ease list to see current value of all eases or filter them
  Adds a bookmark list to easily teleport between bookmarks (idea: tunne_123)
  Click on ease or color channel to select event responsible for value or all events setting that var
  Right click on ease or color channel to copy value/hex code (idea: unity)
  Make the input sizes fit the window size or a custom size and cleans the select input
  Replaces the help marker with a tooltip, making more space
  Shows the current forced player sprite in-editor (idea: unity)
  Lively (cranky blinks, falls asleep (Doesnt work in EA!)), is happy when holding the modifier key or >< after playtesting
  Shows beats progressed within the bookmark and a bit more (idea: bean)
  Shows the Nisenen event parameter (idea: crisp_chip)
Event Visuals:
  Marks position of repeated events and eases
  Marks duration of (repeated) events and eases
  Offsets directly overlapping (stacked) non note events
  Also makes them transparent when stacked
  Notes are rendered under non notes. Overlapping note events are marked
  Option to draw notes at endAngle instead (idea: whenpigfly666)
  Set endAngle to angle when toggling it on (idea: piger)
  Can draw some parameter values on events (order, speedMult)
  Marks events that ease the same value
Metadata:
  Edit the total level charter option (idea: _play_)
  Auto-insert a predefined one when creating a variant (idea: _play_)
Buttons:
  Button to spread stacked events (idea: crisp_chip)
  Buttons to (un)tag event(s)
  Button to use mouse coordinates for inputs (idea: crisp_chip)
Features:
  Drag bounces around like holds (idea: crisp_chip)
  Double click and drag to adjust bounce amount (idea: k4kadu)
  Ctrl select (original: k4kadu)
  Fakes an option to repeat events. Compatible with unmodded
  Mod specific confirmation, prompts and error popups (some text by: k4kadu, something4803, irember135)
  Rounds time for all selected events to prevent float inaccuracy
Hotkeys:
  Config Hotkeys
  - "r" to reload the config in the editor
  - "f" to fold all tree nodes but the by default open ones
  During Playtest
  - "restart hotkey" to restart in editor playtest (to the position you started playtesting)
  Undo in Editor:
  - "z" to undo a single change
  - "shift + z" to redo a single change
  - "ctrl + z" to undo multiple changes grouped by time difference
  - "ctrl + shift + z" to redo multiple changes grouped by time difference
  Select in Editor
  - Right click empty space or "n" while placing event to deselect the placable event
	(select "None" in event palette)
  Multiselect in Editor
  - "ctrl + a" to select all events
  - "ctrl + up/down arrow" to snap to the next event
  Tagging in Editor
  - "t" to tag selection
  - "shift + t" to untag a single tag
  - "ctrl + t" to untag same tag name (all tags with the same tag name)

Contributions:
  - Pentatrate: Almost all code
  - K4kadu: Reworking most editor marker images
        Audible Ratemod]],
	},
	general_menuOptions = {
		long =
		"The mod config is designed to be very flexible, accessible in the editor in real time and adjustable for when you need more information or know what you're doing and want to keep it simple",
		short = "Edit the way this menu is displayed and arranged"
	},
	general_advanced = {
		long =
		"Advanced settings the normal user shouldnt need to touch, like controlling compatibility with other mods, lag reduction by setting limits or niche stuff\nThese settings may severely effect lag in larger levels and/or require the user to know what they are doing",
		short = "Advanced settings for compatibility, lag reduction or niche features that require knowledge to use"
	},
	game_visuals = {
		long =
		"Adjust and toggle the additional user interface elements added by this mod (Accuracy Bar) or the custom visuals for vfx-less levels during gameplay",
		short = "Adjust and toggle the modded UI or custom vfx during gameplay"
	},
	game_features = {
		long = "Adjust and toggle new features added by this mod during gameplay",
		short = "Adjust and toggle modded features during gameplay"
	},
	levelSelect_visuals = {
		long =
		"Allows displaying more stats or updates them relative to the game speed and allows displaying incompatible files that are unselectable",
		short = "Allows displaying more stats and incompatible files"
	},
	levelSelect_features = {
		long = "Loads levels dynamically as you scroll or logs duplicate folder names of levels",
		short = "Loads levels as you scroll or logs duplicate folder names"
	},
	editor_visuals_general = {
		long =
		"Visually customize editor colors, zoom, displayed beats, scrolling past the beginning of the level, enhance the bookmark slider and breath life into cranky's face",
		short = "Visually customize editor colors, zoom, scroll limits, the bookmark slider and cranky's face"
	},
	editor_visuals_windows = {
		long = "Toggles for additional windows in the editor that show real time data",
		short = "Toggle additional windows in the editor"
	},
	editor_visuals_tracking = {
		long =
		"Display current values/states for level colors, variables, player sprites, paddles or mouse coordinates in the editor",
		short = "Display current values for level/player variables and colors"
	},
	editor_visuals_markers = {
		long =
		"Visual tweaks in the editor to indicate the positions of repeated eases or events and their duration\nIndicates or draws gameplay at their end angle\nShows an event parameter visually as a number near the event",
		short = "Visually indicate repeated eases or events, their durations, end angle and supported event parameters"
	},
	editor_visuals_stacking = {
		long =
		"Visual tweaks in the editor to indicate gameplay notes or to separate non-notes that are stacked on top of each other with same time and angle while moving their selection hitboxes as well\nEspecially useful when editing levels of other people or merged collabs out of multiple parts",
		short = "Visually indicate or separate events with the same time and angle"
	},
	editor_visuals_UI = {
		long = "Shorten event parameter names, adjust input sizes and behavior or hide help markers",
		short = "Adjust input size behavior, names and help markers"
	},
	editor_features_metadata = {
		long =
		"Adds an additional option in the level properties for the charter that the browser displays and it's default setting when creating a new level",
		short = "Adds an additional option for the charter in the browser"
	},
	editor_features_adjustments = {
		long = "Adjusts existing editor behavior for more intuitive use, mainly for odd beat snaps or including angle2",
		short = "Adjustments to existing editor behavior"
	},
	editor_features_features = {
		long = "New editor behaviors and features added by this mod",
		short = "Newly added features"
	},
	editor_features_buttons = {
		short = "Enable/Disable/Configure button features"
	},
	editor_features_hotkeys = {
		short = "Enable/Disable hotkeys"
	}
}
