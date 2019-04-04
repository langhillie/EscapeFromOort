function debug()
	love.graphics.print("Weapon Cooldown: " .. player.weapon.cooldown, 20, 20)

	-- reset ship
	if love.keyboard.isDown("r") then
		resetShip()
	end
	
	--for i,v in pairs(player.bullets) do
		-- print debug information
	--end
end

-- returns true if there's a collision
function checkCollision(x1,y1,s1, x2,y2,s2)
  local distance = math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
  return distance <= s1 + s2 + 2
end


function generateAsteroid()
	local asteroid = {}
	
	asteroid.scale = math.random() * 50 + 5
	
	rand = math.random(3, 10)
	numVerts = math.ceil(rand) + math.floor(asteroid.scale / 8)
	angle = (2 * math.pi) / numVerts

	-- TODO
	-- spawn on a circle surrounding the area
	asteroid.x = math.random() * 500 + 50
	asteroid.y = math.random() * 500 + 50
	local maxVelocity = 30
	
	-- TODO
	-- point roughly towards the center
	asteroid.rot = 2 * math.pi * math.random()
	asteroid.xVelocity = math.random() * maxVelocity * math.sin(asteroid.rot)
	asteroid.yVelocity = math.random() * maxVelocity * -math.cos(asteroid.rot)
	
	-- Initializing
	asteroid.points = {}
	for i = 1, numVerts do
		asteroid.points[i] = {}
	end

	local scale = math.random() * 40 + 20

	for i, n in pairs(asteroid.points) do
		asteroid.points[i].x = math.cos(angle * i) * asteroid.scale + ((math.random() * asteroid.scale * 2 ) - asteroid.scale) / 4
		asteroid.points[i].y = math.sin(angle * i) * asteroid.scale + ((math.random() * asteroid.scale * 2 ) - asteroid.scale) / 4
		--print("" .. asteroid.points[i].x .. "," .. asteroid.points[i].y .. "")
	end
	table.insert(asteroids, asteroid)

end

function drawAsteroids()
	-- loops through every asteroid
	for i, asteroid in ipairs(asteroids) do
		local startPoint = {}
		local prevPoint = {}
	
		love.graphics.push()
		love.graphics.translate(asteroid.x, asteroid.y)
		
		-- loops through every point that selected asteroid has
		for j, point in ipairs(asteroid.points) do
			if j == 1 then
				startPoint = point
			else
				love.graphics.line(prevPoint.x, prevPoint.y, point.x, point.y)
			end
			prevPoint = point
		end
		love.graphics.line(prevPoint.x, prevPoint.y, startPoint.x, startPoint.y)
		
		love.graphics.pop()
	end
end

function resetShip()
		player.x = window.width / 2
		player.y = window.height / 2
		player.xVelocity = 0
		player.yVelocity = 0
		player.rot = 0
end

function drawUI()

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
		love.graphics.rectangle("fill", v.x - v.width / 2, v.y - v.height / 2, v.width, v.height)
		love.graphics.pop()
	end
end

-- Called on load
function love.load()
	local seed = os.time()
	math.randomseed(seed)
	print("Seed: " .. seed)


	-- variables
	settings = {}
	settings.enableDebug = 1
	
	game = {}
	game.score = 0
	game.asteroids = {}
	
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
	
	-- for the purposes of collision detection
	player.radius = 2
	
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
		bullet.width = 3
		bullet.height = 3
		
		bullet.rot = player.rot
		bullet.xVelocity = player.weapon.velocity * math.sin(player.rot) + player.xVelocity
		bullet.yVelocity = player.weapon.velocity * -math.cos(player.rot) + player.yVelocity
		table.insert(player.bullets, bullet)
	end
	
	asteroids = {}
	generateAsteroid()
	genAsteroidTimer = 0
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
	
	if love.keyboard.isDown("a") then
		generateAsteroid()
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
	for i, bullet in ipairs(player.bullets) do
		-- delete bullet if it is out of bounds
		if (bullet.x > window.width or bullet.x < 0 or bullet.y > window.height or bullet.y < 0) then
			table.remove(player.bullets, i)
		end
	
		bullet.x = bullet.x + bullet.xVelocity * dt
		bullet.y = bullet.y + bullet.yVelocity * dt
	end
	
	-- generate asteroids
	genAsteroidTimer = genAsteroidTimer + dt
	
	if genAsteroidTimer > 1 then
		generateAsteroid()
		genAsteroidTimer = 0
	end
	
	
	
	for i, asteroid in ipairs(asteroids) do
		--move asteroids
		asteroid.x = asteroid.x + asteroid.xVelocity * dt
		asteroid.y = asteroid.y + asteroid.yVelocity * dt
	
	
		-- Check if player hits an asteroid
		if checkCollision(player.x, player.y, player.radius, asteroid.x, asteroid.y, asteroid.scale) then
			resetShip()
		end
		for j, bullet in ipairs(player.bullets) do
			if checkCollision(asteroid.x, asteroid.y, asteroid.scale, bullet.x, bullet.y, 1) then
				table.remove(asteroids, i)
				table.remove(player.bullets, j)
			end
		end
	end
	

	
end

-- Draws the scene
function love.draw()

	drawAsteroids()
	
	drawShip()
	
	drawBullets()
		
end