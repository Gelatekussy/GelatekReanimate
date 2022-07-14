if not getgenv().OGChar then
    error("Gelatek Reanimate - Not Reanimated!")
end
if not getgenv().OGChar:FindFirstChild("Bullet") then
    error("Gelatek Reanimate - Bullet Is Disabled!")
end
if getgenv().OGChar:FindFirstChild("Bullet"):FindFirstChildOfClass("BodyAngularVelocity") then
    error("Gelatek Reanimate - Bullet Is Already Running!")
end

getgenv().PartDisconnecting = true

local Players = game:GetService("Players")
local Character = workspace:FindFirstChild("GelatekReanimate")
local Bullet = getgenv().OGChar:FindFirstChild("Bullet")
local Mouse = Players.LocalPlayer:GetMouse()
local Power = Instance.new("BodyAngularVelocity")
Power.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
Power.P = math.huge
Power.AngularVelocity = Vector3.new(25000,25000,25000)
Power.Parent = Bullet
local BP = Instance.new("BodyPosition")
BP.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
BP.P = 22500
BP.D = 125
BP.Position = Bullet.Position
BP.Parent = Bullet
local Held = false
table.insert(getgenv().TableOfEvents, Mouse.Button1Down:Connect(function()
    Held = true
end))
    
table.insert(getgenv().TableOfEvents, Mouse.Button1Up:Connect(function()
    Held = false
end))

table.insert(getgenv().TableOfEvents, game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        if Held then
            if Mouse.Target:IsA("BasePart") then
                if Players:GetPlayerFromCharacter(Mouse.Target.Parent) then
                    if Mouse.Target.Parent.Name ~= Players.LocalPlayer.Name then
                        BP.Position = Mouse.Target.Parent:FindFirstChild("Head").CFrame.p + Vector3.new(0,-1.5,0)
                    end
                elseif Players:GetPlayerFromCharacter(Mouse.Target.Parent.Parent) then
                    if Mouse.Target.Parent.Parent.Name ~= Players.LocalPlayer.Name then
                       BP.Position = Mouse.Target.Parent.Parent:FindFirstChild("Head").CFrame.p + Vector3.new(0,-1.5,0)
                    end
                else
                    BP.Position = Mouse.Hit.Position
                end
            end
        else
           BP.Position = Character["HumanoidRootPart"].Position
        end
    end)
end))
