local SignalManager = {}
SignalManager.__index = SignalManager

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local notif = loadstring(game:HttpGet("https://raw.githubusercontent.com/IceMinisterq/Notification-Library/Main/Library.lua"))()

getgenv().connections = getgenv().connections or {}

local function randomString(len)
    len = len or 100
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,.<>/?"
    local res = {}
    for i = 1, len do
        local randIndex = math.random(1, #charset)
        res[#res + 1] = charset:sub(randIndex, randIndex)
    end
    return table.concat(res)
end

math.randomseed(tick())

local hiddenUI
if get_hidden_gui or gethui then
    hiddenUI = (get_hidden_gui or gethui)()
elseif CoreGui:FindFirstChild("RobloxGui") then
    hiddenUI = CoreGui.RobloxGui
end

local function makeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createSignalEntry(self, uid, info, listFrame)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, 0)
    entry.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    entry.BorderSizePixel = 0
    entry.ClipsDescendants = true
    entry.Parent = listFrame
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 6)
    entryCorner.Parent = entry
    
    local entryPadding = Instance.new("UIPadding")
    entryPadding.PaddingLeft = UDim.new(0, 8)
    entryPadding.PaddingRight = UDim.new(0, 8)
    entryPadding.Parent = entry

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, -8, 0, 16)
    idLabel.Position = UDim2.new(0, 0, 0, 4)
    idLabel.BackgroundTransparency = 1
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 10
    idLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Text = "ID: "..uid
    idLabel.TextTruncate = Enum.TextTruncate.AtEnd
    idLabel.Parent = entry

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -8, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = "Signal: "..info.name
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = entry

    local killBtn = Instance.new("TextButton")
    killBtn.Size = UDim2.new(0.3, -8, 0.4, 0)
    killBtn.Position = UDim2.new(0.7, 0, 0.3, 0)
    killBtn.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
    killBtn.BorderSizePixel = 0
    killBtn.Font = Enum.Font.GothamBold
    killBtn.TextSize = 12
    killBtn.TextColor3 = Color3.new(1, 1, 1)
    killBtn.Text = "KILL"
    killBtn.Parent = entry
    killBtn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = killBtn
    
    killBtn.MouseEnter:Connect(function() 
        TweenService:Create(
            killBtn,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 = Color3.fromRGB(220, 80, 80),
                Size = UDim2.new(0.32, -8, 0.42, 0)
            }
        ):Play()
    end)
    
    killBtn.MouseLeave:Connect(function() 
        TweenService:Create(
            killBtn,
            TweenInfo.new(0.15),
            {
                BackgroundColor3 = Color3.fromRGB(190, 50, 50),
                Size = UDim2.new(0.3, -8, 0.4, 0)
            }
        ):Play()
    end)
    
    killBtn.MouseButton1Click:Connect(function()
        local pressTween = TweenService:Create(
            killBtn,
            TweenInfo.new(0.1),
            {
                BackgroundColor3 = Color3.fromRGB(100, 20, 20),
                Size = UDim2.new(0.28, -8, 0.38, 0)
            }
        )
        pressTween:Play()
        
        local fadeTween = TweenService:Create(
            entry,
            TweenInfo.new(0.2),
            {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0)
            }
        )
        
        pressTween.Completed:Wait()
        
        info.connection:Disconnect()
        getgenv().connections[uid] = nil
        
        fadeTween:Play()
        fadeTween.Completed:Wait()
        
        entry:Destroy()
        notif:SendNotification("Error", "Removed: "..info.name, 3)
    end)
    
    local growTween = TweenService:Create(
        entry,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(1, 0, 0, 60)}
    )
    
    entry.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    local highlightTween = TweenService:Create(
        entry,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(36, 36, 36)}
    )
    
    growTween:Play()
    task.wait(0.1)
    highlightTween:Play()
    
    return entry
end

function SignalManager:InitUI()
    if self._uiCreated then return end
    self._uiCreated = true

    local player = Players.LocalPlayer
    local existingGui = hiddenUI:FindFirstChild("SignalManagerUI")
    
    if existingGui then
        self.gui = existingGui
        self.gui.Enabled = true
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SignalManagerUI"
    gui.ResetOnSpawn = false
    gui.Parent = hiddenUI
    gui.Enabled = false
    self.gui = gui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 350, 0, 500)
    frame.AnchorPoint = Vector2.new(1, 0.5)
    frame.Position = UDim2.new(1, -20, 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    header.BorderSizePixel = 0
    header.Parent = frame
    makeDraggable(frame, header)

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Signal Manager"
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0, 8)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.Text = "×"
    closeBtn.Parent = header
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(
            frame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 500)}
        )
        tween:Play()
        tween.Completed:Wait()
        gui.Enabled = false
    end)

    local search = Instance.new("TextBox")
    search.Name = "SearchBox"
    search.Size = UDim2.new(1, -24, 0, 32)
    search.Position = UDim2.new(0, 12, 0, 48)
    search.PlaceholderText = "Search signals..."
    search.Text = ""
    search.ClearTextOnFocus = false
    search.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    search.TextColor3 = Color3.fromRGB(230, 230, 230)
    search.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    search.BorderSizePixel = 0
    search.Font = Enum.Font.Gotham
    search.TextSize = 14
    search.Parent = frame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = search
    
    local searchPadding = Instance.new("UIPadding")
    searchPadding.PaddingLeft = UDim.new(0, 8)
    searchPadding.PaddingRight = UDim.new(0, 8)
    searchPadding.Parent = search
    
    self.searchBox = search

    local list = Instance.new("ScrollingFrame")
    list.Name = "SignalList"
    list.Size = UDim2.new(1, -24, 1, -96)
    list.Position = UDim2.new(0, 12, 0, 88)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 6
    list.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = frame
    
    local layout = Instance.new("UIListLayout") 
    layout.Padding = UDim.new(0, 8) 
    layout.Parent = list
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    self.listFrame = list
    
    function self:RefreshUI()
        local filter = self.searchBox.Text:lower()
        
        for _, child in ipairs(self.listFrame:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        
        for uid, info in pairs(getgenv().connections) do
            if filter == "" or info.name:lower():find(filter, 1, true) or uid:lower():find(filter, 1, true) then
                createSignalEntry(self, uid, info, self.listFrame)
            end
        end
    end

    self.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:RefreshUI()
    end)
    
    Players.LocalPlayer.Chatted:Connect(function(msg)
        if msg:lower() == "/signals" then
            gui.Enabled = not gui.Enabled
            if gui.Enabled then 
                self:RefreshUI() 
                frame.Size = UDim2.new(0, 0, 0, 500)
                frame.Visible = true
                TweenService:Create(
                    frame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 350, 0, 500)}
                ):Play()
            else
                local tween = TweenService:Create(
                    frame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Size = UDim2.new(0, 0, 0, 500)}
                )
                tween:Play()
                tween.Completed:Wait()
                frame.Visible = false
            end
        end
    end)
end

function SignalManager.AddSignal(conn, name)
    assert(typeof(conn) == "RBXScriptConnection", "Must pass a connection")
    local uid = "Signal_"..randomString()
    getgenv().connections[uid] = { connection = conn, name = name }
    notif:SendNotification("Warning", "Added: "..name, 3)
    SignalManager:InitUI()
    
    if SignalManager.gui and SignalManager.gui.Enabled then
        createSignalEntry(SignalManager, uid, getgenv().connections[uid], SignalManager.listFrame)
    end
    
    return uid
end

function SignalManager.DestroySignal(uid)
    local info = getgenv().connections[uid]
    if info then
        info.connection:Disconnect()
        getgenv().connections[uid] = nil
        notif:SendNotification("Error", "Removed: "..info.name, 3)
        SignalManager:RefreshUI()
    end
end

SignalManager:InitUI()

return SignalManager
