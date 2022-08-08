do --// Error Checking
	if not game:IsLoaded() then
		return nil
	end
	if workspace:FindFirstChild("GelatekReanimate") then
		return nil
	end
	if game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 then
		return nil
	end
end
--// Functions/Configs
local GlobalEnv            = getgenv and getgenv() or _G
local sethiddenproperty    = sethiddenproperty or set_hidden_property or function() end
local setsimulationradius  = setsimulationradius or set_simulation_radius or function() end
local setscriptable        = setscriptable or function() end
local isnetworkowner       = isnetworkowner or function(Part) return Part.ReceiveAge == 0 end
local setfflag             = setfflag or function(flag,bool) game:DefineFastFlag(flag,bool) end 
local Config               = GlobalEnv.GelatekReanimateConfig or {}

local BulletConfig           = Config.BulletConfig or {}
local AreAnimationsDisabled  = Config["AnimationsDisabled"] or false
local IsPermaDeath           = Config["PermanentDeath"] or false
local IsBulletEnabled        = Config["BulletEnabled"] or false
local IsTorsoFling           = Config["TorsoFling"] or false
local IsLoadLibraryEnabled   = Config["LoadLibrary"] or false
local AlignReanimate         = Config["AlignReanimate"] or false
local R15ToR6                = Config["R15ToR6"] or false
local Optimization           = Config["R15ToR6"] or false
local NewVelocityMethod      = Config["NewVelocityMethod"] or false
local DontBreakHairWelds     = Config["DontBreakHairWelds"] or false
local BulletAfterReanim      = BulletConfig["RunAfterReanimate"] or false
local LockBulletOnTorso      = BulletConfig["LockBulletOnTorso"] or false
if IsTorsoFling == true and IsBulletEnabled == true then IsTorsoFling = false end


--// Startup
local Player    = game:GetService("Players").LocalPlayer
local Character = Player["Character"]
local Humanoid  = Character:FindFirstChildWhichIsA("Humanoid")
local RigType   = Player.Character.Humanoid.RigType.Name
local Events    = {}
local Velocity  = Vector3.new(30,0,0)
local R15Offset = { -- R15 Offsets.
	
}

local Functions = {
	CreateSignal = function(DataModel,Name,Callback)
		local Service = game:GetService(DataModel)
		table.insert(Events,Service[Name]:Connect(Callback))
	end,
	Replicate = function(Part0,Part1,P_Offset,R_Offset)
		Part0:ApplyImpulse(Vector3.new(30,0,0))
		Part0:ApplyAngularImpulse(Vector3.new())
		Part0.CustomPhysicalProperties = PhysicalProperties.new(math.huge,math.huge,0,math.huge,0)
		Part0.RootPriority = 127
		Part0.Massless = true
		
		local P_Offset = P_Offset or CFrame.new()
		local R_Offset = R_Offset or CFrame.Angles()
		
		local ABV = Instance.new("BodyAngularVelocity"); do
			ABV.P = math.huge
			ABV.MaxTorque = Vector3.new(1,1,1) * math.huge
			ABV.AngularVelocity = Vector3.new()
			ABV.Name = "AntiRotation"
		end
		local BV = Instance.new("BodyVelocity"); do
			BV.P = math.huge
			BV.MaxForce = Vector3.new(1,1,1) * math.huge
			BV.Velocity = Vector3.new()
			BV.Name = "Stability"
		end
		local HG = Instance.new("SelectionBox"); do
			HG.Adornee = Part0
			HG.Name = "OwnershipCheck"
			HG.LineThickness = 0.4
			HG.Transparency = 1
			HG.Color3 = Color3.fromRGB(125,125,125)
		end
		
		ABV.Parent = Part0
		BV.Parent = Part0
		HG.Parent = Part0
		if AlignReanimate == false then
			CreateSignal("RunService", "Heartbeat", function()
				if isnetworkowner(Part0) == true then
					Part0.CFrame = Part1.CFrame * P_Offset * R_Offset
				end
			end)
		elseif AlignReanimate == true then
			local Attachment0 = Instance.new("Attachment"); local Attachment1 = Instance.new("Attachment")
			Attachment0.CFrame = P_Offset * R_Offset
			
			local Position = Instance.new("AlignPosition"); do
				Position.Attachment0 = Attachment0
				Position.Attachment1 = Attachment1
				Position.MaxForce = math.huge
				Position.Responsiveness = 200
			end
			local Orientation = Instance.new("AlignOrientation"); do
				Orientation.Attachment0 = Attachment0
				Orientation.Attachment1 = Attachment1
				Orientation.MaxTorque = math.huge
				Orientation.Responsiveness = 200
			end
			Attachment0.Parent = Part0
			Attachment1.Parent = Part1
			Position.Parent = Part0
			Orientation.Parent = Part0
		end
		CreateSignal("RunService", "Heartbeat", function()
			Part0.Velocity = Velocity
			Part0.RotVelocity = Vector3.new()
			if Part0:FindFirstChild("Stability") then
				Part0:FindFirstChild("Stability").Velocity = Velocity
			end	
			
			sethiddenproperty(Part0, "NetworkIsSleeping", false)
			sethiddenproperty(Part0, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
			if Part0:FindFirstChild("OwnershipCheck") then
				if NetworkChecking(Part0) == true then
					Part0:FindFirstChild("OwnershipCheck").Transparency = 1
				else
					Part0:FindFirstChild("OwnershipCheck").Transparency = 0
				end
			end
		end)
	end
}
