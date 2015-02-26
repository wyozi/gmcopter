concommand.Add("spawnheli", function(ply, cmd, args)
	if not ply:GMC_IsDeveloper() then return end

	local ent = ents.Create("gmc_hc_base")
	ent.Owner = ply
	ent:SetPos(ply:GetEyeTrace().HitPos + Vector(0, 0, 50))
	ent:Spawn()
	ent:Activate()

	do
		local att = ents.Create("gmc_hc_attachment_light")
		ent:HeliAttach(att)
		att:Spawn()
	end
	
	do
		local att = ents.Create("gmc_hc_attachment_radio")
		ent:HeliAttach(att)
		att:Spawn()
	end
end)
