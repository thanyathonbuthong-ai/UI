-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)--!nocheck
-- Ethos Dex. Running it again closes the previous window first.

-- The Ethos modules carry Luraph annotations; outside a Luraph build they do nothing.
if not LPH_OBFUSCATED then
	local env = getfenv()
	local function pass(...)
		return ...
	end
	env.LPH_ATTRIBUTES = env.LPH_ATTRIBUTES
		or function()
		end
	env.VM = env.VM or pass
	env.PRESET = env.PRESET or pass
	env.ERROR_HANDLING = env.ERROR_HANDLING or pass
	env.UNROLL = env.UNROLL or pass
	env.NONE = env.NONE
	env.FAST = env.FAST
end

local genv = if typeof(getgenv) == "function" then getgenv() else _G

local previous = genv.__ETHOS_DEX
if type(previous) == "table" and type(previous.Destroy) == "function" then
	pcall(previous.Destroy)
end

local App = require(script.app)
local Internal = require(script.packages.internal)
local Images = require(script.ui.images)

local app = App.start()

local handle = {}
function handle.Destroy()
	if genv.__ETHOS_DEX == handle then
		genv.__ETHOS_DEX = nil
	end
	app.Destroy()
	pcall(function()
		Images:cleanup()
	end)
	pcall(function()
		Internal.Scope:doCleanup()
	end)
end
handle.Gui = app.Gui
handle.State = app.State
handle.Tree = app.Tree
handle.Window = app.Window
handle.Version = "1.0.0"

genv.__ETHOS_DEX = handle
return handle

end)() end,
    function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...)--!nocheck
-- Builds the GUI: the window, the explorer, and the panel with its topbar, tabs and pages.

local Root = script.Parent
local Fusion = require(Root.packages.fusion)
local States = require(Root.packages.states)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local TabPill = require(Root.ui.tabPill)
local Env = require(Root.core.env)
local Api = require(Root.core.api)
local Path = require(Root.core.path)
local Settings = require(Root.core.settings)
local State = require(script.state)
local Menu = require(script.menu)
local Toast = require(script.toast)
local Picker = require(script.picker)
local Actions = require(script.actions)
local Window = require(script.window)
local Explorer = require(script.explorer)
local Properties = require(script.properties)
local ScriptViewer = require(script.scriptViewer)
local Console = require(script.console)
local Preview = require(script.preview)
local SettingsPage = require(script.settingsPage)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local UserInputService = Env.service("UserInputService")

local TOPBAR = 46
local TABS = { "Properties", "Script", "Console", "Preview" }
local TAB_TH = { Properties = "พรอเพอร์ตี้", Script = "สคริปต์", Console = "คอนโซล", Preview = "ตัวอย่าง" }

local App = {}

local function breadcrumb(scope)
	local holder = scope:New("Frame")({
		Name = "Breadcrumb",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		[Children] = scope:New("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	local partScope = nil
	local function rebuild()
		if partScope then
			Fusion.doCleanup(partScope)
		end
		partScope = scope:innerScope()
		local first = State.first()
		local chain = {}
		if first then
			local ok, result = pcall(Path.chain, first, game)
			chain = if ok then result else { first }
		end
		local start = math.max(1, #chain - 2)
		local order = 0
		local function add(child)
			order += 1
			child.LayoutOrder = order
			child.Parent = holder
		end
		if first == nil then
			add(
				Controls.Label(
					partScope,
					{
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromOffset(0, 30),
						Text = "ยังไม่ได้เลือกอะไร",
						TextSize = 13,
						TextColor3 = Theme.Muted,
						TextTruncate = Enum.TextTruncate.None,
					}
				)
			)
			return
		end
		if start > 1 then
			add(
				Controls.Label(
					partScope,
					{
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromOffset(0, 30),
						Text = "…",
						TextSize = 13,
						TextColor3 = Theme.Muted,
						TextTruncate = Enum.TextTruncate.None,
					}
				)
			)
		end
		for index = start, #chain do
			local object = chain[index]
			if index > start or start > 1 then
				add(Controls.Icon(partScope, "chevron-right", 12, { ImageColor3 = Theme.Faint }))
			end
			local last = index == #chain
			local ok, name = pcall(function()
				return object.Name
			end)
			add(
				partScope:New("TextButton")({
					Name = "Crumb",
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 30),
					BackgroundTransparency = 1,
					Text = if ok then name else "?",
					FontFace = if last then Theme.Title else Theme.Body,
					TextSize = 13,
					TextColor3 = if last then Theme.Ink else Theme.Muted,
					[OnEvent("Activated")] = function()
						State.Hooks.reveal(object)
					end,
					[Children] = scope:New("UISizeConstraint")({ MaxSize = Vector2.new(180, 30) }),
				})
			)
		end
	end
	table.insert(scope, scope:Observer(State.Selection):onBind(rebuild))
	return holder
end

function App.start()
	local scope = Fusion.scoped(Fusion)

	-- Theme follows the setting.
	States.Theme:set(Settings.get("Theme"))
	table.insert(
		scope,
		scope:Observer(Settings.state("Theme")):onChange(function()
			States.Theme:set(Settings.get("Theme"))
		end)
	)

	local gui = Instance.new("ScreenGui")
	gui.Name = Env.safeName(game:GetService("HttpService"):GenerateGUID(false))
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 10000
	gui.IgnoreGuiInset = false
	Env.protect(gui)
	gui.Parent = Env.guiParent()
	table.insert(scope, gui)

	local layer = scope:New("Frame")({
		Name = "Layer",
		Parent = gui,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})
	Menu.setLayer(
		layer,
		function()
			return 1
		end
	)
	Toast.setLayer(layer)
	Picker.setLayer(layer)

	local explorer = Explorer.new(scope)

	State.Hooks.insert = function(parent)
		if not Api.hasDump() then
			Toast.show("การแทรกอ็อบเจกต์ต้องใช้ Roblox API ซึ่งโหลดไม่สำเร็จ", "error")
			return
		end
		Picker.open({
			Title = "แทรกลงใน " .. parent.Name,
			Items = Api.creatable(),
			ClassIcons = true,
			OnPick = function(className)
				Actions.insert(parent, className)
			end,
		})
	end

	-- Pages
	local pages = {
		Properties = Properties.new(scope:innerScope()).Instance,
		Script = ScriptViewer.new(scope:innerScope()).Instance,
		Console = Console.new(scope:innerScope()).Instance,
		Preview = Preview.new(scope:innerScope()).Instance,
		Settings = SettingsPage.new(scope:innerScope()).Instance,
	}
	local content = scope:New("Frame")({
		Name = "Content",
		Position = UDim2.fromOffset(0, TOPBAR + 38),
		Size = UDim2.new(1, 0, 1, -(TOPBAR + 38)),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	})
	for name, page in pages do
		page.Parent = content
		scope:Hydrate(page)({
			Visible = scope:Computed(function(use)
				return use(State.Tab) == name
			end),
		})
	end

	local tabs = {}
	for index, name in TABS do
		table.insert(
			tabs,
			TabPill(
				scope,
				TAB_TH[name] or name,
				index,
				scope:Computed(function(use)
					return use(State.Tab) == name
				end),
				function()
					State.Tab:set(name)
				end
			)
		)
	end

	local window -- assigned below; the topbar's buttons call into it
	local function topButton(name, icon, order, onActivated, visible)
		return Controls.IconButton(
			scope,
			{
				Name = name,
				Icon = icon,
				Size = 30,
				LayoutOrder = order,
				Visible = visible,
				OnActivated = onActivated,
			}
		)
	end

	local destroy
	local maximizedIcon = scope:Value("maximize-2")
	local topbar = scope:New("Frame")({
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, TOPBAR),
		BackgroundTransparency = 1,
		Active = true,
		[Children] = {
			Controls.IconButton(
				scope,
				{
					Name = "Back",
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 8, 0.5, 0),
					Icon = "chevron-left",
					Size = 30,
					Visible = State.Compact,
					OnActivated = function()
						State.MobileView:set("explorer")
					end,
				}
			),
			scope:New("Frame")({
				Name = "Crumbs",
				Position = scope:Computed(function(use)
					return UDim2.fromOffset(if use(State.Compact) then 44 else 16, 8)
				end),
				Size = scope:Computed(function(use)
					return UDim2.new(1, -(if use(State.Compact) then 44 else 16) - 176, 0, 30)
				end),
				BackgroundTransparency = 1,
				[Children] = breadcrumb(scope),
			}),
			scope:New("Frame")({
				Name = "Actions",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(0, 30),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				[Children] = {
					scope:New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					topButton(
						"More",
						"ellipsis",
						1,
						function()
							local selection = State.selection()
							if #selection == 0 then
								Toast.show("เลือกบางอย่างก่อน")
								return
							end
							local button = topbar.Actions.More
							local at = button.AbsolutePosition
								+ Vector2.new(-190, button.AbsoluteSize.Y + 4)
							Menu.open(
								at,
								Actions.entries(
									selection,
									{
										Expand = function()
											for _, object in State.selection() do
												State.Hooks.reveal(object, true)
											end
										end,
										Collapse = State.Hooks.collapseAll,
									}
								)
							)
						end
					),
					topButton(
						"Settings",
						"settings",
						2,
						function()
							State.open(
								if peek(State.Tab) == "Settings" then "Properties" else "Settings"
							)
						end
					),
					topButton(
						"Minimize",
						"minus",
						3,
						function()
							window.Toggle()
						end
					),
					topButton(
						"Maximize",
						maximizedIcon,
						4,
						function()
							window.Maximized:set(not peek(window.Maximized))
							maximizedIcon:set(
								if peek(window.Maximized) then "minimize-2" else "maximize-2"
							)
						end,
						scope:Computed(function(use)
							return not use(State.Compact)
						end)
					),
					topButton(
						"Close",
						"x",
						5,
						function()
							destroy()
						end
					),
				},
			}),
		},
	})

	local tabRow = scope:New("ScrollingFrame")({
		Name = "Tabs",
		Position = UDim2.fromOffset(10, TOPBAR),
		Size = UDim2.new(1, -20, 0, 34),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		[Children] = {
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			tabs,
		},
	})

	local panel = scope:New("Frame")({
		Name = "PanelContent",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = { topbar, tabRow, content },
	})

	window = Window.new(
		scope,
		{
			Layer = layer,
			Explorer = explorer.Instance,
			Panel = panel,
			Scale = function()
				return 1
			end,
		}
	)
	window.DragHandle(explorer.Header)
	window.DragHandle(topbar)

	-- Keybind
	table.insert(
		scope,
		UserInputService.InputBegan:Connect(function(input, processed)
			if processed or UserInputService:GetFocusedTextBox() then
				return
			end
			local key = Settings.get("ToggleKey")
			if input.KeyCode.Name == key then
				window.Toggle()
			end
		end)
	)

	-- The first selected part or model glows in the world.
	local glow = Instance.new("Highlight")
	glow.Name = "Selection"
	glow.FillTransparency = 0.85
	glow.OutlineTransparency = 0
	glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	glow.Parent = gui
	table.insert(scope, glow)
	table.insert(
		scope,
		scope:Observer(State.Selection):onBind(function()
			local first = State.first()
			local ok, isWorld = pcall(function()
				return first ~= nil
					and (first:IsA("BasePart") or first:IsA("Model") and not first:IsA("WorldRoot"))
					and first:IsDescendantOf(workspace)
			end)
			glow.Adornee = if ok and isWorld then first else nil
			glow.OutlineColor = peek(Theme.Accent)
			glow.FillColor = peek(Theme.Accent)
		end)
	)

	-- The API loads in the background; the tree re-sorts by Studio's order when it lands.
	task.spawn(function()
		Api.load()
		if Api.Status == "failed" then
			Toast.show(tostring(Api.Problem), "error")
		end
		if State.Hooks.rebuildTree then
			State.Hooks.rebuildTree()
		end
	end)

	local destroyed = false
	destroy = function()
		if destroyed then
			return
		end
		destroyed = true
		Menu.close()
		Picker.close()
		local tree = explorer.Tree()
		if tree then
			tree:destroy()
		end
		Fusion.doCleanup(scope)
		if gui.Parent then
			gui:Destroy()
		end
	end

	return {
		Gui = gui,
		Window = window,
		Destroy = destroy,
		State = State,
		Tree = explorer.Tree,
	}
end

return App

end)() end,
    function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)--!nocheck
-- What can be done to selected instances: the context menu's entries and their effects.

local Root = script.Parent.Parent
local Env = require(Root.core.env)
local Api = require(Root.core.api)
local Path = require(Root.core.path)
local Settings = require(Root.core.settings)
local State = require(script.Parent.state)
local Toast = require(script.Parent.toast)

local Actions = {}

local UNSUPPORTED = "Not on this executor"

local function scriptLike(object): boolean
	return object:IsA("LuaSourceContainer")
end

local function folderFor(kind: string): string
	return `{Env.ROOT}/{kind}/{game.PlaceId}`
end

function Actions.copy(text: string, what: string)
	if Env.clipboard(text) then
		Toast.show(`คัดลอก {what} แล้ว`, "success")
	else
		Toast.show("Executor นี้ไม่มีคลิปบอร์ด", "error")
	end
end

function Actions.path(object): string
	return Path.of(object, game, State.LocalPlayer)
end

function Actions.delete(list)
	local count = 0
	for _, object in list do
		if pcall(object.Destroy, object) then
			count += 1
		end
	end
	State.select({})
	Toast.show(
		if count == #list then `ลบแล้ว {count} รายการ` else `ลบแล้ว {count} จาก {#list} รายการ`,
		if count == #list then "success" else "error"
	)
end

function Actions.duplicate(list)
	local clones = {}
	for _, object in list do
		local ok, clone = pcall(function()
			local archivable = object.Archivable
			object.Archivable = true
			local copy = object:Clone()
			object.Archivable = archivable
			copy.Parent = object.Parent
			return copy
		end)
		if ok and clone then
			table.insert(clones, clone)
		end
	end
	if #clones > 0 then
		State.select(clones)
		State.Hooks.reveal(clones[1], true)
	else
		Toast.show("ทำสำเนาไม่ได้", "error")
	end
end

function Actions.group(list)
	local ok, model = pcall(function()
		local group = Instance.new("Model")
		group.Parent = list[1].Parent
		for _, object in list do
			object.Parent = group
		end
		return group
	end)
	if ok then
		State.Hooks.reveal(model)
	else
		Toast.show("จัดกลุ่มไม่ได้: " .. tostring(model), "error")
	end
end

function Actions.ungroup(list)
	local moved = {}
	for _, object in list do
		pcall(function()
			for _, child in object:GetChildren() do
				child.Parent = object.Parent
				table.insert(moved, child)
			end
			object:Destroy()
		end)
	end
	State.select(moved)
end

function Actions.teleport(object)
	local character = State.LocalPlayer.Character
	if character == nil then
		Toast.show("คุณไม่มีตัวละคร", "error")
		return
	end
	local ok, problem = pcall(function()
		local pivot = if object:IsA("PVInstance") then object:GetPivot()
			else object.Parent:GetPivot()
		character:PivotTo(pivot + Vector3.new(0, 4, 0))
	end)
	if not ok then
		Toast.show("เทเลพอร์ตไม่ได้: " .. tostring(problem), "error")
	end
end

function Actions.saveScript(object)
	Toast.show("กำลังดีคอมไพล์ " .. object.Name)
	local source, problem = Env.decompile(object, Settings.get("Decompiler"))
	if source == nil then
		Toast.show("ดีคอมไพล์ไม่ได้: " .. tostring(problem), "error")
		return
	end
	local file = `{folderFor("scripts")}/{Env.safeName(object.Name)}.lua`
	local header = `-- {Actions.path(object)}\n-- Decompiled by Ethos Dex\n\n`
	local ok, failure = Env.writeFile(file, header .. source)
	Toast.show(
		if ok then "บันทึกที่ workspace/" .. file else "บันทึกไม่ได้: " .. tostring(failure),
		if ok then "success" else "error"
	)
end

function Actions.saveBytecode(object)
	local bytecode, problem = Env.bytecode(object)
	if bytecode == nil then
		Toast.show(tostring(problem), "error")
		return
	end
	local file = `{folderFor("bytecode")}/{Env.safeName(object.Name)}.luac`
	local ok, failure = Env.writeFile(file, bytecode)
	Toast.show(
		if ok then "บันทึกที่ workspace/" .. file else "บันทึกไม่ได้: " .. tostring(failure),
		if ok then "success" else "error"
	)
end

function Actions.saveInstance(list)
	local first = list[1]
	local name = if first == game then `place-{game.PlaceId}` else Env.safeName(first.Name)
	local file = `{folderFor("saves")}/{name}`
	Env.ensureFolder(folderFor("saves"))
	Toast.show("กำลังบันทึก " .. (if first == game then "แมพ" else first.Name) .. "...")
	task.spawn(function()
		local options = {
			FilePath = file,
			Decompile = Settings.get("SaveDecompile"),
			ShowStatus = true,
			SafeMode = false,
		}
		if first ~= game then
			options.Object = if #list == 1 then first else nil
			options.ExtraInstances = if #list > 1 then list else nil
			options.IsModel = true
		end
		local ok, problem = Env.saveInstance(options)
		Toast.show(
			if ok then "บันทึกที่ workspace/" .. file else "บันทึกไม่ได้: " .. tostring(problem),
			if ok then "success" else "error"
		)
	end)
end

local function fireTarget(object, className: string)
	if object:IsA(className) then
		return object
	end
	return object:FindFirstChildWhichIsA(className)
end

-- The menu for a selection. `tree` has Expand(deep) and Collapse().
function Actions.entries(list, tree)
	local first = list[1]
	if first == nil then
		return {}
	end
	local single = #list == 1
	local entries = {}
	local function add(entry)
		table.insert(entries, entry)
	end
	local function divider()
		if #entries > 0 and entries[#entries] ~= "divider" then
			table.insert(entries, "divider")
		end
	end

	add({
		Text = "คัดลอกพาธ",
		Icon = "copy",
		OnActivated = function()
			local paths = {}
			for _, object in list do
				table.insert(paths, Actions.path(object))
			end
			Actions.copy(table.concat(paths, "\n"), if single then "path" else `{#list} paths`)
		end,
	})
	add({
		Text = "คัดลอกชื่อ",
		Icon = "type",
		OnActivated = function()
			Actions.copy(first.Name, "name")
		end,
	})
	divider()

	if single then
		add({
			Text = "เปลี่ยนชื่อ",
			Icon = "pencil",
			Detail = "F2",
			OnActivated = function()
				State.Hooks.rename(first)
			end,
		})
	end
	add({
		Text = "ทำสำเนา",
		Icon = "copy-plus",
		OnActivated = function()
			Actions.duplicate(list)
		end,
	})
	add({
		Text = "จัดกลุ่ม",
		Icon = "group",
		OnActivated = function()
			Actions.group(list)
		end,
	})
	if first:IsA("Model") or first:IsA("Folder") then
		add({
			Text = "เลิกจัดกลุ่ม",
			Icon = "ungroup",
			OnActivated = function()
				Actions.ungroup(list)
			end,
		})
	end
	add({
		Text = "แทรกอ็อบเจกต์",
		Icon = "plus",
		OnActivated = function()
			State.Hooks.insert(first)
		end,
	})
	add({
		Text = if single then "Delete" else `Delete {#list}`,
		Icon = "trash-2",
		Danger = true,
		Detail = "Del",
		OnActivated = function()
			Actions.delete(list)
		end,
	})
	divider()

	add({
		Text = "เลือกลูกทั้งหมด",
		Icon = "list-tree",
		OnActivated = function()
			State.Hooks.selectChildren(list)
		end,
	})
	if first.Parent and first.Parent ~= game then
		add({
			Text = "ไปที่อ็อบเจกต์แม่",
			Icon = "corner-left-up",
			OnActivated = function()
				State.Hooks.reveal(first.Parent)
			end,
		})
	end
	add({
		Text = "ขยายทั้งหมด",
		Icon = "chevrons-up-down",
		OnActivated = function()
			tree.Expand(true)
		end,
	})
	add({
		Text = "ย่อทั้งหมด",
		Icon = "chevrons-down-up",
		OnActivated = function()
			tree.Collapse()
		end,
	})
	divider()

	if scriptLike(first) then
		local can = Env.canDecompile(first)
		add({
			Text = "ดูสคริปต์",
			Icon = "code",
			Disabled = if can then nil else UNSUPPORTED,
			Detail = if can then nil else "Unsupported",
			OnActivated = function()
				State.ScriptTarget:set(first)
				State.open("Script")
			end,
		})
		add({
			Text = "บันทึกสคริปต์",
			Icon = "download",
			Disabled = if can and Env.canWrite() then nil else UNSUPPORTED,
			OnActivated = function()
				Actions.saveScript(first)
			end,
		})
		if Env.has("getscriptbytecode") then
			add({
				Text = "บันทึกไบต์โค้ด",
				Icon = "binary",
				Disabled = if Env.canWrite() then nil else UNSUPPORTED,
				OnActivated = function()
					Actions.saveBytecode(first)
				end,
			})
		end
	end
	if first:IsA("PVInstance") and not first:IsA("WorldRoot") then
		add({
			Text = "ตัวอย่าง",
			Icon = "box",
			OnActivated = function()
				State.PreviewTarget:set(first)
				State.open("Preview")
			end,
		})
		add({
			Text = "เทเลพอร์ตไปที่",
			Icon = "map-pin",
			OnActivated = function()
				Actions.teleport(first)
			end,
		})
	end
	local click = fireTarget(first, "ClickDetector")
	if click then
		add({
			Text = "สั่งงาน Click Detector",
			Icon = "mouse-pointer-click",
			Disabled = if Env.has("fireclickdetector") then nil else UNSUPPORTED,
			OnActivated = function()
				local ok, problem = Env.fire("fireclickdetector", click)
				Toast.show(
					if ok then "สั่งงานแล้ว" else tostring(problem),
					if ok then "success" else "error"
				)
			end,
		})
	end
	local prompt = fireTarget(first, "ProximityPrompt")
	if prompt then
		add({
			Text = "สั่งงาน Proximity Prompt",
			Icon = "hand",
			Disabled = if Env.has("fireproximityprompt") then nil else UNSUPPORTED,
			OnActivated = function()
				local ok, problem = Env.fire("fireproximityprompt", prompt)
				Toast.show(
					if ok then "สั่งงานแล้ว" else tostring(problem),
					if ok then "success" else "error"
				)
			end,
		})
	end
	if first:IsA("BasePart") and first:FindFirstChildWhichIsA("TouchTransmitter") then
		add({
			Text = "สั่งงาน Touch",
			Icon = "pointer",
			Disabled = if Env.has("firetouchinterest") then nil else UNSUPPORTED,
			OnActivated = function()
				local ok, problem = Env.fire("firetouchinterest", first)
				Toast.show(
					if ok then "สั่งงานแล้ว" else tostring(problem),
					if ok then "success" else "error"
				)
			end,
		})
	end
	if first:IsA("Player") then
		add({
			Text = "เลือกตัวละคร",
			Icon = "person-standing",
			OnActivated = function()
				if first.Character then
					State.Hooks.reveal(first.Character)
				end
			end,
		})
	end
	divider()

	add({
		Text = "บันทึกเป็นไฟล์",
		Icon = "save",
		Disabled = if Env.canWrite() and (Env.has("saveinstance") or Env.has("loadstring")) then nil
			else UNSUPPORTED,
		OnActivated = function()
			Actions.saveInstance(list)
		end,
	})
	add({
		Text = "คัดลอกไปคอนโซล",
		Icon = "terminal",
		OnActivated = function()
			State.Hooks.consoleInsert(`local object = {Actions.path(first)}\n`)
			State.open("Console")
		end,
	})
	add({
		Text = "เปิดหน้า API",
		Icon = "external-link",
		OnActivated = function()
			local class = first.ClassName
			Actions.copy(
				"https://create.roblox.com/docs/reference/engine/classes/" .. class,
				"API page link"
			)
		end,
	})
	if entries[#entries] == "divider" then
		table.remove(entries)
	end
	return entries
end

-- Instance.new under `parent`, then selects it.
function Actions.insert(parent, className: string)
	local ok, object = pcall(function()
		local made = Instance.new(className)
		made.Parent = parent
		return made
	end)
	if ok then
		State.Hooks.reveal(object)
	else
		Toast.show(`สร้าง {className} ไม่ได้: {object}`, "error")
	end
end

Actions.creatable = Api.creatable

return Actions

end)() end,
    function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)--!nocheck
--[[
	Studio's class icons: the 16px strip every Roblox client ships, indexed by ReflectionMetadata's
	ExplorerImageIndex, so nothing is uploaded and it works on every executor. The strip is 2352px
	wide and the engine ignores ImageRectOffset past 1024px, so instead of cropping, the whole strip
	slides inside a 16px clipping frame.
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Api = require(Root.core.api)

local IMAGE = "rbxasset://textures/ClassImages.PNG"
local SIZE = 16
local COUNT = 147

local ClassIcon = {}

-- For when ReflectionMetadata couldn't load; indices from it.
local FALLBACK = {
	Folder = 77,
	Model = 2,
	Part = 1,
	Script = 6,
	LocalScript = 18,
	ModuleScript = 76,
	Players = 21,
	Player = 12,
	Workspace = 19,
	Camera = 5,
}

function ClassIcon.index(className: string): number
	local index = Api.icon(className) or FALLBACK[className] or 0
	return math.clamp(index, 0, COUNT - 1)
end

function ClassIcon.apply(frame: Frame, className: string)
	frame.Strip.Position = UDim2.fromOffset(-ClassIcon.index(className) * SIZE, 0)
end

function ClassIcon.new(scope, className: string, props)
	props = props or {}
	props.Name = props.Name or "ClassIcon"
	props.Size = UDim2.fromOffset(SIZE, SIZE)
	props.BackgroundTransparency = 1
	props.ClipsDescendants = true
	props[Fusion.Children] = scope:New("ImageLabel")({
		Name = "Strip",
		Size = UDim2.fromOffset(SIZE * COUNT, SIZE),
		BackgroundTransparency = 1,
		Image = IMAGE,
	})
	local frame = scope:New("Frame")(props)
	ClassIcon.apply(frame, className)
	return frame
end

return table.freeze(ClassIcon)

end)() end,
    function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)--!nocheck
--[[
	A Luau console. Code runs through the executor's loadstring with `sel` (the first selected
	instance) and `sels` (all of them) defined, and its print/warn/error land here as well as in
	the game's output. Game output can be shown too.
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Fonts = require(Root.ui.fonts)
local CodeView = require(Root.ui.codeView)
local Env = require(Root.core.env)
local Values = require(Root.core.values)
local State = require(script.Parent.state)

local Children = Fusion.Children
local peek = Fusion.peek

local LogService = Env.service("LogService")
local UserInputService = Env.service("UserInputService")

local LIMIT = 250

local Console = {}

function Console.new(scope)
	local code = scope:Value("print(sel)\n")
	local gameOutput = scope:Value(false)
	local order = 0
	local entries = {}

	local log = scope:New("ScrollingFrame")({
		Name = "Output",
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Ink,
		ScrollBarImageTransparency = 0.8,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
			}),
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
			}),
		},
	})

	local function push(text: string, kind: string)
		order += 1
		local color = if kind == "error" then Theme.Danger
			elseif kind == "warn" then Theme.Caution
			elseif kind == "input" then Theme.Muted
			elseif kind == "game" then Theme.Faint
			else Theme.Ink2
		local label = scope:New("TextLabel")({
			Name = "Entry",
			Parent = log,
			LayoutOrder = order,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
			FontFace = Fonts.Mono,
			TextSize = 12,
			TextColor3 = color,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = string.sub(text, 1, 4000),
		})
		table.insert(entries, label)
		while #entries > LIMIT do
			table.remove(entries, 1):Destroy()
		end
		task.defer(function()
			log.CanvasPosition = Vector2.new(0, math.huge)
		end)
	end

	local function show(...)
		local parts = table.pack(...)
		for index = 1, parts.n do
			local value = parts[index]
			parts[index] = if type(value) == "string" then value else Values.format(value)
		end
		return table.concat(parts, "  ", 1, parts.n)
	end

	local function run()
		local source = peek(code)
		if string.match(source, "^%s*$") then
			return
		end
		push("> " .. (string.gsub(source, "\n", "\n  ")), "input")
		local fn, problem = Env.compile(source, "=EthosDex")
		if fn == nil then
			push(tostring(problem), "error")
			return
		end
		local selection = State.selection()
		local env = setmetatable(
			{
				sel = selection[1],
				sels = selection,
				print = function(...)
					push(show(...), "print")
					print(...)
				end,
				warn = function(...)
					push(show(...), "warn")
					warn(...)
				end,
			},
			{ __index = getfenv(0) }
		)
		pcall(setfenv, fn, env)
		task.spawn(function()
			local results = table.pack(xpcall(fn, debug.traceback))
			if not results[1] then
				push(tostring(results[2]), "error")
			elseif results.n > 1 then
				push("< " .. show(table.unpack(results, 2, results.n)), "print")
			end
		end)
	end

	table.insert(
		scope,
		LogService.MessageOut:Connect(function(message, messageType)
			if not peek(gameOutput) then
				return
			end
			push(
				message,
				if messageType == Enum.MessageType.MessageError then "error"
					elseif messageType == Enum.MessageType.MessageWarning then "warn"
					else "game"
			)
		end)
	)

	State.Hooks.consoleInsert = function(text)
		code:set(text .. peek(code))
	end

	local editor, parts = CodeView.new(
		scope,
		{
			Name = "Input",
			Text = code,
			Editable = true,
			Placeholder = "Luau — sel คืออ็อบเจกต์ที่เลือก, sels คือทั้งหมดที่เลือก",
		}
	)
	editor.AnchorPoint = Vector2.new(0, 1)
	editor.Position = UDim2.new(0, 10, 1, -52)
	editor.Size = UDim2.new(1, -20, 0.42, -40)

	table.insert(
		scope,
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Return
				and parts.Box:IsFocused()
				and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
					or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
				task.defer(run)
			end
		end)
	)

	local output = scope:New("Frame")({
		Name = "Log",
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 0.58, -22),
		BackgroundColor3 = Theme.Ink,
		ClipsDescendants = true,
		[Children] = {
			Controls.Fill(scope, scope:Value(0.04)),
			Controls.Edge(scope, nil, UDim.new(0, 12)),
			log,
		},
	})

	local gameOutputT = Controls.animate(
		scope,
		scope:Computed(function(use)
			return if use(gameOutput) then 1 else 0
		end),
		Controls.snap(0.25)
	)

	local bar = scope:New("Frame")({
		Name = "Bar",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -10),
		Size = UDim2.new(1, -20, 0, 32),
		BackgroundTransparency = 1,
		[Children] = {
			Controls.Button(
				scope,
				{
					Name = "Run",
					Text = "รัน",
					Icon = "play",
					Height = 32,
					OnActivated = run,
				}
			),
			Controls.Button(
				scope,
				{
					Name = "Clear",
					Position = UDim2.fromOffset(86, 0),
					Text = "ล้าง",
					Icon = "trash-2",
					Ghost = true,
					Height = 32,
					OnActivated = function()
						for _, entry in entries do
							entry:Destroy()
						end
						table.clear(entries)
					end,
				}
			),
			scope:New("TextButton")({
				Name = "GameOutput",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromOffset(150, 32),
				BackgroundTransparency = 1,
				Text = "",
				[Fusion.OnEvent("Activated")] = function()
					gameOutput:set(not peek(gameOutput))
				end,
				[Children] = {
					Controls.Label(
						scope,
						{
							Size = UDim2.new(1, -46, 1, 0),
							Text = "เอาต์พุตของเกม",
							TextSize = 13,
							FontFace = Theme.Body,
							TextColor3 = Theme.Ink2,
							TextXAlignment = Enum.TextXAlignment.Right,
						}
					),
					Controls.Switch(scope, gameOutputT, scope:Value(0)),
				},
			}),
		},
	})

	local pane = scope:New("Frame")({
		Name = "Console",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = {
			output,
			editor,
			bar,
			Controls.Label(
				scope,
				{
					Name = "Unsupported",
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, -16, 1, -48),
					Size = UDim2.fromOffset(260, 16),
					Text = "Executor นี้ไม่มี loadstring",
					TextSize = 11,
					FontFace = Theme.Body,
					TextColor3 = Theme.Danger,
					TextXAlignment = Enum.TextXAlignment.Right,
					Visible = not Env.has("loadstring"),
				}
			),
		},
	})
	push(
		"Ethos Dex console. Ctrl+Enter runs. sel = selected instance, sels = all selected.",
		"input"
	)
	return { Instance = pane }
end

return Console

end)() end,
    function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)--!nocheck
--[[
	The explorer column: brand header, search, the virtualized tree and the credits footer.
	Rows are a fixed pool, as many as fit on screen, re-bound to whichever nodes are in view, so
	the cost doesn't grow with the game. A render happens when the tree reports a change, on
	scroll, and every half second (collapsed nodes don't listen, so their arrows refresh then).
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Env = require(Root.core.env)
local Api = require(Root.core.api)
local Tree = require(Root.core.tree)
local Search = require(Root.core.search)
local Settings = require(Root.core.settings)
local State = require(script.Parent.state)
local ClassIcon = require(script.Parent.classIcon)
local Menu = require(script.Parent.menu)
local Toast = require(script.Parent.toast)
local Actions = require(script.Parent.actions)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local UserInputService = Env.service("UserInputService")
local RunService = Env.service("RunService")

local ROW = State.ROW
local INDENT = 14
local NIL_ROOT = Tree.NIL_ROOT
local DISCORD = "jasha.n"

local Explorer = {}

function Explorer.new(scope)
	local tree = nil
	local dirty = true
	local hovering = false
	local anchor = nil -- instance shift-click ranges start from
	local lastClick = { Instance = nil, At = 0 }

	local function buildTree()
		if tree then
			tree:destroy()
		end
		local nilSource = if Env.has("getnilinstances") and Settings.get("ShowNil") then Env.nilInstances
			else nil
		tree = Tree.new({
			Game = game,
			Roots = function()
				return game:GetChildren()
			end,
			Order = Api.order,
			NilInstances = nilSource,
			OnDirty = function()
				dirty = true
			end,
		})
		dirty = true
	end
	buildTree()

	-- Search --------------------------------------------------------------------------------
	local query = scope:Value("")
	local status = scope:Value("")
	local generation = 0
	table.insert(
		scope,
		scope:Observer(query):onChange(function()
			generation += 1
			local mine = generation
			local text = peek(query)
			if string.match(text, "^%s*$") then
				status:set("")
				tree:setFilter(nil)
				return
			end
			task.delay(
				0.25,
				function()
					if mine ~= generation then
						return
					end
					status:set("Searching")
					local nilList = if Settings.get("ShowNil") then Env.nilInstances() else nil
					local filter, count, capped = Search.run(
						game,
						text,
						nilList,
						function()
							return mine ~= generation
						end
					)
					if mine ~= generation or filter == nil then
						return
					end
					tree:setFilter(filter)
					status:set(
						if count == 0 then "No results"
							else `{count}{if capped then "+" else ""} found`
					)
				end
			)
		end)
	)

	local searchField, searchBox = Controls.Field(
		scope,
		{
			Name = "Search",
			Text = query,
			Placeholder = "ค้นหา   class:  isa:  tag:",
			Icon = "search",
			Height = 34,
			TrailingWidth = 84,
			Trailing = scope:New("Frame")({
				Name = "Trailing",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -6, 0.5, 0),
				Size = UDim2.fromOffset(80, 24),
				BackgroundTransparency = 1,
				[Children] = {
					Controls.Label(
						scope,
						{
							Size = UDim2.new(1, -26, 1, 0),
							Text = status,
							TextSize = 11,
							FontFace = Theme.Body,
							TextColor3 = Theme.Muted,
							TextXAlignment = Enum.TextXAlignment.Right,
						}
					),
					Controls.IconButton(
						scope,
						{
							Name = "Clear",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0, 0.5, 0),
							Icon = "x",
							Size = 22,
							IconSize = 13,
							Visible = scope:Computed(function(use)
								return use(query) ~= ""
							end),
							OnActivated = function()
								query:set("")
							end,
						}
					),
				},
			}),
		}
	)
	searchField.Position = UDim2.fromOffset(10, 62)
	searchField.Size = UDim2.new(1, -16, 0, 34)

	-- List ----------------------------------------------------------------------------------
	local list = scope:New("ScrollingFrame")({
		Name = "Tree",
		Position = UDim2.fromOffset(4, 104),
		Size = UDim2.new(1, -8, 1, -104 - 58),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = if State.Touch then 0 else 4,
		ScrollBarImageColor3 = Theme.Ink,
		ScrollBarImageTransparency = 0.8,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		[OnEvent("MouseEnter")] = function()
			hovering = true
		end,
		[OnEvent("MouseLeave")] = function()
			hovering = false
		end,
	})
	table.insert(
		scope,
		list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			dirty = true
		end)
	)
	table.insert(
		scope,
		list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			dirty = true
		end)
	)

	local pool = {}
	local flat = {}

	local function hasChildren(node): boolean
		local instance = node.Instance
		if instance == NIL_ROOT then
			return true
		elseif tree.Filter then
			return bit32.band(tree.Filter[instance] or 0, 2) ~= 0
		elseif node.Children then
			for _, child in node.Children do
				if not child.Removed then
					return true
				end
			end
			return false
		end
		local ok, child = pcall(instance.FindFirstChildWhichIsA, instance, "Instance")
		return ok and child ~= nil
	end

	local function indexOf(instance): number?
		for index, node in flat do
			if node.Instance == instance then
				return index
			end
		end
		return nil
	end

	local function scrollTo(index: number)
		local top = list.CanvasPosition.Y
		local height = list.AbsoluteWindowSize.Y
		local y = (index - 1) * ROW
		if y < top or y + ROW > top + height then
			list.CanvasPosition = Vector2.new(0, math.max(0, y - height / 2))
		end
	end

	local function selectOnly(instance)
		State.select({ instance })
		anchor = instance
	end

	local function onClick(row)
		local node = row.Node
		if node == nil or Menu.justLongPressed() then
			return
		end
		local instance = node.Instance
		if instance == NIL_ROOT then
			tree:toggle(node)
			return
		end
		local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			or peek(State.MultiSelect)
		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		if shift and anchor then
			local from, to = indexOf(anchor), row.Index
			if from then
				local range = {}
				for index = math.min(from, to), math.max(from, to) do
					local object = flat[index].Instance
					if object ~= NIL_ROOT then
						table.insert(range, object)
					end
				end
				State.select(range)
				return
			end
		end
		if ctrl then
			local selection = table.clone(State.selection())
			local at = table.find(selection, instance)
			if at then
				table.remove(selection, at)
			else
				table.insert(selection, instance)
			end
			State.select(selection)
			anchor = instance
			return
		end
		local now = os.clock()
		if lastClick.Instance == instance and now - lastClick.At < 0.35 then
			tree:toggle(node)
			lastClick.Instance = nil
		else
			lastClick.Instance, lastClick.At = instance, now
		end
		selectOnly(instance)
	end

	local function openMenu(row, point)
		local node = row.Node
		if node == nil then
			return
		end
		if node.Instance == NIL_ROOT then
			Menu.open(
				point,
				{
					{
						Text = "รีเฟรช nil instances",
						Icon = "refresh-cw",
						OnActivated = function()
							tree:refreshNil()
						end,
					},
				}
			)
			return
		end
		if not State.isSelected(node.Instance) then
			selectOnly(node.Instance)
		end
		Menu.open(
			point,
			Actions.entries(
				State.selection(),
				{
					Expand = function(deep)
						for _, object in State.selection() do
							local target = tree.Nodes[object]
							if target then
								if deep then
									tree:setExpandedDeep(target, true)
								else
									tree:setExpanded(target, true)
								end
							end
						end
					end,
					Collapse = function()
						for _, object in State.selection() do
							local target = tree.Nodes[object]
							if target then
								tree:setExpandedDeep(target, false)
							end
						end
					end,
				}
			)
		)
	end

	local function newRow(index: number)
		local row = { Index = 0, Node = nil, Bound = nil, NameConnection = nil, Hovered = false }
		local arrow = Controls.Icon(
			scope,
			"chevron-right",
			12,
			{
				Name = "Chevron",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				ImageColor3 = Theme.Muted,
			}
		)
		local toggle = scope:New("TextButton")({
			Name = "Toggle",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(if State.Touch then 26 else 18, ROW),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 2,
			[OnEvent("Activated")] = function()
				if row.Node then
					tree:toggle(row.Node)
				end
			end,
			[Children] = arrow,
		})
		local icon = ClassIcon.new(
			scope,
			"Instance",
			{
				Name = "Class",
				AnchorPoint = Vector2.new(0, 0.5),
			}
		)
		local label = Controls.Label(
			scope,
			{
				Name = "Label",
				Size = UDim2.new(1, -40, 1, 0),
				TextSize = 13,
				FontFace = Theme.Body,
				TextColor3 = Theme.Ink,
			}
		)
		local highlight = scope:New("Frame")({
			Name = "Selected",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.78,
			Visible = false,
			[Children] = scope:New("UICorner")({ CornerRadius = UDim.new(0, 7) }),
		})
		local frame = scope:New("TextButton")({
			Name = "Row" .. index,
			Parent = list,
			Size = UDim2.new(1, -4, 0, ROW),
			BackgroundColor3 = Theme.Ink,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Visible = false,
			[OnEvent("Activated")] = function()
				onClick(row)
			end,
			[OnEvent("MouseEnter")] = function()
				row.Hovered = true
				dirty = true
			end,
			[OnEvent("MouseLeave")] = function()
				row.Hovered = false
				dirty = true
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(0, 7) }),
				highlight,
				toggle,
				icon,
				label,
			},
		})
		row.Frame, row.Toggle, row.Arrow, row.Icon, row.Label = frame, toggle, arrow, icon, label
		row.Selected = highlight
		for _, connection in Menu.bind(
			frame,
			function(point)
				openMenu(row, point)
			end
		) do
			table.insert(scope, connection)
		end
		return row
	end

	local function bindName(row, instance)
		if row.Bound == instance then
			return
		end
		if row.NameConnection then
			row.NameConnection:Disconnect()
			row.NameConnection = nil
		end
		row.Bound = instance
		if instance ~= NIL_ROOT and typeof(instance) == "Instance" then
			local ok, signal = pcall(instance.GetPropertyChangedSignal, instance, "Name")
			if ok then
				row.NameConnection = signal:Connect(function()
					row.Label.Text = instance.Name
					tree:renamed(instance)
				end)
			end
		end
	end

	local selectedSet = {}
	table.insert(
		scope,
		scope:Observer(State.Selection):onBind(function()
			table.clear(selectedSet)
			for _, object in State.selection() do
				selectedSet[object] = true
			end
			dirty = true
		end)
	)

	local function render()
		dirty = false
		flat = tree:flat()
		list.CanvasSize = UDim2.fromOffset(0, #flat * ROW + 8)
		local height = list.AbsoluteWindowSize.Y
		local first = math.max(1, math.floor(list.CanvasPosition.Y / ROW) + 1)
		local needed = math.ceil(height / ROW) + 2
		while #pool < needed do
			table.insert(pool, newRow(#pool + 1))
		end
		for slot, row in pool do
			local index = first + slot - 1
			local node = if slot <= needed then flat[index] else nil
			if node == nil then
				if row.Frame.Visible then
					row.Frame.Visible = false
					row.Node = nil
					bindName(row, nil)
				end
				continue
			end
			row.Node, row.Index = node, index
			local instance = node.Instance
			local name, className
			if instance == NIL_ROOT then
				name, className = "Nil instances", "Folder"
			else
				local ok
				ok, name, className = pcall(function()
					return instance.Name, instance.ClassName
				end)
				if not ok then
					name, className = "<locked>", "Instance"
				end
			end
			local depth = node.Depth * INDENT
			local frame = row.Frame
			frame.Position = UDim2.fromOffset(2, (index - 1) * ROW + 4)
			frame.Visible = true
			local open = hasChildren(node)
			row.Toggle.Position = UDim2.new(0, depth, 0.5, 0)
			row.Arrow.Visible = open
			row.Arrow.Rotation = if open and tree:isOpen(node) then 90 else 0
			local iconX = depth + (if State.Touch then 26 else 18)
			row.Icon.Position = UDim2.new(0, iconX, 0.5, 0)
			ClassIcon.apply(row.Icon, className)
			row.Label.Position = UDim2.fromOffset(iconX + 22, 0)
			row.Label.Size = UDim2.new(1, -(iconX + 26), 1, 0)
			row.Label.Text = name
			row.Label.TextTransparency = if instance ~= NIL_ROOT
					and tree.Filter
					and bit32.band(tree.Filter[instance] or 0, 1) == 0 then 0.45
				else 0
			local selected = selectedSet[instance] == true
			row.Selected.Visible = selected
			frame.BackgroundTransparency = if row.Hovered and not selected then 0.95 else 1
			bindName(row, instance)
		end
	end

	local elapsed = 0
	table.insert(
		scope,
		RunService.Heartbeat:Connect(function(dt)
			elapsed += dt
			if dirty or tree.Dirty or elapsed > 0.5 then
				elapsed = 0
				render()
			end
		end)
	)

	-- Keyboard: arrows move and open, F2 renames, Delete deletes, while the pointer is over the list.
	table.insert(
		scope,
		UserInputService.InputBegan:Connect(function(input, processed)
			if processed or not hovering or UserInputService:GetFocusedTextBox() then
				return
			end
			local key = input.KeyCode
			local current = State.first()
			local index = current and indexOf(current)
			if key == Enum.KeyCode.Up or key == Enum.KeyCode.Down then
				local target = if index then index + (if key == Enum.KeyCode.Up then -1 else 1)
					else 1
				local node = flat[math.clamp(target, 1, math.max(1, #flat))]
				if node and node.Instance ~= NIL_ROOT then
					selectOnly(node.Instance)
					scrollTo(math.clamp(target, 1, #flat))
				end
			elseif (key == Enum.KeyCode.Right or key == Enum.KeyCode.Left) and index then
				local node = flat[index]
				if key == Enum.KeyCode.Right then
					if not tree:isOpen(node) then
						tree:setExpanded(node, true)
					end
				elseif tree:isOpen(node) and hasChildren(node) then
					tree:setExpanded(node, false)
				elseif node.Parent and node.Parent.Instance ~= NIL_ROOT then
					selectOnly(node.Parent.Instance)
				end
			elseif key == Enum.KeyCode.F2 and current then
				State.Hooks.rename(current)
			elseif key == Enum.KeyCode.Delete and current then
				Actions.delete(State.selection())
			end
		end)
	)

	-- Rename in place: a box over the row.
	State.Hooks.rename = function(instance)
		local index = indexOf(instance)
		if index == nil then
			return
		end
		scrollTo(index)
		render()
		local row = nil
		for _, candidate in pool do
			if candidate.Node and candidate.Node.Instance == instance then
				row = candidate
			end
		end
		if row == nil then
			return
		end
		local box = Instance.new("TextBox")
		box.Name = "Rename"
		box.Position = row.Label.Position
		box.Size = row.Label.Size
		box.BackgroundColor3 = peek(Theme.Surface)
		box.BorderSizePixel = 0
		box.Text = instance.Name
		box.FontFace = peek(Theme.Body)
		box.TextSize = 13
		box.TextColor3 = peek(Theme.Ink)
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false
		box.ZIndex = 5
		box.Parent = row.Frame
		box:CaptureFocus()
		box.SelectionStart, box.CursorPosition = 1, #box.Text + 1
		box.FocusLost:Connect(function(enter)
			if enter and box.Text ~= "" then
				local ok, problem = Env.setProperty(instance, "Name", box.Text)
				if not ok then
					Toast.show("เปลี่ยนชื่อไม่ได้: " .. tostring(problem), "error")
				end
			end
			box:Destroy()
		end)
	end

	State.Hooks.reveal = function(instance, keepSelection)
		local node = tree:reveal(instance)
		if node == nil then
			Toast.show("อ็อบเจกต์นั้นไม่อยู่ในต้นไม้", "error")
			return
		end
		if not keepSelection then
			selectOnly(instance)
		end
		flat = tree:flat()
		local index = indexOf(instance)
		if index then
			task.defer(function()
				scrollTo(index)
			end)
		end
	end

	State.Hooks.selectChildren = function(list)
		local children = {}
		for _, object in list do
			State.Hooks.reveal(object, true)
			local node = tree.Nodes[object]
			if node then
				tree:setExpanded(node, true)
			end
			for _, child in object:GetChildren() do
				table.insert(children, child)
			end
		end
		State.select(children)
	end

	State.Hooks.rebuildTree = function()
		local selection = State.selection()
		buildTree()
		for _, object in selection do
			tree:reveal(object)
		end
	end

	State.Hooks.collapseAll = function()
		tree:collapseAll()
	end

	-- Phones: a pill to open the panel for the selection.
	local inspect = Controls.Button(
		scope,
		{
			Name = "Inspect",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -12, 1, -66),
			Text = "ตรวจสอบ",
			TrailingIcon = "chevron-right",
			Height = 34,
			Visible = scope:Computed(function(use)
				return use(State.Compact) and #use(State.Selection) > 0
			end),
			OnActivated = function()
				State.open("Properties")
			end,
		}
	)
	inspect.ZIndex = 4

	local footer = scope:New("TextButton")({
		Name = "Credits",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, 44),
		BackgroundColor3 = Theme.Ink,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		[OnEvent("Activated")] = function()
			if Env.clipboard(DISCORD) then
				Toast.show("คัดลอกชื่อ Discord jasha.n แล้ว", "success")
			else
				Toast.show("Discord: jasha.n")
			end
		end,
		[Children] = {
			scope:New("Frame")({
				Name = "Badge",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 6, 0.5, 0),
				Size = UDim2.fromOffset(32, 32),
				BackgroundColor3 = Theme.Ink,
				BackgroundTransparency = 0.92,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
					Controls.Icon(
						scope,
						"discord",
						17,
						{
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
						}
					),
				},
			}),
			Controls.Label(
				scope,
				{
					Position = UDim2.fromOffset(48, 5),
					Size = UDim2.new(1, -52, 0, 18),
					Text = "jashan",
					TextSize = 13,
				}
			),
			Controls.Label(
				scope,
				{
					Position = UDim2.fromOffset(48, 22),
					Size = UDim2.new(1, -52, 0, 16),
					Text = "@" .. DISCORD,
					TextSize = 12,
					FontFace = Theme.Body,
					TextColor3 = Theme.Muted,
				}
			),
		},
	})

	local header = scope:New("Frame")({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		[Children] = {
			scope:New("Frame")({
				Name = "Mark",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 14, 0.5, 2),
				Size = UDim2.fromOffset(32, 32),
				BackgroundColor3 = Theme.Ink,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
					Controls.Icon(
						scope,
						"ethos-e",
						18,
						{
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							ImageColor3 = Theme.Surface,
						}
					),
				},
			}),
			Controls.Label(
				scope,
				{
					Position = UDim2.fromOffset(56, 13),
					Size = UDim2.new(1, -110, 0, 18),
					Text = "Ethos Dex",
					TextSize = 14,
				}
			),
			Controls.Label(
				scope,
				{
					Position = UDim2.fromOffset(56, 31),
					Size = UDim2.new(1, -110, 0, 16),
					Text = Env.executor,
					TextSize = 12,
					FontFace = Theme.Body,
					TextColor3 = Theme.Muted,
				}
			),
			Controls.IconButton(
				scope,
				{
					Name = "MultiSelect",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 2),
					Icon = "list-checks",
					Size = 28,
					Visible = State.Touch,
					OnActivated = function()
						State.MultiSelect:set(not peek(State.MultiSelect))
						Toast.show(
							if peek(State.MultiSelect) then "เลือกหลายรายการ: เปิด — แตะเพื่อเพิ่มในที่เลือก"
								else "เลือกหลายรายการ: ปิด"
						)
					end,
				}
			),
		},
	})

	local pane = scope:New("Frame")({
		Name = "Explorer",
		BackgroundTransparency = 1,
		[Children] = {
			header,
			searchField,
			list,
			inspect,
			footer,
		},
	})

	return {
		Instance = pane,
		Header = header,
		SearchBox = searchBox,
		Tree = function()
			return tree
		end,
	}
end

return Explorer

end)() end,
    function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)--!nocheck
--[[
	A context menu at a screen point, kept on screen, closed by any press outside it, Escape, or
	choosing an item. Long lists scroll. Items: { Text, Icon?, Danger?, Disabled? (reason),
	Detail?, OnActivated } or "divider".
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Env = require(Root.core.env)
local State = require(script.Parent.state)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local UserInputService = Env.service("UserInputService")

local ITEM = if State.Touch then 36 else 30
local WIDTH = 220
local MAX_HEIGHT = 360

local Menu = {}
local current = nil
local layer = nil
local layerScale = function()
	return 1
end

-- The full-screen frame menus open in, and its UI scale.
function Menu.setLayer(frame: GuiObject, getScale: () -> number)
	layer = frame
	layerScale = getScale
end

function Menu.close()
	if current then
		local scope = current
		current = nil
		Fusion.doCleanup(scope)
	end
end

function Menu.isOpen(): boolean
	return current ~= nil
end

local function item(scope, entry, order)
	if entry == "divider" then
		return scope:New("Frame")({
			Name = "Divider",
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 9),
			BackgroundTransparency = 1,
			[Children] = scope:New("Frame")({
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 8, 0.5, 0),
				Size = UDim2.new(1, -16, 0, 1),
				BackgroundColor3 = Theme.Ink,
				BackgroundTransparency = Theme.Line,
				BorderSizePixel = 0,
			}),
		})
	end
	local interaction = Controls.Interaction(scope)
	local disabled = entry.Disabled ~= nil
	local ink = if disabled then Theme.Faint elseif entry.Danger then Theme.Danger else Theme.Ink
	return scope:New("TextButton")(
		Controls.merge(
			{
				Name = entry.Text,
				LayoutOrder = order,
				Size = UDim2.new(1, 0, 0, ITEM),
				BackgroundColor3 = Theme.Ink,
				BackgroundTransparency = scope:Computed(function(use)
					return if disabled then 1 else 1 - 0.07 * use(interaction.HoverT)
				end),
				AutoButtonColor = false,
				Text = "",
				[OnEvent("Activated")] = function()
					if disabled then
						return
					end
					Menu.close()
					task.spawn(entry.OnActivated)
				end,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0, 8) }),
					if entry.Icon then Controls.Icon(
							scope,
							entry.Icon,
							15,
							{
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 10, 0.5, 0),
								ImageColor3 = if disabled then Theme.Faint
									elseif entry.Danger then Theme.Danger
									else Theme.Ink2,
							}
						)
						else nil,
					Controls.Label(
						scope,
						{
							Position = UDim2.fromOffset(if entry.Icon then 34 else 12, 0),
							Size = UDim2.new(1, -(if entry.Icon then 34 else 12) - 10, 1, 0),
							Text = entry.Text,
							TextSize = 13,
							FontFace = Theme.Body,
							TextColor3 = ink,
						}
					),
					if entry.Detail or entry.Disabled then Controls.Label(
							scope,
							{
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, -10, 0, 0),
								Size = UDim2.new(0.5, 0, 1, 0),
								Text = entry.Detail or "",
								TextSize = 11,
								FontFace = Theme.Body,
								TextColor3 = Theme.Faint,
								TextXAlignment = Enum.TextXAlignment.Right,
							}
						)
						else nil,
				},
			},
			interaction.Events
		)
	)
end

-- position: screen point (absolute, before the layer's UIScale).
function Menu.open(position: Vector2, entries)
	Menu.close()
	if layer == nil or #entries == 0 then
		return
	end
	local scope = Fusion.scoped(Fusion)
	current = scope
	local height = 8
	for _, entry in entries do
		height += if entry == "divider" then 9 else ITEM
	end
	local shown = math.min(height, MAX_HEIGHT)
	-- The layer is full screen under the UI scale: screen points divide by it.
	local room = layer.AbsoluteSize
	local scale = layerScale()
	local point = (position - layer.AbsolutePosition) / scale
	local x = math.clamp(point.X, 4, math.max(4, room.X / scale - WIDTH - 4))
	local y = point.Y
	if y + shown > room.Y / scale - 4 then
		y = math.max(4, y - shown)
	end

	local children = {}
	for index, entry in entries do
		table.insert(children, item(scope, entry, index))
	end
	local menuFrame = nil
	local function inside(input): boolean
		local frame = menuFrame
		if frame == nil then
			return false
		end
		local p, at, size = input.Position, frame.AbsolutePosition, frame.AbsoluteSize
		return p.X >= at.X and p.X <= at.X + size.X and p.Y >= at.Y and p.Y <= at.Y + size.Y
	end

	local dismiss = scope:New("TextButton")({
		Name = "MenuDismiss",
		Parent = layer,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 500,
		[OnEvent("InputBegan")] = function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.Touch then
				if not inside(input) then
					Menu.close()
				end
			end
		end,
		[Children] = scope:New("Frame")({
			Name = "Menu",
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(WIDTH, shown),
			BackgroundColor3 = Theme.Surface,
			Active = true,
			ZIndex = 501,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(0, 12) }),
				scope:New("UIStroke")({
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Theme.Ink,
					Transparency = 0.88,
				}),
				scope:New("ScrollingFrame")({
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					CanvasSize = UDim2.fromOffset(0, height),
					ScrollBarThickness = if height > shown then 3 else 0,
					ScrollBarImageColor3 = Theme.Ink,
					ScrollBarImageTransparency = 0.8,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					[Children] = {
						scope:New("UIPadding")({
							PaddingTop = UDim.new(0, 4),
							PaddingBottom = UDim.new(0, 4),
							PaddingLeft = UDim.new(0, 4),
							PaddingRight = UDim.new(0, 4),
						}),
						scope:New("UIListLayout")({ SortOrder = Enum.SortOrder.LayoutOrder }),
						children,
					},
				}),
			},
		}),
	})
	menuFrame = dismiss:FindFirstChild("Menu")
	table.insert(
		scope,
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Escape then
				Menu.close()
			end
		end)
	)
end

-- Right click, or a long press on touch, on `button` calls `onMenu(screenPoint)`.
function Menu.bind(button: GuiObject, onMenu: (Vector2) -> ()): { RBXScriptConnection }
	local connections = {}
	local pressId = 0
	table.insert(
		connections,
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				onMenu(Vector2.new(input.Position.X, input.Position.Y))
			elseif input.UserInputType == Enum.UserInputType.Touch then
				pressId += 1
				local mine = pressId
				local start = Vector2.new(input.Position.X, input.Position.Y)
				task.delay(
					0.45,
					function()
						if pressId == mine and input.UserInputState ~= Enum.UserInputState.End then
							local now = Vector2.new(input.Position.X, input.Position.Y)
							if (now - start).Magnitude < 12 then
								pressId += 1
								Menu.longPressed = os.clock()
								onMenu(now)
							end
						end
					end
				)
			end
		end)
	)
	table.insert(
		connections,
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				pressId += 1
			end
		end)
	)
	return connections
end

-- True right after a long press opened a menu, so the tap that ends it isn't also a click.
function Menu.justLongPressed(): boolean
	return Menu.longPressed ~= nil and os.clock() - Menu.longPressed < 0.6
end

return Menu

end)() end,
    function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)--!nocheck
--[[
	A searchable list in a sheet over the window: Insert Object's classes and long enums.
	options: Title, Items ({ string }), Current?, ClassIcons?, OnPick (string) -> ().
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Env = require(Root.core.env)
local State = require(script.Parent.state)
local ClassIcon = require(script.Parent.classIcon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local UserInputService = Env.service("UserInputService")

local SHOWN = 150
local ITEM = if State.Touch then 36 else 30

local Picker = {}
local layer = nil
local current = nil

function Picker.setLayer(frame: GuiObject)
	layer = frame
end

function Picker.close()
	if current then
		local scope = current
		current = nil
		Fusion.doCleanup(scope)
	end
end

function Picker.open(options)
	Picker.close()
	if layer == nil then
		return
	end
	local scope = Fusion.scoped(Fusion)
	current = scope
	local query = scope:Value("")
	local shown = scope:Computed(function(use)
		local text = string.lower(use(query))
		local list = {}
		for _, item in options.Items do
			if text == "" or string.find(string.lower(item), text, 1, true) then
				table.insert(list, item)
				if #list >= SHOWN then
					break
				end
			end
		end
		return list
	end)

	local function pick(item)
		Picker.close()
		task.spawn(options.OnPick, item)
	end

	local field, box = Controls.Field(
		scope,
		{
			Name = "Filter",
			Text = query,
			Placeholder = "กรอง",
			Icon = "search",
			Height = 34,
			OnSubmit = function()
				local first = peek(shown)[1]
				if first then
					pick(first)
				end
			end,
		}
	)
	field.Position = UDim2.fromOffset(12, 52)
	field.Size = UDim2.new(1, -24, 0, 34)

	scope:New("TextButton")({
		Name = "PickerShade",
		Parent = layer,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.55,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 400,
		[OnEvent("Activated")] = Picker.close,
		[Children] = scope:New("TextButton")({
			Name = "Sheet",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.9, 0, 0.8, 0),
			BackgroundColor3 = Theme.Surface,
			AutoButtonColor = false,
			Text = "",
			[Children] = {
				scope:New("UISizeConstraint")({ MaxSize = Vector2.new(380, 480) }),
				scope:New("UICorner")({ CornerRadius = UDim.new(0, 16) }),
				scope:New("UIStroke")({
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Theme.Ink,
					Transparency = 0.86,
				}),
				Controls.Label(
					scope,
					{
						Position = UDim2.fromOffset(16, 0),
						Size = UDim2.new(1, -60, 0, 48),
						Text = options.Title,
						TextSize = 14,
					}
				),
				Controls.IconButton(
					scope,
					{
						Name = "Close",
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, -10, 0, 10),
						Icon = "x",
						Size = 28,
						OnActivated = Picker.close,
					}
				),
				field,
				scope:New("ScrollingFrame")({
					Name = "Items",
					Position = UDim2.fromOffset(8, 94),
					Size = UDim2.new(1, -16, 1, -102),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.new(),
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = Theme.Ink,
					ScrollBarImageTransparency = 0.8,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					[Children] = {
						scope:New("UIListLayout")({ SortOrder = Enum.SortOrder.LayoutOrder }),
						scope:ForValues(
							shown,
							function(_, itemScope, item)
								local interaction = Controls.Interaction(itemScope)
								local picked = item == options.Current
								return itemScope:New("TextButton")(
									Controls.merge(
										{
											Name = item,
											LayoutOrder = table.find(peek(shown), item) or 0,
											Size = UDim2.new(1, 0, 0, ITEM),
											BackgroundColor3 = if picked then Theme.Accent
												else Theme.Ink,
											BackgroundTransparency = itemScope:Computed(function(
												use
											)
												return if picked then 0.8
													else 1 - 0.07 * use(interaction.HoverT)
											end),
											AutoButtonColor = false,
											Text = "",
											[OnEvent("Activated")] = function()
												pick(item)
											end,
											[Children] = {
												itemScope:New("UICorner")({
													CornerRadius = UDim.new(0, 8),
												}),
												if options.ClassIcons then ClassIcon.new(
														itemScope,
														item,
														{
															AnchorPoint = Vector2.new(0, 0.5),
															Position = UDim2.new(0, 10, 0.5, 0),
														}
													)
													else nil,
												Controls.Label(
													itemScope,
													{
														Position = UDim2.fromOffset(
															if options.ClassIcons then 34 else 12,
															0
														),
														Size = UDim2.new(1, -46, 1, 0),
														Text = item,
														TextSize = 13,
														FontFace = Theme.Body,
													}
												),
											},
										},
										interaction.Events
									)
								)
							end
						),
					},
				}),
			},
		}),
	})
	table.insert(
		scope,
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Escape then
				Picker.close()
			end
		end)
	)
	if not State.Touch then
		task.defer(function()
			if current == scope then
				box:CaptureFocus()
			end
		end)
	end
end

return Picker

end)() end,
    function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)--!nocheck
-- A 3D preview of a model or part: a copy in a ViewportFrame you can orbit and zoom.

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Pointer = require(Root.ui.pointer)
local Env = require(Root.core.env)
local State = require(script.Parent.state)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local RunService = Env.service("RunService")

local MAX_PARTS = 6000

local Preview = {}

function Preview.new(scope)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 50
	local world = Instance.new("WorldModel")
	local yaw, pitch, distance, center = 0.6, -0.35, 10, Vector3.zero
	local spin = scope:Value(true)
	local title = scope:Value("")
	local problem = scope:Value(nil)
	local copy = nil

	local function place()
		local rotation = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)
		camera.CFrame = CFrame.new(center) * rotation * CFrame.new(0, 0, distance)
		camera.Focus = CFrame.new(center)
	end

	local function load(object)
		if copy then
			copy:Destroy()
			copy = nil
		end
		problem:set(nil)
		if object == nil then
			title:set("")
			return
		end
		title:set(object.Name)
		local ok, result = pcall(function()
			local count = if object:IsA("BasePart") then 1 else 0
			for _, descendant in object:GetDescendants() do
				if descendant:IsA("BasePart") then
					count += 1
				end
			end
			if count > MAX_PARTS then
				error(`{count} parts is too many to preview.`, 0)
			end
			local restore = {}
			local function allow(instance)
				if not instance.Archivable then
					instance.Archivable = true
					table.insert(restore, instance)
				end
			end
			allow(object)
			for _, descendant in object:GetDescendants() do
				pcall(allow, descendant)
			end
			local clone = object:Clone()
			for _, instance in restore do
				pcall(function()
					instance.Archivable = false
				end)
			end
			if clone == nil then
				error("It can't be copied.", 0)
			end
			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("LuaSourceContainer") then
					descendant:Destroy()
				end
			end
			return clone
		end)
		if not ok then
			problem:set(tostring(result))
			return
		end
		copy = result
		local cframe, size
		if copy:IsA("BasePart") then
			cframe, size = copy.CFrame, copy.Size
		else
			local model = copy
			if not copy:IsA("Model") then
				model = Instance.new("Model")
				copy.Parent = model
				copy = model
			end
			cframe, size = model:GetBoundingBox()
		end
		center = cframe.Position
		distance = math.max(size.Magnitude * 1.1, 2)
		copy.Parent = world
		place()
	end

	table.insert(
		scope,
		scope:Observer(State.PreviewTarget):onBind(function()
			load(peek(State.PreviewTarget))
		end)
	)

	local viewport = scope:New("ViewportFrame")({
		Name = "Viewport",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		CurrentCamera = camera,
		Ambient = Color3.fromRGB(160, 160, 170),
		LightColor = Color3.fromRGB(255, 255, 255),
		LightDirection = Vector3.new(-1, -2, -1),
		Active = true,
		[OnEvent("InputBegan")] = function(input)
			if not Pointer.isPress(input) then
				return
			end
			spin:set(false)
			local last = Vector2.new(input.Position.X, input.Position.Y)
			Pointer.drag(
				scope,
				function(point)
					local delta = point - last
					last = point
					yaw -= delta.X * 0.01
					pitch = math.clamp(pitch - delta.Y * 0.01, -1.5, 1.5)
					place()
				end
			)
		end,
		[OnEvent("InputChanged")] = function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				distance = math.max(0.5, distance * (1 - input.Position.Z * 0.1))
				place()
			end
		end,
	})
	camera.Parent = viewport
	world.Parent = viewport

	table.insert(
		scope,
		RunService.RenderStepped:Connect(function(dt)
			if peek(spin) and copy then
				yaw += dt * 0.4
				place()
			end
		end)
	)
	table.insert(
		scope,
		function()
			if copy then
				copy:Destroy()
			end
		end
	)

	local function zoom(factor)
		distance = math.max(0.5, distance * factor)
		place()
	end

	local body = scope:New("Frame")({
		Name = "Stage",
		Position = UDim2.fromOffset(10, 52),
		Size = UDim2.new(1, -20, 1, -62),
		BackgroundColor3 = Theme.Ink,
		ClipsDescendants = true,
		Visible = scope:Computed(function(use)
			return use(State.PreviewTarget) ~= nil
		end),
		[Children] = {
			Controls.Fill(scope, scope:Value(0.04)),
			Controls.Edge(scope, nil, UDim.new(0, 12)),
			viewport,
			Controls.Label(
				scope,
				{
					Position = UDim2.new(0, 14, 1, -30),
					Size = UDim2.new(1, -28, 0, 20),
					Text = scope:Computed(function(use)
						return use(problem) or ""
					end),
					TextSize = 13,
					TextColor3 = Theme.Caution,
				}
			),
		},
	})

	local header = scope:New("Frame")({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Visible = scope:Computed(function(use)
			return use(State.PreviewTarget) ~= nil
		end),
		[Children] = {
			Controls.Label(
				scope,
				{
					Position = UDim2.fromOffset(16, 0),
					Size = UDim2.new(1, -170, 1, 0),
					Text = title,
					TextSize = 14,
				}
			),
			scope:New("Frame")({
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(0, 30),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				[Children] = {
					scope:New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Controls.IconButton(
						scope,
						{
							Name = "ZoomIn",
							Icon = "zoom-in",
							Size = 30,
							LayoutOrder = 1,
							OnActivated = function()
								zoom(0.8)
							end,
						}
					),
					Controls.IconButton(
						scope,
						{
							Name = "ZoomOut",
							Icon = "zoom-out",
							Size = 30,
							LayoutOrder = 2,
							OnActivated = function()
								zoom(1.25)
							end,
						}
					),
					Controls.IconButton(
						scope,
						{
							Name = "Spin",
							Icon = "rotate-ccw",
							Size = 30,
							LayoutOrder = 3,
							OnActivated = function()
								spin:set(not peek(spin))
							end,
						}
					),
				},
			}),
		},
	})

	local empty = Controls.Empty(
		scope,
		{
			Name = "Empty",
			Icon = "box",
			Title = "คลิกขวาที่โมเดลหรือพาร์ต แล้วเลือก ตัวอย่าง",
			Visible = scope:Computed(function(use)
				return use(State.PreviewTarget) == nil
			end),
		}
	)
	empty.AnchorPoint = Vector2.new(0.5, 0.5)
	empty.Position = UDim2.fromScale(0.5, 0.45)

	local pane = scope:New("Frame")({
		Name = "Preview",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = { header, body, empty },
	})
	return { Instance = pane }
end

return Preview

end)() end,
    function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)--!nocheck
--[[
	The properties panel. The list of rows (category headers, properties, attributes) is built
	from the API dump when the selection or a setting changes; rows on screen are a pool bound to
	it, each holding every editor kind and showing the one its value needs. Values are read
	fresh on each render, which runs when the selected instance reports a change, on scroll, and
	when the list is rebuilt. Edits go to every selected instance.
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Env = require(Root.core.env)
local Api = require(Root.core.api)
local Values = require(Root.core.values)
local Settings = require(Root.core.settings)
local State = require(script.Parent.state)
local ClassIcon = require(script.Parent.classIcon)
local Menu = require(script.Parent.menu)
local Picker = require(script.Parent.picker)
local Toast = require(script.Parent.toast)
local Actions = require(script.Parent.actions)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local RunService = Env.service("RunService")
local CollectionService = Env.service("CollectionService")

local ROW = State.ROW + 4
local ORDER = {
	"Data",
	"Appearance",
	"Text",
	"Image",
	"Behavior",
	"Transform",
	"Pivot",
	"Part",
	"Collision",
	"Assembly",
	"Physics",
	"Surface",
	"Shape",
	"Character",
	"Camera",
	"Scripting",
}
local ORDER_INDEX = {}
for index, name in ORDER do
	ORDER_INDEX[name] = index
end
local BASIC = { "Name", "ClassName", "Parent", "Archivable" }

local Properties = {}

local function escape(text: string): string
	return (string.gsub(string.gsub(text, "\\", "\\\\"), "\n", "\\n"))
end

local function unescape(text: string): string
	return (string.gsub(
		text,
		"\\(.)",
		function(char)
			return if char == "n" then "\n" elseif char == "t" then "\t" else char
		end
	))
end

function Properties.new(scope)
	local query = scope:Value("")
	local collapsed = {}
	local entries = {}
	local dirty = true
	local target = nil
	local targetConnections = {}

	local header = scope:New("Frame")({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	})
	local headerIcon = ClassIcon.new(
		scope,
		"Instance",
		{
			Parent = header,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 14, 0.5, 0),
		}
	)
	local headerName = Controls.Label(
		scope,
		{
			Parent = header,
			Position = UDim2.fromOffset(40, 6),
			Size = UDim2.new(1, -54, 0, 18),
			TextSize = 14,
		}
	)
	local headerClass = Controls.Label(
		scope,
		{
			Parent = header,
			Position = UDim2.fromOffset(40, 23),
			Size = UDim2.new(1, -54, 0, 16),
			TextSize = 12,
			FontFace = Theme.Body,
			TextColor3 = Theme.Muted,
		}
	)

	local filterField = Controls.Field(
		scope,
		{
			Name = "Filter",
			Text = query,
			Placeholder = "กรองพรอเพอร์ตี้",
			Icon = "list-filter",
			Height = 32,
		}
	)
	filterField.Position = UDim2.fromOffset(10, 48)
	filterField.Size = UDim2.new(1, -20, 0, 32)

	local notice = Controls.Label(
		scope,
		{
			Name = "Notice",
			Position = UDim2.fromOffset(14, 84),
			Size = UDim2.new(1, -28, 0, 18),
			TextSize = 11,
			FontFace = Theme.Body,
			TextColor3 = Theme.Caution,
			Visible = false,
		}
	)

	local list = scope:New("ScrollingFrame")({
		Name = "Rows",
		Position = UDim2.fromOffset(6, 88),
		Size = UDim2.new(1, -12, 1, -94),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = if State.Touch then 0 else 4,
		ScrollBarImageColor3 = Theme.Ink,
		ScrollBarImageTransparency = 0.8,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
	})
	table.insert(
		scope,
		list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			dirty = true
		end)
	)
	table.insert(
		scope,
		list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			dirty = true
		end)
	)

	local empty = Controls.Empty(
		scope,
		{
			Name = "Empty",
			Icon = "mouse-pointer-click",
			Title = "เลือกบางอย่างในเอ็กซ์พลอเรอร์",
		}
	)
	empty.AnchorPoint = Vector2.new(0.5, 0.5)
	empty.Position = UDim2.fromScale(0.5, 0.45)

	-- Reading and writing --------------------------------------------------------------------

	local function read(entry): (boolean, any)
		if entry.Kind == "attr" then
			return pcall(target.GetAttribute, target, entry.Name)
		elseif entry.Kind == "tags" then
			return pcall(function()
				return table.concat(CollectionService:GetTags(target), ", ")
			end)
		end
		return Env.getProperty(target, entry.Name)
	end

	local function write(entry, value)
		local failures, problem = 0, nil
		for _, object in State.selection() do
			local ok, failure
			if entry.Kind == "attr" then
				ok, failure = pcall(object.SetAttribute, object, entry.Name, value)
			else
				ok, failure = Env.setProperty(object, entry.Name, value)
			end
			if not ok then
				failures += 1
				problem = failure
			end
		end
		if failures > 0 then
			Toast.show(`ตั้งค่า {entry.Name} ไม่ได้: {problem}`, "error")
		end
		dirty = true
	end

	-- Building the row list ------------------------------------------------------------------

	local function propertyList(object)
		local list = {}
		if Api.hasDump() then
			local showHidden = Settings.get("ShowHidden") and Env.has("gethiddenproperty")
			local showDeprecated = Settings.get("ShowDeprecated")
			for _, property in Api.properties(object.ClassName) do
				local tags = property.Tags
				if tags.Deprecated and not showDeprecated then
					continue
				end
				if (tags.Hidden or tags.NotScriptable) and not showHidden then
					continue
				end
				if Env.getProperty(object, property.Name) then
					table.insert(
						list,
						{
							Kind = "prop",
							Name = property.Name,
							Category = property.Category,
							ReadOnly = tags.ReadOnly == true,
							Hidden = tags.Hidden or tags.NotScriptable,
							EnumType = if property.ValueType.Category == "Enum" then property.ValueType.Name
								else nil,
						}
					)
				end
			end
		elseif Env.has("getproperties") then
			local ok, found = pcall(Env.raw.getproperties, object)
			if ok and type(found) == "table" then
				for name in found do
					if type(name) == "string" then
						table.insert(list, { Kind = "prop", Name = name, Category = "Properties" })
					end
				end
				table.sort(
					list,
					function(a, b)
						return a.Name < b.Name
					end
				)
			end
		end
		if #list == 0 then
			for _, name in BASIC do
				table.insert(
					list,
					{
						Kind = "prop",
						Name = name,
						Category = "Data",
						ReadOnly = name == "ClassName",
					}
				)
			end
		end
		return list
	end

	local function build()
		entries = {}
		local selection = State.selection()
		target = selection[1]
		if target == nil then
			return
		end
		local props = propertyList(target)
		-- With several selected, only properties they all have.
		if #selection > 1 then
			local shared = {}
			for _, property in props do
				shared[property.Name] = true
			end
			local seenClass = { [target.ClassName] = true }
			for index = 2, #selection do
				local className = selection[index].ClassName
				if not seenClass[className] then
					seenClass[className] = true
					local names = {}
					for _, property in propertyList(selection[index]) do
						names[property.Name] = true
					end
					for name in shared do
						if not names[name] then
							shared[name] = nil
						end
					end
				end
			end
			local kept = {}
			for _, property in props do
				if shared[property.Name] then
					table.insert(kept, property)
				end
			end
			props = kept
		end

		local text = string.lower(peek(query))
		local groups, names = {}, {}
		local function add(category, entry)
			if text ~= "" and not string.find(string.lower(entry.Name), text, 1, true) then
				return
			end
			if groups[category] == nil then
				groups[category] = {}
				table.insert(names, category)
			end
			table.insert(groups[category], entry)
		end
		for _, property in props do
			add(property.Category, property)
		end
		local ok, attributes = pcall(target.GetAttributes, target)
		if ok then
			local attributeNames = {}
			for name in attributes do
				table.insert(attributeNames, name)
			end
			table.sort(attributeNames)
			for _, name in attributeNames do
				add("Attributes", { Kind = "attr", Name = name, Category = "Attributes" })
			end
		end
		local tagged, tags = pcall(CollectionService.GetTags, CollectionService, target)
		if tagged and #tags > 0 then
			add("Tags", { Kind = "tags", Name = "Tags", Category = "Tags", ReadOnly = true })
		end
		table.sort(
			names,
			function(a, b)
				local ra = ORDER_INDEX[a]
					or (if a == "Attributes" then 999 elseif a == "Tags" then 1000 else 500)
				local rb = ORDER_INDEX[b]
					or (if b == "Attributes" then 999 elseif b == "Tags" then 1000 else 500)
				if ra ~= rb then
					return ra < rb
				end
				return a < b
			end
		)
		for _, category in names do
			table.insert(entries, { Kind = "header", Name = category, Count = #groups[category] })
			if not collapsed[category] then
				for _, entry in groups[category] do
					table.insert(entries, entry)
				end
			end
		end
	end

	local function retarget()
		for _, connection in targetConnections do
			connection:Disconnect()
		end
		table.clear(targetConnections)
		build()
		if target then
			table.insert(
				targetConnections,
				target.Changed:Connect(function()
					dirty = true
				end)
			)
			table.insert(
				targetConnections,
				target.AttributeChanged:Connect(function()
					build()
					dirty = true
				end)
			)
			local okName, name = pcall(function()
				return target.Name
			end)
			headerName.Text = if okName then name else "?"
			local count = #State.selection()
			headerClass.Text = if count > 1 then `{target.ClassName} · {count} selected`
				else target.ClassName
			ClassIcon.apply(headerIcon, target.ClassName)
		end
		local failed = Api.Status == "failed"
		notice.Visible = failed and target ~= nil
		notice.Text = if failed then "Roblox API unavailable: showing basic properties" else ""
		list.Position = UDim2.fromOffset(6, if notice.Visible then 104 else 88)
		list.Size = UDim2.new(1, -12, 1, if notice.Visible then -110 else -94)
		dirty = true
	end

	table.insert(scope, scope:Observer(State.Selection):onBind(retarget))
	table.insert(scope, scope:Observer(query):onChange(retarget))
	for _, key in { "ShowHidden", "ShowDeprecated" } do
		table.insert(scope, scope:Observer(Settings.state(key)):onChange(retarget))
	end
	Api.onReady(retarget)

	-- Rows ----------------------------------------------------------------------------------

	local pool = {}

	local function openEnum(row)
		local entry = row.Entry
		local ok, current = read(entry)
		local enumType = entry.EnumType
			or (ok and typeof(current) == "EnumItem" and tostring(current.EnumType))
		local enum = enumType and Enum[enumType]
		if enum == nil then
			return
		end
		local items = {}
		for _, item in enum:GetEnumItems() do
			table.insert(items, item.Name)
		end
		local function choose(name)
			write(entry, enum[name])
		end
		if #items <= 12 then
			local menuItems = {}
			for _, name in items do
				table.insert(
					menuItems,
					{
						Text = name,
						Icon = if ok and current and current.Name == name then "check" else nil,
						OnActivated = function()
							choose(name)
						end,
					}
				)
			end
			local at = row.EnumButton.AbsolutePosition
			Menu.open(Vector2.new(at.X, at.Y + row.EnumButton.AbsoluteSize.Y + 2), menuItems)
		else
			Picker.open({
				Title = entry.Name,
				Items = items,
				Current = ok and current and current.Name or nil,
				OnPick = choose,
			})
		end
	end

	local function commit(row)
		local entry = row.Entry
		if entry == nil or entry.ReadOnly then
			return
		end
		local ok, current = read(entry)
		if not ok then
			return
		end
		local text = row.Box.Text
		if typeof(current) == "string" then
			text = unescape(text)
		end
		if text == row.Shown then
			return
		end
		local parsed, value = Values.parse(text, current)
		if parsed then
			write(entry, value)
		else
			Toast.show(`ไม่ใช่ค่า {typeof(current)} ที่ถูกต้อง`, "error")
			dirty = true
		end
	end

	local function newRow(index)
		local row = { Entry = nil, Shown = nil, OnT = scope:Value(0), PressT = scope:Value(0) }
		local frame = scope:New("Frame")({
			Name = "Row" .. index,
			Parent = list,
			Size = UDim2.new(1, -4, 0, ROW),
			BackgroundColor3 = Theme.Ink,
			BackgroundTransparency = 1,
			Visible = false,
		})
		row.Frame = frame
		row.Fold = scope:New("TextButton")({
			Name = "Fold",
			Parent = frame,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			[OnEvent("Activated")] = function()
				local entry = row.Entry
				if entry and entry.Kind == "header" then
					collapsed[entry.Name] = not collapsed[entry.Name]
					build()
					dirty = true
				end
			end,
		})
		row.Chevron = Controls.Icon(
			scope,
			"chevron-right",
			12,
			{
				Parent = frame,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 6, 0.5, 0),
				ImageColor3 = Theme.Muted,
			}
		)
		row.Name = Controls.Label(
			scope,
			{
				Name = "PropName",
				Parent = frame,
				Position = UDim2.fromOffset(10, 0),
				TextSize = 13,
				FontFace = Theme.Body,
				TextColor3 = Theme.Ink2,
			}
		)
		row.Line = scope:New("Frame")({
			Name = "Line",
			Parent = frame,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Theme.Ink,
			BackgroundTransparency = 0.95,
			BorderSizePixel = 0,
		})
		row.Swatch = scope:New("Frame")({
			Name = "Swatch",
			Parent = frame,
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(14, 14),
			Visible = false,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(0, 4) }),
				scope:New("UIStroke")({ Color = Theme.Ink, Transparency = 0.8 }),
			},
		})
		row.Box = scope:New("TextBox")({
			Name = "Value",
			Parent = frame,
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			FontFace = Theme.Body,
			TextSize = 13,
			TextColor3 = Theme.Ink,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = "",
			[OnEvent("FocusLost")] = function()
				commit(row)
			end,
		})
		local interaction = Controls.Interaction(scope)
		row.Toggle = scope:New("TextButton")(
			Controls.merge(
				{
					Name = "Toggle",
					Parent = frame,
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.fromOffset(40, 24),
					BackgroundTransparency = 1,
					Text = "",
					Visible = false,
					[OnEvent("Activated")] = function()
						local entry = row.Entry
						if entry and not entry.ReadOnly then
							local ok, current = read(entry)
							if ok and type(current) == "boolean" then
								write(entry, not current)
							end
						end
					end,
					[Children] = (function()
						local switch = Controls.Switch(scope, row.OnT, interaction.PressT)
						switch.AnchorPoint = Vector2.new(0, 0.5)
						switch.Position = UDim2.fromScale(0, 0.5)
						return switch
					end)(),
				},
				interaction.Events
			)
		)
		row.EnumCaption = Controls.Label(
			scope,
			{
				Name = "Caption",
				Size = UDim2.new(1, -20, 1, 0),
				TextSize = 13,
				FontFace = Theme.Body,
				TextColor3 = Theme.Ink,
			}
		)
		row.EnumButton = scope:New("TextButton")({
			Name = "Enum",
			Parent = frame,
			BackgroundTransparency = 1,
			Text = "",
			Visible = false,
			[OnEvent("Activated")] = function()
				if row.Entry and not row.Entry.ReadOnly then
					openEnum(row)
				end
			end,
			[Children] = {
				row.EnumCaption,
				Controls.Icon(
					scope,
					"chevrons-up-down",
					12,
					{
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -4, 0.5, 0),
						ImageColor3 = Theme.Muted,
					}
				),
			},
		})
		row.Link = scope:New("TextButton")({
			Name = "Link",
			Parent = frame,
			BackgroundTransparency = 1,
			FontFace = Theme.Body,
			TextSize = 13,
			TextColor3 = Theme.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = "",
			Visible = false,
			[OnEvent("Activated")] = function()
				local entry = row.Entry
				if entry then
					local ok, value = read(entry)
					if ok and typeof(value) == "Instance" then
						State.Hooks.reveal(value)
					end
				end
			end,
		})
		for _, connection in Menu.bind(
			frame,
			function(point)
				local entry = row.Entry
				if entry == nil or entry.Kind == "header" then
					return
				end
				local ok, value = read(entry)
				Menu.open(
					point,
					{
						{
							Text = "คัดลอกค่า",
							Icon = "copy",
							OnActivated = function()
								Actions.copy(if ok then Values.format(value) else "", "value")
							end,
						},
						{
							Text = "คัดลอกเป็น Luau",
							Icon = "code",
							OnActivated = function()
								Actions.copy(if ok then Values.code(value) else "nil", "value")
							end,
						},
						{
							Text = "คัดลอกชื่อ",
							Icon = "type",
							OnActivated = function()
								Actions.copy(entry.Name, "name")
							end,
						},
					}
				)
			end
		) do
			table.insert(scope, connection)
		end
		return row
	end

	local function show(row, kind)
		row.Box.Visible = kind == "box"
		row.Toggle.Visible = kind == "toggle"
		row.EnumButton.Visible = kind == "enum"
		row.Link.Visible = kind == "link"
	end

	local function render()
		dirty = false
		list.Visible = target ~= nil
		filterField.Visible = target ~= nil
		header.Visible = target ~= nil
		empty.Visible = target == nil
		if target == nil then
			return
		end
		list.CanvasSize = UDim2.fromOffset(0, #entries * ROW + 8)
		local width = list.AbsoluteWindowSize.X
		local nameWidth = math.clamp(math.floor(width * 0.42), 96, 220)
		local valueX = nameWidth + 8
		local height = list.AbsoluteWindowSize.Y
		local first = math.max(1, math.floor(list.CanvasPosition.Y / ROW) + 1)
		local needed = math.ceil(height / ROW) + 2
		while #pool < needed do
			table.insert(pool, newRow(#pool + 1))
		end
		local ink = peek(Theme.Ink)
		local faint = peek(Theme.Faint)
		for slot, row in pool do
			local index = first + slot - 1
			local entry = if slot <= needed then entries[index] else nil
			local frame = row.Frame
			if entry == nil then
				frame.Visible = false
				row.Entry = nil
				continue
			end
			if row.Entry ~= entry and row.Box:IsFocused() then
				row.Box:ReleaseFocus()
			end
			row.Entry = entry
			frame.Visible = true
			frame.Position = UDim2.fromOffset(2, (index - 1) * ROW + 4)
			if entry.Kind == "header" then
				frame.BackgroundTransparency = 0.97
				row.Fold.Visible = true
				row.Chevron.Visible = true
				row.Chevron.Rotation = if collapsed[entry.Name] then 0 else 90
				row.Name.Position = UDim2.fromOffset(24, 0)
				row.Name.Size = UDim2.new(1, -30, 1, 0)
				row.Name.Text = entry.Name
				row.Name.FontFace = peek(Theme.Title)
				row.Line.Visible = false
				row.Swatch.Visible = false
				show(row, nil)
				continue
			end
			frame.BackgroundTransparency = 1
			row.Fold.Visible = false
			row.Chevron.Visible = false
			row.Line.Visible = true
			row.Name.Position = UDim2.fromOffset(14, 0)
			row.Name.Size = UDim2.new(0, nameWidth - 10, 1, 0)
			row.Name.Text = entry.Name
			row.Name.FontFace = peek(Theme.Body)
			row.Name.TextTransparency = if entry.Hidden then 0.4 else 0
			local ok, value = read(entry)
			local kind = typeof(value)
			local x = valueX
			local swatch = ok and (kind == "Color3" or kind == "BrickColor")
			row.Swatch.Visible = swatch
			if swatch then
				row.Swatch.BackgroundColor3 = if kind == "Color3" then value else value.Color
				row.Swatch.Position = UDim2.new(0, x, 0.5, 0)
				x += 22
			end
			local valueSize = UDim2.new(1, -x - 8, 1, 0)
			if not ok then
				show(row, "box")
				row.Box.Text = "?"
				row.Box.TextEditable = false
			elseif kind == "boolean" then
				show(row, "toggle")
				row.Toggle.Position = UDim2.new(0, x, 0.5, 0)
				row.OnT:set(if value then 1 else 0)
			elseif kind == "EnumItem" then
				show(row, "enum")
				row.EnumButton.Position = UDim2.fromOffset(x, 0)
				row.EnumButton.Size = valueSize
				row.EnumCaption.Text = value.Name
				row.EnumCaption.TextColor3 = if entry.ReadOnly then faint else ink
			elseif kind == "Instance" then
				show(row, "link")
				row.Link.Position = UDim2.fromOffset(x, 0)
				row.Link.Size = valueSize
				row.Link.Text = value.Name
			else
				show(row, "box")
				row.Box.Position = UDim2.fromOffset(x, 0)
				row.Box.Size = valueSize
				local editable = not entry.ReadOnly and (Values.TEXT_TYPES[kind] == true)
				row.Box.TextEditable = editable
				row.Box.TextColor3 = if editable then ink else faint
				if not row.Box:IsFocused() then
					local text = if value == nil then "nil"
						elseif kind == "string" then escape(value)
						else Values.format(value)
					row.Shown = if kind == "string" then value else text
					row.Box.Text = text
				end
			end
		end
	end

	table.insert(
		scope,
		RunService.Heartbeat:Connect(function()
			if dirty then
				render()
			end
		end)
	)
	-- Theme changes recolour the read-only text.
	table.insert(
		scope,
		scope:Observer(Theme.Ink):onChange(function()
			dirty = true
		end)
	)

	local pane = scope:New("Frame")({
		Name = "Properties",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = { header, filterField, notice, list, empty },
	})
	return { Instance = pane }
end

return Properties

end)() end,
    function()local wax,script,require=ImportGlobals(11)local ImportGlobals return (function(...)--!nocheck
--[[
	Decompiled source, one pooled row per visible line, so a 20k-line script costs what fits on
	screen. Lines are highlighted once (LuauHighlight over the whole source, so strings and
	comments that span lines colour right) and turned into rich text as they scroll in.
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Fonts = require(Root.ui.fonts)
local CodeTheme = require(Root.ui.codeTheme)
local LuauHighlight = require(Root.utils.luauHighlight)
local Env = require(Root.core.env)
local Settings = require(Root.core.settings)
local State = require(script.Parent.state)
local ClassIcon = require(script.Parent.classIcon)
local Menu = require(script.Parent.menu)
local Toast = require(script.Parent.toast)
local Actions = require(script.Parent.actions)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local RunService = Env.service("RunService")
local TextService = Env.service("TextService")

local LINE = 18
local TEXT = 13
local PAD = 10
local HIGHLIGHT_LIMIT = 400000
local LONG_LINE = 1500
local ESCAPES = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	['"'] = "&quot;",
	["'"] = "&apos;",
}

local ScriptViewer = {}

local CHAR = (function()
	local ok, size = pcall(
		TextService.GetTextSize,
		TextService,
		string.rep("0", 100),
		TEXT,
		Enum.Font.RobotoMono,
		Vector2.new(100000, 100)
	)
	return if ok then size.X / 100 else 7.8
end)()

local function escape(text: string): string
	return (string.gsub(text, "[&<>\"']", ESCAPES))
end

function ScriptViewer.new(scope)
	local cache = setmetatable({}, { __mode = "k" })
	local lines = {} -- plain text
	local tokens = nil -- per line, or nil when plain
	local rich = {}
	local source = ""
	local status = scope:Value("")
	local problem = scope:Value(nil)
	local findQuery = scope:Value("")
	local matches = {}
	local matchAt = 0
	local matchLine = nil
	local dirty = true
	local resetCanvas = false
	local generation = 0
	local target = nil

	local function setSource(text: string)
		source = text
		local expanded = string.gsub(text, "\t", "    ")
		lines = string.split(expanded, "\n")
		rich = {}
		tokens = nil
		if #expanded <= HIGHLIGHT_LIMIT then
			local ok, result = pcall(LuauHighlight, expanded)
			if ok then
				tokens = result
			end
		end
		matches, matchAt, matchLine = {}, 0, nil
		resetCanvas = true
		dirty = true
	end

	local function richLine(index: number, colors): string
		local hit = rich[index]
		if hit then
			return hit
		end
		local text = lines[index] or ""
		if #text > LONG_LINE then
			hit = escape(string.sub(text, 1, LONG_LINE)) .. " …"
		elseif tokens and tokens[index] then
			local parts = {}
			for _, token in tokens[index] do
				local color = colors[token.Kind] or colors.iden
				table.insert(parts, `<font color="#{color:ToHex()}">{escape(token.Text)}</font>`)
			end
			hit = table.concat(parts)
		else
			hit = escape(text)
		end
		rich[index] = hit
		return hit
	end

	local function load(object, force: boolean?)
		generation += 1
		local mine = generation
		target = object
		problem:set(nil)
		if object == nil then
			setSource("")
			status:set("")
			return
		end
		local mode = Settings.get("Decompiler")
		local hit = cache[object]
		if hit and hit.Mode == mode and not force then
			setSource(hit.Source)
			status:set(`{#lines} lines`)
			return
		end
		setSource("")
		if not Env.canDecompile(object) then
			problem:set(
				if Env.has("decompile") or Env.has("getscriptbytecode") then "Server scripts aren't on the client, so there's nothing to decompile."
					else "This executor can't decompile scripts."
			)
			status:set("")
			return
		end
		status:set("Decompiling")
		task.spawn(function()
			local started = os.clock()
			local text, failure = Env.decompile(object, mode)
			if mine ~= generation then
				return
			end
			if text == nil then
				problem:set(tostring(failure))
				status:set("")
				return
			end
			cache[object] = { Mode = mode, Source = text }
			setSource(text)
			status:set(`{#lines} lines · {string.format("%.1f", os.clock() - started)}s`)
		end)
	end

	table.insert(
		scope,
		scope:Observer(State.ScriptTarget):onBind(function()
			load(peek(State.ScriptTarget))
		end)
	)
	table.insert(
		scope,
		scope:Observer(Settings.state("Decompiler")):onChange(function()
			if target then
				load(target)
			end
		end)
	)

	-- Header -------------------------------------------------------------------------------
	local headerIcon = ClassIcon.new(
		scope,
		"LocalScript",
		{
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 14, 0.5, 0),
		}
	)
	local headerName = Controls.Label(
		scope,
		{
			Position = UDim2.fromOffset(40, 6),
			Size = UDim2.new(1, -170, 0, 18),
			TextSize = 14,
		}
	)
	local headerPath = Controls.Label(
		scope,
		{
			Position = UDim2.fromOffset(40, 23),
			Size = UDim2.new(1, -170, 0, 16),
			TextSize = 12,
			FontFace = Theme.Body,
			TextColor3 = Theme.Muted,
			Text = status,
		}
	)
	table.insert(
		scope,
		scope:Observer(State.ScriptTarget):onBind(function()
			local object = peek(State.ScriptTarget)
			if object then
				headerName.Text = object.Name
				ClassIcon.apply(headerIcon, object.ClassName)
			end
		end)
	)

	local function action(name, icon, order, onActivated)
		return Controls.IconButton(
			scope,
			{ Name = name, Icon = icon, Size = 30, LayoutOrder = order, OnActivated = onActivated }
		)
	end

	local header = scope:New("Frame")({
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		[Children] = {
			headerIcon,
			headerName,
			headerPath,
			scope:New("Frame")({
				Name = "Actions",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(0, 30),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				[Children] = {
					scope:New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					action(
						"Redo",
						"refresh-cw",
						1,
						function()
							if target then
								load(target, true)
							end
						end
					),
					action(
						"Copy",
						"copy",
						2,
						function()
							if source ~= "" then
								Actions.copy(source, "source")
							end
						end
					),
					action(
						"Save",
						"download",
						3,
						function()
							if target then
								Actions.saveScript(target)
							end
						end
					),
				},
			}),
		},
	})

	-- Find ---------------------------------------------------------------------------------
	local findCount = scope:Value("")
	local scrollToLine
	local function find(step: number)
		local text = string.lower(peek(findQuery))
		if text == "" then
			matches, matchLine = {}, nil
			findCount:set("")
			dirty = true
			return
		end
		if #matches == 0 or matches.Query ~= text then
			matches = { Query = text }
			for index, line in lines do
				if string.find(string.lower(line), text, 1, true) then
					table.insert(matches, index)
				end
			end
			matchAt = 0
		end
		if #matches == 0 then
			findCount:set("0")
			matchLine = nil
			dirty = true
			return
		end
		matchAt = (matchAt + step - 1) % #matches + 1
		matchLine = matches[matchAt]
		findCount:set(`{matchAt}/{#matches}`)
		scrollToLine(matchLine)
		dirty = true
	end
	table.insert(
		scope,
		scope:Observer(findQuery):onChange(function()
			matches = {}
			find(1)
		end)
	)

	local findField = Controls.Field(
		scope,
		{
			Name = "Find",
			Text = findQuery,
			Placeholder = "ค้นหา",
			Icon = "search",
			Height = 32,
			TrailingWidth = 110,
			OnSubmit = function()
				find(1)
			end,
			Trailing = scope:New("Frame")({
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -4, 0.5, 0),
				Size = UDim2.fromOffset(104, 26),
				BackgroundTransparency = 1,
				[Children] = {
					Controls.Label(
						scope,
						{
							Size = UDim2.new(1, -56, 1, 0),
							Text = findCount,
							TextSize = 11,
							FontFace = Theme.Body,
							TextColor3 = Theme.Muted,
							TextXAlignment = Enum.TextXAlignment.Right,
						}
					),
					Controls.IconButton(
						scope,
						{
							Position = UDim2.new(1, -52, 0, 0),
							Icon = "chevron-up",
							Size = 26,
							IconSize = 13,
							OnActivated = function()
								find(-1)
							end,
						}
					),
					Controls.IconButton(
						scope,
						{
							Position = UDim2.new(1, -26, 0, 0),
							Icon = "chevron-down",
							Size = 26,
							IconSize = 13,
							OnActivated = function()
								find(1)
							end,
						}
					),
				},
			}),
		}
	)
	findField.Position = UDim2.fromOffset(10, 48)
	findField.Size = UDim2.new(1, -20, 0, 32)

	-- Code ---------------------------------------------------------------------------------
	local scroll = scope:New("ScrollingFrame")({
		Name = "Code",
		Size = UDim2.new(1, -4, 1, -4),
		Position = UDim2.fromOffset(2, 2),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = if State.Touch then 0 else 4,
		ScrollBarImageColor3 = Theme.Ink,
		ScrollBarImageTransparency = 0.8,
	})
	table.insert(
		scope,
		scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			dirty = true
		end)
	)
	table.insert(
		scope,
		scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			dirty = true
		end)
	)

	scrollToLine = function(index: number)
		local height = scroll.AbsoluteWindowSize.Y
		local y = (index - 1) * LINE + PAD
		local top = scroll.CanvasPosition.Y
		if y < top or y + LINE > top + height then
			scroll.CanvasPosition = Vector2.new(0, math.max(0, y - height / 3))
		end
	end

	local body = scope:New("Frame")({
		Name = "Body",
		Position = UDim2.fromOffset(10, 88),
		Size = UDim2.new(1, -20, 1, -98),
		BackgroundColor3 = Theme.Ink,
		ClipsDescendants = true,
		[Children] = {
			Controls.Fill(scope, scope:Value(0.04)),
			Controls.Edge(scope, nil, UDim.new(0, 12)),
			scroll,
		},
	})

	local message = scope:New("Frame")({
		Name = "Problem",
		Position = UDim2.fromOffset(10, 88),
		Size = UDim2.new(1, -20, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Visible = scope:Computed(function(use)
			return use(problem) ~= nil
		end),
		[Children] = Controls.Banner(
			scope,
			{
				Icon = "triangle-alert",
				Ink = Theme.Caution,
				Text = scope:Computed(function(use)
					return "ดีคอมไพล์ไม่ได้: "
						.. (use(problem) or "")
						.. "\nTry another decompiler in Settings."
				end),
			}
		),
	})

	local empty = Controls.Empty(
		scope,
		{
			Name = "Empty",
			Icon = "code",
			Title = "คลิกขวาที่สคริปต์ แล้วเลือก ดูสคริปต์",
		}
	)
	empty.AnchorPoint = Vector2.new(0.5, 0.5)
	empty.Position = UDim2.fromScale(0.5, 0.45)

	local pool = {}
	local function newRow(index)
		local number = scope:New("TextLabel")({
			Name = "Number",
			BackgroundTransparency = 1,
			FontFace = Fonts.Mono,
			TextSize = TEXT,
			TextColor3 = Theme.Faint,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
		local code = scope:New("TextLabel")({
			Name = "Text",
			BackgroundTransparency = 1,
			RichText = true,
			FontFace = Fonts.Mono,
			TextSize = TEXT,
			TextColor3 = Theme.Ink2,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		local frame = scope:New("TextButton")({
			Name = "Line" .. index,
			Parent = scroll,
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			Visible = false,
			[Children] = { number, code },
		})
		local row = { Frame = frame, Number = number, Code = code, Line = 0 }
		for _, connection in Menu.bind(
			frame,
			function(point)
				local line = lines[row.Line]
				if line then
					Menu.open(
						point,
						{
							{
								Text = "คัดลอกบรรทัด",
								Icon = "copy",
								OnActivated = function()
									Actions.copy(line, "line")
								end,
							},
							{
								Text = "คัดลอกทั้งหมด",
								Icon = "files",
								OnActivated = function()
									Actions.copy(source, "source")
								end,
							},
						}
					)
				end
			end
		) do
			table.insert(scope, connection)
		end
		return row
	end

	local function render()
		dirty = false
		if resetCanvas then
			resetCanvas = false
			scroll.CanvasSize = UDim2.new()
			scroll.CanvasPosition = Vector2.zero
		end
		local hasTarget = peek(State.ScriptTarget) ~= nil
		empty.Visible = not hasTarget
		header.Visible = hasTarget
		findField.Visible = hasTarget
		body.Visible = hasTarget and peek(problem) == nil
		local count = if source == "" then 0 else #lines
		local gutter = #tostring(math.max(count, 1)) * CHAR + PAD * 2
		local widest = 0
		local height = scroll.AbsoluteWindowSize.Y
		local first = math.max(1, math.floor(math.max(0, scroll.CanvasPosition.Y - PAD) / LINE) + 1)
		local needed = math.ceil(height / LINE) + 2
		while #pool < needed do
			table.insert(pool, newRow(#pool + 1))
		end
		local colors = CodeTheme(peek(Theme.Surface))
		for slot, row in pool do
			local index = first + slot - 1
			if slot > needed or index > count then
				row.Frame.Visible = false
				continue
			end
			local text = lines[index]
			widest = math.max(widest, math.min(#text, LONG_LINE + 2))
			row.Line = index
			row.Frame.Visible = true
			row.Frame.Position = UDim2.fromOffset(0, (index - 1) * LINE + PAD)
			row.Frame.Size = UDim2.new(1, 0, 0, LINE)
			row.Frame.BackgroundTransparency = if index == matchLine then 0.82 else 1
			row.Number.Position = UDim2.fromOffset(0, 0)
			row.Number.Size = UDim2.fromOffset(gutter - PAD, LINE)
			row.Number.Text = tostring(index)
			row.Code.Position = UDim2.fromOffset(gutter, 0)
			row.Code.Size = UDim2.fromOffset(math.min(#text, LONG_LINE + 2) * CHAR + 20, LINE)
			row.Code.Text = richLine(index, colors)
		end
		-- The canvas is as wide as the widest line seen so far, so it never jumps narrower.
		local canvasWidth = math.max(scroll.CanvasSize.X.Offset, gutter + widest * CHAR + PAD * 3)
		if count == 0 then
			canvasWidth = 0
		end
		scroll.CanvasSize = UDim2.fromOffset(canvasWidth, count * LINE + PAD * 2)
	end

	table.insert(
		scope,
		RunService.Heartbeat:Connect(function()
			if dirty then
				render()
			end
		end)
	)
	table.insert(
		scope,
		scope:Observer(problem):onChange(function()
			dirty = true
		end)
	)
	table.insert(
		scope,
		scope:Observer(Theme.Surface):onChange(function()
			rich = {}
			dirty = true
		end)
	)

	local pane = scope:New("Frame")({
		Name = "Script",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		[Children] = { header, findField, body, message, empty },
	})
	return { Instance = pane }
end

return ScriptViewer

end)() end,
    function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)--!nocheck
-- Settings, what this executor supports, and credits.

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local EthosTheme = require(Root.ui.theme)
local Env = require(Root.core.env)
local Api = require(Root.core.api)
local Settings = require(Root.core.settings)
local State = require(script.Parent.state)
local Menu = require(script.Parent.menu)
local Picker = require(script.Parent.picker)
local Toast = require(script.Parent.toast)
local Actions = require(script.Parent.actions)

local Children = Fusion.Children
local peek = Fusion.peek

local UserInputService = Env.service("UserInputService")

local SettingsPage = {}

local function titleCase(text: string): string
	return (string.gsub(
		text,
		"(%a)([%w']*)",
		function(first, rest)
			return string.upper(first) .. rest
		end
	))
end

function SettingsPage.new(scope)
	local function switchRow(
		key: string,
		title: string,
		description: string?,
		reason: string?,
		onChange: (() -> ())?
	)
		local state = Settings.state(key)
		return Controls.Row(
			scope,
			{
				Title = title,
				Description = description,
				Disabled = reason,
				Switch = {
					On = state,
					Set = function(value)
						Settings.set(key, value)
						if onChange then
							onChange()
						end
					end,
				},
			}
		)
	end

	local listening = scope:Value(false)
	local keyText = scope:Computed(function(use)
		return if use(listening) then "Press a key" else use(Settings.state("ToggleKey"))
	end)

	local capabilityRows = {}
	for _, feature in Env.FEATURES do
		local supported = Env.supports(feature)
		local missing = {}
		for _, name in feature.Needs do
			if not Env.has(name) then
				table.insert(missing, name)
			end
		end
		table.insert(
			capabilityRows,
			Controls.Row(
				scope,
				{
					Title = feature.Name,
					Icon = if supported then "check" else "x",
					Description = if supported then nil
						else "Missing "
							.. table.concat(missing, if feature.Any then " and " else ", "),
				}
			)
		)
	end

	local apiState = scope:Value(Api.Status)
	Api.onReady(function()
		apiState:set(Api.Status)
	end)

	local content = {
		Controls.Group(
			scope,
			{
				Title = "การแสดงผล",
				Rows = {
					Controls.Row(
						scope,
						{
							Title = "ธีม",
							Detail = scope:Computed(function(use)
								return titleCase(use(Settings.state("Theme")))
							end),
							Chevron = true,
							OnActivated = function()
								local names = EthosTheme.GetSupportedThemes()
								local items = {}
								for _, name in names do
									table.insert(items, name)
								end
								table.sort(items)
								Picker.open({
									Title = "ธีม",
									Items = items,
									Current = Settings.get("Theme"),
									OnPick = function(name)
										Settings.set("Theme", name)
									end,
								})
							end,
						}
					),
				},
			}
		),
		Controls.Group(
			scope,
			{
				Title = "เอ็กซ์พลอเรอร์",
				Rows = {
					switchRow(
						"ShowNil",
						"Nil instances",
						"Instances parented to nothing, as a folder at the bottom",
						if Env.has("getnilinstances") then nil else "ต้องมี getnilinstances",
						function()
							State.Hooks.rebuildTree()
						end
					),
					Controls.Row(
						scope,
						{
							Title = "ย่อทั้งหมด",
							Chevron = true,
							OnActivated = function()
								State.Hooks.collapseAll()
							end,
						}
					),
				},
			}
		),
		Controls.Group(
			scope,
			{
				Title = "พรอเพอร์ตี้",
				Rows = {
					switchRow(
						"ShowHidden",
						"พรอเพอร์ตี้ที่ซ่อน",
						"พรอเพอร์ตี้ที่ Roblox ซ่อนจากสคริปต์",
						if Env.has("gethiddenproperty") then nil else "ต้องมี gethiddenproperty"
					),
					switchRow("ShowDeprecated", "พรอเพอร์ตี้ที่เลิกใช้แล้ว"),
				},
			}
		),
		Controls.Group(
			scope,
			{
				Title = "สคริปต์",
				Rows = {
					Controls.Row(
						scope,
						{
							Title = "ดีคอมไพเลอร์",
							Description = "Auto จะลองของ executor ก่อน แล้ว Advanced Decompiler แล้ว Konstant",
							Detail = Settings.state("Decompiler"),
							Chevron = true,
							OnActivated = function()
								local items = {}
								for _, mode in Env.DECOMPILERS do
									local reason = nil
									if mode == "Executor" and not Env.has("decompile") then
										reason = "Unsupported"
									elseif mode == "Advanced"
										and not (Env.has("getscriptbytecode")
											and Env.has("loadstring")) then
										reason = "Unsupported"
									elseif mode == "Konstant"
										and not (Env.has("getscriptbytecode") and Env.has("request")) then
										reason = "Unsupported"
									end
									table.insert(
										items,
										{
											Text = mode,
											Icon = if Settings.get("Decompiler") == mode then "check"
												else nil,
											Disabled = reason,
											Detail = reason,
											OnActivated = function()
												Settings.set("Decompiler", mode)
											end,
										}
									)
								end
								Menu.open(
									UserInputService:GetMouseLocation()
										- Env.service("GuiService"):GetGuiInset(),
									items
								)
							end,
						}
					),
					switchRow(
						"SaveDecompile",
						"ดีคอมไพล์เมื่อบันทึกอินสแตนซ์",
						"Slower, but saved scripts keep their source"
					),
				},
			}
		),
		Controls.Group(
			scope,
			{
				Title = "หน้าต่าง",
				Rows = {
					Controls.Row(
						scope,
						{
							Title = "ปุ่มแสดง/ซ่อน",
							Description = if State.Touch then "บนจอสัมผัส ให้แตะปุ่มลอย"
								else nil,
							Detail = keyText,
							Chevron = true,
							OnActivated = function()
								if peek(listening) then
									return
								end
								listening:set(true)
								local connection
								connection = UserInputService.InputBegan:Connect(function(input)
									if input.UserInputType == Enum.UserInputType.Keyboard then
										connection:Disconnect()
										if input.KeyCode ~= Enum.KeyCode.Escape then
											Settings.set("ToggleKey", input.KeyCode.Name)
										end
										listening:set(false)
									end
								end)
								table.insert(scope, connection)
							end,
						}
					),
				},
			}
		),
		Controls.Group(
			scope,
			{
				Title = "เครื่องมือ",
				Rows = {
					Controls.Row(
						scope,
						{
							Title = "บันทึกแมพ",
							Description = "เขียนไฟล์ .rbxlx ไปที่ workspace/EthosDex/saves",
							Icon = "save",
							Chevron = true,
							Disabled = if Env.canWrite()
									and (Env.has("saveinstance") or Env.has("loadstring")) then nil
								else "ต้องมี saveinstance และสิทธิ์เข้าถึงไฟล์",
							OnActivated = function()
								Actions.saveInstance({ game })
							end,
						}
					),
					Controls.Row(
						scope,
						{
							Title = "โหลด Roblox API ใหม่",
							Description = scope:Computed(function(use)
								local status = use(apiState)
								return if status == "ready" then `Loaded {Api.Version or "from the mirror"}`
									elseif status == "failed" then "Couldn't load: "
										.. tostring(Api.Problem)
									else "กำลังโหลด"
							end),
							Icon = "refresh-cw",
							Chevron = true,
							OnActivated = function()
								if Env.canWrite() and Env.raw.delfile and Api.Version then
									pcall(
										Env.raw.delfile,
										`{Env.ROOT}/cache/api-{Api.Version}.json`
									)
									pcall(Env.raw.delfile, `{Env.ROOT}/cache/rmd-{Api.Version}.xml`)
								end
								Api.Status = "idle"
								apiState:set("loading")
								task.spawn(function()
									Api.load()
									apiState:set(Api.Status)
									State.Hooks.rebuildTree()
									Toast.show(
										if Api.Status == "ready" then "โหลด Roblox API ใหม่แล้ว"
											else "โหลด API ใหม่ไม่ได้",
										if Api.Status == "ready" then "success" else "error"
									)
								end)
							end,
						}
					),
				},
			}
		),
		Controls.Group(
			scope,
			{
				Title = "Executor นี้: " .. Env.executor,
				Rows = capabilityRows,
			}
		),
		Controls.Group(
			scope,
			{
				Title = "เครดิต",
				Rows = {
					Controls.Row(
						scope,
						{
							Title = "jashan",
							Description = "@jasha.n บน Discord",
							Icon = "discord",
							Detail = "คัดลอก",
							OnActivated = function()
								Actions.copy("jasha.n", "Discord username")
							end,
						}
					),
					Controls.Row(
						scope,
						{
							Title = "ได้แรงบันดาลใจจาก Dex",
							Description = "Dex ของ Moon และ Dex++ ของ Chillz",
						}
					),
				},
			}
		),
	}
	for index, group in content do
		group.LayoutOrder = index
	end

	local pane = scope:New("ScrollingFrame")({
		Name = "Settings",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Ink,
		ScrollBarImageTransparency = 0.8,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 16),
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
			}),
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 16),
			}),
			content,
		},
	})
	return { Instance = pane }
end

return SettingsPage

end)() end,
    function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)--!nocheck
-- What the panels share: the selection, the open tab, and the device's layout.

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Internal = require(Root.packages.internal)
local Env = require(Root.core.env)

local scope = Internal.Scope
local peek = Fusion.peek

local UserInputService = Env.service("UserInputService")

local State = {}

State.Game = game
State.LocalPlayer = Env.service("Players").LocalPlayer

-- Array of instances; always set a new table.
State.Selection = scope:Value({})
State.Tab = scope:Value("Properties")
State.ScriptTarget = scope:Value(nil)
State.PreviewTarget = scope:Value(nil)
-- Phones: one column, the explorer or the panel.
State.Compact = scope:Value(false)
State.MobileView = scope:Value("explorer")
State.Touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
-- Tap adds to the selection instead of replacing it (touch has no Ctrl).
State.MultiSelect = scope:Value(false)

State.ROW = if State.Touch then 32 else 24

function State.selection(): { Instance }
	return peek(State.Selection)
end

function State.first(): Instance?
	return peek(State.Selection)[1]
end

function State.select(list: { Instance })
	State.Selection:set(table.clone(list))
end

function State.isSelected(instance): boolean
	return table.find(peek(State.Selection), instance) ~= nil
end

-- Opens a panel tab; on phones, also flips to the panel.
function State.open(tab: string)
	State.Tab:set(tab)
	if peek(State.Compact) then
		State.MobileView:set("panel")
	end
end

-- Hooks the panels register so actions can reach them without importing them.
State.Hooks = {}

return State

end)() end,
    function()local wax,script,require=ImportGlobals(14)local ImportGlobals return (function(...)--!nocheck
-- One-line notices at the bottom of the screen; the newest replaces the last.

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)

local Children = Fusion.Children

local Toast = {}
local layer = nil
local current = nil
local generation = 0

function Toast.setLayer(frame: GuiObject)
	layer = frame
end

-- kind: "info" | "success" | "error"
function Toast.show(text: string, kind: string?)
	if layer == nil then
		return
	end
	text = if #text > 96 then string.sub(text, 1, 93) .. "..." else text
	if current then
		Fusion.doCleanup(current)
	end
	generation += 1
	local mine = generation
	local scope = Fusion.scoped(Fusion)
	current = scope
	local ink = if kind == "error" then Theme.Danger
		elseif kind == "success" then Theme.Success
		else Theme.Ink2
	local icon = if kind == "error" then "circle-alert"
		elseif kind == "success" then "check"
		else "info"
	scope:New("Frame")({
		Name = "Toast",
		Parent = layer,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 36),
		BackgroundColor3 = Theme.Surface,
		ZIndex = 600,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
			scope:New("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Theme.Ink,
				Transparency = 0.86,
			}),
			scope:New("UISizeConstraint")({ MaxSize = Vector2.new(520, 36) }),
			scope:New("UIPadding")({
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 16),
			}),
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Controls.Icon(scope, icon, 15, { LayoutOrder = 1, ImageColor3 = ink }),
			Controls.Label(
				scope,
				{
					LayoutOrder = 2,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 36),
					Text = text,
					TextSize = 13,
					TextTruncate = Enum.TextTruncate.None,
				}
			),
		},
	})
	task.delay(
		if kind == "error" then 4 else 2.5,
		function()
			if generation == mine and current == scope then
				current = nil
				Fusion.doCleanup(scope)
			end
		end
	)
end

return Toast

end)() end,
    function()local wax,script,require=ImportGlobals(15)local ImportGlobals return (function(...)--!nocheck
--[[
	The window: Ethos's two-layer body with the explorer on the left and the inset panel on the
	right, a splitter between them, dragging by either header, a corner grip to resize, maximize,
	and minimize to a floating bubble (the only way back on touch, where there's no keybind).
	Below 720px wide it becomes a phone layout: full screen, one column at a time.

	props: Layer, Explorer (frame), Panel (frame), Title (frame for the panel topbar's left),
	Actions (frame for its right), OnClose.
	Returns { Instance, Open (Value), Maximized (Value), Toggle (), DragHandles (fn) }.
]]

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Controls = require(Root.ui.controls)
local Theme = require(Root.ui.tokens)
local Icons = require(Root.ui.icons.dock)
local Pointer = require(Root.ui.pointer)
local Settings = require(Root.core.settings)
local State = require(script.Parent.state)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local RADIUS = 18
local INSET = 8
local MIN = Vector2.new(560, 360)
local COMPACT_WIDTH = 720
local EXPLORER_MIN, EXPLORER_MAX = 200, 520
local LOW_FADE = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.7, 1),
	NumberSequenceKeypoint.new(0.85, 0.55),
	NumberSequenceKeypoint.new(1, 0.1),
})

local Window = {}

function Window.new(scope, props)
	local layer = props.Layer
	local room = scope:Value(layer.AbsoluteSize)
	table.insert(
		scope,
		layer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			room:set(layer.AbsoluteSize)
		end)
	)

	local compact = State.Compact
	local function updateCompact()
		compact:set(peek(room).X < COMPACT_WIDTH)
	end
	updateCompact()
	table.insert(scope, scope:Observer(room):onChange(updateCompact))

	local open = scope:Value(true)
	local maximized = scope:Value(false)
	local size = scope:Value(Vector2.new(Settings.get("WindowWidth"), Settings.get("WindowHeight")))
	local offset = scope:Value(nil) -- top-left; nil centres it
	local explorerWidth = scope:Value(Settings.get("ExplorerWidth"))

	local function clampSize(want: Vector2): Vector2
		local space = peek(room)
		return Vector2.new(
			math.clamp(want.X, MIN.X, math.max(MIN.X, space.X - 16)),
			math.clamp(want.Y, MIN.Y, math.max(MIN.Y, space.Y - 16))
		)
	end

	-- The window's rectangle as drawn: phone and maximized fill the room.
	local rect = scope:Computed(function(use)
		local space = use(room)
		if use(compact) then
			return { At = Vector2.new(6, 6), Size = space - Vector2.new(12, 12) }
		elseif use(maximized) then
			return { At = Vector2.new(12, 12), Size = space - Vector2.new(24, 24) }
		end
		local shown = Vector2.new(
			math.clamp(use(size).X, MIN.X, math.max(MIN.X, space.X - 16)),
			math.clamp(use(size).Y, MIN.Y, math.max(MIN.Y, space.Y - 16))
		)
		local at = use(offset) or (space - shown) / 2
		at = Vector2.new(
			math.clamp(at.X, 8 - shown.X + 120, space.X - 120),
			math.clamp(at.Y, 0, space.Y - 48)
		)
		return { At = at, Size = shown }
	end)
	local rectPosition = scope:Computed(function(use)
		local at = use(rect).At
		return UDim2.fromOffset(math.round(at.X), math.round(at.Y))
	end)
	local rectSize = scope:Computed(function(use)
		local shown = use(rect).Size
		return UDim2.fromOffset(math.round(shown.X), math.round(shown.Y))
	end)

	-- Explorer width as drawn; on phones each column takes the whole window.
	local leftWidth = scope:Computed(function(use)
		local shown = use(rect).Size
		if use(compact) then
			return if use(State.MobileView) == "explorer" then shown.X else 0
		end
		return math.clamp(use(explorerWidth), EXPLORER_MIN, math.min(EXPLORER_MAX, shown.X - 320))
	end)

	local function beginDrag(input)
		if not Pointer.isPress(input) or peek(compact) or peek(maximized) then
			return
		end
		local start = Vector2.new(input.Position.X, input.Position.Y)
		local origin = peek(rect).At
		Pointer.drag(
			scope,
			function(point)
				offset:set(origin + (point - start) / props.Scale())
			end
		)
	end

	local function dragHandle(frame: GuiObject)
		table.insert(scope, frame.InputBegan:Connect(beginDrag))
	end

	local grip = scope:New("TextButton")({
		Name = "ResizeGrip",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 20,
		Visible = scope:Computed(function(use)
			return not use(compact) and not use(maximized)
		end),
		[OnEvent("InputBegan")] = function(input)
			if not Pointer.isPress(input) then
				return
			end
			local start = Vector2.new(input.Position.X, input.Position.Y)
			local at, startSize = peek(rect).At, peek(rect).Size
			offset:set(at)
			Pointer.drag(
				scope,
				function(point)
					size:set(clampSize(startSize + (point - start) / props.Scale()))
				end,
				function()
					local final = peek(size)
					Settings.set("WindowWidth", math.round(final.X))
					Settings.set("WindowHeight", math.round(final.Y))
				end
			)
		end,
		[Children] = Controls.Icon(
			scope,
			"grip-vertical",
			12,
			{
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Rotation = -45,
				ImageColor3 = Theme.Faint,
			}
		),
	})

	local splitterHover = scope:Value(false)
	local splitter = scope:New("TextButton")({
		Name = "Splitter",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = scope:Computed(function(use)
			return UDim2.new(0, use(leftWidth) + INSET / 2, 0, 0)
		end),
		Size = UDim2.new(0, 8, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 5,
		Visible = scope:Computed(function(use)
			return not use(compact)
		end),
		[OnEvent("MouseEnter")] = function()
			splitterHover:set(true)
		end,
		[OnEvent("MouseLeave")] = function()
			splitterHover:set(false)
		end,
		[OnEvent("InputBegan")] = function(input)
			if not Pointer.isPress(input) then
				return
			end
			local start = input.Position.X
			local from = peek(leftWidth)
			Pointer.drag(
				scope,
				function(point)
					explorerWidth:set(
						math.clamp(
							from + (point.X - start) / props.Scale(),
							EXPLORER_MIN,
							EXPLORER_MAX
						)
					)
				end,
				function()
					Settings.set("ExplorerWidth", math.round(peek(explorerWidth)))
				end
			)
		end,
		[Children] = scope:New("Frame")({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 2, 0, 36),
			BackgroundColor3 = Theme.Ink,
			BackgroundTransparency = scope:Computed(function(use)
				return if use(splitterHover) then 0.7 else 1
			end),
			[Children] = scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
		}),
	})

	local explorer = scope:Hydrate(props.Explorer)({
		Position = UDim2.fromOffset(0, 0),
		Size = scope:Computed(function(use)
			return UDim2.new(0, use(leftWidth), 1, 0)
		end),
		Visible = scope:Computed(function(use)
			return not use(compact) or use(State.MobileView) == "explorer"
		end),
	})

	local panelVisible = scope:Computed(function(use)
		return not use(compact) or use(State.MobileView) == "panel"
	end)
	local panel = scope:New("Frame")({
		Name = "Panel",
		Position = scope:Computed(function(use)
			return UDim2.fromOffset(if use(compact) then INSET else use(leftWidth), INSET)
		end),
		Size = scope:Computed(function(use)
			local left = if use(compact) then INSET else use(leftWidth)
			return UDim2.new(1, -left - INSET, 1, -INSET * 2)
		end),
		BackgroundColor3 = Theme.Ink,
		Visible = panelVisible,
		ClipsDescendants = true,
		[Children] = {
			Controls.Fill(scope, scope:Value(0.03)),
			Controls.Edge(scope, scope:Value(0.5), UDim.new(0, 14)),
			props.Panel,
		},
	})

	local frame = scope:New("Frame")({
		Name = "EthosDex",
		Parent = layer,
		Position = rectPosition,
		Size = rectSize,
		BackgroundTransparency = 1,
		Visible = open,
		ZIndex = 10,
		[Children] = {
			scope:New("ImageLabel")({
				Name = "Shadow",
				Position = UDim2.fromOffset(-12, -8),
				Size = UDim2.new(1, 24, 1, 24),
				BackgroundTransparency = 1,
				Image = Icons.shadow,
				ImageColor3 = Color3.new(0, 0, 0),
				ImageTransparency = 0.6,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(164, 164, 166, 166),
				SliceScale = 0.25,
			}),
			scope:New("Frame")({
				Name = "Body",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Theme.Surface,
				ClipsDescendants = true,
				BorderSizePixel = 0,
				Active = true,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0, RADIUS) }),
					scope:New("Frame")({
						Name = "Low",
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Theme.SurfaceLow,
						BorderSizePixel = 0,
						[Children] = {
							scope:New("UICorner")({ CornerRadius = UDim.new(0, RADIUS) }),
							scope:New("UIGradient")({ Rotation = 90, Transparency = LOW_FADE }),
						},
					}),
					explorer,
					panel,
					splitter,
					grip,
				},
			}),
			scope:New("Frame")({
				Name = "Rim",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 3,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0, RADIUS) }),
					scope:New("UIStroke")({
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						Color = Theme.Ink,
						Transparency = 0.9,
						[Children] = scope:New("UIGradient")({
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(0.4, 0.5),
								NumberSequenceKeypoint.new(1, 0.8),
							}),
						}),
					}),
				},
			}),
		},
	})

	-- The floating bubble: shown while the window is hidden; drag it anywhere, tap to reopen.
	local bubbleAt = scope:Value(nil)
	local bubbleMoved = false
	scope:New("TextButton")({
		Name = "Bubble",
		Parent = layer,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = scope:Computed(function(use)
			local at = use(bubbleAt)
			local space = use(room)
			at = at or Vector2.new(space.X - 40, space.Y * 0.35)
			return UDim2.fromOffset(
				math.clamp(at.X, 24, space.X - 24),
				math.clamp(at.Y, 24, space.Y - 24)
			)
		end),
		Size = UDim2.fromOffset(46, 46),
		BackgroundColor3 = Theme.Surface,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 50,
		Visible = scope:Computed(function(use)
			return not use(open)
		end),
		[OnEvent("InputBegan")] = function(input)
			if not Pointer.isPress(input) then
				return
			end
			bubbleMoved = false
			local start = Vector2.new(input.Position.X, input.Position.Y)
			local space = peek(room)
			local origin = peek(bubbleAt) or Vector2.new(space.X - 40, space.Y * 0.35)
			Pointer.drag(
				scope,
				function(point)
					local delta = (point - start) / props.Scale()
					if delta.Magnitude > 6 then
						bubbleMoved = true
					end
					bubbleAt:set(origin + delta)
				end
			)
		end,
		[OnEvent("Activated")] = function()
			if not bubbleMoved then
				open:set(true)
			end
		end,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
			scope:New("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Theme.Ink,
				Transparency = 0.82,
			}),
			Controls.Icon(
				scope,
				"ethos-e",
				22,
				{
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				}
			),
		},
	})

	return {
		Instance = frame,
		Panel = panel,
		Open = open,
		Maximized = maximized,
		Toggle = function()
			open:set(not peek(open))
		end,
		DragHandle = dragHandle,
	}
end

return Window

end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)--!strict
local HttpService = game:GetService("HttpService")
local Data = require(script.Parent.ethosIconsFont)

local FOLDER = "Ethos Suite/fonts"
local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local VALUES = {}
for index = 1, #ALPHABET do
	VALUES[string.byte(ALPHABET, index)] = index - 1
end

local EthosIcons = {}
EthosIcons.Path = `{FOLDER}/ethos-icons-{Data.Version}`

local face: Font? = nil
local failure: string? = nil

function EthosIcons.decode(text: string): string
	local padding = if string.sub(text, -2) == "==" then 2
		elseif string.sub(text, -1) == "=" then 1
		else 0
	local length = #text // 4 * 3 - padding
	local output = buffer.create(length)
	local offset = 0
	for index = 1, #text, 4 do
		local a, b, c, d = string.byte(text, index, index + 3)
		local value = VALUES[a] * 262144
			+ VALUES[b] * 4096
			+ (VALUES[c] or 0) * 64
			+ (VALUES[d] or 0)
		for shift = 16, 0, -8 do
			if offset < length then
				buffer.writeu8(output, offset, bit32.extract(value, shift, 8))
				offset += 1
			end
		end
	end
	return buffer.tostring(output)
end

local function load(): (Font?, string?)
	if face or failure then
		return face, failure
	end
	local ok, result = pcall(function()
		assert(
			typeof(isfile) == "function"
				and typeof(isfolder) == "function"
				and typeof(makefolder) == "function"
				and typeof(writefile) == "function"
				and typeof(getcustomasset) == "function",
			"Custom assets are unavailable"
		)
		local current = ""
		for _, part in string.split(FOLDER, "/") do
			current = if current == "" then part else `{current}/{part}`
			if not isfolder(current) then
				makefolder(current)
			end
		end
		local ttf = EthosIcons.Path .. ".ttf"
		if not isfile(ttf) then
			writefile(ttf, EthosIcons.decode(Data.Font))
		end
		writefile(
			EthosIcons.Path .. ".json",
			HttpService:JSONEncode({
				name = "Ethos Icons",
				loadStrategy = "sameFamilyOnly",
				faces = {
					{
						name = "Regular",
						weight = 400,
						style = "normal",
						assetId = getcustomasset(ttf),
					},
				},
			})
		)
		return Font.new(getcustomasset(EthosIcons.Path .. ".json"))
	end)
	if ok then
		face = result
	else
		failure = tostring(result)
	end
	return face, failure
end

function EthosIcons.Has(name: string): boolean
	return Data.Icons[name] ~= nil
end

function EthosIcons.Fallback(name: string): string?
	return Data.Icons[name]
end

function EthosIcons.GetFontAsset(name: string)
	if Data.Icons[name] == nil then
		return nil, "Unknown icon."
	end
	local font, message = load()
	if font == nil then
		return nil, message
	end
	return { FontFace = font, Text = name }, nil
end

return table.freeze(EthosIcons)

end)() end,
    [18] = function()local wax,script,require=ImportGlobals(18)local ImportGlobals return (function(...)return table.freeze({
	Version = "9ae5848c315ff388",
	Font = "AAEAAAALAIAAAwAwR1NVQrLcudgAAAE4AAAGjk9TLzJWUFKBAAAHyAAAAGBjbWFwdPsjdwAACVwAAAW4Z2x5ZlL019cAAA+wAAA0bGhlYWQxDLsAAAAA4AAAADZoaGVhB8IENQAAALwAAAAkaG10eMsg/+8AAAgoAAABNGxvY2GFBJLwAAAPFAAAAJxtYXhwAV4AswAAARgAAAAgbmFtZbSp01gAAEQcAAACOnBvc3TWGm6OAABGWAAAA7oAAQAAA+gAAAAAA+j/7///A+kAAQAAAAAAAAAAAAAAAAAAAE0AAQAAAAEAAJHcD3FfDzz1AAsD6AAAAADnCzsWAAAAAOcLOxb/7wAAA+kD7wAAAAgAAgAAAAAAAAABAAAATQCnAAcAAAAAAAIAAAAKAAoAAAD/AAAAAAAAAAEAAAAKADAAPgACREZMVAAObGF0bgAaAAQAAAAAAAAAAQAAAAQAAAAAAAAAAQAAAAFsaWdhAAgAAAABAAAAAQAEAAQAAAABAAgAAQY4AAQADgTWBOoGHAAnAFAAfACiAMgA7gESATYBWgF+AaABwgHkAgYCJgJGAmYChgKmAsQC4gMAAx4DPANYA3IDjAOmA8AD2APwBAgEIAQ4BE4EZAR6BJAEpAS4ACAAFQA2ADcAOAA5ADoASwA/ADUAOwBCAEQANwA6AEsAOQA7ADwAQgA3AEUABQASADYANwA4ADkAOgBAAEEANwBGADsAPAA4ADoARQA8AD0AOAAYABIANgA3ADgAOQA6ADgANQBGADoASwA3ADkAOQBHADgANgBLABoAEgA2ADcAOAA5ADoAOAA1AEYAOgA+AEsANwA7ADoANQBFAEUAEAARADYANwA4ADkAOgA4ADUARgA6AEAAQQA3AEYAOwA8ADgAEgARADYANwA4ADkAOgA4ADUARgA6AEAAPABMAD8APABLADcAGQARADYANwA4ADkAOgA4ADUARgA6AEsARwBFADcAQwA1ADsAIwARADYANwA4ADkAOgA5AEEAPgBMAEMASwA6AEUAPAA9ADgAAwAQADYANwA4ADkAOgBAAEEANwBAAEIAOgBDADwARABFAAMAEAA2ADcAOAA5ADoAQAA8AEUANwA6AEAAQQA3AEAAQgAVABAANgA3ADgAOQA6ADgANQBGADoARAA8ADYAPAA+ADkAFwAQADYANwA4ADkAOgA4ADUARgA6AEsANwA1ADsAQABBAAgADwA2ADcAOAA5ADoAQAA8AEUANwA6AEAAPAA/AEkACQAPADYANwA4ADkAOgBAADwARQA3ADoASgBHAEQANwAPAA8ANgA3ADgAOQA6ADgANQBGADoAQABBADcAQABCABEADwA2ADcAOAA5ADoAOAA1AEYAOgBAAEQAPABLADcAJAAPADYANwA4ADkAOgA5AEEAPgBMAEMASwA6AD4APwABAA4ANgA3ADgAOQA6ADUAOwA7ADwAPQA6AD4APwATAA4ANgA3ADgAOQA6ADgANQBGADoAQQA8AEwANwAUAA4ANgA3ADgAOQA6ADgANQBGADoARAA8ADYAPAAWAA4ANgA3ADgAOQA6ADgANQBGADoAPwBEAD4ASwAiAA4ANgA3ADgAOQA6ADkANwA7AEwARwA4ADUARAAhAA0ANgA3ADgAOQA6AEsAPwA1ADsAQgBEADcABgAMADYANwA4ADkAOgBAAEEARwA/ADoASAANAAwANgA3ADgAOQA6AEQANQBJADcAOwBLABsADAA2ADcAOAA5ADoAPwA3ADgAQABHAEQAHwAMADYANwA4ADkAOgBLADcANQA7AEAAQQACAAsANgA3ADgAOQA6AEAAQQA1ADsAOQAEAAsANgA3ADgAOQA6AEAAQQA3AEAAQgAMAAsANgA3ADgAOQA6ADYARAA8AEMANwAdAAsANgA3ADgAOQA6ADsANwA/AEQASQAeAAsANgA3ADgAOQA6ADsANwA5ADsASQAHAAoANgA3ADgAOQA6AEAARABHAD8ACgAKADYANwA4ADkAOgBAADwAPwBJAAsACgA2ADcAOAA5ADoASgBHAEQANwAcAAoANgA3ADgAOQA6AD8ARAA+AEsADgAJADYANwA4ADkAOgBMAEcAQAAlAAkANgA3ADgAOQA6AD0ANwBDACYABwA2ADcAOAA5ADoASAABAAQAMwAHADkAQQA8AEsAOgA3AAwAGgA4AFQAbgCIAKAAuADQAOYA+gEOASIALAAOADwAQABCADoARAA8AEAANQA5AEcAPAA4AEsALwANADwAQABCADoAPwA7ADwASgBHAEQANwBLAC4ADAA8AEAAQgA6AD8ARAA1AEkANwA7AEsAMQAMADwAQABCADoASwA3AEsASwBHADwAOAAoAAsAPABAAEIAOgBAADUATAA3ADsANQAtAAsAPABAAEIAOgA/ADcAOwBLADwAOAAwAAsAPABAAEIAOgBLAEAAOwBHAD8AOQAyAAoAPABAAEIAOgA9ADwAOwBEAEUAKQAJADwAQABCADoANgA1AEwANwAqAAkAPABAAEIAOgA2ADcANQA7ACsACQA8AEAAQgA6AEEAPABMADcAJwAHAEcASwBAADwAOwBFAAEABAA0AAsAOQA1ADsAOgBKAEcARABEADcARQABAAQANQA3AEUASwAAAAQCowGQAAUAAAJ6ArwAAACMAnoCvAAAAeAAMQECAAACAAUDAAAAAAAAAAAAARAAAAAAAAAAAAAAAFBmRWQAwAAt4DQD6AAAAFoEQgAAAAAAAQAAAAAAAAAAAAAAAAAVAAAAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+j/7wPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAD6AAAA+gAAAPoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFAAAAAwAAACwAAAAEAAACDAABAAAAAAEGAAMAAQAAACwAAwAKAAACDAAEANoAAAAMAAgAAgAEAC0AaQBwAHngNP//AAAALQBhAGsAcuAA//8AAAAAAAAAAAAAAAEADAAMABwAJgA0AAAAOgA1AEMAQABFADcASgA2AEEARwBCAEQATAA4ADwAPwA7AEsAOQA+AEYAPQBIAEkAAQACAAQAAwAFAAYABwADAAgACQAKAAsADAANAA4ADwAQABEAEgATABQAFQAWABcAGAAZABoAGwAcAB0AHgAfACEAIAAiACMAJAAlACYAJwAoACkAKgArACwALQAuAC8AMAAxADIAMwA0AAABBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAOgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADVDQEU3SjZBRwBCREw4PD8AO0s5PkY9SEkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAOsAAAAAAAAAE0AAAAtAAAALQAAADoAAABhAAAAYQAAADUAAABiAAAAYgAAAEMAAABjAAAAYwAAAEAAAABkAAAAZAAAAEUAAABlAAAAZQAAADcAAABmAAAAZgAAAEoAAABnAAAAZwAAADYAAABoAAAAaAAAAEEAAABpAAAAaQAAAEcAAABrAAAAawAAAEIAAABsAAAAbAAAAEQAAABtAAAAbQAAAEwAAABuAAAAbgAAADgAAABvAAAAbwAAADwAAABwAAAAcAAAAD8AAAByAAAAcgAAADsAAABzAAAAcwAAAEsAAAB0AAAAdAAAADkAAAB1AAAAdQAAAD4AAAB2AAAAdgAAAEYAAAB3AAAAdwAAAD0AAAB4AAAAeAAAAEgAAAB5AAAAeQAAAEkAAOAAAADgAAAAAAEAAOABAADgAQAAAAIAAOACAADgAgAAAAQAAOADAADgAwAAAAMAAOAEAADgBAAAAAUAAOAFAADgBQAAAAYAAOAGAADgBgAAAAcAAOAHAADgBwAAAAMAAOAIAADgCAAAAAgAAOAJAADgCQAAAAkAAOAKAADgCgAAAAoAAOALAADgCwAAAAsAAOAMAADgDAAAAAwAAOANAADgDQAAAA0AAOAOAADgDgAAAA4AAOAPAADgDwAAAA8AAOAQAADgEAAAABAAAOARAADgEQAAABEAAOASAADgEgAAABIAAOATAADgEwAAABMAAOAUAADgFAAAABQAAOAVAADgFQAAABUAAOAWAADgFgAAABYAAOAXAADgFwAAABcAAOAYAADgGAAAABgAAOAZAADgGQAAABkAAOAaAADgGgAAABoAAOAbAADgGwAAABsAAOAcAADgHAAAABwAAOAdAADgHQAAAB0AAOAeAADgHgAAAB4AAOAfAADgHwAAAB8AAOAgAADgIAAAACEAAOAhAADgIQAAACAAAOAiAADgIgAAACIAAOAjAADgIwAAACMAAOAkAADgJAAAACQAAOAlAADgJQAAACUAAOAmAADgJgAAACYAAOAnAADgJwAAACcAAOAoAADgKAAAACgAAOApAADgKQAAACkAAOAqAADgKgAAACoAAOArAADgKwAAACsAAOAsAADgLAAAACwAAOAtAADgLQAAAC0AAOAuAADgLgAAAC4AAOAvAADgLwAAAC8AAOAwAADgMAAAADAAAOAxAADgMQAAADEAAOAyAADgMgAAADIAAOAzAADgMwAAADMAAOA0AADgNAAAADQAAAAAAGAAwAD6ATABaAHIAnwDPgPCBHYE3gWcBiYG/Ac0B2wHuAh2COYJsgpKCpoLHAviDIgNUg2qDeoOWg7qD2QPiA+sEAgQphFYElYSuhOAFBgUsBWOFdwWMBamF0gXthf4GJQZQBmqGjYaNho2GjYaNho2GjYaNho2GjYaNho2GjYaNho2GjYaNho2GjYaNho2GjYaNho2GjYAAQAAAAADSgNKADwAAAEOAQ8BBgcGBwYdARQWFx4BNzY/ARMXHgEXHgEyNjc+AT8BExcWFxY2Nz4BPQE0JyYnJi8BJicmJyYrASIB5QULmCZDEhkGBAICCicUBmpqAQMDDggFBxIHBQgOAwMBamoGFCcKAgIEBhkSREZIExwKBwgECwNIAgeYJkMTGgkHCAUJBwUUDQoDamr+JgcIDwQCAgICBA8IBwHaamoDCg0UBQcJBQgHCRoTREZIExsGBQAAAQAAAAADugNoADsAAAEOAQ8BESMRJy4CBgcGDwERIw4BBw4CFhcWFxYgNzY3PgE1JicmJyYvAREnLgIGBwYPAREjEScuAQGaCQ8EA68EBAwMDwUNBwMdGAwHBQUBAQMHDwUDTgUPBwMBAQMFDAQO0wQEDAwPBQ4GA68EBhUDZgEMCQb9ggGECAcKBAECBg4G/nwBAwcGCg8GBRAEAgIEEAUGBgoFCwYCAQEBBwgHCgQBAgYOBv75An4ICwsAAAAAAQAAAAADggMxACAAAAEGBw4BDwEnLgEnJg4BBwYXHgMXFjc+AQA2NzYnLgEDNAYJBzua0lU+GgcTKBwDAwkDIKIhBhwcBkIBWkEDCQMELAMrAQQEOZrSVT0ZBAkHHBUSEwYioh8DDQ0DQQFaQgYTEhseAAABAAAAAAN2AyQAHgAAAQYHDgEPAScuAScmBgcGFBceARcWMjc2ADc2NTQnJgM6BwgGPprWWT8dBRIlCgkHA9gGDB4NBQHSBAgcDAMhAQMDPZrVWT4bAwgKEA0fDAXYBAgHAwHSBgwQHhAHAAABAAAAAAMfAqIAIQAAEw4BBwYUFx4EMj4DNzYnLgEnJgcOAQ8BJy4BJybzCxQFAgICJsAnDRINJ8AmAgYHAw4IEREFIlFxcU8kBA0CngIQCggSCAUnwCYEBCbAJwUREQgPAgcHAiBRcXFQIQIFAAAAAQAAAAADJQMkADwAABMOARcVFhcWHwEHBgcGBxUGHgE3MzY3Nj8BFxYXFhczFj4BJzUmJyYvATc2NzY3NTYmJyYHDgEPAScmJybyFBsEAQQGFMXFFAYEAQMQHRADCAUIFsXFFggFCAMQHRADAQQGFMXFFAYEAQQbFQ8NBSZLb25vBQ4DIQIkFAMIBQgWxcUWCAUIAxAdEAMBBAYUxcUUBgQBAxAdEAMIBQgWxcUWCAUIAxQkAgIGASVLb25uAwcAAQAAAAADoQO9AHUAAAEGBwYABwYHBhYXFhceATMyNjc2ADY1Ni4DDgIHBgcGIyImJyY1NDc2PwE2NzY/ATYyFx4BFxYGBwYABwYnLgQ9ASY3PgE/AT4BNzQuAw4BAAcGBw4BFRQWFx4BFxY2NzY/ATY3Njc2JicmJy4BAmk8MQr+fggwCgIBAg5BKWo7M10nDAGLBgEBBwwMDwlOfMcKO0c9ZhwVKwm+kCYNCQoCGDkYEB8JGAUeBv6VBQ4PCAoNBQEBAwMZHoG1BgEBBwsNDwz+kwUNBgMBBQgMLh4YMRQHuogpDgoHHAEdDRIfUgO6BCUH/n4LQE0OLg5eQyotIiAJAYwLCgcFDQoEAQRMfMcILEA3KjRIOQu+jyULCAQBCwoHGg4lWCIH/pcCBwMBBQ4KBwgEBgUGHB+AtQsKBwYMCwMBBf6UCBEWCAoOExQQGiIFBA0PBbqIKhALDTBxLxYRIB8AAAAAAwAAAAADlAO/AEgAZgB/AAATDgEHBg8BFQYXFhceARceAToBNzY3NjU0JicuAScuASMiJy4BLwERNzY/ASEXHgMVFBYXFhcWMjc2NzY8ASYnLgEnJicmIAEOAQ8BERceAR8BITc2NzY/AREnLgEvASYnJisBIgUeARcWFQ8BDgEHBiAnLgEnJhA3PgE3NiCaFSoPFgkDAQICCgspGggNNAwFDwgDAQIDDQcFChEiCgUKAwMEBg4HAYsHBgsGAgEBBg8HFgcPBgICAggiFxUYDP6LAR4qPwsDAws4KgsBUAsvHxYJAwMKMiUBCwkMI3yhATsUIAMBAQMGGhAI/tYIFBwDAQEDHhQJASIDvQIUEBchDMXEDBYVFyIIAgICBg8HCwcGBQYMAwEBBQMLBgcBiwkNBgMDAwsLExQPCwQPCAMDCA8FDDQNCBooDAoCAv7ZCDsrC/6wCyo4CwMDDCQZJAsBUAsmNwwBAwECUwMeFguWlggQFwICAgMfEwsBHgoUIAICAAMAAAAAA9IDdAAWADMAUAAAAQYHBgIHBhYXFjY3NhM3PgE3NC8BLgEFDgEHDgEHBhceAxcWNicuAS8BNz4BNzYuAgUOARceAR8BBw4BBwYWNz4DNzYnLgEnLgEnJgJGDwYDvAEBFBALFAQDXj8SDQECAQYb/roGCXBQIAIFBQIhpSMFFyEIAh1GY2NGHQIEBBAVAawPDgYCHEdjY0YdAgghFwUjpSECBQUCIVJHLgQOA28FDQf9TwcPFwEBCwoGAVnnQDUJBgQCDQyCAghwUCEGDQ0GIqUiAggiFwUeR2NjRx4FCxUPBgQFHQ4GHkdjY0ceBRciCAIipSIGDQ0GIlJILAIGAAAAAAMAAAAAA5EDugBAAFoAcgAAEwYHDgEHBh0BFhcWHwEeARceATMWNjc+ASYnLgMnJi8BETc+AT8BIRcWHwIUFhceATY3PgEuAScuAS8BIyIBBgcOAQcGEBceARcWIDc+ATc2ECcuAScmIAUeARcWEAcOAQ8BIScuAScmEDc+ATc2IJYPDR0pBAIBAQEEAQckFQ8UHBgLBQ4OCw4ECy0KBg8IAwMEDAYHAZAHDwcEAQECBh4cBQIBAQECCSshC83NATQWFCApBwICCEAuDAE4DC5ACAICCUMvCv7NAToTHAQCAgQXEAn+wAcQFwQCAgQcEgkBLwO5AgYLMh4JyJ0lDQkKAxUmCQYEAQECBRwdBwIBAQEDBhAHAZAHBgwEAwMIDgkfFQwEDQwODgULLw4HIC0KA/7cAwkQNyMM/sgMLkAIAgIIQC4MATgML0EGAUwEHBMJ/tIJERoGAwMGGxAJAS4JEh0EAgAAAAMAAAAAA28DwwAhADoAQAAAEw4BBwYPAREXFhcWHwEhNz4BPwERJy4BJyYvASYnJisBIgUVFx4BHwIDBwYPASEnJi8BETc2NzY7AR8BIzU0MukVKA8XCQMDCRYZJQ0CGg0jMQkDAwIyUoIFAQUHCiKFrwEpBAMMBwfZAQMGDQf9/AcNBgMDCRMGj5CMLl4CA8EDFA8ZIQv9PAshGBoKBAQJMSMLAhUHBTNRgwIBAwEBx2sIBw0DAwH+MAYMBgQEBgwGAq4GEgMBcC4uLgAAAAAHAAAAAAOfA6AAIAAzAEAAUABcAGwAeQAAAQ4CBw4BFBYXHgEXHgEyNjc+ATc+ATQmJy4CJy4BDwEUDwEOAQ8BIzc+ATc2NzY/ATYXHgEfASM1LgEvASYzBx4BFx4BHwEjNz4BNz4BMgMeARcWFCcuAS8BMwUOAQcGBw4BIiYnLgEvATMXDgEHDgEmNz4BNzUzAdpboHEXCAYGCB2jbh0zPjMdbqIdCAcHBxZmkFMMLwdtAgUYIQcDhAECCQQVJjBDDgPvRmMSBYUFIxkDBgFoDhwIBw0CAaQBBBYPCB4DuQchGAcNRmQSBYQBDAINBwwSCRMDHggPFgQBpOwMVkAJIQEHGSQFhQOeBVSNWBwxPjEcb6QeBwcHCB2ibh0zPjMdUYVVDAIEAX0BBAsvbTYXBAkkCjcsNx4GAQYedkkXCTd3MgUMHxg8GRY8EwkJIVQhFDb+ljZvLw4BBh13SRgKEzwWJCUSIDYUIVQhCgVHdyQFDwEOMnk3CgAAAAQAAAAAA70DugAZACAAPQBUAAABBgQHDgEXHgEfATM3Njc2NTYmJy4BLwEjJh8BBSU3NjIBDgEUFx4BFx4BNjc+ATc2JicuASsBBSUmJyYjJgcGBwYWFxYfATM3Njc+AS4BKwEFJSMiAeUO/mYDCAYFAwrW1hTW1gUKAQEDBAnV1QkKr6b+s/60paUE/lIMDgoEPZnVDQ3VmT0EDQcQBQYGC/5q/qcrDQkECQgNBwUGCAXV1RbV1QUIBgoSDAj+aP5oCAgDtwbOAwcZCgcKa2trawUJEAYGBQgIa2oBo1OmplNT/q4FExoLBR9NagICak0fBQ4jCQMBy6wVBgQB1AUPChkHBGtqamsEBxkVDMzMAAAAAAMAAAAAA0IDvgAiAD4AjgAAAQ4BBwYHBhUDFxYXFhceATMyNjc+ATc2PwERNCcmLwEuAScXHgEXHgEHFQYHDgEHBiInLgEnJic1Jjc2Nz4BBQYHDgEVBhcUFhceARceARcWHwIUFxQWHwEWMj8BPgE1NjU/ATI3PgE3Njc2NTYnNCYnJgYHDgEVFAYHDgEHBgcGIicmJyYnJjU0JicuAQHtLk0TCgQCAQMOKB8qCAwQFBYQITQNAwMEAgEEARFRNQoVIgYDAwEBAQYhFQgaCBYgBgEBAQEDCw4v/toKCQcFAQECBQcfFiFaNB0QBAEBBAYBDCIMAQYEAQEEAw1MeyMaCQIBAQUHDSYLBwICAwYbFCMxM3I0IxxECQECBQcaA74CMykUEwcb/sUMOCIaCwIBBAYMMyIJDAwBKSMOCQwCMj4DVQQeEwkZlX8aBRUhBgICBiEVBRp/lQ0WERUT/gMJBg0QDSUsHhYiRR0rPg8IAQEyHggMCAYBDAwBBggMCB4yAQMOXEQzOw43JgwRDQYOAw8IEyknIhEcOhcrFxkZERtBXQ4xKRIICgoAAQAAAAACxQLGAB8AAAEGBwYPAScmJy4BIg4BBwYUFx4BFxY2NzY/ATY0Jy4BApMMCQVbWy8dCQwLFA0LAwQEA4gFDRkJBWprAwUFGwLDAgkEkpIuHgcMBAYKBQkVCQWIAgYFCAWqqwgUCQsNAAAAAAEAAAAAAsUCcgAiAAABDgIUFx4BFxYXFjc+ATc2NCcuAisBIgYHBg8BJy4DAUMIDwgEApYIERYeFgiTAgQEAwsNCgIJDA8KJlFHLhsLEAJwAgwQFAkFlgULAQIQBpQECRUHBgoGBg4KJlBHLhkFAgABAAAAAALIAsUALQAAAQ4BFxYfAQcGBwYWFxY3Nj8BFxYXFjY3NicmLwE3Njc2JicmIgcGDwEnLgEnIgFHFRMKAkdHR0cCChIVDg0FR0dHRwUTJgMDBgNHR0dHAggKDwkWCQVHRkZHCwwDAsQDJxMFR0dHRwUTJgMDBgNHR0dHAgoSFQ4NBUdHR0cFECEHBQUDRkdHRgYCAAMAAAAAA5IDlgAnAGkAfAAAAQYHBg8BBgcGDwEOAR0BFx4BHwEzMjY/ATY3Nj8BNjc2NzY0JyYnJgUGBwYHBhAXHgEXFhcWIDc+ATc2NzY9AS4BJzUmIyIHBgcGDwEUBwYHBiAuAScmED4BPwE+ATczNjc+AiYvASMmBR4CFRcUBw4BBwEjNTc2Nz4BAwEjHAiuhiEKBgMBAgEDAwwFBkQyFQYCCQkMIoavBhIFAgIGIC39viMVPgcBAQMQDx40DgHoDhklESAFAQECBAwXCgcQBwEBAQEIEgf+ABAOAwIECAQBBQ0VWXEEDBACDg0GaWkCHAYTBgECAxgc/t1Cq6sECBQDkAMVBq6GIgwJCQIGFTJEBgUMAwMBAgEDBgohhq8IGR8MDQspIC4sAgofSQ7+GA4ZJREgBQEBAxAPHjQNaVEWDAYBEQMIEQRxYBMEEwUCBA8JBQIECwsDAQQCAQEBBRQaFgYCATECEw0KBAYEBhke/t1Cq6sCAwEAAgAAAAADbAOyACkARwAAAQYHDgEHBg8BBgcGFQcUFhceARceASA3Njc+ATc2ECcmJyYnLgEnLgIXHgMfARUUBw4CICcmJyY1JzQ3Njc+ATc2NzYB4RwdB9QdHwsCAwECAQEFCC4fDBwB6A40Hg8QAwEBAwcJEAfsEBMdJA4FEegVAwMCAw4Q/gAHEggBAQEDEhTaBggFCwOvBBUFrBgaHQQICQsilJZCER8uBwMDAQUgESUZDQFuCxMRExEHwAwODQRWAQy8EwYGwcEFCQ8EAgUTBB+hvwYLEBGwBAYBBAAEAAAAAAMXA78AOwBZAHgAigAAAQYHDgEHBhUHFxQXHgEXFhceARczFRQWFx4BFxYyNz4BNz4BPQEzPgE3PgE3Nj0BJzQnLgEnJicuASMmFx4BFxYdAQcOAQcGJyYnLgEnJgcGIjY3Njc2NzYWAxYXFhcWNj8BMgYHDgMrAiIuAz0BNz4BNzYTFA4CBw4BIiYnLgM9ATMBuTEsNkgKAgEBAgYQDhYgCA0VHwIFCjIhCSAJITIKBQIfFQ0IJDAHAgECCjgrIyoSHiw3czJIDAUJDykKHh0SKB4oFDs/DQEBAQQuKD0HcoAPKhgMLlEqCQEBAQEFDQsXmpoXCw0GAg8XMhQSfAEEDAYFBg4GBQYMBAFSA74EFhpgPAkepqUdBRUcDRUJAgEBLyUaDSAsBwICBywgDRolLwEBAgo0JAcgoKIeCDRVHRcLBAMBVgpEMRU9KAcNGQUMBgMRDAsBBCoIjgw/LScHAQH+pQMRCQQPChoFkQYICwsFBQsMFx8mDxYgBAT+uSAPDA0DAgEBAgMNDA8gLgAAAAACAAAAAANrA2sALwBjAAATDgEHBgcGBx0BFhceARcWFxYXPwE+ASYvAS4BIy8BJi8BETc2PwM+ASYvAiIFDgEXHgEfASEHDgEXHgIzIQcGBw4BHQEUFx4BNz4BPwE2NzY3Nic1NicmJyYvAS4D5hovDgsEAgEBAQcoHgsLCRPhBw4MBwwCBQ0W1QYMBwQEBg0G8AcQDAsPCHd3AYcRDgcCFig9/oQGDwwHAw0MGAFiQCQKDQUMCRcMBR9HEDIOEwQEAQEEBBMNMxBHHwsRA2kEIBYTFgkl5OQlCSAwDAQDAQEBAwcbHQkBAwMBAwcNBgIMBg0GBAEDCB4eCAMBlAYiEAUXKT0DCCAPBwwFQSQKDgsKAREMCQQEAh1HEDIOFAgFCAYIBQgUDTIRRx0EAQAAAQAAAAADLAMvADYAAAEOAQcGHQEjIg4BBw4BFRQXFhcWOwEVFBcWFxYyNzY3Nj0BMzI3Njc2NTQmJy4CKwE1NCcuAQHqCRAEAt8QDA0DAwEEBw8GD+ACBg8HFgcPBgLgDwYPBwQBAwMNDBDfAgYcAysCDgkGD+AFDAYFBgcLBw8GAuAPBg8HBAQHDwYP4AIGDwcLBwYFBgwF4A8GDg4AAAIAAAAAA28DbAA1AFEAAAEGBw4BBw4BBw4BFRQXFhceARceAT4BNz4BPwEXHgEXFj4BJy4BLwE3Njc+AiYnLgInLgEXHgEXFhcWFAcOAQcGJicuAjY3PgE3PgE3NjIBrS0pDykNNkcPBQMBCiAldEYVHy0cEx9CGQVIMRsFESAOCAIaMEkDKRAFAwECBA5OdUUPMTBFbhgIBAICDG9QNGspJy8NGh4IHAobQB8MJwNqBQ8FFQkkZz8UHhkeC0Y3P1QOBAIBAwUHHxMDSTAaAggOIBEFGzFIBTdDEh0tHxVEcEkKAgJWCVlBGBkOLA1Qcw8KGyEfVGFgKAocCBQaBAEAAAAABAAAAAADbAOIACsASgBrAIIAAAEGBw4DBwYHBhAXFhceAxcWMjc+Azc2NzYQJyYnLgMnLgEjJhceARcWHwERBw4CBwYnLgIvARE3PgE/ATY3MTYWBwYHDgEHDgEVFBYXHgEXHgEyNjc+ATc+ATQmJy4BJy4BFx4BFxYUBw4BBwYiJy4BJyY0Nz4BNzYB2xAOC/oNEgUSBAEBBBIFFBHzCxo8GgvzERQFEgQBAQQSBRIP/AoMFRETIAj8BAUDBAQDCf0JDQ0J/AoDBAQDCmyEEwUFDyRAJw0PBgIBBAYMNCIQFigWECI0DAYEBAYPQSoKKSYUIwUCAgUhFggaCBYhBQICBBgRGQOGBAcFjQkTBxkdCv7cCh0ZCBQLiAYNDQaICxQIGR0KASQKHRkHEwqOBQYEAVYDjwQEBwb+0gYHCY4DBQUDjgkHBgEuBgcJPUoKAgEBnAswECAVCAwQFBYQIjQMBgQEBgw0IhAWKBYQKDgJAgFVBSMUCRgIFSIGAgIGIhUIGAkQHggNAAAABAAAAAADawNrACkAOQBFAGoAABMOAQcGBwYHHQEWFx4BFxYXFhc7ATY3PgE3Njc9ASYnLgEnIyYnJicjIBMRIyImJyYvARE3Njc2OwEFFh8BEQcGDwEhESEHDgEPAQYHDgEdARQWFxYfAR4BFxY+AScuAS8BNz4BNzYmJy4B5hovDgsEAgEBAQcoHgsLCSXk5CUJJjUIAQEBAQcsIQEKDBE2xP7+XTAkDQUMBwQECREDLi4Bsg0GBAQHDAb+pgFafggTIwIcBwsEBAsHHAIfEgURIA4IAgwSHR0SDAIIDBEFEANpBCAWExYJJeTkJQkgMAwEAwEBAQIHNSYJJeTkJQkhMgwDAQEB/on+3QECBw0GAgwGEQUBBAYNBv30Bg0HAwJGpwIQIwMcCAsKCgIKCgsIHAMeEgIIDiARBQ4SHR0TDQUQIAcDAQAAAAADAAAAAAOYA4IAPwBUAIUAAAEOAQcGBwYUFxYfAQcOAQcGFhcWFxYXFjI3PgEnJi8BLgEjLwEmJyY3Njc+ATc2Nz4BNz4BNz4BNTQmJy4BJyYHHgEXFhUUDgIuAScmNjc2NzY3NgEGBw4BBxQdASMiBwYHBhYfAhUUFhcWFxYyNzY3PgE9AT8BPgEnJicmKwE1NCcuAQHrKEwdMwsCAgwxCw5DXhACAQIGFBspC8AHEREHBAoCBQsTsQYMAwIDCBMeYT4LFR8sGCs9DAQCBwkLLxw6KhYsECUhOkY9KgUBAQMIGRAXJAEKDQoGBAEpKQgOCg8IEwdfAQEGDwcWBw8GAQFfBxMIDwoOCCkpAgUaA38BIR0zSAkuCUcyDAcjhFQHGQgdFR0IAgIFIRALCAEEAwEEBgwFDCYlOkQHAQEBCgwUTC8QExMYIxYfNxEkVwMVESc2Ij4kBRw4IQsgCSMaEQsS/pkCCgYKDAkdLQICCg8qCQMBLiAPBQ8IAwMIDwUPIC4BAwkqDwoCAlUIBA4PAAAAAAIAAAAAA7wDuwAfADEAAAEGBw4BBwAGBw4BFx4BFxY2Nz4BADc2NzYmJy4BJy4BFxYXHgEPAQEHBjA/AQE3PgEWAv4mHwdys/7fBSEYCQEBGBIGJVV3DAJBBxcGAgEDDEMvCignCAcYDwwF/c5GRhMTAjILCw4WA7kHFQVxs/7fC3dXIwcRGAEBChchBQJBCyElDiQNL0ELAgFfAgUQNBkL/c4TE0ZGAjIFBQMCAAAAAQAAAAADQgNDACsAAAEOAx0BIQcOARceAjsBFRQeAjI+Aj0BMzI+AjQnJi8BITU0Jy4BAe0HCwsF/voGEAsGBAwMEvMFDA8SDwwF8xIMDAcDBw4G/voCBRoDQAEFDQsS8wMIIA8HDAXzEgwMBwcMDBLzBQwPEggOBwPyEwQODwABAAAAAANsA2sASAAAAQ4CBwYHFRQHDgEHBisBNz4BNzYmJy4BKwEmBwYHBg8BDgEHBhQXHgEfARYXFhcWNzMyNz4BJy4BLwEhMjc+ATc2ECcuAScmAzcIDwYBAQECCDwpC8nJSDMWAgULDwUGBwMIBggVEDcRRCsBBAMCK0QRNxAVCAYIAwsHDgwFAhYzSAGAJghFYgkCAgQUDQgDagIMDQgLIvUYCCg2BQJINBcFDx4IAgEBBAUVDzcRRCwEBxQHBCxEETcPFQUEAQMHHw8FFzRIAgtjRRABMwcNDwEBAAIAAAAAA5IDkwBFAGIAAAEOAQcOAQcOARceARcWFx4BFx4BMjY3Njc+ATc2JicmIgYVFAcOAgcOASMGJicuAj4DFxYXHgEzMjY1LgEnLgEnJgUGDwMGBw4BFBYXFjsCMj4CPQI0LgIiAd1NijcwOwkDAQIFLSchLSJVKRkcPhwYak8+SgcCAwgLIBUCBkRyRhMdFS1OKEJbIyBeip1FLysJDggPFwEHCSJdMUEBPg8GBAHQDwQKDA0LBRJzcxIMDAUEDAwPA48EPjcwekUQMhE9dS8rIRkmCAUDAwUWRDaRUhsXCQsWEQkQSH5XEQQEAREUInaRlHtFAiEXJwkGFg8IDgkiNg0SBQUNCN0BAQIEFBUUBAIFDAwSc3MSCwwGAAIAAAAAA5QDbAAxAE0AAAEGBw4BBw4BBw4BFRQXFhceARcWNjc+AT8BFx4BMj4CNCYvATc+ATc+AScuAicuARceARcWFxYUBw4BBwYmJy4CNjc+ATc+ATc2MgGtLSkPKQ02Rw8FAwEKICmHUQ42DShMHgpeXgwWDA4FB11eBxYfBgICAgdOe0sPMTBFbhgIBAICDG9QNGspJy8NGh4IHAobQB8MJwNqBQ8FFQkkZz8UHhkeC0Y3RlgIAgICBh8WB15dBwUODBYMXl4KHk0nDTYOTH9TCwICVglZQRgZDiwNUHMPChshH1RhYCgKHAgUGgQBAAABAAAAAAPQA9YAEwAAAQ8BBhQfAhYyPwI2NC8CJiIBuTqzs7OzOjoCOjqzs7OzOjoCAyeuQkICQkKurq6uQkICQkKurgAAAAABAAAAAAOUA5MAEwAAAQ8BBhQfAhYyPwI2NC8CJiIBwjKenZ2eMjECMTKenZ2eMjECAv6VOjoCOjqVlZWVOjoCOjqVlQAAAAACAAAAAANvAvIAIQA6AAATBgcOARQeAhQOAhQWFx4BPgE3PgE1NCYnLgInLgIBDgEXFh8BFhcWMyE3PgI1NCYnLgEvASWaCwoHBAQLz88LBAUHDCMY8gQGBQEDAwf0CgYLEgFFEBADAxACBQcKIQE5CAcNBgECAw0GB/6dAvADCggMFgwLrQKtCwwWDQcOAhPLAwcMCwgGBQcHzAcFBAH+CQcbEBIMAQQBAgQDDA4MCAcFBgwEAwEAAwAAAAADugO6ADMAWQBnAAATBgcOAQcGAgcGFBcWFxYfAjIPAQYeATMyPgI3PgE/AjI3PgE/ATU2Jy4DLwEhJAEVBwYHBg8BMCcuATc2Nz4BJyYnJi8CLgI1NDY3PgI3NjMlFxYfAREUBwYHBiMHERf4EQ0SHwgDYgQDAwgWFyMNxBABHwkjVi8LDAsXNUoKCAiEDwYhLwsDAQICEhoYEwn+1v7VAZ4JHBEFQ0MKHiEFARYOBwEBEwUR+AgHDQcPIzIGDwcEIwF4tg4IAwIHFQMKWWQDuAMHCSASBf6xEQseDCAXGgkEAQGELl08BAosapULBAQCAgctIQu3twkSIhoOBQMB/tzZBQ8aB4aGAww4HwlYPB4GFgoBAQEEAw4OCgY3d6oNDAMBAQQIDgf+sxcFFQcCAQGpAQAAAAMAAAAAA7MDugA8AGIAcgAAAQ4BDwEGBwYPAiIGBw4BDwERFhcWFxYXITI3Nj8BPgE3NhI3NjQnLgEvASYnJiMnIj8BPgEnJicmJy4BFx4BBwYHDgEXFhcWHwIeAhUUBgcGBwYPAQURNz4BNzY3PgEXARUvAS4BLwERNz4BNzY7AQHoCgpKOg8HBAcJRzwaERkkCQMBARNFBS4B6jYRDAgDFiQJA2IEAwMHJhwCCgcKFq0QAR8CAgIJKCQxCh0qHCEFARYOBwEBEwUR+AgHDQcPIzIDBg4H/mMFDhsIBUMtFwH+8mQGBwwEAwMFEwoHLCwDuAQMk3MdCQYEBAEDBwopGwv+ox4FRBUBAQEBBAEIIxQFAU8RCx4MHS0LAQQBAgICgAwgCjsoJAoCAVIMOB4JWDweBhYJAgEBBAMODgoGN3eqBgwIAwEBsgMHFwwIhlosAf3j1QEDAw0GBwFmBwoOAgEABwAAAAADugO6ACgAPgBVAGgAfQCPAKYAAAEGBw4BBwYHBhQXFhceARcWFx4BMjY3Njc+ATc2NzY0JyYnLgEnJiMiBwYHDgEHDgEPASM3PgE3PgE3Njc+ARcWFx4BFx4BHwEjJy4BJy4BLwEmMzEyBx4BFx4BHQEjNTQ2NzY3Njc+AQMeARceARcWBicuAScuAScuAS8BMwUUBgcGBw4BIicuAScuAT0BMxcGBw4BBw4BBw4BBwYmNz4BNz4BPwEzAdN+ZjFRGBsJAgENKBZBJldwFBk8GRR1WxAsDE4SAgITWjCCSSUvIjwBBxgqDgsLBQGvAwcsIgghCjxKDAfBTD0KIAkfKgcDrwEFDQwNKhcHAQICUCg5DAIF/AUCFUEIBRMCywUNCw0sFwcDDSNHHAwhCSIsBwOvAUkFAhZFCRICCSk4DAIF/PsBAQcsIgkhDBxHIw0DBxgqDQwNBQGvA7kKRyNhNz1HDVAMW0opSx1DEwMCAgMUSQwsEGKEDVANj2Y4TA8IVgIKJFssJDwrBxIxYygKIAkwFQQBBRczCCEKJ2AwEgctQCUrWCMKAhc2gEMNJAUFBQUkDnFlDgcYAf5tLEAlKlwjCQEECiQWCiALKGMxEwYFJA14Zw0YCzd/Qw0kBQYFBAoxYygLIAoWJAoEAQojWSslQC0IAAEAAAAAAx8DHwA8AAATDgEHBhQXHgEfAQcOAQcGFx4BFxY3PgE/ARceARcWNz4BNzYnLgEvATc+ATc2Jy4BJyYHDgEPAScuAScm8wsUBQICAiFRcXFRIQIGBwMOCBERBSJRcXFRIgUREQgOAwcGAiFRcXFRIQIGBwMOCBERBSJRcXFPJAQNAxsCEAoIEggFIlFxcVEiBRERCA4DBwYCIVFxcVEhAgYHAw4IEREFIlFxcVEiBRERCA8CBwcCIFFxcVAhAgUAAAAAA//vAAAD6QNyAFIAbACBAAABBg8BDgEPAQYHBhMxHgEXHgEXFhcWPgE3NiYnLgE0NjIXFhcWNjc+ARYUBgcOARceATMyNzY3Njc+AScmLwImLwEHDgEPARQnJiIPASI0LgEjAx4BFxYXFgcOAQcGJy4DJy4CNz4BMzIFHgEXHgEVFgcOAScuATc2NzY3NhYBTU9FBhMJBQEHDY0SAQICBToNRlAXBBcHFQINGCsQAxI5PlaxUxEGESwUEAIRBh0BBStTSDIBAgIBDoEJC1ZZEwICDwQFDzFrLgoCFQUCBQ4bCRQBAyANGhAVFAcIEAYEBwQBAQYxIAoBVRgkCAIBAQkNNh4iKwQDCBUsBRQDbBAdAggFCAEMFev++BUIAgQmCCgcCAMjCyMFBQoXBA4IGA0REiMHAg4EFwgHAx4LLBAfLh8FDF0c5cIOBSURBAMCHAoKAQIHBwECKwj+wAMSDBohMSANDAEBCQMHDwkIDRAfCSMuAQUlGgcKDRsSHh8GB0AnFBIpCgEBAAAAAwAAAAADlQOVADAASwBjAAABBgcGDwIGBw4BBwYdAhQXHgEXFhcpATY3PgE3Nj0CNCcuAScmLwIuAS8BIyIXFhceARcWBgcOAQcGIicuAScmNDc2Nz4BNzYXBgcGBw4BFBYXHgEXFjY3PgEmJy4DAYkQDwgbG4YOBhUhBgICBiEVBjIBKgEqMgYVIQYCAgYhFQYOhhgaFQ4JZ2Z/LyokLgcCAQILYUQJKAlFYQsCAggdBx4KRCQdGCUNAgEBAggnHCpZFxACHRoIGBIfA5IDCwYeHgEBAQYhFQgj5OQjCBUhBgEBAQEGIRYHI+TkIwgVIQYBAQEbHREFBNIGHBhJKw4nD0JeCgICC19EDCgMMSkKHgcvXAUQGi0JChoKCR0sCxEeJxxAORIFCwQCAAAAAAQAAAAAA4UDFwAsADkAUQBjAAABDgEHBgcGAhUUFxY3Njc2PwEzFx4BFxY3Njc2NzY3NCYnJicuAScmJyYjJyIXFTMVIxUjNSM1MzUzBRYXHgEUBgcGBwYiJyYnLgE0Njc2NzYWFx4BFx4BFAYHDgEnLgE2NzYyASMwSRAEAgMtHyEvHxkJMjL4NCcYDRUZEAsbFBoCBxAXAgUaEiAuCBy50VBUVClUVCkBDA0GAgICAgcMBxYHDAcCAgICCBIDFFYHDQMCAQECCSoPCgUPDwURAxYGOy0LCRD+vQcrHyECAhEGMjIzKBQGCQEBAwkUHCcKM3WjChgtER4MAgGmKStSUitSBAYNBAYQBgQNBwMDBg4EBhAGBBAGAQF+AwwGBQYOBgUTBw4KHBoFAgAAAAACAAAAAANyA4sAgQCcAAABBgcOAQcOAgcGBwYiLgEiBw4FFBYXHgMVFwcUDgQeBBcWMj4BMzIXFhceAhceARceARcWOwE3PgE3PgQ3NjMyHgEyNz4FJy4DNSc3ND4CNzYmJy4DJyYiDgEiJy4DJy4BJyYnJiIXFhceARcWBgcGBw4BIiYnJicmJyY3PgE3PgEBvRYQDAoEBAMICw0IEQoxDRQGDBoNKwUBAgIFDioDAQEEJA8KAwEFKw0XDAcYDDEDBhAKDAsIAwUDBgYIGg4JMjEKEhoFAwcDBxoJEAYDMQwXBwwYDSsFAgIEECwDAQEDLBADAwIDAigOGQ0HFQ0xChEIGgcDAwUJDBEWCVtBJSAKGAcfCSYcJQ0TIBMNIhoTDRoPAxAHGU4DiAQRCxgbGAgHBQcGChIDAQMQEUsNCRUJBg4QIwUHHB0GBh0QFBEYEEsRDwMCAxIKBgcFBwgaFRMJCxIDAgQGGhEHLQsGDgYKEgMCAw8RSxAYCRAWJAUHHBwHBSQVEAoYCQdGFRADAgMSCgYOBgsWGhcLEQQC+wUVBxgKLm4oHA0EAwMECxkTGjQ5DB4KIiEAAAABAAAAAAN2A1wAMQAAAQYHAQ4BHgI7AREUHgEfATM3PgI9ATMVFB4BHwEzNz4CNREzMjY3NicmJwEuASIB5AYH/qgHBAMIDh4mBQwHCI8IBwwFqAUMBwiPCAcMBSYfDQUIAwII/qgHDRIDWQIH/ssHCgsJAv7nFQwMBAMDBAwMEMrKEAwMBAMDBAwMFQEZAgYJCgQIATUHBQAAAAACAAAAAANFA5UAHQAzAAABDgEHBhUUFhcWFx4BFxY3PgE3Njc2JicuAScuAQcXFhcWFRQGBw4BIiYnJicuATc+AhcBzlKJJScDBRyBH2sLExQLayGFGAkLEh+AUxY6FzoVEBkfGgcJFAkHIw8FAwMFIioUA5IJXEhLWBYbE3mRIWgGCQoFaCWVfSxkLE5pEQUCA/oGEBkjGyoJAgEBAg0hDBwNFSILBQACAAAAAAM/A3gAIwBJAAABBgcOAQcOAQcOARQWFx4BFx4BMjY3PgE3PgE3NjQnLgEnLgEDBgcOAQcGDwEVFxYfARYXFhchNjc2PwE2PwI0JicmJy4BJy4BAdYCCRAkDxcjCQUDAwUNOiYQFiQWEBwvEQcNAwICC0c0Ci0CcVMbLQwKBgMDBAUBBAoONAHYNA4KBAEFBAMBAgUDCB2OWhIvA3cBAQMOChAuGw8VJhUOJzsNBQMDBQolGgsgDwstDDNJDAIB/mQHNhEuFxQXDZcHBwMCAwEBAQEBAQMCAwcHRTkgEQsQO1IJAgEAAAQAAAAAA78DGAAaADEATgBrAAABDgEHBgcGFx4BFxY2NzY3PgE1NCYnLgEnJiIFDgEHBhceAxcWNjc+AScmJyYnJiIBDgEHBgcOAR0BFx4COwIyPgE/AjQnJicuAQUiBhceARceARUWBgcGOwIyPgE/ATU0JicuAgEzFykNFAEBAgY2Jh06FhIKBwUBAwoyIwsdAUMfMAsRDwUNFxQOI0YaHA0SCA4cJgod/q4mVSRfDwEBAwQMDCLi4iIMDQMDAQILRDGAARcRAgkWIQgFBAEDBAEQYGIQDAwEAwECC12PAxUFHBMdIxEJJjkIBhAUEBYPFRQPCggiLwcCAgcoHSssDxQYDQUMEBkdUCQQDh0HAv6yAhIOJjYFERspCAcMBQUMBgcoKAkuIxgbAwIHESwWDhoeIiMPAgUMBwgpHg4HJDkiAAIAAAAAA1MDgQAbAEEAAAEGBwYEDgEUFhceARcWMzI3NiQ3PgEnJiQnLgEBDgEEBw4BIyImJCYGBw4BFxYfARYXHgEyNzY3Nj8BPgE3Ni4BBwHlDw4I/uoNBQUHBPoeFx0TEgkBHwQKAwkD/uIICyIBLAYL/wAIBgYGCw3++Q4SBxMHEAaOaiAMCBIXCAoJDCFuYjADCQgaEQN+AwkF2QwNFA0HA8QXEQgF4AQJHwwG3gUIBv5HAQbIBAMCB8wFAQMJKg8Gb1IYCAUEAgIGBxlVTScEDyATAwAAAAABAAAAAANnA1IAKQAAAQ4BBwYVHwEeATMhFSEVFB4CFxYzPwE2PwETMzI3PgE3NjQnJi8CIAEqERoEAQEDAwgZATb+UgILFwwG3t4LMhEDAR0cBw8bBggICx0I//8AA1EEGhEGyMcEBQRKJiASFREDAQEDETILAcABBBQOEB4QGQsCAQAEAAAAAANrA2sAGwArAEoAYAAAEw4BBwYHHwEWFx4CIDY3Nj8CJicuAS8BJSAXHgEXFgYHDgEnLgE2Nz4BAwYHDgEPAhYXHgEXFhcpATY3PgE3NjcvAS4BJyIkFx4CFxYOAQcOASImJyYnLgE2NzYWwBgjBgEBAQMHEQYWEAJeDgsfCwQBAQEGHxQJ/tD+0XAXIQUEDBATMxcfFhceDB5fGBMKEQQDAQEBBiIWCCgBBwEHKAgWIgYBAQEECCUZB/26aQgQFAQMBB4YBgkXCQYSDhYEJyAGGANpBSIYBw60ChUPBgsEAwYOIgq0DggWIAYDAVYGIxgVJhATCAwPPDsPBgP+sgINBxgNCLQOCBYiBQIBAQIFIhYIDrQKGB4DAVgCCRQIFjEoCQIBAQMGDhc/MQYBAQAAAAADAAAAAAOUA5UAKABZAHMAAAEOAQcOAQcOAQcGBwYUFx4BFxYyNzY3PgE3PgE0JicuAScuAScmJyYiFxYXHgEXFgcGBw4CJy4DIy8BNCcmJyMmJyYnIzUzMj4CPwIzMjY3Njc2PQEBFxUUFhceARceATsBFScuAScuAScmNDc2MgHOGToWES4OOlYYEgcDAxXDjxBMEIVfL0INBQMDBRFjSA4uEDM5DDKoBgxCWA0LCgwoBxUCAwUUGBIYGwEBBQsCBQYJGeItIBAMDAQDATIlEAUiDwn+o2MEBgUUCggUBgUHES4TT2wMBAQEAgOTAg0JBhYJJGg/LDUQTBCPwxUDAxRWLHQ+GR0+HRlSjS4JFgYTBQFzAgcleUk7PEQ8CxoBBg0WDAQBegwDDggEAQEBVAEEDAcIXQECDR8RFw3+smMaFhUMChQFBAZQAQIMCCGLVBY4FRoAAAIAAAAAA+UD7wAeAEMAAAEGBw4BBw4BBwYHDgEVFBcyMyEyMzY0Jy4BJy4BJyYBFBYXFhceARcWFx4BMzI3Njc+AT8BJwcGBwYHBiYnLgEvASMiAdBOSw4vDRspF2EiAwgUG2gCsmgbFAMSdVsNMw5t/cAHAxtGDS4QZHwaIh8oFExFI0kcDI0MLTkrLzVmKSc2CwO9DQPnBh4GGAgRIRZihg0qBQEBAQMTarE5CRoGLP3IBCoMa1gQLg1QFwUCAgseEDEaDI0KKRQPAgEhIh9VLwwAAQAAAAADvwO/AF4AAAEGBw4BBw4EBwYHDgIWFxYfARYXFhcWFxUUBgcGFRQXFhcWNzE2PwE+ATM3MhYfARYXMRY3Njc2NTQnLgE9ATY3Njc2PwE2NzY0Jy4BJy4EJy4BJyYvASIB6xQQBgcMPhsMDdoIEA0ICAUGBwNTCC0NEQQDAQYNEhMOEg0NBw13OhYGAwoQWmANBw0NEw0TEg0GAQMEEQwtCVIFCgoGFgwG2g0MGj4NBwYQEgkDA70CEAYMGX00CwUgAgQNCA4WGQsGUActDBIHBgkBBypHbwYZFA0EAwMCBj4fCgEGMDIGAgMDBA0UGQdtRyoHAgkFCBEMLAlQBxAlEAoPAwEgBQsyfhkNBhACAQAAAAAAEADGAAEAAAAAAAEACwAAAAEAAAAAAAIABwALAAEAAAAAAAMACwASAAEAAAAAAAQACwAdAAEAAAAAAAUACwAoAAEAAAAAAAYACwAzAAEAAAAAAAoAKwA+AAEAAAAAAAsAEwBpAAMAAQQJAAEAFgB8AAMAAQQJAAIADgCSAAMAAQQJAAMAFgCgAAMAAQQJAAQAFgC2AAMAAQQJAAUAFgDMAAMAAQQJAAYAFgDiAAMAAQQJAAoAVgD4AAMAAQQJAAsAJgFOZXRob3MtaWNvbnNSZWd1bGFyZXRob3MtaWNvbnNldGhvcy1pY29uc1ZlcnNpb24gMS4wZXRob3MtaWNvbnNHZW5lcmF0ZWQgYnkgc3ZnMnR0ZiBmcm9tIEZvbnRlbGxvIHByb2plY3QuaHR0cDovL2ZvbnRlbGxvLmNvbQBlAHQAaABvAHMALQBpAGMAbwBuAHMAUgBlAGcAdQBsAGEAcgBlAHQAaABvAHMALQBpAGMAbwBuAHMAZQB0AGgAbwBzAC0AaQBjAG8AbgBzAFYAZQByAHMAaQBvAG4AIAAxAC4AMABlAHQAaABvAHMALQBpAGMAbwBuAHMARwBlAG4AZQByAGEAdABlAGQAIABiAHkAIABzAHYAZwAyAHQAdABmACAAZgByAG8AbQAgAEYAbwBuAHQAZQBsAGwAbwAgAHAAcgBvAGoAZQBjAHQALgBoAHQAdABwADoALwAvAGYAbwBuAHQAZQBsAGwAbwAuAGMAbwBtAAAAAgAAAAAAAAAKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABNAQIBAwEEAQUBBgEHAQgBCQEKAQsBDAENAQ4BDwEQAREBEgETARQBFQEWARcBGAEZARoBGwEcAR0BHgEfASABIQEiASMBJAElASYBJwEoASkBKgErASwBLQEuAS8BMAExATIBMwE0ATUBNgE3ATgBOQE6ATsBPAE9AT4BPwFAAUEBQgFDAUQBRQFGAUcBSAFJAUoBSwFMAU0BTgAOYWdlbnQtYXJyb3ctdXALYWdlbnQtY2hhcnQQYWdlbnQtY2hlY2stYm9sZAthZ2VudC1jaGVjaxJhZ2VudC1jaGV2cm9uLWRvd24MYWdlbnQtY2hpcC14CmFnZW50LWNsaXAPYWdlbnQtY29kZS1jb3B5D2FnZW50LWNvZGUtZmlsZQphZ2VudC1jb3B5CmFnZW50LWZpbGULYWdlbnQtZ2xvYmUMYWdlbnQtbGF5ZXJzCWFnZW50LW1pYw9hZ2VudC1uYXYtY2hlY2sRYWdlbnQtbmF2LWNoZXZyb24PYWdlbnQtbmF2LWNsb3NlEWFnZW50LW5hdi1jb21wb3NlDmFnZW50LW5hdi1ob21lDmFnZW50LW5hdi1sb2dvEGFnZW50LW5hdi1sb2dvdXQOYWdlbnQtbmF2LXBsdXMQYWdlbnQtbmF2LXNlYXJjaBJhZ2VudC1uYXYtc2V0dGluZ3MRYWdlbnQtbmF2LXNpZGViYXISYWdlbnQtbmF2LXVzZXItYWRkDGFnZW50LXBlbmNpbAphZ2VudC1wbHVzC2FnZW50LXJlcGx5C2FnZW50LXJldHJ5DGFnZW50LXNlYXJjaBVhZ2VudC1zcGFya2xlLXN0cm9rZWQNYWdlbnQtc3BhcmtsZQ5hZ2VudC10ZXJtaW5hbBFhZ2VudC10aHVtYnMtZG93bg9hZ2VudC10aHVtYnMtdXAJYWdlbnQtd2ViB2FnZW50LXgHZGlzY29yZAtkb2NrLWNhbWVyYQlkb2NrLWdhbWUJZG9jay1nZWFyCWRvY2staG9tZQ5kb2NrLWxvY2F0aW9ucwtkb2NrLXBlcnNvbgxkb2NrLXBsYXllcnMNZG9jay1wcm9maWxlcwtkb2NrLXNjcmlwdAxkb2NrLXNlc3Npb24KZG9jay13b3JsZAdldGhvcy1lC3N0YXItZmlsbGVkAWEBZwFlAW4BdAEtAXIBbwF3AXUBcAFjAWgBawFiAWwBZAF2AWkBeAF5AWYBcwFtAAAAAA==",
	Icons = table.freeze({
		["agent-arrow-up"] = "rbxassetid://105267514434427",
		["agent-chart"] = "rbxassetid://137459292073776",
		["agent-check"] = "rbxassetid://104317682855691",
		["agent-check-bold"] = "rbxassetid://106983789947112",
		["agent-chevron-down"] = "rbxassetid://73871504307591",
		["agent-chip-x"] = "rbxassetid://136303908508490",
		["agent-clip"] = "rbxassetid://82595772828431",
		["agent-code-check"] = "rbxassetid://123980485320904",
		["agent-code-copy"] = "rbxassetid://73115300226251",
		["agent-code-file"] = "rbxassetid://86888202855225",
		["agent-copy"] = "rbxassetid://80367212182224",
		["agent-file"] = "rbxassetid://105072490107574",
		["agent-globe"] = "rbxassetid://126620319656045",
		["agent-layers"] = "rbxassetid://121669966519194",
		["agent-mic"] = "rbxassetid://133956731964833",
		["agent-nav-check"] = "rbxassetid://84183213708923",
		["agent-nav-chevron"] = "rbxassetid://134308896358444",
		["agent-nav-close"] = "rbxassetid://120660689306306",
		["agent-nav-compose"] = "rbxassetid://127384614560266",
		["agent-nav-home"] = "rbxassetid://87077178021887",
		["agent-nav-logo"] = "rbxassetid://113186274080651",
		["agent-nav-logout"] = "rbxassetid://128620003337457",
		["agent-nav-plus"] = "rbxassetid://133095967248251",
		["agent-nav-search"] = "rbxassetid://108580723751191",
		["agent-nav-settings"] = "rbxassetid://72102212673270",
		["agent-nav-sidebar"] = "rbxassetid://111540909421494",
		["agent-nav-user-add"] = "rbxassetid://112757983878173",
		["agent-pencil"] = "rbxassetid://117654172903836",
		["agent-plus"] = "rbxassetid://99008240235457",
		["agent-reply"] = "rbxassetid://95920413943910",
		["agent-retry"] = "rbxassetid://95257627864251",
		["agent-search"] = "rbxassetid://95628827171601",
		["agent-sparkle"] = "rbxassetid://119473457171118",
		["agent-sparkle-stroked"] = "rbxassetid://119182900823843",
		["agent-terminal"] = "rbxassetid://108988270870707",
		["agent-thumbs-down"] = "rbxassetid://107768576145340",
		["agent-thumbs-up"] = "rbxassetid://110106348997192",
		["agent-web"] = "rbxassetid://119259429533640",
		["agent-x"] = "rbxassetid://110858464874743",
		["discord"] = "rbxassetid://135427415405802",
		["dock-camera"] = "rbxassetid://123335388663322",
		["dock-game"] = "rbxassetid://100634765395584",
		["dock-gear"] = "rbxassetid://119679349772474",
		["dock-home"] = "rbxassetid://120704660868662",
		["dock-locations"] = "rbxassetid://139346806935647",
		["dock-person"] = "rbxassetid://111084746415354",
		["dock-players"] = "rbxassetid://99883124832960",
		["dock-profiles"] = "rbxassetid://91850452391775",
		["dock-script"] = "rbxassetid://79064539790155",
		["dock-session"] = "rbxassetid://83337489103350",
		["dock-world"] = "rbxassetid://138698178233765",
		["ethos-e"] = "rbxassetid://111882090410078",
		["star-filled"] = "rbxassetid://118022893731495",
	}),
})

end)() end,
    [19] = function()local wax,script,require=ImportGlobals(19)local ImportGlobals return (function(...)--!strict
-- Molto icon registry adapter: https://github.com/notpoiu/Molto
-- The live loader is required because it must match the live provider data and fonts.

local LOADER_URL = "https://molto.pages.dev/source.lua"

local Molto = {}

local registry: any = nil
local retryAt = 0
local lastError: string? = nil

local function load(): (any, string?)
	if registry then
		return registry, nil
	end
	if os.clock() < retryAt then
		return nil, lastError
	end
	local ok, result = pcall(
		function()
			local loaded = (loadstring :: any)(game:HttpGet(LOADER_URL))()
			loaded.GetIcons() -- Loads the default Lucide provider data.
			return loaded
		end
	)
	if not ok then
		lastError = "Molto could not load: " .. tostring(result)
		retryAt = os.clock() + 3
		return nil, lastError
	end
	registry = result
	return registry, nil
end

-- Names cannot be checked while Molto is unreachable; GetFontAsset reports that failure.
function Molto.IsIcon(name: string): boolean
	local loaded = load()
	return loaded == nil or loaded.HasIcon(name)
end

function Molto.GetFontAsset(name: string)
	local loaded, message = load()
	if loaded == nil then
		return nil, message
	end
	local asset = loaded.GetAsset(name)
	if asset == nil then
		return nil, "Unknown icon."
	end
	if asset.FontFace == nil then
		return nil, "Icon font could not be loaded."
	end
	return asset, nil
end

return table.freeze(Molto)

end)() end,
    [20] = function()local wax,script,require=ImportGlobals(20)local ImportGlobals return (function(...)-- Generated by scripts/build-runtime-assets.py. Do not edit by hand.
return table.freeze({
	Version = "3e953f3a220548a7fdb6fa8fdab532cb6bcc7505",
	BaseUrl = "https://raw.githubusercontent.com/jashxn/Ethos-Suite-Assets/3e953f3a220548a7fdb6fa8fdab532cb6bcc7505/images/ui/",
	Assets = {
		["6049668989"] = { File = "6049668989.png" },
		["9313765853"] = { File = "9313765853.png" },
		["72171626148979"] = { File = "72171626148979.png" },
		["81624121716376"] = { File = "81624121716376.png" },
		["81857207543459"] = { File = "81857207543459.png" },
		["113005153483202"] = { File = "113005153483202.png" },
		["115758629709887"] = { File = "115758629709887.png" },
		["116215943524454"] = { File = "116215943524454.png" },
		["117616164364352"] = { File = "117616164364352.png" },
		["118471988295372"] = { File = "118471988295372.png" },
		["121899300432067"] = { File = "121899300432067.png" },
		["122288503920903"] = { File = "122288503920903.png" },
		["126065347737085"] = { File = "126065347737085.png" },
	},
})

end)() end,
    [22] = function()local wax,script,require=ImportGlobals(22)local ImportGlobals return (function(...)--!nocheck
--[[
	Roblox's own class reflection: the API dump (classes, inheritance, properties and their
	categories, tags and security) and ReflectionMetadata (Studio's explorer icon index and sort
	order). Both are downloaded once per client version and cached on disk when the executor can
	write files. Without HTTP the explorer still works; the properties panel falls back to the
	executor's getproperties or a short list, and icons fall back to a generic one.
]]

local Env = require(script.Parent.env)

local VERSION_URL = "https://clientsettings.roblox.com/v2/client-version/WindowsStudio64/channel/LIVE"
local DUMP_URLS = {
	"https://setup.rbxcdn.com/%s-API-Dump.json",
	"http://setup.roblox.com/%s-API-Dump.json",
}
local DUMP_MIRROR = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/API-Dump.json"
local RMD_URL = "https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml"
local CACHE = Env.ROOT .. "/cache"

local Api = {}

Api.Status = "idle" -- idle, loading, ready, failed
Api.Problem = nil
Api.Version = nil

local classes = {} -- name -> { Name, Superclass, Tags, Properties, Events, Functions, Icon, Order }
local propertyCache = {}
local listeners = {}

local function tagSet(tags)
	local set = {}
	if tags then
		for _, tag in tags do
			if type(tag) == "string" then
				set[tag] = true
			end
		end
	end
	return set
end

function Api.parseDump(dump)
	local parsed = {}
	for _, class in dump.Classes do
		local entry = {
			Name = class.Name,
			Superclass = if class.Superclass ~= "<<<ROOT>>>" then class.Superclass else nil,
			Tags = tagSet(class.Tags),
			Properties = {},
			Events = {},
			Functions = {},
		}
		for _, member in class.Members do
			local kind = member.MemberType
			if kind == "Property" then
				local security = member.Security or {}
				table.insert(
					entry.Properties,
					{
						Name = member.Name,
						Category = member.Category or "Other",
						ValueType = member.ValueType,
						Tags = tagSet(member.Tags),
						Read = if type(security) == "table" then security.Read else security,
						Write = if type(security) == "table" then security.Write else security,
						Class = class.Name,
					}
				)
			elseif kind == "Event" then
				table.insert(entry.Events, member.Name)
			elseif kind == "Function" then
				table.insert(entry.Functions, member.Name)
			end
		end
		parsed[class.Name] = entry
	end
	return parsed
end

-- ReflectionMetadata is XML; each class's own fields come before its nested member items, so
-- the text from one class item to the next item tag holds exactly that class's fields.
function Api.parseMetadata(xml: string)
	local meta = {}
	local marker = '<Item class="ReflectionMetadataClass">'
	local start = string.find(xml, marker, 1, true)
	while start do
		local after = start + #marker
		local nextItem = string.find(xml, "<Item ", after, true) or #xml
		local chunk = string.sub(xml, after, nextItem)
		local name = string.match(chunk, '<string name="Name">([^<]+)</string>')
		if name then
			meta[name] = {
				Icon = tonumber(
					string.match(chunk, '<string name="ExplorerImageIndex">(%d+)</string>')
				),
				Order = tonumber(
					string.match(chunk, '<string name="ExplorerOrder">(%-?%d+)</string>')
				),
			}
		end
		start = string.find(xml, marker, after, true)
	end
	return meta
end

local function cached(name: string): string?
	return Env.readFile(`{CACHE}/{name}`)
end

local function store(name: string, contents: string)
	if Env.canWrite() then
		Env.writeFile(`{CACHE}/{name}`, contents)
	end
end

local function fetchVersion(): string?
	local ok, body = Env.httpGet(VERSION_URL)
	if ok then
		local version = string.match(body, "(version%-%x+)")
		if version then
			return version
		end
	end
	return nil
end

local function fetchDump(version: string?): (string?, string?)
	if version then
		local hit = cached(`api-{version}.json`)
		if hit then
			return hit, nil
		end
		for _, pattern in DUMP_URLS do
			local ok, body = Env.httpGet(string.format(pattern, version))
			if ok and string.sub(body, 1, 1) == "{" then
				store(`api-{version}.json`, body)
				store("api-latest.txt", version)
				return body, nil
			end
		end
	end
	local ok, body = Env.httpGet(DUMP_MIRROR)
	if ok and string.sub(body, 1, 1) == "{" then
		return body, nil
	end
	-- Offline: the newest dump this executor has cached.
	local last = cached("api-latest.txt")
	local hit = last and cached(`api-{last}.json`)
	if hit then
		return hit, nil
	end
	return nil, "Couldn't download the Roblox API dump."
end

local function fetchMetadata(version: string?): string?
	local key = `rmd-{version or "latest"}.xml`
	local hit = cached(key)
	if hit then
		return hit
	end
	local ok, body = Env.httpGet(RMD_URL)
	if ok and string.find(body, "ReflectionMetadataClass", 1, true) then
		store(key, body)
		return body
	end
	return nil
end

function Api.onReady(callback)
	if Api.Status == "ready" or Api.Status == "failed" then
		task.spawn(callback)
	else
		table.insert(listeners, callback)
	end
end

local function finish(status: string, problem: string?)
	Api.Status = status
	Api.Problem = problem
	local waiting = listeners
	listeners = {}
	for _, callback in waiting do
		task.spawn(callback)
	end
end

-- Loads both sources. Yields. `progress(text)` hears each step.
function Api.load(progress: ((string) -> ())?)
	if Api.Status ~= "idle" then
		return
	end
	Api.Status = "loading"
	local say = progress
		or function()
		end
	say("Checking the Roblox version")
	local version = fetchVersion()
	Api.Version = version
	say("Loading the API dump")
	local body, problem = fetchDump(version)
	if body then
		local ok, result = pcall(Env.jsonDecode, body)
		if ok then
			classes = Api.parseDump(result)
		else
			body, problem = nil, "The API dump didn't parse: " .. tostring(result)
		end
	end
	say("Loading class icons")
	local xml = fetchMetadata(version)
	if xml then
		for name, meta in Api.parseMetadata(xml) do
			local class = classes[name]
			if class == nil then
				class = { Name = name, Tags = {}, Properties = {}, Events = {}, Functions = {} }
				classes[name] = class
			end
			class.Icon, class.Order = meta.Icon, meta.Order
		end
	end
	table.clear(propertyCache)
	finish(if body then "ready" else "failed", problem)
end

function Api.class(name: string)
	return classes[name]
end

function Api.hasDump(): boolean
	return next(classes) ~= nil and classes.Instance ~= nil
end

-- The class and its ancestors, nearest first.
function Api.lineage(name: string): { string }
	local chain = {}
	local current = classes[name]
	local guard = 0
	while current and guard < 64 do
		table.insert(chain, current.Name)
		current = current.Superclass and classes[current.Superclass]
		guard += 1
	end
	return chain
end

-- Every property of a class including inherited ones, by name, ancestors' first.
function Api.properties(name: string)
	local hit = propertyCache[name]
	if hit then
		return hit
	end
	local list, seen = {}, {}
	local chain = Api.lineage(name)
	for index = #chain, 1, -1 do
		for _, property in classes[chain[index]].Properties do
			if not seen[property.Name] then
				seen[property.Name] = true
				table.insert(list, property)
			end
		end
	end
	propertyCache[name] = list
	return list
end

function Api.members(name: string, kind: "Events" | "Functions"): { string }
	local list = {}
	for _, className in Api.lineage(name) do
		for _, member in classes[className][kind] do
			table.insert(list, member)
		end
	end
	table.sort(list)
	return list
end

-- Studio's explorer image index, inherited from the nearest ancestor that has one.
function Api.icon(name: string): number?
	local current = classes[name]
	local guard = 0
	while current and guard < 64 do
		if current.Icon then
			return current.Icon
		end
		current = current.Superclass and classes[current.Superclass]
		guard += 1
	end
	return nil
end

function Api.order(name: string): number
	local class = classes[name]
	return class and class.Order or 1000
end

-- Classes Instance.new can make, for Insert Object.
function Api.creatable(): { string }
	local list = {}
	for name, class in classes do
		if class.Superclass ~= nil
			and not class.Tags.NotCreatable
			and not class.Tags.Service
			and not class.Tags.Deprecated
			and not class.Tags.NotBrowsable then
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

return Api

end)() end,
    [23] = function()local wax,script,require=ImportGlobals(23)local ImportGlobals return (function(...)--!nocheck
--[[
	The executor surface. Every executor ships a different subset of the custom functions, under
	different names, so each one is looked up by every name it is known by and given a fallback.
	Nothing outside this module touches an executor global, so a missing function only ever
	disables the feature that needs it.

	Test hook: `getgenv().EthosDexDisable = { "decompile", "gethui", ... }` before loading makes
	those names look missing, to check the fallbacks on a fully featured executor.
]]

local HttpService = game:GetService("HttpService")

local genv = if typeof(getgenv) == "function" then getgenv() else getfenv(0)
local chunkEnv = getfenv(0)

local disabled = {}
if type(genv.EthosDexDisable) == "table" then
	for _, name in genv.EthosDexDisable do
		disabled[name] = true
	end
end

local function lookup(path: string)
	if disabled[path] then
		return nil
	end
	local ok, value = pcall(function()
		local current = nil
		for part in string.gmatch(path, "[^%.]+") do
			if current == nil then
				current = genv[part]
				if current == nil then
					current = chunkEnv[part]
				end
			else
				current = if type(current) == "table" then current[part] else nil
			end
			if current == nil then
				return nil
			end
		end
		return current
	end)
	return if ok then value else nil
end

-- The first of the names that resolves to a function.
local function pick(...): any
	for index = 1, select("#", ...) do
		local value = lookup((select(index, ...)))
		if type(value) == "function" then
			return value
		end
	end
	return nil
end

local Env = {}

local cloneref = pick("cloneref", "clonereference")
Env.cloneref = function(instance)
	if cloneref == nil or typeof(instance) ~= "Instance" then
		return instance
	end
	local ok, clone = pcall(cloneref, instance)
	return if ok and clone ~= nil then clone else instance
end

local services = {}
function Env.service(name: string): any
	local cached = services[name]
	if cached then
		return cached
	end
	local ok, service = pcall(game.GetService, game, name)
	if not ok or service == nil then
		ok, service = pcall(game.FindService, game, name)
	end
	if ok and service then
		service = Env.cloneref(service)
		services[name] = service
		return service
	end
	return nil
end

local identify = pick("identifyexecutor", "getexecutorname", "whatexecutor")
Env.executor = (function()
	if identify then
		local ok, name, version = pcall(identify)
		if ok and type(name) == "string" then
			return if type(version) == "string" then `{name} {version}` else name
		end
	end
	return "Unknown executor"
end)()

-- Raw functions, by what Dex++ and the UNC call them. nil means unsupported.
local raw = {
	gethui = pick("gethui", "get_hidden_gui"),
	protectGui = pick("protect_gui", "syn.protect_gui", "protectgui"),
	getcustomasset = pick("getcustomasset", "getsynasset"),
	decompile = pick("decompile"),
	getscriptbytecode = pick("getscriptbytecode", "dumpstring"),
	getscripthash = pick("getscripthash"),
	saveinstance = pick("saveinstance", "syn.saveinstance"),
	getnilinstances = pick("getnilinstances", "get_nil_instances"),
	getinstances = pick("getinstances", "get_instances"),
	getloadedmodules = pick("getloadedmodules", "get_loaded_modules"),
	getrunningscripts = pick("getrunningscripts", "get_running_scripts"),
	gethiddenproperty = pick("gethiddenproperty", "gethiddenprop"),
	sethiddenproperty = pick("sethiddenproperty", "sethiddenprop"),
	getproperties = pick("getproperties"),
	setclipboard = pick(
		"setclipboard",
		"toclipboard",
		"set_clipboard",
		"Clipboard.set",
		"writeclipboard",
		"setrbxclipboard"
	),
	readfile = pick("readfile"),
	writefile = pick("writefile"),
	appendfile = pick("appendfile"),
	isfile = pick("isfile"),
	isfolder = pick("isfolder"),
	makefolder = pick("makefolder"),
	listfiles = pick("listfiles"),
	delfile = pick("delfile"),
	request = pick("request", "http_request", "syn.request", "http.request", "fluxus.request"),
	loadstring = pick("loadstring"),
	getsenv = pick("getsenv"),
	getconnections = pick("getconnections", "get_signal_cons"),
	firesignal = pick("firesignal"),
	fireclickdetector = pick("fireclickdetector"),
	fireproximityprompt = pick("fireproximityprompt"),
	firetouchinterest = pick("firetouchinterest"),
	getthreadidentity = pick("getthreadidentity", "getidentity", "get_thread_identity"),
	setthreadidentity = pick("setthreadidentity", "setidentity", "set_thread_identity"),
}
Env.raw = raw

function Env.has(name: string): boolean
	return raw[name] ~= nil
end

-- What each feature needs, for the settings page and for disabling actions.
Env.FEATURES = table.freeze({
	{ Name = "Hidden UI container", Needs = { "gethui", "protectGui" }, Any = true },
	{ Name = "Decompile scripts", Needs = { "decompile", "getscriptbytecode" }, Any = true },
	{ Name = "Script bytecode", Needs = { "getscriptbytecode" } },
	{ Name = "Save instance", Needs = { "saveinstance", "loadstring" }, Any = true },
	{ Name = "Nil instances", Needs = { "getnilinstances" } },
	{ Name = "Hidden properties", Needs = { "gethiddenproperty" } },
	{ Name = "Clipboard", Needs = { "setclipboard" } },
	{ Name = "Files and cache", Needs = { "writefile", "readfile", "isfile", "makefolder" } },
	{ Name = "Custom assets", Needs = { "getcustomasset" } },
	{ Name = "HTTP requests", Needs = { "request" } },
	{ Name = "Run code (console)", Needs = { "loadstring" } },
	{ Name = "Script environments", Needs = { "getsenv" } },
	{ Name = "Signal connections", Needs = { "getconnections" } },
	{ Name = "Fire click detectors", Needs = { "fireclickdetector" } },
	{ Name = "Fire proximity prompts", Needs = { "fireproximityprompt" } },
	{ Name = "Fire touch interests", Needs = { "firetouchinterest" } },
})

function Env.supports(feature): boolean
	for _, name in feature.Needs do
		local present = raw[name] ~= nil
		if feature.Any and present then
			return true
		elseif not feature.Any and not present then
			return false
		end
	end
	return not feature.Any
end

-- UI ----------------------------------------------------------------------------------------

-- Where the window lives: the executor's hidden container, then CoreGui, then PlayerGui.
function Env.guiParent(): Instance
	if raw.gethui then
		local ok, hui = pcall(raw.gethui)
		if ok and typeof(hui) == "Instance" then
			return hui
		end
	end
	local coreGui = Env.service("CoreGui")
	if coreGui
		and pcall(function()
			return coreGui:GetChildren()
		end) then
		local probe = Instance.new("Folder")
		if pcall(function()
			probe.Parent = coreGui
		end) then
			probe:Destroy()
			return coreGui
		end
		probe:Destroy()
	end
	local player = Env.service("Players").LocalPlayer
	return player:WaitForChild("PlayerGui")
end

function Env.protect(gui: Instance)
	if raw.protectGui then
		pcall(raw.protectGui, gui)
	end
end

function Env.clipboard(text: string): boolean
	if raw.setclipboard == nil then
		return false
	end
	return (pcall(raw.setclipboard, text))
end

-- Files ---------------------------------------------------------------------------------------

Env.ROOT = "EthosDex"

function Env.canWrite(): boolean
	return raw.writefile ~= nil
		and raw.readfile ~= nil
		and raw.isfile ~= nil
		and raw.makefolder ~= nil
end

function Env.ensureFolder(path: string): boolean
	if not Env.canWrite() then
		return false
	end
	local current = ""
	for part in string.gmatch(path, "[^/]+") do
		current = if current == "" then part else `{current}/{part}`
		local exists = raw.isfolder and select(2, pcall(raw.isfolder, current))
		if not exists then
			pcall(raw.makefolder, current)
		end
	end
	return true
end

function Env.readFile(path: string): string?
	if not Env.canWrite() then
		return nil
	end
	local ok, exists = pcall(raw.isfile, path)
	if not ok or not exists then
		return nil
	end
	local read, contents = pcall(raw.readfile, path)
	return if read and type(contents) == "string" then contents else nil
end

function Env.writeFile(path: string, contents: string): (boolean, string?)
	if not Env.canWrite() then
		return false, "This executor can't write files."
	end
	local folder = string.match(path, "^(.*)/[^/]*$")
	if folder then
		Env.ensureFolder(folder)
	end
	local ok, problem = pcall(raw.writefile, path, contents)
	return ok, if ok then nil else tostring(problem)
end

-- Strips characters Windows refuses in file names.
function Env.safeName(name: string): string
	local cleaned = string.gsub(tostring(name), '[%*\\%?:<>|"/]+', "_")
	return string.sub(cleaned, 1, 120)
end

function Env.customAsset(path: string): string?
	if raw.getcustomasset == nil then
		return nil
	end
	local ok, id = pcall(raw.getcustomasset, path)
	return if ok and type(id) == "string" and id ~= "" then id else nil
end

-- HTTP ----------------------------------------------------------------------------------------

function Env.httpGet(url: string): (boolean, string)
	local ok, body = pcall(function()
		return game:HttpGet(url, true)
	end)
	if ok and type(body) == "string" then
		return true, body
	end
	if raw.request then
		local sent, response = pcall(raw.request, { Url = url, Method = "GET" })
		if sent
			and type(response) == "table"
			and (response.StatusCode == nil or response.StatusCode < 400) then
			return true, response.Body or ""
		end
		return
			false,
			if sent and type(response) == "table" then `HTTP {response.StatusCode}`
				else tostring(response)
	end
	return false, tostring(body)
end

function Env.request(options)
	if raw.request == nil then
		return nil, "This executor has no request function."
	end
	local ok, response = pcall(raw.request, options)
	if not ok then
		return nil, tostring(response)
	end
	return response, nil
end

function Env.jsonDecode(text: string)
	return HttpService:JSONDecode(text)
end

function Env.jsonEncode(value): string
	return HttpService:JSONEncode(value)
end

-- Code ----------------------------------------------------------------------------------------

function Env.compile(source: string, chunkName: string?)
	if raw.loadstring == nil then
		return nil, "This executor has no loadstring."
	end
	local ok, fn, problem = pcall(raw.loadstring, source, chunkName)
	if not ok then
		return nil, tostring(fn)
	end
	return fn, problem
end

-- Scripts the client can hold bytecode for: client and module scripts.
function Env.canDecompile(object: Instance): boolean
	if not (raw.decompile or raw.getscriptbytecode) then
		return false
	end
	if object:IsA("ModuleScript") then
		return true
	end
	if object:IsA("LocalScript") then
		return true
	end
	if object:IsA("Script") then
		local ok, context = pcall(function()
			return object.RunContext
		end)
		return ok and context == Enum.RunContext.Client
	end
	return false
end

function Env.bytecode(object: Instance): (string?, string?)
	if raw.getscriptbytecode == nil then
		return nil, "This executor can't read script bytecode."
	end
	local ok, bytecode = pcall(raw.getscriptbytecode, object)
	if not ok then
		return nil, tostring(bytecode)
	elseif type(bytecode) ~= "string" or bytecode == "" then
		return nil, "The script has no bytecode (it may run on the server)."
	end
	return bytecode, nil
end

local KONSTANT = "https://api.plusgiant5.com/konstant/decompile"
local lastKonstant = 0

-- Sends the bytecode to the Konstant web decompiler, at most twice a second as its API asks.
local function konstant(object: Instance): (string?, string?)
	local bytecode, problem = Env.bytecode(object)
	if bytecode == nil then
		return nil, problem
	end
	if raw.request == nil then
		return nil, "This executor has no request function for the web decompiler."
	end
	local wait = 0.5 - (os.clock() - lastKonstant)
	if wait > 0 then
		task.wait(wait)
	end
	lastKonstant = os.clock()
	local response, failure = Env.request({
		Url = KONSTANT,
		Method = "POST",
		Body = bytecode,
		Headers = { ["Content-Type"] = "text/plain" },
	})
	if response == nil then
		return nil, failure
	elseif response.StatusCode == 0 or response.StatusCode == nil then
		return nil, "Couldn't reach the Konstant web decompiler; it may be down."
	elseif response.StatusCode ~= 200 then
		return nil, `Konstant answered {response.StatusCode}: {response.Body}`
	end
	return response.Body, nil
end

local function native(object: Instance): (string?, string?)
	if raw.decompile == nil then
		return nil, "This executor has no decompiler."
	end
	local ok, source = pcall(raw.decompile, object)
	if not ok then
		return nil, tostring(source)
	elseif type(source) ~= "string" or source == "" then
		return nil, "The decompiler returned nothing."
	end
	return source, nil
end

-- Advanced Decompiler V3 (the one Dex++ ships): decompiles the bytecode on this machine. Loaded
-- from GitHub the first time it's needed.
local ADVANCED = "https://raw.githubusercontent.com/AZYsGithub/Advanced-Decompiler-V3/refs/heads/main/init.lua"
local advancedFn = nil

local function advanced(object: Instance): (string?, string?)
	if raw.getscriptbytecode == nil then
		return nil, "This executor can't read script bytecode."
	end
	if advancedFn == nil then
		local ok, source = Env.httpGet(ADVANCED)
		if not ok then
			return nil, "Couldn't download Advanced Decompiler: " .. source
		end
		local chunk, problem = Env.compile(source, "=AdvancedDecompiler")
		if chunk == nil then
			return nil, problem
		end
		-- It looks for getscriptbytecode by that name; hand it whichever alias this executor has.
		pcall(
			setfenv,
			chunk,
			setmetatable({ getscriptbytecode = raw.getscriptbytecode }, { __index = genv })
		)
		local loaded, result = pcall(chunk)
		if not loaded or type(result) ~= "function" then
			return nil, "Advanced Decompiler didn't load: " .. tostring(result)
		end
		advancedFn = result
	end
	local ok, source = pcall(advancedFn, object, "optdec")
	if not ok then
		return nil, tostring(source)
	elseif type(source) ~= "string" or source == "" then
		return nil, "Advanced Decompiler returned nothing."
	elseif not string.find(source, "\n") and string.sub(source, 1, 2) == "--" then
		-- It reports failures (e.g. unsupported bytecode) as a lone comment instead of erroring.
		return nil, "Advanced Decompiler: " .. string.lower(string.gsub(source, "^%-%-%s*", ""))
	end
	return source, nil
end

Env.DECOMPILERS = table.freeze({ "Auto", "Executor", "Advanced", "Konstant" })

-- `mode`: "Auto" tries the executor's decompiler, then Advanced Decompiler, then Konstant; the
-- others use only that one.
function Env.decompile(object: Instance, mode: string?): (string?, string?)
	mode = mode or "Auto"
	if mode == "Executor" then
		return native(object)
	elseif mode == "Advanced" then
		return advanced(object)
	elseif mode == "Konstant" then
		return konstant(object)
	end
	local problems = {}
	for _, attempt in { native, advanced, konstant } do
		local source, problem = attempt(object)
		if source then
			return source, nil
		end
		table.insert(problems, problem)
	end
	return nil, table.concat(problems, " ")
end

local USSI = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"
local ussi = nil

local function loadUssi()
	if ussi then
		return ussi, nil
	end
	local ok, source = Env.httpGet(USSI)
	if not ok then
		return nil, "Couldn't download SynSaveInstance: " .. source
	end
	local fn, problem = Env.compile(source, "saveinstance")
	if fn == nil then
		return nil, problem
	end
	local loaded, result = pcall(fn)
	if not loaded or type(result) ~= "function" then
		return nil, "SynSaveInstance didn't load: " .. tostring(result)
	end
	ussi = result
	return ussi, nil
end

-- Saves `options.Object` (or the place) through the executor's saveinstance, falling back to
-- SynSaveInstance, whose options every common saveinstance shares.
function Env.saveInstance(options): (boolean, string?)
	if raw.saveinstance then
		local ok, problem = pcall(raw.saveinstance, options)
		if ok then
			return true, nil
		end
		-- Older saveinstances take (instance, path, options).
		ok = pcall(raw.saveinstance, options.Object or game, options.FilePath, options)
		if ok then
			return true, nil
		end
		if raw.loadstring == nil then
			return false, tostring(problem)
		end
	end
	local save, problem = loadUssi()
	if save == nil then
		return false, problem
	end
	local ok, failure = pcall(save, options)
	return ok, if ok then nil else tostring(failure)
end

-- Instances ------------------------------------------------------------------------------------

function Env.nilInstances(): { Instance }?
	if raw.getnilinstances == nil then
		return nil
	end
	local ok, list = pcall(raw.getnilinstances)
	return if ok and type(list) == "table" then list else nil
end

-- Reads a property, then retries it as a hidden one. Returns ok, value.
function Env.getProperty(object: Instance, name: string): (boolean, any)
	local ok, value = pcall(function()
		return object[name]
	end)
	if ok then
		return true, value
	end
	if raw.gethiddenproperty then
		local hidden, result = pcall(raw.gethiddenproperty, object, name)
		if hidden then
			return true, result
		end
	end
	return false, value
end

function Env.setProperty(object: Instance, name: string, value: any): (boolean, string?)
	local ok, problem = pcall(function()
		object[name] = value
	end)
	if ok then
		return true, nil
	end
	if raw.sethiddenproperty then
		local hidden, result = pcall(raw.sethiddenproperty, object, name, value)
		if hidden then
			return true, nil
		end
		problem = result
	end
	return false, tostring(problem)
end

function Env.fire(kind: string, object: Instance): (boolean, string?)
	local fn = raw[kind]
	if fn == nil then
		return false, "This executor doesn't support that."
	end
	local ok, problem
	if kind == "firetouchinterest" then
		local player = Env.service("Players").LocalPlayer
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root == nil then
			return false, "Your character has no HumanoidRootPart."
		end
		ok, problem = pcall(function()
			fn(root, object, 0)
			task.wait()
			fn(root, object, 1)
		end)
	else
		ok, problem = pcall(fn, object)
	end
	return ok, if ok then nil else tostring(problem)
end

return table.freeze(Env)

end)() end,
    [24] = function()local wax,script,require=ImportGlobals(24)local ImportGlobals return (function(...)--!nocheck
-- An instance's path as Luau that finds it again, the way Dex's "Copy path" writes it.

local Path = {}

local KEYWORDS = {}
for _, word in string.split(
	"and break do else elseif end false for function if in local nil not or repeat return then true until while continue export type",
	" "
) do
	KEYWORDS[word] = true
end

function Path.index(name: string): string
	if string.match(name, "^[%a_][%w_]*$") and not KEYWORDS[name] then
		return "." .. name
	end
	return `[{string.format("%q", name)}]`
end

-- `game` is the DataModel; `localPlayer` shortens paths through the local player.
function Path.of(instance: Instance, game: Instance, localPlayer: Instance?): string
	if instance == game then
		return "game"
	end
	local parts = {}
	local current = instance
	while current do
		if current == localPlayer then
			table.insert(parts, 1, 'game:GetService("Players").LocalPlayer')
			return table.concat(parts)
		end
		local parent = current.Parent
		if parent == game then
			local ok, service = pcall(game.FindService, game, current.ClassName)
			if ok and service == current then
				table.insert(parts, 1, `game:GetService("{current.ClassName}")`)
			else
				table.insert(parts, 1, "game" .. Path.index(current.Name))
			end
			return table.concat(parts)
		elseif parent == nil then
			-- Parented to nil: find it again through getnilinstances.
			table.insert(
				parts,
				1,
				string.format(
					"(function() for _, v in getnilinstances() do if v.Name == %q and v.ClassName == %q then return v end end end)()",
					current.Name,
					current.ClassName
				)
			)
			return table.concat(parts)
		end
		table.insert(parts, 1, Path.index(current.Name))
		current = parent
	end
	return table.concat(parts)
end

-- Ancestors from the top down, for the breadcrumb.
function Path.chain(instance: Instance, game: Instance): { Instance }
	local chain = {}
	local current = instance
	while current and current ~= game do
		table.insert(chain, 1, current)
		current = current.Parent
	end
	return chain
end

return table.freeze(Path)

end)() end,
    [25] = function()local wax,script,require=ImportGlobals(25)local ImportGlobals return (function(...)--!nocheck
--[[
	Explorer search. A query is space-separated terms that must all match:
		class:Part    exact ClassName (any case)
		isa:BasePart  IsA
		tag:Coin      has the CollectionService tag
		attr:Health   has the attribute
		anything else part of the Name (any case, plain text)
	`run` walks the game in slices so a big place never freezes a frame, and returns the
	explorer filter: instance -> 1 for a match, 2 for an ancestor of one, 3 for both.
]]

local Tree = require(script.Parent.tree)

local Search = {}

Search.LIMIT = 3000
local SLICE = 3000

function Search.parse(query: string)
	local conditions = { Name = nil, Class = nil, IsA = nil, Tag = nil, Attribute = nil }
	local words = {}
	for term in string.gmatch(query, "%S+") do
		local key, value = string.match(term, "^(%a+):(.+)$")
		key = key and string.lower(key)
		if key == "class" then
			conditions.Class = string.lower(value)
		elseif key == "isa" then
			conditions.IsA = value
		elseif key == "tag" then
			conditions.Tag = value
		elseif key == "attr" then
			conditions.Attribute = value
		else
			table.insert(words, term)
		end
	end
	if #words > 0 then
		conditions.Name = string.lower(table.concat(words, " "))
	end
	return conditions
end

function Search.matches(instance: Instance, conditions): boolean
	local ok, result = pcall(function()
		if conditions.Name
			and not string.find(string.lower(instance.Name), conditions.Name, 1, true) then
			return false
		end
		if conditions.Class and string.lower(instance.ClassName) ~= conditions.Class then
			return false
		end
		if conditions.IsA and not instance:IsA(conditions.IsA) then
			return false
		end
		if conditions.Tag and not instance:HasTag(conditions.Tag) then
			return false
		end
		if conditions.Attribute and instance:GetAttribute(conditions.Attribute) == nil then
			return false
		end
		return true
	end)
	return ok and result
end

local function mark(filter, instance, game)
	filter[instance] = bit32.bor(filter[instance] or 0, 1)
	local current = instance
	while true do
		local ok, parent = pcall(function()
			return current.Parent
		end)
		if not ok then
			return
		end
		if parent == nil then
			if current ~= game then
				filter[Tree.NIL_ROOT] = 2
			end
			return
		end
		if parent == game then
			return
		end
		local bits = filter[parent] or 0
		if bit32.band(bits, 2) ~= 0 then
			return
		end
		filter[parent] = bit32.bor(bits, 2)
		current = parent
	end
end

-- Yields. `isCancelled()` stops early (a newer query started). Returns filter, count, capped.
function Search.run(
	game: Instance,
	query: string,
	nilInstances: { Instance }?,
	isCancelled: () -> boolean
)
	local conditions = Search.parse(query)
	local filter, count = {}, 0
	local sources = { game:GetDescendants() }
	if nilInstances then
		local list = {}
		for _, object in nilInstances do
			table.insert(list, object)
			local ok, descendants = pcall(object.GetDescendants, object)
			if ok then
				table.move(descendants, 1, #descendants, #list + 1, list)
			end
		end
		table.insert(sources, list)
	end
	local checked = 0
	for _, list in sources do
		for _, instance in list do
			checked += 1
			if checked % SLICE == 0 then
				task.wait()
				if isCancelled() then
					return nil, 0, false
				end
			end
			if Search.matches(instance, conditions) then
				count += 1
				mark(filter, instance, game)
				if count >= Search.LIMIT then
					return filter, count, true
				end
			end
		end
	end
	return filter, count, false
end

return Search

end)() end,
    [26] = function()local wax,script,require=ImportGlobals(26)local ImportGlobals return (function(...)--!nocheck
-- Preferences, as Fusion values, saved to EthosDex/settings.json when the executor has files.

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Internal = require(Root.packages.internal)
local Env = require(script.Parent.env)

local scope = Internal.Scope
local peek = Fusion.peek

local FILE = Env.ROOT .. "/settings.json"

local DEFAULTS = {
	Theme = "eclipse",
	Decompiler = "Auto",
	ShowHidden = false,
	ShowDeprecated = false,
	ShowNil = true,
	ToggleKey = "RightControl",
	ExplorerWidth = 300,
	WindowWidth = 980,
	WindowHeight = 600,
	SaveDecompile = true,
}

local Settings = {}
local values = {}

local saved = {}
local text = Env.readFile(FILE)
if text then
	local ok, decoded = pcall(Env.jsonDecode, text)
	if ok and type(decoded) == "table" then
		saved = decoded
	end
end

for key, default in DEFAULTS do
	local value = saved[key]
	if typeof(value) ~= typeof(default) then
		value = default
	end
	values[key] = scope:Value(value)
end

local pending = false
local function save()
	if pending or not Env.canWrite() then
		return
	end
	pending = true
	task.delay(
		0.5,
		function()
			pending = false
			local out = {}
			for key, value in values do
				out[key] = peek(value)
			end
			Env.writeFile(FILE, Env.jsonEncode(out))
		end
	)
end

for _, value in values do
	scope:Observer(value):onChange(save)
end

function Settings.get(key: string)
	return peek(values[key])
end

function Settings.set(key: string, value)
	values[key]:set(value)
end

function Settings.state(key: string)
	return values[key]
end

Settings.DEFAULTS = table.freeze(DEFAULTS)

return table.freeze(Settings)

end)() end,
    [27] = function()local wax,script,require=ImportGlobals(27)local ImportGlobals return (function(...)--!nocheck
--[[
	The explorer's model. A node per instance the user has opened down to; children load the
	first time their parent opens and from then on follow ChildAdded/ChildRemoved on that one
	parent, so a game with 100k instances only costs what has been opened. Removals only mark
	the node; `flat()` drops marked nodes while it walks. `flat()` returns the visible rows in
	order and is what the virtualized list draws, rebuilt at most once a frame by the caller
	when `onDirty` fires.

	A filter (from a search) replaces expansion: a map of instance -> bits, 1 for a match and 2
	for an ancestor of one. Every instance in it is shown, and ancestors are open unless the user
	closes them.
]]

local Tree = {}
Tree.__index = Tree

local NIL_ROOT = table.freeze({ Name = "Nil instances", ClassName = "Folder", Virtual = true })
Tree.NIL_ROOT = NIL_ROOT

export type Node = {
	Instance: any,
	Parent: Node?,
	Children: { Node }?,
	Expanded: boolean,
	Closed: boolean, -- closed by the user while a filter is on
	Removed: boolean,
	Unsorted: boolean,
	Depth: number,
	Order: number,
	Key: string,
	Seq: number,
	Connections: { RBXScriptConnection }?,
}

-- options: Roots () -> { Instance }, Order (className) -> number, NilInstances (() -> {Instance})?,
-- OnDirty () -> ()
function Tree.new(options)
	local self = setmetatable({}, Tree)
	self.Options = options
	self.Nodes = {} -- Instance -> Node
	self.Roots = {}
	self.Filter = nil
	self.Dirty = true
	self.Seq = 0
	self.FlatCache = {}
	self.RootConnections = {}
	self:_buildRoots()
	return self
end

function Tree:_dirty()
	if not self.Dirty then
		self.Dirty = true
		if self.Options.OnDirty then
			self.Options.OnDirty()
		end
	end
end

function Tree:_node(instance, parent)
	self.Seq += 1
	local ok, name, className = pcall(function()
		return instance.Name, instance.ClassName
	end)
	local node = {
		Instance = instance,
		Parent = parent,
		Children = nil,
		Expanded = false,
		Closed = false,
		Removed = false,
		Unsorted = false,
		Depth = 0,
		Order = if ok then self.Options.Order(className) else 1000,
		Key = if ok then string.lower(name) else "",
		Seq = self.Seq,
		Connections = nil,
	}
	if instance ~= NIL_ROOT then
		self.Nodes[instance] = node
	end
	return node
end

local function compare(a, b)
	if a.Order ~= b.Order then
		return a.Order < b.Order
	elseif a.Key ~= b.Key then
		return a.Key < b.Key
	end
	return a.Seq < b.Seq
end

function Tree:_buildRoots()
	for _, root in self.Options.Roots() do
		table.insert(self.Roots, self:_node(root, nil))
	end
	if self.Options.NilInstances then
		table.insert(self.Roots, self:_node(NIL_ROOT, nil))
	end
	table.sort(
		self.Roots,
		function(a, b)
			if a.Instance == NIL_ROOT or b.Instance == NIL_ROOT then
				return b.Instance == NIL_ROOT and a.Instance ~= NIL_ROOT
			end
			return compare(a, b)
		end
	)
	-- New services appear at the top level.
	local game = self.Options.Game
	if game then
		table.insert(
			self.RootConnections,
			game.ChildAdded:Connect(function(child)
				if self.Nodes[child] == nil then
					local node = self:_node(child, nil)
					table.insert(
						self.Roots,
						#self.Roots + (if self.Options.NilInstances then 0 else 1),
						node
					)
					self:_dirty()
				end
			end)
		)
	end
end

function Tree:_forget(node)
	if node.Connections then
		for _, connection in node.Connections do
			connection:Disconnect()
		end
		node.Connections = nil
	end
	node.Removed = true
	if self.Nodes[node.Instance] == node then
		self.Nodes[node.Instance] = nil
	end
	if node.Children then
		for _, child in node.Children do
			self:_forget(child)
		end
	end
end

function Tree:_load(node)
	if node.Children then
		return
	end
	node.Children = {}
	local instance = node.Instance
	if instance == NIL_ROOT then
		for _, object in self.Options.NilInstances() or {} do
			if self.Nodes[object] == nil then
				table.insert(node.Children, self:_node(object, node))
			end
		end
		table.sort(node.Children, compare)
		return
	end
	local ok, children = pcall(instance.GetChildren, instance)
	if not ok then
		return
	end
	for _, child in children do
		table.insert(node.Children, self:_node(child, node))
	end
	table.sort(node.Children, compare)
	node.Connections = {
		instance.ChildAdded:Connect(function(child)
			if node.Removed or (self.Nodes[child] and not self.Nodes[child].Removed) then
				return
			end
			table.insert(node.Children, self:_node(child, node))
			node.Unsorted = true
			self:_dirty()
		end),
		instance.ChildRemoved:Connect(function(child)
			local removed = self.Nodes[child]
			if removed and removed.Parent == node then
				self:_forget(removed)
				self:_dirty()
			end
		end),
	}
end

-- Re-reads the nil-instance list (it has no events).
function Tree:refreshNil()
	for _, root in self.Roots do
		if root.Instance == NIL_ROOT and root.Children then
			for _, child in root.Children do
				self:_forget(child)
			end
			root.Children = nil
			if root.Expanded then
				self:_load(root)
			end
		end
	end
	self:_dirty()
end

-- A node's name changed: its sort key and its parent's order are stale.
function Tree:renamed(instance)
	local node = self.Nodes[instance]
	if node then
		local ok, name = pcall(function()
			return instance.Name
		end)
		if ok and string.lower(name) ~= node.Key then
			node.Key = string.lower(name)
			if node.Parent then
				node.Parent.Unsorted = true
			end
			self:_dirty()
		end
	end
end

function Tree:isOpen(node): boolean
	if self.Filter then
		return not node.Closed
	end
	return node.Expanded
end

function Tree:setExpanded(node, expanded: boolean)
	if self.Filter then
		node.Closed = not expanded
	else
		node.Expanded = expanded
	end
	if expanded then
		self:_load(node)
	end
	self:_dirty()
end

function Tree:toggle(node)
	self:setExpanded(node, not self:isOpen(node))
end

-- Opens or closes a node and everything under it that's loaded (or loads, when opening).
function Tree:setExpandedDeep(node, expanded: boolean, limit: number?)
	local budget = limit or 2000
	local function walk(current)
		if budget <= 0 then
			return
		end
		budget -= 1
		self:setExpanded(current, expanded)
		if current.Children then
			for _, child in current.Children do
				if not child.Removed then
					walk(child)
				end
			end
		end
	end
	walk(node)
end

function Tree:collapseAll()
	for _, node in self.Nodes do
		node.Expanded = false
	end
	for _, root in self.Roots do
		root.Expanded = false
	end
	self:_dirty()
end

-- The node for an instance, opening every ancestor so it is visible. nil when it isn't in the
-- tree (destroyed, or parented to nil and nil instances are off).
function Tree:reveal(instance)
	if instance == nil then
		return nil
	end
	local chain = {}
	local current = instance
	local game = self.Options.Game
	while current ~= nil and current ~= game do
		table.insert(chain, 1, current)
		local known = self.Nodes[current]
		if known and known.Parent == nil then
			break -- a top-level row
		end
		local ok, parent = pcall(function()
			return current.Parent
		end)
		current = if ok then parent else nil
	end
	local parentNode = nil
	if current == nil then
		-- Parented to nil at the top: it lives under the nil root.
		for _, root in self.Roots do
			if root.Instance == NIL_ROOT then
				parentNode = root
			end
		end
		if parentNode == nil then
			return nil
		end
		self:setExpanded(parentNode, true)
		if self.Nodes[chain[1]] == nil then
			self:refreshNil()
			self:setExpanded(parentNode, true)
		end
	end
	local node = nil
	for _, object in chain do
		node = self.Nodes[object]
		if node == nil and parentNode then
			self:setExpanded(parentNode, true)
			node = self.Nodes[object]
		end
		if node == nil then
			return nil
		end
		parentNode = node
	end
	local up = node and node.Parent
	while up do
		self:setExpanded(up, true)
		up = up.Parent
	end
	return node
end

-- filter: set of instances to show (matches and their ancestors), or nil for the normal tree.
function Tree:setFilter(filter)
	self.Filter = filter
	if filter then
		for _, node in self.Nodes do
			node.Closed = false
		end
		for _, root in self.Roots do
			root.Closed = false
		end
	end
	self:_dirty()
end

local function compact(children)
	local write = 0
	for read = 1, #children do
		local child = children[read]
		if not child.Removed then
			write += 1
			children[write] = child
		end
	end
	for index = #children, write + 1, -1 do
		children[index] = nil
	end
end

-- The visible rows, top to bottom.
function Tree:flat(): { Node }
	if not self.Dirty then
		return self.FlatCache
	end
	self.Dirty = false
	local flat = table.create(#self.FlatCache)
	local filter = self.Filter
	local function push(node, depth)
		node.Depth = depth
		table.insert(flat, node)
		if not self:isOpen(node) then
			return
		end
		-- With a filter only ancestors of matches (bit 2) have rows under them.
		if filter and bit32.band(filter[node.Instance] or 0, 2) == 0 then
			return
		end
		self:_load(node)
		local children = node.Children
		if children == nil then
			return
		end
		if node.Unsorted then
			compact(children)
			table.sort(children, compare)
			node.Unsorted = false
		end
		local hasRemoved = false
		for _, child in children do
			if child.Removed then
				hasRemoved = true
			elseif filter == nil or filter[child.Instance] then
				push(child, depth + 1)
			end
		end
		if hasRemoved then
			compact(children)
		end
	end
	for _, root in self.Roots do
		if not root.Removed
			and (filter == nil
				or filter[root.Instance]
				or root.Instance == NIL_ROOT and filter[NIL_ROOT]) then
			push(root, 0)
		end
	end
	self.FlatCache = flat
	return flat
end

function Tree:destroy()
	for _, connection in self.RootConnections do
		connection:Disconnect()
	end
	for _, node in self.Roots do
		self:_forget(node)
	end
	table.clear(self.Nodes)
	table.clear(self.Roots)
end

return Tree

end)() end,
    [28] = function()local wax,script,require=ImportGlobals(28)local ImportGlobals return (function(...)--!nocheck
-- Property values as the properties panel shows them, and text typed back into a value.

local Values = {}

local function num(n: number): string
	if n ~= n then
		return "nan"
	elseif n == math.huge then
		return "inf"
	elseif n == -math.huge then
		return "-inf"
	elseif n == math.floor(n) and math.abs(n) < 1e15 then
		return string.format("%d", n)
	end
	local text = string.format("%.3f", n)
	text = string.gsub(text, "0+$", "")
	return (string.gsub(text, "%.$", ""))
end
Values.num = num

local function join(...)
	local parts = table.pack(...)
	for index = 1, parts.n do
		parts[index] = num(parts[index])
	end
	return table.concat(parts, ", ")
end

function Values.format(value): string
	local kind = typeof(value)
	if kind == "nil" then
		return "nil"
	elseif kind == "string" then
		return value
	elseif kind == "number" then
		return num(value)
	elseif kind == "boolean" then
		return tostring(value)
	elseif kind == "Vector3" or kind == "Vector3int16" then
		return join(value.X, value.Y, value.Z)
	elseif kind == "Vector2" or kind == "Vector2int16" then
		return join(value.X, value.Y)
	elseif kind == "CFrame" then
		return join(value:GetComponents())
	elseif kind == "Color3" then
		return join(math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255))
	elseif kind == "BrickColor" then
		return value.Name
	elseif kind == "UDim" then
		return join(value.Scale, value.Offset)
	elseif kind == "UDim2" then
		return `\{{join(value.X.Scale, value.X.Offset)}}, \{{join(value.Y.Scale, value.Y.Offset)}}`
	elseif kind == "EnumItem" then
		return value.Name
	elseif kind == "Instance" then
		return value.Name
	elseif kind == "NumberRange" then
		return join(value.Min, value.Max)
	elseif kind == "Rect" then
		return join(value.Min.X, value.Min.Y, value.Max.X, value.Max.Y)
	elseif kind == "NumberSequence" then
		local points = {}
		for _, point in value.Keypoints do
			table.insert(points, `{num(point.Time)}: {num(point.Value)}`)
		end
		return table.concat(points, "  ")
	elseif kind == "ColorSequence" then
		local points = {}
		for _, point in value.Keypoints do
			table.insert(points, `{num(point.Time)}: #{point.Value:ToHex()}`)
		end
		return table.concat(points, "  ")
	elseif kind == "Font" then
		local family = string.match(value.Family, "([^/]+)%.json$") or value.Family
		return `{family}, {value.Weight.Name}, {value.Style.Name}`
	elseif kind == "PhysicalProperties" then
		return join(
			value.Density,
			value.Friction,
			value.Elasticity,
			value.FrictionWeight,
			value.ElasticityWeight
		)
	elseif kind == "Ray" then
		return `{join(value.Origin.X, value.Origin.Y, value.Origin.Z)} → {join(value.Direction.X, value.Direction.Y, value.Direction.Z)}`
	elseif kind == "Faces" or kind == "Axes" then
		local names = {}
		for _, name in { "Top", "Bottom", "Left", "Right", "Back", "Front", "X", "Y", "Z" } do
			local ok, on = pcall(function()
				return value[name]
			end)
			if ok and on then
				table.insert(names, name)
			end
		end
		return table.concat(names, ", ")
	elseif kind == "Content" then
		local ok, uri = pcall(function()
			return value.Uri
		end)
		return if ok and uri then uri else tostring(value)
	end
	return tostring(value)
end

local function numbers(text: string): { number }
	local list = {}
	for token in string.gmatch(text, "[^,%s{}()]+") do
		local n = tonumber(token)
		if n == nil then
			local lowered = string.lower(token)
			n = if lowered == "inf" or lowered == "math.huge" then math.huge
				elseif lowered == "-inf" or lowered == "-math.huge" then -math.huge
				else nil
		end
		if n == nil then
			return {}
		end
		table.insert(list, n)
	end
	return list
end
Values.numbers = numbers

-- Types the panel edits as text.
Values.TEXT_TYPES = table.freeze({
	string = true,
	number = true,
	Vector3 = true,
	Vector2 = true,
	Vector3int16 = true,
	Vector2int16 = true,
	CFrame = true,
	Color3 = true,
	BrickColor = true,
	UDim = true,
	UDim2 = true,
	NumberRange = true,
	Rect = true,
	Content = true,
})

-- Text typed for a property back into a value of the current value's type. Returns ok, value.
function Values.parse(text: string, current): (boolean, any)
	local kind = typeof(current)
	local n = numbers(text)
	if kind == "string" then
		return true, text
	elseif kind == "number" then
		return #n == 1, n[1]
	elseif kind == "Vector3" and #n == 3 then
		return true, Vector3.new(n[1], n[2], n[3])
	elseif kind == "Vector3int16" and #n == 3 then
		return true, Vector3int16.new(n[1], n[2], n[3])
	elseif kind == "Vector2" and #n == 2 then
		return true, Vector2.new(n[1], n[2])
	elseif kind == "Vector2int16" and #n == 2 then
		return true, Vector2int16.new(n[1], n[2])
	elseif kind == "CFrame" then
		if #n == 3 then
			return true, current.Rotation + Vector3.new(n[1], n[2], n[3])
		elseif #n == 12 then
			return true, CFrame.new(table.unpack(n))
		end
	elseif kind == "Color3" then
		local hex = string.match(text, "^%s*#?(%x%x%x%x%x%x)%s*$")
		if hex then
			return true, Color3.fromHex(hex)
		elseif #n == 3 then
			local scale = if n[1] <= 1 and n[2] <= 1 and n[3] <= 1 and string.find(text, "%.") then 1
				else 255
			return true, Color3.new(n[1] / scale, n[2] / scale, n[3] / scale)
		end
	elseif kind == "BrickColor" then
		local ok, color = pcall(BrickColor.new, tonumber(text) or text)
		return ok, color
	elseif kind == "UDim" and #n == 2 then
		return true, UDim.new(n[1], n[2])
	elseif kind == "UDim2" and #n == 4 then
		return true, UDim2.new(n[1], n[2], n[3], n[4])
	elseif kind == "NumberRange" and (#n == 1 or #n == 2) then
		return true, NumberRange.new(n[1], n[2] or n[1])
	elseif kind == "Rect" and #n == 4 then
		return true, Rect.new(n[1], n[2], n[3], n[4])
	elseif kind == "Content" then
		local ok, content = pcall(function()
			return Content.fromUri(text)
		end)
		return ok, content
	end
	return false, nil
end

-- Luau that rebuilds a value, for "Copy value".
function Values.code(value): string
	local kind = typeof(value)
	if kind == "string" then
		return string.format("%q", value)
	elseif kind == "Vector3"
		or kind == "Vector2"
		or kind == "UDim"
		or kind == "NumberRange"
		or kind == "Vector3int16"
		or kind == "Vector2int16" then
		return `{kind}.new({Values.format(value)})`
	elseif kind == "UDim2" then
		return `UDim2.new({join(value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)})`
	elseif kind == "CFrame" then
		return `CFrame.new({Values.format(value)})`
	elseif kind == "Color3" then
		return `Color3.fromRGB({Values.format(value)})`
	elseif kind == "BrickColor" then
		return `BrickColor.new("{value.Name}")`
	elseif kind == "EnumItem" then
		return tostring(value)
	elseif kind == "Rect" then
		return `Rect.new({Values.format(value)})`
	end
	return Values.format(value)
end

return table.freeze(Values)

end)() end,
    [30] = function()local wax,script,require=ImportGlobals(30)local ImportGlobals return (function(...)if not LPH_OBFUSCATED then
	local env = getfenv()
	env.LPH_ATTRIBUTES = env.LPH_ATTRIBUTES
		or function()
		end
	env.VM = env.VM
		or function(...)
			return ...
		end
	env.PRESET = env.PRESET
		or function(...)
			return ...
		end
	env.ERROR_HANDLING = env.ERROR_HANDLING
		or function(...)
			return ...
		end
end

local a
local function resolveLibraryRoot(startAt)
	local current = startAt
	while current do
		if current:FindFirstChild("packages") and current:FindFirstChild("utils") then
			return current
		end
		current = current.Parent
	end

	error(("Unable to resolve library root from %s"):format(startAt:GetFullName()))
end

local Root = resolveLibraryRoot(script)
local services = require(Root.packages.services)
local b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, v =
	{
		function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(1)
			local e
			return (function(...)
				local f, g, h = d(c.Types), (d(c.External))
				type Fusion = f.Fusion
				export type Animatable = f.Animatable
				export type UsedAs<T> = f.UsedAs<T>
				export type Child = f.Child
				export type Computed<T> = f.Computed<T>
				export type Contextual<T> = f.Contextual<T>
				export type GraphObject = f.GraphObject
				export type For<KO, VO> = f.For<KO, VO>
				export type Observer = f.Observer
				export type PropertyTable = f.PropertyTable
				export type Scope<Constructors = Fusion> = f.Scope<Constructors>
				export type ScopedObject = f.ScopedObject
				export type SpecialKey = f.SpecialKey
				export type Spring<T> = f.Spring<T>
				export type StateObject<T> = f.StateObject<T>
				export type Task = f.Task
				export type Tween<T> = f.Tween<T>
				export type Use = f.Use
				export type Value<T, S = T> = f.Value<T, S>
				export type Version = f.Version
				do
					local i = d(c.RobloxExternal)
					g.setExternalProvider(i)
				end
				local i: Fusion = table.freeze({
					version = { major = 0, minor = 4, isRelease = false },
					cleanup = function()
						return g.stopUpdateStep()
					end,
					Contextual = d(c.Utility.Contextual),
					Safe = d(c.Utility.Safe),
					deriveScope = d(c.Memory.deriveScope),
					doCleanup = d(c.Memory.doCleanup),
					innerScope = d(c.Memory.innerScope),
					insert = d(c.Memory.insert),
					scoped = d(c.Memory.scoped),
					Observer = d(c.Graph.Observer),
					Computed = d(c.State.Computed),
					ForKeys = d(c.State.ForKeys) :: f.ForKeysConstructor,
					ForPairs = d(c.State.ForPairs) :: f.ForPairsConstructor,
					ForValues = d(c.State.ForValues) :: f.ForValuesConstructor,
					peek = d(c.State.peek),
					Value = d(c.State.Value),
					Attribute = d(c.Instances.Attribute),
					AttributeChange = d(c.Instances.AttributeChange),
					AttributeOut = d(c.Instances.AttributeOut),
					Child = d(c.Instances.Child),
					Children = d(c.Instances.Children),
					Hydrate = d(c.Instances.Hydrate),
					New = d(c.Instances.New),
					OnChange = d(c.Instances.OnChange),
					OnEvent = d(c.Instances.OnEvent),
					Out = d(c.Instances.Out),
					Tag = d(c.Instances.Tag),
					Tween = d(c.Animation.Tween),
					Spring = d(c.Animation.Spring),
				})
				return i
			end)()
		end,
		[3] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(3)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k =
					d(f.Types),
					d(f.External),
					d(f.Graph.change),
					d(f.Utility.nicknames)
				type ExternalTime = h.StateObject<number>
				type Self = ExternalTime
				local l = {}
				l.type = "State"
				l.kind = "ExternalTime"
				l.timeliness = "lazy"
				l.dependencySet = table.freeze({})
				setmetatable(
					l,
					{
						__index = function(_, key)
							if key == "_EXTREMELY_DANGEROUS_usedAsValue" then
								return i.lastUpdateStep()
							end
							return nil
						end,
					}
				)
				local m, n = table.freeze({ __index = l }), {}
				local function o(p: h.Scope<unknown>): ExternalTime
					local q = os.clock()
					local r: Self
					r = setmetatable(
						{
							createdAt = q,
							-- Graph.depend adds dependents by assignment, which marks the clock active.
							dependentSet = setmetatable(
								{},
								{
									__newindex = function(t, key, value)
										rawset(t, key, value)
										n[r] = true
									end,
								}
							),
							lastChange = nil,
							scope = p,
							validity = "invalid",
						},
						m
					) :: any
					local s = function()
						r.scope = nil
						n[r] = nil
					end
					r.oldestTask = s
					k[r.oldestTask] = "ExternalTime"
					table.insert(p, s)
					return r
				end
				function l._evaluate(p: Self): boolean
					return true
				end
				local stepping = {}
				i.bindToUpdateStep(function(p: number): ()
					for r in n do
						if next(r.dependentSet) == nil then
							n[r] = nil
						else
							table.insert(stepping, r)
						end
					end
					for _, r in stepping do
						j(r)
					end
					table.clear(stepping)
				end)
				return o
			end)()
		end,
		[4] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(4)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n, o, p, q, r, s, t, u, v =
					d(f.Types),
					d(f.External),
					d(f.Memory.checkLifetime),
					d(f.Graph.depend),
					d(f.Graph.change),
					d(f.Graph.evaluate),
					d(f.State.castToState),
					d(f.State.peek),
					d(f.Animation.ExternalTime),
					d(f.Animation.Stopwatch),
					d(f.Animation.packType),
					d(f.Animation.unpackType),
					d(f.Animation.springCoefficients),
					d(f.Utility.nicknames),
					0.00001
				type Self<T> = h.Spring<T> & {
					_activeDamping: number,
					_activeGoal: T,
					_activeLatestP: { number },
					_activeLatestV: { number },
					_activeNumSprings: number,
					_activeSpeed: number,
					_activeStartP: { number },
					_activeStartV: { number },
					_activeTargetP: { number },
					_activeType: string,
					_speed: h.UsedAs<number>,
					_damping: h.UsedAs<number>,
					_goal: h.UsedAs<T>,
					_stopwatch: q.Stopwatch,
				}
				local w = {}
				w.type = "State"
				w.kind = "Spring"
				w.timeliness = "eager"
				local x = table.freeze({ __index = w })
				local function y<T>(
					z: h.Scope<unknown>,
					A: h.UsedAs<T>,
					B: h.UsedAs<number>?,
					C: h.UsedAs<number>?
				): h.Spring<T>
					local D, E, F = os.clock(), (n(A))
					if E ~= nil then
						F = q(z, p(z))
						F:unpause()
					end
					local G, H = B or 10, C or 1
					local I: Self<T> = setmetatable(
						{
							createdAt = D,
							dependencySet = {},
							dependentSet = {},
							lastChange = nil,
							scope = z,
							validity = "invalid",
							_activeDamping = -1,
							_activeGoal = nil,
							_activeLatestP = {},
							_activeLatestV = {},
							_activeNumSprings = 0,
							_activeSpeed = -1,
							_activeStartP = {},
							_activeStartV = {},
							_activeTargetP = {},
							_activeType = "",
							_damping = H,
							_EXTREMELY_DANGEROUS_usedAsValue = o(A),
							_goal = A,
							_speed = G,
							_stopwatch = F,
						},
						x
					) :: any
					local J = function()
						I.scope = nil
						for J in pairs(I.dependencySet) do
							J.dependentSet[I] = nil
						end
					end
					I.oldestTask = J
					u[I.oldestTask] = "Spring"
					table.insert(z, J)
					if E ~= nil then
						j.bOutlivesA(
							z,
							I.oldestTask,
							E.scope,
							E.oldestTask,
							j.formatters.animationGoal
						)
					end
					local K = n(G)
					if K ~= nil then
						j.bOutlivesA(
							z,
							I.oldestTask,
							K.scope,
							K.oldestTask,
							j.formatters.parameter,
							"speed"
						)
					end
					local L = n(H)
					if L ~= nil then
						j.bOutlivesA(
							z,
							I.oldestTask,
							L.scope,
							L.oldestTask,
							j.formatters.parameter,
							"damping"
						)
					end
					m(I, true)
					return I
				end
				function w.addVelocity<T>(z: Self<T>, A: T): ()
					m(z, false)
					local B = typeof(A)
					if B ~= z._activeType then
						i.logError("springTypeMismatch", nil, B, z._activeType)
					end
					local C = s(A, B)
					for D, E in z._activeLatestV do
						C[D] += E
					end
					z._activeStartP = table.clone(z._activeLatestP)
					z._activeStartV = C
					z._stopwatch:zero()
					z._stopwatch:unpause()
					l(z)
				end
				function w.setPosition<T>(z: Self<T>, A: T): ()
					m(z, false)
					local B = typeof(A)
					if B ~= z._activeType then
						i.logError("springTypeMismatch", nil, B, z._activeType)
					end
					z._activeStartP = s(A, B)
					z._activeStartV = table.clone(z._activeLatestV)
					z._stopwatch:zero()
					z._stopwatch:unpause()
					l(z)
				end
				function w.setVelocity<T>(z: Self<T>, A: T): ()
					m(z, false)
					local B = typeof(A)
					if B ~= z._activeType then
						i.logError("springTypeMismatch", nil, B, z._activeType)
					end
					z._activeStartP = table.clone(z._activeLatestP)
					z._activeStartV = s(A, B)
					z._stopwatch:zero()
					z._stopwatch:unpause()
					l(z)
				end
				function w._evaluate<T>(z: Self<T>): boolean
					local A = n(z._goal)
					if A == nil then
						z._EXTREMELY_DANGEROUS_usedAsValue = z._goal :: T
						return false
					end
					local B, C = k(z, A), z._stopwatch :: q.Stopwatch
					local D = k(z, C)
					if B ~= B then
						i.logWarn("springNanGoal")
						return false
					end
					local E = typeof(B)
					local F, G: T = (E ~= z._activeType)
					if F then
						G = B
					else
						local H, I, J, K = t(D, z._activeDamping, z._activeSpeed)
						local L = false
						for M = 1, z._activeNumSprings do
							local N, O, P =
								z._activeStartP[M],
								z._activeTargetP[M],
								z._activeStartV[M]
							local Q = N - O
							local R, S = Q * H + P * I, Q * J + P * K
							if R ~= R or S ~= S then
								i.logWarn("springNanMotion")
								R, S = 0, 0
							end
							if math.abs(R) > v or math.abs(S) > v then
								L = true
							end
							local T = R + O
							z._activeLatestP[M] = T
							z._activeLatestV[M] = S
						end
						if not L and C:isPlaying() then
							z._activeLatestP = table.clone(z._activeTargetP)
							z._activeLatestV = table.create(z._activeNumSprings, 0)
							C:pause()
							C:zero()
						end
						G = r(z._activeLatestP, z._activeType) :: any
					end
					local H, I = o(z._speed) :: number, o(z._damping) :: number
					if F or B ~= z._activeGoal or H ~= z._activeSpeed or I ~= z._activeDamping then
						z._activeTargetP = s(B, E)
						z._activeNumSprings = #z._activeTargetP
						if F then
							z._activeStartP = table.clone(z._activeTargetP)
							z._activeLatestP = table.clone(z._activeTargetP)
							z._activeStartV = table.create(z._activeNumSprings, 0)
							z._activeLatestV = table.create(z._activeNumSprings, 0)
						else
							z._activeStartP = table.clone(z._activeLatestP)
							z._activeStartV = table.clone(z._activeLatestV)
						end
						z._activeType = E
						z._activeGoal = B
						z._activeDamping = I
						z._activeSpeed = H
						C:zero()
						C:unpause()
					end
					local J = z._EXTREMELY_DANGEROUS_usedAsValue
					z._EXTREMELY_DANGEROUS_usedAsValue = G
					return J ~= G
				end
				table.freeze(w)
				return y :: h.SpringConstructor
			end)()
		end,
		[5] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(5)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m =
					d(f.Types),
					d(f.Memory.checkLifetime),
					d(f.Graph.depend),
					d(f.Graph.change),
					d(f.State.peek),
					d(f.Utility.nicknames)
				export type Stopwatch = h.StateObject<number> & {
					zero: (Stopwatch) -> (),
					pause: (Stopwatch) -> (),
					unpause: (Stopwatch) -> (),
					isPlaying: (Stopwatch) -> boolean,
				}
				type Self = Stopwatch & {
					_measureTimeSince: number,
					_playing: boolean,
					_zeroFlag: boolean,
					_timer: h.StateObject<number>,
				}
				local n = {}
				n.type = "State"
				n.kind = "Stopwatch"
				n.timeliness = "lazy"
				local o = table.freeze({
					__index = n,
				})
				local function p(q: h.Scope<unknown>, r: h.StateObject<number>): Stopwatch
					local s = os.clock()
					local t: Self = setmetatable(
						{
							awake = true,
							createdAt = s,
							dependencySet = {},
							dependentSet = {},
							lastChange = nil,
							scope = q,
							validity = "invalid",
							_EXTREMELY_DANGEROUS_usedAsValue = 0,
							_measureTimeSince = 0,
							_playing = false,
							_zeroFlag = true,
							_timer = r,
						},
						o
					) :: any
					local u = function()
						t.scope = nil
					end
					t.oldestTask = u
					m[t.oldestTask] = "Stopwatch"
					table.insert(q, u)
					i.bOutlivesA(
						q,
						t.oldestTask,
						r.scope,
						r.oldestTask,
						i.formatters.parameter,
						"timer"
					)
					j(t, r)
					return t
				end
				function n.zero(q: Self): ()
					q._zeroFlag = true
					q._measureTimeSince = l(q._timer)
					k(q)
				end
				function n.pause(q: Self): ()
					if q._playing == true then
						q._playing = false
						k(q)
					end
				end
				function n.unpause(q: Self): ()
					if q._playing == false then
						q._playing = true
						q._measureTimeSince = l(q._timer)
							- (if q._zeroFlag then 0 else q._EXTREMELY_DANGEROUS_usedAsValue)
						k(q)
					end
				end
				function n.isPlaying(q: Self): boolean
					return q._playing
				end
				function n._evaluate(q: Self): boolean
					if q._playing then
						q._zeroFlag = false
						local r, s = j(q, q._timer), q._EXTREMELY_DANGEROUS_usedAsValue
						local t = r - q._measureTimeSince
						q._EXTREMELY_DANGEROUS_usedAsValue = t
						return s ~= t
					else
						return false
					end
				end
				table.freeze(n)
				return p
			end)()
		end,
		[6] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(6)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n, o, p, q, r, s, t =
					d(f.Types),
					d(f.External),
					d(f.Memory.checkLifetime),
					d(f.Graph.depend),
					d(f.Graph.evaluate),
					d(f.State.castToState),
					d(f.State.peek),
					d(f.Animation.ExternalTime),
					d(f.Animation.Stopwatch),
					d(f.Animation.lerpType),
					d(f.Animation.getTweenRatio),
					d(f.Animation.getTweenDuration),
					d(f.Utility.nicknames)
				export type Self<T> = h.Tween<T> & {
					_activeDuration: number,
					_activeElapsed: number,
					_activeFrom: T,
					_activeTo: T,
					_activeTweenInfo: TweenInfo,
					_goal: h.UsedAs<T>,
					_stopwatch: p.Stopwatch?,
					_tweenInfo: h.UsedAs<TweenInfo>,
				}
				local u = {}
				u.type = "State"
				u.kind = "Tween"
				u.timeliness = "eager"
				local v = table.freeze({ __index = u })
				local function w<T>(x: h.Scope<unknown>, y: h.UsedAs<T>, z: h.UsedAs<TweenInfo>?): h.Tween<T>
					local A, B, C = os.clock(), (m(y))
					if B ~= nil then
						C = p(x, o(x))
					end
					local D: Self<T> = setmetatable(
						{
							createdAt = A,
							dependencySet = {},
							dependentSet = {},
							lastChange = nil,
							scope = x,
							validity = "invalid",
							_activeDuration = nil,
							_activeElapsed = nil,
							_activeFrom = nil,
							_activeTo = nil,
							_activeTweenInfo = nil,
							_EXTREMELY_DANGEROUS_usedAsValue = n(y),
							_goal = y,
							_stopwatch = C,
							_tweenInfo = z or TweenInfo.new(),
						},
						v
					) :: any
					local E = function()
						D.scope = nil
						for E in pairs(D.dependencySet) do
							E.dependentSet[D] = nil
						end
					end
					D.oldestTask = E
					t[D.oldestTask] = "Tween"
					table.insert(x, E)
					if B ~= nil then
						j.bOutlivesA(
							x,
							D.oldestTask,
							B.scope,
							B.oldestTask,
							j.formatters.animationGoal
						)
					end
					local F = m(z)
					if F ~= nil then
						j.bOutlivesA(
							x,
							D.oldestTask,
							F.scope,
							F.oldestTask,
							j.formatters.parameter,
							"tween info"
						)
					end
					l(D, true)
					return D
				end
				function u._evaluate<T>(x: Self<T>): boolean
					local y = m(x._goal)
					if y == nil then
						x._EXTREMELY_DANGEROUS_usedAsValue = x._goal :: T
						return false
					end
					k(x, y)
					local z = n(y)
					if z ~= z then
						i.logWarn("tweenNanGoal")
						return false
					end
					local A, B = x._stopwatch :: p.Stopwatch, n(x._tweenInfo) :: TweenInfo
					if x._activeTo ~= z
						or (x._activeElapsed < x._activeDuration and x._activeTweenInfo ~= B) then
						x._activeDuration = s(B)
						x._activeFrom = x._EXTREMELY_DANGEROUS_usedAsValue
						x._activeTo = z
						x._activeTweenInfo = B
						A:zero()
						A:unpause()
					end
					k(x, A)
					x._activeElapsed = n(A)
					if x._activeFrom == x._activeTo
						or x._activeElapsed >= x._activeDuration
						or typeof(x._activeTo) ~= typeof(x._activeFrom) then
						x._activeFrom = x._activeTo
						x._activeElapsed = x._activeDuration
						A:pause()
					end
					local C, D = r(B, x._activeElapsed), x._EXTREMELY_DANGEROUS_usedAsValue
					local E = q(x._activeFrom, x._activeTo, C) :: T
					if E ~= E then
						i.logWarn("tweenNanMotion")
						E = x._activeTo
					end
					x._EXTREMELY_DANGEROUS_usedAsValue = E
					return D ~= E
				end
				table.freeze(u)
				return w :: h.TweenConstructor
			end)()
		end,
		[7] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(7)
			local e
			return (function(...)
				local f, g = (services.TweenService)
				local function h(i: TweenInfo): number
					if i.RepeatCount <= -1 then
						return math.huge
					end
					local j = i.DelayTime + i.Time
					if i.Reverses then
						j += i.Time
					end
					j *= i.RepeatCount + 1
					return j
				end
				return h
			end)()
		end,
		[8] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(8)
			local e
			return (function(...)
				local f, g = (services.TweenService)
				local function h(i: TweenInfo, j: number): number
					local k, l, m, n, o, p =
						i.DelayTime,
						i.Time,
						i.Reverses,
						1 + i.RepeatCount,
						i.EasingStyle,
						i.EasingDirection
					local q = k + l
					if m then
						q += l
					end
					if j == math.huge then
						return 1
					end
					if j >= q * n and i.RepeatCount > -1 then
						return 1
					end
					local r = j % q
					if r <= k then
						return 0
					end
					local s = (r - k) / l
					if s > 1 then
						s = 2 - s
					end
					local t = f:GetValue(s, o, p)
					return t
				end
				return h
			end)()
		end,
		[9] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(9)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Colour.Oklab)
				local function i(j: unknown, k: unknown, l: number): unknown
					local m = typeof(j)
					if typeof(k) == m then
						if m == "number" then
							local n, o = k :: number, j :: number
							return (n - o) * l + o
						elseif m == "CFrame" then
							local n, o = k :: CFrame, j :: CFrame
							return o:Lerp(n, l)
						elseif m == "Color3" then
							local n, o = k :: Color3, j :: Color3
							local p, q = h.fromSRGB(o), h.fromSRGB(n)
							return h.toSRGB(p:Lerp(q, l), false)
						elseif m == "ColorSequenceKeypoint" then
							local n, o = k :: ColorSequenceKeypoint, j :: ColorSequenceKeypoint
							local p, q = h.fromSRGB(o.Value), h.fromSRGB(n.Value)
							return ColorSequenceKeypoint.new(
								(n.Time - o.Time) * l + o.Time,
								h.toSRGB(p:Lerp(q, l), false)
							)
						elseif m == "DateTime" then
							local n, o = k :: DateTime, j :: DateTime
							return DateTime.fromUnixTimestampMillis(
								(n.UnixTimestampMillis - o.UnixTimestampMillis) * l
									+ o.UnixTimestampMillis
							)
						elseif m == "NumberRange" then
							local n, o = k :: NumberRange, j :: NumberRange
							return NumberRange.new(
								(n.Min - o.Min) * l + o.Min,
								(n.Max - o.Max) * l + o.Max
							)
						elseif m == "NumberSequenceKeypoint" then
							local n, o = k :: NumberSequenceKeypoint, j :: NumberSequenceKeypoint
							return NumberSequenceKeypoint.new(
								(n.Time - o.Time) * l + o.Time,
								(n.Value - o.Value) * l + o.Value,
								(n.Envelope - o.Envelope) * l + o.Envelope
							)
						elseif m == "PhysicalProperties" then
							local n, o = k :: PhysicalProperties, j :: PhysicalProperties
							return PhysicalProperties.new(
								(n.Density - o.Density) * l + o.Density,
								(n.Friction - o.Friction) * l + o.Friction,
								(n.Elasticity - o.Elasticity) * l + o.Elasticity,
								(n.FrictionWeight - o.FrictionWeight) * l + o.FrictionWeight,
								(n.ElasticityWeight - o.ElasticityWeight) * l + o.ElasticityWeight
							)
						elseif m == "Ray" then
							local n, o = k :: Ray, j :: Ray
							return Ray.new(
								o.Origin:Lerp(n.Origin, l),
								o.Direction:Lerp(n.Direction, l)
							)
						elseif m == "Rect" then
							local n, o = k :: Rect, j :: Rect
							return Rect.new(o.Min:Lerp(n.Min, l), o.Max:Lerp(n.Max, l))
						elseif m == "Region3" then
							local n, o = k :: Region3, j :: Region3
							local p, q =
								o.CFrame.Position:Lerp(n.CFrame.Position, l),
								o.Size:Lerp(n.Size, l) / 2
							return Region3.new(p - q, p + q)
						elseif m == "Region3int16" then
							local n, o = k :: Region3int16, j :: Region3int16
							return Region3int16.new(
								Vector3int16.new(
									(n.Min.X - o.Min.X) * l + o.Min.X,
									(n.Min.Y - o.Min.Y) * l + o.Min.Y,
									(n.Min.Z - o.Min.Z) * l + o.Min.Z
								),
								Vector3int16.new(
									(n.Max.X - o.Max.X) * l + o.Max.X,
									(n.Max.Y - o.Max.Y) * l + o.Max.Y,
									(n.Max.Z - o.Max.Z) * l + o.Max.Z
								)
							)
						elseif m == "UDim" then
							local n, o = k :: UDim, j :: UDim
							return UDim.new(
								(n.Scale - o.Scale) * l + o.Scale,
								(n.Offset - o.Offset) * l + o.Offset
							)
						elseif m == "UDim2" then
							local n, o = k :: UDim2, j :: UDim2
							return o:Lerp(n, l)
						elseif m == "Vector2" then
							local n, o = k :: Vector2, j :: Vector2
							return o:Lerp(n, l)
						elseif m == "Vector2int16" then
							local n, o = k :: Vector2int16, j :: Vector2int16
							return Vector2int16.new((n.X - o.X) * l + o.X, (n.Y - o.Y) * l + o.Y)
						elseif m == "Vector3" then
							local n, o = k :: Vector3, j :: Vector3
							return o:Lerp(n, l)
						elseif m == "Vector3int16" then
							local n, o = k :: Vector3int16, j :: Vector3int16
							return Vector3int16.new(
								(n.X - o.X) * l + o.X,
								(n.Y - o.Y) * l + o.Y,
								(n.Z - o.Z) * l + o.Z
							)
						end
					end
					if l < 0.5 then
						return j
					else
						return k
					end
				end
				return i
			end)()
		end,
		[10] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(10)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i = d(f.Types), d(f.Colour.Oklab)
				local function j(k: { number }, l: string): h.Animatable?
					if l == "number" then
						return k[1]
					elseif l == "CFrame" then
						return CFrame.new(k[1], k[2], k[3])
							* CFrame.fromAxisAngle(Vector3.new(k[4], k[5], k[6]).Unit, k[7])
					elseif l == "Color3" then
						return i.toSRGB(Vector3.new(k[1], k[2], k[3]), false)
					elseif l == "ColorSequenceKeypoint" then
						return ColorSequenceKeypoint.new(
							k[4],
							i.toSRGB(Vector3.new(k[1], k[2], k[3]), false)
						)
					elseif l == "DateTime" then
						return DateTime.fromUnixTimestampMillis(k[1])
					elseif l == "NumberRange" then
						return NumberRange.new(k[1], k[2])
					elseif l == "NumberSequenceKeypoint" then
						return NumberSequenceKeypoint.new(k[2], k[1], k[3])
					elseif l == "PhysicalProperties" then
						return PhysicalProperties.new(k[1], k[2], k[3], k[4], k[5])
					elseif l == "Ray" then
						return Ray.new(Vector3.new(k[1], k[2], k[3]), Vector3.new(k[4], k[5], k[6]))
					elseif l == "Rect" then
						return Rect.new(k[1], k[2], k[3], k[4])
					elseif l == "Region3" then
						local m, n =
							Vector3.new(k[1], k[2], k[3]),
							Vector3.new(k[4] / 2, k[5] / 2, k[6] / 2)
						return Region3.new(m - n, m + n)
					elseif l == "Region3int16" then
						return Region3int16.new(
							Vector3int16.new(math.round(k[1]), math.round(k[2]), math.round(k[3])),
							Vector3int16.new(math.round(k[4]), math.round(k[5]), math.round(k[6]))
						)
					elseif l == "UDim" then
						return UDim.new(k[1], math.round(k[2]))
					elseif l == "UDim2" then
						return UDim2.new(k[1], math.round(k[2]), k[3], math.round(k[4]))
					elseif l == "Vector2" then
						return Vector2.new(k[1], k[2])
					elseif l == "Vector2int16" then
						return Vector2int16.new(math.round(k[1]), math.round(k[2]))
					elseif l == "Vector3" then
						return Vector3.new(k[1], k[2], k[3])
					elseif l == "Vector3int16" then
						return Vector3int16.new(
							math.round(k[1]),
							math.round(k[2]),
							math.round(k[3])
						)
					else
						return nil
					end
				end
				return j
			end)()
		end,
		[11] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(11)
			local e
			return (function(...)
				local f
				local function g(h: number, i: number, j: number): (number, number, number, number)
					if h == 0 or j == 0 then
						return 1, 0, 0, 1
					end
					local k, l, m, n
					if i > 1 then
						local o = math.sqrt(i ^ 2 - 1)
						local p, q, r = -0.5 / (o * j), j * (o + i) * -1, j * (o - i)
						local s, t = math.exp(h * q), math.exp(h * r)
						k = (t * q - s * r) * p
						l = (s - t) * p / j
						m = (t - s) * p * j
						n = (s * q - t * r) * p
					elseif i == 1 then
						local o = h * j
						local p = o * -1
						local q = math.exp(p)
						k = q * (o + 1)
						l = q * h
						m = q * (p * j)
						n = q * (p + 1)
					else
						local o = j * math.sqrt(1 - i ^ 2)
						local p, q, r, s =
							1 / o,
							math.exp(-1 * h * j * i),
							math.sin(o * h),
							math.cos(o * h)
						local t, u = q * r, q * s
						local v = t * j * i * p
						k = v + u
						l = t * p
						m = -1 * (t * o + j * i * v)
						n = u - v
					end
					return k, l, m, n
				end
				return g
			end)()
		end,
		[12] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(12)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Colour.Oklab)
				local function i(j: unknown, k: string): { number }
					if k == "number" then
						local l = j :: number
						return { l }
					elseif k == "CFrame" then
						local l = j :: CFrame
						local m, n = l:ToAxisAngle()
						return { l.X, l.Y, l.Z, m.X, m.Y, m.Z, n }
					elseif k == "Color3" then
						local l = j :: Color3
						local m = h.fromSRGB(l)
						return { m.X, m.Y, m.Z }
					elseif k == "ColorSequenceKeypoint" then
						local l = j :: ColorSequenceKeypoint
						local m = h.fromSRGB(l.Value)
						return { m.X, m.Y, m.Z, l.Time }
					elseif k == "DateTime" then
						local l = j :: DateTime
						return { l.UnixTimestampMillis }
					elseif k == "NumberRange" then
						local l = j :: NumberRange
						return { l.Min, l.Max }
					elseif k == "NumberSequenceKeypoint" then
						local l = j :: NumberSequenceKeypoint
						return { l.Value, l.Time, l.Envelope }
					elseif k == "PhysicalProperties" then
						local l = j :: PhysicalProperties
						return {
							l.Density,
							l.Friction,
							l.Elasticity,
							l.FrictionWeight,
							l.ElasticityWeight,
						}
					elseif k == "Ray" then
						local l = j :: Ray
						return {
							l.Origin.X,
							l.Origin.Y,
							l.Origin.Z,
							l.Direction.X,
							l.Direction.Y,
							l.Direction.Z,
						}
					elseif k == "Rect" then
						local l = j :: Rect
						return { l.Min.X, l.Min.Y, l.Max.X, l.Max.Y }
					elseif k == "Region3" then
						local l = j :: Region3
						return { l.CFrame.X, l.CFrame.Y, l.CFrame.Z, l.Size.X, l.Size.Y, l.Size.Z }
					elseif k == "Region3int16" then
						local l = j :: Region3int16
						return { l.Min.X, l.Min.Y, l.Min.Z, l.Max.X, l.Max.Y, l.Max.Z }
					elseif k == "UDim" then
						local l = j :: UDim
						return { l.Scale, l.Offset }
					elseif k == "UDim2" then
						local l = j :: UDim2
						return { l.X.Scale, l.X.Offset, l.Y.Scale, l.Y.Offset }
					elseif k == "Vector2" then
						local l = j :: Vector2
						return { l.X, l.Y }
					elseif k == "Vector2int16" then
						local l = j :: Vector2int16
						return { l.X, l.Y }
					elseif k == "Vector3" then
						local l = j :: Vector3
						return { l.X, l.Y, l.Z }
					elseif k == "Vector3int16" then
						local l = j :: Vector3int16
						return { l.X, l.Y, l.Z }
					else
						return {}
					end
				end
				return i
			end)()
		end,
		[14] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(14)
			local e
			return (function(...)
				local f, g, h = d(c.Parent.sRGB), {}
				function g.fromLinear(i: Color3): Vector3
					local j, k, l =
						i.R * 0.4122214708 + i.G * 0.5363325363 + i.B * 0.0514459929,
						i.R * 0.2119034982 + i.G * 0.6806995451 + i.B * 0.1073969566,
						i.R * 0.0883024619 + i.G * 0.2817188376 + i.B * 0.6299787005
					local m, n, o =
						j ^ 0.3333333333333333,
						k ^ 0.3333333333333333,
						l ^ 0.3333333333333333
					return Vector3.new(
						m * 0.2104542553 + n * 0.793617785 - o * 0.0040720468,
						m * 1.9779984951 - n * 2.428592205 + o * 0.4505937099,
						m * 0.0259040371 + n * 0.7827717662 - o * 0.808675766
					)
				end
				function g.fromSRGB(i: Color3): Vector3
					return g.fromLinear(f.toLinear(i))
				end
				function g.toLinear(i: Vector3, j: boolean?): Color3
					local k, l, m =
						i.X + i.Y * 0.3963377774 + i.Z * 0.2158037573,
						i.X - i.Y * 0.1055613458 - i.Z * 0.0638541728,
						i.X - i.Y * 0.0894841775 - i.Z * 1.291485548
					local n, o, p = k ^ 3, l ^ 3, m ^ 3
					local q, r, s =
						n * 4.0767416621 - o * 3.3077115913 + p * 0.2309699292,
						n * -1.2684380046 + o * 2.6097574011 - p * 0.3413193965,
						n * -4.1960863E-3 - o * 0.7034186147 + p * 1.707614701
					if not j then
						q = math.clamp(q, 0, 1)
						r = math.clamp(r, 0, 1)
						s = math.clamp(s, 0, 1)
					end
					return Color3.new(q, r, s)
				end
				function g.toSRGB(i: Vector3, j: boolean?): Color3
					return f.fromLinear(g.toLinear(i, j))
				end
				return g
			end)()
		end,
		[15] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(15)
			local e
			return (function(...)
				local f, g = {}
				local function h(i: number): number
					if i < 0.04045 then
						return i / 12.92
					end
					return ((i + 0.055) / 1.055) ^ 2.4
				end
				local function i(j: number): number
					if j < 0.0031308 then
						return 12.92 * j
					end
					return (1.055 * j ^ 0.4166666666666667) - 0.055
				end
				function f.fromLinear(j: Color3): Color3
					return Color3.new(i(j.R), i(j.G), i(j.B))
				end
				function f.toLinear(j: Color3): Color3
					return Color3.new(h(j.R), h(j.G), h(j.B))
				end
				return f
			end)()
		end,
		[16] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(16)
			local e
			return (function(...)
				local f, g = c.Parent
				local h, i, j, k =
					d(f.Logging.formatError),
					d(f.Types),
					"https://elttob.uk/Fusion/0.3/api-reference/general/errors/#",
					{}
				k.safetyTimerMultiplier = 1
				local l, m, n: i.ExternalProvider? = {}, 0
				function k.setExternalProvider(o: i.ExternalProvider?): i.ExternalProvider?
					local p = n
					if p ~= nil then
						p.stopScheduler()
					end
					n = o
					if o ~= nil then
						o.startScheduler()
					end
					return p
				end
				function k.stopUpdateStep(): () -> ()
					local p = n
					if p == nil then
						return function()
						end
					end
					p.stopScheduler()
					return function()
						if n == p then
							p.startScheduler()
						end
					end
				end
				function k.doTaskImmediate(o: () -> ())
					if n == nil then
						k.logError("noTaskScheduler")
					else
						n.doTaskImmediate(o)
					end
				end
				function k.doTaskDeferred(o: () -> ())
					if n == nil then
						k.logError("noTaskScheduler")
					else
						n.doTaskDeferred(o)
					end
				end
				function k.logError(o: string, p: i.Error?, ...: unknown): never
					error(h(n, o, p, ...), 0)
				end
				function k.logErrorNonFatal(o: string, p: i.Error?, ...: unknown): ()
					local q = h(n, o, p, ...)
					if n ~= nil then
						n.logErrorNonFatal(q)
					else
						print(q)
					end
				end
				function k.logWarn(o: string, ...: unknown): ()
					local p = h(n, o, debug.traceback(nil, 2), ...)
					if n ~= nil then
						n.logWarn(p)
					else
						print(p)
					end
				end
				function k.bindToUpdateStep(o: (now: number) -> ()): () -> ()
					local p = {}
					l[p] = o
					return function()
						l[p] = nil
					end
				end
				function k.performUpdateStep(o: number)
					m = o
					for p, q in l do
						q(o)
					end
				end
				function k.lastUpdateStep()
					return m
				end
				return k
			end)()
		end,
		[17] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(17)
			local e
			return (function(...)
				local f, g = c.Parent
				local h, i, j, k: Types.ExternalDebugger? = d(f.Types), 0, {}
				function j.setDebugger(l: h.ExternalDebugger?): h.ExternalDebugger?
					local m = k
					if m ~= nil then
						m.stopDebugging()
					end
					k = l
					if l ~= nil then
						l.startDebugging()
					end
					return m
				end
				function j.trackScope(l: h.Scope<unknown>): ()
					if k == nil then
						return
					end
					k.trackScope(l)
				end
				function j.untrackScope(l: h.Scope<unknown>): ()
					if k == nil then
						return
					end
					k.trackScope(l)
				end
				return j
			end)()
		end,
		[19] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(19)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n =
					d(f.Types),
					d(f.External),
					d(f.Memory.checkLifetime),
					d(f.Graph.castToGraph),
					d(f.Graph.depend),
					d(f.Graph.evaluate),
					d(f.Utility.nicknames)
				type Self = h.Observer & {
					_watchingGraph: h.GraphObject?,
					_changeListeners: { [unknown]: () -> () },
				}
				local o = {}
				o.type = "Observer"
				o.timeliness = "eager"
				o.dependentSet = table.freeze({})
				local p = table.freeze({ __index = o })
				local function q(r: h.Scope<unknown>, s: unknown): h.Observer
					local t = os.clock()
					local u: Self = setmetatable(
						{
							scope = r,
							createdAt = t,
							dependencySet = {},
							lastChange = nil,
							validity = "invalid",
							_watchingGraph = k(s),
							_changeListeners = {},
						},
						p
					) :: any
					local v = function()
						u.scope = nil
						for v in pairs(u.dependencySet) do
							v.dependentSet[u] = nil
						end
					end
					u.oldestTask = v
					n[u.oldestTask] = "Observer"
					table.insert(r, v)
					if u._watchingGraph ~= nil then
						j.bOutlivesA(
							r,
							u.oldestTask,
							u._watchingGraph.scope,
							u._watchingGraph.oldestTask,
							j.formatters.observer
						)
					end
					m(u, true)
					return u
				end
				function o.onBind(r: Self, s: () -> ()): () -> ()
					i.doTaskImmediate(s)
					return r:onChange(s)
				end
				function o.onChange(r: Self, s: () -> ()): () -> ()
					local t = table.freeze({})
					r._changeListeners[t] = s
					return function()
						r._changeListeners[t] = nil
					end
				end
				function o._evaluate(r: Self): ()
					if r._watchingGraph ~= nil then
						l(r, r._watchingGraph)
					end
					for s, t in r._changeListeners do
						i.doTaskImmediate(t)
					end
					return true
				end
				table.freeze(o)
				return q :: h.ObserverConstructor
			end)()
		end,
		[20] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(20)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Types)
				local function i(j: any): h.GraphObject?
					if typeof(j) == "table"
						and typeof(j.validity) == "string"
						and typeof(j.timeliness) == "string"
						and typeof(j.dependencySet) == "table"
						and typeof(j.dependentSet) == "table" then
						return j
					else
						return nil
					end
				end
				return i
			end)()
		end,
		[21] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(21)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k = d(f.Types), d(f.External), d(f.Graph.evaluate), 1
				local function l(m: h.GraphObject): ()
					if m.validity == "busy" then
						return i.logError("infiniteLoop")
					end
					local n = j(m, true)
					if not n then
						return
					end
					local o: { h.GraphObject }, p: { h.GraphObject }, q: { h.GraphObject } =
						{},
						{},
						{}
					o[1] = m
					local r = os.clock() + k * i.safetyTimerMultiplier
					repeat
						if os.clock() > r then
							return i.logError("infiniteLoop")
						end
						local s = true
						for t, u in o do
							for v in u.dependentSet do
								if v.validity == "valid" then
									s = false
									table.insert(q, v)
									table.insert(p, v)
								end
							end
						end
						o, p = p, o
						table.clear(p)
					until s
					local s: { h.GraphObject } = {}
					for t, u in q do
						u.validity = "invalid"
						if u.timeliness == "eager" then
							table.insert(s, u)
						end
					end
					table.sort(
						s,
						function(t, u)
							return t.createdAt < u.createdAt
						end
					)
					for t, u in s do
						j(u, false)
					end
				end
				return l
			end)()
		end,
		[22] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(22)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m =
					d(f.Types),
					d(f.External),
					d(f.Graph.evaluate),
					d(f.Graph.castToGraph),
					d(f.State.castToState),
					d(f.Utility.nameOf)
				local n = function<T>(n: h.GraphObject, o: h.UsedAs<T> | h.GraphObject): any
					if k(o) then
						local p = o :: h.GraphObject
						j(p, false)
						if table.isfrozen(n.dependencySet) or table.isfrozen(p.dependentSet) then
							i.logError("cannotDepend", nil, m(n, "Dependent"), m(p, "dependency"))
						end
						p.dependentSet[n] = true
						n.dependencySet[p] = true
						if l(p) then
							return (p :: h.StateObject<T>)._EXTREMELY_DANGEROUS_usedAsValue :: T
						else
							return nil
						end
					end
					return o :: T
				end :: (<T>(h.GraphObject, h.UsedAs<T>) -> T) & ((h.GraphObject, h.GraphObject) -> ())
				return n
			end)()
		end,
		[23] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(23)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i = d(f.Types), d(f.External)
				local function j(k: h.GraphObject, l: boolean): boolean
					if k.validity == "busy" then
						return i.logError("infiniteLoop")
					end
					local m, n = k.lastChange == nil, k.validity == "invalid"
					if m or n or l then
						local o = m or l
						if not o then
							for p in k.dependencySet do
								j(p, false)
								if p.lastChange > k.lastChange then
									o = true
									break
								end
							end
						end
						local p = false
						if o then
							for q in k.dependencySet do
								q.dependentSet[k] = nil
								k.dependencySet[q] = nil
							end
							k.validity = "busy"
							p = k:_evaluate() or m
						end
						if p then
							k.lastChange = os.clock()
						end
						k.validity = "valid"
						return p
					else
						return false
					end
				end
				return j
			end)()
		end,
		[25] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(25)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m: { [string]: Types.SpecialKey } =
					d(f.Types),
					d(f.Memory.checkLifetime),
					d(f.Graph.Observer),
					d(f.State.castToState),
					d(f.State.peek),
					{}
				local function n(o: string): h.SpecialKey
					local p = m[o]
					if p == nil then
						p = {
							type = "SpecialKey",
							kind = "Attribute",
							stage = "self",
							apply = function(
								q: h.SpecialKey,
								r: h.Scope<unknown>,
								s: unknown,
								t: Instance
							)
								if k(s) then
									local u = s :: h.StateObject<unknown>
									i.bOutlivesA(
										r,
										t,
										u.scope,
										u.oldestTask,
										i.formatters.boundAttribute,
										o
									)
									j(r, u :: any):onBind(function()
										t:SetAttribute(o, l(u))
									end)
								else
									t:SetAttribute(o, s)
								end
							end,
						}
						m[o] = p
					end
					return p
				end
				return n
			end)()
		end,
		[26] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(26)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j: { [string]: Types.SpecialKey } = d(f.Types), d(f.External), {}
				local function k(l: string): h.SpecialKey
					local m = j[l]
					if m == nil then
						m = {
							type = "SpecialKey",
							kind = "AttributeChange",
							stage = "observer",
							apply = function(
								n: h.SpecialKey,
								o: h.Scope<unknown>,
								p: unknown,
								q: Instance
							)
								if typeof(p) ~= "function" then
									i.logError("invalidAttributeChangeHandler", nil, l)
								end
								local r, s =
									p :: (...unknown) -> ...unknown,
									q:GetAttributeChangedSignal(l)
								table.insert(
									o,
									s:Connect(function()
										r((q :: any):GetAttribute(l))
									end)
								)
							end,
						}
						j[l] = m
					end
					return m
				end
				return k
			end)()
		end,
		[27] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(27)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l: { [string]: Types.SpecialKey } =
					d(f.Types),
					d(f.External),
					d(f.Memory.checkLifetime),
					d(f.State.castToState),
					{}
				local function m(n: string): h.SpecialKey
					local o = l[n]
					if o == nil then
						o = {
							type = "SpecialKey",
							kind = "AttributeOut",
							stage = "observer",
							apply = function(
								p: h.SpecialKey,
								q: h.Scope<unknown>,
								r: unknown,
								s: Instance
							)
								local t = s:GetAttributeChangedSignal(n)
								if not k(r) then
									i.logError("invalidAttributeOutType")
								end
								local u = r :: h.StateObject<unknown>
								if u.kind ~= "Value" then
									i.logError("invalidAttributeOutType")
								end
								local v = u :: h.Value<unknown>
								j.bOutlivesA(
									q,
									s,
									v.scope,
									v.oldestTask,
									j.formatters.attributeOutputsTo,
									n
								)
								v:set((s :: any):GetAttribute(n))
								table.insert(
									q,
									t:Connect(function()
										v:set((s :: any):GetAttribute(n))
									end)
								)
							end,
						}
						l[n] = o
					end
					return o
				end
				return m
			end)()
		end,
		[28] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(28)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Types)
				local function i(j: { h.Child }): h.Child
					return j
				end
				return i
			end)()
		end,
		[29] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(29)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m =
					d(f.Types),
					d(f.External),
					d(f.Graph.Observer),
					d(f.State.peek),
					d(f.State.castToState),
					d(f.Memory.doCleanup)
				type Set<T> = { [T]: unknown }
				local n = false
				return {
					type = "SpecialKey",
					kind = "Children",
					stage = "descendants",
					apply = function(o: h.SpecialKey, p: h.Scope<unknown>, q: unknown, r: Instance)
						local s: Set<Instance>, t: Set<Instance>, v: { [h.StateObject<unknown>]: h.Scope<unknown> }, w: { [h.StateObject<unknown>]: h.Scope<unknown> } =
							{},
							{},
							{},
							{}
						local function x()
							t, s = s, t
							w, v = v, w
							local function y(z: unknown, A: string?)
								local B = typeof(z)
								if B == "Instance" then
									local C = z :: Instance
									s[C] = true
									if t[C] == nil then
										C.Parent = r
									else
										t[C] = nil
									end
									if n and A ~= nil then
										C.Name = A
									end
								elseif l(z) then
									local C = z :: h.StateObject<unknown>
									local D = k(C)
									if D ~= nil then
										y(D, A)
									end
									local E = w[C]
									if E == nil then
										E = {}
										j(E, C):onChange(x)
									else
										w[C] = nil
									end
									v[C] = E
								elseif B == "table" then
									local C = z :: { [unknown]: unknown }
									for D, E in pairs(C) do
										local F, G: string? = (typeof(D))
										if F == "string" then
											local H = D :: string
											G = H
										elseif F == "number" and A ~= nil then
											local H = D :: number
											G = A .. "_" .. H
										end
										y(E, G)
									end
								else
									i.logWarn("unrecognisedChildType", B)
								end
							end
							if q ~= nil then
								y(q)
							end
							for z in pairs(t) do
								z.Parent = nil
							end
							table.clear(t)
							for z, A in pairs(w) do
								m(A)
							end
							table.clear(w)
						end
						table.insert(
							p,
							function()
								q = nil
								x()
							end
						)
						x()
					end,
				} :: h.SpecialKey
			end)()
		end,
		[30] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(30)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i = d(f.Types), d(f.Instances.applyInstanceProps)
				local function j(k: h.Scope<unknown>, l: Instance)
					return function(m: h.PropertyTable): Instance
						table.insert(k, l)
						i(k, m, l)
						return l
					end
				end
				return j
			end)()
		end,
		[31] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(31)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k =
					d(f.Types),
					d(f.External),
					d(f.Instances.defaultProps),
					d(f.Instances.applyInstanceProps)
				type Component = (h.PropertyTable) -> Instance
				local function l(m: h.Scope<unknown>, n: string)
					return function(o: h.PropertyTable): Instance
						local p, q = pcall(Instance.new, n)
						if not p then
							i.logError("cannotCreateClass", nil, n)
						end
						local r = j[n]
						if r ~= nil then
							for s, t in pairs(r) do
								(q :: any)[s] = t
							end
						end
						table.insert(m, q)
						k(m, o, q)
						return q
					end
				end
				return l
			end)()
		end,
		[32] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(32)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j: { [string]: Types.SpecialKey } = d(f.Types), d(f.External), {}
				local function k(l: string): h.SpecialKey
					local m = j[l]
					if m == nil then
						m = {
							type = "SpecialKey",
							kind = "OnChange",
							stage = "observer",
							apply = function(
								n: h.SpecialKey,
								o: h.Scope<unknown>,
								p: unknown,
								q: Instance
							)
								local r, s = pcall(q.GetPropertyChangedSignal, q, l)
								if not r then
									i.logError("cannotConnectChange", nil, q.ClassName, l)
								elseif typeof(p) ~= "function" then
									i.logError("invalidChangeHandler", nil, l)
								else
									local t = p :: (...unknown) -> ...unknown
									table.insert(
										o,
										s:Connect(function()
											t((q :: any)[l])
										end)
									)
								end
							end,
						}
						j[l] = m
					end
					return m
				end
				return k
			end)()
		end,
		[33] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(33)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j: { [string]: Types.SpecialKey } = d(f.Types), d(f.External), {}
				local function k(l: Instance, m: string)
					return (l :: any)[m]
				end
				local function l(m: string): h.SpecialKey
					local n = j[m]
					if n == nil then
						n = {
							type = "SpecialKey",
							kind = "OnEvent",
							stage = "observer",
							apply = function(
								o: h.SpecialKey,
								p: h.Scope<unknown>,
								q: unknown,
								r: Instance
							)
								local s, t = pcall(k, r, m)
								if not s or typeof(t) ~= "RBXScriptSignal" then
									i.logError("cannotConnectEvent", nil, r.ClassName, m)
								elseif typeof(q) ~= "function" then
									i.logError("invalidEventHandler", nil, m)
								else
									table.insert(p, t:Connect(q :: any))
								end
							end,
						}
						j[m] = n
					end
					return n
				end
				return l
			end)()
		end,
		[34] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(34)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l: { [string]: Types.SpecialKey } =
					d(f.Types),
					d(f.External),
					d(f.Memory.checkLifetime),
					d(f.State.castToState),
					{}
				local function m(n: string): h.SpecialKey
					local o = l[n]
					if o == nil then
						o = {
							type = "SpecialKey",
							kind = "Out",
							stage = "observer",
							apply = function(
								p: h.SpecialKey,
								q: h.Scope<unknown>,
								r: unknown,
								s: Instance
							)
								local t, v = pcall(s.GetPropertyChangedSignal, s, n)
								if not t then
									i.logError("invalidOutProperty", nil, s.ClassName, n)
								end
								if not k(r) then
									i.logError("invalidOutType")
								end
								local w = r :: h.StateObject<unknown>
								if w.kind ~= "Value" then
									i.logError("invalidOutType")
								end
								local x = w :: h.Value<unknown>
								j.bOutlivesA(
									q,
									s,
									x.scope,
									x.oldestTask,
									j.formatters.propertyOutputsTo,
									n
								)
								x:set((s :: any)[n])
								table.insert(
									q,
									v:Connect(function()
										x:set((s :: any)[n])
									end)
								)
							end,
						}
						l[n] = o
					end
					return o
				end
				return m
			end)()
		end,
		[35] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(35)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m: { [string]: Types.SpecialKey } =
					d(f.Types),
					d(f.Memory.checkLifetime),
					d(f.Graph.Observer),
					d(f.State.castToState),
					d(f.State.peek),
					{}
				local function n(o: string): h.SpecialKey
					local p = m[o]
					if p == nil then
						p = {
							type = "SpecialKey",
							kind = "Tag",
							stage = "self",
							apply = function(
								q: h.SpecialKey,
								r: h.Scope<unknown>,
								s: unknown,
								t: Instance
							)
								if k(s) then
									local v = s :: h.StateObject<unknown>
									i.bOutlivesA(
										r,
										t,
										v.scope,
										v.oldestTask,
										i.formatters.boundTag,
										o
									)
									j(r, v :: any):onBind(function()
										if l(v) == true then
											t:AddTag(o)
										elseif t:HasTag(o) then
											t:RemoveTag(o)
										end
									end)
								else
									if s == true then
										t:AddTag(o)
									end
								end
							end,
						}
						m[o] = p
					end
					return p
				end
				return n
			end)()
		end,
		[36] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(36)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n, o =
					d(f.Types),
					d(f.External),
					d(f.Logging.parseError),
					d(f.Memory.checkLifetime),
					d(f.Graph.Observer),
					d(f.State.castToState),
					d(f.State.peek),
					d(f.Utility.xtypeof)
				local function p(q: Instance, r: string, s: unknown)
					(q :: any)[r] = s
				end
				local function q(r: Instance, s: string)
					(r :: any)[s] = (r :: any)[s]
				end
				local function r(s: Instance, t: string, v: unknown)
					local x, y = xpcall(p :: any, j, s, t, v)
					if not x then
						if not pcall(q, s, t) then
							i.logErrorNonFatal("cannotAssignProperty", nil, s.ClassName, t)
						else
							local z, A = typeof(v), typeof((s :: any)[t])
							if z == A then
								i.logErrorNonFatal("propertySetError", y)
							else
								i.logErrorNonFatal("invalidPropertyType", nil, s.ClassName, t, A, z)
							end
						end
					end
				end
				local function s(t: h.Scope<unknown>, v: Instance, x: string, y: h.UsedAs<unknown>)
					if m(y) then
						local z = y :: h.StateObject<unknown>
						k.bOutlivesA(t, v, z.scope, z.oldestTask, k.formatters.boundProperty, x)
						l(t, z :: any):onBind(function()
							r(v, x, n(z))
						end)
					else
						r(v, x, y)
					end
				end
				local function t(v: h.Scope<unknown>, x: h.PropertyTable, y: Instance)
					local z = {
						self = {} :: { [h.SpecialKey]: unknown },
						descendants = {} :: { [h.SpecialKey]: unknown },
						ancestor = {} :: { [h.SpecialKey]: unknown },
						observer = {} :: { [h.SpecialKey]: unknown },
					}
					for A, B in pairs(x) do
						local C = o(A)
						if C == "string" then
							if A ~= "Parent" then
								s(v, y, A :: string, B)
							end
						elseif C == "SpecialKey" then
							local D = (A :: h.SpecialKey).stage
							local E = z[D]
							if E == nil then
								i.logError("unrecognisedPropertyStage", nil, D)
							else
								E[A] = B
							end
						else
							i.logError("unrecognisedPropertyKey", nil, C)
						end
					end
					for A, B in pairs(z.self) do
						A:apply(v, B, y)
					end
					for A, B in pairs(z.descendants) do
						A:apply(v, B, y)
					end
					if x.Parent ~= nil then
						s(v, y, "Parent", x.Parent)
					end
					for A, B in pairs(z.ancestor) do
						A:apply(v, B, y)
					end
					for A, B in pairs(z.observer) do
						A:apply(v, B, y)
					end
				end
				return t
			end)()
		end,
		[37] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(37)
			local e
			return (function(...)
				local f
				return {
					ScreenGui = {
						ResetOnSpawn = false,
						ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					},
					BillboardGui = {
						ResetOnSpawn = false,
						ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
						Active = true,
					},
					SurfaceGui = {
						ResetOnSpawn = false,
						ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
						SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
						PixelsPerStud = 50,
					},
					Frame = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
					},
					ScrollingFrame = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
						ScrollBarImageColor3 = Color3.new(0, 0, 0),
					},
					TextLabel = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Color3.new(0, 0, 0),
						TextSize = 14,
					},
					TextButton = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
						AutoButtonColor = false,
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Color3.new(0, 0, 0),
						TextSize = 14,
					},
					TextBox = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
						ClearTextOnFocus = false,
						Font = Enum.Font.SourceSans,
						Text = "",
						TextColor3 = Color3.new(0, 0, 0),
						TextSize = 14,
					},
					ImageLabel = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
					},
					ImageButton = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
						AutoButtonColor = false,
					},
					ViewportFrame = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
					},
					VideoFrame = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
					},
					CanvasGroup = {
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 0,
					},
					SpawnLocation = { Duration = 0 },
					BoxHandleAdornment = { ZIndex = 0 },
					ConeHandleAdornment = { ZIndex = 0 },
					CylinderHandleAdornment = { ZIndex = 0 },
					ImageHandleAdornment = { ZIndex = 0 },
					LineHandleAdornment = { ZIndex = 0 },
					SphereHandleAdornment = { ZIndex = 0 },
					WireframeHandleAdornment = { ZIndex = 0 },
					Part = {
						Anchored = true,
						Size = Vector3.one,
						FrontSurface = Enum.SurfaceType.Smooth,
						BackSurface = Enum.SurfaceType.Smooth,
						LeftSurface = Enum.SurfaceType.Smooth,
						RightSurface = Enum.SurfaceType.Smooth,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
					},
					TrussPart = {
						Anchored = true,
						Size = Vector3.one * 2,
						FrontSurface = Enum.SurfaceType.Smooth,
						BackSurface = Enum.SurfaceType.Smooth,
						LeftSurface = Enum.SurfaceType.Smooth,
						RightSurface = Enum.SurfaceType.Smooth,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
					},
					MeshPart = {
						Anchored = true,
						Size = Vector3.one,
						FrontSurface = Enum.SurfaceType.Smooth,
						BackSurface = Enum.SurfaceType.Smooth,
						LeftSurface = Enum.SurfaceType.Smooth,
						RightSurface = Enum.SurfaceType.Smooth,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
					},
					CornerWedgePart = {
						Anchored = true,
						Size = Vector3.one,
						FrontSurface = Enum.SurfaceType.Smooth,
						BackSurface = Enum.SurfaceType.Smooth,
						LeftSurface = Enum.SurfaceType.Smooth,
						RightSurface = Enum.SurfaceType.Smooth,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
					},
					VehicleSeat = {
						Anchored = true,
						Size = Vector3.one,
						FrontSurface = Enum.SurfaceType.Smooth,
						BackSurface = Enum.SurfaceType.Smooth,
						LeftSurface = Enum.SurfaceType.Smooth,
						RightSurface = Enum.SurfaceType.Smooth,
						TopSurface = Enum.SurfaceType.Smooth,
						BottomSurface = Enum.SurfaceType.Smooth,
					},
				}
			end)()
		end,
		[39] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(39)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j =
					d(f.Types),
					d(f.Logging.messages),
					"https://elttob.uk/Fusion/0.3/api-reference/general/errors/#"
				local function k(
					l: h.ExternalProvider?,
					m: string,
					n: h.Error | string | nil,
					...: unknown
				): string
					local o, p: h.Error?, q: string?, r =
						m,
						if typeof(n) == "table" then n else nil,
						if typeof(n) == "table" then n.trace else n,
						i[m]
					if r == nil then
						m = "unknownMessage"
						r = i[m]
					end
					r = r:format(...)
					if p ~= nil then
						r = r:gsub("ERROR_MESSAGE", p.message)
						if p.context ~= nil then
							r ..= ` ({p.context})`
						end
					else
						r = r:gsub("ERROR_MESSAGE", o)
					end
					r = `[Fusion] {r} \nID: {m}`
					if l ~= nil and l.policies.allowWebLinks then
						r ..= `\nLearn more: {j}{m:lower()}`
					end
					if q ~= nil then
						r ..= ` \n---- Stack trace ----\n{q}`
					end
					return r:gsub("\n", "\n    ")
				end
				return k
			end)()
		end,
		[40] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(40)
			local e
			return (function(...)
				local f
				return {
					callbackError = "Error in callback:\nERROR_MESSAGE",
					cannotAssignProperty = "The class type '%s' has no assignable property '%s'.",
					cannotConnectChange = "The %s class doesn't have a property called '%s'.",
					cannotConnectEvent = "The %s class doesn't have an event called '%s'.",
					cannotCreateClass = "Can't create a new instance of class '%s'.",
					cannotDepend = "%s can't depend on %s.",
					destroyedTwice = [[`doCleanup()` was given something that it is already cleaning up. Unclear how to proceed.]],
					forKeyCollision = [[The key '%s' was returned multiple times simultaneously, which is not allowed in `For` objects.]],
					infiniteLoop = [[Detected an infinite loop. Consider adding an explicit breakpoint to your code to prevent a cyclic dependency.]],
					invalidAttributeChangeHandler = [[The change handler for the '%s' attribute must be a function.]],
					invalidAttributeOutType = "[AttributeOut] properties must be given Value objects.",
					invalidChangeHandler = [[The change handler for the '%s' property must be a function.]],
					invalidEventHandler = "The handler for the '%s' event must be a function.",
					invalidOutProperty = "The %s class doesn't have a property called '%s'.",
					invalidOutType = "[Out] properties must be given Value objects.",
					invalidPropertyType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
					invalidSpringDamping = [[The damping ratio for a spring must be >= 0. (damping was %.2f)]],
					invalidSpringSpeed = "The speed of a spring must be >= 0. (speed was %.2f)",
					mergeConflict = "Multiple definitions for '%s' found while merging.",
					mistypedSpringDamping = "The damping ratio for a spring must be a number. (got a %s)",
					mistypedSpringSpeed = "The speed of a spring must be a number. (got a %s)",
					mistypedTweenInfo = "The tween info of a tween must be a TweenInfo. (got a %s)",
					noTaskScheduler = "Fusion is not connected to an external task scheduler.",
					poisonedScope = "Attempted to use a scope after it's been destroyed; %s",
					propertySetError = "Error setting property:\nERROR_MESSAGE",
					springNanGoal = [[A spring was given a NaN goal, so some simulation has been skipped. Ensure no springs have NaN goals.]],
					springNanMotion = [[A spring encountered NaN during motion, so has snapped to the goal position. Ensure no springs have NaN positions or velocities.]],
					springTypeMismatch = "The type '%s' doesn't match the spring's type '%s'.",
					tweenNanGoal = [[A tween was given a NaN goal, so some animation has been skipped. Ensure no tweens have NaN goals.]],
					tweenNanMotion = [[A tween encountered NaN during motion, so has snapped to the goal. Ensure no tweens have NaN in their tween infos.]],
					unknownMessage = "Unknown error:\nERROR_MESSAGE",
					unrecognisedChildType = "'%s' type children aren't accepted by `[Children]`.",
					unrecognisedPropertyKey = "'%s' keys aren't accepted in property tables.",
					unrecognisedPropertyStage = [['%s' isn't a valid stage for a special key to be applied at.]],
					useAfterDestroy = [[%s is no longer valid - it was destroyed before %s. See discussion #292 on GitHub for advice.]],
				}
			end)()
		end,
		[41] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(41)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Types)
				local function i(j: string): h.Error
					return {
						type = "Error",
						raw = j,
						message = j:gsub("^.+:%d+:%s*", ""),
						trace = debug.traceback(nil, 2),
					}
				end
				return i
			end)()
		end,
		[43] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(43)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k = d(f.Types), d(f.External), d(f.Utility.nameOf), {}
				k.formatters = {}
				function k.formatters.useFunction(l: unknown, m: unknown): (string, string)
					local n, o = j(l, "object"), j(m, "object")
					return `The use()-d {o}`, `the {n}`
				end
				function k.formatters.boundProperty(l: Instance, m: unknown, n: string): (string, string)
					local o, p = l.Name, j(m, "value")
					return `The {p} (bound to the {n} property)`, `the {o} instance`
				end
				function k.formatters.boundAttribute(l: Instance, m: unknown, n: string): (string, string)
					local o, p = l.Name, j(m, "value")
					return `The {p} (bound to the {n} attribute)`, `the {o} instance`
				end
				function k.formatters.boundTag(l: Instance, m: unknown, n: string): (string, string)
					local o, p = l.Name, j(m, "value")
					return `The {p} (bound to the {n} CollectionService tag)`, `the {o} instance`
				end
				function k.formatters.propertyOutputsTo(l: Instance, m: unknown, n: string): (string, string)
					local o, p = l.Name, j(m, "object")
					return `The {p} (which the {n} property outputs to)`, `the {o} instance`
				end
				function k.formatters.attributeOutputsTo(l: Instance, m: unknown, n: string): (string, string)
					local o, p = l.Name, j(m, "object")
					return `The {p} (which the {n} attribute outputs to)`, `the {o} instance`
				end
				function k.formatters.refOutputsTo(l: Instance, m: unknown): (string, string)
					local n, o = l.Name, j(m, "object")
					return `The {o} (which the Ref key outputs to)`, `the {n} instance`
				end
				function k.formatters.animationGoal(l: unknown, m: unknown): (string, string)
					local n, o = j(l, "object"), j(m, "object")
					return `The goal {o}`, `the {n} that is following it`
				end
				function k.formatters.parameter(l: unknown, m: unknown, n: string | false): (string, string)
					local o, p = j(l, "object"), j(m, "object")
					if n == false then
						return `The {p} parameter`, `the {o} that it was used for`
					else
						return
							`The {p} representing the {n} parameter`,
							`the {o} that it was used for`
					end
				end
				function k.formatters.observer(l: unknown, m: unknown): (string, string)
					local n, o = j(l, "object"), j(m, "object")
					return `The watched {o}`, `the {n} that's observing it for changes`
				end
				function k.bOutlivesA<A, B, Args...>(
					l: h.Scope<unknown>,
					m: A,
					n: h.Scope<unknown>?,
					o: B,
					p: (a: A, b: B, Args...) -> (string, string),
					...: Args...
				)
					if n == nil then
						i.logError("useAfterDestroy", nil, p(m, o, ...))
					end
				end
				return k
			end)()
		end,
		[44] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(44)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j = d(f.Types), d(f.ExternalDebug), d(f.Memory.deriveScopeImpl)
				local function k(...)
					local l = j(...)
					i.trackScope(l)
					return l
				end
				return k :: h.DeriveScopeConstructor
			end)()
		end,
		[45] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(45)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i = d(f.Types), d(f.Utility.merge)
				local function j<T>(
					k: h.Scope<T>,
					l: { [unknown]: unknown }?,
					...: { [unknown]: unknown }
				): any
					local m = getmetatable(k)
					if l ~= nil then
						m = table.clone(m)
						m.__index = i(true, {}, m.__index, i(false, {}, l, ...))
					end
					return setmetatable({}, m)
				end
				return (j :: any) :: h.DeriveScopeConstructor
			end)()
		end,
		[46] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(46)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k: { [Types.Task]: true } =
					d(f.Types),
					d(f.External),
					d(f.ExternalDebug),
					{}
				local function l(m: h.Task): ()
					if k[m] then
						return i.logError("destroyedTwice")
					end
					k[m] = true
					local success, message = pcall(function()
						if typeof(m) == "Instance" then
							m:Destroy()
						elseif typeof(m) == "RBXScriptConnection" then
							m:Disconnect()
						elseif typeof(m) == "function" then
							m()
						elseif typeof(m) == "table" then
							local n = (m :: any) :: {
								Destroy: (...unknown) -> unknown?,
								destroy: (...unknown) -> unknown?,
							}
							if typeof(n.destroy) == "function" then
								local o = (n :: any) :: { destroy: (...unknown) -> ...unknown }
								o:destroy()
							elseif typeof(n.Destroy) == "function" then
								local o = (n :: any) :: { Destroy: (...unknown) -> ...unknown }
								o:Destroy()
							elseif n[1] ~= nil then
								local o = n :: { h.Task }
								for p = #o, 1, -1 do
									l(o[p])
									o[p] = nil
								end
								j.untrackScope(o)
							end
						end
					end)
					k[m] = nil
					if not success then
						error(message, 0)
					end
				end
				return l
			end)()
		end,
		[47] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(47)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j = d(f.Types), d(f.ExternalDebug), d(f.Memory.deriveScopeImpl)
				local function k<T>(l: h.Scope<T>, ...: { [unknown]: unknown }): any
					local m = j(l, ...)
					table.insert(l, m)
					table.insert(
						m,
						function()
							local n = table.find(l, m)
							if n ~= nil then
								table.remove(l, n)
							end
						end
					)
					i.trackScope(m)
					return m
				end
				return (k :: any) :: h.DeriveScopeConstructor
			end)()
		end,
		[48] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(48)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Types)
				local function i<Tasks...>(j: h.Scope<unknown>, ...: Tasks...): Tasks...
					for k = 1, select("#", ...) do
						table.insert(j, select(k, ...))
					end
					return ...
				end
				return i
			end)()
		end,
		[49] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(49)
			local e
			return (function(...)
				local f
				local function g(h: unknown): boolean
					return typeof(h) == "Instance"
				end
				return g
			end)()
		end,
		[50] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(50)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j = d(f.Types), d(f.ExternalDebug), d(f.Utility.merge)
				local function k(...: { [unknown]: unknown }): any
					local l = { __index = j(false, {}, ...) }
					local m = setmetatable({}, l) :: any
					i.trackScope(m)
					return m
				end
				return (k :: any) :: h.ScopedConstructor
			end)()
		end,
		[51] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(51)
			local e
			return (function(...)
				local f, g, h = services.RunService, services.HttpService, c.Parent
				local i, j = d(h.External), {}
				j.policies = { allowWebLinks = f:IsStudio() }
				function j.doTaskImmediate(k: () -> ())
					task.spawn(k)
				end
				function j.doTaskDeferred(k: () -> ())
					task.defer(k)
				end
				function j.logErrorNonFatal(k: string)
					task.spawn(error, k, 0)
				end
				j.logWarn = warn
				local function k()
					i.performUpdateStep(os.clock())
				end
				local l = nil :: (() -> ())?
				function j.startScheduler()
					if l ~= nil then
						return
					end
					if f:IsClient() then
						local m = "FusionUpdateStep_" .. g:GenerateGUID()
						f:BindToRenderStep(m, Enum.RenderPriority.First.Value, k)
						l = function()
							f:UnbindFromRenderStep(m)
						end
					else
						local m = f.Heartbeat:Connect(k)
						l = function()
							m:Disconnect()
						end
					end
				end
				function j.stopScheduler()
					if l ~= nil then
						l()
						l = nil
					end
				end
				return j
			end)()
		end,
		[53] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(53)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n, o, p, q, r =
					d(f.Types),
					d(f.External),
					d(f.Logging.parseError),
					d(f.Utility.isSimilar),
					d(f.Graph.depend),
					d(f.State.castToState),
					d(f.State.peek),
					d(f.Memory.doCleanup),
					d(f.Memory.deriveScope),
					d(f.Memory.checkLifetime),
					d(f.Utility.nicknames)
				type Self<T, S> = h.Computed<T> & {
					_innerScope: h.Scope<S>?,
					_processor: (h.Use, h.Scope<S>) -> T,
				}
				local s = {}
				s.type = "State"
				s.kind = "Computed"
				s.timeliness = "lazy"
				local t = table.freeze({
					__index = s,
				})
				local function v<T, S>(x: S & h.Scope<unknown>, y: (h.Use, S) -> T): h.Computed<T>
					local z = os.clock()
					local A: Self<T, S> = setmetatable(
						{
							createdAt = z,
							dependencySet = {},
							dependentSet = {},
							lastChange = nil,
							scope = x,
							validity = "invalid",
							_EXTREMELY_DANGEROUS_usedAsValue = nil,
							_innerScope = nil,
							_processor = y,
						},
						t
					) :: any
					local B = function()
						A.scope = nil
						for B in pairs(A.dependencySet) do
							B.dependentSet[A] = nil
						end
						if A._innerScope ~= nil then
							o(A._innerScope)
							A._innerScope = nil
						end
					end
					A.oldestTask = B
					r[A.oldestTask] = "Computed"
					table.insert(x, B)
					return A
				end
				function s._evaluate<T, S>(x: Self<T, S>): boolean
					if x.scope == nil then
						return false
					end
					local y = x.scope :: S & h.Scope<unknown>
					local z = p(y)
					local function A<T>(B: h.UsedAs<T>): T
						local C = m(B)
						if C ~= nil then
							q.bOutlivesA(
								y,
								x.oldestTask,
								C.scope,
								C.oldestTask,
								q.formatters.useFunction
							)
							l(x, C)
						end
						return n(B)
					end
					local B, C = xpcall(x._processor, j, A, z)
					if B then
						local D = k(x._EXTREMELY_DANGEROUS_usedAsValue, C)
						if x._innerScope ~= nil then
							o(x._innerScope)
							x._innerScope = nil
						end
						x._innerScope = z
						x._EXTREMELY_DANGEROUS_usedAsValue = C
						return not D
					else
						local D = (C :: any) :: h.Error
						o(z)
						i.logErrorNonFatal("callbackError", D)
						return false
					end
				end
				table.freeze(s)
				return v :: h.ComputedConstructor
			end)()
		end,
		[54] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(54)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n =
					d(f.Types),
					d(f.Graph.depend),
					d(f.State.peek),
					d(f.State.castToState),
					d(f.State.For.ForTypes),
					d(f.Utility.nicknames),
					d(f.State.For.Disassembly)
				type Self<S, KI, KO, VI, VO> = h.For<KO, VO> & { _disassembly: l.Disassembly<S, KI, KO, VI, VO> }
				local o = {}
				o.type = "State"
				o.kind = "For"
				o.timeliness = "lazy"
				local p = table.freeze({ __index = o })
				local function q<S, KI, KO, VI, VO>(
					r: h.Scope<S>,
					s: h.UsedAs<{ [KI]: VI }>,
					t: (h.Scope<S>, initialKey: KI, initialValue: VI) -> l.SubObject<S, KI, KO, VI, VO>
				): h.For<KO, VO>
					local v = os.clock()
					local x: Self<S, KI, KO, VI, VO> = setmetatable(
						{
							createdAt = v,
							dependencySet = {},
							dependentSet = {},
							scope = r,
							validity = "invalid",
							_EXTREMELY_DANGEROUS_usedAsValue = {},
							_disassembly = n(r, s, t),
						},
						p
					) :: any
					local y = function()
						x.scope = nil
						for y in pairs(x.dependencySet) do
							y.dependentSet[x] = nil
						end
					end
					x.oldestTask = y
					m[x.oldestTask] = "For"
					table.insert(r, y)
					return x
				end
				function o._evaluate<S, KI, KO, VI, VO>(r: Self<S, KI, KO, VI, VO>): boolean
					if r.scope == nil then
						return false
					end
					local s = r.scope :: S & h.Scope<unknown>
					i(r, r._disassembly)
					table.clear(r._EXTREMELY_DANGEROUS_usedAsValue)
					r._disassembly:populate(
						function<T>(t: h.UsedAs<T>): T
							local v = k(t)
							if v ~= nil then
								i(r, v)
							end
							return j(t)
						end,
						r._EXTREMELY_DANGEROUS_usedAsValue
					)
					return true
				end
				table.freeze(o)
				return q
			end)()
		end,
		[55] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(55)
			local e
			return (function(...)
				local f, g = c.Parent.Parent.Parent
				local h, i, j, k, l, m, n, o, p, q =
					d(f.Types),
					d(f.External),
					d(f.Graph.depend),
					d(f.State.peek),
					d(f.State.castToState),
					d(f.State.For.ForTypes),
					d(f.Memory.doCleanup),
					d(f.Memory.deriveScope),
					d(f.Utility.nameOf),
					d(f.Utility.nicknames)
				type Self<S, KI, KO, VI, VO> = m.Disassembly<S, KI, KO, VI, KO> & {
					scope: (S & h.Scope<unknown>)?,
					_inputTable: h.UsedAs<{ [KI]: VI }>,
					_constructor: (h.Scope<S>, initialKey: KI, initialValue: VI) -> m.SubObject<S, KI, KO, VI, VO>,
					_subObjects: { [m.SubObject<S, KI, KO, VI, VO>]: true },
				}
				local r = {}
				r.type = "Graph"
				r.kind = "For.Disassembly"
				r.timeliness = "lazy"
				local s = table.freeze({ __index = r })
				local function t<S, KI, KO, VI, VO>(
					v: S & h.Scope<unknown>,
					x: h.UsedAs<{ [KI]: VI }>,
					y: (h.Scope<S>, initialKey: KI, initialValue: VI) -> m.SubObject<S, KI, KO, VI, VO>
				): m.Disassembly<S, KI, KO, VI, KO>
					local z = os.clock()
					local A = setmetatable(
						{
							createdAt = z,
							dependencySet = {},
							dependentSet = {},
							scope = v,
							validity = "invalid",
							_inputTable = x,
							_constructor = y,
							_subObjects = {},
						},
						s
					) :: any
					local B = function()
						A.scope = nil
						for B in pairs(A.dependencySet) do
							B.dependentSet[A] = nil
						end
						for B in A._subObjects do
							if B.maybeScope ~= nil then
								n(B.maybeScope)
								B.maybeScope = nil
							end
						end
					end
					A.oldestTask = B
					q[A.oldestTask] = "For (internal disassembler)"
					table.insert(v, B)
					return A
				end
				function r.populate<S, KI, KO, VI, VO>(
					v: Self<S, KI, KO, VI, VO>,
					x: h.Use,
					y: { [KO]: VO }
				): ()
					local z, A, B = math.huge, -math.huge, false
					for C in v._subObjects do
						local D, E = C:useOutputPair(x)
						if D == nil or E == nil then
							B = true
							continue
						elseif y[D] ~= nil then
							i.logErrorNonFatal("forKeyCollision", nil, tostring(D))
							continue
						end
						y[D] = E
						if typeof(D) == "number" then
							z = math.min(z, D)
							A = math.max(A, D)
						end
					end
					if B and A > z then
						local C: { [number]: VO }, D = y :: any, z
						for E = z, A do
							local F = C[E]
							if F == nil then
								continue
							end
							C[E] = nil
							C[D] = F
							D += 1
						end
					end
				end
				function r._evaluate<S, KI, KO, VI, VO>(v: Self<S, KI, KO, VI, VO>): boolean
					local x, y = v.scope :: S & h.Scope<unknown>, l(v._inputTable)
					if y ~= nil then
						if y.scope == nil then
							i.logError(
								"useAfterDestroy",
								nil,
								`The input {p(y, "table")}`,
								`the For object that is watching it`
							)
						end
						j(v, y)
					end
					local z = {} :: { [KI]: VI }
					for A, B in k(v._inputTable) do
						z[A] = B
					end
					local A = {} :: typeof(v._subObjects)
					for B in v._subObjects do
						local C, D, E, F: KI = false, B.inputKey, B.inputValue
						if not B.roamKeys and z[D] ~= nil then
							C = true
							F = D
						else
							for G, H in z do
								C = true
								F = G
								if B.roamValues then
									break
								end
								if H == E then
									break
								end
							end
						end
						if C then
							local G = z[F]
							A[B] = true
							if F ~= D then
								B.inputKey = F
								B:invalidateInputKey()
							end
							if G ~= E then
								B.inputValue = G
								B:invalidateInputValue()
							end
							z[F] = nil
						else
							if B.maybeScope ~= nil then
								n(B.maybeScope)
								B.maybeScope = nil
							end
						end
					end
					for B, C in z do
						local D = v._constructor(o(x), B, C)
						A[D] = true
					end
					v._subObjects = A
					return true
				end
				table.freeze(r)
				return t
			end)()
		end,
		[56] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(56)
			local e
			return (function(...)
				local f, g = c.Parent.Parent.Parent
				local h = d(f.Types)
				export type SubObject<S, KI, KO, VI, VO> = {
					maybeScope: h.Scope<S>?,
					inputKey: KI,
					inputValue: VI,
					roamKeys: boolean,
					roamValues: boolean,
					invalidateInputKey: (SubObject<S, KI, KO, VI, VO>) -> (),
					invalidateInputValue: (SubObject<S, KI, KO, VI, VO>) -> (),
					useOutputPair: (SubObject<S, KI, KO, VI, VO>, h.Use) -> (KO?, VO?),
				}
				export type Disassembly<S, KI, KO, VI, VO> = h.GraphObject & {
					populate: (Disassembly<S, KI, KO, VI, VO>, h.Use, output: { [KO]: VO }) -> (),
				}
				return nil
			end)()
		end,
		[57] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(57)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n, o, p =
					d(f.Types),
					d(f.External),
					d(f.Memory.doCleanup),
					d(f.State.For),
					d(f.State.Value),
					d(f.State.Computed),
					d(f.State.For.ForTypes),
					d(f.Logging.parseError),
					{
						__index = {
							roamKeys = false,
							roamValues = true,
							invalidateInputKey = function(h): ()
								h._inputKeyState:set(h.inputKey)
							end,
							invalidateInputValue = function(h): ()
							end,
							useOutputPair = function(h, i)
								return i(h._outputKeyState), h.inputValue
							end,
						},
					}
				local function q<KI, KO, V, S>(
					r: h.Scope<S>,
					s: KI,
					t: V,
					v: (h.Use, h.Scope<S>, KI) -> KO
				): n.SubObject<S, KI, KO, V, V>
					local x = {}
					x.maybeScope = r
					x.inputKey = s
					x.inputValue = t
					x._inputKeyState = l(r, s)
					x._processor = v
					x._outputKeyState = m(
						r,
						function(y, z): KO?
							local A = y(x._inputKeyState)
							local B, C = xpcall(x._processor, o, y, z, A)
							if B then
								return C
							else
								local D: h.Error = C :: any
								D.context = `while processing key {tostring(A)}`
								i.logErrorNonFatal("callbackError", D)
								j(z)
								table.clear(z)
								return nil
							end
						end
					)
					return setmetatable(x, p) :: any
				end
				local function r<KI, KO, V, S>(
					s: h.Scope<S>,
					t: h.UsedAs<{ [KI]: V }>,
					v: (h.Use, h.Scope<S>, KI) -> KO
				): h.For<KO, V>
					return k(
						s,
						t,
						function(x, y, z)
							return q(x, y, z, v)
						end
					)
				end
				return r :: h.ForKeysConstructor
			end)()
		end,
		[58] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(58)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n, o, p =
					d(f.Types),
					d(f.External),
					d(f.State.For),
					d(f.State.Value),
					d(f.State.Computed),
					d(f.State.For.ForTypes),
					d(f.Logging.parseError),
					d(f.Memory.doCleanup),
					{
						__index = {
							roamKeys = false,
							roamValues = false,
							invalidateInputKey = function(h): ()
								h._inputKeyState:set(h.inputKey)
							end,
							invalidateInputValue = function(h): ()
								h._inputValueState:set(h.inputValue)
							end,
							useOutputPair = function(h, i)
								local j = i(h._outputPairState)
								return j.key, j.value
							end,
						},
					}
				local function q<KI, KO, VI, VO, S>(
					r: h.Scope<S>,
					s: KI,
					t: VI,
					v: (h.Use, h.Scope<S>, KI, VI) -> (KO, VO)
				): m.SubObject<S, KI, KO, VI, VO>
					local x = {}
					x.maybeScope = r
					x.inputKey = s
					x.inputValue = t
					x._inputKeyState = k(r, s)
					x._inputValueState = k(r, t)
					x._processor = v
					x._outputPairState = l(
						r,
						function(y, z): { key: KO?, value: VO? }
							local A, B = y(x._inputKeyState), y(x._inputValueState)
							local C, D, E = xpcall(x._processor, n, y, z, A, B)
							if C then
								return { key = D, value = E }
							else
								local F: h.Error = D :: any
								F.context = `while processing key {tostring(B)} and value {tostring(B)}`
								i.logErrorNonFatal("callbackError", F)
								o(z)
								table.clear(z)
								return { key = nil, value = nil }
							end
						end
					)
					return setmetatable(x, p) :: any
				end
				local function r<KI, KO, VI, VO, S>(
					s: h.Scope<S>,
					t: h.UsedAs<{ [KI]: VI }>,
					v: (h.Use, h.Scope<S>, KI, VI) -> (KO, VO)
				): h.For<KO, VO>
					return j(
						s,
						t,
						function(x, y, z)
							return q(x, y, z, v)
						end
					)
				end
				return r :: h.ForPairsConstructor
			end)()
		end,
		[59] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(59)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k, l, m, n, o, p =
					d(f.Types),
					d(f.External),
					d(f.State.For),
					d(f.State.Value),
					d(f.State.Computed),
					d(f.State.For.ForTypes),
					d(f.Logging.parseError),
					d(f.Memory.doCleanup),
					{
						__index = {
							roamKeys = true,
							roamValues = false,
							invalidateInputKey = function(h): ()
							end,
							invalidateInputValue = function(h): ()
								h._inputValueState:set(h.inputValue)
							end,
							useOutputPair = function(h, i)
								return h.inputKey, i(h._outputValueState)
							end,
						},
					}
				local function q<K, VI, VO, S>(
					r: h.Scope<S>,
					s: K,
					t: VI,
					v: (h.Use, h.Scope<S>, VI) -> VO
				): m.SubObject<S, K, K, VI, VO>
					local x = {}
					x.maybeScope = r
					x.inputKey = s
					x.inputValue = t
					x._inputValueState = k(r, t)
					x._processor = v
					x._outputValueState = l(
						r,
						function(y, z): VO?
							local A = y(x._inputValueState)
							local B, C = xpcall(x._processor, n, y, z, A)
							if B then
								return C
							else
								local D: h.Error = C :: any
								D.context = `while processing value {tostring(A)}`
								i.logErrorNonFatal("callbackError", D)
								o(z)
								table.clear(z)
								return nil
							end
						end
					)
					return setmetatable(x, p) :: any
				end
				local function r<K, VI, VO, S>(
					s: h.Scope<S>,
					t: h.UsedAs<{ [K]: VI }>,
					v: (h.Use, h.Scope<S>, VI) -> VO
				): h.For<K, VO>
					return j(
						s,
						t,
						function(x, y, z)
							return q(x, y, z, v)
						end
					)
				end
				return r :: h.ForValuesConstructor
			end)()
		end,
		[60] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(60)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j, k =
					d(f.Types),
					d(f.Graph.change),
					d(f.Utility.isSimilar),
					d(f.Utility.nicknames)
				type Self<T, S> = h.Value<T, S>
				local l = {}
				l.type = "State"
				l.kind = "Value"
				l.timeliness = "lazy"
				l.dependencySet = table.freeze({})
				local m = table.freeze({ __index = l })
				local function n<T>(o: h.Scope<unknown>, p: T): h.Value<T, any>
					local q = os.clock()
					local r: Self<T, any> = setmetatable(
						{
							createdAt = q,
							dependentSet = {},
							lastChange = os.clock(),
							scope = o,
							validity = "valid",
							_EXTREMELY_DANGEROUS_usedAsValue = p,
						},
						m
					) :: any
					local s = function()
						r.scope = nil
					end
					r.oldestTask = s
					k[r.oldestTask] = "Value"
					table.insert(o, s)
					return r
				end
				function l.set<T, S>(o: Self<T, S>, p: S): S
					local q = o._EXTREMELY_DANGEROUS_usedAsValue
					if not j(q, p) then
						o._EXTREMELY_DANGEROUS_usedAsValue = p :: any
						i(o)
					end
					return p
				end
				function l._evaluate<T, S>(o: Self<T, S>): boolean
					return true
				end
				table.freeze(l)
				return n :: h.ValueConstructor
			end)()
		end,
		[61] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(61)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Types)
				local function i<T>(j: h.UsedAs<T>): h.StateObject<T>?
					if typeof(j) == "table" and j.type == "State" then
						return j
					else
						return nil
					end
				end
				return i
			end)()
		end,
		[62] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(62)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j = d(f.Types), d(f.State.castToState), d(f.Graph.evaluate)
				local function k<T>(l: h.UsedAs<T>): T
					local m = i(l)
					if m ~= nil then
						j(m, false)
						return m._EXTREMELY_DANGEROUS_usedAsValue :: T
					else
						return l :: T
					end
				end
				return k
			end)()
		end,
		[63] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(63)
			local e
			return (function(...)
				return nil
			end)()
		end,
		[64] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(64)
			local e
			return (function(...)
				local f
				export type Error = {
					type: "Error",
					raw: string,
					message: string,
					trace: string,
					context: string?,
				}
				export type Animatable = number | CFrame | Color3 | ColorSequenceKeypoint | DateTime | NumberRange | NumberSequenceKeypoint | PhysicalProperties | Ray | Rect | Region3 | Region3int16 | UDim | UDim2 | Vector2 | Vector2int16 | Vector3 | Vector3int16
				export type Task = Instance | RBXScriptConnection | (() -> ()) | { destroy: (unknown) -> () } | { Destroy: (unknown) -> () } | { Task }
				export type Scope<Constructors = any> = { Task } & Constructors
				export type ScopedObject = { scope: Scope<unknown>?, oldestTask: unknown }
				export type Version = { major: number, minor: number, isRelease: boolean }
				export type Contextual<T> = {
					type: "Contextual",
					now: (Contextual<T>) -> T,
					is: (Contextual<T>, T) -> ContextualIsMethods,
				}
				type ContextualIsMethods = {
					during: <R, A...>(ContextualIsMethods, (A...) -> R, A...) -> R,
				}
				export type GraphObject = ScopedObject & {
					createdAt: number,
					dependencySet: { [GraphObject]: unknown },
					dependentSet: { [GraphObject]: unknown },
					lastChange: number?,
					timeliness: "lazy" | "eager",
					validity: "valid" | "invalid" | "busy",
					_evaluate: (GraphObject) -> boolean,
				}
				export type StateObject<T> = GraphObject & {
					type: "State",
					kind: string,
					_EXTREMELY_DANGEROUS_usedAsValue: T,
				}
				export type UsedAs<T> = StateObject<T> | T
				export type Use = <T>(target: UsedAs<T>) -> T
				export type Value<T, S = T> = StateObject<T> & {
					kind: "State",
					timeliness: "lazy",
					set: (Value<T, S>, newValue: S, force: boolean?) -> S,
					____phantom_setType: (never) -> S,
				}
				export type ValueConstructor = <T>(scope: Scope<unknown>, initialValue: T) -> Value<T, any>
				export type Computed<T> = StateObject<T> & { kind: "Computed", timeliness: "lazy" }
				export type ComputedConstructor = <T, S>(scope: S & Scope<unknown>, callback: (Use, S) -> T) -> Computed<T>
				export type For<KO, VO> = StateObject<{ [KO]: VO }> & { kind: "For" }
				export type ForPairsConstructor = <KI, KO, VI, VO, S>(scope: S & Scope<unknown>, inputTable: UsedAs<{ [KI]: VI }>, processor: (Use, S, key: KI, value: VI) -> (KO, VO)) -> For<KO, VO>
				export type ForKeysConstructor = <KI, KO, V, S>(scope: S & Scope<unknown>, inputTable: UsedAs<{ [KI]: V }>, processor: (Use, S, key: KI) -> KO) -> For<KO, V>
				export type ForValuesConstructor = <K, VI, VO, S>(scope: S & Scope<unknown>, inputTable: UsedAs<{ [K]: VI }>, processor: (Use, S, value: VI) -> VO) -> For<K, VO>
				export type Observer = GraphObject & {
					type: "Observer",
					timeliness: "eager",
					onChange: (Observer, callback: () -> ()) -> () -> (),
					onBind: (Observer, callback: () -> ()) -> () -> (),
				}
				export type ObserverConstructor = (scope: Scope<unknown>, watching: unknown) -> Observer
				export type Tween<T> = StateObject<T> & { kind: "Tween" }
				export type TweenConstructor = <T>(scope: Scope<unknown>, goalState: UsedAs<T>, tweenInfo: UsedAs<TweenInfo>?) -> Tween<T>
				export type Spring<T> = StateObject<T> & {
					kind: "Spring",
					setPosition: (Spring<T>, newPosition: T) -> (),
					setVelocity: (Spring<T>, newVelocity: T) -> (),
					addVelocity: (Spring<T>, deltaVelocity: T) -> (),
				}
				export type SpringConstructor = <T>(scope: Scope<unknown>, goalState: UsedAs<T>, speed: UsedAs<number>?, damping: UsedAs<number>?) -> Spring<T>
				export type SpecialKey = {
					type: "SpecialKey",
					kind: string,
					stage: "self" | "descendants" | "ancestor" | "observer",
					apply: (self: SpecialKey, scope: Scope<unknown>, value: unknown, applyTo: Instance) -> (),
				}
				export type Child = Instance | StateObject<Child> | { [unknown]: Child }
				export type PropertyTable = { [(string | SpecialKey)]: unknown }
				export type NewConstructor = (scope: Scope<unknown>, className: string) -> (propertyTable: PropertyTable) -> Instance
				export type HydrateConstructor = (scope: Scope<unknown>, target: Instance) -> (propertyTable: PropertyTable) -> Instance
				export type DeriveScopeConstructor = (<S>(Scope<S>) -> Scope<S>) & (<S, A>(Scope<S>, A & {}) -> Scope<S & A>) & (<S, A, B>(Scope<S>, A & {}, B & {}) -> Scope<S & A & B>) & (<S, A, B, C>(Scope<S>, A & {}, B & {}, C & {}) -> Scope<S & A & B & C>) & (<S, A, B, C, D>(Scope<S>, A & {}, B & {}, C & {}, D & {}) -> Scope<S & A & B & C & D>) & (<S, A, B, C, D, E>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}) -> Scope<S & A & B & C & D & E>) & (<S, A, B, C, D, E, F>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scope<S & A & B & C & D & E & F>) & (<S, A, B, C, D, E, F, G>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}) -> Scope<S & A & B & C & D & E & F & G>) & (<S, A, B, C, D, E, F, G, H>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}) -> Scope<S & A & B & C & D & E & F & G & H>) & (<S, A, B, C, D, E, F, G, H, I>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}) -> Scope<S & A & B & C & D & E & F & G & H & I>) & (<S, A, B, C, D, E, F, G, H, I, J>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J>) & (<S, A, B, C, D, E, F, G, H, I, J, K>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J & K>) & (<S, A, B, C, D, E, F, G, H, I, J, K, L>(Scope<S>, A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}, L & {}) -> Scope<S & A & B & C & D & E & F & G & H & I & J & K & L>)
				export type ScopedConstructor = (() -> Scope<{}>) & (<A>(A & {}) -> Scope<A>) & (<A, B>(A & {}, B & {}) -> Scope<A & B>) & (<A, B, C>(A & {}, B & {}, C & {}) -> Scope<A & B & C>) & (<A, B, C, D>(A & {}, B & {}, C & {}, D & {}) -> Scope<A & B & C & D>) & (<A, B, C, D, E>(A & {}, B & {}, C & {}, D & {}, E & {}) -> Scope<A & B & C & D & E>) & (<A, B, C, D, E, F>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scope<A & B & C & D & E & F>) & (<A, B, C, D, E, F, G>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}) -> Scope<A & B & C & D & E & F & G>) & (<A, B, C, D, E, F, G, H>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}) -> Scope<A & B & C & D & E & F & G & H>) & (<A, B, C, D, E, F, G, H, I>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}) -> Scope<A & B & C & D & E & F & G & H & I>) & (<A, B, C, D, E, F, G, H, I, J>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}) -> Scope<A & B & C & D & E & F & G & H & I & J>) & (<A, B, C, D, E, F, G, H, I, J, K>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}) -> Scope<A & B & C & D & E & F & G & H & I & J & K>) & (<A, B, C, D, E, F, G, H, I, J, K, L>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}, G & {}, H & {}, I & {}, J & {}, K & {}, L & {}) -> Scope<A & B & C & D & E & F & G & H & I & J & K & L>)
				export type ContextualConstructor = <T>(defaultValue: T) -> Contextual<T>
				export type Safe = <Success, Fail>(callbacks: { try: () -> Success, fallback: (err: unknown) -> Fail }) -> Success | Fail
				export type Fusion = {
					version: Version,
					cleanup: () -> () -> (),
					Contextual: ContextualConstructor,
					Safe: Safe,
					doCleanup: (Task) -> (),
					scoped: ScopedConstructor,
					deriveScope: DeriveScopeConstructor,
					innerScope: DeriveScopeConstructor,
					insert: <Tasks...>(scope: Scope<unknown>, Tasks...) -> Tasks...,
					peek: Use,
					Value: ValueConstructor,
					Computed: ComputedConstructor,
					ForPairs: ForPairsConstructor,
					ForKeys: ForKeysConstructor,
					ForValues: ForValuesConstructor,
					Observer: ObserverConstructor,
					Tween: TweenConstructor,
					Spring: SpringConstructor,
					New: NewConstructor,
					Hydrate: HydrateConstructor,
					Child: ({ Child }) -> Child,
					Children: SpecialKey,
					Out: (propertyName: string) -> SpecialKey,
					OnEvent: (eventName: string) -> SpecialKey,
					OnChange: (propertyName: string) -> SpecialKey,
					Attribute: (attributeName: string) -> SpecialKey,
					AttributeChange: (attributeName: string) -> SpecialKey,
					AttributeOut: (attributeName: string) -> SpecialKey,
					Tag: (tagName: string) -> SpecialKey,
				}
				export type ExternalProvider = {
					policies: { allowWebLinks: boolean },
					logErrorNonFatal: (errorString: string) -> (),
					logWarn: (errorString: string) -> (),
					doTaskImmediate: (resume: () -> ()) -> (),
					doTaskDeferred: (resume: () -> ()) -> (),
					startScheduler: () -> (),
					stopScheduler: () -> (),
				}
				export type ExternalDebugger = {
					startDebugging: () -> (),
					stopDebugging: () -> (),
					trackScope: (scope: Scope<unknown>) -> (),
					untrackScope: (scope: Scope<unknown>) -> (),
				}
				return nil
			end)()
		end,
		[72] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(72)
			local e
			return (function(...)
				local f
				return setmetatable({}, { __mode = "k" })
			end)()
		end,
		[66] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(66)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h, i, j = d(f.Types), d(f.External), d(f.Logging.parseError)
				export type Self<T> = h.Contextual<T> & { _valuesNow: { [thread]: { value: T } }, _defaultValue: T }
				local k = {}
				k.type = "Contextual"
				local l, m = table.freeze({ __index = k }), table.freeze({ __mode = "k" })
				local function n<T>(o: T): h.Contextual<T>
					local p: Self<T> = setmetatable(
						{ _valuesNow = setmetatable({}, m), _defaultValue = o },
						l
					) :: any
					return p
				end
				function k.now<T>(o: Self<T>): T
					local p = coroutine.running()
					local q = o._valuesNow[p]
					if typeof(q) ~= "table" then
						return o._defaultValue
					else
						return q.value
					end
				end
				function k.is<T>(o: Self<T>, p: T)
					local q = {}
					function q.during<T, A...>(r: any, s: (A...) -> T, ...: A...): T
						local t = coroutine.running()
						local v = o._valuesNow[t]
						o._valuesNow[t] = { value = p }
						local x, y = xpcall(s, j, ...)
						o._valuesNow[t] = v
						if not x then
							i.logError("callbackError", y :: any)
						end
						return y
					end
					return q
				end
				table.freeze(k)
				return n
			end)()
		end,
		[69] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(69)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.External)
				local function i(j: boolean, k: { [unknown]: unknown }, ...: { [unknown]: unknown }): { [unknown]: unknown }
					local l = { ... }
					if #l < 1 then
						return k
					else
						for m, n in l do
							for o, p in n do
								if j or k[o] == nil then
									k[o] = p
								elseif not j then
									h.logError("mergeConflict", nil, tostring(o))
								end
							end
						end
						return k
					end
				end
				return i
			end)()
		end,
		[68] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(68)
			local e
			return (function(...)
				local f
				local function g(h: unknown, i: unknown): boolean
					local j = typeof(h)
					local k, l = j == "table", j == "userdata"
					return if not (k or l) then h == i or h ~= h and i ~= i
						elseif j == typeof(i)
							and (l or table.isfrozen(h :: any) or getmetatable(h :: any) ~= nil) then h
							== i
						else false
				end
				return g
			end)()
		end,
		[71] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(71)
			local e
			return (function(...)
				local f
				local function g(): never
					error("This codepath should not be reachable")
				end
				return g
			end)()
		end,
		[73] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(73)
			local e
			return (function(...)
				local f
				local function g(h: unknown): string
					local i = typeof(h)
					if i == "table" then
						local j = h :: { type: unknown? }
						if typeof(j.type) == "string" then
							return j.type
						end
					end
					return i
				end
				return g
			end)()
		end,
		[67] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(67)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local function h<Success, Fail>(
					i: { try: () -> Success, fallback: (err: unknown) -> Fail }
				): Success | Fail
					local j, k = xpcall(i.try, i.fallback)
					return k
				end
				return h
			end)()
		end,
		[70] = function()
			LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
			local b, c, d = a(70)
			local e
			return (function(...)
				local f, g = c.Parent.Parent
				local h = d(f.Utility.nicknames)
				local function i(j: unknown, k: string): string
					local l = h[j]
					if typeof(l) == "string" then
						return l
					end
					if typeof(j) == "table" then
						local m = j :: { [any]: any }
						if typeof(m.name) == "string" then
							return m.name
						elseif typeof(m.kind) == "string" then
							return m.kind
						elseif typeof(m.type) == "string" then
							return m.type
						end
					end
					return k
				end
				return i
			end)()
		end,
	},
	{
		{
			1,
			2,
			{ "Fusion" },
			{
				{ 16, 2, { "External" } },
				{ 17, 2, { "ExternalDebug" } },
				{
					65,
					1,
					{ "Utility" },
					{
						{ 73, 2, { "xtypeof" } },
						{ 69, 2, { "merge" } },
						{ 72, 2, { "nicknames" } },
						{ 67, 2, { "Safe" } },
						{ 66, 2, { "Contextual" } },
						{ 71, 2, { "never" } },
						{ 70, 2, { "nameOf" } },
						{ 68, 2, { "isSimilar" } },
					},
				},
				{
					64,
					2,
					{
						"Types",
					},
				},
				{
					42,
					1,
					{ "Memory" },
					{
						{ 46, 2, { "doCleanup" } },
						{ 47, 2, { "innerScope" } },
						{ 50, 2, { "scoped" } },
						{ 45, 2, { "deriveScopeImpl" } },
						{ 43, 2, { "checkLifetime" } },
						{ 48, 2, { "insert" } },
						{ 44, 2, { "deriveScope" } },
						{ 49, 2, { "needsDestruction" } },
					},
				},
				{
					2,
					1,
					{ "Animation" },
					{
						{
							8,
							2,
							{
								"getTweenRatio",
							},
						},
						{ 11, 2, { "springCoefficients" } },
						{ 6, 2, { "Tween" } },
						{ 9, 2, { "lerpType" } },
						{ 7, 2, { "getTweenDuration" } },
						{
							12,
							2,
							{
								"unpackType",
							},
						},
						{ 4, 2, { "Spring" } },
						{ 3, 2, { "ExternalTime" } },
						{ 5, 2, { "Stopwatch" } },
						{ 10, 2, { "packType" } },
					},
				},
				{
					38,
					1,
					{ "Logging" },
					{
						{ 40, 2, { "messages" } },
						{ 39, 2, { "formatError" } },
						{ 41, 2, { "parseError" } },
					},
				},
				{
					18,
					1,
					{ "Graph" },
					{
						{ 23, 2, { "evaluate" } },
						{ 21, 2, { "change" } },
						{
							22,
							2,
							{ "depend" },
						},
						{ 19, 2, { "Observer" } },
						{ 20, 2, { "castToGraph" } },
					},
				},
				{
					52,
					1,
					{ "State" },
					{
						{ 59, 2, { "ForValues" } },
						{ 63, 2, { "updateAll" } },
						{
							54,
							2,
							{ "For" },
							{ { 56, 2, { "ForTypes" } }, { 55, 2, { "Disassembly" } } },
						},
						{ 61, 2, { "castToState" } },
						{ 62, 2, { "peek" } },
						{ 58, 2, { "ForPairs" } },
						{ 60, 2, { "Value" } },
						{ 57, 2, { "ForKeys" } },
						{ 53, 2, { "Computed" } },
					},
				},
				{
					24,
					1,
					{ "Instances" },
					{
						{ 30, 2, { "Hydrate" } },
						{ 27, 2, { "AttributeOut" } },
						{ 37, 2, { "defaultProps" } },
						{ 31, 2, { "New" } },
						{ 33, 2, { "OnEvent" } },
						{ 32, 2, { "OnChange" } },
						{ 29, 2, { "Children" } },
						{ 35, 2, { "Tag" } },
						{ 28, 2, { "Child" } },
						{ 25, 2, { "Attribute" } },
						{ 34, 2, { "Out" } },
						{ 26, 2, { "AttributeChange" } },
						{ 36, 2, { "applyInstanceProps" } },
					},
				},
				{
					51,
					2,
					{
						"RobloxExternal",
					},
				},
				{ 13, 1, { "Colour" }, { { 15, 2, { "sRGB" } }, { 14, 2, { "Oklab" } } } },
			},
		},
	},
	"0.4.2",
	"WaxRuntime",
	string,
	task,
	setmetatable,
	error,
	next,
	table,
	unpack,
	coroutine,
	script,
	type,
	require,
	pcall,
	tostring,
	tonumber,
	_VERSION
local x, y, z, A, B, C, D =
	k.insert,
	k.remove,
	k.freeze
		or function(x)
			return x
		end,
	m.wrap,
	f.sub,
	f.match,
	f.gmatch
if t and B(t, 1, 4) == "Lune" then
	local E, F = q(p, "@lune/task")
	if E and F then
		g = F
	end
end
local E = g and g.defer
local F, G, H, I, J, K, L, M, N =
	E
		or function(F, ...)
			A(F)(...)
		end,
	{
		[1] = "Folder",
		[2] = "ModuleScript",
		[3] = "Script",
		[4] = "LocalScript",
		[5] = "StringValue",
	},
	{},
	{},
	{},
	{},
	{},
	{},
	{}
local O, P =
	{
		GetFullName = {
			{},
			function(O)
				local P, Q = O.Name, O.Parent
				while Q do
					P = Q.Name .. "." .. P
					Q = Q.Parent
				end
				return P
			end,
		},
		GetChildren = {
			{},
			function(O)
				local P = {}
				for Q in j, N[O] do
					x(P, Q)
				end
				return P
			end,
		},
		GetDescendants = {
			{},
			function(O)
				local P = {}
				for Q in j, N[O] do
					x(P, Q)
					for R, S in j, Q:GetDescendants() do
						x(P, S)
					end
				end
				return P
			end,
		},
		FindFirstChild = {
			{ "string", "boolean?" },
			function(O, P, Q)
				local R = N[O]
				for S in j, R do
					if S.Name == P then
						return S
					end
				end
				if Q then
					for S in j, R do
						return S:FindFirstChild(P, true)
					end
				end
			end,
		},
		FindFirstAncestor = {
			{ "string" },
			function(O, P)
				local Q = O.Parent
				while Q do
					if Q.Name == P then
						return Q
					end
					Q = Q.Parent
				end
			end,
		},
		WaitForChild = {
			{ "string", "number?" },
			function(O, P)
				return O:FindFirstChild(P)
			end,
		},
	},
	{}
for Q, R in j, O do
	local S, T, U = R[1], R[2], {}
	for V, W in j, S do
		local X, Y = C(W, "^([^%?]+)(%??)")
		U[V] = { X, Y }
	end
	P[Q] = function(V, ...)
		if not N[V] then
			i("Expected ':' not '.' calling member function " .. Q, 2)
		end
		local W = { ... }
		for X, Y in j, U do
			local Z = W[X]
			local _, aa, ab = o(Z), Y[1], Y[2]
			if Z == nil and not ab then
				i("Argument " .. Z .. " missing or nil", 3)
			end
			if aa ~= "any" and _ ~= aa and not (_ == "nil" and ab) then
				i("Argument " .. X .. ' expects type "' .. aa .. '", got "' .. _ .. '"', 2)
			end
		end
		return T(V, ...)
	end
end
local function aa(ab, Q, R)
	local S, T = (h({}, { __mode = "k" }))
	local function U(V)
		i(V .. " is not a valid (virtual) member of " .. ab .. ' "' .. Q .. '"', 3)
	end
	local function V(W)
		i("Unable to assign (virtual) property " .. W .. ". Property is read only", 3)
	end
	local W, X = {}, {}
	X.__metatable = false
	X.__index = function(Y, Z)
		if Z == "ClassName" then
			return ab
		elseif Z == "Name" then
			return Q
		elseif Z == "Parent" then
			return R
		elseif ab == "StringValue" and Z == "Value" then
			return T
		else
			local _ = P[Z]
			if _ then
				return _
			end
		end
		for _ in j, S do
			if _.Name == Z then
				return _
			end
		end
		U(Z)
	end
	X.__newindex = function(Y, Z, _)
		if Z == "ClassName" then
			V(Z)
		elseif Z == "Name" then
			Q = _
		elseif Z == "Parent" then
			if _ == W then
				return
			end
			if R ~= nil then
				N[R][W] = nil
			end
			R = _
			if _ ~= nil then
				N[_][W] = true
			end
		elseif ab == "StringValue" and Z == "Value" then
			T = _
		else
			U(Z)
		end
	end
	X.__tostring = function()
		return Q
	end
	h(W, X)
	N[W] = S
	if R ~= nil then
		N[R][W] = true
	end
	return W
end
local function ab(Q, R)
	local S, T, U, V = Q[1], Q[2], Q[3], Q[4]
	local W = G[T]
	local X = U and y(U, 1) or W
	local Y = aa(W, X, R)
	H[S] = Y
	if U then
		for Z, _ in j, U do
			Y[Z] = _
		end
	end
	if V then
		for Z, _ in j, V do
			ab(_, Y)
		end
	end
	return Y
end
local Q = aa("Folder", "[" .. e .. "]")
for R, S in j, c do
	ab(S, Q)
end
for R, S in j, b do
	local T = H[R]
	I[T] = S
	J[T] = R
	local U = T.ClassName
	if U == "LocalScript" or U == "Script" then
		x(L, T)
	end
end
local function R(S)
	local T, U = S.ClassName, K[S]
	if U and T == "ModuleScript" then
		return l(U)
	end
	local V = I[S]
	local function W(X)
		X = r(X)
		local Y, Z, _ = S:GetFullName(), C(X, "[^:]+:(%d+): (.+)")
		if not Z or not v then
			return Y .. ":*: " .. (_ or X)
		end
		Z = s(Z)
		local ac = J[S]
		local ad = v[ac]
		local ae = Z - ad + 1
		if ae < 0 then
			ae = "?"
		end
		return Y .. ":" .. ae .. ": " .. _
	end
	if T == "LocalScript" or T == "Script" then
		local ac, ad = q(V)
		if not ac then
			i(W(ad), 0)
		end
	else
		local ac = { q(V) }
		local ad = y(ac, 1)
		if not ad then
			local ae = y(ac, 1)
			i(W(ae), 0)
		end
		K[S] = ac
		return l(ac)
	end
end
function a(ac)
	local ad = H[ac]
	local function ae(S, ...)
		local T = { q(S, ...) }
		local U = y(T, 1)
		if not U then
			i(T[1], 3)
		end
		return l(T)
	end
	local S = z(
		h(
			{},
			{
				__index = M,
				__newindex = function(S, T, U)
					M[T] = U
				end,
				__len = function()
					return #M
				end,
				__iter = function()
					return j, M
				end,
			}
		)
	)
	local T, U = z({ version = d, envname = e, shared = S, script = n, require = p }), ad
	local function V(W, ...)
		local X, Y, Z =
			o(W),
			"Attempted to call require with a non-ModuleScript",
			"Attempted to call require with self"
		if X == "table" and N[W] then
			if W.ClassName ~= "ModuleScript" then
				i(Y, 2)
			elseif W == ad then
				i(Z, 2)
			end
			return R(W)
		elseif X == "string" and B(W, 1, 1) ~= "@" then
			if #W == 0 then
				i("Attempted to call require with empty string", 2)
			end
			local _ = ad
			if B(W, 1, 1) == "/" then
				_ = Q
			elseif B(W, 1, 2) == "./" then
				W = B(W, 3)
			end
			local af
			for ag in D(W, "([^/]*)/?") do
				local ah = ag
				if ag == ".." then
					ah = "Parent"
				end
				if ah ~= "" then
					local ai = _:FindFirstChild(ah)
					if not ai then
						local aj = _.Parent
						if aj then
							ai = aj:FindFirstChild(ah)
						end
					end
					if ai then
						_ = ai
					elseif ag ~= af and ag ~= "init" and ag ~= "init.server" and ag ~= "init.client" then
						i('Virtual script path "' .. W .. '" not found', 2)
					end
				end
				af = ag
			end
			if _.ClassName ~= "ModuleScript" then
				i(Y, 2)
			elseif _ == ad then
				i(Z, 2)
			end
			return R(_)
		end
		return ae(p, W, ...)
	end
	return T, U, V
end
for ac, ad in j, L do
	F(R, ad)
end
return R(Q:GetChildren()[1])

end)() end,
    [31] = function()local wax,script,require=ImportGlobals(31)local ImportGlobals return (function(...)local Fusion = require(script.Parent.fusion)
local Maid = require(script.Parent.maid)

return {
	Scope = Fusion.scoped(Fusion),
	Maid = Maid.new(),
}

end)() end,
    [32] = function()local wax,script,require=ImportGlobals(32)local ImportGlobals return (function(...)--!strict
--!optimize 2

--[[
	Lexical scanner producing a stream of tokens from Luau source code.
	Built as a single-pass byte scanner so it can handle Luau syntax that
	pattern matching could not. It understands string escapes, interpolated
	strings with nested holes, type annotation operators, and contextual type positions.

	Lexer.scan(source) yields (kind, content) pairs whose contents
	concatenate back to the exact source, so consumers can walk token lengths
	to find positions. Whitespace merges into the preceding token's content.

	The possible token kinds are iden, keyword, builtin, type, string,
	number, comment, and operator.
]]

local Language = require(script.language)
local Constants = require(script.constants)
local Navigator = require(script.navigator)

local keywords = Language.keyword
local builtins = Language.builtin
local libraries = Language.libraries

local Lexer = {}
Lexer.language = Language

-- The constant tables rebind as locals so the scanner's hot loops read
-- upvalues instead of chasing module fields.
local BYTE_NEWLINE = Constants.BYTE_NEWLINE
local BYTE_RETURN = Constants.BYTE_RETURN
local BYTE_QUOTE = Constants.BYTE_QUOTE
local BYTE_APOSTROPHE = Constants.BYTE_APOSTROPHE
local BYTE_BACKTICK = Constants.BYTE_BACKTICK
local BYTE_BACKSLASH = Constants.BYTE_BACKSLASH
local BYTE_DASH = Constants.BYTE_DASH
local BYTE_PLUS = Constants.BYTE_PLUS
local BYTE_STAR = Constants.BYTE_STAR
local BYTE_SLASH = Constants.BYTE_SLASH
local BYTE_PERCENT = Constants.BYTE_PERCENT
local BYTE_CARET = Constants.BYTE_CARET
local BYTE_HASH = Constants.BYTE_HASH
local BYTE_TILDE = Constants.BYTE_TILDE
local BYTE_DOT = Constants.BYTE_DOT
local BYTE_COMMA = Constants.BYTE_COMMA
local BYTE_COLON = Constants.BYTE_COLON
local BYTE_SEMICOLON = Constants.BYTE_SEMICOLON
local BYTE_QUESTION = Constants.BYTE_QUESTION
local BYTE_PIPE = Constants.BYTE_PIPE
local BYTE_AMPERSAND = Constants.BYTE_AMPERSAND
local BYTE_UNDERSCORE = Constants.BYTE_UNDERSCORE
local BYTE_EQUALS = Constants.BYTE_EQUALS
local BYTE_OPEN_PAREN = Constants.BYTE_OPEN_PAREN
local BYTE_CLOSE_PAREN = Constants.BYTE_CLOSE_PAREN
local BYTE_OPEN_BRACE = Constants.BYTE_OPEN_BRACE
local BYTE_CLOSE_BRACE = Constants.BYTE_CLOSE_BRACE
local BYTE_OPEN_BRACKET = Constants.BYTE_OPEN_BRACKET
local BYTE_CLOSE_BRACKET = Constants.BYTE_CLOSE_BRACKET
local BYTE_LESS_THAN = Constants.BYTE_LESS_THAN
local BYTE_GREATER_THAN = Constants.BYTE_GREATER_THAN
local BYTE_AT = Constants.BYTE_AT
local BYTE_LOWER_E = Constants.BYTE_LOWER_E
local BYTE_UPPER_E = Constants.BYTE_UPPER_E
local BYTE_LOWER_U = Constants.BYTE_LOWER_U
local BYTE_LOWER_Z = Constants.BYTE_LOWER_Z
local IS_SPACE = Constants.IS_SPACE
local IS_DIGIT = Constants.IS_DIGIT
local IS_IDEN_START = Constants.IS_IDEN_START
local IS_IDEN_CHAR = Constants.IS_IDEN_CHAR
local IS_NUMBER_TAIL = Constants.IS_NUMBER_TAIL

-- How many bytes past a token's start the restart watermark reserves for
-- the fixed peeks that never fold into maxRead, which are the one and two
-- byte reads in scanOperator and the dispatcher. The deepest of those
-- reaches one byte past the next token's start, from the third byte read of
-- a lone dot operator, and the second byte keeps a margin over it. A new
-- peek reaching deeper than this must fold its position into maxRead the
-- way the long lookahead helpers and checkTypeNewline do, or hotswap reuse
-- will silently trust tokens whose lookahead crossed an edit.
local FIXED_PEEK_SLACK = 2

--[[
	Scans one source string, calling yield(kind, content) for every token.
	All scanner state lives in locals here so concurrent scans of different
	sources never interfere. When a token ends at a safely resumable point,
	its yield also carries the bracket depth there and the furthest byte the
	scan has read, which is what lets the navigator resume a scan partway
	through an edited source. The optional seed restores the state such a
	resumed scan needs beyond its start position.
]]
local function scanSource(
	source: string,
	yield: (string, string, number?, number?) -> (),
	startIndex: number?,
	seed: Navigator.ScanSeed?
)
	local size = #source
	local index = startIndex or 1

	-- Tokens queue briefly before yielding so trailing whitespace can merge
	-- into them, and whitespace before the first token becomes its prefix.
	local queuedKind: string? = nil
	local queuedText = ""
	local pendingPrefix = ""

	-- The last three emitted token lexemes feed the library member heuristic,
	-- mirroring how members are detected for things like math.floor without
	-- misreading foo.floor. They hold exact lexemes with no whitespace, which
	-- lets the heuristic compare interned strings instead of running pattern
	-- matches on the identifier hot path.
	local previous1, previous2, previous3 = "", "", ""

	-- Bracket depth across parens, braces, and square brackets in code, and
	-- the depths at which interpolation holes opened.
	local depth = 0
	local holeStack = {}

	-- A resumed scan restores the depth and previous token lexemes it would
	-- have had at this point in a full scan. Cached token contents carry
	-- merged whitespace, so they strip once here to restore the exact lexeme
	-- invariant the heuristic relies on.
	if seed ~= nil then
		depth = seed.depth
		previous1 = (string.gsub(seed.previous1, "[%c%s]+", ""))
		previous2 = (string.gsub(seed.previous2, "[%c%s]+", ""))
		previous3 = (string.gsub(seed.previous3, "[%c%s]+", ""))
	end

	-- The furthest byte position any lookahead has read. Restart snapshots
	-- report it so the navigator can prove that a cached token, and the
	-- scanner state after it, never depended on bytes that later changed.
	local maxRead = 0

	-- Snapshot of the resumable state at the start of the token currently
	-- being scanned. When restartable, the previous token's yield carries it,
	-- since the position right after that token is where a resume would begin.
	local snapDepth = 0
	local snapWatermark = 0
	local snapRestartable = false

	-- Type context state. While typeMode is on, identifiers lex as type
	-- tokens until the context exits at its entry depth. typeAngle tracks
	-- generic argument brackets, typeofDepth suspends type classification
	-- inside typeof(...) since it takes a value expression, and the alias
	-- flags carry a "type Name = ..." statement through its equals sign.
	-- typeExpectsWord arms whenever the next identifier can extend the type
	-- expression, which is right after entering the context or a connector
	-- operator. An identifier arriving unarmed means a new value expression
	-- started on the same line, so the context exits instead of swallowing it.
	local typeMode = false
	local typeEntryDepth = 0
	local typeAngle = 0
	local typeContinues = false
	local typeExpectsWord = false
	local typeofDepth: number? = nil
	local typeofArmed = false
	local aliasNamePending = false
	local aliasAwaitEquals = false

	local function flushQueued()
		if queuedKind ~= nil then
			-- The snapshot rides along only when the position after this
			-- token is a safe place to resume a scan from.
			if snapRestartable then
				yield(queuedKind, queuedText, snapDepth, snapWatermark)
			else
				yield(queuedKind, queuedText)
			end
			queuedKind, queuedText = nil, ""
		end
	end

	local function emit(kind: string, text: string)
		flushQueued()
		-- The lexeme records before the prefix joins it, so the previous
		-- token texts stay whitespace free even at the start of the source.
		previous3, previous2, previous1 = previous2, previous1, text
		if pendingPrefix ~= "" then
			text = pendingPrefix .. text
			pendingPrefix = ""
		end
		queuedKind, queuedText = kind, text
	end

	local function emitSuffix(text: string)
		if queuedKind ~= nil then
			queuedText ..= text
		else
			pendingPrefix ..= text
		end
	end

	local function enterTypeMode()
		typeMode = true
		typeEntryDepth = depth
		typeAngle = 0
		typeExpectsWord = true
		typeofDepth = nil
	end

	local function exitTypeMode()
		typeMode = false
		typeAngle = 0
		typeExpectsWord = false
		typeofDepth = nil
		aliasAwaitEquals = false
	end

	local function skipSpace(position: number): number
		while position <= size and IS_SPACE[string.byte(source, position)] do
			position += 1
		end
		if position > maxRead then
			maxRead = position
		end
		return position
	end

	--[[
		Reads a dotted identifier chain starting at the given position and
		returns the position after it, or nil when no identifier starts
		there. Used only for lookahead, so it never consumes input.
	]]
	local function skipIdenChain(position: number): number?
		local byte = string.byte(source, position)
		if byte == nil or not IS_IDEN_START[byte] then
			return nil
		end
		while true do
			position += 1
			while position <= size and IS_IDEN_CHAR[string.byte(source, position)] do
				position += 1
			end
			if position > maxRead then
				maxRead = position
			end
			local afterSpace = skipSpace(position)
			if string.byte(source, afterSpace) ~= BYTE_DOT then
				return position
			end
			local nextIden = skipSpace(afterSpace + 1)
			if nextIden > size or not IS_IDEN_START[string.byte(source, nextIden)] then
				return position
			end
			position = nextIden - 1
		end
	end

	--[[
		Reads the level of a long bracket opener at the given position,
		returning the count of equals signs or nil when it is not one.
	]]
	local function matchLongOpen(position: number): number?
		if string.byte(source, position) ~= BYTE_OPEN_BRACKET then
			return nil
		end
		local level = 0
		local cursor = position + 1
		while string.byte(source, cursor) == BYTE_EQUALS do
			level += 1
			cursor += 1
		end
		-- The equals run can reach well past the byte the scanner ends up
		-- consuming, so a failed match still counts as lookahead.
		if cursor > maxRead then
			maxRead = cursor
		end
		if string.byte(source, cursor) == BYTE_OPEN_BRACKET then
			return level
		end
		return nil
	end

	--[[
		Steps over whitespace and comments starting at the given position and
		returns the position of the next significant byte, or nil when an
		unfinished comment hides the rest of the source. Used only for
		lookahead, so it never consumes input.
	]]
	local function skipInsignificant(position: number): number?
		position = skipSpace(position)
		while string.byte(source, position) == BYTE_DASH do
			-- Deciding whether the dash opens a comment reads the byte after
			-- it, so that peek folds into maxRead even when the dash turns
			-- out to be a lone operator and the walk stops here. Skipping the
			-- fold would let a restart snapshot vouch for a decision that
			-- depended on a byte the edit may have changed.
			if position + 1 > maxRead then
				maxRead = position + 1
			end
			if string.byte(source, position + 1) ~= BYTE_DASH then
				break
			end
			local level = matchLongOpen(position + 2)
			if level ~= nil then
				local closer = "]" .. string.rep("=", level) .. "]"
				local _, finish = string.find(source, closer, position + 2 + level + 2, true)
				if finish == nil then
					-- The failed search read every remaining byte.
					if size > maxRead then
						maxRead = size
					end
					return nil
				end
				if finish > maxRead then
					maxRead = finish
				end
				position = skipSpace(finish + 1)
			else
				local newlineAt = string.find(source, "\n", position + 2, true)
				if newlineAt == nil then
					if size > maxRead then
						maxRead = size
					end
					return nil
				end
				if newlineAt > maxRead then
					maxRead = newlineAt
				end
				position = skipSpace(newlineAt + 1)
			end
		end
		return position
	end

	--[[
		Ends the type context when a line break lands at its entry depth,
		unless the last significant token promised a continuation or the next
		significant byte is a union bar, an intersection ampersand, or a
		return arrow. No statement can start with those bytes, so a line
		leading with one can only be continuing the type expression. Comments
		stay transparent to the type context, so the lookahead walks past
		whitespace and whole comments, and every byte it reads folds into
		maxRead so restart snapshots stay honest about the peek.
	]]
	local function checkTypeNewline()
		if typeMode
			and depth <= typeEntryDepth
			and typeAngle == 0
			and not typeContinues
			and not aliasAwaitEquals then
			local nextSignificant = skipInsignificant(index)
			if nextSignificant ~= nil then
				local nextByte = string.byte(source, nextSignificant)
				if nextByte == BYTE_PIPE or nextByte == BYTE_AMPERSAND then
					return
				end
				-- A dash here is never a comment opener, since the walk above
				-- stops only on significant bytes and already folded the byte
				-- after the dash into maxRead while ruling a comment out.
				if nextByte == BYTE_DASH
					and string.byte(source, nextSignificant + 1) == BYTE_GREATER_THAN then
					return
				end
			end
			exitTypeMode()
		end
	end

	--[[
		Decides whether a colon at the scanner's position starts a type
		annotation rather than a method access. A method name is followed
		immediately by call arguments, while an annotation's type is not.
		Comments may sit on either side of the name, so the lookahead steps
		over them the way the scanner itself will.
	]]
	local function isAnnotationColon(): boolean
		local position = skipInsignificant(index)
		if position == nil then
			return false
		end
		local byte = string.byte(source, position)
		if byte == nil then
			return false
		end
		if byte == BYTE_OPEN_PAREN or byte == BYTE_OPEN_BRACE then
			return true
		end
		local afterChain = skipIdenChain(position)
		if afterChain == nil then
			return false
		end
		local afterName = skipInsignificant(afterChain)
		if afterName == nil then
			-- A name followed by an unfinished comment shows no call
			-- arguments, so it reads as an annotation.
			return true
		end
		-- An open bracket after the name is a long bracket string argument,
		-- since no type syntax puts one directly after an identifier chain.
		local nextByte = string.byte(source, afterName)
		return nextByte ~= BYTE_OPEN_PAREN
			and nextByte ~= BYTE_OPEN_BRACE
			and nextByte ~= BYTE_QUOTE
			and nextByte ~= BYTE_APOSTROPHE
			and nextByte ~= BYTE_BACKTICK
			and nextByte ~= BYTE_OPEN_BRACKET
	end

	--[[
		Decides whether the source after a type keyword looks like an alias
		declaration, meaning a name, optional generic parameter list, and an
		equals sign. This keeps calls to a variable named type lexing as
		plain code.
	]]
	local function isAliasHead(): boolean
		local position = skipSpace(index)
		local byte = string.byte(source, position)
		if byte == nil or not IS_IDEN_START[byte] then
			return false
		end
		while position <= size and IS_IDEN_CHAR[string.byte(source, position)] do
			position += 1
		end
		if position > maxRead then
			maxRead = position
		end
		position = skipSpace(position)
		if string.byte(source, position) == BYTE_LESS_THAN then
			local angle = 0
			while position <= size do
				local angleByte = string.byte(source, position)
				if angleByte == BYTE_LESS_THAN then
					angle += 1
				elseif angleByte == BYTE_GREATER_THAN then
					angle -= 1
					if angle == 0 then
						position += 1
						break
					end
				end
				position += 1
			end
			position = skipSpace(position)
		end
		if position + 1 > maxRead then
			maxRead = position + 1
		end
		return string.byte(source, position) == BYTE_EQUALS
			and string.byte(source, position + 1) ~= BYTE_EQUALS
	end

	--[[
		Scans an identifier and classifies it. Type contexts win over the
		builtin table so annotations color consistently, and the library
		member heuristic still recognizes things like math.floor.
	]]
	local function scanIden()
		typeofArmed = false
		local start = index
		index += 1
		while index <= size and IS_IDEN_CHAR[string.byte(source, index)] do
			index += 1
		end
		local text = string.sub(source, start, index - 1)
		typeContinues = false

		if aliasNamePending then
			aliasNamePending = false
			emit("type", text)
			enterTypeMode()
			aliasAwaitEquals = true
			typeContinues = true
			return
		end

		if keywords[text] ~= nil then
			if typeMode then
				if text == "typeof" then
					emit("keyword", text)
					typeofArmed = true
					typeExpectsWord = false
					return
				end
				-- nil, true, and false are singleton types, so they stay
				-- legal inside a type expression while any other keyword
				-- ends the context.
				if text ~= "nil" and text ~= "true" and text ~= "false" then
					exitTypeMode()
				else
					typeExpectsWord = false
				end
			elseif text == "type" and isAliasHead() then
				aliasNamePending = true
			end
			emit("keyword", text)
			return
		end

		if typeMode and typeofDepth == nil then
			if typeExpectsWord then
				typeExpectsWord = false
				emit("type", text)
				return
			end
			-- The type expression cannot take another bare identifier, so
			-- this one starts a new value expression and classifies below.
			exitTypeMode()
		end

		if builtins[text] ~= nil then
			emit("builtin", text)
			return
		end

		-- A library member sits directly after a member access dot whose left
		-- side is a known library that is not itself a member access, which
		-- keeps foo.math.floor plain. The previous lexemes are exact interned
		-- strings, so equality against the dot operator is all this costs.
		if previous1 == "." and previous3 ~= "." then
			local libraryMembers = libraries[previous2]
			if libraryMembers ~= nil and libraryMembers[text] ~= nil then
				emit("builtin", text)
				return
			end
		end

		emit("iden", text)
	end

	--[[
		Scans a numeric literal by skipping a number-like pattern exactly the
		way Luau's own lexer does. It greedily takes digits, dots, and
		underscores, then an exponent marker with an optional sign, then any
		trailing alphanumeric run. That trailing run is what keeps hex and
		binary notations whole and keeps malformed literals like 1.2.3 or 3px
		lexing as a single number token, matching how Luau reports them.
	]]
	local function scanNumber()
		typeofArmed = false
		typeContinues = false
		typeExpectsWord = false
		local start = index

		repeat
			index += 1
			local byte = string.byte(source, index)
		until byte == nil or not (IS_DIGIT[byte] or byte == BYTE_DOT or byte == BYTE_UNDERSCORE)

		local exponentByte = string.byte(source, index)
		if exponentByte == BYTE_LOWER_E or exponentByte == BYTE_UPPER_E then
			index += 1
			local signByte = string.byte(source, index)
			if signByte == BYTE_PLUS or signByte == BYTE_DASH then
				index += 1
			end
		end

		while index <= size and IS_NUMBER_TAIL[string.byte(source, index)] do
			index += 1
		end

		emit("number", string.sub(source, start, index - 1))
	end

	--[[
		Advances past a backslash escape inside a string, mirroring Luau's
		readBackslashInString, and returns whether it consumed a line feed so
		string scanners can track line breaks without rescanning their text.
		An escaped carriage return also takes the line feed after it, and a z
		escape swallows all following whitespace including line breaks so the
		string continues on the next line.
	]]
	local function skipEscape(): boolean
		local escapeByte = string.byte(source, index + 1)
		if escapeByte == nil then
			index += 1
			return false
		elseif escapeByte == BYTE_RETURN then
			index += 2
			if string.byte(source, index) == BYTE_NEWLINE then
				index += 1
				return true
			end
			return false
		elseif escapeByte == BYTE_LOWER_Z then
			index += 2
			local sawNewline = false
			while index <= size do
				local spaceByte = string.byte(source, index)
				if not IS_SPACE[spaceByte] then
					break
				end
				if spaceByte == BYTE_NEWLINE then
					sawNewline = true
				end
				index += 1
			end
			return sawNewline
		else
			index += 2
			return escapeByte == BYTE_NEWLINE
		end
	end

	--[[
		Scans a quoted string with real escape handling, so escaped quotes
		stay inside the string and an escaped backslash before the closing
		quote still closes it. An unfinished string runs through the end of
		its line.
	]]
	local function scanQuoted(quoteByte: number)
		typeofArmed = false
		typeContinues = false
		typeExpectsWord = false
		local start = index
		local sawNewline = false
		index += 1
		while index <= size do
			local byte = string.byte(source, index)
			if byte == BYTE_BACKSLASH then
				if skipEscape() then
					sawNewline = true
				end
			elseif byte == quoteByte or byte == BYTE_NEWLINE or byte == BYTE_RETURN then
				if byte == BYTE_NEWLINE then
					sawNewline = true
				end
				index += 1
				break
			else
				index += 1
			end
		end
		emit("string", string.sub(source, start, index - 1))
		if sawNewline then
			checkTypeNewline()
		end
	end

	--[[
		Scans from a long bracket opener through its matching closer, or to
		the end of the source when unfinished, emitting the given kind.
	]]
	local function scanLongBracket(kind: string, start: number, level: number, bodyStart: number)
		-- Comments stay transparent to the type context so an annotation can
		-- carry past one and typeof stays armed for its paren, while a long
		-- string ends any continuation the same way a quoted string does.
		if kind == "string" then
			typeofArmed = false
			typeContinues = false
			typeExpectsWord = false
		end
		local closer = "]" .. string.rep("=", level) .. "]"
		local _, finish = string.find(source, closer, bodyStart, true)
		if finish ~= nil then
			index = finish + 1
		else
			-- The failed search read every remaining byte looking for the
			-- closer, so the whole source counts as lookahead.
			index = size + 1
			if size > maxRead then
				maxRead = size
			end
		end
		local text = string.sub(source, start, index - 1)
		emit(kind, text)
		if string.find(text, "\n", 1, true) ~= nil then
			checkTypeNewline()
		end
	end

	--[[
		Scans a comment, either a long bracket form or a line comment that
		runs through its newline.
	]]
	local function scanComment()
		local start = index
		local level = matchLongOpen(index + 2)
		if level ~= nil then
			scanLongBracket("comment", start, level, index + 2 + level + 2)
			return
		end
		local newlineAt = string.find(source, "\n", index + 2, true)
		if newlineAt ~= nil then
			index = newlineAt + 1
		else
			index = size + 1
		end
		emit("comment", string.sub(source, start, index - 1))
		-- The terminator search already answers whether the comment carried
		-- its newline, so no rescan of the text is needed.
		if newlineAt ~= nil then
			checkTypeNewline()
		end
	end

	--[[
		Emits one interpolated string piece running from start to the current
		index, ending the type context when the piece carried a line break the
		way every other string and comment scanner does. A piece can hold a
		line break as the bare one that terminated an unfinished string or
		through an escape like a backslash z, and the scanners that consume
		those bytes report the flag rather than rescanning the text.
	]]
	local function emitInterpPiece(start: number, sawNewline: boolean)
		emit("string", string.sub(source, start, index - 1))
		if sawNewline then
			checkTypeNewline()
		end
	end

	--[[
		Scans one string piece of an interpolated string, starting at the
		opening backtick or at the brace that just closed a hole. Returns
		"hole" when the piece ends by opening a hole, and nil when the
		string ends, hits a bare newline, or hits the end of the source.
	]]
	local function scanInterpPiece(): string?
		typeofArmed = false
		typeContinues = false
		local start = index
		local sawNewline = false
		index += 1
		while index <= size do
			local byte = string.byte(source, index)
			if byte == BYTE_BACKSLASH then
				-- A unicode escape's brace belongs to the string text, so it
				-- must not open an interpolation hole.
				if string.byte(source, index + 1) == BYTE_LOWER_U
					and string.byte(source, index + 2) == BYTE_OPEN_BRACE then
					index += 3
				elseif skipEscape() then
					sawNewline = true
				end
			elseif byte == BYTE_BACKTICK or byte == BYTE_NEWLINE or byte == BYTE_RETURN then
				if byte == BYTE_NEWLINE then
					sawNewline = true
				end
				index += 1
				emitInterpPiece(start, sawNewline)
				return nil
			elseif byte == BYTE_OPEN_BRACE then
				index += 1
				emitInterpPiece(start, sawNewline)
				return "hole"
			else
				index += 1
			end
		end
		emitInterpPiece(start, sawNewline)
		return nil
	end

	--[[
		Applies an operator's side effects: bracket depth, interpolation
		hole tracking, and the type context's entries and exits. Each branch
		also records whether the operator lets a type context survive a line
		break, like a trailing union bar before a wrapped union member, since
		the chain is already comparing against every lexeme that does.
	]]
	local function handleOperator(operator: string)
		local continues = false
		if operator == "(" or operator == "{" or operator == "[" then
			depth += 1
			if operator == "(" and typeofArmed then
				typeofDepth = depth
			end
			continues = true
		elseif operator == ")" or operator == "}" or operator == "]" then
			if typeMode and depth <= typeEntryDepth then
				exitTypeMode()
			end
			depth = math.max(depth - 1, 0)
			if typeofDepth ~= nil and depth < typeofDepth then
				typeofDepth = nil
			end
		elseif operator == "::" then
			enterTypeMode()
			continues = true
		elseif operator == "->" then
			if not typeMode then
				enterTypeMode()
			end
			continues = true
		elseif operator == ":" then
			if not typeMode and isAnnotationColon() then
				enterTypeMode()
			end
			continues = true
		elseif operator == "=" then
			if typeMode and depth <= typeEntryDepth and typeAngle == 0 then
				if aliasAwaitEquals then
					aliasAwaitEquals = false
				else
					exitTypeMode()
				end
			end
			continues = true
		elseif operator == "," or operator == ";" then
			if typeMode and depth <= typeEntryDepth and typeAngle == 0 then
				exitTypeMode()
			end
			continues = operator == ","
		elseif operator == "<" then
			if typeMode then
				typeAngle += 1
			end
			continues = true
		elseif operator == ">" then
			if typeMode and typeAngle > 0 then
				typeAngle -= 1
			end
		elseif operator == "|" or operator == "&" or operator == "." then
			continues = true
		end
		typeofArmed = false
		typeContinues = continues
		-- Continuing operators are exactly the ones a type word can follow,
		-- except the semicolon, which separates table type fields but never
		-- carries a context past a line break.
		typeExpectsWord = continues or operator == ";"
	end

	--[[
		Scans an at sign, taking the attribute name with it when one follows
		so @native lexes as a single token the way Luau's lexer reads it. A
		bare at sign, including the one that opens an @[...] attribute list,
		stays a lone operator.
	]]
	local function scanAttribute()
		typeofArmed = false
		typeContinues = false
		local start = index
		index += 1
		local nameByte = string.byte(source, index)
		if nameByte ~= nil and IS_IDEN_START[nameByte] then
			repeat
				index += 1
			until index > size or not IS_IDEN_CHAR[string.byte(source, index)]
			emit("keyword", string.sub(source, start, index - 1))
		else
			emit("operator", "@")
		end
	end

	--[[
		Scans an operator by dispatching on its first byte, checking longer
		lexemes before their prefixes so ..= wins over .. and a lone dot.
		Every emitted lexeme is an interned literal and the chain is ordered
		roughly by how often each family appears in real code, which keeps
		this path free of substring allocations and table lookups. Bytes that
		are not part of any operator become single-character iden tokens so
		the stream still covers them. The at sign never arrives here because
		the dispatcher sends it to the attribute path first, and neither do
		two dashes, which go to the comment scanner.
	]]
	local function scanOperator()
		local byte = string.byte(source, index)
		local nextByte = string.byte(source, index + 1)
		local operator: string? = nil

		if byte == BYTE_OPEN_PAREN then
			operator = "("
		elseif byte == BYTE_CLOSE_PAREN then
			operator = ")"
		elseif byte == BYTE_EQUALS then
			operator = if nextByte == BYTE_EQUALS then "==" else "="
		elseif byte == BYTE_DOT then
			if nextByte == BYTE_DOT then
				local thirdByte = string.byte(source, index + 2)
				operator = if thirdByte == BYTE_EQUALS then "..="
					elseif thirdByte == BYTE_DOT then "..."
					else ".."
			else
				operator = "."
			end
		elseif byte == BYTE_COMMA then
			operator = ","
		elseif byte == BYTE_COLON then
			operator = if nextByte == BYTE_COLON then "::" else ":"
		elseif byte == BYTE_OPEN_BRACE then
			operator = "{"
		elseif byte == BYTE_CLOSE_BRACE then
			operator = "}"
		elseif byte == BYTE_OPEN_BRACKET then
			operator = "["
		elseif byte == BYTE_CLOSE_BRACKET then
			operator = "]"
		elseif byte == BYTE_DASH then
			operator = if nextByte == BYTE_GREATER_THAN then "->"
				elseif nextByte == BYTE_EQUALS then "-="
				else "-"
		elseif byte == BYTE_PLUS then
			operator = if nextByte == BYTE_EQUALS then "+=" else "+"
		elseif byte == BYTE_STAR then
			operator = if nextByte == BYTE_EQUALS then "*=" else "*"
		elseif byte == BYTE_SLASH then
			if nextByte == BYTE_SLASH then
				operator = if string.byte(source, index + 2) == BYTE_EQUALS then "//=" else "//"
			else
				operator = if nextByte == BYTE_EQUALS then "/=" else "/"
			end
		elseif byte == BYTE_LESS_THAN then
			operator = if nextByte == BYTE_EQUALS then "<=" else "<"
		elseif byte == BYTE_GREATER_THAN then
			operator = if nextByte == BYTE_EQUALS then ">=" else ">"
		elseif byte == BYTE_TILDE then
			operator = if nextByte == BYTE_EQUALS then "~=" else "~"
		elseif byte == BYTE_PERCENT then
			operator = if nextByte == BYTE_EQUALS then "%=" else "%"
		elseif byte == BYTE_CARET then
			operator = if nextByte == BYTE_EQUALS then "^=" else "^"
		elseif byte == BYTE_SEMICOLON then
			operator = ";"
		elseif byte == BYTE_HASH then
			operator = "#"
		elseif byte == BYTE_QUESTION then
			operator = "?"
		elseif byte == BYTE_PIPE then
			operator = "|"
		elseif byte == BYTE_AMPERSAND then
			operator = "&"
		end

		if operator ~= nil then
			-- The rebind casts because the new solver leaves the nil check's
			-- intersection unsimplified instead of narrowing it to a string.
			local operatorText = operator :: string
			index += #operatorText
			emit("operator", operatorText)
			handleOperator(operatorText)
		else
			typeofArmed = false
			typeContinues = false
			emit("iden", string.sub(source, index, index))
			index += 1
		end
	end

	while index <= size do
		local byte = string.byte(source, index)
		if IS_SPACE[byte] then
			local start = index
			local sawNewline = byte == BYTE_NEWLINE
			while true do
				index += 1
				if index > size then
					break
				end
				local spaceByte = string.byte(source, index)
				if not IS_SPACE[spaceByte] then
					break
				end
				if spaceByte == BYTE_NEWLINE then
					sawNewline = true
				end
			end
			emitSuffix(string.sub(source, start, index - 1))
			if sawNewline then
				checkTypeNewline()
			end
		else
			-- This byte starts a token, so the state here is what a resumed
			-- scan would need. The point is restartable when every carried
			-- flag is in its ground state, since depth is seedable and the
			-- previous token texts come back from the navigator's cache. The
			-- watermark reserves slack for the fixed peeks the scan functions
			-- make past their consumed bytes.
			snapDepth = depth
			snapWatermark = math.max(maxRead, index + FIXED_PEEK_SLACK)
			snapRestartable = not typeMode
				and holeStack[1] == nil
				and not aliasNamePending
				and not typeofArmed
			if IS_IDEN_START[byte] then
				scanIden()
			elseif IS_DIGIT[byte]
				or (byte == BYTE_DOT and IS_DIGIT[string.byte(source, index + 1) or 0]) then
				scanNumber()
			elseif byte == BYTE_DASH and string.byte(source, index + 1) == BYTE_DASH then
				scanComment()
			elseif byte == BYTE_QUOTE or byte == BYTE_APOSTROPHE then
				scanQuoted(byte)
			elseif byte == BYTE_BACKTICK then
				if scanInterpPiece() == "hole" then
					table.insert(holeStack, depth)
				end
			elseif byte == BYTE_CLOSE_BRACE and holeStack[#holeStack] == depth then
				table.remove(holeStack)
				if typeMode and typeEntryDepth >= depth then
					exitTypeMode()
				end
				if scanInterpPiece() == "hole" then
					table.insert(holeStack, depth)
				end
			elseif byte == BYTE_OPEN_BRACKET then
				local level = matchLongOpen(index)
				if level ~= nil then
					scanLongBracket("string", index, level, index + level + 2)
				else
					scanOperator()
				end
			elseif byte == BYTE_AT then
				scanAttribute()
			else
				scanOperator()
			end
		end
	end

	-- The lingering snapshot belongs to the final token's own start, not to
	-- the position after it, so the final flush must not carry it. A restart
	-- at the very end of the source would have nothing to rescan anyway.
	snapRestartable = false
	flushQueued()
	if pendingPrefix ~= "" then
		yield("iden", pendingPrefix)
	end
end

--[[
	Creates a token iterator whose returns also carry restart snapshots, and
	which accepts a seed for resuming a scan partway through a source. The
	navigator reads through this richer form so HotswapSource can reuse
	cached tokens, and tests wrap it to observe where a resumed scan begins.
]]
function Lexer.scanRestartable(source: string, startIndex: number?, seed: Navigator.ScanSeed?): () -> (string?, string, number?, number?)
	local thread = coroutine.create(function()
		scanSource(source, coroutine.yield, startIndex, seed)
	end)

	return function(): (string?, string, number?, number?)
		if coroutine.status(thread) ~= "dead" then
			-- The type checks narrow resume's untyped results. The first two
			-- always pass since the scanner only yields string pairs, while
			-- the snapshot values are missing on most tokens.
			local success, kind, content, restartDepth, watermark = coroutine.resume(thread)
			if not success then
				-- A failed resume carries the scan's error in the kind slot,
				-- and it propagates rather than reading as a clean end of
				-- the source.
				error(kind, 0)
			end
			if type(kind) == "string" and type(content) == "string" then
				return
					kind,
					content,
					if type(restartDepth) == "number" then restartDepth else nil,
					if type(watermark) == "number" then watermark else nil
			end
		end
		return nil, "", nil, nil
	end
end

--[[
	Creates a token iterator over the given source. Each call to the
	returned function produces the next (kind, content) pair. When a
	startIndex is given, scanning begins at that byte with fresh context,
	so tokens whose meaning depends on what came earlier (type positions,
	interpolation holes, library members) may classify differently than
	they would in a full scan.
]]
function Lexer.scan(source: string, startIndex: number?): () -> (string?, string)
	local iterate = Lexer.scanRestartable(source, startIndex, nil)

	return function(): (string?, string)
		-- The wrapper drops the restart snapshot values so they never leak
		-- into callers reading extra returns.
		local kind, content = iterate()
		return kind, content
	end
end

--[[
	Calls onToken with every token of the source in order. This walks the
	same scanner as Lexer.scan without the iterator's coroutine, which makes
	it the cheapest way to read a whole source when tokens can be handled as
	they arrive. The extra optional parameters carry the restart snapshots
	the scanner attaches to some tokens, which callers are free to ignore.
]]
function Lexer.scanEach(source: string, onToken: (string, string, number?, number?) -> ())
	scanSource(source, onToken, nil, nil)
end

--[[
	Builds a token navigator supporting non-sequential reads over a source,
	caching scanned tokens so earlier ones can be revisited. The result
	erases to any here because the navigator table carries more members than
	the public TokenNavigator contract and the old solver has no width
	subtyping to bridge them.
]]
function Lexer.navigator(): any
	return Navigator.new(Lexer.scanRestartable)
end

return Lexer

end)() end,
    [33] = function()local wax,script,require=ImportGlobals(33)local ImportGlobals return (function(...)--!strict

--[[
	Static classification tables the scanner dispatches on. The language module
	holds the word tables, while this module holds raw byte values and byte
	class lookups. Operator lexemes and the type context words live inline in
	the scanner's comparison chains since nothing else reads them.
]]

-- Byte class lookups, indexed by byte value. Bytes at 128 and above are
-- treated as identifier characters so multibyte text lexes as idens.
local IS_SPACE: { [number]: boolean } = {}
local IS_DIGIT: { [number]: boolean } = {}
local IS_IDEN_START: { [number]: boolean } = {}
local IS_IDEN_CHAR: { [number]: boolean } = {}
local IS_NUMBER_TAIL: { [number]: boolean } = {}
for byteValue = 0, 255 do
	local char = string.char(byteValue)
	IS_SPACE[byteValue] = string.find(char, "[%c%s]") ~= nil
	IS_DIGIT[byteValue] = string.find(char, "%d") ~= nil
	IS_IDEN_START[byteValue] = string.find(char, "[%a_]") ~= nil or byteValue >= 128
	IS_IDEN_CHAR[byteValue] = string.find(char, "[%w_]") ~= nil or byteValue >= 128
	-- Number tails follow Luau's lexer, which greedily consumes trailing
	-- ASCII alphanumerics so malformed literals like 3px stay one token.
	IS_NUMBER_TAIL[byteValue] = string.find(char, "[%w_]") ~= nil
end

return {
	-- Byte values the dispatcher compares against directly.
	BYTE_NEWLINE = string.byte("\n"),
	BYTE_RETURN = string.byte("\r"),
	BYTE_QUOTE = string.byte('"'),
	BYTE_APOSTROPHE = string.byte("'"),
	BYTE_BACKTICK = string.byte("`"),
	BYTE_BACKSLASH = string.byte("\\"),
	BYTE_DASH = string.byte("-"),
	BYTE_PLUS = string.byte("+"),
	BYTE_STAR = string.byte("*"),
	BYTE_SLASH = string.byte("/"),
	BYTE_PERCENT = string.byte("%"),
	BYTE_CARET = string.byte("^"),
	BYTE_HASH = string.byte("#"),
	BYTE_TILDE = string.byte("~"),
	BYTE_DOT = string.byte("."),
	BYTE_COMMA = string.byte(","),
	BYTE_COLON = string.byte(":"),
	BYTE_SEMICOLON = string.byte(";"),
	BYTE_QUESTION = string.byte("?"),
	BYTE_PIPE = string.byte("|"),
	BYTE_AMPERSAND = string.byte("&"),
	BYTE_UNDERSCORE = string.byte("_"),
	BYTE_EQUALS = string.byte("="),
	BYTE_OPEN_PAREN = string.byte("("),
	BYTE_CLOSE_PAREN = string.byte(")"),
	BYTE_OPEN_BRACE = string.byte("{"),
	BYTE_CLOSE_BRACE = string.byte("}"),
	BYTE_OPEN_BRACKET = string.byte("["),
	BYTE_CLOSE_BRACKET = string.byte("]"),
	BYTE_LESS_THAN = string.byte("<"),
	BYTE_GREATER_THAN = string.byte(">"),
	BYTE_AT = string.byte("@"),
	BYTE_LOWER_E = string.byte("e"),
	BYTE_UPPER_E = string.byte("E"),
	BYTE_LOWER_U = string.byte("u"),
	BYTE_LOWER_Z = string.byte("z"),
	IS_SPACE = IS_SPACE,
	IS_DIGIT = IS_DIGIT,
	IS_IDEN_START = IS_IDEN_START,
	IS_IDEN_CHAR = IS_IDEN_CHAR,
	IS_NUMBER_TAIL = IS_NUMBER_TAIL,
}

end)() end,
    [34] = function()local wax,script,require=ImportGlobals(34)local ImportGlobals return (function(...)--!strict

--[[
	The word tables the scanner classifies identifiers with. Keywords, global
	builtins, and library members all live here.
]]

-- The indexer annotations let consumers look words up by arbitrary strings,
-- and let the Enum fill below add members the literal does not list.
type LanguageTable = {
	keyword: { [string]: string },
	builtin: { [string]: string },
	libraries: { [string]: { [string]: string } },
}

local Language: LanguageTable = {
	keyword = {
		["and"] = "keyword",
		["break"] = "keyword",
		["continue"] = "keyword",
		["do"] = "keyword",
		["else"] = "keyword",
		["elseif"] = "keyword",
		["end"] = "keyword",
		["export"] = "keyword",
		["false"] = "keyword",
		["for"] = "keyword",
		["function"] = "keyword",
		["if"] = "keyword",
		["in"] = "keyword",
		["local"] = "keyword",
		["nil"] = "keyword",
		["not"] = "keyword",
		["or"] = "keyword",
		["repeat"] = "keyword",
		["return"] = "keyword",
		["self"] = "keyword",
		["then"] = "keyword",
		["true"] = "keyword",
		["type"] = "keyword",
		["typeof"] = "keyword",
		["until"] = "keyword",
		["while"] = "keyword",
	},
	builtin = {
		-- These are the global functions Luau itself provides.
		["assert"] = "function",
		["error"] = "function",
		["getfenv"] = "function",
		["getmetatable"] = "function",
		["ipairs"] = "function",
		["loadstring"] = "function",
		["newproxy"] = "function",
		["next"] = "function",
		["pairs"] = "function",
		["pcall"] = "function",
		["print"] = "function",
		["rawequal"] = "function",
		["rawget"] = "function",
		["rawlen"] = "function",
		["rawset"] = "function",
		["select"] = "function",
		["setfenv"] = "function",
		["setmetatable"] = "function",
		["tonumber"] = "function",
		["tostring"] = "function",
		["unpack"] = "function",
		["xpcall"] = "function",
		-- Luau deprecated collectgarbage but still exposes it.
		["collectgarbage"] = "function",
		-- Luau exposes these variables globally.
		["_G"] = "table",
		["_VERSION"] = "string",
		-- These tables are Luau's standard libraries.
		["bit32"] = "table",
		["buffer"] = "table",
		["coroutine"] = "table",
		["debug"] = "table",
		["math"] = "table",
		["os"] = "table",
		["string"] = "table",
		["table"] = "table",
		["utf8"] = "table",
		["vector"] = "table",
		-- Roblox adds these global functions.
		["DebuggerManager"] = "function",
		["delay"] = "function",
		["gcinfo"] = "function",
		["PluginManager"] = "function",
		["require"] = "function",
		["settings"] = "function",
		["spawn"] = "function",
		["tick"] = "function",
		["time"] = "function",
		["UserSettings"] = "function",
		["wait"] = "function",
		["warn"] = "function",
		-- Roblox deprecated these functions but still exposes them.
		["Delay"] = "function",
		["ElapsedTime"] = "function",
		["elapsedTime"] = "function",
		["printidentity"] = "function",
		["Spawn"] = "function",
		["Stats"] = "function",
		["stats"] = "function",
		["Version"] = "function",
		["version"] = "function",
		["Wait"] = "function",
		["ypcall"] = "function",
		-- Roblox exposes these Instances as globals.
		["game"] = "Instance",
		["plugin"] = "Instance",
		["script"] = "Instance",
		["shared"] = "Instance",
		["workspace"] = "Instance",
		-- Roblox deprecated these globals but still exposes them.
		["Game"] = "Instance",
		["Workspace"] = "Instance",
		-- These tables build Roblox data types.
		["Axes"] = "table",
		["BrickColor"] = "table",
		["CatalogSearchParams"] = "table",
		["CFrame"] = "table",
		["Color3"] = "table",
		["ColorSequence"] = "table",
		["ColorSequenceKeypoint"] = "table",
		["DateTime"] = "table",
		["DockWidgetPluginGuiInfo"] = "table",
		["Enum"] = "table",
		["Faces"] = "table",
		["FloatCurveKey"] = "table",
		["Font"] = "table",
		["Instance"] = "table",
		["NumberRange"] = "table",
		["NumberSequence"] = "table",
		["NumberSequenceKeypoint"] = "table",
		["OverlapParams"] = "table",
		["PathWaypoint"] = "table",
		["PhysicalProperties"] = "table",
		["Random"] = "table",
		["Ray"] = "table",
		["RaycastParams"] = "table",
		["Rect"] = "table",
		["Region3"] = "table",
		["Region3int16"] = "table",
		["RotationCurveKey"] = "table",
		["SharedTable"] = "table",
		["task"] = "table",
		["TweenInfo"] = "table",
		["UDim"] = "table",
		["UDim2"] = "table",
		["Vector2"] = "table",
		["Vector2int16"] = "table",
		["Vector3"] = "table",
		["Vector3int16"] = "table",
	},
	libraries = {
		-- These are the member tables of Luau's standard libraries.
		bit32 = {
			arshift = "function",
			band = "function",
			bnot = "function",
			bor = "function",
			btest = "function",
			bxor = "function",
			countlz = "function",
			countrz = "function",
			extract = "function",
			lrotate = "function",
			lshift = "function",
			replace = "function",
			rrotate = "function",
			rshift = "function",
		},
		buffer = {
			copy = "function",
			create = "function",
			fill = "function",
			fromstring = "function",
			len = "function",
			readbits = "function",
			writebits = "function",
			readf32 = "function",
			readf64 = "function",
			readi8 = "function",
			readi16 = "function",
			readi32 = "function",
			readu16 = "function",
			readu32 = "function",
			readu8 = "function",
			readstring = "function",
			tostring = "function",
			writef32 = "function",
			writef64 = "function",
			writei16 = "function",
			writei32 = "function",
			writei8 = "function",
			writestring = "function",
			writeu16 = "function",
			writeu32 = "function",
			writeu8 = "function",
		},
		coroutine = {
			close = "function",
			create = "function",
			isyieldable = "function",
			resume = "function",
			running = "function",
			status = "function",
			wrap = "function",
			yield = "function",
		},
		debug = {
			dumpheap = "function",
			getmemorycategory = "function",
			info = "function",
			loadmodule = "function",
			profilebegin = "function",
			profileend = "function",
			resetmemorycategory = "function",
			setmemorycategory = "function",
			traceback = "function",
		},
		math = {
			abs = "function",
			acos = "function",
			asin = "function",
			atan2 = "function",
			atan = "function",
			ceil = "function",
			clamp = "function",
			cos = "function",
			cosh = "function",
			deg = "function",
			exp = "function",
			floor = "function",
			fmod = "function",
			frexp = "function",
			ldexp = "function",
			lerp = "function",
			log10 = "function",
			log = "function",
			map = "function",
			max = "function",
			min = "function",
			modf = "function",
			noise = "function",
			pow = "function",
			rad = "function",
			random = "function",
			randomseed = "function",
			round = "function",
			sign = "function",
			sin = "function",
			sinh = "function",
			sqrt = "function",
			tan = "function",
			tanh = "function",
			huge = "number",
			pi = "number",
		},
		os = {
			clock = "function",
			date = "function",
			difftime = "function",
			time = "function",
		},
		string = {
			byte = "function",
			char = "function",
			find = "function",
			format = "function",
			gmatch = "function",
			gsub = "function",
			len = "function",
			lower = "function",
			match = "function",
			pack = "function",
			packsize = "function",
			rep = "function",
			reverse = "function",
			split = "function",
			sub = "function",
			unpack = "function",
			upper = "function",
		},
		table = {
			clear = "function",
			clone = "function",
			concat = "function",
			create = "function",
			find = "function",
			foreach = "function",
			foreachi = "function",
			freeze = "function",
			getn = "function",
			insert = "function",
			isfrozen = "function",
			maxn = "function",
			move = "function",
			pack = "function",
			remove = "function",
			sort = "function",
			unpack = "function",
		},
		utf8 = {
			char = "function",
			codepoint = "function",
			codes = "function",
			graphemes = "function",
			len = "function",
			nfcnormalize = "function",
			nfdnormalize = "function",
			offset = "function",
			charpattern = "string",
		},
		vector = {
			abs = "function",
			angle = "function",
			ceil = "function",
			clamp = "function",
			create = "function",
			cross = "function",
			dot = "function",
			floor = "function",
			magnitude = "function",
			max = "function",
			min = "function",
			normalize = "function",
			sign = "function",
			one = "vector",
			zero = "vector",
		},
		-- These are the member tables of the Roblox globals above.
		Axes = {
			new = "function",
		},
		BrickColor = {
			Black = "function",
			Blue = "function",
			DarkGray = "function",
			Gray = "function",
			Green = "function",
			new = "function",
			New = "function",
			palette = "function",
			Random = "function",
			random = "function",
			Red = "function",
			White = "function",
			Yellow = "function",
		},
		CatalogSearchParams = {
			new = "function",
		},
		CFrame = {
			Angles = "function",
			fromAxisAngle = "function",
			fromEulerAngles = "function",
			fromEulerAnglesXYZ = "function",
			fromEulerAnglesYXZ = "function",
			fromMatrix = "function",
			fromOrientation = "function",
			lookAt = "function",
			new = "function",
			identity = "CFrame",
		},
		Color3 = {
			fromHex = "function",
			fromHSV = "function",
			fromRGB = "function",
			new = "function",
			toHSV = "function",
		},
		ColorSequence = {
			new = "function",
		},
		ColorSequenceKeypoint = {
			new = "function",
		},
		DateTime = {
			fromIsoDate = "function",
			fromLocalTime = "function",
			fromUniversalTime = "function",
			fromUnixTimestamp = "function",
			fromUnixTimestampMillis = "function",
			now = "function",
		},
		DockWidgetPluginGuiInfo = {
			new = "function",
		},
		Enum = {},
		Faces = {
			new = "function",
		},
		FloatCurveKey = {
			new = "function",
		},
		Font = {
			fromEnum = "function",
			fromId = "function",
			fromName = "function",
			new = "function",
		},
		Instance = {
			new = "function",
		},
		NumberRange = {
			new = "function",
		},
		NumberSequence = {
			new = "function",
		},
		NumberSequenceKeypoint = {
			new = "function",
		},
		OverlapParams = {
			new = "function",
		},
		PathWaypoint = {
			new = "function",
		},
		PhysicalProperties = {
			new = "function",
		},
		Random = {
			new = "function",
		},
		Ray = {
			new = "function",
		},
		RaycastParams = {
			new = "function",
		},
		Rect = {
			new = "function",
		},
		Region3 = {
			new = "function",
		},
		Region3int16 = {
			new = "function",
		},
		RotationCurveKey = {
			new = "function",
		},
		SharedTable = {
			clear = "function",
			clone = "function",
			cloneAndFreeze = "function",
			increment = "function",
			isFrozen = "function",
			new = "function",
			size = "function",
			update = "function",
		},
		task = {
			cancel = "function",
			defer = "function",
			delay = "function",
			desynchronize = "function",
			spawn = "function",
			synchronize = "function",
			wait = "function",
		},
		TweenInfo = {
			new = "function",
		},
		UDim = {
			new = "function",
		},
		UDim2 = {
			fromOffset = "function",
			fromScale = "function",
			new = "function",
		},
		Vector2 = {
			new = "function",
			one = "Vector2",
			xAxis = "Vector2",
			yAxis = "Vector2",
			zero = "Vector2",
		},
		Vector2int16 = {
			new = "function",
		},
		Vector3 = {
			fromAxis = "function",
			FromAxis = "function",
			fromNormalId = "function",
			FromNormalId = "function",
			new = "function",
			one = "Vector3",
			xAxis = "Vector3",
			yAxis = "Vector3",
			zAxis = "Vector3",
			zero = "Vector3",
		},
		Vector3int16 = {
			new = "function",
		},
	},
}

-- The Enum library members come from the engine,
-- so this fill is pcalled to silently skip in Lune/Lute/etc.
local enumLibraryTable = Language.libraries.Enum

pcall(function()
	for _, enum in ipairs(Enum:GetEnums()) do
		enumLibraryTable[tostring(enum)] = "Enum"
	end
end)

return Language

end)() end,
    [35] = function()local wax,script,require=ImportGlobals(35)local ImportGlobals return (function(...)--!strict

--[[
	A token navigator supporting non-sequential reads over a source, caching
	scanned tokens so earlier ones can be revisited. The lexer's scan function
	arrives through Navigator.new, which keeps this module from requiring its
	parent and forming a cycle. When the scan function reports restart
	snapshots, HotswapSource keeps every cached token the edit provably left
	untouched and resumes scanning from there instead of re-lexing everything.
]]

-- The scanner state a resumed scan needs beyond its start position. The
-- depth comes from a restart snapshot and the previous token contents come
-- back out of the token cache.
export type ScanSeed = {
	depth: number,
	previous1: string,
	previous2: string,
	previous3: string,
}

type ScanFunction = (src: string, startIndex: number?, seed: ScanSeed?) -> () -> (string?, string, number?, number?)

-- How many bytes the common prefix measurement compares at a time before
-- falling back to single bytes inside the first chunk that differs.
local PREFIX_CHUNK = 256

local Navigator = {}

--[[
	Measures the longest shared byte prefix of two strings. Whole chunks
	compare first so large untouched heads go quickly, then the first chunk
	that differs walks byte by byte to the exact split point.
]]
local function commonPrefixLength(a: string, b: string): number
	local limit = math.min(#a, #b)
	local matched = 0
	while matched + PREFIX_CHUNK <= limit
		and string.sub(a, matched + 1, matched + PREFIX_CHUNK)
			== string.sub(b, matched + 1, matched + PREFIX_CHUNK) do
		matched += PREFIX_CHUNK
	end
	while matched < limit and string.byte(a, matched + 1) == string.byte(b, matched + 1) do
		matched += 1
	end
	return matched
end

--[[
	Builds a navigator that reads tokens through the given scan function.
	Every method except Destroy closes over nav instead of reading through
	self because the new solver types self generically there, which blocks
	compound assignment, widens the token cache, and rejects internal calls
	between methods. The ignored parameter keeps them callable as methods
	alongside the rest.
]]
function Navigator.new(scan: ScanFunction)
	local nav = {
		source = "",
		realIndex = 0,
		userIndex = 0,
		scanThread = nil :: thread?,
		-- Token storage and restart bookkeeping live in parallel flat
		-- arrays so appending a token allocates no per token table and the
		-- cache stays cheap for the garbage collector to trace. tokenKinds
		-- and tokenContents hold each token's two halves. endOffsets holds
		-- each token's cumulative byte length, so endOffsets[k] + 1 is
		-- where the token after k starts. restartDepths holds the bracket
		-- depth right after a token and restartWatermarks the furthest byte
		-- the scan had read by that point, lookahead included. Tokens the
		-- scan cannot resume after store zero in both, and since a real
		-- watermark always covers at least the first token plus its peek
		-- slack, a zero watermark alone marks the absent snapshot.
		tokenKinds = table.create(50) :: { string },
		tokenContents = table.create(50) :: { string },
		endOffsets = table.create(50) :: { number },
		restartDepths = table.create(50) :: { number },
		restartWatermarks = table.create(50) :: { number },
	}

	--[[
		Builds the coroutine that pulls tokens from a scan of the current
		source and appends them, with their restart bookkeeping, onto the
		cache. A scan function that never reports snapshots just fills the
		cache with no restart points, which makes hotswapping fall back to a
		full rescan.
	]]
	local function buildScanThread(startIndex: number?, seed: ScanSeed?): thread
		return coroutine.create(function()
			for token, content, restartDepth, watermark in scan(nav.source, startIndex, seed) do
				local tokenIndex = nav.realIndex + 1
				nav.realIndex = tokenIndex
				nav.tokenKinds[tokenIndex] = token
				nav.tokenContents[tokenIndex] = content
				nav.endOffsets[tokenIndex] = (nav.endOffsets[tokenIndex - 1] or 0) + #content
				if restartDepth ~= nil and watermark ~= nil then
					nav.restartDepths[tokenIndex] = restartDepth
					nav.restartWatermarks[tokenIndex] = watermark
				else
					nav.restartDepths[tokenIndex] = 0
					nav.restartWatermarks[tokenIndex] = 0
				end
				coroutine.yield(token, content)
			end
		end)
	end

	--[[
		Resumes the scan until the cache reaches goalIndex or the scan runs
		out of tokens. A failed resume carries the scan's error, and it
		propagates rather than masquerading as a clean end of the stream and
		silently truncating whatever the caller is building.
	]]
	local function fillTo(goalIndex: number)
		local scanThread = nav.scanThread
		if scanThread == nil then
			return
		end
		while nav.realIndex < goalIndex and coroutine.status(scanThread) ~= "dead" do
			local success, message = coroutine.resume(scanThread)
			if not success then
				error(message, 0)
			end
		end
	end

	--[[
		Clears every field so a discarded navigator keeps nothing alive.
	]]
	function nav:Destroy()
		self.source = nil
		self.realIndex = nil
		self.userIndex = nil
		self.scanThread = nil
		self.tokenKinds = nil
		self.tokenContents = nil
		self.endOffsets = nil
		self.restartDepths = nil
		self.restartWatermarks = nil
	end

	--[[
		Points the navigator at a new source, dropping every cached token
		and starting a fresh scan from the beginning.
	]]
	function nav.SetSource(_self: any, sourceString: string)
		nav.source = sourceString

		nav.realIndex = 0
		nav.userIndex = 0
		table.clear(nav.tokenKinds)
		table.clear(nav.tokenContents)
		table.clear(nav.endOffsets)
		table.clear(nav.restartDepths)
		table.clear(nav.restartWatermarks)

		nav.scanThread = buildScanThread(nil, nil)
	end

	--[[
		Swaps in an edited source while keeping every cached token the edit
		provably left untouched, resuming the scan from the latest restart
		snapshot inside the shared prefix. Returns how many leading bytes of
		the new source the kept tokens cover, which is the prefix whose
		tokenization provably matches the previous source. An identical swap
		reports the whole source and the full rescan fallback reports zero.
	]]
	function nav.HotswapSource(_self: any, sourceString: string): number
		if sourceString == nav.source then
			nav.userIndex = 0
			return #sourceString
		end

		-- A cached token stays valid for the new source when everything the
		-- scanner read to produce it, lookahead included, lies inside the
		-- shared prefix. The scan resumes right after the latest such token
		-- that also carries a restart snapshot, since tokens without one
		-- ended somewhere the scanner state cannot be rebuilt, like inside
		-- a type context or an open interpolation hole.
		local sharedPrefix = commonPrefixLength(nav.source, sourceString)

		-- A token's watermark always reaches past its own bytes, so every
		-- token ending beyond the shared prefix is guaranteed to fail the
		-- check below. Binary searching the end offsets for the last token
		-- ending inside the prefix bounds the walk to candidates that can
		-- actually qualify, which keeps a head edit from walking the whole
		-- cache one token at a time.
		local low, high = 1, nav.realIndex
		local candidate = 0
		while low <= high do
			local mid = math.floor((low + high) / 2)
			if nav.endOffsets[mid] <= sharedPrefix then
				candidate = mid
				low = mid + 1
			else
				high = mid - 1
			end
		end

		local restartToken = 0
		while candidate > 0 do
			-- A zero watermark marks a token with no snapshot, and it needs
			-- its own check because zero always sits inside the prefix.
			local watermark = nav.restartWatermarks[candidate]
			if watermark ~= 0 and watermark <= sharedPrefix then
				restartToken = candidate
				break
			end
			candidate -= 1
		end

		if restartToken == 0 then
			nav:SetSource(sourceString)
			return 0
		end

		for stale = nav.realIndex, restartToken + 1, -1 do
			nav.tokenKinds[stale] = nil
			nav.tokenContents[stale] = nil
			nav.endOffsets[stale] = nil
			nav.restartDepths[stale] = nil
			nav.restartWatermarks[stale] = nil
		end
		nav.realIndex = restartToken
		nav.userIndex = 0
		nav.source = sourceString

		local contents = nav.tokenContents
		local seed: ScanSeed = {
			depth = nav.restartDepths[restartToken],
			previous1 = contents[restartToken],
			previous2 = contents[restartToken - 1] or "",
			previous3 = contents[restartToken - 2] or "",
		}
		nav.scanThread = buildScanThread(nav.endOffsets[restartToken] + 1, seed)
		return nav.endOffsets[restartToken]
	end

	--[[
		Moves the read position so the next Next returns the token containing
		the given byte, and returns how many bytes of that token sit before
		the byte so the caller can trim them off the first read. The position
		must lie inside the scanned bytes or exactly one past them, where the
		next read simply resumes the scan. Peeks keep returning whole tokens,
		since the trim is the caller's to apply.
	]]
	function nav.SeekToByte(_self: any, position: number): number
		-- A binary search over the cumulative end offsets finds the last
		-- token that ends before the position.
		local low, high = 1, nav.realIndex
		local before = 0
		while low <= high do
			local mid = math.floor((low + high) / 2)
			if nav.endOffsets[mid] < position then
				before = mid
				low = mid + 1
			else
				high = mid - 1
			end
		end
		nav.userIndex = before
		return position - 1 - (nav.endOffsets[before] or 0)
	end

	--[[
		Advances to the next token and returns it, reading from the cache
		when the position sits behind the scan.
	]]
	function nav.Next(_self: any): ...string?
		-- The position only advances when a token actually comes back, so
		-- reads past the end never drift where relative Peeks resolve.
		local goalIndex = nav.userIndex + 1
		if nav.realIndex < goalIndex then
			fillTo(goalIndex)
		end
		if nav.realIndex >= goalIndex then
			nav.userIndex = goalIndex
			return nav.tokenKinds[goalIndex], nav.tokenContents[goalIndex]
		end
		return
	end

	--[[
		Returns the token peekAmount away from the current position without
		moving it, scanning forward on demand. Peeks landing outside the
		token range return nothing.
	]]
	function nav.Peek(_self: any, peekAmount: number): ...string?
		local goalIndex = nav.userIndex + peekAmount
		if goalIndex <= 0 then
			return
		end
		if nav.realIndex < goalIndex then
			fillTo(goalIndex)
		end
		if nav.realIndex >= goalIndex then
			return nav.tokenKinds[goalIndex], nav.tokenContents[goalIndex]
		end
		return
	end

	return nav
end

return Navigator

end)() end,
    [36] = function()local wax,script,require=ImportGlobals(36)local ImportGlobals return (function(...)---	Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy
-- @classmod Maid
-- @see Signal

local Maid = {}
Maid.ClassName = "Maid"

--- Returns a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
	return setmetatable(
		{
			_tasks = {},
		},
		Maid
	)
end

function Maid.isMaid(value)
	return type(value) == "table" and value.ClassName == "Maid"
end

--- Returns Maid[key] if not part of Maid metatable
-- @return Maid[key] value
function Maid:__index(index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

--- Add a task to clean up. Tasks given to a maid will be cleaned when
--  maid[index] is set to a different value.
-- @usage
-- Maid[key] = (function)         Adds a task to perform
-- Maid[key] = (event connection) Manages an event connection
-- Maid[key] = (Maid)             Maids can act as an event connection, allowing a Maid to have other maids to clean up.
-- Maid[key] = (Object)           Maids can cleanup objects with a `Destroy` method
-- Maid[key] = nil                Removes a named task. If the task is an event, it is disconnected. If it is an object,
--                                it is destroyed.
function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == newTask then
		return
	end

	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect()
		elseif oldTask.Destroy then
			oldTask:Destroy()
		end
	end
end

--- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
	if not task then
		error("Task cannot be false or nil", 2)
	end

	local taskId = #self._tasks + 1
	self[taskId] = task

	return taskId
end

function Maid:GivePromise(promise)
	if not promise:IsPending() then
		return promise
	end

	local newPromise = promise.resolved(promise)
	local id = self:GiveTask(newPromise)

	-- Ensure GC
	newPromise:Finally(function()
		self[id] = nil
	end)

	return newPromise
end

--- Cleans up all tasks.
-- @alias Destroy
function Maid:DoCleaning()
	local tasks = self._tasks
	local firstError = nil
	local attempted = {}

	local function cleanTask(index, task)
		attempted[index] = task
		local success, message = pcall(function()
			if type(task) == "function" then
				task()
			elseif typeof(task) == "RBXScriptConnection" then
				task:Disconnect()
			elseif task.Destroy then
				task:Destroy()
			end
		end)
		if success then
			if tasks[index] == task then
				tasks[index] = nil
			end
		elseif firstError == nil then
			firstError = message
		end
	end

	-- Prefer disconnecting events before other work, while retaining any task
	-- that fails so a later DoCleaning() can retry it.
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			cleanTask(index, task)
		end
	end

	-- Cleanup callbacks may enqueue more work. Keep draining newly-added tasks
	-- in this pass, but do not spin on a task that already failed once.
	while true do
		local foundNewTask = false
		for index, task in pairs(tasks) do
			if attempted[index] ~= task then
				foundNewTask = true
				cleanTask(index, task)
			end
		end
		if not foundNewTask then
			break
		end
	end

	if firstError ~= nil then
		error(firstError, 0)
	end
end

--- Alias for DoCleaning()
-- @function Destroy
Maid.Destroy = Maid.DoCleaning

return Maid

end)() end,
    [37] = function()local wax,script,require=ImportGlobals(37)local ImportGlobals return (function(...)local service = setmetatable(
	{},
	{
		__index = function(self, serviceName)
			local o, s = pcall(Instance.new, serviceName)
			local Service = o and s
				or game:GetService(serviceName)
				or settings():GetService(serviceName)
				or UserSettings():GetService(serviceName)

			if cloneref then
				Service = cloneref(Service)
			end
			if Service then
				self[serviceName] = Service
			end
			return Service
		end,
	}
)
return service

end)() end,
    [38] = function()local wax,script,require=ImportGlobals(38)local ImportGlobals return (function(...)local Root = script.Parent.Parent
local Internal = require(Root.packages.internal)

local scope = Internal.Scope

return {
	Theme = scope:Value("eclipse"),
	EffectiveDPIScale = scope:Value(1),
	AnimationsEnabled = scope:Value(true),
	ServerConnected = scope:Value(false),
	ServerConnecting = scope:Value(false),
	ServerAuthenticating = scope:Value(false),
	AgentNeedsAttention = scope:Value(false),
	Keybinds = scope:Value({}),
	ActiveKeybinds = scope:Value({}),
}

end)() end,
    [40] = function()local wax,script,require=ImportGlobals(40)local ImportGlobals return (function(...)-- Catppuccin for VS Code's token colors; pinned sources and licenses:
-- assets/vendor/catppuccin/README.md
local ColorSpace = require(script.Parent.Parent.utils.colorSpace)

local MOCHA = table.freeze({
	iden = Color3.fromHex("cdd6f4"),
	punctuation = Color3.fromHex("9399b2"),
	comment = Color3.fromHex("9399b2"),
	keyword = Color3.fromHex("cba6f7"),
	["function"] = Color3.fromHex("89b4fa"),
	type = Color3.fromHex("f9e2af"),
	string = Color3.fromHex("a6e3a1"),
	number = Color3.fromHex("fab387"),
	constant = Color3.fromHex("fab387"),
	operator = Color3.fromHex("94e2d5"),
	property = Color3.fromHex("94e2d5"),
	parameter = Color3.fromHex("eba0ac"),
	builtin = Color3.fromHex("eba0ac"),
	self = Color3.fromHex("f38ba8"),
})

local LATTE = table.freeze({
	iden = Color3.fromHex("4c4f69"),
	punctuation = Color3.fromHex("7c7f93"),
	comment = Color3.fromHex("7c7f93"),
	keyword = Color3.fromHex("8839ef"),
	["function"] = Color3.fromHex("1e66f5"),
	type = Color3.fromHex("df8e1d"),
	string = Color3.fromHex("40a02b"),
	number = Color3.fromHex("fe640b"),
	constant = Color3.fromHex("fe640b"),
	operator = Color3.fromHex("179299"),
	property = Color3.fromHex("179299"),
	parameter = Color3.fromHex("e64553"),
	builtin = Color3.fromHex("e64553"),
	self = Color3.fromHex("d20f39"),
})

return function(background: Color3)
	return if ColorSpace.Oklch.From(background):IsDark() then MOCHA else LATTE
end

end)() end,
    [41] = function()local wax,script,require=ImportGlobals(41)local ImportGlobals return (function(...)--[[
	A Luau code view and editor: line numbers, syntax colours and a scrolling surface. Read-only
	views still select text for copying. Editing follows react-simple-code-editor (MIT, behaviour
	only): Tab indents, Shift+Tab outdents, Enter keeps the line's indentation, Ctrl+Z and Ctrl+Y
	undo and redo (100 steps, typing within a second merges). Colours show while the box isn't
	focused; while typing the text is plain, because a Roblox TextBox can't colour its own text.

	props: Text (a Value the view reads and, when editable, writes), Editable?, Placeholder?,
	LayoutOrder?, Size?, Name?.
]]

local UserInputService = game:GetService("UserInputService")

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Theme = require(Root.ui.tokens)
local Fonts = require(Root.ui.fonts)
local Surface = require(script.Parent.controls.surface)
local CodeTheme = require(script.Parent.codeTheme)
local LuauHighlight = require(Root.utils.luauHighlight)

local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local TEXT_SIZE = 13
local PAD = 12
local DIGIT = 8
-- Past this the label would blow Roblox's text limits with colour tags; show it plain.
local HIGHLIGHT_LIMIT = 20000
local HISTORY_LIMIT = 100
local MERGE_SECONDS = 1
local ESCAPES = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
	['"'] = "&quot;",
	["'"] = "&apos;",
}

local CodeView = {}

function CodeView.richText(source: string, colors): string
	local lines = {}
	for index, tokens in LuauHighlight(source) do
		local parts = {}
		for _, token in tokens do
			local text = string.gsub(token.Text, "[&<>\"']", ESCAPES)
			local color = colors[token.Kind] or colors.iden
			table.insert(parts, `<font color="#{color:ToHex()}">{text}</font>`)
		end
		lines[index] = table.concat(parts)
	end
	return table.concat(lines, "\n")
end

function CodeView.keyEdit(text: string, cursor: number, key: Enum.KeyCode, shift: boolean): (string?, number?)
	local before, after = string.sub(text, 1, cursor - 1), string.sub(text, cursor)
	local lineStart = (string.find(before, "\n[^\n]*$") or 0) + 1
	if key == Enum.KeyCode.Tab and not shift then
		return before .. "\t" .. after, cursor + 1
	elseif key == Enum.KeyCode.Tab and shift then
		if string.sub(text, lineStart, lineStart) == "\t" then
			return
				string.sub(text, 1, lineStart - 1) .. string.sub(text, lineStart + 1),
				math.max(lineStart, cursor - 1)
		end
		return nil
	end
	return nil
end

function CodeView.indentNewline(text: string, cursor: number): (string, number)
	local before = string.sub(text, 1, cursor - 2)
	local previous = string.match(before, "([^\n]*)$") or ""
	local indent = string.match(previous, "^[ \t]*") or ""
	if indent == "" then
		return text, cursor
	end
	return string.sub(text, 1, cursor - 1) .. indent .. string.sub(text, cursor), cursor + #indent
end

function CodeView.new(scope, props)
	local text = props.Text
	local editable = props.Editable
	local focused = scope:Value(false)
	local colors = scope:Computed(function(use)
		return CodeTheme(use(Theme.Surface))
	end)
	local lineCount = scope:Computed(function(use)
		return select(2, string.gsub(use(text), "\n", "")) + 1
	end)
	local gutter = scope:Computed(function(use)
		return #tostring(use(lineCount)) * DIGIT + PAD + 4
	end)
	local function isEditable(use)
		return if editable == nil then false
			elseif type(editable) == "boolean" then editable
			else use(editable)
	end

	local history = { { Text = peek(text), Cursor = 1, At = 0 } }
	local at = 1
	local applying = false
	local box: TextBox

	local function remember(value: string, cursor: number, merge: boolean)
		local now = os.clock()
		for index = #history, at + 1, -1 do
			history[index] = nil
		end
		local last = history[at]
		if last and last.Text == value then
			return
		end
		if merge and last and at > 1 and now - last.At < MERGE_SECONDS then
			history[at] = { Text = value, Cursor = cursor, At = now }
		else
			table.insert(history, { Text = value, Cursor = cursor, At = now })
			if #history > HISTORY_LIMIT then
				table.remove(history, 1)
			end
			at = #history
		end
	end

	local function apply(value: string, cursor: number)
		applying = true
		box.Text = value
		box.CursorPosition = cursor
		applying = false
		text:set(value)
	end

	local lastText = peek(text)
	box = scope:New("TextBox")({
		Name = "Code",
		Position = scope:Computed(function(use)
			return UDim2.fromOffset(use(gutter), 0)
		end),
		Size = scope:Computed(function(use)
			return UDim2.new(1, -use(gutter), 1, 0)
		end),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		MultiLine = true,
		TextEditable = scope:Computed(isEditable),
		Text = peek(text),
		PlaceholderText = props.Placeholder or "",
		PlaceholderColor3 = Theme.Faint,
		FontFace = Fonts.Mono,
		TextSize = TEXT_SIZE,
		TextColor3 = Theme.Ink2,
		TextTransparency = scope:Computed(function(use)
			local long = #use(text) > HIGHLIGHT_LIMIT
			return if use(focused) or long then 0 else 1
		end),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		SelectionImageObject = nil,
		ZIndex = 2,
		[OnEvent("Focused")] = function()
			focused:set(true)
		end,
		[OnEvent("FocusLost")] = function()
			focused:set(false)
		end,
		[OnChange("Text")] = function(value)
			if applying or value == lastText then
				lastText = value
				return
			end
			local cursor = box.CursorPosition
			if #value == #lastText + 1 and string.sub(value, cursor - 1, cursor - 1) == "\n" then
				local indented, moved = CodeView.indentNewline(value, cursor)
				if indented ~= value then
					lastText = indented
					apply(indented, moved)
					remember(indented, moved, false)
					return
				end
			end
			lastText = value
			text:set(value)
			remember(value, cursor, true)
		end,
	})
	table.insert(
		scope,
		scope:Observer(text):onChange(function()
			local value = peek(text)
			if value ~= box.Text then
				lastText = value
				applying = true
				box.Text = value
				applying = false
				history, at = { { Text = value, Cursor = 1, At = 0 } }, 1
			end
		end)
	)
	table.insert(
		scope,
		UserInputService.InputBegan:Connect(
			function(input)
				if not box:IsFocused()
					or not box.TextEditable
					or input.UserInputType ~= Enum.UserInputType.Keyboard then
					return
				end
				local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
					or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
				local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
					or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
				if ctrl and (input.KeyCode == Enum.KeyCode.Z or input.KeyCode == Enum.KeyCode.Y) then
					local redo = input.KeyCode == Enum.KeyCode.Y or shift
					local target = if redo then at + 1 else at - 1
					local entry = history[target]
					if entry then
						at = target
						task.defer(function()
							lastText = entry.Text
							apply(entry.Text, entry.Cursor)
						end)
					end
					return
				end
				if input.KeyCode == Enum.KeyCode.Tab then
					local before = box.Text
					local cursor = box.CursorPosition
					task.defer(
						function()
							-- The TextBox may have moved focus or typed a tab itself; start from what it had.
							local value, moved = CodeView.keyEdit(
								before,
								cursor,
								Enum.KeyCode.Tab,
								shift
							)
							if value then
								lastText = value
								apply(value, moved)
								remember(value, moved, false)
								if not box:IsFocused() then
									box:CaptureFocus()
									box.CursorPosition = moved
								end
							end
						end
					)
				end
			end
		)
	)

	local scroll = scope:New("ScrollingFrame")({
		Name = "Scroll",
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.XY,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Ink,
		ScrollBarImageTransparency = 0.82,
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, PAD),
				PaddingBottom = UDim.new(0, PAD),
				PaddingRight = UDim.new(0, PAD),
			}),
			scope:New("TextLabel")({
				Name = "Lines",
				Size = scope:Computed(function(use)
					return UDim2.new(0, use(gutter) - PAD, 1, 0)
				end),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text = scope:Computed(function(use)
					local numbers = table.create(use(lineCount))
					for index = 1, use(lineCount) do
						numbers[index] = tostring(index)
					end
					return table.concat(numbers, "\n")
				end),
				FontFace = Fonts.Mono,
				TextSize = TEXT_SIZE,
				TextColor3 = Theme.Faint,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Top,
				-- AutomaticCanvasSize ignores the frame's bottom padding; this keeps room under the last line.
				[Children] = scope:New("UIPadding")({ PaddingBottom = UDim.new(0, PAD) }),
			}),
			scope:New("TextLabel")({
				Name = "Colours",
				Position = scope:Computed(function(use)
					return UDim2.fromOffset(use(gutter), 0)
				end),
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				RichText = true,
				Visible = scope:Computed(function(use)
					return not use(focused) and #use(text) <= HIGHLIGHT_LIMIT
				end),
				Text = scope:Computed(function(use)
					local source = use(text)
					return if #source <= HIGHLIGHT_LIMIT then CodeView.richText(source, use(colors))
						else ""
				end),
				FontFace = Fonts.Mono,
				TextSize = TEXT_SIZE,
				TextColor3 = Theme.Ink2,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
			box,
		},
	})

	local frame = scope:New("Frame")({
		Name = props.Name or "CodeView",
		LayoutOrder = props.LayoutOrder,
		Size = props.Size or UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Ink,
		ClipsDescendants = true,
		[Children] = {
			Surface.Fill(scope, scope:Value(0.04)),
			Surface.Edge(scope, nil, UDim.new(0, 14)),
			scroll,
		},
	})
	return frame, { Box = box, Scroll = scroll }
end

return table.freeze(CodeView)

end)() end,
    [42] = function()local wax,script,require=ImportGlobals(42)local ImportGlobals return (function(...)local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Motion = require(Root.ui.motion)
local Surface = require(script.surface)
local Buttons = require(script.buttons)
local Switch = require(script.switch)
local Rows = require(script.rows)
local Inputs = require(script.inputs)
local Notices = require(script.notices)

local peek = Fusion.peek

local function read(value)
	return if type(value) == "table" and value.kind ~= nil then peek(value) else value
end

-- The families' own functions, not wrappers (Field returns two values), listed by name so
-- callers keep their types.
return table.freeze({
	Interaction = Surface.Interaction,
	Edge = Surface.Edge,
	Fill = Surface.Fill,
	FillAlpha = Surface.FillAlpha,
	Icon = Surface.Icon,
	texture = Surface.texture,
	apply = Surface.apply,
	Label = Surface.Label,
	Section = Surface.Section,
	merge = Surface.merge,
	Button = Buttons.Button,
	IconButton = Buttons.IconButton,
	Badge = Buttons.Badge,
	Switch = Switch.Switch,
	SwitchCard = Switch.SwitchCard,
	Row = Rows.Row,
	Group = Rows.Group,
	List = Rows.List,
	Field = Inputs.Field,
	KeyButton = Inputs.KeyButton,
	keyLabel = Inputs.keyLabel,
	ageLabel = Inputs.ageLabel,
	KeyRow = Inputs.KeyRow,
	Banner = Notices.Banner,
	Empty = Notices.Empty,
	read = read,
	snap = Motion.Snap,
	soft = Motion.Soft,
	animate = Motion.Animate,
	peek = peek,
})

end)() end,
    [43] = function()local wax,script,require=ImportGlobals(43)local ImportGlobals return (function(...)local Root = script.Parent.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Theme = require(Root.ui.tokens)
local Surface = require(script.Parent.surface)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local merge = Surface.merge

local Controls = {}

function Controls.Button(scope, props)
	local interaction = Surface.Interaction(scope)
	local ghost = props.Ghost == true
	local height = props.Height or 32
	local level = scope:Computed(function(use)
		if ghost then
			return 0.06 * use(interaction.HoverT) + 0.03 * use(interaction.PressT)
		end
		return 0.07 + 0.04 * use(interaction.HoverT) + 0.03 * use(interaction.PressT)
	end)
	local ink = props.Ink or Theme.Ink
	local content = {
		scope:New("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		scope:New("UIPadding")({
			PaddingLeft = UDim.new(0, props.PaddingX or 14),
			PaddingRight = UDim.new(0, props.PaddingX or 14),
		}),
	}
	if props.Icon then
		table.insert(
			content,
			Surface.Icon(scope, props.Icon, 16, { LayoutOrder = 1, ImageColor3 = ink })
		)
	end
	if props.Text then
		table.insert(
			content,
			Surface.Label(
				scope,
				{
					Name = "Text",
					LayoutOrder = 2,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, height),
					Text = props.Text,
					TextSize = props.TextSize or 14,
					FontFace = Theme.Title,
					TextColor3 = ink,
					TextTruncate = Enum.TextTruncate.None,
				}
			)
		)
	end
	if props.TrailingIcon then
		table.insert(
			content,
			Surface.Icon(scope, props.TrailingIcon, 14, { LayoutOrder = 3, ImageColor3 = ink })
		)
	end
	return scope:New("TextButton")(
		merge(
			{
				Name = props.Name or "Button",
				LayoutOrder = props.LayoutOrder,
				Visible = props.Visible,
				AnchorPoint = props.AnchorPoint,
				Position = props.Position,
				AutomaticSize = if props.Size then Enum.AutomaticSize.None else Enum.AutomaticSize.X,
				Size = props.Size or UDim2.fromOffset(0, height),
				BackgroundColor3 = Theme.Ink,
				AutoButtonColor = false,
				Text = "",
				[OnEvent("Activated")] = function()
					if props.OnActivated then
						props.OnActivated()
					end
				end,
				[Children] = {
					Surface.Fill(scope, level),
					if ghost then scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) })
						else Surface.Edge(scope, nil, UDim.new(0.5, 0)),
					scope:New("UIScale")({
						Scale = scope:Computed(function(use)
							return 1 - 0.03 * use(interaction.PressT)
						end),
					}),
					content,
				},
			},
			interaction.Events
		)
	)
end

function Controls.IconButton(scope, props)
	local interaction = Surface.Interaction(scope)
	local size = props.Size or 28
	return scope:New("TextButton")(
		merge(
			{
				Name = props.Name or "IconButton",
				LayoutOrder = props.LayoutOrder,
				AnchorPoint = props.AnchorPoint,
				Position = props.Position,
				Size = UDim2.fromOffset(size, size),
				Visible = props.Visible,
				BackgroundColor3 = Theme.Ink,
				BackgroundTransparency = scope:Computed(function(use)
					return 1
						- (props.Rest or 0)
						- 0.08 * use(interaction.HoverT)
						- 0.04 * use(interaction.PressT)
				end),
				AutoButtonColor = false,
				Text = "",
				[OnEvent("Activated")] = function()
					if props.OnActivated then
						props.OnActivated()
					end
				end,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
					Surface.Icon(
						scope,
						props.Icon,
						props.IconSize or 16,
						{
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							ImageColor3 = scope:Computed(function(use)
								return use(Theme.Muted):Lerp(
									use(Theme.Ink),
									use(interaction.HoverT)
								)
							end),
						}
					),
				},
			},
			interaction.Events
		)
	)
end

function Controls.Badge(scope, props)
	local tinted = props.Success or props.Color ~= nil
	local tint = props.Color or (if props.Success then Theme.Success else Theme.Ink)
	return scope:New("Frame")({
		Name = props.Text,
		LayoutOrder = props.LayoutOrder,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundColor3 = tint,
		BackgroundTransparency = 0.9,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
			scope:New("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				Color = tint,
				Transparency = if tinted then 0.75 else 0.92,
			}),
			scope:New("UIPadding")({
				PaddingLeft = UDim.new(0, 7),
				PaddingRight = UDim.new(0, 8),
			}),
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			if props.Icon then Surface.Icon(
					scope,
					props.Icon,
					12,
					{
						ImageColor3 = if tinted then tint else Theme.Ink2,
					}
				)
				else nil,
			Surface.Label(
				scope,
				{
					LayoutOrder = 2,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 20),
					Text = props.Text,
					TextSize = 11,
					FontFace = Theme.Title,
					TextColor3 = if tinted then tint else Theme.Ink2,
					TextTruncate = Enum.TextTruncate.None,
				}
			),
		},
	})
end

return table.freeze(Controls)

end)() end,
    [44] = function()local wax,script,require=ImportGlobals(44)local ImportGlobals return (function(...)local Root = script.Parent.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Motion = require(Root.ui.motion)
local Theme = require(Root.ui.tokens)
local Surface = require(script.Parent.surface)
local Buttons = require(script.Parent.buttons)

local soft = Motion.Soft
local animate = Motion.Animate

local Children = Fusion.Children
local OnChange = Fusion.OnChange
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local Controls = {}

function Controls.Field(scope, props)
	local box
	local focused = scope:Value(false)
	local height = props.Height or 40
	box = scope:New("TextBox")({
		Name = "Box",
		Position = UDim2.fromOffset(if props.Icon then 38 else 14, 0),
		Size = UDim2.new(1, -(if props.Icon then 38 else 14) - (props.TrailingWidth or 14), 1, 0),
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Text = peek(props.Text),
		PlaceholderText = props.Placeholder or "",
		PlaceholderColor3 = Theme.Faint,
		FontFace = Theme.Title,
		TextSize = 14,
		TextColor3 = Theme.Ink,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		[OnChange("Text")] = function(text)
			if peek(props.Text) ~= text then
				props.Text:set(text)
			end
		end,
		[OnEvent("Focused")] = function()
			focused:set(true)
		end,
		[OnEvent("FocusLost")] = function(enter)
			focused:set(false)
			if enter and props.OnSubmit then
				props.OnSubmit(box.Text)
			end
		end,
	})
	table.insert(
		scope,
		scope:Observer(props.Text):onChange(function()
			if box.Text ~= peek(props.Text) then
				box.Text = peek(props.Text)
			end
		end)
	)
	local focusT = animate(
		scope,
		scope:Computed(function(use)
			return if use(focused) then 1 else 0
		end),
		soft(0.15)
	)
	local frame = scope:New("Frame")({
		Name = props.Name or "Field",
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Ink,
		[Children] = {
			Surface.Fill(
				scope,
				scope:Computed(function(use)
					return 0.06 + 0.02 * use(focusT)
				end)
			),
			Surface.Edge(scope, focusT, props.Radius or UDim.new(0, math.floor(height / 2.6))),
			if props.Icon then Surface.Icon(
					scope,
					props.Icon,
					16,
					{
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 13, 0.5, 0),
						ImageColor3 = Theme.Muted,
					}
				)
				else nil,
			box,
			props.Trailing,
		},
	})
	return frame, box
end

local DIGITS = {
	Zero = "0",
	One = "1",
	Two = "2",
	Three = "3",
	Four = "4",
	Five = "5",
	Six = "6",
	Seven = "7",
	Eight = "8",
	Nine = "9",
}
local KEY_NAMES = {
	Return = "Enter",
	MouseButton1 = "Mouse 1",
	MouseButton2 = "Mouse 2",
	MouseButton3 = "Mouse 3",
}

function Controls.keyLabel(key: string): string
	if KEY_NAMES[key] then
		return KEY_NAMES[key]
	end
	local digit = DIGITS[key] or DIGITS[string.match(key, "^Keypad(%a+)$") or ""]
	if digit then
		return if string.find(key, "^Keypad") then `Num {digit}` else digit
	end
	local spaced = string.gsub(string.gsub(key, "(%l)(%u)", "%1 %2"), "^Keypad ", "Num ")
	return (string.gsub(spaced, "Control", "Ctrl"))
end

function Controls.ageLabel(days: number): string
	local function count(n: number, unit: string)
		return `{n} {unit}{if n == 1 then "" else "s"}`
	end
	if days >= 365 then
		return `{count(days // 365, "year")} ({count(days, "day")})`
	elseif days >= 60 then
		return count(days // 30, "month")
	end
	return count(days, "day")
end

function Controls.KeyButton(scope, props)
	local Dispatcher = require(Root.utils.keybindDispatcher)
	local UserInputService = game:GetService("UserInputService")
	local listening = scope:Value(false)
	local connection
	local owner = {}
	local function stop(late)
		listening:set(false)
		if connection then
			connection:Disconnect()
			connection = nil
		end
		if late then
			task.defer(Dispatcher.endCapture, owner)
		else
			Dispatcher.endCapture(owner)
		end
	end
	table.insert(scope, stop)
	return Buttons.Button(
		scope,
		{
			Name = props.Name or "Key",
			LayoutOrder = props.LayoutOrder,
			AnchorPoint = props.AnchorPoint,
			Position = props.Position,
			Height = 28,
			TextSize = 13,
			PaddingX = 12,
			Ink = scope:Computed(function(use)
				return use(if use(listening) then Theme.Accent else Theme.Ink)
			end),
			Text = scope:Computed(function(use)
				if use(listening) then
					return "Press a key"
				end
				local key = use(props.Key)
				return if key == nil or key == "None" or key == "" then "Not set"
					else Controls.keyLabel(key)
			end),
			OnActivated = function()
				if peek(listening) then
					stop()
					return
				end
				if not Dispatcher.beginCapture(owner, stop) then
					return
				end
				listening:set(true)
				connection = UserInputService.InputBegan:Connect(function(input)
					local key = Dispatcher.normalizeInputToKey(input)
					if key == nil or key == "MouseLeft" then
						return
					end
					stop(true)
					if key == "Escape" then
						return
					end
					props.OnChange(if key == "Backspace" then "None" else key)
				end)
			end,
		}
	)
end

function Controls.KeyRow(scope, props)
	return scope:New("Frame")({
		Name = props.Name or props.Title,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		[Children] = {
			if props.Icon then Surface.Icon(
					scope,
					props.Icon,
					16,
					{
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 14, 0.5, 0),
						ImageColor3 = Theme.Muted,
					}
				)
				else nil,
			Surface.Label(
				scope,
				{
					Name = "Title",
					Position = UDim2.fromOffset(if props.Icon then 40 else 14, 0),
					Size = UDim2.new(1, -150, 1, 0),
					Text = props.Title,
				}
			),
			Controls.KeyButton(
				scope,
				{
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -8, 0.5, 0),
					Key = props.Key,
					OnChange = props.OnChange,
				}
			),
		},
	})
end

return table.freeze(Controls)

end)() end,
    [45] = function()local wax,script,require=ImportGlobals(45)local ImportGlobals return (function(...)local Root = script.Parent.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Theme = require(Root.ui.tokens)
local Surface = require(script.Parent.surface)
local Buttons = require(script.Parent.buttons)

local Children = Fusion.Children

local Controls = {}

function Controls.Banner(scope, props)
	local actions = {}
	for index, action in props.Actions or {} do
		actions[index] = Buttons.Button(
			scope,
			{
				Name = action.Text,
				LayoutOrder = index,
				Text = action.Text,
				Height = 28,
				TextSize = 13,
				PaddingX = 12,
				Ghost = action.Ghost,
				OnActivated = action.OnActivated,
			}
		)
	end
	return scope:New("Frame")({
		Name = props.Name or "Banner",
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = Theme.Ink,
		[Children] = {
			Surface.Fill(
				scope,
				scope:Computed(function()
					return 0.08
				end)
			),
			Surface.Edge(scope, nil, UDim.new(0, 14)),
			Surface.Icon(
				scope,
				props.Icon or "info",
				16,
				{
					Position = UDim2.fromOffset(14, 13),
					ImageColor3 = props.Ink or Theme.Ink2,
				}
			),
			scope:New("Frame")({
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				BackgroundTransparency = 1,
				[Children] = {
					scope:New("UIPadding")({
						PaddingTop = UDim.new(0, 12),
						PaddingBottom = UDim.new(0, 12),
						PaddingLeft = UDim.new(0, 40),
						PaddingRight = UDim.new(0, 14),
					}),
					scope:New("UIListLayout")({
						Padding = UDim.new(0, 10),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Surface.Label(
						scope,
						{
							Name = "Text",
							LayoutOrder = 1,
							AutomaticSize = Enum.AutomaticSize.Y,
							Size = UDim2.fromScale(1, 0),
							Text = props.Text,
							TextSize = 13,
							FontFace = Theme.Body,
							TextColor3 = Theme.Ink2,
							TextWrapped = true,
							TextTruncate = Enum.TextTruncate.None,
							LineHeight = 1.15,
						}
					),
					if #actions > 0 then scope:New("Frame")({
							Name = "Actions",
							LayoutOrder = 2,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							[Children] = {
								scope:New("UIListLayout")({
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 8),
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),
								actions,
							},
						})
						else nil,
				},
			}),
		},
	})
end

function Controls.Empty(scope, props)
	return scope:New("Frame")({
		Name = props.Name or "Empty",
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 20),
			}),
			scope:New("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Surface.Icon(
				scope,
				props.Icon or "info",
				20,
				{ LayoutOrder = 1, ImageColor3 = Theme.Muted }
			),
			Surface.Label(
				scope,
				{
					Name = "Title",
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 18),
					Text = props.Title,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Center,
				}
			),
			if props.Text then Surface.Label(
					scope,
					{
						Name = "Text",
						LayoutOrder = 3,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.new(1, -40, 0, 0),
						Text = props.Text,
						TextSize = 13,
						FontFace = Theme.Body,
						TextColor3 = Theme.Muted,
						TextWrapped = true,
						TextTruncate = Enum.TextTruncate.None,
						TextXAlignment = Enum.TextXAlignment.Center,
					}
				)
				else nil,
			if props.Action then Buttons.Button(
					scope,
					{
						Name = "Action",
						LayoutOrder = 4,
						Text = props.Action.Text,
						Icon = props.Action.Icon,
						Height = 30,
						TextSize = 13,
						OnActivated = props.Action.OnActivated,
					}
				)
				else nil,
		},
	})
end

return table.freeze(Controls)

end)() end,
    [46] = function()local wax,script,require=ImportGlobals(46)local ImportGlobals return (function(...)local Root = script.Parent.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Motion = require(Root.ui.motion)
local Theme = require(Root.ui.tokens)
local Surface = require(script.Parent.surface)
local Switch = require(script.Parent.switch)

local snap = Motion.Snap
local animate = Motion.Animate

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek
local merge = Surface.merge

local Controls = {}

function Controls.Row(scope, props)
	local interaction = Surface.Interaction(scope)
	local disabled = props.Disabled
	local isDisabled = scope:Computed(function(use)
		return disabled ~= nil and use(disabled) ~= nil
	end)
	local switch = props.Switch
	local onT = if switch then animate(
			scope,
			scope:Computed(function(use)
				return if use(switch.On) then 1 else 0
			end),
			snap(0.25)
		)
		else nil
	local description = props.Description
	if disabled ~= nil then
		local base = description
		description = scope:Computed(function(use)
			local reason = use(disabled)
			if reason ~= nil then
				return reason
			end
			return if base ~= nil then use(base) else nil
		end)
	end
	local twoLine = scope:Computed(function(use)
		local text = if description ~= nil then use(description) else nil
		return text ~= nil and text ~= ""
	end)
	local trailing = 14
	if switch then
		trailing += 44
	end
	if props.Chevron then
		trailing += 20
	end
	local left = props.Inset or (if props.Icon then 40 else 14)
	local detailWidth = props.DetailWidth or 120
	local detailRight = (if props.Chevron then 34 else 14) + (if switch then 52 else 0)

	return scope:New("TextButton")(
		merge(
			{
				Name = props.Name or "Row",
				LayoutOrder = props.LayoutOrder,
				Visible = props.Visible,
				Size = scope:Computed(function(use)
					return UDim2.new(1, 0, 0, if use(twoLine) then 54 else 44)
				end),
				BackgroundColor3 = Theme.Ink,
				BackgroundTransparency = scope:Computed(function(use)
					if use(isDisabled) then
						return 1
					end
					return 1 - 0.03 * use(interaction.HoverT) - 0.02 * use(interaction.PressT)
				end),
				AutoButtonColor = false,
				Text = "",
				Selectable = true,
				Interactable = scope:Computed(function(use)
					return not use(isDisabled)
				end),
				[OnEvent("Activated")] = function()
					if props.OnActivated then
						props.OnActivated()
					elseif switch then
						switch.Set(not peek(switch.On))
					end
				end,
				[Children] = {
					if props.Icon then Surface.Icon(
							scope,
							props.Icon,
							16,
							{
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 14, 0.5, 0),
								ImageColor3 = scope:Computed(function(use)
									if use(isDisabled) then
										return use(Theme.Faint)
									end
									local lit = if onT then use(onT) else 0
									return use(Theme.Muted):Lerp(
										use(Theme.Ink),
										math.max(lit, use(interaction.HoverT) * 0.6)
									)
								end),
							}
						)
						else nil,
					Surface.Label(
						scope,
						{
							Name = "Title",
							Position = scope:Computed(function(use)
								return UDim2.fromOffset(left, if use(twoLine) then 9 else 0)
							end),
							Size = scope:Computed(function(use)
								return UDim2.new(
									1,
									-left - trailing - (if props.Detail then detailWidth else 0),
									0,
									if use(twoLine) then 18 else 44
								)
							end),
							Text = props.Title,
							TextColor3 = scope:Computed(function(use)
								return use(if use(isDisabled) then Theme.Faint else Theme.Ink)
							end),
						}
					),
					Surface.Label(
						scope,
						{
							Name = "Description",
							Visible = twoLine,
							Position = UDim2.fromOffset(left, 28),
							Size = scope:Computed(function(use)
								local detail = if props.Detail and not use(isDisabled) then detailWidth
									else 0
								return UDim2.new(1, -left - trailing - detail, 0, 16)
							end),
							Text = scope:Computed(function(use)
								return if description ~= nil then use(description) or "" else ""
							end),
							TextSize = 13,
							FontFace = Theme.Body,
							TextColor3 = Theme.Muted,
						}
					),
					if props.Detail then Surface.Label(
							scope,
							{
								Name = "Detail",
								Visible = scope:Computed(function(use)
									return not use(isDisabled)
								end),
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.new(1, -detailRight, 0, 0),
								Size = UDim2.new(0, detailWidth, 1, 0),
								Text = props.Detail,
								TextSize = 13,
								FontFace = Theme.Title,
								TextColor3 = Theme.Muted,
								TextXAlignment = Enum.TextXAlignment.Right,
							}
						)
						else nil,
					if switch then scope:New("TextButton")({
							Name = "Toggle",
							Visible = scope:Computed(function(use)
								return not use(isDisabled)
							end),
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, if props.Chevron then -28 else -2, 0.5, 0),
							Size = UDim2.fromOffset(52, 40),
							BackgroundTransparency = 1,
							Text = "",
							[OnEvent("Activated")] = function()
								switch.Set(not peek(switch.On))
							end,
							[Children] = Switch.Switch(scope, onT, interaction.PressT),
						})
						else nil,
					if props.Chevron then Surface.Icon(
							scope,
							"chevron-right",
							14,
							{
								Visible = scope:Computed(function(use)
									return not use(isDisabled)
								end),
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -12, 0.5, 0),
								ImageColor3 = Theme.Faint,
							}
						)
						else nil,
				},
			},
			interaction.Events
		)
	)
end

local function divider(scope, row)
	scope:New("Frame")({
		Name = "Divider",
		Parent = row,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = Theme.Ink,
		BackgroundTransparency = Theme.Line,
		BorderSizePixel = 0,
	})
end

function Controls.Group(scope, props)
	local rows = {}
	for index, row in props.Rows do
		row.LayoutOrder = index
		if index > 1 then
			divider(scope, row)
		end
		rows[index] = row
	end
	return scope:New("Frame")({
		Name = props.Name or "Group",
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		[Children] = {
			scope:New("UIListLayout")({
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			if props.Title then Surface.Section(
					scope,
					{ LayoutOrder = 1, Text = props.Title, Inset = 2 }
				)
				else nil,
			scope:New("Frame")({
				Name = "Card",
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				BackgroundColor3 = Theme.Ink,
				ClipsDescendants = true,
				[Children] = {
					Surface.Fill(
						scope,
						scope:Computed(function()
							return 0.05
						end)
					),
					Surface.Edge(scope, nil, UDim.new(0, 14)),
					scope:New("UIListLayout")({ SortOrder = Enum.SortOrder.LayoutOrder }),
					rows,
				},
			}),
		},
	})
end

function Controls.List(scope, props)
	return scope:New("Frame")({
		Name = props.Name or "List",
		LayoutOrder = props.LayoutOrder,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = Theme.Ink,
		ClipsDescendants = true,
		Visible = scope:Computed(function(use)
			return #use(props.Items) > 0
		end),
		[Children] = {
			Surface.Fill(
				scope,
				scope:Computed(function()
					return 0.05
				end)
			),
			Surface.Edge(scope, nil, UDim.new(0, 14)),
			scope:New("UIListLayout")({ SortOrder = Enum.SortOrder.LayoutOrder }),
			scope:ForPairs(
				props.Items,
				function(_, rowScope, index, entry)
					local row = props.Row(rowScope, index, entry)
					row.LayoutOrder = index
					if index > 1 then
						divider(rowScope, row)
					end
					return index, row
				end
			),
		},
	})
end

return table.freeze(Controls)

end)() end,
    [47] = function()local wax,script,require=ImportGlobals(47)local ImportGlobals return (function(...)local Root = script.Parent.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Motion = require(Root.ui.motion)
local Icons = require(Root.ui.icons.dock)
local SharedIcons = require(Root.ui.icons.shared)
local Images = require(Root.ui.images)
local RuntimeAssets = require(Root.utils.runtimeAssets)
local Theme = require(Root.ui.tokens)

local soft = Motion.Soft
local animate = Motion.Animate

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local Controls = {}

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

function Controls.Interaction(scope)
	local hovered = scope:Value(false)
	local pressed = scope:Value(false)
	return {
		Hovered = hovered,
		Pressed = pressed,
		HoverT = animate(
			scope,
			scope:Computed(function(use)
				return if use(hovered) then 1 else 0
			end),
			soft(0.12)
		),
		PressT = animate(
			scope,
			scope:Computed(function(use)
				return if use(pressed) then 1 else 0
			end),
			soft(0.1)
		),
		Events = {
			[OnEvent("MouseEnter")] = function()
				hovered:set(true)
			end,
			[OnEvent("MouseLeave")] = function()
				hovered:set(false)
				pressed:set(false)
			end,
			[OnEvent("InputBegan")] = function(input)
				if isPointer(input) then
					pressed:set(true)
				end
			end,
			[OnEvent("InputEnded")] = function(input)
				if isPointer(input) then
					pressed:set(false)
				end
			end,
		},
	}
end

local function merge(into, from)
	for key, value in from do
		into[key] = value
	end
	return into
end

function Controls.Edge(scope, lit, radius)
	return {
		scope:New("UICorner")({ CornerRadius = radius or UDim.new(0, 12) }),
		scope:New("UIStroke")({
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Color = Theme.Ink,
			Thickness = 1,
			[Children] = scope:New("UIGradient")({
				Rotation = 90,
				Transparency = scope:Computed(function(use)
					local t = if lit then use(lit) else 0
					return NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.88 - 0.14 * t),
						NumberSequenceKeypoint.new(0.5, 0.96 - 0.02 * t),
						NumberSequenceKeypoint.new(1, 0.985),
					})
				end),
			}),
		}),
	}
end

function Controls.FillAlpha(level, at)
	return level * (1 - 0.55 * at)
end

function Controls.Fill(scope, level)
	return scope:New("UIGradient")({
		Rotation = 90,
		Transparency = scope:Computed(function(use)
			local top = use(level)
			return NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1 - Controls.FillAlpha(top, 0)),
				NumberSequenceKeypoint.new(1, 1 - Controls.FillAlpha(top, 1)),
			})
		end),
	})
end

function Controls.texture(name: string?): string?
	return if name then Icons[name] or SharedIcons[name] else nil
end

function Controls.apply(label: ImageLabel, name: string?)
	if name and Images:IsIcon(name) then
		Images:Track(name, label)
	else
		Images:Track(nil, label)
		label.Image = RuntimeAssets.resolve(Controls.texture(name) or "")
	end
end

function Controls.Icon(scope, name, size, props)
	props = props or {}
	props.Name = props.Name or "Icon"
	props.Size = UDim2.fromOffset(size, size)
	props.BackgroundTransparency = 1
	props.ImageColor3 = props.ImageColor3 or Theme.Ink
	local label = scope:New("ImageLabel")(props)
	if type(name) == "table" then
		scope:Observer(name):onBind(function()
			Controls.apply(label, peek(name))
		end)
	else
		Controls.apply(label, name)
	end
	table.insert(
		scope,
		function()
			Images:Untrack(label)
		end
	)
	return label
end

function Controls.Label(scope, props)
	props.BackgroundTransparency = 1
	props.FontFace = props.FontFace or Theme.Title
	props.TextSize = props.TextSize or 14
	props.TextColor3 = props.TextColor3 or Theme.Ink
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props.TextTruncate = props.TextTruncate or Enum.TextTruncate.AtEnd
	return scope:New("TextLabel")(props)
end

function Controls.Section(scope, props)
	return scope:New("Frame")({
		Name = props.Name or "Section",
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		[Children] = Controls.Label(
			scope,
			{
				Position = UDim2.fromOffset(props.Inset or 0, 0),
				Size = UDim2.new(1, -(props.Inset or 0), 1, 0),
				Text = props.Text,
				TextSize = 13,
				FontFace = Theme.Title,
				TextColor3 = Theme.Muted,
			}
		),
	})
end
Controls.merge = merge

return table.freeze(Controls)

end)() end,
    [48] = function()local wax,script,require=ImportGlobals(48)local ImportGlobals return (function(...)local Root = script.Parent.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Motion = require(Root.ui.motion)
local Theme = require(Root.ui.tokens)
local Surface = require(script.Parent.surface)

local snap = Motion.Snap
local animate = Motion.Animate

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek
local merge = Surface.merge

local Controls = {}

function Controls.Switch(scope, onT, pressT)
	return scope:New("Frame")({
		Name = "Switch",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(32, 20),
		BackgroundColor3 = scope:Computed(function(use)
			return use(Theme.Track):Lerp(use(Theme.Accent), use(onT))
		end),
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
			scope:New("Frame")({
				Name = "Thumb",
				AnchorPoint = scope:Computed(function(use)
					return Vector2.new(use(onT), 0.5)
				end),
				Position = scope:Computed(function(use)
					local t = use(onT)
					return UDim2.new(t, 2 - 4 * t, 0.5, 0)
				end),
				Size = scope:Computed(function(use)
					return UDim2.fromOffset(16 + 3 * use(pressT), 16)
				end),
				BackgroundColor3 = scope:Computed(function(use)
					return use(Theme.Ink):Lerp(use(Theme.AccentInk), use(onT))
				end),
				[Children] = scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }),
			}),
		},
	})
end

function Controls.SwitchCard(scope, props)
	local interaction = Surface.Interaction(scope)
	local on = props.On
	local disabled = props.Disabled
	local isDisabled = scope:Computed(function(use)
		return disabled ~= nil and use(disabled) ~= nil
	end)
	local onT = animate(
		scope,
		scope:Computed(function(use)
			return if use(on) then 1 else 0
		end),
		snap(0.25)
	)
	local level = scope:Computed(function(use)
		return 0.05 + 0.03 * use(interaction.HoverT) + 0.05 * use(onT)
	end)
	return scope:New("TextButton")(
		merge(
			{
				Name = props.Name or props.Text,
				LayoutOrder = props.LayoutOrder,
				BackgroundColor3 = Theme.Ink,
				AutoButtonColor = false,
				Text = "",
				[OnEvent("Activated")] = function()
					if peek(isDisabled) then
						if props.OnBlocked then
							props.OnBlocked(peek(disabled))
						end
						return
					end
					on:set(not peek(on))
					if props.OnToggle then
						props.OnToggle(peek(on))
					end
				end,
				[Children] = {
					Surface.Fill(scope, level),
					Surface.Edge(scope, onT, UDim.new(0, 14)),
					Surface.Icon(
						scope,
						props.Icon,
						16,
						{
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 14, 0.5, 0),
							ImageColor3 = scope:Computed(function(use)
								if use(isDisabled) then
									return use(Theme.Faint)
								end
								return use(Theme.Muted):Lerp(
									use(Theme.Ink),
									math.max(use(onT), use(interaction.HoverT) * 0.6)
								)
							end),
						}
					),
					Surface.Label(
						scope,
						{
							Name = "Label",
							Position = UDim2.fromOffset(40, 0),
							Size = UDim2.new(1, -96, 1, 0),
							Text = props.Text,
							TextColor3 = scope:Computed(function(use)
								if use(isDisabled) then
									return use(Theme.Faint)
								end
								return use(Theme.Ink2):Lerp(use(Theme.Ink), use(onT))
							end),
						}
					),
					scope:Hydrate(Controls.Switch(scope, onT, interaction.PressT))({
						Visible = scope:Computed(function(use)
							return not use(isDisabled)
						end),
					}),
					Surface.Icon(
						scope,
						"lock",
						14,
						{
							Name = "Locked",
							Visible = isDisabled,
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -11, 0.5, 0),
							ImageColor3 = Theme.Faint,
						}
					),
				},
			},
			interaction.Events
		)
	)
end

return table.freeze(Controls)

end)() end,
    [49] = function()local wax,script,require=ImportGlobals(49)local ImportGlobals return (function(...)local FONT_ID = "rbxassetid://12187365364"

return table.freeze({
	Title = Font.new(FONT_ID, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	Body = Font.new(FONT_ID, Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Mono = Font.fromEnum(Enum.Font.RobotoMono),
})

end)() end,
    [51] = function()local wax,script,require=ImportGlobals(51)local ImportGlobals return (function(...)-- This file was automatically @generated by Tungsten.
-- It is not intended for manual editing.

local cascader = {
	["at-sign"] = "rbxassetid://83248663474196",
	["calendar-clock"] = "rbxassetid://132427868520093",
	check = "rbxassetid://82672046716943",
	["chevron-down"] = "rbxassetid://133323015971318",
	["chevron-left"] = "rbxassetid://126366292753734",
	["chevron-right"] = "rbxassetid://116216294201821",
	hash = "rbxassetid://107654838834456",
	["square-check"] = "rbxassetid://80032897400049",
	type = "rbxassetid://102581956795665",
	user = "rbxassetid://96909186329486",
	users = "rbxassetid://104483245304583",
}

return cascader
end)() end,
    [52] = function()local wax,script,require=ImportGlobals(52)local ImportGlobals return (function(...)-- This file was automatically @generated by Tungsten.
-- It is not intended for manual editing.

local dock = {
	aperture = "rbxassetid://71856987706399",
	armchair = "rbxassetid://81694426802216",
	["arrow-down"] = "rbxassetid://88026336945817",
	["arrow-left"] = "rbxassetid://129215413396781",
	["arrow-right"] = "rbxassetid://140474672051655",
	["arrow-up"] = "rbxassetid://118783031963069",
	["badge-check"] = "rbxassetid://122381235148836",
	bell = "rbxassetid://85344391726580",
	bookmark = "rbxassetid://114371783961690",
	camera = "rbxassetid://123335388663322",
	check = "rbxassetid://125449216983517",
	["chevron-left"] = "rbxassetid://123449985048824",
	["chevron-right"] = "rbxassetid://86983510736744",
	clock = "rbxassetid://71443450777692",
	["cloud-off"] = "rbxassetid://117414289694605",
	cloud = "rbxassetid://137275560345538",
	compass = "rbxassetid://135566716754989",
	copy = "rbxassetid://76260391966055",
	crosshair = "rbxassetid://124472500298566",
	ellipsis = "rbxassetid://134599684090138",
	["external-link"] = "rbxassetid://129702076596338",
	eye = "rbxassetid://95796078766771",
	feather = "rbxassetid://120225547844644",
	folder = "rbxassetid://108240051477804",
	footprints = "rbxassetid://124212191068324",
	game = "rbxassetid://100634765395584",
	gauge = "rbxassetid://71581744420753",
	gear = "rbxassetid://119679349772474",
	ghost = "rbxassetid://84437913777007",
	globe = "rbxassetid://122068543869789",
	glow = "rbxassetid://128261931875861",
	["grip-vertical"] = "rbxassetid://135252013614339",
	home = "rbxassetid://120704660868662",
	image = "rbxassetid://121120404724188",
	info = "rbxassetid://132890788193359",
	["key-round"] = "rbxassetid://118992616174422",
	keyboard = "rbxassetid://106526440532308",
	layers = "rbxassetid://73464042737448",
	["loader-circle"] = "rbxassetid://83147791564917",
	locations = "rbxassetid://139346806935647",
	lock = "rbxassetid://72628498015078",
	["log-out"] = "rbxassetid://131361600690041",
	["map-pin"] = "rbxassetid://97377526148306",
	["message-circle"] = "rbxassetid://87899224988800",
	minus = "rbxassetid://110057551347208",
	monitor = "rbxassetid://82970289866058",
	["mouse-pointer-click"] = "rbxassetid://83939350605495",
	move = "rbxassetid://74801393968004",
	navigation = "rbxassetid://129541449548117",
	pencil = "rbxassetid://115903585033132",
	["person-standing"] = "rbxassetid://104256789504584",
	person = "rbxassetid://111084746415354",
	["pin-off"] = "rbxassetid://137061606251633",
	pin = "rbxassetid://96141803971014",
	plane = "rbxassetid://95305623856624",
	play = "rbxassetid://123142153163403",
	players = "rbxassetid://99883124832960",
	plus = "rbxassetid://138421651759694",
	profiles = "rbxassetid://91850452391775",
	puzzle = "rbxassetid://112741125879315",
	rabbit = "rbxassetid://73116991452014",
	["refresh-cw"] = "rbxassetid://113743107212266",
	["rotate-ccw"] = "rbxassetid://75080897285458",
	save = "rbxassetid://106406722842714",
	["scan-eye"] = "rbxassetid://115372746985937",
	script = "rbxassetid://79064539790155",
	search = "rbxassetid://79469097389124",
	server = "rbxassetid://124822749911731",
	session = "rbxassetid://83337489103350",
	shadow = "rbxassetid://125631206242448",
	["shield-check"] = "rbxassetid://138923536018846",
	["sliders-horizontal"] = "rbxassetid://115205301649756",
	smartphone = "rbxassetid://78506312005528",
	sparkles = "rbxassetid://105456336884886",
	sun = "rbxassetid://134938361504965",
	tornado = "rbxassetid://100444168600677",
	["trash-2"] = "rbxassetid://138349808197044",
	["triangle-alert"] = "rbxassetid://95741547452434",
	["undo-2"] = "rbxassetid://130774859486493",
	user = "rbxassetid://139160406052157",
	users = "rbxassetid://115805020666026",
	video = "rbxassetid://99749634656187",
	["wifi-off"] = "rbxassetid://95342937826306",
	wifi = "rbxassetid://101033944166992",
	world = "rbxassetid://138698178233765",
	x = "rbxassetid://88368074812433",
	zap = "rbxassetid://87786458747877",
}

return dock
end)() end,
    [53] = function()local wax,script,require=ImportGlobals(53)local ImportGlobals return (function(...)-- This file was automatically @generated by Tungsten.
-- It is not intended for manual editing.

local components = {
	["arrow-down-to-line"] = "rbxassetid://86772230402105",
	["arrow-up-down"] = "rbxassetid://139906228037816",
	box = "rbxassetid://107609208095727",
	["chevrons-up-down"] = "rbxassetid://121115619359967",
	history = "rbxassetid://121150030527002",
	inbox = "rbxassetid://100765520073065",
	list = "rbxassetid://96417288556180",
	package = "rbxassetid://81490551201653",
	pause = "rbxassetid://107092647782205",
	star = "rbxassetid://115591372030944",
	["star-filled"] = "rbxassetid://118022893731495",
	["trending-down"] = "rbxassetid://95180168092473",
	["trending-up"] = "rbxassetid://108686763215714",
	["user-plus"] = "rbxassetid://85830136528646",
	["layout-grid"] = "rbxassetid://110738408229055",
	["ethos-e"] = "rbxassetid://111882090410078",
	["maximize-2"] = "rbxassetid://79848092515060",
	["minimize-2"] = "rbxassetid://79476081473754",
	discord = "rbxassetid://135427415405802",
	settings = "rbxassetid://130211338910815",
	["cursor-col-resize"] = "rbxassetid://109314965156981",
	["cursor-default"] = "rbxassetid://79046234010211",
	["cursor-ew-resize"] = "rbxassetid://115582826877002",
	["cursor-nesw-resize"] = "rbxassetid://124663234579526",
	["cursor-ns-resize"] = "rbxassetid://86392132761278",
	["cursor-nwse-resize"] = "rbxassetid://83769682581038",
	["cursor-text"] = "rbxassetid://83531299746719",
}

return components

end)() end,
    [54] = function()local wax,script,require=ImportGlobals(54)local ImportGlobals return (function(...)--!nocheck

local RuntimeAssets = require(script.Parent.Parent.utils.runtimeAssets)
local Molto = require(script.Parent.Parent.assets.molto)
local EthosIcons = require(script.Parent.Parent.assets.ethosIcons)

local UPLOADS = {}
for _, uploads in ipairs({
	require(script.Parent.icons.cascader),
	require(script.Parent.icons.shared),
	require(script.Parent.icons.dock),
}) do
	for name, image in pairs(uploads) do
		UPLOADS[name] = image
	end
end

local Images = {}
local bindings = {}
local warnedFontFailure = false

local function imageInstance(instance)
	return instance:IsA("ImageLabel") or instance:IsA("ImageButton")
end

local function disconnect(connections)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
end

function Images:IsIcon(name)
	return type(name) == "string" and (EthosIcons.Has(name) or Molto.IsIcon(name))
end

function Images:GetFontAsset(name)
	if type(name) == "string" and EthosIcons.Has(name) then
		return EthosIcons.GetFontAsset(name)
	end
	if self:IsIcon(name) then
		return Molto.GetFontAsset(name)
	end
	return nil, "Unknown icon: " .. tostring(name)
end

function Images:Untrack(instance)
	local binding = bindings[instance]
	if binding == nil then
		return
	end
	bindings[instance] = nil
	disconnect(binding.Connections)
	disconnect(binding.ScaleConnections)
	if binding.Glyph then
		binding.Glyph:Destroy()
	end
end

local function scaleAt(instance)
	local scale = 1
	local current = instance
	while current do
		local uiScale = current:FindFirstChildOfClass("UIScale")
		if uiScale then
			scale *= uiScale.Scale
		end
		current = current.Parent
	end
	return math.max(scale, 0.001)
end

function Images:Track(name, instance)
	assert(
		typeof(instance) == "Instance" and imageInstance(instance),
		"Icon host must be an ImageLabel or ImageButton"
	)
	self:Untrack(instance)
	instance.Image = ""
	instance.ImageRectOffset = Vector2.zero
	instance.ImageRectSize = Vector2.zero
	if not self:IsIcon(name) then
		return instance
	end

	local binding = { Connections = {}, ScaleConnections = {} }
	bindings[instance] = binding
	table.insert(
		binding.Connections,
		instance.Destroying:Connect(function()
			if bindings[instance] == binding then
				self:Untrack(instance)
			end
		end)
	)
	local asset, message = self:GetFontAsset(name)
	if bindings[instance] ~= binding then
		return instance
	end
	if asset == nil then
		local fallback = EthosIcons.Fallback(name) or UPLOADS[name]
		if fallback then
			instance.Image = RuntimeAssets.resolve(fallback)
			return instance
		end
		self:Untrack(instance)
		if not warnedFontFailure then
			warnedFontFailure = true
			warn("Icon font could not load: " .. tostring(message))
		end
		return instance
	end
	warnedFontFailure = false
	local glyph = Instance.new("TextLabel")
	binding.Glyph = glyph
	glyph.Name = "IconGlyph"
	glyph.BackgroundTransparency = 1
	glyph.BorderSizePixel = 0
	glyph.Size = UDim2.fromScale(1, 1)
	glyph.FontFace = asset.FontFace
	glyph.Text = asset.Text
	glyph.RichText = false
	glyph.TextScaled = false
	glyph.TextWrapped = false
	glyph.TextXAlignment = Enum.TextXAlignment.Center
	glyph.TextYAlignment = Enum.TextYAlignment.Center
	glyph.TextStrokeTransparency = 1
	glyph.Active = false
	glyph.Selectable = false
	local function refreshStyle()
		if bindings[instance] ~= binding then
			return
		end
		glyph.TextColor3 = instance.ImageColor3
		glyph.TextTransparency = instance.ImageTransparency
		glyph.ZIndex = instance.ZIndex
	end
	local function refreshSize()
		if bindings[instance] ~= binding then
			return
		end
		local size = instance.AbsoluteSize
		local extent = math.min(size.X, size.Y) / scaleAt(instance)
		if extent <= 0 then
			extent = math.min(instance.Size.X.Offset, instance.Size.Y.Offset)
		end
		glyph.TextSize = math.max(1, extent)
	end
	local bindScaleChanges: () -> ()
	local function scaleChildrenChanged(child)
		if child:IsA("UIScale") then
			bindScaleChanges()
		end
	end
	bindScaleChanges = function()
		if bindings[instance] ~= binding then
			return
		end
		disconnect(binding.ScaleConnections)
		local current = instance
		while current do
			local uiScale = current:FindFirstChildOfClass("UIScale")
			if uiScale then
				table.insert(
					binding.ScaleConnections,
					uiScale:GetPropertyChangedSignal("Scale"):Connect(refreshSize)
				)
			end
			if current:IsA("GuiBase2d") then
				table.insert(
					binding.ScaleConnections,
					current.ChildAdded:Connect(scaleChildrenChanged)
				)
				table.insert(
					binding.ScaleConnections,
					current.ChildRemoved:Connect(scaleChildrenChanged)
				)
			end
			current = current.Parent
		end
		refreshSize()
	end
	table.insert(
		binding.Connections,
		instance.Changed:Connect(function(property)
			if property == "ImageColor3" or property == "ImageTransparency" or property == "ZIndex" then
				refreshStyle()
			elseif property == "AbsoluteSize" or property == "Size" then
				refreshSize()
			end
		end)
	)
	table.insert(binding.Connections, instance.AncestryChanged:Connect(bindScaleChanges))
	refreshStyle()
	bindScaleChanges()
	glyph.Parent = instance
	return instance
end

function Images:cleanup()
	local release = {}
	for instance in pairs(bindings) do
		table.insert(release, instance)
	end
	for _, instance in ipairs(release) do
		self:Untrack(instance)
	end
end

return Images

end)() end,
    [55] = function()local wax,script,require=ImportGlobals(55)local ImportGlobals return (function(...)local Root = script.Parent.Parent
local States = require(Root.packages.states)

local Motion = {}

function Motion.Snap(duration, delay)
	return TweenInfo.new(
		duration,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out,
		0,
		false,
		delay or 0
	)
end

function Motion.Soft(duration)
	return TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
end

function Motion.Animate(scope, goal, info)
	local tween = scope:Tween(goal, info)
	return scope:Computed(function(use)
		return if use(States.AnimationsEnabled) == false then use(goal) else use(tween)
	end)
end

function Motion.Fade(scope, base, ...)
	local opacities = { ... }
	return scope:Computed(function(use)
		local alpha = 1 - use(base)
		for _, opacity in opacities do
			alpha *= use(opacity)
		end
		return 1 - alpha
	end)
end

return table.freeze(Motion)

end)() end,
    [56] = function()local wax,script,require=ImportGlobals(56)local ImportGlobals return (function(...)local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)

local UserInputService = game:GetService("UserInputService")

local Pointer = {}

function Pointer.isPress(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

function Pointer.drag(scope, onMove: (Vector2) -> (), onEnd: (() -> ())?)
	local dragScope = scope:innerScope()
	table.insert(
		dragScope,
		UserInputService.InputChanged:Connect(function(motion)
			if motion.UserInputType == Enum.UserInputType.MouseMovement
				or motion.UserInputType == Enum.UserInputType.Touch then
				onMove(Vector2.new(motion.Position.X, motion.Position.Y))
			end
		end)
	)
	table.insert(
		dragScope,
		UserInputService.InputEnded:Connect(function(release)
			if Pointer.isPress(release) then
				Fusion.doCleanup(dragScope)
				if onEnd then
					onEnd()
				end
			end
		end)
	)
end

return table.freeze(Pointer)

end)() end,
    [57] = function()local wax,script,require=ImportGlobals(57)local ImportGlobals return (function(...)local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local Theme = require(Root.ui.tokens)
local Controls = require(Root.ui.controls)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local function pill(scope, title: string, order: number, selected, onSelect)
	local interaction = Controls.Interaction(scope)
	local selectedT = Controls.animate(
		scope,
		scope:Computed(function(use)
			return if use(selected) then 1 else 0
		end),
		Controls.soft(0.18)
	)
	local edge = Controls.Edge(scope, selectedT, UDim.new(0, 9))
	scope:Hydrate(edge[2])({
		Transparency = scope:Computed(function(use)
			return 1 - use(selectedT)
		end),
	})
	return scope:New("TextButton")(
		Controls.merge(
			{
				Name = title,
				LayoutOrder = order,
				Size = UDim2.fromOffset(0, 30),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = Theme.Ink,
				AutoButtonColor = false,
				Text = "",
				[OnEvent("Activated")] = onSelect,
				[Children] = {
					Controls.Fill(
						scope,
						scope:Computed(function(use)
							local sel = use(selectedT)
							return 0.075 * sel + 0.04 * use(interaction.HoverT) * (1 - sel)
						end)
					),
					edge,
					scope:New("UIPadding")({
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
					}),
					Controls.Label(
						scope,
						{
							Name = "Sizer",
							Size = UDim2.fromOffset(0, 30),
							AutomaticSize = Enum.AutomaticSize.X,
							Text = title,
							TextSize = 13,
							FontFace = Theme.Title,
							TextTransparency = 1,
							TextTruncate = Enum.TextTruncate.None,
						}
					),
					Controls.Label(
						scope,
						{
							Name = "Title",
							Size = UDim2.fromScale(1, 1),
							Text = title,
							TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Center,
							FontFace = scope:Computed(function(use)
								return if use(selected) then Theme.Title else Theme.Body
							end),
							TextColor3 = scope:Computed(function(use)
								return use(Theme.Muted):Lerp(
									use(Theme.Ink),
									math.max(use(selectedT), use(interaction.HoverT) * 0.6)
								)
							end),
							TextTruncate = Enum.TextTruncate.None,
						}
					),
				},
			},
			interaction.Events
		)
	)
end

return pill

end)() end,
    [58] = function()local wax,script,require=ImportGlobals(58)local ImportGlobals return (function(...)--!nolint LocalShadow
local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local States = require(Root.packages.states)
local Internal = require(Root.packages.internal)
local Themes = require(Root.ui.theme.palettes)
local ThemeUtils = require(Root.utils.themeUtils)

local scope = Internal.Scope

local peek = Fusion.peek

local currentThemeName = States.Theme

local function GetThemeConfig(themeName: string)
	return ThemeUtils.WithConfigDefaults(Themes.getTheme(themeName))
end

local function BuildTheme()
	LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
	ThemeUtils.SetThemeForScope(scope, GetThemeConfig(peek(currentThemeName)))
end

BuildTheme()

Fusion.Observer(scope, currentThemeName):onChange(BuildTheme)

local theme = ThemeUtils.GetThemeForScope(scope) :: any

local function GetSupportedThemes()
	return Themes.getThemeNames()
end

local function SetTheme(themeName)
	if Themes.getTheme(themeName) then
		currentThemeName:set(themeName)
	end
end

local function Preview(config)
	if config then
		ThemeUtils.SetThemeForScope(scope, ThemeUtils.WithConfigDefaults(config))
	else
		BuildTheme()
	end
end

local function Define(key: string, config)
	Themes.define(key, config)
	if peek(currentThemeName) == key then
		BuildTheme()
	end
end

local function Remove(key: string)
	Themes.remove(key)
end

local function Generate(config)
	return ThemeUtils.CreateTheme(ThemeUtils.WithConfigDefaults(config))
end

theme.GetThemeForScope = function(themeScope)
	return ThemeUtils.GetThemeForScope(themeScope) or theme
end
theme.SetThemeForScope = ThemeUtils.SetThemeForScope
theme.GetNextVariant = ThemeUtils.GetNextVariant
theme.CalcColorModifier = ThemeUtils.CalcColorModifier
theme.ApplyColorModifier = function(themeScope, color, modifier)
	return ThemeUtils.ApplyColorModifier(theme, themeScope, color, modifier)
end

theme.GetSupportedThemes = GetSupportedThemes
theme.SetTheme = SetTheme
theme.GetThemeConfig = GetThemeConfig
theme.IsPreset = Themes.isPreset
theme.Preview = Preview
theme.Define = Define
theme.Remove = Remove
theme.Generate = Generate

return theme

end)() end,
    [59] = function()local wax,script,require=ImportGlobals(59)local ImportGlobals return (function(...)local themeLoaders = {
	eclipse = script.eclipse,
	ember = script.ember,
	gold = script.gold,
	graphite = script.graphite,
	jade = script.jade,
	midnight = script.midnight,
	orchid = script.orchid,
	rose = script.rose,
	obsidian = script.obsidian,
	abyss = script.abyss,
	frost = script.frost,
	crimson = script.crimson,
	lagoon = script.lagoon,
	lavender = script.lavender,
	sunset = script.sunset,
	citrus = script.citrus,
	cobalt = script.cobalt,
	sakura = script.sakura,
	moss = script.moss,
	["high contrast"] = script.highContrast,
	terminal = script.terminal,
	synthwave = script.synthwave,
	coffee = script.coffee,
	paper = script.paper,
	daylight = script.daylight,
	sandstone = script.sandstone,
	["catppuccin mocha"] = script.catppuccinMocha,
	["catppuccin macchiato"] = script.catppuccinMacchiato,
	["catppuccin frappé"] = script.catppuccinFrappe,
	["catppuccin latte"] = script.catppuccinLatte,
	dracula = script.dracula,
	nord = script.nord,
	["gruvbox dark"] = script.gruvboxDark,
	["gruvbox light"] = script.gruvboxLight,
	["tokyo night"] = script.tokyoNight,
	["one dark"] = script.oneDark,
	["solarized dark"] = script.solarizedDark,
	["solarized light"] = script.solarizedLight,
	["rosé pine"] = script.rosePine,
	["rosé pine moon"] = script.rosePineMoon,
	["rosé pine dawn"] = script.rosePineDawn,
	kanagawa = script.kanagawa,
	everforest = script.everforest,
	["ayu dark"] = script.ayuDark,
	["ayu mirage"] = script.ayuMirage,
	["github dark"] = script.githubDark,
	["github light"] = script.githubLight,
	monokai = script.monokai,
	palenight = script.palenight,
	["night owl"] = script.nightOwl,
	["synthwave '84"] = script.synthwave84,
	vesper = script.vesper,
	poimandres = script.poimandres,
	oxocarbon = script.oxocarbon,
	horizon = script.horizon,
}

local loadedThemes = {}
local customThemes = {}

local function deepFreeze(tbl)
	if type(tbl) ~= "table" or table.isfrozen(tbl) then
		return tbl
	end
	for _, value in pairs(tbl) do
		if type(value) == "table" and not table.isfrozen(value) then
			deepFreeze(value)
		end
	end
	return table.freeze(tbl)
end

local function getTheme(name)
	if customThemes[name] then
		return customThemes[name]
	end
	if loadedThemes[name] then
		return loadedThemes[name]
	end
	local loader = themeLoaders[name]
	if not loader then
		return nil
	end
	local theme = require(loader)
	deepFreeze(theme)
	loadedThemes[name] = theme
	return theme
end

local function getThemeNames()
	local names = {}
	for name in pairs(themeLoaders) do
		table.insert(names, name)
	end
	for name in pairs(customThemes) do
		table.insert(names, name)
	end
	table.sort(names)
	return table.freeze(names)
end

local function isPreset(name)
	return themeLoaders[name] ~= nil
end

local function define(key, config)
	assert(not isPreset(key), `"{key}" is a built-in theme`)
	customThemes[key] = deepFreeze(table.clone(config))
end

local function remove(key)
	customThemes[key] = nil
end

return table.freeze({
	getTheme = getTheme,
	getThemeNames = getThemeNames,
	isPreset = isPreset,
	define = define,
	remove = remove,
})

end)() end,
    [60] = function()local wax,script,require=ImportGlobals(60)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Abyss: Deep teal-black with a bright cyan accent.
return {
	name = "abyss",
	title = "Abyss",
	BgBaseColor = hex("#0b1417"),
	AccentPrimary = hex("#2cc4d8"),
	AccentSecondary = hex("#5b8cf0"),
	AccentCaution = hex("#e8b04a"),
	AccentDestructive = hex("#f0607a"),
	Overrides = {
		FgPrimary = hex("#eef6f7"),
		FgSecondary = hex("#c3d3d6"),
		FgTertiary = hex("#8fa5aa"),
		FgQuaternary = hex("#728a8f"),
		FgQuinary = hex("#627a80"),
		Success = hex("#52cc84"),
	},
}

end)() end,
    [61] = function()local wax,script,require=ImportGlobals(61)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Ayu Dark: Ayu's deep dark variant with its golden accent.
return {
	name = "ayu dark",
	title = "Ayu Dark",
	BgBaseColor = hex("#0d1017"),
	AccentPrimary = hex("#e6b450"),
	AccentSecondary = hex("#39bae6"),
	AccentCaution = hex("#ff8f40"),
	AccentDestructive = hex("#f26d78"),
	Overrides = {
		BgSunken = hex("#0d1017"),
		FgPrimary = hex("#e6e1cf"),
		FgSecondary = hex("#bfbdb6"),
		FgTertiary = hex("#8f939a"),
		FgQuaternary = hex("#767b83"),
		FgQuinary = hex("#666b73"),
		Success = hex("#aad94c"),
	},
}

end)() end,
    [62] = function()local wax,script,require=ImportGlobals(62)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Ayu Mirage: Ayu's mid-tone variant.
return {
	name = "ayu mirage",
	title = "Ayu Mirage",
	BgBaseColor = hex("#1f2430"),
	AccentPrimary = hex("#ffcc66"),
	AccentSecondary = hex("#5ccfe6"),
	AccentCaution = hex("#ffad66"),
	AccentDestructive = hex("#ff6666"),
	Overrides = {
		BgSunken = hex("#1f2430"),
		FgPrimary = hex("#e6e1cf"),
		FgSecondary = hex("#cccac2"),
		FgTertiary = hex("#a0a3ab"),
		FgQuaternary = hex("#8a8e98"),
		FgQuinary = hex("#7a7e88"),
		Success = hex("#d5ff80"),
	},
}

end)() end,
    [63] = function()local wax,script,require=ImportGlobals(63)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Catppuccin Frappé: Catppuccin's muted flavour, mauve accent.
return {
	name = "catppuccin frappé",
	title = "Catppuccin Frappé",
	BgBaseColor = hex("#303446"),
	AccentPrimary = hex("#ca9ee6"),
	AccentSecondary = hex("#8caaee"),
	AccentCaution = hex("#e5c890"),
	AccentDestructive = hex("#e78284"),
	Overrides = {
		BgSunken = hex("#303446"),
		FgPrimary = hex("#c6d0f5"),
		FgSecondary = hex("#b5bfe2"),
		FgTertiary = hex("#a5adce"),
		FgQuaternary = hex("#949cbb"),
		FgQuinary = hex("#838ba7"),
		Success = hex("#a6d189"),
	},
}

end)() end,
    [64] = function()local wax,script,require=ImportGlobals(64)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Catppuccin Latte: Catppuccin's light flavour, mauve accent.
return {
	name = "catppuccin latte",
	title = "Catppuccin Latte",
	BgBaseColor = hex("#eff1f5"),
	AccentPrimary = hex("#8839ef"),
	AccentSecondary = hex("#1e66f5"),
	AccentCaution = hex("#985a08"),
	AccentDestructive = hex("#d20f39"),
	Overrides = {
		BgSunken = hex("#eff1f5"),
		FgPrimary = hex("#4c4f69"),
		FgSecondary = hex("#5c5f77"),
		FgTertiary = hex("#63667c"),
		FgQuaternary = hex("#74778c"),
		FgQuinary = hex("#84879a"),
		Success = hex("#2f7a1f"),
	},
}

end)() end,
    [65] = function()local wax,script,require=ImportGlobals(65)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Catppuccin Macchiato: Catppuccin's medium-dark flavour, mauve accent.
return {
	name = "catppuccin macchiato",
	title = "Catppuccin Macchiato",
	BgBaseColor = hex("#24273a"),
	AccentPrimary = hex("#c6a0f6"),
	AccentSecondary = hex("#8aadf4"),
	AccentCaution = hex("#eed49f"),
	AccentDestructive = hex("#ed8796"),
	Overrides = {
		BgSunken = hex("#24273a"),
		FgPrimary = hex("#cad3f5"),
		FgSecondary = hex("#b8c0e0"),
		FgTertiary = hex("#a5adcb"),
		FgQuaternary = hex("#939ab7"),
		FgQuinary = hex("#8087a2"),
		Success = hex("#a6da95"),
	},
}

end)() end,
    [66] = function()local wax,script,require=ImportGlobals(66)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Catppuccin Mocha: Catppuccin's darkest flavour, mauve accent.
return {
	name = "catppuccin mocha",
	title = "Catppuccin Mocha",
	BgBaseColor = hex("#1e1e2e"),
	AccentPrimary = hex("#cba6f7"),
	AccentSecondary = hex("#89b4fa"),
	AccentCaution = hex("#f9e2af"),
	AccentDestructive = hex("#f38ba8"),
	Overrides = {
		BgSunken = hex("#1e1e2e"),
		FgPrimary = hex("#cdd6f4"),
		FgSecondary = hex("#bac2de"),
		FgTertiary = hex("#a6adc8"),
		FgQuaternary = hex("#9399b2"),
		FgQuinary = hex("#7f849c"),
		Success = hex("#a6e3a1"),
	},
}

end)() end,
    [67] = function()local wax,script,require=ImportGlobals(67)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Citrus: Olive-black with a lime accent.
return {
	name = "citrus",
	title = "Citrus",
	BgBaseColor = hex("#121510"),
	AccentPrimary = hex("#a6e22e"),
	AccentSecondary = hex("#e6d046"),
	AccentCaution = hex("#f0a83c"),
	AccentDestructive = hex("#f2606a"),
	Overrides = {
		FgPrimary = hex("#f2f6ec"),
		FgSecondary = hex("#cfd6c4"),
		FgTertiary = hex("#9ea692"),
		FgQuaternary = hex("#7f8874"),
		FgQuinary = hex("#707864"),
		Success = hex("#4fd1a0"),
	},
}

end)() end,
    [68] = function()local wax,script,require=ImportGlobals(68)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Cobalt: Ink-blue surfaces with a vivid cobalt accent.
return {
	name = "cobalt",
	title = "Cobalt",
	BgBaseColor = hex("#0d1220"),
	AccentPrimary = hex("#3d7bfd"),
	AccentSecondary = hex("#22c3e6"),
	AccentCaution = hex("#f0b44c"),
	AccentDestructive = hex("#f45d6e"),
	Overrides = {
		FgPrimary = hex("#eef2fb"),
		FgSecondary = hex("#c4cde2"),
		FgTertiary = hex("#8f9bb7"),
		FgQuaternary = hex("#73809c"),
		FgQuinary = hex("#64708c"),
		Success = hex("#4fd08a"),
	},
}

end)() end,
    [69] = function()local wax,script,require=ImportGlobals(69)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Coffee: Espresso browns with cream text and a caramel accent.
return {
	name = "coffee",
	title = "Coffee",
	BgBaseColor = hex("#1c1612"),
	AccentPrimary = hex("#d4a056"),
	AccentSecondary = hex("#c27c5a"),
	AccentCaution = hex("#e8b04a"),
	AccentDestructive = hex("#e8645a"),
	Overrides = {
		BgSunken = hex("#18130f"),
		FgPrimary = hex("#f3e9dc"),
		FgSecondary = hex("#d6c6b2"),
		FgTertiary = hex("#a8957f"),
		FgQuaternary = hex("#8a7864"),
		FgQuinary = hex("#796856"),
		Success = hex("#9cc46a"),
	},
}

end)() end,
    [70] = function()local wax,script,require=ImportGlobals(70)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Crimson: Charcoal with a crimson accent. Errors lean orange to stay apart from it.
return {
	name = "crimson",
	title = "Crimson",
	BgBaseColor = hex("#161214"),
	AccentPrimary = hex("#e0344f"),
	AccentSecondary = hex("#e88a5a"),
	AccentCaution = hex("#eab24c"),
	AccentDestructive = hex("#ff7a45"),
	Overrides = {
		FgPrimary = hex("#f7f2f3"),
		FgSecondary = hex("#d3c7ca"),
		FgTertiary = hex("#a3959a"),
		FgQuaternary = hex("#85777c"),
		FgQuinary = hex("#75686c"),
		Success = hex("#56c97c"),
	},
}

end)() end,
    [71] = function()local wax,script,require=ImportGlobals(71)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Daylight: Clean cool white with a blue accent.
return {
	name = "daylight",
	title = "Daylight",
	BgBaseColor = hex("#f5f7fa"),
	AccentPrimary = hex("#2563eb"),
	AccentSecondary = hex("#0e8f9f"),
	AccentCaution = hex("#9a6100"),
	AccentDestructive = hex("#c8243a"),
	Overrides = {
		BgSunken = hex("#f5f7fa"),
		FgPrimary = hex("#14181f"),
		FgSecondary = hex("#363d49"),
		FgTertiary = hex("#555e6c"),
		FgQuaternary = hex("#6c7584"),
		FgQuinary = hex("#7f8896"),
		Success = hex("#1d7a3e"),
	},
}

end)() end,
    [72] = function()local wax,script,require=ImportGlobals(72)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Dracula: The classic purple-accented dark theme.
return {
	name = "dracula",
	title = "Dracula",
	BgBaseColor = hex("#282a36"),
	AccentPrimary = hex("#bd93f9"),
	AccentSecondary = hex("#ff79c6"),
	AccentCaution = hex("#f1fa8c"),
	AccentDestructive = hex("#ff6e6e"),
	Overrides = {
		BgSunken = hex("#282a36"),
		FgPrimary = hex("#f8f8f2"),
		FgSecondary = hex("#d6d6e0"),
		FgTertiary = hex("#a9b0d0"),
		FgQuaternary = hex("#8e98c4"),
		FgQuinary = hex("#7a86b8"),
		Success = hex("#50fa7b"),
	},
}

end)() end,
    [73] = function()local wax,script,require=ImportGlobals(73)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Eclipse: cool slate with an indigo accent. The look window v2 was designed on.
return {
	name = "eclipse",
	BgBaseColor = rgb(18, 18, 22),
	AccentPrimary = rgb(70, 100, 210),
	AccentSecondary = rgb(55, 165, 185),
	AccentCaution = rgb(230, 165, 60),
	AccentDestructive = rgb(229, 72, 77),
}

end)() end,
    [74] = function()local wax,script,require=ImportGlobals(74)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Ember: warm brown-black surfaces with an orange accent. Errors lean crimson to stay apart from it.
return {
	name = "ember",
	BgBaseColor = rgb(22, 17, 14),
	AccentPrimary = rgb(240, 110, 40),
	AccentSecondary = rgb(230, 175, 60),
	AccentCaution = rgb(230, 175, 60),
	AccentDestructive = rgb(225, 65, 90),
}

end)() end,
    [75] = function()local wax,script,require=ImportGlobals(75)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Everforest: Comfortable forest greens with a green accent.
return {
	name = "everforest",
	title = "Everforest",
	BgBaseColor = hex("#2d353b"),
	AccentPrimary = hex("#a7c080"),
	AccentSecondary = hex("#7fbbb3"),
	AccentCaution = hex("#dbbc7f"),
	AccentDestructive = hex("#e67e80"),
	Overrides = {
		BgSunken = hex("#2d353b"),
		FgPrimary = hex("#d3c6aa"),
		FgSecondary = hex("#c2b89f"),
		FgTertiary = hex("#a7b0a6"),
		FgQuaternary = hex("#939f95"),
		FgQuinary = hex("#859289"),
		Success = hex("#83c092"),
	},
}

end)() end,
    [76] = function()local wax,script,require=ImportGlobals(76)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Frost: Steel-blue surfaces with an icy accent.
return {
	name = "frost",
	title = "Frost",
	BgBaseColor = hex("#141a22"),
	AccentPrimary = hex("#7cc4f2"),
	AccentSecondary = hex("#9aa8f5"),
	AccentCaution = hex("#e9b354"),
	AccentDestructive = hex("#f06b74"),
	Overrides = {
		FgPrimary = hex("#f0f4f9"),
		FgSecondary = hex("#c6d0dc"),
		FgTertiary = hex("#93a1b2"),
		FgQuaternary = hex("#768596"),
		FgQuinary = hex("#667586"),
		Success = hex("#5fcf8f"),
	},
}

end)() end,
    [77] = function()local wax,script,require=ImportGlobals(77)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- GitHub Dark: GitHub's dark default.
return {
	name = "github dark",
	title = "GitHub Dark",
	BgBaseColor = hex("#0d1117"),
	AccentPrimary = hex("#4493f8"),
	AccentSecondary = hex("#a371f7"),
	AccentCaution = hex("#d29922"),
	AccentDestructive = hex("#f85149"),
	Overrides = {
		BgSunken = hex("#0d1117"),
		FgPrimary = hex("#e6edf3"),
		FgSecondary = hex("#c9d1d9"),
		FgTertiary = hex("#9198a1"),
		FgQuaternary = hex("#7d8590"),
		FgQuinary = hex("#6e7681"),
		Success = hex("#3fb950"),
	},
}

end)() end,
    [78] = function()local wax,script,require=ImportGlobals(78)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- GitHub Light: GitHub's light default.
return {
	name = "github light",
	title = "GitHub Light",
	BgBaseColor = hex("#ffffff"),
	AccentPrimary = hex("#0969da"),
	AccentSecondary = hex("#8250df"),
	AccentCaution = hex("#9a6700"),
	AccentDestructive = hex("#d1242f"),
	Overrides = {
		BgSunken = hex("#ffffff"),
		FgPrimary = hex("#1f2328"),
		FgSecondary = hex("#31373d"),
		FgTertiary = hex("#59636e"),
		FgQuaternary = hex("#6e7781"),
		FgQuinary = hex("#818b98"),
		Success = hex("#1a7f37"),
	},
}

end)() end,
    [79] = function()local wax,script,require=ImportGlobals(79)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Gold: olive-sand surfaces with an amber accent. Warnings turn orange to stay apart from it.
return {
	name = "gold",
	BgBaseColor = rgb(20, 19, 14),
	AccentPrimary = rgb(240, 180, 40),
	AccentSecondary = rgb(190, 140, 80),
	AccentCaution = rgb(240, 130, 60),
	AccentDestructive = rgb(229, 72, 77),
}

end)() end,
    [80] = function()local wax,script,require=ImportGlobals(80)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Graphite: neutral near-black with a white accent, for an all-monochrome window.
return {
	name = "graphite",
	BgBaseColor = rgb(14, 14, 14),
	AccentPrimary = rgb(230, 230, 230),
	AccentSecondary = rgb(150, 150, 156),
	AccentCaution = rgb(230, 165, 60),
	AccentDestructive = rgb(229, 72, 77),
}

end)() end,
    [81] = function()local wax,script,require=ImportGlobals(81)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Gruvbox Dark: Retro warm browns with cream text and an orange accent.
return {
	name = "gruvbox dark",
	title = "Gruvbox Dark",
	BgBaseColor = hex("#282828"),
	AccentPrimary = hex("#fe8019"),
	AccentSecondary = hex("#83a598"),
	AccentCaution = hex("#fabd2f"),
	AccentDestructive = hex("#fd5f4c"),
	Overrides = {
		BgSunken = hex("#282828"),
		FgPrimary = hex("#ebdbb2"),
		FgSecondary = hex("#d5c4a1"),
		FgTertiary = hex("#bdae93"),
		FgQuaternary = hex("#a89984"),
		FgQuinary = hex("#928374"),
		Success = hex("#b8bb26"),
	},
}

end)() end,
    [82] = function()local wax,script,require=ImportGlobals(82)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Gruvbox Light: Gruvbox on its cream background.
return {
	name = "gruvbox light",
	title = "Gruvbox Light",
	BgBaseColor = hex("#fbf1c7"),
	AccentPrimary = hex("#af3a03"),
	AccentSecondary = hex("#076678"),
	AccentCaution = hex("#8a5a0f"),
	AccentDestructive = hex("#9d0006"),
	Overrides = {
		BgSunken = hex("#fbf1c7"),
		FgPrimary = hex("#3c3836"),
		FgSecondary = hex("#504945"),
		FgTertiary = hex("#665c54"),
		FgQuaternary = hex("#7c6f64"),
		FgQuinary = hex("#928374"),
		Success = hex("#5f5b0a"),
	},
}

end)() end,
    [83] = function()local wax,script,require=ImportGlobals(83)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- High contrast: Pure black, white text and a yellow accent. The most legible theme.
return {
	name = "high contrast",
	title = "High contrast",
	BgBaseColor = hex("#000000"),
	AccentPrimary = hex("#ffd400"),
	AccentSecondary = hex("#00e5ff"),
	AccentCaution = hex("#ffb000"),
	AccentDestructive = hex("#ff5c5c"),
	Overrides = {
		BgSunken = hex("#000000"),
		FgPrimary = hex("#ffffff"),
		FgSecondary = hex("#f0f0f0"),
		FgTertiary = hex("#d0d0d0"),
		FgQuaternary = hex("#b8b8b8"),
		FgQuinary = hex("#a8a8a8"),
		Success = hex("#3dff7a"),
	},
}

end)() end,
    [84] = function()local wax,script,require=ImportGlobals(84)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Horizon: Warm dark with a rose accent.
return {
	name = "horizon",
	title = "Horizon",
	BgBaseColor = hex("#1c1e26"),
	AccentPrimary = hex("#e95678"),
	AccentSecondary = hex("#fab795"),
	AccentCaution = hex("#fac29a"),
	AccentDestructive = hex("#f6661e"),
	Overrides = {
		BgSunken = hex("#1c1e26"),
		FgPrimary = hex("#e0e0e0"),
		FgSecondary = hex("#cbced0"),
		FgTertiary = hex("#9ea2a8"),
		FgQuaternary = hex("#878b92"),
		FgQuinary = hex("#777b82"),
		Success = hex("#29d398"),
	},
}

end)() end,
    [85] = function()local wax,script,require=ImportGlobals(85)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Jade: green-grey surfaces with a jade accent.
return {
	name = "jade",
	BgBaseColor = rgb(13, 20, 18),
	AccentPrimary = rgb(38, 170, 130),
	AccentSecondary = rgb(70, 170, 200),
	AccentCaution = rgb(230, 165, 60),
	AccentDestructive = rgb(229, 72, 77),
}

end)() end,
    [86] = function()local wax,script,require=ImportGlobals(86)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Kanagawa: Hokusai's Great Wave: ink blues and old-paper text.
return {
	name = "kanagawa",
	title = "Kanagawa",
	BgBaseColor = hex("#1f1f28"),
	AccentPrimary = hex("#7e9cd8"),
	AccentSecondary = hex("#957fb8"),
	AccentCaution = hex("#e6c384"),
	AccentDestructive = hex("#ff5d62"),
	Overrides = {
		BgSunken = hex("#1f1f28"),
		FgPrimary = hex("#dcd7ba"),
		FgSecondary = hex("#c8c093"),
		FgTertiary = hex("#a6a69c"),
		FgQuaternary = hex("#8f8e86"),
		FgQuinary = hex("#7a7a72"),
		Success = hex("#98bb6c"),
	},
}

end)() end,
    [87] = function()local wax,script,require=ImportGlobals(87)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Lagoon: Blue-green surfaces with a turquoise accent.
return {
	name = "lagoon",
	title = "Lagoon",
	BgBaseColor = hex("#0f1a1c"),
	AccentPrimary = hex("#1fb8a4"),
	AccentSecondary = hex("#4aa3e8"),
	AccentCaution = hex("#e6b450"),
	AccentDestructive = hex("#ef6670"),
	Overrides = {
		FgPrimary = hex("#edf7f6"),
		FgSecondary = hex("#c2d6d4"),
		FgTertiary = hex("#8ea9a6"),
		FgQuaternary = hex("#71908d"),
		FgQuinary = hex("#62807d"),
		Success = hex("#6ccf6a"),
	},
}

end)() end,
    [88] = function()local wax,script,require=ImportGlobals(88)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Lavender: Cool grey with a soft lilac accent.
return {
	name = "lavender",
	title = "Lavender",
	BgBaseColor = hex("#16151c"),
	AccentPrimary = hex("#b49cf5"),
	AccentSecondary = hex("#f0a0d0"),
	AccentCaution = hex("#ebb75a"),
	AccentDestructive = hex("#f36b7f"),
	Overrides = {
		FgPrimary = hex("#f3f1f8"),
		FgSecondary = hex("#cdc9da"),
		FgTertiary = hex("#9d98ae"),
		FgQuaternary = hex("#7f7a90"),
		FgQuinary = hex("#6f6a80"),
		Success = hex("#62cf90"),
	},
}

end)() end,
    [89] = function()local wax,script,require=ImportGlobals(89)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Midnight: deep navy surfaces with a sky-blue accent.
return {
	name = "midnight",
	BgBaseColor = rgb(11, 16, 28),
	AccentPrimary = rgb(78, 178, 250),
	AccentSecondary = rgb(110, 130, 240),
	AccentCaution = rgb(230, 165, 60),
	AccentDestructive = rgb(229, 72, 77),
}

end)() end,
    [90] = function()local wax,script,require=ImportGlobals(90)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Monokai: The original Monokai: hot pink, lime and orange on olive-black.
return {
	name = "monokai",
	title = "Monokai",
	BgBaseColor = hex("#272822"),
	AccentPrimary = hex("#a6e22e"),
	AccentSecondary = hex("#66d9ef"),
	AccentCaution = hex("#e6db74"),
	AccentDestructive = hex("#ff4f88"),
	Overrides = {
		BgSunken = hex("#272822"),
		FgPrimary = hex("#f8f8f2"),
		FgSecondary = hex("#d6d6cc"),
		FgTertiary = hex("#a8a593"),
		FgQuaternary = hex("#908d7b"),
		FgQuinary = hex("#7d7a68"),
		Success = hex("#a6e22e"),
	},
}

end)() end,
    [91] = function()local wax,script,require=ImportGlobals(91)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Moss: Forest-floor greens with a sage accent.
return {
	name = "moss",
	title = "Moss",
	BgBaseColor = hex("#121611"),
	AccentPrimary = hex("#8fbf6a"),
	AccentSecondary = hex("#d6b25e"),
	AccentCaution = hex("#e8a24a"),
	AccentDestructive = hex("#ec6a5e"),
	Overrides = {
		FgPrimary = hex("#eef3ea"),
		FgSecondary = hex("#c9d2c2"),
		FgTertiary = hex("#97a28e"),
		FgQuaternary = hex("#7a8571"),
		FgQuinary = hex("#6b7562"),
		Success = hex("#5fcf9a"),
	},
}

end)() end,
    [92] = function()local wax,script,require=ImportGlobals(92)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Night Owl: Night Owl, for late-night coding.
return {
	name = "night owl",
	title = "Night Owl",
	BgBaseColor = hex("#011627"),
	AccentPrimary = hex("#82aaff"),
	AccentSecondary = hex("#c792ea"),
	AccentCaution = hex("#ecc48d"),
	AccentDestructive = hex("#ef5350"),
	Overrides = {
		BgSunken = hex("#011627"),
		FgPrimary = hex("#d6deeb"),
		FgSecondary = hex("#bcc6d6"),
		FgTertiary = hex("#8fa0b5"),
		FgQuaternary = hex("#7a8ba0"),
		FgQuinary = hex("#6b7c90"),
		Success = hex("#addb67"),
	},
}

end)() end,
    [93] = function()local wax,script,require=ImportGlobals(93)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Nord: Arctic polar night with frost-blue accents.
return {
	name = "nord",
	title = "Nord",
	BgBaseColor = hex("#2e3440"),
	AccentPrimary = hex("#88c0d0"),
	AccentSecondary = hex("#81a1c1"),
	AccentCaution = hex("#ebcb8b"),
	AccentDestructive = hex("#d9868c"),
	Overrides = {
		BgSunken = hex("#2e3440"),
		FgPrimary = hex("#eceff4"),
		FgSecondary = hex("#e5e9f0"),
		FgTertiary = hex("#c0c8d6"),
		FgQuaternary = hex("#a3adbf"),
		FgQuinary = hex("#8e99ad"),
		Success = hex("#a3be8c"),
	},
}

end)() end,
    [94] = function()local wax,script,require=ImportGlobals(94)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Obsidian: Near-black with a soft violet accent, close to the default look but darker.
return {
	name = "obsidian",
	title = "Obsidian",
	BgBaseColor = hex("#101014"),
	AccentPrimary = hex("#8b6cf0"),
	AccentSecondary = hex("#5aa8e0"),
	AccentCaution = hex("#e8a94a"),
	AccentDestructive = hex("#ef5a6a"),
	Overrides = {
		FgPrimary = hex("#f4f4f8"),
		FgSecondary = hex("#c9c9d3"),
		FgTertiary = hex("#9a9aa8"),
		FgQuaternary = hex("#7a7a88"),
		FgQuinary = hex("#6a6a78"),
		Success = hex("#4cc77a"),
	},
}

end)() end,
    [95] = function()local wax,script,require=ImportGlobals(95)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- One Dark: Atom's One Dark with a blue accent.
return {
	name = "one dark",
	title = "One Dark",
	BgBaseColor = hex("#282c34"),
	AccentPrimary = hex("#61afef"),
	AccentSecondary = hex("#c678dd"),
	AccentCaution = hex("#e5c07b"),
	AccentDestructive = hex("#e8747d"),
	Overrides = {
		BgSunken = hex("#282c34"),
		FgPrimary = hex("#d7dae0"),
		FgSecondary = hex("#abb2bf"),
		FgTertiary = hex("#9aa1ad"),
		FgQuaternary = hex("#858b97"),
		FgQuinary = hex("#737985"),
		Success = hex("#98c379"),
	},
}

end)() end,
    [96] = function()local wax,script,require=ImportGlobals(96)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Orchid: aubergine surfaces with a violet accent.
return {
	name = "orchid",
	BgBaseColor = rgb(20, 16, 26),
	AccentPrimary = rgb(128, 84, 224),
	AccentSecondary = rgb(220, 80, 160),
	AccentCaution = rgb(230, 165, 60),
	AccentDestructive = rgb(229, 72, 77),
}

end)() end,
    [97] = function()local wax,script,require=ImportGlobals(97)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Oxocarbon: IBM Carbon greys with a blue accent.
return {
	name = "oxocarbon",
	title = "Oxocarbon",
	BgBaseColor = hex("#161616"),
	AccentPrimary = hex("#78a9ff"),
	AccentSecondary = hex("#be95ff"),
	AccentCaution = hex("#ffd57e"),
	AccentDestructive = hex("#ee5396"),
	Overrides = {
		BgSunken = hex("#161616"),
		FgPrimary = hex("#f2f4f8"),
		FgSecondary = hex("#dde1e6"),
		FgTertiary = hex("#a8adb5"),
		FgQuaternary = hex("#8d929a"),
		FgQuinary = hex("#7a7f87"),
		Success = hex("#42be65"),
	},
}

end)() end,
    [98] = function()local wax,script,require=ImportGlobals(98)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Palenight: Material Palenight: lavender-grey with a purple accent.
return {
	name = "palenight",
	title = "Palenight",
	BgBaseColor = hex("#292d3e"),
	AccentPrimary = hex("#c792ea"),
	AccentSecondary = hex("#82aaff"),
	AccentCaution = hex("#ffcb6b"),
	AccentDestructive = hex("#ff6680"),
	Overrides = {
		BgSunken = hex("#292d3e"),
		FgPrimary = hex("#d0d6f0"),
		FgSecondary = hex("#bfc7d5"),
		FgTertiary = hex("#a6accd"),
		FgQuaternary = hex("#8d93b8"),
		FgQuinary = hex("#7b81a6"),
		Success = hex("#c3e88d"),
	},
}

end)() end,
    [99] = function()local wax,script,require=ImportGlobals(99)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Paper: Warm off-white, like a notebook page, with an ink-blue accent.
return {
	name = "paper",
	title = "Paper",
	BgBaseColor = hex("#f7f4ec"),
	AccentPrimary = hex("#2f5bd3"),
	AccentSecondary = hex("#b0532c"),
	AccentCaution = hex("#9a5b00"),
	AccentDestructive = hex("#c0262d"),
	Overrides = {
		BgSunken = hex("#f7f4ec"),
		FgPrimary = hex("#24211c"),
		FgSecondary = hex("#45403a"),
		FgTertiary = hex("#5f5950"),
		FgQuaternary = hex("#77706a"),
		FgQuinary = hex("#8a8379"),
		Success = hex("#2a7a3b"),
	},
}

end)() end,
    [100] = function()local wax,script,require=ImportGlobals(100)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Poimandres: Calm blue-grey with mint and sky accents.
return {
	name = "poimandres",
	title = "Poimandres",
	BgBaseColor = hex("#1b1e28"),
	AccentPrimary = hex("#5de4c7"),
	AccentSecondary = hex("#89ddff"),
	AccentCaution = hex("#fffac2"),
	AccentDestructive = hex("#e07aaf"),
	Overrides = {
		BgSunken = hex("#1b1e28"),
		FgPrimary = hex("#e4f0fb"),
		FgSecondary = hex("#c7d0e0"),
		FgTertiary = hex("#a6accd"),
		FgQuaternary = hex("#8e94b8"),
		FgQuinary = hex("#7d83a6"),
		Success = hex("#5de4c7"),
	},
}

end)() end,
    [101] = function()local wax,script,require=ImportGlobals(101)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local rgb = utils.rgb

-- Rose: plum-black surfaces with a deep rose accent. Errors lean orange-red to stay apart from it.
return {
	name = "rose",
	BgBaseColor = rgb(22, 15, 19),
	AccentPrimary = rgb(200, 45, 105),
	AccentSecondary = rgb(170, 90, 220),
	AccentCaution = rgb(230, 165, 60),
	AccentDestructive = rgb(232, 80, 60),
}

end)() end,
    [102] = function()local wax,script,require=ImportGlobals(102)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Rosé Pine: Pine, faux fur and a bit of soho vibes.
return {
	name = "rosé pine",
	title = "Rosé Pine",
	BgBaseColor = hex("#191724"),
	AccentPrimary = hex("#c4a7e7"),
	AccentSecondary = hex("#ebbcba"),
	AccentCaution = hex("#f6c177"),
	AccentDestructive = hex("#eb6f92"),
	Overrides = {
		BgSunken = hex("#191724"),
		FgPrimary = hex("#e0def4"),
		FgSecondary = hex("#c7c3e0"),
		FgTertiary = hex("#908caa"),
		FgQuaternary = hex("#7e7a98"),
		FgQuinary = hex("#6e6a86"),
		Success = hex("#9ccfd8"),
	},
}

end)() end,
    [103] = function()local wax,script,require=ImportGlobals(103)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Rosé Pine Dawn: Rosé Pine's light variant.
return {
	name = "rosé pine dawn",
	title = "Rosé Pine Dawn",
	BgBaseColor = hex("#faf4ed"),
	AccentPrimary = hex("#907aa9"),
	AccentSecondary = hex("#d7827e"),
	AccentCaution = hex("#945c10"),
	AccentDestructive = hex("#a24e68"),
	Overrides = {
		BgSunken = hex("#faf4ed"),
		FgPrimary = hex("#575279"),
		FgSecondary = hex("#625d84"),
		FgTertiary = hex("#6e6a8e"),
		FgQuaternary = hex("#797593"),
		FgQuinary = hex("#8a86a0"),
		Success = hex("#286983"),
	},
}

end)() end,
    [104] = function()local wax,script,require=ImportGlobals(104)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Rosé Pine Moon: Rosé Pine's softer moonlit variant.
return {
	name = "rosé pine moon",
	title = "Rosé Pine Moon",
	BgBaseColor = hex("#232136"),
	AccentPrimary = hex("#c4a7e7"),
	AccentSecondary = hex("#ea9a97"),
	AccentCaution = hex("#f6c177"),
	AccentDestructive = hex("#eb6f92"),
	Overrides = {
		BgSunken = hex("#232136"),
		FgPrimary = hex("#e0def4"),
		FgSecondary = hex("#c7c3e0"),
		FgTertiary = hex("#a09cbc"),
		FgQuaternary = hex("#8b87a8"),
		FgQuinary = hex("#7a7696"),
		Success = hex("#9ccfd8"),
	},
}

end)() end,
    [105] = function()local wax,script,require=ImportGlobals(105)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Sakura: Rose-grey with a cherry-blossom accent.
return {
	name = "sakura",
	title = "Sakura",
	BgBaseColor = hex("#1a1519"),
	AccentPrimary = hex("#f49ac1"),
	AccentSecondary = hex("#c3a2f0"),
	AccentCaution = hex("#efb85a"),
	AccentDestructive = hex("#ff6b6b"),
	Overrides = {
		FgPrimary = hex("#fbf2f6"),
		FgSecondary = hex("#dcc9d2"),
		FgTertiary = hex("#ab95a0"),
		FgQuaternary = hex("#8c7782"),
		FgQuinary = hex("#7b6772"),
		Success = hex("#6fd29a"),
	},
}

end)() end,
    [106] = function()local wax,script,require=ImportGlobals(106)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Sandstone: Light sand with a terracotta accent.
return {
	name = "sandstone",
	title = "Sandstone",
	BgBaseColor = hex("#f3ece2"),
	AccentPrimary = hex("#b5532f"),
	AccentSecondary = hex("#5a7a3a"),
	AccentCaution = hex("#8f5d00"),
	AccentDestructive = hex("#b3261e"),
	Overrides = {
		BgSunken = hex("#f3ece2"),
		FgPrimary = hex("#2b231c"),
		FgSecondary = hex("#4a3f35"),
		FgTertiary = hex("#665a4e"),
		FgQuaternary = hex("#7c7064"),
		FgQuinary = hex("#8c8073"),
		Success = hex("#3d7034"),
	},
}

end)() end,
    [107] = function()local wax,script,require=ImportGlobals(107)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Solarized Dark: Solarized on base03.
return {
	name = "solarized dark",
	title = "Solarized Dark",
	BgBaseColor = hex("#002b36"),
	AccentPrimary = hex("#268bd2"),
	AccentSecondary = hex("#2aa198"),
	AccentCaution = hex("#b58900"),
	AccentDestructive = hex("#f2625a"),
	Overrides = {
		BgSunken = hex("#002b36"),
		FgPrimary = hex("#eee8d5"),
		FgSecondary = hex("#93a1a1"),
		FgTertiary = hex("#839496"),
		FgQuaternary = hex("#73888c"),
		FgQuinary = hex("#657b83"),
		Success = hex("#859900"),
	},
}

end)() end,
    [108] = function()local wax,script,require=ImportGlobals(108)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Solarized Light: Solarized on base3.
return {
	name = "solarized light",
	title = "Solarized Light",
	BgBaseColor = hex("#fdf6e3"),
	AccentPrimary = hex("#268bd2"),
	AccentSecondary = hex("#2aa198"),
	AccentCaution = hex("#8a6800"),
	AccentDestructive = hex("#c4291f"),
	Overrides = {
		BgSunken = hex("#fdf6e3"),
		FgPrimary = hex("#073642"),
		FgSecondary = hex("#2f4c54"),
		FgTertiary = hex("#4d636a"),
		FgQuaternary = hex("#5f747a"),
		FgQuinary = hex("#788a8e"),
		Success = hex("#5c6b00"),
	},
}

end)() end,
    [109] = function()local wax,script,require=ImportGlobals(109)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Sunset: Dusky plum with a coral accent and amber highlights.
return {
	name = "sunset",
	title = "Sunset",
	BgBaseColor = hex("#1a1418"),
	AccentPrimary = hex("#ff7a59"),
	AccentSecondary = hex("#ffb347"),
	AccentCaution = hex("#ffc94d"),
	AccentDestructive = hex("#ff5c8a"),
	Overrides = {
		FgPrimary = hex("#faf1ef"),
		FgSecondary = hex("#dccac7"),
		FgTertiary = hex("#ab9794"),
		FgQuaternary = hex("#8c7976"),
		FgQuinary = hex("#7b6966"),
		Success = hex("#5fd08a"),
	},
}

end)() end,
    [110] = function()local wax,script,require=ImportGlobals(110)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Synthwave: Midnight purple with neon pink and cyan.
return {
	name = "synthwave",
	title = "Synthwave",
	BgBaseColor = hex("#1a1029"),
	AccentPrimary = hex("#ff4fd8"),
	AccentSecondary = hex("#2de2e6"),
	AccentCaution = hex("#ffd319"),
	AccentDestructive = hex("#ff6b6b"),
	Overrides = {
		BgSunken = hex("#160d24"),
		FgPrimary = hex("#fbefff"),
		FgSecondary = hex("#dccbe8"),
		FgTertiary = hex("#ad98bf"),
		FgQuaternary = hex("#8e78a2"),
		FgQuinary = hex("#7e6892"),
		Success = hex("#72f1b8"),
	},
}

end)() end,
    [111] = function()local wax,script,require=ImportGlobals(111)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Synthwave '84: The Synthwave '84 neon palette.
return {
	name = "synthwave '84",
	title = "Synthwave '84",
	BgBaseColor = hex("#262335"),
	AccentPrimary = hex("#ff7edb"),
	AccentSecondary = hex("#36f9f6"),
	AccentCaution = hex("#fede5d"),
	AccentDestructive = hex("#fe5562"),
	Overrides = {
		BgSunken = hex("#262335"),
		FgPrimary = hex("#f0eff1"),
		FgSecondary = hex("#d7d2e4"),
		FgTertiary = hex("#ab9fc4"),
		FgQuaternary = hex("#9488ad"),
		FgQuinary = hex("#83789c"),
		Success = hex("#72f1b8"),
	},
}

end)() end,
    [112] = function()local wax,script,require=ImportGlobals(112)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Terminal: Phosphor green on black, like an old CRT.
return {
	name = "terminal",
	title = "Terminal",
	BgBaseColor = hex("#050a06"),
	AccentPrimary = hex("#33ff66"),
	AccentSecondary = hex("#ffcc33"),
	AccentCaution = hex("#ffcc33"),
	AccentDestructive = hex("#ff5f56"),
	Overrides = {
		BgSunken = hex("#050a06"),
		FgPrimary = hex("#c8ffcf"),
		FgSecondary = hex("#9ae6a6"),
		FgTertiary = hex("#6cbd7a"),
		FgQuaternary = hex("#58a166"),
		FgQuinary = hex("#4c9059"),
		Success = hex("#7dff9a"),
	},
}

end)() end,
    [113] = function()local wax,script,require=ImportGlobals(113)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Tokyo Night: Night-city navy with a blue accent.
return {
	name = "tokyo night",
	title = "Tokyo Night",
	BgBaseColor = hex("#1a1b26"),
	AccentPrimary = hex("#7aa2f7"),
	AccentSecondary = hex("#bb9af7"),
	AccentCaution = hex("#e0af68"),
	AccentDestructive = hex("#f7768e"),
	Overrides = {
		BgSunken = hex("#1a1b26"),
		FgPrimary = hex("#c0caf5"),
		FgSecondary = hex("#a9b1d6"),
		FgTertiary = hex("#9099c4"),
		FgQuaternary = hex("#7a82b0"),
		FgQuinary = hex("#6b73a0"),
		Success = hex("#9ece6a"),
	},
}

end)() end,
    [114] = function()local wax,script,require=ImportGlobals(114)local ImportGlobals return (function(...)local function hex(hexString)
	hexString = hexString:gsub("#", "")
	local r = tonumber(hexString:sub(1, 2), 16) or 0
	local g = tonumber(hexString:sub(3, 4), 16) or 0
	local b = tonumber(hexString:sub(5, 6), 16) or 0
	return Color3.fromRGB(r, g, b)
end

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

return {
	hex = hex,
	rgb = rgb,
}

end)() end,
    [115] = function()local wax,script,require=ImportGlobals(115)local ImportGlobals return (function(...)local utils = require(script.Parent.utils)
local hex = utils.hex

-- Vesper: Minimal black with a peach accent.
return {
	name = "vesper",
	title = "Vesper",
	BgBaseColor = hex("#101010"),
	AccentPrimary = hex("#ffc799"),
	AccentSecondary = hex("#99ffe4"),
	AccentCaution = hex("#ffc799"),
	AccentDestructive = hex("#ff8080"),
	Overrides = {
		BgSunken = hex("#101010"),
		FgPrimary = hex("#ffffff"),
		FgSecondary = hex("#d4d4d4"),
		FgTertiary = hex("#a0a0a0"),
		FgQuaternary = hex("#878787"),
		FgQuinary = hex("#767676"),
		Success = hex("#99ffe4"),
	},
}

end)() end,
    [116] = function()local wax,script,require=ImportGlobals(116)local ImportGlobals return (function(...)-- Colours and type shared by the dock panels, from the Ethos theme: its ink tiers on its sunken
-- surface, so the dock follows Library:SetTheme like the window does. The colours are theme
-- states; read them with `use` inside a Computed. Overlays are Ink at a transparency so they
-- read the same on the panel's gradient.

local Root = script.Parent.Parent
local EthosTheme = require(Root.ui.theme)

local FONT_ID = "rbxassetid://12187365364" -- Inter

return table.freeze({
	Ink = EthosTheme.FgPrimary,
	Ink2 = EthosTheme.FgSecondary,
	Muted = EthosTheme.FgTertiary,
	Faint = EthosTheme.FgQuinary,
	-- The panel and bar: the sunken surface, lifting to the second tier toward the bottom.
	Surface = EthosTheme.BgSunken,
	SurfaceLow = EthosTheme.BgSecondary,
	-- A switch's track while off, then the theme accent and its ink while on, as the window's
	-- checkboxes and sliders use it.
	Track = EthosTheme.BgQuaternary,
	Accent = EthosTheme.AccentPrimary,
	AccentInk = EthosTheme.AccentPrimaryFgPrimary,
	Success = EthosTheme.Success,
	Caution = EthosTheme.AccentCaution,
	Danger = EthosTheme.AccentDestructive,
	-- Tints that tell items of one kind apart, such as the parry builder's moves, in order.
	Hues = table.freeze({
		EthosTheme.AccentPrimary,
		EthosTheme.Violet,
		EthosTheme.Orange,
		EthosTheme.Green,
		EthosTheme.Cyan,
		EthosTheme.Pink,
	}),
	-- Ink overlay transparencies.
	Fill = 0.95, -- resting control
	FillHover = 0.92,
	FillPress = 0.9,
	Line = 0.93, -- hairlines and control edges
	Selected = 0.86, -- the selected segment
	Body = Font.new(FONT_ID, Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	Title = Font.new(FONT_ID, Enum.FontWeight.Medium, Enum.FontStyle.Normal),
	Strong = Font.new(FONT_ID, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
})

end)() end,
    [118] = function()local wax,script,require=ImportGlobals(118)local ImportGlobals return (function(...)--!nocheck

-- Download and register only the asset requested by the caller. Nothing runs
-- at module load. Tests supply the same filesystem/HTTP boundary as an executor.
local AssetCache = {}

local function callInTask(callback, argument, timeoutSeconds, timeoutMessage)
	LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
	-- The executor owns the yielding native call. Do not cancel or resume its
	-- thread: a late native callback must be free to finish without waking us.
	local result: { any }? = nil
	local abandoned = false
	local deadline = os.clock() + timeoutSeconds
	task.defer(function()
		LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
		if abandoned or os.clock() >= deadline then
			return
		end
		local response = table.pack(pcall(callback, argument))
		if not abandoned and os.clock() < deadline then
			result = response
		end
	end)
	local heartbeat = game:GetService("RunService").Heartbeat
	while result == nil and os.clock() < deadline do
		heartbeat:Wait()
	end
	if result == nil then
		abandoned = true
		error(timeoutMessage, 0)
	end
	if not result[1] then
		error(result[2], 0)
	end
	return result[2]
end

local function checksum(bytes)
	local a, b = 1, 0
	for index = 1, #bytes do
		a = (a + string.byte(bytes, index)) % 65521
		b = (b + a) % 65521
	end
	return string.format("%08x", b * 65536 + a)
end

local function uint16(bytes, offset)
	local a, b = string.byte(bytes, offset, offset + 1)
	return a * 256 + b
end

local function uint32(bytes, offset)
	local a, b, c, d = string.byte(bytes, offset, offset + 3)
	return ((a * 256 + b) * 256 + c) * 256 + d
end

local function validate(bytes, options)
	if type(bytes) ~= "string" or #bytes == 0 then
		return false, "asset body is empty"
	end
	if options.Kind == "font" then
		local signature = string.sub(bytes, 1, 4)
		if #bytes < 28 or (signature ~= "\0\1\0\0" and signature ~= "OTTO") then
			return false, "expected a TTF or OTF font"
		end
		local count = uint16(bytes, 5)
		if count < 1 or count > 512 or 12 + count * 16 > #bytes then
			return false, "invalid font table directory"
		end
		for index = 0, count - 1 do
			local record = 13 + index * 16
			local offset = uint32(bytes, record + 8)
			local length = uint32(bytes, record + 12)
			if offset > #bytes or length > #bytes - offset then
				return false, "font table is truncated"
			end
		end
		return true
	end
	if options.Extension == "jpg" or options.Extension == "jpeg" then
		return
			string.sub(bytes, 1, 3) == "\255\216\255" and string.sub(bytes, -2) == "\255\217",
			"expected a complete JPEG image"
	end
	if #bytes < 45
		or string.sub(bytes, 1, 8) ~= "\137PNG\13\10\26\10"
		or string.sub(bytes, 13, 16) ~= "IHDR"
		or string.sub(bytes, -12) ~= "\0\0\0\0IEND\174\66\96\130" then
		return false, "expected a complete PNG image"
	end
	local width, height = uint32(bytes, 17), uint32(bytes, 21)
	if width < 1 or height < 1 or width > 8192 or height > 8192 then
		return false, "image dimensions must be between 1 and 8192"
	end
	return true
end

local function normalize(options)
	assert(type(options) == "table", "Asset options must be a table")
	local result = table.clone(options)
	assert(
		type(result.Name) == "string"
			and #result.Name <= 100
			and string.match(result.Name, "^[%w_-][%w_.-]*$") ~= nil,
		"Asset Name must be a safe file name"
	)
	assert(
		type(result.Url) == "string" and string.match(result.Url, "^https://[^%s]+$") ~= nil,
		"Asset Url must use HTTPS"
	)
	assert(
		result.Version == nil or type(result.Version) == "string",
		"Asset Version must be a string"
	)
	result.Kind = result.Kind or "image"
	assert(result.Kind == "image" or result.Kind == "font", "Asset Kind must be image or font")
	local path = string.match(result.Url, "^[^?#]+") or result.Url
	result.Extension = string.lower(result.Extension or string.match(path, "%.([%w]+)$") or "")
	if result.Kind == "font" then
		assert(
			result.Extension == "ttf" or result.Extension == "otf",
			"Font URL must end in .ttf or .otf"
		)
	else
		assert(
			result.Extension == "png" or result.Extension == "jpg" or result.Extension == "jpeg",
			"Image URL must end in .png, .jpg, or .jpeg"
		)
	end
	return result
end

local function encodeIdentity(fields)
	-- Length prefixes keep fields distinct even if a field contains separators.
	for index, value in ipairs(fields) do
		fields[index] = tostring(#value) .. ":" .. value
	end
	return table.concat(fields)
end

local function requestIdentity(options)
	return encodeIdentity({
		options.Name,
		options.Url,
		options.Version or "",
		options.Kind,
		options.Extension,
	})
end

local function fontStyle(weight, style)
	weight = weight or 400
	style = style or "normal"
	if typeof(weight) == "EnumItem" and weight.EnumType == Enum.FontWeight then
		weight = weight.Value
	end
	if typeof(style) == "EnumItem" and style.EnumType == Enum.FontStyle then
		style = string.lower(style.Name)
	end
	assert(
		type(weight) == "number" and weight >= 100 and weight <= 900 and weight % 100 == 0,
		"Font Weight must be an Enum.FontWeight or 100 through 900"
	)
	assert(style == "normal" or style == "italic", "Font Style must be normal or italic")
	return weight, style
end

local function normalizeFont(rawOptions)
	assert(type(rawOptions) == "table", "Font options must be a table")
	local name = rawOptions.Name
	assert(
		type(name) == "string" and #name <= 100 and name:match("^[%w_-][%w_.-]*$") ~= nil,
		"Font Name must be a safe file name"
	)
	local weight, style = fontStyle(rawOptions.Weight, rawOptions.Style)
	local sources = rawOptions.Faces or { rawOptions }
	assert(
		type(sources) == "table" and #sources > 0 and #sources <= 18,
		"Font Faces must contain 1 through 18 faces"
	)
	local faces, seen = {}, {}
	local sourceCount = 0
	for index in pairs(sources) do
		assert(
			type(index) == "number" and index % 1 == 0 and index >= 1 and index <= #sources,
			"Font Faces must be an array"
		)
		sourceCount += 1
	end
	assert(sourceCount == #sources, "Font Faces must be a complete array")
	for index, source in ipairs(sources) do
		assert(type(source) == "table", "Each font face must be a table")
		local face = table.clone(source)
		face.Weight, face.Style = fontStyle(face.Weight, face.Style)
		local faceKey = tostring(face.Weight) .. ":" .. face.Style
		assert(not seen[faceKey], "Font faces must have distinct weights and styles")
		seen[faceKey] = true
		face.Name = face.Name
			or name:sub(1, 80) .. "-" .. tostring(face.Weight) .. "-" .. face.Style
		face.Version = face.Version or rawOptions.Version
		face.Kind = "font"
		faces[index] = normalize(face)
	end
	table.sort(
		faces,
		function(a, b)
			return if a.Weight == b.Weight then a.Style == "normal" and b.Style ~= "normal"
				else a.Weight < b.Weight
		end
	)
	local fields = { "font-family-v1", name, tostring(weight), style }
	for _, face in ipairs(faces) do
		table.insert(fields, requestIdentity(face))
		table.insert(fields, tostring(face.Weight))
		table.insert(fields, face.Style)
	end
	return {
		Name = name,
		Faces = faces,
		Weight = weight,
		Style = style,
		Identity = encodeIdentity(fields),
	}
end

function AssetCache.new(environment)
	local cache = {}
	local handles, fonts, pending, pendingFonts = {}, {}, {}, {}
	local needsDownload = {}
	local paths, claims = {}, {}
	local base = environment.Directory or "Ethos Suite/assets-v2"
	local foldersReady = false
	local stats = { downloads = 0, registrations = 0, cacheHits = 0 }

	local function readyFolders()
		if foldersReady and environment.isfolder(base) then
			return
		end
		local current = ""
		for part in string.gmatch(base, "[^/]+") do
			current = if current == "" then part else current .. "/" .. part
			if not environment.isfolder(current) then
				environment.makefolder(current)
			end
		end
		foldersReady = true
	end

	local function selectPath(identity, options)
		if paths[identity] ~= nil then
			return paths[identity]
		end
		local prefix = base .. "/" .. options.Name .. "-" .. checksum(identity)
		-- The short checksum groups files; it does not establish identity. A full
		-- identity sidecar and separate collision slots prevent native-path reuse.
		for slot = 0, 127 do
			local suffix = if slot == 0 then "" else "-" .. tostring(slot)
			local path = prefix .. suffix .. "." .. options.Extension
			if claims[path] == nil then
				local metadataPath = path .. ".meta"
				local hasMetadata = environment.isfile(metadataPath)
				local matches = false
				if hasMetadata then
					local ok, savedIdentity = pcall(environment.readfile, metadataPath)
					matches = ok and savedIdentity == identity
				end
				if matches or (not hasMetadata and not environment.isfile(path)) then
					claims[path] = identity
					paths[identity] = path
					return path
				end
			end
		end
		error("asset cache identity slots are exhausted")
	end

	function cache:IsSupported()
		return type(environment.isfile) == "function"
			and type(environment.readfile) == "function"
			and type(environment.writefile) == "function"
			and type(environment.isfolder) == "function"
			and type(environment.makefolder) == "function"
			and type(environment.getcustomasset) == "function"
	end

	function cache:Fetch(rawOptions)
		local validOptions, options = pcall(normalize, rawOptions)
		if not validOptions then
			return nil, tostring(options)
		end
		if not self:IsSupported() then
			return nil, "custom assets are unavailable in this environment"
		end
		local identity = requestIdentity(options)
		if handles[identity] then
			stats.cacheHits += 1
			return handles[identity], nil, paths[identity]
		end
		local active = pending[identity]
		if active and coroutine.status(active.thread) == "dead" then
			pending[identity] = nil
			active = nil
		end
		if active then
			local deadline = os.clock() + 30
			local heartbeat = game:GetService("RunService").Heartbeat
			while not active.complete
				and os.clock() < deadline
				and coroutine.status(active.thread) ~= "dead" do
				heartbeat:Wait()
			end
			if not active.complete and coroutine.status(active.thread) == "dead" then
				return self:Fetch(rawOptions)
			end
			if not active.complete then
				return nil, "asset download is still in progress"
			end
			return active.handle, active.error, active.path
		end
		active = { complete = false, thread = coroutine.running() }
		pending[identity] = active
		local ok, value = pcall(
			function()
				readyFolders()
				local path = selectPath(identity, options)
				active.path = path
				local metadataPath = path .. ".meta"
				local metadataReadOk, savedIdentity = pcall(environment.readfile, metadataPath)
				if not metadataReadOk or savedIdentity ~= identity then
					environment.writefile(metadataPath, identity)
				end
				assert(
					environment.readfile(metadataPath) == identity,
					"asset identity cache write was incomplete"
				)
				local cached = false
				if not needsDownload[identity] and environment.isfile(path) then
					local readOk, bytes = pcall(environment.readfile, path)
					cached = readOk and validate(bytes, options)
				end
				local function download()
					-- A failed write must not become an accepted cache hit on retry.
					needsDownload[identity] = true
					local bytes: string
					if type(environment.request) == "function" then
						local response = callInTask(
							environment.request,
							{
								Url = options.Url,
								Method = "GET",
								Timeout = environment.RequestTimeoutSeconds or 20,
							},
							environment.RequestTimeoutSeconds or 20,
							"asset HTTP request timed out"
						)
						assert(type(response) == "table", "HTTP request returned no response")
						local status = response.StatusCode or response.Status
						assert(
							type(status) == "number" and status >= 200 and status < 300,
							"asset HTTP request failed: " .. tostring(status)
						)
						bytes = response.Body
					else
						assert(
							type(environment.httpGet) == "function",
							"HTTP requests are unavailable"
						)
						bytes = callInTask(
							environment.httpGet,
							options.Url,
							environment.RequestTimeoutSeconds or 20,
							"asset HTTP request timed out"
						)
					end
					local accepted, message = validate(bytes, options)
					assert(accepted, "asset download " .. options.Name .. ": " .. tostring(message))
					environment.writefile(path, bytes)
					-- A partial or changed file can still pass the format checks.
					local written = environment.readfile(path)
					assert(
						written == bytes,
						"asset cache write " .. options.Name .. ": bytes do not match download"
					)
					stats.downloads += 1
					needsDownload[identity] = nil
				end
				local function register()
					local handle = callInTask(
						environment.getcustomasset,
						path,
						environment.RegistrationTimeoutSeconds or 20,
						"asset registration timed out"
					)
					assert(
						type(handle) == "string" and handle ~= "",
						"getcustomasset returned no content URI"
					)
					return handle
				end
				if not cached then
					download()
				end
				local registered, handle = pcall(register)
				if not registered and cached then
					-- Readable bytes are not proof that the executor can load this file.
					-- Replace only this asset, then make one more registration attempt.
					local firstError = tostring(handle)
					registered, handle = pcall(function()
						download()
						return register()
					end)
					if not registered then
						error(
							"asset registration failed: "
								.. firstError
								.. "; repair failed: "
								.. tostring(handle),
							0
						)
					end
				end
				assert(registered, handle)
				stats.registrations += 1
				return handle
			end
		)
		if ok then
			handles[identity] = value
			active.handle = value
		else
			active.error = tostring(value)
		end
		active.complete = true
		pending[identity] = nil
		return active.handle, active.error, active.path
	end

	function cache:CreateFont(rawOptions)
		local valid, options = pcall(normalizeFont, rawOptions)
		if not valid then
			return nil, tostring(options)
		end
		local key = options.Identity
		if fonts[key] then
			return fonts[key]
		end
		local active = pendingFonts[key]
		if active and coroutine.status(active.thread) == "dead" then
			pendingFonts[key] = nil
			active = nil
		end
		if active then
			local deadline = os.clock() + 30
			local heartbeat = game:GetService("RunService").Heartbeat
			while not active.complete
				and os.clock() < deadline
				and coroutine.status(active.thread) ~= "dead" do
				heartbeat:Wait()
			end
			if not active.complete and coroutine.status(active.thread) == "dead" then
				return self:CreateFont(rawOptions)
			end
			if not active.complete then
				return nil, "font family download is still in progress"
			end
			return active.font, active.error
		end
		active = { complete = false, thread = coroutine.running() }
		pendingFonts[key] = active
		local registrationStarted = false
		local function buildFamily()
			registrationStarted = false
			local faces = {}
			for index, face in ipairs(options.Faces) do
				local handle, message = self:Fetch(face)
				assert(handle, message)
				faces[index] = {
					name = face.Name,
					weight = face.Weight,
					style = face.Style,
					assetId = handle,
				}
			end
			local data = environment.jsonEncode({
				name = options.Name,
				loadStrategy = "sameFamilyOnly",
				faces = faces,
			})
			local familyPath = selectPath(key, { Name = options.Name, Extension = "json" })
			local metadataPath = familyPath .. ".meta"
			local metadataOk, metadata = pcall(environment.readfile, metadataPath)
			if not metadataOk or metadata ~= key then
				environment.writefile(metadataPath, key)
			end
			assert(
				environment.readfile(metadataPath) == key,
				"font family identity write was incomplete"
			)
			-- Registration URIs can change between executor sessions. Build this
			-- family from the current TTF handle, even when the TTF was cached.
			local familyReadOk, existingFamily = pcall(environment.readfile, familyPath)
			if not familyReadOk or existingFamily ~= data then
				environment.writefile(familyPath, data)
			end
			assert(
				environment.readfile(familyPath) == data,
				"font family cache write was incomplete"
			)
			registrationStarted = true
			local family = callInTask(
				environment.getcustomasset,
				familyPath,
				environment.RegistrationTimeoutSeconds or 20,
				"font family registration timed out"
			)
			assert(type(family) == "string" and family ~= "", "font family registration failed")
			local fontWeight = Enum.FontWeight.Regular
			for _, item in ipairs(Enum.FontWeight:GetEnumItems()) do
				if item.Value == options.Weight then
					fontWeight = item
					break
				end
			end
			stats.registrations += 1
			return Font.new(
				family,
				fontWeight,
				if options.Style == "italic" then Enum.FontStyle.Italic else Enum.FontStyle.Normal
			)
		end
		local success, result = pcall(buildFamily)
		if not success and registrationStarted then
			local firstError = tostring(result)
			-- Family registration or Font.new can reject a previously accepted face.
			-- Refresh every face once and rebuild JSON with the new session handles.
			for _, face in ipairs(options.Faces) do
				local identity = requestIdentity(face)
				handles[identity] = nil
				needsDownload[identity] = true
			end
			success, result = pcall(buildFamily)
			if not success then
				result = "font family registration failed: "
					.. firstError
					.. "; repair failed: "
					.. tostring(result)
			end
		end
		if success then
			fonts[key] = result
			active.font = result
		else
			active.error = tostring(result)
		end
		active.complete = true
		pendingFonts[key] = nil
		return active.font, active.error
	end

	function cache:GetStats()
		return table.clone(stats)
	end

	return cache
end

return table.freeze(AssetCache)

end)() end,
    [119] = function()local wax,script,require=ImportGlobals(119)local ImportGlobals return (function(...)-- Control callbacks run after all config values have been applied. A keyed
-- callback is replaced by its latest notification while a load is active.
local Heartbeat = game:GetService("RunService").Heartbeat

local CallbackBatch = {}
local active = nil
local MAX_PASSES = 64

local function execute(callback, key)
	if type(callback) ~= "function" then
		return true
	end
	local owner = active
	local result = table.pack(
		xpcall(
			callback,
			function(message)
				return debug.traceback(tostring(message), 2)
			end
		)
	)
	if not result[1] then
		local message = (if key then "[" .. key .. "] " else "") .. tostring(result[2])
		if owner and not owner.cancelled then
			table.insert(owner.errors, message)
			owner.failedPriority = math.min(
				owner.failedPriority or math.huge,
				owner.executingPriority or 0
			)
		end
		warn("[Ethos callback] " .. message)
		return false, message
	end
	return table.unpack(result, 1, result.n)
end

function CallbackBatch.current()
	return if active and not active.cancelled then active else nil
end

function CallbackBatch.begin(orderResolver)
	assert(CallbackBatch.current() == nil, "A control callback batch is already active")
	assert(
		orderResolver == nil or type(orderResolver) == "function",
		"Expected a callback order resolver"
	)
	local batch = {
		pending = {},
		nextOrder = 0,
		errors = {},
		orderResolver = orderResolver,
		cancelled = false,
		finishing = false,
	}
	active = batch
	return batch
end

function CallbackBatch.invoke(callback, key)
	if key ~= nil then
		assert(type(key) == "string", "Expected a control callback key")
		if active then
			if active.cancelled then
				return false, "Control callback batch was cancelled"
			end
			local job = active.pending[key]
			if job then
				job.callback = callback
			else
				active.nextOrder += 1
				active.pending[key] = { key = key, callback = callback, order = active.nextOrder }
			end
			return true
		end
	end
	return execute(callback, key)
end

function CallbackBatch.cancel(batch)
	if batch == nil then
		return
	end
	batch.cancelled = true
	table.clear(batch.pending)
	-- Deferred Fusion observers may still publish their last notification. Keep
	-- this cancelled owner for two deferred turns so they cannot run effects.
	if active == batch then
		task.defer(function()
			task.defer(function()
				if active == batch then
					active = nil
				end
			end)
		end)
	end
end

function CallbackBatch.finish(batch)
	if active ~= batch or batch.cancelled then
		return false, "Control callback batch is no longer active"
	end
	if batch.finishing then
		return false, "Control callback batch is already finishing"
	end
	batch.finishing = true
	local idlePasses = 0
	for _ = 1, MAX_PASSES do
		-- Cross an engine frame boundary so deferred state observers can publish
		-- dependent changes before selecting the next callback phase.
		Heartbeat:Wait()
		if active ~= batch or batch.cancelled then
			return false, "Control callback batch was cancelled"
		end
		local jobs = {}
		local nextPriority = math.huge
		for _, job in pairs(batch.pending) do
			local ok, priority = true, 0
			if batch.orderResolver then
				ok, priority = pcall(batch.orderResolver, job.key)
			end
			if not ok
				or type(priority) ~= "number"
				or priority ~= priority
				or math.abs(priority) == math.huge then
				CallbackBatch.cancel(batch)
				return
					false,
					"Invalid callback loading order for " .. job.key .. ": " .. tostring(priority)
			end
			job.priority = priority
			nextPriority = math.min(nextPriority, priority)
			table.insert(jobs, job)
		end
		-- Other callbacks in a failed phase can finish their independent work.
		-- A later activation phase must not run with a failed dependency.
		if batch.failedPriority ~= nil and nextPriority > batch.failedPriority then
			CallbackBatch.cancel(batch)
			return false, table.concat(batch.errors, "\n")
		end
		if #jobs == 0 then
			idlePasses += 1
			if idlePasses == 2 then
				active = nil
				return
					#batch.errors == 0,
					if #batch.errors > 0 then table.concat(batch.errors, "\n") else nil
			end
		else
			idlePasses = 0
			table.sort(
				jobs,
				function(a, b)
					if a.priority == b.priority then
						return a.order < b.order
					end
					return a.priority < b.priority
				end
			)
			batch.executingPriority = nextPriority
			for _, job in ipairs(jobs) do
				if job.priority ~= nextPriority then
					break
				end
				if active ~= batch or batch.cancelled then
					return false, "Control callback batch was cancelled"
				end
				if batch.pending[job.key] == job then
					batch.pending[job.key] = nil
					batch.lastCallbackKey = job.key
					execute(job.callback, job.key)
				end
			end
			batch.executingPriority = nil
		end
	end
	CallbackBatch.cancel(batch)
	return false, "Control callbacks did not settle after config loading"
end

return CallbackBatch

end)() end,
    [120] = function()local wax,script,require=ImportGlobals(120)local ImportGlobals return (function(...)--!strict

if not LPH_OBFUSCATED then
	local env = getfenv()
	env.LPH_ATTRIBUTES = env.LPH_ATTRIBUTES
		or function()
		end
	env.VM = env.VM
		or function(...)
			return ...
		end
	env.PRESET = env.PRESET
		or function(...)
			return ...
		end
	env.ERROR_HANDLING = env.ERROR_HANDLING
		or function(...)
			return ...
		end
end

local Contrast = require(script.contrast)

local COLOR_SPACE_KIND_PREFIX = "ColorSpace:"
local COLOR_SPACE_KIND_PREFIX_LEN = #COLOR_SPACE_KIND_PREFIX

local COLOR_SPACE_CONSTR_KIND_PREFIX = "ColorSpaceConstr:"
local COLOR_SPACE_CONSTR_KIND_PREFIX_LEN = #COLOR_SPACE_CONSTR_KIND_PREFIX

local function singleton<T>(value: T | ""): T
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return value
end

local function srgbToLinear(channel: number): number
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	if channel <= 0.04045 then
		return channel / 12.92
	else
		return ((channel + 0.055) / 1.055) ^ 2.4
	end
end

local function linearToSrgb(channel: number): number
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	if channel <= 0.0031308 then
		return channel * 12.92
	else
		return 1.055 * channel ^ (1 / 2.4) - 0.055
	end
end

local DARK_LIGHTNESS_THRESHOLD = 0.5
local GAMUT_SEARCH_ITERATIONS = 12

-- Srgb

local Srgb = {
	kind = singleton("ColorSpaceConstr:Srgb"),
}
Srgb.__index = Srgb

export type Srgb = {
	red: number,
	green: number,
	blue: number,
	kind: "ColorSpace:Srgb",
}

export type SrgbClass = setmetatable<Srgb, typeof(Srgb)>

function Srgb.new(red: number, green: number, blue: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return setmetatable(
		{
			red = red,
			green = green,
			blue = blue,
			kind = singleton("ColorSpace:Srgb"),
		},
		Srgb
	)
end

-- LinearRgb

local LinearRgb = {
	kind = singleton("ColorSpaceConstr:LinearRgb"),
}
LinearRgb.__index = LinearRgb

export type LinearRgb = {
	red: number,
	green: number,
	blue: number,
	kind: "ColorSpace:LinearRgb",
}

export type LinearRgbClass = setmetatable<LinearRgb, typeof(LinearRgb)>

function LinearRgb.new(red: number, green: number, blue: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return setmetatable(
		{
			red = red,
			green = green,
			blue = blue,
			kind = singleton("ColorSpace:LinearRgb"),
		},
		LinearRgb
	)
end

-- Xyz

local Xyz = {
	kind = singleton("ColorSpaceConstr:Xyz"),
}
Xyz.__index = Xyz

export type Xyz = { x: number, y: number, z: number, kind: "ColorSpace:Xyz" }

export type XyzClass = setmetatable<Xyz, typeof(Xyz)>

function Xyz.new(x: number, y: number, z: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return setmetatable(
		{
			x = x,
			y = y,
			z = z,
			kind = singleton("ColorSpace:Xyz"),
		},
		Xyz
	)
end

-- Oklab

local Oklab = {
	kind = singleton("ColorSpaceConstr:Oklab"),
}
Oklab.__index = Oklab

export type Oklab = {
	lightness: number,
	a: number,
	b: number,
	kind: "ColorSpace:Oklab",
}

export type OklabClass = setmetatable<Oklab, typeof(Oklab)>

function Oklab.new(lightness: number, a: number, b: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return setmetatable(
		{
			lightness = lightness,
			a = a,
			b = b,
			kind = singleton("ColorSpace:Oklab"),
		},
		Oklab
	)
end

-- Oklch

local Oklch = {
	kind = singleton("ColorSpaceConstr:Oklch"),
}
Oklch.__index = Oklch

export type Oklch = {
	lightness: number,
	chroma: number,
	hue: number,
	kind: "ColorSpace:Oklch",
}

export type OklchClass = setmetatable<Oklch, typeof(Oklch)>

function Oklch.new(lightness: number, chroma: number, hue: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return setmetatable(
		{
			lightness = lightness,
			chroma = chroma,
			hue = hue,
			kind = singleton("ColorSpace:Oklch"),
		},
		Oklch
	)
end

-- Direct conversions: Srgb <-> LinearRgb

function Srgb.ToLinearRgb(self: SrgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return LinearRgb.new(srgbToLinear(self.red), srgbToLinear(self.green), srgbToLinear(self.blue))
end

function LinearRgb.ToSrgb(self: LinearRgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Srgb.new(
		math.clamp(linearToSrgb(self.red), 0, 1),
		math.clamp(linearToSrgb(self.green), 0, 1),
		math.clamp(linearToSrgb(self.blue), 0, 1)
	)
end

-- Direct conversions: LinearRgb <-> Xyz

function LinearRgb.ToXyz(self: LinearRgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local r: number = self.red
	local g: number = self.green
	local b: number = self.blue

	return Xyz.new(
		0.4124564 * r + 0.3575761 * g + 0.1804375 * b,
		0.2126729 * r + 0.7151522 * g + 0.0721750 * b,
		0.0193339 * r + 0.1191920 * g + 0.9503041 * b
	)
end

function Xyz.ToLinearRgb(self: XyzClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return LinearRgb.new(
		3.2404542 * self.x - 1.5371385 * self.y - 0.4985314 * self.z,
		-0.9692660 * self.x + 1.8760108 * self.y + 0.0415560 * self.z,
		0.0556434 * self.x - 0.2040259 * self.y + 1.0572252 * self.z
	)
end

-- Direct conversions: LinearRgb <-> Oklab

function LinearRgb.ToOklab(self: LinearRgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local r: number = self.red
	local g: number = self.green
	local b: number = self.blue

	local l: number = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ^ (1 / 3)
	local m: number = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ^ (1 / 3)
	local s: number = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ^ (1 / 3)

	return Oklab.new(
		0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
		1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
		0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
	)
end

function Oklab.ToLinearRgb(self: OklabClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local l: number = (self.lightness + 0.3963377774 * self.a + 0.2158037573 * self.b) ^ 3
	local m: number = (self.lightness - 0.1055613458 * self.a - 0.0638541728 * self.b) ^ 3
	local s: number = (self.lightness - 0.0894841775 * self.a - 1.2914855480 * self.b) ^ 3

	return LinearRgb.new(
		4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
		-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
		-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
	)
end

-- Direct conversions: Oklab <-> Oklch

function Oklab.ToOklch(self: OklabClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Oklch.new(self.lightness, math.sqrt(self.a ^ 2 + self.b ^ 2), math.atan2(self.b, self.a))
end

function Oklch.ToOklab(self: OklchClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Oklab.new(
		self.lightness,
		self.chroma * math.cos(self.hue),
		self.chroma * math.sin(self.hue)
	)
end

-- Chained conversions: Srgb

function Srgb.ToXyz(self: SrgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToXyz()
end

function Srgb.ToOklab(self: SrgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToOklab()
end

function Srgb.ToOklch(self: SrgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToOklab():ToOklch()
end

-- Chained conversions: LinearRgb

function LinearRgb.ToOklch(self: LinearRgbClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():ToOklch()
end

-- Chained conversions: Xyz

function Xyz.ToSrgb(self: XyzClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToSrgb()
end

function Xyz.ToOklab(self: XyzClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToOklab()
end

function Xyz.ToOklch(self: XyzClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToOklab():ToOklch()
end

-- Chained conversions: Oklab

function Oklab.ToSrgb(self: OklabClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToSrgb()
end

function Oklab.ToXyz(self: OklabClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToLinearRgb():ToXyz()
end

-- Chained conversions: Oklch

function Oklch.ToLinearRgb(self: OklchClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():ToLinearRgb()
end

function Oklch.ToSrgb(self: OklchClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():ToLinearRgb():ToSrgb()
end

function Oklch.ToXyz(self: OklchClass)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():ToLinearRgb():ToXyz()
end

-- Lerp

function Srgb.Lerp(self: SrgbClass, other: SrgbClass, alpha: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Srgb.new(
		self.red + (other.red - self.red) * alpha,
		self.green + (other.green - self.green) * alpha,
		self.blue + (other.blue - self.blue) * alpha
	)
end

function LinearRgb.Lerp(self: LinearRgbClass, other: LinearRgbClass, alpha: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return LinearRgb.new(
		self.red + (other.red - self.red) * alpha,
		self.green + (other.green - self.green) * alpha,
		self.blue + (other.blue - self.blue) * alpha
	)
end

function Xyz.Lerp(self: XyzClass, other: XyzClass, alpha: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Xyz.new(
		self.x + (other.x - self.x) * alpha,
		self.y + (other.y - self.y) * alpha,
		self.z + (other.z - self.z) * alpha
	)
end

function Oklab.Lerp(self: OklabClass, other: OklabClass, alpha: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Oklab.new(
		self.lightness + (other.lightness - self.lightness) * alpha,
		self.a + (other.a - self.a) * alpha,
		self.b + (other.b - self.b) * alpha
	)
end

function Oklch.Lerp(self: OklchClass, other: OklchClass, alpha: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local tau: number = 2 * math.pi
	local delta: number = (other.hue - self.hue) % tau
	if delta > math.pi then
		delta -= tau
	end

	return Oklch.new(
		self.lightness + (other.lightness - self.lightness) * alpha,
		self.chroma + (other.chroma - self.chroma) * alpha,
		self.hue + delta * alpha
	)
end

-- Components

function Srgb.Components(self: SrgbClass): (number, number, number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self.red, self.green, self.blue
end

function LinearRgb.Components(self: LinearRgbClass): (number, number, number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self.red, self.green, self.blue
end

function Xyz.Components(self: XyzClass): (number, number, number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self.x, self.y, self.z
end

function Oklab.Components(self: OklabClass): (number, number, number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self.lightness, self.a, self.b
end

function Oklch.Components(self: OklchClass): (number, number, number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self.lightness, self.chroma, self.hue
end

-- Color3 interop

function Srgb.ToColor3(self: SrgbClass): Color3
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Color3.new(self.red, self.green, self.blue)
end

function LinearRgb.ToColor3(self: LinearRgbClass): Color3
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToColor3()
end

function Xyz.ToColor3(self: XyzClass): Color3
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToColor3()
end

function Oklab.ToColor3(self: OklabClass): Color3
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToColor3()
end

function Oklch.ToColor3(self: OklchClass): Color3
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToColor3()
end

-- Stringification

function Srgb.ToHexString(self: SrgbClass): string
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return string.format(
		"#%02X%02X%02X",
		math.round(self.red * 255),
		math.round(self.green * 255),
		math.round(self.blue * 255)
	)
end

function LinearRgb.ToHexString(self: LinearRgbClass): string
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToHexString()
end

function Xyz.ToHexString(self: XyzClass): string
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToHexString()
end

function Oklab.ToHexString(self: OklabClass): string
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToHexString()
end

function Oklch.ToHexString(self: OklchClass): string
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToSrgb():ToHexString()
end

-- Appearance

function Oklab.IsDark(self: OklabClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self.lightness <= DARK_LIGHTNESS_THRESHOLD
end

function Oklab.IsLight(self: OklabClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return not self:IsDark()
end

function Srgb.IsDark(self: SrgbClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():IsDark()
end

function Srgb.IsLight(self: SrgbClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return not self:IsDark()
end

function LinearRgb.IsDark(self: LinearRgbClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():IsDark()
end

function LinearRgb.IsLight(self: LinearRgbClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return not self:IsDark()
end

function Xyz.IsDark(self: XyzClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():IsDark()
end

function Xyz.IsLight(self: XyzClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return not self:IsDark()
end

function Oklch.IsDark(self: OklchClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return self:ToOklab():IsDark()
end

function Oklch.IsLight(self: OklchClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return not self:IsDark()
end

export type ColorSpace = SrgbClass | LinearRgbClass | XyzClass | OklabClass | OklchClass
export type AnyColor = ColorSpace | Color3
export type AnyColorConstructor = typeof(Srgb) | typeof(LinearRgb) | typeof(Xyz) | typeof(Oklab) | typeof(Oklch) | "Color3"
export type ContrastResult = Contrast.Result

local function from(color: AnyColor, targetSpace: AnyColorConstructor)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local colorName: string = if typeof(color) == "Color3" then "Color3"
		else string.sub((color :: any).kind, COLOR_SPACE_KIND_PREFIX_LEN + 1)

	local targetSpaceName: string = if targetSpace == "Color3" then "Color3"
		else string.sub((targetSpace :: any).kind, COLOR_SPACE_CONSTR_KIND_PREFIX_LEN + 1)

	if colorName == targetSpaceName then
		return color
	end

	local source: any = color

	if colorName == "Color3" then
		source = Srgb.new((color :: Color3).R, (color :: Color3).G, (color :: Color3).B)

		if targetSpaceName == "Srgb" then
			return source
		end
	end

	if targetSpaceName == "Color3" then
		return source:ToColor3()
	end

	return source["To" .. targetSpaceName](source)
end

function Srgb.From(color: AnyColor): SrgbClass
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return from(color, Srgb) :: SrgbClass
end

function LinearRgb.From(color: AnyColor): LinearRgbClass
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return from(color, LinearRgb) :: LinearRgbClass
end

function Xyz.From(color: AnyColor): XyzClass
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return from(color, Xyz) :: XyzClass
end

function Oklab.From(color: AnyColor): OklabClass
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return from(color, Oklab) :: OklabClass
end

function Oklch.From(color: AnyColor): OklchClass
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return from(color, Oklch) :: OklchClass
end

-- Oklch colors can fall outside sRGB. Direct channel clipping changes their
-- hue and relative lightness, so reduce chroma until the color fits instead.
local function IsInSrgbGamut(color: OklchClass): boolean
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local linear = LinearRgb.From(color)
	local red, green, blue = linear:Components()

	return red >= 0 and red <= 1 and green >= 0 and green <= 1 and blue >= 0 and blue <= 1
end

local function ToGamutMappedColor3(color: OklabClass | OklchClass): Color3
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local oklch = Oklch.From(color)
	local lightness, chroma, hue = oklch:Components()
	lightness = math.clamp(lightness, 0, 1)
	chroma = math.max(chroma, 0)

	local requested = Oklch.new(lightness, chroma, hue)
	if IsInSrgbGamut(requested) then
		return requested:ToColor3()
	end

	local low = 0
	local high = chroma
	local bestChroma = 0

	for _ = 1, GAMUT_SEARCH_ITERATIONS do
		local midpoint = (low + high) / 2
		local candidate: OklchClass = Oklch.new(lightness, midpoint, hue)

		if IsInSrgbGamut(candidate) then
			low = midpoint
			bestChroma = midpoint
		else
			high = midpoint
		end
	end

	return Oklch.new(lightness, bestChroma, hue):ToColor3()
end

local function relativeLuminance(color: AnyColor): number
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local linearColor = LinearRgb.From(color)

	return Contrast.RelativeLuminance(linearColor.red, linearColor.green, linearColor.blue)
end

local function checkContrast(first: AnyColor, second: AnyColor): Contrast.Result
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return Contrast.Check(relativeLuminance(first), relativeLuminance(second))
end

local function bestContrast(reference: ColorSpace, firstCandidate: ColorSpace, ...: ColorSpace): ColorSpace
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local bestCandidate = firstCandidate
	local bestContrastRatio = checkContrast(reference, firstCandidate).ratio

	for _, candidate in { ... } do
		local contrastRatio = checkContrast(reference, candidate).ratio

		if contrastRatio > bestContrastRatio then
			bestCandidate = candidate
			bestContrastRatio = contrastRatio
		end
	end

	return bestCandidate
end

function Srgb.CheckContrast(self: SrgbClass, other: AnyColor): Contrast.Result
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return checkContrast(self, other)
end

function LinearRgb.CheckContrast(self: LinearRgbClass, other: AnyColor): Contrast.Result
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return checkContrast(self, other)
end

function Xyz.CheckContrast(self: XyzClass, other: AnyColor): Contrast.Result
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return checkContrast(self, other)
end

function Oklab.CheckContrast(self: OklabClass, other: AnyColor): Contrast.Result
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return checkContrast(self, other)
end

function Oklch.CheckContrast(self: OklchClass, other: AnyColor): Contrast.Result
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return checkContrast(self, other)
end

function Srgb.BestContrast(self: SrgbClass, firstCandidate: ColorSpace, ...: ColorSpace): ColorSpace
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return bestContrast(self, firstCandidate, ...)
end

function LinearRgb.BestContrast(self: LinearRgbClass, firstCandidate: ColorSpace, ...: ColorSpace): ColorSpace
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return bestContrast(self, firstCandidate, ...)
end

function Xyz.BestContrast(self: XyzClass, firstCandidate: ColorSpace, ...: ColorSpace): ColorSpace
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return bestContrast(self, firstCandidate, ...)
end

function Oklab.BestContrast(self: OklabClass, firstCandidate: ColorSpace, ...: ColorSpace): ColorSpace
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return bestContrast(self, firstCandidate, ...)
end

function Oklch.BestContrast(self: OklchClass, firstCandidate: ColorSpace, ...: ColorSpace): ColorSpace
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return bestContrast(self, firstCandidate, ...)
end

return {
	Srgb = Srgb,
	LinearRgb = LinearRgb,
	Xyz = Xyz,
	Oklab = Oklab,
	Oklch = Oklch,
	ToGamutMappedColor3 = ToGamutMappedColor3,
}

end)() end,
    [121] = function()local wax,script,require=ImportGlobals(121)local ImportGlobals return (function(...)--!strict

export type Result = {
	ratio: number,
	normalTextAA: boolean,
	normalTextAAA: boolean,
	largeTextAA: boolean,
	largeTextAAA: boolean,
	uiAA: boolean,
}

local NORMAL_TEXT_AA_RATIO = 4.5
local NORMAL_TEXT_AAA_RATIO = 7
local LARGE_TEXT_AA_RATIO = 3
local LARGE_TEXT_AAA_RATIO = 4.5
local UI_AA_RATIO = 3

local function RelativeLuminance(red: number, green: number, blue: number): number
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	return 0.2126 * red + 0.7152 * green + 0.0722 * blue
end

local function Check(firstLuminance: number, secondLuminance: number): Result
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local lighter = math.max(firstLuminance, secondLuminance)
	local darker = math.min(firstLuminance, secondLuminance)
	local ratio = (lighter + 0.05) / (darker + 0.05)

	return {
		ratio = ratio,
		normalTextAA = ratio >= NORMAL_TEXT_AA_RATIO,
		normalTextAAA = ratio >= NORMAL_TEXT_AAA_RATIO,
		largeTextAA = ratio >= LARGE_TEXT_AA_RATIO,
		largeTextAAA = ratio >= LARGE_TEXT_AAA_RATIO,
		uiAA = ratio >= UI_AA_RATIO,
	}
end

return {
	RelativeLuminance = RelativeLuminance,
	Check = Check,
}

end)() end,
    [123] = function()local wax,script,require=ImportGlobals(123)local ImportGlobals return (function(...)--!strict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Root = script.Parent.Parent.Parent
local Packages = Root.packages
local Fusion = require(Packages.fusion)

local ColorSpace = require(Root.utils.colorSpace)
local Oklab = ColorSpace.Oklab

local Observer = Fusion.Observer
local peek = Fusion.peek
local Value = Fusion.Value

local DEFAULT_TWEEN_INFO = TweenInfo.new()
local REBASE_EPSILON = 1e-6

local function GetTweenDuration(tweenInfo: TweenInfo): number
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	if tweenInfo.RepeatCount <= -1 then
		return math.huge
	end
	local duration = tweenInfo.DelayTime + tweenInfo.Time
	if tweenInfo.Reverses then
		duration += tweenInfo.Time
	end
	return duration * (tweenInfo.RepeatCount + 1)
end

local function GetTweenRatio(tweenInfo: TweenInfo, elapsed: number): number
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local delay = tweenInfo.DelayTime
	local duration = tweenInfo.Time
	local cycleDuration = delay + duration
	if tweenInfo.Reverses then
		cycleDuration += duration
	end
	if elapsed == math.huge then
		return 1
	end
	if tweenInfo.RepeatCount > -1 and elapsed >= cycleDuration * (tweenInfo.RepeatCount + 1) then
		return 1
	end
	if cycleDuration == 0 then
		return 1
	end
	local cycleTime = elapsed % cycleDuration
	if cycleTime <= delay then
		return 0
	end
	local progress = (cycleTime - delay) / duration
	if progress > 1 then
		progress = 2 - progress
	end
	return TweenService:GetValue(progress, tweenInfo.EasingStyle, tweenInfo.EasingDirection)
end

-- Rebasing extrapolates the Oklab origin far outside the sRGB gamut. Gamut
-- map each interpolated color before emitting it so hue is retained instead
-- of being changed by direct RGB channel clipping.
local function ToValidColor3(color: Color3): Color3
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local r = color.R
	local g = color.G
	local b = color.B
	if r ~= r then
		r = 0
	end
	if g ~= g then
		g = 0
	end
	if b ~= b then
		b = 0
	end
	return Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
end

local function RebaseOrigin(current: Color3, target: Color3, ratio: number)
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local currentL, currentA, currentB = Oklab.From(current):Components()
	local targetL, targetA, targetB = Oklab.From(target):Components()
	local remaining = 1 - ratio
	return Oklab.new(
		(currentL - targetL * ratio) / remaining,
		(currentA - targetA * ratio) / remaining,
		(currentB - targetB * ratio) / remaining
	)
end

local function Oktween(scope: Fusion.Scope<any>, goal: Fusion.UsedAs<Color3>, tweenInfo: TweenInfo?): Fusion.StateObject<Color3>
	LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
	local resolvedTweenInfo = tweenInfo or DEFAULT_TWEEN_INFO
	local initialColor = peek(goal)
	local output = Value(scope, ToValidColor3(initialColor))
	local activeGoal = initialColor
	local origin = Oklab.From(initialColor)
	local previousRatio = 0
	local startedAt = 0
	local totalDuration = GetTweenDuration(resolvedTweenInfo)
	local heartbeatConnection: RBXScriptConnection? = nil
	local destroyed = false

	local function Stop()
		if not heartbeatConnection then
			return
		end
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	local function Step()
		LPH_ATTRIBUTES(VM(NONE), ERROR_HANDLING(false))
		local nextGoal = peek(goal)
		local goalChanged = nextGoal ~= activeGoal
		if goalChanged then
			if math.abs(1 - previousRatio) > REBASE_EPSILON then
				origin = RebaseOrigin(peek(output), nextGoal, previousRatio)
			else
				origin = Oklab.From(peek(output))
			end
			activeGoal = nextGoal
		end
		local elapsed = os.clock() - startedAt
		local ratio = GetTweenRatio(resolvedTweenInfo, elapsed)
		output:set(
			ToValidColor3(
				ColorSpace.ToGamutMappedColor3(origin:Lerp(Oklab.From(activeGoal), ratio))
			)
		)
		previousRatio = ratio
		if elapsed >= totalDuration then
			output:set(ToValidColor3(activeGoal))
			previousRatio = 1
			if not goalChanged then
				Stop()
			end
		end
	end

	local function Start()
		if destroyed or heartbeatConnection then
			return
		end
		activeGoal = peek(goal)
		origin = Oklab.From(peek(output))
		previousRatio = 0
		startedAt = os.clock()
		totalDuration = GetTweenDuration(resolvedTweenInfo)
		heartbeatConnection = RunService.Heartbeat:Connect(Step)
	end

	local stopObserving = Observer(scope, goal):onChange(Start)
	table.insert(
		scope,
		function()
			destroyed = true
			stopObserving()
			Stop()
		end
	)

	return output
end

return Oktween

end)() end,
    [124] = function()local wax,script,require=ImportGlobals(124)local ImportGlobals return (function(...)-- keybindDispatcher.luau: the single owner of keybind input dispatch.
--
-- Previously this lived inside packages/states/init.lua, which made the shared
-- reactive store also a UserInputService listener and forced the server's
-- require graph to touch a client-only service. This module owns:
--   * the key-match rules (isKeyMatch / normalizeInputToKey) -- one copy,
--   * the batched UserInputService listener that dispatches to registered
--     handlers, and
--   * the keybind CRUD (addKeybind / removeKeybind / updateKeybind).
-- The reactive Keybinds / ActiveKeybinds Values stay in States; the dispatcher
-- mutates them. Only client-side modules require this dispatcher.

local Root = script.Parent.Parent
local Fusion = require(Root.packages.fusion)
local States = require(Root.packages.states)

local services = require(Root.packages.services)
local safeCallback = require(Root.utils.safecallback)
local UserInputService = services.UserInputService

local peek = Fusion.peek

local Dispatcher = {}

-- < Key-match rules (single canonical copy) >

function Dispatcher.isKeyMatch(input: InputObject, key: string)
	LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
	if key == "None" then
		return false
	end
	if key == "MouseLeft" then
		return input.UserInputType == Enum.UserInputType.MouseButton1
	end
	if key == "MouseRight" then
		return input.UserInputType == Enum.UserInputType.MouseButton2
	end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		return input.KeyCode.Name == key
	end
	return false
end

function Dispatcher.normalizeInputToKey(input: InputObject): string?
	LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
	if input.UserInputType == Enum.UserInputType.Keyboard then
		return input.KeyCode.Name
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		return "MouseLeft"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		return "MouseRight"
	end
	return nil
end

-- < Batched keybind listener system >
-- Instead of each keybind creating its own InputBegan connection, a single
-- global listener dispatches to registered handlers.

local _keybindHandlers = {}
local _listenerActive = false
local _inputBeganConnection = nil
local _inputEndedConnection = nil
local _focusReleasedConnection = nil
local _textBoxFocusedConnection = nil
local _capture = nil
local _activeInputs = {}
local _capturedInputs = setmetatable({}, { __mode = "k" })

local function releaseActiveInputs()
	local activeInputs = _activeInputs
	_activeInputs = {}
	for id, input in pairs(activeInputs) do
		local handler = _keybindHandlers[id]
		if handler and handler.onInputEnded then
			safeCallback(function()
				handler.onInputEnded(input)
			end)
		end
	end
end

local function disconnectListeners()
	if _inputBeganConnection then
		_inputBeganConnection:Disconnect()
		_inputBeganConnection = nil
	end
	if _inputEndedConnection then
		_inputEndedConnection:Disconnect()
		_inputEndedConnection = nil
	end
	if _focusReleasedConnection then
		_focusReleasedConnection:Disconnect()
		_focusReleasedConnection = nil
	end
	if _textBoxFocusedConnection then
		_textBoxFocusedConnection:Disconnect()
		_textBoxFocusedConnection = nil
	end
	_listenerActive = false
end

local function handleInputBegan(input, gameProcessed)
	LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
	if _capture then
		_capturedInputs[input] = true
		return
	end
	if gameProcessed then
		return
	end

	-- Skip if user is typing in a text box
	if UserInputService:GetFocusedTextBox() then
		return
	end

	for id, handler in pairs(_keybindHandlers) do
		if _capture then
			_capturedInputs[input] = true
			return
		end
		local keybindData = peek(States.Keybinds)[id]
		if keybindData and Dispatcher.isKeyMatch(input, keybindData.key) then
			_activeInputs[id] = input
			if handler.onInputBegan then
				safeCallback(function()
					handler.onInputBegan(input)
				end)
			end
		end
	end
end

local function handleInputEnded(input, _gameProcessed)
	LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
	if _capture or _capturedInputs[input] then
		-- Keep the release marked until all listeners have seen it. A picker can
		-- finish before the window's separate minimize listener runs.
		local capturedInputs = _capturedInputs
		capturedInputs[input] = true
		task.defer(function()
			capturedInputs[input] = nil
		end)
		return
	end

	-- A processed release must still end a hold that began in this dispatcher.
	local releasedKey = Dispatcher.normalizeInputToKey(input)
	for id, startedInput in pairs(_activeInputs) do
		if releasedKey and Dispatcher.isKeyMatch(startedInput, releasedKey) then
			_activeInputs[id] = nil
			local handler = _keybindHandlers[id]
			if handler and handler.onInputEnded then
				safeCallback(function()
					handler.onInputEnded(input)
				end)
			end
		end
	end
end

local function ensureListenerActive()
	if _listenerActive then
		return
	end

	_listenerActive = true
	_inputBeganConnection = UserInputService.InputBegan:Connect(handleInputBegan)
	_inputEndedConnection = UserInputService.InputEnded:Connect(handleInputEnded)
	_focusReleasedConnection = UserInputService.WindowFocusReleased:Connect(function()
		Dispatcher.cancelCapture("focus lost")
		releaseActiveInputs()
	end)
	_textBoxFocusedConnection = UserInputService.TextBoxFocused:Connect(function()
		Dispatcher.cancelCapture("text input focused")
		releaseActiveInputs()
	end)
end

-- A capture owns input until its UI releases it. Only one picker can own it.
function Dispatcher.beginCapture(owner, onCancel)
	assert(owner ~= nil, "keybind capture needs an owner")
	assert(type(onCancel) == "function", "keybind capture needs a cancel callback")
	if _capture then
		return false
	end
	_capture = { owner = owner, onCancel = onCancel }
	ensureListenerActive()
	releaseActiveInputs()
	return true
end

function Dispatcher.endCapture(owner)
	if not _capture or _capture.owner ~= owner then
		return false
	end
	_capture = nil
	if next(_keybindHandlers) == nil then
		disconnectListeners()
	end
	return true
end

function Dispatcher.cancelCapture(reason)
	local capture = _capture
	if not capture then
		return false
	end
	_capture = nil
	safeCallback(function()
		capture.onCancel(reason)
	end)
	if not _capture and next(_keybindHandlers) == nil then
		disconnectListeners()
	end
	return true
end

function Dispatcher.isCapturing()
	return _capture ~= nil
end

function Dispatcher.isInputCaptured(input)
	return _capture ~= nil or _capturedInputs[input] == true
end

-- < Keybind CRUD >

function Dispatcher.addKeybind(id, key, feature)
	local currentKeybinds = peek(States.Keybinds)
	local newKeybinds = table.clone(currentKeybinds)
	newKeybinds[id] = {
		key = key,
		feature = feature,
	}
	States.Keybinds:set(newKeybinds)
end

function Dispatcher.removeKeybind(id)
	_activeInputs[id] = nil
	local currentKeybinds = peek(States.Keybinds)
	local newKeybinds = table.clone(currentKeybinds)
	newKeybinds[id] = nil
	States.Keybinds:set(newKeybinds)
end

function Dispatcher.updateKeybind(id, key, feature)
	if key == nil and feature == nil then
		Dispatcher.removeKeybind(id)
	else
		local currentKeybinds = peek(States.Keybinds)
		local newKeybinds = table.clone(currentKeybinds)
		if newKeybinds[id] then
			newKeybinds[id].key = key or newKeybinds[id].key
			newKeybinds[id].feature = feature or newKeybinds[id].feature
		else
			newKeybinds[id] = {
				key = key or "None",
				feature = feature or "Unknown",
			}
		end
		States.Keybinds:set(newKeybinds)
	end
end

function Dispatcher.registerKeybindHandler(id, handlers)
	-- handlers = { onInputBegan = fn, onInputEnded = fn }
	_keybindHandlers[id] = handlers
	ensureListenerActive()
end

function Dispatcher.unregisterKeybindHandler(id)
	_activeInputs[id] = nil
	_keybindHandlers[id] = nil

	-- If no more handlers, disconnect the global listener to save resources
	if not _capture and next(_keybindHandlers) == nil then
		disconnectListeners()
	end
end

function Dispatcher.cleanup()
	Dispatcher.cancelCapture("dispatcher cleanup")
	releaseActiveInputs()
	disconnectListeners()
	_keybindHandlers = {}
	_capturedInputs = setmetatable({}, { __mode = "k" })
	States.Keybinds:set({})
	States.ActiveKeybinds:set({})
end

return Dispatcher

end)() end,
    [125] = function()local wax,script,require=ImportGlobals(125)local ImportGlobals return (function(...)-- Lex with Highlighter, then apply the symbol categories used by Luau's VS Code grammar.
-- See assets/vendor/catppuccin/README.md for the pinned scope and color sources.
local Lexer = require(script.Parent.Parent.packages.luauLexer)

export type Token = { Kind: string, Text: string }

local PUNCTUATION = {
	["("] = true,
	[")"] = true,
	["["] = true,
	["]"] = true,
	["{"] = true,
	["}"] = true,
	[","] = true,
	[";"] = true,
}

local function classify(tokens)
	local depth, angles = 0, 0
	local functionHead = false
	local parameterDepth = nil
	local parameterExpected = false
	local braces = 0

	for index, token in tokens do
		local word, kind = token.Value, token.Kind
		local before = tokens[index - 1]
		local after = tokens[index + 1]
		local previous = if before then before.Value else ""
		local following = if after then after.Value else ""

		if kind == "keyword" then
			if word == "function" then
				functionHead = true
			elseif word == "true" or word == "false" or word == "nil" then
				token.Kind = "constant"
			elseif word == "self" then
				token.Kind = "self"
			elseif (word == "type" or word == "typeof") and following == "(" then
				token.Kind = "function"
			end
		elseif kind == "operator" then
			if word == "(" or word == "[" or word == "{" then
				depth += 1
				if word == "(" and functionHead and angles == 0 then
					parameterDepth = depth
					parameterExpected = true
					functionHead = false
				end
				braces += if word == "{" then 1 else 0
			elseif word == ")" or word == "]" or word == "}" then
				if word == ")" and depth == parameterDepth then
					parameterDepth = nil
				end
				depth -= 1
				braces -= if word == "}" then 1 else 0
			elseif word == "<" and (functionHead or parameterDepth ~= nil) then
				angles += 1
			elseif word == ">" and angles > 0 then
				angles -= 1
			elseif word == "," and depth == parameterDepth and angles == 0 then
				parameterExpected = true
			elseif word == "..." and parameterExpected and depth == parameterDepth then
				token.Kind = "parameter"
				parameterExpected = false
			end
			if PUNCTUATION[word] then
				token.Kind = "punctuation"
			end
		elseif kind == "iden" or kind == "builtin" or kind == "type" then
			if parameterExpected and depth == parameterDepth and angles == 0 then
				token.Kind = "parameter"
				parameterExpected = false
				continue
			end
			if braces > 0
				and (previous == "{" or previous == ",")
				and (following == "=" or following == ":") then
				token.Kind = "property"
				continue
			end
			if kind == "type" or (functionHead and angles > 0) then
				token.Kind = "type"
				continue
			end
			if following == "("
				or following == "{"
				or (after and after.Kind == "string")
				or (functionHead and angles == 0 and following == "<")
				or (following == "<" and tokens[index + 2] and tokens[index + 2].Value == "<") then
				token.Kind = "function"
				continue
			end
			if previous == "." or previous == ":" then
				token.Kind = "property"
				continue
			end
			if string.match(word, "^[A-Z_][A-Z0-9_]*$") then
				token.Kind = "constant"
				continue
			end
			if kind == "builtin"
				and Lexer.language.builtin[word] == "table"
				and string.match(word, "^[A-Z]") then
				token.Kind = "type"
			end
		end
	end
end

local function luauHighlight(source: string): { { Token } }
	local tokens, significant = {}, {}
	Lexer.scanEach(
		source,
		function(kind, content)
			local token = {
				Kind = kind,
				Text = content,
				Value = string.match(content, "^%s*(.-)%s*$"),
			}
			table.insert(tokens, token)
			if kind ~= "comment" and token.Value ~= "" then
				table.insert(significant, token)
			end
		end
	)
	classify(significant)

	-- Split only after classifying so calls, comments, strings and signatures span lines.
	local lines: { { Token } } = { {} }
	for _, token in tokens do
		for index, text in string.split(token.Text, "\n") do
			if index > 1 then
				table.insert(lines, {})
			end
			if text ~= "" then
				table.insert(lines[#lines], { Kind = token.Kind, Text = text })
			end
		end
	end
	return lines
end

return luauHighlight

end)() end,
    [126] = function()local wax,script,require=ImportGlobals(126)local ImportGlobals return (function(...)--!nocheck

local AssetCache = require(script.Parent.assetCache)
local Manifest = require(script.Parent.Parent.assets.runtimeManifest)
local RuntimeAssets = {}
local cache: any = nil

local function getCache()
	if cache == nil then
		cache = AssetCache.new({
			isfile = isfile,
			readfile = readfile,
			writefile = writefile,
			isfolder = isfolder,
			makefolder = makefolder,
			getcustomasset = getcustomasset,
			request = request or http_request or (syn and syn.request),
			httpGet = function(url)
				LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
				return game:HttpGet(url)
			end,
			jsonEncode = function(value)
				return game:GetService("HttpService"):JSONEncode(value)
			end,
		})
	end
	return cache
end

function RuntimeAssets.isSupported()
	return getCache():IsSupported()
end

function RuntimeAssets.fetch(options)
	return getCache():Fetch(options)
end

function RuntimeAssets.createFont(options)
	return getCache():CreateFont(options)
end

function RuntimeAssets.resolve(image)
	if type(image) ~= "string" then
		return image
	end
	local id = string.match(image, "^rbxassetid://(%d+)$")
	local asset = id and Manifest.Assets[id]
	if asset == nil then
		return image
	end
	local handle = RuntimeAssets.fetch({
		Name = id,
		Url = Manifest.BaseUrl .. asset.File,
		Version = Manifest.Version,
		Kind = "image",
	})
	return handle or image
end

function RuntimeAssets.getVersion()
	return Manifest.Version
end

function RuntimeAssets.getStats()
	return getCache():GetStats()
end

return table.freeze(RuntimeAssets)

end)() end,
    [127] = function()local wax,script,require=ImportGlobals(127)local ImportGlobals return (function(...)local CallbackBatch = require(script.Parent.callbackBatch)

return function(callback: () -> ...any, key: string?): (boolean, ...any)
	return CallbackBatch.invoke(callback, key)
end

end)() end,
    [128] = function()local wax,script,require=ImportGlobals(128)local ImportGlobals return (function(...)--!strict
--!nolint LocalShadow

local Types = require(script.types)
local Constants = require(script.constants)
local CreateTheme = require(script.createTheme)
local ManageTheme = require(script.manageTheme)
local ThemeHelpers = require(script.themeHelpers)
local DefaultThemeConfig = require(script.defaultThemeConfig)

export type Theme = Types.Theme
export type ThemeSource = Types.ThemeSource
export type ThemeConfig = Types.ThemeConfig

export type BgVariant = Types.BgVariant
export type FgVariant = Types.FgVariant
export type AccentVariant = Types.AccentVariant
export type HeightVariant = Types.HeightVariant
export type CornerRadiusVariant = Types.CornerRadiusVariant
export type FontVariant = Types.FontVariant
export type FontSizeVariant = Types.FontSizeVariant
export type ThemeColorModifier = Types.ThemeColorModifier

return {
	CreateTheme = CreateTheme,
	SetThemeForScope = ManageTheme.SetThemeForScope,
	GetThemeForScope = ManageTheme.GetThemeForScope,
	CalcColorModifier = ThemeHelpers.CalcColorModifier,
	ApplyColorModifier = ThemeHelpers.ApplyColorModifier,
	GetNextVariant = ThemeHelpers.GetNextVariant,
	DefaultThemeConfig = DefaultThemeConfig.DefaultThemeConfig,
	WithConfigDefaults = DefaultThemeConfig.WithConfigDefaults,
	Types = Types,
	Constants = Constants,
}

end)() end,
    [129] = function()local wax,script,require=ImportGlobals(129)local ImportGlobals return (function(...)--!strict
-- Generative theme constants: contrast anchors and reference colors for the
-- extended palette.

local BASE_LIGHT_TEXT_COLOR = Color3.fromHex("#F8FAFC")
local BASE_DARK_TEXT_COLOR = Color3.fromHex("#09090B")

-- Extended palette seeds. Each named theme only provides its background
-- base color and accent seeds; these hues are shared across every theme
-- and are re-generated with a lightness floor so they stay visible on
-- the theme's background tiers.
local COLOR_SEEDS = {
	Blue = Color3.fromRGB(40, 80, 180),
	Brown = Color3.fromRGB(120, 80, 50),
	Cyan = Color3.fromRGB(40, 170, 190),
	Gray = Color3.fromRGB(80, 80, 80),
	Green = Color3.fromRGB(40, 150, 80),
	Magenta = Color3.fromRGB(180, 60, 180),
	Orange = Color3.fromRGB(230, 120, 40),
	Pink = Color3.fromRGB(230, 100, 150),
	Purple = Color3.fromRGB(110, 60, 170),
	Red = Color3.fromRGB(200, 50, 50),
	Success = Color3.fromRGB(50, 200, 70),
	Violet = Color3.fromRGB(140, 80, 200),
	White = Color3.fromRGB(200, 200, 200),
	Yellow = Color3.fromRGB(230, 200, 60),
}

return {
	BASE_LIGHT_TEXT_COLOR = BASE_LIGHT_TEXT_COLOR,
	BASE_DARK_TEXT_COLOR = BASE_DARK_TEXT_COLOR,
	COLOR_SEEDS = COLOR_SEEDS,
}

end)() end,
    [130] = function()local wax,script,require=ImportGlobals(130)local ImportGlobals return (function(...)--!strict
--!nolint LocalShadow

local ColorSpace = require(script.Parent.Parent.colorSpace)

local Types = require(script.Parent.types)
local Constants = require(script.Parent.constants)

local CORNER_RADIUS_SM = 3
local CORNER_RADIUS_MD = 6
local CORNER_RADIUS_LG = 9

local BACKGROUND_PALETTE_SIZE = 6
local BACKGROUND_LIGHTNESS_STRENGTH = 0.225
local MAX_BACKGROUND_TINT_CHROMA = 0.035

local SUNKEN_TOWARD_BLACK = 0.14

local GAMUT_SEARCH_ITERATIONS = 12
local MIN_ACCENT_TEXT_CONTRAST = 4.5

local EXTENDED_PALETTE_MIN_LIGHTNESS_OFFSET = 0.18

local LIGHT_TEXT_SURFACE_BLEND = { 0, 0.18, 0.36, 0.46, 0.56 }
local DARK_TEXT_SURFACE_BLEND = { 0, 0.25, 0.5, 0.64, 0.76 }

local function LerpColor(from: Color3, to: Color3, alpha: number): Color3
	return ColorSpace.ToGamutMappedColor3(
		ColorSpace.Oklab.From(from):Lerp(ColorSpace.Oklab.From(to), alpha)
	)
end

local function GenBackgroundPalette(baseColor: Color3, tintColor: Color3): { Color3 }
	local baseOklab = ColorSpace.Oklab.From(baseColor)
	local baseOklch = baseOklab:ToOklch()
	local tintOklch = ColorSpace.Oklch.From(tintColor)
	local targetLightness = if baseOklch:IsDark() then 1 else 0

	local targetChroma = math.min(
		tintOklch.chroma,
		math.max(baseOklch.chroma, MAX_BACKGROUND_TINT_CHROMA)
	)
	local targetTint = ColorSpace.Oklch.new(baseOklch.lightness, targetChroma, tintOklch.hue):ToOklab()

	local palette = table.create(BACKGROUND_PALETTE_SIZE) :: { Color3 }
	palette[1] = baseColor

	for idx = 2, BACKGROUND_PALETTE_SIZE do
		local progress = (idx - 1) / (BACKGROUND_PALETTE_SIZE - 1)
		local newLightness = baseOklab.lightness
			+ (targetLightness - baseOklab.lightness) * progress * BACKGROUND_LIGHTNESS_STRENGTH

		palette[idx] = ColorSpace.ToGamutMappedColor3(
			ColorSpace.Oklab.new(
				newLightness,
				baseOklab.a + (targetTint.a - baseOklab.a) * progress,
				baseOklab.b + (targetTint.b - baseOklab.b) * progress
			)
		)
	end

	return palette
end

local function GenLerpedPalette(colors: { Color3 }, alpha: number): { Color3 }
	local palette = table.create(#colors - 1) :: { Color3 }

	for idx = 1, #colors - 1 do
		local thisColor = colors[idx + 1]

		palette[idx] = LerpColor(colors[idx], thisColor, alpha)
	end

	return palette
end

local function GenFgPalette(surfaceColor: Color3, amount: number?): { Color3 }
	local baseFgColor = ColorSpace.Srgb.From(
		ColorSpace.Srgb.From(surfaceColor):BestContrast(
			ColorSpace.Srgb.From(Constants.BASE_LIGHT_TEXT_COLOR),
			ColorSpace.Srgb.From(Constants.BASE_DARK_TEXT_COLOR)
		)
	):ToColor3()
	local baseFg = ColorSpace.Oklab.From(baseFgColor)
	local surface = ColorSpace.Oklab.From(surfaceColor)
	local blendSteps = if baseFg:IsDark() then DARK_TEXT_SURFACE_BLEND else LIGHT_TEXT_SURFACE_BLEND
	local paletteSize = amount or 3

	assert(paletteSize <= #blendSteps, "Foreground palette exceeds configured tiers")

	local palette = table.create(paletteSize) :: { Color3 }
	palette[1] = baseFgColor
	for idx = 2, paletteSize do
		palette[idx] = ColorSpace.ToGamutMappedColor3(baseFg:Lerp(surface, blendSteps[idx]))
	end

	return palette
end

local function GenFgAccent(accentColor: Color3, primaryFgColor: Color3, surfaceColor: Color3): Color3
	local accentOklch = ColorSpace.Oklch.From(accentColor)
	local primaryFg = ColorSpace.Oklch.From(primaryFgColor)
	local candidate = ColorSpace.ToGamutMappedColor3(
		ColorSpace.Oklch.new(
			accentOklch.lightness + (primaryFg.lightness - accentOklch.lightness) * 0.6,
			math.min(math.max(accentOklch.chroma * 0.7, 0.08), 0.16),
			accentOklch.hue
		)
	)

	if ColorSpace.Srgb.From(surfaceColor):CheckContrast(candidate).ratio >= MIN_ACCENT_TEXT_CONTRAST then
		return candidate
	end

	local low = 0
	local high = 1
	local best = primaryFgColor
	for _ = 1, GAMUT_SEARCH_ITERATIONS do
		local midpoint = (low + high) / 2
		local adjusted = LerpColor(candidate, primaryFgColor, midpoint)

		if ColorSpace.Srgb.From(surfaceColor):CheckContrast(adjusted).ratio
			>= MIN_ACCENT_TEXT_CONTRAST then
			high = midpoint
			best = adjusted
		else
			low = midpoint
		end
	end

	return best
end

local function GenExtendedPalette(bgBaseColor: Color3): { [string]: Color3 }
	local baseOklch = ColorSpace.Oklch.From(bgBaseColor)
	local baseLightness = baseOklch.lightness
	local minLightness = baseLightness + EXTENDED_PALETTE_MIN_LIGHTNESS_OFFSET
	local maxLightness = baseLightness - EXTENDED_PALETTE_MIN_LIGHTNESS_OFFSET

	local palette: { [string]: Color3 } = {}
	for rawName, seed in Constants.COLOR_SEEDS do
		local name: string = rawName :: any
		local seedOklch = ColorSpace.Oklch.From(seed)
		local lightness = if baseOklch:IsDark() then math.max(seedOklch.lightness, minLightness)
			else math.min(seedOklch.lightness, maxLightness)

		palette[name] = ColorSpace.ToGamutMappedColor3(
			ColorSpace.Oklch.new(lightness, seedOklch.chroma, seedOklch.hue)
		)
	end
	return palette
end

local function CreateTheme(config: Types.ThemeConfig): Types.ThemeSource
	local bgBaseColor = config.BgBaseColor
	local accentPrimary = config.AccentPrimary
	local accentSecondary = config.AccentSecondary
	local accentCaution = config.AccentCaution
	local accentDestructive = config.AccentDestructive

	local bgColors = GenBackgroundPalette(bgBaseColor, config.BgTintColor or bgBaseColor)
	local bgHighlightColors = GenLerpedPalette(bgColors, 0.5)

	local fgColors = GenFgPalette(bgBaseColor, 5)

	local accentPrimaryFgColors = GenFgPalette(accentPrimary)
	local accentSecondaryFgColors = GenFgPalette(accentSecondary)
	local accentCautionFgColors = GenFgPalette(accentCaution)
	local accentDestructiveFgColors = GenFgPalette(accentDestructive)

	local primaryFgColor = fgColors[1]

	local extendedPalette = GenExtendedPalette(bgBaseColor)

	local source: Types.ThemeSource = {
		BgPrimary = bgColors[1],
		BgSecondary = bgColors[2],
		BgTertiary = bgColors[3],
		BgQuaternary = bgColors[4],
		BgQuinary = bgColors[5],
		BgPrimaryHighlight = bgHighlightColors[1],
		BgSecondaryHighlight = bgHighlightColors[2],
		BgTertiaryHighlight = bgHighlightColors[3],
		BgQuaternaryHighlight = bgHighlightColors[4],
		BgQuinaryHighlight = bgHighlightColors[5],
		BgSunken = LerpColor(bgBaseColor, Color3.new(0, 0, 0), SUNKEN_TOWARD_BLACK),
		FgPrimary = primaryFgColor,
		FgSecondary = fgColors[2],
		FgTertiary = fgColors[3],
		FgQuaternary = fgColors[4],
		FgQuinary = fgColors[5],
		AccentPrimary = accentPrimary,
		AccentSecondary = accentSecondary,
		AccentCaution = accentCaution,
		AccentDestructive = accentDestructive,
		AccentPrimaryFgPrimary = accentPrimaryFgColors[1],
		AccentPrimaryFgSecondary = accentPrimaryFgColors[2],
		AccentPrimaryFgTertiary = accentPrimaryFgColors[3],
		AccentSecondaryFgPrimary = accentSecondaryFgColors[1],
		AccentSecondaryFgSecondary = accentSecondaryFgColors[2],
		AccentSecondaryFgTertiary = accentSecondaryFgColors[3],
		AccentCautionFgPrimary = accentCautionFgColors[1],
		AccentCautionFgSecondary = accentCautionFgColors[2],
		AccentCautionFgTertiary = accentCautionFgColors[3],
		AccentDestructiveFgPrimary = accentDestructiveFgColors[1],
		AccentDestructiveFgSecondary = accentDestructiveFgColors[2],
		AccentDestructiveFgTertiary = accentDestructiveFgColors[3],
		AccentFgPrimary = GenFgAccent(accentPrimary, primaryFgColor, bgBaseColor),
		AccentFgSecondary = GenFgAccent(accentSecondary, primaryFgColor, bgBaseColor),
		AccentFgCaution = GenFgAccent(accentCaution, primaryFgColor, bgBaseColor),
		AccentFgDestructive = GenFgAccent(accentDestructive, primaryFgColor, bgBaseColor),
		Success = extendedPalette.Success,
		Blue = extendedPalette.Blue,
		Brown = extendedPalette.Brown,
		Cyan = extendedPalette.Cyan,
		Gray = extendedPalette.Gray,
		Green = extendedPalette.Green,
		Magenta = extendedPalette.Magenta,
		Orange = extendedPalette.Orange,
		Pink = extendedPalette.Pink,
		Purple = extendedPalette.Purple,
		Red = extendedPalette.Red,
		Violet = extendedPalette.Violet,
		White = extendedPalette.White,
		Yellow = extendedPalette.Yellow,
		HeightSm = config.HeightSm,
		HeightMd = config.HeightMd,
		HeightLg = config.HeightLg,
		CornerRadiusSm = CORNER_RADIUS_SM,
		CornerRadiusMd = CORNER_RADIUS_MD,
		CornerRadiusLg = CORNER_RADIUS_LG,
		FontMain = config.FontMain,
		FontMono = config.FontMono,
		FontMainTitleSize = config.FontMainTitleSize,
		FontMainBodySize = config.FontMainBodySize,
		FontMainCaptionSize = config.FontMainCaptionSize,
		FontMonoTitleSize = config.FontMonoTitleSize,
		FontMonoBodySize = config.FontMonoBodySize,
		FontMonoCaptionSize = config.FontMonoCaptionSize,
	}
	for token, color in config.Overrides or {} do
		if typeof(source[token]) == "Color3" and typeof(color) == "Color3" then
			source[token] = color
		end
	end
	return source
end

return CreateTheme

end)() end,
    [131] = function()local wax,script,require=ImportGlobals(131)local ImportGlobals return (function(...)--!strict

local Types = require(script.Parent.types)

-- Default generative theme config. Named themes in src/ui/theme/palettes
-- only override the seed colors; everything else falls back to these
-- layout/font defaults.
local function DefaultThemeConfig(): Types.ThemeConfig
	return {
		BgBaseColor = Color3.fromRGB(18, 18, 22),
		AccentPrimary = Color3.fromRGB(70, 100, 210),
		AccentSecondary = Color3.fromRGB(55, 165, 185),
		AccentCaution = Color3.fromHex("#A47103"),
		AccentDestructive = Color3.fromHex("#BE123C"),
		HeightSm = 24,
		HeightMd = 28,
		HeightLg = 36,
		FontMain = Font.new("rbxassetid://12187365364"),
		FontMono = Font.fromName("RobotoMono"),
		FontMainTitleSize = 15,
		FontMainBodySize = 14,
		FontMainCaptionSize = 12,
		FontMonoTitleSize = 14,
		FontMonoBodySize = 13,
		FontMonoCaptionSize = 12,
	}
end

-- Fill every missing config key with its default. Configs coming from the
-- theme registry are frozen, so this returns a merged clone.
local function WithConfigDefaults(config: Types.ThemeConfig?): Types.ThemeConfig
	if not config then
		return DefaultThemeConfig()
	end

	local merged = table.clone(DefaultThemeConfig())
	for key, value in pairs(config) do
		merged[key] = value
	end
	return merged
end

return {
	DefaultThemeConfig = DefaultThemeConfig,
	WithConfigDefaults = WithConfigDefaults,
}

end)() end,
    [132] = function()local wax,script,require=ImportGlobals(132)local ImportGlobals return (function(...)--!strict
--!nolint LocalShadow

local Fusion = require(script.Parent.Parent.Parent.packages.fusion)

local Oktween = require(script.Parent.Parent.fusionUtils.oktween)

local Types = require(script.Parent.types)
local ThemeHelpers = require(script.Parent.themeHelpers)
local CreateTheme = require(script.Parent.createTheme)

local Value = Fusion.Value

local THEME_COLOR_TWEEN_INFO = TweenInfo.new(
	.55,
	Enum.EasingStyle.Exponential,
	Enum.EasingDirection.InOut
)

type ManagedTheme = {
	Public: Types.Theme,
	Targets: { [string]: Fusion.Value<any> },
}

-- Per-scope managed theme registry. Scopes are plain tables (see the
-- vendored Fusion's deriveScope), so weak keys let themes die with their
-- scope.
local managedThemes = setmetatable({}, { __mode = "k" }) :: { [Fusion.Scope]: ManagedTheme }

local function CreateManagedTheme(scope: Fusion.Scope<unknown>, config: Types.ThemeConfig): ManagedTheme
	local source = CreateTheme(config)
	local targets: { [string]: Fusion.Value<any> } = {}

	local theme = {
		GetToken = ThemeHelpers.GetToken,
		GetBg = ThemeHelpers.GetBg,
		GetBgHighlight = ThemeHelpers.GetBgHighlight,
		GetFg = ThemeHelpers.GetFg,
		GetAccent = ThemeHelpers.GetAccent,
		GetAccentFg = ThemeHelpers.GetAccentFg,
		GetHeight = ThemeHelpers.GetHeight,
		GetCornerRadius = ThemeHelpers.GetCornerRadius,
		GetFont = ThemeHelpers.GetFont,
		GetFontSize = ThemeHelpers.GetFontSize,
		HighlightGradient = ThemeHelpers.HighlightGradient,
		ApplyColorModifier = ThemeHelpers.ApplyColorModifier,
		GetNextVariant = ThemeHelpers.GetNextVariant,
	} :: any

	for key, sourceValue in pairs(source) do
		local target = Value(scope, sourceValue)

		targets[key] = target
		theme[key] = if typeof(sourceValue) == "Color3" then Oktween(
				scope,
				target,
				THEME_COLOR_TWEEN_INFO
			)
			else target
	end

	return {
		Public = theme,
		Targets = targets,
	}
end

local function UpdateTheme(managedTheme: ManagedTheme, config: Types.ThemeConfig)
	local source = CreateTheme(config)

	for key, target in pairs(managedTheme.Targets) do
		target:set(source[key])
	end
end

-- Register (or refresh) the theme for a scope. New scopes get a fresh
-- managed theme; existing scopes re-generate their tokens in place.
local function SetThemeForScope(scope: Fusion.Scope<unknown>, config: Types.ThemeConfig)
	local managedTheme = managedThemes[scope]

	if managedTheme then
		UpdateTheme(managedTheme, config)
	else
		managedThemes[scope] = CreateManagedTheme(scope, config)
	end
end

-- Returns nil when the scope has no registered theme (callers fall back
-- to their library-level theme).
local function GetThemeForScope(scope: Fusion.Scope<unknown>): Types.Theme?
	local managedTheme = managedThemes[scope]

	return managedTheme and managedTheme.Public or nil
end

return {
	SetThemeForScope = SetThemeForScope,
	GetThemeForScope = GetThemeForScope,
}

end)() end,
    [133] = function()local wax,script,require=ImportGlobals(133)local ImportGlobals return (function(...)--!strict
--!nolint LocalShadow

local Fusion = require(script.Parent.Parent.Parent.packages.fusion)

local ColorSpace = require(script.Parent.Parent.colorSpace)

local Types = require(script.Parent.types)
local Constants = require(script.Parent.constants)

local Computed, New = Fusion.Computed, Fusion.New

-- Public semantic names resolve here so components do not need to know the
-- generated palette's storage keys. Canonical generated names are accepted as
-- well, which keeps this interface useful for less common tokens.
local TOKEN_NAMES = table.freeze({
	accent = "AccentPrimary",
	background = "BgPrimary",
	["background.secondary"] = "BgPrimaryHighlight",
	stroke = "BgTertiary",
	text = "FgPrimary",
	["text.secondary"] = "FgSecondary",
	["text.tertiary"] = "FgTertiary",
	["text.quaternary"] = "FgQuaternary",
	["text.quinary"] = "FgQuinary",
	danger = "AccentDestructive",
	warning = "AccentCaution",
	success = "Success",
	blue = "Blue",
	brown = "Brown",
	cyan = "Cyan",
	gray = "Gray",
	green = "Green",
	magenta = "Magenta",
	orange = "Orange",
	pink = "Pink",
	purple = "Purple",
	red = "Red",
	violet = "Violet",
	white = "White",
	yellow = "Yellow",
	["font.main"] = "FontMain",
	["font.mono"] = "FontMono",
})

local function GetToken(theme: Types.Theme, scope: Fusion.Scope, tokenName: Fusion.UsedAs<string>): Fusion.UsedAs<unknown>
	return Computed(
		scope,
		function(use)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local requestedName = use(tokenName)
			local generatedName = TOKEN_NAMES[requestedName] or requestedName
			local token = theme[generatedName]

			assert(token ~= nil, (`Unknown theme token %q`):format(requestedName))
			return use(token)
		end
	)
end

local function LerpColor(from: Color3, to: Color3, alpha: number)
	return ColorSpace.ToGamutMappedColor3(
		ColorSpace.Oklab.From(from):Lerp(ColorSpace.Oklab.From(to), alpha)
	)
end

local function ComputeWithDefault(
	theme: Types.Theme,
	scope: Fusion.Scope,
	itemName: Fusion.UsedAs<string>,
	default: any
)
	return Computed(
		scope,
		function(use)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedItemName = use(itemName)

			return use(theme[usedItemName]) or default
		end
	)
end

local function ResolveColorModifier(
	theme: Types.Theme,
	use: Fusion.Use,
	color: Color3,
	modifier: Types.ThemeColorModifier?
): Color3
	return if modifier == "Hover" then LerpColor(color, use(theme.BgPrimary), .1)
		elseif modifier == "HoverStroke" then LerpColor(color, use(theme.FgPrimary), .1)
		elseif modifier == "Press" then LerpColor(color, use(theme.BgPrimary), .2)
		else color
end

local function ApplyColorModifier(
	theme: Types.Theme,
	scope: Fusion.Scope,
	color: Fusion.UsedAs<Color3>,
	modifier: Fusion.UsedAs<Types.ThemeColorModifier?>
): Fusion.Computed<Color3>
	return Computed(
		scope,
		function(use, scope): Color3
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			return ResolveColorModifier(theme, use, use(color), use(modifier))
		end
	)
end

local function ApplyNamedColorModifier(
	theme: Types.Theme,
	scope: Fusion.Scope,
	colorName: Fusion.UsedAs<string>,
	defaultColor: Fusion.UsedAs<Color3>,
	modifier: Fusion.UsedAs<Types.ThemeColorModifier?>
): Fusion.Computed<Color3>
	return Computed(
		scope,
		function(use, scope): Color3
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedColorName = use(colorName)

			local usedColor = use(theme[usedColorName] :: Fusion.UsedAs<Color3>)
				or use(defaultColor)

			return ResolveColorModifier(theme, use, usedColor, use(modifier))
		end
	)
end

local function GetBg(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.BgVariant>,
	modifier: Fusion.UsedAs<Types.ThemeColorModifier?>
): Fusion.UsedAs<Color3>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			return `Bg{usedVariant}`
		end
	)

	return ApplyNamedColorModifier(theme, scope, computeName, theme.BgPrimary, modifier)
end

local function GetBgHighlight(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.BgVariant>,
	modifier: Fusion.UsedAs<Types.ThemeColorModifier?>
): Fusion.UsedAs<Color3>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			return `Bg{usedVariant}Highlight`
		end
	)

	return ApplyNamedColorModifier(theme, scope, computeName, theme.BgPrimaryHighlight, modifier)
end

local function GetFg(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.FgVariant>,
	accentVariant: Fusion.UsedAs<Types.AccentVariant?>?,
	modifier: Fusion.UsedAs<Types.ThemeColorModifier?>
): Fusion.UsedAs<Color3>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)
			local usedAccentVariant = use(accentVariant)

			return if usedAccentVariant then `Accent{usedAccentVariant}Fg{usedVariant}`
				else `Fg{usedVariant}`
		end
	)

	return ApplyNamedColorModifier(theme, scope, computeName, theme.FgPrimary, modifier)
end

local function GetAccent(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.AccentVariant>,
	modifier: Fusion.UsedAs<Types.ThemeColorModifier?>
): Fusion.UsedAs<Color3>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			return `Accent{usedVariant}`
		end
	)

	return ApplyNamedColorModifier(theme, scope, computeName, theme.AccentPrimary, modifier)
end

local function GetAccentFg(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.AccentVariant>,
	modifier: Fusion.UsedAs<Types.ThemeColorModifier?>
): Fusion.UsedAs<Color3>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			return `AccentFg{usedVariant}`
		end
	)

	return ApplyNamedColorModifier(theme, scope, computeName, theme.AccentPrimary, modifier)
end

local function GetHeight(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.HeightVariant>
): Fusion.UsedAs<number>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			return `Height{usedVariant}`
		end
	)

	return ComputeWithDefault(theme, scope, computeName, theme.HeightLg)
end

local function GetCornerRadius(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.CornerRadiusVariant>
): Fusion.UsedAs<number>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			return `CornerRadius{usedVariant}`
		end
	)

	return ComputeWithDefault(theme, scope, computeName, theme.CornerRadiusMd)
end

local function GetFont(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.FontVariant>,
	weight: Fusion.UsedAs<Enum.FontWeight>?,
	style: Fusion.UsedAs<Enum.FontStyle>?
): Fusion.UsedAs<Font>
	return Computed(
		scope,
		function(use, scope): Font
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			local font = use(theme[`Font{usedVariant}`] :: Fusion.UsedAs<Font>)
				or use(theme.FontMain)

			return Font.new(
				font.Family,
				use(weight) or Enum.FontWeight.Medium,
				use(style) or Enum.FontStyle.Normal
			)
		end
	)
end

local function GetFontSize(
	theme: Types.Theme,
	scope: Fusion.Scope,
	variant: Fusion.UsedAs<Types.FontVariant>,
	sizeVariant: Fusion.UsedAs<Types.FontSizeVariant>
): Fusion.UsedAs<number>
	local computeName = Computed(
		scope,
		function(use, scope)
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)
			local usedSizeVariant = use(sizeVariant)

			return `Font{usedVariant}{usedSizeVariant}Size`
		end
	)

	return ComputeWithDefault(theme, scope, computeName, theme.FontMainBodySize)
end

local DefaultHighlightColor = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Constants.BASE_LIGHT_TEXT_COLOR),
	ColorSequenceKeypoint.new(1, Constants.BASE_DARK_TEXT_COLOR),
})

local function HighlightGradient(
	_theme: Types.Theme,
	scope: Fusion.Scope,
	transparency: Fusion.UsedAs<number>,
	gradientColor: Fusion.UsedAs<ColorSequence?>?
)
	local color = if gradientColor == nil then DefaultHighlightColor
		else Computed(
			scope,
			function(use): ColorSequence
				LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
				return use(gradientColor) or DefaultHighlightColor
			end
		)

	return New(scope, "UIGradient")({
		Color = color,
		Rotation = 90,
		Transparency = Computed(
			scope,
			function(use, scope)
				LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
				return NumberSequence.new(use(transparency))
			end
		),
	}) :: UIGradient
end

local function CalcColorModifier(
	scope: Fusion.Scope,
	isHover: Fusion.UsedAs<boolean>,
	isPress: Fusion.UsedAs<boolean>,
	hoverMode: ("Stroke" | "Default")?
): Fusion.UsedAs<Types.ThemeColorModifier?>
	return Fusion.Computed(
		scope,
		function(use, scope): Types.ThemeColorModifier?
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedIsHover, usedIsPress = use(isHover), use(isPress)

			return if usedIsPress then "Press"
				elseif usedIsHover then if hoverMode == "Stroke" then "HoverStroke" else "Hover"
				else nil
		end
	)
end

local function GetNextVariant(scope: Fusion.Scope, variant: Fusion.UsedAs<Types.BgVariant>): Fusion.UsedAs<Types.BgVariant>
	return Computed(
		scope,
		function(use, scope): Types.BgVariant
			LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
			local usedVariant = use(variant)

			return if usedVariant == "Primary" then "Secondary"
				elseif usedVariant == "Secondary" then "Tertiary"
				elseif usedVariant == "Tertiary" then "Quaternary"
				elseif usedVariant == "Quaternary" then "Quinary"
				else "Secondary"
		end
	)
end

return {
	GetToken = GetToken,
	GetBg = GetBg,
	GetBgHighlight = GetBgHighlight,
	GetFg = GetFg,
	GetAccent = GetAccent,
	GetAccentFg = GetAccentFg,
	GetHeight = GetHeight,
	GetCornerRadius = GetCornerRadius,
	GetFont = GetFont,
	GetFontSize = GetFontSize,
	HighlightGradient = HighlightGradient,
	ApplyColorModifier = ApplyColorModifier,
	CalcColorModifier = CalcColorModifier,
	GetNextVariant = GetNextVariant,
}

end)() end,
    [134] = function()local wax,script,require=ImportGlobals(134)local ImportGlobals return (function(...)--!strict
--!nolint LocalShadow

local Fusion = require(script.Parent.Parent.Parent.packages.fusion)

export type BgVariant = "Primary" | "Secondary" | "Tertiary" | "Quaternary" | "Quinary"

export type FgVariant = "Primary" | "Secondary" | "Tertiary" | "Quaternary" | "Quinary"

export type AccentVariant = "Primary" | "Secondary" | "Caution" | "Destructive"

export type HeightVariant = "Sm" | "Md" | "Lg"

export type CornerRadiusVariant = "Sm" | "Md" | "Lg"

export type FontVariant = "Main" | "Mono"

export type FontSizeVariant = "Title" | "Body" | "Caption"

export type ThemeColorModifier = "Hover" | "Press" | "HoverStroke"

-- A theme is fully described by a handful of seed colors plus layout
-- dimensions. Everything else is generated in Oklab by createTheme.
export type ThemeConfig = {
	BgBaseColor: Color3,
	-- Optional hue target for elevated backgrounds. When omitted, tiers
	-- preserve BgBaseColor's hue and neutral themes remain neutral.
	BgTintColor: Color3?,

	AccentPrimary: Color3,
	AccentSecondary: Color3,
	AccentCaution: Color3,
	AccentDestructive: Color3,

	HeightSm: number,
	HeightMd: number,
	HeightLg: number,

	FontMain: Font,
	FontMono: Font,

	FontMainTitleSize: number,
	FontMainBodySize: number,
	FontMainCaptionSize: number,

	FontMonoTitleSize: number,
	FontMonoBodySize: number,
	FontMonoCaptionSize: number,

	[string]: any,
}

export type ThemeSource = {
	BgPrimary: Color3,
	BgSecondary: Color3,
	BgTertiary: Color3,
	BgQuaternary: Color3,
	BgQuinary: Color3,
	BgPrimaryHighlight: Color3,
	BgSecondaryHighlight: Color3,
	BgTertiaryHighlight: Color3,
	BgQuaternaryHighlight: Color3,
	BgQuinaryHighlight: Color3,
	BgSunken: Color3,
	FgPrimary: Color3,
	FgSecondary: Color3,
	FgTertiary: Color3,
	FgQuaternary: Color3,
	FgQuinary: Color3,
	AccentPrimary: Color3,
	AccentSecondary: Color3,
	AccentCaution: Color3,
	AccentDestructive: Color3,
	AccentPrimaryFgPrimary: Color3,
	AccentPrimaryFgSecondary: Color3,
	AccentPrimaryFgTertiary: Color3,
	AccentSecondaryFgPrimary: Color3,
	AccentSecondaryFgSecondary: Color3,
	AccentSecondaryFgTertiary: Color3,
	AccentCautionFgPrimary: Color3,
	AccentCautionFgSecondary: Color3,
	AccentCautionFgTertiary: Color3,
	AccentDestructiveFgPrimary: Color3,
	AccentDestructiveFgSecondary: Color3,
	AccentDestructiveFgTertiary: Color3,
	AccentFgPrimary: Color3,
	AccentFgSecondary: Color3,
	AccentFgCaution: Color3,
	AccentFgDestructive: Color3,
	Success: Color3,
	Blue: Color3,
	Brown: Color3,
	Cyan: Color3,
	Gray: Color3,
	Green: Color3,
	Magenta: Color3,
	Orange: Color3,
	Pink: Color3,
	Purple: Color3,
	Red: Color3,
	Violet: Color3,
	White: Color3,
	Yellow: Color3,
	HeightSm: number,
	HeightMd: number,
	HeightLg: number,
	CornerRadiusSm: number,
	CornerRadiusMd: number,
	CornerRadiusLg: number,
	FontMain: Font,
	FontMono: Font,
	FontMainTitleSize: number,
	FontMainBodySize: number,
	FontMainCaptionSize: number,
	FontMonoTitleSize: number,
	FontMonoBodySize: number,
	FontMonoCaptionSize: number,
	[string]: any,
}

-- The reactive theme object consumed by components: every token is a
-- Fusion state object (Color3 tokens tween in Oklab between themes).
export type Theme = {
	[string]: Fusion.UsedAs<unknown>,
	GetToken: (theme: Theme, scope: Fusion.Scope, tokenName: Fusion.UsedAs<string>) -> Fusion.UsedAs<unknown>,
	GetBg: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<BgVariant>, modifier: Fusion.UsedAs<ThemeColorModifier?>) -> Fusion.UsedAs<Color3>,
	GetBgHighlight: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<BgVariant>, modifier: Fusion.UsedAs<ThemeColorModifier?>) -> Fusion.UsedAs<Color3>,
	GetFg: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<FgVariant>, accentVariant: Fusion.UsedAs<AccentVariant?>?, modifier: Fusion.UsedAs<ThemeColorModifier?>) -> Fusion.UsedAs<Color3>,
	GetAccent: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<AccentVariant>, modifier: Fusion.UsedAs<ThemeColorModifier?>) -> Fusion.UsedAs<Color3>,
	GetAccentFg: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<AccentVariant>, modifier: Fusion.UsedAs<ThemeColorModifier?>) -> Fusion.UsedAs<Color3>,
	GetHeight: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<HeightVariant>) -> Fusion.UsedAs<number>,
	GetCornerRadius: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<CornerRadiusVariant>) -> Fusion.UsedAs<number>,
	GetFont: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<FontVariant>, weight: Fusion.UsedAs<Enum.FontWeight>?, style: Fusion.UsedAs<Enum.FontStyle>?) -> Fusion.UsedAs<Font>,
	GetFontSize: (theme: Theme, scope: Fusion.Scope, variant: Fusion.UsedAs<FontVariant>, sizeVariant: Fusion.UsedAs<FontSizeVariant>) -> Fusion.UsedAs<number>,
	HighlightGradient: (theme: Theme, scope: Fusion.Scope, transparency: Fusion.UsedAs<number>, gradientColor: Fusion.UsedAs<ColorSequence?>?) -> UIGradient,
}

return nil

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        2,
        {
            "EthosDex"
        },
        {
            {
                16,
                1,
                {
                    "assets"
                },
                {
                    {
                        19,
                        2,
                        {
                            "molto"
                        }
                    },
                    {
                        17,
                        2,
                        {
                            "ethosIcons"
                        }
                    },
                    {
                        18,
                        2,
                        {
                            "ethosIconsFont"
                        }
                    },
                    {
                        20,
                        2,
                        {
                            "runtimeManifest"
                        }
                    }
                }
            },
            {
                21,
                1,
                {
                    "core"
                },
                {
                    {
                        27,
                        2,
                        {
                            "tree"
                        }
                    },
                    {
                        24,
                        2,
                        {
                            "path"
                        }
                    },
                    {
                        25,
                        2,
                        {
                            "search"
                        }
                    },
                    {
                        28,
                        2,
                        {
                            "values"
                        }
                    },
                    {
                        22,
                        2,
                        {
                            "api"
                        }
                    },
                    {
                        23,
                        2,
                        {
                            "env"
                        }
                    },
                    {
                        26,
                        2,
                        {
                            "settings"
                        }
                    }
                }
            },
            {
                117,
                1,
                {
                    "utils"
                },
                {
                    {
                        119,
                        2,
                        {
                            "callbackBatch"
                        }
                    },
                    {
                        124,
                        2,
                        {
                            "keybindDispatcher"
                        }
                    },
                    {
                        126,
                        2,
                        {
                            "runtimeAssets"
                        }
                    },
                    {
                        125,
                        2,
                        {
                            "luauHighlight"
                        }
                    },
                    {
                        118,
                        2,
                        {
                            "assetCache"
                        }
                    },
                    {
                        120,
                        2,
                        {
                            "colorSpace"
                        },
                        {
                            {
                                121,
                                2,
                                {
                                    "contrast"
                                }
                            }
                        }
                    },
                    {
                        128,
                        2,
                        {
                            "themeUtils"
                        },
                        {
                            {
                                132,
                                2,
                                {
                                    "manageTheme"
                                }
                            },
                            {
                                133,
                                2,
                                {
                                    "themeHelpers"
                                }
                            },
                            {
                                130,
                                2,
                                {
                                    "createTheme"
                                }
                            },
                            {
                                134,
                                2,
                                {
                                    "types"
                                }
                            },
                            {
                                129,
                                2,
                                {
                                    "constants"
                                }
                            },
                            {
                                131,
                                2,
                                {
                                    "defaultThemeConfig"
                                }
                            }
                        }
                    },
                    {
                        122,
                        1,
                        {
                            "fusionUtils"
                        },
                        {
                            {
                                123,
                                2,
                                {
                                    "oktween"
                                }
                            }
                        }
                    },
                    {
                        127,
                        2,
                        {
                            "safecallback"
                        }
                    }
                }
            },
            {
                39,
                1,
                {
                    "ui"
                },
                {
                    {
                        40,
                        2,
                        {
                            "codeTheme"
                        }
                    },
                    {
                        42,
                        2,
                        {
                            "controls"
                        },
                        {
                            {
                                45,
                                2,
                                {
                                    "notices"
                                }
                            },
                            {
                                48,
                                2,
                                {
                                    "switch"
                                }
                            },
                            {
                                44,
                                2,
                                {
                                    "inputs"
                                }
                            },
                            {
                                47,
                                2,
                                {
                                    "surface"
                                }
                            },
                            {
                                43,
                                2,
                                {
                                    "buttons"
                                }
                            },
                            {
                                46,
                                2,
                                {
                                    "rows"
                                }
                            }
                        }
                    },
                    {
                        50,
                        1,
                        {
                            "icons"
                        },
                        {
                            {
                                52,
                                2,
                                {
                                    "dock"
                                }
                            },
                            {
                                53,
                                2,
                                {
                                    "shared"
                                }
                            },
                            {
                                51,
                                2,
                                {
                                    "cascader"
                                }
                            }
                        }
                    },
                    {
                        54,
                        2,
                        {
                            "images"
                        }
                    },
                    {
                        58,
                        2,
                        {
                            "theme"
                        },
                        {
                            {
                                59,
                                2,
                                {
                                    "palettes"
                                },
                                {
                                    {
                                        111,
                                        2,
                                        {
                                            "synthwave84"
                                        }
                                    },
                                    {
                                        62,
                                        2,
                                        {
                                            "ayuMirage"
                                        }
                                    },
                                    {
                                        107,
                                        2,
                                        {
                                            "solarizedDark"
                                        }
                                    },
                                    {
                                        65,
                                        2,
                                        {
                                            "catppuccinMacchiato"
                                        }
                                    },
                                    {
                                        89,
                                        2,
                                        {
                                            "midnight"
                                        }
                                    },
                                    {
                                        104,
                                        2,
                                        {
                                            "rosePineMoon"
                                        }
                                    },
                                    {
                                        79,
                                        2,
                                        {
                                            "gold"
                                        }
                                    },
                                    {
                                        96,
                                        2,
                                        {
                                            "orchid"
                                        }
                                    },
                                    {
                                        84,
                                        2,
                                        {
                                            "horizon"
                                        }
                                    },
                                    {
                                        102,
                                        2,
                                        {
                                            "rosePine"
                                        }
                                    },
                                    {
                                        73,
                                        2,
                                        {
                                            "eclipse"
                                        }
                                    },
                                    {
                                        63,
                                        2,
                                        {
                                            "catppuccinFrappe"
                                        }
                                    },
                                    {
                                        86,
                                        2,
                                        {
                                            "kanagawa"
                                        }
                                    },
                                    {
                                        115,
                                        2,
                                        {
                                            "vesper"
                                        }
                                    },
                                    {
                                        114,
                                        2,
                                        {
                                            "utils"
                                        }
                                    },
                                    {
                                        70,
                                        2,
                                        {
                                            "crimson"
                                        }
                                    },
                                    {
                                        76,
                                        2,
                                        {
                                            "frost"
                                        }
                                    },
                                    {
                                        67,
                                        2,
                                        {
                                            "citrus"
                                        }
                                    },
                                    {
                                        78,
                                        2,
                                        {
                                            "githubLight"
                                        }
                                    },
                                    {
                                        64,
                                        2,
                                        {
                                            "catppuccinLatte"
                                        }
                                    },
                                    {
                                        97,
                                        2,
                                        {
                                            "oxocarbon"
                                        }
                                    },
                                    {
                                        66,
                                        2,
                                        {
                                            "catppuccinMocha"
                                        }
                                    },
                                    {
                                        77,
                                        2,
                                        {
                                            "githubDark"
                                        }
                                    },
                                    {
                                        69,
                                        2,
                                        {
                                            "coffee"
                                        }
                                    },
                                    {
                                        81,
                                        2,
                                        {
                                            "gruvboxDark"
                                        }
                                    },
                                    {
                                        103,
                                        2,
                                        {
                                            "rosePineDawn"
                                        }
                                    },
                                    {
                                        113,
                                        2,
                                        {
                                            "tokyoNight"
                                        }
                                    },
                                    {
                                        92,
                                        2,
                                        {
                                            "nightOwl"
                                        }
                                    },
                                    {
                                        68,
                                        2,
                                        {
                                            "cobalt"
                                        }
                                    },
                                    {
                                        110,
                                        2,
                                        {
                                            "synthwave"
                                        }
                                    },
                                    {
                                        109,
                                        2,
                                        {
                                            "sunset"
                                        }
                                    },
                                    {
                                        83,
                                        2,
                                        {
                                            "highContrast"
                                        }
                                    },
                                    {
                                        61,
                                        2,
                                        {
                                            "ayuDark"
                                        }
                                    },
                                    {
                                        94,
                                        2,
                                        {
                                            "obsidian"
                                        }
                                    },
                                    {
                                        87,
                                        2,
                                        {
                                            "lagoon"
                                        }
                                    },
                                    {
                                        75,
                                        2,
                                        {
                                            "everforest"
                                        }
                                    },
                                    {
                                        74,
                                        2,
                                        {
                                            "ember"
                                        }
                                    },
                                    {
                                        98,
                                        2,
                                        {
                                            "palenight"
                                        }
                                    },
                                    {
                                        82,
                                        2,
                                        {
                                            "gruvboxLight"
                                        }
                                    },
                                    {
                                        108,
                                        2,
                                        {
                                            "solarizedLight"
                                        }
                                    },
                                    {
                                        88,
                                        2,
                                        {
                                            "lavender"
                                        }
                                    },
                                    {
                                        93,
                                        2,
                                        {
                                            "nord"
                                        }
                                    },
                                    {
                                        105,
                                        2,
                                        {
                                            "sakura"
                                        }
                                    },
                                    {
                                        101,
                                        2,
                                        {
                                            "rose"
                                        }
                                    },
                                    {
                                        80,
                                        2,
                                        {
                                            "graphite"
                                        }
                                    },
                                    {
                                        100,
                                        2,
                                        {
                                            "poimandres"
                                        }
                                    },
                                    {
                                        99,
                                        2,
                                        {
                                            "paper"
                                        }
                                    },
                                    {
                                        95,
                                        2,
                                        {
                                            "oneDark"
                                        }
                                    },
                                    {
                                        60,
                                        2,
                                        {
                                            "abyss"
                                        }
                                    },
                                    {
                                        106,
                                        2,
                                        {
                                            "sandstone"
                                        }
                                    },
                                    {
                                        91,
                                        2,
                                        {
                                            "moss"
                                        }
                                    },
                                    {
                                        90,
                                        2,
                                        {
                                            "monokai"
                                        }
                                    },
                                    {
                                        72,
                                        2,
                                        {
                                            "dracula"
                                        }
                                    },
                                    {
                                        85,
                                        2,
                                        {
                                            "jade"
                                        }
                                    },
                                    {
                                        112,
                                        2,
                                        {
                                            "terminal"
                                        }
                                    },
                                    {
                                        71,
                                        2,
                                        {
                                            "daylight"
                                        }
                                    }
                                }
                            }
                        }
                    },
                    {
                        116,
                        2,
                        {
                            "tokens"
                        }
                    },
                    {
                        57,
                        2,
                        {
                            "tabPill"
                        }
                    },
                    {
                        56,
                        2,
                        {
                            "pointer"
                        }
                    },
                    {
                        49,
                        2,
                        {
                            "fonts"
                        }
                    },
                    {
                        41,
                        2,
                        {
                            "codeView"
                        }
                    },
                    {
                        55,
                        2,
                        {
                            "motion"
                        }
                    }
                }
            },
            {
                2,
                2,
                {
                    "app"
                },
                {
                    {
                        4,
                        2,
                        {
                            "classIcon"
                        }
                    },
                    {
                        7,
                        2,
                        {
                            "menu"
                        }
                    },
                    {
                        8,
                        2,
                        {
                            "picker"
                        }
                    },
                    {
                        13,
                        2,
                        {
                            "state"
                        }
                    },
                    {
                        6,
                        2,
                        {
                            "explorer"
                        }
                    },
                    {
                        15,
                        2,
                        {
                            "window"
                        }
                    },
                    {
                        9,
                        2,
                        {
                            "preview"
                        }
                    },
                    {
                        11,
                        2,
                        {
                            "scriptViewer"
                        }
                    },
                    {
                        14,
                        2,
                        {
                            "toast"
                        }
                    },
                    {
                        3,
                        2,
                        {
                            "actions"
                        }
                    },
                    {
                        12,
                        2,
                        {
                            "settingsPage"
                        }
                    },
                    {
                        10,
                        2,
                        {
                            "properties"
                        }
                    },
                    {
                        5,
                        2,
                        {
                            "console"
                        }
                    }
                }
            },
            {
                29,
                1,
                {
                    "packages"
                },
                {
                    {
                        32,
                        2,
                        {
                            "luauLexer"
                        },
                        {
                            {
                                34,
                                2,
                                {
                                    "language"
                                }
                            },
                            {
                                33,
                                2,
                                {
                                    "constants"
                                }
                            },
                            {
                                35,
                                2,
                                {
                                    "navigator"
                                }
                            }
                        }
                    },
                    {
                        38,
                        2,
                        {
                            "states"
                        }
                    },
                    {
                        36,
                        2,
                        {
                            "maid"
                        }
                    },
                    {
                        37,
                        2,
                        {
                            "services"
                        }
                    },
                    {
                        31,
                        2,
                        {
                            "internal"
                        }
                    },
                    {
                        30,
                        2,
                        {
                            "fusion"
                        }
                    }
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    8,
    64,
    548,
    1007,
    1068,
    1366,
    2204,
    2487,
    2715,
    3013,
    3846,
    4450,
    4843,
    4905,
    4998,
    [17] = 5406,
    [18] = 5518,
    [19] = 5579,
    [20] = 5638,
    [22] = 5660,
    [23] = 5975,
    [24] = 6578,
    [25] = 6652,
    [26] = 6792,
    [27] = 6878,
    [28] = 7305,
    [30] = 7530,
    [31] = 11651,
    [32] = 11660,
    [33] = 12751,
    [34] = 12824,
    [35] = 13341,
    [36] = 13648,
    [37] = 13808,
    [38] = 13831,
    [40] = 13849,
    [41] = 13892,
    [42] = 14231,
    [43] = 14283,
    [44] = 14491,
    [45] = 14739,
    [46] = 14915,
    [47] = 15217,
    [48] = 15400,
    [49] = 15548,
    [51] = 15557,
    [52] = 15576,
    [53] = 15671,
    [54] = 15707,
    [55] = 15919,
    [56] = 15960,
    [57] = 15999,
    [58] = 16089,
    [59] = 16173,
    [60] = 16297,
    [61] = 16320,
    [62] = 16344,
    [63] = 16368,
    [64] = 16392,
    [65] = 16416,
    [66] = 16440,
    [67] = 16464,
    [68] = 16487,
    [69] = 16510,
    [70] = 16534,
    [71] = 16557,
    [72] = 16581,
    [73] = 16605,
    [74] = 16619,
    [75] = 16633,
    [76] = 16657,
    [77] = 16680,
    [78] = 16704,
    [79] = 16728,
    [80] = 16742,
    [81] = 16756,
    [82] = 16780,
    [83] = 16804,
    [84] = 16828,
    [85] = 16852,
    [86] = 16866,
    [87] = 16890,
    [88] = 16913,
    [89] = 16936,
    [90] = 16950,
    [91] = 16974,
    [92] = 16997,
    [93] = 17021,
    [94] = 17045,
    [95] = 17068,
    [96] = 17092,
    [97] = 17106,
    [98] = 17130,
    [99] = 17154,
    [100] = 17178,
    [101] = 17202,
    [102] = 17216,
    [103] = 17240,
    [104] = 17264,
    [105] = 17288,
    [106] = 17311,
    [107] = 17335,
    [108] = 17359,
    [109] = 17383,
    [110] = 17406,
    [111] = 17430,
    [112] = 17454,
    [113] = 17478,
    [114] = 17502,
    [115] = 17520,
    [116] = 17544,
    [118] = 17591,
    [119] = 18160,
    [120] = 18342,
    [121] = 19075,
    [123] = 19119,
    [124] = 19287,
    [125] = 19582,
    [126] = 19728,
    [127] = 19798,
    [128] = 19805,
    [129] = 19842,
    [130] = 19877,
    [131] = 20128,
    [132] = 20176,
    [133] = 20277,
    [134] = 20673
}

-- Misc AOT variable imports
local WaxVersion = "0.4.2"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- ++++++++ ETHOS WAX LURAPH RUNTIME PATCH ++++++++ --
if not LPH_OBFUSCATED then
	function LPH_ATTRIBUTES(...) end
	function VM(...) return ... end
	function PRESET(...) return ... end
	function ERROR_HANDLING(...) return ... end
end

local function __ETHOS_WAX_RUNTIME()
	LPH_ATTRIBUTES(VM(NONE), PRESET(FAST), ERROR_HANDLING(false))
	
	-- Localizing certain libraries and built-ins for runtime efficiency
	local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
	      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION
	
	local table_insert = table.insert
	local table_remove = table.remove
	local table_freeze = table.freeze or function(t) return t end -- lol
	
	local coroutine_wrap = coroutine.wrap
	
	local string_sub = string.sub
	local string_match = string.match
	local string_gmatch = string.gmatch
	
	-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
	-- module path, "@lune/task"
	if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
	    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
	    if RequireSuccess and LuneTaskLib then
	        task = LuneTaskLib
	    end
	end
	
	local task_defer = task and task.defer
	
	-- If we're not running on the Roblox engine, we won't have a `task` global
	local Defer = task_defer or function(f, ...)
	    coroutine_wrap(f)(...)
	end
	
	-- ClassName "IDs"
	local ClassNameIdBindings = {
	    [1] = "Folder",
	    [2] = "ModuleScript",
	    [3] = "Script",
	    [4] = "LocalScript",
	    [5] = "StringValue",
	}
	
	local RefBindings = {} -- [RefId] = RealObject
	
	local ScriptClosures = {}
	local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
	local StoredModuleValues = {}
	local ScriptsToRun = {}
	
	-- wax.shared __index/__newindex
	local SharedEnvironment = {}
	
	-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
	-- It's meant to be as lazy as possible
	local RefChildren = {} -- [Ref] = {ChildrenRef, ...}
	
	-- Implemented instance methods
	local InstanceMethods = {
	    GetFullName = { {}, function(self)
	        local Path = self.Name
	        local ObjectPointer = self.Parent
	
	        while ObjectPointer do
	            Path = ObjectPointer.Name .. "." .. Path
	
	            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
	            ObjectPointer = ObjectPointer.Parent
	        end
	
	        return Path
	    end},
	
	    GetChildren = { {}, function(self)
	        local ReturnArray = {}
	
	        for Child in next, RefChildren[self] do
	            table_insert(ReturnArray, Child)
	        end
	
	        return ReturnArray
	    end},
	
	    GetDescendants = { {}, function(self)
	        local ReturnArray = {}
	
	        for Child in next, RefChildren[self] do
	            table_insert(ReturnArray, Child)
	
	            for _, Descendant in next, Child:GetDescendants() do
	                table_insert(ReturnArray, Descendant)
	            end
	        end
	
	        return ReturnArray
	    end},
	
	    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
	        local Children = RefChildren[self]
	
	        for Child in next, Children do
	            if Child.Name == name then
	                return Child
	            end
	        end
	
	        if recursive then
	            for Child in next, Children do
	                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
	                -- ref first, the engine uses a direct recursive call
	                return Child:FindFirstChild(name, true)
	            end
	        end
	    end},
	
	    FindFirstAncestor = { {"string"}, function(self, name)
	        local RefPointer = self.Parent
	        while RefPointer do
	            if RefPointer.Name == name then
	                return RefPointer
	            end
	
	            RefPointer = RefPointer.Parent
	        end
	    end},
	
	    -- Just to implement for traversal usage
	    WaitForChild = { {"string", "number?"}, function(self, name)
	        return self:FindFirstChild(name)
	    end},
	}
	
	-- "Proxies" to instance methods, with err checks etc
	local InstanceMethodProxies = {}
	for MethodName, MethodObject in next, InstanceMethods do
	    local Types = MethodObject[1]
	    local Method = MethodObject[2]
	
	    local EvaluatedTypeInfo = {}
	    for ArgIndex, TypeInfo in next, Types do
	        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
	        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
	    end
	
	    InstanceMethodProxies[MethodName] = function(self, ...)
	        if not RefChildren[self] then
	            error("Expected ':' not '.' calling member function " .. MethodName, 2)
	        end
	
	        local Args = {...}
	        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
	            local RealArg = Args[ArgIndex]
	            local RealArgType = type(RealArg)
	            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]
	
	            if RealArg == nil and not IsOptional then
	                error("Argument " .. RealArg .. " missing or nil", 3)
	            end
	
	            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
	                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
	            end
	        end
	
	        return Method(self, ...)
	    end
	end
	
	local function CreateRef(className, name, parent)
	    -- `name` and `parent` can also be set later by the init script if they're absent
	
	    -- Extras
	    local StringValue_Value
	
	    -- Will be set to RefChildren later aswell
	    local Children = setmetatable({}, {__mode = "k"})
	
	    -- Err funcs
	    local function InvalidMember(member)
	        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
	    end
	    local function ReadOnlyProperty(property)
	        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
	    end
	
	    local Ref = {}
	    local RefMetatable = {}
	
	    RefMetatable.__metatable = false
	
	    RefMetatable.__index = function(_, index)
	        if index == "ClassName" then -- First check "properties"
	            return className
	        elseif index == "Name" then
	            return name
	        elseif index == "Parent" then
	            return parent
	        elseif className == "StringValue" and index == "Value" then
	            -- Supporting StringValue.Value for Rojo .txt file conv
	            return StringValue_Value
	        else -- Lastly, check "methods"
	            local InstanceMethod = InstanceMethodProxies[index]
	
	            if InstanceMethod then
	                return InstanceMethod
	            end
	        end
	
	        -- Next we'll look thru child refs
	        for Child in next, Children do
	            if Child.Name == index then
	                return Child
	            end
	        end
	
	        -- At this point, no member was found; this is the same err format as Roblox
	        InvalidMember(index)
	    end
	
	    RefMetatable.__newindex = function(_, index, value)
	        -- __newindex is only for props fyi
	        if index == "ClassName" then
	            ReadOnlyProperty(index)
	        elseif index == "Name" then
	            name = value
	        elseif index == "Parent" then
	            -- We'll just ignore the process if it's trying to set itself
	            if value == Ref then
	                return
	            end
	
	            if parent ~= nil then
	                -- Remove this ref from the CURRENT parent
	                RefChildren[parent][Ref] = nil
	            end
	
	            parent = value
	
	            if value ~= nil then
	                -- And NOW we're setting the new parent
	                RefChildren[value][Ref] = true
	            end
	        elseif className == "StringValue" and index == "Value" then
	            -- Supporting StringValue.Value for Rojo .txt file conv
	            StringValue_Value = value
	        else
	            -- Same err as __index when no member is found
	            InvalidMember(index)
	        end
	    end
	
	    RefMetatable.__tostring = function()
	        return name
	    end
	
	    setmetatable(Ref, RefMetatable)
	
	    RefChildren[Ref] = Children
	
	    if parent ~= nil then
	        RefChildren[parent][Ref] = true
	    end
	
	    return Ref
	end
	
	-- Create real ref DOM from object tree
	local function CreateRefFromObject(object, parent)
	    local RefId = object[1]
	    local ClassNameId = object[2]
	    local Properties = object[3] -- Optional
	    local Children = object[4] -- Optional
	
	    local ClassName = ClassNameIdBindings[ClassNameId]
	
	    local Name = Properties and table_remove(Properties, 1) or ClassName
	
	    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
	    RefBindings[RefId] = Ref
	
	    if Properties then
	        for PropertyName, PropertyValue in next, Properties do
	            Ref[PropertyName] = PropertyValue
	        end
	    end
	
	    if Children then
	        for _, ChildObject in next, Children do
	            CreateRefFromObject(ChildObject, Ref)
	        end
	    end
	
	    return Ref
	end
	
	local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
	for _, Object in next, ObjectTree do
	    CreateRefFromObject(Object, RealObjectRoot)
	end
	
	-- Now we'll set script closure refs and check if they should be ran as a BaseScript
	for RefId, Closure in next, ClosureBindings do
	    local Ref = RefBindings[RefId]
	
	    ScriptClosures[Ref] = Closure
	    ScriptClosureRefIds[Ref] = RefId
	
	    local ClassName = Ref.ClassName
	    if ClassName == "LocalScript" or ClassName == "Script" then
	        table_insert(ScriptsToRun, Ref)
	    end
	end
	
	local function LoadScript(scriptRef)
	    local ScriptClassName = scriptRef.ClassName
	
	    -- First we'll check for a cached module value (packed into a tbl)
	    local StoredModuleValue = StoredModuleValues[scriptRef]
	    if StoredModuleValue and ScriptClassName == "ModuleScript" then
	        return unpack(StoredModuleValue)
	    end
	
	    local Closure = ScriptClosures[scriptRef]
	
	    local function FormatError(originalErrorMessage)
	        originalErrorMessage = tostring(originalErrorMessage)
	
	        local VirtualFullName = scriptRef:GetFullName()
	
	        -- Check for vanilla/Roblox format
	        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")
	
	        if not OriginalErrorLine or not LineOffsets then
	            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
	        end
	
	        OriginalErrorLine = tonumber(OriginalErrorLine)
	
	        local RefId = ScriptClosureRefIds[scriptRef]
	        local LineOffset = LineOffsets[RefId]
	
	        local RealErrorLine = OriginalErrorLine - LineOffset + 1
	        if RealErrorLine < 0 then
	            RealErrorLine = "?"
	        end
	
	        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
	    end
	
	    -- If it's a BaseScript, we'll just run it directly!
	    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
	        local RunSuccess, ErrorMessage = pcall(Closure)
	        if not RunSuccess then
	            error(FormatError(ErrorMessage), 0)
	        end
	    else
	        local PCallReturn = {pcall(Closure)}
	
	        local RunSuccess = table_remove(PCallReturn, 1)
	        if not RunSuccess then
	            local ErrorMessage = table_remove(PCallReturn, 1)
	            error(FormatError(ErrorMessage), 0)
	        end
	
	        StoredModuleValues[scriptRef] = PCallReturn
	        return unpack(PCallReturn)
	    end
	end
	
	-- We'll assign the actual func from the top of this output for flattening user globals at runtime
	-- Returns (in a tuple order): wax, script, require
	function ImportGlobals(refId)
	    local ScriptRef = RefBindings[refId]
	
	    local function RealCall(f, ...)
	        local PCallReturn = {pcall(f, ...)}
	
	        local CallSuccess = table_remove(PCallReturn, 1)
	        if not CallSuccess then
	            error(PCallReturn[1], 3)
	        end
	
	        return unpack(PCallReturn)
	    end
	
	    -- `wax.shared` index
	    local WaxShared = table_freeze(setmetatable({}, {
	        __index = SharedEnvironment,
	        __newindex = function(_, index, value)
	            SharedEnvironment[index] = value
	        end,
	        __len = function()
	            return #SharedEnvironment
	        end,
	        __iter = function()
	            return next, SharedEnvironment
	        end,
	    }))
	
	    local Global_wax = table_freeze({
	        -- From AOT variable imports
	        version = WaxVersion,
	        envname = EnvName,
	
	        shared = WaxShared,
	
	        -- "Real" globals instead of the env set ones
	        script = script,
	        require = require,
	    })
	
	    local Global_script = ScriptRef
	
	    local function Global_require(module, ...)
	        local ModuleArgType = type(module)
	
	        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
	        local ErrorSelfRequire = "Attempted to call require with self"
	
	        if ModuleArgType == "table" and RefChildren[module]  then
	            if module.ClassName ~= "ModuleScript" then
	                error(ErrorNonModuleScript, 2)
	            elseif module == ScriptRef then
	                error(ErrorSelfRequire, 2)
	            end
	
	            return LoadScript(module)
	        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
	            -- The control flow on this SUCKS
	
	            if #module == 0 then
	                error("Attempted to call require with empty string", 2)
	            end
	
	            local CurrentRefPointer = ScriptRef
	
	            if string_sub(module, 1, 1) == "/" then
	                CurrentRefPointer = RealObjectRoot
	            elseif string_sub(module, 1, 2) == "./" then
	                module = string_sub(module, 3)
	            end
	
	            local PreviousPathMatch
	            for PathMatch in string_gmatch(module, "([^/]*)/?") do
	                local RealIndex = PathMatch
	                if PathMatch == ".." then
	                    RealIndex = "Parent"
	                end
	
	                -- Don't advance dir if it's just another "/" either
	                if RealIndex ~= "" then
	                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
	                    if not ResultRef then
	                        local CurrentRefParent = CurrentRefPointer.Parent
	                        if CurrentRefParent then
	                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
	                        end
	                    end
	
	                    if ResultRef then
	                        CurrentRefPointer = ResultRef
	                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
	                        error("Virtual script path \"" .. module .. "\" not found", 2)
	                    end
	                end
	
	                -- For possible checks next cycle
	                PreviousPathMatch = PathMatch
	            end
	
	            if CurrentRefPointer.ClassName ~= "ModuleScript" then
	                error(ErrorNonModuleScript, 2)
	            elseif CurrentRefPointer == ScriptRef then
	                error(ErrorSelfRequire, 2)
	            end
	
	            return LoadScript(CurrentRefPointer)
	        end
	
	        return RealCall(require, module, ...)
	    end
	
	    -- Now, return flattened globals ready for direct runtime exec
	    return Global_wax, Global_script, Global_require
	end
	
	for _, ScriptRef in next, ScriptsToRun do
	    Defer(LoadScript, ScriptRef)
	end
	
	-- AoT adjustment: Load init module (MainModule behavior)
	return LoadScript(RealObjectRoot:GetChildren()[1])
end

return __ETHOS_WAX_RUNTIME()
