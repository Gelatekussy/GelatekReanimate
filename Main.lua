local Player = game:GetService("Players").LocalPlayer
local HiddenProps = sethiddenproperty or set_hidden_property or function() end 
local SimulationRadius = setsimulationradius or set_simulation_radius or function() end 
local SetScript = setscriptable or function() end
local IsPlayerDead = false
local Events = {}
local PlayerRigType = ""
local HatReplicaR6, BulletR6 = nil
local HatReplicaR15, BulletR15 = nil
local Velocity = Vector3.new(30,0,0)
local PartFling = nil
local Offset = 1
local R6TorsoVel = Vector3.new(1000,1000,1000)
if not getgenv().TableOfEvents then
	getgenv().TableOfEvents = {}
end

--// Configs

do --// Checking
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	if workspace:FindFirstChild("GelatekReanimate") then
		error("REANIMATE_ALREADY_RUNNING")
	end
	if Player.Character.Humanoid.Health == 0 then
		error("PLAYER_NOT_ALIVE")
	end
	if not getgenv().GelatekReanimateConfig then
		getgenv().GelatekReanimateConfig = {
			["AnimationsDisabled"] = false,
			["R15ToR6"] = false,
			["PermanentDeath"] = false,
			["TorsoFling"] = false,
			["BulletEnabled"] = false,
			["LoadLibrary"] = false,
			["NewVelocityMethod"] = false,
			["BulletConfig"] = {
				["RunAfterReanimate"] = false,
				["LockBulletOnTorso"] = false
			}
		}
	end
	if not game:GetService("ReplicatedStorage"):FindFirstChild("GelatekReanimateData") then
		local Folder = Instance.new("Folder")
		Folder.Name = "GelatekReanimateData"
		Folder.Parent = game:GetService("ReplicatedStorage")
		local Clone = game:GetObjects("rbxassetid://8440552086")[1]
		Clone.Name = "R6FakeRig"
		Clone.Parent = Folder
		task.wait(0.65)
	end
end


local AreAnimationsDisabled = getgenv().GelatekReanimateConfig.AnimationsDisabled or false
local IsPermaDeath = getgenv().GelatekReanimateConfig.PermanentDeath or false
local IsBulletEnabled = getgenv().GelatekReanimateConfig.BulletEnabled or false
local IsTorsoFling = getgenv().GelatekReanimateConfig.TorsoFling or false
local IsLoadLibraryEnabled = getgenv().GelatekReanimateConfig.LoadLibrary or false
local R15ToR6 = getgenv().GelatekReanimateConfig.R15ToR6 or false
local NewVelocityMethod = getgenv().GelatekReanimateConfig.NewVelocityMethod or false
local DontBreakHairWelds = getgenv().GelatekReanimateConfig.DontBreakHairWelds or false
local BulletConfig = getgenv().GelatekReanimateConfig.BulletConfig or {}
local BulletAfterReanim = BulletConfig.RunAfterReanimate or false
local LockBulletOnTorso = BulletConfig.LockBulletOnTorso or false
local Core = { --// API Used to store functions easier
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
	ReCreateWelds = function(Model,Accessory) -- Inspiration from DevForum Post made by admin.
		local Handle = Accessory:FindFirstChild("Handle")
		pcall(function() Handle:FindFirstChild("AccessoryWeld"):Destroy() end)
		local NewWeld = Instance.new("Weld")
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
		
		NewWeld.Parent = Accessory.Handle
	end,
	GetLoadLibrary = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/StrokeThePea/GelatekReanimate/main/Addons/LoadLibrary.lua"))()
	end,
	Animations = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/StrokeThePea/GelatekReanimate/main/Addons/Animations.lua"))()
	end,
	Notification = function(Text)		
		task.spawn(function()
			local Message = Instance.new("Message")
			Message.Text = "Gelatek Reanimate: "..Text
			Message.Parent = workspace
			task.wait(3)
			Message:Destroy()
		end)
	end,
	Align = function(Part0,Part1,OffSetPos,OffsetAngles)
		local NetworkChecking = isnetworkowner or is_network_owner or function(Part) return Part.ReceiveAge == 0 end
		local Pos = OffSetPos or CFrame.new(0,0,0)
		local Angle = OffsetAngles or CFrame.Angles(0,0,0)
		if NetworkChecking(Part0) == true then
			Part0.CFrame = Part1.CFrame * Pos * Angle
		end
	end,
	DisableCollisions = function(Table)
		for Index, Part in ipairs(Table) do
			if Part:IsA("BasePart") then
				if Part and Part.Parent then
					Part.CanCollide = false
				end
			end
		end
	end,
	DisableScripts = function(Table)
		for Index,Scripts in ipairs(Table) do
			if Scripts:IsA("LocalScript") or Scripts:IsA("Script") then
				Scripts.Disabled = true
			end
		end
	end,
	Network = function()
		if syn then
			pcall(function()
				SetScript(Player, "SimulationRadius", true)
			end)
		end
		HiddenProps(Player, "MaximumSimulationRadius", 2763+1e5)
		HiddenProps(Player, "SimulationRadius", 2763+1e5)
	end,
	CreateSignal = function(DataModel,Name,Callback)
		local Service = game:GetService(DataModel)
		table.insert(Events,Service[Name]:Connect(Callback))
	end,
	CreateDummy = function(Name)
		local Dummy = game:GetService("ReplicatedStorage"):FindFirstChild("GelatekReanimateData").R6FakeRig:Clone() 
		Dummy.Name = Name or "Reanimate"
		for Index,Misc in ipairs(Dummy:GetDescendants()) do
			if Misc:IsA("BasePart") or Misc:IsA("Decal") then
				Misc.Transparency = 1
			end
		end
		Dummy.Parent = game:GetService("Workspace") -- hahahahaf
	end,
	Resetting = function(Model1,Model2)
		if Model1 and Model1.Parent then
			Model1.Parent = workspace
		end
		game.Players.LocalPlayer.Character = workspace[Model1.Name]
		Model2:Destroy(); Model1:BreakJoints()
		-- Remove Vars, Disconnect Events
		IsPlayerDead = true
		getgenv().OGChar = nil
		getgenv().PartDisconnecting = nil
		for i,v in ipairs(Events) do
			v:Disconnect()
		end
		for i,v in ipairs(getgenv().TableOfEvents) do
			v:Disconnect()
		end
	end,	
	PermaDeath = function(Model)
		task.spawn(function()
			game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
			task.wait(game:GetService("Players").RespawnTime + game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 750)
			local Head = Model:FindFirstChild("Head")
			Head:BreakJoints() 
			game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
		end)
	end,
	BreakJoints = function(Table)
		for Index, Joint in ipairs(Table) do
			if Joint:IsA("Motor6D") and Joint.Name ~= "Neck" then
				Joint:Destroy()
			elseif Joint.Name == "AccessoryWeld" then
				-- DontBreakHairWelds = false // break
				-- DontBreakHairWelds = true \\ dont break
				if IsPermaDeath == true then
					Joint:Destroy()
				elseif IsPermaDeath == false then
					local Attachment = Joint.Parent:FindFirstChildOfClass("Attachment")
					if DontBreakHairWelds == true then
						if Attachment.Name ~= "HatAttachment" and Attachment.Name ~= "FaceFrontAttachment" and Attachment.Name ~= "HairAttachment" and Attachment.Name ~= "FaceCenterAttachment" then
							Joint:Destroy()
						end
					else
						Joint:Destroy()
					end
				end	
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
	HatRenamer = function(Table)
		local HatsNameTable = {}
		for Index, Accessory in next, Table do
			if Accessory:IsA("Accessory") then
				if HatsNameTable[Accessory.Name] then
					if HatsNameTable[Accessory.Name] == "Unknown" then
						HatsNameTable[Accessory.Name] = {}
					end
					table.insert(HatsNameTable[Accessory.Name], Accessory)
				else
					HatsNameTable[Accessory.Name] = "Unknown"
				end	
			end
		end
		for Index, Tables in ipairs(HatsNameTable) do
			if type(Tables) == "table" then
				local Number = 1
				for Index2, Names in ipairs(Tables) do
					Names.Name = Names.Name .. Number
					Number = Number + 1
				end
			end
		end
		table.clear(HatsNameTable)
	end,
	CreateOutline = function(Part, Parent)
		local SelectionBox = Instance.new("SelectionBox")
		SelectionBox.LineThickness = 0.05
		SelectionBox.Name = "FlingerHighlighter"
		SelectionBox.Adornee = Part
		SelectionBox.Parent = Parent
	end
}



--// Rig Variables
local OriginalRig = Player["Character"]
local OriginalHum = OriginalRig:WaitForChild("Humanoid")
local OriginalRigDescendants = OriginalRig:GetDescendants()
local OriginalRigChildren = OriginalRig:GetChildren()
local OriginalHumTracks = OriginalHum:GetPlayingAnimationTracks()
local PlayerRigType = Core.GetRig(OriginalHum)
OriginalRig.Archivable = true
pcall(function()
	OriginalRig:FindFirstChild("Local Ragdoll"):Destroy()
	OriginalRig:FindFirstChild("State Handler"):Destroy()
	OriginalRig:FindFirstChild("Controls"):Destroy()
	OriginalRig:FindFirstChild("FirstPerson"):Destroy()
	OriginalRig:FindFirstChild("FakeAdmin"):Destroy()

	for Index, RagdollStuff in ipairs(OriginalRigDescendants) do
		if RagdollStuff:IsA("BallSocketConstraint") or RagdollStuff:IsA("HingeConstraint") then
			RagdollStuff:Destroy()
		end
	end
end)

do --// Fix/Print Configs
	if IsTorsoFling == true and IsBulletEnabled == true then
		IsTorsoFling = false
		warn("Gelatek Reanimate - TorsoFling and BulletEnabled are both true! Disabling TorsoFling")
	end
	if R15ToR6 == false and PlayerRigType == "R15" then
		IsBulletEnabled = false
		IsTorsoFling = false
		warn("Gelatek Reanimate - R15ToR6 Is disabled! Disabling TorsoFling/BulletEnabled")
	end
	warn("Gelatek Reanimate - Default Animations Disabled: "..tostring(AreAnimationsDisabled))
	warn("Gelatek Reanimate - R15 To R6: "..tostring(R15ToR6))
	warn("Gelatek Reanimate - Permament Death: "..tostring(IsPermaDeath))
	warn("Gelatek Reanimate - Torso Fling: "..tostring(IsTorsoFling))
	warn("Gelatek Reanimate - Bullet Enabled: "..tostring(IsBulletEnabled))
	warn("Gelatek Reanimate - LoadLibrary Enabled: "..tostring(IsLoadLibraryEnabled))
	warn("Gelatek Reanimate - New Velocity Method: "..tostring(NewVelocityMethod))
end

do --// Optimizations/Boosting
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	settings().Physics.AllowSleep = false
	settings().Physics.ForceCSGv2 = false
	settings().Physics.DisableCSGv2 = true
	settings().Physics.UseCSGv2 = false
	settings().Physics.ThrottleAdjustTime = math.huge
	settings().Rendering.EagerBulkExecution = true
	game.Players.LocalPlayer.ReplicationFocus = workspace
	HiddenProps(workspace, "PhysicsSteppingMethod", Enum.PhysicsSteppingMethod.Fixed)
	HiddenProps(workspace, "PhysicsSimulationRateReplicator", Enum.PhysicsSimulationRate.Fixed240Hz)
	Core.DisableScripts(OriginalRigChildren)
	if IsTorsoFling == false then OriginalHum:ChangeState(Enum.HumanoidStateType.Physics) end
	if setfpscap then setfpscap(60) end
end

do --// Dummy Creation
	if PlayerRigType == "R6" or (PlayerRigType == "R15" and R15ToR6 == true) then
		Core.CreateDummy("GelatekReanimate", workspace) -- Dummy Creation
	elseif PlayerRigType == "R15" and R15ToR6 == false then
		local Dummy = OriginalRig:Clone() 
		Dummy.Name = "GelatekReanimate"
		for Index, Misc in ipairs(Dummy:GetDescendants()) do
			if Misc:IsA("BasePart") or Misc:IsA("Decal") then
				Misc.Transparency = 1
			end
			if Misc:IsA("Accessory") then
				Misc:Destroy()
			end
		end
		Dummy.Parent = workspace
	end
end

local FakeRig = workspace:WaitForChild("GelatekReanimate")
local FakeHum = FakeRig:FindFirstChildOfClass("Humanoid")
local FakeRigDescendants = FakeRig:GetDescendants()
local FakeRigChildren = FakeRig:GetChildren()
FakeHum.BreakJointsOnDeath = false
FakeRig:MoveTo(OriginalRig.HumanoidRootPart.Position)
Core.BreakJoints(OriginalRigDescendants)
OriginalRig.Parent = FakeRig
pcall(function() workspace:FindFirstChildOfClass("Camera").CameraSubject = FakeHum end)
for Index,Track in ipairs(OriginalHumTracks) do
	Track:Stop()
end
do --// AccessoryWeld Recreation (Fix Offsets)
	Core.HatRenamer(OriginalRigChildren)
	for Index,Part in pairs(OriginalRigChildren) do
		if Part:IsA("Accessory") then
			local FakeHats1 = Part:Clone()
			FakeHats1.Handle.Transparency = 1
			Core.ReCreateWelds(FakeRig, FakeHats1)
			FakeHats1.Parent = FakeRig
		end
	end
end

do --// Bullet/Collision Fling Checking
	if IsBulletEnabled == true then
		getgenv().PartDisconnecting = false
		if PlayerRigType == "R6" then
			BulletR6 = OriginalRig["Left Arm"]
			HatReplicaR6 = OriginalRig:FindFirstChild("Robloxclassicred")
			if IsPermaDeath == true then
				BulletR6 = OriginalRig["HumanoidRootPart"]
				HatReplicaR6 = nil
			end
			if HatReplicaR6 then
				HatReplicaR6.Handle:ClearAllChildren()
			end
			BulletR6.Name = "Bullet"
			BulletR6.Transparency = 0.65
			Core.CreateOutline(BulletR6, FakeRig)
		elseif PlayerRigType == "R15" then -- Overcomplicating to make the code more readable.
			BulletR15 = OriginalRig["LeftUpperArm"]
			BulletR15.Name = "Bullet"
			HatReplicaR15 = OriginalRig:FindFirstChild("SniperShoulderL")
			Core.CreateOutline(BulletR15, FakeRig)
		end
	end
	
	if IsTorsoFling == true then
		PartFling = OriginalRig:FindFirstChild("Torso") or OriginalRig:FindFirstChild("HumanoidRootPart")
		Core.CreateOutline(PartFling, FakeRig)
	end
end

Core.CreateSignal("RunService", "Stepped", function() -- Disable Collisions, Movement, Velocity Receiver and Net Claimer
	Core.DisableCollisions(OriginalRigDescendants)
	Core.DisableCollisions(FakeRigDescendants)
	Core.Network()
	for Index,Track in ipairs(OriginalHumTracks) do
		Track:Stop()
	end
	FakeHum:Move(OriginalHum.MoveDirection, false)
	if NewVelocityMethod == true then
		Velocity = Vector3.new(FakeRig["HumanoidRootPart"].CFrame.LookVector.X * 85, FakeRig["HumanoidRootPart"].AssemblyLinearVelocity.Y * 10, FakeRig["HumanoidRootPart"].CFrame.LookVector.Z * 85)
	else
		Velocity = Vector3.new(FakeRig["HumanoidRootPart"].AssemblyLinearVelocity.X * 5, 25.32, FakeRig["HumanoidRootPart"].AssemblyLinearVelocity.Z * 5)
	end
end)

Core.CreateSignal("UserInputService", "JumpRequest", function() -- Jumping
	FakeHum.Jump = true
	FakeHum.Sit = false
end)
local BVT = {}
do --// Extra Properties, Anchor Claim
	task.wait()
	for Index,Part in ipairs(OriginalRigDescendants) do
		if Part:IsA("BasePart") then
			Part:ApplyImpulse(Vector3.new(30,0,0))
			Part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
			Part.RootPriority = 127
			Part.Massless = true
			local ABV = Instance.new("BodyAngularVelocity")
			ABV.P = 27632763276327632763276327632763276327632763
			ABV.MaxTorque = Vector3.new(27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763)
			ABV.AngularVelocity = Vector3.new(0,0,0)
			ABV.Name = "AntiRotation"
			ABV.Parent = Part
			local BV = Instance.new("BodyVelocity")
			BV.P = 27632763276327632763276327632763276327632763
			BV.MaxForce = Vector3.new(27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763)
			BV.Velocity = Vector3.new(0,0,0)
			BV.Name = "Stabilition"
			BV.Parent = Part
			table.insert(BVT,BV)
		end
	end
end

task.spawn(function()
	if IsPermaDeath == false then
		R6TorsoVel = Vector3.new(30,30,30)
		task.wait(2.5)
		R6TorsoVel = Vector3.new(1500,1500,1500)
	else
		R6TorsoVel = Vector3.new(30,30,30)
		task.wait(6)
		R6TorsoVel = Vector3.new(1500,1500,1500)
	end
end)
coroutine.wrap(function() --// Delayless Method; Used for root Y cframing.
	while task.wait(0.01) do
		if IsPlayerDead then
			break
		end
		Offset = Offset * -1
	end
end)()

if IsPermaDeath == true then
	Core.PermaDeath(OriginalRig)
end
Core.CreateSignal("RunService", "Heartbeat", function() -- Main Part (Velocity, CFraming)
	for Index,BV in ipairs(BVT) do
		BV.Velocity = Velocity
	end
	for Index,Part in ipairs(OriginalRigDescendants) do
		if Part:IsA("BasePart") and (not PartFling) then
			if Part and Part.Parent then
				Part.Velocity = Velocity
				HiddenProps(Part, "NetworkIsSleeping", false)
				HiddenProps(Part, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
			end
		elseif Part:IsA("Accessory") then
			if Part and Part.Parent and Part:FindFirstChild("Handle") then
				Core.Align(Part.Handle, FakeRig[Part.Name].Handle)
			end
		end
	end
	
	if PartFling then
		if PlayerRigType == "R6" then
			PartFling.Velocity = R6TorsoVel + Velocity
			PartFling.AssemblyAngularVelocity = Vector3.new(0,0,0)
		else
			PartFling.Velocity = Velocity
			PartFling.RotVelocity = Vector3.new(800,800,800)
		end
	end
	pcall(function()
		if IsPermaDeath == true then
			Core.Align(OriginalRig.Head, FakeRig.Head)
		end
		if PlayerRigType == "R6" then
			if IsBulletEnabled == true then
				if HatReplicaR6 and HatReplicaR6:FindFirstChild("Handle") then
					Core.Align(HatReplicaR6.Handle, FakeRig['Left Arm'], CFrame.new(),CFrame.Angles(math.rad(90),0,0))
				end
				if getgenv().PartDisconnecting == false then
					if BulletR6.Size == Vector3.new(1,2,1) then
						Core.Align(BulletR6, FakeRig['Left Arm']); Core.Align(OriginalRig['HumanoidRootPart'], FakeRig['HumanoidRootPart'], CFrame.new(0,Offset,0))
					end
					if BulletR6.Size == Vector3.new(2,2,1) then
						Core.Align(BulletR6, FakeRig['HumanoidRootPart'], CFrame.new(0,Offset,0)); Core.Align(OriginalRig['Left Arm'], FakeRig['Left Arm'])
					end
				end
			else
				Core.Align(OriginalRig['Left Arm'], FakeRig['Left Arm']); Core.Align(OriginalRig['HumanoidRootPart'], FakeRig['HumanoidRootPart'], CFrame.new(0,Offset,0))
			end
			
			Core.Align(OriginalRig['Torso'], FakeRig['Torso'])
			Core.Align(OriginalRig['Right Arm'], FakeRig['Right Arm'])
			Core.Align(OriginalRig['Right Leg'], FakeRig['Right Leg'])
			Core.Align(OriginalRig['Left Leg'], FakeRig['Left Leg'])
		elseif PlayerRigType == "R15" then
			if R15ToR6 == true then
				Core.Align(OriginalRig["UpperTorso"], FakeRig["Torso"], Core.Offsets.UpperTorso)
				Core.Align(OriginalRig["HumanoidRootPart"], OriginalRig["UpperTorso"])
				Core.Align(OriginalRig["LowerTorso"], FakeRig["Torso"], Core.Offsets.LowerTorso)
				
				if IsBulletEnabled == true then
					if HatReplicaR15 and HatReplicaR15:FindFirstChild("Handle") then
						Core.Align(HatReplicaR15.Handle, FakeRig['Left Arm'], CFrame.new(0,0.5085,0))
					end
					if getgenv().PartDisconnecting == false then
						Core.Align(BulletR15, FakeRig["Left Arm"], Core.Offsets.UpperArm)
					end
				else
					Core.Align(OriginalRig["LeftUpperArm"], FakeRig["Left Arm"], Core.Offsets.UpperArm)
				end
				Core.Align(OriginalRig["RightUpperArm"], FakeRig["Right Arm"], Core.Offsets.UpperArm)
				Core.Align(OriginalRig["RightLowerArm"], FakeRig["Right Arm"], Core.Offsets.LowerArm)
				Core.Align(OriginalRig["RightHand"], FakeRig["Right Arm"], Core.Offsets.Hand)

				Core.Align(OriginalRig["LeftLowerArm"], FakeRig["Left Arm"], Core.Offsets.LowerArm)
				Core.Align(OriginalRig["LeftHand"], FakeRig["Left Arm"], Core.Offsets.Hand)
								
				Core.Align(OriginalRig["RightUpperLeg"], FakeRig["Right Leg"], Core.Offsets.UpperLeg)
				Core.Align(OriginalRig["RightLowerLeg"], FakeRig["Right Leg"], Core.Offsets.LowerLeg)
				Core.Align(OriginalRig["RightFoot"], FakeRig["Right Leg"], Core.Offsets.Foot)
												
				Core.Align(OriginalRig["LeftUpperLeg"], FakeRig["Left Leg"], Core.Offsets.UpperLeg)
				Core.Align(OriginalRig["LeftLowerLeg"], FakeRig["Left Leg"], Core.Offsets.LowerLeg)
				Core.Align(OriginalRig["LeftFoot"], FakeRig["Left Leg"], Core.Offsets.Foot)
			else
				Core.Align(OriginalRig["UpperTorso"], FakeRig["UpperTorso"])
				Core.Align(OriginalRig["HumanoidRootPart"], OriginalRig["UpperTorso"])
				Core.Align(OriginalRig["LowerTorso"], FakeRig["LowerTorso"])

				Core.Align(OriginalRig["RightUpperArm"], FakeRig["RightUpperArm"])
				Core.Align(OriginalRig["RightLowerArm"], FakeRig["RightLowerArm"])
				Core.Align(OriginalRig["RightHand"], FakeRig["RightHand"])
				
				Core.Align(OriginalRig["LeftUpperArm"], FakeRig["LeftUpperArm"])
				Core.Align(OriginalRig["LeftLowerArm"], FakeRig["LeftLowerArm"])
				Core.Align(OriginalRig["LeftHand"], FakeRig["LeftHand"])

				Core.Align(OriginalRig["RightUpperLeg"], FakeRig["RightUpperLeg"])
				Core.Align(OriginalRig["RightLowerLeg"], FakeRig["RightLowerLeg"])
				Core.Align(OriginalRig["RightFoot"], FakeRig["RightFoot"])

				Core.Align(OriginalRig["LeftUpperLeg"], FakeRig["LeftUpperLeg"])
				Core.Align(OriginalRig["LeftLowerLeg"], FakeRig["LeftLowerLeg"])
				Core.Align(OriginalRig["LeftFoot"], FakeRig["LeftFoot"])	
			end
		end
	end)
end)

Player.Character = FakeRig
getgenv().OGChar = OriginalRig
Core.Notification("Loaded! By: Gelatek \n (Thanks: CenteredSniper, Mizt, MW)")

do --// Animations
	if AreAnimationsDisabled == false then
		if PlayerRigType == "R6" or (PlayerRigType == "R15" and R15ToR6 == true) then
			Core.Animations()
		elseif PlayerRigType == "R15" and R15ToR6 == false then
			local Anim = OriginalRig.Animate:Clone()
			FakeRig.Animate:Destroy()
			Anim.Parent = FakeRig
			Anim.Disabled = false
		end
	end
end
do --// Death Detectors
	table.insert(Events, FakeHum.Died:Connect(function()
		Core.Resetting(OriginalRig, FakeRig)
	end))
	if IsPermaDeath == false then
		table.insert(Events, OriginalHum.Died:Connect(function()
			Core.Resetting(OriginalRig, FakeRig)
		end))
	end
	table.insert(Events, Player.CharacterAdded:Connect(function()
		Core.Resetting(OriginalRig, FakeRig)
	end))
end

do -- Bullet Stuff
	if IsBulletEnabled == true and BulletAfterReanim == true then

	getgenv().PartDisconnecting = true

	local Players = game:GetService("Players")
	local Character = workspace:FindFirstChild("GelatekReanimate")
	local Bullet = getgenv().OGChar:FindFirstChild("Bullet")
	pcall(function()
	Bullet.Stabilition:Destroy()
	end)
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
				if LockBulletOnTorso == true then
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
					if Mouse.Target:IsA("BasePart") then
						BP.Position = Mouse.Hit.Position
					end
				end
			else
			   BP.Position = Character["HumanoidRootPart"].Position
			end
		end)
	end))
	
	end
end

if IsLoadLibraryEnabled == true then
	Core.LoadLibrary()
end

do -- Bug Reporting
	local Bindable = Instance.new("BindableFunction")
	local function Copy(e)
		setclipboard("https://discord.gg/3Qr97C4BDn")
		Bindable:Destroy()
	end
	Bindable.OnInvoke = Copy
	game.StarterGui:SetCore("SendNotification",{
			Title = "Found A Bug?\n Got a suggestion?";
			Text = "Click copy to get discord invite where you can report a bug! otherwise ignore.";
			Duration = 10;
			Callback = Bindable,
			Button1 = "Copy";
	})
end
