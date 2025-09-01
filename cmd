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
