return {
    name = "Entropy Arcade",
    audio = "assets/Entropy Arcade.mp3",
    difficulty = "Medium",
    bpm = 140,
    arrows = {
        -- Warm-up Phase (0-8 seconds)
        -- Basic rhythm pattern with style
        {time = 1, direction = "left"},
        {time = 1.5, direction = "right"},
        {time = 2, direction = "left"},
        {time = 2.25, direction = "right"},
        
        -- Add up/down flow
        {time = 3, direction = "up"},
        {time = 3.5, direction = "down"},
        {time = 4, direction = "up"},
        {time = 4.25, direction = "down"},
        
        -- Dance Flow (8-16 seconds)
        -- Crossover pattern
        {time = 8, direction = "left"},
        {time = 8.5, direction = "up"},
        {time = 9, direction = "right"},
        {time = 9.5, direction = "down"},
        
        -- Quick steps
        {time = 10, direction = "left"},
        {time = 10.25, direction = "right"},
        {time = 10.5, direction = "left"},
        {time = 10.75, direction = "right"},
        
        -- First Technical Section (16-24 seconds)
        -- Triplet pattern
        {time = 16, direction = "left"},
        {time = 16.33, direction = "down"},
        {time = 16.66, direction = "right"},
        {time = 17, direction = "up"},
        {time = 17.33, direction = "down"},
        {time = 17.66, direction = "left"},
        
        -- Double steps with rhythm
        {time = 18, direction = "left"},
        {time = 18, direction = "down"},
        {time = 18.5, direction = "right"},
        {time = 18.5, direction = "up"},
        
        -- Groove Section (24-32 seconds)
        -- Syncopated pattern
        {time = 24, direction = "left"},
        {time = 24.75, direction = "right"},
        {time = 25, direction = "left"},
        {time = 25.75, direction = "right"},
        
        -- Quick alternations
        {time = 26, direction = "up"},
        {time = 26.25, direction = "down"},
        {time = 26.5, direction = "up"},
        {time = 26.75, direction = "down"},
        
        -- Build-up Section (32-40 seconds)
        -- Increasing complexity
        {time = 32, direction = "left"},
        {time = 32.5, direction = "right"},
        {time = 33, direction = "up"},
        {time = 33.25, direction = "down"},
        {time = 33.5, direction = "left"},
        {time = 33.75, direction = "right"},
        
        -- Double arrows with flow
        {time = 34, direction = "left"},
        {time = 34, direction = "up"},
        {time = 34.5, direction = "right"},
        {time = 34.5, direction = "down"},
        
        -- Technical Break (40-48 seconds)
        -- Complex step pattern
        {time = 40, direction = "left"},
        {time = 40.25, direction = "up"},
        {time = 40.5, direction = "right"},
        {time = 40.75, direction = "down"},
        {time = 41, direction = "left"},
        {time = 41.25, direction = "up"},
        
        -- Stream sequence
        {time = 42, direction = "left"},
        {time = 42.25, direction = "down"},
        {time = 42.5, direction = "up"},
        {time = 42.75, direction = "right"},
        
        -- Dance Climax (48-56 seconds)
        -- Advanced combinations
        {time = 48, direction = "left"},
        {time = 48, direction = "right"},
        {time = 48.5, direction = "up"},
        {time = 48.75, direction = "down"},
        
        -- Quick crossovers
        {time = 49, direction = "left"},
        {time = 49.25, direction = "up"},
        {time = 49.5, direction = "right"},
        {time = 49.75, direction = "down"},
        
        -- Peak Intensity (56-64 seconds)
        -- Complex doubles
        {time = 56, direction = "left"},
        {time = 56, direction = "up"},
        {time = 56.5, direction = "right"},
        {time = 56.5, direction = "down"},
        
        -- Rapid alternations
        {time = 57, direction = "left"},
        {time = 57.25, direction = "right"},
        {time = 57.5, direction = "left"},
        {time = 57.75, direction = "right"},
        
        -- Cool Down Phase (64-72 seconds)
        -- Rhythmic wind-down
        {time = 64, direction = "left"},
        {time = 64.5, direction = "right"},
        {time = 65, direction = "up"},
        {time = 65.5, direction = "down"},
        
        -- Final flourish
        {time = 66, direction = "left"},
        {time = 66, direction = "right"},
        {time = 66.5, direction = "up"},
        {time = 66.5, direction = "down"},
        {time = 67, direction = "left"},
        {time = 67.5, direction = "right"},
    }
}