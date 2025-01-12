local menu = require('menu')
local ui = require('ui_config')
local gameUI = require('game_ui')
local gameplay = require('gameplay')
local gameOver = require('game_over')
local editor = require('editor')

function love.load()
    -- Create required directories in save directory
    love.filesystem.createDirectory("assets")
    love.filesystem.createDirectory("songs")
    
    -- Print save directory location for debugging
    print("Save directory: " .. love.filesystem.getSaveDirectory())
    
    -- Initialize game state
    gameState = {
        current = "mainMenu",  -- mainMenu, songSelect, game, gameover, editor
        score = 0,
        combo = 0,
        maxCombo = 0,
        health = 100,
        selectedMenuItem = 1,
        selectedSong = 1,
        gameTime = 0,
        nextArrowIndex = 1,
        lastHitRating = nil,
        hitRatingTimer = 0,
        comboScale = 1,
        comboTimer = 0,
        multiplier = 1,
        perfectHits = 0,
        goodHits = 0,
        missedHits = 0,
        stagesCleared = 0,
        totalScore = 0,
        isGameOver = false,
        currentMusic = nil,
        laneEffects = {
            left = 0,
            down = 0,
            up = 0,
            right = 0
        },
        hitEffects = {}
    }
    
    -- Initialize editor state
    editorState = {
        recording = false,
        currentTime = 0,
        arrows = {},
        songName = nil,
        audioPath = nil,
        currentMusic = nil
    }
    
    -- Menu items
    menuItems = {
        {text = "Play", action = function() gameState.current = "songSelect" end},
        {text = "Create Beat Map", action = function() gameState.current = "editor" end},
        {text = "Options", action = function() end},
        {text = "Exit", action = function() love.event.quit() end}
    }
    
    -- Load song patterns
    songs = {
        require("songs/song1/pattern"),
        require("songs/song2/pattern"),
        require("songs/song3/pattern")
    }
    
    -- Load custom songs from save directory if they exist
    if love.filesystem.getInfo("songs") then
        local items = love.filesystem.getDirectoryItems("songs")
        for _, dir in ipairs(items) do
            if dir:match("^custom_") then
                local patternPath = "songs/" .. dir .. "/pattern.lua"
                if love.filesystem.getInfo(patternPath) then
                    local success, pattern = pcall(require, patternPath:sub(1, -5))  -- Remove .lua extension
                    if success then
                        -- Update audio path to use save directory for custom songs
                        if pattern.audio:match("^assets/") then
                            pattern.audio = love.filesystem.getSaveDirectory() .. "/" .. pattern.audio
                        end
                        table.insert(songs, pattern)
                        print("Loaded custom song: " .. pattern.name)
                    else
                        print("Failed to load pattern: " .. patternPath)
                        print("Error: " .. tostring(pattern))
                    end
                end
            end
        end
    end
    
    -- Load song audio files
    for _, song in ipairs(songs) do
        local success, source = pcall(love.audio.newSource, song.audio, "stream")
        if success then
            song.music = source
            print("Loaded audio for song: " .. song.name)
        else
            print("Failed to load audio for song: " .. song.name)
            print("Audio path: " .. song.audio)
            print("Error: " .. tostring(source))
        end
    end
    
    -- Colors
    colors = {
        background = {0.1, 0.1, 0.1},
        ui = {0.9, 0.9, 0.9},
        uiDark = {0.7, 0.7, 0.7},
        health = {0.2, 0.8, 0.2},
        healthLow = {0.8, 0.2, 0.2},
        combo = {1, 0.8, 0.2},
        perfect = {0.3, 1, 0.3},
        good = {0.3, 0.3, 1},
        miss = {1, 0.3, 0.3},
        progress = {0.4, 0.4, 0.4},
        progressFill = {0.6, 0.6, 0.6},
        multiplier = {1, 0.5, 0.8},
        laneEffect = {1, 1, 1, 0.2}
    }
    
    -- Initialize gameplay elements
    arrowColors = gameplay.createArrowColors()
    targetArrows = gameplay.createTargetArrows()
    movingArrows = {}
    
    -- Load fonts
    fonts = {
        title = love.graphics.newFont(48),
        large = love.graphics.newFont(32),
        medium = love.graphics.newFont(24),
        small = love.graphics.newFont(20),
        combo = love.graphics.newFont(36),
        multiplier = love.graphics.newFont(28)
    }
    
    -- Hit detection settings
    hitSettings = {
        threshold = 45,
        perfect = 15
    }
end

function love.update(dt)
    if gameState.current == "game" then
        -- Update game time
        gameState.gameTime = gameState.gameTime + dt
        
        -- Update timers
        if gameState.hitRatingTimer > 0 then
            gameState.hitRatingTimer = gameState.hitRatingTimer - dt
        end
        
        if gameState.comboTimer > 0 then
            gameState.comboTimer = gameState.comboTimer - dt
            gameState.comboScale = 1 + (gameState.comboTimer / 0.1) * 0.5
        end
        
        -- Update effects
        for direction, timer in pairs(gameState.laneEffects) do
            if timer > 0 then
                gameState.laneEffects[direction] = timer - dt
            end
        end
        
        for i = #gameState.hitEffects, 1, -1 do
            local effect = gameState.hitEffects[i]
            effect.timer = effect.timer - dt
            effect.y = effect.y - 100 * dt
            effect.alpha = effect.timer / effect.duration
            if effect.timer <= 0 then
                table.remove(gameState.hitEffects, i)
            end
        end
        
        -- Update arrows
        for i = #movingArrows, 1, -1 do
            local arrow = movingArrows[i]
            arrow.y = arrow.y - (300 * dt)
            
            if arrow.y < 0 then
                table.remove(movingArrows, i)
                gameState.health = math.max(0, gameState.health - 5)
                gameState.combo = 0
                gameState.multiplier = 1
                gameState.missedHits = gameState.missedHits + 1
                gameState.lastHitRating = "Miss"
                gameState.hitRatingTimer = 0.5
            end
        end
        
        -- Update multiplier
        gameState.multiplier = math.min(4, 1 + math.floor(gameState.combo / 10))
        
        -- Spawn new arrows
        local currentSong = songs[gameState.selectedSong]
        while gameState.nextArrowIndex <= #currentSong.arrows do
            local nextArrow = currentSong.arrows[gameState.nextArrowIndex]
            if nextArrow.time <= gameState.gameTime then
                local x = gameplay.getArrowXPosition(nextArrow.direction)
                if x then  -- Make sure we got a valid position
                    table.insert(movingArrows, {
                        x = x,
                        y = ui.gameArea.spawnY,
                        direction = nextArrow.direction,
                        time = nextArrow.time
                    })
                    gameState.nextArrowIndex = gameState.nextArrowIndex + 1
                end
            else
                break
            end
        end
        
        -- Check for song end
        if gameState.nextArrowIndex > #currentSong.arrows and #movingArrows == 0 then
            gameState.stagesCleared = gameState.stagesCleared + 1
            gameState.totalScore = gameState.totalScore + gameState.score
            gameState.isGameOver = gameState.stagesCleared >= 3
            gameState.current = "gameover"
            if gameState.currentMusic then
                gameState.currentMusic:stop()
            end
            gameOver.reset()
        end
        
        if gameState.health <= 0 then
            gameState.isGameOver = true
            gameState.current = "gameover"
            if gameState.currentMusic then
                gameState.currentMusic:stop()
            end
            gameOver.reset()
        end
    elseif gameState.current == "gameover" then
        gameOver.update(dt)
    elseif gameState.current == "editor" then
        editor.updateEditor(dt)
    end
end

function love.draw()
    love.graphics.setBackgroundColor(colors.background)
    
    if gameState.current == "mainMenu" then
        menu.drawMainMenu()
        
    elseif gameState.current == "songSelect" then
        menu.drawSongSelect()
        
    elseif gameState.current == "game" then
        -- Draw gameplay elements
        gameplay.drawLaneEffects(targetArrows, gameState.laneEffects)
        gameplay.drawHitEffects(gameState.hitEffects, colors)
        
        -- Draw arrows
        for _, arrow in ipairs(targetArrows) do
            gameplay.drawArrow(arrow.x, arrow.y, arrow.direction, true, arrowColors)
        end
        
        for _, arrow in ipairs(movingArrows) do
            gameplay.drawArrow(arrow.x, arrow.y, arrow.direction, false, arrowColors)
        end
        
        -- Draw UI elements
        local currentSong = songs[gameState.selectedSong]
        local songLength = currentSong.arrows[#currentSong.arrows].time
        
        gameUI.drawProgressBar(gameState.gameTime, songLength, colors)
        gameUI.drawSongInfo(currentSong.name, colors, fonts)
        gameUI.drawScorePanel(gameState.score, gameState.multiplier, colors, fonts)
        gameUI.drawStatsPanel(gameState, colors, fonts)
        gameUI.drawHealthBar(gameState.health, colors)
        
        if gameState.combo > 0 then
            gameUI.drawCombo(gameState.combo, gameState.comboScale, colors, fonts)
        end
        
        if gameState.hitRatingTimer > 0 then
            gameUI.drawHitRating(gameState.lastHitRating, colors, fonts)
        end
        
    elseif gameState.current == "gameover" then
        -- Draw the gameplay screen in the background with reduced opacity
        love.graphics.setColor(1, 1, 1, 0.3)
        for _, arrow in ipairs(targetArrows) do
            gameplay.drawArrow(arrow.x, arrow.y, arrow.direction, true, arrowColors)
        end
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Draw the animated game over screen
        gameOver.draw(gameState, colors, fonts)
    elseif gameState.current == "editor" then
        editor.drawEditor()
    end
end

function love.keypressed(key)
    if gameState.current == "mainMenu" then
        if key == "up" then
            gameState.selectedMenuItem = math.max(1, gameState.selectedMenuItem - 1)
        elseif key == "down" then
            gameState.selectedMenuItem = math.min(#menuItems, gameState.selectedMenuItem + 1)
        elseif key == "return" then
            menuItems[gameState.selectedMenuItem].action()
            -- Reset stages and total score when starting new game
            gameState.stagesCleared = 0
            gameState.totalScore = 0
        end
        
    elseif gameState.current == "songSelect" then
        if key == "up" then
            gameState.selectedSong = math.max(1, gameState.selectedSong - 1)
        elseif key == "down" then
            gameState.selectedSong = math.min(#songs, gameState.selectedSong + 1)
        elseif key == "return" then
            gameState.current = "game"
            gameState.score = 0
            gameState.combo = 0
            gameState.maxCombo = 0
            gameState.health = 100
            gameState.gameTime = 0
            gameState.nextArrowIndex = 1
            gameState.lastHitRating = nil
            gameState.hitRatingTimer = 0
            gameState.multiplier = 1
            gameState.perfectHits = 0
            gameState.goodHits = 0
            gameState.missedHits = 0
            gameState.hitEffects = {}
            movingArrows = {}
            -- Reset target arrows when starting new game
            targetArrows = gameplay.createTargetArrows()
            -- Start playing the selected song
            if gameState.currentMusic then
                gameState.currentMusic:stop()
            end
            gameState.currentMusic = songs[gameState.selectedSong].music
            gameState.currentMusic:play()
        elseif key == "escape" then
            gameState.current = "mainMenu"
        end
        
    elseif gameState.current == "game" then
        if key == "left" or key == "down" or key == "up" or key == "right" then
            local hit = false
            gameState.laneEffects[key] = 0.1
            
            for i = #movingArrows, 1, -1 do
                local arrow = movingArrows[i]
                if arrow.direction == key and gameplay.isArrowInLane(arrow, key) then
                    local hitResult = gameplay.checkHit(arrow, ui.gameArea.targetY, hitSettings.threshold, hitSettings.perfect)
                    if hitResult then
                        hit = true
                        table.remove(movingArrows, i)
                        
                        if hitResult == "Perfect" then
                            gameState.score = gameState.score + (100 * gameState.multiplier)
                            gameState.perfectHits = gameState.perfectHits + 1
                        else
                            gameState.score = gameState.score + (50 * gameState.multiplier)
                            gameState.goodHits = gameState.goodHits + 1
                        end
                        
                        gameState.combo = gameState.combo + 1
                        gameState.maxCombo = math.max(gameState.maxCombo, gameState.combo)
                        gameState.lastHitRating = hitResult
                        gameState.hitRatingTimer = 0.5
                        gameState.comboTimer = 0.1
                        gameState.comboScale = 1.5
                        
                        table.insert(gameState.hitEffects, gameplay.addHitEffect(arrow.x, arrow.y, hitResult))
                        break
                    end
                end
            end
            
            if not hit then
                gameState.combo = 0
                gameState.multiplier = 1
                gameState.health = math.max(0, gameState.health - 5)
                gameState.missedHits = gameState.missedHits + 1
                gameState.lastHitRating = "Miss"
                gameState.hitRatingTimer = 0.5
            end
        elseif key == "escape" then
            gameState.current = "songSelect"
            if gameState.currentMusic then
                gameState.currentMusic:stop()
            end
        end
        
    elseif gameState.current == "gameover" and key == "r" then
        if gameState.isGameOver then
            gameState.current = "mainMenu"
        else
            gameState.current = "songSelect"
        end
        gameOver.reset()
    elseif gameState.current == "editor" then
        editor.handleEditorKeyPress(key)
    end
end

-- Add file drop handler for the editor
function love.filedropped(file)
    if gameState.current == "editor" then
        local filename = file:getFilename()
        if filename:match("%.mp3$") then
            -- Get the file data
            file:open("r")
            local data = file:read("data")  -- Use "data" mode for binary files
            file:close()
            
            -- Save the file to LÖVE's save directory
            local basename = filename:match("[^/\\]+$")
            local newPath = "assets/" .. basename
            
            -- Debug print
            print("Save directory: " .. love.filesystem.getSaveDirectory())
            print("Attempting to save file: " .. newPath)
            
            -- Write the file
            local success = love.filesystem.write(newPath, data)
            if not success then
                print("Failed to write file to: " .. newPath)
                return
            end
            print("Successfully wrote file")
            
            -- Update editor state
            editorState.songName = basename:match("(.+)%.mp3$")
            editorState.audioPath = newPath
            
            -- Try to load the audio file
            local success, sourceOrError = pcall(function()
                return love.audio.newSource(newPath, "stream")
            end)
            
            if success then
                editorState.currentMusic = sourceOrError
                print("Successfully loaded audio source")
            else
                print("Failed to load audio source: " .. tostring(sourceOrError))
            end
        else
            print("Invalid file type. Please use MP3 format.")
        end
    end
end