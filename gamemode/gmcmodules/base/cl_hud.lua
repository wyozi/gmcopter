GMC_CAMVIEW_COCKPIT = 1
GMC_CAMVIEW_CHASE = 2
GMC_CAMVIEW_THIRDPERSON = 3

CreateClientConVar("gmc_camview", GMC_CAMVIEW_CHASE, true, false)

local table = table

-- Hide the standard HUD stuff
local hud = {"CHudCrosshair", "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudVoiceStatus", "CHudVoiceSelfStatus"}
function GM:HUDShouldDraw(name)
	return not table.HasValue(hud, name)
end
