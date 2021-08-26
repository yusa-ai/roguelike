function love.load()
    local windfield = require("libraries.windfield")
    local anim8 = require("libraries.anim8")
    local gamera = require("libraries.gamera")

    -- Window settings
    love.window.setMode(1000, 500)
    love.window.setTitle("Prototype")

    -- World
    world = windfield.newWorld(0, 400, false)
    world:addCollisionClass("Player")
    world:addCollisionClass("Boundary")

    -- Ground
    Boundary = world:newRectangleCollider(0, 456, love.graphics.getWidth(), 40)
    Boundary:setType("static")
    Boundary:setCollisionClass("Boundary")

    -- Walls
    walls = {
        wall_1 = world:newRectangleCollider(-1, 0, 1, love.graphics.getHeight()),
        wall_2 = world:newRectangleCollider(love.graphics.getWidth(), 0, 1, love.graphics.getHeight())
    }
    for _, wall in pairs(walls) do
        wall:setType("static")
        wall:setCollisionClass("Boundary")
    end

    -- Sprites
    sprites = {
        background = love.graphics.newImage("sprites/background.png"),
        player = love.graphics.newImage("sprites/adventurer.png")
    }

    -- Player animations
    local player_grid = anim8.newGrid(50, 37, sprites.player:getWidth(), sprites.player:getHeight())
    p_animations = {
        idle = anim8.newAnimation(player_grid("1-4", 1), 0.2),
        run = anim8.newAnimation(player_grid("2-5", 2), 0.1),
        atk = anim8.newAnimation(player_grid("1-5", 7), 0.1),
    }

    -- Player
    player = world:newRectangleCollider(0, 425, 25, 30)
    Boundary:setCollisionClass("Player")

    player.direction = 1
    player.speed = 150
    player.animation = p_animations.idle
    player.attacking = false
    
    -- Camera
    camera = gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    camera:setScale(2.0)
end

function love.update(dt)  
    world:update(dt)
    
    local px, py = player:getPosition()
    if not player.attacking then
        -- Controls
        if love.keyboard.isDown("q") then
            player.animation = p_animations.run
            player.direction = -1
            player:setX(px - player.speed * dt)
        elseif love.keyboard.isDown("d") then
            player.animation = p_animations.run
            player.direction = 1
            player:setX(px + player.speed * dt)
        else
            player.animation = p_animations.idle
        end

    elseif player.animation.position == 5 then
        player.attacking = false
    end

    -- Animations
    player.animation:update(dt)

    -- Camera
    camera:setPosition(px, py)
end

function love.draw()
    camera:draw(drawCamera)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and not player.attacking then
        player.attacking = true
        player.animation = p_animations.atk
        player.animation:gotoFrame(1)
    end
end

function drawCamera()
    -- background
    local sx = love.graphics.getWidth() / sprites.background:getWidth()
    local sy = love.graphics.getHeight() / sprites.background:getHeight()
    love.graphics.draw(sprites.background, 0, 0, nil, sx, sy)

    --world:draw()

    -- Player
    local px, py = player:getPosition()
    player.animation:draw(sprites.player, px, py, nil, player.direction, 1, 50/2, 37/2)
end