--invisible
local key = Enum.KeyCode.X -- key to toggle invisibility

--// important 
local invis_on = false

function toggleInvisibility()
    invis_on = not invis_on
    if invis_on then
        local savedpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        wait()
        local newPos = savedpos.Position - Vector3.new(0, 200, 0) -- 200 studs below
        game.Players.LocalPlayer.Character:MoveTo(newPos)
        wait(.15)
        local Seat = Instance.new('Seat', game.Workspace)
        Seat.Anchored = false
        Seat.CanCollide = false
        Seat.Name = 'invischair'
        Seat.Transparency = 1
        Seat.Position = newPos
        local Weld = Instance.new("Weld", Seat)
        Weld.Part0 = Seat
        Weld.Part1 = game.Players.LocalPlayer.Character:FindFirstChild("Torso") or game.Players.LocalPlayer.Character.UpperTorso
        wait()
        Seat.CFrame = savedpos
        game.StarterGui:SetCore("SendNotification", {
            Title = "Invis On";
            Duration = 1;
            Text = "";
        })
    else
        local chair = workspace:FindFirstChild('invischair')
        if chair then chair:Destroy() end
        game.StarterGui:SetCore("SendNotification", {
            Title = "Invis Off";
            Duration = 1;
            Text = "";
        })
    end
end

function onKeyPress(inputObject, chat)
    if chat then return end
    if inputObject.KeyCode == key then
        toggleInvisibility()
    end
end

-- Create UI button with circular design and glow effect
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main button frame for circular shape
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Parent = ScreenGui
ButtonFrame.Size = UDim2.new(0, 60, 0, 60) -- Circular size
ButtonFrame.Position = UDim2.new(1, -80, 0, 20) -- Top right position
ButtonFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3) -- Grey background
ButtonFrame.BorderSizePixel = 0

-- Make it circular
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.5, 0) -- Makes it perfectly circular
Corner.Parent = ButtonFrame

-- Glow effect (outer border)
local Glow = Instance.new("Frame")
Glow.Parent = ButtonFrame
Glow.Size = UDim2.new(1, 6, 1, 6) -- Slightly larger for glow effect
Glow.Position = UDim2.new(0, -3, 0, -3) -- Center it
Glow.BackgroundColor3 = Color3.new(1, 0, 0) -- Starting glow color
Glow.BorderSizePixel = 0
Glow.ZIndex = ButtonFrame.ZIndex - 1 -- Behind the button

-- Make glow circular
local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0.5, 0)
GlowCorner.Parent = Glow

-- Add gradient for better glow effect
local GlowGradient = Instance.new("UIGradient")
GlowGradient.Parent = Glow
GlowGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 1)
})

-- Lightning bolt icon
local Icon = Instance.new("TextLabel")
Icon.Parent = ButtonFrame
Icon.Size = UDim2.new(1, 0, 1, 0)
Icon.Position = UDim2.new(0, 0, 0, 0)
Icon.Text = "⚡️"
Icon.TextColor3 = Color3.new(1, 1, 1) -- White icon
Icon.Font = Enum.Font.SourceSansBold
Icon.TextSize = 28
Icon.BackgroundTransparency = 1
Icon.TextStrokeTransparency = 0
Icon.TextStrokeColor3 = Color3.new(0, 0, 0) -- Black outline for better visibility

-- Invisible button for clicking
local Button = Instance.new("TextButton")
Button.Parent = ButtonFrame
Button.Size = UDim2.new(1, 0, 1, 0)
Button.Position = UDim2.new(0, 0, 0, 0)
Button.Text = ""
Button.BackgroundTransparency = 1

-- Button click animation
Button.MouseButton1Click:Connect(function()
    -- Quick scale animation on click
    ButtonFrame:TweenSize(
        UDim2.new(0, 55, 0, 55),
        "Out",
        "Quad",
        0.1,
        true,
        function()
            ButtonFrame:TweenSize(
                UDim2.new(0, 60, 0, 60),
                "Out",
                "Quad",
                0.1,
                true
            )
        end
    )
    toggleInvisibility()
end)

game:GetService("UserInputService").InputBegan:Connect(onKeyPress)

-- RGB Glow Effect
spawn(function()
    while true do
        for i = 0, 1, 0.01 do
            Glow.BackgroundColor3 = Color3.fromHSV(i, 1, 1)
            wait(0.05) -- Adjust speed of color change
        end
    end
end)