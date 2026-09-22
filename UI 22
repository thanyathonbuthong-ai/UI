local gethui = gethui or function() return game:GetService("CoreGui") end
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return nil end
local listfiles = listfiles or function() return {} end
local getcustomasset = getcustomasset or function() return "rbxasset://textures/ui/GuiImagePlaceholder.png" end
local getgenv = getgenv or function() return _G end
local identifyexecutor = identifyexecutor or function() return "Unknown" end
local setclipboard = setclipboard or function() end
local queue_on_teleport = queue_on_teleport or function() end

local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")
local http_service = game:GetService("HttpService")
local coregui = game:GetService("CoreGui")
local run_service = game:GetService("RunService")
local marketplace = game:GetService("MarketplaceService")

local player = players.LocalPlayer

if getgenv().library then
    getgenv().library:unload()
end

local function hex_to_color(hex)
    if type(hex) ~= "string" then return nil end
    if string.sub(hex, 1, 1) ~= "#" then hex = "#" .. hex end
    
    if Color3.fromHex then
        local ok, color = pcall(Color3.fromHex, hex)
        if ok and color then return color end
    end
    
    local clean_hex = string.gsub(hex, "#", "")
    if #clean_hex == 6 then
        local r = tonumber(string.sub(clean_hex, 1, 2), 16)
        local g = tonumber(string.sub(clean_hex, 3, 4), 16)
        local b = tonumber(string.sub(clean_hex, 5, 6), 16)
        if r and g and b then return Color3.fromRGB(r, g, b) end
    elseif #clean_hex == 3 then
        local r = tonumber(string.sub(clean_hex, 1, 1), 16) * 17
        local g = tonumber(string.sub(clean_hex, 2, 2), 16) * 17
        local b = tonumber(string.sub(clean_hex, 3, 3), 16) * 17
        if r and g and b then return Color3.fromRGB(r, g, b) end
    end
    return nil
end

local library = {
    flags = {},
    config_flags = {},
    instances = {},
    connections = {},
    theme_elements = {
        background = {}, sidebar = {}, accent = {}, text = {},
        placeholder = {}, stroke = {}, element_background = {},
        dropdown = {}, highlight = {}
    },
    active_toggles = {},
    active_notifs = {},
    active_popups = {},
    current_tab = nil,
    directory = "Femboy-Ware",
    drag_speed = 0.08,
    is_loading = false,
    themes = {
        preset = {
            background = Color3.fromRGB(30, 30, 30),
            sidebar = Color3.fromRGB(25, 25, 25),
            accent = Color3.fromRGB(150, 150, 150),
            text = Color3.fromRGB(220, 220, 220),
            placeholder = Color3.fromRGB(140, 140, 140),
            stroke = Color3.fromRGB(50, 50, 50),
            element_background = Color3.fromRGB(40, 40, 40),
            dropdown = Color3.fromRGB(35, 35, 35),
            highlight = Color3.fromRGB(40, 40, 40)
        }
    },
    tab_order = 0
}

function library:close_popups()
    for i = #self.active_popups, 1, -1 do
        local p = self.active_popups[i]
        if p and p.Parent then
            p.Visible = false
        end
        table.remove(self.active_popups, i)
    end
end

function library:create(class, props)
    local inst = Instance.new(class)
    for prop, val in next, props do
        inst[prop] = val
        for t_name, t_color in pairs(self.themes.preset) do
            if typeof(val) == "Color3" and val == t_color then
                if not self.theme_elements[t_name] then self.theme_elements[t_name] = {} end
                table.insert(self.theme_elements[t_name], {inst = inst, prop = prop})
                break
            end
        end
    end
    table.insert(self.instances, inst)
    return inst
end

function library:change_theme(theme_data)
    local t_info = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    for t_name, color in pairs(theme_data) do
        self.themes.preset[t_name] = color
        if self.theme_elements[t_name] then
            for _, data in ipairs(self.theme_elements[t_name]) do
                if data.inst and data.inst.Parent then
                    tween_service:Create(data.inst, t_info, {[data.prop] = color}):Play()
                end
            end
        end
    end
    for _, inst in ipairs(self.active_toggles) do
        if inst and inst.Parent then
            tween_service:Create(inst, t_info, {BackgroundColor3 = theme_data.accent or self.themes.preset.accent}):Play()
        end
    end
end

function library:change_accent(color)
    self.themes.preset.accent = color
    local t_info = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    if self.theme_elements.accent then
        for _, data in ipairs(self.theme_elements.accent) do
            if data.inst and data.inst.Parent then
                local tw = tween_service:Create(data.inst, t_info, {[data.prop] = color})
                tw:Play()
            end
        end
    end
    for _, inst in ipairs(self.active_toggles) do
        if inst and inst.Parent then
            local tw = tween_service:Create(inst, t_info, {BackgroundColor3 = color})
            tw:Play()
        end
    end
end

function library:change_background(color)
    self.themes.preset.background = color
    local t_info = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if self.theme_elements.background then
        for _, data in ipairs(self.theme_elements.background) do
            if data.inst and data.inst.Parent then
                local tw = tween_service:Create(data.inst, t_info, {[data.prop] = color})
                tw:Play()
            end
        end
    end
end

function library:connection(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(self.connections, conn)
    return conn
end

function library:unload()
    for _, conn in next, self.connections do if conn.Connected then conn:Disconnect() end end
    for _, inst in next, self.instances do if inst and inst.Parent then inst:Destroy() end end
    if self.gui then self.gui:Destroy() end
    getgenv().library = nil
end

function library:get_icon(icon)
    if not icon then return "rbxasset://textures/ui/GuiImagePlaceholder.png" end
    
    if string.sub(icon, 1, 4) == "http" or string.sub(icon, 1, 7) == "rbxasset" then
        return icon
    end

    if not isfolder(self.directory) then makefolder(self.directory) end
    local icon_folder = self.directory .. "/icons"
    if not isfolder(icon_folder) then makefolder(icon_folder) end

    local file_name = icon
    if string.sub(file_name, -4):lower() == ".png" then
        file_name = string.sub(file_name, 1, -5)
    end
    file_name = file_name .. ".png"

    local path = icon_folder .. "/" .. file_name
    if isfile(path) then
        return getcustomasset(path)
    end

    local urls = {
        "https://raw.githubusercontent.com/weound/lx/main/ui/fware/assets/icons/" .. file_name,
        "https://raw.githubusercontent.com/weound/lx/main/ui/fware/assets/" .. file_name
    }

    for _, url in ipairs(urls) do
        local success, data = pcall(function() return game:HttpGet(url) end)
        if success and data and #data > 100 then
            writefile(path, data)
            return getcustomasset(path)
        end
    end

    local q_path = icon_folder .. "/question.png"
    if isfile(q_path) then
        return getcustomasset(q_path)
    end
    
    local q_urls = {
        "https://raw.githubusercontent.com/weound/lx/main/ui/fware/assets/icons/question.png",
        "https://raw.githubusercontent.com/weound/lx/main/ui/fware/assets/question.png"
    }
    for _, q_url in ipairs(q_urls) do
        local q_success, q_data = pcall(function() return game:HttpGet(q_url) end)
        if q_success and q_data and #q_data > 100 then
            writefile(q_path, q_data)
            return getcustomasset(q_path)
        end
    end

    return "rbxasset://textures/ui/GuiImagePlaceholder.png"
end

local function parse_markdown(md)
    if type(md) ~= "string" then return "invalid changelog" end
    local html = ""
    local in_code = false
    local in_diff = false
    
    for line in string.gmatch(md .. "\n", "(.-)\n") do
        if string.sub(line, 1, 3) == "```" then
            local lang = string.match(line, "```(%w+)")
            in_code = not in_code
            if in_code then
                in_diff = (lang == "diff")
            else
                in_diff = false
            end
            html = html .. "<br/>"
        elseif not in_code then
            if string.sub(line, 1, 3) == "-# " then
                html = html .. '<font size="11" color="#6a6a6a">' .. string.sub(line, 4) .. '</font><br/>'
            elseif string.sub(line, 1, 4) == "### " then
                html = html .. '<font size="13" color="#9a9a9a"><b>' .. string.sub(line, 5) .. '</b></font><br/>'
            elseif string.sub(line, 1, 3) == "## " then
                html = html .. '<font size="14" color="#9a9a9a"><b>' .. string.sub(line, 4) .. '</b></font><br/>'
            elseif string.sub(line, 1, 2) == "# " then
                html = html .. '<font size="16" color="#ffffff"><b>' .. string.sub(line, 3) .. '</b></font><br/>'
            elseif string.sub(line, 1, 2) == "- " or string.sub(line, 1, 2) == "* " then
                html = html .. '• ' .. string.sub(line, 3) .. '<br/>'
            else
                html = html .. line .. '<br/>'
            end
        else
            if in_diff then
                if string.sub(line, 1, 1) == "+" then
                    html = html .. '<font color="#50ff80">' .. line .. '</font><br/>'
                elseif string.sub(line, 1, 1) == "-" then
                    html = html .. '<font color="#ff5050">' .. line .. '</font><br/>'
                else
                    html = html .. '<font color="#8c8c8c">' .. line .. '</font><br/>'
                end
            else
                html = html .. '<font color="#8c8c8c">' .. line .. '</font><br/>'
            end
        end
    end
    return html
end

function library:loading_screen(props)
    local cfg = {
        text = props.text or "loading...",
        duration = props.duration or 2,
        icon = props.icon or "loader"
    }

    self.is_loading = true

    if not self.gui or not self.gui:FindFirstChild("main") then return end
    
    local main_frame = self.gui.main
    main_frame.Visible = true

    local screen = self:create("Frame", {
        Name = "loader",
        Parent = main_frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.themes.preset.background,
        BorderSizePixel = 0,
        ZIndex = 9999
    })
    self:create("UICorner", { Parent = screen, CornerRadius = UDim.new(0, 6) })

    local logo = self:create("ImageLabel", {
        Name = "logo",
        Parent = screen,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -40),
        Size = UDim2.new(0, 120, 0, 120),
        Image = self:get_icon(cfg.icon),
        ZIndex = 10000
    })

    local text_label = self:create("TextLabel", {
        Name = "text",
        Parent = screen,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 60),
        Size = UDim2.new(0, 200, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = cfg.text,
        TextColor3 = self.themes.preset.text,
        TextSize = 14,
        ZIndex = 10000
    })

    local spin_info = TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local spin_tween = tween_service:Create(logo, spin_info, { Rotation = 360 })
    spin_tween:Play()
    
    local spin_conn
    spin_conn = spin_tween.Completed:Connect(function()
        if logo and logo.Parent then
            logo.Rotation = 0
            spin_tween:Play()
        else
            if spin_conn then spin_conn:Disconnect() end
        end
    end)

    task.delay(cfg.duration, function()
        if spin_conn then spin_conn:Disconnect() end
        if spin_tween then spin_tween:Pause() end
        
        tween_service:Create(screen, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        
        tween_service:Create(logo, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            ImageTransparency = 1
        }):Play()
        
        tween_service:Create(text_label, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            TextTransparency = 1
        }):Play()
        
        task.delay(0.8, function() if screen then screen:Destroy() end end)
    end)
end

function library:window(props)
    local cfg = {
        title = props.title or "femboy-ware",
        subtitle = props.subtitle or "",
        size = props.size or UDim2.new(0, 650, 0, 450),
        icon = props.icon or "logo",
        discord_link = props.discord_link or "https://discord.gg/yourserver",
        supported_executors = props.supported_executors or {"xeno", "velocity", "solara", "synz", "potassium", "volt", "cosmic", "wave", "madium", "real", "sirhurt", "delta", "codex"},
        changelog_url = props.changelog_url or "https://raw.githubusercontent.com/weound/lx/main/ui/fware/changelog.md",
        script_url = props.script_url or "https://raw.githubusercontent.com/weound/lx/main/ui/fware/example.luau",
        custom_themes = props.themes or {}
    }

    local to_preload = {"logo", "x", "minimize", "maximize", "settings", "panel-close", "panel-open", "house", "down", "search", "moon", "sun", "contrast", "palette", "loader"}
    for _, ic in ipairs(to_preload) do self:get_icon(ic) end

    self.gui = self:create("ScreenGui", {
        Name = "femboy_ware",
        Parent = gethui(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local main_frame = self:create("Frame", {
        Name = "main",
        Parent = self.gui,
        Size = cfg.size,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = self.themes.preset.background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false
    })
    self:create("UICorner", { Parent = main_frame, CornerRadius = UDim.new(0, 6) })
    self:create("UIStroke", { Parent = main_frame, Color = self.themes.preset.stroke, Thickness = 1 })

    local topbar = self:create("Frame", {
        Name = "topbar",
        Parent = main_frame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.themes.preset.sidebar,
        BorderSizePixel = 0
    })
    self:create("UICorner", { Parent = topbar, CornerRadius = UDim.new(0, 6) })

    local window_icon = self:create("ImageLabel", {
        Name = "icon",
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(0, 24, 0, 24),
        Image = self:get_icon(cfg.icon)
    })

    local title_label = self:create("TextLabel", {
        Name = "title",
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -200, 1, 0),
        Font = Enum.Font.GothamBold,
        RichText = true,
        Text = string.format('<font size="14">%s</font><font size="12" color="#8c8c8c">%s</font>', cfg.title, cfg.subtitle),
        TextColor3 = self.themes.preset.text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local content = self:create("Frame", {
        Name = "content",
        Parent = main_frame,
        Position = UDim2.new(0, 8, 0, 48),
        Size = UDim2.new(1, -16, 1, -56),
        BackgroundTransparency = 1
    })

    local sidebar = self:create("Frame", {
        Name = "sidebar",
        Parent = content,
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundColor3 = self.themes.preset.sidebar,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    self:create("UICorner", { Parent = sidebar, CornerRadius = UDim.new(0, 4) })

    local tab_list = self:create("ScrollingFrame", {
        Name = "tab_list",
        Parent = sidebar,
        Size = UDim2.new(1, 0, 1, -50),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    self:create("UIListLayout", { Parent = tab_list, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
    self:create("UIPadding", { Parent = tab_list, PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })

    local player_frame = self:create("Frame", {
        Name = "player_info",
        Parent = sidebar,
        Position = UDim2.new(0, 6, 1, -44),
        Size = UDim2.new(1, -12, 0, 32),
        BackgroundTransparency = 1
    })

    local avatar_img = self:create("ImageLabel", {
        Name = "avatar",
        Parent = player_frame,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 32, 0, 32),
        Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png"
    })
    self:create("UICorner", { Parent = avatar_img, CornerRadius = UDim.new(1, 0) })

    local pname_label = self:create("TextLabel", {
        Name = "pname",
        Parent = player_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = player.DisplayName,
        TextColor3 = self.themes.preset.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local tab_content = self:create("Frame", {
        Name = "tab_content",
        Parent = content,
        Position = UDim2.new(0, 148, 0, 0),
        Size = UDim2.new(1, -148, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    local close_btn = self:create("ImageButton", {
        Name = "close",
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -34, 0, 8),
        Size = UDim2.new(0, 24, 0, 24),
        Image = self:get_icon("x")
    })

    local minimize_btn = self:create("ImageButton", {
        Name = "minimize",
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -68, 0, 9),
        Size = UDim2.new(0, 21, 0, 21),
        Image = self:get_icon("minimize")
    })

    local settings_btn = self:create("ImageButton", {
        Name = "settings",
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -101, 0, 9),
        Size = UDim2.new(0, 21, 0, 21),
        Image = self:get_icon("settings")
    })

    local panel_btn = self:create("ImageButton", {
        Name = "panel",
        Parent = topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -134, 0, 9),
        Size = UDim2.new(0, 21, 0, 21),
        Image = self:get_icon("panel-close")
    })

    local dragging, drag_start, start_pos
    self:connection(topbar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = main_frame.Position
        end
    end)
    self:connection(topbar.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    self:connection(uis.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - drag_start
                local target_pos = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
                if library.drag_speed > 0 then
                    tween_service:Create(main_frame, TweenInfo.new(library.drag_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target_pos}):Play()
                else
                    main_frame.Position = target_pos
                end
            end
        elseif input.UserInputType == Enum.UserInputType.MouseWheel then
            library:close_popups()
        end
    end)

    self:connection(close_btn.MouseButton1Click, function()
        if self.is_closing then return end
        self.is_closing = true

        local overlay = self:create("Frame", {
            Name = "closing_overlay",
            Parent = main_frame,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = self.themes.preset.background,
            BorderSizePixel = 0,
            ZIndex = 9998,
            ClipsDescendants = true
        })
        self:create("UICorner", { Parent = overlay, CornerRadius = UDim.new(0, 6) })

        local fuckoff = self:create("TextLabel", {
            Name = "fuck_off!",
            Parent = overlay,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = main_frame.Size,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = self.themes.preset.text,
            TextSize = 24,
            ZIndex = 9999
        })

        local expand_tween = tween_service:Create(overlay, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0)
        })
        expand_tween:Play()
        expand_tween.Completed:Wait()

        local function rng(char) -- i guess
            local base = math.random() * 0.15 + 0.03
            if char == "," or char == "." or char == " " then base += math.random() * 0.12 end
            return tonumber(string.format("%.3f", base))
        end

        local full_text = "goodbye, " .. player.DisplayName

        for i = 1, #full_text do
            local char = string.sub(full_text, i, i)
            fuckoff.Text = string.sub(full_text, 1, i)
            task.wait(rng(char))
        end

        for _, child in ipairs(main_frame.Parent:GetChildren()) do
            if child ~= main_frame then
                child:Destroy()
            end
        end

        for _, child in ipairs(main_frame:GetChildren()) do
            if child ~= overlay then
                child:Destroy()
            end
        end

        task.wait(1.53) -- ok

        local shrink_tween = tween_service:Create(overlay, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        shrink_tween:Play()
        main_frame.BackgroundTransparency = 1
        
        tween_service:Create(fuckoff, TweenInfo.new(0.4), {TextTransparency = 1}):Play()

        shrink_tween.Completed:Wait()

        self:unload()
    end)

    local minimized = false
    self:connection(minimize_btn.MouseButton1Click, function()
        minimized = not minimized
        self:close_popups()
        local target_size = minimized and UDim2.new(cfg.size.X.Scale, cfg.size.X.Offset, 0, 40) or cfg.size
        minimize_btn.Image = minimized and self:get_icon("maximize") or self:get_icon("minimize")
        content.Visible = not minimized
        tween_service:Create(main_frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = target_size }):Play()
    end)

    local panel_collapsed = false
    self:connection(panel_btn.MouseButton1Click, function()
        panel_collapsed = not panel_collapsed
        self:close_popups()
        local target_w = panel_collapsed and 50 or 140
        local target_x = panel_collapsed and 58 or 148
        local target_icon = panel_collapsed and "panel-open" or "panel-close"
        
        local t_info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        tween_service:Create(sidebar, t_info, { Size = UDim2.new(0, target_w, 1, 0) }):Play()
        tween_service:Create(tab_content, t_info, { Position = UDim2.new(0, target_x, 0, 0), Size = UDim2.new(1, -target_x, 1, 0) }):Play()
        panel_btn.Image = self:get_icon(target_icon)
        
        for _, tab in next, self.tabs do
            if tab.text_label then
                tween_service:Create(tab.text_label, t_info, { TextTransparency = panel_collapsed and 1 or 0 }):Play()
            end
            if tab.icon_label then
                local target_pos = UDim2.new(0, 12, 0.5, 0)
                tween_service:Create(tab.icon_label, t_info, { Position = target_pos }):Play()
            end
        end
        tween_service:Create(pname_label, t_info, { TextTransparency = panel_collapsed and 1 or 0 }):Play()
        
        if panel_collapsed then
            tween_service:Create(avatar_img, t_info, { Position = UDim2.new(0, 3, 0.5, 0) }):Play()
        else
            tween_service:Create(avatar_img, t_info, { Position = UDim2.new(0, 0, 0.5, 0) }):Play()
        end
    end)

    self.tabs = {}

    local home_tab = self:tab({ name = "home", icon = "house", hidden_order = -1 })
    
    local info_section = home_tab:section({ name = "info" })
    local exec_name = "Unknown"
    local ok, name = pcall(identifyexecutor)
    if ok and type(name) == "string" then exec_name = name end

    local is_supported = "unsupported"
    for _, ex in ipairs(cfg.supported_executors) do
        if string.find(string.lower(exec_name), string.lower(ex)) then
            if string.lower(ex) == "xeno" or string.lower(ex) == "solara" then
                is_supported = "partially supported"
            else
                is_supported = "supported"
            end
            break
        end
    end
    
    local game_name = "unknown"
    local ok2, prod_info = pcall(function() return marketplace:GetProductInfo(game.PlaceId) end)
    if ok2 and prod_info and prod_info.Name then game_name = prod_info.Name end
    
    local latency_label = info_section:add_info_row("latency", "0ms")
    
    local region_val = "N/A"
    local ok4, region = pcall(function() return game:GetService("LocalizationService").RobloxLocaleId end)
    if ok4 and region then region_val = string.upper(region) end
    
    info_section:add_info_row("game", game_name)
    info_section:add_info_row("region", region_val)
    info_section:add_info_row("executor", exec_name)
    info_section:add_info_row("support", is_supported)
    
    library.button(info_section, {
        name = "join discord",
        callback = function()
            setclipboard(cfg.discord_link)
            self:notification({ text = "discord link copied to clipboard!" })
        end
    })

    task.spawn(function()
        while true do
            local ok3, ping = pcall(function() return player:GetNetworkPing() end)
            if ok3 and ping and latency_label and latency_label.Parent then
                latency_label.Text = string.format("%.0fms", ping * 1000)
            end
            task.wait(1)
        end
    end)

    local changelog_section = home_tab:section({ name = "changelog" })
    local changelog_text = "failed to load changelog."
    local success, data = pcall(function() return game:HttpGet(cfg.changelog_url) end)
    if success and data and string.sub(data, 1, 1) ~= "<" and #data > 10 then
        changelog_text = parse_markdown(data)
    end

    local cl_frame = self:create("Frame", {
        Name = "cl_frame",
        Parent = changelog_section.holder,
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = self.themes.preset.dropdown,
        BorderSizePixel = 0
    })
    self:create("UICorner", { Parent = cl_frame, CornerRadius = UDim.new(0, 4) })
    
    local cl_scroll = self:create("ScrollingFrame", {
        Name = "scroll",
        Parent = cl_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 4),
        Size = UDim2.new(1, -8, 1, -8),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.themes.preset.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0
    })
    self:create("UIPadding", { Parent = cl_scroll, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })

    local cl_label = self:create("TextLabel", {
        Name = "text",
        Parent = cl_scroll,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        RichText = true,
        Font = Enum.Font.Gotham,
        Text = changelog_text,
        TextColor3 = self.themes.preset.text,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    home_tab:select()

    cfg.settings_tab = self:tab({ name = "settings", icon = "settings", hidden = true })
    cfg.settings_tab.frame.Visible = false
    cfg.settings_tab.button.Visible = false

    self:connection(settings_btn.MouseButton1Click, function() cfg.settings_tab:select() end)

    local ui_section = cfg.settings_tab:section({ name = "ui" })
    
    local theme_options = {
        {name = "default", icon = "moon"},
        {name = "light", icon = "sun"},
        {name = "amoled", icon = "contrast"}
    }
    for name, _ in pairs(cfg.custom_themes) do
        table.insert(theme_options, {name = name, icon = "palette"})
    end

    ui_section:dropdown({
        name = "theme",
        options = theme_options,
        default = "default",
        flag = "theme",
        callback = function(val)
            local themes = {
                ["default"] = {
                    background = Color3.fromRGB(30, 30, 30),
                    sidebar = Color3.fromRGB(25, 25, 25),
                    accent = library.themes.preset.accent,
                    text = Color3.fromRGB(220, 220, 220),
                    placeholder = Color3.fromRGB(140, 140, 140),
                    stroke = Color3.fromRGB(50, 50, 50),
                    element_background = Color3.fromRGB(40, 40, 40),
                    dropdown = Color3.fromRGB(35, 35, 35),
                    highlight = Color3.fromRGB(40, 40, 40)
                },
                ["light"] = {
                    background = Color3.fromRGB(240, 240, 240),
                    sidebar = Color3.fromRGB(225, 225, 225),
                    accent = library.themes.preset.accent,
                    text = Color3.fromRGB(30, 30, 30),
                    placeholder = Color3.fromRGB(120, 120, 120),
                    stroke = Color3.fromRGB(200, 200, 200),
                    element_background = Color3.fromRGB(230, 230, 230),
                    dropdown = Color3.fromRGB(215, 215, 215),
                    highlight = Color3.fromRGB(220, 220, 220)
                },
                ["amoled"] = {
                    background = Color3.fromRGB(0, 0, 0),
                    sidebar = Color3.fromRGB(10, 10, 10),
                    accent = library.themes.preset.accent,
                    text = Color3.fromRGB(255, 255, 255),
                    placeholder = Color3.fromRGB(150, 150, 150),
                    stroke = Color3.fromRGB(30, 30, 30),
                    element_background = Color3.fromRGB(15, 15, 15),
                    dropdown = Color3.fromRGB(20, 20, 20),
                    highlight = Color3.fromRGB(15, 15, 15)
                }
            }
            for name, data in pairs(cfg.custom_themes) do themes[name] = data end
            if themes[val] then
                library:change_theme(themes[val])
            end
        end
    })
    ui_section:colorpicker({
        name = "accent color",
        default = library.themes.preset.accent,
        flag = "accent_color",
        callback = function(color)
            self:change_accent(color)
        end
    })
    ui_section:slider({
        name = "drag speed",
        min = 0, max = 0.3, default = 0.08,
        flag = "drag_speed",
        callback = function(val)
            library.drag_speed = val
        end
    })
    ui_section:keybind({
        name = "menu toggle",
        default = Enum.KeyCode.RightShift,
        flag = "menu_toggle",
        callback = function()
            main_frame.Visible = not main_frame.Visible
        end
    })

    local config_section = cfg.settings_tab:section({ name = "configs" })
    local config_name_input = config_section:textbox({ placeholder = "config name", clear_on_focus = true })

    library.button(config_section, { 
        name = "save config", 
        callback = function()
            local name = config_name_input.instance.Text
            if name == "" then return end
            local config_data = {}
            for flag, val in next, library.flags do config_data[flag] = val end
            local path = self.directory .. "/configs/" .. name .. ".json"
            writefile(path, http_service:JSONEncode(config_data))
            self:notification({ text = "saved config: " .. name })
            config_section:refresh_configs()
        end 
    })

    library.button(config_section, { 
        name = "load config", 
        callback = function()
            local name = config_name_input.instance.Text
            if name == "" then return end
            local path = self.directory .. "/configs/" .. name .. ".json"
            if isfile(path) then
                local data = http_service:JSONDecode(readfile(path))
                for flag, val in next, data do
                    if library.config_flags[flag] then library.config_flags[flag](val) end
                end
                self:notification({ text = "loaded config: " .. name })
            else
                self:notification({ text = "config not found!" })
            end
        end 
    })

    library.button(config_section, { 
        name = "delete config", 
        callback = function()
            local name = config_name_input.instance.Text
            if name == "" then return end
            local path = self.directory .. "/configs/" .. name .. ".json"
            if isfile(path) then
                delfile(path)
                self:notification({ text = "deleted config: " .. name })
                config_section:refresh_configs()
            else
                self:notification({ text = "config not found!" })
            end
        end 
    })

    config_section:toggle({
        name = "autoload config",
        default = isfile(self.directory .. "/autoload.txt"),
        flag = "autoload",
        callback = function(val)
            local path = self.directory .. "/autoload.txt"
            if val then
                writefile(path, config_name_input.instance.Text)
            else
                if isfile(path) then delfile(path) end
            end
        end
    })

    local other_section = cfg.settings_tab:section({ name = "other" })
    other_section:toggle({
        name = "auto execute",
        default = false,
        flag = "auto_exec",
        callback = function(val)
            if val then
                queue_on_teleport(cfg.script_url)
            else
                queue_on_teleport("")
            end
        end
    })

    function config_section:refresh_configs()
        if not isfolder(library.directory .. "/configs") then makefolder(library.directory .. "/configs") end
        local files = listfiles(library.directory .. "/configs")
        local names = {}
        for _, file in next, files do
            local name = file:match("([^/\\]+)%.json$")
            if name then table.insert(names, name) end
        end
        if config_section.config_dd then config_section.config_dd:refresh(names) end
    end

    config_section.config_dd = config_section:dropdown({ 
        name = "saved configs", 
        options = {}, 
        callback = function(val) config_name_input.instance.Text = val end
    })
    config_section:refresh_configs()

    if isfile(library.directory .. "/autoload.txt") then
        local name = readfile(library.directory .. "/autoload.txt")
        local path = library.directory .. "/configs/" .. name .. ".json"
        if isfile(path) then
            local data = http_service:JSONDecode(readfile(path))
            for flag, val in next, data do
                if library.config_flags[flag] then library.config_flags[flag](val) end
            end
        end
    end

    task.defer(function()
        if not library.is_loading then
            main_frame.Visible = true
        end
    end)

    return setmetatable(cfg, { __index = self })
end

function library:tab(props)
    local cfg = {
        name = props.name or "tab",
        icon = props.icon or "down",
        hidden = props.hidden or false,
        search_enabled = props.search or false,
        sections = {}
    }

    local order = props.hidden_order or self.tab_order
    if not props.hidden_order then
        self.tab_order += 1
        order = self.tab_order
    end

    local button = self:create("TextButton", {
        Name = cfg.name,
        Parent = self.gui.main.content.sidebar.tab_list,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = self.themes.preset.highlight,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order
    })
    self:create("UICorner", { Parent = button, CornerRadius = UDim.new(0, 4) })

    local accent_bar = self:create("Frame", {
        Name = "accent",
        Parent = button,
        Size = UDim2.new(0, 2, 0, 16),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundColor3 = self.themes.preset.accent,
        BorderSizePixel = 0,
        Visible = false
    })
    self:create("UICorner", { Parent = accent_bar, CornerRadius = UDim.new(1, 0) })

    local icon_label = self:create("ImageLabel", {
        Name = "icon",
        Parent = button,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        Image = self:get_icon(cfg.icon)
    })

    local text_label = self:create("TextLabel", {
        Name = "text",
        Parent = button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Font = Enum.Font.Gotham,
        Text = cfg.name,
        TextColor3 = self.themes.preset.placeholder,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local frame = self:create("Frame", {
        Name = cfg.name .. "_page",
        Parent = self.gui.main.content.tab_content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.themes.preset.background,
        BackgroundTransparency = 1,
        Visible = false,
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 1
    })

    local page_layout = frame.Parent:FindFirstChild("TabPageLayout")
    if not page_layout then
        page_layout = self:create("UIPageLayout", {
            Name = "TabPageLayout",
            Parent = frame.Parent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            EasingDirection = Enum.EasingDirection.InOut,
            EasingStyle = Enum.EasingStyle.Quint,
            TweenTime = 0.35,
            Padding = UDim.new(0, 0),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center
        })
    end

    local list_frame
    if cfg.search_enabled then
        local search_container = self:create("Frame", {
            Name = "search_container",
            Parent = frame,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1
        })

        local search_box = self:create("TextBox", {
            Name = "search",
            Parent = search_container,
            Position = UDim2.new(0, 30, 0, 0),
            Size = UDim2.new(1, -30, 1, 0),
            BackgroundColor3 = self.themes.preset.dropdown,
            Text = "",
            PlaceholderText = "search...",
            PlaceholderColor3 = self.themes.preset.placeholder,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = self.themes.preset.text,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        self:create("UICorner", { Parent = search_box, CornerRadius = UDim.new(0, 4) })
        self:create("UIPadding", { Parent = search_box, PaddingLeft = UDim.new(0, 8) })
        
        local search_icon = self:create("ImageLabel", {
            Parent = search_container,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(0, 16, 0, 16),
            BackgroundTransparency = 1,
            Image = self:get_icon("search")
        })
        
        list_frame = self:create("ScrollingFrame", {
            Name = "list_frame",
            Parent = frame,
            Position = UDim2.new(0, 0, 0, 40),
            Size = UDim2.new(1, 0, 1, -40),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = self.themes.preset.accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0
        })
        self:create("UIListLayout", { Parent = list_frame, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
        self:create("UIPadding", { Parent = list_frame, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

        self:connection(search_box:GetPropertyChangedSignal("Text"), function()
            local text = string.lower(search_box.Text)
            for _, section in next, cfg.sections do
                local matched = false
                if string.find(string.lower(section.name), text) then matched = true end
                if not matched then
                    for _, element in next, section.elements do
                        if element.name and string.find(string.lower(element.name), text) then
                            matched = true
                            break
                        end
                    end
                end
                section.frame.Visible = matched
            end
        end)
    else
        list_frame = self:create("ScrollingFrame", {
            Name = "list_frame",
            Parent = frame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = self.themes.preset.accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0
        })
        self:create("UIListLayout", { Parent = list_frame, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
        self:create("UIPadding", { Parent = list_frame, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
    end

    cfg.button = button
    cfg.frame = frame
    cfg.text_label = text_label
    cfg.icon_label = icon_label
    cfg.accent_bar = accent_bar
    cfg.order = order
    cfg.holder = list_frame

    table.insert(self.tabs, cfg)

    function cfg:select()
        if library.current_tab == cfg then return end
        
        library:close_popups()
        
        local old_tab = library.current_tab

        if old_tab then
            old_tab.button.BackgroundTransparency = 1
            old_tab.accent_bar.Visible = false
            old_tab.text_label.TextColor3 = library.themes.preset.placeholder
        end

        library.current_tab = cfg
        button.BackgroundTransparency = 0
        accent_bar.Visible = true
        text_label.TextColor3 = library.themes.preset.text
        
        frame.Visible = true
        frame.Parent.TabPageLayout:JumpTo(frame)
    end

    self:connection(button.MouseButton1Click, function() cfg:select() end)

    return setmetatable(cfg, { __index = self })
end

function library:section(props)
    local cfg = {
        name = props.name or "section",
        icon = props.icon or nil,
        expanded = true,
        elements = {}
    }

    local section_frame = self:create("Frame", {
        Name = cfg.name,
        Parent = self.holder,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = self.themes.preset.element_background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    self:create("UICorner", { Parent = section_frame, CornerRadius = UDim.new(0, 4) })

    local header = self:create("TextButton", {
        Name = "header",
        Parent = section_frame,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })

    local dropdown_icon = self:create("ImageLabel", {
        Name = "dropdown",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = self:get_icon("down")
    })

    local text_x = 12
    if cfg.icon then
        local s_icon = self:create("ImageLabel", {
            Name = "s_icon",
            Parent = header,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = self:get_icon(cfg.icon)
        })
        text_x = 32
    end

    local title = self:create("TextLabel", {
        Name = "title",
        Parent = header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, text_x, 0, 0),
        Size = UDim2.new(1, -text_x - 24, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = cfg.name,
        TextColor3 = self.themes.preset.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local elements_holder = self:create("Frame", {
        Name = "elements",
        Parent = section_frame,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })
    local elements_layout = self:create("UIListLayout", { Parent = elements_holder, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
    self:create("UIPadding", { Parent = elements_holder, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

    cfg.holder = elements_holder
    cfg.frame = section_frame

    self:connection(elements_layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if cfg.expanded then
            local target_height = elements_layout.AbsoluteContentSize.Y + 12 
            local target_frame_size = target_height + 32
            local t_info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tween_service:Create(elements_holder, t_info, { Size = UDim2.new(1, 0, 0, target_height) }):Play()
            tween_service:Create(section_frame, t_info, { Size = UDim2.new(1, 0, 0, target_frame_size) }):Play()
        end
    end)

    self:connection(header.MouseButton1Click, function()
        cfg.expanded = not cfg.expanded
        
        local target_height = cfg.expanded and (elements_layout.AbsoluteContentSize.Y + 12) or 0
        local target_frame_size = target_height + 32
        local target_rot = cfg.expanded and 0 or 180
        
        local t_info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        tween_service:Create(elements_holder, t_info, { Size = UDim2.new(1, 0, 0, target_height) }):Play()
        tween_service:Create(section_frame, t_info, { Size = UDim2.new(1, 0, 0, target_frame_size) }):Play()
        tween_service:Create(dropdown_icon, t_info, { Rotation = target_rot }):Play()
    end)

    function cfg:add_info_row(name, val)
        local row = self:create("Frame", {
            Name = name,
            Parent = self.holder,
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1
        })
        self:create("TextLabel", {
            Name = "name",
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 4, 0, 0),
            Size = UDim2.new(0.5, -4, 1, 0),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = self.themes.preset.placeholder,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        local val_label = self:create("TextLabel", {
            Name = "val",
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, 0),
            Size = UDim2.new(0.5, -4, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = val,
            TextColor3 = self.themes.preset.text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        return val_label
    end

    if self.sections then table.insert(self.sections, cfg) end

    return setmetatable(cfg, { __index = self })
end

function library:toggle(props)
    local cfg = {
        name = props.name or "toggle",
        default = props.default or false,
        flag = props.flag or props.name or "toggle_"..tostring(math.random(1, 100000)),
        callback = props.callback or function() end,
        keybind_enabled = props.keybind or (props.options and props.options.keybind) or false,
        default_key = props.default_key or Enum.KeyCode.Unknown,
        default_mode = props.default_mode or "toggle"
    }

    local toggle_frame = self:create("TextButton", {
        Name = cfg.name,
        Parent = self.holder,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    
    local name_width = -50
    local settings_btn = nil
    local popup_frame = nil
    local bind_btn = nil
    local mode_btn = nil
    local mode_list = nil
    local toggle_bind_input = nil
    local set_mode = nil
    local expanded = false
    local current_rot = 0
    local mode_open = false
    
    if cfg.keybind_enabled then
        name_width = -90
        settings_btn = self:create("ImageButton", {
            Name = "settings_btn",
            Parent = toggle_frame,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -68, 0, 8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = self:get_icon("settings"),
            ZIndex = 3
        })
        
        popup_frame = self:create("Frame", {
            Name = "keybind_popup",
            Parent = self.gui,
            Visible = false,
            Size = UDim2.new(0, 200, 0, 0),
            BackgroundColor3 = self.themes.preset.element_background,
            BorderSizePixel = 0,
            ZIndex = 100,
            ClipsDescendants = true
        })
        self:create("UICorner", { Parent = popup_frame, CornerRadius = UDim.new(0, 4) })
        self:create("UIStroke", { Parent = popup_frame, Color = self.themes.preset.stroke, Thickness = 1, ZIndex = 100 })
        self:create("UIPadding", { Parent = popup_frame, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
        
        local popup_layout = self:create("UIListLayout", {
            Parent = popup_frame,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local keybind_row = self:create("Frame", {
            Parent = popup_frame,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1
        })
        self:create("TextLabel", {
            Parent = keybind_row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -100, 1, 0),
            Font = Enum.Font.Gotham,
            Text = "keybind",
            TextColor3 = self.themes.preset.placeholder,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        bind_btn = self:create("TextButton", {
            Parent = keybind_row,
            Position = UDim2.new(1, -80, 0, 0),
            Size = UDim2.new(0, 70, 0, 20),
            BackgroundColor3 = self.themes.preset.dropdown,
            Text = "...",
            Font = Enum.Font.Gotham,
            TextColor3 = self.themes.preset.text,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false
        })
        self:create("UICorner", { Parent = bind_btn, CornerRadius = UDim.new(0, 4) })

        local remove_btn = self:create("ImageButton", {
            Parent = keybind_row,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 4, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Image = self:get_icon("x"),
            ZIndex = 3
        })

        local mode_row = self:create("Frame", {
            Parent = popup_frame,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1
        })
        self:create("TextLabel", {
            Parent = mode_row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -90, 1, 0),
            Font = Enum.Font.Gotham,
            Text = "mode",
            TextColor3 = self.themes.preset.placeholder,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        mode_btn = self:create("TextButton", {
            Parent = mode_row,
            Position = UDim2.new(1, -80, 0, 0),
            Size = UDim2.new(0, 80, 0, 20),
            BackgroundColor3 = self.themes.preset.dropdown,
            Text = cfg.default_mode,
            Font = Enum.Font.Gotham,
            TextColor3 = self.themes.preset.text,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false
        })
        self:create("UICorner", { Parent = mode_btn, CornerRadius = UDim.new(0, 4) })

        mode_list = self:create("Frame", {
            Parent = popup_frame,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = self.themes.preset.dropdown,
            BorderSizePixel = 0,
            Visible = false,
            ClipsDescendants = true
        })
        self:create("UICorner", { Parent = mode_list, CornerRadius = UDim.new(0, 4) })
        local mode_layout = self:create("UIListLayout", { Parent = mode_list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
        self:create("UIPadding", { Parent = mode_list, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })

        local function update_popup_size()
            local h = 20 + 6 + 20 
            if mode_open then
                h = h + 6 + 44 
            end
            h = h + 16 
            tween_service:Create(popup_frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, h)}):Play()
        end

        local function set_mode_open(open)
            mode_open = open
            if open then
                mode_list.Visible = true
                mode_list.Size = UDim2.new(1, 0, 0, 0)
                tween_service:Create(mode_list, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 44)}):Play()
            else
                local tw = tween_service:Create(mode_list, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
                tw:Play()
                tw.Completed:Connect(function()
                    if not mode_open then mode_list.Visible = false end
                end)
            end
            update_popup_size()
        end

        set_mode = function(m)
            if m ~= "toggle" and m ~= "hold" then
                m = "toggle"
            end
            cfg.mode = m
            mode_btn.Text = m
            library.flags[cfg.flag.."_mode"] = m
            if cfg.bind_conn then cfg.bind_conn:Disconnect() end
            if cfg.hold_conn then cfg.hold_conn:Disconnect() end
            if cfg.key ~= Enum.KeyCode.Unknown then
                if cfg.mode == "toggle" then
                    cfg.bind_conn = uis.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if (cfg.key.EnumType == Enum.KeyCode and input.KeyCode == cfg.key) or (cfg.key.EnumType == Enum.UserInputType and input.UserInputType == cfg.key) then
                            cfg.set(not cfg.value)
                        end
                    end)
                elseif cfg.mode == "hold" then
                    cfg.bind_conn = uis.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if (cfg.key.EnumType == Enum.KeyCode and input.KeyCode == cfg.key) or (cfg.key.EnumType == Enum.UserInputType and input.UserInputType == cfg.key) then
                            cfg.set(true)
                        end
                    end)
                    cfg.hold_conn = uis.InputEnded:Connect(function(input)
                        if (cfg.key.EnumType == Enum.KeyCode and input.KeyCode == cfg.key) or (cfg.key.EnumType == Enum.UserInputType and input.UserInputType == cfg.key) then
                            cfg.set(false)
                        end
                    end)
                end
            end
        end

        for _, m in ipairs({"toggle", "hold"}) do
            local opt_btn = self:create("TextButton", {
                Parent = mode_list,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false
            })
            self:create("TextLabel", {
                Parent = opt_btn,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = m,
                TextColor3 = self.themes.preset.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            self:connection(opt_btn.MouseButton1Click, function()
                set_mode(m)
                set_mode_open(false)
            end)
        end

        self:connection(mode_btn.MouseButton1Click, function()
            set_mode_open(not mode_open)
        end)

        toggle_bind_input = function(key)
            if key == nil then key = Enum.KeyCode.Unknown end
            if typeof(key) == "string" then
                local k = Enum.KeyCode[key] or Enum.UserInputType[key]
                if k then key = k else key = Enum.KeyCode.Unknown end
            elseif typeof(key) ~= "EnumItem" then
                key = Enum.KeyCode.Unknown
            end
            
            cfg.key = key
            local key_name = "None"
            if key ~= Enum.KeyCode.Unknown then
                key_name = key.Name
            end
            
            bind_btn.Text = key_name
            library.flags[cfg.flag.."_key"] = key_name
            
            if cfg.mode == nil then cfg.mode = "toggle" end
            set_mode(cfg.mode)
        end

        self:connection(remove_btn.MouseButton1Click, function()
            toggle_bind_input(Enum.KeyCode.Unknown)
        end)

        self:connection(bind_btn.MouseButton1Click, function()
            bind_btn.Text = "..."
            cfg.binding = true
            local conn
            conn = uis.InputBegan:Connect(function(input)
                if cfg.binding then
                    local valid_input = false
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        valid_input = true
                        toggle_bind_input(input.KeyCode)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                        valid_input = true
                        toggle_bind_input(input.UserInputType)
                    end
                    if valid_input then
                        cfg.binding = false
                        if conn then conn:Disconnect() end
                    end
                end
            end)
        end)

        local function update_popup_pos()
            local btn_pos = settings_btn.AbsolutePosition
            local btn_size = settings_btn.AbsoluteSize
            popup_frame.Position = UDim2.new(0, btn_pos.X - 180, 0, btn_pos.Y + btn_size.Y + 4)
        end

        self:connection(settings_btn.MouseButton1Click, function()
            expanded = not expanded
            current_rot += 360
            tween_service:Create(settings_btn, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = current_rot}):Play()
            
            if expanded then
                mode_open = false
                mode_list.Visible = false
                mode_list.Size = UDim2.new(1, 0, 0, 0)
                popup_frame.Visible = true
                popup_frame.Size = UDim2.new(0, 200, 0, 0)
                update_popup_pos()
                update_popup_size()
            else
                mode_open = false
                local tw = tween_service:Create(mode_list, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
                tw:Play()
                tween_service:Create(popup_frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)}):Play()
                task.delay(0.3, function() 
                    if not expanded then 
                        popup_frame.Visible = false 
                        mode_list.Visible = false
                    end 
                end)
            end
        end)

        self:connection(settings_btn:GetPropertyChangedSignal("AbsolutePosition"), function()
            if popup_frame.Visible then
                update_popup_pos()
            end
        end)

        toggle_bind_input(cfg.default_key)
        set_mode(cfg.default_mode)
        
        library.config_flags[cfg.flag.."_key"] = function(val) toggle_bind_input(val) end
        library.config_flags[cfg.flag.."_mode"] = function(val) set_mode(val) end
    end
    
    local name_label = self:create("TextLabel", {
        Name = "name",
        Parent = toggle_frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, name_width, 1, 0),
        Font = Enum.Font.Gotham,
        Text = cfg.name,
        TextColor3 = self.themes.preset.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local switch_bg = self:create("Frame", {
        Name = "switch",
        Parent = toggle_frame,
        Position = UDim2.new(1, -42, 0, 6),
        Size = UDim2.new(0, 36, 0, 20),
        BackgroundColor3 = self.themes.preset.dropdown,
        BorderSizePixel = 0
    })
    self:create("UICorner", { Parent = switch_bg, CornerRadius = UDim.new(1, 0) })

    local switch_dot = self:create("Frame", {
        Name = "dot",
        Parent = switch_bg,
        Position = UDim2.new(0, 3, 0, 3),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = self.themes.preset.text,
        BorderSizePixel = 0
    })
    self:create("UICorner", { Parent = switch_dot, CornerRadius = UDim.new(1, 0) })

    function cfg.set(val)
        cfg.value = val
        library.flags[cfg.flag] = val
        local color = val and self.themes.preset.accent or self.themes.preset.dropdown
        local pos = val and UDim2.new(1, -17, 0, 3) or UDim2.new(0, 3, 0, 3)
        tween_service:Create(switch_bg, TweenInfo.new(0.2), { BackgroundColor3 = color }):Play()
        tween_service:Create(switch_dot, TweenInfo.new(0.2), { Position = pos }):Play()
        if val then
            table.insert(library.active_toggles, switch_bg)
        else
            local idx = table.find(library.active_toggles, switch_bg)
            if idx then table.remove(library.active_toggles, idx) end
        end
        if type(cfg.callback) == "function" then cfg.callback(val) end
    end

    self:connection(toggle_frame.MouseButton1Click, function() cfg.set(not cfg.value) end)
    cfg.set(cfg.default)
    library.config_flags[cfg.flag] = cfg.set
    
    if self.elements then table.insert(self.elements, cfg) end
    return setmetatable(cfg, { __index = self })
end

function library:button(props)
    local cfg = {
        name = props.name or "button",
        callback = props.callback or function() end,
        keybind_enabled = props.keybind or false,
        default_key = props.default_key or Enum.KeyCode.Unknown,
        flag = props.flag or props.name or "button_"..tostring(math.random(1, 100000))
    }

    local btn = self:create("TextButton", {
        Name = cfg.name,
        Parent = self.holder,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = self.themes.preset.dropdown,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    self:create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })

    local name_width = -50
    local settings_btn = nil
    local popup_frame = nil
    local bind_btn = nil
    local remove_btn = nil
    local toggle_bind_input = nil
    local expanded = false
    local current_rot = 0

    if cfg.keybind_enabled then
        name_width = -90
        settings_btn = self:create("ImageButton", {
            Name = "settings_btn",
            Parent = btn,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -32, 0, 8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = self:get_icon("settings"),
            ZIndex = 3
        })
        
        popup_frame = self:create("Frame", {
            Name = "keybind_popup",
            Parent = self.gui,
            Visible = false,
            Size = UDim2.new(0, 200, 0, 0),
            BackgroundColor3 = self.themes.preset.element_background,
            BorderSizePixel = 0,
            ZIndex = 100,
            ClipsDescendants = true
        })
        self:create("UICorner", { Parent = popup_frame, CornerRadius = UDim.new(0, 4) })
        self:create("UIStroke", { Parent = popup_frame, Color = self.themes.preset.stroke, Thickness = 1, ZIndex = 100 })
        self:create("UIPadding", { Parent = popup_frame, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
        
        local popup_layout = self:create("UIListLayout", {
            Parent = popup_frame,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local keybind_row = self:create("Frame", {
            Parent = popup_frame,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1
        })
        self:create("TextLabel", {
            Parent = keybind_row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -100, 1, 0),
            Font = Enum.Font.Gotham,
            Text = "keybind",
            TextColor3 = self.themes.preset.placeholder,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        bind_btn = self:create("TextButton", {
            Parent = keybind_row,
            Position = UDim2.new(1, -80, 0, 0),
            Size = UDim2.new(0, 70, 0, 20),
            BackgroundColor3 = self.themes.preset.dropdown,
            Text = "...",
            Font = Enum.Font.Gotham,
            TextColor3 = self.themes.preset.text,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false
        })
        self:create("UICorner", { Parent = bind_btn, CornerRadius = UDim.new(0, 4) })

        remove_btn = self:create("ImageButton", {
            Parent = keybind_row,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 4, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Image = self:get_icon("x"),
            ZIndex = 3
        })

        local function update_popup_size()
            local h = 20 + 16
            tween_service:Create(popup_frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, h)}):Play()
        end

        toggle_bind_input = function(key)
            if key == nil then key = Enum.KeyCode.Unknown end
            if typeof(key) == "string" then
                local k = Enum.KeyCode[key] or Enum.UserInputType[key]
                if k then key = k else key = Enum.KeyCode.Unknown end
            elseif typeof(key) ~= "EnumItem" then
                key = Enum.KeyCode.Unknown
            end
            
            cfg.key = key
            local key_name = "None"
            if key ~= Enum.KeyCode.Unknown then
                key_name = key.Name
            end
            
            bind_btn.Text = key_name
            library.flags[cfg.flag.."_key"] = key_name
            
            if cfg.bind_conn then cfg.bind_conn:Disconnect() end
            if cfg.key ~= Enum.KeyCode.Unknown then
                cfg.bind_conn = uis.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if (cfg.key.EnumType == Enum.KeyCode and input.KeyCode == cfg.key) or (cfg.key.EnumType == Enum.UserInputType and input.UserInputType == cfg.key) then
                        if type(cfg.callback) == "function" then cfg.callback() end
                    end
                end)
            end
        end

        self:connection(remove_btn.MouseButton1Click, function()
            toggle_bind_input(Enum.KeyCode.Unknown)
        end)

        self:connection(bind_btn.MouseButton1Click, function()
            bind_btn.Text = "..."
            cfg.binding = true
            local conn
            conn = uis.InputBegan:Connect(function(input)
                if cfg.binding then
                    local valid_input = false
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        valid_input = true
                        toggle_bind_input(input.KeyCode)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                        valid_input = true
                        toggle_bind_input(input.UserInputType)
                    end
                    if valid_input then
                        cfg.binding = false
                        if conn then conn:Disconnect() end
                    end
                end
            end)
        end)

        local function update_popup_pos()
            local btn_pos = settings_btn.AbsolutePosition
            local btn_size = settings_btn.AbsoluteSize
            popup_frame.Position = UDim2.new(0, btn_pos.X - 180, 0, btn_pos.Y + btn_size.Y + 4)
        end

        self:connection(settings_btn.MouseButton1Click, function()
            expanded = not expanded
            current_rot += 360
            tween_service:Create(settings_btn, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = current_rot}):Play()
            
            if expanded then
                popup_frame.Visible = true
                popup_frame.Size = UDim2.new(0, 200, 0, 0)
                update_popup_pos()
                update_popup_size()
            else
                tween_service:Create(popup_frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)}):Play()
                task.delay(0.3, function() 
                    if not expanded then 
                        popup_frame.Visible = false 
                    end 
                end)
            end
        end)

        self:connection(settings_btn:GetPropertyChangedSignal("AbsolutePosition"), function()
            if popup_frame.Visible then
                update_popup_pos()
            end
        end)

        toggle_bind_input(cfg.default_key)
        
        library.config_flags[cfg.flag.."_key"] = function(val) toggle_bind_input(val) end
    end

    self:create("TextLabel", {
        Name = "name",
        Parent = btn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, name_width, 1, 0),
        Font = Enum.Font.Gotham,
        Text = cfg.name,
        TextColor3 = self.themes.preset.text,
        TextSize = 13
    })

    self:connection(btn.MouseButton1Click, function()
        tween_service:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = self.themes.preset.accent }):Play()
        task.delay(0.1, function()
            tween_service:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = self.themes.preset.dropdown }):Play()
        end)
        if type(cfg.callback) == "function" then cfg.callback() end
    end)
    if self.elements then table.insert(self.elements, cfg) end
    return cfg
end

function library:keybind(props)
    local cfg = {
        name = props.name or "keybind",
        default = props.default or Enum.KeyCode.Unknown,
        flag = props.flag or props.name or "keybind_"..tostring(math.random(1, 100000)),
        callback = props.callback or function() end,
        binding = false,
        conn = nil
    }

    local bind_frame = self:create("TextButton", {
        Name = cfg.name,
        Parent = self.holder,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    self:create("TextLabel", {
        Name = "name",
        Parent = bind_frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.Gotham,
        Text = cfg.name,
        TextColor3 = self.themes.preset.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local bind_btn = self:create("TextButton", {
        Name = "bind",
        Parent = bind_frame,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 6),
        Size = UDim2.new(0, 60, 0, 20),
        BackgroundColor3 = self.themes.preset.dropdown,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        TextColor3 = self.themes.preset.placeholder,
        TextSize = 12
    })
    self:create("UICorner", { Parent = bind_btn, CornerRadius = UDim.new(0, 4) })
    
    local bind_text = self:create("TextLabel", {
        Name = "text",
        Parent = bind_btn,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        Font = Enum.Font.Gotham,
        Text = "...",
        TextColor3 = self.themes.preset.placeholder,
        TextSize = 12
    })

    local text_service = game:GetService("TextService")

    local function get_key_name(key)
        if typeof(key) == "EnumItem" then
            return key.Name
        end
        return tostring(key)
    end

    local function update_bind_size(text)
        local size = text_service:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(1000, 20))
        local target_width = math.max(50, size.X + 16)
        bind_btn.Size = UDim2.new(0, target_width, 0, 20)
    end

    local function bind_input(key)
        if typeof(key) == "string" then
            local k = Enum.KeyCode[key] or Enum.UserInputType[key]
            if k then key = k else return end
        end
        
        cfg.key = key
        local key_name = get_key_name(key)
        library.flags[cfg.flag] = key_name
        bind_text.Text = key_name
        update_bind_size(key_name)
        
        if cfg.conn then cfg.conn:Disconnect() end
        cfg.conn = uis.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            local pressed = false
            if key.EnumType == Enum.KeyCode and input.KeyCode == key then
                pressed = true
            elseif key.EnumType == Enum.UserInputType and input.UserInputType == key then
                pressed = true
            end
            if pressed then
                if type(cfg.callback) == "function" then cfg.callback() end
            end
        end)
    end

    self:connection(bind_btn.MouseButton1Click, function()
        bind_text.Text = "..."
        update_bind_size("...")
        cfg.binding = true
        local conn
        conn = uis.InputBegan:Connect(function(input)
            if cfg.binding then
                local valid_input = false
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    valid_input = true
                    bind_input(input.KeyCode)
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                    valid_input = true
                    bind_input(input.UserInputType)
                end
                if valid_input then
                    cfg.binding = false
                    if conn then conn:Disconnect() end
                end
            end
        end)
    end)

    bind_input(cfg.default)
    library.config_flags[cfg.flag] = function(val)
        bind_input(val)
    end
    if self.elements then table.insert(self.elements, cfg) end
    return setmetatable(cfg, { __index = self })
end

function library:dropdown(props)
    local cfg = {
        name = props.name or "dropdown",
        options = props.options or {},
        default = props.default or (props.options and props.options[1] or nil),
        flag = props.flag or props.name or "dropdown_"..tostring(math.random(1, 100000)),
        callback = props.callback or function() end,
        open = false,
        multiple = props.multiple or false
    }

    local dd_frame = library:create("Frame", { Name = cfg.name, Parent = self.holder, Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1 })
    library:create("TextLabel", {
        Name = "name",
        Parent = dd_frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = cfg.name,
        TextColor3 = library.themes.preset.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local dd_btn = library:create("TextButton", {
        Name = "select",
        Parent = dd_frame,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = library.themes.preset.dropdown,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    library:create("UICorner", { Parent = dd_btn, CornerRadius = UDim.new(0, 4) })

    local dd_text = library:create("TextLabel", {
        Name = "val",
        Parent = dd_btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "...",
        TextColor3 = library.themes.preset.text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local dd_icon = library:create("ImageLabel", {
        Name = "icon",
        Parent = dd_btn,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -24, 0, 2),
        Size = UDim2.new(0, 20, 0, 20),
        Image = self:get_icon("down")
    })

    local dd_list = library:create("ScrollingFrame", {
        Name = "list",
        Parent = dd_frame,
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = library.themes.preset.dropdown,
        BorderSizePixel = 0,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = library.themes.preset.accent,
        ClipsDescendants = true
    })
    library:create("UICorner", { Parent = dd_list, CornerRadius = UDim.new(0, 4) })
    local dd_layout = library:create("UIListLayout", { Parent = dd_list, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
    library:create("UIPadding", { Parent = dd_list, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })

    function cfg.set(val)
        if cfg.multiple then
            if type(val) == "table" then
                cfg.value = val
            elseif type(val) == "string" and val ~= "" then
                cfg.value = { val }
            else
                cfg.value = {}
            end
            library.flags[cfg.flag] = cfg.value
            dd_text.Text = (#cfg.value > 0 and table.concat(cfg.value, ", ")) or "..."
        else
            if type(val) == "table" then
                val = val[1]
            end
            cfg.value = val
            library.flags[cfg.flag] = val
            dd_text.Text = (val ~= nil and tostring(val)) or "..."
        end
        cfg:update_visuals()
        if type(cfg.callback) == "function" then cfg.callback(cfg.value) end
    end

    function cfg:update_visuals()
        for _, child in next, dd_list:GetChildren() do
            if child:IsA("TextButton") then
                local name = child.Name
                local is_selected = false
                if cfg.multiple then
                    if type(cfg.value) == "table" and table.find(cfg.value, name) then is_selected = true end
                else
                    if cfg.value == name then is_selected = true end
                end
                
                local check = child:FindFirstChild("check")
                local text = child:FindFirstChild("val")
                local icon = child:FindFirstChild("s_icon")
                
                local offset = is_selected and 24 or 0
                
                if check and text then
                    tween_service:Create(check, TweenInfo.new(0.2), {ImageTransparency = is_selected and 0 or 1}):Play()
                    
                    if icon then
                        tween_service:Create(icon, TweenInfo.new(0.2), {Position = UDim2.new(0, 8 + offset, 0, 2)}):Play()
                        tween_service:Create(text, TweenInfo.new(0.2), {Position = UDim2.new(0, 32 + offset, 0, 0), TextColor3 = is_selected and Color3.fromRGB(255, 255, 255) or library.themes.preset.text}):Play()
                    else
                        tween_service:Create(text, TweenInfo.new(0.2), {Position = UDim2.new(0, 8 + offset, 0, 0), TextColor3 = is_selected and Color3.fromRGB(255, 255, 255) or library.themes.preset.text}):Play()
                    end
                end
            end
        end
    end

    local function toggle_dropdown(open)
        cfg.open = open
        local max_h = math.clamp(dd_layout.AbsoluteContentSize.Y, 0, 150)
        local target_h = open and max_h or 0
        
        tween_service:Create(dd_frame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { 
            Size = UDim2.new(1, 0, 0, 42 + target_h) 
        }):Play()
        
        tween_service:Create(dd_icon, TweenInfo.new(0.2), { Rotation = open and 180 or 0 }):Play()
        
        if open then
            dd_list.Visible = true
            dd_list.Size = UDim2.new(1, 0, 0, 0)
            tween_service:Create(dd_list, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, target_h) }):Play()
        else
            tween_service:Create(dd_list, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.new(1, 0, 0, 0) }):Play()
            task.delay(0.2, function() if not cfg.open and dd_list and dd_list.Parent then dd_list.Visible = false end end)
        end
    end

    function cfg:refresh(opts)
        cfg.options = opts or {}
        for _, child in next, dd_list:GetChildren() do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in next, cfg.options do
            local name = opt
            local icon = nil
            if type(opt) == "table" then
                name = opt.name
                icon = opt.icon
            end

            local opt_btn = library:create("TextButton", {
                Name = name,
                Parent = dd_list,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false
            })
            
            local check = library:create("ImageLabel", {
                Name = "check",
                Parent = opt_btn,
                Position = UDim2.new(0, 8, 0, 2),
                Size = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Image = library:get_icon("check"),
                ImageTransparency = 1,
                ZIndex = 2
            })

            local text_x = 8
            if icon then
                local ic = library:create("ImageLabel", {
                    Name = "s_icon",
                    Parent = opt_btn,
                    Position = UDim2.new(0, 8, 0, 2),
                    Size = UDim2.new(0, 16, 0, 16),
                    BackgroundTransparency = 1,
                    Image = library:get_icon(icon)
                })
                text_x = 32
            end

            library:create("TextLabel", {
                Name = "val",
                Parent = opt_btn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, text_x, 0, 0),
                Size = UDim2.new(1, -text_x, 1, 0),
                Font = Enum.Font.Gotham,
                Text = name,
                TextColor3 = library.themes.preset.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            library:connection(opt_btn.MouseButton1Click, function()
                if cfg.multiple then
                    local idx = table.find(cfg.value, name)
                    if idx then
                        table.remove(cfg.value, idx)
                    else
                        table.insert(cfg.value, name)
                    end
                    library.flags[cfg.flag] = cfg.value
                    dd_text.Text = (#cfg.value > 0 and table.concat(cfg.value, ", ")) or "..."
                    cfg:update_visuals()
                    if type(cfg.callback) == "function" then cfg.callback(cfg.value) end
                else
                    cfg.set(name)
                    toggle_dropdown(false)
                end
            end)
        end
        cfg:update_visuals()
    end

    self:connection(dd_btn.MouseButton1Click, function()
        toggle_dropdown(not cfg.open)
    end)

    if cfg.multiple then
        if type(cfg.default) == "table" then
            cfg.value = cfg.default
        elseif type(cfg.default) == "string" and cfg.default ~= "" then
            cfg.value = { cfg.default }
        else
            cfg.value = {}
        end
    else
        if type(cfg.default) == "table" then
            cfg.value = cfg.default[1]
        else
            cfg.value = cfg.default
        end
    end

    cfg:refresh(cfg.options)
    
    if cfg.multiple then
        cfg.set(cfg.value)
    else
        if cfg.default then cfg.set(cfg.default) end
    end
    
    library.config_flags[cfg.flag] = function(val) cfg.set(val) end
    if self.elements then table.insert(self.elements, cfg) end
    return cfg
end

function library:textbox(props)
    local cfg = {
        placeholder = props.placeholder or "enter text...",
        default = props.default or "",
        flag = props.flag or props.name or "textbox_"..tostring(math.random(1, 100000)),
        callback = props.callback or function() end,
        clear_on_focus = props.clear_on_focus or false
    }

    local tb_frame = self:create("TextBox", {
        Name = "textbox",
        Parent = self.holder,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = self.themes.preset.dropdown,
        Text = "",
        PlaceholderText = cfg.placeholder,
        PlaceholderColor3 = self.themes.preset.placeholder,
        Font = Enum.Font.Gotham,
        TextColor3 = self.themes.preset.text,
        TextSize = 12,
        ClearTextOnFocus = cfg.clear_on_focus,
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
    self:create("UICorner", { Parent = tb_frame, CornerRadius = UDim.new(0, 4) })
    self:create("UIPadding", { Parent = tb_frame, PaddingLeft = UDim.new(0, 8) })

    cfg.instance = tb_frame

    self:connection(tb_frame.FocusLost, function()
        library.flags[cfg.flag] = tb_frame.Text
        if type(cfg.callback) == "function" then cfg.callback(tb_frame.Text) end
    end)

    if cfg.default ~= "" then
        tb_frame.Text = cfg.default
        library.flags[cfg.flag] = cfg.default
    end

    library.config_flags[cfg.flag] = function(val)
        if type(val) == "string" then
            tb_frame.Text = val
            library.flags[cfg.flag] = val
            if type(cfg.callback) == "function" then cfg.callback(val) end
        end
    end
    if self.elements then table.insert(self.elements, cfg) end
    return cfg
end

function library:slider(props)
    local cfg = {
        name = props.name or "slider",
        min = props.min or 0,
        max = props.max or 100,
        default = props.default or 50,
        flag = props.flag or props.name or "slider_"..tostring(math.random(1, 100000)),
        callback = props.callback or function() end,
        dragging = false
    }

    local s_frame = self:create("Frame", { Name = cfg.name, Parent = self.holder, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1 })
    self:create("TextLabel", {
        Name = "name",
        Parent = s_frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = cfg.name,
        TextColor3 = self.themes.preset.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local val_label = self:create("TextLabel", {
        Name = "val",
        Parent = s_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 0, 16),
        Font = Enum.Font.Gotham,
        Text = tostring(cfg.default),
        TextColor3 = self.themes.preset.placeholder,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local track = self:create("TextButton", {
        Name = "track",
        Parent = s_frame,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = self.themes.preset.dropdown,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ClipsDescendants = false
    })
    self:create("UICorner", { Parent = track, CornerRadius = UDim.new(1, 0) })

    local fill = self:create("Frame", {
        Name = "fill",
        Parent = track,
        Size = UDim2.new(0.5, 7, 1, 0),
        BackgroundColor3 = self.themes.preset.accent,
        BorderSizePixel = 0,
        ClipsDescendants = false
    })
    self:create("UICorner", { Parent = fill, CornerRadius = UDim.new(1, 0) })

    local knob = self:create("Frame", {
        Name = "knob",
        Parent = track,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2
    })
    self:create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    function cfg.set(val)
        val = math.clamp(val, cfg.min, cfg.max)
        local range = cfg.max - cfg.min
        if range <= 1 then
            val = math.floor(val * 100) / 100
        elseif range <= 10 then
            val = math.floor(val * 10) / 10
        else
            val = math.floor(val)
        end
        
        cfg.value = val
        library.flags[cfg.flag] = val
        val_label.Text = tostring(val)
        
        local percent = (cfg.max == cfg.min) and 0 or (val - cfg.min) / (cfg.max - cfg.min)
        local target_fill_size = UDim2.new(percent, 14 - 14 * percent, 1, 0)
        local target_knob_pos = UDim2.new(percent, 7 - 14 * percent, 0.5, 0)
        
        tween_service:Create(fill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = target_fill_size}):Play()
        tween_service:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = target_knob_pos}):Play()
        
        if type(cfg.callback) == "function" then cfg.callback(val) end
    end

    self:connection(track.MouseButton1Down, function()
        cfg.dragging = true
        local percent = math.clamp((uis:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        cfg.set(cfg.min + (cfg.max - cfg.min) * percent)
    end)
    self:connection(uis.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then cfg.dragging = false end
    end)
    self:connection(uis.InputChanged, function(input)
        if cfg.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            cfg.set(cfg.min + (cfg.max - cfg.min) * percent)
        end
    end)

    cfg.set(cfg.default)
    library.config_flags[cfg.flag] = cfg.set
    if self.elements then table.insert(self.elements, cfg) end
    return cfg
end

function library:colorpicker(props)
    local cfg = {
        name = props.name or "colorpicker",
        default = props.default or Color3.fromRGB(255, 255, 255),
        flag = props.flag or props.name or "colorpicker_"..tostring(math.random(1, 100000)),
        callback = props.callback or function() end
    }

    local cp_frame = self:create("Frame", { Name = cfg.name, Parent = self.holder, Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1 })
    self:create("TextLabel", {
        Name = "name",
        Parent = cp_frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = cfg.name,
        TextColor3 = self.themes.preset.text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local cp_btn = self:create("TextButton", {
        Name = "box",
        Parent = cp_frame,
        Position = UDim2.new(1, -30, 0, 18),
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundColor3 = cfg.default,
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 2,
        AutoButtonColor = false
    })
    self:create("UICorner", { Parent = cp_btn, CornerRadius = UDim.new(0, 4) })

    local popup = self:create("Frame", {
        Name = "popup",
        Parent = self.gui,
        Visible = false,
        Size = UDim2.new(0, 220, 0, 220),
        BackgroundColor3 = self.themes.preset.element_background,
        BorderSizePixel = 0,
        ZIndex = 100
    })
    self:create("UICorner", { Parent = popup, CornerRadius = UDim.new(0, 6) })
    self:create("UIStroke", { Parent = popup, Color = self.themes.preset.stroke, Thickness = 1, ZIndex = 100 })
    self:create("UIPadding", { Parent = popup, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })

    local h, s, v = Color3.toHSV(cfg.default)
    h = (h == 0) and 0.001 or h

    local sv_box = self:create("TextButton", {
        Parent = popup,
        Size = UDim2.new(0, 200, 0, 150),
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 101,
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        AutoButtonColor = false
    })
    self:create("UICorner", { Parent = sv_box, CornerRadius = UDim.new(0, 4) })

    local white_frame = self:create("Frame", {
        Parent = sv_box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 102
    })
    self:create("UIGradient", {
        Parent = white_frame,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
    })

    local black_frame = self:create("Frame", {
        Parent = sv_box,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 103
    })
    self:create("UIGradient", {
        Parent = black_frame,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 90
    })

    local sv_cursor = self:create("Frame", {
        Parent = sv_box,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 104
    })
    self:create("UICorner", { Parent = sv_cursor, CornerRadius = UDim.new(1, 0) })
    self:create("UIStroke", { Parent = sv_cursor, Color = Color3.fromRGB(0, 0, 0), Thickness = 1, ZIndex = 104 })

    local hue_bar = self:create("TextButton", {
        Parent = popup,
        Position = UDim2.new(0, 0, 0, 160),
        Size = UDim2.new(0, 200, 0, 12),
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 101,
        AutoButtonColor = false
    })
    self:create("UICorner", { Parent = hue_bar, CornerRadius = UDim.new(1, 0) })
    self:create("UIGradient", {
        Parent = hue_bar,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
    })

    local hue_cursor = self:create("Frame", {
        Parent = hue_bar,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 6, 0, 16),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 102
    })
    self:create("UICorner", { Parent = hue_cursor, CornerRadius = UDim.new(1, 0) })
    self:create("UIStroke", { Parent = hue_cursor, Color = Color3.fromRGB(0, 0, 0), Thickness = 1, ZIndex = 102 })

    local hex_box = self:create("TextBox", {
        Parent = popup,
        Position = UDim2.new(0, 0, 0, 180),
        Size = UDim2.new(0, 200, 0, 20),
        BackgroundColor3 = self.themes.preset.dropdown,
        Text = "#FFFFFF",
        Font = Enum.Font.Gotham,
        TextColor3 = self.themes.preset.text,
        TextSize = 12,
        BorderSizePixel = 0,
        ZIndex = 101,
        ClearTextOnFocus = false 
    })
    self:create("UICorner", { Parent = hex_box, CornerRadius = UDim.new(0, 4) })

    local function update_color()
        local color = Color3.fromHSV(h, s, v)
        cp_btn.BackgroundColor3 = color
        sv_box.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        sv_cursor.Position = UDim2.new(s, 0, 1-v, 0)
        hue_cursor.Position = UDim2.new(h, 0, 0.5, 0)
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        hex_box.Text = string.format("#%02X%02X%02X", r, g, b)
        library.flags[cfg.flag] = {R=r, G=g, B=b}
        if type(cfg.callback) == "function" then cfg.callback(color) end
    end

    local dragging_sv = false
    local dragging_hue = false

    self:connection(sv_box.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging_sv = true
            local rel_x = math.clamp((input.Position.X - sv_box.AbsolutePosition.X) / sv_box.AbsoluteSize.X, 0, 1)
            local rel_y = math.clamp((input.Position.Y - sv_box.AbsolutePosition.Y) / sv_box.AbsoluteSize.Y, 0, 1)
            s = rel_x
            v = 1 - rel_y
            update_color()
        end
    end)

    self:connection(hue_bar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging_hue = true
            local rel_x = math.clamp((input.Position.X - hue_bar.AbsolutePosition.X) / hue_bar.AbsoluteSize.X, 0, 1)
            h = rel_x
            update_color()
        end
    end)

    self:connection(uis.InputEnded, function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging_sv = false 
            dragging_hue = false 
        end 
    end)

    self:connection(uis.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging_sv then
                local rel_x = math.clamp((input.Position.X - sv_box.AbsolutePosition.X) / sv_box.AbsoluteSize.X, 0, 1)
                local rel_y = math.clamp((input.Position.Y - sv_box.AbsolutePosition.Y) / sv_box.AbsoluteSize.Y, 0, 1)
                s = rel_x
                v = 1 - rel_y
                update_color()
            elseif dragging_hue then
                local rel_x = math.clamp((input.Position.X - hue_bar.AbsolutePosition.X) / hue_bar.AbsoluteSize.X, 0, 1)
                h = rel_x
                update_color()
            end
        end
    end)

    self:connection(hex_box.FocusLost, function()
        local color = hex_to_color(hex_box.Text)
        if color then
            cfg.set(color)
        else
            update_color()
        end
    end)

    local function update_popup_pos()
        local btn_pos = cp_btn.AbsolutePosition
        local btn_size = cp_btn.AbsoluteSize
        local pop_size = popup.AbsoluteSize
        if pop_size.X == 0 then pop_size = Vector2.new(220, 220) end
        
        local target_x = btn_pos.X - pop_size.X - 8
        if target_x < 10 then
            target_x = btn_pos.X + btn_size.X + 8
        end
        
        local target_y = btn_pos.Y + (btn_size.Y / 2) - (pop_size.Y / 2)
        popup.Position = UDim2.new(0, target_x, 0, target_y)
    end

    self:connection(cp_btn.MouseButton1Click, function()
        if popup.Visible then
            popup.Visible = false
            local idx = table.find(library.active_popups, popup)
            if idx then table.remove(library.active_popups, idx) end
        else
            library:close_popups()
            update_popup_pos()
            popup.Visible = true
            table.insert(library.active_popups, popup)
        end
    end)

    self:connection(cp_btn:GetPropertyChangedSignal("AbsolutePosition"), function()
        if popup.Visible then
            update_popup_pos()
        end
    end)

    function cfg.set(color)
        if type(color) == "table" then
            color = Color3.fromRGB(color.R or color[1] or 255, color.G or color[2] or 255, color.B or color[3] or 255)
        end
        h, s, v = Color3.toHSV(color)
        h = (h == 0) and 0.001 or h
        update_color()
    end

    update_color()
    library.config_flags[cfg.flag] = function(val) cfg.set(val) end
    if self.elements then table.insert(self.elements, cfg) end
    return cfg
end

function library:notification(props)
    local cfg = {
        text = props.text or "notification",
        duration = props.duration or 3
    }

    local notif = self:create("Frame", {
        Name = "notif",
        Parent = self.gui,
        Position = UDim2.new(1, -300, 1, -50),
        Size = UDim2.new(0, 220, 0, 50),
        BackgroundColor3 = self.themes.preset.element_background,
        BorderSizePixel = 0
    })
    self:create("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 4) })
    self:create("UIStroke", { Parent = notif, Color = self.themes.preset.stroke, Thickness = 1, Transparency = 0.5 })

    local accent_bar = self:create("Frame", {
        Name = "accent_bar",
        Parent = notif,
        Size = UDim2.new(0, 3, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = self.themes.preset.accent,
        BorderSizePixel = 0
    })
    self:create("UICorner", { Parent = accent_bar, CornerRadius = UDim.new(1, 0) })

    self:create("TextLabel", {
        Name = "text",
        Parent = notif,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -25, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Font = Enum.Font.Gotham,
        Text = cfg.text,
        TextColor3 = self.themes.preset.text,
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    table.insert(self.active_notifs, notif)

    local function update_positions()
        for i, n in ipairs(library.active_notifs) do
            local target_pos = UDim2.new(1, -240, 1, -60 - ((i-1) * 60))
            tween_service:Create(n, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = target_pos }):Play()
        end
    end
    update_positions()

    task.delay(cfg.duration, function()
        tween_service:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 1, notif.Position.Y.Offset)
        }):Play()
        task.delay(0.5, function() 
            if notif then 
                notif:Destroy() 
                table.remove(library.active_notifs, table.find(library.active_notifs, notif))
                update_positions()
            end 
        end)
    end)
end

getgenv().library = library
return library
