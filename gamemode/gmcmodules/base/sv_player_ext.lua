local meta = FindMetaTable("Player")

function meta:EnterHelicopter(helicopter, seat)
	if self.VehicleLeft and self.VehicleLeft > CurTime() - 0.5 then
		return false
	end
	self:EnterVehicle(seat)
	self.InHeli = {heli = helicopter, seat = seat}
	return true
end

function meta:LeaveHelicopter()
	local helicopter = self:GetHelicopter()
	if not helicopter then return end

	local myseat = helicopter:GetSeatOf(self)

	self:ExitVehicle()
	self.InHeli = nil
	self.VehicleLeft = CurTime()

	if myseat then
		self:SetPos(helicopter:LocalToWorld(myseat.Exit))
		self:SetEyeAngles((helicopter:LocalToWorld(myseat.Pos - Vector(0,0,40)) - self:GetPos()):Angle())
	else
		ErrorNoHalt("Couldn't find ply chair")
	end
	self:SetVelocity(helicopter:GetPhysicsObject():GetVelocity() * 1.2)

end

function meta:GetHelicopter()
	return self.InHeli and self.InHeli.heli or nil
end

concommand.Add("+gmc_incalt", function(ply, cmd, args)
	ply.IncAltDown = true
end)

concommand.Add("-gmc_incalt", function(ply, cmd, args)
	ply.IncAltDown = false
end)

concommand.Add("+gmc_decalt", function(ply, cmd, args)
	ply.DecAltDown = true
end)

concommand.Add("-gmc_decalt", function(ply, cmd, args)
	ply.DecAltDown = false
end)
