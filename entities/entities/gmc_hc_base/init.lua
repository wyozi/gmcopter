AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SvInit()
	local hull = self.Hull

	self.InputVelocityTrail = Vector(0, 0, 0)
	self.InputAngleVelocityTrail = Vector(0, 0, 0)
	self.InputAngleTrail = Angle(0, 0, 0)

	self.SeatEnts = {}

	self:SetModel(hull.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		self.Phys = phys
		phys:SetMass(hull.Weight)
		phys:Wake()

		--phys:EnableDrag(true) -- lel wut
	end

	self:SetEngineStartLevel(0)

	self:AddRotors()
	self:AddSeats()

end
function ENT:AddRotors()

	do
		local trotor = ents.Create("prop_physics")
		self.TopRotorEnt = trotor

		trotor:SetModel(self.TopRotor.Model)
		trotor:SetPos(self:LocalToWorld(self.TopRotor.Pos))
		trotor:SetAngles(self:LocalToWorldAngles(self.TopRotor.Angles or Angle(0, 0, 0)))
		trotor:SetOwner(self.Owner)
		self:SetNWEntity("trotor", trotor)

		trotor:Spawn()

		local phys = trotor:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableGravity(false)
			phys:SetMass(5)
			phys:EnableDrag(false)
			phys:Wake()

			self.TopRotorPhys = phys
		end

		local cst = constraint.Axis(self, trotor, 0, 0, self.TopRotor.Pos, Vector(0,0,1), self.TopRotorForceLimit,0,0,1)
		if not cst then
			MsgN("Constraint waswnt credted")
		end
		self.TopRotorHinge = cst

		self:DeleteOnRemove(trotor)
	end

	do
		local brotor = ents.Create("prop_physics")
		self.BackRotorEnt = brotor

		brotor:SetModel(self.BackRotor.Model)
		brotor:SetPos(self:LocalToWorld(self.BackRotor.Pos))
		brotor:SetAngles(self:LocalToWorldAngles(self.BackRotor.Angles or Angle(0, 0, 0)))
		brotor:SetOwner(self.Owner)
		self:SetNWEntity("brotor", brotor)

		brotor:Spawn()

		local phys = brotor:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableGravity(false)
			phys:SetMass(5)
			phys:EnableDrag(false)
			phys:Wake()

			self.BackRotorPhys = phys
		end

		local cst
		if self.BackRotor.TwinBladed then
			cst = constraint.Axis(self, brotor, 0, 0, self.BackRotor.Pos, Vector(0, 0, 1), self.BackRotorForceLimit, 0, 0, 1)
		else
			cst = constraint.Axis(self, brotor, 0, 0, self.BackRotor.Pos, Vector(0, 1, 0), self.BackRotorForceLimit, 0, 0, 1)
		end
		self.BackRotorHinge = cst

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

		self.SeatEnts[i] = ent

		self:DeleteOnRemove(ent)
	end
end

function ENT:GetDriver()
	local seatent = self.SeatEnts[1]
	if not IsValid(seatent) then return nil end
	return seatent:GetDriver()
end

function ENT:Think()
	local driver = self:GetDriver()
	if not self:IsEngineRunning() then
		if not self.MSounds.Start:IsPlaying() and (IsValid(driver) and driver.IncAltDown) then
			self.MSounds.Start:Play()
		elseif not driver.IncAltDown then -- Shouldn't get sound of rotors accelerating if we've stopped
			self.MSounds.Start:Stop()
		end

		if IsValid(driver) and driver.IncAltDown then
			self:SetEngineStartLevel(math.min(self:GetEngineStartLevel() + 1, self.MaxEngineStartLevel))
		elseif self:GetEngineStartLevel() > 0 then
			self:SetEngineStartLevel(math.max(self:GetEngineStartLevel() - 2, 0))
		end

		if self:IsEngineRunning() then
			self.LastEngineStarted = CurTime()
		end

	elseif self.MSounds.Start:IsPlaying() then
		self.MSounds.Start:Stop()
	end

	if self.Phys:IsAsleep() and self:GetEngineStartLevel() > 0 then
		self.Phys:Wake()
	end

	if self:IsEngineRunning() then
		if not self.MSounds.Engine:IsPlaying() then
			self.MSounds.Engine:Play()
		end
	elseif self.MSounds.Engine:IsPlaying() then
		if self:GetEngineStartFrac() > 0 then
			self.MSounds.Engine:ChangeVolume(self:GetEngineStartFrac(), 0)
		else
			self.MSounds.Engine:Stop()
		end
	end

	local RotorFrac = math.Clamp(self:RotorSpeed() / 5000, 0, 1)
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
	if self:IsEngineRunning() then
		gmcutils.SetAngleVelocity(self.TopRotorPhys, Vector(0, 0, self.RotorSpinSpeed))
		gmcutils.SetAngleVelocity(self.BackRotorPhys, Vector(0, self.RotorSpinSpeed, 0))
	elseif self:GetEngineStartFrac() > 0 or self:RotorSpeed() > 40 then
		gmcutils.SetAngleVelocity(self.TopRotorPhys, Vector(0, 0, self:GetEngineStartFrac() * self.RotorSpinSpeed))
		gmcutils.SetAngleVelocity(self.BackRotorPhys, Vector(0, self:GetEngineStartFrac() * self.RotorSpinSpeed, 0))
	end

	if self:IsEngineRunning() then

		local driver = self:GetDriver()
		local angles = self:GetAngles()
		local yawangles = angles:OnlyYaw()

		local hovervel = Vector(0, 0, 9)
		hovervel:AddZ(math.sin(CurTime()) * 20) -- Makes the helicopter "bounce" in air making hovering look a bit more realistic

		if self:RotorSpeed() < 1000 then -- If rotors arent moving, dont stay in air. TODO make something more sophisticated. 
			hovervel = Vector(0, 0, 0)
		end

		local InputVelocity = Vector(0, 0, 0)
		local InputAngleVelocity = Vector(0, 0, 0)
		local InputAngle = Angle(0, 0, 0)

		if IsValid(driver) then
			if driver.IncAltDown then
				InputVelocity:AddZ(400)
			elseif driver.DecAltDown then
				InputVelocity:AddZ(-400)
			end

			if driver:KeyDown(IN_FORWARD) then
				InputVelocity:Add(yawangles:Forward() * 800)
				InputAngle.p = 30
			elseif driver:KeyDown(IN_BACK) then
				InputVelocity:Add(-yawangles:Forward() * 800)
				InputAngle.p = -30
			end

			if driver:KeyDown(IN_MOVELEFT) then
				InputAngleVelocity:AddZ(60)
				InputAngle.r = -30
			elseif driver:KeyDown(IN_MOVERIGHT) then
				InputAngleVelocity:AddZ(-60)
				InputAngle.r = 30
			end
		end

		InputVelocity:ClampX(-4000, 4000)
		InputVelocity:ClampY(-4000, 4000)
		InputVelocity:ClampZ(-1000, 1000)

		do -- Velocity
			local CurVel = self.Phys:GetVelocity()
			local TargetVel = gmcmath.ApproachVectorMod(self.InputVelocityTrail, InputVelocity, 3.5)

			local AddVel = gmcmath.VectorDiff(CurVel, TargetVel) > 0.1 and (TargetVel - CurVel) or vector_origin

			local vel = hovervel + AddVel
			self.Phys:AddVelocity(vel)
		end

		do -- AngleVelocity
			local CurAng = self.Phys:GetAngleVelocity()
			local TargetAng = gmcmath.ApproachVectorMod(self.InputAngleVelocityTrail, InputAngleVelocity, 0.5)

			local SetAngVel = gmcmath.VectorDiff(CurAng, TargetAng) > 0.1 and (TargetAng - CurAng) or vector_origin

			gmcutils.SetAngleVelocity(self.Phys, SetAngVel)
		end

		do -- Angle
			local CurAng = self:GetAngles()
			local TargetAng = self.InputAngleTrail

			local InputTargetDiff = gmcmath.AngleDiff(InputAngle, TargetAng)

			if self:IsJustAboveGround() then -- If we're above ground dont pitch or roll to avoid glitching with ground due to forcing angle
				InputAngle.p = 0 -- We could set targetangle here but faking InputAngle makes transition smoother because TargetAngle is directly related to the SetAngles
				InputAngle.r = 0
			end 
			TargetAng = gmcmath.ApproachAngleMod(TargetAng, InputAngle, math.Clamp(InputTargetDiff / 100, 0.1, 1.5)) -- math.Clamp is here to do some smoothening

			local SetAng = gmcmath.AngleDiff(CurAng, TargetAng) > 0.1 and (TargetAng - CurAng) or nil

			if SetAng then
				SetAng.y = CurAng.y -- Dont mess with yaw because its not directly controlled by player
				self:SetAngles(SetAng)
			end
		end

	end

end

function ENT:PhysicsCollide(cdata, phys)
	if cdata.HitEntity:GetClass() == "worldspawn" then
		MsgN(cdata.HitNormal, "pc", util.PointContents(cdata.HitPos + cdata.HitNormal*400))
		if self:IsEngineRunning() and self.LastEngineStarted < CurTime() - 2 then
			self.InputVelocity = Vector(0, 0, 0)
			if cdata.Speed < 100 then -- TODO Test if we're upright
				self:SetEngineStartLevel(self.MaxEngineStartLevel - 2)
				phys:SetVelocity(Vector(0, 0, 0))
				MsgN("Set velocity to 0")
			else
				-- Bounce back?
				local LastSpeed = math.max( cdata.OurOldVelocity:Length(), cdata.Speed )
				local NewVelocity = phys:GetVelocity()
				NewVelocity:Normalize()

				LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

				local TargetVelocity = NewVelocity * LastSpeed * 0.2

				phys:SetVelocity( TargetVelocity )
				MsgN("Bounced from ground")
			end
		end
	end
end

function ENT:RotorSpeed()
	return self.TopRotorPhys:GetAngleVelocity():Length()
end

-- TODO make better
function ENT:Use(act, cal)
	local d,v = self.MaxEnterDistance, _
	for i=1,#self.Seats do
		local seat = self.Seats[i]
		local seatent = self.SeatEnts[i]
		if not IsValid(seatent) or IsValid(seatent:GetDriver()) then
			continue
		end

		local dist = seatent:GetPos():Distance(
						util.QuickTrace(act:GetShootPos(), act:GetAimVector() * self.MaxEnterDistance, act).HitPos)

		if dist < d then
			d = dist
			v = seatent
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
