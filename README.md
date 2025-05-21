# Heads up!
> [!TIP]
> For people wandering in the dark, my new identity is @xyzkade and my new github is @KadeTheExploiter, if you want to use reanimates, check out [Krypton Reanimate](https://github.com/KadeTheExploiter/Krypton), love you guys!

![Default](https://user-images.githubusercontent.com/76650942/178831019-819f6dd5-9a22-4d6c-8495-6b4ab1df57af.png)
-# repository updated: 21.05.2025
# Gelatek Reanimation.
An limb reanimation handler for roblox, it's pretty cluttered but heavily customizable, that's about it, yeah :-)

> [!WARNING]
>This Reanimate no longer functions in modern games, also beware of optimization issues, as I haven't covered much here (Please use Krypton **for now...**)
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
loadstring(game:HttpGet("https://raw.githubusercontent.com/Gelatekussy/GelatekReanimate/main/Main.lua"))()
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

-# 92..... 92...... 92.... beware... 92.... perhaps...... may this be a setting count? not sure.. haha....
