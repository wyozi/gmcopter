
AddCSLuaFile()

ENT.Model = Model("models/weapons/w_bugbait.mdl") 

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.IsHeliAttachment = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Heli")
end

function ENT:GetHelicopter()
	return self:GetHeli()
end

if SERVER then

	function ENT:AttachToHeli(heli)
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
	end

	function ENT:SetHelicopter(heli)
		self:SetParent(heli)
		self:SetHeli(heli)
	end
	
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:AttachToHeli(self:GetHelicopter())
	end
end