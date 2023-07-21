--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

require 'src/PowerUpHandlers'

--Import power up handler functions

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.blockedBricks = params.blockedBricks
    self.health = params.health
    self.score = params.score

    --! Why are we passing around highScores?
    self.highScores = params.highScores

    --! Do a new ball here, not import; has to be a table of balls
    self.balls = params.balls
    self.level = params.level

    self.recoverPoints = params.recoverPoints
    self.powerUpPoints = params.powerUpPoints

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-70, -80)

    --Make a table for the power ups on screen
    self.powerUps = {}

    --timer for key drops
    self.timer = 0
    self.timeToDrop = math.random(20, 30)
end

--refenence table for power functions
function PlayState:implementPowers(type)

    if type == 1 then
        self:newHeart()
    elseif type == 2 then 
        self:lessHearts()
    elseif type == 3 then
        self:increaseSpeed()
    elseif type == 4 then
        self:decreaseSpeed()
    elseif type == 5 then
        self:smallBall()
    elseif type == 6 then
        self:largeBall()
    elseif type == 7 then
        self:newBalls()
    else
        self:removeBlock()
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    --spawn Key power up
    if #self.blockedBricks > 0 then
        self.timer = self.timer + dt

        if self.timer >= self.timeToDrop then
            self.timer = 0
            self.timeToDrop = math.random(20, 30)

            --spawn timer power up
            P = PowerUp(8)
            table.insert(self.powerUps, P)
        end
    end

    -- updates
    self.paddle:update(dt)

    for k,powerUp in pairs(self.powerUps) do
        powerUp:update(dt)

        if powerUp:collides(self.paddle) then
            powerUp.inPlay = false
            self:implementPowers(powerUp.type)
        end

        if powerUp.y >= VIRTUAL_HEIGHT then
            powerUp.inPlay = false
        end
    end

    local inPlay = false

    for k,ball in pairs(self.balls) do

        if not ball.inPlay then
            goto continue
        end

        --update each ball position
        ball:update(dt)

        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - ball.height - 1
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

            -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then
                -- add to score and trigger the hit function
                self.score = self.score + brick:hit()

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 4 health
                    self.health = math.min(4, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.random(4000, 6000)

                    --increase paddle size
                    self.paddle:sizeChange(true)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                --Spawn a Power Up if you get enough points
                if self.score > self.powerUpPoints then
                    --spawn a random power up
                    local t = math.random(1,15)
                    local P = PowerUp(7)
                    if t < 7 then
                        P.type = t
                    end
                    table.insert(self.powerUps, P)

                    --Set up condition for next power up
                    self.powerUpPoints = self.powerUpPoints + math.random(8,13)*100
                end


                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        recoverPoints = self.recoverPoints,
                        powerUpPoints = self.powerUpPoints
                    })
                end

                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - ball.width

                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32

                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - ball.width

                -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                ball.dy = ball.dy * 1.02

                -- only allow colliding with one brick, for corners
                break
            end
        end

        -- if a ball drops below ground, remove it
        -- and decrease health if all balls are gone
        if ball.y >= VIRTUAL_HEIGHT then
            ball.inPlay = false
            gSounds['hurt']:play()
        else
            inPlay = true
        end

        ::continue::
    end

    --Executes if there were no balls in Play above Virtual height
    if not inPlay then
        self.health = self.health - 1
        self.paddle:sizeChange(false)
        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                blockedBricks = self.blockedBricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints,
                powerUpPoints = self.powerUpPoints
            })
        end
    end
    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    --render all balls
    for k,ball in pairs(self.balls) do
        if ball.inPlay then
            ball:render()
        end
    end

    renderScore(self.score)
    renderHealth(self.health)

    for k, powerUp in pairs(self.powerUps) do
        powerUp:render()
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end