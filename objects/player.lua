local player = {}

function player:new(x, y)
  player.x = x
  player.y = y
  player.image = ""
  
  player.isAlive = true
  player.cooldown = 10
  player.speed = 300
  
  player.bullets = {}
  player.bullet_image = ""
  player.fire_audio = ""
  
  return player
end

function player:fire()
  if player.cooldown <= 0 and player.isAlive then
    bullet = {}
    bullet.speed = 900
    bullet.x = player.x + player.image:getHeight() / 2
    bullet.y = player.y
    bullet.image = bullet_image
    table.insert(player.bullets, bullet)
    player.cooldown = 20
    love.audio.play(player.fire_audio)
  end
end

function player:reset(x,y)  
    -- remove all our bullets and enemies from screen
    player.bullets = {}

    -- reset timers
    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax

    -- move player back to default position
    player.x = x
    player.y = y
    
    player.isAlive = true
end

return player
