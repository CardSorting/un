-- Initialize fonts immediately when the module loads
local fonts = {
    title = love.graphics.newFont(64),  -- Increased for more impact
    large = love.graphics.newFont(36),  -- Increased for better visibility
    medium = love.graphics.newFont(28), -- Adjusted for balance
    small = love.graphics.newFont(20),
    combo = love.graphics.newFont(48),  -- Increased for dramatic effect
    multiplier = love.graphics.newFont(32),
    neon = love.graphics.newFont(42),   -- New font for neon effects
    header = love.graphics.newFont(52)  -- New font for section headers
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

local gameState = {
    current = "mainMenu",  -- mainMenu, songSelect, game, gameover, editor
    score = 0,
    combo = 0,
    maxCombo = 0,
    health = 100,
    selectedMenuItem = 1,
    selectedSong = 1,
    currentPage = 1,
    songsPerPage = 3,
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
    editor = editorState,  -- Initialize editor state properly
    
    -- Enhanced animation states
    menuAnimations = {
        titleGlow = 0,
        selectedScale = 1,
        colorCycle = 0,
        beatPulse = 0,
        particleTimer = 0,
        shockwaveTimer = 0,
        flashIntensity = 0,
        energyWaveOffset = 0,
        neonIntensity = 0
    },
    
    -- Enhanced visual effects states
    visualEffects = {
        glowIntensity = 1,
        pulseScale = 1,
        beatSync = 0,
        particleCount = 0,
        shockwaves = {},
        energyWaves = {},
        activeParticles = {},
        colorPhase = 0
    },
    
    laneEffects = {
        left = 0,
        down = 0,
        up = 0,
        right = 0
    },
    hitEffects = {}
}

local menuItems = {
    {text = "Play", action = function() gameState.current = "songSelect" end},
    {text = "Create Beat Map", action = function() gameState.current = "editor" end},
    {text = "Options", action = function() end},
    {text = "Exit", action = function() love.event.quit() end}
}

local colors = {
    background = {0.1, 0.1, 0.15, 1},  -- Added alpha
    ui = {0.9, 0.95, 1, 1},           -- Added alpha
    uiDark = {0.5, 0.6, 0.7, 1},      -- Added alpha
    health = {0.2, 1, 0.4, 1},        -- Added alpha
    healthLow = {1, 0.2, 0.3, 1},     -- Added alpha
    combo = {1, 0.8, 0.2, 1},         -- Added alpha
    perfect = {0.3, 1, 0.5, 1},       -- Added alpha
    good = {0.4, 0.6, 1, 1},          -- Added alpha
    miss = {1, 0.3, 0.4, 1},          -- Added alpha
    progress = {0.3, 0.5, 0.9, 1},    -- Added alpha
    progressFill = {0.5, 0.8, 1, 1},  -- Added alpha
    multiplier = {1, 0.5, 0.8, 1},    -- Added alpha
    laneEffect = {1, 1, 1, 0.25},     -- Already had alpha
    
    -- New color schemes for enhanced effects
    neon = {
        blue = {0.4, 0.8, 1, 1},      -- Added alpha
        pink = {1, 0.4, 0.8, 1},      -- Added alpha
        green = {0.4, 1, 0.8, 1},     -- Added alpha
        yellow = {1, 0.9, 0.4, 1},    -- Added alpha
        purple = {0.8, 0.4, 1, 1}     -- Added alpha
    },
    
    particles = {
        energy = {0.6, 0.9, 1, 1},    -- Added alpha
        spark = {1, 0.95, 0.8, 1},    -- Added alpha
        trail = {0.4, 0.8, 1, 1}      -- Added alpha
    }
}

local hitSettings = {
    threshold = 45,
    perfect = 15
}

local function init()
    -- Reset editor state
    gameState.editor = {
        recording = false,
        currentTime = 0,
        arrows = {},
        songName = nil,
        audioPath = nil,
        currentMusic = nil,
        audioData = nil
    }
end

-- Create a module table with all components
local module = {
    state = gameState,
    editor = gameState.editor,  -- Use the editor state from gameState
    menuItems = menuItems,
    colors = colors,
    hitSettings = hitSettings,
    fonts = fonts,
    init = init
}

-- Return the module
return module