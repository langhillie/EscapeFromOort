require "menu"
require "hiscores"

function debugUpdate()
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

function round(number, decimals)
    local p = 10^decimals
    return math.floor(number * p) / p
end

function generateAsteroid()
	local asteroid = {}
	
	asteroid.scale = math.random() * 45 + 11
	
	rand = math.random(3, 10)
	numVerts = math.ceil(rand) + math.floor(asteroid.scale / 8)
	angle = (2 * math.pi) / numVerts

	-- TODO
	-- despawn asteroids
	
	-- randomize starting position of the asteroid
	local startingAngle = 2 * math.pi * math.random()
	asteroid.x = math.cos(startingAngle) * (500) + window.width / 2
	asteroid.y = math.sin(startingAngle) * (500) + window.height / 2
	local maxVelocity = 50
	local minVelocity = 10
	local velocity = minVelocity + math.random() * (maxVelocity - minVelocity)
	
	-- TODO
	-- point roughly towards the center
	asteroid.rot = math.atan2(asteroid.y - window.height / 2, asteroid.x - window.width / 2)
	print(asteroid.rot)
	--asteroid.rot = 0
	asteroid.xVelocity = velocity * -math.cos(asteroid.rot)
	asteroid.yVelocity = velocity * -math.sin(asteroid.rot)
	
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

function shipDestroyed()
	game.state = "menu"
	game.paused = true
	-- Handle high scores, etc
	
	--local highScoresFile = io.open("hiscores.txt", "a")
	--highScoresFile.write(game.time)
	love.filesystem.append("hiscores.txt", game.time)
end

function drawUI()
	-- TODO: Add in game UI (Time, score, etc)
	if game.paused == true then
		local pauseText = "PAUSED"
		local textWidth = game.font:getWidth(pauseText)
		local textHeight = game.font:getHeight()
		local pauseTextTransform = love.math.newTransform(window.width / 2 - textWidth / 2, window.height / 2 - textHeight / 2)
		
		love.graphics.printf(pauseText, game.font, pauseTextTransform, game.font:getWidth(pauseText), "left")
	end
	local transform2 = love.math.newTransform(window.width / 2, window.height / 2 + 50)

	love.graphics.printf(round(game.time, 3), game.font, transform2, 200, "left")
	
end

function updateUI(dt)
	game.time = game.time + dt
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

-- Applies physics to ship, bullets, and asteroids
function applyPhysics(dt)
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

	for i, asteroid in ipairs(asteroids) do
		--move asteroids
		asteroid.x = asteroid.x + asteroid.xVelocity * dt
		asteroid.y = asteroid.y + asteroid.yVelocity * dt
	
	
		-- Check if player hits an asteroid
		if checkCollision(player.x, player.y, player.radius, asteroid.x, asteroid.y, asteroid.scale) then
			shipDestroyed()
		end
		for j, bullet in ipairs(player.bullets) do
			if checkCollision(asteroid.x, asteroid.y, asteroid.scale, bullet.x, bullet.y, 1) then
				table.remove(asteroids, i)
				table.remove(player.bullets, j)
			end
		end
	end
end

function userGameInputHandler(dt)
	if love.keyboard.isDown("a") then
		generateAsteroid()
	end
	
	
	if love.keyboard.isDown("o") then
		settings.enableDebug = 1 - settings.enableDebug
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

end

function asteroidGenerationManager(dt)
	-- generate asteroids
	genAsteroidTimer = genAsteroidTimer + dt
	
	if genAsteroidTimer > 1 then
		generateAsteroid()
		genAsteroidTimer = 0
	end

end

function initializeGame()
	local seed = os.time()
	math.randomseed(seed)
	print("Seed: " .. seed)

	-- player setup
	player = {}
	player.x = window.width /2
	player.y = window.height /2
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

	game.state = "game"
	game.paused = false
	
end

function love.keypressed( key, scancode, isrepeat )
	if game.state == "menu" then
		userMenuInputHandler(scancode)
	elseif game.state == "game" then
		if love.keyboard.isDown("escape") then
			game.paused = not game.paused
		end
	end
end

-- Called before draw (once per frame)
function love.update(dt)
	if game.paused == false and game.state == "game" then
		userGameInputHandler(dt)
		applyPhysics(dt)
		asteroidGenerationManager(dt)
		updateUI(dt)
		
		if settings.enableDebug == 1 then
			debugUpdate()	
		end
	end

end

-- Called on load
function love.load()

	-- variables
	settings = {}
	settings.enableDebug = 1
	
	game = {}
	game.score = 0
	game.asteroids = {}
	
	game.font = love.graphics.newFont(18)
	game.textHeight = game.font:getHeight()
	game.time = 0
	
	game.state = "menu"
	game.paused = true
	
	window = {}
	window.width = love.graphics.getWidth()
	window.height = love.graphics.getHeight()
	
	initializeMenu()
end

-- Draws the scene
function love.draw()
	if game.state == "menu" then
		drawMenu()
	
	elseif game.state == "game" then
		drawAsteroids()
		drawShip()
		drawBullets()
		drawUI()
	elseif game.state == "hiscores" then
	
	
	
	end
	
	-- debug
	if not window.width == nil then
		if settings.enableDebug == 1 then
			love.graphics.line(window.width/2, 0, window.width/2, window.height)
			love.graphics.line(0, window.height/2, window.width, window.height/2)
		end
	end
	
end