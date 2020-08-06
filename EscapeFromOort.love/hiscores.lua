function loadHiscores()
	hiscores = {}
	for line in love.filesystem.lines("hiscores.txt") do
		table.insert(highscores, line)
	end
end


function drawHiscores()




end