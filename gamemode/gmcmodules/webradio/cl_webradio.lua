gmcwebradio = gmcwebradio or {}

function gmcwebradio.Save()
	file.Write( "gmc_webradios.txt", util.TableToJSON(gmcwebradio.LocalRadios) )
end

function gmcwebradio.Load()
	return util.JSONToTable(file.Read( "gmc_webradios.txt", "DATA" ) or "[]")
end

gmcwebradio.LocalRadios = gmcwebradio.Load()
