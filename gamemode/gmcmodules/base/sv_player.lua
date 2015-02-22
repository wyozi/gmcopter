
util.AddNetworkString("gmc_ispawn")

function GM:PlayerInitialSpawn( pl )
	MsgN(pl:Nick() .. " initial spawn")

	net.Start("gmc_ispawn")
	net.Send(pl)
end

function GM:PlayerSpawn( pl )
	-- Stop observer mode
	pl:UnSpectate()

	player_manager.SetPlayerClass( pl, "player_gmc" )
	player_manager.OnPlayerSpawn( pl )
	player_manager.RunClass( pl, "Spawn" )

	-- Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )

	-- Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )

end

function GM:PlayerSelectSpawn(ply)

    local spawns = ents.FindByClass( "gmc_pilotspawn" )
    gmc.debug.Msg("PilotSpawns: ", #spawns)
    if #spawns == 0 then
    	spawns = ents.FindByClass( "info_player_start" )
    end
    local random_entry = math.random( #spawns )

    gmc.debug.Msg("Player spawnpoint selected: ", IsValid(spawns[random_entry]))

    return spawns[random_entry]
end

hook.Add("PlayerSetModel", "SetModel", function(ply)
	ply:SetModel("models/player/hostage02.mdl")
end)

concommand.Add("spazz", function(ply)
	local heli = ply:GetHelicopter()
	heli:SetPos(heli:GetPos() + heli:GetVelocity():GetNormalized() * 1000 )
end)