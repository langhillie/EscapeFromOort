function debug()


end



function love.load()
	-- variables
	enableDebug = 0


	-- player setup
	player = {}
	player.x = love.graphics.getWidth() /2
	player.y = love.graphics.getHeight() /2
	player.width = 10
	player.length = 15
	
	player.xVelocity = 0
	player.yVelocity = 0
	player.thrust = 10
	player.mass = 300
	
	player.rot = 0 -- Initial rotation
	
	player.weapon = {}
	player.weapon.velocity = 8
	player.weapon.firerate = 5 -- attacks per second
	
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

	-- Player Controls
	if love.keyboard.isDown("right") then
		player.rot = player.rot + 0.1
	end
	if love.keyboard.isDown("left") then
		player.rot = player.rot - 0.1
	end
	if love.keyboard.isDown("up") then
		player.xVelocity = player.xVelocity + math.cos(player.rot) * player.thrust / player.mass
		player.yVelocity = player.yVelocity + math.sin(player.rot) * player.thrust / player.mass
	end
	
	if love.keyboard.isDown("space") then
		player.shoot()
	end

	-- update player position
	player.x = player.x + player.xVelocity
	player.y = player.y + player.yVelocity


	-- Update bullet locations
	for i,v in pairs(player.bullets) do
		v.x = v.x + v.xVelocity
		v.y = v.y + v.yVelocity
	end
end

function love.draw()
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
	
	for i,v in pairs(player.bullets) do
		love.graphics.push()
		love.graphics.translate(v.x, v.y)
		love.graphics.rotate(v.rot)
		love.graphics.translate(-v.x, -v.y)
		love.graphics.rectangle("fill", v.x, v.y, 5, 2)
		love.graphics.pop()
	end
		
end