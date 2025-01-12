return {
    name = "Pixel Dreams",
    audio = "assets/Pixel Dreams.mp3",
    difficulty = "Hard",
    bpm = 160,
    arrows = {
        -- Opening Burst (0-8 seconds)
        -- Rapid hold sequence
        {time = 1, direction = "left", holdLength = 0.5},
        {time = 1.25, direction = "right"}, -- Tap during hold
        {time = 1.5, direction = "up", holdLength = 0.5},
        {time = 1.75, direction = "down"}, -- Tap during hold
        
        -- Quick double holds
        {time = 2.5, direction = "left", holdLength = 0.75},
        {time = 2.5, direction = "right", holdLength = 0.75},
        {time = 3, direction = "up"}, -- Tap during holds
        {time = 3.25, direction = "down"}, -- Tap during holds
        
        -- Intensity Build (8-16 seconds)
        -- Triple hold challenge
        {time = 8, direction = "left", holdLength = 1.0},
        {time = 8, direction = "right", holdLength = 1.0},
        {time = 8, direction = "up", holdLength = 1.0},
        {time = 8.5, direction = "down"}, -- Tap during triple hold
        
        -- Quick release chain
        {time = 10, direction = "left", holdLength = 0.2},
        {time = 10.2, direction = "down", holdLength = 0.2},
        {time = 10.4, direction = "up", holdLength = 0.2},
        {time = 10.6, direction = "right", holdLength = 0.2},
        
        -- Technical Section (16-24 seconds)
        -- Hold and rapid tap combination
        {time = 16, direction = "left", holdLength = 2.0},
        {time = 16.25, direction = "up"}, -- Quick taps during hold
        {time = 16.5, direction = "right"},
        {time = 16.75, direction = "down"},
        {time = 17, direction = "up"},
        {time = 17.25, direction = "right"},
        
        -- Alternating long holds
        {time = 19, direction = "left", holdLength = 1.5},
        {time = 19.5, direction = "right"}, -- Tap during hold
        {time = 20, direction = "right", holdLength = 1.5},
        {time = 20.5, direction = "left"}, -- Tap during hold
        
        -- Complex Pattern (24-32 seconds)
        -- Quad hold with taps
        {time = 24, direction = "left", holdLength = 1.5},
        {time = 24, direction = "right", holdLength = 1.5},
        {time = 24, direction = "up", holdLength = 1.5},
        {time = 24, direction = "down", holdLength = 1.5},
        {time = 24.75, direction = "left"}, -- Release and retap
        {time = 25, direction = "right"}, -- Release and retap
        
        -- Rapid hold transitions
        {time = 27, direction = "left", holdLength = 0.15},
        {time = 27.15, direction = "down", holdLength = 0.15},
        {time = 27.3, direction = "up", holdLength = 0.15},
        {time = 27.45, direction = "right", holdLength = 0.15},
        
        -- Peak Intensity (32-40 seconds)
        -- Hold stream with crossovers
        {time = 32, direction = "left", holdLength = 0.5},
        {time = 32.25, direction = "up"},
        {time = 32.5, direction = "right", holdLength = 0.5},
        {time = 32.75, direction = "down"},
        {time = 33, direction = "left", holdLength = 0.5},
        {time = 33.25, direction = "up"},
        
        -- Triple hold with movement
        {time = 35, direction = "left", holdLength = 1.0},
        {time = 35, direction = "right", holdLength = 1.0},
        {time = 35, direction = "up", holdLength = 1.0},
        {time = 35.25, direction = "down"}, -- Tap during holds
        {time = 35.5, direction = "up"}, -- Quick switch
        {time = 35.75, direction = "down"}, -- Quick switch
        
        -- Endurance Test (40-48 seconds)
        -- Long hold with complex taps
        {time = 40, direction = "left", holdLength = 3.0},
        {time = 40.25, direction = "up"},
        {time = 40.5, direction = "right"},
        {time = 40.75, direction = "down"},
        {time = 41, direction = "up"},
        {time = 41.25, direction = "right"},
        {time = 41.5, direction = "down"},
        
        -- Quick release sequence
        {time = 44, direction = "left", holdLength = 0.1},
        {time = 44.1, direction = "down", holdLength = 0.1},
        {time = 44.2, direction = "right", holdLength = 0.1},
        {time = 44.3, direction = "up", holdLength = 0.1},
        {time = 44.4, direction = "left", holdLength = 0.1},
        {time = 44.5, direction = "down", holdLength = 0.1},
        
        -- Maximum Challenge (48-56 seconds)
        -- Quad hold with complex taps
        {time = 48, direction = "left", holdLength = 2.0},
        {time = 48, direction = "right", holdLength = 2.0},
        {time = 48, direction = "up", holdLength = 2.0},
        {time = 48, direction = "down", holdLength = 2.0},
        {time = 48.5, direction = "left"}, -- Release and retap sequence
        {time = 48.75, direction = "right"},
        {time = 49, direction = "up"},
        {time = 49.25, direction = "down"},
        
        -- Technical Finale (56-64 seconds)
        -- Rapid hold and release chain
        {time = 56, direction = "left", holdLength = 0.25},
        {time = 56.25, direction = "right", holdLength = 0.25},
        {time = 56.5, direction = "up", holdLength = 0.25},
        {time = 56.75, direction = "down", holdLength = 0.25},
        {time = 57, direction = "left", holdLength = 0.25},
        {time = 57.25, direction = "right", holdLength = 0.25},
        
        -- Ultimate Challenge (64-72 seconds)
        -- Triple hold with quad taps
        {time = 64, direction = "left", holdLength = 1.5},
        {time = 64, direction = "right", holdLength = 1.5},
        {time = 64, direction = "up", holdLength = 1.5},
        {time = 64.25, direction = "down"},
        {time = 64.5, direction = "left"}, -- Release and retap
        {time = 64.75, direction = "right"}, -- Release and retap
        
        -- Grand Finale (72-80 seconds)
        -- Ultimate hold combination
        {time = 72, direction = "left", holdLength = 1.0},
        {time = 72, direction = "right", holdLength = 1.0},
        {time = 72, direction = "up", holdLength = 1.0},
        {time = 72, direction = "down", holdLength = 1.0},
        {time = 72.5, direction = "left"}, -- Quad tap during quad hold
        {time = 72.5, direction = "right"},
        {time = 72.5, direction = "up"},
        {time = 72.5, direction = "down"},
        
        -- Epic ending sequence
        {time = 74, direction = "left", holdLength = 0.1},
        {time = 74.1, direction = "down", holdLength = 0.1},
        {time = 74.2, direction = "up", holdLength = 0.1},
        {time = 74.3, direction = "right", holdLength = 0.1},
        {time = 74.4, direction = "left", holdLength = 0.1},
        {time = 74.5, direction = "right", holdLength = 0.1},
        {time = 74.6, direction = "up", holdLength = 0.1},
        {time = 74.7, direction = "down", holdLength = 0.1},
        {time = 75, direction = "left"},
        {time = 75, direction = "right"},
        {time = 75, direction = "up"},
        {time = 75, direction = "down"} -- Final quad tap
    }
}