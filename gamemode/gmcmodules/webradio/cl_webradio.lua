gmc.webradio = gmc.webradio or {}

function gmc.webradio.Save()
	file.Write( "gmc_webradios.txt", util.TableToJSON(gmc.webradio.LocalRadios) )
end

function gmc.webradio.Load()
	return util.JSONToTable(file.Read( "gmc_webradios.txt", "DATA" ) or "[]")
end

gmc.webradio.LocalRadios = gmc.webradio.Load()

function gmc.webradio.NextRadioUrl(cur)
	local first
	local retnext = false
	for _, v in pairs(gmc.webradio.LocalRadios) do
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