local luacom = require("luacom")
local HwpLuaModule = require("HwpLuaModule")

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
            
            local hwp = HwpLuaModule.GetObject()
            if hwp then
                print("found")
                print(hwp)
                
                local start_time = os.clock()
                -- HAction, HParameterSet 미리 가져오기 (루프 재사용)
                local ha = hwp.HAction
                local ps = hwp.HParameterSet
                local insert_set = ps.HInsertText.HSet  -- 반복 사용

                -- 테스트할 텍스트
                local texts = {"hello world", "한글테스트"}

                local start_time = os.clock()

                for i = 1, 1000 do
                    for _, txt in ipairs(texts) do
                        ha:GetDefault("InsertText", insert_set)
                        ps.HInsertText.Text = txt
                        ha:Execute("InsertText", insert_set)
                        ha:Run("BreakPara")  -- 문단 나누기
                    end

                    -- 50 루프마다 가비지 컬렉션
                    if i % 50 == 0 then
                        collectgarbage("collect")
                    end
                end

                print("done")
                print(os.clock()-start_time)
            else
                print("not found")
            end
        end
    end
end
