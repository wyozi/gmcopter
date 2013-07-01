AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SvInit()
	local hull = self.Hull

	self.Brake = 0
	self.InputVelocity = Vector(0, 0, 0)

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

		if not constraint.Axis(self, trotor, 0, 0, self.TopRotor.Pos, Vector(0,0,1), 0,0,0,1) then
			MsgN("Constraint waswnt credted")
		end

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
		elseif not driver.IncAltDown then -- Shouldn't get sound of rotors accelerating if we've stopped
			self.MSounds.Start:Stop()
		end

		if driver.IncAltDown then
			self:SetEngineStartLevel(math.min(self:GetEngineStartLevel() + 1, self.MaxEngineStartLevel))
			self.Brake = 0
		elseif self:GetEngineStartLevel() > 0 then
			self:SetEngineStartLevel(math.max(self:GetEngineStartLevel() - 3, 0))
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

	--[[local RotorFrac = math.Clamp(self:RotorSpeed() / 5000, 0, 1)

	MsgN(self:RotorSpeed(), "  lel  ", RotorFrac)
	if RotorFrac > 0.01 then
		if not self.MSounds.Blades:IsPlaying() then
			self.MSounds.Blades:Play()
		end
		self.MSounds.Blades:ChangeVolume(RotorFrac, 0)
	elseif self.MSounds.Blades:IsPlaying() then
		self.MSounds.Blades:Stop()
	end DURR DURR ]]

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
	local oav = self.TopRotorPhys:GetAngleVelocity() * self.Brake
	if self:IsEngineRunning() then
		SetAngleVelocity(self.TopRotorPhys, Vector(0, 0, self.RotorSpinSpeed))
	elseif self:GetEngineStartFrac() > 0.1 then
		SetAngleVelocity(self.TopRotorPhys, Vector(0, 0, self:GetEngineStartFrac() * self.RotorSpinSpeed))
	end

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

		if IsValid(driver) then
			local angles = self:GetAngles()
			if driver:KeyDown(IN_FORWARD) then
				if angles.p < 12 then
					self.Phys:AddAngleVelocity(Vector(0, 0.1, 0))
				end
				self.InputVelocity = self.InputVelocity + OverrideComponents(angles:Forward() * 2.5, _, _, 0)
			elseif driver:KeyDown(IN_BACK) then
				if angles.p > -12 then
					self.Phys:AddAngleVelocity(Vector(0, -0.1, 0))
				end
				self.InputVelocity = self.InputVelocity - OverrideComponents(angles:Forward() * 2.5, _, _, 0)
			end
			
			if angles.p > 12 or angles.p < 12 then
				self.Phys:AddAngleVelocity(Vector(0, angles.p > 0 and -0.05 or 0.05, 0))
			end

			if driver:KeyDown(IN_MOVERIGHT) then
				self.Phys:AddAngleVelocity(Vector(0, 0, -0.2))
			elseif driver:KeyDown(IN_MOVELEFT) then
				self.Phys:AddAngleVelocity(Vector(0, 0, 0.2))
			end

			angles.r = 0
			self:SetAngles(angles)

			MsgN(angles)

			--MsgN(self.InputVelocity, driver:KeyDown(IN_RIGHT), driver:KeyDown(IN_LEFTs))
		end

		self.InputVelocity.x = math.Clamp(self.InputVelocity.x, -300, 300)
		self.InputVelocity.y = math.Clamp(self.InputVelocity.y, -300, 300)
		self.InputVelocity.z = math.Clamp(self.InputVelocity.z, -200, 200)

		vel = vel + self.InputVelocity

		--MsgN(vel)
		--vel = vel:Rotate(-1*self:GetAngles())
		self.Phys:SetVelocity(vel)

	end

end

function ENT:PhysicsCollide(cdata, phys)
	if cdata.HitEntity:GetClass() == "worldspawn" then
		MsgN(cdata.Speed)
		if self:IsEngineRunning() and self.LastEngineStarted < CurTime() - 2 then
			if cdata.Speed < 200 then
				self:SetEngineStartLevel(self.MaxEngineStartLevel - 2)
			else
				-- Bounce back?
				local LastSpeed = math.max( cdata.OurOldVelocity:Length(), cdata.Speed )
				local NewVelocity = phys:GetVelocity()
				NewVelocity:Normalize()

				LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

				local TargetVelocity = NewVelocity * LastSpeed * 0.2

				phys:SetVelocity( TargetVelocity )
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