return {
    name = "Beginner's Beat",
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
        
        -- Add up-down to the mix
        {time = 14, direction = "up"},
        {time = 15, direction = "down"},
        {time = 15.5, direction = "up"},
        {time = 16, direction = "down"},
        
        -- Simple Dance Pattern (16-24 seconds)
        -- Basic dance step simulation
        {time = 18, direction = "left"},
        {time = 19, direction = "right"},
        {time = 20, direction = "left"},
        {time = 20.5, direction = "right"},
        
        -- Add some groove
        {time = 22, direction = "up"},
        {time = 22.5, direction = "down"},
        {time = 23, direction = "up"},
        {time = 23.5, direction = "down"},
        
        -- First Challenge (24-32 seconds)
        -- Simple alternating with rhythm
        {time = 26, direction = "left"},
        {time = 26.5, direction = "right"},
        {time = 27, direction = "left"},
        {time = 27.5, direction = "right"},
        
        -- Basic diagonal flow
        {time = 28, direction = "left"},
        {time = 28.5, direction = "up"},
        {time = 29, direction = "right"},
        {time = 29.5, direction = "down"},
        
        -- Rest and Reset (32-36 seconds)
        -- Slower pattern for breather
        {time = 32, direction = "left"},
        {time = 33, direction = "right"},
        {time = 34, direction = "up"},
        {time = 35, direction = "down"},
        
        -- Simple Combinations (36-44 seconds)
        -- Introduce basic two-arrow patterns
        {time = 36, direction = "left"},
        {time = 36.5, direction = "right"},
        {time = 37, direction = "up"},
        {time = 37, direction = "down"},  -- First simultaneous arrows
        
        -- Flow pattern
        {time = 39, direction = "left"},
        {time = 39.5, direction = "up"},
        {time = 40, direction = "right"},
        {time = 40.5, direction = "down"},
        
        -- Dance Sequence (44-52 seconds)
        -- Simple but rhythmic pattern
        {time = 44, direction = "left"},
        {time = 44.5, direction = "right"},
        {time = 45, direction = "left"},
        {time = 45.25, direction = "right"},
        
        -- Add some style
        {time = 46, direction = "up"},
        {time = 46.5, direction = "down"},
        {time = 47, direction = "up"},
        {time = 47.25, direction = "down"},
        
        -- Final Challenge (52-60 seconds)
        -- Combine everything learned
        {time = 52, direction = "left"},
        {time = 52.5, direction = "right"},
        {time = 53, direction = "up"},
        {time = 53.5, direction = "down"},
        
        -- Simple crossover pattern
        {time = 54, direction = "left"},
        {time = 54.5, direction = "up"},
        {time = 55, direction = "right"},
        {time = 55.5, direction = "down"},
        
        -- Basic two-arrow finale
        {time = 56, direction = "left"},
        {time = 56, direction = "right"},
        {time = 57, direction = "up"},
        {time = 57, direction = "down"},
        
        -- Cool Down (60-64 seconds)
        -- Simple ending sequence
        {time = 60, direction = "left"},
        {time = 61, direction = "right"},
        {time = 62, direction = "up"},
        {time = 63, direction = "down"},
        
        -- Final notes
        {time = 64, direction = "left"},
        {time = 64.5, direction = "right"},
    }
}