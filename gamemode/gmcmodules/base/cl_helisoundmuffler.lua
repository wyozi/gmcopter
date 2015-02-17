hook.Add("Think", "HeliSoundMuffler", function()
	local shouldbemuffled = LocalPlayer():IsInHelicopter()
	LocalPlayer():SetDSP(shouldbemuffled and 31 or 0, false)
end)
