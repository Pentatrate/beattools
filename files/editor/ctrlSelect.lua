local ctrlSelect = {}

function ctrlSelect.init(st)
	function st:beattoolsCtrlSelect(event, force)
		if not mods.beattools.config.ctrlSelect and not force then return end
		self.ctrlSelectPending = false
		self.deletePending = false
		local singleSelected = (not self.lastSelected and self.selectedEvent) or (type(self.lastSelected) == "table" and self.lastSelected) -- could be false as well, not just nil

		local selected = {}
		local selectedAmount = 0
		local selectedTypeAmount = 0
		local selectedMin
		local selectedMax
		local function addToLastSelected(event2, index)
			selected[tostring(event2)] = { event = event2, index = index }
			selectedAmount = selectedAmount + 1
			if event.type == event2.type then selectedTypeAmount = selectedTypeAmount + 1 end
			if event ~= event2 then
				selectedMin = selectedMin and math.min(selectedMin, event2.time) or event2.time
				selectedMax = selectedMax and math.max(selectedMax, event2.time) or event2.time
			end
		end
		if self.multiselect then
			for i, event2 in ipairs(self.multiselect.events) do
				addToLastSelected(event2, i)
			end
		elseif singleSelected then
			addToLastSelected(singleSelected)
		end

		if selected[tostring(event)] then
			local index = selected[tostring(event)].index
			if index then -- multiselect
				table.remove(self.multiselect.events, index)
				self.multiselectStartBeat = event.time == self.multiselectStartBeat and selectedMin or self.multiselectStartBeat
				self.multiselectEndBeat = event.time == self.multiselectEndBeat and selectedMax or self.multiselectEndBeat
				selectedTypeAmount = selectedTypeAmount - 1
				if selectedTypeAmount <= 0 then
					self.multiselect.eventTypes[event.type] = nil
					selectedTypeAmount = 0
				end
				selectedAmount = selectedAmount - 1
				if selectedAmount == 0 then
					self:noSelection()
					selectedTypeAmount = 0
				end
			else -- single event
				self:noSelection()
				selectedAmount = 0
				selectedTypeAmount = 0
			end
		else
			local function addToMultiselect(event2)
				table.insert(self.multiselect.events, event2)
				self.multiselect.eventTypes[event2.type] = true
				self.multiselectStartBeat = self.multiselectStartBeat and math.min(self.multiselectStartBeat, event2.time) or event2.time
				self.multiselectEndBeat = self.multiselectEndBeat and math.max(self.multiselectEndBeat, event2.time) or event2.time
				selected[tostring(event2)] = { event = event2, index = #self.multiselect.events }
				selectedAmount = selectedAmount + 1
				if event.type == event2.type then selectedTypeAmount = selectedTypeAmount + 1 end
			end
			if not self.multiselect then
				self:newMulti()
				self.multiselectStartBeat = nil
				self.multiselectEndBeat = nil
				selectedAmount = 0
				selectedTypeAmount = 0
				for _, data in pairs(selected) do
					if not data.index then addToMultiselect(data.event) end
					modlog(mod, "added single to multi")
				end
			end
			addToMultiselect(event)
		end

		if mods.beattools.config.convertSingle and selectedAmount == 1 and #self.markers == 0 then
			local event2 = self.multiselect.events[1]
			self:noSelection()
			self.selectedEvent = event2
		end
	end
end

return ctrlSelect