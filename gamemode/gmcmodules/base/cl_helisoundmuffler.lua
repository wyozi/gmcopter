hook.Add("Think", "HeliSoundMuffler", function()
	local shouldbemuffled = LocalPlayer():IsInHelicopter() and GetConVar("gmc_camview"):GetInt() == GMC_CAMVIEW_FIRSTPERSON
	LocalPlayer():SetDSP(shouldbemuffled and 31 or 0, false)
end)
