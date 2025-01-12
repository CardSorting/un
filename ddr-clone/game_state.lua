-- Initialize fonts immediately when the module loads
local fonts = {
    title = love.graphics.newFont(48),
    large = love.graphics.newFont(32),
    medium = love.graphics.newFont(24),
    small = love.graphics.newFont(20),
    combo = love.graphics.newFont(36),
    multiplier = love.graphics.newFont(28)
}

local gameState = {
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

local editorState = {
    recording = false,
    currentTime = 0,
    arrows = {},
    songName = nil,
    audioPath = nil,
    currentMusic = nil,
    audioData = nil
}

local menuItems = {
    {text = "Play", action = function() gameState.current = "songSelect" end},
    {text = "Create Beat Map", action = function() gameState.current = "editor" end},
    {text = "Options", action = function() end},
    {text = "Exit", action = function() love.event.quit() end}
}

local colors = {
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

local hitSettings = {
    threshold = 45,
    perfect = 15
}

local function init()
    -- Any additional initialization if needed
    -- Fonts are already initialized at module load
end

-- Create a module table with all components
local module = {
    state = gameState,
    editor = editorState,
    menuItems = menuItems,
    colors = colors,
    hitSettings = hitSettings,
    fonts = fonts,
    init = init
}

-- Return the module
return module