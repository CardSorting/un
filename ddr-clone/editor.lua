local storage = require('storage')
local gameState = require('game_state')
local songManager = require('song_manager')
local gameplay = require('gameplay')
local editorUI = require('editor_ui')

local targetArrows = gameplay.createTargetArrows()
local arrowColors = gameplay.createArrowColors()

-- Simple active key tracking
local activeKeys = {
    left = false,
    down = false,
    up = false,
    right = false
}

local function silenceAllMusic()
    if gameState.menuMusic then gameState.menuMusic:stop() end
    if gameState.editor.currentMusic then gameState.editor.currentMusic:stop() end
    if gameState.currentSong and gameState.currentSong.music then gameState.currentSong.music:stop() end
    for _, song in ipairs(songManager.getSongs()) do
        if song.music then song.music:stop() end
    end
end

local function setStatus(message, duration)
    gameState.editor.status = {
        message = message,
        time = duration or 3
    }
end

local function startRecording()
    local editor = gameState.editor
    if not editor.currentMusic then return end
    
    silenceAllMusic()
    editor.countdown = 3
    editor.recording = false
    editor.currentTime = 0
    editor.arrows = {}
    editorUI.reset()
    setStatus("Get ready to record!", 3)
end

local function stopRecording()
    local editor = gameState.editor
    editor.recording = false
    editor.countdown = 0
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
            audioData = nil,
            countdown = 0,
            status = { message = "", time = 0 }
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
        audioData = nil,
        countdown = 0,
        status = { message = "", time = 0 }
    }
    
    gameState.state.current = "mainMenu"
end

local function updateEditor(dt)
    local editor = gameState.editor
    
    -- Update status message
    if editor.status.time > 0 then
        editor.status.time = editor.status.time - dt
        if editor.status.time <= 0 then
            editor.status.message = ""
        end
    end

    -- Update countdown
    if editor.countdown > 0 then
        editor.countdown = editor.countdown - dt
        if editor.countdown <= 0 then
            editor.countdown = 0
            editor.recording = true
            editor.currentMusic:play()
            setStatus("Recording started!", 1)
        end
    elseif editor.recording then
        editor.currentTime = editor.currentMusic:tell() -- Use actual music time
    end

    -- Update UI
    editorUI.update(dt)
end

local function handleEditorKeyPress(key)
    local editor = gameState.editor
    
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
    elseif not editor.recording and editor.countdown == 0 then
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
            editor.countdown = 0
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

local function drawEditor()
    editorUI.draw(activeKeys, targetArrows, arrowColors)
end

local function enterEditor()
    silenceAllMusic()
    gameState.editor.status = { message = "", time = 0 }
    gameState.editor.countdown = 0
    setStatus("Welcome to the Beat Map Editor!", 3)
end

return {
    drawEditor = drawEditor,
    updateEditor = updateEditor,
    handleEditorKeyPress = handleEditorKeyPress,
    handleEditorKeyRelease = handleEditorKeyRelease,
    enterEditor = enterEditor
}