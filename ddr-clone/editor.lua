local storage = require('storage')

local function drawEditor()
    -- Draw background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(colors.ui)

    -- Draw title
    love.graphics.setFont(fonts.title)
    love.graphics.printf("Beat Map Editor", 0, 50, love.graphics.getWidth(), "center")

    -- Draw editor interface
    love.graphics.setFont(fonts.medium)
    if not editorState.recording then
        -- Show initial setup screen
        love.graphics.printf("Song: " .. (editorState.songName or "No song selected"), 0, 150, love.graphics.getWidth(), "center")
        if not editorState.songName then
            love.graphics.printf("Drag and drop an MP3 file here", 0, 200, love.graphics.getWidth(), "center")
        else
            if editorState.currentMusic then
                love.graphics.printf("Press Space to start recording", 0, 250, love.graphics.getWidth(), "center")
            else
                love.graphics.setColor(colors.miss)
                love.graphics.printf("Error loading audio file", 0, 250, love.graphics.getWidth(), "center")
                love.graphics.setColor(colors.ui)
            end
        end
        love.graphics.printf("Press Escape to return to menu", 0, 300, love.graphics.getWidth(), "center")
    else
        -- Show recording interface
        love.graphics.printf("Recording...", 0, 150, love.graphics.getWidth(), "center")
        love.graphics.printf(string.format("Time: %.2f", editorState.currentTime), 0, 200, love.graphics.getWidth(), "center")
        love.graphics.printf("Press arrow keys to place arrows", 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Space to finish", 0, 300, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Escape to cancel", 0, 330, love.graphics.getWidth(), "center")
        
        -- Draw placed arrows (show last 10 for visibility)
        local startIdx = math.max(1, #editorState.arrows - 9)
        for i = startIdx, #editorState.arrows do
            local arrow = editorState.arrows[i]
            local y = 350 + (i - startIdx) * 30
            love.graphics.printf(arrow.direction .. " at " .. string.format("%.2f", arrow.time), 0, y, love.graphics.getWidth(), "center")
        end
    end
end

local function startRecording()
    if not editorState.currentMusic then
        return
    end
    
    editorState.recording = true
    editorState.currentTime = 0
    editorState.arrows = {}
    editorState.currentMusic:play()
end

local function stopRecording()
    editorState.recording = false
    if editorState.currentMusic then
        editorState.currentMusic:stop()
    end
    
    if #editorState.arrows == 0 then
        -- Don't save if no arrows were placed
        editorState = {
            recording = false,
            currentTime = 0,
            arrows = {},
            songName = nil,
            audioPath = nil,
            currentMusic = nil
        }
        gameState.current = "mainMenu"
        return
    end
    
    -- Sort arrows by time
    table.sort(editorState.arrows, function(a, b) return a.time < b.time end)
    
    -- Create pattern
    local pattern = {
        name = editorState.songName,
        difficulty = "Custom",
        bpm = 120, -- Default BPM
        arrows = editorState.arrows
    }
    
    -- Save the custom song using storage module
    local success = storage.saveCustomSong(editorState.songName, editorState.audioData, pattern)
    if not success then
        print("Failed to save custom song")
        return
    end
    
    -- Add to songs list
    pattern.audio = love.filesystem.getSaveDirectory() .. "/assets/" .. editorState.songName .. ".mp3"
    pattern.music = editorState.currentMusic
    table.insert(songs, pattern)
    
    -- Reset editor state
    editorState = {
        recording = false,
        currentTime = 0,
        arrows = {},
        songName = nil,
        audioPath = nil,
        currentMusic = nil,
        audioData = nil
    }
    
    -- Return to menu
    gameState.current = "mainMenu"
end

local function updateEditor(dt)
    if editorState.recording then
        editorState.currentTime = editorState.currentTime + dt
    end
end

local function handleEditorKeyPress(key)
    if not editorState.recording then
        if key == "space" and editorState.songName and editorState.currentMusic then
            startRecording()
        elseif key == "escape" then
            gameState.current = "mainMenu"
            if editorState.currentMusic then
                editorState.currentMusic:stop()
            end
        end
    else
        if key == "space" then
            stopRecording()
        elseif key == "left" or key == "down" or key == "up" or key == "right" then
            table.insert(editorState.arrows, {
                time = editorState.currentTime,
                direction = key
            })
        elseif key == "escape" then
            -- Cancel recording
            editorState.recording = false
            if editorState.currentMusic then
                editorState.currentMusic:stop()
            end
            editorState.arrows = {}
        end
    end
end

return {
    drawEditor = drawEditor,
    updateEditor = updateEditor,
    handleEditorKeyPress = handleEditorKeyPress
}