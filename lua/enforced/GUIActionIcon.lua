kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local kIconOffsets = GetUpValue( GUIActionIcon.ShowIcon, "kIconOffsets", { LocateRecurse = true } )

if kIconOffsets then
	kIconOffsets["HeavyMachineGun"] = 0
end
