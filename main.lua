--[[

PROGRAM INFO:
A clone of the classic Tron game. Survive for as long as possible by avoiding light trails and the screen edges.
Controls used are WASD for player 1 and the arrow keys for player 2. R restarts when a player loses, Escape closes the game.

Last updated 28/10/2014 at 10:21.

NOTE: Any change in love.load might want to be doublechecked with the restart code to maintain similarity cuz I didn't bother making a fancy reset function.

]]
function love.load()
	--An extra 8 pixels is added to the height to accomodate power-of-two graphics.
	love.window.setMode(800, 608)
	love.window.setTitle("Tron")

	--The width and height of each drawn rectangle.
	tileSize = 16
	
	--Map max width and height are higher than necessary. Did it for scalability. Left it despite never really needing it.
	mapWidth = 50
	mapHeight = 50 

	visitedTiles = {mapWidth, mapHeight} 
	
	--Create an empty game world. Starts at -1 so handling a loss at x/y 0 can be done without crashing.
	for i = -1, mapHeight do
		visitedTiles[i] = {}
		for j = -1, mapWidth do
			visitedTiles[i][j] = 0
		end
	end
	
	p1 = {}
	p1.headX = 5
	p1.headY = 18
	p1.direction = 3 --up down left right, 0 1 2 3, that order.
	p1.lastMove = 3
	p1.lost = 0
	p1.score = 0
    
	p2 = {}
	p2.headX = 44
	p2.headY = 18
	p2.direction = 2
	p2.lastMove = 2
	p2.lost = 0
    p2.score = 0

	timer = 0

end

function love.update(dt)

	timer = timer + dt --update time

	checkKeyInput()
    
	--Only update movement after a certain amount of time has passed.
	if p1.lost ~= 1 and p2.lost ~= 1 then
		if (timer > 0.08) then
			timeUpdate() --Update movement
			checkVisited() --Check for collisions
			
			timer = 0
		end
	else
		 --Restart game.
		if love.keyboard.isDown('r') then --basically reset select parts in love.load.
			
			for i = -1, mapHeight do
				visitedTiles[i] = {}
				for j = -1, mapWidth do
					visitedTiles[i][j] = 0
				end
			end

			p1.headX = 5
			p1.headY = 18
			p1.direction = 3 --up down left right, 0 1 2 3, that order.
			p1.lastMove = 3
			p1.lost = 0
			
			p2.headX = 44
			p2.headY = 18
			p2.direction = 2
			p2.lastMove = 2
			p2.lost = 0

			timer = 0
		end
	end
end

function love.draw()

	drawVisited() --Draw visited tiles under everything else.

	--Draw player 1
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.rectangle('fill', p1.headX*tileSize, p1.headY*tileSize, tileSize, tileSize)

	--Draw player 2
	love.graphics.setColor(0, 0, 255, 255)
	love.graphics.rectangle('fill', p2.headX*tileSize, p2.headY*tileSize, tileSize, tileSize)

	--[[Draw debugging text
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Time: " .. math.floor(timer), 32, 32)

	love.graphics.print("P1 Head X: " .. p1.headX, 32, 48)
	love.graphics.print("P1 Head Y: " .. p1.headY, 32, 64)
	love.graphics.print("P2 Head X: " .. p2.headX, 32, 80)
	love.graphics.print("P2 Head Y: " .. p2.headY, 32, 96)
	love.graphics.print("P1 loss: " .. p1.lost, 300, 16)
	love.graphics.print("P2 loss: " .. p2.lost, 300, 26)
	]]
	
	--Print scores
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("Red snake score: " .. p1.score, 300, 24)
	love.graphics.print("Blue snake score: " .. p2.score, 300, 40)
	
	
	--Handle loss messages.
	if p1.lost == 1 and p2.lost == 1 then
		love.graphics.print("It's a tie!\nHit R to restart.", 300, 64)
	elseif p1.lost == 1 then
		love.graphics.print("Blue player is the winner!\nHit R to restart.", 300, 64)
	elseif p2.lost == 1 then
		love.graphics.print("Red player is the winner!\nHit R to restart.", 300, 64)
	end
	
end

--Run whenever a certain amount of time has passed. Handles players committing to movement in their set direction.
function timeUpdate()

	--Move both players in their set direction.
	if (p1.direction == 0) then
		p1.headY = p1.headY - 1
		p1.lastMove = 0
	end
	if (p1.direction == 1) then
		p1.headY = p1.headY + 1
		p1.lastMove = 1
	end
	if (p1.direction == 2) then
		p1.headX = p1.headX - 1
		p1.lastMove = 2
	end
	if (p1.direction == 3) then
		p1.headX = p1.headX + 1
		p1.lastMove = 3
	end

	if (p2.direction == 0) then
		p2.headY = p2.headY - 1
		p2.lastMove = 0
	end
	if (p2.direction == 1) then
		p2.headY = p2.headY + 1
		p2.lastMove = 1
	end
	if (p2.direction == 2) then
		p2.headX = p2.headX - 1
		p2.lastMove = 2
	end
	if (p2.direction == 3) then
		p2.headX = p2.headX + 1
		p2.lastMove = 3
	end
end

--This function checks and handles most keyboard input aside from the restart command.
function checkKeyInput()

	--Player 1 input, blocks 180 degree turns. NOTE: Slight bug here. Redundant solution in place using the lastMove var.
	if ((p1.direction ~= 1) and love.keyboard.isDown('w') and p1.lastMove ~= 1) then
		p1.direction = 0
	end
	if ((p1.direction ~= 0) and love.keyboard.isDown('s') and p1.lastMove ~= 0) then
		p1.direction = 1
	end
	if ((p1.direction ~= 3) and love.keyboard.isDown('a') and p1.lastMove ~= 3) then
		p1.direction = 2
	end
	if ((p1.direction ~= 2) and love.keyboard.isDown('d') and p1.lastMove ~= 2) then
		p1.direction = 3
	end

	--Player 2 input, blocks 180 degree turns.
	if ((p2.direction ~= 1) and love.keyboard.isDown('up') and p2.lastMove ~= 1) then
		p2.direction = 0
	end
	if ((p2.direction ~= 0) and love.keyboard.isDown('down') and p2.lastMove ~= 0) then
		p2.direction = 1
	end
	if ((p2.direction ~= 3) and love.keyboard.isDown('left') and p2.lastMove ~= 3) then
		p2.direction = 2
	end
	if ((p2.direction ~= 2) and love.keyboard.isDown('right') and p2.lastMove ~= 2) then
		p2.direction = 3
	end

	if (love.keyboard.isDown("escape")) then
		love.event.push("quit")
	end
end

--Check, then set tiles properly. Also handles loss checking.
function checkVisited()

	--If either player collides with a set tile.
	if visitedTiles[p1.headX][p1.headY] == 1 or visitedTiles[p1.headX][p1.headY] == 2 then
		p1.lost = 1
	end
	if visitedTiles[p2.headX][p2.headY] == 1 or visitedTiles[p2.headX][p2.headY] == 2 then
		p2.lost = 1
	end
	
	if p1.headX < 0 or p1.headX > 49 then
		p1.lost = 1
	end
	if p1.headY < 0 or p1.headY > 37 then
		p1.lost = 1
	end
	if p2.headX < 0 or p2.headX > 49 then
		p2.lost = 1
	end
	if p2.headY < 0 or p2.headY > 37 then
		p2.lost = 1
	end
	
	--If either players have lost, increase score. Function does not run after a loss. Ignores ties.
	if p1.lost == 1 and p2.lost ~= 1 then
		p2.score = p2.score + 1
	elseif p1.lost ~= 1 and p2.lost == 1 then
		p1.score = p1.score + 1
	end
	
	--If either player has not lost, set their tile as visited.
	if p1.lost ~= 1 and p2.lost ~= 1 then
		visitedTiles[p1.headX][p1.headY] = 1
		visitedTiles[p2.headX][p2.headY] = 2
	end
end

--Draws visited tiles in the proper trail color.
function drawVisited()
	for i=0, mapHeight do
		for j=0, mapWidth do
			if visitedTiles[i][j] == 1 then
				love.graphics.setColor(255, 0, 0, 128)
				love.graphics.rectangle('fill', i * tileSize, j * tileSize, tileSize, tileSize)
			end
			if visitedTiles[i][j] == 2 then
				love.graphics.setColor(0, 0, 255, 128)
				love.graphics.rectangle('fill', i * tileSize, j * tileSize, tileSize, tileSize)
			end
		end
	end
end