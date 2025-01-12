function love.conf(t)
    t.window.width = 1920
    t.window.height = 1080
    t.window.title = "Sound Bozo"
    t.window.vsync = true
    
    -- Enable required modules
    t.modules.audio = true
    t.modules.sound = true
    t.modules.keyboard = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.math = true
end