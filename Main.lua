-- Rep: https://github.com/StrokeThePea/GelatekReanimate
if not getgenv().GelatekReanimateConfig then
	getgenv().GelatekReanimateConfig = {
		["AnimationsDisabled"] = false,
		["R15ToR6"] = false,
		["PermanentDeath"] = false,
		["TorsoFling"] = false,
		["BulletEnabled"] = false,
		["LoadLibrary"] = false
	}
end
--// Variables
local HiddenProps = sethiddenproperty or set_hidden_property or function() end 
	
local SimulationRadius = setsimulationradius or set_simulation_radius or function() end 

local SetScript = setscriptable or function() end
	
--// Core
local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/StrokeThePea/GelatekReanimate/main/Addons/Core.lua"))()


local IsPlayerDead, Events, PlayerRigType, HatReplicaR6, BulletR6, HatReplicaR15, BulletR15, Velocity, PartFling = false, {}, "", nil, nil, nil, nil, Vector3.new(0,25.05,0), PartFling

if not getgenv().TableOfEvents then
	getgenv().TableOfEvents = {}
end

do
	if not game:IsLoaded() then
		Core.Notification("Game Did not load yet. Please Wait.")
		return
	end
	if workspace:FindFirstChild("GelatekReanimate") then
		Core.Notification("Reanimation Already Running! Reset to continue.")
		return
	end
	if game.Players.LocalPlayer.Character.Humanoid.Health == 0 then
		Core.Notification("Player Is Dead, Reanimate when you will be alive.")
		return
	end
	if not game:GetService("ReplicatedStorage"):FindFirstChild("FrostwareData") then
		local Folder = Instance.new("Folder")
		Folder.Name = "FrostwareData"
		Folder.Parent = game:GetService("ReplicatedStorage")
		local Clone = game:GetObjects("rbxassetid://8440552086")[1]
		Clone.Name = "R6FakeRig"
		Clone.Parent = Folder
		task.wait(0.55)
	end
	
end

--// Settings
local AreAnimationsDisabled = getgenv().GelatekReanimateConfig.AnimationsDisabled or false

local IsPermaDeath = getgenv().GelatekReanimateConfig.PermanentDeath or false

local IsBulletEnabled = getgenv().GelatekReanimateConfig.BulletEnabled or false

local IsTorsoFling = getgenv().GelatekReanimateConfig.TorsoFling or false

local IsLoadLibraryEnabled = getgenv().GelatekReanimateConfig.LoadLibrary or false

local R15ToR6 = getgenv().GelatekReanimateConfig.R15ToR6 or false

if IsTorsoFling == true and IsBulletEnabled == true then
	IsTorsoFling = false
	warn("TorsoFling and BulletEnabled are both true! Disabling TorsoFling")
end
if R15ToR6 == false and game.Players.LocalPlayer.Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then
	IsBulletEnabled = false
	IsTorsoFling = false
	warn("R15ToR6 Is disabled! Disabling TorsoFling/BulletEnabled")
end

--// SimpleAPI
warn("Gelatek Reanimate - Default Animations Disabled: "..tostring(AreAnimationsDisabled))
warn("Gelatek Reanimate - R15 To R6: "..tostring(R15ToR6))
warn("Gelatek Reanimate - Permament Death: "..tostring(IsPermaDeath))
warn("Gelatek Reanimate - Torso Fling: "..tostring(IsTorsoFling))
warn("Gelatek Reanimate - Bullet Enabled: "..tostring(IsBulletEnabled))
warn("Gelatek Reanimate - LoadLibrary Enabled: "..tostring(IsLoadLibraryEnabled))

do 
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	settings().Physics.AllowSleep = false
	settings().Physics.ForceCSGv2 = false
	settings().Physics.DisableCSGv2 = true
	settings().Physics.UseCSGv2 = false
	settings().Physics.ThrottleAdjustTime = math.huge
	game.Players.LocalPlayer.ReplicationFocus = workspace

	HiddenProps(workspace,"PhysicsSteppingMethod",Enum.PhysicsSteppingMethod.Fixed)
	HiddenProps(workspace,"PhysicsSimulationRateReplicator",Enum.PhysicsSimulationRate.Fixed240Hz)
end

if setfpscap then
	setfpscap(60.1)
	task.wait(0.05)
end
--// Get Variables
local Player = game:GetService("Players").LocalPlayer
local Character = Player["Character"]
local Humanoid = Character:FindFirstChildOfClass("Humanoid")
Character.Archivable = true

for i,v in ipairs(Character:GetDescendants()) do
	if v:IsA("Tool") then
		v:Destroy()
	end
end
for i,v in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
	if v:IsA("Tool") then
		v:Destroy()
	end
end


local HatsFolder = Instance.new("Folder") -- Hats Folder (For Stop Script)
HatsFolder.Name = "FakeHats"
HatsFolder.Parent = Character

Core.DestroyBodyResizers(Humanoid) -- Humanoid Configs
if IsTorsoFling == false then
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end
PlayerRigType = Core.GetRig(Humanoid)

if PlayerRigType == "R6" then
	Core.CreateDummy("GelatekReanimate", workspace) -- Dummy Creation
elseif PlayerRigType == "R15" and R15ToR6 == true then
	Core.CreateDummy("GelatekReanimate", workspace) -- Dummy Creation
elseif PlayerRigType == "R15" and R15ToR6 == false then
	local Dummy = Character:Clone() 
	Dummy.Name = "GelatekReanimate"
	for i,v in pairs(Dummy:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Decal") then
			v.Transparency = 1
		end
		if v:IsA("Accessory") then
			v:Destroy()
		end
	end
	Dummy.Parent = workspace

end
Core.DisableScripts(Character)


local Dummy = workspace:WaitForChild("GelatekReanimate") -- DummyVariables/Configs
local DummyHumanoid = Dummy:FindFirstChildOfClass("Humanoid")
DummyHumanoid.BreakJointsOnDeath = false
Dummy:MoveTo(Character.Head.Position + Vector3.new(0,-2,0)) -- Get Dummy Nearby You
if workspace:FindFirstChildOfClass("Camera") then
	workspace:FindFirstChildOfClass("Camera").CameraSubject = DummyHumanoid -- Fix Camera
end

Character.Parent = Dummy -- Fix First Person Part Transparency
Core.BreakJoints(Character) -- Break Joints

-- Tables
local CharChildren = Character:GetChildren()
local CharDescendants = Character:GetDescendants()

local DummyChildren = Dummy:GetChildren()
local DummyDescendants = Dummy:GetDescendants()

-- Better To update tables with ChildAdded/ChildRemoved Signal because its optimized.
table.insert(Events, Character.ChildAdded:Connect(function(Tool) -- Character Added
	CharChildren = Character:GetChildren()
	CharDescendants = Character:GetDescendants()
end))

table.insert(Events, Character.ChildRemoved:Connect(function() -- Character Removed
	CharChildren = Character:GetChildren()
	CharDescendants = Character:GetDescendants()
end))

table.insert(Events, Dummy.ChildAdded:Connect(function(Tool) -- Clone Added
	DummyChildren = Dummy:GetChildren()
	DummyDescendants = Dummy:GetDescendants()
end))

table.insert(Events, Dummy.ChildRemoved:Connect(function() -- Clone Removed
	DummyChildren = Dummy:GetChildren()
	DummyDescendants = Dummy:GetDescendants()
end))

Core.MiztRenamer(CharChildren) -- Rename Hats to avoid weird hat placements.
for _,v in pairs(CharChildren) do -- Copying Hats
	if v:IsA("Accessory") then
		local FakeHats1 = v:Clone() -- HatsFolder
		FakeHats1.Handle.Transparency = 1
		FakeHats1.Parent = HatsFolder
		Core.ReCreateAccessoryWelds(Dummy, FakeHats1) -- Remake Offsets
		
		local FakeHats2 = FakeHats1:Clone() -- Dummy
		FakeHats2.Parent = Dummy
	end
end
-- UGLIEST PART #1
if IsBulletEnabled == true then -- Bullet Checking
	getgenv().PartDisconnecting = false
	if PlayerRigType == "R6" then
		if IsPermaDeath == true then
			BulletR6 = Character["HumanoidRootPart"]
			BulletR6.Name = "Bullet"
			BulletR6.Transparency = 0.8
			Core.CreateOutline(BulletR6)
			HatReplicaR6 = nil
		else
			BulletR6 = Character["Left Arm"]
			HatReplicaR6 = "Robloxclassicred"
			BulletR6.Name = "Bullet"
			BulletR6.Transparency = 0.8
			Core.CreateOutline(BulletR6)
			if HatReplicaR6 and Character:FindFirstChild(HatReplicaR6) then
				Character:FindFirstChild(HatReplicaR6).Handle:ClearAllChildren()
			end
		end
	else
		BulletR15 = Character["LeftUpperArm"]
		BulletR15.Name = "Bullet"
		HatReplicaR15 = "SniperShoulderL"
		BulletR15.Transparency = 0.8
		Core.CreateOutline(BulletR15)
	end
else
	BulletR6 = nil
	HatReplicaR6 = nil
	BulletR15 = nil
	HatReplicaR15 = nil
end
if IsTorsoFling == true then
	if PlayerRigType == "R6" then
		PartFling = "Torso"
	else
		PartFling = "HumanoidRootPart"
	end
else
	PartFling = ""
end
-- Collisions/Movement/Network
Core.CreateSignal(Events, "RunService", "Stepped", function()
	Core.DisableCollisions(CharDescendants, DummyDescendants)
	Core.Movement(Humanoid, DummyHumanoid)
	Core.Network()
end)

-- Jumping
Core.CreateSignal(Events, "UserInputService", "JumpRequest", function()
	Core.Jumping(DummyHumanoid)
end)

--

local R6TorsoFlingVelocity = Vector3.new(30,40,30)
task.spawn(function()
	task.wait(2.5)
	R6TorsoFlingVelocity = Vector3.new(1000,1000,1000)
end)
local Off = 1
local Off2 = 0.07
coroutine.wrap(function()
	while wait(0.05) do
		if IsPlayerDead then
			break
		end
		Off2 = Off2 * -1
		Off = Off * -1 
	end
end)()
-- Velocity/Main Part
Core.CreateSignal(Events, "RunService", "Heartbeat", function()
	Velocity = Vector3.new(Dummy["HumanoidRootPart"].AssemblyLinearVelocity.X * 5, 25.32, Dummy["HumanoidRootPart"].AssemblyLinearVelocity.Z * 5)
	for i,v in pairs(CharDescendants) do
		if v:IsA("BasePart") then
			if v and v.Parent and v.Name ~= PartFling then -- Velocity
				v.RootPriority = 127
				v.Velocity = Velocity
				if BulletR6 and v.Name ~= BulletR6.Name or BulletR15 and v.Name ~= BulletR15.Name then
					v.AssemblyAngularVelocity = Vector3.new()
				end
			end
		end
		if v:IsA("Accessory") then
			if v and v.Parent then
				if v.Name ~= HatReplicaR6 and v.Name ~= HatReplicaR15 then
					Core.Align(v.Handle,Dummy[v.Name].Handle)
				end
			end
		end
	end
	if PartFling and Character:FindFirstChild(PartFling) then
		if PlayerRigType == "R6" then
			Character:FindFirstChild(PartFling).Velocity = R6TorsoFlingVelocity
			Character:FindFirstChild(PartFling).AssemblyAngularVelocity = Vector3.new(0,0,0)
		else
			Character:FindFirstChild(PartFling).Velocity = Velocity
			Character:FindFirstChild(PartFling).RotVelocity = Vector3.new(2000,2000,2000)
		end
		Character:FindFirstChild(PartFling).RootPriority = 127
	end
	pcall(function()
		if IsPermaDeath == true then
			Core.Align(Character["Head"], Dummy["Head"])
		end
		
		if PlayerRigType == "R6" then
			if IsPermaDeath == true then -- Ugly Code But Works
				Core.Align(Character["Left Arm"], Dummy["Left Arm"])
				if IsBulletEnabled == true then
					if getgenv().PartDisconnecting == false then 
						Core.Align(BulletR6, Dummy["HumanoidRootPart"], CFrame.new(0,Off,0)) 
					end
				elseif IsBulletEnabled == false then
					Core.Align(Character["HumanoidRootPart"], Dummy["HumanoidRootPart"], CFrame.new(0,Off,0))	
				end
			elseif IsPermaDeath == false then 
				Core.Align(Character["HumanoidRootPart"], Dummy["HumanoidRootPart"], CFrame.new(0,Off,0))	
			end
		
			if IsBulletEnabled == true and IsPermaDeath == false then
				if getgenv().PartDisconnecting == false then
					Core.Align(BulletR6, Dummy["Left Arm"])
				end
				if HatReplicaR6 and Character:FindFirstChild(HatReplicaR6) then
					Character:FindFirstChild(HatReplicaR6).Handle.CFrame = Dummy["Left Arm"].CFrame * CFrame.Angles(math.rad(90),0,0)
				end
			else
				Core.Align(Character["Left Arm"], Dummy["Left Arm"])
			end
			Core.Align(Character["Torso"], Dummy["Torso"])
			Core.Align(Character["Right Arm"], Dummy["Right Arm"])
			Core.Align(Character["Right Leg"], Dummy["Right Leg"])
			Core.Align(Character["Left Leg"], Dummy["Left Leg"])
		else
			if R15ToR6 == true then
				Character.PrimaryPart = Character["UpperTorso"] -- Net Fix
				Core.Align(Character["UpperTorso"], Dummy["Torso"], Core.Offsets.UpperTorso)
				Core.Align(Character["HumanoidRootPart"], Character["UpperTorso"], CFrame.new(0,Off2,0))
				Core.Align(Character["LowerTorso"], Dummy["Torso"], Core.Offsets.LowerTorso)
				if IsBulletEnabled == true then
					if getgenv().PartDisconnecting == false then
						Core.Align(BulletR15, Dummy["Left Arm"])
					end
					if HatReplicaR15 and Character:FindFirstChild(HatReplicaR15) then
						Character:FindFirstChild(HatReplicaR15).Handle.CFrame = Dummy["Left Arm"].CFrame * CFrame.new(0,0.5085,0)
					end
				else
					Core.Align(Character["LeftUpperArm"], Dummy["Left Arm"], Core.Offsets.UpperArm)
				end
				Core.Align(Character["RightUpperArm"], Dummy["Right Arm"], Core.Offsets.UpperArm)
				Core.Align(Character["RightLowerArm"], Dummy["Right Arm"], Core.Offsets.LowerArm)
				Core.Align(Character["RightHand"], Dummy["Right Arm"], Core.Offsets.Hand)

				Core.Align(Character["LeftLowerArm"], Dummy["Left Arm"], Core.Offsets.LowerArm)
				Core.Align(Character["LeftHand"], Dummy["Left Arm"], Core.Offsets.Hand)
							
				Core.Align(Character["RightUpperLeg"], Dummy["Right Leg"], Core.Offsets.UpperLeg)
				Core.Align(Character["RightLowerLeg"], Dummy["Right Leg"], Core.Offsets.LowerLeg)
				Core.Align(Character["RightFoot"], Dummy["Right Leg"], Core.Offsets.Foot)
										
				Core.Align(Character["LeftUpperLeg"], Dummy["Left Leg"], Core.Offsets.UpperLeg)
				Core.Align(Character["LeftLowerLeg"], Dummy["Left Leg"], Core.Offsets.LowerLeg)
				Core.Align(Character["LeftFoot"], Dummy["Left Leg"], Core.Offsets.Foot)
			else
				Core.Align(Character["UpperTorso"], Dummy["UpperTorso"])
				Core.Align(Character["HumanoidRootPart"], Character["UpperTorso"], CFrame.new(0,Off2,0))
				Core.Align(Character["LowerTorso"], Dummy["LowerTorso"])

				Core.Align(Character["RightUpperArm"], Dummy["RightUpperArm"])
				Core.Align(Character["RightLowerArm"], Dummy["RightLowerArm"])
				Core.Align(Character["RightHand"], Dummy["RightHand"])

				Core.Align(Character["LeftUpperArm"], Dummy["LeftUpperArm"])
				Core.Align(Character["LeftLowerArm"], Dummy["LeftLowerArm"])
				Core.Align(Character["LeftHand"], Dummy["LeftHand"])

				Core.Align(Character["RightUpperLeg"], Dummy["RightUpperLeg"])
				Core.Align(Character["RightLowerLeg"], Dummy["RightLowerLeg"])
				Core.Align(Character["RightFoot"], Dummy["RightFoot"])

				Core.Align(Character["LeftUpperLeg"], Dummy["LeftUpperLeg"])
				Core.Align(Character["LeftLowerLeg"], Dummy["LeftLowerLeg"])
				Core.Align(Character["LeftFoot"], Dummy["LeftFoot"])	
			end
		end
	end)
end)
getgenv().OGChar = Character -- Make A Variable for character to manage it easier
game.Players.LocalPlayer.Character = Dummy -- All scripts will go to dummy instead of your character
if IsPermaDeath == true then
	task.spawn(function()
		Core.PermaDeath(Character)
	end)
end
-- Disconnecting Parts
table.insert(Events, DummyHumanoid.Died:Connect(function()
	Core.Resetting(Events, Character, Dummy)
end))
if IsPermaDeath == false then
	table.insert(Events, Humanoid.Died:Connect(function()
		Core.Resetting(Events, Character, Dummy)
	end))
end
table.insert(Events, game.Players.LocalPlayer.CharacterAdded:Connect(function()
	Core.Resetting(Events, Character, Dummy)
end))
-- Animations
if AreAnimationsDisabled ~= true then
	if PlayerRigType == "R6" then
		Core.Animations()
	elseif PlayerRigType == "R15" and R15ToR6 == true then
		Core.Animations()
	elseif PlayerRigType == "R15" and R15ToR6 == false then
		local Anim = Character.Animate:Clone()
		Dummy.Animate:Destroy()
		Anim.Parent = Dummy
		Anim.Disabled = false
	end
end
if IsLoadLibraryEnabled == true then
	Core.LoadLibrary()
end
Core.Notification("Loaded! By: Gelatek \n (Thanks: CenteredSniper, Mizt, MW)")
print("Gelatek Reanimate - Loaded! Version: 1.1.2")
