local gameState = require('game_state')

local menuAudio = {
    menuMusic = nil,
    previewSystem = {
        currentPreview = nil,
        lastSelectedSong = nil,
        previewStartTime = 0,
        fadeVolume = 1,
        crossfadeTime = 0.3
    }
}

function menuAudio.init()
    menuAudio.menuMusic = love.audio.newSource("assets/Z Fighter's Anthem.mp3", "stream")
    menuAudio.menuMusic:setLooping(true)
    menuAudio.menuMusic:setVolume(0.8)
    menuAudio.menuMusic:play()
end

function menuAudio.updatePreview(selectedSong, songs)
    local preview = menuAudio.previewSystem
    if selectedSong ~= preview.lastSelectedSong then
        if preview.currentPreview then
            preview.currentPreview:stop()
            preview.currentPreview = nil
        end
        
        if selectedSong and songs[selectedSong] and songs[selectedSong].music then
            menuAudio.menuMusic:setVolume(0)
            preview.currentPreview = songs[selectedSong].music
            preview.currentPreview:setVolume(1.0)
            preview.currentPreview:play()
            preview.previewStartTime = love.timer.getTime()
        else
            menuAudio.menuMusic:setVolume(0.8)
        end
        
        preview.lastSelectedSong = selectedSong
    end
end

function menuAudio.resetPreview()
    local preview = menuAudio.previewSystem
    if preview.currentPreview then
        preview.currentPreview:stop()
        preview.currentPreview = nil
        preview.lastSelectedSong = nil
        menuAudio.menuMusic:setVolume(0.8)
    end
end

function menuAudio.cleanup()
    if menuAudio.menuMusic then
        menuAudio.menuMusic:stop()
    end
    menuAudio.resetPreview()
end

return menuAudio