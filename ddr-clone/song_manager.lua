local storage = require('storage')

local songManager = {}
local songs = {}

function songManager.init()
    -- Load built-in song patterns
    songs = {
        require("songs/song1/pattern"),
        require("songs/song2/pattern"),
        require("songs/song3/pattern")
    }
    
    -- Load custom songs from save directory
    local customSongs = storage.loadCustomSongs()
    for _, song in ipairs(customSongs) do
        table.insert(songs, song)
    end
    
    -- Load song audio files for built-in songs
    for _, song in ipairs(songs) do
        if not song.music then  -- Only load if not already loaded by storage module
            local success, source = pcall(love.audio.newSource, song.audio, "stream")
            if success then
                song.music = source
                print("Loaded audio for song: " .. song.name)
            else
                print("Failed to load audio for song: " .. song.name)
                print("Audio path: " .. song.audio)
            end
        end
    end
end

function songManager.getSongs()
    return songs
end

function songManager.addSong(song)
    table.insert(songs, song)
end

function songManager.loadAudioFromData(data)
    local success, sourceOrError = pcall(function()
        return love.audio.newSource(love.sound.newSoundData(data), "stream")
    end)
    
    if success then
        print("Successfully loaded audio source")
        return sourceOrError
    else
        print("Failed to load audio source: " .. tostring(sourceOrError))
        return nil
    end
end

function songManager.stopCurrentSong(currentMusic)
    if currentMusic then
        currentMusic:stop()
    end
end

return songManager