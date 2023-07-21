--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerPotIdleState:enter(params)

end

function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk')
    end

    if love.keyboard.wasPressed('space') then
        for k, object in pairs(self.dungeon.currentRoom.objects) do
            if object.state == 2 then
                object.state = self.entity.direction
                object:setInitial()
            end
        end
        self.entity.lifted = false
        self.entity:changeState('idle')
    end
end