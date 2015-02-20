AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SvInit()
	local hull = self.Hull

	self.InputVelocityTrail = Vector(0, 0, 0)
	self.InputAngleVelocityTrail = Vector(0, 0, 0)
	self.InputAngleTrail = Angle(0, 0, 0)
	self.RotorAngVel = 0

	self.SeatEnts = {}
	self.Attachments = {}

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

function ENT:HasBeenOn()
	return self.LastEngineStarted ~= nil
end

function ENT:AddRotors()

	do
		local trotor = ents.Create("prop_physics")
		self.TopRotorEnt = trotor

		trotor:SetModel(self.TopRotor.Model)
		trotor:SetPos(self:LocalToWorld(self.TopRotor.Pos))
		trotor:SetLocalAngles(self:LocalToWorldAngles(self.TopRotor.Angles or Angle(0, 0, 0)))
		trotor:SetOwner(self.Owner)
		trotor:SetParent(self)
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

		local cst = constraint.Axis(self, trotor, 0, 0, self.TopRotor.Pos, Vector(0, 0, 1), self.TopRotorForceLimit,0,0,1)
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
		brotor:SetLocalAngles(self:LocalToWorldAngles(self.BackRotor.Angles or Angle(0, 0, 0)))
		brotor:SetOwner(self.Owner)
		brotor:SetParent(self)
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
		ent:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
		ent:SetKeyValue("limitview", "0") -- Allow looking all around. We override this in CalcHeliView anyway
		ent:SetPos(self:LocalToWorld(seat.Pos))
		ent:Spawn()
		ent:Activate()

		local ang = self:GetAngles()
		if seat.Angles then
			local a = self:GetAngles()
			a.y = a.y-90
			a:RotateAroundAxis(Vector(0, 0, 1), seat.Angles.y)
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

function ENT:Think()
	local driver = self:GetDriver()

	-- Handle engine start logic
	if not self:IsEngineRunning() then
		local ang = self:GetAngles()
		local RequiredAngle = ang:IsPitchWithin(-15, 30) and ang:IsRollWithin(-15, 15) -- Are our angles good for liftoff. TODO warn player if not?
		local CanLiftOff = (IsValid(driver) and driver.IncAltDown and RequiredAngle)

		if not self.MSounds.Start:IsPlaying() and CanLiftOff then
			self.MSounds.Start:Play()
		elseif not driver.IncAltDown then -- Shouldn't get sound of rotors accelerating if we've stopped
			self.MSounds.Start:Stop()
		end

		if CanLiftOff then
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

	self:SetRotorFrac(gmcmath.Approach(self:GetRotorFrac(), self:GetEngineStartFrac(), 0.03))

	-- Make sure if that if engine or rotors are on PhysicsUpdate gets called
	if self.Phys:IsAsleep() and (self:GetEngineStartLevel() > 0 or self:GetRotorFrac() > 0) then
		self.Phys:Wake()
	end

	if self:WaterLevel() > 0 then
		self:DamageHeli(100)
		if self:IsEngineRunning() then
			self:StopEngine()
		end
	end

	self:NextThink(CurTime() + 0.1)
	return true
end

function ENT:PhysicsUpdate()
	-- Handle spinning the rotors
	do
		local mvm = self:GetRotorFrac() * self.RotorSpinSpeed

		self.LastRotorAng = ((self.LastRotorAng or 0) + math.Clamp(mvm/100, 0, 360)) % 360
		self.TopRotorEnt:SetLocalAngles(Angle(0, self.LastRotorAng, 0))
		self.BackRotorEnt:SetLocalAngles(Angle(self.LastRotorAng, 0, 0))
	end


	if self:IsEngineRunning() then

		local driver = self:GetDriver()
		local angles = self:GetAngles()
		local yawangles = angles:OnlyYaw()

		local horizontal_vel = self:GetVelocity()
		horizontal_vel.z = 0 -- rip
		horizontal_vel = horizontal_vel:Length()

		local hovervel = Vector(0, 0, 9)
		hovervel:AddZ(math.sin(CurTime()) * 10) -- Simulate some movement, which makes stationary hovering more realistic

		--if self:RotorSpeed() < 1000 then -- If rotors arent moving, dont stay in air. TODO make something more sophisticated.  Doesnt work due to custom angle system
			--hovervel = Vector(0, 0, 0)
			--gmcdebug.Msg("Fallin down due to slow rotorspeed")


		local InputVelocity = Vector(0, 0, 0)
		local InputAngleVelocity = Vector(0, 0, 0)
		local InputAngle = Angle(0, 0, 0)

		if IsValid(driver) then
			if driver.IncAltDown then
				InputVelocity:AddZ(400 * self:GetUp().z)
			elseif driver.DecAltDown then
				InputVelocity:AddZ(-800 * self:GetUp().z)
			end

			if driver:KeyDown(IN_FORWARD) then
				InputVelocity:Add(yawangles:Forward() * 800)
				InputAngle.p = 25
			elseif driver:KeyDown(IN_BACK) then
				InputVelocity:Add(-yawangles:Forward() * 800)
				InputAngle.p = -25
			end

			-- On low velocities we shouldn't have much roll or the helicopter
			-- starts looking like it's defying laws of physics
			local roll_mul = (0.3 + 0.7*math.Clamp(horizontal_vel / 800, 0, 1))

			if driver:KeyDown(IN_MOVELEFT) then
				InputAngleVelocity:AddZ(60)
				InputAngle.r = -25 * roll_mul
			elseif driver:KeyDown(IN_MOVERIGHT) then
				InputAngleVelocity:AddZ(-60)
				InputAngle.r = 25 * roll_mul
			end
		else -- No driver
			InputVelocity:AddZ(-1000)
		end

		InputVelocity:ClampX(-4000, 4000)
		InputVelocity:ClampY(-4000, 4000)
		InputVelocity:ClampZ(-1000, 1000)

		do -- Velocity
			local CurVel = self.Phys:GetVelocity()
			local TargetVel = gmcmath.ApproachVectorMod(self.InputVelocityTrail, InputVelocity, 3.5)

			local vel = (hovervel + TargetVel) * 60 * FrameTime()
			self.Phys:SetVelocity(vel)

			--print(TargetVel)
		end

		do -- AngleVelocity
			local CurAng = self.Phys:GetAngleVelocity()
			local TargetAng = gmcmath.ApproachVectorMod(self.InputAngleVelocityTrail, InputAngleVelocity, 0.5)

			local SetAngVel = gmcmath.VectorDiff(CurAng, TargetAng) > 0.1 and (TargetAng - CurAng) or vector_origin

			gmcutils.SetAngleVelocity(self.Phys, SetAngVel)
		end

		do -- Angle
			local CurAng = self:GetAngles()

			local InputTargetDiff = self.InputAngleTrail - InputAngle

			-- If we're above ground dont pitch or roll to avoid glitching with ground due to forcing angle
			if self:IsJustAboveGround() then
				InputAngle.p = 0 -- We could set targetangle here but faking InputAngle makes transition smoother because TargetAngle is directly related to the SetAngles
				InputAngle.r = 0
			end

			local frac = 0.15 + 0.15 * math.sin(math.abs(self.InputAngleTrail.p - InputAngle.p) / 30 * math.pi)
			self.InputAngleVel = self.InputAngleVel or Angle(0, 0, 0)

			local PitchDiff = InputAngle.p - CurAng.p
			self.InputAngleVel.p = math.Clamp(gmcmath.Approach(self.InputAngleVel.p, PitchDiff, 3 * FrameTime()), -1, 1)
			local RollDiff = InputAngle.r - CurAng.r
			self.InputAngleVel.r = math.Clamp(gmcmath.Approach(self.InputAngleVel.r, RollDiff, 3 * FrameTime()), -1, 1)

			self.InputAngleTrail.p = self.InputAngleTrail.p + self.InputAngleVel.p * 0.2
			self.InputAngleTrail.r = self.InputAngleTrail.r + self.InputAngleVel.r * 0.3

			local SetAng = gmcmath.AngleDiff(CurAng, self.InputAngleTrail) > 0.1 and self.InputAngleTrail or nil

			if SetAng then
				SetAng.y = CurAng.y -- Dont mess with yaw because its not directly controlled by player
				self:SetAngles(SetAng)
			end
		end

	end

end

function ENT:StopEngine()
	self:SetEngineStartLevel(self.MaxEngineStartLevel - 2)
	self.LastEngineStopped = CurTime()

	-- Reset trails.
	self.InputVelocityTrail = Vector(0, 0, 0)
	self.InputAngleVelocityTrail = Vector(0, 0, 0)
	self.InputAngleTrail = Angle(0, 0, 0)
end

function ENT:DamageHeli(dmg, localhitpos)

	self:SetVehHealth(math.max(self:GetVehHealth() - dmg, -1))

	if self:IsEngineRunning() then
		local HardHit = dmg > 50
		local Sound = table.Random(HardHit and self.HitSounds.Hard or self.HitSounds.Soft)
		sound.Play( Sound, localhitpos or self:GetPos() )

		if localhitpos then
			local vPoint = self:LocalToWorld(localhitpos)
			local effectdata = EffectData()
			effectdata:SetStart( vPoint )
			effectdata:SetOrigin( vPoint )
			effectdata:SetScale( 0.2 )
			util.Effect( "HelicopterMegaBomb", effectdata )
		 end
	end


	if self:GetVehHealth() < 0 then
		-- TODO destroy everything but check if we were dead first
	end
end

function ENT:PhysicsCollide(cdata, phys)
	if cdata.HitEntity:GetClass() == "worldspawn" then
		if self:IsEngineRunning() and self.LastEngineStarted < CurTime() - 2 then
			self.InputVelocity = Vector(0, 0, 0)

			local ang = self:GetAngles()
			local AreAnglesSane = ang:IsPitchWithin(-45, 45) and ang:IsRollWithin(-45, 45) -- we shouldnt accept all angles

			gmcdebug.Msg("Colliding with speed ", cdata.Speed, AreAnglesSane)
			if cdata.Speed < 100 and AreAnglesSane then
				self:StopEngine()
				phys:SetVelocity(Vector(0, 0, 0))
			else

				if cdata.DeltaTime > 0.2 then
					--local hitpos = self:WorldToLocal(self:NearestPoint(cdata.HitPos + cdata.HitNormal*1000))
					self:DamageHeli(cdata.Speed, self:WorldToLocal(cdata.HitPos))
				end

				-- Bounce back?
				// Bounce like a crazy bitch
				local LastSpeed = cdata.OurOldVelocity:Length()
				local NewVelocity = phys:GetVelocity()

				NewVelocity:Normalize()
				local TargetVelocity = NewVelocity * LastSpeed * 0.99

				phys:SetVelocity( TargetVelocity )

				-- TODO Fix
			end
		end
	end
end

function ENT:RotorSpeed()
	return self.TopRotorPhys:GetAngleVelocity():Length()
end

-- TODO make cleaner
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
			v = i
		end

	end

	if v then
		act:EnterHelicopter(self, v)
	end
end

function ENT:GetSeatOf(ent)
	for k,v in pairs(self.SeatEnts) do
		if self:GetPassenger(k) == ent then
			return k
		end
	end
end

function ENT:IsSeatFree(idx)
	return not IsValid(self:GetPassenger(idx))
end

function ENT:GetFreeSeat(skipdriver)
	for k,v in pairs(self.SeatEnts) do
		if k == 1 and skipdriver then
			continue
		end
		if self:IsSeatFree(v) then
			return k
		end
	end
end

function ENT:GetDriver()
	return self:GetPassenger(1)
end

function ENT:GetPassenger(idx)
	local seatent = self:SeatIdxToEnt(idx)
	if not IsValid(seatent) then return nil end
	return seatent:GetDriver()
end

function ENT:SeatIdxToEnt(idx)
	return self.SeatEnts[idx]
end

function ENT:SeatIdxToSeatData(idx)
	return self.Seats[idx]
end

function ENT:OnRemove()
	for _,snd in pairs(self.MSounds) do
		snd:Stop()
	end
end

function ENT:HeliAttach(att)
	table.insert(self.Attachments, att)
	att:SetHelicopter(self)
end
