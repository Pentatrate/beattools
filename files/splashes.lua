local realSplashes = splashes
local splashes = {}

function splashes.imgui()
	if mod.config.splashTextWindow and beattools.splashes and cs.name == "Menu" and TheFunnyIsActivated and savedata.aprilFools.titleSplash and realSplashes then
		helpers.SetNextWindowPos(298,35,'ImGuiCond_FirstUseEver')
		helpers.SetNextWindowSize(616,650,'ImGuiCond_FirstUseEver')
		mod.config.splashTextWindow = imgui.Begin("Splash Texts##beattools", true)

		local configHelpers = utilitools.configHelpers
		configHelpers.setMod(mod)

		configHelpers.input("moreSplashes")
		imgui.Text("Disclaimer: Disabling will only remove splashes added by Beattools\nSplashes added by ExtraStuff will remain")

		if imgui.Button("Generate Random") then
			cs.splash = realSplashes.gen()
		end

		if not beattools.splashes.cache or beattools.splashes.cache ~= #beattools.splashes.total then
			beattools.splashes.cache = #beattools.splashes.total
			beattools.splashes.categories = {}
			beattools.splashes.categoriesSorted = {}
			beattools.splashes.totalCache = {}
			beattools.splashes.totalCategories = {}

			local function getVanilla(splash)
				for _, splash2 in ipairs(beattools.splashes.added) do
					if splash == splash2 then
						return true
					end
				end
				for _, splash2 in ipairs(beattools.splashes.crankless) do
					if splash == splash2 then
						return true
					end
				end
				for _, splash2 in ipairs(beattools.splashes.crankful) do
					if splash == splash2 then
						return true
					end
				end
				for _, splash2 in ipairs(beattools.splashes.rg_nods) do
					if splash == splash2 then
						return true
					end
				end
				return false
			end
			local function getIndex(splash)
				for i, splash2 in ipairs(beattools.splashes.total) do
					if splash == splash2 then
						return i + 2
					end
				end
				for i, splash2 in ipairs(beattools.splashes.additional) do
					if splash == splash2 then
						return i + 2 + #beattools.splashes.total
					end
				end
			end
			local function insertSplash(splash, category, forceVanilla, forceIndex)
				if not beattools.splashes.categories[category] then
					table.insert(beattools.splashes.totalCategories, category)
				end
				beattools.splashes.categories[category] = beattools.splashes.categories[category] or {}
				beattools.splashes.categoriesSorted[category] = beattools.splashes.categoriesSorted[category] or {}

				if beattools.splashes.totalCache[splash] then
					-- if category ~= "added" then modlog(mod, "duplicate splash?", splash, category, beattools.splashes.totalCache[splash]) end
					return -- duplicate
				end
				local vanilla, index = forceVanilla or getVanilla(splash), forceIndex or getIndex(splash)
				beattools.splashes.totalCache[splash] = category
				beattools.splashes.categories[category][splash] = { vanilla = vanilla, index = index }
				table.insert(beattools.splashes.categoriesSorted[category], splash)
			end
			local function insertSplashes(table, category, forceVanilla, forceIndex)
				for _, splash in ipairs(table) do
					insertSplash(splash, category, forceVanilla, forceIndex)
				end
			end

			insertSplashes(beattools.splashes.regular, "Regular Splashes")
			insertSplashes(beattools.splashes.crankless, "Crankless Splashes")
			insertSplashes(beattools.splashes.crankful, "Crankful Splashes")
			insertSplashes(beattools.splashes.rg_nods, "Rhythm Game Nods")
			insertSplashes(beattools.splashes.added, "Otherwise Added Splashes")
			insertSplashes(beattools.splashes.additional, "More Splashes (Beattools)")
			insertSplashes(beattools.splashes.total, "Other Modded Splashes (likely ExtraStuff)")

			insertSplash("There are actually " .. (#beattools.splashes.total + #beattools.splashes.additional + 2) .. " total modded and vanilla splashes! Collect them all!", "More Splashes (Beattools)", false, 1)
			insertSplash("[colour=2]You found the shiny splash text!", "Otherwise Added Splashes", true, 2)

			for category, array in pairs(beattools.splashes.categoriesSorted) do
				table.sort(array, function(a, b)
					local dataA = beattools.splashes.categories[category][a]
					local dataB = beattools.splashes.categories[category][b]
					if (not dataA.index) ~= (not dataB.index) then
						return not dataB.index
					end
					if not dataA.index then
						return a < b
					end
					return dataA.index < dataB.index
				end)
			end
		end

		for _, category in ipairs(beattools.splashes.totalCategories) do
			imgui.SeparatorText(category .. "##beattoolsSplashText")
			for _, splash in ipairs(beattools.splashes.categoriesSorted[category]) do
				local data = beattools.splashes.categories[category][splash]
				local index = data.index
				if not mod.config.moreSplashes and index then
					if index > 2 + #beattools.splashes.total or index < 2 then
						index = nil
					else
						index = index - 1
					end
				end

				imgui.Text((index and "Nr. " .. index or "Not in splash pool") .. (data.vanilla and " (Vanilla)" or " (Modded)"))
				imgui.SameLine()
				if imgui.Button(tostring(splash)) then
					if realSplashes.gen then
						cs.splash = realSplashes.gen(index or splash)
					end
				end
			end
		end

		imgui.End()
	end
end

if beattools and beattools.splashes then
	beattools.splashes.cache = nil
end

return splashes