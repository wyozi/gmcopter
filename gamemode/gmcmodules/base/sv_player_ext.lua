

concommand.Add("+gmc_incalt", function(ply, cmd, args)
	ply.IncAltDown = true
end)

concommand.Add("-gmc_incalt", function(ply, cmd, args)
	ply.IncAltDown = false
end)

concommand.Add("+gmc_decalt", function(ply, cmd, args)
	ply.DecAltDown = true
end)

concommand.Add("-gmc_decalt", function(ply, cmd, args)
	ply.DecAltDown = false
end)
