local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Tabela do trzymania połączeń, żeby łatwo je zabić przy Unload
local Connections = {}
-- Tabela do trzymania obiektów Drawing (Box ESP)
local ESP_Drawings = {}

local flags = {
    -- ESP
    ESP = false,
    ESP_Names = true,
    ESP_Fill = Color3.fromRGB(255, 0, 50),
    ESP_Outline = Color3.fromRGB(255, 255, 255),
    ESP_NameColor = Color3.fromRGB(255, 255, 255),
    ESP_FillTrans = 0.5,
    ESP_OutlineTrans = 0,

    -- FOV
    FOV_Visible = false,
    FOV_Radius = 150,
    FOV_Color = Color3.fromRGB(255, 255, 255),

    -- Camera Aimbot System (1st Person)
    AimbotSystem = false,
    AimMode = "Hold",
    AimKey = Enum.UserInputType.MouseButton2,
    IsAiming = false,
    AimbotSmoothness = 1,

    -- Mouse Aimlock System (3rd Person)
    AimlockSystem = false,
    AimlockMode = "Hold",
    AimlockKey = Enum.KeyCode.E,
    IsAimlocking = false,
    AimlockSmoothness = 1,

    -- Triggerbot
    Triggerbot = false
}

-- Inicjalizacja kółka FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = false
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.Color = flags.FOV_Color
FOVCircle.Visible = flags.FOV_Visible

local window = Rayfield:CreateWindow({
    name = "Handy HUB",
    subtitle = "All in One Tool | by Dinguz",
})

-- ================= FUNKCJE POMOCNICZE ================= --
-- Funkcja czyszcząca obiekty Drawing z ekranu
local function ClearESP(player)
    if ESP_Drawings[player] then
        if ESP_Drawings[player].BoxOutline then ESP_Drawings[player].BoxOutline:Remove() end
        if ESP_Drawings[player].BoxFill then ESP_Drawings[player].BoxFill:Remove() end
        if ESP_Drawings[player].NameText then ESP_Drawings[player].NameText:Remove() end
        ESP_Drawings[player] = nil
    end
end

-- Bezpieczne poszukiwanie gracza na podstawie Raycastu
local function GetPlayerFromPart(part)
    local current = part
    while current and current ~= workspace do
        if current:IsA("Model") and current:FindFirstChild("Humanoid") then
            local plr = Players:GetPlayerFromCharacter(current)
            if plr then return plr end
        end
        current = current.Parent
    end
    return nil
end

--======================--
--======== MAIN ========--
--======================--
local mainTab = window:CreateTab({ name = "Main" })

mainTab:CreateSection({ name = "Handy HUB, your all in one tool." })
mainTab:CreateSection({ name = "Made by Dinguz" })

mainTab:CreateButton({
    name = "Dinguz's Bio",
    description = "Copies the e-z.bio link to clipboard",
    callback = function()
        if setclipboard then
            setclipboard("https://e-z.bio/Dinguz")
            window:Notify({ 
                title = "Copied!", 
                content = "The e-z.bio/Dinguz link has been copied to your clipboard.",
                duration = 4
            })
        else
            window:Notify({ 
                title = "Error", 
                content = "Your executor does not support clipboard copying (setclipboard).",
                duration = 4
            })
        end
    end,
})

mainTab:CreateSection({ name = "Panic Button" })

mainTab:CreateButton({
    name = "Unload HUB",
    description = "Stops all scripts, removes ESP, and deletes the UI.",
    callback = function()
        for _, conn in ipairs(Connections) do
            if conn.Disconnect then
                conn:Disconnect()
            end
        end
        
        if FOVCircle then
            FOVCircle:Remove()
        end

        for player, _ in pairs(ESP_Drawings) do
            ClearESP(player)
        end

        window:Unload()
    end,
})

--======================--
--======= SCRIPTS ======--
--======================--
local scriptsTab = window:CreateTab({ name = "Scripts" })

scriptsTab:CreateButton({
    name = "DEX",
    callback = function()
        loadstring(game:HttpGet("https://github.com/Tesker-103/DexRecontinued/releases/latest/download/out.lua"))()
    end,
})

scriptsTab:CreateButton({
    name = "Nameless",
    callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))()
    end,
})

scriptsTab:CreateButton({
    name = "Sirius",
    callback = function()
        loadstring(game:HttpGet('https://sirius.menu/sirius'))()
    end,
})

scriptsTab:CreateButton({
    name = "Cobalt",
    callback = function()
        loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
    end,
})

--======================--
--=== VISUALS & FOV ====--
--======================--
local visualsTab = window:CreateTab({ name = "Visuals & FOV" })

-- System 2D Box ESP + Names
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            
            if flags.ESP and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                
                if not ESP_Drawings[player] then
                    ESP_Drawings[player] = {
                        BoxOutline = Drawing.new("Square"),
                        BoxFill = Drawing.new("Square"),
                        NameText = Drawing.new("Text")
                    }
                    ESP_Drawings[player].BoxOutline.Thickness = 2
                    ESP_Drawings[player].BoxOutline.Filled = false
                    
                    ESP_Drawings[player].BoxFill.Thickness = 1
                    ESP_Drawings[player].BoxFill.Filled = true
                    
                    ESP_Drawings[player].NameText.Size = 16
                    ESP_Drawings[player].NameText.Center = true
                    ESP_Drawings[player].NameText.Outline = true
                end
                
                local hrp = char.HumanoidRootPart
                local headPos = char:FindFirstChild("Head") and char.Head.Position + Vector3.new(0, 0.5, 0) or hrp.Position + Vector3.new(0, 2.5, 0)
                local legPos = hrp.Position - Vector3.new(0, 3, 0)
                
                local headScreen, headOnScreen = Camera:WorldToViewportPoint(headPos)
                local legScreen, legOnScreen = Camera:WorldToViewportPoint(legPos)
                
                if headOnScreen and legOnScreen then
                    local height = math.abs(headScreen.Y - legScreen.Y)
                    local width = height * 0.6
                    
                    local pos = Vector2.new(headScreen.X - width / 2, headScreen.Y)
                    local size = Vector2.new(width, height)
                    
                    -- Rysowanie Konturów
                    local outline = ESP_Drawings[player].BoxOutline
                    outline.Size = size
                    outline.Position = pos
                    outline.Color = flags.ESP_Outline
                    outline.Transparency = 1 - flags.ESP_OutlineTrans
                    outline.Visible = true
                    
                    -- Rysowanie Wypełnienia
                    local fill = ESP_Drawings[player].BoxFill
                    fill.Size = size
                    fill.Position = pos
                    fill.Color = flags.ESP_Fill
                    fill.Transparency = 1 - flags.ESP_FillTrans
                    fill.Visible = true
                    
                    -- Rysowanie Imion (DisplayName [@username])
                    local nameText = ESP_Drawings[player].NameText
                    if flags.ESP_Names then
                        nameText.Text = string.format("%s [@%s]", player.DisplayName, player.Name)
                        nameText.Position = Vector2.new(headScreen.X, legScreen.Y + 4) -- Pod boxem
                        nameText.Color = flags.ESP_NameColor
                        nameText.Transparency = 1
                        nameText.Visible = true
                    else
                        nameText.Visible = false
                    end
                else
                    ESP_Drawings[player].BoxOutline.Visible = false
                    ESP_Drawings[player].BoxFill.Visible = false
                    ESP_Drawings[player].NameText.Visible = false
                end
            else
                ClearESP(player)
            end
        end
    end
end

visualsTab:CreateSection({ name = "2D Box ESP & Names" })

visualsTab:CreateToggle({
    name = "Enable ESP",
    value = false,
    callback = function(state)
        flags.ESP = state
        if not state then 
            for player, _ in pairs(ESP_Drawings) do ClearESP(player) end 
        end
    end,
})

visualsTab:CreateToggle({
    name = "Show Names",
    value = true,
    callback = function(state)
        flags.ESP_Names = state
    end,
})

visualsTab:CreateColorPicker({
    name = "ESP Fill Color",
    color = Color3.fromRGB(255, 0, 50),
    callback = function(color) flags.ESP_Fill = color end,
})

visualsTab:CreateColorPicker({
    name = "ESP Outline Color",
    color = Color3.fromRGB(255, 255, 255),
    callback = function(color) flags.ESP_Outline = color end,
})

visualsTab:CreateColorPicker({
    name = "ESP Name Color",
    color = Color3.fromRGB(255, 255, 255),
    callback = function(color) flags.ESP_NameColor = color end,
})

visualsTab:CreateSlider({
    name = "ESP Fill Transparency",
    range = { 0, 100 },
    increment = 1,
    value = 50,
    suffix = "%",
    callback = function(val) flags.ESP_FillTrans = val / 100 end,
})

visualsTab:CreateSlider({
    name = "ESP Outline Transparency",
    range = { 0, 100 },
    increment = 1,
    value = 0,
    suffix = "%",
    callback = function(val) flags.ESP_OutlineTrans = val / 100 end,
})

visualsTab:CreateSection({ name = "FOV Settings" })

visualsTab:CreateToggle({
    name = "Draw FOV Circle",
    value = false,
    callback = function(state)
        flags.FOV_Visible = state
        FOVCircle.Visible = state
    end,
})

visualsTab:CreateSlider({
    name = "FOV Radius",
    range = { 10, 800 },
    increment = 1,
    value = 150,
    suffix = " px",
    callback = function(val)
        flags.FOV_Radius = val
        FOVCircle.Radius = val
    end,
})

visualsTab:CreateColorPicker({
    name = "FOV Color",
    color = Color3.fromRGB(255, 255, 255),
    callback = function(color)
        flags.FOV_Color = color
        FOVCircle.Color = color
    end,
})

--======================--
--========= AIM ========--
--======================--
local aimTab = window:CreateTab({ name = "AIM" })

local function GetNearestPlayer()
    local nearestTarget = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local headPos = player.Character.Head.Position
                local viewportPos, onScreen = Camera:WorldToViewportPoint(headPos)
                
                if onScreen then
                    local magnitude = (Vector2.new(viewportPos.X, viewportPos.Y) - mousePos).Magnitude
                    if magnitude <= flags.FOV_Radius and magnitude < shortestDistance then
                        nearestTarget = player.Character
                        shortestDistance = magnitude
                    end
                end
            end
        end
    end
    return nearestTarget
end

-- --- CAMERA AIMBOT --- --
aimTab:CreateSection({ name = "Camera Aimbot (1st Person)" })

aimTab:CreateToggle({
    name = "Enable Camera Aimbot",
    value = false,
    callback = function(state)
        flags.AimbotSystem = state
        if not state then flags.IsAiming = false end
    end,
})

aimTab:CreateDropdown({
    name = "Activation Mode",
    options = { "Hold", "Toggle" },
    value = "Hold",
    callback = function(selected)
        flags.AimMode = selected
        flags.IsAiming = false
    end,
})

aimTab:CreateKeybind({
    name = "Action Key",
    value = Enum.UserInputType.MouseButton2,
    callback = function() end,
    onChanged = function(newKey)
        flags.AimKey = newKey
        flags.IsAiming = false
    end,
})

aimTab:CreateSlider({
    name = "Smoothness",
    range = { 1, 10 },
    increment = 0.5,
    value = 1,
    suffix = " (1 = Insta)",
    callback = function(value) flags.AimbotSmoothness = value end,
})

-- --- MOUSE AIMLOCK --- --
aimTab:CreateSection({ name = "Mouse Aimlock (3rd Person)" })

aimTab:CreateToggle({
    name = "Enable Mouse Aimlock",
    value = false,
    callback = function(state)
        flags.AimlockSystem = state
        if not state then flags.IsAimlocking = false end
    end,
})

aimTab:CreateDropdown({
    name = "Lock Mode",
    options = { "Hold", "Toggle" },
    value = "Hold",
    callback = function(selected)
        flags.AimlockMode = selected
        flags.IsAimlocking = false
    end,
})

aimTab:CreateKeybind({
    name = "Lock Key",
    value = Enum.KeyCode.E,
    callback = function() end,
    onChanged = function(newKey)
        flags.AimlockKey = newKey
        flags.IsAimlocking = false
    end,
})

aimTab:CreateSlider({
    name = "Aimlock Smoothness",
    range = { 1, 10 },
    increment = 0.5,
    value = 5,
    suffix = " (1 = Insta)",
    callback = function(value) flags.AimlockSmoothness = value end,
})

-- --- TRIGGERBOT --- --
aimTab:CreateSection({ name = "Misc" })

aimTab:CreateToggle({
    name = "Triggerbot",
    value = false,
    callback = function(state) flags.Triggerbot = state end,
})

-- ================= LOGIKA WPROWADZANIA (KLIKNIĘĆ) ================= --
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if flags.AimbotSystem and (input.KeyCode == flags.AimKey or input.UserInputType == flags.AimKey) then
        if flags.AimMode == "Hold" then
            flags.IsAiming = true
        elseif flags.AimMode == "Toggle" then
            flags.IsAiming = not flags.IsAiming
        end
    end

    if flags.AimlockSystem and (input.KeyCode == flags.AimlockKey or input.UserInputType == flags.AimlockKey) then
        if flags.AimlockMode == "Hold" then
            flags.IsAimlocking = true
        elseif flags.AimlockMode == "Toggle" then
            flags.IsAimlocking = not flags.IsAimlocking
        end
    end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if flags.AimbotSystem and (input.KeyCode == flags.AimKey or input.UserInputType == flags.AimKey) then
        if flags.AimMode == "Hold" then
            flags.IsAiming = false
        end
    end

    if flags.AimlockSystem and (input.KeyCode == flags.AimlockKey or input.UserInputType == flags.AimlockKey) then
        if flags.AimlockMode == "Hold" then
            flags.IsAimlocking = false
        end
    end
end))

table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end))

-- ================= GŁÓWNA PĘTLA GRY ================= --
local lastTriggerTime = 0
local triggerbotDelay = 0.01

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    
    if FOVCircle then
        FOVCircle.Position = mouseLoc
    end
    
    UpdateESP()

    -- 1. Camera Aimbot
    if flags.AimbotSystem and flags.IsAiming then
        local target = GetNearestPlayer()
        if target and target:FindFirstChild("Head") then
            local targetPos = target.Head.Position
            if flags.AimbotSmoothness > 1 then
                local smoothFactor = 1 / flags.AimbotSmoothness
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smoothFactor)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end
    end

    -- 2. Mouse Aimlock
    if flags.AimlockSystem and flags.IsAimlocking then
        local target = GetNearestPlayer()
        if target and target:FindFirstChild("Head") then
            local targetScreenPos, onScreen = Camera:WorldToViewportPoint(target.Head.Position)
            
            if onScreen and mousemoverel then
                local deltaX = targetScreenPos.X - mouseLoc.X
                local deltaY = targetScreenPos.Y - mouseLoc.Y

                if flags.AimlockSmoothness > 1 then
                    local smooth = 1 / flags.AimlockSmoothness
                    deltaX = deltaX * smooth
                    deltaY = deltaY * smooth
                end

                mousemoverel(deltaX, deltaY)
            end
        end
    end

    -- 3. Zsynchronizowany Triggerbot
    if flags.Triggerbot then
        local triggerPart = nil
        
        if flags.AimbotSystem and flags.IsAiming then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            
            local rayResult = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000, rayParams)
            if rayResult then triggerPart = rayResult.Instance end
        else
            triggerPart = Mouse.Target
        end

        if triggerPart then
            local hitPlayer = GetPlayerFromPart(triggerPart)
            if hitPlayer and hitPlayer ~= LocalPlayer and hitPlayer.Character and hitPlayer.Character:FindFirstChild("Humanoid") and hitPlayer.Character.Humanoid.Health > 0 then
                if os.clock() - lastTriggerTime >= triggerbotDelay then
                    if mouse1click then 
                        mouse1click() 
                    else
                        print("Pew pew! (Triggerbot hit: " .. hitPlayer.Name .. ")")
                    end
                    lastTriggerTime = os.clock()
                end
            end
        end
    end
end))
