function debug()
	love.graphics.print("Weapon Cooldown: " .. player.weapon.cooldown, 5, 5)

	-- reset ship
	if love.keyboard.isDown("r") then
		player.x = window.width / 2
		player.y = window.height / 2
		player.xVelocity = 0
		player.yVelocity = 0
		player.rot = 0
	end
	
	--for i,v in pairs(player.bullets) do
		-- print debug information
	--end
end

-- TODO
-- mid point subdivision
function generateAsteroid(x, y, s)

	love.graphics.line(x, y - 4, x - 4, y, x, y + 4, x + 4, y)

--[[
	roughness = 12
	
	points = {}
	rand = math.rand()
	pointx[0] = s + rand * roughness
	for i=0, N do
		for j=0, M do
			points[2*j] = {}
			points[2*j].x = 0
			points[2*j].y = 0
		end
	
	end

	love.graphics.line()
	]]--
end


function drawUI()

end

-- returns false if co-ordinates are out of bounds (and object should be deleted)
function checkBounds(x, y)

end

function drawShip()
-- pushes matrix transormation
	love.graphics.push() 
	-- Moves origin to player for rotation
	love.graphics.translate(player.x, player.y)
	-- Rotates player around the origin
	love.graphics.rotate(player.rot)
	-- Moves origin back to draw
	love.graphics.translate(-player.x, -player.y)
	-- Draws player
	love.graphics.line(player.x - 5, player.y + 8, player.x, player.y - 8, player.x + 5, player.y + 8)
	love.graphics.line(player.x - 2.5, player.y + 4, player.x + 2.5, player.y + 4)
	if player.thrustEnabled == 1 then
		rand = math.random()
		if rand > 0.66 then
			love.graphics.line(player.x - 2.5, player.y + 4, player.x, player.y + 15, player.x + 2.5, player.y + 4)
		end
	end
	-- Restores the scenes matrix transformation
	love.graphics.pop() 
end

function drawBullets()
	for i,v in pairs(player.bullets) do
		love.graphics.push()
		love.graphics.translate(v.x, v.y)
		love.graphics.rotate(v.rot + math.pi / 2)
		love.graphics.translate(-v.x, -v.y)
		love.graphics.rectangle("fill", v.x, v.y, 5, 2)
		love.graphics.pop()
	end
end

-- Called on load
function love.load()
	-- variables
	settings = {}
	settings.enableDebug = 1
	game = {}
	game.score = 0
	
	window = {}
	window.width = love.graphics.getWidth()
	window.height = love.graphics.getHeight()

	-- player setup
	player = {}
	player.x = love.graphics.getWidth() /2
	player.y = love.graphics.getHeight() /2
	player.width = 10
	player.length = 15
	
	player.xVelocity = 0
	player.yVelocity = 0
	player.thrust = 100
	player.thrustEnabled = 0
	player.mass = 50
	
	player.rot = 0 -- Initial rotation
	
	player.weapon = {}
	player.weapon.velocity = 600
	player.weapon.firerate = 8 -- attacks per second
	player.weapon.cooldown = 0
	
	player.bullets = {}

	player.shoot = function()
		bullet = {}
		bullet.x = player.x
		bullet.y = player.y
		bullet.rot = player.rot
		bullet.xVelocity = player.weapon.velocity * math.sin(player.rot) + player.xVelocity
		bullet.yVelocity = player.weapon.velocity * -math.cos(player.rot) + player.yVelocity
		table.insert(player.bullets, bullet)
	end
end

-- Called before draw (once per frame)
function love.update(dt)
	-- looping ship at edges
	if player.x > window.width then
		player.x = 0
	elseif player.x < 0 then
		player.x = window.width
	end
	if player.y > window.height then
		player.y = 0
	elseif player.y < 0 then
		player.y = window.height
	end
	
	
	if love.keyboard.isDown("o") then
		settings.enableDebug = 1 - settings.enableDebug
	end
	if settings.enableDebug == 1 then
		debug()	
	end

	-- Player Controls
	if love.keyboard.isDown("right") then
		player.rot = player.rot + 2 * math.pi * dt
	end
	if love.keyboard.isDown("left") then
		player.rot = player.rot - 2 * math.pi * dt
	end
	if love.keyboard.isDown("up") then
		player.thrustEnabled = 1
		player.xVelocity = player.xVelocity + 100 * math.sin(player.rot) * player.thrust * dt / player.mass 
		player.yVelocity = player.yVelocity + 100 * -math.cos(player.rot) * player.thrust * dt / player.mass 
	else
		player.thrustEnabled = 0
	end
	
	player.weapon.cooldown = math.max(player.weapon.cooldown - dt, 0)
	
	if love.keyboard.isDown("space") and player.weapon.cooldown == 0 then
		player.weapon.cooldown = 1 / player.weapon.firerate
		player.shoot()
	end

	-- update player position
	player.x = player.x + player.xVelocity * dt
	player.y = player.y + player.yVelocity * dt


	-- Update bullet locations
	for i,v in pairs(player.bullets) do
		-- delete bullet if it is out of bounds
	
		v.x = v.x + v.xVelocity * dt
		v.y = v.y + v.yVelocity * dt
	end
	
	
	generateAsteroid(100, 100, 1)
	
end

-- Draws the scene
function love.draw()

	drawShip()
	
	drawBullets()
		
end