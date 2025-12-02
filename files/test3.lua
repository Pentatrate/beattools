utilitools.try(mod, function()

	-- utilitools.request("https://raw.githubusercontent.com/Pentatrate/beattools/refs/heads/main/mod.json")
	local ignoreFiles = { [".git"] = true, [".gitignore"] = true, [".vscode"] = true, [".lovelyignore"] = true, [".nolovelyignore"] = true, ["config.json"] = true, unused = true }
	local function recursiveCopy(to, from, ignore)
		for i, fileName in ipairs(love.filesystem.getDirectoryItems(from)) do
			local toFile = to .. "/" .. fileName
			local fromFile = from .. "/" .. fileName
			local fromFileInfo = love.filesystem.getInfo(fromFile)
			if fromFileInfo and (not ignore or not ignoreFiles[fileName]) then
				if fromFileInfo.type == "file" then
					local fromFileData = love.filesystem.read("data", fromFile)
					love.filesystem.write(toFile, fromFileData)
				elseif fromFileInfo.type == "directory" then
					love.filesystem.createDirectory(toFile)
					helpers.recursiveFolderCopy(toFile, fromFile)
				end
			end
		end
	end
	local function recursiveDelete(path, ignore)
		for _, fileName in ipairs(love.filesystem.getDirectoryItems(path)) do
			local filePath = path .. "/" .. fileName
			local fileInfo = love.filesystem.getInfo(filePath)
			if fileInfo and (not ignore or not ignoreFiles[fileName]) then
				if fileInfo.type == "file" then
					forceprint("deleting " .. filePath)
					love.filesystem.remove(filePath)
				elseif fileInfo.type == "directory" then
					recursiveDelete(filePath)
				end
			end
		end
		forceprint("deleting " .. path)
		return love.filesystem.remove(path)
	end
	local function recursiveCompare(path, path2, ignore, prints)
		if love.filesystem.getInfo(path) == nil then if prints then forceprint("No directory: " .. tostring(path)) end return false end
		if love.filesystem.getInfo(path2) == nil then if prints then forceprint("No directory: " .. tostring(path2)) end return false end

		for _, fileName in ipairs(love.filesystem.getDirectoryItems(path)) do
			local filePath = path .. "/" .. fileName
			local fileInfo = love.filesystem.getInfo(filePath)
			local filePath2 = path2 .. "/" .. fileName
			local fileInfo2 = love.filesystem.getInfo(filePath2)
			if fileInfo and (not ignore or not ignoreFiles[fileName]) then
				if fileInfo2 == nil then if prints then forceprint("No file: " .. tostring(filePath2)) end return false end
				if fileInfo.type ~= fileInfo2.type then if prints then forceprint("Different file types: " .. tostring(fileInfo.type) .. " " .. tostring(fileInfo2.type)) end return false end

				if fileInfo.type == "file" then
					local content, size = love.filesystem.read(filePath)
					local content2, size2 = love.filesystem.read(filePath2)
					if content ~= content2 then if prints then forceprint("Different file content: " .. tostring(filePath) .. " (" .. size .. ") " .. tostring(filePath2) .. " (" .. size2 .. ")\n\n||" .. content .. "||\n\n||" .. content2 .. "||") end return false end
				elseif fileInfo.type == "directory" then
					return recursiveCompare(filePath, filePath2)
				end
			end
		end
		return true
	end
	local function downloadMod(mod, url)
		local rawData = utilitools.request(url)
		local fileData = love.filesystem.newFileData(rawData, "modZip.zip")

		forceprint("Mount success: " .. tostring(love.filesystem.mount(fileData, "modZip")))

		for _, fileName in pairs(love.filesystem.getDirectoryItems("modZip")) do
			local path = beatblockPlus2_0Update and mod.path or mods.utilitools.config.modPath .. "/" .. mod.id
			forceprint("Same content: " .. tostring(recursiveCompare(path, "modZip/" .. fileName, true)))
			forceprint("Same content: " .. tostring(recursiveCompare("modZip/" .. fileName, path, true)))
			forceprint("Delete success: " .. tostring(recursiveDelete(path, true)))
			recursiveCopy(path, "modZip/" .. fileName, true)
			break
		end

		forceprint("Unmount success: " .. tostring(love.filesystem.unmount("modZip.zip")))
	end
	-- downloadMod(mods.utilitools, "https://github.com/Pentatrate/utilitools/archive/refs/heads/main.zip")
	downloadMod(mods.themeable, "https://github.com/ImPurplez/Themeable/archive/refs/heads/main.zip")
	-- downloadMod(mods.themeable, "https://github.com/ImPurplez/Themeable/releases/download/v1.3.1/themeable.v1.3.1.zip")
	--https://github.com/ImPurplez/Themeable/releases/latest

end)