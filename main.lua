shoot = love.audio.newSource("gun-sound.wav")
bullet_image = love.graphics.newImage("bullet.png")
background_image = love.graphics.newImage("space1.jpg")

--More timers
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
isAlive = true
score = 0
  
-- More images
enemyImg = nil -- Like other images we'll pull this in during out love.load function
  
-- More storage
enemies = {} -- array of current enemies on screen

-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function love.load()
    background_music = love.audio.newSource("Mecha Collection.wav")
    love.audio.play(background_music)

    player = {}
    player.image = love.graphics.newImage("plane.png")
    player.x = 370
    player.y = 543
    
    player.cooldown = 10
    player.speed = 300
    player.bullets = {}
  
    player.fire = function()
      if player.cooldown <= 0 then
        bullet = {}
        bullet.speed = 900
        bullet.x = player.x + player.image:getHeight() / 2
        bullet.y = player.y
        bullet.image = bullet_image
        table.insert(player.bullets, bullet)
        player.cooldown = 20
        love.audio.play(shoot)
      end
    end
    
    enemy = {}
    enemyImg = love.graphics.newImage("enemy.png")
    enemy.x = 100
    enemy.y = 200
    enemy.speed = 5
    enemies[0] = enemy
    
end

function detectKey(dt)
 if love.keyboard.isDown("right") then
   if player.x < (love.graphics.getWidth() - player.image:getWidth()) then
      player.x = player.x + (player.speed * dt)
    end
  elseif love.keyboard.isDown("left") then
    if player.x > 0 then
      player.x = player.x - (player.speed * dt)
    end
  end
  
  if love.keyboard.isDown("down") then
    if player.y < (love.graphics.getHeight() - player.image:getHeight()) then
      player.y = player.y + (player.speed * dt)
    end
  elseif love.keyboard.isDown("up") then
    if player.y > 0 then
      player.y = player.y - (player.speed * dt)
    end
  end

end 

function love.keyreleased(key)
  -- in v0.9.2 and earlier space is represented by the actual space character ' ', so check for both
  if (key == " " or key == "space") then
    player.fire()
  end
end

function love.update(dt)
  
  player.cooldown = player.cooldown - 1
  enemySpawn(dt)
  detectKey(dt)
  
  -- update the bullets positions
  for i,v in ipairs(player.bullets) do
    v.y = v.y - (v.speed * dt)
    if(v.y <= 0) then 
      table.remove(player.bullets, i)
    end    
  end
  
    -- update the positions of enemies
  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (enemy.speed * dt)

    if enemy.y > 850 then -- remove enemies when they pass off the screen
      table.remove(enemies, i)
    end
  end
  
--  --move the enemies
--  for _,v in pairs(enemies) do
--    if(math.random(0,20) == 0) then
--      v.x = v.x + math.random(-10, 10)
--      v.y = v.y + math.random(-10, 10)
--    end
--  end

-- run our collision detection
-- Since there will be fewer enemies on screen than bullets we'll loop them first
-- Also, we need to see if the enemies hit our player
for i, enemy in ipairs(enemies) do
	for j, bullet in ipairs(player.bullets) do
		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.image:getWidth(), bullet.image:getHeight()) then
			table.remove(player.bullets, j)
			table.remove(enemies, i)
			score = score + 1
		end
	end

	if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.image:getWidth(), player.image:getHeight()) 
	and isAlive then
		table.remove(enemies, i)
		isAlive = false
	end
  
  if not isAlive and love.keyboard.isDown('r') then
    reset()
  end
end
 
end

function enemySpawn(dt)
    -- Time out enemy creation
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax

    -- Create an enemy
    randomNumber = math.random(10, love.graphics.getWidth() - 10)
    newEnemy = { x = randomNumber, y = -10, img = enemyImg, speed = 100}
    table.insert(enemies, newEnemy)
  end
end

function reset()  
    -- remove all our bullets and enemies from screen
    player.bullets = {}
    enemies = {}

    -- reset timers
    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax

    -- move player back to default position
    player.x = 50
    player.y = 710

    -- reset our game state
    score = 0
    isAlive = true
end

function love.draw()
  --background
  love.graphics.draw(background_image,0,0,0,1.7)
  
  -- draw a player
  if isAlive then
    love.graphics.draw(player.image, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  
  --draw the enemies
  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end
  
  --draw the bullets
  for _,v in pairs(player.bullets) do
      love.graphics.draw(bullet_image, v.x, v.y)
  end
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("SCORE: " .. tostring(score), 400, 10)
    
end
