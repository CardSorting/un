local gameState = require('game_state')

local animations = {
    state = {
        time = 0,
        pulseScale = 1,
        waveOffset = 0,
        titleGlow = 0,
        selectedScale = 1,
        menuItemOffsets = {},
        bgRotation = 0,
        flashAlpha = 0,
        beatTime = 0,
        neonIntensity = 0,
        colorCycle = 0,
        beatPulse = 0,
        rainbowTime = 0,
        glowPhase = 0,
        pulsePhase = 0
    }
}

function animations.lerp(a, b, t)
    return a + (b - a) * t
end

function animations.getRainbowColor(offset)
    offset = offset or 0
    local time = animations.state.rainbowTime + offset
    return {
        0.5 + 0.5 * math.sin(time),
        0.5 + 0.5 * math.sin(time + math.pi * 2/3),
        0.5 + 0.5 * math.sin(time + math.pi * 4/3),
        1
    }
end

function animations.getNeonColor(offset)
    offset = offset or 0
    local time = animations.state.colorCycle + offset
    return {
        0.5 + 0.5 * math.sin(time),
        0.5 + 0.5 * math.sin(time + math.pi/3),
        1,
        1
    }
end

function animations.getPulseScale(baseScale, intensity, speed)
    return baseScale * (1 + intensity * math.sin(animations.state.beatTime * speed))
end

function animations.getGlowIntensity(baseIntensity, speed)
    return baseIntensity + 0.3 * math.sin(animations.state.time * speed)
end

function animations.update(dt)
    local state = animations.state
    state.time = state.time + dt
    state.beatTime = state.beatTime + dt
    state.pulseScale = 1 + 0.15 * math.sin(state.beatTime * 8)
    state.waveOffset = state.waveOffset + 200 * dt
    state.titleGlow = 0.7 + 0.3 * math.sin(state.time * 3)
    state.neonIntensity = 0.7 + 0.3 * math.sin(state.time * 5)
    state.flashAlpha = math.max(0, state.flashAlpha - dt * 2)
    state.colorCycle = (state.colorCycle + dt * 0.5) % (math.pi * 2)
    state.rainbowTime = (state.rainbowTime + dt) % (math.pi * 2)
    state.glowPhase = (state.glowPhase + dt * 2) % (math.pi * 2)
    state.pulsePhase = (state.pulsePhase + dt * 3) % (math.pi * 2)
    
    -- Update beat pulse with smoother transition
    state.beatPulse = math.max(0, state.beatPulse - dt * 4)
    if math.sin(state.beatTime * 8) > 0.9 then
        state.beatPulse = 1
    end
    
    -- Update background rotation
    state.bgRotation = state.bgRotation + 0.5
end

function animations.flash()
    animations.state.flashAlpha = 1
end

function animations.getBeatPulse()
    return animations.state.beatPulse * 0.3
end

function animations.reset()
    for k in pairs(animations.state) do
        if type(animations.state[k]) == "number" then
            animations.state[k] = 0
        elseif type(animations.state[k]) == "table" then
            animations.state[k] = {}
        end
    end
    animations.state.pulseScale = 1
end

return animations