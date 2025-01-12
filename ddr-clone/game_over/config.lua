return {
    -- Main panel layout
    panel = {
        width = 1200,              -- Increased from 900 for better use of screen space
        height = 800,              -- Increased from 650 for better vertical spacing
        cornerRadius = 25,         -- Slightly larger corners
        padding = {
            horizontal = 80,       -- Increased from 60
            vertical = 50          -- Increased from 40
        }
    },
    
    -- Layout sections
    sections = {
        -- Title section at top
        title = {
            height = 150,          -- Increased from 120
            spacing = 30           -- Increased from 20
        },
        
        -- Grade and score section
        grade = {
            height = 200,          -- Increased from 160
            gradeSize = 120,       -- Increased from 80
            scoreSpacing = 40      -- Increased from 30
        },
        
        -- Stats section
        stats = {
            width = 900,           -- Increased from 700
            height = 300,          -- Increased from 250
            padding = 40,          -- Increased from 30
            spacing = 35,          -- Increased from 25
            barHeight = 45,        -- Increased from 35
            labelWidth = 150,      -- Increased from 100
            valueWidth = 100       -- Increased from 80
        },
        
        -- Bottom section
        bottom = {
            height = 100,          -- Increased from 80
            spacing = 30           -- Increased from 20
        }
    },
    
    -- Visual effects
    effects = {
        glow = {
            size = 40,            -- Increased from 30
            intensity = 0.15
        },
        bars = {
            cornerRadius = 10,     -- Increased from 8
            glowSize = 4,         -- Increased from 3
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
            min = 30,             -- Increased from 20
            max = 40              -- Increased from 30
        },
        speed = {
            min = 80,             -- Increased from 60
            max = 160             -- Increased from 120
        },
        size = {
            min = 3,              -- Increased from 2
            max = 7               -- Increased from 5
        },
        fadeSpeed = 0.8
    }
}