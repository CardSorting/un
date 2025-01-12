return {
    name = "Electric Gradient",
    audio = "assets/Electric Gradient.mp3",
    difficulty = "Easy",
    bpm = 120,
    arrows = {
        -- Tutorial Phase (0-8 seconds)
        -- Single arrows with clear spacing
        {time = 2, direction = "left"},
        {time = 4, direction = "right"},
        {time = 6, direction = "up"},
        {time = 8, direction = "down"},
        
        -- Basic Flow Phase (8-16 seconds)
        -- Simple left-right patterns
        {time = 10, direction = "left"},
        {time = 11, direction = "right"},
        {time = 12, direction = "left"},
        {time = 13, direction = "right"},
        
        -- Introduce basic hold note
        {time = 14, direction = "up", holdLength = 1.0}, -- 1 second hold
        {time = 15.5, direction = "down"},
        {time = 16, direction = "up"},
        
        -- Simple Dance Pattern (16-24 seconds)
        -- Basic dance step with holds
        {time = 18, direction = "left"},
        {time = 19, direction = "right", holdLength = 0.5}, -- Short hold
        {time = 20, direction = "left"},
        {time = 20.5, direction = "right"},
        
        -- Add some groove with alternating holds
        {time = 22, direction = "up", holdLength = 0.75},
        {time = 23, direction = "down", holdLength = 0.75},
        
        -- First Challenge (24-32 seconds)
        -- Hold and tap combinations
        {time = 26, direction = "left", holdLength = 1.0},
        {time = 26.5, direction = "right"}, -- Tap during hold
        {time = 27.5, direction = "up"},
        
        -- Basic diagonal flow with hold
        {time = 28, direction = "left"},
        {time = 28.5, direction = "up", holdLength = 1.0},
        {time = 29, direction = "right"}, -- Tap during hold
        {time = 29.5, direction = "down"},
        
        -- Rest and Reset (32-36 seconds)
        -- Long hold practice
        {time = 32, direction = "left", holdLength = 2.0}, -- Long hold
        {time = 34, direction = "right"},
        {time = 35, direction = "up"},
        
        -- Simple Combinations (36-44 seconds)
        -- Hold and simultaneous taps
        {time = 36, direction = "left", holdLength = 1.5},
        {time = 36.5, direction = "right"}, -- Tap during hold
        {time = 37, direction = "up"},
        {time = 37, direction = "down"}, -- Simultaneous arrows
        
        -- Flow pattern with holds
        {time = 39, direction = "left", holdLength = 0.5},
        {time = 39.5, direction = "up", holdLength = 0.5},
        {time = 40, direction = "right", holdLength = 0.5},
        {time = 40.5, direction = "down", holdLength = 0.5},
        
        -- Dance Sequence (44-52 seconds)
        -- Hold and release rhythm
        {time = 44, direction = "left", holdLength = 0.75},
        {time = 44.5, direction = "right"},
        {time = 45, direction = "left", holdLength = 0.5},
        {time = 45.25, direction = "right"},
        
        -- Complex hold pattern
        {time = 46, direction = "up", holdLength = 1.0},
        {time = 46.5, direction = "down"}, -- Tap during hold
        {time = 47, direction = "up"},
        {time = 47.25, direction = "down", holdLength = 0.75},
        
        -- Final Challenge (52-60 seconds)
        -- Advanced hold combinations
        {time = 52, direction = "left", holdLength = 1.0},
        {time = 52.5, direction = "right"}, -- Tap during hold
        {time = 53, direction = "up", holdLength = 0.75},
        {time = 53.5, direction = "down"}, -- Tap during hold
        
        -- Hold and crossover pattern
        {time = 54, direction = "left", holdLength = 1.5},
        {time = 54.5, direction = "up"}, -- Tap during hold
        {time = 55, direction = "right", holdLength = 1.0},
        {time = 55.5, direction = "down"}, -- Tap during hold
        
        -- Complex two-arrow finale
        {time = 56, direction = "left", holdLength = 1.0},
        {time = 56, direction = "right", holdLength = 1.0}, -- Simultaneous holds
        {time = 57, direction = "up"},
        {time = 57, direction = "down"},
        
        -- Advanced Pattern (60-68 seconds)
        -- Hold chain sequence
        {time = 60, direction = "left", holdLength = 0.5},
        {time = 60.5, direction = "down", holdLength = 0.5},
        {time = 61, direction = "up", holdLength = 0.5},
        {time = 61.5, direction = "right", holdLength = 0.5},
        
        -- Hold and tap combinations
        {time = 62, direction = "left", holdLength = 1.0},
        {time = 62.25, direction = "up"}, -- Quick tap during hold
        {time = 62.5, direction = "right"}, -- Another tap during hold
        {time = 62.75, direction = "down"}, -- Final tap during hold
        
        -- Rapid hold transitions
        {time = 64, direction = "left", holdLength = 0.25},
        {time = 64.25, direction = "right", holdLength = 0.25},
        {time = 64.5, direction = "up", holdLength = 0.25},
        {time = 64.75, direction = "down", holdLength = 0.25},
        
        -- Grand Finale (68-72 seconds)
        -- Complex hold combinations
        {time = 68, direction = "left", holdLength = 1.0},
        {time = 68, direction = "right", holdLength = 1.0}, -- Simultaneous holds
        {time = 69, direction = "up", holdLength = 0.5},
        {time = 69.5, direction = "down", holdLength = 0.5},
        
        -- Final sequence
        {time = 70, direction = "left", holdLength = 0.75},
        {time = 70.5, direction = "right"},
        {time = 71, direction = "up", holdLength = 0.75},
        {time = 71.5, direction = "down"},
        
        -- End with style
        {time = 72, direction = "left"},
        {time = 72, direction = "right"},
        {time = 72, direction = "up"},
        {time = 72, direction = "down"}, -- Quad finish
    }
}