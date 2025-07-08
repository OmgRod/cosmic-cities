local musicmanager = {
    sources = {},
    currentId = nil
}

function musicmanager.load(id, filepath, mode)
    mode = mode or "stream"
    if musicmanager.sources[id] then
        musicmanager.sources[id]:stop()
        musicmanager.sources[id] = nil
    end
    musicmanager.sources[id] = love.audio.newSource(filepath, mode)
end

function musicmanager.play(id, loop)
    local source = musicmanager.sources[id]
    if not source then return false end
    musicmanager.currentId = id
    source:setLooping(loop or false)
    source:play()
    return true
end

function musicmanager.stop(id)
    local source = musicmanager.sources[id]
    if source then
        source:stop()
        if musicmanager.currentId == id then
            musicmanager.currentId = nil
        end
    end
end

function musicmanager.pause(id)
    local source = musicmanager.sources[id]
    if source and source:isPlaying() then
        source:pause()
    end
end

function musicmanager.resume(id)
    local source = musicmanager.sources[id]
    if source and not source:isPlaying() then
        source:play()
    end
end

function musicmanager.isPlaying(id)
    local source = musicmanager.sources[id]
    if source then
        return source:isPlaying()
    end
    return false
end

function musicmanager.getCurrent()
    return musicmanager.currentId
end

return musicmanager
