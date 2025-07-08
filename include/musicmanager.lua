local musicmanager = {
    sources = {},
    currentId = nil
}

--- Loads a music source and associates it with an ID.
-- If a source with the same ID exists, it is stopped and replaced.
-- @param id string Identifier for the music track.
-- @param filepath string Path to the audio file.
-- @param mode string? Playback mode, either "stream" (default) or "static".
function musicmanager.load(id, filepath, mode)
    mode = mode or "stream"
    if musicmanager.sources[id] then
        musicmanager.sources[id]:stop()
        musicmanager.sources[id] = nil
    end
    musicmanager.sources[id] = love.audio.newSource(filepath, mode)
end

--- Plays the music associated with the given ID.
-- Stops any currently playing music? No, it only sets currentId.
-- @param id string Identifier of the music track to play.
-- @param loop boolean? Whether the music should loop (default false).
-- @return boolean True if the music was found and played, false otherwise.
function musicmanager.play(id, loop)
    local source = musicmanager.sources[id]
    if not source then return false end
    musicmanager.currentId = id
    source:setLooping(loop or false)
    source:play()
    return true
end

--- Stops the music associated with the given ID.
-- Clears currentId if it matches the stopped music.
-- @param id string Identifier of the music track to stop.
function musicmanager.stop(id)
    local source = musicmanager.sources[id]
    if source then
        source:stop()
        if musicmanager.currentId == id then
            musicmanager.currentId = nil
        end
    end
end

--- Pauses the music associated with the given ID.
-- Does nothing if the music is not playing.
-- @param id string Identifier of the music track to pause.
function musicmanager.pause(id)
    local source = musicmanager.sources[id]
    if source and source:isPlaying() then
        source:pause()
    end
end

--- Resumes the music associated with the given ID if it is paused.
-- Does nothing if the music is already playing or doesn't exist.
-- @param id string Identifier of the music track to resume.
function musicmanager.resume(id)
    local source = musicmanager.sources[id]
    if source and not source:isPlaying() then
        source:play()
    end
end

--- Checks if the music associated with the given ID is currently playing.
-- @param id string Identifier of the music track to check.
-- @return boolean True if the music is playing, false otherwise.
function musicmanager.isPlaying(id)
    local source = musicmanager.sources[id]
    if source then
        return source:isPlaying()
    end
    return false
end

--- Returns the ID of the currently playing music, or nil if none.
-- @return string|nil The current music ID.
function musicmanager.getCurrent()
    return musicmanager.currentId
end

return musicmanager
