
local composer = require( "composer" )

local scene = composer.newScene()

-- Init. physics engine
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

local function dragger( self, event )
		local phase = event.phase
		local id 	= event.id
		if( phase == "began" ) then
			self.isFocus = true
			self.tempJoint = physics.newJoint( "touch", self, self.x, self.y )
			self.tempJoint.maxForce = 1e6
			self.tempJoint.dampingRatio = 0
			self.tempJoint.frequency = 2000
			display.currentStage:setFocus( self, id )
		elseif( self.isFocus ) then
			self.tempJoint:setTarget( event.x, event.y )
			if( phase == "ended" or phase == "cancelled" ) then
				self.isFocus = false
				display.currentStage:setFocus( self, nil )
				display.remove( self.tempJoint ) 
			end	
		end
		return false; 
	end;

-- Caculate x,y edges of bounds
local minX 			= 0
local maxX 			= display.actualContentWidth + display.screenOriginX
local minY 			= 0
local maxY 			= 240
local paddleRadius  = 25
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local puck

--Ability to move the ship
local function dragPuck(event)
    local puck = event.target
    local phase = event.phase

    if ("began" == phase) then
        -- Sets touch focus on the ship
        display.currentStage:setFocus(puck)
        -- Store initial offset position; wont be tapped directly in the middle
        puck.touchOffsetX = event.x - puck.x
		puck.touchOffsetY = event.y - puck.y
    elseif ("moved" == phase) then 
        -- Move the ship to the new touch position
        puck.x = puck.x - puck.touchOffsetX
		puck.y = puck.y - puck.touchOffsetY
    elseif ("ended "== phase or "cancelled" == phase) then 
        -- Release touch focus 
        display.currentStage:setFocus(nil)
    end

    return true -- prevents touch propogation to underlying objects
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- Set up display groups
	backGroup = display.newGroup() -- display group for background image
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup() -- display group for ship, asteroids, lasers etc
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup() -- display group for UI objects like score
	sceneGroup:insert(uiGroup)

		-- add to all corners, change to bg colour. stops ball gettings stuck in corenr
	local body = display.newRect(backGroup,display.screenOriginX, display.screenOriginY, 20, 20 )
	-- Add background to scene
	local background = display.newImageRect(backGroup, "assets/background.png", 320, 480)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local topgoal = display.newImageRect(backGroup, "assets/goal.png", 64, 16)
	topgoal.x = display.contentCenterX
	topgoal.y = display.screenOriginY

	local left = display.newImageRect(mainGroup,"assets/wall.png", 10,600)
	left.x = display.screenOriginX 
	left.y = 240
	physics.addBody(left, "static")

	local right = display.newImageRect(mainGroup,"assets/wall.png", 10,600)
	right.x = display.screenOriginX + display.actualContentWidth
	right.y = 240
	physics.addBody(right, "static")

	local top = display.newImageRect(mainGroup,"assets/wall.png", 10,600)
	top:rotate(90)
	top.x = display.screenOriginX
	top.y = display.screenOriginY
	physics.addBody(top, "static")
	
	local bot = display.newImageRect(mainGroup,"assets/wall.png", 10,600)
	bot:rotate(90)
	bot.x = display.screenOriginX
	bot.y = display.screenOriginY + display.actualContentHeight
	physics.addBody(bot, "static")

	puck = display.newImageRect(mainGroup, "assets/puck.png", 32, 32)
	puck.x = display.contentCenterX
	puck.y = display.contentCenterY
	physics.addBody(puck, "dynamic", {radius=16})
	puck.linearDamping = 1.1
	puck.isBullet = true

	puck.touch = dragger
	puck:addEventListener("touch")	

	paddle = display.newImageRect(mainGroup, "assets/paddle.png", 50, 50)
	paddle.x = display.contentCenterX - 50
	paddle.y = display.contentCenterY - 50
	physics.addBody(paddle, "dynamic", {radius=25})

	paddle.touch = dragger
	paddle:addEventListener("touch")	

	physics.addBody(body, "static")
	-- Add and enterFrame Listener to help limit movement
function paddle.enterFrame( self )
	if (self.x < minX + paddleRadius) then self.x = minX end
	if (self.x > maxX - paddleRadius) then self.x = maxX end
	if (self.y < minY) then self.y = minY end
	if (self.y > maxY) then self.y = maxY end
end; 
	Runtime:addEventListener("enterFrame", paddle)

end
-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		Runtime:addEventListener("enterFrame", paddle)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
