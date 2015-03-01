concommand.Add("mission", function(ply, cmd, args)
	local t = args[1] or "transport"


	if t == "transport" then
		local rand_npc = table.Random(ents.FindByClass("gmc_npc_generic"))

		local mission = gmc.class("TransportMission"):new()
		mission:add_player(ply)
		mission:add_npc(rand_npc)

		mission.targetPOI = table.Random(gmc.npcs.POIs)

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
	elseif t == "riot" then
		local mission = gmc.class("RiotControlMission"):new()
		mission:add_player(ply)

		local npcs = ents.FindByClass("gmc_npc_generic")

		local function shuffleTable( t )
			local rand = math.random 
			assert( t, "shuffleTable() expected a table, got nil" )
			local iterations = #t
			local j

			for i = iterations, 2, -1 do
				j = rand(i)
				t[i], t[j] = t[j], t[i]
			end
		end
		shuffleTable(npcs)

		for i=1,8 do
			local rand_npc = table.remove(npcs, 1)
			mission:add_npc(rand_npc)
		end

		mission.targetPOI = table.Random(gmc.npcs.POIs)

		mission:start()
	end
end)