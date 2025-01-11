function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.title = "Rhythm Game"
    t.window.vsync = true
    
    -- Enable required modules
    t.modules.audio = true
    t.modules.sound = true
    t.modules.keyboard = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.math = true
end