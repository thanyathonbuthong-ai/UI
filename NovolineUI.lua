-- ============================================================================
--  NovolineUI 1.1  ·  standalone UI library  (build: standalone)
--  Extracted from BasedHub's Novoline look. Single self-contained file that
--  runs in any Roblox executor.
--
--  Built in, exactly as in BasedHub:
--    Home      the welcome deck: clock and executor, your profile, Quick
--              actions, Now playing, Quick Commands, the game, this server
--              (Rejoin / Server hop) and your friends online
--    Music     the real player (SoundCloud, Audius, your files, a link)
--    Keys      every key on a keyboard
--    Settings  colour, font, size, shade, dock, motion, sound, keys, configs
--    Profile   the card at the top right opens Music, Keys, Settings, Close, Unload
--  Your own tabs go between Home and Music.
--
--  Usage:
--    local NovolineUI = loadstring(game:HttpGet("..."))()
--    local win = NovolineUI:CreateWindow({ Name = "My UI", Key = "RightShift" })
--    local tab = win:CreateTab("Main", "flame")
--    tab:Toggle({ Name = "Enabled", Flag = "main.enabled", Default = true,
--                 Callback = function(v) print("toggle", v) end })
--    -- (full example at the bottom of this file)
-- ============================================================================

local B = { VERSION = "NovolineUI 1.0", BUILD = "standalone" }
local NovolineUI   -- forward declaration; assigned in the api layer below

B.MANIFEST = {["files"]={["fonts/Archivo-ExpandedBlack.ttf"]="a55ca833",["fonts/Archivo-ExpandedBold.ttf"]="ffbf2077",["fonts/GeistMono-Medium.ttf"]="8332ab04",["fonts/GeistMono-Regular.ttf"]="c192a4ad",["fonts/InstrumentSerif-Italic.ttf"]="cfeb4692",["fonts/InstrumentSerif-Regular.ttf"]="760dce2e",["fonts/Inter-Bold.ttf"]="6fe5683d",["fonts/Inter-Medium.ttf"]="ad5bac14",["fonts/Inter-Regular.ttf"]="ec9fcd4d",["fonts/Inter-SemiBold.ttf"]="186e2a94",["fonts/Monocraft.ttf"]="0a54bca7",["fonts/ProggyClean.ttf"]="472c72d3",["fonts/ProggyTiny.ttf"]="c5ee3a40",["fx/bh_flight_pack.lua"]="d7594695",["img/arrow_2978718f.png"]="2978718f",["img/chevron_5862bda1.png"]="5862bda1",["img/dot_88aed008.png"]="88aed008",["img/esp_box_af236fc2.png"]="af236fc2",["img/esp_corner_57de7310.png"]="57de7310",["img/esp_glow_4714e388.png"]="4714e388",["img/esp_round_0a2b8705.png"]="0a2b8705",["img/glow_b92f0e11.png"]="b92f0e11",["img/grain_ccc6d981.png"]="ccc6d981",["img/icons_aed91083.png"]="aed91083",["img/line_d9684f60.png"]="d9684f60",["img/line_glow_b4fb854c.png"]="b4fb854c",["img/noise_b6e30457.png"]="b6e30457",["img/ring_1541da6c.png"]="1541da6c",["img/shock_3531fe60.png"]="3531fe60",["img/speedlines_64815646.png"]="64815646",["img/vignette_94d218e2.png"]="94d218e2",["img/wm_A_ace1a1fc.png"]="ace1a1fc",["img/wm_B_e3ad8d5d.png"]="e3ad8d5d",["img/wm_D_0312b32a.png"]="0312b32a",["img/wm_E_f66e6465.png"]="f66e6465",["img/wm_hub_604a3cba.png"]="604a3cba",["img/wm_S_3daf2f74.png"]="3daf2f74",["sfx/bh_click.ogg"]="3fd39a5b",["sfx/bh_close.ogg"]="827837c5",["sfx/bh_fly_boom.ogg"]="39b42154",["sfx/bh_fly_land.ogg"]="9e0889fa",["sfx/bh_fly_takeoff.ogg"]="04b9cbfd",["sfx/bh_fly_wind.ogg"]="fe17eb5d",["sfx/bh_hit_bell.ogg"]="589e0d98",["sfx/bh_hit_blip.ogg"]="a200d2ba",["sfx/bh_hit_chirp.ogg"]="16667041",["sfx/bh_hit_clack.ogg"]="8a9ffa7e",["sfx/bh_hit_coin.ogg"]="3d458f74",["sfx/bh_hit_ding.ogg"]="4413c30a",["sfx/bh_hit_glass.ogg"]="71701f8e",["sfx/bh_hit_kill_bass.ogg"]="fdaf9a05",["sfx/bh_hit_kill_chime.ogg"]="f5fc778e",["sfx/bh_hit_kill_coins.ogg"]="003c96e4",["sfx/bh_hit_kill_gong.ogg"]="b5a250bf",["sfx/bh_hit_kill_sweep.ogg"]="814df70a",["sfx/bh_hit_pop.ogg"]="35af5b1d",["sfx/bh_hit_punch.ogg"]="62c63220",["sfx/bh_hit_snap.ogg"]="9d0f6f51",["sfx/bh_hit_thud.ogg"]="82420e99",["sfx/bh_hit_tick.ogg"]="bff8fe87",["sfx/bh_hit_zap.ogg"]="fd9f125d",["sfx/bh_hover.ogg"]="bf7df59b",["sfx/bh_open.ogg"]="3a6618eb",["sfx/bh_saved.ogg"]="778f174a",["sfx/bh_tab.ogg"]="2b9384b9",["sfx/bh_toggle_off.ogg"]="f55696b4",["sfx/bh_toggle_on.ogg"]="0fab2e62"},["icons"]={["image"]="img/icons_aed91083.png",["cell"]=48,["cols"]=20,["map"]={["house"]=0,["layout-dashboard"]=1,["gamepad-2"]=2,["crosshair"]=3,["eye"]=4,["eye-off"]=5,["wind"]=6,["users"]=7,["user"]=8,["globe"]=9,["earth"]=10,["settings"]=11,["settings-2"]=12,["search"]=13,["x"]=14,["minus"]=15,["plus"]=16,["check"]=17,["chevron-down"]=18,["chevron-up"]=19,["chevron-right"]=20,["chevron-left"]=21,["chevrons-up-down"]=22,["ellipsis"]=23,["sliders-horizontal"]=24,["palette"]=25,["keyboard"]=26,["bell"]=27,["save"]=28,["download"]=29,["upload"]=30,["trash-2"]=31,["copy"]=32,["refresh-cw"]=33,["rotate-ccw"]=34,["power"]=35,["shield"]=36,["shield-check"]=37,["zap"]=38,["sparkles"]=39,["film"]=40,["clapperboard"]=41,["volume-2"]=42,["volume-x"]=43,["play"]=44,["pause"]=45,["skip-forward"]=46,["user-check"]=47,["user-x"]=48,["map-pin"]=49,["navigation"]=50,["target"]=51,["scan"]=52,["bone"]=53,["heart-pulse"]=54,["ruler"]=55,["tag"]=56,["plane"]=57,["footprints"]=58,["arrow-up"]=59,["arrow-down"]=60,["arrow-right"]=61,["arrow-left"]=62,["ghost"]=63,["mouse-pointer-click"]=64,["mouse-pointer-2"]=65,["sun"]=66,["moon"]=67,["cloud-fog"]=68,["clock"]=69,["camera"]=70,["monitor"]=71,["gauge"]=72,["wifi"]=73,["server"]=74,["link"]=75,["log-out"]=76,["shuffle"]=77,["lock"]=78,["lock-open"]=79,["info"]=80,["triangle-alert"]=81,["circle-alert"]=82,["circle-check"]=83,["circle"]=84,["star"]=85,["pin"]=86,["command"]=87,["corner-down-left"]=88,["hand"]=89,["maximize-2"]=90,["minimize-2"]=91,["panel-left"]=92,["layers"]=93,["box"]=94,["package"]=95,["puzzle"]=96,["code"]=97,["terminal"]=98,["flask-conical"]=99,["wand-sparkles"]=100,["swords"]=101,["sword"]=102,["rocket"]=103,["flame"]=104,["contrast"]=105,["droplet"]=106,["droplets"]=107,["blend"]=108,["type"]=109,["history"]=110,["folder"]=111,["file-json"]=112,["clipboard"]=113,["clipboard-paste"]=114,["external-link"]=115,["grip-vertical"]=116,["filter"]=117,["list"]=118,["grid-2x2"]=119,["image"]=120,["music"]=121,["timer"]=122,["activity"]=123,["radar"]=124,["focus"]=125,["aperture"]=126,["scan-eye"]=127,["view"]=128,["binoculars"]=129,["locate"]=130,["locate-fixed"]=131,["route"]=132,["compass"]=133,["anchor"]=134,["feather"]=135,["square"]=136,["square-dashed"]=137,["person-standing"]=138,["move"]=139,["move-3d"]=140,["orbit"]=141,["trees"]=142,["mountain"]=143,["lightbulb"]=144,["sunrise"]=145,["bug"]=146,["wrench"]=147,["hammer"]=148,["cpu"]=149,["hard-drive"]=150,["database"]=151,["cloud"]=152,["cloud-download"]=153,["circle-dot"]=154,["dot"]=155,["badge-check"]=156,["crown"]=157,["gem"]=158,["trophy"]=159,["flag"]=160,["bookmark"]=161,["heart"]=162,["skull"]=163,["axe"]=164,["bomb"]=165,["car"]=166,["leaf"]=167,["snowflake"]=168,["plug"]=169,["radio"]=170,["signal"]=171,["fingerprint"]=172,["key-round"]=173,["key"]=174,["door-open"]=175,["app-window"]=176,["fullscreen"]=177,["expand"]=178,["shrink"]=179,["rotate-3d"]=180,["scaling"]=181,["pipette"]=182,["paintbrush"]=183,["brush"]=184,["eraser"]=185,["wand"]=186,["magnet"]=187,["waypoints"]=188,["git-branch"]=189,["share-2"]=190,["send"]=191,["message-circle"]=192,["at-sign"]=193,["hash"]=194,["circle-user"]=195,["user-round"]=196,["users-round"]=197,["id-card"]=198,["megaphone"]=199,["apple"]=200,["tree-pine"]=201,["sprout"]=202,["glasses"]=203,["scan-line"]=204,["vibrate"]=205,["proportions"]=206,["ratio"]=207,["spline"]=208,["arrow-up-right"]=209,["circle-play"]=210,["circle-pause"]=211,["circle-x"]=212,["circle-plus"]=213,["circle-minus"]=214,["toggle-left"]=215,["toggle-right"]=216,["text-cursor-input"]=217,["align-left"]=218,["monitor-smartphone"]=219,["smartphone"]=220,["tablet"]=221,["laptop"]=222,["mouse"]=223,["joystick"]=224,["dices"]=225,["swatch-book"]=226,["sun-moon"]=227,["paint-bucket"]=228,["square-mouse-pointer"]=229,["baseline"]=230,["skip-back"]=231,["repeat"]=232,["repeat-1"]=233,["list-plus"]=234,["list-music"]=235,["list-x"]=236,["headphones"]=237,["disc-3"]=238,["library"]=239,["layout-grid"]=240,["audio-lines"]=241,["folder-open"]=242,["file-music"]=243,["pencil"]=244,["heart-off"]=245}},["img"]={["noise"]="img/noise_b6e30457.png",["grain"]="img/grain_ccc6d981.png",["glow"]="img/glow_b92f0e11.png",["vignette"]="img/vignette_94d218e2.png",["line"]="img/line_d9684f60.png",["arrow"]="img/arrow_2978718f.png",["dot"]="img/dot_88aed008.png",["ring"]="img/ring_1541da6c.png",["esp_box"]="img/esp_box_af236fc2.png",["esp_corner"]="img/esp_corner_57de7310.png",["esp_round"]="img/esp_round_0a2b8705.png",["esp_glow"]="img/esp_glow_4714e388.png",["line_glow"]="img/line_glow_b4fb854c.png",["chevron"]="img/chevron_5862bda1.png",["speedlines"]="img/speedlines_64815646.png",["shock"]="img/shock_3531fe60.png"},["wordmark"]={["glyphs"]={{["char"]="B",["image"]="img/wm_B_e3ad8d5d.png",["w"]=606,["h"]=460,["advance"]=558.0},{["char"]="A",["image"]="img/wm_A_ace1a1fc.png",["w"]=621,["h"]=460,["advance"]=572.4},{["char"]="S",["image"]="img/wm_S_3daf2f74.png",["w"]=578,["h"]=460,["advance"]=529.2},{["char"]="E",["image"]="img/wm_E_f66e6465.png",["w"]=564,["h"]=460,["advance"]=516.0},{["char"]="D",["image"]="img/wm_D_0312b32a.png",["w"]=608,["h"]=460,["advance"]=559.8}},["cap"]=412,["pad"]=24,["size"]=600,["hub"]={["image"]="img/wm_hub_604a3cba.png",["w"]=901,["h"]=777,["baseline"]=579.0,["xHeight"]=285.6,["pad"]=24.0}},["sfx"]={["click"]="sfx/bh_click.ogg",["close"]="sfx/bh_close.ogg",["hover"]="sfx/bh_hover.ogg",["open"]="sfx/bh_open.ogg",["saved"]="sfx/bh_saved.ogg",["tab"]="sfx/bh_tab.ogg",["toggle_off"]="sfx/bh_toggle_off.ogg",["toggle_on"]="sfx/bh_toggle_on.ogg",["fly_boom"]="sfx/bh_fly_boom.ogg",["fly_takeoff"]="sfx/bh_fly_takeoff.ogg",["fly_land"]="sfx/bh_fly_land.ogg",["fly_wind"]="sfx/bh_fly_wind.ogg",["hit_tick"]="sfx/bh_hit_tick.ogg",["hit_pop"]="sfx/bh_hit_pop.ogg",["hit_blip"]="sfx/bh_hit_blip.ogg",["hit_clack"]="sfx/bh_hit_clack.ogg",["hit_snap"]="sfx/bh_hit_snap.ogg",["hit_thud"]="sfx/bh_hit_thud.ogg",["hit_punch"]="sfx/bh_hit_punch.ogg",["hit_bell"]="sfx/bh_hit_bell.ogg",["hit_ding"]="sfx/bh_hit_ding.ogg",["hit_glass"]="sfx/bh_hit_glass.ogg",["hit_coin"]="sfx/bh_hit_coin.ogg",["hit_zap"]="sfx/bh_hit_zap.ogg",["hit_chirp"]="sfx/bh_hit_chirp.ogg",["hit_kill_chime"]="sfx/bh_hit_kill_chime.ogg",["hit_kill_bass"]="sfx/bh_hit_kill_bass.ogg",["hit_kill_coins"]="sfx/bh_hit_kill_coins.ogg",["hit_kill_gong"]="sfx/bh_hit_kill_gong.ogg",["hit_kill_sweep"]="sfx/bh_hit_kill_sweep.ogg"},["fx"]={["flight"]="fx/bh_flight_pack.lua"}}

B.FILM = {["version"]=1,["fps"]=60,["count"]=1122,["duration"]=18.7,["gap"]={174,353},["drop"]=5.9333,["cuts"]={1.7167,2.8833,5.9333,6.8833,7.6167,8.3833,9.2167,10.05,10.75,11.3833,12.3333,13.15,13.95,14.65,15.5167,16.25,17.0167,17.7833,18.3167},["audio"]="film/bhf1_audio.ogg",["sets"]={["hd"]={["width"]=1024,["height"]=576,["digits"]=4,["tiles"]={{["path"]="film/hd/bhf1_h_",["x"]=0,["w"]=1,["rectX"]=0,["rectW"]=1024,["texW"]=1024}}},["ultra"]={["width"]=1820,["height"]=1024,["digits"]=4,["tiles"]={{["path"]="film/ultra/bhf1_l_",["x"]=0,["w"]=0.5,["rectX"]=0,["rectW"]=910,["texW"]=912},{["path"]="film/ultra/bhf1_r_",["x"]=0.5,["w"]=0.5,["rectX"]=2,["rectW"]=910,["texW"]=912}}}}}

-- external holes (all guarded / nil-safe in core; listed here for clarity)
B.PC_HELPER = "# BASED Hub - music on this PC\n#\n# The hub's \"Music on this PC\" writes this out (as based-music.txt: executors refuse .ps1) and copies\n# the one command that starts it (Win+R, paste, Enter).\n# It reads what Windows says is playing (Spotify, Apple Music, a browser, any app that shows in the\n# volume flyout) and writes it to now.json beside this file, with the cover. The hub writes what to\n# do (play, pause, skip, seek, volume, shuffle, repeat) to do.json, and this does it. Nothing else is\n# read, and nothing is sent anywhere. It closes itself when the game has been gone for 20 minutes, or\n# when the hub says \"quit\". Windows PowerShell 5.1 (the one built into Windows 10 and 11).\nparam([string]$Dir = $PSScriptRoot)\n\n$ErrorActionPreference = 'Stop'\n$mutex = New-Object System.Threading.Mutex($false, 'Local\\BASEDHubMusicOnThisPC')\nif (-not $mutex.WaitOne(0)) { exit }\ntry { [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = 'BelowNormal' } catch {}\n\n$utf8 = New-Object System.Text.UTF8Encoding($false)\n$logPath = Join-Path $Dir 'helper.log'\ntry { if ((Test-Path $logPath) -and (Get-Item $logPath).Length -gt 65536) { Remove-Item $logPath -Force } } catch {}\nfunction Log([string]$text) {\n  try { [IO.File]::AppendAllText($logPath, ('{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $text) + \"`r`n\", $utf8) } catch {}\n}\nfunction NowMs() { [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() }\n$nowPath = Join-Path $Dir 'now.json'\n$doPath = Join-Path $Dir 'do.json'\n$alivePath = Join-Path $Dir 'alive.txt'\nfunction Put($state) {\n  $state.v = 1\n  $state.at = NowMs\n  $state.pid = $PID\n  $text = $state | ConvertTo-Json -Compress -Depth 4\n  $temp = $nowPath + '.tmp'\n  [IO.File]::WriteAllText($temp, $text, $utf8)\n  try {\n    # (NullString: a plain $null would reach .NET as \"\", which Replace refuses)\n    if (Test-Path $nowPath) { [IO.File]::Replace($temp, $nowPath, [NullString]::Value) } else { [IO.File]::Move($temp, $nowPath) }\n  } catch {\n    [IO.File]::WriteAllText($nowPath, $text, $utf8)\n    Remove-Item $temp -Force -ErrorAction SilentlyContinue\n  }\n}\n\nif ($PSVersionTable.PSVersion.Major -gt 5) {\n  Put @{ ok = $false; why = 'Run it with Windows PowerShell (powershell), not PowerShell 7 (pwsh).' }\n  exit\n}\n\n# ---------------------------------------------------------------- Windows' media sessions (WinRT)\nAdd-Type -AssemblyName System.Runtime.WindowsRuntime\n$asTaskOp = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {\n  $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]\nfunction Await($operation, [Type]$type) {\n  $task = $asTaskOp.MakeGenericMethod($type).Invoke($null, @($operation))\n  if (-not $task.Wait(4000)) { throw 'Windows did not answer in time' }\n  $task.Result\n}\n$null = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime]\n$null = [Windows.Media.MediaPlaybackAutoRepeatMode, Windows.Media, ContentType = WindowsRuntime]\n$null = [Windows.Storage.Streams.IRandomAccessStreamWithContentType, Windows.Storage.Streams, ContentType = WindowsRuntime]\n$null = [Windows.Storage.Streams.IInputStream, Windows.Storage.Streams, ContentType = WindowsRuntime]\n$AsStreamForRead = [System.IO.WindowsRuntimeStreamExtensions].GetMethod('AsStreamForRead', [Type[]]@([Windows.Storage.Streams.IInputStream]))\n$ManagerType = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]\n$PropsType = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties]\n$StreamType = [Windows.Storage.Streams.IRandomAccessStreamWithContentType]\ntry {\n  $manager = Await ($ManagerType::RequestAsync()) $ManagerType\n} catch {\n  Put @{ ok = $false; why = 'Windows would not share what is playing on this PC.' }\n  Log ('no session manager: ' + $_)\n  exit\n}\n\n# ---------------------------------------------------------------- an app's own volume (the volume mixer)\n$mixerReady = $false\ntry {\n  Add-Type -TypeDefinition @'\nusing System;\nusing System.Collections.Generic;\nusing System.Diagnostics;\nusing System.Runtime.InteropServices;\nnamespace BasedHubPC {\n  [ComImport, Guid(\"BCDE0395-E52F-467C-8E3D-C4579291692E\")] internal class DeviceEnumeratorCom {}\n  [ComImport, Guid(\"A95664D2-9614-4F35-A746-DE8DB63617E6\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]\n  internal interface IMMDeviceEnumerator {\n    [PreserveSig] int EnumAudioEndpoints(int dataFlow, int stateMask, out IntPtr devices);\n    [PreserveSig] int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);\n  }\n  [ComImport, Guid(\"D666063F-1587-4E43-81F1-B948E807363F\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]\n  internal interface IMMDevice {\n    [PreserveSig] int Activate(ref Guid iid, int context, IntPtr parameters, [MarshalAs(UnmanagedType.IUnknown)] out object face);\n  }\n  [ComImport, Guid(\"77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]\n  internal interface IAudioSessionManager2 {\n    [PreserveSig] int GetAudioSessionControl(IntPtr grouping, int flags, out IntPtr control);\n    [PreserveSig] int GetSimpleAudioVolume(IntPtr grouping, int flags, out IntPtr volume);\n    [PreserveSig] int GetSessionEnumerator(out IAudioSessionEnumerator sessions);\n  }\n  [ComImport, Guid(\"E2F5BB11-0570-40CA-ACDD-3AA01277DEE8\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]\n  internal interface IAudioSessionEnumerator {\n    [PreserveSig] int GetCount(out int count);\n    [PreserveSig] int GetSession(int index, out IAudioSessionControl2 session);\n  }\n  [ComImport, Guid(\"bfb7ff88-7239-4fc9-8fa2-07c950be9c6d\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]\n  internal interface IAudioSessionControl2 {\n    [PreserveSig] int GetState(out int state);\n    [PreserveSig] int GetDisplayName(out IntPtr name);\n    [PreserveSig] int SetDisplayName(IntPtr name, IntPtr context);\n    [PreserveSig] int GetIconPath(out IntPtr path);\n    [PreserveSig] int SetIconPath(IntPtr path, IntPtr context);\n    [PreserveSig] int GetGroupingParam(out Guid grouping);\n    [PreserveSig] int SetGroupingParam(IntPtr grouping, IntPtr context);\n    [PreserveSig] int RegisterAudioSessionNotification(IntPtr client);\n    [PreserveSig] int UnregisterAudioSessionNotification(IntPtr client);\n    [PreserveSig] int GetSessionIdentifier(out IntPtr id);\n    [PreserveSig] int GetSessionInstanceIdentifier(out IntPtr id);\n    [PreserveSig] int GetProcessId(out int pid);\n  }\n  [ComImport, Guid(\"87CE5498-68D6-44E5-9215-6DA47EF883D8\"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]\n  internal interface ISimpleAudioVolume {\n    [PreserveSig] int SetMasterVolume(float level, ref Guid context);\n    [PreserveSig] int GetMasterVolume(out float level);\n    [PreserveSig] int SetMute(bool mute, ref Guid context);\n    [PreserveSig] int GetMute(out bool mute);\n  }\n  public static class Mixer {\n    // the sessions of the processes whose name is in `match` (an app id, lower case)\n    static List<ISimpleAudioVolume> Find(string match) {\n      var found = new List<ISimpleAudioVolume>();\n      if (string.IsNullOrEmpty(match)) return found;\n      var enumerator = (IMMDeviceEnumerator)(new DeviceEnumeratorCom());\n      IMMDevice device;\n      if (enumerator.GetDefaultAudioEndpoint(0, 1, out device) != 0 || device == null) return found;\n      Guid iid = typeof(IAudioSessionManager2).GUID;\n      object face;\n      if (device.Activate(ref iid, 23, IntPtr.Zero, out face) != 0 || face == null) return found;\n      IAudioSessionEnumerator sessions;\n      if (((IAudioSessionManager2)face).GetSessionEnumerator(out sessions) != 0 || sessions == null) return found;\n      int count;\n      sessions.GetCount(out count);\n      for (int i = 0; i < count; i++) {\n        IAudioSessionControl2 control;\n        if (sessions.GetSession(i, out control) != 0 || control == null) continue;\n        int pid;\n        // (a session shared by several processes answers AUDCLNT_S_NO_SINGLE_PROCESS: a success, with a pid)\n        if (control.GetProcessId(out pid) < 0 || pid == 0) continue;\n        string name;\n        try { name = Process.GetProcessById(pid).ProcessName.ToLowerInvariant(); } catch { continue; }\n        if (name.Length >= 4 && match.Contains(name)) found.Add((ISimpleAudioVolume)control);\n      }\n      return found;\n    }\n    public static float Get(string match) {\n      foreach (var volume in Find(match)) {\n        float level;\n        if (volume.GetMasterVolume(out level) == 0) return level;\n      }\n      return -1f;\n    }\n    public static bool Set(string match, float level) {\n      bool any = false;\n      Guid context = Guid.Empty;\n      level = Math.Max(0f, Math.Min(1f, level));\n      foreach (var volume in Find(match)) {\n        if (volume.SetMasterVolume(level, ref context) == 0) any = true;\n      }\n      return any;\n    }\n  }\n}\n'@\n  $mixerReady = $true\n} catch {\n  Log ('no volume mixer: ' + $_)\n}\n\n# ---------------------------------------------------------------- which app, and its name\n$names = @{\n  'spotify' = 'Spotify'; 'applemusic' = 'Apple Music'; 'itunes' = 'iTunes'; 'zunemusic' = 'Media Player'; 'chrome' = 'Chrome'\n  'msedge' = 'Edge'; '308046b0af4a39cb' = 'Firefox'; 'firefox' = 'Firefox'; 'opera' = 'Opera'; 'brave' = 'Brave'; 'deezer' = 'Deezer'\n  'tidal' = 'TIDAL'; 'amazonmusic' = 'Amazon Music'; 'vlc' = 'VLC'; 'foobar2000' = 'foobar2000'; 'musicbee' = 'MusicBee'\n  'aimp' = 'AIMP'; 'soundcloud' = 'SoundCloud'; 'youtubemusic' = 'YouTube Music'; 'discord' = 'Discord'\n}\nfunction AppName([string]$id) {\n  $low = $id.ToLowerInvariant()\n  foreach ($key in $names.Keys) { if ($low.Contains($key)) { return $names[$key] } }\n  $short = ($id -split '[!\\\\]')[-1]\n  if ($short -eq 'App' -or $short -eq '') { $short = ($id -split '[._!]')[1] }\n  $short = $short -replace '\\.exe$', ''\n  if (-not $short) { $short = 'An app' }\n  return $short\n}\n# what the mixer looks for: the app id, plus the process name an id does not spell out\nfunction MixerKey([string]$id) {\n  $low = $id.ToLowerInvariant()\n  if ($low.Contains('308046b0af4a39cb')) { return $low + ' firefox' }\n  return $low\n}\n\n# Which app the hub shows: the one it showed, until another app STARTS playing. (Pausing Spotify\n# from the hub must not hand the player to a video left playing in a browser.)\n$script:lastApp = $null\n$script:wasPlaying = @{}\nfunction PickSession {\n  $all = @($manager.GetSessions())\n  if ($all.Count -eq 0) { return $null }\n  $last, $started, $playing = $null, $null, $null\n  $now = @{}\n  foreach ($one in $all) {\n    $id = $one.SourceAppUserModelId\n    $on = $one.GetPlaybackInfo().PlaybackStatus -eq 'Playing'\n    $now[$id] = $on\n    if ($id -eq $script:lastApp) { $last = $one }\n    if ($on -and -not $playing) { $playing = $one }\n    if ($on -and -not $script:wasPlaying[$id] -and $id -ne $script:lastApp -and -not $started) { $started = $one }\n  }\n  $script:wasPlaying = $now\n  if ($started -and $script:lastApp) { return $started }\n  if ($last) { return $last }\n  $current = $manager.GetCurrentSession()\n  if ($current -and $current.GetPlaybackInfo().PlaybackStatus -eq 'Playing') { return $current }\n  if ($playing) { return $playing }\n  if ($current) { return $current }\n  return $all[0]\n}\n\n# ---------------------------------------------------------------- the cover\nfunction ReadCover($reference) {\n  if ($null -eq $reference) { return $null }\n  $stream = Await ($reference.OpenReadAsync()) $StreamType\n  # (called through reflection: PowerShell cannot match the WinRT stream to the overload itself;\n  # closing the .NET stream closes the WinRT one, which has no Dispose of its own here)\n  $source = $AsStreamForRead.Invoke($null, @($stream))\n  try {\n    $memory = New-Object System.IO.MemoryStream\n    $source.CopyTo($memory)\n    $bytes = $memory.ToArray()\n  } finally {\n    try { $source.Dispose() } catch { }\n  }\n  if ($bytes.Length -lt 64) { return $null }\n  $isJpeg = $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8\n  $isPng = $bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x4E -and $bytes[3] -eq 0x47\n  if ($isJpeg) { return @{ bytes = $bytes; ext = 'jpg' } }\n  if ($isPng) { return @{ bytes = $bytes; ext = 'png' } }\n  # (anything else: made a PNG)\n  Add-Type -AssemblyName System.Drawing\n  $image = [System.Drawing.Image]::FromStream((New-Object System.IO.MemoryStream(, $bytes)))\n  $out = New-Object System.IO.MemoryStream\n  $image.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)\n  $image.Dispose()\n  return @{ bytes = $out.ToArray(); ext = 'png' }\n}\nfunction Hash([byte[]]$bytes) {\n  $sha = [System.Security.Cryptography.SHA1]::Create()\n  $text = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '').Substring(0, 10).ToLowerInvariant()\n  $sha.Dispose()\n  return $text\n}\n\n# ---------------------------------------------------------------- what to do (do.json)\n$script:doStamp = $null\n$script:doSession = $null\n$script:doneId = 0\nfunction ReadOrders([bool]$first) {\n  if (-not (Test-Path $doPath)) { return @() }\n  $stamp = (Get-Item $doPath).LastWriteTimeUtc\n  if ($stamp -eq $script:doStamp) { return @() }\n  $script:doStamp = $stamp\n  $orders = $null\n  try { $orders = [IO.File]::ReadAllText($doPath, $utf8) | ConvertFrom-Json } catch { $script:doStamp = $null; return @() }\n  if ($null -eq $orders) { return @() }\n  $list = @($orders.cmds)\n  $top = 0\n  foreach ($order in $list) { if ([int]$order.id -gt $top) { $top = [int]$order.id } }\n  if ($first) {\n    # (what was asked before this started is not done again)\n    $script:doSession, $script:doneId = $orders.s, $top\n    return @()\n  }\n  if ($orders.s -ne $script:doSession) { $script:doSession, $script:doneId = $orders.s, 0 }\n  $out = @()\n  foreach ($order in ($list | Sort-Object { [int]$_.id })) {\n    if ([int]$order.id -gt $script:doneId) { $out += $order }\n  }\n  if ($top -gt $script:doneId) { $script:doneId = $top }\n  return $out\n}\nfunction Obey($session, $order) {\n  $what = [string]$order.do\n  if ($what -eq 'quit') { return 'quit' }\n  if ($what -eq 'volume') {\n    if ($mixerReady -and $session) { $null = [BasedHubPC.Mixer]::Set((MixerKey $session.SourceAppUserModelId), [float]$order.to) }\n    return 'ok'\n  }\n  if (-not $session) { return 'none' }\n  switch ($what) {\n    'toggle' { $null = Await ($session.TryTogglePlayPauseAsync()) ([bool]) }\n    'play' { $null = Await ($session.TryPlayAsync()) ([bool]) }\n    'pause' { $null = Await ($session.TryPauseAsync()) ([bool]) }\n    'next' { $null = Await ($session.TrySkipNextAsync()) ([bool]) }\n    'previous' { $null = Await ($session.TrySkipPreviousAsync()) ([bool]) }\n    'seek' { $null = Await ($session.TryChangePlaybackPositionAsync([long]([double]$order.to * 10000000))) ([bool]) }\n    'shuffle' { $null = Await ($session.TryChangeShuffleActiveAsync([bool]$order.to)) ([bool]) }\n    'repeat' {\n      $mode = switch ([string]$order.to) { 'one' { 'Track' } 'all' { 'List' } default { 'None' } }\n      $null = Await ($session.TryChangeAutoRepeatModeAsync([Windows.Media.MediaPlaybackAutoRepeatMode]::$mode)) ([bool])\n    }\n  }\n  return 'ok'\n}\n\n# ---------------------------------------------------------------- what is playing, as the hub reads it\n$script:trackKey = $null\n$script:coverName = ''\n$script:coverHash = ''\n$script:coverBefore = ''\n$script:coverUntil = 0\n$script:coverSettled = $true\n$script:trackNo = 0\n$script:volume = -1\n$script:volumeAt = 0\nfunction Snapshot {\n  $session = PickSession\n  if (-not $session) { return @{ ok = $true; none = $true } }\n  $id = $session.SourceAppUserModelId\n  $script:lastApp = $id\n  $props = Await ($session.TryGetMediaPropertiesAsync()) $PropsType\n  $info = $session.GetPlaybackInfo()\n  $line = $session.GetTimelineProperties()\n  $status = [string]$info.PlaybackStatus\n  $rate = 1.0\n  if ($null -ne $info.PlaybackRate) { $rate = [double]$info.PlaybackRate }\n  $length = ($line.EndTime - $line.StartTime).TotalSeconds\n  $position = ($line.Position - $line.StartTime).TotalSeconds\n  if ($status -eq 'Playing') { $position += ([DateTimeOffset]::UtcNow - $line.LastUpdatedTime).TotalSeconds * $rate }\n  if ($length -gt 0) { $position = [Math]::Min([Math]::Max($position, 0), $length) } else { $position = [Math]::Max($position, 0) }\n  $key = $id + '|' + $props.Title + '|' + $props.Artist + '|' + $props.AlbumTitle\n  if ($key -ne $script:trackKey) {\n    $script:trackKey = $key\n    $script:trackNo += 1\n    $script:coverBefore = $script:coverHash\n    $script:coverName = ''\n    $script:coverSettled = $false\n    $script:coverUntil = (NowMs) + 4000\n  }\n  # the cover: read with the song, and again for a few seconds while it is still the last song's\n  # (an app can send the new cover a moment after the new name)\n  if (-not $script:coverSettled -and (NowMs) -lt $script:coverUntil) {\n    try {\n      $cover = ReadCover $props.Thumbnail\n      if ($cover) {\n        $hash = Hash $cover.bytes\n        $name = 'art_' + $hash + '.' + $cover.ext\n        if ($hash -ne $script:coverHash) {\n          [IO.File]::WriteAllBytes((Join-Path $Dir $name), $cover.bytes)\n          Get-ChildItem -Path $Dir -Filter 'art_*' | Where-Object { $_.Name -ne $name } | Sort-Object LastWriteTime -Descending |\n            Select-Object -Skip 2 | Remove-Item -Force -ErrorAction SilentlyContinue\n        }\n        $script:coverHash, $script:coverName = $hash, $name\n        if ($hash -ne $script:coverBefore) { $script:coverSettled = $true }\n      }\n    } catch {\n      if (-not $script:coverFault) { $script:coverFault = $true; Log ('cover: ' + $_) }\n    }\n  }\n  # the app's own volume, now and then (it costs a look through the mixer)\n  if ($mixerReady -and ((NowMs) - $script:volumeAt) -gt 1500) {\n    $script:volumeAt = NowMs\n    try { $script:volume = [double][BasedHubPC.Mixer]::Get((MixerKey $id)) } catch { $script:volume = -1 }\n  }\n  $controls = $info.Controls\n  $repeat = switch ([string]$info.AutoRepeatMode) { 'Track' { 'one' } 'List' { 'all' } default { 'off' } }\n  $others = @()\n  foreach ($one in @($manager.GetSessions())) {\n    if ($one.SourceAppUserModelId -ne $id) { $others += (AppName $one.SourceAppUserModelId) }\n  }\n  return @{\n    ok = $true; app = (AppName $id); appId = $id; title = [string]$props.Title; artist = [string]$props.Artist\n    album = [string]$props.AlbumTitle; length = [Math]::Round($length, 3); position = [Math]::Round($position, 3); rate = $rate\n    playing = ($status -eq 'Playing'); status = $status.ToLowerInvariant(); shuffle = ($info.IsShuffleActive -eq $true); repeat = $repeat\n    canSeek = ($controls.IsPlaybackPositionEnabled -eq $true); canNext = ($controls.IsNextEnabled -eq $true)\n    canPrevious = ($controls.IsPreviousEnabled -eq $true); volume = [Math]::Round($script:volume, 3); cover = $script:coverName\n    track = $script:trackNo; done = $script:doneId; others = $others\n  }\n}\n\n# ---------------------------------------------------------------- the loop\nLog ('started, pid ' + $PID + ', folder ' + $Dir)\n$started = Get-Date\n$null = ReadOrders $true\n$lastText = ''\n$lastPut = 0\nwhile ($true) {\n  $busy = $false\n  try {\n    # the game gone for 20 minutes: done\n    $seen = $started\n    if (Test-Path $alivePath) { $seen = (Get-Item $alivePath).LastWriteTime; if ($seen -lt $started) { $seen = $started } }\n    if (((Get-Date) - $seen).TotalMinutes -gt 20) { Log 'the game has been gone 20 minutes: closing'; break }\n    $orders = @(ReadOrders $false)\n    if ($orders.Count -gt 0) {\n      $session = PickSession\n      $quit = $false\n      foreach ($order in $orders) {\n        try { if ((Obey $session $order) -eq 'quit') { $quit = $true } } catch { Log ('order ' + $order.do + ': ' + $_) }\n      }\n      if ($quit) { Log 'asked to close'; break }\n      $busy = $true\n      $script:volumeAt = 0\n    }\n    $state = Snapshot\n    $plain = ($state.GetEnumerator() | Where-Object { $_.Key -ne 'position' } | Sort-Object Key | ForEach-Object { $_.Key + '=' + $_.Value }) -join ';'\n    if ($plain -ne $lastText -or ((NowMs) - $lastPut) -gt 900) {\n      Put $state\n      $lastText = $plain\n      $lastPut = NowMs\n    }\n  } catch {\n    Log ('loop: ' + $_)\n    Start-Sleep -Milliseconds 500\n  }\n  if ($busy) { Start-Sleep -Milliseconds 40 } else { Start-Sleep -Milliseconds 120 }\n}\ntry { Put @{ ok = $false; closed = $true; why = 'The helper was closed.' } } catch {}\n$mutex.ReleaseMutex()\n"
B.Loader = nil        -- prebuild timing hint; nil -> 0.05s slice spacing
B.SHIPPED = nil       -- shipped flag defaults; nil -> only what we define below
B.pages = B.pages or {}   -- deferred tab registrants (51_keys registers here)

do -- 00_kernel.lua
-- ============================================================================
--  00 kernel   services, ownership, signals, error boundaries, files, helpers
-- ============================================================================
local genv = (type(getgenv) == "function" and getgenv()) or _G
B.genv = genv

-- A second execution replaces the first: the old hub unloads itself completely.
if type(genv.BASED) == "table" and type(genv.BASED.unload) == "function" then
  pcall(genv.BASED.unload, true)
end
genv.BASED = B
B.alive = true
B.bootClock = os.clock()

local cloneref = type(cloneref) == "function" and cloneref or function(x) return x end
B.cloneref = cloneref
B.S = setmetatable({}, { __index = function(t, name)
  local ok, service = pcall(game.GetService, game, name)
  if not ok or not service then error("BASED: no service " .. tostring(name), 2) end
  service = cloneref(service)
  rawset(t, name, service)
  return service
end })
local S = B.S
B.LP = S.Players.LocalPlayer

-- ---------------------------------------------------------------- signals
local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ list = {} }, Signal) end
function Signal:connect(fn)
  local link = { fn = fn, live = true }
  local list = self.list
  list[#list + 1] = link
  return { disconnect = function()
    if not link.live then return end
    link.live = false
    local at = table.find(list, link)
    if at then table.remove(list, at) end
  end }
end
function Signal:fire(...)
  local list = self.list
  if #list == 0 then return end
  for _, link in ipairs(table.clone(list)) do
    if link.live then B.try("signal", link.fn, ...) end
  end
end
B.Signal = Signal

-- ---------------------------------------------------------------- faults
-- Everything user-facing runs inside B.try: a failing feature logs here and the
-- rest of the hub keeps running. Settings > About shows this list.
B.faults = {}
B.onFault = Signal.new()
local lastFault = {}
function B.fault(scope, err)
  scope = tostring(scope)
  -- something failing every frame must not flood the log: one entry a second per scope
  local now = os.clock()
  local previous = lastFault[scope]
  if previous and now - previous.at < 1 then previous.entry.repeats = (previous.entry.repeats or 0) + 1; return end
  local entry = { scope = scope, message = tostring(err), at = now - B.bootClock }
  lastFault[scope] = { at = now, entry = entry }
  local faults = B.faults
  faults[#faults + 1] = entry
  if #faults > 60 then table.remove(faults, 1) end
  warn("[BASED] " .. entry.scope .. ": " .. entry.message)
  if B.onFault and #B.onFault.list > 0 then
    for _, link in ipairs(table.clone(B.onFault.list)) do pcall(link.fn, entry) end
  end
end
local function trace(e) return tostring(e) .. "\n" .. debug.traceback("", 2) end
function B.try(scope, fn, ...)
  local result = table.pack(xpcall(fn, trace, ...))
  if not result[1] then B.fault(scope, result[2]); return nil end
  return table.unpack(result, 2, result.n)
end
function B.safe(scope, fn)
  return function(...) return B.try(scope, fn, ...) end
end
-- Potassium: calling into game modules drops the thread's Plugin capability and
-- every gethui instance then throws. Callbacks the game invokes call this first.
function B.identity()
  if type(setthreadidentity) == "function" then pcall(setthreadidentity, 8) end
end

-- ---------------------------------------------------------------- ownership
local owned = {}
function B.own(thing)
  owned[#owned + 1] = thing
  return thing
end
-- What every hooked function costs, by name, while measuring (B.measure): nil the rest of the time,
-- and then a hook costs one look at it. Read with B.measure(seconds) -> lines, worst first.
B.prof = nil
local function charge(scope, seconds)
  local prof = B.prof
  if not prof then return end
  local entry = prof[scope]
  if not entry then entry = { 0, 0, 0 }; prof[scope] = entry end
  entry[1] += seconds
  entry[2] += 1
  if seconds > entry[3] then entry[3] = seconds end
end
B.charge = charge
function B.connect(signal, fn, scope)
  scope = scope or "event"
  local safe = B.safe(scope, fn)
  return B.own(signal:Connect(function(...)
    if not B.prof then return safe(...) end
    local started = os.clock()
    safe(...)
    charge(scope, os.clock() - started)
  end))
end
function B.measure(seconds)
  B.prof = {}
  local frames, started = 0, os.clock()
  local counter = S.RunService.Heartbeat:Connect(function() frames += 1 end)
  task.wait(seconds or 5)
  counter:Disconnect()
  local prof, span = B.prof, os.clock() - started
  B.prof = nil
  local rows = {}
  for scope, entry in pairs(prof) do rows[#rows + 1] = { scope, entry[1], entry[2], entry[3] } end
  table.sort(rows, function(a, b) return a[2] > b[2] end)
  local out = { string.format("%d frames in %.1f s (%.0f fps)", frames, span, frames / math.max(span, 1e-3)) }
  for _, row in ipairs(rows) do
    out[#out + 1] = string.format("%-28s %6.3f ms/frame  %6d calls  worst %.2f ms", row[1], row[2] * 1000 / math.max(frames, 1), row[3], row[4] * 1000)
  end
  return out
end
B.onUnload = Signal.new()
function B.unload()
  if not B.alive then return end
  B.alive = false
  pcall(function() B.onUnload:fire() end)
  for index = #owned, 1, -1 do
    local thing = owned[index]
    pcall(function()
      local kind = typeof(thing)
      if kind == "RBXScriptConnection" then thing:Disconnect()
      elseif kind == "Instance" then thing:Destroy()
      elseif kind == "function" then thing()
      elseif kind == "table" and type(thing.destroy) == "function" then thing:destroy() end
    end)
  end
  table.clear(owned)
  if genv.BASED == B then genv.BASED = nil end
end

-- ---------------------------------------------------------------- files
local fs = { root = "BasedHub" }
fs.ok = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
  and type(makefolder) == "function" and type(isfolder) == "function"
function fs.path(relative) return fs.root .. "/" .. relative end
function fs.exists(path)
  if not fs.ok then return false end
  local ok, present = pcall(isfile, path)
  return ok and present == true
end
function fs.isdir(path)
  if not fs.ok then return false end
  local ok, present = pcall(isfolder, path)
  return ok and present == true
end
function fs.mkdir(path)
  if not fs.ok then return false end
  local built = ""
  for part in string.gmatch(path, "[^/\\]+") do
    built = built == "" and part or (built .. "/" .. part)
    if not fs.isdir(built) then pcall(makefolder, built) end
  end
  return fs.isdir(path)
end
function fs.read(path)
  if not fs.exists(path) then return nil end
  local ok, data = pcall(readfile, path)
  return ok and data or nil
end
function fs.write(path, data)
  if not fs.ok then return false end
  local folder = string.match(path, "^(.*)[/\\][^/\\]+$")
  if folder and not fs.isdir(folder) then fs.mkdir(folder) end
  local ok = pcall(writefile, path, data)
  return ok
end
function fs.remove(path)
  if type(delfile) ~= "function" or not fs.exists(path) then return false end
  return (pcall(delfile, path))
end
function fs.list(path)
  if type(listfiles) ~= "function" or not fs.isdir(path) then return {} end
  local ok, files = pcall(listfiles, path)
  if not ok or type(files) ~= "table" then return {} end
  local out = {}
  for _, file in ipairs(files) do out[#out + 1] = (string.gsub(tostring(file), "\\", "/")) end
  table.sort(out)
  return out
end
function fs.readJson(path)
  local data = fs.read(path)
  if not data or data == "" then return nil end
  local ok, value = pcall(S.HttpService.JSONDecode, S.HttpService, data)
  return ok and value or nil
end
function fs.writeJson(path, value)
  local ok, data = pcall(S.HttpService.JSONEncode, S.HttpService, value)
  return ok and fs.write(path, data) or false
end
B.fs = fs

-- ---------------------------------------------------------------- helpers
local util = {}
function util.clamp01(x) return x < 0 and 0 or (x > 1 and 1 or x) end
function util.lerp(a, b, t) return a + (b - a) * t end
function util.map(x, a, b, c, d, clamp)
  local t = (x - a) / (b - a)
  if clamp then t = util.clamp01(t) end
  return c + (d - c) * t
end
function util.round(x, step)
  step = step or 1
  return math.floor(x / step + 0.5) * step
end
function util.hex(text)
  text = string.gsub(text, "#", "")
  return Color3.fromRGB(tonumber(string.sub(text, 1, 2), 16), tonumber(string.sub(text, 3, 4), 16), tonumber(string.sub(text, 5, 6), 16))
end
function util.toHex(color)
  return string.format("%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end
function util.luma(color) return 0.2126 * color.R + 0.7152 * color.G + 0.0722 * color.B end
function util.mix(a, b, t) return a:Lerp(b, t) end
function util.format(value, decimals)
  if decimals and decimals > 0 then return string.format("%." .. decimals .. "f", value) end
  return tostring(math.floor(value + 0.5))
end
function util.comma(n)
  local text = tostring(math.floor(n))
  local out = string.reverse((string.gsub(string.reverse(text), "(%d%d%d)", "%1,")))
  return (string.gsub(out, "^,", ""))
end
function util.copy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for k, v in pairs(value) do out[k] = util.copy(v) end
  return out
end
function util.keys(t)
  local out = {}
  for k in pairs(t) do out[#out + 1] = k end
  return out
end
-- Cheap fuzzy score for the command palette: every query character must appear
-- in order; contiguous runs and word starts score higher. nil = no match.
function util.fuzzy(query, text)
  query, text = string.lower(query), string.lower(text)
  if query == "" then return 0 end
  local score, at, run = 0, 1, 0
  for i = 1, #query do
    local ch = string.sub(query, i, i)
    local found = string.find(text, ch, at, true)
    if not found then return nil end
    if found == at then run += 1; score += 2 + run else run = 0 end
    if found == 1 or string.find(string.sub(text, found - 1, found - 1), "[%s%p]") then score += 3 end
    score -= (found - at) * 0.05
    at = found + 1
  end
  return score - #text * 0.01
end
function util.debounce(seconds, fn)
  local token = 0
  return function(...)
    token += 1
    local mine = token
    local args = table.pack(...)
    task.delay(seconds, function()
      if mine == token and B.alive then B.try("debounce", fn, table.unpack(args, 1, args.n)) end
    end)
  end
end
-- A ray from one point to another, however far apart. Measured on the client: one ray finds
-- nothing more than 15,000 studs away however long it is asked to be, and says so with nil, not
-- an error. So a long one is cast in lengths the engine can see along. nil means the way is
-- clear (or, past `lengths` of them, further than it is worth looking).
local RAY_REACH = 14000
function util.ray(from, to, params, lengths)
  local offset = to - from
  local distance = offset.Magnitude
  if distance <= RAY_REACH then return workspace:Raycast(from, offset, params) end
  local unit = offset / distance
  local at = 0
  for _ = 1, lengths or 8 do
    local reach = math.min(RAY_REACH, distance - at)
    local hit = workspace:Raycast(from + unit * at, unit * reach, params)
    if hit then return hit end
    at += reach
    if at >= distance - 0.01 then break end
  end
  return nil
end
util.RAY_REACH = RAY_REACH
-- a distance for a label: whole studs with a comma, then thousands, then millions
function util.studs(distance)
  if distance >= 99.95e6 then return string.format("%.0fM", distance / 1e6) end
  if distance >= 999500 then return string.format("%.1fM", distance / 1e6) end
  if distance >= 99950 then return string.format("%.0fk", distance / 1000) end
  if distance >= 9995 then return string.format("%.1fk", distance / 1000) end
  return util.comma(distance + 0.5)
end
function util.randomName()
  local chars = {}
  for i = 1, 12 do chars[i] = string.char(math.random(97, 122)) end
  return table.concat(chars)
end
B.util = util

-- ---------------------------------------------------------------- environment
function B.camera() return workspace.CurrentCamera end
function B.viewport()
  local camera = workspace.CurrentCamera
  return camera and camera.ViewportSize or Vector2.new(1920, 1080)
end
function B.character(player)
  player = player or B.LP
  return player and player.Character
end
function B.humanoid(player)
  local character = B.character(player)
  return character and character:FindFirstChildOfClass("Humanoid")
end
function B.root(player)
  local character = B.character(player)
  if not character then return nil end
  return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end
function B.clipboard(text)
  local set = (type(setclipboard) == "function" and setclipboard) or (type(toclipboard) == "function" and toclipboard)
  if not set then return false end
  return (pcall(set, tostring(text)))
end
B.executor = "Unknown"
pcall(function()
  if type(identifyexecutor) == "function" then B.executor = tostring((identifyexecutor())) end
end)
B.touch = false
pcall(function() B.touch = S.UserInputService.TouchEnabled and not S.UserInputService.MouseEnabled end)

-- The GUI parent: the executor's hidden container when it has one.
function B.host()
  if B._host and B._host.Parent then return B._host end
  local host
  if type(gethui) == "function" then
    local ok, hidden = pcall(gethui)
    if ok and typeof(hidden) == "Instance" then host = hidden end
  end
  if not host then
    local ok, core = pcall(function() return cloneref(game:GetService("CoreGui")) end)
    if ok and core and pcall(function() return core.Name end) then host = core end
  end
  if not host and B.LP then host = B.LP:FindFirstChildOfClass("PlayerGui") or B.LP:WaitForChild("PlayerGui", 5) end
  B._host = host
  return host
end
B.screens = {}
function B.screen(order, name)
  local gui = Instance.new("ScreenGui")
  table.insert(B.screens, gui)
  gui.Name = name or util.randomName()
  gui.ResetOnSpawn = false
  gui.IgnoreGuiInset = true
  gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  gui.DisplayOrder = order or 9000
  pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)
  pcall(function() gui.ClipToDeviceSafeArea = false end)
  gui.Parent = B.host()
  return B.own(gui)
end
end

do -- 01_motion.lua
-- ============================================================================
--  01 motion   one render loop: analytic springs, timelines, jobs
--
--  Springs are described the way SwiftUI does it: a duration (how long the move
--  feels) and a bounce (0 = critically damped, 0.3 = lively). They are solved in
--  closed form, so a 20 fps hitch and a 240 fps frame land on the same curve and
--  nothing ever explodes. A spring at rest is removed from the loop: an idle hub
--  costs one empty table scan per frame.
-- ============================================================================
local S, util = B.S, B.util
local Motion = { speed = 1, reduced = false, frame = 0, dt = 1 / 60, smoothDt = 1 / 60, now = os.clock() }
B.Motion = Motion

Motion.presets = {
  quick  = { 0.16, 0 },     -- hover tints, tiny state changes
  snappy = { 0.24, 0.10 },  -- presses, toggles
  smooth = { 0.34, 0 },     -- panels, pages
  gentle = { 0.52, 0 },     -- large surfaces
  bouncy = { 0.40, 0.24 },  -- things that should feel alive
  liquid = { 0.46, 0.30 },  -- the trailing edge of a moving pill
  lazy   = { 0.90, 0 },     -- ambient drift
}

local awake = {}       -- springs that are moving
local stepping = {}    -- the ones being stepped this frame, in a list of their own (see the loop)
local jobs = {}        -- per-frame callbacks
local tweens = {}      -- fixed-duration timelines

-- ---------------------------------------------------------------- springs
local Spring = {}
Spring.__index = Spring

local function tune(spring, preset)
  local p = type(preset) == "table" and preset or Motion.presets[preset or "smooth"] or Motion.presets.smooth
  local duration, bounce = p[1], p[2] or 0
  if Motion.reduced then duration, bounce = duration * 0.55, 0 end
  duration = math.max(duration / Motion.speed, 0.02)
  spring.w0 = 2 * math.pi / duration
  spring.zeta = math.clamp(1 - bounce, 0.08, 1)
end

function Motion.spring(n, preset, onStep, eps)
  local spring = setmetatable({ n = n, x = table.create(n, 0), v = table.create(n, 0), g = table.create(n, 0),
    onStep = onStep, eps = eps or 0.001 }, Spring)
  tune(spring, preset)
  return spring
end
function Spring:snap(values)
  for i = 1, self.n do self.x[i], self.g[i], self.v[i] = values[i], values[i], 0 end
  awake[self] = nil
  if self.onStep then self.onStep(self.x) end
end
function Spring:to(values, preset)
  if preset then tune(self, preset) end
  local g = self.g
  for i = 1, self.n do g[i] = values[i] end
  awake[self] = true
end
function Spring:impulse(index, velocity)
  self.v[index] += velocity
  awake[self] = true
end
function Spring:moving() return awake[self] == true end
function Spring:stop() awake[self] = nil end

local function stepSpring(spring, dt)
  local w0, zeta, eps = spring.w0, spring.zeta, spring.eps
  local x, v, g = spring.x, spring.v, spring.g
  local rest = true
  if zeta < 0.999 then
    local wd = w0 * math.sqrt(1 - zeta * zeta)
    local decay = math.exp(-zeta * w0 * dt)
    local c, s = math.cos(wd * dt), math.sin(wd * dt)
    for i = 1, spring.n do
      local a = x[i] - g[i]
      local b = (v[i] + zeta * w0 * a) / wd
      local y = decay * (a * c + b * s)
      local nv = decay * ((b * wd - a * zeta * w0) * c - (a * wd + b * zeta * w0) * s)
      x[i], v[i] = g[i] + y, nv
      local tolerance = type(eps) == "table" and eps[i] or eps
      if rest and (math.abs(y) > tolerance or math.abs(nv) > tolerance * 20) then rest = false end
    end
  else
    local decay = math.exp(-w0 * dt)
    for i = 1, spring.n do
      local a = x[i] - g[i]
      local k = v[i] + w0 * a
      local y = decay * (a + k * dt)
      local nv = decay * (v[i] - k * w0 * dt)
      x[i], v[i] = g[i] + y, nv
      local tolerance = type(eps) == "table" and eps[i] or eps
      if rest and (math.abs(y) > tolerance or math.abs(nv) > tolerance * 20) then rest = false end
    end
  end
  if rest then
    for i = 1, spring.n do x[i], v[i] = g[i], 0 end
    awake[spring] = nil
  end
  if spring.onStep then spring.onStep(x) end
  if rest and spring.onRest then
    local done = spring.onRest
    spring.onRest = nil
    done()
  end
end

-- ---------------------------------------------------------------- properties
local PX, UNIT = 0.08, 0.0008
local packers = {
  number = { 1, function(value) return { value } end, function(x) return x[1] end, UNIT },
  UDim2 = { 4, function(value) return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset } end,
    function(x) return UDim2.new(x[1], x[2], x[3], x[4]) end, { UNIT, PX, UNIT, PX } },
  UDim = { 2, function(value) return { value.Scale, value.Offset } end, function(x) return UDim.new(x[1], x[2]) end, { UNIT, PX } },
  Vector2 = { 2, function(value) return { value.X, value.Y } end, function(x) return Vector2.new(x[1], x[2]) end, UNIT },
  Vector3 = { 3, function(value) return { value.X, value.Y, value.Z } end, function(x) return Vector3.new(x[1], x[2], x[3]) end, UNIT },
  Color3 = { 3, function(value) return { value.R, value.G, value.B } end,
    function(x) return Color3.new(util.clamp01(x[1]), util.clamp01(x[2]), util.clamp01(x[3])) end, 0.002 },
}
-- Properties that must stay inside 0..1: a bouncy spring overshoots, the engine rejects it.
local unitProps = { BackgroundTransparency = true, TextTransparency = true, ImageTransparency = true, Transparency = true,
  GroupTransparency = true, TextStrokeTransparency = true, ScrollBarImageTransparency = true, FillTransparency = true,
  OutlineTransparency = true }

local bound = setmetatable({}, { __mode = "k" })
-- Spring `instance[property]` toward `target`. The spring is kept per
-- (instance, property) and re-aimed in flight, so interrupted motion never jumps.
function Motion.to(instance, property, target, preset, done)
  local packer = packers[typeof(target)]
  if not packer then instance[property] = target; if done then done() end; return nil end
  local map = bound[instance]
  if not map then map = {}; bound[instance] = map end
  local spring = map[property]
  if not spring then
    local unpack, clampUnit = packer[3], unitProps[property]
    spring = Motion.spring(packer[1], preset, function(x)
      local value = unpack(x)
      if clampUnit then value = util.clamp01(value) end
      instance[property] = value
    end, packer[4])
    local current = packer[2](instance[property])
    for i = 1, spring.n do spring.x[i], spring.g[i] = current[i], current[i] end
    map[property] = spring
  end
  spring.onRest = done
  spring:to(packer[2](target), preset)
  return spring
end
function Motion.snap(instance, property, value)
  local map = bound[instance]
  local spring = map and map[property]
  local packer = packers[typeof(value)]
  if spring and packer then
    spring.onRest = nil
    spring:snap(packer[2](value))
  else
    instance[property] = value
  end
end
function Motion.kick(instance, property, index, velocity)
  local map = bound[instance]
  local spring = map and map[property]
  if spring then spring:impulse(index or 1, velocity) end
end
function Motion.target(instance, property)
  local map = bound[instance]
  local spring = map and map[property]
  if not spring then return instance[property] end
  local packer = packers[typeof(instance[property])]
  return packer and packer[3](spring.g) or instance[property]
end

-- ---------------------------------------------------------------- easing + timelines
local ease = {}
function ease.linear(t) return t end
function ease.outCubic(t) return 1 - (1 - t) ^ 3 end
function ease.inCubic(t) return t * t * t end
function ease.inOutCubic(t) return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2) ^ 3 / 2 end
function ease.outQuint(t) return 1 - (1 - t) ^ 5 end
function ease.inOutQuint(t) return t < 0.5 and 16 * t ^ 5 or 1 - (-2 * t + 2) ^ 5 / 2 end
function ease.outExpo(t) return t >= 1 and 1 or 1 - 2 ^ (-10 * t) end
function ease.inExpo(t) return t <= 0 and 0 or 2 ^ (10 * t - 10) end
function ease.outBack(t) local c = 1.70158; return 1 + (c + 1) * (t - 1) ^ 3 + c * (t - 1) ^ 2 end
function ease.outSine(t) return math.sin(t * math.pi / 2) end
Motion.ease = ease
-- progress of `t` through the window [from, from + length], eased and clamped
function Motion.window(t, from, length, curve)
  local p = util.clamp01((t - from) / length)
  return curve and curve(p) or p
end

function Motion.tween(duration, curve, step, done)
  local tween = { t = 0, duration = math.max(duration / Motion.speed, 0.001), curve = curve or ease.outCubic, step = step, done = done }
  if Motion.reduced then tween.duration *= 0.5 end
  tweens[#tweens + 1] = tween
  function tween.cancel() tween.dead = true end
  step(tween.curve(0))
  return tween
end

-- ---------------------------------------------------------------- jobs
-- fn(elapsed) every frame, or at `hz` with the time since it last ran.
function Motion.every(fn, hz, scope)
  local job = { fn = fn, interval = hz and 1 / hz or 0, acc = 0, scope = scope or "job" }
  jobs[#jobs + 1] = job
  function job.cancel() job.dead = true end
  return job
end
function Motion.after(seconds, fn, scope)
  local job
  local left = seconds
  job = Motion.every(function(dt)
    left -= dt
    if left <= 0 then job.dead = true; fn() end
  end, nil, scope or "after")
  return job
end

-- ---------------------------------------------------------------- the loop
Motion.stats = { springs = 0, jobs = 0, ms = 0 }
local function frame(dt)
  if not B.alive then return end
  local started = os.clock()
  dt = math.min(dt, 0.1)
  Motion.frame += 1
  Motion.dt = dt
  Motion.smoothDt += (dt - Motion.smoothDt) * 0.08
  Motion.now = started

  -- A spring's step runs code that may start other springs, and a table cannot be given new keys
  -- while it is being walked ("invalid key to 'next'", one frame in thousands): so this frame's
  -- springs are listed first. One started during the frame is stepped from the next; one put to
  -- rest by another before its turn is left alone.
  local measuring = B.prof ~= nil
  local springCount = 0
  for spring in pairs(awake) do
    springCount += 1
    stepping[springCount] = spring
  end
  for index = 1, springCount do
    local spring = stepping[index]
    stepping[index] = nil
    if awake[spring] then
      local ok, err = pcall(stepSpring, spring, dt)
      if not ok then awake[spring] = nil; B.fault("spring", err) end
    end
  end

  local mark = measuring and os.clock()
  if measuring then B.charge("motion.springs", mark - started) end
  local count = #tweens
  if count > 0 then
    for index = count, 1, -1 do
      local tween = tweens[index]
      if tween.dead then
        table.remove(tweens, index)
      else
        tween.t += dt
        local p = util.clamp01(tween.t / tween.duration)
        local ok, err = pcall(tween.step, tween.curve(p))
        if not ok then tween.dead = true; B.fault("tween", err) end
        if p >= 1 and not tween.dead then
          tween.dead = true
          table.remove(tweens, index)
          if tween.done then B.try("tween.done", tween.done) end
        end
      end
    end
  end

  if measuring then B.charge("motion.tweens", os.clock() - mark) end
  count = #jobs
  if count > 0 then
    for index = 1, count do
      local job = jobs[index]
      if job and not job.dead then
        local elapsed = dt
        local run = true
        if job.interval > 0 then
          job.acc += dt
          if job.acc < job.interval then run = false else elapsed = math.min(job.acc, 0.5); job.acc = 0 end
        end
        if run then
          local before = measuring and os.clock()
          local ok, err = pcall(job.fn, elapsed)
          if not ok then job.dead = true; B.fault(job.scope, err) end
          if measuring then B.charge("job." .. job.scope, os.clock() - before) end
        end
      end
    end
    for index = #jobs, 1, -1 do
      if jobs[index].dead then table.remove(jobs, index) end
    end
  end
  local stats = Motion.stats
  stats.springs, stats.jobs, stats.ms = springCount, #jobs, (os.clock() - started) * 1000
end
B.own(S.RunService.RenderStepped:Connect(frame))
Motion._frame = frame
end

do -- 02_theme.lua
-- ============================================================================
--  02 theme    tokens, live bindings
--
--  Surfaces are not solid colours: every fill is the scheme's ink at a low alpha
--  laid over glass, so one set of numbers works on a dark, a black and a light
--  scheme. B.T holds the resolved values; Theme.bind keeps an instance property
--  in step with a token, so accent, scheme and the glass slider all change the
--  whole hub live without rebuilding anything.
-- ============================================================================
local util = B.util
local hex = util.hex
local Theme = { changed = B.Signal.new() }
B.Theme = Theme
local T = {}
B.T = T

Theme.schemes = {
  dark = { label = "Graphite", base = hex("0B0B0F"), ink = hex("F5F4EF"), sub = hex("A9A8B4"), faint = hex("6C6B77"),
    shadow = 0.42, fill = { 0.045, 0.075, 0.115 }, stroke = { 0.085, 0.16 }, dark = true },
  midnight = { label = "Midnight", base = hex("000000"), ink = hex("F5F4EF"), sub = hex("9E9DA9"), faint = hex("62616C"),
    shadow = 0.3, fill = { 0.055, 0.09, 0.13 }, stroke = { 0.10, 0.18 }, dark = true },
  light = { label = "Porcelain", base = hex("F3F2EE"), ink = hex("121216"), sub = hex("56555F"), faint = hex("8C8B95"),
    shadow = 0.72, fill = { 0.05, 0.08, 0.12 }, stroke = { 0.10, 0.18 }, dark = false },
}
Theme.schemeOrder = { "dark", "midnight", "light" }
Theme.accents = {
  { id = "ultraviolet", label = "Ultraviolet", color = hex("8E7DFF") },
  { id = "azure", label = "Azure", color = hex("4DA3FF") },
  { id = "mint", label = "Mint", color = hex("45DDA8") },
  { id = "ember", label = "Ember", color = hex("FF7A45") },
  { id = "rose", label = "Rose", color = hex("FF5C93") },
  { id = "gold", label = "Gold", color = hex("F2C14E") },
  { id = "blood", label = "Blood", color = hex("FF4B4B") },
  { id = "bone", label = "Bone", color = hex("EDEBE4") },
}

Theme.state = { scheme = "dark", accent = hex("8E7DFF"), glass = 0.6, radius = 1, blur = false }

-- type ramp: font key (resolved in B.F by 03 assets) and size in design px
Theme.type = {
  display = { "serifItalic", 34 },
  title = { "serif", 25 },
  heading = { "text600", 15 },
  label = { "text500", 14 },
  body = { "text400", 13 },
  caption = { "text400", 12 },
  eyebrow = { "wideBold", 10 },
  mono = { "mono400", 12 },
  monoBold = { "mono500", 12 },
  button = { "text600", 13 },
  brand = { "wideBlack", 18 },
}

local function resolve()
  local state = Theme.state
  local scheme = Theme.schemes[state.scheme] or Theme.schemes.dark
  local glass = util.clamp01(state.glass)
  T.dark = scheme.dark
  T.base, T.ink, T.sub, T.faint = scheme.base, scheme.ink, scheme.sub, scheme.faint
  -- the iOS 27 control: clear glass at 0, tinted glass at 1. Without real blur
  -- behind it a clear panel is unreadable, so the range tightens.
  local alpha = state.blur and util.lerp(0.5, 0.94, glass) or util.lerp(0.84, 0.975, glass)
  T.baseA = 1 - alpha
  T.panelA = 1 - util.lerp(0.34, 0.62, glass)       -- inner panels: sidebar, popovers
  T.fill1A, T.fill2A, T.fill3A = 1 - scheme.fill[1], 1 - scheme.fill[2], 1 - scheme.fill[3]
  T.strokeA, T.stroke2A = 1 - scheme.stroke[1], 1 - scheme.stroke[2]
  T.shadowA = scheme.shadow
  T.accent = state.accent
  T.accentInk = util.luma(state.accent) > 0.62 and hex("101014") or hex("FFFFFF")
  T.accentSoftA = 0.84
  T.accentDim = state.accent:Lerp(scheme.base, 0.55)
  T.ok, T.warn, T.bad = hex("52D6A0"), hex("F4B45F"), hex("FF6577")
  T.white, T.black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
  T.rim = scheme.dark and Color3.new(1, 1, 1) or Color3.new(1, 1, 1)
  T.rimA = scheme.dark and 0.5 or 0.1
  T.popover = scheme.base:Lerp(scheme.ink, scheme.dark and 0.07 or 0.0)
  local r = state.radius
  T.rWindow, T.rPanel, T.rCard, T.rControl, T.rSmall = math.floor(26 * r), math.floor(19 * r), math.floor(16 * r), math.floor(11 * r), math.floor(7 * r)
end
resolve()

-- Strong references on purpose. A weak-keyed table of Instances loses entries whenever Lua holds
-- no other reference to that instance's wrapper, even though the instance is alive in the game:
-- measured as labels that kept their dark-scheme colour after switching to the light scheme.
-- Destroyed instances are swept out instead (their Parent is nil for good).
local bindings = {}
local boundAt = {}
-- Keep instance[property] equal to token `key` (optionally through `map`).
function Theme.bind(instance, property, key, map)
  local list = bindings[instance]
  if not list then list = {}; bindings[instance] = list; boundAt[instance] = os.clock() end
  list[property] = { key, map }
  local value = T[key]
  if map then value = map(value, T) end
  instance[property] = value
  return instance
end
function Theme.unbind(instance, property)
  local list = bindings[instance]
  if list then list[property] = nil end
end
-- forget instances that were destroyed (not ones still being assembled)
function Theme.sweep()
  local now = os.clock()
  for instance in pairs(bindings) do
    if instance.Parent == nil and now - boundAt[instance] > 5 then
      bindings[instance], boundAt[instance] = nil, nil
    end
  end
end
function Theme.apply()
  resolve()
  Theme.sweep()
  for instance, list in pairs(bindings) do
    for property, binding in pairs(list) do
      local value = T[binding[1]]
      if binding[2] then value = binding[2](value, T) end
      pcall(function() instance[property] = value end)
    end
  end
  Theme.changed:fire()
end
B.Motion.every(Theme.sweep, 1 / 20, "theme.sweep")
function Theme.set(changes)
  local state = Theme.state
  for key, value in pairs(changes) do state[key] = value end
  Theme.apply()
end
function Theme.corner(key) return UDim.new(0, T[key] or 10) end
end

do -- 03_assets.lua
-- ============================================================================
--  03 assets   files on disk -> content ids, fonts, icons, sounds
--
--  Measured on Potassium (2026-10-06): getcustomasset costs 3-5 ms per call on
--  the main thread whatever the file size, the files it copies stay in the
--  client's content folder between sessions, and the id is always
--  <prefix>/<basename>. So a file is registered ONCE, ever; after that its id is
--  built by hand for free. A sentinel is checked at boot because a client update
--  can empty that folder.
-- ============================================================================
local S, fs, util = B.S, B.fs, B.util
local Assets = { ready = false, lite = false, calls = 0 }
B.Assets = Assets
local manifest = B.MANIFEST or { files = {}, icons = { map = {} } }
Assets.manifest = manifest

local canRegister = type(getcustomasset) == "function" and fs.ok
local REGISTRY = fs.path("cache/registry.json")
local registry = { files = {}, seq = {} }
local ids = {}            -- relative path -> content id, or false when unavailable
local seqIds = {}         -- sequence prefix -> { [index] = id }
local seqKnown = {}       -- sequence prefix -> { [index] = true } registered in an earlier session
local dirty = false

local function basename(path) return string.match(path, "[^/\\]+$") or path end
local function prefixOf(id) return string.match(id, "^(rbxasset://[^/]+/)") end

local saveSoon = util.debounce(1.5, function()
  if not dirty then return end
  dirty = false
  local seq = {}
  for key, known in pairs(seqKnown) do
    -- compress the registered indices into [from, to] runs
    local runs, from, last = {}, nil, nil
    local indices = util.keys(known)
    table.sort(indices)
    for _, index in ipairs(indices) do
      if from and index == last + 1 then last = index
      else
        if from then runs[#runs + 1] = { from, last } end
        from, last = index, index
      end
    end
    if from then runs[#runs + 1] = { from, last } end
    seq[key] = runs
  end
  fs.writeJson(REGISTRY, { prefix = registry.prefix, sentinel = registry.sentinel, files = registry.files, seq = seq })
end)
local function touch() dirty = true; saveSoon() end

local function register(path)
  Assets.calls += 1
  local ok, id = pcall(getcustomasset, path)
  if not ok or type(id) ~= "string" or id == "" then return nil end
  local prefix = prefixOf(id)
  if prefix and registry.prefix ~= prefix then
    -- a different content folder: nothing registered before is reachable
    registry.prefix = prefix
    registry.files = {}
    table.clear(seqKnown)
  end
  return id
end

-- Content id for a file under BasedHub/, or nil when it is not installed.
function Assets.id(relative)
  local cached = ids[relative]
  if cached ~= nil then return cached or nil end
  if not canRegister then ids[relative] = false; return nil end
  local name = basename(relative)
  local stamp = manifest.files[relative] or "x"
  local id
  if registry.prefix and registry.files[name] == stamp then
    id = registry.prefix .. name
  else
    id = register(fs.path(relative))
    if id then
      registry.files[name] = stamp
      -- the sentinel must be something PreloadAsync can load and report on: an image
      if string.match(name, "%.png$") or string.match(name, "%.jpg$") then registry.sentinel = name end
      touch()
    end
  end
  ids[relative] = id or false
  return id
end

-- Content id for frame `index` of a numbered sequence ("film/hd/bhf1_h_", 4 digits).
function Assets.frame(pathPrefix, index, digits, extension)
  local cache = seqIds[pathPrefix]
  if not cache then cache = {}; seqIds[pathPrefix] = cache end
  local id = cache[index]
  if id ~= nil then return id or nil end
  if not canRegister then return nil end
  local file = pathPrefix .. string.format("%0" .. (digits or 4) .. "d", index) .. (extension or ".jpg")
  local known = seqKnown[pathPrefix]
  if known and known[index] and registry.prefix then
    id = registry.prefix .. basename(file)
  else
    id = register(fs.path(file))
    if id then
      if not known then known = {}; seqKnown[pathPrefix] = known end
      known[index] = true
      touch()
    end
  end
  cache[index] = id or false
  return id
end
-- true when frame `index` can be had without a getcustomasset call
function Assets.frameIsFree(pathPrefix, index)
  local cache = seqIds[pathPrefix]
  if cache and cache[index] then return true end
  local known = seqKnown[pathPrefix]
  return known ~= nil and known[index] == true and registry.prefix ~= nil
end

function Assets.has(relative) return fs.exists(fs.path(relative)) end

-- ---------------------------------------------------------------- fonts
local FONT_FILES = {
  text400 = { "Inter", "fonts/Inter-Regular.ttf", 400 }, text500 = { "Inter", "fonts/Inter-Medium.ttf", 500 },
  text600 = { "Inter", "fonts/Inter-SemiBold.ttf", 600 }, text700 = { "Inter", "fonts/Inter-Bold.ttf", 700 },
  mono400 = { "GeistMono", "fonts/GeistMono-Regular.ttf", 400 }, mono500 = { "GeistMono", "fonts/GeistMono-Medium.ttf", 500 },
  serif = { "InstrumentSerif", "fonts/InstrumentSerif-Regular.ttf", 400 },
  serifItalic = { "InstrumentSerifItalic", "fonts/InstrumentSerif-Italic.ttf", 400 },
  wideBold = { "ArchivoExpanded", "fonts/Archivo-ExpandedBold.ttf", 700 },
  wideBlack = { "ArchivoExpanded", "fonts/Archivo-ExpandedBlack.ttf", 900 },
  -- the Unnamed menu's: Monocraft (the Minecraft letters), and the two Proggy pixel fonts
  craft = { "Monocraft", "fonts/Monocraft.ttf", 400 },
  proggy = { "ProggyClean", "fonts/ProggyClean.ttf", 400 },
  proggyTiny = { "ProggyTiny", "fonts/ProggyTiny.ttf", 400 },
}
local WEIGHTS = { [400] = "Regular", [500] = "Medium", [600] = "SemiBold", [700] = "Bold", [900] = "Heavy" }
local function builtin(name, weight, style)
  local ok, font = pcall(Font.fromName, name, weight or Enum.FontWeight.Regular, style or Enum.FontStyle.Normal)
  if ok and font then return font end
  return Font.fromEnum(Enum.Font.Gotham)
end
local FALLBACK = {
  text400 = function() return builtin("BuilderSans", Enum.FontWeight.Regular) end,
  text500 = function() return builtin("BuilderSans", Enum.FontWeight.Medium) end,
  text600 = function() return builtin("BuilderSans", Enum.FontWeight.SemiBold) end,
  text700 = function() return builtin("BuilderSans", Enum.FontWeight.Bold) end,
  mono400 = function() return builtin("RobotoMono", Enum.FontWeight.Regular) end,
  mono500 = function() return builtin("RobotoMono", Enum.FontWeight.Medium) end,
  serif = function() return builtin("Merriweather", Enum.FontWeight.Regular) end,
  serifItalic = function() return builtin("Merriweather", Enum.FontWeight.Regular, Enum.FontStyle.Italic) end,
  wideBold = function() return builtin("BuilderExtended", Enum.FontWeight.Bold) end,
  wideBlack = function() return builtin("BuilderExtended", Enum.FontWeight.Heavy) end,
  -- (without the files, the closest Roblox has: its own pixel font, and Arial)
  craft = function() return Font.fromEnum(Enum.Font.Arcade) end,
  proggy = function() return Font.fromEnum(Enum.Font.Code) end,
  proggyTiny = function() return Font.fromEnum(Enum.Font.Code) end,
}
B.F = {}

local function loadFonts()
  -- one family file per family, listing each face's registered .ttf
  local families = {}
  for key, spec in pairs(FONT_FILES) do
    local ttf = Assets.id(spec[2])
    if ttf then
      local family = families[spec[1]]
      if not family then family = { name = spec[1], faces = {}, keys = {} }; families[spec[1]] = family end
      family.faces[#family.faces + 1] = { name = WEIGHTS[spec[3]] or "Regular", weight = spec[3], style = "normal", assetId = ttf }
      family.keys[key] = spec[3]
    end
  end
  for name, family in pairs(families) do
    table.sort(family.faces, function(a, b) return a.weight < b.weight end)
    local relative = "fonts/" .. name .. ".json"
    local ok, json = pcall(S.HttpService.JSONEncode, S.HttpService, { name = name, faces = family.faces })
    if ok then
      local path = fs.path(relative)
      local changed = fs.read(path) ~= json
      if changed then fs.write(path, json) end
      -- the stamp is the json itself: a new prefix or face list re-registers the family file
      manifest.files[relative] = tostring(#json) .. ":" .. tostring(registry.prefix)
      if changed then ids[relative] = nil; registry.files[basename(relative)] = nil end
      local id = Assets.id(relative)
      if id then
        for key, weight in pairs(family.keys) do
          local okFont, font = pcall(Font.new, id, Enum.FontWeight[WEIGHTS[weight] or "Regular"], Enum.FontStyle.Normal)
          if okFont then B.F[key] = font end
        end
      end
    end
  end
  local missing = 0
  for key, make in pairs(FALLBACK) do
    if not B.F[key] then B.F[key] = make(); missing += 1 end
  end
  return missing
end

-- ---------------------------------------------------------------- icons, images, sounds
-- Icons live in one atlas (a single registration): returns image, offset, size.
function Assets.icon(name)
  local atlas = manifest.icons
  local index = atlas and atlas.map and atlas.map[name]
  if not index then return nil end
  local id = Assets.id(atlas.image)
  if not id then return nil end
  local cell = atlas.cell
  return id, Vector2.new((index % atlas.cols) * cell, math.floor(index / atlas.cols) * cell), Vector2.new(cell, cell)
end
-- Images are deployed under a content-hashed file name (a changed picture gets a
-- new id, so a cached texture can never be stale); manifest.img maps name -> file.
function Assets.image(name)
  local file = manifest.img and manifest.img[name]
  return file and Assets.id(file) or nil
end
function Assets.sound(name)
  local file = manifest.sfx and manifest.sfx[name]
  return file and Assets.id(file) or nil
end

-- ---------------------------------------------------------------- boot
function Assets.preload(list, timeout)
  local done = false
  task.spawn(function()
    pcall(function() S.ContentProvider:PreloadAsync(list) end)
    done = true
  end)
  local waited = 0
  while not done and waited < (timeout or 3) do waited += task.wait() end
  return done
end

function Assets.init()
  if not canRegister then
    Assets.lite = true
  else
    local saved = fs.readJson(REGISTRY)
    if type(saved) == "table" and type(saved.prefix) == "string" and type(saved.files) == "table" and type(saved.sentinel) == "string" then
      -- is the content folder we registered into still there?
      local status
      local finished = false
      task.spawn(function()
        pcall(function()
          S.ContentProvider:PreloadAsync({ saved.prefix .. saved.sentinel }, function(_, result) status = result end)
        end)
        finished = true
      end)
      local waited = 0
      while not finished and waited < 2 do waited += task.wait() end
      if status == Enum.AssetFetchStatus.Success then
        registry.prefix, registry.files, registry.sentinel = saved.prefix, saved.files, saved.sentinel
        for key, runs in pairs(type(saved.seq) == "table" and saved.seq or {}) do
          local known = {}
          for _, run in ipairs(runs) do
            for index = run[1], run[2] do known[index] = true end
          end
          seqKnown[key] = known
        end
      end
    end
    Assets.lite = not (manifest.icons and manifest.icons.image and Assets.id(manifest.icons.image))
  end
  Assets.fontsMissing = loadFonts()
  -- the hub's own letters, kept: Settings > Font swaps B.F, and Inter is these again
  B.F0 = table.clone(B.F)
  Assets.ready = true
  return not Assets.lite
end
function Assets.registry() return registry end
end

do -- 04_ui.lua
-- ============================================================================
--  04 ui       instance factory, glass, text, icons, input, popovers, scroll
-- ============================================================================
local S, util, Motion, Theme, T, Assets = B.S, B.util, B.Motion, B.Theme, B.T, B.Assets
local UIS = S.UserInputService
local UI = { fx = { canvas = true, shadow = false, innerStroke = false }, sfxVolume = 0.5, sfxOn = true }
B.UI = UI

-- ---------------------------------------------------------------- capabilities
pcall(function()
  local probe = Instance.new("UIShadow")
  probe.BlurRadius = UDim.new(0, 4)
  probe:Destroy()
  UI.fx.shadow = true
end)
pcall(function()
  local probe = Instance.new("UIStroke")
  probe.BorderStrokePosition = Enum.BorderStrokePosition.Inner
  probe:Destroy()
  UI.fx.innerStroke = true
end)
pcall(function()
  -- a CanvasGroup is drawn at reduced resolution on the lowest quality levels: text goes soft
  local saved = UserSettings():GetService("UserGameSettings").SavedQualityLevel
  if saved ~= Enum.SavedQualitySetting.Automatic and saved.Value <= 2 then UI.fx.canvas = false end
end)

-- ---------------------------------------------------------------- factory
local function applyTheme(instance, map)
  for property, spec in pairs(map) do
    if type(spec) == "table" then Theme.bind(instance, property, spec[1], spec[2]) else Theme.bind(instance, property, spec) end
  end
end
function UI.new(class, props, children)
  local instance = Instance.new(class)
  local parent
  if props then
    for key, value in pairs(props) do
      if key == "Parent" then parent = value
      elseif key == "Theme" then applyTheme(instance, value)
      else instance[key] = value end
    end
  end
  if children then
    for _, child in ipairs(children) do child.Parent = instance end
  end
  if parent then instance.Parent = parent end
  return instance
end
local new = UI.new

function UI.frame(parent, props)
  local frame = Instance.new("Frame")
  frame.BackgroundTransparency = 1
  frame.BorderSizePixel = 0
  if props then
    for key, value in pairs(props) do
      if key == "Theme" then applyTheme(frame, value) else frame[key] = value end
    end
  end
  frame.Parent = parent
  return frame
end
-- radius: a token name ("rCard"), a pixel count, or true for a full pill
function UI.corner(instance, radius)
  local corner = Instance.new("UICorner")
  if radius == true then corner.CornerRadius = UDim.new(1, 0)
  elseif type(radius) == "string" then Theme.bind(corner, "CornerRadius", radius, function(value) return UDim.new(0, value) end)
  else corner.CornerRadius = UDim.new(0, radius or 8) end
  corner.Parent = instance
  return corner
end
function UI.stroke(instance, token, alphaToken, thickness)
  local stroke = Instance.new("UIStroke")
  stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  stroke.Thickness = thickness or 1
  Theme.bind(stroke, "Color", token or "ink")
  if type(alphaToken) == "number" then stroke.Transparency = alphaToken else Theme.bind(stroke, "Transparency", alphaToken or "strokeA") end
  if UI.fx.innerStroke then stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner end
  stroke.Parent = instance
  return stroke
end
function UI.pad(instance, top, right, bottom, left)
  local pad = Instance.new("UIPadding")
  right = right or top
  bottom = bottom or top
  left = left or right
  pad.PaddingTop, pad.PaddingRight, pad.PaddingBottom, pad.PaddingLeft = UDim.new(0, top), UDim.new(0, right), UDim.new(0, bottom), UDim.new(0, left)
  pad.Parent = instance
  return pad
end
function UI.list(instance, direction, gap, align)
  local layout = Instance.new("UIListLayout")
  layout.FillDirection = direction == "x" and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  layout.Padding = UDim.new(0, gap or 0)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  if align then
    if align.h then layout.HorizontalAlignment = Enum.HorizontalAlignment[align.h] end
    if align.v then layout.VerticalAlignment = Enum.VerticalAlignment[align.v] end
  end
  layout.Parent = instance
  return layout
end
function UI.scaleOf(instance)
  local scale = instance:FindFirstChildOfClass("UIScale")
  if not scale then scale = Instance.new("UIScale"); scale.Parent = instance end
  return scale
end
function UI.gradient(instance, props)
  local gradient = Instance.new("UIGradient")
  for key, value in pairs(props) do gradient[key] = value end
  gradient.Parent = instance
  return gradient
end
function UI.alphaSeq(...)
  local points, args = {}, { ... }
  for i = 1, #args, 2 do points[#points + 1] = NumberSequenceKeypoint.new(args[i], args[i + 1]) end
  return NumberSequence.new(points)
end

-- ---------------------------------------------------------------- text + icons
local STYLE = Theme.type
-- style: a key of Theme.type; color: a token name
function UI.text(parent, text, style, color, props)
  local spec = STYLE[style or "body"] or STYLE.body
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency = 1
  label.BorderSizePixel = 0
  label.FontFace = B.F[spec[1]]
  if UI.fontKey then UI.fontKey[label] = spec[1] end
  label.TextSize = spec[2]
  label.Text = text or ""
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.TextYAlignment = Enum.TextYAlignment.Center
  label.AutomaticSize = Enum.AutomaticSize.XY
  label.Size = UDim2.new()
  Theme.bind(label, "TextColor3", color or "ink")
  if props then
    for key, value in pairs(props) do label[key] = value end
  end
  label.Parent = parent
  return label
end
function UI.icon(parent, name, size, color, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency = 1
  image.BorderSizePixel = 0
  image.Size = UDim2.fromOffset(size or 18, size or 18)
  image.ScaleType = Enum.ScaleType.Fit
  Theme.bind(image, "ImageColor3", color or "ink")
  local id, offset, rect = Assets.icon(name)
  if id then
    image.Image, image.ImageRectOffset, image.ImageRectSize = id, offset, rect
  end
  if props then
    for key, value in pairs(props) do image[key] = value end
  end
  image.Parent = parent
  return image
end
function UI.setIcon(image, name)
  local id, offset, rect = Assets.icon(name)
  if id then image.Image, image.ImageRectOffset, image.ImageRectSize = id, offset, rect end
end
function UI.image(parent, name, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency = 1
  image.BorderSizePixel = 0
  image.Image = Assets.image(name) or ""
  if props then
    for key, value in pairs(props) do
      if key == "Theme" then applyTheme(image, value) else image[key] = value end
    end
  end
  image.Parent = parent
  return image
end

-- ---------------------------------------------------------------- glass
-- A translucent surface: tinted fill, fine grain, a top sheen and a rim that
-- catches light. level: "window" (reads the glass slider), "panel", "popover".
function UI.glass(parent, opts)
  opts = opts or {}
  local level = opts.level or "panel"
  local radius = opts.radius or "rPanel"
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  frame.Name = opts.name or "Glass"
  if level == "window" then
    Theme.bind(frame, "BackgroundColor3", "base")
    Theme.bind(frame, "BackgroundTransparency", "baseA")
  elseif level == "popover" then
    Theme.bind(frame, "BackgroundColor3", "popover")
    frame.BackgroundTransparency = 0.04
  else
    Theme.bind(frame, "BackgroundColor3", "ink")
    Theme.bind(frame, "BackgroundTransparency", opts.fill or "fill1A")
  end
  UI.corner(frame, radius)
  if opts.grain ~= false and Assets.image("noise") then
    local grain = UI.image(frame, "noise", { Name = "Grain", Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Tile,
      TileSize = UDim2.fromOffset(128, 128), ImageTransparency = opts.grainAlpha or 0.955, ZIndex = 0, Interactable = false })
    UI.corner(grain, radius)
  end
  if opts.sheen ~= false then
    local sheen = Instance.new("Frame")
    sheen.Name = "Sheen"
    sheen.BorderSizePixel = 0
    sheen.BackgroundColor3 = Color3.new(1, 1, 1)
    sheen.Size = UDim2.fromScale(1, 1)
    sheen.ZIndex = 0
    sheen.Interactable = false
    UI.corner(sheen, radius)
    UI.gradient(sheen, { Rotation = 90, Transparency = UI.alphaSeq(0, opts.sheenAlpha or 0.93, 0.45, 1, 1, 1) })
    sheen.Parent = frame
  end
  local rim = Instance.new("UIStroke")
  rim.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  rim.Thickness = 1
  rim.Color = Color3.new(1, 1, 1)
  if UI.fx.innerStroke then rim.BorderStrokePosition = Enum.BorderStrokePosition.Inner end
  local rimGradient = UI.gradient(rim, { Rotation = 52,
    Transparency = UI.alphaSeq(0, opts.rimHi or 0.55, 0.32, 0.9, 0.68, 0.93, 1, opts.rimLo or 0.72) })
  rim.Parent = frame
  if opts.shadow and UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, opts.shadow == true and 56 or opts.shadow)
    shadow.Offset = UDim2.fromOffset(0, opts.shadowY or 22)
    shadow.Color = Color3.new(0, 0, 0)
    Theme.bind(shadow, "Transparency", "shadowA")
    pcall(function() shadow.ShowBehindParent = false end)
    shadow.Parent = frame
  end
  if opts.props then
    for key, value in pairs(opts.props) do frame[key] = value end
  end
  frame.Parent = parent
  return frame, rimGradient
end

-- A quiet filled surface (cards, rows): ink at a low alpha with a hairline.
function UI.surface(parent, props, radius, fill)
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  Theme.bind(frame, "BackgroundColor3", "ink")
  Theme.bind(frame, "BackgroundTransparency", fill or "fill1A")
  UI.corner(frame, radius or "rCard")
  if props then
    for key, value in pairs(props) do frame[key] = value end
  end
  frame.Parent = parent
  return frame
end

-- A container that can fade as one. Falls back to a plain frame where a
-- CanvasGroup would soften text; UI.fade then just shows or hides it.
function UI.group(parent, props)
  local group = Instance.new(UI.fx.canvas and "CanvasGroup" or "Frame")
  group.BackgroundTransparency = 1
  group.BorderSizePixel = 0
  if props then
    for key, value in pairs(props) do group[key] = value end
  end
  group.Parent = parent
  return group
end
function UI.fade(group, alpha, preset, done)
  if group:IsA("CanvasGroup") then
    if alpha > 0 then group.Visible = true end
    Motion.to(group, "GroupTransparency", 1 - alpha, preset or "quick", function()
      if alpha <= 0 then group.Visible = false end
      if done then done() end
    end)
  else
    group.Visible = alpha > 0
    if done then done() end
  end
end
function UI.setFade(group, alpha)
  if group:IsA("CanvasGroup") then Motion.snap(group, "GroupTransparency", 1 - alpha) end
  group.Visible = alpha > 0
end

-- ---------------------------------------------------------------- sound
local sounds = {}
function UI.sfx(name, volume)
  if not UI.sfxOn or UI.sfxVolume <= 0 or not UI.soundHost then return end
  local id = Assets.sound(name)
  if not id then return end
  local now = os.clock()
  local entry = sounds[name]
  if entry and now - entry.at < 0.04 then return end
  if not entry then
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Parent = UI.soundHost
    entry = { sound = sound, at = 0 }
    sounds[name] = entry
  end
  entry.at = now
  entry.sound.Volume = (volume or 1) * UI.sfxVolume * 0.5
  entry.sound.PlaybackSpeed = 0.97 + math.random() * 0.06
  entry.sound:Play()
end
-- A look's own sound, by its asset id (src/53: Novoline's), at the volume and speed that look plays
-- it at when the hub's sound volume is where it starts (45 %), and louder or softer with it.
function UI.sfxId(id, volume, speed)
  if not UI.sfxOn or UI.sfxVolume <= 0 or not UI.soundHost then return end
  local key = id .. "@" .. tostring(speed or 1)
  local now = os.clock()
  local entry = sounds[key]
  if entry and now - entry.at < 0.04 then return end
  if not entry then
    local sound = Instance.new("Sound")
    sound.SoundId = id
    sound.Parent = UI.soundHost
    entry = { sound = sound, at = 0 }
    sounds[key] = entry
  end
  entry.at = now
  entry.sound.Volume = math.clamp((volume or 1) * UI.sfxVolume / 0.45, 0, 2)
  entry.sound.PlaybackSpeed = speed or 1
  entry.sound.TimePosition = 0
  entry.sound:Play()
end

-- ---------------------------------------------------------------- input
local function isPress(input)
  return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end
UI.isPress = isPress
-- One coordinate space everywhere: the one AbsolutePosition reports. Measured on the client:
-- a ScreenGui that ignores the inset sits at AbsolutePosition (0, -58), InputObject.Position is
-- in that same space, and GetMouseLocation / the camera's viewport are 58 px further down.
function UI.inset() return S.GuiService:GetGuiInset() end
function UI.mouse() return UIS:GetMouseLocation() - S.GuiService:GetGuiInset() end
function UI.point(input) return Vector2.new(input.Position.X, input.Position.Y) end
-- design units -> screen pixels for anything inside the window (set by 06 window)
function UI.unit() return 1 end
function UI.inside(gui, point)
  local p, s = gui.AbsolutePosition, gui.AbsoluteSize
  return point.X >= p.X and point.X <= p.X + s.X and point.Y >= p.Y and point.Y <= p.Y + s.Y
end

-- Attach hover / press / click / alt (right click) handlers to a GuiButton.
function UI.wire(button, handlers)
  local pressing = false
  if handlers.hover then
    button.MouseEnter:Connect(B.safe("ui.hover", function() handlers.hover(true) end))
    button.MouseLeave:Connect(B.safe("ui.hover", function()
      handlers.hover(false)
      if pressing and handlers.press then pressing = false; handlers.press(false) end
    end))
  end
  button.InputBegan:Connect(B.safe("ui.press", function(input)
    if isPress(input) then
      pressing = true
      if handlers.press then handlers.press(true) end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 and handlers.alt then
      handlers.alt(input)
    end
  end))
  button.InputEnded:Connect(B.safe("ui.press", function(input)
    if isPress(input) and pressing then
      pressing = false
      if handlers.press then handlers.press(false) end
    end
  end))
  if handlers.click then button.Activated:Connect(B.safe("ui.click", function(input) handlers.click(input) end)) end
  return button
end
-- An invisible button laid over `parent`. Only for parents WITHOUT a list layout or automatic
-- width: a full-size child there is laid out as an item and inflates the parent (measured:
-- a 60 px dropdown pill became 550 px). Those use UI.pressable instead.
function UI.button(parent, handlers, props)
  local button = Instance.new("TextButton")
  button.Name = "Hit"
  button.Text = ""
  button.BackgroundTransparency = 1
  button.BorderSizePixel = 0
  button.AutoButtonColor = false
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = 5
  if props then
    for key, value in pairs(props) do button[key] = value end
  end
  UI.wire(button, handlers)
  button.Parent = parent
  return button
end
-- A container that is itself the button: children (labels, icons, layouts) go inside it.
function UI.pressable(parent, props, handlers)
  local button = Instance.new("TextButton")
  button.Text = ""
  button.AutoButtonColor = false
  button.BorderSizePixel = 0
  button.BackgroundTransparency = 1
  if props then
    for key, value in pairs(props) do
      if key == "Theme" then applyTheme(button, value) else button[key] = value end
    end
  end
  if handlers then UI.wire(button, handlers) end
  button.Parent = parent
  return button
end

-- Drag with mouse or finger. onMove(position, deltaFromStart); returns nothing.
function UI.drag(handle, onStart, onMove, onEnd)
  handle.InputBegan:Connect(B.safe("ui.drag", function(input)
    if not isPress(input) then return end
    local start = UI.point(input)
    if onStart and onStart(start) == false then return end
    local touch = input.UserInputType == Enum.UserInputType.Touch
    local moved, ended
    local function finish()
      if moved then moved:Disconnect() end
      if ended then ended:Disconnect() end
      moved, ended = nil, nil
      if onEnd then B.try("ui.drag.end", onEnd) end
    end
    moved = UIS.InputChanged:Connect(B.safe("ui.drag.move", function(change)
      if (touch and change == input) or (not touch and change.UserInputType == Enum.UserInputType.MouseMovement) then
        local p = UI.point(change)
        onMove(p, p - start)
      end
    end))
    ended = UIS.InputEnded:Connect(function(finished)
      if finished == input or (not touch and finished.UserInputType == Enum.UserInputType.MouseButton1) then finish() end
    end)
  end))
end

-- ---------------------------------------------------------------- overlay layer
-- Popovers, menus and tooltips live in one full-screen layer above the window.
local popovers = {}
function UI.mountOverlay(gui, scaleSource)
  UI.overlay = UI.frame(gui, { Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 50 })
  UI.overlayScale = scaleSource
  -- a click anywhere outside the open popover closes it
  B.connect(UIS.InputBegan, function(input)
    if #popovers == 0 then return end
    if isPress(input) or input.UserInputType == Enum.UserInputType.MouseButton2 then
      local point = UI.point(input)
      for index = #popovers, 1, -1 do
        local pop = popovers[index]
        if not UI.inside(pop.frame, point) and not (pop.anchor and UI.inside(pop.anchor, point)) then pop.close() else break end
      end
    elseif input.KeyCode == Enum.KeyCode.Escape then
      popovers[#popovers].close()
    end
  end, "ui.overlay")
end
function UI.closePopovers()
  for index = #popovers, 1, -1 do popovers[index].close(true) end
end
function UI.popoverOpen() return #popovers > 0 end

-- Open a glass panel next to `anchor`. build(content, close) fills it.
-- opts: width, align ("left" | "right" | "center"), gap, side ("below" | "above")
function UI.popover(anchor, opts, build)
  opts = opts or {}
  local scale = UI.overlayScale and UI.overlayScale() or 1
  local width = opts.width or 220
  local pop = { anchor = anchor }
  local holder = UI.frame(UI.overlay, { Name = "Popover", Size = UDim2.fromOffset(width, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 60 })
  local sizer = Instance.new("UIScale")
  sizer.Scale = scale * 0.92
  sizer.Parent = holder
  local glass = UI.glass(holder, { level = "popover", radius = "rCard", shadow = 34, shadowY = 14, rimHi = 0.62, name = "Panel",
    props = { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y } })
  local group = UI.group(glass, { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.pad(group, opts.pad or 6)
  UI.list(group, "y", opts.gap or 2)
  pop.frame = holder
  local closed = false
  function pop.close(instant)
    if closed then return end
    closed = true
    local at = table.find(popovers, pop)
    if at then table.remove(popovers, at) end
    if opts.onClose then B.try("popover.close", opts.onClose) end
    if instant then holder:Destroy(); return end
    Motion.to(sizer, "Scale", scale * 0.94, "quick")
    UI.fade(group, 0, "quick")
    Motion.to(glass, "BackgroundTransparency", 1, "quick", function() holder:Destroy() end)
  end
  B.try("popover.build", build, group, pop.close)
  -- place it once its height is known
  local function place()
    local view = B.viewport()
    local a, s = anchor.AbsolutePosition, anchor.AbsoluteSize
    local size = holder.AbsoluteSize
    local w, h = width * scale, math.max(size.Y, 1)
    local x
    if opts.align == "left" then x = a.X elseif opts.align == "center" then x = a.X + s.X / 2 - w / 2 else x = a.X + s.X - w end
    local y = a.Y + s.Y + 6 * scale
    local above = opts.side == "above" or (y + h > view.Y - 8 and a.Y - h - 6 * scale > 8)
    if above then y = a.Y - h - 6 * scale end
    local origin = UI.overlay.AbsolutePosition
    x = math.clamp(x - origin.X, 8, math.max(8, view.X - w - 8))
    y = math.clamp(y - origin.Y, 8, math.max(8, view.Y - h - 8))
    holder.Position = UDim2.fromOffset(x, y)
    return above
  end
  place()
  holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if not closed then place() end end)
  UI.setFade(group, 0)
  UI.fade(group, 1, "quick")
  Motion.to(sizer, "Scale", scale, "snappy")
  popovers[#popovers + 1] = pop
  UI.sfx("open", 0.5)
  return pop
end

-- A simple menu: items = { { label, icon?, hint?, danger?, checked?, run } | "divider" }
-- A long one (more than opts.rows of them, 11 unless said) scrolls, and opens on the one that is checked.
function UI.menu(anchor, items, opts)
  opts = opts or {}
  return UI.popover(anchor, { width = opts.width or 208, align = opts.align, side = opts.side }, function(content, close)
    local rows = opts.rows or 11
    if #items > rows then
      local holder = UI.frame(content, { Name = "Long", Size = UDim2.new(1, 0, 0, rows * 34 - 2) })
      local scroller, scroll = UI.scroll(holder, { Size = UDim2.fromScale(1, 1), Name = "Scroll" })
      content = UI.frame(scroller, { Name = "Rows", Size = UDim2.new(1, -9, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
      UI.list(content, "y", 2)
      for index, item in ipairs(items) do
        if type(item) == "table" and item.checked then
          task.defer(function() if holder.Parent then scroll.to((index - 4) * 34, true) end end)
          break
        end
      end
    end
    for index, item in ipairs(items) do
      if item == "divider" then
        local line = UI.frame(content, { Size = UDim2.new(1, -12, 0, 1), LayoutOrder = index, Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
        line.Position = UDim2.fromOffset(6, 0)
      else
        local row = UI.frame(content, { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = index, Theme = { BackgroundColor3 = "ink" } })
        UI.corner(row, "rSmall")
        local x = 10
        if item.icon then
          UI.icon(row, item.icon, 16, item.danger and "bad" or "sub", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
          x = 34
        end
        UI.text(row, item.label, "label", item.danger and "bad" or "ink", { Position = UDim2.new(0, x, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13 })
        if item.checked then
          UI.icon(row, "check", 15, "accent", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
        elseif item.hint then
          UI.text(row, item.hint, "mono", "faint", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
        end
        UI.button(row, {
          hover = function(on) Motion.to(row, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
          click = function()
            UI.sfx("click", 0.6)
            if not item.keepOpen then close() end
            if item.run then item.run() end
          end,
        })
      end
    end
  end)
end

-- ---------------------------------------------------------------- tooltip
-- One tip for the whole hub, in every look (2026-10-30: nearly every control says what it does when
-- the mouse rests on it). It comes beside what it is about (to its right, else its left, else under
-- it, always on the screen), fades and slides in, and goes straight on to the next thing the mouse
-- rests on without going away first. On a screen of its own, above everything.
local TIP_W, TIP_MIN = 250, 110
local tipGui, tipCard, tipTitle, tipBody, tipFor
local tipToken, tipShown, tipGoneAt = 0, false, -math.huge
local function tipBuild()
  if tipCard and tipCard.Parent and tipGui and tipGui.Parent then return true end
  if not B.alive then return false end
  tipGui = B.screen(9950)
  tipCard = Instance.new("CanvasGroup")
  tipCard.Name = "Tip"
  -- (one flat colour, no UIGradient: measured live 2026-10-30, a gradient on a CanvasGroup tints all
  -- that is drawn in it, and the words came out near black on the card)
  tipCard.BackgroundColor3, tipCard.BackgroundTransparency, tipCard.BorderSizePixel = Color3.fromRGB(21, 21, 25), 0, 0
  tipCard.Size, tipCard.AutomaticSize = UDim2.fromOffset(TIP_W, 0), Enum.AutomaticSize.Y
  tipCard.GroupTransparency, tipCard.Visible = 1, false
  local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 10); corner.Parent = tipCard
  local rim = Instance.new("UIStroke")
  rim.ApplyStrokeMode, rim.Color, rim.Transparency, rim.Thickness = Enum.ApplyStrokeMode.Border, Color3.new(1, 1, 1), 0.86, 1
  rim.Parent = tipCard
  local padding = Instance.new("UIPadding")
  padding.PaddingTop, padding.PaddingBottom, padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 8), UDim.new(0, 9), UDim.new(0, 11), UDim.new(0, 11)
  padding.Parent = tipCard
  local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 2); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = tipCard
  local function line(order, font, size, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency, label.BorderSizePixel = 1, 0
    label.Size, label.AutomaticSize = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
    label.FontFace, label.TextSize, label.TextColor3 = font, size, color
    label.TextWrapped, label.TextXAlignment, label.LayoutOrder = true, Enum.TextXAlignment.Left, order
    label.Text, label.Visible = "", true
    label.Parent = tipCard
    return label
  end
  tipTitle = line(1, B.F.text600, 12, Color3.fromRGB(246, 246, 248))
  tipBody = line(2, B.F.text400, 12, Color3.fromRGB(190, 190, 198))
  tipCard.Parent = tipGui
  return true
end
local TIP_IN = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TIP_MOVE = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TIP_OUT = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local function tipShow(target, title, text)
  if not tipBuild() then return end
  tipTitle.Text, tipTitle.Visible = title or "", title ~= nil and title ~= ""
  tipBody.Text = text
  -- (as wide as its words want, up to TIP_W: a short tip is a small card)
  local width = math.clamp(math.max(#(title or "") * 7.2, #text * 6.3) + 24, TIP_MIN, TIP_W)
  tipCard.Size = UDim2.fromOffset(width, 0)
  local base = tipGui.AbsolutePosition
  local view = tipGui.AbsoluteSize
  local at, size = target.AbsolutePosition - base, target.AbsoluteSize
  local height = (tipTitle.Visible and 16 or 0) + math.ceil(#text * 6.3 / math.max(width - 22, 40)) * 16 + 20
  local x, y = at.X + size.X + 10, at.Y + size.Y / 2 - height / 2
  local from = Vector2.new(-8, 0)
  if x + width > view.X - 8 then
    x, from = at.X - width - 10, Vector2.new(8, 0)
    if x < 8 then
      -- (no room either side: under it, or over it)
      x = math.clamp(at.X + size.X / 2 - width / 2, 8, math.max(view.X - width - 8, 8))
      y, from = at.Y + size.Y + 8, Vector2.new(0, -6)
      if y + height > view.Y - 8 then y, from = at.Y - height - 8, Vector2.new(0, 6) end
    end
  end
  y = math.clamp(y, 8, math.max(view.Y - height - 8, 8))
  local goal = UDim2.fromOffset(math.floor(x), math.floor(y))
  if tipShown and tipCard.Visible then
    -- (already showing: it moves over to the new one)
    S.TweenService:Create(tipCard, TIP_MOVE, { Position = goal, GroupTransparency = 0 }):Play()
  else
    tipCard.Position = goal + UDim2.fromOffset(from.X, from.Y)
    tipCard.GroupTransparency = 1
    tipCard.Visible = true
    S.TweenService:Create(tipCard, TIP_IN, { Position = goal, GroupTransparency = 0 }):Play()
  end
  tipShown = true
end
local function tipHide()
  if not (tipShown and tipCard) then return end
  tipShown = false
  tipGoneAt = os.clock()
  local mine = tipToken
  S.TweenService:Create(tipCard, TIP_OUT, { GroupTransparency = 1 }):Play()
  task.delay(0.11, function() if mine == tipToken and not tipShown and tipCard then tipCard.Visible = false end end)
end
-- target: the thing the mouse rests on; text: what it does; title: its name (optional)
function UI.tooltip(target, text, title)
  if type(text) ~= "string" or text == "" then return end
  target.MouseEnter:Connect(function()
    tipToken += 1
    local mine = tipToken
    tipFor = target
    -- (one tip just showing, or just gone: the next comes at once, the way a menu's tips do)
    local quick = tipShown or os.clock() - tipGoneAt < 0.3
    task.delay(quick and 0.02 or 0.35, function()
      if mine ~= tipToken or tipFor ~= target or not B.alive or not target.Parent then return end
      B.try("ui.tip", tipShow, target, title, text)
    end)
  end)
  target.MouseLeave:Connect(function()
    if tipFor ~= target then return end
    tipFor = nil
    tipToken += 1
    local mine = tipToken
    task.delay(0.06, function() if mine == tipToken then tipHide() end end)
  end)
  -- (a click: it has been read; it goes)
  if target:IsA("GuiButton") then target.MouseButton1Down:Connect(function() tipToken += 1; tipFor = nil; tipHide() end) end
end
function UI.hideTip()
  tipToken += 1
  tipFor = nil
  tipHide()
end

-- ---------------------------------------------------------------- scroll
-- A vertical scroller with a spring-driven wheel and a scrollbar: a thumb that says how far down
-- the page is, grows under the pointer, and can be dragged; a press on the track beside it goes
-- there. UI.scrollbar: "always" (it rests faint), "auto" (only while the page moves), "off".
UI.scrollbar = "always"
local scrollers = setmetatable({}, { __mode = "k" })
function UI.setScrollbar(mode)
  UI.scrollbar = mode
  for _, paint in pairs(scrollers) do B.try("ui.scrollbar", paint) end
end
local BAR_REST, BAR_WIDE, BAR_GRIP = 3, 6, 14     -- the thumb at rest and under the pointer, and the strip that takes the pointer
function UI.scroll(parent, props)
  local scroller = Instance.new("ScrollingFrame")
  scroller.BackgroundTransparency = 1
  scroller.BorderSizePixel = 0
  scroller.ScrollBarThickness = 0
  scroller.ScrollingDirection = Enum.ScrollingDirection.Y
  scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
  scroller.CanvasSize = UDim2.new()
  scroller.ElasticBehavior = Enum.ElasticBehavior.Never
  scroller.ScrollingEnabled = B.touch
  if props then
    for key, value in pairs(props) do scroller[key] = value end
  end
  scroller.Parent = parent
  local thumb = UI.frame(parent, { Name = "Thumb", Size = UDim2.fromOffset(BAR_REST, 40), AnchorPoint = Vector2.new(1, 0), ZIndex = 8,
    Theme = { BackgroundColor3 = "ink" }, BackgroundTransparency = 1 })
  UI.corner(thumb, true)
  local grip = UI.new("TextButton", { Name = "Scrollbar", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
    Size = UDim2.fromOffset(BAR_GRIP, 40), ZIndex = 9, Visible = false, Parent = parent })
  local target = 0
  local spring = Motion.spring(1, "smooth", function(x)
    scroller.CanvasPosition = Vector2.new(0, x[1])
  end, 0.2)
  local function limit()
    return math.max(0, scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y)
  end
  local hideToken = 0
  local hovered, dragging, flashing, width = false, false, false, BAR_REST
  local bar = { top = 0, size = 0, span = 0 }       -- the thumb as it was last laid out, in screen pixels
  -- false when there is nothing to scroll, or the bar is switched off
  local function refresh()
    local window, canvas = scroller.AbsoluteWindowSize.Y, scroller.AbsoluteCanvasSize.Y
    local needed = canvas > window + 1 and window > 0 and UI.scrollbar ~= "off"
    if grip.Visible ~= needed then grip.Visible = needed end
    if not needed then thumb.BackgroundTransparency = 1; return false end
    local track = scroller.AbsoluteSize.Y - 12
    local size = math.max(28, track * window / canvas)
    local ratio = scroller.CanvasPosition.Y / math.max(1, canvas - window)
    local unit = UI.unit()
    local right = (scroller.AbsolutePosition.X - parent.AbsolutePosition.X + scroller.AbsoluteSize.X) / unit
    local top = scroller.AbsolutePosition.Y - parent.AbsolutePosition.Y
    thumb.Size = UDim2.fromOffset(width, size / unit)
    thumb.Position = UDim2.new(0, right - 3, 0, (top + 6 + (track - size) * ratio) / unit)
    grip.Size = UDim2.fromOffset(BAR_GRIP, scroller.AbsoluteSize.Y / unit)
    grip.Position = UDim2.new(0, right, 0, top / unit)
    bar.top, bar.size, bar.span = scroller.AbsolutePosition.Y + 6, size, track - size
    return true
  end
  local widen = Motion.spring(1, "snappy", function(x)
    width = x[1]
    refresh()
  end, 0.05)
  widen:snap({ BAR_REST })
  -- how solid the thumb is: held, under the pointer, while the page moves, or at rest
  local function paint()
    if not refresh() then return end
    local alpha = dragging and 0.35 or hovered and 0.5 or flashing and 0.62 or (UI.scrollbar == "always" and 0.82 or 1)
    Motion.to(thumb, "BackgroundTransparency", alpha, alpha >= 0.8 and "gentle" or "quick")
    widen:to({ (dragging or hovered) and BAR_WIDE or BAR_REST })
  end
  scrollers[scroller] = paint
  local function flash()
    flashing = true
    paint()
    hideToken += 1
    local mine = hideToken
    task.delay(0.9, function()
      if mine == hideToken and thumb.Parent then flashing = false; paint() end
    end)
  end
  scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(flash)
  scroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
    if target > limit() then target = limit(); spring:to({ target }) end
    paint()
  end)
  scroller:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(paint)
  -- the thumb held: the page goes with the pointer, with no spring between them
  local grab = 0
  local function follow(y)
    local ratio = bar.span > 0 and math.clamp((y - grab - bar.top) / bar.span, 0, 1) or 0
    target = ratio * limit()
    spring:snap({ target })
  end
  UI.drag(grip, function(point)
    if not refresh() then return false end
    local at = bar.top + bar.span * (scroller.CanvasPosition.Y / math.max(1, limit()))
    -- on the thumb it is taken where it was pressed; beside it, the thumb comes to the pointer
    grab = (point.Y >= at and point.Y <= at + bar.size) and (point.Y - at) or bar.size * 0.5
    dragging = true
    follow(point.Y)
    paint()
    return true
  end, function(point) follow(point.Y) end, function()
    dragging = false
    paint()
  end)
  grip.MouseEnter:Connect(function() hovered = true; paint() end)
  grip.MouseLeave:Connect(function() hovered = false; paint() end)
  local wheel = B.safe("ui.wheel", function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseWheel or B.touch then return end
    -- An open list (any popover) holds the page under it still: the wheel over it scrolls the list
    -- alone. Before, the page went on scrolling under an open dropdown and left it behind.
    local top = popovers[#popovers]
    if top and not (top.frame and scroller:IsDescendantOf(top.frame)) then return end
    if not spring:moving() then
      spring.x[1], spring.g[1] = scroller.CanvasPosition.Y, scroller.CanvasPosition.Y
      target = scroller.CanvasPosition.Y
    end
    target = math.clamp(target - input.Position.Z * 92, 0, limit())
    spring:to({ target })
  end)
  scroller.InputChanged:Connect(wheel)
  grip.InputChanged:Connect(wheel)        -- (the strip lies over the page's edge: the wheel works there too)
  -- (painted once it is laid out, not only when something about it changes)
  task.defer(function() if scroller.Parent then B.try("ui.scrollbar", paint) end end)
  local api = { frame = scroller, thumb = thumb, grip = grip }
  function api.to(y, instant)
    target = math.clamp(y, 0, limit())
    if instant then spring:snap({ target }) else
      spring.x[1] = scroller.CanvasPosition.Y
      spring:to({ target })
    end
  end
  function api.top(instant) api.to(0, instant) end
  return scroller, api
end

-- ---------------------------------------------------------------- the interface's letters
-- Settings > Font: every word the BASED look writes in one family (its wordmark keeps its own).
-- Done where the letters come from: B.F's keys take the family at their own weight, so whatever is
-- drawn from now on has it, and what is on screen already is moved across once, matched by the
-- face it wore. The other looks keep their own letters (Unnamed has its own font setting).
UI.FAMILIES = {
  { "inter", "Inter (BASED)" },
  { "monocraft", "Monocraft (Minecraft)", function() return B.F0 and B.F0.craft end },
  { "builder", "Builder Sans", "BuilderSans" },
  { "gotham", "Gotham", "GothamSSm" },
  { "montserrat", "Montserrat", "Montserrat" },
  { "nunito", "Nunito", "Nunito" },
  { "ubuntu", "Ubuntu", "Ubuntu" },
  { "titillium", "Titillium", "TitilliumWeb" },
  { "jura", "Jura", "Jura" },
  { "sarpanch", "Sarpanch", "Sarpanch" },
  { "michroma", "Michroma", "Michroma" },
  { "oswald", "Oswald", "Oswald" },
  { "fredoka", "Fredoka", "FredokaOne" },
  { "roboto", "Roboto Mono", "RobotoMono" },
  { "arial", "Arial", function() return Font.fromEnum(Enum.Font.Arial) end },
  { "source", "Source Sans", "SourceSansPro" },
}
-- the keys that follow the pick (the wordmark, wideBlack, stays BASED)
local LETTER_KEYS = { "text400", "text500", "text600", "mono400", "mono500", "wideBold", "serif", "serifItalic" }
local function faceSig(face) return tostring(face.Family) .. "|" .. tostring(face.Weight) .. "|" .. tostring(face.Style) end
function UI.familyOf(id)
  for _, spec in ipairs(UI.FAMILIES) do
    if spec[1] == id then
      local source = spec[3]
      if source == nil then return nil end
      local ok, face = pcall(function()
        if type(source) == "function" then return source() end
        return Font.fromName(source)
      end)
      return ok and typeof(face) == "Font" and face.Family or nil
    end
  end
  return nil
end
-- Which key each text on screen was drawn from (strong, swept): told by its face the first time it
-- is seen, from the hub's own faces (all different), or from the faces in use now. The second can be
-- two keys at once (in one family Inter 400 and Geist 400 are the same face): the body text wins,
-- and texts drawn by UI.text say their key outright. (Matching by face alone turned 381 labels into
-- the serif on the way back to Inter.)
UI.fontKey = {}
function UI.sweepFonts()
  for label in pairs(UI.fontKey) do
    if not label.Parent then UI.fontKey[label] = nil end
  end
end
function UI.setLetters(id)
  if not B.F0 then return end
  local family = UI.familyOf(id)
  local own, now = {}, {}
  for _, key in ipairs(LETTER_KEYS) do
    if B.F0[key] then own[faceSig(B.F0[key])] = own[faceSig(B.F0[key])] or key end
    if B.F[key] then now[faceSig(B.F[key])] = now[faceSig(B.F[key])] or key end
  end
  for label in pairs(UI.fontKey) do
    if not label.Parent then UI.fontKey[label] = nil end
  end
  for _, key in ipairs(LETTER_KEYS) do
    local own = B.F0[key]
    if own then
      if family then
        local ok, face = pcall(Font.new, family, own.Weight, own.Style)
        B.F[key] = ok and face or own
      else
        B.F[key] = own
      end
    end
  end
  -- what is on screen now: each text moved to its key's new face
  -- (the other looks keep their own letters, also where they draw on the HUD)
  local function owns(item) return B.Novoline ~= nil and B.Novoline.owns(item) end
  for _, gui in ipairs(B.screens or {}) do
    if gui.Parent and not gui:GetAttribute("OwnLetters") then
      for _, item in ipairs(gui:GetDescendants()) do
        if (item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox")) and not owns(item) then
          local key = UI.fontKey[item]
          if not key then
            local sig = faceSig(item.FontFace)
            key = own[sig] or now[sig]
            if key then UI.fontKey[item] = key end
          end
          if key and B.F[key] and item.FontFace ~= B.F[key] then item.FontFace = B.F[key] end
        end
      end
    end
  end
end

-- ---------------------------------------------------------------- misc
function UI.divider(parent, order)
  local line = UI.frame(parent, { Name = "Divider", Size = UDim2.new(1, 0, 0, 1), LayoutOrder = order or 0,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
  return line
end
-- Small rounded tag: "NEW", "BETA", a key name...
function UI.badge(parent, text, color, props)
  local badge = UI.frame(parent, { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), Theme = { BackgroundColor3 = color or "accent" },
    BackgroundTransparency = 0.82 })
  UI.corner(badge, 6)
  UI.pad(badge, 0, 6)
  UI.text(badge, text, "eyebrow", color or "accent", { TextSize = 9, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  if props then
    for key, value in pairs(props) do badge[key] = value end
  end
  return badge
end
end

do -- 05_config.lua
-- ============================================================================
--  05 config   flags, profiles, keybinds
--
--  Every setting is a flag with an id. Ids under "app." are the hub's own
--  preferences (theme, intro, scale) and live in prefs.json; everything else is
--  a feature setting and lives in the active profile, which can be one file for
--  every game or one per game. Writes are debounced; nothing saves per frame.
-- ============================================================================
local S, fs, util = B.S, B.fs, B.util
local UIS = S.UserInputService
local Config = { profile = "default", changed = B.Signal.new(), loaded = B.Signal.new() }
B.Config = Config

local values, defaults, listeners = {}, {}, {}
local binds = {}            -- flag id -> { key = "E", mode = "toggle" | "hold" }
local actions = {}          -- id -> function, for bindable buttons
local stored = { app = {}, profile = {} }   -- raw decoded files, kept so unknown ids survive a save
local storedBinds = {}
Config.values, Config.defaults, Config.binds = values, defaults, binds

local function isApp(id) return string.sub(id, 1, 4) == "app." end
local function encode(value)
  local kind = typeof(value)
  if kind == "Color3" then return { __c = util.toHex(value) } end
  if kind == "EnumItem" then return { __e = tostring(value.EnumType), v = value.Name } end
  if kind == "table" then
    local out = {}
    for k, v in pairs(value) do out[k] = encode(v) end
    return out
  end
  return value
end
local function decode(value)
  if type(value) ~= "table" then return value end
  if type(value.__c) == "string" then
    local ok, color = pcall(util.hex, value.__c)
    return ok and color or nil
  end
  if value.__e then
    local ok, item = pcall(function() return Enum[value.__e][value.v] end)
    return ok and item or nil
  end
  local out = {}
  for k, v in pairs(value) do out[k] = decode(v) end
  return out
end
local function sameType(a, b)
  return typeof(a) == typeof(b)
end

-- What the hub ships with (based/shipped.json, baked in by the build): the settings a fresh
-- executor starts from. A shipped value takes the place of the default written in the code, so
-- a setting someone has saved still wins and Reset comes back to what shipped.
local shipped = type(B.SHIPPED) == "table" and B.SHIPPED or {}
local shippedValues = type(shipped.values) == "table" and shipped.values or {}
local shippedBinds = type(shipped.binds) == "table" and shipped.binds or {}

local function profilePath(name) return fs.path("config/" .. name .. ".json") end
local PREFS = fs.path("prefs.json")

-- Saving. Only what changed here is written, onto what is on disk at that moment: every account
-- open on this PC shares these files, and writing the whole of one client's memory undid what
-- another had just saved. A change made quietly (a test, a bot starting itself) is never written.
-- Whatever is waiting goes out at once on unload and on a teleport, not 0.6 s later or never.
local dirty, dirtyBinds = {}, {}
local pending = false
local function isDefault(id)
  local a, b = values[id], defaults[id]
  if type(a) ~= "table" or type(b) ~= "table" then return a == b end
  for k, v in pairs(a) do if b[k] ~= v then return false end end
  for k, v in pairs(b) do if a[k] ~= v then return false end end
  return true
end
local function flush()
  pending = false
  if next(dirty) == nil and next(dirtyBinds) == nil then return end
  local appTouched = false
  local prefs = fs.readJson(PREFS)
  prefs = type(prefs) == "table" and prefs or {}
  local app = type(prefs.values) == "table" and prefs.values or stored.app
  local bindOut = type(prefs.binds) == "table" and prefs.binds or nil
  if not bindOut then
    -- (nothing on disk yet: every key there is, the ones that shipped too, or they would be lost)
    bindOut = {}
    for id, bind in pairs(binds) do bindOut[id] = { key = bind.key, mode = bind.mode } end
    appTouched = true
  end
  local disk = fs.readJson(profilePath(Config.profile))
  local profile = (type(disk) == "table" and type(disk.values) == "table") and disk.values or stored.profile
  local profileTouched = false
  for id in pairs(dirty) do
    local bucket = isApp(id) and app or profile
    if values[id] == nil or isDefault(id) then bucket[id] = nil else bucket[id] = encode(values[id]) end
    if isApp(id) then appTouched = true else profileTouched = true end
  end
  for id in pairs(dirtyBinds) do
    local bind = binds[id]
    bindOut[id] = bind and { key = bind.key, mode = bind.mode } or nil
    appTouched = true
  end
  table.clear(dirty)
  table.clear(dirtyBinds)
  stored.app, stored.profile = app, profile
  if appTouched or prefs.profile ~= Config.profileMode then
    fs.writeJson(PREFS, { values = app, binds = bindOut, profile = Config.profileMode })
  end
  if profileTouched then
    fs.writeJson(profilePath(Config.profile), { values = profile, game = game.GameId, saved = os.time() })
  end
  Config.saved:fire()
end
Config.saved = B.Signal.new()
local later = util.debounce(0.6, function() if pending then B.try("config.save", flush) end end)
local function save() pending = true; later() end
function Config.save() save() end
-- write what is waiting now (unload, teleport, a profile switch)
function Config.flush() if pending or next(dirty) or next(dirtyBinds) then B.try("config.flush", flush) end end
function Config.touch(id) dirty[id] = true; save() end
B.onUnload:connect(function() Config.flush() end)

-- Register a flag. Returns its current value (the saved one when there is one).
function Config.define(id, default)
  if defaults[id] ~= nil then return values[id] end
  local ships = decode(shippedValues[id])
  if ships ~= nil and sameType(ships, default) then default = ships end
  defaults[id] = default
  local bucket = isApp(id) and stored.app or stored.profile
  local saved = decode(bucket[id])
  if saved ~= nil and sameType(saved, default) then values[id] = saved else values[id] = default end
  local savedBind = storedBinds[id]
  if savedBind and savedBind.key and not binds[id] then
    binds[id] = { key = savedBind.key, mode = savedBind.mode or "toggle" }
    -- (a switch made after the keys started listening, on a tab built later: its key works at once)
    if Config.reindex then Config.reindex() end
  end
  return values[id]
end
function Config.get(id) return values[id] end
function Config.set(id, value, quiet)
  if defaults[id] == nil then defaults[id] = value end
  local old = values[id]
  if old == value and type(value) ~= "table" then return end
  values[id] = value
  local list = listeners[id]
  if list then
    for _, fn in ipairs(table.clone(list)) do B.try("config." .. id, fn, value, old) end
  end
  if not quiet then
    dirty[id] = true
    Config.changed:fire(id, value)
    save()
  end
end
function Config.reset(id) if defaults[id] ~= nil then Config.set(id, util.copy(defaults[id])) end end
function Config.isDefault(id) return isDefault(id) end
-- fn(value, old) on every change; `now` also calls it once with the current value.
function Config.on(id, fn, now)
  local list = listeners[id]
  if not list then list = {}; listeners[id] = list end
  list[#list + 1] = fn
  if now and values[id] ~= nil then B.try("config." .. id, fn, values[id], nil) end
  return function()
    local at = table.find(list, fn)
    if at then table.remove(list, at) end
  end
end
-- Mirror a set of flags into a plain table that feature loops can read for free:
--   local O = Config.mirror({ enabled = "esp.enabled", range = "esp.range" })
function Config.mirror(map, onChange)
  local out = {}
  for key, id in pairs(map) do
    out[key] = values[id]
    Config.on(id, function(value)
      out[key] = value
      if onChange then onChange(key, value) end
    end)
  end
  return out
end

-- ---------------------------------------------------------------- profiles
Config.profileMode = "global"     -- "global": one config everywhere; "game": one per game
function Config.profiles()
  local out = {}
  for _, file in ipairs(fs.list(fs.path("config"))) do
    local name = string.match(file, "([^/]+)%.json$")
    if name then out[#out + 1] = name end
  end
  if not table.find(out, "default") then table.insert(out, 1, "default") end
  return out
end
local function readProfile(name)
  local data = fs.readJson(profilePath(name))
  return type(data) == "table" and type(data.values) == "table" and data.values or {}
end
function Config.init()
  local prefs = fs.readJson(PREFS)
  if type(prefs) == "table" then
    stored.app = type(prefs.values) == "table" and prefs.values or {}
    storedBinds = type(prefs.binds) == "table" and prefs.binds or {}
    if prefs.profile == "game" then Config.profileMode = "game" end
  else
    -- nothing saved here yet: the keys that ship. Only then, or a key someone cleared would come back.
    storedBinds = shippedBinds
    -- (and the first launch on this machine: the look is picked before the hub opens, src/13_picker)
    Config.firstRun = true
  end
  Config.profile = Config.profileMode == "game" and ("game_" .. tostring(game.GameId)) or "default"
  stored.profile = readProfile(Config.profile)
  -- (a teleport ends this client: what is waiting is written as it starts)
  pcall(function()
    B.connect(B.LP.OnTeleport, function(state)
      if state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then Config.flush() end
    end, "config.teleport")
  end)
end
-- Switch to another profile: every feature flag takes the value saved there.
function Config.load(name)
  Config.flush()                          -- (what is waiting belongs to the profile being left)
  Config.profile = name
  stored.profile = readProfile(name)
  for id, default in pairs(defaults) do
    if not isApp(id) then
      local saved = decode(stored.profile[id])
      if saved == nil or not sameType(saved, default) then saved = util.copy(default) end
      Config.set(id, saved, true)
    end
  end
  Config.loaded:fire(name)
  -- (the mode lives in prefs.json)
  local prefs = fs.readJson(PREFS)
  if type(prefs) == "table" and prefs.profile ~= Config.profileMode then
    prefs.profile = Config.profileMode
    fs.writeJson(PREFS, prefs)
  end
end
function Config.saveAs(name)
  name = string.gsub(name, "[^%w_%-]", "")
  if name == "" then return false end
  Config.flush()
  Config.profile = name
  stored.profile = {}
  for id in pairs(defaults) do
    if not isApp(id) then dirty[id] = true end
  end
  save()
  return true
end
function Config.delete(name)
  if name == "default" then return false end
  return fs.remove(profilePath(name))
end
function Config.setMode(mode)
  Config.profileMode = mode
  Config.load(mode == "game" and ("game_" .. tostring(game.GameId)) or "default")
end
function Config.resetAll(includeApp)
  for id, default in pairs(defaults) do
    if includeApp or not isApp(id) then Config.set(id, util.copy(default)) end
  end
end
-- The share code: EVERY setting (the look too: colours, font, menu style, intro) and every key,
-- as "BASED2:" and base64. Pasted in, the other hub becomes this one: what the code has is set,
-- and what it leaves out is put back to its default, so nothing of theirs is left mixed in.
-- (The first version carried feature settings only, and only ones changed from their defaults:
-- a colour, a key, or a setting the other person had changed and this one had not stayed theirs.)
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function toBase64(data)
  return ((string.gsub(data, ".", function(x)
    local r, byte = "", string.byte(x)
    for i = 8, 1, -1 do r ..= (byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0") end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then return "" end
    local c = 0
    for i = 1, 6 do c += (string.sub(x, i, i) == "1" and 2 ^ (6 - i) or 0) end
    return string.sub(B64, c + 1, c + 1)
  end) .. ({ "", "==", "=" })[#data % 3 + 1])
end
local function fromBase64(data)
  data = string.gsub(data, "[^" .. B64 .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then return "" end
    local r, f = "", (string.find(B64, x, 1, true) - 1)
    for i = 6, 1, -1 do r ..= (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then return "" end
    local c = 0
    for i = 1, 8 do c += (string.sub(x, i, i) == "1" and 2 ^ (8 - i) or 0) end
    return string.char(c)
  end))
end
Config.toBase64, Config.fromBase64 = toBase64, fromBase64
-- where windows sit is the screen's business, not a setup's
local PLACE = { ["app.window.x"] = true, ["app.window.y"] = true, ["app.keyHudX"] = true, ["app.keyHudY"] = true }
-- (and some things are yours alone: a share code leaves them out, and pasting one leaves yours be)
function Config.unshared(id) PLACE[id] = true end
function Config.export()
  local out, keys = {}, {}
  for id, value in pairs(values) do
    if not PLACE[id] and defaults[id] ~= nil and not isDefault(id) then out[id] = encode(value) end
  end
  for id, bind in pairs(binds) do
    if bind.key then keys[id] = { key = bind.key, mode = bind.mode } end
  end
  local ok, json = pcall(S.HttpService.JSONEncode, S.HttpService, { based = 2, values = out, binds = keys, full = true })
  return ok and ("BASED2:" .. toBase64(json)) or nil
end
function Config.import(text)
  text = tostring(text or "")
  local json = text
  local coded = string.match(text, "BASED2:(%S+)")
  if coded then json = fromBase64(coded) end
  local ok, data = pcall(S.HttpService.JSONDecode, S.HttpService, json)
  if not ok or type(data) ~= "table" or type(data.values) ~= "table" then return false, 0 end
  local count = 0
  -- (an old code holds feature settings only, changed ones: those alone are set)
  if data.full then
    for id, default in pairs(defaults) do
      if data.values[id] == nil and not PLACE[id] and not isDefault(id) then Config.set(id, util.copy(default)) end
    end
  end
  for id, raw in pairs(data.values) do
    local default = defaults[id]
    local value = decode(raw)
    if default ~= nil and value ~= nil and sameType(value, default) and not PLACE[id] and (data.full or not isApp(id)) then
      Config.set(id, value)
      count += 1
    end
  end
  if type(data.binds) == "table" then
    for id in pairs(table.clone(binds)) do
      if data.binds[id] == nil then Config.bind(id, nil) end
    end
    for id, bind in pairs(data.binds) do
      if type(bind) == "table" and type(bind.key) == "string" then Config.bind(id, bind.key, bind.mode == "hold" and "hold" or "toggle"); count += 1 end
    end
  end
  return true, count
end

-- ---------------------------------------------------------------- keybinds
local byKey = {}
local function keyName(input)
  if input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode.Name end
  if input.UserInputType == Enum.UserInputType.MouseButton2 then return "MouseButton2" end
  if input.UserInputType == Enum.UserInputType.MouseButton3 then return "MouseButton3" end
  return nil
end
Config.keyName = keyName
local function reindex()
  table.clear(byKey)
  for id, bind in pairs(binds) do
    if bind.key then
      local list = byKey[bind.key]
      if not list then list = {}; byKey[bind.key] = list end
      list[#list + 1] = id
    end
  end
end
Config.reindex = reindex
Config.bindsChanged = B.Signal.new()
function Config.bind(id, key, mode)
  if not key then binds[id] = nil else binds[id] = { key = key, mode = mode or (binds[id] and binds[id].mode) or "toggle" } end
  reindex()
  dirtyBinds[id] = true
  Config.bindsChanged:fire(id)
  save()
end
function Config.bindOf(id) return binds[id] end
-- A button that can be bound (an emote, mark the one looked at...). Its saved key comes back here:
-- before, only switches took theirs back (in define), and every key on a button was lost on rejoin.
function Config.action(id, fn)
  actions[id] = fn
  local savedBind = storedBinds[id]
  if savedBind and savedBind.key and not binds[id] then
    binds[id] = { key = savedBind.key, mode = savedBind.mode or "toggle" }
    reindex()
    Config.bindsChanged:fire(id)
  end
end
function Config.isAction(id) return actions[id] ~= nil end
-- Whether a button's work is going on, for the key list to light it like a switch that is on: its
-- own say if it has one (an emote: while it plays), else for a moment after its key was pressed.
local actionStates = {}
Config.ranAt = {}
Config.actionRan = B.Signal.new()
function Config.actionState(id, fn) actionStates[id] = fn end
function Config.isActive(id)
  local state = actionStates[id]
  if state then
    local ok, on = pcall(state)
    if ok and on then return true end
    if ok and on == false then return false end
  end
  local at = Config.ranAt[id]
  return at ~= nil and os.clock() - at < 0.6
end
local SHORT = { LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift", LeftAlt = "LAlt", RightAlt = "RAlt",
  MouseButton2 = "RMB", MouseButton3 = "MMB", Return = "Enter", Backspace = "Bksp", CapsLock = "Caps", Escape = "Esc", Delete = "Del",
  Insert = "Ins", PageUp = "PgUp", PageDown = "PgDn", Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/", BackSlash = "\\",
  LeftBracket = "[", RightBracket = "]", Minus = "-", Equals = "=", Backquote = "`", Space = "Space", Unknown = "None",
  One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "0" }
function Config.keyLabel(key)
  if not key then return "None" end
  return SHORT[key] or (string.gsub(key, "^Keypad", "Num"))
end
Config.capturing = false   -- true while a keybind control is listening for a key
-- A switch can have a quick panel: its key tapped flips it as always, its key HELD (0.3 s) opens the
-- panel instead and letting go closes it (the ragebot's: who to hunt). { open = fn, close = fn }
Config.holdPanels = {}
local held = {}
local HOLD = 0.3

function Config.listen()
  reindex()
  B.connect(UIS.InputBegan, function(input, processed)
    if Config.capturing then return end
    local key = keyName(input)
    if not key then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
      if UIS:GetFocusedTextBox() then return end
    elseif processed then
      return
    end
    local list = byKey[key]
    if not list then return end
    for _, id in ipairs(list) do
      local bind = binds[id]
      local panel = Config.holdPanels[id]
      if actions[id] then
        B.try("bind." .. id, actions[id])
        Config.ranAt[id] = os.clock()
        Config.actionRan:fire(id)
      elseif type(values[id]) == "boolean" and panel and bind.mode ~= "hold" then
        -- (decided when it is let go: a tap flips it, a hold opened the panel)
        local mine = { at = os.clock(), key = key }
        held[id] = mine
        task.delay(HOLD, function()
          if held[id] == mine and Config.keyDown(key) then
            mine.opened = true
            B.try("hold." .. id, panel.open, key)
          end
        end)
      elseif type(values[id]) == "boolean" then
        if bind.mode == "hold" then Config.set(id, true) else Config.set(id, not values[id]) end
      end
    end
  end, "keybinds")
  B.connect(UIS.InputEnded, function(input)
    local key = keyName(input)
    local list = key and byKey[key]
    if not list then return end
    for _, id in ipairs(list) do
      local bind = binds[id]
      local press = held[id]
      if press and press.key == key then
        held[id] = nil
        if press.opened then
          local panel = Config.holdPanels[id]
          if panel and panel.close then B.try("hold.close." .. id, panel.close) end
        elseif type(values[id]) == "boolean" then
          Config.set(id, not values[id])
        end
      elseif bind.mode == "hold" and type(values[id]) == "boolean" and not actions[id] then
        Config.set(id, false)
      end
    end
  end, "keybinds")
end
-- true while the key bound to `id` (or `key`) is physically down
function Config.keyDown(key)
  if not key then return false end
  if key == "MouseButton2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
  if key == "MouseButton3" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton3) end
  local ok, code = pcall(function() return Enum.KeyCode[key] end)
  return ok and code ~= nil and UIS:IsKeyDown(code)
end
end

do -- 06_controls.lua
-- ============================================================================
--  06 controls  rows and the things on their right-hand side
--
--  A control is a row inside a card: label (and description) on the left, the
--  control on the right. Every control is backed by a Config flag, so it saves,
--  reloads with a profile, can be reset from its context menu and, for toggles
--  and buttons, bound to a key.
-- ============================================================================
local S, util, Motion, Theme, T, UI, Config = B.S, B.util, B.Motion, B.Theme, B.T, B.UI, B.Config
local UIS = S.UserInputService
local Controls = { bindables = {} }   -- bindables: flag id -> { label, kind, page }, everything a key can be given
B.Controls = Controls

-- ---------------------------------------------------------------- key capture
function Controls.captureKey(done)
  if Config.capturing then return end
  Config.capturing = true
  local connection
  connection = UIS.InputBegan:Connect(function(input)
    local key = Config.keyName(input)
    if not key then return end
    connection:Disconnect()
    -- the press that sets a key must not also fire the bind it just made
    task.delay(0.15, function() Config.capturing = false end)
    if key == "Escape" then B.try("capture", done, nil, true)
    elseif key == "Backspace" or key == "Delete" then B.try("capture", done, nil, false)
    else B.try("capture", done, key, false) end
  end)
  B.own(connection)
end

-- ---------------------------------------------------------------- row
-- section: { body = Frame, count = number, index = function(entry) }
local function makeRow(section, spec, controlWidth)
  section.count = (section.count or 0) + 1
  local row = UI.frame(section.body, { Name = spec.label or "Row", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = section.count })
  if section.count > 1 then
    UI.frame(row, { Name = "Rule", Size = UDim2.new(1, -28, 0, 1), Position = UDim2.fromOffset(14, 0),
      Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
  end
  local wash = UI.frame(row, { Name = "Wash", Size = UDim2.new(1, -8, 1, -6), Position = UDim2.fromOffset(4, 3), Theme = { BackgroundColor3 = "ink" },
    BackgroundTransparency = 1, ZIndex = 0 })
  UI.corner(wash, "rSmall")
  local left = UI.frame(row, { Name = "Left", Size = UDim2.new(1, -((controlWidth or 150) + 30), 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    Position = UDim2.fromOffset(0, 0) })
  UI.pad(left, 12, 0, 12, spec.icon and 42 or 14)
  UI.list(left, "y", 2)
  if spec.icon then
    UI.icon(row, spec.icon, 17, "sub", { Position = UDim2.fromOffset(14, 13), Name = "Icon" })
  end
  local titleLine = UI.frame(left, { Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1 })
  UI.list(titleLine, "x", 7, { v = "Center" })
  local label = UI.text(titleLine, spec.label or "", "label", "ink", { TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = 1,
    AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 20) })
  if spec.badge then UI.badge(titleLine, spec.badge, spec.badgeColor, { LayoutOrder = 2 }) end
  if spec.desc and spec.desc ~= "" then
    UI.text(left, spec.desc, "caption", "sub", { TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0),
      LayoutOrder = 2, LineHeight = 1.15 })
  end
  local slot = UI.frame(row, { Name = "Slot", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 0), Size = UDim2.fromOffset(0, 44),
    AutomaticSize = Enum.AutomaticSize.X, ZIndex = 6 })
  UI.list(slot, "x", 8, { h = "Right", v = "Center" })
  local api = { frame = row, left = left, slot = slot, label = label, wash = wash }
  -- (what it does, on hover: the tip of a control with no line of its own under its name)
  if spec.tip and spec.tip ~= "" then UI.tooltip(row, spec.tip, spec.label) end
  function api.hover(on) Motion.to(wash, "BackgroundTransparency", on and 0.965 or 1, "quick") end
  function api.flash()
    wash.BackgroundTransparency = 0.86
    Theme.unbind(wash, "BackgroundColor3")
    wash.BackgroundColor3 = T.accent
    Motion.to(wash, "BackgroundTransparency", 1, "lazy", function() Theme.bind(wash, "BackgroundColor3", "ink") end)
  end
  if section.index then
    section.index({ label = spec.label or "", desc = spec.desc or "", row = api, id = spec.id })
  end
  return api
end
Controls.row = makeRow

-- the small chip showing which key a flag is bound to
local function bindChip(slot, id, order)
  local chip = UI.frame(slot, { Name = "Bind", Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order or 1,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" }, Visible = false })
  UI.corner(chip, 6)
  UI.pad(chip, 0, 6)
  local text = UI.text(chip, "", "mono", "sub", { TextSize = 11, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  local function refresh()
    local bind = Config.bindOf(id)
    chip.Visible = bind ~= nil and bind.key ~= nil
    if bind and bind.key then text.Text = Config.keyLabel(bind.key) .. (bind.mode == "hold" and " ·hold" or "") end
  end
  Config.bindsChanged:connect(function(changed) if changed == id and chip.Parent then refresh() end end)
  refresh()
  return chip
end

local function contextMenu(anchor, spec, extra)
  local items = {}
  local id = spec.id
  if id then
    items[#items + 1] = { label = "Reset to default", icon = "rotate-ccw", run = function() Config.reset(id) end }
  end
  if spec.bindable and id then
    local bind = Config.bindOf(id)
    items[#items + 1] = { label = bind and "Change key…" or "Bind to a key…", icon = "keyboard", run = function()
      B.Window.toast({ title = "Press a key", text = "Esc cancels · Backspace clears", icon = "keyboard", time = 2.2 })
      Controls.captureKey(function(key, cancelled)
        if cancelled then return end
        Config.bind(id, key)
        B.Window.toast({ title = key and ("Bound to " .. Config.keyLabel(key)) or "Key cleared", text = spec.label, icon = "keyboard" })
      end)
    end }
    if bind then
      if spec.kind == "toggle" then
        items[#items + 1] = { label = "Hold to activate", icon = "hand", checked = bind.mode == "hold", run = function()
          Config.bind(id, bind.key, bind.mode == "hold" and "toggle" or "hold")
        end }
      end
      items[#items + 1] = { label = "Clear key", icon = "x", run = function() Config.bind(id, nil) end }
    end
  end
  if extra then
    for _, item in ipairs(extra) do items[#items + 1] = item end
  end
  if #items > 0 then UI.menu(anchor, items, { align = "right" }) end
end

-- ---------------------------------------------------------------- toggle
function Controls.toggle(section, spec)
  spec.kind = "toggle"
  spec.bindable = spec.bindable ~= false
  local id = spec.id
  local value = id and Config.define(id, spec.default == true) or (spec.default == true)
  local row = makeRow(section, spec, spec.children and 92 or 62)
  if id and spec.bindable then
    bindChip(row.slot, id, 1)
    Controls.bindables[id] = { label = spec.label or id, kind = "toggle", page = section.page }
  end

  local track = UI.frame(row.slot, { Name = "Switch", Size = UDim2.fromOffset(42, 24), LayoutOrder = 3, BackgroundTransparency = 0 })
  UI.corner(track, true)
  local knob = UI.frame(track, { Name = "Knob", Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0, 3, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0 })
  UI.corner(knob, true)
  if UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, 5); shadow.Offset = UDim2.fromOffset(0, 1); shadow.Transparency = 0.7
    shadow.Parent = knob
  end
  local pressed = false
  local function paint(instant)
    local on = value
    local color = on and T.accent or T.ink
    local alpha = on and 0 or T.fill3A - 0.05
    local width = pressed and 23 or 18
    local x = on and (42 - 3 - width) or 3
    if instant then
      track.BackgroundColor3, track.BackgroundTransparency = color, alpha
      Motion.snap(knob, "Position", UDim2.new(0, x, 0.5, 0)); Motion.snap(knob, "Size", UDim2.fromOffset(width, 18))
    else
      Motion.to(track, "BackgroundColor3", color, "quick")
      Motion.to(track, "BackgroundTransparency", alpha, "quick")
      Motion.to(knob, "Position", UDim2.new(0, x, 0.5, 0), pressed and "quick" or "bouncy")
      Motion.to(knob, "Size", UDim2.fromOffset(width, 18), "snappy")
    end
  end
  paint(true)
  Theme.changed:connect(function() if track.Parent then paint(true) end end)

  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    next = next == true
    if next == value then return end
    if id then Config.set(id, next, quiet) else
      value = next
      paint()
      if spec.changed then B.try("toggle", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next == true
      if track.Parent then paint() end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed and value then task.defer(B.safe("toggle.init", function() spec.changed(value) end)) end
  end

  -- nested options that only matter when the toggle is on
  local sub
  if spec.children then
    local chevron = UI.frame(row.slot, { Name = "More", Size = UDim2.fromOffset(22, 22), LayoutOrder = 2 })
    local icon = UI.icon(chevron, "chevron-down", 15, "faint", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    local holder = UI.frame(section.body, { Name = "Sub", Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true, LayoutOrder = section.count })
    section.count += 1
    holder.LayoutOrder = section.count
    local inner = UI.frame(holder, { Name = "Inner", Size = UDim2.new(1, -18, 0, 0), Position = UDim2.fromOffset(18, 0), AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(inner, "y", 0)
    UI.frame(holder, { Name = "Guide", Size = UDim2.new(0, 1, 1, -12), Position = UDim2.fromOffset(22, 2),
      Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
    sub = { body = inner, count = 0, index = section.index, page = section.page, nested = true }
    local open = false
    local built = false
    local function size(instant)
      local h = open and (inner.AbsoluteSize.Y / UI.unit()) or 0
      if instant then Motion.snap(holder, "Size", UDim2.new(1, 0, 0, h)) else Motion.to(holder, "Size", UDim2.new(1, 0, 0, h), "smooth") end
      Motion.to(icon, "Rotation", open and 180 or 0, "snappy")
    end
    local function setOpen(next)
      open = next
      if open and not built then
        built = true
        B.try("toggle.children", spec.children, B.Window.sectionApi(sub))
      end
      size()
    end
    inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if open then size(true) end end)
    UI.button(chevron, {
      hover = function(on) Theme.bind(icon, "ImageColor3", on and "ink" or "faint") end,
      click = function() UI.sfx("click", 0.5); setOpen(not open) end,
    })
    api.open = setOpen
  end

  UI.button(row.frame, {
    hover = row.hover,
    press = function(on) pressed = on; paint() end,
    click = function()
      UI.sfx(value and "toggle_off" or "toggle_on", 0.7)
      api.set(not value)
    end,
    alt = function() contextMenu(track, spec) end,
  })
  return api
end

-- ---------------------------------------------------------------- slider
function Controls.slider(section, spec)
  local id = spec.id
  local min, max, step = spec.min or 0, spec.max or 100, spec.step or 1
  local decimals = spec.decimals or (step < 1 and math.max(0, math.ceil(-math.log10(step))) or 0)
  -- curve: 1 is a straight track. Above 1 the low end of the range gets most of it
  -- (value = min + t ^ curve * span), for a range too wide to set by hand otherwise.
  local curve = spec.curve or 1
  local wide = spec.valueWidth or 64
  local value = id and Config.define(id, spec.default or min) or (spec.default or min)
  local row = makeRow(section, spec, wide + 12)
  row.frame.Name = "Slider"
  local suffix = spec.suffix or ""
  local function text(v) return (spec.format and spec.format(v)) or (util.format(v, decimals) .. suffix) end

  local field = UI.new("TextBox", { Name = "Value", Size = UDim2.fromOffset(wide, 24), BackgroundTransparency = 1, Text = text(value), FontFace = B.F.mono400,
    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ClearTextOnFocus = true, LayoutOrder = 2, Theme = { TextColor3 = "sub" },
    PlaceholderText = "", Parent = row.slot })

  -- the track sits under the label, the full width of the row
  local bar = UI.frame(row.left, { Name = "Bar", Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 5 })
  row.left.Size = UDim2.new(1, 0, 0, 0)
  UI.pad(bar, 0, 14, 0, 0)
  local track = UI.frame(bar, { Name = "Track", Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill3A" } })
  UI.corner(track, true)
  local fill = UI.frame(track, { Name = "Fill", Size = UDim2.fromScale(0, 1), Theme = { BackgroundColor3 = "accent" }, BackgroundTransparency = 0 })
  UI.corner(fill, true)
  local knob = UI.frame(track, { Name = "Knob", Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
    BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, ZIndex = 3 })
  UI.corner(knob, true)
  if UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, 6); shadow.Offset = UDim2.fromOffset(0, 1); shadow.Transparency = 0.62
    shadow.Parent = knob
  end

  local dragging = false
  local function place(instant)
    local alpha = util.clamp01((value - min) / (max - min)) ^ (1 / curve)
    if instant then
      Motion.snap(fill, "Size", UDim2.fromScale(alpha, 1)); Motion.snap(knob, "Position", UDim2.fromScale(alpha, 0.5))
    else
      Motion.to(fill, "Size", UDim2.fromScale(alpha, 1), "quick"); Motion.to(knob, "Position", UDim2.fromScale(alpha, 0.5), "quick")
    end
    if not field:IsFocused() then field.Text = text(value) end
  end
  place(true)

  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    next = math.clamp(util.round(next, step), min, max)
    if decimals > 0 then next = tonumber(string.format("%." .. decimals .. "f", next)) or next end
    if next == value then return end
    if id then Config.set(id, next, quiet) else
      value = next; place()
      if spec.changed then B.try("slider", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if track.Parent then place(dragging) end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed then task.defer(B.safe("slider.init", function() spec.changed(value) end)) end
  end

  local hit = UI.new("TextButton", { Name = "Hit", Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1, 14, 1, 0),
    Position = UDim2.fromOffset(-7, 0), ZIndex = 6, Parent = bar })
  local function at(point)
    local x = track.AbsolutePosition.X
    local w = math.max(1, track.AbsoluteSize.X)
    api.set(min + util.clamp01((point.X - x) / w) ^ curve * (max - min))
  end
  UI.drag(hit, function(point)
    dragging = true
    Motion.to(knob, "Size", UDim2.fromOffset(20, 16), "snappy")
    at(point)
  end, function(point) at(point) end, function()
    dragging = false
    Motion.to(knob, "Size", UDim2.fromOffset(14, 14), "bouncy")
    UI.sfx("click", 0.35)
  end)
  hit.MouseEnter:Connect(function() if not dragging then Motion.to(knob, "Size", UDim2.fromOffset(16, 16), "quick") end; row.hover(true) end)
  hit.MouseLeave:Connect(function() if not dragging then Motion.to(knob, "Size", UDim2.fromOffset(14, 14), "quick") end; row.hover(false) end)
  hit.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then contextMenu(knob, spec) end
  end)
  field.FocusLost:Connect(B.safe("slider.field", function()
    local typed = tonumber((string.gsub(field.Text, "[^%d%.%-]", "")))
    if typed then api.set(typed) end
    field.Text = text(value)
    Theme.bind(field, "TextColor3", "sub")
  end))
  field.Focused:Connect(function() Theme.bind(field, "TextColor3", "ink") end)
  return api
end

-- ---------------------------------------------------------------- dropdown / multi-select
local function optionList(options)
  local out = {}
  for _, option in ipairs(options) do
    if type(option) == "table" then out[#out + 1] = { value = option.value or option[1], label = option.label or option[2] or tostring(option.value or option[1]), icon = option.icon }
    else out[#out + 1] = { value = option, label = tostring(option) } end
  end
  return out
end
local function pill(slot, order)
  local button = UI.pressable(slot, { Name = "Select", Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = order or 3,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(button, "rSmall")
  UI.pad(button, 0, 9, 0, 11)
  UI.list(button, "x", 6, { v = "Center" })
  local label = UI.text(button, "", "label", "ink", { TextSize = 13, LayoutOrder = 1, TextTruncate = Enum.TextTruncate.AtEnd })
  local limit = Instance.new("UISizeConstraint"); limit.MaxSize = Vector2.new(132, 28); limit.Parent = label
  local chevron = UI.icon(button, "chevrons-up-down", 13, "faint", { LayoutOrder = 2 })
  return button, label, chevron
end

function Controls.dropdown(section, spec)
  local id = spec.id
  local options = optionList(spec.options)
  local value = id and Config.define(id, spec.default ~= nil and spec.default or options[1].value) or (spec.default ~= nil and spec.default or options[1].value)
  local row = makeRow(section, spec, 150)
  local button, label = pill(row.slot)
  local function labelOf(v)
    for _, option in ipairs(options) do if option.value == v then return option.label end end
    return tostring(v)
  end
  label.Text = labelOf(value)
  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    if next == value then return end
    if id then Config.set(id, next, quiet) else
      value = next; label.Text = labelOf(value)
      if spec.changed then B.try("dropdown", spec.changed, value) end
    end
  end
  function api.options(list)
    options = optionList(list)
    label.Text = labelOf(value)
  end
  if id then
    Config.on(id, function(next)
      value = next
      if label.Parent then label.Text = labelOf(value) end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed then task.defer(B.safe("dropdown.init", function() spec.changed(value) end)) end
  end
  local function open()
    local items = {}
    for _, option in ipairs(options) do
      items[#items + 1] = { label = option.label, icon = option.icon, checked = option.value == value, run = function() api.set(option.value) end }
    end
    UI.menu(button, items, { align = "right", width = spec.menuWidth })
  end
  UI.wire(button, {
    hover = function(on) Motion.to(button, "BackgroundTransparency", on and T.fill3A or T.fill2A, "quick"); row.hover(on) end,
    click = function() UI.sfx("click", 0.6); open() end,
    alt = function() contextMenu(button, spec) end,
  })
  return api
end

-- value is a set stored as an array of the selected option values
function Controls.multi(section, spec)
  local id = spec.id
  local options = optionList(spec.options)
  local value = id and Config.define(id, spec.default or {}) or (spec.default or {})
  local row = makeRow(section, spec, 150)
  local button, label = pill(row.slot)
  local function has(v) return table.find(value, v) ~= nil end
  local function summary()
    if #value == 0 then return spec.empty or "None" end
    if #value == #options then return "All" end
    if #value <= 2 then
      local names = {}
      for _, option in ipairs(options) do if has(option.value) then names[#names + 1] = option.label end end
      return table.concat(names, ", ")
    end
    return #value .. " selected"
  end
  label.Text = summary()
  local api = { row = row, id = id }
  function api.get() return value end
  function api.has(v) return has(v) end
  function api.set(next, quiet)
    if id then Config.set(id, next, quiet) else
      value = next; label.Text = summary()
      if spec.changed then B.try("multi", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if label.Parent then label.Text = summary() end
      if spec.changed then spec.changed(value) end
    end)
    if spec.changed then task.defer(B.safe("multi.init", function() spec.changed(value) end)) end
  end
  local function flip(v)
    local next = table.clone(value)
    local at = table.find(next, v)
    if at then table.remove(next, at) else next[#next + 1] = v end
    -- keep option order, so two identical selections compare equal
    local ordered = {}
    for _, option in ipairs(options) do if table.find(next, option.value) then ordered[#ordered + 1] = option.value end end
    api.set(ordered)
  end
  local function open()
    UI.popover(button, { width = spec.menuWidth or 212, align = "right" }, function(content)
      local checks = {}
      local function refresh()
        for v, icon in pairs(checks) do icon.ImageTransparency = has(v) and 0 or 1 end
      end
      for index, option in ipairs(options) do
        local item = UI.frame(content, { Size = UDim2.new(1, 0, 0, 32), LayoutOrder = index, Theme = { BackgroundColor3 = "ink" } })
        UI.corner(item, "rSmall")
        local x = 10
        if option.icon then
          UI.icon(item, option.icon, 16, "sub", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
          x = 34
        end
        UI.text(item, option.label, "label", "ink", { Position = UDim2.new(0, x, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13 })
        local box = UI.frame(item, { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5),
          Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill3A" } })
        UI.corner(box, 5)
        checks[option.value] = UI.icon(box, "check", 13, "accent", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
        UI.button(item, {
          hover = function(on) Motion.to(item, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
          click = function() UI.sfx("click", 0.6); flip(option.value); refresh() end,
        })
      end
      UI.divider(content, #options + 1)
      local footer = UI.frame(content, { Size = UDim2.new(1, 0, 0, 30), LayoutOrder = #options + 2 })
      for index, action in ipairs({ { "All", function() local all = {}; for _, o in ipairs(options) do all[#all + 1] = o.value end; api.set(all) end },
        { "None", function() api.set({}) end } }) do
        local link = UI.new("TextButton", { Text = action[1], FontFace = B.F.text500, TextSize = 12, BackgroundTransparency = 1, AutoButtonColor = false,
          AutomaticSize = Enum.AutomaticSize.XY, Position = UDim2.new(index == 1 and 0 or 1, index == 1 and 10 or -10, 0.5, 0),
          AnchorPoint = Vector2.new(index == 1 and 0 or 1, 0.5), Theme = { TextColor3 = "sub" }, Parent = footer })
        UI.wire(link, { click = function() UI.sfx("click", 0.5); action[2](); refresh() end,
          hover = function(on) Theme.bind(link, "TextColor3", on and "ink" or "sub") end })
      end
      refresh()
    end)
  end
  UI.wire(button, {
    hover = function(on) Motion.to(button, "BackgroundTransparency", on and T.fill3A or T.fill2A, "quick"); row.hover(on) end,
    click = function() UI.sfx("click", 0.6); open() end,
    alt = function() contextMenu(button, spec) end,
  })
  return api
end

-- ---------------------------------------------------------------- segmented
-- A row of mutually exclusive choices with a pill that slides like liquid:
-- its leading edge arrives first, the trailing edge catches up.
function Controls.segmentedBar(parent, options, initial, onPick, props)
  options = optionList(options)
  local bar = UI.frame(parent, { Name = "Segmented", Size = UDim2.new(1, 0, 0, 30), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(bar, "rSmall")
  if props then
    for key, value in pairs(props) do bar[key] = value end
  end
  local count = #options
  local thumb = UI.frame(bar, { Name = "Thumb", Size = UDim2.new(1 / count, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill3A" } })
  UI.corner(thumb, "rSmall")
  local labels = {}
  local current
  -- left and right edges are separate springs (scale units)
  local edges = Motion.spring(2, "snappy", function(x)
    local a, b = math.min(x[1], x[2]), math.max(x[1], x[2])
    thumb.Position = UDim2.new(a, 2, 0, 2)
    thumb.Size = UDim2.new(b - a, -4, 1, -4)
  end, 0.0004)
  local function select(index, instant)
    local previous = current
    current = index
    for i, label in ipairs(labels) do Theme.bind(label, "TextColor3", i == index and "ink" or "sub") end
    local a, b = (index - 1) / count, index / count
    if instant or not previous then edges:snap({ a, b }); return end
    -- the edge in the direction of travel leads
    if index > previous then
      edges.g[2] = b; edges:to({ edges.g[1], b }, "snappy")
      task.delay(0.045, function() edges:to({ a, b }, "liquid") end)
    else
      edges.g[1] = a; edges:to({ a, edges.g[2] }, "snappy")
      task.delay(0.045, function() edges:to({ a, b }, "liquid") end)
    end
  end
  for index, option in ipairs(options) do
    local cell = UI.frame(bar, { Size = UDim2.new(1 / count, 0, 1, 0), Position = UDim2.fromScale((index - 1) / count, 0), ZIndex = 2 })
    labels[index] = UI.text(cell, option.label, "label", "sub", { TextSize = 12.5, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    UI.button(cell, { click = function()
      if current == index then return end
      UI.sfx("tab", 0.6)
      select(index)
      onPick(option.value, index)
    end })
  end
  local startIndex = 1
  for index, option in ipairs(options) do if option.value == initial then startIndex = index end end
  select(startIndex, true)
  return bar, function(v)
    for index, option in ipairs(options) do if option.value == v then select(index) end end
  end
end

function Controls.segmented(section, spec)
  local id = spec.id
  local options = optionList(spec.options)
  local value = id and Config.define(id, spec.default ~= nil and spec.default or options[1].value) or (spec.default ~= nil and spec.default or options[1].value)
  local width = spec.width or math.min(64 * #options, 220)
  local row = makeRow(section, spec, width)
  local holder = UI.frame(row.slot, { Size = UDim2.fromOffset(width, 30), LayoutOrder = 3 })
  local api = { row = row, id = id }
  local _, show = Controls.segmentedBar(holder, options, value, function(v)
    if id then Config.set(id, v) else
      value = v
      if spec.changed then B.try("segmented", spec.changed, v) end
    end
  end)
  function api.get() return value end
  function api.set(v) if id then Config.set(id, v) else value = v; show(v) end end
  if id then
    Config.on(id, function(next)
      value = next
      if holder.Parent then show(next) end
      if spec.changed then spec.changed(next) end
    end)
    if spec.changed then task.defer(B.safe("segmented.init", function() spec.changed(value) end)) end
  end
  return api
end

-- ---------------------------------------------------------------- button
function Controls.pillButton(parent, text, style, run, props)
  local primary, danger = style == "primary", style == "danger"
  local button = UI.pressable(parent, { Name = "Button", Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X })
  local function rest() return primary and 0 or (danger and 0.84 or T.fill2A) end
  Theme.bind(button, "BackgroundColor3", primary and "accent" or (danger and "bad" or "ink"))
  button.BackgroundTransparency = rest()
  if not primary and not danger then Theme.bind(button, "BackgroundTransparency", "fill2A") end
  UI.corner(button, "rSmall")
  UI.pad(button, 0, 13)
  local label = UI.text(button, text, "button", primary and "accentInk" or (danger and "bad" or "ink"),
    { Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  local scale = UI.scaleOf(button)
  if props then
    for key, value in pairs(props) do button[key] = value end
  end
  UI.wire(button, {
    hover = function(on)
      local base = rest()
      Motion.to(button, "BackgroundTransparency", on and (primary and 0.14 or math.max(0, base - 0.06)) or base, "quick")
    end,
    press = function(on) Motion.to(scale, "Scale", on and 0.95 or 1, on and "quick" or "bouncy") end,
    click = function() UI.sfx("click", 0.8); if run then run() end end,
  })
  return button, label
end

function Controls.button(section, spec)
  local row = makeRow(section, spec, 110)
  local id = spec.id
  if id then
    Config.action(id, function() if spec.run then spec.run() end end)
    spec.bindable = spec.bindable ~= false
    if spec.bindable then
      bindChip(row.slot, id, 1)
      Controls.bindables[id] = { label = spec.label or id, kind = "button", page = section.page }
    end
  end
  local button, label = Controls.pillButton(row.slot, spec.text or "Run", spec.style, function()
    if spec.run then B.try("button." .. (spec.label or "?"), spec.run) end
  end, { LayoutOrder = 3 })
  button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and id then contextMenu(button, { id = id, bindable = spec.bindable, label = spec.label, kind = "button" }) end
  end)
  return { row = row, button = button, setText = function(text) label.Text = text end }
end

-- ---------------------------------------------------------------- keybind
function Controls.keybind(section, spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "None") or (spec.default or "None")
  local row = makeRow(section, spec, 100)
  local chip = UI.pressable(row.slot, { Name = "Key", Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 3,
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(chip, "rSmall")
  UI.pad(chip, 0, 11)
  local floor = Instance.new("UISizeConstraint"); floor.MinSize = Vector2.new(46, 28); floor.Parent = chip
  local label = UI.text(chip, Config.keyLabel(value ~= "None" and value or nil), "monoBold", "ink", { Size = UDim2.fromScale(1, 1),
    AutomaticSize = Enum.AutomaticSize.X, TextXAlignment = Enum.TextXAlignment.Center })
  local stroke = UI.stroke(chip, "accent", 1, 1)
  local api = { row = row, id = id }
  function api.get() return value end
  local function show() label.Text = Config.keyLabel(value ~= "None" and value or nil) end
  if id then
    Config.on(id, function(next)
      value = next
      if label.Parent then show() end
      if spec.changed then spec.changed(next) end
    end)
    if spec.changed then task.defer(B.safe("keybind.init", function() spec.changed(value) end)) end
  end
  UI.wire(chip, {
    hover = function(on) Motion.to(chip, "BackgroundTransparency", on and T.fill3A or T.fill2A, "quick"); row.hover(on) end,
    click = function()
      UI.sfx("click", 0.6)
      label.Text = "…"
      Motion.to(stroke, "Transparency", 0, "quick")
      Controls.captureKey(function(key, cancelled)
        Motion.to(stroke, "Transparency", 1, "smooth")
        if not cancelled then
          local next = key or "None"
          if id then Config.set(id, next) else value = next; if spec.changed then spec.changed(next) end end
        end
        show()
      end)
    end,
    alt = function() contextMenu(chip, spec) end,
  })
  return api
end

-- ---------------------------------------------------------------- text input
function Controls.field(parent, props, onSubmit)
  local field = UI.frame(parent, { Name = "Field", Size = UDim2.fromOffset(150, 28), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(field, "rSmall")
  local stroke = UI.stroke(field, "accent", 1, 1)
  local box = UI.new("TextBox", { Name = "Box", BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(10, 0), Text = "",
    FontFace = B.F.text400, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ClipsDescendants = true,
    Theme = { TextColor3 = "ink", PlaceholderColor3 = "faint" }, Parent = field })
  if props then
    for key, value in pairs(props) do
      if key == "Width" then field.Size = UDim2.fromOffset(value, 28) else box[key] = value end
    end
  end
  box.Focused:Connect(function() Motion.to(stroke, "Transparency", 0.25, "quick") end)
  box.FocusLost:Connect(B.safe("field", function(enter)
    Motion.to(stroke, "Transparency", 1, "smooth")
    if onSubmit then onSubmit(box.Text, enter) end
  end))
  return field, box
end

function Controls.input(section, spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "") or (spec.default or "")
  local row = makeRow(section, spec, spec.width or 150)
  local api = { row = row, id = id }
  local _, box = Controls.field(row.slot, { Width = spec.width or 150, PlaceholderText = spec.placeholder or "", Text = tostring(value) }, function(text)
    if spec.numeric then
      local n = tonumber(text)
      if not n then api.box.Text = tostring(value); return end
      text = n
    end
    if id then Config.set(id, text) else
      value = text
      if spec.changed then B.try("input", spec.changed, text) end
    end
  end)
  api.box = box
  function api.get() return value end
  if id then
    Config.on(id, function(next)
      value = next
      if box.Parent and not box:IsFocused() then box.Text = tostring(next) end
      if spec.changed then spec.changed(next) end
    end)
  end
  return api
end

-- ---------------------------------------------------------------- colour
local function hueColor(h) return Color3.fromHSV(h, 1, 1) end
function Controls.colorPopover(anchor, initial, onChange)
  local h, s, v = initial:ToHSV()
  return UI.popover(anchor, { width = 224, align = "right", pad = 10, gap = 10 }, function(content)
    local square = UI.frame(content, { Name = "SV", Size = UDim2.new(1, 0, 0, 132), BackgroundTransparency = 0, BackgroundColor3 = hueColor(h), LayoutOrder = 1 })
    UI.corner(square, 9)
    local white = UI.frame(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0 })
    UI.corner(white, 9)
    UI.gradient(white, { Transparency = UI.alphaSeq(0, 0, 1, 1) })
    local black = UI.frame(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0, ZIndex = 2 })
    UI.corner(black, 9)
    UI.gradient(black, { Rotation = 90, Transparency = UI.alphaSeq(0, 1, 1, 0) })
    local dot = UI.frame(square, { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 4, BackgroundTransparency = 1 })
    UI.corner(dot, true)
    local ring = Instance.new("UIStroke"); ring.Color = Color3.new(1, 1, 1); ring.Thickness = 2; ring.Parent = dot

    local hueBar = UI.frame(content, { Name = "Hue", Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, LayoutOrder = 2 })
    UI.corner(hueBar, true)
    local stops = {}
    for i = 0, 6 do stops[#stops + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1)) end
    UI.gradient(hueBar, { Color = ColorSequence.new(stops) })
    local hueKnob = UI.frame(hueBar, { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 0, ZIndex = 3 })
    UI.corner(hueKnob, true)
    local hueRing = Instance.new("UIStroke"); hueRing.Color = Color3.new(0, 0, 0); hueRing.Transparency = 0.7; hueRing.Parent = hueKnob

    local bottom = UI.frame(content, { Size = UDim2.new(1, 0, 0, 28), LayoutOrder = 3 })
    local preview = UI.frame(bottom, { Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 0, BackgroundColor3 = initial })
    UI.corner(preview, 8)
    local hexField, hexBox
    local function emit(fromHex)
      local color = Color3.fromHSV(h, s, v)
      square.BackgroundColor3 = hueColor(h)
      dot.Position = UDim2.fromScale(s, 1 - v)
      hueKnob.Position = UDim2.fromScale(h, 0.5)
      preview.BackgroundColor3 = color
      if hexBox and not fromHex and not hexBox:IsFocused() then hexBox.Text = "#" .. util.toHex(color) end
      onChange(color)
    end
    hexField, hexBox = Controls.field(bottom, { Width = 96, Text = "#" .. util.toHex(initial), FontFace = B.F.mono400, TextSize = 12 }, function(text)
      local clean = string.gsub(text, "[^%x]", "")
      if #clean == 6 then
        h, s, v = util.hex(clean):ToHSV()
        emit(true)
      end
      hexBox.Text = "#" .. util.toHex(Color3.fromHSV(h, s, v))
    end)
    hexField.Position = UDim2.fromOffset(36, 0)
    -- quick picks: the accent family
    local picks = UI.frame(content, { Size = UDim2.new(1, 0, 0, 18), LayoutOrder = 4 })
    UI.list(picks, "x", 7)
    for index, accent in ipairs(Theme.accents) do
      local swatch = UI.frame(picks, { Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 0, BackgroundColor3 = accent.color, LayoutOrder = index })
      UI.corner(swatch, true)
      UI.button(swatch, { click = function() h, s, v = accent.color:ToHSV(); emit() end })
    end
    local svHit = UI.new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 6, AutoButtonColor = false, Parent = square })
    local function sv(point)
      local p, size = square.AbsolutePosition, square.AbsoluteSize
      s = util.clamp01((point.X - p.X) / size.X)
      v = 1 - util.clamp01((point.Y - p.Y) / size.Y)
      emit()
    end
    UI.drag(svHit, sv, sv)
    local hueHit = UI.new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 12), Position = UDim2.fromOffset(0, -6), ZIndex = 6,
      AutoButtonColor = false, Parent = hueBar })
    local function hue(point)
      h = util.clamp01((point.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X)
      emit()
    end
    UI.drag(hueHit, hue, hue)
    dot.Position = UDim2.fromScale(s, 1 - v)
    hueKnob.Position = UDim2.fromScale(h, 0.5)
  end)
end

function Controls.color(section, spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or Color3.new(1, 1, 1)) or (spec.default or Color3.new(1, 1, 1))
  local row = makeRow(section, spec, 60)
  local swatch = UI.frame(row.slot, { Name = "Swatch", Size = UDim2.fromOffset(34, 22), BackgroundTransparency = 0, BackgroundColor3 = value, LayoutOrder = 3 })
  UI.corner(swatch, 7)
  UI.stroke(swatch, "ink", "stroke2A")
  local api = { row = row, id = id }
  function api.get() return value end
  function api.set(next, quiet)
    if id then Config.set(id, next, quiet) else
      value = next; swatch.BackgroundColor3 = next
      if spec.changed then B.try("color", spec.changed, next) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if swatch.Parent then swatch.BackgroundColor3 = next end
      if spec.changed then spec.changed(next) end
    end)
    if spec.changed then task.defer(B.safe("color.init", function() spec.changed(value) end)) end
  end
  local scale = UI.scaleOf(swatch)
  UI.button(swatch, {
    hover = function(on) Motion.to(scale, "Scale", on and 1.08 or 1, "snappy"); row.hover(on) end,
    click = function() UI.sfx("click", 0.6); Controls.colorPopover(swatch, value, function(color) api.set(color) end) end,
    alt = function() contextMenu(swatch, spec) end,
  })
  return api
end

-- ---------------------------------------------------------------- static rows
function Controls.note(section, spec)
  section.count = (section.count or 0) + 1
  local tone = spec.tone or "sub"
  local box = UI.frame(section.body, { Name = "Note", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = section.count })
  UI.pad(box, 10, 14, 12, 14)
  local inner = UI.frame(box, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(inner, "x", 9)
  if spec.icon then UI.icon(inner, spec.icon, 15, tone, { LayoutOrder = 1 }) end
  local text = UI.text(inner, spec.text or "", "caption", tone, { TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2,
    Size = UDim2.new(1, spec.icon and -24 or 0, 0, 0), LineHeight = 1.2, RichText = spec.rich == true })
  return { frame = box, set = function(value) text.Text = value end }
end
function Controls.custom(section, spec)
  section.count = (section.count or 0) + 1
  local frame = UI.frame(section.body, { Name = spec.name or "Custom", Size = UDim2.new(1, 0, 0, spec.height or 100), LayoutOrder = section.count })
  if spec.height == nil then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("custom", spec.build, frame)
  return frame
end
end

do -- 07_window.lua
-- ============================================================================
--  07 window   the shell: glass, sidebar, pages, cards, toasts, palette, blur
-- ============================================================================
local S, util, Motion, Theme, T, UI, Config, Controls = B.S, B.util, B.Motion, B.Theme, B.T, B.UI, B.Config, B.Controls
local UIS = S.UserInputService
local Window = { open = false, built = false, pages = {}, order = {}, index = {}, scale = 1, onShow = B.Signal.new(), onPage = B.Signal.new() }
B.Window = Window

local W, H = 980, 624
local SIDE = 206
local CONTENT_X = SIDE + 20
local CONTENT_W = W - CONTENT_X - 10
local HEADER = 84

-- ---------------------------------------------------------------- real blur
-- Measured: a Glass part a hair in front of the camera plus a DepthOfField with
-- nothing in its focus range blurs the 3D scene inside the part's rectangle only.
-- A rounded window is five rectangles: the body and two steps per end.
local Blur = { enabled = false, parts = {}, visible = false }
B.Blur = Blur
local DEPTH = 0.012
local function blurPart()
  local part = Instance.new("Part")
  part.Name = util.randomName()
  part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
  part.CastShadow = false
  part.Locked = true
  part.Material = Enum.Material.Glass
  part.Color = Color3.new(0, 0, 0)
  part.Transparency = 0.98
  part.Size = Vector3.new(1, 1, 0.001)
  local mesh = Instance.new("SpecialMesh")
  mesh.MeshType = Enum.MeshType.Brick
  mesh.Offset = Vector3.new(0, 0, -0.000001)
  mesh.Parent = part
  return part, mesh
end
function Blur.supported()
  local ok, level = pcall(function() return settings().Rendering.QualityLevel.Value end)
  -- level 0 is Automatic; the effect needs the post-processing tiers
  return ok and (level == 0 or level >= 8)
end
function Blur.start()
  if Blur.dof then return end
  local dof = Instance.new("DepthOfFieldEffect")
  dof.Name = util.randomName()
  dof.FarIntensity, dof.NearIntensity, dof.InFocusRadius, dof.FocusDistance = 0, 1, 0.1, 0.05
  dof.Enabled = false
  dof.Parent = S.Lighting
  Blur.dof = B.own(dof)
  for index = 1, 5 do
    local part, mesh = blurPart()
    Blur.parts[index] = { part = B.own(part), mesh = mesh }
  end
  -- runs after the camera has moved this frame, so the glass never trails it
  S.RunService:BindToRenderStep("BasedBlur", Enum.RenderPriority.Camera.Value + 2, function()
    if not Blur.visible or not B.alive then return end
    B.try("blur", Blur.update)
  end)
  B.own(function() pcall(function() S.RunService:UnbindFromRenderStep("BasedBlur") end) end)
end
local function placePart(camera, slot, x, y, w, h)
  if w < 1 or h < 1 then slot.part.Parent = nil; return end
  local a = camera:ViewportPointToRay(x, y)
  local b = camera:ViewportPointToRay(x + w, y + h)
  local c = camera:ViewportPointToRay(x + w, y)
  local p1, p2, p3 = a.Origin + a.Direction * DEPTH, b.Origin + b.Direction * DEPTH, c.Origin + c.Direction * DEPTH
  local cf = camera.CFrame
  -- A game that clears the camera's children takes the glass with them (Da Hood's own client calls
  -- ClearAllChildren on the camera), and a destroyed part cannot be parented again: make it anew.
  if slot.part.Parent ~= camera and not pcall(function() slot.part.Parent = camera end) then
    local part, mesh = blurPart()
    slot.part, slot.mesh = B.own(part), mesh
    part.Parent = camera
  end
  slot.part.CFrame = CFrame.fromMatrix((p1 + p2) / 2, cf.XVector, cf.YVector, cf.ZVector)
  slot.mesh.Scale = Vector3.new((p3 - p1).Magnitude, (p3 - p2).Magnitude, 0) / slot.part.Size
end
function Blur.update()
  local camera = workspace.CurrentCamera
  local holder = Window.holder
  if not camera or not holder then return end
  -- read the rectangle this frame: a dragged window must not outrun its blur
  local p, s = holder.AbsolutePosition, holder.AbsoluteSize
  local inset = S.GuiService:GetGuiInset()
  local x, y, w, h, r = p.X + inset.X, p.Y + inset.Y, s.X, s.Y, T.rWindow * Window.sizer.Scale
  local parts = Blur.parts
  placePart(camera, parts[1], x, y + r, w, h - 2 * r)
  placePart(camera, parts[2], x + 0.063 * r, y + 0.30 * r, w - 0.126 * r, 0.70 * r)
  placePart(camera, parts[3], x + 0.42 * r, y + 0.07 * r, w - 0.84 * r, 0.23 * r)
  placePart(camera, parts[4], x + 0.063 * r, y + h - r, w - 0.126 * r, 0.70 * r)
  placePart(camera, parts[5], x + 0.42 * r, y + h - 0.30 * r, w - 0.84 * r, 0.23 * r)
end
function Blur.show(on)
  Blur.visible = on and Blur.enabled
  if Blur.dof then Blur.dof.Enabled = Blur.visible end
  if not Blur.visible then
    for _, slot in ipairs(Blur.parts) do slot.part.Parent = nil end
  end
end
function Blur.set(on)
  on = on and Blur.supported()
  Blur.enabled = on
  if on then Blur.start() end
  Theme.set({ blur = on })
  Blur.show(Window.open)
end

-- ---------------------------------------------------------------- toasts
local toasts = {}
local function layoutToasts()
  local y = 0
  for _, toast in ipairs(toasts) do
    Motion.to(toast.holder, "Position", UDim2.new(1, -18, 0, 18 + y), "smooth")
    y += toast.height + 10
  end
end
-- opts: title, text, icon, tone ("accent" | "ok" | "warn" | "bad"), time
function Window.toast(opts)
  if Window.toastHook then
    local taken = Window.toastHook(opts)
    if taken then return taken end
  end
  if not Window.hud then return end
  local tone = opts.tone or "accent"
  local hasText = opts.text ~= nil and opts.text ~= ""
  local toast = { height = hasText and 62 or 46 }
  local holder = UI.frame(Window.hud, { Name = "Toast", AnchorPoint = Vector2.new(1, 0), Size = UDim2.fromOffset(318, toast.height),
    Position = UDim2.new(1, 360, 0, 18) })
  local sizer = Instance.new("UIScale"); sizer.Scale = Window.scale; sizer.Parent = holder
  local glass = UI.glass(holder, { level = "popover", radius = "rCard", shadow = 30, shadowY = 12, props = { Size = UDim2.fromScale(1, 1) } })
  local chip = UI.frame(glass, { Size = UDim2.fromOffset(30, 30), Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    Theme = { BackgroundColor3 = tone }, BackgroundTransparency = 0.84 })
  UI.corner(chip, 9)
  UI.icon(chip, opts.icon or "sparkles", 16, tone, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
  UI.text(glass, opts.title or "", "heading", "ink", { TextSize = 13.5, Position = UDim2.fromOffset(50, hasText and 12 or 14), Size = UDim2.new(1, -64, 0, 18),
    AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd })
  if hasText then
    UI.text(glass, opts.text, "caption", "sub", { Position = UDim2.fromOffset(50, 31), Size = UDim2.new(1, -64, 0, 18), AutomaticSize = Enum.AutomaticSize.None,
      TextTruncate = Enum.TextTruncate.AtEnd })
  end
  local timer = UI.frame(glass, { Size = UDim2.new(1, -28, 0, 2), Position = UDim2.new(0, 14, 1, -5), Theme = { BackgroundColor3 = tone }, BackgroundTransparency = 0.45 })
  UI.corner(timer, true)
  toast.holder = holder
  table.insert(toasts, 1, toast)
  while #toasts > 4 do
    local old = table.remove(toasts)
    old.holder:Destroy()
  end
  layoutToasts()
  local life = opts.time or 3.6
  Motion.tween(life, Motion.ease.linear, function(p) timer.Size = UDim2.new(1 - p, -28 * (1 - p), 0, 2) end)
  local function dismiss()
    if toast.gone then return end
    toast.gone = true
    local at = table.find(toasts, toast)
    if at then table.remove(toasts, at) end
    Motion.to(holder, "Position", UDim2.new(1, 380, 0, holder.Position.Y.Offset), "smooth", function() holder:Destroy() end)
    layoutToasts()
  end
  task.delay(life, function() if B.alive then dismiss() end end)
  UI.button(glass, { click = dismiss })
  UI.sfx(tone == "bad" and "close" or "saved", 0.6)
  return dismiss
end

-- ---------------------------------------------------------------- sections
local SectionApi = {}
SectionApi.__index = SectionApi
for _, kind in ipairs({ "toggle", "slider", "dropdown", "multi", "segmented", "color", "keybind", "button", "input", "note", "custom" }) do
  SectionApi[kind] = function(self, spec) return Controls[kind](self.raw, spec) end
end
function Window.sectionApi(raw) return setmetatable({ raw = raw, body = raw.body }, SectionApi) end

local Page = {}
Page.__index = Page
local function band(page, full)
  page.bandCount += 1
  local frame = UI.frame(page.content, { Name = full and "Full" or "Columns", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = page.bandCount })
  if full then
    UI.list(frame, "y", 12)
    return { full = true, frame = frame }
  end
  local columns = {}
  for i = 1, 2 do
    local column = UI.frame(frame, { Name = "Column" .. i, Size = UDim2.new(0.5, -6, 0, 0), Position = UDim2.new(i == 1 and 0 or 0.5, i == 1 and 0 or 6, 0, 0),
      AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(column, "y", 12)
    columns[i] = { frame = column, count = 0 }
  end
  return { full = false, frame = frame, columns = columns }
end
-- spec: title, desc, icon, full (span both columns), column (1 | 2)
function Page:section(spec)
  spec = spec or {}
  -- built in the background, a tab is assembled one card per frame (see Window.prebuild)
  if self.slicing then task.wait() end
  local current = self.band
  if spec.full then
    current = band(self, true)
    self.band = nil
  elseif not current or current.full then
    current = band(self, false)
    self.band = current
  end
  local host
  if current.full then host = current.frame else
    local column = spec.column and current.columns[spec.column]
      or (current.columns[1].count <= current.columns[2].count and current.columns[1] or current.columns[2])
    column.count += spec.weight or 1
    host = column.frame
  end
  self.sectionCount += 1
  local card = UI.surface(host, { Name = spec.title or "Card", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self.sectionCount })
  UI.stroke(card, "ink", "strokeA")
  local stack = UI.frame(card, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(stack, "y", 0)
  UI.pad(stack, 0, 0, 4, 0)
  if spec.title then
    local head = UI.frame(stack, { Name = "Head", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 0 })
    UI.pad(head, 14, 14, 8, 14)
    UI.list(head, "y", 3)
    local line = UI.frame(head, { Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 1 })
    UI.list(line, "x", 8, { v = "Center" })
    if spec.icon then UI.icon(line, spec.icon, 16, "accent", { LayoutOrder = 1 }) end
    UI.text(line, spec.title, "heading", "ink", { LayoutOrder = 2 })
    if spec.badge then UI.badge(line, spec.badge, spec.badgeColor, { LayoutOrder = 3 }) end
    if spec.desc then
      UI.text(head, spec.desc, "caption", "sub", { TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2, LineHeight = 1.15 })
    end
  end
  local body = UI.frame(stack, { Name = "Body", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1 })
  UI.list(body, "y", 0)
  local page = self
  local raw = { body = body, count = spec.title and 1 or 0, page = self, card = card }
  function raw.index(entry)
    entry.page, entry.section = page, spec.title or page.title
    Window.index[#Window.index + 1] = entry
  end
  local api = Window.sectionApi(raw)
  api.card = card
  return api
end
-- a full-width block the caller draws itself
function Page:custom(height, build)
  if self.slicing then task.wait() end
  local current = band(self, true)
  self.band = nil
  local frame = UI.frame(current.frame, { Name = "Custom", Size = UDim2.new(1, 0, 0, height or 0) })
  if not height then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("page.custom", build, frame)
  return frame
end
function Page:empty(icon, title, text)
  return self:custom(380, function(frame)
    local box = UI.frame(frame, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.46), Size = UDim2.fromOffset(420, 0),
      AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(box, "y", 10, { h = "Center" })
    local orb = UI.frame(box, { Size = UDim2.fromOffset(64, 64), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" }, LayoutOrder = 1 })
    UI.corner(orb, true)
    UI.stroke(orb, "ink", "strokeA")
    UI.icon(orb, icon or "package", 26, "sub", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    UI.text(box, title or "Nothing here yet", "title", "ink", { LayoutOrder = 2, TextXAlignment = Enum.TextXAlignment.Center })
    UI.text(box, text or "", "body", "sub", { LayoutOrder = 3, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.new(1, 0, 0, 0),
      AutomaticSize = Enum.AutomaticSize.Y, LineHeight = 1.25 })
  end)
end

-- ---------------------------------------------------------------- pages
-- spec: id, title, icon, group, eyebrow, build(page), order
function Window.page(spec)
  local page = setmetatable({ id = spec.id, title = spec.title, icon = spec.icon or "circle", group = spec.group or "", eyebrow = spec.eyebrow,
    build = spec.build, built = false, bandCount = 0, sectionCount = 0, order = spec.order or (#Window.order + 1) * 10 }, Page)
  Window.pages[spec.id] = page
  Window.order[#Window.order + 1] = page
  table.sort(Window.order, function(a, b) return a.order < b.order end)
  if Window.built then Window.rebuildNav() end
  return page
end
function Window.removePage(id)
  local page = Window.pages[id]
  if not page then return end
  Window.pages[id] = nil
  table.remove(Window.order, table.find(Window.order, page))
  if page.frame then page.holder:Destroy() end
  for index = #Window.index, 1, -1 do
    if Window.index[index].page == page then table.remove(Window.index, index) end
  end
  if Window.built then Window.rebuildNav() end
end
-- background = true builds the tab a card at a time across frames. Measured: built in one go a
-- tab costs 5-25 ms, which is a visible hitch; sliced, no frame carries more than one card.
local function ensureBuilt(page, background)
  if page.built then return end
  page.built = true
  page.slicing = background == true
  local holder = UI.group(Window.pageHost, { Name = page.id, Size = UDim2.fromScale(1, 1), Visible = false })
  local scroller, api = UI.scroll(holder, { Size = UDim2.new(1, 0, 1, 0), Name = "Scroll" })
  local content = UI.frame(scroller, { Name = "Content", Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(content, "y", 12)
  UI.pad(content, 2, 0, 18, 0)
  page.holder, page.frame, page.scroll, page.content = holder, scroller, api, content
  local started = os.clock()
  if page.build then B.try("page." .. page.id, page.build, page) end
  if page.sectionCount == 0 and page.bandCount == 0 then
    page:empty("package", "Nothing here yet", "This tab is ready for its controls.")
  end
  page.slicing = false
  page.ready = true
  page.buildMs = (os.clock() - started) * 1000
end
-- Build every tab that has not been opened yet, quietly, so the first visit never stutters and
-- search can find every control. Runs during the intro when there is one.
function Window.prebuild()
  if Window.prebuilding then return end
  Window.prebuilding = true
  for _, page in ipairs(table.clone(Window.order)) do
    if not B.alive then return end
    if Window.pages[page.id] == page and not page.built then
      B.try("page.prebuild", ensureBuilt, page, true)
      -- (under a film a tab built in one frame shows as a skipped picture: measured 2026-10-29,
      -- 57 of 887 skipped at boot against 17 with the hub idle, so they are spaced out more then)
      task.wait((B.Loader and B.Loader.active) and 0.3 or 0.05)
    end
  end
  Window.prebuilding = false
  -- (the key list on screen names each feature by its switch: they are all known now)
  if B.Keys and B.Keys.repaint then B.Keys.repaint() end
end
Window.ensureBuilt = ensureBuilt

function Window.go(id, instant)
  local page = Window.pages[id]
  if not page or not Window.built then return end
  local previous = Window.current
  if previous == page then return end
  ensureBuilt(page)
  Window.current = page
  UI.closePopovers()
  UI.hideTip()
  if previous and previous.holder then
    local old = previous.holder
    UI.fade(old, 0, "quick")
    Motion.to(old, "Position", UDim2.fromOffset(0, -8), "quick")
  end
  page.holder.Visible = true
  if instant then
    UI.setFade(page.holder, 1)
    page.holder.Position = UDim2.new()
  else
    UI.setFade(page.holder, 0)
    Motion.snap(page.holder, "Position", UDim2.fromOffset(0, 14))
    UI.fade(page.holder, 1, "smooth")
    Motion.to(page.holder, "Position", UDim2.new(), "smooth")
  end
  Window.setTitle(page, instant)
  Window.selectNav(page, instant)
  Window.onPage:fire(page)
  if not instant then UI.sfx("tab", 0.6) end
end

-- ---------------------------------------------------------------- build
local navItems = {}
function Window.build()
  if Window.built then return end
  Window.built = true
  local gui = B.screen(9000)
  local hudGui = B.screen(9100)
  Window.gui, Window.hudGui = gui, hudGui
  Window.hud = UI.frame(hudGui, { Name = "Hud", Size = UDim2.fromScale(1, 1) })
  UI.soundHost = UI.frame(hudGui, { Name = "Sound" })

  -- frees the cursor in first person while the hub is open
  Window.modal = UI.new("TextButton", { Name = "Modal", Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0), Modal = true, Visible = false, Parent = gui })

  local stage = UI.frame(gui, { Name = "Stage", Size = UDim2.fromScale(1, 1) })
  local holder = UI.frame(stage, { Name = "Window", Size = UDim2.fromOffset(W, H), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Visible = false })
  local sizer = Instance.new("UIScale")
  sizer.Parent = holder
  Window.holder, Window.sizer = holder, sizer
  UI.unit = function() return sizer.Scale end

  -- shadow lives outside the canvas: a canvas clips whatever leaves its bounds
  local shadowHost = UI.frame(holder, { Name = "Shadow", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
  UI.corner(shadowHost, "rWindow")
  if UI.fx.shadow then
    local shadow = Instance.new("UIShadow")
    shadow.BlurRadius = UDim.new(0, 70)
    shadow.Offset = UDim2.fromOffset(0, 28)
    shadow.Color = Color3.new(0, 0, 0)
    shadow.Transparency = 1
    pcall(function() shadow.ShowBehindParent = false end)
    shadow.Parent = shadowHost
    Window.shadow = shadow
  end

  local root = UI.group(holder, { Name = "Root", Size = UDim2.fromScale(1, 1) })
  UI.corner(root, "rWindow")
  Window.root = root
  local glass, rim = UI.glass(root, { level = "window", radius = "rWindow", name = "Glass", props = { Size = UDim2.fromScale(1, 1), Active = true },
    rimHi = 0.42, rimLo = 0.7, sheenAlpha = 0.95 })
  Window.glass, Window.rim = glass, rim

  -- ---- sidebar
  local side = UI.glass(glass, { level = "panel", radius = "rPanel", name = "Sidebar", fill = "fill1A",
    props = { Size = UDim2.new(0, SIDE, 1, -20), Position = UDim2.fromOffset(10, 10) }, rimHi = 0.72, rimLo = 0.9 })
  Window.side = side
  local brand = UI.frame(side, { Name = "Brand", Size = UDim2.new(1, 0, 0, 58) })
  local mark = UI.frame(brand, { Size = UDim2.fromOffset(0, 26), Position = UDim2.fromOffset(18, 18), AutomaticSize = Enum.AutomaticSize.X })
  UI.list(mark, "x", 3, { v = "Bottom" })
  UI.text(mark, "BASED", "brand", "ink", { LayoutOrder = 1, TextSize = 17 })
  UI.text(mark, "hub", "display", "accent", { LayoutOrder = 2, TextSize = 21 })
  -- The tabs scroll, between the brand and the user chip (a game with tabs of its own, Music and the
  -- rest of the hub ran past the bottom: Keys sat under the chip and Settings could not be reached).
  local navHost, navScroll = UI.scroll(side, { Name = "Nav", Size = UDim2.new(1, -16, 1, -128), Position = UDim2.fromOffset(8, 60),
    AutomaticCanvasSize = Enum.AutomaticSize.None, ClipsDescendants = true })
  Window.navHost, Window.navScroll = navHost, navScroll
  Window.navPill = UI.frame(Window.navHost, { Name = "Pill", Size = UDim2.new(1, 0, 0, 34), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" }, Visible = false })
  UI.corner(Window.navPill, "rControl")
  UI.stroke(Window.navPill, "ink", "strokeA")

  -- user chip
  local user = UI.frame(side, { Name = "User", Size = UDim2.new(1, -16, 0, 50), Position = UDim2.new(0, 8, 1, -58), Theme = { BackgroundColor3 = "ink" }, BackgroundTransparency = 1 })
  UI.corner(user, "rControl")
  local avatar = UI.new("ImageLabel", { Name = "Avatar", Size = UDim2.fromOffset(32, 32), Position = UDim2.new(0, 9, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 0, Theme = { BackgroundColor3 = "ink" }, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(B.LP.UserId) .. "&w=150&h=150", Parent = user })
  avatar.BackgroundTransparency = 0.9
  UI.corner(avatar, true)
  UI.text(user, B.LP.DisplayName, "label", "ink", { Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -78, 0, 17), AutomaticSize = Enum.AutomaticSize.None,
    TextTruncate = Enum.TextTruncate.AtEnd, TextSize = 13 })
  Window.userLine = UI.text(user, "@" .. B.LP.Name, "caption", "faint", { Position = UDim2.fromOffset(50, 26), Size = UDim2.new(1, -78, 0, 15),
    AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd, TextSize = 11 })
  local more = UI.icon(user, "ellipsis", 16, "faint", { Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
  UI.button(user, {
    hover = function(on) Motion.to(user, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
    click = function()
      UI.menu(more, {
        { label = "Settings", icon = "settings", run = function() Window.go("settings") end },
        { label = "Search", icon = "search", hint = "Ctrl K", run = function() Window.palette() end },
        { label = "Novoline menu", icon = "layout-grid", run = function() Config.set("app.gui", "novoline") end },
        "divider",
        { label = "Hide hub", icon = "eye-off", hint = Config.keyLabel(Config.get("app.key.menu")), run = function() Window.show(false) end },
        { label = "Unload BASED", icon = "power", danger = true, run = function() B.unload() end },
      }, { side = "above", align = "left", width = 214 })
    end,
  })

  -- ---- header
  local header = UI.frame(glass, { Name = "Header", Size = UDim2.new(0, CONTENT_W, 0, HEADER), Position = UDim2.fromOffset(CONTENT_X, 6) })
  Window.header = header
  Window.eyebrow = UI.text(header, "", "eyebrow", "faint", { Position = UDim2.fromOffset(2, 13) })
  local titleClip = UI.frame(header, { Name = "TitleClip", Size = UDim2.new(1, -250, 0, 46), Position = UDim2.fromOffset(0, 27), ClipsDescendants = true })
  Window.titleClip = titleClip
  -- search pill
  local search = UI.frame(header, { Name = "Search", Size = UDim2.fromOffset(170, 32), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -78, 0, 22),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill1A" } })
  UI.corner(search, true)
  UI.stroke(search, "ink", "strokeA")
  UI.icon(search, "search", 15, "faint", { Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
  UI.text(search, "Search", "body", "faint", { Position = UDim2.new(0, 34, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
  local hint = UI.frame(search, { Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
    Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
  UI.corner(hint, 6); UI.pad(hint, 0, 6)
  UI.text(hint, "Ctrl K", "mono", "faint", { TextSize = 10.5, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X })
  UI.button(search, {
    hover = function(on) Motion.to(search, "BackgroundTransparency", on and T.fill2A or T.fill1A, "quick") end,
    click = function() Window.palette() end,
  })
  -- window buttons
  local function roundButton(icon, x, tone, run, tip)
    local button = UI.frame(header, { Size = UDim2.fromOffset(30, 30), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 23),
      Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill1A" } })
    UI.corner(button, true)
    local glyph = UI.icon(button, icon, 15, "sub", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
    local scale = UI.scaleOf(button)
    local hit = UI.button(button, {
      hover = function(on)
        Motion.to(button, "BackgroundTransparency", on and (tone and 0.8 or T.fill3A) or T.fill1A, "quick")
        Theme.bind(button, "BackgroundColor3", on and tone or "ink")
        Theme.bind(glyph, "ImageColor3", on and (tone or "ink") or "sub")
      end,
      press = function(on) Motion.to(scale, "Scale", on and 0.9 or 1, on and "quick" or "bouncy") end,
      click = run,
    })
    UI.tooltip(hit, tip)
  end
  roundButton("x", -4, "bad", function() Window.show(false) end, "Hide (" .. Config.keyLabel(Config.get("app.key.menu")) .. ")")
  roundButton("minus", -40, nil, function() Window.show(false) end, "Minimise to the island")

  -- ---- pages
  Window.pageHost = UI.frame(glass, { Name = "Pages", Size = UDim2.new(0, CONTENT_W, 1, -(HEADER + 16)), Position = UDim2.fromOffset(CONTENT_X, HEADER + 6), ClipsDescendants = true })
  -- soft edge where content scrolls under the header
  local fade = UI.frame(glass, { Name = "EdgeTop", Size = UDim2.new(0, CONTENT_W, 0, 14), Position = UDim2.fromOffset(CONTENT_X, HEADER + 6), ZIndex = 7,
    Theme = { BackgroundColor3 = "base" }, BackgroundTransparency = 0, Interactable = false })
  UI.gradient(fade, { Rotation = 90, Transparency = UI.alphaSeq(0, 0.25, 1, 1) })
  Window.edgeTop = fade

  UI.mountOverlay(gui, function() return sizer.Scale end)

  -- ---- drag (header and sidebar brand), spring-followed
  local position = Motion.spring(2, "snappy", function(x) holder.Position = UDim2.fromOffset(x[1], x[2]) end, 0.2)
  Window.position = position
  local function clampTo(x, y)
    local view = B.viewport()
    local hw, hh = W * sizer.Scale / 2, H * sizer.Scale / 2
    local topInset = UI.inset().Y
    -- FIX: ScreenGui has IgnoreGuiInset=true, so y=0 sits under the native Roblox topbar.
    -- Keep the window's top edge below the topbar (+8px margin) so the header / tab title
    -- is never covered and the top rounded corners stay visible (not hidden / square-looking).
    -- Also keep the bottom edge on-screen. Guard min<=max: on small / mobile screens the window
    -- can be taller than the viewport, which would make math.clamp error (max < min).
    local minX, maxX = 140 - hw, view.X + hw - 140
    if maxX < minX then maxX = minX end
    local minY, maxY = hh + topInset + 8, view.Y - hh - 8
    if maxY < minY then maxY = minY end
    return math.clamp(x, minX, maxX), math.clamp(y, minY, maxY)
  end
  Window.clampTo = clampTo
  local startX, startY
  local function dragFrom(handle)
    UI.drag(handle, function()
      UI.closePopovers()
      startX, startY = position.g[1], position.g[2]
    end, function(_, delta)
      local x, y = clampTo(startX + delta.X, startY + delta.Y)
      position:to({ x, y }, "quick")
    end, function()
      local view = B.viewport()
      Config.set("app.window.x", position.g[1] / view.X)
      Config.set("app.window.y", position.g[2] / view.Y)
    end)
  end
  local grip = UI.new("TextButton", { Name = "Grip", Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.new(1, -260, 1, 0), ZIndex = 2, Parent = header })
  dragFrom(grip)
  local grip2 = UI.new("TextButton", { Name = "Grip", Text = "", BackgroundTransparency = 1, AutoButtonColor = false, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = brand })
  dragFrom(grip2)

  -- the rim highlight leans toward the pointer: glass catching a light
  local rimAngle = Motion.spring(1, "gentle", function(x) rim.Rotation = x[1] end, 0.05)
  rimAngle:snap({ 52 })
  Motion.every(function()
    if not Window.open then return end
    local mouse = UI.mouse()
    local p, s = holder.AbsolutePosition, holder.AbsoluteSize
    local dx, dy = mouse.X - (p.X + s.X / 2), mouse.Y - (p.Y + s.Y / 2)
    -- the gradient's bright end sits at angle+180: point it at the cursor
    local angle = math.deg(math.atan2(dy, dx)) + 180
    local current = rimAngle.g[1]
    local diff = (angle - current + 180) % 360 - 180
    if math.abs(diff) > 1.5 then rimAngle:to({ current + diff }) end
  end, 30, "window.rim")

  Window.rebuildNav()
  Window.rescale()
  B.connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() Window.rescale() end, "window.viewport")
end

function Window.rescale()
  if not Window.built then return end
  local view = B.viewport()
  local auto = math.clamp(math.min(view.Y / 1090, view.X / 1500), 0.55, 1.5)
  local user = (Config.get("app.scale") or 100) / 100
  local scale = math.min(auto * user, (view.X - 24) / W, (view.Y - 24) / H)
  Window.scale = scale
  Motion.to(Window.sizer, "Scale", scale * (Window.open and 1 or 0.95), "smooth")
  local fx, fy = Config.get("app.window.x") or 0.5, Config.get("app.window.y") or 0.5
  local x, y = Window.clampTo(fx * view.X, fy * view.Y)
  Window.position:snap({ x, y })
end

-- ---------------------------------------------------------------- nav
local selected = Motion.spring(2, "snappy", function(x)
  local pill = Window.navPill
  if not pill then return end
  local a, b = math.min(x[1], x[2]), math.max(x[1], x[2])
  pill.Position = UDim2.fromOffset(0, a)
  pill.Size = UDim2.new(1, 0, 0, math.max(8, b - a))
end, 0.15)
function Window.rebuildNav()
  local host = Window.navHost
  for _, item in ipairs(navItems) do item.frame:Destroy() end
  for _, child in ipairs(host:GetChildren()) do
    if child.Name == "Group" then child:Destroy() end
  end
  table.clear(navItems)
  local y = 0
  local lastGroup
  for _, page in ipairs(Window.order) do
    if not page.hidden then
      if page.group ~= lastGroup then
        lastGroup = page.group
        if page.group ~= "" then
          y += 10
          local label = UI.text(host, string.upper(page.group), "eyebrow", "faint", { Name = "Group", Position = UDim2.fromOffset(12, y), TextSize = 9 })
          label.Name = "Group"
          y += 22
        end
      end
      local item = UI.frame(host, { Name = "Item", Size = UDim2.new(1, 0, 0, 34), Position = UDim2.fromOffset(0, y), Theme = { BackgroundColor3 = "ink" }, ZIndex = 2 })
      UI.corner(item, "rControl")
      local icon = UI.icon(item, page.icon, 17, "sub", { Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
      local label = UI.text(item, page.title, "label", "sub", { Position = UDim2.new(0, 39, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13.5 })
      if page.badge then UI.badge(item, page.badge, "accent", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) }) end
      local entry = { frame = item, icon = icon, label = label, page = page, y = y }
      navItems[#navItems + 1] = entry
      UI.button(item, {
        hover = function(on)
          if Window.current == page then return end
          Motion.to(item, "BackgroundTransparency", on and 0.955 or 1, "quick")
        end,
        click = function() Window.go(page.id) end,
      })
      y += 36
    end
  end
  host.CanvasSize = UDim2.fromOffset(0, y + 6)
  if Window.current then Window.selectNav(Window.current, true) end
end
function Window.selectNav(page, instant)
  local target
  for _, entry in ipairs(navItems) do
    local on = entry.page == page
    Theme.bind(entry.icon, "ImageColor3", on and "accent" or "sub")
    Theme.bind(entry.label, "TextColor3", on and "ink" or "sub")
    Motion.to(entry.frame, "BackgroundTransparency", 1, "quick")
    if on then target = entry end
  end
  if not target then Window.navPill.Visible = false; return end
  local a, b = target.y, target.y + 34
  -- (scrolled so the chosen tab is in view)
  local host, scroll = Window.navHost, Window.navScroll
  if host and scroll then
    local view = host.AbsoluteWindowSize.Y / math.max(UI.unit(), 0.01)
    local at = host.CanvasPosition.Y / math.max(UI.unit(), 0.01)
    if a < at + 4 then scroll.to((a - 12) * UI.unit(), instant) elseif b > at + view - 4 then scroll.to((b - view + 12) * UI.unit(), instant) end
  end
  if instant or not Window.navPill.Visible then
    Window.navPill.Visible = true
    selected:snap({ a, b })
    return
  end
  -- liquid: the edge facing the destination moves first, the other one follows
  local down = a > selected.g[1]
  if down then selected:to({ selected.g[1], b }, "snappy") else selected:to({ a, selected.g[2] }, "snappy") end
  task.delay(0.05, function() if Window.current == page then selected:to({ a, b }, "liquid") end end)
end

-- title: the old one slides up out of a mask, the new one rises into it
function Window.setTitle(page, instant)
  local clip = Window.titleClip
  local old = Window.titleLabel
  local label = UI.text(clip, page.title, "display", "ink", { Position = UDim2.fromOffset(0, instant and 2 or 46), Name = "Title" })
  Window.titleLabel = label
  Window.eyebrow.Text = string.upper(page.eyebrow or (page.group ~= "" and page.group or "BASED"))
  if instant then
    if old then old:Destroy() end
    return
  end
  Motion.to(label, "Position", UDim2.fromOffset(0, 2), "smooth")
  if old then Motion.to(old, "Position", UDim2.fromOffset(0, -46), "smooth", function() old:Destroy() end) end
end

-- ---------------------------------------------------------------- show / hide
function Window.show(on, instant)
  if not Window.built or Window.open == on then return end
  Window.open = on
  UI.closePopovers()
  UI.hideTip()
  local holder, root, sizer = Window.holder, Window.root, Window.sizer
  Window.modal.Visible = on and Config.get("app.freeCursor") ~= false
  if on then
    holder.Visible = true
    if not Window.current and Window.order[1] then Window.go(Window.startPage or Window.order[1].id, true) end
    if instant then
      UI.setFade(root, 1); Motion.snap(sizer, "Scale", Window.scale)
      if Window.shadow then Window.shadow.Transparency = T.shadowA end
    else
      UI.setFade(root, 0)
      Motion.snap(sizer, "Scale", Window.scale * 0.94)
      UI.fade(root, 1, "smooth")
      Motion.to(sizer, "Scale", Window.scale, "bouncy")
      if Window.shadow then Motion.to(Window.shadow, "Transparency", T.shadowA, "gentle") end
      UI.sfx("open", 0.8)
    end
    Blur.show(true)
  else
    if Window.shadow then Motion.to(Window.shadow, "Transparency", 1, "quick") end
    Motion.to(sizer, "Scale", Window.scale * 0.96, "quick")
    Blur.show(false)
    UI.fade(root, 0, "quick", function() if not Window.open then holder.Visible = false end end)
    if not root:IsA("CanvasGroup") then holder.Visible = false end
    UI.sfx("close", 0.7)
  end
  Window.onShow:fire(on)
end
function Window.toggle() Window.show(not Window.open) end
-- any look of the hub is up: the BASED window, the Unnamed menu (src/52) or the Novoline one (src/53)
function Window.anyOpen()
  return Window.open or (B.Novoline ~= nil and B.Novoline.open == true)
end
-- a tab on screen in any look. (Live parts of a tab asked the BASED window alone, and stood still
-- in the other looks.)
function Window.showing(id)
  if Window.open and Window.current ~= nil and Window.current.id == id then return true end
  local novoline = B.Novoline
  return novoline ~= nil and novoline.open == true and novoline.current == id
end
-- which look is in use, and opening or closing it (the menu key)
function Window.look()
  local look = Config.get("app.gui")
  if look == "novoline" and B.Novoline then return "novoline" end
  return "based"
end
function Window.showActive(on)
  local look = Window.look()
  if look == "novoline" then B.Novoline.show(on) else Window.show(on) end
end
function Window.toggleActive()
  local look = Window.look()
  if look == "novoline" then B.Novoline.toggle() else Window.toggle() end
end

-- ---------------------------------------------------------------- the look kit
-- A tab that draws part of itself (the music player, a preview) takes its colours, letters and
-- corners from the look it is drawn in: Window.kit(frame). The BASED one is here; the Unnamed and
-- Novoline looks put theirs in Window.kits with an `owns(frame)` that says a frame is theirs.
--   kit.paint(instance, property, role)  set a colour and keep it in step (theme, accent)
--   kit.fill(instance, role)             a surface: colour and see-through together
--   kit.text(parent, value, props, bold, size), kit.entry(parent, size)  in the look's letters
--   kit.clear(instance)                  no surface (after a hover)
--   kit.outline(frame), kit.corner(frame, radius), kit.menu(anchor, items)
-- roles: card field hover line back text dim faint accent onAccent good bad
local ROLES = {
  card = { "ink", "fill1A" }, field = { "ink", "fill2A" }, hover = { "ink", "fill3A" }, line = { "ink", "strokeA" }, back = { "base", "baseA" },
  text = { "ink" }, dim = { "sub" }, faint = { "faint" }, accent = { "accent" }, onAccent = { "accentInk" }, good = { "ok" }, bad = { "bad" },
}
local kit = { look = "novoline", radius = 14, small = 9, size = 13 }  -- fallback stub; novoline kit registered later
function kit.color(role)
  local r = ROLES[role] or ROLES.text
  return T[r[1]], r[2] and T[r[2]] or 0
end
function kit.paint(instance, property, role)
  Theme.bind(instance, property, (ROLES[role] or ROLES.text)[1])
end
function kit.fill(instance, role)
  local r = ROLES[role] or ROLES.card
  Theme.bind(instance, "BackgroundColor3", r[1])
  if r[2] then Theme.bind(instance, "BackgroundTransparency", r[2]) else
    Theme.unbind(instance, "BackgroundTransparency")
    instance.BackgroundTransparency = 0
  end
end
-- no surface at all (after a hover): the theme lets go of it too
function kit.clear(instance)
  Theme.unbind(instance, "BackgroundTransparency")
  instance.BackgroundTransparency = 1
end
function kit.font(bold) return bold and B.F.text600 or B.F.text500 end
function kit.text(parent, value, props, bold, size)
  local label = UI.text(parent, value, bold and "heading" or "label", "ink", { AutomaticSize = Enum.AutomaticSize.None, TextSize = size or 13 })
  if props then for key, v in pairs(props) do label[key] = v end end
  return label
end
function kit.entry(parent, size)
  local entry = Instance.new("TextBox")
  entry.BackgroundTransparency, entry.BorderSizePixel = 1, 0
  entry.FontFace = B.F.text500
  UI.fontKey[entry] = "text500"
  entry.TextSize = size or 13
  entry.TextXAlignment, entry.ClearTextOnFocus, entry.ClipsDescendants = Enum.TextXAlignment.Left, false, true
  Theme.bind(entry, "TextColor3", "ink")
  Theme.bind(entry, "PlaceholderColor3", "faint")
  entry.Parent = parent
  return entry
end
function kit.outline(frame) return UI.stroke(frame, "ink", "strokeA") end
function kit.corner(frame, radius) return UI.corner(frame, radius or kit.radius) end
function kit.menu(anchor, items) return UI.menu(anchor, items, { align = "right" }) end
Window.kits = {}  -- empty-ish; the novoline kit (src/53) registers itself here
function Window.kit(frame)
  for name, other in pairs(Window.kits) do
    if name ~= "based" and other.owns and frame and other.owns(frame) then return other end
  end
  return kit
end
-- the kit of the look in use (for what sits on the HUD, outside any window)
function Window.activeKit() return Window.kits[Window.look()] or kit end

-- ---------------------------------------------------------------- command palette
local palette
function Window.palette()
  if palette then palette.close(); return end
  if not Window.built then return end
  if not Window.open then Window.show(true) end
  -- everything has to exist before it can be found
  for _, page in ipairs(Window.order) do ensureBuilt(page) end
  local scale = Window.scale
  local view = B.viewport()
  local veil = UI.new("TextButton", { Name = "Veil", Text = "", AutoButtonColor = false, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1, ZIndex = 70, Parent = UI.overlay })
  Motion.to(veil, "BackgroundTransparency", 0.62, "smooth")
  -- over the hub, wherever the hub has been dragged to
  local at, size = Window.holder.AbsolutePosition - UI.overlay.AbsolutePosition, Window.holder.AbsoluteSize
  local half = 270 * scale
  local holder = UI.frame(veil, { Name = "Palette", Size = UDim2.fromOffset(540, 0), AutomaticSize = Enum.AutomaticSize.Y, AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.fromOffset(math.clamp(at.X + size.X * 0.5, half + 12, math.max(half + 12, view.X - half - 12)), math.clamp(at.Y + 72 * scale, 16, math.max(16, view.Y - 420 * scale))),
    ZIndex = 71 })
  local sizer = Instance.new("UIScale"); sizer.Scale = scale * 0.95; sizer.Parent = holder
  Motion.to(sizer, "Scale", scale, "bouncy")
  local glass = UI.glass(holder, { level = "popover", radius = "rPanel", shadow = 60, shadowY = 26, props = { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y, Active = true } })
  local stack = UI.frame(glass, { Size = UDim2.fromScale(1, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(stack, "y", 0)
  local top = UI.frame(stack, { Size = UDim2.new(1, 0, 0, 54), LayoutOrder = 1 })
  UI.icon(top, "search", 18, "sub", { Position = UDim2.new(0, 18, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
  local box = UI.new("TextBox", { BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0), Position = UDim2.fromOffset(48, 0), Text = "", PlaceholderText = "Search every setting and tab",
    FontFace = B.F.text500, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Theme = { TextColor3 = "ink", PlaceholderColor3 = "faint" }, Parent = top })
  UI.text(top, "esc", "mono", "faint", { Position = UDim2.new(1, -18, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
  UI.divider(stack, 2)
  local list = UI.frame(stack, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3 })
  UI.pad(list, 6)
  UI.list(list, "y", 2)
  local rows, results, cursor = {}, {}, 1
  local connection
  local api = {}
  function api.close()
    if not palette then return end
    palette = nil
    if connection then connection:Disconnect() end
    Motion.to(veil, "BackgroundTransparency", 1, "quick", function() veil:Destroy() end)
    holder:Destroy()
  end
  local function highlight()
    for index, row in ipairs(rows) do
      Motion.to(row, "BackgroundTransparency", index == cursor and T.fill2A or 1, "quick")
    end
  end
  local function run(result)
    if not result then return end
    api.close()
    if result.kind == "page" then Window.go(result.page.id); return end
    Window.go(result.page.id)
    task.delay(0.12, function()
      local entry = result.entry
      if not entry.row.frame.Parent then return end
      local scroller = result.page.frame
      local offset = (entry.row.frame.AbsolutePosition.Y - scroller.AbsolutePosition.Y + scroller.CanvasPosition.Y) - 90 * Window.scale
      result.page.scroll.to(offset)
      entry.row.flash()
    end)
  end
  local function refresh()
    for _, row in ipairs(rows) do row:Destroy() end
    table.clear(rows); table.clear(results)
    local query = box.Text
    local scored = {}
    for _, page in ipairs(Window.order) do
      local score = util.fuzzy(query, page.title)
      if score then scored[#scored + 1] = { kind = "page", page = page, label = page.title, sub = "Tab", icon = page.icon, score = score + 1.5 } end
    end
    for _, entry in ipairs(Window.index) do
      local score = util.fuzzy(query, entry.label)
      if not score and query ~= "" and entry.desc ~= "" then
        local other = util.fuzzy(query, entry.desc)
        score = other and other - 4 or nil
      end
      if score then
        scored[#scored + 1] = { kind = "control", page = entry.page, entry = entry, label = entry.label, sub = entry.page.title .. "  ›  " .. tostring(entry.section),
          icon = entry.page.icon, score = score }
      end
    end
    table.sort(scored, function(a, b) return a.score > b.score end)
    for index = 1, math.min(8, #scored) do
      local result = scored[index]
      results[index] = result
      local row = UI.frame(list, { Size = UDim2.new(1, 0, 0, 40), LayoutOrder = index, Theme = { BackgroundColor3 = "ink" } })
      UI.corner(row, "rSmall")
      UI.icon(row, result.icon, 16, result.kind == "page" and "accent" or "sub", { Position = UDim2.new(0, 12, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
      UI.text(row, result.label, "label", "ink", { Position = UDim2.new(0, 40, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13.5 })
      UI.text(row, result.sub, "caption", "faint", { Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11.5 })
      UI.button(row, { hover = function(on) if on then cursor = index; highlight() end end, click = function() run(result) end })
      rows[index] = row
    end
    if #scored == 0 then
      local row = UI.frame(list, { Size = UDim2.new(1, 0, 0, 56) })
      UI.text(row, "No setting matches “" .. query .. "”", "body", "faint", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
      rows[1] = row
    end
    cursor = 1
    highlight()
  end
  box:GetPropertyChangedSignal("Text"):Connect(B.safe("palette", refresh))
  connection = UIS.InputBegan:Connect(B.safe("palette.key", function(input)
    if input.KeyCode == Enum.KeyCode.Down then cursor = math.min(#results, cursor + 1); highlight()
    elseif input.KeyCode == Enum.KeyCode.Up then cursor = math.max(1, cursor - 1); highlight()
    elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then run(results[cursor])
    elseif input.KeyCode == Enum.KeyCode.Escape then api.close() end
  end))
  veil.Activated:Connect(function() api.close() end)
  palette = api
  refresh()
  box:CaptureFocus()
  UI.sfx("open", 0.6)
end
end

do -- 08_film.lua
-- ============================================================================
--  08 film     frame-sequence player
--
--  The client cannot play a local video file (measured: VideoFrame and
--  VideoPlayer both refuse), and caps a local image at 1024 px. So a film is a
--  numbered run of JPEGs, and a frame above 1024 px wide is two textures side by
--  side. Each frame is decoded ahead of time in a pool of image slots. A slot
--  waits as a 1 px image; the two frames due next are made full size at alpha
--  0.001 ("primed") so the client has really drawn them; showing a frame is then
--  nothing but an alpha change.
--
--  That priming step is not optional. Measured with a 60 fps screen recording
--  and on-screen frame counters (tools/probes/present_test.lua): resizing a
--  frame to full size at the moment it is shown left the picture BLANK in 45%
--  of the recorded frames, while IsLoaded and every counter in Lua said all was
--  well. Primed, the frame on screen matched the frame Lua had presented in
--  every recorded frame, with no blanks.
--
--  Measured headroom on the test machine (10 slots): 1024x576 decodes at 337
--  frames/s and two-tile 1820x1024 at 171 frames/s against the 60 needed; both
--  presented 240/240 frames with none skipped.
--
--  The clock is wall time from the moment playback starts, so a slow frame
--  skips pictures instead of drifting away from the sound. Frames are counted
--  in an unwrapped sequence (0, 1, 2 ... across loops), which keeps every
--  "is this one newer" comparison a plain integer test.
--
--  Window mode (opts.window) is for a film that is part of the interface rather
--  than the whole screen: it needs rounded corners and may fade into what is
--  behind it, and a clip can do neither. Measured in this client's hidden UI: a
--  CanvasGroup neither clips its children nor takes a gradient, while a UICorner
--  and a UIGradient on the image itself both work, and a corner radius can be
--  set one corner at a time. So in window mode each tile is exactly the part of
--  the picture that shows, cut out of its texture by ImageRect, rounded on its
--  outer corners only and carrying its share of the fade.
-- ============================================================================
local S, Assets, fs = B.S, B.Assets, B.fs
local Film = { spec = B.FILM }
B.Film = Film

local HIDDEN = 0.999   -- a fully transparent image is never decoded; this one is
-- A waiting slot is a 1 px image parked at the CENTRE of the picture. Measured: an image that is
-- clipped out of view is never loaded, and a picture that covers a wider container overflows it,
-- so slots parked at its top-left corner sat off screen and the film stayed black.

function Film.has(setName, spec)
  spec = spec or Film.spec
  local set = spec and spec.sets and spec.sets[setName]
  if not set then return false end
  for _, tile in ipairs(set.tiles) do
    for _, index in ipairs({ 0, spec.count - 1 }) do
      if not Assets.frameIsFree(tile.path, index) and not fs.exists(fs.path(tile.path .. string.format("%0" .. set.digits .. "d.jpg", index))) then
        return false
      end
    end
  end
  return true
end
-- which set to play: the preference, falling back to whatever is installed
function Film.pick(preference, spec)
  local want = preference
  if want ~= "ultra" and want ~= "hd" then want = B.viewport().Y >= 800 and "ultra" or "hd" end
  if Film.has(want, spec) then return want end
  local other = want == "ultra" and "hd" or "ultra"
  if Film.has(other, spec) then return other end
  return nil
end
-- the part of a transparency ramp ({ { at, value }, ... }) between two fractions of its length
local function slice(points, a, b)
  local function at(t)
    local before = points[1]
    for _, point in ipairs(points) do
      if point[1] >= t then
        local span = point[1] - before[1]
        return span <= 0 and point[2] or before[2] + (point[2] - before[2]) * (t - before[1]) / span
      end
      before = point
    end
    return before[2]
  end
  local out = { NumberSequenceKeypoint.new(0, at(a)) }
  for _, point in ipairs(points) do
    if point[1] > a + 1e-3 and point[1] < b - 1e-3 then out[#out + 1] = NumberSequenceKeypoint.new((point[1] - a) / (b - a), point[2]) end
  end
  out[#out + 1] = NumberSequenceKeypoint.new(1, at(b))
  return NumberSequence.new(out)
end

-- opts: spec (which film: the intro unless given), set, slots, from / to (frame range), start
--       (film seconds), loop, audio, muted, volume, zIndex, window (see the header), backdrop,
--       budget (getcustomasset calls allowed per rendered frame), warmTo (last frame to pre-register),
--       clock (a function giving seconds: two players handed the same one are always on the same
--       frame, and one of them can be stopped and started without the other noticing)
function Film.new(parent, opts)
  local spec = opts.spec or Film.spec
  local set = spec and spec.sets[opts.set or "hd"]
  if not set then return nil end
  local fps, digits = spec.fps, set.digits
  local first, last = opts.from or 0, opts.to or (spec.count - 1)
  local length = last - first + 1
  local gapA, gapB = -1, -2          -- a film with no blackout: no frame is ever inside it
  if spec.gap then gapA, gapB = spec.gap[1], spec.gap[2] end
  local windowed = opts.window == true
  local slotCount = opts.slots or 10
  local budget = opts.budget or 2
  local tiles = set.tiles
  local self = { time = opts.start or first / fps, shown = -1, playing = false, ended = false, dead = false, volume = opts.volume or 0.5,
    muted = opts.muted == true, stats = { presented = 0, skipped = 0, late = 0, registered = 0 }, fps = fps, set = opts.set or "hd",
    length = length / fps, fresh = 0 }

  local frame = Instance.new("Frame")
  frame.Name = "Film"
  frame.BackgroundColor3 = Color3.new(0, 0, 0)
  frame.BackgroundTransparency = opts.backdrop == false and 1 or 0
  frame.BorderSizePixel = 0
  frame.Size = UDim2.fromScale(1, 1)
  frame.ClipsDescendants = true
  frame.ZIndex = opts.zIndex or 1
  frame.Parent = parent
  self.frame = frame
  -- the picture covers the container at the film's own aspect
  local picture = Instance.new("Frame")
  picture.Name = "Picture"
  picture.BackgroundTransparency = 1
  picture.BorderSizePixel = 0
  picture.AnchorPoint = Vector2.new(0.5, 0.5)
  picture.Position = UDim2.fromScale(0.5, 0.5)
  if windowed then picture.Size = UDim2.fromScale(1, 1) end
  picture.Parent = frame
  self.picture = picture
  local zoom = Instance.new("UIScale")
  zoom.Parent = picture
  self.zoom = zoom

  local rects = {}
  local slots = {}
  local current
  -- window mode: per tile, the part of it that shows (nil when none of it does)
  local cuts = {}
  local look = { tl = 0, tr = 0, br = 0, bl = 0, fade = nil, focusX = 0.5, focusY = 0.5 }
  self.look = look
  local function place(slot)
    for index, image in ipairs(slot.images) do
      if windowed then
        local cut = cuts[index]
        if cut then
          image.Position = UDim2.fromScale(cut.x, 0)
          image.Size = UDim2.fromScale(cut.w, 1)
          image.ImageRectOffset = Vector2.new(cut.rectX, cut.rectY)
          image.ImageRectSize = Vector2.new(cut.rectW, cut.rectH)
        else
          -- out of the window, but it still has to load for its frame to count as ready
          image.Position = UDim2.fromScale(0.5, 0.5)
          image.Size = UDim2.fromOffset(1, 1)
        end
      else
        image.Position = UDim2.fromOffset(rects[index][1], 0)
        image.Size = UDim2.new(0, rects[index][2], 1, 0)
      end
    end
  end
  local function dress()
    for _, slot in ipairs(slots) do
      for index in ipairs(slot.images) do
        local cut = cuts[index]
        if cut then
          local corner, fade = slot.corners[index], slot.fades[index]
          corner.TopLeftRadius, corner.BottomLeftRadius = UDim.new(0, cut.first and look.tl or 0), UDim.new(0, cut.first and look.bl or 0)
          corner.TopRightRadius, corner.BottomRightRadius = UDim.new(0, cut.last and look.tr or 0), UDim.new(0, cut.last and look.br or 0)
          if look.fade then
            fade.Transparency = slice(look.fade, cut.x, cut.x + cut.w)
            fade.Enabled = true
          elseif fade.Enabled then
            fade.Enabled = false
          end
        end
      end
    end
  end
  local function layout()
    local size = frame.AbsoluteSize
    if size.X < 2 or size.Y < 2 then return end
    if windowed then
      local W, H = math.floor(size.X + 0.5), math.floor(size.Y + 0.5)
      local scale = math.max(W / set.width, H / set.height)             -- screen pixels per film pixel
      local vw, vh = math.min(W / scale, set.width), math.min(H / scale, set.height)
      local vx, vy = (set.width - vw) * look.focusX, (set.height - vh) * look.focusY
      for index, tile in ipairs(tiles) do
        local t0, t1 = tile.x * set.width, (tile.x + tile.w) * set.width
        local a, b = math.max(t0, vx), math.min(t1, vx + vw)
        if b - a < 0.5 then
          cuts[index] = nil
        else
          -- Whole screen pixels, written as fractions of the container: exact under any UIScale,
          -- and both tiles round the seam between them from the same number. The rect follows
          -- the rounded pixel, and may reach a hair into the overlap the tiles were cut with.
          local x0 = a <= vx + 0.01 and 0 or math.floor((a - vx) * scale + 0.5)
          local x1 = b >= vx + vw - 0.01 and W or math.floor((b - vx) * scale + 0.5)
          cuts[index] = { x = x0 / W, w = (x1 - x0) / W, first = x0 == 0, last = x1 == W,
            rectX = tile.rectX + (vx + x0 / scale - t0), rectY = vy, rectW = (x1 - x0) / scale, rectH = vh }
        end
      end
      dress()
      for _, slot in ipairs(slots) do
        if slot == current or slot.primed then place(slot) end
      end
      return
    end
    local scale = math.max(size.X / set.width, size.Y / set.height)
    local w, h = math.ceil(set.width * scale), math.ceil(set.height * scale)
    picture.Size = UDim2.fromOffset(w, h)
    -- whole pixels per tile, so two halves never leave a seam or overlap
    local x = 0
    for index, tile in ipairs(tiles) do
      local right = index == #tiles and w or math.floor((tile.x + tile.w) * w + 0.5)
      rects[index] = { x, right - x }
      x = right
    end
    for _, slot in ipairs(slots) do
      if slot == current or slot.primed then place(slot) end
    end
  end
  for index = 1, slotCount do
    local slot = { images = {}, corners = {}, fades = {}, seq = nil }
    for t, tile in ipairs(tiles) do
      local image = Instance.new("ImageLabel")
      image.Name = "T" .. t
      image.BackgroundTransparency = 1
      image.BorderSizePixel = 0
      image.ScaleType = Enum.ScaleType.Stretch
      image.ImageRectOffset = Vector2.new(tile.rectX, 0)
      image.ImageRectSize = Vector2.new(tile.rectW, set.height)
      image.Size = UDim2.fromOffset(1, 1)
      image.Position = UDim2.fromScale(0.5, 0.5)
      image.ImageTransparency = HIDDEN
      if windowed then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 0)
        corner.Parent = image
        local fade = Instance.new("UIGradient")
        fade.Enabled = false
        fade.Parent = image
        slot.corners[t], slot.fades[t] = corner, fade
      end
      image.Parent = picture
      slot.images[t] = image
    end
    slots[index] = slot
  end
  layout()
  -- corner radii (tl, tr, br, bl, in the container's own units), a fade ({ { at, transparency }, ... }
  -- across the width, or false for none) and which part of the picture shows when it is cropped
  function self:setLook(next)
    local moved = false
    for key, value in pairs(next) do
      if (key == "focusX" or key == "focusY") and look[key] ~= value then moved = true end
      look[key] = value
    end
    if next.fade == false then look.fade = nil end
    if not windowed then return end
    if moved then layout() else dress() end
  end
  if opts.look then self:setLook(opts.look) end
  local resized = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

  local black = Instance.new("Frame")
  black.Name = "Black"
  black.BackgroundColor3 = Color3.new(0, 0, 0)
  black.BorderSizePixel = 0
  black.Size = UDim2.fromScale(1, 1)
  black.ZIndex = 2
  black.Visible = false
  black.Parent = frame

  local function indexOf(seq)
    return first + (opts.loop and seq % length or math.min(seq, length - 1))
  end
  local function inGap(index) return index >= gapA and index <= gapB end
  -- step a sequence number forward until it is on a frame that exists
  local function playable(seq)
    local index = indexOf(seq)
    if inGap(index) then seq += gapB - index + 1 end
    if not opts.loop and seq >= length then return nil end
    return seq
  end
  local function loaded(slot)
    for _, image in ipairs(slot.images) do
      if not image.IsLoaded then return false end
    end
    return true
  end
  local renderFrame = 0
  -- full size but invisible: drawn for real, so showing it later cannot blank
  local function prime(slot)
    if slot.primed then return end
    place(slot)
    slot.primed = renderFrame
  end
  local function reveal(slot, on)
    if on then
      if not slot.primed then place(slot) end
      local alpha = self.alpha or 1
      for index, image in ipairs(slot.images) do image.ImageTransparency = (windowed and not cuts[index]) and HIDDEN or 1 - alpha end
    else
      slot.primed = nil
      for _, image in ipairs(slot.images) do
        image.Size = UDim2.fromOffset(1, 1)
        image.Position = UDim2.fromScale(0.5, 0.5)
        image.ImageTransparency = HIDDEN
      end
    end
  end
  local function cost(index)
    local calls = 0
    for _, tile in ipairs(tiles) do
      if not Assets.frameIsFree(tile.path, index) then calls += 1 end
    end
    return calls
  end

  local assignedSeq, warmSeq, shownSeq = nil, nil, -1
  local spend = 0
  self.missing = false

  local function fill(horizon)
    for _, slot in ipairs(slots) do
      if not slot.seq and slot ~= current then
        local candidate = playable(math.max(assignedSeq and assignedSeq + 1 or horizon, horizon))
        if not candidate or candidate - horizon > slotCount + 1 then return end
        local index = indexOf(candidate)
        local need = cost(index)
        if need > spend then return end
        spend -= need
        self.stats.registered += need
        for t, tile in ipairs(tiles) do
          local id = Assets.frame(tile.path, index, digits)
          if not id then self.missing = true; return end
          slot.images[t].Image = id
        end
        slot.seq = candidate
        assignedSeq = candidate
      end
    end
  end
  local function warm()
    -- spare budget registers what comes next: those frames are free on every later launch
    local cursor = warmSeq or assignedSeq
    local guard = 0
    while spend > 0 and cursor and guard < 6 do
      guard += 1
      cursor = playable(cursor + 1)
      if not cursor then break end
      local index = indexOf(cursor)
      if opts.warmTo and index > opts.warmTo then break end
      if opts.loop and cursor >= length then break end
      local need = cost(index)
      if need > spend then break end
      if need > 0 then
        for _, tile in ipairs(tiles) do Assets.frame(tile.path, index, digits) end
        spend -= need
        self.stats.registered += need
      end
      warmSeq = cursor
    end
  end
  local function present(want)
    if inGap(indexOf(want)) then
      if not black.Visible then black.Visible = true end
      return
    end
    local best, waiting
    for _, slot in ipairs(slots) do
      local seq = slot.seq
      if seq and slot ~= current and seq <= want and seq > shownSeq and loaded(slot) then
        if slot.primed and renderFrame - slot.primed >= 1 then
          if not best or seq > best.seq then best = slot end
        elseif not waiting or seq > waiting.seq then
          waiting = slot
        end
      end
    end
    -- a frame that is due but was never primed (after a skip) gets one frame at full size first
    if waiting and (not best or waiting.seq > best.seq) then prime(waiting) end
    if best then
      reveal(best, true)
      if current then reveal(current, false); current.seq = nil end
      local jumped = best.seq - shownSeq - 1
      -- (the first picture after a start is not a skip: what lies before it was never due)
      if shownSeq >= 0 and jumped > 0 and jumped < 30 and self.fresh > 0 and not inGap(indexOf(shownSeq + 1)) then self.stats.skipped += jumped end
      current, shownSeq = best, best.seq
      self.current, self.shown = best, indexOf(best.seq)
      self.stats.presented += 1
      self.fresh += 1
      if black.Visible then black.Visible = false end
    elseif shownSeq >= 0 and shownSeq < want then
      self.stats.late += 1
    end
  end
  local function recycle(want)
    for _, slot in ipairs(slots) do
      local seq = slot.seq
      if seq and slot ~= current then
        -- already superseded, or so far behind the clock it will never be the newest
        if seq <= shownSeq or (seq < want - 3 and not loaded(slot)) then
          slot.seq = nil
          if slot.primed then reveal(slot, false) end
        end
      end
    end
  end
  -- make the two frames due next full size now
  local function primeAhead()
    local a, b
    for _, slot in ipairs(slots) do
      local seq = slot.seq
      if seq and slot ~= current and seq > shownSeq then
        if not a or seq < a.seq then b = a; a = slot
        elseif not b or seq < b.seq then b = slot end
      end
    end
    if a then prime(a) end
    if b then prime(b) end
  end
  local function pump(want)
    spend = budget
    renderFrame += 1
    present(want)
    recycle(want)
    fill(playable(want) or want)
    primeAhead()
    if spend > 0 then warm() end
  end

  local sound
  if opts.audio and spec.audio then
    local id = Assets.id(spec.audio)
    if id then
      sound = Instance.new("Sound")
      sound.Name = "Track"
      sound.SoundId = id
      sound.Volume = 0
      sound.Looped = opts.loop == true
      -- not under the picture: the picture is moved between containers, and a sound that
      -- changes parent starts over
      sound.Parent = opts.soundHost or frame
      self.sound = sound
    end
  end
  function self:setVolume(volume)
    self.volume = volume
    if sound then sound.Volume = volume end
  end
  -- Silent means the sound is not running at all, not running at volume 0. Unmuted, it joins
  -- at the picture's own time.
  function self:setMuted(muted)
    muted = muted == true
    if self.muted == muted then return end
    self.muted = muted
    if sound and muted then sound:Pause() end
  end
  function self:setAlpha(alpha)
    self.alpha = alpha
    if current then
      for index, image in ipairs(current.images) do image.ImageTransparency = (windowed and not cuts[index]) and HIDDEN or 1 - alpha end
    end
  end

  local function seqAt(seconds) return math.max(0, math.floor((seconds - first / fps) * fps + 1e-6)) end
  -- Decode the opening frames before the clock starts; returns when `count` are ready.
  function self:prepare(count, timeout, onProgress)
    local startSeq = playable(seqAt(self.time)) or 0
    count = math.min(count or 6, slotCount)
    local waited = 0
    while waited < (timeout or 4) and not self.dead do
      spend = math.max(budget, 4)
      fill(startSeq)
      local ready = 0
      for _, slot in ipairs(slots) do
        if slot.seq and loaded(slot) then ready += 1 end
      end
      if onProgress then onProgress(math.min(1, ready / count)) end
      renderFrame += 1
      primeAhead()
      if ready >= count or self.missing then break end
      waited += S.RunService.RenderStepped:Wait()
    end
    -- one more rendered frame, so the first pictures have been drawn at full size
    S.RunService.RenderStepped:Wait()
    renderFrame += 1
    if sound then
      local soundWait = 0
      while not sound.IsLoaded and soundWait < 1.5 and not self.dead do soundWait += S.RunService.RenderStepped:Wait() end
    end
    return not self.missing
  end

  -- `held` is how far the clock had run when it was paused. A looping film cannot take that
  -- from its time, which wraps: the frame sequence does not, and would never catch up.
  local started, held, lastJoin = 0, nil, 0
  function self:play()
    if self.dead or self.playing then return end
    self.playing, self.ended = true, false
    started = os.clock() - (held or (self.time - first / fps))
    held = nil
    -- how many pictures it has shown since it was last started: on someone else's clock, what it
    -- holds from before is old, and the one still on show is not to be trusted until this moves
    self.fresh = 0
    if opts.clock then
      for _, slot in ipairs(slots) do
        if slot ~= current then
          slot.seq = nil
          if slot.primed then reveal(slot, false) end
        end
      end
      assignedSeq, warmSeq = nil, nil
    end
    if sound and sound.IsLoaded and not self.muted then
      sound.TimePosition = self.time
      sound.Volume = self.volume
      sound:Play()
      lastJoin = os.clock()
    end
  end
  function self:pause()
    if self.playing then held = os.clock() - started end
    self.playing = false
    if sound then sound:Pause() end
  end
  local lastSync = 0
  local connection = S.RunService.RenderStepped:Connect(function()
    if self.dead then return end
    if not frame.Parent then self:destroy(); return end
    if not self.playing then return end
    local now = os.clock()
    local elapsed = opts.clock and opts.clock() or now - started
    local loopLength = length / fps
    if sound and not self.muted then
      if not sound.IsPlaying then
        -- unmuted, or loaded late, or back from a pause: join at the picture's own time
        local at = first / fps + (opts.loop and elapsed % loopLength or elapsed)
        if sound.IsLoaded and now - lastJoin > 0.25 and (opts.loop or at < sound.TimeLength - 0.05) then
          sound.TimePosition = at
          sound.Volume = self.volume
          sound:Play()
          lastSync, lastJoin = now, now
        end
      elseif now - lastSync > 0.5 then
        -- follow the sound if the two drift apart (its position only updates in coarse steps)
        lastSync = now
        local drift = sound.TimePosition - (first / fps + (opts.loop and elapsed % loopLength or elapsed))
        if opts.loop then drift = (drift + loopLength / 2) % loopLength - loopLength / 2 end
        if math.abs(drift) > 0.12 and math.abs(drift) < 2 then
          if opts.clock then
            -- the clock is not ours to move: bring the sound to the picture instead
            sound.TimePosition = first / fps + (opts.loop and elapsed % loopLength or elapsed)
          else
            started -= drift * 0.5
            elapsed = now - started
          end
        end
      end
    end
    local want = math.floor(elapsed * fps)
    if not opts.loop and want >= length then
      self.time = (last + 1) / fps
      self.playing, self.ended = false, true
      if sound then sound:Stop() end
      if self.onEnded then B.try("film.ended", self.onEnded) end
      return
    end
    self.time = first / fps + (opts.loop and elapsed % (length / fps) or elapsed)
    local ok, err = pcall(pump, want)
    if not ok then B.fault("film", err); self:destroy() end
  end)

  function self:destroy()
    if self.dead then return end
    self.dead, self.playing = true, false
    connection:Disconnect()
    resized:Disconnect()
    if sound then
      pcall(function() sound:Stop() end)
      if sound.Parent ~= frame then sound:Destroy() end
    end
    frame:Destroy()
  end
  B.own(self)
  return self
end
end

do -- 13_picker.lua
-- ============================================================================
--  13 picker   the first launch: which look to open in
--
--  The first time the hub runs on a machine (nothing saved yet), once the intro
--  is done, three cards fade in: BASED, Novoline and Unnamed, each with a small
--  drawing of what it looks like. A click (or 1, 2, 3) opens that one; it can be
--  changed any time after in Settings > Menu style.
-- ============================================================================
local S, util, Motion, Config = B.S, B.util, B.Motion, B.Config
local UIS = S.UserInputService
local Picker = { active = false }
B.Picker = Picker

local rgb = Color3.fromRGB
local INK, SOFT, FAINT = rgb(245, 244, 239), rgb(170, 170, 180), rgb(110, 110, 120)
local LOOKS = {
  { id = "novoline", name = "Novoline", line = "A dock at the bottom. A panel rises from it.", accent = rgb(230, 30, 30) },
}

local function frame(parent, props)
  local item = Instance.new("Frame")
  item.BorderSizePixel = 0
  item.BackgroundTransparency = 1
  for key, value in pairs(props or {}) do item[key] = value end
  item.Parent = parent
  return item
end
local function round(item, radius)
  local corner = Instance.new("UICorner")
  corner.CornerRadius = UDim.new(0, radius)
  corner.Parent = item
  return corner
end
local function label(parent, text, font, size, color, props)
  local item = Instance.new("TextLabel")
  item.BackgroundTransparency = 1
  item.BorderSizePixel = 0
  item.FontFace = B.F[font] or B.F.text400
  item.TextSize = size
  item.TextColor3 = color
  item.Text = text
  item.TextXAlignment = Enum.TextXAlignment.Left
  for key, value in pairs(props or {}) do item[key] = value end
  item.Parent = parent
  return item
end
local function block(parent, x, y, w, h, color, alpha, radius)
  local item = frame(parent, { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = color, BackgroundTransparency = alpha or 0 })
  if radius then round(item, radius) end
  return item
end

-- ---------------------------------------------------------------- the three drawings (196 x 150)
local DRAW = {}
function DRAW.novoline(box, accent)
  local back = block(box, 0, 0, 196, 150, rgb(10, 10, 11), 0, 12)
  local panel = block(back, 38, 18, 120, 88, rgb(22, 22, 25), 0.02, 10)
  local rim = Instance.new("UIStroke")
  rim.Color, rim.Transparency, rim.Thickness = rgb(255, 255, 255), 0.86, 1
  rim.Parent = panel
  block(panel, 10, 10, 46, 6, INK, 0.1, 3)
  for index = 1, 4 do
    block(panel, 10, 22 + index * 14, 70, 5, INK, 0.72, 2)
    local switch = block(panel, 92, 20 + index * 14, 18, 9, index % 2 == 1 and rgb(242, 242, 244) or rgb(60, 60, 66), 0, 5)
    block(switch, index % 2 == 1 and 10 or 2, 2, 5, 5, rgb(18, 18, 20), 0, 3)
  end
  local dock = block(back, 48, 118, 100, 22, rgb(40, 40, 44), 0, 11)
  for index = 1, 5 do
    local on = index == 3
    block(dock, 8 + (index - 1) * 18, 6, on and 14 or 10, 10, on and rgb(242, 242, 244) or rgb(150, 150, 156), on and 0 or 0.35, 5)
  end
  block(back, 93, 112, 10, 2, accent, 0, 1)
end
-- ---------------------------------------------------------------- the picker
-- done(look): look is "based", "novoline" or "unnamed"
function Picker.show(done)
  if Picker.active then return end
  Picker.active = true
  local gui = B.screen(9650)
  gui:SetAttribute("OwnLetters", true)
  local view = B.viewport()
  local k = math.clamp(math.min(view.Y / 1080, view.X / 1280), 0.55, 1.6)
  local shade = frame(gui, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = rgb(4, 4, 6), BackgroundTransparency = 1 })
  local veil = Instance.new("TextButton")          -- (frees the cursor and keeps clicks from the game)
  veil.Text, veil.AutoButtonColor, veil.BackgroundTransparency, veil.Size, veil.Modal, veil.ZIndex = "", false, 1, UDim2.fromScale(1, 1), true, 1
  veil.Parent = gui
  local stage = frame(gui, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(780, 430), ZIndex = 2 })
  local scale = Instance.new("UIScale")
  scale.Scale = k
  scale.Parent = stage
  local title = label(stage, "Pick your interface", "wideBold", 26, INK, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(780, 34),
    TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1 })
  local sub = label(stage, "You can change it any time in Settings, under Menu style.", "text400", 14, SOFT, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 40),
    Size = UDim2.fromOffset(780, 20), TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1 })
  local cards, chosen = {}, false
  -- (picked from outside: the same as a click on that card)
  function Picker.pick(look) if Picker.active then Picker.finish(look) end end

  local function finish(look)
    if chosen then return end
    chosen = true
    for _, card in ipairs(cards) do
      local mine = card.look.id == look
      Motion.tween(mine and 0.5 or 0.3, Motion.ease.outCubic, function(p)
        card.fade(mine and 0 or p)
        if mine then card.scale.Scale = 1.04 + 0.03 * math.sin(p * math.pi) end
      end)
    end
    task.delay(0.42, function()
      Motion.tween(0.38, Motion.ease.inCubic, function(p)
        shade.BackgroundTransparency = 0.25 + 0.75 * p
        title.TextTransparency, sub.TextTransparency = p, math.max(p, 0.2)
        for _, card in ipairs(cards) do card.fade(math.max(p, card.look.id == look and 0 or 1)) end
      end, function()
        gui:Destroy()
        Picker.active = false
        done(look)
      end)
    end)
  end

  Picker.finish = finish
  for index, look in ipairs(LOOKS) do
    local x = (index - 2) * 252
    local card = frame(stage, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, x, 0, 104), Size = UDim2.fromOffset(228, 300), BackgroundColor3 = rgb(18, 18, 22),
      BackgroundTransparency = 1, ZIndex = 2 })
    round(card, 16)
    local cardScale = Instance.new("UIScale")
    cardScale.Parent = card
    local rim = Instance.new("UIStroke")
    rim.Color, rim.Thickness, rim.Transparency = rgb(255, 255, 255), 1.2, 1
    rim.Parent = card
    local art = frame(card, { Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(196, 150), ZIndex = 3 })
    local group = Instance.new("CanvasGroup")
    group.BackgroundTransparency, group.BorderSizePixel, group.Size, group.GroupTransparency = 1, 0, UDim2.fromScale(1, 1), 1
    group.Parent = art
    DRAW[look.id](group, look.accent)
    local name = label(card, look.name, "wideBold", 17, INK, { Position = UDim2.fromOffset(18, 184), Size = UDim2.fromOffset(192, 22), TextTransparency = 1, ZIndex = 3 })
    local line = label(card, look.line, "text400", 13, SOFT, { Position = UDim2.fromOffset(18, 212), Size = UDim2.fromOffset(192, 40), TextWrapped = true,
      TextYAlignment = Enum.TextYAlignment.Top, TextTransparency = 1, ZIndex = 3 })
    local key = label(card, tostring(index), "mono500", 11, FAINT, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 266), Size = UDim2.fromOffset(18, 18),
      TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1, BackgroundColor3 = rgb(255, 255, 255), BackgroundTransparency = 1, ZIndex = 3 })
    round(key, 5)
    local tag = label(card, "Open", "text500", 12, look.accent, { Position = UDim2.fromOffset(18, 266), Size = UDim2.fromOffset(120, 18), TextTransparency = 1, ZIndex = 3 })
    local entry = { look = look, frame = card, scale = cardScale, hovered = false }
    -- 0 shown, 1 gone (and the rim, which lights on hover)
    function entry.fade(alpha)
      card.BackgroundTransparency = 0.08 + 0.92 * alpha
      group.GroupTransparency = alpha
      name.TextTransparency, line.TextTransparency = alpha, alpha
      key.TextTransparency, key.BackgroundTransparency = alpha, 0.92 + 0.08 * alpha
      tag.TextTransparency = entry.hovered and alpha or 1
      rim.Transparency = entry.hovered and (0.15 + 0.85 * alpha) or (0.88 + 0.12 * alpha)
      rim.Color = entry.hovered and look.accent or rgb(255, 255, 255)
    end
    entry.fade(1)
    local hit = Instance.new("TextButton")
    hit.Text, hit.AutoButtonColor, hit.BackgroundTransparency, hit.Size, hit.ZIndex = "", false, 1, UDim2.fromScale(1, 1), 5
    hit.Parent = card
    hit.MouseEnter:Connect(function()
      if chosen then return end
      entry.hovered = true
      Motion.to(cardScale, "Scale", 1.035, "snappy")
      entry.fade(0)
    end)
    hit.MouseLeave:Connect(function()
      if chosen then return end
      entry.hovered = false
      Motion.to(cardScale, "Scale", 1, "snappy")
      entry.fade(0)
    end)
    hit.Activated:Connect(function() finish(look.id) end)
    cards[index] = entry
  end

  -- in: the room darkens, the words come up, the cards rise one after another
  Motion.tween(0.6, Motion.ease.outCubic, function(p)
    shade.BackgroundTransparency = 1 - 0.75 * p
    title.TextTransparency, sub.TextTransparency = 1 - p, 1 - p * 0.9
    title.Position = UDim2.new(0.5, 0, 0, 10 * (1 - p))
  end)
  for index, entry in ipairs(cards) do
    task.delay(0.18 + index * 0.09, function()
      local x = (index - 2) * 252
      Motion.tween(0.55, Motion.ease.outCubic, function(p)
        if chosen then return end
        entry.frame.Position = UDim2.new(0.5, x, 0, 104 + 26 * (1 - p))
        entry.fade(1 - p)
      end)
    end)
  end
  -- 1, 2, 3 on the keyboard
  local keys = { One = 1, Two = 2, Three = 3, KeypadOne = 1, KeypadTwo = 2, KeypadThree = 3 }
  local link
  link = B.connect(UIS.InputBegan, function(input)
    if chosen then return end
    local pick = keys[input.KeyCode.Name]
    if pick and LOOKS[pick] then finish(LOOKS[pick].id) end
  end, "picker.keys")
  gui.Destroying:Connect(function() pcall(function() link:Disconnect() end) end)
end
end

do -- 20_home.lua (standalone)
-- ============================================================================
--  20 home     what the Home deck reads and calls, and the Home tab itself
--
--  The Home deck (53_novoline) shows the game, the server, your friends, the
--  music and the quick buttons. Everything it calls is real here, taken from
--  BasedHub as it is:
--    Registry  what game this is (no game modules ship in this library)
--    Hud       frame rate and ping                     (BasedHub 11_hud)
--    Server    Rejoin, Server hop, Copy join script    (BasedHub 25_world)
--    Music     the player behind Now playing           (44 to 49, below)
--  and the Home page itself, first in the dock.
-- ============================================================================
local S, util, Motion, Config, Window = B.S, B.util, B.Motion, B.Config, B.Window
B.pages = B.pages or {}

-- ---------------------------------------------------------------- registry
-- (no game has a script of its own in a UI library: the Game card names the place from Roblox)
local Registry = { games = {}, active = nil, gameName = nil }
B.Registry = Registry
function Registry.status() return { name = Registry.gameName, engineered = false, universal = true } end

-- ---------------------------------------------------------------- hud
local Hud = {}
B.Hud = Hud
function Hud.ping()
  local ok, value = pcall(function() return B.LP:GetNetworkPing() * 1000 end)
  if ok and value and value > 0 then return value end
  local ok2, item = pcall(function() return S.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
  return ok2 and item or 0
end
function Hud.fps() return 1 / math.max(Motion.smoothDt, 1 / 1000) end

-- ---------------------------------------------------------------- server
local Server = {}
B.Server = Server
function Server.rejoin()
  Window.toast({ title = "Rejoining", text = "Back in a moment.", icon = "refresh-cw" })
  task.delay(0.4, function()
    local ok, err = pcall(function()
      if #S.Players:GetPlayers() <= 1 then S.TeleportService:Teleport(game.PlaceId, B.LP)
      else S.TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, B.LP) end
    end)
    if not ok then Window.toast({ title = "Could not rejoin", text = tostring(err), icon = "triangle-alert", tone = "bad" }) end
  end)
end
function Server.hop()
  Window.toast({ title = "Looking for a server", icon = "shuffle" })
  task.spawn(B.safe("server.hop", function()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100"
    local ok, body = pcall(function() return game:HttpGet(url) end)
    local data = ok and select(2, pcall(function() return S.HttpService:JSONDecode(body) end))
    local choices = {}
    if type(data) == "table" and type(data.data) == "table" then
      for _, server in ipairs(data.data) do
        if type(server) == "table" and server.id ~= game.JobId and (server.playing or 0) < (server.maxPlayers or 0) then choices[#choices + 1] = server end
      end
    end
    if #choices == 0 then
      Window.toast({ title = "No other server found", text = "This may be the only one open.", icon = "triangle-alert", tone = "warn" })
      return
    end
    -- any of them, or the one with the fewest people in it, or the most that still has room
    local mode = Config.get("world.hopMode")
    local pick = choices[math.random(1, #choices)]
    if mode == "empty" or mode == "full" then
      table.sort(choices, function(a, b)
        if mode == "empty" then return (a.playing or 0) < (b.playing or 0) end
        return (a.playing or 0) > (b.playing or 0)
      end)
      pick = choices[1]
    end
    Server.picked = pick
    S.TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, B.LP)
  end))
end
function Server.copyJoin()
  local line = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)', game.PlaceId, game.JobId)
  local ok = B.clipboard(line)
  Window.toast(ok and { title = "Join script copied", text = "Run it to land in this exact server.", icon = "clipboard", tone = "ok" }
    or { title = "No clipboard access", icon = "triangle-alert", tone = "warn" })
end

-- ---------------------------------------------------------------- the Home tab
-- (Novoline draws its own Home deck for this page; the page's controls are what the command palette
-- finds, and what a look without a deck would show)
B.pages[#B.pages + 1] = function()
  Window.page({ id = "home", title = "Home", icon = "house", group = "", order = 1, eyebrow = "Welcome back, " .. B.LP.DisplayName, build = function(page)
    local quick = page:section({ title = "Quick actions", icon = "zap" })
    quick:button({ id = "home.rejoin", label = "Rejoin this server", tip = "Leaves and joins this server again.", text = "Rejoin", run = function() if B.Server then B.Server.rejoin() end end })
    quick:button({ id = "home.hop", label = "Find another server", tip = "Moves you to a different server.", text = "Hop", run = function() if B.Server then B.Server.hop() end end })
    local tips = page:section({ title = "Good to know", icon = "lightbulb" })
    tips:note({ icon = "keyboard", text = "Right-click a toggle or a button to bind it to a key. Right-click anything to reset it." })
    tips:note({ icon = "search", text = "Ctrl K searches every setting in every tab." })
    tips:note({ icon = "eye-off", text = Config.keyLabel(Config.get("app.key.menu")) .. " hides the hub." })
  end })
  Window.startPage = Window.startPage or "home"
end
end

do -- 44_aac.lua
-- ============================================================================
--  44 aac      AAC-LC to PCM in Luau: what SoundCloud streams, played here
--
--  Measured 2026-10-21: SoundCloud serves almost every track as AAC-LC in
--  fragmented MP4 over HLS (96 of 100 tracks across five searches had no MP3
--  stream), and Roblox will not load AAC/MP4 from a file (getcustomasset on
--  .m4a, .mp4 and .aac: never IsLoaded). WAV it will. So the stream is decoded
--  here: the MP4 boxes, the bitstream (sections, scale factors, Huffman
--  spectral data, pulses, TNS, mid/side, intensity, noise), the IMDCT (a DCT-IV
--  through an FFT of a quarter the size) with sine and KBD windows, and 16-bit
--  WAV out. Huffman codebooks and band tables are those of ISO/IEC 14496-3,
--  checked here as complete prefix codes; the decode is checked against
--  FFmpeg's on a real SoundCloud stream (tools: _work/aac).
-- ============================================================================
local AAC = {}
B.AAC = AAC

-- AAC Huffman codebooks (ISO/IEC 14496-3 / 13818-7): codewords and their lengths, index order.
local HCB = {
  { codes = { 2040, 497, 2045, 1013, 104, 1008, 2039, 492, 2037, 1009, 114, 1012, 116, 17, 118, 491, 108, 1014, 2044, 481, 2033, 496, 97, 502, 2034, 490, 2043, 498, 105, 493, 119, 23, 111, 486, 100, 485, 103, 21, 98, 18, 0, 20, 101, 22, 109, 489, 99, 484, 107, 19, 113, 483, 112, 499, 2046, 487, 2035, 495, 96, 494, 2032, 482, 2042, 1011, 106, 488, 117, 16, 115, 500, 110, 1015, 2038, 480, 2041, 1010, 102, 501, 2047, 503, 2036 },
    bits = { 11, 9, 11, 10, 7, 10, 11, 9, 11, 10, 7, 10, 7, 5, 7, 9, 7, 10, 11, 9, 11, 9, 7, 9, 11, 9, 11, 9, 7, 9, 7, 5, 7, 9, 7, 9, 7, 5, 7, 5, 1, 5, 7, 5, 7, 9, 7, 9, 7, 5, 7, 9, 7, 9, 11, 9, 11, 9, 7, 9, 11, 9, 11, 10, 7, 9, 7, 5, 7, 9, 7, 10, 11, 9, 11, 10, 7, 9, 11, 9, 11 } },
  { codes = { 499, 111, 509, 235, 35, 234, 503, 232, 506, 242, 45, 112, 32, 6, 43, 110, 40, 233, 505, 102, 248, 231, 27, 241, 500, 107, 501, 236, 42, 108, 44, 10, 39, 103, 26, 245, 36, 8, 31, 9, 0, 7, 29, 11, 48, 239, 28, 100, 30, 12, 41, 243, 47, 240, 508, 113, 498, 244, 33, 230, 247, 104, 504, 238, 34, 101, 49, 2, 38, 237, 37, 106, 507, 114, 510, 105, 46, 246, 511, 109, 502 },
    bits = { 9, 7, 9, 8, 6, 8, 9, 8, 9, 8, 6, 7, 6, 5, 6, 7, 6, 8, 9, 7, 8, 8, 6, 8, 9, 7, 9, 8, 6, 7, 6, 5, 6, 7, 6, 8, 6, 5, 6, 5, 3, 5, 6, 5, 6, 8, 6, 7, 6, 5, 6, 8, 6, 8, 9, 7, 9, 8, 6, 8, 8, 7, 9, 8, 6, 7, 6, 4, 6, 8, 6, 7, 9, 7, 9, 7, 6, 8, 9, 7, 9 } },
  { codes = { 0, 9, 239, 11, 25, 240, 491, 486, 1010, 10, 53, 495, 52, 55, 489, 493, 487, 1011, 494, 1005, 8186, 492, 498, 2041, 2040, 1016, 4088, 8, 56, 1014, 54, 117, 1009, 1003, 1004, 4084, 24, 118, 2036, 57, 116, 1007, 499, 500, 2038, 488, 1002, 8188, 242, 497, 4091, 1013, 2035, 4092, 238, 1015, 32766, 496, 2037, 32765, 8187, 16378, 65535, 241, 1008, 16380, 490, 1006, 16379, 4086, 4090, 32764, 2034, 4085, 65534, 1012, 2039, 32763, 4087, 4089, 32762 },
    bits = { 1, 4, 8, 4, 5, 8, 9, 9, 10, 4, 6, 9, 6, 6, 9, 9, 9, 10, 9, 10, 13, 9, 9, 11, 11, 10, 12, 4, 6, 10, 6, 7, 10, 10, 10, 12, 5, 7, 11, 6, 7, 10, 9, 9, 11, 9, 10, 13, 8, 9, 12, 10, 11, 12, 8, 10, 15, 9, 11, 15, 13, 14, 16, 8, 10, 14, 9, 10, 14, 12, 12, 15, 11, 12, 16, 10, 11, 15, 12, 12, 15 } },
  { codes = { 7, 22, 246, 24, 8, 239, 495, 243, 2040, 25, 23, 237, 21, 1, 226, 240, 112, 1008, 494, 241, 2042, 238, 228, 1010, 2038, 1007, 2045, 5, 20, 242, 9, 4, 229, 244, 232, 1012, 6, 2, 231, 3, 0, 107, 227, 105, 499, 235, 230, 1014, 110, 106, 500, 1004, 496, 1017, 245, 236, 2043, 234, 111, 1015, 2041, 1011, 4095, 233, 109, 1016, 108, 104, 501, 1006, 498, 2036, 2039, 1009, 4094, 1005, 497, 2037, 2046, 1013, 2044 },
    bits = { 4, 5, 8, 5, 4, 8, 9, 8, 11, 5, 5, 8, 5, 4, 8, 8, 7, 10, 9, 8, 11, 8, 8, 10, 11, 10, 11, 4, 5, 8, 4, 4, 8, 8, 8, 10, 4, 4, 8, 4, 4, 7, 8, 7, 9, 8, 8, 10, 7, 7, 9, 10, 9, 10, 8, 8, 11, 8, 7, 10, 11, 10, 12, 8, 7, 10, 7, 7, 9, 10, 9, 11, 11, 10, 12, 10, 9, 11, 11, 10, 11 } },
  { codes = { 8191, 4087, 2036, 2024, 1009, 2030, 2041, 4088, 8189, 4093, 2033, 1000, 488, 240, 492, 1006, 2034, 4090, 4084, 1007, 498, 232, 112, 236, 496, 1002, 2035, 2027, 491, 234, 26, 8, 25, 238, 495, 2029, 1008, 242, 115, 11, 0, 10, 113, 243, 2025, 2031, 494, 239, 24, 9, 27, 235, 489, 2028, 2038, 1003, 499, 237, 114, 233, 497, 1005, 2039, 4086, 2032, 1001, 493, 241, 490, 1004, 2040, 4089, 8188, 4092, 4085, 2026, 1011, 1010, 2037, 4091, 8190 },
    bits = { 13, 12, 11, 11, 10, 11, 11, 12, 13, 12, 11, 10, 9, 8, 9, 10, 11, 12, 12, 10, 9, 8, 7, 8, 9, 10, 11, 11, 9, 8, 5, 4, 5, 8, 9, 11, 10, 8, 7, 4, 1, 4, 7, 8, 11, 11, 9, 8, 5, 4, 5, 8, 9, 11, 11, 10, 9, 8, 7, 8, 9, 10, 11, 12, 11, 10, 9, 8, 9, 10, 11, 12, 13, 12, 12, 11, 10, 10, 11, 12, 13 } },
  { codes = { 2046, 1021, 497, 491, 500, 490, 496, 1020, 2045, 1014, 485, 234, 108, 113, 104, 240, 486, 1015, 499, 239, 50, 39, 40, 38, 49, 235, 503, 488, 111, 46, 8, 4, 6, 41, 107, 494, 495, 114, 45, 2, 0, 3, 47, 115, 506, 487, 110, 43, 7, 1, 5, 44, 109, 492, 505, 238, 48, 36, 42, 37, 51, 236, 498, 1016, 484, 237, 106, 112, 105, 116, 241, 1018, 2047, 1017, 502, 493, 504, 489, 501, 1019, 2044 },
    bits = { 11, 10, 9, 9, 9, 9, 9, 10, 11, 10, 9, 8, 7, 7, 7, 8, 9, 10, 9, 8, 6, 6, 6, 6, 6, 8, 9, 9, 7, 6, 4, 4, 4, 6, 7, 9, 9, 7, 6, 4, 4, 4, 6, 7, 9, 9, 7, 6, 4, 4, 4, 6, 7, 9, 9, 8, 6, 6, 6, 6, 6, 8, 9, 10, 9, 8, 7, 7, 7, 7, 8, 10, 11, 10, 9, 9, 9, 9, 9, 10, 11 } },
  { codes = { 0, 5, 55, 116, 242, 491, 1005, 2039, 4, 12, 53, 113, 236, 238, 494, 501, 54, 52, 114, 234, 241, 489, 499, 1013, 115, 112, 235, 240, 497, 496, 1004, 1018, 243, 237, 488, 495, 1007, 1009, 1017, 2043, 493, 239, 490, 498, 1011, 1016, 2041, 2044, 1006, 492, 500, 1012, 1015, 2040, 4093, 4094, 2038, 1008, 1010, 1014, 2042, 2045, 4092, 4095 },
    bits = { 1, 3, 6, 7, 8, 9, 10, 11, 3, 4, 6, 7, 8, 8, 9, 9, 6, 6, 7, 8, 8, 9, 9, 10, 7, 7, 8, 8, 9, 9, 10, 10, 8, 8, 9, 9, 10, 10, 10, 11, 9, 8, 9, 9, 10, 10, 11, 11, 10, 9, 9, 10, 10, 11, 12, 12, 11, 10, 10, 10, 11, 11, 12, 12 } },
  { codes = { 14, 5, 16, 48, 111, 241, 506, 1022, 3, 0, 4, 18, 44, 106, 117, 248, 15, 2, 6, 20, 46, 105, 114, 245, 47, 17, 19, 42, 50, 108, 236, 250, 113, 43, 45, 49, 109, 112, 242, 505, 239, 104, 51, 107, 110, 238, 249, 1020, 504, 116, 115, 237, 240, 246, 502, 509, 1021, 243, 244, 247, 503, 507, 508, 1023 },
    bits = { 5, 4, 5, 6, 7, 8, 9, 10, 4, 3, 4, 5, 6, 7, 7, 8, 5, 4, 4, 5, 6, 7, 7, 8, 6, 5, 5, 6, 6, 7, 8, 8, 7, 6, 6, 6, 7, 7, 8, 9, 8, 7, 6, 7, 7, 8, 8, 10, 9, 7, 7, 8, 8, 8, 9, 9, 10, 8, 8, 8, 9, 9, 9, 10 } },
  { codes = { 0, 5, 55, 231, 478, 974, 985, 1992, 1997, 4040, 4061, 8164, 8172, 4, 12, 53, 114, 234, 237, 482, 977, 979, 992, 2008, 4047, 4053, 54, 52, 113, 232, 236, 481, 975, 989, 987, 2000, 4039, 4052, 4068, 230, 112, 233, 477, 483, 978, 988, 1996, 1994, 2014, 4056, 4074, 8155, 479, 235, 476, 486, 981, 990, 1995, 2013, 2012, 4045, 4066, 4071, 8161, 976, 480, 484, 982, 1989, 2001, 2011, 4050, 2016, 4057, 4075, 8163, 8169, 1988, 485, 983, 1990, 1999, 2010, 4043, 4058, 4067, 4073, 8166, 8179, 8183, 2003, 984, 993, 2004, 2009, 4051, 4062, 8157, 8153, 8162, 8170, 8177, 8182, 2002, 980, 986, 1991, 2007, 2018, 4046, 4059, 8152, 8174, 16368, 8180, 16370, 2017, 991, 1993, 2006, 4042, 4048, 4069, 4070, 8171, 8175, 16371, 16372, 16373, 4064, 1998, 2005, 4038, 4049, 4065, 8160, 8168, 8176, 16369, 16376, 16374, 32764, 4072, 2015, 4041, 4055, 4060, 8156, 8159, 8173, 8181, 16377, 16379, 32765, 32766, 8167, 4044, 4054, 4063, 8158, 8154, 8165, 8178, 16378, 16375, 16380, 16381, 32767 },
    bits = { 1, 3, 6, 8, 9, 10, 10, 11, 11, 12, 12, 13, 13, 3, 4, 6, 7, 8, 8, 9, 10, 10, 10, 11, 12, 12, 6, 6, 7, 8, 8, 9, 10, 10, 10, 11, 12, 12, 12, 8, 7, 8, 9, 9, 10, 10, 11, 11, 11, 12, 12, 13, 9, 8, 9, 9, 10, 10, 11, 11, 11, 12, 12, 12, 13, 10, 9, 9, 10, 11, 11, 11, 12, 11, 12, 12, 13, 13, 11, 9, 10, 11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 11, 10, 10, 11, 11, 12, 12, 13, 13, 13, 13, 13, 13, 11, 10, 10, 11, 11, 11, 12, 12, 13, 13, 14, 13, 14, 11, 10, 11, 11, 12, 12, 12, 12, 13, 13, 14, 14, 14, 12, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 12, 11, 12, 12, 12, 13, 13, 13, 13, 14, 14, 15, 15, 13, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 15 } },
  { codes = { 34, 8, 29, 38, 95, 211, 463, 976, 983, 1005, 2032, 2038, 4093, 7, 0, 1, 9, 32, 84, 96, 213, 220, 468, 973, 990, 2023, 28, 2, 6, 12, 30, 40, 91, 205, 217, 462, 476, 985, 1009, 37, 11, 10, 13, 36, 87, 97, 204, 221, 460, 478, 979, 999, 93, 33, 31, 35, 39, 89, 100, 216, 223, 466, 482, 989, 1006, 209, 85, 41, 86, 88, 98, 206, 224, 226, 474, 980, 995, 2027, 457, 94, 90, 92, 99, 202, 218, 455, 458, 480, 987, 1000, 2028, 483, 210, 203, 208, 215, 219, 454, 469, 472, 970, 986, 2026, 2033, 481, 212, 207, 214, 222, 225, 464, 470, 977, 981, 1010, 2030, 2043, 1001, 461, 456, 459, 465, 471, 479, 975, 992, 1007, 2022, 2040, 4090, 1003, 477, 467, 473, 475, 978, 972, 988, 1002, 2029, 2035, 2041, 4089, 2034, 974, 484, 971, 984, 982, 994, 997, 2024, 2036, 2037, 2039, 4091, 2042, 1004, 991, 993, 996, 998, 1008, 2025, 2031, 4088, 4094, 4092, 4095 },
    bits = { 6, 5, 6, 6, 7, 8, 9, 10, 10, 10, 11, 11, 12, 5, 4, 4, 5, 6, 7, 7, 8, 8, 9, 10, 10, 11, 6, 4, 5, 5, 6, 6, 7, 8, 8, 9, 9, 10, 10, 6, 5, 5, 5, 6, 7, 7, 8, 8, 9, 9, 10, 10, 7, 6, 6, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 8, 7, 6, 7, 7, 7, 8, 8, 8, 9, 10, 10, 11, 9, 7, 7, 7, 7, 8, 8, 9, 9, 9, 10, 10, 11, 9, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10, 11, 11, 9, 8, 8, 8, 8, 8, 9, 9, 10, 10, 10, 11, 11, 10, 9, 9, 9, 9, 9, 9, 10, 10, 10, 11, 11, 12, 10, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 12, 11, 10, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 12, 11, 10, 10, 10, 10, 10, 10, 11, 11, 12, 12, 12, 12 } },
  { codes = { 0, 6, 25, 61, 156, 198, 423, 912, 962, 991, 2022, 2035, 4091, 2028, 4090, 4094, 910, 5, 1, 8, 20, 55, 66, 146, 175, 401, 421, 437, 926, 960, 930, 973, 2006, 174, 23, 7, 9, 24, 57, 64, 142, 163, 184, 409, 428, 449, 945, 918, 958, 970, 157, 60, 21, 22, 26, 59, 68, 145, 165, 190, 406, 430, 441, 929, 913, 933, 981, 148, 154, 54, 56, 58, 65, 140, 155, 176, 195, 414, 427, 444, 927, 911, 937, 975, 147, 191, 62, 63, 67, 69, 158, 167, 185, 404, 418, 442, 451, 934, 935, 955, 980, 159, 416, 143, 141, 144, 152, 166, 182, 196, 415, 431, 447, 921, 959, 948, 969, 999, 168, 438, 171, 164, 170, 178, 194, 197, 408, 420, 440, 908, 932, 964, 966, 989, 1000, 173, 943, 402, 189, 188, 398, 407, 410, 419, 433, 909, 920, 951, 979, 977, 987, 2013, 180, 990, 425, 411, 412, 417, 426, 429, 435, 907, 946, 952, 974, 993, 992, 2002, 2021, 183, 2019, 443, 424, 422, 432, 434, 439, 923, 922, 954, 949, 982, 2007, 996, 2008, 2026, 186, 2024, 928, 445, 436, 906, 452, 914, 938, 944, 956, 983, 2004, 2012, 2011, 2005, 2032, 193, 2043, 968, 931, 917, 925, 940, 942, 965, 984, 994, 998, 2020, 2023, 2016, 2025, 2039, 400, 2034, 915, 446, 448, 916, 919, 941, 963, 961, 978, 2010, 2009, 2015, 2027, 2036, 2042, 405, 2040, 957, 924, 939, 936, 947, 953, 976, 995, 997, 2018, 2014, 2029, 2033, 2041, 2044, 403, 4093, 988, 950, 967, 972, 971, 985, 986, 2003, 2017, 2030, 2031, 2037, 2038, 4092, 4095, 413, 450, 181, 161, 150, 151, 149, 153, 160, 162, 172, 169, 177, 179, 187, 192, 399, 4 },
    bits = { 4, 5, 6, 7, 8, 8, 9, 10, 10, 10, 11, 11, 12, 11, 12, 12, 10, 5, 4, 5, 6, 7, 7, 8, 8, 9, 9, 9, 10, 10, 10, 10, 11, 8, 6, 5, 5, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10, 8, 7, 6, 6, 6, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10, 8, 8, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10, 8, 8, 7, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 8, 9, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10, 10, 8, 9, 8, 8, 8, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10, 10, 10, 8, 10, 9, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 8, 10, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 8, 11, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 10, 11, 11, 8, 11, 10, 9, 9, 10, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 8, 11, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 9, 11, 10, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 9, 11, 10, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 9, 12, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 12, 12, 9, 9, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 5 } },
}
local SFCB = { codes = { 262120, 262118, 262119, 262117, 524277, 524273, 524269, 524278, 524270, 524271, 524272, 524284, 524285, 524287, 524286, 524279, 524280, 524283, 524281, 262116, 524282, 262115, 131055, 131056, 65525, 131054, 65522, 65523, 65524, 65521, 32758, 32759, 16377, 16373, 16375, 16371, 16374, 16370, 8183, 8181, 4089, 4087, 4086, 2041, 4084, 2040, 1017, 1015, 1013, 504, 503, 250, 248, 246, 121, 58, 56, 26, 11, 4, 0, 10, 12, 27, 57, 59, 120, 122, 247, 249, 502, 505, 1012, 1014, 1016, 2037, 2036, 2038, 2039, 4085, 4088, 8180, 8182, 8184, 16376, 16372, 65520, 32756, 65526, 32757, 262114, 524249, 524250, 524251, 524252, 524253, 524254, 524248, 524242, 524243, 524244, 524245, 524246, 524274, 524255, 524263, 524264, 524265, 524266, 524267, 524262, 524256, 524257, 524258, 524259, 524260, 524261, 524247, 524268, 524276, 524275 },
  bits = { 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 18, 19, 18, 17, 17, 16, 17, 16, 16, 16, 16, 15, 15, 14, 14, 14, 14, 14, 14, 13, 13, 12, 12, 12, 11, 12, 11, 10, 10, 10, 9, 9, 8, 8, 8, 7, 6, 6, 5, 4, 3, 1, 4, 4, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 10, 11, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 16, 15, 16, 15, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19 } }

local band, rshift, lshift = bit32.band, bit32.rshift, bit32.lshift
local readu8 = buffer.readu8
local floor, sqrt, sin, cos, pi = math.floor, math.sqrt, math.sin, math.cos, math.pi

-- ---------------------------------------------------------------- reading bits
local RB: buffer = buffer.create(0)          -- what is being read, and where (in bits)
local RP = 0
local function bit1()
  local p = RP
  RP = p + 1
  return band(rshift(readu8(RB, rshift(p, 3)), 7 - band(p, 7)), 1)
end
local function bits(n)
  local v = 0
  for _ = 1, n do
    local p = RP
    RP = p + 1
    v = v * 2 + band(rshift(readu8(RB, rshift(p, 3)), 7 - band(p, 7)), 1)
  end
  return v
end
-- a codebook as a tree walked a bit at a time: zero[node] / one[node] is the next node, or -(entry)
local function tree(codes, lengths)
  local zero, one = { 0 }, { 0 }
  local count = 1
  for index = 1, #codes do
    local code, length = codes[index], lengths[index]
    local node = 1
    for b = length - 1, 0, -1 do
      local bit = band(rshift(code, b), 1)
      if b == 0 then
        if bit == 0 then zero[node] = -index else one[node] = -index end
      else
        local child = if bit == 0 then zero[node] else one[node]
        if child == nil or child == 0 then
          count += 1
          zero[count], one[count] = 0, 0
          child = count
          if bit == 0 then zero[node] = child else one[node] = child end
        end
        node = child
      end
    end
  end
  return zero, one
end
local function huff(zero, one)
  local node = 1
  while true do
    local p = RP
    RP = p + 1
    local child
    if band(rshift(readu8(RB, rshift(p, 3)), 7 - band(p, 7)), 1) == 0 then child = zero[node] else child = one[node] end
    if child < 0 then return -child end
    if child == 0 then error("aac: bad codeword") end
    node = child
  end
end

-- ---------------------------------------------------------------- the books, ready to use
-- per spectral book: how many values a codeword holds, whether signs follow, and every entry's values
local BOOK = {}
local SFZ, SFO
local function prepare()
  if SFZ then return end
  SFZ, SFO = tree(SFCB.codes, SFCB.bits)
  local shape = { { 4, true, 3, 1 }, { 4, true, 3, 1 }, { 4, false, 3, 0 }, { 4, false, 3, 0 }, { 2, true, 9, 4 }, { 2, true, 9, 4 },
    { 2, false, 8, 0 }, { 2, false, 8, 0 }, { 2, false, 13, 0 }, { 2, false, 13, 0 }, { 2, false, 17, 0 } }
  for book = 1, 11 do
    local dim, signed, mod, off = shape[book][1], shape[book][2], shape[book][3], shape[book][4]
    local zero, one = tree(HCB[book].codes, HCB[book].bits)
    local values = {}
    for index = 1, #HCB[book].codes do
      local i = index - 1
      if dim == 4 then
        values[#values + 1] = floor(i / 27) - off
        values[#values + 1] = floor(i / 9) % 3 - off
        values[#values + 1] = floor(i / 3) % 3 - off
        values[#values + 1] = i % 3 - off
      else
        values[#values + 1] = floor(i / mod) - off
        values[#values + 1] = i % mod - off
      end
    end
    BOOK[book] = { zero = zero, one = one, dim = dim, unsigned = not signed, values = values }
  end
end

-- ---------------------------------------------------------------- tables of the standard
local RATES = { [0] = 96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350 }
local L96 = { 0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 64, 72, 80, 88, 96, 108, 120, 132, 144, 156, 172, 188, 212, 240, 276, 320, 384, 448, 512, 576, 640, 704,
  768, 832, 896, 960, 1024 }
local S96 = { 0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 92, 128 }
local L64 = { 0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 64, 72, 80, 88, 100, 112, 124, 140, 156, 172, 192, 216, 240, 268, 304, 344, 384, 424, 464, 504, 544, 584,
  624, 664, 704, 744, 784, 824, 864, 904, 944, 984, 1024 }
local L48 = { 0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72, 80, 88, 96, 108, 120, 132, 144, 160, 176, 196, 216, 240, 264, 292, 320, 352, 384, 416, 448, 480, 512, 544,
  576, 608, 640, 672, 704, 736, 768, 800, 832, 864, 896, 928, 1024 }
local S48 = { 0, 4, 8, 12, 16, 20, 28, 36, 44, 56, 68, 80, 96, 112, 128 }
local L32 = { 0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72, 80, 88, 96, 108, 120, 132, 144, 160, 176, 196, 216, 240, 264, 292, 320, 352, 384, 416, 448, 480, 512, 544,
  576, 608, 640, 672, 704, 736, 768, 800, 832, 864, 896, 928, 960, 992, 1024 }
local L24 = { 0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 52, 60, 68, 76, 84, 92, 100, 108, 116, 124, 136, 148, 160, 172, 188, 204, 220, 240, 260, 284, 308, 336, 364, 396, 432,
  468, 508, 552, 600, 652, 704, 768, 832, 896, 960, 1024 }
local S24 = { 0, 4, 8, 12, 16, 20, 24, 28, 36, 44, 52, 64, 76, 92, 108, 128 }
local L16 = { 0, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88, 100, 112, 124, 136, 148, 160, 172, 184, 196, 212, 228, 244, 260, 280, 300, 320, 344, 368, 396, 424, 456, 492, 532, 572,
  616, 664, 716, 772, 832, 896, 960, 1024 }
local S16 = { 0, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 60, 72, 88, 108, 128 }
local L8 = { 0, 12, 24, 36, 48, 60, 72, 84, 96, 108, 120, 132, 144, 156, 172, 188, 204, 220, 236, 252, 268, 288, 308, 328, 348, 372, 396, 420, 448, 476, 508, 544, 580, 620, 664,
  712, 764, 820, 880, 944, 1024 }
local S8 = { 0, 4, 8, 12, 16, 20, 24, 28, 36, 44, 52, 60, 72, 88, 108, 128 }
local LONG = { [0] = L96, L96, L64, L48, L48, L32, L24, L24, L16, L16, L16, L8, L8 }
local SHORT = { [0] = S96, S96, S96, S48, S48, S48, S24, S24, S16, S16, S16, S8, S8 }
local TNS_LONG = { [0] = 31, 31, 34, 40, 42, 51, 46, 46, 42, 42, 42, 39, 39 }
local TNS_SHORT = { [0] = 9, 9, 10, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14 }
local POW43 = {}
for v = 0, 8191 do POW43[v] = v ^ (4 / 3) end

-- ---------------------------------------------------------------- the transform
-- An FFT of size n, its sign positive (an inverse transform without the 1/n), in place on 1-based re/im.
local plans = {}
local function plan(n)
  local p = plans[n]
  if p then return p end
  p = { n = n, rev = {}, c = {}, s = {} }
  local levels = floor(math.log(n, 2) + 0.5)
  for i = 0, n - 1 do
    local r, x = 0, i
    for _ = 1, levels do r = r * 2 + x % 2; x = floor(x / 2) end
    p.rev[i + 1] = r + 1
  end
  for j = 0, n / 2 - 1 do p.c[j] = cos(2 * pi * j / n); p.s[j] = sin(2 * pi * j / n) end
  plans[n] = p
  return p
end
local function ifft(re, im, p)
  local n, rev, ct, st = p.n, p.rev, p.c, p.s
  for i = 1, n do
    local j = rev[i]
    if j > i then re[i], re[j] = re[j], re[i]; im[i], im[j] = im[j], im[i] end
  end
  local size = 2
  while size <= n do
    local half = size / 2
    local step = n / size
    for start = 1, n, size do
      local t = 0
      for k = start, start + half - 1 do
        local wr, wi = ct[t], st[t]
        t += step
        local b = k + half
        local br, bi = re[b], im[b]
        local tr, ti = br * wr - bi * wi, br * wi + bi * wr
        local ar, ai = re[k], im[k]
        re[b], im[b] = ar - tr, ai - ti
        re[k], im[k] = ar + tr, ai + ti
      end
    end
    size *= 2
  end
end
-- DCT-IV of M values through an inverse FFT of M/2 (worked out for this file):
--   u[m] = (X[2m] - i X[M-1-2m]) e^(i pi m / M);  U = sum u[m] e^(2 pi i n m / (M/2));
--   Z[n] = U[n] e^(i pi (n + 1/4) / M);  C[2n] = Re Z[n], C[M-1-2n] = Im Z[n]
local twiddles = {}
local function dct4(X, C, M, xOff)
  xOff = xOff or 0
  local L = M / 2
  local t = twiddles[M]
  if not t then
    t = { pc = {}, ps = {}, qc = {}, qs = {}, re = table.create(L, 0), im = table.create(L, 0), p = plan(L) }
    for m = 0, L - 1 do
      t.pc[m] = cos(pi * m / M); t.ps[m] = sin(pi * m / M)
      t.qc[m] = cos(pi * (m + 0.25) / M); t.qs[m] = sin(pi * (m + 0.25) / M)
    end
    twiddles[M] = t
  end
  local re, im, pc, ps, qc, qs = t.re, t.im, t.pc, t.ps, t.qc, t.qs
  for m = 0, L - 1 do
    local a, b = X[xOff + 2 * m + 1], X[xOff + M - 2 * m]
    local c, s = pc[m], ps[m]
    -- (a - ib)(c + is) = a c + b s + i (a s - b c)
    re[m + 1], im[m + 1] = a * c + b * s, a * s - b * c
  end
  ifft(re, im, t.p)
  for n = 0, L - 1 do
    local ur, ui = re[n + 1], im[n + 1]
    local c, s = qc[n], qs[n]
    C[2 * n + 1] = ur * c - ui * s
    C[M - 2 * n] = ur * s + ui * c
  end
end
-- IMDCT: N = 2M samples from M coefficients, with the standard's 2/N
local function imdct(X, Y, M, xOff, scratch)
  dct4(X, scratch, M, xOff)
  local h, scale = M / 2, 2 / (2 * M)
  for n = 0, h - 1 do Y[n + 1] = scratch[n + h + 1] * scale end
  for n = h, 3 * h - 1 do Y[n + 1] = -scratch[3 * h - n] * scale end
  for n = 3 * h, 2 * M - 1 do Y[n + 1] = -scratch[n - 3 * h + 1] * scale end
end
AAC.test = { dct4 = dct4, imdct = imdct }

-- ---------------------------------------------------------------- windows
local function bessel0(x)
  local sum, term, k = 1, 1, 1
  while term > 1e-12 * sum do
    term *= (x / (2 * k)) ^ 2
    sum += term
    k += 1
  end
  return sum
end
local function windows(N, alpha)
  local sine, kbd = {}, {}
  for n = 0, N - 1 do sine[n + 1] = sin(pi * (n + 0.5) / N) end
  local w, total = {}, 0
  for n = 0, N / 2 do
    local x = (n - N / 4) / (N / 4)
    w[n] = bessel0(pi * alpha * sqrt(math.max(0, 1 - x * x)))
    total += w[n]
  end
  local acc = 0
  for n = 0, N / 2 - 1 do
    acc += w[n]
    local value = sqrt(acc / total)
    kbd[n + 1] = value
    kbd[N - n] = value
  end
  return { [0] = sine, [1] = kbd }
end
local LW, SW = windows(2048, 4), windows(256, 6)

-- ---------------------------------------------------------------- one channel's stream
local function newIcs() return { groupLen = {}, cb = {}, sf = {}, tnsN = {}, tnsLen = {}, tnsOrder = {}, tnsDir = {}, tnsCoef = {}, pk = {}, pa = {} } end
local function icsInfo(ics, rate)
  bit1()
  ics.seq = bits(2)
  ics.shape = bit1()
  if ics.seq == 2 then
    ics.maxSfb = bits(4)
    local grouping = bits(7)
    ics.numWindows = 8
    ics.swb = SHORT[rate]
    local groups = 1
    ics.groupLen[1] = 1
    for i = 6, 0, -1 do
      if band(rshift(grouping, i), 1) == 1 then ics.groupLen[groups] += 1 else groups += 1; ics.groupLen[groups] = 1 end
    end
    ics.numGroups = groups
  else
    ics.maxSfb = bits(6)
    ics.numWindows, ics.numGroups = 1, 1
    ics.groupLen[1] = 1
    ics.swb = LONG[rate]
    if bit1() == 1 then error("aac: prediction (not AAC-LC)") end
  end
  ics.numSwb = #ics.swb - 1
  if ics.maxSfb > ics.numSwb then error("aac: max_sfb") end
end
local function tnsData(ics)
  local long = ics.seq ~= 2
  for w = 0, ics.numWindows - 1 do
    local count = bits(long and 2 or 1)
    ics.tnsN[w] = count
    if count > 0 then
      local res = bit1()
      for f = 1, count do
        local key = w * 4 + f
        ics.tnsLen[key] = bits(long and 6 or 4)
        local order = bits(long and 5 or 3)
        ics.tnsOrder[key] = order
        if order > 0 then
          ics.tnsDir[key] = bit1()
          local compress = bit1()
          local width = res + 3 - compress
          local half = 2 ^ (res + 2)
          local iq, iqm = (half - 0.5) / (pi / 2), (half + 0.5) / (pi / 2)
          for i = 1, order do
            local c = bits(width)
            if c >= 2 ^ (width - 1) then c -= 2 ^ width end
            ics.tnsCoef[key * 32 + i] = sin(c / (c >= 0 and iq or iqm))
          end
        end
      end
    end
  end
end
local function stream(ics, common, rate, q)
  local gain = bits(8)
  if not common then icsInfo(ics, rate) end
  local cb, sf, groups, maxSfb = ics.cb, ics.sf, ics.numGroups, ics.maxSfb
  -- sections
  local long = ics.seq ~= 2
  local width, esc = long and 5 or 3, long and 31 or 7
  for g = 0, groups - 1 do
    local k = 0
    while k < maxSfb do
      local book = bits(4)
      local length = 0
      local incr = bits(width)
      while incr == esc do length += incr; incr = bits(width) end
      length += incr
      if length == 0 or k + length > maxSfb or book == 12 then error("aac: section") end
      for sfb = k, k + length - 1 do cb[g * 64 + sfb] = book end
      k += length
    end
  end
  -- scale factors
  local scale, position, noise, first = gain, 0, gain - 90, true
  for g = 0, groups - 1 do
    for sfb = 0, maxSfb - 1 do
      local key = g * 64 + sfb
      local book = cb[key]
      if book == 0 then sf[key] = 0
      elseif book == 14 or book == 15 then position += huff(SFZ, SFO) - 61; sf[key] = position
      elseif book == 13 then
        if first then noise += bits(9) - 256; first = false else noise += huff(SFZ, SFO) - 61 end
        sf[key] = noise
      else
        scale += huff(SFZ, SFO) - 61
        sf[key] = scale
      end
    end
  end
  -- pulses (long windows only)
  ics.pulses = 0
  if bit1() == 1 then
    if not long then error("aac: pulse in short") end
    local count = bits(2) + 1
    local k = ics.swb[bits(6) + 1]
    for i = 1, count do
      k += bits(5)
      ics.pk[i], ics.pa[i] = k, bits(4)
    end
    ics.pulses = count
  end
  ics.tnsOn = bit1() == 1
  if ics.tnsOn then tnsData(ics) end
  if bit1() == 1 then error("aac: gain control (not AAC-LC)") end
  -- the spectrum, quantized
  for i = 1, 1024 do q[i] = 0 end
  local swb = ics.swb
  local win = 0
  for g = 0, groups - 1 do
    local glen = ics.groupLen[g + 1]
    for sfb = 0, maxSfb - 1 do
      local book = cb[g * 64 + sfb]
      if book >= 1 and book <= 11 then
        local B = BOOK[book]
        local zero, one, values, dim, unsigned = B.zero, B.one, B.values, B.dim, B.unsigned
        local from, to = swb[sfb + 1], swb[sfb + 2]
        for w = 0, glen - 1 do
          local base = (win + w) * 128
          local k = from
          while k < to do
            local index = huff(zero, one)
            if dim == 4 then
              local v = index * 4
              local a, b, c, d = values[v - 3], values[v - 2], values[v - 1], values[v]
              if unsigned then
                if a ~= 0 and bit1() == 1 then a = -a end
                if b ~= 0 and bit1() == 1 then b = -b end
                if c ~= 0 and bit1() == 1 then c = -c end
                if d ~= 0 and bit1() == 1 then d = -d end
              end
              local at = base + k
              q[at + 1], q[at + 2], q[at + 3], q[at + 4] = a, b, c, d
              k += 4
            else
              local v = index * 2
              local y, z = values[v - 1], values[v]
              if unsigned then
                if y ~= 0 and bit1() == 1 then y = -y end
                if z ~= 0 and bit1() == 1 then z = -z end
              end
              if book == 11 then
                if y == 16 or y == -16 then
                  local n = 4
                  while bit1() == 1 do n += 1; if n > 20 then error("aac: escape") end end
                  local e = 2 ^ n + bits(n)
                  y = y < 0 and -e or e
                end
                if z == 16 or z == -16 then
                  local n = 4
                  while bit1() == 1 do n += 1; if n > 20 then error("aac: escape") end end
                  local e = 2 ^ n + bits(n)
                  z = z < 0 and -e or e
                end
              end
              local at = base + k
              q[at + 1], q[at + 2] = y, z
              k += 2
            end
          end
        end
      end
    end
    win += glen
  end
end
-- quantized -> real values; noise bands filled; intensity bands left for the pair
local seed = 1
local function random()
  seed = (seed * 1664525 + 1013904223) % 4294967296
  return seed / 2147483648 - 1
end
local function dequantize(ics, q, spec)
  for i = 1, 1024 do spec[i] = 0 end
  if ics.pulses > 0 then
    for i = 1, ics.pulses do
      local at = ics.pk[i] + 1
      local v = q[at]
      if v < 0 then q[at] = v - ics.pa[i] else q[at] = v + ics.pa[i] end
    end
  end
  local swb, cb, sf = ics.swb, ics.cb, ics.sf
  local win = 0
  for g = 0, ics.numGroups - 1 do
    local glen = ics.groupLen[g + 1]
    for sfb = 0, ics.maxSfb - 1 do
      local key = g * 64 + sfb
      local book = cb[key]
      local from, to = swb[sfb + 1], swb[sfb + 2]
      if book >= 1 and book <= 11 then
        local gain = 2 ^ (0.25 * (sf[key] - 100))
        for w = 0, glen - 1 do
          local base = (win + w) * 128
          for k = base + from + 1, base + to do
            local v = q[k]
            if v > 0 then spec[k] = (POW43[v] or v ^ (4 / 3)) * gain
            elseif v < 0 then spec[k] = -(POW43[-v] or (-v) ^ (4 / 3)) * gain end
          end
        end
      elseif book == 13 then
        for w = 0, glen - 1 do
          local base = (win + w) * 128
          local energy = 0
          for k = base + from + 1, base + to do
            local r = random()
            spec[k] = r
            energy += r * r
          end
          local scale = 2 ^ (0.25 * sf[key]) / sqrt(math.max(energy, 1e-9))
          for k = base + from + 1, base + to do spec[k] *= scale end
        end
      end
    end
    win += glen
  end
end
-- TNS: each filter run over its bands, from the bottom up or the top down
local lpc, tmp = {}, {}
local function tns(ics, spec, rate)
  if not ics.tnsOn then return end
  local long = ics.seq ~= 2
  local most = long and TNS_LONG[rate] or TNS_SHORT[rate]
  local swb, numSwb, maxSfb = ics.swb, ics.numSwb, ics.maxSfb
  for w = 0, ics.numWindows - 1 do
    local top = numSwb
    local base = long and 0 or w * 128
    for f = 1, ics.tnsN[w] or 0 do
      local key = w * 4 + f
      local bottom = math.max(top - ics.tnsLen[key], 0)
      local order = ics.tnsOrder[key]
      if order > 0 then
        for m = 1, order do
          local r = ics.tnsCoef[key * 32 + m]
          for i = 1, m - 1 do tmp[i] = lpc[i] + r * lpc[m - i] end
          for i = 1, m - 1 do lpc[i] = tmp[i] end
          lpc[m] = r
        end
        local startBand = math.min(bottom, most, maxSfb)
        local endBand = math.min(top, most, maxSfb)
        local start, stop = swb[startBand + 1], swb[endBand + 1]
        local size = stop - start
        if size > 0 then
          local inc, pos = 1, base + start + 1
          if ics.tnsDir[key] == 1 then inc, pos = -1, base + stop end
          for m = 0, size - 1 do
            local acc = spec[pos]
            for i = 1, math.min(m, order) do acc -= spec[pos - i * inc] * lpc[i] end
            spec[pos] = acc
            pos += inc
          end
        end
      end
      top = bottom
    end
  end
end
-- the filterbank: the frame's 1024 samples out, the next frame's half kept
local function filterbank(ics, spec, ch, out)
  local seq, shape, prev = ics.seq, ics.shape, ch.prevShape
  local time, scratch, short = ch.time, ch.scratch, ch.short
  local overlap = ch.overlap
  if seq == 2 then
    for i = 1, 2048 do time[i] = 0 end
    for j = 0, 7 do
      imdct(spec, short, 128, j * 128, scratch)
      local left = j == 0 and SW[prev] or SW[shape]
      local right = SW[shape]
      local at = 448 + j * 128
      for n = 1, 128 do time[at + n] += short[n] * left[n] end
      for n = 129, 256 do time[at + n] += short[n] * right[n] end
    end
  else
    imdct(spec, time, 1024, 0, scratch)
    local left, right = LW[prev], LW[shape]
    if seq == 3 then
      for n = 1, 448 do time[n] = 0 end
      local sl = SW[prev]
      for n = 449, 576 do time[n] *= sl[n - 448] end
    else
      for n = 1, 1024 do time[n] *= left[n] end
    end
    if seq == 1 then
      local sr = SW[shape]
      for n = 1473, 1600 do time[n] *= sr[n - 1472 + 128] end
      for n = 1601, 2048 do time[n] = 0 end
    else
      for n = 1025, 2048 do time[n] *= right[n] end
    end
  end
  for n = 1, 1024 do
    out[n] = time[n] + overlap[n]
    overlap[n] = time[n + 1024]
  end
  ch.prevShape = shape
end

-- ---------------------------------------------------------------- frames
local function newChannel()
  return { q = table.create(1024, 0), spec = table.create(1024, 0), time = table.create(2048, 0), scratch = table.create(1024, 0),
    short = table.create(256, 0), overlap = table.create(1024, 0), out = table.create(1024, 0), prevShape = 0, ics = newIcs() }
end
-- one raw_data_block: SCE/CPE (and fill/data elements skipped) up to END
local function frame(dec)
  local rate, chans = dec.rate, dec.channels
  local used = 0
  while true do
    local id = bits(3)
    if id == 7 then break end
    if id == 0 or id == 3 then
      bits(4)
      used += 1
      local ch = chans[used] or chans[1]
      stream(ch.ics, false, rate, ch.q)
      dequantize(ch.ics, ch.q, ch.spec)
      tns(ch.ics, ch.spec, rate)
      filterbank(ch.ics, ch.spec, ch, ch.out)
    elseif id == 1 then
      bits(4)
      local a, b = chans[used + 1], chans[used + 2]
      used += 2
      if not (a and b) then error("aac: more channels than set up") end
      local common = bit1() == 1
      local msMask = 0
      local ms = dec.ms
      if common then
        icsInfo(a.ics, rate)
        -- (one window for both: the second channel's stream reads none of its own)
        local one, other = a.ics, b.ics
        other.seq, other.shape, other.maxSfb, other.numWindows, other.numGroups = one.seq, one.shape, one.maxSfb, one.numWindows, one.numGroups
        other.swb, other.numSwb = one.swb, one.numSwb
        for i = 1, one.numGroups do other.groupLen[i] = one.groupLen[i] end
        msMask = bits(2)
        if msMask == 1 then
          for g = 0, a.ics.numGroups - 1 do
            for sfb = 0, a.ics.maxSfb - 1 do ms[g * 64 + sfb] = bit1() end
          end
        end
      end
      stream(a.ics, common, rate, a.q)
      stream(b.ics, common, rate, b.q)
      dequantize(a.ics, a.q, a.spec)
      dequantize(b.ics, b.q, b.spec)
      -- mid/side, then intensity: right from left, by band
      if common then
        local ics, swb = b.ics, b.ics.swb
        local win = 0
        for g = 0, ics.numGroups - 1 do
          local glen = ics.groupLen[g + 1]
          for sfb = 0, ics.maxSfb - 1 do
            local key = g * 64 + sfb
            local book = ics.cb[key]
            local from, to = swb[sfb + 1], swb[sfb + 2]
            local msUsed = msMask == 2 or (msMask == 1 and ms[key] == 1)
            if book == 14 or book == 15 then
              local scale = 0.5 ^ (0.25 * ics.sf[key])
              local sign = (book == 15 and 1 or -1) * ((msMask == 1 and ms[key] == 1) and -1 or 1)
              for w = 0, glen - 1 do
                local base = (win + w) * 128
                for k = base + from + 1, base + to do b.spec[k] = a.spec[k] * scale * sign end
              end
            elseif msUsed and book ~= 13 and a.ics.cb[key] ~= 13 then
              for w = 0, glen - 1 do
                local base = (win + w) * 128
                for k = base + from + 1, base + to do
                  local m, s = a.spec[k], b.spec[k]
                  a.spec[k], b.spec[k] = m + s, m - s
                end
              end
            end
          end
          win += glen
        end
      end
      tns(a.ics, a.spec, rate)
      tns(b.ics, b.spec, rate)
      filterbank(a.ics, a.spec, a, a.out)
      filterbank(b.ics, b.spec, b, b.out)
    elseif id == 6 then
      local count = bits(4)
      if count == 15 then count += bits(8) - 1 end
      RP += count * 8
    elseif id == 4 then
      bits(4)
      local align = bit1() == 1
      local count = bits(8)
      if count == 255 then count += bits(8) end
      if align then RP = math.ceil(RP / 8) * 8 end
      RP += count * 8
    else
      error("aac: element " .. id .. " not handled")
    end
  end
  return used
end

-- ---------------------------------------------------------------- MP4 (fragmented): the setup and the frames
local function u32(s, i) return (string.unpack(">I4", s, i)) end
local function walk(s, from, to, each)
  local i = from
  while i + 7 <= to do
    local size = u32(s, i)
    local kind = string.sub(s, i + 4, i + 7)
    local head = 8
    if size == 1 then size = string.unpack(">I8", s, i + 8); head = 16 elseif size == 0 then size = to - i + 1 end
    if size < head then break end
    each(kind, i + head, i + size - 1, i)
    i += size
  end
end
local function descriptor(s, i)
  local tag = string.byte(s, i)
  local length = 0
  i += 1
  for _ = 1, 4 do
    local b = string.byte(s, i)
    i += 1
    length = length * 128 + band(b, 0x7F)
    if b < 0x80 then break end
  end
  return tag, length, i
end
-- the AudioSpecificConfig in the init segment's esds: object type, rate index, channels
function AAC.config(init)
  local found
  local function dig(kind, from, to)
    if found then return end
    if kind == "moov" or kind == "trak" or kind == "mdia" or kind == "minf" or kind == "stbl" then walk(init, from, to, dig)
    elseif kind == "stsd" then walk(init, from + 8, to, dig)
    elseif kind == "mp4a" then walk(init, from + 28, to, dig)
    elseif kind == "esds" then
      local i = from + 4
      local tag, length
      tag, length, i = descriptor(init, i)
      if tag == 3 then
        i += 2
        local flags = string.byte(init, i)
        i += 1
        if band(flags, 0x80) ~= 0 then i += 2 end
        if band(flags, 0x40) ~= 0 then i += 1 + string.byte(init, i) end
        if band(flags, 0x20) ~= 0 then i += 2 end
        tag, length, i = descriptor(init, i)
      end
      if tag == 4 then
        i += 13
        tag, length, i = descriptor(init, i)
      end
      if tag == 5 then
        local a, b = string.byte(init, i, i + 1)
        local object = rshift(a, 3)
        local rate = band(a, 7) * 2 + rshift(b, 7)
        local channels = band(rshift(b, 3), 15)
        found = { object = object, rate = rate, channels = channels }
      end
      local _ = length
    end
  end
  walk(init, 1, #init, dig)
  return found
end
-- every frame of one media segment (moof + mdat, any number of them): its bytes, in order
function AAC.frames(segment, out)
  out = out or {}
  local sizes = {}
  walk(segment, 1, #segment, function(kind, from, to)
    if kind == "moof" then
      table.clear(sizes)
      walk(segment, from, to, function(k2, f2, t2)
        if k2 ~= "traf" then return end
        local default = 0
        walk(segment, f2, t2, function(k3, f3)
          if k3 == "tfhd" then
            local flags = band(u32(segment, f3), 0xFFFFFF)
            local i = f3 + 8
            if band(flags, 0x01) ~= 0 then i += 8 end
            if band(flags, 0x02) ~= 0 then i += 4 end
            if band(flags, 0x08) ~= 0 then i += 4 end
            if band(flags, 0x10) ~= 0 then default = u32(segment, i) end
          elseif k3 == "trun" then
            local flags = band(u32(segment, f3), 0xFFFFFF)
            local count = u32(segment, f3 + 4)
            local i = f3 + 8
            if band(flags, 0x001) ~= 0 then i += 4 end
            if band(flags, 0x004) ~= 0 then i += 4 end
            for _ = 1, count do
              if band(flags, 0x100) ~= 0 then i += 4 end
              local size = default
              if band(flags, 0x200) ~= 0 then size = u32(segment, i); i += 4 end
              if band(flags, 0x400) ~= 0 then i += 4 end
              if band(flags, 0x800) ~= 0 then i += 4 end
              sizes[#sizes + 1] = size
            end
          end
        end)
      end)
    elseif kind == "mdat" then
      local at = from
      for _, size in ipairs(sizes) do
        if size > 0 and at + size - 1 <= to then out[#out + 1] = string.sub(segment, at, at + size - 1) end
        at += size
      end
    end
  end)
  return out
end

-- ---------------------------------------------------------------- a decoder, and WAV out
function AAC.decoder(config)
  prepare()
  seed = 1                             -- (the noise starts the same each time: the same song decodes the same)
  local channels = math.clamp(config.channels or 2, 1, 2)
  local dec = { rate = config.rate or 4, channels = {}, count = channels, ms = {} }
  for i = 1, channels do dec.channels[i] = newChannel() end
  dec.sampleRate = RATES[dec.rate] or 44100
  -- one frame's bytes -> true, each channel's 1024 samples in channel.out (silence on a frame that will not decode)
  function dec.decode(data)
    RB, RP = buffer.fromstring(data), 0
    local ok, why = pcall(frame, dec)
    if not ok then
      for _, ch in ipairs(dec.channels) do
        for n = 1, 1024 do ch.out[n] = ch.overlap[n] * 0; ch.overlap[n] = 0 end
      end
      dec.errors = (dec.errors or 0) + 1
      dec.lastError = why
    end
    return ok
  end
  return dec
end
-- a WAV file's header for `bytes` of 16-bit samples
local function wavHeader(rate, channels, bytes)
  return "RIFF" .. string.pack("<I4", 36 + bytes) .. "WAVEfmt " .. string.pack("<I4I2I2I4I4I2I2", 16, 1, channels, rate, rate * channels * 2, channels * 2, 16)
    .. "data" .. string.pack("<I4", bytes)
end
AAC.wavHeader = wavHeader
-- the frame just decoded, as 16-bit samples (interleaved), into `out` at byte `at`
local writei16 = buffer.writei16
local function putFrame(dec, out, at)
  local left = dec.channels[1].out
  if dec.count == 2 then
    local right = dec.channels[2].out
    for n = 1, 1024 do
      local l, r = left[n], right[n]
      l = l > 32767 and 32767 or (l < -32768 and -32768 or l)
      r = r > 32767 and 32767 or (r < -32768 and -32768 or r)
      writei16(out, at, l >= 0 and floor(l + 0.5) or -floor(-l + 0.5))
      writei16(out, at + 2, r >= 0 and floor(r + 0.5) or -floor(-r + 0.5))
      at += 4
    end
  else
    for n = 1, 1024 do
      local l = left[n]
      l = l > 32767 and 32767 or (l < -32768 and -32768 or l)
      writei16(out, at, l >= 0 and floor(l + 0.5) or -floor(-l + 0.5))
      at += 2
    end
  end
end
local function setup(init)
  local config = AAC.config(init)
  if not config then return nil, "no AAC setup in the stream" end
  if config.object ~= 2 and config.object ~= 5 and config.object ~= 29 then return nil, "not AAC-LC (object " .. tostring(config.object) .. ")" end
  return AAC.decoder(config)
end
-- init + segments -> a WAV file's bytes (16-bit). progress(fraction) now and then; yield() between batches.
function AAC.toWav(init, segments, progress, yield)
  local dec, why = setup(init)
  if not dec then return nil, why end
  local frames = {}
  for _, segment in ipairs(segments) do AAC.frames(segment, frames) end
  if #frames == 0 then return nil, "no frames in the stream" end
  local channels = dec.count
  local bytes = #frames * 1024 * channels * 2
  local out = buffer.create(44 + bytes)
  buffer.writestring(out, 0, wavHeader(dec.sampleRate, channels, bytes))
  local at = 44
  local started = os.clock()
  for index, data in ipairs(frames) do
    dec.decode(data)
    putFrame(dec, out, at)
    at += 1024 * channels * 2
    if yield and os.clock() - started > 0.012 then
      if progress then progress(index / #frames) end
      yield()
      started = os.clock()
    end
  end
  if progress then progress(1) end
  return buffer.tostring(out), nil, { frames = #frames, errors = dec.errors or 0, lastError = dec.lastError, rate = dec.sampleRate, channels = channels }
end

-- Decoded as it arrives, and handed over a piece at a time, so a song plays a few seconds after it
-- is asked for instead of after all of it is decoded. Each piece is `piece` seconds of WAV plus
-- `overlap` more: the start of the next one, for the player to cross into it without a gap.
--   opts.segment(i)  -> the i-th media segment's bytes, nil after the last (it may wait for a download)
--   opts.onPiece(index, wav, startSeconds, ownSeconds, fileSeconds, last)
--   opts.progress(decodedSeconds), opts.yield(), opts.cancelled() -> true to stop
--   opts.budget: seconds of work between yields (opts.first for the first piece, so it starts quickly)
--   opts.firstPiece: a shorter first piece (seconds), so the song starts sooner
-- -> true, nil, info | false, why
function AAC.stream(init, opts)
  local dec, why = setup(init)
  if not dec then return false, why end
  local channels, rate = dec.count, dec.sampleRate
  local frameBytes = 1024 * channels * 2
  local pieceFrames = math.max(8, floor((opts.piece or 12) * rate / 1024 + 0.5))
  local firstFrames = math.max(8, floor((opts.firstPiece or opts.piece or 12) * rate / 1024 + 0.5))
  local overlapFrames = math.max(1, math.ceil((opts.overlap or 0.06) * rate / 1024))
  local function ownFrames(index) return index == 1 and firstFrames or pieceFrames end
  local size = (math.max(pieceFrames, firstFrames) + overlapFrames) * frameBytes
  local function newPiece(index, first) return { index = index, first = first, frames = 0, buf = buffer.create(size) } end
  local current, following = newPiece(1, 0), nil
  local decoded, count = 0, 0
  local budget = opts.first or 0.03
  local started = os.clock()
  local yield = opts.yield or task.wait
  local function emit(piece, last)
    local bytes = piece.frames * frameBytes
    local wav = wavHeader(rate, channels, bytes) .. buffer.readstring(piece.buf, 0, bytes)
    piece.buf = nil
    count += 1
    local own = (last and piece.frames or ownFrames(piece.index)) * 1024 / rate
    opts.onPiece(piece.index, wav, piece.first * 1024 / rate, own, piece.frames * 1024 / rate, last)
    budget = opts.budget or 0.006
  end
  local i = 0
  local list = {}
  while true do
    i += 1
    local segment = opts.segment(i)
    if segment == nil then break end
    if opts.cancelled and opts.cancelled() then return false, "cancelled" end
    table.clear(list)
    AAC.frames(segment, list)
    for _, data in ipairs(list) do
      dec.decode(data)
      local slot = decoded - current.first
      local own = ownFrames(current.index)
      putFrame(dec, current.buf, slot * frameBytes)
      current.frames = slot + 1
      if slot >= own then
        -- (in the overlap: also the head of the next piece)
        following = following or newPiece(current.index + 1, current.first + own)
        buffer.copy(following.buf, (slot - own) * frameBytes, current.buf, slot * frameBytes, frameBytes)
        following.frames = slot - own + 1
      end
      decoded += 1
      if current.frames == own + overlapFrames then
        emit(current, false)
        current, following = following, nil
      end
      if os.clock() - started > budget then
        if opts.progress then opts.progress(decoded * 1024 / rate) end
        yield()
        if opts.cancelled and opts.cancelled() then return false, "cancelled" end
        started = os.clock()
      end
    end
  end
  if decoded == 0 then return false, "no frames in the stream" end
  if current.frames > 0 then emit(current, true) end
  if opts.progress then opts.progress(decoded * 1024 / rate) end
  return true, nil, { frames = decoded, errors = dec.errors or 0, lastError = dec.lastError, rate = rate, channels = channels, pieces = count,
    seconds = decoded * 1024 / rate }
end
end

do -- 45_music.lua
-- ============================================================================
--  45 music    a music player in every look: SoundCloud, Audius, your own
--              files, or a link; a queue, likes, playlists, history, sound
--              shaping, crossfades, a mini player and keys
--
--  How each source plays (measured 2026-10-21 from the game client):
--    * SoundCloud: the client id is read from soundcloud.com's own scripts (no
--      key to sign up for; kept 12 h, read again on a 401/403). Search is
--      api-v2 /search/tracks. Streams are AAC in fragmented MP4 over HLS (96 of
--      100 tracks had nothing else), which Roblox will not load, so 44_aac.lua
--      decodes them as they download, in 12 s pieces (the first 6 s) with 0.3 s of overlap: the
--      first piece plays a few seconds after the click, and the player crosses
--      from piece to piece on that overlap. The pieces stay on disk: the next
--      play starts at once. An MP3 stream, where a track still has one, is used
--      as it is. A track behind DRM (#EXT-X-KEY) says so and is skipped.
--    * Audius: api.audius.co search, trending and /stream (an MP3, at once).
--    * Files: .mp3 .ogg .wav .flac in workspace/BasedHub/music.
--    * Link: a direct audio URL, or a Roblox audio id.
--  Three voices (Sounds) share one SoundGroup that carries the effects, so a
--  piece change, a crossfade between songs and the sound settings all agree.
--  What plays "in front" (Music.front) is this player, or what this PC plays
--  (48_pc); the words in time are 47_lyrics, the card and island 49_card.
-- ============================================================================
local S, util, Motion, UI, Config, Window, fs = B.S, B.util, B.Motion, B.UI, B.Config, B.Window, B.fs
local Http = S.HttpService

local Music = { queue = {}, index = 0, now = nil, state = "idle", status = nil, results = {}, resultsFor = nil, changed = B.Signal.new() }
B.Music = Music

local FOLDER = fs.path("music")
local CACHE = fs.path("music/cache")
local ART = fs.path("music/art")
local INDEX = fs.path("music/cache.json")
local APP = "BASEDHUB"
local UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"

-- ---------------------------------------------------------------- the web
local function fetch(url)
  local send = (type(request) == "function" and request) or (type(http_request) == "function" and http_request) or nil
  if send then
    local ok, response = pcall(send, { Url = url, Method = "GET", Headers = { ["User-Agent"] = UA } })
    if ok and type(response) == "table" then return response.StatusCode or 0, response.Body end
    return -1, nil
  end
  local ok, body = pcall(game.HttpGet, game, url)
  return ok and 200 or -1, ok and body or nil
end
local function json(text)
  if type(text) ~= "string" then return nil end
  local ok, value = pcall(Http.JSONDecode, Http, text)
  return ok and value or nil
end
local function encode(text) return Http:UrlEncode(tostring(text or "")) end
local function token() return string.format("%06x", math.random(0, 0xFFFFFF)) end

-- ---------------------------------------------------------------- the cache: kept songs, the least lately played go first past the size set
local index
local function cacheIndex()
  if not index then
    index = fs.readJson(INDEX)
    if type(index) ~= "table" or type(index.files) ~= "table" then index = { files = {} } end
  end
  return index
end
local function removeEntry(path)
  if fs.isdir(path) then
    for _, file in ipairs(fs.list(path)) do fs.remove(file) end
    if type(delfolder) == "function" then pcall(delfolder, path) end
  else
    fs.remove(path)
  end
end
local function present(path) return fs.exists(path) or fs.isdir(path) end
local function cacheTouch(path, size)
  local data = cacheIndex()
  local old = data.files[path]
  data.files[path] = { size = size or (old and old.size) or 0, used = os.time() }
  local limit = (Config.get("music.cacheMb") or 600) * 1048576
  local total, list = 0, {}
  for file, info in pairs(data.files) do
    if present(file) then total += info.size or 0; list[#list + 1] = { file, info } else data.files[file] = nil end
  end
  table.sort(list, function(a, b) return (a[2].used or 0) < (b[2].used or 0) end)
  for _, item in ipairs(list) do
    if total <= limit then break end
    if item[1] ~= path and not (Music.now and string.find(item[1], Music.now.key, 1, true)) then
      removeEntry(item[1])
      total -= item[2].size or 0
      data.files[item[1]] = nil
    end
  end
  fs.writeJson(INDEX, data)
end
function Music.cacheSize()
  local total, count = 0, 0
  for file, info in pairs(cacheIndex().files) do
    if present(file) then total += info.size or 0; count += 1 end
  end
  return total, count
end
function Music.clearCache()
  for file in pairs(cacheIndex().files) do
    if not (Music.now and string.find(file, Music.now.key, 1, true)) then removeEntry(file); index.files[file] = nil end
  end
  fs.writeJson(INDEX, index)
end
local assets = {}
local function asset(path)
  if assets[path] then return assets[path] end
  if type(getcustomasset) ~= "function" or not fs.exists(path) then return nil end
  local ok, id = pcall(getcustomasset, path)
  B.identity()
  if ok and id then assets[path] = id; return id end
  return nil
end

-- ---------------------------------------------------------------- SoundCloud
local SC = { id = nil, at = 0 }
local function scId(fresh)
  if SC.id and not fresh and os.time() - SC.at < 12 * 3600 then return SC.id end
  local saved = fs.readJson(fs.path("music/soundcloud.json"))
  if not fresh and type(saved) == "table" and type(saved.id) == "string" and os.time() - (saved.at or 0) < 12 * 3600 then
    SC.id, SC.at = saved.id, saved.at
    return SC.id
  end
  local code, html = fetch("https://soundcloud.com/")
  if code ~= 200 or not html then return nil end
  local scripts = {}
  for src in string.gmatch(html, '<script crossorigin src="(https://a%-v2%.sndcdn%.com/assets/[^"]+%.js)"') do scripts[#scripts + 1] = src end
  for i = #scripts, 1, -1 do
    local _, js = fetch(scripts[i])
    local id = js and (string.match(js, 'client_id:"([%w%-_]+)"') or string.match(js, 'client_id=([%w%-_]+)'))
    if id then
      SC.id, SC.at = id, os.time()
      fs.writeJson(fs.path("music/soundcloud.json"), { id = id, at = SC.at })
      return id
    end
  end
  return nil
end
local function scGet(url)
  local id = scId(false)
  if not id then return nil, "SoundCloud could not be reached" end
  local sep = string.find(url, "?", 1, true) and "&" or "?"
  local code, body = fetch(url .. sep .. "client_id=" .. id)
  if code == 401 or code == 403 then
    id = scId(true)
    if not id then return nil, "SoundCloud refused the key" end
    code, body = fetch(url .. sep .. "client_id=" .. id)
  end
  if code ~= 200 then return nil, "SoundCloud said " .. tostring(code) end
  return body
end
local function scTrack(t)
  local media = type(t.media) == "table" and t.media.transcodings or {}
  local playable, preview = false, false
  for _, tr in ipairs(media) do
    local mime = tostring(tr.format and tr.format.mime_type or "")
    if string.find(mime, "audio/mpeg", 1, true) or string.find(mime, "mp4a", 1, true) then playable = true end
    if tr.snipped then preview = true end
  end
  local art = t.artwork_url or (type(t.user) == "table" and t.user.avatar_url) or nil
  if type(art) == "string" then art = (string.gsub(art, "%-large%.", "-t300x300.")) else art = nil end
  return { source = "sc", key = "sc_" .. tostring(t.id), id = t.id, title = tostring(t.title or "?"), artist = tostring(type(t.user) == "table" and t.user.username or "SoundCloud"),
    duration = math.floor((t.full_duration or t.duration or 0) / 1000), art = art, link = t.permalink_url, auth = t.track_authorization,
    playable = playable and t.policy ~= "BLOCK", preview = preview or t.policy == "SNIP", plays = t.playback_count, raw = media }
end
function SC.search(query)
  local body, why = scGet("https://api-v2.soundcloud.com/search/tracks?q=" .. encode(query) .. "&limit=40&offset=0&linked_partitioning=1")
  if not body then return nil, why end
  local data = json(body)
  local out = {}
  for _, t in ipairs(type(data) == "table" and data.collection or {}) do out[#out + 1] = scTrack(t) end
  return out
end
function SC.related(id)
  local body = scGet("https://api-v2.soundcloud.com/tracks/" .. tostring(id) .. "/related?limit=20")
  local data = json(body)
  local out = {}
  for _, t in ipairs(type(data) == "table" and data.collection or {}) do
    local track = scTrack(t)
    if track.playable then out[#out + 1] = track end
  end
  return out
end
-- a playlist -> its init (fMP4) url and its segment urls
local function playlist(url, text)
  local function join(rel)
    if string.find(rel, "^https?://") then return rel end
    if string.sub(rel, 1, 1) == "/" then return (string.match(url, "^(https?://[^/]+)") or "") .. rel end
    return (string.match(url, "^(https?://.*/)") or "") .. rel
  end
  local init = string.match(text, '#EXT%-X%-MAP:[^\r\n]*URI="([^"]+)"')
  local urls = {}
  for line in string.gmatch(text, "[^\r\n]+") do
    line = string.match(line, "^%s*(.-)%s*$")
    if line ~= "" and string.sub(line, 1, 1) ~= "#" then urls[#urls + 1] = join(line) end
  end
  return init and join(init) or nil, urls
end
-- what to play: { mp3 = url } | { hls = playlist url, aac = true } | nil, why
function SC.stream(track)
  local mp3, hlsMp3, aac
  for _, tr in ipairs(track.raw or {}) do
    local mime = tostring(tr.format and tr.format.mime_type or "")
    local protocol = tostring(tr.format and tr.format.protocol or "")
    local isMp3 = string.find(mime, "audio/mpeg", 1, true) ~= nil
    if protocol == "progressive" and isMp3 then mp3 = mp3 or tr.url
    elseif protocol == "hls" and isMp3 then hlsMp3 = hlsMp3 or tr.url
    elseif protocol == "hls" and string.find(mime, "mp4a", 1, true) then aac = aac or tr.url end
  end
  local function resolve(url)
    local extra = track.auth and ((string.find(url, "?", 1, true) and "&" or "?") .. "track_authorization=" .. track.auth) or ""
    local data = json((scGet(url .. extra)))
    return type(data) == "table" and data.url or nil
  end
  if mp3 then
    local direct = resolve(mp3)
    if direct then return { mp3 = direct } end
  end
  if hlsMp3 then
    local url = resolve(hlsMp3)
    if url then return { hls = url } end
  end
  if aac then
    local url = resolve(aac)
    if url then return { hls = url, aac = true } end
  end
  return nil, "SoundCloud has no stream for this one"
end

-- ---------------------------------------------------------------- Audius
local AU = {}
local function auHost()
  if AU.host then return AU.host end
  local _, body = fetch("https://api.audius.co")
  local data = json(body)
  local list = type(data) == "table" and data.data
  AU.host = type(list) == "table" and #list > 0 and list[math.random(#list)] or "https://api.audius.co"
  return AU.host
end
local function auTrack(t)
  local art = type(t.artwork) == "table" and (t.artwork["480x480"] or t.artwork["150x150"]) or nil
  return { source = "au", key = "au_" .. tostring(t.id), id = t.id, title = tostring(t.title or "?"), artist = tostring(type(t.user) == "table" and t.user.name or "Audius"),
    duration = tonumber(t.duration) or 0, art = art, playable = t.is_streamable ~= false, plays = t.play_count }
end
local function auList(path)
  local code, body = fetch(auHost() .. path)
  if code ~= 200 then AU.host = nil; return nil, "Audius said " .. tostring(code) end
  local data = json(body)
  local out = {}
  for _, t in ipairs(type(data) == "table" and data.data or {}) do out[#out + 1] = auTrack(t) end
  return out
end
function AU.search(query) return auList("/v1/tracks/search?query=" .. encode(query) .. "&app_name=" .. APP) end
function AU.trending() return auList("/v1/tracks/trending?limit=40&app_name=" .. APP) end

-- ---------------------------------------------------------------- your own files, and links
local AUDIO = { mp3 = true, ogg = true, wav = true, flac = true }
function Music.files()
  fs.mkdir(FOLDER)
  local out = {}
  for _, path in ipairs(fs.list(FOLDER)) do
    local name, ext = string.match(path, "([^/]+)%.(%w+)$")
    if name and AUDIO[string.lower(ext)] then
      out[#out + 1] = { source = "file", key = "file_" .. string.gsub(name, "[^%w]", ""), title = name, artist = "Your files", duration = 0, path = path, playable = true }
    end
  end
  return out
end
function Music.link(text)
  text = string.match(tostring(text or ""), "^%s*(.-)%s*$")
  local id = string.match(text, "^rbxassetid://(%d+)$") or string.match(text, "^(%d+)$")
  if id then return { source = "roblox", key = "rbx_" .. id, title = "Roblox audio " .. id, artist = "Roblox", duration = 0, sound = "rbxassetid://" .. id, playable = true } end
  if string.find(text, "^https?://") then
    local name = string.match(text, "([^/%?]+)%.%w+%f[%?%z]") or "A link"
    return { source = "link", key = "link_" .. string.sub(string.gsub(text, "%W", ""), -40), title = name, artist = "Link", duration = 0, url = text, playable = true }
  end
  return nil
end

-- ---------------------------------------------------------------- getting a song: a job per song, shared by the player and the prefetch
-- job: { track, kind = "file" | "pieces", asset, pieces = { { asset, start, own, file, last } }, done, failed, why, phase, ready, changed }
local jobs = {}
Music.jobs = jobs
local function say(text) Music.status = text; Music.changed:fire("status") end
local function newJob(track)
  local job = { track = track, pieces = {}, changed = B.Signal.new(), phase = "Getting it ready", fraction = 0 }
  function job.fire() job.changed:fire() end
  return job
end
local function fail(job, why)
  job.failed, job.why = true, why or "it would not play"
  job.fire()
end
local function fileJob(job, data, ext)
  local path = CACHE .. "/" .. job.track.key .. "_" .. token() .. ext
  fs.write(path, data)
  local id = asset(path)
  if not id then return fail(job, "the file would not load") end
  cacheTouch(path, #data)
  job.kind, job.asset, job.done, job.ready = "file", id, true, true
  job.fire()
end
-- a song kept from before: one file, or a folder of pieces with its info.json
local function fromCache(job)
  local key = job.track.key
  for _, file in ipairs(fs.list(CACHE)) do
    local name = string.match(file, "([^/]+)$") or ""
    if string.sub(name, 1, #key + 1) == key .. "_" and string.find(name, "%.%w+$") then
      local id = asset(file)
      if id then
        cacheTouch(file)
        job.kind, job.asset, job.done, job.ready = "file", id, true, true
        return true
      end
    end
  end
  local folder = CACHE .. "/" .. key
  local info = fs.readJson(folder .. "/info.json")
  if type(info) == "table" and type(info.pieces) == "table" and #info.pieces > 0 then
    for i, p in ipairs(info.pieces) do
      local id = asset(folder .. "/" .. p.name)
      if not id then return false end
      job.pieces[i] = { asset = id, start = p.start, own = p.own, file = p.file, last = p.last }
    end
    cacheTouch(folder)
    job.kind, job.done, job.ready, job.total = "pieces", true, true, info.total
    return true
  end
  return false
end
-- SoundCloud's AAC: downloaded four segments at a time, decoded as it comes, kept a piece at a time
local converting = nil
local function convert(job, url)
  local code, text = fetch(url)
  if code ~= 200 or not text then return fail(job, "the stream would not open") end
  if string.find(text, "#EXT-X-KEY", 1, true) then return fail(job, "this one is protected (DRM)") end
  local init, urls = playlist(url, text)
  if not init or #urls == 0 then return fail(job, "the stream is empty") end
  local _, head = fetch(init)
  if not head then return fail(job, "the stream would not open") end
  -- (a song another conversion was busy with in the background gives way to the one asked for)
  if converting and converting ~= job and not converting.foreground then converting.cancelled = true end
  while converting and converting ~= job and not job.cancelled do task.wait(0.1) end
  if job.cancelled then return fail(job, "cancelled") end
  converting = job
  local parts, nextUrl, active, broken = {}, 1, 0, false
  task.spawn(function()
    while nextUrl <= #urls and not broken and not job.cancelled do
      while active >= 4 do task.wait() end
      local i = nextUrl
      nextUrl += 1
      active += 1
      task.spawn(function()
        local body
        for _ = 1, 3 do
          local c, data = fetch(urls[i])
          if c == 200 and data and #data > 0 then body = data; break end
          task.wait(0.4)
        end
        if body then parts[i] = body else broken = true end
        active -= 1
      end)
    end
  end)
  local folder = CACHE .. "/" .. job.track.key
  removeEntry(folder)
  fs.mkdir(folder)
  local stamp = token()
  local kept, bytes = {}, 0
  job.kind = "pieces"
  local total = math.max(job.track.duration or 0, 1)
  local ok, why, info = B.AAC.stream(head, {
    piece = 12, firstPiece = 6, overlap = 0.3,
    first = job.foreground and 0.03 or 0.006, budget = 0.006,
    segment = function(i)
      if i > #urls then return nil end
      while parts[i] == nil and not broken and not job.cancelled do task.wait() end
      local body = parts[i]
      parts[i] = false
      return body or nil
    end,
    cancelled = function() return job.cancelled == true end,
    progress = function(seconds)
      job.phase, job.fraction = "Converting", math.clamp(seconds / total, 0, 1)
      job.fire()
    end,
    onPiece = function(i, wav, start, own, file, last)
      local name = "p" .. i .. "_" .. stamp .. ".wav"
      fs.write(folder .. "/" .. name, wav)
      bytes += #wav
      local id = asset(folder .. "/" .. name)
      job.pieces[i] = { asset = id, start = start, own = own, file = file, last = last }
      kept[i] = { name = name, start = start, own = own, file = file, last = last }
      job.ready = true
      job.fire()
    end,
  })
  B.identity()
  if converting == job then converting = nil end
  if not ok then
    removeEntry(folder)
    if broken then why = "a part of the stream failed" end
    return fail(job, why)
  end
  fs.writeJson(folder .. "/info.json", { v = 1, pieces = kept, total = info.seconds, rate = info.rate, channels = info.channels })
  cacheTouch(folder, bytes)
  job.total, job.done = info.seconds, true
  job.fire()
end
local function run(job)
  local track = job.track
  if track.sound then job.kind, job.asset, job.done, job.ready = "file", track.sound, true, true; return job.fire() end
  if track.source == "file" then
    local id = asset(track.path)
    if not id then return fail(job, "the file would not load") end
    job.kind, job.asset, job.done, job.ready = "file", id, true, true
    return job.fire()
  end
  if fromCache(job) then return job.fire() end
  job.phase = "Downloading"
  job.fire()
  if track.source == "link" then
    local code, body = fetch(track.url)
    if code ~= 200 or not body or #body < 512 then return fail(job, "the link did not answer") end
    local magic = string.sub(body, 1, 4)
    return fileJob(job, body, magic == "OggS" and ".ogg" or (magic == "RIFF" and ".wav" or (magic == "fLaC" and ".flac" or ".mp3")))
  elseif track.source == "au" then
    local code, body = fetch(auHost() .. "/v1/tracks/" .. tostring(track.id) .. "/stream?app_name=" .. APP)
    if code ~= 200 or not body or #body < 1000 then AU.host = nil; return fail(job, "Audius would not stream it") end
    return fileJob(job, body, ".mp3")
  elseif track.source == "sc" then
    if not track.raw then Music.revive(track) end
    local stream, why = SC.stream(track)
    if not stream then return fail(job, why) end
    if stream.mp3 then
      local code, body = fetch(stream.mp3)
      if code ~= 200 or not body then return fail(job, "the download failed") end
      return fileJob(job, body, ".mp3")
    end
    if not stream.aac then
      -- (an HLS of MP3 parts: the parts joined are an MP3)
      local code, text = fetch(stream.hls)
      if code ~= 200 or not text then return fail(job, "the stream would not open") end
      local _, urls = playlist(stream.hls, text)
      local all = {}
      for i, url in ipairs(urls) do
        local c, data = fetch(url)
        if c ~= 200 or not data then return fail(job, "a part of the stream failed") end
        all[i] = data
        job.phase, job.fraction = "Downloading", i / #urls
        job.fire()
      end
      return fileJob(job, table.concat(all), ".mp3")
    end
    if not B.AAC then return fail(job, "no AAC decoder") end
    return convert(job, stream.hls)
  end
  return fail(job, "no source")
end
-- the job for a track: the one already going, or a new one
local function jobFor(track, foreground)
  local job = jobs[track.key]
  if job and not job.failed and not job.cancelled then
    if foreground then job.foreground = true end
    return job
  end
  job = newJob(track)
  job.foreground = foreground
  jobs[track.key] = job
  task.spawn(function()
    local ok, err = pcall(run, job)
    B.identity()
    if not ok then fail(job, tostring(err)) end
    if job.failed then jobs[track.key] = nil end
  end)
  return job
end

-- ---------------------------------------------------------------- the deck: three voices in a group that carries the effects
local deck = { voices = {}, main = nil, nextVoice = nil, piece = 0, job = nil, track = nil, mode = nil, waiting = false, paused = {} }
Music.deck = deck
local group, eq, reverb, pitch, comp
local function speed() return (Config.get("music.speed") or 100) / 100 end
local function effects()
  if not group then return end
  group.Volume = math.clamp((Config.get("music.volume") or 60) / 100, 0, 3) * 0.6
  eq.LowGain = Config.get("music.bass") or 0
  eq.MidGain = Config.get("music.mid") or 0
  eq.HighGain = Config.get("music.treble") or 0
  local wet = (Config.get("music.reverb") or 0) / 100
  reverb.Enabled = wet > 0
  reverb.WetLevel = -26 + wet * 22
  reverb.DryLevel = -wet * 3
  reverb.DecayTime = 0.8 + wet * 3.2
  local rate = speed()
  pitch.Enabled = Config.get("music.keepPitch") == true and math.abs(rate - 1) > 0.01
  pitch.Octave = math.clamp(1 / rate, 0.5, 2)
  comp.Enabled = Config.get("music.even") == true
  comp.Threshold, comp.Ratio, comp.Attack, comp.Release, comp.GainMakeup = -20, 4, 0.01, 0.25, 6
  for _, voice in ipairs(deck.voices) do voice.sound.PlaybackSpeed = rate end
end
local ended
local function ensureDeck()
  if group and group.Parent then return end
  group = Instance.new("SoundGroup")
  group.Name = util.randomName()
  group.Parent = S.SoundService
  B.own(group)
  eq = Instance.new("EqualizerSoundEffect"); eq.Priority = 1; eq.Parent = group
  comp = Instance.new("CompressorSoundEffect"); comp.Priority = 2; comp.Parent = group
  pitch = Instance.new("PitchShiftSoundEffect"); pitch.Priority = 3; pitch.Parent = group
  reverb = Instance.new("ReverbSoundEffect"); reverb.Priority = 4; reverb.Parent = group
  table.clear(deck.voices)
  for i = 1, 3 do
    local sound = Instance.new("Sound")
    sound.Name = "Voice" .. i
    sound.SoundGroup = group
    sound.Parent = group
    local voice = { sound = sound, gain = 0 }
    sound.Ended:Connect(function() if B.alive then B.try("music.ended", ended, voice) end end)
    deck.voices[i] = voice
  end
  effects()
end
function Music.sound() return deck.main and deck.main.sound or nil end
local function freeVoice()
  for _, voice in ipairs(deck.voices) do
    if voice ~= deck.main and voice ~= deck.nextVoice and not voice.fade and not voice.sound.IsPlaying then return voice end
  end
  return nil
end
local function fadeVoice(voice, to, seconds, stop)
  voice.fade = { from = voice.gain, to = to, t = 0, dur = math.max(seconds, 0.01), stop = stop }
end
local function stopAll(seconds)
  for _, voice in ipairs(deck.voices) do
    if voice.sound.IsPlaying then
      if seconds and seconds > 0 then fadeVoice(voice, 0, seconds, true) else voice.fade = nil; voice.sound:Stop() end
    end
  end
  deck.main, deck.nextVoice, deck.waiting = nil, nil, false
  table.clear(deck.paused)
end
-- where the song is, and how long it is
function Music.position()
  local main = deck.main
  if not main then return Music.resumeAt or 0 end
  if deck.mode == "pieces" then
    local p = deck.job and deck.job.pieces[deck.piece]
    return (p and p.start or 0) + main.sound.TimePosition
  end
  return main.sound.TimePosition
end
function Music.length()
  local job = deck.job
  if deck.mode == "pieces" then return (job and job.done and job.total) or (deck.track and deck.track.duration) or 0 end
  local main = deck.main
  if main and main.sound.TimeLength > 0 then return main.sound.TimeLength end
  return (deck.track and deck.track.duration) or (Music.now and Music.now.duration) or 0
end
function Music.loudness()
  local main = deck.main
  return (main and main.sound.IsPlaying) and main.sound.PlaybackLoudness or 0
end

local function remember(track)
  local history = table.clone(Config.get("music.history") or {})
  for i = #history, 1, -1 do if history[i].key == track.key then table.remove(history, i) end end
  table.insert(history, 1, Music.compact(track))
  while #history > 60 do table.remove(history) end
  Config.set("music.history", history)
end
-- the deck takes up a song whose job has its first sound loaded on `voice`
local function begin(track, job, voice, offset, fadeIn)
  local old = deck.main
  deck.track, deck.job, deck.mode = track, job, job.kind
  deck.piece = job.kind == "pieces" and 1 or 0
  deck.main, deck.nextVoice, deck.waiting = voice, nil, false
  table.clear(deck.paused)
  local sound = voice.sound
  sound.PlaybackSpeed = speed()
  sound.TimePosition = offset or 0
  sound:Play()
  voice.gain = fadeIn and 0 or 1
  if fadeIn then fadeVoice(voice, 1, fadeIn) else voice.fade = nil end
  if old and old ~= voice and old.sound.IsPlaying then fadeVoice(old, 0, fadeIn or 0.12, true) end
  Music.state = "playing"
  Music.startedAt = os.clock()
  say(nil)
  remember(track)
  Music.changed:fire("state")
  if Config.get("music.announce") ~= false then
    Window.toast({ title = track.title, text = track.artist, icon = "music", time = 2.6, music = track })
  end
  Music.prefetch()
end
-- load a job's first sound on a free voice, then start it (at `offset` seconds: a restored session)
local playToken = 0
local function startJob(track, job, offset)
  playToken += 1
  local mine = playToken
  task.spawn(function()
    while not (job.ready or job.failed) and mine == playToken do
      say(string.format("%s%s", job.phase or "Getting it ready", (job.fraction and job.fraction > 0) and string.format(" %d%%", math.floor(job.fraction * 100)) or "..."))
      task.wait(0.1)
    end
    if mine ~= playToken then return end
    if job.failed then
      Music.state = "error"
      say("Could not play: " .. tostring(job.why))
      Music.changed:fire("state")
      -- (a song that will not play is passed over, after a moment)
      task.delay(1.6, function() if mine == playToken and Music.state == "error" and #Music.queue > Music.index then Music.next(true) end end)
      return
    end
    ensureDeck()
    local voice = freeVoice()
    while not voice and mine == playToken do task.wait(); voice = freeVoice() end
    if mine ~= playToken then return end
    -- (a restored session's place: the piece that holds it)
    local first, at = job.asset, offset or 0
    if job.kind == "pieces" then
      local k = 1
      if at > 0 then
        while not job.done and not job.failed and (job.pieces[#job.pieces].start + job.pieces[#job.pieces].own) < at and mine == playToken do task.wait(0.1) end
        for i, p in ipairs(job.pieces) do if at < p.start + p.own then k = i; break end end
      end
      first, at = job.pieces[k].asset, math.max(at - job.pieces[k].start, 0)
      job.startPiece = k
    end
    voice.sound.SoundId = first
    local began = os.clock()
    while not voice.sound.IsLoaded and os.clock() - began < 12 and mine == playToken do task.wait() end
    if mine ~= playToken then return end
    if not voice.sound.IsLoaded then
      Music.state = "error"
      say("The sound would not load")
      Music.changed:fire("state")
      return
    end
    begin(track, job, voice, at, 0.06)
    if job.startPiece then deck.piece = job.startPiece; job.startPiece = nil end
  end)
end

-- ---------------------------------------------------------------- the queue
-- play a track now: it goes in after the one playing and becomes the one playing
function Music.play(track, fromQueue)
  if not track or track.playable == false then return end
  -- (a song kept from this PC plays here through SoundCloud: the closest by name and length)
  if track.source == "pc" then
    say("Finding it on SoundCloud...")
    task.spawn(function()
      local found = Music.findOnSoundCloud(track)
      B.identity()
      if not found then say("Not on SoundCloud: " .. tostring(track.title)); return end
      if fromQueue and Music.queue[Music.index] == track then Music.queue[Music.index] = found end
      Music.play(found, fromQueue)
    end)
    return
  end
  if not fromQueue then
    local at = math.max(Music.index + 1, 1)
    table.insert(Music.queue, at, track)
    Music.index = at
  end
  Music.resumeAt = nil
  Music.now = track
  Music.state = "loading"
  stopAll(0.15)
  deck.track = track
  Music.changed:fire("track")
  Music.changed:fire("queue")
  startJob(track, jobFor(track, true), 0)
end
-- which song comes next (shuffle draws it once and keeps it)
local shuffleBag = nil
function Music.upcoming()
  local count = #Music.queue
  if count == 0 then return nil end
  if Config.get("music.repeat") == "one" and Music.now then return Music.now end
  if Config.get("music.shuffle") and count > 1 then
    if not (shuffleBag and Music.queue[shuffleBag] and shuffleBag ~= Music.index) then
      repeat shuffleBag = math.random(count) until shuffleBag ~= Music.index
    end
    return Music.queue[shuffleBag]
  end
  if Music.index + 1 <= count then return Music.queue[Music.index + 1] end
  if Config.get("music.repeat") == "all" then return Music.queue[1] end
  return nil
end
-- the next of the queue is made ready while this one plays
function Music.prefetch()
  local nextTrack = Music.upcoming()
  if not nextTrack or nextTrack == Music.now or nextTrack.source == "file" or nextTrack.sound then return end
  if jobs[nextTrack.key] or Music.prefetching == nextTrack.key then return end
  Music.prefetching = nextTrack.key
  task.delay(2, function()
    if Music.prefetching == nextTrack.key then Music.prefetching = nil end
    if not B.alive or Music.upcoming() ~= nextTrack or jobs[nextTrack.key] then return end
    jobFor(nextTrack, false)
  end)
end
local function advanceIndex(track)
  for i, item in ipairs(Music.queue) do
    if item == track then Music.index = i; return end
  end
end
local autoBusy = false
function Music.next(auto)
  local nextTrack = Music.upcoming()
  shuffleBag = nil
  if nextTrack and nextTrack == Music.now and not auto then
    -- (repeat one: the button still moves on)
    nextTrack = Music.queue[Music.index + 1] or (Config.get("music.repeat") ~= "off" and Music.queue[1]) or nil
  end
  if nextTrack then
    if nextTrack == Music.now and auto then Music.seekTo(0); return end
    advanceIndex(nextTrack)
    Music.play(nextTrack, true)
    return
  end
  -- the queue ran out: songs like the last one (SoundCloud), or the rest of what was searched
  if auto and Config.get("music.autoplay") ~= false and Music.now and not autoBusy then
    autoBusy = true
    local last = Music.now
    task.spawn(function()
      local more
      if last.source == "sc" and last.id then more = SC.related(last.id) end
      B.identity()
      if not more or #more == 0 then
        more = {}
        local after = false
        for _, track in ipairs(Music.results) do
          if after and track.playable ~= false then more[#more + 1] = track end
          if track.key == last.key then after = true end
        end
      end
      autoBusy = false
      if #more == 0 then Music.state = "idle"; Music.changed:fire("state"); return end
      for i = 1, math.min(#more, 10) do Music.queue[#Music.queue + 1] = more[i] end
      Music.changed:fire("queue")
      Music.index += 1
      Music.play(Music.queue[Music.index], true)
    end)
    return
  end
  Music.state = "idle"
  stopAll(0.3)
  Music.changed:fire("state")
end
function Music.previous()
  if Music.position() > 4 then Music.seekTo(0); return end
  if Music.index > 1 then
    Music.index -= 1
    Music.play(Music.queue[Music.index], true)
  else
    Music.seekTo(0)
  end
end
function Music.toggle()
  if not deck.main or not Music.now then
    local first = Music.now or Music.queue[math.max(Music.index, 1)] or Music.results[1]
    if not first then return end
    if Music.state == "loading" then return end
    -- (a restored song starts where it was)
    local at = Music.resumeAt
    Music.resumeAt = nil
    if not table.find(Music.queue, first) then Music.play(first); return end
    advanceIndex(first)
    local track = first
    Music.now = track
    Music.state = "loading"
    deck.track = track
    Music.changed:fire("state")
    startJob(track, jobFor(track, true), at or 0)
    return
  end
  if Music.state == "playing" then
    table.clear(deck.paused)
    for _, voice in ipairs(deck.voices) do
      if voice.sound.IsPlaying then voice.sound:Pause(); deck.paused[#deck.paused + 1] = voice end
    end
    Music.state = "paused"
  elseif Music.state == "paused" then
    for _, voice in ipairs(deck.paused) do voice.sound:Resume() end
    table.clear(deck.paused)
    Music.state = "playing"
    Music.startedAt = os.clock()
  end
  Music.changed:fire("state")
end
function Music.stop()
  playToken += 1
  stopAll(0.2)
  Music.state = "idle"
  say(nil)
  Music.changed:fire("state")
end
-- to a time (seconds) in the song: in pieces, the piece that has it
function Music.seekTo(seconds)
  local main = deck.main
  if not main then return end
  seconds = math.max(0, seconds)
  if deck.mode ~= "pieces" then
    main.sound.TimePosition = math.min(seconds, math.max(main.sound.TimeLength - 0.05, 0))
    if Music.state == "playing" and not main.sound.IsPlaying then main.sound:Play() end
    return
  end
  local job = deck.job
  local k = #job.pieces
  for i, p in ipairs(job.pieces) do
    if seconds < p.start + p.own then k = i; break end
  end
  local p = job.pieces[k]
  if not p then return end
  local offset = math.clamp(seconds - p.start, 0, math.max(p.file - 0.05, 0))
  if k == deck.piece and main.sound.IsLoaded then
    main.sound.TimePosition = offset
    if Music.state == "playing" and not main.sound.IsPlaying then main.sound:Play() end
    deck.waiting = false
    return
  end
  local voice = (deck.nextVoice and deck.nextVoice.sound.SoundId == p.asset) and deck.nextVoice or freeVoice()
  if not voice then return end
  deck.nextVoice = nil
  voice.sound.SoundId = p.asset
  task.spawn(function()
    local began = os.clock()
    while not voice.sound.IsLoaded and os.clock() - began < 5 do task.wait() end
    if deck.job ~= job then return end
    local old = deck.main
    voice.sound.PlaybackSpeed = speed()
    voice.sound.TimePosition = offset
    voice.gain, voice.fade = 1, nil
    voice.sound:Play()
    if Music.state ~= "playing" then voice.sound:Pause(); table.clear(deck.paused); deck.paused[1] = voice end
    if old and old ~= voice then old.fade = nil; old.sound:Stop() end
    deck.main, deck.piece, deck.waiting = voice, k, false
  end)
end
function Music.seek(fraction)
  local length = Music.length()
  if length > 0 then Music.seekTo(math.clamp(fraction, 0, 0.999) * length) end
end

-- the end of a voice: the next piece, or the next song
ended = function(voice)
  if voice ~= deck.main or Music.state ~= "playing" then return end
  if deck.mode == "pieces" then
    local p = deck.job and deck.job.pieces[deck.piece]
    if p and not p.last then
      -- (the next piece is not ready: it carries on from here when it is)
      deck.waiting = true
      say("Buffering...")
      return
    end
  end
  if Config.get("music.repeat") == "one" then Music.seekTo(0); return end
  Music.next(true)
end

-- every frame: fades, the step from piece to piece, and the crossfade into the next song
local function step(dt)
  if not group then return end
  for _, voice in ipairs(deck.voices) do
    local f = voice.fade
    if f then
      f.t += dt
      local p = math.clamp(f.t / f.dur, 0, 1)
      voice.gain = f.from + (f.to - f.from) * p
      if p >= 1 then
        voice.fade = nil
        if f.stop then voice.sound:Stop() end
      end
    end
    voice.sound.Volume = voice.gain
  end
  if Music.state ~= "playing" or not deck.main then return end
  local main = deck.main
  if deck.mode == "pieces" then
    local job = deck.job
    local p = job.pieces[deck.piece]
    local q = job.pieces[deck.piece + 1]
    if q and not deck.nextVoice then
      local voice = freeVoice()
      if voice then voice.sound.SoundId = q.asset; deck.nextVoice = voice end
    end
    local nv = deck.nextVoice
    if p and q and nv and nv.sound.IsLoaded then
      if deck.waiting then
        -- (it ran out and waited: carry on where the last one stopped)
        nv.sound.PlaybackSpeed = speed()
        nv.sound.TimePosition = math.max(0, p.file - p.own)
        nv.sound:Play()
        nv.gain, nv.fade = 1, nil
        deck.main, deck.nextVoice, deck.piece, deck.waiting = nv, nil, deck.piece + 1, false
        say(nil)
      elseif main.sound.TimePosition >= p.own then
        -- the overlap (0.3 s, longer than a slow frame): the next piece comes in under this one
        local left = math.clamp(p.file - main.sound.TimePosition, 0.02, 0.1)
        nv.sound.PlaybackSpeed = speed()
        nv.sound.TimePosition = main.sound.TimePosition - p.own
        nv.sound:Play()
        nv.gain = 0
        fadeVoice(nv, 1, left)
        fadeVoice(main, 0, left, true)
        deck.main, deck.nextVoice, deck.piece = nv, nil, deck.piece + 1
      end
    end
  end
  -- the crossfade into the next song, when one is set and the next is ready
  local fade = Config.get("music.fade") or 0
  if fade > 0 and not deck.crossing then
    local length = Music.length()
    local left = length - Music.position()
    local cur = deck.job and deck.job.pieces[deck.piece]
    local lastPiece = deck.mode ~= "pieces" or (deck.job and deck.job.done and cur and cur.last)
    if length > fade * 2 and left <= fade and left > 0.2 and lastPiece then
      local nextTrack = Music.upcoming()
      local job = nextTrack and nextTrack ~= Music.now and jobs[nextTrack.key]
      if job and job.ready and not job.failed then
        local voice = freeVoice()
        if voice then
          deck.crossing = true
          voice.sound.SoundId = job.kind == "pieces" and job.pieces[1].asset or job.asset
          task.spawn(function()
            local began = os.clock()
            while not voice.sound.IsLoaded and os.clock() - began < 2 do task.wait() end
            deck.crossing = false
            if not voice.sound.IsLoaded or Music.state ~= "playing" then return end
            local fadeFor = math.max(Music.length() - Music.position(), 0.3)
            shuffleBag = nil
            advanceIndex(nextTrack)
            Music.now = nextTrack
            Music.changed:fire("track")
            begin(nextTrack, job, voice, 0, fadeFor)
          end)
        end
      elseif nextTrack and not job then
        Music.prefetch()
      end
    end
  end
end
Motion.every(step, nil, "music.deck")

-- ---------------------------------------------------------------- the library: queue, likes, playlists
function Music.enqueue(track, playNext)
  if playNext then table.insert(Music.queue, math.max(Music.index + 1, 1), track) else Music.queue[#Music.queue + 1] = track end
  Music.changed:fire("queue")
  Music.prefetch()
end
function Music.remove(position)
  if not Music.queue[position] then return end
  table.remove(Music.queue, position)
  if position <= Music.index then Music.index = math.max(Music.index - 1, 0) end
  shuffleBag = nil
  Music.changed:fire("queue")
end
function Music.move(from, to)
  local track = Music.queue[from]
  if not track or not Music.queue[to] or from == to then return end
  local current = Music.queue[Music.index]
  table.remove(Music.queue, from)
  table.insert(Music.queue, to, track)
  if current then advanceIndex(current) end
  Music.changed:fire("queue")
end
function Music.clearQueue()
  local current = Music.now
  table.clear(Music.queue)
  Music.index = 0
  if current and Music.state ~= "idle" then Music.queue[1] = current; Music.index = 1 end
  shuffleBag = nil
  Music.changed:fire("queue")
end
-- what is kept of a track (likes, history, playlists): enough to find and play it again
function Music.compact(track)
  return { source = track.source, key = track.key, id = track.id, title = track.title, artist = track.artist, duration = track.duration, art = track.art,
    link = track.link, path = track.path, url = track.url, sound = track.sound }
end
function Music.liked(track)
  if not track then return false end
  for _, item in ipairs(Config.get("music.liked") or {}) do if item.key == track.key then return true end end
  return false
end
function Music.like(track, on)
  if not track then return end
  local list = table.clone(Config.get("music.liked") or {})
  for i = #list, 1, -1 do if list[i].key == track.key then table.remove(list, i) end end
  if on then table.insert(list, 1, Music.compact(track)) end
  Config.set("music.liked", list)
  Music.changed:fire("liked")
end
function Music.playlists() return Config.get("music.playlists") or {} end
local function savePlaylists(list) Config.set("music.playlists", list); Music.changed:fire("playlists") end
function Music.newPlaylist(name)
  name = string.match(tostring(name or ""), "^%s*(.-)%s*$")
  if name == "" then return nil end
  local list = table.clone(Music.playlists())
  for _, item in ipairs(list) do if string.lower(item.name) == string.lower(name) then return item end end
  local item = { name = string.sub(name, 1, 40), tracks = {} }
  list[#list + 1] = item
  savePlaylists(list)
  return item
end
function Music.addTo(name, track)
  local list = table.clone(Music.playlists())
  for i, item in ipairs(list) do
    if item.name == name then
      local copy = { name = item.name, tracks = table.clone(item.tracks or {}) }
      for _, t in ipairs(copy.tracks) do if t.key == track.key then return end end
      copy.tracks[#copy.tracks + 1] = Music.compact(track)
      list[i] = copy
      savePlaylists(list)
      return
    end
  end
end
function Music.removeFrom(name, key)
  local list = table.clone(Music.playlists())
  for i, item in ipairs(list) do
    if item.name == name then
      local copy = { name = item.name, tracks = {} }
      for _, t in ipairs(item.tracks or {}) do if t.key ~= key then copy.tracks[#copy.tracks + 1] = t end end
      list[i] = copy
      savePlaylists(list)
      return
    end
  end
end
function Music.deletePlaylist(name)
  local list = {}
  for _, item in ipairs(Music.playlists()) do if item.name ~= name then list[#list + 1] = item end end
  savePlaylists(list)
end
-- play a list from the start (or a chosen song in it)
function Music.playList(tracks, first)
  if #tracks == 0 then return end
  table.clear(Music.queue)
  for _, t in ipairs(tracks) do Music.queue[#Music.queue + 1] = table.clone(t) end
  Music.index = math.clamp(first or 1, 1, #Music.queue)
  if Config.get("music.shuffle") and not first then Music.index = math.random(#Music.queue) end
  shuffleBag = nil
  Music.changed:fire("queue")
  Music.play(Music.queue[Music.index], true)
end
-- a kept SoundCloud track has no stream list: it is asked for again
function Music.revive(track)
  if track and track.source == "sc" and not track.raw and track.id then
    local body = scGet("https://api-v2.soundcloud.com/tracks/" .. tostring(track.id))
    local data = json(body)
    if type(data) == "table" and data.id then
      local fresh = scTrack(data)
      track.raw, track.auth, track.playable, track.preview = fresh.raw, fresh.auth, fresh.playable, fresh.preview
      track.art = track.art or fresh.art
    end
    B.identity()
  end
  return track
end
function Music.findOnSoundCloud(track)
  local list = SC.search(tostring(track.artist or "") .. " " .. tostring(track.title or ""))
  local best, bestOff
  for _, t in ipairs(list or {}) do
    if t.playable and not t.preview then
      local off = ((track.duration or 0) > 0 and (t.duration or 0) > 0) and math.abs(t.duration - track.duration) or 30
      if not best or off < bestOff then best, bestOff = t, off end
    end
  end
  return best
end
function Music.search(source, query)
  local list, why
  if source == "files" then list = Music.files()
  elseif source == "au" then
    if #string.gsub(query or "", "%s", "") == 0 then list, why = AU.trending() else list, why = AU.search(query) end
  else list, why = SC.search(query) end
  B.identity()
  if list then
    Music.results, Music.resultsFor = list, source
    Music.changed:fire("results")
  end
  return list, why
end
-- the cover: downloaded once, then shown from disk
local artWaiting = {}
function Music.coverPath(track) return track and track.art and (ART .. "/" .. track.key .. ".jpg") or nil end
function Music.cover(track, image, done)
  if not (track and image) then return end
  if not track.art then image.Image = ""; if done then done(nil) end; return end
  local path = Music.coverPath(track)
  local id = asset(path)
  if id then image.Image = id; if done then done(path) end; return end
  image.Image = ""
  if artWaiting[path] then table.insert(artWaiting[path], { image, done }); return end
  artWaiting[path] = { { image, done } }
  task.spawn(function()
    local code, data = fetch(track.art)
    if code == 200 and data and #data > 100 then fs.write(path, data) end
    local got = asset(path)
    for _, waiting in ipairs(artWaiting[path]) do
      if waiting[1].Parent and got then waiting[1].Image = got end
      if waiting[2] then B.try("music.cover", waiting[2], got and path or nil) end
    end
    artWaiting[path] = nil
  end)
end
function Music.time(seconds)
  seconds = math.max(0, math.floor(seconds or 0))
  if seconds >= 3600 then return string.format("%d:%02d:%02d", seconds // 3600, (seconds // 60) % 60, seconds % 60) end
  return string.format("%d:%02d", seconds // 60, seconds % 60)
end
function Music.plays(n)
  n = tonumber(n)
  if not n or n <= 0 then return nil end
  if n >= 1e6 then return string.format("%.1fM plays", n / 1e6) end
  if n >= 1e3 then return string.format("%.0fK plays", n / 1e3) end
  return n .. " plays"
end
local SOURCE_NAME = { sc = "SoundCloud", au = "Audius", file = "Your file", link = "Link", roblox = "Roblox", pc = "This PC" }
function Music.sourceName(track) return track and SOURCE_NAME[track.source] or "" end

-- ---------------------------------------------------------------- in front: this player, or this PC's (48_pc)
-- Both answer the same calls, so the card, the island and the tab draw either.
local GAME = { kind = "game" }
Music.game = GAME
function GAME.track() return Music.now end
function GAME.state() return Music.state end
function GAME.status() return Music.status end
function GAME.position() return Music.position() end
function GAME.length() return Music.length() end
function GAME.toggle() Music.toggle() end
function GAME.next() Music.next(false) end
function GAME.previous() Music.previous() end
function GAME.seekTo(seconds) Music.seekTo(seconds) end
function GAME.seek(fraction) Music.seek(fraction) end
function GAME.canSeek() return deck.main ~= nil end
function GAME.volume() return math.clamp((Config.get("music.volume") or 60) / 100, 0, 1) end
function GAME.setVolume(value) Config.set("music.volume", math.floor(math.clamp(value, 0, 1) * 100 + 0.5)) end
function GAME.shuffle() return Config.get("music.shuffle") == true end
function GAME.setShuffle(on) Config.set("music.shuffle", on == true) end
function GAME.repeatMode() return Config.get("music.repeat") or "off" end
function GAME.setRepeat(mode) Config.set("music.repeat", mode) end
function GAME.cover(track, image, done) Music.cover(track, image, done) end
function GAME.tint(track, done) Music.tint(track, done) end
function GAME.loudness() return Music.loudness() end
function GAME.label(track) return Music.sourceName(track) end
-- the next songs: { track, index } (at most eight)
function GAME.queue()
  local out = {}
  for i = Music.index + 1, math.min(#Music.queue, Music.index + 8) do out[#out + 1] = { track = Music.queue[i], index = i } end
  return out
end
-- the game's player, unless this PC is the one playing (or started last, or the game has nothing)
function Music.front()
  local PC = B.PC
  local pc = PC and PC.ctl
  if not (pc and PC.live and PC.track) then return GAME end
  local gameOn = Music.state == "playing" or Music.state == "loading"
  local pcOn = PC.playing()
  if pcOn and not gameOn then return pc end
  if gameOn and not pcOn then return GAME end
  local pcLater = (PC.startedAt or 0) > (Music.startedAt or 0)
  if pcOn and gameOn then return pcLater and pc or GAME end
  if not Music.now or pcLater then return pc end
  return GAME
end
-- the Music tab, in the look in use
function Music.openTab()
  local look = Window.look()
  Window.showActive(true)
  if look == "unnamed" and B.Unnamed and B.Unnamed.go then B.Unnamed.go("music")
  elseif look == "novoline" and B.Novoline and B.Novoline.go then B.Novoline.go("music")
  else Window.go("music") end
end

-- ---------------------------------------------------------------- drawing: the same pieces in every look (Window.kit)
-- what a drawing listens to is let go of when the drawing is gone
local function life(root)
  local links, jobsOf = {}, {}
  local api = {}
  local function cleanup()
    for _, job in ipairs(jobsOf) do job.cancel() end
    for _, link in ipairs(links) do link.disconnect() end
    table.clear(links)
  end
  function api.signal(signal, fn) links[#links + 1] = signal:connect(function(...) if root.Parent then fn(...) end end) end
  function api.config(id, fn) local off = Config.on(id, function(...) if root.Parent then fn(...) end end); links[#links + 1] = { disconnect = off } end
  function api.every(fn, hz, scope)
    local job
    job = Motion.every(function(dt)
      if not root.Parent then cleanup(); return end
      fn(dt)
    end, hz, scope)
    jobsOf[#jobsOf + 1] = job
  end
  api.every(function() end, 0.5, "music.life")
  return api
end
Music.life = life
local function frame(parent, props)
  local f = Instance.new("Frame")
  f.BorderSizePixel, f.BackgroundTransparency = 0, 1
  for key, value in pairs(props or {}) do f[key] = value end
  f.Parent = parent
  return f
end
local function round(f, radius)
  local c = Instance.new("UICorner")
  c.CornerRadius = radius == true and UDim.new(1, 0) or UDim.new(0, radius)
  c.Parent = f
  return c
end
local function hitbox(parent, props)
  local button = Instance.new("TextButton")
  button.Text, button.AutoButtonColor, button.BackgroundTransparency, button.BorderSizePixel = "", false, 1, 0
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = 8
  for key, value in pairs(props or {}) do button[key] = value end
  button.Parent = parent
  return button
end
local function icon(parent, name, size, kit, role, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency, image.BorderSizePixel = 1, 0
  image.Size = UDim2.fromOffset(size, size)
  image.ScaleType = Enum.ScaleType.Fit
  UI.setIcon(image, name)
  kit.paint(image, "ImageColor3", role or "text")
  for key, value in pairs(props or {}) do image[key] = value end
  image.Parent = parent
  return image
end
-- a round button: an icon on a tinted disc (or the accent, for the main one)
local function circle(parent, name, size, kit, run, main, tip)
  local disc = frame(parent, { Size = UDim2.fromOffset(size, size), Name = name })
  local filled = main == true
  if kit.look ~= "unnamed" then round(disc, true) end
  local function rest()
    if filled then kit.fill(disc, "accent") else kit.clear(disc) end
  end
  rest()
  if kit.look == "unnamed" and filled then kit.outline(disc) end
  local inner = math.floor(size * (filled and 0.46 or 0.5))
  local glyph = icon(disc, name, inner, kit, filled and "onAccent" or "text", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
  local hit = hitbox(disc)
  hit.MouseEnter:Connect(function()
    if filled then disc.BackgroundTransparency = 0.12 else kit.fill(disc, "hover") end
  end)
  hit.MouseLeave:Connect(rest)
  hit.Activated:Connect(B.safe("music.button", function()
    UI.sfx("click", 0.45)
    if not Motion.reduced then
      glyph.Size = UDim2.fromOffset(math.floor(inner * 0.78), math.floor(inner * 0.78))
      Motion.to(glyph, "Size", UDim2.fromOffset(inner, inner), "bouncy")
    end
    run()
  end))
  if tip and kit.look == "based" then UI.tooltip(hit, tip) end
  return disc, glyph
end
Music.circle = circle
local function cover(parent, kit, size, props)
  local image = Instance.new("ImageLabel")
  image.Name = "Cover"
  image.BorderSizePixel = 0
  image.Size = UDim2.fromOffset(size, size)
  image.ScaleType = Enum.ScaleType.Crop
  kit.fill(image, "field")
  for key, value in pairs(props or {}) do image[key] = value end
  if kit.look == "unnamed" then kit.outline(image) else round(image, math.max(6, math.floor(size * 0.12))) end
  image.Parent = parent
  local placeholder = icon(image, "music", math.floor(size * 0.38), kit, "faint", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    ZIndex = image.ZIndex })
  image:GetPropertyChangedSignal("Image"):Connect(function() placeholder.Visible = image.Image == "" end)
  return image
end
Music.coverImage = cover
-- A line that slides when it is longer than its box (a long song name): it waits, glides to its
-- end, waits, glides back. A short one sits still. Moved by Position.X.Scale (a share of the box),
-- so the look's scale never throws it off.
local function marquee(parent, kit, props, bold, size)
  local holder = frame(parent, props)
  holder.ClipsDescendants = true
  local label = kit.text(holder, "", { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, TextTruncate = Enum.TextTruncate.None,
    ZIndex = holder.ZIndex }, bold, size)
  local api = { holder = holder, label = label, t = 0 }
  function api.set(value)
    value = tostring(value or "")
    if label.Text ~= value then
      label.Text = value
      api.t = 0
      label.Position = UDim2.new()
    end
  end
  function api.step(dt)
    local width = holder.AbsoluteSize.X
    local over = label.AbsoluteSize.X - width
    if over <= 1 or width <= 0 then
      if label.Position.X.Scale ~= 0 then label.Position = UDim2.new() end
      api.t = 0
      return
    end
    local glide, back, rest = over / 38, over / 90, 1.6
    local cycle = rest * 2 + glide + back
    api.t = (api.t + dt) % cycle
    local t, p = api.t, 0
    if t < rest then p = 0
    elseif t < rest + glide then p = (t - rest) / glide
    elseif t < rest * 2 + glide then p = 1
    else p = 1 - (t - rest * 2 - glide) / back end
    p = p * p * (3 - 2 * p)
    label.Position = UDim2.new(-(over / width) * p, 0, 0, 0)
  end
  return api
end
Music.marquee = marquee

-- the cover's colour, for the tint behind the player (46_cover.lua reads it)
local tintOf = {}
function Music.tint(track, done)
  if not track or not track.art or Config.get("music.tint") == false then done(nil); return end
  if tintOf[track.key] ~= nil then done(tintOf[track.key] or nil); return end
  local probe = Instance.new("ImageLabel")
  Music.cover(track, probe, function(path)
    probe:Destroy()
    -- (read off the thread that asked: it takes a few frames)
    task.spawn(function()
      local color = path and B.Cover and B.Cover.color(path) or nil
      B.identity()
      tintOf[track.key] = color or false
      B.try("music.tint", done, color)
    end)
  end)
end

-- The player: the cover (a record slides out of it while it plays), the names, the bars, the line, the buttons.
function Music.viewPlayer(holder, shown)
  local kit = Window.kit(holder)
  local L = life(holder)
  shown = shown or function() return Window.showing("music") end
  local square = kit.look == "unnamed"
  local coverSize = square and 112 or 148
  local deckFrame = frame(holder, { Name = "Deck", Size = UDim2.fromScale(1, 1), ClipsDescendants = true })
  -- the tint: the cover's colour, strongest on the left
  local tint = frame(deckFrame, { Name = "Tint", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 0 })
  if not square then round(tint, kit.radius) end
  local shade = Instance.new("UIGradient")
  shade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(0.55, 0.82), NumberSequenceKeypoint.new(1, 1) })
  shade.Parent = tint
  local pad = square and 6 or 14
  -- the record
  local disc, label, sheen
  if not square then
    disc = frame(deckFrame, { Name = "Record", Size = UDim2.fromOffset(coverSize - 12, coverSize - 12), AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.fromOffset(pad + coverSize / 2, pad + coverSize / 2), BackgroundColor3 = Color3.fromRGB(14, 14, 16), BackgroundTransparency = 0, ZIndex = 2 })
    round(disc, true)
    for _, s in ipairs({ 0.92, 0.8, 0.68, 0.56 }) do
      local groove = frame(disc, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(s, s), ZIndex = 2 })
      round(groove, true)
      local line = Instance.new("UIStroke")
      line.Color, line.Transparency, line.Thickness = Color3.fromRGB(46, 46, 52), 0.35, 1
      line.Parent = groove
    end
    label = Instance.new("ImageLabel")
    label.Name = "Label"
    label.BorderSizePixel, label.AnchorPoint, label.Position, label.Size = 0, Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.4, 0.4)
    label.ScaleType, label.ZIndex = Enum.ScaleType.Crop, 3
    kit.fill(label, "accent")
    round(label, true)
    label.Parent = disc
    local hole = frame(label, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(6, 6),
      BackgroundColor3 = Color3.fromRGB(10, 10, 12), BackgroundTransparency = 0, ZIndex = 4 })
    round(hole, true)
    sheen = frame(deckFrame, { AnchorPoint = Vector2.new(0.5, 0.5), Size = disc.Size, Position = disc.Position, BackgroundColor3 = Color3.new(1, 1, 1),
      BackgroundTransparency = 0.86, ZIndex = 3 })
    round(sheen, true)
    local light = Instance.new("UIGradient")
    light.Rotation = 35
    light.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.45, 0.55), NumberSequenceKeypoint.new(0.5, 0.2),
      NumberSequenceKeypoint.new(0.55, 0.55), NumberSequenceKeypoint.new(1, 1) })
    light.Parent = sheen
  end
  local art = cover(deckFrame, kit, coverSize, { Position = UDim2.fromOffset(pad, pad), ZIndex = 5 })
  local right = pad + coverSize + (square and 14 or 64)
  local area = frame(deckFrame, { Name = "Side", Position = UDim2.fromOffset(right, pad), Size = UDim2.new(1, -(right + pad), 1, -pad * 2), ZIndex = 5 })
  local big = kit.size + (square and 3 or 6)
  local title = marquee(area, kit, { Size = UDim2.new(1, -44, 0, big + 6), ZIndex = 5 }, true, big)
  title.set("Nothing playing")
  local artist = kit.text(area, "Search below, or play your own files.", { Position = UDim2.fromOffset(0, big + 6), Size = UDim2.new(1, -44, 0, kit.size + 4),
    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5 }, false, kit.size)
  kit.paint(artist, "TextColor3", "dim")
  local badge = frame(area, { Position = UDim2.fromOffset(0, big + kit.size + 14), Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 5, Visible = false })
  kit.fill(badge, "field")
  if not square then round(badge, true) end
  local badgeText = kit.text(badge, "", { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 6 }, true, kit.size - 3)
  kit.paint(badgeText, "TextColor3", "accent")
  local badgePad = Instance.new("UIPadding")
  badgePad.PaddingLeft, badgePad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
  badgePad.Parent = badge
  local status = kit.text(area, "", { Position = UDim2.fromOffset(0, big + kit.size + 14), Size = UDim2.new(1, -120, 0, 16), ZIndex = 5 }, false, kit.size - 1)
  kit.paint(status, "TextColor3", "accent")
  local _, heart = circle(area, "heart", 32, kit, function() local track = Music.front().track(); if track then Music.like(track, not Music.liked(track)) end end, false, "Like")
  heart.Parent.AnchorPoint, heart.Parent.Position = Vector2.new(1, 0), UDim2.new(1, 0, 0, 0)
  -- the bars: how loud it is, spread over a made-up spectrum that moves with it
  local barsY = big + kit.size + 36
  local bars = frame(area, { Name = "Bars", Position = UDim2.fromOffset(0, barsY), Size = UDim2.new(1, 0, 0, square and 18 or 26), ZIndex = 5 })
  local barList, barLevel = {}, {}
  local COUNT = square and 32 or 40
  for i = 1, COUNT do
    local bar = frame(bars, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new((i - 1) / COUNT, 1, 1, 0), Size = UDim2.new(1 / COUNT, -2, 0, 2), ZIndex = 5 })
    kit.fill(bar, "accent")
    if not square then round(bar, 1) end
    barList[i], barLevel[i] = bar, 0
  end
  -- the line: drag or click it
  local lineY = barsY + (square and 24 or 34)
  local rail = frame(area, { Name = "Rail", Position = UDim2.fromOffset(0, lineY), Size = UDim2.new(1, 0, 0, square and 6 or 4), ZIndex = 5 })
  kit.fill(rail, "field")
  if square then kit.outline(rail) else round(rail, true) end
  local fill = frame(rail, { Size = UDim2.fromScale(0, 1), ZIndex = 6 })
  kit.fill(fill, "accent")
  if not square then round(fill, true) end
  local knob = frame(rail, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(square and 4 or 12, square and 10 or 12),
    BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0, ZIndex = 7 })
  if not square then round(knob, true) end
  local at = kit.text(area, "0:00", { Position = UDim2.fromOffset(0, lineY + 8), Size = UDim2.fromOffset(60, 14), ZIndex = 5 }, false, kit.size - 2)
  kit.paint(at, "TextColor3", "faint")
  local length = kit.text(area, "0:00", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, lineY + 8), Size = UDim2.fromOffset(60, 14), ZIndex = 5,
    TextXAlignment = Enum.TextXAlignment.Right }, false, kit.size - 2)
  kit.paint(length, "TextColor3", "faint")
  local dragging = nil
  local seekHit = hitbox(rail, { Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.5, -10), ZIndex = 9 })
  local function fractionAt(point) return math.clamp((point.X - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1) end
  UI.drag(seekHit, function(point) dragging = fractionAt(point) end, function(point) dragging = fractionAt(point) end, function()
    if dragging then Music.front().seek(dragging) end
    dragging = nil
  end)
  -- the buttons
  local row = frame(area, { Name = "Buttons", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, lineY + (square and 22 or 26)),
    Size = UDim2.fromOffset(0, 44), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 5 })
  local layout = Instance.new("UIListLayout")
  layout.FillDirection, layout.Padding, layout.VerticalAlignment, layout.SortOrder = Enum.FillDirection.Horizontal, UDim.new(0, square and 6 or 12),
    Enum.VerticalAlignment.Center, Enum.SortOrder.LayoutOrder
  layout.Parent = row
  local shuffle, shuffleIcon = circle(row, "shuffle", 30, kit, function() local ctl = Music.front(); ctl.setShuffle(not ctl.shuffle()) end, false, "Shuffle")
  shuffle.LayoutOrder = 1
  local back = circle(row, "skip-back", 34, kit, function() Music.front().previous() end, false, "Back")
  back.LayoutOrder = 2
  local play, playIcon = circle(row, "play", square and 34 or 44, kit, function() Music.front().toggle() end, true)
  play.LayoutOrder = 3
  local forward = circle(row, "skip-forward", 34, kit, function() Music.front().next() end, false, "Next")
  forward.LayoutOrder = 4
  local loop, loopIcon = circle(row, "repeat", 30, kit, function()
    local ctl = Music.front()
    local now = ctl.repeatMode()
    ctl.setRepeat(now == "off" and "all" or (now == "all" and "one" or "off"))
  end, false, "Repeat")
  loop.LayoutOrder = 5
  local coverKey
  local function paint()
    local ctl = Music.front()
    local track = ctl.track()
    title.set(track and track.title or "Nothing playing")
    artist.Text = track and (track.artist .. (track.preview and "  ·  30 s preview" or "")) or "Search below, or play your own files."
    local busy = ctl.status()
    status.Text = busy or ""
    status.Visible = busy ~= nil
    badge.Visible = track ~= nil and busy == nil
    badgeText.Text = string.upper(track and ctl.label(track) or "")
    local key = track and track.key or nil
    if key ~= coverKey then
      coverKey = key
      if track then
        ctl.cover(track, art)
        if label then ctl.cover(track, label) end
        ctl.tint(track, function(color)
          if not tint.Parent or coverKey ~= key then return end
          if color then
            tint.BackgroundColor3 = color
            Motion.to(tint, "BackgroundTransparency", 0, "smooth")
          else
            Motion.to(tint, "BackgroundTransparency", 1, "smooth")
          end
        end)
      else
        art.Image = ""
        if label then label.Image = "" end
        tint.BackgroundTransparency = 1
      end
    end
    UI.setIcon(playIcon, ctl.state() == "playing" and "pause" or "play")
    kit.paint(heart, "ImageColor3", (track and Music.liked(track)) and "accent" or "text")
    kit.paint(shuffleIcon, "ImageColor3", ctl.shuffle() and "accent" or "text")
    local mode = ctl.repeatMode()
    UI.setIcon(loopIcon, mode == "one" and "repeat-1" or "repeat")
    kit.paint(loopIcon, "ImageColor3", mode ~= "off" and "accent" or "text")
  end
  L.signal(Music.changed, paint)
  L.config("music.shuffle", paint)
  L.config("music.repeat", paint)
  L.config("music.liked", paint)
  paint()
  local spin, out = 0, 0
  local level, peak = 0, 4
  local paintedFor
  L.every(function(dt)
    if not shown() then return end
    title.step(dt)
    local ctl = Music.front()
    -- (what is in front changed, or its state: drawn again)
    local current = ctl.track()
    local stamp = (current and current.key or "") .. ctl.state() .. ctl.kind
    if stamp ~= paintedFor then paintedFor = stamp; paint() end
    local position, total = ctl.position(), ctl.length()
    local f = dragging or (total > 0 and math.clamp(position / total, 0, 1) or 0)
    fill.Size = UDim2.fromScale(f, 1)
    knob.Position = UDim2.fromScale(f, 0.5)
    at.Text = Music.time(dragging and dragging * total or position)
    length.Text = Music.time(total)
    -- the record: out of its sleeve and turning while it plays (33 turns a minute)
    local playing = ctl.state() == "playing"
    if disc then
      out += ((playing and 1 or 0) - out) * math.min(dt * 6, 1)
      if playing then spin = (spin + dt * 198) % 360 end
      local x = pad + coverSize / 2 + out * 50
      disc.Position = UDim2.fromOffset(x, pad + coverSize / 2)
      sheen.Position = disc.Position
      disc.Rotation = spin
    end
    -- the bars: against the loudest lately, so they move at any volume
    local raw = playing and ctl.loudness() or 0
    peak = math.max(peak * (1 - math.min(dt * 0.35, 1)), raw, 4)
    local loud = playing and math.clamp(raw / peak * 1.05, 0, 1.15) or 0
    level += (loud - level) * math.min(dt * 14, 1)
    local now = os.clock()
    for i = 1, COUNT do
      local x = (i - 1) / (COUNT - 1)
      local shape = 0.55 + 0.45 * math.sin(now * (2.1 + x * 3.3) + i * 1.7) * math.cos(now * 1.3 + i * 0.6)
      local tilt = 1 - x * 0.55
      local want = level * tilt * (0.35 + 0.65 * math.abs(shape))
      barLevel[i] += (want - barLevel[i]) * math.min(dt * 18, 1)
      barList[i].Size = UDim2.new(1 / COUNT, -2, math.clamp(barLevel[i], 0.06, 1), 0)
    end
    bars.Visible = Config.get("music.visual") ~= "off"
  end, 60, "music.player")
end

-- The small player (Novoline's Home card, tight places): the cover, the names, the line, the buttons.
function Music.viewCompact(holder, shown)
  local kit = Window.kit(holder)
  local L = life(holder)
  shown = shown or function() return true end
  local square = kit.look == "unnamed"
  local art = cover(holder, kit, 84, { Position = UDim2.fromOffset(12, 6), ZIndex = 5 })
  local x = 110
  local title = marquee(holder, kit, { Position = UDim2.fromOffset(x, 10), Size = UDim2.new(1, -(x + 12), 0, kit.size + 6), ZIndex = 5 }, true, kit.size + 1)
  local artist = kit.text(holder, "", { Position = UDim2.fromOffset(x, kit.size + 18), Size = UDim2.new(1, -(x + 12), 0, kit.size + 2), ZIndex = 5,
    TextTruncate = Enum.TextTruncate.AtEnd }, false, kit.size - 1)
  kit.paint(artist, "TextColor3", "dim")
  local status = kit.text(holder, "", { Position = UDim2.fromOffset(x, kit.size * 2 + 22), Size = UDim2.new(1, -(x + 12), 0, kit.size), ZIndex = 5,
    TextTruncate = Enum.TextTruncate.AtEnd }, false, kit.size - 3)
  kit.paint(status, "TextColor3", "accent")
  local rail = frame(holder, { Position = UDim2.fromOffset(12, 104), Size = UDim2.new(1, -24, 0, 3), ZIndex = 5 })
  kit.fill(rail, "field")
  if not square then round(rail, true) end
  local fill = frame(rail, { Size = UDim2.fromScale(0, 1), ZIndex = 6 })
  kit.fill(fill, "accent")
  if not square then round(fill, true) end
  local at = kit.text(holder, "0:00", { Position = UDim2.fromOffset(12, 110), Size = UDim2.fromOffset(50, 12), ZIndex = 5 }, false, kit.size - 4)
  kit.paint(at, "TextColor3", "faint")
  local long = kit.text(holder, "0:00", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 110), Size = UDim2.fromOffset(50, 12), ZIndex = 5,
    TextXAlignment = Enum.TextXAlignment.Right }, false, kit.size - 4)
  kit.paint(long, "TextColor3", "faint")
  local seekHit = hitbox(rail, { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0.5, -8), ZIndex = 9 })
  UI.drag(seekHit, function(point) Music.front().seek(math.clamp((point.X - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)) end)
  local row = frame(holder, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 126), Size = UDim2.fromOffset(0, 36), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 5 })
  local layout = Instance.new("UIListLayout")
  layout.FillDirection, layout.Padding, layout.VerticalAlignment, layout.SortOrder = Enum.FillDirection.Horizontal, UDim.new(0, 12), Enum.VerticalAlignment.Center, Enum.SortOrder.LayoutOrder
  layout.Parent = row
  local _, heart = circle(row, "heart", 28, kit, function() local track = Music.front().track(); if track then Music.like(track, not Music.liked(track)) end end)
  heart.Parent.LayoutOrder = 1
  local back = circle(row, "skip-back", 30, kit, function() Music.front().previous() end)
  back.LayoutOrder = 2
  local play, playIcon = circle(row, "play", 36, kit, function() Music.front().toggle() end, true)
  play.LayoutOrder = 3
  local forward = circle(row, "skip-forward", 30, kit, function() Music.front().next() end)
  forward.LayoutOrder = 4
  local _, shuffleIcon = circle(row, "shuffle", 28, kit, function() local ctl = Music.front(); ctl.setShuffle(not ctl.shuffle()) end)
  shuffleIcon.Parent.LayoutOrder = 5
  local coverKey
  local function paint()
    local ctl = Music.front()
    local track = ctl.track()
    title.set(track and track.title or "Nothing playing")
    artist.Text = track and track.artist or "Pick a song in the Music tab"
    status.Text = ctl.status() or (track and string.upper(ctl.label(track)) or "")
    local key = track and track.key or nil
    if key ~= coverKey then
      coverKey = key
      if track then ctl.cover(track, art) else art.Image = "" end
    end
    UI.setIcon(playIcon, ctl.state() == "playing" and "pause" or "play")
    kit.paint(heart, "ImageColor3", (track and Music.liked(track)) and "accent" or "text")
    kit.paint(shuffleIcon, "ImageColor3", ctl.shuffle() and "accent" or "text")
  end
  L.signal(Music.changed, paint)
  L.config("music.liked", paint)
  L.config("music.shuffle", paint)
  paint()
  local paintedFor
  L.every(function(dt)
    if not shown() then return end
    title.step(dt)
    local ctl = Music.front()
    local current = ctl.track()
    local stamp = (current and current.key or "") .. ctl.state() .. ctl.kind
    if stamp ~= paintedFor then paintedFor = stamp; paint() end
    local position, total = ctl.position(), ctl.length()
    fill.Size = UDim2.fromScale(total > 0 and math.clamp(position / total, 0, 1) or 0, 1)
    at.Text = Music.time(position)
    long.Text = Music.time(total)
  end, 30, "music.compact")
end

-- One line of a track list: cover, names, length, buttons.
local function trackRow(list, track, order, kit, actions)
  local square = kit.look == "unnamed"
  local height = square and 36 or 48
  local row = frame(list, { Name = "Track", Size = UDim2.new(1, -4, 0, height), LayoutOrder = order })
  if not square then round(row, 10) end
  local art = cover(row, kit, height - 10, { Position = UDim2.fromOffset(5, 5), ZIndex = 2 })
  Music.cover(track, art)
  local playing = Music.now and Music.now.key == track.key
  local x = height + 4
  local name = kit.text(row, track.title, { Position = UDim2.fromOffset(x, square and 2 or 6), Size = UDim2.new(1, -(x + 40 + #actions * 30), 0, kit.size + 5),
    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2 }, true, kit.size)
  kit.paint(name, "TextColor3", playing and "accent" or "text")
  local bits = { track.artist }
  local plays = Music.plays(track.plays)
  if plays then bits[#bits + 1] = plays end
  if track.preview then bits[#bits + 1] = "30 s preview" end
  if track.playable == false then bits[#bits + 1] = "can't play" end
  local sub = kit.text(row, table.concat(bits, "  ·  "), { Position = UDim2.fromOffset(x, (square and 2 or 6) + kit.size + 5),
    Size = UDim2.new(1, -(x + 40 + #actions * 30), 0, kit.size + 2), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2 }, false, kit.size - 2)
  kit.paint(sub, "TextColor3", "dim")
  local long = kit.text(row, (track.duration and track.duration > 0) and Music.time(track.duration) or "", { AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -(8 + #actions * 30), 0.5, 0), Size = UDim2.fromOffset(40, 14), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 2 }, false, kit.size - 2)
  kit.paint(long, "TextColor3", "faint")
  local hit = hitbox(row, { Name = "Play", Size = UDim2.new(1, -(6 + #actions * 30), 1, 0), ZIndex = 3 })
  hit.MouseEnter:Connect(function() kit.fill(row, "hover") end)
  hit.MouseLeave:Connect(function() kit.clear(row) end)
  row:SetAttribute("Key", track.key)
  if not actions.ownClick then
    hit.Activated:Connect(B.safe("music.row", function()
      if track.playable == false then return end
      UI.sfx("click", 0.4)
      Music.play(track)
    end))
  end
  for i, action in ipairs(actions) do
    local button, glyph = circle(row, action[1], 26, kit, function() action[2](track, row) end, false)
    button.AnchorPoint, button.Position = Vector2.new(1, 0.5), UDim2.new(1, -4 - (#actions - i) * 30, 0.5, 0)
    button.ZIndex = 4
    kit.paint(glyph, "ImageColor3", (action[3] and action[3](track)) and "accent" or "dim")
  end
  return row, hit
end
Music.trackRow = trackRow
-- a list that scrolls, drawn again by `fill(list, kit)` when asked
local function listBox(holder, top, fill)
  local kit = Window.kit(holder)
  local area = frame(holder, { Name = "List", Position = UDim2.fromOffset(0, top), Size = UDim2.new(1, 0, 1, -top), ClipsDescendants = true })
  local scroller = Instance.new("ScrollingFrame")
  scroller.BackgroundTransparency, scroller.BorderSizePixel = 1, 0
  scroller.Size = UDim2.fromScale(1, 1)
  scroller.AutomaticCanvasSize, scroller.CanvasSize = Enum.AutomaticSize.Y, UDim2.new()
  scroller.ScrollBarThickness = 3
  kit.paint(scroller, "ScrollBarImageColor3", "accent")
  scroller.ScrollingDirection = Enum.ScrollingDirection.Y
  scroller.Parent = area
  local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 2); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = scroller
  local function redraw()
    if not area.Parent then return end
    for _, child in ipairs(scroller:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
    B.try("music.list", fill, scroller, kit)
  end
  redraw()
  return scroller, redraw
end
local function empty(list, kit, text)
  local label = kit.text(list, text, { Size = UDim2.new(1, -16, 0, 40), TextWrapped = true, TextTruncate = Enum.TextTruncate.None }, false, kit.size - 1)
  kit.paint(label, "TextColor3", "dim")
  local padding = Instance.new("UIPadding"); padding.PaddingLeft = UDim.new(0, 8); padding.Parent = label
  return label
end
-- the menu of playlists a song can go in
local function addMenu(track, anchor, kit)
  local items = {}
  for _, item in ipairs(Music.playlists()) do
    items[#items + 1] = { label = item.name, icon = "list-music", run = function()
      Music.addTo(item.name, track)
      Window.toast({ title = "Added to " .. item.name, text = track.title, icon = "list-plus", time = 1.8 })
    end }
  end
  items[#items + 1] = { label = "Play next", icon = "skip-forward", run = function() Music.enqueue(track, true) end }
  items[#items + 1] = { label = "Add to the queue", icon = "list-plus", run = function()
    Music.enqueue(track)
    Window.toast({ title = "Queued", text = track.title, icon = "list-plus", time = 1.6 })
  end }
  if #Music.playlists() == 0 then items[#items + 1] = { label = "Make a playlist in Playlists", icon = "info", run = function() end } end
  kit.menu(anchor, items)
end
local function songActions()
  return {
    { "heart", function(t) Music.like(t, not Music.liked(t)) end, function(t) return Music.liked(t) end },
    { "list-plus", function(t, row) addMenu(t, row, Window.kit(row)) end },
  }
end

-- search: the source, the box, what it found
local SOURCES = { { "sc", "SoundCloud" }, { "au", "Audius" }, { "files", "Your files" }, { "link", "Link / id" } }
function Music.viewSearch(holder)
  local kit = Window.kit(holder)
  local L = life(holder)
  local square = kit.look == "unnamed"
  local tabs = frame(holder, { Name = "Sources", Size = UDim2.new(1, 0, 0, 30) })
  local tabLayout = Instance.new("UIListLayout")
  tabLayout.FillDirection, tabLayout.Padding, tabLayout.SortOrder = Enum.FillDirection.Horizontal, UDim.new(0, 6), Enum.SortOrder.LayoutOrder
  tabLayout.Parent = tabs
  local chips = {}
  for i, source in ipairs(SOURCES) do
    local chip = frame(tabs, { Size = UDim2.new(0.25, -5, 1, 0), LayoutOrder = i })
    if square then kit.outline(chip) else round(chip, true) end
    local label = kit.text(chip, source[2], { Name = "Source", Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center }, true, kit.size - 1)
    chips[source[1]] = { chip = chip, label = label }
    hitbox(chip).Activated:Connect(B.safe("music.source", function() UI.sfx("tab", 0.4); Config.set("music.source", source[1]) end))
  end
  local field = frame(holder, { Name = "Field", Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 34) })
  kit.fill(field, "field")
  if square then kit.outline(field) else round(field, 10) end
  icon(field, "search", 16, kit, "faint", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0) })
  local box = kit.entry(field, kit.size)
  box.Size, box.Position = UDim2.new(1, -110, 1, 0), UDim2.fromOffset(34, 0)
  box.Text = ""
  local go = frame(field, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(68, 26) })
  kit.fill(go, "accent")
  if square then kit.outline(go) else round(go, true) end
  -- (named: words on the accent are the accent's own ink, light or dark scheme)
  local goText = kit.text(go, "Search", { Name = "OnAccent", Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center }, true, kit.size - 1)
  kit.paint(goText, "TextColor3", "onAccent")
  local note = kit.text(holder, "", { Position = UDim2.fromOffset(2, 78), Size = UDim2.new(1, -4, 0, 16) }, false, kit.size - 1)
  kit.paint(note, "TextColor3", "dim")
  local _, redraw = listBox(holder, 98, function(list, k)
    local source = Config.get("music.source")
    if source == "link" then
      empty(list, k, "Paste a direct audio link (.mp3 .ogg .wav) or a Roblox audio id above, then press Enter.")
      return
    end
    if Music.resultsFor ~= source or #Music.results == 0 then
      empty(list, k, source == "files" and "Put .mp3, .ogg or .wav files in workspace/BasedHub/music, then press Enter."
        or (source == "au" and "Press Enter for what is trending on Audius, or type to search." or "Type an artist or a song, then press Enter."))
      return
    end
    for i, track in ipairs(Music.results) do trackRow(list, track, i, k, songActions()) end
  end)
  local function paintSource()
    local source = Config.get("music.source")
    for key, chip in pairs(chips) do
      local on = key == source
      kit.fill(chip.chip, on and "accent" or "field")
      kit.paint(chip.label, "TextColor3", on and "onAccent" or "dim")
    end
    box.PlaceholderText = source == "link" and "A link or an audio id" or (source == "files" and "Press Enter to list your files"
      or (source == "au" and "Search Audius (Enter alone: trending)" or "Search SoundCloud"))
    goText.Text = source == "link" and "Play" or (source == "files" and "List" or "Search")
    note.Text = ""
    redraw()
  end
  L.config("music.source", paintSource)
  local busy = false
  local function search()
    if busy then return end
    local source = Config.get("music.source")
    local text = box.Text
    if source == "link" then
      local track = Music.link(text)
      if not track then note.Text = "That is not a link or an audio id."; return end
      Music.play(track)
      note.Text = "Playing the link."
      return
    end
    if source == "sc" and #string.gsub(text, "%s", "") == 0 then note.Text = "Type something to look for."; return end
    busy = true
    note.Text = "Looking..."
    task.spawn(function()
      local list, why = Music.search(source, text)
      busy = false
      if not note.Parent then return end
      if list then
        note.Text = #list == 0 and "Nothing found." or (#list .. " found. Click one to play it.")
      else
        note.Text = "No results: " .. tostring(why)
      end
      redraw()
    end)
  end
  box.FocusLost:Connect(function(enter) if enter then search() end end)
  hitbox(go).Activated:Connect(B.safe("music.search", function() UI.sfx("click", 0.5); search() end))
  L.signal(Music.changed, function(what) if what == "track" or what == "liked" then redraw() end end)
  paintSource()
end
function Music.viewQueue(holder)
  local L = life(holder)
  local _, redraw = listBox(holder, 0, function(list, kit)
    if #Music.queue == 0 then empty(list, kit, "Nothing queued. Use + on a song, or play a playlist."); return end
    for i, track in ipairs(Music.queue) do
      local actions = { ownClick = true,
        { "arrow-up", function() Music.move(i, i - 1) end },
        { "x", function() Music.remove(i) end },
      }
      local row, hit = trackRow(list, track, i, kit, actions)
      hit.Activated:Connect(B.safe("music.queue.row", function()
        Music.index = i
        Music.play(track, true)
      end))
      if i == Music.index then kit.fill(row, "field") end
    end
  end)
  L.signal(Music.changed, function(what) if what == "queue" or what == "track" then redraw() end end)
end
function Music.viewLiked(holder)
  local L = life(holder)
  local _, redraw = listBox(holder, 0, function(list, kit)
    local liked = Config.get("music.liked") or {}
    if #liked == 0 then empty(list, kit, "Songs you like (the heart) are kept here."); return end
    for i, item in ipairs(liked) do
      local actions = { ownClick = true,
        { "list-plus", function(t, row) addMenu(t, row, Window.kit(row)) end },
        { "heart-off", function(t) Music.like(t, false) end },
      }
      local _, hit = trackRow(list, table.clone(item), i, kit, actions)
      hit.Activated:Connect(B.safe("music.liked.row", function() Music.playList(Config.get("music.liked") or {}, i) end))
    end
  end)
  L.config("music.liked", function() redraw() end)
  L.signal(Music.changed, function(what) if what == "track" then redraw() end end)
end
function Music.viewHistory(holder)
  local L = life(holder)
  local _, redraw = listBox(holder, 0, function(list, kit)
    local history = Config.get("music.history") or {}
    if #history == 0 then empty(list, kit, "What you play is listed here."); return end
    for i, item in ipairs(history) do
      if i > 40 then break end
      local track = table.clone(item)
      local actions = songActions()
      actions.ownClick = true
      local _, hit = trackRow(list, track, i, kit, actions)
      hit.Activated:Connect(B.safe("music.history.row", function() Music.play(track) end))
    end
  end)
  L.config("music.history", function() redraw() end)
end
-- playlists: make one, open one to see its songs, play it, delete it (twice)
function Music.viewPlaylists(holder)
  local kit = Window.kit(holder)
  local L = life(holder)
  local square = kit.look == "unnamed"
  local field = frame(holder, { Name = "New", Size = UDim2.new(1, 0, 0, 30) })
  kit.fill(field, "field")
  if square then kit.outline(field) else round(field, 9) end
  local box = kit.entry(field, kit.size)
  box.Size, box.Position = UDim2.new(1, -96, 1, 0), UDim2.fromOffset(10, 0)
  box.PlaceholderText, box.Text = "New playlist name", ""
  local make = frame(field, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -3, 0.5, 0), Size = UDim2.fromOffset(78, 24) })
  kit.fill(make, "accent")
  if square then kit.outline(make) else round(make, true) end
  local makeText = kit.text(make, "Create", { Name = "OnAccent", Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center }, true, kit.size - 1)
  kit.paint(makeText, "TextColor3", "onAccent")
  local opened, armed = nil, nil
  local redraw
  local _, draw = listBox(holder, 38, function(list, k)
    local lists = Music.playlists()
    if #lists == 0 then empty(list, k, "No playlists yet. Name one above, then add songs with + on any song."); return end
    local order = 0
    for _, item in ipairs(lists) do
      order += 1
      local row = frame(list, { Size = UDim2.new(1, -4, 0, square and 26 or 40), LayoutOrder = order })
      if not square then round(row, 10) end
      local open = opened == item.name
      kit.fill(row, open and "field" or "card")
      if square then kit.outline(row) end
      icon(row, "list-music", 16, k, "accent", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0) })
      local count = #(item.tracks or {})
      k.text(row, item.name, { Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -170, 1, 0) }, true, k.size)
      local sub = k.text(row, count .. (count == 1 and " song" or " songs"), { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -70, 0.5, 0),
        Size = UDim2.fromOffset(60, 14), TextXAlignment = Enum.TextXAlignment.Right }, false, k.size - 2)
      k.paint(sub, "TextColor3", "dim")
      local hit = hitbox(row, { Size = UDim2.new(1, -66, 1, 0), ZIndex = 3 })
      hit.Activated:Connect(B.safe("music.playlist.open", function()
        opened = (opened ~= item.name) and item.name or nil
        armed = nil
        redraw()
      end))
      local playButton = circle(row, "play", 26, k, function() Music.playList(item.tracks or {}) end, false)
      playButton.AnchorPoint, playButton.Position = Vector2.new(1, 0.5), UDim2.new(1, -36, 0.5, 0)
      local del, delIcon = circle(row, "trash-2", 26, k, function()
        if armed == item.name then
          armed = nil
          if opened == item.name then opened = nil end
          Music.deletePlaylist(item.name)
        else
          armed = item.name
          Window.toast({ title = "Click again to delete", text = item.name, icon = "trash-2", tone = "warn", time = 2 })
          task.delay(2.2, function() if armed == item.name then armed = nil; redraw() end end)
          redraw()
        end
      end, false)
      del.AnchorPoint, del.Position = Vector2.new(1, 0.5), UDim2.new(1, -6, 0.5, 0)
      k.paint(delIcon, "ImageColor3", armed == item.name and "bad" or "dim")
      if open then
        for i, t in ipairs(item.tracks or {}) do
          order += 1
          local _, songHit = trackRow(list, table.clone(t), order, k, { ownClick = true,
            { "x", function(tr) Music.removeFrom(item.name, tr.key) end },
          })
          -- (a song in a playlist plays the playlist from there)
          songHit.Activated:Connect(B.safe("music.playlist.song", function() Music.playList(item.tracks or {}, i) end))
        end
        if count == 0 then
          order += 1
          local hint = empty(list, k, "Empty: use + on any song to add it here.")
          hint.LayoutOrder = order
        end
      end
    end
  end)
  redraw = draw
  local function create()
    local made = Music.newPlaylist(box.Text)
    if made then
      box.Text = ""
      opened = made.name
      Window.toast({ title = "Playlist made", text = made.name, icon = "list-music", time = 1.6 })
      redraw()
    end
  end
  box.FocusLost:Connect(function(enter) if enter then create() end end)
  hitbox(make).Activated:Connect(B.safe("music.playlist.new", function() UI.sfx("click", 0.5); create() end))
  L.signal(Music.changed, function(what) if what == "playlists" then redraw() end end)
end

-- The words, in time: the card's scrolling lines, drawn in the look's own colours (the word being
-- sung in the cover's colour when the card has one)
function Music.viewLyrics(holder)
  local kit = Window.kit(holder)
  local L = life(holder)
  local function color(role)
    local ok, value = pcall(kit.color, role)
    return (ok and typeof(value) == "Color3") and value or Color3.new(1, 1, 1)
  end
  local list = B.Card.lyricList(holder, { font = kit.font(true), size = 18, gap = 12, z = 2, dim = color("dim"), colors = function()
    local now = B.Card.wordColor(color("accent"))
    return { sung = B.Lyrics.hex(color("text")), now = B.Lyrics.hex(now), next = B.Lyrics.hex(color("faint")) }
  end })
  L.every(function(dt)
    if Window.showing("music") then list.step(dt, Music.front()) end
  end, 30, "music.lyrics")
end

-- ---------------------------------------------------------------- where you were: the queue and the song, kept for next time
local function saveSession()
  if Config.get("music.resume") == false then return end
  local queue = {}
  for i, track in ipairs(Music.queue) do
    if i > 100 then break end
    queue[#queue + 1] = Music.compact(track)
  end
  Config.set("music.session", { queue = queue, index = Music.index, at = math.floor(Music.position()) })
end
local function restoreSession()
  local session = Config.get("music.session")
  if Config.get("music.resume") == false or type(session) ~= "table" or type(session.queue) ~= "table" or #session.queue == 0 then return end
  for _, track in ipairs(session.queue) do Music.queue[#Music.queue + 1] = table.clone(track) end
  Music.index = math.clamp(tonumber(session.index) or 1, 1, #Music.queue)
  Music.now = Music.queue[Music.index]
  Music.resumeAt = tonumber(session.at) or 0
  Music.state = "idle"
  Music.changed:fire("queue")
  Music.changed:fire("track")
end

-- ---------------------------------------------------------------- settings, keys, the tab
function Music.define()
  for id, default in pairs({ volume = 60, speed = 100, keepPitch = false, bass = 0, mid = 0, treble = 0, reverb = 0, even = false, fade = 0, shuffle = false,
    autoplay = true, mini = true, cacheMb = 800, tint = true, announce = true, resume = true }) do
    Config.define("music." .. id, default)
  end
  Config.define("music.repeat", "off")
  Config.define("music.source", "sc")
  Config.define("music.visual", "bars")
  for _, id in ipairs({ "music.liked", "music.history", "music.playlists" }) do Config.define(id, {}) end
  Config.define("music.session", {})
  for _, id in ipairs({ "music.liked", "music.history", "music.playlists", "music.session" }) do Config.unshared(id) end
  if B.Lyrics then B.Lyrics.define() end
  if B.Card then B.Card.define() end
  if B.PC then B.PC.define(); B.PC.start() end
  for _, id in ipairs({ "music.volume", "music.speed", "music.keepPitch", "music.bass", "music.mid", "music.treble", "music.reverb", "music.even" }) do
    Config.on(id, effects)
  end
  -- the keys work from the start (the tab itself may not be drawn yet)
  local ACTIONS = {
    { "music.toggle", "Music: play / pause", function() Music.front().toggle() end },
    { "music.next", "Music: next song", function() Music.front().next() end },
    { "music.previous", "Music: song before", function() Music.front().previous() end },
    { "music.like", "Music: like this song", function() local track = Music.front().track(); if track then Music.like(track, not Music.liked(track)) end end },
    { "music.louder", "Music: louder", function() Config.set("music.volume", math.min((Config.get("music.volume") or 60) + 10, 200)) end },
    { "music.quieter", "Music: quieter", function() Config.set("music.volume", math.max((Config.get("music.volume") or 60) - 10, 0)) end },
    { "music.size", "Music: big / small player", function() if B.Card then B.Card.toggleMode() end end },
  }
  for _, action in ipairs(ACTIONS) do
    Config.action(action[1], action[3])
    if B.Controls then B.Controls.bindables[action[1]] = B.Controls.bindables[action[1]] or { label = action[2], kind = "button" } end
  end
  Config.actionState("music.toggle", function() return Music.front().state() == "playing" end)
  restoreSession()
  B.onUnload:connect(function()
    saveSession()
    stopAll()
  end)
  Motion.every(function() if Music.state == "playing" then saveSession() end end, 1 / 15, "music.session")
end
B.pages = B.pages or {}
B.pages[#B.pages + 1] = function()
  Music.define()
  fs.mkdir(CACHE)
  fs.mkdir(ART)
  task.defer(function() if B.alive and B.Card then B.Card.start() end end)
  Window.page({ id = "music", title = "Music", icon = "music", group = "Hub", order = 870, eyebrow = "Your music, while you play", build = function(page)
    -- (stage: in a look whose Music tab has the player as its stage, Novoline's, this one is that)
    local now = page:section({ title = "Now playing", icon = "disc-3", full = true, stage = true })
    now:custom({ height = 214, name = "Player", build = function(f) Music.viewPlayer(f) end })
    local words = page:section({ title = "Lyrics", icon = "message-circle", full = true, desc = "Every word as it is sung. Click a line to go to it." })
    words:custom({ height = 260, name = "Lyrics", build = Music.viewLyrics })
    local find = page:section({ title = "Find music", icon = "search", full = true, desc = "SoundCloud songs start in a few seconds and are kept, so they start at once next time." })
    find:custom({ height = 420, name = "Search", build = Music.viewSearch })
    local queue = page:section({ title = "Queue", icon = "list-music", column = 1 })
    queue:custom({ height = 260, name = "Queue", build = Music.viewQueue })
    queue:button({ label = "Clear the queue", tip = "Removes every song from the queue.", text = "Clear", bindable = false, run = function() Music.clearQueue() end })
    local liked = page:section({ title = "Liked", icon = "heart", column = 2 })
    liked:custom({ height = 260, name = "Liked", build = Music.viewLiked })
    liked:button({ label = "Play every liked song", tip = "Plays all your liked songs.", text = "Play", bindable = false, run = function() Music.playList(Config.get("music.liked") or {}) end })
    local lists = page:section({ title = "Playlists", icon = "library", column = 1 })
    lists:custom({ height = 300, name = "Playlists", build = Music.viewPlaylists })
    local recent = page:section({ title = "Played lately", icon = "history", column = 2 })
    recent:custom({ height = 300, name = "History", build = Music.viewHistory })
    local sound = page:section({ title = "Sound", icon = "sliders-horizontal", column = 1 })
    sound:slider({ id = "music.volume", label = "Volume", tip = "How loud the music is.", min = 0, max = 200, step = 1, default = 60, suffix = "%" })
    sound:slider({ id = "music.speed", label = "Speed", tip = "How fast the song plays.", min = 50, max = 200, step = 5, default = 100, suffix = "%" })
    sound:toggle({ id = "music.keepPitch", label = "Keep the pitch", desc = "Faster or slower without the voice going high or low.", default = false, bindable = false })
    sound:slider({ id = "music.bass", label = "Bass", tip = "More or less low end.", min = -10, max = 20, step = 1, default = 0, suffix = " dB" })
    sound:slider({ id = "music.mid", label = "Middle", tip = "More or less middle.", min = -10, max = 10, step = 1, default = 0, suffix = " dB" })
    sound:slider({ id = "music.treble", label = "Treble", tip = "More or less high end.", min = -10, max = 10, step = 1, default = 0, suffix = " dB" })
    sound:slider({ id = "music.reverb", label = "Echo", tip = "Adds room sound.", min = 0, max = 100, step = 5, default = 0, suffix = "%" })
    sound:toggle({ id = "music.even", label = "Even loudness", desc = "Quiet and loud songs end up closer.", default = false, bindable = false })
    sound:slider({ id = "music.fade", label = "Crossfade", desc = "Songs blend into the next. 0: off.", min = 0, max = 10, step = 1, default = 0, suffix = " s" })
    local player = page:section({ title = "Player", icon = "settings-2", column = 2 })
    player:button({ id = "music.toggle", label = "Play / pause", tip = "Plays or pauses the song.", text = "Toggle", run = function() Music.front().toggle() end })
    player:button({ id = "music.next", label = "Next song", tip = "Skips to the next song.", text = "Next", run = function() Music.front().next() end })
    player:button({ id = "music.previous", label = "Song before", tip = "Goes back a song.", text = "Back", run = function() Music.front().previous() end })
    player:button({ id = "music.size", label = "Big / small player", tip = "Switches the on-screen player's size.", text = "Switch", run = function() if B.Card then B.Card.toggleMode() end end })
    player:button({ id = "music.like", label = "Like this song", tip = "Adds the song to your liked list.", text = "Like", run = function() local track = Music.front().track(); if track then Music.like(track, not Music.liked(track)) end end })
    player:toggle({ id = "music.autoplay", label = "Keep playing", desc = "When the queue ends, songs like the last one play.", default = true, bindable = false })
    player:toggle({ id = "music.resume", label = "Pick up where you were", desc = "The queue and the song come back next time.", default = true, bindable = false })
    player:toggle({ id = "music.announce", label = "Show each new song", tip = "A message when a new song starts.", default = true, bindable = false })
    local look = page:section({ title = "Look", icon = "palette", column = 1 })
    look:toggle({ id = "music.mini", label = "Player on screen", desc = "While the menu is shut. Tap its cover: big or small.", default = true, bindable = false })
    look:toggle({ id = "music.island", label = "Island", desc = "The line being sung, at the top of the screen.", default = true, bindable = false })
    look:segmented({ id = "music.visual", label = "Bars", tip = "How the music bars look.", options = { { "bars", "Bars" }, { "off", "Off" } }, default = "bars" })
    look:toggle({ id = "music.tint", label = "Cover colour", desc = "The player takes the colour of the cover.", default = true, bindable = false })
    look:toggle({ id = "music.lyrics", label = "Lyrics", desc = "Looked up for each song (LRCLIB, NetEase).", default = true, bindable = false })
    look:slider({ id = "music.lyricsShift", label = "Lyrics timing", desc = "Up: the words come sooner.", min = -2000, max = 2000, step = 100, default = 0, suffix = " ms" })
    local pc = page:section({ title = "Music on this PC", icon = "monitor", column = 2, desc = "Spotify, Apple Music or a browser, worked from here." })
    pc:toggle({ id = "music.pc", label = "Show what this PC plays", tip = "Shows Spotify or browser music in the game.", default = false, bindable = false })
    local pcLine = pc:note({ icon = "info", text = "" })
    pc:button({ label = "Set up (copies a command)", tip = "Copies the command that sets up PC music.", text = "Set up", bindable = false, run = function()
      local command, why = B.PC.install()
      if not command then
        Window.toast({ title = "Could not set it up", text = tostring(why), icon = "triangle-alert", tone = "bad" })
        return
      end
      Config.set("music.pc", true)
      B.clipboard(command)
      Window.toast({ title = "Command copied", text = "Press Win+R, paste it, press Enter.", icon = "clipboard", time = 6 })
    end })
    pc:button({ label = "Close the helper", tip = "Stops the PC music helper.", text = "Close", bindable = false, run = function() B.PC.send("quit") end })
    Motion.every(function()
      if pcLine.frame.Parent and Window.showing("music") then pcLine.set(B.PC.describe()) end
    end, 2, "music.pcLine")
    local keep = page:section({ title = "Kept songs", icon = "hard-drive", column = 2 })
    keep:slider({ id = "music.cacheMb", label = "Keep up to", desc = "Songs kept on disk start at once next time.", min = 100, max = 5000, step = 100, default = 800, suffix = " MB" })
    local line = keep:note({ icon = "info", text = "" })
    keep:button({ label = "Clear kept songs", tip = "Deletes downloaded songs to free space.", text = "Clear", style = "danger", bindable = false, run = function()
      Music.clearCache()
      Window.toast({ title = "Kept songs cleared", icon = "trash-2" })
    end })
    Motion.every(function()
      if not (line.frame.Parent and Window.showing("music")) then return end
      local size, count = Music.cacheSize()
      line.set(string.format("%d songs kept, %.0f MB. Your own files go in workspace/BasedHub/music.", count, size / 1048576))
    end, 0.5, "music.cacheLine")
  end })
end
end

do -- 46_cover.lua
-- ============================================================================
--  46 cover    the colour of a song's cover, for the music player's tint
--
--  Measured 2026-10-21: an EditableImage reads a PNG from a custom asset, but
--  refuses a JPEG ("Failed to load texture, unexpected format"), and covers
--  are JPEG. So the JPEG is read here, only as far as its DC coefficients:
--  each 8x8 block's average, which is plenty for one colour. Baseline and
--  progressive files (Huffman coding), any sampling. PNGs go through the
--  EditableImage. It yields as it goes, so a big cover costs no frame.
-- ============================================================================
local S = B.S
local Cover = {}
B.Cover = Cover

local band, rshift = bit32.band, bit32.rshift
local byte = string.byte
local floor, ceil = math.floor, math.ceil

local function u16(s, i) return (byte(s, i) or 0) * 256 + (byte(s, i + 1) or 0) end
local function huffman(counts, symbols)
  local maxcode, valptr, mincode = {}, {}, {}
  local code, k = 0, 1
  for len = 1, 16 do
    local n = counts[len]
    if n > 0 then
      valptr[len], mincode[len] = k, code
      code += n
      k += n
      maxcode[len] = code - 1
    else
      maxcode[len] = -1
    end
    code *= 2
  end
  return { maxcode = maxcode, valptr = valptr, mincode = mincode, symbols = symbols }
end

-- the bits of one scan (0xFF00 is a stuffed 0xFF; another marker reads as zeros)
local data, pos, cur, left = "", 1, 0, 0
local function bit()
  if left == 0 then
    local b = byte(data, pos) or 0
    if b == 0xFF then
      local after = byte(data, pos + 1) or 0
      if after == 0 then pos += 2 else b = 0 end
    else
      pos += 1
    end
    cur, left = b, 8
  end
  left -= 1
  return band(rshift(cur, left), 1)
end
local function bits(n)
  local v = 0
  for _ = 1, n do v = v * 2 + bit() end
  return v
end
local function decode(h)
  if not h then return 0 end
  local code = 0
  for len = 1, 16 do
    code = code * 2 + bit()
    if code <= h.maxcode[len] then return h.symbols[h.valptr[len] + code - h.mincode[len]] or 0 end
  end
  return 0
end
local function extend(v, size)
  if size == 0 then return 0 end
  if v < 2 ^ (size - 1) then return v - 2 ^ size + 1 end
  return v
end
local function nextMarker(s, at)
  while at < #s do
    if byte(s, at) == 0xFF then
      local m = byte(s, at + 1) or 0
      if m ~= 0 and not (m >= 0xD0 and m <= 0xD7) and m ~= 0xFF then return at end
    end
    at += 1
  end
  return #s
end

-- each component's block averages (DC), on the grid of an interleaved scan
local function readJpeg(s, yield)
  if u16(s, 1) ~= 0xFFD8 then return nil end
  local quant, dcTables, acTables = {}, {}, {}
  local frame, interval = nil, 0
  local i, work = 3, 0
  while i < #s do
    if byte(s, i) ~= 0xFF then i += 1; continue end
    local m = byte(s, i + 1) or 0
    if m == 0xFF then i += 1; continue end
    if m == 0xD8 or m == 0x01 or (m >= 0xD0 and m <= 0xD7) then i += 2; continue end
    if m == 0xD9 then break end
    local length = u16(s, i + 2)
    local seg, stop = i + 4, i + 2 + length
    if m == 0xDB then
      local j = seg
      while j < stop do
        local pq, tq = rshift(byte(s, j), 4), band(byte(s, j), 15)
        quant[tq] = pq == 0 and byte(s, j + 1) or u16(s, j + 1)
        j += 1 + (pq == 0 and 64 or 128)
      end
    elseif m == 0xC0 or m == 0xC1 or m == 0xC2 then
      frame = { progressive = m == 0xC2, height = u16(s, seg + 1), width = u16(s, seg + 3), comps = {} }
      local hmax, vmax = 1, 1
      for c = 1, byte(s, seg + 5) do
        local base = seg + 6 + (c - 1) * 3
        local hv = byte(s, base + 1)
        local comp = { id = byte(s, base), h = math.max(rshift(hv, 4), 1), v = math.max(band(hv, 15), 1), tq = byte(s, base + 2), pred = 0, grid = {}, done = false }
        hmax, vmax = math.max(hmax, comp.h), math.max(vmax, comp.v)
        frame.comps[c] = comp
      end
      frame.mcux, frame.mcuy = ceil(frame.width / (8 * hmax)), ceil(frame.height / (8 * vmax))
      for _, comp in ipairs(frame.comps) do
        comp.bw = ceil(ceil(frame.width * comp.h / hmax) / 8)
        comp.bh = ceil(ceil(frame.height * comp.v / vmax) / 8)
        comp.gw = frame.mcux * comp.h
      end
    elseif m == 0xC4 then
      local j = seg
      while j < stop do
        local tc, th = rshift(byte(s, j), 4), band(byte(s, j), 15)
        local counts, total = {}, 0
        for k = 1, 16 do counts[k] = byte(s, j + k) or 0; total += counts[k] end
        local symbols = {}
        for k = 1, total do symbols[k] = byte(s, j + 16 + k) or 0 end
        if tc == 0 then dcTables[th] = huffman(counts, symbols) else acTables[th] = huffman(counts, symbols) end
        j += 17 + total
      end
    elseif m == 0xDD then
      interval = u16(s, seg)
    elseif m == 0xC3 or (m >= 0xC5 and m <= 0xCF and m ~= 0xC8 and m ~= 0xCC) then
      return nil  -- (lossless or arithmetic coding: not covers)
    elseif m == 0xDA then
      if not frame then return nil end
      local count = byte(s, seg)
      local comps = {}
      for c = 1, count do
        local id, tables = byte(s, seg + 1 + (c - 1) * 2), byte(s, seg + 2 + (c - 1) * 2)
        for _, comp in ipairs(frame.comps) do
          if comp.id == id then comp.td, comp.ta = rshift(tables, 4), band(tables, 15); comps[#comps + 1] = comp end
        end
      end
      local after = seg + 1 + count * 2
      local ss, ah, al = byte(s, after), rshift(byte(s, after + 2), 4), band(byte(s, after + 2), 15)
      local wanted = (not frame.progressive) or (ss == 0 and ah == 0)
      if wanted then
        data, pos, left = s, stop, 0
        local skipAC = not frame.progressive
        local scale = 2 ^ al
        for _, comp in ipairs(comps) do comp.pred = 0 end
        local function restart()
          left = 0
          if byte(s, pos) == 0xFF and (byte(s, pos + 1) or 0) >= 0xD0 and (byte(s, pos + 1) or 0) <= 0xD7 then pos += 2 end
          for _, comp in ipairs(comps) do comp.pred = 0 end
        end
        local function block(comp, bx, by)
          local size = decode(dcTables[comp.td])
          comp.pred += extend(bits(size), size)
          comp.grid[by * comp.gw + bx] = comp.pred * scale
          if skipAC then
            local h, k = acTables[comp.ta], 1
            while k < 64 do
              local rs = decode(h)
              local r, sz = rshift(rs, 4), band(rs, 15)
              if sz == 0 then
                if r == 15 then k += 16 else break end
              else
                k += r
                bits(sz)
                k += 1
              end
            end
          end
          work += 1
          if yield and work % 300 == 0 then yield() end
        end
        if #comps > 1 then
          for n = 0, frame.mcux * frame.mcuy - 1 do
            if interval > 0 and n > 0 and n % interval == 0 then restart() end
            local mx, my = n % frame.mcux, n // frame.mcux
            for _, comp in ipairs(comps) do
              for v = 0, comp.v - 1 do
                for h = 0, comp.h - 1 do block(comp, mx * comp.h + h, my * comp.v + v) end
              end
            end
          end
        elseif comps[1] then
          local comp, n = comps[1], 0
          for by = 0, comp.bh - 1 do
            for bx = 0, comp.bw - 1 do
              if interval > 0 and n > 0 and n % interval == 0 then restart() end
              block(comp, bx, by)
              n += 1
            end
          end
        end
        for _, comp in ipairs(comps) do comp.done = true end
      end
      i = nextMarker(s, math.max(pos, stop))
      -- (every component's averages are in: the rest of a progressive file is detail)
      local all = true
      for _, comp in ipairs(frame.comps) do if not comp.done then all = false end end
      if all then break end
      continue
    end
    i = stop
  end
  if not frame or not frame.comps[1] or not frame.comps[1].done then return nil end
  return frame, quant
end

-- a few hundred colours from the block averages
local function jpegColors(s, yield)
  local frame, quant = readJpeg(s, yield)
  if not frame then return nil end
  local Y, Cb, Cr = frame.comps[1], frame.comps[2], frame.comps[3]
  local function q(comp) return quant[comp.tq] or 1 end
  local out = {}
  local step = math.max(1, floor(math.sqrt(Y.bw * Y.bh / 900)))
  for by = 0, Y.bh - 1, step do
    for bx = 0, Y.bw - 1, step do
      local y = (Y.grid[by * Y.gw + bx] or 0) * q(Y) / 8 + 128
      local r, g, b = y, y, y
      if Cb and Cr and Cb.done and Cr.done then
        local cx, cy = floor(bx * Cb.h / Y.h), floor(by * Cb.v / Y.v)
        local cb = (Cb.grid[cy * Cb.gw + cx] or 0) * q(Cb) / 8
        local cr = (Cr.grid[cy * Cr.gw + cx] or 0) * q(Cr) / 8
        r, g, b = y + 1.402 * cr, y - 0.344136 * cb - 0.714136 * cr, y + 1.772 * cb
      end
      out[#out + 1] = Color3.new(math.clamp(r / 255, 0, 1), math.clamp(g / 255, 0, 1), math.clamp(b / 255, 0, 1))
    end
  end
  return out
end
local function pngColors(path)
  if type(getcustomasset) ~= "function" then return nil end
  local okId, id = pcall(getcustomasset, path)
  if not okId then return nil end
  local ok, image = pcall(function() return S.AssetService:CreateEditableImageAsync(Content.fromUri(id)) end)
  B.identity()
  if not ok or not image then return nil end
  local out = {}
  pcall(function()
    local size = image.Size
    local pixels = image:ReadPixelsBuffer(Vector2.zero, size)
    local total = size.X * size.Y
    local stride = math.max(1, floor(total / 900))
    for n = 0, total - 1, stride do
      local at = n * 4
      out[#out + 1] = Color3.fromRGB(buffer.readu8(pixels, at), buffer.readu8(pixels, at + 1), buffer.readu8(pixels, at + 2))
    end
  end)
  pcall(function() image:Destroy() end)
  return out
end

-- the colour that stands out: hues weighed by how vivid they are, the heaviest one's average
function Cover.pick(colors)
  if not colors or #colors == 0 then return nil end
  local bins = {}
  local r0, g0, b0 = 0, 0, 0
  for _, c in ipairs(colors) do
    r0, g0, b0 = r0 + c.R, g0 + c.G, b0 + c.B
    local h, sat, val = c:ToHSV()
    if val > 0.16 and sat > 0.2 then
      local key = floor(h * 18) % 18
      local weight = sat * (1.2 - math.abs(val - 0.62))
      local bin = bins[key]
      if not bin then bin = { w = 0, r = 0, g = 0, b = 0 }; bins[key] = bin end
      bin.w += weight
      bin.r, bin.g, bin.b = bin.r + c.R * weight, bin.g + c.G * weight, bin.b + c.B * weight
    end
  end
  local best
  for _, bin in pairs(bins) do if not best or bin.w > best.w then best = bin end end
  if not best or best.w < #colors * 0.03 then
    -- (a grey cover: its own grey, kept dark)
    local n = #colors
    local _, _, val = Color3.new(r0 / n, g0 / n, b0 / n):ToHSV()
    return Color3.fromHSV(0, 0, math.clamp(val * 0.6, 0.16, 0.42))
  end
  local h, sat, val = Color3.new(best.r / best.w, best.g / best.w, best.b / best.w):ToHSV()
  return Color3.fromHSV(h, math.clamp(sat * 1.12, 0.38, 0.92), math.clamp(val, 0.42, 0.86))
end

-- path of a cover file -> Color3 (or nil); yields while it reads
-- (one at a time: the bit reader is shared, and it yields)
local busy = false
function Cover.color(path)
  local ok, s = pcall(readfile, path)
  if not ok or type(s) ~= "string" or #s < 64 then return nil end
  while busy do task.wait() end
  busy = true
  local colors
  if string.sub(s, 1, 8) == "\137PNG\r\n\26\n" then
    local done, got = pcall(pngColors, path)
    colors = done and got or nil
  elseif u16(s, 1) == 0xFFD8 then
    local done, got = pcall(jpegColors, s, task.wait)
    colors = done and got or nil
  end
  busy = false
  local picked, color = pcall(Cover.pick, colors)
  return picked and color or nil
end
Cover.test = { readJpeg = readJpeg, jpegColors = jpegColors }
end

do -- 47_lyrics.lua
-- ============================================================================
--  47 lyrics   the words of the song, in time: the lines from LRCLIB, the time
--              of each word from NetEase where it has it
--
--  Measured 2026-10-25 from this PC:
--    * LRCLIB (lrclib.net: open, no key) answers a search in 1 to 3 s, and had
--      lines with times for every song tried.
--    * NetEase (music.163.com: no key) cloud search + song/lyric/v1 "yrc" has
--      each word's own time. Its first match had them for 4 of 12 songs;
--      looking through its first three matches found them for 10 of 10
--      popular songs. 1 to 4 s.
--    * Where only the lines have times, each line's words are spread over the
--      time it is sung, by their letters: 0.08 s a letter + 0.2 s, at least
--      0.6 s, each word weighed by its letters + 1. Against the real word times
--      of those 10 songs (4,892 words): half the words within 0.16 s, nine in
--      ten within 0.67 s (slow, held notes are the worst). Every word at its
--      line's start would be 1.05 s and 2.94 s.
--  Kept on disk (music/lyrics). A song with none is asked for again in 3 days.
-- ============================================================================
local S, Config, fs = B.S, B.Config, B.fs
local Http = S.HttpService
local Lyrics = { entries = {}, byTrack = {}, changed = B.Signal.new() }
B.Lyrics = Lyrics

local FOLDER = fs.path("music/lyrics")
local AGENT = "BASEDHub/1.0 (https://github.com/Mrzaytoon/based-hub)"
local BROWSER = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
local NETEASE = "https://music.163.com"
local PER_LETTER, PLUS, LEAST = 0.08, 0.2, 0.6
local RETRY = 3 * 86400

-- ---------------------------------------------------------------- the web
local function get(url, agent, referer)
  local send = (type(request) == "function" and request) or (type(http_request) == "function" and http_request) or nil
  local code, body = -1, nil
  if send then
    local headers = { ["User-Agent"] = agent or AGENT }
    if referer then headers.Referer = referer end
    local ok, response = pcall(send, { Url = url, Method = "GET", Headers = headers })
    if ok and type(response) == "table" then code, body = response.StatusCode or 0, response.Body end
  else
    local ok, text = pcall(game.HttpGet, game, url)
    if ok then code, body = 200, text end
  end
  B.identity()
  return code, body
end
local function json(text)
  if type(text) ~= "string" then return nil end
  local ok, value = pcall(Http.JSONDecode, Http, text)
  return ok and value or nil
end
local function encode(text) return Http:UrlEncode(tostring(text or "")) end
local function trim(text) return (string.match(tostring(text or ""), "^%s*(.-)%s*$")) end
local function letters(text)
  local ok, n = pcall(utf8.len, text)
  return (ok and n) or #text
end

-- ---------------------------------------------------------------- names
-- a name as names are compared: lower case, letters and digits, single spaces
local function plain(text)
  text = string.lower(tostring(text or ""))
  text = string.gsub(text, "&", " and ")
  text = string.gsub(text, "[%p%c]+", " ")
  text = string.gsub(text, "%s+", " ")
  return trim(text)
end
Lyrics.plain = plain
-- what in brackets is not part of a song's name. ("remix", "slowed", "sped up", "live" stay: those
-- are other recordings, with other times)
local NOISE = { "official", "audio", "video", "lyric", "visuali", "prod", "remaster", "explicit", "clean", "dirty", "hq", "hd", "4k",
  "music video", "free dl", "download", "leak", "snippet", "unreleased", "feat", "ft.", "ft ", "with ", "bass boost", "8d", "copyright", "mv" }
local function noise(inner)
  local low = string.lower(inner)
  for _, word in ipairs(NOISE) do
    if string.find(low, word, 1, true) then return "" end
  end
  return nil
end
-- a song's title and artist as a lyrics site names them: "Artist - Title" split, the noise in
-- brackets and the featured artists taken off. The third answer says the name was split (uploads
-- write "Title - Artist" too: the other way round is tried as well).
function Lyrics.clean(title, artist)
  title, artist = tostring(title or ""), tostring(artist or "")
  title = string.gsub(string.gsub(title, "\u{2013}", "-"), "\u{2014}", "-")
  local left, right = string.match(title, "^(.-)%s+%-%s+(.+)$")
  local split = false
  if left and right and trim(left) ~= "" then artist, title, split = left, right, true end
  title = string.gsub(title, "%s*(%b())", function(inner) return noise(inner) end)
  title = string.gsub(title, "%s*(%b[])", function(inner) return noise(inner) end)
  title = string.gsub(title, "%s+[fF][eE]?[aA]?[tT]%.?%s.*$", "")
  title = string.gsub(title, "%s+[wW]/%s.*$", "")
  artist = string.gsub(artist, "%s*%b()", "")
  artist = string.gsub(artist, "%s*%-%s*[Tt]opic$", "")
  artist = string.gsub(artist, "VEVO$", "")
  return trim(title), trim(artist), split
end
-- the first of several artists ("A, B & C" -> "A")
local function firstArtist(artist)
  local first = string.match(artist, "^(.-)%s*[,&]%s") or string.match(artist, "^(.-)%s+[xX]%s") or string.match(artist, "^(.-)%s+[Ff]eat")
  return first and trim(first) or artist
end

-- ---------------------------------------------------------------- reading lyrics
local function stamp(text)
  local m, s, f = string.match(text, "^(%d+):(%d+)[%.:]?(%d*)$")
  if not m then return nil end
  local fraction = (f ~= "" and tonumber(f) / (10 ^ #f)) or 0
  return tonumber(m) * 60 + tonumber(s) + fraction
end
local function lines(text)
  return string.gmatch(text .. "\n", "([^\r\n]*)\r?\n")
end
-- LRC: "[mm:ss.xx]words", several times on one line, an [offset:], and the words' own times
-- ("<mm:ss.xx>word") where a file has them
function Lyrics.parseLrc(text)
  local out, offset = {}, 0
  for raw in lines(tostring(text or "")) do
    local shift = string.match(raw, "^%s*%[offset:%s*([%+%-]?%d+)%s*%]")
    -- (the "+" taken off first: not every tonumber reads one)
    local value = shift and tonumber((string.gsub(shift, "^%+", ""))) or nil
    if value then offset = value / 1000 end
    local times, rest = {}, raw
    while true do
      local tag, after = string.match(rest, "^%s*%[([%d:%.]+)%](.*)$")
      if not tag then break end
      local t = stamp(tag)
      if t then times[#times + 1] = t end
      rest = after
    end
    if #times > 0 then
      local words
      if string.find(rest, "<%d+:%d+") then
        words = {}
        for tag, word in string.gmatch(rest, "<([%d:%.]+)>([^<]*)") do
          local t = stamp(tag)
          if t and trim(word) ~= "" then words[#words + 1] = { t = t, w = word } end
        end
        rest = string.gsub(rest, "<[%d:%.]+>", "")
        if #words == 0 then words = nil end
      end
      for k, t in ipairs(times) do
        out[#out + 1] = { t = t, text = trim(rest), words = k == 1 and words or nil }
      end
    end
  end
  table.sort(out, function(a, b) return a.t < b.t end)
  -- ("+" in an [offset:] brings the words sooner)
  if offset ~= 0 then
    for _, line in ipairs(out) do
      line.t -= offset
      for _, word in ipairs(line.words or {}) do word.t -= offset end
    end
  end
  return out
end
-- NetEase's word timing: "[start,length](start,length,0)word(start,length,0)word...", in ms. A
-- word runs up to the next mark (it can hold brackets of its own).
function Lyrics.parseYrc(text)
  local out = {}
  for raw in lines(tostring(text or "")) do
    local ls, ld, rest = string.match(raw, "^%[(%d+),(%d+)%](.*)$")
    if ls then
      local words, at = {}, 1
      while true do
        local s, e, ws, wd = string.find(rest, "%((%d+),(%d+),%-?%d+%)", at)
        if not s then break end
        local following = string.find(rest, "%(%d+,%d+,%-?%d+%)", e + 1)
        local word = string.sub(rest, e + 1, (following or (#rest + 1)) - 1)
        if trim(word) ~= "" then
          local start = tonumber(ws) / 1000
          words[#words + 1] = { t = start, e = start + tonumber(wd) / 1000, w = word }
        end
        if not following then break end
        at = following
      end
      if #words > 0 then
        local parts = {}
        for i, word in ipairs(words) do parts[i] = word.w end
        local start = tonumber(ls) / 1000
        out[#out + 1] = { t = start, e = start + tonumber(ld) / 1000, text = trim(table.concat(parts)), words = words }
      end
    end
  end
  table.sort(out, function(a, b) return a.t < b.t end)
  return out
end
-- the credits a Chinese lyrics file opens with ("作词 : ...") are not words of the song
local function dropCredits(list)
  local out = {}
  for _, line in ipairs(list) do
    local credit = string.find(line.text, "^[^%w]*[\128-\255]+%s*[:\u{FF1A}]") ~= nil
    if not credit then out[#out + 1] = line end
  end
  return out
end
Lyrics.dropCredits = dropCredits

-- every line gets an end and words with times: the file's own, or spread over the line (see the top)
function Lyrics.spread(list, length)
  for i, line in ipairs(list) do
    local after = list[i + 1]
    local limit = after and after.t or (line.t + 8)
    if length and length > 0 and not after then limit = math.max(math.min(limit, length), line.t + 0.5) end
    local gap = math.max(limit - line.t, 0.2)
    if not line.e then
      line.e = line.t + math.max(math.min(gap - 0.05, math.max(LEAST, letters(line.text) * PER_LETTER + PLUS)), 0.15)
    end
    if line.words then
      -- (words with a start and no end end where the next one starts)
      for k, word in ipairs(line.words) do
        if not word.e then
          local nextWord = line.words[k + 1]
          word.e = nextWord and nextWord.t or math.max(line.e, word.t + 0.2)
        end
      end
    elseif line.text ~= "" then
      local parts = {}
      for word in string.gmatch(line.text, "%S+") do parts[#parts + 1] = word end
      local total = 0
      local weights = {}
      for k, word in ipairs(parts) do weights[k] = letters(word) + 1; total += weights[k] end
      local t, span = line.t, line.e - line.t
      local words = {}
      for k, word in ipairs(parts) do
        local d = span * weights[k] / total
        words[k] = { t = t, e = t + d, w = k < #parts and (word .. " ") or word }
        t += d
      end
      line.words, line.guessed = words, true
    end
  end
  return list
end

-- ---------------------------------------------------------------- where the song is in them
-- the line at `t` (0 before the first), the word in it (0 before its first), how far through that word
function Lyrics.at(list, t)
  if not list or #list == 0 or t < list[1].t then return 0, 0, 0 end
  local lo, hi = 1, #list
  while lo < hi do
    local mid = (lo + hi + 1) // 2
    if list[mid].t <= t then lo = mid else hi = mid - 1 end
  end
  local line = list[lo]
  local word, through = 0, 0
  for k, w in ipairs(line.words or {}) do
    if w.t <= t then word = k else break end
  end
  local w = line.words and line.words[word]
  if w then through = math.clamp((t - w.t) / math.max(w.e - w.t, 0.05), 0, 1) end
  return lo, word, through
end
-- is line `i` being sung at `t`, or was it a moment ago (and nothing else has started)?
function Lyrics.live(list, i, t)
  local line = list and list[i]
  if not line or line.text == "" then return false end
  local after = list[i + 1]
  if after and t >= after.t then return false end
  return t <= (line.e or line.t) + 2.5
end

-- ---------------------------------------------------------------- drawing a line
local ESCAPE = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;", ["'"] = "&apos;" }
function Lyrics.escape(text) return (string.gsub(tostring(text or ""), "[&<>\"']", ESCAPE)) end
function Lyrics.hex(color)
  return string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end
-- rich text for a line: sung words, the word being sung, the rest. colors = { sung, now, next } (hex)
function Lyrics.markup(line, word, colors)
  if not line then return "" end
  if not line.words then return string.format('<font color="%s">%s</font>', colors.sung, Lyrics.escape(line.text)) end
  local out = {}
  for k, w in ipairs(line.words) do
    local color = (k < word and colors.sung) or (k == word and colors.now) or colors.next
    out[#out + 1] = string.format('<font color="%s">%s</font>', color, Lyrics.escape(w.w))
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------- finding them
-- the same artist, however it is spelled ("PlayboiCarti", "Playboi Carti", "Playboi Carti, X")
local function squash(text) return (string.gsub(plain(text), " ", "")) end
local function sameArtist(a, b)
  local x, y = squash(a), squash(b)
  return x ~= "" and y ~= "" and (x == y or string.find(x, y, 1, true) ~= nil or string.find(y, x, 1, true) ~= nil)
end
Lyrics.sameArtist = sameArtist
-- LRCLIB's best answer: lines with times first, then the closest length. (A recording of another
-- length is used only for its words: load() takes the times off.)
local function lrclibPick(list, length, artist, slack, needArtist)
  slack = slack or 12
  local best, bestScore
  for _, item in ipairs(type(list) == "table" and list or {}) do
    if type(item) == "table" and (item.syncedLyrics or item.plainLyrics or item.instrumental) and (not needArtist or sameArtist(item.artistName, artist)) then
      local score = (type(item.syncedLyrics) == "string" and 100) or (item.instrumental and 40) or 20
      local d = tonumber(item.duration)
      if length and length > 0 and d then
        local off = math.abs(d - length)
        if off > slack then score = -1 else score -= off * 4 end
      end
      if score >= 0 and artist ~= "" and plain(item.artistName) == plain(artist) then score += 10 end
      if score >= 0 and (not bestScore or score > bestScore) then best, bestScore = item, score end
    end
  end
  return best
end
local function fromLrclib(title, artist, length)
  local queries = { "track_name=" .. encode(title) .. "&artist_name=" .. encode(artist) }
  local first = firstArtist(artist)
  if first ~= artist and first ~= "" then queries[#queries + 1] = "track_name=" .. encode(title) .. "&artist_name=" .. encode(first) end
  queries[#queries + 1] = "q=" .. encode(title .. " " .. first)
  for _, query in ipairs(queries) do
    local code, body = get("https://lrclib.net/api/search?" .. query)
    if code == 200 then
      local item = lrclibPick(json(body), length, artist)
      if item then return item end
    end
  end
  -- the title alone (an artist spelled another way): a recording of the same length (3 s), or by
  -- the same artist at any length up to 30 s off
  local code, body = get("https://lrclib.net/api/search?track_name=" .. encode(title))
  if code == 200 then
    local list = json(body)
    return (length and length > 0 and lrclibPick(list, length, artist, 3)) or lrclibPick(list, length, artist, 30, true)
  end
  return nil
end
-- NetEase: the first three of its matches with the right name, artist and length, for the one with
-- each word's time (and, failing that, the first with timed lines)
local function fromNetease(title, artist, length)
  local code, body = get(NETEASE .. "/api/cloudsearch/pc?s=" .. encode(title .. " " .. firstArtist(artist)) .. "&type=1&limit=8", BROWSER, NETEASE .. "/")
  if code ~= 200 then return nil end
  local data = json(body)
  local songs = type(data) == "table" and type(data.result) == "table" and data.result.songs or nil
  if type(songs) ~= "table" then return nil end
  local want, who = plain(title), plain(firstArtist(artist))
  local looked, timedLines, timedLength = 0, nil, nil
  for _, song in ipairs(songs) do
    if looked >= 3 then break end
    if type(song) == "table" then
      local name = plain(song.name)
      local nameOk = name == want or (#want >= 4 and (string.find(name, want, 1, true) ~= nil or string.find(want, name, 1, true) ~= nil))
      local whoOk = who == ""
      for _, person in ipairs(type(song.ar) == "table" and song.ar or {}) do
        if sameArtist(type(person) == "table" and person.name or "", who) then whoOk = true end
      end
      local d = tonumber(song.dt) and song.dt / 1000 or nil
      local off = (length and length > 0 and d) and math.abs(d - length) or 0
      -- (the right artist at another length: its words, without times; anyone else's only at the same length)
      if nameOk and ((whoOk and off <= 30) or off <= 1.5) then
        looked += 1
        local c2, b2 = get(NETEASE .. "/api/song/lyric/v1?id=" .. tostring(song.id) .. "&lv=1&yv=1", BROWSER, NETEASE .. "/")
        local found = c2 == 200 and json(b2) or nil
        if type(found) == "table" then
          if found.pureMusic == true then return { kind = "instrumental", from = "NetEase" } end
          local yrc = type(found.yrc) == "table" and found.yrc.lyric or nil
          if type(yrc) == "string" and #Lyrics.parseYrc(yrc) > 0 then return { kind = "words", yrc = yrc, from = "NetEase", length = d } end
          local lrc = type(found.lrc) == "table" and found.lrc.lyric or nil
          if not timedLines and type(lrc) == "string" and #dropCredits(Lyrics.parseLrc(lrc)) > 2 then timedLines, timedLength = lrc, d end
        end
      end
    end
  end
  if timedLines then return { kind = "lines", lrc = timedLines, from = "NetEase", length = timedLength } end
  return nil
end
-- what is kept, made into lines to show
local function build(entry, kept, length)
  entry.kind, entry.from, entry.loose = kept.kind, kept.from, kept.loose == true
  entry.timed = false
  if kept.kind == "words" then
    entry.lines = Lyrics.spread(Lyrics.parseYrc(kept.yrc), length)
    entry.timed = true
  elseif kept.kind == "lines" then
    entry.lines = Lyrics.spread(dropCredits(Lyrics.parseLrc(kept.lrc)), length)
    entry.timed = true
  elseif kept.kind == "plain" then
    entry.lines = {}
    for raw in lines(kept.plain or "") do entry.lines[#entry.lines + 1] = { t = 0, text = trim(raw) } end
  else
    entry.lines = {}
  end
  if (kept.kind == "words" or kept.kind == "lines") and #entry.lines == 0 then entry.kind, entry.timed = "none", false end
  entry.state = (entry.kind == "none") and "none" or "ready"
end
local function load(entry, length)
  local path = FOLDER .. "/" .. entry.key .. ".json"
  local kept = fs.readJson(path)
  if type(kept) == "table" and kept.v == 1 and (kept.kind ~= "none" or os.time() - (tonumber(kept.at) or 0) < RETRY) then
    build(entry, kept, length)
    Lyrics.changed:fire(entry)
    return
  end
  -- NetEase alongside LRCLIB: whichever has each word's time wins
  local netease, neteaseDone = nil, false
  task.spawn(function()
    local ok, got = pcall(fromNetease, entry.title, entry.artist, length)
    if ok and not got and entry.split then ok, got = pcall(fromNetease, entry.artist, entry.title, length) end
    B.identity()
    netease, neteaseDone = ok and got or nil, true
  end)
  local item = fromLrclib(entry.title, entry.artist, length)
  if not item and entry.split then item = fromLrclib(entry.artist, entry.title, length) end
  local waited = 0
  while not neteaseDone and waited < 8 do waited += task.wait(0.1) end
  if netease and (netease.kind == "words" or netease.kind == "instrumental") then
    kept = netease
  elseif item and type(item.syncedLyrics) == "string" and item.syncedLyrics ~= "" then
    kept = { kind = "lines", lrc = item.syncedLyrics, from = "LRCLIB", length = tonumber(item.duration) }
  elseif netease then
    kept = netease
  elseif item and item.instrumental then
    kept = { kind = "instrumental", from = "LRCLIB" }
  elseif item and type(item.plainLyrics) == "string" and item.plainLyrics ~= "" then
    kept = { kind = "plain", plain = item.plainLyrics, from = "LRCLIB" }
  else
    kept = { kind = "none" }
  end
  -- another length of the song (a re-upload, a longer intro): its times would be wrong, so its words
  -- are shown without them
  if length and length > 0 and kept.length and math.abs(kept.length - length) > 4 and (kept.kind == "words" or kept.kind == "lines") then
    local list = kept.kind == "words" and Lyrics.parseYrc(kept.yrc) or dropCredits(Lyrics.parseLrc(kept.lrc))
    local words = {}
    for _, line in ipairs(list) do if line.text ~= "" then words[#words + 1] = line.text end end
    kept = { kind = "plain", plain = table.concat(words, "\n"), from = kept.from, loose = true }
  end
  kept.v, kept.at = 1, os.time()
  fs.mkdir(FOLDER)
  fs.writeJson(path, kept)
  build(entry, kept, length)
  Lyrics.changed:fire(entry)
end
local function keyOf(title, artist)
  local key = string.gsub(plain(artist) .. " " .. plain(title), "[^%w]+", "-")
  return string.sub(key, 1, 90)
end
-- the lyrics of a track: { state = "loading" | "ready" | "none", kind, lines, timed, from }, asked for
-- the first time a track is seen (nil: lyrics are off, or the track has no name)
function Lyrics.forTrack(track)
  if not track or Config.get("music.lyrics") == false then return nil end
  local known = Lyrics.byTrack[track.key]
  if known then return known end
  local title, artist, split = Lyrics.clean(track.title, track.artist)
  if title == "" then return nil end
  local key = keyOf(title, artist)
  local entry = Lyrics.entries[key]
  if not entry then
    entry = { state = "loading", key = key, title = title, artist = artist, split = split, lines = {} }
    Lyrics.entries[key] = entry
    local length = tonumber(track.duration) or 0
    task.spawn(function()
      local ok, err = pcall(load, entry, length)
      B.identity()
      if not ok then
        B.fault("lyrics.load", err)
        entry.state, entry.kind = "none", "none"
        Lyrics.changed:fire(entry)
      end
    end)
  end
  Lyrics.byTrack[track.key] = entry
  return entry
end
-- the song's time as the words are read: the timing setting moves them sooner or later
function Lyrics.clock(position)
  return position + (Config.get("music.lyricsShift") or 0) / 1000
end
-- what a view shows while there are no lines
function Lyrics.note(entry)
  if not entry then return "Lyrics are off." end
  if entry.state == "loading" then return "Looking for the words..." end
  if entry.kind == "instrumental" then return "Instrumental" end
  if entry.state == "none" then return "No lyrics found for this one." end
  return nil
end

function Lyrics.define()
  Config.define("music.lyrics", true)
  Config.define("music.lyricsShift", 0)
end
end

do -- 48_pc.lua
-- ============================================================================
--  48 pc       music on this PC: what Spotify, Apple Music or a browser is
--              playing, shown in the hub and worked from it
--
--  A small helper (based/pc/based-music.ps1, written out by the hub as
--  BasedHub/pc/based-music.txt and started once with Win+R) reads Windows' own
--  "now playing" (the media sessions the volume flyout shows) and writes it
--  with the cover to BasedHub/pc/now.json. The hub writes what to do to
--  do.json. Files both ways: no port, no network, any executor. (Measured: the
--  executor refuses to write a .ps1 or a .cmd, "invalid file path", so the
--  command reads the .txt and runs it.)
--
--  Measured 2026-10-25 against a test session on this PC: the name, artist,
--  length, place and cover come through; play/pause, seek, the app's own
--  volume (the volume mixer) and quit work. The helper keeps to the app it
--  shows until another app STARTS playing (pausing Spotify from here does not
--  hand the player to a video in a browser). A place sent while paused shows
--  once it plays again (the app's own report), so the hub shows it at once.
-- ============================================================================
local S, Config, fs, Motion = B.S, B.Config, B.fs, B.Motion
local Http = S.HttpService
local PC = { state = nil, live = false, track = nil, changed = B.Signal.new(), sent = {}, id = 0, startedAt = 0 }
B.PC = PC

local DIR = fs.path("pc")
local NOW, ORDERS, ALIVE = DIR .. "/now.json", DIR .. "/do.json", DIR .. "/alive.txt"
local HELPER = DIR .. "/based-music.txt"
-- where an executor keeps its workspace, for the one-line command (others get a command that finds it)
local WORKSPACES = { potassium = "\\Potassium\\workspace" }

local function nowMs()
  local ok, ms = pcall(function() return DateTime.now().UnixTimestampMillis end)
  if ok and type(ms) == "number" then return ms end
  return os.time() * 1000
end
PC.nowMs = nowMs

-- ---------------------------------------------------------------- the helper
-- (under 259 letters either way: the Run box takes no more)
function PC.command()
  local root = WORKSPACES[string.lower(tostring(B.executor))]
  if root then
    return string.format("powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command \"$p=$env:LOCALAPPDATA+'%s\\%s\\pc\\based-music.txt';"
      .. "&([scriptblock]::Create((gc -Raw -LiteralPath $p))) -Dir (Split-Path $p)\"", root, fs.root)
  end
  -- (finds the newest copy under the places executors keep their files)
  return "powershell -NoP -W Hidden -Ep Bypass -C \"$f=gci $env:LOCALAPPDATA,$env:APPDATA -Fi based-music.txt -Rec -Dep 5 -EA 0|sort LastWriteTime|select -L 1;"
    .. "if($f){&([scriptblock]::Create((gc -Raw -LiteralPath $f.FullName))) -Dir $f.DirectoryName}\""
end
-- writes the helper next to the hub's files; the command that starts it
function PC.install()
  if type(B.PC_HELPER) ~= "string" or B.PC_HELPER == "" then return nil, "this build has no helper in it" end
  fs.mkdir(DIR)
  if not fs.write(HELPER, B.PC_HELPER) then return nil, "the executor would not write the helper" end
  fs.write(ALIVE, tostring(os.time()))
  return PC.command()
end

-- ---------------------------------------------------------------- what it says
local lastText
local function trackOf(s)
  local title = tostring(s.title or "")
  local artist = tostring(s.artist or "")
  local app = tostring(s.app or "An app")
  local key = "pc_" .. string.sub(string.gsub(string.lower(app .. "_" .. artist .. "_" .. title), "[^%w]+", "-"), 1, 80)
  local cover = (type(s.cover) == "string" and s.cover ~= "") and (DIR .. "/" .. s.cover) or nil
  local track = PC.track
  if not (track and track.key == key) then
    track = { source = "pc", key = key, playable = true }
  end
  track.title = title ~= "" and title or "Something on this PC"
  track.artist = artist ~= "" and artist or app
  track.album, track.app = tostring(s.album or ""), app
  track.duration = tonumber(s.length) or 0
  track.coverFile = cover
  return track
end
local function read()
  local text = fs.read(NOW)
  if text and text ~= lastText then
    lastText = text
    local ok, data = pcall(Http.JSONDecode, Http, text)
    if ok and type(data) == "table" then
      local before = PC.state
      PC.state = data
      local old = PC.track
      local playingBefore = before and before.playing == true
      if data.ok and not data.closed and not data.none and data.title then
        PC.track = trackOf(data)
      else
        PC.track = nil
      end
      if PC.track ~= old then PC.changed:fire("track") end
      if (data.playing == true) and (not playingBefore or PC.track ~= old) then PC.startedAt = os.clock() end
      if (before and before.playing) ~= data.playing then PC.changed:fire("state") end
      -- (a guess the helper has now answered goes)
      if PC.guess and PC.guess.track ~= data.track then PC.guess = nil end
    end
  end
  local s = PC.state
  local live = s ~= nil and s.ok == true and not s.closed and (nowMs() - (tonumber(s.at) or 0)) < 4000
  if live ~= PC.live then
    PC.live = live
    PC.changed:fire("live")
  end
end
PC.read = read

-- ---------------------------------------------------------------- telling it what to do
-- This load's own name for its orders, made with the first one: a reload starts a new name, so the
-- helper never takes new orders for ones it has done. (Measured 2026-10-28: math.random gave the same
-- first number on every load, so two loads shared a name and the second one's orders were passed over.)
local session
function PC.send(what, value)
  session = session or string.format("%x-%04x", math.floor(nowMs()), math.random(0, 0xFFFF))
  PC.id += 1
  PC.sent[#PC.sent + 1] = { id = PC.id, ["do"] = what, to = value }
  while #PC.sent > 12 do table.remove(PC.sent, 1) end
  fs.mkdir(DIR)
  fs.writeJson(ORDERS, { s = session, cmds = PC.sent })
end
function PC.playing()
  local guess = PC.guess
  if guess and guess.playing ~= nil and os.clock() < guess.till then return guess.playing end
  return PC.live and PC.state ~= nil and PC.state.playing == true
end
function PC.position()
  local s = PC.state
  if not s then return 0 end
  local guess = PC.guess
  if guess and guess.position and os.clock() < guess.till then
    return guess.position + (PC.playing() and (os.clock() - guess.at) or 0)
  end
  local p = tonumber(s.position) or 0
  if s.playing then p += math.max(0, nowMs() - (tonumber(s.at) or nowMs())) / 1000 * (tonumber(s.rate) or 1) end
  local length = tonumber(s.length) or 0
  if length > 0 then p = math.min(p, length) end
  return math.max(p, 0)
end

-- ---------------------------------------------------------------- the player's side of it (Music.front)
local assets = {}
local function asset(path)
  if assets[path] then return assets[path] end
  if type(getcustomasset) ~= "function" or not fs.exists(path) then return nil end
  local ok, id = pcall(getcustomasset, path)
  B.identity()
  if ok and id then assets[path] = id; return id end
  return nil
end
local tints = {}
local volumeSent = 0
local ctl = { kind = "pc" }
PC.ctl = ctl
function ctl.track() return PC.live and PC.track or nil end
function ctl.state()
  if not (PC.live and PC.track) then return "idle" end
  return PC.playing() and "playing" or "paused"
end
function ctl.status() return nil end
ctl.position = PC.position
function ctl.length() return PC.state and tonumber(PC.state.length) or 0 end
function ctl.toggle()
  PC.guess = { playing = not PC.playing(), track = PC.state and PC.state.track, till = os.clock() + 1.6,
    position = PC.position(), at = os.clock() }
  PC.send("toggle")
end
function ctl.next() PC.send("next") end
function ctl.previous() PC.send("previous") end
function ctl.seekTo(seconds)
  seconds = math.max(0, seconds)
  PC.guess = { position = seconds, at = os.clock(), till = os.clock() + 1.6, track = PC.state and PC.state.track }
  PC.send("seek", seconds)
end
function ctl.seek(fraction)
  local length = ctl.length()
  if length > 0 then ctl.seekTo(math.clamp(fraction, 0, 0.999) * length) end
end
function ctl.canSeek() return PC.state ~= nil and PC.state.canSeek == true and (tonumber(PC.state.length) or 0) > 0 end
function ctl.volume()
  local v = PC.volumeGuess and os.clock() < PC.volumeGuess.till and PC.volumeGuess.value or (PC.state and tonumber(PC.state.volume))
  return (v and v >= 0) and v or nil
end
function ctl.setVolume(value, final)
  value = math.clamp(value, 0, 1)
  PC.volumeGuess = { value = value, till = os.clock() + 2 }
  -- (while dragging, ten a second at most)
  if final or os.clock() - volumeSent > 0.1 then
    volumeSent = os.clock()
    PC.send("volume", math.floor(value * 1000 + 0.5) / 1000)
  end
end
function ctl.shuffle() return PC.state ~= nil and PC.state.shuffle == true end
function ctl.setShuffle(on) PC.send("shuffle", on == true) end
function ctl.repeatMode() return PC.state and PC.state["repeat"] or "off" end
function ctl.setRepeat(mode) PC.send("repeat", mode) end
function ctl.cover(track, image, done)
  local id = track and track.coverFile and asset(track.coverFile) or nil
  image.Image = id or ""
  if done then done(id and track.coverFile or nil) end
end
function ctl.tint(track, done)
  if not track or not track.coverFile or Config.get("music.tint") == false then done(nil); return end
  local known = tints[track.coverFile]
  if known ~= nil then done(known or nil); return end
  task.spawn(function()
    local color = B.Cover and B.Cover.color(track.coverFile) or nil
    B.identity()
    tints[track.coverFile] = color or false
    B.try("pc.tint", done, color)
  end)
end
-- (Windows does not say how loud it is: the bars move with the playing)
function ctl.loudness()
  if not PC.playing() then return 0 end
  local t = os.clock()
  return 60 + 35 * math.abs(math.sin(t * 2.7)) * (0.6 + 0.4 * math.sin(t * 0.9 + 1))
end
function ctl.label(track) return ((track and track.app) or "An app") .. " on this PC" end
function ctl.queue() return nil end

-- ---------------------------------------------------------------- running
function PC.define()
  Config.define("music.pc", false)
end
function PC.start()
  if PC.started then return end
  PC.started = true
  Motion.every(function()
    if Config.get("music.pc") ~= true then
      if PC.live then PC.live = false; PC.changed:fire("live") end
      return
    end
    B.try("pc.read", read)
  end, 6, "pc.read")
  -- the helper closes itself when this has not been written for 20 minutes
  Motion.every(function()
    if Config.get("music.pc") == true then fs.write(ALIVE, tostring(os.time())) end
  end, 0.2, "pc.alive")
  PC.changed:connect(function(what) if B.Music then B.Music.changed:fire(what == "live" and "state" or what) end end)
end
-- what the Music tab says about it
function PC.describe()
  if Config.get("music.pc") ~= true then return "Off. Set it up below to see and control what this PC plays." end
  local s = PC.state
  if not s then return "Waiting for the helper. Press Set up, then Win+R, paste, Enter." end
  if s.closed then return "The helper was closed. Press Set up to start it again." end
  if s.ok == false then return tostring(s.why or "The helper could not start.") end
  if not PC.live then return "The helper stopped answering. Press Set up to start it again." end
  if s.none then return "Connected. Nothing is playing on this PC." end
  return string.format("Connected: %s, %s.", tostring(s.app or "an app"), s.playing and "playing" or "paused")
end
end

do -- 49_card.lua
-- ============================================================================
--  49 card     the player on the screen while you play, and the island at the
--              top: the song, the colours of its cover, its words in time
--
--  The card (where the mini player was) plays what is in front
--  (Music.front): a song in the game, or what this PC is playing (48_pc).
--    full: the cover, the names, the line, the buttons, the volume, and the
--          words or the queue in the cover's place (the buttons at the bottom)
--    mini: the cover small, the names, the line, the buttons
--  A tap on the cover goes from one to the other. Drag it by any empty part.
--  The island: a pill at the top with the line being sung, word by word (in
--  the Novoline look its own island shows it, src/53).
--  Colours: the card takes the cover's colour, darkened; its line, bars and
--  the word being sung take it lightened (a grey cover: white).
-- ============================================================================
local Motion, UI, Config, Window = B.Motion, B.UI, B.Config, B.Window
local Music, Lyrics = B.Music, B.Lyrics
local Card = { mode = "full", view = "cover" }
B.Card = Card
local Island = {}
B.Island = Island

local WHITE = Color3.new(1, 1, 1)
local GREY = Color3.fromRGB(150, 150, 156)
local FAINT = Color3.fromRGB(112, 112, 118)
local FULL_W, FULL_H = 248, 456
local MINI_W, MINI_H = 288, 124
local GREY_HEX = "#8E8E93"

-- ---------------------------------------------------------------- small parts
local function frame(parent, props)
  local f = Instance.new("Frame")
  f.BorderSizePixel, f.BackgroundTransparency = 0, 1
  for key, value in pairs(props or {}) do f[key] = value end
  f.Parent = parent
  return f
end
local function round(f, radius)
  local c = Instance.new("UICorner")
  c.CornerRadius = radius == true and UDim.new(1, 0) or UDim.new(0, radius)
  c.Parent = f
  return c
end
local function text(parent, value, size, font, color, props)
  local l = Instance.new("TextLabel")
  l.BackgroundTransparency, l.BorderSizePixel = 1, 0
  l.FontFace = font
  l.TextSize = size
  l.TextColor3 = color or WHITE
  l.Text = value or ""
  l.TextXAlignment = Enum.TextXAlignment.Left
  l.TextYAlignment = Enum.TextYAlignment.Center
  l.TextTruncate = Enum.TextTruncate.AtEnd
  for key, v in pairs(props or {}) do l[key] = v end
  l.Parent = parent
  return l
end
local function glyph(parent, name, size, color, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency, image.BorderSizePixel = 1, 0
  image.Size = UDim2.fromOffset(size, size)
  image.ScaleType = Enum.ScaleType.Fit
  image.ImageColor3 = color or WHITE
  UI.setIcon(image, name)
  for key, v in pairs(props or {}) do image[key] = v end
  image.Parent = parent
  return image
end
local function hit(parent, z, props)
  local button = Instance.new("TextButton")
  button.Name = "Hit"
  button.Text, button.AutoButtonColor, button.BackgroundTransparency, button.BorderSizePixel = "", false, 1, 0
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = z
  for key, v in pairs(props or {}) do button[key] = v end
  button.Parent = parent
  return button
end
-- a bare glyph to press (no disc, as Apple's are): it dims under the mouse and gives on a press
local function press(parent, name, size, z, run, box)
  local holder = frame(parent, { Name = name, Size = UDim2.fromOffset(box or (size + 12), box or (size + 12)), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = z })
  local image = glyph(holder, name, size, WHITE, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = z + 1 })
  local give = Instance.new("UIScale")
  give.Parent = image
  local button = hit(holder, z + 2)
  button.MouseEnter:Connect(function() image.ImageTransparency = 0.28 end)
  button.MouseLeave:Connect(function() image.ImageTransparency = 0; Motion.to(give, "Scale", 1, "bouncy") end)
  button.MouseButton1Down:Connect(function() Motion.to(give, "Scale", 0.84, "quick") end)
  button.MouseButton1Up:Connect(function() Motion.to(give, "Scale", 1, "bouncy") end)
  button.Activated:Connect(B.safe("card.button", function()
    UI.sfx("click", 0.4)
    run()
  end))
  return holder, image
end
-- how much the UIScales above a frame enlarge it (to turn its pixels back into offsets)
local function scaleOf(gui)
  local s, node = 1, gui
  while node and node:IsA("GuiObject") do
    local sizer = node:FindFirstChildOfClass("UIScale")
    if sizer then s *= sizer.Scale end
    node = node.Parent
  end
  return s > 0 and s or 1
end
-- a line to drag (the song's place, the volume), placed by its middle: thin, a little thicker while held
local function line(parent, props, z, onMove, onEnd)
  local bar = frame(parent, props)
  bar.ZIndex = z
  bar.AnchorPoint = Vector2.new(0, 0.5)
  bar.BackgroundColor3, bar.BackgroundTransparency = WHITE, 0.8
  round(bar, true)
  local fill = frame(bar, { Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0, ZIndex = z + 1 })
  round(fill, true)
  local button = hit(bar, z + 3, { Size = UDim2.new(1, 8, 0, 18), Position = UDim2.new(0, -4, 0.5, -9) })
  local api = { frame = bar, fill = fill, dragging = nil, height = props.Size.Y.Offset }
  local function at(point) return math.clamp((point.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1) end
  local function thick(on)
    local h = on and api.height + 3 or api.height
    Motion.to(bar, "Size", UDim2.new(bar.Size.X.Scale, bar.Size.X.Offset, 0, h), "snappy")
  end
  button.MouseEnter:Connect(function() thick(true) end)
  button.MouseLeave:Connect(function() if not api.dragging then thick(false) end end)
  UI.drag(button, function(point)
    api.dragging = at(point)
    thick(true)
    if onMove then onMove(api.dragging) end
  end, function(point)
    api.dragging = at(point)
    if onMove then onMove(api.dragging) end
  end, function()
    local value = api.dragging
    api.dragging = nil
    thick(false)
    if value and onEnd then onEnd(value) end
  end)
  function api.set(f) fill.Size = UDim2.fromScale(math.clamp(f, 0, 1), 1) end
  return api
end
-- a name that slides when it is longer than its box (as the music tab's does)
local function marquee(parent, font, size, z)
  local holder = frame(parent, { Name = "Marquee", ClipsDescendants = true, ZIndex = z })
  local label = text(holder, "", size, font, WHITE, { Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
    TextTruncate = Enum.TextTruncate.None, ZIndex = z })
  local api = { holder = holder, label = label, t = 0 }
  function api.set(value)
    value = tostring(value or "")
    if label.Text ~= value then label.Text = value; api.t = 0; label.Position = UDim2.new() end
  end
  function api.step(dt)
    local width = holder.AbsoluteSize.X
    local over = label.AbsoluteSize.X - width
    if over <= 1 or width <= 0 then
      if label.Position.X.Scale ~= 0 then label.Position = UDim2.new() end
      api.t = 0
      return
    end
    local glide, back, rest = over / 38, over / 90, 1.6
    api.t = (api.t + dt) % (rest * 2 + glide + back)
    local t, p = api.t, 0
    if t < rest then p = 0
    elseif t < rest + glide then p = (t - rest) / glide
    elseif t < rest * 2 + glide then p = 1
    else p = 1 - (t - rest * 2 - glide) / back end
    p = p * p * (3 - 2 * p)
    label.Position = UDim2.new(-(over / width) * p, 0, 0, 0)
  end
  return api
end

-- ---------------------------------------------------------------- the colours of a cover
-- back: the card, darkened; low: its bottom; accent: the line, the bars, the word being sung
local function palette(color)
  if not color then return nil end
  local h, s = color:ToHSV()
  if s < 0.14 then
    return { back = Color3.fromHSV(0, 0, 0.14), low = Color3.fromHSV(0, 0, 0.07), accent = WHITE, vivid = false }
  end
  return { back = Color3.fromHSV(h, math.min(s * 0.75, 0.62), 0.22), low = Color3.fromHSV(h, math.min(s * 0.85, 0.7), 0.1),
    accent = Color3.fromHSV(h, math.clamp(s * 0.8, 0.32, 0.68), 1), vivid = true }
end
Card.palette = palette
local palettes = {}
-- the palette of a track (nil while it is read, or with the cover colour off)
function Card.paletteOf(ctl, track, done)
  if not track then done(nil); return end
  local known = palettes[track.key]
  if known ~= nil then done(known or nil); return end
  ctl.tint(track, function(color)
    palettes[track.key] = palette(color) or false
    done(palettes[track.key] or nil)
  end)
end
-- the colour of the word being sung: the cover's when it has one, the look's own for a grey cover
function Card.wordColor(fallback)
  return (Card.vivid and Card.accent and Config.get("music.tint") ~= false) and Card.accent or fallback
end
local function kitAccent(kit)
  local ok, color = pcall(kit.color, "accent")
  return (ok and typeof(color) == "Color3") and color or Color3.fromRGB(255, 59, 78)
end

-- ---------------------------------------------------------------- the words, scrolling (the card, the music tab)
-- opts: font, size, z, dim (Color3 of the lines not sung now), colors() -> { sung, now, next } (hex)
function Card.lyricList(parent, opts)
  local z = opts.z or 2
  local area = frame(parent, { Name = "Lyrics", Size = UDim2.fromScale(1, 1), ClipsDescendants = true, ZIndex = z })
  local column = frame(area, { Name = "Lines", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = z })
  local layout = Instance.new("UIListLayout")
  layout.Padding, layout.SortOrder = UDim.new(0, opts.gap or 10), Enum.SortOrder.LayoutOrder
  layout.Parent = column
  local note = text(area, "", (opts.size or 15) - 2, opts.font, opts.dim or GREY, { Size = UDim2.fromScale(1, 1), TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.None, ZIndex = z, Visible = false })
  local api = { area = area, labels = {}, current = -1, word = -1, entry = nil, state = nil, ctl = nil }
  local dim = opts.dim or GREY
  local function plainText(lineInfo)
    return lineInfo.text == "" and "\u{2022}  \u{2022}  \u{2022}" or Lyrics.escape(lineInfo.text)
  end
  local function clear()
    for _, child in ipairs(column:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
    table.clear(api.labels)
    column.Position = UDim2.new()
  end
  local function rebuild(entry)
    clear()
    if entry.loose then
      text(column, "Another length of this song: the words, without their times.", (opts.size or 15) - 4, opts.font, dim, { Name = "Note",
        Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, LayoutOrder = 0, ZIndex = z + 1 })
    end
    for i, lineInfo in ipairs(entry.lines) do
      local button = Instance.new("TextButton")
      button.Name = "Line"
      button.AutoButtonColor, button.BackgroundTransparency, button.BorderSizePixel = false, 1, 0
      button.RichText, button.TextWrapped = true, true
      button.FontFace, button.TextSize = opts.font, opts.size or 15
      button.TextXAlignment, button.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
      button.TextColor3, button.TextTransparency = dim, 0.35
      button.Text = plainText(lineInfo)
      button.Size = UDim2.new(1, -6, 0, 0)
      button.AutomaticSize = Enum.AutomaticSize.Y
      button.LayoutOrder, button.ZIndex = i, z + 1
      button.Parent = column
      -- (a line with a time: a click goes to it)
      button.Activated:Connect(B.safe("lyrics.line", function()
        local ctl = api.ctl
        if entry.timed and ctl then ctl.seekTo(math.max(lineInfo.t - (Config.get("music.lyricsShift") or 0) / 1000 + 0.02, 0)) end
      end))
      api.labels[i] = button
    end
  end
  function api.repaint() api.word = -1 end
  function api.step(_, ctl)
    api.ctl = ctl
    local track = ctl and ctl.track()
    local entry = track and Lyrics.forTrack(track) or nil
    local state = entry and entry.state
    if entry ~= api.entry or state ~= api.state then
      api.entry, api.state = entry, state
      api.current, api.word = -1, -1
      if entry and state == "ready" and #entry.lines > 0 then
        rebuild(entry)
        note.Visible = false
      else
        clear()
        note.Text = (not track and "Nothing playing") or Lyrics.note(entry) or ""
        note.Visible = true
      end
    end
    if not (entry and state == "ready" and entry.timed) then return end
    local t = Lyrics.clock(ctl.position())
    local i, w = Lyrics.at(entry.lines, t)
    if i ~= api.current then
      local old = api.labels[api.current]
      if old then
        old.Text = plainText(entry.lines[api.current])
        old.TextColor3, old.TextTransparency = dim, 0.35
      end
      api.current, api.word = i, -1
      local target = api.labels[i]
      if target then
        target.TextColor3, target.TextTransparency = WHITE, 0
        local s = scaleOf(area)
        local y = (target.AbsolutePosition.Y - column.AbsolutePosition.Y) / s
        local view = area.AbsoluteSize.Y / s
        Motion.to(column, "Position", UDim2.fromOffset(0, math.floor(view * 0.3 - y)), "gentle")
      end
    end
    if i > 0 and w ~= api.word then
      api.word = w
      local target = api.labels[i]
      if target then target.Text = Lyrics.markup(entry.lines[i], w, opts.colors()) end
    end
  end
  return api
end

-- ---------------------------------------------------------------- the island's row: cover, bars, the line
-- (also drawn inside the Novoline look's own island). opts: font, size, z, accent() -> Color3
function Island.row(parent, opts)
  local z = opts.z or 22
  local row = frame(parent, { Name = "LyricRow", Size = UDim2.fromScale(1, 1), ZIndex = z })
  local art = Instance.new("ImageLabel")
  art.Name = "Cover"
  art.BackgroundColor3, art.BorderSizePixel = Color3.fromRGB(40, 40, 46), 0
  art.AnchorPoint, art.Position, art.Size = Vector2.new(0, 0.5), UDim2.new(0, 5, 0.5, 0), UDim2.fromOffset(28, 28)
  art.ScaleType, art.ZIndex = Enum.ScaleType.Crop, z + 1
  art.Parent = row
  round(art, true)
  local bars = {}
  for i = 1, 4 do
    local bar = frame(row, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 41 + (i - 1) * 5, 0.5, 0), Size = UDim2.fromOffset(3, 4),
      BackgroundColor3 = WHITE, BackgroundTransparency = 0, ZIndex = z + 1 })
    round(bar, true)
    bars[i] = bar
  end
  local clip = frame(row, { Name = "Words", Position = UDim2.fromOffset(66, 0), Size = UDim2.new(1, -78, 1, 0), ClipsDescendants = true, ZIndex = z + 1 })
  local function newLabel()
    return text(clip, "", opts.size or 14, opts.font, WHITE, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
      Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, RichText = true, TextTruncate = Enum.TextTruncate.None, ZIndex = z + 2 })
  end
  local a, b = newLabel(), newLabel()
  b.TextTransparency = 1
  local api = { frame = row, showing = a, key = nil, markup = nil }
  local coverKey, level, peak, spin = nil, 0, 4, 0
  local lastLine, lastWord = -1, -1
  function api.step(dt, ctl)
    local track = ctl.track()
    if not track then return 220, false end
    if track.key ~= coverKey then
      coverKey = track.key
      ctl.cover(track, art)
      lastLine, lastWord = -1, -1
    end
    local accent = opts.accent and opts.accent() or WHITE
    local playing = ctl.state() == "playing"
    if playing then spin = (spin + dt * 40) % 360 end
    art.Rotation = spin
    -- the words: the line being sung, or the song's name between lines
    local entry = Lyrics.forTrack(track)
    local key, markup
    if entry and entry.state == "ready" and entry.timed then
      local t = Lyrics.clock(ctl.position())
      local i, w = Lyrics.at(entry.lines, t)
      if i > 0 and Lyrics.live(entry.lines, i, t) then
        key = "line" .. i
        if i ~= lastLine or w ~= lastWord or api.key ~= key then
          lastLine, lastWord = i, w
          markup = Lyrics.markup(entry.lines[i], w, { sung = "#FFFFFF", now = Lyrics.hex(accent), next = GREY_HEX })
        end
      end
    end
    local isLine = key ~= nil
    if not key then
      key = "name " .. track.key
      if api.key ~= key then
        markup = Lyrics.escape(track.title) .. string.format('<font color="%s">  \u{00B7}  %s</font>', GREY_HEX, Lyrics.escape(track.artist))
      end
    end
    if key ~= api.key then
      -- the old line rises away, the new one comes up from below
      local old, new = api.showing, (api.showing == a and b or a)
      api.key, api.showing = key, new
      new.Text = markup or ""
      if Motion.reduced then
        new.Position, new.TextTransparency = UDim2.new(0, 0, 0.5, 0), 0
        old.TextTransparency = 1
      else
        new.Position, new.TextTransparency = UDim2.new(0, 0, 0.5, 13), 1
        Motion.to(new, "Position", UDim2.new(0, 0, 0.5, 0), "smooth")
        Motion.to(new, "TextTransparency", 0, "smooth")
        Motion.to(old, "Position", UDim2.new(0, 0, 0.5, -13), "smooth")
        Motion.to(old, "TextTransparency", 1, "quick")
      end
    elseif markup then
      api.showing.Text = markup
    end
    -- the bars: against the loudest lately, so they move at any volume
    local raw = playing and ctl.loudness() or 0
    peak = math.max(peak * (1 - math.min(dt * 0.35, 1)), raw, 4)
    local loud = playing and math.clamp(raw / peak * 1.05, 0, 1.15) or 0
    level += (loud - level) * math.min(dt * 12, 1)
    local now = os.clock()
    for i, bar in ipairs(bars) do
      local wobble = 0.4 + 0.6 * math.abs(math.sin(now * (3.3 + i * 1.1) + i * 1.9))
      bar.Size = UDim2.fromOffset(3, math.clamp(4 + level * 14 * wobble, 4, 18))
      bar.BackgroundColor3 = accent
    end
    local width = api.showing.AbsoluteSize.X / scaleOf(clip)
    return math.clamp(66 + width + 16, 200, 560), isLine
  end
  return api
end

-- ---------------------------------------------------------------- the island (the BASED and Unnamed looks)
function Island.start()
  if Island.pill or not Window.hud then return end
  local pill = frame(Window.hud, { Name = "MusicIsland", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10),
    Size = UDim2.fromOffset(38, 38), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.04, Visible = false, ZIndex = 20,
    ClipsDescendants = true })
  round(pill, true)
  local rim = Instance.new("UIStroke")
  rim.Color, rim.Transparency, rim.Thickness = WHITE, 0.9, 1
  rim.Parent = pill
  local sizer = Instance.new("UIScale")
  sizer.Parent = pill
  Island.pill = pill
  local row, rowLook
  local width, shown = 38, false
  local function build()
    if row then row.frame:Destroy() end
    local kit = Window.activeKit()
    rowLook = kit.look
    row = Island.row(pill, { font = kit.font(true), size = 14, z = 21, accent = function() return Card.wordColor(kitAccent(kit)) end })
    local corner = pill:FindFirstChildOfClass("UICorner")
    if corner then corner.CornerRadius = kit.look == "unnamed" and UDim.new(0, 0) or UDim.new(1, 0) end
  end
  build()
  hit(pill, 30).Activated:Connect(B.safe("music.island", function() Music.openTab() end))
  Motion.every(function(dt)
    local ctl = Music.front()
    local track = ctl.track()
    local show = Window.look() ~= "novoline" and Config.get("music.island") ~= false and track ~= nil and ctl.state() ~= "idle" and not Window.anyOpen()
    if show ~= shown then
      shown = show
      pill.Visible = show
      if show then
        -- (it opens out from a dot)
        width = 38
        pill.Size = UDim2.fromOffset(38, 38)
      end
    end
    if not show then return end
    if rowLook ~= Window.activeKit().look then build() end
    sizer.Scale = Window.scale or 1
    local want = row.step(dt, ctl)
    if math.abs(want - width) > 1 then
      width = want
      Motion.to(pill, "Size", UDim2.fromOffset(want, 38), "smooth")
    end
  end, nil, "music.island")
end

-- ---------------------------------------------------------------- the card
local function layoutFor(mode, view)
  if mode == "mini" then
    return { w = MINI_W, h = MINI_H, cover = { 12, 12, 46 }, title = { 68, 12, MINI_W - 68 - 44, 18 }, titleSize = 13,
      artist = { 68, 32, MINI_W - 68 - 44, 15 }, artistSize = 11, heart = { FULL_W - 46, 254 }, more = { FULL_W - 22, 254 } }
  end
  if view == "cover" then
    return { w = FULL_W, h = FULL_H, cover = { 14, 14, FULL_W - 28 }, title = { 14, 242, FULL_W - 28 - 58, 20 }, titleSize = 15,
      artist = { 14, 263, FULL_W - 28 - 58, 16 }, artistSize = 12, heart = { FULL_W - 46, 253 }, more = { FULL_W - 22, 253 } }
  end
  return { w = FULL_W, h = FULL_H, cover = { 14, 14, 48 }, title = { 72, 15, FULL_W - 72 - 62, 20 }, titleSize = 14,
    artist = { 72, 36, FULL_W - 72 - 62, 16 }, artistSize = 12, heart = { FULL_W - 46, 38 }, more = { FULL_W - 22, 38 } }
end

local parts
local function setText(label, value) if label.Text ~= value then label.Text = value end end
local function timeOf(seconds) return Music.time(seconds) end

-- go to the size and view asked for (instant: no motion, for the first build)
function Card.apply(instant)
  if not parts then return end
  local L = layoutFor(Card.mode, Card.view)
  local function move(instance, property, value)
    if instant or Motion.reduced then Motion.snap(instance, property, value) else Motion.to(instance, property, value, "smooth") end
  end
  move(Card.holder, "Size", UDim2.fromOffset(L.w, L.h))
  move(parts.cover, "Position", UDim2.fromOffset(L.cover[1], L.cover[2]))
  move(parts.cover, "Size", UDim2.fromOffset(L.cover[3], L.cover[3]))
  parts.coverCorner.CornerRadius = UDim.new(0, (parts.square and 0) or (L.cover[3] > 100 and 12 or 8))
  move(parts.title.holder, "Position", UDim2.fromOffset(L.title[1], L.title[2]))
  move(parts.title.holder, "Size", UDim2.fromOffset(L.title[3], L.title[4]))
  parts.title.label.TextSize = L.titleSize
  move(parts.artist, "Position", UDim2.fromOffset(L.artist[1], L.artist[2]))
  move(parts.artist, "Size", UDim2.fromOffset(L.artist[3], L.artist[4]))
  parts.artist.TextSize = L.artistSize
  move(parts.heart, "Position", UDim2.fromOffset(L.heart[1], L.heart[2]))
  move(parts.more, "Position", UDim2.fromOffset(L.more[1], L.more[2]))
  local full, list = Card.mode == "full", Card.mode == "full" and Card.view ~= "cover"
  local function show(group, on)
    if instant then UI.setFade(group, on and 1 or 0) else UI.fade(group, on and 1 or 0, "smooth") end
  end
  show(parts.full, full)
  show(parts.mini, not full)
  show(parts.list, list)
  parts.lyrics.area.Visible = Card.view == "lyrics"
  parts.queue.Visible = Card.view == "queue"
  parts.paintButtons()
end
function Card.setMode(mode, view)
  Card.mode = mode
  if view then Card.view = view end
  Config.set("music.cardMode", Card.mode)
  Config.set("music.cardView", Card.view)
  Card.apply(false)
end
-- the cover: mini -> full; the words or the queue -> the cover; the cover -> mini
function Card.tapCover()
  if Card.mode == "mini" then Card.setMode("full", "cover")
  elseif Card.view ~= "cover" then Card.setMode("full", "cover")
  else Card.setMode("mini") end
end
function Card.toggleMode()
  Card.setMode(Card.mode == "mini" and "full" or "mini")
end

-- the next songs of the game's queue, in the card
local function fillQueue(list)
  for _, child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
  local ctl = Music.front()
  local upcoming = ctl.queue and ctl.queue() or nil
  local font = parts.font
  if not upcoming or #upcoming == 0 then
    text(list, upcoming and "Nothing next. Add songs with + in the Music tab." or "The queue is the app's own on this PC.", 12, font, GREY,
      { Size = UDim2.new(1, 0, 0, 40), TextWrapped = true, TextTruncate = Enum.TextTruncate.None, ZIndex = 9 })
    return
  end
  for order, item in ipairs(upcoming) do
    local row = Instance.new("TextButton")
    row.Name = "Next"
    row.AutoButtonColor, row.BackgroundColor3, row.BackgroundTransparency, row.BorderSizePixel = false, WHITE, 1, 0
    row.Text, row.Size, row.LayoutOrder, row.ZIndex = "", UDim2.new(1, 0, 0, 34), order, 9
    row.Parent = list
    round(row, 8)
    text(row, item.track.title, 12, parts.bold, WHITE, { Position = UDim2.fromOffset(8, 2), Size = UDim2.new(1, -16, 0, 16), ZIndex = 10 })
    text(row, item.track.artist, 11, font, GREY, { Position = UDim2.fromOffset(8, 17), Size = UDim2.new(1, -16, 0, 14), ZIndex = 10 })
    row.MouseEnter:Connect(function() row.BackgroundTransparency = 0.92 end)
    row.MouseLeave:Connect(function() row.BackgroundTransparency = 1 end)
    row.Activated:Connect(B.safe("card.queue", function()
      Music.index = item.index
      Music.play(item.track, true)
    end))
  end
end

local function build()
  local holder = Card.holder
  for _, child in ipairs(holder:GetChildren()) do
    if child:IsA("GuiObject") then child:Destroy() end
  end
  local kit = Window.activeKit()
  local square = kit.look == "unnamed"
  local bold, regular = kit.font(true), kit.font(false)
  parts = { kit = kit, square = square, font = regular, bold = bold, look = kit.look }
  -- the card: the cover's colour, darker toward the bottom
  local back = frame(holder, { Name = "Back", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(24, 24, 28), BackgroundTransparency = 0.03, ZIndex = 1 })
  if not square then round(back, 18) end
  local shade = Instance.new("UIGradient")
  shade.Rotation = 90
  shade.Color = ColorSequence.new(WHITE, Color3.fromRGB(120, 120, 120))
  shade.Parent = back
  local rim = Instance.new("UIStroke")
  rim.Color, rim.Transparency, rim.Thickness = WHITE, square and 0.7 or 0.9, 1
  rim.Parent = back
  pcall(function()
    local shadow = Instance.new("UIShadow")
    shadow.Color, shadow.BlurRadius, shadow.Offset, shadow.Transparency = Color3.new(0, 0, 0), UDim.new(0, 26), UDim2.fromOffset(0, 10), 0.45
    shadow.Parent = back
  end)
  parts.back = back
  -- drag it by anything that is not a button
  local grab = hit(holder, 2, { Name = "Grab" })
  local from
  UI.drag(grab, function(point)
    from = point - holder.AbsolutePosition
  end, function(point)
    local layer = Window.hud.AbsoluteSize
    if layer.X <= 0 or layer.Y <= 0 then return end
    local topLeft = point - from - Window.hud.AbsolutePosition
    local bottom = topLeft.Y + holder.AbsoluteSize.Y
    Card.at = Vector2.new(math.clamp(topLeft.X / layer.X, 0, 1), math.clamp(bottom / layer.Y, 0, 1))
    Card.seat()
  end, function()
    if Card.at then
      Config.set("music.cardX", Card.at.X)
      Config.set("music.cardY", Card.at.Y)
    end
  end)
  -- the cover (tap: big or small)
  local cover = Instance.new("ImageLabel")
  cover.Name = "Cover"
  cover.BackgroundColor3, cover.BorderSizePixel = Color3.fromRGB(44, 44, 50), 0
  cover.ScaleType, cover.ZIndex = Enum.ScaleType.Crop, 6
  cover.Parent = holder
  parts.coverCorner = round(cover, 12)
  local placeholder = glyph(cover, "music", 28, FAINT, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 7 })
  cover:GetPropertyChangedSignal("Image"):Connect(function() placeholder.Visible = cover.Image == "" end)
  local coverHit = hit(cover, 8, { Name = "Tap" })
  coverHit.Activated:Connect(B.safe("card.cover", function() UI.sfx("click", 0.35); Card.tapCover() end))
  parts.cover = cover
  parts.title = marquee(holder, bold, 15, 6)
  parts.artist = text(holder, "", 12, regular, GREY, { Name = "Artist", ZIndex = 6 })

  -- the full card's own parts
  local full = UI.group(holder, { Name = "Full", Size = UDim2.fromOffset(FULL_W, FULL_H), ZIndex = 4 })
  parts.full = full
  local heart, heartIcon = press(full, "heart", 18, 10, function()
    local track = Music.front().track()
    if track then Music.like(track, not Music.liked(track)) end
  end)
  parts.heart, parts.heartIcon = heart, heartIcon
  parts.more = press(full, "ellipsis", 18, 10, function() Music.openTab() end)
  local seekLine = line(full, { Position = UDim2.fromOffset(14, 298), Size = UDim2.fromOffset(FULL_W - 28, 4) }, 10, nil, function(f)
    local ctl = Music.front()
    if ctl.canSeek() then ctl.seek(f) end
  end)
  parts.seekLine = seekLine
  parts.at = text(full, "0:00", 10, regular, FAINT, { Position = UDim2.fromOffset(14, 306), Size = UDim2.fromOffset(70, 12), ZIndex = 10 })
  parts.left = text(full, "-0:00", 10, regular, FAINT, { Position = UDim2.fromOffset(FULL_W - 84, 306), Size = UDim2.fromOffset(70, 12),
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 10 })
  local prev = press(full, "skip-back", 22, 10, function() Music.front().previous() end, 40)
  prev.Position = UDim2.fromOffset(FULL_W / 2 - 64, 352)
  local play, playIcon = press(full, "play", 30, 10, function() Music.front().toggle() end, 48)
  play.Position = UDim2.fromOffset(FULL_W / 2, 352)
  local nxt = press(full, "skip-forward", 22, 10, function() Music.front().next() end, 40)
  nxt.Position = UDim2.fromOffset(FULL_W / 2 + 64, 352)
  parts.playIcon = playIcon
  -- the volume: the game's music, or the app on this PC (the volume mixer)
  local quiet = glyph(full, "volume-x", 12, FAINT, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(14, 400), ZIndex = 10 })
  parts.quiet = quiet
  local volumeLine = line(full, { Position = UDim2.fromOffset(34, 400), Size = UDim2.fromOffset(FULL_W - 68, 4) }, 10, function(f)
    local ctl = Music.front()
    if ctl.setVolume then ctl.setVolume(f, false) end
  end, function(f)
    local ctl = Music.front()
    if ctl.setVolume then ctl.setVolume(f, true) end
  end)
  parts.volumeLine = volumeLine
  parts.loud = glyph(full, "volume-2", 14, FAINT, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromOffset(FULL_W - 14, 400), ZIndex = 10 })
  -- the bottom: words, where it plays, the queue
  local words, wordsIcon = press(full, "message-circle", 16, 10, function()
    Card.setMode("full", Card.view == "lyrics" and "cover" or "lyrics")
  end, 30)
  words.Position = UDim2.fromOffset(28, 434)
  parts.wordsIcon = wordsIcon
  local queue, queueIcon = press(full, "list", 16, 10, function()
    Card.setMode("full", Card.view == "queue" and "cover" or "queue")
  end, 30)
  queue.Position = UDim2.fromOffset(FULL_W - 28, 434)
  parts.queueIcon = queueIcon
  local where = frame(full, { Name = "Where", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(FULL_W / 2, 434), Size = UDim2.fromOffset(150, 16), ZIndex = 10 })
  parts.whereIcon = glyph(where, "music", 11, FAINT, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), ZIndex = 11 })
  parts.where = text(where, "", 10, regular, FAINT, { Position = UDim2.fromOffset(15, 0), Size = UDim2.new(1, -15, 1, 0), ZIndex = 11 })
  parts.whereBox = where

  -- the words or the queue, where the cover was
  local list = UI.group(holder, { Name = "List", Position = UDim2.fromOffset(14, 72), Size = UDim2.fromOffset(FULL_W - 28, 212), ZIndex = 5 })
  parts.list = list
  parts.lyrics = Card.lyricList(list, { font = bold, size = 15, z = 6, dim = GREY, colors = function()
    return { sung = "#FFFFFF", now = Lyrics.hex(Card.wordColor(kitAccent(kit))), next = GREY_HEX }
  end })
  local queueList = Instance.new("ScrollingFrame")
  queueList.Name = "Queue"
  queueList.BackgroundTransparency, queueList.BorderSizePixel = 1, 0
  queueList.Size = UDim2.fromScale(1, 1)
  queueList.AutomaticCanvasSize, queueList.CanvasSize = Enum.AutomaticSize.Y, UDim2.new()
  queueList.ScrollBarThickness, queueList.ScrollBarImageColor3 = 2, WHITE
  queueList.ZIndex = 8
  queueList.Parent = list
  local queueLayout = Instance.new("UIListLayout")
  queueLayout.Padding, queueLayout.SortOrder = UDim.new(0, 2), Enum.SortOrder.LayoutOrder
  queueLayout.Parent = queueList
  parts.queue = queueList

  -- the mini card's own parts
  local mini = UI.group(holder, { Name = "Mini", Size = UDim2.fromOffset(MINI_W, MINI_H), ZIndex = 4 })
  parts.mini = mini
  local bars = {}
  for i = 1, 4 do
    local bar = frame(mini, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromOffset(MINI_W - 34 + (i - 1) * 5, 22), Size = UDim2.fromOffset(3, 4),
      BackgroundColor3 = WHITE, BackgroundTransparency = 0, ZIndex = 10 })
    round(bar, true)
    bars[i] = bar
  end
  parts.bars = bars
  local miniLine = line(mini, { Position = UDim2.fromOffset(12, 70), Size = UDim2.fromOffset(MINI_W - 24, 3) }, 10, nil, function(f)
    local ctl = Music.front()
    if ctl.canSeek() then ctl.seek(f) end
  end)
  parts.miniLine = miniLine
  parts.miniAt = text(mini, "0:00", 9, regular, FAINT, { Position = UDim2.fromOffset(12, 76), Size = UDim2.fromOffset(60, 11), ZIndex = 10 })
  parts.miniLeft = text(mini, "-0:00", 9, regular, FAINT, { Position = UDim2.fromOffset(MINI_W - 72, 76), Size = UDim2.fromOffset(60, 11),
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 10 })
  local miniHeart, miniHeartIcon = press(mini, "heart", 15, 10, function()
    local track = Music.front().track()
    if track then Music.like(track, not Music.liked(track)) end
  end, 28)
  miniHeart.Position = UDim2.fromOffset(26, 104)
  parts.miniHeartIcon = miniHeartIcon
  local miniPrev = press(mini, "skip-back", 17, 10, function() Music.front().previous() end, 32)
  miniPrev.Position = UDim2.fromOffset(MINI_W / 2 - 46, 104)
  local miniPlay, miniPlayIcon = press(mini, "play", 22, 10, function() Music.front().toggle() end, 36)
  miniPlay.Position = UDim2.fromOffset(MINI_W / 2, 104)
  parts.miniPlayIcon = miniPlayIcon
  local miniNext = press(mini, "skip-forward", 17, 10, function() Music.front().next() end, 32)
  miniNext.Position = UDim2.fromOffset(MINI_W / 2 + 46, 104)
  local grow = press(mini, "maximize-2", 14, 10, function() Card.setMode("full", "cover") end, 28)
  grow.Position = UDim2.fromOffset(MINI_W - 26, 104)

  -- colours, names, the buttons that show a state
  function parts.paintButtons()
    local ctl = Music.front()
    local accent = Card.accent or kitAccent(kit)
    wordsIcon.ImageColor3 = Card.view == "lyrics" and accent or FAINT
    queueIcon.ImageColor3 = Card.view == "queue" and accent or FAINT
    queue.Visible = ctl.kind ~= "pc"
  end
  Card.coverKey = nil
  Card.apply(true)
end

-- the colours and names of what is in front (on a change of song or state)
local function paint()
  if not parts then return end
  local ctl = Music.front()
  local track = ctl.track()
  parts.title.set(track and track.title or "Nothing playing")
  setText(parts.artist, track and (ctl.status() or track.artist) or "")
  local playing = ctl.state() == "playing"
  UI.setIcon(parts.playIcon, playing and "pause" or "play")
  UI.setIcon(parts.miniPlayIcon, playing and "pause" or "play")
  local liked = track ~= nil and Music.liked(track)
  local accent = Card.accent or kitAccent(parts.kit)
  parts.heartIcon.ImageColor3 = liked and accent or WHITE
  parts.miniHeartIcon.ImageColor3 = liked and accent or WHITE
  UI.setIcon(parts.whereIcon, ctl.kind == "pc" and "monitor" or "music")
  setText(parts.where, track and ctl.label(track) or "")
  local key = track and track.key or nil
  if key ~= Card.coverKey then
    Card.coverKey = key
    if track then
      ctl.cover(track, parts.cover)
      Card.paletteOf(ctl, track, function(pal)
        if not parts or Card.coverKey ~= key then return end
        Card.accent = pal and pal.accent or nil
        Card.vivid = pal ~= nil and pal.vivid == true
        local back = pal and pal.back or Color3.fromRGB(24, 24, 28)
        Motion.to(parts.back, "BackgroundColor3", back, "gentle")
        local fill = Card.accent or WHITE
        for _, bar in ipairs({ parts.seekLine.fill, parts.miniLine.fill }) do bar.BackgroundColor3 = fill end
        parts.lyrics.repaint()
        parts.paintButtons()
        paint()
      end)
    else
      parts.cover.Image = ""
    end
  end
  parts.paintButtons()
  if Card.view == "queue" then fillQueue(parts.queue) end
end
Card.paint = paint

-- ---------------------------------------------------------------- the wide card (Novoline's Home): every cover, every colour
-- The cover with its record, the names, the line, the buttons; under them Shuffle, Library and
-- Playlists. The whole card takes the cover's colour; the line and the tiles' icons its light one.
local WIDE_W, WIDE_H = 420, 260
function Card.viewWide(holder, shown)
  local kit = Window.kit(holder)
  local L = Music.life(holder)
  shown = shown or function() return true end
  local bold, regular = kit.font(true), kit.font(false)
  local tint = frame(holder, { Name = "Tint", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(30, 30, 36), BackgroundTransparency = 1, ZIndex = 21 })
  round(tint, 28)
  local shade = Instance.new("UIGradient")
  shade.Rotation = 35
  shade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0.6) })
  shade.Parent = tint
  -- the record, out of its sleeve while it plays
  local disc = frame(holder, { Name = "Record", AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(138, 138), Position = UDim2.fromOffset(18 + 75, 18 + 75),
    BackgroundColor3 = Color3.fromRGB(12, 12, 14), BackgroundTransparency = 0, ZIndex = 22 })
  round(disc, true)
  for _, s in ipairs({ 0.94, 0.82, 0.7, 0.58 }) do
    local groove = frame(disc, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(s, s), ZIndex = 22 })
    round(groove, true)
    local ring = Instance.new("UIStroke")
    ring.Color, ring.Transparency, ring.Thickness = Color3.fromRGB(46, 46, 52), 0.4, 1
    ring.Parent = groove
  end
  local cover = Instance.new("ImageLabel")
  cover.Name = "Cover"
  cover.BackgroundColor3, cover.BorderSizePixel = Color3.fromRGB(44, 44, 50), 0
  cover.Position, cover.Size = UDim2.fromOffset(18, 18), UDim2.fromOffset(150, 150)
  cover.ScaleType, cover.ZIndex = Enum.ScaleType.Crop, 23
  cover.Parent = holder
  round(cover, 14)
  local placeholder = glyph(cover, "music", 34, FAINT, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 24 })
  cover:GetPropertyChangedSignal("Image"):Connect(function() placeholder.Visible = cover.Image == "" end)
  -- the names, the line, the buttons
  local x = 236
  local title = marquee(holder, bold, 17, 23)
  title.holder.Position, title.holder.Size = UDim2.fromOffset(x, 22), UDim2.fromOffset(WIDE_W - x - 18, 22)
  local artist = text(holder, "", 13, regular, GREY, { Position = UDim2.fromOffset(x, 46), Size = UDim2.fromOffset(WIDE_W - x - 18, 18), ZIndex = 23 })
  local seek = line(holder, { Position = UDim2.fromOffset(x, 88), Size = UDim2.fromOffset(WIDE_W - x - 18, 4) }, 23, nil, function(f)
    local ctl = Music.front()
    if ctl.canSeek() then ctl.seek(f) end
  end)
  local at = text(holder, "0:00", 10, regular, FAINT, { Position = UDim2.fromOffset(x, 97), Size = UDim2.fromOffset(60, 12), ZIndex = 23 })
  local long = text(holder, "0:00", 10, regular, FAINT, { Position = UDim2.fromOffset(WIDE_W - 18 - 60, 97), Size = UDim2.fromOffset(60, 12),
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 23 })
  local y = 140
  local prev = press(holder, "skip-back", 20, 23, function() Music.front().previous() end, 34)
  prev.Position = UDim2.fromOffset(x + 14, y)
  local play, playIcon = press(holder, "play", 28, 23, function() Music.front().toggle() end, 42)
  play.Position = UDim2.fromOffset(x + 60, y)
  local nxt = press(holder, "skip-forward", 20, 23, function() Music.front().next() end, 34)
  nxt.Position = UDim2.fromOffset(x + 106, y)
  -- (out: the menu shuts and the player is left on the screen; the words: the Music tab)
  local out = press(holder, "external-link", 16, 23, function() Window.showActive(false) end, 30)
  out.Position = UDim2.fromOffset(x + 142, y)
  local words = press(holder, "message-circle", 16, 23, function() Music.openTab() end, 30)
  words.Position = UDim2.fromOffset(x + 170, y)
  -- the tiles
  local tiles = {}
  local tileW = math.floor((WIDE_W - 36 - 20) / 3)
  local function tile(index, icon, label, run)
    local box = frame(holder, { Name = label, Position = UDim2.fromOffset(18 + (index - 1) * (tileW + 10), 184), Size = UDim2.fromOffset(tileW, 60),
      BackgroundColor3 = Color3.fromRGB(40, 40, 46), BackgroundTransparency = 0.15, ZIndex = 23 })
    round(box, 14)
    local rim = Instance.new("UIStroke")
    rim.Color, rim.Transparency, rim.Thickness = WHITE, 0.9, 1
    rim.Parent = box
    local mark = glyph(box, icon, 15, WHITE, { Position = UDim2.fromOffset(12, 10), ZIndex = 24 })
    text(box, label, 12, bold, WHITE, { Position = UDim2.fromOffset(12, 29), Size = UDim2.new(1, -20, 0, 14), ZIndex = 24 })
    local sub = text(box, "", 10, regular, GREY, { Position = UDim2.fromOffset(12, 43), Size = UDim2.new(1, -20, 0, 12), ZIndex = 24 })
    local give = Instance.new("UIScale")
    give.Parent = box
    local button = hit(box, 26)
    button.MouseEnter:Connect(function() box.BackgroundTransparency = 0.05 end)
    button.MouseLeave:Connect(function() box.BackgroundTransparency = 0.15; Motion.to(give, "Scale", 1, "bouncy") end)
    button.MouseButton1Down:Connect(function() Motion.to(give, "Scale", 0.96, "quick") end)
    button.MouseButton1Up:Connect(function() Motion.to(give, "Scale", 1, "bouncy") end)
    button.Activated:Connect(B.safe("card.tile", function() UI.sfx("click", 0.4); run() end))
    tiles[index] = { box = box, mark = mark, sub = sub }
  end
  tile(1, "shuffle", "Shuffle", function() local ctl = Music.front(); ctl.setShuffle(not ctl.shuffle()) end)
  tile(2, "search", "Library", function() Music.openTab() end)
  tile(3, "library", "Playlists", function() Music.openTab() end)
  local coverKey, accent = nil, nil
  local function colours(pal)
    accent = pal and pal.accent or nil
    local back = pal and pal.back or nil
    if back then
      tint.BackgroundColor3 = back
      Motion.to(tint, "BackgroundTransparency", 0, "gentle")
    else
      Motion.to(tint, "BackgroundTransparency", 1, "gentle")
    end
    local h, s = (pal and pal.accent or WHITE):ToHSV()
    local tileColor = pal and Color3.fromHSV(h, math.min(s * 0.5, 0.45), 0.3) or Color3.fromRGB(40, 40, 46)
    for _, item in ipairs(tiles) do
      item.box.BackgroundColor3 = tileColor
      item.mark.ImageColor3 = accent or kitAccent(kit)
    end
    seek.fill.BackgroundColor3 = accent or kitAccent(kit)
  end
  colours(nil)
  local function paintWide()
    local ctl = Music.front()
    local track = ctl.track()
    title.set(track and track.title or "Nothing playing")
    artist.Text = track and (ctl.status() or track.artist) or "Pick a song in the Music tab"
    UI.setIcon(playIcon, ctl.state() == "playing" and "pause" or "play")
    tiles[1].sub.Text = ctl.shuffle() and "On" or "Off"
    local liked = #(Config.get("music.liked") or {})
    tiles[2].sub.Text = liked .. (liked == 1 and " song" or " songs")
    local lists = #Music.playlists()
    tiles[3].sub.Text = lists .. (lists == 1 and " playlist" or " playlists")
    local key = track and track.key or nil
    if key ~= coverKey then
      coverKey = key
      if track then
        ctl.cover(track, cover)
        Card.paletteOf(ctl, track, function(pal)
          if coverKey == key and holder.Parent then colours(pal) end
        end)
      else
        cover.Image = ""
        colours(nil)
      end
    end
  end
  L.signal(Music.changed, paintWide)
  L.config("music.liked", paintWide)
  L.config("music.playlists", paintWide)
  L.config("music.shuffle", paintWide)
  paintWide()
  local out, spin, stamp = 0, 0, nil
  L.every(function(dt)
    if not shown() then return end
    local ctl = Music.front()
    local track = ctl.track()
    local now = (track and track.key or "") .. ctl.state() .. ctl.kind
    if now ~= stamp then stamp = now; paintWide() end
    title.step(dt)
    local position, length = ctl.position(), ctl.length()
    local f = seek.dragging or (length > 0 and math.clamp(position / length, 0, 1) or 0)
    seek.set(f)
    setText(at, Music.time(seek.dragging and seek.dragging * length or position))
    setText(long, length > 0 and Music.time(length) or "--:--")
    -- the record slides out while it plays and turns (33 a minute)
    local playing = ctl.state() == "playing"
    out += ((playing and 1 or 0) - out) * math.min(dt * 5, 1)
    if playing then spin = (spin + dt * 198) % 360 end
    disc.Position = UDim2.fromOffset(18 + 75 + out * 46, 18 + 75)
    disc.Rotation = spin
  end, 60, "music.wide")
end
Card.WIDE = Vector2.new(WIDE_W, WIDE_H)

-- where it sits: its bottom-left corner, kept on screen
function Card.seat()
  local holder = Card.holder
  local at = Card.at
  holder.AnchorPoint = Vector2.new(0, 1)
  -- (how far under its place it is while it comes and goes with the menu)
  local drop = Card.drop and Card.drop.Value or 0
  if not at then
    holder.Position = UDim2.new(0, 16, 1, -16 + drop)
    return
  end
  local layer = Window.hud.AbsoluteSize
  local size = holder.AbsoluteSize
  if layer.X <= 0 or layer.Y <= 0 then holder.Position = UDim2.fromScale(at.X, at.Y); return end
  local x = math.clamp(at.X * layer.X, 4, math.max(layer.X - size.X - 4, 4))
  local y = math.clamp(at.Y * layer.Y, math.min(size.Y + 4, layer.Y), layer.Y - 4)
  holder.Position = UDim2.fromOffset(x, y + drop)
end

function Card.define()
  Config.define("music.island", true)
  Config.define("music.cardMode", "full")
  Config.define("music.cardView", "cover")
  Config.define("music.cardX", -1)
  Config.define("music.cardY", -1)
  for _, id in ipairs({ "music.cardMode", "music.cardView", "music.cardX", "music.cardY" }) do Config.unshared(id) end
end
function Card.start()
  if Card.holder or not Window.hud then return end
  Card.mode = Config.get("music.cardMode") == "mini" and "mini" or "full"
  local view = Config.get("music.cardView")
  Card.view = (view == "lyrics" or view == "queue") and view or "cover"
  local x, y = Config.get("music.cardX"), Config.get("music.cardY")
  if type(x) == "number" and x >= 0 and type(y) == "number" and y >= 0 then Card.at = Vector2.new(x, y) end
  local holder = frame(Window.hud, { Name = "MusicCard", Size = UDim2.fromOffset(FULL_W, FULL_H), Visible = false, ZIndex = 1 })
  -- (one UIScale a frame: the window's scale, times the pop when it shows)
  local sizer = Instance.new("UIScale")
  sizer.Parent = holder
  local pop = Instance.new("NumberValue")
  pop.Value = 1
  local drop = Instance.new("NumberValue")
  drop.Value = 0
  Card.drop = drop
  Card.holder = holder
  build()
  Card.seat()
  paint()
  Music.changed:connect(function(what)
    if what == "queue" and Card.view ~= "queue" then return end
    B.try("card.paint", paint)
  end)
  Config.on("music.liked", function() B.try("card.paint", paint) end)
  -- It comes and goes with the menu, on the menu's own clock (2026-10-30: it had one of its own,
  -- and came back over the menu's cards while they were still going down). The menu opening: it
  -- sinks and fades with the cards rising (0.16 s). The menu closing: it waits for the cards to
  -- have gone down (each look's close takes so long), then rises into place with the same ease.
  local shown, leaving, menuShutAt = false, nil, -math.huge
  local wasOpen = Window.anyOpen()
  local CLOSE_TAKES = { novoline = 0.3, unnamed = 0.12, based = 0.24 }
  Motion.every(function(dt)
    local kit = Window.activeKit()
    if parts and kit.look ~= parts.look then build(); paint() end
    local ctl = Music.front()
    local track = ctl.track()
    local open = Window.anyOpen()
    if wasOpen and not open then menuShutAt = os.clock() end
    wasOpen = open
    local settled = os.clock() - menuShutAt >= (CLOSE_TAKES[kit.look] or 0.24)
    local show = Config.get("music.mini") ~= false and track ~= nil and ctl.state() ~= "idle" and not open and settled
    if show ~= shown then
      shown = show
      if show then
        leaving = nil
        holder.Visible = true
        paint()
        if Motion.reduced then pop.Value, drop.Value = 1, 0 else
          pop.Value, drop.Value = 0.94, 14
          Motion.to(pop, "Value", 1, "smooth")
          Motion.to(drop, "Value", 0, "smooth")
        end
      elseif Motion.reduced or not holder.Visible then
        holder.Visible = false
      else
        -- (going: down and smaller, quickly, then put away)
        local token = {}
        leaving = token
        Motion.to(pop, "Value", 0.94, { 0.16, 0 })
        Motion.to(drop, "Value", 14, { 0.16, 0 }, function() if leaving == token then holder.Visible = false end end)
      end
    end
    if leaving and holder.Visible then sizer.Scale = (Window.scale or 1) * pop.Value; Card.seat() end
    if not show or not parts then return end
    sizer.Scale = (Window.scale or 1) * pop.Value
    Card.seat()
    if parts.paintedFor ~= track.key or parts.paintedState ~= ctl.state() then
      parts.paintedFor, parts.paintedState = track.key, ctl.state()
      paint()
    end
    parts.title.step(dt)
    local position, length = ctl.position(), ctl.length()
    local fraction = length > 0 and math.clamp(position / length, 0, 1) or 0
    local seeking = parts.seekLine.dragging or parts.miniLine.dragging
    if seeking then fraction = seeking; position = seeking * length end
    parts.seekLine.set(fraction)
    parts.miniLine.set(fraction)
    local at = length > 0 and timeOf(position) or "--:--"
    local left = length > 0 and ("-" .. timeOf(math.max(length - position, 0))) or ""
    setText(parts.at, at)
    setText(parts.left, left)
    setText(parts.miniAt, at)
    setText(parts.miniLeft, left)
    if not parts.volumeLine.dragging then
      local volume = ctl.volume and ctl.volume() or nil
      parts.volumeLine.frame.Visible = volume ~= nil
      parts.quiet.Visible, parts.loud.Visible = volume ~= nil, volume ~= nil
      parts.volumeLine.set(volume or 0)
      UI.setIcon(parts.quiet, (volume or 1) <= 0.001 and "volume-x" or "volume-2")
    end
    if Card.mode == "full" and Card.view == "lyrics" then parts.lyrics.step(dt, ctl) end
    if Card.mode == "mini" then
      local accent = Card.accent or WHITE
      local playing = ctl.state() == "playing"
      local raw = playing and ctl.loudness() or 0
      parts.peak = math.max((parts.peak or 4) * (1 - math.min(dt * 0.35, 1)), raw, 4)
      local loud = playing and math.clamp(raw / parts.peak * 1.05, 0, 1.15) or 0
      parts.level = (parts.level or 0) + (loud - (parts.level or 0)) * math.min(dt * 12, 1)
      local now = os.clock()
      for i, bar in ipairs(parts.bars) do
        local wobble = 0.4 + 0.6 * math.abs(math.sin(now * (3.3 + i * 1.1) + i * 1.9))
        bar.Size = UDim2.fromOffset(3, math.clamp(4 + parts.level * 12 * wobble, 4, 16))
        bar.BackgroundColor3 = accent
      end
    end
  end, nil, "music.card")
  Island.start()
end
end

do -- 50_settings.lua (standalone)
-- ============================================================================
--  50 settings   the library's own preferences and the Settings tab
--
--  Taken from BasedHub's Settings, kept to what the Novoline look has: its
--  colour, font, size, shade, dock and island; motion and sound; keys; what
--  stays on screen; this server; configs; about. Every control here is live.
-- ============================================================================
local S, util, Motion, UI, Config, Window = B.S, B.util, B.Motion, B.UI, B.Config, B.Window
local Assets = B.Assets
local Prefs = {}
B.Prefs = Prefs
B.pages = B.pages or {}
B.TITLE = B.TITLE or "BASED"

-- applied once at boot (after Config.init), then kept in step with the switches
function Prefs.apply()
  Motion.reduced = Config.get("app.motion") == "reduced"
  Motion.speed = (Config.get("app.motionSpeed") or 100) / 100
  UI.sfxOn = Config.get("app.sfx") ~= false
  UI.sfxVolume = (Config.get("app.sfxVolume") or 45) / 100
  Config.on("app.motion", function(v) Motion.reduced = v == "reduced" end)
  Config.on("app.motionSpeed", function(v) Motion.speed = (v or 100) / 100 end)
  Config.on("app.sfx", function(v) UI.sfxOn = v ~= false end)
  Config.on("app.sfxVolume", function(v) UI.sfxVolume = (v or 45) / 100 end)
end

local function openKeys()
  if B.Novoline and B.Novoline.go and B.Novoline.active() then B.Novoline.go("keys") else Window.go("keys") end
end

B.pages[#B.pages + 1] = function()
  Window.page({ id = "settings", title = "Settings", icon = "settings", group = "Hub", order = 900, eyebrow = "Make it yours", build = function(page)
    local look = page:section({ title = "Appearance", icon = "palette", desc = "Changes apply live." })
    if B.Novoline then
      look:color({ id = "app.novoline.accent", label = "Novoline colour", desc = "Its one colour: icons, checks, the island's dot." })
      local faces = {}
      for _, spec in ipairs(B.Novoline.FONTS) do faces[#faces + 1] = { spec[1], spec[2] } end
      look:dropdown({ id = "app.novoline.font", label = "Novoline font", desc = "Gotham is Novoline's own.", options = faces })
      look:slider({ id = "app.novoline.size", label = "Novoline size", tip = "How big the Novoline look is.", min = 70, max = 140, step = 5, suffix = "%" })
      look:slider({ id = "app.novoline.shade", label = "Novoline shade", desc = "How dark the game goes behind it.", min = 0, max = 100, step = 5, suffix = "%" })
      look:toggle({ id = "app.novoline.dock", label = "Keep the dock", desc = "The pill stays at the bottom while it is shut.", bindable = false })
      look:toggle({ id = "app.novoline.island", label = "Novoline island", desc = "The song and every message, top middle.", bindable = false })
    end
    look:slider({ id = "app.scale", label = "Interface size", desc = "It never grows past the screen.", min = 60, max = 160, step = 5, suffix = "%" })

    local motion = page:section({ title = "Motion & sound", icon = "activity" })
    motion:segmented({ id = "app.motion", label = "Animations", tip = "Full or reduced motion.", options = { { "full", "Full" }, { "reduced", "Reduced" } }, width = 170 })
    motion:slider({ id = "app.motionSpeed", label = "Animation speed", tip = "How fast animations play.", min = 40, max = 250, step = 10, suffix = "%" })
    motion:toggle({ id = "app.sfx", label = "Interface sounds", tip = "Clicks and pops in the menu.", bindable = false })
    motion:slider({ id = "app.sfxVolume", label = "Sound volume", tip = "How loud the menu sounds are.", min = 0, max = 100, step = 5, suffix = "%" })

    local keys = page:section({ title = "Keys", icon = "keyboard" })
    keys:keybind({ tip = "The key that opens and closes the hub.", id = "app.key.menu", label = "Open / close the hub" })
    keys:keybind({ id = "app.key.panic", label = "Panic", desc = "Unloads " .. B.TITLE .. " instantly: every feature off, nothing left behind." })
    keys:toggle({ id = "app.freeCursor", label = "Free the cursor while open", desc = "Unlocks the mouse in first-person games.", bindable = false })
    keys:button({ label = "Every key, on a keyboard", desc = "What each one does, and a click to change it.", text = "Open", bindable = false, run = openKeys })
    keys:note({ icon = "info", text = "Right-click any toggle or button to bind it to a key." })

    local screen = page:section({ title = "On screen", icon = "monitor", desc = "What stays up while the hub is hidden." })
    screen:toggle({ id = "app.keyHud", label = "My keys", desc = "Each bound feature with its key, lit while it is on.", bindable = false })

    local server = page:section({ title = "This server", icon = "server" })
    server:button({ id = "server.rejoin", label = "Rejoin", desc = "Leave and come straight back.", text = "Rejoin", run = function() B.Server.rejoin() end })
    server:dropdown({ id = "world.hopMode", label = "Hop to", tip = "What kind of server to hop to.", options = { { "random", "Any other server" }, { "empty", "The emptiest" }, { "full", "The fullest with room" } } })
    server:button({ id = "server.hop", label = "Server hop", desc = "Join a different server of this game.", text = "Hop", run = function() B.Server.hop() end })
    server:button({ label = "Copy join script", desc = "A line that lands in this exact server.", text = "Copy", run = function() B.Server.copyJoin() end, bindable = false })
    server:button({ label = "Copy server ID", tip = "Copies this server's ID.", text = "Copy", bindable = false, run = function()
      Window.toast(B.clipboard(game.JobId) and { title = "Server ID copied", icon = "clipboard", tone = "ok" } or { title = "No clipboard access", icon = "triangle-alert", tone = "warn" })
    end })

    local data = page:section({ title = "Configs", icon = "save", desc = "Feature settings save on their own." })
    data:segmented({ label = "Saved", tip = "One config for every game, or one per game.", options = { { "global", "One for all games" }, { "game", "One per game" } }, default = Config.profileMode, width = 232,
      changed = function(mode)
        if mode ~= Config.profileMode then
          Config.setMode(mode)
          Window.toast({ title = "Config scope changed", text = mode == "game" and "This game now has its own settings." or "One config for every game.", icon = "save" })
        end
      end })
    data:button({ label = "Copy share code", desc = "Everything: settings, colours, font, keys.", text = "Copy", run = function()
      local code = Config.export()
      if code and B.clipboard(code) then Window.toast({ title = "Share code copied", text = "Whoever pastes it gets your exact setup.", icon = "clipboard", tone = "ok" })
      else Window.toast({ title = "Could not copy", text = "This executor has no clipboard access.", icon = "triangle-alert", tone = "warn" }) end
    end })
    local importBox
    importBox = data:input({ label = "Paste share code", tip = "Paste a code to copy someone's setup.", placeholder = "Paste, then Enter", width = 170, changed = function(text)
      if text == "" then return end
      local ok, count = Config.import(text)
      importBox.box.Text = ""
      Window.toast(ok and { title = "Setup loaded", text = count .. " settings and keys applied.", icon = "circle-check", tone = "ok" }
        or { title = "Not a share code", text = "That text could not be read.", icon = "triangle-alert", tone = "warn" })
    end })
    data:button({ label = "Reset every feature", desc = "Appearance and keys are kept.", text = "Reset", style = "danger", run = function()
      Config.resetAll(false)
      Window.toast({ title = "Features reset", text = "Everything is back to its default.", icon = "rotate-ccw" })
    end })

    local about = page:section({ title = "About", icon = "info" })
    local function stat(label, value)
      about:custom({ height = 34, build = function(frame)
        UI.text(frame, label, "label", "sub", { Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13 })
        local text = UI.text(frame, "", "mono", "ink", { Position = UDim2.new(1, -14, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
        if type(value) == "function" then
          text.Text = tostring(value())
          Motion.every(function() if text.Parent and Window.showing("settings") then text.Text = tostring(value()) end end, 2, "about")
        else text.Text = tostring(value) end
      end })
    end
    stat("Version", B.VERSION .. "  ·  " .. B.BUILD)
    stat("Executor", B.executor)
    stat("Assets", function() return Assets.lite and "missing (lite mode)" or (Assets.calls .. " registered this session") end)
    stat("Started in", function() return (B.bootMs or 0) .. " ms" end)
    stat("Faults", function() return #B.faults end)
    about:button({ label = "Copy diagnostics", tip = "Copies info that helps fix a problem.", text = "Copy", run = function()
      local lines = { B.TITLE .. " " .. B.VERSION .. " " .. B.BUILD, "executor " .. B.executor, "place " .. game.PlaceId .. " universe " .. game.GameId }
      for _, fault in ipairs(B.faults) do lines[#lines + 1] = string.format("[%.1fs] %s: %s", fault.at, fault.scope, fault.message) end
      B.clipboard(table.concat(lines, "\n"))
      Window.toast({ title = "Diagnostics copied", icon = "clipboard", tone = "ok" })
    end })
    about:button({ label = "Unload " .. B.TITLE, tip = "Turns the hub off completely.", text = "Unload", style = "danger", bindable = false, run = function() B.unload() end })
  end })
end
end

do -- 51_keys.lua
-- ============================================================================
--  51 keys     the keyboard, drawn, with what every key does written on it
--
--  A key can be given a feature from either side: right-click a toggle or a
--  button and press a key, or come here, click the key and pick the feature.
--  The picture is the same either way. A bound key carries its feature's name
--  and lights up while that feature is on; the keys the hub and flight already
--  use are marked; a key asked to do two things is flagged. The same list can
--  sit on screen while the hub is hidden.
-- ============================================================================
local S, util, Motion, Theme, T, UI, Config, Window, Controls = B.S, B.util, B.Motion, B.Theme, B.T, B.UI, B.Config, B.Window, B.Controls
local UIS = S.UserInputService
local Keys = { caps = {}, builtin = {} }
B.Keys = Keys
B.pages = B.pages or {}

-- An ANSI board in units of one key; every row is fifteen units wide. A unit of 48 keeps every
-- key an even number of pixels wide, which matters: a UDim offset is a whole number, and a key
-- anchored at its centre with an odd width sits half a pixel off its neighbours.
local UNIT, GAP, HEIGHT = 44, 4, 40
local function k(key, width) return { key = key, width = width or 1 } end
local function gap(width) return { width = width } end
local ROWS = {
  { k("Escape"), gap(1), k("F1"), k("F2"), k("F3"), k("F4"), gap(0.5), k("F5"), k("F6"), k("F7"), k("F8"), gap(0.5), k("F9"), k("F10"), k("F11"), k("F12") },
  { k("Backquote"), k("One"), k("Two"), k("Three"), k("Four"), k("Five"), k("Six"), k("Seven"), k("Eight"), k("Nine"), k("Zero"), k("Minus"), k("Equals"), k("Backspace", 2) },
  { k("Tab", 1.5), k("Q"), k("W"), k("E"), k("R"), k("T"), k("Y"), k("U"), k("I"), k("O"), k("P"), k("LeftBracket"), k("RightBracket"), k("BackSlash", 1.5) },
  { k("CapsLock", 1.75), k("A"), k("S"), k("D"), k("F"), k("G"), k("H"), k("J"), k("K"), k("L"), k("Semicolon"), k("Quote"), k("Return", 2.25) },
  { k("LeftShift", 2.25), k("Z"), k("X"), k("C"), k("V"), k("B"), k("N"), k("M"), k("Comma"), k("Period"), k("Slash"), k("RightShift", 2.75) },
  { k("LeftControl", 1.5), k("LeftAlt", 1.25), k("Space", 5.5), k("RightAlt", 1.25), k("RightControl", 1.5), k("Left"), k("Up"), k("Down"), k("Right") },
  { k("Insert", 1.25), k("Delete", 1.25), k("Home", 1.25), k("End", 1.25), k("PageUp", 1.25), k("PageDown", 1.25), gap(0.5), k("MouseButton2", 2.25), k("MouseButton3", 2.25) },
}
Keys.width = 15 * (UNIT + GAP) - GAP
Keys.height = #ROWS * (HEIGHT + GAP) - GAP
local LONG = { MouseButton2 = "Right click", MouseButton3 = "Middle click", Backspace = "Backspace", Return = "Enter", CapsLock = "Caps", Space = "Space",
  LeftShift = "Shift", RightShift = "Shift", LeftControl = "Ctrl", RightControl = "Ctrl", LeftAlt = "Alt", RightAlt = "Alt", Tab = "Tab", Escape = "Esc",
  Insert = "Ins", Delete = "Del", PageUp = "PgUp", PageDown = "PgDn" }
-- on the cap the two Shifts and the two Ctrls are told apart by where they sit; in a sentence they need saying
local function capLabel(key) return LONG[key] or Config.keyLabel(key) end
local function keyName(key) return Config.keyLabel(key) end

-- ---------------------------------------------------------------- what is on a key
-- the keys the hub and flight already use, read fresh: three of them can be moved
local function readBuiltins()
  local map = {}
  local function put(key, short, what, flag)
    if type(key) ~= "string" or key == "None" then return end
    map[key] = map[key] or {}
    table.insert(map[key], { short = short, what = what, flag = flag })
  end
  put(Config.get("app.key.menu"), "Menu", "opens and closes the hub", "app.key.menu")
  put(Config.get("app.key.panic"), "Panic", "unloads the UI", "app.key.panic")
  for _, key in ipairs({ "W", "A", "S", "D" }) do put(key, "Move", "walk and steer") end
  Keys.builtin = map
  return map
end
-- (a feature whose switch has not been drawn yet is named from its id: "some.feature" -> "Air jump")
local function nameFromId(id)
  local last = string.match(id, "([^%.]+)$") or id
  last = string.gsub(last, "(%l)(%u)", "%1 %2")
  return string.upper(string.sub(last, 1, 1)) .. string.lower(string.sub(last, 2))
end
local function featureOf(id)
  local entry = Controls.bindables[id]
  local kind = entry and entry.kind or (type(Config.get(id)) == "boolean" and "toggle" or "button")
  return entry and entry.label or nameFromId(id), kind, entry and entry.page and entry.page.title or nil
end
-- every feature bound to `key`, by name
function Keys.on(key)
  local list = {}
  for id, bind in pairs(Config.binds) do
    if bind.key == key then
      local label, kind, page = featureOf(id)
      list[#list + 1] = { id = id, label = label, kind = kind, page = page, mode = bind.mode, on = Config.get(id) == true or (kind == "button" and Config.isActive(id)) }
    end
  end
  table.sort(list, function(a, b) return a.label < b.label end)
  return list
end
-- every bind there is, in keyboard order
function Keys.all()
  local order, list = {}, {}
  for _, row in ipairs(ROWS) do
    for _, item in ipairs(row) do
      if item.key then order[item.key] = #list + 1; list[#list + 1] = item.key end
    end
  end
  local out = {}
  for id, bind in pairs(Config.binds) do
    if bind.key then
      local label, kind, page = featureOf(id)
      out[#out + 1] = { id = id, key = bind.key, label = label, kind = kind, page = page, mode = bind.mode, on = Config.get(id) == true or (kind == "button" and Config.isActive(id)) }
    end
  end
  table.sort(out, function(a, b)
    local ka, kb = order[a.key] or 999, order[b.key] or 999
    if ka ~= kb then return ka < kb end
    return a.label < b.label
  end)
  return out
end
function Keys.describe(key)
  local features, roles = Keys.on(key), Keys.builtin[key]
  local parts = {}
  for _, f in ipairs(features) do
    parts[#parts + 1] = f.label .. (f.kind == "toggle" and (f.mode == "hold" and " (while held" or " (toggle") .. (f.on and ", on)" or ", off)") or " (runs it)")
  end
  for _, role in ipairs(roles or {}) do parts[#parts + 1] = role.what end
  local name = keyName(key)
  if #parts == 0 then return name .. "  ·  free. Click it to give it a feature." end
  local clash = #features > 1 or (#features > 0 and roles ~= nil)
  return name .. "  ·  " .. table.concat(parts, "  +  ") .. (clash and "   — more than one thing on this key" or "")
end

-- ---------------------------------------------------------------- menus
local function menuRow(content, order, item, close)
  local row = UI.frame(content, { Name = item.name or "Item", Size = UDim2.new(1, 0, 0, 32), LayoutOrder = order, Theme = { BackgroundColor3 = "ink" } })
  UI.corner(row, "rSmall")
  local x = 10
  if item.icon then
    UI.icon(row, item.icon, 16, item.danger and "bad" or "sub", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
    x = 34
  end
  UI.text(row, item.label, "label", item.danger and "bad" or "ink", { Position = UDim2.new(0, x, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13,
    Size = UDim2.new(1, -(x + (item.hint and 78 or 30)), 0, 18), AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd })
  if item.checked then
    UI.icon(row, "check", 15, "accent", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5) })
  elseif item.hint then
    UI.text(row, item.hint, "mono", "faint", { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
  end
  UI.button(row, {
    hover = function(on) Motion.to(row, "BackgroundTransparency", on and T.fill2A or 1, "quick") end,
    click = function()
      UI.sfx("click", 0.6)
      close()
      if item.run then B.try("keys.menu", item.run) end
    end,
  })
  return row
end
-- pick a feature for `key`: every toggle and button the hub has, searchable
function Keys.pick(anchor, key)
  local list = {}
  for id, entry in pairs(Controls.bindables) do
    local bind = Config.bindOf(id)
    if not (bind and bind.key == key) then
      list[#list + 1] = { id = id, label = entry.label, page = entry.page and entry.page.title or "", key = bind and bind.key or nil }
    end
  end
  table.sort(list, function(a, b) return a.label < b.label end)
  return UI.popover(anchor, { width = 276, align = "center", pad = 8, gap = 6 }, function(content, close)
    UI.text(content, "Give " .. keyName(key) .. " a feature", "eyebrow", "faint", { LayoutOrder = 1, TextSize = 9 })
    local _, box = Controls.field(content, { Width = 260, PlaceholderText = "Search " .. #list .. " features" }, function() end)
    box.Parent.LayoutOrder = 2
    local holder = UI.frame(content, { Name = "List", Size = UDim2.new(1, 0, 0, 238), LayoutOrder = 3, ClipsDescendants = true })
    local scroller = UI.scroll(holder, { Size = UDim2.fromScale(1, 1), Name = "Scroll" })
    local rows = UI.frame(scroller, { Name = "Rows", Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
    UI.list(rows, "y", 2)
    local made = {}
    for index, feature in ipairs(list) do
      local row = menuRow(rows, index, { name = feature.id, label = feature.label, hint = feature.key and Config.keyLabel(feature.key) or feature.page, run = function()
        Config.bind(feature.id, key)
        Window.toast({ title = feature.label .. " is on " .. keyName(key), text = "Right-click the key to clear it.", icon = "keyboard" })
      end }, close)
      made[index] = { row = row, text = string.lower(feature.label .. " " .. feature.page) }
    end
    if #list == 0 then
      UI.text(rows, "Nothing left to bind: open the other tabs once so their switches are known.", "caption", "sub", { TextWrapped = true, Size = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y })
    end
    box:GetPropertyChangedSignal("Text"):Connect(function()
      local query = string.lower(box.Text)
      for _, item in ipairs(made) do item.row.Visible = query == "" or string.find(item.text, query, 1, true) ~= nil end
    end)
  end)
end
-- what clicking a key opens: what is on it, and what can be done about that
function Keys.menu(anchor, key)
  local features, roles = Keys.on(key), Keys.builtin[key]
  return UI.popover(anchor, { width = 252, align = "center" }, function(content, close)
    local order = 0
    local function add(item) order += 1; return menuRow(content, order, item, close) end
    local head = UI.frame(content, { Name = "Head", Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 0 })
    UI.text(head, keyName(key), "heading", "ink", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5) })
    UI.text(head, #features == 0 and (roles and roles[1].short or "Free") or (#features .. (#features == 1 and " feature" or " features")), "mono", "faint",
      { Position = UDim2.new(1, -10, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), TextSize = 11 })
    for _, f in ipairs(features) do
      if f.kind == "toggle" then
        add({ name = "Hold_" .. f.id, label = f.label .. ": only while held", icon = "hand", checked = f.mode == "hold", run = function()
          Config.bind(f.id, key, f.mode == "hold" and "toggle" or "hold")
        end })
      end
      add({ name = "Unbind_" .. f.id, label = "Take " .. f.label .. " off this key", icon = "x", danger = true, run = function() Config.bind(f.id, nil) end })
    end
    for _, role in ipairs(roles or {}) do
      if role.flag then
        add({ name = "Move_" .. role.flag, label = "Move " .. string.lower(role.short) .. " to another key…", icon = "keyboard", run = function()
          Window.toast({ title = "Press a key", text = "Esc cancels · Backspace clears", icon = "keyboard", time = 2.2 })
          Controls.captureKey(function(next, cancelled)
            if not cancelled then Config.set(role.flag, next or "None") end
          end)
        end })
      end
    end
    add({ name = "Bind", label = "Bind a feature to this key…", icon = "plus", run = function() task.defer(Keys.pick, anchor, key) end })
  end)
end
function Keys.clear(key)
  local cleared = 0
  for _, f in ipairs(Keys.on(key)) do
    Config.bind(f.id, nil)
    cleared += 1
  end
  if cleared > 0 then Window.toast({ title = keyName(key) .. " is free again", text = cleared .. (cleared == 1 and " feature taken off it." or " features taken off it."), icon = "keyboard" }) end
  return cleared
end

-- ---------------------------------------------------------------- the board
local function tint(instance, property, token) Theme.bind(instance, property, token) end
local function fixed(instance, property, value)
  Theme.unbind(instance, property)
  instance[property] = value
end
local function paint(entry)
  local key = entry.key
  local features, roles = Keys.on(key), Keys.builtin[key]
  local on = false
  for _, f in ipairs(features) do on = on or f.on end
  local clash = #features > 1 or (#features > 0 and roles ~= nil)
  entry.features, entry.roles, entry.clash, entry.lit = features, roles, clash, on
  local cap, label, what, stroke = entry.cap, entry.label, entry.what, entry.stroke
  if #features > 0 then
    -- bound: the feature's name on the key, solid while it is on
    tint(cap, "BackgroundColor3", "accent")
    fixed(cap, "BackgroundTransparency", on and 0 or 0.8)
    tint(label, "TextColor3", on and "accentInk" or "ink")
    tint(what, "TextColor3", on and "accentInk" or "ink")
    what.Text = features[1].label .. (#features > 1 and ("  +" .. #features - 1) or "")
    tint(stroke, "Color", clash and "warn" or "accent")
    fixed(stroke, "Transparency", clash and 0 or 0.35)
  elseif roles then
    -- the hub's own, or flight's
    tint(cap, "BackgroundColor3", "ink")
    tint(cap, "BackgroundTransparency", "fill2A")
    tint(label, "TextColor3", "ink")
    tint(what, "TextColor3", "faint")
    what.Text = roles[1].short
    tint(stroke, "Color", "ink")
    tint(stroke, "Transparency", "stroke2A")
  else
    tint(cap, "BackgroundColor3", "ink")
    tint(cap, "BackgroundTransparency", "fill1A")
    tint(label, "TextColor3", "sub")
    what.Text = ""
    tint(stroke, "Color", "ink")
    tint(stroke, "Transparency", "strokeA")
  end
  local named = what.Text ~= ""
  what.Visible = named
  label.Position = named and UDim2.new(0.5, 0, 0, 13) or UDim2.fromScale(0.5, 0.5)
end
local repaintQueued = false
function Keys.repaint()
  if repaintQueued then return end
  repaintQueued = true
  task.defer(function()
    repaintQueued = false
    readBuiltins()
    for _, entry in pairs(Keys.caps) do
      if entry.cap.Parent then paint(entry) end
    end
    if Keys.renderList then Keys.renderList() end
    if Keys.renderHud then Keys.renderHud() end
  end)
end
local function board(frame)
  local holder = UI.frame(frame, { Name = "Board", Size = UDim2.fromOffset(Keys.width, Keys.height), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6) })
  local legend = UI.text(frame, "", "caption", "sub", { Name = "Legend", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, Keys.height + 18), Size = UDim2.fromOffset(Keys.width, 16),
    AutomaticSize = Enum.AutomaticSize.None, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd })
  local RESTING = "Click a key to give it a feature.  Right-click a key to clear it.  Bound keys light up while their feature is on."
  legend.Text = RESTING
  Keys.legend = legend
  readBuiltins()
  for rowIndex, row in ipairs(ROWS) do
    local x = 0
    local y = (rowIndex - 1) * (HEIGHT + GAP)
    for _, item in ipairs(row) do
      local width = item.width * (UNIT + GAP) - GAP
      if item.key then
        local key = item.key
        -- anchored at its centre, so the press shrinks it in place
        local cap = UI.pressable(holder, { Name = "Cap_" .. key, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x + width / 2, y + HEIGHT / 2),
          Size = UDim2.fromOffset(width, HEIGHT) })
        UI.corner(cap, "rSmall")
        local entry = { key = key, cap = cap, scale = UI.scaleOf(cap) }
        entry.stroke = UI.stroke(cap, "ink", "strokeA")
        entry.label = UI.text(cap, capLabel(key), "mono", "sub", { Name = "Label", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), TextSize = 11 })
        entry.what = UI.text(cap, "", "caption", "ink", { Name = "What", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -5), Size = UDim2.new(1, -6, 0, 11),
          AutomaticSize = Enum.AutomaticSize.None, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.AtEnd, Visible = false })
        Keys.caps[key] = entry
        paint(entry)
        UI.wire(cap, {
          hover = function(over)
            legend.Text = over and Keys.describe(key) or RESTING
            Theme.bind(legend, "TextColor3", over and (entry.clash and "warn" or "ink") or "sub")
            if not entry.held then Motion.to(entry.scale, "Scale", over and 1.05 or 1, "snappy") end
          end,
          click = function() UI.sfx("click", 0.6); Keys.menu(cap, key) end,
          alt = function() Keys.clear(key) end,
        })
      end
      x += item.width * (UNIT + GAP)
    end
  end
  -- a key pressed for real dips on the board: it is the quickest way to find out which one is which
  B.connect(UIS.InputBegan, function(input)
    local entry = Keys.caps[Config.keyName(input) or ""]
    if entry and entry.cap.Parent and Window.showing("keys") then
      entry.held = true
      Motion.to(entry.scale, "Scale", 0.9, "quick")
    end
  end, "keys.press")
  B.connect(UIS.InputEnded, function(input)
    local entry = Keys.caps[Config.keyName(input) or ""]
    if entry and entry.held then
      entry.held = false
      if entry.cap.Parent then Motion.to(entry.scale, "Scale", 1, "bouncy") end
    end
  end, "keys.release")
  Theme.changed:connect(function() if holder.Parent then Keys.repaint() end end)
end

-- ---------------------------------------------------------------- the list beside it
local function list(frame)
  local holder = UI.frame(frame, { Name = "Bound", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
  UI.list(holder, "y", 0)
  UI.pad(holder, 2, 0, 6, 0)
  function Keys.renderList()
    if not holder.Parent then return end
    for _, child in ipairs(holder:GetChildren()) do
      if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    local binds = Keys.all()
    if #binds == 0 then
      local empty = UI.frame(holder, { Name = "Empty", Size = UDim2.new(1, 0, 0, 74) })
      UI.icon(empty, "keyboard", 20, "faint", { Position = UDim2.fromOffset(14, 14) })
      UI.text(empty, "Nothing is bound yet", "label", "ink", { Position = UDim2.fromOffset(44, 12) })
      UI.text(empty, "Click a key on the board, or right-click any switch in the hub and press the key you want for it.", "caption", "sub", { Position = UDim2.fromOffset(44, 32),
        Size = UDim2.new(1, -58, 0, 30), AutomaticSize = Enum.AutomaticSize.None, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, LineHeight = 1.15 })
      return
    end
    for index, bind in ipairs(binds) do
      local row = UI.frame(holder, { Name = "Bind_" .. bind.id, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = index })
      if index > 1 then
        UI.frame(row, { Name = "Rule", Size = UDim2.new(1, -28, 0, 1), Position = UDim2.fromOffset(14, 0), Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "strokeA" } })
      end
      local chip = UI.frame(row, { Name = "Chip", Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(58, 24),
        Theme = { BackgroundColor3 = "accent" }, BackgroundTransparency = bind.on and 0 or 0.8 })
      UI.corner(chip, 7)
      UI.text(chip, Config.keyLabel(bind.key), "monoBold", bind.on and "accentInk" or "ink", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), TextSize = 11 })
      UI.text(row, bind.label, "label", "ink", { Name = "Feature", Position = UDim2.new(0, 84, 0.5, bind.page and -8 or 0), AnchorPoint = Vector2.new(0, 0.5), TextSize = 13,
        Size = UDim2.new(1, -220, 0, 18), AutomaticSize = Enum.AutomaticSize.None, TextTruncate = Enum.TextTruncate.AtEnd })
      if bind.page then
        UI.text(row, bind.page, "caption", "faint", { Position = UDim2.new(0, 84, 0.5, 9), AnchorPoint = Vector2.new(0, 0.5), TextSize = 11 })
      end
      -- how the key works it: press to flip, hold to keep on, or simply run
      local mode = UI.pressable(row, { Name = "Mode", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -48, 0.5, 0), Size = UDim2.fromOffset(74, 24),
        Theme = { BackgroundColor3 = "ink", BackgroundTransparency = "fill2A" } })
      UI.corner(mode, 7)
      UI.text(mode, bind.kind == "toggle" and (bind.mode == "hold" and "While held" or "Toggle") or "Runs it", "caption", bind.kind == "toggle" and "ink" or "faint",
        { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), TextSize = 11 })
      if bind.kind == "toggle" then
        UI.wire(mode, { click = function() UI.sfx("click", 0.5); Config.bind(bind.id, bind.key, bind.mode == "hold" and "toggle" or "hold") end })
      end
      local remove = UI.pressable(row, { Name = "Unbind", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(24, 24) })
      UI.corner(remove, 7)
      local cross = UI.icon(remove, "x", 14, "faint", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
      UI.wire(remove, {
        hover = function(over) Theme.bind(cross, "ImageColor3", over and "bad" or "faint") end,
        click = function() UI.sfx("click", 0.5); Config.bind(bind.id, nil) end,
      })
    end
  end
  Keys.renderList()
end

-- ---------------------------------------------------------------- a list on screen that lights smoothly
-- Rows are kept from one draw to the next: a feature switched on fades its row in (and its key
-- chip pops), switched off it fades back. Only a change of what is bound redraws the rows.
local TS = S.TweenService
local LIGHT = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
Keys.LIGHT = LIGHT
-- what the rows show, as one string: equal means only the lights may have changed
function Keys.shape(binds, moving, most)
  local parts = { moving and "m" or "-", tostring(#binds) }
  for index, bind in ipairs(binds) do
    if index > most then break end
    parts[#parts + 1] = bind.id .. "|" .. tostring(bind.key) .. "|" .. tostring(bind.mode) .. "|" .. tostring(bind.label)
  end
  return table.concat(parts, ";")
end
function Keys.basedPanel(holder)
  local glass = UI.glass(holder, { level = "popover", radius = 14, shadow = 20, shadowY = 8, grain = false, props = { Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY } })
  local body = UI.frame(glass, { Name = "Body", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY })
  UI.pad(body, 9, 10, 10, 10)
  UI.list(body, "y", 3)
  local api = { frame = glass, rows = {}, shape = nil }
  local function light(row, on, animate)
    row.on = on
    local goal = { chip = on and 0 or 0.8, wash = on and 0.88 or 1, key = on and T.accentInk or T.ink, name = on and T.ink or T.sub }
    if animate and not Motion.reduced then
      TS:Create(row.chip, LIGHT, { BackgroundTransparency = goal.chip }):Play()
      TS:Create(row.wash, LIGHT, { BackgroundTransparency = goal.wash }):Play()
      TS:Create(row.key, LIGHT, { TextColor3 = goal.key }):Play()
      TS:Create(row.name, LIGHT, { TextColor3 = goal.name }):Play()
      if on then
        row.pop.Scale = 1.22
        Motion.to(row.pop, "Scale", 1, "bouncy")
      end
    else
      row.chip.BackgroundTransparency, row.wash.BackgroundTransparency = goal.chip, goal.wash
      row.key.TextColor3, row.name.TextColor3 = goal.key, goal.name
    end
  end
  function api.forget() api.shape = nil end
  function api.render(binds, moving)
    local shape = Keys.shape(binds, moving, 9)
    if shape == api.shape then
      for _, bind in ipairs(binds) do
        local row = api.rows[bind.id]
        if row and row.on ~= bind.on then light(row, bind.on, true) end
      end
      return
    end
    api.shape = shape
    local before = {}
    for id, row in pairs(api.rows) do before[id] = row.on end
    table.clear(api.rows)
    for _, child in ipairs(body:GetChildren()) do
      if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    UI.text(body, moving and "KEYS  ·  DRAG ME, THEN LOCK" or "KEYS", "eyebrow", moving and "accent" or "faint", { TextSize = 9, LayoutOrder = 0 })
    if #binds == 0 then UI.text(body, "Nothing is bound yet", "caption", "sub", { TextSize = 12, LayoutOrder = 1 }) end
    for index, bind in ipairs(binds) do
      if index > 9 then
        UI.text(body, "+" .. (#binds - 9) .. " more", "caption", "faint", { TextSize = 11, LayoutOrder = index })
        break
      end
      local line = UI.frame(body, { Name = "Bind_" .. bind.id, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = index })
      local wash = UI.frame(line, { Name = "Wash", Size = UDim2.new(1, 8, 1, 0), Position = UDim2.fromOffset(-4, 0), Theme = { BackgroundColor3 = "accent" }, BackgroundTransparency = 1 })
      UI.corner(wash, 6)
      local inner = UI.frame(line, { Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X })
      UI.list(inner, "x", 8, { v = "Center" })
      -- sized from its text: a chip that sizes itself left a single letter against its left edge
      local name = Config.keyLabel(bind.key)
      local chip = UI.frame(inner, { Name = "Chip", Size = UDim2.fromOffset(math.max(28, #name * 7 + 14), 18), LayoutOrder = 1, Theme = { BackgroundColor3 = "accent" },
        BackgroundTransparency = 0.8 })
      UI.corner(chip, 5)
      local pop = Instance.new("UIScale"); pop.Parent = chip
      local key = UI.text(chip, name, "monoBold", "ink", { TextSize = 10, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
      Theme.unbind(key, "TextColor3")
      local label = UI.text(inner, bind.label, "caption", "sub", { Name = "Feature", TextSize = 12, LayoutOrder = 2 })
      Theme.unbind(label, "TextColor3")
      local row = { chip = chip, wash = wash, key = key, name = label, pop = pop }
      api.rows[bind.id] = row
      local was = before[bind.id]
      light(row, was == nil and bind.on or was, false)
      if was ~= nil and was ~= bind.on then light(row, bind.on, true) end
    end
  end
  return api
end

-- ---------------------------------------------------------------- the list on screen
-- While the hub is hidden: each bound feature with its key, lit while it is on. It sits in the
-- bottom right corner until it is put somewhere else: unlocked (Keys tab), it shows with the hub
-- open too and goes where it is dragged; locked again, it stays there.
function Keys.hud()
  if Keys.panel or not Window.hud then return end
  local holder = UI.frame(Window.hud, { Name = "KeyList", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(0, 0),
    AutomaticSize = Enum.AutomaticSize.XY, Visible = false })
  local function unlocked() return Config.get("app.keyHudLock") == false end
  local function seat()
    local x, y = Config.get("app.keyHudX"), Config.get("app.keyHudY")
    if type(x) == "number" and type(y) == "number" and x >= 0 and y >= 0 then
      holder.AnchorPoint = Vector2.new(0.5, 0.5)
      holder.Position = UDim2.fromScale(math.clamp(x, 0.02, 0.98), math.clamp(y, 0.02, 0.98))
    else
      holder.AnchorPoint = Vector2.new(1, 1)
      holder.Position = UDim2.new(1, -16, 1, -16)
    end
  end
  seat()
  local sizer = Instance.new("UIScale"); sizer.Scale = Window.scale or 1; sizer.Parent = holder
  -- three looks, each with its own list: the BASED glass card, the Unnamed box, Novoline's dark card.
  -- Never one with another look's window.
  local style, panel
  local function lookNow()
    if B.Novoline ~= nil and B.Novoline.keyPanel ~= nil and B.Novoline.active() then return "novoline" end
    if B.Unnamed ~= nil and B.Unnamed.keyPanel ~= nil and B.Unnamed.active() then return "unnamed" end
    return "based"
  end
  local function dress()
    if panel then panel.frame:Destroy(); panel = nil end
    style = lookNow()
    if style == "unnamed" then panel = B.Unnamed.keyPanel(holder)
    elseif style == "novoline" then panel = B.Novoline.keyPanel(holder)
    else panel = Keys.basedPanel(holder) end
  end
  dress()
  Keys.panel = holder
  -- the hand it is moved by: over all of it, and only there while it is unlocked
  local grip = UI.new("TextButton", { Name = "Move", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Visible = false, Parent = holder })
  local from
  UI.drag(grip, function(point)
    local centre = holder.AbsolutePosition + holder.AbsoluteSize / 2
    from = centre - point
    return true
  end, function(point)
    local layer = Window.hud
    local size = layer.AbsoluteSize
    if size.X < 1 or size.Y < 1 then return end
    local at = point + from - layer.AbsolutePosition
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.fromScale(math.clamp(at.X / size.X, 0.02, 0.98), math.clamp(at.Y / size.Y, 0.02, 0.98))
  end, function()
    -- (both read before either is kept: keeping one seats the list again, by the other's old value)
    local x, y = holder.Position.X.Scale, holder.Position.Y.Scale
    Config.set("app.keyHudX", x)
    Config.set("app.keyHudY", y)
  end)
  local function shouldShow()
    if Config.get("app.keyHud") == false then return false end
    if unlocked() then return true end
    return not Window.anyOpen() and next(Config.binds) ~= nil
  end
  function Keys.renderHud()
    if not holder.Parent then return end
    if lookNow() ~= style then dress() end
    sizer.Scale = (style == "unnamed" and B.Unnamed.scaleNow and B.Unnamed.scaleNow())
      or (style == "novoline" and B.Novoline.scaleNow and math.clamp(B.Novoline.scaleNow(), 0.7, 1.2)) or Window.scale or 1
    local binds = Keys.all()
    local moving = unlocked()
    grip.Visible = moving
    holder.Visible = shouldShow() and (#binds > 0 or moving)
    if holder.Visible then panel.render(binds, moving) end
  end
  Window.onShow:connect(function() Keys.renderHud() end)
  -- A bound button lights too: while what it started goes on (an emote playing), or for a moment
  -- after its key. Pressed: drawn at once; then looked at five times a second, drawn only on a change.
  local lit = ""
  local function litNow()
    local parts = {}
    for id, bind in pairs(Config.binds) do
      if bind.key and Config.isAction(id) and Config.isActive(id) then parts[#parts + 1] = id end
    end
    table.sort(parts)
    return table.concat(parts, ",")
  end
  Config.actionRan:connect(function() lit = litNow(); Keys.renderHud() end)
  Motion.every(function()
    if not holder.Visible then return end
    local now = litNow()
    if now ~= lit then lit = now; Keys.renderHud() end
  end, 5, "keys.lit")
  Config.on("app.keyHud", function() Keys.renderHud() end)
  Config.on("app.keyHudLock", function() Keys.renderHud() end)
  Config.on("app.gui", function() Keys.renderHud() end)
  Config.on("app.scale", function() Keys.renderHud() end)
  Theme.changed:connect(function() if panel and panel.forget then panel.forget() end; Keys.renderHud() end)
  Config.on("app.keyHudX", seat)
  Config.on("app.keyHudY", seat)
  Keys.renderHud()
end

-- ---------------------------------------------------------------- the tab
function Keys.define()
  Config.define("app.keyHud", true)
  Config.define("app.keyHudLock", true)
  Config.define("app.keyHudX", -1)          -- where it was put, as a share of the screen; under 0: the corner
  Config.define("app.keyHudY", -1)
end
B.pages[#B.pages + 1] = function()
  Keys.define()
  -- anything that changes what a key does, or whether a bound feature is on, redraws the board
  Config.bindsChanged:connect(function() Keys.repaint() end)
  Config.changed:connect(function(id)
  end)
  Config.loaded:connect(function() Keys.repaint() end)
  Window.page({ id = "keys", title = "Keys", icon = "keyboard", group = "Hub", order = 890, eyebrow = "What every key does", build = function(page)
    local map = page:section({ title = "Your keyboard", icon = "keyboard", full = true, desc = "Every key the hub listens to, and what it does." })
    map:custom({ height = Keys.height + 46, name = "Keyboard", build = board })

    local bound = page:section({ title = "Bound features", icon = "link", column = 1, weight = 6 })
    bound:custom({ name = "List", build = list })

    local own = page:section({ title = "The hub's own keys", icon = "command", column = 2, weight = 6 })
    own:keybind({ tip = "The key that opens and closes the hub.", id = "app.key.menu", label = "Open / close the hub" })
    own:keybind({ id = "app.key.panic", label = "Panic", desc = "Unloads the UI instantly." })
    own:toggle({ id = "app.keyHud", label = "Show my keys on screen", desc = "A small list while the hub is hidden, lit for whatever is on.", bindable = false })
    own:toggle({ id = "app.keyHudLock", label = "Lock where it sits", desc = "Off: drag the list anywhere on screen. On: it stays.", bindable = false })
    own:button({ label = "Back to the corner", tip = "Moves the key list back to its corner.", text = "Reset", bindable = false, run = function()
      Config.set("app.keyHudX", -1)
      Config.set("app.keyHudY", -1)
    end })
    own:button({ label = "Clear every bound key", desc = "The hub's own keys are kept.", text = "Clear", style = "danger", bindable = false, run = function()
      local cleared = 0
      for id in pairs(table.clone(Config.binds)) do Config.bind(id, nil); cleared += 1 end
      Window.toast({ title = cleared == 0 and "Nothing was bound" or "Keys cleared", text = cleared > 0 and (cleared .. " features are off their keys.") or nil, icon = "keyboard" })
    end })
  end })
end
end

do -- 53_novoline.lua
-- ============================================================================
--  53 novoline  the third look: Novoline, as it looks with everything on
--
--  Drawn after Novoline's design (its code is PolyForm Strict, so none of it is
--  here: only how it looks and moves, read from its source, 2026-10-29: its
--  "upstream 9" layout). A pill at the bottom of the screen holds the tabs.
--  Opening it shades the game and every tab comes up as a DECK: cards of dark
--  glass (a near-black gradient, 8,8,9 to 26,26,28, a fine white rim lit at
--  the top and bottom, a soft shadow) held in the four corners of the screen,
--  40 px in from the sides, 34 from the top and 90 from the bottom:
--    Home      Novoline's own: the welcome line, the clock and the executor top
--              right; you, quick actions, what is playing and two quick commands
--              bottom left; the game, this server and your friends bottom right.
--    any other Novoline's settings deck: the tab's name, a search pill and your
--              account top right; its sections in a list card beside the card
--              that holds the chosen section's controls (one faint white group,
--              hairlines between rows); quick settings (three tinted tiles: the
--              tab's first switches) and its shortcuts on the right.
--  Cards rise out of the dock when it opens (0.56 s quint out from a 120 x 44
--  pill), sink back into it when it shuts, and change tab by gliding each card
--  into the next tab's card in the same corner (0.5 s quint out). Monochrome
--  controls: Novoline's glass switch (a white pill knob on a clear track that
--  fills when on), glass sliders, soft tile buttons, lists that open in place.
--  An island at the top shows what is playing and every message.
--  The same tabs and settings as the other looks (every control is bound to the
--  same flag); a tab that draws itself takes this look from Window.kit.
-- ============================================================================
local S, util, Motion, UI, Config, Window, Controls = B.S, B.util, B.Motion, B.UI, B.Config, B.Window, B.Controls
-- (the fonts the look falls back to when the asset pack is missing)
if not (B.F0 or B.F) then B.F = { text500 = { Family = Enum.Font.Gotham } } end
local UIS = S.UserInputService
local TS = S.TweenService
local N = { open = false, built = false, pages = {}, tabs = {}, current = nil }
B.Novoline = N

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local P = {
  top = rgb(8, 8, 9), bottom = rgb(26, 26, 28),
  card = rgb(28, 28, 32), raised = rgb(38, 38, 43), hover = rgb(48, 48, 54), line = rgb(55, 55, 61), divider = rgb(42, 42, 48),
  text = rgb(244, 244, 246), sub = rgb(205, 205, 210), dim = rgb(158, 158, 164), faint = rgb(108, 108, 115),
  on = rgb(242, 242, 244), off = rgb(58, 58, 62), knobOn = rgb(18, 18, 20), knobOff = rgb(255, 255, 255),
  rail = rgb(52, 52, 58), fill = rgb(224, 224, 226), danger = rgb(239, 68, 68), good = rgb(82, 214, 160),
  white = Color3.new(1, 1, 1), black = Color3.new(0, 0, 0),
  -- Novoline's own names for what its cards use
  subtle = rgb(150, 150, 156), ink = rgb(18, 18, 20), placeholder = rgb(118, 118, 124),
}
N.P = P
-- the tinted tiles (Novoline's quick settings and quick actions): the plate when on, and its icon
local TINT = {
  { rgb(13, 40, 51), rgb(64, 186, 255) },    -- blue
  { rgb(38, 28, 62), rgb(168, 120, 255) },   -- purple
  { rgb(14, 46, 40), rgb(56, 224, 186) },    -- teal
  { rgb(52, 30, 12), rgb(255, 156, 64) },    -- amber (quick commands)
  { rgb(52, 18, 22), rgb(255, 96, 102) },    -- red
}
local ROW_H, COMPACT_H = 56, 40       -- a setting with its line under it, and one without
local GLIDE = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FILL_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local ACCENT = rgb(230, 30, 30)
local function accent() return Config.get("app.novoline.accent") or ACCENT end
local W, H = 600, 480                 -- the panel, design pixels (Settings can drag it bigger)
local DOCK_H = 52
local OPEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local CLOSE_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local FADE_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HOVER_INFO = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SWITCH_INFO = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
-- Novoline's own sounds, as its source plays them: the menu opening (at 0.9 speed) and closing
-- (the same sound at 0.7), a change of tab on the dock, and a notification. It has none for a
-- click or a switch (its one click sound is fetched from a file host at run time: not used here),
-- so those keep the hub's own.
local NV_SOUND = {
  open = { "rbxassetid://255881176", 0.8, 0.9 },
  close = { "rbxassetid://255881176", 0.8, 0.7 },
  tab = { "rbxassetid://1180994874", 0.8, 1 },
  notify = { "rbxassetid://255881176", 0.6, 1 },
}
local function nvSound(name)
  local own = NV_SOUND[name]
  if own and UI.sfxId then UI.sfxId(own[1], own[2], own[3]) end
end
local function tween(instance, info, props)
  if Motion.reduced then
    for key, value in pairs(props) do instance[key] = value end
    return nil
  end
  local t = TS:Create(instance, info, props)
  t:Play()
  return t
end

-- ---------------------------------------------------------------- the letters
-- Gotham, as Novoline has it; Settings > Novoline font picks another.
local FONTS = {
  { "gotham", "Gotham", "rbxasset://fonts/families/GothamSSm.json", 1 },
  { "builder", "Builder Sans", "rbxasset://fonts/families/BuilderSans.json", 1.04 },
  { "montserrat", "Montserrat", "rbxasset://fonts/families/Montserrat.json", 0.98 },
  { "inter", "Inter", nil, 1 },
  { "ubuntu", "Ubuntu", "rbxasset://fonts/families/Ubuntu.json", 1.04 },
  { "nunito", "Nunito", "rbxasset://fonts/families/Nunito.json", 1.04 },
}
N.FONTS = FONTS
local family, factor = FONTS[1][3], 1
local function pickFont()
  local id = Config.get("app.novoline.font")
  local spec = FONTS[1]
  for _, entry in ipairs(FONTS) do if entry[1] == id then spec = entry end end
  family = spec[3] or ((B.F0 or B.F).text500 and (B.F0 or B.F).text500.Family) or FONTS[1][3]
  factor = spec[4]
end
local WEIGHTS = { regular = Enum.FontWeight.Regular, medium = Enum.FontWeight.Medium, bold = Enum.FontWeight.Bold, black = Enum.FontWeight.Heavy }
local faces = {}
local function face(weight)
  local key = family .. (weight or "medium")
  if not faces[key] then
    local ok, made = pcall(Font.new, family, WEIGHTS[weight or "medium"] or Enum.FontWeight.Medium)
    faces[key] = ok and made or Font.fromEnum(Enum.Font.GothamMedium)
  end
  return faces[key]
end
-- every text drawn here, kept STRONG and swept (weak tables lose labels that are still on screen)
local typed = {}
local function letters(item, size, weight)
  typed[item] = { size, weight or "medium" }
  item.FontFace = face(weight)
  item.TextSize = math.floor(size * factor + 0.5)
  return item
end
local function refont()
  pickFont()
  for item, spec in pairs(typed) do
    if item.Parent then
      item.FontFace = face(spec[2])
      item.TextSize = math.floor(spec[1] * factor + 0.5)
    else
      typed[item] = nil
    end
  end
end
function N.owns(item) return typed[item] ~= nil end
Motion.every(function() for item in pairs(typed) do if not item.Parent then typed[item] = nil end end end, 0.1, "novoline.sweep")

-- ---------------------------------------------------------------- the accent, kept on what wears it
local worn = {}
local function wear(instance, property)
  for _, entry in ipairs(worn) do if entry[1] == instance and entry[2] == property then instance[property] = accent(); return instance end end
  worn[#worn + 1] = { instance, property }
  instance[property] = accent()
  return instance
end
local function unwear(instance, property)
  for index = #worn, 1, -1 do
    local entry = worn[index]
    if entry[1] == instance and (property == nil or entry[2] == property) then table.remove(worn, index) end
  end
end
local function repaint()
  local color = accent()
  for index = #worn, 1, -1 do
    local entry = worn[index]
    if entry[1].Parent then entry[1][entry[2]] = color else table.remove(worn, index) end
  end
end

-- ---------------------------------------------------------------- pieces
local function box(parent, props)
  local frame = Instance.new("Frame")
  frame.BorderSizePixel = 0
  frame.BackgroundTransparency = 1
  if props then for key, value in pairs(props) do frame[key] = value end end
  frame.Parent = parent
  return frame
end
local function round(instance, radius)
  local corner = instance:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
  corner.CornerRadius = radius == true and UDim.new(1, 0) or UDim.new(0, radius or 12)
  corner.Parent = instance
  return corner
end
local function rim(instance, color, transparency)
  local line = Instance.new("UIStroke")
  line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  line.Color = color or P.white
  line.Transparency = transparency or 0.9
  line.Thickness = 1
  line.Parent = instance
  return line
end
local function text(parent, value, size, weight, props)
  local label = Instance.new("TextLabel")
  label.BackgroundTransparency, label.BorderSizePixel = 1, 0
  label.TextColor3 = P.text
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.TextTruncate = Enum.TextTruncate.AtEnd
  label.Text = value or ""
  letters(label, size or 13, weight)
  if props then for key, v in pairs(props) do label[key] = v end end
  label.Parent = parent
  return label
end
local function entryBox(parent, size)
  local entry = Instance.new("TextBox")
  entry.BackgroundTransparency, entry.BorderSizePixel = 1, 0
  entry.TextColor3, entry.PlaceholderColor3 = P.text, P.faint
  entry.TextXAlignment, entry.ClearTextOnFocus, entry.ClipsDescendants = Enum.TextXAlignment.Left, false, true
  letters(entry, size or 13, "medium")
  entry.Parent = parent
  return entry
end
local function hit(parent, props)
  local button = Instance.new("TextButton")
  button.Text, button.AutoButtonColor, button.BackgroundTransparency, button.BorderSizePixel = "", false, 1, 0
  button.Size = UDim2.fromScale(1, 1)
  button.ZIndex = 8
  if props then for key, value in pairs(props) do button[key] = value end end
  button.Parent = parent
  return button
end
local function glyph(parent, name, size, color, props)
  local image = Instance.new("ImageLabel")
  image.BackgroundTransparency, image.BorderSizePixel = 1, 0
  image.Size = UDim2.fromOffset(size, size)
  image.ScaleType = Enum.ScaleType.Fit
  image.ImageColor3 = color or P.dim
  UI.setIcon(image, name)
  if props then for key, value in pairs(props) do image[key] = value end end
  image.Parent = parent
  return image
end
local function list(parent, gap, horizontal, align)
  local layout = Instance.new("UIListLayout")
  layout.FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical
  layout.Padding = UDim.new(0, gap or 0)
  layout.SortOrder = Enum.SortOrder.LayoutOrder
  if align == "center" then
    if horizontal then layout.HorizontalAlignment = Enum.HorizontalAlignment.Center else layout.VerticalAlignment = Enum.VerticalAlignment.Center end
  end
  if horizontal then layout.VerticalAlignment = Enum.VerticalAlignment.Center end
  layout.Parent = parent
  return layout
end
local function pad(parent, top, right, bottom, left)
  local padding = Instance.new("UIPadding")
  padding.PaddingTop, padding.PaddingRight = UDim.new(0, top or 0), UDim.new(0, right or top or 0)
  padding.PaddingBottom, padding.PaddingLeft = UDim.new(0, bottom or top or 0), UDim.new(0, left or right or top or 0)
  padding.Parent = parent
  return padding
end
-- Novoline's glass: the near-black gradient, the rim lit at top and bottom, a shadow under it
local function glass(frame, radius, shadow)
  frame.BackgroundColor3 = P.white
  frame.BackgroundTransparency = 0
  round(frame, radius)
  local body = Instance.new("UIGradient")
  body.Name = "Body"
  body.Rotation = 90
  body.Color = ColorSequence.new(P.top, P.bottom)
  body.Parent = frame
  local line = rim(frame, P.white, 0)
  pcall(function() line.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
  local light = Instance.new("UIGradient")
  light.Rotation = 90
  light.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.84), NumberSequenceKeypoint.new(0.5, 0.92), NumberSequenceKeypoint.new(1, 0.78) })
  light.Parent = line
  if shadow ~= false then
    pcall(function()
      local glow = Instance.new("UIShadow")
      glow.Color = P.black
      glow.BlurRadius = UDim.new(0, 26)
      glow.Offset = UDim2.fromOffset(0, 10)
      glow.Transparency = 0.45
      glow.ZIndex = -1
      glow.Parent = frame
    end)
  end
  return line
end
N.glass = glass
-- Novoline's soft button: a dark gradient (46,46,49 to 32,32,35), a rim lit at the top, a lift under the mouse
function N.softFace(holder, radius, hover)
  local face0 = box(holder, { Name = "Face", Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = holder.ZIndex + 1 })
  round(face0, radius or 16)
  local body = Instance.new("UIGradient"); body.Rotation = 90; body.Color = ColorSequence.new(rgb(46, 46, 49), rgb(32, 32, 35)); body.Parent = face0
  local line = rim(face0, P.white, 0)
  pcall(function() line.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
  local light = Instance.new("UIGradient"); light.Rotation = 90
  light.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.4, 0.96), NumberSequenceKeypoint.new(1, 0.97) })
  light.Parent = line
  local lift = box(face0, { Name = "Lift", Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = face0.ZIndex + 1 })
  round(lift, radius or 16)
  if hover then
    face0.MouseEnter:Connect(function() tween(lift, HOVER_INFO, { BackgroundTransparency = 0.95 }) end)
    face0.MouseLeave:Connect(function() tween(lift, HOVER_INFO, { BackgroundTransparency = 1 }) end)
  end
  return face0, lift
end
-- Novoline's tile: the soft button's plate without the lift (a key, an "Open", a value), its rim faint
local function tile(parent, props, radius)
  local plate = box(parent, props)
  plate.BackgroundColor3, plate.BackgroundTransparency = P.white, 0
  round(plate, radius or 14)
  local body = Instance.new("UIGradient"); body.Name = "Body"; body.Rotation = 90; body.Color = ColorSequence.new(rgb(46, 46, 49), rgb(32, 32, 35)); body.Parent = plate
  rim(plate, P.white, 0.9)
  return plate, body
end
N.tile = tile
local function lower(value) return string.lower(tostring(value or "")) end
-- a name that would be cut short on a tile shrinks to fit instead (down to `least`), measured in
-- design px (TextScaled would measure it after the look's own scale, and come out small)
local function shrink(label, most, least, width)
  local function fit()
    local room = width or ((label.Size.X.Scale == 0) and label.Size.X.Offset) or 0
    if room <= 0 then return end
    local weight = label.FontFace and label.FontFace.Weight
    local heavy = weight ~= nil and weight.Value >= Enum.FontWeight.Bold.Value
    local enum = heavy and Enum.Font.GothamBold or Enum.Font.GothamMedium
    local size = most
    while size > (least or 9) do
      local ok, bounds = pcall(S.TextService.GetTextSize, S.TextService, label.Text, size, enum, Vector2.new(4000, 200))
      -- (the look's letters set a little wider than the measure's: kept a tenth short)
      if not ok or bounds.X <= room * 0.9 then break end
      size -= 1
    end
    label.TextSize = size
    return size
  end
  local size = fit()
  label:GetPropertyChangedSignal("Text"):Connect(fit)
  return label, size
end
local function options(spec)
  local out = {}
  for _, option in ipairs(spec or {}) do
    if type(option) == "table" then out[#out + 1] = { value = option.value or option[1], label = option.label or option[2] or tostring(option.value or option[1]) }
    else out[#out + 1] = { value = option, label = tostring(option) } end
  end
  return out
end

-- ---------------------------------------------------------------- the kit (src/07): tabs that draw themselves, in this look
local KIT = { card = P.card, field = P.raised, hover = P.hover, line = P.line, back = rgb(18, 18, 20), text = P.text, dim = P.dim, faint = P.faint,
  onAccent = P.white, good = P.good, bad = P.danger }
local kit = { look = "novoline", radius = 16, small = 10, size = 13 }
function kit.owns(frame) return N.gui ~= nil and frame:IsDescendantOf(N.gui) end
function kit.color(role)
  if role == "accent" then return accent(), 0 end
  return KIT[role] or P.text, 0
end
function kit.paint(instance, property, role)
  unwear(instance, property)
  if role == "accent" then wear(instance, property) else instance[property] = KIT[role] or P.text end
end
function kit.fill(instance, role)
  kit.paint(instance, "BackgroundColor3", role)
  instance.BackgroundTransparency = 0
end
function kit.clear(instance) instance.BackgroundTransparency = 1 end
function kit.font(bold) return face(bold and "bold" or "medium") end
function kit.text(parent, value, props, bold, size) return text(parent, value, size or 13, bold and "bold" or "medium", props) end
function kit.entry(parent, size) return entryBox(parent, size or 13) end
function kit.outline(frame) return rim(frame, P.line, 0.2) end
function kit.corner(frame, radius) return round(frame, radius or 16) end
N.kit = kit
Window.kits.novoline = kit
function N.palette() return { card = P.card, elevated = P.raised, stroke = P.line, text = P.text, dim = P.dim, faint = P.faint, accent = accent(), font = face("medium"), bold = face("bold") } end

-- ---------------------------------------------------------------- floating bits: a tip, a menu (in the overlay layer, above the panel)
local overlay
local tip, tipFor
local function hideTip()
  tipFor = nil
  if tip then tip.Visible = false end
  if UI.hideTip then UI.hideTip() end
end
-- What a control does, on hover (2026-10-30, every look): the hub's one tip, its name over what it
-- does. A row with no words of its own still says its name when the row cuts it short.
local function tooltip(button, desc, holder, title)
  if desc and desc ~= "" and UI.tooltip then
    UI.tooltip(button, desc, title)
    return
  end
  if (not desc or desc == "") and not holder then return end
  button.MouseEnter:Connect(function()
    tipFor = button
    task.delay(0.5, function()
      if tipFor ~= button or not (N.open and button.Parent and overlay) then return end
      local say = desc
      if holder then
        local cutName, cutDesc
        for _, child in ipairs(holder:GetChildren()) do
          if child:IsA("TextLabel") and child.Text ~= "" and not child.TextFits then
            if desc and child.Text == desc then cutDesc = true else cutName = child.Text end
          end
        end
        if not (cutName or cutDesc) then return end
        say = cutName and ((desc and desc ~= "") and (cutName .. ": " .. desc) or cutName) or desc
      end
      if not say or say == "" then return end
      tip.Text = say
      local scale = N.sizer and N.sizer.Scale or 1
      local at = button.AbsolutePosition - overlay.AbsolutePosition
      tip.Position = UDim2.fromOffset(at.X + 6 * scale, at.Y + button.AbsoluteSize.Y + 4)
      tip.Visible = true
      task.defer(function()
        if tipFor ~= button or not tip.Visible then return end
        local view = overlay.AbsoluteSize
        local size = tip.AbsoluteSize
        local x, y = tip.Position.X.Offset, tip.Position.Y.Offset
        if x + size.X > view.X - 8 then x = view.X - 8 - size.X end
        if y + size.Y > view.Y - 8 then y = at.Y - size.Y - 4 end
        tip.Position = UDim2.fromOffset(math.max(x, 8), math.max(y, 8))
      end)
    end)
  end)
  button.MouseLeave:Connect(function() if tipFor == button then hideTip() end end)
end
local menu
local function closeMenu()
  if menu then
    local open = menu
    menu = nil
    open.frame:Destroy()
  end
end
-- items: { label, icon?, checked?, danger?, run } | "divider"; at = a screen point, or under `anchor`
local function openMenu(items, at, anchor)
  closeMenu()
  hideTip()
  if not overlay then return end
  local scale = N.sizer and N.sizer.Scale or 1
  local frame = box(overlay, { Name = "Menu", Size = UDim2.fromOffset(210, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 90 })
  glass(frame, 14)
  local sizer = Instance.new("UIScale"); sizer.Scale = scale; sizer.Parent = frame
  local body = box(frame, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 91 })
  pad(body, 6)
  list(body, 2)
  for index, item in ipairs(items) do
    if item == "divider" then
      box(body, { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = P.divider, BackgroundTransparency = 0, LayoutOrder = index, ZIndex = 92 })
    else
      local row = box(body, { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.white, BackgroundTransparency = 1, LayoutOrder = index, ZIndex = 92 })
      round(row, 9)
      local x = 10
      if item.icon then
        glyph(row, item.icon, 15, item.danger and P.danger or P.dim, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), ZIndex = 93 })
        x = 33
      end
      text(row, item.label, 13, "medium", { Position = UDim2.fromOffset(x, 0), Size = UDim2.new(1, -x - 28, 1, 0), TextColor3 = item.danger and P.danger or P.text, ZIndex = 93 })
      if item.checked then
        wear(glyph(row, "check", 14, nil, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 93 }), "ImageColor3")
      end
      local button = hit(row, { ZIndex = 94 })
      button.MouseEnter:Connect(function() tween(row, HOVER_INFO, { BackgroundTransparency = 0.93 }) end)
      button.MouseLeave:Connect(function() tween(row, HOVER_INFO, { BackgroundTransparency = 1 }) end)
      button.Activated:Connect(B.safe("novoline.menu", function()
        UI.sfx("click", 0.5)
        if not item.keepOpen then closeMenu() end
        if item.run then item.run() end
      end))
    end
  end
  -- (placed once its height is known: kept on screen)
  local function place()
    local view = overlay.AbsoluteSize
    local size = frame.AbsoluteSize
    local p
    if anchor then
      local a = anchor.AbsolutePosition - overlay.AbsolutePosition
      p = Vector2.new(a.X + anchor.AbsoluteSize.X - size.X, a.Y + anchor.AbsoluteSize.Y + 4)
      if p.Y + size.Y > view.Y - 8 then p = Vector2.new(p.X, a.Y - size.Y - 4) end
    else
      p = (at or UI.mouse()) - overlay.AbsolutePosition + Vector2.new(2, 2)
    end
    frame.Position = UDim2.fromOffset(math.clamp(p.X, 8, math.max(8, view.X - size.X - 8)), math.clamp(p.Y, 8, math.max(8, view.Y - size.Y - 8)))
  end
  place()
  task.defer(place)
  menu = { frame = frame, anchor = anchor }
  UI.sfx("open", 0.4)
  return frame
end
function kit.menu(anchor, items) return openMenu(items, nil, anchor) end
N.menu = openMenu

-- ---------------------------------------------------------------- an open list, a colour: they open in place, under their row
local unfolded                           -- { frame, anchor, scroller, close }
local function fold()
  if unfolded then
    local open = unfolded
    unfolded = nil
    if open.scroller and open.scroller.Parent then open.scroller.ScrollingEnabled = true end
    if open.close then B.try("novoline.fold", open.close) end
    open.frame:Destroy()
  end
end
N.fold = fold
local function pageScroller(frame)
  for _, entry in pairs(N.pages) do
    if entry.scroller and frame:IsDescendantOf(entry.scroller) then return entry.scroller end
  end
  return nil
end
-- the frame given takes the place under `row`; the page holds still while it is open
local function unfold(row, frame, closed)
  fold()
  local scroller = pageScroller(row)
  if scroller then scroller.ScrollingEnabled = false end
  unfolded = { frame = frame, anchor = row, scroller = scroller, close = closed }
end

-- ---------------------------------------------------------------- keys on a control (right click)
local function keyMenu(id, label, kind)
  if not id then return end
  local bind = Config.bindOf(id)
  local items = {
    { label = bind and bind.key and ("Change key (" .. Config.keyLabel(bind.key) .. ")") or "Bind a key", icon = "keyboard", run = function()
      Window.toast({ title = "Press a key", text = "Esc: cancel. Backspace: clear.", icon = "keyboard", time = 2.2 })
      Controls.captureKey(function(key, cancelled)
        if cancelled then return end
        Config.bind(id, key)
        Window.toast({ title = key and ("Bound to " .. Config.keyLabel(key)) or "Key cleared", text = label, icon = "keyboard", time = 2 })
      end)
    end },
  }
  if bind and bind.key then
    if kind == "toggle" then
      items[#items + 1] = { label = "Hold to use", icon = "hand", checked = bind.mode == "hold", run = function()
        Config.bind(id, bind.key, bind.mode == "hold" and "toggle" or "hold")
      end }
    end
    items[#items + 1] = { label = "Clear the key", icon = "x", run = function() Config.bind(id, nil) end }
  end
  if Config.get(id) ~= nil and kind ~= "button" then
    items[#items + 1] = "divider"
    items[#items + 1] = { label = "Back to default", icon = "rotate-ccw", run = function() Config.reset(id) end }
  end
  openMenu(items)
end
-- the small pill that shows a control's key
local function keyChip(parent, id)
  local chip = box(parent, { Name = "Key", AnchorPoint = Vector2.new(1, 0.5), Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = P.raised,
    BackgroundTransparency = 0, Visible = false, ZIndex = 6 })
  round(chip, true)
  pad(chip, 0, 8, 0, 8)
  local label = text(chip, "", 10, "bold", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.sub, ZIndex = 7 })
  local function refresh()
    local bind = id and Config.bindOf(id)
    chip.Visible = bind ~= nil and bind.key ~= nil
    if chip.Visible then label.Text = Config.keyLabel(bind.key) .. (bind.mode == "hold" and " · hold" or "") end
  end
  if id then Config.bindsChanged:connect(function(changed) if changed == id and chip.Parent then refresh() end end) end
  refresh()
  return chip, refresh
end

-- ---------------------------------------------------------------- a card and its controls
local Section = {}
Section.__index = Section
local function nextOrder(section)
  section.count += 2
  return section.count
end
-- a row of a group: Novoline's (14 in from the left, 12 from the right, a hairline over every row
-- but the first, the whole row lit faintly under the mouse)
local function row(section, height)
  local order = nextOrder(section)
  local line = box(section.body, { Name = "Row", Size = UDim2.new(1, 0, 0, height), LayoutOrder = order, BackgroundColor3 = P.white, BackgroundTransparency = 1 })
  round(line, 12)
  pad(line, 0, 12, 0, 14)
  section.made = (section.made or 0) + 1
  if section.made > 1 then
    box(line, { Name = "Line", Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -2, 0, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0.93, ZIndex = 2 })
  end
  return line
end
local function sub(section, holder)
  return setmetatable({ body = holder, count = 0, made = 0, page = section.page, card = section.card, wide = section.wide, icon = section.icon }, Section)
end
local function findable(section, frame, label, desc)
  local page = section.page
  if not (page and page.rows) then return end
  page.rows[#page.rows + 1] = { frame = frame, card = section.card, text = lower(tostring(label or "") .. " " .. tostring(desc or "")) }
end
-- a name and its one line under it (Novoline's: bold 13 at 11, the line 11 at 30); `right` is how much
-- of the row the control takes. A row with no line under it is 40 tall and its name is centred.
-- A row's line that is too long for it ends at its first full stop, whole ("Hops round your
-- target."), not cut in the next sentence ("Hops round your target...."): the tip on hover has all
-- of it (2026-10-30). Measured in the row's own width, whatever the look's scale is just then.
local function firstSentence(under, desc)
  local first = string.match(desc, "^(.-[%.!?])%s+%S")
  if not first then return end
  local lastRoom
  local function fit()
    if not under.Parent then return end
    local scale, node = 1, under
    while node do
      local sizer = node:FindFirstChildOfClass("UIScale")
      if sizer then scale *= sizer.Scale end
      node = node.Parent
    end
    if scale <= 0.01 then return end
    local room = math.floor(under.AbsoluteSize.X / scale + 0.5)
    if room <= 0 or room == lastRoom then return end
    lastRoom = room
    local ok, whole = pcall(S.TextService.GetTextSize, S.TextService, desc, 11, Enum.Font.GothamMedium, Vector2.new(4000, 100))
    -- (the look's letters set a little wider than the measure's: kept a tenth short, as in shrink)
    under.Text = (ok and whole.X > room * 0.9) and first or desc
  end
  under:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
  task.defer(fit)
end
local function labels(line, label, desc, right)
  local h = line.Size.Y.Offset
  local name = text(line, label or "", 13, "bold", { Position = UDim2.fromOffset(0, desc and 11 or 0), Size = UDim2.new(1, -(right or 60), 0, desc and 16 or h),
    TextColor3 = P.text, ZIndex = 3 })
  local under
  if desc and desc ~= "" then
    under = text(line, desc, 11, "medium", { Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, -(right or 60), 0, 14), TextColor3 = P.subtle, ZIndex = 3 })
    firstSentence(under, desc)
  end
  return name, under
end
-- the row lights up a little under the mouse (Novoline's: the row itself, to 0.96)
local function washed(line)
  return function(on) tween(line, HOVER_INFO, { BackgroundTransparency = on and 0.96 or 1 }) end
end

-- Novoline's glass switch: a clear track (white at 0.86) that fills white (0.25) when on, and a
-- white pill knob with a soft shadow that glides across (0.3 s quart out)
local function switch(parent)
  local track = box(parent, { Name = "Switch", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(52, 26),
    BackgroundColor3 = P.white, BackgroundTransparency = 0.86, ZIndex = 4 })
  round(track, true)
  local fill = box(track, { Name = "Fill", Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 4 })
  round(fill, true)
  local knob = box(track, { Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 18, 0.5, 0), Size = UDim2.fromOffset(32, 22), BackgroundColor3 = P.white,
    BackgroundTransparency = 0, ZIndex = 5 })
  round(knob, true)
  pcall(function()
    local shade = Instance.new("UIShadow")
    shade.Color, shade.BlurRadius, shade.Offset, shade.Transparency = P.black, UDim.new(0, 6), UDim2.fromOffset(0, 1), 0.62
    shade.Parent = knob
  end)
  local function set(on, animate)
    local spot = UDim2.new(0, on and 34 or 18, 0.5, 0)
    if animate then
      tween(knob, GLIDE, { Position = spot })
      tween(fill, FILL_INFO, { BackgroundTransparency = on and 0.25 or 1 })
    else
      knob.Position = spot
      fill.BackgroundTransparency = on and 0.25 or 1
    end
  end
  return track, set
end

function Section:toggle(spec)
  local id = spec.id
  local bindable = spec.bindable ~= false
  local value = id and Config.define(id, spec.default == true) or (spec.default == true)
  local desc = spec.desc
  local line = row(self, desc and ROW_H or COMPACT_H)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 120)
  local track, set = switch(line)
  local chip = keyChip(line, id)
  chip.Position = UDim2.new(1, -60, 0.5, 0)
  local children
  if spec.children then
    local order = nextOrder(self)
    children = box(self.body, { Name = "Sub", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order, Visible = value })
    local edge = box(children, { Size = UDim2.new(0, 2, 1, -8), Position = UDim2.fromOffset(16, 4), BackgroundColor3 = P.white, BackgroundTransparency = 0.88 })
    round(edge, true)
    local inner = box(children, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y })
    pad(inner, 0, 0, 4, 16)
    list(inner, 0)
    B.try("novoline.children", spec.children, sub(self, inner))
  end
  local function paint(animate)
    set(value, animate)
    if children then children.Visible = value end
  end
  paint(false)
  if id then
    Config.on(id, function(next)
      value = next == true
      if line.Parent then paint(true) end
      if spec.changed then spec.changed(value) end
    end)
    if bindable then Controls.bindables[id] = Controls.bindables[id] or { label = spec.label or id, kind = "toggle", page = self.page.source } end
    -- (a tab's first switches are its quick settings)
    if self.top and self.page.toggles then self.page.toggles[#self.page.toggles + 1] = { id = id, label = spec.label or id, icon = self.icon } end
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  button.Activated:Connect(B.safe("novoline.toggle", function()
    UI.sfx(value and "toggle_off" or "toggle_on", 0.5)
    if id then Config.set(id, not value) else
      value = not value
      paint(true)
      if spec.changed then B.try("toggle", spec.changed, value) end
    end
  end))
  button.MouseButton2Click:Connect(function() if bindable and id then keyMenu(id, spec.label, "toggle") end end)
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = function(next) if id then Config.set(id, next == true) end end,
    open = function() end, track = track }
end

function Section:slider(spec)
  local id = spec.id
  local min, max, step = spec.min or 0, spec.max or 100, spec.step or 1
  local decimals = spec.decimals or (step < 1 and math.max(0, math.ceil(-math.log10(step))) or 0)
  local curve = spec.curve or 1
  local value = id and Config.define(id, spec.default or min) or (spec.default or min)
  local desc = spec.desc
  -- Novoline's glass slider: the name and the amount on one line, a clear track (white at 0.88, 10
  -- tall) under them that fills toward its white pill thumb (30 x 18, a soft shadow; held, it grows
  -- to 36 x 20 and clears to glass)
  local line = row(self, desc and 76 or 60)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 90)
  label.Size = UDim2.new(1, -90, 0, 16)
  label.Position = UDim2.fromOffset(0, 11)
  local amount = text(line, "", 12, "bold", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 11), Size = UDim2.fromOffset(86, 16),
    TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = P.text, ZIndex = 3 })
  local rail = box(line, { Name = "Track", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -12), Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = P.white,
    BackgroundTransparency = 0.88, ZIndex = 3 })
  round(rail, true)
  local fill = box(rail, { Name = "Fill", Size = UDim2.fromScale(0, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 4 })
  round(fill, true)
  local sheen = Instance.new("UIGradient")
  sheen.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 0) })
  sheen.Parent = fill
  local knob = box(rail, { Name = "Thumb", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(30, 18), BackgroundColor3 = P.white,
    BackgroundTransparency = 0, ZIndex = 5 })
  round(knob, true)
  local knobRim = rim(knob, P.white, 1)
  pcall(function()
    local shade = Instance.new("UIShadow")
    shade.Color, shade.BlurRadius, shade.Offset, shade.Transparency = P.black, UDim.new(0, 8), UDim2.fromOffset(0, 2), 0.62
    shade.Parent = knob
  end)
  local HOLD = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
  local function held(on)
    tween(knob, HOLD, { Size = on and UDim2.fromOffset(36, 20) or UDim2.fromOffset(30, 18), BackgroundTransparency = on and 0.72 or 0 })
    tween(knobRim, HOLD, { Transparency = on and 0.3 or 1 })
  end
  local function shown(v) return (spec.format and spec.format(v)) or (util.format(v, decimals) .. (spec.suffix or "")) end
  -- (the thumb stays inside the track: its centre runs from 15 px in to 15 px short of the end)
  local function place(animate)
    local f = util.clamp01((value - min) / math.max(max - min, 1e-9)) ^ (1 / curve)
    local at = UDim2.new(f, 15 - f * 30, 0.5, 0)
    local filled = UDim2.new(f, 15 - f * 30, 1, 0)
    if animate then
      tween(fill, HOVER_INFO, { Size = filled })
      tween(knob, HOVER_INFO, { Position = at })
    else
      fill.Size = filled
      knob.Position = at
    end
    amount.Text = shown(value)
  end
  place(false)
  local dragging = false
  local function set(next)
    next = math.clamp(util.round(next, step), min, max)
    if decimals > 0 then next = tonumber(string.format("%." .. decimals .. "f", next)) or next end
    if next == value then return end
    if id then Config.set(id, next) else
      value = next
      place(not dragging)
      if spec.changed then B.try("slider", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if line.Parent then place(not dragging) end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  local function at(point)
    local width = math.max(rail.AbsoluteSize.X - 30 * (N.sizer and N.sizer.Scale or 1), 1)
    set(min + util.clamp01((point.X - rail.AbsolutePosition.X - 15 * (N.sizer and N.sizer.Scale or 1)) / width) ^ curve * (max - min))
  end
  UI.drag(button, function(point) dragging = true; held(true); at(point) end, function(point) at(point) end, function() dragging = false; held(false) end)
  -- (right click: type a number)
  button.MouseButton2Click:Connect(function()
    local field = box(line, { Size = UDim2.new(0, 120, 0, 26), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 6), BackgroundColor3 = P.white,
      BackgroundTransparency = 0.94, ZIndex = 12 })
    round(field, 10)
    rim(field, P.white, 0.7)
    local entry = entryBox(field, 12)
    entry.Size, entry.Position, entry.ZIndex = UDim2.new(1, -16, 1, 0), UDim2.fromOffset(8, 0), 13
    entry.TextXAlignment = Enum.TextXAlignment.Center
    entry.Text, entry.ClearTextOnFocus, entry.PlaceholderText = "", true, "type a number"
    entry.FocusLost:Connect(B.safe("novoline.slider.type", function()
      local typed = tonumber((string.gsub(entry.Text, "[^%d%.%-eE]", "")))
      field:Destroy()
      if typed then set(typed) end
    end))
    entry:CaptureFocus()
  end)
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set }
end

-- a list that opens in place under its row: one value (dropdown) or several (multi)
local function chooser(section, spec, many)
  local id = spec.id
  local choices = options(spec.options)
  local first = choices[1] and choices[1].value
  local value
  if many then value = id and Config.define(id, spec.default or {}) or (spec.default or {})
  else value = id and Config.define(id, spec.default ~= nil and spec.default or first) or (spec.default ~= nil and spec.default or first) end
  local desc = spec.desc
  local line = row(section, desc and ROW_H or COMPACT_H)
  findable(section, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 140)
  -- (the value on Novoline's tile, its arrow beside it)
  local field = tile(line, { Name = "Value", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(128, 28), ZIndex = 4 }, 14)
  local fieldRim = field:FindFirstChildOfClass("UIStroke")
  local shown = text(field, "", 12, "bold", { Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -34, 1, -12), TextColor3 = P.text, ZIndex = 5 })
  shrink(shown, 12, 9, 94)
  local arrow = glyph(field, "chevron-down", 14, P.subtle, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 5 })
  local function has(v) return table.find(value, v) ~= nil end
  local function summary()
    if not many then
      for _, option in ipairs(choices) do if option.value == value then return option.label end end
      return tostring(value)
    end
    if #value == 0 then return spec.empty or "None" end
    local names = {}
    for _, option in ipairs(choices) do if has(option.value) then names[#names + 1] = option.label end end
    return table.concat(names, ", ")
  end
  shown.Text = summary()
  local function set(next)
    if id then Config.set(id, next) else
      value = next
      shown.Text = summary()
      if spec.changed then B.try("chooser", spec.changed, value) end
    end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if shown.Parent then shown.Text = summary() end
      if spec.changed then spec.changed(next) end
    end)
  end
  local open = false
  local function openList()
    local rows = math.min(#choices, 7)
    local order = line.LayoutOrder + 1
    local holder = box(section.body, { Name = "List", Size = UDim2.new(1, 0, 0, 0), LayoutOrder = order, ClipsDescendants = true, ZIndex = 6 })
    local panel = box(holder, { Size = UDim2.new(1, -24, 0, rows * 30 + 8), Position = UDim2.fromOffset(12, 0), BackgroundColor3 = rgb(30, 30, 34), BackgroundTransparency = 0, ZIndex = 6 })
    round(panel, 12)
    rim(panel, P.white, 0.92)
    local scroller = Instance.new("ScrollingFrame")
    scroller.BackgroundTransparency, scroller.BorderSizePixel = 1, 0
    scroller.Position, scroller.Size = UDim2.fromOffset(4, 4), UDim2.new(1, -8, 1, -8)
    scroller.CanvasSize = UDim2.fromOffset(0, #choices * 30)
    scroller.ScrollBarThickness = #choices > rows and 3 or 0
    scroller.ScrollBarImageColor3 = P.line
    scroller.ScrollingDirection = Enum.ScrollingDirection.Y
    scroller.ZIndex = 7
    scroller.Parent = panel
    for index, option in ipairs(choices) do
      local item = box(scroller, { Position = UDim2.fromOffset(0, (index - 1) * 30), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 8 })
      round(item, 9)
      local picked = many and has(option.value) or option.value == value
      local name = text(item, option.label, 12, picked and "bold" or "medium", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -40, 1, 0),
        TextColor3 = picked and P.text or P.sub, ZIndex = 9 })
      local check = glyph(item, "check", 14, nil, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), ZIndex = 9, Visible = picked })
      wear(check, "ImageColor3")
      local button = hit(item, { ZIndex = 10 })
      button.MouseEnter:Connect(function() tween(item, HOVER_INFO, { BackgroundTransparency = 0.94 }) end)
      button.MouseLeave:Connect(function() tween(item, HOVER_INFO, { BackgroundTransparency = 1 }) end)
      button.Activated:Connect(B.safe("novoline.choose", function()
        UI.sfx("click", 0.4)
        if not many then
          set(option.value)
          fold()
          return
        end
        local next = table.clone(value)
        local at = table.find(next, option.value)
        if at then table.remove(next, at) else next[#next + 1] = option.value end
        local ordered = {}
        for _, o in ipairs(choices) do if table.find(next, o.value) then ordered[#ordered + 1] = o.value end end
        set(ordered)
        local on = at == nil
        check.Visible = on
        name.TextColor3 = on and P.text or P.sub
        name.FontFace = face(on and "bold" or "medium")
      end))
    end
    -- (it opens to its height: the card grows under it)
    local tall = rows * 30 + 8 + 6
    tween(holder, OPEN_INFO, { Size = UDim2.new(1, 0, 0, tall) })
    tween(arrow, HOVER_INFO, { Rotation = 180 })
    open = true
    unfold(line, holder, function()
      open = false
      if arrow.Parent then tween(arrow, HOVER_INFO, { Rotation = 0 }) end
    end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true); if fieldRim then tween(fieldRim, HOVER_INFO, { Transparency = 0.78 }) end end)
  button.MouseLeave:Connect(function() hover(false); if fieldRim then tween(fieldRim, HOVER_INFO, { Transparency = 0.9 }) end end)
  button.Activated:Connect(B.safe("novoline.dropdown", function()
    UI.sfx("click", 0.4)
    if open then fold() else openList() end
  end))
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set, has = has,
    options = function(next) choices = options(next); shown.Text = summary() end,
    show = function(next) value = next; if shown.Parent then shown.Text = summary() end end }
end
function Section:dropdown(spec) return chooser(self, spec, false) end
function Section:multi(spec) return chooser(self, spec, true) end
-- a few short choices: a pill bar with the chosen one lit (more, or long ones: a list)
-- a few short choices: Novoline's chips (soft tiles, the chosen one white with dark letters), at the
-- right of the row when they fit beside its name, else on a line of their own under it; more than
-- fit on a line: a list
function Section:segmented(spec)
  local choices = options(spec.options)
  if #choices > 5 then return chooser(self, spec, false) end
  local width = self.wide and 514 or 290
  local widths, total = {}, 0
  for i, option in ipairs(choices) do
    local ok, size = pcall(S.TextService.GetTextSize, S.TextService, option.label, 12, Enum.Font.GothamBold, Vector2.new(300, 28))
    widths[i] = (ok and size.X or #option.label * 7) + 28
    total += widths[i] + (i > 1 and 6 or 0)
  end
  if total > width then return chooser(self, spec, false) end
  local id = spec.id
  local value = id and Config.define(id, spec.default ~= nil and spec.default or choices[1].value) or (spec.default ~= nil and spec.default or choices[1].value)
  local desc = spec.desc
  local inline = total <= width - 100
  local line = row(self, inline and (desc and ROW_H or COMPACT_H) or ((desc and ROW_H or 40) + 36))
  tooltip(line, spec.tip or desc, nil, spec.label)
  findable(self, line, spec.label, desc)
  local label = labels(line, spec.label, desc, inline and (total + 10) or 0)
  if not inline and not desc then label.Size = UDim2.new(1, 0, 0, 40) end
  local holder = box(line, { Name = "Chips", AnchorPoint = inline and Vector2.new(1, 0.5) or Vector2.new(0, 1), Position = inline and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0, 0, 1, -8),
    Size = UDim2.fromOffset(total, 28), ZIndex = 4 })
  local chips = {}
  local x = 0
  local function paint()
    for i, option in ipairs(choices) do
      local on = option.value == value
      local c = chips[i]
      c.body.Enabled = not on
      c.plate.BackgroundColor3 = on and P.on or P.white
      c.name.TextColor3 = on and P.ink or P.text
    end
  end
  for i, option in ipairs(choices) do
    local plate, body = tile(holder, { Position = UDim2.fromOffset(x, 0), Size = UDim2.fromOffset(widths[i], 28), ZIndex = 5 }, 14)
    local name = text(plate, option.label, 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6 })
    chips[i] = { plate = plate, body = body, name = name }
    local press = Instance.new("UIScale"); press.Parent = plate
    local button = hit(plate, { ZIndex = 7 })
    button.MouseButton1Down:Connect(function() tween(press, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.94 }) end)
    button.MouseButton1Up:Connect(function() tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }) end)
    button.MouseLeave:Connect(function() tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }) end)
    button.Activated:Connect(B.safe("novoline.segment", function()
      UI.sfx("tab", 0.4)
      if id then Config.set(id, option.value) else
        value = option.value
        paint()
        if spec.changed then B.try("segmented", spec.changed, value) end
      end
    end))
    x += widths[i] + 6
  end
  paint()
  if id then
    Config.on(id, function(next)
      value = next
      if holder.Parent then paint() end
      if spec.changed then spec.changed(next) end
    end)
  end
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = function(next) if id then Config.set(id, next) end end,
    options = function() end, show = function(next) value = next; if holder.Parent then paint() end end }
end

-- a colour: a dot; the square and the hue strip open in place
function Section:color(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or Color3.new(1, 1, 1)) or (spec.default or Color3.new(1, 1, 1))
  local desc = spec.desc
  local line = row(self, desc and ROW_H or COMPACT_H)
  tooltip(line, spec.tip or desc, nil, spec.label)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  local label = labels(line, spec.label, desc, 80)
  local swatch = box(line, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(44, 24), BackgroundColor3 = value,
    BackgroundTransparency = 0, ZIndex = 4 })
  round(swatch, true)
  rim(swatch, P.white, 0.75)
  local function set(next)
    if id then Config.set(id, next) else value = next; swatch.BackgroundColor3 = next; if spec.changed then spec.changed(next) end end
  end
  if id then
    Config.on(id, function(next)
      value = next
      if swatch.Parent then swatch.BackgroundColor3 = next end
      if spec.changed then spec.changed(next) end
    end)
  end
  local open = false
  local function openPicker()
    local h, s, v = value:ToHSV()
    local holder = box(self.body, { Name = "Colour", Size = UDim2.new(1, 0, 0, 0), LayoutOrder = line.LayoutOrder + 1, ClipsDescendants = true, ZIndex = 6 })
    local panel = box(holder, { Size = UDim2.new(1, 0, 0, 176), BackgroundColor3 = P.raised, BackgroundTransparency = 0, ZIndex = 6 })
    round(panel, 12)
    local square = box(panel, { Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 0, 118), BackgroundColor3 = Color3.fromHSV(h, 1, 1), BackgroundTransparency = 0, ZIndex = 7 })
    round(square, 8)
    local whiteLayer = box(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 8 })
    round(whiteLayer, 8)
    local across = Instance.new("UIGradient"); across.Transparency = NumberSequence.new(0, 1); across.Parent = whiteLayer
    local blackLayer = box(square, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.black, BackgroundTransparency = 0, ZIndex = 9 })
    round(blackLayer, 8)
    local down = Instance.new("UIGradient"); down.Rotation = 90; down.Transparency = NumberSequence.new(1, 0); down.Parent = blackLayer
    local dot = box(square, { Size = UDim2.fromOffset(12, 12), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 11 })
    round(dot, true)
    rim(dot, P.black, 0.4)
    local hueBar = box(panel, { Position = UDim2.fromOffset(10, 138), Size = UDim2.new(1, -96, 0, 12), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 7 })
    round(hueBar, true)
    local stops = {}
    for i = 0, 6 do stops[#stops + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6 % 1, 1, 1)) end
    local rainbow = Instance.new("UIGradient"); rainbow.Color = ColorSequence.new(stops); rainbow.Parent = hueBar
    local mark = box(hueBar, { Size = UDim2.fromOffset(6, 16), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 9 })
    round(mark, true)
    local hexField = box(panel, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 133), Size = UDim2.fromOffset(78, 22), BackgroundColor3 = P.hover,
      BackgroundTransparency = 0, ZIndex = 7 })
    round(hexField, true)
    local hex = entryBox(hexField, 11)
    hex.Size, hex.Position, hex.ZIndex = UDim2.new(1, -12, 1, 0), UDim2.fromOffset(6, 0), 8
    hex.TextXAlignment = Enum.TextXAlignment.Center
    local function show()
      square.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
      dot.Position = UDim2.fromScale(s, 1 - v)
      mark.Position = UDim2.fromScale(h, 0.5)
      if not hex:IsFocused() then hex.Text = "#" .. string.upper(Color3.fromHSV(h, s, v):ToHex()) end
    end
    show()
    local function emit() show(); set(Color3.fromHSV(h, s, v)) end
    local squareHit = hit(square, { ZIndex = 12 })
    local function pickSquare(point)
      s = util.clamp01((point.X - square.AbsolutePosition.X) / square.AbsoluteSize.X)
      v = 1 - util.clamp01((point.Y - square.AbsolutePosition.Y) / square.AbsoluteSize.Y)
      emit()
    end
    UI.drag(squareHit, pickSquare, pickSquare)
    local hueHit = hit(hueBar, { ZIndex = 12, Size = UDim2.new(1, 0, 1, 10), Position = UDim2.fromOffset(0, -5) })
    local function pickHue(point) h = util.clamp01((point.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X); emit() end
    UI.drag(hueHit, pickHue, pickHue)
    hex.FocusLost:Connect(function()
      local ok, color = pcall(Color3.fromHex, (string.gsub(hex.Text, "[^%x]", "")))
      if ok and color then h, s, v = color:ToHSV(); emit() else show() end
    end)
    tween(holder, OPEN_INFO, { Size = UDim2.new(1, 0, 0, 182) })
    open = true
    unfold(line, holder, function() open = false end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  button.Activated:Connect(B.safe("novoline.color", function()
    UI.sfx("click", 0.4)
    if open then fold() else openPicker() end
  end))
  return { row = { frame = line, label = label }, id = id, get = function() return value end, set = set }
end

function Section:keybind(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "None") or (spec.default or "None")
  local desc = spec.desc
  local line = row(self, desc and ROW_H or COMPACT_H)
  findable(self, line, spec.label, desc)
  local hover = washed(line)
  -- (Novoline's key: the name on a 92 x 28 tile; while it listens, the tile goes white with dark letters)
  local label = labels(line, spec.label, desc, 104)
  local chip, chipBody = tile(line, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(92, 28), ZIndex = 4 }, 14)
  local key = text(chip, "", 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = P.text, ZIndex = 5 })
  local function listening(on)
    chipBody.Enabled = not on
    chip.BackgroundColor3 = on and P.on or P.white
    key.TextColor3 = on and P.ink or P.text
  end
  local function show() key.Text = Config.keyLabel(value ~= "None" and value or nil) end
  show()
  if id then
    Config.on(id, function(next)
      value = next
      if key.Parent then show() end
      if spec.changed then spec.changed(next) end
    end)
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false) end)
  button.Activated:Connect(B.safe("novoline.key", function()
    key.Text = "Press a key"
    listening(true)
    Controls.captureKey(function(pressed, cancelled)
      listening(false)
      if not cancelled then
        local next = pressed or "None"
        if id then Config.set(id, next) else value = next; if spec.changed then spec.changed(next) end end
      end
      show()
    end)
  end))
  tooltip(button, spec.tip or desc, line, spec.label)
  return { row = { frame = line, label = label }, id = id, get = function() return value end }
end

-- a pill button the width of the card
local function pillButton(parent, value, style, props)
  local holder = box(parent, props)
  holder.ZIndex = 3
  local face0, lift
  if style == "accent" then
    face0 = box(holder, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent(), BackgroundTransparency = 0, ZIndex = 4 })
    round(face0, 16)
    wear(face0, "BackgroundColor3")
  else
    face0, lift = N.softFace(holder, 16)
  end
  local label = text(face0, value, 13, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 6,
    TextColor3 = style == "danger" and P.danger or P.text })
  local button = hit(face0, { ZIndex = 8 })
  button.MouseEnter:Connect(function()
    if lift then tween(lift, HOVER_INFO, { BackgroundTransparency = 0.95 }) else tween(face0, HOVER_INFO, { BackgroundTransparency = 0.15 }) end
  end)
  button.MouseLeave:Connect(function()
    if lift then tween(lift, HOVER_INFO, { BackgroundTransparency = 1 }) else tween(face0, HOVER_INFO, { BackgroundTransparency = 0 }) end
  end)
  button.MouseButton1Down:Connect(function() tween(face0, HOVER_INFO, { Size = UDim2.new(1, -6, 1, -4), Position = UDim2.fromOffset(3, 2) }) end)
  button.MouseButton1Up:Connect(function() tween(face0, SWITCH_INFO, { Size = UDim2.fromScale(1, 1), Position = UDim2.new() }) end)
  button.MouseLeave:Connect(function() tween(face0, SWITCH_INFO, { Size = UDim2.fromScale(1, 1), Position = UDim2.new() }) end)
  return holder, button, label, face0
end
N.pillButton = pillButton
-- an action: Novoline's (its name at the left, a 92 x 28 tile at the right saying what it does)
function Section:button(spec)
  local id = spec.id
  local desc = spec.desc
  local line = row(self, (desc and desc ~= "") and ROW_H or COMPACT_H)
  findable(self, line, spec.label or spec.text, desc)
  local hover = washed(line)
  local name = labels(line, spec.label or spec.text or "", (desc and desc ~= "") and desc or nil, 104)
  local accentStyle = spec.style == "accent"
  local plate, plateBody = tile(line, { Name = "Action", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(92, 28), ZIndex = 4 }, 14)
  if accentStyle then plateBody.Enabled = false; plate.BackgroundColor3 = P.on end
  local said = text(plate, spec.text or (spec.label and "Run") or "Run", 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 5,
    TextColor3 = accentStyle and P.ink or (spec.style == "danger" and P.danger or P.text) })
  local press = Instance.new("UIScale"); press.Parent = plate
  local chip = keyChip(line, id)
  chip.Position = UDim2.new(1, -100, 0.5, 0)
  if id then
    Config.action(id, function() if spec.run then spec.run() end end)
    if spec.bindable ~= false then Controls.bindables[id] = Controls.bindables[id] or { label = spec.label or id, kind = "button", page = self.page.source } end
  end
  local button = hit(line, { ZIndex = 8, Size = UDim2.new(1, 26, 1, 0), Position = UDim2.fromOffset(-14, 0) })
  button.MouseEnter:Connect(function() hover(true) end)
  button.MouseLeave:Connect(function() hover(false); tween(press, SWITCH_INFO, { Scale = 1 }) end)
  button.MouseButton1Down:Connect(function() tween(press, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.94 }) end)
  button.MouseButton1Up:Connect(function() tween(press, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }) end)
  button.Activated:Connect(B.safe("novoline.button", function()
    UI.sfx("click", 0.6)
    if spec.run then B.try("button." .. (spec.label or "?"), spec.run) end
  end))
  button.MouseButton2Click:Connect(function() if id and spec.bindable ~= false then keyMenu(id, spec.label, "button") end end)
  tooltip(button, spec.tip or desc, line, spec.label)
  -- (a new word: on the tile when the action has one of its own, else in place of its name)
  return { row = { frame = line, label = name }, button = plate, setText = function(value) if spec.text then said.Text = value else name.Text = value end end }
end

function Section:input(spec)
  local id = spec.id
  local value = id and Config.define(id, spec.default or "") or (spec.default or "")
  -- (Novoline's field: its name and line over a box of faint white, 30 tall, its rim brighter while typing)
  local desc = spec.desc
  local line = row(self, (desc and desc ~= "") and 92 or 72)
  tooltip(line, spec.tip or desc, nil, spec.label)
  findable(self, line, spec.label, desc)
  local label = labels(line, spec.label or "", (desc and desc ~= "") and desc or nil, 0)
  label.Position, label.Size = UDim2.fromOffset(0, 11), UDim2.new(1, 0, 0, 16)
  local field = box(line, { Position = UDim2.fromOffset(0, (desc and desc ~= "") and 50 or 34), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.white,
    BackgroundTransparency = 0.94, ZIndex = 4 })
  round(field, 10)
  local stroke = rim(field, P.white, 0.92)
  local entry = entryBox(field, 13)
  entry.Position, entry.Size, entry.ZIndex = UDim2.fromOffset(12, 0), UDim2.new(1, -24, 1, 0), 5
  entry.Text, entry.PlaceholderText = tostring(value), spec.placeholder or ""
  entry.Focused:Connect(function() tween(stroke, HOVER_INFO, { Transparency = 0.7 }) end)
  entry.FocusLost:Connect(B.safe("novoline.input", function()
    tween(stroke, HOVER_INFO, { Transparency = 0.92 })
    local typed = entry.Text
    if spec.numeric then
      local number = tonumber(typed)
      if not number then entry.Text = tostring(value); return end
      typed = number
    end
    if id then Config.set(id, typed) else
      value = typed
      if spec.changed then B.try("input", spec.changed, typed) end
    end
  end))
  if id then
    Config.on(id, function(next)
      value = next
      if entry.Parent and not entry:IsFocused() then entry.Text = tostring(next) end
      if spec.changed then spec.changed(next) end
    end)
  end
  return { row = { frame = line }, id = id, box = entry, get = function() return value end }
end

function Section:note(spec)
  local order = nextOrder(self)
  -- (Novoline's foot line: medium 11 in its quiet grey, inside the group)
  local holder = box(self.body, { Name = "Note", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order })
  pad(holder, 9, 14, 9, spec.icon and 36 or 14)
  if spec.icon then glyph(holder, spec.icon, 14, P.subtle, { Position = UDim2.fromOffset(-22, 0) }) end
  local label = text(holder, spec.text or "", 11, "medium", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true,
    TextTruncate = Enum.TextTruncate.None, TextColor3 = P.subtle, RichText = spec.rich == true })
  return { frame = holder, set = function(value) label.Text = value end }
end
-- A view a tab draws itself. One drawn wider than the card (the keyboard on Keys is 716 across) is
-- shrunk to fit: its pieces go into a frame of their own width, scaled down as one.
local function fitWide(frame, room)
  local widest = 0
  for _, child in ipairs(frame:GetChildren()) do
    if child:IsA("GuiObject") and child.Size.X.Scale == 0 then widest = math.max(widest, child.Size.X.Offset) end
  end
  if widest <= room then return end
  local k = room / widest
  local tall = frame.Size.Y.Offset
  local inner = box(frame, { Name = "Fit", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(widest, tall) })
  for _, child in ipairs(frame:GetChildren()) do
    if child ~= inner and child:IsA("GuiObject") then child.Parent = inner end
  end
  local scale = Instance.new("UIScale"); scale.Scale = k; scale.Parent = inner
  if tall > 0 then frame.Size = UDim2.new(1, 0, 0, math.ceil(tall * k)) end
end
function Section:custom(spec)
  local frame = box(self.body, { Name = spec.name or "Custom", Size = UDim2.new(1, 0, 0, spec.height or 100), LayoutOrder = nextOrder(self) })
  if spec.height == nil then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("novoline.custom", spec.build, frame)
  -- (in a deck whose Options card is the narrow one, the Music deck's, a view is fitted to that)
  local room = (self.page and self.page.narrow) and 300 or (self.wide and 540 or 316)
  if spec.height then B.try("novoline.fit", fitWide, frame, room) end
  return frame
end
-- for a tab's own version of itself (the Unnamed ones work here too): a line, two buttons, a box
function Section:label(value)
  local line = row(self, 22)
  local label = text(line, value or "", 12, "medium", { Size = UDim2.fromScale(1, 1), TextColor3 = P.sub })
  return { frame = line, set = function(next) label.Text = next end }
end
function Section:pair(a, b)
  local line = row(self, 38)
  local out = {}
  for index, item in ipairs({ a, b }) do
    if item then
      local holder, button, label = pillButton(line, item[1], nil, { Size = UDim2.new(b and 0.5 or 1, b and -4 or 0, 0, 30), Position = UDim2.new((index - 1) * 0.5, index == 2 and 4 or 0, 0, 4) })
      button.Activated:Connect(B.safe("novoline.pair", function() UI.sfx("click", 0.5); if item[2] then item[2]() end end))
      out[index] = { field = holder, label = label }
    end
  end
  return out
end
function Section:field(placeholder, changed)
  local line = row(self, 38)
  local field = box(line, { Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = P.raised, BackgroundTransparency = 0, ZIndex = 4 })
  round(field, 10)
  glyph(field, "search", 14, P.faint, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0), ZIndex = 5 })
  local entry = entryBox(field, 13)
  entry.Position, entry.Size, entry.ZIndex = UDim2.fromOffset(30, 0), UDim2.new(1, -40, 1, 0), 5
  entry.Text, entry.PlaceholderText = "", placeholder or ""
  if changed then entry:GetPropertyChangedSignal("Text"):Connect(function() changed(entry.Text) end) end
  return entry
end
N.Section = Section

-- ---------------------------------------------------------------- a tab: its sections, as Novoline's groups
-- A section is one of Novoline's settings groups: a plate of faint white (0.955, 14 round) with
-- hairlines between its rows. The tab's deck shows one section at a time in its Options card (the
-- Sections card beside it picks which); a search shows every section with something that matches,
-- each under its name.
local TextService = S.TextService
local Page = {}
Page.__index = Page
local function card(page, spec)
  page.sections += 1
  local frame = box(page.content, { Name = spec.title or "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = page.sections,
    Visible = false, ZIndex = 21 })
  list(frame, 0)
  local head = box(frame, { Name = "Group", Size = UDim2.new(1, 0, 0, 24), LayoutOrder = 0, Visible = false, ZIndex = 21 })
  text(head, spec.title or page.source.title or "", 12, "bold", { Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -12, 0, 16), TextColor3 = P.subtle, ZIndex = 22 })
  local body = box(frame, { Name = "Body", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = P.white, BackgroundTransparency = 0.955,
    LayoutOrder = 1, ZIndex = 21 })
  round(body, 14)
  list(body, 0)
  local wide = spec.full == true
  local section = setmetatable({ body = body, count = 0, made = 0, page = page, card = frame, wide = wide, icon = spec.icon or page.source.icon, top = true }, Section)
  page.list[#page.list + 1] = { title = spec.title or page.source.title or page.source.id, icon = spec.icon or page.source.icon or "circle", desc = spec.desc,
    frame = frame, head = head, wide = wide, section = section, stage = spec.stage == true }
  page.cards[#page.cards + 1] = { frame = frame, title = lower(spec.title) }
  return section
end
function Page:section(spec) return card(self, spec or {}) end
function Page:custom(height, build, alt)
  local section = card(self, { full = true })
  if alt then
    B.try("novoline.alt", alt, section)
    return section.body
  end
  local frame = box(section.body, { Name = "Custom", Size = UDim2.new(1, 0, 0, height or 0), LayoutOrder = nextOrder(section) })
  if not height then frame.AutomaticSize = Enum.AutomaticSize.Y end
  B.try("novoline.custom", build, frame)
  return frame
end
function Page:empty(icon, title, value)
  local section = card(self, {})
  local holder = box(section.body, { Size = UDim2.new(1, 0, 0, 160), LayoutOrder = nextOrder(section) })
  glyph(holder, icon or "package", 30, P.faint, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 26), ZIndex = 22 })
  text(holder, title or "Nothing here yet", 16, "bold", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 70), Size = UDim2.new(1, 0, 0, 22),
    TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 22 })
  text(holder, value or "", 12, "medium", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 96), Size = UDim2.new(1, -40, 0, 32),
    TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = P.subtle, TextWrapped = true, ZIndex = 22 })
end

-- ---------------------------------------------------------------- the tabs
local function tabsWanted()
  local out = {}
  for _, page in ipairs(Window.order) do
    if not page.hidden and page.build then out[#out + 1] = page end
  end
  return out
end
-- which rows a search keeps: { found anything, which groups show }. The hairline over the first row
-- still showing in each group goes, so a group never starts with a line.
local function filter(entry, query)
  local any, keep = false, {}
  for _, item in ipairs(entry.rows) do
    if item.frame.Parent then
      local found = query == "" or string.find(item.text, query, 1, true) ~= nil
      if found then
        if item.hidden then item.frame.Visible = true; item.hidden = nil end
        keep[item.card] = true
        any = true
      elseif item.frame.Visible then
        item.frame.Visible = false
        item.hidden = true
      end
    end
  end
  local shown = {}
  for _, c in ipairs(entry.cards) do
    local named = query ~= "" and c.title ~= "" and string.find(c.title, query, 1, true) ~= nil
    if named and not keep[c.frame] then
      for _, item in ipairs(entry.rows) do
        if item.card == c.frame and item.hidden then item.frame.Visible = true; item.hidden = nil end
      end
      any = true
    end
    shown[c.frame] = query == "" or keep[c.frame] == true or named
  end
  for _, c in ipairs(entry.cards) do
    local body = c.frame:FindFirstChild("Body")
    if body then
      local rows = {}
      for _, child in ipairs(body:GetChildren()) do
        if child:IsA("GuiObject") and child.Name == "Row" then rows[#rows + 1] = child end
      end
      table.sort(rows, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
      local first = true
      for _, r in ipairs(rows) do
        if r.Visible then
          local line = r:FindFirstChild("Line")
          if line then line.Visible = not first end
          first = false
        end
      end
    end
  end
  return any, shown
end

-- ---------------------------------------------------------------- the dock (Novoline's: 52 tall, 40 px items, a capsule behind the chosen one)
local DOCK = { pad = 6, h = 40, w = 40, gap = 2 }
local ICON_OFF, ICON_HOVER, ICON_ON = rgb(150, 150, 156), rgb(235, 235, 238), rgb(242, 242, 244)
local QUICK = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SLIDE = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
function N.paintNav(instant)
  if not N.bar then return end
  local x, selX, selW = DOCK.pad, nil, nil
  for _, tab in ipairs(N.tabs) do
    local selected = tab.id == N.current and N.open
    local w = selected and tab.wide or DOCK.w
    local goal = { Size = UDim2.fromOffset(w, DOCK.h), Position = UDim2.fromOffset(x, DOCK.pad) }
    if instant then tab.button.Size, tab.button.Position = goal.Size, goal.Position else tween(tab.button, SLIDE, goal) end
    if selected then selX, selW = x, w end
    tab.select(selected, instant)
    x += w + DOCK.gap
  end
  local barSize = UDim2.fromOffset(x - DOCK.gap + DOCK.pad, DOCK_H)
  if instant then N.bar.Size = barSize else tween(N.bar, SLIDE, { Size = barSize }) end
  local capsule = N.capsule
  if selX then
    local goal = { Position = UDim2.fromOffset(selX, DOCK.pad), Size = UDim2.fromOffset(selW, DOCK.h), BackgroundTransparency = 0 }
    if instant or capsule.BackgroundTransparency > 0.99 then
      capsule.Position, capsule.Size = goal.Position, UDim2.fromOffset(DOCK.w, DOCK.h)
      if instant then capsule.Size, capsule.BackgroundTransparency, N.capsuleRim.Transparency = goal.Size, 0, 0; return end
    end
    tween(capsule, SLIDE, goal)
    tween(N.capsuleRim, SLIDE, { Transparency = 0 })
  else
    tween(capsule, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
    tween(N.capsuleRim, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 })
  end
end
function N.rebuildTabs()
  if not N.built then return end
  for _, tab in ipairs(N.tabs) do tab.button:Destroy() end
  table.clear(N.tabs)
  local x = DOCK.pad
  for _, page in ipairs(tabsWanted()) do
    local label = page.title or page.id
    local ok, size = pcall(TextService.GetTextSize, TextService, label, 12, Enum.Font.GothamBold, Vector2.new(300, 20))
    local textW = ok and size.X or #label * 7
    local item = Instance.new("TextButton")
    item.Name, item.Text, item.AutoButtonColor = page.id, "", false
    item.Position, item.Size = UDim2.fromOffset(x, DOCK.pad), UDim2.fromOffset(DOCK.w, DOCK.h)
    item.BackgroundColor3, item.BackgroundTransparency, item.BorderSizePixel = P.white, 1, 0
    item.ZIndex, item.ClipsDescendants = 53, true
    item.Parent = N.bar
    round(item, true)
    local press = Instance.new("UIScale"); press.Parent = item
    local img = glyph(item, page.icon or "circle", 20, ICON_OFF, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(DOCK.w / 2, DOCK.h / 2), ZIndex = 54 })
    local name = text(item, label, 12, "bold", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 36, 0.5, 0), Size = UDim2.fromOffset(textW + 4, 16),
      TextColor3 = ICON_ON, TextTransparency = 1, TextTruncate = Enum.TextTruncate.None, ZIndex = 54 })
    local selected, hovered = false, false
    local function paint(instant)
      local over = hovered and not selected
      local goals = {
        { item, QUICK, { BackgroundTransparency = over and 0.92 or 1 } },
        { img, QUICK, { ImageColor3 = selected and ICON_ON or (over and ICON_HOVER or ICON_OFF) } },
        { img, SLIDE, { Position = UDim2.fromOffset(selected and 24 or DOCK.w / 2, DOCK.h / 2) } },
        { name, TweenInfo.new(selected and 0.3 or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, selected and 0.08 or 0), { TextTransparency = selected and 0 or 1 } },
      }
      for _, g in ipairs(goals) do
        if instant then for key, value in pairs(g[3]) do g[1][key] = value end else tween(g[1], g[2], g[3]) end
      end
    end
    item.MouseEnter:Connect(function()
      hovered = true
      paint()
      if not selected then N.showLabel(item, label) end
    end)
    item.MouseLeave:Connect(function() hovered = false; paint(); N.showLabel(nil) end)
    item.MouseButton1Down:Connect(function() tween(press, QUICK, { Scale = 0.94 }) end)
    item.MouseButton1Up:Connect(function() tween(press, SWITCH_INFO, { Scale = 1 }) end)
    item.MouseLeave:Connect(function() tween(press, SWITCH_INFO, { Scale = 1 }) end)
    item.Activated:Connect(B.safe("novoline.tab", function()
      if os.clock() - (N.tabAt or 0) < 0.25 then return end
      N.tabAt = os.clock()
      N.showLabel(nil)
      if N.open and N.current == page.id then N.show(false)
      elseif not N.open then N.current = page.id; N.show(true)
      else N.go(page.id) end
    end))
    N.tabs[#N.tabs + 1] = { id = page.id, button = item, wide = 14 + 20 + 6 + textW + 16, select = function(on, instant) selected = on; paint(instant) end }
    paint(true)
    x += DOCK.w + DOCK.gap
  end
  if not (N.current and Window.pages[N.current]) then
    -- (Novoline opens on its Home deck, the way Novoline does: a game's own tab, the ragebot,
    -- is a click away on the dock, never what the hub opens on)
    local wanted = tabsWanted()
    N.current = (Window.pages.home and "home") or (Window.startPage and Window.pages[Window.startPage] and Window.startPage) or (wanted[1] and wanted[1].id) or nil
  end
  N.paintNav(true)
end

-- ---------------------------------------------------------------- where the cards sit, and how they come and go
-- Novoline's scale: never past 1, and the whole layout (1280 x 712 design px) always on screen;
-- then the hub's own size settings.
local FULL_W, FULL_H = 1280, 712
local MARGIN, TOP, BOTTOM = 40, 34, 90
local function scaleNow()
  local camera = workspace.CurrentCamera
  local view = camera and camera.ViewportSize or Vector2.new(1280, 720)
  local fit = math.min(1, view.X / FULL_W, view.Y / FULL_H)
  return math.max(0.45, fit) * ((Config.get("app.scale") or 100) / 100) * ((Config.get("app.novoline.size") or 100) / 100)
end
N.scaleNow = scaleNow
local function screen()
  return N.gui.AbsoluteSize
end
-- the dock's bottom centre (dragged there, or Novoline's spot)
local function seat()
  if not N.bar then return end
  local x, y = Config.get("app.novoline.x"), Config.get("app.novoline.y")
  if type(x) == "number" and x >= 0 then N.bar.Position = UDim2.fromScale(x, y) else N.bar.Position = UDim2.new(0.5, 0, 1, -24) end
end
local function dockCentre()
  local bar = N.bar
  local at = bar.AbsolutePosition - N.gui.AbsolutePosition
  if not bar.Visible or bar.AbsoluteSize.X < 1 then
    local view = screen()
    return Vector2.new(view.X / 2, view.Y - 24 - DOCK_H / 2)
  end
  return at + bar.AbsoluteSize / 2
end
-- where a card rests: its corner, and how far in from it (design px); its centre and size in pixels
local function cardRest(item)
  local s = N.sizer.Scale
  local view = screen()
  local w, h = item.w * s, item.h * s
  local left = item.corner == "tl" or item.corner == "bl"
  local top = item.corner == "tl" or item.corner == "tr"
  local x = left and (MARGIN + item.x) * s + w / 2 or view.X - (MARGIN + item.x) * s - w / 2
  -- (the top row starts under Roblox's own buttons, which sit in the first 58 pixels)
  local topStart = math.max(TOP * s, UI.inset().Y + 14)
  local y = top and topStart + item.y * s + h / 2 or view.Y - (BOTTOM + item.y) * s - h / 2
  return Vector2.new(x, y), Vector2.new(w, h)
end
-- a card: dark glass whose body fades as one and never reflows while the card's frame grows round it
local function floating(name, w, h, radius, bare)
  local frame = box(N.gui, { Name = name, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(w, h), Visible = false, ZIndex = 20, ClipsDescendants = true })
  if not bare then glass(frame, radius or 28) end
  local scale = Instance.new("UIScale"); scale.Parent = frame
  local body = Instance.new("CanvasGroup")
  body.Name = "Body"
  body.BackgroundTransparency, body.BorderSizePixel = 1, 0
  body.AnchorPoint, body.Position, body.Size = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(w, h)
  body.ZIndex = 21
  body.Parent = frame
  return { frame = frame, body = body, scale = scale, w = w, h = h, bare = bare == true }
end
local function settle(item)
  local centre = cardRest(item)
  item.frame.Position = UDim2.fromOffset(centre.X, centre.Y)
  item.frame.Size = UDim2.fromOffset(item.w, item.h)
end
-- out of the dock: from a 120 x 44 pill where the dock is, to its place (0.56 s quint out)
local function rise(item, delay)
  local frame, body = item.frame, item.body
  item.sinking = false
  frame.Visible = true
  local centre = cardRest(item)
  if Motion.reduced then settle(item); body.GroupTransparency = 0; return end
  local dock = dockCentre()
  frame.Position = UDim2.fromOffset(dock.X, dock.Y)
  frame.Size = UDim2.fromOffset(120, 44)
  body.GroupTransparency = 1
  tween(frame, TweenInfo.new(0.56, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0), { Position = UDim2.fromOffset(centre.X, centre.Y), Size = UDim2.fromOffset(item.w, item.h) })
  tween(body, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0), { GroupTransparency = 0 })
end
-- a title has no glass: it comes up a little and fades in
local function lift(item, delay, from)
  local frame, body = item.frame, item.body
  item.sinking = false
  frame.Visible = true
  local centre = cardRest(item)
  frame.Size = UDim2.fromOffset(item.w, item.h)
  if Motion.reduced then frame.Position = UDim2.fromOffset(centre.X, centre.Y); body.GroupTransparency = 0; return end
  frame.Position = UDim2.fromOffset(centre.X, centre.Y + (from or 14) * N.sizer.Scale)
  body.GroupTransparency = 1
  tween(frame, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0), { Position = UDim2.fromOffset(centre.X, centre.Y) })
  tween(body, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0), { GroupTransparency = 0 })
end
-- from where another card is (a tab change: the card in the same corner turns into this one)
local function morph(item, fromPosition, fromSize, delay)
  local frame, body = item.frame, item.body
  item.sinking = false
  frame.Visible = true
  local centre = cardRest(item)
  if Motion.reduced then settle(item); body.GroupTransparency = 0; return end
  frame.Position, frame.Size = fromPosition, fromSize
  body.GroupTransparency = 1
  tween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, delay or 0), { Position = UDim2.fromOffset(centre.X, centre.Y), Size = UDim2.fromOffset(item.w, item.h) })
  tween(body, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay or 0), { GroupTransparency = 0 })
end
local function fadeAway(item)
  if not item.frame.Visible then return end
  item.sinking = true
  tween(item.body, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
  task.delay(0.16, function() if item.sinking then item.frame.Visible = false end end)
end
-- back into the dock (0.28 s quint in, most of the way, and gone)
local function sink(item, delay)
  local frame, body = item.frame, item.body
  if not frame.Visible then return end
  item.sinking = true
  if Motion.reduced then frame.Visible = false; return end
  if item.bare then
    tween(frame, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = frame.Position + UDim2.fromOffset(0, 10) })
    tween(body, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { GroupTransparency = 1 })
  else
    local dock = dockCentre()
    local at = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
    local goal = at:Lerp(dock, 0.45)
    tween(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In, 0, false, delay or 0),
      { Position = UDim2.fromOffset(goal.X, goal.Y), Size = UDim2.fromOffset(frame.Size.X.Offset * 0.6, frame.Size.Y.Offset * 0.6) })
    tween(body, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, (delay or 0) + 0.15), { GroupTransparency = 1 })
  end
  task.delay((delay or 0) + 0.34, function() if item.sinking then frame.Visible = false end end)
end
local labelTip
function N.showLabel(anchor, value)
  if not labelTip then return end
  if not anchor then labelTip.Visible = false; return end
  labelTip.Text = value
  local at = anchor.AbsolutePosition - overlay.AbsolutePosition
  labelTip.Position = UDim2.fromOffset(at.X + anchor.AbsoluteSize.X / 2, at.Y - 10)
  labelTip.Visible = true
end
-- a soft button on a card (Novoline's: the dark plate, its rim lit at the top, a lift under the mouse,
-- pressed to 95%); `tint` makes it a coloured tile instead
local function soft(parent, x, y, w, h, radius, tint, run)
  local holder = box(parent, { Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), ZIndex = 22 })
  local plate, liftFrame
  if tint then
    plate = box(holder, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = tint, BackgroundTransparency = 0, ZIndex = 23 })
    round(plate, radius)
    local line = rim(plate, P.white, 0)
    pcall(function() line.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
    local light = Instance.new("UIGradient"); light.Rotation = 90
    light.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.4, 0.96), NumberSequenceKeypoint.new(1, 0.97) })
    light.Parent = line
    liftFrame = box(plate, { Size = UDim2.fromScale(1, 1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 24 })
    round(liftFrame, radius)
  else
    plate, liftFrame = N.softFace(holder, radius)
  end
  local press = Instance.new("UIScale"); press.Parent = holder
  local button = hit(holder, { ZIndex = 30 })
  button.MouseEnter:Connect(function() tween(liftFrame, TweenInfo.new(0.18), { BackgroundTransparency = 0.95 }) end)
  button.MouseLeave:Connect(function() tween(liftFrame, TweenInfo.new(0.18), { BackgroundTransparency = 1 }); tween(press, SWITCH_INFO, { Scale = 1 }) end)
  button.MouseButton1Down:Connect(function() tween(press, QUICK, { Scale = 0.95 }) end)
  button.MouseButton1Up:Connect(function() tween(press, SWITCH_INFO, { Scale = 1 }) end)
  if run then button.Activated:Connect(B.safe("novoline.soft", function() UI.sfx("click", 0.5); run() end)) end
  return holder, plate, button
end
-- a card's own name (Novoline's: bold 14 at 18, 16) and its icon at the right
local function header(item, title, icon)
  text(item.body, title, 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(item.w - 70, 18), ZIndex = 22 })
  if icon then glyph(item.body, icon, 16, P.subtle, { Position = UDim2.fromOffset(item.w - 34, 17), ZIndex = 22 }) end
end
local function headshot(parent, x, y, size)
  local image = Instance.new("ImageLabel")
  image.BackgroundColor3, image.BorderSizePixel = rgb(40, 40, 44), 0
  image.Size, image.Position = UDim2.fromOffset(size, size), UDim2.fromOffset(x, y)
  image.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(B.LP.UserId) .. "&w=150&h=150"
  image.ZIndex = 22
  image.Parent = parent
  round(image, true)
  return image
end
-- Music, Keys, Settings, Close and Unload, under the account card
local function looksMenu(anchor)
  openMenu({
    { label = "Music", icon = "music", run = function() if B.Music and B.Music.openTab then B.Music.openTab() else N.go("music") end end },
    { label = "Keys", icon = "keyboard", run = function() N.go("keys") end },
    { label = "Settings", icon = "settings", run = function() N.go("settings") end },
    "divider",
    { label = "Close", icon = "x", run = function() N.show(false) end },
    { label = "Unload " .. (B.TITLE or "BASED"), icon = "power", danger = true, run = function() B.unload() end },
  }, nil, anchor)
end

-- ---------------------------------------------------------------- a tab's deck: Novoline's settings deck
-- tl  the tab's name (black 30) and its line (medium 13)
-- tr  a search pill (260 x 44) and your account beside it (200 x 44)
-- bl  the Sections card (210 x 360) beside the Options card (296 x 360) that holds the chosen section;
--     a wide section (a view of its own, the keyboard, the music) widens Options to 520. A tab of one
--     section has no Sections card: Options is a 520 stage from the corner.
-- br  Quick settings (330 x 173: the tab's first three switches as tinted tiles) over Shortcuts
--     (330 x 173: the keys on this tab)
-- (Options is 340 across, not Novoline's 296: the hub's settings have longer names and lines)
local SECTIONS_W, OPTIONS_W, STAGE_W, CARD_H, SIDE_W = 210, 340, 564, 360, 330
local decks = {}
N.decks = decks
local pick
local function addCard(d, name, corner, x, y, w, h, bare)
  local item = floating(name, w, h, h <= 60 and math.floor(h / 2) or 28, bare)
  item.corner, item.x, item.y = corner, x, y
  item.scale.Scale = N.sizer.Scale
  d.cards[#d.cards + 1] = item
  return item
end
-- the Options card at the width the chosen section wants
local function shape(d, wide, instant)
  if d.fixed then return end
  local item = d.options
  local w = (d.single or wide) and STAGE_W or OPTIONS_W
  if item.w == w then return end
  item.w = w
  item.body.Size = UDim2.fromOffset(w, item.h)
  d.heroTile.Position = UDim2.fromOffset(w - 16 - 36, 14)
  d.heroTitle.Size, d.heroDesc.Size = UDim2.fromOffset(w - 18 - 60, 20), UDim2.fromOffset(w - 18 - 60, 28)
  if not item.frame.Visible or instant or Motion.reduced then
    if item.frame.Visible then settle(item) end
    return
  end
  local centre = cardRest(item)
  tween(item.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(centre.X, centre.Y), Size = UDim2.fromOffset(w, item.h) })
end
local function rowsIn(entry, frame)
  local n = 0
  for _, item in ipairs(entry.rows) do if item.card == frame then n += 1 end end
  return n
end
local function tabDeck(source)
  local d = decks[source.id]
  if d then return d end
  d = { id = source.id, source = source, cards = {}, query = "", catRows = {} }
  decks[source.id] = d
  -- the name, top left
  local title = addCard(d, "Title", "tl", 0, 0, 760, 72, true)
  text(title.body, source.title or source.id, 30, "black", { Size = UDim2.fromOffset(760, 36), ZIndex = 22 })
  d.subtitle = text(title.body, source.eyebrow or source.desc or "", 13, "medium", { Position = UDim2.fromOffset(1, 40), Size = UDim2.fromOffset(760, 18), TextColor3 = P.sub, ZIndex = 22 })
  -- the search pill, top right
  local search = addCard(d, "Search", "tr", 0, 0, 260, 44)
  glyph(search.body, "search", 16, P.subtle, { Position = UDim2.fromOffset(16, 14), ZIndex = 22 })
  local seek = entryBox(search.body, 13)
  seek.Position, seek.Size, seek.ZIndex = UDim2.fromOffset(42, 0), UDim2.fromOffset(176, 44), 22
  seek.PlaceholderText, seek.PlaceholderColor3, seek.Text = "Search " .. lower(source.title or source.id), P.placeholder, ""
  d.seek = seek
  local clear = hit(search.body, { Position = UDim2.fromOffset(260 - 36, 10), Size = UDim2.fromOffset(24, 24), ZIndex = 23, Visible = false })
  glyph(clear, "x", 14, P.subtle, { Position = UDim2.fromOffset(5, 5), ZIndex = 24 })
  clear.Activated:Connect(function() seek.Text = "" end)
  -- you, beside it: a click opens the looks and the rest
  local account = addCard(d, "Account", "tr", 270, 0, 200, 44)
  headshot(account.body, 7, 7, 30)
  text(account.body, B.LP.DisplayName, 13, "bold", { Position = UDim2.fromOffset(46, 6), Size = UDim2.fromOffset(122, 16), ZIndex = 22 })
  text(account.body, "@" .. B.LP.Name, 10, "medium", { Position = UDim2.fromOffset(46, 23), Size = UDim2.fromOffset(122, 14), TextColor3 = P.subtle, ZIndex = 22 })
  glyph(account.body, "chevron-down", 14, P.subtle, { Position = UDim2.fromOffset(200 - 30, 15), ZIndex = 22 })
  local accountHit = hit(account.body, { ZIndex = 24, BackgroundColor3 = P.white })
  round(accountHit, 22)
  accountHit.MouseEnter:Connect(function() tween(accountHit, HOVER_INFO, { BackgroundTransparency = 0.96 }) end)
  accountHit.MouseLeave:Connect(function() tween(accountHit, HOVER_INFO, { BackgroundTransparency = 1 }) end)
  accountHit.Activated:Connect(B.safe("novoline.account", function() UI.sfx("click", 0.5); looksMenu(account.frame) end))
  -- Music is Novoline's music deck: what is playing is the stage, bottom left (its record, the
  -- cover and the Shuffle, Library and Playlists tiles: the hub's wide card), and the tab's sections
  -- sit bottom right, the way Novoline's queue does
  local stage = source.id == "music" and B.Card ~= nil and B.Card.viewWide ~= nil
  -- the Options card first: the tab builds into it
  local optionsW = stage and SIDE_W or OPTIONS_W
  local options = addCard(d, "Options", stage and "br" or "bl", stage and 0 or 224, 0, optionsW, CARD_H)
  d.options = options
  d.heroTitle = text(options.body, "", 16, "bold", { Position = UDim2.fromOffset(18, 14), Size = UDim2.fromOffset(optionsW - 18 - 60, 20), ZIndex = 22 })
  d.heroDesc = text(options.body, "", 11, "medium", { Position = UDim2.fromOffset(18, 35), Size = UDim2.fromOffset(optionsW - 18 - 60, 28), TextColor3 = P.subtle, ZIndex = 22,
    TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top })
  local heroTile = tile(options.body, { Position = UDim2.fromOffset(optionsW - 16 - 36, 14), Size = UDim2.fromOffset(36, 36), ZIndex = 21 }, 12)
  d.heroTile = heroTile
  d.heroIcon = glyph(heroTile, source.icon or "circle", 18, P.text, { Position = UDim2.fromOffset(9, 9), ZIndex = 22 })
  local scroller = Instance.new("ScrollingFrame")
  scroller.Name = source.id
  scroller.BackgroundTransparency, scroller.BorderSizePixel = 1, 0
  scroller.Position, scroller.Size = UDim2.fromOffset(0, 68), UDim2.new(1, 0, 1, -68)
  scroller.CanvasSize = UDim2.new()
  scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
  scroller.ScrollingDirection = Enum.ScrollingDirection.Y
  scroller.ScrollBarThickness = 0
  scroller.ZIndex = 21
  scroller.Parent = options.body
  scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function() hideTip() end)
  local content = box(scroller, { Name = "Content", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 21 })
  pad(content, 4, 12, 18, 12)
  list(content, 20)
  -- the tab, built into it
  local entry = setmetatable({ source = source, scroller = scroller, content = content, sections = 0, rows = {}, cards = {}, list = {}, toggles = {}, narrow = stage }, Page)
  N.pages[source.id] = entry
  d.entry = entry
  B.try("novoline.page." .. source.id, source.build, entry)
  -- (what the stage already shows is not a section of its own as well: Music's "Now playing" was
  -- the wide player squeezed into the narrow card beside the same player, 2026-10-30)
  if stage then
    for index = #entry.list, 1, -1 do
      local item = entry.list[index]
      if item.stage then
        item.frame.Visible = false
        table.remove(entry.list, index)
      end
    end
  end
  if #entry.list == 0 then entry:empty(nil, "Nothing here yet", "This tab is ready for its controls.") end
  if B.Keys and B.Keys.repaint then B.Keys.repaint() end
  -- its sections, beside it (a tab of one section is a stage of its own)
  d.single = #entry.list == 1 and not stage
  d.fixed = stage
  if stage then
    local size = B.Card.WIDE
    local now = addCard(d, "NowPlaying", "bl", 0, 0, STAGE_W, CARD_H)
    local k = math.min(STAGE_W / size.X, CARD_H / size.Y)
    local holder = box(now.body, { Name = "Wide", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size.X, size.Y), ZIndex = 21 })
    local grow = Instance.new("UIScale"); grow.Scale = k; grow.Parent = holder
    B.try("novoline.music.stage", B.Card.viewWide, holder, function() return N.open and N.current == "music" end)
  end
  if d.single then
    options.x = 0
  else
    local cats = addCard(d, "Sections", stage and "br" or "bl", stage and (SIDE_W + 14) or 0, 0, SECTIONS_W, CARD_H)
    text(cats.body, "Sections", 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(160, 18), ZIndex = 22 })
    local many = #entry.list > 8
    local step = many and 35 or 38
    local tall = step - 4
    local holder = Instance.new("ScrollingFrame")
    holder.BackgroundTransparency, holder.BorderSizePixel = 1, 0
    holder.Position, holder.Size = UDim2.fromOffset(0, many and 38 or 40), UDim2.new(1, 0, 1, -(many and 38 or 40) - 8)
    holder.CanvasSize = UDim2.fromOffset(0, #entry.list * step)
    holder.ScrollBarThickness = 0
    holder.ScrollingDirection = Enum.ScrollingDirection.Y
    holder.ZIndex = 21
    holder.Parent = cats.body
    local glide = box(holder, { Name = "Glide", BackgroundColor3 = P.white, BackgroundTransparency = 0.9, ZIndex = 21 })
    round(glide, 12)
    d.glide = glide
    for n, item in ipairs(entry.list) do
      local line = hit(holder, { Name = item.title, Position = UDim2.fromOffset(12, (n - 1) * step), Size = UDim2.fromOffset(186, tall), ZIndex = 22 })
      local mark = tile(line, { Position = UDim2.fromOffset(5, math.floor((tall - 24) / 2)), Size = UDim2.fromOffset(24, 24), ZIndex = 23 }, 8)
      glyph(mark, item.icon, 14, P.text, { Position = UDim2.fromOffset(5, 5), ZIndex = 24 })
      local name, fits = shrink(text(line, item.title, 13, "bold", { Position = UDim2.fromOffset(38, 0), Size = UDim2.fromOffset(112, tall), TextTransparency = 0.35, ZIndex = 23 }), 13, 11)
      d.catSize = math.min(d.catSize or 13, fits or 13)
      local held = rowsIn(entry, item.frame)
      text(line, held > 0 and tostring(held) or "", 11, "medium", { Position = UDim2.fromOffset(186 - 10 - 28, 0), Size = UDim2.fromOffset(28, tall), TextColor3 = P.subtle,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 23 })
      d.catRows[item] = { line = line, name = name }
      line.MouseEnter:Connect(function() if item ~= d.current or d.query ~= "" then tween(name, QUICK, { TextTransparency = 0.1 }) end end)
      line.MouseLeave:Connect(function() if item ~= d.current or d.query ~= "" then tween(name, QUICK, { TextTransparency = 0.35 }) end end)
      line.Activated:Connect(B.safe("novoline.section", function()
        UI.sfx("tab", 0.35)
        if d.query ~= "" then seek.Text = "" end
        pick(d, item)
      end))
    end
  end
  -- (the list reads as one: every name at the size the longest one fits)
  for _, r in pairs(d.catRows) do r.name.TextSize = d.catSize or 13 end
  -- quick settings, bottom right: the tab's first three switches as Novoline's tinted tiles
  -- (Music has none of these two: its sections are where they would be)
  local quick = addCard(stage and { cards = {} } or d, "Quick", "br", 0, 187, SIDE_W, 173)
  text(quick.body, "Quick settings", 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(200, 18), ZIndex = 22 })
  if #entry.toggles == 0 then
    text(quick.body, "No switches on this tab.", 12, "medium", { Position = UDim2.fromOffset(18, 48), Size = UDim2.fromOffset(SIDE_W - 36, 16), TextColor3 = P.subtle, ZIndex = 22 })
  end
  for n = 1, math.min(3, #entry.toggles) do
    local t = entry.toggles[n]
    local tint = TINT[n]
    local holder, plate = soft(quick.body, 16 + (n - 1) * 102, 40, 94, 117, 18, nil, function() Config.set(t.id, not (Config.get(t.id) == true)) end)
    local plateBody = plate:FindFirstChildOfClass("UIGradient")
    local mark = glyph(holder, t.icon or source.icon or "zap", 20, P.text, { Position = UDim2.fromOffset(14, 14), ZIndex = 26 })
    shrink(text(holder, t.label, 12, "bold", { Position = UDim2.fromOffset(14, 74), Size = UDim2.fromOffset(74, 16), ZIndex = 26 }), 12, 8)
    local state = text(holder, "", 11, "medium", { Position = UDim2.fromOffset(14, 92), Size = UDim2.fromOffset(74, 14), TextColor3 = P.subtle, ZIndex = 26 })
    local function paint()
      local on = Config.get(t.id) == true
      if plateBody then plateBody.Enabled = not on end
      plate.BackgroundColor3 = on and tint[1] or P.white
      tween(mark, QUICK, { ImageColor3 = on and tint[2] or P.text })
      state.Text = on and "On" or "Off"
    end
    paint()
    Config.on(t.id, function() if holder.Parent then paint() end end)
  end
  -- its keys, under that
  local keys = addCard(stage and { cards = {} } or d, "Shortcuts", "br", 0, 0, SIDE_W, 173)
  header(keys, "Shortcuts", "keyboard")
  local keyRows = box(keys.body, { Size = UDim2.fromScale(1, 1), ZIndex = 22 })
  local function drawKeys()
    for _, child in ipairs(keyRows:GetChildren()) do child:Destroy() end
    local bound = {}
    for id, info in pairs(Controls.bindables) do
      local bind = Config.bindOf(id)
      if bind and bind.key and info.page == source then bound[#bound + 1] = { id = id, label = info.label, kind = info.kind, bind = bind } end
    end
    table.sort(bound, function(a, b) return a.label < b.label end)
    if #bound == 0 then
      text(keyRows, "Nothing on this tab has a key yet. Right-click a switch to give it one.", 12, "medium", { Position = UDim2.fromOffset(18, 48), Size = UDim2.fromOffset(SIDE_W - 36, 34),
        TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextColor3 = P.subtle, ZIndex = 23 })
      local open = soft(keyRows, 18, 104, 132, 34, 17, nil, function() N.go("keys") end)
      glyph(open, "keyboard", 14, P.text, { Position = UDim2.fromOffset(14, 10), ZIndex = 26 })
      text(open, "All your keys", 12, "bold", { Position = UDim2.fromOffset(36, 0), Size = UDim2.fromOffset(90, 34), ZIndex = 26 })
      return
    end
    for n = 1, math.min(2, #bound) do
      local b = bound[n]
      local y = 44 + (n - 1) * ROW_H
      shrink(text(keyRows, b.label, 13, "bold", { Position = UDim2.fromOffset(18, y + 11), Size = UDim2.fromOffset(SIDE_W - 36 - 104, 16), ZIndex = 23 }), 13, 10)
      local how = b.kind == "button" and "Press to run" or (b.bind.mode == "hold" and "Hold to use" or "Press to switch")
      text(keyRows, how, 11, "medium", { Position = UDim2.fromOffset(18, y + 30), Size = UDim2.fromOffset(SIDE_W - 36 - 104, 14), TextColor3 = P.subtle, ZIndex = 23 })
      local plate = tile(keyRows, { Position = UDim2.fromOffset(SIDE_W - 18 - 92, y + 14), Size = UDim2.fromOffset(92, 28), ZIndex = 23 }, 14)
      text(plate, Config.keyLabel(b.bind.key), 12, "bold", { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 24 })
      if n < math.min(2, #bound) then
        box(keyRows, { Position = UDim2.fromOffset(18, y + ROW_H - 1), Size = UDim2.fromOffset(SIDE_W - 36, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0.94, ZIndex = 23 })
      end
    end
    if #bound > 2 then
      text(keyRows, "+" .. (#bound - 2) .. " more on Keys", 11, "medium", { Position = UDim2.fromOffset(18, 173 - 22), Size = UDim2.fromOffset(SIDE_W - 36, 14), TextColor3 = P.subtle, ZIndex = 23 })
    end
  end
  drawKeys()
  Config.bindsChanged:connect(function() if keyRows.Parent then drawKeys() end end)
  -- searching
  local token = 0
  seek:GetPropertyChangedSignal("Text"):Connect(function()
    clear.Visible = seek.Text ~= ""
    token += 1
    local mine = token
    task.delay(0.12, function()
      if mine ~= token then return end
      d.query = string.match(lower(seek.Text), "^%s*(.-)%s*$")
      B.try("novoline.search", pick, d, d.current)
    end)
  end)
  pick(d, entry.list[1], true)
  return d
end
-- show one section (or, while searching, every section that has a match)
pick = function(d, item, instant)
  local entry = d.entry
  if not item then return end
  fold()
  closeMenu()
  d.current = item
  local searching = d.query ~= ""
  local any, shown = filter(entry, d.query)
  local count = 0
  for _, other in ipairs(entry.list) do
    local on
    if searching then on = shown[other.frame] == true else on = other == item end
    other.frame.Visible = on
    other.head.Visible = searching and on
    if on then count += rowsIn(entry, other.frame) end
  end
  if searching then
    d.heroTitle.Text = any and "Results" or "Nothing found"
    d.heroDesc.Text = any and (count == 1 and "1 setting matches" or (count .. " settings match")) or "Try another word."
    UI.setIcon(d.heroIcon, "search")
  else
    d.heroTitle.Text = item.title
    local held = rowsIn(entry, item.frame)
    d.heroDesc.Text = item.desc or (held > 0 and (held == 1 and "1 setting" or (held .. " settings")) or "")
    UI.setIcon(d.heroIcon, item.icon or "circle")
  end
  shape(d, (not searching) and item.wide, instant)
  -- the Sections card: the glide sits under the chosen one, the others dimmed
  if d.glide then
    local at = d.catRows[item]
    if at then
      local goal = { Position = at.line.Position, Size = at.line.Size, BackgroundTransparency = searching and 1 or 0.9 }
      if instant or d.glide.Size.Y.Offset <= 0 then
        d.glide.Position, d.glide.Size, d.glide.BackgroundTransparency = goal.Position, goal.Size, goal.BackgroundTransparency
      else
        tween(d.glide, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goal)
      end
    end
    for other, r in pairs(d.catRows) do
      tween(r.name, QUICK, { TextTransparency = (other == item and not searching) and 0 or 0.35 })
    end
  end
  if not searching then d.entry.scroller.CanvasPosition = Vector2.zero end
end

-- ---------------------------------------------------------------- the Home deck: Novoline's own
local DAY = {
  { 5, "It's the middle of the night, night owl" }, { 7, "It's sunrise, the day is just getting started" }, { 11, "Good morning, have a good one" },
  { 14, "It's midday, sun's at the top" }, { 17, "Good afternoon, hope it's going well" }, { 19, "It's golden hour" }, { 21, "It's sunset, wind down a little" },
  { 24, "Good evening, the night is yours" },
}
local function dayLine()
  local hour = tonumber(os.date("%H")) or 12
  for _, step in ipairs(DAY) do if hour < step[1] then return step[2] end end
  return DAY[#DAY][2]
end
local homeDeck = nil
local function buildHome()
  if homeDeck then return homeDeck end
  local d = { id = "home", cards = {} }
  homeDeck = d
  -- the welcome, top left
  local title = addCard(d, "Title", "tl", 0, 0, 760, 72, true)
  text(title.body, "Welcome back, " .. B.LP.DisplayName, 30, "black", { Size = UDim2.fromOffset(760, 36), ZIndex = 22 })
  local day = text(title.body, dayLine(), 13, "medium", { Position = UDim2.fromOffset(1, 40), Size = UDim2.fromOffset(760, 18), TextColor3 = P.sub, ZIndex = 22 })
  -- the clock and the executor, top right
  local clock = addCard(d, "Clock", "tr", 0, 0, 158, 44)
  glyph(clock.body, "clock", 16, P.subtle, { Position = UDim2.fromOffset(16, 14), ZIndex = 22 })
  local time = text(clock.body, "", 15, "bold", { Position = UDim2.fromOffset(42, 0), Size = UDim2.fromOffset(50, 44), ZIndex = 22 })
  local date = text(clock.body, "", 13, "medium", { Position = UDim2.fromOffset(94, 0), Size = UDim2.fromOffset(56, 44), TextColor3 = P.subtle, ZIndex = 22 })
  local execName = "Executor"
  pcall(function()
    local name = (identifyexecutor or getexecutorname)()
    if type(name) == "string" and name ~= "" then execName = name end
  end)
  local okW, size = pcall(TextService.GetTextSize, TextService, execName, 13, Enum.Font.GothamBold, Vector2.new(400, 44))
  local execW = math.min(okW and size.X or 80, 160) + 58
  local exec = addCard(d, "Executor", "tr", 158 + 10, 0, execW, 44)
  glyph(exec.body, "shield", 16, P.subtle, { Position = UDim2.fromOffset(16, 14), ZIndex = 22 })
  text(exec.body, execName, 13, "bold", { Position = UDim2.fromOffset(40, 0), Size = UDim2.fromOffset(execW - 54, 44), ZIndex = 22 })
  -- you, bottom left
  local profile = addCard(d, "Profile", "bl", 0, 0, 230, 360)
  local banner = box(profile.body, { Name = "Banner", Size = UDim2.fromOffset(230, 110), BackgroundColor3 = P.white, BackgroundTransparency = 0, ZIndex = 21 })
  local bannerFade = Instance.new("UIGradient")
  bannerFade.Rotation = 90
  bannerFade.Color = ColorSequence.new(rgb(46, 46, 50), rgb(16, 16, 18))
  bannerFade.Transparency = NumberSequence.new(0, 1)
  bannerFade.Parent = banner
  local avatar = headshot(profile.body, 18, 70, 76)
  local ring = Instance.new("UIStroke"); ring.Color, ring.Thickness = rgb(12, 12, 14), 4; ring.Parent = avatar
  text(profile.body, B.LP.DisplayName, 18, "bold", { Position = UDim2.fromOffset(18, 158), Size = UDim2.fromOffset(194, 22), ZIndex = 22 })
  text(profile.body, "@" .. B.LP.Name, 12, "medium", { Position = UDim2.fromOffset(18, 182), Size = UDim2.fromOffset(194, 16), TextColor3 = P.subtle, ZIndex = 22 })
  local stat = {}
  for n, key in ipairs({ "Friends", "Account", "Online" }) do
    local x = 18 + (n - 1) * 68
    stat[key] = text(profile.body, "", 16, "bold", { Position = UDim2.fromOffset(x, 232), Size = UDim2.fromOffset(64, 20), ZIndex = 22 })
    text(profile.body, key, 11, "medium", { Position = UDim2.fromOffset(x, 254), Size = UDim2.fromOffset(64, 14), TextColor3 = P.subtle, ZIndex = 22 })
  end
  local ageDays = tonumber(B.LP.AccountAge) or 0
  stat.Account.Text = ageDays >= 365 and (math.floor(ageDays / 365) .. "y") or (ageDays .. "d")
  stat.Friends.Text, stat.Online.Text = "...", "..."
  box(profile.body, { Position = UDim2.fromOffset(18, 288), Size = UDim2.fromOffset(194, 1), BackgroundColor3 = P.white, BackgroundTransparency = 0.93, ZIndex = 22 })
  text(profile.body, os.date("Joined Roblox in %B %Y", os.time() - ageDays * 86400), 11, "medium", { Position = UDim2.fromOffset(18, 304), Size = UDim2.fromOffset(194, 14),
    TextColor3 = P.subtle, ZIndex = 22 })
  text(profile.body, "Account " .. (ageDays >= 365 and (math.floor(ageDays / 365) .. " years") or (ageDays .. " days")) .. " old", 11, "medium",
    { Position = UDim2.fromOffset(18, 324), Size = UDim2.fromOffset(194, 14), TextColor3 = P.subtle, ZIndex = 22 })
  -- over it, Novoline's own first widget: its name and the frames a second
  local widget = addCard(d, "Widget", "bl", 0, 360 + 14, 230, 118)
  text(widget.body, B.TITLE or "BASED", 15, "bold", { Position = UDim2.fromOffset(18, 18), Size = UDim2.fromOffset(194, 20), ZIndex = 22 })
  local fpsValue = text(widget.body, "-", 28, "black", { Position = UDim2.fromOffset(18, 48), Size = UDim2.fromOffset(194, 34), ZIndex = 22 })
  text(widget.body, "FPS", 11, "medium", { Position = UDim2.fromOffset(18, 84), Size = UDim2.fromOffset(194, 14), TextColor3 = P.subtle, ZIndex = 22 })
  -- quick actions: the first three tabs, as Novoline's tinted tiles
  local quick = addCard(d, "Quick", "bl", 244, 0, 260, 173)
  header(quick, "Quick actions", "zap")
  local picks = {}
  for _, page in ipairs(tabsWanted()) do
    if page.id ~= "home" and #picks < 3 then picks[#picks + 1] = page end
  end
  for n, page in ipairs(picks) do
    local tint = TINT[n]
    local holder = soft(quick.body, 18 + (n - 1) * 78, 46, 68, 109, 18, tint[1], function() N.go(page.id) end)
    glyph(holder, page.icon or "circle", 20, tint[2], { Position = UDim2.fromOffset(12, 14), ZIndex = 26 })
    shrink(text(holder, page.title or page.id, 13, "bold", { Position = UDim2.fromOffset(9, 109 - 14 - 16), Size = UDim2.fromOffset(56, 16), ZIndex = 26 }), 13, 8)
  end
  -- what is playing
  local music = addCard(d, "NowPlaying", "bl", 244, 187, 260, 173)
  header(music, "Now playing", "music")
  local cover = Instance.new("ImageLabel")
  cover.BackgroundColor3, cover.BorderSizePixel = rgb(40, 40, 44), 0
  cover.Position, cover.Size, cover.ScaleType, cover.ZIndex = UDim2.fromOffset(18, 46), UDim2.fromOffset(56, 56), Enum.ScaleType.Crop, 22
  cover.Parent = music.body
  round(cover, 12)
  local coverMark = glyph(cover, "music", 22, P.subtle, { Position = UDim2.fromOffset(17, 17), ZIndex = 23 })
  local songTitle = text(music.body, "Nothing playing", 14, "bold", { Position = UDim2.fromOffset(86, 54), Size = UDim2.fromOffset(156, 18), ZIndex = 22 })
  local songArtist = shrink(text(music.body, "Pick a song from your library", 12, "medium", { Position = UDim2.fromOffset(86, 73), Size = UDim2.fromOffset(156, 16), TextColor3 = P.subtle, ZIndex = 22 }), 12, 9)
  local playIcon
  local controls = {}
  for n, spec in ipairs({ { "skip-back", function() local M = B.Music; if M then M.front().previous() end end },
    { "play", function()
      local M = B.Music
      local ctl = M and M.front()
      if ctl and ctl.track() then ctl.toggle() elseif M and M.openTab then M.openTab() end
    end },
    { "skip-forward", function() local M = B.Music; if M then M.front().next() end end } }) do
    local main = n == 2
    local dim = main and 40 or 34
    local x = ({ 64, 110, 162 })[n]
    local holder, plate = soft(music.body, x, 173 - 18 - 20 - dim / 2, dim, dim, dim / 2, main and P.on or nil, spec[2])
    local isz = main and 16 or 14
    local mark = glyph(holder, spec[1], isz, main and P.ink or P.text, { Position = UDim2.fromOffset((dim - isz) / 2, (dim - isz) / 2), ZIndex = 26 })
    if main then playIcon = mark end
    controls[n] = holder
    local _ = plate
  end
  local coverKey
  local function refreshMusic()
    local M = B.Music
    local ctl = M and M.front()
    local track = ctl and ctl.track()
    local state = ctl and ctl.state() or "idle"
    if track and state ~= "idle" then
      songTitle.Text = track.title or "Playing"
      songArtist.Text = (ctl.status and ctl.status()) or track.artist or (state == "playing" and "Playing" or "Paused")
      if coverKey ~= track.key then
        coverKey = track.key
        cover.Image = ""
        B.try("novoline.cover", ctl.cover, track, cover)
      end
      coverMark.Visible = cover.Image == ""
    else
      songTitle.Text, songArtist.Text = "Nothing playing", "Pick a song from your library"
      cover.Image, coverMark.Visible, coverKey = "", true, nil
    end
    UI.setIcon(playIcon, state == "playing" and "pause" or "play")
    controls[1].Visible = track ~= nil
    controls[3].Visible = track ~= nil
  end
  -- two quick commands under it
  local cmd = addCard(d, "QuickCommands", "bl", 244, 360 + 14, 260, 118)
  text(cmd.body, "Quick Commands", 13, "bold", { Position = UDim2.fromOffset(16, 12), Size = UDim2.fromOffset(190, 16), ZIndex = 22 })
  glyph(cmd.body, "zap", 14, P.subtle, { Position = UDim2.fromOffset(260 - 30, 13), ZIndex = 22 })
  local cmdW = math.floor((260 - 14 * 2 - 10) / 2)
  local commands = {
    { label = "Music", icon = "music", tint = TINT[4], run = function() if B.Music and B.Music.openTab then B.Music.openTab() else N.go("music") end end },
    { label = "Keys", icon = "keyboard", tint = TINT[5], run = function() N.go("keys") end },
  }
  for n, c in ipairs(commands) do
    local holder = soft(cmd.body, 14 + (n - 1) * (cmdW + 10), 36, cmdW, 70, 16, c.tint[1], c.run)
    glyph(holder, c.icon, 22, c.tint[2], { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 24), ZIndex = 26 })
    text(holder, c.label, 12, "bold", { Position = UDim2.fromOffset(0, 70 - 8 - 14), Size = UDim2.fromOffset(cmdW, 14), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 26 })
  end
  -- the game, bottom right
  local gameCard = addCard(d, "Game", "br", 314, 0, 230, 360)
  local shot = Instance.new("ImageLabel")
  shot.Name, shot.BackgroundColor3, shot.BorderSizePixel = "Thumbnail", rgb(30, 30, 33), 0
  shot.Size, shot.ScaleType, shot.ZIndex = UDim2.fromOffset(230, 128), Enum.ScaleType.Crop, 21
  shot.Image = "rbxthumb://type=Asset&id=" .. tostring(game.PlaceId) .. "&w=768&h=432"
  shot.Parent = gameCard.body
  local shotFade = Instance.new("UIGradient")
  shotFade.Rotation = 90
  shotFade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.6, 0.15), NumberSequenceKeypoint.new(1, 1) })
  shotFade.Parent = shot
  local gameIcon = Instance.new("ImageLabel")
  gameIcon.BackgroundColor3, gameIcon.BorderSizePixel = rgb(40, 40, 44), 0
  gameIcon.Position, gameIcon.Size, gameIcon.ZIndex = UDim2.fromOffset(18, 96), UDim2.fromOffset(52, 52), 22
  gameIcon.Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.GameId) .. "&w=150&h=150"
  gameIcon.Parent = gameCard.body
  round(gameIcon, 14)
  local iconRing = Instance.new("UIStroke"); iconRing.Color, iconRing.Thickness = rgb(12, 12, 14), 3; iconRing.Parent = gameIcon
  local status = B.Registry and B.Registry.status and B.Registry.status() or {}
  local gameName = text(gameCard.body, status.name or "This game", 16, "bold", { Position = UDim2.fromOffset(18, 158), Size = UDim2.fromOffset(194, 20), ZIndex = 22 })
  local gameBy = text(gameCard.body, "", 12, "medium", { Position = UDim2.fromOffset(18, 180), Size = UDim2.fromOffset(194, 16), TextColor3 = P.subtle, ZIndex = 22 })
  text(gameCard.body, status.engineered and "BASED is engineered for it" or ("Place " .. tostring(game.PlaceId)), 12, "medium",
    { Position = UDim2.fromOffset(18, 214), Size = UDim2.fromOffset(194, 16), TextColor3 = P.sub, ZIndex = 22 })
  task.spawn(function()
    local ok, info = pcall(function() return S.MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok and type(info) == "table" and gameName.Parent then
      if not status.name then gameName.Text = tostring(info.Name or "This game") end
      local creator = type(info.Creator) == "table" and info.Creator.Name
      gameBy.Text = creator and ("By " .. tostring(creator)) or ""
    end
  end)
  local function copy(label, icon, x, value)
    local holder = soft(gameCard.body, x, 252, 94, 32, 16, nil, function()
      local done = B.clipboard and B.clipboard(value())
      Window.toast({ title = label, text = done and "Copied" or "This executor has no clipboard access.", icon = icon, tone = done and "ok" or "warn", time = 2.4 })
    end)
    glyph(holder, icon, 14, P.text, { Position = UDim2.fromOffset(12, 9), ZIndex = 26 })
    shrink(text(holder, label, 12, "bold", { Position = UDim2.fromOffset(31, 8), Size = UDim2.fromOffset(94 - 36, 16), ZIndex = 26 }), 12, 9)
  end
  copy("Copy link", "link", 18, function() return "https://www.roblox.com/games/" .. tostring(game.PlaceId) end)
  copy("Job ID", "copy", 118, function() return game.JobId end)
  -- this server
  local server = addCard(d, "Server", "br", 0, 187, 300, 173)
  header(server, "This server", "server")
  local sv = {}
  for n, key in ipairs({ "Players", "Ping", "Uptime" }) do
    local x = 18 + (n - 1) * 94
    sv[key] = text(server.body, "", 20, "bold", { Position = UDim2.fromOffset(x, 44), Size = UDim2.fromOffset(90, 24), ZIndex = 22 })
    text(server.body, key, 11, "medium", { Position = UDim2.fromOffset(x, 68), Size = UDim2.fromOffset(90, 14), TextColor3 = P.subtle, ZIndex = 22 })
  end
  local function chip(label, icon, x, w, run)
    local holder = soft(server.body, x, 97, w, 30, 15, nil, run)
    glyph(holder, icon, 14, P.text, { Position = UDim2.fromOffset(12, 8), ZIndex = 26 })
    text(holder, label, 12, "bold", { Position = UDim2.fromOffset(32, 0), Size = UDim2.fromOffset(w - 38, 30), ZIndex = 26 })
  end
  chip("Rejoin", "rotate-ccw", 18, 124, function() if B.Server and B.Server.rejoin then B.Server.rejoin() end end)
  chip("Server hop", "shuffle", 150, 132, function() if B.Server and B.Server.hop then B.Server.hop() end end)
  -- your friends
  local friends = addCard(d, "Friends", "br", 0, 0, 300, 173)
  text(friends.body, "Friends online", 14, "bold", { Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(200, 18), ZIndex = 22 })
  local friendCount = text(friends.body, "", 14, "bold", { Position = UDim2.fromOffset(200, 16), Size = UDim2.fromOffset(82, 18), TextColor3 = P.subtle,
    TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 22 })
  local faces = {}
  for n = 1, 6 do
    local f = Instance.new("ImageLabel")
    f.BackgroundColor3, f.BorderSizePixel = rgb(40, 40, 44), 0
    f.Position, f.Size, f.ZIndex, f.Visible = UDim2.fromOffset(18 + (n - 1) * 27, 48), UDim2.fromOffset(36, 36), 22 + (7 - n), false
    f.Parent = friends.body
    round(f, true)
    local r = Instance.new("UIStroke"); r.Color, r.Thickness = rgb(14, 14, 16), 3; r.Parent = f
    faces[n] = f
  end
  local more = text(friends.body, "", 12, "bold", { Position = UDim2.fromOffset(0, 48), Size = UDim2.fromOffset(70, 36), TextColor3 = P.subtle, ZIndex = 22 })
  local friendLine = text(friends.body, "Looking for your friends", 12, "medium", { Position = UDim2.fromOffset(18, 104), Size = UDim2.fromOffset(264, 16), TextColor3 = P.sub, ZIndex = 22 })
  local friendsAt, totalAsked = -1e9, false
  local function loadFriends()
    if os.clock() - friendsAt < 30 then return end
    friendsAt = os.clock()
    task.spawn(function()
      local ok, list0 = pcall(function() return B.LP:GetFriendsOnline(50) end)
      if not friendLine.Parent then return end
      if not ok or type(list0) ~= "table" then friendLine.Text = "Friends could not be loaded"; return end
      local here = 0
      for _, f in ipairs(list0) do if f.PlaceId == game.PlaceId then here += 1 end end
      for n, f in ipairs(faces) do
        local friend = list0[n]
        f.Visible = friend ~= nil
        if friend then f.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(friend.VisitorId) .. "&w=48&h=48" end
      end
      local shown = math.min(#list0, #faces)
      more.Position = UDim2.fromOffset(18 + math.max(shown - 1, 0) * 27 + 36 + 10, 48)
      more.Text = #list0 > #faces and ("+" .. (#list0 - #faces)) or ""
      friendCount.Text = tostring(#list0)
      stat.Online.Text = tostring(#list0)
      if #list0 == 0 then friendLine.Text = "No friends online right now"
      elseif here == 0 then friendLine.Text = "None of them are in this game"
      else friendLine.Text = here .. (here == 1 and " of them is" or " of them are") .. " playing this game" end
    end)
    if totalAsked then return end
    totalAsked = true
    task.spawn(function()
      local count = 0
      local ok = pcall(function()
        local pages = S.Players:GetFriendsAsync(B.LP.UserId)
        while true do
          count += #pages:GetCurrentPage()
          if pages.IsFinished then break end
          pages:AdvanceToNextPageAsync()
        end
      end)
      if stat.Friends.Parent then stat.Friends.Text = ok and tostring(count) or "0" end
    end)
  end
  local function uptime(seconds)
    seconds = math.floor(seconds or 0)
    if seconds >= 3600 then return string.format("%dh %dm", seconds // 3600, (seconds % 3600) // 60) end
    return string.format("%dm", math.max(1, seconds // 60))
  end
  d.refresh = function()
    time.Text = os.date("%H:%M")
    date.Text = (string.gsub(os.date("%a %d"), " 0", " "))
    day.Text = dayLine()
    sv.Players.Text = #S.Players:GetPlayers() .. "/" .. S.Players.MaxPlayers
    local hud = B.Hud
    sv.Ping.Text = tostring(hud and hud.ping and math.floor(hud.ping() + 0.5) or 0) .. "ms"
    sv.Uptime.Text = uptime(workspace.DistributedGameTime)
    fpsValue.Text = tostring(hud and hud.fps and math.floor(hud.fps() + 0.5) or 0)
    B.try("novoline.music", refreshMusic)
    loadFriends()
  end
  Motion.every(function()
    if N.open and N.current == "home" then d.refresh() end
  end, 2, "novoline.home")
  return d
end

-- ---------------------------------------------------------------- showing a deck, and changing decks
local shown = nil
-- opening: every card rises out of the dock, in a shuffled order, a moment apart (Novoline's);
-- changing tab: each card glides out of the card that was in its corner, the rest fade
local function showDeck(d, opening, from)
  shown = d
  if d.refresh then B.try("novoline.refresh", d.refresh) end
  local count = #d.cards
  local order = {}
  for i = 1, count do order[i] = i end
  if opening then for i = count, 2, -1 do local j = math.random(i); order[i], order[j] = order[j], order[i] end end
  local used = {}
  for n, item in ipairs(d.cards) do
    item.scale.Scale = N.sizer.Scale
    local delay = math.min((order[n] - 1) * (opening and 0.04 or 0.018), opening and 0.22 or 0.12)
    if item.bare then
      lift(item, delay, opening and 14 or 6)
    elseif opening or not from then
      rise(item, delay)
    else
      local partner
      for _, other in ipairs(from.cards) do
        if not used[other] and not other.bare and other.corner == item.corner and other.frame.Visible and not other.sinking then
          partner, used[other] = other, true
          break
        end
      end
      if partner then
        morph(item, partner.frame.Position, partner.frame.Size, 0)
      else
        local centre = cardRest(item)
        morph(item, UDim2.fromOffset(centre.X, centre.Y), UDim2.fromOffset(item.w * 0.96, item.h * 0.96), delay)
      end
    end
  end
  if from and from ~= d then
    for _, other in ipairs(from.cards) do fadeAway(other) end
  end
end
local function hideDeck(d)
  if not d then return end
  for n, item in ipairs(d.cards) do sink(item, (n - 1) * 0.012) end
end
function N.go(id)
  local source = Window.pages[id]
  if not (source and N.built) then return end
  fold()
  closeMenu()
  hideTip()
  N.current = id
  N.paintNav()
  if not N.open then return end
  local d
  if id == "home" then d = buildHome() else
    local ok, made = pcall(tabDeck, source)
    if not ok then B.fault("novoline.deck." .. tostring(id), made); return end
    d = made
  end
  if shown == d and not N.opening then return end
  local from = (not N.opening) and shown or nil
  -- (Novoline's tab sound on a change of tab, from the dock or anywhere; opening has its own)
  if from and from ~= d then nvSound("tab") end
  showDeck(d, N.opening, from ~= d and from or nil)
end
-- (for a test, or a tab that wants to point at one of its sections: the n-th section of a tab)
function N.pickSection(id, n)
  local d = decks[id]
  if d and d.entry and d.entry.list[n] then pick(d, d.entry.list[n]) end
end
-- a search from elsewhere (the palette): it goes into the deck the tab has
function N.search(value)
  if not (N.built and N.current and N.current ~= "home") then return end
  local d = decks[N.current]
  if d and d.seek then d.seek.Text = value or "" end
end

-- ---------------------------------------------------------------- the window
function N.build()
  if N.built then return end
  N.built = true
  N.since = os.clock()
  pickFont()
  local gui = B.screen(9060)
  gui:SetAttribute("OwnLetters", true)
  N.gui = gui
  N.modal = Instance.new("TextButton")
  N.modal.Text, N.modal.BackgroundTransparency, N.modal.Size, N.modal.Modal, N.modal.Visible = "", 1, UDim2.fromOffset(0, 0), true, false
  N.modal.Parent = gui
  -- the shade over the game while it is open (Novoline's: darker at the top and the bottom); a click on it closes
  local shade = Instance.new("TextButton")
  shade.Name, shade.Text, shade.AutoButtonColor = "Shade", "", false
  shade.Size, shade.BackgroundColor3, shade.BackgroundTransparency, shade.BorderSizePixel, shade.ZIndex = UDim2.fromScale(1, 1), P.black, 1, 0, 1
  shade.Visible = false
  shade.Parent = gui
  local shadeFade = Instance.new("UIGradient")
  shadeFade.Rotation = 90
  shadeFade.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(0.16, 0.48), NumberSequenceKeypoint.new(0.45, 0.6),
    NumberSequenceKeypoint.new(1, 0.2) })
  shadeFade.Parent = shade
  shade.Activated:Connect(B.safe("novoline.shade", function() if N.open then N.show(false) end end))
  N.shade = shade
  N.sizer = { Scale = scaleNow() }
  -- the dock: Novoline's pill, its capsule, a tab an item
  local bar = box(gui, { Name = "Dock", AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(304, DOCK_H), Visible = false, ZIndex = 40 })
  glass(bar, DOCK_H / 2)
  bar:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(1, 0)
  N.bar = bar
  N.barScale = Instance.new("UIScale"); N.barScale.Parent = bar
  local capsule = box(bar, { Name = "Capsule", BackgroundColor3 = P.white, BackgroundTransparency = 1, Size = UDim2.fromOffset(DOCK.w, DOCK.h),
    Position = UDim2.fromOffset(DOCK.pad, DOCK.pad), ZIndex = 52 })
  round(capsule, true)
  local capsuleBody = Instance.new("UIGradient"); capsuleBody.Rotation = 90; capsuleBody.Color = ColorSequence.new(rgb(46, 46, 49), rgb(32, 32, 35)); capsuleBody.Parent = capsule
  local capsuleRim = rim(capsule, P.white, 1)
  pcall(function() capsuleRim.BorderStrokePosition = Enum.BorderStrokePosition.Inner end)
  local capsuleLight = Instance.new("UIGradient"); capsuleLight.Rotation = 90
  capsuleLight.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.86), NumberSequenceKeypoint.new(0.4, 0.96), NumberSequenceKeypoint.new(1, 0.97) })
  capsuleLight.Parent = capsuleRim
  N.capsule, N.capsuleRim = capsule, capsuleRim
  seat()
  -- (held on its empty parts, the dock moves)
  local barGrip = hit(bar, { ZIndex = 51 })
  local barFrom, barStart
  UI.drag(barGrip, function(point)
    barFrom, barStart = point, Vector2.new(bar.AbsolutePosition.X + bar.AbsoluteSize.X / 2, bar.AbsolutePosition.Y + bar.AbsoluteSize.Y)
  end, function(point)
    local view = screen()
    local inset = UI.inset()
    local bottom = barStart + (point - barFrom)
    bar.Position = UDim2.fromScale(util.clamp01(bottom.X / view.X), util.clamp01((bottom.Y + inset.Y) / view.Y))
  end, function()
    Config.set("app.novoline.x", bar.Position.X.Scale)
    Config.set("app.novoline.y", bar.Position.Y.Scale)
  end)
  -- the overlay: menus, tips, the tab names over the dock
  overlay = box(gui, { Name = "Overlay", Size = UDim2.fromScale(1, 1), ZIndex = 80 })
  tip = text(overlay, "", 12, "medium", { Name = "Tip", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, TextWrapped = true,
    TextTruncate = Enum.TextTruncate.None, BackgroundColor3 = P.raised, BackgroundTransparency = 0, Visible = false, ZIndex = 95 })
  round(tip, 8)
  pad(tip, 6, 10, 6, 10)
  local tipMost = Instance.new("UISizeConstraint"); tipMost.MaxSize = Vector2.new(280, math.huge); tipMost.Parent = tip
  labelTip = text(overlay, "", 11, "bold", { Name = "Label", AnchorPoint = Vector2.new(0.5, 1), Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
    TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.None, BackgroundColor3 = P.raised, BackgroundTransparency = 0, Visible = false, ZIndex = 96 })
  round(labelTip, true)
  pad(labelTip, 0, 10, 0, 10)
  -- a click outside an open list or menu closes it
  B.connect(UIS.InputBegan, function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 and input.UserInputType ~= Enum.UserInputType.Touch then
      if input.KeyCode == Enum.KeyCode.Escape then closeMenu(); fold() end
      return
    end
    local point = UI.point(input)
    if menu and not UI.inside(menu.frame, point) and not (menu.anchor and menu.anchor.Parent and UI.inside(menu.anchor, point)) then closeMenu() end
    if unfolded and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
      if not (UI.inside(unfolded.frame, point) or (unfolded.anchor and unfolded.anchor.Parent and UI.inside(unfolded.anchor, point))) then fold() end
    end
  end, "novoline.outside")
  -- the screen's size or the hub's scale changes: everything follows
  local function rescale()
    if not N.sizer then return end
    local s = scaleNow()
    N.sizer.Scale = s
    N.barScale.Scale = s
    local all = { homeDeck }
    for _, d in pairs(decks) do all[#all + 1] = d end
    for _, d in ipairs(all) do
      for _, item in ipairs(d.cards) do
        item.scale.Scale = s
        if N.open and d == shown and item.frame.Visible and not item.sinking then settle(item) end
      end
    end
  end
  N.rescale = rescale
  rescale()
  local camera = workspace.CurrentCamera
  if camera then B.connect(camera:GetPropertyChangedSignal("ViewportSize"), rescale, "novoline.viewport") end
  N.rebuildTabs()
end
-- open: the dock pops up, the tab's deck rises out of it, the shade comes down; shut: all of it goes back
local motionToken = 0
function N.show(on)
  if on and not N.built then N.build() end
  if not N.built or N.open == on then
    if N.built and not on then N.bar.Visible = N.active() and Config.get("app.novoline.dock") == true end
    return
  end
  N.open = on
  motionToken += 1
  local mine = motionToken
  closeMenu()
  fold()
  hideTip()
  N.showLabel(nil)
  N.modal.Visible = on and Config.get("app.freeCursor") ~= false
  if on then
    N.rescale()
    N.rebuildTabs()
    local bar = N.bar
    if not bar.Visible then
      bar.Visible = true
      seat()
      if not Motion.reduced then
        N.barScale.Scale = N.sizer.Scale * 0.86
        tween(N.barScale, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = N.sizer.Scale })
      end
    end
    N.shade.Visible = true
    N.shade.BackgroundTransparency = 1
    tween(N.shade, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 - (Config.get("app.novoline.shade") or 100) / 100 })
    local id = N.current or "home"
    shown = nil
    N.opening = true
    local ok, err = pcall(N.go, id)
    N.opening = false
    if not ok then B.fault("novoline.open", err) end
    nvSound("open")
  else
    for _, d in pairs(decks) do if d.seek and d.seek:IsFocused() then d.seek:ReleaseFocus() end end
    hideDeck(shown)
    N.paintNav()
    tween(N.shade, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 })
    task.delay(0.36, function()
      if mine ~= motionToken then return end
      N.shade.Visible = false
      -- (the dock goes too, unless it is kept on screen)
      if Config.get("app.novoline.dock") ~= true and not N.open then
        if Motion.reduced then N.bar.Visible = false; return end
        tween(N.barScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = N.sizer.Scale * 0.86 })
        task.delay(0.2, function() if mine == motionToken and not N.open then N.bar.Visible = false; N.barScale.Scale = N.sizer.Scale end end)
      end
    end)
    nvSound("close")
  end
  if Window.onShow then Window.onShow:fire(Window.anyOpen()) end
end
function N.toggle() N.show(not N.open) end
function N.active() return Config.get("app.gui") == "novoline" end

-- ---------------------------------------------------------------- the island: what is playing, every message
local island
function N.islandHasMusic()
  if not (island ~= nil and island.frame.Visible and B.Music ~= nil) then return false end
  local ctl = B.Music.front()
  return ctl.track() ~= nil and ctl.state() ~= "idle"
end
local function islandWanted() return N.active() and Config.get("app.novoline.island") ~= false and Config.get("app.island") ~= false end
local function makeIsland()
  if island or not N.gui then return end
  local frame = box(N.gui, { Name = "Island", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 10), Size = UDim2.fromOffset(196, 36), ZIndex = 70 })
  frame.BackgroundColor3 = P.black
  frame.BackgroundTransparency = 0.02
  round(frame, true)
  rim(frame, P.white, 0.9)
  pcall(function()
    local glow = Instance.new("UIShadow")
    glow.Color, glow.BlurRadius, glow.Offset, glow.Transparency, glow.ZIndex = P.black, UDim.new(0, 18), UDim2.fromOffset(0, 6), 0.5, -1
    glow.Parent = frame
  end)
  local sizer = Instance.new("UIScale"); sizer.Parent = frame
  frame.ClipsDescendants = true
  -- what it shows when nothing else is: the name, frames a second, ping
  local idle = box(frame, { Name = "Idle", Size = UDim2.fromScale(1, 1), ZIndex = 71 })
  local dot = box(idle, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(7, 7), BackgroundTransparency = 0, ZIndex = 72 })
  round(dot, true)
  wear(dot, "BackgroundColor3")
  text(idle, "BASED", 12, "black", { Position = UDim2.fromOffset(30, 0), Size = UDim2.new(0, 56, 1, 0), ZIndex = 72 })
  local stats = text(idle, "", 11, "medium", { Position = UDim2.fromOffset(86, 0), Size = UDim2.new(1, -102, 1, 0), TextColor3 = P.dim, ZIndex = 72,
    TextXAlignment = Enum.TextXAlignment.Right })
  -- the song: a turning cover, its name, bars that move with it
  local song = box(frame, { Name = "Song", Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 71 })
  local art = Instance.new("ImageLabel")
  art.BackgroundColor3, art.BorderSizePixel = P.raised, 0
  art.AnchorPoint, art.Position, art.Size = Vector2.new(0, 0.5), UDim2.new(0, 6, 0.5, 0), UDim2.fromOffset(28, 28)
  art.ScaleType, art.ZIndex = Enum.ScaleType.Crop, 72
  art.Parent = song
  round(art, true)
  local songName = B.Music and B.Music.marquee(song, kit, { Position = UDim2.fromOffset(42, 4), Size = UDim2.new(1, -96, 0, 15), ZIndex = 72 }, true, 12)
  local songWho = text(song, "", 10, "medium", { Position = UDim2.fromOffset(42, 19), Size = UDim2.new(1, -96, 0, 13), TextColor3 = P.dim, ZIndex = 72 })
  local bars = {}
  for i = 1, 5 do
    local bar = box(song, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(1, -46 + (i - 1) * 7, 0.5, 0), Size = UDim2.fromOffset(4, 6), BackgroundTransparency = 0, ZIndex = 72 })
    round(bar, true)
    wear(bar, "BackgroundColor3")
    bars[i] = bar
  end
  -- the line being sung, word by word (src/49): it takes the song's place while there is one
  local plainParts = { art, songWho, bars[1], bars[2], bars[3], bars[4], bars[5] }
  if songName then plainParts[#plainParts + 1] = songName.holder end
  local lyricRow = B.Island and B.Island.row(song, { font = face("bold"), size = 13, z = 72, accent = function()
    return B.Card and B.Card.wordColor(accent()) or accent()
  end }) or nil
  if lyricRow then lyricRow.frame.Visible = false end
  -- a message: its icon, title and text
  local note = box(frame, { Name = "Note", Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 71 })
  local chip = box(note, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(32, 32), BackgroundTransparency = 0, ZIndex = 72 })
  round(chip, true)
  local chipIcon = glyph(chip, "sparkles", 16, P.white, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 73 })
  local noteTitle = text(note, "", 13, "bold", { Position = UDim2.fromOffset(50, 9), Size = UDim2.new(1, -62, 0, 17), ZIndex = 72 })
  local noteText = text(note, "", 11, "medium", { Position = UDim2.fromOffset(50, 27), Size = UDim2.new(1, -62, 0, 14), TextColor3 = P.dim, ZIndex = 72 })
  local click = hit(frame, { ZIndex = 75 })
  click.Activated:Connect(B.safe("novoline.island", function()
    if island.showing then island.showing.gone = true end
    N.show(true)
  end))
  island = { frame = frame, idle = idle, song = song, note = note, queue = {}, sizer = sizer }
  local level, peak = 0, 4
  local spin = 0
  local coverKey
  local function shape(width, height)
    if island.width ~= width or island.height ~= height then
      island.width, island.height = width, height
      tween(frame, OPEN_INFO, { Size = UDim2.fromOffset(width, height) })
    end
  end
  Motion.every(function(dt)
    local wanted = islandWanted()
    frame.Visible = wanted
    if not wanted then return end
    local camera = workspace.CurrentCamera
    sizer.Scale = math.clamp((camera and camera.ViewportSize.Y or 900) / 1080, 0.8, 1.1) * ((Config.get("app.scale") or 100) / 100)
    frame.Position = UDim2.new(0.5, 0, 0, 10)
    local M = B.Music
    local message = island.showing
    if message and (message.gone or os.clock() > message.till) then island.showing = nil; message = nil end
    if not message and #island.queue > 0 then
      message = table.remove(island.queue, 1)
      message.till = os.clock() + (message.time or 3)
      island.showing = message
      noteTitle.Text, noteText.Text = message.title or "", message.text or ""
      UI.setIcon(chipIcon, message.icon or "sparkles")
      local tone = message.tone
      chip.BackgroundColor3 = tone == "bad" and P.danger or (tone == "warn" and rgb(244, 180, 95) or (tone == "ok" and P.good or accent()))
    end
    local ctl = M and M.front()
    local playing = ctl ~= nil and ctl.track() ~= nil and ctl.state() ~= "idle" and Config.get("music.island") ~= false
    idle.Visible = not message and not playing
    song.Visible = not message and playing == true
    note.Visible = message ~= nil
    if message then
      shape(math.clamp(64 + math.max(#(message.title or ""), #(message.text or "")) * 6.4, 240, 380), (message.text and message.text ~= "") and 48 or 40)
    elseif playing then
      local track = ctl.track()
      -- a line being sung: the row of words (it says how wide it wants the island)
      local want, singing = 300, false
      if lyricRow then want, singing = lyricRow.step(dt, ctl) end
      if lyricRow then lyricRow.frame.Visible = singing end
      for _, part in ipairs(plainParts) do part.Visible = not singing end
      shape(singing and math.floor(want + 0.5) or 300, 40)
      if songName then songName.set(track.title); songName.step(dt) end
      songWho.Text = ctl.status() or track.artist
      if coverKey ~= track.key then coverKey = track.key; ctl.cover(track, art) end
      local live = ctl.state() == "playing"
      if live then spin = (spin + dt * 120) % 360 end
      art.Rotation = spin
      local raw = live and ctl.loudness() or 0
      peak = math.max(peak * (1 - math.min(dt * 0.35, 1)), raw, 4)
      local loud = live and math.clamp(raw / peak * 1.05, 0, 1.15) or 0
      level += (loud - level) * math.min(dt * 12, 1)
      local now = os.clock()
      for i, bar in ipairs(bars) do
        local wobble = 0.45 + 0.55 * math.abs(math.sin(now * (3.1 + i * 0.9) + i))
        bar.Size = UDim2.fromOffset(4, math.clamp(4 + level * 18 * wobble, 4, 22))
      end
    else
      shape(196, 36)
      local hud = B.Hud
      local fps = hud and hud.fps and math.floor(hud.fps() + 0.5) or 0
      local ping = hud and hud.ping and math.floor(hud.ping() + 0.5) or 0
      stats.Text = string.format("%d fps · %d ms", fps, ping)
    end
  end, nil, "novoline.island")
end
function N.island() if N.gui then makeIsland() end end
-- messages go into the island while this look is in use
Window.toastHook = function(opts)
  if not (N.built and islandWanted() and island) then return nil end
  if opts.music and Config.get("music.island") ~= false then return function() end end
  local message = { title = opts.title, text = opts.text, icon = opts.icon, tone = opts.tone, time = opts.time or 3.2 }
  island.queue[#island.queue + 1] = message
  while #island.queue > 4 do table.remove(island.queue, 1) end
  nvSound("notify")
  return function() message.gone = true end
end

-- ---------------------------------------------------------------- the key list, drawn this way
function N.keyPanel(parent)
  local panel = box(parent, { Name = "KeysNovoline", Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY })
  glass(panel, 18)
  local least = Instance.new("UISizeConstraint"); least.MinSize = Vector2.new(200, 0); least.Parent = panel
  local stack = box(panel, { Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, ZIndex = 2 })
  pad(stack, 12, 14, 12, 14)
  list(stack, 6)
  local head = box(stack, { Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 0, ZIndex = 2 })
  local title = text(head, "Keybinds", 13, "bold", { Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 3 })
  local body = box(stack, { Size = UDim2.fromOffset(0, 0), AutomaticSize = Enum.AutomaticSize.XY, LayoutOrder = 1, ZIndex = 2 })
  list(body, 4)
  local api = { frame = panel, rows = {}, shape = nil }
  -- (lit: the key chip turns white, the name bright, a soft wash behind the row; all of it fades)
  local function light(row, on, animate)
    row.on = on
    local goal = { chip = on and P.on or P.raised, key = on and P.knobOn or P.sub, name = on and P.text or P.dim, wash = on and 0.93 or 1 }
    if animate and not Motion.reduced then
      tween(row.chip, SWITCH_INFO, { BackgroundColor3 = goal.chip })
      tween(row.key, SWITCH_INFO, { TextColor3 = goal.key })
      tween(row.name, SWITCH_INFO, { TextColor3 = goal.name })
      tween(row.wash, SWITCH_INFO, { BackgroundTransparency = goal.wash })
      if on then
        row.pop.Scale = 1.2
        Motion.to(row.pop, "Scale", 1, "bouncy")
      end
    else
      row.chip.BackgroundColor3, row.key.TextColor3, row.name.TextColor3, row.wash.BackgroundTransparency = goal.chip, goal.key, goal.name, goal.wash
    end
  end
  function api.forget() api.shape = nil end
  function api.render(binds, moving)
    local shape = B.Keys.shape(binds, moving, 12)
    if shape == api.shape then
      for _, bind in ipairs(binds) do
        local row = api.rows[bind.id]
        if row and row.on ~= bind.on then light(row, bind.on, true) end
      end
      return
    end
    api.shape = shape
    local before = {}
    for id, row in pairs(api.rows) do before[id] = row.on end
    table.clear(api.rows)
    for _, child in ipairs(body:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
    title.Text = moving and "Keybinds  ·  drag, then lock" or "Keybinds"
    if #binds == 0 then
      text(body, "Nothing bound yet", 12, "medium", { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.faint, LayoutOrder = 1, ZIndex = 3 })
      return
    end
    for index, bind in ipairs(binds) do
      if index > 12 then
        text(body, "+" .. (#binds - 12) .. " more", 11, "medium", { Size = UDim2.fromOffset(0, 16), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.faint, LayoutOrder = index, ZIndex = 3 })
        break
      end
      local line = box(body, { Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = index, ZIndex = 3 })
      local wash = box(line, { Size = UDim2.new(1, 10, 1, 2), Position = UDim2.fromOffset(-5, -1), BackgroundColor3 = P.white, BackgroundTransparency = 1, ZIndex = 2 })
      round(wash, 8)
      local inner = box(line, { Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 3 })
      list(inner, 8, true)
      local chip = box(inner, { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = P.raised, BackgroundTransparency = 0, LayoutOrder = 1, ZIndex = 3 })
      round(chip, true)
      pad(chip, 0, 7, 0, 7)
      local pop = Instance.new("UIScale"); pop.Parent = chip
      local key = text(chip, Config.keyLabel(bind.key), 10, "bold", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, TextColor3 = P.sub, ZIndex = 4 })
      local name = text(inner, bind.label, 12, "medium", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2, TextColor3 = P.dim, ZIndex = 3 })
      if bind.kind == "toggle" and bind.mode == "hold" then
        text(inner, "hold", 10, "medium", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 3, TextColor3 = P.faint, ZIndex = 3 })
      end
      local row = { chip = chip, key = key, name = name, wash = wash, pop = pop }
      api.rows[bind.id] = row
      local was = before[bind.id]
      light(row, was == nil and bind.on or was, false)
      if was ~= nil and was ~= bind.on then light(row, bind.on, true) end
    end
  end
  return api
end

-- ---------------------------------------------------------------- switching to it, and back
-- Novoline's pieces, for the panels of other files drawn in this look (dahood_hunt's)
N.parts = { P = P, TINT = TINT, box = box, round = round, rim = rim, text = text, entryBox = entryBox, hit = hit, glyph = glyph, list = list, pad = pad,
  glass = glass, tile = tile, tween = tween, HOVER = HOVER_INFO }
function N.start()
  Config.define("app.novoline.accent", ACCENT)
  Config.define("app.novoline.font", "gotham")
  Config.define("app.novoline.size", 100)
  Config.define("app.novoline.dock", false)
  Config.define("app.novoline.island", true)
  Config.define("app.novoline.shade", 100)
  Config.define("app.novoline.x", -1)
  Config.define("app.novoline.y", -1)
  Config.define("app.novoline.px", -1)
  Config.define("app.novoline.py", -1)
  Config.define("app.novoline.w", W)
  Config.define("app.novoline.h", H)
  for _, id in ipairs({ "app.novoline.x", "app.novoline.y", "app.novoline.px", "app.novoline.py", "app.novoline.w", "app.novoline.h" }) do Config.unshared(id) end
  Config.on("app.gui", function(look)
    if look == "novoline" then
      Window.show(false)
      N.show(true)
      N.island()
    elseif N.built then
      N.show(false)
      if N.bar then N.bar.Visible = false end
    end
  end)
  Config.on("app.novoline.accent", repaint)
  Config.on("app.novoline.font", function() refont() end)
  Config.on("app.novoline.size", function() if N.rescale then N.rescale() end end)
  Config.on("app.scale", function() if N.rescale then N.rescale() end end)
  Config.on("app.novoline.dock", function(keep)
    if not N.built or N.open or not N.active() then return end
    N.bar.Visible = keep == true
    if keep then N.paintNav(true) end
  end)
  -- a tab added or taken away later (a game's tabs) shows up here as well
  local rebuildNav = Window.rebuildNav
  Window.rebuildNav = function(...)
    rebuildNav(...)
    if N.built then N.rebuildTabs() end
  end
end
end


-- ============================================================================
--  api.lua     init, boot, toggle key, and the friendly NovolineUI API
-- ============================================================================
do -- api.lua
local S, util, Config, Window, Assets = B.S, B.util, B.Config, B.Window, B.Assets
local UIS = S.UserInputService
local Novoline = B.Novoline

-- ---- friendly helpers -----------------------------------------------------
local autoFlag = 0
local function flagOf(opts)
  if opts.Flag then return opts.Flag end
  autoFlag += 1
  return "auto.flag." .. autoFlag
end
local function keyNameOf(k)
  if typeof(k) == "EnumItem" then return k.Name end
  return tostring(k or "None")
end

-- ---- config defaults (called after Config.init so saved values win) -------
local function defineDefaults()
  Config.define("app.key.menu", "RightShift")
  Config.define("app.key.panic", "None")
  Config.define("app.scale", 100)
  Config.define("app.window.x", 0.5)
  Config.define("app.window.y", 0.5)
  Config.define("app.freeCursor", true)
  Config.define("app.sfx", true)
  Config.define("app.sfxVolume", 45)
  Config.define("app.motion", "full")
  Config.define("app.motionSpeed", 100)
  Config.define("app.island", true)
  Config.define("app.keyHud", false)
  Config.define("app.keyHudLock", false)
  Config.define("app.keyHudX", -1)
  Config.define("app.keyHudY", -1)
  Config.define("world.hopMode", "random")
  -- only the Novoline look ships in this standalone build: force it.
  Config.define("app.gui", "novoline")
  if Config.get("app.gui") ~= "novoline" then Config.set("app.gui", "novoline") end
end

-- ---- boot (mirrors the original 90_boot order) ----------------------------
local booted = false
local function boot()
  if booted then return end
  booted = true
  if not game:IsLoaded() then game.Loaded:Wait() end
  Config.init()
  defineDefaults()
  if B.Prefs then B.Prefs.apply() end
  Assets.init()
  if Novoline then Novoline.start() end          -- defines app.novoline.*, wraps Window.rebuildNav
  Window.build()
  -- deferred tab registrants (e.g. the "Keys" tab from 51_keys)
  for _, register in ipairs(B.pages or {}) do B.try("pages", register) end
  Window.rebuildNav()                             -- also rebuilds novoline tabs once built (N.start wraps it)
  Config.listen()                                 -- keybind toggles / hold panels

  -- the menu key, the command palette, and the panic key
  B.connect(UIS.InputBegan, function(input)
    if Config.capturing then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if UIS:GetFocusedTextBox() then return end
    local name = input.KeyCode.Name
    local menu = Config.get("app.key.menu")
    local panic = Config.get("app.key.panic")
    if menu and name == menu then
      Window.toggleActive()
    elseif panic and panic ~= "None" and name == panic then
      B.unload()
    elseif input.KeyCode == Enum.KeyCode.K and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) and Window.anyOpen() then
      Window.palette()
    end
  end, "novolineui.keys")

  -- prebuild every tab quietly in the background so the first visit never stutters
  task.delay(0.7, function() if B.alive then Window.prebuild() end end)

  -- reveal
  Window.showActive(true)
  if Novoline and Novoline.active() then B.try("novoline.island", Novoline.island) end
  if B.Keys and B.Keys.hud then B.try("keys.hud", B.Keys.hud) end
  B.bootMs = math.floor((os.clock() - B.bootClock) * 1000)
end
task.spawn(function() B.try("novolineui.boot", boot) end)

-- ---- control playback: maps friendly spec -> novoline Section method ------
-- A section proxy buffers controls until the page is actually built; if the
-- section already exists (tab added after boot), the control is drawn at once.
local function playControl(sec, kind, o)
  o = o or {}
  local flag = flagOf(o)
  local cb = o.Callback
  local info = o.Info or o.Desc
  local function draw(s)
    if kind == "Toggle" then
      return s:toggle({ id = flag, label = o.Name, desc = info, default = o.Default == true, changed = cb, tip = o.Tip })
    elseif kind == "Slider" then
      return s:slider({ id = flag, label = o.Name, desc = info, min = o.Min, max = o.Max, step = o.Step,
        default = o.Default, decimals = o.Decimals, suffix = o.Suffix, format = o.Format, changed = cb, tip = o.Tip })
    elseif kind == "Dropdown" then
      return s:dropdown({ id = flag, label = o.Name, desc = info, options = o.Options, default = o.Default, changed = cb, tip = o.Tip })
    elseif kind == "MultiDropdown" then
      return s:multi({ id = flag, label = o.Name, desc = info, options = o.Options, default = o.Default, changed = cb, tip = o.Tip })
    elseif kind == "Segmented" then
      return s:segmented({ id = flag, label = o.Name, desc = info, options = o.Options, default = o.Default, changed = cb, tip = o.Tip })
    elseif kind == "ColorPicker" then
      return s:color({ id = flag, label = o.Name, desc = info, default = o.Default, changed = cb, tip = o.Tip })
    elseif kind == "Keybind" then
      return s:keybind({ id = flag, label = o.Name, desc = info, default = keyNameOf(o.Default), changed = cb, tip = o.Tip })
    elseif kind == "Button" then
      return s:button({ label = o.Name, text = o.Text, desc = info, run = cb, style = o.Style, tip = o.Tip })
    elseif kind == "Label" then
      return s:label(o.Name or o.Text or "")
    elseif kind == "TextBox" then
      return s:input({ id = flag, label = o.Name, desc = info, default = o.Default,
        placeholder = o.Placeholder, numeric = o.Numeric, changed = cb, tip = o.Tip })
    elseif kind == "Note" then
      return s:note({ text = o.Info or o.Name or o.Text, icon = o.Icon, rich = o.Rich })
    elseif kind == "Custom" then
      return s:custom({ name = o.Name, height = o.Height, build = o.Build })
    end
  end
  if sec.section then
    return draw(sec.section)
  else
    sec.controls[#sec.controls + 1] = draw
    return nil
  end
end

local CONTROL_KINDS = { "Toggle", "Slider", "Dropdown", "MultiDropdown", "Segmented",
  "ColorPicker", "Keybind", "Button", "Label", "TextBox", "Note", "Custom" }

local function makeSectionProxy(tab, name)
  local sec = { name = name, controls = {}, section = nil }
  tab.sections[#tab.sections + 1] = sec
  local proxy = {}
  for _, kind in ipairs(CONTROL_KINDS) do
    proxy[kind] = function(self, o) return playControl(sec, kind, o) end
  end
  return proxy
end

-- ---- Tab object -----------------------------------------------------------
local Tab = {}
Tab.__index = Tab
local function newTab(win, name, icon)
  local tab = setmetatable({ name = name, icon = icon, sections = {}, defaultSec = nil, page = nil, id = nil }, Tab)
  autoFlag += 1
  tab.id = "novolineui.tab." .. autoFlag
  tab.defaultSec = makeSectionProxy(tab, name)
  Window.page({
    id = tab.id, title = name, icon = icon or "circle",
    build = function(page)
      tab.page = page
      -- default (unnamed) section first
      local ds = page:section({ title = name, icon = icon })
      tab.defaultSec.section = ds
      for _, c in ipairs(tab.defaultSec.controls) do c(ds) end
      -- named sections
      for _, s in ipairs(tab.sections) do
        local sec = page:section({ title = s.name, icon = s.icon })
        s.section = sec
        for _, c in ipairs(s.controls) do c(sec) end
      end
    end,
  })
  return tab
end
function Tab:Section(name, icon)
  local proxy = makeSectionProxy(self, name)
  self.sections[#self.sections].icon = icon
  return proxy
end
-- proxy every control to the tab's default (first) section
-- FIX: self.defaultSec is the section PROXY (no .controls field); passing it straight to
-- playControl crashes with "attempt to get length of a nil value". Route through the proxy's
-- own method, which captures the real section object that has .controls.
for _, kind in ipairs(CONTROL_KINDS) do
  Tab[kind] = function(self, o) return self.defaultSec[kind](self.defaultSec, o) end
end

-- ---- Window object --------------------------------------------------------
local WinObj = {}
WinObj.__index = WinObj
function WinObj:CreateTab(name, icon) return newTab(self, name, icon) end
function WinObj:ToggleKey(key)
  pcall(function() Config.set("app.key.menu", keyNameOf(key)) end)
  return self
end
function WinObj:Show(on) Window.showActive(on ~= false) return self end
function WinObj:Toggle() Window.toggleActive() return self end
function WinObj:Unload() B.unload() end
WinObj.Destroy = WinObj.Unload
function WinObj:Notify(opts) if Window.toast then Window.toast(opts) end end

-- ---- library entry point --------------------------------------------------
NovolineUI = {}
function NovolineUI:CreateWindow(opts)
  opts = opts or {}
  if opts.Name then B.TITLE = tostring(opts.Name) end
  if opts.Key or opts.ToggleKey then
    pcall(function() Config.set("app.key.menu", keyNameOf(opts.Key or opts.ToggleKey)) end)
  end
  local win = setmetatable({ name = opts.Name or "Novoline UI", tabs = {} }, WinObj)
  return win
end
function NovolineUI:SetToggleKey(key) pcall(function() Config.set("app.key.menu", keyNameOf(key)) end) end
function NovolineUI:Unload() B.unload() end
NovolineUI.Destroy = NovolineUI.Unload
-- raw access for advanced users
NovolineUI.B = B
NovolineUI.Window = Window
NovolineUI.Config = Config
NovolineUI.Novoline = Novoline
end -- api.lua

return NovolineUI

--[[
-- ============================================================================
--  FULL EXAMPLE  (paste into your script after loadstring)
-- ============================================================================
local NovolineUI = loadstring(game:HttpGet("https://your-host/NovolineUI.lua"))()

-- CreateWindow opts: { Name, Key (Enum.KeyCode or string), ToggleKey }
local win = NovolineUI:CreateWindow({
  Name = "My Script",
  Key  = Enum.KeyCode.RightShift,   -- or "RightShift"; defaults to RightShift
})

-- ---- Tab 1: every control type (added to the tab's default section) -------
local main = win:CreateTab("Main", "flame")

main:Toggle({
  Name = "Enabled", Flag = "main.enabled", Default = true,
  Info = "Master switch for the feature.",
  Callback = function(v) print("Enabled:", v) end,
})

main:Slider({
  Name = "Speed", Flag = "main.speed", Min = 1, Max = 200, Default = 50,
  Suffix = "%", Info = "How fast to go.",
  Callback = function(v) print("Speed:", v) end,
})

main:Dropdown({
  Name = "Mode", Flag = "main.mode", Options = { "Fast", "Balanced", "Safe" },
  Default = "Balanced", Callback = function(v) print("Mode:", v) end,
})

main:MultiDropdown({
  Name = "Filters", Flag = "main.filters",
  Options = { "A", "B", "C" }, Default = { "A" },
  Callback = function(v) print("Filters:", table.concat(v, ",")) end,
})

main:ColorPicker({
  Name = "Accent", Flag = "main.color", Default = Color3.fromRGB(230, 30, 30),
  Callback = function(c) print("Color:", c) end,
})

main:Keybind({
  Name = "Action key", Flag = "main.actionkey", Default = Enum.KeyCode.F,
  Callback = function() print("Action key pressed") end,
})

main:Button({ Name = "Run thing", Callback = function() print("clicked") end })

main:Label({ Name = "This is a label" })

main:TextBox({
  Name = "Name", Flag = "main.name", Default = "hello",
  Callback = function(v) print("Text:", v) end,
})

main:Note({ Name = "Tip", Info = "Right-click a toggle or keybind to bind a key." })

-- ---- Tab 2: named sections ------------------------------------------------
local settings = win:CreateTab("Settings", "settings")
local gen = settings:Section("General")
gen:Toggle({ Name = "Auto-save", Flag = "set.autosave", Default = true })
gen:Slider({ Name = "Volume", Flag = "set.volume", Min = 0, Max = 100, Default = 45 })

local adv = settings:Section("Advanced")
adv:Dropdown({ Name = "Theme", Flag = "set.theme", Options = { "Dark", "Light" }, Default = "Dark" })

-- ---- window helpers -------------------------------------------------------
win:ToggleKey(Enum.KeyCode.Insert)   -- change the open/close key at runtime
win:Toggle()                          -- open/close programmatically
win:Notify({ title = "Loaded", text = "NovolineUI is ready.", icon = "check" })
-- win:Unload()                        -- remove everything
]]
