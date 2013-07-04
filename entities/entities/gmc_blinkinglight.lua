
AddCSLuaFile()

ENT.Model = Model("models/weapons/w_bugbait.mdl") 

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if SERVER then
	
	function ENT:Initialize()
		self:SetModel(self.Model)

		--self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)

	end

end

if CLIENT then
	

	local mat = Material("sprites/light_glow02_add")
	function ENT:DrawLightSprites()
		cam.Start3D(EyePos(), EyeAngles())
			render.SetMaterial(mat)
			render.DrawSprite(self:GetPos(), 32, 32, self:GetColor())
		cam.End3D()
	end

end