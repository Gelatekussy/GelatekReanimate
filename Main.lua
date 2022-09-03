game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
local Speed = tick()
local AdditionalStuff = getgenv().AdditionalStuff or false -- This is only for my hub, nothing should affect when it's true but i recommend not. (it will just create a folder with hats)
local Player = game:GetService("Players").LocalPlayer
local SpawnPoint = workspace:FindFirstChildOfClass("SpawnLocation",true) and workspace:FindFirstChildOfClass("SpawnLocation",true) or CFrame.new(0,20,0)
do --// Checking
	local function SadNotification(Text)
		task.spawn(function()
			game.StarterGui:SetCore("SendNotification",{
				Title = "Gelatek Reanimate";
				Text = Text or "aeia";
				Duration = 5;
			})
			local Sound = Instance.new("Sound")
			Sound.SoundId = "rbxassetid://5914602124"
			Sound.Parent = game:GetService("CoreGui")
			Sound:Play()
			task.wait(3)
			Sound:Destroy()
		end)
	end
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	if Player.Character == workspace:FindFirstChild("GelatekReanimate") then
		SadNotification("Reanimate Is Already Running!")
		error("REANIMATE_ALREADY_RUNNING")
	end
	if Player.Character.Humanoid.Health == 0 then
		SadNotification("Humanoid Is Dead! Reanimate after you respawn.")
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
			["TeleportBackWhenVoided"] = false,
			["MoreAccurateOffsets"] = false,
			["Headless"] = false,
			["BulletConfig"] = {
				["RunAfterReanimate"] = false,
				["BuffedBodyPosition"] = false,
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
		local IAmNotSorryOne = game:GetObjects("rbxassetid://48474313")[1]
		IAmNotSorryOne.Parent = Folder
		IAmNotSorryOne.Handle.Color = Color3.fromRGB(235,50,50)
		IAmNotSorryOne.Handle.Transparency = 0.15
		local IAmNotSorryOne = game:GetObjects("rbxassetid://5973840187")[1]
		IAmNotSorryOne.Parent = Folder
		IAmNotSorryOne.Handle.Color = Color3.fromRGB(255,0,0)
		IAmNotSorryOne.Handle.Transparency = 0.15
	end
end
	
local HiddenProps = sethiddenproperty or set_hidden_property or function() end 
local SimulationRadius = setsimulationradius or set_simulation_radius or function() end 
local SetScript = setscriptable or function() end
local NetworkChecking = isnetworkowner or is_network_owner or function(Part) return Part.ReceiveAge == 0 end
local IsPlayerDead = false
local Events = {}
local PlayerRigType = ""
local HatReplicaR6, BulletR6 = nil
local HatReplicaR15, BulletR15 = nil
local Velocity = Vector3.new(30,0,0)
local PartFling = nil
local Offset = 1
local OffsetR15 = 0.024
local FakeHatsFolder = nil
local R6TorsoVel = Vector3.new(1000,1000,1000)
local R15Funny = Vector3.new(2500,2500,2500)
if not getgenv().TableOfEvents then
	getgenv().TableOfEvents = {}
end
-- Configs
local AreAnimationsDisabled = getgenv().GelatekReanimateConfig.AnimationsDisabled or false
local IsPermaDeath = getgenv().GelatekReanimateConfig.PermanentDeath or false
local IsBulletEnabled = getgenv().GelatekReanimateConfig.BulletEnabled or false
local IsTorsoFling = getgenv().GelatekReanimateConfig.TorsoFling or false
local IsLoadLibraryEnabled = getgenv().GelatekReanimateConfig.LoadLibrary or false
local R15ToR6 = getgenv().GelatekReanimateConfig.R15ToR6 or false
local NewVelocityMethod = getgenv().GelatekReanimateConfig.NewVelocityMethod or false
local DontBreakHairWelds = getgenv().GelatekReanimateConfig.DontBreakHairWelds or false
local TeleportBackWhenVoided = getgenv().GelatekReanimateConfig.TeleportBackWhenVoided or false
local MoreAccurateOffsets = getgenv().GelatekReanimateConfig.MoreAccurateOffsets or false
local IsHeadless = getgenv().GelatekReanimateConfig.Headless or false
local DetailedCredits = getgenv().GelatekReanimateConfig.DetailedCredits or false
local BulletConfig = getgenv().GelatekReanimateConfig.BulletConfig or {}
local BulletAfterReanim = BulletConfig.RunAfterReanimate or false
local LockBulletOnTorso = BulletConfig.LockBulletOnTorso or false
if IsTorsoFling == true and IsBulletEnabled == true then
	IsTorsoFling = false
	warn("Gelatek Reanimate - TorsoFling and BulletEnabled are both true! Disabling TorsoFling")
end

local Offsets
if MoreAccurateOffsets == false then
	Offsets = {
		["UpperTorso"] = CFrame.new(0,0.194,0),
		["LowerTorso"] = CFrame.new(0,-0.79,0), 
		["Root"] = CFrame.new(0,0,0),
		
		["UpperArm"] = CFrame.new(0,0.4085,0),
		["LowerArm"] = CFrame.new(0,-0.184,0),
		["Hand"] = CFrame.new(0,-0.83,0),
		
		["UpperLeg"] = CFrame.new(0,0.575,0),
		["LowerLeg"] = CFrame.new(0,-0.199,0),
		["Foot"] = CFrame.new(0,-0.849,0)
	}
else
	Offsets = {
		["UpperTorso"] = CFrame.new(0,0.2,0),
		["LowerTorso"] = CFrame.new(0,-0.77,0), 
		["Root"] = CFrame.new(0,0,0),
			
		["UpperArm"] = CFrame.new(0,0.38,0),
		["LowerArm"] = CFrame.new(0,-0.21,0),
		["Hand"] = CFrame.new(0,-0.8,0),
		
		["UpperLeg"] = CFrame.new(0,0.595,0),
		["LowerLeg"] = CFrame.new(0,-0.18,0),
		["Foot"] = CFrame.new(0,-0.849,0)
	}
end
	
local Core = { --// API Used to store functions easier
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
					Part.CanTouch = false
					Part.CanQuery = false
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
		Player.MaximumSimulationRadius = 9e9
		if not syn then
			SimulationRadius(9e9)
		else
			HiddenProps(Player, "SimulationRadius", 9e9)
		end
	end,
	CreateSignal = function(DataModel,Name,Callback)
		local Service = game:GetService(DataModel)
		table.insert(Events,Service[Name]:Connect(Callback))
	end,
	CreateDummy = function(Name)
		local Dummy = game:GetService("ReplicatedStorage"):FindFirstChild("GelatekReanimateData"):WaitForChild("R6FakeRig"):Clone() 
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
		if (getgenv and getgenv().ShibaHubConfig and getgenv().ShibaHubConfig.TableOfEvents) then
			for i,v in pairs(getgenv().ShibaHubConfig.TableOfEvents) do
				v:Disconnect()
			end
			getgenv().ShibaHubConfig["ScriptStopped"] = true
			task.wait()
			getgenv().ShibaHubConfig["ScriptStopped"] = false
		end
	end,	
	PermaDeath = function(Model)
		task.spawn(function()
			local Speed = tick()
			game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
			task.wait(game:GetService("Players").RespawnTime + game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 750)
			local Head = Model:FindFirstChild("Head"); Head:BreakJoints() 
			warn("Godmoded in: " .. string.sub(tostring(tick()-Speed),1,string.find(tostring(tick()-Speed),".")+5))
			game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
			if IsHeadless == true then
				Head:Remove()
			end
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
		SelectionBox.LineThickness = 0.06
		SelectionBox.Name = "FlingerHighlighter"
		SelectionBox.Adornee = Part
		SelectionBox.Parent = Parent
	end
}

--// Rig Variables
local Data = game:GetService("ReplicatedStorage"):FindFirstChild("GelatekReanimateData")
local OriginalRig = Player["Character"]
local OriginalHum = OriginalRig:FindFirstChildWhichIsA("Humanoid")
local PlayerRigType = OriginalHum.RigType.Name
if AdditionalStuff == true then
	FakeHatsFolder = Instance.new("Folder")
	FakeHatsFolder.Name = "FakeHats"
	FakeHatsFolder.Parent = OriginalRig
end
if IsBulletEnabled == true then
	if PlayerRigType == "R6" then
		if IsPermaDeath == false then
			if not OriginalRig:FindFirstChild("Pal Hair") then
				local FakeHat = Data.Robloxclassicred:Clone()
				FakeHat.Parent = OriginalRig
				task.wait()
			end
		end
	else
		if not OriginalRig:FindFirstChild("SniperShoulderL") then
			local FakeHat = Data.SniperShoulderL:Clone()
			FakeHat.Parent = OriginalRig
			task.wait()
		end
	end
end
local OriginalRigDescendants = OriginalRig:GetDescendants()
local OriginalRigChildren = OriginalRig:GetChildren()
OriginalRig.Archivable = true

Core.HatRenamer(OriginalRigChildren)
Core.DisableScripts(OriginalRigChildren)
if IsTorsoFling == false then 
	OriginalHum:ChangeState(Enum.HumanoidStateType.Physics)
end
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
	warn("Gelatek Reanimate - Default Animations Disabled: "..tostring(AreAnimationsDisabled))
	warn("Gelatek Reanimate - R15 To R6: "..tostring(R15ToR6))
	warn("Gelatek Reanimate - Permament Death: "..tostring(IsPermaDeath))
	warn("Gelatek Reanimate - Torso Fling: "..tostring(IsTorsoFling))
	warn("Gelatek Reanimate - Bullet Enabled: "..tostring(IsBulletEnabled))
	warn("Gelatek Reanimate - LoadLibrary Enabled: "..tostring(IsLoadLibraryEnabled))
	warn("Gelatek Reanimate - New Velocity Method: "..tostring(NewVelocityMethod))
	warn("Gelatek Reanimate - Teleport Back When Voided: "..tostring(TeleportBackWhenVoided))
	warn("Gelatek Reanimate - Accurate R15 Offsets: "..tostring(MoreAccurateOffsets))
	warn("Gelatek Reanimate - Headless: "..tostring(IsHeadless))
	warn("Gelatek Reanimate - Detailed Credits: "..tostring(DetailedCredits))
end

do --// Optimizations/Boosting
	pcall(function() -- Based on rumors, sometimes properties cause errors, that's why I am PCalling.
		Player.ReplicationFocus = workspace
		settings()["Physics"].PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
		settings()["Physics"].AllowSleep = false
		settings()["Physics"].ForceCSGv2 = false
		settings()["Physics"].DisableCSGv2 = true
		settings()["Physics"].UseCSGv2 = false
		settings()["Physics"].ThrottleAdjustTime = -math.huge
		settings()["Rendering"].QualityLevel = 1
		game.Players.LocalPlayer.ReplicationFocus = workspace
		HiddenProps(workspace, "PhysicsSteppingMethod", Enum.PhysicsSteppingMethod.Fixed)
		HiddenProps(workspace, "PhysicsSimulationRateReplicator", Enum.PhysicsSimulationRate.Fixed240Hz)
		HiddenProps(workspace, "PhysicsSimulationRate", Enum.PhysicsSimulationRate.Fixed240Hz)
		HiddenProps(workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
		HiddenProps(workspace, "HumanoidOnlySetCollisionsOnStateChange", Enum.HumanoidOnlySetCollisionsOnStateChange.Disabled)
		HiddenProps(OriginalHum, "InternalBodyScale", Vector3.new(1,1,1) * math.huge)
		Core.DisableScripts(OriginalRigChildren)
	end)
end

task.spawn(function()
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
	pcall(function()
		workspace:FindFirstChildOfClass("Camera").CameraSubject = FakeHum
		OriginalRig.Animate.Disabled = true
		for Index,Track in ipairs(OriginalHum:GetPlayingAnimationTracks()) do
			Track:Stop()
		end
		for Index,Track in pairs(OriginalHum:GetPlayingAnimationTracks()) do
			Track:Stop()
		end
	end)
	
	do --// AccessoryWeld Recreation (Fix Offsets)
		Core.HatRenamer(OriginalRigChildren)
		for Index,Part in pairs(OriginalRigChildren) do
			if Part:IsA("Accessory") then
				local FakeHats1 = Part:Clone()
				FakeHats1.Handle.Transparency = 1
				Core.ReCreateWelds(FakeRig, FakeHats1)
				FakeHats1.Parent = FakeRig
				if FakeHatsFolder then
					local FakeHats2 = FakeHats1:Clone()
					FakeHats2.Parent = FakeHatsFolder
				end
			end
		end
	end

	FakeRig.HumanoidRootPart.CFrame = OriginalRig.HumanoidRootPart.CFrame

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
	for Index,Track in pairs(OriginalHum:GetPlayingAnimationTracks()) do
		Track:Stop()
	end
	Core.CreateSignal("RunService", "Stepped", function() -- Disable Collisions, Movement, Velocity Receiver and Net Claimer
		Core.DisableCollisions(OriginalRigDescendants)
		Core.DisableCollisions(FakeRigDescendants)
		Core.Network()
	end)
	local BVT = {}
	do --// Extra Properties, Anchor Claim
		task.wait()
		for Index,Part in ipairs(OriginalRigDescendants) do
			if Part:IsA("BasePart") then
				Part:ApplyImpulse(Vector3.new(30,0,0))
				Part.CustomPhysicalProperties = PhysicalProperties.new(math.huge,0,0,0,0)
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
				local HG = Instance.new("SelectionBox")
				HG.Adornee = Part
				HG.Name = "OwnershipCheck"
				HG.LineThickness = 0.4
				HG.Transparency = 1
				HG.Color3 = Color3.fromRGB(125,240,125)
				HG.Parent = Part

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
		while task.wait(0.05) do
			if IsPlayerDead then break end
			Offset = Offset * -1
			OffsetR15 = OffsetR15 * -1
		end
	end)()
	
	coroutine.wrap(function() --// R15 Fling Method
		if IsBulletEnabled == false and PlayerRigType == "R15" then
			while task.wait(1) do
				if IsPlayerDead then break end
				R15Funny = Vector3.new(0,0,0)
				if FakeRig:FindFirstChild("FlingerHighlighter") then
					FakeRig:FindFirstChild("FlingerHighlighter").Transparency = 1
				end
				task.wait(1)
				R15Funny = Vector3.new(2500,2500,2500)
				if FakeRig:FindFirstChild("FlingerHighlighter") then
					FakeRig:FindFirstChild("FlingerHighlighter").Transparency = 0
				end
			end
		end
	end)()

	if IsPermaDeath == true then
		Core.PermaDeath(OriginalRig)
	end

	if PlayerRigType == "R15" then
		Core.CreateSignal("RunService", "Heartbeat", function()
			Core.Align(OriginalRig["HumanoidRootPart"], OriginalRig["UpperTorso"], CFrame.new(0,OffsetR15,0))
		end)
	end
	Core.CreateSignal("RunService", "Heartbeat", function()
		if FakeRig.HumanoidRootPart.Position.Y <= workspace.FallenPartsDestroyHeight + 60 then
			if TeleportBackWhenVoided == false then
				Core.Resetting(OriginalRig, FakeRig)
			else
				FakeRig:MoveTo(SpawnPoint.Position)
			end
		end
	end)
	Core.CreateSignal("RunService", "Heartbeat", function() -- Main Part (Velocity, CFraming)
		if NewVelocityMethod == true then
			Velocity = Vector3.new(FakeRig["HumanoidRootPart"].CFrame.LookVector.X * 85, FakeRig["HumanoidRootPart"].AssemblyLinearVelocity.Y * 7, FakeRig["HumanoidRootPart"].CFrame.LookVector.Z * 85)
		else
			Velocity = Vector3.new(FakeRig["HumanoidRootPart"].AssemblyLinearVelocity.X * 5, 25.32, FakeRig["HumanoidRootPart"].AssemblyLinearVelocity.Z * 5)
		end
		for Index,BV in ipairs(BVT) do
			BV.Velocity = Velocity
		end
		for Index,Part in ipairs(OriginalRigDescendants) do
			if Part:IsA("BasePart") and (not PartFling) then
				if Part and Part.Parent then
					Part.Velocity = Velocity
					HiddenProps(Part, "NetworkIsSleeping", false)
					HiddenProps(Part, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
					
					if Part:FindFirstChild("OwnershipCheck") then
						if NetworkChecking(Part) == true then
							Part:FindFirstChild("OwnershipCheck").Transparency = 1
						else
							Part:FindFirstChild("OwnershipCheck").Transparency = 0
						end
					end
				end
			elseif Part:IsA("Accessory") then
				if Part and Part.Parent and Part:FindFirstChild("Handle") then
					Core.Align(Part.Handle, FakeRig[Part.Name].Handle)
				end
			end
		end
		
		if PartFling then
			if PlayerRigType == "R6" then
				PartFling.Velocity = R6TorsoVel 
			else
				PartFling.Velocity = Velocity 
				PartFling.RotVelocity = R15Funny
			end
		end
		pcall(function()
			if IsPermaDeath == true and IsHeadless == false then
				Core.Align(OriginalRig.Head, FakeRig.Head)
			end
			if PlayerRigType == "R6" then
				if IsBulletEnabled == true then
					if HatReplicaR6 and HatReplicaR6:FindFirstChild("Handle") then
						Core.Align(HatReplicaR6.Handle, FakeRig['Left Arm'], CFrame.new(),CFrame.Angles(math.rad(90),0,0))
					end
						if BulletR6.Size == Vector3.new(1,2,1) then
							if getgenv().PartDisconnecting == false then
								Core.Align(BulletR6, FakeRig['Left Arm'])
							end
							Core.Align(OriginalRig['HumanoidRootPart'], FakeRig['HumanoidRootPart'], CFrame.new(0,Offset,0))
						end
						if BulletR6.Size == Vector3.new(2,2,1) then
							if getgenv().PartDisconnecting == false then
								Core.Align(BulletR6, FakeRig['HumanoidRootPart'], CFrame.new(0,Offset,0))
							end
							Core.Align(OriginalRig['Left Arm'], FakeRig['Left Arm'])
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
					Core.Align(OriginalRig["UpperTorso"], FakeRig["Torso"], Offsets.UpperTorso)
					Core.Align(OriginalRig["LowerTorso"], FakeRig["Torso"], Offsets.LowerTorso)
					
					if IsBulletEnabled == true then
						if HatReplicaR15 and HatReplicaR15:FindFirstChild("Handle") then
							Core.Align(HatReplicaR15.Handle, FakeRig['Left Arm'], CFrame.new(0,0.5085,0))
						end
						if getgenv().PartDisconnecting == false then
							Core.Align(BulletR15, FakeRig["Left Arm"], Offsets.UpperArm)
						end
					else
						Core.Align(OriginalRig["LeftUpperArm"], FakeRig["Left Arm"], Offsets.UpperArm)
					end
					Core.Align(OriginalRig["RightUpperArm"], FakeRig["Right Arm"], Offsets.UpperArm)
					Core.Align(OriginalRig["RightLowerArm"], FakeRig["Right Arm"], Offsets.LowerArm)
					Core.Align(OriginalRig["RightHand"], FakeRig["Right Arm"], Offsets.Hand)

					Core.Align(OriginalRig["LeftLowerArm"], FakeRig["Left Arm"], Offsets.LowerArm)
					Core.Align(OriginalRig["LeftHand"], FakeRig["Left Arm"], Offsets.Hand)
									
					Core.Align(OriginalRig["RightUpperLeg"], FakeRig["Right Leg"], Offsets.UpperLeg)
					Core.Align(OriginalRig["RightLowerLeg"], FakeRig["Right Leg"], Offsets.LowerLeg)
					Core.Align(OriginalRig["RightFoot"], FakeRig["Right Leg"], Offsets.Foot)
													
					Core.Align(OriginalRig["LeftUpperLeg"], FakeRig["Left Leg"], Offsets.UpperLeg)
					Core.Align(OriginalRig["LeftLowerLeg"], FakeRig["Left Leg"], Offsets.LowerLeg)
					Core.Align(OriginalRig["LeftFoot"], FakeRig["Left Leg"], Offsets.Foot)
				else
					Core.Align(OriginalRig["UpperTorso"], FakeRig["UpperTorso"])
					Core.Align(OriginalRig["LowerTorso"], FakeRig["LowerTorso"])

					if IsBulletEnabled == true then
						if HatReplicaR15 and HatReplicaR15:FindFirstChild("Handle") then
							Core.Align(HatReplicaR15.Handle, FakeRig['LeftUpperArm'], CFrame.new(0,0.05,0))
						end
						if getgenv().PartDisconnecting == false then
							Core.Align(BulletR15, FakeRig["LeftUpperArm"])
						end
					else
						Core.Align(OriginalRig["LeftUpperArm"], FakeRig["LeftUpperArm"])
					end
					
					Core.Align(OriginalRig["RightUpperArm"], FakeRig["RightUpperArm"])
					Core.Align(OriginalRig["RightLowerArm"], FakeRig["RightLowerArm"])
					Core.Align(OriginalRig["RightHand"], FakeRig["RightHand"])
					
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

	if DetailedCredits == true then
		task.spawn(function()
			local ScreenGui = Instance.new("ScreenGui")
			local DefaultSample = Instance.new("Frame")
			local TextLabel = Instance.new("TextLabel")
			local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
			local TextLabel_2 = Instance.new("TextLabel")
			local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
			local Cat = Instance.new("Frame")
			local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			local UIStroke = Instance.new("UIStroke")
			local Sound = Instance.new("Sound")
			--Properties:
			ScreenGui.Parent = game.CoreGui
			DefaultSample.Name = "DefaultSample"
			DefaultSample.Parent = ScreenGui
			DefaultSample.AnchorPoint = Vector2.new(0.5, 0.5)
			DefaultSample.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			DefaultSample.BackgroundTransparency = 0.700
			DefaultSample.BorderSizePixel = 0
			DefaultSample.Position = UDim2.new(0.5, 0, -1.5, 0)
			DefaultSample.Size = UDim2.new(0.363999993, 0, 1.5, 0)

			UIStroke.Parent = DefaultSample
			UIStroke.ApplyStrokeMode = 1
			UIStroke.Thickness = 4
			UIStroke.Color = Color3.fromRGB(172, 172, 172)
			
			TextLabel.Parent = DefaultSample
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.AnchorPoint = Vector2.new(0.5,0.5)
			TextLabel.Position = UDim2.new(0.5, 0, 0.190133557, 0)
			TextLabel.Size = UDim2.new(1, 0, 0.0285421945, 0)
			TextLabel.Font = Enum.Font.Arcade
			TextLabel.Text = "CREDITS (V1.4.2)"
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14.000
			TextLabel.TextStrokeTransparency = 0.000
			TextLabel.TextWrapped = true

			UITextSizeConstraint.Parent = TextLabel
			UITextSizeConstraint.MaxTextSize = 30

			Sound.Parent = DefaultSample
			Sound.SoundId = "rbxassetid://3216912628"
			Sound.Volume = 0.25
			
			TextLabel_2.Parent = DefaultSample
			TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.BackgroundTransparency = 1.000
			TextLabel_2.Position = UDim2.new(0.0301664975, 0, 0.225778505, 0)
			TextLabel_2.Size = UDim2.new(0.943056703, 0, 0.3, 0)
			TextLabel_2.Font = Enum.Font.Arcade
			TextLabel_2.Text = [[GELATEK
			Reanimate Itself, New Low Jitter and more, 



			PRODUCTIONTAKEONE
			Optimization, Helpful with tweaks and some stuff.



			MYWORLD
			Delayless, Old (Low Jitter) Method, Inspiration



			MIZT
			Hat Renamer, Inspiration, R6 Rig
			
			
			
			FNF SONIC.EXE TEAM
			Inspiration for the Credit GUI
			]]
			TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel_2.TextScaled = true
			TextLabel_2.TextSize = 14.000
			TextLabel_2.TextStrokeTransparency = 0.000
			TextLabel_2.TextWrapped = true
			TextLabel_2.TextYAlignment = Enum.TextYAlignment.Top

			UITextSizeConstraint_2.Parent = TextLabel_2
			UITextSizeConstraint_2.MaxTextSize = 25

			Cat.Name = "Cat"
			Cat.Parent = DefaultSample
			Cat.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Cat.BackgroundTransparency = 1.000
			Cat.AnchorPoint = Vector2.new(0.5,0.5)
			Cat.Position = UDim2.new(0.5,0,0.7, 0)
			Cat.Size = UDim2.new(0.289978415, 0, 0.139616504, 0)

			UIAspectRatioConstraint.Parent = Cat


			do
				local getsynasset = getsynasset or getcustomasset or function() end 
				local request = syn and syn.request or http and http.request or request or function() end
				local isfile = isfile or readfile and function(filename) local succ,a = pcall(function() local b = readfile(filename) end) return succ end or function() end
					
				local Video = Instance.new("VideoFrame"); do
					Video.Size = UDim2.new(1,0,1,0)
					Video.Position = UDim2.new(0,0,0,0)
					Video.Looped = true
					Video.Parent = Cat
				end
				if getsynasset and request and writefile and isfile then
					if not isfile("cat.webm") then
						local Response, TempFile = request({Url = "https://cdn.discordapp.com/attachments/971520525736218766/1008731543298117692/cat.webm",Method = 'GET'})
						if Response.StatusCode == 200 then
							writefile("cat.webm",Response.Body)
						end
					end
					Video.Video = getsynasset("cat.webm")
					Video:Play()
					Sound:Play()
					DefaultSample:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quart, 1, false)
					task.wait(2.5)
					DefaultSample:TweenPosition(UDim2.new(0.5,0,2.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quart, 1, false)
					task.wait(2.5)
					ScreenGui:Destroy()
				else
					Video.Visible = false
				end
			end
			
		end)
	else
		game.StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "Reanimate By Gelatek, Special thanks: Derek, MyWorld, Mizt.",
			Color = Color3.fromRGB(255, 0, 0),
			TextSize = 20
		})
	end
	
	do -- Bullet Stuff
		if IsBulletEnabled == true and BulletAfterReanim == true then
		task.wait(2.5)
		getgenv().PartDisconnecting = true
		local Held = false
		local Players = game:GetService("Players")
		local Character = workspace:FindFirstChild("GelatekReanimate")
		local Bullet = getgenv().OGChar:FindFirstChild("Bullet")
		local Highlight = Character:FindFirstChild("FlingerHighlighter")
		pcall(function() Bullet.AntiRotation:Destroy() end)
		Bullet.Transparency = 1
		local Mouse = Players.LocalPlayer:GetMouse()
		local Power = Instance.new("BodyAngularVelocity")
		local Position = Instance.new("BodyPosition")
		Position.Position = Bullet.Position
		Position.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		Position.P = 25000
		Position.D = 200
		Power.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
		Power.P = math.huge
		Power.AngularVelocity = Vector3.new(20000,20000,20000)
		table.insert(getgenv().TableOfEvents, Mouse.Button1Down:Connect(function()
			Held = true
		end))
		table.insert(getgenv().TableOfEvents, Mouse.Button1Up:Connect(function()
			Held = false
		end))
		Power.Parent = Bullet
		Position.Parent = Bullet
		coroutine.wrap(function()
			while true do
				Position.P = 25000
				task.wait(5)
				Position.P = 50000
				task.wait(1)
			end
		end)()
		table.insert(getgenv().TableOfEvents, game:GetService("RunService").Heartbeat:Connect(function()
			local Hue = tick() % 5/5
			Bullet.Rotation = Vector3.new()
			pcall(function()
				if Held then
					if LockBulletOnTorso == true then
						if Mouse.Target:IsA("BasePart") then
							if Players:GetPlayerFromCharacter(Mouse.Target.Parent) then
								if Mouse.Target.Parent.Name ~= Players.LocalPlayer.Name then
									local Target = Mouse.Target.Parent:FindFirstChild("Torso") or Mouse.Target.Parent:FindFirstChild("Head") or Mouse.Target.Parent:FindFirstChildWhichIsA("BasePart")
									Position.Position = Target.Position
								end
							elseif Players:GetPlayerFromCharacter(Mouse.Target.Parent.Parent) then
								if Mouse.Target.Parent.Parent.Name ~= Players.LocalPlayer.Name then
									local Target = Mouse.Target.Parent.Parent:FindFirstChild("Torso") or Mouse.Target.Parent.Parent:FindFirstChild("Head") or Mouse.Target.Parent.Parent:FindFirstChildWhichIsA("BasePart")
									Position.Position = Target.Position
								end
							else
								Position.Position = Mouse.Hit.Position
							end
						end
					else
						if Mouse.Target:IsA("BasePart") then
							Position.Position = Mouse.Hit.Position
						end
					end
				else
				  Position.Position = Character["HumanoidRootPart"].Position
				end
				Highlight.Color3 = Color3.fromHSV(Hue, 1, 1)
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
			Title = "Found A Bug?";
			Text = "Click copy to get discord invite where you can report a bug! otherwise ignore.";
			Duration = 10;
			Callback = Bindable,
			Button1 = "Copy";
		})
	end
	
	table.insert(Events, Player.Chatted:Connect(function(Text)
		if Text == "gelatek skid" or Text == "i love south park" or Text == "i use align" then
			local telserv = game:GetService("TeleportService")
			telserv:Teleport(10613034992)
		end
	end))
end)
warn("Reanimated in " .. string.sub(tostring(tick()-Speed),1,string.find(tostring(tick()-Speed),".")+5))
