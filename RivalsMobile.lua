-- ============================================================================
-- RIVALS MOBILE & PC COMBAT SUITE — HARDENED / SAFE-FALLBACK BUILD
-- ============================================================================
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local HasDrawing = (typeof(Drawing) == "table" or typeof(Drawing) == "function") and Drawing.new ~= nil
local HasHooks = (hookmetamethod ~= nil and newcclosure ~= nil and getnamecallmethod ~= nil and checkcaller ~= nil)

local Config = {
    SilentAim = {
        Enabled = true,
        HitChance = 100,
        TargetPart = "Head",
        FOV = 150,
        ShowFOV = true,
        WallCheck = true,
        TeamCheck = true,
        Prediction = 0.045
    },
    Aimbot = {
        Enabled = true,
        TargetPart = "Head",
        Smoothness = 0.25,
        AimAssistMode = IsMobile,
        AssistStrength = 0.12,
        FOV = 160,
        WallCheck = true,
        TeamCheck = true
    },
    Ragebot = {
        Enabled = false,
        AutoFire = true,
        FireDelay = 0.08,
        TargetPart = "Head",
        WallCheck = true
    },
    Visuals = {
        BoxESP = true,
        NameESP = true,
        HealthBar = true,
        Color = Color3.fromRGB(45, 226, 230)
    },
    SkinChanger = {
        Enabled = false,
        Material = "ForceField",
        PrimaryColor = Color3.fromRGB(45, 226, 230),
        SecondaryColor = Color3.fromRGB(138, 92, 246),
        Reflectance = 0.25
    }
}

-- TOUCH-COMPATIBLE DRAGGING HELPER
local function MakeTouchDraggable(dragHandle, moveTarget)
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- MOBILE FLOATING TOGGLE + MODERN STYLED HUB UI
local ActivityLabelRef, TargetLabelRef

local function CreateMobileRivalsUI()
    local existing = CoreGui:FindFirstChild("RivalsMobileHubUI") or PlayerGui:FindFirstChild("RivalsMobileHubUI")
    if existing then existing:Destroy() end

    local COL_BG_DARK   = Color3.fromRGB(16, 18, 24)
    local COL_CARD      = Color3.fromRGB(23, 26, 35)
    local COL_INPUT     = Color3.fromRGB(15, 17, 23)
    local COL_CYAN      = Color3.fromRGB(45, 226, 230)
    local COL_VIOLET    = Color3.fromRGB(138, 92, 246)
    local COL_EMERALD   = Color3.fromRGB(16, 185, 129)
    local COL_TEXT_MAIN = Color3.fromRGB(240, 244, 250)
    local COL_TEXT_DIM  = Color3.fromRGB(150, 160, 180)

    local gui = Instance.new("ScreenGui")
    gui.Name = "RivalsMobileHubUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    local parentOk = pcall(function() gui.Parent = CoreGui end)
    if not parentOk or not gui.Parent then gui.Parent = PlayerGui end

    local floatBtn = Instance.new("TextButton")
    floatBtn.Name = "MobileTogglePill"
    floatBtn.Size = UDim2.new(0, 74, 0, 34)
    floatBtn.Position = UDim2.new(0.03, 0, 0.16, 0)
    floatBtn.BackgroundColor3 = COL_BG_DARK
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.TextSize = 12
    floatBtn.TextColor3 = COL_CYAN
    floatBtn.Text = "UI: ON"
    floatBtn.ZIndex = 20
    floatBtn.Parent = gui
    Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

    local floatStroke = Instance.new("UIStroke", floatBtn)
    floatStroke.Thickness = 1.6
    floatStroke.Color = COL_CYAN

    local winW = IsMobile and 410 or 500
    local winH = IsMobile and 250 or 315

    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = UDim2.new(0, winW, 0, winH)
    main.Position = UDim2.new(0.5, -winW / 2, 0.5, -winH / 2)
    main.BackgroundColor3 = COL_BG_DARK
    main.BorderSizePixel = 0
    main.Visible = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Thickness = 1.6
    mainStroke.Color = Color3.new(1, 1, 1)

    local borderGrad = Instance.new("UIGradient", mainStroke)
    borderGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, COL_CYAN),
        ColorSequenceKeypoint.new(0.5, COL_VIOLET),
        ColorSequenceKeypoint.new(1.0, COL_EMERALD)
    })

    local function ToggleMenu()
        main.Visible = not main.Visible
        floatBtn.Text = main.Visible and "UI: ON" or "UI: OFF"
        floatBtn.TextColor3 = main.Visible and COL_CYAN or COL_TEXT_DIM
        floatStroke.Color = main.Visible and COL_CYAN or COL_VIOLET
    end

    floatBtn.MouseButton1Click:Connect(ToggleMenu)
    MakeTouchDraggable(floatBtn, floatBtn)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.Insert then
            ToggleMenu()
        end
    end)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36)
    topBar.BackgroundTransparency = 1
    topBar.Parent = main
    MakeTouchDraggable(topBar, main)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextColor3 = COL_TEXT_MAIN
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Text = "Rivals — Control Panel" .. (HasHooks and "" or " (No-Hook Mode)")
    titleLbl.Parent = topBar

    local hideBtn = Instance.new("TextButton")
    hideBtn.Size = UDim2.new(0, 28, 0, 24)
    hideBtn.Position = UDim2.new(1, -36, 0, 6)
    hideBtn.BackgroundColor3 = COL_CARD
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 12
    hideBtn.TextColor3 = COL_TEXT_DIM
    hideBtn.Text = "X"
    hideBtn.Parent = topBar
    Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 6)
    hideBtn.MouseButton1Click:Connect(ToggleMenu)

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 36)
    divider.BackgroundColor3 = Color3.fromRGB(38, 44, 58)
    divider.BorderSizePixel = 0
    divider.Parent = main

    local sideW = IsMobile and 108 or 130
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, sideW, 1, -46)
    sidebar.Position = UDim2.new(0, 10, 0, 42)
    sidebar.BackgroundTransparency = 1
    sidebar.Parent = main

    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.Padding = UDim.new(0, 6)

    local contentX = sideW + 18
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -(contentX + 10), 1, -80)
    contentArea.Position = UDim2.new(0, contentX, 0, 42)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    local footerBar = Instance.new("Frame")
    footerBar.Size = UDim2.new(1, -(contentX + 10), 0, 28)
    footerBar.Position = UDim2.new(0, contentX, 1, -34)
    footerBar.BackgroundColor3 = COL_CARD
    footerBar.Parent = main
    Instance.new("UICorner", footerBar).CornerRadius = UDim.new(0, 8)
    local footerStroke = Instance.new("UIStroke", footerBar)
    footerStroke.Color = Color3.fromRGB(42, 52, 68)
    footerStroke.Thickness = 1

    local activityLbl = Instance.new("TextLabel")
    activityLbl.Size = UDim2.new(0.55, 0, 1, 0)
    activityLbl.Position = UDim2.new(0, 8, 0, 0)
    activityLbl.BackgroundTransparency = 1
    activityLbl.Font = Enum.Font.GothamSemibold
    activityLbl.TextSize = 10
    activityLbl.TextColor3 = COL_EMERALD
    activityLbl.TextXAlignment = Enum.TextXAlignment.Left
    activityLbl.Text = "● Ready"
    activityLbl.Parent = footerBar
    ActivityLabelRef = activityLbl

    local targetLbl = Instance.new("TextLabel")
    targetLbl.Size = UDim2.new(0.42, -8, 1, 0)
    targetLbl.Position = UDim2.new(0.58, 0, 0, 0)
    targetLbl.BackgroundTransparency = 1
    targetLbl.Font = Enum.Font.GothamSemibold
    targetLbl.TextSize = 10
    targetLbl.TextColor3 = COL_CYAN
    targetLbl.TextXAlignment = Enum.TextXAlignment.Right
    targetLbl.Text = "Lock: None"
    targetLbl.Parent = footerBar
    TargetLabelRef = targetLbl

    local pages, tabButtons = {}, {}

    local function CreateTab(labelText)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = COL_CARD
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 11
        btn.TextColor3 = COL_TEXT_DIM
        btn.Text = labelText
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", btn)
        stroke.Thickness = 1.2
        stroke.Color = COL_VIOLET
        stroke.Transparency = 0.45

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = COL_CYAN
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = contentArea

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages) do p.Visible = false end
            for _, item in pairs(tabButtons) do
                item.btn.TextColor3 = COL_TEXT_DIM
                item.stroke.Color = COL_VIOLET
                item.stroke.Thickness = 1.2
                item.stroke.Transparency = 0.45
            end
            page.Visible = true
            btn.TextColor3 = COL_CYAN
            stroke.Color = COL_CYAN
            stroke.Thickness = 1.8
            stroke.Transparency = 0
        end)

        table.insert(pages, page)
        table.insert(tabButtons, { btn = btn, stroke = stroke })
        return page
    end

    local function AddPillToggle(parent, labelText, tbl, key)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 32)
        row.BackgroundColor3 = COL_CARD
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Thickness = 1

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 7, 0, 7)
        dot.Position = UDim2.new(0, 10, 0.5, -3)
        dot.Parent = row
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -86, 1, 0)
        lbl.Position = UDim2.new(0, 24, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 11
        lbl.TextColor3 = COL_TEXT_MAIN
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = labelText
        lbl.Parent = row

        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, 50, 0, 22)
        pill.Position = UDim2.new(1, -58, 0.5, -11)
        pill.Font = Enum.Font.GothamBold
        pill.TextSize = 10
        pill.TextColor3 = Color3.new(1, 1, 1)
        pill.Parent = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local function Refresh()
            local state = tbl[key]
            pill.Text = state and "ON" or "OFF"
            pill.BackgroundColor3 = state and COL_EMERALD or Color3.fromRGB(55, 62, 78)
            dot.BackgroundColor3 = state and COL_EMERALD or Color3.fromRGB(90, 98, 115)
            rowStroke.Color = state and Color3.fromRGB(28, 95, 78) or Color3.fromRGB(40, 46, 60)
        end

        Refresh()
        pill.MouseButton1Click:Connect(function()
            tbl[key] = not tbl[key]
            Refresh()
        end)
    end

    local function AddDropdownCycle(parent, labelText, tbl, key, options)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 32)
        row.BackgroundColor3 = COL_CARD
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", row)
        s.Color = Color3.fromRGB(42, 50, 66)
        s.Thickness = 1

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.45, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = COL_TEXT_DIM
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = labelText
        lbl.Parent = row

        local valBtn = Instance.new("TextButton")
        valBtn.Size = UDim2.new(0.50, -8, 0, 22)
        valBtn.Position = UDim2.new(0.50, 0, 0.5, -11)
        valBtn.BackgroundColor3 = COL_INPUT
        valBtn.Font = Enum.Font.GothamSemibold
        valBtn.TextSize = 10
        valBtn.TextColor3 = COL_CYAN
        valBtn.Parent = row
        Instance.new("UICorner", valBtn).CornerRadius = UDim.new(0, 6)

        local function Refresh()
            valBtn.Text = tostring(tbl[key]) .. "  ▾"
        end

        Refresh()
        valBtn.MouseButton1Click:Connect(function()
            local idx = 1
            for i, opt in ipairs(options) do
                if opt == tbl[key] then idx = i break end
            end
            tbl[key] = options[(idx % #options) + 1]
            Refresh()
        end)
    end

    local function AddNumberInput(parent, labelText, tbl, key, minVal, maxVal)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -4, 0, 32)
        row.BackgroundColor3 = COL_CARD
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", row)
        s.Color = Color3.fromRGB(42, 50, 66)
        s.Thickness = 1

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.45, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextColor3 = COL_TEXT_DIM
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = labelText
        lbl.Parent = row

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.50, -8, 0, 22)
        box.Position = UDim2.new(0.50, 0, 0.5, -11)
        box.BackgroundColor3 = COL_INPUT
        box.Font = Enum.Font.GothamSemibold
        box.TextSize = 10
        box.TextColor3 = COL_TEXT_MAIN
        box.ClearTextOnFocus = false
        box.Text = tostring(tbl[key])
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

        box.FocusLost:Connect(function()
            local num = tonumber(box.Text)
            if num then
                tbl[key] = math.clamp(num, minVal, maxVal)
            end
            box.Text = tostring(tbl[key])
        end)
    end

    local tabSilent = CreateTab("Silent Aim")
    AddPillToggle(tabSilent, "Enable Silent Aim", Config.SilentAim, "Enabled")
    AddDropdownCycle(tabSilent, "Target Hitbox:", Config.SilentAim, "TargetPart", {"Head", "UpperTorso", "HumanoidRootPart"})
    AddNumberInput(tabSilent, "Hit Chance (%):", Config.SilentAim, "HitChance", 1, 100)
    AddNumberInput(tabSilent, "FOV Radius (px):", Config.SilentAim, "FOV", 20, 800)
    AddNumberInput(tabSilent, "Prediction:", Config.SilentAim, "Prediction", 0, 0.5)
    AddPillToggle(tabSilent, "Show FOV Circle", Config.SilentAim, "ShowFOV")
    AddPillToggle(tabSilent, "Wall Check", Config.SilentAim, "WallCheck")
    AddPillToggle(tabSilent, "Team Check", Config.SilentAim, "TeamCheck")

    local tabAim = CreateTab("Aimbot / Assist")
    AddPillToggle(tabAim, "Enable Aimbot", Config.Aimbot, "Enabled")
    AddPillToggle(tabAim, "Mobile Aim Assist", Config.Aimbot, "AimAssistMode")
    AddDropdownCycle(tabAim, "Target Hitbox:", Config.Aimbot, "TargetPart", {"Head", "UpperTorso", "HumanoidRootPart"})
    AddNumberInput(tabAim, "Smoothness:", Config.Aimbot, "Smoothness", 0.01, 1)
    AddNumberInput(tabAim, "Assist Pull:", Config.Aimbot, "AssistStrength", 0.01, 1)
    AddNumberInput(tabAim, "FOV Radius (px):", Config.Aimbot, "FOV", 20, 800)
    AddPillToggle(tabAim, "Wall Check", Config.Aimbot, "WallCheck")

    local tabRage = CreateTab("Ragebot")
    AddPillToggle(tabRage, "Enable 360° Ragebot", Config.Ragebot, "Enabled")
    AddPillToggle(tabRage, "Auto-Fire (Touch/PC)", Config.Ragebot, "AutoFire")
    AddDropdownCycle(tabRage, "Target Hitbox:", Config.Ragebot, "TargetPart", {"Head", "UpperTorso", "HumanoidRootPart"})
    AddNumberInput(tabRage, "Fire Delay (sec):", Config.Ragebot, "FireDelay", 0.01, 2)
    AddPillToggle(tabRage, "Wall Check", Config.Ragebot, "WallCheck")

    local tabVis = CreateTab("Visuals / Skins")
    AddPillToggle(tabVis, "2D Box ESP", Config.Visuals, "BoxESP")
    AddPillToggle(tabVis, "Name & HP Tags", Config.Visuals, "NameESP")
    AddPillToggle(tabVis, "Health Bars", Config.Visuals, "HealthBar")
    AddPillToggle(tabVis, "Viewmodel Skin", Config.SkinChanger, "Enabled")
    AddDropdownCycle(tabVis, "Skin Material:", Config.SkinChanger, "Material", {"ForceField", "Neon", "Glass", "Foil"})
    AddNumberInput(tabVis, "Reflectance:", Config.SkinChanger, "Reflectance", 0, 1)

    pages[1].Visible = true
    tabButtons[1].btn.TextColor3 = COL_CYAN
    tabButtons[1].stroke.Color = COL_CYAN
    tabButtons[1].stroke.Thickness = 1.8
    tabButtons[1].stroke.Transparency = 0
end

CreateMobileRivalsUI()

local function GetAimOrigin2D()
    if IsMobile then
        local vp = Camera.ViewportSize
        return Vector2.new(vp.X / 2, vp.Y / 2)
    end
    return UserInputService:GetMouseLocation()
end

-- SAFE DRAWING INITIALIZATION
local FOVCircle = nil
if HasDrawing then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 64
        FOVCircle.Radius = Config.SilentAim.FOV
        FOVCircle.Filled = false
        FOVCircle.Visible = Config.SilentAim.ShowFOV
        FOVCircle.Color = Config.Visuals.Color
        FOVCircle.Transparency = 0.85
    end)
end

local ESPCache = {}
local function CreateESP(player)
    if not HasDrawing or player == LocalPlayer or ESPCache[player] then return end
    pcall(function()
        local box = Drawing.new("Square")
        box.Thickness = 1.5
        box.Filled = false
        box.Color = Config.Visuals.Color
        box.Visible = false

        local name = Drawing.new("Text")
        name.Size = 13
        name.Center = true
        name.Outline = true
        name.Color = Color3.fromRGB(240, 244, 250)
        name.Visible = false

        local hpBar = Drawing.new("Line")
        hpBar.Thickness = 2
        hpBar.Color = Color3.fromRGB(16, 185, 129)
        hpBar.Visible = false

        ESPCache[player] = { Box = box, Name = name, HpBar = hpBar }
    end)
end

local function RemoveESP(player)
    if ESPCache[player] then
        for _, d in pairs(ESPCache[player]) do pcall(function() d:Remove() end) end
        ESPCache[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

local function IsSameTeam(player)
    if not Config.SilentAim.TeamCheck and not Config.Aimbot.TeamCheck then return false end
    return LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team
end

local function IsVisible(part, char)
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.IgnoreWater = true

    local hit = Workspace:Raycast(origin, dir, params)
    return not hit or (hit.Instance and hit.Instance:IsDescendantOf(char))
end

local function GetTarget(useFOV, fovLimit, partName, wallCheck)
    local bestPart, bestPlayer = nil, nil
    local bestScore = useFOV and fovLimit or math.huge
    local aimOrigin = GetAimOrigin2D()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or IsSameTeam(player) then continue end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local part = char and (char:FindFirstChild(partName) or char:FindFirstChild("HumanoidRootPart"))

        if hum and hum.Health > 0 and part then
            if wallCheck and not IsVisible(part, char) then continue end

            if useFOV then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - aimOrigin).Magnitude
                    if dist < bestScore then
                        bestScore = dist
                        bestPart = part
                        bestPlayer = player
                    end
                end
            else
                local worldDist = myRoot and (part.Position - myRoot.Position).Magnitude or 0
                if worldDist < bestScore then
                    bestScore = worldDist
                    bestPart = part
                    bestPlayer = player
                end
            end
        end
    end
    return bestPart, bestPlayer
end

local function TriggerFire()
    if IsMobile and firesignal then
        for _, obj in ipairs(PlayerGui:GetDescendants()) do
            if obj:IsA("GuiButton") and obj.Visible then
                local n = obj.Name:lower()
                if n:find("fire") or n:find("shoot") or n:find("attack") then
                    firesignal(obj.MouseButton1Down)
                    task.defer(function() firesignal(obj.MouseButton1Up) end)
                    return
                end
            end
        end
    end
    if mouse1click then mouse1click() end
end

-- SAFE SILENT AIM HOOK
local CurrentSilentTarget = nil
if HasHooks then
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if not checkcaller() and Config.SilentAim.Enabled and CurrentSilentTarget then
                if self == Workspace and method == "Raycast" then
                    if math.random(1, 100) <= Config.SilentAim.HitChance then
                        local origin, dir = args[1], args[2]
                        if typeof(origin) == "Vector3" and typeof(dir) == "Vector3" then
                            local predicted = CurrentSilentTarget.Position + (CurrentSilentTarget.AssemblyLinearVelocity * Config.SilentAim.Prediction)
                            args[2] = (predicted - origin).Unit * dir.Magnitude
                            return oldNamecall(self, unpack(args))
                        end
                    end
                end
            end

            return oldNamecall(self, ...)
        end))
    end)
end

local function ApplyViewmodelSkin()
    if not Config.SkinChanger.Enabled then return end
    local matEnum = Enum.Material[Config.SkinChanger.Material] or Enum.Material.ForceField
    for _, container in ipairs({Camera, LocalPlayer.Character}) do
        if not container then continue end
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                obj.Material = matEnum
                obj.Color = (obj.Name:lower():find("mag") or obj.Name:lower():find("scope"))
                    and Config.SkinChanger.SecondaryColor
                    or Config.SkinChanger.PrimaryColor
                obj.Reflectance = Config.SkinChanger.Reflectance
            end
        end
    end
end

local lastShot = 0
RunService.RenderStepped:Connect(function()
    local aimOrigin = GetAimOrigin2D()
    if FOVCircle then
        FOVCircle.Position = aimOrigin
        FOVCircle.Radius = Config.SilentAim.Enabled and Config.SilentAim.FOV or Config.Aimbot.FOV
        FOVCircle.Visible = Config.SilentAim.ShowFOV and Config.SilentAim.Enabled
    end

    local lockedPlayer = nil

    if Config.SilentAim.Enabled then
        local part, plr = GetTarget(true, Config.SilentAim.FOV, Config.SilentAim.TargetPart, Config.SilentAim.WallCheck)
        CurrentSilentTarget = part
        lockedPlayer = plr
    else
        CurrentSilentTarget = nil
    end

    if Config.Aimbot.Enabled then
        local keyHeld = not IsMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        local target, plr = GetTarget(true, Config.Aimbot.FOV, Config.Aimbot.TargetPart, Config.Aimbot.WallCheck)
        if target then
            lockedPlayer = lockedPlayer or plr
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            if keyHeld then
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.Smoothness)
            elseif Config.Aimbot.AimAssistMode then
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.AssistStrength)
            end
        end
    end

    if Config.Ragebot.Enabled then
        local ragePart, ragePlr = GetTarget(false, math.huge, Config.Ragebot.TargetPart, Config.Ragebot.WallCheck)
        if ragePart then
            CurrentSilentTarget = ragePart
            lockedPlayer = ragePlr
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, ragePart.Position)
            if Config.Ragebot.AutoFire and (os.clock() - lastShot) >= Config.Ragebot.FireDelay then
                lastShot = os.clock()
                TriggerFire()
            end
        end
    end

    if ActivityLabelRef then
        local modeText = Config.Ragebot.Enabled and "Ragebot 360°"
            or (Config.SilentAim.Enabled and HasHooks and "Silent Aim"
            or (Config.Aimbot.Enabled and "Aim Assist" or "Standby"))
        ActivityLabelRef.Text = "● Mode: " .. modeText
    end
    if TargetLabelRef then
        TargetLabelRef.Text = lockedPlayer and ("Lock: " .. lockedPlayer.Name) or "Lock: None"
    end

    ApplyViewmodelSkin()

    for player, esp in pairs(ESPCache) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and hum.Health > 0 and root and not IsSameTeam(player) then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local head = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
                local leg = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.0, 0))
                local h = math.abs(head.Y - leg.Y)
                local w = h * 0.58
                local tl = Vector2.new(pos.X - w / 2, head.Y)

                esp.Box.Size = Vector2.new(w, h)
                esp.Box.Position = tl
                esp.Box.Visible = Config.Visuals.BoxESP

                esp.Name.Text = string.format("%s [%d]", player.Name, math.floor(hum.Health))
                esp.Name.Position = Vector2.new(pos.X, head.Y - 15)
                esp.Name.Visible = Config.Visuals.NameESP

                if Config.Visuals.HealthBar then
                    local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    esp.HpBar.From = Vector2.new(tl.X - 4, tl.Y + h)
                    esp.HpBar.To = Vector2.new(tl.X - 4, tl.Y + h - (h * ratio))
                    esp.HpBar.Visible = true
                else
                    esp.HpBar.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.HpBar.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HpBar.Visible = false
        end
    end
end)
