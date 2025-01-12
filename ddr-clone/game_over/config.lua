return {
    -- Main panel layout
    panel = {
        width = 900,              -- Wider panel for better spacing
        height = 650,             -- Taller panel for content
        cornerRadius = 20,
        padding = {
            horizontal = 60,      -- Padding from panel edges
            vertical = 40
        }
    },
    
    -- Layout sections
    sections = {
        -- Title section at top
        title = {
            height = 120,
            spacing = 20
        },
        
        -- Grade and score section
        grade = {
            height = 160,
            gradeSize = 80,       -- Size of grade letter
            scoreSpacing = 30     -- Space between grade and score
        },
        
        -- Stats section
        stats = {
            width = 700,          -- Width of stats container
            height = 250,         -- Height of stats container
            padding = 30,         -- Internal padding
            spacing = 25,         -- Space between stats
            barHeight = 35,       -- Height of stat bars
            labelWidth = 100,     -- Width for labels
            valueWidth = 80       -- Width for values
        },
        
        -- Bottom section
        bottom = {
            height = 80,
            spacing = 20
        }
    },
    
    -- Visual effects
    effects = {
        glow = {
            size = 30,
            intensity = 0.15
        },
        bars = {
            cornerRadius = 8,
            glowSize = 3,
            glowIntensity = 0.3
        }
    },
    
    -- Colors
    colors = {
        overlay = {
            top = {0, 0, 0, 0.8},
            bottom = {0, 0, 0, 0.9}
        },
        panel = {
            background = {0.08, 0.08, 0.12, 0.95},
            border = {1, 1, 1, 0.15},
            glow = {1, 1, 1, 0.1},
            divider = {1, 1, 1, 0.1}
        },
        grade = {
            S = {1, 0.95, 0.2, 1},      -- Gold
            A = {0.2, 1, 0.4, 1},       -- Green
            B = {0.2, 0.6, 1, 1},       -- Blue
            C = {1, 0.6, 0.2, 1},       -- Orange
            D = {1, 0.3, 0.3, 1}        -- Red
        },
        stats = {
            perfect = {0.3, 1, 0.3, 0.9},
            good = {0.3, 0.6, 1, 0.9},
            miss = {1, 0.3, 0.3, 0.9},
            label = {1, 1, 1, 0.9},
            value = {1, 1, 1, 0.8},
            background = {0.12, 0.12, 0.15, 0.6}
        },
        text = {
            primary = {1, 1, 1, 1},
            secondary = {0.8, 0.8, 0.8, 0.9},
            highlight = {1, 0.95, 0.7, 1}
        }
    },
    
    -- Animations
    animation = {
        fadeIn = {
            duration = 0.4,
            delay = 0.1
        },
        grade = {
            duration = 0.6,
            delay = 0.5,
            pulseSpeed = 2,
            pulseAmount = 0.1
        },
        score = {
            duration = 1.2,
            delay = 0.8,
            countSpeed = 1.5
        },
        stats = {
            duration = 0.8,
            delay = 1.0,
            stagger = 0.15        -- Delay between each stat bar
        },
        prompt = {
            pulseSpeed = 2,
            pulseAmount = 0.15
        }
    },
    
    -- Particles
    particles = {
        spawnRate = 0.1,
        count = {
            min = 20,
            max = 30
        },
        speed = {
            min = 60,
            max = 120
        },
        size = {
            min = 2,
            max = 5
        },
        fadeSpeed = 0.8
    }
}