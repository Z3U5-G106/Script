-- Z3U5 HUB v2.0

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Core Variables
local ESPObjects = {}
local Connections = {}
local ESPToggles = {
    Monster = false,
    Player = false,
    Items = false,
    Houses = false,
    Cache = false
}
local ESPColors = {
    Monster = Color3.fromRGB(255, 0, 0),
    Player = Color3.fromRGB(0, 255, 0),
    Items = Color3.fromRGB(0, 255, 255),
    Houses = Color3.fromRGB(255, 255, 255),
    Cache = Color3.fromRGB(255, 0, 255)
}

-- Location Data
local HousePositions = {
    {name = "House 1", pos = Vector3.new(-1899.73, 13.55, -1019.22)},
    {name = "House 2", pos = Vector3.new(-1967.71, 5.20, -1265.53)},
    {name = "House 3", pos = Vector3.new(-2252.76, 4.56, -962.53)},
    {name = "House 4", pos = Vector3.new(-2350.38, 10.36, -1146.34)},
    {name = "House 5", pos = Vector3.new(-2229.85, 9.95, -1444.92)},
    {name = "House 6", pos = Vector3.new(-2397.95, 2.89, -1517.19)},
    {name = "House 7", pos = Vector3.new(-1915.93, 4.45, -1621.71)},
    {name = "House 8", pos = Vector3.new(-1696.46, 10.51, -1695.40)},
    {name = "House 9", pos = Vector3.new(-1695.99, 1.81, -1382.98)},
    {name = "House 10", pos = Vector3.new(-1531.26, 10.06, -1192.95)},
    {name = "House 11", pos = Vector3.new(-1483.31, 2.00, -1369.89)},
    {name = "House 12", pos = Vector3.new(-1427.03, 10.19, -1610.70)},
    {name = "WaterPump", pos = Vector3.new(-1666.40, 11.56, -1080.11)},
    {name = "Power Station", pos = Vector3.new(-2124.63, 8.99, -1790.79)},
    {name = "Church", pos = Vector3.new(-1853.36, 11.98, -1864.70)},
    {name = "Shop", pos = Vector3.new(-1822.92, 2.65, -1470.27)},
    {name = "NPC Shop", pos = Vector3.new(-2080.18, 8.13, -1014.72)}
}

-- UI Variables
local ScreenGui
local MainButton
local MainFrame
local TeleportFrame
local OthersFrame
local isMainFrameVisible = false

-- Core Functions
local function createBillboardGui(parent, text, color, offset)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Parent = parent
    billboardGui.AlwaysOnTop = true
    billboardGui.Size = UDim2.new(0, 130, 0, 32) -- 35% smaller (200*0.65=130, 50*0.65≈32)
    billboardGui.StudsOffset = offset or Vector3.new(0, 2, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboardGui
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    
    return billboardGui
end

local function createHighlight(parent, color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = parent
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    return highlight
end

local function createESP(object, text, color, offset)
    if not object or ESPObjects[object] then return end
    
    local billboard = createBillboardGui(object, text, color, offset)
    local highlight = createHighlight(object, color)
    
    ESPObjects[object] = {
        billboard = billboard,
        highlight = highlight
    }
end

local function createBillboardOnly(object, text, color, offset)
    if not object or ESPObjects[object] then return end
    
    local billboard = createBillboardGui(object, text, color, offset)
    
    ESPObjects[object] = {
        billboard = billboard,
        highlight = nil
    }
end

local function removeESP(object)
    if ESPObjects[object] then
        if ESPObjects[object].billboard then
            ESPObjects[object].billboard:Destroy()
        end
        if ESPObjects[object].highlight then
            ESPObjects[object].highlight:Destroy()
        end
        ESPObjects[object] = nil
    end
end

local function createPositionESP(position, text, color)
    local part = Instance.new("Part")
    part.Name = text
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1, 1, 1)
    part.Position = position
    part.Parent = workspace
    
    createESP(part, text, color)
    return part
end

-- ESP Update Functions
local function updateMonsterESP()
    local wendigo = workspace:FindFirstChild("AI") and workspace.AI:FindFirstChild("WendigoAI")
    if wendigo and ESPToggles.Monster then
        createESP(wendigo, "Wendigo", ESPColors.Monster)
    elseif not ESPToggles.Monster then
        if wendigo then removeESP(wendigo) end
    end
end

local function updatePlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            
            if ESPToggles.Player then
                local hp = humanoid and math.floor(humanoid.Health) or 0
                local maxHp = humanoid and math.floor(humanoid.MaxHealth) or 100
                local text = player.Name .. "\nHP: " .. hp .. "/" .. maxHp
                
                -- Billboard (always show when ESP is enabled)
                if not ESPObjects[character] then
                    local billboard = createBillboardGui(character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"), text, ESPColors.Player)
                    ESPObjects[character] = {billboard = billboard, highlight = nil}
                else
                    ESPObjects[character].billboard.TextLabel.Text = text
                end
                
                -- Distance-based highlight (independent from billboard)
                local distance = (character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
                if distance <= 350 and not ESPObjects[character].highlight then
                    ESPObjects[character].highlight = createHighlight(character, ESPColors.Player)
                elseif distance > 350 and ESPObjects[character].highlight then
                    ESPObjects[character].highlight:Destroy()
                    ESPObjects[character].highlight = nil
                end
            else
                removeESP(character)
            end
        end
    end
end

local function updateItemsESP()
    local itemFolders = {
        workspace:FindFirstChild("ItemSpawners") and workspace.ItemSpawners:FindFirstChild("Items"),
        workspace:FindFirstChild("ItemSpawners") and workspace.ItemSpawners:FindFirstChild("ShopItemPickups")
    }
    
    for _, folder in pairs(itemFolders) do
        if folder then
            for _, item in pairs(folder:GetChildren()) do
                if ESPToggles.Items then
                    -- Remove "pickup" from the end of item names (case insensitive)
                    local displayName = item.Name
                    if string.lower(string.sub(displayName, -6)) == "pickup" then
                        displayName = string.sub(displayName, 1, -7) -- Remove last 6 characters + space if any
                    end
                    createBillboardOnly(item, displayName, ESPColors.Items, Vector3.new(0, 0, 0))
                else
                    removeESP(item)
                end
            end
        end
    end
end

local function updateHousesESP()
    for _, houseData in pairs(HousePositions) do
        local existingPart = workspace:FindFirstChild(houseData.name)
        if ESPToggles.Houses then
            if not existingPart then
                createPositionESP(houseData.pos, houseData.name, ESPColors.Houses)
            end
        else
            if existingPart then
                removeESP(existingPart)
                existingPart:Destroy()
            end
        end
    end
end

local function updateCacheESP()
    local cacheBox = workspace:FindFirstChild("Caches") and workspace.Caches:FindFirstChild("CacheBox")
    local paper = workspace:FindFirstChild("Caches") and workspace.Caches:FindFirstChild("Paper")
    
    if ESPToggles.Cache then
        if cacheBox then createESP(cacheBox, "CacheBox", ESPColors.Cache) end
        if paper then createESP(paper, "Code", ESPColors.Cache) end
    else
        if cacheBox then removeESP(cacheBox) end
        if paper then removeESP(paper) end
    end
end

-- Teleport Function
local function teleportTo(position)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- UI Creation
local function createToggleButton(parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    local isToggled = false
    button.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        button.BackgroundColor3 = isToggled and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(45, 45, 45)
        callback(isToggled)
    end)
    
    return button
end

local function createActionButton(parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local function createUI()
    -- Main ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Z3U5Hub"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    -- Toggle Button
    MainButton = Instance.new("TextButton")
    MainButton.Name = "ToggleButton"
    MainButton.Parent = ScreenGui
    MainButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    MainButton.BorderSizePixel = 0
    MainButton.Position = UDim2.new(0, 10, 0, 10)
    MainButton.Size = UDim2.new(0, 50, 0, 50)
    MainButton.Font = Enum.Font.GothamBold
    MainButton.Text = "⚡"
    MainButton.TextColor3 = Color3.fromRGB(255, 165, 0)
    MainButton.TextScaled = true
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 25)
    buttonCorner.Parent = MainButton
    
    -- Make button draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragThreshold = 5 -- Minimum pixels to consider dragging
    
    MainButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = MainButton.Position
        end
    end)
    
    MainButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragStart and not dragging then
                local delta = input.Position - dragStart
                if delta.Magnitude > dragThreshold then
                    dragging = true
                end
            end
            
            if dragging and dragStart then
                local delta = input.Position - dragStart
                MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    
    MainButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not dragging then
                -- This was a click, not a drag
                wait(0.1)
                isMainFrameVisible = not isMainFrameVisible
                MainFrame.Visible = isMainFrameVisible
                
                -- Animate the frame
                if isMainFrameVisible then
                    MainFrame.Size = UDim2.new(0, 0, 0, 0)
                    MainFrame.Visible = true
                    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 360)})
                    tween:Play()
                else
                    TeleportFrame.Visible = false
                    OthersFrame.Visible = false
                    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)})
                    tween:Play()
                    tween.Completed:Connect(function()
                        MainFrame.Visible = false
                    end)
                end
            end
            
            dragging = false
            dragStart = nil
            startPos = nil
        end
    end)
    
    -- Main Frame
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 70, 0, 10)
    MainFrame.Size = UDim2.new(0, 200, 0, 360)
    MainFrame.Visible = false
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = MainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = MainFrame
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.Text = "Z3U5 HUB v2.0"
    title.TextColor3 = Color3.fromRGB(255, 165, 0)
    title.TextScaled = true
    
    -- ESP Toggles
    createToggleButton(MainFrame, "Monster ESP", UDim2.new(0, 10, 0, 40), function(toggled)
        ESPToggles.Monster = toggled
        updateMonsterESP()
    end)
    
    createToggleButton(MainFrame, "Player ESP", UDim2.new(0, 10, 0, 80), function(toggled)
        ESPToggles.Player = toggled
        updatePlayerESP()
    end)
    
    createToggleButton(MainFrame, "Items ESP", UDim2.new(0, 10, 0, 120), function(toggled)
        ESPToggles.Items = toggled
        updateItemsESP()
    end)
    
    createToggleButton(MainFrame, "Houses ESP", UDim2.new(0, 10, 0, 160), function(toggled)
        ESPToggles.Houses = toggled
        updateHousesESP()
    end)
    
    createToggleButton(MainFrame, "Cache ESP", UDim2.new(0, 10, 0, 200), function(toggled)
        ESPToggles.Cache = toggled
        updateCacheESP()
    end)
    
    -- Menu Buttons
    createActionButton(MainFrame, "Teleport", UDim2.new(0, 10, 0, 240), function()
        TeleportFrame.Visible = not TeleportFrame.Visible
        OthersFrame.Visible = false
    end)
    
    createActionButton(MainFrame, "Others", UDim2.new(0, 10, 0, 280), function()
        OthersFrame.Visible = not OthersFrame.Visible
        TeleportFrame.Visible = false
    end)
    
    -- Close Button
    createActionButton(MainFrame, "Close", UDim2.new(0, 10, 0, 320), function()
        isMainFrameVisible = false
        TeleportFrame.Visible = false
        OthersFrame.Visible = false
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            MainFrame.Visible = false
        end)
    end)
    
    -- Teleport Frame
    TeleportFrame = Instance.new("ScrollingFrame")
    TeleportFrame.Name = "TeleportFrame"
    TeleportFrame.Parent = ScreenGui
    TeleportFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TeleportFrame.BorderSizePixel = 0
    TeleportFrame.Position = UDim2.new(0, 280, 0, 10)
    TeleportFrame.Size = UDim2.new(0, 200, 0, 300)
    TeleportFrame.Visible = false
    TeleportFrame.CanvasSize = UDim2.new(0, 0, 0, #HousePositions * 40 + 40)
    TeleportFrame.ScrollBarThickness = 5
    
    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 10)
    teleportCorner.Parent = TeleportFrame
    
    -- Teleport Title
    local teleportTitle = Instance.new("TextLabel")
    teleportTitle.Name = "Title"
    teleportTitle.Parent = TeleportFrame
    teleportTitle.BackgroundTransparency = 1
    teleportTitle.Position = UDim2.new(0, 0, 0, 0)
    teleportTitle.Size = UDim2.new(1, 0, 0, 30)
    teleportTitle.Font = Enum.Font.GothamBold
    teleportTitle.Text = "Teleport Menu"
    teleportTitle.TextColor3 = Color3.fromRGB(255, 165, 0)
    teleportTitle.TextScaled = true
    
    -- Teleport Buttons
    for i, location in pairs(HousePositions) do
        createActionButton(TeleportFrame, location.name, UDim2.new(0, 10, 0, 30 + (i-1) * 40), function()
            teleportTo(location.pos)
        end)
    end
    
    -- Others Frame
    OthersFrame = Instance.new("Frame")
    OthersFrame.Name = "OthersFrame"
    OthersFrame.Parent = ScreenGui
    OthersFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    OthersFrame.BorderSizePixel = 0
    OthersFrame.Position = UDim2.new(0, 280, 0, 10)
    OthersFrame.Size = UDim2.new(0, 200, 0, 300)
    OthersFrame.Visible = false
    
    local othersCorner = Instance.new("UICorner")
    othersCorner.CornerRadius = UDim.new(0, 10)
    othersCorner.Parent = OthersFrame
    
    -- Others Title
    local othersTitle = Instance.new("TextLabel")
    othersTitle.Name = "Title"
    othersTitle.Parent = OthersFrame
    othersTitle.BackgroundTransparency = 1
    othersTitle.Position = UDim2.new(0, 0, 0, 0)
    othersTitle.Size = UDim2.new(1, 0, 0, 30)
    othersTitle.Font = Enum.Font.GothamBold
    othersTitle.Text = "Others Menu"
    othersTitle.TextColor3 = Color3.fromRGB(255, 165, 0)
    othersTitle.TextScaled = true
    
    -- Others Buttons
    createActionButton(OthersFrame, "Chat Unlocker", UDim2.new(0, 10, 0, 40), function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Z3U5-G106/Script/refs/heads/main/chat-unlocker.lua"))()
    end)
    
    createActionButton(OthersFrame, "Anti Lag", UDim2.new(0, 10, 0, 80), function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Z3U5-G106/Script/refs/heads/main/Z3U5-ANTILAG"))()
    end)
    
    createActionButton(OthersFrame, "Fly GUI V4", UDim2.new(0, 10, 0, 120), function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Better-Fly-GUI-44304"))()
    end)
    
    -- Toggle main frame visibility (removed duplicate since it's now in InputEnded)
    -- MainFrame toggle is now handled in the InputEnded event above
end

-- Setup monitoring connections
local function setupConnections()
    -- Monitor workspace changes
    if workspace:FindFirstChild("AI") then
        Connections.MonsterAdded = workspace.AI.ChildAdded:Connect(updateMonsterESP)
        Connections.MonsterRemoved = workspace.AI.ChildRemoved:Connect(updateMonsterESP)
    end
    
    if workspace:FindFirstChild("ItemSpawners") then
        if workspace.ItemSpawners:FindFirstChild("Items") then
            Connections.ItemsAdded = workspace.ItemSpawners.Items.ChildAdded:Connect(updateItemsESP)
            Connections.ItemsRemoved = workspace.ItemSpawners.Items.ChildRemoved:Connect(updateItemsESP)
        end
        if workspace.ItemSpawners:FindFirstChild("ShopItemPickups") then
            Connections.ShopItemsAdded = workspace.ItemSpawners.ShopItemPickups.ChildAdded:Connect(updateItemsESP)
            Connections.ShopItemsRemoved = workspace.ItemSpawners.ShopItemPickups.ChildRemoved:Connect(updateItemsESP)
        end
    end
    
    if workspace:FindFirstChild("Caches") then
        Connections.CacheAdded = workspace.Caches.ChildAdded:Connect(updateCacheESP)
        Connections.CacheRemoved = workspace.Caches.ChildRemoved:Connect(updateCacheESP)
    end
    
    -- Monitor player changes
    Connections.PlayerAdded = Players.PlayerAdded:Connect(updatePlayerESP)
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        if player.Character and ESPObjects[player.Character] then
            removeESP(player.Character)
        end
    end)
    
    -- Update player ESP every 0.1 seconds
    Connections.PlayerESPUpdate = RunService.Heartbeat:Connect(function()
        if ESPToggles.Player then
            updatePlayerESP()
        end
    end)
end

-- Initialize script
createUI()
setupConnections()

print("Z3U5 HUB v2.0 Loaded Successfully!")