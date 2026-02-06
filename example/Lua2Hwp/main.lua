local luacom = require("luacom")
local HwpLuaLib = require("HwpLuaLib")
local FileDialog = require("FileDialog")

local quitButton = {}

function love.load()
    -- Define button properties (text, position)
    local font = love.graphics.getFont() -- Get default font or load a new one
    quitButton.text = love.graphics.newText(font, "Test")
    quitButton.x = 450
    quitButton.y = 375
end

function love.draw()
    -- Draw the button text on the screen
    love.graphics.draw(quitButton.text, quitButton.x, quitButton.y)
end

function love.mousepressed(x, y, button)
    -- Check if the left mouse button (button 1) was pressed
    if button == 1 then
        -- Get the button's dimensions
        local textWidth = quitButton.text:getWidth()
        local textHeight = quitButton.text:getHeight()

        -- Check if the click coordinates (x, y) are within the button's area
        if x >= quitButton.x and x <= quitButton.x + textWidth and
           y >= quitButton.y and y <= quitButton.y + textHeight then
            -- Action to perform when clicked (e.g., quit the game)
            local hwp = HwpLuaLib.HwpInstance.GetActiveObject()
            if hwp then
                print("found")
        
                print(hwp)
                
                hwp.HAction:GetDefault("InsertText", hwp.HParameterSet.HInsertText.HSet)
                hwp.HParameterSet.HInsertText.Text = "hello world"
                hwp.HAction:Execute("InsertText", hwp.HParameterSet.HInsertText.HSet)
                
                hwp.HAction:Run("BreakPara")

                hwp.HAction:GetDefault("InsertText", hwp.HParameterSet.HInsertText.HSet)
                hwp.HParameterSet.HInsertText.Text = "한글테스트"
                hwp.HAction:Execute("InsertText", hwp.HParameterSet.HInsertText.HSet)

                hwp.HAction:Run("BreakPara")

                -- local img_path = FileDialog.open("images")
                -- if img_path then
                --     hwp:InsertBackgroundPicture("SelectedCell", img_path, True)
                -- end
            
                print("done")
            else
                print("not found")
            end
        end
    end
end
