--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y)
    self.x = x
    self.y = y
    self.matches = {}
    self.score_to_give = 0
    self.time_inc = 0

    --To aid in level generation
    self.last_variety_initialized = 1
    self.common_difference = 120
    self.level_gen_params = {0,0,0,0,0,0}
    self.colors = {}

    --store whether moves can be made
    self.canContinue = true
end

-- Below two functions try to immplement a general scale in the 'variety' of the tiles
-- !test the sequence of 6-tuples this generates and implement passing of boards along states
function Board:update_level_gen_params()
    local middle = (1 + self.last_variety_initialized)/2
    local avg = 120/self.last_variety_initialized

    self.level_gen_params = {0,0,0,0,0,0}

    for i = 1, self.last_variety_initialized, 1 do
        self.level_gen_params[i] = avg + math.ceil((middle-i)*self.common_difference)
    end

    for i = 2, 6, 1 do
        self.level_gen_params[i] = self.level_gen_params[i] + self.level_gen_params[i-1]
    end
end

function Board:giveType()
    local x = math.random(0,119)
    if x <= self.level_gen_params[1] then
        return 1
    elseif x <= self.level_gen_params[2] then
        return 2
    elseif x <= self.level_gen_params[3] then
        return 3
    elseif x <= self.level_gen_params[4] then
        return 4
    elseif x <= self.level_gen_params[5] then
        return 5
    else
        return 6
    end
end

function Board:initializeTiles(newLevel)
    self.tiles = {}

    if newLevel then
    --generate probability distributions for various tile types
        if self.common_difference <= 1 and self.last_variety_initialized < 6 then
            self.last_variety_initialized = self.last_variety_initialized + 1
            self.common_difference = math.floor(60/self.last_variety_initialized)
        else
            self.common_difference = math.floor(((self.last_variety_initialized-1)*self.common_difference)/(self.last_variety_initialized+3))
        end
    end

    self:update_level_gen_params()

    --making the game a bit easier by only choosing 9(or less) colors at a time 
    self.colors = {}
    for x = 1, 8 do
        table.insert(self.colors, math.random(18))
    end

    for tileY = 1, 8 do

        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do

            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, self.colors[math.random(#self.colors)], self:giveType()))
        end
    end

    if self:calculateMatches() then

        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles(false)
    end

    --ensure there are moves at the start of a level
    self:checkMovesLeft()
    if(not self.canContinue) then
        self.canContinue = true
        self:initializeTiles(false)
    end
end

--takes a tile and checks if this tile and the one to the right can
--join with a tile to create a match
function Board:checkAdjacentsHorizontal(a, b)
    local color = self.tiles[a][b].color
    if not (color == self.tiles[a+1][b].color) then
        return false
    end

    if a<6 and (color == self.tiles[a+3][b].color) then
        return true
    end

    if a<7 and b<8 and (color == self.tiles[a+2][b+1].color) then
        return true
    end

    if a<7 and b>1 and (color == self.tiles[a+2][b-1].color) then
        return true
    end

    if a>1 and b<8 and (color == self.tiles[a-1][b+1].color) then
        return true
    end

    if a>2 and (color == self.tiles[a-2][b].color) then
        return true
    end

    if a>1 and b>1 and (color == self.tiles[a-1][b-1].color) then
        return true
    end

    return false
end

--takes a tile and checks if this tile and the one below it can
--join with a tile to create a match
function Board:checkAdjacentsVertical(a, b)
    local color = self.tiles[a][b].color
    if not (color == self.tiles[a][b+1].color) then
        return false
    end

    if b<6 and (color == self.tiles[a][b+3].color) then
        return true
    end

    if b<7 and a<8 and (color == self.tiles[a+1][b+2].color) then
        return true
    end

    if b<7 and a>1 and (color == self.tiles[a-1][b+2].color) then
        return true
    end

    if b>1 and a>1 and (color == self.tiles[a-1][b-1].color) then
        return true
    end

    if b>2 and (color == self.tiles[a][b-2].color) then
        return true
    end

    if b>1 and a<8 and (color == self.tiles[a+1][b-1].color) then
        return true
    end

    return false
end

--takes a tile and checks if this tile and the one 
--two spaces below it can join with a tile to create a match
function Board:checkGapedVertical(a, b)
    if b == 7 then
        return false
    end

    local color = self.tiles[a][b].color
    if not (color == self.tiles[a][b+2].color) then
        return false
    end

    if a<8 and (color == self.tiles[a+1][b+1].color) then
        return true
    end

    if a>1 and (color == self.tiles[a-1][b+1].color) then
        return true
    end

    return false
end

--takes a tile and checks if this tile and the one 
--two spaces to the right can join with a tile to create a match
function Board:checkGapedHorizontal(a, b)
    if a == 7 then
        return false
    end

    local color = self.tiles[a][b].color
    if not (color == self.tiles[a+2][b].color) then
        return false
    end

    if b<8 and (color == self.tiles[a+1][b+1].color) then
        return true
    end

    if b>1 and (color == self.tiles[a+1][b-1].color) then
        return true
    end

    return false
end

function Board:checkMovesLeft()
    for x = 1, 7 do
        for y = 1, 8 do
            if self:checkAdjacentsHorizontal(x, y) or self:checkAdjacentsVertical(y, x) or
                self:checkGapedVertical(y, x) or self:checkGapedHorizontal(x, y) then
                return
            end
        end
    end

    self.canContinue = false
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    --initiialize the score
    self.score_to_give = 0

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1

        -- every horizontal tile
        for x = 2, 8 do

            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do

                        --check for shiny first
                        if self.tiles[y][x2].isShiny then
                            for w = 1, 8 do
                                table.insert(match, self.tiles[w][x2])
                                table.insert(match, self.tiles[y][w])
                            end
                        else
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                --check for shiny first
                if self.tiles[y][x].isShiny then
                    for w = 1, 8 do
                        table.insert(match, self.tiles[w][x])
                        table.insert(match, self.tiles[y][w])
                    end
                else
                    -- add each tile to the match that's in that match
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        --check for shiny first
                        if self.tiles[y2][x].isShiny then
                            for w = 1, 8 do
                                table.insert(match, self.tiles[w][x])
                                table.insert(match, self.tiles[y2][w])
                            end
                        else
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                --check for shiny first
                if self.tiles[y][x].isShiny then
                    for w = 1, 8 do
                        table.insert(match, self.tiles[y][w])
                        table.insert(match, self.tiles[w][x])
                    end
                else
                    -- add each tile to the match that's in that match
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    --reset score_to_give
    self.score_to_give = 0
    self.time_inc = 0

    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            --add to the score_to_give
            if not (self.tiles[tile.gridY][tile.gridX] == nil) then
                self.score_to_give  = self.score_to_give + 40 + 10*tile.variety
                self.tiles[tile.gridY][tile.gridX] = nil
                self.time_inc = self.time_inc + 1 
            end
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do

            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then

                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then

                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, self.colors[math.random(#self.colors)], self:giveType())
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end