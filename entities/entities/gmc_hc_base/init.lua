AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SvInit()
	local hull = self.Hull

	self.Brake = 0
	self.InputVelocity = Vector(0, 0, 0)
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
		trotor:SetAngles(self:LocalToWorldAngles(self.TopRotor.Angles))
		trotor:SetOwner(self.Owner)

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
		brotor:SetAngles(self:LocalToWorldAngles(self.BackRotor.Angles))
		brotor:SetOwner(self.Owner)

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
	if IsValid(driver) and not self:IsEngineRunning() then
		if not self.MSounds.Start:IsPlaying() and driver.IncAltDown then
			self.MSounds.Start:Play()
		elseif not driver.IncAltDown then -- Shouldn't get sound of rotors accelerating if we've stopped
			self.MSounds.Start:Stop()
		end

		if driver.IncAltDown then
			self:SetEngineStartLevel(math.min(self:GetEngineStartLevel() + 1, self.MaxEngineStartLevel))
			self.Brake = 0
		elseif self:GetEngineStartLevel() > 0 then
			self:SetEngineStartLevel(math.max(self:GetEngineStartLevel() - 2, 0))
			self.Brake = 0.01
		end

		if self:IsEngineRunning() then
			self.LastEngineStarted = CurTime()
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
		if self:GetEngineStartFrac() > 0 then
			self.MSounds.Engine:ChangeVolume(self:GetEngineStartFrac(), 0)
		else
			self.MSounds.Engine:Stop()
		end
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

local function SetAngleVelocity(phys, angle)
	phys:AddAngleVelocity( -1 * phys:GetAngleVelocity( ) + angle)
end
local function OverrideComponents(vec, x, y, z)
	return Vector(x or vec.x, y or vec.y, z or vec.z)
end

function ENT:PhysicsUpdate()
	if self:IsEngineRunning() then
		SetAngleVelocity(self.TopRotorPhys, Vector(0, 0, self.RotorSpinSpeed))
		SetAngleVelocity(self.BackRotorPhys, Vector(0, self.RotorSpinSpeed, 0))
	elseif self:GetEngineStartFrac() > 0 or self:RotorSpeed() > 40 then
		SetAngleVelocity(self.TopRotorPhys, Vector(0, 0, self:GetEngineStartFrac() * self.RotorSpinSpeed))
		SetAngleVelocity(self.BackRotorPhys, Vector(0, self:GetEngineStartFrac() * self.RotorSpinSpeed, 0))
	end
	--MsgN(self:RotorSpeed())

	if self:IsEngineRunning() then

		local driver = self:GetDriver()

		local vel = Vector(0, 0, 9)

		if IsValid(driver) and driver.IncAltDown then
			self.InputVelocity.z = self.InputVelocity.z + 0.5
		elseif IsValid(driver) and driver.DecAltDown then
			self.InputVelocity.z = self.InputVelocity.z - 1.5
		elseif self.InputVelocity.z > -1 then
			self.InputVelocity.z = math.max(self.InputVelocity.z - 1, -1)
		end

		if self:RotorSpeed() < 1000 then -- If rotors arent moving, dont stay in air. TODO make something more sophisticated. 
			vel = Vector(0, 0, 0)
		end

		if IsValid(driver) then
			local angles = self:GetAngles()
			local anglevel = self.Phys:GetAngleVelocity()

			if driver:KeyDown(IN_FORWARD) then
				if angles.p < 25 then
					self.Phys:AddAngleVelocity(Vector(0, 0.1, 0))
				end
				--self.InputVelocity = self.InputVelocity + OverrideComponents(angles:Forward() * 3.5, _, _, 0)
			elseif driver:KeyDown(IN_BACK) then
				if angles.p > -17 then
					self.Phys:AddAngleVelocity(Vector(0, -0.1, 0))
				end
				--vel.z = vel.z + 10
				--self.InputVelocity.z = self.InputVelocity.z - 1
				--self.InputVelocity = self.InputVelocity - OverrideComponents(angles:Forward() * 3.5, _, _, 0)
			end
			if angles.p > 5 then
				self.InputVelocity.z = self.InputVelocity.z + 1.5
			end
			
			if angles.p > 35 or (angles.p > 5 and not driver:KeyDown(IN_FORWARD)) or angles.p < -25 or (angles.p < -5 and not driver:KeyDown(IN_BACK)) then
				self.Phys:AddAngleVelocity(Vector(0, angles.p > 0 and -0.1 or 0.1, 0))
			end


			if driver:KeyDown(IN_MOVERIGHT) then
				self:SetAngles(Angle(angles.p, angles.y, math.ApproachAngle(angles.r, 30, 0.3)))
				self.Phys:AddAngleVelocity(Vector(0, 0, -0.2))
			elseif driver:KeyDown(IN_MOVELEFT) then
				self:SetAngles(Angle(angles.p, angles.y, math.ApproachAngle(angles.r, -30, 0.3)))
				self.Phys:AddAngleVelocity(Vector(0, 0, 0.2))
			else
				local adiff = math.abs(angles.r) / 10
				if math.abs(angles.r) > adiff then
					self:SetAngles(Angle(angles.p, angles.y, math.ApproachAngle(angles.r, 0, adiff)))
				end
				if math.abs(anglevel.z) > 0.1 then
					--MsgN(anglevel, "he", math.Approach(anglevel.z, 0, 0.05))
					self.Phys:AddAngleVelocity(Vector(0, 0, anglevel.z < 0 and 0.1 or -0.1))
				end
			end

			--angles.r = 0
			--self:SetAngles(angles)

			--MsgN(angles)

			--MsgN(self.InputVelocity, driver:KeyDown(IN_RIGHT), driver:KeyDown(IN_LEFTs))
		end

		self.InputVelocity.x = math.Clamp(self.InputVelocity.x, -4000, 4000)
		self.InputVelocity.y = math.Clamp(self.InputVelocity.y, -4000, 4000)
		self.InputVelocity.z = math.Clamp(self.InputVelocity.z, -200, 200)

		vel = vel + self.InputVelocity
		local vel1 = vel
		vel:Rotate(self:GetAngles())
		local vel2 = vel
		vel.x = vel.x * 5
		vel.y = vel.y * 5
		MsgN(self:GetAngles(), " -> ", vel1, " - ", vel2, " - ", vel)
		self.Phys:SetVelocity(vel)
		--self.Phys:AddVelocity(self:GetAngles():Forward() * 10)
		--MsgN(self.Phys:GetVelocity())

	end

end

function ENT:PhysicsCollide(cdata, phys)
	if cdata.HitEntity:GetClass() == "worldspawn" then
		--MsgN(cdata.Speed)
		if self:IsEngineRunning() and self.LastEngineStarted < CurTime() - 2 then
			self.InputVelocity = Vector(0, 0, 0)
			if cdata.Speed < 100 then -- TODO Test if we're upright
				self:SetEngineStartLevel(self.MaxEngineStartLevel - 2)
				phys:SetVelocity(Vector(0, 0, 0))
				MsgN("Set velocity to 0")
				--MsgN("eng run: " .. tostring(self:IsEngineRunning()) .. " " .. tostring(self:GetEngineStartFrac()))
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

		MsgN(dist)

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