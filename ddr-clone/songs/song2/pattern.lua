return {
    name = "Entropy Arcade",
    audio = "assets/Entropy Arcade.mp3",
    difficulty = "Medium",
    bpm = 140,
    arrows = {
        -- Opening Sequence (0-8 seconds)
        -- Quick hold patterns
        {time = 2, direction = "left", holdLength = 0.75},
        {time = 3, direction = "right", holdLength = 0.75},
        {time = 4, direction = "up", holdLength = 0.75},
        {time = 5, direction = "down", holdLength = 0.75},
        
        -- Build-up Phase (8-16 seconds)
        -- Hold and tap combinations
        {time = 8, direction = "left", holdLength = 1.0},
        {time = 8.5, direction = "right"}, -- Tap during hold
        {time = 9, direction = "up", holdLength = 1.0},
        {time = 9.5, direction = "down"}, -- Tap during hold
        
        -- Quick alternating holds
        {time = 11, direction = "left", holdLength = 0.5},
        {time = 11.5, direction = "right", holdLength = 0.5},
        {time = 12, direction = "up", holdLength = 0.5},
        {time = 12.5, direction = "down", holdLength = 0.5},
        
        -- First Intensity (16-24 seconds)
        -- Simultaneous holds with taps
        {time = 16, direction = "left", holdLength = 1.5},
        {time = 16, direction = "right", holdLength = 1.5},
        {time = 16.75, direction = "up"}, -- Tap during holds
        {time = 17.25, direction = "down"}, -- Tap during holds
        
        -- Quick release chain
        {time = 19, direction = "left", holdLength = 0.25},
        {time = 19.25, direction = "down", holdLength = 0.25},
        {time = 19.5, direction = "up", holdLength = 0.25},
        {time = 19.75, direction = "right", holdLength = 0.25},
        
        -- Complex Pattern (24-32 seconds)
        -- Hold and crossover
        {time = 24, direction = "left", holdLength = 2.0},
        {time = 24.5, direction = "up"}, -- Tap during hold
        {time = 25, direction = "right"}, -- Tap during hold
        {time = 25.5, direction = "down"}, -- Tap during hold
        
        -- Double holds with taps
        {time = 27, direction = "left", holdLength = 1.0},
        {time = 27, direction = "right", holdLength = 1.0},
        {time = 27.5, direction = "up"},
        {time = 28, direction = "down"},
        
        -- Intensity Build (32-40 seconds)
        -- Rapid hold transitions
        {time = 32, direction = "left", holdLength = 0.3},
        {time = 32.3, direction = "down", holdLength = 0.3},
        {time = 32.6, direction = "up", holdLength = 0.3},
        {time = 32.9, direction = "right", holdLength = 0.3},
        
        -- Hold streams
        {time = 34, direction = "left", holdLength = 0.5},
        {time = 34.25, direction = "right"},
        {time = 34.5, direction = "up", holdLength = 0.5},
        {time = 34.75, direction = "down"},
        
        -- Peak Intensity (40-48 seconds)
        -- Triple hold pattern
        {time = 40, direction = "left", holdLength = 1.0},
        {time = 40, direction = "right", holdLength = 1.0},
        {time = 40, direction = "up", holdLength = 1.0},
        {time = 40.5, direction = "down"}, -- Tap during holds
        
        -- Quick release sequence
        {time = 42, direction = "left", holdLength = 0.2},
        {time = 42.2, direction = "down", holdLength = 0.2},
        {time = 42.4, direction = "right", holdLength = 0.2},
        {time = 42.6, direction = "up", holdLength = 0.2},
        
        -- Technical Section (48-56 seconds)
        -- Hold and tap precision
        {time = 48, direction = "left", holdLength = 1.5},
        {time = 48.25, direction = "up"}, -- Quick tap
        {time = 48.5, direction = "down"}, -- Quick tap
        {time = 48.75, direction = "right"}, -- Quick tap
        
        -- Alternating holds with taps
        {time = 50, direction = "left", holdLength = 0.75},
        {time = 50.25, direction = "right"}, -- Tap during hold
        {time = 50.75, direction = "up", holdLength = 0.75},
        {time = 51, direction = "down"}, -- Tap during hold
        
        -- Climax Section (56-64 seconds)
        -- Complex hold combinations
        {time = 56, direction = "left", holdLength = 1.0},
        {time = 56, direction = "right", holdLength = 1.0},
        {time = 56.5, direction = "up", holdLength = 0.5},
        {time = 57, direction = "down", holdLength = 0.5},
        
        -- Rapid transitions
        {time = 58, direction = "left", holdLength = 0.25},
        {time = 58.25, direction = "up", holdLength = 0.25},
        {time = 58.5, direction = "right", holdLength = 0.25},
        {time = 58.75, direction = "down", holdLength = 0.25},
        
        -- Final Challenge (64-72 seconds)
        -- Hold endurance test
        {time = 64, direction = "left", holdLength = 2.0},
        {time = 64.5, direction = "right"}, -- Tap during hold
        {time = 65, direction = "up"}, -- Tap during hold
        {time = 65.5, direction = "down"}, -- Tap during hold
        
        -- Quick release chain
        {time = 67, direction = "left", holdLength = 0.2},
        {time = 67.2, direction = "right", holdLength = 0.2},
        {time = 67.4, direction = "up", holdLength = 0.2},
        {time = 67.6, direction = "down", holdLength = 0.2},
        
        -- Grand Finale (72-80 seconds)
        -- Quad hold pattern
        {time = 72, direction = "left", holdLength = 1.0},
        {time = 72, direction = "right", holdLength = 1.0},
        {time = 72, direction = "up", holdLength = 1.0},
        {time = 72, direction = "down", holdLength = 1.0},
        
        -- Final burst
        {time = 74, direction = "left", holdLength = 0.5},
        {time = 74.5, direction = "right", holdLength = 0.5},
        {time = 75, direction = "up", holdLength = 0.5},
        {time = 75.5, direction = "down", holdLength = 0.5},
        
        -- Epic ending
        {time = 76, direction = "left", holdLength = 0.25},
        {time = 76.25, direction = "down", holdLength = 0.25},
        {time = 76.5, direction = "up", holdLength = 0.25},
        {time = 76.75, direction = "right", holdLength = 0.25},
        {time = 77, direction = "left"},
        {time = 77, direction = "right"},
        {time = 77, direction = "up"},
        {time = 77, direction = "down"} -- Final quad tap
    }
}