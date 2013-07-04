GMC_CAMVIEW_FIRSTPERSON = 1
GMC_CAMVIEW_CHASE = 2
GMC_CAMVIEW_THIRDPERSON = 3
GMC_CAMVIEW_COCKPIT = 4

CreateClientConVar("gmc_camview", GMC_CAMVIEW_FIRSTPERSON, true, false)

local table = table

-- Hide the standard HUD stuff
local hud = {"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudVoiceStatus", "CHudVoiceSelfStatus"} --"CHudCrosshair", 
function GM:HUDShouldDraw(name)
	return not table.HasValue(hud, name)
end

function GM:HUDPaint()
	if not HeliGui or not HeliGui:IsVisible() then
		HeliGui = vgui.Create("HGuiFrame")
		MsgN("Creating HGuiFrame")
	end
end