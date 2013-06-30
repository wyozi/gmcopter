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