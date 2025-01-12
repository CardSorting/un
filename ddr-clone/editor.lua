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

local function drawSetupOverlay()
    local editor = getEditorState()
    if editor.recording then return end

    -- Full screen semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Center content vertically and horizontally
    local contentWidth = 600
    local contentX = (love.graphics.getWidth() - contentWidth) / 2
    local contentY = love.graphics.getHeight() * 0.2
    local spacing = 40

    -- Draw title
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.setFont(gameState.fonts.title)
    love.graphics.printf("BEAT MAP EDITOR", 0, contentY, love.graphics.getWidth(), "center")
    contentY = contentY + spacing * 2

    -- Draw current step
    local currentStep
    if not editor.songName then
        currentStep = "STEP 1/3: Load Song"
    else
        currentStep = "STEP 2/3: Prepare Recording"
    end
    
    love.graphics.setColor(0.3, 1, 0.3, 1)
    love.graphics.setFont(gameState.fonts.medium)
    love.graphics.printf(currentStep, 0, contentY, love.graphics.getWidth(), "center")
    contentY = contentY + spacing * 2

    -- Draw instructions based on current step
    love.graphics.setFont(gameState.fonts.medium)
    if not editor.songName then
        -- Step 1 instructions
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("To begin creating your beatmap:", 0, contentY, love.graphics.getWidth(), "center")
        contentY = contentY + spacing

        local steps = {
            "1. Locate your MP3 file",
            "2. Drag and drop it into this window",
            "3. Wait for audio to load"
        }

        love.graphics.setColor(0.8, 0.8, 1, 1)
        for _, step in ipairs(steps) do
            love.graphics.printf(step, 0, contentY, love.graphics.getWidth(), "center")
            contentY = contentY + spacing
        end

        -- Only show ESC instruction in step 1
        love.graphics.setColor(1, 0.5, 0.5, 1)
        love.graphics.printf("Press ESC to return to menu", 0, love.graphics.getHeight() - spacing * 2, love.graphics.getWidth(), "center")
    else
        -- Step 2 instructions
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf("Audio Loaded: " .. editor.songName, 0, contentY, love.graphics.getWidth(), "center")
        contentY = contentY + spacing * 2

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Recording Process:", 0, contentY, love.graphics.getWidth(), "center")
        contentY = contentY + spacing

        local steps = {
            "1. Press SPACE to begin countdown",
            "2. Music will start automatically",
            "3. Press arrow keys to place notes",
            "4. Notes appear where arrows light up",
            "5. Press SPACE to finish recording",
            "6. Press ESC to cancel anytime"
        }

        love.graphics.setColor(0.8, 0.8, 1, 1)
        for _, step in ipairs(steps) do
            love.graphics.printf(step, 0, contentY, love.graphics.getWidth(), "center")
            contentY = contentY + spacing
        end

        contentY = contentY + spacing
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf("Ready? Press SPACE to start!", 0, contentY, love.graphics.getWidth(), "center")
    end
end

local function drawEditor()
    local editor = getEditorState()
    
    -- Draw gameplay background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    if editor.recording then
        -- Draw top banner
        love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 40)
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("● RECORDING: " .. editor.songName .. string.format(" (%.1fs)", editor.currentTime), 
            0, 10, love.graphics.getWidth(), "center")

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
    else
        -- Draw setup overlay for steps 1 and 2
        drawSetupOverlay()
    end

    -- Draw countdown if active
    if countdown.active then
        -- Dim the screen
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Draw countdown
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(gameState.fonts.title)
        love.graphics.printf(math.ceil(countdown.time), 0, love.graphics.getHeight()/2 - 100, love.graphics.getWidth(), "center")
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("Get ready!", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
        love.graphics.printf("Press arrow keys in time with the music", 0, love.graphics.getHeight()/2 + 50, love.graphics.getWidth(), "center")
    end
    
    -- Draw status message if active
    if status.message ~= "" and status.time > 0 then
        -- Draw status background
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 60, love.graphics.getWidth(), 40)
        
        love.graphics.setColor(1, 1, 0, math.min(1, status.time))
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf(status.message, 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")
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
    setStatus("Get ready to record!", 3)
end

local function stopRecording()
    local editor = getEditorState()
    editor.recording = false
    countdown.active = false
    if editor.currentMusic then editor.currentMusic:stop() end
    
    if #editor.arrows == 0 then
        setStatus("No notes recorded, returning to menu...", 2)
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
        setStatus("Beatmap saved successfully! (" .. #editor.arrows .. " notes)", 2)
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
        editor.currentTime = editor.currentMusic:tell() -- Use actual music time
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

local function enterEditor()
    silenceAllMusic()
    setStatus("Welcome to the Beat Map Editor!", 3)
end

-- Return the module with all functions
return {
    drawEditor = drawEditor,
    updateEditor = updateEditor,
    handleEditorKeyPress = handleEditorKeyPress,
    handleEditorKeyRelease = handleEditorKeyRelease,
    enterEditor = enterEditor
}