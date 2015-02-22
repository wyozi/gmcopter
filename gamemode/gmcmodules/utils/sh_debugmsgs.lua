gmc.debug = {}
gmc.debug.DisableDebug = false

function gmc.debug.GetTracebackSource(traceback)
	local ll = traceback:Split("\t")
	--PrintTable(ll)
	ll = ll[#ll]
	ll = ll:Split(":")
	ll = ll[1] .. ":" .. ll[2]
	return ll
end

function gmc.debug.ToString(obj)
	if type(obj) == "table" then
		return gmc.debug.TableToString(obj)
	end
	return tostring(obj)
end

function gmc.debug.TableToString(tbl)
	local str = "{" .. tostring(#tbl) ..":"
	if table.IsSequential(tbl) then
		for k,v in ipairs(tbl) do
			str = str .. gmc.debug.ToString(k) .. "=" .. gmc.debug.ToString(v) .. ", "
		end
	else
		for k,v in pairs(tbl) do
			str = str .. gmc.debug.ToString(k) .. "=" .. gmc.debug.ToString(v) .. ", "
		end
	end
	str = str .. "}"
	return str
end

function gmc.debug.Msg(...)
	if gmc.debug.DisableDebug then return end
	local t = {...}
	local str = "[DEBUG] " .. gmc.debug.GetTracebackSource(debug.traceback()) .. ": "
	local rawstr = ""
	for i=1,#t do
		rawstr = rawstr .. gmc.debug.ToString(t[i]) .. "\t"
	end
	local fstr = str .. rawstr
	MsgN(fstr)
	return fstr, rawstr
end

function gmc.debug.CMsg(...)
	local _, msg = gmc.debug.Msg(...)
	for _,ply in pairs(player.GetAll()) do
		ply:ChatPrint(msg)
	end
end