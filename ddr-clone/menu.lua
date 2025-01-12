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
    
    -- Calculate pagination
    local songs = songManager.getSongs()
    local startIndex = (gameState.state.currentPage - 1) * gameState.state.songsPerPage + 1
    local endIndex = math.min(startIndex + gameState.state.songsPerPage - 1, #songs)
    local totalPages = math.ceil(#songs / gameState.state.songsPerPage)
    
    -- Draw song list for current page
    love.graphics.setFont(gameState.fonts.medium)
    for i = startIndex, endIndex do
        local song = songs[i]
        local displayIndex = i - startIndex + 1
        local y = 150 + (displayIndex-1) * 100
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
    
    -- Draw pagination controls
    love.graphics.setColor(gameState.colors.ui)
    love.graphics.setFont(gameState.fonts.small)
    
    -- Previous page button
    if gameState.state.currentPage > 1 then
        love.graphics.setColor(gameState.colors.ui)
    else
        love.graphics.setColor(gameState.colors.uiDark)
    end
    love.graphics.printf("< Prev", love.graphics.getWidth()/2 - 200, 450, 100, "left")
    
    -- Page indicator
    love.graphics.setColor(gameState.colors.ui)
    love.graphics.printf(string.format("Page %d/%d", gameState.state.currentPage, totalPages),
        0, 450, love.graphics.getWidth(), "center")
    
    -- Next page button
    if gameState.state.currentPage < totalPages then
        love.graphics.setColor(gameState.colors.ui)
    else
        love.graphics.setColor(gameState.colors.uiDark)
    end
    love.graphics.printf("Next >", love.graphics.getWidth()/2 + 100, 450, 100, "right")
    
    -- Draw instructions
    love.graphics.setColor(gameState.colors.ui)
    love.graphics.printf("Press Enter to select, Escape to return", 0, 500, love.graphics.getWidth(), "center")
    love.graphics.printf("Left/Right to change pages", 0, 520, love.graphics.getWidth(), "center")
end

return {
    drawMainMenu = drawMainMenu,
    drawSongSelect = drawSongSelect
}