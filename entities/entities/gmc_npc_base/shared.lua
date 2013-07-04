if SERVER then
	AddCSLuaFile()
end

AddCSLuaFile()


ENT.Base             = "base_nextbot"


function ENT:Initialize()
    self:SetModel( "models/mossman.mdl" );
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

function ENT:BehaveAct()
end
