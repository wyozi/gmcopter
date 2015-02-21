gmcnpcs = gmcnpcs or {}

gmcnpcs.POIs = {
	-- Grass area
	Vector(-2170.8549804688, 240.54220581055, -11135.96875),
	Vector(-2188.5832519531, -530.82446289063, -11135.96875),
	Vector(-901.27258300781, 365.27624511719, -11135.96875),
	Vector(-685.67126464844, -1203.3029785156, -11135.96875),
	Vector(-646.52294921875, -2713.2978515625, -11135.96875),
	Vector(563.48223876953, -2749.8095703125, -11135.96875),
	Vector(544.21221923828, -1576.2160644531, -11135.96875),

	-- Garbage lake
	Vector(9182.794921875, 10235.766601563, -10895.96875),

	-- Near garbage lake
	Vector(10197.838867188, 6404.4448242188, -11135.96875),
	Vector(5516.912109375, 6729.2192382813, -11135.96875),
	Vector(4747.9453125, 5602.3422851563, -11135.96875),

	-- Suburbs
	Vector(12068.479492188, 286.31121826172, -11135.96875),
	Vector(11555.684570313, -2645.4477539063, -11135.96875),
	Vector(11405.11328125, -6785.8608398438, -11135.96875),
	Vector(11413.154296875, -9102.50390625, -11135.96875),
	Vector(9025.130859375, -11420.166015625, -11135.96875),

	-- City 
	Vector(2932.0197753906, -11181.69921875, -11135.96875),
	Vector(627.35778808594, -11322.251953125, -11135.96875),
	Vector(-1800.0992431641, -10768.314453125, -11135.96875),
	Vector(-6277.9311523438, -10621.03125, -11135.96875),
	Vector(-9691.99609375, -11463.043945313, -11135.96875),
	Vector(-12758.672851563, -11382.624023438, -11135.96875),
	Vector(-11357.734375, -5919.5805664063, -10879.96875),
	Vector(-11370.076171875, -3464.7966308594, -10879.96875),
	Vector(-11789.602539063, 3109.8315429688, -11135.96875),
	Vector(-9580.8681640625, 11403.2265625, -11135.96875),
	Vector(-2465.658203125, 9175.6796875, -11143.96875),
}

timer.Create("NPCSpawner", 1, 0, function()
	local npccount = #ents.FindByClass("gmc_npc*")
	if npccount >= 30 then
		return
	end

	local pos = table.Random(gmcnpcs.POIs)
	local ent = ents.Create("gmc_npc_generic")
	ent:SetPos(pos + Vector(math.random()*100, math.random()*100, 50))
	ent:Spawn()
	ent:Activate()
end)