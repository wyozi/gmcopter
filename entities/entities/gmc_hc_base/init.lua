AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SvInit()
	local hull = self.Hull

	self.InputVelocityTrail = Vector(0, 0, 0)
	self.InputAngleVelocityTrail = Vector(0, 0, 0)
	self.InputAngleTrail = Angle(0, 0, 0)
	self.RotorAngVel = 0

	-- SeatEnts are ents that fulfill IsValid if there's someone sitting at that seat.
	-- SeatEnt can be one of following two things:
	-- 	* a prop_vehicle_prisoner_pod if there's a Player sitting there
	--  * a gmc_npc_base if there's a NPC sitting there
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

		trotor:SetSolid(SOLID_BBOX)
		trotor:SetCollisionBounds(Vector(-300, -300, -20), Vector(300, 300, 20))

		trotor:Spawn()

		local phys = trotor:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableGravity(false)
			phys:SetMass(5)
			phys:EnableDrag(false)
			phys:Wake()

			self.TopRotorPhys = phys
		end

		local cst = constraint.Axis(self, trotor, 0, 0, self.TopRotor.Pos, Vector(0, 0, 1), self.TopRotorForceLimit, 0, 0, 0)
		if not cst then
			MsgN("Constraint waswnt credted")
		end
		self.TopRotorHinge = cst

		--[[trotor:AddCallback("PhysicsCollide", function()
			MsgN("TRotor colliding ", CurTime())

			trotor:SetParent(nil)
			trotor:GetPhysicsObject():EnableGravity(true)
			cst:Remove()
		end)]]

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

function ENT:Think()
	local driver = self:GetDriver()

	-- Handle engine start logic
	if not self:IsEngineRunning() then
		local ang = self:GetAngles()
		local RequiredAngle = ang:IsPitchWithin(-25, 45) and ang:IsRollWithin(-15, 15) -- Are our angles good for liftoff. TODO warn player if not?
		local CanLiftOff = (IsValid(driver) and driver.IncAltDown and RequiredAngle)

		if not self.MSounds.Start:IsPlaying() and CanLiftOff then
			self.MSounds.Start:Play()
		elseif not IsValid(driver) or not driver.IncAltDown then -- Shouldn't get sound of rotors accelerating if we've stopped
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

	self:SetRotorFrac(gmc.math.Approach(self:GetRotorFrac(), self:GetEngineStartFrac(), 0.03))

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
		local mvm = self:GetRotorFrac() * self.RotorSpinSpeed * FrameTime()

		self.LastRotorAng = ((self.LastRotorAng or 0) + math.Clamp(mvm/2, 0, 360)) % 360
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
		hovervel:AddZ(math.sin(CurTime() * 1.5) * 35) -- Simulate some movement, which makes stationary hovering more realistic

		--if self:RotorSpeed() < 1000 then -- If rotors arent moving, dont stay in air. TODO make something more sophisticated.  Doesnt work due to custom angle system
			--hovervel = Vector(0, 0, 0)
			--gmc.debug.Msg("Fallin down due to slow rotorspeed")


		local InputHVelocity = 0
		local InputVVelocity = 0

		local InputAngleVelocity = Vector(0, 0, 0)
		local InputAngle = Angle(0, 0, 0)

		if IsValid(driver) then
			if driver.IncAltDown then
				InputVVelocity = 400
			elseif driver.DecAltDown then
				InputVVelocity = -800
			end

			if driver:KeyDown(IN_FORWARD) then
				InputHVelocity = 2000
				--InputVelocity:Add(yawangles:Forward() * 2000)
				InputAngle.p = 3
			elseif driver:KeyDown(IN_BACK) then
				InputHVelocity = -1200
				--InputVelocity:Add(-yawangles:Forward() * 1200)
				InputAngle.p = -3
			end

			-- On low velocities we shouldn't have much roll or the helicopter
			-- starts looking like it's defying laws of physics
			local roll_mul = (0.2 + 0.8*math.Clamp(horizontal_vel / 1500, 0, 1))

			if driver:KeyDown(IN_MOVELEFT) then
				InputAngleVelocity:AddZ(60)
				--InputAngle.r = -10 * roll_mul
			elseif driver:KeyDown(IN_MOVERIGHT) then
				InputAngleVelocity:AddZ(-60)
				--InputAngle.r = 10 * roll_mul
			end
		else -- No driver
			InputVVelocity = -1000
		end

		--InputVelocity:ClampX(-4000, 4000)
		--InputVelocity:ClampY(-4000, 4000)
		--InputVelocity:ClampZ(-1000, 1000)

		do -- Velocity
			local CurVel = self.Phys:GetVelocity()

			local h_src = self.InputVelocityTrail
			local h_srch = Vector(h_src.x, h_src.y, 0)
			local h_targ = InputHVelocity * yawangles:Forward()

			local h_srclen = h_srch:Length()
			local h_targlen = h_targ:Length()

			local h_srcang = math.atan2(h_src.y, h_src.x)
			local h_targang = h_targlen > 0 and math.atan2(h_targ.y, h_targ.x) or h_srcang

			--[[
			local h_interpang = gmc.math.ApproachOverflow(h_srcang, h_targang, FrameTime(), -math.pi, math.pi)
			local h_interplen = gmc.math.Approach(h_srclen, h_targlen, FrameTime() * 230)]]

			local speed = h_srclen
			local angdiff = (h_srclen >= 1 and h_targlen >= 1) and math.abs(math.AngleDifference(math.deg(h_srcang), math.deg(h_targang))) or 0
			local str = angdiff > 90 and 1 or math.Clamp(angdiff / 60 + speed / 2000, 0.2, 10)

			self.InputVelocityTrail.x = gmc.math.Approach(h_src.x, h_targ.x, 10 * str) --math.cos(h_interpang) * h_interplen
			self.InputVelocityTrail.y = gmc.math.Approach(h_src.y, h_targ.y, 10 * str) --math.sin(h_interpang) * h_interplen

			self.InputVelocityTrail.z = gmc.math.Approach(self.InputVelocityTrail.z, InputVVelocity, 5 + speed / 1500)

			local vel = (hovervel + self.InputVelocityTrail) * 60 * FrameTime()
			self.Phys:SetVelocity(vel)

			-- TODO move somewhere else
			-- This makes roll be based on speed and angdiff instead of user input
			InputAngle.r = speed < 500 and 0 or ((speed-500) / 1000 * math.AngleDifference(math.deg(h_srcang), math.deg(h_targang)) / 2)
		end

		do -- AngleVelocity
			local CurAng = self.Phys:GetAngleVelocity()
			local TargetAng = gmc.math.ApproachVectorMod(self.InputAngleVelocityTrail, InputAngleVelocity, 100 * FrameTime())

			local SetAngVel = gmc.math.VectorDiff(CurAng, TargetAng) > 0.1 and (TargetAng - CurAng) or vector_origin

			gmc.utils.SetAngleVelocity(self.Phys, SetAngVel)
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
			self.InputAngleVel.p = math.Clamp(gmc.math.Approach(self.InputAngleVel.p, PitchDiff, 1.5 * FrameTime()), -1, 1)
			local RollDiff = InputAngle.r - CurAng.r
			self.InputAngleVel.r = math.Clamp(gmc.math.Approach(self.InputAngleVel.r, RollDiff, 1.5 * FrameTime()), -1, 1)

			self.InputAngleTrail.p = self.InputAngleTrail.p + self.InputAngleVel.p * 0.1
			self.InputAngleTrail.r = self.InputAngleTrail.r + self.InputAngleVel.r * 0.2

			local SetAng = gmc.math.AngleDiff(CurAng, self.InputAngleTrail) > 0.1 and self.InputAngleTrail or nil

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
	if cdata.DeltaTime < 0.2 then return end

	if cdata.HitEntity:GetClass() == "worldspawn" then
		if self:IsEngineRunning() and self.LastEngineStarted < CurTime() - 2 then
			local ang = self:GetAngles()

			-- Make sure that the landing angle is somewhat sensible
			local angle_sanity = ang:IsPitchWithin(-45, 45) and ang:IsRollWithin(-45, 45)

			gmc.debug.Msg("Colliding with speed ", cdata.Speed, angle_sanity)
			if cdata.Speed < 150 and angle_sanity then
				self:StopEngine()
				phys:SetVelocity(Vector(0, 0, 0))
			else

				--local hitpos = self:WorldToLocal(self:NearestPoint(cdata.HitPos + cdata.HitNormal*1000))
				self:DamageHeli(cdata.Speed, self:WorldToLocal(cdata.HitPos))

				-- Calculate bounce back
				local TargetVelocity = cdata.OurOldVelocity * -0.5

				self.InputVelocityTrail = TargetVelocity
				phys:SetVelocity(TargetVelocity)

				-- TODO this allows damping vertical falling by crashing into a building wall
			end
		end
	end
end

function ENT:RotorSpeed()
	return self.TopRotorPhys:GetAngleVelocity():Length()
end

function ENT:Use(act, cal)
	local s, e = self:EnterHelicopter(act)
	if s == false then
		act:ChatPrint(e)
	end
end

function ENT:PlyEnterHelicopter(ply, seatidx)
	local idx = seatidx or self:GetFreeSeatIdx(false)
	if not idx or not self:IsSeatIdxFree(idx) then
		return false, "no free seat available"
	end

	local seat_data = self:SeatIdxToSeatData(idx)

	local chair = ents.Create("prop_vehicle_prisoner_pod")
	chair:SetModel("models/nova/airboat_seat.mdl")
	chair:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
	--chair:SetKeyValue("limitview", "0") -- Allow looking all around. We override this in CalcHeliView anyway
	chair:SetPos(self:LocalToWorld(seat_data.Pos))
	chair:SetAngles(self:LocalToWorldAngles(seat_data.Ang))
	chair:Spawn()
	chair:Activate()

	chair:SetNoDraw(true)
	chair:SetNotSolid(true)
	chair:SetParent(self)

	self.SeatEnts[idx] = chair

	ply:EnterVehicle(chair)
	ply:SetHelicopter(self)
end

function ENT:NPCEnterHelicopter(npc, seatidx)
	local idx = seatidx or self:GetFreeSeatIdx(true)
	if not idx or not self:IsSeatIdxFree(idx) then
		return false, "no free seat available"
	end

	local seat_data = self:SeatIdxToSeatData(idx)

	npc:SetSequence("silo_sit")
	npc:SetMoveType(MOVETYPE_NONE)
	npc:SetPos(self:LocalToWorld(seat_data.Pos) + Vector(13, -3, -14))

	-- hue
	local wang = self:LocalToWorldAngles(seat_data.Ang)
	wang:RotateAroundAxis(wang:Up(), 90)

	npc:SetAngles(wang)

	npc:SetLocalAngles(Angle(-15, 0, 0))

	npc:SetParent(self)
	npc:SetHelicopter(self)

	self.SeatEnts[idx] = npc
end

function ENT:EnterHelicopter(ent, seatidx)
	if ent:IsPlayer() then
		return self:PlyEnterHelicopter(ent, seatidx)
	elseif ent.IsGMCNPC then
		return self:NPCEnterHelicopter(ent, seatidx)
	end

	ErrorNoHalt("Trying to EnterHelicopter an unknown entity " .. tostring(ent))
end

function ENT:PlyLeaveHelicopter(ply)
	local idx = self:GetSeatIdxOf(ply)
	if not idx then
		return false, "entity was not in this helicopter"
	end

	local seat_ent = self:SeatIdxToEnt(idx)

	local seat_pos = seat_ent:GetPos()
	local exit_pos = self:GetPos() - self:GetRight() * 150

	ply:ExitVehicle()
	ply:SetHelicopter(NULL)
	ply.HelicopterLeft = CurTime()

	ply:SetPos(exit_pos)
	ply:SetEyeAngles((seat_pos - exit_pos):Angle())

	seat_ent:Remove()

	ply:SetVelocity(self:GetPhysicsObject():GetVelocity() * 1.2)
end

function ENT:NPCLeaveHelicopter(npc)
	local idx = self:GetSeatIdxOf(npc)
	if not idx then
		return false, "entity was not in this helicopter"
	end

	local seat_ent = self:SeatIdxToEnt(idx)

	npc:SetParent(NULL)
	npc:SetMoveType(MOVETYPE_CUSTOM)
	npc:SetHelicopter(nil)

	npc:SetPos(self:GetPos() + self:GetRight() * 150)
	npc:SetLocalAngles(Angle(0, 0, 0))

	npc:StartActivity(ACT_IDLE)

	npc:SetVelocity(self:GetPhysicsObject():GetVelocity() * 1.2)

	self.SeatEnts[idx] = nil
end

function ENT:LeaveHelicopter(ent)
	if ent:IsPlayer() then
		return self:PlyLeaveHelicopter(ent)
	elseif ent.IsGMCNPC then
		return self:NPCLeaveHelicopter(ent)
	end

	ErrorNoHalt("Trying to LeaveHelicopter an unknown entity " .. tostring(ent))
end

function ENT:GetSeatIdxOf(ent)
	for k,v in pairs(self.SeatEnts) do
		if self:GetPassenger(k) == ent then
			return k
		end
	end
end

function ENT:IsSeatIdxFree(idx)
	return not IsValid(self:GetPassenger(idx))
end

function ENT:GetFreeSeatIdx(skipdriver)
	for i=1, #self.Seats do
		if i == 1 and skipdriver then
			continue
		end
		if self:IsSeatIdxFree(i) then
			return i
		end
	end
end

function ENT:GetDriver()
	return self:GetPassenger(1)
end

function ENT:GetPassenger(idx)
	local seatent = self:SeatIdxToEnt(idx)
	if not IsValid(seatent) then return nil end

	if seatent:IsVehicle() then return seatent:GetDriver() end

	return seatent
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
