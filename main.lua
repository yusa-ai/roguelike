function love.load()
    local windfield = require("libraries.windfield")
    local anim8 = require("libraries.anim8")
    local gamera = require("libraries.gamera")

    -- Window settings
    love.window.setMode(1000, 500)
    love.window.setTitle("Prototype")

    -- World
    world = windfield.newWorld(0, 400, false)

    -- Ground collider
    ground = world:newRectangleCollider(0, 456, love.graphics.getWidth(), 40)
    ground:setType("static")

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
    }

    -- Player entity
    player = world:newRectangleCollider(0, 425, 25, 30)
    player.direction = 1
    player.speed = 150
    player.animation = p_animations.idle
    
    -- Camera
    camera = gamera.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    camera:setScale(2.0)
end

function love.update(dt)  
    world:update(dt)
    
    local px, py = player:getPosition()
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

    -- Animations
    player.animation:update(dt)

    -- Camera
    camera:setPosition(px, py)
end

function love.draw()
    camera:draw(drawCamera)

    -- DEBUG
    love.graphics.print("Cursor position: " .. love.mouse.getX() .. ", " .. love.mouse.getY(), 0, 0)
end

function drawCamera()
    -- Background
    local sx = love.graphics.getWidth() / sprites.background:getWidth()
    local sy = love.graphics.getHeight() / sprites.background:getHeight()
    love.graphics.draw(sprites.background, 0, 0, nil, sx, sy)

    --world:draw()

    -- Player
    local px, py = player:getPosition()
    player.animation:draw(sprites.player, px, py, nil, player.direction, 1, 50/2, 37/2)
end