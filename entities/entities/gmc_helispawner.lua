
AddCSLuaFile()

ENT.Model = Model("models/props_lab/reciever_cart.mdl") 

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then
	
	function ENT:Initialize()
		self:SetModel(self.Model)

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )

	end

	function ENT:KeyValue(key, value)
		if key == "helispawnid" then
			self.HeliSpawnId = value
		end
	end

end