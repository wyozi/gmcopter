gmcmissions = {}

gmcmissions.Missions = {}

function gmcmissions.Add(name, data)
	gmcmissions.Missions[name] = data
	gmchooks.Call("GMCMissionAdded", name)
end