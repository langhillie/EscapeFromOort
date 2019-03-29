function debug()
	love.graphics.print("Weapon Cooldown: " .. player.weapon.cooldown, 5, 5)

end

-- Draws triangular ship
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
	love.graphics.rectangle("line", player.x - player.width / 2, player.y - player.length / 2, player.width, player.length)
	-- Restores the scenes matrix transformation
	love.graphics.pop() 
end

function drawBullets()
	for i,v in pairs(player.bullets) do
		love.graphics.push()
		love.graphics.translate(v.x, v.y)
		love.graphics.rotate(v.rot)
		love.graphics.translate(-v.x, -v.y)
		love.graphics.rectangle("fill", v.x, v.y, 5, 2)
		love.graphics.pop()
	end
end

function love.load()
	-- variables
	enableDebug = 1


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
	player.weapon.velocity = 500
	player.weapon.firerate = 8 -- attacks per second
	player.weapon.cooldown = 0
	
	player.bullets = {}

	player.shoot = function()
		bullet = {}
		bullet.x = player.x
		bullet.y = player.y
		bullet.rot = player.rot
		bullet.xVelocity = (player.weapon.velocity + player.xVelocity) * math.cos(player.rot)
		bullet.yVelocity = (player.weapon.velocity + player.yVelocity) * math.sin(player.rot)
		table.insert(player.bullets, bullet)
	end
end

function love.update(dt)
	if love.keyboard.isDown("o") then
		enableDebug = 1 - enableDebug
	end
	if enableDebug == 1 then
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
		player.xVelocity = player.xVelocity + 100 * math.cos(player.rot) * player.thrust * dt / player.mass 
		player.yVelocity = player.yVelocity + 100 * math.sin(player.rot) * player.thrust * dt / player.mass 
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
		v.x = v.x + v.xVelocity * dt
		v.y = v.y + v.yVelocity * dt
	end
end

function love.draw()

	drawShip()
	
	drawBullets()
		
end