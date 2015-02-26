hook.Add("PlayerSpawn", "GMCGiveDevWeapons", function(ply)
	if ply:GMC_IsDeveloper() then
		ply:Give("weapon_physgun")
		ply:Give("gmod_tool")
		ply:Give("gmod_camera")
	end
end)