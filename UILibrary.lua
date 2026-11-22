--[[
	UI Library  (extracted from the menu of the supplied script, 1:1 visuals)
	-------------------------------------------------------------------------
	Single file. Usage:

		local Library = loadstring(readfile("UILibrary.lua"))()
		-- or: loadstring(game:HttpGet("<raw url>"))()

		Library.title = "my menu"
		local tab = Library.AddTab("aimbot", "crosshair")   -- NOTE: AddTab is called with a dot
		local col = tab:AddColumn()
		local sec = col:AddSection("main")
		sec:AddToggle({ text = "enabled", flag = "enabled" })
		Library.Init()

	See Example.lua for every component.
]]

local _registry = {}
local _cache = {}
local _loading = {}

local function requireModule(name)
	if _cache[name] ~= nil then
		return _cache[name]
	end
	if _loading[name] then
		error("Circular dependency detected while requiring " .. tostring(name), 2)
	end
	local factory = _registry[name]
	if not factory then
		error("Module " .. tostring(name) .. " not found in registry", 2)
	end
	_loading[name] = true
	local ok, result = pcall(factory, requireModule)
	_loading[name] = false
	if not ok then
		error("Error while running module " .. tostring(name) .. ": " .. tostring(result), 2)
	end
	_cache[name] = result
	return result
end

_registry["core/blind"] = (function()
return function(p)
	-- original hid executor globals from callbacks; a UI library shouldn't do that
	return { env = function(t) return t end }
end
end)()

_registry["core/log"] = (function()
return function(p)
	local log = { SINK = false }
	local function noop() end
	log.write, log.info, log.warn, log.fail = noop, noop, noop, noop
	log.entries = function() return {} end
	log.dump = function() return "" end
	log.count = function() return 0 end
	log.clear = noop
	return log
end
end)()

_registry["game/guard"] = (function()
return function(p)
	return {
		CLOCKED = false,
		charge = function() end,
		safe = function(fn) return fn end,
	}
end
end)()

_registry["services/mover"] = (function()
return function(p)
	-- generic replacement: horizontal speed of any character (used by the watermark "speed" stat)
	local mover = {}
	mover.prime = function() return true end
	mover.ready = function() return true end
	mover.velocity = function(character)
		if not character then return nil end
		local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
		if not root then return nil end
		local ok, v = pcall(function() return root.AssemblyLinearVelocity end)
		if ok and typeof(v) == "Vector3" then return v end
		return nil
	end
	mover.onGround = function() return nil end
	mover.renderDelay = function() return 1 / 30 end
	mover.number = function(_, fallback) return fallback end
	return mover
end
end)()

_registry["services/frame"] = (function()
return function(p)
	local RunService = p("core/service").get("RunService")
	local frame, bound = {}, {}
	frame.onDraw = function(name, fn)
		frame.stop(name)
		local conn = RunService.RenderStepped:Connect(function(dt)
			local ok, err = pcall(fn, dt)
			if not ok then warn("[UILibrary] frame/" .. tostring(name) .. ": " .. tostring(err)) end
		end)
		bound[name] = conn
	end
	frame.stop = function(name)
		local c = bound[name]
		if c then pcall(function() c:Disconnect() end) bound[name] = nil end
	end
	frame.isBound = function(name) return bound[name] ~= nil end
	frame.reset = function() for n in pairs(bound) do frame.stop(n) end end
	return frame
end
end)()

_registry["core/http"] = (function()
return function()
	local r3 = function()
		local s4 = request

		if typeof(s4) ~= "function" and typeof(capture_core_http_3) == "table" then
			s4 = capture_core_http_3.request
		end

		return typeof(s4) == "function" and s4 or nil
	end

	local r2

	r2 = {
		fetch = function(s27)
			if typeof(httpget) == "function" then
				local s1, s2 = pcall(httpget, s27)
				if s1 and typeof(s2) == "string" and #s2 > 0 then
					return s2
				end
			end

			local s1_1, s2_1 = pcall(function()
				return game:HttpGet(s27, true)
			end)

			if s1_1 and typeof(s2_1) == "string" and #s2_1 > 0 then
				return s2_1
			end
			local s4 = r3
			local s2_2 = r3()

			if s2_2 then
				local s1_2, s2_3 = pcall(s2_2, { Url = s27, Method = "GET" })
				if s1_2 and typeof(s2_3) == "table" and typeof(s2_3.Body) == "string" then
					return s2_3.Body
				end
			end

			return nil
		end,
		fetchRaw = function(s16, s17)
			if typeof(s17) ~= "function" then
				return nil
			end
			local s1 = r2.fetch(s16)
			if s17(s1) then
				return s1
			end
			local s2 = r3()

			if s2 then
				local s1_1, s2_1 = pcall(s2, { Url = s16, Method = "GET" })

				if s1_1 and typeof(s2_1) == "table" then
					if s17(s2_1.Body) then
						return s2_1.Body
					end
				end
			end

			return nil
		end,
		post = function(s28, s29, s30)
			if typeof(s28) ~= "function" then
				return nil
			end
			local s2, s3 = pcall(s28, { Url = s29, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = s30 })
			if not s2 or typeof(s3) ~= "table" then
				return nil
			end
			return { status = s3.StatusCode or (s3.status_code or 0), body = s3.Body }
		end,
	}

	return r2
end
end)()

_registry["core/service"] = (function()
return function()
	local r2 = {}

	return {
		get = function(s25)
			local s1 = r2[s25]
			if s1 then
				return s1
			end
			if typeof(game) ~= "Instance" and typeof(game) ~= "table" then
				return nil
			end
			local s22, s23 = pcall(function()
				return game:GetService(s25)
			end)
			if not s22 or not s23 then
				return nil
			end

			if typeof(cloneref) == "function" then
				local s21, s22_1 = pcall(cloneref, s23)
				if s21 and s22_1 then
					s23 = s22_1
				end
			end

			r2[s25] = s23
			return s23
		end,
		same = function(s35, s36)
			if typeof(compareinstances) == "function" then
				local s33, s34 = pcall(compareinstances, s35, s36)
				if s33 then
					return s34
				end
			end

			return s35 == s36
		end,
	}
end
end)()

_registry["services/latency"] = (function()

return function(p)
				local J = p("core/service").get("Players")
				local p, O, u, F, f, o, Z, i = J and J.LocalPlayer, {}, 1, 0.25, 50, 1, 2000
				local J, y, P, b, I, h = 0, 16, {}, 0, 0
				local function A(T)
					I = I % y + 1
					P[I] = T
					T = b < y
					if T then
						b += 1
					end
					local y, I = {}, b
					for T = 1, I, 1 do
						y[T] = P[T]
					end
					table.sort(y)
					h = y[math.floor((b + 1) / 2)]
				end
				local y
				local P, I = { 0, 0, 0, 0 }, 0
				local function T(r)
					for S = 1, #P, 1 do
						if P[S] == r then
							return true
						end
					end
					return false
				end
				local function r(S)
					local c, R = i
					if c then
						local e = i
						R = e + (S - i) * F
					else
						R = c
					end
					i = R or S
					A(S)
				end
				local function F(A)
					if typeof(A) ~= "number" then
						return false
					end
					if A ~= A then
						return false
					end
					return A >= o and A <= Z
				end
				O.of = function(o)
					if not o then
						return nil
					end
					local Z = o:GetAttribute("Ping")
					if not F(Z) then
						return nil
					end
					return Z
				end
				O.ours = function()
					local o = not p
					if o then
						local Z = i or f
						return Z
					end
					o = os.clock()
					local Z = i and o - J < u
					if Z then
						local u = i
						return u
					end
					J = o
					Z = y ~= nil
					if Z then
						o = i or f
						return o
					end
					o = O.of(p)
					Z = not o or T(o)
					if Z then
						local p = i or f
						return p
					end
					r(o)
					o = i
					return o
				end
				O.observe = function(p)
					if not F(p) then
						return
					end
					r(p)
					J = os.clock()
				end
				O.declare = function(p)
					local J = typeof(p) == "number"
					if J then
						local J = I
						I = J % #P + 1
						P[I] = p
						y = p
						return
					end
					y = nil
				end
				O.declared = function()
					local p = y
					return p
				end
				O.stable = function()
					O.ours()
					local p = h or i or f
					return p
				end
				O.samples = function()
					local p = b
					return p
				end
				O.FIXED_MS = 70
				O.SOURCE_STABLE = "stable"
				O.SOURCE_LIVE = "live"
				O.SOURCE_FIXED = "fixed"
				O.SOURCE = O.SOURCE_STABLE
				O.lead = function()
					local p = O.SOURCE
					if p == O.SOURCE_FIXED then
						return O.FIXED_MS
					end
					if p == O.SOURCE_LIVE then
						return O.ours()
					end
					return O.stable()
				end
				return O
			end
end)()

_registry["services/png"] = (function()
return function()
	local r2 = {}
	local r3 = string.char
	local r5 = table.concat

	local r6 = function()
		local s5 = {}

		for s6 = 0, 255 do
			local s18 = s6

			for s1 = 1, 8 do
				if s18 % 2 == 1 then
					s18 = bit32.bxor(3988292384, bit32.rshift(s18, 1))
				else
					s18 = bit32.rshift(s18, 1)
				end
			end

			s5[s6] = s18
		end

		return s5
	end

	local r6_1 = r6(344372670)

	local r7 = function(s28)
		local s5 = 4294967295

		for s3 = 1, #s28 do
			local s4 = bit32.rshift
			s5 = bit32.bxor(r6_1[bit32.band(bit32.bxor(s5, string.byte(s28, s3)), 255)], s4(s5, 8))
		end

		return bit32.bxor(s5, 4294967295)
	end

	local r8 = function(s22)
		local s5 = 1
		local s7 = 1
		local s8 = 0

		while s5 <= #s22 do
			local s1 = math.min(s5 + 5551, #s22)

			for s23 = s5, s1 do
				s7 += string.byte(s22, s23)
				s8 += s7
			end

			s7 %= 65521
			s8 %= 65521
			s5 = s1 + 1
		end

		return s8 * 65536 + s7
	end

	local r10 = function(s22)
		local s4 = bit32.band
		local s21 = bit32.band
		return r3(bit32.band(bit32.rshift(s22, 24), 255), bit32.band(bit32.rshift(s22, 16), 255), s4(bit32.rshift(s22, 8), 255), s21(s22, 255))
	end

	local r11 = function(s17)
		local s15 = bit32.band
		return r3(bit32.band(s17, 255), s15(bit32.rshift(s17, 8), 255))
	end

	local r13 = function(s24, s25)
		return r10(#s25) .. s24 .. s25 .. r10(r7(s24 .. s25))
	end

	r2.encode = function(s36, s37, s38)
		local s800002 = 3213522740
		if typeof(s36) ~= "number" or typeof(s37) ~= "number" then
			return nil
		end

		if typeof(s38) ~= "string" then
			return nil
		end

		if not (s36 <= 0) then
			if not (s37 <= 0) then
				if #s38 ~= s36 * s37 * 4 then
					return nil
				end
				local s5 = {}
				local s6 = s36 * 4

				for s2 = 0, s37 - 1 do
					s5[#s5 + 1] = "\0"
					s5[#s5 + 1] = string.sub(s38, s2 * s6 + 1, (s2 + 1) * s6)
				end

				local s8_1 = r5(s5)
				local s1_2 = { "x\1" }
				local s9 = 1

				while s9 <= #s8_1 do
					local s2_1 = math.min(65535, #s8_1 - s9 + 1)
					local s4

					if s9 + s2_1 > #s8_1 then
						s4 = 1
					else
						s4 = 0
					end

					s1_2[#s1_2 + 1] = r3(s4)
					s1_2[#s1_2 + 1] = r11(s2_1)
					s1_2[#s1_2 + 1] = r11(bit32.band(bit32.bnot(s2_1), 65535))
					s1_2[#s1_2 + 1] = string.sub(s8_1, s9, s9 + s2_1 - 1)
					s9 += s2_1
				end

				s1_2[#s1_2 + 1] = r10(r8(s8_1))
				return "\137PNG\r\n\26\n" .. r13("IHDR", r10(s36) .. r10(s37) .. r3(8) .. r3(6) .. r3(0) .. r3(0) .. r3(0)) .. r13("IDAT", r5(s1_2)) .. r13("IEND", "")
			end
		end

		return nil
	end

	return r2
end
end)()

_registry["ui/assets"] = (function()
return function()
	local r6 = {}

	local r3 = {
		team = {
			["Counter-Terrorists"] = "rbxassetid://123313484458877",
			Terrorists = "rbxassetid://86088922816787",
		},
	}

	r3.weapon = {
		["AK-47"] = "rbxassetid://83097083839889",
		AUG = "rbxassetid://119885531832389",
		AWP = "rbxassetid://79794264811775",
		["Decoy Grenade"] = "rbxassetid://81385239843859",
		["Defuse Kit"] = "rbxassetid://116726858713748",
		["Desert Eagle"] = "rbxassetid://122477921917392",
		["Dual Berettas"] = "rbxassetid://111854065134079",
		FAMAS = "rbxassetid://125469152582044",
		["Five-SeveN"] = "rbxassetid://90570942481875",
		Flashbang = "rbxassetid://132038996524430",
		["Galil AR"] = "rbxassetid://75166557697975",
		["Glock-18"] = "rbxassetid://101406018897044",
		["HE Grenade"] = "rbxassetid://111110976385167",
		["Incendiary Grenade"] = "rbxassetid://81255981095065",
		Kevlar = "rbxassetid://77092909095947",
		["Kevlar + Helmet"] = "rbxassetid://80903717317993",
		["M4A1-S"] = "rbxassetid://113144230602399",
		M4A4 = "rbxassetid://93053662997899",
		["MAC-10"] = "rbxassetid://83671879972945",
		["MAG-7"] = "rbxassetid://86291171438206",
		MP9 = "rbxassetid://135384625641866",
		Molotov = "rbxassetid://95390644612614",
		Negev = "rbxassetid://134163874921903",
		Nova = "rbxassetid://127273982496076",
		P250 = "rbxassetid://73666032770570",
		P90 = "rbxassetid://82724138944322",
		["R8 Revolver"] = "rbxassetid://112745953600473",
		["Rescue Kit"] = "rbxassetid://116726858713748",
		["SG 553"] = "rbxassetid://133547075528778",
		["SSG 08"] = "rbxassetid://112132914334737",
		["Sawed-Off"] = "rbxassetid://117478678996500",
		["Smoke Grenade"] = "rbxassetid://137305344844339",
		["Tec-9"] = "rbxassetid://119232881698906",
		["USP-S"] = "rbxassetid://131658947857971",
		XM1014 = "rbxassetid://115344320193773",
		["Zeus x27"] = "rbxassetid://71464446190434",
	}

	r3.sound = { beep = "rbxassetid://104816011091831" }
	r6.marketplace = r3
	r6.builtin = { cursor = { "rbxasset://SystemCursors/Arrow", "rbxasset://textures/ArrowCursor.png" } }
	return r6
end
end)()

_registry["ui/backdrop"] = (function()

return function(p)
				local J = p("ui/backdrop_art")
				local O = p("core/log")
				local u = p("ui/raster")
				local F, f, o, Z = p("core/service").get("AssetService"), {}
				local p = false
				local function i(y, P)
					local b, I = buffer.create(y * P * 4), J.alpha
					local h, A, T, r = #I, 255 // (J.levels - 1), 1, 0
					while T < h do
						P, y = string.byte(I, T), string.byte(I, T + 1)
						T += 2
						if P > 0 then
							local I = 16777215 + P * A * 16777216
							for P = 1, y, 1 do
								buffer.writeu32(b, r * 4, I)
								r += 1
							end
						else
							r += y
						end
					end
					return b
				end
				local function y(P, b, I, h, A, T, r)
					for S = 0, A - 1, 1 do
						local A = r + S
						if A >= 0 and A < b then
							local r, c = S * h, A * b
							for A = 0, h - 1, 1 do
								local h = T + A
								if h >= 0 and h < b then
									local b = buffer.readu8(I, (r + A) * 4 + 3)
									if b > 0 then
										local I = (c + h) * 4
										local h = b + buffer.readu8(P, I + 3) * (255 - b) // 255
										h = if h > 255 then 255 else h
										buffer.writeu8(P, I, 255)
										buffer.writeu8(P, I + 1, 255)
										buffer.writeu8(P, I + 2, 255)
										buffer.writeu8(P, I + 3, h)
									end
								end
							end
						end
					end
				end
				local function P(b, I)
					local h, A = pcall(function()
						local T, r = i(b, I), J.tile
						local S, c = buffer.create(r * r * 4), J.blits
						for R = 1, #c, 2 do
							y(S, r, T, b, I, c[R], c[R + 1])
						end
						return u.image(S, r, r, "backdrop")
					end)
					return h and A or nil
				end
				f.content = function()
					local y = p
					if y then
						local b = Z
						return b
					end
					p = true
					local b = J.sprite[1]
					local I = J.sprite[2]
					y = u.supported()
					if y then
						local u, h = pcall(function()
							local A = F:CreateEditableImage({ Size = Vector2.new(b, I) })
							A:WritePixelsBuffer(Vector2.zero, Vector2.new(b, I), i(b, I))
							o = F:CreateEditableImage({ Size = Vector2.new(J.tile, J.tile) })
							local F = J.blits
							local i = #F
							for T = 1, i, 2 do
								local i = o
								i:DrawImage(Vector2.new(F[T], F[T + 1]), A, Enum.ImageCombineType.AlphaBlend)
							end
							pcall(function()
								A:Destroy()
							end)
							Z = Content.fromObject(o)
						end)
						local F = not u or not Z
						if F then
							O.warn("backdrop", "needs EditableImage: %s", tostring(h))
							o, Z = nil, nil
						end
						h = Z
						return h
					end
					Z = P(b, I)
					y = Z
					return y
				end
				f.tileSize = function()
					return J.tile
				end
				f.reset = function()
					o, Z, p = nil, nil, false
				end
				return f
			end
end)()

_registry["ui/backdrop_art"] = (function()
return function()
	return {
		tile = 840,
		sprite = { 335, 198 },
		levels = 8,
		blits = {
			-167,
			-99,
			-167,
			741,
			673,
			-99,
			673,
			741,
			-143,
			-51,
			-143,
			789,
			697,
			-51,
			697,
			789,
			-119,
			-3,
			-119,
			837,
			721,
			-3,
			721,
			837,
			-95,
			45,
			745,
			45,
			-71,
			93,
			769,
			93,
			-47,
			141,
			793,
			141,
			-23,
			189,
			817,
			189,
			1,
			237,
			25,
			285,
			49,
			333,
			73,
			381,
			97,
			429,
			121,
			477,
			145,
			525,
			169,
			573,
			193,
			621,
			217,
			-171,
			217,
			669,
			241,
			-123,
			241,
			717,
			265,
			-75,
			265,
			765,
			289,
			-27,
			289,
			813,
			313,
			21,
			337,
			69,
			361,
			117,
			385,
			165,
			409,
			213,
			433,
			261,
			457,
			309,
			481,
			357,
			505,
			405,
			-311,
			453,
			529,
			453,
			-287,
			501,
			553,
			501,
			-263,
			549,
			577,
			549,
			-239,
			597,
			601,
			597,
			-215,
			-195,
			-215,
			645,
			625,
			-195,
			625,
			645,
			-191,
			-147,
			-191,
			693,
			649,
			-147,
			649,
			693,
		},
		alpha = "\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\25\1\1\4\1\6\1\4\1\0\255\0J\2\1\5\1\7\4\1\1\0\255\0G\1\1\4\1\7\6\4\1\0\255\0F\1\1\6\1\7\8\1\1\0\255\0D\1\1\6\1\7\7\5\1\4\1\1\1\0\255\0D\4\1\7\6\5\1\1\1\0\255\0F\1\1\7\6\4\1\0\255\0H\2\1\7\6\1\1\0\3\1\1\2\1\0\255\0C\2\1\7\6\2\1\0\1\1\1\3\1\7\2\0\255\0C\1\1\7\6\5\1\3\1\6\1\7\3\3\1\0\255\0C\6\1\7\12\1\1\0\255\0B\3\1\7\12\2\1\0\255\0005\2\1\5\1\1\1\0\n\1\1\7\n\4\1\1\1\0\255\0004\2\1\5\1\7\2\4\1\0\8\1\1\3\1\6\1\7\8\4\1\1\1\0\255\0004\2\1\5\1\7\5\1\1\0\5\1\1\0\1\2\1\7\n\3\1\0\255\0005\6\1\7\6\4\1\0\3\1\1\3\1\6\1\4\1\0\1\5\1\7\t\6\1\0\255\0005\3\1\7\7\1\1\0\1\3\1\6\1\7\3\1\2\7\n\3\1\0\255\0005\6\1\7\6\5\1\6\1\7\5\4\1\0\1\5\1\4\1\1\1\3\1\7\6\6\1\0\255\0005\3\1\7\r\6\1\0\4\1\1\7\7\3\1\0\255\0005\6\1\7\11\4\1\1\1\0\5\4\1\7\6\6\1\0\255\0005\5\1\7\t\4\1\1\1\0\7\1\1\7\7\3\1\0\255\0002\3\1\6\1\7\8\6\1\1\1\0\n\4\1\7\6\6\1\0\255\0/\1\1\2\1\0\1\4\1\7\t\6\1\1\1\0\n\1\1\7\7\3\1\0\255\0-\3\1\6\2\0\2\6\1\7\t\4\1\0\11\4\1\7\6\6\1\0\255\0+\3\1\6\1\7\2\6\1\1\1\0\1\3\1\7\2\5\1\7\7\1\1\0\n\1\1\7\7\3\1\0\255\0(\2\1\6\1\7\5\1\1\0\1\1\1\4\1\1\1\0\1\6\1\7\6\4\1\0\11\4\1\7\6\6\1\0\255\0(\2\1\7\6\2\1\0\5\3\1\7\7\1\1\0\n\1\1\7\7\3\1\0\255\0'\1\1\7\6\3\1\0\6\6\1\7\6\4\1\0\11\4\1\7\7\1\1\0\255\0'\6\1\7\5\4\1\0\6\3\1\7\7\1\1\0\n\1\1\7\6\5\1\1\1\0\255\0\30\3\1\6\1\1\1\0\6\4\1\7\5\5\1\0\7\6\1\7\6\4\1\0\5\3\1\4\1\0\4\4\1\7\3\5\1\2\1\0\255\0\30\3\1\6\1\7\2\6\1\1\1\0\5\3\1\7\5\6\1\0\7\3\1\7\7\2\1\0\3\3\1\7\2\1\1\0\3\1\1\7\1\5\1\2\1\0\255\0\30\2\1\6\1\7\5\6\1\1\1\0\4\1\1\7\6\1\1\0\7\6\1\7\7\3\2\5\1\7\3\4\1\0\4\1\1\0\255\0 \4\1\7\7\6\1\0\5\6\1\7\5\2\1\0\7\3\1\7\14\1\1\0\255\0$\3\1\7\8\5\1\0\4\5\1\7\5\3\1\0\8\6\1\7\12\6\1\1\1\0\255\0$\2\1\7\t\5\1\0\3\3\1\7\5\4\1\0\8\2\1\7\11\4\1\0\255\0\30\3\2\0\6\1\1\7\n\5\1\0\2\2\1\7\5\5\1\0\t\4\1\7\8\6\1\2\1\0\255\0\29\3\1\6\1\7\2\2\1\0\6\6\1\7\n\4\1\0\1\1\1\7\5\6\1\0\n\4\1\7\5\5\1\2\1\0\255\0\28\1\1\3\1\6\1\7\5\1\1\0\5\5\1\7\3\6\1\2\1\7\6\4\1\0\1\5\1\7\5\1\1\0\n\1\1\2\1\3\1\2\1\1\1\0\255\0\30\5\1\7\7\6\1\1\1\0\4\4\1\7\4\1\1\2\1\7\6\3\2\7\5\2\1\0\255\0\24\3\2\0\19\1\1\6\1\7\7\5\1\0\4\3\1\7\4\2\1\0\1\3\1\7\6\5\1\7\5\3\1\0\255\0\22\3\1\6\1\7\2\1\1\0\19\1\1\7\8\4\1\0\3\2\1\7\4\3\1\0\2\3\1\7\11\4\1\0\255\0\20\3\1\6\1\7\4\4\1\0\20\2\1\7\8\3\1\0\2\1\1\7\4\5\1\0\3\4\1\7\n\5\1\0\255\0\19\2\1\7\7\1\1\0\20\2\1\7\8\3\1\0\2\6\1\7\3\6\1\0\4\4\1\7\t\6\1\0\255\0\20\6\1\7\6\4\1\0\21\2\1\7\8\2\1\0\1\5\1\7\4\1\1\0\4\4\1\7\t\1\1\0\255\0\19\3\1\7\7\1\1\0\21\2\1\7\8\1\1\4\1\7\4\1\1\0\5\4\1\7\6\5\1\2\1\0\255\0\21\6\1\7\6\4\1\0\22\3\1\7\7\5\1\3\1\7\4\2\1\0\6\5\1\7\3\5\1\2\1\0\255\0\23\3\1\7\7\1\1\0\22\3\1\7\12\4\1\0\7\5\1\6\1\2\1\0\255\0\26\6\1\7\6\4\1\0\23\3\1\7\11\5\1\0\255\0$\3\1\7\7\1\1\0\23\3\1\7\n\6\1\0\255\0%\6\1\7\6\4\1\0\24\4\1\7\n\1\1\0\255\0$\3\1\7\7\1\1\0\24\4\1\7\t\2\1\0\255\0%\6\1\7\6\4\1\0\25\4\1\7\6\5\1\2\1\0\255\0&\3\1\7\7\1\1\0\r\2\1\1\1\0\n\4\1\7\3\5\1\2\1\0\255\0)\6\1\7\6\4\1\0\11\2\1\5\1\7\1\5\1\0\11\5\1\6\1\2\1\0\255\0\28\1\1\3\1\5\1\6\1\7\1\6\2\3\1\0\7\3\1\7\7\1\1\0\8\2\1\5\1\7\4\1\1\0\255\0'\2\1\5\1\7\8\5\1\0\7\6\1\7\6\4\1\0\7\5\1\7\6\5\1\0\255\0%\2\1\5\1\7\11\5\1\0\6\3\1\7\7\1\1\0\6\4\1\7\7\1\1\0\255\0\"\1\1\4\1\7\14\3\1\0\6\6\1\7\6\4\1\0\6\1\1\7\7\5\1\0\255\0!\2\1\6\1\7\15\6\1\0\6\3\1\7\7\1\1\0\6\4\1\7\7\1\1\0\255\0\31\4\1\7\7\6\1\5\1\4\1\5\1\7\7\3\1\0\6\6\1\7\6\4\1\0\6\1\1\7\5\6\1\2\1\0\255\0\31\5\1\7\6\6\1\3\1\1\1\0\3\4\1\7\6\6\1\0\6\3\1\7\7\1\1\0\6\4\1\7\2\6\1\2\1\0\255\0!\6\1\7\5\3\1\0\6\4\1\7\7\3\1\0\6\6\1\7\6\4\1\0\6\1\1\5\1\2\1\0\255\0#\2\1\7\3\6\1\1\1\0\5\2\1\6\1\7\8\6\1\0\6\3\1\7\7\1\1\0\255\0#\1\1\2\1\3\2\0\5\5\1\7\1\6\1\1\1\0\4\1\1\5\1\7\11\3\1\0\6\6\1\7\6\4\1\0\255\0 \1\1\4\1\6\1\7\4\2\1\0\4\2\1\6\1\1\1\0\4\3\1\6\1\7\12\6\1\0\6\3\1\7\7\1\1\0\255\0\29\1\1\5\1\7\7\6\1\0\n\4\1\7\6\4\1\1\1\7\7\3\1\0\6\6\1\7\4\6\1\2\1\0\255\0\29\4\1\7\n\2\1\0\8\5\1\7\5\6\1\2\1\0\2\4\1\7\6\6\1\0\6\3\1\7\2\6\1\2\1\0\255\0\29\1\1\5\1\7\11\6\1\0\7\4\1\7\5\5\1\0\4\1\1\7\7\3\1\0\6\5\1\2\1\0\255\0\31\6\1\7\8\6\1\5\3\6\1\1\1\0\5\2\1\7\5\5\1\0\6\3\1\7\6\6\1\0\255\0&\5\1\7\6\6\1\3\1\1\1\0\11\5\1\7\5\2\1\0\6\4\1\7\7\3\1\0\255\0$\3\1\7\6\5\1\0\r\1\1\7\6\2\1\0\5\3\1\7\8\5\1\0\255\0$\6\1\7\5\5\1\0\14\1\1\7\6\5\1\0\4\3\1\7\7\6\1\2\1\0\255\0\30\2\1\1\1\0\4\2\1\7\6\2\1\0\14\1\1\7\7\5\1\3\2\6\1\7\3\4\1\3\1\7\1\6\1\2\1\0\255\0\30\3\1\6\1\7\1\1\1\0\4\4\1\7\6\1\1\0\15\5\1\7\r\1\2\2\1\0\255\0\30\3\1\6\1\7\3\2\1\0\4\5\1\7\5\6\1\0\16\2\1\7\12\3\1\0\255\0\31\1\1\6\1\7\5\2\1\0\4\5\1\7\6\1\1\0\12\2\1\0\3\5\1\7\n\4\1\0\255\0 \1\1\7\6\3\1\0\4\5\1\7\6\3\1\0\11\3\1\7\1\2\1\0\2\1\1\6\1\7\8\3\1\0\255\0\"\6\1\7\5\3\1\0\4\3\1\7\6\5\1\0\11\6\1\7\1\5\1\0\4\4\1\6\1\7\4\5\1\1\1\0\255\0#\5\1\7\5\4\1\0\4\2\1\7\7\2\1\0\t\5\1\7\3\2\1\0\5\2\3\1\1\0\255\0%\4\1\7\5\4\1\0\5\6\1\7\6\6\1\1\1\0\6\1\1\5\1\7\4\5\1\0\255\0#\2\1\6\2\1\1\0\7\3\1\7\5\5\1\0\5\3\1\7\7\6\1\2\1\0\3\1\1\3\1\6\1\7\6\1\1\0\255\0 \2\1\6\1\7\3\6\1\1\1\0\6\3\1\7\5\5\1\0\6\6\1\7\8\6\1\5\2\7\8\3\1\0\255\0\31\3\1\6\1\7\6\6\1\1\1\0\5\2\1\7\5\6\1\0\6\2\1\7\18\3\1\0\255\0\12\1\1\0\19\4\1\7\t\2\1\0\4\1\1\7\5\6\1\0\7\4\1\7\15\6\1\2\1\0\255\0\11\2\1\6\2\0\20\3\1\7\t\2\1\0\4\7\5\6\1\0\8\4\1\7\r\5\1\1\1\0\255\0\n\2\1\5\1\7\3\3\1\0\20\2\1\7\t\2\1\0\3\6\1\7\5\1\1\0\8\2\1\6\1\7\t\5\1\2\1\0\255\0\n\1\1\5\1\7\5\6\1\0\8\1\1\4\1\5\1\6\2\4\1\1\1\0\6\2\1\6\1\7\8\3\1\0\2\5\1\7\5\1\1\0\n\3\1\5\1\6\4\4\1\3\1\1\1\0\255\0\12\1\1\7\7\3\1\0\5\1\1\4\1\7\7\3\1\0\6\1\1\6\1\7\8\3\1\0\1\5\1\7\5\2\1\0\255\0 \4\1\7\6\6\1\0\4\1\1\6\1\7\t\3\1\0\6\1\1\6\1\7\8\3\2\7\5\2\1\0\255\0 \1\1\7\7\3\1\0\2\1\1\6\1\7\11\2\1\0\7\5\1\7\8\6\1\7\5\3\1\0\255\0!\4\1\7\6\6\1\0\2\5\1\7\12\5\1\0\8\4\1\7\r\3\1\0\255\0!\1\1\7\7\2\2\7\14\2\1\0\8\4\1\7\12\4\1\0\255\0\"\4\1\7\6\6\2\7\5\6\2\7\7\6\1\0\t\3\1\7\11\4\1\0\255\0\21\1\1\4\2\0\n\1\1\7\11\4\1\1\1\0\2\5\1\7\7\2\1\0\t\3\1\7\n\5\1\0\255\0\19\1\1\4\1\6\1\7\2\1\1\0\n\4\1\7\t\2\1\0\5\6\1\7\6\6\1\0\n\2\1\7\t\5\1\0\255\0\17\1\1\4\1\7\5\4\1\0\6\1\1\0\3\1\1\7\8\2\1\0\6\2\1\7\7\2\1\0\n\1\1\6\1\7\7\6\1\0\255\0\17\3\1\7\7\1\1\0\3\2\1\6\1\7\1\1\1\0\3\4\1\7\6\6\1\0\8\5\1\7\6\6\1\0\11\1\1\6\1\7\6\6\1\0\255\0\18\6\1\7\6\4\1\0\1\2\1\5\1\7\3\4\1\0\3\1\1\7\7\3\1\0\7\2\1\7\7\2\1\0\11\1\1\6\1\7\6\1\1\0\255\0\17\3\1\7\7\6\1\7\6\1\1\0\3\4\1\7\6\6\1\0\8\5\1\7\6\6\1\0\12\4\1\7\6\1\1\0\255\0\18\6\1\7\r\3\1\0\3\1\1\7\7\3\1\0\7\2\1\7\7\2\1\0\11\4\1\7\6\1\1\0\255\0\18\3\1\7\11\5\1\2\1\0\5\4\1\7\6\6\1\0\8\5\1\7\6\6\1\0\11\3\1\7\6\2\1\0\255\0\18\2\1\7\t\5\1\2\1\0\7\1\1\7\7\3\1\0\7\2\1\7\7\2\1\0\n\3\1\7\6\2\1\0\255\0\16\1\1\6\1\7\t\2\1\0\n\4\1\7\6\6\1\0\8\5\1\7\6\6\1\0\n\2\1\7\6\3\1\0\255\0\16\1\1\7\n\4\1\0\n\1\1\7\7\3\1\0\7\2\1\7\5\6\1\3\1\0\n\2\1\7\5\4\1\1\1\0\255\0\17\4\1\7\n\1\1\0\n\4\1\7\6\6\1\0\8\5\1\7\2\6\1\3\1\0\12\1\1\7\3\4\1\1\1\0\255\0\19\1\1\7\2\5\1\6\1\7\6\4\1\0\n\1\1\7\7\3\1\0\7\2\1\6\1\3\1\0\14\1\1\7\1\4\1\1\1\0\255\0\11\1\1\2\3\1\1\0\6\3\1\2\1\0\1\3\1\7\7\1\1\0\n\4\1\7\6\6\1\0\25\1\1\0\255\0\n\1\1\4\1\6\1\7\5\6\1\3\1\0\8\6\1\7\6\4\1\0\n\1\1\7\7\3\1\0\255\0!\1\1\4\1\7\n\6\1\2\1\0\6\3\1\7\7\1\1\0\n\4\1\7\6\6\1\0\255\0 \3\1\7\14\3\1\0\6\6\1\7\6\4\1\0\n\1\1\7\6\6\1\1\1\0\255\0\30\4\1\7\16\2\1\0\5\3\1\7\7\1\1\0\4\1\1\5\1\1\1\0\3\4\1\7\3\6\1\3\1\0\255\0\31\4\1\7\17\6\1\1\1\0\5\6\1\7\6\5\1\0\3\1\1\6\1\7\1\4\1\0\3\1\1\7\1\6\1\3\1\0\255\0 \2\1\7\6\5\1\2\1\1\2\3\1\7\8\4\1\0\5\3\1\7\7\5\1\3\1\4\1\7\4\1\1\0\3\2\1\0\255\0\"\6\1\7\5\4\1\0\5\1\1\7\8\1\1\0\5\6\1\7\r\4\1\0\255\0%\3\1\7\5\6\1\0\7\2\1\7\7\4\1\0\5\3\1\7\r\3\1\0\255\0\30\2\1\5\1\2\1\0\4\5\1\7\5\4\1\0\8\5\1\7\6\6\1\0\6\6\1\7\n\6\1\2\1\0\255\0\30\4\1\7\2\5\1\0\4\6\1\7\5\4\1\0\8\1\1\7\7\1\1\0\5\1\1\6\1\7\7\6\1\3\1\0\255\0\31\5\1\7\4\2\1\0\3\6\1\7\5\5\1\0\t\5\1\7\6\2\1\0\6\1\1\5\1\7\4\6\1\3\1\1\1\0\255\0\28\1\1\0\2\4\1\7\5\5\1\0\3\6\1\7\5\6\1\0\t\2\1\7\6\3\1\0\8\1\1\2\2\1\1\0\255\0\29\2\1\5\1\6\1\0\1\2\1\7\7\2\1\0\2\5\1\7\6\3\1\0\8\1\1\7\6\2\1\0\255\0'\2\1\5\1\7\3\2\1\5\1\7\7\5\1\0\2\4\1\7\6\6\1\0\8\1\1\7\6\2\1\0\255\0%\1\1\5\1\7\5\6\1\7\6\5\1\3\1\1\1\0\2\2\1\7\7\3\1\0\7\2\1\7\5\6\1\0\255\0&\2\1\7\11\5\1\2\1\0\6\6\1\7\7\1\1\0\6\5\1\7\5\4\1\0\255\0'\4\1\7\t\3\1\0\8\3\1\7\7\6\1\2\1\0\3\1\1\5\1\7\6\1\1\0\255\0 \2\1\0\6\1\1\7\7\6\1\2\1\0\n\6\1\7\8\5\1\4\1\5\1\7\7\3\1\0\255\0\31\2\1\5\1\7\1\3\1\0\6\5\1\7\6\6\1\0\11\2\1\7\17\4\1\0\255\0\30\2\1\5\1\7\3\6\1\0\6\1\1\7\7\2\1\0\11\3\1\7\15\3\1\0\255\0\30\5\1\7\6\3\1\0\6\5\1\7\6\6\1\0\12\3\1\7\12\5\1\1\1\0\255\0\31\5\1\7\6\6\1\0\6\1\1\7\7\2\1\0\12\1\1\5\1\7\8\5\1\2\1\0\255\0!\1\1\7\7\3\1\0\6\5\1\7\6\6\1\0\14\1\1\3\1\5\3\4\1\3\1\1\1\0\255\0$\4\1\7\6\6\1\0\6\1\1\7\7\2\1\0\255\0/\2\1\5\1\4\1\0\7\1\1\7\7\3\1\0\6\5\1\7\6\6\1\0\255\0-\2\1\5\1\7\3\1\1\0\7\4\1\7\6\6\1\0\6\1\1\7\7\2\1\0\255\0*\2\1\5\1\7\5\4\1\0\7\1\1\7\7\3\1\0\6\5\1\7\6\6\1\0\255\0*\4\1\7\7\1\1\0\7\4\1\7\6\6\1\0\6\1\1\7\7\2\1\0\255\0)\1\1\7\7\4\1\0\7\1\1\7\7\3\1\0\6\5\1\7\6\5\1\0\255\0*\4\1\7\7\1\1\0\7\4\1\7\6\6\1\0\6\1\1\7\7\3\1\0\255\0)\1\1\7\7\4\1\0\7\1\1\7\7\3\1\0\6\5\1\7\5\6\1\3\1\0\255\0\29\2\1\3\1\4\3\2\1\0\7\4\1\7\7\1\1\0\7\4\1\7\6\6\1\0\6\1\1\7\3\6\1\3\1\0\255\0\28\1\1\4\1\6\1\7\6\6\1\2\1\0\5\1\1\7\7\4\1\0\7\1\1\7\7\3\1\0\6\5\1\7\1\3\1\0\255\0\29\4\1\7\11\4\1\0\5\4\1\7\7\1\1\0\7\4\1\7\6\6\1\0\6\1\2\0\255\0\28\1\1\6\1\7\r\3\1\0\4\1\1\7\7\4\1\0\6\1\1\6\1\7\7\3\1\0\255\0\18\1\1\4\1\6\1\0\r\2\1\6\1\7\15\2\1\0\4\4\1\7\7\1\1\0\4\1\1\6\1\7\8\6\1\0\255\0\16\1\1\4\1\7\3\3\1\0\11\1\1\6\1\7\5\5\1\3\1\2\1\4\1\7\7\6\1\0\4\1\1\7\7\6\1\1\1\0\2\2\1\6\1\7\8\6\1\3\1\0\255\0\15\4\1\7\5\6\1\0\11\5\1\7\4\6\1\2\1\0\4\3\1\7\7\3\1\0\4\4\1\7\8\5\1\6\1\7\5\5\1\7\2\6\1\3\1\1\1\0\255\0\16\6\1\7\6\3\1\0\t\2\1\7\5\2\1\0\6\4\1\7\6\6\1\1\1\0\3\1\1\7\14\4\1\1\1\6\1\3\1\1\1\0\255\0\18\3\1\7\6\6\1\0\t\5\1\7\4\4\1\0\5\1\1\4\1\6\1\7\6\6\1\1\1\0\4\4\1\7\12\6\1\1\1\0\255\0\23\6\1\7\6\3\1\0\7\1\1\7\5\3\1\0\3\1\1\4\1\7\7\6\1\3\1\0\7\6\1\7\11\2\1\0\255\0\24\3\1\7\6\6\1\0\7\2\1\7\5\4\1\0\1\1\1\4\1\7\7\6\1\3\1\0\t\2\1\7\n\3\1\0\255\0\r\1\1\3\1\2\1\0\n\6\1\7\6\3\1\0\6\2\1\7\5\6\1\4\1\7\7\6\1\3\1\0\5\3\2\0\5\2\1\6\1\7\6\6\1\2\1\0\255\0\12\1\1\4\1\7\3\4\1\1\1\0\8\3\1\7\6\6\1\0\6\2\1\7\12\6\1\3\1\0\6\1\1\7\1\6\1\0\6\1\1\4\1\5\1\6\2\4\1\2\1\0\255\0\12\1\1\4\1\7\6\6\1\3\1\0\8\6\1\7\6\3\1\0\5\1\1\7\n\6\1\3\1\0\8\6\1\7\2\3\1\0\255\0\22\1\1\4\1\7\n\5\1\2\1\0\6\3\1\7\6\6\1\0\6\6\1\7\7\6\1\3\1\0\t\5\1\7\3\6\1\0\255\0\22\5\1\7\r\4\1\1\1\0\5\6\1\7\6\3\1\0\5\4\1\7\6\6\1\0\t\1\1\6\1\7\5\3\1\0\255\0\21\1\1\7\14\6\1\3\1\0\4\3\1\7\6\6\1\0\5\2\1\7\7\4\1\0\6\1\1\3\1\7\6\6\1\1\1\0\255\0\22\5\1\7\15\5\1\2\1\0\3\6\1\7\6\3\1\0\5\5\1\7\7\5\1\2\1\1\2\2\1\4\1\6\1\7\6\6\1\1\1\0\255\0\23\1\1\7\17\4\1\1\1\0\1\3\1\7\6\6\1\0\5\1\1\7\19\6\1\1\1\0\255\0\25\5\1\7\17\6\1\3\1\0\1\6\1\7\6\3\1\0\5\3\1\7\17\4\1\0\255\0\27\1\1\7\7\4\1\6\1\7\n\5\1\4\1\7\6\6\1\0\6\4\1\7\14\6\1\2\1\0\255\0\29\5\1\7\6\4\1\1\1\5\1\7\18\3\1\0\6\3\1\7\11\6\1\2\1\0\255\0\31\1\1\7\7\1\1\0\1\2\1\6\1\7\16\6\1\0\7\1\1\4\1\6\1\7\5\6\1\4\1\2\1\0\255\0\"\5\1\7\6\4\1\0\3\4\1\7\16\3\1\0\t\1\1\2\3\1\1\0\255\0%\1\1\7\7\1\1\0\3\1\1\5\1\7\14\6\1\0\255\0004\5\1\7\6\4\1\0\5\3\1\6\1\7\r\3\1\0\255\0003\1\1\7\7\1\1\0\5\1\1\4\1\7\12\6\1\0\255\0004\5\1\7\6\4\1\0\7\2\1\6\1\7\11\3\1\0\255\0003\1\1\7\7\1\1\0\8\3\1\7\n\6\1\0\255\0004\5\1\7\6\4\1\0\t\1\1\5\1\7\7\4\1\1\1\0\255\0004\1\1\7\7\1\1\0\n\3\1\6\1\7\3\4\1\1\1\0\255\0007\5\1\7\6\4\1\0\11\1\1\4\2\1\1\0\255\0009\2\1\7\7\1\1\0\255\0H\5\1\7\6\4\1\0\255\0H\2\1\7\7\1\1\0\255\0H\5\1\7\6\4\1\0\255\0H\2\1\7\7\1\1\0\255\0H\5\1\7\5\4\1\1\1\0\255\0H\2\1\7\3\4\1\1\1\0\255\0K\5\1\4\1\1\1\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\255\0\156",
	}
end
end)()

_registry["ui/checker"] = (function()

return function(p)
				local J, O, u = p("ui/raster"), { CELL = 5, LIGHT = 16777215, DARK = 13027014 }
				O.content = function()
					local p = u ~= nil
					if p then
						local F = u or nil
						return F
					end
					p = O.CELL * 2
					local F = buffer.create(p * p * 4)
					for f = 0, p - 1, 1 do
						for o = 0, p - 1, 1 do
							local Z = o < O.CELL ~= (f < O.CELL) and O.DARK or O.LIGHT
							buffer.writeu32(F, (f * p + o) * 4, Z + 4278190080)
						end
					end
					u = J.image(F, p, p, "checker") or false
					p = u or nil
					return p
				end
				O.paint = function(p)
					local J = O.content()
					if not J then
						return false
					end
					p.Image = ""
					p.ImageContent = J
					p.ScaleType = Enum.ScaleType.Tile
					p.TileSize = UDim2.fromOffset(O.CELL * 2, O.CELL * 2)
					return true
				end
				return O
			end
end)()

_registry["ui/chrome/account"] = (function()

local Runtime = { [14] = table.pack }
function Runtime:oh(values) return table.unpack(values, 1, values.n) end
function Runtime:Wh(destination, offset, ...)
    local values = table.pack(...)
    table.move(values, 1, values.n, offset + 1, destination)
end
function Runtime:Lh(destination, offset, values)
    table.move(values, 1, values.n, offset + 1, destination)
    destination.n = offset + values.n
end

local p = Runtime

return function(J)
				local O = J("ui/create")
				local u = J("ui/connect")
				local F = J("ui/icon")
				local f = J("ui/chrome/linkdot")
				local o = J("ui/motion")
				local Z = J("ui/skin")
				local i = J("ui/theme")
				local y = J("ui/font")
				local P, b, I, h, A =
					J("ui/zindex"),
					{
						ROW_HEIGHT = 20,
						FACE = 20,
						GAP = 6,
						TEXT_SIZE = 13,
						TICK_SLOW = 20,
						TICK_FAST = 5,
						HOUR = 3600,
						NAME_ROLE = "text",
						DOT_ROLE = "hint",
						LOW_ROLE = "danger",
						SWITCH = 14,
					}
				local J, T, r, S, c, R, e = false
				b.human = function(G)
					if G == 1 / 0 then
						return "lifetime"
					end
					if G <= 0 then
						return "expired"
					end
					local q, w, H = G // 86400, G % 86400 // b.HOUR, G % b.HOUR // 60
					if q > 0 then
						return ("%dd %dh left"):format(q, w)
					end
					if w > 0 then
						return ("%dh %dm left"):format(w, H)
					end
					G = p[14](math.max(1, H))
					return ("%dm left"):format(p:oh(G))
				end
				b.repaint = function()
					local p = not I or not A
					if p then
						return
					end
					local G, q = A.remaining(), tostring(A.username() or "")
					S.Text = q
					p = c
					p.Text = b.human(G)
					local w, H = A.avatar(), T
					if H then
						T.Image = w or ""
						p = r
						if p then
							local p = r
							p.Visible = w == nil
						end
					end
					w = r
					if w then
						H = r
						H.Text = string.sub(q ~= "" and q or "?", 1, 1):upper()
					end
					q = G < b.HOUR
					if q then
						i.unfollow(c)
						Z.paint(c, b.LOW_ROLE)
					else
						Z.unpaint(c)
						i.follow(c, "TextColor3")
					end
				end
				b.attach = function(p, G)
					local q = I or not p or not G
					if q then
						local w = I
						return w
					end
					A = G
					I = O.new(
						"Frame",
						{
							Name = "Account",
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.fromScale(1, 1),
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.fromOffset(0, b.ROW_HEIGHT),
							BackgroundTransparency = 1,
							ZIndex = P.WINDOW + 1,
							Parent = p,
						}
					)
					G, p =
						O.new,
						{
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}
					p.Padding, p.Parent = UDim.new(0, b.GAP), I
					G("UIListLayout", p)
					p = A.avatar()
					T = i.follow(
						O.new(
							"ImageLabel",
							{
								Name = "Face",
								LayoutOrder = 1,
								Size = UDim2.fromOffset(b.FACE, b.FACE),
								BackgroundColor3 = i.get(),
								BorderSizePixel = 0,
								Image = p or "",
								ZIndex = P.WINDOW + 1,
								Parent = I,
							}
						),
						"BackgroundColor3"
					)
					G, q = O.new, {}
					q.CornerRadius, q.Parent = UDim.new(0.5, 0), T
					G("UICorner", q)
					R = f.mount(T, P.WINDOW + 3, "surface", b.FACE, e)
					r = O.new(
						"TextLabel",
						{
							Name = "Monogram",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Text = tostring(A.username() or "?"):sub(1, 1):upper(),
							TextSize = b.TEXT_SIZE - 2,
							TextColor3 = Color3.new(1, 1, 1),
							FontFace = y.face(),
							Visible = p == nil,
							ZIndex = P.WINDOW + 2,
							Parent = T,
						}
					)
					local function p(w, H, Q)
						local Y, E =
							O.new,
							{
								Name = "Line" .. w,
								LayoutOrder = w,
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.fromOffset(0, b.ROW_HEIGHT),
								BackgroundTransparency = 1,
								Text = Q,
								TextSize = b.TEXT_SIZE,
								skin = H,
								FontFace = y.face(),
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = P.WINDOW + 1,
								Parent = I,
							}
						return Y("TextLabel", E)
					end
					S = p(2, b.NAME_ROLE, "")
					p(3, b.DOT_ROLE, "\194\183")
					c = p(4, b.NAME_ROLE, "")
					h = O.new(
						"ImageButton",
						{
							Name = "Theme",
							LayoutOrder = 5,
							Size = UDim2.fromOffset(b.SWITCH, b.SWITCH),
							BackgroundTransparency = 1,
							skin = "dim",
							ZIndex = P.WINDOW + 1,
							Parent = I,
						}
					)
					b.paintSwitch()
					u.signal(h.Activated, function()
						Z.toggle()
						b.paintSwitch()
					end, "account/theme")
					u.signal(h.MouseEnter, function()
						local p, O, y, P = o.to, h, o.HOVER_IN, {}
						P.ImageColor3 = i.get()
						p(O, y, P)
					end, "account/themein")
					u.signal(h.MouseLeave, function()
						local p, O, u, i = o.to, h, o.HOVER_OUT, {}
						i.ImageColor3 = Z.get("dim")
						p(O, u, i)
					end, "account/themeout")
					b.repaint()
					q = not J and typeof(A.subscribe) == "function"
					if q then
						J = true
						A.subscribe(b.repaint)
					end
					task.spawn(function()
						while true do
							local p = I and I.Parent
							if not p then
								break
							end
							task.wait(A.remaining() < b.HOUR and b.TICK_FAST or b.TICK_SLOW)
							p = not I or not I.Parent
							if p then
								break
							end
							b.repaint()
						end
					end)
					G = I
					return G
				end
				b.paintSwitch = function()
					local p = h
					if not p then
						return
					end
					p = F.get(Z.mode == "dark" and "sun" or "moon")
					if p then
						h.ImageContent = p
					end
				end
				b.setLink = function(p)
					e = p
					f.paint(R, p)
					return b
				end
				b.reset = function()
					I, A, J, h, T, r, S, c, R = nil, nil, false, nil, nil, nil, nil, nil, nil
				end
				return b
			end
end)()

_registry["ui/chrome/aurora"] = (function()

return function(p)
				local J = p("ui/create")
				local O = p("ui/chrome/reveal")
				local u = p("ui/theme")
				local F, f, o =
					p("ui/zindex"),
					{ RISE = { 70, 150, 260 }, BASE = { 0.9, 0.945, 0.975 }, PERIOD = 7, DEPTH = 0.03, enabled = false },
					{}
				f.attach = function(p, Z)
					local i = #o > 0 or not p
					if i then
						return f
					end
					local y, P = ipairs, f.RISE
					for b, I in y(P) do
						i = f.BASE[b] or 0.97
						local y, P, h =
							u.follow(
								J.new(
									"Frame",
									{
										Name = "Aurora" .. b,
										AnchorPoint = Vector2.new(0, 1),
										Position = UDim2.new(0, 0, 1, -Z),
										Size = UDim2.new(1, 0, 0, I),
										BackgroundColor3 = u.get(),
										BackgroundTransparency = i,
										BorderSizePixel = 0,
										Visible = false,
										ZIndex = F.WINDOW,
										Parent = p,
									}
								),
								"BackgroundColor3"
							),
							J.new,
							{ Rotation = 90 }
						h.Transparency, h.Parent =
							NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 0),
							}),
							y
						P("UIGradient", h)
						o[b] = { frame = y, base = i }
					end
					return f
				end
				f.setEnabled = function(p)
					f.enabled = p and true or false
					p = o
					for J, J in ipairs(p) do
						J.frame.Visible = f.enabled
					end
					return f
				end
				f.onRender = function()
					local p = not f.enabled or #o == 0
					if p then
						return
					end
					local J, u, F =
						f.DEPTH * (0.5 + 0.5 * math.sin(os.clock() * (6.283 / f.PERIOD))), O.amount(), o
					for O, O in ipairs(F) do
						p = math.clamp(O.base - J, 0, 1)
						O.frame.BackgroundTransparency = p + (1 - p) * u
					end
				end
				f.reset = function()
					o = {}
					f.enabled = false
				end
				return f
			end
end)()

_registry["ui/chrome/beam"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u, F, f =
					p("ui/theme"),
					{ RISE = { 10, 18, 28 }, SPREAD = { 6, 20, 44 }, BASE = { 0.62, 0.8, 0.9 } }
				local p, o = {}
				local Z = false
				F.attach = function(i)
					local y = f or not i
					if y then
						return F
					end
					f = i
					y, i = ipairs, F.RISE
					for P, b in y(i) do
						local i, y, I =
							u.follow(
								O.new(
									"Frame",
									{
										Name = "Beam" .. P,
										AnchorPoint = Vector2.new(0.5, 1),
										Position = UDim2.new(0, 0, 1, 0),
										Size = UDim2.fromOffset(0, b),
										BackgroundColor3 = u.get(),
										BackgroundTransparency = F.BASE[P] or 0.9,
										BorderSizePixel = 0,
										Visible = false,
										ZIndex = f.ZIndex,
										Parent = f,
									}
								),
								"BackgroundColor3"
							),
							O.new,
							{ Rotation = 90 }
						I.Transparency, I.Parent =
							NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 0),
							}),
							i
						y("UIGradient", I)
						p[P] = i
					end
					return F
				end
				F.follow = function(O)
					o = O
					O = o and not Z
					if O then
						Z = true
						J.signal(o:GetPropertyChangedSignal("Position"), F.sync, "beam/move")
						J.signal(o:GetPropertyChangedSignal("Size"), F.sync, "beam/size")
					end
					F.sync()
					return F
				end
				F.sync = function()
					local J = f
					if not J then
						return
					end
					J = not o
					if J then
						local O = p
						for u, u in ipairs(O) do
							u.Visible = false
						end
						return
					end
					J = o.Size.X.Offset
					local O = J <= 0
					if O then
						local O = p
						for u, u in ipairs(O) do
							u.Visible = false
						end
						return
					end
					local O, u = o.Position.X.Offset + J / 2, p
					for i, y in ipairs(u) do
						y.Visible = true
						y.Position = UDim2.new(0, O, 1, 0)
						y.Size = UDim2.fromOffset(J + (F.SPREAD[i] or 0), F.RISE[i])
					end
				end
				F.reset = function()
					f, p, o, Z = nil, {}, nil, false
				end
				return F
			end
end)()

_registry["ui/chrome/bubbles"] = (function()

return function(p)
				local J = p("ui/create")
				local O = p("ui/chrome/reveal")
				local u = p("ui/theme")
				local F, f, o, Z, i =
					p("ui/zindex"),
					{
						COUNT = 128,
						SIZE_MIN = 3,
						SIZE_MAX = 17,
						RISE_MIN = 70,
						RISE_MAX = 195,
						LIFE_MIN = 1.6,
						LIFE_MAX = 6,
						FADE = 0.55,
						HOLLOW = 0.35,
						WOBBLE = 7,
						SPAWN_DEPTH = 6,
						FADE_IN = 10,
						enabled = false,
					}
				local p = {}
				local function y()
					local P, b = i.AbsolutePosition, o.AbsolutePosition
					return P - b
				end
				local function P(b, I, h, A)
					local T, r, S = math.random(f.SIZE_MIN, f.SIZE_MAX), 0.7 + math.random() * 0.7, u.get()
					b.born = I + math.random() * 1.6
					b.life = f.LIFE_MIN + math.random() * (f.LIFE_MAX - f.LIFE_MIN)
					b.rise = f.RISE_MIN + math.random() * (f.RISE_MAX - f.RISE_MIN)
					b.speed = 1.4 + math.random() * 2.4
					b.phase = math.random() * 6.283
					b.column = math.random()
					b.hollow = math.random() < f.HOLLOW
					h, A = h or (y()), A or i.AbsoluteSize.X
					b.originX = h.X + b.column * A
					b.originY = h.Y + f.SPAWN_DEPTH
					b.frame.Size = UDim2.fromOffset(T, math.max(2, math.floor(T * r)))
					b.half = T / 2
					b.corner.CornerRadius = UDim.new(0.35 + math.random() * 0.15, 0)
					b.frame.Rotation = math.random(0, 179)
					b.frame.BackgroundColor3 = S
					b.stroke.Color = S
					b.stroke.Enabled = b.hollow
					b.frame.BackgroundTransparency = 1
					b.frame.Visible = false
					b.lit = false
				end
				local b
				local function I(h)
					local A = b
					if A == h then
						return
					end
					b = h
					o.Visible = h
					o.Parent = h and Z or nil
				end
				f.attach = function(h, A)
					local T = o or not h or not A
					if T then
						local r = o
						return r
					end
					i, Z = A, h
					o, b =
						J.new(
							"Frame",
							{
								Name = "BubbleField",
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Visible = false,
								ZIndex = F.BUBBLE,
							}
						),
						false
					A, T = os.clock(), f.COUNT
					for r = 1, T, 1 do
						r = J.new(
							"Frame",
							{
								Name = "Bubble",
								BackgroundColor3 = u.get(),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Visible = false,
								ZIndex = F.BUBBLE,
								Parent = o,
							}
						)
						h = {
							frame = r,
							corner = J.new("UICorner", { Parent = r }),
							stroke = J.new("UIStroke", { Thickness = 1, Enabled = false, Parent = r }),
						}
						P(h, A)
						table.insert(p, h)
					end
					T = o
					return T
				end
				f.setEnabled = function(J)
					f.enabled = J and true or false
					J = o and not f.enabled
					if J then
						I(false)
					end
					return f
				end
				f.onRender = function(J)
					local u = not o or not i
					if u then
						return
					end
					if not f.enabled then
						I(false)
						return
					end
					u = b == true
					I(J)
					if not J then
						return
					end
					if not u then
						return
					end
					local F, I, h, A, T = os.clock(), y(), i.AbsoluteSize.X, O.amount(), p
					for O, y in ipairs(T) do
						O = (F - y.born) / y.life
						if O >= 1 then
							P(y, F, I, h)
							O = 0
						else
						end
						if O <= 0 then
							y.originX = I.X + y.column * h
							y.originY = I.Y + f.SPAWN_DEPTH
							if y.lit then
								y.lit = false
								y.frame.Visible = false
							end
						else
							if not y.lit then
								y.lit = true
								y.frame.Visible = true
							end
							u = y.rise * O
							local P, I =
								math.min(u / f.FADE_IN, (1 - O) / 0.45, 1),
								math.sin(F * y.speed + y.phase) * f.WOBBLE
							y.frame.Position = UDim2.fromOffset(y.originX + I - y.half, y.originY - u)
							J = 1 - P * (1 - f.FADE)
							J += (1 - J) * A
							if y.hollow then
								y.stroke.Transparency = J
							else
								y.frame.BackgroundTransparency = J
							end
						end
					end
				end
				f.reset = function()
					o, Z, i, p, b = nil, nil, nil, {}, nil
					f.enabled = false
				end
				return f
			end
end)()

_registry["ui/chrome/cursor"] = (function()

return function(p)
				local J = p("ui/chrome/cursor_art")
				local O = p("ui/assets")
				local u = p("ui/create")
				local F = p("ui/icon")
				local f = p("ui/zindex")
				local o = p("core/service")
				local p = o.get("Players")
				local Z = o.get("UserInputService")
				local o, i = { mode = "image", fillColor = Color3.new(1, 1, 1), outlineColor = Color3.new() }
				local y, P = {}
				local b = false
				local function I()
					local h = p.LocalPlayer
					if not h then
						return nil
					end
					local p, A = pcall(function()
						return h:GetMouse()
					end)
					return p and A or nil
				end
				local function p()
					local h = I()
					if not h then
						return
					end
					local A = P == nil
					if A then
						P = h.Icon
					end
					for A, A in ipairs(O.builtin.cursor) do
						if pcall(function()
							h.Icon = A
						end) and h.Icon == A then
							return
						end
					end
				end
				local function O()
					local h = P
					if h == nil then
						return
					end
					local h = I()
					if h then
						pcall(function()
							h.Icon = P
						end)
					end
					P = nil
				end
				local function P(I, h, A, T, r)
					local S = u.new(
						"ImageLabel",
						{
							Name = h,
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 1),
							ImageColor3 = T,
							ZIndex = f.TOP + r,
							Parent = I,
						}
					)
					local I = F.fromAlpha(A, J.size)
					if I then
						pcall(function()
							S.ImageContent = I
						end)
					end
					return S
				end
				local function F(I)
					local h = i and i.Parent
					if h then
						local h = i
						return h
					end
					i = u.new(
						"Frame",
						{
							Name = "Pointer",
							BackgroundTransparency = 1,
							Size = UDim2.fromOffset(J.size, J.size),
							Visible = false,
							ZIndex = f.TOP,
							Parent = I,
						}
					)
					y.outline = P(i, "Outline", J.outline, o.outlineColor, 0)
					y.fill = P(i, "Fill", J.fill, o.fillColor, 1)
					I = i
					return I
				end
				local u, f
				local function P(I)
					local h = i
					if not h then
						return
					end
					local A, T = I.X - J.hotspot.X, I.Y - J.hotspot.Y
					I = A == u and T == f
					if I then
						return
					end
					u, f = A, T
					h = i
					h.Position = UDim2.fromOffset(A, T)
				end
				o.needsEngineIcon = function()
					return o.mode ~= "image"
				end
				o.repaint = function()
					if y.fill then
						y.fill.ImageColor3 = o.fillColor
					end
					if y.outline then
						y.outline.ImageColor3 = o.outlineColor
					end
				end
				o.setImage = function(J, u)
					if y.fill and J then
						pcall(function()
							y.fill.ImageContent = J
						end)
					end
					if y.outline and u then
						pcall(function()
							y.outline.ImageContent = u
						end)
					end
				end
				o.attach = function(J)
					local u = b
					if u then
						return
					end
					b = true
					if o.mode ~= "image" then
						return
					end
					F(J)
				end
				o.onRender = function()
					if o.mode ~= "image" then
						return
					end
					local J = not i or not i.Visible
					if J then
						return
					end
					P(Z:GetMouseLocation())
				end
				o.setVisible = function(J)
					local u = o.mode == "system"
					if u then
						if J then
							p()
						else
							O()
						end
					else
						local p = o.mode == "image" and i
						if p then
							i.Visible = J
							if J then
								P(Z:GetMouseLocation())
							end
						end
					end
				end
				o.restore = function()
					O()
					local p = i
					if p then
						i.Visible = false
					end
					b = false
				end
				return o
			end
end)()

_registry["ui/chrome/cursor_art"] = (function()
return function()
	return {
		size = 24,
		hotspot = Vector2.new(5,2),
		outline = "\0005\18\1+\1\0\22\30\1\237\0017\1\0\21\30\1\253\1\240\1F\1\0\20\30\1\245\1M\1\240\1X\1\0\19\30\1\245\1\0\1?\1\239\1q\1\0\18\30\1\245\1\0\2,\1\229\1\136\1\0\17\30\1\245\1\0\3\"\1\219\1\148\1\2\1\0\15\30\1\245\1\0\4\24\1\208\1\166\1\5\1\0\14\30\1\245\1\0\5\17\1\196\1\188\1\r\1\0\r\30\1\245\1\0\6\n\1\182\1\202\1\20\1\0\12\30\1\245\1\0\7\4\1\158\1\213\1\28\1\0\11\30\1\245\1\0\8\1\1\141\1\224\1&\1\0\n\30\1\245\1\0\n~\1\233\0012\1\0\t\30\1\245\1\0\7C\1[\1p\1\133\1\228\1\241\1@\1\0\8\30\1\245\1\0\2\5\1T\1\0\3\184\1\226\1\164\1\143\1z\1b\1E\1\0\8\30\1\245\1\3\1^\1\221\1\253\1I\1\0\2M\1\217\1\0\r\30\1\251\1\214\2U\1k\1\203\1\1\1\0\1\4\1\251\1\18\1\0\12\30\1\222\1^\1\3\1\0\1\6\1\223\1b\1\0\1E\1\236\1\4\1\0\12\6\2\0\4<\1\236\1\225\1\242\1P\1\0\20\n\0014\1\12\1\0009",
		fill = "\0f\2\1\4\1\0\22\n\1\178\1\t\1\0\21\n\1\255\1\192\1\15\1\0\20\n\1\255\2\211\1\26\1\0\19\n\1\255\3\222\1$\1\0\18\n\1\255\4\231\1/\1\0\17\n\1\255\5\239\1<\1\0\16\n\1\255\6\245\1J\1\0\15\n\1\255\7\251\1a\1\0\14\n\1\255\8\254\1s\1\0\r\n\1\255\n\136\1\0\12\n\1\255\4\253\1\240\1\233\1\188\1\165\1\144\1{\1\28\1\0\11\n\1\255\2\250\1\184\1\255\3G\1\0\15\n\1\253\1\170\1%\1\0\1\183\1\255\2\178\1\0\15\4\1*\1\0\0034\1\254\1\255\1\251\1\4\1\0\20\150\1\255\1\186\1\0\22\24\1\1\1\0Q",
	}
end
end)()

_registry["ui/chrome/edge"] = (function()

return function(p)
				local J = p("ui/create")
				local O = p("core/service")
				local p = O.get("GuiService")
				local u, F, f, o =
					O.get("UserInputService"), { LIT = 0, DARK = 0.85, DEAD_ZONE = 24, enabled = false }
				local O = 0
				local function Z()
					local i, y = u:GetMouseLocation(), p:GetGuiInset()
					return Vector2.new(i.X - y.X, i.Y - y.Y)
				end
				F.attach = function(p, u)
					local i = o or not p or not u
					if i then
						return F
					end
					f = p
					o = J.new(
						"UIGradient",
						{
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, F.LIT),
								NumberSequenceKeypoint.new(1, F.DARK),
							}),
							Parent = u,
						}
					)
					return F
				end
				F.setEnabled = function(p)
					F.enabled = p and true or false
					p = o
					if not p then
						return F
					end
					p = not F.enabled
					if p then
						local p = o
						p.Transparency = NumberSequence.new(0)
					else
						local p = o
						p.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, F.LIT),
							NumberSequenceKeypoint.new(1, F.DARK),
						})
					end
					return F
				end
				F.onRender = function(p)
					local J = not F.enabled or not o or not f
					if J then
						return
					end
					if not p then
						return
					end
					J = f.AbsoluteSize
					if J.X <= 0 then
						return
					end
					p = f.AbsolutePosition + J / 2
					J = Z() - p
					if J.Magnitude < F.DEAD_ZONE then
						return
					end
					O = math.deg(math.atan2(J.Y, J.X)) + 180
					o.Rotation = O
				end
				F.reset = function()
					f, o, O = nil, nil, 0
					F.enabled = false
				end
				return F
			end
end)()

_registry["ui/chrome/footer"] = (function()

return function(p)
				local J = p("ui/create")
				local O = p("ui/theme")
				local u = p("ui/zindex")
				local p
				p = {
					HEIGHT = 30,
					INSET = 6,
					RULE_FADE = 0.7,
					BACKGROUND = "footer",
					BACKGROUND_FADE = 0.25,
					frame = nil,
					rule = nil,
					attach = function(F)
						if p.frame or not F then
							return p.frame
						end
						p.frame = J.new(
							"Frame",
							{
								Name = "Footer",
								Position = UDim2.new(0, p.INSET, 1, -(p.HEIGHT + 2)),
								Size = UDim2.new(1, -2 * p.INSET, 0, p.HEIGHT),
								skin = p.BACKGROUND,
								BackgroundTransparency = p.BACKGROUND_FADE,
								BorderSizePixel = 0,
								ZIndex = u.WINDOW + 1,
								Parent = F,
							}
						)
						p.rule = O.follow(
							J.new(
								"Frame",
								{
									Name = "Rule",
									Size = UDim2.new(1, 0, 0, 1),
									BackgroundColor3 = O.get(),
									BackgroundTransparency = p.RULE_FADE,
									BorderSizePixel = 0,
									ZIndex = u.WINDOW + 1,
									Parent = p.frame,
								}
							),
							"BackgroundColor3"
						)
						return p.frame
					end,
					reset = function()
						p.frame = nil
						p.rule = nil
					end,
				}
				return p
			end
end)()

_registry["ui/chrome/keybinds"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/icon")
				local F = p("ui/shadow")
				local f = p("ui/skin")
				local o = p("ui/theme")
				local Z = p("ui/font")
				local i = p("ui/zindex")
				local y, P, b, I, h, A, T =
					p("core/service").get("UserInputService"),
					{
						WIDTH = 230,
						PAD_X = 11,
						PAD_TOP = 8,
						PAD_BOTTOM = 8,
						TITLE = 19,
						TITLE_LINE = 23,
						TITLE_ICON = 18,
						TITLE_GAP = 6,
						RULE = 1,
						RULE_GAP = 6,
						BODY_GAP = 7,
						RADIUS = 6,
						ROW_H = 18,
						ROW_GAP = 3,
						KEY_W = 46,
						KEY_TEXT = 14,
						GAP = 8,
						MODE_W = 44,
						NAME_TEXT = 14,
						MODE_TEXT = 11,
						RULE_DARK = 0.5,
						BACKDROP_FADE = 0.12,
						STROKE_FADE = 0.4,
						HEADING = "hotkeys",
						EMPTY = "no keybinds",
						REFRESH = 4,
						DEFAULT_X = 12,
						DEFAULT_Y = 260,
						MODE_SHORT = { hold = "hold", toggle = "toggle", always = "always" },
						enabled = false,
					}
				local p, r, S = {}, 0, 0
				local function c()
					local R, e, G = o.get(), Color3.new(), P.RULE_DARK
					return R:Lerp(e, G)
				end
				local function R(e)
					local G, q = math.max(1, e), r
					return q + G * P.ROW_H + (G - 1) * P.ROW_GAP + P.PAD_BOTTOM
				end
				local function e(G, q)
					q = tostring(q or "")
					if G.Text ~= q then
						G.Text = q
					end
				end
				local function G(q)
					local w = O.new(
						"Frame",
						{
							Name = "Bind",
							Position = UDim2.fromOffset(P.PAD_X, q),
							Size = UDim2.new(1, -P.PAD_X * 2, 0, P.ROW_H),
							BackgroundTransparency = 1,
							Visible = false,
							ZIndex = i.TOP + 1,
							Parent = b,
						}
					)
					return {
						frame = w,
						key = O.new(
							"TextLabel",
							{
								Name = "Key",
								Size = UDim2.new(0, P.KEY_W, 1, 0),
								BackgroundTransparency = 1,
								Text = "",
								TextSize = P.KEY_TEXT,
								FontFace = Z.face(),
								skin = "text",
								TextXAlignment = Enum.TextXAlignment.Left,
								TextTruncate = Enum.TextTruncate.AtEnd,
								ZIndex = i.TOP + 1,
								Parent = w,
							}
						),
						name = O.new(
							"TextLabel",
							{
								Name = "Name",
								Position = UDim2.fromOffset(P.KEY_W + P.GAP, 0),
								Size = UDim2.new(1, -(P.KEY_W + P.GAP + P.MODE_W), 1, 0),
								BackgroundTransparency = 1,
								Text = "",
								TextSize = P.NAME_TEXT,
								FontFace = Z.face(),
								skin = "text",
								TextXAlignment = Enum.TextXAlignment.Left,
								TextTruncate = Enum.TextTruncate.AtEnd,
								ZIndex = i.TOP + 1,
								Parent = w,
							}
						),
						mode = O.new(
							"TextLabel",
							{
								Name = "Mode",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, 0, 0.5, 0),
								Size = UDim2.fromOffset(P.MODE_W, P.ROW_H),
								BackgroundTransparency = 1,
								Text = "",
								TextSize = P.MODE_TEXT,
								FontFace = Z.face(),
								skin = "dim",
								TextXAlignment = Enum.TextXAlignment.Right,
								ZIndex = i.TOP + 1,
								Parent = w,
							}
						),
					}
				end
				local function q()
					local w, H, Q = false
					J.signal(b.InputBegan, function(Y)
						if Y.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						w = true
						local E, s = Y.Position, b.Position
						H, Q = E, s
					end, "keybinds/down")
					J.signal(b.InputEnded, function(Y)
						if Y.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						w = false
					end, "keybinds/up")
					J.signal(y.InputChanged, function(J)
						local y = w
						if not y then
							return
						end
						if J.UserInputType ~= Enum.UserInputType.MouseMovement then
							return
						end
						local y, w = J.Position - H, b
						w.Position = UDim2.fromOffset(Q.X.Offset + y.X, Q.Y.Offset + y.Y)
					end, "keybinds/move")
				end
				P.attach = function(J)
					local y = b or not J
					if y then
						return P
					end
					r = P.PAD_TOP + P.TITLE_LINE + P.RULE_GAP + P.RULE + P.BODY_GAP
					b = O.new(
						"Frame",
						{
							Name = "Keybinds",
							Position = UDim2.fromOffset(P.DEFAULT_X, P.DEFAULT_Y),
							Size = UDim2.fromOffset(P.WIDTH, R(1)),
							BackgroundTransparency = P.BACKDROP_FADE,
							BorderSizePixel = 0,
							Visible = false,
							skin = "window",
							ZIndex = i.TOP,
							Parent = J,
						}
					)
					y, J = O.new, {}
					J.CornerRadius, J.Parent = UDim.new(0, P.RADIUS), b
					y("UICorner", J)
					O.new(
						"UIStroke",
						{ Color = Color3.new(), Thickness = 1, Transparency = P.STROKE_FADE, Parent = b }
					)
					F.attach(b, i.TOP)
					J = u.get("keyboard")
					y = J and P.TITLE_ICON + P.TITLE_GAP or 0
					if J then
						h = o.follow(
							O.new(
								"ImageLabel",
								{
									Name = "Glyph",
									AnchorPoint = Vector2.new(0, 0.5),
									Position = UDim2.fromOffset(P.PAD_X, P.PAD_TOP + P.TITLE_LINE // 2),
									Size = UDim2.fromOffset(P.TITLE_ICON, P.TITLE_ICON),
									BackgroundTransparency = 1,
									ImageContent = J,
									ImageColor3 = o.get(),
									ZIndex = i.TOP + 1,
									Parent = b,
								}
							),
							"ImageColor3"
						)
					end
					I = o.follow(
						O.new(
							"TextLabel",
							{
								Name = "Title",
								Position = UDim2.fromOffset(P.PAD_X + y, P.PAD_TOP),
								Size = UDim2.new(1, -(P.PAD_X * 2 + y), 0, P.TITLE_LINE),
								BackgroundTransparency = 1,
								Text = P.HEADING,
								TextSize = P.TITLE,
								TextColor3 = o.get(),
								FontFace = Z.face(),
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = i.TOP + 1,
								Parent = b,
							}
						),
						"TextColor3"
					)
					A = O.new(
						"Frame",
						{
							Name = "Rule",
							Position = UDim2.fromOffset(P.PAD_X, P.PAD_TOP + P.TITLE_LINE + P.RULE_GAP),
							Size = UDim2.new(1, -P.PAD_X * 2, 0, P.RULE),
							BackgroundColor3 = c(),
							BorderSizePixel = 0,
							ZIndex = i.TOP + 1,
							Parent = b,
						}
					)
					T = O.new(
						"TextLabel",
						{
							Name = "Empty",
							Position = UDim2.fromOffset(P.PAD_X, r),
							Size = UDim2.new(1, -P.PAD_X * 2, 0, P.ROW_H),
							BackgroundTransparency = 1,
							Text = P.EMPTY,
							TextSize = P.NAME_TEXT,
							FontFace = Z.face(),
							skin = "dim",
							Visible = false,
							ZIndex = i.TOP + 1,
							Parent = b,
						}
					)
					q()
					o.onChange(function()
						local J = A
						if J then
							local J = A
							J.BackgroundColor3 = c()
						end
					end)
					return P
				end
				P.setEnabled = function(J)
					P.enabled = J and true or false
					J = b
					if J then
						local J = b
						J.Visible = P.enabled
					end
					return P
				end
				P.setRows = function(J)
					local O = b
					if not O then
						return
					end
					local u, F, Z = #J, o.get(), f.get("text")
					for f, o in ipairs(J) do
						O = p[f]
						local i = not O
						if i then
							local y = r
							O = G(y + (f - 1) * (P.ROW_H + P.ROW_GAP))
							p[f] = O
						else
						end
						e(O.key, o.key or "--")
						e(O.name, o.name)
						e(O.mode, P.MODE_SHORT[o.mode] or o.mode)
						i = o.active and F or Z
						if O.key.TextColor3 ~= i then
							O.key.TextColor3 = i
							O.name.TextColor3 = i
						end
						O.frame.Visible = true
					end
					F, Z = u + 1, #p
					for O = F, Z, 1 do
						p[O].frame.Visible = false
					end
					Z = T
					Z.Visible = u == 0
					Z = R(u)
					J = b.Size.Y.Offset ~= Z
					if J then
						u = b
						u.Size = UDim2.fromOffset(P.WIDTH, Z)
					end
				end
				P.onRender = function(J, O)
					local u = not P.enabled or not b
					if u then
						return
					end
					S += J or 0
					u = S
					if u < 1 / P.REFRESH then
						return
					end
					S = 0
					P.setRows(O())
				end
				P.position = function()
					local J = b
					if not J then
						return nil
					end
					J = { x = b.Position.X.Offset, y = b.Position.Y.Offset }
					return J
				end
				P.setPosition = function(J, O)
					local u = b
					if not u then
						return P
					end
					J, O = tonumber(J), tonumber(O)
					u = J and O
					if u then
						local u = b
						u.Position = UDim2.fromOffset(J, O)
					end
					return P
				end
				P.reset = function()
					b, I, h, A, T, p, r, S = nil, nil, nil, nil, nil, {}, 0, 0
					P.enabled = false
				end
				return P
			end
end)()

_registry["ui/chrome/linkdot"] = (function()
return function(requireModule)
	local create = requireModule("ui/create")
	local linkdot

	linkdot = {
		RATIO = 0.35,
		RING = 2,
		RING_SMALL_AT = 6,
		TONES = {
			live = Color3.fromRGB(88, 214, 141),
			connecting = Color3.fromRGB(240, 190, 90),
			stopped = Color3.fromRGB(232, 102, 102),
			unsupported = Color3.fromRGB(232, 102, 102),
		},
		mount = function(parent, zIndex, bgRole, size, status, ratio)
			if parent == nil then
				return nil
			end
			local pipSize = math.max(4, math.floor((size or 20) * (ratio or linkdot.RATIO) + 0.5))
			local ringThickness = (pipSize < linkdot.RING_SMALL_AT) and 1 or linkdot.RING
			local ringTotalSize = pipSize + ringThickness * 2

			local ring = create.new("Frame", {
				Name = "LinkRing",
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, 0, 1, 0),
				Size = UDim2.fromOffset(ringTotalSize, ringTotalSize),
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = zIndex,
				Parent = parent,
				skin = { BackgroundColor3 = bgRole or "surface" },
			})

			if ring == nil then
				return nil
			end
			create.new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = ring })

			local pip = create.new("Frame", {
				Name = "Link",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(pipSize, pipSize),
				BackgroundColor3 = linkdot.TONES.connecting,
				BorderSizePixel = 0,
				ZIndex = zIndex + 1,
				Parent = ring,
			})

			if pip == nil then
				pcall(function() ring:Destroy() end)
				create.forget()
				return nil
			end

			create.new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = pip })
			local dot = { ring = ring, pip = pip }
			linkdot.paint(dot, status)
			return dot
		end,
		paint = function(dot, status)
			if dot == nil then
				return linkdot
			end
			local tone = linkdot.TONES[status]
			dot.ring.Visible = tone ~= nil
			if tone ~= nil then
				dot.pip.BackgroundColor3 = tone
			end
			return linkdot
		end,
	}

	return linkdot
end
end)()

_registry["ui/chrome/rainbow"] = (function()

return function(p)
				local J = p("ui/create")
				local O = p("ui/chrome/reveal")
				local u, F, f =
					p("ui/theme"),
					{
						STOPS = 12,
						GLOW_HEIGHTS = { 2, 5, 9 },
						GLOW_BASE = { 0.74, 0.86, 0.93 },
						PULSE_SPEED = 2.2,
						PULSE_DEPTH = 0.12,
						SCROLL_SPEED = 0.09,
						enabled = false,
					}
				local p, o = {}, {}
				local function Z(i)
					local y = table.create(F.STOPS + 1)
					for P = 0, F.STOPS, 1 do
						y[P + 1] = ColorSequenceKeypoint.new(
							P / F.STOPS,
							Color3.fromHSV((P / F.STOPS + i) % 1, 1, 1)
						)
					end
					return ColorSequence.new(y)
				end
				local function i(y)
					local P = O.amount()
					return y + (1 - y) * P
				end
				F.attach = function(O)
					local y = f or not O
					if y then
						return F
					end
					f = O
					u.unfollow(f)
					y = f
					y.BackgroundColor3 = Color3.new(1, 1, 1)
					f.BackgroundTransparency = 0
					O = Z(0)
					table.insert(p, J.new("UIGradient", { Color = O, Parent = f }))
					local P, b = ipairs, F.GLOW_HEIGHTS
					for I, h in P(b) do
						y = F.GLOW_BASE[I] or 0.9
						local P = J.new(
							"Frame",
							{
								Name = "Glow" .. I,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.new(1, 0, 0, h),
								BackgroundColor3 = Color3.new(1, 1, 1),
								BackgroundTransparency = y,
								BorderSizePixel = 0,
								ZIndex = f.ZIndex - 1,
								Parent = f,
							}
						)
						table.insert(p, J.new("UIGradient", { Color = O, Parent = P }))
						table.insert(o, { frame = P, base = y })
					end
					return F
				end
				F.setEnabled = function(J)
					F.enabled = J and true or false
					J = f
					if not J then
						return F
					end
					J = o
					for O, O in ipairs(J) do
						O.frame.Visible = F.enabled
					end
					J = F.enabled
					if J then
						u.unfollow(f)
						local J = f
						J.BackgroundColor3 = Color3.new(1, 1, 1)
					else
						local J = p
						for O, O in ipairs(J) do
							O.Color = ColorSequence.new(Color3.new(1, 1, 1))
						end
						u.follow(f, "BackgroundColor3")
					end
					return F
				end
				F.onRender = function()
					local J = not F.enabled or not f
					if J then
						return
					end
					J = os.clock()
					local O, u, y =
						Z(J * F.SCROLL_SPEED % 1),
						F.PULSE_DEPTH * (0.5 + 0.5 * math.sin(J * F.PULSE_SPEED)),
						p
					for J, J in ipairs(y) do
						J.Color = O
					end
					O = o
					for J, J in ipairs(O) do
						J.frame.BackgroundTransparency = i(math.clamp(J.base - u, 0, 1))
					end
				end
				F.reset = function()
					f, p, o = nil, {}, {}
				end
				return F
			end
end)()

_registry["ui/chrome/reveal"] = (function()

return function(p)
				local J = p("ui/fade")
				local O, u, F =
					p("core/service").get("TweenService"),
					{ RISE = 16, SINK = 12, OPEN_TIME = 0.2, SHUT_TIME = 0.12 }
				u.onSettle = nil
				local p = {}
				u.include = function(f, o)
					if not f or typeof(o) ~= "string" then
						return
					end
					table.insert(p, { object = f, property = o })
				end
				local function f(o)
					local Z = J.snapshot(o)
					for o, o in ipairs(p) do
						if o.object.Parent then
							J.record(Z, o.object, o.property)
						end
					end
					return Z
				end
				u.faded = 0
				u.amount = function()
					return u.faded
				end
				local function p(o, Z)
					u.faded = Z
					J.apply(o, Z)
				end
				u.stop = function()
					local J = F
					if not J then
						return
					end
					local o = J
					F = nil
					p(o.shot, 0)
					o.window.Position = o.home
					o.window.Visible = o.opening
					if u.onSettle then
						u.onSettle()
					end
				end
				u.play = function(J, o)
					if not J then
						return
					end
					u.stop()
					local Z = J.Position
					local i, y =
						Z + UDim2.fromOffset(0, o and u.RISE or 0), Z + UDim2.fromOffset(0, o and 0 or u.SINK)
					J.Visible = true
					local P, b = f(J), o and 1 or 0
					J.Position = i
					p(P, b)
					F = {
						window = J,
						shot = P,
						home = Z,
						from = i,
						to = y,
						opening = o,
						started = os.clock(),
						duration = o and u.OPEN_TIME or u.SHUT_TIME,
						style = o and Enum.EasingStyle.Quint or Enum.EasingStyle.Quad,
						direction = o and Enum.EasingDirection.Out or Enum.EasingDirection.In,
					}
				end
				u.onRender = function()
					local J = F
					if not J then
						return
					end
					local f = math.clamp((os.clock() - J.started) / J.duration, 0, 1)
					local o = O:GetValue(f, J.style, J.direction)
					J.window.Position = J.from:Lerp(J.to, o)
					p(J.shot, J.opening and 1 - o or o)
					if f < 1 then
						return
					end
					f = J
					F = nil
					p(f.shot, 0)
					f.window.Position = f.home
					f.window.Visible = f.opening
					if u.onSettle then
						u.onSettle()
					end
				end
				return u
			end
end)()

_registry["ui/chrome/search"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/icon")
				local F = p("ui/metrics")
				local f = p("ui/motion")
				local o = p("ui/skin")
				local Z = p("ui/theme")
				local i = p("ui/font")
				local y = p("ui/zindex")
				local p
				p = {
					WIDTH = 170,
					HEIGHT = 24,
					ICON_X = 7,
					TEXT_X = 28,
					PLACEHOLDER = "search",
					onQuery = function(P) end,
					frame = nil,
					attach = function(P, b, I)
						if p.frame or not P then
							return p.frame
						end
						local h = y.WINDOW + 1
						p.frame = O.new(
							"Frame",
							{
								Name = "Search",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -b, 0, I),
								Size = UDim2.fromOffset(p.WIDTH, p.HEIGHT),
								skin = "field",
								BorderSizePixel = 0,
								ZIndex = h,
								Parent = P,
							}
						)
						O.new("UICorner", { CornerRadius = UDim.new(0, F.corner), Parent = p.frame })
						p.stroke =
							O.new("UIStroke", { Thickness = F.stroke, skin = "stroke", Parent = p.frame })
						P = u.size()
						p.icon = O.new(
							"ImageButton",
							{
								Name = "Glyph",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, p.ICON_X, 0.5, 0),
								Size = UDim2.fromOffset(P, P),
								BackgroundTransparency = 1,
								skin = "hint",
								ImageContent = u.get("search"),
								ZIndex = h + 1,
								Parent = p.frame,
							}
						)
						p.field = O.new(
							"TextBox",
							{
								Name = "Field",
								Position = UDim2.fromOffset(p.TEXT_X, 0),
								Size = UDim2.new(1, -p.TEXT_X - 8, 1, 0),
								BackgroundTransparency = 1,
								Text = "",
								PlaceholderText = p.PLACEHOLDER,
								TextSize = F.textSize - 1,
								skin = { TextColor3 = "body", PlaceholderColor3 = "hint" },
								FontFace = i.face(),
								TextXAlignment = Enum.TextXAlignment.Left,
								ClearTextOnFocus = false,
								ClipsDescendants = true,
								TextTruncate = Enum.TextTruncate.AtEnd,
								ZIndex = h + 1,
								Parent = p.frame,
							}
						)
						p.wire()
						return p.frame
					end,
					wire = function()
						J.signal(p.field:GetPropertyChangedSignal("Text"), function()
							p.paintIcon()
							p.onQuery(p.field.Text)
						end, "search/text")
						J.signal(p.field.Focused, function()
							p.editing = true
							local O, i, y, P = f.to, p.stroke, f.HOVER_IN, {}
							P.Color = Z.get()
							O(i, y, P)
							p.paintIcon()
						end, "search/focus")
						J.signal(p.field.FocusLost, function()
							p.editing = false
							local O, i, y, P = f.to, p.stroke, f.HOVER_OUT, {}
							P.Color = o.get("stroke")
							O(i, y, P)
							p.paintIcon()
						end, "search/blur")
						J.signal(p.frame.MouseEnter, function()
							if p.editing then
								return
							end
							local O, i, y, P = f.to, p.stroke, f.HOVER_IN, {}
							P.Color = o.get("edge")
							O(i, y, P)
						end, "search/enter")
						J.signal(p.frame.MouseLeave, function()
							if p.editing then
								return
							end
							local O, i, y, P = f.to, p.stroke, f.HOVER_OUT, {}
							P.Color = o.get("stroke")
							O(i, y, P)
						end, "search/leave")
						J.signal(p.icon.InputBegan, function(O)
							if O.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end
							if p.field.Text == "" then
								return
							end
							f.cancel(p.iconPress)
							O = u.size()
							p.iconPress = f.to(
								p.icon,
								f.PRESS,
								{ Size = UDim2.fromOffset(O * F.pressScale, O * F.pressScale) }
							)
							p.Clear()
						end, "search/clear")
						J.signal(p.icon.InputEnded, function(J)
							if J.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end
							f.cancel(p.iconPress)
							J = u.size()
							p.iconPress = f.to(p.icon, f.RELEASE, { Size = UDim2.fromOffset(J, J) })
						end, "search/clearend")
					end,
					paintIcon = function()
						local J, O, u, F, i = p.editing or p.field.Text ~= "", f.to, p.icon, f.HOVER_IN, {}
						i.ImageColor3 = J and Z.get() or o.get("hint")
						O(u, F, i)
					end,
					Clear = function()
						if not p.field then
							return
						end
						p.field.Text = ""
					end,
					Get = function()
						return p.field and p.field.Text or ""
					end,
				}
				return p
			end
end)()

_registry["ui/chrome/subtabs"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/skin")
				local u = p("ui/create")
				local F = p("ui/icon")
				local f = p("ui/motion")
				local o = p("ui/chrome/switch")
				local Z = p("ui/theme")
				local i = p("ui/font")
				local y = p("ui/zindex")
				local P = p("core/service").get("RunService")
				local p, b, I =
					{
						ROW_HEIGHT = 20,
						ICON_SIZE = 12,
						ICON_GAP = 5,
						SLOT_GAP = 16,
						TEXT_SIZE = 13,
						IDLE_ROLE = "text",
						HOVER = 0.55,
						SLIDE = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					},
					{},
					{}
				I.__index = I
				p.add = function(h, A, T)
					local r = setmetatable(
						{ tab = h, title = tostring(A or "subtab"), icon = T and tostring(T) or nil, sections = {} },
						I
					)
					h.subs = h.subs or {}
					table.insert(h.subs, r)
					if #h.subs == 1 then
						h.currentSub = r
					end
					return r
				end
				I.assign = function(h, A)
					if A then
						table.insert(h.sections, A)
					end
					return A
				end
				I.Select = function(I)
					I.tab.currentSub = I
					p.apply(I.tab)
					return I
				end
				p.paint = function(I)
					local h = Z.get()
					for A, T in ipairs(I.subs or {}) do
						if T.label then
							A = if T == I.currentSub
								then h
								else if T == I.hoveredSub
									then O.get(p.IDLE_ROLE):Lerp(h, p.HOVER)
									else O.get(p.IDLE_ROLE)
							f.to(T.label, f.HOVER_IN, { TextColor3 = A })
							if T.glyph then
								f.to(T.glyph, f.HOVER_IN, { ImageColor3 = A })
							end
						end
					end
				end
				p.apply = function(O, I)
					local h = {}
					for A, T in ipairs(O.subs or {}) do
						A = T == O.currentSub
						for r, r in ipairs(T.sections) do
							if r.main then
								if A and not r.main.Visible then
									table.insert(h, r.main)
								end
								r.main.Visible = A
							end
						end
					end
					p.paint(O)
					p.slide(O)
					if not I then
						o.play(h, false)
					end
					if typeof(O.onSub) == "function" then
						pcall(O.onSub, O.currentSub)
					end
				end
				p.slide = function(O)
					local o = O.currentSub
					local I = o and o.slot
					if not I or not O.slider or not O.bar then
						return
					end
					o = I.AbsoluteSize.X
					if o <= 0 then
						return
					end
					local h = I.AbsolutePosition.X - O.bar.AbsolutePosition.X
					f.to(
						O.slider,
						p.SLIDE,
						{ Position = UDim2.new(0, h, 1, -1), Size = UDim2.fromOffset(o, 1) }
					)
				end
				p.reapply = function()
					local O = b
					for f, f in ipairs(O) do
						p.apply(f, true)
					end
				end
				p.showFor = function(O)
					local f = b
					for o, o in ipairs(f) do
						if o.bar then
							o.bar.Visible = o == O
						end
					end
				end
				p.build = function(O, f)
					if not f or not O.subs or #O.subs == 0 then
						return false
					end
					table.insert(b, O)
					O.bar = u.new(
						"Frame",
						{
							Name = "SubTabs",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Visible = false,
							ZIndex = y.WINDOW + 1,
							Parent = f,
						}
					)
					local f, o, I =
						u.new(
							"Frame",
							{
								Name = "Row",
								Position = UDim2.new(0, 0, 1, -p.ROW_HEIGHT),
								Size = UDim2.new(1, 0, 0, p.ROW_HEIGHT),
								BackgroundTransparency = 1,
								ZIndex = y.WINDOW + 1,
								Parent = O.bar,
							}
						),
						u.new,
						{ FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder }
					I.Padding, I.Parent = UDim.new(0, p.SLOT_GAP), f
					o("UIListLayout", I)
					O.slider = Z.follow(
						u.new(
							"Frame",
							{
								Name = "Slider",
								Position = UDim2.new(0, 0, 1, -1),
								Size = UDim2.fromOffset(0, 1),
								BackgroundColor3 = Z.get(),
								BorderSizePixel = 0,
								ZIndex = y.WINDOW + 2,
								Parent = O.bar,
							}
						),
						"BackgroundColor3"
					)
					for o, Z in ipairs(O.subs) do
						p.buildSlot(O, Z, f, o)
					end
					p.apply(O, true)
					task.spawn(function()
						P.RenderStepped:Wait()
						p.slide(O)
					end)
					return true
				end
				p.buildSlot = function(O, f, o, Z)
					f.slot = u.new(
						"TextButton",
						{
							Name = "Slot",
							LayoutOrder = Z,
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.fromOffset(0, p.ROW_HEIGHT),
							BackgroundTransparency = 1,
							Text = "",
							AutoButtonColor = false,
							ZIndex = y.WINDOW + 2,
							Parent = o,
						}
					)
					o = f.icon and F.get(f.icon)
					if o then
						f.glyph = u.new(
							"ImageLabel",
							{
								Name = "Glyph",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 0, 0.5, 0),
								Size = UDim2.fromOffset(p.ICON_SIZE, p.ICON_SIZE),
								BackgroundTransparency = 1,
								skin = p.IDLE_ROLE,
								ImageContent = o,
								ZIndex = y.WINDOW + 3,
								Parent = f.slot,
							}
						)
					end
					f.label = u.new(
						"TextLabel",
						{
							Name = "Label",
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, o and p.ICON_SIZE + p.ICON_GAP or 0, 0.5, 0),
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.fromOffset(0, p.ROW_HEIGHT),
							BackgroundTransparency = 1,
							Text = f.title,
							TextSize = p.TEXT_SIZE,
							skin = p.IDLE_ROLE,
							FontFace = i.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = y.WINDOW + 3,
							Parent = f.slot,
						}
					)
					J.signal(f.slot.MouseEnter, function()
						O.hoveredSub = f
						p.paint(O)
					end, "subtab/enter")
					J.signal(f.slot.MouseLeave, function()
						if O.hoveredSub == f then
							O.hoveredSub = nil
							p.paint(O)
						end
					end, "subtab/leave")
					J.signal(f.slot.MouseButton1Click, function()
						f:Select()
					end, "subtab/click")
				end
				p.reset = function()
					local J = b
					for O, O in ipairs(J) do
						O.bar = nil
						O.slider = nil
						O.hoveredSub = nil
						for J, J in ipairs(O.subs or {}) do
							J.slot = nil
							J.label = nil
							J.glyph = nil
						end
					end
					b = {}
				end
				return p
			end
end)()

_registry["ui/chrome/switch"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/fade")
				local F = p("ui/motion")
				local p, f, o =
					{
						INFO = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						RISE = 14,
						STAGGER = 0.07,
						onSettle = nil,
					},
					setmetatable,
					{ __mode = "k" }
				local Z, i = f({}, o), {}
				local function f(o)
					local y = i[o]
					if y then
						return y
					end
					y = { value = O.new("NumberValue", { Name = "SwitchFade" .. o, Value = 0 }) }
					J.signal(y.value.Changed, function(J)
						if y.shot then
							u.apply(y.shot, J)
						end
					end, "switch/fade" .. o)
					i[o] = y
					return y
				end
				p.play = function(J, O)
					if typeof(J) ~= "table" or #J == 0 then
						return
					end
					local o = i
					for y, y in pairs(o) do
						F.cancel(y.tween)
						if y.shot and y.value.Value > 0 then
							u.apply(y.shot, 0)
						end
						y.shot = nil
					end
					for y, P in ipairs(J) do
						if P and P.Parent then
							local J, b = f(y), (y - 1) * p.STAGGER
							o = TweenInfo.new(
								p.INFO.Time,
								p.INFO.EasingStyle,
								p.INFO.EasingDirection,
								0,
								false,
								b
							)
							J.shot = u.snapshot(P)
							u.apply(J.shot, 1)
							J.value.Value = 1
							J.tween = F.to(J.value, o, { Value = 0 })
							if J.tween then
								local u, f =
									J.tween, function()
										if p.onSettle then
											p.onSettle()
										end
									end
								u.Completed:Once(f)
							end
							if O then
								b = Z[P]
								if not b then
									b = P.Position
									Z[P] = b
								else
								end
								P.Position = b + UDim2.fromOffset(0, p.RISE)
								F.to(P, o, { Position = b })
							end
						end
					end
				end
				p.reset = function()
					local J = i
					for O, O in pairs(J) do
						F.cancel(O.tween)
					end
					i = {}
					table.clear(Z)
				end
				return p
			end
end)()

_registry["ui/chrome/tilt"] = (function()

return function(p)
				local p, J, O = { MAX = 2.2, PER_SPEED = 0.0044, TAU = 0.06, enabled = false }
				local u, F = 0
				local function f(o)
					local Z = F
					if Z == o then
						return
					end
					F = o
					J.Rotation = o
				end
				p.attach = function(o)
					if not o then
						return p
					end
					J = o
					O, u, F = o.Position.X.Offset, 0, nil
					return p
				end
				p.setEnabled = function(o)
					p.enabled = o and true or false
					o = not p.enabled and J
					if o then
						u = 0
						f(0)
					end
					return p
				end
				p.onRender = function(o)
					local Z = not p.enabled or not J or not o or o <= 0
					if Z then
						return
					end
					Z = J.Position.X.Offset
					local i = (Z - (O or Z)) / o
					O = Z
					local Z, y = math.clamp(i * p.PER_SPEED, -p.MAX, p.MAX), u
					u = y + (Z - y) * (1 - math.exp(-o / p.TAU))
					f(u)
				end
				p.reset = function()
					J, O, u, F = nil, nil, 0, nil
					p.enabled = false
				end
				return p
			end
end)()

_registry["ui/chrome/watermark"] = (function()

local J = identifyexecutor

return function(p)
				local O = p("ui/create")
				local u = p("services/mover")
				local F = p("ui/icon")
				local f = p("ui/chrome/linkdot")
				local o = p("ui/shadow")
				local Z = p("ui/skin")
				local i = p("ui/theme")
				local y = p("ui/font")
				local P = p("ui/zindex")
				local b, I = p("core/service"), p("services/latency")
				local p, h, A, T, r, S, c, R, e, G, q, w, H, Q, Y =
					b.get("Players"),
					{
						HEIGHT = 36,
						PAD_X = 15,
						GAP = 12,
						MARGIN = 12,
						RADIUS = 6,
						BACKDROP_FADE = 0.12,
						STROKE_FADE = 0.4,
						BRAND_TEXT = 13,
						STAT_TEXT = 11,
						STAT_ICON = 11,
						STAT_GAP = 5,
						FACE = 16,
						LINK_RATIO = 0.26,
						FPS_W = 24,
						SPEED_W = 22,
						PING_W = 32,
						HOURS_W = 40,
						CLOCK_W = 32,
						BARS = 24,
						BAR_W = 2,
						BAR_GAP = 1,
						BAR_H = 13,
						BAR_MIN = 2,
						ALARM = 45,
						SAMPLE = 6,
						CONTENT = {
							"brand",
							"user",
							"executor",
							"speed",
							"hours",
							"graph",
							"fps",
							"ping",
							"config",
							"clock",
						},
						UNKNOWN = "--",
						enabled = false,
					}
				local b, E, s, v = {}, {}, 0
				local m, B, g, k, z, l, D = h.UNKNOWN, {}, 0, 0, 0, 0, 0
				local K = os.clock()
				local C
				local function a()
					local j = C
					if j then
						local V = C
						return V
					end
					local V
					local V, V = J, typeof(J) == "function"
					if V then
						j = J
						local J, N, W = pcall(j)
						local j = J and typeof(N) == "string" and N ~= ""
						if j then
							C = typeof(W) == "string" and W ~= "" and N .. " " .. W or N
						end
					end
					C = C or h.UNKNOWN
					V = C
					return V
				end
				local function J()
					local C = p.LocalPlayer and p.LocalPlayer.Character
					local p = u.velocity(C)
					if not p then
						return nil
					end
					return (p * Vector3.new(1, 0, 1)).Magnitude
				end
				local function p()
					return math.floor(I.ours() + 0.5)
				end
				local function u(I)
					local C = math.max(0, math.floor(I))
					local I, j = C // 3600, C % 3600 // 60
					if I > 0 then
						return string.format("%dh%02dm", I, j)
					end
					if j > 0 then
						return string.format("%dm%02ds", j, C % 60)
					end
					return string.format("%ds", C)
				end
				local function I(C, j, V)
					local N, W, U = O.new, { Name = "Stat_" .. C }, not V
					W.AutomaticSize = U and Enum.AutomaticSize.X or nil
					W.Size = UDim2.fromOffset(V and h.STAT_ICON + h.STAT_GAP + V or 0, h.HEIGHT)
					W.BackgroundTransparency = 1
					W.ZIndex = P.TOP + 1
					W.Parent = A
					local _ = N("Frame", W)
					E[C] = _
					N = F.get(j)
					if N then
						O.new(
							"ImageLabel",
							{
								Name = "Glyph",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 0, 0.5, 0),
								Size = UDim2.fromOffset(h.STAT_ICON, h.STAT_ICON),
								BackgroundTransparency = 1,
								ImageContent = N,
								skin = "dim",
								ZIndex = P.TOP + 1,
								Parent = _,
							}
						)
					end
					return (
						O.new(
							"TextLabel",
							{
								Name = "Value",
								Position = UDim2.fromOffset(h.STAT_ICON + h.STAT_GAP, 0),
								AutomaticSize = U and Enum.AutomaticSize.X or nil,
								Size = UDim2.new(0, V or 0, 1, 0),
								BackgroundTransparency = 1,
								Text = "",
								TextSize = h.STAT_TEXT,
								FontFace = y.face(),
								skin = "muted",
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = P.TOP + 1,
								Parent = _,
							}
						)
					)
				end
				local function F()
					local C = O.new(
						"Frame",
						{
							Name = "Stat_user",
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.fromOffset(0, h.HEIGHT),
							BackgroundTransparency = 1,
							ZIndex = P.TOP + 1,
							Parent = A,
						}
					)
					E.user = C
					r = i.follow(
						O.new(
							"ImageLabel",
							{
								Name = "Face",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 0, 0.5, 0),
								Size = UDim2.fromOffset(h.FACE, h.FACE),
								BackgroundColor3 = i.get(),
								BackgroundTransparency = 0,
								BorderSizePixel = 0,
								Image = "",
								ZIndex = P.TOP + 1,
								Parent = C,
							}
						),
						"BackgroundColor3"
					)
					local j, V = O.new, {}
					V.CornerRadius, V.Parent = UDim.new(0.5, 0), r
					j("UICorner", V)
					R = f.mount(r, P.TOP + 3, "window", h.FACE, e, h.LINK_RATIO)
					S = O.new(
						"TextLabel",
						{
							Name = "Monogram",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							Text = "?",
							TextSize = h.STAT_TEXT,
							FontFace = y.face(),
							TextColor3 = Color3.new(1, 1, 1),
							ZIndex = P.TOP + 2,
							Parent = r,
						}
					)
					c = O.new(
						"TextLabel",
						{
							Name = "Value",
							Position = UDim2.fromOffset(h.FACE + h.STAT_GAP, 0),
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "",
							TextSize = h.STAT_TEXT,
							FontFace = y.face(),
							skin = "muted",
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = P.TOP + 1,
							Parent = C,
						}
					)
				end
				local function C()
					local j = O.new(
						"Frame",
						{
							Name = "Spark",
							Size = UDim2.fromOffset(h.BARS * (h.BAR_W + h.BAR_GAP) - h.BAR_GAP, h.HEIGHT),
							BackgroundTransparency = 1,
							ZIndex = P.TOP + 1,
							Parent = A,
						}
					)
					E.graph = j
					local V = h.BARS
					for N = 1, V, 1 do
						local V = b
						V[N] = i.follow(
							O.new(
								"Frame",
								{
									Name = "Bar" .. N,
									AnchorPoint = Vector2.new(0, 1),
									Position = UDim2.new(
										0,
										(N - 1) * (h.BAR_W + h.BAR_GAP),
										0.5,
										h.BAR_H // 2
									),
									Size = UDim2.fromOffset(h.BAR_W, h.BAR_MIN),
									BackgroundColor3 = i.get(),
									BackgroundTransparency = 0.35,
									BorderSizePixel = 0,
									ZIndex = P.TOP + 1,
									Parent = j,
								}
							),
							"BackgroundColor3"
						)
					end
				end
				h.repaint = function()
					local j = not r or not v
					if j then
						return
					end
					local V, N = pcall(v.username)
					N = V and typeof(N) == "string" and N ~= "" and N or "?"
					j = c and c.Text ~= N
					if j then
						c.Text = N
					end
					j = nil
					V = typeof(v.avatar) == "function"
					if V then
						local W, U = pcall(v.avatar)
						j = W and U or nil
					else
					end
					r.Image = j or ""
					V = S
					if V then
						local V = S
						V.Visible = j == nil
						V = S
						V.Text = N:sub(1, 1):upper()
					end
				end
				h.attach = function(j, V, N)
					local W = A or not j
					if W then
						return h
					end
					v = typeof(N) == "table" and N or nil
					A = O.new(
						"Frame",
						{
							Name = "Watermark",
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -h.MARGIN, 0, h.MARGIN),
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.fromOffset(0, h.HEIGHT),
							BackgroundTransparency = h.BACKDROP_FADE,
							BorderSizePixel = 0,
							Visible = false,
							skin = "window",
							ZIndex = P.TOP,
							Parent = j,
						}
					)
					N, W = O.new, {}
					W.CornerRadius, W.Parent = UDim.new(0, h.RADIUS), A
					N("UICorner", W)
					W = O.new("UIStroke", { Thickness = 1, Transparency = h.STROKE_FADE, Parent = A })
					Z.paint(W, { Color = "border" })
					o.attach(A, P.TOP)
					j, W =
						O.new,
						{
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}
					W.Padding, W.Parent = UDim.new(0, h.GAP), A
					j("UIListLayout", W)
					O.new(
						"UIPadding",
						{ PaddingLeft = UDim.new(0, h.PAD_X), PaddingRight = UDim.new(0, h.PAD_X), Parent = A }
					)
					T = i.follow(
						O.new(
							"TextLabel",
							{
								Name = "Brand",
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.new(0, 0, 1, 0),
								BackgroundTransparency = 1,
								Text = tostring(V or "menu"),
								TextSize = h.BRAND_TEXT,
								TextColor3 = i.get(),
								FontFace = y.face(),
								ZIndex = P.TOP + 1,
								Parent = A,
							}
						),
						"TextColor3"
					)
					E.brand = T
					F()
					I("executor", "code", nil).Text = a()
					q = I("speed", "gauge", h.SPEED_W)
					H = I("hours", "timer", h.HOURS_W)
					C()
					G = I("fps", "pulse", h.FPS_W)
					w = I("ping", "signal", h.PING_W)
					Y = I("config", "gear", nil)
					Q = I("clock", "clock", h.CLOCK_W)
					Y.Text = m
					h.repaint()
					W = v and typeof(v.subscribe) == "function"
					if W then
						pcall(v.subscribe, h.repaint)
					end
					h.setContent(h.CONTENT)
					return h
				end
				h.setContent = function(O)
					local F = A
					if not F then
						return h
					end
					local F, o, y = {}, 0, typeof(O) == "table"
					if y then
						for y, P in ipairs(O) do
							P = tostring(P)
							y = E[P]
							if y and not F[P] then
								F[P] = true
								o += 1
								y.LayoutOrder = o
								y.Visible = true
							else
							end
						end
					else
					end
					O = E
					for y, P in pairs(O) do
						if not F[y] then
							P.Visible = false
						end
					end
					s = o
					F = A
					F.Visible = h.enabled and s > 0
					return h
				end
				h.setEnabled = function(O)
					h.enabled = O and true or false
					O = A
					if O then
						local O = A
						O.Visible = h.enabled and s > 0
					end
					return h
				end
				h.setLink = function(O)
					e = O
					f.paint(R, O)
					return h
				end
				h.setConfig = function(O)
					m = typeof(O) == "string" and O ~= "" and O or h.UNKNOWN
					O = Y and Y.Text ~= m
					if O then
						Y.Text = m
					end
					return h
				end
				local function O(F)
					local f, o = B, 1
					for y, y in ipairs(f) do
						o = if y > o then y else o
					end
					local y, P, I = F and Z.get("danger") or i.get(), #B, h.BARS
					for i = 1, I, 1 do
						F = b[i]
						if not F then
							break
						end
						f = i - (h.BARS - P)
						local I, e = f >= 1
						if I then
							i = B
							e = i[(g + f - 1) % P + 1]
						else
							e = I
						end
						i, I = e or nil, h.BAR_MIN
						I = if i then math.max(h.BAR_MIN, math.floor(h.BAR_H * (i / o) + 0.5)) else I
						if F.Size.Y.Offset ~= I then
							F.Size = UDim2.fromOffset(h.BAR_W, I)
						end
						if F.BackgroundColor3 ~= y then
							F.BackgroundColor3 = y
						end
					end
				end
				local function F(f, o)
					if f and f.Text ~= o then
						f.Text = o
					end
				end
				h.onRender = function(f)
					local o = not h.enabled or not A
					if o then
						return
					end
					f = f or 0
					k += 1
					z += f
					l += f
					D += f
					o = l
					if o < 1 / h.SAMPLE then
						return
					end
					l = 0
					o = z > 0 and k / z or 0
					k, z = 0, 0
					local f = g
					g = f % h.BARS + 1
					B[g] = o
					f = o < h.ALARM
					F(G, tostring(math.floor(o + 0.5)))
					o = f and Z.get("danger") or Z.get("muted")
					local Z = G.TextColor3 ~= o
					if Z then
						G.TextColor3 = o
					end
					Z = E.graph and E.graph.Visible
					if Z then
						O(f)
					end
					Z = E.speed and E.speed.Visible
					if Z then
						o = J()
						F(q, o and string.format("%d", o + 0.5) or h.UNKNOWN)
					end
					f = D >= 1
					if f then
						D = 0
						F(w, string.format("%d ms", p()))
						F(H, u(os.clock() - K))
						F(Q, os.date("%H:%M"))
					end
				end
				h.reset = function()
					A, T, r, S, c, R, G, q, w, H, Q, Y, b, B, g, E, s =
						nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, {}, {}, 0, {}, 0
					local p
					p, v = h.UNKNOWN, nil
					m, k, z, l, D = p, 0, 0, 0, 0
					K = os.clock()
					h.enabled = false
				end
				return h
			end
end)()

_registry["ui/chrome/wordmark"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/theme")
				local F, f, o, Z =
					p("core/service").get("TextService"),
					{
						WAVE_HEIGHT = 2.6,
						WAVE_SPEED = 2.4,
						WAVE_SPREAD = 0.45,
						GLOW_CORE = 2,
						GLOW_HALO = 5,
						GLOW_WAVE = 0.6,
						CORE_PEAK = 0.3,
						HALO_PEAK = 0.78,
						SHEEN_PERIOD = 5,
						SHEEN_SWEEP = 1.1,
						SHEEN_WIDTH = 2.2,
						SHEEN_REST = 1,
					},
					{}
				local p = ""
				local i = Color3.new(1, 1, 1)
				local y
				local P, b, I = 22, false, false
				local function h(A, T)
					J.thread(function()
						local J, r = pcall(Instance.new, "GetTextBoundsParams")
						if not J or not r then
							return
						end
						r.Font = T
						r.Size = P
						r.Width = 1000000
						local J, T = #o, 0
						for S = 1, J, 1 do
							r.Text = A:sub(1, S)
							local J, A = pcall(function()
								return F:GetTextBoundsAsync(r)
							end)
							if not J or typeof(A) ~= "Vector2" then
								return
							end
							o[S].x = T
							T = A.X
						end
						b, I = true, false
					end)
				end
				local function J(F, A, T, r, S)
					local c = O.new(
						"TextLabel",
						{
							AutomaticSize = Enum.AutomaticSize.XY,
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							Text = A,
							TextSize = P,
							TextColor3 = i,
							TextTransparency = S and 1 or 0,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = F.ZIndex,
							Parent = F,
						}
					)
					if T then
						pcall(function()
							c.FontFace = T
						end)
					end
					return c, (O.new("UIStroke", { Thickness = r, Transparency = 1, Parent = c }))
				end
				f.attach = function(F)
					local A = not F or #o > 0
					if A then
						return false
					end
					y = F
					A = F.Text
					if typeof(A) ~= "string" or A == "" then
						return false
					end
					p = A
					P = F.TextSize
					i = F.TextColor3:Lerp(Color3.new(), 1 - f.SHEEN_REST)
					F.Visible = false
					Z = O.new(
						"Frame",
						{
							Name = "Wordmark",
							AnchorPoint = F.AnchorPoint,
							Position = F.Position,
							Size = UDim2.fromOffset(0, 0),
							BackgroundTransparency = 1,
							ZIndex = F.ZIndex,
							Parent = F.Parent,
						}
					)
					local O, P = F.FontFace, #A
					for T = 1, P, 1 do
						F = A:sub(T, T)
						local P, r = J(Z, F, O, f.GLOW_HALO, true)
						local S, c = J(Z, F, O, f.GLOW_CORE, false)
						o[T] = { label = S, bloom = P, core = c, halo = r, x = 0 }
					end
					h(A, O)
					return true
				end
				f.recolor = function(J)
					local O = not J
					if O then
						local O = y
						if not O then
							return
						end
						J = y.TextColor3
					else
					end
					i = J:Lerp(Color3.new(), 1 - f.SHEEN_REST)
				end
				f.remeasure = function()
					local J = #o == 0 or not Z
					if J then
						return
					end
					J = o[1].label
					if not J then
						return
					end
					b, I = false, false
					h(p, J.FontFace)
				end
				f.onRender = function()
					local p = #o == 0 or not Z or not Z.Parent
					if p then
						return
					end
					p = not I
					if p then
						local J, O = o, 0
						for F, P in ipairs(J) do
							F = P.label.AbsoluteSize.X
							if F <= 0 then
								return
							end
							local J = b
							if not J then
								P.x = O
							end
							O += F
						end
						I = true
					end
					local J, O = os.clock(), u.get()
					local u, F = J % f.SHEEN_PERIOD, -f.SHEEN_WIDTH
					F = if u < f.SHEEN_SWEEP then F + u / f.SHEEN_SWEEP * (#o + f.SHEEN_WIDTH * 2) else F
					p = o
					for P, h in ipairs(p) do
						u = math.sin(J * f.WAVE_SPEED + P * f.WAVE_SPREAD)
						local p = UDim2.fromOffset(h.x, u * f.WAVE_HEIGHT)
						h.label.Position = p
						h.bloom.Position = p
						p = math.max(0, 1 - math.abs(P - F) / f.SHEEN_WIDTH)
						P = math.max((u + 1) * 0.5 * f.GLOW_WAVE, p)
						h.label.TextColor3 = i:Lerp(O, p)
						h.core.Color = O
						h.halo.Color = O
						h.core.Transparency = 1 - P * (1 - f.CORE_PEAK)
						h.halo.Transparency = 1 - P * (1 - f.HALO_PEAK)
					end
				end
				f.reset = function()
					o, Z, y, b, I = {}, nil, nil, false, false
				end
				return f
			end
end)()

_registry["ui/colorpicker"] = (function()

local Runtime = { [14] = table.pack }
function Runtime:oh(values) return table.unpack(values, 1, values.n) end
function Runtime:Wh(destination, offset, ...)
    local values = table.pack(...)
    table.move(values, 1, values.n, offset + 1, destination)
end
function Runtime:Lh(destination, offset, values)
    table.move(values, 1, values.n, offset + 1, destination)
    destination.n = offset + values.n
end

local p = Runtime

return function(J)
				local O = J("ui/checker")
				local u = J("ui/connect")
				local F = J("ui/fade")
				local f = J("ui/skin")
				local o = J("ui/create")
				local Z = J("ui/metrics")
				local i = J("ui/motion")
				local y = J("ui/popup")
				local P = J("ui/theme")
				local b = J("ui/font")
				J("ui/zindex")
				local I = J("core/service")
				local J = I.get("GuiService")
				local h = I.get("UserInputService")
				local I
				I = {
					WIDTH = 190,
					SQUARE_H = 120,
					STRIP_H = 12,
					FIELD_H = 22,
					GAP = 8,
					MODE_H = 22,
					RAIL_ROW_H = 24,
					RAIL_H = 16,
					DIAL = 24,
					MAX_MODES = 3,
					RULER_H = 12,
					RAIL_ROW_RULER_H = 30,
					HANDLE = 13,
					HANDLE_ON = 16,
					MAX_STOPS = 3,
					HANDLE_INSET = 9,
					HANDLE_DIM = 0.45,
					BLEND = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					ROW = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					GRAD_ANGLE = 90,
					DIAL_R = 7,
					DOT = 5,
					SNAP = 6,
					snapAngle = function(A)
						A %= 360
						local T = math.floor(A / 45 + 0.5) * 45
						local r = math.abs(A - T)
						if (if r > 180 then 360 - r else r) <= I.SNAP then
							return T % 360
						end
						return A
					end,
					angleFromDelta = function(A, T)
						local r = math.deg(math.atan2(T, A))
						return I.snapAngle(if r < 0 then r + 360 else r)
					end,
					heightFor = function(A, T, r)
						local S = I.SQUARE_H + I.STRIP_H * 2 + I.FIELD_H + I.GAP * 3
						if not A then
							return S
						end
						S = S + I.MODE_H + I.GAP
						return if T then S + (r and I.RAIL_ROW_RULER_H or I.RAIL_ROW_H) + I.GAP else S
					end,
					RING = 11,
					MARK_W = 4,
				}
				local A = {}
				for T = 0, 6, 1 do
					table.insert(A, ColorSequenceKeypoint.new(T / 6, Color3.fromHSV(T / 6, 1, 1)))
				end
				local T, r, S, c, R, e
				local G =
					{ h = 0, s = 1, v = 1, a = 1, slots = {}, at = 1, kind = "plain", modes = {}, mode = 1, on = false, angle = 90 }
				local function q()
					return G.slots[G.at]
				end
				local function w()
					return #G.slots >= 2
				end
				local function H()
					return #G.modes
				end
				local function Q()
					return G.modes[G.mode]
				end
				local function Y()
					return G.kind == "grad" and w()
				end
				local function E()
					local s = Q()
					return s ~= nil and s.ruler == true
				end
				local function s(v)
					local m = G.modes[v]
					if not m then
						return
					end
					G.mode = v
					G.slots = m.stops
					G.on = G.kind == "grad" and #m.stops >= 2
				end
				local v, m
				local B, g, k = false
				local function z()
					return Color3.fromHSV(G.h, G.s, G.v)
				end
				local function l(D)
					local K, C, a =
						math.floor(D.R * 255 + 0.5),
						math.floor(D.G * 255 + 0.5),
						p[14](math.floor(D.B * 255 + 0.5))
					return ("%02X%02X%02X"):format(K, C, p:oh(a))
				end
				local function p(D)
					local K = D:gsub("^%s*#?", ""):gsub("%s*$", "")
					if not K:match("^%x%x%x%x%x%x$") then
						return nil
					end
					return Color3.fromRGB(
						tonumber(K:sub(1, 2), 16),
						tonumber(K:sub(3, 4), 16),
						tonumber(K:sub(5, 6), 16)
					)
				end
				local function D()
					local K, C = h:GetMouseLocation(), J:GetGuiInset()
					return Vector2.new(K.X - C.X, K.Y - C.Y)
				end
				local function J(K)
					local C, a = K.AbsolutePosition, K.AbsoluteSize
					if a.X <= 0 or a.Y <= 0 then
						return 0, 0
					end
					K = D()
					return math.clamp((K.X - C.X) / a.X, 0, 1), math.clamp((K.Y - C.Y) / a.Y, 0, 1)
				end
				local function K()
					local C = not T or G.kind ~= "grad"
					if C then
						return
					end
					local a, j = T.dial.AbsolutePosition, T.dial.AbsoluteSize
					if j.X <= 0 or j.Y <= 0 then
						return
					end
					C = D()
					G.angle = I.angleFromDelta(C.X - (a.X + j.X * 0.5), C.Y - (a.Y + j.Y * 0.5))
				end
				I.lerpHue = function(D, C, a)
					local j = C - D
					return (D + (if j > 0.5 then j - 1 else if j < -0.5 then j + 1 else j) * a) % 1
				end
				local function D(C)
					local a = T
					if not a then
						return
					end
					a = z()
					T.square.BackgroundColor3 = Color3.fromHSV(G.h, 1, 1)
					T.alpha.BackgroundColor3 = a
					local j, V, N =
						UDim2.fromScale(G.s, 1 - G.v), UDim2.fromScale(G.h, 0), UDim2.fromScale(G.a, 0)
					if C then
						i.to(T.ring, C, { Position = j })
						i.to(T.mark, C, { Position = V })
						i.to(T.alphaMark, C, { Position = N })
					else
						T.ring.Position = j
						T.mark.Position = V
						T.alphaMark.Position = N
					end
					T.ring.BackgroundColor3 = a
					C = not T.editing
					if C then
						T.hex.Text = l(a)
					end
					if w() then
						S()
					end
				end
				local function l()
					local C = q()
					if not C then
						return
					end
					C.color, C.alpha = z(), G.a
				end
				local function q()
					local C = v
					if not C then
						return
					end
					C = G.kind == "ramp"
					if C then
						local a = Q()
						if a then
							v(a.key, G.slots)
						end
						return
					end
					C = G.slots[1] or { color = z(), alpha = G.a }
					local Q = G.modes[2] and G.modes[2].stops[2] or C
					v(
						C.color,
						C.alpha,
						G.kind == "grad" and { on = G.on, color = Q.color, alpha = Q.alpha, angle = G.angle }
							or nil
					)
				end
				e = function()
					local Q = T
					if not Q then
						return
					end
					local C, a = #G.slots, E()
					T.ruler.Visible = a
					T.railRow.Size = UDim2.new(1, 0, 0, a and I.RAIL_ROW_RULER_H or I.RAIL_ROW_H)
					if a then
						T.rail.AnchorPoint = Vector2.new(0, 0)
						T.rail.Position = UDim2.new(0, 0, 0, 0)
					else
						T.rail.AnchorPoint = Vector2.new(0, 0.5)
						T.rail.Position = UDim2.new(0, 0, 0.5, 0)
					end
					T.dial.Visible = Y()
					T.rail.Size = UDim2.new(1, Y() and -(I.DIAL + I.GAP) or 0, 0, I.RAIL_H)
					Q = I.MAX_STOPS
					for j = 1, Q, 1 do
						a = T.stops[j]
						if not a then
							break
						end
						local Q = C >= 2 and j <= C
						a.Visible = Q
						if Q then
							local Q = (j - 1) / (C - 1)
							a.Position = UDim2.new(Q, (1 - Q * 2) * I.HANDLE_INSET, 0.5, 0)
						end
					end
				end
				S = function()
					local S = not T or not w()
					if S then
						return
					end
					local Q, C, a = #G.slots, {}, {}
					for j, V in ipairs(G.slots) do
						S = (j - 1) / (Q - 1)
						table.insert(C, ColorSequenceKeypoint.new(S, V.color))
						table.insert(a, NumberSequenceKeypoint.new(S, 1 - V.alpha))
					end
					T.railRamp.Color = ColorSequence.new(C)
					T.railRamp.Transparency = NumberSequence.new(a)
					if not Y() then
						return
					end
					C = math.rad(G.angle)
					T.dot.Position = UDim2.fromOffset(
						I.DIAL * 0.5 + math.cos(C) * I.DIAL_R,
						I.DIAL * 0.5 + math.sin(C) * I.DIAL_R
					)
					T.dot.BackgroundColor3 = P.get()
				end
				c = function(P, S)
					local Q = not T or not w()
					if Q then
						return
					end
					Q = math.clamp(P or 1, 1, #G.slots)
					G.at = Q
					P = I.MAX_STOPS
					for C = 1, P, 1 do
						local a, j = T.stops[C], T.stopRings[C]
						if a and j then
							local V = C == Q
							local C, N, W, U = V and I.HANDLE_ON or I.HANDLE, i.to, i.STATE, {}
							U.Size = UDim2.fromOffset(C, C)
							N(a, W, U)
							W, C, N = i.to, i.STATE, {}
							N.Transparency = V and 0 or I.HANDLE_DIM
							W(j, C, N)
						end
					end
					P = G.slots[Q]
					if not P then
						return
					end
					local C, a, j = P.color:ToHSV()
					Q = P.alpha
					P = S or C == G.h and a == G.s and j == G.v and Q == G.a
					if P then
						g, k = nil, nil
						G.h = C
						G.s = a
						G.v = j
						G.a = Q
						D(nil)
						return
					end
					g, k = { h = G.h, s = G.s, v = G.v, a = G.a }, { h = C, s = a, v = j, a = Q }
					i.cancel(T.blendTween)
					T.blend.Value = 0
					a = T
					a.blendTween = i.to(T.blend, I.BLEND, { Value = 1 })
				end
				R = function(P, S)
					local Q = not T or G.kind == "plain"
					if Q then
						return
					end
					Q = H()
					local C = math.clamp(P or 1, 1, Q)
					s(C)
					local a, j = S or i.STATE, 1 / Q
					i.to(
						T.thumb,
						a,
						{ Position = UDim2.new((C - 1) * j, 2, 0, 2), Size = UDim2.new(j, -4, 1, -4) }
					)
					S = I.MAX_MODES
					for V = 1, S, 1 do
						P = T.modeLabels[V]
						if P then
							j, Q = i.to, {}
							Q.TextColor3 = V == C and f.get("text") or f.get("faint")
							j(P, a, Q)
						end
					end
					i.cancel(T.rowTween)
					e()
					j = w()
					if j then
						T.rowHiding = false
						T.rowFade.Value = 1
						T.railRow.Visible = true
						P = T
						P.rowTween = i.to(T.rowFade, I.ROW, { Value = 0 })
					else
						T.rowHiding = true
						Q = T
						Q.rowTween = i.to(T.rowFade, I.ROW, { Value = 1 })
					end
					j, C, Q = i.to, T.body, {}
					Q.Size = UDim2.new(1, 0, 0, I.heightFor(true, w(), E()))
					j(C, a, Q)
					c(1)
					q()
				end
				local function P(S)
					l()
					D(S)
					q()
				end
				local function S()
					local q = B
					if q then
						return
					end
					B = true
					u.signal(h.InputChanged, function(q)
						local Q = m
						if not Q then
							return
						end
						if q.UserInputType ~= Enum.UserInputType.MouseMovement then
							return
						end
						Q = m == "square"
						if Q then
							local Q, B = J(T.square)
							G.s, G.v = Q, 1 - B
						else
							q = m == "alpha"
							if q then
								G.a = J(T.alpha)
							else
								local q = m == "angle"
								if q then
									K()
								else
									G.h = J(T.strip)
								end
							end
						end
						P(nil)
					end, "picker/move")
					u.signal(h.InputEnded, function(h)
						local q = m
						if not q then
							return
						end
						if h.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						local h, q, Q, B = i.to, T.ring, i.RELEASE, {}
						B.Size = UDim2.fromOffset(I.RING, I.RING)
						h(q, Q, B)
						m = nil
					end, "picker/up")
				end
				local function h()
					local q = T
					if q then
						local Q = T
						return Q
					end
					q = y.new(nil, true)
					if not q then
						return nil
					end
					q.width = I.WIDTH
					q.frameWidth = I.WIDTH
					T = { popup = q }
					q.frame.Active = true
					local Q = q.zbase
					local B = o.new(
						"Frame",
						{
							Name = "Body",
							Size = UDim2.new(1, 0, 0, I.heightFor(false, false)),
							BackgroundTransparency = 1,
							ZIndex = Q,
							Parent = q.content,
						}
					)
					T.body = B
					local l, C = o.new, { SortOrder = Enum.SortOrder.LayoutOrder }
					C.Padding, C.Parent = UDim.new(0, I.GAP), B
					l("UIListLayout", C)
					o.new(
						"UIPadding",
						{ PaddingLeft = UDim.new(0, I.GAP), PaddingRight = UDim.new(0, I.GAP), Parent = B }
					)
					local a, j = B, T
					j.mode = o.new(
						"Frame",
						{
							Name = "Mode",
							LayoutOrder = -2,
							Size = UDim2.new(1, 0, 0, I.MODE_H),
							skin = "control",
							BorderSizePixel = 0,
							Visible = false,
							ZIndex = Q,
							Parent = a,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(0, Z.corner), Parent = T.mode })
					l = T
					l.thumb = o.new(
						"Frame",
						{
							Name = "Thumb",
							Size = UDim2.new(0.5, -2, 1, -4),
							Position = UDim2.new(0, 2, 0, 2),
							skin = "raised",
							BorderSizePixel = 0,
							ZIndex = Q + 1,
							Parent = T.mode,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(0, Z.corner - 1), Parent = T.thumb })
					C, B = o.new, { Thickness = Z.stroke, skin = "hard" }
					B.Parent = T.thumb
					C("UIStroke", B)
					T.modeLabels = {}
					j = I.MAX_MODES
					for V = 1, j, 1 do
						T.modeLabels[V] = o.new(
							"TextLabel",
							{
								Name = "Mode" .. V,
								Size = UDim2.fromScale(0.5, 1),
								BackgroundTransparency = 1,
								Text = "",
								TextSize = Z.textSize - 2,
								skin = "faint",
								FontFace = b.face(),
								Visible = false,
								ZIndex = Q + 2,
								Parent = T.mode,
							}
						)
					end
					j = T
					j.railRow = o.new(
						"Frame",
						{
							Name = "RailRow",
							LayoutOrder = -1,
							Size = UDim2.new(1, 0, 0, I.RAIL_ROW_H),
							BackgroundTransparency = 1,
							Visible = false,
							ZIndex = Q,
							Parent = a,
						}
					)
					l = T
					l.rail = o.new(
						"Frame",
						{
							Name = "Rail",
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0, 0.5, 0),
							Size = UDim2.new(1, -(I.DIAL + I.GAP), 0, I.RAIL_H),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BorderSizePixel = 0,
							ZIndex = Q,
							Parent = T.railRow,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(0, Z.corner), Parent = T.rail })
					j, C, l =
						o.new(
							"ImageLabel",
							{
								Name = "Checker",
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								ZIndex = Q - 1,
								Parent = T.rail,
							}
						),
						o.new,
						{}
					l.CornerRadius, l.Parent = UDim.new(0, Z.corner), j
					C("UICorner", l)
					O.paint(j)
					C = T
					C.railRamp = o.new("UIGradient", { Parent = T.rail })
					B = T
					B.ruler = o.new(
						"Frame",
						{
							Name = "Ruler",
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.new(0, 0, 1, 0),
							Size = UDim2.new(1, 0, 0, I.RULER_H),
							BackgroundTransparency = 1,
							Visible = false,
							ZIndex = Q,
							Parent = T.railRow,
						}
					)
					local function V(N, W, U)
						local _, x =
							o.new,
							{
								Name = "Tick" .. N,
								AnchorPoint = Vector2.new(W, 0),
								Position = UDim2.new(W, 0, 0, 0),
								Size = UDim2.fromOffset(40, I.RULER_H),
								BackgroundTransparency = 1,
								Text = N,
								TextSize = Z.textSize - 5,
								skin = "hint",
								FontFace = b.face(),
								TextXAlignment = U,
								ZIndex = Q,
								Parent = T.ruler,
							}
						return _("TextLabel", x)
					end
					V("0", 0, Enum.TextXAlignment.Left)
					V("100", 1, Enum.TextXAlignment.Right)
					local function N(W)
						local U, _, x =
							o.new(
								"Frame",
								{
									Name = W,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Size = UDim2.fromOffset(I.HANDLE, I.HANDLE),
									Visible = false,
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									ZIndex = Q + 2,
									Parent = T.rail,
								}
							),
							o.new,
							{}
						x.CornerRadius, x.Parent = UDim.new(1, 0), U
						_("UICorner", x)
						o.new(
							"UIStroke",
							{ Thickness = 1, Color = Color3.new(), Transparency = I.HANDLE_DIM, Parent = U }
						)
						_, W, x =
							o.new(
								"Frame",
								{
									Name = "Ring",
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.new(1, -2, 1, -2),
									BackgroundTransparency = 1,
									BorderSizePixel = 0,
									ZIndex = Q + 2,
									Parent = U,
								}
							),
							o.new,
							{}
						x.CornerRadius, x.Parent = UDim.new(1, 0), _
						W("UICorner", x)
						return U,
							(o.new(
								"UIStroke",
								{ Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = I.HANDLE_DIM, Parent = _ }
							))
					end
					B = T
					T.stops = {}
					B.stopRings = {}
					B = I.MAX_STOPS
					for W = 1, B, 1 do
						T.stops[W], T.stopRings[W] = N("Stop" .. W)
					end
					j = T
					j.dial = o.new(
						"Frame",
						{
							Name = "Dial",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.fromOffset(I.DIAL, I.DIAL),
							skin = "control",
							BorderSizePixel = 0,
							ZIndex = Q,
							Parent = T.railRow,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = T.dial })
					C, B = o.new, { Thickness = Z.stroke, skin = "hard" }
					B.Parent = T.dial
					C("UIStroke", B)
					l = T
					l.dot = o.new(
						"Frame",
						{
							Name = "Dot",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Size = UDim2.fromOffset(I.DOT, I.DOT),
							BorderSizePixel = 0,
							ZIndex = Q + 1,
							Parent = T.dial,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = T.dot })
					C = T
					C.blend = o.new("NumberValue", { Name = "Blend", Value = 1, Parent = q.frame })
					N = T
					N.rowFade = o.new("NumberValue", { Name = "RowFade", Value = 1, Parent = q.frame })
					l = T
					l.rowShot = F.snapshot(T.railRow)
					N = T
					N.square = o.new(
						"Frame",
						{
							Name = "Square",
							LayoutOrder = 0,
							Size = UDim2.new(1, 0, 0, I.SQUARE_H),
							BackgroundColor3 = Color3.fromHSV(0, 1, 1),
							BorderSizePixel = 0,
							ZIndex = Q,
							Parent = a,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(0, Z.corner), Parent = T.square })
					B, j, C =
						o.new(
							"Frame",
							{
								Name = "Saturation",
								Size = UDim2.fromScale(1, 1),
								BackgroundColor3 = Color3.new(1, 1, 1),
								BorderSizePixel = 0,
								ZIndex = Q + 1,
								Parent = T.square,
							}
						),
						o.new,
						{}
					C.CornerRadius, C.Parent = UDim.new(0, Z.corner), B
					j("UICorner", C)
					C, j = o.new, {}
					j.Transparency, j.Parent =
						NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
							1,
							1
						) }),
						B
					C("UIGradient", j)
					V, B, l =
						o.new(
							"Frame",
							{
								Name = "Value",
								Size = UDim2.fromScale(1, 1),
								BackgroundColor3 = Color3.new(),
								BorderSizePixel = 0,
								ZIndex = Q + 2,
								Parent = T.square,
							}
						),
						o.new,
						{}
					l.CornerRadius, l.Parent = UDim.new(0, Z.corner), V
					B("UICorner", l)
					B, q = o.new, { Rotation = 90 }
					q.Transparency, q.Parent =
						NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(
							1,
							0
						) }),
						V
					B("UIGradient", q)
					j = T
					j.ring = o.new(
						"Frame",
						{
							Name = "Ring",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Size = UDim2.fromOffset(I.RING, I.RING),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BorderSizePixel = 0,
							ZIndex = Q + 3,
							Parent = T.square,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = T.ring })
					o.new("UIStroke", { Thickness = 2, Color = Color3.new(1, 1, 1), Parent = T.ring })
					local function B(W, U, _)
						local x, d, L =
							o.new(
								"Frame",
								{
									Name = W,
									LayoutOrder = U,
									Size = UDim2.new(1, 0, 0, I.STRIP_H),
									BackgroundColor3 = Color3.new(1, 1, 1),
									BorderSizePixel = 0,
									ZIndex = Q,
									Parent = a,
								}
							),
							o.new,
							{}
						L.CornerRadius, L.Parent = UDim.new(1, 0), x
						d("UICorner", L)
						if W == "Alpha" then
							d, L, U =
								o.new(
									"ImageLabel",
									{
										Name = "Checker",
										Size = UDim2.fromScale(1, 1),
										BackgroundTransparency = 1,
										ZIndex = Q - 1,
										Parent = x,
									}
								),
								o.new,
								{}
							U.CornerRadius, U.Parent = UDim.new(1, 0), d
							L("UICorner", U)
							O.paint(d)
						end
						_.Parent = x
						o.new("UIGradient", _)
						W, U, d =
							o.new(
								"Frame",
								{
									Name = "Mark",
									AnchorPoint = Vector2.new(0.5, 0),
									Size = UDim2.new(0, I.MARK_W, 1, 0),
									BackgroundColor3 = Color3.new(1, 1, 1),
									BorderSizePixel = 0,
									ZIndex = Q + 1,
									Parent = x,
								}
							),
							o.new,
							{}
						d.CornerRadius, d.Parent = UDim.new(1, 0), W
						U("UICorner", d)
						_, U = o.new, { Thickness = 1 }
						U.Color, U.Transparency, U.Parent = Color3.new(), 0.6, W
						_("UIStroke", U)
						return x, W
					end
					C, q, j, N = T, T, B("Hue", 1, { Color = ColorSequence.new(A) })
					C.strip = j
					q.mark = N
					N, C, V, q =
						T,
						T,
						B(
							"Alpha",
							2,
							{
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 1),
									NumberSequenceKeypoint.new(1, 0),
								}),
							}
						)
					N.alpha = V
					C.alphaMark = q
					j = T
					j.hex = o.new(
						"TextBox",
						{
							Name = "Hex",
							LayoutOrder = 3,
							Size = UDim2.new(1, 0, 0, I.FIELD_H),
							BorderSizePixel = 0,
							Text = "FFFFFF",
							TextSize = Z.textSize - 2,
							skin = { BackgroundColor3 = "field", TextColor3 = "body" },
							FontFace = b.face(),
							ClearTextOnFocus = false,
							ClipsDescendants = true,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = Q,
							Parent = a,
						}
					)
					o.new("UICorner", { CornerRadius = UDim.new(0, Z.corner - 1), Parent = T.hex })
					l = T
					l.hexStroke = o.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = Z.stroke,
							skin = "stroke",
							Parent = T.hex,
						}
					)
					o.new(
						"UIPadding",
						{ PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = T.hex }
					)
					r()
					C = T
					return C
				end
				r = function()
					S()
					u.signal(T.blend.Changed, function(O)
						local o = not g or not k
						if o then
							return
						end
						G.h = I.lerpHue(g.h, k.h, O)
						G.s = g.s + (k.s - g.s) * O
						G.v = g.v + (k.v - g.v) * O
						G.a = g.a + (k.a - g.a) * O
						D(nil)
						o = O >= 1
						if o then
							g, k = nil, nil
						end
					end, "picker/blend")
					u.signal(T.rowFade.Changed, function(O)
						F.apply(T.rowShot, O)
						local F = T.rowHiding and O >= 1
						if F then
							T.railRow.Visible = false
						end
					end, "picker/rowfade")
					u.signal(T.mode.InputBegan, function(O)
						if O.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						O = H()
						if O == 0 then
							return
						end
						y.hold()
						local F = J(T.mode)
						R(math.min(math.floor(F * O) + 1, O), i.STATE)
					end, "picker/mode")
					local O = I.MAX_STOPS
					for F = 1, O, 1 do
						local O = T.stops[F]
						if O then
							u.signal(O.InputBegan, function(O)
								if O.UserInputType ~= Enum.UserInputType.MouseButton1 then
									return
								end
								y.hold()
								c(F)
							end, "picker/stop" .. F)
						end
					end
					u.signal(T.dial.InputBegan, function(O)
						if O.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						if not Y() then
							return
						end
						y.hold()
						m = "angle"
						K()
						P(nil)
					end, "picker/dial")
					u.signal(T.square.InputBegan, function(O)
						if O.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						y.hold()
						m = "square"
						local F, o, Z, b = i.to, T.ring, i.PRESS, {}
						b.Size = UDim2.fromOffset(I.RING + 4, I.RING + 4)
						F(o, Z, b)
						O, Z = J(T.square)
						G.s, G.v = O, 1 - Z
						P(nil)
					end, "picker/square")
					u.signal(T.strip.InputBegan, function(O)
						if O.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						y.hold()
						m = "strip"
						G.h = J(T.strip)
						P(nil)
					end, "picker/strip")
					u.signal(T.alpha.InputBegan, function(O)
						if O.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						y.hold()
						m = "alpha"
						G.a = J(T.alpha)
						P(nil)
					end, "picker/alpha")
					u.signal(T.hex.Focused, function()
						T.editing = true
						y.hold()
						i.to(T.hexStroke, i.HOVER_IN, { Color = z() })
					end, "picker/hexfocus")
					u.signal(T.hex.FocusLost, function()
						T.editing = false
						local J, O, u, F = i.to, T.hexStroke, i.HOVER_OUT, {}
						F.Color = f.get("stroke")
						J(O, u, F)
						O = p(T.hex.Text)
						if O then
							G.h, G.s, G.v = O:ToHSV()
							P(i.HOVER_IN)
						else
							D(nil)
						end
					end, "picker/hexblur")
				end
				local function p(J)
					if not h() then
						return
					end
					local O = y.current
					local u = O ~= nil
						and O ~= T.popup
						and J ~= nil
						and O.frame ~= nil
						and J:IsDescendantOf(O.frame)
					T.popup.owner = u and O or nil
				end
				local function J()
					i.cancel(T.blendTween)
					i.cancel(T.rowTween)
					g, k = nil, nil
					T.blend.Value = 1
					G.at = 1
					local O = H()
					local u, F = O > 0, w()
					T.mode.Visible = u
					if u then
						local o, Z = 1 / O, I.MAX_MODES
						for P = 1, Z, 1 do
							local Z, b = T.modeLabels[P], G.modes[P]
							Z.Visible = b ~= nil
							if b then
								Z.Text = b.label
								Z.Position = UDim2.new((P - 1) * o, 0, 0, 0)
								Z.Size = UDim2.fromScale(o, 1)
								Z.TextColor3 = P == G.mode and f.get("text") or f.get("faint")
							end
						end
						T.thumb.Position = UDim2.new((G.mode - 1) * o, 2, 0, 2)
						T.thumb.Size = UDim2.new(o, -4, 1, -4)
					end
					e()
					T.rowHiding = not F
					T.rowFade.Value = F and 0 or 1
					T.railRow.Visible = F
					T.body.Size = UDim2.new(1, 0, 0, I.heightFor(u, F, E()))
					O = I.MAX_STOPS
					for f = 1, O, 1 do
						u, F = T.stops[f], T.stopRings[f]
						if u and F then
							local O = f == 1
							local f = O and I.HANDLE_ON or I.HANDLE
							u.Size = UDim2.fromOffset(f, f)
							F.Transparency = O and 0 or I.HANDLE_DIM
						end
					end
				end
				local function O(u, F)
					T.popup.anchor = u
					T.popup.placement = "beside"
					D(nil)
					v = F
					F = not T.popup.open
					if F then
						T.popup:Open()
						return
					end
					T.popup:place()
					T.popup.guard = true
					u = T.popup.frame
					u.Position = UDim2.fromOffset(u.Position.X.Offset, T.popup.homeY + y.RISE)
					local F, f, o = i.to, i.HOVER_IN, {}
					o.Position = UDim2.fromOffset(u.Position.X.Offset, T.popup.homeY)
					F(u, f, o)
				end
				I.open = function(u, F, f, o, Z)
					if not h() then
						return
					end
					p(u)
					v = nil
					G.h, G.s, G.v = F:ToHSV()
					G.a = typeof(f) == "number" and math.clamp(f, 0, 1) or 1
					f = { color = F, alpha = G.a }
					G.kind = Z and "grad" or "plain"
					if Z then
						local i = {
							color = typeof(Z.color) == "Color3" and Z.color or F,
							alpha = typeof(Z.alpha) == "number" and math.clamp(Z.alpha, 0, 1) or 1,
						}
						G.angle = typeof(Z.angle) == "number" and Z.angle or I.GRAD_ANGLE
						G.modes = {
							{ key = "solid", label = "solid", stops = { f } },
							{ key = "gradient", label = "gradient", stops = { f, i } },
						}
						s(Z.on and 2 or 1)
					else
						G.modes = {}
						G.mode = 1
						G.slots = { f }
						G.on = false
					end
					J()
					O(u, o)
				end
				I.openRamp = function(u, F, f)
					if not h() then
						return
					end
					if typeof(F) ~= "table" or typeof(F.modes) ~= "table" then
						return
					end
					p(u)
					v = nil
					G.kind = "ramp"
					G.angle = I.GRAD_ANGLE
					G.modes = {}
					local p = 1
					for o, Z in ipairs(F.modes) do
						local i, y = G.modes, { key = Z.key, label = Z.label, ruler = Z.ruler == true }
						y.stops, i[o] = Z.stops or {}, y
						p = if Z.key == F.mode then o else p
					end
					s(p)
					F = G.slots[1]
					if not F then
						return
					end
					G.h, G.s, G.v = F.color:ToHSV()
					G.a = F.alpha
					J()
					O(u, f)
				end
				I.isOpenFor = function(p)
					local J = T ~= nil and T.popup ~= nil and T.popup.open == true and T.popup.anchor == p
					return J
				end
				I.close = function()
					local p = T and T.popup
					if p then
						T.popup:Close()
					end
				end
				I.isOpenFor = function(p)
					local J = T ~= nil and T.popup.open and T.popup.anchor == p
					return J
				end
				return I
			end
end)()

_registry["ui/components/base"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/skin")
				local u = p("ui/create")
				local F = p("ui/icon")
				local f = p("ui/keybind")
				local o = p("ui/metrics")
				local Z = p("ui/motion")
				local i = p("ui/popup")
				local y = p("ui/theme")
				local P = p("ui/tooltip")
				local b = p("ui/zindex")
				local p
				p = {
					IDLE_ROLE = "dim",
					GEAR_SPIN = 45,
					CAUTION_ROLE = "danger",
					CAUTION_TIP = "turning this on can cost you noticeable fps",
					slot = function(I)
						local h = I.bindConfig and 1 or 0
						I.subcount = (I.subcount or 0) + 1
						return (h + I.subcount - 1) * o.subStep
					end,
					slotCount = function(I)
						return (I.subcount or 0) + (I.bindConfig and 1 or 0)
					end,
					SetShown = function(I, h)
						I.shown = h and true or false
						if I.main then
							I.main.Visible = I.shown
						end
						return I
					end,
					AddGear = function(I, h)
						I.gearBuild = h
						if I.main then
							I:mountGear()
						end
						return I
					end,
					AddTooltip = function(I, h)
						I.tip = typeof(h) == "string" and h or nil
						if I.main then
							I:mountTooltip()
						end
						return I
					end,
					mountTooltip = function(I)
						if not I.tip or I.tipMounted then
							return
						end
						I.tipMounted = true
						P.attach(I.interest or I.main, I.tip)
					end,
					AddCaution = function(I, h)
						I.cautionTip = typeof(h) == "string" and h ~= "" and h or p.CAUTION_TIP
						if I.main then
							I:mountCaution()
						end
						return I
					end,
					mountCaution = function(I)
						if I.caution or not I.cautionTip or not I.main then
							return
						end
						local h, A = I:slot(), F.size()
						local T = u.new(
							"ImageLabel",
							{
								Name = "Caution",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -h - o.controlX, 0, I.adornY or o.row // 2),
								Size = UDim2.fromOffset(A, A),
								BackgroundTransparency = 1,
								skin = p.CAUTION_ROLE,
								ImageContent = F.get("caution"),
								ZIndex = (I.zbase or b.WIDGET) + 3,
								Parent = I.main,
							}
						)
						P.attach(T, I.cautionTip)
						I.caution = T
						I:reserveLabel()
						return T
					end,
					AddKeybind = function(P, I)
						P.bindConfig = typeof(I) == "table" and I or {}
						if P.main then
							P:mountKeybind()
						end
						return P
					end,
					mountKeybind = function(P)
						if not P.bindConfig or P.bind then
							return
						end
						P.bind = f.attach(P, P.interest or P.main, P.main, 0, P.bindConfig)
					end,
					adorn = function(f)
						if f.gearBuild ~= nil and not f.gear then
							f:mountGear()
						end
						if f.actionIcon and not f.action then
							f:mountAction()
						end
						if f.cautionTip and not f.caution then
							f:mountCaution()
						end
						if f.bindConfig and not f.bind then
							f:mountKeybind()
						end
						if f.tip then
							f:mountTooltip()
						end
						if f.colors and f.mountColors then
							f:mountColors()
						end
					end,
					AddAction = function(f, P, I)
						f.actionIcon = P
						f.actionRun = I
						if f.main then
							f:mountAction()
						end
						return f
					end,
					mountAction = function(f)
						if f.action or not f.actionIcon or not f.main then
							return
						end
						local P, I = f:slot(), F.size()
						local h = u.new(
							"ImageLabel",
							{
								Name = "Action",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -P - o.controlX, 0, f.adornY or o.row // 2),
								Size = UDim2.fromOffset(I, I),
								BackgroundTransparency = 1,
								skin = p.IDLE_ROLE,
								ImageContent = F.get(f.actionIcon),
								ZIndex = (f.zbase or b.WIDGET) + 3,
								Parent = f.main,
							}
						)
						J.signal(h.InputBegan, function(P)
							if P.UserInputType == Enum.UserInputType.MouseButton1 then
								Z.cancel(f.actionPress)
								f.actionPress = Z.to(
									h,
									Z.PRESS,
									{ Size = UDim2.fromOffset(I * o.pressScale, I * o.pressScale) }
								)
								if typeof(f.actionRun) == "function" then
									pcall(f.actionRun)
								end
							elseif P.UserInputType == Enum.UserInputType.MouseMovement then
								if i.blocks(h) then
									return
								end
								local P, A, T = Z.to, Z.HOVER_IN, {}
								T.ImageColor3 = y.get()
								P(h, A, T)
							end
						end, "action/begin")
						J.signal(h.InputEnded, function(P)
							if
								P.UserInputType == Enum.UserInputType.MouseButton1
								or P.UserInputType == Enum.UserInputType.MouseMovement
							then
								Z.cancel(f.actionPress)
								f.actionPress = Z.to(h, Z.RELEASE, { Size = UDim2.fromOffset(I, I) })
							end
							if P.UserInputType == Enum.UserInputType.MouseMovement then
								local P, I, A = Z.to, Z.HOVER_OUT, {}
								A.ImageColor3 = O.get(p.IDLE_ROLE)
								P(h, I, A)
							end
						end, "action/end")
						f.action = h
						f:reserveLabel()
						return h
					end,
					mountGear = function(f)
						local P, I, h = f.gearBuild, f:slot(), F.size()
						local A = u.new(
							"ImageLabel",
							{
								Name = "Gear",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -I - o.controlX, 0, f.adornY or o.row // 2),
								Size = UDim2.fromOffset(h, h),
								BackgroundTransparency = 1,
								skin = p.IDLE_ROLE,
								ImageContent = F.get("gear"),
								ZIndex = (f.zbase or b.WIDGET) + 3,
								Parent = f.main,
							}
						)
						local u = i.new(A)
						if not u then
							return nil
						end
						if typeof(P) == "function" then
							P(u)
						end
						local function F(P)
							Z.to(
								A,
								P and Z.HOVER_IN or Z.HOVER_OUT,
								{
									ImageColor3 = P and y.get() or O.get(p.IDLE_ROLE),
									Rotation = P and p.GEAR_SPIN or 0,
								}
							)
						end
						u.onOpen = function()
							F(true)
						end
						u.onClose = function()
							F(false)
						end
						J.signal(A.InputBegan, function(O)
							if O.UserInputType == Enum.UserInputType.MouseButton1 then
								Z.cancel(f.gearPress)
								f.gearPress = Z.to(
									A,
									Z.PRESS,
									{ Size = UDim2.fromOffset(h * o.pressScale, h * o.pressScale) }
								)
								u:Toggle()
							elseif O.UserInputType == Enum.UserInputType.MouseMovement then
								if i.blocks(A) then
									return
								end
								if not u.open then
									F(true)
								end
							end
						end, "gear/begin")
						J.signal(A.InputEnded, function(J)
							if
								J.UserInputType == Enum.UserInputType.MouseButton1
								or J.UserInputType == Enum.UserInputType.MouseMovement
							then
								Z.cancel(f.gearPress)
								f.gearPress = Z.to(A, Z.RELEASE, { Size = UDim2.fromOffset(h, h) })
							end
							if J.UserInputType == Enum.UserInputType.MouseMovement and not u.open then
								F(false)
							end
						end, "gear/end")
						f.gear = A
						f.popup = u
						return u
					end,
					reserveLabel = function(J)
						if not J.title then
							return
						end
						local O = J:slotCount() * o.subStep + o.controlX
						if O <= o.controlX then
							return
						end
						if J.hit then
							local u = J.hit.Size
							J.hit.Size = UDim2.new(u.X.Scale, -O, u.Y.Scale, u.Y.Offset)
							return
						end
						local u = J.title.Size
						J.title.Size = UDim2.new(1, -(J.title.Position.X.Offset + O), u.Y.Scale, u.Y.Offset)
					end,
				}
				return p
			end
end)()

_registry["ui/components/box"] = (function()

return function(p)
				local J, O = p("ui/components/base"), p("ui/skin")
				local u = p("ui/connect")
				local F = p("ui/create")
				local f = p("ui/metrics")
				local o = p("ui/motion")
				local Z = p("ui/popup")
				local i = p("ui/theme")
				local y = p("ui/font")
				local P, b, I, h =
					p("ui/zindex"),
					{ LABEL_H = 18, LABEL_GAP = 4, FIELD_H = 20, ROW = 16, ROW_PAD = 4 },
					setmetatable,
					{ __index = J }
				local p = I({}, h)
				p.__index = p
				b.new = function(J)
					J = typeof(J) == "table" and J or {}
					local I = tostring(J.text or "box")
					return setmetatable(
						{
							type = "box",
							text = I,
							tip = J.tip and tostring(J.tip) or nil,
							flag = tostring(J.flag or I),
							value = tostring(J.value or ""),
							placeholder = tostring(J.placeholder or ""),
							lines = math.max(1, math.floor(tonumber(J.lines) or 1)),
							callback = typeof(J.callback) == "function" and J.callback or nil,
							subcount = 0,
							hasInit = false,
							adornY = b.LABEL_H // 2,
						},
						p
					)
				end
				b.Box = p
				p.Get = function(J)
					return J.value
				end
				p.Set = function(J, I, h)
					J.value = tostring(I or "")
					if J.hasInit and not J.editing then
						J.field.Text = J.value
					end
					if J.onChanged then
						J.onChanged(J.flag, J.value)
					end
					if not h and J.callback then
						pcall(J.callback, J.value)
					end
					return J
				end
				p.Init = function(J, I)
					if J.hasInit or not I then
						return J
					end
					J.hasInit = true
					local h, A = J.zbase or P.WIDGET, J.lines > 1
					local P = A and J.lines * b.ROW + b.ROW_PAD * 2 or b.FIELD_H - 2
					local T = A and P or b.FIELD_H
					J.main = F.new(
						"Frame",
						{
							Name = "Box",
							LayoutOrder = J.position or 0,
							Size = UDim2.new(1, 0, 0, b.LABEL_H + b.LABEL_GAP + T),
							AutomaticSize = A and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
							BackgroundTransparency = 1,
							ZIndex = h,
							Parent = I,
						}
					)
					J.title = F.new(
						"TextLabel",
						{
							Name = "Title",
							Position = UDim2.fromOffset(f.controlX, 0),
							Size = UDim2.new(1, -f.controlX, 0, b.LABEL_H),
							BackgroundTransparency = 1,
							Text = J.text,
							TextSize = f.textSize,
							skin = "body",
							FontFace = y.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = h + 1,
							Parent = J.main,
						}
					)
					J.field = F.new(
						"TextBox",
						{
							Name = "Field",
							Position = UDim2.fromOffset(f.controlX, b.LABEL_H + b.LABEL_GAP),
							Size = UDim2.new(1, -f.controlX * 2, 0, P),
							AutomaticSize = A and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
							skin = { BackgroundColor3 = "field", TextColor3 = "body", PlaceholderColor3 = "hint" },
							BorderSizePixel = 0,
							Text = J.value,
							PlaceholderText = J.placeholder,
							TextSize = f.textSize - 2,
							FontFace = y.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ClearTextOnFocus = false,
							MultiLine = A,
							TextWrapped = A,
							TextYAlignment = A and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
							ClipsDescendants = true,
							TextTruncate = A and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
							ZIndex = h + 1,
							Parent = J.main,
						}
					)
					F.new("UICorner", { CornerRadius = UDim.new(0, f.corner - 1), Parent = J.field })
					J.stroke = F.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = f.stroke,
							skin = "stroke",
							Parent = J.field,
						}
					)
					F.new(
						"UIPadding",
						{
							PaddingLeft = UDim.new(0, 7),
							PaddingRight = UDim.new(0, 7),
							PaddingTop = UDim.new(0, A and b.ROW_PAD or 0),
							PaddingBottom = UDim.new(0, A and b.ROW_PAD or 0),
							Parent = J.field,
						}
					)
					J:wire()
					J:adorn()
					J:reserveLabel()
					return J
				end
				p.wire = function(p)
					u.signal(p.field.InputBegan, function(J)
						if J.UserInputType == Enum.UserInputType.MouseButton1 then
							Z.hold()
						end
					end, "box/down")
					u.signal(p.field.Focused, function()
						Z.hold()
						p.editing = true
						local J, F, f, Z = o.to, p.stroke, o.HOVER_IN, {}
						Z.Color = i.get()
						J(F, f, Z)
					end, "box/focus")
					u.signal(p.field.FocusLost, function()
						p.editing = false
						local J, F, f, Z = o.to, p.stroke, o.HOVER_OUT, {}
						Z.Color = O.get("stroke")
						J(F, f, Z)
						if p.field.Text ~= p.value then
							p:Set(p.field.Text)
						end
					end, "box/blur")
					u.signal(p.field.MouseEnter, function()
						if p.editing then
							return
						end
						local J, F, f, Z = o.to, p.stroke, o.HOVER_IN, {}
						Z.Color = O.get("edge")
						J(F, f, Z)
					end, "box/enter")
					u.signal(p.field.MouseLeave, function()
						if p.editing then
							return
						end
						local J, u, F, f = o.to, p.stroke, o.HOVER_OUT, {}
						f.Color = O.get("stroke")
						J(u, F, f)
					end, "box/leave")
				end
				return b
			end
end)()

_registry["ui/components/button"] = (function()

return function(p)
				local J, O = p("ui/components/base"), p("ui/skin")
				local u = p("ui/connect")
				local F = p("ui/create")
				local f = p("ui/icon")
				local o = p("ui/metrics")
				local Z = p("ui/motion")
				local i = p("ui/popup")
				local y = p("ui/theme")
				local P = p("ui/font")
				local b = p("ui/zindex")
				local p, I, h =
					{
						HEIGHT = 34,
						BAR_H = 26,
						PAD = 4,
						INSET_X = 10,
						PRESS_INSET = 2,
						BG = "control",
						BG_HOVER = "hover",
						GRADIENT_TOP = Color3.fromRGB(180, 180, 180),
						GRADIENT_BOTTOM = Color3.fromRGB(253, 253, 253),
					},
					setmetatable,
					{ __index = J }
				local J = I({}, h)
				J.__index = J
				p.new = function(I)
					I = typeof(I) == "table" and I or {}
					return setmetatable(
						{
							type = "button",
							text = tostring(I.text or "button"),
							tip = I.tip and tostring(I.tip) or nil,
							icon = I.icon and tostring(I.icon) or nil,
							tone = I.tone and tostring(I.tone) or nil,
							callback = typeof(I.callback) == "function" and I.callback or nil,
							subcount = 0,
							hasInit = false,
							adornY = p.HEIGHT - p.PAD - p.BAR_H // 2,
						},
						J
					)
				end
				p.Button = J
				J.Get = function(I)
					return I.text
				end
				J.Set = function(I, h)
					I.text = tostring(h or "")
					if I.hasInit then
						if I.label then
							I.label.Text = I.text
						else
							I.bar.Text = I.text
						end
					end
					return I
				end
				J.Fire = function(I)
					if I.callback then
						pcall(I.callback)
					end
					return I
				end
				J.Init = function(I, h)
					if I.hasInit or not h then
						return I
					end
					I.hasInit = true
					local A = I.zbase or b.WIDGET
					I.main = F.new(
						"Frame",
						{
							Name = "Button",
							LayoutOrder = I.position or 0,
							Size = UDim2.new(1, 0, 0, p.HEIGHT),
							BackgroundTransparency = 1,
							ZIndex = A,
							Parent = h,
						}
					)
					I.bar = F.new(
						"TextButton",
						{
							Name = "Bar",
							AnchorPoint = Vector2.new(0.5, 1),
							Position = UDim2.new(0.5, 0, 1, -p.PAD),
							Size = UDim2.new(1, -p.INSET_X * 2, 0, p.BAR_H),
							skin = { BackgroundColor3 = p.BG, TextColor3 = "text" },
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = I.text,
							TextSize = o.textSize,
							FontFace = P.face(),
							ZIndex = A + 1,
							Parent = I.main,
						}
					)
					F.new("UICorner", { CornerRadius = UDim.new(0, o.corner), Parent = I.bar })
					I.stroke = F.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = o.stroke,
							skin = "stroke",
							Parent = I.bar,
						}
					)
					I.gradient = F.new(
						"UIGradient",
						{
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, p.GRADIENT_TOP),
								ColorSequenceKeypoint.new(1, p.GRADIENT_BOTTOM),
							}),
							Rotation = -90,
							Parent = I.bar,
						}
					)
					h = I.icon and f.get(I.icon)
					if h then
						I.bar.Text = ""
						I.strip = F.new(
							"Frame",
							{
								Name = "Strip",
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.fromOffset(0, p.BAR_H),
								BackgroundTransparency = 1,
								ZIndex = A + 2,
								Parent = I.bar,
							}
						)
						F.new(
							"UIListLayout",
							{
								FillDirection = Enum.FillDirection.Horizontal,
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								Padding = UDim.new(0, 6),
								Parent = I.strip,
							}
						)
						I.mark = F.new(
							"ImageLabel",
							{
								Name = "Mark",
								LayoutOrder = 1,
								Size = UDim2.fromOffset(13, 13),
								BackgroundTransparency = 1,
								skin = I.tone or "text",
								ImageContent = h,
								ZIndex = A + 3,
								Parent = I.strip,
							}
						)
						I.label = F.new(
							"TextLabel",
							{
								Name = "Text",
								LayoutOrder = 2,
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.fromOffset(0, p.BAR_H),
								BackgroundTransparency = 1,
								Text = I.text,
								TextSize = o.textSize,
								skin = I.tone or "text",
								FontFace = P.face(),
								ZIndex = A + 3,
								Parent = I.strip,
							}
						)
					elseif I.tone then
						O.paint(I.bar, { TextColor3 = I.tone })
					end
					I.interest = I.bar
					I:wire()
					I:adorn()
					return I
				end
				J.highlight = function(F, f)
					local o, P, b, I = f and Z.HOVER_IN or Z.HOVER_OUT, Z.to, F.bar, {}
					I.BackgroundColor3 = O.get(f and p.BG_HOVER or p.BG)
					P(b, o, I)
					b, P, I = Z.to, F.stroke, {}
					I.Color = f and y.get() or O.get("stroke")
					b(P, o, I)
				end
				J.press = function(O, F)
					Z.cancel(O.pressTween)
					local f = F and p.PRESS_INSET or 0
					O.pressTween = Z.to(
						O.bar,
						F and Z.PRESS or Z.RELEASE,
						{ Size = UDim2.new(1, -p.INSET_X * 2 - f * 2, 0, p.BAR_H - f * 2) }
					)
					O.gradient.Rotation = F and 90 or -90
				end
				J.wire = function(J)
					u.signal(J.bar.InputBegan, function(O)
						if O.UserInputType == Enum.UserInputType.MouseButton1 then
							i.hold()
							J:press(true)
						elseif O.UserInputType == Enum.UserInputType.MouseMovement then
							if i.blocks(J.bar) then
								return
							end
							J:highlight(true)
						end
					end, "button/begin")
					u.signal(J.bar.InputEnded, function(O)
						if O.UserInputType == Enum.UserInputType.MouseButton1 then
							J:press(false)
						elseif O.UserInputType == Enum.UserInputType.MouseMovement then
							J:press(false)
							J:highlight(false)
						end
					end, "button/end")
					u.signal(J.bar.Activated, function()
						J:Fire()
					end, "button/fire")
				end
				return p
			end
end)()

_registry["ui/components/color"] = (function()

return function(p)
				local J, O = p("ui/components/base"), p("ui/skin")
				local u = p("ui/connect")
				local F = p("ui/create")
				local f = p("ui/metrics")
				local o = p("ui/motion")
				local Z = p("ui/colorpicker")
				local i = p("ui/popup")
				local y = p("ui/theme")
				local P = p("ui/font")
				local b, I, h, A =
					p("ui/zindex"),
					{
						ALPHA_KEY = "_alpha",
						GRAD_KEY = "_grad",
						GRAD_COLOR_KEY = "_grad_b",
						GRAD_ANGLE_KEY = "_grad_angle",
						GRAD_ANGLE = 90,
						RAMP_ANGLE = 90,
					},
					setmetatable,
					{ __index = J }
				local p = h({}, A)
				p.__index = p
				local function J(h)
					if typeof(h) == "Color3" then
						return h
					end
					return Color3.fromRGB(255, 255, 255)
				end
				local function h(A)
					if typeof(A) ~= "number" then
						return 1
					end
					return math.clamp(A, 0, 1)
				end
				local function A(T)
					if typeof(T) ~= "table" or #T == 0 then
						return nil, nil
					end
					local r, S = {}, {}
					for c, R in ipairs(T) do
						c = {}
						for T, e in ipairs(R.stops or {}) do
							T = tostring(e.flag)
							table.insert(c, T)
							if not S[T] then
								S[T] = { color = J(e.value), alpha = h(e.alpha) }
							end
						end
						table.insert(
							r,
							{
								key = tostring(R.key),
								label = tostring(R.label or R.key),
								stops = c,
								ruler = R.ruler == true,
							}
						)
					end
					return r, S
				end
				I.new = function(T)
					T = typeof(T) == "table" and T or {}
					local r, S, c = tostring(T.text or "color"), A(T.modes)
					return setmetatable(
						{
							modes = S,
							stops = c,
							mode = S and tostring(T.value or S[1].key) or nil,
							type = "color",
							text = r,
							tip = T.tip and tostring(T.tip) or nil,
							flag = tostring(T.flag or r),
							value = J(T.value or T.color),
							alpha = h(T.alpha),
							gradient = typeof(T.gradient) == "table" and {
								on = false,
								color = J(T.gradient.value),
								alpha = h(T.gradient.alpha),
								angle = typeof(T.gradient.angle) == "number" and T.gradient.angle
									or I.GRAD_ANGLE,
							} or nil,
							callback = typeof(T.callback) == "function" and T.callback or nil,
							subcount = 0,
							hasInit = false,
						},
						p
					)
				end
				I.Color = p
				p.Get = function(A)
					if A.modes then
						return A.mode
					end
					return A.value
				end
				p.GetStops = function(A)
					if not A.stops then
						return nil
					end
					local T = {}
					for r, S in pairs(A.stops) do
						T[r] = { color = S.color, alpha = S.alpha }
					end
					return T
				end
				p.SetStops = function(A, T, r)
					if not A.stops or typeof(T) ~= "table" then
						return A
					end
					for S, c in pairs(T) do
						if A.stops[S] and typeof(c) == "table" then
							A.stops[S].color = J(c.color or A.stops[S].color)
							if typeof(c.alpha) == "number" then
								A.stops[S].alpha = h(c.alpha)
							end
						end
					end
					A:mirrorStops()
					A:repaint()
					if not r and A.callback then
						pcall(A.callback, A.mode, A.stops)
					end
					return A
				end
				p.mirrorStops = function(A)
					if not A.onChanged or not A.stops then
						return
					end
					for T, r in pairs(A.stops) do
						A.onChanged(T, r.color)
						A.onChanged(T .. I.ALPHA_KEY, r.alpha)
					end
				end
				p.mirrorRamp = function(A)
					if not A.modes or not A.onChanged then
						return
					end
					A.onChanged(A.flag, A.mode)
					A:mirrorStops()
				end
				p.activeStops = function(A)
					if not A.modes then
						return {}
					end
					for T, r in ipairs(A.modes) do
						if r.key == A.mode then
							T = {}
							for S, c in ipairs(r.stops) do
								S = A.stops[c]
								if S then
									table.insert(T, { color = S.color, alpha = S.alpha })
								end
							end
							return T, r
						end
					end
					return {}
				end
				p.GetAlpha = function(A)
					return A.alpha
				end
				p.mirrorAlpha = function(A)
					if A.onChanged then
						A.onChanged(A.flag .. I.ALPHA_KEY, A.alpha)
					end
				end
				p.GetGradient = function(A)
					if not A.gradient then
						return nil
					end
					return {
						on = A.gradient.on,
						color = A.gradient.color,
						alpha = A.gradient.alpha,
						angle = A.gradient.angle,
					}
				end
				p.mirrorGradient = function(A)
					if not A.onChanged or not A.gradient then
						return
					end
					A.onChanged(A.flag .. I.GRAD_KEY, A.gradient.on)
					A.onChanged(A.flag .. I.GRAD_COLOR_KEY, A.gradient.color)
					A.onChanged(A.flag .. I.GRAD_COLOR_KEY .. I.ALPHA_KEY, A.gradient.alpha)
					A.onChanged(A.flag .. I.GRAD_ANGLE_KEY, A.gradient.angle)
				end
				p.SetGradient = function(A, T, r)
					if not A.gradient or typeof(T) ~= "table" then
						return A
					end
					A.gradient.on = T.on and true or false
					A.gradient.color = J(T.color or A.gradient.color)
					if typeof(T.alpha) == "number" then
						A.gradient.alpha = h(T.alpha)
					end
					if typeof(T.angle) == "number" then
						A.gradient.angle = T.angle
					end
					A:mirrorGradient()
					A:repaint()
					if not r and A.callback then
						pcall(A.callback, A.value, A.alpha)
					end
					return A
				end
				p.repaint = function(A)
					if not A.hasInit then
						return
					end
					o.cancel(A.stateTween)
					A.stateTween = nil
					if A.modes then
						local T = A:activeStops()
						local r = #T
						if r == 0 then
							A.ramp.Enabled = false
							A.swatch.BackgroundTransparency = 1
							return
						end
						if r == 1 then
							A.ramp.Enabled = false
							A.swatch.BackgroundColor3 = T[1].color
							A.swatch.BackgroundTransparency = 1 - T[1].alpha
							return
						end
						local S, c = {}, {}
						for R, e in ipairs(T) do
							local T = (R - 1) / (r - 1)
							table.insert(S, ColorSequenceKeypoint.new(T, e.color))
							table.insert(c, NumberSequenceKeypoint.new(T, 1 - e.alpha))
						end
						A.swatch.BackgroundColor3 = Color3.new(1, 1, 1)
						A.swatch.BackgroundTransparency = 0
						A.ramp.Color = ColorSequence.new(S)
						A.ramp.Transparency = NumberSequence.new(c)
						A.ramp.Rotation = I.RAMP_ANGLE
						A.ramp.Enabled = true
						return
					end
					local T = A.gradient
					if T and T.on then
						A.swatch.BackgroundColor3 = Color3.new(1, 1, 1)
						A.swatch.BackgroundTransparency = 0
						A.ramp.Color = ColorSequence.new(A.value, T.color)
						A.ramp.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1 - A.alpha),
							NumberSequenceKeypoint.new(1, 1 - T.alpha),
						})
						A.ramp.Rotation = T.angle
						A.ramp.Enabled = true
						return
					end
					A.ramp.Enabled = false
					A.swatch.BackgroundColor3 = A.value
					A.swatch.BackgroundTransparency = 1 - A.alpha
				end
				p.apply = function(A, T, r, S)
					A.value = J(T)
					A.alpha = h(r)
					if A.hasInit then
						r = { BackgroundColor3 = A.value, BackgroundTransparency = 1 - A.alpha }
						if A.gradient and A.gradient.on then
							A:repaint()
						elseif A.live then
							A.swatch.BackgroundColor3 = r.BackgroundColor3
							A.swatch.BackgroundTransparency = r.BackgroundTransparency
						else
							A.stateTween = o.to(A.swatch, o.STATE, r)
						end
					end
					if A.onChanged then
						A.onChanged(A.flag, A.value)
					end
					A:mirrorAlpha()
					if not S and A.callback then
						pcall(A.callback, A.value, A.alpha)
					end
					return A
				end
				p.Set = function(J, h, A)
					if J.modes then
						local T, r = tostring(h), false
						for S, S in ipairs(J.modes) do
							if S.key == T then
								r = true
								break
							end
						end
						if not r then
							return J
						end
						J.mode = T
						if J.onChanged then
							J.onChanged(J.flag, J.mode)
						end
						J:repaint()
						if not A and J.callback then
							pcall(J.callback, J.mode, J.stops)
						end
						return J
					end
					return J:apply(h, J.alpha, A)
				end
				p.SetAlpha = function(J, h, A)
					return J:apply(J.value, h, A)
				end
				p.Init = function(J, h)
					if J.hasInit or not h then
						return J
					end
					J.hasInit = true
					local A, T = J.zbase or b.WIDGET, f.control
					J.main = F.new(
						"Frame",
						{
							Name = "Color",
							LayoutOrder = J.position or 0,
							Size = UDim2.new(1, 0, 0, f.row),
							skin = "rowGlow",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ZIndex = A,
							Parent = h,
						}
					)
					F.new("UICorner", { CornerRadius = UDim.new(0, f.corner), Parent = J.main })
					J:paint(J.main, A, UDim2.fromOffset(f.controlX + T // 2, f.row // 2))
					J.interest = F.new(
						"Frame",
						{
							Name = "Hit",
							Size = UDim2.new(1, 0, 0, f.row),
							BackgroundTransparency = 1,
							ZIndex = A + 2,
							Parent = J.main,
						}
					)
					J.hit = J.interest
					h = f.labelX()
					J.title = F.new(
						"TextLabel",
						{
							Name = "Title",
							Position = UDim2.new(0, h, 0, 0),
							Size = UDim2.new(1, -h, 1, 0),
							BackgroundTransparency = 1,
							Text = J.text,
							TextSize = f.textSize,
							skin = "body",
							FontFace = P.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = A + 2,
							Parent = J.interest,
						}
					)
					J:wire(J.interest, true)
					J:adorn()
					J:reserveLabel()
					J:mirrorAlpha()
					J:mirrorGradient()
					J:mirrorRamp()
					return J
				end
				p.attach = function(J, P)
					if J.hasInit or not P or not P.main then
						return J
					end
					J.hasInit = true
					local h, A, T = (P.zbase or b.WIDGET) + 3, f.control, P:slot()
					J.main = P.main
					J:paint(P.main, h, UDim2.new(1, -T - f.controlX - A // 2, 0, P.adornY or f.row // 2))
					J:wire(J.swatch, false)
					J.interest = J.swatch
					if J.tip then
						J:mountTooltip()
					end
					if P.reserveLabel then
						P:reserveLabel()
					end
					J:mirrorAlpha()
					J:mirrorGradient()
					J:mirrorRamp()
					return J
				end
				p.paint = function(J, P, b, h)
					local A = f.control
					J.swatch = F.new(
						"Frame",
						{
							Name = "Swatch",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = h,
							Size = UDim2.fromOffset(A, A),
							BackgroundColor3 = J.value,
							BackgroundTransparency = 1 - J.alpha,
							BorderSizePixel = 0,
							ZIndex = b + 1,
							Parent = P,
						}
					)
					F.new("UICorner", { CornerRadius = UDim.new(0, f.corner), Parent = J.swatch })
					J.ramp = F.new("UIGradient", { Enabled = false, Parent = J.swatch })
					J.stroke = F.new("UIStroke", { Thickness = f.stroke, skin = "hard", Parent = J.swatch })
				end
				p.highlight = function(J, F)
					local P, b, h, A = F and o.HOVER_IN or o.HOVER_OUT, o.to, J.stroke, {}
					A.Color = F and y.get() or O.get("hard")
					b(h, P, A)
					if J.row then
						h, A, b = o.to, J.row, {}
						b.BackgroundTransparency = F and f.rowHover or 1
						h(A, P, b)
					end
				end
				p.press = function(J, O)
					o.cancel(J.pressTween)
					local F = f.control * (O and f.pressScale or 1)
					J.pressTween =
						o.to(J.swatch, O and o.PRESS or o.RELEASE, { Size = UDim2.fromOffset(F, F) })
				end
				p.wire = function(J, O, F)
					J.row = F and J.main or nil
					u.signal(O.InputBegan, function(F)
						if F.UserInputType == Enum.UserInputType.MouseButton1 then
							J:press(true)
							J:toggle()
						elseif F.UserInputType == Enum.UserInputType.MouseMovement then
							if i.blocks(O) then
								return
							end
							J:highlight(true)
						end
					end, "color/begin")
					u.signal(O.InputEnded, function(O)
						if O.UserInputType == Enum.UserInputType.MouseButton1 then
							J:press(false)
						elseif O.UserInputType == Enum.UserInputType.MouseMovement then
							J:press(false)
							J:highlight(false)
						end
					end, "color/end")
				end
				p.toggle = function(p)
					if Z.isOpenFor(p.swatch) then
						Z.close()
						return
					end
					if p.modes then
						local J, O = {}, {}
						for u, F in ipairs(p.modes) do
							u = {}
							for f, f in ipairs(F.stops) do
								if not J[f] and p.stops[f] then
									J[f] = { color = p.stops[f].color, alpha = p.stops[f].alpha }
								end
								if J[f] then
									table.insert(u, J[f])
								end
							end
							table.insert(O, { key = F.key, label = F.label, ruler = F.ruler, stops = u })
						end
						Z.openRamp(p.swatch, { modes = O, mode = p.mode }, function(O)
							p.live = true
							if O ~= p.mode then
								p:Set(O)
							end
							p:SetStops(J)
							p.live = false
						end)
						return
					end
					Z.open(p.swatch, p.value, p.alpha, function(J, O, u)
						p.live = true
						p:apply(J, O)
						if u then
							p:SetGradient(u)
						end
						p.live = false
					end, p:GetGradient())
				end
				return I
			end
end)()

_registry["ui/components/divider"] = (function()

return function(p)
				local J = p("ui/connect")
				p("ui/skin")
				local O = p("ui/create")
				local u = p("ui/metrics")
				local F = p("ui/font")
				local f, o, Z =
					p("ui/zindex"),
					{ HEIGHT = 18, BARE_HEIGHT = 8, GAP = 8, INSET = 6, LINE = "line", TEXT = "dim" },
					{}
				Z.__index = Z
				o.new = function(p)
					p = if typeof(p) == "string" then { text = p } else p
					p = typeof(p) == "table" and p or {}
					local i = p.text and tostring(p.text) or nil
					return setmetatable({ type = "divider", text = i ~= "" and i or nil, hasInit = false }, Z)
				end
				o.Divider = Z
				Z.Get = function(p)
					return p.text
				end
				Z.Init = function(p, i)
					if p.hasInit or not i then
						return p
					end
					p.hasInit = true
					local y = p.zbase or f.WIDGET
					local f = p.text and o.HEIGHT or o.BARE_HEIGHT
					p.main = O.new(
						"Frame",
						{
							Name = "Divider",
							LayoutOrder = p.position or 0,
							Size = UDim2.new(1, 0, 0, f),
							BackgroundTransparency = 1,
							ZIndex = y,
							Parent = i,
						}
					)
					local function i(P, b)
						return O.new(
							"Frame",
							{
								Name = P,
								AnchorPoint = Vector2.new(b, 0.5),
								Position = UDim2.new(b, b == 0 and o.INSET or -o.INSET, 0.5, 0),
								Size = UDim2.new(0.5, -o.INSET, 0, 1),
								skin = o.LINE,
								BorderSizePixel = 0,
								ZIndex = y,
								Parent = p.main,
							}
						)
					end
					p.left = i("Left", 0)
					p.right = i("Right", 1)
					if not p.text then
						return p
					end
					p.title = O.new(
						"TextLabel",
						{
							Name = "Title",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(0, f),
							AutomaticSize = Enum.AutomaticSize.X,
							BackgroundTransparency = 1,
							Text = p.text,
							TextSize = u.textSize - 1,
							skin = o.TEXT,
							FontFace = F.face(),
							ZIndex = y + 1,
							Parent = p.main,
						}
					)
					J.signal(p.title:GetPropertyChangedSignal("AbsoluteSize"), function()
						p:fit()
					end, "divider/fit")
					p:fit()
					return p
				end
				Z.fit = function(p)
					if not p.title then
						return
					end
					local J = p.title.AbsoluteSize.X / 2 + o.GAP
					p.left.Size = UDim2.new(0.5, -o.INSET - J, 0, 1)
					p.right.Size = UDim2.new(0.5, -o.INSET - J, 0, 1)
				end
				return o
			end
end)()

_registry["ui/components/label"] = (function()

return function(p)
				local J, O = p("ui/components/base"), p("ui/create")
				local u = p("ui/metrics")
				local F = p("ui/font")
				local f = p("ui/zindex")
				p("ui/skin")
				local p, o, Z = { PAD = 4 }, setmetatable, { __index = J }
				local J = o({}, Z)
				J.__index = J
				p.new = function(o)
					o = if typeof(o) == "string" then { text = o } else o
					o = typeof(o) == "table" and o or {}
					return setmetatable(
						{
							type = "label",
							text = tostring(o.text or ""),
							tip = o.tip and tostring(o.tip) or nil,
							subcount = 0,
							hasInit = false,
						},
						J
					)
				end
				p.Label = J
				J.Get = function(o)
					return o.text
				end
				J.Set = function(o, Z)
					o.text = tostring(Z or "")
					if o.hasInit then
						o.main.Text = o.text
					end
					return o
				end
				J.Init = function(J, o)
					if J.hasInit or not o then
						return J
					end
					J.hasInit = true
					local Z = J.zbase or f.WIDGET
					J.main = O.new(
						"TextLabel",
						{
							Name = "Label",
							LayoutOrder = J.position or 0,
							Size = UDim2.new(1, -u.controlX * 2, 0, 0),
							Position = UDim2.fromOffset(u.controlX, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							Text = J.text,
							TextSize = u.textSize,
							skin = "body",
							FontFace = F.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
							TextWrapped = true,
							ZIndex = Z,
							Parent = o,
						}
					)
					O.new("UIPadding", { PaddingBottom = UDim.new(0, p.PAD), Parent = J.main })
					J.interest = J.main
					if J.tip then
						J:mountTooltip()
					end
					return J
				end
				return p
			end
end)()

_registry["ui/components/list"] = (function()

return function(p)
				local J, O = p("ui/components/base"), p("ui/checker")
				local u = p("ui/skin")
				local F = p("ui/connect")
				local f = p("ui/create")
				local o = p("ui/icon")
				local Z = p("ui/metrics")
				local i = p("ui/motion")
				local y = p("ui/popup")
				local P = p("ui/theme")
				local b = p("ui/font")
				local I, h =
					p("ui/zindex"),
					{
						LABEL_H = 18,
						LABEL_GAP = 4,
						FIELD_H = 26,
						PAD_LEFT = 10,
						PAD_RIGHT = 24,
						ROW_H = 22,
						ICON_GAP = 5,
						HINT_ICON = 12,
						HINT_GAP = 5,
						HINT_INNER = 2,
						HINT_FADE = 0.45,
						PANEL_ROWS = 16,
						SWATCH = 14,
						SWATCH_PAD = 6,
						EDITOR_PAD = 8,
						SQUARE_H = 92,
						STRIP_H = 11,
						STRIP_GAP = 7,
						KNOB = 9,
					}
				h.EDITOR_H = h.SQUARE_H + (h.STRIP_GAP + h.STRIP_H) * 2 + h.EDITOR_PAD
				h.SEARCH_H = 24
				h.SEARCH_PAD = 6
				h.RULE_FADE = 0.75
				h.SEARCH_FROM = 1
				h.ORDER_SEARCH = 0
				h.ORDER_RULE = 1
				h.ORDER_ROWS = 2
				h.EMPTY = "none"
				local p, A = setmetatable, { __index = J }
				local J = p({}, A)
				J.__index = J
				h.new = function(p)
					p = typeof(p) == "table" and p or {}
					local A, T = tostring(p.text or "list"), {}
					if typeof(p.values) == "table" then
						for r, r in ipairs(p.values) do
							table.insert(T, tostring(r))
						end
					end
					local r = setmetatable(
						{
							type = "list",
							text = A,
							tip = p.tip and tostring(p.tip) or nil,
							flag = tostring(p.flag or A),
							values = T,
							multi = p.multi == true,
							colors = typeof(p.colors) == "table" and p.colors or nil,
							onColor = typeof(p.onColor) == "function" and p.onColor or nil,
							icons = typeof(p.icons) == "table" and p.icons or nil,
							hints = typeof(p.hints) == "function" and p.hints or nil,
							labels = typeof(p.labels) == "table" and p.labels or nil,
							onPeek = typeof(p.onPeek) == "function" and p.onPeek or nil,
							onPick = typeof(p.onPick) == "function" and p.onPick or nil,
							icon = p.icon and tostring(p.icon) or nil,
							gapBefore = math.max(0, tonumber(p.gapBefore) or 0),
							onRefresh = typeof(p.onRefresh) == "function" and p.onRefresh or nil,
							callback = typeof(p.callback) == "function" and p.callback or nil,
							subcount = 0,
							hasInit = false,
							adornY = math.max(0, tonumber(p.gapBefore) or 0) + h.LABEL_H // 2,
						},
						J
					)
					r.chosen = {}
					if r.multi and typeof(p.value) == "table" then
						for A, A in ipairs(p.value) do
							r.chosen[tostring(A)] = true
						end
					elseif p.value ~= nil then
						r.chosen[tostring(p.value)] = true
					end
					return r
				end
				h.List = J
				J.Get = function(p)
					if not p.multi then
						for A, A in ipairs(p.values) do
							if p.chosen[A] then
								return A
							end
						end
						return nil
					end
					local A = {}
					for T, T in ipairs(p.values) do
						if p.chosen[T] then
							table.insert(A, T)
						end
					end
					return A
				end
				J.labelOf = function(p, A)
					return p.labels and p.labels[A] or A
				end
				J.summary = function(p)
					if not p.multi then
						local A = p:Get()
						return A and p:labelOf(A) or h.EMPTY
					end
					local A = p:Get()
					if #A == 0 then
						return h.EMPTY
					end
					local T = {}
					for r, r in ipairs(A) do
						T[#T + 1] = p:labelOf(r)
					end
					return table.concat(T, ", ")
				end
				J.isChosen = function(p, A)
					return p.chosen[A] == true
				end
				J.choose = function(p, A)
					if p.multi then
						p.chosen[A] = not p.chosen[A] or nil
					else
						p.chosen = { [A] = true }
					end
					p:refresh()
					p:commit()
					if p.onPick then
						pcall(p.onPick, p:Get())
					end
					if not p.multi and p.popup then
						p.popup:Close()
					end
				end
				J.commit = function(p, A)
					if p.onChanged then
						p.onChanged(p.flag, p:Get())
					end
					if not A and p.callback then
						pcall(p.callback, p:Get())
					end
				end
				J.Set = function(p, A, T)
					p.chosen = {}
					if typeof(A) == "table" then
						for r, r in ipairs(A) do
							p.chosen[tostring(r)] = true
						end
					elseif A ~= nil then
						p.chosen[tostring(A)] = true
					end
					p:refresh()
					p:commit(T)
					return p
				end
				J.refresh = function(p)
					if not p.hasInit then
						return
					end
					p.field.Text = p:summary()
					for A, T in pairs(p.marks) do
						T(p:isChosen(A))
					end
				end
				J.Init = function(p, A)
					if p.hasInit or not A then
						return p
					end
					p.hasInit = true
					local T, r = p.zbase or I.WIDGET, p.gapBefore or 0
					p.main = f.new(
						"Frame",
						{
							Name = "List",
							LayoutOrder = p.position or 0,
							Size = UDim2.new(1, 0, 0, r + h.LABEL_H + h.LABEL_GAP + h.FIELD_H),
							BackgroundTransparency = 1,
							ZIndex = T,
							Parent = A,
						}
					)
					p.title = f.new(
						"TextLabel",
						{
							Name = "Title",
							Position = UDim2.fromOffset(Z.controlX, r),
							Size = UDim2.new(1, -Z.controlX, 0, h.LABEL_H),
							BackgroundTransparency = 1,
							Text = p.text,
							TextSize = Z.textSize,
							skin = "body",
							FontFace = b.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = T + 1,
							Parent = p.main,
						}
					)
					if p.icon then
						A = o.size()
						local I = A + h.ICON_GAP
						f.new(
							"ImageLabel",
							{
								Name = "Glyph",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromOffset(Z.controlX, r + h.LABEL_H // 2),
								Size = UDim2.fromOffset(A, A),
								BackgroundTransparency = 1,
								skin = "dim",
								ImageContent = o.get(p.icon),
								ZIndex = T + 1,
								Parent = p.main,
							}
						)
						p.title.Position = UDim2.fromOffset(Z.controlX + I, r)
						p.title.Size = UDim2.new(1, -(Z.controlX + I), 0, h.LABEL_H)
					end
					p.field = f.new(
						"TextButton",
						{
							Name = "Field",
							Position = UDim2.fromOffset(Z.controlX, r + h.LABEL_H + h.LABEL_GAP),
							Size = UDim2.new(1, -Z.controlX * 2, 0, h.FIELD_H - 2),
							skin = { BackgroundColor3 = "field", TextColor3 = "body" },
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = p:summary(),
							TextSize = Z.textSize - 2,
							FontFace = b.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ClipsDescendants = true,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = T + 1,
							Parent = p.main,
						}
					)
					f.new("UICorner", { CornerRadius = UDim.new(0, Z.corner - 1), Parent = p.field })
					p.stroke = f.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = Z.stroke,
							skin = "stroke",
							Parent = p.field,
						}
					)
					f.new(
						"UIPadding",
						{
							PaddingLeft = UDim.new(0, h.PAD_LEFT),
							PaddingRight = UDim.new(0, h.PAD_RIGHT),
							Parent = p.field,
						}
					)
					r, A = o.dimensions("tooltipArrow")
					p.caret = f.new(
						"ImageLabel",
						{
							Name = "Caret",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.fromOffset(r or 7, A or 12),
							BackgroundTransparency = 1,
							ImageContent = o.get("tooltipArrow"),
							skin = "hint",
							Rotation = 270,
							ZIndex = T + 2,
							Parent = p.field,
						}
					)
					p.marks = {}
					p.rows = {}
					p:wire()
					p:adorn()
					p:reserveLabel()
					return p
				end
				J.editor = function(p, I, A, T)
					local r = f.new(
						"Frame",
						{
							Name = "Editor",
							Position = UDim2.fromOffset(h.PAD_LEFT, h.ROW_H),
							Size = UDim2.new(1, -(h.PAD_LEFT + h.EDITOR_PAD), 0, h.EDITOR_H - h.EDITOR_PAD),
							BackgroundTransparency = 1,
							Visible = false,
							ZIndex = p.popup.zbase + 1,
							Parent = I,
						}
					)
					local S = f.new(
						"Frame",
						{
							Name = "Square",
							Size = UDim2.new(1, 0, 0, h.SQUARE_H),
							BorderSizePixel = 0,
							ZIndex = p.popup.zbase + 1,
							Parent = r,
						}
					)
					local c, R = f.new, {}
					R.CornerRadius, R.Parent = UDim.new(0, Z.corner), S
					c("UICorner", R)
					c, R, I =
						f.new(
							"Frame",
							{
								Name = "White",
								Size = UDim2.fromScale(1, 1),
								BackgroundColor3 = Color3.new(1, 1, 1),
								BorderSizePixel = 0,
								ZIndex = p.popup.zbase + 2,
								Parent = S,
							}
						),
						f.new,
						{}
					I.CornerRadius, I.Parent = UDim.new(0, Z.corner), c
					R("UICorner", I)
					I, R = f.new, {}
					R.Transparency, R.Parent = NumberSequence.new(0, 1), c
					I("UIGradient", R)
					R, c, I =
						f.new(
							"Frame",
							{
								Name = "Shade",
								Size = UDim2.fromScale(1, 1),
								BackgroundColor3 = Color3.new(),
								BorderSizePixel = 0,
								ZIndex = p.popup.zbase + 3,
								Parent = S,
							}
						),
						f.new,
						{}
					I.CornerRadius, I.Parent = UDim.new(0, Z.corner), R
					c("UICorner", I)
					I, c = f.new, { Rotation = 90 }
					c.Transparency, c.Parent = NumberSequence.new(1, 0), R
					I("UIGradient", c)
					local e = f.new(
						"Frame",
						{
							Name = "Dot",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Size = UDim2.fromOffset(h.KNOB, h.KNOB),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BorderSizePixel = 0,
							ZIndex = p.popup.zbase + 4,
							Parent = S,
						}
					)
					I, c = f.new, {}
					c.CornerRadius, c.Parent = UDim.new(1, 0), e
					I("UICorner", c)
					I, c = f.new, { Thickness = 1 }
					c.Color, c.Transparency, c.Parent = Color3.new(), 0.35, e
					I("UIStroke", c)
					R, c, I =
						f.new(
							"Frame",
							{
								Name = "Hue",
								Position = UDim2.fromOffset(0, h.SQUARE_H + h.STRIP_GAP),
								Size = UDim2.new(1, 0, 0, h.STRIP_H),
								BorderSizePixel = 0,
								ZIndex = p.popup.zbase + 1,
								Parent = r,
							}
						),
						f.new,
						{}
					I.CornerRadius, I.Parent = UDim.new(1, 0), R
					c("UICorner", I)
					I, c = f.new, {}
					c.Color, c.Parent =
						ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
							ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
							ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
							ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
						}),
						R
					I("UIGradient", c)
					local function G(q)
						local w, H, Q =
							f.new(
								"Frame",
								{
									Name = "Mark",
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0, 0.5),
									Size = UDim2.new(0, 4, 1, 2),
									BackgroundColor3 = Color3.new(1, 1, 1),
									BorderSizePixel = 0,
									ZIndex = p.popup.zbase + 3,
									Parent = q,
								}
							),
							f.new,
							{}
						Q.CornerRadius, Q.Parent = UDim.new(1, 0), w
						H("UICorner", Q)
						q, Q = f.new, { Thickness = 1 }
						Q.Color, Q.Transparency, Q.Parent = Color3.new(), 0.35, w
						q("UIStroke", Q)
						return w
					end
					local q = G(R)
					c = h.SQUARE_H + (h.STRIP_GAP + h.STRIP_H) + h.STRIP_GAP
					local w, H, Q =
						f.new(
							"ImageLabel",
							{
								Name = "AlphaChecker",
								Position = UDim2.fromOffset(0, c),
								Size = UDim2.new(1, 0, 0, h.STRIP_H),
								BackgroundTransparency = 1,
								ZIndex = p.popup.zbase + 1,
								Parent = r,
							}
						),
						f.new,
						{}
					Q.CornerRadius, Q.Parent = UDim.new(1, 0), w
					H("UICorner", Q)
					O.paint(w)
					local O = f.new(
						"Frame",
						{
							Name = "Alpha",
							Position = UDim2.fromOffset(0, c),
							Size = UDim2.new(1, 0, 0, h.STRIP_H),
							BorderSizePixel = 0,
							ZIndex = p.popup.zbase + 2,
							Parent = r,
						}
					)
					I, H = f.new, {}
					H.CornerRadius, H.Parent = UDim.new(1, 0), O
					I("UICorner", H)
					local I = f.new("UIGradient", { Transparency = NumberSequence.new(1, 0), Parent = O })
					local c = G(O)
					local G, w, H = T.BackgroundColor3:ToHSV()
					p.alphas = p.alphas or {}
					local Q = p.alphas[A] or 1
					local function Y()
						local E = Color3.fromHSV(G, w, H)
						S.BackgroundColor3 = Color3.fromHSV(G, 1, 1)
						T.BackgroundColor3 = E
						T.BackgroundTransparency = 1 - Q
						O.BackgroundColor3 = E
						I.Transparency = NumberSequence.new(1, 0)
						e.Position = UDim2.fromScale(w, 1 - H)
						q.Position = UDim2.fromScale(G, 0.5)
						c.Position = UDim2.fromScale(Q, 0.5)
						p.colors[A] = E
						p.alphas[A] = Q
						local I = p.onColor
						if I then
							p.onColor(A, E, Q)
						end
					end
					local function I(A, T)
						local c = false
						local function e(q)
							local E, s = A.AbsolutePosition, A.AbsoluteSize
							T(
								s.X > 0 and math.clamp((q.Position.X - E.X) / s.X, 0, 1) or 0,
								s.Y > 0 and math.clamp((q.Position.Y - E.Y) / s.Y, 0, 1) or 0
							)
							Y()
						end
						F.signal(A.InputBegan, function(T)
							if T.UserInputType ~= Enum.UserInputType.MouseButton1 then
								return
							end
							y.hold(p.popup)
							c = true
							e(T)
						end, "list/editor")
						F.signal(A.InputChanged, function(p)
							local T = c and p.UserInputType == Enum.UserInputType.MouseMovement
							if T then
								e(p)
							end
						end, "list/editormove")
						F.signal(A.InputEnded, function(p)
							local A = p.UserInputType == Enum.UserInputType.MouseButton1
							if A then
								c = false
							end
						end, "list/editorup")
					end
					I(S, function(p, A)
						local T
						T, w = 1 - A, p
						H = T
					end)
					I(R, function(p)
						G = p
					end)
					I(O, function(p)
						Q = p
					end)
					Y()
					return r
				end
				J.row = function(p, O, I, A)
					local T = f.new(
						"TextButton",
						{
							Name = "Row",
							LayoutOrder = I,
							Size = UDim2.new(1, 0, 0, h.ROW_H),
							skin = "rowGlow",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = "",
							ZIndex = p.popup.zbase,
							Parent = O,
						}
					)
					p.rows[A] = T
					I, O = f.new, {}
					O.CornerRadius, O.Parent = UDim.new(0, Z.corner), T
					I("UICorner", O)
					local r = 0
					I = p.colors and p.colors[A] or nil
					if I then
						r = h.SWATCH + h.SWATCH_PAD
						local S = f.new(
							"TextButton",
							{
								Name = "Swatch",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -h.SWATCH_PAD, 0, h.ROW_H // 2),
								Size = UDim2.fromOffset(h.SWATCH, h.SWATCH),
								BackgroundColor3 = I,
								BorderSizePixel = 0,
								AutoButtonColor = false,
								Text = "",
								ZIndex = p.popup.zbase + 2,
								Parent = T,
							}
						)
						local c, R = f.new, {}
						R.CornerRadius, R.Parent = UDim.new(0, Z.corner), S
						c("UICorner", R)
						f.new("UIStroke", { Thickness = 1, skin = "border", Parent = S })
						local c
						local R = false
						F.signal(S.MouseButton1Click, function()
							y.hold(p.popup)
							local e = not c
							if e then
								c = p:editor(T, A, S)
								T.ClipsDescendants = true
							end
							R = not R
							e = R
							if e then
								c.Visible = true
							end
							local S, e, G = i.to, i.STATE, {}
							G.Size = UDim2.new(1, 0, 0, R and h.ROW_H + h.EDITOR_H or h.ROW_H)
							S(T, e, G)
							e = not R
							if e then
								task.delay(0.15, function()
									local S = c and not R
									if S then
										c.Visible = false
									end
								end)
							end
						end, "list/swatch")
					else
					end
					local S, c = 0
					O = p.icons and p.icons[A] or nil
					if O then
						I = o.size()
						S = I + h.ICON_GAP
						c = f.new(
							"ImageLabel",
							{
								Name = "Glyph",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromOffset(h.PAD_LEFT, h.ROW_H // 2),
								Size = UDim2.fromOffset(I, I),
								BackgroundTransparency = 1,
								skin = "hint",
								ImageContent = o.get(O),
								ZIndex = p.popup.zbase + 1,
								Parent = T,
							}
						)
					else
					end
					local R, e, G = p.onPeek and o.size() + h.PAD_LEFT or 0
					if p.hints then
						I, O = pcall(p.hints, A)
						G = if I and typeof(O) == "table" and #O > 0 then O else G
					else
					end
					if G then
						e = f.new(
							"Frame",
							{
								Name = "Hints",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -(h.PAD_LEFT + r + R), 0, h.ROW_H // 2),
								Size = UDim2.fromOffset(0, h.ROW_H),
								AutomaticSize = Enum.AutomaticSize.X,
								BackgroundTransparency = 1,
								ZIndex = p.popup.zbase + 1,
								Parent = T,
							}
						)
						I, O =
							f.new,
							{
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}
						O.Padding, O.Parent = UDim.new(0, h.HINT_GAP), e
						I("UIListLayout", O)
						for I, q in ipairs(G) do
							local G, w, H, Q =
								q.faded == true and h.HINT_FADE or 0,
								f.new(
									"Frame",
									{
										Name = "Mark",
										Size = UDim2.fromOffset(0, h.ROW_H),
										AutomaticSize = Enum.AutomaticSize.X,
										BackgroundTransparency = 1,
										LayoutOrder = I,
										ZIndex = p.popup.zbase + 1,
										Parent = e,
									}
								),
								f.new,
								{
									FillDirection = Enum.FillDirection.Horizontal,
									VerticalAlignment = Enum.VerticalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}
							Q.Padding, Q.Parent = UDim.new(0, h.HINT_INNER), w
							H("UIListLayout", Q)
							f.new(
								"ImageLabel",
								{
									Name = "Glyph",
									Size = UDim2.fromOffset(h.HINT_ICON, h.HINT_ICON),
									BackgroundTransparency = 1,
									skin = "hint",
									ImageTransparency = G,
									ImageContent = o.get(q.icon),
									LayoutOrder = 1,
									ZIndex = p.popup.zbase + 1,
									Parent = w,
								}
							)
							f.new(
								"TextLabel",
								{
									Name = "Text",
									Size = UDim2.fromOffset(0, h.ROW_H),
									AutomaticSize = Enum.AutomaticSize.X,
									BackgroundTransparency = 1,
									Text = tostring(q.text),
									TextSize = Z.textSize - 3,
									skin = "hint",
									TextTransparency = G,
									FontFace = b.face(),
									LayoutOrder = 2,
									ZIndex = p.popup.zbase + 1,
									Parent = w,
								}
							)
						end
					else
					end
					local I, G, q =
						f.new,
						{
							Name = "Label",
							Position = UDim2.fromOffset(h.PAD_LEFT + S, 0),
							Size = UDim2.new(1, -(h.PAD_LEFT * 2) - r - R - S, 0, h.ROW_H),
							BackgroundTransparency = 1,
						},
						A
					G.Text = p:labelOf(q)
					G.TextSize = Z.textSize - 1
					G.skin = "hint"
					G.FontFace = b.face()
					G.TextXAlignment = Enum.TextXAlignment.Left
					G.ClipsDescendants = true
					G.TextTruncate = Enum.TextTruncate.AtEnd
					G.ZIndex = p.popup.zbase + 1
					G.Parent = T
					local q = I("TextLabel", G)
					if e then
						local function I()
							q.Size = UDim2.new(
								1,
								-(h.PAD_LEFT * 2) - r - R - S - e.AbsoluteSize.X - h.HINT_GAP,
								0,
								h.ROW_H
							)
						end
						F.signal(e:GetPropertyChangedSignal("AbsoluteSize"), I, "list/hints")
						I()
					end
					O = f.new(
						"TextButton",
						{
							Name = "Hit",
							Size = UDim2.new(1, -r, 0, h.ROW_H),
							BackgroundTransparency = 1,
							AutoButtonColor = false,
							Text = "",
							ZIndex = p.popup.zbase + 1,
							Parent = T,
						}
					)
					F.signal(O.MouseButton1Click, function()
						y.hold(p.popup)
						p:choose(A)
					end, "list/pick")
					local O
					if p.onPeek then
						O = f.new(
							"ImageLabel",
							{
								Name = "Peek",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -h.PAD_LEFT - r, 0, h.ROW_H // 2),
								Size = UDim2.fromOffset(o.size(), o.size()),
								BackgroundTransparency = 1,
								ImageTransparency = 1,
								skin = "hint",
								ImageContent = o.get("speaker"),
								ZIndex = p.popup.zbase + 1,
								Parent = T,
							}
						)
					else
					end
					F.signal(T.InputBegan, function(I)
						if I.UserInputType == Enum.UserInputType.MouseMovement then
							if y.blocks(T) then
								return
							end
							i.to(T, i.HOVER_IN, { BackgroundTransparency = 0.92 })
							if O then
								i.to(O, i.HOVER_IN, { ImageTransparency = 0 })
							end
							if p.onPeek then
								pcall(p.onPeek, A)
							end
						end
					end, "list/row")
					F.signal(T.InputEnded, function(p)
						if p.UserInputType == Enum.UserInputType.MouseMovement then
							i.to(T, i.HOVER_OUT, { BackgroundTransparency = 1 })
							if O then
								i.to(O, i.HOVER_OUT, { ImageTransparency = 1 })
							end
						end
					end, "list/rowout")
					return function(p)
						local O = p and P.get() or u.get("hint")
						i.to(q, i.HOVER_IN, { TextColor3 = O })
						if c then
							i.to(c, i.HOVER_IN, { ImageColor3 = O })
						end
					end
				end
				J.SetValues = function(p, O)
					p.values = typeof(O) == "table" and O or {}
					O = {}
					for I, I in ipairs(p.values) do
						O[tostring(I)] = true
					end
					for I in pairs(p.chosen) do
						if not O[I] then
							p.chosen[I] = nil
						end
					end
					if p.popup and p.popup.content then
						for O, O in pairs(p.rows) do
							pcall(function()
								O:Destroy()
							end)
						end
						p.marks = {}
						p.rows = {}
						for O, I in ipairs(p.values) do
							p.marks[I] = p:row(p.popup.content, O + h.ORDER_ROWS - 1, I)
						end
						if p.search then
							p:filter(p.search.Text)
						end
					else
						p.marks = {}
						p.rows = {}
					end
					p:refresh()
					return p
				end
				J.buildSearch = function(p, O)
					if #p.values < h.SEARCH_FROM then
						return nil
					end
					p.search = f.new(
						"TextBox",
						{
							Name = "Search",
							LayoutOrder = h.ORDER_SEARCH,
							Size = UDim2.new(1, -(h.PAD_LEFT * 2), 0, h.SEARCH_H),
							BorderSizePixel = 0,
							Text = "",
							PlaceholderText = "search...",
							TextSize = Z.textSize - 2,
							FontFace = b.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ClearTextOnFocus = false,
							ClipsDescendants = true,
							TextTruncate = Enum.TextTruncate.AtEnd,
							skin = { BackgroundColor3 = "field", TextColor3 = "body", PlaceholderColor3 = "hint" },
							ZIndex = p.popup.zbase + 1,
							Parent = O,
						}
					)
					f.new("UICorner", { CornerRadius = UDim.new(0, Z.corner - 1), Parent = p.search })
					if p.onRefresh then
						local b = o.size()
						local I = f.new(
							"ImageButton",
							{
								Name = "Refresh",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -h.SEARCH_PAD, 0.5, 0),
								Size = UDim2.fromOffset(b, b),
								BackgroundTransparency = 1,
								AutoButtonColor = false,
								skin = "hint",
								ImageContent = o.get("refresh"),
								ZIndex = p.popup.zbase + 2,
								Parent = p.search,
							}
						)
						f.new(
							"UIPadding",
							{
								PaddingLeft = UDim.new(0, h.SEARCH_PAD),
								PaddingRight = UDim.new(0, b + h.SEARCH_PAD * 2),
								Parent = p.search,
							}
						)
						F.signal(I.MouseButton1Click, function()
							y.hold(p.popup)
							pcall(p.onRefresh)
							p.search.Text = ""
							p:filter("")
						end, "list/refresh")
						F.signal(I.InputBegan, function(o)
							if o.UserInputType == Enum.UserInputType.MouseMovement then
								if y.blocks(I) then
									return
								end
								local o, b, A = i.to, i.HOVER_IN, {}
								A.ImageColor3, A.Rotation = P.get(), 90
								o(I, b, A)
							end
						end, "list/refreshin")
						F.signal(I.InputEnded, function(o)
							if o.UserInputType == Enum.UserInputType.MouseMovement then
								local o, b, A = i.to, i.HOVER_OUT, {}
								A.ImageColor3, A.Rotation = u.get("hint"), 0
								o(I, b, A)
							end
						end, "list/refreshout")
					end
					f.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = Z.stroke,
							skin = "stroke",
							Parent = p.search,
						}
					)
					f.new(
						"UIPadding",
						{ PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = p.search }
					)
					P.follow(
						f.new(
							"Frame",
							{
								Name = "Rule",
								LayoutOrder = h.ORDER_RULE,
								Size = UDim2.new(1, -(h.PAD_LEFT * 2), 0, 1),
								BackgroundColor3 = P.get(),
								BackgroundTransparency = h.RULE_FADE,
								BorderSizePixel = 0,
								ZIndex = p.popup.zbase,
								Parent = O,
							}
						),
						"BackgroundColor3"
					)
					F.signal(p.search:GetPropertyChangedSignal("Text"), function()
						p:filter(p.search.Text)
					end, "list/search")
					F.signal(p.search.Focused, function()
						y.hold()
					end, "list/searchfocus")
					return p.search
				end
				J.filter = function(p, O)
					O = tostring(O or ""):lower()
					for f, o in pairs(p.rows) do
						o.Visible = O == "" or tostring(f):lower():find(O, 1, true) ~= nil
					end
				end
				J.buildPanel = function(p)
					if p.popup then
						return p.popup
					end
					local O = y.new(p.field)
					if not O then
						return nil
					end
					O.placement = "below"
					O.maxHeight = h.PANEL_ROWS * (h.ROW_H + Z.rowGap) + h.SEARCH_H + Z.rowGap + y.PAD * 2
					p.popup = O
					p:buildSearch(O.content)
					for f, o in ipairs(p.values) do
						p.marks[o] = p:row(O.content, f + h.ORDER_ROWS - 1, o)
					end
					O.onOpen = function()
						local f, o, Z, b = i.to, p.caret, i.HOVER_IN, { Rotation = 90 }
						b.ImageColor3 = P.get()
						f(o, Z, b)
						b, o, Z, f = i.to, p.stroke, i.HOVER_IN, {}
						f.Color = P.get()
						b(o, Z, f)
						if p.search then
							p.search.Text = ""
							p:filter("")
						end
					end
					O.onClose = function()
						local f, o, Z, P = i.to, p.caret, i.HOVER_OUT, { Rotation = 270 }
						P.ImageColor3 = u.get("hint")
						f(o, Z, P)
						P, f, o, Z = i.to, p.stroke, i.HOVER_OUT, {}
						Z.Color = u.get("stroke")
						P(f, o, Z)
					end
					p:refresh()
					return O
				end
				J.wire = function(p)
					F.signal(p.field.InputBegan, function(J)
						if J.UserInputType == Enum.UserInputType.MouseButton1 then
							local O = p:buildPanel()
							if O then
								O:Toggle()
							end
						elseif J.UserInputType == Enum.UserInputType.MouseMovement then
							if y.blocks(p.field) then
								return
							end
							if p.popup and p.popup.open then
								return
							end
							local J, O, f, o = i.to, p.stroke, i.HOVER_IN, {}
							o.Color = u.get("edge")
							J(O, f, o)
						end
					end, "list/open")
					F.signal(p.field.InputEnded, function(J)
						if J.UserInputType == Enum.UserInputType.MouseMovement then
							if p.popup and p.popup.open then
								return
							end
							local J, O, F, f = i.to, p.stroke, i.HOVER_OUT, {}
							f.Color = u.get("stroke")
							J(O, F, f)
						end
					end, "list/out")
				end
				return h
			end
end)()

_registry["ui/components/order"] = (function()

return function(p)
				local J, O = p("ui/components/base"), p("ui/connect")
				local u = p("ui/create")
				local F = p("ui/icon")
				local f = p("ui/metrics")
				local o = p("ui/motion")
				local Z = p("ui/popup")
				local i = p("ui/skin")
				local y = p("ui/theme")
				local P = p("ui/font")
				local b = p("ui/zindex")
				local I, h, A, T =
					p("core/service").get("UserInputService"),
					{
						LABEL_H = 18,
						LABEL_GAP = 4,
						FIELD_H = 26,
						PAD_LEFT = 10,
						PAD_RIGHT = 24,
						ROW_H = 22,
						ROW_GAP = 2,
						LIST_GAP = 6,
						ROW_PAD = 8,
						GRIP_W = 10,
						ROW_ICON = 12,
						CHECK = 12,
						PIECE_GAP = 6,
						DRAG_SLOP = 3,
						HELD_FADE = 0.86,
						HOVER_FADE = 0.92,
						EMPTY = "none",
					},
					setmetatable,
					{ __index = J }
				local p = A({}, T)
				p.__index = p
				local function J(A, T, r)
					local S, c = {}, {}
					for R, R in ipairs(A) do
						if T[R].locked then
							S[R] = true
							table.insert(c, R)
						end
					end
					if typeof(r) == "table" then
						for R, R in ipairs(r) do
							R = tostring(R)
							if T[R] and not S[R] then
								S[R] = true
								table.insert(c, R)
							end
						end
					end
					for T, T in ipairs(A) do
						if not S[T] then
							table.insert(c, T)
						end
					end
					return c, S
				end
				h.new = function(A)
					A = typeof(A) == "table" and A or {}
					local T, r, S, c, R = tostring(A.text or "order"), {}, {}, {}, 0
					if typeof(A.values) == "table" then
						for e, e in ipairs(A.values) do
							local G, q, w, H
							if typeof(e) == "table" then
								w = tostring(e.key or e.text or "")
								H, G = tostring(e.text or w), e.icon and tostring(e.icon) or nil
								q = e.locked == true
							else
								w = tostring(e)
								H = w
							end
							if w ~= "" and not S[w] then
								e = { key = w, text = H, icon = G, locked = q }
								S[w] = e
								table.insert(r, e)
								table.insert(c, w)
								R = if q then R + 1 else R
							else
							end
						end
					else
					end
					local e = setmetatable(
						{
							type = "order",
							text = T,
							tip = A.tip and tostring(A.tip) or nil,
							flag = tostring(A.flag or T),
							items = r,
							byKey = S,
							locked = R,
							callback = typeof(A.callback) == "function" and A.callback or nil,
							expanded = false,
							subcount = 0,
							hasInit = false,
							adornY = h.LABEL_H // 2,
						},
						p
					)
					e.order, e.chosen = J(c, S, typeof(A.value) == "table" and A.value or c)
					return e
				end
				h.Order = p
				p.Get = function(A)
					local T = {}
					for r, r in ipairs(A.order) do
						if A.chosen[r] then
							table.insert(T, r)
						end
					end
					return T
				end
				p.summary = function(A)
					local T = {}
					for r, S in ipairs(A.order) do
						if A.chosen[S] then
							r = A.byKey[S]
							table.insert(T, r and r.text or S)
						end
					end
					if #T == 0 then
						return h.EMPTY
					end
					return table.concat(T, ", ")
				end
				p.commit = function(A, T)
					if A.onChanged then
						A.onChanged(A.flag, A:Get())
					end
					if not T and A.callback then
						pcall(A.callback, A:Get())
					end
				end
				p.Set = function(A, T, r)
					local S = {}
					for c, c in ipairs(A.items) do
						table.insert(S, c.key)
					end
					A.order, A.chosen = J(S, A.byKey, T)
					A:relayout()
					A:refresh()
					A:commit(r)
					return A
				end
				p.indexOf = function(J, A)
					for T, r in ipairs(J.order) do
						if r == A then
							return T
						end
					end
					return 1
				end
				p.relayout = function(J)
					if not J.rows then
						return
					end
					for A, T in ipairs(J.order) do
						local r = J.rows[T]
						if r then
							r.LayoutOrder = A
						end
					end
				end
				p.refresh = function(J, A)
					if not J.hasInit then
						return
					end
					J.field.Text = J:summary()
					for T, r in pairs(J.marks) do
						r(J.chosen[T] == true, A)
					end
				end
				p.repaint = function(J)
					J:refresh(true)
				end
				p.measure = function(J)
					local A = h.LABEL_H + h.LABEL_GAP + h.FIELD_H
					if J.expanded then
						local T = #J.items
						local J = T * h.ROW_H + math.max(0, T - 1) * h.ROW_GAP
						A = A + h.LIST_GAP + J
					else
					end
					return A
				end
				p.resize = function(J)
					J.main.Size = UDim2.new(1, 0, 0, J:measure())
				end
				p.setExpanded = function(J, A)
					J.expanded = A and true or false
					J.holder.Visible = J.expanded
					J:resize()
					o.to(
						J.caret,
						o.HOVER_IN,
						{
							Rotation = J.expanded and 90 or 270,
							ImageColor3 = J.expanded and y.get() or i.get("hint"),
						}
					)
					local A, T, r, S = o.to, J.stroke, o.HOVER_IN, {}
					S.Color = J.expanded and y.get() or i.get("stroke")
					A(T, r, S)
				end
				p.paintRow = function(J, A)
					local T = J.rows and J.rows[A]
					if not T then
						return
					end
					local r, S, c, R = J.dragKey == A, o.to, o.HOVER_IN, {}
					R.BackgroundTransparency = r and h.HELD_FADE or 1
					S(T, c, R)
				end
				p.toggle = function(J, A)
					local T = J.byKey[A]
					if T and T.locked then
						return
					end
					J.chosen[A] = not J.chosen[A] or nil
					J:refresh()
					J:commit()
				end
				p.moveTo = function(J, A, T)
					local r = J:indexOf(A)
					if r == T then
						return
					end
					table.remove(J.order, r)
					table.insert(J.order, T, A)
					J:relayout()
					J.field.Text = J:summary()
				end
				p.row = function(J, A, T)
					local r = u.new(
						"TextButton",
						{
							Name = "Row_" .. T.key,
							Size = UDim2.new(1, 0, 0, h.ROW_H),
							skin = "rowGlow",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = "",
							ZIndex = J.zbase or b.WIDGET,
							Parent = A,
						}
					)
					J.rows[T.key] = r
					local S, c = u.new, {}
					c.CornerRadius, c.Parent = UDim.new(0, f.corner), r
					S("UICorner", c)
					u.new(
						"UIPadding",
						{ PaddingLeft = UDim.new(0, h.ROW_PAD), PaddingRight = UDim.new(0, h.ROW_PAD), Parent = r }
					)
					A, c = (J.zbase or b.WIDGET) + 1, not T.locked and F.get("grip") or nil
					if c then
						local R, e =
							u.new,
							{ Name = "Grip", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(
								0,
								0,
								0.5,
								0
							) }
						e.Size, e.BackgroundTransparency, e.ImageContent, e.skin, e.ZIndex, e.Parent =
							UDim2.fromOffset(h.GRIP_W, h.ROW_ICON), 1, c, "dim", A, r
						R("ImageLabel", e)
					end
					c = T.icon and F.get(T.icon) or nil
					if c then
						u.new(
							"ImageLabel",
							{
								Name = "Glyph",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, h.GRIP_W + h.PIECE_GAP, 0.5, 0),
								Size = UDim2.fromOffset(h.ROW_ICON, h.ROW_ICON),
								BackgroundTransparency = 1,
								ImageContent = c,
								skin = "hint",
								ZIndex = A,
								Parent = r,
							}
						)
					end
					S = h.GRIP_W + h.PIECE_GAP + h.ROW_ICON + h.PIECE_GAP
					local c = u.new(
						"TextLabel",
						{
							Name = "Label",
							Position = UDim2.fromOffset(S, 0),
							Size = UDim2.new(1, -(S + (T.locked and 0 or h.CHECK + h.PIECE_GAP)), 1, 0),
							BackgroundTransparency = 1,
							Text = T.text,
							TextSize = f.textSize - 1,
							skin = not T.locked and "hint" or nil,
							TextColor3 = T.locked and y.get() or nil,
							FontFace = P.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ClipsDescendants = true,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = A,
							Parent = r,
						}
					)
					if T.locked then
						y.follow(c, "TextColor3")
						return function() end
					end
					local R, e, G =
						u.new(
							"Frame",
							{
								Name = "Check",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, 0, 0.5, 0),
								Size = UDim2.fromOffset(h.CHECK, h.CHECK),
								skin = "field",
								BorderSizePixel = 0,
								ZIndex = A,
								Parent = r,
							}
						),
						u.new,
						{}
					G.CornerRadius, G.Parent = UDim.new(0, f.corner - 2), R
					e("UICorner", G)
					local e = u.new("UIStroke", { Thickness = f.stroke, skin = "stroke", Parent = R })
					local G = y.follow(
						u.new(
							"Frame",
							{
								Name = "Fill",
								Size = UDim2.fromScale(1, 1),
								BackgroundColor3 = y.get(),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								ZIndex = A + 1,
								Parent = R,
							}
						),
						"BackgroundColor3"
					)
					S, A = u.new, {}
					A.CornerRadius, A.Parent = UDim.new(0, f.corner - 2), G
					S("UICorner", A)
					O.signal(r.InputBegan, function(A)
						if A.UserInputType == Enum.UserInputType.MouseButton1 then
							Z.hold()
							if T.locked then
								return
							end
							J.dragKey = T.key
							J.dragFrom = J:indexOf(T.key)
							J.dragY = A.Position.Y
							J.dragMoved = false
							J:paintRow(T.key)
						elseif A.UserInputType == Enum.UserInputType.MouseMovement then
							if Z.blocks(r) then
								return
							end
							if J.dragKey then
								return
							end
							o.to(r, o.HOVER_IN, { BackgroundTransparency = h.HOVER_FADE })
						end
					end, "order/rowdown")
					O.signal(r.InputEnded, function(A)
						if A.UserInputType == Enum.UserInputType.MouseMovement then
							if J.dragKey == T.key then
								return
							end
							o.to(r, o.HOVER_OUT, { BackgroundTransparency = 1 })
						end
					end, "order/rowout")
					return function(J, A)
						if A then
							G.BackgroundTransparency = J and 0 or 1
							c.TextColor3 = J and i.get("body") or i.get("hint")
							e.Color = J and y.get() or i.get("stroke")
							return
						end
						local T, r, S = o.to, o.HOVER_IN, {}
						S.BackgroundTransparency = J and 0 or 1
						T(G, r, S)
						r, T, A = o.to, o.HOVER_IN, {}
						A.TextColor3 = J and i.get("body") or i.get("hint")
						r(c, T, A)
						r, S, A = o.to, o.HOVER_IN, {}
						A.Color = J and y.get() or i.get("stroke")
						r(e, S, A)
					end
				end
				p.Init = function(J, y)
					if J.hasInit or not y then
						return J
					end
					J.hasInit = true
					local A = J.zbase or b.WIDGET
					J.main = u.new(
						"Frame",
						{
							Name = "Order",
							LayoutOrder = J.position or 0,
							Size = UDim2.new(1, 0, 0, h.LABEL_H + h.LABEL_GAP + h.FIELD_H),
							BackgroundTransparency = 1,
							ZIndex = A,
							Parent = y,
						}
					)
					J.title = u.new(
						"TextLabel",
						{
							Name = "Title",
							Position = UDim2.fromOffset(f.controlX, 0),
							Size = UDim2.new(1, -f.controlX, 0, h.LABEL_H),
							BackgroundTransparency = 1,
							Text = J.text,
							TextSize = f.textSize,
							skin = "body",
							FontFace = P.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = A + 1,
							Parent = J.main,
						}
					)
					J.field = u.new(
						"TextButton",
						{
							Name = "Field",
							Position = UDim2.fromOffset(f.controlX, h.LABEL_H + h.LABEL_GAP),
							Size = UDim2.new(1, -f.controlX * 2, 0, h.FIELD_H - 2),
							skin = { BackgroundColor3 = "field", TextColor3 = "body" },
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = J:summary(),
							TextSize = f.textSize - 2,
							FontFace = P.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ClipsDescendants = true,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = A + 1,
							Parent = J.main,
						}
					)
					u.new("UICorner", { CornerRadius = UDim.new(0, f.corner - 1), Parent = J.field })
					J.stroke = u.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = f.stroke,
							skin = "stroke",
							Parent = J.field,
						}
					)
					u.new(
						"UIPadding",
						{
							PaddingLeft = UDim.new(0, h.PAD_LEFT),
							PaddingRight = UDim.new(0, h.PAD_RIGHT),
							Parent = J.field,
						}
					)
					local P, b = F.dimensions("tooltipArrow")
					J.caret = u.new(
						"ImageLabel",
						{
							Name = "Caret",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.fromOffset(P or 7, b or 12),
							BackgroundTransparency = 1,
							ImageContent = F.get("tooltipArrow"),
							skin = "hint",
							Rotation = 270,
							ZIndex = A + 2,
							Parent = J.field,
						}
					)
					J.holder = u.new(
						"Frame",
						{
							Name = "Rows",
							Position = UDim2.fromOffset(
								f.controlX,
								h.LABEL_H + h.LABEL_GAP + h.FIELD_H + h.LIST_GAP
							),
							Size = UDim2.new(1, -f.controlX * 2, 0, 0),
							BackgroundTransparency = 1,
							Visible = false,
							ZIndex = A,
							Parent = J.main,
						}
					)
					u.new(
						"UIListLayout",
						{ SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, h.ROW_GAP), Parent = J.holder }
					)
					J.rows = {}
					J.marks = {}
					for u, u in ipairs(J.items) do
						J.marks[u.key] = J:row(J.holder, u)
					end
					J:relayout()
					y = #J.items
					J.holder.Size =
						UDim2.new(1, -f.controlX * 2, 0, y * h.ROW_H + math.max(0, y - 1) * h.ROW_GAP)
					J:wire()
					J:adorn()
					J:reserveLabel()
					J.title.Size = UDim2.new(J.title.Size.X.Scale, J.title.Size.X.Offset, 0, h.LABEL_H)
					J:refresh()
					return J
				end
				p.wire = function(p)
					O.signal(p.field.InputBegan, function(J)
						if J.UserInputType == Enum.UserInputType.MouseButton1 then
							Z.hold()
							p:setExpanded(not p.expanded)
						elseif J.UserInputType == Enum.UserInputType.MouseMovement then
							if Z.blocks(p.field) then
								return
							end
							if p.expanded then
								return
							end
							local J, u, F, f = o.to, p.stroke, o.HOVER_IN, {}
							f.Color = i.get("edge")
							J(u, F, f)
						end
					end, "order/open")
					O.signal(p.field.InputEnded, function(J)
						if J.UserInputType == Enum.UserInputType.MouseMovement then
							if p.expanded then
								return
							end
							local J, u, F, f = o.to, p.stroke, o.HOVER_OUT, {}
							f.Color = i.get("stroke")
							J(u, F, f)
						end
					end, "order/fieldout")
					O.signal(I.InputChanged, function(J)
						if not p.dragKey then
							return
						end
						if J.UserInputType ~= Enum.UserInputType.MouseMovement then
							return
						end
						local u = J.Position.Y - p.dragY
						if math.abs(u) > h.DRAG_SLOP then
							p.dragMoved = true
						end
						J = h.ROW_H + h.ROW_GAP
						local F = math.floor(u / J + 0.5)
						u = math.clamp(p.dragFrom + F, p.locked + 1, #p.order)
						p:moveTo(p.dragKey, u)
					end, "order/drag")
					O.signal(I.InputEnded, function(J)
						if not p.dragKey then
							return
						end
						if J.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						local J, O = p.dragKey, p.dragMoved
						p.dragKey = nil
						p.dragMoved = false
						p:paintRow(J)
						if O then
							p:commit()
						else
							p:toggle(J)
						end
					end, "order/drop")
				end
				return h
			end
end)()

_registry["ui/components/slider"] = (function()

local Runtime = { [14] = table.pack }
function Runtime:oh(values) return table.unpack(values, 1, values.n) end
function Runtime:Wh(destination, offset, ...)
    local values = table.pack(...)
    table.move(values, 1, values.n, offset + 1, destination)
end
function Runtime:Lh(destination, offset, values)
    table.move(values, 1, values.n, offset + 1, destination)
    destination.n = offset + values.n
end

local p = Runtime

return function(J)
				local O, u = J("ui/components/base"), J("ui/skin")
				local F = J("ui/connect")
				local f = J("ui/create")
				local o = J("ui/metrics")
				local Z = J("ui/motion")
				local i = J("ui/popup")
				local y = J("ui/theme")
				local P = J("ui/font")
				local b = J("ui/zindex")
				local I = J("core/service").get("UserInputService")
				local J, h = {
					LABEL_H = 18,
					LABEL_GAP = 4,
					LANE_H = 20,
					TRACK = 4,
					GRAB_W = 10,
					GRAB_H = 17,
					BOX_W = 72,
					BOX_GAP = 8,
					TRACK_COLOR = "line",
					TRACK_HOVER = "edge",
					GRAB_COLOR = "grab",
					TEXT = "body",
					GRAB_TINT = 0.45,
					BUBBLE_H = 18,
					BUBBLE_GAP = 6,
					DRAG = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					STEP = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					WHEEL_DIR = -1,
				}
				local A = false
				local function T()
					local r = A
					if r then
						return
					end
					A = true
					F.signal(I.InputChanged, function(A)
						local r = h
						if not r then
							return
						end
						if A.UserInputType ~= Enum.UserInputType.MouseMovement then
							return
						end
						h.slider:dragTo(I:GetMouseLocation().X)
					end, "slider/move")
					F.signal(I.InputEnded, function(A)
						local r = h
						if not r then
							return
						end
						if A.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						h.slider:release()
						h = nil
					end, "slider/up")
				end
				local A, r = setmetatable, { __index = O }
				local O = A({}, r)
				O.__index = O
				J.new = function(A)
					A = typeof(A) == "table" and A or {}
					local r, S, c, R =
						tostring(A.text or "slider"), tonumber(A.min) or 0, tonumber(A.max) or 100, {}
					if typeof(A.labels) == "table" then
						for e, e in ipairs(A.labels) do
							table.insert(R, tostring(e))
						end
					end
					local e, G =
						setmetatable(
							{
								type = "slider",
								text = r,
								tip = A.tip and tostring(A.tip) or nil,
								flag = tostring(A.flag or r),
								min = S,
								max = c,
								labels = R,
								top = c + #R,
								suffix = A.suffix and tostring(A.suffix) or "",
								step = math.max(1, tonumber(A.step) or 1),
								range = A.range == true,
								rangeable = A.rangeable == true or A.range == true,
								callback = typeof(A.callback) == "function" and A.callback or nil,
								subcount = 0,
								hasInit = false,
								adornY = J.LABEL_H // 2,
							},
							O
						),
						tonumber(A.value) or S
					e.low = e:clamp(G)
					e.high = e:clamp(tonumber(A.high) or e.top)
					return e
				end
				J.Slider = O
				O.clamp = function(A, r)
					r = math.floor(tonumber(r) or A.min)
					return math.clamp(r, A.min, A.top)
				end
				O.snap = function(A, r)
					local S = A.min + math.floor((r - A.min) / A.step + 0.5) * A.step
					return A:clamp(S)
				end
				O.format = function(A, r, S)
					if r > A.max then
						return A.labels[r - A.max] or tostring(r)
					end
					return tostring(r) .. (S and "" or A.suffix)
				end
				O.Get = function(A)
					if A.range then
						return { A.low, A.high }
					end
					return A.low
				end
				O.parse = function(A, r)
					if typeof(r) ~= "string" then
						return nil
					end
					local S = r:match("^%s*(.-)%s*$"):lower()
					if S == "" then
						return nil
					end
					for c, R in ipairs(A.labels) do
						if R:lower() == S then
							return A.max + c
						end
					end
					r = A.suffix:lower()
					local c = if r ~= "" and S:sub(-#r) == r
						then S:sub(1, #S - #r):match("^%s*(.-)%s*$")
						else S
					if not c:match("^%-?%d+$") then
						return nil
					end
					r = p[14](tonumber(c))
					return A:clamp(p:oh(r))
				end
				local function p(A, r)
					local S = A.top - A.min
					if S <= 0 then
						return 0
					end
					return (r - A.min) / S
				end
				O.pulse = function(A)
					Z.cancel(A.pulseTween)
					A.box.TextColor3 = y.get()
					A.pulseTween = Z.to(A.box, Z.HOVER_OUT, { TextColor3 = u.get("body") })
				end
				O.showValue = function(A, r, S)
					if A.editing then
						return
					end
					A:paintValue()
					if r and not (A.low > A.max or A.range and A.high > A.max) then
						Z.cancel(A.countLowTween)
						Z.cancel(A.countHighTween)
						A.countLowTween = Z.to(A.counterLow, r, { Value = A.low })
						A.countHighTween = Z.to(A.counterHigh, r, { Value = A.high })
					else
						A.counterLow.Value = A.low
						A.counterHigh.Value = A.high
						A:paintValue()
					end
					if S then
						A:pulse()
					end
				end
				O.paintValue = function(A)
					local r, S = A:clamp(A.counterLow.Value), A:clamp(A.counterHigh.Value)
					if not A.editing then
						A.box.Text = A.range and ("%s-%s"):format(A:format(r, true), A:format(S))
							or A:format(r)
					end
					local c = h and h.slider == A and h.which or "low"
					A.bubble.Text = A:format(c == "high" and S or r)
				end
				O.redraw = function(A, r, S)
					if not A.hasInit then
						return
					end
					local c = p(A, A.low)
					local R = A.range and p(A, A.high) or c
					local e, G = math.min(c, R), math.max(c, R)
					local q, w, H, Q =
						UDim2.fromScale(A.range and e or 0, 0),
						UDim2.new(A.range and G - e or G, 0, 1, 0),
						UDim2.new(c, 0, 0.5, 0),
						UDim2.new(R, 0, 0.5, 0)
					if r then
						Z.to(A.fill, r, { Position = q, Size = w })
						Z.to(A.grabLow, r, { Position = H })
						Z.to(A.grabHigh, r, { Position = Q })
					else
						A.fill.Position = q
						A.fill.Size = w
						A.grabLow.Position = H
						A.grabHigh.Position = Q
					end
					A.grabHigh.Visible = A.range
					A:moveBubble(r)
					A:showValue(r, S)
				end
				O.Init = function(A, r)
					if A.hasInit or not r then
						return A
					end
					A.hasInit = true
					local S, c = A.zbase or b.WIDGET, A.text == nil or A.text == ""
					local b = c and 0 or J.LABEL_H + J.LABEL_GAP
					A.laneY = b
					A.main = f.new(
						"Frame",
						{
							Name = "Slider",
							LayoutOrder = A.position or 0,
							Size = UDim2.new(1, 0, 0, b + J.LANE_H),
							BackgroundTransparency = 1,
							ZIndex = S,
							Parent = r,
						}
					)
					if not c then
						A.title = f.new(
							"TextLabel",
							{
								Name = "Title",
								Position = UDim2.fromOffset(o.controlX, 0),
								Size = UDim2.new(1, -o.controlX, 0, J.LABEL_H),
								BackgroundTransparency = 1,
								Text = A.text,
								TextSize = o.textSize,
								skin = J.TEXT,
								FontFace = P.face(),
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = S + 1,
								Parent = A.main,
							}
						)
					end
					A.counterLow =
						f.new("NumberValue", { Name = "CounterLow", Value = A.low, Parent = A.main })
					A.counterHigh =
						f.new("NumberValue", { Name = "CounterHigh", Value = A.high, Parent = A.main })
					A.box = f.new(
						"TextBox",
						{
							Name = "Value",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -o.controlX, 0, A.laneY + J.LANE_H // 2),
							Size = UDim2.fromOffset(J.BOX_W, J.LANE_H - 2),
							BorderSizePixel = 0,
							Text = "",
							TextSize = o.textSize - 2,
							skin = { BackgroundColor3 = "field", TextColor3 = J.TEXT },
							FontFace = P.face(),
							ClearTextOnFocus = false,
							ClipsDescendants = true,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = S + 1,
							Parent = A.main,
						}
					)
					f.new("UICorner", { CornerRadius = UDim.new(0, o.corner - 1), Parent = A.box })
					A.boxStroke = f.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = o.stroke,
							skin = "stroke",
							Parent = A.box,
						}
					)
					A.lane = f.new(
						"Frame",
						{
							Name = "Lane",
							Position = UDim2.fromOffset(o.controlX, A.laneY),
							Size = UDim2.new(1, -(o.controlX * 2 + J.BOX_W + J.BOX_GAP), 0, J.LANE_H),
							BackgroundTransparency = 1,
							ZIndex = S + 1,
							Parent = A.main,
						}
					)
					A.track = f.new(
						"Frame",
						{
							Name = "Track",
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.fromScale(0, 0.5),
							Size = UDim2.new(1, 0, 0, J.TRACK),
							skin = J.TRACK_COLOR,
							BorderSizePixel = 0,
							ZIndex = S + 1,
							Parent = A.lane,
						}
					)
					f.new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = A.track })
					A.fill = y.follow(
						f.new(
							"Frame",
							{
								Name = "Fill",
								Size = UDim2.fromScale(0, 1),
								BackgroundColor3 = y.get(),
								BorderSizePixel = 0,
								ZIndex = S + 2,
								Parent = A.track,
							}
						),
						"BackgroundColor3"
					)
					f.new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = A.fill })
					f.new(
						"UIGradient",
						{ Color = ColorSequence.new(Color3.fromRGB(55, 55, 55), Color3.new(1, 1, 1)), Parent = A.fill }
					)
					A.grabLow = A:makeGrab(S + 3, "GrabLow")
					A.grabHigh = A:makeGrab(S + 3, "GrabHigh")
					A.grabHigh.Visible = false
					A:makeBubble(S + 4)
					A:wire()
					A:adorn()
					A:reserveLabel()
					A:redraw(nil)
					return A
				end
				O.makeGrab = function(b, A, r)
					local S, c, R =
						f.new(
							"Frame",
							{
								Name = r,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Size = UDim2.fromOffset(J.GRAB_W, J.GRAB_H),
								skin = J.GRAB_COLOR,
								BorderSizePixel = 0,
								ZIndex = A,
								Parent = b.lane,
							}
						),
						f.new,
						{}
					R.CornerRadius, R.Parent = UDim.new(0, 3), S
					c("UICorner", R)
					f.new("UIStroke", { Thickness = 1, skin = "hard", Transparency = 0.7, Parent = S })
					return S
				end
				O.makeBubble = function(b, A)
					b.bubble = f.new(
						"TextLabel",
						{
							Name = "Bubble",
							AnchorPoint = Vector2.new(0.5, 1),
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.fromOffset(0, J.BUBBLE_H),
							BorderSizePixel = 0,
							Text = "",
							TextSize = o.textSize - 2,
							skin = { BackgroundColor3 = "raised", TextColor3 = "text" },
							FontFace = P.face(),
							Visible = false,
							ZIndex = A,
							Parent = b.lane,
						}
					)
					f.new("UICorner", { CornerRadius = UDim.new(0, o.corner), Parent = b.bubble })
					b.bubbleStroke = f.new(
						"UIStroke",
						{
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Thickness = o.stroke,
							skin = "border",
							Transparency = 1,
							Parent = b.bubble,
						}
					)
					f.new(
						"UIPadding",
						{ PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), Parent = b.bubble }
					)
				end
				O.dragTo = function(f, o)
					local P, b = f.lane.AbsolutePosition.X, f.lane.AbsoluteSize.X
					if b <= 0 then
						return
					end
					local A = math.clamp((o - P) / b, 0, 1)
					P, b = f:snap(f.min + A * (f.top - f.min)), h and h.which == "high"
					if b then
						f.high = math.max(P, f.low)
					elseif f.range then
						f.low = math.min(P, f.high)
					else
						f.low = P
					end
					f:redraw(J.DRAG)
					f:commit()
				end
				O.nearest = function(f, o)
					if not f.range then
						return "low"
					end
					local P, b = f.lane.AbsolutePosition.X, f.lane.AbsoluteSize.X
					if b <= 0 then
						return "low"
					end
					local A = math.clamp((o - P) / b, 0, 1)
					b = math.abs(A - p(f, f.low))
					return math.abs(A - p(f, f.high)) < b and "high" or "low"
				end
				O.grabHeld = function(f, o, P)
					local b, A, r = o == "high" and f.grabHigh or f.grabLow, Z.to, P and Z.PRESS
					o, f = r or Z.RELEASE, {}
					f.BackgroundColor3 = P and y.get():Lerp(Color3.new(1, 1, 1), J.GRAB_TINT) or J.GRAB_COLOR
					A(b, o, f)
				end
				O.moveBubble = function(f, o)
					if not f.bubble.Visible then
						return
					end
					local P = h and h.which or "low"
					local b = P == "high" and f.high or f.low
					P = UDim2.new(p(f, b), 0, 0.5, -(J.GRAB_H // 2) - J.BUBBLE_GAP)
					if o then
						Z.to(f.bubble, o, { Position = P })
					else
						f.bubble.Position = P
					end
				end
				O.showBubble = function(p, f)
					local o = { BackgroundTransparency = f and 0 or 1, TextTransparency = f and 0 or 1 }
					if f then
						p.bubble.Visible = true
						p.bubble.BackgroundTransparency = 1
						p.bubble.TextTransparency = 1
						p:moveBubble(nil)
						Z.to(p.bubble, Z.HOVER_IN, o)
						Z.to(p.bubbleStroke, Z.HOVER_IN, { Transparency = 0 })
						return
					end
					f = Z.to(p.bubble, Z.HOVER_OUT, o)
					Z.to(p.bubbleStroke, Z.HOVER_OUT, { Transparency = 1 })
					if f then
						f.Completed:Once(function()
							local f = not h or h.slider ~= p
							if f then
								p.bubble.Visible = false
							end
						end)
					else
						p.bubble.Visible = false
					end
				end
				O.release = function(p)
					p:grabHeld(h and h.which or "low", false)
					p:showBubble(false)
				end
				O.setRange = function(p, f)
					p.range = f and true or false
					if p.range and p.high <= p.low then
						p.high = p:clamp(p.top)
					end
					p:redraw(J.STEP, true)
					p:commit()
				end
				O.commit = function(p, f)
					if p.onChanged then
						p.onChanged(p.flag, p:Get())
					end
					if not f and p.callback then
						pcall(p.callback, p:Get())
					end
				end
				O.Set = function(p, f, o)
					local P, b, A
					if typeof(f) == "table" then
						A, P = tonumber(f[1]), tonumber(f[2])
						b = o == true
					else
						if typeof(o) == "number" then
							A, P = tonumber(f), o
						else
							A, b = (tonumber(f)), o == true
						end
					end
					if A ~= nil then
						p.low = p:clamp(A)
					end
					if P ~= nil then
						p.high = p:clamp(P)
					end
					p:redraw(J.STEP, true)
					p:commit(b)
					return p
				end
				O.scroll = function(p, f)
					local o = p.range and "high" or "low"
					o = if p.range then p:nearest(I:GetMouseLocation().X) else o
					local P = p:clamp((o == "high" and p.high or p.low) + f * p.step)
					if o == "high" then
						p.high = math.max(P, p.low)
					else
						p.low = p.range and math.min(P, p.high) or P
					end
					p:redraw(J.STEP, true)
					p:commit()
				end
				local function p(f)
					local o = f.Parent
					while o do
						if o:IsA("ScrollingFrame") then
							return o
						end
						o = o.Parent
					end
					return nil
				end
				O.suppressScroll = function(f, o)
					if not f.scroller then
						return
					end
					if o then
						if f.scrollWas == nil then
							f.scrollWas = f.scroller.ScrollingEnabled
						end
						f.scroller.ScrollingEnabled = false
					elseif f.scrollWas ~= nil then
						f.scroller.ScrollingEnabled = f.scrollWas
						f.scrollWas = nil
					end
				end
				O.wire = function(f)
					T()
					f.scroller = p(f.main)
					F.signal(f.counterLow.Changed, function()
						f:paintValue()
					end, "slider/countlow")
					F.signal(f.counterHigh.Changed, function()
						f:paintValue()
					end, "slider/counthigh")
					F.signal(f.lane.InputBegan, function(p)
						local o = p.UserInputType == Enum.UserInputType.MouseButton1
						if o then
							local o = I:GetMouseLocation().X
							local P = f:nearest(o)
							h = { slider = f, which = P }
							f:grabHeld(P, true)
							f:showBubble(true)
							f:dragTo(o)
						elseif p.UserInputType == Enum.UserInputType.MouseButton3 then
							if f.rangeable then
								f:setRange(not f.range)
							end
						elseif p.UserInputType == Enum.UserInputType.MouseMovement then
							if i.blocks(f.lane) then
								return
							end
							f:suppressScroll(true)
							local p, o, P, b = Z.to, f.track, Z.HOVER_IN, {}
							b.BackgroundColor3 = u.get(J.TRACK_HOVER)
							p(o, P, b)
						end
					end, "slider/down")
					F.signal(f.lane.InputChanged, function(p)
						if p.UserInputType == Enum.UserInputType.MouseWheel then
							f:scroll(p.Position.Z * J.WHEEL_DIR)
						end
					end, "slider/wheel")
					F.signal(f.lane.InputEnded, function(p)
						if p.UserInputType == Enum.UserInputType.MouseMovement then
							f:suppressScroll(false)
							local p, o, P, b = Z.to, f.track, Z.HOVER_OUT, {}
							b.BackgroundColor3 = u.get(J.TRACK_COLOR)
							p(o, P, b)
						end
					end, "slider/out")
					F.signal(f.box.InputBegan, function(p)
						if p.UserInputType == Enum.UserInputType.MouseButton1 then
							i.hold()
						end
					end, "slider/boxdown")
					F.signal(f.box.Focused, function()
						i.hold()
						f.editing = true
						local p, o, i, P = Z.to, f.boxStroke, Z.HOVER_IN, {}
						P.Color = y.get()
						p(o, i, P)
					end, "slider/focus")
					F.signal(f.box.FocusLost, function()
						f.editing = false
						local p, F, o, i = Z.to, f.boxStroke, Z.HOVER_OUT, {}
						i.Color = u.get("stroke")
						p(F, o, i)
						f:apply(f.box.Text)
					end, "slider/blur")
				end
				O.apply = function(p, O)
					if p.range then
						local u, F = O:match("^%s*(.-)%s*%-%s*(.-)%s*$")
						if u and F then
							local f, o = p:parse(u), p:parse(F)
							if f and o then
								p.low, p.high = math.min(f, o), math.max(f, o)
								p:redraw(J.STEP, true)
								p:commit()
								return
							end
						end
					end
					local u = p:parse(O)
					if u then
						p.low = u
						if p.range and p.high < p.low then
							p.high = p.low
						end
						p:commit()
					end
					p:redraw(J.STEP, true)
				end
				return J
			end
end)()

_registry["ui/components/toggle"] = (function()

return function(p)
				local J, O = p("ui/components/base"), p("ui/skin")
				local u = p("ui/connect")
				local F = p("ui/create")
				local f = p("ui/metrics")
				local o = p("ui/motion")
				local Z = p("ui/popup")
				local i = p("ui/theme")
				local y = p("ui/font")
				local P, b, I, h =
					p("ui/zindex"),
					{ TEXT_ON = "muted", TEXT_OFF = "faint", TEXT_LOCKED = "disabled", BOX_OFF = "control" },
					setmetatable,
					{ __index = J }
				local p = I({}, h)
				p.__index = p
				b.new = function(J)
					J = typeof(J) == "table" and J or {}
					local I = tostring(J.text or "toggle")
					return setmetatable(
						{
							type = "toggle",
							text = I,
							tip = J.tip and tostring(J.tip) or nil,
							flag = tostring(J.flag or I),
							disabled = J.disabled == true,
							state = J.disabled ~= true and J.state == true,
							callback = typeof(J.callback) == "function" and J.callback or nil,
							subcount = 0,
							hasInit = false,
						},
						p
					)
				end
				p.Get = function(J)
					return J.state
				end
				p.Init = function(J, I)
					if J.hasInit or not I then
						return J
					end
					J.hasInit = true
					local h, A, T = f.control, f.labelX(), J.zbase or P.WIDGET
					J.main = F.new(
						"Frame",
						{
							Name = "Toggle",
							LayoutOrder = J.position or 0,
							Size = UDim2.new(1, 0, 0, f.row),
							skin = "rowGlow",
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ZIndex = T,
							Parent = I,
						}
					)
					F.new("UICorner", { CornerRadius = UDim.new(0, f.corner), Parent = J.main })
					J.box = i.follow(
						F.new(
							"Frame",
							{
								Name = "Box",
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromOffset(f.controlX + h // 2, f.row // 2),
								Size = UDim2.fromOffset(h, h),
								BackgroundColor3 = i.get(),
								BorderSizePixel = 0,
								ZIndex = T,
								Parent = J.main,
							}
						),
						"BackgroundColor3"
					)
					F.new("UICorner", { CornerRadius = UDim.new(0, f.corner), Parent = J.box })
					J.stroke = F.new("UIStroke", { Thickness = f.stroke, skin = "hard", Parent = J.box })
					J.overlay = F.new(
						"Frame",
						{
							Name = "Overlay",
							Size = UDim2.fromScale(1, 1),
							skin = b.BOX_OFF,
							BackgroundTransparency = J.state and 1 or 0,
							BorderSizePixel = 0,
							ZIndex = T + 1,
							Parent = J.box,
						}
					)
					F.new("UICorner", { CornerRadius = UDim.new(0, f.corner), Parent = J.overlay })
					J.interest = F.new(
						"Frame",
						{
							Name = "Hit",
							Size = UDim2.new(1, 0, 0, f.row),
							BackgroundTransparency = 1,
							ZIndex = T + 2,
							Parent = J.main,
						}
					)
					J.hit = J.interest
					J.title = F.new(
						"TextLabel",
						{
							Name = "Title",
							Position = UDim2.new(0, A, 0, 0),
							Size = UDim2.new(1, -A, 1, 0),
							BackgroundTransparency = 1,
							Text = J.text,
							TextSize = f.textSize,
							skin = J.disabled and b.TEXT_LOCKED or (J.state and b.TEXT_ON or b.TEXT_OFF),
							FontFace = y.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = T + 2,
							Parent = J.interest,
						}
					)
					J:wire()
					J:adorn()
					J:reserveLabel()
					return J
				end
				p.highlight = function(J, F)
					local y, P, I, h = F and o.HOVER_IN or o.HOVER_OUT, o.to, J.stroke, {}
					h.Color = F and i.get() or O.get("hard")
					P(I, y, h)
					P, h, I = o.to, J.main, {}
					I.BackgroundTransparency = F and f.rowHover or 1
					P(h, y, I)
				end
				p.press = function(J, F)
					o.cancel(J.pressTween)
					local i = f.control * (F and f.pressScale or 1)
					J.pressTween = o.to(J.box, F and o.PRESS or o.RELEASE, { Size = UDim2.fromOffset(i, i) })
				end
				p.wire = function(J)
					if J.disabled then
						return
					end
					u.signal(J.interest.InputBegan, function(F)
						if F.UserInputType == Enum.UserInputType.MouseButton1 then
							J:press(true)
							J:Set(not J.state)
						elseif F.UserInputType == Enum.UserInputType.MouseMovement then
							if Z.blocks(J.interest) then
								return
							end
							J:highlight(true)
						end
					end, "toggle/begin")
					u.signal(J.interest.InputEnded, function(u)
						if u.UserInputType == Enum.UserInputType.MouseButton1 then
							J:press(false)
						elseif u.UserInputType == Enum.UserInputType.MouseMovement then
							J:press(false)
							J:highlight(false)
						end
					end, "toggle/end")
				end
				p.repaint = function(J)
					if not J.hasInit then
						return
					end
					o.cancel(J.stateTween)
					J.stateTween = nil
					J.overlay.BackgroundTransparency = J.state and 1 or 0
					local u, F, f, Z =
						O.paint,
						J.title,
						{},
						J.disabled and b.TEXT_LOCKED or (J.state and b.TEXT_ON or b.TEXT_OFF)
					f.TextColor3 = Z
					u(F, f)
				end
				p.Set = function(J, u, F)
					if J.disabled then
						return J
					end
					J.state = u == true
					if J.hasInit then
						J.stateTween =
							o.to(J.overlay, o.STATE, { BackgroundTransparency = J.state and 1 or 0 })
						local u, f, Z, i = o.to, J.title, o.STATE, {}
						i.TextColor3 = O.get(J.state and b.TEXT_ON or b.TEXT_OFF)
						u(f, Z, i)
					end
					if J.onChanged then
						J.onChanged(J.flag, J.state)
					end
					if not F and J.callback then
						pcall(J.callback, J.state)
					end
					return J
				end
				b.Toggle = p
				return b
			end
end)()

_registry["ui/connect"] = (function()

local J = setstackhidden

return function(p)
				local O = p("core/blind")
				local u = p("core/log")
				local F = p("game/guard")
				local p, f, o, Z, i = F.CLOCKED, pcall, { DIAGNOSTICS = true }, {}
				local y, P = 32, 0
				local function b()
					local I, h = #Z, 0
					for A = 1, I, 1 do
						local T = Z[A]
						if T.Connected then
							h += 1
							Z[h] = T
						else
						end
					end
					for A = h + 1, I, 1 do
						Z[A] = nil
					end
				end
				local function I(h)
					if typeof(setfenv) ~= "function" or typeof(getfenv) ~= "function" then
						return
					end
					local A, T = f(getfenv, h)
					if not A or typeof(T) ~= "table" then
						return
					end
					A = not i
					if A then
						i = O.env(T)
					end
					f(setfenv, h, i)
				end
				local function O(i)
					local h
					local h = J
					if typeof(h) ~= "function" then
						return false
					end
					h = J
					return (f(h, i, true))
				end
				local J = typeof(debug) == "table"
						and typeof(debug.getmemorycategory) == "function"
						and debug.getmemorycategory
					or nil
				local i = typeof(debug) == "table"
						and typeof(debug.setmemorycategory) == "function"
						and debug.setmemorycategory
					or nil
				local function h()
					if not J or not i then
						return
					end
					local A, T = f(J)
					if A and T == "" then
						f(i, "Interface")
					end
				end
				o.signal = function(J, i, A)
					if typeof(i) ~= "function" then
						return nil
					end
					local T
					local r = false
					local function S(...)
						local c = r
						if c then
							return
						end
						h()
						local c, R, e = p and os.clock() or nil, f(i, ...)
						if c then
							F.charge("connect/" .. tostring(A or "?"), os.clock() - c)
						end
						c = not R
						if c then
							r = true
							if T then
								f(function()
									T:Disconnect()
								end)
							end
							if o.DIAGNOSTICS then
								u.fail(
									"connect",
									"connection %s disarmed: %s",
									tostring(A or "?"),
									tostring(e)
								)
							end
						end
					end
					I(S)
					O(S)
					local p, F = f(function()
						return J:Connect(S)
					end)
					if not p or not F then
						return nil
					end
					T = F
					P += 1
					p = P >= y
					if p then
						P = 0
						f(b)
					end
					table.insert(Z, T)
					return T
				end
				o.thread = function(p, ...)
					if typeof(p) ~= "function" then
						return
					end
					local function J(...)
						h()
						local F, i = f(p, ...)
						if not F and o.DIAGNOSTICS then
							u.fail("connect", "thread errored: %s", tostring(i))
						end
					end
					I(J)
					O(J)
					return task.spawn(J, ...)
				end
				o.count = function()
					return #Z
				end
				o.disconnectAll = function()
					for p = #Z, 1, -1 do
						f(function()
							Z[p]:Disconnect()
						end)
						Z[p] = nil
					end
					P = 0
				end
				return o
			end
end)()

_registry["ui/create"] = (function()

local J = Drawing

return function(p)
				local O = p("ui/skin")
				local u, F, f, o =
					p("ui/zindex"),
					{ ALLOW_DRAWING = true },
					{ Line = true, Text = true, Image = true, Circle = true, Square = true, Quad = true, Triangle = true },
					{}
				local function p()
					return setmetatable({}, {
						__index = function()
							return nil
						end,
						__newindex = function() end,
					})
				end
				F.new = function(Z, i)
					if not Z then
						return nil
					end
					local y = f[Z] == true
					if y and not F.ALLOW_DRAWING then
						return p()
					end
					local f
					if y then
						local P
						local P = J
						f = P
					else
						f = y
					end
					local J = f or Instance
					local f, P = pcall(function()
						return J.new(Z)
					end)
					if not f or not P then
						return y and p() or nil
					end
					local p, J
					if i then
						for f, Z in next, i, nil do
							if f == "Parent" then
								p = Z
							else
								if f == "skin" then
									J = Z
								else
									pcall(function()
										P[f] = Z
									end)
								end
							end
						end
					else
					end
					if p ~= nil then
						pcall(function()
							P.Parent = p
						end)
					end
					if J and not y then
						O.paint(P, J)
					end
					table.insert(o, { object = P, drawing = y })
					return P
				end
				local p = 0
				F.forget = function()
					p += 1
				end
				F.count = function()
					local J, O = #o, p
					return J - O
				end
				F.destroyAll = function()
					for p = #o, 1, -1 do
						local J = o[p]
						if J.drawing then
							pcall(function()
								J.object:Remove()
							end)
						else
							pcall(function()
								J.object:Destroy()
							end)
						end
						o[p] = nil
					end
				end
				F.Z = u
				return F
			end
end)()

_registry["ui/customfont"] = (function()

local J = isfile
local O = writefile
local u = getcustomasset
local F = isfolder
local f = makefolder
local o = readfile
local Z = crypt
local i = delfile

return function(p)
				local y = p("core/http")
				local P, b, I, h, A =
					p("core/service").get("HttpService"),
					{ files = {} },
					"UILibrary/storage/fonts",
					{
						{ weight = 100, name = "Thin" },
						{ weight = 200, name = "ExtraLight" },
						{ weight = 300, name = "Light" },
						{ weight = 400, name = "Regular" },
						{ weight = 500, name = "Medium" },
						{ weight = 600, name = "SemiBold" },
						{ weight = 700, name = "Bold" },
						{ weight = 800, name = "ExtraBold" },
						{ weight = 900, name = "Heavy" },
					},
					{
						{ key = "normal", style = "normal", suffix = "", label = "" },
						{ key = "italic", style = "italic", suffix = "i", label = " Italic" },
					}
				b.report = {}
				b.uris = {}
				local p
				local function T(r)
					local S = p
					if not S then
						return
					end
					S = p
					S[r] = (S[r] or 0) + 1
				end
				local function r()
					local S
					local S, S, c = J, typeof(J) == "function"
					if S then
						local R
						local R = O
						c = typeof(R) == "function"
					else
						c = S
					end
					S = nil
					if c then
						local R
						local R = u
						S = typeof(R) == "function"
					else
						S = c
					end
					return S
				end
				local function S(c)
					local R
					local R, R, e, G = F, typeof(F) ~= "function"
					if R then
						e = R
					else
						local G = f
						e = typeof(G) ~= "function"
					end
					if e then
						return
					end
					e = nil
					for G in c:gmatch("[^/]+") do
						e = e and e .. "/" .. G or G
						G = F
						R = not G(e)
						if R then
							G = f
							pcall(G, e)
						end
					end
				end
				local F = { string.char(0, 1, 0, 0), "true", "ttcf", "OTTO" }
				local function f(c, R, e)
					local G = 0
					for q = 0, e - 1, 1 do
						local e = c:byte(R + q)
						if not e then
							return nil
						end
						G = G * 256 + e
					end
					return G
				end
				local function c(R)
					local e = f(R, 5, 2)
					if not e or e == 0 or e > 512 then
						return false
					end
					for G = 0, e - 1, 1 do
						local e = 13 + G * 16
						local G, q = f(R, e + 8, 4), f(R, e + 12, 4)
						if not G or not q then
							return false
						end
						if G + q > #R then
							return false
						end
					end
					return true
				end
				local function f(R)
					if typeof(R) ~= "string" or #R < 4 then
						return false
					end
					local e, G = R:sub(1, 4), false
					for q, q in ipairs(F) do
						if e == q then
							G = true
							break
						end
					end
					return G and (c(R))
				end
				local F = ".ok2"
				local function c(R)
					local e
					local e = o
					if typeof(e) ~= "function" then
						return "?"
					end
					e = o
					local G, q = pcall(e, R)
					if not G or typeof(q) ~= "string" then
						return "?"
					end
					return ("%dk"):format(#q // 1024)
				end
				local function R(e)
					local G
					local G = J
					if not G(e) then
						return false
					end
					G = J
					if G(e .. F) then
						return true
					end
					local q
					local q, q = o, typeof(o) == "function"
					if q then
						G = o
						local o, q = pcall(G, e)
						local G = o and (f(q))
						if G then
							local o
							pcall(O, e .. F, "1")
							return true
						end
					end
					return false
				end
				local function o(e)
					return y.fetchRaw(e, f)
				end
				local y, e = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", {}
				for G = 1, 64, 1 do
					e[y:byte(G)] = G - 1
				end
				local function y(G)
					local q
					local q, q = Z, typeof(Z) == "table"
					if q then
						local w = Z
						local H, Q = w.base64decode
						if H then
							Q = H
						else
							w = Z
							Q = w.base64_decode
						end
						if typeof(Q) == "function" then
							w, H = pcall(Q, G)
							if w and typeof(H) == "string" and #H > 0 then
								return H
							end
						end
					end
					if typeof(base64_decode) == "function" then
						local Z, w = pcall(base64_decode, G)
						if Z and typeof(w) == "string" and #w > 0 then
							return w
						end
					end
					local Z, w = G:gsub("[^A-Za-z0-9+/=]", ""), {}
					for H = 1, #Z, 4 do
						local Q, Y, E, s =
							e[Z:byte(H)] or 0, e[Z:byte(H + 1)] or 0, e[Z:byte(H + 2)], e[Z:byte(H + 3)]
						H = Q * 262144 + Y * 4096 + (E or 0) * 64 + (s or 0)
						G, Q, q = math.floor(H / 65536) % 256, math.floor(H / 256) % 256, H % 256
						if E == nil then
							w[#w + 1] = string.char(G)
						elseif s == nil then
							w[#w + 1] = string.char(G, Q)
						else
							w[#w + 1] = string.char(G, Q, q)
						end
					end
					return table.concat(w)
				end
				local function Z(e)
					if typeof(e) == "table" and typeof(e.b64) == "string" then
						local G = y(e.b64)
						if f(G) then
							return G, "art"
						end
						T("badart")
						return nil
					end
					if typeof(e) == "string" and e ~= "" then
						local f = o(e)
						if f then
							return f, "net"
						end
						T("nobytes")
						return nil
					end
					return nil
				end
				local function f(o, y)
					if R(y) then
						T("disk " .. c(y))
						return true
					end
					local c
					local c = J
					local R = c(y)
					if R then
						T("stale")
						local e
						c = i
						pcall(c, y)
						pcall(i, y .. F)
					end
					R, c = Z(o)
					if not R then
						return false
					end
					local Z
					o = O
					pcall(o, y, R)
					o = J
					if not o(y) then
						T("nowrite")
						return false
					end
					pcall(O, y .. F, "1")
					T(string.format("%s %dk", c, #R // 1024))
					return true
				end
				b.load = function(J, F)
					if typeof(J) ~= "table" then
						return nil
					end
					if not r() then
						return nil
					end
					p = {}
					local o, Z = pcall(function()
						S(I)
						local i, y, T, r = F or "Custom", {}, ipairs
						for r, S in T(h) do
							r = J[S.weight]
							r = if typeof(r) == "string" then { normal = r } else r
							r = if typeof(r) ~= "table" then {} else r
							local J = ipairs
							for c, R in J(A) do
								c = string.format("%s/%s-%d%s.ttf", I, i, S.weight, R.suffix)
								local J = f(r[R.key], c)
								if J then
									y[S.weight] = y[S.weight] or {}
									local J
									J, y[S.weight][R.key] = u, u(c)
									b.files[S.weight] = b.files[S.weight] or {}
									b.files[S.weight][R.key] = c
								end
							end
						end
						T = {}
						for J, f in ipairs(A) do
							J = nil
							for A, r in ipairs(h) do
								A = y[r.weight]
								if A and A[f.key] then
									J = A[f.key]
									break
								end
							end
							if J then
								for A, r in ipairs(h) do
									A = y[r.weight]
									J = A and A[f.key] or J
									table.insert(
										T,
										{ name = r.name .. f.label, weight = r.weight, style = f.style, assetId = J }
									)
								end
							end
						end
						if #T == 0 then
							return nil
						end
						y = string.format("%s/%s.json", I, i)
						local J
						local J = O
						J(y, P:JSONEncode({ name = i, faces = T }))
						T = u
						J = T(y)
						b.uris[i] = J
						return Font.new(J, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					end)
					local J, O = {}, p
					for u, f in pairs(O) do
						table.insert(J, string.format("%s x%d", u, f))
					end
					table.sort(J)
					table.insert(
						b.report,
						string.format("%s[%s]", F or "Custom", #J > 0 and table.concat(J, " ") or "nothing")
					)
					p = nil
					if not o or typeof(Z) ~= "Font" then
						return nil
					end
					return Z
				end
				return b
			end
end)()

_registry["ui/fade"] = (function()

return function(p)
				local p, J, O = {}, setmetatable, { __mode = "k" }
				local u = J({}, O)
				local function J(O, F)
					local f = u[O]
					return f and f[F] or nil
				end
				local function O(F, f, o)
					local Z = u[F]
					if not Z then
						Z = {}
						u[F] = Z
					else
					end
					Z[f] = o
				end
				local function F(f, o)
					local Z = u[f]
					if Z then
						Z[o] = nil
					end
				end
				local u, f =
					{ TextLabel = true, TextButton = true, TextBox = true },
					{ ImageLabel = true, ImageButton = true, ViewportFrame = true }
				p.record = function(o, Z, i)
					local y = J(Z, i)
					if y then
						if y < 1 then
							table.insert(o, { object = Z, property = i, original = y })
						end
						return
					end
					local J, y = pcall(function()
						return Z[i]
					end)
					if J and typeof(y) == "number" and y < 1 then
						table.insert(o, { object = Z, property = i, original = y })
					end
				end
				p.snapshot = function(J)
					local o = {}
					if not J then
						return o
					end
					local Z = J:GetDescendants()
					table.insert(Z, J)
					for i, i in ipairs(Z) do
						if i:IsA("UIStroke") then
							p.record(o, i, "Transparency")
						elseif i:IsA("GuiObject") then
							p.record(o, i, "BackgroundTransparency")
							J = i.ClassName
							if u[J] then
								p.record(o, i, "TextTransparency")
							end
							if f[J] then
								p.record(o, i, "ImageTransparency")
							end
							if J == "ScrollingFrame" then
								p.record(o, i, "ScrollBarImageTransparency")
							end
						end
					end
					return o
				end
				p.apply = function(J, u)
					local f = u <= 0
					for o, o in ipairs(J) do
						o.object[o.property] = o.original + (1 - o.original) * u
						if f then
							F(o.object, o.property)
						else
							O(o.object, o.property, o.original)
						end
					end
				end
				return p
			end
end)()

_registry["ui/font"] = (function()

return function(p)
				local J = p("ui/font_art")
				local O = p("ui/customfont")
				local u, F, f, o =
					p("ui/font_tiny5_art"),
					{
						families = {
							Arimo = true,
							SourceSansPro = true,
							Gotham = true,
							Inconsolata = true,
							Merriweather = true,
							Nunito = true,
							Ubuntu = true,
						},
						family = "Arimo",
					}
				F.MONO = "Inconsolata"
				F.PIXEL_STEP = 8
				local p = {}
				F.face = function(Z)
					local i = (f or F.family) .. (Z and "/b" or "/r")
					local y = p[i]
					if y then
						local P = p
						return P[i]
					end
					local P = Z and Enum.FontWeight.Bold or Enum.FontWeight.Regular
					Z, y = pcall(function()
						local b = f
						if b then
							local b, I = Font.new, f
							return b(I, P, Enum.FontStyle.Normal)
						end
						return Font.fromName(F.family, P, Enum.FontStyle.Normal)
					end)
					if not Z or not y then
						Z, y = pcall(function()
							return Font.fromEnum(Enum.Font.SourceSans)
						end)
					else
					end
					if not Z or not y then
						return nil
					end
					p[i] = y
					return y
				end
				F.setFamily = function(Z)
					if not F.families[Z] then
						return false
					end
					F.family = Z
					p = {}
					return true
				end
				local function Z(i)
					local y = {}
					for P, b in pairs(i.faces or {}) do
						y[P] = {}
						for i, I in pairs(b) do
							y[P][i] = { b64 = I }
						end
					end
					return y
				end
				F.loadCustom = function(i)
					local y = Z(J)
					if typeof(i) == "table" then
						for P, b in pairs(i) do
							b = if typeof(b) == "string" then { normal = b } else b
							if typeof(b) == "table" then
								y[P] = y[P] or {}
								for I, h in pairs(b) do
									if not y[P][I] then
										y[P][I] = h
									end
								end
							end
						end
					end
					i = J.family or "Menu"
					if not O.load(y, i) then
						return false
					end
					f = O.uris[i]
					i = f
					if not i then
						return false
					end
					p = {}
					return true
				end
				F.loadPixel = function()
					local J = o
					if J then
						return true
					end
					J = u.family or "Pixel"
					if not O.load(Z(u), J) then
						return false
					end
					o = O.uris[J]
					J = o
					return J ~= nil
				end
				F.pixel = function()
					local J = o
					if not J then
						return F.face(true)
					end
					J = o .. "/px"
					local u = p[J]
					if u then
						local u = p
						return u[J]
					end
					local u, f = pcall(function()
						local Z, i = Font.new, o
						return Z(i, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					end)
					if not u or not f then
						return F.face(true)
					end
					p[J] = f
					return f
				end
				F.mono = function()
					local J = F.MONO .. "/mono"
					local u = p[J]
					if u then
						local u = p
						return u[J]
					end
					local u, f = pcall(function()
						return Font.fromName(F.MONO, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					end)
					if not u or not f then
						return F.face()
					end
					p[J] = f
					return f
				end
				F.refresh = function(p)
					if not p then
						return 0
					end
					local J = F.face()
					if not J then
						return 0
					end
					local u = 0
					for f, f in ipairs(p:GetDescendants()) do
						u = if f:IsA("TextLabel")
								or f:IsA("TextButton")
								or f:IsA("TextBox")
							then if pcall(function()
									f.FontFace = J
								end)
								then u + 1
								else u
							else u
					end
					return u
				end
				F.report = function()
					if #O.report == 0 then
						return nil
					end
					return table.concat(O.report, " ")
				end
				return F
			end
end)()

_registry["ui/font_art"] = (function()
return function()
	return {
		family = "Verdana",
		faces = {
			[400] = {
				normal = "AAEAAAARAQAABAAQT1MvMkNSmCYAAAGYAAAAVlZETVh08XxtAAAD4AAABeBjbWFwDsKNaQAAGUgAAADSY3Z0IEyiQQIAAB74AAABmGZwZ203UdEpAAAaHAAAAfZnYXNwABcACQAAmsQAAAAQZ2x5Zi9CU3wAACGMAABtpGhkbXjh7wrBAAAJwAAAD4hoZWFk+5n0ywAAARwAAAA2aGhlYRNjCrgAAAFUAAAAJGhtdHh3p0vAAAAB8AAAAfBrZXJuO14/KQAAjzAAAAn8bG9jYegYzcIAACCQAAAA+m1heHAC7wN2AAABeAAAACBuYW1lHjI2tgAAmSwAAAF4cG9zdP9PAHgAAJqkAAAAIHByZXB5Zdj/AAAcFAAAAuMAAQAAAAJuFJlbEYdfDzz1ABsIAAAAAACqfkQpAAAAAOaV+Kv/wv5ZC5MGjAAAAAkAAgAAAAAAAAABAAAIC/5SAAAMLP/C/70LkwABAAAAAAAAAAAAAAAAAAAAfAABAAAAfABiAAcAAAAAAAIAEAAvAFYAAAIFAuMAAAAAAAEEEQGQAAUAAAWaBTMAAAElBZoFMwAAA6AAeAKnCAACCwYEAwUEBAIEAAAAAwAAAAAAAAAAAAAAAE1TICAAQAAgImUGHv5ZAMoICwGuAAAAAQAAAAAAAAgAAQAC0AAAAyYBIwOsAKgGjADDBRYAmwicAJUF0ABzAiYApAOiALUDogCTBRYApwaMANIC6QCTA6IAmQLpAP0Dov/iBRYAiQUWARYFFgChBRYApwUWAE0FFgC7BRYAiQUWAJoFFgB6BRYAcQOiAVoDogDmBowA/gaMAPUGjAEMBF0AoAgAALAFeAAaBXwAyAWWAHMGKgDIBQ8AyASZAMgGNABzBgMAyANeAIkDowAsBYsAzQR0AMgGvgDIBfwAyAZMAHME0wDIBkwAcwWQAMgFeACGBO4AAAXbALIFeAAaB+kAXAV7AEQE7AAGBXsAfgOiAO8DogBGA6IAqwaMALoFFv/8BRYBVATOAGgE/AC5BCsAaQT8AGwExABqAtAARAT8AGwFEAC5AjIArwLB/8IEvADBAjIAuwfIALkFEAC5BNsAagT8ALkE/ABsA2oAuQQrAG4DJwA+BRAAsQS8AD0GjABWBLwAPAS8AD0ENABdBRQArQOiAXoFFAC7BowAuwUWALsEVgCaBRYArARdALkFFgCJCAAAnwgAAJ8H0ACqBowA9QaMANcGjAD+BowBDAaMAPMFKACmBSgArgaMALIFFgCZCAAAmQOs/+0DrACWAib/7QImAKADogC6A6IAwgUWALsMLACVBowBIwLpAP0AAAABAAEBAQEBAAwA+Aj/AAgACP/+AAkACv/+AAoACv/+AAsAC//+AAwADP/+AA0ADf/9AA4ADv/9AA8AD//9ABAAD//9ABEAEf/9ABIAEv/8ABMAE//8ABQAFf/8ABUAFf/8ABYAFv/8ABcAF//7ABgAGP/7ABkAGv/7ABoAG//7ABsAG//7ABwAHP/6AB0AHf/6AB4AHv/6AB8AIP/6ACAAIP/6ACEAIf/5ACIAIv/5ACMAI//5ACQAJf/5ACUAJv/5ACYAJv/4ACcAJ//4ACgAKP/4ACkAKf/4ACoAK//4ACsAK//3ACwALP/3AC0ALf/3AC4ALv/3AC8AMP/3ADAAMf/2ADEAMf/2ADIAMv/2ADMAM//2ADQANP/2ADUANv/1ADYANv/1ADcAN//1ADgAOP/1ADkAOf/1ADoAO//0ADsAPP/0ADwAPf/0AD0APf/0AD4APv/0AD8AP//zAEAAQf/zAEEAQf/zAEIAQv/zAEMAQ//zAEQARP/yAEUARv/yAEYAR//yAEcAR//yAEgASP/yAEkASf/xAEoASv/xAEsATP/xAEwATf/xAE0ATf/xAE4ATv/wAE8AT//wAFAAUf/wAFEAUv/wAFIAUv/vAFMAU//vAFQAVP/vAFUAVf/vAFYAV//vAFcAWP/uAFgAWP/uAFkAWf/uAFoAWv/uAFsAXP/uAFwAXf/sAF0AXf/sAF4AXv/sAF8AX//sAGAAYP/sAGEAYv/rAGIAYv/rAGMAY//rAGQAZP/rAGUAZf/rAGYAZ//qAGcAaP/qAGgAaP/qAGkAaf/qAGoAav/qAGsAa//pAGwAbf/pAG0Abf/pAG4Abv/pAG8Ab//pAHAAcP/oAHEAcv/oAHIAcv/oAHMAc//oAHQAdP/oAHUAdf/nAHYAdv/nAHcAeP/nAHgAeP/nAHkAef/nAHoAev/mAHsAe//mAHwAff/mAH0Aff/mAH4Afv/mAH8Af//lAIAAgP/lAIEAgv/lAIIAg//lAIMAg//lAIQAhP/kAIUAhf/kAIYAhv/kAIcAiP/kAIgAiP/kAIkAif/jAIoAiv/jAIsAi//jAIwAjf/jAI0Ajv/jAI4Ajv/iAI8Aj//iAJAAkP/iAJEAkf/iAJIAk//iAJMAk//hAJQAlP/hAJUAlf/hAJYAlv/hAJcAmP/hAJgAmf/gAJkAmf/gAJoAm//gAJsAm//gAJwAnP/gAJ0Anv/fAJ4Anv/fAJ8AoP/fAKAAoP/fAKEAof/fAKIAo//eAKMApP/eAKQApP/eAKUApv/eAKYApv/eAKcAp//dAKgAqf/dAKkAqf/dAKoAq//dAKsAq//dAKwArP/cAK0Arv/cAK4Ar//cAK8AsP/cALAAsP/cALEAsf/bALIAsv/bALMAtP/bALQAtf/bALUAtv/bALYAtv/aALcAt//aALgAuf/aALkAuv/aALoAu//aALsAu//ZALwAvP/ZAL0Avf/ZAL4Av//ZAL8AwP/ZAMAAwf/YAMEAwf/YAMIAwv/YAMMAxP/YAMQAxf/YAMUAxf/XAMYAxv/XAMcAx//XAMgAyP/XAMkAyv/XAMoAy//WAMsAzP/WAMwAzP/WAM0Azf/WAM4Az//WAM8A0P/VANAA0P/VANEA0f/VANIA0v/VANMA0//VANQA1f/UANUA1f/UANYA1//UANcA1//UANgA2P/UANkA2v/TANoA2//TANsA3P/TANwA3P/TAN0A3f/TAN4A3v/SAN8A4P/SAOAA4P/SAOEA4v/SAOIA4v/SAOMA4//RAOQA5f/RAOUA5v/RAOYA5//RAOcA5//RAOgA6P/QAOkA6f/QAOoA6//QAOsA6//QAOwA7P/QAO0A7f/PAO4A7v/PAO8A8P/PAPAA8f/PAPEA8v/PAPIA8v/OAPMA8//OAPQA9P/OAPUA9v/OAPYA9//OAPcA9//NAPgA+P/NAPkA+f/NAPoA+//NAPsA/P/MAPwA/f/MAP0A/v/MAP4A/v/MAP8A///MAAAAHwAAAIAJDgkDBQUHBwsHAwQEBwcDBQMEBwcHBwcHBwcHBwQEBwcHBgoIBwgIBwYICAUFBwYJCAkHCQcHBwgICQcHBwQEBAcGBgYGBgYGAwYGAwMGAwkGBgYGBAYEBgYHBgYFBgUGBwcFBgUHCQkJBwcHBwcGBgcHCQQEAgIEBAcOBwMAAAoPCgQEBQgHCwcDBQUHCAQFBAUHBwcHBwcHBwcHBQUICAgGCgcHCAgGBggIBQUHBgkHCQcJCAcHCAcLBwcHBQUFCAYGBwcFBwcEBwcDAwcDCwcHBwcEBgQHBgcHBgYGBQYIBwUGBQcKCgoICAgICAYGCAcKBQUDAwUFBw8IBAAACxELBAQFCQcMCAMFBQcJBAUEBQcHBwcHBwcHBwcFBQkJCQYKCAgJCQcGCQgFBQgGCQgJBwkICAcICAsIBwgFBQUJBwcHBwYHBwQHBwMEBwMLBwcHBwUGBAcHCQcHBgcFBwkHBgcGBwsLCwkJCQkJBwcJBwsFBQMDBQUHEQkEAAAMEgwEBQYKCA0JAwUFCAkEBQQFCAgICAgICAgICAUFCQkJBwwICAkJCAcJCQUFCAcKCQoICggIBwkIDQgHCAUFBQoICAgIBggIBAgIAwQHAwsICAgIBQcFCAcLBwcHCAUICggHCAcIDAwMCQkJCQoICAoIDAYGAwMFBQgSCgQAAA0UDQUFBQoIDQkDBgYJCQUHBQYICAgICAgICAgIBgYJCQkHDQkICQkICAkJBQYIBwsJCggKCAkJCQkNCQkJBgYGCwgICAgICAgFCAgDBAcDCwgICAgFBwYICAsHCAcIBwgLCAcIBwgNDQ0JCQkJCwgICwgNBgYDAwYGCBQLBQAADhUOBQYGCwkPCgQGBgkLBQcFBgkJCQkJCQkJCQkGBgsLCwgOCgoKCwkICwoFBgoICwoLCAsKCgkKCg8KCQoGBgYLCQkICQcJCAUJCQMFCAMNCQkJCQYIBgkICwkICAkGCQsJCAkICQ4ODgsLCwsLCQkLCQ4GBgQEBgYJFQsFAAAPFw8FBgcMChALBAcHCgwFBwUHCgoKCgoKCgoKCgcHDAwMCA8KCgsLCQkMCwUHCggNCwwJDAoKCQsKDwoJCgcHBwwKCgkJCAkJBQkJAwUJAw8JCgkJBggGCQkNCQkJCgcKDAoICggKDw8PDAwMDAwKCgwKDwcHBAQHBwoXDAUAABAYEAYGBw0KEQwEBwcKDQYHBgcKCgoKCgoKCgoKBwcNDQ0JEAsLCwwKCQwMBwcLCQ0MDQoNCwoKDAsRCwsLBwcHDQoKCgoICgoGCgoFBgkFDwoKCgoGCQcKCQ0JCQkKBwoNCgkKCQoQEBANDQ0NDQoKDQoQBwcEBAcHChgNBgAAERoRBgcIDgsSDAUICAsOBggGCAsLCwsLCwsLCwsICA4ODgkRDAwMDQsKDQ0ICAwJDg0NCg0MDAoMDBEMCgwICAgOCwsKCwkL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/84AIgBY/+IAIgBa/84AIgBw/84AIgBx/84AIgBy/84AIgBz/4gAIgB0/84AIgB1/4gAIwAN/+wAIwAOAAoAIwAP/+wAIwA1/8QAIwBv/+wAIwBwAAoAIwBxAAoAJAAO/84AJABw/84AJABx/84AJQAN/84AJQAP/84AJQA1/84AJQA4/+wAJQA5//YAJQA6/+wAJQA7/+wAJQBv/84AJwAN/tQAJwAP/tQAJwAb/8QAJwAc/8QAJwAgADwAJwAi/5wAJwA1AB4AJwBC/5wAJwBG/84AJwBQ/84AJwBv/tQAKgAO/+IAKgBw/+IAKgBx/+IAKwAN/+wAKwAP/+wAKwAi//YAKwBv/+wALAAO/5IALAAw/+wALABC/8QALABG/7oALABQ/7oALABW/84ALABX/7AALABY/7oALABa/7AALABw/5IALABx/5IALQAI/4gALQAO/2AALQAk/+wALQAo/+wALQArAGQALQAw/+wALQA1/1YALQA3/5IALQA4/5wALQA6/2AALQBX/5IALQBa/5IALQBw/2AALQBx/2AALQBz/2AALQB1/2AAMAAN/+IAMAAP/+IAMAA1/84AMAA5//YAMAA6/+wAMAA7/+wAMABv/+IAMQAN/tQAMQAP/tQAMQAi/84AMQA6ABQAMQBC/84AMQBG/84AMQBQ/84AMQBv/tQAMgAN/+IAMgAP/+IAMgBv/+IAMwAO/5wAMwA1/8QAMwA6/+wAMwBC/9gAMwBG/84AMwBQ/84AMwBW/+wAMwBa/8kAMwBw/5wAMwBx/5wAMwBz/7oAMwB1/7oANAAN/+wANAAP/+wANAAi/+wANAA0/+oANABX/+IANABY/+wANABa/+IANABv/+wANQAN/t4ANQAO/2oANQAP/t4ANQAb/zgANQAc/zgANQAgADwANQAi/4gANQAk/9gANQAo/9gANQAw/84ANQA0//QANQA1/7oANQBC/xAANQBE/yQANQBG/yQANQBI/y4ANQBQ/yQANQBT/zgANQBU/0wANQBW/zgANQBX/zgANQBY/zgANQBa/zgANQBb/1YANQBv/t4ANQBw/2oANQBx/2oANgAN/+wANgAP/+wANgAi//YANgBv/+wANwAN/t4ANwAO/84ANwAP/t4ANwAb/7AANwAc/7AANwAi/8QANwBC/5wANwBG/5wANwBQ/5wANwBW/8QANwBa/78ANwBv/t4ANwBw/84ANwBx/84AOAAN/t4AOAAO/84AOAAP/yQAOAAb/7AAOAAc/7AAOAAi/84AOABC/5wAOABG/5wAOABQ/5wAOABT/8QAOABW/8QAOABa/78AOABv/yQAOABw/84AOABx/84AOQAO/7AAOQAk//YAOQAo//YAOQAw//YAOQBC/84AOQBG/8QAOQBQ/8QAOQBW/+IAOQBa/7AAOQBw/7AAOQBx/7AAOgAN/t4AOgAO/3QAOgAP/t4AOgAb/zgAOgAc/zgAOgAi/7AAOgAw/+wAOgBC/3QAOgBF/4gAOgBG/34AOgBI/34AOgBO/5wAOgBP/5wAOgBQ/34AOgBR/5wAOgBS/34AOgBT/5wAOgBU/5IAOgBW/5IAOgBX/5wAOgBv/t4AOgBw/3QAOgBx/3QAOwAO/8QAOwAk/+wAOwAo/+wAOwAw/+wAOwA7//YAOwBC/84AOwBG/8QAOwBQ/8QAOwBY/9gAOwBa/78AOwBw/84AOwBx/84AQgBX//AAQgBY//YAQgBa//AAQwAN/+IAQwAP/+wAQwBa//sAQwBv/+wARAAO/+wARAA1/8QARABw/+wARABx/+wARgA1/3QARwADADwARwAIADwARwAKAGQARwALADIARwAN/34ARwAO/84ARwAP/4gARwAgAG4ARwA9AGQARwA+AGQARwBa//YARwBeAGQARwBv/4gARwBw/84ARwBx/84ARwBzADIARwB1ADIASQBX/+wASQBY//YASQBa/+wATAAO/5wATABG/+wATABQ/+wATABw/5wATABx/5wATgBX/+wATgBY//YATgBa/+wATwBX/+wATwBY//YATwBa/+wAUAAN/+IAUAAP/+wAUABX//EAUABZ/+wAUABa//EAUABv/+wAUQAN/+IAUQAP/+wAUQBa//sAUQBv/+wAUwAN/t4AUwAO/+wAUwAP/t4AUwBC/9wAUwBv/t4AUwBw/+wAUwBx/+wAUwBzAB4AUwB1AB4AVQAO/9gAVQBa//YAVQBw/9gAVQBx/9gAVQBzABQAVQB1ABQAVwAN/0wAVwAO/9gAVwAP/0wAVwBC/9gAVwBG/+4AVwBQ/+4AVwBv/0wAVwBw/9gAVwBx/9gAWAAN/7oAWAAO/+wAWAAP/7oAWABC/+wAWABv/7oAWABw/+wAWABx/+wAWQAO/84AWQBE/+wAWQBF//YAWQBG/+gAWQBI//YAWQBQ/+gAWQBw/84AWQBx/84AWgAN/0IAWgAO/9gAWgAP/0IAWgBC/9gAWgBE/+4AWgBF//YAWgBG/+4AWgBI//YAWgBQ/+4AWgBS//YAWgBv/0wAWgBw/9gAWgBx/9gAWwAO/+wAWwBE//YAWwBF//YAWwBG//QAWwBI//YAWwBQ//QAWwBS//YAWwBw/+wAWwBx/+wAbwBz/y4AbwB1/y4AcAAi/84AcAAq/+IAcAAr/5wAcAA0/+wAcAA1/2oAcAA3/84AcAA4/84AcAA5/7AAcAA6/3QAcAA7//YAcABC/+wAcABX/9gAcABY/+wAcABZ/84AcABa/9gAcABb/9gAcQAi/84AcQAq/+IAcQAr/5wAcQA0/+wAcQA1/2oAcQA3/84AcQA4/84AcQA5/7AAcQA6/3QAcQA7//YAcQBC/+wAcQBX/9gAcQBY/+wAcQBZ/84AcQBa/9gAcQBb/9gAcgAi/5wAcwAN/y4AcwAP/y4AcwAi/5wAcwA1AG4AcwA3AGQAcwA4ADwAcwA6AG4AcwBU/7oAcwBVACgAcwBv/y4AdAAi/5wAdQAN/y4AdQAP/y4AdQAi/5wAdQA1AG4AdQA3AGQAdQA4ADwAdQA6AG4AdQBU/7oAdQBVACgAdQBv/y4AAAAHAFoAAwABBAkAAACGAAAAAwABBAkAAQAOAIYAAwABBAkAAgAOAJQAAwABBAkAAwBkAKIAAwABBAkABAAOAIYAAwABBAkABQAYAQYAAwABBAkABgAOAIYAVAB5AHAAZQBmAGEAYwBlACAAYQBuAGQAIABkAGEAdABhACAAqQAgADEAOQA5ADYAIABNAGkAYwByAG8AcwBvAGYAdAAgAEMAbwByAHAAbwByAGEAdABpAG8AbgAuACAAQQBsAGwAIABSAGkAZwBoAHQAcwAgAFIAZQBzAGUAcgB2AGUAZABWAGUAcgBkAGEAbgBhAFIAZQBnAHUAbABhAHIATQBpAGMAcgBvAHMAbwBmAHQAOgBWAGUAcgBkAGEAbgBhACAAUgBlAGcAdQBsAGEAcgA6AFYAZQByAHMAaQBvAG4AIAAyAC4ANAAzACAAKABNAGkAYwByAG8AcwBvAGYAdAApAFYAZQByAHMAaQBvAG4AIAAyAC4ANAAzAAMAAAAAAAD/TAB4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAgAAgAQAAH//wAD",
			},
			[700] = {
				normal = "AAEAAAAQAQAABAAAT1MvMkTcmtsAAAGIAAAAVlZETVh08XxtAAAD0AAABeBjbWFwDsKNaQAAFbgAAADSY3Z0IFYhZi0AAB9YAAAB8mZwZ216Re4kAAAWjAAABb9nYXNwABcACQAAeygAAAAQZ2x5Zlj+1IsAACJIAABXKGhkbXiZKvBYAAAJsAAADAhoZWFkAKCWhAAAAQwAAAA2aGhlYRV8DOMAAAFEAAAAJGhtdHjBHkdpAAAB4AAAAfBsb2NhfeNpYQAAIUwAAAD6bWF4cAOPAfgAAAFoAAAAIG5hbWUhmjnyAAB5cAAAAZZwb3N0/3gA0wAAewgAAAAgcHJlcN573dEAABxMAAADCQABAAAAAQAAfkM6XF8PPPUAGwgAAAAAAK1sU/gAAAAA5pX4q//G/lcNqAaMAAEACQACAAAAAAAAAAEAAAgL/lIAAA44/8b/3A2oAAEAAAAAAAAAAAAAAAAAAAB8AAEAAAB8AFMABwAAAAAAAgACAEAAVQAAArQBYwAAAAAAAQSLArwABQAABZoFMwAAASUFmgUzAAADoADTAwUIAAILCAQDBQQEAgQAAAADAAAAAAAAAAAAAAAATVMgIAAgACAiZQYe/lkAyggLAa4AAAABAAAAAAAACAABAAK8AAADOADLBLMApwbwAJUFsACGCi0AjwbmAHkCqACnBFkAwQRZAKYFsADMBvAA2gLkACMD1wBuAuQAtwWEAHsFsABwBbABCgWwALkFsACMBbAAVAWwAKQFsACGBbAAnAWwAGMFsABoAzgA4QM4AE0G8ADMBvAA+QbwAOwE7wCTB7YAkQY2ABgGGAC+BcoAZwakAL4FdwC+BTQAvgZ9AGcGswC+BF4AewRxACoGKwC+BRkAvgeVAL4GxgC+Bs0AZwXdAL4GzQBnBkIAvgWvAG0FdAApBn8AqQYcABgJBwBCBhwAGAXlAAkFiQBaBFkA+AWEAL0EWQDGBvAAxQWw//AFsAF2BVgAVgWYAKoEtQBYBZgAWgVQAFgDYQArBZgAWgWzAKoCvACgAzn/xgVeAKoCvACqCHcAqgWzAKoFfgBYBZgAqgWYAFoD+gCqBL8AXwOlACsFswChBTMAHgfWAC0FWgAaBTUAHgTGAFQFsACYBFkBmwWwAMkG8ACdBbAA8gSzALQFsACXBbAA3QWwAIcHtgB6B7YAege2AI4G8AD6BvAA2gbwANoG8ADaBvAAngbMANkGzAEmCGQAtwWwAJkIAACZBLMACwSzAHsCqAAgAqgAewRZANkEWQEmBbAA8g44AI8G8AEIAuQAtwAAAAEAAQEBAQEADAD4CP8ACAAI//4ACQAK//4ACgAK//4ACwAL//4ADAAM//4ADQAN//0ADgAO//0ADwAP//0AEAAP//0AEQAR//0AEgAS//wAEwAT//wAFAAV//wAFQAV//wAFgAW//wAFwAX//sAGAAY//sAGQAa//sAGgAb//sAGwAb//sAHAAc//oAHQAd//oAHgAe//oAHwAg//oAIAAg//oAIQAh//kAIgAi//kAIwAj//kAJAAl//kAJQAm//kAJgAm//gAJwAn//gAKAAo//gAKQAp//gAKgAr//gAKwAr//cALAAs//cALQAt//cALgAu//cALwAw//cAMAAx//YAMQAx//YAMgAy//YAMwAz//YANAA0//YANQA2//UANgA2//UANwA3//UAOAA4//UAOQA5//UAOgA7//QAOwA8//QAPAA9//QAPQA9//QAPgA+//QAPwA///MAQABB//MAQQBB//MAQgBC//MAQwBD//MARABE//IARQBG//IARgBH//IARwBH//IASABI//IASQBJ//EASgBK//EASwBM//EATABN//EATQBN//EATgBO//AATwBP//AAUABR//AAUQBS//AAUgBS/+8AUwBT/+8AVABU/+8AVQBV/+8AVgBX/+8AVwBY/+4AWABY/+4AWQBZ/+4AWgBa/+4AWwBc/+4AXABd/+wAXQBd/+wAXgBe/+wAXwBf/+wAYABg/+wAYQBi/+sAYgBi/+sAYwBj/+sAZABk/+sAZQBl/+sAZgBn/+oAZwBo/+oAaABo/+oAaQBp/+oAagBq/+oAawBr/+kAbABt/+kAbQBt/+kAbgBu/+kAbwBv/+kAcABw/+gAcQBy/+gAcgBy/+gAcwBz/+gAdAB0/+gAdQB1/+cAdgB2/+cAdwB4/+cAeAB4/+cAeQB5/+cAegB6/+YAewB7/+YAfAB9/+YAfQB9/+YAfgB+/+YAfwB//+UAgACA/+UAgQCC/+UAggCD/+UAgwCD/+UAhACE/+QAhQCF/+QAhgCG/+QAhwCI/+QAiACI/+QAiQCJ/+MAigCK/+MAiwCL/+MAjACN/+MAjQCO/+MAjgCO/+IAjwCP/+IAkACQ/+IAkQCR/+IAkgCT/+IAkwCT/+EAlACU/+EAlQCV/+EAlgCW/+EAlwCY/+EAmACZ/+AAmQCZ/+AAmgCb/+AAmwCb/+AAnACc/+AAnQCe/98AngCe/98AnwCg/98AoACg/98AoQCh/98AogCj/94AowCk/94ApACk/94ApQCm/94ApgCm/94ApwCn/90AqACp/90AqQCp/90AqgCr/90AqwCr/90ArACs/9wArQCu/9wArgCv/9wArwCw/9wAsACw/9wAsQCx/9sAsgCy/9sAswC0/9sAtAC1/9sAtQC2/9sAtgC2/9oAtwC3/9oAuAC5/9oAuQC6/9oAugC7/9oAuwC7/9kAvAC8/9kAvQC9/9kAvgC//9kAvwDA/9kAwADB/9gAwQDB/9gAwgDC/9gAwwDE/9gAxADF/9gAxQDF/9cAxgDG/9cAxwDH/9cAyADI/9cAyQDK/9cAygDL/9YAywDM/9YAzADM/9YAzQDN/9YAzgDP/9YAzwDQ/9UA0ADQ/9UA0QDR/9UA0gDS/9UA0wDT/9UA1ADV/9QA1QDV/9QA1gDX/9QA1wDX/9QA2ADY/9QA2QDa/9MA2gDb/9MA2wDc/9MA3ADc/9MA3QDd/9MA3gDe/9IA3wDg/9IA4ADg/9IA4QDi/9IA4gDi/9IA4wDj/9EA5ADl/9EA5QDm/9EA5gDn/9EA5wDn/9EA6ADo/9AA6QDp/9AA6gDr/9AA6wDr/9AA7ADs/9AA7QDt/88A7gDu/88A7wDw/88A8ADx/88A8QDy/88A8gDy/84A8wDz/84A9AD0/84A9QD2/84A9gD3/84A9wD3/80A+AD4/80A+QD5/80A+gD7/80A+wD8/8wA/AD9/8wA/QD+/8wA/gD+/8wA/wD//8wAAAAYAAAAgAkQCQMEBQgGCwgDBQUGCAMEAwYGBgYGBgYGBgYGBAQICAgGCQgHBgcGBgcHBQUHBggHCAcIBwYGBwcLBwcGBQYFCAYGBgYFBgYFBgYDBAYDCQYGBgYEBQUGBgkGBgUGBQYIBgUGBgYJCQkICAgICAgICQYJBgYDAwUFBhAIAwAAChIKAwQGCQcNCQMFBQcJBAUEBwcHBwcHBwcHBwcEBAkJCQYKCQgHCQcHCAgGBggGCQgJCAkIBwYICAwICAcFBwUJBwcHBwYHBwUHBwMEBwMLBwcHBwUGBQcHCQcHBgcFBwkHBgcHBwoKCgkJCQkJCQkMBwoGBgMDBQUHEgkEAAALFAsEBAcJCA4KBAYGCAkEBgQICAgICAgICAgICAQECQkJBwsJCAgJCAgJCQYGCAcKCQkICQgICAkIDAgICAYIBgoICAgIBwgIBQgIBAUIBAwICAgIBgcFCAgKCAgHCAYICQgGCAcICwsLCQkJCQkJCQwICwcHBAQGBggUCgQAAAwVDAQFBwoJDwoEBwcJCgQGBAgJCQkJCQkJCQkJBQUKCgoHDAkJCQoICAoKBgcJCAsKCwkLCQkICgkOCQoIBggGCgkJCAgHCAgFCAgEBQgEDAgICAgGBwUICAwICAcJBgkKCQcJCQkMDAwKCgoKCgoKDAkMBwcEBAcHCRUKBAAADRgNBAYHCwkRCwQHBwkLBQcFCQkJCQkJCQkJCQkFBQsLCwgNCgoKCgkJCgsGBwkIDAoLCQsJCQgKCg4KCgkGCQYKCQkJCQgJCQUJCQQFCAQOCQkJCQYIBgkJDAkJCAkICQsKBwkKCQwMDQsLCwsLCwsPCQ0ICAQEBwcKGAsFAAAOGQ4FBggMChIMBQgICgwFBwUKCgoKCgoKCgoKCgYGDAwMCQ4LCwsLCgkLCwgICwkNCwwKDAsKCgsLEAsKCggKCAwKCgkKCAoJBgoKBAYJBA4KCgoKBwgGCgkOCQkICggKDAoICgoKDg4ODAwMDAwMDA8KDgkJBQUICAoZDAUAAA8bDwUGCQ0LEw0FCAgLDQUHBQoLCwsLCwsLCwsLBgYNDQ0JDgwLCwwKCgwMCAgMCg4MDQsNDAsKDAsQCwsKCAoIDQsLCgoICgoGCgoEBgoEEAoKCgoHCQcKCg4KCgkLCAsNCwkLCwsODg4NDQ0NDQ0NDwsPCQkFBQgICxsNBQAAEBwQBQYJDQsUDgYJCQsNBggGCwsLCwsLCwsLCwsGBg0NDQoPDAwMDQsKDQ0ICQwKDw0ODA4NCwwNDBIMDAsJCwkNCwsLCwkLCwcLCwQGCgQQCwsLCwgJBwsKEAsKCgsICw0LCQsLCw8PDw0NDQ0NDg4SCxAJCQUFCQkLHA4GAAARHhEGBwoPDBYPBgkJDA8GCAYMDAwMDAwMDAwMDAcHDw8PChANDQwODAsODgkJDQsQDg4MDg0MDA4NEw0NDAkMCQ8MDAsMCgwLBwwMBgcLBhIMDAwMCAoI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",
			},
		},
	}
end
end)()

_registry["ui/font_tiny5_art"] = (function()
return function()
	return {
		family = "Tiny5",
		faces = {
			[400] = {
				normal = "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PwBOAAAABQAFEREECRgrJRUhETMRAYD+gICAgAKA/gAAAwAAAAACgAKAAAcADwATADdANAAICgEJAAgJZwcBAQE+TQUBAwMCXwYBAgJBTQQBAAA/AE4QEBATEBMSERERERERERALCR8rMyMRMxUzFSMBIxEjNTM1MwE1MxWAgICAgAIAgICAgP6AgAKAgID+gAGAgID+gICAAAACAAAAAAIAAoAABwAPAC1AKgAGAAUABgVnBwEBAT5NAAMDAl8AAgJBTQQBAAA/AE4REREREREREAgJHiszIxEzFTMVIwEjESM1MxEzgICAgIABgICAgIACgICA/oABAIABAAAABAAAAAACAAKAAAMABwALAA8AQEA9CAEBAQBfAAAAPk0EAQICA18FAQMDQU0JAQcHBl8ABgY/Bk4MDAAADA8MDw4NCwoJCAcGBQQAAwADEQoJFysTNSEVASMRMwEjETMDFSE1gAEA/wCAgAGAgICA/wACAICA/oABgP6AAYD+gICAAAIAAAAAAgACgAAJAA0ANUAyAAMABAADBGcAAgIBXwABAT5NBwEGBgVfAAUFQU0AAAA/AE4KCgoNCg0SERERERAICRwrMyMRIRUhFSEVISU1MxWAgAGA/wABAP8AAQCAAoCAgICAgIAABgAAAAACAAKAAAMABwALAA8AEwAXAFxAWQAHBgECCQcCZwwBAQEAXwAAAD5NDQEFBQNfBAEDA0FNCg4CCQkIXw8LAggIPwhOFBQQEAgIAAAUFxQXFhUQExATEhEPDg0MCAsICwoJBwYFBAADAAMREAkXKxM1IRUBIxEzAREzEQcjNTMHFSM1BTUzFYABAP8AgIABAICAgICAgAEAgAIAgID+gAGA/wABAP8AgICAgICAgIAAAwAAAAACAAKAAAkADQARADdANAADAAQIAwRnAAICAV8AAQE+TQAFBQZfAAYGQU0ACAgAXwcBAAA/AE4RERERERERERAJCR8rMyMRIRUhFSEVISUjNTMRIxEzgIABgP8AAQD/AAGAgICAgAKAgICAgID+AAEAAAUAAAAAAgACgAADAAcACwAPABMAV0BUAAQABQcEBWcABwAGCQcGZwoBAQEAXwAAAD5NCwEDAwJfAAICQU0MAQkJCF8ACAg/CE4QEAQEAAAQExATEhEPDg0MCwoJCAQHBAcGBQADAAMRDQkXKxM1IRUF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QU0KAQkJCGAACAg/CE5ZQBIAAAATABMRERERERERERELCR8rNzUjETM1IRUjFSMVMzUzESMVITWAgIABAICAgICA/wCAgAEAgICAgID/AICAAAADAAAAgAGAAoAAAwAHAAsAQ7EGZERAOAAABgEBAwABZwADAAIEAwJnAAQFBQRXAAQEBV8HAQUEBU8ICAAACAsICwoJBwYFBAADAAMRCAkXK7EGAEQTNSEVASMRMxE1IRWAAQD/AICAAQACAICA/wABAP6AgIAABgAAAIACgAIAAAMABwALAA8AEwAXAE1ASg0HDAMFBgEECAUEZwoBCA8LDgMJCAljAgEAAAFfAwEBAUEAThQUEBAMDAgIFBcUFxYVEBMQExIRDA8MDw4NCAsICxIREREQEAkbKwEjNTMFIzUzBxUjNSEVIzUBNTMVITUzFQKAgID+gICAgIACAID/AIABAIABgICAgICAgICA/wCAgICAAAMAAACAAYACgAAJAA0AEQBNsQZkREBCAAEAAgUBAmcABQkBBgMFBmcAAwAEBwMEZwAHAAAHVwAHBwBfCggCAAcATw4OCgoOEQ4REA8KDQoNEhEREREQCwkcK7EGAEQ3IxEhFSMVMxUjNzUzFQM1MxWAgAEAgICAgICAgIACAICAgICAgP8AgIAAAAQAAAEAAYACgAADAAcACwAPAE6xBmREQEMAAAgBAQIAAWcEAQIKBQkDAwYCA2cABgcHBlcABgYHXwAHBgdPCAgEBAAADw4NDAgLCAsKCQQHBAcGBQADAAMRCwkXK7EGAEQTNTMVBTUzFTM1MxUhMxUjgID/AICAgP8AgIACAICAgICAgICAAAACAAAAAAGAAoAACwAPADxAOQgFAgMDAF8CAQAAQU0ABAQBXwABAT5NAAYGB18JAQcHPwdODAwAAAwPDA8ODQALAAsREREREQoJGysRNTM1MxUzFSMVIzUDNSEVgICAgICAAYABgICAgICAgP6AgIAAAQAAAAABgAKAAAkAJUAiAAICA18AAwNBTQABAQRfAAQEPk0AAAA/AE4REREREAUJGyshIxEjNSM1MzUhAYCAgICAAQABAICAgAABAAABAACAAYAAAwAeQBsAAAEBAFcAAAABXwIBAQABTwAAAAMAAxEDCRcrETUzFYABAICAAAAGAAAAgAKAAgAAAwAHAAsADwATABcAT0BM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",
			},
		},
	}
end
end)()

_registry["ui/icon"] = (function()

return function(p)
				local J = p("ui/icon_art")
				local O = p("services/png")
				local u, F, f = p("ui/raster"), {}, {}
				local function p(o, Z)
					local i, y, P = buffer.create(Z * 4), 1, 0
					while y < #o and P < Z do
						local b, I = string.byte(o, y), string.byte(o, y + 1)
						y += 2
						for o = 1, I, 1 do
							if P >= Z then
								break
							end
							o = P * 4
							buffer.writeu8(i, o, 255)
							buffer.writeu8(i, o + 1, 255)
							buffer.writeu8(i, o + 2, 255)
							buffer.writeu8(i, o + 3, b)
							P += 1
						end
					end
					return i
				end
				F.fromAlpha = function(o, Z, i)
					if typeof(o) ~= "string" or #o == 0 then
						return nil
					end
					i = i or Z
					return u.image(p(o, Z * i), Z, i, "icon")
				end
				F.get = function(u)
					local o = f[u]
					if o ~= nil then
						return o or nil
					end
					o = J.glyphs and J.glyphs[u]
					if not o then
						f[u] = false
						return nil
					end
					local Z = F.fromAlpha(o.data, o.w, o.h)
					f[u] = Z or false
					return Z
				end
				local u = {}
				F.bytes = function(f)
					local o = u[f]
					if o ~= nil then
						return o or nil
					end
					local o = J.glyphs and J.glyphs[f]
					if not o then
						u[f] = false
						return nil
					end
					local Z, i = pcall(function()
						return O.encode(o.w, o.h, buffer.tostring(p(o.data, o.w * o.h)))
					end)
					u[f] = Z and i or false
					return u[f] or nil
				end
				F.dimensions = function(p)
					local O = J.glyphs and J.glyphs[p]
					if not O then
						return nil
					end
					return O.w, O.h
				end
				F.GLYPH = 16
				F.size = function()
					return F.GLYPH
				end
				F.shadowSlice = function()
					local p = J.shadow or {}
					return p.pad or 12, p.slice or 20
				end
				return F
			end
end)()

_registry["ui/icon_art"] = (function()
return function()
	local r3 = {}

	local r5 = {
		armor = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\139+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\254\1\255.\253\1\0\16\248\1\255.\246\1\0\16\236\1\255.\233\1\0\16\216\1\255.\213\1\0\16\189\1\255.\186\1\0\16\155\1\255.\151\1\0\16q\1\255.n\1\0\16@\1\255.<\1\0\16\12\1\250\1\255,\249\1\t\1\0\17\197\1\255,\193\1\0\18z\1\255,u\1\0\18'\1\255+\254\1\"\1\0\19\201\1\255*\196\1\0\20b\1\255*\\\1\0\20\8\1\231\1\255(\228\1\6\1\0\21q\1\255(m\1\0\22\8\1\223\1\255&\220\1\7\1\0\23S\1\255&M\1\0\25\175\1\255$\169\1\0\26\22\1\231\1\255\"\226\1\19\1\0\27@\1\251\1\255 \249\1:\1\0\29i\1\255 c\1\0\31\133\1\255\30~\1\0!\140\1\255\28\133\1\0#}\1\254\1\255\24\254\1w\1\0%]\1\247\1\255\22\245\1Y\1\0'2\1\219\1\255\20\215\1.\1\0)\12\1\152\1\254\1\255\16\253\1\147\1\11\1\0,>\1\211\1\255\14\208\1;\1\0/\3\1e\1\226\1\255\n\224\1b\1\3\1\0002\7\1e\1\214\1\255\6\211\1c\1\6\1\0006\1\1@\1\157\1\235\1\234\1\155\1=\1\0\255\0\30",
		},
		arrow = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\141&\1\175\1\244\2\179\1V\1\8\1\0008&\1\238\1\255\5\238\1\151\0019\1\0006\174\1\255\t\217\1{\1\30\1\0003\241\1\255\11\253\1\189\1^\1\11\1\0000\241\1\255\14\243\1\160\1A\1\2\1\0-\176\1\255\17\224\1\130\1%\1\0+S\1\255\20\204\1o\1\20\1\0(\6\1\235\1\255\21\248\1\179\1U\1\5\1\0&\149\1\255\24\230\1\145\0011\1\0$6\1\255\27\213\1w\1\22\1\0\"\214\1\255\28\252\1\187\1^\1\t\1\0\31x\1\255\31\239\1\153\1<\1\0\29\27\1\252\1\255!\215\1\128\1 \1\0\27\186\1\255#\253\1\196\1f\1\11\1\0\24[\1\255&\241\1\162\1D\1\1\1\0\21\t\1\240\1\255(\226\1\136\1$\1\0\20\157\1\255*\254\1\193\1a\1\5\1\0\17>\1\255-\198\1\r\1\0\16\1\1\222\1\255-\143\1\0\17\128\1\255-\231\1\0\17#\1\254\1\255,\250\1\0\18\194\1\255,\207\1\0\18c\1\255,X\1\0\18\14\1\246\1\255)\244\1l\1\0\20\165\1\255&\228\1\157\1U\1\15\1\0\21G\1\255\"\251\1\196\1w\0013\1\1\1\0\24\2\1\227\1\255\30\221\1\153\1U\1\14\1\0\29\137\1\255\26\245\1\187\1w\1*\1\0!*\1\255\23\221\1\145\1D\1\7\1\0%\203\1\255\19\209\1`\1\25\1\0)l\1\255\19`\1\0+\18\1\248\1\255\17\254\1\26\1\0,\174\1\255\17\208\1\0-O\1\255\17\137\1\0-\5\1\234\1\255\16B\1\0.\146\1\255\15\244\1\7\1\0.3\1\255\15\177\1\0000\210\1\255\14j\1\0000u\1\255\14#\1\0000\23\1\251\1\255\12\218\1\0002\183\1\255\12\147\1\0002X\1\255\12L\1\0002\8\1\239\1\255\n\249\1\12\1\0003\154\1\255\n\188\1\0004;\1\255\nu\1\0005\216\1\255\t-\1\0005}\1\255\8\230\1\1\1\0005\31\1\253\1\255\7\157\1\0007\191\1\255\7V\1\0007^\1\255\6\244\1\16\1\0007\4\1\194\1\255\5l\1\0009\11\1\139\1\229\1\250\1\206\1W\1\0\159",
		},
		badCircle = not {
			w = 64,
			h = 64,
			data = "\0\255\0\153\1\1/\1k\1\156\1\196\1\228\1\245\1\255\2\244\1\225\1\195\1\155\1i\1,\1\0/5\1\148\1\229\1\255\14\226\1\145\0011\1\0)\1\1T\1\202\1\255\20\198\1N\1\1\1\0%<\1\205\1\255\24\200\0016\1\0\"\11\1\151\1\254\1\255\26\253\1\144\1\t\1\0\31)\1\214\1\255\30\209\1$\1\0\29C\1\241\1\255 \237\1=\1\0\27L\1\248\1\255\"\246\1G\1\0\25C\1\248\1\255$\246\1>\1\0\23)\1\241\1\255&\237\1$\1\0\21\11\1\214\1\255(\209\1\8\1\0\20\151\1\255*\143\1\0\19<\1\254\1\255\19\173\1\20\1\21\1\175\1\255\19\253\0015\1\0\17\1\1\205\1\255\20\20\1\0\2\23\1\255\20\198\1\1\1\0\16T\1\255\21\0\4\255\21L\1\0\16\202\1\255\21\0\4\255\21\196\1\0\0155\1\255\22\0\4\255\0220\1\0\14\148\1\255\22\0\4\255\22\142\1\0\r\1\1\229\1\255\22\0\4\255\22\225\1\0\r/\1\255\23\0\4\255\23)\1\0\12k\1\255\23\0\4\255\23f\1\0\12\157\1\255\23\0\4\255\23\152\1\0\12\197\1\255\23\0\4\255\23\192\1\0\12\226\1\255\23\0\4\255\23\222\1\0\12\245\1\255\23\0\4\255\23\242\1\0\12\254\1\255\23\0\4\255\23\252\1\0\12\254\1\255\23\0\4\255\23\252\1\0\12\245\1\255\23\0\4\255\23\242\1\0\12\225\1\255\23\21\1\0\2\24\1\255\23\223\1\0\12\196\1\255\23\175\1\22\1\23\1\177\1\255\23\193\1\0\12\156\1\2552\152\1\0\12j\1\2552f\1\0\12.\1\2552)\1\0\12\1\1\228\1\2550\225\1\0\14\147\1\255\21\248\1j\1\12\1\r\1k\1\248\1\255\21\142\1\0\0144\1\255\21i\1\0\4m\1\255\0211\1\0\15\201\1\255\20\r\1\0\4\16\1\255\20\197\1\0\16R\1\255\20\14\1\0\4\16\1\255\20M\1\0\16\1\1\203\1\255\19k\1\0\4o\1\255\19\199\1\1\1\0\17:\1\253\1\255\18\248\1m\1\14\1\16\1o\1\248\1\255\18\253\0015\1\0\19\148\1\255*\145\1\0\20\n\1\212\1\255(\209\1\t\1\0\21'\1\239\1\255&\238\1%\1\0\23@\1\247\1\255$\247\1?\1\0\25K\1\248\1\255\"\247\1J\1\0\27A\1\239\1\255 \238\1?\1\0\29'\1\212\1\255\30\209\1%\1\0\31\t\1\147\1\253\1\255\26\253\1\145\1\t\1\0\"7\1\201\1\255\24\199\0015\1\0%\1\1O\1\199\1\255\20\197\1M\1\1\1\0)2\1\144\1\226\1\255\14\225\1\142\0011\1\0/*\1g\1\153\1\193\1\223\1\242\1\255\2\242\1\223\1\192\1\152\1f\1)\1\0\255\0\154",
		},
		boxDraw = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\11+\1\180\1\246\1\255\8\246\1\178\1)\1\0\18+\1\180\1\246\1\255\8\246\1\178\1)\1\0\17+\1\241\1\255\12\240\1(\1\0\16+\1\241\1\255\12\240\1(\1\0\16\180\1\255\14\176\1\0\16\180\1\255\14\176\1\0\16\246\1\255\14\243\1\0\16\246\1\255\14\243\1\0\16\255\16\0\16\255\16\0\16\255\16\0\16\255\16\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\16\0\16\255\16\0\16\255\16\0\16\255\16\0\16\245\1\255\14\243\1\0\16\245\1\255\14\243\1\0\16\179\1\255\14\175\1\0\16\179\1\255\14\175\1\0\16)\1\240\1\255\12\239\1'\1\0\16)\1\240\1\255\12\239\1'\1\0\17(\1\177\1\244\1\255\8\243\1\175\1'\1\0\18(\1\177\1\244\1\255\8\243\1\175\1'\1\0\23\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\23+\1\180\1\246\1\255\8\246\1\178\1)\1\0\18+\1\180\1\246\1\255\8\246\1\178\1)\1\0\17+\1\241\1\255\12\240\1(\1\0\16+\1\241\1\255\12\240\1(\1\0\16\180\1\255\14\176\1\0\16\180\1\255\14\176\1\0\16\246\1\255\14\243\1\0\16\246\1\255\14\243\1\0\16\255\16\0\16\255\16\0\16\255\16\0\16\255\16\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\16\0\16\255\16\0\16\255\16\0\16\255\16\0\16\245\1\255\14\243\1\0\16\245\1\255\14\243\1\0\16\179\1\255\14\175\1\0\16\179\1\255\14\175\1\0\16)\1\240\1\255\12\239\1'\1\0\16)\1\240\1\255\12\239\1'\1\0\17(\1\177\1\244\1\255\8\243\1\175\1'\1\0\18(\1\177\1\244\1\255\8\243\1\175\1'\1\0\255\0\255\0\11",
		},
		caret = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\255\0\255\0\255\0\143S\1\235\1\255(\234\1O\1\0\20\234\1\255*\232\1\0\20\234\1\255*\231\1\0\20T\1\251\1\255(\251\1S\1\0\21T\1\251\1\255&\252\1[\1\0\23T\1\251\1\255$\252\1[\1\0\25T\1\251\1\255\"\252\1[\1\0\27T\1\251\1\255 \252\1[\1\0\29T\1\251\1\255\30\252\1[\1\0\31T\1\251\1\255\28\252\1[\1\0!T\1\251\1\255\26\252\1[\1\0#T\1\251\1\255\24\252\1[\1\0%T\1\251\1\255\22\252\1[\1\0'T\1\251\1\255\20\252\1[\1\0)T\1\251\1\255\18\252\1[\1\0+T\1\251\1\255\16\252\1[\1\0-T\1\251\1\255\14\252\1[\1\0/T\1\251\1\255\12\252\1[\1\0001T\1\251\1\255\n\252\1[\1\0003T\1\251\1\255\8\252\1[\1\0005T\1\251\1\255\6\252\1[\1\0007T\1\251\1\255\4\252\1[\1\0009T\1\251\1\255\2\252\1[\1\0;S\1\232\2S\1\0\255\0\255\0\255\0\255\0\162",
		},
		caution = {
			w = 64,
			h = 64,
			data = "\0\255\0\157\12\1x\1\208\1\250\1\249\1\207\1v\1\11\1\0007)\1\221\1\255\6\220\1'\1\0005\19\1\227\1\255\8\226\1\18\1\0004\151\1\255\n\151\1\0003+\1\251\1\255\n\252\1/\1\0002\186\1\255\12\190\1\0001S\1\255\14R\1\0/\6\1\219\1\255\14\222\1\8\1\0.y\1\255\16x\1\0-\23\1\241\1\255\16\243\1\26\1\0,\160\1\255\18\159\1\0+2\1\253\1\255\18\253\0016\1\0)\1\1\195\1\255\20\198\1\1\1\0(Z\1\255\22Y\1\0'\t\1\224\1\255\22\227\1\11\1\0&\129\1\255\24\128\1\0%\28\1\244\1\255\24\246\1\31\1\0$\168\1\255\26\167\1\0#;\1\254\1\255\11\173\1\20\1\21\1\175\1\255\11\254\1;\1\0!\2\1\204\1\255\12\20\1\0\2\23\1\255\12\204\1\2\1\0 b\1\255\r\0\4\255\ra\1\0\31\r\1\230\1\255\r\0\4\255\r\232\1\15\1\0\30\137\1\255\14\0\4\255\14\136\1\0\29\"\1\248\1\255\14\0\4\255\14\249\1%\1\0\28\176\1\255\15\0\4\255\15\175\1\0\27B\1\255\16\0\4\255\16F\1\0\25\3\1\209\1\255\16\0\4\255\16\213\1\4\1\0\24j\1\255\17\0\4\255\17i\1\0\23\17\1\235\1\255\17\0\4\255\17\237\1\19\1\0\22\145\1\255\18\0\4\255\18\144\1\0\21)\1\250\1\255\18\21\1\0\2\24\1\255\18\250\1)\1\0\20\182\1\255\19\175\1\22\1\23\1\177\1\255\19\182\1\0\19K\1\255,J\1\0\17\5\1\216\1\255,\219\1\7\1\0\16r\1\255.q\1\0\15\21\1\239\1\255.\241\1\23\1\0\14\152\1\255\21\248\1j\1\12\1\r\1k\1\248\1\255\21\152\1\0\r.\1\252\1\255\21i\1\0\4m\1\255\21\252\1.\1\0\12\190\1\255\22\r\1\0\4\16\1\255\22\190\1\0\11R\1\255\23\14\1\0\4\16\1\255\23R\1\0\t\8\1\221\1\255\23k\1\0\4o\1\255\23\221\1\8\1\0\8q\1\255\24\248\1m\1\14\1\16\1o\1\248\1\255\24o\1\0\8\207\1\2556\203\1\0\8\249\1\2556\246\1\0\8\248\1\2556\245\1\0\8\204\1\2556\199\1\0\8m\1\2556i\1\0\8\6\1\206\1\2554\202\1\5\1\0\t\25\1\205\1\2552\201\1\23\1\0\11\6\1j\1\198\1\245\1\255,\245\1\197\1g\1\5\1\0\255\0\255\0\8",
		},
		check = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\137+\1\180\1\246\1\255,\246\1\178\1)\1\0\r+\1\241\1\2550\240\1(\1\0\12\180\1\2552\176\1\0\12\246\1\2552\243\1\0\12\2554\0\12\2554\0\12\2554\0\12\2554\0\12\255*\171\1\21\2\175\1\255\6\0\12\255)\168\1\4\1\0\2\23\1\255\6\0\12\255(\168\1\4\1\0\3\24\1\255\6\0\12\255'\168\1\4\1\0\3\4\1\172\1\255\6\0\12\255&\170\1\4\1\0\3\3\1\164\1\255\7\0\12\255%\170\1\4\1\0\3\3\1\164\1\255\8\0\12\255$\170\1\4\1\0\3\3\1\164\1\255\t\0\12\255#\170\1\4\1\0\3\3\1\164\1\255\n\0\12\255\"\170\1\4\1\0\3\3\1\164\1\255\11\0\12\255!\170\1\4\1\0\3\3\1\164\1\255\12\0\12\255 \170\1\4\1\0\3\3\1\164\1\255\r\0\12\255\31\170\1\4\1\0\3\3\1\164\1\255\14\0\12\255\30\170\1\4\1\0\3\3\1\164\1\255\15\0\12\255\29\170\1\4\1\0\3\3\1\164\1\255\16\0\12\255\8\173\1\21\2\171\1\255\16\168\1\4\1\0\3\4\1\168\1\255\17\0\12\255\8\21\1\0\2\4\1\168\1\255\14\168\1\4\1\0\3\4\1\168\1\255\18\0\12\255\8\22\1\0\3\4\1\168\1\255\12\168\1\4\1\0\3\4\1\168\1\255\19\0\12\255\8\171\1\4\1\0\3\4\1\168\1\255\n\168\1\4\1\0\3\4\1\168\1\255\20\0\12\255\t\171\1\4\1\0\3\3\1\163\1\255\8\170\1\4\1\0\3\3\1\164\1\255\21\0\12\255\n\171\1\4\1\0\3\3\1\163\1\255\6\170\1\4\1\0\3\3\1\164\1\255\22\0\12\255\11\171\1\4\1\0\3\3\1\163\1\255\4\170\1\4\1\0\3\3\1\164\1\255\23\0\12\255\12\171\1\4\1\0\3\3\1\163\1\255\2\170\1\4\1\0\3\3\1\164\1\255\24\0\12\255\r\171\1\4\1\0\3\3\1\163\1\170\1\4\1\0\3\3\1\164\1\255\25\0\12\255\14\168\1\4\1\0\3\4\2\0\3\4\1\168\1\255\26\0\12\255\15\171\1\4\1\0\6\3\1\164\1\255\27\0\12\255\16\171\1\4\1\0\4\3\1\164\1\255\28\0\12\255\17\171\1\4\1\0\2\3\1\164\1\255\29\0\12\255\18\172\1\23\2\172\1\255\30\0\12\2554\0\12\2554\0\12\2554\0\12\2554\0\12\245\1\2552\243\1\0\12\179\1\2552\175\1\0\12)\1\240\1\2550\239\1'\1\0\r(\1\177\1\244\1\255,\243\1\175\1'\1\0\255\0\255\0\137",
		},
		clock = {
			w = 64,
			h = 64,
			data = "\0\255\0\153\1\1/\1k\1\156\1\196\1\228\1\245\1\255\2\244\1\225\1\195\1\155\1i\1,\1\0/5\1\148\1\229\1\255\14\226\1\145\0011\1\0)\1\1T\1\202\1\255\20\198\1N\1\1\1\0%<\1\205\1\255\24\200\0016\1\0\"\11\1\151\1\254\1\255\26\253\1\144\1\t\1\0\31)\1\214\1\255\30\209\1$\1\0\29C\1\241\1\255 \237\1=\1\0\27L\1\248\1\255\"\246\1G\1\0\25C\1\248\1\255$\246\1>\1\0\23)\1\241\1\255&\237\1$\1\0\21\11\1\214\1\255\18\173\1\20\1\21\1\175\1\255\18\209\1\8\1\0\20\151\1\255\19\20\1\0\2\23\1\255\19\143\1\0\19<\1\254\1\255\19\0\4\255\19\253\0015\1\0\17\1\1\205\1\255\20\0\4\255\20\198\1\1\1\0\16T\1\255\21\0\4\255\21L\1\0\16\202\1\255\21\0\4\255\21\196\1\0\0155\1\255\22\0\4\255\0220\1\0\14\148\1\255\22\0\4\255\22\142\1\0\r\1\1\229\1\255\22\0\4\255\22\225\1\0\r/\1\255\23\0\4\255\23)\1\0\12k\1\255\23\0\4\255\23f\1\0\12\157\1\255\23\0\4\255\23\152\1\0\12\197\1\255\23\0\4\255\23\192\1\0\12\226\1\255\23\0\4\255\23\222\1\0\12\245\1\255\23\0\16\21\1\175\1\255\t\242\1\0\12\254\1\255\23\0\17\23\1\255\t\252\1\0\12\254\1\255\23\21\1\0\16\24\1\255\t\252\1\0\12\245\1\255\23\175\1\22\1\0\14\23\1\177\1\255\t\242\1\0\12\225\1\2552\223\1\0\12\196\1\2552\193\1\0\12\156\1\2552\152\1\0\12j\1\2552f\1\0\12.\1\2552)\1\0\12\1\1\228\1\2550\225\1\0\14\147\1\2550\142\1\0\0144\1\25501\1\0\15\201\1\255.\197\1\0\16R\1\255.M\1\0\16\1\1\203\1\255,\199\1\1\1\0\17:\1\253\1\255*\253\0015\1\0\19\148\1\255*\145\1\0\20\n\1\212\1\255(\209\1\t\1\0\21'\1\239\1\255&\238\1%\1\0\23@\1\247\1\255$\247\1?\1\0\25K\1\248\1\255\"\247\1J\1\0\27A\1\239\1\255 \238\1?\1\0\29'\1\212\1\255\30\209\1%\1\0\31\t\1\147\1\253\1\255\26\253\1\145\1\t\1\0\"7\1\201\1\255\24\199\0015\1\0%\1\1O\1\199\1\255\20\197\1M\1\1\1\0)2\1\144\1\226\1\255\14\225\1\142\0011\1\0/*\1g\1\153\1\193\1\223\1\242\1\255\2\242\1\223\1\192\1\152\1f\1)\1\0\255\0\154",
		},
		cloudUp = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\163\12\1M\1\137\1\185\1\219\1\243\1\255\2\243\1\219\1\185\1\137\1M\1\12\1\0/\2\1J\1\174\1\247\1\255\12\247\1\173\1G\1\1\1\0*\1\1T\1\214\1\255\18\211\1Q\1\0(%\1\190\1\255\22\187\1!\1\0%^\1\244\1\255\24\242\1W\1\0\"\1\1\138\1\255\27\254\1\130\1\0 \1\1\155\1\255\30\146\1\1\1\0\30\139\1\255 \131\1\0\29`\1\255\"W\1\0\27%\1\245\1\255\"\242\1!\1\0\25\1\1\192\1\255$\187\1\0\25T\1\255&P\1\0\16\15\1Y\1\128\1\14\1\0\3\2\1\213\1\255\17\171\1\20\1\21\1\171\1\255\17\210\1\1\1\0\r&\1\157\1\247\1\255\2X\1\0\3K\1\255\17\168\1\4\1\0\2\4\1\168\1\255\17G\1\0\11\n\1\141\1\251\1\255\3\254\1\26\1\0\3\175\1\255\16\168\1\4\1\0\4\4\1\168\1\255\16\172\1\0\n%\1\212\1\255\5\209\1\0\3\r\1\248\1\255\15\168\1\4\1\0\6\4\1\168\1\255\15\246\1\11\1\0\0081\1\234\1\255\6\148\1\0\3O\1\255\15\168\1\4\1\0\8\4\1\168\1\255\15K\1\0\7$\1\235\1\255\7c\1\0\3\138\1\255\14\168\1\4\1\0\n\4\1\168\1\255\14\135\1\0\6\n\1\211\1\255\8:\1\0\3\185\1\255\r\168\1\4\1\0\3\4\1\0\4\4\1\0\3\4\1\168\1\255\r\181\1\0\6\141\1\255\t\29\1\0\3\220\1\255\12\168\1\4\1\0\3\4\1\168\1\0\4\168\1\4\1\0\3\4\1\168\1\255\12\217\1\0\5&\1\250\1\255\t\t\1\0\3\243\1\255\11\170\1\4\1\0\3\4\1\168\1\255\1\0\4\255\1\168\1\4\1\0\3\4\1\172\1\255\11\240\1\0\5\158\1\255\n\0\4\254\1\255\11\21\1\0\3\4\1\168\1\255\2\0\4\255\2\168\1\4\1\0\3\23\1\255\11\252\1\0\4\15\1\246\1\255\n\21\1\0\2\26\1\255\12\22\1\0\2\4\1\168\1\255\3\0\4\255\3\168\1\4\1\0\2\24\1\255\11\251\1\0\4Z\1\255\11\174\1\22\1\24\1\181\1\255\12\175\1\23\2\172\1\255\4\0\4\255\4\172\1\23\2\177\1\255\11\238\1\0\4\157\1\255#\0\4\255\19\214\1\0\4\205\1\255#\0\4\255\19\179\1\0\4\238\1\255#\0\4\255\19\131\1\0\4\253\1\255#\0\4\255\19G\1\0\4\253\1\255#\0\4\255\18\245\1\t\1\0\4\237\1\255#\0\4\255\18\169\1\0\5\204\1\255#\0\4\255\18E\1\0\5\154\1\255#\0\4\255\17\208\1\1\1\0\5U\1\255#\0\4\255\17N\1\0\6\11\1\242\1\255\"\0\4\255\16\186\1\0\8\145\1\255\"\21\1\0\2\24\1\255\15\241\1 \1\0\8\27\1\245\1\255!\175\1\22\1\23\1\177\1\255\14\254\1W\1\0\nw\1\2553\132\1\0\11\3\1\191\1\2551\149\1\1\1\0\12\21\1\218\1\255.\254\1\131\1\1\1\0\14\29\1\216\1\255,\241\1V\1\0\17\18\1\184\1\255*\184\1!\1\0\19\1\1k\1\239\1\255&\208\1N\1\0\23\19\1\131\1\233\1\255!\245\1\167\1E\1\1\1\0\26\5\1F\1\141\1\192\1\230\1\250\1\255\23\239\1\214\1\179\1\132\1H\1\n\1\0\255\0\255\0\147",
		},
		code = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\137+\1\180\1\246\1\255,\246\1\178\1)\1\0\r+\1\241\1\2550\240\1(\1\0\12\180\1\2552\176\1\0\12\246\1\2552\243\1\0\12\2554\0\12\2554\0\12\255\28\178\1\29\1 \1\183\1\255\20\0\12\255\27\252\1\21\1\0\2\29\1\255\20\0\12\255\27\198\1\0\3\22\1\255\20\0\12\255\27}\1\0\3Z\1\255\20\0\12\255\0274\1\0\3\163\1\255\20\0\12\255\26\234\1\2\1\0\2\2\1\233\1\255\20\0\12\255\26\162\1\0\0035\1\255\21\0\12\255\26Y\1\0\3~\1\255\21\0\12\255\14\159\1\20\1\21\1\175\1\255\7\252\1\19\1\0\3\199\1\255\3\173\1\21\2\160\1\255\14\0\12\255\12\244\1_\1\0\3\24\1\255\7\198\1\0\3\19\1\252\1\255\3\20\1\0\3_\1\244\1\255\12\0\12\255\11\213\1*\1\0\4\24\1\255\7~\1\0\3Y\1\255\4\22\1\0\4*\1\213\1\255\11\0\12\255\n\159\1\n\1\0\4\n\1\176\1\255\0075\1\0\3\162\1\255\4\174\1\n\1\0\4\n\1\159\1\255\n\0\12\255\8\246\1f\1\0\5(\1\210\1\255\7\234\1\2\1\0\2\2\1\233\1\255\5\215\1-\1\0\5^\1\244\1\255\8\0\12\255\7\215\1-\1\0\5^\1\244\1\255\8\162\1\0\0035\1\255\7\246\1o\1\0\5(\1\210\1\255\7\0\12\255\6\173\1\n\1\0\4\11\1\159\1\255\nY\1\0\3~\1\255\t\159\1\11\1\0\4\n\1\175\1\255\6\0\12\255\6\21\1\0\4+\1\213\1\255\n\252\1\19\1\0\3\199\1\255\n\213\1+\1\0\4\24\1\255\6\0\12\255\6\22\1\0\4+\1\213\1\255\n\198\1\0\3\19\1\252\1\255\n\213\1+\1\0\4\24\1\255\6\0\12\255\6\174\1\n\1\0\4\11\1\159\1\255\t~\1\0\3Y\1\255\n\159\1\11\1\0\4\11\1\176\1\255\6\0\12\255\7\215\1-\1\0\5^\1\244\1\255\0074\1\0\3\163\1\255\8\246\1o\1\0\5(\1\210\1\255\7\0\12\255\8\246\1f\1\0\5(\1\210\1\255\5\234\1\2\1\0\2\2\1\233\1\255\7\215\1-\1\0\5^\1\244\1\255\8\0\12\255\n\159\1\n\1\0\4\n\1\175\1\255\4\162\1\0\0035\1\255\7\173\1\n\1\0\4\11\1\160\1\255\n\0\12\255\11\213\1*\1\0\4\24\1\255\4Y\1\0\3~\1\255\7\21\1\0\4+\1\213\1\255\11\0\12\255\12\244\1_\1\0\3\25\1\255\3\252\1\19\1\0\3\199\1\255\7\21\1\0\3`\1\245\1\255\12\0\12\255\14\160\1\23\1\24\1\177\1\255\3\198\1\0\3\19\1\252\1\255\7\175\1\23\1\24\1\161\1\255\14\0\12\255\21}\1\0\3Z\1\255\26\0\12\255\0214\1\0\3\163\1\255\26\0\12\255\20\234\1\2\1\0\2\2\1\233\1\255\26\0\12\255\20\162\1\0\0035\1\255\27\0\12\255\20Y\1\0\3~\1\255\27\0\12\255\19\254\1\19\1\0\3\199\1\255\27\0\12\255\19\254\1\17\1\0\2\22\1\252\1\255\27\0\12\255\20\166\1\15\1\16\1\172\1\255\28\0\12\255\22\254\1\255\29\0\12\2554\0\12\245\1\2552\243\1\0\12\179\1\2552\175\1\0\12)\1\240\1\2550\239\1'\1\0\r(\1\177\1\244\1\255,\243\1\175\1'\1\0\255\0\255\0\137",
		},
		copy = {
			w = 64,
			h = 64,
			data = "\0\255\0\255\0\22R\1\235\1\255 \234\1P\1\0\28\235\1\255\"\232\1\0\28\255$\0\28\255$\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\28\255\4\0\16R\1\235\1\255 \234\1P\1\0\8\255\4\0\16\235\1\255\"\232\1\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\255$\0\8\255\4\0\16\2550\0\16\2550\0\16\255/\231\1\0\16\255.\232\1N\1\0\16\255$\0\28\255$\0\28\255$\0\28\255$\0\28\255$\0\28\255$\0\28\255$\0\28\255$\0\28\255$\0\28\255$\0\28\234\1\255\"\231\1\0\28P\1\233\1\255 \232\1N\1\0\255\0\255\0\22",
		},
	}

	r5.crosshair = {
		w = 64,
		h = 64,
		data = "\0\255\0\31R\1\235\1\234\1P\1\0<\235\1\255\2\232\1\0<\255\4\0<\255\4\0007\27\1]\1\148\1\190\1\221\1\255\4\221\1\189\1\147\1\\\1\25\1\0/\19\1p\1\204\1\255\r\254\1\202\1o\1\18\1\0*\27\1\147\1\245\1\255\18\245\1\146\1\25\1\0&\6\1{\1\245\1\255\22\244\1x\1\5\1\0#*\1\207\1\255\6\252\1\196\1\129\1N\1)\1\255\4)\1O\1\130\1\197\1\252\1\255\6\205\1(\1\0!Q\1\243\1\255\5\225\1u\1\24\1\0\4\255\4\0\4\25\1w\1\226\1\255\5\242\1O\1\0\31j\1\253\1\255\4\233\1g\1\5\1\0\6\234\1\255\2\231\1\0\6\6\1i\1\234\1\255\4\253\1h\1\0\29j\1\254\1\255\4\164\1\17\1\0\8P\1\233\1\232\1N\1\0\8\19\1\167\1\255\4\254\1h\1\0\27Q\1\253\1\255\3\249\1e\1\0\24g\1\250\1\255\3\252\1N\1\0\25*\1\243\1\255\3\246\1G\1\0\26I\1\246\1\255\3\242\1'\1\0\23\6\1\207\1\255\3\249\1G\1\0\28J\1\250\1\255\3\205\1\5\1\0\22{\1\255\4e\1\0\30i\1\255\4w\1\0\21\26\1\244\1\255\3\164\1\0 \167\1\255\3\243\1\23\1\0\20\147\1\255\3\233\1\17\1\0 \19\1\235\1\255\3\143\1\0\19\19\1\245\1\255\3g\1\0\12\t\1_\1\174\1\226\1\253\1\251\1\226\1\175\1^\1\8\1\0\12k\1\255\3\244\1\17\1\0\18q\1\255\3\225\1\5\1\0\11Z\1\230\1\255\8\228\1X\1\0\11\6\1\227\1\255\3m\1\0\18\204\1\255\3u\1\0\n\3\1\153\1\255\12\150\1\2\1\0\ny\1\255\3\199\1\0\17\27\1\254\1\255\2\252\1\24\1\0\n\154\1\255\14\149\1\0\n\27\1\253\1\255\2\254\1\24\1\0\16]\1\255\3\196\1\0\n[\1\255\16V\1\0\n\200\1\255\3X\1\0\16\147\1\255\3\130\1\0\t\8\1\230\1\255\16\227\1\7\1\0\t\135\1\255\3\143\1\0\16\190\1\255\3N\1\0\t]\1\255\18[\1\0\tR\1\255\3\186\1\0\16\222\1\255\3(\1\0\t\174\1\255\18\172\1\0\t*\1\255\3\220\1\0\12R\1\235\1\255\8\234\1P\1\0\6\226\1\255\18\224\1\0\6R\1\235\1\255\8\234\1P\1\0\8\235\1\255\n\232\1\0\6\252\1\255\18\249\1\0\6\235\1\255\n\232\1\0\8\234\1\255\n\231\1\0\6\252\1\255\18\249\1\0\6\234\1\255\n\231\1\0\8P\1\233\1\255\8\232\1N\1\0\6\226\1\255\18\223\1\0\6P\1\233\1\255\8\232\1N\1\0\12\221\1\255\3(\1\0\t\173\1\255\18\171\1\0\t+\1\255\3\219\1\0\16\189\1\255\3O\1\0\t]\1\255\18Y\1\0\tR\1\255\3\186\1\0\16\147\1\255\3\131\1\0\t\8\1\228\1\255\16\225\1\7\1\0\t\135\1\255\3\142\1\0\16\\\1\255\3\197\1\0\nW\1\255\16T\1\0\n\201\1\255\3W\1\0\16\26\1\254\1\255\2\252\1\25\1\0\n\149\1\255\14\146\1\0\n\28\1\253\1\255\2\253\1\23\1\0\17\202\1\255\3v\1\0\n\2\1\149\1\255\12\147\1\2\1\0\n{\1\255\3\197\1\0\18o\1\255\3\226\1\6\1\0\11V\1\227\1\255\8\227\1U\1\0\11\7\1\228\1\255\3k\1\0\18\18\1\245\1\255\3i\1\0\12\7\1Z\1\170\1\223\1\250\1\249\1\222\1\171\1[\1\7\1\0\12m\1\255\3\243\1\16\1\0\19\146\1\255\3\234\1\19\1\0 \21\1\236\1\255\3\142\1\0\20\25\1\244\1\255\3\167\1\0 \170\1\255\3\242\1\22\1\0\21x\1\255\4h\1\0\30k\1\255\4t\1\0\22\5\1\205\1\255\3\250\1I\1\0\28L\1\251\1\255\3\203\1\4\1\0\23(\1\242\1\255\3\246\1J\1\0\26L\1\246\1\255\3\241\1%\1\0\25O\1\253\1\255\3\250\1i\1\0\24k\1\251\1\255\3\252\1M\1\0\27h\1\254\1\255\4\168\1\19\1\0\8R\1\235\1\234\1P\1\0\8\21\1\170\1\255\4\254\1f\1\0\29h\1\252\1\255\4\235\1k\1\6\1\0\6\235\1\255\2\232\1\0\6\6\1m\1\236\1\255\4\252\1f\1\0\31O\1\242\1\255\5\227\1y\1\27\1\0\4\255\4\0\4\28\1{\1\228\1\255\5\241\1M\1\0!'\1\205\1\255\6\253\1\200\1\134\1R\1*\1\255\4+\1S\1\136\1\201\1\253\1\255\6\203\1%\1\0#\5\1w\1\243\1\255\22\242\1t\1\4\1\0&\23\1\143\1\244\1\255\18\243\1\142\1\22\1\0*\16\1m\1\199\1\254\1\255\12\253\1\197\1k\1\16\1\0/\23\1X\1\143\1\186\1\219\1\255\4\219\1\186\1\142\1W\1\23\1\0007\255\4\0<\255\4\0<\234\1\255\2\231\1\0<P\1\233\1\232\1N\1\0\255\0\31",
	}

	r5.crouch = {
		w = 64,
		h = 64,
		data = "\0\255\0\159R\1\235\1\234\1P\1\0<\235\1\255\2\232\1\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0*S\1\235\1\255$\234\1O\1\0\24\234\1\255&\232\1\0\24\234\1\255&\231\1\0\24T\1\251\1\255$\251\1S\1\0\25T\1\251\1\255\"\252\1[\1\0\27T\1\251\1\255 \252\1[\1\0\29T\1\251\1\255\30\252\1[\1\0\31T\1\251\1\255\28\252\1[\1\0!T\1\251\1\255\26\252\1[\1\0#T\1\251\1\255\24\252\1[\1\0%T\1\251\1\255\22\252\1[\1\0'T\1\251\1\255\20\252\1[\1\0)T\1\251\1\255\18\252\1[\1\0+T\1\251\1\255\16\252\1[\1\0-T\1\251\1\255\14\252\1[\1\0/T\1\251\1\255\12\252\1[\1\0001T\1\251\1\255\n\252\1[\1\0003T\1\251\1\255\8\252\1[\1\0005T\1\251\1\255\6\252\1[\1\0007T\1\251\1\255\4\252\1[\1\0009T\1\251\1\255\2\252\1[\1\0;S\1\232\2S\1\0\255\0'R\1\235\1\255,\234\1P\1\0\16\235\1\255.\232\1\0\16\234\1\255.\231\1\0\16P\1\233\1\255,\232\1N\1\0\255\0\255\0\n",
	}

	r5.download = {
		w = 64,
		h = 64,
		data = "\0\255\0\159R\1\235\1\234\1P\1\0<\235\1\255\2\232\1\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0002S\1\235\1\255\20\234\1O\1\0(\234\1\255\22\232\1\0(\234\1\255\22\231\1\0(T\1\251\1\255\20\251\1S\1\0)T\1\251\1\255\18\252\1[\1\0+T\1\251\1\255\16\252\1[\1\0-T\1\251\1\255\14\252\1[\1\0/T\1\251\1\255\12\252\1[\1\0001T\1\251\1\255\n\252\1[\1\0003T\1\251\1\255\8\252\1[\1\0\"R\1\235\1\234\1P\1\0\15W\1\251\1\255\6\251\1W\1\0\15R\1\235\1\234\1P\1\0\16\235\1\255\2\232\1\0\16W\1\251\1\255\4\251\1W\1\0\16\235\1\255\2\232\1\0\16\255\4\0\17T\1\251\1\255\2\252\1[\1\0\17\255\4\0\16\255\4\0\18S\1\232\2S\1\0\18\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\2550\0\16\2550\0\16\234\1\255.\231\1\0\16P\1\233\1\255,\232\1N\1\0\255\0\255\0\138",
	}

	r5.drop = {
		w = 64,
		h = 64,
		data = "\0\158b\1\235\1\233\1]\1\0:\t\1\159\1\255\4\154\1\7\1\0007\27\1\203\1\255\6\198\1\24\1\00050\1\229\1\255\8\225\1,\1\0003B\1\242\1\255\n\240\1?\1\0001P\1\248\1\255\12\246\1K\1\0/T\1\250\1\255\14\249\1P\1\0-O\1\250\1\255\16\249\1L\1\0+B\1\248\1\255\18\247\1?\1\0)-\1\241\1\255\20\240\1-\1\0'\26\1\226\1\255\22\225\1\24\1\0%\8\1\201\1\255\24\199\1\7\1\0$\156\1\255\26\153\1\0#^\1\255\28[\1\0!$\1\243\1\255\28\241\1!\1\0\31\2\1\195\1\255\30\192\1\2\1\0\30j\1\255 g\1\0\29\23\1\240\1\255 \238\1\21\1\0\28\154\1\255\"\151\1\0\27)\1\252\1\255\"\251\1&\1\0\26\165\1\255$\162\1\0\25!\1\252\1\255$\251\1\31\1\0\24\141\1\255&\138\1\0\23\7\1\236\1\255&\234\1\6\1\0\22R\1\255(N\1\0\22\167\1\255(\162\1\0\21\3\1\238\1\255(\235\1\2\1\0\0204\1\255*1\1\0\20m\1\255*j\1\0\20\157\1\255*\153\1\0\20\196\1\255*\192\1\0\20\225\1\255*\221\1\0\20\244\1\255*\242\1\0\20\254\1\255*\253\1\0\20\253\1\255\31\173\1\20\1\21\1\174\1\255\7\251\1\0\20\242\1\255\30\254\1\21\1\0\2\23\1\255\7\239\1\0\20\219\1\255\30\214\1\0\3\19\1\255\7\217\1\0\20\185\1\255\30\130\1\0\3O\1\255\7\181\1\0\20\138\1\255\29\245\1\25\1\0\3\157\1\255\7\133\1\0\20M\1\255\29w\1\0\3\14\1\242\1\255\7J\1\0\20\r\1\247\1\255\27\179\1\2\1\0\3{\1\255\7\246\1\11\1\0\21\174\1\255\26\179\1\t\1\0\3\29\1\242\1\255\7\169\1\0\22J\1\255\24\245\1w\1\3\1\0\3\4\1\190\1\255\8F\1\0\22\2\1\213\1\255\20\254\1\213\1\130\1\24\1\0\5\150\1\255\8\210\1\1\1\0\23T\1\255\19\173\1\21\1\0\6\3\1\150\1\255\tQ\1\0\24\1\1\191\1\255\18\21\1\0\6\28\1\189\1\255\t\188\1\0\26%\1\244\1\255\17\22\1\0\4\14\1z\1\242\1\255\t\242\1\"\1\0\27]\1\255\17\175\1\23\1\17\1N\1\156\1\241\1\255\11Z\1\0\29\137\1\255 \132\1\0\30\1\1\153\1\255\30\150\1\1\1\0\31\1\1\137\1\255\28\133\1\1\1\0\"\\\1\243\1\255\24\242\1Z\1\0%#\1\190\1\255\22\189\1\"\1\0(S\1\211\1\255\18\210\1Q\1\0+\1\1H\1\171\1\246\1\255\12\246\1\169\1F\1\1\1\0/\11\1K\1\134\1\182\1\217\1\240\1\255\2\240\1\216\1\181\1\132\1J\1\n\1\0\255\0\154",
	}

	r5.eye = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\255\0\27&\1\\\1\139\1\178\1\210\1\232\1\248\1\255\2\248\1\232\1\211\1\178\1\139\1\\\1%\1\0,\4\1G\1\154\1\228\1\255\16\227\1\153\1F\1\3\1\0&\25\1\130\1\230\1\255\22\229\1\128\1\23\1\0\"\25\1\149\1\248\1\255\26\247\1\146\1\23\1\0\30\6\1y\1\244\1\255\30\242\1u\1\5\1\0\0270\1\210\1\255\"\207\1-\1\0\25m\1\248\1\255$\247\1h\1\0\22\6\1\159\1\255(\154\1\5\1\0\19\r\1\189\1\255*\185\1\12\1\0\17\14\1\198\1\255,\196\1\r\1\0\15\n\1\196\1\255\18\247\1\161\1Q\1\29\1\1\1\3\1\30\1R\1\162\1\247\1\255\18\193\1\t\1\0\r\3\1\178\1\255\18\165\1\26\1\0\8\26\1\167\1\255\18\174\1\2\1\0\12\139\1\255\17\253\1g\1\0\12i\1\253\1\255\17\136\1\0\11T\1\254\1\255\17g\1\0\14j\1\255\17\254\1Q\1\0\t\31\1\240\1\255\17\165\1\0\16\168\1\255\17\238\1\28\1\0\7\1\1\188\1\255\17\247\1\26\1\0\16\28\1\248\1\255\17\185\1\1\1\0\6_\1\255\18\161\1\0\18\164\1\255\18]\1\0\5\14\1\232\1\255\18Q\1\0\18S\1\255\18\230\1\12\1\0\4\128\1\255\19\29\1\0\18\31\1\255\19|\1\0\4\234\1\255\19\3\1\0\18\5\1\255\19\232\1\0\4\234\1\255\19\4\1\0\18\6\1\255\19\232\1\0\4~\1\255\19\29\1\0\18 \1\255\19z\1\0\4\r\1\231\1\255\18Q\1\0\18U\1\255\18\228\1\11\1\0\5^\1\255\18\162\1\0\18\165\1\255\18Z\1\0\6\1\1\186\1\255\17\247\1\27\1\0\16\30\1\248\1\255\17\182\1\0\8\29\1\239\1\255\17\167\1\0\16\171\1\255\17\236\1\27\1\0\tS\1\254\1\255\17i\1\0\14l\1\255\17\254\1M\1\0\11\138\1\255\17\253\1j\1\0\12l\1\253\1\255\17\132\1\0\12\3\1\176\1\255\18\168\1\28\1\0\8\30\1\171\1\255\18\172\1\2\1\0\r\t\1\194\1\255\18\248\1\164\1S\1\31\1\4\1\5\1 \1T\1\165\1\248\1\255\18\191\1\8\1\0\15\14\1\197\1\255,\196\1\r\1\0\17\12\1\187\1\255*\183\1\11\1\0\19\6\1\156\1\255(\151\1\4\1\0\22g\1\247\1\255$\246\1c\1\0\25-\1\207\1\255\"\204\1*\1\0\27\5\1u\1\241\1\255\30\239\1p\1\4\1\0\30\22\1\144\1\246\1\255\26\245\1\141\1\20\1\0\"\22\1\127\1\227\1\255\22\226\1~\1\21\1\0&\2\1C\1\151\1\223\1\255\16\222\1\149\1A\1\2\1\0, \1Y\1\136\1\175\1\207\1\230\1\244\1\255\2\244\1\229\1\207\1\174\1\136\1Y\1 \1\0\255\0\255\0\255\0\27",
	}

	r5.flagPiece = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\18\23\1g\1\169\1\217\1\245\1\255\1\249\1\226\1\190\1\139\1J\1\t\1\0002.\1\169\1\251\1\255\n\244\1\165\1D\1\1\1\0-\14\1\151\1\253\1\255\15\217\1i\1\t\1\0*5\1\222\1\255\19\233\1x\1\r\1\0'P\1\247\1\255\22\236\1|\1\15\1\0\17X\1\233\1\231\1N\1\0\16\233\1\255\25\239\1\133\1\23\1\0\r\t\1\145\1\254\1\255\2\231\1\0\16\255\28\247\1\159\1:\1\0\t\1\1Q\1\218\1\255\5\0\16\255\31\222\1\145\1Q\1#\1\n\1\1\1\22\1>\1\127\1\216\1\255\7\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\7\213\1{\0019\1\17\1\0\1\7\1\"\1O\1\143\1\220\1\255\31\0\16\255\5\215\1L\1\1\1\0\t9\1\158\1\247\1\255\28\0\16\255\4\141\1\7\1\0\r\22\1\132\1\239\1\255\25\230\1\0\16\255\4\0\17\15\1}\1\237\1\255\22\246\1M\1\0\16\255\4\0\19\r\1x\1\233\1\255\19\219\0010\1\0\17\255\4\0\21\t\1i\1\216\1\255\15\251\1\145\1\12\1\0\18\255\4\0\23\1\1D\1\165\1\243\1\255\n\249\1\163\1(\1\0\20\255\4\0\26\t\1I\1\138\1\188\1\226\1\248\1\255\1\242\1\211\1\164\1c\1\19\1\0\22\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\234\1\255\2\231\1\0<P\1\233\1\232\1N\1\0\255\0\179",
	}

	r5.flask = {
		w = 64,
		h = 64,
		data = "\0\255\0\149R\1\235\1\255\20\234\1P\1\0(\235\1\255\22\232\1\0(\234\1\255\22\231\1\0(P\1\233\1\255\20\232\1N\1\0,\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0000\255\4\0\8\255\4\0/-\1\255\4\0\8\255\4-\1\0-\1\1\193\1\255\3\214\1\0\8\215\1\255\3\193\1\1\1\0,]\1\255\4M\1\0\8N\1\255\4\\\1\0+\r\1\229\1\255\3\184\1\0\n\179\1\255\3\232\1\15\1\0*\143\1\255\3\248\1&\1\0\n#\1\247\1\255\3\142\1\0)+\1\250\1\255\3\128\1\0\12\129\1\255\3\251\1/\1\0'\1\1\191\1\255\3\225\1\n\1\0\12\t\1\221\1\255\3\195\1\1\1\0&]\1\255\4M\1\0\14N\1\255\4\\\1\0%\r\1\229\1\255\3\184\1\0\16\179\1\255\3\232\1\15\1\0$\143\1\255\3\248\1&\1\0\16#\1\247\1\255\3\142\1\0#+\1\250\1\255\3\128\1\0\18\129\1\255\3\251\1/\1\0!\1\1\191\1\255\3\225\1\n\1\0\18\t\1\222\1\255\3\195\1\1\1\0 \\\1\255\5\239\1\213\1\173\1~\1A\1\7\1\0\14N\1\255\4\\\1\0\31\14\1\230\1\255\n\243\1\168\1L\1\3\1\0\12\181\1\255\3\230\1\14\1\0\30\143\1\255\14\226\1u\1\14\1\0\n#\1\247\1\255\3\143\1\0\29-\1\251\1\255\16\237\1\127\1\19\1\0\t\130\1\255\3\251\1-\1\0\27\1\1\193\1\255\19\245\1\157\1<\1\2\1\0\6\t\1\223\1\255\3\193\1\1\1\0\26[\1\255\23\230\1\160\1d\0015\1\23\1\2\1\0\1\19\1{\1\255\4[\1\0\25\r\1\229\1\255$\232\1\15\1\0\24\143\1\255&\142\1\0\23+\1\250\1\255&\251\1/\1\0\22\191\1\255(\195\1\1\1\0\20\\\1\255*[\1\0\19\r\1\229\1\255*\232\1\15\1\0\18\142\1\255,\141\1\0\17,\1\251\1\255,\251\1,\1\0\16\177\1\255.\176\1\0\16\244\1\255.\242\1\0\16\244\1\255.\243\1\0\16\176\1\255.\176\1\0\16(\1\239\1\255,\238\1'\1\0\17'\1\175\1\243\1\255(\244\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.gauge = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\154\5\1;\1s\1\162\1\197\1\155\1\0\4\161\1\200\1\165\1v\1>\1\7\1\0-\6\1R\1\171\1\242\1\255\5\0\4\255\5\244\1\175\1X\1\8\1\0(\19\1\127\1\232\1\255\8\0\4\255\8\237\1\136\1\24\1\0$\t\1}\1\242\1\255\n\0\4\255\n\245\1\136\1\r\1\0!D\1\221\1\255\12\0\4\255\12\229\1P\1\0\30\5\1\141\1\254\1\255\r\0\4\255\14\158\1\n\1\0\27\19\1\194\1\255\15\0\4\255\15\208\1\30\1\0\25\31\1\217\1\255\16\0\4\255\16\229\1+\1\0\23\30\1\223\1\255\17\21\1\0\2\26\1\255\17\234\1+\1\0\21\18\1\216\1\255\18\174\1\22\1\24\1\180\1\255\18\229\1\30\1\0\19\4\1\190\1\255*\208\1\n\1\0\18\135\1\255,\158\1\0\17<\1\253\1\255\30\174\1\21\1\22\1\178\1\255\11Q\1\0\15\6\1\215\1\255\30\216\1\12\1\0\2\29\1\255\11\229\1\14\1\0\14s\1\255\30\248\0012\1\0\3\28\1\255\12\135\1\0\r\14\1\236\1\255\30p\1\0\4\158\1\255\12\245\1\24\1\0\12t\1\255\30\181\1\1\1\0\3W\1\255\14\135\1\0\11\3\1\225\1\255\29\230\1\22\1\0\3!\1\240\1\255\14\236\1\8\1\0\nF\1\255\29\253\1D\1\0\3\5\1\199\1\255\16W\1\0\n\158\1\255\29\136\1\0\4\134\1\255\17\174\1\0\t\1\1\233\1\255\28\201\1\5\1\0\3C\1\253\1\255\17\244\1\6\1\0\8\1\1\205\1\255\27\241\1\"\1\0\3\21\1\229\1\255\18\216\1\6\1\0\16\23\1\178\1\255\19Z\1\0\3\1\1\180\1\255\11\176\1\22\1\0\25\23\1\255\18\160\1\0\4o\1\255\12\22\1\0\26\23\1\255\17\217\1\12\1\0\0030\1\248\1\255\12\22\1\0\25\23\1\176\1\255\16\249\0012\1\0\3\11\1\216\1\255\r\175\1\23\1\0\16\195\1\255\25r\1\0\4\157\1\255\23\196\1\0\8\253\1\255\24\182\1\1\1\0\3X\1\255\24\254\1\0\8\255\24\231\1\22\1\0\3!\1\240\1\255\25\0\8\255\23\253\1E\1\0\3\4\1\198\1\255\26\0\8\255\23\136\1\0\4\134\1\255\27\0\8\255\22\203\1\6\1\0\3?\1\252\1\255\27\0\8\255\21\243\1&\1\0\3\21\1\229\1\255\28\0\8\255\21\\\1\0\3\1\1\177\1\255\29\0\8\245\1\255\19\161\1\0\4o\1\255\29\243\1\0\8\179\1\255\18\218\1\12\1\0\0031\1\248\1\255\29\175\1\0\8)\1\240\1\255\16\249\0013\1\0\3\1\1\214\1\255\29\239\1'\1\0\t(\1\177\1\244\1\255\r\252\1k\1\0\4\1\1\204\1\255\27\243\1\175\1'\1\0\255\0\255\0\255\0\255\0\t",
	}

	r5.gear = {
		w = 64,
		h = 64,
		data = "\0\255\0\149\r\1i\1\198\1\252\1\184\1/\1\0\12.\1\183\1\250\1\195\1d\1\11\1\0&\19\1\133\1\240\1\255\4\253\1\156\1\26\1\0\8\25\1\156\1\252\1\255\4\238\1\131\1\18\1\0\"\4\1q\1\239\1\255\8\244\1~\1\11\1\0\4\n\1~\1\244\1\255\8\238\1o\1\4\1\0\31,\1\206\1\255\12\228\1a\1\2\2`\1\228\1\255\12\204\1+\1\0\29c\1\247\1\255\15\207\2\255\15\246\1b\1\0\27~\1\255$~\1\0\25\2\1\248\1\255$\247\1\2\1\0\24\7\1\255&\6\1\0\24\8\1\255&\7\1\0\24\t\1\255&\8\1\0\24\n\1\255&\t\1\0\24\12\1\255&\n\1\0\24\r\1\255&\n\1\0\24\14\1\255&\11\1\0\24\15\1\255&\12\1\0\23\14\1\139\1\255&\141\1\15\1\0\20\2\1d\1\232\1\255\15\247\1\161\1Q\1\29\1\1\1\3\1\30\1R\1\162\1\247\1\255\15\233\1g\1\3\1\0\17A\1\207\1\255\16\165\1\26\1\0\8\26\1\167\1\255\16\209\1C\1\0\14#\1\174\1\255\16\253\1g\1\0\12i\1\253\1\255\16\177\1%\1\0\n\3\1\135\1\248\1\255\17g\1\0\14j\1\255\17\249\1\137\1\2\1\0\8a\1\255\18\165\1\0\16\168\1\255\18^\1\0\8\158\1\255\17\247\1\26\1\0\16\28\1\248\1\255\17\155\1\0\8\198\1\255\17\161\1\0\18\164\1\255\17\194\1\0\8\226\1\255\17Q\1\0\18S\1\255\17\223\1\0\8\247\1\255\17\29\1\0\18\31\1\255\17\242\1\0\7\1\1\255\18\3\1\0\18\5\1\255\17\251\1\0\7\1\1\255\18\4\1\0\18\6\1\255\17\251\1\0\8\247\1\255\17\29\1\0\18 \1\255\17\242\1\0\8\227\1\255\17Q\1\0\18U\1\255\17\223\1\0\8\198\1\255\17\162\1\0\18\165\1\255\17\194\1\0\8\159\1\255\17\247\1\27\1\0\16\30\1\248\1\255\17\155\1\0\8c\1\255\18\167\1\0\16\171\1\255\18^\1\0\8\3\1\141\1\250\1\255\17i\1\0\14l\1\255\17\248\1\132\1\2\1\0\n(\1\181\1\255\16\253\1j\1\0\12l\1\253\1\255\16\174\1#\1\0\14G\1\213\1\255\16\168\1\28\1\0\8\30\1\171\1\255\16\207\1A\1\0\17\4\1k\1\236\1\255\15\248\1\164\1S\1\31\1\4\1\5\1 \1T\1\165\1\248\1\255\15\232\1d\1\2\1\0\20\17\1\145\1\255&\139\1\14\1\0\23\15\1\255&\14\1\0\24\14\1\255&\r\1\0\24\r\1\255&\12\1\0\24\r\1\255&\11\1\0\24\12\1\255&\t\1\0\24\11\1\255&\8\1\0\24\n\1\255&\7\1\0\24\t\1\255&\6\1\0\24\4\1\249\1\255$\246\1\2\1\0\25\131\1\255$z\1\0\27f\1\247\1\255\15\207\2\255\15\244\1]\1\0\29-\1\206\1\255\12\228\1a\1\2\2a\1\228\1\255\12\200\1(\1\0\31\4\1r\1\239\1\255\8\244\1\127\1\11\1\0\4\11\1~\1\244\1\255\8\237\1k\1\3\1\0\"\18\1\132\1\240\1\255\4\253\1\157\1\26\1\0\8\26\1\156\1\253\1\255\4\237\1\128\1\15\1\0&\12\1g\1\198\1\250\1\184\0010\1\0\12/\1\183\1\250\1\195\1b\1\n\1\0\255\0\149",
	}

	r5.globe = {
		w = 64,
		h = 64,
		data = "\0\255\0\153\1\1/\1k\1\156\1\196\1\228\1\245\1\255\2\244\1\225\1\195\1\155\1i\1,\1\0/5\1\148\1\229\1\255\14\226\1\145\0011\1\0)\1\1T\1\202\1\255\20\198\1N\1\1\1\0%<\1\205\1\255\24\200\0016\1\0\"\11\1\151\1\254\1\255\12\247\2\255\4\204\1\243\1\255\6\253\1\144\1\t\1\0\31)\1\214\1\255\r\252\1P\1S\1\253\1\255\3\190\1\n\1Q\1\182\1\254\1\255\5\209\1$\1\0\29C\1\241\1\255\14u\1\0\2{\1\255\4l\1\0\2+\1\172\1\255\5\237\1=\1\0\27L\1\248\1\255\14\179\1\1\1\0\2\2\1\184\1\255\3\242\1\26\1\0\3A\1\220\1\255\4\246\1G\1\0\25C\1\248\1\255\14\235\1\22\1\0\4\26\1\239\1\255\3\159\1\0\4\12\1\165\1\255\4\246\1=\1\0\23)\1\241\1\255\15c\1\0\6j\1\255\3\252\1*\1\0\5z\1\254\1\255\3\237\1$\1\0\21\11\1\214\1\255\15\206\1\2\1\0\6\3\1\211\1\255\3\164\1\0\6k\1\254\1\255\3\209\1\8\1\0\20\151\1\255\16K\1\0\8Q\1\255\3\251\1\28\1\0\6z\1\255\4\143\1\0\19<\1\254\1\255\15\207\1\1\1\0\8\1\1\213\1\255\3\129\1\0\7\165\1\255\3\253\0015\1\0\17\1\1\205\1\255\16a\1\0\ng\1\255\3\224\1\1\1\0\6\12\1\221\1\255\3\198\1\1\1\0\16T\1\255\16\242\1\11\1\0\n\14\1\245\1\255\0039\1\0\7D\1\255\4L\1\0\16\202\1\255\16\163\1\0\12\169\1\255\3\135\1\0\8\176\1\255\3\196\1\0\0155\1\255\17S\1\0\12X\1\255\3\206\1\0\8.\1\254\1\255\0030\1\0\14\148\1\255\16\252\1\16\1\0\12\20\1\253\1\255\2\253\1\16\1\0\8\185\1\255\3\142\1\0\r\1\1\229\1\255\16\206\1\0\14\212\1\255\3D\1\0\8V\1\255\3\225\1\0\r/\1\255\17\153\1\0\14\158\1\255\3s\1\0\8\n\1\245\1\255\3)\1\0\12k\1\255\17m\1\0\14q\1\255\3\155\1\0\t\182\1\255\3f\1\0\12\157\1\255\17H\1\0\14L\1\255\3\188\1\0\tz\1\255\3\152\1\0\12\197\1\255\17+\1\0\14.\1\255\3\214\1\0\tK\1\255\3\192\1\0\12\226\1\255\17\22\1\0\14\24\1\255\3\233\1\0\t'\1\255\3\222\1\0\12\245\1\2552\242\1\0\12\254\1\2552\252\1\0\12\254\1\2552\252\1\0\12\245\1\2552\242\1\0\12\225\1\255\17\22\1\0\14\23\1\255\3\233\1\0\t'\1\255\3\223\1\0\12\196\1\255\17+\1\0\14.\1\255\3\213\1\0\tL\1\255\3\193\1\0\12\156\1\255\17I\1\0\14L\1\255\3\188\1\0\t{\1\255\3\152\1\0\12j\1\255\17n\1\0\14p\1\255\3\155\1\0\t\183\1\255\3f\1\0\12.\1\255\17\154\1\0\14\158\1\255\3r\1\0\8\11\1\246\1\255\3)\1\0\12\1\1\228\1\255\16\208\1\0\14\211\1\255\3C\1\0\8X\1\255\3\225\1\0\14\147\1\255\16\252\1\17\1\0\12\19\1\253\1\255\2\252\1\15\1\0\8\187\1\255\3\142\1\0\0144\1\255\17U\1\0\12X\1\255\3\204\1\0\0080\1\254\1\255\0031\1\0\15\201\1\255\16\165\1\0\12\168\1\255\3\134\1\0\8\178\1\255\3\197\1\0\16R\1\255\16\243\1\12\1\0\n\r\1\245\1\255\0038\1\0\7F\1\255\4M\1\0\16\1\1\203\1\255\16c\1\0\nf\1\255\3\223\1\1\1\0\6\14\1\223\1\255\3\199\1\1\1\0\17:\1\253\1\255\15\210\1\1\1\0\8\1\1\213\1\255\3\129\1\0\6\1\1\168\1\255\3\253\0015\1\0\19\148\1\255\16M\1\0\8O\1\255\3\250\1\27\1\0\6|\1\255\4\145\1\0\20\n\1\212\1\255\15\208\1\2\1\0\6\3\1\211\1\255\3\162\1\0\6n\1\255\4\209\1\t\1\0\21'\1\239\1\255\15f\1\0\6i\1\255\3\252\1)\1\0\4\1\1}\1\255\4\238\1%\1\0\23@\1\247\1\255\14\238\1\25\1\0\4\27\1\239\1\255\3\157\1\0\4\14\1\169\1\255\4\247\1?\1\0\25K\1\248\1\255\14\183\1\1\1\0\2\2\1\185\1\255\3\241\1\25\1\0\3E\1\223\1\255\4\247\1J\1\0\27A\1\239\1\255\14z\1\0\2|\1\255\4k\1\0\2/\1\177\1\255\5\238\1?\1\0\29'\1\212\1\255\r\253\1S\1T\1\253\1\255\3\189\1\11\1V\1\186\1\254\1\255\5\209\1%\1\0\31\t\1\147\1\253\1\255\12\248\1\247\1\255\4\207\1\245\1\255\6\253\1\145\1\t\1\0\"7\1\201\1\255\24\199\0015\1\0%\1\1O\1\199\1\255\20\197\1M\1\1\1\0)2\1\144\1\226\1\255\14\225\1\142\0011\1\0/*\1g\1\153\1\193\1\223\1\242\1\255\2\242\1\223\1\192\1\152\1f\1)\1\0\255\0\154",
	}

	r5.graph = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\137+\1\180\1\246\1\255,\246\1\178\1)\1\0\r+\1\241\1\2550\240\1(\1\0\12\180\1\2552\176\1\0\12\246\1\2552\243\1\0\12\2554\0\12\2554\0\12\255\6\173\1\20\1\21\1\175\1\255*\0\12\255\6\20\1\0\2\23\1\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255 \163\1\19\1\21\1\175\1\255\6\0\12\255\6\0\4\255\30\253\1x\1\0\3\25\1\255\6\0\12\255\6\0\4\255\8\165\1\20\1\21\1\152\1\254\1\255\16\243\1O\1\0\4\26\1\255\6\0\12\255\6\0\4\255\6\254\1z\1\1\1\0\3D\1\224\1\255\14\225\1/\1\0\4\8\1\176\1\255\6\0\12\255\6\0\4\255\5\244\1R\1\0\6\n\1\136\1\253\1\255\11\199\1\24\1\0\4\20\1\194\1\255\7\0\12\255\6\0\4\255\4\228\0014\1\0\t=\1\219\1\255\t\168\1\t\1\0\4.\1\224\1\255\8\0\12\255\6\0\4\255\3\199\1\24\1\0\4\24\1@\1\0\5\r\1\153\1\254\1\255\5\253\1x\1\0\5R\1\244\1\255\t\0\12\255\6\0\4\255\2\168\1\t\1\0\4.\1\224\1\254\1\153\1\r\1\0\5=\1\219\1\255\3\244\1Q\1\0\5o\1\253\1\255\n\0\12\255\6\0\4\254\1\128\1\1\1\0\4K\1\241\1\255\3\224\1D\1\0\5\n\1\136\1\253\1\228\0013\1\0\4\7\1\161\1\255\12\0\12\255\6\0\4R\1\0\4\1\1z\1\254\1\255\5\254\1\152\1\r\1\0\5A\1\23\1\0\4\25\1\200\1\255\r\0\12\255\6\0\8\7\1\161\1\255\t\224\1D\1\0\t.\1\224\1\255\14\0\12\255\6\0\7\20\1\194\1\255\11\254\1\153\1\r\1\0\6K\1\241\1\255\15\0\12\255\6\0\6.\1\224\1\255\14\224\1D\1\0\4o\1\253\1\255\16\0\12\255\6\0\5Q\1\244\1\255\16\254\1\151\1\22\1\24\1\167\1\255\18\0\12\255\6\0\4z\1\253\1\255(\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0\4\255*\0\12\255\6\0&\21\1\175\1\255\6\0\12\255\6\0'\23\1\255\6\0\12\255\6\21\1\0&\24\1\255\6\0\12\255\6\175\1\22\1\0$\23\1\177\1\255\6\0\12\2554\0\12\2554\0\12\245\1\2552\243\1\0\12\179\1\2552\175\1\0\12)\1\240\1\2550\239\1'\1\0\r(\1\177\1\244\1\255,\243\1\175\1'\1\0\255\0\255\0\137",
	}

	r5.grid = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\141+\1\180\1\246\1\255\12\246\1\178\1)\1\0\6+\1\180\1\246\1\255\12\246\1\178\1)\1\0\21+\1\241\1\255\16\240\1(\1\0\4+\1\241\1\255\16\240\1(\1\0\20\180\1\255\18\176\1\0\4\180\1\255\18\176\1\0\20\246\1\255\18\243\1\0\4\246\1\255\18\243\1\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\245\1\255\18\243\1\0\4\245\1\255\18\243\1\0\20\179\1\255\18\175\1\0\4\179\1\255\18\175\1\0\20)\1\240\1\255\16\239\1'\1\0\4)\1\240\1\255\16\239\1'\1\0\21(\1\177\1\244\1\255\12\243\1\175\1'\1\0\6(\1\177\1\244\1\255\12\243\1\175\1'\1\0\255\0\23+\1\180\1\246\1\255\12\246\1\178\1)\1\0\6+\1\180\1\246\1\255\12\246\1\178\1)\1\0\21+\1\241\1\255\16\240\1(\1\0\4+\1\241\1\255\16\240\1(\1\0\20\180\1\255\18\176\1\0\4\180\1\255\18\176\1\0\20\246\1\255\18\243\1\0\4\246\1\255\18\243\1\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\255\20\0\4\255\20\0\20\245\1\255\18\243\1\0\4\245\1\255\18\243\1\0\20\179\1\255\18\175\1\0\4\179\1\255\18\175\1\0\20)\1\240\1\255\16\239\1'\1\0\4)\1\240\1\255\16\239\1'\1\0\21(\1\177\1\244\1\255\12\243\1\175\1'\1\0\6(\1\177\1\244\1\255\12\243\1\175\1'\1\0\255\0\255\0\141",
	}

	r5.grip = {
		w = 64,
		h = 64,
		data = "\0\255\0\14+\1\180\1\246\1\255 \246\1\178\1)\1\0\25+\1\241\1\255$\240\1(\1\0\24\180\1\255&\176\1\0\24\246\1\255&\243\1\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255\n\248\1j\1\12\1\r\1k\1\248\1\255\8\248\1j\1\12\1\r\1k\1\248\1\255\n\0\24\255\ni\1\0\4m\1\255\8i\1\0\4m\1\255\n\0\24\255\n\r\1\0\4\16\1\255\8\r\1\0\4\16\1\255\n\0\24\255\n\14\1\0\4\16\1\255\8\14\1\0\4\16\1\255\n\0\24\255\nk\1\0\4o\1\255\8k\1\0\4o\1\255\n\0\24\255\n\248\1m\1\14\1\16\1o\1\248\1\255\8\248\1m\1\14\1\16\1o\1\248\1\255\n\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255\n\248\1j\1\12\1\r\1k\1\248\1\255\8\248\1j\1\12\1\r\1k\1\248\1\255\n\0\24\255\ni\1\0\4m\1\255\8i\1\0\4m\1\255\n\0\24\255\n\r\1\0\4\16\1\255\8\r\1\0\4\16\1\255\n\0\24\255\n\14\1\0\4\16\1\255\8\14\1\0\4\16\1\255\n\0\24\255\nk\1\0\4o\1\255\8k\1\0\4o\1\255\n\0\24\255\n\248\1m\1\14\1\16\1o\1\248\1\255\8\248\1m\1\14\1\16\1o\1\248\1\255\n\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255\n\248\1j\1\12\1\r\1k\1\248\1\255\8\248\1j\1\12\1\r\1k\1\248\1\255\n\0\24\255\ni\1\0\4m\1\255\8i\1\0\4m\1\255\n\0\24\255\n\r\1\0\4\16\1\255\8\r\1\0\4\16\1\255\n\0\24\255\n\14\1\0\4\16\1\255\8\14\1\0\4\16\1\255\n\0\24\255\nk\1\0\4o\1\255\8k\1\0\4o\1\255\n\0\24\255\n\248\1m\1\14\1\16\1o\1\248\1\255\8\248\1m\1\14\1\16\1o\1\248\1\255\n\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\245\1\255&\243\1\0\24\179\1\255&\175\1\0\24)\1\240\1\255$\239\1'\1\0\25(\1\177\1\244\1\255 \243\1\175\1'\1\0\255\0\14",
	}

	r5.health = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\144,\1z\1\181\1\223\1\249\1\255\1\249\1\227\1\189\1\136\1B\1\3\1\0\12\3\1C\1\137\1\189\1\228\1\249\1\255\1\248\1\222\1\180\1y\1*\1\0\25\1\1S\1\201\1\255\11\229\1z\1\r\1\0\8\15\1|\1\230\1\255\11\200\1Q\1\1\1\0\21(\1\196\1\255\15\232\1W\1\0\6Z\1\234\1\255\15\194\1&\1\0\19V\1\245\1\255\18\154\1\5\1\0\2\6\1\157\1\255\18\243\1T\1\0\17i\1\254\1\255\20\178\1\6\2\182\1\255\20\253\1g\1\0\15V\1\254\1\255\22\158\1\161\1\255\22\253\1T\1\0\r(\1\244\1\2550\243\1&\1\0\11\1\1\196\1\2552\194\1\1\1\0\nT\1\2554P\1\0\n\201\1\2554\198\1\0\t,\1\2556(\1\0\8z\1\2556u\1\0\8\180\1\2556\177\1\0\8\222\1\2556\218\1\0\8\247\1\2556\243\1\0\8\2557\253\1\0\8\248\1\2556\245\1\0\8\228\1\2556\224\1\0\8\192\1\2556\189\1\0\8\143\1\2556\139\1\0\8P\1\2556K\1\0\8\12\1\246\1\2554\245\1\n\1\0\t\169\1\2554\164\1\0\nC\1\2554=\1\0\11\206\1\2552\201\1\0\12M\1\2552H\1\0\r\190\1\2550\186\1\0\14+\1\249\1\255.\248\1(\1\0\15}\1\255.z\1\0\16\4\1\197\1\255,\193\1\3\1\0\17\29\1\234\1\255*\233\1\27\1\0\19A\1\250\1\255(\249\1=\1\0\21d\1\255'\254\1_\1\0\23}\1\255&y\1\0\25\139\1\255$\134\1\0\27\139\1\255\"\136\1\0\29\128\1\255 }\1\0\31k\1\252\1\255\28\252\1i\1\0!O\1\244\1\255\26\243\1M\1\0#0\1\225\1\255\24\223\1.\1\0%\21\1\189\1\255\22\186\1\20\1\0'\3\1\132\1\253\1\255\18\253\1\129\1\3\1\0*C\1\230\1\255\16\228\1A\1\0-\20\1\173\1\255\14\169\1\18\1\0000Z\1\236\1\255\n\235\1X\1\0003\22\1\166\1\255\8\163\1\21\1\0006D\1\215\1\255\4\214\1B\1\0009\5\1p\1\229\2o\1\5\1\0\255\0\158",
	}

	r5.heartBreak = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\144/\1|\1\182\1\223\1\249\1\255\1\248\1\223\1\181\1z\1-\1\0\14/\1|\1\183\1\225\1\249\1\255\1\248\1\224\1\183\1|\1.\1\0\25\1\1W\1\206\1\255\11\203\1U\1\1\1\0\8\2\1X\1\205\1\255\11\204\1V\1\1\1\0\21+\1\199\1\255\15\197\1 \1\0\6*\1\200\1\255\15\197\1(\1\0\19Z\1\246\1\255\17\131\1\0\5Y\1\246\1\255\17\244\1U\1\0\17n\1\254\1\255\17\213\1\22\1\0\4k\1\254\1\255\19\253\1f\1\0\15Y\1\254\1\255\17\213\1\23\1\0\4k\1\254\1\255\21\253\1R\1\0\r*\1\245\1\255\17\214\1\23\1\0\4k\1\254\1\255\23\242\1$\1\0\11\1\1\198\1\255\17\219\1\23\1\0\4k\1\254\1\255\25\189\1\0\11V\1\255\18g\1\0\4i\1\254\1\255\27K\1\0\n\203\1\255\18t\1\0\4D\1\246\1\255\27\193\1\0\t,\1\255\19\237\1.\1\0\4D\1\246\1\255\27$\1\0\8{\1\255\20\235\1.\1\0\4D\1\246\1\255\26r\1\0\8\182\1\255\21\235\1.\1\0\4D\1\246\1\255\25\174\1\0\8\223\1\255\22\235\1.\1\0\4E\1\246\1\255\24\216\1\0\8\247\1\255\23\235\1.\1\0\4E\1\246\1\255\23\242\1\0\8\255\25\235\1.\1\0\4E\1\246\1\255\22\252\1\0\8\248\1\255\25\235\1.\1\0\4E\1\246\1\255\21\247\1\0\8\228\1\255\26\235\1.\1\0\4c\1\255\21\225\1\0\8\192\1\255\27\206\1\1\1\0\3%\1\255\21\189\1\0\8\143\1\255\26\225\1\"\1\0\4u\1\255\21\140\1\0\8P\1\255\25\225\1\"\1\0\4[\1\252\1\255\21M\1\0\8\12\1\246\1\255\23\224\1!\1\0\4[\1\252\1\255\21\245\1\11\1\0\t\169\1\255\22\224\1!\1\0\4[\1\252\1\255\22\166\1\0\nC\1\255\21\223\1 \1\0\4[\1\252\1\255\23?\1\0\11\206\1\255\20F\1\0\4[\1\252\1\255\23\201\1\0\12M\1\255\20+\1\0\3[\1\252\1\255\24J\1\0\r\190\1\255\19\164\1\5\1\0\1a\1\252\1\255\24\188\1\0\14+\1\249\1\255\19\232\1\219\1\255\25\248\1)\1\0\15}\1\255.{\1\0\16\4\1\197\1\255,\194\1\3\1\0\17\29\1\234\1\255*\233\1\28\1\0\19A\1\250\1\255(\249\1?\1\0\21d\1\255'\254\1_\1\0\23~\1\255&z\1\0\25\140\1\255$\136\1\0\27\140\1\255\"\136\1\0\29\129\1\255 ~\1\0\31l\1\253\1\255\28\252\1j\1\0!P\1\244\1\255\26\244\1O\1\0#1\1\225\1\255\24\224\0010\1\0%\21\1\189\1\255\22\188\1\21\1\0'\3\1\133\1\253\1\255\18\253\1\130\1\3\1\0*D\1\230\1\255\16\228\1C\1\0-\20\1\173\1\255\14\170\1\19\1\0000[\1\236\1\255\n\236\1Y\1\0003\23\1\167\1\255\8\166\1\23\1\0006F\1\217\1\255\4\217\1E\1\0009\6\1r\1\232\2s\1\6\1\0\255\0\158",
	}

	r5.immune = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\139+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255 \171\1\21\2\175\1\255\12\0\16\255\31\168\1\4\1\0\2\23\1\255\12\0\16\255\30\168\1\4\1\0\3\24\1\255\12\0\16\255\29\168\1\4\1\0\3\3\1\171\1\255\12\0\16\254\1\255\27\168\1\4\1\0\3\3\1\166\1\255\12\253\1\0\16\248\1\255\26\168\1\4\1\0\3\3\1\166\1\255\r\246\1\0\16\236\1\255\25\168\1\4\1\0\3\3\1\166\1\255\14\233\1\0\16\216\1\255\24\168\1\4\1\0\3\3\1\166\1\255\15\213\1\0\16\189\1\255\11\174\1\21\2\170\1\255\8\168\1\4\1\0\3\3\1\166\1\255\16\186\1\0\16\155\1\255\11\22\1\0\2\3\1\166\1\255\6\168\1\4\1\0\3\3\1\166\1\255\17\151\1\0\16q\1\255\11\23\1\0\3\3\1\167\1\255\4\168\1\4\1\0\3\3\1\166\1\255\18n\1\0\16@\1\255\11\172\1\4\1\0\3\3\1\167\1\255\2\168\1\4\1\0\3\3\1\166\1\255\19<\1\0\16\12\1\250\1\255\11\169\1\4\1\0\3\4\1\168\2\4\1\0\3\3\1\166\1\255\19\249\1\t\1\0\17\197\1\255\12\169\1\4\1\0\3\4\2\0\3\3\1\166\1\255\20\193\1\0\18z\1\255\r\169\1\4\1\0\6\3\1\166\1\255\21u\1\0\18'\1\255\14\169\1\4\1\0\4\3\1\166\1\255\21\254\1\"\1\0\19\201\1\255\14\169\1\4\1\0\2\3\1\166\1\255\22\196\1\0\20b\1\255\15\172\1\23\2\171\1\255\23\\\1\0\20\8\1\231\1\255(\228\1\6\1\0\21q\1\255(m\1\0\22\8\1\223\1\255&\221\1\7\1\0\23R\1\255&N\1\0\25\174\1\255$\170\1\0\26\21\1\230\1\255\"\227\1\19\1\0\27?\1\250\1\255 \249\1;\1\0\29g\1\255 e\1\0\31\130\1\255\30\128\1\0!\137\1\255\28\136\1\0#z\1\254\1\255\24\254\1z\1\0%Z\1\246\1\255\22\246\1\\\1\0'0\1\217\1\255\20\217\0010\1\0)\11\1\150\1\254\1\255\16\254\1\150\1\12\1\0,<\1\209\1\255\14\209\1=\1\0/\3\1c\1\225\1\255\n\225\1d\1\3\1\0002\6\1d\1\213\1\255\6\212\1d\1\6\1\0006\1\1>\1\156\1\234\1\235\1\157\1>\1\0\255\0\30",
	}

	r5.jumped = {
		w = 64,
		h = 64,
		data = "\0\255\0\31T\1\235\1\234\1T\1\0;U\1\251\1\255\2\252\1\\\1\0009U\1\251\1\255\4\252\1\\\1\0007U\1\251\1\255\6\252\1\\\1\0005U\1\251\1\255\8\252\1\\\1\0003U\1\251\1\255\n\252\1\\\1\0001U\1\251\1\255\12\252\1\\\1\0/U\1\251\1\255\14\252\1\\\1\0-U\1\251\1\255\16\252\1\\\1\0+U\1\251\1\255\18\252\1\\\1\0)U\1\251\1\255\20\252\1\\\1\0'U\1\251\1\255\22\252\1\\\1\0%U\1\251\1\255\24\252\1\\\1\0#U\1\251\1\255\26\252\1\\\1\0!U\1\251\1\255\28\252\1\\\1\0\31U\1\251\1\255\30\252\1\\\1\0\29U\1\251\1\255 \252\1\\\1\0\27U\1\251\1\255\"\252\1\\\1\0\25U\1\251\1\255$\252\1\\\1\0\23U\1\251\1\255&\252\1\\\1\0\21U\1\251\1\255(\252\1\\\1\0\19U\1\251\1\255*\252\1\\\1\0\17U\1\251\1\255,\252\1\\\1\0\15U\1\251\1\255.\252\1\\\1\0\rU\1\251\1\2550\251\1S\1\0\12\235\1\2552\231\1\0\12\234\1\2552\231\1\0\12P\1\233\1\2550\232\1M\1\0\24\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\245\1\255\26\243\1\0$\179\1\255\26\175\1\0$)\1\240\1\255\24\239\1'\1\0%(\1\177\1\244\1\255\20\243\1\175\1'\1\0\255\0\255\0\21",
	}

	r5.keyboard = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\255\0\8+\1\180\1\246\1\2550\246\1\178\1)\1\0\t+\1\241\1\2554\240\1(\1\0\8\180\1\2556\176\1\0\8\246\1\2556\243\1\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\255\6\173\1\20\1\0(\21\1\175\1\255\6\0\8\255\6\20\1\0*\23\1\255\6\0\8\255\6\21\1\0*\24\1\255\6\0\8\255\6\175\1\22\1\0(\23\1\177\1\255\6\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\255\6\173\1\20\1\0(\21\1\175\1\255\6\0\8\255\6\20\1\0*\23\1\255\6\0\8\255\6\21\1\0*\24\1\255\6\0\8\255\6\175\1\22\1\0(\23\1\177\1\255\6\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\255\6\173\1\20\1\0\4\21\1\175\1\255\4\173\1\20\1\0\16\21\1\175\1\255\4\173\1\20\1\0\4\21\1\175\1\255\6\0\8\255\6\20\1\0\6\23\1\255\4\20\1\0\18\23\1\255\4\20\1\0\6\23\1\255\6\0\8\255\6\21\1\0\6\24\1\255\4\21\1\0\18\24\1\255\4\21\1\0\6\24\1\255\6\0\8\255\6\175\1\22\1\0\4\23\1\177\1\255\4\175\1\22\1\0\16\23\1\177\1\255\4\175\1\22\1\0\4\23\1\177\1\255\6\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\2558\0\8\245\1\2556\243\1\0\8\179\1\2556\175\1\0\8)\1\240\1\2554\239\1'\1\0\t(\1\177\1\244\1\2550\243\1\175\1'\1\0\255\0\255\0\255\0\8",
	}

	r5.kit = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\140\2\1M\1\167\1\224\1\254\1\253\1\225\1\167\1L\1\1\1\0005,\1\203\1\255\8\203\1,\1\0003D\1\244\1\255\n\244\1F\1\0\22#\1\140\1\211\1\249\1\254\1\227\1\185\1\142\1d\0018\1\14\1\0\16+\1\243\1\255\12\244\1,\1\0\19\3\1\131\1\250\1\255\n\225\1\183\1\139\1Y\1\5\1\0\n\1\1\201\1\255\4\168\0017\1\5\2:\1\170\1\255\4\203\1\1\1\0\17\3\1\166\1\255\16\164\1\0\nI\1\255\4m\1\0\6q\1\255\4L\1\0\16\3\1\163\1\255\17\245\1\0\n\164\1\255\3\170\1\0\8\174\1\255\3\166\1\0\15\2\1\161\1\255\18\184\1\0\n\222\1\255\3:\1\0\8=\1\255\3\223\1\0\14\2\1\159\1\255\18\164\1\15\1\0\n\250\1\255\3\6\1\0\8\t\1\255\3\251\1\0\r\2\1\156\1\255\17\235\1T\1\0\12\249\1\255\3\8\1\0\8\11\1\255\3\251\1\0\12\1\1\154\1\255\17\177\1\23\1\0\r\221\1\255\3>\1\0\8?\1\255\3\222\1\0\11\1\1\151\1\255\16\241\1a\1\0\15\162\1\255\3\176\1\0\8\177\1\255\3\163\1\0\n\1\1\148\1\255\16\189\1\31\1\0\16G\1\255\4x\1\0\6x\1\255\4\177\1\14\1\0\8\1\1\146\1\255\15\246\1n\1\1\1\0\17\1\1\197\1\255\4\179\1B\1\r\1\12\1C\1\180\1\255\6\223\1@\1\0\7`\1\255\15\200\1'\1\0\20'\1\241\1\255\16\253\1\142\1\t\1\0\5<\1\241\1\255\12\250\1{\1\4\1\0\22?\1\241\1\255\17\214\0015\1\0\5\31\1\190\1\255\n\210\0011\1\0\25'\1\196\1\255\8\208\1\252\1\255\7\251\1\129\1\5\1\0\4\1\1o\1\246\1\255\6\252\1\137\1\7\1\0\28E\1\159\1\219\1\248\1\247\1\218\1\159\1E\1\1\1[\1\252\1\255\8\204\1+\1\0\5(\1\201\1\255\4\220\1;\1\0(_\1\253\1\255\8\247\1w\1\3\1\0\4\4\1w\1\249\1\254\1\153\1\12\1\0*a\1\253\1\255\t\194\1\"\1\0\5*\0016\1\0-b\1\253\1\255\t\245\1o\1\1\1\0003c\1\253\1\255\n\185\1\28\1\0002V\1\251\1\255\11\237\1X\1\0000T\1\251\1\255\14\170\1\20\1\0-T\1\251\1\255\16\232\1O\1\0+T\1\251\1\255\19\162\1\r\1\0\31C\1\157\1\215\1\246\1\248\1\219\1\160\1G\1\1\1V\1\251\1\255\21\223\1?\1\0\28$\1\192\1\255\8\208\1\251\1\255\7\251\1\132\1\130\1\255\r\253\1\141\1\8\1\0\0259\1\239\1\255\17\216\0017\1\0\2\130\1\255\14\214\0014\1\0\23\"\1\237\1\255\16\254\1\146\1\n\1\0\4\134\1\255\14\251\1\128\1\5\1\0\21\189\1\255\4\168\0017\1\5\2:\1\170\1\255\6\225\1B\1\0\7\137\1\255\15\204\1*\1\0\19>\1\255\4m\1\0\6q\1\255\4\179\1\15\1\0\t\140\1\255\15\247\1r\1\2\1\0\17\152\1\255\3\170\1\0\8\174\1\255\3\164\1\0\11\144\1\255\16\193\1!\1\0\16\209\1\255\3:\1\0\8=\1\255\3\223\1\0\11\1\1\147\1\255\16\242\1e\1\0\15\238\1\255\3\6\1\0\8\t\1\255\3\251\1\0\12\1\1\150\1\255\17\181\1\25\1\0\r\237\1\255\3\8\1\0\8\n\1\255\3\250\1\0\r\1\1\153\1\255\17\236\1W\1\0\12\209\1\255\3>\1\0\8?\1\255\3\222\1\0\14\2\1\156\1\255\18\168\1\17\1\0\n\151\1\255\3\176\1\0\8\177\1\255\3\164\1\0\15\2\1\159\1\255\18\190\1\0\n<\1\255\4x\1\0\6w\1\255\4H\1\0\16\2\1\162\1\255\17\251\1\0\11\187\1\255\4\179\1B\1\r\1\12\1C\1\180\1\255\4\197\1\1\1\0\17\3\1\164\1\255\16\167\1\0\11!\1\237\1\255\12\241\1(\1\0\19\2\1~\1\249\1\255\n\225\1\183\1\139\1Y\1\5\1\0\0128\1\237\1\255\n\242\1?\1\0\22 \1\136\1\208\1\247\1\253\1\227\1\186\1\142\1d\0018\1\14\1\0\18!\1\189\1\255\8\196\1'\1\0006>\1\153\1\213\1\240\1\242\1\215\1\156\1C\1\0\255\0\255\0\175",
	}

	r5.landed = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\21+\1\180\1\246\1\255\20\246\1\178\1)\1\0%+\1\241\1\255\24\240\1(\1\0$\180\1\255\26\176\1\0$\246\1\255\26\243\1\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0$\255\28\0\24S\1\235\1\2550\234\1O\1\0\12\234\1\2552\232\1\0\12\234\1\2552\231\1\0\12T\1\251\1\2550\251\1S\1\0\rT\1\251\1\255.\252\1[\1\0\15T\1\251\1\255,\252\1[\1\0\17T\1\251\1\255*\252\1[\1\0\19T\1\251\1\255(\252\1[\1\0\21T\1\251\1\255&\252\1[\1\0\23T\1\251\1\255$\252\1[\1\0\25T\1\251\1\255\"\252\1[\1\0\27T\1\251\1\255 \252\1[\1\0\29T\1\251\1\255\30\252\1[\1\0\31T\1\251\1\255\28\252\1[\1\0!T\1\251\1\255\26\252\1[\1\0#T\1\251\1\255\24\252\1[\1\0%T\1\251\1\255\22\252\1[\1\0'T\1\251\1\255\20\252\1[\1\0)T\1\251\1\255\18\252\1[\1\0+T\1\251\1\255\16\252\1[\1\0-T\1\251\1\255\14\252\1[\1\0/T\1\251\1\255\12\252\1[\1\0001T\1\251\1\255\n\252\1[\1\0003T\1\251\1\255\8\252\1[\1\0005T\1\251\1\255\6\252\1[\1\0007T\1\251\1\255\4\252\1[\1\0009T\1\251\1\255\2\252\1[\1\0;S\1\232\2S\1\0\255\0\31",
	}

	r5.letters = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\137+\1\180\1\246\1\255,\246\1\178\1)\1\0\r+\1\241\1\2550\240\1(\1\0\12\180\1\2552\176\1\0\12\246\1\2552\243\1\0\12\2554\0\12\2554\0\12\255\15\172\1\19\1\20\1\174\1\255!\0\12\255\14\246\1\19\1\0\2\19\1\246\1\255 \0\12\255\14\155\1\0\4\156\1\255 \0\12\255\0143\1\0\0040\1\255 \0\12\255\r\195\1\0\6\196\1\255\31\0\12\255\rW\1\0\6X\1\255\31\0\12\255\12\230\1\5\1\0\6\5\1\228\1\255\30\0\12\255\12\127\1\0\3)\2\0\3\127\1\255\30\0\12\255\11\249\1\25\1\0\3\148\2\0\3\25\1\249\1\255\12\254\1\180\1X\1\30\1\2\1\4\1 \1Z\1\181\1\254\1\255\7\0\12\255\11\166\1\0\3\14\1\242\2\14\1\0\3\166\1\255\11\219\0018\1\0\8:\1\219\1\255\6\0\12\255\11;\1\0\3l\1\255\2l\1\0\3;\1\255\11,\1\0\n\19\1\209\1\255\5\0\12\255\n\206\1\0\3\1\1\215\1\255\2\215\1\1\1\0\3\206\1\255\t\254\1\7\1\0\11!\1\244\1\255\4\0\12\255\nb\1\0\3E\1\255\4E\1\0\3b\1\255\nv\1\0\2Q\1\197\1\249\1\248\1\195\1O\1\0\4\137\1\255\4\0\12\255\t\236\1\t\1\0\3\177\1\255\4\177\1\0\3\t\1\236\1\255\n\208\1\209\1\255\6i\1\0\0033\1\255\4\0\12\255\t\137\1\0\3 \1\252\1\255\4\252\1 \1\0\3\137\1\255\18\233\1\0\3\8\1\255\4\0\12\255\8\252\1!\1\0\3\138\1\255\6\137\1\0\3\30\1\252\1\255\18\0\4\255\4\0\12\255\8\176\1\0\3\t\1\236\1\255\6\236\1\t\1\0\3\176\1\255\t\254\1\180\1X\1 \1\3\2\31\1Z\1\182\1\0\4\255\4\0\12\255\8D\1\0\3b\1\255\8b\1\0\3D\1\255\8\218\0017\1\0\12\255\4\0\12\255\7\214\1\1\1\0\16\1\1\214\1\255\6\207\1\18\1\0\r\255\4\0\12\255\7l\1\0\18l\1\255\5\242\1\31\1\0\14\255\4\0\12\255\6\241\1\r\1\0\18\r\1\241\1\255\4\135\1\0\4O\1\196\1\249\1\248\1\194\1M\1\0\5\255\4\0\12\255\6\147\1\0\20\147\1\255\4/\1\0\3m\1\255\6i\1\0\4\255\4\0\12\255\5\254\1(\1\0\3\128\1\255\12\128\1\0\3(\1\254\1\255\3\6\1\0\3\237\1\255\6\234\1\0\4\255\4\0\12\255\5\186\1\0\3\5\1\230\1\255\12\230\1\5\1\0\3\186\1\255\3\6\1\0\3\236\1\255\6\233\1\0\4\255\4\0\12\255\5N\1\0\3X\1\255\14X\1\0\3N\1\255\0030\1\0\3j\1\255\6f\1\0\4\255\4\0\12\255\4\223\1\3\1\0\3\196\1\255\14\196\1\0\3\3\1\223\1\255\2\136\1\0\4N\1\193\1\246\2\192\1K\1\0\5\255\4\0\12\255\4u\1\0\0031\1\255\0161\1\0\3u\1\255\2\243\1!\1\0\14\255\4\0\12\255\4\20\1\0\3\157\1\255\16\157\1\0\3\22\1\255\3\209\1\19\1\0\r\255\4\0\12\255\4\21\1\0\2\19\1\246\1\255\16\246\1\19\1\0\2\24\1\255\4\220\1;\1\0\8\2\1\0\2\24\1\255\4\0\12\255\4\175\1\22\1\24\1\176\1\255\18\174\1\23\2\176\1\255\5\254\1\183\1]\1\"\1\5\2\"\1^\1\186\1\175\1\24\1\23\1\178\1\255\4\0\12\2554\0\12\2554\0\12\2554\0\12\2554\0\12\245\1\2552\243\1\0\12\179\1\2552\175\1\0\12)\1\240\1\2550\239\1'\1\0\r(\1\177\1\244\1\255,\243\1\175\1'\1\0\255\0\255\0\137",
	}

	r5.listBullets = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\11+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\6\248\1j\1\12\1\r\1k\1\248\1\255$\0\16\255\6i\1\0\4m\1\255\4\173\1\20\1\0\22\21\1\175\1\255\6\0\16\255\6\r\1\0\4\16\1\255\4\20\1\0\24\23\1\255\6\0\16\255\6\14\1\0\4\16\1\255\4\21\1\0\24\24\1\255\6\0\16\255\6k\1\0\4o\1\255\4\175\1\22\1\0\22\23\1\177\1\255\6\0\16\255\6\248\1m\1\14\1\16\1o\1\248\1\255$\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\6\248\1j\1\12\1\r\1k\1\248\1\255$\0\16\255\6i\1\0\4m\1\255\4\173\1\20\1\0\22\21\1\175\1\255\6\0\16\255\6\r\1\0\4\16\1\255\4\20\1\0\24\23\1\255\6\0\16\255\6\14\1\0\4\16\1\255\4\21\1\0\24\24\1\255\6\0\16\255\6k\1\0\4o\1\255\4\175\1\22\1\0\22\23\1\177\1\255\6\0\16\255\6\248\1m\1\14\1\16\1o\1\248\1\255$\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\6\248\1j\1\12\1\r\1k\1\248\1\255$\0\16\255\6i\1\0\4m\1\255\4\173\1\20\1\0\22\21\1\175\1\255\6\0\16\255\6\r\1\0\4\16\1\255\4\20\1\0\24\23\1\255\6\0\16\255\6\14\1\0\4\16\1\255\4\21\1\0\24\24\1\255\6\0\16\255\6k\1\0\4o\1\255\4\175\1\22\1\0\22\23\1\177\1\255\6\0\16\255\6\248\1m\1\14\1\16\1o\1\248\1\255$\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.lock = {
		w = 64,
		h = 64,
		data = "\0\155$\1|\1\189\1\231\1\253\2\231\1\189\1{\1#\1\0004$\1\173\1\253\1\255\8\253\1\170\1!\1\0001`\1\245\1\255\12\244\1]\1\0/y\1\255\16v\1\0-`\1\255\5\204\1e\1#\1\4\2$\1g\1\205\1\255\5\\\1\0+$\1\245\1\255\3\245\1`\1\1\1\0\6\1\1d\1\246\1\255\3\243\1 \1\0*\173\1\255\3\245\1;\1\0\n>\1\246\1\255\3\168\1\0)$\1\253\1\255\3a\1\0\12f\1\255\3\252\1!\1\0(}\1\255\3\204\1\1\1\0\12\1\1\207\1\255\3y\1\0(\189\1\255\3e\1\0\14i\1\255\3\186\1\0(\232\1\255\3$\1\0\14'\1\255\3\229\1\0(\252\1\255\3\4\1\0\14\7\1\255\3\250\1\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0\29+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.lowhp = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\144,\1z\1\181\1\223\1\249\1\255\1\249\1\227\1\189\1\136\1B\1\3\1\0\12\3\1C\1\137\1\189\1\228\1\249\1\255\1\248\1\222\1\180\1y\1*\1\0\25\1\1S\1\201\1\255\11\229\1z\1\r\1\0\8\15\1|\1\230\1\255\11\200\1Q\1\1\1\0\21(\1\196\1\255\15\232\1W\1\0\6Z\1\234\1\255\15\194\1&\1\0\19V\1\245\1\255\18\154\1\5\1\0\2\6\1\157\1\255\18\243\1T\1\0\17i\1\254\1\255\20\178\1\6\2\182\1\255\20\253\1g\1\0\15V\1\254\1\255\22\158\1\161\1\255\22\253\1T\1\0\r(\1\244\1\2550\243\1&\1\0\11\1\1\196\1\2552\194\1\1\1\0\nT\1\2554P\1\0\n\201\1\2554\198\1\0\t,\1\2556(\1\0\8z\1\2556u\1\0\8\180\1\2556\177\1\0\8\222\1\2556\218\1\0\8\247\1\2556\243\1\0\8\2557\253\1\0\8\247\1\255\15\174\1\21\2\174\1\255#\245\1\0\8\227\1\255\14\224\1\r\1\0\2\r\1\224\1\255\"\224\1\0\8\192\1\255\r\254\1D\1\0\4D\1\254\1\255!\189\1\0\8\144\1\255\r\152\1\0\6\152\1\255!\139\1\0\8P\1\255\12\224\1\r\1\0\6\r\1\224\1\255 K\1\0\8\11\1\220\1\255\n\254\1D\1\0\3\r\2\0\3D\1\254\1\255\30\245\1\n\1\0\25\152\1\151\1\0\4\152\1\255\4\173\1\21\1\0\6\23\1\178\1\255\16\164\1\0\25D\1\254\2C\1\0\3\r\1\224\1\255\2\224\1\r\1\0\8\24\1\255\16=\1\0\24\r\1\224\1\255\2\224\1\r\1\0\3C\1\254\2D\1\0\t\23\1\255\15\201\1\0\24\24\1\177\1\255\4\152\1\0\4\151\1\152\1\0\t\23\1\176\1\255\15H\1\0\r!\1\238\1\255\15\254\1D\1\0\3\r\2\0\3D\1\254\1\255\20\186\1\0\14!\1\248\1\255\16\224\1\r\1\0\6\r\1\224\1\255\20\248\1(\1\0\15{\1\255\17\152\1\0\6\152\1\255\21z\1\0\16\4\1\195\1\255\16\254\1D\1\0\4D\1\254\1\255\20\193\1\3\1\0\17\28\1\234\1\255\16\224\1\r\1\0\2\r\1\224\1\255\20\233\1\27\1\0\19>\1\249\1\255\16\174\1\23\2\177\1\255\20\249\1=\1\0\21`\1\254\1\255&\254\1_\1\0\23y\1\255&y\1\0\25\135\1\255$\134\1\0\27\137\1\255\"\136\1\0\29~\1\255 }\1\0\31i\1\252\1\255\28\252\1i\1\0!M\1\243\1\255\26\243\1M\1\0#/\1\223\1\255\24\223\1.\1\0%\20\1\187\1\255\22\186\1\20\1\0'\3\1\130\1\253\1\255\18\253\1\129\1\3\1\0*B\1\228\1\255\16\228\1A\1\0-\19\1\169\1\255\14\169\1\18\1\0000X\1\235\1\255\n\235\1X\1\0003\21\1\164\1\255\8\163\1\21\1\0006D\1\215\1\255\4\214\1B\1\0009\5\1p\1\229\2o\1\5\1\0\255\0\158",
	}

	r5.missing = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\11+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\n\173\1\21\2\171\1\255\20\171\1\21\2\175\1\255\n\0\16\255\n\21\1\0\2\4\1\168\1\255\18\168\1\4\1\0\2\23\1\255\n\0\16\255\n\22\1\0\3\4\1\168\1\255\16\168\1\4\1\0\3\24\1\255\n\0\16\255\n\171\1\4\1\0\3\4\1\168\1\255\14\168\1\4\1\0\3\4\1\172\1\255\n\0\16\255\11\171\1\4\1\0\3\3\1\163\1\255\12\170\1\4\1\0\3\3\1\164\1\255\11\0\16\255\12\171\1\4\1\0\3\3\1\163\1\255\n\170\1\4\1\0\3\3\1\164\1\255\12\0\16\255\r\171\1\4\1\0\3\3\1\163\1\255\8\170\1\4\1\0\3\3\1\164\1\255\r\0\16\255\14\171\1\4\1\0\3\3\1\163\1\255\6\170\1\4\1\0\3\3\1\164\1\255\14\0\16\255\15\171\1\4\1\0\3\3\1\163\1\255\4\170\1\4\1\0\3\3\1\164\1\255\15\0\16\255\16\171\1\4\1\0\3\3\1\163\1\255\2\170\1\4\1\0\3\3\1\164\1\255\16\0\16\255\17\171\1\4\1\0\3\3\1\163\1\170\1\4\1\0\3\3\1\164\1\255\17\0\16\255\18\168\1\4\1\0\3\4\2\0\3\4\1\168\1\255\18\0\16\255\19\171\1\4\1\0\6\3\1\164\1\255\19\0\16\255\20\171\1\4\1\0\4\3\1\164\1\255\20\0\16\255\20\170\1\4\1\0\4\3\1\163\1\255\20\0\16\255\19\170\1\4\1\0\6\3\1\163\1\255\19\0\16\255\18\168\1\4\1\0\3\4\2\0\3\4\1\168\1\255\18\0\16\255\17\170\1\4\1\0\3\3\1\164\1\171\1\4\1\0\3\3\1\163\1\255\17\0\16\255\16\170\1\4\1\0\3\3\1\164\1\255\2\171\1\4\1\0\3\3\1\163\1\255\16\0\16\255\15\170\1\4\1\0\3\3\1\164\1\255\4\171\1\4\1\0\3\3\1\163\1\255\15\0\16\255\14\170\1\4\1\0\3\3\1\164\1\255\6\171\1\4\1\0\3\3\1\163\1\255\14\0\16\255\r\170\1\4\1\0\3\3\1\164\1\255\8\171\1\4\1\0\3\3\1\163\1\255\r\0\16\255\12\170\1\4\1\0\3\3\1\164\1\255\n\171\1\4\1\0\3\3\1\163\1\255\12\0\16\255\11\170\1\4\1\0\3\3\1\164\1\255\12\171\1\4\1\0\3\3\1\163\1\255\11\0\16\255\n\170\1\4\1\0\3\4\1\168\1\255\14\168\1\4\1\0\3\4\1\172\1\255\n\0\16\255\n\21\1\0\3\4\1\168\1\255\16\168\1\4\1\0\3\23\1\255\n\0\16\255\n\22\1\0\2\4\1\168\1\255\18\168\1\4\1\0\2\24\1\255\n\0\16\255\n\175\1\23\2\172\1\255\20\172\1\23\2\177\1\255\n\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.money = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\144\8\0017\1g\1\142\1\176\1\201\1\224\1\238\1\254\1\255\2\254\1\238\1\224\1\201\1\175\1\141\1f\0017\1\7\1\0),\1|\1\195\1\249\1\255\18\248\1\194\1{\1+\1\0#\11\1j\1\210\1\255\26\208\1h\1\n\1\0\30\5\1p\1\234\1\255\30\233\1l\1\4\1\0\27,\1\209\1\255\"\206\1)\1\0\25J\1\244\1\255$\242\1F\1\0\23=\1\248\1\255&\247\1:\1\0\21\15\1\229\1\255(\226\1\12\1\0\20z\1\255*v\1\0\20\208\1\255*\205\1\0\20\249\1\255*\247\1\0\20\255,\0\20\255,\138\1c\0014\1\5\1\0\16\255/\247\1\192\1y\1*\1\0\r\2553\208\1j\1\11\1\0\n\2555\234\1p\1\5\1\0\8\2557\209\1,\1\0\7\255\4\205\1\255\"\203\1\255\16\244\1K\1\0\6\255\4\4\1k\1\231\1\255\30\230\1h\1\3\1\255\17\248\1>\1\0\5\255\4\0\2\t\1f\1\203\1\255\26\202\1e\1\8\1\0\2\255\18\228\1\14\1\0\4\255\4\0\5'\1w\1\190\1\255\20\189\1v\1&\1\0\5\255\19w\1\0\4\249\1\255\3\19\1\0\7\255\4\171\1\197\1\220\1\238\1\249\1\255\2\249\1\238\1\219\1\197\1\171\1\255\4\0\7\22\1\255\19\205\1\0\4\207\1\255\3\133\1\0\7\255\4\0\12\255\4\0\7\136\1\255\19\247\1\0\4x\1\255\3\253\1h\1\0\6\255\4\0\12\255\4\0\6l\1\254\1\255\20\0\4\r\1\227\1\255\4\165\1\24\1\0\4\255\4\0\12\255\4\0\4\25\1\167\1\255\22\0\5;\1\247\1\255\4\243\1\140\1!\1\0\2\255\4\0\12\255\4\0\2\"\1\141\1\244\1\255\23\0\6F\1\242\1\255\5\253\1\193\1n\1\255\4\0\12\255\4n\1\194\1\254\1\255\25\0\7)\1\204\1\255\11_\1?\1(\1\20\1\8\1\0\2\8\1\20\1(\1@\1_\1\255 \0\8\4\1j\1\231\1\2555\0\n\t\1e\1\203\1\255.\203\1\255\4\0\r&\1v\1\189\1\246\1\255(\230\1h\1\3\1\255\4\0\16\5\0012\1b\1\137\1\255\4\249\1\255\2\249\1\238\1\255\26\202\1e\1\8\1\0\2\255\4\0\20\255\4\0\5\"\1r\1\184\1\255\20\189\1v\1&\1\0\5\255\4\0\20\249\1\255\3\19\1\0\7\255\4\169\1\196\1\217\1\238\1\248\1\255\2\249\1\238\1\219\1\197\1\171\1\255\4\0\7\22\1\255\3\246\1\0\20\207\1\255\3\133\1\0\7\255\4\0\12\255\4\0\7\136\1\255\3\204\1\0\20x\1\255\3\253\1h\1\0\6\255\4\0\12\255\4\0\6l\1\254\1\255\3t\1\0\20\r\1\227\1\255\4\165\1\24\1\0\4\255\4\0\12\255\4\0\4\25\1\167\1\255\4\223\1\11\1\0\21;\1\247\1\255\4\243\1\140\1!\1\0\2\255\4\0\12\255\4\0\2\"\1\141\1\244\1\255\4\246\0018\1\0\23E\1\242\1\255\5\253\1\193\1n\1\255\4\0\12\255\4n\1\194\1\254\1\255\5\240\1B\1\0\25(\1\205\1\255\11_\1@\1)\1\22\1\t\1\0\2\n\1\22\1)\1A\1_\1\255\11\202\1&\1\0\27\4\1k\1\232\1\255\30\231\1h\1\3\1\0\30\t\1f\1\204\1\255\26\201\1d\1\8\1\0#(\1x\1\190\1\246\1\255\18\245\1\188\1v\1&\1\0)\5\0014\1c\1\138\1\171\1\199\1\220\1\238\1\248\1\255\2\248\1\238\1\220\1\198\1\170\1\137\1a\0013\1\5\1\0\255\0\255\0\144",
	}

	r5.moon = {
		w = 64,
		h = 64,
		data = "\0\255\0Y4\1\146\1\224\1\228\1Q\1\0008\1\1P\1\202\1\255\4\237\1\1\1\00069\1\203\1\255\6\243\1\2\1\0004\n\1\147\1\253\1\255\7\178\1\0004'\1\212\1\255\tv\1\0003A\1\239\1\255\nG\1\0002K\1\247\1\255\11%\1\0001C\1\248\1\255\12\r\1\0000(\1\240\1\255\r\2\1\0/\11\1\213\1\255\14\2\1\0/\152\1\255\15\14\1\0.>\1\254\1\255\15%\1\0-\2\1\207\1\255\16H\1\0-W\1\255\17w\1\0-\206\1\255\17\180\1\0,:\1\255\18\243\1\t\1\0+\151\1\255\19S\1\0*\2\1\232\1\255\19\183\1\0*2\1\255\20\254\1,\1\0)n\1\255\21\173\1\0)\159\1\255\22B\1\0(\198\1\255\22\220\1\12\1\0'\226\1\255\23\164\1\0'\246\1\255\24x\1\0&\255\25\254\1g\1\0%\254\1\255\25\254\1v\1\0$\245\1\255\27\162\1\12\1\0\"\225\1\255\28\219\1@\1\0!\196\1\255\30\171\1+\1\0\31\156\1\255\31\253\1\181\1R\1\8\1\0\28j\1\255\"\243\1\178\1w\1G\1%\1\12\1\0\2\12\1$\1F\1u\1\176\1\241\1\236\1Q\1\0\r.\1\2551\229\1\0\r\1\1\228\1\2550\227\1\0\14\147\1\2550\144\1\0\0144\1\25501\1\0\15\201\1\255.\196\1\0\16R\1\255.L\1\0\16\1\1\202\1\255,\197\1\0\18:\1\253\1\255*\253\0015\1\0\19\148\1\255*\143\1\0\20\n\1\213\1\255(\208\1\8\1\0\21'\1\239\1\255&\236\1#\1\0\23A\1\248\1\255$\246\1<\1\0\25L\1\248\1\255\"\246\1G\1\0\27A\1\239\1\255 \238\1?\1\0\29'\1\213\1\255\30\213\1&\1\0\31\n\1\148\1\254\1\255\26\253\1\147\1\n\1\0\":\1\203\1\255\24\200\0018\1\0%\1\1R\1\201\1\255\20\198\1P\1\1\1\0)4\1\145\1\227\1\255\14\226\1\144\0012\1\0.\1\1,\1i\1\154\1\194\1\226\1\244\1\255\2\243\1\225\1\194\1\154\1h\1+\1\1\1\0\255\0\255\0\24",
	}

	r5.mouseLeft = {
		w = 64,
		h = 64,
		data = "\0\255\0\23\15\1Z\1\157\1\205\1\238\1\255\n\237\1\205\1\156\1Y\1\15\1\0*&\1\158\1\246\1\255\18\246\1\156\1%\1\0&\t\1\141\1\251\1\255\22\250\1\139\1\t\1\0#$\1\212\1\255\26\210\1#\1\0!0\1\234\1\255\14\0\4\2\1\24\1C\1\133\1\221\1\255\5\233\0010\1\0\31$\1\234\1\255\15\0\8\2\1V\1\223\1\255\4\234\1#\1\0\29\n\1\212\1\255\16\0\n\12\1\164\1\255\4\210\1\t\1\0\28\141\1\255\17\0\11\1\1\139\1\255\4\138\1\0\27&\1\251\1\255\17\0\12\1\1\165\1\255\3\250\1$\1\0\26\158\1\255\18\0\r\12\1\224\1\255\3\155\1\0\25\15\1\246\1\255\18\0\14Y\1\255\3\245\1\r\1\0\24Z\1\255\19\0\14\3\1\223\1\255\3W\1\0\24\156\1\255\19\0\15\136\1\255\3\153\1\0\24\205\1\255\19\0\15F\1\255\3\202\1\0\24\238\1\255\19\0\15\27\1\255\3\234\1\0\24\253\1\255\19\0\15\6\1\255\3\251\1\0\24\255\20\0\16\255\4\0\24\255\20\0\16\255\4\0\24\255\20\0\16\255\4\0\24\255\20\0\16\255\4\0\24\255\20\0\16\255\4\0\24\255\20\0\16\255\4\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\253\1\255\3\3\1\0\30\6\1\255\3\251\1\0\24\238\1\255\3\24\1\0\30\28\1\255\3\234\1\0\24\204\1\255\3C\1\0\30G\1\255\3\201\1\0\24\156\1\255\3\133\1\0\30\137\1\255\3\152\1\0\24Y\1\255\3\221\1\2\1\0\28\3\1\224\1\255\3V\1\0\24\15\1\246\1\255\3V\1\0\28[\1\255\3\244\1\r\1\0\25\157\1\255\3\223\1\12\1\0\26\14\1\226\1\255\3\154\1\0\26%\1\250\1\255\3\163\1\1\1\0\24\1\1\168\1\255\3\249\1#\1\0\27\139\1\255\4\139\1\1\1\0\22\1\1\141\1\255\4\135\1\0\28\t\1\210\1\255\4\165\1\r\1\0\20\14\1\168\1\255\4\208\1\8\1\0\29#\1\234\1\255\4\224\1Y\1\3\1\0\16\3\1[\1\227\1\255\4\233\1\"\1\0\0310\1\234\1\255\5\223\1\136\1G\1\27\1\4\1\0\8\4\1\28\1G\1\137\1\225\1\255\5\233\1/\1\0!#\1\210\1\255\26\208\1\"\1\0#\t\1\138\1\250\1\255\22\249\1\135\1\8\1\0&$\1\155\1\245\1\255\18\245\1\154\1#\1\0*\r\1W\1\153\1\202\1\233\1\253\1\255\8\253\1\233\1\202\1\152\1V\1\r\1\0\255\0\23",
	}

	r5.mouseRight = {
		w = 64,
		h = 64,
		data = "\0\255\0\23\15\1Z\1\157\1\205\1\238\1\255\n\237\1\205\1\156\1Y\1\15\1\0*&\1\158\1\246\1\255\18\246\1\156\1%\1\0&\t\1\141\1\251\1\255\22\250\1\139\1\t\1\0#$\1\212\1\255\26\210\1#\1\0!0\1\234\1\255\5\220\1\132\1C\1\24\1\2\1\0\4\255\14\233\0010\1\0\31$\1\234\1\255\4\220\1T\1\2\1\0\8\255\15\234\1#\1\0\29\n\1\212\1\255\4\160\1\11\1\0\n\255\16\210\1\t\1\0\28\141\1\255\4\136\1\0\12\255\17\138\1\0\27&\1\251\1\255\3\160\1\0\r\255\17\250\1$\1\0\26\158\1\255\3\220\1\11\1\0\r\255\18\155\1\0\25\15\1\246\1\255\3T\1\0\14\255\18\245\1\r\1\0\24Z\1\255\3\220\1\2\1\0\14\255\19W\1\0\24\156\1\255\3\132\1\0\15\255\19\153\1\0\24\205\1\255\3C\1\0\15\255\19\202\1\0\24\238\1\255\3\23\1\0\15\255\19\234\1\0\24\253\1\255\3\3\1\0\15\255\19\251\1\0\24\255\4\0\16\255\20\0\24\255\4\0\16\255\20\0\24\255\4\0\16\255\20\0\24\255\4\0\16\255\20\0\24\255\4\0\16\255\20\0\24\255\4\0\16\255\20\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\255\4\0 \255\4\0\24\253\1\255\3\3\1\0\30\6\1\255\3\251\1\0\24\238\1\255\3\24\1\0\30\28\1\255\3\234\1\0\24\204\1\255\3C\1\0\30G\1\255\3\201\1\0\24\156\1\255\3\133\1\0\30\137\1\255\3\152\1\0\24Y\1\255\3\221\1\2\1\0\28\3\1\224\1\255\3V\1\0\24\15\1\246\1\255\3V\1\0\28[\1\255\3\244\1\r\1\0\25\157\1\255\3\223\1\12\1\0\26\14\1\226\1\255\3\154\1\0\26%\1\250\1\255\3\163\1\1\1\0\24\1\1\168\1\255\3\249\1#\1\0\27\139\1\255\4\139\1\1\1\0\22\1\1\141\1\255\4\135\1\0\28\t\1\210\1\255\4\165\1\r\1\0\20\14\1\168\1\255\4\208\1\8\1\0\29#\1\234\1\255\4\224\1Y\1\3\1\0\16\3\1[\1\227\1\255\4\233\1\"\1\0\0310\1\234\1\255\5\223\1\136\1G\1\27\1\4\1\0\8\4\1\28\1G\1\137\1\225\1\255\5\233\1/\1\0!#\1\210\1\255\26\208\1\"\1\0#\t\1\138\1\250\1\255\22\249\1\135\1\8\1\0&$\1\155\1\245\1\255\18\245\1\154\1#\1\0*\r\1W\1\153\1\202\1\233\1\253\1\255\8\253\1\233\1\202\1\152\1V\1\r\1\0\255\0\23",
	}

	r5.okCircle = {
		w = 64,
		h = 64,
		data = "\0\255\0\153\1\1/\1k\1\156\1\196\1\228\1\245\1\255\2\244\1\225\1\195\1\155\1i\1,\1\0/5\1\148\1\229\1\255\14\226\1\145\0011\1\0)\1\1T\1\202\1\255\20\198\1N\1\1\1\0%<\1\205\1\255\24\200\0016\1\0\"\11\1\151\1\254\1\255\26\253\1\144\1\t\1\0\31)\1\214\1\255\30\209\1$\1\0\29C\1\241\1\255 \237\1=\1\0\27L\1\248\1\255\"\246\1G\1\0\25C\1\248\1\255$\246\1>\1\0\23)\1\241\1\255&\237\1$\1\0\21\11\1\214\1\255(\209\1\8\1\0\20\151\1\255*\143\1\0\19<\1\254\1\255*\253\0015\1\0\17\1\1\205\1\255,\198\1\1\1\0\16T\1\255.L\1\0\16\202\1\255.\196\1\0\0155\1\25500\1\0\14\148\1\2550\142\1\0\r\1\1\229\1\255 \171\1\21\2\175\1\255\12\225\1\0\r/\1\255 \168\1\4\1\0\2\23\1\255\r)\1\0\12k\1\255\31\168\1\4\1\0\3\24\1\255\rf\1\0\12\157\1\255\30\168\1\4\1\0\3\4\1\172\1\255\r\152\1\0\12\197\1\255\29\168\1\4\1\0\3\4\1\168\1\255\14\192\1\0\12\226\1\255\28\168\1\4\1\0\3\4\1\168\1\255\15\222\1\0\12\245\1\255\27\168\1\4\1\0\3\4\1\168\1\255\16\242\1\0\12\254\1\255\26\168\1\4\1\0\3\4\1\168\1\255\17\252\1\0\12\254\1\255\r\173\1\21\2\171\1\255\8\168\1\4\1\0\3\4\1\168\1\255\18\252\1\0\12\245\1\255\r\21\1\0\2\4\1\168\1\255\6\168\1\4\1\0\3\4\1\168\1\255\19\242\1\0\12\225\1\255\r\22\1\0\3\4\1\168\1\255\4\168\1\4\1\0\3\4\1\168\1\255\20\223\1\0\12\196\1\255\r\171\1\4\1\0\3\4\1\168\1\255\2\168\1\4\1\0\3\4\1\168\1\255\21\193\1\0\12\156\1\255\14\168\1\4\1\0\3\4\1\168\2\4\1\0\3\4\1\168\1\255\22\152\1\0\12j\1\255\15\168\1\4\1\0\3\4\2\0\3\4\1\168\1\255\23f\1\0\12.\1\255\16\168\1\4\1\0\6\4\1\168\1\255\24)\1\0\12\1\1\228\1\255\16\168\1\4\1\0\4\4\1\168\1\255\24\225\1\0\14\147\1\255\17\168\1\4\1\0\2\4\1\168\1\255\25\142\1\0\0144\1\255\18\172\1\23\2\172\1\255\0261\1\0\15\201\1\255.\197\1\0\16R\1\255.M\1\0\16\1\1\203\1\255,\199\1\1\1\0\17:\1\253\1\255*\253\0015\1\0\19\148\1\255*\145\1\0\20\n\1\212\1\255(\209\1\t\1\0\21'\1\239\1\255&\238\1%\1\0\23@\1\247\1\255$\247\1?\1\0\25K\1\248\1\255\"\247\1J\1\0\27A\1\239\1\255 \238\1?\1\0\29'\1\212\1\255\30\209\1%\1\0\31\t\1\147\1\253\1\255\26\253\1\145\1\t\1\0\"7\1\201\1\255\24\199\0015\1\0%\1\1O\1\199\1\255\20\197\1M\1\1\1\0)2\1\144\1\226\1\255\14\225\1\142\0011\1\0/*\1g\1\153\1\193\1\223\1\242\1\255\2\242\1\223\1\192\1\152\1f\1)\1\0\255\0\154",
	}

	r5.person = {
		w = 64,
		h = 64,
		data = "\0\255\0\155'\1p\1\170\1\213\1\243\1\255\2\242\1\212\1\169\1o\1%\1\0001\5\1_\1\204\1\255\12\202\1^\1\5\1\0-M\1\220\1\255\16\218\1J\1\0*\11\1\161\1\255\20\158\1\n\1\0'\26\1\208\1\255\22\205\1\25\1\0%\26\1\220\1\255\24\218\1\25\1\0#\11\1\206\1\255\26\205\1\n\1\0\"\160\1\255\28\156\1\0!M\1\255\30I\1\0\31\5\1\219\1\255\30\216\1\4\1\0\30`\1\255 Z\1\0\30\203\1\255 \198\1\0\29%\1\255!\254\1!\1\0\28n\1\255\"k\1\0\28\170\1\255\"\165\1\0\28\213\1\255\"\208\1\0\28\241\1\255\"\236\1\0\27\1\1\254\1\255\"\250\1\0\27\1\1\254\1\255\"\250\1\0\28\239\1\255\"\236\1\0\28\210\1\255\"\208\1\0\28\167\1\255\"\165\1\0\28n\1\255\"k\1\0\28$\1\255!\254\1!\1\0\29\200\1\255 \197\1\0\30\\\1\255 X\1\0\30\4\1\216\1\255\30\213\1\3\1\0\31I\1\255\30D\1\0!\156\1\255\28\152\1\0\"\t\1\204\1\255\26\200\1\8\1\0#\23\1\216\1\255\24\214\1\21\1\0%\23\1\203\1\255\22\201\1\22\1\0'\t\1\154\1\255\20\152\1\8\1\0)\26\1\179\1\255\18\177\1\25\1\0(?\1\176\1\252\1\255\20\252\1\174\1=\1\0$8\1\193\1\255\26\191\0016\1\0 \19\1\160\1\254\1\255\28\254\1\156\1\17\1\0\29G\1\231\1\255 \229\1D\1\0\26\1\1~\1\253\1\255\"\253\1{\1\1\1\0\23\6\1\165\1\255&\162\1\5\1\0\21\7\1\180\1\255(\177\1\6\1\0\19\3\1\175\1\255*\171\1\3\1\0\18\148\1\255,\144\1\0\17e\1\255.`\1\0\15+\1\246\1\255.\245\1(\1\0\r\4\1\204\1\2550\201\1\3\1\0\12p\1\2552n\1\0\12\234\1\2552\232\1\0\12\233\1\2552\231\1\0\12P\1\232\1\2550\231\1N\1\0\255\0\255\0\8",
	}

	r5.plus = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\11+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\22\173\1\20\1\21\1\175\1\255\22\0\16\255\22\20\1\0\2\23\1\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\8\173\1\20\1\0\28\21\1\175\1\255\8\0\16\255\8\20\1\0\30\23\1\255\8\0\16\255\8\21\1\0\30\24\1\255\8\0\16\255\8\175\1\22\1\0\28\23\1\177\1\255\8\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\21\1\0\2\24\1\255\22\0\16\255\22\175\1\22\1\23\1\177\1\255\22\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.pulse = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\137+\1\180\1\246\1\255,\246\1\178\1)\1\0\r+\1\241\1\2550\240\1(\1\0\12\180\1\2552\176\1\0\12\246\1\2552\243\1\0\12\2554\0\12\2554\0\12\255\18\171\1\19\2\173\1\255\30\0\12\255\17\234\1\15\1\0\2\19\1\246\1\255\29\0\12\255\17g\1\0\4\155\1\255\29\0\12\255\16\213\1\4\1\0\4,\1\254\1\255\28\0\12\255\16F\1\0\6\192\1\255\28\0\12\255\15\175\1\0\7S\1\255\28\0\12\255\14\249\1%\1\0\3\"\1\0\3\4\1\225\1\255\27\0\12\255\14\139\1\0\3\3\1\209\0013\1\0\3w\1\255\27\0\12\255\r\234\1\16\1\0\3h\1\255\1\157\1\0\3\17\1\245\1\255\26\0\12\255\rh\1\0\3\r\1\231\1\255\1\248\1\22\1\0\3\156\1\255\26\0\12\255\12\213\1\4\1\0\3\139\1\255\3y\1\0\3,\1\254\1\255\25\0\12\255\12F\1\0\3\"\1\248\1\255\3\228\1\5\1\0\3\192\1\255\25\0\12\255\11\176\1\0\4\175\1\255\5U\1\0\3S\1\255\25\0\12\255\n\249\1&\1\0\3A\1\255\6\194\1\0\3\3\1\223\1\255\24\0\12\255\4\173\1\20\1\0\8\3\1\207\1\255\0071\1\0\3x\1\255\n\171\1\20\1\0\6\23\1\178\1\255\4\0\12\255\4\20\1\0\te\1\255\8\158\1\0\3\19\1\246\1\255\8\233\1\14\1\0\8\26\1\255\4\0\12\255\4\21\1\0\8\14\1\232\1\255\8\247\1\20\1\0\3\156\1\255\8f\1\0\t\26\1\255\4\0\12\255\4\175\1\22\1\0\6\23\1\173\1\255\nz\1\0\3/\1\255\7\208\1\3\1\0\8\22\1\178\1\255\4\0\12\255\24\229\1\5\1\0\3\193\1\255\6E\1\0\3#\1\248\1\255\n\0\12\255\25U\1\0\3T\1\255\5\174\1\0\4\178\1\255\11\0\12\255\25\194\1\0\3\3\1\223\1\255\3\249\1%\1\0\3B\1\255\12\0\12\255\0264\1\0\3y\1\255\3\137\1\0\3\3\1\210\1\255\12\0\12\255\26\158\1\0\3\18\1\245\1\255\1\233\1\15\1\0\3i\1\255\r\0\12\255\26\248\1\23\1\0\3\157\1\255\1f\1\0\3\14\1\232\1\255\r\0\12\255\27z\1\0\3,\1\212\1\4\1\0\3\140\1\255\14\0\12\255\27\227\1\4\1\0\3\"\1\0\3$\1\249\1\255\14\0\12\255\28V\1\0\7\175\1\255\15\0\12\255\28\195\1\0\6A\1\255\16\0\12\255\0294\1\0\4\2\1\204\1\255\16\0\12\255\29\159\1\0\4f\1\255\17\0\12\255\29\247\1\21\1\0\2\14\1\232\1\255\17\0\12\255\30\177\1\23\2\174\1\255\18\0\12\2554\0\12\2554\0\12\245\1\2552\243\1\0\12\179\1\2552\175\1\0\12)\1\240\1\2550\239\1'\1\0\r(\1\177\1\244\1\255,\243\1\175\1'\1\0\255\0\255\0\137",
	}

	r5.refresh = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\28\t\0015\1Y\1r\1\129\1\136\1|\1m\1Q\1)\1\3\1\00022\1\133\1\202\1\251\1\255\t\243\1\185\1o\1\28\1\0,\7\1f\1\209\1\255\16\253\1\182\1F\1\0\nT\1\234\1\233\1O\1\0\26\2\1a\1\227\1\255\21\199\1;\1\0\7V\1\251\1\255\2\232\1\0\25&\1\196\1\255\7\253\1\216\1\172\1\142\1{\1w\1\129\1\148\1\183\1\229\1\255\7\254\1\155\1\14\1\0\4V\1\251\1\255\4\0\24[\1\244\1\255\5\250\1\175\1X\1\18\1\0\t#\1o\1\200\1\255\6\220\0010\1\0\2V\1\251\1\255\5\0\22\1\1\133\1\255\5\245\1\138\1\26\1\0\0152\1\173\1\254\1\255\4\245\1N\1V\1\251\1\255\6\0\22\134\1\255\5\174\1\28\1\0\19<\1\212\1\255\4\251\2\255\7\0\22\239\1\255\3\245\1^\1\0\22\8\1\147\1\255\12\0\22\199\1\255\2\233\0014\1\0\25f\1\252\1\255\n\0\22\30\1\156\1\159\1%\1\0\26Y\1\252\1\255\n\0003U\1\251\1\255\11\0002U\1\251\1\255\12\0001U\1\251\1\255\r\0000U\1\251\1\255\14\0000\235\1\255\15\0000\234\1\255\14\231\1\0000P\1\233\1\255\12\232\1N\1\0\255\0\255\0\255\0\19R\1\235\1\255\12\235\1Q\1\0000\235\1\255\14\234\1\0000\255\15\233\1\0000\255\14\252\1T\1\0000\255\r\252\1\\\1\0001\255\12\252\1\\\1\0002\255\11\252\1\\\1\0003\255\n\252\1Y\1\0\26&\1\165\1\160\1\30\1\0\22\255\n\252\1g\1\0\0259\1\236\1\255\2\198\1\0\22\255\12\150\1\t\1\0\22h\1\247\1\255\3\237\1\0\22\255\7\251\2\255\4\214\1?\1\0\19\"\1\181\1\255\5\130\1\0\22\255\6\251\1W\1N\1\244\1\255\5\178\0017\1\0\15\31\1\146\1\248\1\255\4\254\1\129\1\0\23\255\5\251\1W\1\0\0020\1\220\1\255\6\205\1t\1)\1\0\t\25\1b\1\183\1\252\1\255\5\242\1W\1\0\24\255\4\251\1W\1\0\4\14\1\155\1\254\1\255\7\235\1\188\1\155\1\136\1w\1\132\1\149\1\181\1\223\1\255\8\195\1#\1\0\25\234\1\255\2\251\1W\1\0\7;\1\199\1\255\21\225\1^\1\1\1\0\26O\1\233\1\232\1S\1\0\nF\1\182\1\253\1\255\16\209\1c\1\6\1\0,\27\1n\1\182\1\242\1\255\t\251\1\200\1\130\1/\1\0002\3\1&\1M\1k\1x\1\136\1}\1o\1W\0013\1\t\1\0\255\0\255\0\28",
	}

	r5.save = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\11+\1\180\1\246\1\255\31\251\1\196\1@\1\0\26+\1\241\1\255#\251\1W\1\0\25\180\1\255%\251\1W\1\0\24\246\1\255&\251\1W\1\0\23\255\4\0\31T\1\251\1\255\3\252\1\\\1\0\22\255\4\0 T\1\251\1\255\3\252\1\\\1\0\21\255\4\0!T\1\251\1\255\3\252\1\\\1\0\20\255\4\0\"T\1\251\1\255\3\252\1\\\1\0\19\255\4\0\nR\1\235\1\255\14\234\1P\1\0\7W\1\251\1\255\3\251\1W\1\0\18\255\4\0\n\235\1\255\16\232\1\0\8W\1\251\1\255\3\251\1W\1\0\17\255\4\0\n\234\1\255\16\231\1\0\tW\1\251\1\255\3\251\1?\1\0\16\255\4\0\nP\1\233\1\255\14\232\1N\1\0\nW\1\251\1\255\3\193\1\0\16\255\4\0'W\1\255\3\248\1\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0\7+\1\180\1\246\1\255\20\246\1\178\1)\1\0\7\255\4\0\16\255\4\0\6+\1\241\1\255\24\240\1(\1\0\6\255\4\0\16\255\4\0\6\180\1\255\26\176\1\0\6\255\4\0\16\255\4\0\6\246\1\255\26\243\1\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\255\4\0\6\255\28\0\6\255\4\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.search = {
		w = 64,
		h = 64,
		data = "\0\255\0\150\15\1T\1\143\1\189\1\225\1\248\1\255\2\249\1\224\1\189\1\141\1P\1\15\1\0/\3\1P\1\180\1\250\1\255\12\249\1\178\1O\1\2\1\0*\1\1[\1\219\1\255\18\217\1Y\1\1\1\0'*\1\197\1\255\22\195\1'\1\0%e\1\247\1\255\6\217\1\143\1V\1,\1\15\1\0\2\16\1,\1W\1\144\1\218\1\255\6\245\1b\1\0\"\2\1\145\1\255\5\250\1\161\0015\1\0\0126\1\162\1\251\1\255\5\141\1\1\1\0\31\2\1\159\1\255\5\179\1%\1\0\16&\1\182\1\255\5\157\1\1\1\0\30\144\1\255\4\244\1_\1\0\20b\1\245\1\255\4\140\1\0\29d\1\255\4\230\0010\1\0\5\3\1D\1\144\1\199\1\234\1\255\2\234\1\198\1\143\1B\1\2\1\0\0052\1\231\1\255\4`\1\0\27)\1\246\1\255\3\230\1&\1\0\4\4\1i\1\223\1\255\n\221\1f\1\4\1\0\4&\1\231\1\255\3\245\1&\1\0\25\1\1\197\1\255\3\244\0010\1\0\4-\1\207\1\255\14\205\1*\1\0\0043\1\246\1\255\3\192\1\1\1\0\24Z\1\255\4_\1\0\4O\1\245\1\255\16\243\1K\1\0\4c\1\255\4U\1\0\23\3\1\218\1\255\3\179\1\0\4O\1\251\1\255\18\250\1K\1\0\4\184\1\255\3\213\1\1\1\0\22N\1\255\3\250\1%\1\0\3-\1\244\1\255\20\243\1)\1\0\3)\1\252\1\255\3I\1\0\22\177\1\255\3\161\1\0\3\4\1\208\1\255\22\204\1\3\1\0\3\165\1\255\3\173\1\0\21\r\1\249\1\255\0035\1\0\3h\1\255\24d\1\0\0039\1\255\3\247\1\12\1\0\20P\1\255\3\217\1\0\3\2\1\221\1\255\24\219\1\2\1\0\3\222\1\255\3K\1\0\20\139\1\255\3\143\1\0\3B\1\255\26@\1\0\3\148\1\255\3\134\1\0\20\185\1\255\3V\1\0\3\143\1\255\26\140\1\0\3Z\1\255\3\181\1\0\20\221\1\255\3+\1\0\3\200\1\255\26\196\1\0\3/\1\255\3\217\1\0\20\243\1\255\3\15\1\0\3\236\1\255\26\232\1\0\3\18\1\255\3\240\1\0\20\254\1\255\3\1\1\0\2\1\1\254\1\255\26\251\1\0\3\3\1\255\3\251\1\0\20\254\1\255\3\1\1\0\2\1\1\253\1\255\26\251\1\0\3\3\1\255\3\250\1\0\20\243\1\255\3\16\1\0\3\235\1\255\26\232\1\0\3\18\1\255\3\238\1\0\20\219\1\255\3,\1\0\3\197\1\255\26\194\1\0\0030\1\255\3\215\1\0\20\184\1\255\3X\1\0\3\141\1\255\26\138\1\0\3Z\1\255\3\180\1\0\20\136\1\255\3\145\1\0\3A\1\255\26>\1\0\3\149\1\255\3\133\1\0\20L\1\255\3\219\1\0\3\2\1\221\1\255\24\217\1\1\1\0\2\1\1\223\1\255\3H\1\0\20\12\1\247\1\255\0038\1\0\3e\1\255\24a\1\0\3;\1\255\3\245\1\n\1\0\21\173\1\255\3\164\1\0\3\3\1\205\1\255\22\203\1\3\1\0\3\167\1\255\3\168\1\0\22J\1\255\3\251\1(\1\0\3*\1\243\1\255\20\242\1'\1\0\3*\1\252\1\255\3E\1\0\22\2\1\213\1\255\3\184\1\0\4K\1\250\1\255\18\249\1G\1\0\4\187\1\255\3\209\1\1\1\0\23S\1\255\4d\1\0\4K\1\243\1\255\16\242\1G\1\0\4f\1\255\4O\1\0\24\1\1\190\1\255\3\246\0014\1\0\4)\1\205\1\255\14\202\1'\1\0\0045\1\246\1\255\3\186\1\0\26#\1\243\1\255\3\232\1(\1\0\4\3\1d\1\219\1\255\n\219\1b\1\3\1\0\4'\1\232\1\255\3\242\1!\1\0\27[\1\255\4\232\0014\1\0\5\2\1?\1\139\1\195\1\231\1\252\2\231\1\194\1\138\1>\1\2\1\0\0055\1\232\1\255\4Y\1\0\29\135\1\255\4\246\1e\1\0\20f\1\246\1\255\4\252\1W\1\0\29\1\1\150\1\255\5\186\1)\1\0\16*\1\187\1\255\7\251\1W\1\0\29\1\1\133\1\255\5\252\1\166\1:\1\0\12;\1\167\1\252\1\255\5\253\1\255\3\251\1W\1\0\30Z\1\242\1\255\6\222\1\149\1[\0010\1\20\1\0\2\20\0010\1Z\1\149\1\223\1\255\6\242\1Y\1W\1\251\1\255\3\251\1W\1\0\30\"\1\188\1\255\22\185\1!\1\0\2W\1\251\1\255\3\251\1W\1\0\31O\1\209\1\255\18\207\1M\1\0\5W\1\251\1\255\3\251\1W\1\0\31\1\1E\1\168\1\245\1\255\12\244\1\166\1B\1\0\8W\1\251\1\255\3\251\1W\1\0!\t\1G\1\130\1\175\1\212\1\235\1\249\1\246\1\234\1\212\1\177\1\130\1F\1\8\1\0\11W\1\251\1\255\3\251\1W\1\0:T\1\251\1\255\3\252\1\\\1\0:T\1\251\1\255\3\252\1\\\1\0:T\1\251\1\255\3\252\1\\\1\0:T\1\251\1\255\3\252\1\\\1\0:W\1\251\1\255\3\251\1S\1\0:W\1\251\1\255\3\232\1\0;W\1\251\1\255\2\231\1\0<S\1\232\2N\1\0\255\0\135",
	}

	r5.shield = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\139+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\22\173\1\20\1\21\1\175\1\255\22\0\16\255\22\20\1\0\2\23\1\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\255\22\0\4\255\22\0\16\254\1\255\21\0\4\255\21\253\1\0\16\248\1\255\21\0\4\255\21\246\1\0\16\236\1\255\21\0\4\255\21\233\1\0\16\216\1\255\21\0\4\255\21\213\1\0\16\189\1\255\21\0\4\255\21\186\1\0\16\155\1\255\21\0\4\255\21\151\1\0\16q\1\255\21\21\1\0\2\24\1\255\21n\1\0\16@\1\255\21\175\1\22\1\23\1\177\1\255\21<\1\0\16\12\1\250\1\255,\249\1\t\1\0\17\197\1\255,\193\1\0\18z\1\255,u\1\0\18'\1\255+\254\1\"\1\0\19\201\1\255\18\248\1j\1\12\1\r\1k\1\248\1\255\18\196\1\0\20b\1\255\18i\1\0\4m\1\255\18\\\1\0\20\8\1\231\1\255\17\r\1\0\4\16\1\255\17\228\1\6\1\0\21q\1\255\17\14\1\0\4\16\1\255\17m\1\0\22\8\1\223\1\255\16k\1\0\4o\1\255\16\221\1\7\1\0\23R\1\255\16\248\1m\1\14\1\16\1o\1\248\1\255\16N\1\0\25\174\1\255$\170\1\0\26\21\1\230\1\255\"\227\1\19\1\0\27?\1\250\1\255 \249\1;\1\0\29g\1\255 e\1\0\31\130\1\255\30\128\1\0!\137\1\255\28\136\1\0#z\1\254\1\255\24\254\1z\1\0%Z\1\246\1\255\22\246\1\\\1\0'0\1\217\1\255\20\217\0010\1\0)\11\1\150\1\254\1\255\16\254\1\150\1\12\1\0,<\1\209\1\255\14\209\1=\1\0/\3\1c\1\225\1\255\n\225\1d\1\3\1\0002\6\1d\1\213\1\255\6\212\1d\1\6\1\0006\1\1>\1\156\1\234\1\235\1\157\1>\1\0\255\0\30",
	}

	r5.shoot = {
		w = 64,
		h = 64,
		data = "\0\255\0\153\1\1/\1k\1\156\1\196\1\228\1\245\1\255\2\244\1\225\1\195\1\155\1i\1,\1\0/5\1\148\1\229\1\255\14\226\1\145\0011\1\0)\1\1T\1\202\1\255\20\198\1N\1\1\1\0%<\1\205\1\255\24\200\0016\1\0\"\11\1\151\1\254\1\255\6\242\1\177\1w\1F\1$\1\12\1\0\2\r\1$\1G\1x\1\178\1\243\1\255\6\253\1\144\1\t\1\0\31)\1\214\1\255\5\253\1\180\1P\1\7\1\0\12\8\1Q\1\181\1\253\1\255\5\209\1$\1\0\29C\1\241\1\255\4\254\1\168\1)\1\0\18*\1\170\1\254\1\255\4\237\1=\1\0\27L\1\248\1\255\4\217\1=\1\0\22?\1\218\1\255\4\246\1G\1\0\25C\1\248\1\255\4\158\1\n\1\0\6\"\1m\1\167\1\210\1\0\4\210\1\167\1l\1\"\1\0\6\11\1\161\1\255\4\246\1>\1\0\23)\1\241\1\255\3\254\1s\1\0\5\4\1[\1\198\1\255\4\0\4\255\4\197\1Y\1\3\1\0\5u\1\254\1\255\3\237\1$\1\0\21\11\1\214\1\255\3\254\1e\1\0\5I\1\216\1\255\6\0\4\255\6\214\1F\1\0\5f\1\254\1\255\3\209\1\8\1\0\20\151\1\255\4s\1\0\4\n\1\156\1\255\8\0\4\255\8\153\1\8\1\0\4v\1\255\4\143\1\0\19<\1\254\1\255\3\158\1\0\4\23\1\204\1\255\t\0\4\255\t\201\1\22\1\0\4\162\1\255\3\253\0015\1\0\17\1\1\205\1\255\3\217\1\n\1\0\3\23\1\215\1\255\n\0\4\255\n\214\1\22\1\0\3\11\1\219\1\255\3\198\1\1\1\0\16T\1\255\3\254\1=\1\0\3\n\1\204\1\255\11\21\1\0\2\24\1\255\11\201\1\8\1\0\3A\1\255\4L\1\0\16\202\1\255\3\169\1\0\4\156\1\255\12\175\1\22\1\23\1\177\1\255\12\152\1\0\4\172\1\255\3\196\1\0\0155\1\255\3\253\1)\1\0\3I\1\255\29\254\1E\1\0\3,\1\254\1\255\0030\1\0\14\148\1\255\3\180\1\0\3\4\1\216\1\255\30\213\1\3\1\0\3\183\1\255\3\142\1\0\r\1\1\229\1\255\3P\1\0\3[\1\255 X\1\0\3T\1\255\3\225\1\0\r/\1\255\3\242\1\7\1\0\3\199\1\255 \196\1\0\3\t\1\244\1\255\3)\1\0\12k\1\255\3\177\1\0\3\"\1\255!\254\1 \1\0\3\182\1\255\3f\1\0\12\157\1\255\3v\1\0\3m\1\255\"j\1\0\3y\1\255\3\152\1\0\12\197\1\255\3G\1\0\3\167\1\255\"\164\1\0\3J\1\255\3\192\1\0\12\226\1\255\3$\1\0\3\210\1\255\"\208\1\0\3'\1\255\3\222\1\0\12\245\1\255\3\12\1\0\t\21\1\175\1\255\20\173\1\20\1\0\t\16\1\255\3\242\1\0\12\254\1\255\3\2\1\0\n\23\1\255\20\20\1\0\n\3\1\255\3\252\1\0\12\254\1\255\3\2\1\0\n\24\1\255\20\21\1\0\n\4\1\255\3\252\1\0\12\245\1\255\3\r\1\0\t\23\1\177\1\255\20\175\1\22\1\0\t\17\1\255\3\242\1\0\12\225\1\255\3$\1\0\3\210\1\255\"\207\1\0\3(\1\255\3\223\1\0\12\196\1\255\3H\1\0\3\167\1\255\"\163\1\0\3L\1\255\3\193\1\0\12\156\1\255\3w\1\0\3l\1\255\"i\1\0\3{\1\255\3\152\1\0\12j\1\255\3\178\1\0\3\"\1\254\1\255 \254\1\31\1\0\3\184\1\255\3f\1\0\12.\1\255\3\242\1\8\1\0\3\197\1\255 \195\1\0\3\11\1\246\1\255\3)\1\0\12\1\1\228\1\255\3Q\1\0\3Y\1\255 W\1\0\3W\1\255\3\225\1\0\14\147\1\255\3\181\1\0\3\3\1\214\1\255\30\211\1\3\1\0\3\186\1\255\3\142\1\0\0144\1\255\3\253\1*\1\0\3F\1\255\29\254\1B\1\0\3/\1\254\1\255\0031\1\0\15\201\1\255\3\170\1\0\4\153\1\255\12\173\1\20\1\21\1\175\1\255\12\148\1\0\4\176\1\255\3\197\1\0\16R\1\255\3\254\1?\1\0\3\8\1\201\1\255\11\20\1\0\2\23\1\255\11\198\1\7\1\0\3E\1\255\4M\1\0\16\1\1\203\1\255\3\218\1\11\1\0\3\22\1\214\1\255\n\0\4\255\n\213\1\21\1\0\3\r\1\221\1\255\3\199\1\1\1\0\17:\1\253\1\255\3\161\1\0\4\22\1\201\1\255\t\0\4\255\t\198\1\21\1\0\4\167\1\255\3\253\0015\1\0\19\148\1\255\4u\1\0\4\8\1\152\1\255\8\0\4\255\7\254\1\148\1\7\1\0\4{\1\255\4\145\1\0\20\n\1\212\1\255\3\254\1f\1\0\5E\1\213\1\255\6\0\4\255\6\211\1B\1\0\5j\1\254\1\255\3\209\1\t\1\0\21'\1\239\1\255\3\254\1v\1\0\5\3\1X\1\196\1\255\4\0\4\255\3\254\1\195\1W\1\2\1\0\5{\1\254\1\255\3\238\1%\1\0\23@\1\247\1\255\4\162\1\11\1\0\6 \1j\1\164\1\207\1\0\4\207\1\163\1i\1\31\1\0\6\r\1\167\1\255\4\247\1?\1\0\25K\1\248\1\255\4\219\1@\1\0\22E\1\221\1\255\4\247\1J\1\0\27A\1\239\1\255\5\173\1,\1\0\18/\1\176\1\255\5\238\1?\1\0\29'\1\212\1\255\5\254\1\183\1T\1\t\1\0\12\n\1W\1\186\1\254\1\255\5\209\1%\1\0\31\t\1\147\1\253\1\255\6\244\1\181\1z\1J\1(\1\15\1\0\2\17\1)\1L\1|\1\184\1\246\1\255\6\253\1\145\1\t\1\0\"7\1\201\1\255\24\199\0015\1\0%\1\1O\1\199\1\255\20\197\1M\1\1\1\0)2\1\144\1\226\1\255\14\225\1\142\0011\1\0/*\1g\1\153\1\193\1\223\1\242\1\255\2\242\1\223\1\192\1\152\1f\1)\1\0\255\0\154",
	}

	r5.signal = {
		w = 64,
		h = 64,
		data = "\0\255\0\174*\1\179\1\246\2\177\1(\1\00096\1\240\1\255\4\239\1(\1\00076\1\240\1\255\6\176\1\00066\1\240\1\255\7\243\1\00052\1\237\1\255\t\00042\1\237\1\255\n\00032\1\237\1\255\11\00022\1\237\1\255\12\00012\1\237\1\255\r\00002\1\237\1\255\14\0/2\1\237\1\255\15\0.2\1\237\1\255\16\0-2\1\237\1\255\17\0,2\1\237\1\255\18\0+2\1\237\1\255\19\0*2\1\237\1\255\20\0)2\1\237\1\255\21\0(2\1\237\1\255\22\0'2\1\237\1\255\23\0&2\1\237\1\255\24\0%2\1\237\1\255\25\0$2\1\237\1\255\26\0#2\1\237\1\255\27\0\"2\1\237\1\255\28\0!2\1\237\1\255\29\0 2\1\237\1\255\30\0\0312\1\237\1\255\31\0\0302\1\237\1\255 \0\0292\1\237\1\255!\0\0282\1\237\1\255\"\0\0272\1\237\1\255#\0\0262\1\237\1\255$\0\0252\1\237\1\255%\0\0242\1\237\1\255&\0\0232\1\237\1\255'\0\0222\1\237\1\255(\0\0212\1\237\1\255)\0\0202\1\237\1\255*\0\0192\1\237\1\255+\0\0182\1\237\1\255,\0\0172\1\237\1\255-\0\16*\1\240\1\255.\0\16\179\1\255/\0\16\245\1\255/\0\16\245\1\255.\243\1\0\16\177\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\175\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\143",
	}

	r5.silenced = {
		w = 64,
		h = 64,
		data = "\0\255\0\167\\\1\234\1\233\1P\1\0:\6\1\148\1\255\3\231\1\0\"K\1\230\1\232\1R\1\0\19\29\1\199\1\255\5\0\"\229\1\255\2\249\1E\1\0\17C\1\234\1\255\6\0\"\231\1\255\3\243\0014\1\0\14\1\1y\1\252\1\255\7\0\"V\1\253\1\255\3\234\1&\1\0\12\16\1\177\1\255\t\0#i\1\255\4\226\1\29\1\0\n/\1\219\1\255\n\0$\133\1\255\4\211\1\17\1\0\8[\1\244\1\255\11\0$\1\1\156\1\255\4\194\1\t\1\0\5\6\1\150\1\255\r\0%\3\1\176\1\255\4\176\1\3\1\0\4a\1\255\14\0&\t\1\194\1\255\4\155\1\1\1\0\3\25\1\224\1\255\r\0'\14\1\207\1\255\4\133\1\0\4$\1\232\1\255\12\0(\26\1\223\1\255\4q\1\0\0045\1\243\1\255\11\0)$\1\232\1\255\3\254\1^\1\0\4B\1\248\1\255\n\0\29+\1\180\1\246\1\255\15\249\1E\1\0\4[\1\254\1\255\t\0\14P\1\235\2Q\1\0\n+\1\241\1\255\18\243\0014\1\0\4q\1\255\t\0\14\233\1\255\2\232\1\0\n\180\1\255\20\234\1&\1\0\4\136\1\255\8\0\14\255\4\0\n\246\1\255\21\223\1\26\1\0\3\1\1\159\1\255\7\0\14\255\4\0\n\255\23\209\1\16\1\0\3\4\1\179\1\255\6\0\6S\1\236\1\234\1M\1\0\4\255\4\0\n\255\24\194\1\t\1\0\3\n\1\197\1\255\5\0\6\234\1\255\2\230\1\0\4\255\4\0\n\255\25\176\1\3\1\0\3\18\1\212\1\255\4\0\6\255\4\0\4\255\4\0\n\255\26\162\1\1\1\0\3\26\1\224\1\255\3\0\6\255\4\0\4\255\4\0\n\255\27\133\1\0\4%\1\233\1\255\2\0\6\255\4\0\4\255\4\0\n\255\28m\1\0\0048\1\244\1\238\1\0\6\255\4\0\4\255\4\0\n\255\28\253\1X\1\0\4'\1%\1\0\6\255\4\0\4\255\4\0\n\255\29\250\1H\1\0\11\255\4\0\4\255\4\0\n\255\30\245\0019\1\0\n\255\4\0\4\255\4\0\n\255\31\235\1(\1\0\t\255\4\0\4\255\4\0\n\255 \226\1\29\1\0\8\255\4\0\4\255\4\0\n\255!\211\1\17\1\0\7\255\4\0\4\255\4\0\n\255\"\199\1\n\1\0\6\255\4\0\4\255\4\0\n\255#\176\1\3\1\0\5\255\4\0\4\255\4\0\n\255$\155\1\1\1\0\4\234\1\255\2\229\1\0\4\255\4\0\n\255%\133\1\0\4Q\1\233\1\231\1J\1\0\4\255\4\0\n\245\1\255%m\1\0\11\255\4\0\n\179\1\255%\253\1X\1\0\n\255\4\0\n)\1\240\1\255%\249\1E\1\0\t\232\1\255\2\231\1\0\11(\1\177\1\244\1\255 \249\1\255\3\243\0014\1\0\8M\1\231\2N\1\0\25)\1\214\1\255\19X\1\253\1\255\3\235\1(\1\0%\14\1\172\1\255\18\0\1j\1\255\4\226\1\29\1\0%\1\1o\1\251\1\255\16\0\2\133\1\255\4\211\1\17\1\0&?\1\232\1\255\15\0\2\1\1\155\1\255\4\199\1\n\1\0&\28\1\198\1\255\14\0\3\3\1\172\1\255\4\178\1\4\1\0&\4\1\136\1\255\r\0\4\t\1\193\1\255\4\162\1\1\1\0'[\1\244\1\255\11\0\5\14\1\207\1\255\4\133\1\0()\1\214\1\255\n\0\6\26\1\222\1\255\4q\1\0(\16\1\177\1\255\t\0\7&\1\234\1\255\3\253\1V\1\0(\1\1z\1\252\1\255\7\0\0084\1\243\1\255\3\234\1\0*D\1\234\1\255\6\0\tE\1\249\1\255\2\236\1\1\1\0*\29\1\200\1\255\5\0\nR\1\235\1\236\1U\1\0,\7\1\150\1\255\3\228\1\0<]\1\232\1\231\1L\1\0\255\0\151",
	}

	r5.skull = {
		w = 64,
		h = 64,
		data = "\0\255\0\25\4\0017\1q\1\161\1\199\1\227\1\246\1\255\2\245\1\228\1\198\1\161\1q\0016\1\3\1\0-\2\1G\1\162\1\238\1\255\14\237\1\160\1F\1\2\1\0(\8\1m\1\221\1\255\20\220\1k\1\8\1\0$\1\1_\1\228\1\255\24\226\1\\\1\1\1\0!!\1\190\1\255\28\189\1 \1\0\31R\1\241\1\255\30\239\1P\1\0\29|\1\254\1\255 \254\1y\1\0\26\1\1\142\1\255$\139\1\0\25\135\1\255&\131\1\0\23f\1\255(a\1\0\0215\1\249\1\255(\248\0011\1\0\19\t\1\217\1\255*\214\1\7\1\0\18\135\1\255,\128\1\0\17 \1\248\1\255,\246\1\27\1\0\16\154\1\255.\149\1\0\15\23\1\247\1\255.\246\1\20\1\0\14v\1\2550q\1\0\14\207\1\2550\203\1\0\r\31\1\2551\254\1\26\1\0\12`\1\2552[\1\0\12\149\1\2552\146\1\0\12\192\1\2552\189\1\0\12\223\1\2552\221\1\0\12\245\1\2552\242\1\0\12\254\1\255\r\172\1<\1\7\2=\1\173\1\255\12\172\1<\1\7\2=\1\173\1\255\r\252\1\0\12\254\1\255\12r\1\0\6s\1\255\nr\1\0\6s\1\255\12\252\1\0\12\244\1\255\11\171\1\0\8\175\1\255\8\171\1\0\8\175\1\255\11\240\1\0\12\222\1\255\11;\1\0\8>\1\255\8;\1\0\8>\1\255\11\218\1\0\12\189\1\255\11\8\1\0\8\n\1\255\8\8\1\0\8\n\1\255\11\186\1\0\12\146\1\255\11\8\1\0\8\n\1\255\8\8\1\0\8\n\1\255\11\142\1\0\12\\\1\255\11<\1\0\8?\1\255\8<\1\0\8?\1\255\11W\1\0\12\26\1\254\1\255\n\173\1\0\8\177\1\255\8\173\1\0\8\177\1\255\n\253\1\23\1\0\r\203\1\255\11s\1\0\6v\1\255\ns\1\0\6v\1\255\11\198\1\0\14r\1\255\12\175\1?\1\t\2?\1\177\1\255\12\175\1?\1\t\2?\1\177\1\255\12l\1\0\14\19\1\246\1\255.\244\1\17\1\0\15\150\1\255.\145\1\0\16\28\1\246\1\255,\245\1\26\1\0\17\129\1\255,~\1\0\18\8\1\214\1\255*\211\1\7\1\0\0192\1\248\1\255(\246\1.\1\0\21d\1\255(^\1\0\23\134\1\255&\130\1\0\25\142\1\255$\138\1\0\27{\1\254\1\255 \254\1x\1\0\29R\1\240\1\255\8\176\1\22\1\21\1\175\1\255\6\176\1\22\1\21\1\175\1\255\8\239\1O\1\0\31 \1\190\1\255\7\23\1\0\2\23\1\255\6\23\1\0\2\23\1\255\7\188\1\31\1\0!\1\1\255\7\0\4\255\6\0\4\255\7\1\1\0#\255\7\0\4\255\6\0\4\255\7\0$\255\7\0\4\255\6\0\4\255\7\0$\255\7\0\4\255\6\0\4\255\7\0$\245\1\255\6\0\4\255\6\0\4\255\6\243\1\0$\179\1\255\6\0\4\255\6\0\4\255\6\175\1\0$)\1\240\1\255\5\0\4\255\6\0\4\255\5\240\1'\1\0%(\1\177\1\244\1\255\2\198\1\0\4\202\1\255\4\199\1\0\4\202\1\255\2\244\1\176\1(\1\0\255\0\148",
	}

	r5.smoke = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\163\12\1M\1\137\1\185\1\219\1\243\1\255\2\243\1\219\1\185\1\137\1M\1\12\1\0/\2\1J\1\174\1\247\1\255\12\247\1\173\1G\1\1\1\0*\1\1T\1\214\1\255\18\211\1Q\1\0(%\1\190\1\255\22\187\1!\1\0%^\1\244\1\255\24\242\1W\1\0\"\1\1\138\1\255\27\254\1\130\1\0 \1\1\155\1\255\30\146\1\1\1\0\30\139\1\255 \131\1\0\29`\1\255\"W\1\0\27%\1\245\1\255\"\242\1!\1\0\25\1\1\192\1\255$\187\1\0\25T\1\255&P\1\0\16\15\1Y\1\128\1\14\1\0\3\2\1\213\1\255&\210\1\1\1\0\r&\1\157\1\247\1\255\2X\1\0\3K\1\255(G\1\0\11\n\1\141\1\251\1\255\3\254\1\26\1\0\3\175\1\255(\172\1\0\n%\1\212\1\255\5\209\1\0\3\r\1\248\1\255(\246\1\11\1\0\0081\1\234\1\255\6\148\1\0\3O\1\255*K\1\0\7$\1\235\1\255\7c\1\0\3\138\1\255*\135\1\0\6\n\1\211\1\255\8:\1\0\3\185\1\255*\181\1\0\6\141\1\255\t\29\1\0\3\220\1\255*\217\1\0\5&\1\250\1\255\t\t\1\0\3\243\1\255*\240\1\0\5\158\1\255\n\0\4\254\1\255*\252\1\0\4\15\1\246\1\255\n\21\1\0\2\26\1\255+\251\1\0\4Z\1\255\11\174\1\22\1\24\1\181\1\255+\238\1\0\4\157\1\255:\214\1\0\4\205\1\255:\179\1\0\4\238\1\255:\131\1\0\4\253\1\255:G\1\0\4\253\1\2559\245\1\t\1\0\4\237\1\2559\169\1\0\5\204\1\2559E\1\0\5\154\1\2558\208\1\1\1\0\5U\1\2558N\1\0\6\11\1\242\1\2556\186\1\0\8\145\1\2555\241\1 \1\0\8\27\1\245\1\2553\254\1W\1\0\nw\1\2553\132\1\0\11\3\1\191\1\2551\149\1\1\1\0\12\21\1\218\1\255.\254\1\131\1\1\1\0\14\29\1\216\1\255,\241\1V\1\0\17\18\1\184\1\255*\184\1!\1\0\19\1\1k\1\239\1\255&\208\1N\1\0\23\19\1\131\1\233\1\255!\245\1\167\1E\1\1\1\0\26\5\1F\1\141\1\192\1\230\1\250\1\255\23\239\1\214\1\179\1\132\1H\1\n\1\0\255\0\255\0\147",
	}

	r5.sortDown = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\11+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255 \171\1\20\1\21\1\171\1\255\12\0\16\255\31\170\1\4\1\0\2\3\1\163\1\255\11\0\16\255\8\173\1\20\1\0\n\21\1\175\1\255\8\168\1\4\1\0\4\4\1\168\1\255\n\0\16\255\8\20\1\0\12\23\1\255\7\168\1\4\1\0\6\4\1\168\1\255\t\0\16\255\8\21\1\0\12\24\1\255\6\168\1\4\1\0\8\4\1\168\1\255\8\0\16\255\8\175\1\22\1\0\n\23\1\177\1\255\5\168\1\4\1\0\n\4\1\168\1\255\7\0\16\255\26\170\1\4\1\0\3\4\1\0\4\4\1\0\3\4\1\172\1\255\6\0\16\255\26\21\1\0\3\4\1\168\1\0\4\168\1\4\1\0\3\23\1\255\6\0\16\255\26\22\1\0\2\4\1\168\1\255\1\0\4\255\1\168\1\4\1\0\2\24\1\255\6\0\16\255\26\175\1\23\2\172\1\255\2\0\4\255\2\172\1\23\2\177\1\255\6\0\16\255 \0\4\255\12\0\16\255 \0\4\255\12\0\16\255 \0\4\255\12\0\16\255 \0\4\255\12\0\16\255\8\173\1\20\1\0\12\21\1\175\1\255\8\0\4\255\12\0\16\255\8\20\1\0\14\23\1\255\8\0\4\255\12\0\16\255\8\21\1\0\14\24\1\255\8\0\4\255\12\0\16\255\8\175\1\22\1\0\12\23\1\177\1\255\8\0\4\255\12\0\16\255 \21\1\0\2\24\1\255\12\0\16\255 \175\1\22\1\23\1\177\1\255\12\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\8\173\1\20\1\0\24\21\1\175\1\255\12\0\16\255\8\20\1\0\26\23\1\255\12\0\16\255\8\21\1\0\26\24\1\255\12\0\16\255\8\175\1\22\1\0\24\23\1\177\1\255\12\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.sortUp = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\11+\1\180\1\246\1\255(\246\1\178\1)\1\0\17+\1\241\1\255,\240\1(\1\0\16\180\1\255.\176\1\0\16\246\1\255.\243\1\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255\8\173\1\20\1\0\24\21\1\175\1\255\12\0\16\255\8\20\1\0\26\23\1\255\12\0\16\255\8\21\1\0\26\24\1\255\12\0\16\255\8\175\1\22\1\0\24\23\1\177\1\255\12\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\255 \173\1\20\1\21\1\175\1\255\12\0\16\255 \20\1\0\2\23\1\255\12\0\16\255\8\173\1\20\1\0\12\21\1\175\1\255\8\0\4\255\12\0\16\255\8\20\1\0\14\23\1\255\8\0\4\255\12\0\16\255\8\21\1\0\14\24\1\255\8\0\4\255\12\0\16\255\8\175\1\22\1\0\12\23\1\177\1\255\8\0\4\255\12\0\16\255 \0\4\255\12\0\16\255 \0\4\255\12\0\16\255 \0\4\255\12\0\16\255 \0\4\255\12\0\16\255\26\173\1\21\2\171\1\255\2\0\4\255\2\171\1\21\2\175\1\255\6\0\16\255\26\21\1\0\2\4\1\168\1\255\1\0\4\255\1\168\1\4\1\0\2\23\1\255\6\0\16\255\26\22\1\0\3\4\1\168\1\0\4\168\1\4\1\0\3\24\1\255\6\0\16\255\26\171\1\4\1\0\3\4\1\0\4\4\1\0\3\4\1\172\1\255\6\0\16\255\8\173\1\20\1\0\n\21\1\175\1\255\5\168\1\4\1\0\n\4\1\168\1\255\7\0\16\255\8\20\1\0\12\23\1\255\6\168\1\4\1\0\8\4\1\168\1\255\8\0\16\255\8\21\1\0\12\24\1\255\7\168\1\4\1\0\6\4\1\168\1\255\t\0\16\255\8\175\1\22\1\0\n\23\1\177\1\255\8\168\1\4\1\0\4\4\1\168\1\255\n\0\16\255\31\171\1\4\1\0\2\3\1\164\1\255\11\0\16\255 \172\1\23\2\172\1\255\12\0\16\2550\0\16\2550\0\16\2550\0\16\2550\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	r5.speaker = {
		w = 64,
		h = 64,
		data = "\0\255\0\165\\\1\234\1\233\1O\1\0:\6\1\149\1\255\3\230\1\0009\29\1\199\1\255\5\0008?\1\231\1\255\6\0006\1\1o\1\251\1\255\7\0005\14\1\172\1\255\t\0004)\1\214\1\255\n\0003[\1\244\1\255\11\0001\4\1\136\1\255\r\0000\27\1\198\1\255\14\0/?\1\231\1\255\15\0-\1\1x\1\252\1\255\16\0\15\t\1\0\28\15\1\176\1\255\18\0\r\27\1\209\1\254\1\171\1\6\1\0\26\211\1\255\19\0\r\140\1\255\3\157\1\0\11+\1\180\1\246\1\255\7\200\1\0\4\255\20\0\r\133\1\255\4\\\1\0\t+\1\241\1\255\n\0\4\255\20\0\r\18\1\217\1\255\3\238\1\23\1\0\8\180\1\255\11\0\4\255\20\0\14*\1\245\1\255\3\153\1\0\8\246\1\255\11\0\4\255\20\0\15p\1\255\3\250\1\31\1\0\7\255\12\0\4\255\20\0\0073\0014\1\0\6\4\1\216\1\255\3\139\1\0\7\255\12\0\4\255\20\0\6\139\1\255\2\149\1\0\6a\1\255\3\231\1\3\1\0\6\255\12\0\4\255\20\0\6\244\1\255\3Y\1\0\5\8\1\239\1\255\3;\1\0\6\255\12\0\4\255\20\0\6\204\1\255\3\229\1\8\1\0\5\164\1\255\3|\1\0\6\255\12\0\4\255\20\0\6+\1\246\1\255\3]\1\0\5c\1\255\3\177\1\0\6\255\12\0\4\255\20\0\7\140\1\255\3\173\1\0\0052\1\255\3\215\1\0\6\255\12\0\4\255\20\0\0071\1\255\3\226\1\0\5\17\1\255\3\240\1\0\6\255\12\0\4\255\20\0\7\6\1\255\3\252\1\0\5\1\1\254\1\255\2\254\1\0\6\255\12\0\4\255\20\0\7\6\1\255\3\251\1\0\5\1\1\254\1\255\2\254\1\0\6\255\12\0\4\255\20\0\0072\1\255\3\225\1\0\5\17\1\255\3\240\1\0\6\255\12\0\4\255\20\0\7\141\1\255\3\172\1\0\0052\1\255\3\214\1\0\6\255\12\0\4\255\20\0\6,\1\247\1\255\3\\\1\0\5d\1\255\3\176\1\0\6\255\12\0\4\255\20\0\6\208\1\255\3\227\1\7\1\0\5\166\1\255\3{\1\0\6\255\12\0\4\255\20\0\5\1\1\249\1\255\3V\1\0\5\t\1\240\1\255\0039\1\0\6\255\12\0\4\255\20\0\6\147\1\255\2\147\1\0\6c\1\255\3\230\1\2\1\0\6\255\12\0\4\255\20\0\0078\2\0\6\5\1\218\1\255\3\137\1\0\7\245\1\255\11\0\4\255\20\0\15s\1\255\3\250\1\29\1\0\7\179\1\255\11\0\4\255\20\0\14+\1\246\1\255\3\150\1\0\8)\1\240\1\255\n\0\4\255\20\0\r\18\1\218\1\255\3\236\1\21\1\0\t(\1\177\1\244\1\255\7\198\1\0\4\255\20\0\r\134\1\255\4Y\1\0\25\210\1\255\19\0\r\140\1\255\3\154\1\0\26\16\1\177\1\255\18\0\r\27\1\207\1\254\1\168\1\6\1\0\27\1\1y\1\252\1\255\16\0\15\7\1\0\31?\1\231\1\255\15\0000\27\1\198\1\255\14\0001\4\1\136\1\255\r\0003[\1\244\1\255\11\0004)\1\214\1\255\n\0005\14\1\172\1\255\t\0006\1\1o\1\251\1\255\7\0008?\1\231\1\255\6\0009\29\1\200\1\255\5\0:\6\1\150\1\255\3\228\1\0<]\1\232\1\231\1L\1\0\255\0\153",
	}

	r5.stack = {
		w = 64,
		h = 64,
		data = "\0\255\0\30\4\1o\1\234\1\235\1q\1\5\1\0009B\1\210\1\255\4\217\1K\1\0006\29\1\162\1\255\8\187\1)\1\0002\n\1\128\1\247\1\255\n\250\1\145\1\14\1\0/M\1\224\1\255\14\230\1f\1\2\1\0+1\1\194\1\255\18\202\0019\1\0(\18\1\145\1\252\1\255\20\254\1\162\1\23\1\0$\4\1f\1\235\1\255\24\243\1\128\1\7\1\0!B\1\210\1\255\28\217\1K\1\0\30\29\1\162\1\255 \187\1)\1\0\26\n\1\128\1\247\1\255\"\250\1\145\1\14\1\0\23M\1\224\1\255&\230\1f\1\2\1\0\0191\1\194\1\255*\202\0019\1\0\16\18\1\145\1\252\1\255,\254\1\162\1\23\1\0\rP\1\239\1\2550\240\1Q\1\0\12\232\1\2552\233\1\0\12\231\1\2552\232\1\0\12N\1\239\1\2550\240\1O\1\0\r\18\1\145\1\252\1\255,\254\1\162\1\23\1\0\0161\1\194\1\255*\202\0018\1\0\20M\1\224\1\255&\229\1f\1\2\1\0\22\n\1\128\1\247\1\255\"\250\1\145\1\14\1\0\26\29\1\162\1\255 \187\1)\1\0\30A\1\210\1\255\28\217\1J\1\0!\4\1f\1\235\1\255\24\243\1\128\1\7\1\0$\18\1\145\1\252\1\255\20\254\1\162\1\23\1\0\0255\1\211\1\224\1o\1\4\1\0\n1\1\194\1\255\18\202\0018\1\0\n\4\1o\1\235\1\238\1X\1\0\12\202\1\255\3\213\1D\1\0\11M\1\224\1\255\14\229\1f\1\2\1\0\nD\1\213\1\255\3\239\1\1\1\0\11\211\1\255\5\175\1\"\1\0\n\n\1\128\1\247\1\255\n\250\1\145\1\14\1\0\n\"\1\175\1\255\5\237\1\1\1\0\11G\1\239\1\255\5\247\1\132\1\11\1\0\n\29\1\162\1\255\8\187\1)\1\0\n\11\1\132\1\247\1\255\5\240\1Q\1\0\r\18\1\145\1\252\1\255\5\229\1^\1\1\1\0\nA\1\210\1\255\4\217\1J\1\0\11M\1\224\1\255\5\254\1\162\1\23\1\0\0161\1\194\1\255\6\202\0018\1\0\n\4\1o\1\231\1\232\1q\1\5\1\0\n1\1\194\1\255\6\202\0018\1\0\20M\1\224\1\255\5\253\1\162\1\23\1\0\22\18\1\145\1\252\1\255\5\229\1f\1\2\1\0\22\n\1\128\1\247\1\255\5\239\1w\1\6\1\0\18\4\1f\1\235\1\255\5\250\1\145\1\14\1\0\26\29\1\162\1\255\6\217\1J\1\0\16B\1\211\1\255\6\187\1)\1\0\30A\1\210\1\255\6\179\1\"\1\0\12\29\1\162\1\255\6\217\1J\1\0!\4\1f\1\235\1\255\5\249\1\145\1\r\1\0\8\n\1\128\1\247\1\255\5\243\1\128\1\7\1\0$\18\1\145\1\252\1\255\5\229\1^\1\1\1\0\5M\1\224\1\255\5\254\1\162\1\23\1\0\0255\1\211\1\224\1o\1\4\1\0\n1\1\194\1\255\6\202\0018\1\0\0021\1\194\1\255\6\202\0018\1\0\n\4\1o\1\235\1\238\1X\1\0\12\202\1\255\3\213\1D\1\0\n\1\1Z\1\227\1\255\5\253\1\154\2\253\1\255\5\229\1\\\1\1\1\0\nD\1\213\1\255\3\239\1\1\1\0\11\211\1\255\5\175\1\"\1\0\n\n\1\128\1\247\1\255\n\250\1\145\1\14\1\0\n\"\1\175\1\255\5\237\1\1\1\0\11G\1\239\1\255\5\247\1\132\1\11\1\0\n\29\1\162\1\255\8\187\1)\1\0\n\11\1\132\1\247\1\255\5\240\1Q\1\0\r\18\1\145\1\252\1\255\5\229\1^\1\1\1\0\nA\1\210\1\255\4\217\1J\1\0\11M\1\224\1\255\5\254\1\162\1\23\1\0\0161\1\194\1\255\6\202\0018\1\0\n\4\1o\1\231\1\232\1q\1\5\1\0\n1\1\194\1\255\6\202\0018\1\0\20M\1\224\1\255\5\253\1\162\1\23\1\0\22\18\1\145\1\252\1\255\5\229\1f\1\2\1\0\22\n\1\128\1\247\1\255\5\239\1w\1\6\1\0\18\4\1f\1\235\1\255\5\250\1\145\1\14\1\0\26\29\1\162\1\255\6\217\1J\1\0\16B\1\211\1\255\6\187\1)\1\0\30A\1\210\1\255\6\179\1\"\1\0\12\29\1\162\1\255\6\217\1J\1\0!\4\1f\1\235\1\255\5\249\1\145\1\r\1\0\8\n\1\128\1\247\1\255\5\243\1\128\1\7\1\0$\18\1\145\1\252\1\255\5\229\1^\1\1\1\0\5M\1\224\1\255\5\254\1\162\1\23\1\0(1\1\194\1\255\6\202\0018\1\0\0021\1\194\1\255\6\202\0018\1\0+\1\1Z\1\227\1\255\5\253\1\154\2\253\1\255\5\229\1\\\1\1\1\0.\n\1\128\1\247\1\255\n\250\1\145\1\14\1\0002\29\1\162\1\255\8\187\1)\1\0006A\1\210\1\255\4\217\1J\1\0009\4\1o\1\231\1\232\1q\1\5\1\0\255\0\30",
	}

	r5.star = {
		w = 64,
		h = 64,
		data = "\0\255\0\30.\1\180\1\245\1\244\1\177\1+\1\00093\1\244\1\255\4\242\1/\1\0008\196\1\255\6\192\1\0007/\1\255\8-\1\0006\154\1\255\8\149\1\0005\15\1\244\1\255\8\243\1\14\1\0004n\1\255\nj\1\0004\212\1\255\n\213\1\1\1\0002B\1\255\12=\1\0002\171\1\255\12\166\1\0001\25\1\250\1\255\12\249\1\23\1\0000\127\1\255\14z\1\0/\4\1\227\1\255\14\225\1\3\1\0.S\1\255\16N\1\0.\188\1\255\16\183\1\0-$\1\254\1\255\16\254\1%\1\0$\11\1\31\0015\1J\1^\1q\1\134\1\156\1\206\1\255\18\205\1\156\1\133\1q\1]\1I\0015\1\30\1\n\1\0\20.\1v\1\143\1\163\1\183\1\205\1\226\1\246\1\255$\245\1\225\1\204\1\183\1\163\1\143\1u\1+\1\0\n\1\1\141\1\254\1\2552\254\1\137\1\0\tf\1\2556b\1\0\8\211\1\2556\209\1\0\8\250\1\2556\245\1\0\8\224\1\2556\220\1\0\8\130\1\2556}\1\0\8\7\1\187\1\2554\187\1\6\1\0\t\4\1\152\1\2552\169\1\8\1\0\12o\1\253\1\255.\254\1\136\1\1\1\0\14U\1\247\1\255,\249\1^\1\0\0179\1\234\1\255*\238\1@\1\0\19#\1\216\1\255(\222\1)\1\0\21\18\1\193\1\255&\200\1\23\1\0\23\7\1\165\1\255$\173\1\n\1\0\25\1\1\128\1\255\"\145\1\2\1\0\28b\1\250\1\255\30\252\1k\1\0\31s\1\255\30w\1\0 \144\1\255\30\147\1\0 \205\1\255\30\207\1\0\31\12\1\251\1\255\30\253\1\16\1\0\30G\1\255 I\1\0\30\131\1\255 \133\1\0\30\192\1\255 \193\1\0\29\5\1\245\1\255 \248\1\7\1\0\0289\1\255\":\1\0\28v\1\255\"w\1\0\28\179\1\255\"\179\1\0\27\2\1\237\1\255\16\225\2\255\16\237\1\2\1\0\26,\1\255\15\251\1\145\1\r\1\n\1\128\1\249\1\255\15,\1\0\26i\1\255\14\196\1-\1\0\4'\1\189\1\255\14h\1\0\26\165\1\255\12\236\1c\1\1\1\0\6\1\1c\1\236\1\255\12\165\1\0\26\214\1\255\n\254\1\158\1\20\1\0\n\20\1\159\1\254\1\255\n\211\1\0\26\207\1\255\t\211\1=\1\0\14=\1\212\1\255\t\203\1\0\26\132\1\255\7\244\1v\1\5\1\0\16\5\1w\1\245\1\255\7\130\1\0\26\15\1\214\1\255\5\177\1\31\1\0\20 \1\178\1\255\5\213\1\14\1\0\27\18\1\149\1\230\1\248\1\196\1M\1\0\24O\1\198\1\249\1\232\1\149\1\19\1\0\255\0\143",
	}

	local r2 = 13218299140 + 32768

	r5.steps = {
		w = 64,
		h = 64,
		data = "\0\255\0\16\1\1]\1\196\1\249\1\248\1\194\1X\1\1\1\0007\17\1\186\1\255\6\181\1\15\1\0005\15\1\207\1\255\8\202\1\12\1\0003\1\1\183\1\255\n\173\1\0003m\1\255\12d\1\0001\24\1\242\1\255\12\237\1\19\1\0000\150\1\255\14\141\1\0\14\1\1\\\1\196\1\249\1\248\1\194\1Y\1\1\1\0\25\25\1\247\1\255\14\246\1\21\1\0\12\16\1\185\1\255\6\183\1\16\1\0\24\130\1\255\16{\1\0\11\14\1\206\1\255\8\204\1\14\1\0\22\3\1\229\1\255\16\222\1\1\1\0\t\1\1\180\1\255\n\178\1\1\1\0\21D\1\255\18<\1\0\tj\1\255\12j\1\0\21\150\1\255\18\141\1\0\8\23\1\240\1\255\12\240\1\22\1\0\20\224\1\255\18\214\1\0\8\147\1\255\14\146\1\0\19 \1\255\20\25\1\0\6\24\1\247\1\255\14\247\1\24\1\0\18Z\1\255\20P\1\0\6\128\1\255\16\128\1\0\18\138\1\255\20\129\1\0\5\2\1\227\1\255\16\227\1\2\1\0\17\178\1\255\20\170\1\0\5B\1\255\18A\1\0\17\211\1\255\20\202\1\0\5\148\1\255\18\147\1\0\17\233\1\255\20\226\1\0\5\222\1\255\18\220\1\0\17\248\1\255\20\241\1\0\4\30\1\255\20\30\1\0\16\255\21\247\1\0\4X\1\255\20V\1\0\16\253\1\255\20\244\1\0\4\136\1\255\20\135\1\0\16\241\1\255\20\230\1\0\4\176\1\255\20\176\1\0\16\216\1\255\20\206\1\0\4\209\1\255\20\208\1\0\16\180\1\255\20\171\1\0\4\231\1\255\20\232\1\0\16\131\1\255\20z\1\0\4\246\1\255\20\248\1\0\16C\1\255\20:\1\0\4\254\1\255\20\254\1\0\16\5\1\235\1\255\18\229\1\2\1\0\4\252\1\255\20\251\1\0\17\139\1\255\18\129\1\0\5\239\1\255\20\237\1\0\17\24\1\243\1\255\16\239\1\19\1\0\5\214\1\255\20\214\1\0\18n\1\255\16g\1\0\6\179\1\255\20\179\1\0\18\1\1\143\1\245\1\255\12\244\1\138\1\0\7\129\1\255\20\130\1\0*A\1\255\20B\1\0*\4\1\234\1\255\18\235\1\5\1\0+\137\1\255\18\138\1\0,\23\1\242\1\255\16\243\1\25\1\0\19R\1\235\1\255\14\234\1P\1\0\8l\1\255\16p\1\0\20\235\1\255\16\232\1\0\8\1\1\144\1\247\1\255\12\248\1\147\1\1\1\0\20\255\18\0.\255\18\0.\255\18\0.\251\1\255\16\249\1\0.\223\1\255\16\220\1\0\8R\1\235\1\255\14\235\1S\1\0\20\165\1\255\16\160\1\0\8\235\1\255\16\235\1\0\20J\1\255\16G\1\0\8\255\18\4\1\0\19\1\1\201\1\255\14\197\1\1\1\0\8\255\18\4\1\0\20*\1\242\1\255\12\241\1(\1\0\t\255\18\4\1\0\21A\1\242\1\255\n\241\1@\1\0\n\251\1\255\16\252\1\1\1\0\22)\1\199\1\255\8\197\1(\1\0\11\223\1\255\16\224\1\0\24\1\1H\1\161\1\221\1\250\2\220\1\160\1G\1\1\1\0\12\165\1\255\16\165\1\0.K\1\255\16K\1\0.\1\1\202\1\255\14\200\1\1\1\0/+\1\243\1\255\12\242\1*\1\0001B\1\243\1\255\n\242\1B\1\0003*\1\201\1\255\8\200\1*\1\0005\1\1J\1\163\1\223\1\251\1\252\1\223\1\163\1J\1\1\1\0\255\0\15",
	}

	r5.sun = {
		w = 64,
		h = 64,
		data = "\0\158R\1\235\1\234\1P\1\0<\235\1\255\2\232\1\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0(R\1\234\2T\1\0\16\234\1\255\2\231\1\0\16T\1\234\2P\1\0\20\234\1\255\2\251\1W\1\0\15P\1\233\1\232\1N\1\0\15W\1\251\1\255\2\232\1\0\20\233\1\255\3\251\1W\1\0 W\1\251\1\255\3\231\1\0\20T\1\251\1\255\3\251\1W\1\0\30W\1\251\1\255\3\251\1S\1\0\21W\1\251\1\255\3\251\1S\1\0\28U\1\251\1\255\3\251\1W\1\0\23W\1\251\1\255\3\232\1\0\28\235\1\255\3\251\1W\1\0\25W\1\251\1\255\2\231\1\0\8\16\1Z\1\157\1\205\1\238\1\255\2\237\1\205\1\156\1Y\1\15\1\0\8\234\1\255\2\251\1W\1\0\27S\1\232\2N\1\0\6'\1\158\1\247\1\255\n\246\1\156\1%\1\0\6P\1\233\1\232\1S\1\0$\n\1\142\1\251\1\255\14\250\1\139\1\t\1\0+%\1\213\1\255\18\210\1#\1\0)2\1\235\1\255\20\233\0010\1\0'%\1\235\1\255\22\234\1#\1\0%\n\1\213\1\255\24\210\1\t\1\0$\142\1\255\26\138\1\0#'\1\251\1\255\26\250\1$\1\0\"\159\1\255\28\155\1\0!\15\1\246\1\255\28\245\1\r\1\0 [\1\255\30W\1\0 \157\1\255\30\153\1\0 \205\1\255\30\202\1\0\18R\1\235\1\255\6\234\1P\1\0\4\238\1\255\30\234\1\0\4R\1\235\1\255\6\234\1P\1\0\4\235\1\255\8\232\1\0\4\253\1\255\30\251\1\0\4\235\1\255\8\232\1\0\4\234\1\255\8\231\1\0\4\253\1\255\30\251\1\0\4\234\1\255\8\231\1\0\4P\1\233\1\255\6\232\1N\1\0\4\238\1\255\30\235\1\0\4P\1\233\1\255\6\232\1N\1\0\18\205\1\255\30\202\1\0 \156\1\255\30\154\1\0 Z\1\255\30W\1\0 \15\1\246\1\255\28\245\1\r\1\0!\157\1\255\28\155\1\0\"%\1\250\1\255\26\249\1$\1\0#\140\1\255\26\137\1\0$\t\1\211\1\255\24\209\1\8\1\0%$\1\234\1\255\22\233\1#\1\0'1\1\234\1\255\20\233\0010\1\0)$\1\211\1\255\18\209\1#\1\0+\t\1\139\1\250\1\255\14\250\1\137\1\8\1\0$T\1\234\2P\1\0\6%\1\156\1\246\1\255\n\245\1\155\1$\1\0\6R\1\234\2T\1\0\27W\1\251\1\255\2\232\1\0\8\14\1X\1\154\1\203\1\234\1\254\2\233\1\203\1\153\1W\1\r\1\0\8\234\1\255\2\251\1W\1\0\25W\1\251\1\255\3\231\1\0\28\233\1\255\3\251\1W\1\0\23W\1\251\1\255\3\251\1S\1\0\28T\1\251\1\255\3\251\1W\1\0\21U\1\251\1\255\3\251\1W\1\0\30W\1\251\1\255\3\251\1S\1\0\20\234\1\255\3\251\1W\1\0 W\1\251\1\255\3\232\1\0\20\233\1\255\2\251\1W\1\0\15R\1\235\1\234\1P\1\0\15W\1\251\1\255\2\231\1\0\20P\1\232\2S\1\0\16\235\1\255\2\232\1\0\16S\1\232\2N\1\0(\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\234\1\255\2\231\1\0<P\1\233\1\232\1N\1\0\158",
	}

	r5.swatches = {
		w = 64,
		h = 64,
		data = "\0\255\0\16\t\1\136\1\231\1\253\1\219\1\172\1\127\1R\1$\1\2\1\0005\2\1\187\1\255\8\244\1\201\1\154\1m\1A\1\18\1\0000V\1\255\15\228\1\183\1\137\1C\1\0,\155\1\255\19\169\1\4\1\0*\199\1\255\20z\1\0)\1\1\243\1\255\20\222\1\0)!\1\255\21\251\1\0)N\1\255\21\223\1\0){\1\255\21\178\1\0)\168\1\255\21\133\1\0)\212\1\255\21Y\1\0(\6\1\249\1\255\21,\1\0(.\1\255\21\250\1\6\1\0([\1\255\21\210\1\0)\135\1\255\21\165\1\0)\180\1\255\21x\1\0)\225\1\255\21L\1\0(\r\1\254\1\255\21\31\1\0(:\1\255\21\241\1\1\1\0\12\2\1@\1\157\1\234\1\251\1\198\1F\1\0\21g\1\255\21\197\1\0\11+\1\135\1\226\1\255\5\253\1T\1\0\20\147\1\255\21\152\1\0\8\24\1q\1\205\1\255\t\230\1\5\1\0\19\192\1\255\21l\1\0\5\8\1U\1\179\1\250\1\255\12M\1\0\19\236\1\255\21?\1\0\2\2\1<\1\153\1\242\1\255\8\246\1\170\1M\1\154\1\255\3\170\1\0\18\26\1\255\22\19\1+\1\128\1\223\1\255\8\253\1\187\1^\1\12\1\0\0029\1\255\3\247\1\16\1\0\17F\1\255\21\250\1\209\1\255\t\205\1p\1\24\1\0\6\217\1\255\3f\1\0\17s\1\255\29\228\1\145\0010\1\0\t}\1\255\3\195\1\0\17\160\1\255\26\241\1\162\1M\1\3\1\0\11\31\1\254\1\255\2\254\1#\1\0\16\204\1\255\23\252\1\187\1^\1\11\1\0\15\193\1\255\3~\1\0\15\3\1\245\1\255\21\203\1m\1\21\1\0\18c\1\255\3\219\1\1\1\0\14&\1\255\21\252\1\t\1\0\20\14\1\246\1\255\0039\1\0\14S\1\255\21\216\1\0\22\168\1\255\3\150\1\0\14\128\1\255\21\172\1\0\22K\1\255\3\238\1\7\1\0\r\172\1\255\21\127\1\0\22\4\1\231\1\255\3R\1\0\r\216\1\255\21S\1\0\23\143\1\255\3\175\1\0\12\t\1\252\1\255\21&\1\0\0231\1\255\3\241\1\0\0122\1\255\21\246\1\3\1\0\21\17\1f\1\196\1\254\1\255\3\0\12_\1\255\21\204\1\0\19\8\1M\1\170\1\250\1\255\6\0\12\139\1\255\7\212\1K\1\8\1\t\1M\1\214\1\255\8\159\1\0\16\2\1@\1\157\1\240\1\255\t\0\12\184\1\255\6\212\1\15\1\0\4\15\1\215\1\255\7s\1\0\14*\1\134\1\225\1\255\12\0\12\227\1\255\6K\1\0\6O\1\255\7F\1\0\11\23\1p\1\204\1\255\t\210\1u\1\255\4\0\12\251\1\255\6\t\1\0\6\12\1\255\7\26\1\0\8\n\1Z\1\181\1\251\1\255\8\229\1\139\1.\1\0\2\255\4\0\12\252\1\255\6\t\1\0\6\12\1\255\6\236\1\0\6\2\1C\1\160\1\242\1\255\8\243\1\162\1E\1\3\1\0\4\255\4\0\12\231\1\255\6M\1\0\6P\1\255\6\191\1\0\4,\1\137\1\227\1\255\8\252\1\183\1\\\1\11\1\0\7\255\4\0\12\184\1\255\6\214\1\15\1\0\4\16\1\216\1\255\6\140\1\0\1\25\1r\1\207\1\255\t\206\1q\1\25\1\0\n\255\4\0\12p\1\255\7\215\1O\1\11\1\12\1P\1\216\1\255\7\154\1\184\1\252\1\255\8\226\1\136\1+\1\0\r\255\4\0\12\22\1\246\1\255\27\241\1\158\1A\1\2\1\0\15\255\4\0\r\138\1\255\24\251\1\180\1X\1\t\1\0\18\255\4\0\r\11\1\216\1\255\21\203\1n\1\22\1\0\21\255\4\0\14&\1\232\1\255/\243\1\0\15%\1\215\1\255.\175\1\0\16\n\1\136\1\246\1\255+\239\1'\1\0\18\20\1m\1\180\1\227\1\251\1\255%\243\1\175\1'\1\0\255\0\255\0\7",
	}

	r5.target = {
		w = 64,
		h = 64,
		data = "\0\255\0\153\1\0011\1m\1\158\1\198\1\229\1\250\1\255\2\248\1\229\1\199\1\157\1k\1.\1\1\1\0\14V\1\236\1\235\1Q\1\0\28;\1\152\1\232\1\255\14\229\1\147\0016\1\0\11Y\1\252\1\255\2\233\1\0\25\2\1X\1\207\1\255\20\203\1S\1\1\1\0\7Y\1\252\1\255\3\231\1\0\24A\1\208\1\255\24\204\1;\1\0\5Y\1\252\1\255\3\251\1R\1\0\22\r\1\158\1\255\7\249\1\189\1\128\1Q\1+\1\21\1\8\1\3\1\19\1)\1N\1|\1\183\1\245\1\255\6\254\1\150\1\11\1\0\2X\1\252\1\255\3\251\1V\1\0\22/\1\219\1\255\6\191\1\\\1\r\1\0\12\t\1U\1\184\1\254\1\255\5\214\1)\1X\1\252\1\255\3\251\1V\1\0\22K\1\243\1\255\5\182\0012\1\0\18-\1\173\1\255\5\241\1\252\1\255\3\251\1V\1\0\22T\1\250\1\255\4\225\1J\1\0\22B\1\219\1\255\7\251\1V\1\0\22J\1\250\1\255\4\175\1\16\1\0\24\12\1\162\1\255\5\251\1V\1\0\22.\1\243\1\255\4\133\1\1\1\0\26W\1\254\1\255\3\251\1V\1\0\22\14\1\220\1\255\4v\1\0\27W\1\251\1\255\3\251\1V\1\0\23\159\1\255\4\134\1\0\27V\1\251\1\255\3\251\1V\1\0\23C\1\254\1\255\3\177\1\1\1\0\n\2\1>\1\138\1\194\1\230\1\251\2\231\1\195\1\140\1A\1\2\1\0\4V\1\251\1\255\3\251\1V\1\0\23\3\1\211\1\255\3\228\1\18\1\0\t\3\1a\1\218\1\255\n\221\1e\1\4\1\0\1V\1\251\1\255\3\251\1V\1\0\4\16\1Q\1(\1\0\17\\\1\255\4Q\1\0\t&\1\201\1\255\14\205\1s\1\251\1\255\3\251\1V\1\0\4\16\1\224\1\255\1\251\1F\1\0\16\210\1\255\3\187\1\0\tF\1\241\1\255\20\251\1V\1\0\5P\1\255\3\200\1\0\15>\1\255\4:\1\0\8D\1\248\1\255\20\251\1V\1\0\6%\1\253\1\255\0034\1\0\14\154\1\255\3\198\1\0\8%\1\240\1\255\20\251\1V\1\0\8\180\1\255\3\146\1\0\r\3\1\234\1\255\3c\1\0\7\2\1\199\1\255\20\251\1V\1\0\tQ\1\255\3\227\1\1\1\0\0126\1\255\3\251\1\18\1\0\7`\1\255\20\251\1V\1\0\n\8\1\243\1\255\3-\1\0\12s\1\255\3\196\1\0\7\1\1\216\1\255\19\251\1V\1\0\12\178\1\255\3i\1\0\12\165\1\255\3\136\1\0\7<\1\255\19\251\1V\1\0\rv\1\255\3\155\1\0\12\205\1\255\3X\1\0\7\137\1\255\18\251\1V\1\0\14G\1\255\3\195\1\0\12\234\1\255\0034\1\0\7\193\1\255\17\251\1V\1\0\4\"\1\155\1\152\1\29\1\0\7$\1\255\3\224\1\0\11\2\1\253\1\255\3\30\1\0\7\229\1\255\16\251\1V\1\0\5\210\1\255\2\200\1\0\7\12\1\255\3\245\1\0\11\t\1\255\4\18\1\0\7\246\1\255\15\251\1V\1\0\5\3\1\255\3\253\1\0\7\1\1\255\3\254\1\0\11\t\1\255\4\17\1\0\7\247\1\255\14\251\1V\1\0\6\5\1\255\3\252\1\0\7\1\1\255\3\254\1\0\11\1\1\253\1\255\3\30\1\0\7\230\1\255\r\251\1V\1\0\7\31\1\255\3\233\1\0\7\14\1\255\3\246\1\0\12\234\1\255\0036\1\0\7\193\1\255\12\251\1V\1\0\8T\1\255\3\195\1\0\7&\1\255\3\226\1\0\12\205\1\255\3Y\1\0\7\137\1\255\11\251\1V\1\0\t\165\1\255\3\140\1\0\7I\1\255\3\196\1\0\12\165\1\255\3\136\1\0\7>\1\255\n\251\1V\1\0\t\28\1\248\1\255\3>\1\0\7w\1\255\3\157\1\0\12s\1\255\3\196\1\0\7\1\1\218\1\255\8\251\1V\1\0\n\170\1\255\3\218\1\1\1\0\7\179\1\255\3k\1\0\0127\1\255\3\251\1\17\1\0\7b\1\255\7\251\1V\1\0\nl\1\255\4b\1\0\7\8\1\243\1\255\3.\1\0\12\3\1\236\1\255\3c\1\0\7\3\1\203\1\255\5\251\1V\1\0\nl\1\253\1\255\3\203\1\3\1\0\7T\1\255\3\229\1\1\1\0\r\157\1\255\3\199\1\0\8(\1\242\1\255\4\203\1\27\1\0\8\28\1\169\1\255\4\242\1(\1\0\8\182\1\255\3\147\1\0\14>\1\255\4;\1\0\8I\1\249\1\255\4\248\1\164\1T\1 \1\5\1\6\1 \1T\1\165\1\248\1\255\4\249\1H\1\0\8+\1\254\1\255\0035\1\0\14\1\1\212\1\255\3\189\1\0\tI\1\242\1\255\16\242\1I\1\0\t\173\1\255\3\203\1\0\16^\1\255\4R\1\0\t(\1\202\1\255\14\202\1(\1\0\t@\1\254\1\255\3T\1\0\16\3\1\213\1\255\3\230\1\19\1\0\t\3\1b\1\218\1\255\n\219\1b\1\3\1\0\t\12\1\220\1\255\3\205\1\2\1\0\17F\1\255\4\180\1\2\1\0\n\2\1>\1\138\1\194\1\230\1\251\2\231\1\194\1\138\1>\1\2\1\0\11\165\1\255\3\254\1=\1\0\19\162\1\255\4\138\1\0 {\1\255\4\151\1\0\20\16\1\222\1\255\4z\1\0\30j\1\254\1\255\3\215\1\11\1\0\0211\1\244\1\255\4\137\1\2\1\0\27{\1\254\1\255\3\240\1)\1\0\23M\1\251\1\255\4\178\1\18\1\0\24\r\1\167\1\255\4\249\1D\1\0\25W\1\251\1\255\4\229\1P\1\0\22D\1\222\1\255\4\249\1O\1\0\27M\1\244\1\255\5\187\0018\1\0\0180\1\178\1\255\5\241\1D\1\0\0290\1\221\1\255\6\196\1`\1\15\1\0\12\11\1Y\1\188\1\254\1\255\5\215\1*\1\0\31\15\1\161\1\255\7\249\1\192\1\131\1T\0010\1\24\1\17\2\21\1,\1Q\1\127\1\187\1\247\1\255\6\254\1\153\1\12\1\0\"D\1\212\1\255\24\207\1@\1\0%\3\1]\1\211\1\255\20\206\1V\1\2\1\0(\1\1>\1\156\1\235\1\255\14\233\1\151\1:\1\0.\3\0016\1q\1\164\1\204\1\231\1\253\1\255\2\253\1\231\1\202\1\161\1o\0013\1\2\1\0007\3\1\1\1\0\255\0`",
	}

	r5.timer = {
		w = 64,
		h = 64,
		data = "\0\152R\1\235\1\255\12\234\1P\1\0000\235\1\255\14\232\1\0000\234\1\255\14\231\1\0000P\1\233\1\255\12\232\1N\1\0\255\0002\29\1^\1\148\1\190\1\223\1\243\1\255\2\243\1\221\1\189\1\145\1\\\1\26\1\0/\20\1s\1\206\1\255\r\254\1\202\1o\1\18\1\0*\28\1\150\1\247\1\255\18\245\1\146\1\25\1\0&\6\1\127\1\246\1\255\22\244\1y\1\5\1\0#+\1\210\1\255\26\206\1(\1\0!U\1\244\1\255\28\242\1O\1\0\31n\1\253\1\255\30\253\1h\1\0\29n\1\255!\254\1h\1\0\27U\1\253\1\255\"\253\1O\1\0\25,\1\244\1\255$\242\1(\1\0\23\6\1\210\1\255&\205\1\5\1\0\22\127\1\255(w\1\0\21\28\1\246\1\255\28\171\1\21\2\175\1\255\8\243\1\24\1\0\20\151\1\255\28\168\1\4\1\0\2\23\1\255\t\144\1\0\19\20\1\246\1\255\27\168\1\4\1\0\3\24\1\255\t\244\1\17\1\0\18s\1\255\27\168\1\4\1\0\3\4\1\172\1\255\nm\1\0\18\206\1\255\26\168\1\4\1\0\3\4\1\168\1\255\11\199\1\0\17\29\1\255\26\168\1\4\1\0\3\4\1\168\1\255\12\254\1\23\1\0\16^\1\255\25\168\1\4\1\0\3\4\1\168\1\255\14X\1\0\16\148\1\255\24\168\1\4\1\0\3\4\1\168\1\255\15\143\1\0\16\191\1\255\23\168\1\4\1\0\3\4\1\168\1\255\16\186\1\0\16\223\1\255\22\168\1\4\1\0\3\4\1\168\1\255\17\219\1\0\16\244\1\255\21\170\1\4\1\0\3\4\1\168\1\255\18\240\1\0\16\253\1\255\21\21\1\0\3\4\1\168\1\255\19\251\1\0\16\253\1\255\21\22\1\0\2\4\1\168\1\255\20\252\1\0\16\244\1\255\21\175\1\23\2\172\1\255\21\240\1\0\16\222\1\255.\219\1\0\16\190\1\255.\186\1\0\16\147\1\255.\144\1\0\16]\1\255.Y\1\0\16\28\1\254\1\255,\254\1\24\1\0\17\204\1\255,\200\1\0\18q\1\255,n\1\0\18\19\1\246\1\255*\244\1\18\1\0\19\148\1\255*\144\1\0\20\27\1\245\1\255(\243\1\25\1\0\21|\1\255(w\1\0\22\6\1\208\1\255&\206\1\5\1\0\23*\1\244\1\255$\242\1(\1\0\25S\1\253\1\255\"\253\1P\1\0\27l\1\255\"j\1\0\29k\1\253\1\255\30\253\1j\1\0\31R\1\243\1\255\28\242\1P\1\0!)\1\208\1\255\26\206\1(\1\0#\5\1z\1\244\1\255\22\243\1w\1\5\1\0&\26\1\146\1\245\1\255\18\244\1\144\1\24\1\0*\18\1o\1\202\1\254\1\255\12\254\1\200\1n\1\18\1\0/\25\1[\1\144\1\187\1\219\1\241\1\255\2\240\1\218\1\187\1\144\1Z\1\24\1\0\255\0\154",
	}

	r5.users = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\255\0\14\n\1c\1\179\1\231\1\255\2\228\1\177\1_\1\8\1\0\22\8\1a\1\178\1\229\1\255\2\230\1\178\1b\1\n\1\0\21_\1\232\1\255\8\229\1Y\1\0\20Z\1\229\1\255\8\231\1\\\1\0\18\4\1\159\1\255\12\150\1\2\1\0\16\3\1\153\1\255\12\155\1\3\1\0\16\160\1\255\14\149\1\0\16\153\1\255\14\155\1\0\15`\1\255\16V\1\0\14Y\1\255\16\\\1\0\r\11\1\233\1\255\16\226\1\6\1\0\12\8\1\229\1\255\16\230\1\t\1\0\12c\1\255\18X\1\0\12\\\1\255\18`\1\0\12\180\1\255\18\168\1\0\12\172\1\255\18\175\1\0\12\230\1\255\18\212\1\0\12\216\1\255\18\228\1\0\11\2\1\254\1\255\17\217\1K\1\0\12M\1\218\1\255\17\252\1\0\11\2\1\253\1\255\15\245\1p\1\4\1\0\14\5\1s\1\246\1\255\15\251\1\0\12\229\1\255\14\218\1*\1\0\18,\1\219\1\255\14\225\1\0\12\176\1\255\r\204\1\19\1\0\5'\1\127\1\192\1\233\1\255\2\231\1\190\1{\1#\1\0\5\20\1\206\1\255\r\172\1\0\12^\1\255\12\217\1\19\1\0\4&\1\177\1\254\1\255\8\253\1\170\1!\1\0\4\21\1\220\1\255\12\\\1\0\12\8\1\229\1\255\n\245\1*\1\0\4e\1\246\1\255\12\243\1\\\1\0\4-\1\246\1\255\n\226\1\7\1\0\rY\1\255\ns\1\0\4\128\1\255\15\254\1t\1\0\4u\1\255\nU\1\0\15\151\1\255\8\216\1\4\1\0\3e\1\255\17\254\1Y\1\0\3\5\1\219\1\255\8\147\1\0\16J\1\244\1\255\7a\1\0\3'\1\247\1\255\18\242\1\30\1\0\3d\1\255\7\243\1H\1\0\14(\1\190\1\255\8\240\1\t\1\0\3\177\1\255\20\164\1\0\3\11\1\242\1\255\8\188\1%\1\0\11b\1\246\1\255\t\165\1\0\3'\1\254\1\255\20\252\1\29\1\0\3\168\1\255\t\245\1_\1\0\8\1\1\137\1\255\11b\1\0\3\128\1\255\22t\1\0\3f\1\255\11\131\1\0\7\135\1\255\0122\1\0\3\194\1\255\22\181\1\0\0035\1\255\12\129\1\0\5_\1\255\r\18\1\0\3\236\1\255\22\224\1\0\3\20\1\255\r[\1\0\4\233\1\255\r\2\1\0\2\3\1\254\1\255\22\245\1\0\3\4\1\255\r\230\1\0\4\234\1\255\r\2\1\0\2\3\1\254\1\255\22\244\1\0\3\3\1\255\r\231\1\0\4Q\1\232\1\255\11\205\1\1\1\0\3\236\1\255\22\223\1\0\3\2\1\207\1\255\11\231\1O\1\0\22\192\1\255\22\179\1\0(}\1\255\22r\1\0(%\1\253\1\255\20\250\1\27\1\0)\171\1\255\20\159\1\0*\"\1\244\1\255\18\240\1\27\1\0+^\1\255\17\254\1S\1\0-w\1\255\15\254\1l\1\0.\8\1\181\1\255\14\173\1\7\1\0-\\\1\227\1\255\16\225\1X\1\0*\20\1\180\1\255\20\177\1\18\1\0'(\1\223\1\255\22\220\1&\1\0%*\1\234\1\255\24\232\1(\1\0#\24\1\227\1\255\26\225\1\23\1\0!\2\1\192\1\255\28\189\1\2\1\0 o\1\255\30l\1\0 \235\1\255\30\232\1\0 \233\1\255\30\231\1\0 P\1\232\1\255\28\231\1N\1\0\255\0\255\0\18",
	}

	r5.vector = {
		w = 64,
		h = 64,
		data = "\0\255\0\29T\1\235\1\234\1T\1\0;U\1\251\1\255\2\252\1\\\1\0009U\1\251\1\255\4\252\1\\\1\0007U\1\251\1\255\6\252\1\\\1\0005U\1\251\1\255\8\252\1\\\1\0003U\1\251\1\255\n\252\1\\\1\0001U\1\251\1\255\12\252\1\\\1\0/U\1\251\1\255\14\252\1\\\1\0-U\1\251\1\255\16\251\1S\1\0,\235\1\255\18\232\1\0,\234\1\255\18\232\1\0,P\1\233\1\255\16\232\1M\1\0004\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0<\255\4\0\16S\1\235\1\234\1T\1\0(\255\4\0\16\235\1\255\2\251\1W\1\0'\255\4\0\16\255\4\252\1\\\1\0&\255\4\0\16\255\5\252\1\\\1\0%\255\4\0\16\255\6\252\1\\\1\0$\255\4\0\16\255\7\252\1\\\1\0#\255\4\0\16\255\8\252\1\\\1\0\"\255\4\0\16\255\t\252\1\\\1\0!\255\30\251\1S\1\0\31W\1\255\31\232\1\0\30W\1\251\1\255\31\231\1\0\29W\1\251\1\255\31\251\1S\1\0\28U\1\251\1\255\3\252\1[\1\0\17\255\t\252\1[\1\0\28U\1\251\1\255\3\252\1[\1\0\18\255\8\252\1[\1\0\16S\1\235\1\234\1T\1\0\8W\1\251\1\255\3\251\1W\1\0\19\255\7\251\1W\1\0\17\235\1\255\2\251\1W\1\0\6W\1\251\1\255\3\251\1W\1\0\20\255\6\251\1W\1\0\18\255\4\252\1\\\1\0\4U\1\251\1\255\3\252\1[\1\0\21\255\5\252\1[\1\0\19\255\5\252\1\\\1\0\2U\1\251\1\255\3\252\1[\1\0\22\255\4\252\1[\1\0\20\255\6\251\1W\2\251\1\255\3\251\1W\1\0\23\234\1\255\2\251\1W\1\0\21\255\7\251\2\255\3\251\1W\1\0\24O\1\233\1\232\1S\1\0\22\255\11\252\1[\1\0003\255\n\252\1[\1\0004\255\n\252\1\\\1\0004\255\11\252\1\\\1\0003\255\12\252\1\\\1\0002\255\r\252\1\\\1\0001\255\14\251\1S\1\0000\255\15\232\1\0000\234\1\255\14\232\1\0000P\1\233\1\255\12\232\1M\1\0\255\0\255\0\168",
	}

	r5.verified = {
		w = 64,
		h = 64,
		data = "\0\255\0\29\5\1h\1\200\1\249\2\199\1g\1\5\1\0007)\1\209\1\255\6\208\1'\1\0005A\1\240\1\255\8\239\1?\1\0003K\1\247\1\255\n\246\1K\1\0001\\\1\250\1\255\12\250\1[\1\0.\25\1\148\1\254\1\255\14\254\1\146\1\24\1\0$7\1~\1\168\1\190\1\204\2\214\1\230\1\255\20\230\1\213\1\204\2\190\1\168\1}\0016\1\0\26&\1\197\1\255$\195\1%\1\0\23&\1\235\1\255&\234\1%\1\0\22\197\1\255(\193\1\0\0217\1\255*3\1\0\20}\1\255*{\1\0\20\168\1\255*\165\1\0\20\190\1\255*\188\1\0\20\200\1\255*\199\1\0\20\206\1\255*\205\1\0\20\213\1\255*\210\1\0\20\231\1\255*\227\1\0\19\25\1\254\1\255*\254\1\23\1\0\18\148\1\255,\145\1\0\17\\\1\254\1\255\30\171\1\21\2\175\1\255\n\254\1Z\1\0\15K\1\250\1\255\30\168\1\4\1\0\2\23\1\255\11\249\1K\1\0\rA\1\247\1\255\30\168\1\4\1\0\3\24\1\255\12\246\1?\1\0\11)\1\240\1\255\30\168\1\4\1\0\3\4\1\172\1\255\r\239\1&\1\0\t\5\1\209\1\255\30\168\1\4\1\0\3\4\1\168\1\255\15\207\1\4\1\0\8i\1\255\30\168\1\4\1\0\3\4\1\168\1\255\17d\1\0\8\200\1\255\29\168\1\4\1\0\3\4\1\168\1\255\18\197\1\0\8\248\1\255\28\168\1\4\1\0\3\4\1\168\1\255\19\246\1\0\8\248\1\255\15\173\1\21\2\171\1\255\8\168\1\4\1\0\3\4\1\168\1\255\20\246\1\0\8\200\1\255\15\21\1\0\2\4\1\168\1\255\6\168\1\4\1\0\3\4\1\168\1\255\21\196\1\0\8g\1\255\15\22\1\0\3\4\1\168\1\255\4\168\1\4\1\0\3\4\1\168\1\255\22b\1\0\8\5\1\208\1\255\14\171\1\4\1\0\3\4\1\168\1\255\2\168\1\4\1\0\3\4\1\168\1\255\22\206\1\4\1\0\t'\1\239\1\255\14\168\1\4\1\0\3\4\1\168\2\4\1\0\3\4\1\168\1\255\22\238\1%\1\0\11?\1\246\1\255\14\168\1\4\1\0\3\4\2\0\3\4\1\168\1\255\22\246\1>\1\0\rK\1\250\1\255\14\168\1\4\1\0\6\4\1\168\1\255\22\249\1J\1\0\15[\1\254\1\255\14\168\1\4\1\0\4\4\1\168\1\255\22\254\1Y\1\0\17\146\1\255\15\168\1\4\1\0\2\4\1\168\1\255\23\143\1\0\18\24\1\254\1\255\15\172\1\23\2\172\1\255\23\254\1\22\1\0\19\231\1\255*\227\1\0\20\213\1\255*\210\1\0\20\206\1\255*\205\1\0\20\200\1\255*\198\1\0\20\191\1\255*\188\1\0\20\168\1\255*\164\1\0\20}\1\255*z\1\0\0205\1\255*2\1\0\21\195\1\255(\191\1\0\22$\1\234\1\255&\234\1#\1\0\23%\1\193\1\255$\191\1#\1\0\0263\1{\1\164\1\187\1\202\1\204\1\207\1\228\1\254\1\255\18\254\1\227\1\207\1\204\1\201\1\187\1\163\1z\0011\1\0$\23\1\145\1\254\1\255\14\254\1\143\1\22\1\0.Z\1\249\1\255\12\249\1Y\1\0001J\1\246\1\255\n\246\1J\1\0003?\1\239\1\255\8\238\1=\1\0005&\1\207\1\255\6\205\1%\1\0007\4\1d\1\197\1\248\1\247\1\196\1b\1\4\1\0\255\0\29",
	}

	r5.wildcard = {
		w = 64,
		h = 64,
		data = "\0\255\0\153\1\1/\1k\1\156\1\196\1\228\1\245\1\255\2\244\1\225\1\195\1\155\1i\1,\1\0/5\1\148\1\229\1\255\14\226\1\145\0011\1\0)\1\1T\1\202\1\255\20\198\1N\1\1\1\0%<\1\205\1\255\24\200\0016\1\0\"\11\1\151\1\254\1\255\26\253\1\144\1\t\1\0\31)\1\214\1\255\30\209\1$\1\0\29C\1\241\1\255 \237\1=\1\0\27L\1\248\1\255\"\246\1G\1\0\25C\1\248\1\255\16\173\1\20\1\21\1\175\1\255\16\246\1>\1\0\23)\1\241\1\255\17\20\1\0\2\23\1\255\17\237\1$\1\0\21\11\1\214\1\255\18\0\4\255\18\209\1\8\1\0\20\151\1\255\19\0\4\255\19\143\1\0\19<\1\254\1\255\19\0\4\255\19\253\0015\1\0\17\1\1\205\1\255\20\0\4\255\20\198\1\1\1\0\16T\1\255\21\0\4\255\21L\1\0\16\202\1\255\21\0\4\255\21\196\1\0\0155\1\255\8\198\1\31\1\12\1y\1\243\1\255\t\0\4\255\t\243\1y\1\12\1 \1\200\1\255\0080\1\0\14\148\1\255\0089\1\0\3\25\1\160\1\254\1\255\7\0\4\255\7\254\1\161\1\26\1\0\3;\1\255\8\142\1\0\r\1\1\229\1\255\8:\1\0\0056\1\199\1\255\6\0\4\255\6\199\0016\1\0\5=\1\255\8\225\1\0\r/\1\255\t\200\1\27\1\0\5\1\1\\\1\228\1\255\4\0\4\255\4\228\1\\\1\1\1\0\5\27\1\202\1\255\t)\1\0\12k\1\255\n\244\1{\1\8\1\0\5\11\1\131\1\246\1\255\2\0\4\255\2\247\1\132\1\11\1\0\5\8\1{\1\244\1\255\nf\1\0\12\157\1\255\12\222\1T\1\0\6 \1\171\1\255\1\0\4\255\1\171\1 \1\0\6T\1\222\1\255\12\152\1\0\12\197\1\255\14\191\1/\1\0\6?\1\0\4?\1\0\6/\1\191\1\255\14\192\1\0\12\226\1\255\15\252\1\152\1\21\1\0\14\21\1\152\1\252\1\255\15\222\1\0\12\245\1\255\17\239\1q\1\5\1\0\n\5\1q\1\239\1\255\17\242\1\0\12\254\1\255\19\216\1I\1\0\8I\1\216\1\255\19\252\1\0\12\254\1\255\19\216\1I\1\0\8I\1\216\1\255\19\252\1\0\12\245\1\255\17\239\1q\1\5\1\0\n\5\1q\1\239\1\255\17\242\1\0\12\225\1\255\15\252\1\152\1\21\1\0\14\21\1\152\1\252\1\255\15\223\1\0\12\196\1\255\14\191\1/\1\0\6?\1\0\4?\1\0\6/\1\191\1\255\14\193\1\0\12\156\1\255\12\222\1T\1\0\6 \1\171\1\255\1\0\4\255\1\171\1 \1\0\6T\1\222\1\255\12\152\1\0\12j\1\255\n\244\1{\1\8\1\0\5\11\1\131\1\246\1\255\2\0\4\255\2\246\1\131\1\11\1\0\5\8\1{\1\244\1\255\nf\1\0\12.\1\255\t\198\1\26\1\0\5\1\1\\\1\228\1\255\4\0\4\255\4\228\1\\\1\1\1\0\5\27\1\200\1\255\t)\1\0\12\1\1\228\1\255\0089\1\0\0056\1\199\1\255\6\0\4\255\6\199\0016\1\0\5<\1\255\8\225\1\0\14\147\1\255\8:\1\0\3\25\1\160\1\254\1\255\7\0\4\255\7\254\1\160\1\25\1\0\3<\1\255\8\142\1\0\0144\1\255\8\200\1\"\1\14\1y\1\243\1\255\t\0\4\255\t\243\1y\1\14\1#\1\202\1\255\0081\1\0\15\201\1\255\21\0\4\255\21\197\1\0\16R\1\255\21\0\4\255\21M\1\0\16\1\1\203\1\255\20\0\4\255\20\199\1\1\1\0\17:\1\253\1\255\19\0\4\255\19\253\0015\1\0\19\148\1\255\19\0\4\255\19\145\1\0\20\n\1\212\1\255\18\0\4\255\18\209\1\t\1\0\21'\1\239\1\255\17\21\1\0\2\24\1\255\17\238\1%\1\0\23@\1\247\1\255\16\175\1\22\1\23\1\177\1\255\16\247\1?\1\0\25K\1\248\1\255\"\247\1J\1\0\27A\1\239\1\255 \238\1?\1\0\29'\1\212\1\255\30\209\1%\1\0\31\t\1\147\1\253\1\255\26\253\1\145\1\t\1\0\"7\1\201\1\255\24\199\0015\1\0%\1\1O\1\199\1\255\20\197\1M\1\1\1\0)2\1\144\1\226\1\255\14\225\1\142\0011\1\0/*\1g\1\153\1\193\1\223\1\242\1\255\2\242\1\223\1\192\1\152\1f\1)\1\0\255\0\154",
	}

	r5.wind = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\1564\1\153\1\220\1\252\2\218\1\152\0010\1\0006\11\1\159\1\254\1\255\6\254\1\153\1\t\1\0003\11\1\198\1\255\n\191\1\8\1\0002\160\1\255\12\151\1\00015\1\254\1\255\12\253\1.\1\0000\156\1\255\14\147\1\0000\221\1\255\14\213\1\0000\185\1\255\14\245\1\0006\23\1\178\1\255\7\245\1\0\n4\1\154\1\221\1\253\1\251\1\219\1\153\0012\1\0%\23\1\255\7\213\1\0\8\n\1\157\1\254\1\255\6\254\1\155\1\n\1\0#\23\1\255\7\146\1\0\7\n\1\196\1\255\n\194\1\t\1\0!\23\1\176\1\255\6\253\1-\1\0\7\158\1\255\12\154\1\0\tO\1\233\1\255\30\149\1\0\0073\1\254\1\255\12\254\0010\1\0\8\234\1\255\30\188\1\8\1\0\7\154\1\255\14\150\1\0\8\235\1\255\28\253\1\150\1\8\1\0\8\219\1\255\14\216\1\0\8Q\1\232\1\255\24\249\1\214\1\147\1-\1\0\n\182\1\255\14\249\1\0006\23\1\177\1\255\7\248\1\0007\23\1\255\7\215\1\0007\22\1\255\7\149\1\0006\23\1\175\1\255\6\253\1.\1\0\nO\1\233\1\2552\152\1\0\11\234\1\2552\192\1\8\1\0\11\235\1\2550\253\1\149\1\8\1\0\12Q\1\232\1\255,\249\1\216\1\149\1.\1\0\255\0\17O\1\233\1\255\28\251\1\219\1\152\0011\1\0\30\234\1\255 \254\1\153\1\t\1\0\28\235\1\255\"\192\1\8\1\0\27Q\1\232\1\255\"\151\1\0007\23\1\178\1\255\6\253\1.\1\0007\24\1\255\7\147\1\0007\24\1\255\7\213\1\0006\24\1\177\1\255\7\245\1\0000\186\1\255\14\245\1\0000\220\1\255\14\213\1\0000\155\1\255\14\146\1\00003\1\254\1\255\12\253\1-\1\0001\156\1\255\12\148\1\0002\n\1\194\1\255\n\189\1\8\1\0003\n\1\155\1\254\1\255\6\253\1\149\1\8\1\00061\1\151\1\216\1\249\1\248\1\214\1\148\1-\1\0\255\0\255\0\152",
	}

	r5.badRing = {
		w = 64,
		h = 64,
		data = "\0\255\0[\23\1C\1j\1\137\1\153\1\165\2\153\1\137\1j\1C\1\23\1\0000\2\1E\1\150\1\215\1\255\12\214\1\149\1C\1\2\1\0*\21\1\130\1\227\1\255\18\226\1\129\1\20\1\0&\17\1\142\1\244\1\255\22\244\1\140\1\16\1\0\"\1\1_\1\233\1\255\26\232\1]\1\0 \16\1\174\1\255\11\247\1\210\1\187\1\176\2\187\1\211\1\247\1\255\11\172\1\15\1\0\29+\1\222\1\255\8\248\1\174\1g\1'\1\2\1\0\6\2\1'\1h\1\175\1\249\1\255\8\221\1)\1\0\27:\1\237\1\255\7\226\1p\1\18\1\0\14\18\1q\1\227\1\255\7\236\0018\1\0\25:\1\245\1\255\6\240\1o\1\6\1\0\18\6\1q\1\241\1\255\6\244\0018\1\0\23+\1\237\1\255\6\184\1\25\1\0\22\26\1\186\1\255\6\236\1)\1\0\21\16\1\222\1\255\5\254\1}\1\2\1\0\24\2\1\128\1\254\1\255\5\220\1\15\1\0\19\1\1\174\1\255\5\252\1a\1\0\28c\1\252\1\255\5\170\1\0\19_\1\255\5\254\1a\1\0\30c\1\254\1\255\5[\1\0\17\17\1\233\1\255\5}\1\0\r9\1U\0049\1\0\r\129\1\255\5\231\1\15\1\0\16\142\1\255\5\184\1\2\1\0\r\170\1\255\4\170\1\0\r\2\1\187\1\255\5\138\1\0\15\21\1\244\1\255\4\241\1\25\1\0\14\170\1\255\4\170\1\0\14\27\1\242\1\255\4\243\1\19\1\0\14\130\1\255\5o\1\0\15\170\1\255\4\170\1\0\15r\1\255\5\128\1\0\r\2\1\226\1\255\4\227\1\6\1\0\15\170\1\255\4\170\1\0\15\7\1\228\1\255\4\225\1\2\1\0\12E\1\255\5o\1\0\16\170\1\255\4\170\1\0\16r\1\255\5A\1\0\12\150\1\255\4\248\1\18\1\0\16\170\1\255\4\170\1\0\16\19\1\249\1\255\4\146\1\0\12\215\1\255\4\174\1\0\17\170\1\255\4\170\1\0\17\177\1\255\4\212\1\0\11\24\1\255\5g\1\0\17\170\1\255\4\170\1\0\17i\1\255\4\254\1\22\1\0\nC\1\255\5'\1\0\17\170\1\255\4\170\1\0\17)\1\255\5A\1\0\nk\1\255\4\246\1\2\1\0\17\170\1\255\4\170\1\0\17\3\1\247\1\255\4h\1\0\n\138\1\255\4\210\1\0\18\170\1\255\4\170\1\0\18\212\1\255\4\137\1\0\n\152\1\255\4\188\1\0\18\170\1\255\4\170\1\0\18\191\1\255\4\150\1\0\n\164\1\255\4\176\1\0\18\170\1\255\4\170\1\0\18\177\1\255\4\163\1\0\n\164\1\255\4\176\1\0\18\170\1\255\4\170\1\0\18\177\1\255\4\163\1\0\n\152\1\255\4\188\1\0\18\170\1\255\4\170\1\0\18\191\1\255\4\150\1\0\n\138\1\255\4\210\1\0\18r\1\170\4r\1\0\18\212\1\255\4\136\1\0\nk\1\255\4\247\1\3\1\0(\3\1\247\1\255\4h\1\0\nC\1\255\5'\1\0(*\1\255\5A\1\0\n\23\1\254\1\255\4h\1\0(j\1\255\4\254\1\21\1\0\11\214\1\255\4\175\1\0(\178\1\255\4\211\1\0\12\149\1\255\4\249\1\18\1\0&\20\1\249\1\255\4\145\1\0\12C\1\255\5p\1\0\16\170\1\255\4\170\1\0\16s\1\255\5@\1\0\12\2\1\226\1\255\4\227\1\7\1\0\15\170\1\255\4\170\1\0\15\7\1\228\1\255\4\225\1\2\1\0\r\129\1\255\5q\1\0\15\170\1\255\4\170\1\0\15u\1\255\5\127\1\0\14\20\1\244\1\255\4\241\1\26\1\0\14\170\1\255\4\170\1\0\14\28\1\243\1\255\4\242\1\18\1\0\15\140\1\255\5\186\1\2\1\0\r\170\1\255\4\170\1\0\r\3\1\189\1\255\5\136\1\0\16\16\1\232\1\255\5\128\1\0\r9\1U\0049\1\0\r\131\1\255\5\230\1\14\1\0\17]\1\255\5\254\1c\1\0\30e\1\255\6Y\1\0\19\171\1\255\5\252\1c\1\0\28e\1\252\1\255\5\168\1\0\20\15\1\221\1\255\5\254\1\129\1\2\1\0\24\3\1\131\1\255\6\218\1\14\1\0\21)\1\236\1\255\6\187\1\27\1\0\22\28\1\189\1\255\6\235\1'\1\0\0238\1\244\1\255\6\242\1s\1\7\1\0\18\8\1u\1\243\1\255\6\243\0017\1\0\0258\1\236\1\255\7\228\1r\1\19\1\0\14\20\1s\1\229\1\255\7\235\0017\1\0\27)\1\220\1\255\8\249\1\177\1j\1)\1\3\1\0\6\3\1)\1j\1\178\1\249\1\255\8\218\1'\1\0\29\15\1\170\1\255\11\248\1\213\1\189\1\177\2\189\1\213\1\248\1\255\11\168\1\14\1\0 [\1\231\1\255\26\230\1Y\1\0#\15\1\138\1\243\1\255\22\242\1\136\1\14\1\0&\19\1\128\1\225\1\255\18\225\1\127\1\18\1\0*\2\1A\1\146\1\212\1\255\11\254\1\212\1\145\1?\1\2\1\0000\21\1B\1h\1\134\1\152\1\164\2\152\1\134\1h\1A\1\21\1\0\255\0[",
	}

	r5.chevron = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\255\0\255\0\255\0W\1\1\0\26\1\1\0#\t\1\186\1h\1\0\24a\1\191\1\12\1\0!\t\1\187\1\255\1\254\1h\1\0\22a\1\253\1\255\1\193\1\12\1\0\31\t\1\187\1\255\3\254\1h\1\0\20a\1\253\1\255\3\193\1\12\1\0\30\174\1\255\5\253\1b\1\0\18b\1\253\1\255\5\174\1\0\0303\1\238\1\255\5\254\1h\1\0\16a\1\253\1\255\5\241\0018\1\0\0313\1\238\1\255\5\254\1h\1\0\14a\1\253\1\255\5\241\0018\1\0!3\1\238\1\255\5\254\1h\1\0\12a\1\253\1\255\5\241\0018\1\0#3\1\238\1\255\5\254\1h\1\0\na\1\253\1\255\5\241\0018\1\0%3\1\238\1\255\5\254\1h\1\0\8a\1\253\1\255\5\241\0018\1\0'3\1\238\1\255\5\254\1h\1\0\6a\1\253\1\255\5\241\0018\1\0)3\1\238\1\255\5\254\1h\1\0\4a\1\253\1\255\5\241\0018\1\0+3\1\238\1\255\5\254\1h\1\0\2a\1\253\1\255\5\241\0018\1\0-3\1\238\1\255\5\254\1h\1a\1\253\1\255\5\241\0018\1\0/9\1\241\1\255\5\253\2\255\5\241\0019\1\00013\1\238\1\255\n\241\0018\1\00033\1\238\1\255\8\241\0018\1\00053\1\238\1\255\6\241\0018\1\00073\1\238\1\255\4\241\0018\1\00093\1\238\1\255\2\241\0018\1\0;3\1\238\1\241\0018\1\0=9\2\0\255\0\255\0\255\0\255\0\255\0d",
	}

	r5.close = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\255\0\212\3\1\158\1N\1\0\24H\1\162\1\4\1\0!\3\1\163\1\255\1\249\1N\1\0\22H\1\247\1\255\1\170\1\4\1\0\31\3\1\164\1\255\3\249\1N\1\0\20H\1\247\1\255\3\170\1\4\1\0\30\161\1\255\5\248\1K\1\0\18K\1\248\1\255\5\160\1\0\30H\1\247\1\255\5\249\1N\1\0\16H\1\247\1\255\5\249\1N\1\0\31H\1\247\1\255\5\249\1N\1\0\14H\1\247\1\255\5\249\1N\1\0!H\1\247\1\255\5\249\1N\1\0\12H\1\247\1\255\5\249\1N\1\0#H\1\247\1\255\5\249\1N\1\0\nH\1\247\1\255\5\249\1N\1\0%H\1\247\1\255\5\249\1N\1\0\8H\1\247\1\255\5\249\1N\1\0'H\1\247\1\255\5\249\1N\1\0\6H\1\247\1\255\5\249\1N\1\0)H\1\247\1\255\5\249\1N\1\0\4H\1\247\1\255\5\249\1N\1\0+H\1\247\1\255\5\249\1N\1\0\2H\1\247\1\255\5\249\1N\1\0-H\1\247\1\255\5\249\1N\1H\1\247\1\255\5\249\1N\1\0/L\1\249\1\255\5\248\2\255\5\248\1K\1\0001H\1\247\1\255\n\249\1N\1\0003H\1\247\1\255\8\249\1N\1\0005H\1\247\1\255\6\249\1N\1\0006I\1\247\1\255\6\249\1N\1\0005I\1\247\1\255\8\249\1N\1\0003I\1\247\1\255\n\249\1N\1\0001L\1\249\1\255\5\249\2\255\5\248\1K\1\0/I\1\247\1\255\5\249\1N\1H\1\247\1\255\5\249\1N\1\0-I\1\247\1\255\5\249\1N\1\0\2H\1\247\1\255\5\249\1N\1\0+I\1\247\1\255\5\249\1N\1\0\4H\1\247\1\255\5\249\1N\1\0)I\1\247\1\255\5\249\1N\1\0\6H\1\247\1\255\5\249\1N\1\0'I\1\247\1\255\5\249\1N\1\0\8H\1\247\1\255\5\249\1N\1\0%I\1\247\1\255\5\249\1N\1\0\nH\1\247\1\255\5\249\1N\1\0#I\1\247\1\255\5\249\1N\1\0\12H\1\247\1\255\5\249\1N\1\0!I\1\247\1\255\5\249\1N\1\0\14H\1\247\1\255\5\249\1N\1\0\31I\1\247\1\255\5\249\1N\1\0\16H\1\247\1\255\5\249\1N\1\0\30\161\1\255\5\249\1L\1\0\18L\1\249\1\255\5\160\1\0\30\3\1\163\1\255\3\249\1N\1\0\20H\1\247\1\255\3\170\1\4\1\0\31\3\1\163\1\255\1\249\1N\1\0\22H\1\247\1\255\1\170\1\4\1\0!\4\1\161\1L\1\0\24L\1\161\1\4\1\0\255\0\255\0\255\0\212",
	}

	r5.okRing = {
		w = 64,
		h = 64,
		data = "\0\255\0[\23\1C\1j\1\137\1\153\1\165\2\153\1\137\1j\1C\1\23\1\0000\2\1E\1\150\1\215\1\255\12\214\1\149\1C\1\2\1\0*\21\1\130\1\227\1\255\18\226\1\129\1\20\1\0&\17\1\142\1\244\1\255\22\244\1\140\1\16\1\0\"\1\1_\1\233\1\255\26\232\1]\1\0 \16\1\174\1\255\11\247\1\210\1\187\1\176\2\187\1\211\1\247\1\255\11\172\1\15\1\0\29+\1\222\1\255\8\248\1\174\1g\1'\1\2\1\0\6\2\1'\1h\1\175\1\249\1\255\8\221\1)\1\0\27:\1\237\1\255\7\226\1p\1\18\1\0\14\18\1q\1\227\1\255\7\236\0018\1\0\25:\1\245\1\255\6\240\1o\1\6\1\0\18\6\1q\1\241\1\255\6\244\0018\1\0\23+\1\237\1\255\6\184\1\25\1\0\22\26\1\186\1\255\6\236\1)\1\0\21\16\1\222\1\255\5\254\1}\1\2\1\0\24\2\1\128\1\254\1\255\5\220\1\15\1\0\19\1\1\174\1\255\5\252\1a\1\0\28c\1\252\1\255\5\170\1\0\19_\1\255\5\254\1a\1\0\30c\1\254\1\255\5[\1\0\17\17\1\233\1\255\5}\1\0 \129\1\255\5\231\1\15\1\0\16\142\1\255\5\184\1\2\1\0 \2\1\187\1\255\5\138\1\0\15\21\1\244\1\255\4\241\1\25\1\0\"\27\1\242\1\255\4\243\1\19\1\0\14\130\1\255\5o\1\0\28?\1\14\1\0\6r\1\255\5\128\1\0\r\2\1\226\1\255\4\227\1\6\1\0\27H\1\247\1\204\1\17\1\0\5\7\1\228\1\255\4\225\1\2\1\0\12E\1\255\5o\1\0\27L\1\248\1\255\2\198\1\14\1\0\5r\1\255\5A\1\0\12\150\1\255\4\248\1\18\1\0\26L\1\248\1\255\4\198\1\14\1\0\4\19\1\249\1\255\4\146\1\0\12\215\1\255\4\174\1\0\26L\1\248\1\255\5\248\1?\1\0\5\177\1\255\4\212\1\0\11\24\1\255\5g\1\0\25L\1\248\1\255\5\248\1K\1\0\6i\1\255\4\254\1\22\1\0\nC\1\255\5'\1\0\t5\1\24\1\0\rL\1\248\1\255\5\248\1K\1\0\7)\1\255\5A\1\0\nk\1\255\4\246\1\2\1\0\0089\1\241\1\217\1\26\1\0\11I\1\247\1\255\5\249\1N\1\0\8\3\1\247\1\255\4h\1\0\n\138\1\255\4\210\1\0\0089\1\241\1\255\2\215\1\24\1\0\tL\1\248\1\255\5\248\1K\1\0\n\212\1\255\4\137\1\0\n\152\1\255\4\188\1\0\0079\1\241\1\255\4\217\1\26\1\0\7I\1\247\1\255\5\249\1N\1\0\11\191\1\255\4\150\1\0\n\164\1\255\4\176\1\0\7\142\1\255\6\215\1\24\1\0\5L\1\248\1\255\5\248\1K\1\0\12\177\1\255\4\164\1\0\n\164\1\255\4\176\1\0\7\1\1\149\1\255\6\217\1\26\1\0\3I\1\247\1\255\5\249\1N\1\0\r\177\1\255\4\163\1\0\n\152\1\255\4\188\1\0\8\1\1\149\1\255\6\217\1\26\1\0\1I\1\247\1\255\5\249\1N\1\0\14\191\1\255\4\150\1\0\n\138\1\255\4\210\1\0\t\1\1\153\1\255\6\215\1b\1\249\1\255\5\248\1K\1\0\15\212\1\255\4\136\1\0\nk\1\255\4\247\1\3\1\0\t\1\1\149\1\255\12\249\1N\1\0\15\3\1\247\1\255\4h\1\0\nC\1\255\5'\1\0\n\1\1\153\1\255\n\248\1K\1\0\16*\1\255\5A\1\0\n\23\1\254\1\255\4h\1\0\11\1\1\153\1\255\8\248\1K\1\0\17j\1\255\4\254\1\21\1\0\11\214\1\255\4\175\1\0\12\1\1\153\1\255\6\248\1K\1\0\18\178\1\255\4\211\1\0\12\149\1\255\4\249\1\18\1\0\12\1\1\153\1\255\4\248\1K\1\0\18\20\1\249\1\255\4\145\1\0\12C\1\255\5p\1\0\r\1\1\153\1\255\2\248\1K\1\0\19s\1\255\5@\1\0\12\2\1\226\1\255\4\227\1\7\1\0\r\1\1\149\1\249\1N\1\0\19\7\1\228\1\255\4\225\1\2\1\0\r\129\1\255\5q\1\0\14\1\1/\1\0\20u\1\255\5\127\1\0\14\20\1\244\1\255\4\241\1\26\1\0\"\28\1\243\1\255\4\242\1\18\1\0\15\140\1\255\5\186\1\2\1\0 \3\1\189\1\255\5\136\1\0\16\16\1\232\1\255\5\128\1\0 \131\1\255\5\230\1\14\1\0\17]\1\255\5\254\1c\1\0\30e\1\255\6Y\1\0\19\171\1\255\5\252\1c\1\0\28e\1\252\1\255\5\168\1\0\20\15\1\221\1\255\5\254\1\129\1\2\1\0\24\3\1\131\1\255\6\218\1\14\1\0\21)\1\236\1\255\6\187\1\27\1\0\22\28\1\189\1\255\6\235\1'\1\0\0238\1\244\1\255\6\242\1s\1\7\1\0\18\8\1u\1\243\1\255\6\243\0017\1\0\0258\1\236\1\255\7\228\1r\1\19\1\0\14\20\1s\1\229\1\255\7\235\0017\1\0\27)\1\220\1\255\8\249\1\177\1j\1)\1\3\1\0\6\3\1)\1j\1\178\1\249\1\255\8\218\1'\1\0\29\15\1\170\1\255\11\248\1\213\1\189\1\177\2\189\1\213\1\248\1\255\11\168\1\14\1\0 [\1\231\1\255\26\230\1Y\1\0#\15\1\138\1\243\1\255\22\242\1\136\1\14\1\0&\19\1\128\1\225\1\255\18\225\1\127\1\18\1\0*\2\1A\1\146\1\212\1\255\11\254\1\212\1\145\1?\1\2\1\0000\21\1B\1h\1\134\1\152\1\164\2\152\1\134\1h\1A\1\21\1\0\255\0[",
	}

	r5.airborne = {
		w = 64,
		h = 64,
		data = "O\1\0?\174\1^\1\0>\174\1\244\1)\1\0=\173\1\255\1\208\1\8\1\0<\173\1\255\2\149\1\0<\173\1\255\3[\1\0;\172\1\255\3\247\0018\1\0:\162\1\255\4\231\1\31\1\0009}\1\255\5\219\1\24\1\0008U\1\255\6\208\1\17\1\0007/\1\255\7\209\1\25\1\0006\8\1\244\1\255\7\221\1'\1\0006\177\1\255\8\242\1X\1\0005e\1\255\n\161\1\21\1\0003\26\1\254\1\255\n\237\1g\1\4\1\0002\179\1\255\12\222\1f\1\3\1\00009\1\255\14\214\1e\1\t\1\0/\192\1\255\15\236\1\135\1!\1\0-<\1\253\1\255\16\254\1\194\1e\1\16\1\0+\142\1\255\19\248\1\186\1o\1$\1\0(\t\1\214\1\255\22\223\1\165\1n\0016\1\12\1\0\31n\1\t\1\0\0032\1\243\1\255\26\228\1\190\1\157\1\140\1{\1j\1f\1a\1U\2S\1D\3C\0013\1&\1\24\1\t\1\0\12p\1\213\1.\1\0\3B\1\247\1\255,\233\1\203\1\156\1h\1\"\1\0\7\17\1\246\1\247\1n\1\1\1\0\2P\1\251\1\2550\208\1f\1\8\1\0\5\160\1\255\2\192\0010\1\0\2N\1\241\1\2551\222\1C\1\0\0048\1\255\3\253\1\174\1=\1\1\1)\1\216\1\2551\252\1e\1\0\4\207\1\255\5\221\1\145\1b\1\210\1\2551\253\1E\1\0\3`\1\255;\224\1\4\1\0\2\2\1\197\1\255;T\1\0\3-\1\250\1\255:\151\1\0\4\127\1\255:\190\1\0\4\1\1\169\1\2559\192\1\0\5\t\1\200\1\2558\161\1\0\6\15\1\187\1\2557h\1\0\7\5\1\158\1\2555\246\1\17\1\0\t_\1\235\1\2553\137\1\0\11\20\1\159\1\253\1\2550\218\1\t\1\0\t\t\1\0\3#\1\143\1\241\1\255-\251\1=\1\0\n@\1\205\1\144\1N\1\15\1\0\1\14\1[\1\164\1\234\1\255)\254\1a\1\0\12d\1\255\2\252\1\201\1\143\1s\1k\1~\1\209\1\255(y\1\0\14\139\1\255/\137\1\0\15\2\1\177\1\255,\254\1w\1\0\17\12\1\188\1\255*\252\1c\1\0\19\4\1\139\1\254\1\255'\248\1Q\1\0\22J\1\217\1\255%\243\1A\1\0\24\5\1q\1\231\1\255\"\250\1G\1\0\27\5\1U\1\190\1\253\1\255\31]\1\0\31\20\1X\1\158\1\216\1\251\1\255\26\176\1\0$\7\1/\1X\1o\1\130\1\150\1\179\1\250\1\255\19`\1\0&\17\0010\1V\1\160\1\237\1\255\20y\1\0#\20\1\175\1\241\1\255\25\215\1\6\1\0#\n\1\138\1\251\1\255\25\134\1\0%2\1\205\1\255\24\254\1o\1\0%\3\1Q\1\190\1\254\1\255\22\254\1o\1\0'\27\1f\1\168\1\216\1\252\1\255\7\248\1\213\1\170\1\156\1\250\1\255\7\254\1G\1\0*\8\1\30\0011\1D\1B\0013\1+\1\19\1\0\4-\1\193\1\255\7\158\1\0008;\1\171\1\243\1\255\3\254\1V\1\0:\6\1?\1_\1s\1>\1\0\255\0\138",
	}

	r5.ammo = {
		w = 64,
		h = 64,
		data = "\0\r?\1\128\1\0\16\7\1\183\1\2\1\0\16\145\1.\1\0\25\162\1\231\1\1\1\0\15O\1\255\1<\1\0\15\8\1\244\1\141\1\0\25\223\1\255\1%\1\0\15\140\1\255\1x\1\0\15:\1\255\1\202\1\0\24\22\1\255\2]\1\0\15\196\1\255\1\175\1\0\15r\1\255\1\250\1\t\1\0\23P\1\255\2\148\1\0\14\5\1\246\1\255\1\233\1\0\15\169\1\255\2;\1\0\23\130\1\255\2\200\1\0\14/\1\255\3\27\1\0\14\219\1\255\2n\1\0\23\171\1\255\2\239\1\0\14X\1\255\3C\1\0\r\8\1\252\1\255\2\149\1\0\23\211\1\255\3\24\1\0\r\128\1\255\3k\1\0\r.\1\255\3\189\1\0\22\3\1\247\1\255\3@\1\0\r\168\1\255\3\147\1\0\rV\1\255\3\230\1\0\22$\1\255\4i\1\0\r\209\1\255\3\187\1\0\r~\1\255\4\16\1\0\21I\1\255\4\141\1\0\r\244\1\255\3\224\1\0\r\162\1\255\0043\1\0\21i\1\255\4\174\1\0\12\22\1\255\4\252\1\5\1\0\12\195\1\255\4T\1\0\21\137\1\255\4\207\1\0\0126\1\255\5\"\1\0\12\227\1\255\4t\1\0\21\169\1\255\4\240\1\0\12W\1\255\5C\1\0\11\6\1\253\1\255\4\149\1\0\21\172\1\221\5\r\1\0\11e\1\221\5U\1\0\11\30\1\221\5\156\1\0\147\1\1\169\1\187\7#\1\0\tm\1\187\7_\1\0\t1\1\187\7\156\1\0\18=\1\255\8\130\1\0\8\3\1\229\1\255\7\216\1\0\t\150\1\255\8)\1\0\17\157\1\255\8\227\1\3\1\0\7J\1\255\t6\1\0\7\8\1\238\1\255\8\137\1\0\16\11\1\242\1\255\tD\1\0\7\171\1\255\t\151\1\0\7X\1\255\t\232\1\4\1\0\15^\1\255\n\164\1\0\6\18\1\248\1\255\t\240\1\t\1\0\6\184\1\255\nJ\1\0\15t\1\170\n\161\1\3\1\0\5=\1\170\0111\1\0\5\t\1\167\1\170\ng\1\0\143\196\1\242\11\22\1\0\5w\1\242\11e\1\0\5(\1\242\11\178\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15h\1\128\11\12\1\0\5?\1\128\0115\1\0\5\21\1\128\11^\1\0\143\203\1\250\11\23\1\0\5{\1\250\11h\1\0\5)\1\250\11\184\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\15\208\1\255\11\24\1\0\5~\1\255\11k\1\0\5+\1\255\11\189\1\0\7",
	}

	r5.armorFull = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\235\25\1H\1\27\1\0\t/\1\177\1\171\1\135\1d\0014\1\5\1\0)\8\1S\1\154\1\223\1\255\1\219\1\229\1\137\1\21\1\0\5 \1\135\1\236\1\255\5\246\1\192\1)\1\0&8\1\215\1\255\3\233\1\31\1\17\1\138\1\237\1\153\1D\1\"\1\23\1E\1\237\1\255\5\254\1\159\1D\1\156\1\220\1\12\1\0#\11\1\129\1\251\1\255\4B\1\0\3\24\1s\1\184\1\219\1\238\1\255\6\239\1D\1\0\3\175\1\128\1\0\"\8\1\201\1\255\4\187\1k\1\169\1\0\6B\1\236\1\255\5\254\1C\1\0\0049\1\236\1\7\1\0!\152\1\255\4\196\1\4\1\0\1\155\1M\1\0\4l\1\251\1\255\6\184\1\0\5\1\1\224\1P\1\0 C\1\254\1\255\4m\1\0\2\21\1\186\1\0\2\6\1\154\1\255\8P\1\0\6\150\1\142\1\0\n!\1d\1\129\1\153\1\169\1\153\1y\1B\1\4\1\0\12\n\1\222\1\255\5K\1\0\3\170\1*\0018\1\212\1\255\8\227\1\4\1\0\6[\1\195\1\0\7\8\1o\1\213\1\255\8\232\1t\1\6\1\0\nz\1\255\6L\1\0\3\135\1\223\1\254\1\255\t\132\1\0\7-\1\221\1\0\6J\1\227\1\255\12\200\1\23\1\0\8\12\1\239\1\255\6\225\1\138\1\152\1\212\1\255\0128\1\0\7\21\1\243\1\0\5o\1\252\1\255\14\207\1\7\1\0\7h\1\255\22\235\1\2\1\0\7\17\1\250\1\0\4U\1\254\1\255\16\129\1\0\7\189\1\255\22\192\1\0\8'\1\243\1\0\3\17\1\236\1\255\17\249\1\24\1\0\5\2\1\248\1\255\22\154\1\0\8;\1\233\1\0\3x\1\255\19r\1\0\5\21\1\255\23\130\1\0\8P\1\205\1\0\3\209\1\255\19\191\1\0\5\n\1\255\23z\1\0\8v\1\174\1\0\2!\1\255\20\242\1\1\1\0\5\238\1\255\22q\1\0\8\165\1\127\1\0\2L\1\255\21\r\1\0\5\210\1\255\22i\1\0\8\211\1L\1\0\1\27\1\141\1\255\21\\\1\0\5\160\1\255\22q\1\0\7\8\1\250\1\25\1\194\1\255\23\241\1\n\1\0\4g\1\255\22\149\1\0\0075\1\230\1\0\1\22\1@\1T\1f\1\176\1\255\0207\1\0\4+\1\255\22\236\1\15\1\0\6d\1\192\1\0\5\200\1\255\20Q\1\0\5\225\1\255\22\191\1\6\1\0\5\129\1\155\1\0\5\217\1\255\20l\1\0\5\152\1\255\23\155\1\0\5\140\1\129\1\0\5\190\1\255\1\235\1\221\1\220\1\204\2\189\1\170\1\147\1{\1\204\1\255\2\181\1f\2\205\1\255\3\136\1\0\5O\1\255\24i\1\0\4u\1\141\1\0\5\150\1\255\1\132\1\0\6\20\1u\1\223\1\255\2\238\1\221\2\224\1\255\2\195\1;\1\0\5\22\1\255\24\238\1\1\1\0\2\24\1\216\1\142\1\0\5\\\1\255\1c\1\0\0063\1\255\ne\1\0\6\n\1\238\1\255\24\19\1\0\2\150\1\165\1\4\1\0\5\22\1\254\1E\1\0\6\14\1\255\nR\1\0\6\187\1\255\25\159\1\140\1\136\1\215\1\127\1\2\1\0\6\217\0018\1\0\7\234\1\255\2\131\1f\1q\1\159\1\218\1\255\1\242\1\15\1\0\6\198\1\255\29\230\1\1\1\0\6\158\0010\1\0\4*\1\145\1\223\1\255\2\250\1\29\1\0\3E\1\239\1[\1\0\7\189\1\255\29\176\1\0\7d\1G\1\0\3c\1\248\1\172\1\220\1\255\2]\1\0\3R\1\206\1\20\1\0\8\165\1\255\29{\1\0\7W\1\191\1\r\1\0\1[\1\249\1W\1\0\1\228\1\255\1\185\1\0\0026\1\176\1\235\1%\1\0\t5\1\157\1\255\28F\1\0\7\141\1\255\1\230\1\200\1\251\1Y\1\0\1\22\1\253\1\255\1\150\1x\1\213\1\255\1\237\0011\1\0\11h\1\255\24h\1P\1z\1\220\1\16\1\0\7a\1\255\12\202\1(\1\0\12q\1\255\24\23\1\0\1\134\1u\1\0\8\14\1\242\1\255\6\229\1\193\1\155\1n\1/\1\1\1\0\0125\1\249\1\255\24\17\1\2\1\227\1\128\1\0\tT\1\184\1\213\1\255\2\249\1\131\1\2\1\0\17R\1\255\25\148\1\189\1\255\1\167\1\0\n,\1\135\1\167\1\129\1\30\1\0\19E\1\255\28\131\1\0\"8\1\255\28\128\1\0\"+\1\186\1\255\27\135\1\0\"\2\1\30\1\255\27\135\1\0#)\1\255\23\239\1\142\1\213\1\255\1J\1\0#{\1\255\23\189\1\0\1\164\1\255\1f\1\0#\11\1~\1\207\1\252\1\255\20\151\1\0\1K\1\144\1\8\1\0&\8\0011\1M\1e\1{\1\136\1\149\1\159\1\170\4\186\1\187\4\198\1\184\1\165\1\134\1\19\1\0\255\0\255\0\201",
	}

	r5.back = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\255\0\2323\1\176\1\12\1\0<3\1\238\1\255\1\193\1\12\1\0:3\1\238\1\255\3\193\1\12\1\00088\1\241\1\255\5\186\1\1\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00069\1\241\1\255\5\254\1h\1\00073\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00083\1\238\1\255\5\254\1h\1\00089\1\241\1\255\5\186\1\1\1\00083\1\238\1\255\3\193\1\11\1\0:3\1\238\1\255\1\193\1\11\1\0<9\1\175\1\n\1\0\255\0\255\0\255\0\219",
	}

	r5.bullet = {
		w = 64,
		h = 64,
		data = "\0\130D\1Q\1\2\1\0=Q\1\255\1\211\0019\1\0<\2\1\211\1\255\1\253\1\147\1\r\1\0;9\1\253\1\255\2\226\1H\1\0;\147\1\255\3\254\1\145\1\7\1\0009\11\1\222\1\255\4\211\1,\1\0009H\1\254\1\255\4\243\1_\1\0009\142\1\255\6\161\1\n\1\0007\5\1\201\1\255\6\214\1)\1\0007$\1\242\1\255\6\242\1T\1\0007_\1\255\7\254\1~\1\0007\161\1\255\6\243\1<\1\0007\8\1\205\1\255\4\244\1@\1\0\2\6\1\172\1\170\0016\1\0003$\1\239\1\255\2\244\1@\1\0\2\6\1\177\1\255\3\196\1M\1\1\1\0001M\1\254\1\244\1@\1\0\2\7\1\180\1\255\6\210\1`\1\4\1\0000~\1<\1\0\2\6\1\177\1\255\8\157\1\2\1\0003\6\1\177\1\255\8\157\1\2\1\0003\6\1\177\1\255\8\157\1\2\1\0\2R\1\180\1\t\1\0/\175\1\255\8\156\1\2\1\0\2R\1\250\1\255\1\185\1\t\1\0.\162\1\255\7\157\1\2\1\0\2R\1\250\1\255\3\185\1\t\1\0--\1\254\1\255\5\157\1\2\1\0\2R\1\250\1\255\5\185\1\t\1\0-\186\1\255\4\157\1\2\1\0\2R\1\250\1\255\7\185\1\t\1\0,G\1\255\3\157\1\2\1\0\2R\1\250\1\255\t\185\1\t\1\0,\208\1\255\1\157\1\2\1\0\2R\1\250\1\255\11\185\1\t\1\0+`\1\157\1\2\1\0\2R\1\250\1\255\r\185\1\t\1\0*\4\1\2\1\0\2R\1\250\1\255\15\185\1\t\1\0,R\1\250\1\255\17\185\1\t\1\0+\179\1\255\19\183\1\8\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\6\1\179\1\255\19\185\1\t\1\0*\8\1\183\1\255\19\177\1\0+\6\1\179\1\255\17\249\1O\1\0,\6\1\179\1\255\15\249\1O\1\0\3\1\1\0*\6\1\179\1\255\r\249\1O\1\0\3a\1\183\1\t\1\0*\6\1\179\1\255\11\249\1O\1\0\3a\1\253\1\255\1\185\1\t\1\0*\6\1\179\1\255\t\249\1O\1\0\3b\1\253\1\255\3\128\1\0+\6\1\179\1\255\7\249\1O\1\0\3a\1\253\1\255\3\185\1\8\1\0,\6\1\179\1\255\5\249\1O\1\0\3a\1\253\1\255\3\185\1\8\1\0.\6\1\179\1\255\3\249\1O\1\0\3a\1\253\1\255\3\185\1\8\1\0000\6\1\179\1\255\1\249\1O\1\0\3a\1\253\1\255\3\185\1\8\1\0002\8\1\177\1N\1\0\3a\1\253\1\255\3\185\1\8\1\0008a\1\253\1\255\3\185\1\8\1\0008a\1\253\1\255\3\185\1\8\1\0008\1\1\181\1\255\3\183\1\8\1\0:\6\1\179\1\255\1\185\1\8\1\0<\8\1\128\1\8\1\0J",
	}

	r5.burning = {
		w = 64,
		h = 64,
		data = "\0\255\0\233\2\1/\1\0=>\1\215\1~\1\0<N\1\251\1\255\1@\1\0;\8\1\233\1\255\2>\1\0;>\1\255\3z\1\0$q\1\169\1W\1\7\1\0\19O\1\255\3\197\1\0$\7\1\208\1\255\1\227\1o\1\8\1\0\17=\1\255\4.\1\0$+\1\246\1\255\2\223\1R\1\0\16\16\1\255\4\152\1\0\12\16\1\0\24\134\1\255\4\151\1\3\1\0\15\227\1\255\3\244\1\14\1\0\11\151\1L\1\0\23\17\1\239\1\255\4\154\1\0\15\188\1\255\4S\1\0\11\158\1\232\1\r\1\0\23\137\1\255\5R\1\0\14\186\1\255\4\136\1\0\11\187\1\255\1j\1\0\0234\1\255\5\216\1\0\14\207\1\255\4\172\1\0\11\221\1\255\1\184\1\0\23\1\1\230\1\255\5/\1\0\12/\1\254\1\255\4\198\1\0\n\22\1\252\1\255\1\238\1\1\1\0\23\194\1\255\5f\1\0\11)\1\221\1\255\5\199\1\0\ns\1\255\3\27\1\0\23\171\1\255\5\131\1\0\t\22\1\131\1\246\1\255\6\170\1\0\t$\1\239\1\255\3\22\1\0\23\192\1\255\5\161\1\0\0075\1\159\1\247\1\255\8z\1\0\8I\1\228\1\255\3\246\1\6\1\0\22\3\1\230\1\255\5\180\1\0\4\2\1U\1\202\1\255\0113\1\0\5\1\1B\1\177\1\255\5\179\1\0\23R\1\255\6\172\1\0\3B\1\212\1\255\12\214\1\0\4\3\1Z\1\212\1\255\7G\1\0\22 \1\230\1\255\6\143\1\0\1\7\1\152\1\254\1\255\rp\1\0\3)\1\202\1\255\8\177\1\0\0225\1\221\1\255\7a\1\18\1\196\1\255\14\230\1\n\1\0\2a\1\247\1\255\8\215\1\15\1\0\20\2\1x\1\250\1\255\8/\1\197\1\255\15^\1\0\2r\1\254\1\255\8\239\1&\1\0\20\31\1\191\1\255\t\228\1\157\1\255\15\166\1\0\2N\1\254\1\255\8\252\1H\1\0\20_\1\241\1\255\n\220\1\255\15\169\1\6\1\0\1\8\1\226\1\255\tk\1\0\19\2\1\148\1\255\26\231\1\\\1\0\3Z\1\255\t\145\1\0\20\144\1\255\26\198\1\20\1\0\4\161\1\255\8\198\1\3\1\0\19Y\1\255\26\247\1\23\1\0\5\219\1\255\0081\1\0\19\16\1\231\1\255\26\221\1\0\0052\1\255\8\218\1\0\20\138\1\255\27\254\1V\1\0\3\23\1\209\1\255\8\202\1\0\19\12\1\239\1\255\28\254\1\181\1}\1\155\1\238\1\255\t\200\1\0\19i\1\255+\197\1\0\19\179\1\255+\203\1\0\19\232\1\255+\213\1\0\18\21\1\255,\223\1\0\18\27\1\255\11\184\1\172\1\255\31\232\1\0\18\29\1\255\n\149\1\0\1=\1\255\31\231\1\0\18\30\1\255\t\232\1\n\1\0\1%\1\255\31\218\1\0\18\r\1\255\t\138\1\0\2\6\1\249\1\255\30\205\1\0\19\242\1\255\8+\1\0\3\206\1\255\30\170\1\0\19\217\1\255\7\246\1\1\1\0\3\158\1\255\30\127\1\0\19\191\1\255\7\239\1\0\4i\1\255\30A\1\0\19\163\1\255\8\19\1\0\3\25\1\252\1\255\28\230\1\3\1\0\19s\1\255\8=\1\0\4\189\1\255\28u\1\0\20?\1\255\8{\1\0\4a\1\255\27\211\1\6\1\0\20\t\1\237\1\255\7\199\1\0\4\4\1\213\1\255\25\235\1\"\1\0\22\141\1\255\7\253\1\22\1\0\0046\1\245\1\255\23\242\0019\1\0\23\30\1\239\1\255\7X\1\0\5I\1\242\1\255\21\239\1<\1\0\25V\1\254\1\255\6\138\1\0\6&\1\200\1\255\19\212\1&\1\0\27T\1\242\1\255\5\129\1\0\7\1\1N\1\192\1\253\1\255\14\232\1z\1\7\1\0\29\29\1\136\1\207\1\238\1\231\1\166\1\20\1\0\n\27\1b\1\156\1\205\1\236\1\255\6\239\1\205\1\147\1O\1\6\1\0005\n\1\23\1\"\2\28\1\14\1\0\255\0\219",
	}

	r5.c4 = {
		w = 64,
		h = 64,
		data = "\0\255\0b1\1\233\1\213\1\24\1\0<\136\1\255\2\\\1\0<\142\1\255\2g\1\0/\4\1v\1f\1\0\n\148\1\255\2i\1\0\t\n\1\127\1O\1\0#b\1\255\2^\1\0\t\158\1\255\2p\1\0\t\154\1\255\1\254\0012\1\0\"J\1\255\2\235\1\19\1\0\8\162\1\255\2x\1\0\0086\1\253\1\255\0020\1\0\"\1\1\204\1\255\2\154\1\0\8\169\1\255\2\128\1\0\7\6\1\210\1\255\2\178\1\0$R\1\255\2\253\0019\1\0\7\176\1\255\2\135\1\0\7\127\1\255\2\252\1(\1\0$\1\1\209\1\255\2\206\1\3\1\0\6\191\1\255\2\144\1\0\6(\1\248\1\255\2\160\1\0&K\1\255\3n\1\0\6\199\1\255\2\152\1\0\5\1\1\192\1\255\2\246\1\29\1\0=\t\1'\1\0\148\11\1@\1D\t:\0013\29/\1\t\1\0\tD\1\198\1\247\1q\1\0\7/\1\229\1\255)\236\1;\1\0\6A\1\194\1\255\3\187\1\0\7\193\1\255+\184\1\0\4=\1\191\1\255\4\245\1X\1\0\7\234\1\255\21\253\1\193\1\187\16\214\1\255\3\219\1\0\3\129\1\255\5\170\1\30\1\0\8\235\1\255\21\173\1\0\17\5\1\253\1\255\2\221\1\0\3\156\1\255\3\214\1C\1\0\n\229\1\255\21\152\1\0\18\237\1\255\2\224\1\0\3\156\1\255\1\243\1u\1\5\1\0\11\226\1\255\21\157\1\0\18\236\1\255\2\224\1\0\3\156\1\166\1\27\1\0\r\226\1\255\21\159\1\0\18\237\1\255\2\224\1\0\3\20\1\0\15\226\1\255\21\159\1\0\18\237\1\255\2\224\1\0\19\226\1\255\21\159\1\0\0029\1\178\1T\1\6\1\164\1\149\1\7\1W\1\179\1/\1\0\6\237\1\255\2\224\1\0\19\226\1\255\21\159\1\0\2>\1\201\1p\1\8\1\182\1\174\1\t\1k\1\201\1:\1\0\6\237\1\255\2\224\1\0\19\226\1\255\21\159\1\0\3\"\1\0\2\20\1\18\1\0\2#\1\0\7\237\1\255\2\224\1\0\19\226\1\255\21\159\1\0\18\237\1\255\2\224\1\0\3?\1Y\1U\1K\1D\1@\0013\2)\1\"\1\28\1\5\1\0\4\226\1\255\21\156\1\0\18\237\1\255\2\224\1\0\3\156\1\255\n\221\1\23\1\0\3\226\1\255\r\231\1\136\3\236\1\255\3\154\1\0\18\237\1\255\2\224\1\0\3\156\1\255\11Q\1\0\3\226\1\255\rV\1\0\3\214\1\255\3\195\1\6\1\0\16\16\1\246\1\255\2\224\1\0\3\156\1\251\1\237\1\221\3\211\1\204\2\191\1\187\1\135\1\8\1\0\3\226\1\255\12\183\1\0\1\23\1\0\2\214\1\255\4\247\1\238\16\249\1\255\3\224\1\0\19\226\1\255\3\253\1\165\1S\0018\0014\1n\1\255\2\248\1%\1\0\1w\1\0\2\214\1\255\3\252\1\140\1w\1z\1\225\1\235\1z\1w\1\129\1\244\1\209\1w\2\147\1\255\1\181\1w\2\183\1\255\3\224\1\0\19\226\1\255\2\249\1J\1\0\4K\1\255\2\131\1\0\1=\1\174\1\0\2\214\1\255\3\212\1\0\3\145\1\169\1\0\3\198\1p\1\0\2\1\1\253\0015\1\0\0028\1\255\3\224\1\0\19\226\1\255\2\135\1\0\2C\1\186\1\195\1\204\1\255\1\223\1\n\1\4\1\213\1\174\1\0\2\214\1\255\3\213\1\0\3\143\1\170\1\0\3\195\1p\1\0\3\250\1.\1\0\0027\1\255\3\224\1\0\19\226\1\255\2%\1\0\1\23\1\243\1\255\4L\1\0\1c\1\255\1\174\1\0\2\214\1\255\3\233\1\11\1\0\2\174\1\195\1\4\1\0\1\5\1\220\1\142\1\0\2\27\1\254\1N\1\0\2N\1\255\3\224\1\0\19\226\1\255\1\253\1\0\2R\1\255\4\187\1\0\0023\1D\1.\1\0\0029\1{\1\255\3\245\1\238\1\244\1\255\2\246\1\238\1\242\1\255\2\243\1\238\1\246\1\255\1\251\1\238\1\242\1\255\4\224\1\0\3N\1\19\1\0\14\226\1\255\2\12\1\0\1,\1\254\1\255\3\166\1\0\8J\1\255\2\253\1\151\1|\1\134\1\231\1\240\1\134\1w\1\146\1\247\1\218\1\136\2\164\1\255\1\192\1\136\2\192\1\255\3\224\1\0\3\156\1\235\1b\1\1\1\0\12\226\1\255\2J\1\0\2d\1\223\1\237\1\222\1\234\1\187\4\129\1\0\2\158\1\210\1\255\2\211\1\0\3\149\1\171\1\0\3\197\1q\1\0\2\3\1\252\1:\1\0\0028\1\255\3\224\1\0\3\156\1\255\2\195\1,\1\0\11\226\1\255\2\201\1\8\1\0\4F\1\255\5\176\1\0\2\215\1\255\3\210\1\0\3\145\1\170\1\0\3\193\1j\1\0\3\252\0016\1\0\0026\1\255\3\224\1\0\3\156\1\255\3\250\1\138\1\11\1\0\t\226\1\255\3\200\1A\1\5\1\0\1\4\1S\1\255\5\187\1\"\2\220\1\255\3\226\1\11\1\0\2\166\1\194\1\1\1\0\1\3\1\215\1\140\1\0\2\16\1\254\1Q\1\0\2M\1\255\3\223\1\0\0031\1\191\1\255\4\225\1T\1\0\8\219\1\255\5\249\1\238\1\248\1\255\14\244\1\238\1\236\1\255\2\240\1\230\1\237\1\255\2\237\1\234\1\253\1\255\1\250\1\238\1\223\1\250\1\255\3\208\1\0\5L\1\213\1\255\4}\1\0\7u\1\255+\129\1\0\6\3\1e\1\231\1\255\2\185\1\0\8c\1\173\1\187&\173\1\170\1n\1\2\1\0\8\r\1\130\1\178\1I\1\0ۂ\1\204\2\202\1%\1\0\6\152\1\204\2z\1\0\6X\1\204\1\205\1\238\1R\1\0%\24\1\248\1\255\2\162\1\0\7\183\1\255\2\145\1\0\6\t\1\214\1\255\2\211\1\2\1\0$\132\1\255\2\241\1\27\1\0\7\174\1\255\2\137\1\0\7=\1\254\1\255\2X\1\0#\r\1\237\1\255\2n\1\0\8\167\1\255\2\129\1\0\8\162\1\255\2\215\1\3\1\0\"i\1\255\2\204\1\3\1\0\8\160\1\255\2y\1\0\8\23\1\239\1\255\2D\1\0\"J\1\254\1\246\1.\1\0\t\155\1\255\2p\1\0\tc\1\255\1\244\1\"\1\0#6\1+\1\0\n\145\1\255\2i\1\0\n<\1&\1\0000\139\1\255\2i\1\0<{\1\255\2V\1\0<\20\1\172\1\153\1\5\1\0\255\0\28",
	}

	r5.carrier = {
		w = 64,
		h = 64,
		data = "\0\22!\1\148\1\222\1\252\1\229\1\178\1e\1\23\1\0\7\t\1\n\1\0.O\1\250\1\174\1G\1'\1R\1\144\1\223\1\252\1\184\1[\1\n\1\0\2\1\1\156\1\253\1\255\1\197\1+\1\0\3?\1\199\1\203\1n\1\0$\19\1\241\1e\1\0\0068\1\154\1\240\1\243\1\169\1Z\1_\1\241\1-\1!\1\156\1\237\0016\1\0\1\16\1\237\1p\1.\1\201\1z\1\0\27\26\1l\1\136\1f\1\8\1\0\3u\1\200\1\0\t\7\1L\1\153\1\218\1\255\1\247\1\199\1\178\1\157\1\230\1\242\1U\1w\1\230\1\1\1\0\1\23\1\232\1#\1\0\25B\1\231\1x\1_\1\194\1\193\1\1\1\0\2\191\1\136\1\0\12\12\1\246\1~\1J\1^\1t\1\141\1\186\1\255\2\238\1\128\0016\1\2\1\143\1\149\1\0\25\205\1X\1\0\2\n\1\236\1J\1\0\1\8\1\247\1t\1\0\12\\\1\255\1!\1\0\4\1\1\151\1\255\1\240\1\129\1\198\1\230\1\190\1\236\1\6\1\0\24\238\1\26\1\4\1<\1D\1\176\1\197\1D\1_\1\255\1\131\1D\3B\1\11\1%\1D\6\172\1\244\1D\0029\1\0\2\11\1E\1\213\1\255\1^\1U\1f\1\201\1\255\1\137\0014\1\6\1\0\22\232\1\"\1q\1\255\12\185\1\250\1\255\11r\1V\1\235\1\255\n\229\0013\1\0\21\213\1;\1\134\1\255\25\245\1\248\1\255\12k\1\0\0180\1\170\2\235\1\195\1\215\1\255'a\1\0\18u\1\255,V\1\0\18\167\1\255\r\251\1\192\1\187\22\193\1\253\1\255\5L\1\0\18\202\1\255\r\145\1\0\24\153\1\255\5B\1\0\18\236\1\255\r~\1\0\24\132\1\255\0058\1\0\18\249\1\255\r~\1\0\24\132\1\255\5.\1\0\18\240\1\255\r~\1\0\24\132\1\255\5$\1\0\18\230\1\255\r~\1\0\24\132\1\255\5\26\1\0\18\210\1\255\r~\1\0\24\132\1\255\5\16\1\0\18\186\1\255\r\147\1\0\24\155\1\255\5\6\1\0\18k\1\255\r\253\1\195\1\187\22\197\1\254\1\255\4\251\1\0\0196\1\255+\242\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\0196\1\255+\241\1\0\23*\1\255\n\253\1\223\1\221\15\226\1\255\11\241\1\0\23*\1\255\ny\1\0\17\158\1\255\n\241\1\0\23*\1\255\nX\1\0\17|\1\255\n\241\1\0\23*\1\255\nX\1\0\2\167\1\204\2\5\1\0\1\202\1\204\1\174\1\0\2\179\1\204\1\196\1\0\2|\1\255\n\241\1\0\23*\1\255\nX\1\0\2\208\1\255\2\6\1\0\1\252\1\255\1\217\1\0\2\224\1\255\1\245\1\0\2|\1\255\n\241\1\0\22\3\1\162\1\255\nX\1\0\2\167\1\204\2\5\1\0\1\202\1\204\1\174\1\0\2\179\1\204\1\196\1\0\2|\1\255\n\241\1\0\21\1\1\161\1\255\11X\1\0\17|\1\255\n\241\1\0\21z\1\255\12X\1\0\0028\1D\2\2\1\0\1C\1D\1:\1\0\2<\1D\1A\1\0\2|\1\255\n\241\1\0\21\226\1\255\1\230\1\255\nX\1\0\2\208\1\255\2\6\1\0\1\252\1\255\1\217\1\0\2\224\1\255\1\245\1\0\2|\1\255\n\247\1\18\1\0\20\177\1\212\1:\1\255\nX\1\0\2\208\1\255\2\6\1\0\1\252\1\255\1\217\1\0\2\224\1\255\1\245\1\0\2|\1\255\11\199\1\8\1\0\19m\1g\1*\1\255\nX\1\0\2E\1U\2\2\1\0\1T\1U\1H\1\0\2K\1U\1R\1\0\2|\1\255\n\250\1\253\1v\1\0\19&\1\203\0014\1\255\nX\1\0\17|\1\255\n\213\1D\1\231\1\t\1\0\19\160\1\211\1\255\nX\1\0\2\194\1\238\2\6\1\0\1\235\1\238\1\203\1\0\2\209\1\238\1\229\1\0\2|\1\255\n\199\1\0\1t\1[\1\0\19\n\1\209\1\255\nX\1\0\2\208\1\255\2\6\1\0\1\252\1\255\1\217\1\0\2\224\1\255\1\245\1\0\2|\1\255\n\185\1\0\1\5\1\171\1\0\0209\1\255\nX\1\0\2\139\1\170\2\4\1\0\1\168\1\170\1\145\1\0\2\149\1\170\1\163\1\0\2|\1\255\n\171\1\0\2\196\1\0\20*\1\255\nX\1\0\17|\1\255\n\157\1\0\1\t\1\219\1\0\20*\1\255\nX\1\0\2S\1f\2\2\1\0\1e\1f\1W\1\0\2Z\1f\1b\1\0\2|\1\255\n\143\1\0\1|\1\145\1\0\20*\1\255\nX\1\0\2\208\1\255\2\6\1\0\1\252\1\255\1\217\1\0\2\224\1\255\1\245\1\0\2|\1\255\n\161\1\137\1\187\1\16\1\0\20*\1\255\nX\1\0\2\208\1\255\2\6\1\0\1\252\1\255\1\217\1\0\2\224\1\255\1\245\1\0\2|\1\255\n\251\1\131\1\5\1\0\21*\1\255\nX\1\0\2*\0013\2\1\1\0\0012\0013\1+\1\0\2-\0013\0011\1\0\2|\1\255\n{\1\0\23*\1\255\nl\1\0\17\145\1\255\nr\1\0\0233\1\255\n\246\1\190\1\187\15\193\1\252\1\255\nr\1\0\23E\1\255'r\1\0\23W\1\255'r\1\0\23i\1\255'r\1\0\23z\1\255'r\1\0\23\139\1\255'r\1\0\23\157\1\255'r\1\0\23\178\1\255's\1\0\23\207\1\255'r\1\0\23\221\1\255'r\1\0\23\150\1\253\1\255\11\226\1\254\1\255\11\210\1\188\1\255\12S\1\0\24\n\1#\1;\1V\1p\1\141\1\166\1\195\1\215\1\233\1\248\1\227\1#\1\25\1\"\11\16\1\26\1\179\1\235\1\238\8\234\1\162\1\4\1\0\11",
	}

	r5.defuser = {
		w = 64,
		h = 64,
		data = "\0\198\30\1q\1\15\1\0=$\1\247\1\225\1@\1\0=i\1\255\1\254\1\145\1\7\1\0<\163\1\255\2\212\0010\1\0;\12\1\214\1\255\2\248\1w\1\2\1\0:,\1\245\1\255\3\197\1\"\1\0:b\1\255\4\240\1f\1\0:\160\1\255\5\167\1&\1\0-U\1j\1\16\1\0\8\n\1\211\1\255\5\233\1\24\1\0,\204\1\255\1\247\1\165\1D\1\2\1\0\6)\1\243\1\255\5\184\1\1\1\0+\23\1\196\1\255\3\223\1\127\1\31\1\0\5[\1\255\6q\1\0,\7\1\156\1\255\4\253\1\187\1Z\1\8\1\0\3\148\1\228\1\232\1\255\3\248\0010\1\0-n\1\251\1\255\5\239\1\149\0014\1\0\3t\1\255\4\216\1\20\1\0-C\1\236\1\255\7L\1\0\1'\1\242\1\255\5\214\1t\1&\1\0,#\1\212\1\255\6|\1\3\1\195\1\255\t\217\1\145\1Q\1\22\1\0\1\3\1\23\1,\1@\1R\1d\1u\1\134\1\136\2\148\1\153\2\143\1\136\1y\1u\1f\1G\1\22\1\0\20\r\1\176\1\255\5\249\1\233\1\255\14\240\1\255\20\211\1\127\1 \1\0\18\2\1\131\1\254\1\255*\250\1\158\1\"\1\0\18U\1\244\1\255+\250\1\145\1\14\1\0\0170\1\225\1\255,\228\1I\1\0\17\14\1f\1\196\1\254\1\255\n\243\1\255\31\254\1\153\1\r\1\0\18-\1\156\1\246\1\255\7\199\1\5\1D\1\155\1\243\1\255\4\250\1\226\1\190\1\153\1t\1N\0013\1\31\1\17\3\23\1B\1o\1\159\1\231\1\255\n\221\1>\1\0\19\18\1\207\1\255\5\236\1\18\1\0\3\15\0013\2#\1\24\1\1\1\0\14\2\0019\1\137\1\224\1\255\8\253\1\140\1\8\1\0\18'\1\243\1\255\5Y\1\0\4l\1\178\1\135\1V\1\6\1\0\17\4\1[\1\209\1\255\8\213\1,\1\0\18N\1\253\1\255\4\232\1\21\1\0\0026\1M\1^\1~\1\151\1$\1\0\19\1\1I\1\203\1\255\7\189\1\0\19\141\1\255\5\182\1\1\1\7\1~\1\234\1\200\1d\1\2\1\0\22\2\1h\1\237\1\255\5\191\1\0\19\r\1\228\1\255\5o\1\136\1\169\1\"\1+\1q\1\r\1\0\24\20\1\156\1\254\1\255\3|\1\0\20J\1\251\1\255\4\243\1Z\1F\1\208\1\133\1\0\0287\1\174\1\179\1`\1\1\1\0\21\162\1\255\5\253\1\131\1\11\0013\1\0006~\1\255\5\143\1\174\1\31\1\0007T\1\255\5\183\1\0009$\1\255\5\239\1\1\1\0008\3\1\252\1\255\5\31\1\0009\233\1\255\5B\1\0009\211\1\255\5c\1\0009\188\1\255\5\131\1\0009\162\1\255\5\163\1\0009\135\1\255\5\211\1\0009l\1\255\5\254\1\22\1\0008B\1\255\6X\1\0008\6\1\242\1\255\5\175\1\0009\173\1\255\5\249\1\18\1\0008U\1\255\6y\1\0008\5\1\230\1\255\5\232\1\8\1\0008\133\1\255\6t\1\0008\19\1\242\1\255\5\242\1\25\1\0008\135\1\255\6\172\1\0008\16\1\231\1\255\6h\1\0008X\1\255\6\247\1>\1\0008\177\1\255\6\240\0010\1\0007\r\1\213\1\255\6\238\1>\1\0007)\1\239\1\255\6\247\1X\1\00072\1\238\1\255\7\162\1\12\1\00068\1\240\1\255\7\214\1\23\1\0006*\1\220\1\255\7\158\1\0007\19\1\188\1\255\6\167\1\0008\2\1t\1\248\1\255\4]\1\0:,\1\200\1\255\2\207\1\0=E\1F\1\r\1\0\216",
	}

	r5.domination = {
		w = 64,
		h = 64,
		data = "\0\217\24\1J\1}\1\166\1\185\1\201\1\217\1\220\1\202\1\184\1\166\1\129\1L\1\22\1\0.\3\1?\1\144\1\223\1\255\14\222\1\149\1>\1\2\1\0(\20\1|\1\228\1\255\20\228\1w\1\16\1\0$\t\1{\1\243\1\255\24\242\1\134\1\12\1\0!X\1\224\1\255\28\229\1\\\1\0\30\20\1\175\1\255 \175\1\18\1\0\0272\1\228\1\255\n\253\1\202\1\153\1m\1\195\1\255\4\197\1x\1\168\1\219\1\255\11\225\0013\1\0\25M\1\244\1\255\t\189\1b\1\23\1\0\3\167\1\255\4\166\1\0\3(\1~\1\213\1\255\t\243\1H\1\0\23Q\1\250\1\255\7\254\1\169\0013\1\0\6\167\1\255\4\166\1\0\5\1\1M\1\202\1\255\8\250\1T\1\0\21F\1\250\1\255\7\216\1>\1\0\8\167\1\255\4\166\1\0\8R\1\231\1\255\7\249\1E\1\0\19+\1\240\1\255\7\148\1\7\1\0\t\167\1\255\4\166\1\0\t\19\1\166\1\255\7\244\1/\1\0\17\11\1\215\1\255\6\251\1m\1\0\11\167\1\255\4\165\1\0\11o\1\253\1\255\6\219\1\15\1\0\16\161\1\255\6\250\1N\1\0\12\167\1\255\4\165\1\0\12V\1\248\1\255\6\169\1\0\15H\1\255\6\253\1Y\1\0\r\167\1\255\4\165\1\0\rT\1\253\1\255\6O\1\0\r\t\1\222\1\255\6y\1\0\14\167\1\255\4\165\1\0\14w\1\255\6\225\1\12\1\0\12u\1\255\6\179\1\1\1\0\14\167\1\255\4\165\1\0\15\167\1\255\6z\1\0\11\14\1\236\1\255\5\235\1\19\1\0\15\166\1\255\4\164\1\0\15\21\1\235\1\255\5\236\1\r\1\0\nq\1\255\6d\1\0\16\128\1\255\4}\1\0\16\\\1\255\6s\1\0\t\2\1\220\1\255\5\204\1\2\1\0\16\19\1\219\1\255\2\217\1\18\1\0\17\205\1\255\5\214\1\0\t?\1\255\6Q\1\0\18\11\1T\1S\1\n\1\0\18Y\1\255\0069\1\0\8\143\1\255\5\214\1\2\1\0(\4\1\222\1\255\5\140\1\0\8\222\1\255\5r\1\0*\130\1\255\5\210\1\0\7'\1\255\5\253\1\28\1\0*4\1\255\5\254\1\25\1\0\6X\1\255\5\200\1\0+\1\1\230\1\255\5J\1\0\6\135\1\255\5\152\1\0,\179\1\255\5w\1\0\6\168\1\255\5n\1\0,\134\1\255\5\159\1\0\6\188\1\255\5\197\1\170\t\162\1h\1\4\1\0\20\r\1z\1\167\1\170\t\205\1\255\5\179\1\0\6\207\1\255\17\164\1\0\19\5\1\204\1\255\17\197\1\0\6\207\1\255\17\254\1\19\1\0\18>\1\255\18\209\1\0\6\203\1\255\17\254\1\19\1\0\18>\1\255\18\203\1\0\6\199\1\255\17\162\1\0\19\5\1\203\1\255\17\197\1\0\6\177\1\255\5\208\1\170\t\162\1f\1\3\1\0\20\r\1x\1\166\1\170\t\205\1\255\5\181\1\0\6\143\1\255\5\146\1\0,\138\1\255\5\148\1\0\6l\1\255\5\193\1\0,\184\1\255\5t\1\0\6@\1\255\5\247\1\n\1\0*\2\1\234\1\255\5F\1\0\6\8\1\247\1\255\5H\1\0*8\1\255\5\252\1\14\1\0\7\192\1\255\5\159\1\0*\134\1\255\5\208\1\0\8z\1\255\5\242\1\12\1\0(\4\1\224\1\255\5\129\1\0\8\31\1\253\1\255\5n\1\0\19\16\1\17\1\0\19V\1\255\6%\1\0\t\190\1\255\5\224\1\6\1\0\16\4\1\161\1\255\2\162\1\4\1\0\16\1\1\202\1\255\5\200\1\0\n[\1\255\6q\1\0\16g\1\255\4g\1\0\16\\\1\255\6g\1\0\n\4\1\219\1\255\5\238\1\24\1\0\15\159\1\255\4\161\1\0\15\15\1\231\1\255\5\225\1\7\1\0\11_\1\255\6\176\1\0\15\165\1\255\4\167\1\0\15\160\1\255\6c\1\0\12\4\1\213\1\255\6k\1\0\14\165\1\255\4\167\1\0\14e\1\255\6\217\1\4\1\0\r;\1\253\1\255\5\250\1@\1\0\r\165\1\255\4\167\1\0\rL\1\249\1\255\5\253\1@\1\0\15\147\1\255\6\241\0014\1\0\12\165\1\255\4\167\1\0\12G\1\248\1\255\6\137\1\0\16\r\1\216\1\255\6\238\1N\1\0\11\165\1\255\4\167\1\0\11j\1\249\1\255\6\207\1\6\1\0\17'\1\240\1\255\6\254\1\139\1\5\1\0\t\165\1\255\4\167\1\0\t\11\1\161\1\255\7\228\1 \1\0\19K\1\253\1\255\7\203\1?\1\0\8\165\1\255\4\167\1\0\8Q\1\225\1\255\7\238\1,\1\0\21b\1\253\1\255\8\181\1/\1\0\6\165\1\255\4\167\1\0\6I\1\195\1\255\8\244\1;\1\0\23a\1\253\1\255\t\204\1q\1\26\1\0\3\165\1\255\4\167\1\0\3#\1{\1\214\1\255\t\234\0019\1\0\25I\1\224\1\255\n\252\1\212\1\162\1q\1\193\1\255\4\197\1j\1\157\1\224\1\255\11\208\1#\1\0\27\16\1\167\1\255\31\254\1\151\1\t\1\0\30\\\1\229\1\255\28\210\1<\1\0!\n\1y\1\240\1\255\24\231\1q\1\4\1\0$\19\1v\1\216\1\255\20\213\1c\1\7\1\0);\1\150\1\215\1\255\14\206\1\130\0016\1\1\1\0.\23\1V\1\129\1\159\1\186\1\213\1\219\1\204\2\195\1\156\1u\1L\1\27\1\0\217",
	}

	r5.flashed = {
		w = 64,
		h = 64,
		data = "\0\255\0K(\1\16\1\0=(\1\231\1\206\1\18\1\0;(\1\231\1\255\2\206\1\18\1\0009(\1\231\1\255\4\206\1\18\1\0007(\1\230\1\255\6\206\1\18\1\0005*\1\233\1\255\8\203\1\17\1\0004\23\1\212\1\255\t\206\1\18\1\0004\23\1\212\1\255\t\206\1\18\1\0004\23\1\212\1\255\t\206\1\19\1\0004\23\1\212\1\255\t\206\1\19\1\0004\23\1\212\1\255\t\206\1\19\1\0004\23\1\212\1\255\t\206\1\19\1\0\2\23\1D\1o\1\148\1\161\1\175\1\187\1\178\1\167\1\153\1}\1V\0010\1\7\1\0$\23\1\212\1\255\t\206\1\19\1\0\1W\1\251\1\255\11\246\1\187\1z\1+\1\0\"\23\1\212\1\255\t\206\1\19\1\0\1X\1\252\1\255\14\205\1n\1\r\1\0 \22\1\212\1\255\t\206\1\19\1\0\1X\1\252\1\255\15\238\1\131\1\19\1\0\31\22\1\212\1\255\t\206\1\19\1\0\1U\1\251\1\255\16\238\1o\1\4\1\0\30\22\1\212\1\255\t\206\1\19\1\0\1Y\1\252\1\255\7\252\1\171\1\190\1\252\1\255\6\204\1*\1\0\26\n\1\149\1.\1\0\1\22\1\212\1\255\t\206\1\19\1\0\1Z\1\227\1\248\1\255\6\250\1T\1\24\1\130\1\235\1\255\5\246\1i\1\0\24&\1\211\1\255\1\234\1+\1\0\1\22\1\212\1\255\t\206\1\19\1\0\3!\1n\1\220\1\255\4\250\1>\1\0\1\n\1u\1\241\1\255\5\155\1\6\1\0\21<\1\237\1\255\3\231\1(\1\0\1\22\1\212\1\255\t\206\1\19\1\0\4\6\1\127\1\253\1\255\3\230\1\16\1\0\2\24\1\164\1\255\5\180\1\8\1\0\19N\1\247\1\255\4\218\0010\1\0\2\22\1\212\1\255\t\206\1\19\1\0\5Y\1\254\1\255\3\143\1\0\4W\1\239\1\255\4\184\1\t\1\0\17F\1\248\1\255\4\168\1\r\1\0\4\22\1\212\1\255\t\206\1\19\1\0\5\130\1\255\3\245\1\20\1\0\4$\1\215\1\255\4\189\1\8\1\0\15?\1\245\1\255\4\130\1\1\1\0\6\22\1\212\1\255\t\206\1\19\1\0\4\8\1\225\1\255\3h\1\0\5\17\1\194\1\255\4\163\1\0\0141\1\242\1\255\3\254\1g\1\0\6i\0010\1\0\1\22\1\212\1\255\t\206\1\19\1\0\4y\1\255\3\177\1\0\6\11\1\192\1\255\4w\1\0\12\20\1\224\1\255\4o\1\0\7\178\1\239\1;\1\0\1\22\1\212\1\255\t\207\1\19\1\0\3-\1\255\3\226\1\0\7\14\1\212\1\255\3\253\1<\1\0\n\3\1\189\1\255\4|\1\0\8\202\1\255\1\245\1H\1\0\1\22\1\212\1\255\t\207\1\19\1\0\2\t\1\255\3\251\1\1\1\0\7!\1\234\1\255\3\217\1\t\1\0\tL\1\255\4\205\1\1\1\0\8\212\1\255\2\249\1\28\1\0\1\22\1\212\1\255\t\207\1\19\1\0\2\245\1\255\3\6\1\0\8x\1\255\4g\1\0\t\2\1\182\1\255\4\142\1\0\8\199\1\255\3B\1\0\2\22\1\212\1\255\t\207\1\19\1\0\1n\1\254\1\255\1\242\1\0\0084\1\245\1\255\3\219\1\r\1\0\n\18\1\221\1\255\4\133\1\0\7\163\1\255\3r\1\0\3\22\1\212\1\255\t\207\1\19\1\0\1m\1\254\1\213\1\0\7,\1\235\1\255\3\246\1/\1\0\12&\1\232\1\255\4\154\1\5\1\0\5m\1\255\3\200\1\0\4\22\1\212\1\255\t\207\1\19\1\0\1m\1\152\1\0\6-\1\232\1\255\3\254\1^\1\0\0140\1\239\1\255\4\189\1\17\1\0\4 \1\254\1\255\3G\1\0\4\22\1\212\1\255\t\207\1\19\1\0\1\16\1\0\5E\1\241\1\255\4t\1\0\0166\1\235\1\255\4\217\1*\1\0\4\180\1\255\3\221\1\20\1\0\4\22\1\212\1\255\t\207\1\19\1\0\4\1\1p\1\250\1\255\4\127\1\0\18'\1\222\1\255\4\246\1o\1\1\1\0\0022\1\253\1\255\3\199\1\21\1\0\4\22\1\212\1\255\t\207\1\19\1\0\2\23\1\182\1\255\5\137\1\0\20\24\1\206\1\255\5\199\0014\1\0\2\141\1\255\4\224\1O\1\0\4\22\1\212\1\255\t\207\1\19\1\0\1C\1\247\1\255\3\253\1q\1\0\22\11\1\162\1\255\5\253\1\163\1*\1\5\1\189\1\255\5\210\1\127\1P\1\23\1\0\1\22\1\212\1\255\t\207\1\19\1\0\1M\1\250\1\255\1\238\1N\1\0\25`\1\240\1\255\5\253\1\176\1Z\1\192\1\255\7\226\1$\1\0\1\22\1\212\1\255\t\207\1\19\1\0\1T\1\195\1 \1\0\27\28\1\179\1\255\7\238\1\254\1\255\7\228\1'\1\0\1\22\1\212\1\255\t\207\1\19\1\0 G\1\212\1\255\15\231\1*\1\0\1\22\1\212\1\255\t\207\1\19\1\0 \2\1M\1\201\1\255\14\233\1.\1\0\1\22\1\212\1\255\t\207\1\19\1\0\"<\1\153\1\239\1\255\12\235\0010\1\0\1\22\1\212\1\255\t\207\1\19\1\0#\7\1A\1\133\1\197\1\240\1\255\t\235\1&\1\0\1\22\1\212\1\255\t\207\1\19\1\0'\27\1?\1Q\1^\1f\1c\1U\1G\1(\1\7\1\0\3\22\1\212\1\255\t\207\1\19\1\0004\22\1\212\1\255\t\207\1\19\1\0004\22\1\212\1\255\t\207\1\19\1\0004\22\1\211\1\255\t\207\1\19\1\0004\22\1\211\1\255\t\207\1\19\1\0004\24\1\214\1\255\t\203\1\4\1\0004\22\1\211\1\255\7\254\1g\1\0006\22\1\211\1\255\5\254\1g\1\0008\22\1\211\1\255\3\254\1g\1\0:\22\1\211\1\255\1\254\1h\1\0<\22\1\210\1h\1\0>\6\1\0\255\0\141",
	}

	r5.headshot = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\15\14\1;\1Z\1g\1f\1b\1H\1&\1\2\1\0004$\1\131\1\208\1\253\1\255\7\239\1\182\1k\1\27\1\0/%\1\174\1\253\1\255\r\253\1\176\1>\1\0+\2\1y\1\249\1\255\18\177\1\30\1\0(\12\1\184\1\255\21\239\1Q\1\0&\15\1\197\1\255\7\231\1\255\15\253\1m\1\0$\2\1\185\1\255\5\253\1\255\1\250\0017\1\190\1\255\16n\1\0\22D\1\23\1\0\11h\1\255\6=\1p\1l\1\0\1=\1\138\1R\1;\1\255\r\251\1A\1\0\20\26\1\240\1\217\1\2\1\0\0013\1\3\1\0\6\3\1\228\1\255\5\248\1\5\1\0\7\225\1\255\r\234\1\29\1\0\19\174\1\255\1[\1\0\1I\1\248\1\153\1\0\6I\1\255\3\180\1f\2W\1\0\8\141\1\255\14\187\1\1\1\0\17\7\1\167\1\183\1\0\1E\1\247\1\244\1>\1\0\6\170\1\255\3\191\1\0\12_\1\240\1\255\r_\1\0\19\7\1D\1\246\1\244\1?\1\0\6\1\1\238\1\255\3\251\1\18\1\0\12\29\1\186\1\255\12\220\0013\14\28\1\0\5h\1\243\1=\1\0\7#\1\255\3\251\1\146\1\12\1\0\r,\1\248\1\255\26\253\1\186\1V\1\6\1\0\3\24\1\0\8W\1\255\2\231\0013\1\0\14\27\1\226\1\255\30\234\1\141\1 \1\0\1\22\1\180\6\30\1\0\1}\1\255\3\241\1\171\1Z\1\0\12s\1\255\31\202\1Z\1\6\1\0\1 \1\255\6,\1\0\1\142\1\255\5\222\1\0\12\1\1\150\1\255\27\253\1\179\1D\1\0\5\5\6\0\2\157\1\255\5\212\1\15\1\0\n)\1b\1\147\1\250\1\255\14\156\0013\11\25\1\0\6]\1=\1\0\7\172\1\255\7N\1\0\t\192\1\255\17\211\1\0\17\23\1\244\2?\1\0\6\163\1\255\7\166\1\0\6\22\1C\1\5\1\218\1\255\4\243\1\249\1\255\11\240\1\0\15^\1\185\1\3\1?\1\244\1\245\1C\1\0\5\137\1\255\7\243\1\12\1s\1\155\1\12\1\0\1\n\1\201\1\255\1\240\1\251\1\255\1\211\1X\1\r\1\0\1\8\1?\1\184\1\255\t\222\1\0\15\142\1\255\1Y\1\0\1C\1\245\0022\1\0\4^\1\255\8\223\1\255\2\216\0014\1\178\1\255\4\161\1\5\1\0\6\149\1\255\6\224\1\144\1\164\1\0\15\27\1\248\1\213\1\2\1\0\1A\1\165\1\5\1\0\4,\1\255\12\254\1\255\5'\1\0\7\21\1\255\5\139\1\5\1\2\1H\1\0\16x\1X\1\2\1\0\8\2\1\239\1\255\17Q\1\0\7&\1\255\4\185\1\0\2K\1\21\1\0\28\184\1\255\17\222\1'\1\0\5\t\1\185\1\255\4\143\1\0\2r\1\0\29~\1\255\18\248\1\151\1D\1%\1B\1\133\1\223\1\255\5\221\1\29\1\0\1h\1\0\29D\1\255\31\241\1\134\1\180\1\1\1\0\28\r\1\253\1\255!$\1\0\29\212\1\255!Z\1\0\29\156\1\255!\135\1\0\29e\1\255!\152\1\0\29:\1\255!\142\1\0\29\22\1\255!^\1\0\29\8\1\255 \240\1\11\1\0\29\12\1\255 \146\1\0\30'\1\255\24\245\1\215\1\204\1\195\1\201\1\242\1\255\1\254\1)\1\0\30B\1\255\22\192\1>\1\4\1\0\4\20\1\202\1\190\1\0\31]\1\255\21\155\1\2\1\0\7f\1[\1\0\31x\1\255\21\184\1\6\1\0\7\150\1\17\1\0\31\148\1\255\22\188\1\22\1\0\5\19\1\167\1\0 \186\1\255\23\234\1z\1)\1\17\2A\1\215\1t\1\0 \227\1\255\30+\1\0\31\n\1\254\1\255\29\223\1\0 !\1\255\30v\1\0 \1\1\162\1\255\28\236\1\17\1\0!\5\1\180\1\255\26\252\1S\1\0#\n\1\196\1\255\24\247\1S\1\0%\r\1\193\1\255\22\248\1?\1\0'\n\1\185\1\255\21\177\1\0)\5\1\150\1\255\20\192\1\0+j\1\249\1\255\18\251\1\21\1\0+3\1\219\1\255\18D\1\0,\r\1\157\1\254\1\255\15\236\1\16\1\0.A\1\218\1\255\r\230\0019\1\0000\8\1x\1\236\1\255\t\247\1\140\1\15\1\0003\11\1a\1\181\1\242\1\255\3\245\1\195\1~\1\24\1\0009\17\1\26\1\t\1\0)",
	}

	r5.helmet = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\222\20\1O\1\128\1\165\1\188\1\204\2\191\1\175\1\141\1Z\1\30\1\0001\16\1n\1\198\1\254\1\255\n\254\1\194\1\\\1\2\1\0,\15\1\138\1\242\1\255\16\206\0014\1\0*P\1\233\1\255\19\247\1`\1\0'\1\1\135\1\255\22\254\1_\1\0&\138\1\255\24\250\0016\1\0$[\1\255\26\216\1\5\1\0\"\28\1\244\1\255\27k\1\0\"\163\1\255\28\213\1\0!\31\1\252\1\255\0294\1\0 \135\1\255\30\141\1\0 \217\1\255\30\198\1\0\31\28\1\255\31\246\1\4\1\0\30G\1\255 \27\1\0\30n\1\255 -\1\0\30\133\1\255 x\1\0\26\16\1j\1\169\1\226\1\255!\254\1@\1\0\25P\1\254\1\255$\177\1\0\26$\1O\1e\1{\1\136\1\142\1\215\1\255\30\229\1\0\31\6\1\181\1\255\30\252\1\4\1\0\0305\1\255 \27\1\0\30.\1\255 6\1\0\30'\1\255 Q\1\0\30\18\1\227\1\255\2\217\1\204\5\193\1\174\1\156\1\137\1t\1]\1A\1G\1\255\4\194\1\"\0038\1\235\1\255\5o\1\0\31\202\1\255\2n\1\0\11\25\1n\1\255\4\240\1\192\1\187\2\186\1\211\1\255\3\251\1\223\1A\1\0\31\179\1\255\2o\1\0\n\128\1\254\1\255\14\185\1\0![\1\255\2.\1\0\nr\1\255\15\168\1\0!\26\1\255\2\20\1\0\nM\1\255\15\151\1\0\"\225\1\255\1\7\1\0\n(\1\255\15y\1\0\"\169\1\248\1\0\11\6\1\252\1\255\3\207\1*\0013\1>\1P\1w\1\179\1\245\1\255\2\246\1\29\1\0\"p\1\235\1\0\t-\1\128\1\200\1\254\1\255\3\178\1\0\6-\1\254\1\255\1g\1\0#6\1\245\1\0\7H\1\205\1\255\6\254\1D\1\0\5\16\1\203\1\194\1b\1\0$\4\1\242\1\r\1\0\5r\1\254\1\251\1\174\1\165\1\255\4S\1\0\5*\1\209\1\207\1\r\1\0&\188\1l\1\0\4V\1\254\1\245\1A\1\0\1n\1\255\3\173\1\0\4\14\1{\1\246\1\226\1\27\1\0&+\1\254\1\253\1y\1\3\2j\1\249\1\245\1B\1\0\2\154\1\255\3@\1\0\2)\1\134\1\237\1\255\1\239\1-\1\0'4\1\255\3\239\1\235\1\255\1\246\1D\1\0\3\204\1\255\3-\1n\1\203\1\255\3\238\0013\1\0(\19\1\254\1\255\5\228\1\187\2\204\1\206\1\255\4\252\1\255\4\228\0012\1\0*\202\1\255\17\237\1\153\1\22\1\0+_\1\255\12\235\1\203\1\159\1q\0019\1\3\1\0-\7\1\205\1\174\1\144\1\177\1\249\1\255\4\246\1Y\1\r\1\0004\28\1\197\1\255\6\180\1%\1\0007\2\1U\1\159\1\192\1\198\1\147\0015\1\0\255\0\255\0\228",
	}

	r5.kevlar = {
		w = 64,
		h = 64,
		data = "\0*)\1\145\1\148\1v\1Q\1*\1\6\1\0$\27\1]\1\147\1\200\1\239\1\182\0010\1\0\r;\1\246\1\255\5\251\1\205\1\149\1^\1&\1\0\29A\1\140\1\210\1\255\4\183\1\227\1\253\1\166\1)\1\0\8\2\1s\1\209\1\245\1\255\11\174\1\6\1\0\25\24\1\176\1\255\6\193\1\6\1\t\1v\1\238\1\254\1\178\1C\1\3\1\0\4\11\1\175\1\255\n\244\1\143\1x\1\216\1\255\1\146\1\0\24P\1\236\1\255\6\219\1\21\1\0\3\18\1\138\1\238\1\255\1\236\1\172\1\153\1\138\1\136\1\207\1\255\n\174\1\25\1\0\2\6\1\173\1\255\1;\1\0\21*\1\158\1\254\1\255\0072\1\0\6\8\1X\1\157\1\203\1\221\1\237\1\255\n\254\1r\1\0\5\19\1\242\1\199\1\1\1\0\0192\1\243\1\255\7\143\1\215\1\181\1\1\1\0\t\11\1\170\1\255\nu\1\0\7\138\1\255\1=\1\0\18\21\1\225\1\255\6\249\1b\1\0\1$\1\243\1a\1\0\8\30\1\207\1\255\n\198\1\2\1\0\7.\1\255\1\159\1\0\18\180\1\255\7x\1\0\3a\1\238\1\20\1\0\6<\1\233\1\255\11L\1\0\t\216\1\243\1\6\1\0\16]\1\255\8\27\1\0\4\194\1y\1\0\5d\1\249\1\255\11\216\1\1\1\0\t\136\1\255\0016\1\0\15\23\1\236\1\255\7\235\1\0\5R\1\225\1\4\1\0\2\11\1\150\1\255\rs\1\0\nL\1\255\1o\1\0\15\171\1\255\8\207\1\0\5\8\1\243\1N\1\0\1D\1\222\1\255\r\250\1\22\1\0\n\19\1\254\1\163\1\0\14>\1\255\t\191\1\0\6\183\1\190\1\173\1\254\1\255\14\175\1\0\12\217\1\188\1\0\r\1\1\199\1\255\t\236\1\r\1\0\3\2\1N\1\227\1\255\17_\1\0\12\180\1\210\1\0\rE\1\255\11\217\1\146\1\147\1\186\1\240\1\255\18\253\1\21\1\0\12\158\1\231\1\0\r\178\1\255\"\199\1\0\r\154\1\245\1\0\12\28\1\253\1\255\"\132\1\0\r\173\1\239\1\0\12g\1\255#P\1\0\r\195\1\232\1\0\12\175\1\255#*\1\0\r\215\1\225\1\0\12\213\1\255#\17\1\0\r\237\1\208\1\0\12\238\1\255\"\253\1\1\1\0\12\4\1\254\1\178\1\0\12\241\1\255\"\242\1\0\r\31\1\255\1\147\1\0\12\224\1\255\"\229\1\0\rF\1\255\1q\1\0\12\201\1\255\"\220\1\0\rl\1\255\1@\1\0\12\165\1\255\"\217\1\0\r\157\1\253\1\14\1\0\12}\1\255\"\214\1\0\r\212\1\216\1\0\rF\1\255\"\227\1\0\12\16\1\253\1\164\1\0\r\14\1\252\1\255!\252\1\4\1\0\11J\1\255\1p\1\0\14\211\1\255\")\1\0\11\128\1\255\1@\1\0\14\153\1\255\"\138\1\0\11\164\1\255\1\19\1\0\14R\1\255\"\250\1E\1\0\n\193\1\230\1\0\15\14\1\249\1\255\"\242\1.\1\0\t\219\1\199\1\0\16\190\1\255#\225\1\25\1\0\8\239\1\179\1\0\16t\1\255$\201\1\8\1\0\7\236\1\182\1\0\16+\1\255%\151\1\0\7\182\1\203\1\0\16\1\1\240\1\255$\252\1)\1\0\5;\1\246\1\242\1\0\17\192\1\255%k\1\0\4+\1\243\1\248\1^\1\0\16\2\1\171\1\255%{\1\0\4\134\1\253\1;\1\0\17\197\1\255&\152\1D\1:\0013\2\172\1\223\1\0\18\245\1\255-\196\1\2\1\0\16\239\1\255-\189\1\0\17\233\1\255-\137\1\0\17\215\1\255-V\1\0\17\191\1\255-&\1\0\17u\1\202\1\237\1\255*\243\1\2\1\0\19\218\1\255*\191\1\0\20\218\1\255$\158\0016\1/\0014\1\146\1\245\1Y\1\0\20\218\1\255$v\1\0\3\197\1\169\1\0\20/\1\239\1\255$p\1\0\2#\1\254\1|\1\0\19\"\1\243\1\255%j\1\0\2}\1\255\1\147\1\3\1\0\18H\1\255&d\1\29\1D\1\218\1\255\1\244\1\1\1\0\18?\1\255&\251\1\255\4\206\1\0\0196\1\255+\168\1\0\19*\1\255+\159\1\0\19\25\1\255+\160\1\0\19\8\1\249\1\196\1\255)\167\1\0\0208\1i\1\255)\179\1\0\21i\1\255)\165\1\0\21j\1\255$\211\1\172\1\223\1\255\2E\1\0\20\4\1\208\1\255#\251\1\3\1\0\1\165\1\255\2z\1\0\20\6\1\236\1\255#\228\1\0\2\157\1\255\2\130\1\0\21+\1\175\1\250\1\255!\197\1\0\2I\1\245\1\164\1\8\1\0\23\12\1K\1z\1\166\1\205\1\231\1\252\1\255\26\251\1S\1\0\3\1\1\0\31\2\1\24\1.\1<\1E\1U\1`\1i\1w\2z\1\136\3\152\1\153\2\165\1\170\4\165\1\153\1\143\1\131\1c\1!\1\0\18",
	}

	r5.loader = {
		w = 64,
		h = 64,
		data = "\0\24\23\1T\1\127\1\166\1\204\1\221\1\238\1\249\2\238\1\221\1\204\1\166\1\127\1T\1\22\1\0-5\1\143\1\212\1\254\1\255\14\254\1\212\1\142\0015\1\0'\14\1u\1\214\1\255\22\214\1t\1\r\1\0\"\18\1\130\1\238\1\255\26\238\1\128\1\17\1\0\30\2\1d\1\236\1\255\7\251\1\199\1\140\1d\1=\1!\1\17\1\5\2\17\1!\1=\1d\1\140\1\200\1\251\1\255\7\234\1a\1\1\1\0\27%\1\198\1\255\6\248\1\173\1P\1\r\1\0\5\18\0013\2\17\1\0\5\14\1R\1\174\1\249\1\255\6\196\1#\1\0\25X\1\242\1\255\5\234\1{\1\18\1\0\6?\1\190\1\252\1\255\2\252\1\189\1=\1\0\6\18\1{\1\235\1\255\5\240\1U\1\0\22\2\1\143\1\255\5\243\1w\1\11\1\0\7{\1\254\1\255\6\254\1y\1\0\7\11\1y\1\244\1\255\5\141\1\2\1\0\19\6\1\167\1\255\5\175\1\29\1\0\8d\1\255\na\1\0\8\30\1\177\1\255\5\165\1\5\1\0\17\6\1\182\1\255\4\247\1f\1\0\t\17\1\238\1\255\n\237\1\16\1\0\tj\1\247\1\255\4\180\1\5\1\0\15\2\1\166\1\255\4\227\1/\1\0\ne\1\255\12b\1\0\n2\1\229\1\255\4\165\1\2\1\0\14\144\1\255\4\215\1\31\1\0\1\8\1J\1w\1\128\1`\1\27\1\0\4\158\1\255\12\156\1\0\4\27\1a\1\128\1w\1I\1\8\1\0\1 \1\216\1\255\4\140\1\0\rX\1\255\4\216\1\21\1\0\1e\1\232\1\255\4\252\1\158\1\16\1\0\2\176\1\255\12\176\1\0\2\17\1\160\1\252\1\255\4\232\1d\1\0\1\22\1\217\1\255\4U\1\0\11$\1\241\1\255\3\228\1 \1\0\1\147\1\255\8\217\1\24\1\0\1\155\1\255\12\154\1\0\1\24\1\217\1\255\8\146\1\0\1\28\1\226\1\255\3\242\1'\1\0\t\2\1\198\1\255\3\247\1/\1\0\1e\1\255\n\194\1\1\1^\1\255\12[\1\1\1\195\1\255\nd\1\0\0012\1\247\1\255\3\195\1\1\1\0\8e\1\255\4f\1\0\1\8\1\232\1\255\11P\1\12\1\232\1\255\n\231\1\11\1P\1\255\11\232\1\8\1\0\1k\1\255\4`\1\0\7\18\1\236\1\255\3\174\1\0\2J\1\255\12\168\1\0\1U\1\254\1\255\8\254\1S\1\0\1\169\1\255\12I\1\0\2\177\1\255\3\233\1\16\1\0\6\131\1\255\3\245\1 \1\0\2x\1\255\12\213\1\0\2h\1\251\1\255\6\250\1g\1\0\2\215\1\255\12v\1\0\2\30\1\244\1\255\3~\1\0\5\14\1\239\1\255\3w\1\0\3\127\1\255\12\221\1\0\3-\1\170\1\245\1\255\2\244\1\169\1,\1\0\3\222\1\255\12~\1\0\3{\1\255\3\237\1\r\1\0\4u\1\255\3\234\1\11\1\0\3`\1\255\12\190\1\0\5\6\1 \2\6\1\0\5\191\1\255\12^\1\0\3\12\1\236\1\255\3s\1\0\4\215\1\255\3z\1\0\4\27\1\252\1\255\11v\1\0\14v\1\255\11\252\1\26\1\0\4~\1\255\3\213\1\0\0036\1\255\3\249\1\19\1\0\5\159\1\255\n\237\1\16\1\0\14\16\1\237\1\255\n\157\1\0\5\20\1\249\1\255\0032\1\0\2\144\1\255\3\173\1\0\6\16\1\217\1\255\8\253\1K\1\0\5\n\1:\1R\0029\1\t\1\0\5L\1\253\1\255\8\217\1\16\1\0\6\176\1\255\3\140\1\0\2\212\1\255\3Q\1\0\7\24\1\194\1\255\6\237\1K\1\0\0041\1\172\1\245\1\255\4\245\1\171\1/\1\0\4L\1\237\1\255\6\193\1\24\1\0\7U\1\255\3\209\1\0\1\22\1\254\1\255\2\251\1\14\1\0\8\1\1P\1\168\1\213\1\220\1\190\1v\1\16\1\0\3\4\1\144\1\253\1\255\8\253\1\141\1\3\1\0\3\16\1v\1\190\1\220\1\213\1\168\1O\1\1\1\0\8\15\1\252\1\255\2\254\1\21\1U\1\255\3\200\1\0\4\17\1e\1\158\1\175\1\156\1^\1\12\1\0\8\4\1\179\1\255\12\177\1\3\1\0\8\r\1_\1\156\1\175\1\158\1d\1\16\1\0\4\202\1\255\3S\1\127\1\255\3\140\1\0\3d\1\238\1\255\5\232\1U\1\0\7\144\1\255\14\140\1\0\7W\1\233\1\255\5\237\1b\1\0\3\142\1\255\3}\1\166\1\255\3c\1\0\2{\1\255\8\254\1h\1\0\5/\1\253\1\255\14\253\0011\1\0\5j\1\254\1\255\8y\1\0\2f\1\255\3\164\1\203\1\255\3<\1\0\1?\1\254\1\255\t\251\1.\1\0\4\172\1\255\16\170\1\0\0040\1\251\1\255\t\254\1=\1\0\1?\1\255\3\202\1\223\1\255\3\31\1\0\1\190\1\255\11\170\1\0\3\n\1\245\1\255\16\245\1\n\1\0\3\172\1\255\11\188\1\0\1!\1\255\3\222\1\237\1\255\3\18\2\252\1\255\11\244\1\6\1\0\2:\1\255\0188\1\0\2\7\1\245\1\255\11\252\1\17\1\20\1\255\3\235\1\249\1\255\3\6\0014\1\255\r \1\0\2T\1\255\18S\1\0\2\"\1\255\r2\1\7\1\255\3\248\1\249\1\255\3\6\0013\1\255\r\31\1\0\2S\1\255\18Q\1\0\2!\1\255\r1\1\7\1\255\3\248\1\237\1\255\3\18\2\252\1\255\11\244\1\6\1\0\0029\1\255\0188\1\0\2\7\1\245\1\255\11\252\1\16\1\20\1\255\3\235\1\223\1\255\3 \1\0\1\189\1\255\11\169\1\0\3\t\1\244\1\255\16\243\1\8\1\0\3\171\1\255\11\187\1\0\1!\1\255\3\221\1\203\1\255\3=\1\0\1=\1\253\1\255\t\250\1,\1\0\4\171\1\255\16\169\1\0\4.\1\251\1\255\t\253\1;\1\0\1?\1\255\3\201\1\166\1\255\3c\1\0\2y\1\255\8\254\1g\1\0\5.\1\253\1\255\14\253\0010\1\0\5h\1\254\1\255\8x\1\0\2f\1\255\3\163\1\127\1\255\3\140\1\0\3b\1\237\1\255\5\231\1S\1\0\7\141\1\255\14\138\1\0\7U\1\232\1\255\5\236\1_\1\0\3\142\1\255\3}\1T\1\255\3\200\1\0\4\16\1c\1\157\1\175\1\154\1\\\1\12\1\0\8\3\1\177\1\255\12\175\1\3\1\0\8\12\1]\1\155\1\175\1\157\1b\1\15\1\0\4\203\1\255\3R\1\22\1\254\1\255\2\251\1\14\1\0\8\1\1P\1\169\1\213\1\220\1\191\1v\1\16\1\0\3\3\1\140\1\253\1\255\8\253\1\138\1\3\1\0\3\17\1v\1\191\1\220\1\213\1\169\1P\1\1\1\0\8\16\1\252\1\255\2\254\1\20\1\0\1\211\1\255\3R\1\0\7\24\1\195\1\255\6\237\1K\1\0\4.\1\170\1\244\1\255\4\244\1\169\1-\1\0\4L\1\238\1\255\6\194\1\24\1\0\7U\1\255\3\208\1\0\2\142\1\255\3\174\1\0\6\17\1\217\1\255\8\253\1L\1\0\5\t\0018\1R\0028\1\8\1\0\5M\1\253\1\255\8\217\1\16\1\0\6\177\1\255\3\138\1\0\0025\1\255\3\249\1\19\1\0\5\160\1\255\n\237\1\16\1\0\14\17\1\238\1\255\n\158\1\0\5\20\1\249\1\255\0031\1\0\3\212\1\255\3|\1\0\4\27\1\252\1\255\11v\1\0\14w\1\255\11\252\1\26\1\0\4\127\1\255\3\213\1\0\4u\1\255\3\235\1\11\1\0\3a\1\255\12\191\1\0\5\7\1!\2\7\1\0\5\191\1\255\12_\1\0\3\r\1\237\1\255\3r\1\0\4\14\1\238\1\255\3z\1\0\3\127\1\255\12\222\1\0\0030\1\172\1\246\1\255\2\245\1\171\1.\1\0\3\222\1\255\12~\1\0\3}\1\255\3\236\1\r\1\0\5\129\1\255\3\245\1 \1\0\2w\1\255\12\212\1\0\2j\1\251\1\255\6\251\1h\1\0\2\213\1\255\12t\1\0\2\30\1\244\1\255\3}\1\0\6\17\1\235\1\255\3\177\1\0\2J\1\255\12\167\1\0\1W\1\254\1\255\8\254\1U\1\0\1\168\1\255\12H\1\0\2\180\1\255\3\232\1\15\1\0\7c\1\255\4i\1\0\1\8\1\232\1\255\11O\1\r\1\233\1\255\n\232\1\12\1O\1\255\11\231\1\8\1\0\1n\1\255\4]\1\0\8\1\1\196\1\255\3\247\0012\1\0\1d\1\255\n\193\1\1\1`\1\255\12]\1\1\1\194\1\255\nc\1\0\0015\1\248\1\255\3\193\1\1\1\0\t#\1\240\1\255\3\229\1 \1\0\1\147\1\255\8\217\1\24\1\0\1\156\1\255\12\154\1\0\1\24\1\217\1\255\8\146\1\0\1!\1\230\1\255\3\239\1\"\1\0\11U\1\255\4\216\1\22\1\0\1c\1\232\1\255\4\252\1\157\1\16\1\0\2\176\1\255\12\176\1\0\2\17\1\158\1\252\1\255\4\231\1b\1\0\1\22\1\217\1\255\3\254\1R\1\0\r\141\1\255\4\217\1 \1\0\1\8\1H\1u\1\127\1^\1\26\1\0\4\158\1\255\12\156\1\0\4\26\1_\1\127\1u\1H\1\8\1\0\1!\1\218\1\255\4\137\1\0\14\2\1\165\1\255\4\229\0012\1\0\nd\1\255\12a\1\0\n4\1\230\1\255\4\162\1\1\1\0\15\5\1\181\1\255\4\247\1j\1\0\t\16\1\238\1\255\n\236\1\16\1\0\tm\1\248\1\255\4\179\1\5\1\0\17\5\1\164\1\255\5\177\1\31\1\0\8b\1\255\n_\1\0\8!\1\180\1\255\5\162\1\5\1\0\19\1\1\140\1\255\5\245\1{\1\12\1\0\7y\1\254\1\255\6\253\1x\1\0\7\r\1}\1\246\1\255\4\254\1\137\1\1\1\0\22T\1\240\1\255\5\236\1}\1\20\1\0\6=\1\188\1\252\1\255\2\252\1\187\1;\1\0\6\20\1~\1\237\1\255\5\239\1R\1\0\25#\1\195\1\255\6\249\1\176\1T\1\15\1\0\5\17\0012\2\17\1\0\5\17\1V\1\178\1\250\1\255\6\193\1!\1\0\27\1\1`\1\234\1\255\7\252\1\202\1\142\1e\1?\1\"\1\18\1\6\2\18\1\"\1@\1f\1\142\1\203\1\252\1\255\7\232\1^\1\1\1\0\30\16\1\127\1\237\1\255\26\236\1}\1\15\1\0\"\r\1s\1\212\1\255\22\212\1r\1\r\1\0'2\1\140\1\209\1\254\1\255\14\254\1\208\1\139\0012\1\0-\21\1R\1}\1\165\1\202\1\221\1\236\1\249\2\236\1\221\1\201\1\164\1|\1R\1\20\1\0\24",
	}

	r5.magazine = {
		w = 64,
		h = 64,
		data = "\230\1\255\24\246\1\27\1\0%\171\1\255\25g\1\0%^\1\255\7\251\1\218\1\236\1\255\8\239\1\217\1\249\1\255\4\180\1\0%\20\1\252\1\255\5\154\1\21\1\0\2=\1\215\1\255\4\238\1Z\1\4\1\0\1\8\1t\1\251\1\255\2\246\1\11\1\0%\196\1\255\4\156\1\0\5\24\1\233\1\255\2\253\1=\1\0\5e\1\255\3O\1\0%w\1\255\3\254\1\27\1\0\1\26\1\145\1l\1\0\2{\1\255\2\183\1\0\2M\1\151\0013\1\0\1\2\1\218\1\255\2\156\1\0%*\1\255\3\229\1\0\2\148\1\255\2B\1\0\1%\1\255\2\131\1\0\1\1\1\245\1\255\1\222\1\1\1\0\1\135\1\255\2\231\1\2\1\0%\220\1\255\2\241\1\1\1\0\1\129\1\255\2\146\1\0\2\217\1\255\1\144\1\0\2\227\1\255\0020\1\0\1<\1\255\0036\1\0%\144\1\255\0030\1\0\0017\1\255\2\222\1\0\2\141\1\255\1\206\1\0\2\152\1\255\2{\1\0\1\3\1\235\1\255\2\131\1\0%C\1\255\3|\1\0\1\2\1\231\1\255\2*\1\0\1B\1\255\1\254\1\28\1\0\1M\1\255\2\198\1\0\2\163\1\255\2\208\1\0%\5\1\239\1\255\2\199\1\0\2\158\1\255\2v\1\0\1\5\1\239\1\255\1f\1\0\1\t\1\245\1\255\1\253\1\23\1\0\1X\1\255\3 \1\0%\169\1\255\2\253\1\23\1\0\1S\1\255\2\193\1\0\2\170\1\255\1\177\1\0\2\181\1\255\2_\1\0\1\15\1\250\1\255\2k\1\0%\\\1\255\3_\1\0\1\12\1\248\1\255\1\252\1\19\1\0\1_\1\255\1\246\1\t\1\0\1j\1\255\2\170\1\0\2\192\1\255\2\184\1\0%\18\1\251\1\255\2\170\1\0\2\187\1\255\2Y\1\0\1\21\1\252\1\255\1I\1\0\1\29\1\254\1\255\1\241\1\6\1\0\1u\1\255\2\248\1\r\1\0%\194\1\255\2\241\1\6\1\0\1p\1\255\2\164\1\0\2\198\1\255\1\148\1\0\2\209\1\255\2B\1\0\1)\1\255\3R\1\0%u\1\255\3C\1\0\1\"\1\255\2\237\1\4\1\0\1{\1\255\1\225\1\0\2\134\1\255\2\141\1\0\2\219\1\255\2\159\1\0%(\1\255\3\142\1\0\2\216\1\255\2<\1\0\1/\1\255\2,\1\0\1;\1\255\2\216\1\0\2\145\1\255\2\234\1\3\1\0%\217\1\255\2\220\1\0\2\140\1\255\2\135\1\0\2\224\1\255\1x\1\0\1\3\1\235\1\255\2%\1\0\1F\1\255\3:\1\0%\141\1\255\3&\1\0\1A\1\255\2\211\1\0\2\151\1\255\1\195\1\0\2\162\1\255\2q\1\0\1\6\1\242\1\255\2\135\1\0%@\1\255\3r\1\0\1\4\1\239\1\255\2 \1\0\1L\1\255\1\252\1\20\1\0\1W\1\255\2\188\1\0\2\174\1\255\2\212\1\0%\4\1\238\1\255\2\189\1\0\2\169\1\255\2k\1\0\1\t\1\245\1\255\1[\1\0\1\15\1\250\1\255\1\250\1\15\1\0\1c\1\255\3$\1\0%\166\1\255\2\250\1\16\1\0\1^\1\255\2\182\1\0\2\180\1\255\1\166\1\0\2\191\1\255\2T\1\0\1\22\1\253\1\255\2o\1\0%Y\1\255\3U\1\0\1\19\1\252\1\255\1\248\1\12\1\0\1i\1\255\1\240\1\5\1\0\1t\1\255\2\159\1\0\2\202\1\255\2\188\1\0%\15\1\250\1\255\2\160\1\0\2\197\1\255\2N\1\0\1\29\1\254\1\255\1?\1\0\1(\1\255\2\234\1\2\1\0\1\127\1\255\2\250\1\16\1\0%\191\1\255\2\234\1\3\1\0\1z\1\255\2\153\1\0\2\208\1\255\1\138\1\0\2\219\1\255\0027\1\0\0014\1\255\3V\1\0%r\1\255\0039\1\0\1/\1\255\2\230\1\1\1\0\1\133\1\255\1\213\1\0\2\144\1\255\2\130\1\0\1\1\1\228\1\255\2\163\1\0%#\1\255\3\132\1\0\2\224\1\255\0021\1\0\1:\1\255\2$\1\0\1E\1\255\2\206\1\0\2\155\1\255\2\237\1\4\1\0%\216\1\255\2\207\1\0\2\150\1\255\2}\1\0\1\2\1\233\1\255\1n\1\0\1\6\1\242\1\255\1\254\1\28\1\0\1P\1\255\3>\1\0%\139\1\255\3\31\1\0\1K\1\255\2\200\1\0\2\161\1\255\1\185\1\0\2\173\1\255\2f\1\0\1\11\1\247\1\255\2\139\1\0%>\1\255\3h\1\0\1\t\1\245\1\255\1\253\1\23\1\0\1V\1\255\1\249\1\r\1\0\1b\1\255\2\177\1\0\2\184\1\255\2\216\1\0%\3\1\236\1\255\2\179\1\0\2\179\1\255\2`\1\0\1\14\1\250\1\255\1Q\1\0\1\22\1\253\1\255\1\246\1\t\1\0\1m\1\255\3&\1\0%\164\1\255\2\246\1\n\1\0\1h\1\255\2\171\1\0\2\190\1\255\1\156\1\0\2\201\1\255\2I\1\0\1!\1\255\3r\1\0%W\1\255\3K\1\0\1\28\1\254\1\255\1\241\1\6\1\0\1s\1\255\1\231\1\1\1\0\1~\1\255\2\148\1\0\2\213\1\255\2\191\1\0%\15\1\249\1\255\2\150\1\0\2\208\1\255\2C\1\0\1'\1\255\0024\1\0\0013\1\255\2\225\1\0\2\137\1\255\2\252\1\19\1\0%\189\1\255\2\226\1\1\1\0\1\132\1\255\2\142\1\0\2\218\1\255\1\128\1\0\1\1\1\228\1\255\2,\1\0\1>\1\255\3Z\1\0%p\1\255\3/\1\0\0019\1\255\2\220\1\0\2\143\1\255\1\203\1\0\2\154\1\255\2x\1\0\1\3\1\236\1\255\2\167\1\0%\"\1\255\3z\1\0\1\2\1\233\1\255\2&\1\0\1D\1\255\1\254\1\27\1\0\1O\1\255\2\195\1\0\2\166\1\255\2\240\1\5\1\0%\214\1\255\2\197\1\0\2\161\1\255\2r\1\0\1\5\1\240\1\255\1c\1\0\1\11\1\247\1\255\1\252\1\20\1\0\1[\1\255\3B\1\0%\137\1\255\2\253\1\22\1\0\1V\1\255\2\189\1\0\2\171\1\255\1\174\1\0\2\183\1\255\2[\1\0\1\18\1\251\1\255\2\143\1\0%<\1\255\3^\1\0\1\14\1\249\1\255\1\250\1\16\1\0\1`\1\255\1\244\1\8\1\0\1l\1\255\2\166\1\0\2\194\1\255\2\221\1\0%\3\1\235\1\255\2\169\1\0\2\190\1\255\2U\1\0\1\22\1\253\1\255\1G\1\0\1\30\1\255\2\240\1\5\1\0\1w\1\255\3)\1\0%\161\1\255\2\240\1\5\1\0\1s\1\255\2\160\1\0\2\200\1\255\1\146\1\0\2\212\1\255\2?\1\0\1,\1\255\3v\1\0%T\1\255\3A\1\0\1'\1\255\2\234\1\2\1\0\1}\1\255\1\222\1\0\2\136\1\255\2\138\1\0\2\222\1\255\2\195\1\0%\12\1\248\1\255\2\140\1\0\2\218\1\255\0028\1\0\0011\1\255\2*\1\0\1=\1\255\2\213\1\0\2\147\1\255\2\252\1\20\1\0%\186\1\255\2\216\1\0\2\143\1\255\2\131\1\0\1\1\1\227\1\255\1v\1\0\1\3\1\236\1\255\2$\1\0\1H\1\255\3^\1\0%m\1\255\3%\1\0\1D\1\255\2\207\1\0\2\153\1\255\1\193\1\0\2\165\1\255\2n\1\0\1\7\1\243\1\255\2\171\1\0%\31\1\255\3p\1\0\1\5\1\240\1\255\2\30\1\0\1N\1\255\1\252\1\19\1\0\1Z\1\255\2\185\1\0\2\176\1\255\2\243\1\7\1\0%\211\1\255\2\187\1\0\2\171\1\255\2g\1\0\1\t\1\245\1\255\1Y\1\0\1\17\1\251\1\255\1\248\1\r\1\0\1e\1\255\3E\1\0%\134\1\255\2\250\1\15\1\0\1`\1\255\2\178\1\0\2\182\1\255\1\164\1\0\2\194\1\255\2Q\1\0\1\25\1\254\1\255\2\146\1\0%9\1\255\3T\1\0\1\22\1\253\1\255\1\246\1\n\1\0\1k\1\255\1\237\1\4\1\0\1w\1\255\2\156\1\0\2\205\1\255\2\225\1\0%\2\1\232\1\255\2\159\1\0\2\200\1\255\2J\1\0\1\30\1\255\2<\1\0\1+\1\255\2\230\1\1\1\0\1\129\1\255\3-\1\0%\159\1\255\2\232\1\2\1\0\1}\1\255\2\148\1\0\2\224\1\255\1\136\1\0\2\222\1\255\0023\1\0\1D\1\255\3z\1\0%R\1\255\0037\1\0\1-\1\254\1\255\1\166\1\0\2\211\1\255\1\211\1\0\2\141\1\255\2D\1\0\0017\1\255\3\199\1\0%\12\1\248\1\255\2\140\1\0\2[\1\158\1&\1\0\1\15\1\249\1\255\2*\1\0\1\16\1\140\1~\1\4\1\0\1l\1\255\3\253\1\23\1\0%\184\1\255\2\242\1\"\1\0\5\140\1\255\3\176\1\2\1\0\4\16\1\223\1\255\4b\1\0%k\1\255\3\223\1F\1\0\2\16\1\141\1\255\5\168\1\27\1\0\0022\1\206\1\255\5\174\1\0%\31\1\255\5\237\1\213\1\248\1\255\7\253\1\221\1\225\1\255\7\243\1\8\1\0%\209\1\255\25I\1\0%Y\1\170\25K\1\0d\24\1\"\28\18\1\0!\136\1\255\29\251\1]\1\0 \242\1\255\30\194\1\0 \172\1\255\30~\1\0\17",
	}

	local r2_1 = r2 + -333430020 + 2961247216 + 1889259311

	r5.outofview = {
		w = 64,
		h = 64,
		data = "\0\195\16\1\8\1\0>\4\1\179\1o\1\7\1\0=6\1\253\1\223\1f\1\3\1\0<\154\1\255\2\213\1U\1\1\1\0:\18\1\233\1\255\3\200\1C\1\0:^\1\255\5\196\1=\1\0009\189\1\255\6\187\0010\1\0007&\1\248\1\255\6\253\1\170\1$\1\0006\131\1\255\8\250\1\153\1\26\1\0004\7\1\216\1\255\t\249\1\153\1\23\1\0003F\1\255\11\243\1\136\1\15\1\0002\168\1\255\12\236\1w\1\t\1\0000\24\1\239\1\255\r\227\1o\1\7\1\0/l\1\255\15\223\1f\1\3\1\0-\2\1\199\1\255\16\213\1U\1\1\1\0,.\1\251\1\255\17\200\1C\1\0,\145\1\255\19\196\1=\1\0*\r\1\228\1\255\20\187\0010\1\0)U\1\255\21\253\1\170\1$\1\0(\179\1\255\22\250\1\153\1\26\1\0&\31\1\244\1\255\23\249\1\153\1\23\1\0%z\1\255\25\243\1\136\1\15\1\0#\6\1\213\1\255\26\236\1w\1\t\1\0\"=\1\254\1\255\27\227\1o\1\7\1\0!\159\1\255\29\223\1f\1\3\1\0\31\19\1\234\1\255\30\213\1U\1\1\1\0\30c\1\255 \200\1C\1\0\29\1\1\191\1\255!\196\1=\1\0\28+\1\250\1\255\"\187\0010\1\0\26+\1\250\1\255\"\187\0010\1\0\25\1\1\191\1\255!\196\1=\1\0\27c\1\255 \200\1C\1\0\28\19\1\234\1\255\30\213\1U\1\1\1\0\29\159\1\255\29\223\1f\1\3\1\0\30=\1\254\1\255\27\227\1o\1\7\1\0\31\6\1\213\1\255\26\236\1w\1\t\1\0!z\1\255\25\243\1\136\1\15\1\0\"\31\1\244\1\255\23\249\1\153\1\23\1\0$\179\1\255\22\250\1\153\1\26\1\0%U\1\255\21\253\1\170\1$\1\0&\r\1\228\1\255\20\187\0010\1\0(\145\1\255\19\196\1=\1\0).\1\251\1\255\17\200\1C\1\0*\2\1\199\1\255\16\213\1U\1\1\1\0+l\1\255\15\223\1f\1\3\1\0,\24\1\239\1\255\r\227\1o\1\7\1\0.\168\1\255\12\236\1w\1\t\1\0/F\1\255\11\243\1\136\1\15\1\0000\7\1\216\1\255\t\249\1\153\1\23\1\0002\131\1\255\8\250\1\153\1\26\1\0003&\1\248\1\255\6\253\1\170\1$\1\0005\189\1\255\6\187\0010\1\0006^\1\255\5\196\1=\1\0007\18\1\233\1\255\3\200\1C\1\0009\154\1\255\2\213\1U\1\1\1\00096\1\253\1\223\1f\1\3\1\0:\4\1\179\1o\1\7\1\0<\16\1\8\1\0\251",
	}

	local t122_1132_3 = table.pack(3056)
	local r9 = bit32.band(t122_1132_3[1] * 56095 + bit32.lshift(bit32.band(t122_1132_3[1] * 8476 + 2534652575, 65535), 16), 4294967295)

	r5.outofviewEdge = {
		w = 64,
		h = 64,
		data = "\0A\20\1\172\1\237\1\199\1O\1\1\1\0:\172\1\255\4\200\1C\1\0009\238\1\255\6\189\0018\1\0007\197\1\255\8\177\1-\1\0005A\1\254\1\255\8\253\1\164\1$\1\0004\162\1\255\n\250\1\162\1 \1\0002\20\1\235\1\255\11\249\1\153\1\23\1\0001g\1\255\r\243\1\136\1\16\1\0/\2\1\197\1\255\14\237\1w\1\t\1\0..\1\251\1\255\15\228\1h\1\5\1\0-\139\1\255\17\224\1f\1\3\1\0+\n\1\223\1\255\18\213\1U\1\1\1\0*J\1\255\20\201\1M\1\0*\176\1\255\21\196\1>\1\0(\29\1\243\1\255\22\187\0011\1\0'u\1\255\23\253\1\170\1%\1\0%\4\1\207\1\255\24\250\1\162\1 \1\0$6\1\253\1\255\25\249\1\153\1\23\1\0#\153\1\255\27\243\1\136\1\16\1\0!\17\1\233\1\255\28\237\1w\1\t\1\0 ]\1\255\30\233\1w\1\7\1\0\31\188\1\255\31\224\1f\1\3\1\0\29%\1\247\1\255 \213\1U\1\1\1\0\28\130\1\255\"\201\1M\1\0\27\7\1\216\1\255#\196\1>\1\0\26E\1\255%\187\0011\1\0\25\167\1\255%\253\1\170\1%\1\0\23\24\1\239\1\255&\250\1\162\1 \1\0\22k\1\255(\246\1\140\1\14\1\0\20\2\1\202\1\255)\210\1\8\1\0\0202\1\252\1\255)M\1\0\0202\1\252\1\255)M\1\0\19\2\1\202\1\255)\210\1\8\1\0\19k\1\255(\246\1\140\1\14\1\0\19\24\1\239\1\255&\250\1\162\1 \1\0\21\167\1\255%\253\1\170\1%\1\0\22E\1\255%\187\0011\1\0\23\7\1\216\1\255#\196\1>\1\0\25\130\1\255\"\201\1M\1\0\26%\1\247\1\255 \213\1U\1\1\1\0\27\188\1\255\31\224\1f\1\3\1\0\28]\1\255\30\233\1w\1\7\1\0\29\17\1\233\1\255\28\237\1w\1\t\1\0\31\153\1\255\27\243\1\136\1\16\1\0 6\1\253\1\255\25\249\1\153\1\23\1\0!\4\1\207\1\255\24\250\1\162\1 \1\0#u\1\255\23\253\1\170\1%\1\0$\29\1\243\1\255\22\187\0011\1\0&\176\1\255\21\196\1>\1\0'J\1\255\20\201\1M\1\0(\n\1\223\1\255\18\213\1U\1\1\1\0)\139\1\255\17\224\1f\1\3\1\0*.\1\251\1\255\15\228\1h\1\5\1\0+\2\1\197\1\255\14\237\1w\1\t\1\0-g\1\255\r\243\1\136\1\16\1\0.\20\1\235\1\255\11\249\1\153\1\23\1\0000\162\1\255\n\250\1\162\1 \1\0001A\1\254\1\255\8\253\1\164\1$\1\0003\197\1\255\8\177\1-\1\0005\238\1\255\6\189\0018\1\0007\172\1\255\4\200\1C\1\0009\20\1\172\1\237\1\199\1O\1\1\1\0y",
	}

	r5.pencil = {
		w = 64,
		h = 64,
		data = "\0\255\0\175T\1\235\1\234\1T\1\0;U\1\251\1\255\2\252\1\\\1\0\22+\1\180\1\246\1\255\20\234\1P\1\0\nW\1\251\1\255\4\251\1W\1\0\20+\1\241\1\255\23\232\1\0\tW\1\251\1\255\6\251\1W\1\0\19\180\1\255\24\231\1\0\8W\1\251\1\255\3\251\2\255\3\251\1W\1\0\18\246\1\255\23\232\1N\1\0\7W\1\251\1\255\3\251\1W\2\251\1\255\3\251\1W\1\0\17\255\4\0\28U\1\251\1\255\3\252\1[\1\0\2T\1\251\1\255\3\252\1\\\1\0\16\255\4\0\27U\1\251\1\255\3\252\1[\1\0\4U\1\251\1\255\3\252\1\\\1\0\15\255\4\0\26W\1\251\1\255\4\251\1W\1\0\5X\1\252\1\255\3\251\1S\1\0\14\255\4\0\25W\1\251\1\255\6\251\1W\1\0\5Y\1\252\1\255\3\232\1\0\14\255\4\0\24W\1\251\1\255\8\251\1W\1\0\4Y\1\252\1\255\3\231\1\0\14\255\4\0\23W\1\251\1\255\n\251\1W\1\0\2X\1\252\1\255\3\251\1S\1\0\14\255\4\0\22U\1\251\1\255\12\252\1\\\1U\1\251\1\255\3\252\1[\1\0\15\255\4\0\21W\1\251\1\255\14\251\2\255\3\251\1W\1\0\16\255\4\0\20U\1\251\1\255\19\252\1[\1\0\17\255\4\0\19U\1\251\1\255\19\252\1[\1\0\18\255\4\0\18U\1\251\1\255\19\252\1[\1\0\19\255\4\0\17U\1\251\1\255\19\252\1[\1\0\20\255\4\0\16U\1\251\1\255\19\252\1[\1\0\21\255\4\0\15U\1\251\1\255\19\252\1[\1\0\22\255\4\0\14U\1\251\1\255\19\252\1[\1\0\23\255\4\0\rU\1\251\1\255\19\252\1[\1\0\24\255\4\0\12U\1\251\1\255\19\252\1[\1\0\25\255\4\0\11U\1\251\1\255\19\252\1[\1\0\26\255\4\0\nT\1\251\1\255\19\251\1W\1\0\7R\1\235\1\234\1P\1\0\16\255\4\0\n\234\1\255\19\251\1W\1\0\8\235\1\255\2\232\1\0\16\255\4\0\n\255\19\252\1[\1\0\t\255\4\0\16\255\4\0\n\255\18\252\1[\1\0\n\255\4\0\16\255\4\0\n\255\17\252\1[\1\0\11\255\4\0\16\255\4\0\n\255\16\252\1[\1\0\12\255\4\0\16\255\4\0\n\255\15\252\1[\1\0\r\255\4\0\16\255\4\0\n\255\14\252\1[\1\0\14\255\4\0\16\255\4\0\n\255\r\252\1[\1\0\15\255\4\0\16\255\4\0\n\255\12\252\1[\1\0\16\255\4\0\16\255\4\0\n\234\1\255\n\251\1W\1\0\17\255\4\0\16\255\4\0\nP\1\233\1\255\8\232\1S\1\0\18\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0(\255\4\0\16\245\1\255.\243\1\0\16\179\1\255.\175\1\0\16)\1\240\1\255,\239\1'\1\0\17(\1\177\1\244\1\255(\243\1\175\1'\1\0\255\0\255\0\11",
	}

	local r800002 = r9 + 3521667687

	r5.revolver = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\255\0\159\5\1\0\3\n\2\6\1\11\1\0\2\2\1\16\1\0\1\16\1\3\1\14\1\3\1\0(Y\1\0\5`\1\254\1\155\1\219\1\177\1\198\2\169\1\205\1\148\1\226\1\134\1\247\1w\1\249\1\140\1\227\1\146\1\214\1\160\1\200\1\227\1\138\1\28\1\0\7Z\1w\2`\1\3\1\0\21q\1\253\1\238\1\235\1\151\1\136\2\209\1\255\22\248\1\152\1w\6\222\1\255\3?\1\0\21M\1\255)\236\1B\1\0\18\n\1o\1\179\1\255*\184\1\0\12\1\1U\1|\1\195\1\135\1\19\1\167\1\255,\184\1\0\15\4\1\184\1\251\1\255-\183\1\0\16F\1\255.|\1\0\14<\1\190\1\254\1\255.\31\1\0\11>\1\129\1\172\1\253\1\2550\16\1\0\ns\1\2554\16\1\0\n\175\1\255\28\249\1\161\1f\1U\7%\1\6\1\17\3O\1\153\4C\1\136\3\t\1\0\n\177\1\255\27\243\1=\1\0\"\196\1\255\27\150\1\0\";\1\254\1\255\27~\1\0!\7\1\214\1\255\17\244\1\241\1\255\tw\1\0!\132\1\255\18\134\1\0\1\22\1\153\1\254\1\255\2\230\1\194\1\189\1\204\1^\1\0 0\1\250\1\255\rt\1\131\1\212\1\251\1\253\1:\1\0\3y\1\254\1_\1\2\1\0#\3\1\204\1\255\r\223\1\4\1\0\1\5\1\222\1\127\1\0\4%\1\184\1\0%o\1\255\14\183\1\0\2\2\1\234\0019\1\0\4(\1s\1\0$\27\1\242\1\255\14\223\1\0\3\134\1\132\1\0\4k\1(\1\0$\173\1\255\0165\1\0\2\7\1\147\1\140\1\7\1\0\1J\1w\1\0$?\1\255\11\197\1f\1_\1}\1\154\1\175\1\183\0013\1\2\1\0\2/\1z\1\138\1c\1\0%\170\1\255\n\174\1\2\1\0\5\28\1\161\1\199\1\167\1\170\1\132\1L\1\8\1\0%\26\1\250\1\255\na\1\0003~\1\255\11\165\1\0002\3\1\227\1\255\11\254\1\23\1\0001E\1\255\12e\1\0002\163\1\255\11\226\1\0002\11\1\243\1\255\11\232\1\3\1\0001g\1\255\rW\1\0000\5\1\221\1\255\12\210\0012\1\0000`\1\255\12\184\1\4\1\0001m\1\255\12<\1\0002\1\1^\1\197\1\252\1\255\6\249\1\198\1h\1\0006\8\1-\1E\1U\2E\1(\1\6\1\0\255\0\255\0\255\0\184",
	}

	r5.roblox = {
		w = 64,
		h = 64,
		data = "\0\12\3\1\198\1\145\1O\1\16\1\0;6\1\255\3\253\1\213\1\153\1U\1\15\1\0007x\1\255\7\252\1\204\1\136\1D\1\8\1\0003\185\1\255\11\251\1\204\1\136\1D\1\7\1\0.\6\1\244\1\255\15\245\1\187\1w\1<\1\5\1\0*>\1\255\20\243\1\187\1w\0013\1\1\1\0&~\1\255\24\233\1\168\1g\1&\1\0#\192\1\255\28\231\1\170\1f\1!\1\0\30\n\1\248\1\255 \230\1\170\1f\1\30\1\0\26E\1\255%\221\1\153\1U\1\20\1\0\22\134\1\255)\221\1\153\1U\1\17\1\0\18\199\1\255,\252\1\204\1\145\1U\1\15\1\0\r\r\1\250\1\2550\251\1\204\1\136\1D\1\8\1\0\tK\1\2555\211\1\0\t\141\1\2555\154\1\0\t\207\1\2555Y\1\0\8\18\1\253\1\2554\254\1\24\1\0\8S\1\2555\213\1\0\t\148\1\2555\147\1\0\t\214\1\2555R\1\0\8\23\1\254\1\2554\253\1\20\1\0\8Z\1\2555\205\1\0\t\155\1\2555\139\1\0\t\221\1\2555J\1\0\8\30\1\2555\251\1\14\1\0\8`\1\255\21\241\1\255\31\198\1\0\t\162\1\255\21/\1\25\1U\1\145\1\204\1\254\1\255\26\131\1\0\t\227\1\255\20\235\1\2\1\0\4\26\1^\1\161\1\228\1\255\23B\1\0\8&\1\255\21\171\1\0\t,\1\227\1\255\20\247\1\8\1\0\8h\1\255\21i\1\0\t\n\1\248\1\255\20\189\1\0\t\169\1\255\21'\1\0\tF\1\255\21|\1\0\8\1\1\232\1\255\20\230\1\0\n\135\1\255\21:\1\0\8.\1\255\21\163\1\0\n\201\1\255\20\243\1\5\1\0\8o\1\255\21b\1\0\t\15\1\251\1\255\20\182\1\0\t\176\1\255\21 \1\0\tN\1\255\21t\1\0\8\3\1\239\1\255\20\237\1\28\1\0\t\144\1\255\0213\1\0\0085\1\255\23\221\1\153\1^\1\27\1\0\5\212\1\255\20\239\1\3\1\0\8v\1\255\27\221\1\153\1U\1\17\1\22\1\254\1\255\20\173\1\0\t\183\1\255\30\252\1\220\1\255\21l\1\0\8\5\1\243\1\2555*\1\0\8<\1\2555\232\1\1\1\0\8~\1\2555\165\1\0\t\191\1\2555d\1\0\8\8\1\247\1\2555#\1\0\8C\1\2555\225\1\0\t\132\1\2555\158\1\0\t\198\1\2555]\1\0\8\12\1\250\1\2555\28\1\0\8J\1\2555\216\1\0\t\139\1\2555\150\1\0\t\182\1\2555U\1\0\n-\1u\1\189\1\248\1\2550\254\1\21\1\0\r\t\1D\1\128\1\187\1\250\1\255,\208\1\0\18\12\1D\1\136\1\204\1\254\1\255(\142\1\0\22\21\1U\1\145\1\204\1\255%M\1\0\26\25\1U\1\153\1\225\1\255 \252\1\16\1\0\30\"\1f\1\170\1\236\1\255\28\200\1\0\"\2\0011\1s\1\180\1\242\1\255\24\135\1\0&\3\0013\1w\1\179\1\241\1\255\20E\1\0*\4\0013\1w\1\187\1\247\1\255\15\249\1\11\1\0.\t\1<\1w\1\187\1\249\1\255\11\192\1\0003\11\1D\1\136\1\196\1\250\1\255\7\127\1\0007\12\1D\1\136\1\204\1\253\1\255\3=\1\0;\21\1T\1\150\1\206\1\6\1\0\12",
	}

	r5.smoked = {
		w = 64,
		h = 64,
		data = "\0\255\0\255\0\218\1\1'\1Q\1j\1u\1p\1[\0017\1\7\1\0006\25\1g\1\128\7x\0011\1\0004$\1z\1\128\nG\1\0002\22\1y\1\128\0126\1\0001^\1\128\r{\1\14\1\0\18.\1\0\28\27\1\128\15B\1\0\1\23\1(\0010\1$\1\t\1\0\11;\1\253\1O\1\0\1;\1\4\1\0\24C\1\128\15u\1n\1\128\4~\1Z\1\24\1\0\8\4\1\214\1\203\1\3\1S\1\251\1n\1\0\24W\1\128\23~\0018\1\0\8L\1.\1J\1\248\1\173\1\5\1\0\24a\1\128\11\137\1\147\1\159\1\169\1\179\n\134\1f\4$\1\0\3\11\1\232\1\174\1\5\1\0\19\4\0012\1W\1d\1Y\1:\1b\1\128\11\151\1\181\1\211\1\240\1\255\15\253\1\179\0012\1\0\2'\1\6\1\0\19\22\1n\1\128\17\151\1\181\1\211\1\240\1\255\17\254\1\172\1\r\1\0\1\160\1\197\4F\1\0\r\14\1t\1\128\18\151\1\181\1\211\1\240\1\255\17\187\1/\1\0\2\134\1\165\4:\1\0\rR\1\128\19\149\1\176\1\203\1\230\1\255\15\213\1K\1\0\3\3\1\31\1\0\17\6\1|\1\128#'\1\0\7\131\1\233\1,\1\0\16\26\1\128$\30\1\0\5k\1v\1\21\1\210\1\234\1.\1\0\15\23\1\128$O\0010\1\r\1\0\3\141\1\242\1\17\1\21\1\209\1\220\1\4\1\0\14\5\1~\1\128\15}\1\128\21~\1W\1\19\1\0\1\27\1\243\1N\1\0\1\20\0013\1\0\16S\1\128\11\127\1W\1\"\1\t\1\0\1\n\1(\1~\1\128\20|\0013\1\0\1\15\1\0\18\2\1 \1N\1\128\ny\1%\1\0\6s\1\128\22;\1\0\17\2\0017\1q\1\128\11|\1\27\1\0\2\26\1E\1R\1H\1Y\1\128\23\127\1$\1\0\15\r\1c\1\128\r;\1\0\2B\1\127\1\128\28o\1\3\1\0\r\r\1m\1\128\rw\1\5\1\0\1/\1\128\0310\1\0\12\2\1`\1\128\14R\1\0\1\1\1o\1\128\31Y\1\0\0122\1\128\12l\1W\1X\0012\1\0\1\17\1\128 x\1\0\12n\1\128\nk\1\30\1\0\5\23\1\128!\6\1\0\n\24\1\128\np\1\12\1\0\6\7\1\128!\n\1\0\n7\1\128\n%\1\0\1\4\1K\1w\1t\1P\1\22\0011\1\128 }\1\0\11D\1\128\ts\1\1\1\0\1E\1\128&f\1\0\11G\1\128\tW\1\0\2s\1\128&@\1\0\11;\1\128\tK\1\0\1\7\1\128&{\1\r\1\0\11%\1\128\tN\1\0\1\19\1\128&A\1\0\12\4\1y\1\128\8}\1L\1h\1\128%`\1\2\1\0\rF\1\128/^\1\6\1\0\14\n\1v\1\128,z\1;\1\2\1\0\16 \1}\1\128(x\1[\0018\1\8\1\0\19'\1z\1\128\22W\1P\1\128\14^\1\n\1\0\23\22\1^\1\128\8z\1:\1\27\1L\1t\1\128\5s\1L\1\26\1\0\2-\1s\1\128\ny\1=\1\2\1\0\26\31\1I\1i\1w\1}\1s\1[\0017\1\8\1\0\4\15\1\31\1#\1\30\1\16\1\0\6\4\0015\1a\1~\1\128\5g\1@\1\n\1\0007\8\1\27\1'\1(\1\29\1\12\1\0\255\0\255\0\255\0\152",
	}

	r5.trash = {
		w = 64,
		h = 64,
		data = "\0\255\0\23\t\1t\1\206\1\250\1\255\12\250\1\206\1s\1\8\1\0+\30\1\213\1\255\18\212\1\29\1\0)\t\1\213\1\255\20\211\1\8\1\0(t\1\255\22q\1\0(\206\1\255\3\173\1\20\1\0\12\21\1\175\1\255\3\204\1\0(\249\1\255\3\20\1\0\14\23\1\255\3\247\1\0(\255\4\0\16\255\4\0(\255\4\0\16\255\4\0\28R\1\235\1\255,\234\1P\1\0\16\235\1\255.\232\1\0\16\234\1\255.\231\1\0\16P\1\233\1\255,\232\1N\1\0\20\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255\12\173\1\20\1\21\1\175\1\255\8\173\1\20\1\21\1\175\1\255\12\0\24\255\12\20\1\0\2\23\1\255\8\20\1\0\2\23\1\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\0\4\255\8\0\4\255\12\0\24\255\12\21\1\0\2\24\1\255\8\21\1\0\2\24\1\255\12\0\24\255\12\175\1\22\1\23\1\177\1\255\8\175\1\22\1\23\1\177\1\255\12\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\255(\0\24\245\1\255&\243\1\0\24\179\1\255&\175\1\0\24)\1\240\1\255$\239\1'\1\0\25(\1\177\1\244\1\255 \243\1\175\1'\1\0\255\0\255\0\15",
	}

	r5.outofviewGlow = {
		w = 64,
		h = 64,
		data = "\8\1\t\1\11\1\12\1\14\1\16\1\17\1\18\1\17\1\16\1\15\1\r\1\n\1\8\1\7\1\5\1\4\1\2\2\1\2\0+\t\1\11\1\r\1\15\1\18\1\20\1\22\1\23\1\22\2\20\1\18\1\15\1\r\1\11\1\8\1\6\1\4\1\3\1\2\2\1\2\0)\n\1\r\1\15\1\18\1\22\1\25\1\28\1\29\1\30\1\29\1\28\1\26\1\23\1\19\1\16\1\r\1\11\1\8\1\6\1\4\1\3\1\2\1\1\3\0'\12\1\15\1\18\1\22\1\27\1\31\1#\1%\1'\2&\1#\1 \1\28\1\25\1\20\1\17\1\r\1\n\1\8\1\6\1\4\1\3\1\2\1\1\3\0%\r\1\17\1\21\1\26\1 \1&\1+\1/\0011\0012\2/\1,\1(\1#\1\30\1\25\1\21\1\17\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0#\14\1\18\1\23\1\30\1%\1,\0013\0018\1<\1>\1?\1=\1:\0015\0010\1*\1$\1\31\1\25\1\20\1\16\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0!\15\1\20\1\25\1 \1)\0012\1:\1A\1G\1K\1M\1L\1I\1E\1@\0019\0012\1+\1%\1\30\1\25\1\20\1\16\1\12\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\31\15\1\20\1\26\1\"\1,\0016\1@\1I\1Q\1V\1Z\1[\1Y\1V\1Q\1J\1B\1;\0013\1+\1$\1\30\1\24\1\20\1\16\1\12\1\n\1\7\1\5\1\4\1\3\1\2\1\1\3\0\29\14\1\20\1\26\1\"\1-\0018\1D\1O\1X\1`\1f\1i\2g\1b\1\\\1T\1L\1C\1:\0012\1+\1$\1\29\1\24\1\19\1\16\1\12\1\t\1\7\1\5\1\4\1\3\1\2\1\1\3\0\27\r\1\18\1\25\1\"\1-\0019\1F\1R\1^\1h\1p\1u\1x\1w\1t\1n\1g\1_\1V\1L\1C\1:\0012\1*\1#\1\29\1\24\1\19\1\15\1\12\1\t\1\7\1\5\1\3\2\2\1\1\2\0\26\11\1\17\1\23\1 \1+\0018\1E\1S\1a\1m\1w\1\127\1\132\1\134\1\133\1\129\1z\1s\1j\1`\1V\1L\1B\0019\0011\1)\1#\1\29\1\23\1\18\1\15\1\11\1\t\1\6\1\5\1\3\2\2\1\1\2\0\24\n\1\14\1\20\1\29\1(\0015\1C\1R\1a\1o\1{\1\134\1\141\1\146\1\147\1\145\1\141\1\135\1~\1t\1j\1`\1U\1K\1B\0019\0011\1)\1\"\1\28\1\23\1\18\1\14\1\11\1\t\1\6\1\5\1\3\1\2\2\1\2\0\22\8\1\12\1\17\1\25\1$\0010\1>\1N\1^\1m\1|\1\137\1\148\1\155\1\159\1\160\1\158\1\153\1\146\1\137\1\127\1u\1j\1_\1U\1J\1A\0018\0010\1(\1\"\1\27\1\22\1\18\1\14\1\11\1\8\1\6\1\4\1\3\1\2\2\1\2\0\20\6\1\n\1\14\1\21\1\31\1+\0018\1H\1Y\1i\1z\1\137\1\150\1\160\1\168\1\171\1\172\1\169\1\164\1\157\1\148\1\138\1\127\1t\1i\1^\1T\1J\1@\0017\1/\1'\1!\1\27\1\22\1\17\1\14\1\11\1\8\1\6\1\4\1\3\1\2\1\1\3\0\18\4\1\8\1\11\1\18\1\26\1%\0012\1A\1R\1c\1u\1\134\1\149\1\162\1\173\1\179\1\182\1\183\1\180\1\175\1\167\1\159\1\148\1\138\1\127\1s\1i\1]\1S\1H\1@\0016\1.\1'\1 \1\26\1\22\1\17\1\r\1\n\1\8\1\6\1\4\1\3\1\2\1\1\3\0\16\3\1\6\1\t\1\14\1\21\1\31\1+\0019\1I\1[\1m\1\128\1\145\1\160\1\173\1\183\1\190\1\193\2\190\1\185\1\178\1\169\1\159\1\148\1\137\1~\1s\1g\1\\\1R\1H\1>\0016\1-\1&\1 \1\26\1\21\1\17\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\14\2\1\4\1\6\1\11\1\17\1\25\1$\0011\1@\1Q\1d\1w\1\138\1\155\1\171\1\183\1\193\1\199\1\202\2\199\1\194\1\187\1\178\1\169\1\158\1\148\1\136\1}\1q\1g\1[\1Q\1G\1=\0015\1-\1&\1\31\1\25\1\20\1\16\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\12\1\1\3\1\4\1\8\1\r\1\20\1\29\1)\0017\1H\1Z\1m\1\129\1\148\1\165\1\180\1\193\1\202\1\208\1\210\2\208\1\202\1\196\1\188\1\178\1\168\1\158\1\146\1\135\1|\1p\1e\1Z\1P\1F\1=\0014\1,\1%\1\30\1\25\1\20\1\16\1\12\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\n\1\1\2\1\3\1\6\1\n\1\16\1\24\1\"\1/\1>\1O\1b\1v\1\138\1\157\1\174\1\189\1\201\1\210\1\215\1\218\2\215\1\210\1\204\1\196\1\187\1\178\1\167\1\156\1\146\1\134\1{\1o\1d\1Y\1O\1E\1<\0013\1+\1$\1\30\1\24\1\20\1\16\1\12\1\n\1\7\1\5\1\4\1\3\1\2\1\1\3\0\t\1\1\2\1\4\1\7\1\12\1\18\1\27\1&\0014\1E\1W\1k\1\127\1\147\1\165\1\183\1\197\1\209\1\216\1\222\1\224\2\222\1\217\1\211\1\204\1\196\1\186\1\176\1\167\1\155\1\144\1\133\1z\1n\1c\1Y\1N\1D\1;\0012\1+\1$\1\29\1\24\1\19\1\16\1\12\1\t\1\7\1\5\1\4\1\3\1\2\1\1\3\0\7\1\2\3\1\5\1\t\1\14\1\22\1\31\1,\1:\1L\1_\1s\1\136\1\155\1\174\1\191\1\204\1\215\1\223\1\228\1\230\2\228\1\223\1\218\1\211\1\203\1\195\1\186\1\175\1\165\1\154\1\143\1\132\1y\1n\1c\1W\1M\1C\1:\0012\1*\1#\1\29\1\24\1\19\1\15\1\12\1\t\1\7\1\5\1\3\2\2\1\1\2\0\7\1\1\2\1\4\1\6\1\11\1\17\1\25\1$\0011\1A\1S\1g\1|\1\144\1\164\1\182\1\198\1\211\1\221\1\228\1\233\1\235\2\232\1\229\1\224\1\217\1\211\1\203\1\194\1\185\1\175\1\164\1\154\1\142\1\131\1x\1l\1a\1V\1L\1B\1:\0011\1)\1#\1\29\1\23\1\18\1\15\1\11\1\t\1\6\1\5\1\3\2\2\1\1\2\0\6\1\1\3\1\4\1\8\1\r\1\19\1\29\1)\0017\1H\1[\1o\1\131\1\152\1\172\1\189\1\204\1\217\1\226\1\233\1\237\1\239\2\237\1\234\1\229\1\224\1\217\1\210\1\202\1\193\1\184\1\174\1\163\1\153\1\142\1\130\1v\1k\1`\1U\1K\1B\0019\0011\1)\1\"\1\28\1\23\1\18\1\14\1\11\1\8\1\6\1\4\1\3\1\2\1\1\3\0\4\1\1\2\1\3\1\6\1\t\1\15\1\23\1!\1.\1=\1O\1c\1w\1\140\1\160\1\179\1\196\1\211\1\222\1\231\1\237\1\241\1\242\2\241\1\238\1\234\1\229\1\223\1\217\1\209\1\201\1\193\1\183\1\173\1\163\1\151\1\140\1\129\1v\1j\1_\1U\1J\1A\0018\1/\1(\1!\1\27\1\22\1\17\1\r\1\n\1\7\1\5\1\3\1\2\1\1\2\0\5\1\1\2\1\4\1\7\1\11\1\18\1\26\1&\0014\1D\1W\1j\1\127\1\149\1\168\1\187\1\203\1\217\1\228\1\235\1\241\1\244\1\245\2\244\1\241\1\238\1\233\1\229\1\222\1\216\1\209\1\200\1\192\1\183\1\172\1\161\1\150\1\139\1\128\1u\1i\1^\1T\1I\1?\0016\1.\1&\1\31\1\25\1\20\1\15\1\11\1\8\1\5\1\3\1\2\2\1\1\0\4\1\2\3\1\5\1\8\1\r\1\21\1\31\1+\1:\1L\1^\1s\1\137\1\157\1\177\1\195\1\210\1\223\1\232\1\240\1\245\1\247\1\248\2\247\1\244\1\241\1\238\1\233\1\228\1\222\1\215\1\208\1\200\1\191\1\181\1\171\1\161\1\149\1\138\1\127\1s\1h\1\\\1Q\1F\1=\0013\1*\1\"\1\27\1\21\1\16\1\11\1\8\1\5\1\3\1\2\1\1\1\0\5\1\1\2\1\3\1\6\1\n\1\16\1\25\1#\0011\1A\1S\1h\1}\1\146\1\167\1\186\1\203\1\218\1\229\1\238\1\244\1\248\1\250\3\249\1\247\1\244\1\241\1\237\1\233\1\227\1\221\1\215\1\207\1\199\1\190\1\180\1\170\1\159\1\148\1\136\1|\1p\1d\1X\1M\1A\0017\1-\1$\1\28\1\21\1\15\1\11\1\7\1\4\1\3\1\2\1\0\6\1\1\2\1\4\1\7\1\12\1\20\1\29\1)\0018\1I\1]\1s\1\136\1\158\1\178\1\197\1\212\1\225\1\235\1\242\1\247\1\250\1\252\2\251\1\250\1\249\1\246\1\244\1\241\1\237\1\232\1\227\1\221\1\214\1\206\1\198\1\189\1\179\1\168\1\156\1\144\1\132\1w\1j\1]\1P\1C\0018\1-\1#\1\27\1\19\1\14\1\t\1\6\1\4\1\2\1\0\6\1\2\3\1\6\1\t\1\16\1\24\1#\0011\1A\1U\1j\1\127\1\150\1\170\1\190\1\207\1\221\1\232\1\241\1\246\1\250\1\252\1\253\2\252\2\250\1\249\1\246\1\243\1\240\1\236\1\231\1\226\1\220\1\213\1\204\1\195\1\185\1\174\1\162\1\150\1\136\1z\1m\1^\1P\1B\0016\1+\1 \1\24\1\17\1\11\1\7\1\5\1\3\1\0\7\1\1\2\1\4\1\7\1\r\1\20\1\30\1+\1;\1N\1c\1x\1\143\1\164\1\185\1\202\1\218\1\230\1\239\1\246\1\250\1\252\1\254\3\253\1\252\2\250\1\248\1\246\1\243\1\239\1\235\1\230\1\224\1\217\1\209\1\199\1\189\1\177\1\165\1\151\1\136\1z\1i\1Z\1L\1=\0011\1%\1\27\1\20\1\r\1\t\1\6\1\3\1\0\8\2\1\3\1\6\1\11\1\17\1\26\1'\0016\1I\1]\1s\1\138\1\160\1\181\1\199\1\215\1\228\1\238\1\245\1\249\1\252\1\254\5\253\1\252\1\251\1\249\1\247\1\244\1\241\1\237\1\232\1\225\1\218\1\209\1\199\1\188\1\175\1\162\1\146\1\131\1r\1b\1R\1C\0015\1)\1\30\1\22\1\14\1\t\1\6\1\4\1\0\8\1\1\3\1\5\1\n\1\16\1\25\1%\0014\1F\1[\1p\1\136\1\158\1\179\1\198\1\214\1\227\1\237\1\245\1\249\1\252\1\254\2\255\2\254\2\253\1\252\1\251\1\249\1\247\1\244\1\240\1\236\1\230\1\223\1\214\1\204\1\193\1\181\1\167\1\151\1\136\1w\1f\1V\1F\0018\1+\1\31\1\23\1\15\1\n\1\6\1\4\1\0\8\1\1\3\1\5\1\n\1\16\1\25\1%\0014\1F\1[\1p\1\136\1\158\1\179\1\198\1\214\1\227\1\237\1\245\1\249\1\252\1\254\2\255\2\254\2\253\1\252\1\251\1\249\1\247\1\244\1\240\1\236\1\230\1\223\1\214\1\204\1\193\1\181\1\167\1\151\1\136\1w\1f\1V\1F\0018\1+\1\31\1\23\1\15\1\n\1\6\1\4\1\0\8\2\1\3\1\6\1\11\1\17\1\26\1'\0016\1I\1]\1s\1\138\1\160\1\181\1\199\1\215\1\228\1\238\1\245\1\249\1\252\1\254\5\253\1\252\1\251\1\249\1\247\1\244\1\241\1\237\1\232\1\225\1\218\1\209\1\199\1\188\1\175\1\162\1\146\1\131\1r\1b\1R\1C\0015\1)\1\30\1\22\1\14\1\t\1\6\1\4\1\0\7\1\1\2\1\4\1\7\1\r\1\20\1\30\1+\1;\1N\1c\1x\1\143\1\164\1\185\1\202\1\218\1\230\1\239\1\246\1\250\1\252\1\254\3\253\1\252\2\250\1\248\1\246\1\243\1\239\1\235\1\230\1\224\1\217\1\209\1\199\1\189\1\177\1\165\1\151\1\136\1z\1i\1Z\1L\1=\0011\1%\1\27\1\20\1\r\1\t\1\6\1\3\1\0\6\1\2\3\1\6\1\t\1\16\1\24\1#\0011\1A\1U\1j\1\127\1\150\1\170\1\190\1\207\1\221\1\232\1\241\1\246\1\250\1\252\1\253\2\252\2\250\1\249\1\246\1\243\1\240\1\236\1\231\1\226\1\220\1\213\1\204\1\195\1\185\1\174\1\162\1\150\1\136\1z\1m\1^\1P\1B\0016\1+\1 \1\24\1\17\1\11\1\7\1\5\1\3\1\0\6\1\1\2\1\4\1\7\1\12\1\20\1\29\1)\0018\1I\1]\1s\1\136\1\158\1\178\1\197\1\212\1\225\1\235\1\242\1\247\1\250\1\252\2\251\1\250\1\249\1\246\1\244\1\241\1\237\1\232\1\227\1\221\1\214\1\206\1\198\1\189\1\179\1\168\1\156\1\144\1\132\1w\1j\1]\1P\1C\0018\1-\1#\1\27\1\19\1\14\1\t\1\6\1\4\1\2\1\0\5\1\1\2\1\3\1\6\1\n\1\16\1\25\1#\0011\1A\1S\1h\1}\1\146\1\167\1\186\1\203\1\218\1\229\1\238\1\244\1\248\1\250\3\249\1\247\1\244\1\241\1\237\1\233\1\227\1\221\1\215\1\207\1\199\1\190\1\180\1\170\1\159\1\148\1\136\1|\1p\1d\1X\1M\1A\0017\1-\1$\1\28\1\21\1\15\1\11\1\7\1\4\1\3\1\2\1\0\4\1\2\3\1\5\1\8\1\r\1\21\1\31\1+\1:\1L\1^\1s\1\137\1\157\1\177\1\195\1\210\1\223\1\232\1\240\1\245\1\247\1\248\2\247\1\244\1\241\1\238\1\233\1\228\1\222\1\215\1\208\1\200\1\191\1\181\1\171\1\161\1\149\1\138\1\127\1s\1h\1\\\1Q\1F\1=\0013\1*\1\"\1\27\1\21\1\16\1\11\1\8\1\5\1\3\1\2\1\1\1\0\4\1\1\2\1\4\1\7\1\11\1\18\1\26\1&\0014\1D\1W\1j\1\127\1\149\1\168\1\187\1\203\1\217\1\228\1\235\1\241\1\244\1\245\2\244\1\241\1\238\1\233\1\229\1\222\1\216\1\209\1\200\1\192\1\183\1\172\1\161\1\150\1\139\1\128\1u\1i\1^\1T\1I\1?\0016\1.\1&\1\31\1\25\1\20\1\15\1\11\1\8\1\5\1\3\1\2\2\1\1\0\3\1\1\2\1\3\1\6\1\t\1\15\1\23\1!\1.\1=\1O\1c\1w\1\140\1\160\1\179\1\196\1\211\1\222\1\231\1\237\1\241\1\242\2\241\1\238\1\234\1\229\1\223\1\217\1\209\1\201\1\193\1\183\1\173\1\163\1\151\1\140\1\129\1v\1j\1_\1U\1J\1A\0018\1/\1(\1!\1\27\1\22\1\17\1\r\1\n\1\7\1\5\1\3\1\2\1\1\2\0\4\1\1\3\1\4\1\8\1\r\1\19\1\29\1)\0017\1H\1[\1o\1\131\1\152\1\172\1\189\1\204\1\217\1\226\1\233\1\237\1\239\2\237\1\234\1\229\1\224\1\217\1\210\1\202\1\193\1\184\1\174\1\163\1\153\1\142\1\130\1v\1k\1`\1U\1K\1B\0019\0011\1)\1\"\1\28\1\23\1\18\1\14\1\11\1\8\1\6\1\4\1\3\1\2\1\1\3\0\3\1\1\2\1\4\1\6\1\11\1\17\1\25\1$\0011\1A\1S\1g\1|\1\144\1\164\1\182\1\198\1\211\1\221\1\228\1\233\1\235\2\232\1\229\1\224\1\217\1\211\1\203\1\194\1\185\1\175\1\164\1\154\1\142\1\131\1x\1l\1a\1V\1L\1B\1:\0011\1)\1#\1\29\1\23\1\18\1\15\1\11\1\t\1\6\1\5\1\3\2\2\1\1\2\0\4\1\2\3\1\5\1\t\1\14\1\22\1\31\1,\1:\1L\1_\1s\1\136\1\155\1\174\1\191\1\204\1\215\1\223\1\228\1\230\2\228\1\223\1\218\1\211\1\203\1\195\1\186\1\175\1\165\1\154\1\143\1\132\1y\1n\1c\1W\1M\1C\1:\0012\1*\1#\1\29\1\24\1\19\1\15\1\12\1\t\1\7\1\5\1\3\2\2\1\1\2\0\6\1\1\2\1\4\1\7\1\12\1\18\1\27\1&\0014\1E\1W\1k\1\127\1\147\1\165\1\183\1\197\1\209\1\216\1\222\1\224\2\222\1\217\1\211\1\204\1\196\1\186\1\176\1\167\1\155\1\144\1\133\1z\1n\1c\1Y\1N\1D\1;\0012\1+\1$\1\29\1\24\1\19\1\16\1\12\1\t\1\7\1\5\1\4\1\3\1\2\1\1\3\0\6\1\1\2\1\3\1\6\1\n\1\16\1\24\1\"\1/\1>\1O\1b\1v\1\138\1\157\1\174\1\189\1\201\1\210\1\215\1\218\2\215\1\210\1\204\1\196\1\187\1\178\1\167\1\156\1\146\1\134\1{\1o\1d\1Y\1O\1E\1<\0013\1+\1$\1\30\1\24\1\20\1\16\1\12\1\n\1\7\1\5\1\4\1\3\1\2\1\1\3\0\8\1\1\3\1\4\1\8\1\r\1\20\1\29\1)\0017\1H\1Z\1m\1\129\1\148\1\165\1\180\1\193\1\202\1\208\1\210\2\208\1\202\1\196\1\188\1\178\1\168\1\158\1\146\1\135\1|\1p\1e\1Z\1P\1F\1=\0014\1,\1%\1\30\1\25\1\20\1\16\1\12\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\n\2\1\4\1\6\1\11\1\17\1\25\1$\0011\1@\1Q\1d\1w\1\138\1\155\1\171\1\183\1\193\1\199\1\202\2\199\1\194\1\187\1\178\1\169\1\158\1\148\1\136\1}\1q\1g\1[\1Q\1G\1=\0015\1-\1&\1\31\1\25\1\20\1\16\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\12\3\1\6\1\t\1\14\1\21\1\31\1+\0019\1I\1[\1m\1\128\1\145\1\160\1\173\1\183\1\190\1\193\2\190\1\185\1\178\1\169\1\159\1\148\1\137\1~\1s\1g\1\\\1R\1H\1>\0016\1-\1&\1 \1\26\1\21\1\17\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\14\4\1\8\1\11\1\18\1\26\1%\0012\1A\1R\1c\1u\1\134\1\149\1\162\1\173\1\179\1\182\1\183\1\180\1\175\1\167\1\159\1\148\1\138\1\127\1s\1i\1]\1S\1H\1@\0016\1.\1'\1 \1\26\1\22\1\17\1\r\1\n\1\8\1\6\1\4\1\3\1\2\1\1\3\0\16\6\1\n\1\14\1\21\1\31\1+\0018\1H\1Y\1i\1z\1\137\1\150\1\160\1\168\1\171\1\172\1\169\1\164\1\157\1\148\1\138\1\127\1t\1i\1^\1T\1J\1@\0017\1/\1'\1!\1\27\1\22\1\17\1\14\1\11\1\8\1\6\1\4\1\3\1\2\1\1\3\0\18\8\1\12\1\17\1\25\1$\0010\1>\1N\1^\1m\1|\1\137\1\148\1\155\1\159\1\160\1\158\1\153\1\146\1\137\1\127\1u\1j\1_\1U\1J\1A\0018\0010\1(\1\"\1\27\1\22\1\18\1\14\1\11\1\8\1\6\1\4\1\3\1\2\2\1\2\0\20\n\1\14\1\20\1\29\1(\0015\1C\1R\1a\1o\1{\1\134\1\141\1\146\1\147\1\145\1\141\1\135\1~\1t\1j\1`\1U\1K\1B\0019\0011\1)\1\"\1\28\1\23\1\18\1\14\1\11\1\t\1\6\1\5\1\3\1\2\2\1\2\0\22\11\1\17\1\23\1 \1+\0018\1E\1S\1a\1m\1w\1\127\1\132\1\134\1\133\1\129\1z\1s\1j\1`\1V\1L\1B\0019\0011\1)\1#\1\29\1\23\1\18\1\15\1\11\1\t\1\6\1\5\1\3\2\2\1\1\2\0\24\r\1\18\1\25\1\"\1-\0019\1F\1R\1^\1h\1p\1u\1x\1w\1t\1n\1g\1_\1V\1L\1C\1:\0012\1*\1#\1\29\1\24\1\19\1\15\1\12\1\t\1\7\1\5\1\3\2\2\1\1\2\0\26\14\1\20\1\26\1\"\1-\0018\1D\1O\1X\1`\1f\1i\2g\1b\1\\\1T\1L\1C\1:\0012\1+\1$\1\29\1\24\1\19\1\16\1\12\1\t\1\7\1\5\1\4\1\3\1\2\1\1\3\0\27\15\1\20\1\26\1\"\1,\0016\1@\1I\1Q\1V\1Z\1[\1Y\1V\1Q\1J\1B\1;\0013\1+\1$\1\30\1\24\1\20\1\16\1\12\1\n\1\7\1\5\1\4\1\3\1\2\1\1\3\0\29\15\1\20\1\25\1 \1)\0012\1:\1A\1G\1K\1M\1L\1I\1E\1@\0019\0012\1+\1%\1\30\1\25\1\20\1\16\1\12\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0\31\14\1\18\1\23\1\30\1%\1,\0013\0018\1<\1>\1?\1=\1:\0015\0010\1*\1$\1\31\1\25\1\20\1\16\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0!\r\1\17\1\21\1\26\1 \1&\1+\1/\0011\0012\2/\1,\1(\1#\1\30\1\25\1\21\1\17\1\r\1\n\1\7\1\6\1\4\1\3\1\2\1\1\3\0#\12\1\15\1\18\1\22\1\27\1\31\1#\1%\1'\2&\1#\1 \1\28\1\25\1\20\1\17\1\r\1\n\1\8\1\6\1\4\1\3\1\2\1\1\3\0%\n\1\r\1\15\1\18\1\22\1\25\1\28\1\29\1\30\1\29\1\28\1\26\1\23\1\19\1\16\1\r\1\11\1\8\1\6\1\4\1\3\1\2\1\1\3\0'\t\1\11\1\r\1\15\1\18\1\20\1\22\1\23\1\22\2\20\1\18\1\15\1\r\1\11\1\8\1\6\1\4\1\3\1\2\2\1\2\0)\8\1\t\1\11\1\12\1\14\1\16\1\17\1\18\1\17\1\16\1\15\1\r\1\n\1\8\1\7\1\5\1\4\1\2\2\1\2\0+",
	}

	r5.shadow = {
		w = 80,
		h = 80,
		data = "\0\255\0c\8\12\0>\8\24\0004\8 \0.\8$\0*\8(\0&\8\15\16\14\8\15\0#\8\11\16\24\8\11\0!\8\n\16\7\24\14\16\7\8\n\0\30\8\n\16\5\24\22\16\5\8\n\0\27\8\t\16\5\24\6 \14\24\6\16\5\8\t\0\26\8\8\16\3\24\6 \7(\6 \7\24\6\16\3\8\8\0\25\8\7\16\4\24\4 \5(\0060\4(\6 \5\24\4\16\4\8\7\0\23\8\7\16\4\24\3 \4(\0040\14(\4 \4\24\3\16\4\8\7\0\21\8\7\16\3\24\4 \3(\0030\0038\0140\3(\3 \3\24\4\16\3\8\7\0\19\8\7\16\3\24\3 \3(\0020\0038\3@\0148\0030\3(\2 \3\24\3\16\3\8\7\0\18\8\6\16\3\24\3 \3(\0020\0028\2@\3H\4P\6H\4@\0038\0020\2(\2 \3\24\3\16\3\8\6\0\17\8\6\16\3\24\3 \3(\0010\0038\1@\3H\2P\3X\8P\3H\2@\0038\0010\3(\1 \3\24\3\16\3\8\6\0\16\8\6\16\3\24\2 \3(\0010\0028\2@\2H\1P\3X\3`\8X\3P\3H\1@\0028\0020\2(\1 \3\24\2\16\3\8\6\0\15\8\6\16\3\24\2 \3(\0010\0028\1@\2H\1P\2X\3`\1h\5p\2h\5`\1X\3P\2H\1@\0028\0010\2(\1 \3\24\2\16\3\8\6\0\14\8\6\16\2\24\3 \2(\0010\0028\1@\2H\1P\2X\1`\2h\2p\2x\8p\2h\2`\2X\1P\2H\1@\0028\0010\2(\1 \2\24\3\16\2\8\6\0\14\8\5\16\2\24\3 \2(\0010\0028\1@\2H\1P\1X\2`\1h\2p\1x\2\128\nx\2p\1h\2`\1X\2P\1H\1@\0028\0010\2(\1 \2\24\3\16\2\8\5\0\r\8\6\16\2\24\2 \2(\0020\0018\1@\2H\1P\1X\1`\2h\1p\1x\2\128\2\136\2\144\6\136\2\128\2x\2p\1h\1`\2X\1P\1H\1@\0028\0010\1(\2 \2\24\2\16\2\8\6\0\12\8\5\16\3\24\2 \2(\0010\0028\1@\1H\1P\1X\1`\1h\2p\1x\1\128\2\136\1\144\2\152\8\144\2\136\1\128\2x\1p\1h\2`\1X\1P\1H\1@\0018\0010\2(\1 \2\24\2\16\3\8\5\0\12\8\5\16\2\24\2 \2(\0010\0028\1@\1H\1P\1X\1`\1h\2x\2\128\1\136\1\144\2\152\1\160\3\168\4\160\3\152\1\144\2\136\1\128\1x\2h\2`\1X\1P\1H\1@\0018\0010\2(\1 \2\24\2\16\2\8\5\0\11\8\5\16\3\24\2 \2(\0010\0018\1@\2P\2X\1h\2x\2\128\1\136\1\144\1\152\1\160\2\168\1\176\8\168\1\160\2\152\1\144\1\136\1\128\1x\2h\2X\1P\2@\0028\0010\1(\1 \2\24\2\16\3\8\5\0\n\8\5\16\2\24\3 \1(\0020\0018\1@\1H\1P\1X\1`\1h\1p\1x\1\128\1\136\1\144\1\152\1\160\1\168\1\176\2\184\8\176\2\168\1\160\1\152\1\144\1\136\1\128\1x\1p\1h\1`\1X\1P\1H\1@\0018\0010\1(\2 \1\24\3\16\2\8\5\0\n\8\5\16\2\24\2 \2(\0010\2@\2P\1X\1`\1h\1p\1x\1\128\1\136\1\144\1\152\1\160\1\168\1\176\1\184\2\192\2\200\4\192\2\184\2\176\1\168\1\160\1\152\1\144\1\136\1\128\1x\1p\1h\1`\1X\1P\1@\0020\2(\1 \2\24\2\16\2\8\5\0\n\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1P\1X\1`\1h\1x\1\128\1\136\1\144\1\152\1\160\1\176\2\184\1\192\1\200\2\208\6\200\2\192\1\184\1\176\2\160\1\152\1\144\1\136\1\128\1x\1h\1`\1X\1P\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\n\8\4\16\3\24\2 \1(\0010\0028\1@\1H\1P\1`\1h\1p\1x\1\128\1\144\1\152\1\160\1\168\1\176\1\184\1\192\1\200\1\208\2\216\6\208\2\200\1\192\1\184\1\176\1\168\1\160\1\152\1\144\1\128\1x\1p\1h\1`\1P\1H\1@\0018\0010\2(\1 \1\24\2\16\3\8\4\0\n\8\4\16\2\24\3 \1(\0010\2@\1H\1P\1X\1`\1h\1x\1\128\1\136\1\144\1\160\1\168\1\176\1\184\1\192\1\200\1\208\1\216\2\224\2\232\2\224\2\216\2\208\1\200\1\192\1\184\1\176\1\168\1\160\1\144\1\136\1\128\1x\1h\1`\1X\1P\1H\1@\0010\2(\1 \1\24\3\16\2\8\4\0\t\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1P\1X\1h\1p\1x\1\128\1\144\1\152\1\160\1\176\1\184\1\192\1\200\1\208\1\216\1\224\2\232\6\224\2\216\1\208\1\200\1\192\1\184\1\176\1\160\1\152\1\144\1\128\1x\1p\1h\1X\1P\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1P\1X\1h\1p\1\128\1\136\1\144\1\160\1\168\1\176\1\184\1\200\1\208\1\216\1\224\1\232\2\240\6\232\2\224\1\216\1\208\1\200\1\184\1\176\1\168\1\160\1\144\1\136\1\128\1p\1h\1X\1P\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1X\1`\1h\1x\1\128\1\136\1\152\1\160\1\176\1\184\1\192\1\200\1\208\1\216\1\224\1\232\1\240\2\248\4\240\2\232\1\224\1\216\1\208\1\200\1\192\1\184\1\176\1\160\1\152\1\136\1\128\1x\1h\1`\1X\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \1(\0020\0018\1@\1P\1X\1`\1h\1x\1\128\1\144\1\152\1\160\1\176\1\184\1\192\1\208\1\216\1\224\1\232\1\240\2\248\6\240\2\232\1\224\1\216\1\208\1\192\1\184\1\176\1\160\1\152\1\144\1\128\1x\1h\1`\1X\1P\1@\0018\0010\1(\2 \1\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \1(\0020\0018\1@\1P\1X\1`\1h\1x\1\128\1\144\1\152\1\168\1\176\1\184\1\200\1\208\1\216\1\224\1\232\1\240\2\248\1\255\4\248\1\240\2\232\1\224\1\216\1\208\1\200\1\184\1\176\1\168\1\152\1\144\1\128\1x\1h\1`\1X\1P\1@\0018\0010\1(\2 \1\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \1(\0010\0028\1@\1P\1X\1`\1p\1x\1\128\1\144\1\152\1\168\1\176\1\192\1\200\1\208\1\216\1\232\2\240\1\248\2\255\4\248\2\240\1\232\2\216\1\208\1\200\1\192\1\176\1\168\1\152\1\144\1\128\1x\1p\1`\1X\1P\1@\0018\0010\2(\1 \1\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \1(\0010\0028\1@\1P\1X\1`\1p\1x\1\128\1\144\1\152\1\168\1\176\1\192\1\200\1\208\1\216\1\232\2\240\1\248\2\255\4\248\2\240\1\232\2\216\1\208\1\200\1\192\1\176\1\168\1\152\1\144\1\128\1x\1p\1`\1X\1P\1@\0018\0010\2(\1 \1\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \1(\0020\0018\1@\1P\1X\1`\1h\1x\1\128\1\144\1\152\1\168\1\176\1\184\1\200\1\208\1\216\1\224\1\232\1\240\2\248\1\255\4\248\1\240\2\232\1\224\1\216\1\208\1\200\1\184\1\176\1\168\1\152\1\144\1\128\1x\1h\1`\1X\1P\1@\0018\0010\1(\2 \1\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \1(\0020\0018\1@\1P\1X\1`\1h\1x\1\128\1\144\1\152\1\160\1\176\1\184\1\192\1\208\1\216\1\224\1\232\1\240\2\248\6\240\2\232\1\224\1\216\1\208\1\192\1\184\1\176\1\160\1\152\1\144\1\128\1x\1h\1`\1X\1P\1@\0018\0010\1(\2 \1\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1X\1`\1h\1x\1\128\1\136\1\152\1\160\1\176\1\184\1\192\1\200\1\208\1\216\1\224\1\232\1\240\2\248\4\240\2\232\1\224\1\216\1\208\1\200\1\192\1\184\1\176\1\160\1\152\1\136\1\128\1x\1h\1`\1X\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1P\1X\1h\1p\1\128\1\136\1\144\1\160\1\168\1\176\1\184\1\200\1\208\1\216\1\224\1\232\2\240\6\232\2\224\1\216\1\208\1\200\1\184\1\176\1\168\1\160\1\144\1\136\1\128\1p\1h\1X\1P\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\8\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1P\1X\1h\1p\1x\1\128\1\144\1\152\1\160\1\176\1\184\1\192\1\200\1\208\1\216\1\224\2\232\6\224\2\216\1\208\1\200\1\192\1\184\1\176\1\160\1\152\1\144\1\128\1x\1p\1h\1X\1P\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\t\8\4\16\2\24\3 \1(\0010\2@\1H\1P\1X\1`\1h\1x\1\128\1\136\1\144\1\160\1\168\1\176\1\184\1\192\1\200\1\208\1\216\2\224\2\232\2\224\2\216\2\208\1\200\1\192\1\184\1\176\1\168\1\160\1\144\1\136\1\128\1x\1h\1`\1X\1P\1H\1@\0010\2(\1 \1\24\3\16\2\8\4\0\n\8\4\16\3\24\2 \1(\0010\0028\1@\1H\1P\1`\1h\1p\1x\1\128\1\144\1\152\1\160\1\168\1\176\1\184\1\192\1\200\1\208\2\216\6\208\2\200\1\192\1\184\1\176\1\168\1\160\1\152\1\144\1\128\1x\1p\1h\1`\1P\1H\1@\0018\0010\2(\1 \1\24\2\16\3\8\4\0\n\8\5\16\2\24\2 \2(\0010\0018\1@\1H\1P\1X\1`\1h\1x\1\128\1\136\1\144\1\152\1\160\1\176\2\184\1\192\1\200\2\208\6\200\2\192\1\184\1\176\2\160\1\152\1\144\1\136\1\128\1x\1h\1`\1X\1P\1H\1@\0018\0010\1(\1 \2\24\2\16\2\8\5\0\n\8\5\16\2\24\2 \2(\0010\2@\2P\1X\1`\1h\1p\1x\1\128\1\136\1\144\1\152\1\160\1\168\1\176\1\184\2\192\2\200\4\192\2\184\2\176\1\168\1\160\1\152\1\144\1\136\1\128\1x\1p\1h\1`\1X\1P\1@\0020\2(\1 \2\24\2\16\2\8\5\0\n\8\5\16\2\24\3 \1(\0020\0018\1@\1H\1P\1X\1`\1h\1p\1x\1\128\1\136\1\144\1\152\1\160\1\168\1\176\2\184\8\176\2\168\1\160\1\152\1\144\1\136\1\128\1x\1p\1h\1`\1X\1P\1H\1@\0018\0010\1(\2 \1\24\3\16\2\8\5\0\n\8\5\16\3\24\2 \2(\0010\0018\1@\2P\2X\1h\2x\2\128\1\136\1\144\1\152\1\160\2\168\1\176\8\168\1\160\2\152\1\144\1\136\1\128\1x\2h\2X\1P\2@\0028\0010\1(\1 \2\24\2\16\3\8\5\0\11\8\5\16\2\24\2 \2(\0010\0028\1@\1H\1P\1X\1`\1h\2x\2\128\1\136\1\144\2\152\1\160\3\168\4\160\3\152\1\144\2\136\1\128\1x\2h\2`\1X\1P\1H\1@\0018\0010\2(\1 \2\24\2\16\2\8\5\0\12\8\5\16\3\24\2 \2(\0010\0028\1@\1H\1P\1X\1`\1h\2p\1x\1\128\2\136\1\144\2\152\8\144\2\136\1\128\2x\1p\1h\2`\1X\1P\1H\1@\0018\0010\2(\1 \2\24\2\16\3\8\5\0\12\8\6\16\2\24\2 \2(\0020\0018\1@\2H\1P\1X\1`\2h\1p\1x\2\128\2\136\2\144\6\136\2\128\2x\2p\1h\1`\2X\1P\1H\1@\0028\0010\1(\2 \2\24\2\16\2\8\6\0\r\8\5\16\2\24\3 \2(\0010\0028\1@\2H\1P\1X\2`\1h\2p\1x\2\128\nx\2p\1h\2`\1X\2P\1H\1@\0028\0010\2(\1 \2\24\3\16\2\8\5\0\14\8\6\16\2\24\3 \2(\0010\0028\1@\2H\1P\2X\1`\2h\2p\2x\8p\2h\2`\2X\1P\2H\1@\0028\0010\2(\1 \2\24\3\16\2\8\6\0\14\8\6\16\3\24\2 \3(\0010\0028\1@\2H\1P\2X\3`\1h\5p\2h\5`\1X\3P\2H\1@\0028\0010\2(\1 \3\24\2\16\3\8\6\0\15\8\6\16\3\24\2 \3(\0010\0028\2@\2H\1P\3X\3`\8X\3P\3H\1@\0028\0020\2(\1 \3\24\2\16\3\8\6\0\16\8\6\16\3\24\3 \3(\0010\0038\1@\3H\2P\3X\8P\3H\2@\0038\0010\3(\1 \3\24\3\16\3\8\6\0\17\8\6\16\3\24\3 \3(\0020\0028\2@\3H\4P\6H\4@\0038\0020\2(\2 \3\24\3\16\3\8\6\0\18\8\7\16\3\24\3 \3(\0020\0038\3@\0148\0030\3(\2 \3\24\3\16\3\8\7\0\19\8\7\16\3\24\4 \3(\0030\0038\0140\3(\3 \3\24\4\16\3\8\7\0\21\8\7\16\4\24\3 \4(\0040\14(\4 \4\24\3\16\4\8\7\0\23\8\7\16\4\24\4 \5(\0060\4(\6 \5\24\4\16\4\8\7\0\25\8\8\16\3\24\6 \7(\6 \7\24\6\16\3\8\8\0\26\8\t\16\5\24\6 \14\24\6\16\5\8\t\0\27\8\n\16\5\24\22\16\5\8\n\0\30\8\n\16\7\24\14\16\7\8\n\0!\8\11\16\24\8\11\0#\8\15\16\14\8\15\0&\8(\0*\8$\0.\8 \0004\8\24\0>\8\12\0\255\0c",
	}

	r5.soundtip = {
		w = 13,
		h = 26,
		data = "\142\1\0\1\3\1\1\1\0\t\255\1\140\1\0\1\3\1\1\1\0\8\251\1\255\1\141\1\0\1\4\1\1\1\0\7\255\1\251\1\255\1\141\1\0\1\4\1\1\1\0\6\255\2\251\1\255\1\141\1\0\1\3\1\1\1\0\5\255\3\251\1\255\1\141\1\0\1\4\1\1\1\0\4\255\4\250\1\255\1\127\1\0\1\5\1\0\4\255\4\254\1\251\1\255\1r\1\0\1\4\1\0\3\255\5\254\1\252\1\255\1r\1\0\1\4\1\0\2\255\6\254\1\251\1\255\1r\1\0\1\4\1\0\1\255\7\254\1\251\1\255\1s\1\0\1\5\1\255\8\254\1\251\1\255\1p\1\0\1\255\t\254\1\252\1\255\1\134\1\255\n\251\1\255\1\159\1\255\t\251\1\255\1\138\1\0\1\255\8\251\1\255\1\141\1\0\1\3\1\255\7\251\1\255\1\141\1\0\1\3\1\1\1\255\6\251\1\255\1\141\1\0\1\4\1\1\1\0\1\255\5\251\1\255\1\141\1\0\1\4\1\1\1\0\2\255\4\251\1\255\1\141\1\0\1\4\1\1\1\0\3\255\3\251\1\255\1\141\1\0\1\4\1\1\1\0\4\255\2\251\1\255\1\141\1\0\1\4\1\1\1\0\5\255\1\251\1\255\1\141\1\0\1\4\1\1\1\0\6\251\1\255\1\141\1\0\1\4\1\1\1\0\7\255\1\140\1\0\1\3\1\1\1\0\8\142\1\0\1\3\1\1\1\0\t",
	}

	r5.soundtipGlow = {
		w = 18,
		h = 35,
		data = "\1\5\0\r\2\1\3\4\2\1\1\1\0\11\6\1\7\1\t\2\8\1\6\1\3\1\2\1\1\1\0\t\12\1\15\1\19\1\20\1\18\1\14\1\8\1\4\1\2\1\1\1\0\8\21\1\27\1#\1&\1$\1\28\1\19\1\n\1\5\1\2\1\1\1\0\7\31\1*\0017\1>\1<\0012\1#\1\21\1\11\1\5\1\2\1\1\1\0\6)\0019\1L\1Z\1[\1O\1;\1'\1\22\1\11\1\5\1\2\1\0\0061\1E\1`\1t\1{\1p\1Z\1?\1'\1\22\1\11\1\5\1\2\1\0\0056\1N\1n\1\138\1\152\1\146\1|\1_\1@\1'\1\21\1\11\1\4\1\2\1\0\0048\1S\1x\1\155\1\176\1\177\1\158\1\129\1_\1?\1&\1\21\1\n\1\4\1\2\1\0\3:\1W\1~\1\165\1\193\1\200\1\189\1\162\1\129\1_\1>\1&\1\21\1\n\1\4\1\2\1\0\2:\1X\1\128\1\172\1\203\1\217\1\212\1\193\1\162\1\128\1]\1>\1&\1\20\1\n\1\4\1\2\1\1\1:\1X\1\130\1\174\1\209\1\228\1\229\1\217\1\193\1\162\1\127\1]\1>\1%\1\20\1\n\1\4\1\2\1:\1X\1\130\1\176\1\211\1\233\1\240\1\234\1\217\1\193\1\161\1~\1\\\1=\1$\1\20\1\t\1\4\1:\1X\1\130\1\176\1\213\1\236\1\246\1\244\1\235\1\217\1\192\1\160\1}\1Y\0019\1!\1\17\1\8\1:\1X\1\130\1\176\1\213\1\237\1\248\1\250\1\246\1\235\1\216\1\189\1\155\1u\1O\1/\1\25\1\r\1:\1X\1\130\1\176\1\213\1\238\1\250\1\253\1\252\1\245\1\231\1\209\1\177\1\137\1a\1;\1 \1\17\1:\1X\1\130\1\176\1\213\1\238\1\250\1\255\2\248\1\236\1\216\1\185\1\145\1g\1@\1#\1\19\1:\1X\1\130\1\176\1\213\1\238\1\250\1\253\1\252\1\245\1\232\1\210\1\179\1\139\1b\1<\1!\1\17\1:\1X\1\130\1\176\1\213\1\238\1\248\1\251\1\247\1\236\1\218\1\192\1\158\1w\1Q\0011\1\26\1\r\1:\1X\1\130\1\176\1\213\1\236\1\246\1\245\1\236\1\219\1\195\1\163\1\128\1]\1;\1\"\1\17\1\t\1:\1X\1\130\1\176\1\211\1\234\1\240\1\235\1\219\1\195\1\164\1\130\1`\1?\1&\1\20\1\n\1\5\1:\1X\1\130\1\174\1\209\1\228\1\230\1\218\1\195\1\164\1\131\1`\1@\1'\1\22\1\11\1\5\1\2\1:\1X\1\128\1\172\1\203\1\217\1\213\1\194\1\164\1\131\1`\1A\1(\1\22\1\11\1\5\1\2\1\1\1:\1W\1~\1\165\1\193\1\200\1\189\1\163\1\131\1`\1A\1(\1\22\1\11\1\5\1\2\1\1\1\0\0018\1S\1x\1\155\1\176\1\177\1\158\1\129\1`\1A\1(\1\22\1\11\1\5\1\2\1\1\1\0\0026\1N\1n\1\138\1\152\1\146\1|\1_\1A\1(\1\22\1\11\1\5\1\2\1\1\1\0\0031\1E\1`\1t\1{\1p\1Z\1?\1(\1\22\1\11\1\5\1\2\1\1\1\0\4)\0019\1L\1Z\1[\1O\1;\1'\1\22\1\11\1\5\1\2\1\1\1\0\5\31\1*\0017\1>\1<\0012\1#\1\21\1\11\1\5\1\2\1\1\1\0\6\21\1\27\1#\1&\1$\1\28\1\19\1\n\1\5\1\2\1\1\1\0\7\12\1\15\1\19\1\20\1\18\1\14\1\8\1\4\1\2\1\1\1\0\8\6\1\7\1\t\2\8\1\6\1\3\1\2\1\1\1\0\t\2\1\3\4\2\1\1\1\0\11\1\5\0\r",
	}

	local r7_3 = {}
	bit32.bor(r800002, 4125359976)
	r7_3.w = 31
	r7_3.h = 60
	r7_3.data = "\0\8\6\15\0\14\6\19\0\n\6\8\12\7\6\8\0\7\6\5\12\15\6\5\0\5\6\5\12\3\19\11\12\3\6\5\0\3\6\4\12\3\19\3\25\t\19\3\12\3\6\4\0\1\6\4\12\3\19\2\25\2\31\t\25\2\19\2\12\3\6\7\12\2\19\2\25\2\31\2&\t\31\2\25\2\19\2\12\2\6\5\12\2\19\2\25\1\31\2&\1,\0023\7,\2&\1\31\2\25\1\19\2\12\2\6\3\12\2\19\2\25\1\31\1&\2,\0013\0019\4?\0019\0043\1,\1&\2\31\1\25\1\19\2\12\2\6\2\12\1\19\2\25\1\31\1&\1,\0013\0019\1?\2F\3L\1F\3?\0029\0013\1,\1&\1\31\1\25\1\19\2\12\1\6\1\12\2\19\1\25\1\31\1&\1,\0013\0019\1?\1F\1L\1R\3Y\1R\3L\1F\1?\0019\0013\1,\1&\1\31\1\25\1\19\1\12\3\19\2\25\1\31\1,\0013\0019\1?\1L\1R\1Y\1_\3f\1_\3Y\1R\1L\1?\0019\0013\1,\1\31\1\25\1\19\2\12\2\19\1\25\1\31\1&\1,\0019\1F\1L\1Y\1_\1f\1l\3r\1l\3f\1_\1Y\1L\1F\0019\1,\1&\1\31\1\25\1\19\1\12\2\19\1\25\1\31\1,\0013\1?\1L\1R\1_\1l\1r\1y\3\127\1y\3r\1l\1_\1R\1L\1?\0013\1,\1\31\1\25\1\19\1\12\1\19\1\25\1\31\1&\0013\0019\1F\1R\1_\1l\1r\1\127\1\133\1\140\5\133\1\127\1r\1l\1_\1R\1F\0019\0013\1&\1\31\1\25\1\19\2\25\1\31\1,\0019\1?\1L\1Y\1f\1r\1\127\1\133\1\146\1\153\2\159\1\153\2\146\1\133\1\127\1r\1f\1Y\1L\1?\0019\1,\1\31\1\25\1\19\2\25\1&\1,\0019\1F\1R\1f\1l\1\127\1\140\1\146\1\159\1\165\2\172\1\165\2\159\1\146\1\140\1\127\1l\1f\1R\1F\0019\1,\1&\1\25\1\19\1\25\1\31\1&\0013\1?\1L\1Y\1l\1y\1\140\1\153\1\159\1\172\1\178\2\184\1\178\2\172\1\159\1\153\1\140\1y\1l\1Y\1L\1?\0013\1&\1\31\1\25\2\31\1,\0013\1F\1R\1_\1r\1\127\1\146\1\159\1\172\1\178\1\191\2\197\1\191\2\178\1\172\1\159\1\146\1\127\1r\1_\1R\1F\0013\1,\1\31\1\25\2\31\1,\0019\1F\1Y\1f\1y\1\133\1\153\1\172\1\178\1\191\1\197\2\204\1\197\2\191\1\178\1\172\1\153\1\133\1y\1f\1Y\1F\0019\1,\1\31\1\25\2&\1,\0019\1L\1Y\1l\1\127\1\140\1\165\1\178\1\191\1\197\1\210\2\216\1\210\2\197\1\191\1\178\1\165\1\140\1\127\1l\1Y\1L\0019\1,\1&\1\25\2&\0013\1?\1L\1_\1l\1\133\1\146\1\172\1\184\1\197\1\210\1\216\2\223\1\216\2\210\1\197\1\184\1\172\1\146\1\133\1l\1_\1L\1?\0013\1&\1\25\1\31\1&\0013\1?\1R\1_\1r\1\133\1\153\1\178\1\191\1\204\1\216\1\229\2\235\1\229\2\216\1\204\1\191\1\178\1\153\1\133\1r\1_\1R\1?\0013\1&\1\31\2&\0013\1?\1R\1f\1r\1\140\1\159\1\178\1\197\1\210\1\223\1\235\2\242\1\235\2\223\1\210\1\197\1\178\1\159\1\140\1r\1f\1R\1?\0013\1&\1\31\2,\0013\1?\1R\1f\1y\1\146\1\159\1\184\1\204\1\216\1\229\1\235\2\242\1\235\2\229\1\216\1\204\1\184\1\159\1\146\1y\1f\1R\1?\0013\1,\1\31\2,\0019\1F\1R\1f\1y\1\146\1\165\1\191\1\204\1\216\1\229\1\242\2\248\1\242\2\229\1\216\1\204\1\191\1\165\1\146\1y\1f\1R\1F\0019\1,\1\31\2,\0019\1F\1Y\1f\1y\1\146\1\165\1\191\1\210\1\223\1\235\1\248\2\255\1\248\2\235\1\223\1\210\1\191\1\165\1\146\1y\1f\1Y\1F\0019\1,\1\31\2,\0019\1F\1Y\1l\1\127\1\146\1\165\1\191\1\210\1\223\1\235\1\248\2\255\1\248\2\235\1\223\1\210\1\191\1\165\1\146\1\127\1l\1Y\1F\0019\1,\1\31\2,\0019\1F\1Y\1l\1\127\1\146\1\165\1\191\1\210\1\223\1\235\1\248\2\255\1\248\2\235\1\223\1\210\1\191\1\165\1\146\1\127\1l\1Y\1F\0019\1,\1\31\2,\0019\1F\1Y\1l\1\127\1\146\1\165\1\191\1\210\1\223\1\235\1\248\2\255\1\248\2\235\1\223\1\210\1\191\1\165\1\146\1\127\1l\1Y\1F\0019\1,\1\31\2,\0019\1F\1Y\1l\1\127\1\146\1\165\1\191\1\210\1\223\1\235\1\248\2\255\1\248\2\235\1\223\1\210\1\191\1\165\1\146\1\127\1l\1Y\1F\0019\1,\1\31\2,\0019\1F\1Y\1f\1y\1\146\1\165\1\191\1\210\1\223\1\235\1\248\2\255\1\248\2\235\1\223\1\210\1\191\1\165\1\146\1y\1f\1Y\1F\0019\1,\1\31\2,\0019\1F\1R\1f\1y\1\146\1\165\1\191\1\204\1\216\1\229\1\242\2\248\1\242\2\229\1\216\1\204\1\191\1\165\1\146\1y\1f\1R\1F\0019\1,\1\31\2,\0013\1?\1R\1f\1y\1\146\1\159\1\184\1\204\1\216\1\229\1\235\2\242\1\235\2\229\1\216\1\204\1\184\1\159\1\146\1y\1f\1R\1?\0013\1,\1\31\2&\0013\1?\1R\1f\1r\1\140\1\159\1\178\1\197\1\210\1\223\1\235\2\242\1\235\2\223\1\210\1\197\1\178\1\159\1\140\1r\1f\1R\1?\0013\1&\1\31\2&\0013\1?\1R\1_\1r\1\133\1\153\1\178\1\191\1\204\1\216\1\229\2\235\1\229\2\216\1\204\1\191\1\178\1\153\1\133\1r\1_\1R\1?\0013\1&\1\31\1\25\1&\0013\1?\1L\1_\1l\1\133\1\146\1\172\1\184\1\197\1\210\1\216\2\223\1\216\2\210\1\197\1\184\1\172\1\146\1\133\1l\1_\1L\1?\0013\1&\1\25\2&\1,\0019\1L\1Y\1l\1\127\1\140\1\165\1\178\1\191\1\197\1\210\2\216\1\210\2\197\1\191\1\178\1\165\1\140\1\127\1l\1Y\1L\0019\1,\1&\1\25\2\31\1,\0019\1F\1Y\1f\1y\1\133\1\153\1\172\1\178\1\191\1\197\2\204\1\197\2\191\1\178\1\172\1\153\1\133\1y\1f\1Y\1F\0019\1,\1\31\1\25\2\31\1,\0013\1F\1R\1_\1r\1\127\1\146\1\159\1\172\1\178\1\191\2\197\1\191\2\178\1\172\1\159\1\146\1\127\1r\1_\1R\1F\0013\1,\1\31\1\25\2\31\1&\0013\1?\1L\1Y\1l\1y\1\140\1\153\1\159\1\172\1\178\2\184\1\178\2\172\1\159\1\153\1\140\1y\1l\1Y\1L\1?\0013\1&\1\31\1\25\1\19\1\25\1&\1,\0019\1F\1R\1f\1l\1\127\1\140\1\146\1\159\1\165\2\172\1\165\2\159\1\146\1\140\1\127\1l\1f\1R\1F\0019\1,\1&\1\25\1\19\2\25\1\31\1,\0019\1?\1L\1Y\1f\1r\1\127\1\133\1\146\1\153\2\159\1\153\2\146\1\133\1\127\1r\1f\1Y\1L\1?\0019\1,\1\31\1\25\1\19\2\25\1\31\1&\0013\0019\1F\1R\1_\1l\1r\1\127\1\133\1\140\5\133\1\127\1r\1l\1_\1R\1F\0019\0013\1&\1\31\1\25\1\19\1\12\1\19\1\25\1\31\1,\0013\1?\1L\1R\1_\1l\1r\1y\3\127\1y\3r\1l\1_\1R\1L\1?\0013\1,\1\31\1\25\1\19\1\12\2\19\1\25\1\31\1&\1,\0019\1F\1L\1Y\1_\1f\1l\3r\1l\3f\1_\1Y\1L\1F\0019\1,\1&\1\31\1\25\1\19\1\12\2\19\2\25\1\31\1,\0013\0019\1?\1L\1R\1Y\1_\3f\1_\3Y\1R\1L\1?\0019\0013\1,\1\31\1\25\1\19\2\12\3\19\1\25\1\31\1&\1,\0013\0019\1?\1F\1L\1R\3Y\1R\3L\1F\1?\0019\0013\1,\1&\1\31\1\25\1\19\1\12\2\6\1\12\1\19\2\25\1\31\1&\1,\0013\0019\1?\2F\3L\1F\3?\0029\0013\1,\1&\1\31\1\25\1\19\2\12\1\6\2\12\2\19\2\25\1\31\1&\2,\0013\0019\4?\0019\0043\1,\1&\2\31\1\25\1\19\2\12\2\6\3\12\2\19\2\25\1\31\2&\1,\0023\7,\2&\1\31\2\25\1\19\2\12\2\6\5\12\2\19\2\25\2\31\2&\t\31\2\25\2\19\2\12\2\6\7\12\3\19\2\25\2\31\t\25\2\19\2\12\3\6\4\0\1\6\4\12\3\19\3\25\t\19\3\12\3\6\4\0\3\6\5\12\3\19\11\12\3\6\5\0\5\6\5\12\15\6\5\0\7\6\8\12\7\6\8\0\n\6\19\0\14\6\15\0\8"
	r5.spinGlow = r7_3

	r5.tickGlow = {
		w = 11,
		h = 78,
		data = "\0\1\1\2\3\2\5\1\3\2\1\2\0\1\1\1\3\1\7\1\11\1\r\1\16\1\r\1\11\1\7\1\3\1\1\1\3\1\7\1\16\1\26\1#\1'\1#\1\26\1\16\1\7\1\3\1\5\1\14\1\31\0012\1C\1J\1C\0012\1\31\1\14\1\5\1\t\1\24\0012\1Q\1m\1x\1m\1Q\0012\1\24\1\t\1\r\1!\1D\1q\1\150\1\167\1\150\1q\1D\1!\1\r\1\16\1*\1U\1\139\1\186\1\206\1\186\1\139\1U\1*\1\16\1\18\0010\1`\1\158\1\210\1\232\1\210\1\158\1`\0010\1\18\1\20\0012\1f\1\167\1\223\1\247\1\223\1\167\1f\0012\1\20\0024\1j\1\171\1\228\1\253\1\228\1\171\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\173\1\230\1\255\1\230\1\173\1j\0014\1\20\0024\1j\1\171\1\228\1\253\1\228\1\171\1j\0014\1\20\0022\1f\1\167\1\223\1\247\1\223\1\167\1f\0012\1\20\1\18\0010\1`\1\158\1\210\1\232\1\210\1\158\1`\0010\1\18\1\16\1*\1U\1\139\1\186\1\206\1\186\1\139\1U\1*\1\16\1\r\1!\1D\1q\1\150\1\167\1\150\1q\1D\1!\1\r\1\t\1\24\0012\1Q\1m\1x\1m\1Q\0012\1\24\1\t\1\5\1\14\1\31\0012\1C\1J\1C\0012\1\31\1\14\1\5\1\3\1\7\1\16\1\26\1#\1'\1#\1\26\1\16\1\7\1\3\1\1\1\3\1\7\1\11\1\r\1\16\1\r\1\11\1\7\1\3\1\1\1\0\1\1\2\3\2\5\1\3\2\1\2\0\1",
	}

	r5.tooltipArrow = {
		w = 7,
		h = 12,
		data = "\0\3\2\1\3\1\0\1d\1\0\2\2\1\0\2\151\1\255\1\0\1\3\1\0\1\17\1\169\1\255\1\253\1\4\1\0\1\25\1\202\1\255\1\251\1\255\1\0\0013\1\230\1\255\1\251\1\255\2k\1\235\1\255\1\252\1\255\3\161\1\255\1\252\1\253\1\255\3\0\1b\1\255\2\253\1\255\2\4\1\0\1G\1\238\1\255\1\252\1\255\1\0\1\4\1\0\0015\1\219\1\255\1\252\1\0\2\4\1\0\1\18\1\200\1\255\1\0\3\3\1\0\1\15\1\160\1",
	}

	r3.glyphs = r5
	r3.shadow = { pad = 28, slice = 38 }
	return r3
end
end)()

_registry["ui/inputguard"] = (function()

return function(p)
				local p, J, O = {}, {}, false
				p.add = function(u)
					if typeof(u) ~= "table" then
						return
					end
					table.insert(J, u)
					local F = O and typeof(u.block) == "function"
					if F then
						pcall(u.block)
					end
				end
				p.arm = function()
					local u = O
					if u then
						return
					end
					O = true
					for u, u in ipairs(J) do
						if typeof(u.block) == "function" then
							pcall(u.block)
						end
					end
				end
				p.disarm = function()
					local u = O
					if not u then
						return
					end
					O = false
					for u, u in ipairs(J) do
						if typeof(u.release) == "function" then
							pcall(u.release)
						end
					end
				end
				p.isArmed = function()
					local J = O
					return J
				end
				return p
			end
end)()

_registry["ui/keybind"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/skin")
				local u = p("ui/create")
				local F = p("ui/icon")
				local f = p("ui/metrics")
				local o = p("ui/motion")
				local Z = p("ui/popup")
				local i = p("ui/theme")
				local y = p("ui/font")
				local P = p("ui/zindex")
				local b = p("core/service")
				local p, I, h =
					b.get("UserInputService"),
					{ MODES = { "hold", "toggle", "always" }, IDLE_ROLE = "dim" },
					{}
				I.bindings = function()
					return h
				end
				local A
				local T, r = false, {}
				I.label = function(S)
					if not S then
						return "None"
					end
					local c = r[S]
					if c then
						return c
					end
					c = tostring(S)
					c = (c:match("([^%.]+)$") or c)
						:gsub("^MouseButton", "mb")
						:gsub("^Left", "")
						:gsub("^Right", "r")
						:lower()
					r[S] = c
					return c
				end
				local r = {}
				r.__index = r
				r.Get = function(S)
					return S.key
				end
				r.setMode = function(S, c, R)
					local e = S.modes or I.MODES
					if not table.find(e, c) then
						return
					end
					S.mode = c
					if c == "always" and S.option and S.option.Set then
						S.option:Set(true, R)
					end
					S:repaint()
				end
				r.setKey = function(S, c)
					S.key = c
					S:repaint()
				end
				r.repaint = function(S)
					if not S.icon then
						return
					end
					local c, R, e, G, q = S.mode == "always" or S.key ~= nil, o.to, S.icon, o.HOVER_IN, {}
					q.ImageColor3 = c and i.get() or O.get(I.IDLE_ROLE)
					R(e, G, q)
				end
				r.fire = function(S, c)
					local R = S.option
					if not R or not R.Set then
						return
					end
					if S.mode == "hold" then
						R:Set(c)
					elseif S.mode == "toggle" and c then
						R:Set(not R:Get())
					end
				end
				local function S(c, R)
					if not c.key then
						return false
					end
					return R.KeyCode == c.key or R.UserInputType == c.key
				end
				local c = b.get("TextChatService")
				I.typing = function()
					local b, R = pcall(function()
						return p:GetFocusedTextBox()
					end)
					if b and R then
						return true
					end
					if not c then
						return false
					end
					R, b = pcall(function()
						local e = c:FindFirstChildOfClass("ChatInputBarConfiguration")
						return e ~= nil and e.IsFocused == true
					end)
					return R and b == true
				end
				local function b()
					local c = T
					if c then
						return
					end
					T = true
					J.signal(p.InputBegan, function(T, c)
						c = A
						if c then
							A:capture(T)
							return
						end
						if I.typing() then
							return
						end
						for c, c in ipairs(h) do
							if S(c, T) then
								c:fire(true)
							end
						end
					end, "keybind/down")
					J.signal(p.InputEnded, function(p)
						local T = A
						if T then
							return
						end
						for T, T in ipairs(h) do
							if S(T, p) then
								T:fire(false)
							end
						end
					end, "keybind/up")
				end
				I.capture = function(p)
					if typeof(p) ~= "function" then
						return
					end
					A = {
						capture = function(T, S)
							local c, R = S.UserInputType == Enum.UserInputType.Keyboard
							if c then
								T = S.KeyCode == Enum.KeyCode.Escape
								if T then
									A = nil
									p(nil)
									return
								end
								R = S.KeyCode
							else
								if
									S.UserInputType.Name:match("^MouseButton")
									and S.UserInputType ~= Enum.UserInputType.MouseButton1
								then
									R = S.UserInputType
								else
									return
								end
							end
							A = nil
							p(R)
						end,
					}
					b()
					return I
				end
				r.capture = function(p, T)
					local S
					if T.UserInputType == Enum.UserInputType.Keyboard then
						S = if T.KeyCode ~= Enum.KeyCode.Escape then T.KeyCode else S
					else
						if
							T.UserInputType.Name:match("^MouseButton")
							and T.UserInputType ~= Enum.UserInputType.MouseButton1
						then
							S = T.UserInputType
						else
							return
						end
					end
					A = nil
					p:setKey(S)
					if p.onCapture then
						p.onCapture()
					end
				end
				local p = 22
				local function T(S, c, R, e)
					local G = u.new(
						"TextButton",
						{
							Name = "Row",
							LayoutOrder = c,
							Size = UDim2.new(1, 0, 0, p),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = "",
							ZIndex = S.ZIndex,
							Parent = S,
						}
					)
					local p, c = u.new, {}
					c.CornerRadius, c.Parent = UDim.new(0, f.corner), G
					p("UICorner", c)
					local p = u.new(
						"TextLabel",
						{
							Name = "Label",
							Position = UDim2.fromOffset(10, 0),
							Size = UDim2.new(1, -20, 1, 0),
							BackgroundTransparency = 1,
							Text = R,
							TextSize = f.textSize - 1,
							skin = I.IDLE_ROLE,
							FontFace = y.face(),
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = S.ZIndex + 1,
							Parent = G,
						}
					)
					J.signal(G.InputBegan, function(y)
						if y.UserInputType == Enum.UserInputType.MouseButton1 then
							Z.hold()
							e()
						elseif y.UserInputType == Enum.UserInputType.MouseMovement then
							if Z.blocks(G) then
								return
							end
							o.to(G, o.HOVER_IN, { BackgroundTransparency = 0.92 })
						end
					end, "keybind/row")
					J.signal(G.InputEnded, function(y)
						if y.UserInputType == Enum.UserInputType.MouseMovement then
							o.to(G, o.HOVER_OUT, { BackgroundTransparency = 1 })
						end
					end, "keybind/rowout")
					return p,
						function(y)
							local S, c, R = o.to, o.HOVER_IN, {}
							R.TextColor3 = y and i.get() or O.get(I.IDLE_ROLE)
							S(p, c, R)
						end
				end
				local function p(O, o)
					return (
						u.new(
							"Frame",
							{
								Name = "Divider",
								LayoutOrder = o,
								Size = UDim2.new(1, 0, 0, 1),
								skin = "border",
								BorderSizePixel = 0,
								ZIndex = O.ZIndex,
								Parent = O,
							}
						)
					)
				end
				r.buildPanel = function(O)
					if O.popup then
						return O.popup
					end
					local o = Z.new(O.anchor)
					if not o then
						return nil
					end
					O.popup = o
					local Z = {}
					local function y()
						O.keyRow.Text = string.format("key: %s", I.label(O.key))
						for S, c in pairs(Z) do
							c(S == O.mode)
						end
					end
					O.keyRow = T(o.content, 0, "", function()
						local S = A
						if S then
							A = nil
						end
						A = O
						O.keyRow.Text = "press any key..."
						O.keyRow.TextColor3 = i.get()
					end)
					O.onCapture = y
					p(o.content, 1)
					for p, i in ipairs(O.modes or I.MODES) do
						local S, S = T(o.content, p + 1, i, function()
							O:setMode(i)
							y()
						end)
						Z[i] = S
					end
					o.onClose = function()
						local p = A == O
						if p then
							A = nil
							y()
						end
						if O.onPopupClose then
							O.onPopupClose()
						end
					end
					y()
					return o
				end
				I.attach = function(p, O, o, Z, i)
					i = typeof(i) == "table" and i or {}
					local y, A, T =
						F.size(),
						(p.zbase or P.WIDGET) + 3,
						setmetatable(
							{
								option = p,
								mode = i.mode or "toggle",
								modes = typeof(i.modes) == "table" and i.modes or nil,
								key = i.key,
							},
							r
						)
					local i = u.new(
						"Frame",
						{
							Name = "Keybind",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -Z - f.controlX, 0, p.adornY or f.row // 2),
							Size = UDim2.fromOffset(y, y),
							BackgroundTransparency = 1,
							ZIndex = A,
							Parent = o,
						}
					)
					T.anchor = i
					T.icon = u.new(
						"ImageLabel",
						{
							Name = "Hint",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							skin = I.IDLE_ROLE,
							ImageContent = F.get("mouseRight"),
							ZIndex = A,
							Parent = i,
						}
					)
					J.signal(O.InputBegan, function(p)
						if p.UserInputType == Enum.UserInputType.MouseButton2 then
							local p = T:buildPanel()
							if p then
								p:Toggle()
							end
						end
					end, "keybind/open")
					table.insert(h, T)
					b()
					T:repaint()
					return T
				end
				return I
			end
end)()

_registry["ui/library"] = (function()

return function(p)
				local J = p("ui/chrome/account")
				local O = p("ui/connect")
				local u = p("ui/chrome/cursor")
				local F = p("ui/chrome/footer")
				local f = p("ui/create")
				local o = p("ui/inputguard")
				local Z = p("ui/icon")
				local i = p("ui/keybind")
				local y = p("ui/chrome/keybinds")
				local P = p("ui/chrome/beam")
				local b = p("ui/chrome/aurora")
				local I = p("ui/backdrop")
				local h = p("ui/chrome/bubbles")
				local A = p("ui/chrome/edge")
				local T, r = p("ui/components/base"), p("ui/components/button")
				local S = p("ui/components/color")
				local c = p("ui/components/divider")
				local R = p("ui/components/label")
				local e = p("ui/components/list")
				local G = p("ui/components/order")
				local q = p("ui/metrics")
				local w = p("ui/mount")
				local H = p("ui/motion")
				local Q = p("ui/popup")
				local Y = p("ui/chrome/rainbow")
				local E = p("ui/chrome/reveal")
				local s = p("ui/chrome/search")
				local v = p("ui/shadow")
				local m = p("ui/skin")
				local B = p("ui/components/slider")
				local g = p("ui/chrome/switch")
				local k = p("ui/chrome/subtabs")
				local z = p("ui/components/box")
				local l = p("ui/theme")
				local D = p("ui/chrome/tilt")
				local K = p("ui/components/toggle")
				local C = p("ui/tooltip")
				local a = p("ui/font")
				local j = p("ui/warning")
				local V = p("ui/chrome/watermark")
				local N = p("ui/chrome/wordmark")
				local W = p("ui/zindex")
				local U = p("core/service")
				local _ = U.get("RunService")
				local x = U.get("UserInputService")
				local d
				d = {
					title = "menu",
					query = "",
					onChanged = nil,
					onFlagWrite = nil,
					account = nil,
					tabs = {},
					options = {},
					flags = {},
					open = false,
					currentTab = nil,
					hasInit = false,
					base = nil,
					main = nil,
					rule = nil,
					tabRow = nil,
					beamHost = nil,
					headerShadow = nil,
					tabHighlight = nil,
					columnHolder = nil,
					geometry = {
						windowWidth = nil,
						windowHeight = 660,
						windowCorner = 6,
						backdropFade = 0.88,
						windowX = 100,
						windowY = 46,
						ruleY = 62,
						tabGap = 10,
						tabBand = 30,
						titleY = 28,
						inset = 6,
						headerPad = 14,
						tabPad = 5,
						tabIconGap = 6,
						tabSpacing = 14,
						tabIconSize = 14,
						columnWidth = 312,
						columnStep = 342,
						columnTop = 2,
						holderX = 5,
						holderBottom = 14,
						headerShadow = 9,
						headerShadowFade = 0.72,
						cardGap = 18,
						cardPadTop = 14,
						cardPadBottom = 10,
						brandSize = 28,
						tabSize = 15,
						sectionSize = 15,
					},
					hasSubTabs = function()
						for L, L in ipairs(d.tabs) do
							if L.subs and #L.subs > 0 then
								return true
							end
						end
						return false
					end,
					topHeight = function()
						local L = d.geometry
						return L.ruleY + L.tabGap + L.tabBand
					end,
					tabY = function()
						local L = d.geometry
						return L.ruleY + L.tabGap
					end,
					holderY = function()
						return d.topHeight() + d.geometry.holderBottom
					end,
					footerHeight = function()
						if d.features.footer or d.hasSubTabs() then
							return F.HEIGHT
						end
						return 0
					end,
				}
				local function L()
					local n = 1
					for M, M in ipairs(d.tabs) do
						n = if #M.columns > n then #M.columns else n
					end
					return n
				end
				d.windowWidth = function()
					local n = d.geometry
					if n.windowWidth then
						return n.windowWidth
					end
					local M, t = L(), math.max(0, n.columnStep - n.columnWidth)
					return 2 * n.holderX + n.inset + M * n.columnWidth + (M - 1) * t + n.inset
				end
				d.features = {
					wordmark = true,
					reveal = true,
					footer = true,
					rainbow = true,
					bubbles = true,
					edge = true,
					aurora = true,
					tilt = false,
					backdrop = true,
					keybinds = true,
					watermark = true,
				}
				local L = {
					window = "window",
					surface = "surface",
					border = "border",
					black = "hard",
					text = "text",
					muted = "muted",
				}
				p, U =
					setmetatable, {
						__index = function(n, M)
							n = L[M]
							return n and m.get(n) or nil
						end,
					}
				d.palette = p({}, U)
				local L = {}
				L.__index = L
				local n = {}
				n.__index = n
				local M = {}
				M.__index = M
				d.setFlag = function(t, X)
					if t == nil then
						return
					end
					d.flags[t] = X
					if d.onFlagWrite then
						d.onFlagWrite(t, X)
					end
				end
				local function t(X)
					if not X.flag then
						return X
					end
					d.options[X.flag] = X
					d.setFlag(X.flag, X:Get())
					X.onChanged = function(pH, JH)
						d.setFlag(pH, JH)
						if d.onChanged then
							d.onChanged(pH, JH)
						end
					end
					return X
				end
				local function X(pH, JH, OH)
					JH.host = pH
					JH.position = #pH.options
					if typeof(OH) == "table" and OH.scope ~= nil then
						JH.scope = OH.scope
					end
					JH.zbase = pH.zbase or W.WIDGET
					table.insert(pH.options, JH)
					t(JH)
					if pH.content then
						JH:Init(pH.content)
						if JH.shown ~= nil and JH.main then
							JH.main.Visible = JH.shown
						end
					end
					return JH
				end
				p, U = ipairs, { L, Q.class }
				for pH, pH in p(U) do
					pH.adopt = X
					pH.AddToggle = function(p, U)
						local X = K.new(U)
						return p:adopt(X, U)
					end
					pH.AddSlider = function(p, K)
						local U = B.new(K)
						return p:adopt(U, K)
					end
					pH.AddBox = function(p, B)
						local K = z.new(B)
						return p:adopt(K, B)
					end
					pH.AddList = function(p, B)
						local z = e.new(B)
						return p:adopt(z, B)
					end
					pH.AddColor = function(p, e)
						local B = S.new(e)
						return p:adopt(B, e)
					end
					pH.AddOrder = function(p, e)
						local B = G.new(e)
						return p:adopt(B, e)
					end
					pH.AddButton = function(p, e)
						local G = r.new(e)
						return p:adopt(G, e)
					end
					pH.AddLabel = function(p, r)
						local e = R.new(r)
						return p:adopt(e, r)
					end
					pH.AddDivider = function(p, r)
						local R = c.new(r)
						return p:adopt(R, r)
					end
				end
				T.AddColor = function(p, r)
					p.colors = p.colors or {}
					local c = t(S.new(r))
					c.zbase = p.zbase or W.WIDGET
					if typeof(r) == "table" and r.scope ~= nil then
						c.scope = r.scope
					end
					table.insert(p.colors, c)
					if p.main then
						c:attach(p)
					end
					return p
				end
				T.mountColors = function(p)
					for T, T in ipairs(p.colors) do
						T:attach(p)
					end
				end
				d.AddSetting = function(p)
					return t({
						flag = p.flag,
						scope = p.scope,
						value = p.value,
						callback = p.callback,
						Get = function(p)
							return p.value
						end,
						Set = function(p, T, r)
							p.value = T
							if p.onChanged then
								p.onChanged(p.flag, T)
							end
							if not r and typeof(p.callback) == "function" then
								p.callback(T)
							end
						end,
					})
				end
				n.AddSection = function(p, T)
					local r = setmetatable(
						{ title = T or "", column = p, zbase = W.WIDGET, options = {}, main = nil, content = nil },
						L
					)
					table.insert(p.sections, r)
					return r
				end
				M.AddSubTab = function(p, T, r)
					return k.add(p, T, r)
				end
				M.AddColumn = function(p)
					local T = setmetatable({ tab = p, position = #p.columns, sections = {}, main = nil }, n)
					table.insert(p.columns, T)
					return T
				end
				d.tabWatchers = {}
				d.onTab = function(p)
					if typeof(p) == "function" then
						table.insert(d.tabWatchers, p)
					end
					return d
				end
				d.AddTab = function(p, T)
					local r = setmetatable(
						{
							title = p or "tab",
							icon = T and tostring(T) or nil,
							columns = {},
							width = nil,
							height = nil,
							subs = {},
							currentSub = nil,
							hovered = false,
							pressed = false,
							button = nil,
						},
						M
					)
					table.insert(d.tabs, r)
					return r
				end
				L.Init = function(p)
					local T = d.geometry
					local r = d.palette
					p.main = f.new(
						"Frame",
						{
							Name = "Section",
							skin = { BackgroundColor3 = "surface", BorderColor3 = "hard" },
							Size = UDim2.new(1, 0, 0, 30),
							ZIndex = W.WIDGET,
							Parent = p.column.main,
						}
					)
					p.content = f.new(
						"Frame",
						{
							Name = "Content",
							Size = UDim2.new(1, 0, 1, 0),
							skin = { BackgroundColor3 = "surface", BorderColor3 = "border" },
							BorderMode = Enum.BorderMode.Inset,
							ZIndex = W.WIDGET,
							Parent = p.main,
						}
					)
					l.follow(
						f.new(
							"Frame",
							{
								Name = "Accent",
								Size = UDim2.new(1, 0, 0, 1),
								BackgroundColor3 = l.get(),
								BorderSizePixel = 0,
								BorderMode = Enum.BorderMode.Inset,
								ZIndex = W.WIDGET,
								Parent = p.main,
							}
						),
						"BackgroundColor3"
					)
					local r = f.new(
						"UIListLayout",
						{
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, q.rowGap),
							Parent = p.content,
						}
					)
					f.new(
						"UIPadding",
						{
							PaddingTop = UDim.new(0, T.cardPadTop),
							PaddingBottom = UDim.new(0, T.cardPadBottom),
							Parent = p.content,
						}
					)
					if p.title ~= "" then
						p.titleText = f.new(
							"TextLabel",
							{
								Name = "Title",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, 12, 0, 0),
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.fromOffset(0, 16),
								BorderSizePixel = 0,
								Text = p.title,
								TextSize = T.sectionSize,
								FontFace = a.face(),
								skin = { BackgroundColor3 = "surface", TextColor3 = "text" },
								ZIndex = W.WIDGET + 1,
								Parent = p.main,
							}
						)
						f.new(
							"UIPadding",
							{ PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 2), Parent = p.titleText }
						)
					end
					O.signal(r:GetPropertyChangedSignal("AbsoluteContentSize"), function()
						p.main.Size =
							UDim2.new(1, 0, 0, r.AbsoluteContentSize.Y + T.cardPadTop + T.cardPadBottom)
					end, "section/size")
					for T, T in ipairs(p.options) do
						if T.Init then
							T:Init(p.content)
						end
						if T.shown ~= nil and T.main then
							T.main.Visible = T.shown
						end
					end
				end
				n.Init = function(p)
					local T = d.geometry
					p.main = f.new(
						"ScrollingFrame",
						{
							Name = "Column",
							ZIndex = W.WINDOW,
							Position = UDim2.new(0, T.inset + p.position * T.columnStep, 0, T.columnTop),
							Size = UDim2.new(0, T.columnWidth, 1, -(4 + d.footerHeight())),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							skin = { ScrollBarImageColor3 = "hard" },
							ScrollBarThickness = 4,
							VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
							ScrollingDirection = Enum.ScrollingDirection.Y,
							Visible = false,
							Parent = d.columnHolder,
						}
					)
					local r = f.new(
						"UIListLayout",
						{
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, T.cardGap),
							Parent = p.main,
						}
					)
					f.new(
						"UIPadding",
						{
							PaddingTop = UDim.new(0, 8),
							PaddingLeft = UDim.new(0, 2),
							PaddingRight = UDim.new(0, 2),
							Parent = p.main,
						}
					)
					O.signal(r:GetPropertyChangedSignal("AbsoluteContentSize"), function()
						p.main.CanvasSize = UDim2.new(0, 0, 0, r.AbsoluteContentSize.Y + 14)
					end, "column/canvas")
					for T, T in ipairs(p.sections) do
						T:Init()
					end
				end
				M.Init = function(p)
					local T = d.geometry
					p.button = f.new(
						"Frame",
						{
							Name = "Tab",
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 1,
							ZIndex = W.WINDOW + 1,
							Parent = d.tabRow,
						}
					)
					local r, S, c =
						f.new(
							"Frame",
							{
								Name = "Content",
								AutomaticSize = Enum.AutomaticSize.X,
								Size = UDim2.new(0, 0, 1, 0),
								BackgroundTransparency = 1,
								ZIndex = W.WINDOW + 1,
								Parent = p.button,
							}
						),
						f.new,
						{
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}
					c.Padding, c.Parent = UDim.new(0, T.tabIconGap), r
					S("UIListLayout", c)
					f.new(
						"UIPadding",
						{ PaddingLeft = UDim.new(0, T.tabPad), PaddingRight = UDim.new(0, T.tabPad), Parent = r }
					)
					S = p.icon and Z.get(p.icon)
					if S then
						c = T.tabIconSize
						p.glyph = f.new(
							"ImageLabel",
							{
								Name = "Glyph",
								LayoutOrder = 0,
								Size = UDim2.fromOffset(c, c),
								BackgroundTransparency = 1,
								skin = "text",
								ImageContent = S,
								ZIndex = W.WINDOW + 1,
								Parent = r,
							}
						)
					end
					p.label = f.new(
						"TextLabel",
						{
							Name = "Label",
							LayoutOrder = 1,
							AutomaticSize = Enum.AutomaticSize.X,
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = p.title,
							TextSize = T.tabSize,
							FontFace = a.face(),
							skin = "text",
							ZIndex = W.WINDOW + 1,
							Parent = r,
						}
					)
					O.signal(r:GetPropertyChangedSignal("AbsoluteSize"), function()
						if d.currentTab == p then
							d.placeHighlight(p, true)
						end
					end, "tab/fit")
					O.signal(p.button.InputBegan, function(Z)
						if Z.UserInputType == Enum.UserInputType.MouseButton1 then
							p.pressed = true
							p:paint()
							d.selectTab(p)
						elseif Z.UserInputType == Enum.UserInputType.MouseMovement then
							if Q.blocks(p.button) then
								return
							end
							p.hovered = true
							p:paint()
						end
					end, "tab/click")
					O.signal(p.button.InputEnded, function(Z)
						if Z.UserInputType == Enum.UserInputType.MouseButton1 then
							p.pressed = false
							p:paint()
						elseif Z.UserInputType == Enum.UserInputType.MouseMovement then
							p.hovered = false
							p.pressed = false
							p:paint()
						end
					end, "tab/leave")
					for Z, Z in ipairs(p.columns) do
						Z:Init()
					end
				end
				d.TAB_HOVER = 0.55
				M.paint = function(p)
					if not p.label then
						return
					end
					local Z = l.get()
					local T, r
					if d.currentTab == p or p.pressed then
						T = p.pressed and H.PRESS or H.STATE
						r = Z
					else
						if p.hovered then
							r, T = (d.palette.text:Lerp(Z, d.TAB_HOVER)), H.HOVER_IN
						else
							r, T = d.palette.text, H.HOVER_OUT
						end
					end
					H.to(p.label, T, { TextColor3 = r })
					if p.glyph then
						H.to(p.glyph, T, { ImageColor3 = r })
					end
				end
				local p
				local function Z()
					local T = p
					if T == nil then
						return
					end
					x.MouseIconEnabled = p.icon
					x.MouseBehavior = p.behavior
					p = nil
				end
				local function T()
					local r = d.open
					if r then
						local r = p == nil
						if r then
							p = { icon = x.MouseIconEnabled, behavior = x.MouseBehavior }
						end
						r = u.needsEngineIcon()
						if x.MouseIconEnabled ~= r then
							x.MouseIconEnabled = r
						end
						if x.MouseBehavior ~= Enum.MouseBehavior.Default then
							x.MouseBehavior = Enum.MouseBehavior.Default
						end
						u.onRender()
					else
						Z()
					end
				end
				d.centerWindow = function()
					if not d.main then
						return d
					end
					local p = workspace.CurrentCamera
					if not p then
						return d
					end
					local r, S, c = p.ViewportSize, d.main.Size.X.Offset, d.main.Size.Y.Offset
					S, c =
						if S <= 0 then d.windowWidth() else S, if c <= 0 then d.geometry.windowHeight else c
					d.main.Position = UDim2.fromOffset(
						math.max(0, math.floor((r.X - S) * 0.5)),
						math.max(0, math.floor((r.Y - c) * 0.5))
					)
					return d
				end
				local function p(r, S)
					local c, R, e = false
					O.signal(r.InputBegan, function(G)
						if G.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						local B, z
						B, z, c = G.Position, S.Position, true
						R, e = B, z
					end, "drag/begin")
					O.signal(r.InputEnded, function(r)
						if r.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						c = false
						if d.onChanged then
							d.onChanged("window", S.Position)
						end
					end, "drag/end")
					O.signal(x.InputChanged, function(r)
						local G = c
						if not G then
							return
						end
						if r.UserInputType ~= Enum.UserInputType.MouseMovement then
							return
						end
						G = r.Position - R
						S.Position = UDim2.new(e.X.Scale, e.X.Offset + G.X, e.Y.Scale, e.Y.Offset + G.Y)
					end, "drag/move")
				end
				local function r()
					O.signal(x.InputBegan, function(S)
						if i.typing() then
							return
						end
						if S.KeyCode == d.keybinds.toggle then
							d.Close()
						elseif S.KeyCode == d.keybinds.unload then
							task.spawn(function()
								if d.onUnloadRequest() ~= false then
									d.Unload()
								end
							end)
						end
					end, "keys")
				end
				d.Init = function()
					if d.hasInit then
						return d
					end
					d.hasInit = true
					local S, c = d.geometry, d.palette
					d.base = w.newBase()
					if not d.base then
						return d
					end
					d.menu = w.newMenu() or d.base
					d.chrome = w.newChrome() or d.base
					d.world = w.newWorld() or d.base
					d.main = f.new(
						"ImageButton",
						{
							Name = "Window",
							AutoButtonColor = false,
							Position = UDim2.new(0, S.windowX, 0, S.windowY),
							Size = UDim2.fromOffset(d.windowWidth(), S.windowHeight),
							skin = { BackgroundColor3 = "window" },
							BorderSizePixel = 0,
							ScaleType = Enum.ScaleType.Tile,
							Modal = false,
							Visible = false,
							ZIndex = W.WINDOW,
							Parent = d.menu,
						}
					)
					f.new("UICorner", { CornerRadius = UDim.new(0, S.windowCorner), Parent = d.main })
					local c = l.follow(
						f.new(
							"UIStroke",
							{ Thickness = q.stroke, Color = l.get(), Transparency = 0.6, Parent = d.main }
						),
						"Color"
					)
					A.attach(d.main, c)
					A.setEnabled(d.features.edge)
					D.attach(d.main)
					D.setEnabled(d.features.tilt)
					d.SetBackdrop(d.features.backdrop)
					d.shadow = v.attach(d.main, W.WINDOW)
					E.include(d.shadow, "ImageTransparency")
					local c, R, e =
						f.new(
							"Frame",
							{
								Name = "Top",
								Size = UDim2.new(1, 0, 0, d.topHeight()),
								skin = { BackgroundColor3 = "surface" },
								BorderSizePixel = 0,
								ZIndex = W.WINDOW,
								Parent = d.main,
							}
						),
						f.new,
						{}
					e.CornerRadius, e.Parent = UDim.new(0, S.windowCorner), c
					R("UICorner", e)
					f.new(
						"Frame",
						{
							Name = "TopSquare",
							AnchorPoint = Vector2.new(0, 1),
							Position = UDim2.fromScale(0, 1),
							Size = UDim2.new(1, 0, 0, S.windowCorner),
							skin = "surface",
							BorderSizePixel = 0,
							ZIndex = W.WINDOW,
							Parent = c,
						}
					)
					p(c, d.main)
					b.attach(d.main, S.holderBottom + d.footerHeight() + 2)
					b.setEnabled(d.features.aurora)
					d.headerShadow = f.new(
						"Frame",
						{
							Name = "HeaderShadow",
							Position = UDim2.new(0, 0, 0, d.topHeight()),
							Size = UDim2.new(1, 0, 0, S.headerShadow),
							BackgroundColor3 = Color3.new(),
							BorderSizePixel = 0,
							ZIndex = W.WIDGET + 5,
							Parent = d.main,
						}
					)
					f.new(
						"UIGradient",
						{
							Rotation = 90,
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, S.headerShadowFade),
								NumberSequenceKeypoint.new(1, 1),
							}),
							Parent = d.headerShadow,
						}
					)
					d.brand = f.new(
						"TextLabel",
						{
							Name = "Brand",
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, S.headerPad, 0, S.titleY),
							Size = UDim2.new(0, 0, 0, S.brandSize + 6),
							BackgroundTransparency = 1,
							Text = tostring(d.title or "menu"),
							FontFace = a.face(),
							TextSize = S.brandSize,
							skin = "text",
							TextXAlignment = Enum.TextXAlignment.Left,
							AutomaticSize = Enum.AutomaticSize.X,
							ZIndex = W.WINDOW + 1,
							Parent = d.main,
						}
					)
					d.rule = l.follow(
						f.new(
							"Frame",
							{
								Name = "Rule",
								Size = UDim2.new(1, 0, 0, 1),
								Position = UDim2.new(0, 0, 0, S.ruleY),
								BackgroundColor3 = l.get(),
								BorderSizePixel = 0,
								ZIndex = W.WINDOW + 1,
								Parent = d.main,
							}
						),
						"BackgroundColor3"
					)
					Y.attach(d.rule).setEnabled(d.features.rainbow)
					s.attach(d.main, S.headerPad, S.titleY)
					s.onQuery = d.Search
					d.beamHost = f.new(
						"Frame",
						{
							Name = "Beam",
							Position = UDim2.new(0, S.headerPad, 0, d.tabY()),
							Size = UDim2.new(1, -2 * S.headerPad, 0, S.tabBand),
							BackgroundTransparency = 1,
							ClipsDescendants = true,
							ZIndex = W.WINDOW,
							Parent = d.main,
						}
					)
					P.attach(d.beamHost)
					d.tabHighlight = l.follow(
						f.new(
							"Frame",
							{
								Name = "Highlight",
								AnchorPoint = Vector2.new(0, 1),
								Position = UDim2.new(0, 0, 1, 0),
								Size = UDim2.fromOffset(0, 1),
								BackgroundColor3 = l.get(),
								BorderSizePixel = 0,
								ZIndex = W.WINDOW + 2,
								Parent = d.beamHost,
							}
						),
						"BackgroundColor3"
					)
					P.follow(d.tabHighlight)
					d.tabRow = f.new(
						"ScrollingFrame",
						{
							Name = "Tabs",
							Position = UDim2.new(0, S.headerPad, 0, d.tabY()),
							Size = UDim2.new(1, -2 * S.headerPad, 0, S.tabBand),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ScrollBarThickness = 0,
							ScrollingDirection = Enum.ScrollingDirection.X,
							AutomaticCanvasSize = Enum.AutomaticSize.X,
							CanvasSize = UDim2.new(),
							ZIndex = W.WINDOW + 1,
							Parent = d.main,
						}
					)
					f.new(
						"UIListLayout",
						{
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Bottom,
							Padding = UDim.new(0, S.tabSpacing),
							Parent = d.tabRow,
						}
					)
					O.signal(d.tabRow:GetPropertyChangedSignal("CanvasPosition"), function()
						if d.currentTab then
							d.placeHighlight(d.currentTab, true)
						end
					end)
					d.columnHolder = f.new(
						"Frame",
						{
							Name = "Columns",
							Position = UDim2.new(0, S.holderX, 0, d.holderY()),
							Size = UDim2.new(1, -2 * S.holderX, 1, -(d.holderY() + S.holderBottom)),
							BackgroundTransparency = 1,
							ZIndex = W.WINDOW,
							Parent = d.main,
						}
					)
					Q.setHost(d.main)
					E.onSettle = d.repaintOptions
					g.onSettle = d.repaintOptions
					Q.onSettle = d.repaintOptions
					for p, p in ipairs(d.tabs) do
						p:Init()
					end
					if d.footerHeight() > 0 then
						R = F.attach(d.columnHolder)
						for p, p in ipairs(d.tabs) do
							k.build(p, R)
						end
						if d.account then
							J.attach(R, d.account)
						end
					end
					if d.tabs[1] then
						d.selectTab(d.tabs[1], true)
					end
					if d.features.wordmark then
						N.attach(d.brand)
					end
					local p
					local S, c = 0.03333333333333333, 0
					O.signal(_.RenderStepped, function(R)
						T()
						local T = d.menu and d.menu ~= d.base and d.main
						if T then
							local e = d.main.Visible
							local G = p ~= e
							if G then
								p = e
								d.menu.Enabled = e
							end
						end
						E.onRender()
						T = d.main ~= nil and d.main.Visible or false
						if T then
							c += R
							local p = c >= S
							if p then
								Y.onRender(c)
								b.onRender()
								if d.features.wordmark then
									N.onRender()
								end
								c = 0
							end
						end
						h.onRender(T)
						A.onRender(T)
						D.onRender(R)
						y.onRender(R, d.collectBinds)
						V.onRender(R)
					end, "frame")
					m.onChange(function()
						N.recolor(m.get("text"))
					end)
					l.onChange(function()
						for p, p in ipairs(d.tabs) do
							if p.label then
								p:paint(false)
							end
						end
						k.reapply()
					end)
					h.attach(d.base, d.main)
					h.setEnabled(d.features.bubbles)
					y.attach(d.chrome)
					y.setEnabled(d.features.keybinds)
					V.attach(d.chrome, d.footerMark or d.title, d.account)
					V.setEnabled(d.features.watermark)
					j.attach(d.main)
					u.attach(d.menu)
					r()
					d.centerWindow()
					return d
				end
				d.selectTab = function(p, T)
					if not p then
						return
					end
					d.currentTab = p
					for r, S in ipairs(d.tabs) do
						r = S == p
						S:paint()
						for c, c in ipairs(S.columns) do
							if c.main then
								c.main.Visible = r
							end
						end
					end
					k.showFor(p)
					local r = {}
					for S, S in ipairs(p.columns) do
						if S.main then
							table.insert(r, S.main)
						end
					end
					local S = not T
					if S then
						g.play(r, true)
					end
					d.placeHighlight(p, T)
					d.fitWindow(p, S)
					for T, T in ipairs(d.tabWatchers) do
						pcall(T, p)
					end
				end
				d.WINDOW_RESIZE = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				d.sizeTab = function(p, T, r)
					if not p then
						return d
					end
					p.width = T
					p.height = r
					if d.main and d.currentTab == p then
						d.fitWindow(p, false)
					end
					return d
				end
				d.tabSize = function(p)
					local T = d.geometry
					if p and p.width then
						return UDim2.fromOffset(p.width, p.height or T.windowHeight)
					end
					return UDim2.fromOffset(d.windowWidth(), T.windowHeight)
				end
				local function p(T)
					if not d.base or d.base.AbsoluteSize.X <= 0 then
						return nil
					end
					local r, S = d.base.AbsoluteSize, d.main.Position
					local c, R = S.X.Offset, S.Y.Offset
					local S, e =
						math.clamp(c, 0, math.max(0, r.X - T.X.Offset)),
						math.clamp(R, 0, math.max(0, r.Y - T.Y.Offset))
					if S == c and e == R then
						return nil
					end
					return UDim2.fromOffset(S, e)
				end
				d.fitWindow = function(T, r)
					if not d.main then
						return
					end
					local S = d.tabSize(T)
					if d.main.Size == S then
						return
					end
					T = p(S)
					if not r then
						d.main.Size = S
						if T then
							d.main.Position = T
						end
						return
					end
					H.cancel(d.resizeTween)
					H.cancel(d.repositionTween)
					d.resizeTween = H.to(d.main, d.WINDOW_RESIZE, { Size = S })
					if T then
						d.repositionTween = H.to(d.main, d.WINDOW_RESIZE, { Position = T })
					end
				end
				d.TAB_SLIDE = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				d.placeHighlight = function(p, T)
					if not d.tabHighlight or not d.beamHost then
						return
					end
					if not p or not p.button then
						return
					end
					local r = p.button.AbsoluteSize.X
					if r <= 0 then
						return
					end
					local S = p.button.AbsolutePosition.X - d.beamHost.AbsolutePosition.X
					local p, c = UDim2.new(0, S, 1, 0), UDim2.fromOffset(r, 1)
					H.cancel(d.highlightTween)
					if T then
						d.tabHighlight.Position = p
						d.tabHighlight.Size = c
						return
					end
					d.highlightTween = H.to(d.tabHighlight, d.TAB_SLIDE, { Position = p, Size = c })
				end
				d.SetBackdrop = function(p)
					d.features.backdrop = p and true or false
					if not d.main then
						return d
					end
					if not d.features.backdrop then
						d.main.ImageTransparency = 1
						return d
					end
					p = I.content()
					if not p then
						return d
					end
					local T = I.tileSize()
					d.main.ImageContent = p
					d.main.TileSize = UDim2.fromOffset(T, T)
					d.main.ImageTransparency = d.geometry.backdropFade
					l.follow(d.main, "ImageColor3")
					return d
				end
				local function p(T)
					local r, S = tostring(T.text or ""), T.host
					T = S and typeof(S.title) == "string" and S.title or nil
					if not T or T == "" then
						return r
					end
					if r == "" or r == "enabled" or r == T then
						return T
					end
					return T .. " " .. r
				end
				d.collectBinds = function()
					local T = {}
					for r, S in ipairs(i.bindings()) do
						r = S.option
						if
							r
							and d.options[r.flag] == r
							and r.bind == S
							and (S.key ~= nil or S.mode == "always")
						then
							local c = S.mode == "always"
							if not c and typeof(r.Get) == "function" then
								local R, e = pcall(r.Get, r)
								c = R and e == true
							else
							end
							table.insert(T, { key = i.label(S.key), name = p(r), mode = S.mode, active = c })
						end
					end
					table.sort(T, function(p, i)
						return tostring(p.name) < tostring(i.name)
					end)
					return T
				end
				d.SetWatermarkContent = function(p)
					V.setContent(p)
					return d
				end
				d.SetWatermarkConfig = function(p)
					V.setConfig(p)
					return d
				end
				d.SetLink = function(p)
					J.setLink(p)
					V.setLink(p)
					return d
				end
				d.SetWatermark = function(p)
					d.features.watermark = p and true or false
					V.setEnabled(d.features.watermark)
					return d
				end
				d.SetKeybinds = function(p)
					d.features.keybinds = p and true or false
					y.setEnabled(d.features.keybinds)
					return d
				end
				d.SetTilt = function(p)
					d.features.tilt = p and true or false
					D.setEnabled(d.features.tilt)
					return d
				end
				d.SetEdge = function(p)
					d.features.edge = p and true or false
					A.setEnabled(d.features.edge)
					return d
				end
				d.SetAurora = function(p)
					d.features.aurora = p and true or false
					b.setEnabled(d.features.aurora)
					return d
				end
				d.SetBubbles = function(p)
					d.features.bubbles = p and true or false
					h.setEnabled(d.features.bubbles)
					return d
				end
				d.SetRainbow = function(p)
					d.features.rainbow = p and true or false
					Y.setEnabled(d.features.rainbow)
					return d
				end
				local p = { divider = true }
				local function i(T, r)
					return tostring(T or ""):lower():find(r, 1, true) ~= nil
				end
				local function T(r, S)
					for c, R in ipairs(d.tabs) do
						c = r and (S[R] or 0) == 0 and d.SEARCH_DIM or 0
						if R.label then
							H.to(R.label, H.STATE, { TextTransparency = c })
						end
						if R.glyph then
							H.to(R.glyph, H.STATE, { ImageTransparency = c })
						end
					end
				end
				d.SEARCH_DIM = 0.65
				d.filterTab = function(r, S, c)
					local R = 0
					for e, G in ipairs(r.columns) do
						for r, q in ipairs(G.sections) do
							r, e = c and i(q.title, S), 0
							for G, w in ipairs(q.options) do
								G = if c then r or not p[w.type] and i(w.text, S) else true
								if w.main then
									w.main.Visible = G
								end
								e = if G then e + 1 else e
							end
							if q.main then
								q.main.Visible = not c or e > 0
							end
							R = if c then R + e else R
						end
					end
					return R
				end
				d.Search = function(p)
					p = tostring(p or ""):lower():match("^%s*(.-)%s*$")
					d.query = p
					local i, r, S = p ~= "", {}
					for c, R in ipairs(d.tabs) do
						c = d.filterTab(R, p, i)
						r[R] = c
						S = if i and c > 0 and not S then R else S
					end
					T(i, r)
					if i and S and (r[d.currentTab] or 0) == 0 then
						d.selectTab(S)
					end
					if not i then
						k.reapply()
					end
					return d
				end
				d.keybinds = { toggle = Enum.KeyCode.Insert, unload = Enum.KeyCode.End }
				local p = d.keybinds.toggle
				d.onToggleKey = nil
				d.SetToggleKey = function(i)
					i = if typeof(i) ~= "EnumItem" then p else i
					d.keybinds.toggle = i
					if d.onToggleKey then
						d.onToggleKey(i)
					end
					return i
				end
				d.onUnloadRequest = function()
					if not j.isOpen() then
						return j.confirm(string.format("unload %s?", tostring(d.title)))
					end
					return false
				end
				d.SetOpen = function(p)
					d.open = p and true or false
					if d.main then
						d.main.Modal = d.open
						if d.open then
							o.arm()
						else
							o.disarm()
						end
						if d.features.reveal then
							E.play(d.main, d.open)
						else
							d.main.Visible = d.open
						end
					end
					u.setVisible(d.open)
					if not d.open then
						pcall(Q.closeAll)
						C.dismiss()
					end
				end
				d.Close = function()
					d.SetOpen(not d.open)
				end
				d.Unload = function()
					E.stop()
					o.disarm()
					u.restore()
					Z()
					O.disconnectAll()
					f.destroyAll()
					b.reset()
					I.reset()
					h.reset()
					y.reset()
					V.reset()
					A.reset()
					D.reset()
					m.reset()
					j.reset()
					N.reset()
					k.reset()
					g.reset()
					P.reset()
					J.reset()
					Y.reset()
					F.reset()
					d.tabs = {}
					d.options = {}
					d.flags = {}
					d.hasInit = false
					d.base = nil
					d.menu = nil
					d.world = nil
					d.main = nil
					d.brand = nil
					d.tabRow = nil
					d.columnHolder = nil
					d.rule = nil
					d.beamHost = nil
					d.tabHighlight = nil
					d.headerShadow = nil
					s.frame = nil
				end
				d.repaintOptions = function()
					for p, p in pairs(d.options) do
						if typeof(p.repaint) == "function" then
							pcall(p.repaint, p)
						end
						if typeof(p.colors) == "table" then
							for J, J in ipairs(p.colors) do
								if typeof(J.repaint) == "function" then
									pcall(J.repaint, J)
								end
							end
						end
					end
				end
				d.refreshFont = function()
					if d.features.wordmark then
						N.remeasure()
					end
				end
				d.Cursor = u
				d.Theme = l
				d.Typeface = a
				d.Z = W
				return d
			end
end)()

_registry["ui/metrics"] = (function()

return function(p)
				local p
				p = {
					row = 24,
					rowGap = 6,
					control = 16,
					controlX = 10,
					gap = 6,
					corner = 4,
					stroke = 1,
					pressScale = 0.88,
					rowHover = 0.93,
					textSize = 15,
					subStep = 24,
					labelX = function()
						return p.controlX + p.control + p.gap
					end,
				}
				return p
			end
end)()

_registry["ui/motion"] = (function()

return function(p)
				local J = p("core/service").get("TweenService")
				local p = {
					enabled = true,
					HOVER_IN = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					HOVER_OUT = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					PRESS = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					RELEASE = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					STATE = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				}
				local function O(u, F)
					for f, o in pairs(F) do
						pcall(function()
							u[f] = o
						end)
					end
				end
				p.to = function(u, F, f)
					if not u then
						return nil
					end
					if not p.enabled then
						O(u, f)
						return nil
					end
					local o, Z = pcall(function()
						return J:Create(u, F, f)
					end)
					if not o or not Z then
						O(u, f)
						return nil
					end
					if not pcall(function()
						Z:Play()
					end) then
						O(u, f)
						return nil
					end
					return Z
				end
				p.cancel = function(J)
					if J then
						pcall(function()
							J:Cancel()
						end)
					end
				end
				return p
			end
end)()

_registry["ui/mount"] = (function()

local J = nil
local O = nil
local u = gethui

return function(p)
				local F = p("ui/create")
				local f, o, Z, i =
					p("core/service"),
					{},
					{
						"Player",
						"Client",
						"Core",
						"Screen",
						"Menu",
						"Hud",
						"Chat",
						"Notification",
						"Prompt",
						"Session",
						"Interface",
						"Overlay",
					},
					{
						"Gui",
						"Overlay",
						"Layer",
						"Container",
						"Handler",
						"Manager",
						"Controller",
						"Frame",
						"Host",
						"Root",
					}
				local function p()
					local y = Random.new()
					local P, b = Z[y:NextInteger(1, #Z)], i[y:NextInteger(1, #i)]
					return P .. (if P == b then "Layer" else b)
				end
				o.GUI_NAME = p()
				local function Z(i)
					local y = (p())
					for P = 1, 12, 1 do
						P = false
						for b, b in ipairs(i) do
							if b == y then
								P = true
								break
							end
						end
						if not P then
							break
						end
						y = (p())
					end
					return y
				end
				o.MENU_NAME = Z({ o.GUI_NAME })
				o.CHROME_NAME = Z({ o.GUI_NAME, o.MENU_NAME })
				o.WORLD_NAME = Z({ o.GUI_NAME, o.MENU_NAME, o.CHROME_NAME })
				o.host = nil
				o.hostPath = nil
				local function p(Z)
					local i
					local i, i, y = J, typeof(J) == "table"
					if i then
						local P
						P, y = J, typeof(J.protect_gui) == "function"
					else
						y = i
					end
					if y then
						pcall(J.protect_gui, Z)
					else
						i = typeof(protect_gui) == "function"
						if i then
							pcall(protect_gui, Z)
						else
							local J
							local J, J = O, typeof(O) == "function"
							if J then
								local J = O
								pcall(J, Z)
							end
						end
					end
				end
				local function J()
					local O, Z = {}
					local Z, Z = u, typeof(u) == "function"
					if Z then
						local i = u
						local u, y = pcall(i)
						if u and y then
							table.insert(O, { name = "gethui", object = y })
						end
					end
					local u, i = pcall(function()
						return f.get("CoreGui")
					end)
					if u and i then
						table.insert(O, { name = "CoreGui", object = i })
					end
					Z, i = pcall(function()
						local u = f.get("Players").LocalPlayer
						return u and (u:FindFirstChildOfClass("PlayerGui"))
					end)
					if Z and i then
						table.insert(O, { name = "PlayerGui", object = i })
					end
					return O
				end
				local function O(u, f)
					local Z = F.new(
						"ScreenGui",
						{
							Name = u,
							IgnoreGuiInset = true,
							ZIndexBehavior = Enum.ZIndexBehavior.Global,
							ResetOnSpawn = false,
							DisplayOrder = f,
						}
					)
					if not Z then
						return nil
					end
					p(Z)
					for p, u in ipairs(J()) do
						pcall(function()
							Z.Parent = u.object
						end)
						if Z.Parent then
							o.host = u.name
							f, p = pcall(function()
								return u.object:GetFullName()
							end)
							o.hostPath = f and p or "<opaque>"
							return Z
						end
					end
					o.host = nil
					o.hostPath = nil
					return Z
				end
				o.newBase = function()
					return O(o.GUI_NAME, 0)
				end
				o.newWorld = function()
					return O(o.WORLD_NAME, 1)
				end
				o.newMenu = function()
					return O(o.MENU_NAME, 3)
				end
				o.newChrome = function()
					return O(o.CHROME_NAME, 2)
				end
				o.inPlayerGui = function()
					return o.host == "PlayerGui"
				end
				return o
			end
end)()

_registry["ui/popup"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/fade")
				local F = p("ui/metrics")
				local f = p("ui/motion")
				local o = p("ui/shadow")
				p("ui/skin")
				local Z = p("ui/zindex")
				local i, y, P =
					p("core/service").get("UserInputService"),
					{
						WIDTH = 194,
						PAD = 6,
						PAD_X = 7,
						SURFACE = "raised",
						RISE = 8,
						DROP = 4,
						MARGIN = 8,
						BAR = 4,
						MIN_H = 120,
						OFFSET = 6,
						current = nil,
					},
					{}
				P.__index = P
				y.class = P
				y.host = nil
				y.onSettle = nil
				y.setHost = function(p)
					y.host = p
				end
				local p = false
				local function b(I, h)
					return I ~= nil and h ~= nil and I.frame ~= nil and h:IsDescendantOf(I.frame)
				end
				y.blocks = function(I)
					local h = y.current
					if h == nil or h.open ~= true or h.frame == nil then
						return false
					end
					if I == nil then
						return true
					end
					return not I:IsDescendantOf(h.frame)
				end
				y.hold = function(I)
					if I then
						local h, A = y.current, false
						while h do
							if h == I then
								A = true
								break
							end
							h = h.owner
						end
						if A then
							local h = y.current
							while h and h ~= I do
								if h.guard then
									break
								end
								local A = h.owner
								h:Close()
								h = A
							end
						end
					end
					local h = I or y.current
					while h do
						h.selfClick = true
						h = h.owner
					end
				end
				y.closeAbove = function(I)
					while y.current and y.current ~= I do
						local I = y.current
						I:Close()
						if y.current == I then
							break
						end
					end
				end
				y.closeAll = function()
					y.closeAbove(nil)
				end
				local function I()
					local h = p
					if h then
						return
					end
					p = true
					J.signal(i.InputEnded, function(p)
						if not y.current then
							return
						end
						if p.UserInputType ~= Enum.UserInputType.MouseButton1 then
							return
						end
						local p, i = y.current, false
						while p do
							i = if p.guard or p.selfClick then true else i
							p.guard = false
							p.selfClick = false
							p = p.owner
						end
						if i then
							return
						end
						y.closeAll()
					end, "popup/dismiss")
				end
				y.new = function(p, i)
					local h = y.host
					if not h then
						return nil
					end
					local A = i == true or b(y.current, p)
					local i, T =
						A and Z.POPUP_NESTED or Z.POPUP, A and Z.POPUP_NESTED_CONTENT or Z.POPUP_CONTENT
					local Z = setmetatable(
						{ anchor = p, host = h, open = false, options = {}, placement = "beside", frameWidth = y.WIDTH, zbase = T },
						P
					)
					Z.frame = O.new(
						"TextButton",
						{
							Name = "Popup",
							Size = UDim2.fromOffset(y.WIDTH, 0),
							skin = { BackgroundColor3 = y.SURFACE },
							BackgroundTransparency = 0,
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = "",
							Active = true,
							Visible = false,
							ZIndex = i,
							Parent = h,
						}
					)
					Z.fader = O.new("NumberValue", { Name = "Fade", Value = 1, Parent = Z.frame })
					O.new("UICorner", { CornerRadius = UDim.new(0, F.corner), Parent = Z.frame })
					O.new("UIStroke", { Thickness = F.stroke, skin = "border", Parent = Z.frame })
					Z.shadow = o.attach(Z.frame, i)
					Z.content = O.new(
						"ScrollingFrame",
						{
							Name = "Content",
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							CanvasSize = UDim2.new(),
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							ScrollingDirection = Enum.ScrollingDirection.Y,
							ScrollBarThickness = y.BAR,
							VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
							skin = { ScrollBarImageColor3 = "hard" },
							ZIndex = T,
							Parent = Z.frame,
						}
					)
					Z.layout = O.new(
						"UIListLayout",
						{
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, F.rowGap),
							Parent = Z.content,
						}
					)
					O.new(
						"UIPadding",
						{
							PaddingTop = UDim.new(0, y.PAD),
							PaddingBottom = UDim.new(0, y.PAD),
							PaddingLeft = UDim.new(0, y.PAD_X),
							PaddingRight = UDim.new(0, y.PAD_X),
							Parent = Z.content,
						}
					)
					J.signal(Z.layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
						Z:resize()
					end, "popup/size")
					J.signal(Z.fader.Changed, function()
						if Z.shot then
							u.apply(Z.shot, Z.fader.Value)
						end
					end, "popup/fade")
					J.signal(Z.frame.InputBegan, function(p)
						if p.UserInputType == Enum.UserInputType.MouseButton1 then
							y.hold(Z)
						end
					end, "popup/inside")
					I()
					return Z
				end
				local function p(J)
					local O = J and (J:FindFirstAncestorWhichIsA("ScreenGui"))
					if O and O.AbsoluteSize.Y > 0 then
						return O.AbsoluteSize
					end
					J = workspace.CurrentCamera
					return J and J.ViewportSize or Vector2.new(1920, 1080)
				end
				P.contentWidth = function(J)
					local O = J.content
					if not O or O.AbsoluteSize.X <= 0 then
						return nil
					end
					J = O.AbsolutePosition.X
					local F = J + O.AbsoluteSize.X
					local function Z(i)
						local I = i
						while I and I ~= O do
							if I:IsA("GuiObject") and not I.Visible then
								return false
							end
							I = I.Parent
						end
						return true
					end
					local i = 0
					for I, h in ipairs(O:GetDescendants()) do
						if h:IsA("TextLabel") and h.Visible and h.Text ~= "" and Z(h) then
							I = h.TextBounds.X
							if I > 0 and not h.TextWrapped then
								local O = h.Parent
								if
									not (
										O
										and O:IsA("GuiObject")
										and (
											O.AutomaticSize == Enum.AutomaticSize.X
											or O.AutomaticSize == Enum.AutomaticSize.XY
										)
									)
								then
									local Z = if O and O:IsA("GuiObject")
										then math.max(F - (O.AbsolutePosition.X + O.AbsoluteSize.X), 0)
										else 0
									local O = h.AbsolutePosition.X - J + I + Z
									i = if O > i then O else i
								else
								end
							else
							end
						else
						end
					end
					if i <= 0 then
						return nil
					end
					return math.ceil(i)
				end
				P.reflow = function(J)
					if J.placement == "below" then
						return
					end
					local O, F = J.anchor, J.host
					if not O or not F then
						return
					end
					local Z, i, I, h =
						F.AbsolutePosition, O.AbsolutePosition, O.AbsoluteSize, J.frameWidth or y.WIDTH
					O = i.X - Z.X + I.X + y.OFFSET
					O = if O + h > F.AbsoluteSize.X then i.X - Z.X - h - y.OFFSET else O
					J.frame.Position = UDim2.fromOffset(O, J.frame.Position.Y.Offset)
				end
				P.resize = function(J)
					if not J.layout then
						return
					end
					local O = J.layout.AbsoluteContentSize.Y
					if O <= 0 then
						return
					end
					local F = p(J.host)
					local Z = math.max(F.Y - y.MARGIN * 2, y.MIN_H)
					Z = if J.maxHeight then math.min(Z, J.maxHeight) else Z
					local i = J.frameWidth or y.WIDTH
					if J.placement ~= "below" and J.width then
						i = math.min(J.width, math.max(F.X - y.MARGIN * 2, y.WIDTH))
					else
						if J.placement ~= "below" then
							local I = J:contentWidth()
							if I then
								local h = math.max(F.X - y.MARGIN * 2, y.WIDTH)
								i = math.clamp(I + y.PAD * 2, y.WIDTH, h)
							else
							end
						else
						end
					end
					F = i ~= J.frameWidth
					J.frameWidth = i
					J.frame.Size = UDim2.fromOffset(i, math.min(O + y.PAD * 2, Z))
					if F then
						J:reflow()
					end
					J:settle()
				end
				P.settle = function(J)
					if not J.frame or J.wantY == nil then
						return
					end
					local O, F, Z =
						p(J.host).Y, J.host and J.host.AbsolutePosition.Y or 0, J.frame.AbsoluteSize.Y
					if Z <= 0 then
						return
					end
					local p, i = F + J.wantY, O - Z - y.MARGIN
					J.homeY = math.max(y.MARGIN, math.min(p, i)) - F
					if J.open then
						J.frame.Position = UDim2.fromOffset(J.frame.Position.X.Offset, J.homeY)
					end
				end
				P.place = function(p)
					local J, O = p.anchor, p.host
					if not J or not O then
						return
					end
					local F, Z, i, I, h, A =
						O.AbsolutePosition, J.AbsolutePosition, J.AbsoluteSize, p.width or y.WIDTH
					if p.placement == "below" then
						I, h, A = i.X, Z.X - F.X, Z.Y - F.Y + i.Y + y.DROP
					else
						h, A = Z.X - F.X + i.X + y.OFFSET, Z.Y - F.Y
						h = if h + I > O.AbsoluteSize.X then Z.X - F.X - I - y.OFFSET else h
					end
					p.frameWidth = I
					p.wantY = A
					p.homeY = A
					p.frame.Position = UDim2.fromOffset(h, A)
					p:settle()
				end
				P.Open = function(p)
					if p.open then
						return p
					end
					if y.current ~= p then
						local J, O = y.current
						while J do
							if b(J, p.anchor) then
								O = J
								break
							end
							J = J.owner
						end
						y.closeAbove(O)
						p.owner = O
					else
						p.owner = nil
					end
					p.open = true
					y.current = p
					p.guard = true
					p.frame.Visible = true
					p:resize()
					p:place()
					p.frame.Position = UDim2.fromOffset(p.frame.Position.X.Offset, p.homeY + y.RISE)
					f.cancel(p.fade)
					f.cancel(p.slide)
					if p.shot and not p.settled then
						u.apply(p.shot, 0)
					end
					p.settled = false
					p.shot = u.snapshot(p.frame)
					p.fader.Value = 1
					u.apply(p.shot, 1)
					p.fade = f.to(p.fader, f.HOVER_IN, { Value = 0 })
					if p.fade then
						local J, O =
							p.fade, function()
								if y.onSettle then
									y.onSettle()
								end
							end
						J.Completed:Once(O)
					end
					p.slide = f.to(
						p.frame,
						f.HOVER_IN,
						{ Position = UDim2.fromOffset(p.frame.Position.X.Offset, p.homeY) }
					)
					o.fade(p.shadow, true, f.HOVER_IN)
					if p.onOpen then
						p.onOpen()
					end
					return p
				end
				P.Close = function(p)
					if not p.open then
						return p
					end
					if y.current and y.current ~= p and y.current.owner == p then
						y.current:Close()
					end
					p.open = false
					if y.current == p then
						y.current = p.owner
					end
					p.owner = nil
					f.cancel(p.fade)
					f.cancel(p.slide)
					if p.shot and p.fader.Value > 0 then
						u.apply(p.shot, 0)
						p.fader.Value = 0
					end
					p.shot = u.snapshot(p.frame)
					p.settled = false
					p.fade = f.to(p.fader, f.HOVER_OUT, { Value = 1 })
					o.fade(p.shadow, false, f.HOVER_OUT)
					local function J()
						if p.open then
							return
						end
						p.frame.Visible = false
						if p.shot then
							u.apply(p.shot, 0)
						end
						p.settled = true
						if y.onSettle then
							y.onSettle()
						end
					end
					if p.fade then
						p.fade.Completed:Once(J)
					else
						J()
					end
					if p.onClose then
						p.onClose()
					end
					return p
				end
				P.Toggle = function(p)
					if not p.open then
						return p:Open()
					end
					local J = p.owner
					p:Close()
					if J then
						y.hold(J)
					end
					return p
				end
				return y
			end
end)()

_registry["ui/raster"] = (function()

local J = gethui
local O = writefile
local u = isfile
local F = getcustomasset
local f = isfolder
local o = makefolder
local Z = delfile

return function(p)
				local i = p("core/log")
				local y = p("core/service")
				local P, b, I, h, A = y.get("AssetService"), {}, false, false, false
				local function T()
					local r = h
					if r then
						return
					end
					h = true
					if I then
						return
					end
					local function h()
						local r, S
						local S, S = J, typeof(J) == "function"
						if S then
							local c = J
							local J, R = pcall(c)
							r = if J and R then R else r
						else
						end
						if not r then
							local J, c = pcall(function()
								return y.get("CoreGui")
							end)
							r = if J then c else r
						else
						end
						if not r then
							return
						end
						local J = Instance.new("ScreenGui")
						J.Name = "n"
						J.ResetOnSpawn = false
						J.Parent = r
						S = Instance.new("ImageLabel")
						S.Size = UDim2.fromOffset(16, 16)
						S.BackgroundTransparency = 1
						S.ImageTransparency = 0
						S.Parent = J
						local y = Vector2.new(16, 16)
						local r = P:CreateEditableImage({ Size = y })
						local c = buffer.create(1024)
						for R = 0, 255, 1 do
							buffer.writeu32(c, R * 4, 4294967295)
						end
						r:WritePixelsBuffer(Vector2.zero, y, c)
						S.ImageContent = Content.fromObject(r)
						for y = 1, 12, 1 do
							y = S.IsLoaded
							if y then
								A = true
								break
							end
							task.wait()
						end
						pcall(function()
							r:Destroy()
						end)
						pcall(function()
							J:Destroy()
						end)
					end
					pcall(h)
				end
				local function J()
					if I then
						return false
					end
					local y = A
					return y
				end
				b.supported = J
				b.method = function()
					return J() and "editableimage" or "getcustomasset"
				end
				local y, I, h, A = {}, {}, {}, {}
				for r = 0, 255, 1 do
					p = r
					for S = 1, 8, 1 do
						p = if p % 2 == 1
							then bit32.bxor(3988292384, bit32.rshift(p, 1))
							else bit32.rshift(p, 1)
					end
					y[r] = p
				end
				for r = 0, 255, 1 do
					p = y[r]
					p = bit32.bxor(bit32.rshift(p, 8), y[bit32.band(p, 255)])
					I[r] = p
					p = bit32.bxor(bit32.rshift(p, 8), y[bit32.band(p, 255)])
					h[r] = p
					A[r] = bit32.bxor(bit32.rshift(p, 8), y[bit32.band(p, 255)])
				end
				local function p(r)
					local S, c, R = #r, 1, 4294967295
					while c + 3 <= S do
						local e = string.unpack("<I4", r, c)
						R = bit32.bxor(R, e)
						R = bit32.bxor(
							A[bit32.band(R, 255)],
							h[bit32.band(bit32.rshift(R, 8), 255)],
							I[bit32.band(bit32.rshift(R, 16), 255)],
							y[bit32.rshift(R, 24)]
						)
						c = c + 4
					end
					while c <= S do
						R = bit32.bxor(
							y[bit32.band(bit32.bxor(R, string.byte(r, c)), 255)],
							bit32.rshift(R, 8)
						)
						c = c + 1
					end
					return bit32.bxor(R, 4294967295)
				end
				local function y(I)
					local h, A, r, S = #I, 1, 1, 0
					while A <= h do
						local c = math.min(A + 5551, h)
						while A + 3 <= c do
							local h, R, e, G = string.byte(I, A, A + 3)
							r += h
							S += r
							r += R
							S += r
							r += e
							S += r
							r += G
							S += r
							A = A + 4
						end
						while A <= c do
							r += string.byte(I, A)
							S += r
							A = A + 1
						end
						r, S = r % 65521, S % 65521
					end
					return S * 65536 + r
				end
				local function I(h)
					local A, r = { string.char(120, 1) }, #h
					if r == 0 then
						A[#A + 1] = string.char(1, 0, 0, 255, 255)
					end
					local S = 1
					while S <= r do
						local c = math.min(S + 65534, r)
						local R = string.sub(h, S, c)
						local e, G = #R, c >= r and 1 or 0
						A[#A + 1] = string.char(G)
						A[#A + 1] = string.pack("<I2", e)
						A[#A + 1] = string.pack("<I2", 65535 - e)
						A[#A + 1] = R
						S = c + 1
					end
					A[#A + 1] = string.pack(">I4", y(h))
					return table.concat(A)
				end
				local function y(h, A)
					return string.pack(">I4", #A) .. h .. A .. string.pack(">I4", p(h .. A))
				end
				local function p(h, A, r)
					local S, c = A * 4, {}
					for R = 0, r - 1, 1 do
						c[#c + 1] = string.char(0)
						c[#c + 1] = string.sub(h, R * S + 1, (R + 1) * S)
					end
					h = table.concat(c)
					return string.char(137, 80, 78, 71, 13, 10, 26, 10)
						.. y(
							"IHDR",
							string.pack(">I4", A) .. string.pack(">I4", r) .. string.char(8, 6, 0, 0, 0)
						)
						.. y("IDAT", I(h))
						.. y("IEND", "")
				end
				local y = "UILibrary/storage/raster"
				local function I()
					local h
					local h, h, A = O, typeof(O) == "function"
					if h then
						local r
						local r = u
						A = typeof(r) == "function"
					else
						A = h
					end
					h = nil
					if A then
						local r
						local r = F
						h = typeof(r) == "function"
					else
						h = A
					end
					return h and typeof(buffer.tostring) == "function"
				end
				local function h()
					local A
					local A, A, r, S = f, typeof(f) ~= "function"
					if A then
						r = A
					else
						local S = o
						r = typeof(S) ~= "function"
					end
					if r then
						return
					end
					A = nil
					for S in y:gmatch("[^/]+") do
						A = A and A .. "/" .. S or S
						S = f
						r = not S(A)
						if r then
							S = o
							pcall(S, A)
						end
					end
				end
				local f = 0
				local function o(A, r)
					if not I() then
						return nil
					end
					h()
					f += 1
					local I = string.format("%s/%s_%d.png", y, tostring(r or "img"), f)
					local f
					local f, f, y = O, not pcall(O, I, A)
					if f then
						y = f
					else
						local O
						r = u
						y = not r(I)
					end
					if y then
						return nil
					end
					local O
					r = F
					A, y = pcall(r, I)
					if A and typeof(y) == "string" and y ~= "" then
						return y, I
					end
					return nil
				end
				local O = {}
				b.image = function(u, F, f, y)
					if J() then
						local I, h = pcall(function()
							local A = Vector2.new(F, f)
							local r = P:CreateEditableImage({ Size = A })
							r:WritePixelsBuffer(Vector2.zero, A, u)
							table.insert(O, r)
							return Content.fromObject(r)
						end)
						return I and h or nil
					end
					local I, h = pcall(function()
						local A = o(p(buffer.tostring(u), F, f), y)
						if not A then
							return nil
						end
						return Content.fromUri(A)
					end)
					return I and h or nil
				end
				b.surface = function(u, F, f)
					local y = Vector2.new(u, F)
					if J() then
						local J, I = pcall(function()
							local h = { Size = y }
							return P:CreateEditableImage(h)
						end)
						if not J or not I then
							return nil
						end
						local J, P = pcall(function()
							return Content.fromObject(I)
						end)
						if not J or not P then
							return nil
						end
						table.insert(O, I)
						return {
							write = function(J, J)
								pcall(function()
									I:WritePixelsBuffer(Vector2.zero, y, J)
								end)
								return P
							end,
						}
					end
					local J
					local O = {
						write = function(y, y)
							local P, I = pcall(function()
								local h, A = o(p(buffer.tostring(y), u, F), f)
								if not h then
									return nil
								end
								local p = J
								if p then
									local p
									local p = Z
									pcall(p, J)
								end
								J = A
								return Content.fromUri(h)
							end)
							return P and I or nil
						end,
					}
					return O
				end
				local p = false
				b.announce = function()
					local J = p
					if J then
						return
					end
					p = true
					T()
					if i.SINK then
						print("render method: " .. b.method())
					end
				end
				return b
			end
end)()

_registry["ui/shadow"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/icon")
				local F = p("ui/motion")
				local p
				p = {
					DROP = 3,
					COLOR = Color3.fromRGB(0, 0, 0),
					TRANSPARENCY = 0.3,
					attach = function(f, o)
						if not f or not f.Parent then
							return nil
						end
						local Z = u.get("shadow")
						if not Z then
							return nil
						end
						local i, y = u.shadowSlice()
						local P, b = u.dimensions("shadow")
						local u = f.AnchorPoint
						local I = -i * (1 - 2 * u.X)
						local h = -i * (1 - 2 * u.Y)
						local A = O.new(
							"ImageLabel",
							{
								Name = "Shadow",
								BackgroundTransparency = 1,
								AnchorPoint = u,
								ImageContent = Z,
								ImageColor3 = p.COLOR,
								ImageTransparency = p.TRANSPARENCY,
								ScaleType = Enum.ScaleType.Slice,
								SliceCenter = Rect.new(y, y, P - y, b - y),
								ZIndex = (o or f.ZIndex) - 1,
								Parent = f.Parent,
							}
						)
						local function O()
							local u = f.Position
							A.Position =
								UDim2.new(u.X.Scale, u.X.Offset + I, u.Y.Scale, u.Y.Offset + h + p.DROP)
							u = f.AbsoluteSize
							A.Size = UDim2.fromOffset(u.X + i * 2, u.Y + i * 2)
						end
						O()
						J.signal(f:GetPropertyChangedSignal("Position"), O, "shadow/move")
						J.signal(f:GetPropertyChangedSignal("AbsoluteSize"), O, "shadow/size")
						A.Visible = f.Visible
						J.signal(f:GetPropertyChangedSignal("Visible"), function()
							A.Visible = f.Visible
						end, "shadow/visible")
						return A
					end,
					fade = function(J, O, u)
						if not J then
							return
						end
						local f, o, Z = F.to, u or F.HOVER_IN, {}
						Z.ImageTransparency = O and p.TRANSPARENCY or 1
						f(J, o, Z)
					end,
				}
				return p
			end
end)()

_registry["ui/skin"] = (function()

return function(p)
				local J = p("ui/motion")
				local p, O, u =
					{
						INFO = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						PALETTES = {
							dark = {
								window = Color3.fromRGB(20, 20, 20),
								surface = Color3.fromRGB(30, 30, 30),
								raised = Color3.fromRGB(38, 38, 38),
								footer = Color3.fromRGB(22, 22, 22),
								border = Color3.fromRGB(60, 60, 60),
								line = Color3.fromRGB(60, 60, 60),
								stroke = Color3.fromRGB(70, 70, 70),
								edge = Color3.fromRGB(100, 100, 100),
								hard = Color3.fromRGB(0, 0, 0),
								text = Color3.fromRGB(255, 255, 255),
								muted = Color3.fromRGB(210, 210, 210),
								faint = Color3.fromRGB(160, 160, 160),
								body = Color3.fromRGB(200, 200, 200),
								dim = Color3.fromRGB(120, 120, 120),
								hint = Color3.fromRGB(110, 110, 110),
								disabled = Color3.fromRGB(96, 96, 96),
								field = Color3.fromRGB(45, 45, 45),
								control = Color3.fromRGB(50, 50, 50),
								grab = Color3.fromRGB(235, 235, 235),
								hover = Color3.fromRGB(62, 62, 62),
								danger = Color3.fromRGB(255, 90, 90),
								add = Color3.fromRGB(95, 208, 138),
								remove = Color3.fromRGB(255, 107, 107),
								rowGlow = Color3.fromRGB(255, 255, 255),
							},
							light = {
								window = Color3.fromRGB(232, 232, 234),
								surface = Color3.fromRGB(246, 246, 248),
								raised = Color3.fromRGB(255, 255, 255),
								footer = Color3.fromRGB(238, 238, 240),
								border = Color3.fromRGB(198, 198, 202),
								line = Color3.fromRGB(206, 206, 210),
								stroke = Color3.fromRGB(190, 190, 196),
								edge = Color3.fromRGB(140, 140, 148),
								hard = Color3.fromRGB(168, 168, 176),
								text = Color3.fromRGB(24, 24, 27),
								muted = Color3.fromRGB(62, 62, 68),
								faint = Color3.fromRGB(122, 122, 130),
								body = Color3.fromRGB(48, 48, 54),
								dim = Color3.fromRGB(126, 126, 134),
								hint = Color3.fromRGB(148, 148, 156),
								disabled = Color3.fromRGB(170, 170, 178),
								field = Color3.fromRGB(255, 255, 255),
								control = Color3.fromRGB(214, 214, 220),
								grab = Color3.fromRGB(255, 255, 255),
								hover = Color3.fromRGB(202, 202, 210),
								danger = Color3.fromRGB(200, 40, 40),
								add = Color3.fromRGB(31, 145, 82),
								remove = Color3.fromRGB(198, 51, 46),
								rowGlow = Color3.fromRGB(0, 0, 0),
							},
						},
						mode = "dark",
					},
					setmetatable,
					{ __mode = "k" }
				local F, f, o =
					O({}, u),
					{},
					{
						TextLabel = "TextColor3",
						TextBox = "TextColor3",
						TextButton = "TextColor3",
						ImageLabel = "ImageColor3",
						ImageButton = "ImageColor3",
						UIStroke = "Color",
					}
				p.get = function(O)
					return (p.PALETTES[p.mode] or p.PALETTES.dark)[O] or Color3.fromRGB(255, 0, 255)
				end
				local function O(u, Z, i)
					for y, P in pairs(Z) do
						local Z = p.get(P)
						if i then
							J.to(u, p.INFO, { [y] = Z })
						else
							pcall(function()
								u[y] = Z
							end)
						end
					end
				end
				p.paint = function(J, u)
					if not J or not u then
						return J
					end
					u = if typeof(u) == "string" then { [o[J.ClassName] or "BackgroundColor3"] = u } else u
					F[J] = u
					O(J, u, false)
					return J
				end
				p.unpaint = function(J)
					if J then
						F[J] = nil
					end
				end
				p.onChange = function(J)
					if typeof(J) ~= "function" then
						return function() end
					end
					table.insert(f, J)
					local function u()
						local o = f
						for Z, i in ipairs(o) do
							local o = i == J
							if o then
								table.remove(f, Z)
								return
							end
						end
					end
					return u
				end
				p.set = function(J)
					if not p.PALETTES[J] or J == p.mode then
						return p.mode
					end
					p.mode = J
					local u = F
					for o, Z in pairs(u) do
						O(o, Z, true)
					end
					u = f
					for O, O in ipairs(u) do
						pcall(O, J)
					end
					return p.mode
				end
				p.toggle = function()
					return p.set(p.mode == "dark" and "light" or "dark")
				end
				p.reset = function()
					local J, O = setmetatable, { __mode = "k" }
					F, f = J({}, O), {}
				end
				return p
			end
end)()

_registry["ui/theme"] = (function()

return function(p)
				local p, J, O = {}, setmetatable, { __mode = "k" }
				local u, F = J({}, O), {}
				local J = Color3.fromRGB(255, 125, 247)
				local function O(f, o, Z)
					if typeof(o) == "function" then
						pcall(o, f, Z)
					else
						pcall(function()
							f[o] = Z
						end)
					end
				end
				p.follow = function(f, o)
					if not f or not o then
						return f
					end
					u[f] = o
					O(f, o, J)
					return f
				end
				p.unfollow = function(f)
					if f then
						u[f] = nil
					end
				end
				p.onChange = function(f)
					if typeof(f) ~= "function" then
						return function() end
					end
					table.insert(F, f)
					return function()
						for o, Z in ipairs(F) do
							if Z == f then
								table.remove(F, o)
								return
							end
						end
					end
				end
				p.get = function()
					local f = J
					return f
				end
				p.set = function(f)
					if typeof(f) ~= "Color3" then
						return
					end
					J = f
					for f, o in pairs(u) do
						O(f, o, J)
					end
					for O, O in ipairs(F) do
						pcall(O, J)
					end
				end
				p.count = function()
					local J = 0
					for O in pairs(u) do
						J += 1
					end
					return J
				end
				return p
			end
end)()

_registry["ui/toast"] = (function()

local Runtime = { [14] = table.pack }
function Runtime:oh(values) return table.unpack(values, 1, values.n) end
function Runtime:Wh(destination, offset, ...)
    local values = table.pack(...)
    table.move(values, 1, values.n, offset + 1, destination)
end
function Runtime:Lh(destination, offset, values)
    table.move(values, 1, values.n, offset + 1, destination)
    destination.n = offset + values.n
end

local p = Runtime

return function(J)
				local O = J("ui/connect")
				local u = J("ui/create")
				local F = J("services/frame")
				local f = J("ui/icon")
				local o = J("ui/library")
				local Z = J("ui/shadow")
				local i = J("ui/skin")
				local y = J("ui/theme")
				local P = J("ui/font")
				local b = J("ui/chrome/watermark")
				local I, h, A = J("ui/zindex"), { BIND = "hud/toast" }, 12
				local T, r, S, c, R, e, G, q, w, H, Q, Y, E, s, v, m =
					f.shadowSlice() + 24, 8, 296, 36, 24, 15, 6, 8, 12, 18, 14, 10, 2, 10, 10, 2
				local B = b.BRAND_TEXT
				local g = b.STAT_TEXT
				local k = b.STAT_TEXT
				h.LIFE = 7
				h.SPIN = 1.1
				h.SETTLED = 18
				local z, l, D, K, C, a, j, V, N = 0.24, 0.3, 28, 3, 0.96, 0.62, 0.5, false
				local W, U = {}
				local function _()
					local x = N and N.Parent
					if x then
						local d = N
						return d
					end
					x = o.base
					if not x then
						return nil
					end
					N = u.new(
						"Frame",
						{
							Name = "Toasts",
							AnchorPoint = Vector2.new(1, 0),
							Position = UDim2.new(1, -A, 0, b.MARGIN + b.HEIGHT + T),
							Size = UDim2.fromOffset(S, c),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ZIndex = I.HUD,
							Parent = x,
						}
					)
					for o, o in ipairs(W) do
						U(o)
						o.piece = false
					end
					x = N
					return x
				end
				local function o(b)
					local A = if b.open and b.body then G * 2 + #b.body * e else 0
					return (b.head or c) + 1 + A + R
				end
				J = string.char(34)
				local b = "closes in <font color=" .. J .. "%s" .. J .. ">%ds</font>, click to hold"
				local A = "<font color=" .. J .. "%s" .. J .. ">held open</font>, close it with the x"
				local T = "<font color=" .. J .. "%s" .. J .. ">working</font>, this closes when it is done"
				local function J(x)
					local d, L, n =
						math.floor(x.R * 255 + 0.5),
						math.floor(x.G * 255 + 0.5),
						p[14](math.floor(x.B * 255 + 0.5))
					return ("rgb(%d,%d,%d)"):format(d, L, p:oh(n))
				end
				local function p(x)
					local d, L, n =
						u.new(
							"Frame",
							{
								Name = "Line",
								AnchorPoint = Vector2.new(1, 0),
								Size = UDim2.fromOffset(S, c + 1 + R),
								BackgroundTransparency = 0,
								skin = { BackgroundColor3 = "window" },
								BorderSizePixel = 0,
								ClipsDescendants = true,
								ZIndex = x,
								Parent = N,
							}
						),
						u.new,
						{}
					n.CornerRadius, n.Parent = UDim.new(0, q), d
					L("UICorner", n)
					L = u.new("UIStroke", { Thickness = 1, Transparency = j, Parent = d })
					i.paint(L, { Color = "border" })
					local q, M, t =
						u.new(
							"ImageLabel",
							{
								Name = "Mark",
								Position = UDim2.fromOffset(w, (c - H) // 2),
								Size = UDim2.fromOffset(H, H),
								BackgroundTransparency = 1,
								ZIndex = x + 1,
								Parent = d,
							}
						),
						u.new(
							"TextLabel",
							{
								Name = "Title",
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.new(0, w + H + s, 0, c // 2),
								Size = UDim2.new(1, -(w * 2 + H + s + Q * 2 + Y + v), 0, m * B * 2),
								BackgroundTransparency = 1,
								Text = "",
								TextSize = B,
								skin = "text",
								FontFace = P.face(true),
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Center,
								TextWrapped = true,
								TextTruncate = Enum.TextTruncate.AtEnd,
								ZIndex = x + 1,
								Parent = d,
							}
						),
						u.new(
							"TextButton",
							{
								Name = "Close",
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -w, 0, c // 2),
								Size = UDim2.fromOffset(Q, Q),
								BackgroundTransparency = 1,
								AutoButtonColor = false,
								Text = "",
								ZIndex = x + 1,
								Parent = d,
							}
						)
					local v, m =
						u.new(
							"ImageLabel",
							{
								Name = "Mark",
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								skin = "faint",
								ZIndex = x + 2,
								Parent = t,
							}
						),
						f.get("close")
					if m then
						v.ImageContent = m
					end
					m = u.new(
						"TextButton",
						{
							Name = "Chevron",
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -(w + Q + Y), 0, c // 2),
							Size = UDim2.fromOffset(Q, Q),
							BackgroundTransparency = 1,
							AutoButtonColor = false,
							Text = "",
							Visible = false,
							ZIndex = x + 1,
							Parent = d,
						}
					)
					local B, X =
						u.new(
							"ImageLabel",
							{
								Name = "Mark",
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								skin = "faint",
								ZIndex = x + 2,
								Parent = m,
							}
						),
						f.get("chevron")
					if X then
						B.ImageContent = X
					end
					X, n =
						u.new(
							"Frame",
							{
								Name = "Rule",
								Position = UDim2.fromOffset(0, c),
								Size = UDim2.new(1, 0, 0, 1),
								skin = { BackgroundColor3 = "line" },
								BackgroundTransparency = a,
								BorderSizePixel = 0,
								ZIndex = x + 1,
								Parent = d,
							}
						),
						u.new(
							"TextButton",
							{
								Name = "Band",
								Position = UDim2.fromOffset(0, c + 1),
								Size = UDim2.new(1, 0, 0, R),
								skin = { BackgroundColor3 = "rowGlow" },
								BackgroundTransparency = C,
								BorderSizePixel = 0,
								AutoButtonColor = false,
								Text = "",
								ClipsDescendants = true,
								ZIndex = x + 1,
								Parent = d,
							}
						)
					local pH, JH, OH =
						u.new(
							"Frame",
							{
								Name = "Body",
								Position = UDim2.fromOffset(w, G),
								Size = UDim2.new(1, -w * 2, 0, 0),
								BackgroundTransparency = 1,
								ClipsDescendants = true,
								ZIndex = x + 2,
								Parent = n,
							}
						),
						u.new,
						{}
					OH.SortOrder, OH.Parent = Enum.SortOrder.LayoutOrder, pH
					JH("UIListLayout", OH)
					local JH, OH, uH, FH =
						u.new(
							"TextLabel",
							{
								Name = "Clock",
								AnchorPoint = Vector2.new(0, 1),
								Position = UDim2.new(0, w, 1, 0),
								Size = UDim2.new(1, -w * 2, 0, R),
								BackgroundTransparency = 1,
								RichText = true,
								Text = "",
								TextSize = g,
								skin = "faint",
								FontFace = P.face(),
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = x + 2,
								Parent = n,
							}
						),
						u.new(
							"Frame",
							{
								Name = "Wick",
								AnchorPoint = Vector2.new(0, 1),
								Position = UDim2.new(0, w, 1, 0),
								Size = UDim2.new(1, -w * 2, 0, E),
								BorderSizePixel = 0,
								ZIndex = x + 3,
								Parent = d,
							}
						),
						u.new,
						{}
					FH.CornerRadius, FH.Parent = UDim.new(0.5, 0), OH
					uH("UICorner", FH)
					local g = {
						root = d,
						edge = L,
						mark = q,
						title = M,
						chevron = m,
						chevronMark = B,
						close = t,
						closeMark = v,
						rule = X,
						band = n,
						body = pH,
						clock = JH,
						wick = OH,
						shade = Z.attach(d, x),
					}
					O.signal(t.MouseButton1Click, function()
						local q = g.entry
						if q then
							q.dead = true
						end
					end, "hud/toastclose")
					O.signal(m.MouseButton1Click, function()
						local q = g.entry
						if not q or not q.body then
							return
						end
						q.open = not q.open
						if q.open then
							q.held = true
						end
					end, "hud/toastopen")
					O.signal(n.MouseButton1Click, function()
						local O = g.entry
						if O then
							O.held = true
						end
					end, "hud/toasthold")
					return g
				end
				U = function(O)
					if not O.piece then
						return
					end
					pcall(function()
						O.piece.root:Destroy()
					end)
					if O.piece.shade then
						pcall(function()
							O.piece.shade:Destroy()
						end)
					end
					O.piece = nil
				end
				local function O(q, v)
					if v then
						return math.max(0, 1 - v / l)
					end
					if q < z then
						return q / z
					end
					return 1
				end
				local function q(v, m, B, g, z)
					local x = v.piece
					if v.lastX ~= B or v.lastY ~= g then
						v.lastX = B
						v.lastY = g
						x.root.Position = UDim2.new(1, B, 0, g)
					end
					B = v.head or c
					if v.lastHead ~= B then
						v.lastHead = B
						x.mark.Position = UDim2.fromOffset(w, (B - H) // 2)
						x.title.Position = UDim2.new(0, w + H + s, 0, B // 2)
						x.close.Position = UDim2.new(1, -w, 0, B // 2)
						x.chevron.Position = UDim2.new(1, -(w + Q + Y), 0, B // 2)
						x.rule.Position = UDim2.fromOffset(0, B)
						x.band.Position = UDim2.fromOffset(0, B + 1)
						v.lastH = nil
					end
					if v.lastH ~= z then
						v.lastH = z
						x.root.Size = UDim2.fromOffset(S, z)
						x.band.Size = UDim2.new(1, 0, 0, math.max(0, z - B - 1))
						x.body.Size = UDim2.new(1, -w * 2, 0, math.max(0, z - B - 1 - R - G * 2))
					end
					if v.lastLit == m then
						return
					end
					v.lastLit = m
					g = 1 - m
					x.root.BackgroundTransparency = g
					x.edge.Transparency = 1 - (1 - j) * m
					x.rule.BackgroundTransparency = 1 - (1 - a) * m
					x.band.BackgroundTransparency = 1 - (1 - C) * m
					x.title.TextTransparency = g
					x.mark.ImageTransparency = g
					x.closeMark.ImageTransparency = g
					x.chevronMark.ImageTransparency = g
					x.clock.TextTransparency = g
					x.wick.BackgroundTransparency = g
					if x.shade then
						x.shade.ImageTransparency = 1 - (1 - Z.TRANSPARENCY) * m
					end
				end
				local function Z()
					local S = os.clock()
					for G = #W, 1, -1 do
						local Q = W[G]
						if (Q.held or Q.pending) and not Q.dying then
							Q.born = S - math.min(S - Q.born, Q.life - l - 0.01)
						end
						if not Q.dying and (Q.dead or S - Q.born >= Q.life) then
							Q.dying = S
						end
						if Q.dying and S - Q.dying >= l then
							U(Q)
							table.remove(W, G)
						end
					end
					local G = 0
					for Q, Y in ipairs(W) do
						if Y.piece then
							if Y.head == false then
								Y.head = nil
							elseif not Y.head then
								Q = Y.piece.title.TextBounds.Y
								if Q > 0 then
									Y.head = math.max(c, Q + c - H)
								end
							end
							local H = S - Y.born
							local Q, s = O(H, Y.dying and S - Y.dying or nil), o(Y)
							Y.y = Y.y + (G - Y.y) * 0.25
							Y.h = Y.h + (s - Y.h) * 0.3
							s = math.floor(Y.h + 0.5)
							q(
								Y,
								math.floor(Q * 100 + 0.5) / 100,
								math.floor(D * (1 - Q) + 0.5),
								math.floor(Y.y + 0.5),
								s
							)
							if Y.body and Y.lastOpen ~= Y.open then
								Y.lastOpen = Y.open
								Y.piece.chevronMark.Rotation = Y.open and 180 or 0
							end
							Q = math.max(0, Y.life - H)
							H = (Y.held or Y.pending) and 1 or math.clamp(Q / Y.life, 0, 1)
							Y.piece.wick.Size = UDim2.new(H, -w * 2 * H, 0, E)
							if Y.pending then
								Y.piece.mark.Rotation = S / h.SPIN * 360 % 360
							end
							H = Y.pending and T:format(J(i.get("text")))
								or (
									Y.held and A:format(J(i.get("text")))
									or b:format(J(i.get("text")), math.max(1, math.ceil(Q)))
								)
							if Y.said ~= H then
								Y.said = H
								Y.piece.clock.Text = H
							end
							G = G + s + r
						else
						end
					end
					S = N
					if S then
						local J = N
						J.Visible = #W > 0
					end
				end
				h.push = function(J)
					if typeof(J) ~= "table" then
						return h
					end
					local O = J.text
					if typeof(O) ~= "string" or O == "" then
						return h
					end
					local o = if typeof(J.body) == "table" and #J.body > 0 then J.body else nil
					if #W >= K then
						local b = W[#W]
						if not b.dying then
							b.dead = true
						end
					end
					local b = {
						text = O,
						bad = J.bad and true or false,
						body = o,
						born = os.clock(),
						life = typeof(J.life) == "number" and J.life or h.LIFE,
						pending = J.pending and true or false,
						open = false,
						held = false,
						dead = false,
						dying = nil,
						y = 0,
						h = c + 1 + R,
						piece = false,
					}
					table.insert(W, 1, b)
					return b
				end
				h.settle = function(J, O)
					if typeof(J) ~= "table" or not J.pending then
						return h
					end
					O = if typeof(O) ~= "table" then {} else O
					J.pending = false
					J.born = os.clock()
					J.life = typeof(O.life) == "number" and O.life or h.SETTLED
					if typeof(O.text) == "string" and O.text ~= "" then
						J.text = O.text
						if J.piece then
							J.piece.title.Text = O.text
							J.head = false
						end
					end
					J.bad = O.bad and true or false
					J.said = nil
					if J.piece then
						local O, o =
							f.get(J.bad and "badRing" or "okRing"), J.bad and i.get("danger") or y.get()
						if O then
							J.piece.mark.ImageContent = O
						end
						J.piece.mark.Rotation = 0
						J.piece.mark.ImageColor3 = o
						J.piece.wick.BackgroundColor3 = o
					end
					return h
				end
				local function J(O)
					for o, b in ipairs(W) do
						if b.piece == false then
							o = p(O)
							b.piece = o
							o.entry = b
							o.title.Text = b.text
							local p = b.bad and i.get("danger") or y.get()
							o.wick.BackgroundColor3 = p
							o.mark.ImageColor3 = p
							local i, y = f.get, b.pending and "refresh" or (b.bad and "badRing" or "okRing")
							p = i(y)
							if p then
								o.mark.ImageContent = p
							end
							if b.body then
								o.chevron.Visible = true
								for f, i in ipairs(b.body) do
									p = tostring(i):sub(1, 1) == "+"
									u.new(
										"TextLabel",
										{
											Name = "L" .. f,
											LayoutOrder = f,
											Size = UDim2.new(1, 0, 0, e),
											BackgroundTransparency = 1,
											Text = tostring(i),
											TextSize = k,
											skin = p and "add" or "remove",
											FontFace = P.face(),
											TextXAlignment = Enum.TextXAlignment.Left,
											TextTruncate = Enum.TextTruncate.AtEnd,
											ZIndex = O + 3,
											Parent = o.body,
										}
									)
								end
							end
						end
					end
				end
				h.enable = function(p)
					p = p and true or false
					local O = V
					if p == O then
						return h
					end
					V = p
					O = not p
					if O then
						F.stop(h.BIND)
						for p, p in ipairs(W) do
							U(p)
						end
						table.clear(W)
						local p = N
						if p then
							N.Visible = false
						end
						return h
					end
					F.onDraw(h.BIND, function()
						if not _() then
							return
						end
						J(I.HUD)
						Z()
					end)
					return h
				end
				h.reset = function()
					h.enable(false)
					table.clear(W)
					local p = N
					if p then
						pcall(function()
							N:Destroy()
						end)
						N = nil
					end
				end
				return h
			end
end)()

_registry["ui/tooltip"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/metrics")
				local F = p("ui/motion")
				local f = p("ui/icon")
				local o = p("ui/popup")
				local Z = p("ui/shadow")
				local i = p("ui/font")
				local y, P, b, I, h =
					p("ui/zindex"),
					{ DWELL = 0.45, OFFSET = 8, SLIDE = 6, MAX_WIDTH = 220, PAD_X = 7, SURFACE = "raised", TEXT = "body" }
				local p, A = false, 0
				local function T()
					local r = b and b.Parent
					if r then
						local S = b
						return S
					end
					r = o.host
					if not r then
						return nil
					end
					b = O.new(
						"TextLabel",
						{
							Name = "Tooltip",
							AnchorPoint = Vector2.new(0, 0.5),
							AutomaticSize = Enum.AutomaticSize.XY,
							Size = UDim2.fromOffset(0, 0),
							BorderSizePixel = 0,
							Text = "",
							TextSize = u.textSize - 1,
							skin = { BackgroundColor3 = P.SURFACE, TextColor3 = P.TEXT },
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							FontFace = i.face(),
							TextTransparency = 1,
							BackgroundTransparency = 1,
							Visible = false,
							ZIndex = y.TOOLTIP,
							Parent = r,
						}
					)
					local i, S = O.new, {}
					S.CornerRadius, S.Parent = UDim.new(0, u.corner), b
					i("UICorner", S)
					O.new("UIStroke", { Thickness = u.stroke, skin = "border", Transparency = 1, Parent = b })
					O.new(
						"UIPadding",
						{
							PaddingTop = UDim.new(0, 4),
							PaddingBottom = UDim.new(0, 4),
							PaddingLeft = UDim.new(0, P.PAD_X),
							PaddingRight = UDim.new(0, P.PAD_X),
							Parent = b,
						}
					)
					i, S = O.new, {}
					S.MaxSize, S.Parent = Vector2.new(P.MAX_WIDTH, 1 / 0), b
					i("UISizeConstraint", S)
					h = Z.attach(b, y.TOOLTIP)
					i, S = f.dimensions("tooltipArrow")
					I = O.new(
						"ImageLabel",
						{
							Name = "TooltipArrow",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Size = UDim2.fromOffset(i or 7, S or 12),
							BackgroundTransparency = 1,
							ImageContent = f.get("tooltipArrow"),
							skin = P.SURFACE,
							ImageTransparency = 1,
							Visible = false,
							ZIndex = y.TOOLTIP + 1,
							Parent = r,
						}
					)
					i = b
					return i
				end
				local function O(u, f, i, y)
					local r = I
					if not r then
						return
					end
					r = I.Size.X.Offset
					if y then
						local y = I
						y.Position = UDim2.fromOffset(u + i + r / 2 - 1, f)
						I.Rotation = 180
					else
						local i = I
						i.Position = UDim2.fromOffset(u - r / 2 + 1, f)
						I.Rotation = 0
					end
					I.Visible = true
				end
				local function u(f)
					local i = f and F.HOVER_IN or F.HOVER_OUT
					local y, r =
						F.to(
							b,
							i,
							{ BackgroundTransparency = f and 0.05 or 1, TextTransparency = f and 0 or 1 }
						),
						b:FindFirstChildOfClass("UIStroke")
					if r then
						local S, c = F.to, {}
						c.Transparency = f and 0 or 1
						S(r, i, c)
					end
					r = I
					if r then
						local r, S, c = F.to, I, {}
						c.ImageTransparency = f and 0.05 or 1
						r(S, i, c)
					end
					Z.fade(h, f, i)
					return y
				end
				local function f(Z)
					local i = o.host
					if not i or not Z then
						return
					end
					local y, h, r = i.AbsolutePosition, Z.AbsolutePosition, Z.AbsoluteSize
					local S, c = h.X - y.X + r.X + P.OFFSET, h.Y - y.Y + r.Y / 2
					Z = S + b.AbsoluteSize.X > i.AbsoluteSize.X
					S = if Z then h.X - y.X - b.AbsoluteSize.X - P.OFFSET else S
					h = b.AbsoluteSize
					return S, c, Z, h.X
				end
				local function Z()
					A += 1
					local i = p
					if not i then
						return
					end
					p = false
					local i, y = u(false), A
					local function h()
						b.Visible = false
						local r = I
						if r then
							I.Visible = false
						end
					end
					if i then
						i.Completed:Once(function()
							local i = y == A and not p
							if i then
								h()
							end
						end)
					else
						h()
					end
				end
				local function i(y, h)
					if not T() then
						return
					end
					A += 1
					local T = A
					J.thread(function()
						task.wait(P.DWELL)
						local r = A
						if T ~= r then
							return
						end
						if o.blocks(y) then
							return
						end
						b.TextWrapped = false
						r = b
						r.AutomaticSize = Enum.AutomaticSize.XY
						r = b
						r.Size = UDim2.fromOffset(0, 0)
						b.Text = h
						b.Visible = true
						task.wait()
						r = T ~= A
						if r then
							b.Visible = false
							return
						end
						r = b.TextBounds.X + P.PAD_X * 2 > P.MAX_WIDTH
						if r then
							local h = b
							h.AutomaticSize = Enum.AutomaticSize.Y
							b.TextWrapped = true
							h = b
							h.Size = UDim2.fromOffset(P.MAX_WIDTH, 0)
							task.wait()
							h = T ~= A
							if h then
								b.Visible = false
								return
							end
						end
						local h, T, S, c = f(y)
						if not h then
							return
						end
						O(h, T, c, S)
						local O, f, y = S and P.SLIDE or -P.SLIDE, I.Position.X.Offset, b
						y.Position = UDim2.fromOffset(h + O, T)
						c = I
						c.Position = UDim2.fromOffset(f + O, T)
						p = true
						u(true)
						O, y, S, r = F.to, b, F.HOVER_IN, {}
						r.Position = UDim2.fromOffset(h, T)
						O(y, S, r)
						S, O, y, r = F.to, I, F.HOVER_IN, {}
						r.Position = UDim2.fromOffset(f, T)
						S(O, y, r)
					end)
				end
				P.attach = function(O, u)
					if not O or typeof(u) ~= "string" or u == "" then
						return
					end
					J.signal(O.InputBegan, function(F)
						if F.UserInputType == Enum.UserInputType.MouseMovement then
							if o.blocks(O) then
								return
							end
							i(O, u)
						end
					end, "tooltip/enter")
					J.signal(O.InputEnded, function(J)
						if J.UserInputType == Enum.UserInputType.MouseMovement then
							Z()
						end
					end, "tooltip/leave")
				end
				P.dismiss = function()
					local J = b
					if not J then
						return
					end
					A += 1
					p = false
					pcall(function()
						b.Visible = false
						b.BackgroundTransparency = 1
						b.TextTransparency = 1
						local p = I
						if p then
							I.Visible = false
							I.ImageTransparency = 1
						end
					end)
				end
				return P
			end
end)()

_registry["ui/warning"] = (function()

return function(p)
				local J = p("ui/connect")
				local O = p("ui/create")
				local u = p("ui/metrics")
				local F = p("ui/motion")
				local f = p("ui/popup")
				local o = p("ui/skin")
				local Z = p("ui/theme")
				local i = p("ui/font")
				local y = p("ui/zindex")
				local p, P, b, I, h, A, T = {
					VEIL = 0.4,
					WIDTH = 320,
					PAD = 16,
					GAP = 10,
					BUTTON_W = 104,
					BUTTON_H = 26,
					RISE = 12,
					INFO = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					OK = "ok",
					YES = "confirm",
					NO = "cancel",
				}
				local r, S = {}
				local function c(R, e, G, q)
					local w = O.new(
						"TextButton",
						{
							Name = "Choice" .. R,
							LayoutOrder = R,
							Size = UDim2.fromOffset(p.BUTTON_W, p.BUTTON_H),
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = e,
							TextSize = u.textSize,
							FontFace = i.face(),
							skin = { BackgroundColor3 = "control", TextColor3 = "text" },
							ZIndex = y.MODAL + 2,
							Parent = A,
						}
					)
					local e, H = O.new, {}
					H.CornerRadius, H.Parent = UDim.new(0, u.corner), w
					e("UICorner", H)
					e = O.new("UIStroke", { Thickness = u.stroke, skin = "stroke", Parent = w })
					if G then
						Z.follow(e, "Color")
					end
					J.signal(w.MouseEnter, function()
						local Z, e, G = F.to, F.HOVER_IN, {}
						G.BackgroundColor3 = o.get("hover")
						Z(w, e, G)
					end, "warning/enter" .. R)
					J.signal(w.MouseLeave, function()
						local Z, e, G = F.to, F.HOVER_OUT, {}
						G.BackgroundColor3 = o.get("control")
						Z(w, e, G)
					end, "warning/leave" .. R)
					J.signal(w.Activated, function()
						p.answer(q)
					end, "warning/click" .. R)
					table.insert(r, w)
					return w
				end
				p.attach = function(o)
					local Z = b or not o
					if Z then
						local R = b
						return R
					end
					P = o
					b = O.new(
						"TextButton",
						{
							Name = "Warning",
							Size = UDim2.fromScale(1, 1),
							BackgroundColor3 = Color3.new(),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							AutoButtonColor = false,
							Text = "",
							Visible = false,
							Active = true,
							ZIndex = y.MODAL,
							Parent = P,
						}
					)
					I = O.new(
						"Frame",
						{
							Name = "Panel",
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(p.WIDTH, 0),
							BorderSizePixel = 0,
							skin = "raised",
							ZIndex = y.MODAL + 1,
							Parent = b,
						}
					)
					o, Z = O.new, {}
					Z.CornerRadius, Z.Parent = UDim.new(0, u.corner + 2), I
					o("UICorner", Z)
					O.new("UIStroke", { Thickness = u.stroke, skin = "border", Parent = I })
					T = O.new(
						"UIListLayout",
						{
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, p.GAP),
							Parent = I,
						}
					)
					O.new(
						"UIPadding",
						{
							PaddingTop = UDim.new(0, p.PAD),
							PaddingBottom = UDim.new(0, p.PAD),
							PaddingLeft = UDim.new(0, p.PAD),
							PaddingRight = UDim.new(0, p.PAD),
							Parent = I,
						}
					)
					h = O.new(
						"TextLabel",
						{
							Name = "Message",
							LayoutOrder = 1,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							BackgroundTransparency = 1,
							Text = "",
							TextSize = u.textSize,
							FontFace = i.face(),
							TextWrapped = true,
							RichText = true,
							skin = "text",
							ZIndex = y.MODAL + 2,
							Parent = I,
						}
					)
					A = O.new(
						"Frame",
						{
							Name = "Choices",
							LayoutOrder = 2,
							Size = UDim2.new(1, 0, 0, p.BUTTON_H),
							BackgroundTransparency = 1,
							ZIndex = y.MODAL + 1,
							Parent = I,
						}
					)
					Z, o =
						O.new,
						{
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}
					o.Padding, o.Parent = UDim.new(0, p.GAP), A
					Z("UIListLayout", o)
					J.signal(T:GetPropertyChangedSignal("AbsoluteContentSize"), function()
						p.resize()
					end, "warning/size")
					o = b
					return o
				end
				p.resize = function()
					local J = not I or not T
					if J then
						return
					end
					J = T.AbsoluteContentSize.Y
					if J <= 0 then
						return
					end
					local O = I
					O.Size = UDim2.fromOffset(p.WIDTH, J + p.PAD * 2)
				end
				p.answer = function(J)
					local O = S
					local u = O
					S = nil
					p.hide()
					if u then
						task.spawn(u, J)
					end
				end
				p.hide = function()
					local J = b
					if not J then
						return
					end
					F.to(b, F.HOVER_OUT, { BackgroundTransparency = 1 })
					local J, O, u, o = F.to, I, F.HOVER_OUT, {}
					o.Position = UDim2.new(0.5, 0, 0.5, p.RISE)
					J(O, u, o)
					task.delay(F.HOVER_OUT.Time, function()
						local J = b and not S
						if J then
							b.Visible = false
						end
					end)
				end
				local function J(O, u)
					local o = b
					if not o then
						return nil
					end
					pcall(f.closeAll)
					o = r
					for f, f in ipairs(o) do
						f:Destroy()
					end
					r = {}
					o = h
					o.Text = tostring(O or "")
					for f, o in ipairs(u) do
						c(f, o.label, o.primary, o.value)
					end
					b.Visible = true
					b.BackgroundTransparency = 1
					O = I
					O.Position = UDim2.new(0.5, 0, 0.5, p.RISE)
					p.resize()
					F.to(b, p.INFO, { BackgroundTransparency = p.VEIL })
					local O, u, f, o = F.to, I, p.INFO, {}
					o.Position = UDim2.fromScale(0.5, 0.5)
					O(u, f, o)
					S = coroutine.running()
					return coroutine.yield()
				end
				p.alert = function(O)
					return J(O, { { label = p.OK, primary = true, value = true } })
				end
				p.confirm = function(O)
					return J(
						O,
						{ { label = p.NO, primary = false, value = false }, {
							label = p.YES,
							primary = true,
							value = true,
						} }
					)
				end
				p.isOpen = function()
					local J = S
					return J ~= nil
				end
				p.reset = function()
					P, b, I, h, A, T, r, S = nil, nil, nil, nil, nil, nil, {}, nil
				end
				return p
			end
end)()

_registry["ui/zindex"] = (function()

return function(p)
				return {
					HUD = 1,
					BUBBLE = 8,
					WORLD = 10,
					WINDOW = 20,
					WIDGET = 30,
					POPUP = 50,
					POPUP_CONTENT = 60,
					POPUP_NESTED = 65,
					POPUP_NESTED_CONTENT = 70,
					TOOLTIP = 80,
					MODAL = 90,
					TOP = 100,
				}
			end
end)()


return requireModule('core/entry')


-- ───────────────────────────── export ─────────────────────────────
local Library = requireModule("ui/library")

Library.Toast      = requireModule("ui/toast")       -- Library.Toast.push({text=..}) / .settle(id,{..}) / .enable(true)
Library.Warning    = requireModule("ui/warning")     -- Library.Warning.confirm("are you sure?")
Library.Keybind    = requireModule("ui/keybind")     -- Library.Keybind.capture(cb) / .label(keycode)
Library.Font       = requireModule("ui/font")
Library.Skin       = requireModule("ui/skin")        -- dark / light mode
Library.Icon       = requireModule("ui/icon")
Library.Tooltip    = requireModule("ui/tooltip")
Library.Popup      = requireModule("ui/popup")
Library.Mount      = requireModule("ui/mount")
Library.Create     = requireModule("ui/create")
Library.Connect    = requireModule("ui/connect")
Library.Motion     = requireModule("ui/motion")
Library.Services   = requireModule("core/service")

return Library
