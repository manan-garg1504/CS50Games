--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)

    -- string identifying this object type
    self.type = def.type
    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    self.consumable = def.consumable
    self.consumed = false

    -- default empty collision callback
    self.onCollide = function() end
end

function GameObject:setInitial()
    self.tilesTravelled = 0
    if self.state == 'left' then
        self.dx = -150
        self.dy = 0
    end
    if self.state == 'right' then
        self.dx = 150
        self.dy = 0
    end
    if self.state == 'up' then
        self.dx = 0
        self.dy = -107
    end
    if self.state == 'down' then
        self.dx = 0
        self.dy = 107
    end
end

--update only happens if the object is a pot
function GameObject:update(dt, room)
    if self.state == 1 then
        return
    end

    if self.state == 2 then
        self.x = room.player.x - 1
        self.y = room.player.y - 10
        return
    end

    self.tilesTravelled = self.tilesTravelled + dt*150
    if self.tilesTravelled >= 64 then
        self.consumed = true
    end

    -- boundary checking on all sides, allowing us to avoid collision detection on tiles
    if self.state == 'left' then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        self.dy = self.dy + 145 * dt

        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
            self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.consumed = true
        end
    elseif self.state == 'right' then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        self.dy = self.dy + 145 * dt

        if self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
            self.consumed = true
        end
    elseif self.state == 'up' then
        self.y = self.y + self.dy * dt
        if self.tilesTravelled >= 32 then
            self.dy = self.dy - 8.25 * dt
        else
            self.dy = self.dy + 8.25 * dt
        end

        if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then
            self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
            self.consumed = true
        end
    elseif self.state == 'down' then
        self.y = self.y + self.dy * dt
        if self.tilesTravelled >= 32 then
            self.dy = self.dy + 8.25 * dt
        else
            self.dy = self.dy - 8.25 * dt
        end

        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE)
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.y + self.height >= bottomEdge then
            self.y = bottomEdge - self.height
            self.consumed = true
        end
    end

    for k, entity in pairs(room.entities) do
        if entity:collides(self) then
            self.consumed = true
            entity:damage(1)
            gSounds['hit-enemy']:play()
        end
    end

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    local frame = 0

    if self.states == nil then
        frame = self.frame
    else
        frame = self.states[self.state].frame
    end

    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end