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