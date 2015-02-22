gmc.missions = {}

function gmc.missions.Create(mtype, data)
	local meta = {
		-- This allows autorefreshing missiontypes
		-- TODO: only do it via function if DEBUG is enabled
		__index = function(t, key)
			return gmc.mtypes.Types[key]
		end
	}
	return setmetatable(data, meta)
end