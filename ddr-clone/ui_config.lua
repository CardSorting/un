return {
    -- Game area configuration
    gameArea = {
        width = 480,          -- Total width of gameplay area
        laneWidth = 100,      -- Width of each arrow lane
        arrowSize = 50,       -- Size of arrow sprites
        targetY = 150,        -- Target line height
        spawnY = 700         -- Arrow spawn position
    },
    
    -- Colors for gameplay elements
    colors = {
        -- Lane and arrow effects
        laneEffect = {1, 1, 1, 0.1},
        laneGuide = {1, 1, 1, 0.05},
        hitEffect = {1, 1, 1, 0.2},
        
        -- Hit ratings
        perfect = {0.3, 1, 0.3, 0.9},
        good = {0.3, 0.6, 1, 0.9},
        miss = {1, 0.3, 0.3, 0.9},
        
        -- UI elements
        panel = {0, 0, 0, 0.7},
        border = {1, 1, 1, 0.2},
        text = {1, 1, 1, 0.9}
    },
    
    -- Animation durations
    animation = {
        hitEffectDuration = 0.2,
        laneEffectDuration = 0.1,
        comboPopDuration = 0.1,
        ratingDuration = 0.4
    }
}