local gameState = require('game_state')
local gameplay = require('gameplay')
local gameUI = require('game_ui')

local editorUI = {}

-- Flash effect time tracking
local flashTime = 0

local function drawSetupOverlay()
    local editor = gameState.editor
    if editor.recording then return end

    -- Full screen semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Center content vertically and horizontally
    local contentWidth = 600
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

function editorUI.draw(activeKeys, targetArrows, arrowColors)
    local editor = gameState.editor
    
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

        -- Draw flashing "Press SPACE to end recording" text
        local alpha = (math.sin(flashTime * 5) + 1) / 2  -- Oscillate between 0 and 1
        love.graphics.setColor(1, 0, 0, alpha)
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("Press SPACE to end recording", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    else
        -- Draw setup overlay for steps 1 and 2
        drawSetupOverlay()
    end

    -- Draw countdown if active
    if editor.countdown > 0 then
        -- Dim the screen
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Draw countdown
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(gameState.fonts.title)
        love.graphics.printf(math.ceil(editor.countdown), 0, love.graphics.getHeight()/2 - 100, love.graphics.getWidth(), "center")
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf("Get ready!", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
        love.graphics.printf("Press arrow keys in time with the music", 0, love.graphics.getHeight()/2 + 50, love.graphics.getWidth(), "center")
    end
    
    -- Draw status message if active
    if editor.status.message ~= "" and editor.status.time > 0 then
        -- Draw status background
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 60, love.graphics.getWidth(), 40)
        
        love.graphics.setColor(1, 1, 0, math.min(1, editor.status.time))
        love.graphics.setFont(gameState.fonts.medium)
        love.graphics.printf(editor.status.message, 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")
    end
end

function editorUI.update(dt)
    if gameState.editor.recording then
        flashTime = flashTime + dt
    end
end

function editorUI.reset()
    flashTime = 0
end

return editorUI