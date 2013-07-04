local meta = FindMetaTable("Entity")

function meta:EnterHelicopter(helicopter, seat)
	if not helicopter:IsSeatFree(seat) then
		return false
	end
	if self:IsPlayer() then
		if self.VehicleLeft and self.VehicleLeft > CurTime() - 0.5 then
			return false
		end
		self:EnterVehicle(seat)
		self:SetHelicopter(helicopter)
	else
		seat.SittingEnt = self
		self.InHeli = helicopter 
	end
	return true
end

function meta:LeaveHelicopter()
	

	if self:IsPlayer() then
		local helicopter = self:GetHelicopter()
		if not helicopter then return end

		local myseat = helicopter:GetSeatOf(self)
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
	else

		local helicopter = self.InHeli
		if not helicopter then return end

		self.InHeli = nil

		local myseat = helicopter:GetSeatEntOf(self)
		if not myseat then return end

		myseat.SittingEnt = nil

	end

end