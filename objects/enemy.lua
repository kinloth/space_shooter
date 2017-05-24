local enemy = {}

function enemy:new(x, y, speed, image)

  local enemy = {}
  enemy.image = image
  enemy.x = x
  enemy.y = y
  enemy.speed = speed
  enemy.dead = false
  
  return enemy

end

function reset()  
    -- remove all enemies from screen
    enemies = {}
    
    -- reset timers
    createEnemyTimer = createEnemyTimerMax
end


return enemy