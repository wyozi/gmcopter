
AddCSLuaFile()


ENT.Model = Model("models/weapons/w_bugbait.mdl") 

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then
	
	function ENT:Initialize()
		self:SetModel(self.Model)

		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)

	end

end