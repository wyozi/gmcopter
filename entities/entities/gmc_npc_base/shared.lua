if SERVER then
	AddCSLuaFile()
end

AddCSLuaFile()


ENT.Base             = "base_nextbot"


function ENT:Initialize()
    self:SetModel( "models/mossman.mdl" );
end


function ENT:BehaveAct()
end
