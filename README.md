![Default](https://user-images.githubusercontent.com/76650942/178831019-819f6dd5-9a22-4d6c-8495-6b4ab1df57af.png)

# Gelatek Reanimate!
This is the one of the best reanimate I ever made, it's stablest and less jittery from my other reanimations! It Has:
- Better Source Code,
- Optimized,
- R6 and R15 Support,
- R15 To R6,
- Permament Death
- Torso Fling
- Bullet Reanimate
- Delayless
- Low Jitter

# Code:
```lua
local Global = (getgenv and getgenv()) or shared
Global.GelatekReanimateConfig = {
    -- [[ Rig Settings ]] --
    ["AnimationsDisabled"] = false,
    ["R15ToR6"] = false,
    ["DontBreakHairWelds"] = false,
    ["PermanentDeath"] = false,
    ["Headless"] = false,
    ["TeleportBackWhenVoided"] = false,
    
    -- [[ Reanimation Settings ]] --
    ["AlignReanimate"] = false,
    ["FullForceAlign"] = false,
    ["FasterHeartbeat"] = false,
    ["DynamicalVelocity"] = false,
    ["DisableTweaks"] = false,
    
    -- [[ Optimization ]] --
    ["OptimizeGame"] = false,

    -- [[ Miscellacious ]] --
    ["LoadLibrary"] = false,
    ["DetailedCredits"] = false,
    
    -- [[ Flinging Methods ]] --
    ["TorsoFling"] = false,
    ["BulletEnabled"] = false,
    ["BulletConfig"] = {
        ["RunAfterReanimate"] = false,
        ["LockBulletOnTorso"] = false
    }
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/StrokeThePea/GelatekReanimate/main/Main.lua"))()
```


# FAQ:
- Can I use this reanimate?
	- Answer: Yes, The Credits are coded in so you don't have to credit by yourself!
- I have a suggestion!
	- Answer: To suggest something go to the [Discord Server](https://discord.gg/3Qr97C4BDn) and say it in general
- I Found a bug!
	- Answer: To report a bug go to the [Discord Server](https://discord.gg/3Qr97C4BDn) and specify the bug with screenshot, context and error (if it's here)
# Hats:
```
R6 Bullet Hat (Optional And Recommended if BulletEnabled is true and PermamentDeath is false)
https://www.roblox.com/catalog/48474313/Red-Roblox-Cap

R15 Bullet Hat (Optional And Recommended if Bullet is true (PermamentDeath Doesn't matter)
https://www.roblox.com/catalog/5973840187/Left-Sniper-Shoulder
```

# Credits:
- Gelatek: Founder, Main Coder
- ProductionTakeOne: Properties, Optimizations, Help and stuff.
- Mizt: Hat Renamer/Fixer, Inspiration
- MyWorld: Help With Delayless
- 4eyedfool: Faster Heartbeat
