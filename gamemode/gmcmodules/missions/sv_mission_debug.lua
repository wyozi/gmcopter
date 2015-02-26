concommand.Add("mission", function(ply, cmd, args)
	local t = args[1] or "transport"


	if t == "transport" then
		local rand_npc = table.Random(ents.FindByClass("gmc_npc_generic"))
		if IsValid(ply:GetEyeTrace().Entity) and ply:GetEyeTrace().Entity.IsGMCNPC then rand_npc = ply:GetEyeTrace().Entity end

		local mission = gmc.class("TransportMission"):new()
		mission:add_player(ply)
		mission:add_npc(rand_npc)

		mission:start()
	elseif t == "fire" then
		local mission = gmc.class("BuildingFireMission"):new()
		mission:add_player(ply)
		mission:start()
	end
end)