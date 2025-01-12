local gameState = require('game_state')

local animations = {
    fadeIn = 0,
    scoreCount = 0,
    finalScore = 0,
    statsDelay = 0.5,
    statsShow = false,
    buttonDelay = 1.5,
    buttonShow = false
}

local function reset()
    animations.fadeIn = 0
    animations.scoreCount = 0
    animations.finalScore = 0
    animations.statsDelay = 0.5
    animations.statsShow = false
    animations.buttonDelay = 1.5
    animations.buttonShow = false
end

local function update(dt)
    -- Update fade in
    animations.fadeIn = math.min(1, animations.fadeIn + dt)
    
    -- Update score counting animation
    if animations.scoreCount < 1 then
        animations.scoreCount = math.min(1, animations.scoreCount + dt * 0.5)
        animations.finalScore = math.floor(gameState.state.score * animations.scoreCount)
    end
    
    -- Update stats delay
    if animations.statsDelay > 0 then
        animations.statsDelay = animations.statsDelay - dt
        if animations.statsDelay <= 0 then
            animations.statsShow = true
        end
    end
    
    -- Update button delay
    if animations.buttonDelay > 0 then
        animations.buttonDelay = animations.buttonDelay - dt
        if animations.buttonDelay <= 0 then
            animations.buttonShow = true
        end
    end
end

local function draw(state, colors, fonts)
    -- Draw background panel with fade
    love.graphics.setColor(0, 0, 0, 0.7 * animations.fadeIn)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 300, 50, 600, 500)
    
    -- Draw title
    love.graphics.setColor(colors.ui[1], colors.ui[2], colors.ui[3], animations.fadeIn)
    love.graphics.setFont(fonts.title)
    if state.isGameOver then
        love.graphics.printf("Game Over", 0, 100, love.graphics.getWidth(), "center")
    else
        love.graphics.printf("Stage Clear!", 0, 100, love.graphics.getWidth(), "center")
    end
    
    -- Draw score
    love.graphics.setFont(fonts.large)
    love.graphics.printf("Score: " .. string.format("%08d", animations.finalScore), 0, 200, love.graphics.getWidth(), "center")
    
    -- Draw stats if showing
    if animations.statsShow then
        love.graphics.setFont(fonts.medium)
        local statsY = 300
        love.graphics.printf("Perfect Hits: " .. state.perfectHits, 0, statsY, love.graphics.getWidth(), "center")
        love.graphics.printf("Good Hits: " .. state.goodHits, 0, statsY + 40, love.graphics.getWidth(), "center")
        love.graphics.printf("Missed Hits: " .. state.missedHits, 0, statsY + 80, love.graphics.getWidth(), "center")
        love.graphics.printf("Max Combo: " .. state.maxCombo, 0, statsY + 120, love.graphics.getWidth(), "center")
    end
    
    -- Draw continue button if showing
    if animations.buttonShow then
        love.graphics.setFont(fonts.medium)
        love.graphics.printf("Press R to continue", 0, 500, love.graphics.getWidth(), "center")
    end
end

return {
    reset = reset,
    update = update,
    draw = draw
}