--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  EGOY UI Library  (liquid glass edition)                     ║
    ║  Extracted 1:1 from EgoySaeHub — same layout, colours,       ║
    ║  fonts, glass layer, animations, toasts, splash, config.     ║
    ╚══════════════════════════════════════════════════════════════╝

    local Library = loadstring(readfile("EgoyUI_Library.lua"))()
    local Window  = Library:CreateWindow({ Title = "MY HUB", Product = "My Game", ... })
    local Tab     = Window:AddTab({ Name = "Main", Subtitle = "stuff", Icon = "egg", Group = "Autofarm" })
    local Sec     = Tab:AddSection("Section")
    Sec:AddToggle / AddSlider / AddDropdown / AddInput / AddButton / AddKeybind / AddLabel / AddNote

    See EgoyUI_Example.lua for every option.
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    pcall(function()
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end)
    LocalPlayer = Players.LocalPlayer
end

-- ───────────────────────── embedded default logo (light / dark) ─────────────────────────
local LOGO_LIGHT_B64 = "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"
local LOGO_DARK_B64 = "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAYU0lEQVR42u2dW4wk11nH/19V91x31o4vRHLAOCIYJEeEkEQ8IdZSkMBCwglkEEhgK4AlLEUiYIMQD7vzgOQnyAuREIEgsA3sWuIiReEhYidxiJIH44dgQRJjnJiwNiPvZXauPV3n46Frdnt6qrvrVJ1TXef0//eyvT1dVae7zvlu9T/nAIQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEkCEk5MaragIg4W2szyZ/glo8LMgAUf4ShBBGAL49v4iYK/t67uwSzl3bhxFBYvJwwIx83gBIDGAK/mjGXGPiuUbfz980xuKYstcxxce0vs0jH3DS5vwPJsnvp2WbJ15/5OBp50oFavLjFhYAc4BPP3KfbKmqiIQTCXQCNVyDe2bwyArwdLZ8+4uM/vLq4XXR3zS3purh3C7b7KqdTbRZx11HLc6hlt9Fy7ct6wNnFoE3/w9fT3fwzLFjCmkghWoABjdBsLMH9Lf30T/+LhNvnlp0ZIuOAI+drKjNth1exgx+0THvj7z2PZDK/H6mxHkbv+eCrL+CVIEnH3lQDi+qpqGNoaANgAgSyb+DCDonOuzo6/wNnZD33PqbAioTzjXt+EnHlDz3pGuO/ZwCIsWfGc33ZOgDMiYnlDEDZrplHnzHsp+FTB+kYneqE/e81DET7suYA7OVNSzevI7Nn7tPvpx7/yzEUDpYTAUPUydsRc1w1MrDjLm4bahbu822EY7Wi1Ym3if11Oay1x/6/RSQLAOSLjYA4FKg9bSgI4AE471d5QGvdh2hVkeadIx6arNt51dPBsu2nqCe2lxwsqnORJGtnEW6M/D+m6F6/+AjAB8e2qoj2Ax4tej8vto8xkPXbXOlAW8Tlamja45LV+zvuZgIvH/wEYBx6aHVQ6jYQHjeipTCZ3iult9Z/bZZI/L+UUQAjXcEn+G5bUqhntpsa+R8hucVBr/zNp98LSYDFiLw/sFHABhXA2hR0c/59X2nFA48tLOUwtejWLUv+h17/9WIvH90NYAqz+S9eWhtUXiOdhf9Gk0pKkYVGlnuH2UNwLoj+iz6tSGlKBHqVvbQtimFr/C8IYESIvT+8dUAPFf8vXhorWAwGgzPnRg5n+F5QylFjN4/+AggMUM1gAYq/iEU/VynFI16aNuUwmeh9+R1stWzSG9ex+ajEXn/4CMAk7Sr4t+Gol+l8LxGSuGszba/mc+K/8jvd6z6SyPz/sFHAHDRkRymFJT51kgpWiTzHWnXref+sXn/8GsApkXhuaeogjLfGm2uWOspeu4fo/ePJgIYNxeAMt/wwnOnRk7rtVkj9/7hRwCgzJcyX69tjtr7Bx8BGNcdwWd4TplvvQijGZnvCe+/Grn3jyICcFoMosy3uZSibTLfkffnwfsHHwFMWw+AMt8aHnrOZL4jB82F9w8+AjCgzJcy3/pRBQq8fzYH3j/4CAAuwnPKfOsZuQhkviN/y1bOIt2dA+8fVQ2gcnhu0/ko820upWhK5jvy+jj31znw/tFEACdWdvUUnlPmG6fMd+Rct7z/R+bA+0cRAVDm6y88j17mi+Ln/vPi/YOPAExT4bmnqIIy3xptrljr0fHXzpbPIt2bI+8fTw2AMl/KfOu3WXROKv/RRABTdQB1Oz9lvs2kFLaG2XWb8+f+81L5jyYCMKDMlzLf+hHGLdWfzJf3Dz4CgE1HoMy3uZSi5TLfkYOy1TWkN29g86Nz5v3jqQG49NCU+cYt8y3y/gaQOfT+UUQAOq0G0EKZr95+zxz/SeB3e22Xubk6GPy2KYULaXfBMdnKGjo717H50XfNn/ePKgWonVuiOZnv8QeWV5EkqX2eq1UHUok2Dxsj1+euXE+otn/fxHuugy+bdjqAJPPp/YM3AKbk4Gtb0U8VmnYg+3t4WRXXRQaf0dEvNeV7jvn4RA9d9jgd+WwyrS0G0KTkMWb672ZKGsOiz5e5Nyowi0tIdrfxrfy5v8yb948mAhhOAaqE5zMo+uniEuTwEE++b1W+CjJzRETn8XsHrwNwIciZRdFPAfQNVlU1eQlIPwBkHIYzG/xmXr97fNuDByTzTQAjIuaiqnxwjjshma0TjYIQZb6E0AA4CAFClfky5ic0AC48v4fwvHJKYaGaS/vsgIQGoFbrQ5P5KiZrFAihASibAZgSOwKNjNZZy3yHP5B12AEJDYDXxrduNV8taSQIoQEoN8DryE8LB6zP1Xw5+AkNgKMUAOGt5svBT2gAPEUChQO2Zav5EkID0JAhCGU1X0JoAFwN+qoeviWr+RJCA+Ag9G/rar4c/IQGwBGmgfDc9Wq+hNAAOG586Kv5EkID4KEYEMxqvoTQAFRLAWwXpJz1ar4c/IQGwIPnb03F36Lo1+dsQEID4Dbyn6nM13KzDc4FIjQATRoGzzLfKikFITQAHrz/LGS+ysFPaACaw9gM+BnJfCfWANj/CA1A/caHIvO1WjSEEBqA6ilAJQ9dU+ZbJaUghAbAQQrgIjxvxXJhhNAAOIgEWiLz5YAnNAAzSgNaIfNVGgbSXjpRDv4ZyXxrRRWkvX1M9dbes7FtIhrV3oDW4bljma9y8EfDedXkHJBs5vs3Dt1YOb+J9KEt6Pp6+NuJR6NGbZvMd9o1aQja6+0vXUKyLpJt5D7m4n/pHd27ILgT+IjI9Y1cwqGqcgGQjYA3dg17e/ChvQGlhTJf5aAPbfAnubfPnvuu/vDCAn42M/jpXob3He0hxT7w/Jv6KoAviuDvReQrAPSiarouYUYDwacAtzy/tEDmaxNh0Bq0LuQXEfOZ/9C1O+7BH6rgiYVlLPb7AA5u367OAj6UdvGhox6e+tst/fz2Nn5rXeSbQ8aDBqC5EKBCSO9T5qv1jASZref/69f1x5bX8JnFFbx/+yrQO0A/Dy5v9bT+EVQHvidZvQM/c0bx43/5bf1NEbkYYiQQtgEwdgNuFjLfSfUEI0gvq3b2gfTyUKWZlOMckNWtyp9XTQTQ59/UdyaCf+50ce+Nt3Ekgq4IOnlwOXwPRXKDcPMasu4C7jrzDvzdn39br66LfCE0IxBFEXD4JrVJ5jsppch70bWHRfrgvKCZcSG/HZrh2aU13LtzA0eSoFvmnicJ0v4RMhxAFhbw7Gf/W3/0Y8Bb51WTUAqDceoA0D6Z78jx0usBmeITL76tryOBwAw+YvLMxkwOeE68aZJBQdQUfH7SuYr+duJ9U+GYBtqcZdDlVcj+Hv5i/V3yHVWVKpGAqqYikv3N/+jjZ+7Ch29cRX948Je55yJIjw7QX7sb77zZxzMi8vhF1WAEdtHoANom850UVYhAjg6B1bN4rNOxN17HEY9WqFWoba1C7c87vGGrYMwGrmpx7qGTGAW6C8CNLfSwiz+p6z/Oqybmu3iyd3gikLSLJAXp7g2opPiFP31df39d5EpVo0QD4DoqmLHMd9xAEgF2tpFJQWmiTJvNhNpG2UGKGoO/7LknDaQqUZkC/bU70ckM/mj9Qdm6rNqRQRpln/uLmOfe0B/sLOJHDvYG3ryKYReBZBmy1TuxqtfxUwD+ahNIQ0jtwtYBTKsBzFjmOy2lOO5wqHB9KSqAFPwWMq5YgpLHlKy7yNCjWClxsErxNQuPP3nupHcAQPAPALBV8cHKOSDZAAwS/OTiChZ715ElgrSGunMQqMjAAGwF8sAnDh3AlJtlE56X8nY+Uwp11+bKBqti6F/FsFo9ilWYhWUkB/t4FVfxch5mZzX70PdLMrAvVe75sE3OMkCB+wHglUAMQJTTga07ooeFPSp1fvXUZtvBp57qCai3c5MCprsEqOC59fdKLw+z6/YbrXPPTx2chSX1iHJV4FnLfL17aLUc8GphsNTTXIpxBTSLNkuC9GAXPUnwbB7G137Ulgquq7oxWCIABDcA4KFymRQNgGvv37aKv/M223p4XymF5e9XO6VQZIsrkN4hXn7le/BaXentUI7+xcM9GKCgAGinHVFJAFVsAsC9NADtGfy1O6+D8NyZjkD9SZOrzGVwmVJMuqYBtNsFEsELGyJms2bfXRfJVFXesYN/7x3itYUlQPVkRGHzmwmQ7u+g3zf4PABsOohOaACmF3Cq5Za2HdFneN6GlMJBeO7CYI07t1Fo2kFndxvbSQ/P5eF/bbntJpA+8qAcQvDc0hmIGTIANr+fyZAtr0GOevjXJx7AN0JSAkazN6DVgIsgPHdq5NpY8R/OrQGztALNMrz48w/IlTz8r11sOwdk51WTxWX88c41vLa4gtQYZDaLuKqBph1o7xCZdvE7IqIXAho6we8LoGiRzFdbkFJ49NBNVvyHX6sCSQqB4IXcczvpt8eDdf0uuZH18ctQSLc7MAKlojKFEUF29h50Dvbw1G/cJy9dHMiLDQ1AwylAKW/TYNHPaXheYfA7b7Ptb+YopVCFpgtId7axBcXnXIX/Q0bAXFRNf/X75GsHe/h4uoCbK2tIjUFfFZnqyM+qUKMwatDvdJEsnUHn6lv41BPvlk+FOB043mXBZ1z0c5ZSaDMa/1kU/UpeP1teBbIMn1u/T7byCTxOn7Wvi2QXVdPH75fP7m7jnDH42trd6KysIe10IaowUBhVGKSQpVUka3ejgwT/u7eLX/z1++WT51WTEFcFinp34JCKfk2H51WiCi86gmmGWZFk2aD6D1W55KmfHBuBjz8g//YvL+AnDnbw2FEP/6SKtxdWkCyuIlk6g0QEe0eH+MrhHp6+uY33/9r3DhYCCXVdwCAXodB8AsjLN/TCnWdx/toN9EUGsuamZL6znIVXpc0unsnb5v11Jw8ZhXYXIP0jXFno4IcevVdu+p5lN1rB/7Pv6F3dDt4LQdrpAGmCV3/pbnnj+O8hrwcIRDIbUDyH5048PGW+VVKKbGkVnZtX8fyj98rNqjP/bNgQMcdLf184ByMiVwF8acQByYXB3zORsJcGj2I9AJ0QjpYePJT51kujPOgIRJD09mGSBJeA6jP/KlQGdQPob+SD/dJQqvzKBWhe5e9vROA8o5gOjCq5ZZ3OT5mv/5mDxzP/dvFqct3NzL9qtkAUDp86BDWGgqgHoObCFA7Cc8p83Rs5BUx30e3MPxKZATheD0DqdH7KfBtJKawMsw609Qe76KUddzP/SIQRwKk15yjzreShZyXzHWPYs8VVyJGjmX8kYgMATO5RlPl6SikcV/xHIhbtdgFJ3Mz8I7EaAFNjZVwbb0uZb2MphTG3Z/71HM78IzEagKTcxqCU+db30JXaXM3gmKUVaD/Di7/icOYfidAADOsAKPOtF1XMROZbcF9uzfxL3M78IxEagMRMLwNwNV9HbYZfHUH+XbWzgHR3G1uph5l/JLYUYEpnpMzXUUoBLzLfojZny6tA3+PMPxKBAdgcSgFK6QAo861lcLwV/VA88w+J35l/JMIIgDJff+G5t5Ri6D9God1FJPs7uLLSwZcgoh+j+IcGoHY6QJmvq/DcrZE7fYJsaRVQPTHzj+E/DUCNGgBlvo2kFFWLfsP/FUFyuA+jTc/8m3M6MQx+m41BKfN1eH1XUcXxzL89vNqZ4cw/GoDAGLseQCAyX6MwMjyGbCSzgazqM3q8KT53v7OABd0fzPy7rNpBAFtr0wC0JH8ZFwVU8dCNyXwVWF5BknRO58N1lgurrSDMt+4ufW51YFgSpEdHQJcz/2gAXBYEWivzVWjSgRzs42UDXBcAaiafz5SMKk4do9M9eeF1pn1Pc/rzZfP+kWuYpWUkh/v45jfuw2t5+E8DQANQLgU44f0DkfkqoAvLkKMdPPnhe+Sr7Ia32eBPQANQyemHJvNV4EixqqrJS0D6AUpeQc9PA1DNAGi+NzsCkvkqkAAm35lGPsjOT2ZAXNuDu/TQDaUUhNAA1KgBAMW7m4Qo8yWEKUDNKMBm8M9a5ksIIwDHjQ9R5ksIDUDFFCB0mS8hNAA+04KAVvMlhDUAlzWAlq/mS7E7YQTQkOefOGBnvJovITQADrx/iKv5EkIDUBEzYaSGsJovIawB+KwBIJDVfAlhBOCg8SGu5ksIDUDFFMAEvpovITQADlof4mq+tAKEBmB2NYCZzxykASA0AHVzgGq5OSoM/sopwbjjhZ2P0AA49f5tlvmWNSyE0ABUCADaJvNVDn5CA9CCGsCMZb4c/IQGoMHGt0nmSx0AoQHwnAK0VeZbdoddQmgAPKQBrZH5cvATGoCGawBtkflOSSm4HgChAZjB4K/s4T2lFITQALgwBm2R+YIFQEID4J2yG1nOouiHCoaBEBqAqmlAW2S+yrUBCA1AY413IchpqujHPIDQAHhKAVzk443qCGgACA2A4zTAZXjegI6AEBoAx4PfdXjuK6qgISA0AB4Gf5tkvtwVmLSdTkxfptUV/yHPf+tvgvSyamcfSC8rlwhpC5sVjtkQZIAoDUCDmBKD33V4XimlKEAEgOLawyJ9UBVMaACq5y9tlvmOMSzS6wFG8Yl/fEtfByDGQBMUb3Zi8u9qSr5/wjiOfKjquQqPMUCSDP6dZJwrfZehN9rYZtXbt7OzANzcw6f/4EHZUlURCScSCD4FqLIxaFMy37FRhUCOesDqWTyWdvO6g+RtLjOXQU4+SizVZovvqBgEs+rh3C5WcB597fPck85rMmD5DuDtN/D1M8Az51UTETGMABpMAdoq852WUogAu9vIbjVVLVcwVrs2a802V1lmXeu0GdVmddoYLBkyIBNf6+n38xNk/SOkxuDJ335QDi+qpkwBZh0JtKzoNzFiEaQy7HULXhcdL/kHSh2jgxWIp11n6jWLXmteyyg4/tQxU9p86vgx5y58rbdXWRbLNmPkuqde5wePvq+KbOkMFve3sfnUD8iXz6sm6yJZqGl00JgqIaDPop9tSqH1Ugp1ZeTUU5tt0yif6znYtHlyJCl5PWEDAB4abz9pAPyP/Aod0WfRbwYphW14XjelsPrOvrZtq7ETdJ02qyJbWkNyuIPNT75bNkP1/lFEALYe2rvMV0t2Xts22xoch7l5LSOnbtpcO8JwGFXE4v2DNwAm8R+eV4kqvOgIfIXntimFtqDNtlFZhXs+7m8mIu8fvAFIDFov83Xi4X2G521IKWx/M587QU+/59F4/yhSANTpSJjBzEEPHrpySuEoPK+dUjRQ9HMRlakiW15DchCJ9w8/BUD959tOwnPLqMJLSoH2VvydeegaRb86KcXQ40IxBkgj8f7RRACKVsl8Z5NStLjiH0LRb5p2VxXZYmTeP8oUYNYy37rheaXO7yulQDMphXPD7CGlEEBMBmhE3j/+GsCMZL51UgqvHtqRjsBJeF4zqnDS5pLXP/b+hzvYfDoi7x+FAdAar6t46FlX/Cu32fb381nxb3jykAPDLCYD0jQu7x+8ATAz8NCU+dY0OGHIfE/k/ktn4nnuH5UBSFx4aMp8KfOdVEfSvPIfofePMwWgzLd6m0GZb8yqv6hTgCrhuVXno8y3uZRiRjLf0TZL5N4/igigckegzJcy30lGYg68fzQGwFdHoMx3fmS+w69Vb6v+NGLvH0cNwOeW4LadjzLf4GS+hYY2f+6/H+Fz/7hrAC5zywrhOWW+NQwzZiPzHbNWoBgDSOTeP64agEvP5Sk8r9RmynwbTSmGNf+xe//gDUDShvCcMt+gZb4FUdnceP8oUgDKfCt0fsp8iw3cnHn/qFIAlx1hVuE5Zb6OjFzFlAKA6Bx5/2gMgIIyX8p8K7R5OJrMn/vPk/ePMgKgzNeRkYtc5jv6+8mc5f7RGADKfEsaDMp8x0cVc+r9gzcAZkKoS5lvAymF7W/WEpnvaFQxr94/qhpA3cFPmS+il/kWtXmeVH/RGYCkjhew7XyU+QYv8y1q87H3T+bQ+wOB7w6sCqOKTIAMZrABbek8scZAcrm9tmnR9tpetgSv6aHLRBU1lobPltbQ2dvG5u+9Z/68f/gGAFheTZEeLiNNOu6KYZP2hp86MHwZFp/pjY5854baXPXeWJ+3YPDn4X+adOfX+wdrALaO72mC/9w5wuX9PWQA0mlhoCnpoU8dg5LHGItj1PI6Ez5/qsOb4uSu8Bhzohh26tpmioeWoqhmgocebpqxTEPMyIvSxxQbFtNZRnLwNr71u++RTVUVmTPvTwiZc4IOeVRVMIdhmysu8CcAAGyIGP4KhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQAP8PUaA+6tMb3zkAAAAASUVORK5CYII="

-- ───────────────────────── static tables ─────────────────────────
local THEMES = {
    Dark = {
        bg = Color3.fromRGB(10, 14, 30),
        rail = Color3.fromRGB(18, 24, 48),
        card = Color3.fromRGB(30, 40, 76),
        lift = Color3.fromRGB(44, 58, 104),
        fill = Color3.fromRGB(54, 68, 120),
        line = Color3.fromRGB(120, 140, 210),
        text = Color3.fromRGB(242, 246, 255),
        dim = Color3.fromRGB(170, 184, 220),
        mute = Color3.fromRGB(112, 126, 168),
        accent = Color3.fromRGB(96, 210, 255),
        accentDeep = Color3.fromRGB(32, 84, 132),
        accentHover = Color3.fromRGB(140, 228, 255),
        ink = Color3.fromRGB(6, 12, 26),
        ok = Color3.fromRGB(110, 231, 183),
        Brand = Color3.fromRGB(242, 246, 255),
    },
    Light = {
        bg = Color3.fromRGB(226, 234, 250),
        rail = Color3.fromRGB(238, 244, 254),
        card = Color3.fromRGB(252, 253, 255),
        lift = Color3.fromRGB(240, 246, 255),
        fill = Color3.fromRGB(222, 231, 248),
        line = Color3.fromRGB(160, 176, 214),
        text = Color3.fromRGB(18, 24, 44),
        dim = Color3.fromRGB(70, 84, 120),
        mute = Color3.fromRGB(112, 126, 160),
        accent = Color3.fromRGB(40, 116, 230),
        accentDeep = Color3.fromRGB(28, 84, 176),
        accentHover = Color3.fromRGB(70, 140, 242),
        ink = Color3.fromRGB(250, 252, 255),
        ok = Color3.fromRGB(30, 140, 96),
        Brand = Color3.fromRGB(18, 24, 44),
    },
}

local FONTS = {
    title = Enum.Font.BuilderSansBold,
    mid = Enum.Font.BuilderSansMedium,
    body = Enum.Font.BuilderSans,
    mono = Enum.Font.RobotoMono,
}

local ACCENT_PRESETS = {
    Aqua = { Color3.fromRGB(96, 210, 255), Color3.fromRGB(36, 90, 140), Color3.fromRGB(140, 228, 255) },
    Violet = { Color3.fromRGB(176, 140, 255), Color3.fromRGB(70, 48, 140), Color3.fromRGB(200, 170, 255) },
    Rose = { Color3.fromRGB(255, 128, 176), Color3.fromRGB(130, 40, 80), Color3.fromRGB(255, 160, 198) },
    Emerald = { Color3.fromRGB(100, 235, 176), Color3.fromRGB(28, 100, 70), Color3.fromRGB(140, 245, 200) },
    Amber = { Color3.fromRGB(255, 190, 92), Color3.fromRGB(120, 76, 20), Color3.fromRGB(255, 208, 130) },
    Crimson = { Color3.fromRGB(255, 104, 104), Color3.fromRGB(128, 34, 34), Color3.fromRGB(255, 140, 140) },
}
Library.AccentPresets = { "Aqua", "Violet", "Rose", "Emerald", "Amber", "Crimson" }

local GLASS_DARK = { bg = 0.24, rail = 0.38, card = 0.46, lift = 0.50, fill = 0.54, line = 0.62, accent = 0.04, accentDeep = 0.10, accentHover = 0.04 }
local GLASS_LIGHT = { bg = 0.14, rail = 0.26, card = 0.30, lift = 0.34, fill = 0.38, line = 0.55, accent = 0.03, accentDeep = 0.08, accentHover = 0.03 }

-- ───────────────────────── small utilities ─────────────────────────
local function copyTable(t)
    local c = {}
    for k, v in pairs(t) do
        c[k] = v
    end
    return c
end

local function sanitize(name)
    local s = tostring(name or "Game"):gsub("[<>:\"/\\|?*]", "_"):gsub("%s+", "_"):gsub("_+", "_"):match("^%s*(.-)%s*$")
    if not s or s == "" or s == "_" then
        s = "Game"
    end
    return s
end

local function trim(s)
    return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function hasText(s)
    return type(s) == "string" and s:match("%S") ~= nil
end

local function detectPhone()
    if UserInputService.VREnabled then
        return false
    end
    local tenFoot = false
    pcall(function()
        tenFoot = GuiService:IsTenFootInterface()
    end)
    if tenFoot then
        return false
    end
    if UserInputService.TouchEnabled then
        return true
    end
    if UserInputService.MouseEnabled == false then
        return true
    end
    local gyro, accel = false, false
    pcall(function()
        gyro = UserInputService.GyroscopeEnabled == true
    end)
    pcall(function()
        accel = UserInputService.AccelerometerEnabled == true
    end)
    if gyro or accel then
        return true
    end
    local preferred, lastType
    pcall(function()
        preferred = UserInputService.PreferredInput
    end)
    pcall(function()
        lastType = UserInputService:GetLastInputType()
    end)
    if preferred == Enum.PreferredInput.Touch or lastType == Enum.UserInputType.Touch then
        return true
    end
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pg and (pg:FindFirstChild("TouchGui", true) or pg:FindFirstChild("TouchControlFrame", true) or pg:FindFirstChild("JumpButton", true) or pg:FindFirstChild("DynamicThumbstickFrame", true)) then
        return true
    end
    return false
end

local function viewportSize()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function phoneWindowSize()
    local vp = viewportSize()
    local w = math.floor(math.clamp(vp.X * 0.7, 440, 560))
    local h = math.floor(math.clamp(vp.Y * 0.74, 340, 410))
    if vp.X > 80 then
        w = math.min(w, vp.X - 36)
    end
    if vp.Y > 80 then
        h = math.min(h, vp.Y - 36)
    end
    return math.max(400, w), math.max(320, h)
end

local function decodeBase64(s)
    if type(s) ~= "string" or s == "" then
        return
    end
    local fns = {}
    if crypt then
        fns[#fns + 1] = crypt.base64decode
        fns[#fns + 1] = crypt.base64_decode
    end
    if syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode then
        fns[#fns + 1] = syn.crypt.base64.decode
    end
    if base64 and base64.decode then
        fns[#fns + 1] = base64.decode
    end
    if base64_decode then
        fns[#fns + 1] = base64_decode
    end
    for i = 1, #fns do
        local ok, res = pcall(fns[i], s)
        if ok and type(res) == "string" and #res > 64 then
            return res
        end
    end
end

-- ═════════════════════════════════════════════════════════════════
--  CreateWindow
-- ═════════════════════════════════════════════════════════════════
function Library:CreateWindow(opts)
    opts = opts or {}

    local cfg = {
        Title = opts.Title or "EGOY HUB",
        Product = opts.Product or "",
        Version = opts.Version or "1.0",
        Tagline = opts.Tagline or "",
        Status = opts.Status or "",
        Game = opts.Game or opts.Product or "Game",
        Discord = opts.Discord or "",
        Website = opts.Website or "",
        Changelog = opts.Changelog or "",
        Author = opts.Author or "",
        Credits = opts.Credits or "",
        Support = opts.Support or "",
        OpenBind = opts.OpenBind or Enum.KeyCode.RightShift,
        Folder = opts.Folder or "EGOY_HUB",
        GuiName = opts.GuiName or "EGOYHUB_UI",
        Logo = opts.Logo or LOGO_DARK_B64,
        LogoLight = opts.LogoLight or LOGO_LIGHT_B64,
        Splash = opts.Splash ~= false,
        SplashSubtitle = opts.SplashSubtitle or "liquid glass edition · loading",
        SearchPlaceholder = opts.SearchPlaceholder or "Filter this page",
        ShowStats = opts.ShowStats ~= false,
        StartMinimized = opts.StartMinimized == true,
    }
    local uid = tostring(LocalPlayer and LocalPlayer.UserId or 0)

    -- state ---------------------------------------------------------
    local themes = { Dark = copyTable(THEMES.Dark), Light = copyTable(THEMES.Light) }
    local T = copyTable(themes.Dark) -- live theme (t3)
    local Flags, Widgets = {}, {}
    local pages, tabButtons, groups = {}, {}, {}
    local groupCount = 0
    local conns = {}
    local logoFrames = {}
    local alive = true
    local phone = detectPhone() -- u42
    local phoneForced = false -- u43
    local winW, winH, railW = 620, 430, 152
    if phone then
        winW, winH = phoneWindowSize()
        railW = 128
    end
    local applying, savePending = false, false
    local currentPage
    local windowVisible = true
    local logoCache = {}
    local W = setmetatable({ Flags = Flags, Widgets = Widgets, Config = cfg }, Window)

    local configIgnore = { ImportPaste = true, CfgSaveName = true, PhoneUI = true }
    if type(opts.ConfigIgnore) == "table" then
        for k, v in pairs(opts.ConfigIgnore) do
            if type(k) == "number" then
                configIgnore[v] = true
            else
                configIgnore[k] = v
            end
        end
    end
    W.ConfigIgnore = configIgnore

    local function track(c)
        if c then
            conns[#conns + 1] = c
        end
        return c
    end

    -- ───────── helpers (tween / new / stroke / padding / hover / icons / logo) ─────────
    local activeTweens = setmetatable({}, { __mode = "k" })
    local function tween(obj, time, props, style)
        local old = activeTweens[obj]
        if old then
            pcall(function()
                old:Cancel()
            end)
        end
        local tw = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
        activeTweens[obj] = tw
        tw:Play()
        tw.Completed:Connect(function()
            if activeTweens[obj] == tw then
                activeTweens[obj] = nil
            end
        end)
    end

    local function mk(class, props, parent)
        local inst = Instance.new(class)
        if props then
            for k, v in pairs(props) do
                inst[k] = v
            end
        end
        if parent then
            inst.Parent = parent
        end
        return inst
    end

    local function corner(parent, r)
        return mk("UICorner", { CornerRadius = UDim.new(0, r or 8) }, parent)
    end

    -- theme-bind: remember which palette role an instance uses
    local function bind(inst, kind, role)
        if not inst or not role then
            return inst
        end
        inst:SetAttribute("th_" .. kind, role)
        local c = T[role]
        if not c then
            return inst
        end
        if kind == "bg" and inst:IsA("GuiObject") then
            inst.BackgroundColor3 = c
        elseif kind == "text" then
            inst.TextColor3 = c
        elseif kind == "placeholder" and inst:IsA("TextBox") then
            inst.PlaceholderColor3 = c
        elseif kind == "stroke" and inst:IsA("UIStroke") then
            inst.Color = c
        elseif kind == "scroll" and inst:IsA("ScrollingFrame") then
            inst.ScrollBarImageColor3 = c
        end
        return inst
    end

    local function stroke(parent, colorOrRole, thickness)
        local role, color
        if type(colorOrRole) == "string" then
            role = colorOrRole
            color = T[colorOrRole] or T.line
        else
            color = colorOrRole or T.line
        end
        local s = mk("UIStroke", {
            Color = color,
            Thickness = thickness or 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        })
        if parent then
            s.Parent = parent
        end
        if role then
            s:SetAttribute("th_stroke", role)
        end
        return s
    end

    local function padding(parent, l, t, r, b)
        if t == nil then
            t, r, b = l, l, l
        end
        local p = mk("UIPadding", {
            PaddingLeft = UDim.new(0, l),
            PaddingTop = UDim.new(0, t),
            PaddingRight = UDim.new(0, r or l),
            PaddingBottom = UDim.new(0, b or t),
        })
        if parent then
            p.Parent = parent
        end
        return p
    end

    local function hover(btn, bgRole, hoverRole)
        if type(bgRole) == "string" then
            if btn and bgRole then
                btn:SetAttribute("th_bg", bgRole)
                local c = T[bgRole]
                if c and btn:IsA("GuiObject") then
                    btn.BackgroundColor3 = c
                end
            end
            btn:SetAttribute("th_hover", hoverRole)
        end
        btn.MouseEnter:Connect(function()
            if btn:GetAttribute("locked") then
                return
            end
            btn:SetAttribute("th_over", true)
            local h = btn:GetAttribute("th_hover") or hoverRole
            local c = type(h) == "string" and T[h] or h
            if c then
                tween(btn, 0.12, { BackgroundColor3 = c })
            end
        end)
        btn.MouseLeave:Connect(function()
            if btn:GetAttribute("locked") then
                return
            end
            btn:SetAttribute("th_over", false)
            local b = btn:GetAttribute("th_bg") or bgRole
            local c = type(b) == "string" and T[b] or b
            if c then
                tween(btn, 0.12, { BackgroundColor3 = c })
            end
        end)
    end

    -- pixel icons (built from frames, recoloured with the theme)
    local function icon(parent, name, color, z)
        local root = mk("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16), ZIndex = z }, parent)
        local function box(x, y, w, h, r)
            local f = mk("Frame", {
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(x, y),
                Size = UDim2.fromOffset(w, h),
                ZIndex = z + 1,
            }, root)
            if r then
                corner(f, r or 8)
            end
            return f
        end
        local function ring(x, y, w, h, r)
            local f = mk("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(x, y),
                Size = UDim2.fromOffset(w, h),
                ZIndex = z + 1,
            }, root)
            corner(f, r or 8)
            stroke(f, color, 1.2)
            return f
        end
        if name == "egg" then
            box(4, 2, 8, 12, 5)
        elseif name == "aim" then
            ring(2, 2, 12, 12, 6)
            box(7, 7, 2, 2, 1)
            box(7, 0, 2, 3, 0)
            box(7, 13, 2, 3, 0)
            box(0, 7, 3, 2, 0)
            box(13, 7, 3, 2, 0)
        elseif name == "spark" then
            box(7, 1, 2, 14, 1)
            box(1, 7, 14, 2, 1)
            box(4, 4, 2, 2, 1)
            box(10, 10, 2, 2, 1)
        elseif name == "grid" then
            box(1, 1, 6, 6, 2)
            box(9, 1, 6, 6, 2)
            box(1, 9, 6, 6, 2)
            box(9, 9, 6, 6, 2)
        elseif name == "layers" then
            box(2, 3, 12, 2, 1)
            box(2, 7, 12, 2, 1)
            box(2, 11, 12, 2, 1)
        elseif name == "out" then
            ring(1, 3, 10, 10, 3)
            box(8, 2, 6, 2, 1)
            box(12, 2, 2, 6, 1)
        elseif name == "cog" then
            ring(3, 3, 10, 10, 5)
            box(7, 1, 2, 3, 1)
            box(7, 12, 2, 3, 1)
            box(1, 7, 3, 2, 1)
            box(12, 7, 3, 2, 1)
        elseif name == "rocket" then
            box(6, 1, 4, 9, 2)
            box(7, 0, 2, 3, 1)
            box(4, 8, 3, 4, 1)
            box(9, 8, 3, 4, 1)
            box(7, 11, 2, 4, 1)
        elseif name == "search" then
            ring(1, 1, 10, 10, 5)
            box(9, 10, 5, 2, 1).Rotation = 40
        elseif name == "info" then
            ring(2, 2, 12, 12, 6)
            box(7, 4, 2, 2, 1)
            box(7, 7, 2, 5, 1)
        else
            box(2, 3, 12, 2, 1)
            box(2, 7, 12, 2, 1)
            box(2, 11, 12, 2, 1)
        end
        return root
    end

    local function recolorIcon(root, color)
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("ImageLabel") then
                d.ImageColor3 = color
            elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then
                d.BackgroundColor3 = color
            elseif d:IsA("UIStroke") then
                d.Color = color
            end
        end
    end

    -- logo (written to disk from base64 so getcustomasset can load it)
    local function logoAsset(light)
        local cached = light and logoCache.light or logoCache.dark
        if cached then
            return cached
        end
        local data = decodeBase64(light and cfg.LogoLight or cfg.Logo)
        if not data then
            -- allow plain asset ids ("rbxassetid://123")
            local raw = light and cfg.LogoLight or cfg.Logo
            if type(raw) == "string" and raw:find("^rbxasset") then
                return raw
            end
            return
        end
        local file = cfg.Folder .. "/" .. (light and "logo-light.png" or "logo.png")
        if type(makefolder) == "function" then
            pcall(makefolder, cfg.Folder)
        end
        if writefile then
            pcall(writefile, file, data)
        end
        if getcustomasset then
            local ok, res = pcall(getcustomasset, file)
            if ok and type(res) == "string" and res ~= "" then
                if light then
                    logoCache.light = res
                else
                    logoCache.dark = res
                end
                return res
            end
        end
    end

    local function logo(parent, z, size)
        local s = size or 18
        local f = mk("Frame", { Name = cfg.Title, BackgroundTransparency = 1, Size = UDim2.fromOffset(s, s), ZIndex = z }, parent)
        mk("ImageLabel", {
            Name = "Mark",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = logoAsset(false) or "",
            ImageColor3 = Color3.new(1, 1, 1),
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = z + 1,
        }, f)
        logoFrames[#logoFrames + 1] = f
        return f
    end

    local function refreshLogos()
        local img = logoAsset(T == themes.Light or (Flags.Theme == "Light"))
        if not img then
            return
        end
        for _, f in ipairs(logoFrames) do
            local mark = f:FindFirstChild("Mark")
            if mark and mark:IsA("ImageLabel") then
                mark.Image = img
                mark.ImageColor3 = Color3.new(1, 1, 1)
            end
        end
    end

    -- ───────── ScreenGui ─────────
    local function guiParent()
        if gethui then
            local ok, res = pcall(gethui)
            if ok and res then
                return res
            end
        end
        local CoreGui = game:GetService("CoreGui")
        if pcall(function()
            return CoreGui:FindFirstChild(cfg.GuiName)
        end) then
            return CoreGui
        end
        return LocalPlayer:WaitForChild("PlayerGui")
    end

    local guiName = cfg.GuiName .. "_" .. uid
    local host = guiParent()
    local stale = host:FindFirstChild(guiName)
    if stale then
        stale:Destroy()
    end

    local Gui = mk("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1200,
    })
    Gui.Parent = guiParent()
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(Gui)
        end
    end)
    W.Gui = Gui

    local Overlay = mk("TextButton", {
        Name = "Overlay",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 80,
    }, Gui)

    local WinScale = mk("UIScale", { Scale = 1 })

    local Win = mk("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(winW, winH),
        BackgroundColor3 = T.bg,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 10,
    }, Gui)
    corner(Win, 12)
    stroke(Win, "line", 1)
    WinScale.Parent = Win
    bind(Win, "bg", "bg")
    W.Frame = Win

    local Shadow = mk("Frame", {
        Name = "Shadow",
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        Position = UDim2.fromOffset(8, 12),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 9,
        BorderSizePixel = 0,
    }, Win)
    corner(Shadow, 14)

    -- head bar
    do
        local head = mk("Frame", {
            Name = "HeadBar",
            BackgroundColor3 = T.rail,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 82),
            ZIndex = 11,
        }, Win)
        bind(head, "bg", "rail")
        corner(head, 12)
        local fill = mk("Frame", {
            BackgroundColor3 = T.rail,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -16),
            Size = UDim2.new(1, 0, 0, 16),
            ZIndex = 11,
        }, head)
        bind(fill, "bg", "rail")
    end

    -- rail
    local Rail = mk("Frame", {
        Name = "Rail",
        BackgroundColor3 = T.rail,
        BorderSizePixel = 0,
        Size = UDim2.new(0, railW, 1, 0),
        ZIndex = 11,
    }, Win)
    bind(Rail, "bg", "rail")
    corner(Rail, 12)

    local RailScroll, Main, Header, HeaderTitle, HeaderSub
    do
        local rfill = mk("Frame", {
            BackgroundColor3 = T.rail,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -16, 0, 0),
            Size = UDim2.new(0, 16, 1, 0),
            ZIndex = 11,
        }, Rail)
        bind(rfill, "bg", "rail")
        local rline = mk("Frame", {
            BackgroundColor3 = T.line,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -1, 0, 2),
            Size = UDim2.new(0, 1, 1, -2),
            ZIndex = 12,
        }, Rail)
        bind(rline, "bg", "line")
        Rail.Active = true

        RailScroll = mk("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -18),
            Position = UDim2.fromOffset(0, 12),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = (not phone) and 0 or 5,
            BorderSizePixel = 0,
            ZIndex = 12,
        }, Rail)
        padding(RailScroll, 10, 2, 10, 12)
        mk("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, RailScroll)

        local brand = mk("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            LayoutOrder = 0,
            ZIndex = 12,
        }, RailScroll)
        logo(brand, 13, 28).Position = UDim2.fromOffset(0, 2)
        local bt = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(34, 3),
            Size = UDim2.new(1, -34, 0, 16),
            Font = FONTS.title,
            Text = cfg.Title,
            TextColor3 = T.text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 13,
        }, brand)
        bind(bt, "text", "text")
        local bp = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(34, 20),
            Size = UDim2.new(1, -34, 0, 12),
            Font = FONTS.mono,
            Text = cfg.Product,
            TextColor3 = T.mute,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13,
        }, brand)
        bind(bp, "text", "mute")
    end

    Main = mk("Frame", {
        Name = "Main",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(railW, 2),
        Size = UDim2.new(1, -railW, 1, -2),
        ZIndex = 11,
    }, Win)

    Header = mk("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 46),
        ZIndex = 12,
        Active = true,
    }, Main)

    HeaderTitle = mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -180, 0, 18),
        Font = FONTS.title,
        Text = "",
        TextColor3 = T.text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    }, Header)
    bind(HeaderTitle, "text", "text")
    HeaderSub = mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 26),
        Size = UDim2.new(1, -180, 0, 14),
        Font = FONTS.body,
        Text = "idle",
        TextColor3 = T.dim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    }, Header)
    bind(HeaderSub, "text", "dim")

    -- header chips (ping / fps) + minimise
    local function headerChip(width, xOffset)
        local lab = mk("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = T.card,
            Position = UDim2.new(1, xOffset, 0.5, 2),
            Size = UDim2.fromOffset(width, 22),
            Font = FONTS.mono,
            Text = "—",
            TextColor3 = T.dim,
            TextSize = 10,
            ZIndex = 12,
        }, Header)
        corner(lab, 7)
        stroke(lab, "line", 1)
        bind(lab, "bg", "card")
        bind(lab, "text", "dim")
        return lab
    end

    local MinBtn = mk("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = T.card,
        Position = UDim2.new(1, -12, 0.5, 2),
        Size = UDim2.fromOffset((not phone) and 22 or 32, (not phone) and 22 or 32),
        Font = FONTS.mid,
        Text = "–",
        TextColor3 = T.dim,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 12,
    }, Header)
    corner(MinBtn, 7)
    stroke(MinBtn, "line", 1)
    hover(MinBtn, "card", "lift")
    bind(MinBtn, "text", "dim")

    local PingChip, FpsChip
    if cfg.ShowStats then
        PingChip = headerChip(52, -54)
        FpsChip = headerChip(56, -110)
    end

    -- search box
    local SearchFrame = mk("Frame", {
        BackgroundColor3 = T.card,
        Position = UDim2.fromOffset(14, 46),
        Size = UDim2.new(1, -28, 0, (not phone) and 28 or 36),
        ZIndex = 12,
    }, Main)
    corner(SearchFrame, 9)
    bind(SearchFrame, "bg", "card")
    local SearchStroke = stroke(SearchFrame, "line", 1)
    local SearchIcon = icon(SearchFrame, "search", T.mute, 13)
    SearchIcon.Position = UDim2.fromOffset(8, 6)
    local SearchBox = mk("TextBox", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.fromOffset(30, 0),
        Font = FONTS.body,
        PlaceholderText = cfg.SearchPlaceholder,
        PlaceholderColor3 = T.mute,
        Text = "",
        TextColor3 = T.text,
        TextSize = (not phone) and 12 or 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 13,
    }, SearchFrame)
    bind(SearchBox, "text", "text")
    bind(SearchBox, "placeholder", "mute")
    SearchBox.Focused:Connect(function()
        tween(SearchStroke, 0.12, { Color = T.accent })
    end)
    SearchBox.FocusLost:Connect(function()
        tween(SearchStroke, 0.12, { Color = T.line })
    end)

    local contentTop = (not phone) and 80 or 88
    local Content = mk("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, contentTop),
        Size = UDim2.new(1, 0, 1, -contentTop),
        ClipsDescendants = true,
        ZIndex = 12,
    }, Main)

    -- forward declarations (assigned further down) ---------------------------
    local setPage, applyTheme, setVisible, setPhone, clampWindow, saveCache

    -- ───────── popup layer (dropdown overlay) ─────────
    local Drops = mk("Frame", {
        Name = "Drops",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 90,
    }, Gui)

    local function closePopups()
        Drops:ClearAllChildren()
        Drops.Visible = false
    end
    Overlay.MouseButton1Click:Connect(function()
        closePopups()
        Overlay.Visible = false
    end)

    -- ───────── save debounce / widget callbacks ─────────
    local function queueSave()
        if applying or savePending then
            return
        end
        savePending = true
        task.delay(0.35, function()
            savePending = false
            if not alive then
                return
            end
            saveCache()
        end)
    end

    local function fire(flag, ...)
        local w = Widgets[flag]
        if w and w.on then
            pcall(w.on, ...)
        end
    end

    -- ───────── page filter (search box) ─────────
    local function applyFilter(page, query)
        local q = string.lower(query or "")
        local secInst
        local secHas = false
        for _, item in ipairs(page.items) do
            if item.kind == "section" then
                if secInst then
                    secInst.Visible = q == "" or secHas
                end
                secInst = item.inst
                secHas = false
            else
                local show = (q == "" or string.find(item.q, q, 1, true) ~= nil) and (not item.visibleIf or item.visibleIf() or false)
                item.inst.Visible = show
                if show then
                    secHas = true
                end
            end
        end
        if secInst then
            secInst.Visible = q == "" or secHas
        end
    end
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if currentPage then
            applyFilter(currentPage, SearchBox.Text)
        end
    end)

    -- ───────── rail groups / tabs / pages ─────────
    local function ensureGroup(name)
        if groups[name] then
            return groups[name]
        end
        groupCount += 1
        local g = { base = groupCount * 100, n = 0 }
        groups[name] = g
        local lab = mk("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Font = FONTS.mono,
            Text = name,
            TextColor3 = T.mute,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = g.base,
            ZIndex = 12,
        }, RailScroll)
        bind(lab, "text", "mute")
        return g
    end

    local function newPage(name, subtitle)
        local scroll = mk("ScrollingFrame", {
            Name = name,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = (not phone) and 4 or 8,
            ScrollBarImageColor3 = T.line,
            BorderSizePixel = 0,
            Visible = false,
            ZIndex = 13,
        }, Content)
        bind(scroll, "scroll", "line")
        padding(scroll, 12, 4, 12, 14)
        mk("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, scroll)
        local page = { name = name, subtitle = subtitle, scroll = scroll, items = {}, n = 0 }
        pages[name] = page
        return page
    end

    -- raw page switch (animation wrapper lives in the glass layer below)
    local function selectPageRaw(name)
        local page = pages[name]
        if not page then
            return
        end
        currentPage = page
        for k, v in pairs(tabButtons) do
            local on = k == name
            v.on = on
            v.lab.TextColor3 = on and T.text or T.dim
            v.lab.Font = on and FONTS.mid or FONTS.body
            v.btn.BackgroundColor3 = on and T.card or T.rail
            v.btn.BackgroundTransparency = (not on) and 1 or 0.35
            recolorIcon(v.ico, on and T.accent or T.mute)
        end
        for _, p in pairs(pages) do
            p.scroll.Visible = p == page
            if p == page then
                p.scroll.CanvasPosition = Vector2.zero
            end
        end
        HeaderTitle.Text = name
        HeaderSub.Text = page.subtitle or ""
        applyFilter(page, SearchBox.Text)
    end

    function W:AddTab(o)
        if type(o) == "string" then
            o = { Name = o }
        end
        o = o or {}
        local name = o.Name or "Tab"
        local page = newPage(name, o.Subtitle)
        local g = ensureGroup(o.Group or "Menu")
        g.n += 1

        local btn = mk("TextButton", {
            BackgroundColor3 = T.rail,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, (not phone) and 26 or 34),
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = g.base + g.n,
            ZIndex = 12,
        }, RailScroll)
        corner(btn, 6)
        local ico = icon(btn, o.Icon or "layers", T.mute, 13)
        ico.Name = "Ico"
        ico.Position = UDim2.fromOffset(6, 5)
        local lab = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -30, 1, 0),
            Font = FONTS.body,
            Text = name,
            TextColor3 = T.dim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13,
        }, btn)
        bind(lab, "text", "dim")
        tabButtons[name] = { btn = btn, lab = lab, ico = ico }
        btn.MouseEnter:Connect(function()
            if tabButtons[name].on then
                return
            end
            tween(btn, 0.12, { BackgroundTransparency = 0.45, BackgroundColor3 = T.lift })
        end)
        btn.MouseLeave:Connect(function()
            if tabButtons[name].on then
                return
            end
            tween(btn, 0.12, { BackgroundTransparency = 1 })
        end)
        btn.MouseButton1Click:Connect(function()
            setPage(name)
        end)

        local tab = setmetatable({ page = page, Name = name, Window = W }, Tab)
        if not currentPage then
            task.defer(function()
                if alive and not currentPage then
                    setPage(name)
                end
            end)
        end
        return tab
    end

    -- ───────── sections / hero card ─────────
    function Tab:AddSection(title)
        local page = self.page
        page.n += 1
        local card = mk("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = T.card,
            BorderSizePixel = 0,
            LayoutOrder = page.n,
            ZIndex = 13,
        }, page.scroll)
        corner(card, 8)
        stroke(card, "line", 1)
        bind(card, "bg", "card")
        mk("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, card)
        local head = mk("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 26),
            LayoutOrder = 0,
            ZIndex = 14,
        }, card)
        local bar = mk("Frame", {
            BackgroundColor3 = T.accent,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(12, 12),
            Size = UDim2.fromOffset(10, 2),
            ZIndex = 15,
        }, head)
        bind(bar, "bg", "accent")
        local lab = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(28, 0),
            Size = UDim2.new(1, -36, 1, 0),
            Font = FONTS.mono,
            Text = title,
            TextColor3 = T.dim,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
        }, head)
        bind(lab, "text", "dim")
        page.items[#page.items + 1] = { kind = "section", inst = card, q = string.lower(title) }
        return setmetatable({ page = page, card = card, lastRule = nil, Window = W }, Section)
    end

    -- big "about" card: logo + title + chips + tagline
    function Tab:AddHero(o)
        o = o or {}
        local page = self.page
        page.n += 1
        local title = o.Title or (cfg.Title .. " " .. cfg.Product)
        local tagline = o.Tagline or cfg.Tagline
        local card = mk("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = T.card,
            BorderSizePixel = 0,
            LayoutOrder = page.n,
            ZIndex = 13,
        }, page.scroll)
        corner(card, 8)
        stroke(card, "line", 1)
        bind(card, "bg", "card")
        padding(card, 14, 14, 14, 14)
        mk("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, card)
        local top = mk("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            LayoutOrder = 1,
            ZIndex = 14,
        }, card)
        logo(top, 15, 44).Position = UDim2.fromOffset(0, 2)
        local tl = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(54, 2),
            Size = UDim2.new(1, -54, 0, 20),
            Font = FONTS.title,
            Text = title,
            TextColor3 = T.text,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 15,
        }, top)
        bind(tl, "text", "text")
        local chipRow = mk("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(54, 26),
            Size = UDim2.new(1, -54, 0, 20),
            ZIndex = 15,
        }, top)
        mk("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }, chipRow)
        local function chip(text, order, role)
            local c = mk("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = T.fill,
                Size = UDim2.fromOffset(0, 18),
                Font = FONTS.mono,
                Text = "  " .. text .. "  ",
                TextColor3 = T[role] or T.dim,
                TextSize = 10,
                LayoutOrder = order,
                ZIndex = 16,
            }, chipRow)
            corner(c, 5)
            bind(c, "bg", "fill")
            bind(c, "text", role or "dim")
            return c
        end
        local chips = o.Chips
        if not chips then
            chips = { { "v" .. tostring(cfg.Version), "accent" } }
            if hasText(cfg.Status) then
                chips[#chips + 1] = { cfg.Status, "dim" }
            end
            if hasText(cfg.Game) and cfg.Game ~= cfg.Product then
                chips[#chips + 1] = { cfg.Game, "dim" }
            elseif hasText(cfg.Product) then
                chips[#chips + 1] = { cfg.Product, "dim" }
            end
        end
        for i, c in ipairs(chips) do
            chip(c[1] or c.Text, i, c[2] or c.Role)
        end
        local tg = mk("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Font = FONTS.body,
            Text = tagline,
            TextColor3 = T.dim,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            ZIndex = 15,
        }, card)
        bind(tg, "text", "dim")
        page.items[#page.items + 1] = { kind = "section", inst = card, q = string.lower(title .. " " .. tagline) }
        return card
    end

    -- ───────── rows ─────────
    local function newRow(sec, title, desc, width)
        local page = sec.page
        local cw = width or ((not phone) and 132 or 140)
        local parent = sec.card or page.scroll
        local h = (not desc) and 36 or 46
        if phone then
            h = (not desc) and 44 or 54
        end
        page.n += 1
        local row = mk("Frame", {
            BackgroundColor3 = T.card,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, h),
            LayoutOrder = page.n,
            ZIndex = 14,
        }, parent)
        local rule = mk("Frame", {
            BackgroundColor3 = T.line,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -28, 0, 1),
            Visible = sec.lastRule ~= nil,
            ZIndex = 15,
        }, row)
        sec.lastRule = rule
        bind(rule, "bg", "line")
        bind(row, "bg", "card")
        row:SetAttribute("th_hover", "lift")
        row:SetAttribute("th_row", true)
        row.MouseEnter:Connect(function()
            row:SetAttribute("th_over", true)
            tween(row, 0.1, { BackgroundTransparency = 0.45, BackgroundColor3 = T.lift })
        end)
        row.MouseLeave:Connect(function()
            row:SetAttribute("th_over", false)
            tween(row, 0.1, { BackgroundTransparency = 1, BackgroundColor3 = T.card })
        end)
        local tl = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, (not desc) and 10 or 6),
            Size = UDim2.new(1, -(cw + 20), 0, 14),
            Font = FONTS.mid,
            Text = title,
            TextColor3 = T.text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 15,
        }, row)
        bind(tl, "text", "text")
        local dl
        if desc then
            dl = mk("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 22),
                Size = UDim2.new(1, -(cw + 20), 0, 20),
                Font = FONTS.body,
                Text = desc,
                TextColor3 = T.dim,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                ZIndex = 15,
            }, row)
            bind(dl, "text", "dim")
        end
        local ctrl = mk("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -10, 0.5, 0),
            Size = UDim2.fromOffset(cw, (not phone) and 26 or 32),
            ZIndex = 16,
        }, row)
        page.items[#page.items + 1] = { kind = "row", inst = row, q = string.lower(title .. " " .. (desc or "")) }
        return row, ctrl, dl
    end

    local function lastItem(sec, o)
        local items = sec.page.items
        local it = items[#items]
        if it and o and o.VisibleIf then
            it.visibleIf = o.VisibleIf
        end
    end

    -- compact button used by dropdown / keybind
    local function fieldButton(parent, text)
        local b = mk("TextButton", {
            BackgroundColor3 = T.fill,
            Size = UDim2.new(1, 0, 0, 24),
            Font = FONTS.mid,
            Text = text,
            TextColor3 = T.text,
            TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd,
            AutoButtonColor = false,
            ZIndex = 17,
        }, parent)
        corner(b, 7)
        stroke(b, "line", 1)
        hover(b, "fill", "lift")
        bind(b, "text", "text")
        return b
    end

    -- simple popup list (used by the toggle's inline choice chip)
    local function openChoicePopup(anchor, flag, options)
        closePopups()
        Overlay.Visible = true
        Overlay.ZIndex = 85
        Drops.Visible = true
        local pos, size = anchor.AbsolutePosition, anchor.AbsoluteSize
        local frame = mk("Frame", {
            BackgroundColor3 = T.card,
            Position = UDim2.fromOffset(pos.X, pos.Y + size.Y + 6),
            Size = UDim2.fromOffset(math.max(size.X, 120), #options * 28 + 10),
            ZIndex = 95,
        }, Drops)
        corner(frame, 10)
        stroke(frame, "line", 1)
        bind(frame, "bg", "card")
        mk("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
        padding(frame, 5, 5, 5, 5)
        for i, v in ipairs(options) do
            local sel = v == Flags[flag]
            local b = mk("TextButton", {
                BackgroundColor3 = sel and T.lift or T.card,
                Size = UDim2.new(1, 0, 0, 24),
                Font = FONTS.body,
                Text = "  " .. v,
                TextColor3 = sel and T.accent or T.text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                LayoutOrder = i,
                ZIndex = 97,
            }, frame)
            corner(b, 6)
            b.MouseButton1Click:Connect(function()
                Flags[flag] = v
                local w = Widgets[flag]
                if w and w.set then
                    w.set(v)
                end
                if w and w.on then
                    pcall(w.on, v)
                end
                closePopups()
                Overlay.Visible = false
                queueSave()
                if currentPage then
                    applyFilter(currentPage, SearchBox.Text)
                end
            end)
        end
    end

    -- ═════════════ widgets ═════════════
    -- Toggle { Flag, Title, Description, Default, Callback, Choice = { Flag, Options, Default } }
    function Section:AddToggle(o)
        local flag = o.Flag or o.Title
        local on0 = not not o.Default
        Flags[flag] = on0
        local choice = o.Choice
        local width = (not choice) and 132 or 214
        if phone then
            width = (not choice) and 148 or 220
        end
        local _, ctrl, status = newRow(self, o.Title, o.Description, width)

        if choice then
            Flags[choice.Flag] = Flags[choice.Flag] or choice.Default or choice.Options[1]
            local chip = mk("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = T.fill,
                Position = UDim2.new(1, -40, 0.5, 0),
                Size = UDim2.fromOffset(72, 22),
                Font = FONTS.mid,
                Text = tostring(Flags[choice.Flag]) .. " ▾",
                TextColor3 = T.text,
                TextSize = 10,
                TextTruncate = Enum.TextTruncate.AtEnd,
                AutoButtonColor = false,
                ZIndex = 17,
            }, ctrl)
            corner(chip, 6)
            stroke(chip, "line", 1)
            bind(chip, "bg", "fill")
            bind(chip, "text", "text")
            chip.MouseButton1Click:Connect(function()
                openChoicePopup(chip, choice.Flag, choice.Options)
            end)
            Widgets[choice.Flag] = {
                kind = "choice",
                chip = chip,
                on = choice.Callback,
                set = function(v)
                    Flags[choice.Flag] = v
                    chip.Text = tostring(v) .. " ▾"
                    queueSave()
                end,
            }
        end

        local btn = mk("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = Flags[flag] and T.accent or T.fill,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset((not phone) and 34 or 42, (not phone) and 18 or 24),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 17,
        }, ctrl)
        corner(btn, (not phone) and 9 or 12)
        local ring = stroke(btn, Flags[flag] and T.accent or T.line, 1)
        local onPos = phone and UDim2.new(1, -20, 0.5, -8) or UDim2.new(1, -16, 0.5, -6)
        local offPos = UDim2.fromOffset(2, 2)
        local ks = (not phone) and 14 or 16
        local knob = mk("Frame", {
            BackgroundColor3 = Flags[flag] and T.ink or T.text,
            Position = Flags[flag] and onPos or offPos,
            Size = UDim2.fromOffset(ks, ks),
            ZIndex = 18,
        }, btn)
        corner(knob, (not phone) and 7 or 8)

        local function paint(v)
            tween(btn, 0.16, { BackgroundColor3 = v and T.accent or T.fill }, Enum.EasingStyle.Quart)
            tween(knob, 0.16, { Position = v and onPos or offPos, BackgroundColor3 = v and T.ink or T.text }, Enum.EasingStyle.Quart)
            tween(ring, 0.16, { Color = v and T.accent or T.line })
        end

        btn.MouseButton1Click:Connect(function()
            local v = not Flags[flag]
            Flags[flag] = v
            paint(v)
            queueSave()
            task.defer(function()
                fire(flag, v)
                if currentPage then
                    applyFilter(currentPage, SearchBox.Text)
                end
            end)
        end)

        Widgets[flag] = {
            kind = "toggle",
            status = status,
            on = o.Callback,
            set = function(v)
                Flags[flag] = not not v
                paint(Flags[flag])
            end,
        }
        lastItem(self, o)
        return Widgets[flag]
    end

    -- Slider { Flag, Title, Description, Min, Max, Default, Suffix, Callback }
    function Section:AddSlider(o)
        local flag = o.Flag or o.Title
        local min, max = o.Min or 0, o.Max or 100
        local def = o.Default or min
        local suffix = o.Suffix
        Flags[flag] = def
        local row, ctrl, status = newRow(self, o.Title, o.Description)
        row.Size = UDim2.new(1, 0, 0, 72)
        ctrl.Size = UDim2.fromOffset(148, 48)
        local page = self.page

        local valLabel = mk("TextLabel", {
            BackgroundColor3 = T.fill,
            Size = UDim2.new(1, 0, 0, 20),
            Font = FONTS.mono,
            Text = tostring(def) .. (suffix or ""),
            TextColor3 = T.accent,
            TextSize = 12,
            ZIndex = 17,
        }, ctrl)
        corner(valLabel, 5)
        bind(valLabel, "bg", "fill")
        bind(valLabel, "text", "accent")

        local trackF = mk("Frame", {
            BackgroundColor3 = T.fill,
            Position = UDim2.fromOffset(0, 32),
            Size = UDim2.new(1, 0, 0, 10),
            ZIndex = 17,
            Active = true,
        }, ctrl)
        corner(trackF, 5)
        local frac0 = (def - min) / math.max(max - min, 1)
        local fillF = mk("Frame", {
            BackgroundColor3 = T.accent,
            Size = UDim2.new(frac0, 0, 1, 0),
            ZIndex = 18,
        }, trackF)
        corner(fillF, 5)
        local knob = mk("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = T.text,
            Position = UDim2.new(frac0, 0, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            ZIndex = 19,
        }, trackF)
        corner(knob, 9)
        stroke(knob, "accentDeep", 1)

        local hit = mk("TextButton", {
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Active = true,
            Position = UDim2.fromOffset(0, 20),
            Size = UDim2.new(1, 0, 0, 32),
            ZIndex = 21,
        }, ctrl)

        local function setValue(v)
            local n = tonumber(v)
            if not n then
                return
            end
            local val = math.clamp(math.floor(n + 0.5), min, max)
            Flags[flag] = val
            local f = (val - min) / math.max(max - min, 1)
            fillF.Size = UDim2.new(f, 0, 1, 0)
            knob.Position = UDim2.new(f, 0, 0.5, 0)
            valLabel.Text = tostring(val) .. (suffix or "")
            if applying then
                return
            end
            fire(flag, val)
            queueSave()
        end

        local dragging = false
        local function fromX(x)
            local f = math.clamp((x - trackF.AbsolutePosition.X) / math.max(trackF.AbsoluteSize.X, 1), 0, 1)
            setValue(min + f * (max - min))
        end
        hit.InputBegan:Connect(function(input)
            local t = input.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                dragging = true
                if page and page.scroll then
                    page.scroll.ScrollingEnabled = false
                end
                RailScroll.ScrollingEnabled = false
                fromX(input.Position.X)
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if dragging then
                local t = input.UserInputType
                if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
                    fromX(input.Position.X)
                end
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if dragging then
                local t = input.UserInputType
                if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                    dragging = false
                    if page and page.scroll then
                        page.scroll.ScrollingEnabled = true
                    end
                    RailScroll.ScrollingEnabled = true
                end
            end
        end))

        Widgets[flag] = { kind = "slider", status = status, on = o.Callback, set = setValue }
        lastItem(self, o)
        return Widgets[flag]
    end

    -- Dropdown { Flag, Title, Description, Options, Default, Multi, Callback }
    local function multiSummary(sel, options)
        if type(sel) ~= "table" then
            return "none"
        end
        local n, total = 0, #options
        local set = {}
        for _, v in ipairs(sel) do
            set[v] = true
        end
        for _, v in ipairs(options) do
            if set[v] then
                n += 1
            end
        end
        if n == 0 then
            return "none"
        end
        if n == total then
            return "all · " .. total
        end
        return n .. " / " .. total
    end

    function Section:AddDropdown(o)
        local flag = o.Flag or o.Title
        local options = o.Options or {}
        local multi = o.Multi == true
        if multi then
            Flags[flag] = o.Default or { unpack(options) }
        else
            Flags[flag] = o.Default or options[1]
        end
        local _, ctrl, status = newRow(self, o.Title, o.Description)
        local function label()
            return (multi and multiSummary(Flags[flag], options) or tostring(Flags[flag])) .. "   "
        end
        local field = fieldButton(ctrl, multi and multiSummary(Flags[flag], options) or tostring(Flags[flag]))
        mk("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -6, 0.5, 0),
            Size = UDim2.fromOffset(12, 12),
            Font = FONTS.mid,
            Text = "▾",
            TextColor3 = T.mute,
            TextSize = 11,
            ZIndex = 18,
        }, field)
        field.Text = label()

        field.MouseButton1Click:Connect(function()
            closePopups()
            Overlay.Visible = true
            Overlay.ZIndex = 85
            Drops.Visible = true
            local pos, size = field.AbsolutePosition, field.AbsoluteSize
            local height = math.min(7, #options) * 28 + 10
            local frame = mk("Frame", {
                BackgroundColor3 = T.card,
                Position = UDim2.fromOffset(pos.X, pos.Y + size.Y + 6),
                Size = UDim2.fromOffset(math.max(size.X, 180), height),
                ZIndex = 95,
            }, Drops)
            corner(frame, 10)
            stroke(frame, "accentDeep", 1)
            local list = mk("ScrollingFrame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, #options * 28),
                ScrollBarThickness = 3,
                BorderSizePixel = 0,
                ZIndex = 96,
            }, frame)
            padding(list, 5, 5, 5, 5)
            mk("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
            local picked = {}
            if multi and type(Flags[flag]) == "table" then
                for _, v in ipairs(Flags[flag]) do
                    picked[v] = true
                end
            end
            for i, v in ipairs(options) do
                local sel = multi and picked[v] or v == Flags[flag]
                local b = mk("TextButton", {
                    BackgroundColor3 = sel and T.lift or T.card,
                    Size = UDim2.new(1, 0, 0, 26),
                    Font = FONTS.body,
                    Text = "   " .. v,
                    TextColor3 = sel and T.accent or T.text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    LayoutOrder = i,
                    ZIndex = 97,
                }, list)
                corner(b, 6)
                hover(b, sel and T.lift or T.card, T.fill)
                b.MouseButton1Click:Connect(function()
                    if multi then
                        picked[v] = not picked[v]
                        local out = {}
                        for _, ov in ipairs(options) do
                            if picked[ov] then
                                out[#out + 1] = ov
                            end
                        end
                        Flags[flag] = out
                        b.BackgroundColor3 = picked[v] and T.lift or T.card
                        b.TextColor3 = picked[v] and T.accent or T.text
                        b:SetAttribute("locked", false)
                        field.Text = label()
                        fire(flag, out)
                        queueSave()
                        return
                    end
                    Flags[flag] = v
                    fire(flag, v)
                    closePopups()
                    Overlay.Visible = false
                    field.Text = label()
                    queueSave()
                    if currentPage then
                        applyFilter(currentPage, SearchBox.Text)
                    end
                end)
            end
        end)

        Widgets[flag] = {
            kind = "dropdown",
            status = status,
            options = options,
            on = o.Callback,
            refresh = function()
                field.Text = label()
            end,
            set = function(v)
                Flags[flag] = v
                field.Text = label()
            end,
        }
        lastItem(self, o)
        return Widgets[flag]
    end

    -- Input { Flag, Title, Description, Placeholder, Default, Callback, VisibleIf }
    function Section:AddInput(o)
        local flag = o.Flag or o.Title
        Flags[flag] = o.Default or ""
        local _, ctrl, status = newRow(self, o.Title, o.Description)
        local box = mk("TextBox", {
            BackgroundColor3 = T.fill,
            Size = UDim2.new(1, 0, 0, 24),
            Font = FONTS.mono,
            Text = Flags[flag],
            PlaceholderText = o.Placeholder or "",
            PlaceholderColor3 = T.mute,
            TextColor3 = T.text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = 17,
        }, ctrl)
        corner(box, 7)
        bind(box, "bg", "fill")
        bind(box, "text", "text")
        bind(box, "placeholder", "mute")
        local st = stroke(box, "line", 1)
        padding(box, 8, 0, 8, 0)
        box.Focused:Connect(function()
            tween(st, 0.12, { Color = T.accent })
        end)
        box.FocusLost:Connect(function()
            tween(st, 0.12, { Color = T.line })
            Flags[flag] = box.Text
            fire(flag, box.Text)
            queueSave()
        end)
        box:GetPropertyChangedSignal("Text"):Connect(function()
            Flags[flag] = box.Text
            queueSave()
        end)
        Widgets[flag] = {
            kind = "input",
            status = status,
            box = box,
            on = o.Callback,
            set = function(v)
                Flags[flag] = v
                box.Text = tostring(v)
            end,
        }
        lastItem(self, o)
        return Widgets[flag]
    end

    -- Button { Flag, Title, Description, Text, Primary, Callback }
    function Section:AddButton(o)
        local flag = o.Flag or o.Title
        local _, ctrl, status = newRow(self, o.Title, o.Description)
        local primary = o.Primary == true
        local b = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            Font = FONTS.mid,
            Text = o.Text or o.Title,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 17,
        }, ctrl)
        corner(b, 7)
        if not primary then
            stroke(b, "line", 1)
        end
        hover(b, (not primary) and "fill" or "accent", (not primary) and "lift" or "accentHover")
        bind(b, "text", (not primary) and "text" or "ink")
        Widgets[flag] = { kind = "button", status = status, btn = b, on = o.OnPress }
        b.MouseButton1Click:Connect(function()
            if o.Callback then
                pcall(o.Callback)
            end
            local w = Widgets[flag]
            if w and w.on then
                pcall(w.on)
            end
        end)
        lastItem(self, o)
        return Widgets[flag]
    end

    -- Keybind { Flag, Title, Description, Default (Enum.KeyCode), Callback }
    function Section:AddKeybind(o)
        local flag = o.Flag or o.Title
        local def = o.Default or Enum.KeyCode.Unknown
        Flags[flag] = def
        local _, ctrl, status = newRow(self, o.Title, o.Description)
        local listening = false
        local b = fieldButton(ctrl, def.Name)
        b.Font = FONTS.mono
        b.MouseButton1Click:Connect(function()
            listening = true
            b.Text = "press"
            b.TextColor3 = T.accent
        end)
        track(UserInputService.InputBegan:Connect(function(input, processed)
            if not listening then
                return
            end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end
            if processed then
                return
            end
            listening = false
            Flags[flag] = input.KeyCode
            b.Text = input.KeyCode.Name
            b.TextColor3 = T.text
            fire(flag, input.KeyCode)
            queueSave()
        end))
        Widgets[flag] = {
            kind = "keybind",
            status = status,
            on = o.Callback,
            set = function(v)
                if type(v) == "string" then
                    local ok, res = pcall(function()
                        return Enum.KeyCode[v]
                    end)
                    if ok then
                        v = res
                    end
                end
                Flags[flag] = v
                local ok, name = pcall(function()
                    return v.Name
                end)
                b.Text = ok and name or tostring(v)
            end,
        }
        lastItem(self, o)
        return Widgets[flag]
    end

    -- Label (title + wrapped body text)
    function Section:AddLabel(title, text)
        if type(title) == "table" then
            title, text = title.Title, title.Text
        end
        text = text or ""
        local page = self.page
        local parent = self.card or page.scroll
        page.n += 1
        local row = mk("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.card,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = page.n,
            ZIndex = 14,
        }, parent)
        local rule = mk("Frame", {
            BackgroundColor3 = T.line,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 14, 0, 0),
            Size = UDim2.new(1, -28, 0, 1),
            Visible = self.lastRule ~= nil,
            ZIndex = 15,
        }, row)
        self.lastRule = rule
        bind(rule, "bg", "line")
        bind(row, "bg", "card")
        row:SetAttribute("th_hover", "lift")
        row:SetAttribute("th_row", true)
        row.MouseEnter:Connect(function()
            row:SetAttribute("th_over", true)
            tween(row, 0.1, { BackgroundTransparency = 0.45, BackgroundColor3 = T.lift })
        end)
        row.MouseLeave:Connect(function()
            row:SetAttribute("th_over", false)
            tween(row, 0.1, { BackgroundTransparency = 1, BackgroundColor3 = T.card })
        end)
        local tl = mk("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 8),
            Size = UDim2.new(1, -28, 0, 14),
            Font = FONTS.mid,
            Text = title,
            TextColor3 = T.text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
        }, row)
        bind(tl, "text", "text")
        local bl = mk("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 24),
            Size = UDim2.new(1, -28, 0, 0),
            Font = FONTS.body,
            Text = text,
            TextColor3 = T.dim,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
        }, row)
        bind(bl, "text", "dim")
        padding(row, 0, 0, 0, 10) -- PaddingBottom only (see below)
        for _, c in ipairs(row:GetChildren()) do
            if c:IsA("UIPadding") then
                c.PaddingLeft = UDim.new(0, 0)
                c.PaddingTop = UDim.new(0, 0)
                c.PaddingRight = UDim.new(0, 0)
                c.PaddingBottom = UDim.new(0, 10)
            end
        end
        page.items[#page.items + 1] = { kind = "row", inst = row, q = string.lower(title .. " " .. text) }
        return { Title = tl, Body = bl }
    end

    -- Note (small muted paragraph)
    function Section:AddNote(text)
        local page = self.page
        local parent = self.card or page.scroll
        page.n += 1
        local holder = mk("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            LayoutOrder = page.n,
            ZIndex = 14,
        }, parent)
        local tl = mk("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 6),
            Size = UDim2.new(1, -28, 0, 0),
            Font = FONTS.body,
            Text = text,
            TextColor3 = T.mute,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 15,
        }, holder)
        mk("UIPadding", { PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 6) }, holder)
        bind(tl, "text", "mute")
        page.items[#page.items + 1] = { kind = "row", inst = holder, q = string.lower(text) }
        return tl
    end

    -- ═════════════ minimised orb ═════════════
    local Orb = mk("TextButton", {
        Name = "Orb",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = phone and UDim2.new(0, 36, 1, -88) or UDim2.new(0, 40, 0.5, 0),
        Size = UDim2.fromOffset((not phone) and 34 or 48, (not phone) and 34 or 48),
        BackgroundColor3 = T.rail,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 20,
    }, Gui)
    local OrbCorner = corner(Orb, (not phone) and 14 or 18)
    stroke(Orb, "accent", 1.4)
    bind(Orb, "bg", "rail")
    local OrbLogo = logo(Orb, 21, 20)
    OrbLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    OrbLogo.Position = UDim2.fromScale(0.5, 0.5)

    -- ═════════════ liquid glass layer ═════════════
    local blur = Instance.new("BlurEffect")
    blur.Name = cfg.Title:gsub("%s+", "_") .. "_Blur"
    blur.Size = 0
    pcall(function()
        blur.Parent = Lighting
    end)

    local glassed = setmetatable({}, { __mode = "k" })
    local function clarityOffset()
        local c = tonumber(Flags.GlassClarity)
        if c == nil then
            c = 50
        end
        return (c - 50) / 100 * 0.4
    end
    local function glassTarget(role)
        local tbl = (Flags.Theme == "Light") and GLASS_LIGHT or GLASS_DARK
        local base = tbl[role]
        if not base then
            return nil
        end
        if role == "accent" or role == "accentDeep" or role == "accentHover" then
            return base
        end
        return math.clamp(base + clarityOffset(), 0.02, 0.93)
    end
    local function isFiller(inst)
        if inst.ClassName ~= "Frame" or inst:GetAttribute("th_bg") ~= "rail" then
            return false
        end
        if inst:FindFirstChildOfClass("UICorner") then
            return false
        end
        local s = inst.Size
        return (s.X.Scale == 1 and s.Y.Offset == 16) or (s.Y.Scale == 1 and s.X.Offset == 16)
    end
    local function glassOne(inst)
        if inst:GetAttribute("egoy_noglass") then
            return
        end
        local role = inst:GetAttribute("th_bg")
        if type(role) ~= "string" then
            return
        end
        if isFiller(inst) then
            inst.BackgroundTransparency = 1
            inst:SetAttribute("egoy_noglass", true)
            return
        end
        local want = glassTarget(role)
        if not want then
            return
        end
        if inst.BackgroundTransparency >= 0.99 and not glassed[inst] then
            return
        end
        glassed[inst] = role
        inst.BackgroundTransparency = want
    end
    local function strokeBase()
        return (Flags.Theme == "Light") and 0.35 or 0.55
    end
    local pressHooked = setmetatable({}, { __mode = "k" })
    local function hookPress(btn)
        if pressHooked[btn] or btn.Name == "Overlay" or btn == Orb or btn.Size.X.Scale >= 0.5 then
            return
        end
        pressHooked[btn] = true
        local sc = Instance.new("UIScale")
        sc.Name = "EGOY_Press"
        sc.Scale = 1
        sc.Parent = btn
        local function to(s, t)
            pcall(function()
                TweenService:Create(sc, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = s }):Play()
            end)
        end
        track(btn.MouseEnter:Connect(function()
            to(1.035)
        end))
        track(btn.MouseLeave:Connect(function()
            to(1)
        end))
        track(btn.MouseButton1Down:Connect(function()
            to(0.95, 0.07)
        end))
        track(btn.MouseButton1Up:Connect(function()
            to(1.035, 0.1)
        end))
    end
    local function glassAny(inst)
        if inst:IsA("GuiObject") then
            glassOne(inst)
            if inst:IsA("TextButton") or inst:IsA("ImageButton") then
                hookPress(inst)
            end
        elseif inst:IsA("UIStroke") then
            if inst:GetAttribute("th_stroke") == "line" and inst.Parent ~= Win then
                inst.Transparency = strokeBase()
            end
        end
    end
    local glassQueue, glassQueued = {}, false
    local function glassFlush()
        glassQueued = false
        local q = glassQueue
        glassQueue = {}
        for i = 1, #q do
            local inst = q[i]
            if inst and inst.Parent then
                pcall(glassAny, inst)
            end
        end
    end
    track(Gui.DescendantAdded:Connect(function(d)
        glassQueue[#glassQueue + 1] = d
        if not glassQueued then
            glassQueued = true
            task.defer(glassFlush)
        end
    end))
    pcall(function()
        glassAny(Win)
        for _, d in ipairs(Gui:GetDescendants()) do
            pcall(glassAny, d)
        end
    end)

    -- window decoration: shadow, animated rim, ambient orbs, sheen sweep
    Shadow.BackgroundTransparency = 0.82
    local rim = Win:FindFirstChildOfClass("UIStroke")
    local rimGrad
    if rim then
        rim:SetAttribute("th_stroke", nil)
        rim.Color = Color3.new(1, 1, 1)
        rim.Thickness = 1.6
        rim.Transparency = 0.2
        rimGrad = Instance.new("UIGradient")
        rimGrad.Parent = rim
    end

    local ambient = mk("Frame", {
        Name = "EGOY_Ambient",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,
        ZIndex = 10,
    })
    ambient:SetAttribute("egoy_noglass", true)
    corner(ambient, 12)
    ambient.Parent = Win

    local ambientOrbs = {}
    local function makeOrb(sizePx, colorIdx, sx, sy, ph)
        local holder = mk("Frame", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(sizePx, sizePx),
            ZIndex = 10,
        }, ambient)
        local rings = {}
        for i = 1, 5 do
            local s = 1 - (i - 1) * 0.17
            local f = mk("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(s, s),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.955,
                ZIndex = 10,
            })
            f:SetAttribute("egoy_noglass", true)
            mk("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
            f.Parent = holder
            rings[#rings + 1] = f
        end
        ambientOrbs[#ambientOrbs + 1] = { holder = holder, rings = rings, idx = colorIdx, sx = sx, sy = sy, ph = ph }
    end
    makeOrb(300, 1, 0.31, 0.23, 0)
    makeOrb(240, 2, 0.22, 0.34, 2.1)
    makeOrb(200, 3, 0.37, 0.27, 4.2)

    local sheen = mk("Frame", {
        Name = "EGOY_Sheen",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,
        ZIndex = 70,
        Active = false,
    })
    sheen:SetAttribute("egoy_noglass", true)
    corner(sheen, 12)
    sheen.Parent = Win
    local band = mk("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0.16, 0, 1.8, 0),
        Position = UDim2.new(-0.3, 0, 0.5, 0),
        Rotation = 18,
        ZIndex = 70,
        Active = false,
    })
    band:SetAttribute("egoy_noglass", true)
    mk("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.93),
            NumberSequenceKeypoint.new(1, 1),
        }),
    }, band)
    band.Parent = sheen

    local function refreshAccent()
        local a1, a2, a3 = T.accent, Color3.fromRGB(176, 140, 255), Color3.fromRGB(110, 235, 200)
        local cols = { a1, a2, a3 }
        for _, o in ipairs(ambientOrbs) do
            for _, f in ipairs(o.rings) do
                f.BackgroundColor3 = cols[o.idx] or a1
            end
        end
        if rimGrad then
            rimGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(0.3, a1),
                ColorSequenceKeypoint.new(0.62, a2),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
            })
        end
    end
    refreshAccent()

    local function refreshGlass()
        for inst, role in pairs(glassed) do
            if inst and inst.Parent then
                local want = glassTarget(role)
                if want then
                    inst.BackgroundTransparency = want
                end
            end
        end
        for _, d in ipairs(Gui:GetDescendants()) do
            if d:IsA("UIStroke") and d:GetAttribute("th_stroke") == "line" and d.Parent ~= Win then
                d.Transparency = strokeBase()
            end
        end
    end

    track(RunService.Heartbeat:Connect(function()
        if not alive or not Win.Visible then
            return
        end
        local t = os.clock()
        if rimGrad then
            rimGrad.Rotation = (t * 40) % 360
        end
        if Flags.GlassAnim ~= false then
            for _, o in ipairs(ambientOrbs) do
                o.holder.Position = UDim2.fromScale(0.5 + math.sin(t * o.sx + o.ph) * 0.38, 0.5 + math.cos(t * o.sy + o.ph) * 0.38)
            end
        end
    end))
    task.spawn(function()
        while alive do
            task.wait(5.5 + math.random() * 3)
            if alive and Win.Visible and Flags.GlassAnim ~= false then
                band.Position = UDim2.new(-0.3, 0, 0.5, 0)
                pcall(function()
                    TweenService:Create(band, TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(1.3, 0, 0.5, 0) }):Play()
                end)
            end
        end
    end)

    -- ═════════════ theme ═════════════
    function applyTheme(name)
        if name == "Dusk" or name == "dusk" then
            name = "Dark"
        end
        local pal = themes[name] or themes.Dark
        local nm = (pal == themes.Light) and "Light" or "Dark"
        pal = themes[nm]
        Flags.Theme = nm
        for k, v in pairs(pal) do
            T[k] = v
        end
        local function reapply(inst)
            local thBg = inst:GetAttribute("th_bg")
            if thBg and T[thBg] and inst:IsA("GuiObject") then
                local tw = activeTweens[inst]
                if tw then
                    pcall(function()
                        tw:Cancel()
                    end)
                    activeTweens[inst] = nil
                end
                local thHover = inst:GetAttribute("th_hover")
                local over = inst:GetAttribute("th_over") == true
                inst.BackgroundColor3 = over and ((not not thHover) and T[thHover]) or T[thBg]
                if inst:GetAttribute("th_row") then
                    inst.BackgroundTransparency = (not over) and 1 or 0.45
                end
            end
            local thText = inst:GetAttribute("th_text")
            if thText and T[thText] then
                pcall(function()
                    inst.TextColor3 = T[thText]
                end)
            end
            if inst:IsA("TextBox") then
                local ph = inst:GetAttribute("th_placeholder")
                if ph and T[ph] then
                    inst.PlaceholderColor3 = T[ph]
                end
            end
            if inst:IsA("UIStroke") then
                local ts = inst:GetAttribute("th_stroke")
                if ts and T[ts] then
                    inst.Color = T[ts]
                end
            end
            if inst:IsA("ImageLabel") then
                local ti = inst:GetAttribute("th_img")
                if ti and T[ti] then
                    inst.ImageColor3 = T[ti]
                end
            end
            if inst:IsA("ScrollingFrame") then
                local ts = inst:GetAttribute("th_scroll")
                if ts and T[ts] then
                    inst.ScrollBarImageColor3 = T[ts]
                end
            end
        end
        reapply(Win)
        reapply(Orb)
        for _, d in ipairs(Gui:GetDescendants()) do
            reapply(d)
        end
        refreshLogos()
        recolorIcon(SearchIcon, T.mute)
        for _, p in pairs(pages) do
            local sc = p.scroll
            if sc then
                local cp = sc.CanvasPosition
                sc.CanvasPosition = cp + Vector2.new(0, 1)
                sc.CanvasPosition = cp
            end
        end
        if currentPage then
            selectPageRaw(currentPage.name)
        end
        for k, w in pairs(Widgets) do
            if w.kind == "toggle" and w.set then
                w.set(Flags[k] == true)
            end
        end
        pcall(function()
            refreshGlass()
            refreshAccent()
        end)
    end

    local function setAccent(name, reapply)
        local p = ACCENT_PRESETS[name] or ACCENT_PRESETS.Aqua
        themes.Dark.accent, themes.Dark.accentDeep, themes.Dark.accentHover = p[1], p[2], p[3]
        themes.Light.accent = p[1]:Lerp(Color3.new(0, 0, 0), 0.38)
        themes.Light.accentDeep = p[2]
        themes.Light.accentHover = p[1]:Lerp(Color3.new(0, 0, 0), 0.25)
        if reapply then
            applyTheme(Flags.Theme or "Dark")
        end
    end
    setAccent(opts.Accent or "Aqua", false)
    if opts.Theme == "Light" then
        applyTheme("Light")
    else
        applyTheme("Dark")
    end

    -- ═════════════ toasts ═════════════
    local toastHost = mk("Frame", {
        Name = "EGOY_Toasts",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(270, 400),
        ZIndex = 150,
        Active = false,
    })
    toastHost:SetAttribute("egoy_noglass", true)
    mk("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, toastHost)
    toastHost.Parent = Gui
    local toastN = 0

    local function notify(title, text, kind)
        if Flags.Notifs == false then
            return
        end
        pcall(function()
            toastN += 1
            local col = (kind == "bad" and Color3.fromRGB(255, 110, 110)) or (kind == "good" and T.ok) or T.accent
            local card = mk("Frame", {
                LayoutOrder = toastN,
                BackgroundColor3 = T.rail,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(250, 52),
                ZIndex = 151,
            })
            card:SetAttribute("egoy_noglass", true)
            corner(card, 10)
            local cs = mk("UIStroke", { Color = col, Thickness = 1.2, Transparency = 1 }, card)
            local bar = mk("Frame", {
                BackgroundColor3 = col,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(8, 10),
                Size = UDim2.fromOffset(3, 32),
                ZIndex = 152,
                BackgroundTransparency = 1,
            })
            mk("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
            bar.Parent = card
            local l1 = mk("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(20, 7),
                Size = UDim2.new(1, -28, 0, 16),
                Font = FONTS.title,
                Text = tostring(title or cfg.Title),
                TextColor3 = T.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 1,
                ZIndex = 152,
            }, card)
            local l2 = mk("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(20, 25),
                Size = UDim2.new(1, -28, 0, 18),
                Font = FONTS.body,
                Text = tostring(text or ""),
                TextColor3 = T.dim,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextTransparency = 1,
                ZIndex = 152,
            }, card)
            card.Parent = toastHost
            local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            TweenService:Create(card, ti, { BackgroundTransparency = 0.22 }):Play()
            TweenService:Create(cs, ti, { Transparency = 0.3 }):Play()
            TweenService:Create(bar, ti, { BackgroundTransparency = 0 }):Play()
            TweenService:Create(l1, ti, { TextTransparency = 0 }):Play()
            TweenService:Create(l2, ti, { TextTransparency = 0 }):Play()
            task.delay(3.4, function()
                pcall(function()
                    local to = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    TweenService:Create(card, to, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(cs, to, { Transparency = 1 }):Play()
                    TweenService:Create(bar, to, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(l1, to, { TextTransparency = 1 }):Play()
                    TweenService:Create(l2, to, { TextTransparency = 1 }):Play()
                    task.wait(0.32)
                    card:Destroy()
                end)
            end)
        end)
    end

    -- ═════════════ open / close / page animations ═════════════
    local function rawVisible(show)
        windowVisible = not not show
        Win.Visible = windowVisible
        Orb.Visible = not windowVisible
        if not windowVisible then
            closePopups()
            Overlay.Visible = false
        end
    end

    local function blurTo(sz)
        if Flags.GlassBlur == false then
            sz = 0
        end
        pcall(function()
            TweenService:Create(blur, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Size = sz }):Play()
        end)
    end

    local busy = 0
    function setVisible(show)
        show = not not show
        busy += 1
        local mine = busy
        local sc = (tonumber(Flags.UIScale) or 100) / 100
        if show then
            local was = Win.Visible
            rawVisible(true)
            blurTo(14)
            if was then
                return
            end
            local p = Win.Position
            WinScale.Scale = sc * 0.9
            Win.Position = p + UDim2.fromOffset(0, 22)
            pcall(function()
                TweenService:Create(WinScale, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = sc }):Play()
                TweenService:Create(Win, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = p }):Play()
            end)
        else
            blurTo(0)
            if not Win.Visible then
                rawVisible(false)
                return
            end
            local p = Win.Position
            pcall(function()
                TweenService:Create(WinScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = sc * 0.93 }):Play()
                TweenService:Create(Win, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = p + UDim2.fromOffset(0, 14) }):Play()
            end)
            task.delay(0.21, function()
                if mine ~= busy then
                    return
                end
                rawVisible(false)
                WinScale.Scale = sc
                Win.Position = p
            end)
        end
    end

    function setPage(name)
        selectPageRaw(name)
        pcall(function()
            local pg = pages[name]
            if pg and pg.scroll then
                local sc = pg.scroll
                local base = sc:GetAttribute("egoy_pos")
                if typeof(base) ~= "UDim2" then
                    base = sc.Position
                    sc:SetAttribute("egoy_pos", base)
                end
                sc.Position = base + UDim2.fromOffset(0, 16)
                TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = base }):Play()
            end
        end)
    end

    MinBtn.MouseButton1Click:Connect(function()
        setVisible(false)
    end)
    Orb.MouseButton1Click:Connect(function()
        setVisible(true)
    end)

    -- ═════════════ drag / resize ═════════════
    local dragging, dragMode, dragStart, startPos, startSize
    local function beginDrag(mode, target)
        return function(input)
            local t = input.UserInputType
            if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
                dragging = true
                dragMode = mode
                dragStart = input.Position
                if mode == "resize" then
                    startSize = Win.AbsoluteSize
                end
                startPos = target.Position
            end
        end
    end
    Header.InputBegan:Connect(beginDrag("win", Win))
    Rail.InputBegan:Connect(beginDrag("win", Win))
    Orb.InputBegan:Connect(beginDrag("orb", Orb))

    local ResizeH = mk("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.fromOffset((not phone) and 18 or 32, (not phone) and 18 or 32),
        ZIndex = 30,
        Active = true,
    }, Win)
    for i = 0, 1 do
        mk("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -4 - i * 4, 1, -4),
            Size = UDim2.fromOffset(8 - i * 2, 1),
            BackgroundColor3 = T.mute,
            BorderSizePixel = 0,
            ZIndex = 31,
        }, ResizeH)
    end
    ResizeH.InputBegan:Connect(beginDrag("resize", Win))

    track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then
            return
        end
        local d = input.Position - dragStart
        if dragMode == "win" then
            Win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        elseif dragMode == "orb" then
            Orb.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        elseif dragMode == "resize" then
            local vp = viewportSize()
            local scale = WinScale.Scale
            if scale <= 0 then
                scale = 1
            end
            local minW = (not phone) and 520 or 400
            local minH = (not phone) and 360 or 320
            local maxW = math.max(minW, vp.X - 24)
            local maxH = math.max(minH, vp.Y - 24)
            local w = math.clamp(startSize.X / scale + d.X / scale, minW, maxW)
            local h = math.clamp(startSize.Y / scale + d.Y / scale, minH, maxH)
            Win.Size = UDim2.fromOffset(w, h)
            winW, winH = w, h
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    function clampWindow()
        local vp = viewportSize()
        if vp.X < 80 or vp.Y < 80 then
            return
        end
        local xo, yo = Win.Size.X.Offset, Win.Size.Y.Offset
        if xo <= 0 then
            xo = winW
        end
        if yo <= 0 then
            yo = winH
        end
        local minW = (not phone) and 520 or 400
        local minH = (not phone) and 360 or 320
        local w = math.clamp(xo, minW, math.max(minW, vp.X - 24))
        local h = math.clamp(yo, minH, math.max(minH, vp.Y - 24))
        if w ~= Win.Size.X.Offset or h ~= Win.Size.Y.Offset then
            Win.Size = UDim2.fromOffset(w, h)
        end
    end

    WinScale.Scale = (tonumber(Flags.UIScale) or 100) / 100
    if phone then
        winW, winH = phoneWindowSize()
        Win.Size = UDim2.fromOffset(winW, winH)
    end
    clampWindow()

    -- phone layout switch (also used by the "Phone layout" setting)
    function setPhone()
        local p = not not phone
        railW = (not p) and 152 or 128
        Rail.Size = UDim2.new(0, railW, 1, 0)
        Main.Position = UDim2.fromOffset(railW, 2)
        Main.Size = UDim2.new(1, -railW, 1, -2)
        MinBtn.Size = UDim2.fromOffset((not p) and 22 or 32, (not p) and 22 or 32)
        Orb.Size = UDim2.fromOffset((not p) and 34 or 48, (not p) and 34 or 48)
        ResizeH.Size = UDim2.fromOffset((not p) and 18 or 32, (not p) and 18 or 32)
        if p then
            Orb.Position = UDim2.new(0, 36, 1, -88)
            winW, winH = phoneWindowSize()
            Win.Size = UDim2.fromOffset(winW, winH)
        else
            winW, winH = 620, 430
            Win.Size = UDim2.fromOffset(winW, winH)
        end
        clampWindow()
    end

    local function autoPhone()
        if phoneForced then
            return
        end
        if detectPhone() and not phone then
            phone = true
            setPhone()
            if Widgets.PhoneUI and Widgets.PhoneUI.set then
                pcall(Widgets.PhoneUI.set, true)
            end
        end
    end
    task.defer(autoPhone)
    for _, d in ipairs({ 0.2, 0.6, 1.2, 2.5 }) do
        task.delay(d, autoPhone)
    end
    task.spawn(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            pcall(function()
                pg = LocalPlayer:WaitForChild("PlayerGui", 8)
            end)
        end
        if not pg then
            return
        end
        track(pg.ChildAdded:Connect(function(child)
            if child.Name == "TouchGui" or child.Name == "TouchControlFrame" then
                autoPhone()
            end
        end))
        autoPhone()
    end)
    pcall(function()
        track(UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(autoPhone))
        track(UserInputService:GetPropertyChangedSignal("GyroscopeEnabled"):Connect(autoPhone))
        track(UserInputService:GetPropertyChangedSignal("AccelerometerEnabled"):Connect(autoPhone))
    end)
    pcall(function()
        local function hookCam(cam)
            if cam then
                track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    autoPhone()
                    clampWindow()
                end))
            end
        end
        hookCam(workspace.CurrentCamera)
        track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            hookCam(workspace.CurrentCamera)
            clampWindow()
        end))
    end)

    -- open / close keybind
    track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if (Flags.OpenBind or cfg.OpenBind) == input.KeyCode then
            setVisible(not windowVisible)
        end
    end))

    -- ping / fps chips
    if cfg.ShowStats then
        local frames = 0
        local last = os.clock()
        track(RunService.RenderStepped:Connect(function()
            frames += 1
            local now = os.clock()
            if now - last < 0.4 then
                return
            end
            local fps = math.floor(frames / (now - last) + 0.5)
            frames = 0
            last = now
            local ping = 0
            pcall(function()
                ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            FpsChip.Text = fps .. " fps"
            PingChip.Text = ping .. " ms"
            PingChip.TextColor3 = ping < 90 and T.ok or T.dim
        end))
    end

    -- ═════════════ config (save / load / presets / export) ═════════════
    local baseDir = cfg.Folder .. "/" .. sanitize(cfg.Game)
    local cacheDir = baseDir .. "/cache"
    local configsDir = baseDir .. "/configs"
    local playerName = LocalPlayer and LocalPlayer.Name or "Player"
    local cacheFile = cacheDir .. "/" .. sanitize(playerName) .. "-config.json"
    local cacheFileUid = cacheDir .. "/" .. uid .. "-config.json"
    local function clog(...)
        warn("[" .. cfg.Title .. "/cfg]", ...)
    end

    local function serialize()
        for k, w in pairs(Widgets) do
            if w and w.kind == "input" and w.box then
                pcall(function()
                    local txt = w.box.Text
                    if type(txt) ~= "string" then
                        return
                    end
                    if txt ~= "" or Flags[k] == nil or Flags[k] == "" then
                        Flags[k] = txt
                    end
                end)
            end
        end
        local out = {}
        for k, v in pairs(Flags) do
            if not configIgnore[k] then
                local tv = type(v)
                if tv == "boolean" or tv == "number" or tv == "string" or tv == "table" then
                    out[k] = v
                else
                    local ok, res = pcall(function()
                        return v.Name
                    end)
                    if ok and type(res) == "string" then
                        out[k] = res
                    end
                end
            end
        end
        return out
    end

    local function writeCfg(path, data)
        if type(path) ~= "string" or path == "" then
            return false
        end
        if not writefile then
            return false
        end
        if type(makefolder) == "function" then
            pcall(makefolder, cfg.Folder)
            pcall(makefolder, baseDir)
            pcall(makefolder, cacheDir)
            pcall(makefolder, configsDir)
            local dir = path:match("^(.*)/[^/]+$")
            if dir then
                pcall(makefolder, dir)
            end
        end
        local ok, err = pcall(writefile, path, data)
        if not ok then
            clog("write fail", path, tostring(err))
            return false
        end
        return true
    end

    function saveCache(force)
        if applying and not force then
            return
        end
        if not writefile then
            clog("writefile missing")
            return
        end
        local ok, json = pcall(function()
            return HttpService:JSONEncode(serialize())
        end)
        if not ok or type(json) ~= "string" then
            clog("encode fail", tostring(json))
            return
        end
        if not writeCfg(cacheFile, json) then
            writeCfg(cacheFileUid, json)
        end
    end

    local function convertValue(flag, v)
        local w = Widgets[flag]
        if w and w.kind == "keybind" and type(v) == "string" then
            local ok, res = pcall(function()
                return Enum.KeyCode[v]
            end)
            if ok and res then
                return res
            end
        end
        if flag == "Theme" and (v == "Dusk" or v == "dusk") then
            return "Dark"
        end
        return v
    end

    local function applyConfig(data, invokeOn)
        if type(data) ~= "table" then
            return
        end
        applying = true
        local ok, err = pcall(function()
            for k, v in pairs(data) do
                if k ~= "ImportPaste" then
                    local val = convertValue(k, v)
                    local w = Widgets[k]
                    if w and w.set then
                        pcall(w.set, val)
                        if invokeOn and w.on and w.kind ~= "slider" and k ~= "CfgPreset" then
                            pcall(w.on, Flags[k])
                        end
                    else
                        Flags[k] = val
                    end
                end
            end
        end)
        applying = false
        if not ok then
            clog("apply fail", tostring(err))
        end
    end

    local function readJson(path)
        if type(path) ~= "string" or path == "" or not readfile then
            return
        end
        local ok, raw = pcall(readfile, path)
        if ok and type(raw) == "string" and raw ~= "" then
            local ok2, data = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if ok2 and type(data) == "table" then
                return data, path
            end
        end
    end

    local function listPresets()
        local out, seen = { "default" }, { default = true }
        if type(listfiles) == "function" then
            local ok, files = pcall(listfiles, configsDir)
            if ok and type(files) == "table" then
                for i = 1, #files do
                    local n = tostring(files[i] or ""):gsub("\\", "/"):match("([^/]+)%.json$")
                    if n and not seen[n] then
                        seen[n] = true
                        out[#out + 1] = n
                    end
                end
            end
        elseif type(isfile) == "function" then
            local cur = trim(Flags.CfgPreset)
            local n = cur ~= "" and sanitize(cur) or "default"
            if n ~= "default" and not seen[n] then
                out[#out + 1] = n
            end
        end
        table.sort(out, function(a, b)
            if a == "default" then
                return true
            end
            if b == "default" then
                return false
            end
            return a < b
        end)
        return out
    end

    local function refreshPresets()
        local w = Widgets.CfgPreset
        if not w or not w.options then
            return
        end
        local list = listPresets()
        for i = #w.options, 1, -1 do
            w.options[i] = nil
        end
        for i = 1, #list do
            w.options[i] = list[i]
        end
        local cur = trim(Flags.CfgPreset)
        local name = cur ~= "" and sanitize(cur) or "default"
        local found = false
        for i = 1, #list do
            if name == list[i] then
                found = true
                break
            end
        end
        if not found then
            name = "default"
            Flags.CfgPreset = name
        end
        if w.set then
            pcall(w.set, name)
            return
        end
        if w.refresh then
            pcall(w.refresh)
        end
    end

    local function saveNamed(name)
        local n = trim(name)
        n = n ~= "" and sanitize(n) or "default"
        local ok, json = pcall(function()
            return HttpService:JSONEncode(serialize())
        end)
        if not ok or type(json) ~= "string" then
            clog("named encode fail", tostring(json))
            return false
        end
        if not writeCfg(configsDir .. "/" .. n .. ".json", json) then
            return false
        end
        Flags.CfgPreset = n
        refreshPresets()
        clog("saved named", n)
        return true
    end

    local function afterLoad()
        applyTheme(Flags.Theme or "Dark")
        local num = tonumber(Flags.UIScale)
        if num then
            WinScale.Scale = num / 100
        end
    end

    local function loadNamed(name, invokeOn)
        local n = trim(name)
        n = n ~= "" and sanitize(n) or "default"
        local data, path = readJson(configsDir .. "/" .. n .. ".json")
        if not data then
            clog("no named config", n)
            return false
        end
        applyConfig(data, invokeOn)
        Flags.CfgPreset = n
        afterLoad()
        saveCache(true)
        clog("loaded named", path)
        return true
    end

    local function loadAuto(invokeOn)
        if not readfile then
            clog("readfile missing")
            return false
        end
        local data, path = readJson(cacheFile)
        if not data then
            data, path = readJson(cacheFileUid)
        end
        if not data then
            data, path = readJson(configsDir .. "/default.json")
        end
        if not data then
            refreshPresets()
            return false
        end
        applyConfig(data, invokeOn)
        afterLoad()
        if Flags.StartMin then
            setVisible(false)
        end
        for k, w in pairs(Widgets) do
            if w and w.set and Flags[k] ~= nil then
                if w.kind == "toggle" then
                    pcall(w.set, Flags[k] == true)
                elseif w.kind == "choice" or w.kind == "dropdown" or w.kind == "input" or w.kind == "slider" then
                    pcall(w.set, Flags[k])
                end
            end
        end
        if currentPage then
            applyFilter(currentPage, SearchBox.Text)
        end
        refreshPresets()
        if path ~= cacheFile then
            saveCache(true)
        end
        clog("loaded", path)
        return true
    end

    -- ═════════════ public API ═════════════
    W.Orb = Orb
    function W:SetPage(name)
        setPage(name)
    end
    function W:SetVisible(v)
        setVisible(v)
    end
    function W:Toggle()
        setVisible(not windowVisible)
    end
    function W:IsVisible()
        return windowVisible
    end
    function W:SetTheme(name)
        applyTheme(name)
    end
    function W:SetAccent(name)
        setAccent(name, true)
    end
    function W:SetScale(pct)
        Flags.UIScale = pct
        WinScale.Scale = pct / 100
        if Widgets.UIScale and Widgets.UIScale.set then
            Widgets.UIScale.set(pct)
        end
    end
    function W:SetStatus(flag, text)
        local w = Widgets[flag]
        if w and w.status then
            w.status.Text = text
        end
    end
    function W:On(flag, fn)
        local w = Widgets[flag]
        if w then
            w.on = fn
        end
    end
    function W:Get(flag)
        return Flags[flag]
    end
    function W:Set(flag, value)
        local w = Widgets[flag]
        if w and w.set then
            w.set(value)
        else
            Flags[flag] = value
        end
    end
    function W:Refresh()
        if currentPage then
            applyFilter(currentPage, SearchBox.Text)
        end
    end
    function W:Notify(title, text, kind)
        notify(title, text, kind)
    end
    function W:SaveConfig(name)
        if name then
            return saveNamed(name)
        end
        saveCache(true)
        return true
    end
    function W:LoadConfig(name)
        if name then
            return loadNamed(name, true)
        end
        return loadAuto(false)
    end
    function W:ListConfigs()
        return listPresets()
    end
    function W:ExportConfig()
        saveCache()
        local ok, json = pcall(function()
            return HttpService:JSONEncode(serialize())
        end)
        if ok and setclipboard then
            pcall(setclipboard, json)
        end
        return ok and json or nil
    end
    function W:ImportConfig(json)
        if type(json) ~= "string" or json == "" then
            return false
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(json)
        end)
        if not ok or type(data) ~= "table" then
            return false
        end
        applyConfig(data, true)
        applyTheme(Flags.Theme or "Dark")
        saveCache(true)
        return true
    end
    function W:Destroy()
        if not alive then
            return
        end
        alive = false
        pcall(closePopups)
        for i = 1, #conns do
            local c = conns[i]
            conns[i] = nil
            if c then
                pcall(function()
                    c:Disconnect()
                end)
            end
        end
        pcall(function()
            blur:Destroy()
        end)
        pcall(function()
            Gui:Destroy()
        end)
    end

    -- Default "Settings" page (appearance / keybinds / config / window) — same as the original hub
    function W:AddSettingsTab(o)
        o = o or {}
        local tab = self:AddTab({
            Name = o.Name or "Settings",
            Subtitle = o.Subtitle or "window, glass and config",
            Icon = "cog",
            Group = o.Group or "Config",
        })
        local sec = tab:AddSection("Appearance")
        sec:AddToggle({
            Flag = "PhoneUI",
            Title = "Phone layout",
            Description = "compact hub for phones / emulators — leave off on PC",
            Default = phone,
            Callback = function(v)
                phoneForced = true
                phone = not not v
                setPhone()
            end,
        })
        sec:AddSlider({
            Flag = "UIScale",
            Title = "UI scale",
            Description = "zooms the hub — does not crush the layout",
            Min = 75,
            Max = 125,
            Default = 100,
            Suffix = "%",
            Callback = function(v)
                WinScale.Scale = v / 100
            end,
        })
        sec:AddDropdown({
            Flag = "Theme",
            Title = "Theme",
            Description = "dark or light — mark swaps with the theme",
            Options = { "Dark", "Light" },
            Default = Flags.Theme or "Dark",
            Callback = function(v)
                applyTheme(v)
            end,
        })
        sec:AddDropdown({
            Flag = "AccentPreset",
            Title = "Accent colour",
            Description = "tints buttons, toggles and the glow",
            Options = Library.AccentPresets,
            Default = opts.Accent or "Aqua",
            Callback = function(v)
                setAccent(v, true)
            end,
        })
        sec:AddSlider({
            Flag = "GlassClarity",
            Title = "Glass clarity",
            Description = "higher = more see-through",
            Min = 0,
            Max = 100,
            Default = 50,
            Suffix = "%",
            Callback = function()
                refreshGlass()
            end,
        })
        sec:AddToggle({
            Flag = "GlassBlur",
            Title = "Background blur",
            Description = "blurs the game behind the hub while it is open",
            Default = true,
            Callback = function(v)
                pcall(function()
                    TweenService:Create(blur, TweenInfo.new(0.3), { Size = (v and Win.Visible) and 14 or 0 }):Play()
                end)
            end,
        })
        sec:AddToggle({
            Flag = "GlassAnim",
            Title = "Animated glass",
            Description = "moving light and shine sweep — turn off on weak devices",
            Default = true,
        })
        sec:AddToggle({
            Flag = "Notifs",
            Title = "Notifications",
            Description = "small pop-ups from the hub",
            Default = true,
        })

        local keys = tab:AddSection("Keybinds")
        keys:AddKeybind({
            Flag = "OpenBind",
            Title = "Open / close",
            Description = "press this any time to show or hide",
            Default = cfg.OpenBind,
        })
        keys:AddToggle({ Flag = "StartMin", Title = "Start minimised", Default = false })

        local conf = tab:AddSection("Config")
        conf:AddDropdown({
            Flag = "CfgPreset",
            Title = "Load config",
            Description = "new accounts use default",
            Options = { "default" },
            Default = "default",
            Callback = function(v)
                loadNamed(v, true)
                refreshPresets()
            end,
        })
        conf:AddInput({
            Flag = "CfgSaveName",
            Title = "Save as",
            Description = "blank = default",
            Placeholder = "name · or leave blank",
            Default = "",
        })
        conf:AddButton({
            Flag = "SaveCfgAs",
            Title = "Save config",
            Description = "writes " .. cfg.Folder .. "/.../configs/<n>.json",
            Text = "Save",
            Primary = true,
            Callback = function()
                saveNamed(Flags.CfgSaveName)
            end,
        })
        conf:AddButton({
            Flag = "ExportCfg",
            Title = "Export settings",
            Description = "copies config to clipboard",
            Text = "Copy",
            Primary = true,
            Callback = function()
                W:ExportConfig()
            end,
        })
        conf:AddInput({
            Flag = "ImportPaste",
            Title = "Import settings",
            Description = "load config from clipboard",
            Placeholder = "paste, then press Import",
            Default = "",
        })
        conf:AddButton({
            Flag = "ImportCfg",
            Title = "Import",
            Text = "Import",
            Primary = false,
            Callback = function()
                W:ImportConfig(Flags.ImportPaste)
            end,
        })

        local winSec = tab:AddSection("Window")
        winSec:AddButton({
            Flag = "ResetWin",
            Title = "Reset position & size",
            Description = "window and orb back to the middle at default size",
            Text = "Reset",
            Primary = false,
            Callback = function()
                Win.Position = UDim2.fromScale(0.5, 0.5)
                Win.Size = UDim2.fromOffset(winW, winH)
                WinScale.Scale = 1
                if Widgets.UIScale and Widgets.UIScale.set then
                    Widgets.UIScale.set(100)
                end
                if phone then
                    Orb.Position = UDim2.new(0, 36, 1, -88)
                else
                    Orb.Position = UDim2.new(0, 40, 0.5, 0)
                end
                clampWindow()
            end,
        })
        refreshPresets()
        return tab
    end

    -- ═════════════ boot splash ═════════════
    if opts.StartMinimized then
        Flags.StartMin = true
    end
    if not Flags.StartMin and cfg.Splash then
        pcall(function()
            rawVisible(false)
            Orb.Visible = false
            local splash = mk("Frame", {
                Name = "EGOY_Splash",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(340, 112),
                BackgroundColor3 = T.bg,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                ZIndex = 200,
            })
            splash:SetAttribute("egoy_noglass", true)
            corner(splash, 16)
            local sst = mk("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.6, Transparency = 0.25 })
            local sg = mk("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(0.5, T.accent),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(176, 140, 255)),
                }),
            }, sst)
            sst.Parent = splash
            local sUI = mk("UIScale", { Scale = 0.85 }, splash)
            local title = mk("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 18),
                Size = UDim2.new(1, 0, 0, 40),
                Font = FONTS.title,
                Text = cfg.Title,
                TextColor3 = T.text,
                TextSize = 32,
                ZIndex = 201,
            })
            mk("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, T.accent),
                }),
            }, title)
            title.Parent = splash
            local sub = mk("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 58),
                Size = UDim2.new(1, 0, 0, 16),
                Font = FONTS.body,
                Text = cfg.SplashSubtitle,
                TextColor3 = T.dim,
                TextSize = 12,
                ZIndex = 201,
            }, splash)
            local track0 = mk("Frame", {
                BackgroundColor3 = T.fill,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 28, 1, -26),
                Size = UDim2.new(1, -56, 0, 6),
                ZIndex = 201,
            })
            track0:SetAttribute("egoy_noglass", true)
            mk("UICorner", { CornerRadius = UDim.new(1, 0) }, track0)
            track0.Parent = splash
            local fill = mk("Frame", {
                BackgroundColor3 = T.accent,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(0, 1),
                ZIndex = 202,
            })
            fill:SetAttribute("egoy_noglass", true)
            mk("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
            fill.Parent = track0
            splash.Parent = Gui
            local rot = RunService.Heartbeat:Connect(function()
                sg.Rotation = (os.clock() * 120) % 360
            end)
            TweenService:Create(sUI, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
            TweenService:Create(fill, TweenInfo.new(1.25, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), { Size = UDim2.fromScale(1, 1) }):Play()
            task.delay(1.45, function()
                pcall(function()
                    TweenService:Create(sUI, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 1.12 }):Play()
                    TweenService:Create(splash, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(sst, TweenInfo.new(0.3), { Transparency = 1 }):Play()
                    TweenService:Create(title, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
                    TweenService:Create(sub, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
                    TweenService:Create(track0, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(fill, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
                end)
                task.wait(0.32)
                pcall(function()
                    rot:Disconnect()
                    splash:Destroy()
                end)
                setVisible(true)
                notify(cfg.Title, "Loaded · press " .. tostring((Flags.OpenBind or cfg.OpenBind).Name) .. " to hide / show", "good")
            end)
            -- failsafe: never leave the hub hidden
            task.delay(5, function()
                if alive and not Win.Visible and not Flags.StartMin then
                    setVisible(true)
                end
            end)
        end)
    elseif Flags.StartMin then
        rawVisible(false)
    end

    return W
end

return Library
