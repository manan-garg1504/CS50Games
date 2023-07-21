--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]

--Load medal images
function ScoreState:init()
    medals = {
        ['Bronze'] = love.graphics.newImage('bronze.png'),
        ['Silver'] = love.graphics.newImage('silver.png'),
        ['Gold'] = love.graphics.newImage('gold.png')
    }
end

function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    
    --render trophy
    if self.score >= 25  then
        love.graphics.draw(medals['Gold'], 250, 120, 0, 0.0625)
        love.graphics.printf('Amazing! You got a Gold trophy!', 0, 64, VIRTUAL_WIDTH, 'center')
    elseif self.score >= 18 then
        love.graphics.draw(medals['Silver'], 250, 120, 0, 0.0625)
        love.graphics.printf('Wow! You got a Silver trophy!', 0, 64, VIRTUAL_WIDTH, 'center')
    elseif self.score >= 10 then
        love.graphics.draw(medals['Bronze'], 250, 120, 0, 0.0625)
        love.graphics.printf('Nice! You got a Bronze trophy!', 0, 64, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end