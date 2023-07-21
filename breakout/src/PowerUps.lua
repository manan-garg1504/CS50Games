--[[
    GD50
    Breakout Remake

    -- PowerUp class --

    Implementation of powerUps that slowly float
    down and if 'caught' by a player (collision with the paddle),
    can change various aspects of the game.
]]

PowerUp = Class{}

function PowerUp:init(type)
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16

    -- We only have a velocity in the y-direction
    self.dy = 20

    --[[
        PowerUp type (Currently fixed to ball spawner)
        The power ups are indexed based on their order
        of appearance in the texture file
    ]]
    self.type = type

    --Starting position (Offests included for a 16X16 quad)
    self.x = math.random(30, VIRTUAL_WIDTH-46)
    self.y = math.random(0, (VIRTUAL_HEIGHT/4) -16)

    --In Play flag
    self.inPlay = true
end

--[[
    Detects if paddle has collided with the power up,
    given that it is still in play
]]
function PowerUp:collides(target)

    if not self.inPlay then
        return false
    end

    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function PowerUp:update(dt)

    if not self.inPlay then
        return
    end

    -- Move the power up down with a constant velocity
    self.y = self.y + self.dy * dt
end

function PowerUp:render()

    if not self.inPlay then
        return
    end

    love.graphics.setColor(1,1,1,1)
    -- Very similar to ball rendering
    love.graphics.draw(gTextures['main'], gFrames['powerUps'][self.type],
        self.x, self.y)
end