local menu = require('menu')
local ui = require('ui_config')
local gameUI = require('game_ui')
local gameplay = require('gameplay')
local gameOver = require('game_over')
local editor = require('editor')
local storage = require('storage')
local gameState = require('game_state')
local songManager = require('song_manager')

function love.load()
    -- Initialize storage and game state first
    storage.init()
    gameState.init()  -- This will initialize fonts and other resources
    
    -- Then initialize song manager which depends on storage
    songManager.init()
    songManager.cleanup() -- Clean up any invalid songs
    
    -- Initialize gameplay elements last
    arrowColors = gameplay.createArrowColors()
    targetArrows = gameplay.createTargetArrows()
    movingArrows = {}
end

function love.update(dt)
    if gameState.state.current == "game" then
        -- Update game time
        gameState.state.gameTime = gameState.state.gameTime + dt
        
        -- Update timers
        if gameState.state.hitRatingTimer > 0 then
            gameState.state.hitRatingTimer = gameState.state.hitRatingTimer - dt
        end
        
        if gameState.state.comboTimer > 0 then
            gameState.state.comboTimer = gameState.state.comboTimer - dt
            gameState.state.comboScale = 1 + (gameState.state.comboTimer / 0.1) * 0.5
        end
        
        -- Update effects
        for direction, timer in pairs(gameState.state.laneEffects) do
            if timer > 0 then
                gameState.state.laneEffects[direction] = timer - dt
            end
        end
        
        for i = #gameState.state.hitEffects, 1, -1 do
            local effect = gameState.state.hitEffects[i]
            effect.timer = effect.timer - dt
            effect.y = effect.y - 100 * dt
            effect.alpha = effect.timer / effect.duration
            if effect.timer <= 0 then
                table.remove(gameState.state.hitEffects, i)
            end
        end
        
        -- Update arrows
        for i = #movingArrows, 1, -1 do
            local arrow = movingArrows[i]
            arrow.y = arrow.y - (300 * dt)
            
            if arrow.y < 0 then
                table.remove(movingArrows, i)
                gameState.state.health = math.max(0, gameState.state.health - 5)
                gameState.state.combo = 0
                gameState.state.multiplier = 1
                gameState.state.missedHits = gameState.state.missedHits + 1
                gameState.state.lastHitRating = "Miss"
                gameState.state.hitRatingTimer = 0.5
            end
        end
        
        -- Update multiplier
        gameState.state.multiplier = math.min(4, 1 + math.floor(gameState.state.combo / 10))
        
        -- Spawn new arrows
        local songs = songManager.getSongs()
        local currentSong = songs[gameState.state.selectedSong]
        while gameState.state.nextArrowIndex <= #currentSong.arrows do
            local nextArrow = currentSong.arrows[gameState.state.nextArrowIndex]
            if nextArrow.time <= gameState.state.gameTime then
                local x = gameplay.getArrowXPosition(nextArrow.direction)
                if x then
                    table.insert(movingArrows, {
                        x = x,
                        y = ui.gameArea.spawnY,
                        direction = nextArrow.direction,
                        time = nextArrow.time
                    })
                    gameState.state.nextArrowIndex = gameState.state.nextArrowIndex + 1
                end
            else
                break
            end
        end
        
        -- Check for song end
        if gameState.state.nextArrowIndex > #currentSong.arrows and #movingArrows == 0 then
            gameState.state.stagesCleared = gameState.state.stagesCleared + 1
            gameState.state.totalScore = gameState.state.totalScore + gameState.state.score
            gameState.state.isGameOver = gameState.state.stagesCleared >= 3
            gameState.state.current = "gameover"
            songManager.stopCurrentSong(gameState.state.currentMusic)
            gameOver.reset()
        end
        
        if gameState.state.health <= 0 then
            gameState.state.isGameOver = true
            gameState.state.current = "gameover"
            songManager.stopCurrentSong(gameState.state.currentMusic)
            gameOver.reset()
        end
    elseif gameState.state.current == "gameover" then
        gameOver.update(dt)
    elseif gameState.state.current == "editor" then
        editor.updateEditor(dt)
    end
end

function love.draw()
    love.graphics.setBackgroundColor(gameState.colors.background)
    
    if gameState.state.current == "mainMenu" then
        menu.drawMainMenu()
    elseif gameState.state.current == "songSelect" then
        menu.drawSongSelect()
    elseif gameState.state.current == "game" then
        -- Draw gameplay elements
        gameplay.drawLaneEffects(targetArrows, gameState.state.laneEffects)
        gameplay.drawHitEffects(gameState.state.hitEffects, gameState.colors)
        
        -- Draw arrows
        for _, arrow in ipairs(targetArrows) do
            gameplay.drawArrow(arrow.x, arrow.y, arrow.direction, true, arrowColors)
        end
        
        for _, arrow in ipairs(movingArrows) do
            gameplay.drawArrow(arrow.x, arrow.y, arrow.direction, false, arrowColors)
        end
        
        -- Draw UI elements
        local songs = songManager.getSongs()
        local currentSong = songs[gameState.state.selectedSong]
        local songLength = currentSong.arrows[#currentSong.arrows].time
        
        gameUI.drawProgressBar(gameState.state.gameTime, songLength, gameState.colors)
        gameUI.drawSongInfo(currentSong.name, gameState.colors, gameState.fonts)
        gameUI.drawScorePanel(gameState.state.score, gameState.state.multiplier, gameState.colors, gameState.fonts)
        gameUI.drawStatsPanel(gameState.state, gameState.colors, gameState.fonts)
        gameUI.drawHealthBar(gameState.state.health, gameState.colors)
        
        if gameState.state.combo > 0 then
            gameUI.drawCombo(gameState.state.combo, gameState.state.comboScale, gameState.colors, gameState.fonts)
        end
        
        if gameState.state.hitRatingTimer > 0 then
            gameUI.drawHitRating(gameState.state.lastHitRating, gameState.colors, gameState.fonts)
        end
    elseif gameState.state.current == "gameover" then
        -- Draw the gameplay screen in the background with reduced opacity
        love.graphics.setColor(1, 1, 1, 0.3)
        for _, arrow in ipairs(targetArrows) do
            gameplay.drawArrow(arrow.x, arrow.y, arrow.direction, true, arrowColors)
        end
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Draw the animated game over screen
        gameOver.draw(gameState.state, gameState.colors, gameState.fonts)
    elseif gameState.state.current == "editor" then
        editor.drawEditor()
    end
end

function love.keypressed(key)
    if gameState.state.current == "mainMenu" then
        if key == "up" then
            gameState.state.selectedMenuItem = math.max(1, gameState.state.selectedMenuItem - 1)
        elseif key == "down" then
            gameState.state.selectedMenuItem = math.min(#gameState.menuItems, gameState.state.selectedMenuItem + 1)
        elseif key == "return" then
            local selectedItem = gameState.menuItems[gameState.state.selectedMenuItem]
            if selectedItem.text == "Create Beat Map" then
                menu.cleanup() -- Clean up menu state before entering editor
                gameState.state.current = "editor"
                editor.enterEditor()
            else
                selectedItem.action()
                gameState.state.stagesCleared = 0
                gameState.state.totalScore = 0
                songManager.cleanup() -- Clean up invalid songs when entering menu
            end
        end
    elseif gameState.state.current == "songSelect" then
        local songs = songManager.getSongs()
        local totalPages = math.ceil(#songs / gameState.state.songsPerPage)
        local startIndex = (gameState.state.currentPage - 1) * gameState.state.songsPerPage + 1
        local endIndex = math.min(startIndex + gameState.state.songsPerPage - 1, #songs)

        if key == "left" then
            if gameState.state.currentPage > 1 then
                gameState.state.currentPage = gameState.state.currentPage - 1
                gameState.state.selectedSong = (gameState.state.currentPage - 1) * gameState.state.songsPerPage + 1
            end
        elseif key == "right" then
            if gameState.state.currentPage < totalPages then
                gameState.state.currentPage = gameState.state.currentPage + 1
                gameState.state.selectedSong = (gameState.state.currentPage - 1) * gameState.state.songsPerPage + 1
            end
        elseif key == "up" then
            if gameState.state.selectedSong > startIndex then
                gameState.state.selectedSong = gameState.state.selectedSong - 1
            end
        elseif key == "down" then
            if gameState.state.selectedSong < endIndex then
                gameState.state.selectedSong = gameState.state.selectedSong + 1
            end
        elseif key == "return" then
            menu.cleanup() -- Clean up menu state before starting game
            gameState.state.current = "game"
            gameState.state.score = 0
            gameState.state.combo = 0
            gameState.state.maxCombo = 0
            gameState.state.health = 100
            gameState.state.gameTime = 0
            gameState.state.nextArrowIndex = 1
            gameState.state.lastHitRating = nil
            gameState.state.hitRatingTimer = 0
            gameState.state.multiplier = 1
            gameState.state.perfectHits = 0
            gameState.state.goodHits = 0
            gameState.state.missedHits = 0
            gameState.state.hitEffects = {}
            movingArrows = {}
            targetArrows = gameplay.createTargetArrows()
            
            -- Start playing the selected song
            songManager.stopCurrentSong(gameState.state.currentMusic)
            gameState.state.currentMusic = songs[gameState.state.selectedSong].music
            gameState.state.currentMusic:play()
        elseif key == "escape" then
            gameState.state.current = "mainMenu"
            songManager.cleanup() -- Clean up invalid songs when returning to menu
        end
    elseif gameState.state.current == "game" then
        if key == "left" or key == "down" or key == "up" or key == "right" then
            local hit = false
            gameState.state.laneEffects[key] = 0.1
            
            for i = #movingArrows, 1, -1 do
                local arrow = movingArrows[i]
                if arrow.direction == key and gameplay.isArrowInLane(arrow, key) then
                    local hitResult = gameplay.checkHit(arrow, ui.gameArea.targetY, gameState.hitSettings.threshold, gameState.hitSettings.perfect)
                    if hitResult then
                        hit = true
                        table.remove(movingArrows, i)
                        
                        if hitResult == "Perfect" then
                            gameState.state.score = gameState.state.score + (100 * gameState.state.multiplier)
                            gameState.state.perfectHits = gameState.state.perfectHits + 1
                        else
                            gameState.state.score = gameState.state.score + (50 * gameState.state.multiplier)
                            gameState.state.goodHits = gameState.state.goodHits + 1
                        end
                        
                        gameState.state.combo = gameState.state.combo + 1
                        gameState.state.maxCombo = math.max(gameState.state.maxCombo, gameState.state.combo)
                        gameState.state.lastHitRating = hitResult
                        gameState.state.hitRatingTimer = 0.5
                        gameState.state.comboTimer = 0.1
                        gameState.state.comboScale = 1.5
                        
                        table.insert(gameState.state.hitEffects, gameplay.addHitEffect(arrow.x, arrow.y, hitResult))
                        break
                    end
                end
            end
            
            if not hit then
                gameState.state.combo = 0
                gameState.state.multiplier = 1
                gameState.state.health = math.max(0, gameState.state.health - 5)
                gameState.state.missedHits = gameState.state.missedHits + 1
                gameState.state.lastHitRating = "Miss"
                gameState.state.hitRatingTimer = 0.5
            end
        elseif key == "escape" then
            gameState.state.current = "songSelect"
            songManager.stopCurrentSong(gameState.state.currentMusic)
        end
    elseif gameState.state.current == "gameover" and key == "r" then
        if gameState.state.isGameOver then
            gameState.state.current = "mainMenu"
            songManager.cleanup() -- Clean up invalid songs when returning to menu
        else
            gameState.state.current = "songSelect"
        end
        gameOver.reset()
    elseif gameState.state.current == "editor" then
        editor.handleEditorKeyPress(key)
    end
end

function love.filedropped(file)
    if gameState.state.current == "editor" then
        local filename = file:getFilename()
        if filename:match("%.mp3$") then
            -- Get the file data
            file:open("r")
            local data = file:read("data")  -- Use "data" mode for binary files
            file:close()
            
            -- Update editor state
            local basename = filename:match("[^/\\]+$")
            gameState.editor.songName = basename:match("(.+)%.mp3$")
            gameState.editor.audioData = data
            
            -- Try to load the audio file
            gameState.editor.currentMusic = songManager.loadAudioFromData(data)
        else
            print("Invalid file type. Please use MP3 format.")
        end
    end
end