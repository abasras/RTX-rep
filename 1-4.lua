-- [[ XENO CUSTOM GUI - DEALERSHIP LITE ]] --

local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")

-- Состояния функций
local States = {
    AutoCollect = false,
    AutoBuy = false,
    AutoFire = false
}

-- === СОЗДАНИЕ GUI ===
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- Настройки основного окна
ScreenGui.Name = "XenoDealershipGui"
ScreenGui.Parent = game:GetService("CoreGui") -- Чтобы GUI не пропало после смерти
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- Возможность перетаскивать окно

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "XENO LITE MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 5, 0, 35)
Container.Size = UDim2.new(0, 210, 0, 260)
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 4

UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Функция для создания кнопок-переключателей (Toggles)
local function CreateToggle(text, stateVar, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 35)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleBtn.Text = text .. ": OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.Font = Enum.Font.SourceSans
    ToggleBtn.TextSize = 16
    ToggleBtn.Parent = Container

    local active = false
    ToggleBtn.MouseButton1Click:Connect(function()
        active = not active
        States[stateVar] = active
        ToggleBtn.Text = text .. (active and ": ON" or ": OFF")
        ToggleBtn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(active)
    end)
end

-- Функция для обычных кнопок (Buttons)
local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 16
    Btn.Parent = Container

    Btn.MouseButton1Click:Connect(callback)
end

-- === ЛОГИКА ФУНКЦИЙ ===

-- 1. Анти-АФК (Работает в фоне)
Player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- 2. Авто-сбор
CreateToggle("Auto Collect", "AutoCollect", function(state)
    while States.AutoCollect do
        task.wait(0.1)
        pcall(function()
            for _, v in pairs(workspace.Collectibles:GetDescendants()) do
                if v:IsA("Model") and v.PrimaryPart then
                    Player.Character.HumanoidRootPart.CFrame = v.PrimaryPart.CFrame
                    task.wait(0.1)
                end
            end
        end)
    end
end)

-- 3. Авто-покупка
CreateToggle("Auto Buy Plot", "AutoBuy", function(state)
    while States.AutoBuy do
        task.wait(0.5)
        pcall(function()
            for _, v in pairs(workspace.Tycoons:GetDescendants()) do
                if v.Name == "Owner" and v.Value == Player.Name then
                    local plot = v.Parent
                    for _, item in pairs(plot.Dealership.Purchases:GetChildren()) do
                        if item:FindFirstChild("TycoonButton") and item.TycoonButton.Button.Transparency == 0 then
                            RS.Remotes.Build:FireServer("BuyItem", item.Name)
                        end
                    end
                end
            end
        end)
    end
end)

-- 4. Авто-пожарный
CreateToggle("Auto Fireman", "AutoFire", function(state)
    while States.AutoFire do
        task.wait(0.1)
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "FirePart" then
                    Player.Character.HumanoidRootPart.CFrame = v.CFrame
                    RS.Remotes.TaskController.ActionGameDataReplication:FireServer("TryInteractWithItem", {
                        ["GameName"] = "FirefighterGame",
                        ["Action"] = "UpdatePlayerToolState",
                        ["Data"] = {["IsActive"] = true, ["ToolName"] = "Extinguisher"}
                    })
                    task.wait(0.5)
                end
            end
        end)
    end
end)

-- 5. Телепорт на гонки
CreateButton("TP to Race", function()
    pcall(function()
        for _, v in pairs(workspace.Races:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChildOfClass("UnionOperation") then
                Player.Character.HumanoidRootPart.CFrame = v:FindFirstChildOfClass("UnionOperation").CFrame
                break
            end
        end
    end)
end)

-- Кнопка закрытия меню (Скрыть/Показать на клавишу K)
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Xeno GUI Loaded! Press 'K' to hide/show menu")
