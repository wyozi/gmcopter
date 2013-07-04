
AddCSLuaFile()

ENT.Base = "gmc_hc_attachment_base"
ENT.Model = Model("models/lamps/torch.mdl")

if SERVER then

	function ENT:AttachToHeli(heli)

		self:SetModel(self.Model)
		self:SetColor(Color(0, 0, 0))

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetLocalPos(Vector(20, 0, 25))
		self:SetLocalAngles(Angle(90, 0, 0))

		self.pointcamera = ents.Create( "point_camera" )

		self.pointcamera:SetParent( self )

		-- The local positions are the offsets from parent..
		self.pointcamera:SetLocalPos( Vector( 0, 0, 0 ) )
		self.pointcamera:SetLocalAngles( Angle(0, 0, 0) )

		self.pointcamera:SetKeyValue("GlobalOverride", 1)
		self.pointcamera:Spawn()
		self.pointcamera:Activate()

		self.pointcamera:Fire("SetOnAndTurnOthersOff", "", 0)

	end

end