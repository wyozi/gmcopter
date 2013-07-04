gmcdebug = {}
gmcdebug.DisableDebug = false

function gmcdebug.GetTracebackSource(traceback)
	local ll = traceback:Split("\t")
	--PrintTable(ll)
	ll = ll[#ll]
	ll = ll:Split(":")
	ll = ll[1] .. ":" .. ll[2]
	return ll
end

function gmcdebug.ToString(obj)
	if type(obj) == "table" then
		return gmcdebug.TableToString(obj)
	end
	return tostring(obj)
end

function gmcdebug.TableToString(tbl)
	local str = "{" .. tostring(#tbl) ..":"
	if table.IsSequential(tbl) then
		for k,v in ipairs(tbl) do
			str = str .. gmcdebug.ToString(k) .. "=" .. gmcdebug.ToString(v) .. ", "
		end
	else
		for k,v in pairs(tbl) do
			str = str .. gmcdebug.ToString(k) .. "=" .. gmcdebug.ToString(v) .. ", "
		end
	end
	str = str .. "}"
	return str
end

function gmcdebug.Msg(...)
	if gmcdebug.DisableDebug then return end
	local t = {...}
	local str = "[DEBUG] " .. gmcdebug.GetTracebackSource(debug.traceback()) .. ": "
	local rawstr = ""
	for i=1,#t do
		rawstr = rawstr .. gmcdebug.ToString(t[i]) .. "\t"
	end
	local fstr = str .. rawstr
	MsgN(fstr)
	return fstr, rawstr
end

function gmcdebug.CMsg(...)
	local _, msg = gmcdebug.Msg(...)
	for _,ply in pairs(player.GetAll()) do
		ply:ChatPrint(msg)
	end
end