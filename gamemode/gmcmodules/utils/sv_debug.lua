concommand.Add("gmc_showhitlocal", function(ply)
	local tr = ply:GetEyeTrace()
	gmc.debug.Msg("We hit ", tr.Entity, " pos ", tr.HitPos, " loc ", tr.Entity:WorldToLocal(tr.HitPos))
end)