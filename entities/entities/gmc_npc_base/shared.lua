if SERVER then
	AddCSLuaFile()
end

AddCSLuaFile()


ENT.Base = "base_nextbot"

local models = {
	"models/mossman.mdl",
	"models/alyx.mdl",
	"models/Barney.mdl",
	"models/breen.mdl",
	"models/Eli.mdl",
	"models/gman_high.mdl",
	"models/Kleiner.mdl",
	"models/monk.mdl",
	"models/odessa.mdl",
	"models/vortigaunt.mdl",
	"models/Humans/Group01/Female_01.mdl",
	"models/Humans/Group01/Female_02.mdl",
	"models/Humans/Group01/Female_03.mdl",
	"models/Humans/Group01/Female_04.mdl",
	"models/Humans/Group01/Female_06.mdl",
	"models/Humans/Group01/Female_07.mdl",
	"models/Humans/Group01/Male_01.mdl",
	"models/Humans/Group01/male_02.mdl",
	"models/Humans/Group01/male_03.mdl",
	"models/Humans/Group01/Male_04.mdl",
	"models/Humans/Group01/Male_05.mdl",
	"models/Humans/Group01/male_06.mdl",
	"models/Humans/Group01/male_07.mdl",
	"models/Humans/Group01/male_08.mdl",
	"models/Humans/Group01/male_09.mdl",
}

function ENT:Initialize()
    self:SetModel(table.Random(models))
end

function ENT:FindHelicopter(range)
	if not range then
		range = 1000
	end
	local heli
	for _,ent in pairs(ents.FindInSphere(self:GetPos(), range)) do
		if ent.IsHelicopter then
			heli = ent
		end
	end
	return heli
end

function ENT:BehaviourTick()
end

function ENT:RunBehaviour()
    while true do
    	self:BehaviourTick()
        coroutine.yield()
    end
end