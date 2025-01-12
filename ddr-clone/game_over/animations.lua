local config = require('game_over/config')

local animations = {
    state = {
        fadeIn = 0,
        scoreCount = 0,
        graphProgress = {},
        badgeRotations = {},
        particles = {},
        particleTimer = 0
    }
}

function animations.reset()
    animations.state = {
        fadeIn = 0,
        scoreCount = 0,
        graphProgress = {
            perfect = 0,
            good = 0,
            miss = 0
        },
        badgeRotations = {},
        particles = {},
        particleTimer = 0
    }
end

function animations.createParticle()
    local particles = config.particles
    return {
        x = love.math.random(0, love.graphics.getWidth()),
        y = love.graphics.getHeight() + particles.size.max,
        speed = love.math.random(particles.speed.min, particles.speed.max),
        size = love.math.random(particles.size.min, particles.size.max),
        color = love.math.random(),
        rotation = love.math.random() * math.pi * 2,
        alpha = 1
    }
end

function animations.update(dt)
    local state = animations.state
    local anim = config.animation
    
    -- Update fade in
    if state.fadeIn < 1 then
        state.fadeIn = math.min(1, state.fadeIn + dt / anim.fadeIn.duration)
    end
    
    -- Update score counter after delay
    if state.fadeIn >= anim.score.delay and state.scoreCount < 1 then
        state.scoreCount = math.min(1, state.scoreCount + dt * anim.score.countSpeed)
    end
    
    -- Update graph progress after score
    if state.scoreCount >= anim.stats.delay then
        for stat, progress in pairs(state.graphProgress) do
            state.graphProgress[stat] = math.min(1, progress + dt / anim.stats.duration)
        end
    end
    
    -- Update badge rotations
    for badge, rotation in pairs(state.badgeRotations) do
        state.badgeRotations[badge] = rotation + dt * anim.prompt.pulseSpeed
    end
    
    -- Update particles
    state.particleTimer = state.particleTimer + dt
    if state.particleTimer >= config.particles.spawnRate then
        state.particleTimer = 0
        table.insert(state.particles, animations.createParticle())
    end
    
    -- Update existing particles
    for i = #state.particles, 1, -1 do
        local p = state.particles[i]
        p.y = p.y - p.speed * dt
        p.rotation = p.rotation + dt
        p.alpha = p.alpha - dt * config.particles.fadeSpeed
        if p.alpha <= 0 then
            table.remove(state.particles, i)
        end
    end
end

return animations