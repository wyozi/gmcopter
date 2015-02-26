function GM:PlayerInitialSpawn(pl)
end

function GM:PlayerSpawn(pl)
	-- Stop observer mode
	pl:UnSpectate()

	player_manager.SetPlayerClass(pl, "player_gmc")
	player_manager.OnPlayerSpawn(pl)
	player_manager.RunClass(pl, "Spawn")

	hook.Call("PlayerLoadout", GAMEMODE, pl)
	hook.Call("PlayerSetModel", GAMEMODE, pl)
end

-- We don't want to give player anything by default
function GM:PlayerLoadout()
end

function GM:PlayerSelectSpawn(ply)
	local spawns = ents.FindByClass("gmc_pilotspawn")

	if #spawns == 0 then
		spawns = ents.FindByClass("info_player_start")
	end

	return table.Random(spawns)
end