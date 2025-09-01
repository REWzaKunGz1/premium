-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DevConsole"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 300)
frame.Position = UDim2.new(0.5, -250, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0
title.Text = "Developer Console"
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- Scrollable output area
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -50)
scrollFrame.Position = UDim2.new(0, 10, 0, 40)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 10
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0,2)
uiListLayout.Parent = scrollFrame

-- Copy button
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 100, 0, 30)
copyButton.Position = UDim2.new(1, -110, 1, -40)
copyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
copyButton.TextColor3 = Color3.new(1,1,1)
copyButton.Text = "Copy"
copyButton.Parent = frame

copyButton.MouseButton1Click:Connect(function()
    local allText = ""
    for _,v in pairs(scrollFrame:GetChildren()) do
        if v:IsA("TextLabel") then
            allText = allText .. v.Text .. "\n"
        end
    end
    local success, err = pcall(function()
        setclipboard(allText)
    end)
    if not success then
        oldPrint("Copy failed: ", err)
    end
end)

-- Drag functionality
local dragging = false
local dragInput, mousePos, framePos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- Function to add message
local function addMessage(msg, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.new(1,1,1)
    label.Text = msg
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextScaled = false
    label.Parent = scrollFrame

    -- Update canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)

    -- Auto-scroll to bottom
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

-- Override print for [INFO]
local oldPrint = print
print = function(...)
    local msg = ""
    for i,v in ipairs({...}) do
        msg = msg .. tostring(v) .. "\t"
    end
    addMessage("[INFO] " .. msg, Color3.new(1,1,1))
    oldPrint(...)
end

-- Functions for warning and error
function warning(...)
    local msg = ""
    for i,v in ipairs({...}) do
        msg = msg .. tostring(v) .. "\t"
    end
    addMessage("[WARNING] " .. msg, Color3.fromRGB(255, 255, 100))
    oldPrint("[WARNING]", ...)
end

function errorMsg(...)
    local msg = ""
    for i,v in ipairs({...}) do
        msg = msg .. tostring(v) .. "\t"
    end
    addMessage("[ERROR] " .. msg, Color3.fromRGB(255, 80, 80))
    oldPrint("[ERROR]", ...)
end

-- Capture runtime errors
game:GetService("ScriptContext").Error:Connect(function(err)
    addMessage("[ERROR] " .. tostring(err), Color3.fromRGB(255, 80, 80))
end)

-- Example usage
print("Developer Console Loaded!")         -- INFO
print("This is normal print (INFO)")      -- INFO
warning("This is a warning")              -- WARNING
errorMsg("This is an error")              -- ERROR
