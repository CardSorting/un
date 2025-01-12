local menuUI = require('menu/menu_ui')

-- Initialize menu system
menuUI.init()

-- Return the public interface
return {
    drawMainMenu = menuUI.drawMainMenu,
    drawSongSelect = menuUI.drawSongSelect,
    cleanup = menuUI.cleanup
}