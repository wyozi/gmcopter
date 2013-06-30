include("shared.lua")

function ENT:AddRotors()

	do
		local trotor = ents.Create("prop_physics")
		self.TopRotor.Ent = trotor

		trotor:SetModel(self.TopRotor.Model)
		trotor:SetPos(self:LocalToWorld(self.TopRotor.Pos))
		trotor:SetAngles(self:LocalToWorldAngles(self.TopRotor.Angles))
		trotor:SetOwner(self.Owner)

		trotor:Spawn()

		local phys = trotor:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableGravity(false)
			phys:SetMass(5)
			phys:EnableDrag(false)

			self.TopRotor.Phys = phys
		end

		if not constraint.Axis(self, trotor, 0, 0, self.TopRotor.Pos, Vector(0,0,1), 0,0,0,1) then
			MsgN("Constraint waswnt credted")
		end

		self:DeleteOnRemove(trotor)
	end

	do
		local brotor = ents.Create("prop_physics")
		self.BackRotor.Ent = brotor

		brotor:SetModel(self.BackRotor.Model)
		brotor:SetPos(self:LocalToWorld(self.BackRotor.Pos))
		brotor:SetAngles(self:LocalToWorldAngles(self.BackRotor.Angles))
		brotor:SetOwner(self.Owner)

		brotor:Spawn()

		local phys = brotor:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableGravity(false)
			phys:SetMass(5)
			phys:EnableDrag(false)

			self.BackRotor.Phys = phys
		end

		if self.BackRotor.TwinBladed then
			constraint.Axis(self, brotor, 0, 0, self.BackRotor.Pos, Vector(0, 0, 1), 0, 0, 0, 1)
		else
			constraint.Axis(self, brotor, 0, 0, self.BackRotor.Pos, Vector(0, 1, 0), 0, 0, 0, 1)
		end

		self:DeleteOnRemove(brotor)
	end

end

function ENT:AddSeats()
	for i=1,#self.Seats do
		local seat = self.Seats[i]

		local ent = ents.Create("prop_vehicle_prisoner_pod")
		ent:SetModel("models/nova/airboat_seat.mdl") 
		ent:SetPos(self:LocalToWorld(seat.Pos))
		ent:Spawn()
		ent:Activate()

		local ang = self:GetAngles()
		if seat.Angles then
			local a = self:GetAngles()
			a.y = a.y-90
			a:RotateAroundAxis(Vector(0,0,1), seat.Angles.y)
			ent:SetAngles(a)
		else
			ang:RotateAroundAxis(self:GetUp(), -90)
			ent:SetAngles(ang)
		end

		ent:SetNoDraw(true)
		ent:SetNotSolid(true)
		ent:SetParent(self)

		seat.Ent = ent

		self:DeleteOnRemove(ent)
	end
end

function ENT:GetDriver()
	local seatent = self.Seats[1].Ent
	if not IsValid(seatent) then return nil end
	return seatent:GetDriver()
end

function ENT:Think()
	local driver = self:GetDriver()
	if IsValid(driver) and not self:IsEngineRunning() then
		if not self.MSounds.Start:IsPlaying() then
			self.MSounds.Start:Play()
			--self.MSounds.Start:ChangeVolume(0, 0)
		elseif not driver:KeyDown(IN_FORWARD) then -- Shouldn't get sound of rotors accelerating if we've stopped
			self.MSounds.Start:Stop()
		end

		if driver:KeyDown(IN_FORWARD) then
			self:SetEngineStartLevel(self:GetEngineStartLevel() + 1)
			self.Brake = 0
		elseif self:GetEngineStartLevel() > 0 then
			self:SetEngineStartLevel(self:GetEngineStartLevel() - 1)
			self.Brake = 0.01
		end

		--self.MSounds.Start:ChangeVolume(self:GetEngineStartFrac(), 0)

		--MsgN(self:GetEngineStartLevel())
	elseif self.MSounds.Start:IsPlaying() then
		self.MSounds.Start:Stop()
	end

	if self:IsEngineRunning() then
		if not self.MSounds.Engine:IsPlaying() then
			self.MSounds.Engine:Play()
		end
		self.Brake = 0
	elseif self.MSounds.Engine:IsPlaying() then
		self.MSounds.Engine:Stop()
	end

	local RotorFrac = math.Clamp(self:RotorSpeed() / 5000, 0, 1)

	--MsgN(self:RotorSpeed(), "  lel  ", RotorFrac)
	if RotorFrac > 0.01 then
		if not self.MSounds.Blades:IsPlaying() then
			self.MSounds.Blades:Play()
		end
		self.MSounds.Blades:ChangeVolume(RotorFrac, 0)
	elseif self.MSounds.Blades:IsPlaying() then
		self.MSounds.Blades:Stop()
	end

	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:PhysicsUpdate()
	local oav = self.TopRotor.Phys:GetAngleVelocity() * self.Brake
	if self:IsEngineRunning() then
		self.TopRotor.Phys:AddAngleVelocity(Vector(0, 0, self.RotorSpinSpeed) - oav)
	elseif self:GetEngineStartFrac() > 0.1 then
		self.TopRotor.Phys:AddAngleVelocity(Vector(0, 0, self:GetEngineStartFrac() * self.RotorSpinSpeed) - oav)
	end

	if self:IsEngineRunning() then
		local vel = self:GetAngles():Up() * (self:RotorSpeed() / 750)
		vel = Vector(0, 0, vel.z)
		self.Phys:AddVelocity(vel)
	end

end

function ENT:RotorSpeed()
	return self.TopRotor.Phys:GetAngleVelocity():Length()
end

-- TODO make better
function ENT:Use(act, cal)
	local d,v = self.MaxEnterDistance, _
	for i=1,#self.Seats do
		local seat = self.Seats[i]
		if not IsValid(seat.Ent) then
			continue
		end

		local dist = seat.Ent:GetPos():Distance(
						util.QuickTrace(act:GetShootPos(), act:GetAimVector() * self.MaxEnterDistance, act).HitPos)

		if dist < d then
			d = dist
			v = seat.Ent
		end

	end

	if v then
		act:EnterHelicopter(self, v)
	end
end

function ENT:GetSeatOf(ply)
	local veh = ply:GetVehicle()
	for _,v in pairs(self.Seats) do
		if v.Ent == veh then
			return v
		end
	end
end

function ENT:OnRemove()
	for _,snd in pairs(self.MSounds) do
		snd:Stop()
	end
end