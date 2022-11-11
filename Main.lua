
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
local HubMode = Global.HubMode or false

-- [[ Variables ]] --
local Events = {}
local BodyVels = {}
local Root_Offset = 0.02
local Velocity = Vector3.new(0,0,-25.8)
local SpawnPoint = workspace:FindFirstChildOfClass("SpawnLocation",true) and workspace:FindFirstChildOfClass("SpawnLocation",true) or CFrame.new(0,20,0)

-- [[ Functions ]] --
local setfflag = setfflag or function(flag,bool) game:DefineFastFlag(flag,bool) end
local isnetworkowner = isnetworkowner or function(Part) return Part.ReceiveAge == 0 end
local sethiddenproperty = sethiddenproperty or set_hidden_property or function() end 
	
-- [[ Checking Settings ]] --
local Config = Global.GelatekReanimateConfig or {}
Global.TableOfEvents = {}

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
local OldVelocityMethod = Config.OldVelocityMethod or false -- Self Explainatory

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
	pcall(function() Handle:FindFirstChildOfClass("Weld"):Destroy() end)
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
	local EventList = {"PreRender","PreAnimation","PreSimulation","PostSimulation"}
	if FasterHeartbeat == false then
		EventList = {"PostSimulation"}
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
    local a=game.Players.LocalPlayer.Character;local b=a:WaitForChild("Torso")local c=b:WaitForChild("Right Shoulder")local d=b:WaitForChild("Left Shoulder")local e=b:WaitForChild("Right Hip")local f=b:WaitForChild("Left Hip")local g=b:WaitForChild("Neck")local h=a:WaitForChild("Humanoid")local i="Standing"local j=""local k=nil;local l=nil;local m=nil;local n=1.0;local o={}local p={idle={{id="http://www.roblox.com/asset/?id=180435571",weight=9},{id="http://www.roblox.com/asset/?id=180435792",weight=1}},walk={{id="http://www.roblox.com/asset/?id=180426354",weight=10}},run={{id="run.xml",weight=10}},jump={{id="http://www.roblox.com/asset/?id=125750702",weight=10}},fall={{id="http://www.roblox.com/asset/?id=180436148",weight=10}},climb={{id="http://www.roblox.com/asset/?id=180436334",weight=10}},sit={{id="http://www.roblox.com/asset/?id=178130996",weight=10}},toolnone={{id="http://www.roblox.com/asset/?id=182393478",weight=10}},toolslash={{id="http://www.roblox.com/asset/?id=129967390",weight=10}},toollunge={{id="http://www.roblox.com/asset/?id=129967478",weight=10}},wave={{id="http://www.roblox.com/asset/?id=128777973",weight=10}},point={{id="http://www.roblox.com/asset/?id=128853357",weight=10}},dance1={{id="http://www.roblox.com/asset/?id=182435998",weight=10},{id="http://www.roblox.com/asset/?id=182491037",weight=10},{id="http://www.roblox.com/asset/?id=182491065",weight=10}},dance2={{id="http://www.roblox.com/asset/?id=182436842",weight=10},{id="http://www.roblox.com/asset/?id=182491248",weight=10},{id="http://www.roblox.com/asset/?id=182491277",weight=10}},dance3={{id="http://www.roblox.com/asset/?id=182436935",weight=10},{id="http://www.roblox.com/asset/?id=182491368",weight=10},{id="http://www.roblox.com/asset/?id=182491423",weight=10}},laugh={{id="http://www.roblox.com/asset/?id=129423131",weight=10}},cheer={{id="http://www.roblox.com/asset/?id=129423030",weight=10}}}local q={"dance1","dance2","dance3"}local r={wave=false,point=false,dance1=true,dance2=true,dance3=true,laugh=false,cheer=false}function configureAnimationSet(s,t)if o[s]~=nil then for u,v in pairs(o[s].connections)do v:disconnect()end end;o[s]={}o[s].count=0;o[s].totalWeight=0;o[s].connections={}local w=script:FindFirstChild(s)if w~=nil then table.insert(o[s].connections,w.ChildAdded:connect(function(x)configureAnimationSet(s,t)end))table.insert(o[s].connections,w.ChildRemoved:connect(function(x)configureAnimationSet(s,t)end))local y=1;for u,z in pairs(w:GetChildren())do if z:IsA("Animation")then table.insert(o[s].connections,z.Changed:connect(function(A)configureAnimationSet(s,t)end))o[s][y]={}o[s][y].anim=z;local B=z:FindFirstChild("Weight")if B==nil then o[s][y].weight=1 else o[s][y].weight=B.Value end;o[s].count=o[s].count+1;o[s].totalWeight=o[s].totalWeight+o[s][y].weight;y=y+1 end end end;if o[s].count<=0 then for y,C in pairs(t)do o[s][y]={}o[s][y].anim=Instance.new("Animation")o[s][y].anim.Name=s;o[s][y].anim.AnimationId=C.id;o[s][y].weight=C.weight;o[s].count=o[s].count+1;o[s].totalWeight=o[s].totalWeight+C.weight end end end;function scriptChildModified(x)local t=p[x.Name]if t~=nil then configureAnimationSet(x.Name,t)end end;script.ChildAdded:connect(scriptChildModified)script.ChildRemoved:connect(scriptChildModified)for s,t in pairs(p)do configureAnimationSet(s,t)end;local D="None"local E=0;local F=0;local G=0.3;local H=0.1;local I=0.3;local J=0.75;function stopAllAnimations()local K=j;if r[K]~=nil and r[K]==false then K="idle"end;j=""k=nil;if m~=nil then m:disconnect()end;if l~=nil then l:Stop()l:Destroy()l=nil end;return K end;function setAnimationSpeed(L)if L~=n then n=L;l:AdjustSpeed(n)end end;function keyFrameReachedFunc(M)if M=="End"then local N=j;if r[N]~=nil and r[N]==false then N="idle"end;local O=n;playAnimation(N,0.0,h)setAnimationSpeed(O)end end;function playAnimation(P,Q,R)pcall(function()local S=math.random(1,o[P].totalWeight)local T=S;local y=1;while S>o[P][y].weight do S=S-o[P][y].weight;y=y+1 end;local C=o[P][y].anim;if C~=k then if l~=nil then l:Stop(Q)l:Destroy()end;n=1.0;l=R:LoadAnimation(C)l.Priority=Enum.AnimationPriority.Core;l:Play(Q)j=P;k=C;if m~=nil then m:disconnect()end;m=l.KeyframeReached:connect(keyFrameReachedFunc)end end)end;local U=""local V=nil;local W=nil;local X=nil;function toolKeyFrameReachedFunc(M)if M=="End"then playToolAnimation(U,0.0,h)end end;function playToolAnimation(P,Q,R,Y)local S=math.random(1,o[P].totalWeight)local T=S;local y=1;while S>o[P][y].weight do S=S-o[P][y].weight;y=y+1 end;local C=o[P][y].anim;if W~=C then if V~=nil then V:Stop()V:Destroy()Q=0 end;V=R:LoadAnimation(C)if Y then V.Priority=Y end;V:Play(Q)U=P;W=C;X=V.KeyframeReached:connect(toolKeyFrameReachedFunc)end end;function stopToolAnimations()local K=U;if X~=nil then X:disconnect()end;U=""W=nil;if V~=nil then V:Stop()V:Destroy()V=nil end;return K end;function onRunning(L)pcall(function()if L>0.01 then playAnimation("walk",0.1,h)if k and k.AnimationId=="http://www.roblox.com/asset/?id=180426354"then setAnimationSpeed(L/14.5)end;i="Running"else if r[j]==nil then playAnimation("idle",0.1,h)i="Standing"end end end)end;function onDied()i="Dead"end;function onJumping()playAnimation("jump",0.1,h)F=G;i="Jumping"end;function onClimbing(L)playAnimation("climb",0.1,h)setAnimationSpeed(L/12.0)i="Climbing"end;function onGettingUp()i="GettingUp"end;function onFreeFall()if F<=0 then playAnimation("fall",I,h)end;i="FreeFall"end;function onFallingDown()i="FallingDown"end;function onSeated()i="Seated"end;function onPlatformStanding()i="PlatformStanding"end;function onSwimming(L)if L>0 then i="Running"else i="Standing"end end;function getTool()for u,Z in ipairs(a:GetChildren())do if Z.className=="Tool"then return Z end end;return nil end;function getToolAnim(_)for u,a0 in ipairs(_:GetChildren())do if a0.Name=="toolanim"and a0.className=="StringValue"then return a0 end end;return nil end;function animateTool()if D=="None"then playToolAnimation("toolnone",H,h,Enum.AnimationPriority.Idle)return end;if D=="Slash"then playToolAnimation("toolslash",0,h,Enum.AnimationPriority.Action)return end;if D=="Lunge"then playToolAnimation("toollunge",0,h,Enum.AnimationPriority.Action)return end end;function moveSit()c.MaxVelocity=0.15;d.MaxVelocity=0.15;c:SetDesiredAngle(3.14/2)d:SetDesiredAngle(-3.14/2)e:SetDesiredAngle(3.14/2)f:SetDesiredAngle(-3.14/2)end;local a1=0;function move(a2)local a3=1;local a4=1;local a5=a2-a1;a1=a2;local a6=0;local a7=false;if F>0 then F=F-a5 end;if i=="FreeFall"and F<=0 then playAnimation("fall",I,h)elseif i=="Seated"then playAnimation("sit",0.5,h)return elseif i=="Running"then playAnimation("walk",0.1,h)elseif i=="Dead"or i=="GettingUp"or i=="FallingDown"or i=="Seated"or i=="PlatformStanding"then stopAllAnimations()a3=0.1;a4=1;a7=true end;if a7 then local a8=a3*math.sin(a2*a4)c:SetDesiredAngle(a8+a6)d:SetDesiredAngle(a8-a6)e:SetDesiredAngle(-a8)f:SetDesiredAngle(-a8)end;local _=getTool()if _ and _:FindFirstChild("Handle")then local a9=getToolAnim(_)if a9 then D=a9.Value;a9.Parent=nil;E=a2+.3 end;if a2>E then E=0;D="None"end;animateTool()else stopToolAnimations()D="None"W=nil;E=0 end end;table.insert(Events,h.Died:connect(onDied))table.insert(Events,h.Running:connect(onRunning))table.insert(Events,h.Jumping:connect(onJumping))table.insert(Events,h.Climbing:connect(onClimbing))table.insert(Events,h.GettingUp:connect(onGettingUp))table.insert(Events,h.FreeFalling:connect(onFreeFall))table.insert(Events,h.FallingDown:connect(onFallingDown))table.insert(Events,h.Seated:connect(onSeated))table.insert(Events,h.PlatformStanding:connect(onPlatformStanding))table.insert(Events,h.Swimming:connect(onSwimming))game:GetService("Players").LocalPlayer.Chatted:connect(function(aa)local ab=""if aa=="/e dance"then ab=q[math.random(1,#q)]elseif string.sub(aa,1,3)=="/e "then ab=string.sub(aa,4)elseif string.sub(aa,1,7)=="/emote "then ab=string.sub(aa,8)end;if i=="Standing"and r[ab]~=nil then playAnimation(ab,0.1,h)end end)playAnimation("idle",0.1,h)i="Standing"table.insert(Events,game:GetService("RunService").Stepped:Connect(function()local u,a2=wait(0.1)move(a2)end))
end
do -- [[ Checking ]] --
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	if Player.Character.Name == "GelatekReanimate" then
		Notification("Error!", "Reanimate Is Already Running!", 3)
		return nil
	end
	if Player.Character:FindFirstChildWhichIsA("Humanoid").Health == 0 then
		Notification("Error!", "You are currently dead, wait until you will respawn.", 3)
		return nil
	end
    if Player.Name == "aliali1974" then
		Notification("Error!", "Please Kill Yourself Com. You are a fucking failure to the society, Your innocence has been lost. GTFO. ", 3)
		task.wait(4)
		Player:Kick("kys")
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
				Root.Transparency = 1
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
local CameraCFrame = workspace.CurrentCamera.CFrame
local FakeHats = Instance.new("Folder"); do
	FakeHats.Name = "FakeHats"
	FakeHats.Parent = Character
end
local RigType = Humanoid.RigType.Name
Character.Archivable = true
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
Character.Parent = FakeRig
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
			BulletHatInfo = {Character:FindFirstChild("Robloxclassicred"), FakeRig:FindFirstChild("Left Arm"), CFrame.Angles(0,0,math.rad(90)), Vector3.new(), Vector3.new()}
		end
		BulletPartInfo = {Character:FindFirstChild("Left Arm"), FakeRig:FindFirstChild("Left Arm")}
	elseif IsBulletEnabled == true and RigType == "R6" and IsPermaDeath == true then
		BulletPartInfo = {Character:FindFirstChild("HumanoidRootPart"), FakeRig:FindFirstChild("HumanoidRootPart"), CFrame.new(), Vector3.new(), Vector3.new(), "yes"}
	elseif IsBulletEnabled == true and RigType == "R15" then
		local funnyoffseto = {0, 0}
		if R15ToR6 == true then
			funnyoffseto = {0.5, -0.5}
		end
		if not Character:FindFirstChild("SniperShoulderL") then -- [[ Hat Check ]] -- 
			local FakeHat = TestService:FindFirstChild("GelatekReanimateData"):FindFirstChild("R15FakeHat"):Clone()
			FakeHat.Parent = Character
			BulletHatInfo = {FakeHat, FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(0, funnyoffseto[1], 0), Vector3.new(0, funnyoffseto[2], 0), Vector3.new()}
		else
			BulletHatInfo = {Character:FindFirstChild("SniperShoulderL"), FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(0, funnyoffseto[1], 0), Vector3.new(0, funnyoffseto[2], 0), Vector3.new()}
		end
		if R15ToR6 == true then
			BulletPartInfo = {Character:FindFirstChild("LeftUpperArm"), FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(0, 0.4085, 0), Vector3.new(0, -0.4085, 0), Vector3.new()}	
		else
			BulletPartInfo = {Character:FindFirstChild("LeftUpperArm"), FakeRig:FindFirstChild("Left Arm") or FakeRig:FindFirstChild("LeftUpperArm"), CFrame.new(0, 0, 0), Vector3.new(0, -0, 0), Vector3.new()}	
		end
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
	else
		CollideFlingInfo = nil
		CollideFlingPart = nil
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
		if IsHeadless == false and AlignReanimate == true then
			Align(Character:FindFirstChild("Head"), FakeRig:FindFirstChild("Head"))	
		end
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
		warn("Godmoded in: " .. string.sub(tostring(tick()-Speed),1,string.find(tostring(tick()-Speed),".")+5))
	end)
end
-- fakehats for stop script for my hub
for _, v in pairs(Character:GetChildren()) do
	if v:IsA("Accessory") then
		local FakeHats1 = v:Clone()
		FakeHats1.Handle.Transparency = 1
		ReCreateWelds(FakeRig, FakeHats1)
		FakeHats1.Parent = FakeHats
	end
end

do -- [[ Boosting Tweaks/Claims ]] --
	for _, v in pairs(CharacterDescendants) do
		if v:IsA("BasePart") then
			v:ApplyAngularImpulse(Vector3.new())
			v:ApplyImpulse(Velocity)
			v.RootPriority = 127
			if HubMode == false then
				v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)	
				v.Massless = true
			end
			if AlignReanimate == false then -- causes weird ass movement
				local ABV = Instance.new("BodyAngularVelocity")
				ABV.P = 1/0
				ABV.MaxTorque = Vector3.new(1/0,1/0,1/0)
				ABV.AngularVelocity = Vector3.new(0,0,0)
				ABV.Name = "AntiRotation"
				ABV.Parent = v
				local BV = Instance.new("BodyVelocity")
				BV.P = 1/0
				BV.MaxForce = Vector3.new(1/0,1/0,1/0)
				BV.Velocity = Vector3.new(0,0,0)
				BV.Name = "Stabilition"
				BV.Parent = v
				table.insert(BodyVels, BV)
			end
			local HG = Instance.new("SelectionBox")
			HG.Adornee = v
			HG.Name = "OwnershipCheck"
			HG.LineThickness = 0.4
			HG.Transparency = 1
			HG.Color3 = Color3.fromRGB(125,240,125)
			HG.Parent = v
		end
	end
	coroutine.wrap(function() --// Delayless Method; Used for root Y cframing.
		while task.wait(0.05) do
			Root_Offset = Root_Offset * -1
		end
	end)()
end
table.insert(Events, RunService.PreSimulation:Connect(function()
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

local function Death()
	Global.Stopped = true
    Character.Parent = workspace
    Player.Character = workspace:FindFirstChild(Character.Name)
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
    task.wait(0.15)
    if game:FindFirstChildOfClass("TestService"):FindFirstChild("ScriptCheck") then
		game:FindFirstChildOfClass("TestService"):FindFirstChild("ScriptCheck"):Destroy()
	end
    Global.Stopped = false
end
	
table.insert(Events, ArtificalEvent:Connect(function()
	if FakeRig.HumanoidRootPart.Position.Y <= workspace.FallenPartsDestroyHeight + 70 then
		if TeleportBackWhenVoided == false then
            pcall(function()
                Death()
            end)
		else
			FakeRig:MoveTo(SpawnPoint.Position)
		end
	end
	if not CollideFlingInfo then
		local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
		Torso.AssemblyLinearVelocity = Velocity	
	end
	for _, v in pairs(BodyVels) do
		v.Velocity = Velocity
	end

	for _, v in pairs(CharacterDescendants) do -- [[ Main Things ]] --
		if v:IsA("BasePart") then
			if v and v.Parent then
				if (CollideFlingInfo and v.Name ~= CollideFlingInfo[1].Name) or not CollideFlingInfo then
					v.AssemblyLinearVelocity = Velocity
				end
			end
		end
	end
	if AlignReanimate == true and IsTorsoFling == true then
		CFrameAlign(CollideFlingInfo[1], CollideFlingInfo[2], CollideFlingInfo[3]) 
	end
	if IsTorsoFling == true then
		if RigType == "R6" then
			if FakeHum.MoveDirection.Magnitude < 0.1 then
				CollideFlingPart.AssemblyLinearVelocity = Velocity
			elseif FakeHum.MoveDirection.Magnitude > 0.1 then
				CollideFlingPart.AssemblyLinearVelocity = Vector3.new(1000,1000,1000)
			end
		else
			CollideFlingPart.AssemblyLinearVelocity = Velocity
			if FakeHum.MoveDirection.Magnitude < 0.1 then
				CollideFlingPart.RotVelocity = Vector3.new()
			elseif FakeHum.MoveDirection.Magnitude > 0.1 then
				CollideFlingPart.RotVelocity = Vector3.new(2500,2500,2500)
			end
		end
	else

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

if DynamicalVelocity == true then
	local Y_Vel = Vector3.new(0, 25.25, 0)
	table.insert(Events, RunService.PreSimulation:Connect(function()
		if OldVelocityMethod == true then
			Velocity = Vector3.new(FakeRig["HumanoidRootPart"].CFrame.LookVector.X * 85, FakeRig["Head"].Velocity.Y * 4, FakeRig["HumanoidRootPart"].CFrame.LookVector.Z * 85)
		else
			if FakeRig.HumanoidRootPart.Velocity.Y > 0 and FakeRig.HumanoidRootPart.Velocity.Y < 3 then
				Y_Vel = Vector3.new(0,25.25,0)
			else
				Y_Vel = Vector3.new(0,28 + (FakeHum.JumpPower/12.5) + FakeRig.HumanoidRootPart.Velocity.Y/15, 0)
			end
			if FakeHum.MoveDirection.Magnitude < 0.1 then
				Velocity = Y_Vel
			elseif FakeHum.MoveDirection.Magnitude > 0.1 then
				Velocity = FakeHum.MoveDirection * 125 + Y_Vel
			end
		end
	end))
end
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
local CurCameraOffset = workspace.CurrentCamera.CFrame
workspace.CurrentCamera.CFrame = CurCameraOffset
Player.Character = FakeRig
workspace.CurrentCamera.CFrame = CurCameraOffset
workspace.CurrentCamera.CameraSubject = FakeHum
workspace.CurrentCamera.CFrame = CurCameraOffset
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
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Gelatekussy/GelatekReanimate/main/Addons/LoadLibrary.lua"))()
end
table.insert(Events,FakeHum.Died:Connect(function() 
    Death()
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
		TextLabel.Text = "CREDITS (V1.5.5)"
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
		Hat Renamer, Inspiration
		
		
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
	if Text == "gelatek skid" then
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
