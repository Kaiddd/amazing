repeat task.wait() until game:IsLoaded()
queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Kaiddd/amazing/refs/heads/main/qot8.luau",true))()]])

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local plr = Players.LocalPlayer

local function hop()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = HttpService:JSONDecode(req)

    if body and body.data then
        for _, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], plr)
    end
end

task.spawn(function()
    while RunService.Heartbeat:Wait() do
        local character = plr.Character
        if not character or not character.Parent then continue end

        local root = character.PrimaryPart
        if not root or not root.Parent then continue end

        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("Humanoid") then v.Jump = true end
            if child:IsA("BasePart") and child.CanCollide then
                child.CanCollide = false
            end
        end

        local vel, movel = nil, 0.1

        vel = root.Velocity
        root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

        RunService.RenderStepped:Wait()

        if not character or not character.Parent then continue end
        if not root or not root.Parent then continue end

        root.Velocity = vel

        RunService.Stepped:Wait()

        if not character or not character.Parent then continue end
        if not root or not root.Parent then continue end

        root.Velocity = vel + Vector3.new(0, movel, 0)
        movel = movel * -1
    end
end)

local prevPositions = {}
local prevTimes = {}

task.spawn(function()
    while true do
        for _, v in pairs(Players:GetPlayers()) do
            pcall(function()
                for _, v in pairs(CoreGui.PlayerList:GetDescendants()) do
                    if v.Name == "PlayerIcon" and v.ClassName == "TextLabel" and v.Text ~= "premium" then
                        while true do
                            hop()
                            task.wait(3)
                        end
                    end
                end

                local targetRoot = v.Character.Humanoid.RootPart
                local myRoot = plr.Character.Humanoid.RootPart

                local targetPos = targetRoot.Position
                local now = tick()

                local predicted = targetRoot.CFrame
                local userId = v.UserId

                if prevPositions[userId] and prevTimes[userId] then
                    local dt = now - prevTimes[userId]
                    if dt > 0 and dt < 1 then
                        local estimatedVel = (targetPos - prevPositions[userId]) / dt

                        local predictionTime = 0.1 + 0.05
                        local offset = estimatedVel * predictionTime

                        predicted = targetRoot.CFrame + offset
                    end
                end

                prevPositions[userId] = targetPos
                prevTimes[userId] = now

                myRoot.CFrame = predicted
            end)
            task.wait(.1)
        end
    end
end)

task.wait(30)

while true do
    hop()
    task.wait(3)
end
