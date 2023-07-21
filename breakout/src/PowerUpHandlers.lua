--[[
    Has functions to implement the effects of various powerups
    As these affect various aspects of the Play State, these functions
    are a part of the Play State class.
]]

function PlayState:newHeart()
    --Increase health with a ceiling
    self.health = math.min(self.health + 1, 4)
    gSounds['recover']:play()
end

function PlayState:lessHearts()
    --Decrease health
    self.health = self.health - 1
    gSounds['hurt']:play()

    if self.health == 0 then
        gStateMachine:change('game-over', {
            score = self.score,
            highScores = self.highScores
        })
    end
end

function PlayState:increaseSpeed()
    for k,ball in pairs(self.balls) do
        ball.dx = ball.dx * 1.5
        ball.dy = ball.dy * 1.5
    end
end

function PlayState:decreaseSpeed()
    for k,ball in pairs(self.balls) do
        ball.dx = ball.dx / 1.5
        ball.dy = ball.dy / 1.5
    end
end

function PlayState:largeBall()
    for k,ball in pairs(self.balls) do
        ball.width = math.min(ball.width + 1.5 , 11)
        ball.height = math.min(ball.width + 1.5 , 11)
    end
end

function PlayState:smallBall()
    for k,ball in pairs(self.balls) do
        ball.width = math.max(ball.width - 1.5 , 5) 
        ball.height = math.max(ball.width - 1.5 , 5)
    end
end

function PlayState:newBalls()
    --initialize two new balls
    b1 = Ball(math.random(7))
    b2 = Ball(math.random(7))

    --giving random coordinates
    b1.x = math.random(0, VIRTUAL_WIDTH/2 - 8)
    b1.y = math.random(5*VIRTUAL_HEIGHT/8, 3*VIRTUAL_HEIGHT/4)

    b2.x = math.random(VIRTUAL_WIDTH/2, VIRTUAL_WIDTH - 8)
    b2.y = math.random(5*VIRTUAL_HEIGHT/8, 3*VIRTUAL_HEIGHT/4)

    --giving random speeds
    b1.dx = math.random(-140, 140)
    b1.dy = math.random(-70, -80)
    b2.dx = math.random(-140, 140)
    b2.dy = math.random(-70, -80)

    --insert into table
    table.insert(self.balls, b1)
    table.insert(self.balls, b2)
end

function PlayState:removeBlock()
    --decrease tier of a blocked brick, and remove it from the table
    self.bricks[table.remove(self.blockedBricks)].tier = 0
end