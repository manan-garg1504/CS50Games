--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)

    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    self.isShiny = true and (math.random(70)==1) or false
    self.shinyQuad = love.graphics.newQuad(100, 50, 128, 128, gTextures['shiny'])
end

mask_effect = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
       if (Texel(texture, texture_coords).a == 0.0) {
          // a discarded pixel wont be applied as the stencil.
          discard;
       }
       return vec4(1.0);
    }
]]
X = 0
Y = 0

function myStencilFunction()
    love.graphics.setShader(mask_effect)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][1][1], X, Y)
    love.graphics.setShader()
end

function Tile:render(x, y)

    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)
    love.graphics.setColor(1,1,1,1)
    -- draw something special for shiny
    if(self.isShiny) then
        X = self.x + x
        Y = self.y + y
        love.graphics.stencil(myStencilFunction, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.draw(gTextures['shiny'], self.shinyQuad, self.x + x, self.y + y, 0, 0.25)
        love.graphics.setStencilTest()
        love.graphics.setColor(1,1,1,0.7)
    end


    -- draw tile itself
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)
    if(self.isShiny) then
        love.graphics.setBlendMode('add')
        love.graphics.setColor(1,1,1,0.05)
        love.graphics.rectangle('fill', self.x + x, self.y + y, 32, 32)
    end
    love.graphics.setBlendMode('alpha')
end