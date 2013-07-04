local meta = FindMetaTable("Player")

function meta:EnterHelicopter(helicopter, seat)
	if not helicopter:IsSeatFree(seat) then
		return false
	end
	if self.VehicleLeft and self.VehicleLeft > CurTime() - 0.5 then
		return false
	end
	self:EnterVehicle(helicopter:SeatIdxToEnt(seat))
	self:SetHelicopter(helicopter)
	return true
end

function meta:LeaveHelicopter()
	local helicopter = self:GetHelicopter()
	if not helicopter then return end

	local myseat = helicopter:GetSeatOf(self)
	if myseat then myseat = helicopter:SeatIdxToSeatData(myseat) end
	
	self:ExitVehicle()
	self:SetHelicopter(NULL)
	self.VehicleLeft = CurTime()

	if myseat then
		self:SetPos(helicopter:LocalToWorld(myseat.Exit))
		self:SetEyeAngles((helicopter:LocalToWorld(myseat.Pos - Vector(0,0,40)) - self:GetPos()):Angle())
	else
		ErrorNoHalt("Couldn't find ply seat")
	end
	self:SetVelocity(helicopter:GetPhysicsObject():GetVelocity() * 1.2)
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
