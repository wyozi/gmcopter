hook.Add("CanExitVehicle", "GMCExitVehicle", function(vehicle, ply)
	if not IsValid(ply:GetHelicopter()) then
		return true
	end

	ply:GetHelicopter():LeaveHelicopter(ply)
	
	return false
end)