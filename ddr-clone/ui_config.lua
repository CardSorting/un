return {
    -- Game area configuration
    gameArea = {
        width = 800,          -- Total width of gameplay area
        laneWidth = 200,      -- Increased from 160 for better spacing between lanes
        arrowSize = 80,       -- Size of arrow sprites
        targetY = 200,        -- Target line height
        spawnY = 900         -- Arrow spawn position
    },
    
    -- Colors for gameplay elements
    colors = {
        -- Lane and arrow effects
        laneEffect = {1, 1, 1, 0.1},
        laneGuide = {1, 1, 1, 0.05},
        hitEffect = {1, 1, 1, 0.2},
        
        -- Hit ratings with enhanced colors
        perfect = {0.3, 1, 0.3, 0.9},
        good = {0.3, 0.6, 1, 0.9},
        miss = {1, 0.3, 0.3, 0.9},
        
        -- UI elements with arcade-style colors
        panel = {0, 0, 0, 0.7},
        border = {1, 1, 1, 0.2},
        text = {1, 1, 1, 0.9},
        
        -- Progress elements
        progress = {0.2, 0.4, 0.8, 0.5},
        progressFill = {0.4, 0.8, 1, 0.9},
        
        -- Health bar colors
        health = {0.3, 1, 0.3, 0.9},
        healthLow = {1, 0.3, 0.3, 0.9},
        
        -- Score and combo colors
        score = {1, 0.8, 0.2, 0.9},
        combo = {1, 0.5, 0.1, 0.9},
        multiplier = {1, 0.8, 0.2, 0.9},
        
        -- UI accent colors
        ui = {0.9, 0.9, 1, 0.9},
        uiDark = {0.5, 0.5, 0.6, 0.7},
        
        -- Neon effect colors
        neonBlue = {0.4, 0.8, 1, 0.9},
        neonPink = {1, 0.4, 0.8, 0.9},
        neonGreen = {0.4, 1, 0.8, 0.9},
        
        -- Particle effect colors
        particleNeon = {0.6, 0.9, 1, 0.8},
        particleEnergy = {1, 0.8, 0.4, 0.8},
        particleSpark = {1, 1, 1, 0.9}
    },
    
    -- Animation durations and timings
    animation = {
        hitEffectDuration = 0.2,
        laneEffectDuration = 0.1,
        comboPopDuration = 0.1,
        ratingDuration = 0.4,
        
        -- New animation timings
        glowPulseDuration = 0.5,
        particleLifetime = 1.0,
        shockwaveDuration = 0.6,
        colorCycleSpeed = 2.0,
        beatPulseSpeed = 8.0,
        menuItemPulse = 0.8,
        titlePulse = 1.2,
        
        -- Transition speeds
        fadeInSpeed = 0.5,
        fadeOutSpeed = 0.3,
        scalePulseSpeed = 4.0
    }
}