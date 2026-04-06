local betterBookmarks = {
	lastProgress = 0,
	lastIndex = 1,
	lastBookmark = {}
}

function betterBookmarks.makeDefault(time)
	local value = utilitools.files.beattools.easing.track.bookmark.default()
	value.time = time
	return value
end
function betterBookmarks.getBookmarks(bookmarkList, currentBookmark, count, smallestBeat, biggestBeat)
	-- we already know current
	local hasPrev = count.index >= 1
	local prevBookmark
	if hasPrev then
		if bookmarkList[count.index - 1] then
			prevBookmark = bookmarkList[count.index - 1].event
		else
			-- using smallest beat instead if there are blocks before the first bookmark
			prevBookmark = betterBookmarks.makeDefault(smallestBeat)
			if currentBookmark.time == prevBookmark.time then
				hasPrev = false
				prevBookmark = nil
			end
		end
	end

	local hasNext = count.index <= count.total
	local nextBookmark
	if hasNext then
		if bookmarkList[count.index + 1] then
			nextBookmark = bookmarkList[count.index + 1].event
		else
			-- using biggest beat instead if there are blocks after the last bookmark
			nextBookmark = betterBookmarks.makeDefault(biggestBeat)
			if currentBookmark.time == nextBookmark.time then
				hasNext = false
				nextBookmark = nil
			end
		end
	end
	return hasPrev, prevBookmark, hasNext, nextBookmark
end
function betterBookmarks.setBookmark(bookmarkList, count, smallestBeat, biggestBeat, index, biggest, loop1, loop2)
	local currentBookmark, hasPrev, prevBookmark, hasNext, nextBookmark
	local function set(i)
		count.index = i
		currentBookmark = bookmarkList[count.index] and bookmarkList[count.index].event or betterBookmarks.makeDefault(biggest and biggestBeat or smallestBeat)
		hasPrev, prevBookmark, hasNext, nextBookmark = betterBookmarks.getBookmarks(bookmarkList, currentBookmark, count, smallestBeat, biggestBeat)
	end

	set(index)
	if not hasNext then
		set(loop1 and 0 or index - 1)
	end

	return currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark
end

function betterBookmarks.getStaticData()
	if not (utilitools.files.beattools.easing.list.bookmark and utilitools.files.beattools.easing.list.bookmark["_"] and utilitools.files.beattools.easing.list.bookmark["_"]["_"]) then modlog(mod, "returning4") return end

	local bookmarkList = utilitools.files.beattools.easing.list.bookmark["_"]["_"]
	local smallestBeat = (utilitools.files.beattools.biggestBeat.min or 0) - mods.beattools.config.scrollPast
	local biggestBeat = (utilitools.files.beattools.biggestBeat.max or 0) + mods.beattools.config.scrollPast

	return bookmarkList, smallestBeat, biggestBeat
end
function betterBookmarks.getBookmarkData()
	local bookmarkList, smallestBeat, biggestBeat = betterBookmarks.getStaticData()
	if not bookmarkList then modlog(mod, "returning3") return end

	local time = cs.editorBeat
	time = math.max(time, smallestBeat)
	time = math.min(time, biggestBeat)

	-- get last bookmark of the current beat
	local currentBookmark, count = utilitools.files.beattools.easing.getEase("bookmark", nil, time, nil, nil)
	count = helpers.copy(count)
	local hasPrev, prevBookmark, hasNext, nextBookmark
	currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark = betterBookmarks.setBookmark(bookmarkList, count, smallestBeat, biggestBeat, count.index, false)

	-- get the real current bookmark if multiple bookmarks are on the same beat
	if currentBookmark.time == time then
		local overlapping = false
		if hasPrev and prevBookmark then
			overlapping = prevBookmark.time == currentBookmark.time
		end
		if not overlapping and hasNext and nextBookmark then
			overlapping = nextBookmark.time == currentBookmark.time
		end
		if overlapping and bookmarkList[betterBookmarks.lastIndex] and bookmarkList[betterBookmarks.lastIndex].event.time == currentBookmark.time then
			currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark = betterBookmarks.setBookmark(bookmarkList, count, smallestBeat, biggestBeat, betterBookmarks.lastIndex, false)
		end
	end

	-- current progress
	local currentProgress = hasNext and nextBookmark and (
		nextBookmark.time - currentBookmark.time ~= 0 and (
			(time - currentBookmark.time) / (nextBookmark.time - currentBookmark.time)
		) or (betterBookmarks.lastBookmark.time == currentBookmark.time and betterBookmarks.lastProgress or 0) -- two bookmarks on the same beat
	) or 1 -- you are on the last beat of the level, i dont think this is possible though

	return bookmarkList, smallestBeat, biggestBeat, time, currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark, currentProgress
end

function betterBookmarks.calc()
	-- Penta: the bookmark code is so confusing ill just write my own
	-- :crankless:

	local bookmarkList, smallestBeat, biggestBeat, time, currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark, currentProgress = betterBookmarks.getBookmarkData()
	if not bookmarkList or not currentBookmark or not count or not currentProgress then modlog(mod, "returning2") return end

	-- get mouse progress
	local mX = mouse.rx - project.res.cx
	local mY = mouse.ry - project.res.cy
	local mouseProgress = (0.5 + math.atan2(-mX, mY) / (2 * math.pi)) % 1
	if math.min(mouseProgress, 1 - mouseProgress) * 360 < 10 then
		mouseProgress = 0
	end

	-- finally we check if a flip has happened
	if math.abs(mouseProgress - currentProgress) > 0.5 then
		-- flipped
		if mouseProgress >= 0.5 then
			-- backwards
			if hasPrev and prevBookmark then
				currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark = betterBookmarks.setBookmark(bookmarkList, count, smallestBeat, biggestBeat, count.index - 1, false)
			else
				-- loop around
				currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark = betterBookmarks.setBookmark(bookmarkList, count, smallestBeat, biggestBeat, count.total, false)
			end
		else
			-- forwards
			if hasNext and nextBookmark then
				currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark = betterBookmarks.setBookmark(bookmarkList, count, smallestBeat, biggestBeat, count.index + 1, false, true)
			else
				-- loop around
				currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark = betterBookmarks.setBookmark(bookmarkList, count, smallestBeat, biggestBeat, 0, false, true)
			end
		end
	end

	-- set the beat
	cs.editorBeat = currentBookmark.time + (hasNext and nextBookmark and (nextBookmark.time - currentBookmark.time) * mouseProgress or 0)

	-- saving values for next frame
	betterBookmarks.lastProgress = mouseProgress
	betterBookmarks.lastIndex = count.index
	betterBookmarks.lastBookmark = currentBookmark
end

function betterBookmarks.getProgress()
	-- Penta: the bookmark code is so confusing ill just write my own
	-- :crankless:

	local bookmarkList, smallestBeat, biggestBeat, time, currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark, currentProgress = betterBookmarks.getBookmarkData()
	if not bookmarkList or not currentBookmark or not count or not currentProgress then
		modlog(mod, "returning")
		return
	end

	-- saving values for next frame
	betterBookmarks.lastProgress = currentProgress
	betterBookmarks.lastIndex = count.index
	betterBookmarks.lastBookmark = currentBookmark

	return currentBookmark, count, hasPrev, prevBookmark, hasNext, nextBookmark, currentProgress
end

return betterBookmarks