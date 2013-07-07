gmcwebradio = gmcwebradio or {}

function gmcwebradio.Save()
	file.Write( "gmc_webradios.txt", util.TableToJSON(gmcwebradio.LocalRadios) )
end

function gmcwebradio.Load()
	return util.JSONToTable(file.Read( "gmc_webradios.txt", "DATA" ) or "[]")
end

gmcwebradio.LocalRadios = gmcwebradio.Load()

function gmcwebradio.NextRadioUrl(cur)
	local first
	local retnext = false
	for _, v in pairs(gmcwebradio.LocalRadios) do
		if not first then
			first = v.url
		end
		if v.url == cur then
			retnext = true
		elseif retnext then
			return v.url
		end
	end
	return first
end