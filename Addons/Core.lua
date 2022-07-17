local HiddenProps = sethiddenproperty or set_hidden_property or function() end 
	
local SimulationRadius = setsimulationradius or set_simulation_radius or function() end 

local SetScript = setscriptable or function() end

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
		local network = isnetworkowner or is_network_owner or function(part) return part.ReceiveAge == 0 end
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
	CreateSignal = function(Table,DataModel,Name,Callback)
		local Service = game:GetService(DataModel)
		table.insert(Table,Service[Name]:Connect(Callback))
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
	Resetting = function(Table,Model1,Model2)
		Model1.Parent = workspace
		game.Players.LocalPlayer.Character = workspace[Model1.Name]
		Model2:Destroy()
		Model1:BreakJoints()
		IsPlayerDead = true
		getgenv().OGChar = nil
		if getgenv().PartDisconnecting then
			getgenv().PartDisconnecting = nil
		end
		for i,v in pairs(Table) do
			v:Disconnect()
		end
		for i,v in pairs(getgenv().TableOfEvents) do
			v:Disconnect()
		end
		
		pcall(function()
			if getgenv().FrostwareConfig then
				getgenv().FrostwareConfig["AnimationPlaying"] = false
				getgenv().FrostwareConfig["ScriptStopped"] = false
			end
		end)
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

return Core
