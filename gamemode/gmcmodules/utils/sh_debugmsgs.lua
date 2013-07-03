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

function gmcdebug.Msg(...)
	if gmcdebug.DisableDebug then return end
	local t = {...}
	local str = "[DEBUG] " .. gmcdebug.GetTracebackSource(debug.traceback()) .. ": "
	local rawstr = ""
	for i=1,#t do
		rawstr = rawstr .. tostring(t[i]) .. "\t"
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