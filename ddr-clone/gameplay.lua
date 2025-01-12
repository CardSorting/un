local ui = require('ui_config')
local gameState = require('game_state')

-- Animation utilities
local function lerp(a, b, t)
    return a + (b - a) * t
end

local function createGlowEffect(r, g, b, intensity, time)
    local pulseIntensity = intensity * (1 + 0.3 * math.sin(time * 6))
    love.graphics.setColor(r, g, b, 0.15 * pulseIntensity)
    return function(x, y, width, height, blur)
        for i = blur, 1, -1 do
            local scale = 1 + 0.2 * math.sin(time * 4 + i)
            love.graphics.rectangle("fill", 
                x - i*scale, y - i*scale, 
                width + i*scale*2, height + i*scale*2)
        end
    end
end

local function pulseEffect(time, min, max, speed)
    return min + (max - min) * math.abs(math.sin(time * speed)) * 0.8
end

local function createArrowColors()
    -- Enhanced vibrant colors with neon effect
    return {
        left = {1, 0.1, 0.3},    -- Intense Red
        down = {0.1, 0.3, 1},    -- Deep Blue
        up = {0.1, 1, 0.3},      -- Bright Green
        right = {1, 0.7, 0.1}    -- Bright Gold
    }
end

local function createTargetArrows()
    return {
        {x = love.graphics.getWidth()/2 - 300, y = ui.gameArea.targetY, direction = "left", glow = 0, rotation = 0, scale = 1, isHolding = false},
        {x = love.graphics.getWidth()/2 - 100, y = ui.gameArea.targetY, direction = "down", glow = 0, rotation = 0, scale = 1, isHolding = false},
        {x = love.graphics.getWidth()/2 + 100, y = ui.gameArea.targetY, direction = "up", glow = 0, rotation = 0, scale = 1, isHolding = false},
        {x = love.graphics.getWidth()/2 + 300, y = ui.gameArea.targetY, direction = "right", glow = 0, rotation = 0, scale = 1, isHolding = false}
    }
end

local function getArrowXPosition(direction)
    local positions = {
        left = love.graphics.getWidth()/2 - 300,
        down = love.graphics.getWidth()/2 - 100,
        up = love.graphics.getWidth()/2 + 100,
        right = love.graphics.getWidth()/2 + 300
    }
    return positions[direction]
end

local function drawHoldTrail(x, startY, endY, direction, color, alpha, time)
    local trailWidth = ui.gameArea.arrowSize * 0.6
    local segments = 10
    local segmentHeight = (endY - startY) / segments
    
    for i = 0, segments - 1 do
        local segY = startY + i * segmentHeight
        local segAlpha = alpha * (0.5 + 0.3 * math.sin(time * 4 + i * 0.5))
        local segWidth = trailWidth * (1 + 0.1 * math.sin(time * 3 + i * 0.7))
        
        love.graphics.setColor(color[1], color[2], color[3], segAlpha)
        
        -- Draw trail segment with glow effect
        for j = 1, 2 do
            local glowAlpha = segAlpha * (3-j)/2
            local glowWidth = segWidth * (1 + (j-1) * 0.3)
            love.graphics.setColor(color[1], color[2], color[3], glowAlpha)
            love.graphics.rectangle("fill",
                x - glowWidth/2,
                segY,
                glowWidth,
                segmentHeight * 0.9
            )
        end
        
        -- Draw side lines
        love.graphics.setColor(1, 1, 1, segAlpha * 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.line(
            x - segWidth/2, segY,
            x - segWidth/2, segY + segmentHeight * 0.9
        )
        love.graphics.line(
            x + segWidth/2, segY,
            x + segWidth/2, segY + segmentHeight * 0.9
        )
    end
end

local function drawArrowTrail(x, y, direction, color, alpha, scale, time)
    local trailLength = 4
    for i = 1, trailLength do
        local trailAlpha = alpha * (1 - i/trailLength) * 0.5
        local trailScale = scale * (1 - i/trailLength * 0.3)
        local trailOffset = i * 15 * (1 + 0.3 * math.sin(time * 5))
        love.graphics.setColor(color[1], color[2], color[3], trailAlpha)
        
        love.graphics.push()
        love.graphics.translate(x, y + trailOffset)
        love.graphics.rotate(math.sin(time * 3 + i) * 0.1)
        
        if direction == "left" then
            love.graphics.polygon("fill", 
                ui.gameArea.arrowSize * trailScale, -ui.gameArea.arrowSize/2 * trailScale,
                ui.gameArea.arrowSize * trailScale, ui.gameArea.arrowSize/2 * trailScale,
                0, 0
            )
        elseif direction == "right" then
            love.graphics.polygon("fill",
                -ui.gameArea.arrowSize * trailScale, -ui.gameArea.arrowSize/2 * trailScale,
                -ui.gameArea.arrowSize * trailScale, ui.gameArea.arrowSize/2 * trailScale,
                0, 0
            )
        elseif direction == "up" then
            love.graphics.polygon("fill",
                -ui.gameArea.arrowSize/2 * trailScale, ui.gameArea.arrowSize * trailScale,
                ui.gameArea.arrowSize/2 * trailScale, ui.gameArea.arrowSize * trailScale,
                0, 0
            )
        elseif direction == "down" then
            love.graphics.polygon("fill",
                -ui.gameArea.arrowSize/2 * trailScale, -ui.gameArea.arrowSize * trailScale,
                ui.gameArea.arrowSize/2 * trailScale, -ui.gameArea.arrowSize * trailScale,
                0, 0
            )
        end
        love.graphics.pop()
    end
end

local function drawArrow(x, y, direction, isTarget, arrowColors, alpha, scale, glow, isHold, holdLength, holdProgress)
    local time = love.timer.getTime()
    local size = ui.gameArea.arrowSize * (scale or 1)
    local color = arrowColors[direction]
    alpha = alpha or 1
    glow = glow or 0
    
    -- Draw hold trail if this is a hold note
    if isHold then
        local endY = y + holdLength
        drawHoldTrail(x, y, endY, direction, color, alpha, time)
        
        -- Draw progress indicator
        if holdProgress then
            local progressY = y + holdLength * holdProgress
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.circle("fill", x, progressY, size * 0.2)
        end
    else
        -- Draw regular arrow trail
        if not isTarget then
            drawArrowTrail(x, y, direction, color, alpha, scale or 1, time)
        end
    end
    
    -- Enhanced glow effect for target arrows
    if isTarget then
        local pulseSize = size * (1 + 0.2 * math.sin(time * 6))
        local glowFunc = createGlowEffect(color[1], color[2], color[3], glow, time)
        glowFunc(x - pulseSize, y - pulseSize, pulseSize * 2, pulseSize * 2, 5)
    end
    
    -- Draw arrow with enhanced effects
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Enhanced rotation animation
    if not isTarget then
        local rotationAmount = math.sin(time * 5) * 0.1
        love.graphics.rotate(rotationAmount)
    else
        local targetRotation = math.sin(time * 3) * 0.05
        love.graphics.rotate(targetRotation)
    end
    
    -- Draw main arrow
    love.graphics.setColor(color[1], color[2], color[3], alpha)
    
    -- Draw arrow with inner glow
    if direction == "left" then
        -- Main arrow
        love.graphics.polygon("fill", 
            size, -size/2,
            size, size/2,
            0, 0
        )
        -- Inner glow
        love.graphics.setColor(1, 1, 1, alpha * 0.5)
        love.graphics.polygon("fill",
            size * 0.7, -size/3,
            size * 0.7, size/3,
            size * 0.1, 0
        )
    elseif direction == "right" then
        love.graphics.polygon("fill",
            -size, -size/2,
            -size, size/2,
            0, 0
        )
        love.graphics.setColor(1, 1, 1, alpha * 0.5)
        love.graphics.polygon("fill",
            -size * 0.7, -size/3,
            -size * 0.7, size/3,
            -size * 0.1, 0
        )
    elseif direction == "up" then
        love.graphics.polygon("fill",
            -size/2, size,
            size/2, size,
            0, 0
        )
        love.graphics.setColor(1, 1, 1, alpha * 0.5)
        love.graphics.polygon("fill",
            -size/3, size * 0.7,
            size/3, size * 0.7,
            0, size * 0.1
        )
    elseif direction == "down" then
        love.graphics.polygon("fill",
            -size/2, -size,
            size/2, -size,
            0, 0
        )
        love.graphics.setColor(1, 1, 1, alpha * 0.5)
        love.graphics.polygon("fill",
            -size/3, -size * 0.7,
            size/3, -size * 0.7,
            0, -size * 0.1
        )
    end
    
    love.graphics.pop()
    
    -- Enhanced target arrow effects
    if isTarget then
        -- Dynamic outline effect
        local outlineAlpha = 0.5 + 0.4 * math.sin(time * 6)
        local outlineWidth = 2 + math.sin(time * 5)
        love.graphics.setLineWidth(outlineWidth)
        
        -- Draw outline
        love.graphics.setColor(1, 1, 1, outlineAlpha)
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
    local time = love.timer.getTime()
    
    for _, arrow in ipairs(targetArrows) do
        -- Enhanced lane activation effect
        if laneEffects[arrow.direction] > 0 or arrow.isHolding then
            local effect = laneEffects[arrow.direction]
            if arrow.isHolding then
                effect = math.max(effect, 0.5) -- Ensure minimum effect during hold
            end
            
            -- Multi-layered energy effect
            for i = 1, 5 do
                local alpha = effect * 0.25 * (6-i)/5
                local width = ui.gameArea.laneWidth + i*8 * math.sin(time * 4)
                local yOffset = math.sin(time * 3 + i) * 10
                love.graphics.setColor(1, 1, 1, alpha)
                love.graphics.rectangle("fill", 
                    arrow.x - width/2,
                    yOffset,
                    width,
                    love.graphics.getHeight()
                )
            end
            
            -- Energy particles
            for i = 1, 3 do
                local particleY = (time * 300 + i * 200) % love.graphics.getHeight()
                local particleAlpha = effect * 0.5 * (1 - particleY/love.graphics.getHeight())
                local particleWidth = ui.gameArea.laneWidth * 0.2
                local particleX = arrow.x + math.sin(time * 5 + i) * (ui.gameArea.laneWidth * 0.3)
                
                love.graphics.setColor(1, 1, 1, particleAlpha)
                love.graphics.circle("fill", particleX, particleY, particleWidth)
            end
        end
        
        -- Enhanced lane guides
        local baseAlpha = 0.12 + 0.08 * math.sin(time * 3 + string.byte(arrow.direction))
        
        -- Draw flowing lane markers
        for i = 0, 12 do
            local yOffset = (time * 250 + i * 80) % love.graphics.getHeight()
            local markerAlpha = baseAlpha * (1 - yOffset/love.graphics.getHeight())
            local width = ui.gameArea.laneWidth * (0.7 + 0.3 * math.sin(time * 4 + i))
            
            love.graphics.setColor(1, 1, 1, markerAlpha)
            love.graphics.rectangle("fill",
                arrow.x - width/2,
                yOffset,
                width,
                3
            )
        end
    end
end

local function drawHitEffects(hitEffects, colors)
    local time = love.timer.getTime()
    
    for _, effect in ipairs(hitEffects) do
        local progress = effect.timer / effect.duration
        local size = 30 * (2 - progress)
        local alpha = effect.alpha * progress
        local rotation = time * 10
        
        -- Draw expanding rings with energy effect
        if effect.type == "Perfect" then
            for i = 1, 4 do
                local ringSize = size * (1 + i * 0.4)
                local ringAlpha = alpha * (5-i)/4
                love.graphics.setColor(colors.perfect[1], colors.perfect[2], colors.perfect[3], ringAlpha)
                love.graphics.circle("line", effect.x, effect.y, ringSize)
                
                -- Additional energy ring
                local energySize = ringSize * (1 + 0.2 * math.sin(time * 6 + i))
                love.graphics.circle("line", effect.x, effect.y, energySize)
            end
        elseif effect.type == "Good" then
            for i = 1, 3 do
                local ringSize = size * (1 + i * 0.3)
                local ringAlpha = alpha * (4-i)/3
                love.graphics.setColor(colors.good[1], colors.good[2], colors.good[3], ringAlpha)
                love.graphics.circle("line", effect.x, effect.y, ringSize)
            end
        end
        
        -- Draw burst effect with rotation
        love.graphics.push()
        love.graphics.translate(effect.x, effect.y)
        love.graphics.rotate(rotation)
        
        local burstCount = effect.type == "Perfect" and 12 or 8
        for i = 1, burstCount do
            local angle = (i / burstCount) * math.pi * 2
            local burstSize = size * (1 + 0.3 * math.sin(time * 8 + i))
            local x1 = math.cos(angle) * burstSize * 0.4
            local y1 = math.sin(angle) * burstSize * 0.4
            local x2 = math.cos(angle) * burstSize
            local y2 = math.sin(angle) * burstSize
            
            if effect.type == "Perfect" then
                love.graphics.setColor(colors.perfect[1], colors.perfect[2], colors.perfect[3], alpha)
            else
                love.graphics.setColor(colors.good[1], colors.good[2], colors.good[3], alpha)
            end
            
            love.graphics.line(x1, y1, x2, y2)
        end
        love.graphics.pop()
        
        -- Draw particles with enhanced movement
        local particleCount = effect.type == "Perfect" and 16 or 12
        for i = 1, particleCount do
            local angle = (i / particleCount) * math.pi * 2 + time * 4
            local radius = size * (1.5 + 0.4 * math.sin(time * 8 + i))
            local px = effect.x + math.cos(angle) * radius
            local py = effect.y + math.sin(angle) * radius
            
            if effect.type == "Perfect" then
                love.graphics.setColor(colors.perfect[1], colors.perfect[2], colors.perfect[3], alpha)
            else
                love.graphics.setColor(colors.good[1], colors.good[2], colors.good[3], alpha)
            end
            
            -- Draw particle with trail
            love.graphics.circle("fill", px, py, 4 * progress)
            
            -- Draw particle trail
            local trailLength = 3
            for j = 1, trailLength do
                local trailAngle = angle - j * 0.2
                local trailRadius = radius * (1 - j * 0.1)
                local tx = effect.x + math.cos(trailAngle) * trailRadius
                local ty = effect.y + math.sin(trailAngle) * trailRadius
                love.graphics.setColor(colors.perfect[1], colors.perfect[2], colors.perfect[3], alpha * (1 - j/trailLength))
                love.graphics.circle("fill", tx, ty, 2 * progress * (1 - j/trailLength))
            end
        end
    end
end

local function addHitEffect(x, y, hitType)
    return {
        x = x,
        y = y,
        type = hitType,
        timer = 0.5,
        duration = 0.5,
        alpha = 1
    }
end

local function isArrowInLane(arrow, direction)
    local targetY = ui.gameArea.targetY
    local threshold = 45
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

local function updateHoldProgress(arrow, targetY)
    if not arrow.holdLength then return 0 end
    
    local progress = (targetY - arrow.y) / arrow.holdLength
    return math.max(0, math.min(1, progress))
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
    checkHit = checkHit,
    updateHoldProgress = updateHoldProgress
}