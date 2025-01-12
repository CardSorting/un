local config = require('game_over/config')
local animations = require('game_over/animations')
local renderer = require('game_over/renderer')

local gameOver = {}

-- Initialize the game over screen
function gameOver.reset()
    animations.reset()
end

-- Update animations and effects
function gameOver.update(dt)
    animations.update(dt)
end

-- Draw the game over screen
function gameOver.draw(gameState, colors, fonts)
    renderer.draw(gameState, animations, fonts)
end

return gameOver