
if SERVER then
	AddCSLuaFile()
end

ENT.Base = "gmc_hc_base"

ENT.Hull = {
	Model = "models/bf2/helicopters/uh-60 blackhawk/uh60_b.mdl",
	Weight = 1300
}

ENT.TopRotor = {
	Model = "models/bf2/helicopters/uh-60 blackhawk/uh60_r.mdl",
	Pos = Vector(0, 0, 100),
	Angles = Angle(0, 0, 0)
}

ENT.BackRotor = {
	Dir = -1,
	Model = "models/bf2/helicopters/uh-60 blackhawk/uh60_rr.mdl",
	Pos = Vector(-400, 17, 134),
	Angles = Angle(0, 0, 192)
}

ENT.Seats = {
	{
		Pos = Vector(120, 30, 30),
		Exit = Vector(70, 70, 10)
	},
	{
		Pos = Vector(120, -30, 30),
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