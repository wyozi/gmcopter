concommand.Add("mission", function(ply)
	local rand_npc = table.Random(ents.FindByClass("gmc_npc_generic"))
	if IsValid(ply:GetEyeTrace().Entity) and ply:GetEyeTrace().Entity.IsGMCNPC then rand_npc = ply:GetEyeTrace().Entity end

	local mission = gmc.class("TransportMission"):new()
	mission:add_player(ply)
	mission:add_npc(rand_npc)

	mission:start()
end)