

local Global = (getgenv and getgenv()) or shared
-- [[ Services ]] --
local Speed = tick()
local Players = game:FindFirstChildOfClass("Players")
local UserInputService = game:FindFirstChildOfClass("UserInputService")
local TestService = game:FindFirstChildOfClass("TestService")
local RunService = game:FindFirstChildOfClass("RunService")
local StarterGui = game:FindFirstChildOfClass("StarterGui")
local CoreGui = game:FindFirstChildOfClass("CoreGui")
local Player = Players.LocalPlayer

-- [[ Variables ]] --
local Events = {}
local BodyVels = {}
local Root_Offset = 0.02
local Velocity = Vector3.new(-26,0,-26)
local SpawnPoint = workspace:FindFirstChildOfClass("SpawnLocation",true) and workspace:FindFirstChildOfClass("SpawnLocation",true) or CFrame.new(0,20,0)

-- [[ Functions ]] --
local setfflag = setfflag or function(flag,bool) game:DefineFastFlag(flag,bool) end
local isnetworkowner = isnetworkowner or function(Part) return Part.ReceiveAge == 0 end
local sethiddenproperty = sethiddenproperty or set_hidden_property or function() end 
	
-- [[ Checking Settings ]] --
pcall(function() setfflag("NewRunServiceSignals", "true") end) 
pcall(function() setfflag("NewRunServiceSignals", true) end)


local Config = Global.GelatekReanimateConfig or {}
Global.TableOfEvents = {}
--[[
	TODO:
	- Bullet Reanimate Code (Done)
	- Optimizations (Done)
	- Torso Fling (Done)
	- Anti Void (Done)
	- Delayless (Done)
	- Credits Thing (Done)
	- Readd Secret (Done)
	- Shiba Hub Support (fuck it)
]]
--[[ Ownership ]] --
local DisableTweaks = Config.DisableTweaks or false -- Disables Net-Boosting Tweaks
local DynamicalVelocity = Config.DynamicalVelocity or false -- Enables Dynamical/Movement Velocity

-- [[ Details ]] --
local DetailedCredits = Config.DetailedCredits or false -- Detailed Credits lol

-- [[ Rig Settings ]] --
local AreAnimationsDisabled = Config.AnimationsDisabled or false -- Disable Anims
local IsPermaDeath = Config.PermanentDeath or false -- Permanent Death

-- [[ R15 Stuff ]] --
local R15ToR6 = Config.R15ToR6 or false -- Convert R15 To R6

-- [[ Align Reanimate ]] --
local AlignReanimate = Config.AlignReanimate or false -- Align Reanimate
local MaxAlignReanimate = Config.FullForceAlign or false -- Maximazes Align Position Force by making another one, might be less stable but no longer wacky

-- [[ Optimizer ]] --
local OptimizeGame = Config.OptimizeGame or false -- Runs Game Optimizer.
if OptimizeGame == true and (not TestService:FindFirstChild("Check")) then
	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/L8X/GameOptimizer/main/src.lua", true))()
	local Part = Instance.new("Part")
	Part.Name = "Check"
	Part.Parent = TestService
end
local FasterHeartbeat = Config.FasterHeartbeat or false
-- Uses Newer Runservices, which makes artifical event x2 times faster than heartbeat, can affect fps. 

-- [[ Extra ]] --
local DontBreakHairWelds = Config.DontBreakHairWelds or false -- Keeps Hair to head (Non Perma Only)
local IsLoadLibraryEnabled = Config.LoadLibrary or false -- LoadLibrary
local TeleportBackWhenVoided = Config.TeleportBackWhenVoided or false -- Teleports back to surface whenever you fall into void
local IsHeadless = Config.Headless or false -- Headless Only On Permanent Death

-- [[ Flinging Methods ]] --
local IsTorsoFling = Config.TorsoFling or false -- Torso/Collision Fling
local IsBulletEnabled = Config.BulletEnabled or false -- Enable Bullet
local BulletConfig = Config.BulletConfig or {}
local BulletAfterReanim = BulletConfig.RunAfterReanimate or false -- Run After Reanimate
local LockBulletOnTorso = BulletConfig.LockBulletOnTorso or false -- Lock Bullet On Torso
if IsTorsoFling == true and IsBulletEnabled == true then
	IsTorsoFling = false
end

task.spawn(function()
-- [[ Custom Functions ]] --
local CFrameAlign = function(Part0, Part1, Position, Angle)
	local CFrame_Position = Position or CFrame.new()
	local CFrame_Angle = Angle or CFrame.Angles(0,0,0)
	if isnetworkowner(Part0) == true then
		Part0.CFrame = Part1.CFrame * CFrame_Position * CFrame_Angle
		if Part0:FindFirstChild("OwnershipCheck") then
			Part0:FindFirstChild("OwnershipCheck").Transparency = 1
		end
	elseif isnetworkowner(Part0) == false then
		if Part0:FindFirstChild("OwnershipCheck") then
			Part0:FindFirstChild("OwnershipCheck").Transparency = 0
		end
	end
end
local Align = function(Part0, Part1, Position, Orientation)
	local AlignPosition = Instance.new("AlignPosition"); do
		AlignPosition.MaxForce = 66666666666
		AlignPosition.RigidityEnabled = true
		AlignPosition.Responsiveness = 200
		AlignPosition.Name = "AlignPosition_1"
		AlignPosition.Parent = Part0
	end

	local AlignOrientation = Instance.new("AlignOrientation"); do
		AlignOrientation.MaxTorque = 9e9 -- Better To Decrease this to avoid weird movement on R15.
		AlignOrientation.Responsiveness = 200
		AlignOrientation.Name = "AlignOrientation"
		AlignOrientation.Parent = Part0
	end

	local Attachment1 = Instance.new("Attachment"); do
		Attachment1.Position = Position or Vector3.new(0,0,0)
		Attachment1.Orientation = Orientation or Vector3.new(0,0,0)
		Attachment1.Name = "Attachment_1"
		Attachment1.Parent = Part0
	end

	local Attachment2 = Instance.new("Attachment"); do
		Attachment2.Name = "GelatekATT2"
		Attachment2.Parent = Part1
	end

	AlignPosition.Attachment0 = Attachment1
	AlignPosition.Attachment1 = Attachment2
	AlignOrientation.Attachment0 = Attachment1
	AlignOrientation.Attachment1 = Attachment2

	if MaxAlignReanimate == true then
		task.spawn(function()
			repeat task.wait() until isnetworkowner(Part0) == true
			task.wait(0.05) -- Avoiding Bugs
			local AlignPosition2 = Instance.new("AlignPosition"); do
				AlignPosition2.Name = "GelatekAP2"
				AlignPosition2.RigidityEnabled = true
				AlignPosition2.Parent = Part0
			end
			AlignPosition2.Attachment0 = Attachment1
			AlignPosition2.Attachment1 = Attachment2
		end)
	end
end
local Notification = function(Title, Text, Duration)
	StarterGui:SetCore("SendNotification", {
		Title = Title or "Unknown",
		Text = Text or "Unknown",
		Duration = Duration or 3
	})
end
local ReCreateWelds = function(Model, Accessory) 
	-- [[ Inspiration from DevForum Post made by admin. ]] --
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
end
local ArtificalEvent; do
	-- [[ Artifical Event; original by 4eyedfool; "Borrowing" From One.]] --
	local EventList = {"PreRender","PreAnimation","Stepped","Heartbeat"}
	if FasterHeartbeat == false then
		EventList = {"Heartbeat"}
	end
	if not ArtificalEvent then
		local BindEvent = Instance.new("BindableEvent")
		local Tick = tick()
		for _,RunEvent in pairs(EventList) do
			table.insert(Events, RunService[RunEvent]:Connect(function()
				Tick = tick()
				BindEvent:Fire(tick()-Tick)
			end))
		end 
		ArtificalEvent = BindEvent.Event
	end
end
local R6Animate = function()
	local Figure = game.Players.LocalPlayer.Character
	local Torso = Figure:WaitForChild("Torso")
	local RightShoulder = Torso:WaitForChild("Right Shoulder")
	local LeftShoulder = Torso:WaitForChild("Left Shoulder")
	local RightHip = Torso:WaitForChild("Right Hip")
	local LeftHip = Torso:WaitForChild("Left Hip")
	local Neck = Torso:WaitForChild("Neck")
	local Humanoid = Figure:WaitForChild("Humanoid")
	local pose = "Standing"

	local currentAnim = ""
	local currentAnimInstance = nil
	local currentAnimTrack = nil
	local currentAnimKeyframeHandler = nil
	local currentAnimSpeed = 1.0
	local animTable = {}
	local animNames = { 
		idle = 	{	
					{ id = "http://www.roblox.com/asset/?id=180435571", weight = 9 },
					{ id = "http://www.roblox.com/asset/?id=180435792", weight = 1 }
				},
		walk = 	{ 	
					{ id = "http://www.roblox.com/asset/?id=180426354", weight = 10 } 
				}, 
		run = 	{
					{ id = "run.xml", weight = 10 } 
				}, 
		jump = 	{
					{ id = "http://www.roblox.com/asset/?id=125750702", weight = 10 } 
				}, 
		fall = 	{
					{ id = "http://www.roblox.com/asset/?id=180436148", weight = 10 } 
				}, 
		climb = {
					{ id = "http://www.roblox.com/asset/?id=180436334", weight = 10 } 
				}, 
		sit = 	{
					{ id = "http://www.roblox.com/asset/?id=178130996", weight = 10 } 
				},	
		toolnone = {
					{ id = "http://www.roblox.com/asset/?id=182393478", weight = 10 } 
				},
		toolslash = {
					{ id = "http://www.roblox.com/asset/?id=129967390", weight = 10 } 
	--				{ id = "slash.xml", weight = 10 } 
				},
		toollunge = {
					{ id = "http://www.roblox.com/asset/?id=129967478", weight = 10 } 
				},
		wave = {
					{ id = "http://www.roblox.com/asset/?id=128777973", weight = 10 } 
				},
		point = {
					{ id = "http://www.roblox.com/asset/?id=128853357", weight = 10 } 
				},
		dance1 = {
					{ id = "http://www.roblox.com/asset/?id=182435998", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=182491037", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=182491065", weight = 10 } 
				},
		dance2 = {
					{ id = "http://www.roblox.com/asset/?id=182436842", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=182491248", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=182491277", weight = 10 } 
				},
		dance3 = {
					{ id = "http://www.roblox.com/asset/?id=182436935", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=182491368", weight = 10 }, 
					{ id = "http://www.roblox.com/asset/?id=182491423", weight = 10 } 
				},
		laugh = {
					{ id = "http://www.roblox.com/asset/?id=129423131", weight = 10 } 
				},
		cheer = {
					{ id = "http://www.roblox.com/asset/?id=129423030", weight = 10 } 
				},
	}
	local dances = {"dance1", "dance2", "dance3"}

	-- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
	local emoteNames = { wave = false, point = false, dance1 = true, dance2 = true, dance3 = true, laugh = false, cheer = false}

	function configureAnimationSet(name, fileList)
		if (animTable[name] ~= nil) then
			for _, connection in pairs(animTable[name].connections) do
				connection:disconnect()
			end
		end
		animTable[name] = {}
		animTable[name].count = 0
		animTable[name].totalWeight = 0	
		animTable[name].connections = {}

		-- check for config values
		local config = script:FindFirstChild(name)
		if (config ~= nil) then
	--		print("Loading anims " .. name)
			table.insert(animTable[name].connections, config.ChildAdded:connect(function(child) configureAnimationSet(name, fileList) end))
			table.insert(animTable[name].connections, config.ChildRemoved:connect(function(child) configureAnimationSet(name, fileList) end))
			local idx = 1
			for _, childPart in pairs(config:GetChildren()) do
				if (childPart:IsA("Animation")) then
					table.insert(animTable[name].connections, childPart.Changed:connect(function(property) configureAnimationSet(name, fileList) end))
					animTable[name][idx] = {}
					animTable[name][idx].anim = childPart
					local weightObject = childPart:FindFirstChild("Weight")
					if (weightObject == nil) then
						animTable[name][idx].weight = 1
					else
						animTable[name][idx].weight = weightObject.Value
					end
					animTable[name].count = animTable[name].count + 1
					animTable[name].totalWeight = animTable[name].totalWeight + animTable[name][idx].weight
		--			print(name .. " [" .. idx .. "] " .. animTable[name][idx].anim.AnimationId .. " (" .. animTable[name][idx].weight .. ")")
					idx = idx + 1
				end
			end
		end

		-- fallback to defaults
		if (animTable[name].count <= 0) then
			for idx, anim in pairs(fileList) do
				animTable[name][idx] = {}
				animTable[name][idx].anim = Instance.new("Animation")
				animTable[name][idx].anim.Name = name
				animTable[name][idx].anim.AnimationId = anim.id
				animTable[name][idx].weight = anim.weight
				animTable[name].count = animTable[name].count + 1
				animTable[name].totalWeight = animTable[name].totalWeight + anim.weight
	--			print(name .. " [" .. idx .. "] " .. anim.id .. " (" .. anim.weight .. ")")
			end
		end
	end

	-- Setup animation objects
	function scriptChildModified(child)
		local fileList = animNames[child.Name]
		if (fileList ~= nil) then
			configureAnimationSet(child.Name, fileList)
		end	
	end

	script.ChildAdded:connect(scriptChildModified)
	script.ChildRemoved:connect(scriptChildModified)


	for name, fileList in pairs(animNames) do 
		configureAnimationSet(name, fileList)
	end	

	-- ANIMATION

	-- declarations
	local toolAnim = "None"
	local toolAnimTime = 0

	local jumpAnimTime = 0
	local jumpAnimDuration = 0.3

	local toolTransitionTime = 0.1
	local fallTransitionTime = 0.3
	local jumpMaxLimbVelocity = 0.75

	-- functions

	function stopAllAnimations()
		local oldAnim = currentAnim

		-- return to idle if finishing an emote
		if (emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false) then
			oldAnim = "idle"
		end

		currentAnim = ""
		currentAnimInstance = nil
		if (currentAnimKeyframeHandler ~= nil) then
			currentAnimKeyframeHandler:disconnect()
		end

		if (currentAnimTrack ~= nil) then
			currentAnimTrack:Stop()
			currentAnimTrack:Destroy()
			currentAnimTrack = nil
		end
		return oldAnim
	end

	function setAnimationSpeed(speed)
		if speed ~= currentAnimSpeed then
			currentAnimSpeed = speed
			currentAnimTrack:AdjustSpeed(currentAnimSpeed)
		end
	end

	function keyFrameReachedFunc(frameName)
		if (frameName == "End") then

			local repeatAnim = currentAnim
			-- return to idle if finishing an emote
			if (emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false) then
				repeatAnim = "idle"
			end
			
			local animSpeed = currentAnimSpeed
			playAnimation(repeatAnim, 0.0, Humanoid)
			setAnimationSpeed(animSpeed)
		end
	end

	-- Preload animations
	function playAnimation(animName, transitionTime, humanoid) 
		pcall(function()
			
		local roll = math.random(1, animTable[animName].totalWeight) 
		local origRoll = roll
		local idx = 1
		while (roll > animTable[animName][idx].weight) do
			roll = roll - animTable[animName][idx].weight
			idx = idx + 1
		end
	--		print(animName .. " " .. idx .. " [" .. origRoll .. "]")
		local anim = animTable[animName][idx].anim

		-- switch animation		
		if (anim ~= currentAnimInstance) then
			
			if (currentAnimTrack ~= nil) then
				currentAnimTrack:Stop(transitionTime)
				currentAnimTrack:Destroy()
			end

			currentAnimSpeed = 1.0
		
			-- load it to the humanoid; get AnimationTrack
			currentAnimTrack = humanoid:LoadAnimation(anim)
			currentAnimTrack.Priority = Enum.AnimationPriority.Core
			
			-- play the animation
			currentAnimTrack:Play(transitionTime)
			currentAnim = animName
			currentAnimInstance = anim

			-- set up keyframe name triggers
			if (currentAnimKeyframeHandler ~= nil) then
				currentAnimKeyframeHandler:disconnect()
			end
			currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached:connect(keyFrameReachedFunc)
			
		end
	end)
	end

	-------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------

	local toolAnimName = ""
	local toolAnimTrack = nil
	local toolAnimInstance = nil
	local currentToolAnimKeyframeHandler = nil

	function toolKeyFrameReachedFunc(frameName)
		if (frameName == "End") then
	--		print("Keyframe : ".. frameName)	
			playToolAnimation(toolAnimName, 0.0, Humanoid)
		end
	end

	function playToolAnimation(animName, transitionTime, humanoid, priority)	 
		local roll = math.random(1, animTable[animName].totalWeight)
		local origRoll = roll
		local idx = 1
		while (roll > animTable[animName][idx].weight) do
			roll = roll - animTable[animName][idx].weight
			idx = idx + 1
		end
		--	print(animName .. " * " .. idx .. " [" .. origRoll .. "]")
		local anim = animTable[animName][idx].anim

		if (toolAnimInstance ~= anim) then
			if (toolAnimTrack ~= nil) then
				toolAnimTrack:Stop()
				toolAnimTrack:Destroy()
				transitionTime = 0
			end

			-- load it to the humanoid; get AnimationTrack
			toolAnimTrack = humanoid:LoadAnimation(anim)
			if priority then
				toolAnimTrack.Priority = priority
			end

			-- play the animation
			toolAnimTrack:Play(transitionTime)
			toolAnimName = animName
			toolAnimInstance = anim

			currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(toolKeyFrameReachedFunc)
		end
	end

	function stopToolAnimations()
		local oldAnim = toolAnimName

		if (currentToolAnimKeyframeHandler ~= nil) then
			currentToolAnimKeyframeHandler:disconnect()
		end

		toolAnimName = ""
		toolAnimInstance = nil

		if (toolAnimTrack ~= nil) then
			toolAnimTrack:Stop()
			toolAnimTrack:Destroy()
			toolAnimTrack = nil
		end

		return oldAnim
	end

	-------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------


	function onRunning(speed)
		pcall(function()
			if speed > 0.01 then
				playAnimation("walk", 0.1, Humanoid)

				if currentAnimInstance and currentAnimInstance.AnimationId == "http://www.roblox.com/asset/?id=180426354" then
					setAnimationSpeed(speed / 14.5)
				end

				pose = "Running"
			else
				if emoteNames[currentAnim] == nil then
					playAnimation("idle", 0.1, Humanoid)
					pose = "Standing"
				end
			end
		end)
	end

	function onDied()
		pose = "Dead"
	end

	function onJumping()
		playAnimation("jump", 0.1, Humanoid)
		jumpAnimTime = jumpAnimDuration
		pose = "Jumping"
	end

	function onClimbing(speed)
		playAnimation("climb", 0.1, Humanoid)
		setAnimationSpeed(speed / 12.0)
		pose = "Climbing"
	end

	function onGettingUp()
		pose = "GettingUp"
	end

	function onFreeFall()
		if (jumpAnimTime <= 0) then
			playAnimation("fall", fallTransitionTime, Humanoid)
		end
		pose = "FreeFall"
	end

	function onFallingDown()
		pose = "FallingDown"
	end

	function onSeated()
		pose = "Seated"
	end

	function onPlatformStanding()
		pose = "PlatformStanding"
	end

	function onSwimming(speed)
		if speed > 0 then
			pose = "Running"
		else
			pose = "Standing"
		end
	end

	function getTool()	
		for _, kid in ipairs(Figure:GetChildren()) do
			if kid.className == "Tool" then return kid end
		end

		return nil
	end

	function getToolAnim(tool)
		for _, c in ipairs(tool:GetChildren()) do
			if c.Name == "toolanim" and c.className == "StringValue" then
				return c
			end
		end
		return nil
	end

	function animateTool()	
		if (toolAnim == "None") then
			playToolAnimation("toolnone", toolTransitionTime, Humanoid, Enum.AnimationPriority.Idle)
			return
		end

		if (toolAnim == "Slash") then
			playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority.Action)
			return
		end

		if (toolAnim == "Lunge") then
			playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority.Action)
			return
		end
	end

	function moveSit()
		RightShoulder.MaxVelocity = 0.15
		LeftShoulder.MaxVelocity = 0.15
		RightShoulder:SetDesiredAngle(3.14 /2)
		LeftShoulder:SetDesiredAngle(-3.14 /2)
		RightHip:SetDesiredAngle(3.14 /2)
		LeftHip:SetDesiredAngle(-3.14 /2)
	end

	local lastTick = 0

	function move(time)
		local amplitude = 1
		local frequency = 1
		local deltaTime = time - lastTick
		lastTick = time

		local climbFudge = 0
		local setAngles = false

		if (jumpAnimTime > 0) then
			jumpAnimTime = jumpAnimTime - deltaTime
		end

		if (pose == "FreeFall" and jumpAnimTime <= 0) then
			playAnimation("fall", fallTransitionTime, Humanoid)
		elseif (pose == "Seated") then
			playAnimation("sit", 0.5, Humanoid)
			return
		elseif (pose == "Running") then
			playAnimation("walk", 0.1, Humanoid)
		elseif (pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "Seated" or pose == "PlatformStanding") then
	--		print("Wha " .. pose)
			stopAllAnimations()
			amplitude = 0.1
			frequency = 1
			setAngles = true
		end

		if (setAngles) then
			local desiredAngle = amplitude * math.sin(time * frequency)

			RightShoulder:SetDesiredAngle(desiredAngle + climbFudge)
			LeftShoulder:SetDesiredAngle(desiredAngle - climbFudge)
			RightHip:SetDesiredAngle(-desiredAngle)
			LeftHip:SetDesiredAngle(-desiredAngle)
		end

		-- Tool Animation handling
		local tool = getTool()
		if tool and tool:FindFirstChild("Handle") then
			local animStringValueObject = getToolAnim(tool)

			if animStringValueObject then
				toolAnim = animStringValueObject.Value
				-- message recieved, delete StringValue
				animStringValueObject.Parent = nil
				toolAnimTime = time + .3
			end

			if time > toolAnimTime then
				toolAnimTime = 0
				toolAnim = "None"
			end

			animateTool()		
		else
			stopToolAnimations()
			toolAnim = "None"
			toolAnimInstance = nil
			toolAnimTime = 0
		end
	end

	-- connect events
	table.insert(Events,Humanoid.Died:connect(onDied))
	table.insert(Events,Humanoid.Running:connect(onRunning))
	table.insert(Events,Humanoid.Jumping:connect(onJumping))
	table.insert(Events,Humanoid.Climbing:connect(onClimbing))
	table.insert(Events,Humanoid.GettingUp:connect(onGettingUp))
	table.insert(Events,Humanoid.FreeFalling:connect(onFreeFall))
	table.insert(Events,Humanoid.FallingDown:connect(onFallingDown))
	table.insert(Events,Humanoid.Seated:connect(onSeated))
	table.insert(Events,Humanoid.PlatformStanding:connect(onPlatformStanding))
	table.insert(Events,Humanoid.Swimming:connect(onSwimming))

	-- setup emote chat hook
	game:GetService("Players").LocalPlayer.Chatted:connect(function(msg)
		local emote = ""

		if msg == "/e dance" then
			emote = dances[math.random(1, #dances)]
		elseif (string.sub(msg, 1, 3) == "/e ") then
			emote = string.sub(msg, 4)
		elseif (string.sub(msg, 1, 7) == "/emote ") then
			emote = string.sub(msg, 8)
		end
		
		if (pose == "Standing" and emoteNames[emote] ~= nil) then
			playAnimation(emote, 0.1, Humanoid)
		end
	end)

	playAnimation("idle", 0.1, Humanoid)
	pose = "Standing"

	table.insert(Events, game:GetService("RunService").Stepped:Connect(function()
		local _, time = wait(0.1)
		move(time)
	end))

end
do -- [[ Checking ]] --
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	if workspace:FindFirstChild("GelatekReanimate") then
		Notification("Error!", "Reanimate Is Already Running!", 3)
		return nil
	end
	if workspace[Player.Name]:FindFirstChildWhichIsA("Humanoid").Health == 0 then
		Notification("Error!", "You are currently dead, wait until you will respawn.", 3)
		return nil
	end
	if not TestService:FindFirstChild("GelatekReanimateData") then
		local Folder = Instance.new("Folder")
		Folder.Name = "GelatekReanimateData"
		local FakeRig = Instance.new("Model"); do
			local Limbs = {}
			local Attachments = {}
			local function CreateJoint(Name,Part0,Part1,C0,C1)
				local Joint = Instance.new("Motor6D")
				Joint.Name = Name
				Joint.Part0 = Part0
				Joint.Part1 = Part1
				Joint.C0 = C0
				Joint.C1 = C1
				Joint.Parent = Part0
			end

			for i = 0,18 do
				local Attachment = Instance.new("Attachment")
				Attachment.Axis = Vector3.new(1,0,0)
				Attachment.SecondaryAxis = Vector3.new(0,1,0)
				table.insert(Attachments, Attachment)
			end
			for i = 0,3 do
				local Limb = Instance.new("Part")
				Limb.Size = Vector3.new(1, 2, 1)
				Limb.BottomSurface = Enum.SurfaceType.Smooth
				Limb.FormFactor = Enum.FormFactor.Symmetric
				Limb.Locked = true
				Limb.CanCollide = false
				Limb.Parent = FakeRig
				table.insert(Limbs, Limb)
			end

			Limbs[1].Name = "Right Arm"
			Limbs[2].Name = "Left Arm"
			Limbs[3].Name = "Right Leg"
			Limbs[4].Name = "Left Leg"

			local Head = Instance.new("Part"); do
				Head.Size = Vector3.new(2,1,1)
				Head.TopSurface = Enum.SurfaceType.Smooth
				Head.FormFactor = Enum.FormFactor.Symmetric
				Head.Locked = true
				Head.CanCollide = false
				Head.Name = "Head"
				Head.Parent = FakeRig
			end
			local Torso = Instance.new("Part"); do
				Torso.Size = Vector3.new(2, 2, 1)
				Torso.BottomSurface = Enum.SurfaceType.Smooth
				Torso.FormFactor = Enum.FormFactor.Symmetric
				Torso.Locked = true
				Torso.CanCollide = false
				Torso.Name = "Torso"
				Torso.Parent = FakeRig
			end
			local Root = Torso:Clone(); do
				Root.Transparency = 0
				Root.Name = "HumanoidRootPart"
				Root.Parent = FakeRig
			end

			CreateJoint("Neck", Torso, Head, CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0))
			CreateJoint("RootJoint", Root, Torso, CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0), CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0))
			CreateJoint("Right Shoulder", Torso, Limbs[1], CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0), CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0))
			CreateJoint("Left Shoulder", Torso, Limbs[2], CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
			CreateJoint("Right Hip", Torso, Limbs[3], CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0), CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0))
			CreateJoint("Left Hip", Torso, Limbs[4], CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))

			local Humanoid = Instance.new("Humanoid"); do
				Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				Humanoid.Parent = FakeRig
			end
			local Animator = Instance.new("Animator"); do
				Animator.Parent = Humanoid
			end
			local HumanoidDescription = Instance.new("HumanoidDescription"); do
				HumanoidDescription.Parent = Humanoid
			end
			local HeadMesh = Instance.new("SpecialMesh") do
				HeadMesh.Scale = Vector3.new(1.25, 1.25, 1.25)
				HeadMesh.Parent = Head
			end
			local Face = Instance.new("Decal"); do
				Face.Name = "face"
				Face.Texture = "http://www.roblox.com/asset/?id=158044781"
				Face.Parent = Head
			end
			local Animate = Instance.new("LocalScript"); do
				Animate.Name = "Animate" -- Later
				Animate.Parent = FakeRig
			end
			local Health = Instance.new("Script"); do -- not neccessary to fill
				Health.Name = "Health"
				Health.Parent = FakeRig
			end
			FakeRig.Name = "Rig"
			FakeRig.PrimaryPart = Root
			FakeRig.Parent = Folder
			-- Attachments (Oh Boy..)
			Attachments[1].Name = "FaceCenterAttachment"
			Attachments[1].Position = Vector3.new(0, 0, 0)
			
			Attachments[2].Name = "FaceFrontAttachment"
			Attachments[2].Position = Vector3.new(0, 0, -0.6)
			
			Attachments[3].Name = "HairAttachment"	
			Attachments[3].Position = Vector3.new(0, 0.6, 0)
			
			Attachments[4].Name = "HatAttachment"
			Attachments[4].Position = Vector3.new(0, 0.6, 0)
			
			Attachments[5].Name = "RootAttachment"
			Attachments[5].Position = Vector3.new(0, 0, 0)
			
			Attachments[6].Name = "RightGripAttachment"
			Attachments[6].Position = Vector3.new(0, -1, 0)
			
			Attachments[7].Name = "RightShoulderAttachment"
			Attachments[7].Position = Vector3.new(0, 1, 0)
			
			Attachments[8].Name = "LeftGripAttachment"
			Attachments[8].Position = Vector3.new(0, -1, 0)
			
			Attachments[9].Name = "LeftShoulderAttachment"
			Attachments[9].Position = Vector3.new(0, 1, 0)
			
			Attachments[10].Name = "RightFootAttachment"
			Attachments[10].Position = Vector3.new(0, -1, 0)
			
			Attachments[11].Name = "LeftFootAttachment"
			Attachments[11].Position = Vector3.new(0, -1, 0)
			
			Attachments[12].Name = "BodyBackAttachment"
			Attachments[12].Position = Vector3.new(0, 0, 0.5)
			
			Attachments[13].Name = "BodyFrontAttachment"
			Attachments[13].Position = Vector3.new(0, 0, -0.5)
			
			Attachments[14].Name = "LeftCollarAttachment"
			Attachments[14].Position = Vector3.new(-1, 1, 0)
			
			Attachments[15].Name = "NeckAttachment"
			Attachments[15].Position = Vector3.new(0, 1, 0)
			
			Attachments[16].Name = "RightCollarAttachment"
			Attachments[16].Position = Vector3.new(1, 1, 0)
			
			Attachments[17].Name = "WaistBackAttachment"
			Attachments[17].Position = Vector3.new(0, -1, 0.5)
			
			Attachments[18].Name = "WaistCenterAttachment"
			Attachments[18].Position = Vector3.new(0, -1, 0)
			
			Attachments[19].Name = "WaistFrontAttachment"
			Attachments[19].Position = Vector3.new(0, -1, -0.5)
	

			Attachments[1].Parent = Head
			Attachments[2].Parent = Head
			Attachments[3].Parent = Head
			Attachments[4].Parent = Head

			Attachments[5].Parent = Root

			Attachments[6].Parent = Limbs[1]
			Attachments[7].Parent = Limbs[1]

			Attachments[8].Parent = Limbs[2]
			Attachments[9].Parent = Limbs[2]

			Attachments[10].Parent = Limbs[3]

			Attachments[11].Parent = Limbs[4]

			for i = 0,7 do
				Attachments[12 + i].Parent = Torso
			end
		end
		local R6FakeHat = Instance.new("Accessory"); do
			R6FakeHat.Name = "R6FakeHat"
			local Handle = Instance.new("Part")
			Handle.Name = "Handle"
			Handle.Transparency = 0.5
			Handle.Size = Vector3.new(2,1,1)
			Handle.Parent = R6FakeHat
		end
		local R15FakeHat = Instance.new("Accessory"); do
			R15FakeHat.Name = "R15FakeHat"
			local Handle = Instance.new("Part")
			Handle.Name = "Handle"
			Handle.Size = Vector3.new(1,1,1)
			Handle.Transparency = 0.5
			Handle.Color = Color3.fromRGB(163, 162, 165)
			local SpecialMesh = Instance.new("SpecialMesh")
			SpecialMesh.MeshId = "rbxassetid://5972856435"
			SpecialMesh.Parent = Handle
			Handle.Parent = R15FakeHat
		end
		R15FakeHat.Parent = Folder
		R6FakeHat.Parent = Folder
		FakeRig.Parent = Folder
		Folder.Parent = TestService
	end
end
Global.PartDisconnected = false
-- [[ Start ]] --
local Character = Player["Character"] or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local CharacterDescendants = Character:GetDescendants()
local CharacterChildren = Character:GetChildren()
local RigType = Humanoid.RigType.Name
Character.Archivable = true
RootPart.Transparency = 0
if Character:FindFirstChild("Animate") then -- [[ Disable Animations ]] --
	Character:FindFirstChild("Animate").Disabled = true
	for _, Track in next, Humanoid:GetPlayingAnimationTracks() do
		Track:Stop();
	end
end
if IsTorsoFling == false then
	Humanoid:ChangeState("Physics")
end
do -- [[ Tweaks ]] --
	if DisableTweaks == false then
		Player.ReplicationFocus = workspace
		settings()["Physics"].PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
		settings()["Physics"].AllowSleep = false
		settings()["Physics"].ForceCSGv2 = false
		settings()["Physics"].DisableCSGv2 = true
		settings()["Physics"].UseCSGv2 = false
		sethiddenproperty(workspace, "PhysicsSteppingMethod", Enum.PhysicsSteppingMethod.Fixed)
		sethiddenproperty(workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Disabled)
	end
end

local FakeRig; do -- [[ Rig Maker ]] --
	if RigType == "R6" or (RigType == "R15" and R15ToR6 == true) then
		FakeRig = TestService.GelatekReanimateData:FindFirstChild("Rig"):Clone()
		FakeRig.Name = "GelatekReanimate"
		for Index, Misc in ipairs(FakeRig:GetDescendants()) do
			if Misc:IsA("BasePart") or Misc:IsA("Decal") then
				Misc.Transparency = 1
			end
		end
		FakeRig.Parent = workspace
	else
		FakeRig = Character:Clone() 
		FakeRig.Name = "GelatekReanimate"
		for Index, Misc in ipairs(FakeRig:GetDescendants()) do
			if Misc:IsA("BasePart") or Misc:IsA("Decal") then
				Misc.Transparency = 1
			elseif Misc:IsA("Accessory") then
				Misc:Destroy()
			end
		end
		FakeRig:FindFirstChildWhichIsA("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		FakeRig.Parent = workspace
	end
	FakeRig.HumanoidRootPart.CFrame = RootPart.CFrame
end
local FakeHum = FakeRig:FindFirstChildOfClass("Humanoid")
do --[[ Rename Hats (By Mizt) / AccessoryWeld Recreation (Fix Offsets) ]] --
	local HatsNames = {}
	for Index, Accessory in ipairs(CharacterDescendants) do
		if Accessory:IsA("Accessory") then
			if HatsNames[Accessory.Name] then
				if HatsNames[Accessory.Name] == "Unknown" then
					HatsNames[Accessory.Name] = {}
				end
				table.insert(HatsNames[Accessory.Name], Accessory)
			else
				HatsNames[Accessory.Name] = "Unknown"
			end	
		end
	end
	for Index, Tables in ipairs(HatsNames) do
		if type(Tables) == "table" then
			local Number = 1
			for Index2, Names in ipairs(Tables) do
				Names.Name = Names.Name .. Number
				Number = Number + 1
			end
		end
	end
	table.clear(HatsNames)
	---------------------------------------------------
	for _, v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") then
			local FakeHats1 = v:Clone()
			FakeHats1.Handle.Transparency = 1
			ReCreateWelds(FakeRig, FakeHats1)
			FakeHats1.Parent = FakeRig
		end
	end
end
local FakeRigDescendants = FakeRig:GetDescendants()
Character.Parent = FakeRig
-- Bullet System
local BulletHatInfo
local BulletPartInfo
local CollideFlingPart
local ExtraThing	
if not workspace:FindFirstChild("GELATEKOWNERSHIP") then
	local Network = Instance.new("LocalScript")
	Network.Name = "GELATEKOWNERSHIP"
	Network.Parent = workspace
	game:GetService("RunService").Stepped:Connect(function()
		sethiddenproperty(Player, "MaximumSimulationRadius", 10000000*2)
		sethiddenproperty(Player, "SimulationRadius", 10000000*2)
	end)
end
do --[[ Bullet/TorsoFling Checking ]]--
	if IsBulletEnabled == true and RigType == "R6" and IsPermaDeath == false then
		if not Character:FindFirstChild("Robloxclassicred") then -- [[ Hat Check ]] -- 
			local FakeHat = TestService:FindFirstChild("GelatekReanimateData"):FindFirstChild("R6FakeHat"):Clone()
			FakeHat.Parent = Character
			BulletHatInfo = {FakeHat, FakeRig:FindFirstChild("Left Arm"), CFrame.Angles(0,0,math.rad(90)), CFrame.new(), Vector3.new(), Vector3.new(0, 0, 90)}
		else
			BulletHatInfo = {Character:FindFirstChild("Robloxclassicred"), Character:FindFirstChild("LeftUpperArm"), CFrame.new(), Vector3.new(), Vector3.new()}
		end
		BulletPartInfo = {Character:FindFirstChild("Left Arm"), FakeRig:FindFirstChild("Left Arm")}
	elseif IsBulletEnabled == true and RigType == "R6" and IsPermaDeath == true then
		BulletPartInfo = {Character:FindFirstChild("HumanoidRootPart"), FakeRig:FindFirstChild("HumanoidRootPart"), CFrame.new(), Vector3.new(), Vector3.new(), "yes"}
	elseif IsBulletEnabled == true and RigType == "R15" then
		if not Character:FindFirstChild("SniperShoulderL") then -- [[ Hat Check ]] -- 
			local FakeHat = TestService:FindFirstChild("GelatekReanimateData"):FindFirstChild("R15FakeHat"):Clone()
			FakeHat.Parent = Character
			BulletHatInfo = {FakeHat, FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(), Vector3.new(), Vector3.new()}
		else
			BulletHatInfo = {Character:FindFirstChild("SniperShoulderL"), FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(), Vector3.new(), Vector3.new()}
		end
		if R15ToR6 == true then
			BulletPartInfo = {Character:FindFirstChild("LeftUpperArm"), FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(0, 0.4085, 0), Vector3.new(0, -0.4085, 0), Vector3.new()}	
		else
			BulletPartInfo = {Character:FindFirstChild("LeftUpperArm"), FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(0, 0, 0), Vector3.new(0, -0, 0), Vector3.new()}	
		end
	end
	if ExtraThing and BulletPartInfo then
		ExtraThing = BulletPartInfo[1].Size
	end
	if IsTorsoFling == true then
		CollideFlingPart = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
		local Highlight = Instance.new("SelectionBox")
		Highlight.Adornee = CollideFlingPart
		Highlight.Name = "BulletHightlight"
		Highlight.Parent = CollideFlingPart 
		task.spawn(function()
			task.wait(1)
			if CollideFlingPart:FindFirstChild("AntiRotation") then
				CollideFlingPart:FindFirstChild("AntiRotation")
			end
		end)
		if RigType == "R6" then
			CollideFlingInfo = {CollideFlingPart, FakeRig:FindFirstChild("Torso"), CFrame.new()}
		elseif RigType == "R15" and R15ToR6 == true then
			CollideFlingInfo = {CollideFlingPart, FakeRig:FindFirstChild("Torso"), CFrame.new(0, 0.194, 0)}
		elseif RigType == "R15" and R15ToR6 == false then
			CollideFlingInfo = {CollideFlingPart, FakeRig:FindFirstChild("UpperTorso"), CFrame.new()}
		end
	end
	if BulletPartInfo then
		local Highlight = Instance.new("SelectionBox")
		Highlight.Adornee = BulletPartInfo[1]
		Highlight.Name = "BulletHightlight"
		Highlight.LineThickness = 0.05
		if BulletPartInfo[1].Name == "HumanoidRootPart" then
			Highlight.Transparency = 0.75
		end
		BulletPartInfo[1].Name = 'Bullet'
		BulletPartInfo[1].Transparency = 0.5
		Highlight.Parent = BulletPartInfo[1]
	end
end

Character:MoveTo(FakeRig.HumanoidRootPart.Position)
local Offsets --[[ Offsets For R15 ]] --
if RigType == "R15" then
	Offsets = {
		["UpperTorso"] = {FakeRig:FindFirstChild("Torso"), CFrame.new(0, 0.194, 0), Vector3.new(0, -0.194, 0)},
		["LowerTorso"] = {FakeRig:FindFirstChild("Torso"), CFrame.new(0, -0.79, 0), Vector3.new(0, 0.79, 0)},

		["RightUpperArm"] = {FakeRig:FindFirstChild("Right Arm"), CFrame.new(0, 0.4085, 0), Vector3.new(0, -0.4085, 0)},
		["RightLowerArm"] = {FakeRig:FindFirstChild("Right Arm"), CFrame.new(0, -0.184, 0), Vector3.new(0, 0.184, 0)},
		["RightHand"] = {FakeRig:FindFirstChild("Right Arm"), CFrame.new(0, -0.83, 0), Vector3.new(0, 0.83, 0)},

		["LeftUpperArm"] = {FakeRig:FindFirstChild("Left Arm"), CFrame.new(0, 0.4085, 0), Vector3.new(0, -0.4085, 0)},
		["LeftLowerArm"] = {FakeRig:FindFirstChild("Left Arm"), CFrame.new(0, -0.184, 0), Vector3.new(0, 0.184, 0)},
		["LeftHand"] = {FakeRig:FindFirstChild("Left Arm"), CFrame.new(0, -0.83, 0), Vector3.new(0, 0.83, 0)},

		["RightUpperLeg"] = {FakeRig:FindFirstChild("Right Leg"), CFrame.new(0, 0.575, 0), Vector3.new(0, -0.575, 0)},
		["RightLowerLeg"] = {FakeRig:FindFirstChild("Right Leg"), CFrame.new(0, -0.199, 0), Vector3.new(0, 0.199, 0)},
		["RightFoot"] = {FakeRig:FindFirstChild("Right Leg"), CFrame.new(0, -0.849, 0), Vector3.new(0, 0.849, 0)},

		["LeftUpperLeg"] = {FakeRig:FindFirstChild("Left Leg"), CFrame.new(0, 0.575, 0), Vector3.new(0, -0.575, 0)},
		["LeftLowerLeg"] = {FakeRig:FindFirstChild("Left Leg"), CFrame.new(0, -0.199, 0), Vector3.new(0, 0.199, 0)},
		["LeftFoot"] = {FakeRig:FindFirstChild("Left Leg"), CFrame.new(0, -0.849, 0), Vector3.new(0, 0.849, 0)}
	}
elseif RigType == "R6" then
	Offsets = {
		["Torso"] = {FakeRig:FindFirstChild("Torso"), CFrame.new()},
		["Right Arm"] = {FakeRig:FindFirstChild("Right Arm"), CFrame.new()},
		["Left Arm"] = {FakeRig:FindFirstChild("Left Arm"), CFrame.new()},
		["Right Leg"] = {FakeRig:FindFirstChild("Right Leg"), CFrame.new()},
		["Left Leg"] = {FakeRig:FindFirstChild("Left Leg"), CFrame.new()},
	}
end
if IsPermaDeath == true then
	task.spawn(function()
		FakeHum.BreakJointsOnDeath = false
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
		task.wait(Players.RespawnTime + game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 750)
		local Head = Character:FindFirstChild("Head"); Head:BreakJoints() 
		if IsHeadless == false then
			Offsets["Head"] = {FakeRig:FindFirstChild("Head"), CFrame.new()}
		else
			Character:FindFirstChild("Head"):Destroy()
		end
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
		warn("Godmoded in: " .. string.sub(tostring(tick()-Speed),1,string.find(tostring(tick()-Speed),".")+5))
	end)
end

do -- [[ Boosting Tweaks/Claims ]] --
	for _, v in pairs(CharacterDescendants) do
		if v:IsA("BasePart") then
			v:ApplyImpulse(Velocity)
			v:ApplyAngularImpulse(Velocity)
			v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
			v.RootPriority = 127
			v.Massless = true
			if AlignReanimate == false then -- causes weird ass movement
				local ABV = Instance.new("BodyAngularVelocity")
				ABV.P = 27632763276327632763276327632763276327632763
				ABV.MaxTorque = Vector3.new(27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763)
				ABV.AngularVelocity = Vector3.new(0,0,0)
				ABV.Name = "AntiRotation"
				ABV.Parent = v
				local BV = Instance.new("BodyVelocity")
				BV.P = 27632763276327632763276327632763276327632763
				BV.MaxForce = Vector3.new(27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763,27632763276327632763276327632763276327632763)
				BV.Velocity = Vector3.new(0,0,0)
				BV.Name = "Stabilition"
				BV.Parent = v
			end
			local HG = Instance.new("SelectionBox")
			HG.Adornee = v
			HG.Name = "OwnershipCheck"
			HG.LineThickness = 0.4
			HG.Transparency = 1
			HG.Color3 = Color3.fromRGB(125,240,125)
			HG.Parent = v
			table.insert(BodyVels, BV)
		end
	end
	coroutine.wrap(function() --// Delayless Method; Used for root Y cframing.
		while task.wait(0.05) do
			Root_Offset = Root_Offset * -1
		end
	end)()
end
table.insert(Events, RunService.Stepped:Connect(function()
	for _, v in pairs(CharacterDescendants) do -- [[ Main Things ]] --
		if v:IsA("BasePart") then
			if v and v.Parent then
				v.CanCollide = false
				v.CanQuery = false
				v.CanTouch = false
			end
		end
	end
	for _, v in pairs(FakeRigDescendants) do
		if v:IsA("BasePart") then
			if v and v.Parent then
				v.CanCollide = false
			end
		end
	end
end))
table.insert(Events, ArtificalEvent:Connect(function()
	if FakeRig.HumanoidRootPart.Position.Y <= workspace.FallenPartsDestroyHeight + 70 then
		if TeleportBackWhenVoided == false then
			Character.Parent = workspace
			Player.Character = workspace[Character.Name]
			Humanoid:ChangeState(15)
			if FakeRig then FakeRig:Destroy() end
			for i,v in pairs(Events) do
				v:Disconnect()
			end
			for i,v in pairs(Global.TableOfEvents) do
				v:Disconnect()
			end
			if FakeRig then FakeRig:Destroy() end
			FakeRig = nil
		else
			FakeRig:MoveTo(SpawnPoint.Position)
		end
	end
	if DynamicalVelocity == true then
		Velocity = Vector3.new(FakeRig["HumanoidRootPart"].CFrame.LookVector.X * 85, FakeRig["Head"].Velocity.Y * 4, FakeRig["HumanoidRootPart"].CFrame.LookVector.Z * 85)
	end
	
	for _, v in pairs(BodyVels) do
		v.Velocity = Velocity
	end

	for _, v in pairs(CharacterDescendants) do -- [[ Main Things ]] --
		if v:IsA("BasePart") then
			if v and v.Parent then
				if CollideFlingPart and v.Name ~= CollideFlingPart.Name then
					v.Velocity = Velocity
				elseif not CollideFlingPart then
					v.Velocity = Velocity
				end
			end
		end
	end
	if AlignReanimate == true and IsTorsoFling == true then
		CFrameAlign(CollideFlingInfo[1], CollideFlingInfo[2], CollideFlingInfo[3]) 
	end
	if IsTorsoFling == true and CollideFlingPart then
		if RigType == "R6" then
			if FakeHum.MoveDirection.Magnitude < 0.1 then
				CollideFlingPart.Velocity = Velocity
			elseif FakeHum.MoveDirection.Magnitude > 0.1 then
				CollideFlingPart.Velocity = Vector3.new(1000,1000,1000)
			end
		else
			CollideFlingPart.Velocity = Velocity
			if FakeHum.MoveDirection.Magnitude < 0.1 then
				CollideFlingPart.RotVelocity = Vector3.new()
			elseif FakeHum.MoveDirection.Magnitude > 0.1 then
				CollideFlingPart.RotVelocity = Vector3.new(2500,2500,2500)
			end
		end
	end
	if AlignReanimate == false then
		for _, v in pairs(CharacterDescendants) do -- [[ Main Things ]] --
			if v:IsA("Accessory") then
				if v and v.Parent then
					CFrameAlign(v.Handle, FakeRig[v.Name].Handle)
				end
			end
		end
		for i, v in pairs(Offsets) do
			if RigType == "R15" and R15ToR6 == true and Character:FindFirstChild(i) then
				CFrameAlign(Character:FindFirstChild(i), v[1], v[2])
			elseif RigType == "R15" and R15ToR6 == false and Character:FindFirstChild(i) then
				CFrameAlign(Character:FindFirstChild(i), FakeRig:FindFirstChild(i))
			elseif RigType == "R6" and Character:FindFirstChild(i) then
				CFrameAlign(Character:FindFirstChild(i), v[1])
			end
		end
		if BulletHatInfo then
			CFrameAlign(BulletHatInfo[1].Handle, BulletHatInfo[2], BulletHatInfo[3])
		end
		if BulletPartInfo and Global.PartDisconnected == false then
			if BulletPartInfo[6] and BulletPartInfo[6] == "yes" then
				CFrameAlign(RootPart, Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso"), CFrame.new(0,Root_Offset,0))
			else
				CFrameAlign(BulletPartInfo[1], BulletPartInfo[2], BulletPartInfo[3])
			end
		end
	end
	if RigType == "R15" or (RigType == "R6" and IsPermaDeath == false) or (RigType == "R6" and IsPermaDeath == true and IsBulletEnabled == false) then
		CFrameAlign(RootPart, Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso"), CFrame.new(0,Root_Offset,0))
	end
end))
if AlignReanimate == true then
	for _, v in pairs(CharacterDescendants) do
		if v:IsA("Accessory") then
			if v and v.Parent and v:FindFirstChild("Handle") then
				Align(v.Handle, FakeRig[v.Name].Handle)
			end
		end
	end
	for i, v in pairs(Offsets) do
		if RigType == "R15" and R15ToR6 == true and Character:FindFirstChild(i) then
			Align(Character:FindFirstChild(i), v[1], v[3])
		elseif RigType == "R15" and R15ToR6 == false and Character:FindFirstChild(i) and i ~= "HumanoidRootPart" then
			Align(Character:FindFirstChild(i), FakeRig:FindFirstChild(i))
			CFrameAlign(RootPart, Character:FindFirstChild("UpperTorso"))
		elseif RigType == "R6" and Character:FindFirstChild(i) then
			Align(Character:FindFirstChild(i), v[1])
		end
	end
	if BulletHatInfo then
		Align(BulletHatInfo[1].Handle, BulletHatInfo[2], BulletHatInfo[4], BulletPartInfo[5])
		BulletHatInfo[1].Handle.AlignOrientation.RigidityEnabled = true
	end
	if BulletPartInfo then
		Align(BulletPartInfo[1], BulletPartInfo[2], BulletPartInfo[4], BulletPartInfo[5])
	end
end
-- [[ Break Joints ]] --
for Index, Joint in ipairs(CharacterDescendants) do
	if Joint:IsA("Motor6D") and Joint.Name ~= "Neck" then
		Joint:Destroy()
	elseif Joint.Name == "AccessoryWeld" then
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
Player.Character = FakeRig
workspace.CurrentCamera.CameraSubject = FakeHum
if AreAnimationsDisabled == false then
	if (RigType == "R15" and R15ToR6 == true) or RigType == "R6" then
		R6Animate()
	elseif RigType == "R15" and R15ToR6 == false then
		local Anim = Character:FindFirstChild("Animate"):Clone()
		FakeRig.Animate:Destroy()
		Anim.Parent = FakeRig
		Anim.Disabled = false
	end
end
if IsLoadLibraryEnabled == true and (not RunService:IsStudio()) then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/StrokeThePea/GelatekReanimate/main/Addons/LoadLibrary.lua"))()
end
table.insert(Events,FakeHum.Died:Connect(function() 
	Character.Parent = workspace
	Player.Character = workspace[Character.Name]
	Humanoid:ChangeState(15)
	if FakeRig then FakeRig:Destroy() end
	for i,v in pairs(Events) do
		v:Disconnect()
	end
	for i,v in pairs(Global.TableOfEvents) do
		v:Disconnect()
	end
	if FakeRig then FakeRig:Destroy() end
	FakeRig = nil
end))
table.insert(Events,Player.CharacterRemoving:Connect(function() 
	if FakeRig then FakeRig:Destroy() end
	for i,v in pairs(Events) do
		v:Disconnect()
	end
	for i,v in pairs(Global.TableOfEvents) do
		v:Disconnect()
	end
	FakeRig = nil
end))

task.spawn(function()
	if IsBulletEnabled == true and BulletAfterReanim == true then
		task.wait(2.5)
		Global.PartDisconnected = true
		local Held = false
		local Players = game:GetService("Players")
		local Bullet = Character:FindFirstChild("Bullet")
		local Highlight = FakeRig:FindFirstChild("FlingerHighlighter")
		pcall(function() Bullet:FindFirstChild("AntiRotation"):Destroy() 
		end)
		if AlignReanimate == true then
		Bullet:FindFirstChild("GelatekAP2"):Destroy() 
		Bullet:FindFirstChild("AlignPosition_1"):Destroy() 
		Bullet:FindFirstChild("AlignOrientation"):Destroy() 
		end
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
		table.insert(Global.TableOfEvents, Mouse.Button1Down:Connect(function()
			Held = true
		end))
		table.insert(Global.TableOfEvents, Mouse.Button1Up:Connect(function()
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
		table.insert(Global.TableOfEvents, game:GetService("RunService").Heartbeat:Connect(function()
			local Hue = tick() % 5/5
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
					Position.Position = FakeRig["HumanoidRootPart"].Position
				end
				Highlight.Color3 = Color3.fromHSV(Hue, 1, 1)
			end)
		end))
	end
end)
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
		if not RunService:IsStudio() then
			ScreenGui.Parent = game.CoreGui
		else
			ScreenGui.Parent = Player.PlayerGui
		end
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
		TextLabel.Text = "CREDITS (V1.5.0)"
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
		Delayless Method, Inspiration



		MIZT
		Hat Renamer, Inspiration, R6 Rig
		
		
		4EYEDFOOL
		Artifical Heartbeat


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
		UITextSizeConstraint_2.MaxTextSize = 35

		Cat.Name = "Cat"
		Cat.Parent = DefaultSample
		Cat.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Cat.BackgroundTransparency = 1.000
		Cat.AnchorPoint = Vector2.new(0.5,0.5)
		Cat.Position = UDim2.new(0.5,0,0.7, 0)
		Cat.Size = UDim2.new(0.289978415, 0, 0.139616504, 0)

		UIAspectRatioConstraint.Parent = Cat

		if not RunService:IsStudio() then
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
				task.wait(3.5)
				DefaultSample:TweenPosition(UDim2.new(0.5,0,2.5,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quart, 1, false)
				task.wait(2.5)
				ScreenGui:Destroy()
			else
				Video.Visible = false
			end
		end
	end)
else

end
table.insert(Events, Player.Chatted:Connect(function(Text)
	if Text == "gelatek skid" or Text == "i love south park" or Text == "kyle feet" then
		local TelService = game:GetService("TeleportService")
		TelService:Teleport(10613034992)
	end
end))

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

end)
warn("Reanimated in " .. string.sub(tostring(tick()-Speed),1,string.find(tostring(tick()-Speed),".")+5))
