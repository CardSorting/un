local config = require('game_over/config')

local renderer = {}

local function drawBackground(width, height, animations)
    -- Draw particles
    for _, p in ipairs(animations.state.particles) do
        local color = config.colors.stats[
            p.color < 0.33 and "perfect" or
            p.color < 0.66 and "good" or "miss"
        ]
        love.graphics.setColor(color[1], color[2], color[3], p.alpha * animations.state.fadeIn)
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.rotate(p.rotation)
        love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
        love.graphics.pop()
    end
    
    -- Draw gradient overlay
    local overlay = config.colors.overlay
    local gradientSteps = 20
    for i = 0, gradientSteps do
        local t = i / gradientSteps
        local alpha = (overlay.top[4] * (1-t) + overlay.bottom[4] * t) * animations.state.fadeIn
        love.graphics.setColor(0, 0, 0, alpha)
        local y = height * (i / gradientSteps)
        local h = height / gradientSteps + 1
        love.graphics.rectangle("fill", 0, y, width, h)
    end
end

local function drawMainPanel(x, y, width, height, animations)
    local panel = config.panel
    local colors = config.colors.panel
    local effects = config.effects
    
    -- Draw outer glow
    for i = effects.glow.size, 0, -1 do
        local alpha = (i/effects.glow.size) * effects.glow.intensity * animations.state.fadeIn
        love.graphics.setColor(colors.glow[1], colors.glow[2], colors.glow[3], alpha)
        love.graphics.rectangle("fill", 
            x-i, y-i, 
            width+i*2, height+i*2, 
            panel.cornerRadius+i)
    end
    
    -- Draw panel background
    love.graphics.setColor(colors.background[1], colors.background[2], colors.background[3], 
        colors.background[4] * animations.state.fadeIn)
    love.graphics.rectangle("fill", x, y, width, height, panel.cornerRadius)
    
    -- Draw border
    love.graphics.setColor(colors.border[1], colors.border[2], colors.border[3], 
        colors.border[4] * animations.state.fadeIn)
    love.graphics.rectangle("line", x, y, width, height, panel.cornerRadius)
end

local function drawStatBar(x, y, width, value, maxValue, color, label, progress)
    local stats = config.sections.stats
    local effects = config.effects.bars
    
    -- Background with glow
    love.graphics.setColor(config.colors.stats.background)
    love.graphics.rectangle("fill", x, y, width, stats.barHeight, effects.cornerRadius)
    
    -- Calculate fill width
    local fillWidth = (width * value / maxValue) * progress
    
    -- Draw bar fill with glow
    love.graphics.setColor(color[1], color[2], color[3], color[4])
    for i = effects.glowSize, 0, -1 do
        local alpha = (i/effects.glowSize) * effects.glowIntensity
        love.graphics.setColor(color[1], color[2], color[3], color[4] * alpha)
        love.graphics.rectangle("fill", 
            x-i, y-i, 
            fillWidth+i*2, stats.barHeight+i*2, 
            effects.cornerRadius+i)
    end
    
    -- Draw main bar
    love.graphics.setColor(color[1], color[2], color[3], color[4])
    love.graphics.rectangle("fill", x, y, fillWidth, stats.barHeight, effects.cornerRadius)
    
    -- Draw label
    love.graphics.setColor(config.colors.text.primary)
    love.graphics.printf(label, x - stats.labelWidth, y + stats.barHeight/2 - 10,
        stats.labelWidth, "right")
    
    -- Draw percentage
    local percentage = math.floor((value / maxValue) * 100)
    love.graphics.setColor(config.colors.text.secondary)
    love.graphics.printf(string.format("%d%%", percentage),
        x + width + 10, y + stats.barHeight/2 - 10,
        stats.valueWidth, "left")
end

function renderer.draw(gameState, animations, fonts)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Draw background effects
    drawBackground(width, height, animations)
    
    -- Calculate panel position
    local panel = config.panel
    local panelX = (width - panel.width) / 2
    local panelY = (height - panel.height) / 2
    
    -- Draw main panel
    drawMainPanel(panelX, panelY, panel.width, panel.height, animations)
    
    if animations.state.fadeIn > 0 then
        local sections = config.sections
        local currentY = panelY + panel.padding.vertical
        
        -- Draw title section
        local titleColor = gameState.isGameOver and config.colors.grade.D or config.colors.grade.S
        love.graphics.setFont(fonts.title)
        love.graphics.setColor(titleColor[1], titleColor[2], titleColor[3], animations.state.fadeIn)
        love.graphics.printf(
            gameState.isGameOver and "GAME OVER" or "STAGE CLEAR",
            0, currentY, width, "center"
        )
        
        if animations.state.scoreCount > 0 then
            currentY = currentY + sections.title.height
            
            -- Calculate and draw grade
            local accuracy = (gameState.perfectHits + gameState.goodHits * 0.5) / 
                (gameState.perfectHits + gameState.goodHits + gameState.missedHits) * 100
            local grade = accuracy >= 95 and "S" or
                         accuracy >= 90 and "A" or
                         accuracy >= 80 and "B" or
                         accuracy >= 70 and "C" or "D"
            local gradeColor = config.colors.grade[grade]
            
            -- Draw grade
            love.graphics.setFont(fonts.title)
            love.graphics.setColor(gradeColor[1], gradeColor[2], gradeColor[3], animations.state.scoreCount)
            love.graphics.printf(grade, 0, currentY, width, "center")
            
            -- Draw stage info
            currentY = currentY + sections.grade.scoreSpacing
            love.graphics.setFont(fonts.medium)
            love.graphics.setColor(config.colors.text.highlight)
            love.graphics.printf(string.format("Stage %d / 3", gameState.stagesCleared), 0, currentY, width, "center")
            
            -- Draw scores
            currentY = currentY + sections.grade.scoreSpacing
            local displayScore = math.floor(gameState.score * animations.state.scoreCount)
            local displayTotalScore = math.floor(gameState.totalScore * animations.state.scoreCount)
            love.graphics.setFont(fonts.large)
            love.graphics.setColor(config.colors.text.highlight)
            love.graphics.printf(string.format("Stage Score: %07d", displayScore), 0, currentY, width, "center")
            currentY = currentY + sections.grade.scoreSpacing
            love.graphics.printf(string.format("Total Score: %07d", displayTotalScore), 0, currentY, width, "center")
            
            -- Draw stats section
            currentY = currentY + sections.grade.height
            local statsX = panelX + (panel.width - sections.stats.width) / 2
            local totalNotes = gameState.perfectHits + gameState.goodHits + gameState.missedHits
            
            if totalNotes > 0 then
                -- Draw stats container background
                love.graphics.setColor(config.colors.panel.background)
                love.graphics.rectangle("fill", 
                    statsX, currentY,
                    sections.stats.width, sections.stats.height,
                    config.effects.bars.cornerRadius)
                
                -- Draw stat bars
                local barX = statsX + sections.stats.padding
                local barY = currentY + sections.stats.padding
                local barWidth = sections.stats.width - sections.stats.padding * 2
                
                local stats = {
                    {label = "Perfect", value = gameState.perfectHits, color = config.colors.stats.perfect},
                    {label = "Good", value = gameState.goodHits, color = config.colors.stats.good},
                    {label = "Miss", value = gameState.missedHits, color = config.colors.stats.miss}
                }
                
                for i, stat in ipairs(stats) do
                    local progress = animations.state.graphProgress[string.lower(stat.label)] or 0
                    drawStatBar(
                        barX,
                        barY + (i-1) * (sections.stats.barHeight + sections.stats.spacing),
                        barWidth,
                        stat.value,
                        totalNotes,
                        stat.color,
                        stat.label,
                        progress
                    )
                end
            end
            
            -- Draw prompt
            local promptY = panelY + panel.height - sections.bottom.height
            local pulse = math.sin(love.timer.getTime() * config.animation.prompt.pulseSpeed)
            local promptAlpha = (0.7 + pulse * config.animation.prompt.pulseAmount) * animations.state.scoreCount
            
            love.graphics.setFont(fonts.medium)
            love.graphics.setColor(config.colors.text.primary[1], config.colors.text.primary[2],
                config.colors.text.primary[3], promptAlpha)
            
            local promptText = gameState.isGameOver and "Press R to Return" or "Press R to Continue"
            love.graphics.printf(promptText, 0, promptY, width, "center")
        end
    end
end

return renderer