local ui = require('ui_config')
local gameState = require('game_state')

local function createArrowColors()
    return {
        left = {1, 0.2, 0.2},   -- Red
        down = {0.2, 0.2, 1},   -- Blue
        up = {0.2, 1, 0.2},     -- Green
        right = {1, 1, 0.2}     -- Yellow
    }
end

local function createTargetArrows()
    return {
        {x = love.graphics.getWidth()/2 - 150, y = ui.gameArea.targetY, direction = "left"},
        {x = love.graphics.getWidth()/2 - 50, y = ui.gameArea.targetY, direction = "down"},
        {x = love.graphics.getWidth()/2 + 50, y = ui.gameArea.targetY, direction = "up"},
        {x = love.graphics.getWidth()/2 + 150, y = ui.gameArea.targetY, direction = "right"}
    }
end

local function getArrowXPosition(direction)
    local positions = {
        left = love.graphics.getWidth()/2 - 150,
        down = love.graphics.getWidth()/2 - 50,
        up = love.graphics.getWidth()/2 + 50,
        right = love.graphics.getWidth()/2 + 150
    }
    return positions[direction]
end

local function drawArrow(x, y, direction, isTarget, arrowColors)
    local size = ui.gameArea.arrowSize
    local color = arrowColors[direction]
    love.graphics.setColor(color)
    
    -- Draw arrow based on direction
    if direction == "left" then
        love.graphics.polygon("fill", 
            x + size, y - size/2,
            x + size, y + size/2,
            x, y
        )
    elseif direction == "right" then
        love.graphics.polygon("fill",
            x - size, y - size/2,
            x - size, y + size/2,
            x, y
        )
    elseif direction == "up" then
        love.graphics.polygon("fill",
            x - size/2, y + size,
            x + size/2, y + size,
            x, y
        )
    elseif direction == "down" then
        love.graphics.polygon("fill",
            x - size/2, y - size,
            x + size/2, y - size,
            x, y
        )
    end
    
    -- Draw outline for target arrows
    if isTarget then
        love.graphics.setColor(1, 1, 1, 0.5)
        if direction == "left" then
            love.graphics.line(
                x + size, y - size/2,
                x + size, y + size/2,
                x, y,
                x + size, y - size/2
            )
        elseif direction == "right" then
            love.graphics.line(
                x - size, y - size/2,
                x - size, y + size/2,
                x, y,
                x - size, y - size/2
            )
        elseif direction == "up" then
            love.graphics.line(
                x - size/2, y + size,
                x + size/2, y + size,
                x, y,
                x - size/2, y + size
            )
        elseif direction == "down" then
            love.graphics.line(
                x - size/2, y - size,
                x + size/2, y - size,
                x, y,
                x - size/2, y - size
            )
        end
    end
end

local function drawLaneEffects(targetArrows, laneEffects)
    for _, arrow in ipairs(targetArrows) do
        if laneEffects[arrow.direction] > 0 then
            love.graphics.setColor(1, 1, 1, laneEffects[arrow.direction] * 0.3)
            love.graphics.rectangle("fill", 
                arrow.x - ui.gameArea.laneWidth/2,
                0,
                ui.gameArea.laneWidth,
                love.graphics.getHeight()
            )
        end
        
        -- Draw lane guides
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.rectangle("fill",
            arrow.x - ui.gameArea.laneWidth/2,
            0,
            ui.gameArea.laneWidth,
            love.graphics.getHeight()
        )
    end
end

local function drawHitEffects(hitEffects, colors)
    for _, effect in ipairs(hitEffects) do
        if effect.type == "Perfect" then
            love.graphics.setColor(colors.perfect[1], colors.perfect[2], colors.perfect[3], effect.alpha)
        elseif effect.type == "Good" then
            love.graphics.setColor(colors.good[1], colors.good[2], colors.good[3], effect.alpha)
        end
        love.graphics.circle("fill", effect.x, effect.y, 20)
    end
end

local function addHitEffect(x, y, hitType)
    return {
        x = x,
        y = y,
        type = hitType,
        timer = 0.2,
        duration = 0.2,
        alpha = 1
    }
end

local function isArrowInLane(arrow, direction)
    local targetY = ui.gameArea.targetY
    local threshold = 45  -- Hit window in pixels
    return math.abs(arrow.y - targetY) <= threshold
end

local function checkHit(arrow, targetY, threshold, perfectThreshold)
    local distance = math.abs(arrow.y - targetY)
    
    if distance <= threshold then
        if distance <= perfectThreshold then
            return "Perfect"
        else
            return "Good"
        end
    end
    
    return nil
end

return {
    createArrowColors = createArrowColors,
    createTargetArrows = createTargetArrows,
    getArrowXPosition = getArrowXPosition,
    drawArrow = drawArrow,
    drawLaneEffects = drawLaneEffects,
    drawHitEffects = drawHitEffects,
    addHitEffect = addHitEffect,
    isArrowInLane = isArrowInLane,
    checkHit = checkHit
}