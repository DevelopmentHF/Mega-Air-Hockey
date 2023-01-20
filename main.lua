-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local widget = require("widget")

-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

-- Seed the random number generation
math.randomseed(os.time())

-- Go to the menu screen
composer.gotoScene("game")

-- Enable multitouch
system.activate("multitouch")