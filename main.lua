--[[ HopefulFS | Main Script (Xeno Friendly) ]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- CLEAN OLD UI
pcall(function()
    CoreGui:FindFirstChild("HopefulFS_Main"):Destroy()
end)

-- ================= UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "HopefulFS_Main"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(520, 360)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "💎 HopefulFS – Rivals"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)

-- WATERMARK
local wm = Instance.new("TextLabel", gui)
wm.Position = UDim2.fromOffset(10,10)
wm.Size = UDim2.fromOffset(300,20)
wm.BackgroundTransparency = 1
wm.Text = "HopefulFS | Xeno"
wm.Font = Enum.Font.Gotham
wm.TextSize = 13
wm.TextColor3 = Color3.fromRGB(200,200,200)

-- INSERT TOGGLE
local uiVisible = true
UserInputService.InputBegan:Connect(function(i,gp)
    if not gp and i.KeyCode == Enum.KeyCode.Insert then
        uiVisible = not uiVisible
        gui.Enabled = uiVisible
    end
end)

-- ================= SETTINGS =================
local Settings = {
    Aimbot = true,
    WallCheck = false,
    TeamCheck = true,
    AimPart = "Head",
    FOV = 120,

    ESP = true,
    ESPMaxDist = 1500
}

-- ================= FOV CIRCLE =================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 64
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Filled = false
FOVCircle.Visible = true

-- ================= UTILS =================
local function IsEnemy(plr)
    if not plr.Character or not LocalPlayer.Character then return false end
    if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
        return false
    end
    return plr ~= LocalPlayer
end

local function WallCheck(part)
    if not Settings.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local res = workspace:Raycast(
        Camera.CFrame.Position,
        (part.Position - Camera.CFrame.Position),
        params
    )
    return res and res.Instance:IsDescendantOf(part.Parent)
end

-- ================= AIMBOT =================
local function GetClosestTarget()
    local closest, dist = nil, Settings.FOV

    for _,plr in pairs(Players:GetPlayers()) do
        if IsEnemy(plr) and plr.Character then
            local char = plr.Character
            local part = char:FindFirstChild(Settings.AimPart) or char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if part and hum and hum.Health > 0 then
                local pos, onscreen = Camera:WorldToViewportPoint(part.Position)
                if onscreen then
                    local mag = (Vector2.new(pos.X,pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mag < dist and WallCheck(part) then
                        dist = mag
                        closest = part
                    end
                end
            end
        end
    end

    return closest
end

-- ================= ESP =================
local ESP = {}

local function CreateESP(plr)
    local txt = Drawing.new("Text")
    txt.Size = 13
    txt.Center = true
    txt.Outline = true
    ESP[plr] = txt
end

local function RemoveESP(plr)
    if ESP[plr] then
        ESP[plr]:Remove()
        ESP[plr] = nil
    end
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ================= LOOP =================
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV

    -- AIMBOT (RMB)
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    -- ESP
    for plr,txt in pairs(ESP) do
        if Settings.ESP and plr.Character and IsEnemy(plr) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hrp and hum then
                local pos, on = Camera:WorldToViewportPoint(hrp.Position)
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude

                if on and dist < Settings.ESPMaxDist then
                    txt.Visible = true
                    txt.Position = Vector2.new(pos.X, pos.Y)
                    txt.Text = string.format(
                        "%s\nHP: %d\n%dm",
                        plr.Name,
                        hum.Health,
                        dist
                    )
                    txt.Color = (plr.Team == LocalPlayer.Team)
                        and Color3.fromRGB(0,255,0)
                        or Color3.fromRGB(255,0,0)

                    txt.Transparency = math.clamp(1 - (dist / Settings.ESPMaxDist), 0.2, 1)
                else
                    txt.Visible = false
                end
            end
        else
            txt.Visible = false
        end
    end
end)
