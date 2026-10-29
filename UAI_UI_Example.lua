-- UAI UI Library -- full example.
-- Run with the library next to it:
--     local Library = loadstring(readfile("UAI_UI_Library.lua"))()
-- or from a URL:
--     local Library = loadstring(game:HttpGet("<url>/UAI_UI_Library.lua"))()

local Library = loadstring(readfile("UAI_UI_Library.lua"))()

-- Every module of the client's interface layer, by its short name.
local P, C, R = Library.P, Library.C, Library.rows
local theme, overlay = Library.theme, Library.overlay

local UI = Library.new({
	title = "UAI UI Library",
	toggleKey = Enum.KeyCode.RightShift,
	launcher = true,
	panels = {
		-- ------------------------------------------------------------ components
		{
			id = "components", label = "Components", icon = "spark",
			build = function(parent, app)
				local page = app.scrollPanel(parent)

				-- R.section: heading + description over a card. Returns the card.
				local card = R.section(page, {
					title = "Buttons",
					description = "Every variant the client ships.",
					layoutOrder = 1,
				})
				local row = P.row(card, { size = UDim2.new(1, 0, 0, 0), auto = "Y", wrap = true, gap = theme.space.sm })
				for index, variant in ipairs({ "primary", "accent", "secondary", "soft", "ghost", "danger" }) do
					P.button(row, {
						text = variant, variant = variant, size = "md", layoutOrder = index,
						onClick = function() overlay.toast("Clicked " .. variant, "info", 2) end,
					})
				end
				local iconRow = P.row(card, { size = UDim2.new(1, 0, 0, 0), auto = "Y", gap = theme.space.xs })
				for index, name in ipairs({ "plus", "check", "copy", "trash", "search", "gear", "folder", "terminal" }) do
					P.iconButton(iconRow, { icon = name, layoutOrder = index })
				end

				local controls = R.section(page, {
					title = "Controls",
					description = "Switch, slider, segmented, progress, spinner.",
					layoutOrder = 2,
				})
				R.toggle(controls, { label = "Switch", hint = "R.toggle writes config when given a path.", value = true })
				R.setting(controls, { label = "Slider", hint = "C.slider with a continuous range." })
				C.slider(controls, { min = 0, max = 100, step = 1, value = 40 })
				C.segmented(controls, {
					options = { { value = "a", label = "Alpha" }, { value = "b", label = "Beta" }, { value = "c", label = "Gamma" } },
					value = "a",
					onChange = function(value) overlay.toast("Segment: " .. tostring(value), "info", 2) end,
				})
				local progress = C.progress(controls, { value = 0.35 })
				task.delay(1.5, function() progress.set(0.8) end)
				local spin = P.row(controls, { size = UDim2.new(1, 0, 0, 0), auto = "Y", gap = theme.space.sm, alignY = "Center" })
				C.spinner(spin, { layoutOrder = 1 })
				P.text(spin, { text = "Working...", role = "caption", color = theme.color.textTertiary, auto = "X", layoutOrder = 2 })

				local misc = R.section(page, { title = "Badges, facts, empty state", layoutOrder = 3 })
				local badges = P.row(misc, { size = UDim2.new(1, 0, 0, 0), auto = "Y", gap = theme.space.xs })
				for index, tone in ipairs({ "neutral", "good", "warn", "bad", "info" }) do
					P.badge(badges, { text = tone, tone = tone, dot = true, layoutOrder = index })
				end
				R.facts(misc, {
					{ key = "Library", value = Library.Version },
					{ key = "Layout mode", value = Library.responsive.mode },
					{ key = "Status", value = "Ready", tone = "good" },
				})
				C.emptyState(misc, { icon = "document", title = "Nothing here yet", description = "An empty state, as the client draws it." })
			end,
		},

		-- ------------------------------------------------------------ settings
		{
			id = "settings", label = "Appearance", icon = "sliders",
			build = function(parent, app)
				local page = app.scrollPanel(parent)

				-- Rows bound to the client's own theme settings: changing one rebuilds the shell.
				local card = R.section(page, {
					title = "Theme",
					description = "Bound to the same config paths the client uses.",
				})

				local accents = {}
				for _, key in ipairs({ "claude", "aurora", "indigo", "amber", "rose" }) do
					accents[#accents + 1] = { value = key, label = theme.ACCENTS[key].label }
				end
				R.select(card, { label = "Accent", hint = "Coral is the default.", path = "ui.accent", options = accents })
				R.segmented(card, {
					label = "Code theme", path = "ui.codeTheme",
					options = { { value = "dark", label = "Dark" }, { value = "light", label = "Light" } },
				})
				R.number(card, "Text size", "Scales every text role.", "ui.fontScale", 0.85, 1.4, 0.05)
				R.toggle(card, { label = "Sidebar collapsed", hint = "Same setting as the collapse button.", path = "ui.sidebarCollapsed" })

				local inputs = R.section(page, { title = "Fields" })
				R.field(inputs, {
					label = "Display name", placeholder = "Type, then click away",
					path = "example.name", hint = "Written on blur, like every field in the client.",
				})
				R.actions(inputs, {
					{ text = "Reset theme", variant = "secondary", onClick = function()
						Library.setTheme({ accent = "claude", fontScale = 1, codeTheme = "dark" })
					end },
					{ text = "Use Aurora", variant = "soft", onClick = function() Library.setAccent("aurora") end },
				})
			end,
		},

		-- ------------------------------------------------------------ overlay
		{
			id = "overlay", label = "Overlay", icon = "terminal",
			build = function(parent, app)
				local page = app.scrollPanel(parent)
				local card = R.section(page, {
					title = "Overlay surfaces",
					description = "Toast, confirm, prompt, modal, menu and code viewer.",
				})
				R.actions(card, {
					{ text = "Toast", onClick = function() Library.toast("Saved.", "good", 3) end },
					{ text = "Warning", onClick = function() Library.toast("Something needs attention.", "warn", 4, { title = "Heads up" }) end },
					{ text = "Confirm", onClick = function()
						Library.confirm({
							title = "Delete this item?", description = "This cannot be undone.",
							confirmText = "Delete", danger = true,
							onConfirm = function() Library.toast("Deleted.", "good", 2) end,
						})
					end },
					{ text = "Prompt", onClick = function()
						Library.prompt({
							title = "Rename", description = "Pick a new name.", value = "Untitled", confirmText = "Rename",
							onConfirm = function(text) Library.toast("Renamed to " .. text, "info", 3) end,
						})
					end },
					{ text = "Modal", onClick = function()
						local modal = Library.modal({ title = "A modal", description = "Content and footer slots." })
						if modal then
							P.text(modal.content, { text = "Anything can go in modal.content.", role = "body", wrap = true, auto = "Y" })
							P.button(modal.footer, { text = "Close", variant = "primary", size = "sm", onClick = modal.close })
						end
					end },
					{ text = "Code", onClick = function()
						Library.code({ title = "Highlighted", language = "luau", code = 'local x = 1\nprint("hello", x + 1)' })
					end },
				})
				local menuButton = P.button(card, { text = "Open menu", variant = "secondary", size = "md" })
				menuButton.instance.Activated:Connect(function()
					Library.menu({
						target = menuButton.instance,
						options = {
							{ label = "Copy", icon = "copy", shortcut = "Ctrl+C", value = "copy" },
							{ label = "Rename", icon = "document", value = "rename" },
							{ divider = true },
							{ label = "Delete", icon = "trash", value = "delete" },
						},
						onSelect = function(value) Library.toast("Menu: " .. tostring(value), "info", 2) end,
					})
				end)
			end,
		},
	},
	menu = function()
		return { { label = "Say hello", icon = "spark", onSelect = function() Library.toast("Hello!", "good", 2) end } }
	end,
})

UI.show("components")
return UI
