--[[ HopefulFS Loader | Xeno Friendly ]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- remove old loader
pcall(function()
    CoreGui:FindFirstChild("HopefulFS_Loader"):Destroy()
end)

-- ===== GUI ROOT =====
local gui = Instance.new("ScreenGui")
gui.Name = "HopefulFS_Loader"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- ===== BACKGROUND =====
local bg = Instance.new("Frame", gui)
bg.Size = UDim2.fromScale(1,1)
bg.BackgroundColor3 = Color3.fromRGB(10,10,10)
bg.BackgroundTransparency = 1

TweenService:Create(bg, TweenInfo.new(0.4), {
    BackgroundTransparency = 0
}):Play()

-- ===== CARD =====
local card = Instance.new("Frame", bg)
card.Size = UDim2.fromOffset(380,240)
card.Position = UDim2.fromScale(0.5,0.5)
card.AnchorPoint = Vector2.new(0.5,0.5)
card.BackgroundColor3 = Color3.fromRGB(25,25,25)

Instance.new("UICorner", card).CornerRadius = UDim.new(0,12)

-- draggable
card.Active = true
card.Draggable = true

-- ===== TITLE =====
local title = Instance.new("TextLabel", card)
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "🔐 HopefulFS Key System"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)

-- ===== SUBTEXT =====
local sub = Instance.new("TextLabel", card)
sub.Position = UDim2.fromOffset(0,42)
sub.Size = UDim2.new(1,0,0,20)
sub.BackgroundTransparency = 1
sub.Text = "Enter your key to continue"
sub.Font = Enum.Font.Gotham
sub.TextSize = 13
sub.TextColor3 = Color3.fromRGB(180,180,180)

-- ===== TEXTBOX =====
local box = Instance.new("TextBox", card)
box.Position = UDim2.fromOffset(40,80)
box.Size = UDim2.fromOffset(300,36)
box.PlaceholderText = "Enter key here..."
box.Text = ""
box.ClearTextOnFocus = false
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.TextColor3 = Color3.new(1,1,1)
box.BackgroundColor3 = Color3.fromRGB(35,35,35)

Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

-- ===== STATUS =====
local status = Instance.new("TextLabel", card)
status.Position = UDim2.fromOffset(40,120)
status.Size = UDim2.fromOffset(300,20)
status.BackgroundTransparency = 1
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(255,90,90)

-- ===== BUTTON =====
local btn = Instance.new("TextButton", card)
btn.Position = UDim2.fromOffset(40,150)
btn.Size = UDim2.fromOffset(300,38)
btn.Text = "Unlock"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 15
btn.TextColor3 = Color3.new(1,1,1)
btn.BackgroundColor3 = Color3.fromRGB(60,120,255)

Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

-- ===== KEY SYSTEM =====
local VALID_KEYS = {
    ["TEST-KEY-123"] = true,
    ["HOPEFULFS"] = true
}

local function showLoading()
    card:ClearAllChildren()

    local text = Instance.new("TextLabel", card)
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.Text = "Loading HopefulFS..."
    text.Font = Enum.Font.GothamBold
    text.TextSize = 18
    text.TextColor3 = Color3.new(1,1,1)

    task.wait(1.2)

    local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HopefulASFS/HopefulFS-Scripts/refs/heads/main/main.lua"))()
end)

if not success then
    warn("MAIN SCRIPT FAILED:", err)
end

gui:Destroy()

end

btn.MouseButton1Click:Connect(function()
    local key = box.Text
    if VALID_KEYS[key] then
        status.TextColor3 = Color3.fromRGB(80,255,120)
        status.Text = "Key accepted!"
        task.wait(0.6)
        showLoading()
    else
        status.TextColor3 = Color3.fromRGB(255,90,90)
        status.Text = "Invalid key!"
    end
end)


