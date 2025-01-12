local storage = require('storage')
local gameState = require('game_state')
local songManager = require('song_manager')

-- Hold state tracking
local holdState = {
    left = { active = false, startTime = 0 },
    down = { active = false, startTime = 0 },
    up = { active = false, startTime = 0 },
    right = { active = false, startTime = 0 }
}

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
        -- Show recording interface with hold instructions
        love.graphics.printf("Recording...", 0, 150, love.graphics.getWidth(), "center")
        love.graphics.printf(string.format("Time: %.2f", gameState.editor.currentTime), 0, 200, love.graphics.getWidth(), "center")
        love.graphics.printf("Press arrow keys to place arrows", 0, 230, love.graphics.getWidth(), "center")
        love.graphics.printf("Hold arrow keys for hold notes", 0, 260, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Space to finish", 0, 290, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Escape to cancel", 0, 320, love.graphics.getWidth(), "center")
        
        -- Draw active holds status
        love.graphics.setFont(gameState.fonts.small)
        local holdY = 350
        for direction, state in pairs(holdState) do
            if state.active then
                local holdDuration = gameState.editor.currentTime - state.startTime
                love.graphics.setColor(1, 1, 0, 1) -- Highlight active holds
                love.graphics.printf(string.format("Holding %s: %.2fs", direction, holdDuration), 
                    0, holdY, love.graphics.getWidth(), "center")
                holdY = holdY + 25
            end
        end
        
        -- Draw placed arrows (show last 8 for visibility)
        love.graphics.setColor(gameState.colors.ui)
        local startIdx = math.max(1, #gameState.editor.arrows - 7)
        for i = startIdx, #gameState.editor.arrows do
            local arrow = gameState.editor.arrows[i]
            local y = holdY + (i - startIdx) * 30
            local text = arrow.direction
            if arrow.holdLength then
                text = text .. string.format(" hold for %.2fs", arrow.holdLength)
            end
            text = text .. string.format(" at %.2fs", arrow.time)
            love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
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
    
    -- Reset hold states
    for direction, _ in pairs(holdState) do
        holdState[direction] = { active = false, startTime = 0 }
    end
end

local function stopRecording()
    gameState.editor.recording = false
    if gameState.editor.currentMusic then
        gameState.editor.currentMusic:stop()
    end
    
    -- Finish any active holds
    for direction, state in pairs(holdState) do
        if state.active then
            local holdLength = gameState.editor.currentTime - state.startTime
            table.insert(gameState.editor.arrows, {
                time = state.startTime,
                direction = direction,
                holdLength = holdLength
            })
            holdState[direction] = { active = false, startTime = 0 }
        end
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
            -- Start hold tracking
            if not holdState[key].active then
                holdState[key] = { active = true, startTime = gameState.editor.currentTime }
            end
        elseif key == "escape" then
            -- Cancel recording
            gameState.editor.recording = false
            if gameState.editor.currentMusic then
                gameState.editor.currentMusic:stop()
            end
            gameState.editor.arrows = {}
            -- Reset hold states
            for direction, _ in pairs(holdState) do
                holdState[direction] = { active = false, startTime = 0 }
            end
        end
    end
end

local function handleEditorKeyRelease(key)
    if gameState.editor.recording then
        if key == "left" or key == "down" or key == "up" or key == "right" then
            if holdState[key].active then
                local holdLength = gameState.editor.currentTime - holdState[key].startTime
                if holdLength >= 0.1 then -- Minimum hold duration of 0.1 seconds
                    -- Add hold note
                    table.insert(gameState.editor.arrows, {
                        time = holdState[key].startTime,
                        direction = key,
                        holdLength = holdLength
                    })
                else
                    -- Add regular tap note
                    table.insert(gameState.editor.arrows, {
                        time = holdState[key].startTime,
                        direction = key
                    })
                end
                holdState[key] = { active = false, startTime = 0 }
            end
        end
    end
end

return {
    drawEditor = drawEditor,
    updateEditor = updateEditor,
    handleEditorKeyPress = handleEditorKeyPress,
    handleEditorKeyRelease = handleEditorKeyRelease
}