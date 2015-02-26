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
	
	do
		local att = ents.Create("gmc_hc_attachment_watertanker")
		ent:HeliAttach(att)
		att:Spawn()
	end
end)

concommand.Add("spawnfire", function(ply, cmd, args)
	if not ply:GMC_IsDeveloper() then return end

	local trpos = ply:GetEyeTrace().HitPos + Vector(0, 0, 100)

	local fire = ents.Create("env_fire")
	if not IsValid(fire) then return end

	fire:SetPos(trpos)
	--no glow + delete when out + start on + last forever
	fire:SetKeyValue("spawnflags", tostring(128 + 32 + 4 + 2 + 1))
	fire:SetKeyValue("firesize", (500))
	fire:SetKeyValue("fireattack", 1)
	fire:SetKeyValue("health", 100)
	fire:SetKeyValue("damagescale", "-10") -- only neg. value prevents dmg

	fire:Spawn()
	fire:Activate()
end)