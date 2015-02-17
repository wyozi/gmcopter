MsgN("Loaded base sv_init")

hook.Add("PlayerSpawn", "lel", function(ply)
	ply:Give("weapon_physgun")
end)

concommand.Add("spawnsmth", function(ply, cmd, args)
	MsgN("Creating " .. args[1])
	local ent = ents.Create(args[1])
	--ent:SetOwner(ply) DONT EVER UNCOMMENT THIS. BREAKS VPHYSICS OF EVERYTHING RELATED TO HULL MODEL
	ent.Owner = ply
	ent:SetPos(ply:GetEyeTrace().HitPos + Vector(0, 0, 50))
	--ent:SetAngles(ply:EyeAngles())
	ent:Spawn()
	ent:Activate()
end)

concommand.Add("spawnheli", function(ply, cmd, args)
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
