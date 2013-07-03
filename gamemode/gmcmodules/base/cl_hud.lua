GMC_CAMVIEW_COCKPIT = 1
GMC_CAMVIEW_CHASE = 2

CreateClientConVar("gmc_camview", GMC_CAMVIEW_CHASE, true, false)

local table = table

-- Hide the standard HUD stuff
local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}
function GM:HUDShouldDraw(name)
	return not table.HasValue(hud, name)
end
