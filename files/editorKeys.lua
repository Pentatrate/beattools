return {
	testKey3 = function() utilitools.try(mod, function()
	end) end,
	recordPosition = function()
		if cs.editMode and beattoolsRecordPosition and beattoolsRecordFunc then
			if beattoolsRecordFunc then beattoolsRecordFunc(helpers.round(mouse.rx / beattoolsRecordPrecision) * beattoolsRecordPrecision, helpers.round(mouse.ry / beattoolsRecordPrecision) * beattoolsRecordPrecision) end
			_G.beattoolsRecordPosition = false
			_G.beattoolsRecordFunc = nil
			_G.beattoolsRecordPrecision = 1
		end
	end,
	selectNone = function()
		if cs.placeEvent ~= "" then
			cs.placeEvent = ""
		end
	end,
	tagSelection = function()
		-- tag selection
		if (cs.multiselect or cs.selectedEvent) and (not maininput:down("shift")) and (not maininput:down("ctrl")) then
			cs.changeToTagDialogue = true
			cs.newTagName = ''
		end
		-- untag single tag
		if maininput:down("shift") and (not maininput:down("ctrl")) then
			if cs.selectedEvent then
				cs:beattoolsUntag({ cs.selectedEvent })
			elseif cs.multiselect then
				cs:beattoolsUntag(cs.multiselect.events)
			end
		end
		-- untag same tags
		if maininput:down("ctrl") and (not maininput:down("shift")) then
			if cs.selectedEvent then
				if mods.beattools.config.ignoreUntagPrompt then cs:beattoolsUntag({ cs.selectedEvent.tag }) return end
				utilitools.prompts.confirm("Continuing will untag all tags with the tag name \"" .. cs.selectedEvent.tag .. "\"!", function ()
					cs:beattoolsUntag({ cs.selectedEvent.tag })
				end)
			elseif cs.multiselect then
				local tempEvents = {}
				for i, v in ipairs(cs.multiselect.events) do
					if v.type == "tag" then table.insert(tempEvents, v.tag) end
				end
				if mods.beattools.config.ignoreUntagPrompt then cs:beattoolsUntag(tempEvents) return end
				utilitools.prompts.confirm("Continuing will untag all tags with the same name as those in the selection!", function ()
					cs:beattoolsUntag(tempEvents)
				end)
			end
		end
	end,
	selectAll = function()
		cs:newMulti()
		cs.multiselectStartBeat = nil
		cs.multiselectEndBeat = nil
		for i, event in ipairs(cs.level.events) do
			table.insert(cs.multiselect.events, event)
		end
		for i, event in ipairs(cs.multiselect.events) do
			cs.multiselect.eventTypes[event.type] = true
			if cs.multiselectStartBeat == nil then cs.multiselectStartBeat, cs.multiselectEndBeat = event.time, event.time end
			if cs.multiselectStartBeat > event.time then cs.multiselectStartBeat = event.time end
			if cs.multiselectEndBeat < event.time then cs.multiselectEndBeat = event.time end
		end
		if cs.multiselectStartBeat == nil then
			cs.multiselectStartBeat = 0
			cs.multiselectEndBeat = 360
		end
	end,
	undo = function() utilitools.files.beattools.undo.keybind() end,
	hideMenus = function()
		if not beattoolsRecordFunc then
			modlog(mod, "lol")
			_G.beattoolsRecordPosition = not beattoolsRecordPosition
			_G.beattoolsRecordFunc = nil
		end
	end
}