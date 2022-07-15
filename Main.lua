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
------------------ Start
do
	if not game:IsLoaded() then
		error("Gelatek Reanimate - Game Not Loaded!")
		return
	end
	if workspace:FindFirstChild("GelatekReanimate") then
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Gelatek Reanimation (V7)",
			Text = "Reanimation Already Running! Reset to continue."
		})
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
if not getgenv().TableOfEvents then
	getgenv().TableOfEvents = {}
end
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
if R15ToR6 == false then
	IsBulletEnabled = false
	IsTorsoFling = false
	warn("R15ToR6 Is disabled! Disabling TorsoFling/BulletEnabled")
end
--// Functions
local HiddenProps = sethiddenproperty or set_hidden_property or function() end 
	
local SimulationRadius = setsimulationradius or set_simulation_radius or function() end 

local SetScript = setscriptable or function() end


local IsPlayerDead, Events, PlayerRigType, HatReplicaR6, BulletR6, HatReplicaR15, BulletR15, Velocity, PartFling = false, {}, "", nil, nil, nil, nil, Vector3.new(0,25.05,0), PartFling
--// SimpleAPI
warn("Gelatek Reanimate - Default Animations Disabled: "..tostring(AreAnimationsDisabled))
warn("Gelatek Reanimate - Permament Death: "..tostring(IsPermaDeath))
warn("Gelatek Reanimate - Torso Fling: "..tostring(IsTorsoFling))
warn("Gelatek Reanimate - Bullet Enabled: "..tostring(IsBulletEnabled))


local Core = {
	Offsets = {
		["UpperTorso"] = CFrame.new(0,0.194,0),
		["LowerTorso"] = CFrame.new(0,-0.79,0), 
		["Root"] = CFrame.new(0,-0.0025,0),
			
		["UpperArm"] = CFrame.new(0,0.4085,0),
		["LowerArm"] = CFrame.new(0,-0.184,0),
		["Hand"] = CFrame.new(0,-0.83,0),
			
		["UpperLeg"] = CFrame.new(0,0.575,0),
		["LowerLeg"] = CFrame.new(0,-0.199,0),
		["Foot"] = CFrame.new(0,-0.849,0)
	},
	LoadLibrary = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/StrokeThePea/GelatekReanimate/main/Addons/LoadLibrary.lua"))()
	end,
	Animations = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/StrokeThePea/GelatekReanimate/main/Addons/Animations.lua"))()
	end,
	ReCreateAccessoryWelds = function(Model,Accessory) -- Inspiration from DevForum Post made by admin.
		if not Accessory:IsA("Accessory") then return end

		local Handle = Accessory:FindFirstChild("Handle")
		pcall(function() Handle:FindFirstChild("AccessoryWeld"):Destroy() end)

		local NewWeld = Instance.new("Weld")
		NewWeld.Parent = Accessory.Handle
		NewWeld.Name = "AccessoryWeld"
		NewWeld.Part0 = Handle

		local Attachment = Handle:FindFirstChildOfClass("Attachment")

		if Attachment then
			NewWeld.C0 = Attachment.CFrame
			NewWeld.C1 = Model:FindFirstChild(tostring(Attachment), true).CFrame
			NewWeld.Part1 = Model:FindFirstChild(tostring(Attachment), true).Parent
		else
			NewWeld.Part1 = Model:FindFirstChild("Head")
			NewWeld.C1 = CFrame.new(0,Model:FindFirstChild("Head").Size.Y / 2,0) * Accessory.AttachmentPoint:Inverse()
		end

		Handle.CFrame = NewWeld.Part1.CFrame * NewWeld.C1 * NewWeld.C0:Inverse()
	end,
	Notification = function(Text)
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Gelatek Reanimation (V7)",
			Text = Text
		})
	end,
	Align = function(Part0,Part1,OffSetPos,OffsetAngles)
		local network = isnetworkowner or is_network_owner or function() return true end
		local Pos = OffSetPos or CFrame.new(0,0,0)
		local Angles = OffsetAngles or CFrame.Angles(0,0,0)
		if network(Part0) == true then
			Part0.CFrame = Part1.CFrame * Pos * Angles
		end
	end,
	DestroyBodyResizers = function(HumanOid)
		for Index,Object in pairs(HumanOid:GetChildren()) do
			if Object:IsA("NumberValue") then -- (R15 Only) Destroys numbervalues in humanoid to reset body size. 
				Object:Destroy()
				task.wait(0.025) -- Cooldown so it does not trigger in games
			end
		end
	end,
	DisableCollisions = function(Table1, Table2)
		for i,v in pairs(Table1) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
		for i,v in pairs(Table2) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end,
	Movement = function(Humanoid1, Humanoid2)
		local Tracks = Humanoid1:GetPlayingAnimationTracks()
		for Index,Track in pairs(Tracks) do
			Track:Stop()
		end
		Humanoid2:Move(Humanoid1.MoveDirection,false)
	end,
	Jumping = function(Humanoid)
		Humanoid.Jump = true
		Humanoid.Sit = false
	end,
	DisableScripts = function(Model)
		for i,v in pairs(Model:GetChildren()) do
			if v:IsA("LocalScript") then
				v.Disabled = true
			end
		end
	end,
	Network = function()
		-- thanks phere for synapse net
		game.Players.LocalPlayer.ReplicationFocus = workspace
		game.Players.LocalPlayer.MaximumSimulationRadius = 9e8
		if syn then
			if identifyexecutor then
				SimulationRadius(9e8)	
			end
		else
			SimulationRadius(9e8)
		end
	end,
	CreateSignal = function(DataModel,Name,Callback)
		local Service = game:GetService(DataModel)
		table.insert(Events,Service[Name]:Connect(Callback))
	end,
	CreateDummy = function(Name,Parent)
		local Dummy = game:GetService("ReplicatedStorage"):FindFirstChild("FrostwareData").R6FakeRig:Clone() 
		Dummy.Name = Name or "anus"
		for i,v in pairs(Dummy:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then
				v.Transparency = 1
			end
		end
		Dummy.Parent = Parent or workspace
	end,
	Resetting = function(Model1,Model2)
		Model1.Parent = workspace
		game.Players.LocalPlayer.Character = workspace[Model1.Name]
		Model2:Destroy()
		Model1:BreakJoints()
		IsPlayerDead = true
		getgenv().OGChar = nil
		if getgenv().PartDisconnecting then
			getgenv().PartDisconnecting = nil
		end
		for i,v in pairs(Events) do
			v:Disconnect()
		end
		for i,v in pairs(getgenv().TableOfEvents) do
			v:Disconnect()
		end
		if workspace:FindFirstChild("ScriptCheck") then
			workspace:FindFirstChild("ScriptCheck"):Destroy()
		end
	end,	
	PermaDeath = function(Model)
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
		task.wait(game:GetService("Players").RespawnTime + 0.65)
		local Head = Model:FindFirstChild("Head")
		Head:BreakJoints() 
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
	end,
	BreakJoints = function(Model)
		for i,v in pairs(Model:GetDescendants()) do
			if v:IsA("Motor6D") and v.Name ~= "Neck" then
				v:Destroy()
			elseif v.Name == "AccessoryWeld" then
				v:Destroy()
			end
		end
	end,
	GetRig = function(Humanoid)
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			return "R15"
		else
			return "R6"
		end
	end,
	MiztRenamer = function(Table)
		local HatsNameTable = {}
		for Index, Accessory in next, Table do
			if Accessory:IsA("Accessory") then
				if HatsNameTable[Accessory.Name] then
					if HatsNameTable[Accessory.Name] == "s" then
						HatsNameTable[Accessory.Name] = {}
					end
					table.insert(HatsNameTable[Accessory.Name], Accessory)
				else
					HatsNameTable[Accessory.Name] = "s"
				end	
			end
		end
		for Index, Strings in pairs(HatsNameTable) do
			if type(Strings) == "table" then
				local Number = 1
				for Index2, Names in pairs(Strings) do
					Names.Name = Names.Name .. Number
					Number = Number + 1
				end
			end
		end
		table.clear(HatsNameTable)
	end,
	CreateOutline = function(Part)
		local Outline = Instance.new("SelectionBox")
		Outline.LineThickness = 0.02
		Outline.Adornee = Part
		Outline.Parent = Part
	end
}

do 
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	settings().Physics.AllowSleep = false
	settings().Physics.ForceCSGv2 = false
	settings().Physics.DisableCSGv2 = true
	settings().Physics.UseCSGv2 = false
	settings().Physics.ThrottleAdjustTime = math.huge
	workspace.FallenPartsDestroyHeight = -math.huge
	game.Players.LocalPlayer.ReplicationFocus = workspace
	
	SetScript(workspace,  "PhysicsSteppingMethod", true)
	HiddenProps(workspace,"PhysicsSteppingMethod",Enum.PhysicsSteppingMethod.Fixed)
	
	SetScript(workspace,  "PhysicsSimulationRateReplicator", true)
	HiddenProps(workspace,"PhysicsSimulationRateReplicator",Enum.PhysicsSimulationRate.Fixed240Hz)
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
Core.CreateSignal("RunService", "Stepped", function()
	Core.DisableCollisions(CharDescendants, DummyDescendants)
	Core.Movement(Humanoid, DummyHumanoid)
	Core.Network()
end)

-- Jumping
Core.CreateSignal("UserInputService", "JumpRequest", function()
	Core.Jumping(DummyHumanoid)
end)

--
local Off = 1
local Off2 = 0.07
task.spawn(function()
	while wait(0.05) do
		if IsPlayerDead then
			break
		end
		Off2 *= -1
		Off *= -1 
	end
end)
-- Velocity/Main Part
Core.CreateSignal("RunService", "Heartbeat", function()
	Velocity = Vector3.new(Dummy["HumanoidRootPart"].AssemblyLinearVelocity.X * 5, 25.05, Dummy["HumanoidRootPart"].AssemblyLinearVelocity.Z * 5)
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
			Character:FindFirstChild(PartFling).Velocity = Vector3.new(1500,1500,1500)
		else
			Character:FindFirstChild(PartFling).Velocity = Velocity
			Character:FindFirstChild(PartFling).RotVelocity = Vector3.new(2000,2000,2000)
		end
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
				else
					Core.Align(Character["HumanoidRootPart"], Dummy["HumanoidRootPart"], CFrame.new(0,Off,0))	
				end
            else
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
				Character["HumanoidRootPart"].Transparency = 0
				Core.Align(Character["UpperTorso"], Dummy["Torso"], Core.Offsets.UpperTorso)
				Core.Align(Character["HumanoidRootPart"], Character["UpperTorso"], CFrame.new(0,Off2,0))
				Core.Align(Character["LowerTorso"], Dummy["Torso"], Core.Offsets.LowerTorso)
				
				if IsBulletEnabled == true then -- Ugly Code But Works
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
	Core.Resetting(Character, Dummy)
end))
if IsPermaDeath == false then
	table.insert(Events, Humanoid.Died:Connect(function()
		Core.Resetting(Character, Dummy)
	end))
end
table.insert(Events, game.Players.LocalPlayer.CharacterAdded:Connect(function()
	Core.Resetting(Character, Dummy)
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
