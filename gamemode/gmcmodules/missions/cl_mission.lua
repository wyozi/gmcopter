gmc.mission = gmc.mission or {}
gmc.mission.Markers = gmc.mission.Markers or {}

net.Receive("GMCMissionMarker", function()
	local id = net.ReadString()
	local type = net.ReadString()
	local marker_id = net.ReadString()
	local pos = net.ReadVector()

	gmc.mission.Markers[id .. marker_id] = {
		time = CurTime(),
		type = type,
		pos = pos
	}
end)

net.Receive("GMCMissionUpdate", function()

end)