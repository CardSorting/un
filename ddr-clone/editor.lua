local storage = require('storage')
local gameState = require('game_state')
local songManager = require('song_manager')
local gameplay = require('gameplay')
local gameUI = require('game_ui')

-- Hold state tracking
local holdState = {
    left = { active = false, startTime = 0, visible = false },
    down = { active = false, startTime = 0, visible = false },
    up = { active = false, startTime = 0, visible = false },
    right = { active = false, startTime = 0, visible = false }
}

local targetArrows = gameplay.createTargetArrows()
local arrowColors = gameplay.createArrowColors()

local function silenceAllMusic()
    -- Stop menu music
    if gameState.menuMusic then
        gameState.menuMusic:stop()
    end
    
    -- Stop any current editor music
    if gameState.editor.currentMusic then
        gameState.editor.currentMusic:stop()
    end
    
    -- Stop any gameplay music
    if gameState.currentSong and gameState.currentSong.music then
        gameState.currentSong.music:stop()
    end
    
    -- Stop any other potential music sources
    for _, song in ipairs(songManager.getSongs()) do
        if song.music then
            song.music:stop()
        end
    end
end

local function enterEditor()
    silenceAllMusic()
end

local function drawEditor()
    -- Draw gameplay background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    if not gameState.editor.recording then
        -- Show initial setup screen
        love.graphics.setColor(gameState.colors.ui)
        love.graphics.setFont(gameState.fonts.title)
        love.graphics.printf("Beat Map Editor", 0, 50, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("Song: " .. (gameState.editor.songName or "No song selected"), 0, 150, love.graphics.getWidth(), "center")
        if not gameState.editor.songName then
            love.graphics.printf("Drag and drop an MP3 file here", 0, 200, love.graphics.getWidth(), "center")
        else
            if gameState.editor.currentMusic then
                love.graphics.printf("Press Space to start recording", 0, 250, love.graphics.getWidth(), "center")
            else
                love.graphics.setColor(gameState.colors.miss)
                love.graphics.printf("Error loading audio file", 0, 250, love.graphics.getWidth(), "center")
            end
        end
        love.graphics.printf("Press Escape to return to menu", 0, 300, love.graphics.getWidth(), "center")
    else
        -- Draw lane effects only for active/visible lanes
        local laneEffects = {
            left = holdState.left.visible and 1 or 0,
            down = holdState.down.visible and 1 or 0,
            up = holdState.up.visible and 1 or 0,
            right = holdState.right.visible and 1 or 0
        }
        gameplay.drawLaneEffects(targetArrows, laneEffects)

        -- Draw target arrows only when corresponding lane is visible
        for _, arrow in ipairs(targetArrows) do
            if holdState[arrow.direction].visible then
                gameplay.drawArrow(
                    arrow.x, 
                    arrow.y, 
                    arrow.direction, 
                    true, 
                    arrowColors, 
                    1, 
                    1, 
                    arrow.glow
                )
            end
        end

        -- Draw placed arrows
        for _, arrow in ipairs(gameState.editor.arrows) do
            local y = arrow.y or (love.graphics.getHeight() - (gameState.editor.currentTime - arrow.time) * 400)
            if y > 0 and y < love.graphics.getHeight() then
                gameplay.drawArrow(
                    gameplay.getArrowXPosition(arrow.direction),
                    y,
                    arrow.direction,
                    false,
                    arrowColors,
                    1,
                    1,
                    0,
                    arrow.holdLength and true or false,
                    arrow.holdLength,
                    arrow.holdLength and ((y - arrow.y) / (arrow.holdLength * 400)) or nil
                )
            end
        end

        -- Draw UI elements
        gameUI.drawProgressBar(gameState.editor.currentTime, gameState.editor.currentMusic:getDuration(), gameState.colors)
        
        -- Draw recording status
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("RECORDING", 0, 20, love.graphics.getWidth(), "center")
        
        -- Draw controls help
        love.graphics.setFont(gameState.fonts.small)
        love.graphics.setColor(1, 1, 1, 0.6)
        love.graphics.printf("Hold arrows for hold notes • Space to finish • Escape to cancel", 
            0, love.graphics.getHeight() - 30, love.graphics.getWidth(), "center")
        
        -- Draw active hold indicators only for visible lanes
        for direction, state in pairs(holdState) do
            if state.active and state.visible then
                local x = gameplay.getArrowXPosition(direction)
                local holdDuration = gameState.editor.currentTime - state.startTime
                love.graphics.setColor(1, 1, 0, 0.8)
                love.graphics.printf(string.format("%.1fs", holdDuration), 
                    x - 50, love.graphics.getHeight() - 60, 100, "center")
            end
        end
    end
end

local function startRecording()
    if not gameState.editor.currentMusic then
        return
    end
    
    silenceAllMusic() -- Ensure all other music is stopped
    
    gameState.editor.recording = true
    gameState.editor.currentTime = 0
    gameState.editor.arrows = {}
    gameState.editor.currentMusic:play()
    
    -- Reset hold states
    for direction, _ in pairs(holdState) do
        holdState[direction] = { active = false, startTime = 0, visible = false }
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
            holdState[direction] = { active = false, startTime = 0, visible = false }
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
        
        -- Update target arrow glows based on hold states
        for _, arrow in ipairs(targetArrows) do
            if holdState[arrow.direction].active then
                arrow.glow = math.min(1, arrow.glow + dt * 4)
            else
                arrow.glow = math.max(0, arrow.glow - dt * 4)
            end
        end
    end
end

local function handleEditorKeyPress(key)
    if key == "left" or key == "down" or key == "up" or key == "right" then
        -- Always make lane visible when key is pressed
        holdState[key].visible = true
        
        -- Handle recording-specific logic
        if gameState.editor.recording and not holdState[key].active then
            holdState[key].active = true
            holdState[key].startTime = gameState.editor.currentTime
        end
    elseif not gameState.editor.recording then
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
        elseif key == "escape" then
            -- Cancel recording
            gameState.editor.recording = false
            if gameState.editor.currentMusic then
                gameState.editor.currentMusic:stop()
            end
            gameState.editor.arrows = {}
            -- Reset hold states
            for direction, _ in pairs(holdState) do
                holdState[direction] = { active = false, startTime = 0, visible = false }
            end
        end
    end
end

local function handleEditorKeyRelease(key)
    if key == "left" or key == "down" or key == "up" or key == "right" then
        -- Always hide the lane and arrow when key is released
        holdState[key].visible = false
        
        -- Handle recording-specific logic
        if gameState.editor.recording and holdState[key].active then
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
            holdState[key].active = false
            holdState[key].startTime = 0
        end
    end
end

return {
    drawEditor = drawEditor,
    updateEditor = updateEditor,
    handleEditorKeyPress = handleEditorKeyPress,
    handleEditorKeyRelease = handleEditorKeyRelease,
    enterEditor = enterEditor
}