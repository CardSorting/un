local storage = require('storage')

local songManager = {}
local songs = {}

function songManager.init()
    -- Load built-in song patterns
    local builtInSongs = {
        require("songs/song1/pattern"),
        require("songs/song2/pattern"),
        require("songs/song3/pattern"),
        require("songs/song4/pattern")  -- Added song4
    }
    
    -- Load and validate built-in songs
    for _, song in ipairs(builtInSongs) do
        if not song.music then
            local success, source = pcall(love.audio.newSource, song.audio, "stream")
            if success then
                song.music = source
                print("Loaded audio for song: " .. song.name)
                table.insert(songs, song)
            else
                print("Failed to load audio for song: " .. song.name)
                print("Audio path: " .. song.audio)
            end
        end
    end
    
    -- Load custom songs from save directory
    local customSongs = storage.loadCustomSongs()
    for _, song in ipairs(customSongs) do
        if song.music then
            -- Custom song already has music loaded by storage module
            table.insert(songs, song)
        end
    end
end

function songManager.getSongs()
    return songs
end

function songManager.addSong(song)
    -- Only add song if it has valid music
    if song.music then
        table.insert(songs, song)
        return true
    end
    return false
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

-- Clean up any invalid songs
function songManager.cleanup()
    local validSongs = {}
    for _, song in ipairs(songs) do
        if song.music then
            -- Test if the music source is still valid
            local success = pcall(function() 
                song.music:getDuration()
            end)
            if success then
                table.insert(validSongs, song)
            else
                print("Removing invalid song: " .. song.name)
            end
        end
    end
    songs = validSongs
end

-- Remove a specific song
function songManager.removeSong(songName)
    for i = #songs, 1, -1 do
        if songs[i].name == songName then
            if songs[i].music then
                songs[i].music:stop()
            end
            table.remove(songs, i)
            print("Removed song: " .. songName)
            return true
        end
    end
    return false
end

return songManager