hook.Add("CanExitVehicle", "GMCExitVehicle", function(vehicle, ply)
	if not ply.InHeli or not IsValid(ply.InHeli.heli) then
		return true
	end

	ply:LeaveHelicopter()

	return false
end)