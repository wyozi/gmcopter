local table = table

-- Hide the standard HUD stuff
local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudVoiceStatus", "CHudVoiceSelfStatus"} --"CHudCrosshair",
function GM:HUDShouldDraw(name)
	return not table.HasValue(hud, name)
end
