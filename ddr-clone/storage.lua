local storage = {
    -- Define file paths for different types of data
    paths = {
        keyMappings = "config/key_mappings.lua"
    }
}

-- Create required directories if they don't exist
function storage.init()
    love.filesystem.createDirectory("assets")
    love.filesystem.createDirectory("songs")
    love.filesystem.createDirectory("config")
    print("Save directory: " .. love.filesystem.getSaveDirectory())
end

-- Generic save function for any data
function storage.save(key, data)
    if key == "keyMappings" then
        -- Create serialize function
        local function serializeTable(tbl)
            local result = "return {"
            for k, v in pairs(tbl) do
                if type(k) == "string" then
                    result = result .. string.format("%q", k) .. "="
                else
                    result = result .. "[" .. k .. "]="
                end
                
                if type(v) == "string" then
                    result = result .. string.format("%q", v)
                else
                    result = result .. tostring(v)
                end
                result = result .. ","
            end
            return result .. "}"
        end
        
        -- Save key mappings
        local success = love.filesystem.write(storage.paths.keyMappings, serializeTable(data))
        if not success then
            print("Failed to save key mappings")
            return false
        end
        return true
    end
    return false
end

-- Generic load function for any data
function storage.load(key)
    if key == "keyMappings" then
        if love.filesystem.getInfo(storage.paths.keyMappings) then
            -- Load the mappings file content
            local content = love.filesystem.read(storage.paths.keyMappings)
            if content then
                -- Create a temporary file to load the mappings
                local tempPath = "config/temp_mappings.lua"
                love.filesystem.write(tempPath, content)
                
                -- Try to load the mappings
                local success, mappings = pcall(require, tempPath:sub(1, -5))
                
                -- Clean up temporary file
                love.filesystem.remove(tempPath)
                
                if success then
                    return mappings
                else
                    print("Failed to load key mappings")
                    print("Error: " .. tostring(mappings))
                end
            end
        end
        return nil
    end
    return nil
end

-- Load all custom songs from save directory
function storage.loadCustomSongs()
    local customSongs = {}
    
    if not love.filesystem.getInfo("songs") then
        return customSongs
    end
    
    local items = love.filesystem.getDirectoryItems("songs")
    for _, dir in ipairs(items) do
        if dir:match("^custom_") then
            local patternPath = "songs/" .. dir .. "/pattern.lua"
            if love.filesystem.getInfo(patternPath) then
                -- Load the pattern file content
                local content = love.filesystem.read(patternPath)
                if content then
                    -- Create a temporary file to load the pattern
                    local tempPath = "songs/" .. dir .. "/temp_pattern.lua"
                    love.filesystem.write(tempPath, content)
                    
                    -- Try to load the pattern
                    local success, pattern = pcall(require, tempPath:sub(1, -5))
                    if success then
                        -- Update audio path to use save directory for custom songs
                        if pattern.audio:match("^assets/") then
                            pattern.audio = love.filesystem.getSaveDirectory() .. "/" .. pattern.audio
                        end
                        
                        -- Try to load the audio file
                        local success, source = pcall(love.audio.newSource, pattern.audio, "stream")
                        if success then
                            pattern.music = source
                            table.insert(customSongs, pattern)
                            print("Loaded custom song: " .. pattern.name)
                        else
                            print("Failed to load audio for song: " .. pattern.name)
                            print("Audio path: " .. pattern.audio)
                        end
                    else
                        print("Failed to load pattern: " .. patternPath)
                        print("Error: " .. tostring(pattern))
                    end
                    
                    -- Clean up temporary file
                    love.filesystem.remove(tempPath)
                end
            end
        end
    end
    
    return customSongs
end

-- Save a new custom song
function storage.saveCustomSong(songName, audioData, pattern)
    -- Save audio file
    local audioPath = "assets/" .. songName .. ".mp3"
    local success = love.filesystem.write(audioPath, audioData)
    if not success then
        print("Failed to save audio file")
        return false
    end
    
    -- Create pattern directory
    local timestamp = os.time()
    local songDir = "songs/custom_" .. timestamp
    love.filesystem.createDirectory(songDir)
    
    -- Update pattern with audio path
    pattern.audio = audioPath
    
    -- Create serialize function with proper recursion
    local function serializeTable(tbl)
        local result = "{"
        for k, v in pairs(tbl) do
            if type(k) == "string" then
                result = result .. k .. " = "
            else
                result = result .. "[" .. k .. "] = "
            end
            
            if type(v) == "table" then
                result = result .. serializeTable(v)
            elseif type(v) == "string" then
                result = result .. string.format("%q", v)
            else
                result = result .. tostring(v)
            end
            result = result .. ","
        end
        return result .. "}"
    end
    
    local content = "return " .. serializeTable(pattern)
    success = love.filesystem.write(songDir .. "/pattern.lua", content)
    if not success then
        print("Failed to save pattern file")
        return false
    end
    
    return true
end

return storage
