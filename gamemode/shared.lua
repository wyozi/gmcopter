include( 'player_class/player_gmc.lua' )

local basefol = GM.FolderName.."/gamemode/gmcmodules/"

local function LoadModuleFolder(modulenm, cb)

	local full_folder = basefol .. modulenm .. "/"

	local files, folders = file.Find(full_folder .. "*", "LUA")

	-- Uncommenting lines after will enable recursivity. Unrequired at this point and might interrupt with item systems etc
	--for _, ifolder in pairs(folders) do
	--	LoadModuleFolder(modulenm .. "/" .. ifolder .. "/")
	--end

	for _, shfile in pairs(file.Find(full_folder .. "sh_*.lua", "LUA")) do
		if SERVER then AddCSLuaFile(full_folder .. shfile) end
		include(full_folder .. shfile)

		if cb then cb(shfile) end
	end

	if SERVER then
		for _, svfile in pairs(file.Find(full_folder .. "sv_*.lua", "LUA")) do
			include(full_folder .. svfile)

			if cb then cb(svfile) end
		end
	end

	for _, clfile in pairs(file.Find(full_folder .. "cl_*.lua", "LUA")) do
		if SERVER then AddCSLuaFile(full_folder .. clfile) end
		if CLIENT then include(full_folder .. clfile) end

		if cb then cb(clfile) end
	end

end

local function LoadModules()

	local _, folders = file.Find(basefol .. "*", "LUA")

	for _, ifolder in pairs(folders) do
		MsgC(Color(34, 167, 240), string.format("[module] %12s [", ifolder))
		LoadModuleFolder(ifolder, function(n)
			MsgC(Color(34, 167, 240), n .. ", ")
		end)
		MsgC(Color(34, 167, 240), "]")
		MsgN("")
	end

end

DeriveGamemode("sandbox")

gmc = gmc or {}
gmc.DEBUG = true

LoadModules()