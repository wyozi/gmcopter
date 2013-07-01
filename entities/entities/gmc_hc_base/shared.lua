if SERVER then
	AddCSLuaFile()
end

ENT.Base = "base_anim"
ENT.Type = "anim"

-- Baseholder variables

ENT.Hull = {
	Model = "",
	Weight = 1000
}

ENT.TopRotor = {
	Model = "",
	Pos = Vector(0, 0, 0),
	Angles = Angle(0, 0, 0)
}

ENT.BackRotor = {
	Model = "",
	Pos = Vector(0, 0, 0),
	Angles = Angle(0, 0, 0)
}

ENT.Seats = {}
ENT.Passengers = {}

-- Simple variables

ENT.MaxEnterDistance = 50
ENT.MaxEngineStartLevel = 100

ENT.RotorSpinSpeed = 12

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ESL") -- EngineStartLevel
end

AccessorFunc(ENT, "ESL", "EngineStartLevel")

function ENT:GetEngineStartFrac()
	return self:GetEngineStartLevel() / self.MaxEngineStartLevel
end
function ENT:IsEngineRunning()
	return self:GetEngineStartFrac() >= 1.0
end

function ENT:Initialize()
	local hull = self.Hull

	if SERVER then

		self.Brake = 0

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

	self.MSounds = {}
	for name, value in pairs(self.Sounds) do
		sound.Add({
			name = "gmc."..self.ClassName.."."..name,
			channel = CHAN_STATIC,
			soundlevel = (name == "Blades" or name == "Engine") and 180 or 100,
			sound = value
		})
		self.MSounds[name] = CreateSound(self, "gmc."..self.ClassName.."."..name)
	end
end
