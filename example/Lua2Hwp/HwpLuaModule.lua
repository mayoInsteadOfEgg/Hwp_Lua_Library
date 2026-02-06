local luacom = require("luacom") 
local HwpLuaLib = require("HwpLuaLib")
local HwpLuaModule = {}

--이거 만들었지
function HwpLuaModule.GetObject()
    local NewHwpObject = HwpLuaLib.HwpInstance.GetActiveObject()
    if NewHwpObject then
        return NewHwpObject
    else
        print("한글 객체를 찾을 수 없습니다.")
        return nil
    end
end

return HwpLuaModule