concommand.Add("mission", function(ply, cmd, args)
	local t = args[1] or "transport"


	if t == "transport" then
		local rand_npc = table.Random(ents.FindByClass("gmc_npc_generic"))

		local mission = gmc.class("TransportMission"):new()
		mission:add_player(ply)
		mission:add_npc(rand_npc)

		mission:start()
	elseif t == "roofrescue" then
		local rand_npc = table.Random(ents.FindByClass("gmc_npc_generic"))

		local mission = gmc.class("RooftopRescueMission"):new()
		mission:add_player(ply)
		mission:add_npc(rand_npc)

		mission:start()

		rand_npc:SetPos(Vector(600, -4784, -8300))
	elseif t == "fire" then
		local mission = gmc.class("BuildingFireMission"):new()
		mission:add_player(ply)
		mission:start()
	end
end)