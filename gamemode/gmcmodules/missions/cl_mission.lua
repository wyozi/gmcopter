gmc.mission = gmc.mission or {}
gmc.mission.Markers = gmc.mission.Markers or {}

net.Receive("GMCMissionMarker", function()
	local id = net.ReadString()
	local type = net.ReadString()
	local marker_id = net.ReadString()
	local pos = net.ReadVector()

	local markers = gmc.mission.Markers
	markers[id] = markers[id] or {}

	markers[id][marker_id] = {
		time = CurTime(),
		type = type,
		pos = pos
	}
end)

net.Receive("GMCMissionCleanup", function()
	local id = net.ReadString()

	gmc.mission.Markers[id] = nil
end)

net.Receive("GMCMissionUpdate", function()

end)