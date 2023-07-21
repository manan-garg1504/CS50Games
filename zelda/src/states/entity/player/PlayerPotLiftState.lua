PlayerPotLiftState = Class{__includes = BaseState}

function PlayerPotLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.player.offsetY = 5
    self.player.offsetX = 0

    -- PlayerAnimation
    self.player:changeAnimation('lift-' .. self.player.direction)
end

function PlayerPotLiftState:enter()

    self.player:changeAnimation('lift-' .. self.player.direction)
end

function PlayerPotLiftState:update(dt)

    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('pot-idle')
        self.player:changeAnimation('pot-idle-'..tostring(self.player.direction))
    end

    --! Space in this state: rapid throwing
    if love.keyboard.wasPressed('space') then
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object.state == 2 then
                object.state = self.player.direction
                object:setInitial()
            end
        end
        self.player.lifted = false
        self.player:changeState('idle')
    end
end

function PlayerPotLiftState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX), math.floor(self.player.y - self.player.offsetY))

    --
    -- debug for player and hurtbox collision rects VV
    --

    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    -- love.graphics.rectangle('line', self.swordHurtbox.x, self.swordHurtbox.y,
    --     self.swordHurtbox.width, self.swordHurtbox.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end