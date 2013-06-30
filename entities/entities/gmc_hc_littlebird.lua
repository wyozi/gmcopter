
if SERVER then
	AddCSLuaFile()
end

ENT.Base = "gmc_hc_base"

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
	Pos = Vector(-217, 9, 73)
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