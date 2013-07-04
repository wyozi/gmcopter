if SERVER then
	AddCSLuaFile()
end

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.IsHelicopter = true

-- Baseholder variables


ENT.Hull = {
	Model = "models/Flyboi/LittleBird/littlebirda_fb.mdl",
	Weight = 1300
}

ENT.TopRotor = {
	Model = "models/Flyboi/LittleBird/littlebirdrotorm_fb.mdl",
	Pos = Vector(-10, 0, 100),
	Angles = Angle(0, 0, 0)
}

ENT.BackRotor = {
	Dir = -1,
	Model = "models/Flyboi/LittleBird/LittleBirdT_fb.mdl",
	Pos = Vector(-217, 9, 73),
	Angles = Angle(0, 0, 0)
}

ENT.Seats = {
	{
		Pos = Vector(22, 15, 49),
		Exit = Vector(70, 70, 10)
	},
	{
		Pos = Vector(22, -12, 49),
		Exit = Vector(70, -70, 10),
	}
}

ENT.Sounds = {
	Start = Sound("WAC/Heli/h6_start.wav"),
	Blades = Sound("WAC/Heli/heli_loop_ext.wav"),
	Engine = Sound("WAC/Heli/heli_loop_int.wav"),
	MissileAlert = Sound("HelicopterVehicle/MissileNearby.mp3"),
	MinorAlarm = Sound("HelicopterVehicle/MinorAlarm.mp3"),
	LowHealth = Sound("HelicopterVehicle/LowHealth.mp3"),
	CrashAlarm = Sound("HelicopterVehicle/CrashAlarm.mp3")
}

ENT.Lights = {
	{
		Pos = Vector(-227, -9, 82),
		Color = Color(255, 0, 0),
		Brightness = 1,
		BlinkRate = 1,
		Decay = 1
	},
	{
		Pos = Vector(-238, -10, 123),
		Color = Color(255, 0, 0),
		Brightness = 1,
		BlinkRate = 0.8,
		Decay = 0.8
	},
	{
		Pos = Vector(29, -6, 20),
		Color = Color(255, 0, 0),
		Brightness = 1,
		BlinkRate = 0.5,
		Decay = 0.2
	}
}

-- Simple variables

ENT.MaxEnterDistance = 50
ENT.MaxEngineStartLevel = 10

ENT.RotorSpinSpeed = 3000

ENT.TopRotorForceLimit = 0
ENT.BackRotorForceLimit = 0

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ESL") -- EngineStartLevel
end

AccessorFuncDT(ENT, "ESL", "EngineStartLevel")

function ENT:GetEngineStartFrac()
	return self:GetEngineStartLevel() / self.MaxEngineStartLevel
end
function ENT:IsEngineRunning()
	return self:GetEngineStartFrac() >= 1.0
end

function ENT:Initialize()

	if SERVER then self:SvInit() end

	if CLIENT then
		self.Emitter = ParticleEmitter(self:GetPos())

		self.MLights = {}
		for k,ml in pairs(self.Lights) do
			self.MLights[k] = {
				LastBlink = 0
			}
		end
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

function ENT:GetGroundHitPos()
	return util.QuickTrace(self:GetPos(), Vector(0, 0, -10000), self).HitPos
end
function ENT:IsJustAboveGround()
	return util.TraceLine({start=self:GetPos(), endpos=self:GetPos() - Vector(0, 0, 60), filter={self}}).HitWorld
end