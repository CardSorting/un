local gameState = require('game_state')
local songManager = require('song_manager')

local function drawMainMenu()
    -- Draw background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 250, 50, 500, 400)
    love.graphics.setColor(gameState.colors.ui)

    -- Draw title
    love.graphics.setFont(gameState.fonts.title)
    love.graphics.printf("Rhythm Game", 0, 100, love.graphics.getWidth(), "center")
    
    -- Draw menu items
    love.graphics.setFont(gameState.fonts.medium)
    for i, item in ipairs(gameState.menuItems) do
        local y = 250 + (i-1) * 50
        local text = item.text
        
        -- Highlight selected item
        if i == gameState.state.selectedMenuItem then
            love.graphics.setColor(gameState.colors.combo)
            text = "> " .. text .. " <"
        else
            love.graphics.setColor(gameState.colors.uiDark)
        end
        
        love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
    end
    
    -- Draw instructions
    love.graphics.setColor(gameState.colors.ui)
    love.graphics.setFont(gameState.fonts.small)
    love.graphics.printf("Use arrow keys to select, Enter to confirm", 0, 500, love.graphics.getWidth(), "center")
end

local function drawSongSelect()
    -- Draw background panel
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 300, 30, 600, 500)
    love.graphics.setColor(gameState.colors.ui)

    -- Draw title
    love.graphics.setFont(gameState.fonts.title)
    love.graphics.printf("Song Selection", 0, 50, love.graphics.getWidth(), "center")
    
    -- Draw song list
    love.graphics.setFont(gameState.fonts.medium)
    local songs = songManager.getSongs()
    for i, song in ipairs(songs) do
        local y = 150 + (i-1) * 100
        local text = song.name
        
        -- Create song panel
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 200, y - 10, 400, 80)
        
        -- Highlight selected song
        if i == gameState.state.selectedSong then
            love.graphics.setColor(gameState.colors.combo)
            text = "> " .. text .. " <"
            
            -- Show song details
            love.graphics.setFont(gameState.fonts.small)
            love.graphics.printf("Difficulty: " .. song.difficulty, 0, y + 40, love.graphics.getWidth(), "center")
            love.graphics.printf("BPM: " .. song.bpm, 0, y + 60, love.graphics.getWidth(), "center")
            love.graphics.setFont(gameState.fonts.medium)
        else
            love.graphics.setColor(gameState.colors.uiDark)
        end
        
        love.graphics.printf(text, 0, y, love.graphics.getWidth(), "center")
    end
    
    -- Draw instructions
    love.graphics.setColor(gameState.colors.ui)
    love.graphics.setFont(gameState.fonts.small)
    love.graphics.printf("Press Enter to select, Escape to return", 0, 500, love.graphics.getWidth(), "center")
end

return {
    drawMainMenu = drawMainMenu,
    drawSongSelect = drawSongSelect
}