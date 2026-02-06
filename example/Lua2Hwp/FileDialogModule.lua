--FileDialog.lua--
local FileDialog = {}

-- for pure lua 5.1
local function to_base64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- 미리 정의된 프리셋 (필요에 따라 추가하세요)
local presets = {
    images = "Image Files|*.jpg;*.png;*.bmp;*.gif",
    texts  = "Text Files|*.txt;*.log;*.json;*.lua",
    excels = "Excel Files|*.xlsx;*.xls;*.csv",
    hwps   = "HWP Files|*.hwp;*.hwpx",
    all    = "All Files|*.*"
}


--- 파일 선택창 띄우기
-- @param filterType: 프리셋 이름(images, texts 등) 또는 직접 작성한 필터 문자열
-- @param title: 창 제목 (선택 사항)
function FileDialog.open(filterType, title)
    -- 입력값이 프리셋에 있으면 가져오고, 없으면 입력값 그대로 사용
    local filter = presets[filterType] or filterType or presets.all
    local windowTitle = title or "파일을 선택하세요"
    local based64_title = to_base64(windowTitle)
    -- PowerShell 커맨드 구성
    local psCommand = string.format(
        [[powershell -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; ]] ..
        [[Add-Type -AssemblyName System.Windows.Forms; ]] ..
        [[$f = New-Object System.Windows.Forms.OpenFileDialog; ]] ..
        [[$f.Title = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%s')); ]] ..
        [[$f.Filter = '%s'; ]] ..
        [[if($f.ShowDialog() -eq 'OK') { Write-Host $f.FileName }"]],
        based64_title, filter
    )

    local success, handle = pcall(function()
        return io.popen(psCommand)
    end)

    if not success then
        print("err: "..handle)
        return nil
    end

    --local handle = io.popen(psCommand)
    local result = handle:read("*a")
    handle:close()

    -- 줄바꿈 제거 및 결과 반환
    result = result:gsub("[\r\n]", "")
    return (result ~= "" and result or nil)
end

return FileDialog