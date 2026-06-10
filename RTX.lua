-- ULTRA RTX SYSTEM: REFLECTIONS & TOGGLE EDITION
-- K: Быстрое переключение | L: Меню настроек

local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isRTXEnabled = false
local currentMode = "Ultra"
local currentTheme = "Glass" 
local reflectionsEnabled = false -- Состояние отражений

-- ==========================================
-- НАСТРОЙКИ ПРЕСЕТОВ RTX
-- ==========================================
local presets = {
	["Classic"] = {
		Brightness = 2, Ambient = Color3.fromRGB(100, 100, 100), OutdoorAmbient = Color3.fromRGB(50, 50, 50),
		ExposureCompensation = 0, Bloom = {Intensity = 0, Size = 0}, ColorCorrection = {Contrast = 0, Saturation = 0},
		SunRays = {Intensity = 0}, Atmosphere = {Density = 0}, DepthOfField = {FarIntensity = 0}
	},
	["Ultra"] = {
		Brightness = 2.5, Ambient = Color3.fromRGB(30, 30, 40), OutdoorAmbient = Color3.fromRGB(70, 70, 80),
		ExposureCompensation = 0.5, Bloom = {Intensity = 0.4, Size = 20}, ColorCorrection = {Contrast = 0.3, Saturation = 0.1},
		SunRays = {Intensity = 0.15}, Atmosphere = {Density = 0.3}, DepthOfField = {FarIntensity = 0.1}
	},
	["Hyper"] = {
		Brightness = 3, Ambient = Color3.fromRGB(20, 20, 30), OutdoorAmbient = Color3.fromRGB(60, 60, 70),
		ExposureCompensation = 0.8, Bloom = {Intensity = 0.8, Size = 30}, ColorCorrection = {Contrast = 0.5, Saturation = 0.2},
		SunRays = {Intensity = 0.3}, Atmosphere = {Density = 0.5}, DepthOfField = {FarIntensity = 0.2}
	}
}

local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
local sunRays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect", Lighting)
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
local dof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect") or Instance.new("DepthOfFieldEffect", Lighting)

-- Функция управления отражениями
local function setGlobalReflections(enabled)
	local targetValue = enabled and 1 or 0
	local info = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	
	-- EnvironmentSpecularScale отвечает за зеркальность поверхностей
	-- EnvironmentDiffuseScale отвечает за освещенность от окружения
	TweenService:Create(Lighting, info, {
		EnvironmentSpecularScale = targetValue,
		EnvironmentDiffuseScale = targetValue
	}):Play()
end

local function applyRTX(modeName)
	local settings = presets[modeName]
	local info = TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	TweenService:Create(Lighting, info, {Brightness = settings.Brightness, Ambient = settings.Ambient, OutdoorAmbient = settings.OutdoorAmbient, ExposureCompensation = settings.ExposureCompensation}):Play()
	TweenService:Create(bloom, info, settings.Bloom):Play()
	TweenService:Create(colorCorrection, info, settings.ColorCorrection):Play()
	TweenService:Create(sunRays, info, settings.SunRays):Play()
	TweenService:Create(atmosphere, info, settings.Atmosphere):Play()
	TweenService:Create(dof, info, settings.DepthOfField):Play()
end

-- ==========================================
-- СОЗДАНИЕ GUI
-- ==========================================
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "RTX_ReflectionMenu"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 480) -- Увеличили высоту для тумблера
mainFrame.Position = UDim2.new(0.5, 0, 0.6, 0) 
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BackgroundTransparency = 1 
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 30)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Transparency = 1

local title = Instance.new("TextLabel", mainFrame)
title.Text = "RTX Settings"
title.Size = UDim2.new(1, 0, 0, 60)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, 0, 1, -180)
container.Position = UDim2.new(0, 0, 0, 70)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 15)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createAnimatedButton(name, color, parent)
	local btn = Instance.new("TextButton", parent)
	btn.Text = name
	btn.Size = UDim2.new(0, 260, 0, 55)
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.6
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 18
	btn.BorderSizePixel = 0
	local btnCorner = Instance.new("UICorner", btn)
	btnCorner.CornerRadius = UDim.new(0, 15)
	local btnStroke = Instance.new("UIStroke", btn)
	btnStroke.Thickness = 1.5
	btnStroke.Color = Color3.fromRGB(255, 255, 255)
	btnStroke.Transparency = 0.5
	
	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 270, 0, 60)}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 260, 0, 55)}):Play() end)
	btn.MouseButton1Down:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 250, 0, 50)}):Play() end)
	btn.MouseButton1Up:Connect(function() TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 270, 0, 60)}):Play() end)
	return btn, btnStroke
end

local buttons = {}
local b1, s1 = createAnimatedButton("Classic", Color3.fromRGB(80, 80, 80), container)
local b2, s2 = createAnimatedButton("Ultra", Color3.fromRGB(0, 122, 255), container)
local b3, s3 = createAnimatedButton("Hyper", Color3.fromRGB(175, 82, 222), container)
buttons["Classic"] = {btn = b1, stroke = s1}
buttons["Ultra"] = {btn = b2, stroke = s2}
buttons["Hyper"] = {btn = b3, stroke = s3}

b1.MouseButton1Click:Connect(function() currentMode = "Classic"; isRTXEnabled = false; applyRTX("Classic") end)
b2.MouseButton1Click:Connect(function() currentMode = "Ultra"; isRTXEnabled = true; applyRTX("Ultra") end)
b3.MouseButton1Click:Connect(function() currentMode = "Hyper"; isRTXEnabled = true; applyRTX("Hyper") end)

-- ==========================================
-- СОЗДАНИЕ ТУМБЛЕРА ОТРАЖЕНИЙ (iOS Style)
-- ==========================================
local toggleFrame = Instance.new("Frame", mainFrame)
toggleFrame.Size = UDim2.new(0, 260, 0, 60)
toggleFrame.Position = UDim2.new(0.5, -130, 1, -140)
toggleFrame.BackgroundTransparency = 1

local toggleLabel = Instance.new("TextLabel", toggleFrame)
toggleLabel.Text = "Global Reflections"
toggleLabel.Size = UDim2.new(0, 140, 1, 0)
toggleLabel.Position = UDim2.new(0, 0, 0, 0)
toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel.Font = Enum.Font.GothamMedium
toggleLabel.TextSize = 16
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.BackgroundTransparency = 1

local switch = Instance.new("TextButton", toggleFrame)
switch.Size = UDim2.new(0, 50, 0, 28)
switch.Position = UDim2.new(1, -55, 0.5, -14)
switch.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
switch.Text = ""
switch.BorderSizePixel = 0

local switchCorner = Instance.new("UICorner", switch)
switchCorner.CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame", switch)
knob.Size = UDim2.new(0, 24, 0, 24)
knob.Position = UDim2.new(0, 2, 0, 2)
knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
knob.BorderSizePixel = 0

local knobCorner = Instance.new("UICorner", knob)
knobCorner.CornerRadius = UDim.new(1, 0)

-- Логика переключения тумблера
switch.MouseButton1Click:Connect(function()
	reflectionsEnabled = not reflectionsEnabled
	
	local knobPos = reflectionsEnabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
	local switchColor = reflectionsEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 200, 200)
	
	TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = knobPos}):Play()
	TweenService:Create(switch, TweenInfo.new(0.3), {BackgroundColor3 = switchColor}):Play()
	
	setGlobalReflections(reflectionsEnabled)
end)

-- ==========================================
-- ТЕМА, ПЕРЕМЕЩЕНИЕ И ОТКРЫТИЕ (MacOS Style)
-- ==========================================
local themeToggle = Instance.new("TextButton", mainFrame)
themeToggle.Size = UDim2.new(0, 60, 0, 60)
themeToggle.Position = UDim2.new(0.5, -30, 1, -80)
themeToggle.Text = "🌙"
themeToggle.TextSize = 30
themeToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
themeToggle.BackgroundTransparency = 0.5
themeToggle.BorderSizePixel = 0
local toggleCorner = Instance.new("UICorner", themeToggle)
toggleCorner.CornerRadius = UDim.new(1, 0)
local toggleStroke = Instance.new("UIStroke", themeToggle)
toggleStroke.Thickness = 2
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Transparency = 0.5

local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = UDim2.new(0, 0, 0, 0)
local targetPos = UDim2.new(0.5, 0, 0.5, 0)
local smoothSpeed = 0.15 

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

RunService.RenderStepped:Connect(function()
	if dragging or (mainFrame.Position ~= targetPos) then
		local currentX = mainFrame.Position.X.Offset
		local currentY = mainFrame.Position.Y.Offset
		local lerpX = currentX + (targetPos.X.Offset - currentX) * smoothSpeed
		local lerpY = currentY + (targetPos.Y.Offset - currentY) * smoothSpeed
		mainFrame.Position = UDim2.new(targetPos.X.Scale, lerpX, targetPos.Y.Scale, lerpY)
	end
end)

local function updateThemeVisuals()
	local info = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	if currentTheme == "Glass" then
		TweenService:Create(mainFrame, info, {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.85}):Play()
		TweenService:Create(mainStroke, info, {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.6}):Play()
		TweenService:Create(themeToggle, info, {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.5}):Play()
		TweenService:Create(toggleStroke, info, {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.5}):Play()
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		themeToggle.Text = "🌙"
		for _, data in pairs(buttons) do
			TweenService:Create(data.btn, info, {BackgroundTransparency = 0.6}):Play()
			TweenService:Create(data.stroke, info, {Color = Color3.fromRGB(255, 255, 255), Transparency = 0.5}):Play()
		end
	else
		TweenService:Create(mainFrame, info, {BackgroundColor3 = Color3.fromRGB(20, 20, 20), BackgroundTransparency = 0.2}):Play()
		TweenService:Create(mainStroke, info, {Color = Color3.fromRGB(0, 0, 0), Transparency = 0}):Play()
		TweenService:Create(themeToggle, info, {BackgroundColor3 = Color3.fromRGB(40, 40, 40), BackgroundTransparency = 0.3}):Play()
		TweenService:Create(toggleStroke, info, {Color = Color3.fromRGB(0, 0, 0), Transparency = 0.5}):Play()
		title.TextColor3 = Color3.fromRGB(200, 200, 200)
		toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		themeToggle.Text = "☀️"
		for _, data in pairs(buttons) do
			TweenService:Create(data.btn, info, {BackgroundTransparency = 0.3}):Play()
			TweenService:Create(data.stroke, info, {Color = Color3.fromRGB(0, 0, 0), Transparency = 0.8}):Play()
		end
	end
end

themeToggle.MouseButton1Click:Connect(function()
	local springInfo = TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	TweenService:Create(themeToggle, springInfo, {Size = UDim2.new(0, 70, 0, 70)}):Play()
	task.wait(0.1)
	TweenService:Create(themeToggle, springInfo, {Size = UDim2.new(0, 60, 0, 60)}):Play()
	currentTheme = (currentTheme == "Glass") and "Dark" or "Glass"
	updateThemeVisuals()
end)

local menuOpen = false
local function toggleMenu()
	menuOpen = not menuOpen
	if menuOpen then
		mainFrame.Visible = true
		mainFrame.Position = UDim2.new(0.5, 0, 0.6, 0)
		targetPos = UDim2.new(0.5, 0, 0.5, 0)
		mainFrame.BackgroundTransparency = 1
		mainStroke.Transparency = 1
		local openInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(mainFrame, openInfo, {Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = (currentTheme == "Glass" and 0.85 or 0.2)}):Play()
		TweenService:Create(mainStroke, openInfo, {Transparency = (currentTheme == "Glass" and 0.6 or 0)}):Play()
	else
		local closeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		TweenService:Create(mainFrame, closeInfo, {Position = UDim2.new(0.5, 0, 0.6, 0), BackgroundTransparency = 1}):Play()
		TweenService:Create(mainStroke, closeInfo, {Transparency = 1}):Play()
		task.wait(0.4)
		mainFrame.Visible = false
	end
end

updateThemeVisuals()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K then
		isRTXEnabled = not isRTXEnabled
		applyRTX(isRTXEnabled and currentMode or "Classic")
	end
	if input.KeyCode == Enum.KeyCode.L then
		toggleMenu()
	end
end)
