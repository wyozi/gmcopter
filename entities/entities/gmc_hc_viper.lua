
if SERVER then
	AddCSLuaFile()
end

ENT.Base = "gmc_hc_base"

ENT.Hull = {
	Model = "models/bf2/helicopters/ah-1 cobra/ah1z_b.mdl",
	Weight = 1300
}

ENT.TopRotor = {
	Model = "models/bf2/helicopters/ah-1 cobra/ah1z_r.mdl",
	Pos = Vector(0, 0, 120),
	Angles = Angle(0, 0, 0)
}

ENT.BackRotor = {
	Dir = -1,
	Model = "models/bf2/helicopters/ah-1 cobra/ah1z_tr.mdl",
	Pos = Vector(-362.61,22.06,107.22),
	Angles = Angle(0, 0, 192)
}

ENT.Seats = {
	{
		Pos = Vector(75, 0, 49),
		Exit = Vector(70, 70, 10)
	},
	{
		Pos = Vector(22, -12, 49),
		Exit = Vector(70, -70, 10),
	}
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