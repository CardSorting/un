function love.load()
    -- Initialize game state
    gameState = {
        current = "mainMenu",  -- mainMenu, songSelect, game, gameover
        score = 0,
        combo = 0,
        health = 100,
        selectedMenuItem = 1,
        selectedSong = 1,
        gameTime = 0,
        nextArrowIndex = 1
    }
    
    -- Menu items
    menuItems = {
        {text = "Play", action = function() gameState.current = "songSelect" end},
        {text = "Options", action = function() end},  -- Placeholder for options
        {text = "Exit", action = function() love.event.quit() end}
    }
    
    -- Load song patterns
    songs = {
        require("songs/song1/pattern"),
        require("songs/song2/pattern"),
        require("songs/song3/pattern")
    }
    
    -- Colors for different arrows
    arrowColors = {
        left = {1, 0, 0},    -- Red
        down = {0, 1, 0},    -- Green
        up = {0, 0, 1},      -- Blue
        right = {1, 1, 0}    -- Yellow
    }
    
    -- Initialize arrow targets (static arrows at top)
    targetArrows = {
        {x = 100, y = 100, direction = "left"},
        {x = 200, y = 100, direction = "down"},
        {x = 300, y = 100, direction = "up"},
        {x = 400, y = 100, direction = "right"}
    }
    
    -- Initialize moving arrows
    movingArrows = {}
    
    -- Load fonts
    fonts = {
        large = love.graphics.newFont(32),
        medium = love.graphics.newFont(24),
        small = love.graphics.newFont(20)
    }
end

function love.update(dt)
    if gameState.current == "game" then
        -- Update game time
        gameState.gameTime = gameState.gameTime + dt
        
        -- Update moving arrows
        for i = #movingArrows, 1, -1 do
            local arrow = movingArrows[i]
            arrow.y = arrow.y - (300 * dt)
            
            if arrow.y < 0 then
                table.remove(movingArrows, i)
                gameState.health = gameState.health - 5
                gameState.combo = 0
            end
        end
        
        -- Spawn arrows based on pattern
        local currentSong = songs[gameState.selectedSong]
        while gameState.nextArrowIndex <= #currentSong.arrows do
            local nextArrow = currentSong.arrows[gameState.nextArrowIndex]
            if nextArrow.time <= gameState.gameTime then
                local x = 100
                if nextArrow.direction == "down" then x = 200
                elseif nextArrow.direction == "up" then x = 300
                elseif nextArrow.direction == "right" then x = 400 end
                
                table.insert(movingArrows, {
                    x = x,
                    y = 600,
                    direction = nextArrow.direction,
                    time = nextArrow.time
                })
                gameState.nextArrowIndex = gameState.nextArrowIndex + 1
            else
                break
            end
        end
        
        -- Check for song end
        if gameState.nextArrowIndex > #currentSong.arrows and #movingArrows == 0 then
            gameState.current = "gameover"
        end
        
        if gameState.health <= 0 then
            gameState.current = "gameover"
        end
    end
end

-- Helper function to draw an arrow
function drawArrow(x, y, direction)
    local color = arrowColors[direction]
    love.graphics.setColor(color)
    
    if direction == "up" then
        love.graphics.polygon("fill", x+25, y, x+50, y+30, x, y+30)
    elseif direction == "down" then
        love.graphics.polygon("fill", x+25, y+30, x+50, y, x, y)
    elseif direction == "left" then
        love.graphics.polygon("fill", x, y+15, x+30, y+30, x+30, y)
    elseif direction == "right" then
        love.graphics.polygon("fill", x+30, y+15, x, y+30, x, y)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function drawMainMenu()
    love.graphics.setFont(fonts.large)
    love.graphics.printf("Rhythm Game", 0, 100, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(fonts.medium)
    for i, item in ipairs(menuItems) do
        local y = 250 + (i-1) * 50
        local text = item.text
        if i == gameState.selectedMenuItem then
            text = "> " .. text .. " <"
        end
        love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
    end
end

function drawSongSelect()
    love.graphics.setFont(fonts.large)
    love.graphics.printf("Song Selection", 0, 50, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(fonts.medium)
    for i, song in ipairs(songs) do
        local y = 150 + (i-1) * 100
        local text = song.name
        if i == gameState.selectedSong then
            text = "> " .. text .. " <"
            
            -- Show song details
            love.graphics.setFont(fonts.small)
            love.graphics.printf("Difficulty: " .. song.difficulty, 0, y + 40, love.graphics.getWidth(), "center")
            love.graphics.printf("BPM: " .. song.bpm, 0, y + 60, love.graphics.getWidth(), "center")
            love.graphics.setFont(fonts.medium)
        else
            love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
        end
    end
    
    love.graphics.setFont(fonts.small)
    love.graphics.printf("Press Enter to select, Escape to return", 0, 500, love.graphics.getWidth(), "center")
end

function love.draw()
    if gameState.current == "mainMenu" then
        drawMainMenu()
        
    elseif gameState.current == "songSelect" then
        drawSongSelect()
        
    elseif gameState.current == "game" then
        -- Draw target arrows
        for _, arrow in ipairs(targetArrows) do
            drawArrow(arrow.x, arrow.y, arrow.direction)
        end
        
        -- Draw moving arrows
        for _, arrow in ipairs(movingArrows) do
            drawArrow(arrow.x, arrow.y, arrow.direction)
        end
        
        -- Draw UI
        love.graphics.setFont(fonts.small)
        love.graphics.print("Score: " .. gameState.score, 10, 10)
        love.graphics.print("Combo: " .. gameState.combo, 10, 40)
        love.graphics.print("Health: " .. gameState.health, 10, 70)
        
        -- Draw current song info
        local currentSong = songs[gameState.selectedSong]
        love.graphics.printf(currentSong.name, 0, 10, love.graphics.getWidth() - 20, "right")
        love.graphics.printf(string.format("Time: %.1f", gameState.gameTime), 0, 40, love.graphics.getWidth() - 20, "right")
    
    elseif gameState.current == "gameover" then
        love.graphics.setFont(fonts.large)
        if gameState.health <= 0 then
            love.graphics.printf("Game Over!", 0, 200, love.graphics.getWidth(), "center")
        else
            love.graphics.printf("Song Complete!", 0, 200, love.graphics.getWidth(), "center")
        end
        
        love.graphics.setFont(fonts.medium)
        love.graphics.printf("Final Score: " .. gameState.score, 0, 300, love.graphics.getWidth(), "center")
        love.graphics.printf("Max Combo: " .. gameState.combo, 0, 350, love.graphics.getWidth(), "center")
        love.graphics.printf("Press R to Return to Menu", 0, 450, love.graphics.getWidth(), "center")
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
            gameState.health = 100
            gameState.gameTime = 0
            gameState.nextArrowIndex = 1
            movingArrows = {}
        elseif key == "escape" then
            gameState.current = "mainMenu"
        end
        
    elseif gameState.current == "game" then
        local hitThreshold = 30
        local perfectThreshold = 10
        
        if key == "left" or key == "down" or key == "up" or key == "right" then
            local targetY = 100
            local hit = false
            
            for i = #movingArrows, 1, -1 do
                local arrow = movingArrows[i]
                if arrow.direction == key and math.abs(arrow.y - targetY) < hitThreshold then
                    hit = true
                    table.remove(movingArrows, i)
                    
                    local accuracy = math.abs(arrow.y - targetY)
                    if accuracy < perfectThreshold then
                        gameState.score = gameState.score + 100
                        gameState.combo = gameState.combo + 1
                    else
                        gameState.score = gameState.score + 50
                        gameState.combo = gameState.combo + 1
                    end
                    break
                end
            end
            
            if not hit then
                gameState.combo = 0
                gameState.health = gameState.health - 5
            end
        elseif key == "escape" then
            gameState.current = "songSelect"
        end
        
    elseif gameState.current == "gameover" and key == "r" then
        gameState.current = "mainMenu"
    end
end