--// NeverLOSE Resizable Themed UI Library
--// Author: YoshiroScripts, based on original NeverLOSE concept

local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ======================== THEME SYSTEM ========================
Library.Themes = {
    Default = {
        main_color = Color3.fromRGB(41, 74, 122),
        sidebar_color = Color3.fromRGB(30, 30, 44),
        accent = Color3.fromRGB(43, 154, 198),
        text = Color3.fromRGB(255,255,255),
        section = Color3.fromRGB(23, 35, 56),
        button = Color3.fromRGB(13, 57, 84),
        border = Color3.fromRGB(15,23,36),
    },
    Dark = {
        main_color = Color3.fromRGB(23, 23, 36),
        sidebar_color = Color3.fromRGB(18, 18, 26),
        accent = Color3.fromRGB(90, 120, 200),
        text = Color3.fromRGB(220,220,220),
        section = Color3.fromRGB(30, 30, 44),
        button = Color3.fromRGB(40, 80, 120),
        border = Color3.fromRGB(40, 50, 70),
    },
    Red = {
        main_color = Color3.fromRGB(80, 25, 25),
        sidebar_color = Color3.fromRGB(60, 10, 10),
        accent = Color3.fromRGB(180, 40, 40),
        text = Color3.fromRGB(255,220,220),
        section = Color3.fromRGB(100, 35, 35),
        button = Color3.fromRGB(120, 40, 40),
        border = Color3.fromRGB(120, 60, 60),
    }
}

Library.CurrentTheme = Library.Themes.Default

function Library:SetTheme(theme)
    if type(theme) == "string" then
        Library.CurrentTheme = Library.Themes[theme] or Library.CurrentTheme
    elseif type(theme) == "table" then
        Library.CurrentTheme = theme
    end
end

local function Notify(tt, tx)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = tt,
        Text = tx,
        Duration = 5
    })
end

-- ======================== DRAG & RESIZE ========================
local function Dragify(frame, parent)
    parent = parent or frame
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

local function MakeResizable(frame, minSize)
    minSize = minSize or Vector2.new(250, 346)
    local resizer = Instance.new("Frame")
    resizer.Parent = frame
    resizer.AnchorPoint = Vector2.new(1, 1)
    resizer.Position = UDim2.new(1, -4, 1, -4)
    resizer.Size = UDim2.new(0, 16, 0, 16)
    resizer.BackgroundColor3 = Library.CurrentTheme.accent
    resizer.BorderSizePixel = 0
    resizer.ZIndex = 999
    resizer.Name = "Resizer"
    local dragging, dragStart, startSize = false, nil, nil
    resizer.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inputObj.Position
            startSize = frame.Size
            inputObj.Changed:Connect(function()
                if inputObj.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inputObj)
        if dragging and inputObj.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inputObj.Position - dragStart
            local newWidth = math.max(startSize.X.Offset + delta.X, minSize.X)
            local newHeight = math.max(startSize.Y.Offset + delta.Y, minSize.Y)
            frame.Size = UDim2.new(startSize.X.Scale, newWidth, startSize.Y.Scale, newHeight)
        end
    end)
end

-- ======================== WINDOW API ========================
function Library:AddWindow(title, opts)
    opts = opts or {}
    title = title or "NEVERLOSE"
    local theme = opts.theme or Library.CurrentTheme
    if type(theme) == "string" then theme = Library.Themes[theme] or Library.CurrentTheme end
    Library.CurrentTheme = theme

    local main_color = opts.main_color or theme.main_color
    local sidebar_color = theme.sidebar_color
    local accent = theme.accent
    local text = theme.text
    local section_color = theme.section
    local button_color = theme.button
    local border_color = theme.border

    local min_size = opts.min_size or Vector2.new(658, 516)
    local can_resize = (opts.can_resize == nil) and true or opts.can_resize

    for i,v in next, game.CoreGui:GetChildren() do
        if v:IsA("ScreenGui") and v.Name == "Neverlose" then
            v:Destroy() 
        end
    end

    local SG = Instance.new("ScreenGui")
    local Body = Instance.new("Frame")
    local bodyCorner = Instance.new("UICorner")
    SG.Parent = game.CoreGui
    SG.Name = "Neverlose"
    Body.Name = "Body"
    Body.Parent = SG
    Body.AnchorPoint = Vector2.new(0.5, 0.5)
    Body.BackgroundColor3 = main_color
    Body.BorderSizePixel = 0
    Body.Position = UDim2.new(0.5, 0, 0.5, 0)
    Body.Size = UDim2.new(0, min_size.X, 0, min_size.Y)
    bodyCorner.CornerRadius = UDim.new(0, 4)
    bodyCorner.Parent = Body

    Dragify(Body, Body)
    if can_resize then
        MakeResizable(Body, min_size)
    end

    -- SideBar
    local SideBar = Instance.new("Frame")
    SideBar.Name = "SideBar"
    SideBar.Parent = Body
    SideBar.BackgroundColor3 = sidebar_color
    SideBar.BorderSizePixel = 0
    SideBar.Size = UDim2.new(0, 187, 1, 0)
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 4)
    sidebarCorner.Parent = SideBar

    local sbLine = Instance.new("Frame")
    sbLine.Name = "sbLine"
    sbLine.Parent = SideBar
    sbLine.BackgroundColor3 = border_color
    sbLine.BorderSizePixel = 0
    sbLine.Position = UDim2.new(0.99490571, 0, 0, 0)
    sbLine.Size = UDim2.new(0, 3, 1, 0)

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Body
    TopBar.BackgroundColor3 = main_color
    TopBar.BackgroundTransparency = 1.000
    TopBar.BorderColor3 = accent
    TopBar.BorderSizePixel = 0
    TopBar.Position = UDim2.new(187/min_size.X, 0, 0, 0)
    TopBar.Size = UDim2.new(1, -187, 0, 49)

    local tbLine = Instance.new("Frame")
    tbLine.Name = "tbLine"
    tbLine.Parent = TopBar
    tbLine.BackgroundColor3 = border_color
    tbLine.BorderSizePixel = 0
    tbLine.Position = UDim2.new(0.0400355868, 0, 1, 0)
    tbLine.Size = UDim2.new(0, min_size.X-187-40, 0, 3)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = SideBar
    Title.BackgroundColor3 = sidebar_color
    Title.BackgroundTransparency = 1.000
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.0614973232, 0, 0.0213178284, 0)
    Title.Size = UDim2.new(0, 162, 0, 26)
    Title.Font = Enum.Font.ArialBold
    Title.Text = title
    Title.TextColor3 = text
    Title.TextSize = 28.000
    Title.TextWrapped = true

    local allPages = Instance.new("Frame")
    allPages.Name = "allPages"
    allPages.Parent = Body
    allPages.BackgroundColor3 = sidebar_color
    allPages.BackgroundTransparency = 1.000
    allPages.BorderSizePixel = 0
    allPages.Position = UDim2.new(187/min_size.X, 0, 49/min_size.Y, 0)
    allPages.Size = UDim2.new(1, -187, 1, -49)

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "tabContainer"
    tabContainer.Parent = SideBar
    tabContainer.BackgroundColor3 = sidebar_color
    tabContainer.BackgroundTransparency = 1.000
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 49/min_size.Y, 0)
    tabContainer.Size = UDim2.new(1, 0, 1, -49)

    local WindowObj = {
        Main = Body,
        Sidebar = SideBar,
        TopBar = TopBar,
        Title = Title,
        Content = allPages,
        TabContainer = tabContainer,
        Notify = Notify,
        ScreenGui = SG,
        Theme = Library.CurrentTheme,
    }

    -- Tabs API
    function WindowObj:AddTab(tabTitle, tabIcon)
        tabTitle = tabTitle or "Tab"
        tabIcon = tabIcon or "rbxassetid://7999345313"
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = tabContainer
        tabButton.BackgroundColor3 = button_color
        tabButton.BorderSizePixel = 0
        tabButton.Size = UDim2.new(0, 165, 0, 30)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Text = "         " .. tabTitle
        tabButton.TextColor3 = text
        tabButton.BackgroundTransparency = 1
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 4)
        tabButtonCorner.Parent = tabButton
        local tabIconObj = Instance.new("ImageLabel")
        tabIconObj.Parent = tabButton
        tabIconObj.BackgroundTransparency = 1.000
        tabIconObj.Position = UDim2.new(0.0408859849, 0, 0.133333355, 0)
        tabIconObj.Size = UDim2.new(0, 21, 0, 21)
        tabIconObj.Image = tabIcon
        tabIconObj.ImageColor3 = accent
        local newPage = Instance.new("ScrollingFrame")
        newPage.Parent = allPages
        newPage.Visible = false
        newPage.BackgroundColor3 = sidebar_color
        newPage.BackgroundTransparency = 1.000
        newPage.BorderSizePixel = 0
        newPage.ClipsDescendants = false
        newPage.Position = UDim2.new(0.021598272, 0, 0.0237068962, 0)
        newPage.Size = UDim2.new(0, allPages.AbsoluteSize.X-20, 0, allPages.AbsoluteSize.Y-20)
        newPage.ScrollBarThickness = 4
        newPage.CanvasSize = UDim2.new(0,0,0,0)
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Parent = newPage
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 12)
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            newPage.CanvasSize = UDim2.new(0,0,0,pageLayout.AbsoluteContentSize.Y) 
        end)
        tabButton.MouseButton1Click:Connect(function()
            for _,v in next, allPages:GetChildren() do
                v.Visible = false
            end
            newPage.Visible = true
            for _,v in next, tabContainer:GetChildren() do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end
            TweenService:Create(tabButton, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                BackgroundTransparency = 0
            }):Play()
        end)
        local TabObj = {}
        TabObj.TabButton = tabButton
        TabObj.TabPage = newPage

        -- Section API
        function TabObj:AddSection(sectionTitle)
            sectionTitle = sectionTitle or "Section"
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Parent = newPage
            sectionFrame.BackgroundColor3 = section_color
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Size = UDim2.new(0, 215, 0, 134)
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Parent = sectionFrame
            sectionLabel.BackgroundTransparency = 1.000
            sectionLabel.Position = UDim2.new(0.012, 0, 0, 0)
            sectionLabel.Size = UDim2.new(0, 213, 0, 25)
            sectionLabel.Font = Enum.Font.GothamSemibold
            sectionLabel.Text = "   " .. sectionTitle
            sectionLabel.TextColor3 = text
            sectionLabel.TextSize = 14.000
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            local sectionFrameCorner = Instance.new("UICorner")
            sectionFrameCorner.CornerRadius = UDim.new(0, 4)
            sectionFrameCorner.Parent = sectionFrame
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Parent = sectionFrame
            sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 2)

            local SectionObj = {}

            -- Button
            function SectionObj:AddButton(opts)
                local TextButton = Instance.new("TextButton")
                TextButton.Parent = sectionFrame
                TextButton.BackgroundColor3 = button_color
                TextButton.BorderSizePixel = 0
                TextButton.Size = UDim2.new(0, 200, 0, 22)
                TextButton.AutoButtonColor = false
                TextButton.Text = opts.text or "Button"
                TextButton.Font = Enum.Font.Gotham
                TextButton.TextColor3 = text
                TextButton.TextSize = 14.000
                TextButton.BackgroundTransparency = 0
                TextButton.MouseButton1Click:Connect(function()
                    if opts.callback then opts.callback() end
                end)
                -- Effects
                TextButton.MouseEnter:Connect(function()
                    TweenService:Create(TextButton, TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0.15
                    }):Play()
                end)
                TextButton.MouseLeave:Connect(function()
                    TweenService:Create(TextButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 0
                    }):Play()
                end)
                TextButton.MouseButton1Click:Connect(function()
                    local oldSize = TextButton.TextSize
                    TweenService:Create(TextButton, TweenInfo.new(0.07, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        TextSize = oldSize - 2
                    }):Play()
                    wait(0.09)
                    TweenService:Create(TextButton, TweenInfo.new(0.11, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
                        TextSize = oldSize
                    }):Play()
                end)
                return TextButton
            end

            -- Toggle
            function SectionObj:AddToggle(opts)
                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Parent = sectionFrame
                toggleLabel.BackgroundTransparency = 1.000
                toggleLabel.Size = UDim2.new(0, 200, 0, 22)
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.Text = " " .. (opts.text or "Toggle")
                toggleLabel.TextColor3 = text
                toggleLabel.TextSize = 14.000
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

                local toggleFrame = Instance.new("TextButton")
                toggleFrame.Parent = toggleLabel
                toggleFrame.BackgroundColor3 = button_color
                toggleFrame.BorderSizePixel = 0
                toggleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                toggleFrame.Position = UDim2.new(0.9, 0, 0.5, 0)
                toggleFrame.Size = UDim2.new(0, 38, 0, 18)
                toggleFrame.AutoButtonColor = false
                toggleFrame.Font = Enum.Font.SourceSans
                toggleFrame.Text = ""
                toggleFrame.TextColor3 = Color3.fromRGB(0, 0, 0)
                toggleFrame.TextSize = 14.000

                local togFrameCorner = Instance.new("UICorner")
                togFrameCorner.CornerRadius = UDim.new(0, 50)
                togFrameCorner.Parent = toggleFrame

                local toggleButton = Instance.new("TextButton")
                toggleButton.Parent = toggleFrame
                toggleButton.BackgroundColor3 = accent
                toggleButton.BorderSizePixel = 0
                toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
                toggleButton.Position = UDim2.new(0.25, 0, 0.5, 0)
                toggleButton.Size = UDim2.new(0, 16, 0, 16)
                toggleButton.AutoButtonColor = false
                toggleButton.Font = Enum.Font.SourceSans
                toggleButton.Text = ""
                toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                toggleButton.TextSize = 14.000
                local togBtnCorner = Instance.new("UICorner")
                togBtnCorner.CornerRadius = UDim.new(0, 50)
                togBtnCorner.Parent = toggleButton

                local State = opts.state or false
                local function PerformToggle()
                    State = not State
                    toggleButton.Position = State and UDim2.new(0.74, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
                    toggleButton.BackgroundColor3 = State and accent or button_color
                    if opts.callback then opts.callback(State) end
                end
                toggleFrame.MouseButton1Click:Connect(PerformToggle)
                toggleButton.MouseButton1Click:Connect(PerformToggle)
                return toggleFrame
            end

            -- Slider
            function SectionObj:AddSlider(opts)
                local min, max = opts.min or 0, opts.max or 100
                local value = opts.value or min
                local Slider = Instance.new("Frame")
                Slider.Parent = sectionFrame
                Slider.BackgroundTransparency = 1.000
                Slider.Size = UDim2.new(0, 200, 0, 22)
                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Parent = Slider
                sliderLabel.BackgroundTransparency = 1.000
                sliderLabel.Position = UDim2.new(0, 0, 0, 0)
                sliderLabel.Size = UDim2.new(0, 77, 0, 22)
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.Text = " " .. (opts.text or "Slider")
                sliderLabel.TextColor3 = text
                sliderLabel.TextSize = 14.000
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                local sliderFrame = Instance.new("TextButton")
                sliderFrame.Parent = sliderLabel
                sliderFrame.BackgroundColor3 = accent
                sliderFrame.BorderSizePixel = 0
                sliderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderFrame.Position = UDim2.new(1.6, 0, 0.5, 0)
                sliderFrame.Size = UDim2.new(0, 72, 0, 2)
                sliderFrame.Text = ""
                sliderFrame.AutoButtonColor = false
                local sliderBall = Instance.new("TextButton")
                sliderBall.Parent = sliderFrame
                sliderBall.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderBall.BackgroundColor3 = button_color
                sliderBall.BorderSizePixel = 0
                sliderBall.Position = UDim2.new(0, 0, 0.5, 0)
                sliderBall.Size = UDim2.new(0, 14, 0, 14)
                sliderBall.AutoButtonColor = false
                sliderBall.Font = Enum.Font.SourceSans
                sliderBall.Text = ""
                sliderBall.TextColor3 = Color3.fromRGB(0, 0, 0)
                sliderBall.TextSize = 14.000
                local sliderBallCorner = Instance.new("UICorner")
                sliderBallCorner.CornerRadius = UDim.new(0, 50)
                sliderBallCorner.Parent = sliderBall
                local sliderTextBox = Instance.new("TextBox")
                sliderTextBox.Parent = sliderLabel
                sliderTextBox.BackgroundColor3 = section_color
                sliderTextBox.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderTextBox.Position = UDim2.new(2.4, 0, 0.5, 0)
                sliderTextBox.Size = UDim2.new(0, 31, 0, 15)
                sliderTextBox.Font = Enum.Font.Gotham
                sliderTextBox.Text = tostring(value)
                sliderTextBox.TextColor3 = text
                sliderTextBox.TextSize = 11.000
                sliderTextBox.TextWrapped = true
                local Held = false
                sliderFrame.MouseButton1Down:Connect(function() Held = true end)
                sliderBall.MouseButton1Down:Connect(function() Held = true end)
                UserInputService.InputEnded:Connect(function(Mouse) Held = false end)
                local function round(num, bracket)
                    bracket = bracket or 1
                    local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
                    if a < 0 then
                        a = a + bracket
                    end
                    return a
                end
                game:GetService("RunService").RenderStepped:Connect(function()
                    if Held then
                        local BtnPos = sliderBall.Position
                        local MousePos = UserInputService:GetMouseLocation().X
                        local FrameSize = sliderFrame.AbsoluteSize.X
                        local FramePos = sliderFrame.AbsolutePosition.X
                        local pos = (MousePos-FramePos)/FrameSize
                        pos = math.clamp(pos,0,0.9)
                        value = ((((max - min) / 0.9) * pos)) + min
                        value = round(value, opts.float)
                        value = math.clamp(value, min, max)
                        sliderTextBox.Text = value
                        if opts.callback then opts.callback(value) end
                        sliderBall.Position = UDim2.new(pos,0,BtnPos.Y.Scale, BtnPos.Y.Offset)
                    end
                end)
                sliderTextBox.FocusLost:Connect(function(Enter)
                    if Enter then
                        local newVal = tonumber(sliderTextBox.Text)
                        if newVal ~= nil then
                            newVal = math.clamp(newVal, min, max)
                            value = newVal
                            if opts.callback then opts.callback(value) end
                        end
                    end
                end)
                return Slider
            end

            -- Dropdown
            function SectionObj:AddDropdown(opts)
                local DropYSize = 0
                local Dropped = false
                local Dropdown = Instance.new("Frame")
                Dropdown.Parent = sectionFrame
                Dropdown.BackgroundTransparency = 1.000
                Dropdown.Size = UDim2.new(0, 200, 0, 22)
                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Parent = Dropdown
                dropdownLabel.BackgroundTransparency = 1.000
                dropdownLabel.Size = UDim2.new(0, 105, 0, 22)
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.Text = " " .. (opts.text or "Dropdown")
                dropdownLabel.TextColor3 = text
                dropdownLabel.TextSize = 14.000
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                local dropdownText = Instance.new("TextLabel")
                dropdownText.Parent = dropdownLabel
                dropdownText.BackgroundColor3 = section_color
                dropdownText.Position = UDim2.new(1.08571434, 0, 0.0909090936, 0)
                dropdownText.Size = UDim2.new(0, 87, 0, 18)
                dropdownText.Font = Enum.Font.Gotham
                dropdownText.Text = " " .. (opts.default or (opts.list and opts.list[1]) or "Select")
                dropdownText.TextColor3 = text
                dropdownText.TextSize = 12.000
                dropdownText.TextXAlignment = Enum.TextXAlignment.Left
                dropdownText.TextWrapped = true
                local dropdownArrow = Instance.new("ImageButton")
                dropdownArrow.Parent = dropdownText
                dropdownArrow.BackgroundColor3 = section_color
                dropdownArrow.BorderSizePixel = 0
                dropdownArrow.Position = UDim2.new(0.87356323, 0, 0.138888866, 0)
                dropdownArrow.Size = UDim2.new(0, 11, 0, 13)
                dropdownArrow.AutoButtonColor = false
                dropdownArrow.Image = "rbxassetid://8008296380"
                dropdownArrow.ImageColor3 = text
                local dropdownList = Instance.new("Frame")
                dropdownList.Parent = dropdownText
                dropdownList.BackgroundColor3 = section_color
                dropdownList.Position = UDim2.new(0, 0, 1, 0)
                dropdownList.Size = UDim2.new(0, 87, 0, 0)
                dropdownList.ClipsDescendants = true
                dropdownList.BorderSizePixel = 0
                dropdownList.ZIndex = 10
                local dropListLayout = Instance.new("UIListLayout")
                dropListLayout.Parent = dropdownList
                dropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                for i,v in next, opts.list or {} do
                    local dropdownBtn = Instance.new("TextButton")
                    dropdownBtn.Name = "dropdownBtn"
                    dropdownBtn.Parent = dropdownList
                    dropdownBtn.BackgroundTransparency = 1.000
                    dropdownBtn.Size = UDim2.new(0, 87, 0, 18)
                    dropdownBtn.AutoButtonColor = false
                    dropdownBtn.Font = Enum.Font.Gotham
                    dropdownBtn.TextColor3 = text
                    dropdownBtn.TextSize = 12.000
                    dropdownBtn.Text = v
                    dropdownBtn.ZIndex = 15
                    dropdownBtn.MouseButton1Click:Connect(function()
                        dropdownText.Text = " " .. v
                        if opts.callback then opts.callback(v) end
                    end)
                    DropYSize = DropYSize + 18
                end
                dropdownArrow.MouseButton1Click:Connect(function()
                    Dropped = not Dropped
                    TweenService:Create(dropdownList, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Size = Dropped and UDim2.new(0, 87, 0, DropYSize) or UDim2.new(0, 87, 0, 0)
                    }):Play()
                    TweenService:Create(dropdownList, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        BorderSizePixel = Dropped and 1 or 0
                    }):Play()
                end)
                return Dropdown
            end

            -- Textbox
            function SectionObj:AddTextbox(opts)
                local Textbox = Instance.new("Frame")
                Textbox.Parent = sectionFrame
                Textbox.BackgroundTransparency = 1.000
                Textbox.Size = UDim2.new(0, 200, 0, 22)
                local textBoxLabel = Instance.new("TextLabel")
                textBoxLabel.Parent = Textbox
                textBoxLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                textBoxLabel.BackgroundTransparency = 1.000
                textBoxLabel.Position = UDim2.new(0.237, 0, 0.5, 0)
                textBoxLabel.Size = UDim2.new(0, 99, 0, 22)
                textBoxLabel.Font = Enum.Font.Gotham
                textBoxLabel.Text = "  " .. (opts.text or "Textbox")
                textBoxLabel.TextColor3 = text
                textBoxLabel.TextSize = 14.000
                textBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
                local textBox = Instance.new("TextBox")
                textBox.Parent = Textbox
                textBox.AnchorPoint = Vector2.new(0.5, 0.5)
                textBox.BackgroundColor3 = section_color
                textBox.Position = UDim2.new(0.85, 0, 0.5, 0)
                textBox.Size = UDim2.new(0, 53, 0, 15)
                textBox.Font = Enum.Font.Gotham
                textBox.Text = opts.value or ""
                textBox.TextColor3 = text
                textBox.TextSize = 11.000
                textBox.TextWrapped = true
                textBox.FocusLost:Connect(function(Enter)
                    if Enter then
                        if textBox.Text ~= nil and textBox.Text ~= "" and opts.callback then
                            opts.callback(textBox.Text)
                        end
                    end
                end)
                return Textbox
            end

            -- Keybind
            function SectionObj:AddKeybind(opts)
                local oldKey = opts.default and opts.default.Name or "None"
                local Keybind = Instance.new("Frame")
                Keybind.Parent = sectionFrame
                Keybind.BackgroundTransparency = 1.000
                Keybind.Size = UDim2.new(0, 200, 0, 22)
                Keybind.ZIndex = 2
                local keybindButton = Instance.new("TextButton")
                keybindButton.Parent = Keybind
                keybindButton.AnchorPoint = Vector2.new(0.5, 0.5)
                keybindButton.BackgroundTransparency = 1.000
                keybindButton.Position = UDim2.new(0.5, 0, 0.5, 0)
                keybindButton.Size = UDim2.new(0, 200, 0, 22)
                keybindButton.AutoButtonColor = false
                keybindButton.Font = Enum.Font.Gotham
                keybindButton.Text = " " .. opts.text
                keybindButton.TextColor3 = text
                keybindButton.TextSize = 14.000
                keybindButton.TextXAlignment = Enum.TextXAlignment.Left
                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Parent = keybindButton
                keybindLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                keybindLabel.BackgroundTransparency = 1.000
                keybindLabel.Position = UDim2.new(0.91, 0, 0.5, 0)
                keybindLabel.Size = UDim2.new(0, 36, 0, 22)
                keybindLabel.Font = Enum.Font.Gotham
                keybindLabel.Text = oldKey .. " "
                keybindLabel.TextColor3 = text
                keybindLabel.TextSize = 14.000
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Right
                keybindButton.MouseButton1Click:Connect(function()
                    keybindLabel.Text = "... "
                    local inputbegan = UserInputService.InputBegan:wait()
                    if not inputbegan.UserInputType == Enum.UserInputType.Keyboard then return end
                    oldKey = inputbegan.KeyCode.Name
                    keybindLabel.Text = oldKey
                end)
                UserInputService.InputBegan:Connect(function(key, focused)
                    if not focused then
                        if key.KeyCode.Name == oldKey and opts.callback then
                            opts.callback(oldKey)
                        end
                    end
                end)
                return Keybind
            end

            -- Colorpicker
            function SectionObj:AddColorpicker(opts)
                local color = opts.color or Color3.new(1,1,1)
                local hue, sat, val = Color3.toHSV(color)
                local Colorpicker = Instance.new("Frame")
                Colorpicker.Parent = sectionFrame
                Colorpicker.BackgroundTransparency = 1.000
                Colorpicker.Size = UDim2.new(0, 200, 0, 22)
                Colorpicker.ZIndex = 2
                local colorpickerLabel = Instance.new("TextLabel")
                colorpickerLabel.Parent = Colorpicker
                colorpickerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                colorpickerLabel.BackgroundTransparency = 1.000
                colorpickerLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                colorpickerLabel.Size = UDim2.new(0, 200, 0, 22)
                colorpickerLabel.Font = Enum.Font.Gotham
                colorpickerLabel.Text = " " .. (opts.text or "Colorpicker")
                colorpickerLabel.TextColor3 = text
                colorpickerLabel.TextSize = 14.000
                colorpickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                local colorpickerButton = Instance.new("ImageButton")
                colorpickerButton.Parent = colorpickerLabel
                colorpickerButton.AnchorPoint = Vector2.new(0.5, 0.5)
                colorpickerButton.BackgroundTransparency = 1.000
                colorpickerButton.Position = UDim2.new(0.92, 0, 0.57, 0)
                colorpickerButton.Size = UDim2.new(0, 15, 0, 15)
                colorpickerButton.Image = "rbxassetid://8023491332"
                local colorpickerFrame = Instance.new("Frame")
                colorpickerFrame.Parent = Colorpicker
                colorpickerFrame.Visible = false
                colorpickerFrame.BackgroundColor3 = section_color
                colorpickerFrame.Position = UDim2.new(1.15, 0, 0.5, 0)
                colorpickerFrame.Size = UDim2.new(0, 251, 0, 221)
                colorpickerFrame.ZIndex = 15
                Dragify(colorpickerFrame, Colorpicker)
                local RGB = Instance.new("ImageButton")
                RGB.Parent = colorpickerFrame
                RGB.BackgroundTransparency = 1.000
                RGB.Position = UDim2.new(0.067, 0, 0.068, 0)
                RGB.Size = UDim2.new(0, 179, 0, 161)
                RGB.AutoButtonColor = false
                RGB.Image = "rbxassetid://6523286724"
                RGB.ZIndex = 16
                local RGBCircle = Instance.new("ImageLabel")
                RGBCircle.Parent = RGB
                RGBCircle.BackgroundTransparency = 1.000
                RGBCircle.Size = UDim2.new(0, 14, 0, 14)
                RGBCircle.Image = "rbxassetid://3926309567"
                RGBCircle.ImageRectOffset = Vector2.new(628, 420)
                RGBCircle.ImageRectSize = Vector2.new(48, 48)
                RGBCircle.ZIndex = 16
                local Darkness = Instance.new("ImageButton")
                Darkness.Parent = colorpickerFrame
                Darkness.BackgroundTransparency = 1.000
                Darkness.Position = UDim2.new(0.83194, 0, 0.068, 0)
                Darkness.Size = UDim2.new(0, 33, 0, 161)
                Darkness.AutoButtonColor = false
                Darkness.Image = "rbxassetid://156579757"
                Darkness.ZIndex = 16
                local DarknessCircle = Instance.new("Frame")
                DarknessCircle.Parent = Darkness
                DarknessCircle.BackgroundTransparency = 0
                DarknessCircle.Position = UDim2.new(0, 0, 0, 0)
                DarknessCircle.Size = UDim2.new(0, 33, 0, 5)
                DarknessCircle.ZIndex = 16
                local colorHex = Instance.new("TextLabel")
                colorHex.Parent = colorpickerFrame
                colorHex.BackgroundColor3 = button_color
                colorHex.Position = UDim2.new(0.0717, 0, 0.8506, 0)
                colorHex.Size = UDim2.new(0, 94, 0, 24)
                colorHex.Font = Enum.Font.GothamSemibold
                colorHex.Text = "#FFFFFF"
                colorHex.TextColor3 = text
                colorHex.TextSize = 14.000
                colorHex.ZIndex = 16
                local Copy = Instance.new("TextButton")
                Copy.Parent = colorpickerFrame
                Copy.BackgroundColor3 = button_color
                Copy.Position = UDim2.new(0.721, 0, 0.8506, 0)
                Copy.Size = UDim2.new(0, 60, 0, 24)
                Copy.AutoButtonColor = false
                Copy.Font = Enum.Font.GothamSemibold
                Copy.Text = "Copy"
                Copy.TextColor3 = text
                Copy.TextSize = 14.000
                Copy.ZIndex = 16
                local WheelDown, SlideDown = false, false
                local function to_hex(color)
                    return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
                end
                local function update()
                    local c = Color3.fromHSV(hue, sat, val)
                    colorHex.Text = tostring(to_hex(c))
                end
                local function UpdateRing()
                    local ml = LocalPlayer:GetMouse()
                    local x = ml.X - RGB.AbsolutePosition.X
                    local y = ml.Y - RGB.AbsolutePosition.Y
                    local maxX,maxY = RGB.AbsoluteSize.X,RGB.AbsoluteSize.Y
                    x = math.clamp(x,0,maxX)
                    y = math.clamp(y,0,maxY)
                    x = x/maxX
                    y = y/maxY
                    local cx = RGBCircle.AbsoluteSize.X/2
                    local cy = RGBCircle.AbsoluteSize.Y/2
                    RGBCircle.Position = UDim2.new(x,-cx,y,-cy)
                    hue = 1-x
                    sat = 1-y
                    local realcolor = Color3.fromHSV(hue, sat, val)
                    Darkness.BackgroundColor3 = realcolor
                    DarknessCircle.BackgroundColor3 = realcolor
                    opts.callback(realcolor)
                    update();
                end
                local function UpdateSlide()
                    local ml = LocalPlayer:GetMouse()
                    local y = ml.Y - Darkness.AbsolutePosition.Y
                    local maxY = Darkness.AbsoluteSize.Y
                    y = math.clamp(y,0,maxY)
                    y = y/maxY
                    local cy = DarknessCircle.AbsoluteSize.Y/2
                    val = 1-y
                    local realcolor = Color3.fromHSV(hue, sat, val)
                    DarknessCircle.BackgroundColor3 = realcolor
                    DarknessCircle.Position = UDim2.new(0,0,y,-cy)
                    opts.callback(realcolor)
                    update();
                end
                RGB.MouseButton1Down:Connect(function()
                    WheelDown = true
                    UpdateRing()
                end)
                Darkness.MouseButton1Down:Connect(function()
                    SlideDown = true
                    UpdateSlide()
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        WheelDown = false
                        SlideDown = false
                    end
                end)
                RGB.MouseMoved:Connect(function()
                    if WheelDown then
                        UpdateRing()
                    end
                end)
                Darkness.MouseMoved:Connect(function()
                    if SlideDown then
                        UpdateSlide()
                    end
                end)
                Copy.MouseButton1Click:Connect(function()
                    if setclipboard then
                        setclipboard(tostring(colorHex.Text))
                        Notify("Colorpicker", tostring(colorHex.Text))
                    else
                        print(tostring(colorHex.Text))
                        Notify("Colorpicker", tostring(colorHex.Text))
                    end
                end)
                colorpickerButton.MouseButton1Click:Connect(function()
                    colorpickerFrame.Visible = not colorpickerFrame.Visible
                end)
                local function setcolor()
                    local realcolor = Color3.fromHSV(hue, sat, val)
                    colorHex.Text = tostring(to_hex(realcolor))
                    DarknessCircle.BackgroundColor3 = realcolor
                    if opts.callback then opts.callback(realcolor) end
                end
                setcolor()
                return Colorpicker
            end

            return SectionObj
        end

        return TabObj
    end

    -- Utility: Theme switch
    function WindowObj:SetTheme(theme)
        Library:SetTheme(theme)
    end
    -- Utility: Show/hide window
    function WindowObj:SetVisible(state)
        self.Main.Visible = state
    end
    -- Utility: Notification
    function WindowObj:Notify(title, text)
        Notify(title, text)
    end

    return WindowObj
end

return Library
