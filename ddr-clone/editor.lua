local storage = require('storage')
local gameState = require('game_state')
local songManager = require('song_manager')
local gameplay = require('gameplay')
local gameUI = require('game_ui')

-- Use gameState.editor for state to ensure sync
local function getEditorState()
    return gameState.editor
end

local targetArrows = gameplay.createTargetArrows()
local arrowColors = gameplay.createArrowColors()

-- Simple active key tracking
local activeKeys = {
    left = false,
    down = false,
    up = false,
    right = false
}

local status = {
    message = "",
    time = 0
}

local countdown = {
    active = false,
    time = 0
}

local function setStatus(message, duration)
    status.message = message
    status.time = duration or 3
end

local function silenceAllMusic()
    if gameState.menuMusic then gameState.menuMusic:stop() end
    if getEditorState().currentMusic then getEditorState().currentMusic:stop() end
    if gameState.currentSong and gameState.currentSong.music then gameState.currentSong.music:stop() end
    for _, song in ipairs(songManager.getSongs()) do
        if song.music then song.music:stop() end
    end
end

local function drawInstructions()
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setFont(gameState.fonts.small)
    local instructions = {
        "How to create a beatmap:",
        "1. Drag and drop an MP3 file here",
        "2. Press SPACE to start recording (3s countdown)",
        "3. Press arrow keys in time with the music",
        "4. Press SPACE to finish recording",
        "Press ESC to cancel anytime"
    }
    
    local y = 50
    for _, line in ipairs(instructions) do
        love.graphics.printf(line, 50, y, love.graphics.getWidth() - 100, "left")
        y = y + 25
    end
end

local function drawEditor()
    local editor = getEditorState()
    
    -- Draw gameplay background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    if not editor.recording then
        -- Show initial setup screen
        love.graphics.setColor(gameState.colors.ui)
        love.graphics.setFont(gameState.fonts.title)
        love.graphics.printf("Beat Map Editor", 0, 50, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(gameState.fonts.medium)
        if editor.currentMusic then
            love.graphics.printf("Current song: " .. editor.songName, 0, 150, love.graphics.getWidth(), "center")
            love.graphics.printf("Audio loaded successfully!", 0, 200, love.graphics.getWidth(), "center")
            love.graphics.printf("Press SPACE when ready to record", 0, 250, love.graphics.getWidth(), "center")
        else
            love.graphics.printf("Waiting for MP3 file...", 0, 200, love.graphics.getWidth(), "center")
        end
    else
        -- Draw lane effects for active keys
        local laneEffects = {
            left = activeKeys.left and 1 or 0,
            down = activeKeys.down and 1 or 0,
            up = activeKeys.up and 1 or 0,
            right = activeKeys.right and 1 or 0
        }
        gameplay.drawLaneEffects(targetArrows, laneEffects)

        -- Draw target arrows only when key is pressed
        for _, arrow in ipairs(targetArrows) do
            if activeKeys[arrow.direction] then
                gameplay.drawArrow(
                    arrow.x, 
                    arrow.y, 
                    arrow.direction, 
                    true, 
                    arrowColors, 
                    1, 
                    1, 
                    1  -- Full glow when pressed
                )
            end
        end

        -- Draw placed arrows
        for _, arrow in ipairs(editor.arrows) do
            local y = arrow.y or (love.graphics.getHeight() - (editor.currentTime - arrow.time) * 400)
            if y > 0 and y < love.graphics.getHeight() then
                gameplay.drawArrow(
                    gameplay.getArrowXPosition(arrow.direction),
                    y,
                    arrow.direction,
                    false,
                    arrowColors,
                    1,
                    1,
                    0
                )
            end
        end

        -- Draw UI elements
        gameUI.drawProgressBar(editor.currentTime, editor.currentMusic:getDuration(), gameState.colors)
        
        -- Draw recording status
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("● RECORDING", 0, 20, love.graphics.getWidth(), "center")
        
        -- Draw time
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(string.format("Time: %.2f", editor.currentTime), 0, 60, love.graphics.getWidth(), "center")
    end

    -- Draw countdown if active
    if countdown.active then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(gameState.fonts.title)
        love.graphics.printf(math.ceil(countdown.time), 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("Get ready!", 0, love.graphics.getHeight()/2 + 50, love.graphics.getWidth(), "center")
    end
    
    -- Draw status message if active
    if status.message ~= "" and status.time > 0 then
        love.graphics.setColor(1, 1, 0, math.min(1, status.time))
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf(status.message, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
    end
end

local function startRecording()
    local editor = getEditorState()
    if not editor.currentMusic then return end
    
    silenceAllMusic()
    countdown.active = true
    countdown.time = 3
    editor.recording = false
    editor.currentTime = 0
    editor.arrows = {}
    setStatus("Recording will start in 3 seconds...", 3)
end

local function stopRecording()
    local editor = getEditorState()
    editor.recording = false
    countdown.active = false
    if editor.currentMusic then editor.currentMusic:stop() end
    
    if #editor.arrows == 0 then
        setStatus("No arrows recorded, returning to menu...", 2)
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
    table.sort(editor.arrows, function(a, b) return a.time < b.time end)
    
    -- Create and save pattern
    local pattern = {
        name = editor.songName,
        difficulty = "Custom",
        bpm = 120,
        arrows = editor.arrows
    }
    
    if storage.saveCustomSong(editor.songName, editor.audioData, pattern) then
        pattern.audio = love.filesystem.getSaveDirectory() .. "/assets/" .. editor.songName .. ".mp3"
        pattern.music = editor.currentMusic
        songManager.addSong(pattern)
        setStatus("Beatmap saved successfully!", 2)
    else
        setStatus("Error saving beatmap!", 2)
    end
    
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
    
    gameState.state.current = "mainMenu"
end

local function updateEditor(dt)
    local editor = getEditorState()
    
    -- Update status message
    if status.time > 0 then
        status.time = status.time - dt
        if status.time <= 0 then
            status.message = ""
        end
    end

    if countdown.active then
        countdown.time = countdown.time - dt
        if countdown.time <= 0 then
            countdown.active = false
            editor.recording = true
            editor.currentMusic:play()
            setStatus("Recording started!", 1)
        end
    elseif editor.recording then
        editor.currentTime = editor.currentMusic:tell() -- Use actual music time instead of dt
    end
end

local function handleEditorKeyPress(key)
    local editor = getEditorState()
    
    if key == "left" or key == "down" or key == "up" or key == "right" then
        -- Record time immediately on key press
        if editor.recording then
            local currentTime = editor.currentMusic:tell() -- Get exact music time
            table.insert(editor.arrows, {
                time = currentTime,
                direction = key
            })
        end
        -- Update visual state after recording
        activeKeys[key] = true
    elseif not editor.recording and not countdown.active then
        if key == "space" and editor.currentMusic then
            startRecording()
        elseif key == "escape" then
            gameState.state.current = "mainMenu"
            if editor.currentMusic then editor.currentMusic:stop() end
        end
    elseif editor.recording then
        if key == "space" then
            stopRecording()
        elseif key == "escape" then
            editor.recording = false
            countdown.active = false
            if editor.currentMusic then editor.currentMusic:stop() end
            editor.arrows = {}
            setStatus("Recording cancelled", 2)
        end
    end
end

local function handleEditorKeyRelease(key)
    if key == "left" or key == "down" or key == "up" or key == "right" then
        activeKeys[key] = false
    end
end

return {
    drawEditor = drawEditor,
    updateEditor = updateEditor,
    handleEditorKeyPress = handleEditorKeyPress,
    handleEditorKeyRelease = handleEditorKeyRelease,
    enterEditor = function() 
        silenceAllMusic() 
        setStatus("Welcome to the Beat Map Editor!", 3)
    end
}