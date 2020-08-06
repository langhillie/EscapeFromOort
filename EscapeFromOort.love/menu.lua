require "hiscores"

function createButton(t)
	local this = {
		text = t,
		selected = false
	}
	return this
end


function userMenuInputHandler(key)
	if key == "up" then
		if menu.selected > 1 then
			menu.buttons[menu.selected].selected = false
			menu.buttons[menu.selected - 1].selected = true
			menu.selected = menu.selected - 1
		end
	elseif key == "down" then
		if menu.selected < table.getn(menu.buttons) then
			menu.buttons[menu.selected].selected = false
			menu.buttons[menu.selected + 1].selected = true
			menu.selected = menu.selected + 1
		end
	elseif key == "return" then
		-- Start game
		if (menu.selected == 1) then
			initializeGame()
			game.state = "game"
			game.paused = false
		elseif (menu.selected == 2) then
			loadHiscores()
			game.state = "hiscores"
		elseif (menu.selected == 3) then
			love.event.quit()
		end
	end
end

function initializeMenu()
	menu = {}
	
	menu.font = love.graphics.newFont(18)
	
	menu.buttonWidth = 100
	menu.buttonHeight = 40

	menu.buttons = {}
	
	local playMenuButton = createButton("Play")
	local scoresMenuButton = createButton("Scores")
	local quitMenuButton = createButton("Quit")
	
	menu.selected = 1
	playMenuButton.selected = true
	table.insert(menu.buttons, playMenuButton)
	table.insert(menu.buttons, scoresMenuButton)
	table.insert(menu.buttons, quitMenuButton)
end

function drawMenu()

	for i, button in ipairs(menu.buttons) do
		local x = window.width / 2 - menu.buttonWidth / 2
		local y = window.height / 2 - menu.buttonHeight / 2 + (menu.buttonHeight + 20) * ( (i-0.5) - table.getn(menu.buttons) / 2)

		if button.selected then
			love.graphics.setColor(40/255, 40/255, 40/255)
			love.graphics.rectangle("fill", x, y, menu.buttonWidth, menu.buttonHeight)
			love.graphics.setColor(255/255, 255/255, 255/255)
		end
	
		love.graphics.rectangle("line", x, y, menu.buttonWidth, menu.buttonHeight)
		
		local textHeight = menu.font:getHeight()
		love.graphics.printf(button.text, menu.font, x, y + menu.buttonHeight / 2 - textHeight / 2, menu.buttonWidth, "center")

	end
end