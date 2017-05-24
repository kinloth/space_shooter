--import the objects
player = require "objects/player"
Enemy = require "objects/enemy"
local anim8 = require 'lib/anim8'

--some global variables
createEnemyTimerMax = 0.6
createEnemyTimer = createEnemyTimerMax
score = 0
scale_factor = 0.9

-- table to store the enemies
enemies = {}

function love.load()
    --define a new player
    player = player:new(love.graphics.getWidth()/2 - 50,love.graphics.getHeight()-150)
    
    --initialize the images and sounds
    background_music = love.audio.newSource("/assets/sounds/Mecha Collection.wav")
    background_image = love.graphics.newImage("/assets/images/space.jpeg")
    button_image = love.graphics.newImage("/assets/images/button9090.png")
    player.image = love.graphics.newImage("/assets/images/plane.png")
    player.fire_audio = love.audio.newSource("/assets/sounds/gun-sound.wav")
    player.bullet_image = love.graphics.newImage("/assets/images/bullet.png")
    enemy_image = love.graphics.newImage("/assets/images/enemy.png")    
    
    
    explosion_animation = love.graphics.newImage("/assets/images/M484ExplosionSet1.png")
                            -- frame, image,    offsets, border
    local g32 = anim8.newGrid(32,32, explosion_animation:getWidth(),explosion_animation:getHeight(), 92, 10 , 0)
    
    explosion = anim8.newAnimation(g32('1-7',1), 0.5)
    
    --play the background music
    love.audio.play(background_music)
end

-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

-- function to key detection and player movement
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

-- like keydetected but for touchscreen
function detectTouch(dt)
  local touches = love.touch.getTouches()
 
  for i, id in ipairs(touches) do
    local x, y = love.touch.getPosition(id)
    if button_pressed(x,y) then player:fire() 
    
    elseif player.x < x then
      player.x = player.x + (player.speed * dt)
      if player.x > x then player.x = x end


    --touched to left
    elseif player.x > x then
      player.x = player.x - (player.speed * dt)
      if player.x < x then player.x = x end
    end

    --touched to down
    if player.y > y then
      player.y = player.y - (player.speed * dt)
      if player.y < y then player.y = y end


    --touched to up
    elseif player.y < y then
      player.y = player.y + (player.speed * dt)
      if player.y > y then player.y = y end
    end
  end
end

-- callback when touch is released
function love.touchreleased( id, x, y, dx, dy, pressure )
    -- player is died
    if not player.isAlive then
      reset()
    end
    -- fire button is pressed
    if button_pressed(x,y) then
      player:fire()
    end
end

-- like touch relased but for keyboard
function love.keyreleased(key)  
  if (key == "space") then
    player:fire()
    
  elseif not player.isAlive and key == 'r' then
    reset()
  end
end

-- reset the player, enermies table, dificult and score
function reset()
  player:reset(300,300)
  enemies = {}
  score = 0
  createEnemyTimerMax = 0.6
end

-- update every frame
function love.update(dt)
  --player fire cooldown
  player.cooldown = player.cooldown - 1
  
  -- with this timer, will slowly spawn more enermies
  createEnemyTimerMax = createEnemyTimerMax - 0.0001
  enemySpawn(dt)
  detectKey(dt)
  detectTouch(dt)
  
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

    if enemy.y > love.graphics.getHeight() then -- remove enemies when they pass off the screen
      table.remove(enemy, i)
    end
  end
  
-- since there will be fewer enemies on screen than bullets we'll loop them first
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(player.bullets) do
      if CheckCollision(enemy.x, enemy.y, enemy.image:getWidth(), enemy.image:getHeight(), 
          bullet.x, bullet.y, player.bullet_image:getWidth(), player.bullet_image:getHeight()) then
        table.remove(player.bullets, j)
        
        enemy.dead = true
        love.audio.play(love.audio.newSource("/assets/sounds/explosion.wav"))
        
        score = score + 1
      end
    end

    -- check if are collision with player
    if CheckCollision(enemy.x, enemy.y, enemy.image:getWidth(), enemy.image:getHeight(), 
              player.x, player.y, player.image:getWidth(), player.image:getHeight()) and player.isAlive then
      table.remove(enemies, i)
      player.isAlive = false
    end

  end 
end

--function to spawn enemies, using the timer and random number generator
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

-- check if the fire button was pressed
function button_pressed(x,y)
  if x > love.graphics:getWidth() - 200 and x < love.graphics:getWidth() - 110 and 
    y > love.graphics:getHeight() - 180 and y < love.graphics:getHeight() - 90 then
    return true
  end
  return false
end

function love.draw()
  -- draw the background image, rotated by 90 degree to fit mobile screen
  love.graphics.draw(background_image,1024,0,math.rad(90))
  
  -- draw a player
  if player.isAlive then
    love.graphics.draw(player.image, player.x, player.y,0,scale_factor, scale_factor)
  else
    love.graphics.print("Press anywhere to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  
  --draw the enemies
  for i, enemy in ipairs(enemies) do
    if(enemy.dead == false) then
      love.graphics.draw(enemy.image, enemy.x, enemy.y, 0, scale_factor, scale_factor)
    else
      explosion:draw(   explosion_animation, enemy.x + enemy.image:getWidth()/2 - 20, enemy.y + enemy.image:getHeight()/2-20) 
      table.remove(enemies, i)
    end
  end
  
  --draw the bullets
  for _,v in pairs(player.bullets) do
      love.graphics.draw(player.bullet_image, v.x, v.y)
  end

  --change color and print score
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("SCORE: " .. tostring(score), 400, 10)
  
  --draw a button
  love.graphics.draw(button_image, love.graphics:getWidth() - 200, love.graphics:getHeight() - 160)
    
end
