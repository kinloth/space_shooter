--background music and image
player = require "objects/player"
Enemy = require "objects/enemy"

--More timers
createEnemyTimerMax = 0.6
createEnemyTimer = createEnemyTimerMax
score = 0

-- More storage
enemies = {} -- array of current enemies on screen


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
    --background music
    background_music = love.audio.newSource("/assets/sounds/Mecha Collection.wav")
    background_image = love.graphics.newImage("/assets/images/space1.jpg")
    
    love.audio.play(background_music)

    player = player:new(300,300)
    player.image = love.graphics.newImage("/assets/images/plane.png")
    player.fire_audio = love.audio.newSource("/assets/sounds/gun-sound.wav")
    player.bullet_image = love.graphics.newImage("/assets/images/bullet.png")
    
    enemy_image = love.graphics.newImage("/assets/images/enemy.png")
    
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
  
  if (key == "space") then
    player:fire()
    
  elseif not player.isAlive and key == 'r' then
    player:reset(300,300)
    enemies = {}
    score = 0
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
  
  
-- Since there will be fewer enemies on screen than bullets we'll loop them first
-- Also, we need to see if the enemies hit our player
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(player.bullets) do
      if CheckCollision(enemy.x, enemy.y, enemy.image:getWidth(), enemy.image:getHeight(), 
          bullet.x, bullet.y, player.bullet_image:getWidth(), player.bullet_image:getHeight()) then
        table.remove(player.bullets, j)
        table.remove(enemies, i)
        score = score + 1
      end
    end

    if CheckCollision(enemy.x, enemy.y, enemy.image:getWidth(), enemy.image:getHeight(), 
              player.x, player.y, player.image:getWidth(), player.image:getHeight()) and player.isAlive then
      table.remove(enemies, i)
      player.isAlive = false
    end

  end 
end

function enemySpawn(dt)
    -- Time out enemy creation
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
    createEnemyTimer = createEnemyTimerMax

    -- Create an enemy
    randomX = math.random(10, love.graphics.getWidth() - 10)
    randomSpeed = math.random(70, 150)
    
    enemy = Enemy:new(randomX, -20, randomSpeed, enemy_image)
    table.insert(enemies, enemy)
  end
end


function love.draw()
  --background
  love.graphics.draw(background_image,0,0,0,1.7)
  
  -- draw a player
  if player.isAlive then
    love.graphics.draw(player.image, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  
  --draw the enemies
  for _, enemy in pairs(enemies) do
    love.graphics.draw(enemy.image, enemy.x, enemy.y)
  end
  
  --draw the bullets
  for _,v in pairs(player.bullets) do
      love.graphics.draw(player.bullet_image, v.x, v.y)
  end
  
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("SCORE: " .. tostring(score), 400, 10)
    
end
