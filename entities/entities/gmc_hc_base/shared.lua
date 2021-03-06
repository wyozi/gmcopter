if SERVER then
	AddCSLuaFile()
end

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.IsHelicopter = true

-- Baseholder variables

-- SHOULD BE MOVED TO LITTLEBIRD LUA WHEN DONE WITH HELI BASE
ENT.Hull = {
	Model = "models/Flyboi/LittleBird/littlebird_fb.mdl",
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

-- SHOULD BE MOVED TO LITTLEBIRD LUA WHEN DONE WITH HELI BASE
ENT.Seats = {
	{
		Pos = Vector(22, 15, 49),
		Ang = Angle(0, -90, 0),
		Exit = Vector(70, 70, 10),
	},
	{
		Pos = Vector(22, -12, 49),
		Ang = Angle(0, -90, 0),
		Exit = Vector(70, -70, 10),
	}
}

-- SHOULD BE MOVED TO LITTLEBIRD LUA WHEN DONE WITH HELI BASE
ENT.Sounds = {
	Start = {Sound = Sound("wac/heli/h6_start.wav")},
	Blades = {Sound = Sound("wac/heli/heli_loop_ext.wav"), SoundLevel = 180, PitchInside = 0.9, VolInside = 0.5},
	Engine = {Sound = Sound("wac/heli/heli_loop_int.wav"), SoundLevel = 180, PitchInside = 0.9, VolInside = 0.5},
	MissileAlert = {Sound = Sound("helicoptervehicle/missilenearby.mp3")},
	MinorAlarm = {Sound = Sound("helicoptervehicle/minoralarm.mp3")},
	LowHealth = {Sound = Sound("helicoptervehicle/lowhealth.mp3")},
	CrashAlarm = {Sound = Sound("helicoptervehicle/crashalarm.mp3")}
}

ENT.HitSounds = {
	Hard = gmc.utils.MapTable(gmc.utils.Range(1, 7), function(v) return Sound("physics/metal/metal_barrel_impact_hard" .. tostring(v) .. ".wav") end),
	Soft = gmc.utils.MapTable(gmc.utils.Range(1, 4), function(v) return Sound("physics/metal/metal_barrel_impact_soft" .. tostring(v) .. ".wav") end)
}

-- SHOULD BE MOVED TO LITTLEBIRD LUA WHEN DONE WITH HELI BASE
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

-- SHOULD BE MOVED TO LITTLEBIRD LUA WHEN DONE WITH HELI BASE
ENT.RotorSpinSpeed = 3000

ENT.TopRotorForceLimit = 0
ENT.BackRotorForceLimit = 0

-- SHOULD BE MOVED TO LITTLEBIRD LUA WHEN DONE WITH HELI BASE
ENT.CopterGuiName = "LittlebirdDefaults"

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ESL") -- EngineStartLevel
	self:NetworkVar("Int", 1, "VehHealth") -- WAC did this so we might aswell
	self:NetworkVar("Float", 0, "RotorFrac") -- The rotor's speed as frac 0 - 1
end

gmc.utils.AccessorFuncDT(ENT, "ESL", "EngineStartLevel")

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

	-- Used for looping sounds
	self.MSounds = {}
	for name, value in pairs(self.Sounds) do
		local sndlevel = value.SoundLevel or 100

		sound.Add({
			name = "gmc.." .. self.ClassName .. "." .. name,
			channel = CHAN_STATIC,
			soundlevel = sndlevel,
			sound = value.Sound
		})
		self.MSounds[name] = CreateSound(self, "gmc.."..self.ClassName.."."..name)
	end
end

-- TODO map specific
function ENT:GetAltitude()
	return self:GetPos().z + 11144
end

function ENT:GetGroundHitPos()
	return util.QuickTrace(self:GetPos(), Vector(0, 0, -10000), self).HitPos
end
function ENT:IsJustAboveGround()
	return util.TraceLine({start=self:GetPos(), endpos=self:GetPos() - Vector(0, 0, 60), filter={self}}).HitWorld
end

function ENT:GetHeliAttachment(cls)
	return ents.FindByClassAndParent(cls, self)[1]
end