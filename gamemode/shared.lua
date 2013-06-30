local basefol = GM.FolderName.."/gamemode/gmcmodules/"

local function LoadModuleFolder(modulenm)

	local full_folder = basefol .. modulenm .. "/"

	local files, folders = file.Find(full_folder .. "*", "LUA")

	-- Uncommenting lines after will enable recursivity. Unrequired at this point and might interrupt with item systems etc
	--for _, ifolder in pairs(folders) do
	--	LoadModuleFolder(modulenm .. "/" .. ifolder .. "/")
	--end

	for _, shfile in pairs(file.Find(full_folder .. "sh_*.lua", "LUA")) do
		if SERVER then AddCSLuaFile(full_folder .. shfile) end
		include(full_folder .. shfile)
	end

	if SERVER then
		for _, svfile in pairs(file.Find(full_folder .. "sv_*.lua", "LUA")) do
			include(full_folder .. svfile)
		end
	end

	for _, clfile in pairs(file.Find(full_folder .. "cl_*.lua", "LUA")) do
		if SERVER then AddCSLuaFile(full_folder .. clfile) end
		if CLIENT then include(full_folder .. clfile) end
	end

end

local function LoadModules()

	local _, folders = file.Find(basefol .. "*", "LUA")

	for _, ifolder in pairs(folders) do
		MsgN("Loading module folder " .. ifolder)
		LoadModuleFolder(ifolder)
	end

end

LoadModules()