local storage = require('storage')
local gameState = require('game_state')
local songManager = require('song_manager')

local function drawEditor()
    -- Draw background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(gameState.colors.ui)

    -- Draw title
    love.graphics.setFont(gameState.fonts.title)
    love.graphics.printf("Beat Map Editor", 0, 50, love.graphics.getWidth(), "center")

    -- Draw editor interface
    love.graphics.setFont(gameState.fonts.medium)
    if not gameState.editor.recording then
        -- Show initial setup screen
        love.graphics.printf("Song: " .. (gameState.editor.songName or "No song selected"), 0, 150, love.graphics.getWidth(), "center")
        if not gameState.editor.songName then
            love.graphics.printf("Drag and drop an MP3 file here", 0, 200, love.graphics.getWidth(), "center")
        else
            if gameState.editor.currentMusic then
                love.graphics.printf("Press Space to start recording", 0, 250, love.graphics.getWidth(), "center")
            else
                love.graphics.setColor(gameState.colors.miss)
                love.graphics.printf("Error loading audio file", 0, 250, love.graphics.getWidth(), "center")
                love.graphics.setColor(gameState.colors.ui)
            end
        end
        love.graphics.printf("Press Escape to return to menu", 0, 300, love.graphics.getWidth(), "center")
    else
        -- Show recording interface
        love.graphics.printf("Recording...", 0, 150, love.graphics.getWidth(), "center")
        love.graphics.printf(string.format("Time: %.2f", gameState.editor.currentTime), 0, 200, love.graphics.getWidth(), "center")
        love.graphics.printf("Press arrow keys to place arrows", 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Space to finish", 0, 300, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Escape to cancel", 0, 330, love.graphics.getWidth(), "center")
        
        -- Draw placed arrows (show last 10 for visibility)
        local startIdx = math.max(1, #gameState.editor.arrows - 9)
        for i = startIdx, #gameState.editor.arrows do
            local arrow = gameState.editor.arrows[i]
            local y = 350 + (i - startIdx) * 30
            love.graphics.printf(arrow.direction .. " at " .. string.format("%.2f", arrow.time), 0, y, love.graphics.getWidth(), "center")
        end
    end
end

local function startRecording()
    if not gameState.editor.currentMusic then
        return
    end
    
    gameState.editor.recording = true
    gameState.editor.currentTime = 0
    gameState.editor.arrows = {}
    gameState.editor.currentMusic:play()
end

local function stopRecording()
    gameState.editor.recording = false
    if gameState.editor.currentMusic then
        gameState.editor.currentMusic:stop()
    end
    
    if #gameState.editor.arrows == 0 then
        -- Don't save if no arrows were placed
        gameState.editor = {
            recording = false,
            currentTime = 0,
            arrows = {},
            songName = nil,
            audioPath = nil,
            currentMusic = nil,
            audioData = nil
        }
        gameState.state.current = "mainMenu"
        return
    end
    
    -- Sort arrows by time
    table.sort(gameState.editor.arrows, function(a, b) return a.time < b.time end)
    
    -- Create pattern
    local pattern = {
        name = gameState.editor.songName,
        difficulty = "Custom",
        bpm = 120, -- Default BPM
        arrows = gameState.editor.arrows
    }
    
    -- Save the custom song using storage module
    local success = storage.saveCustomSong(gameState.editor.songName, gameState.editor.audioData, pattern)
    if not success then
        print("Failed to save custom song")
        return
    end
    
    -- Add to songs list
    pattern.audio = love.filesystem.getSaveDirectory() .. "/assets/" .. gameState.editor.songName .. ".mp3"
    pattern.music = gameState.editor.currentMusic
    songManager.addSong(pattern)
    
    -- Reset editor state
    gameState.editor = {
        recording = false,
        currentTime = 0,
        arrows = {},
        songName = nil,
        audioPath = nil,
        currentMusic = nil,
        audioData = nil
    }
    
    -- Return to menu
    gameState.state.current = "mainMenu"
end

local function updateEditor(dt)
    if gameState.editor.recording then
        gameState.editor.currentTime = gameState.editor.currentTime + dt
    end
end

local function handleEditorKeyPress(key)
    if not gameState.editor.recording then
        if key == "space" and gameState.editor.songName and gameState.editor.currentMusic then
            startRecording()
        elseif key == "escape" then
            gameState.state.current = "mainMenu"
            if gameState.editor.currentMusic then
                gameState.editor.currentMusic:stop()
            end
        end
    else
        if key == "space" then
            stopRecording()
        elseif key == "left" or key == "down" or key == "up" or key == "right" then
            table.insert(gameState.editor.arrows, {
                time = gameState.editor.currentTime,
                direction = key
            })
        elseif key == "escape" then
            -- Cancel recording
            gameState.editor.recording = false
            if gameState.editor.currentMusic then
                gameState.editor.currentMusic:stop()
            end
            gameState.editor.arrows = {}
        end
    end
end

return {
    drawEditor = drawEditor,
    updateEditor = updateEditor,
    handleEditorKeyPress = handleEditorKeyPress
}