
AddCSLuaFile()

ENT.Base = "gmc_hc_attachment_base"
ENT.Model = Model("models/lamps/torch.mdl")
ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then

	function ENT:AttachToHeli(heli)

		self:SetModel(self.Model)

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetLocalPos(Vector(75, 2.5, 20))
		self:SetLocalAngles(Angle(30, 0, 0))

		self.LightOn = true

	end

	function ENT:CreateFlashlight()
		self.flashlight = ents.Create( "env_projectedtexture" )

		self.flashlight:SetParent( self )

		-- The local positions are the offsets from parent..
		self.flashlight:SetLocalPos( Vector( 0, 0, 0 ) )
		self.flashlight:SetLocalAngles( Angle(0,0,0) )

		-- Looks like only one flashlight can have shadows enabled!
		self.flashlight:SetKeyValue( "enableshadows", 1 )
		self.flashlight:SetKeyValue( "farz", 2048 )
		self.flashlight:SetKeyValue( "nearz", 12 )
		self.flashlight:SetKeyValue( "lightfov", 70 )

		local c = Color(255, 255, 255)
		local b = 10
		self.flashlight:SetKeyValue( "lightcolor", Format( "%i %i %i 255", c.r * b, c.g * b, c.b * b ) )

		self.flashlight:Spawn()
	end

	function ENT:Think()

		local heli = self:GetHelicopter()
		if IsValid(heli) then
			if heli:IsEngineRunning() and not self.LightOn then
				self:CreateFlashlight()
				self.LightOn = true
			elseif not heli:IsEngineRunning() and self.LightOn then
				SafeRemoveEntity(self.flashlight)
				self.LightOn = false
			end
		end

		self:NextThink(CurTime() + 0.5)
	end

end

if CLIENT then

	function ENT:Initialize()
		self.PixVis = util.GetPixelVisibleHandle()
	end
	
	local matLight = Material( "sprites/light_ignorez" )
	local matBeam	= Material( "effects/lamp_beam" )

	function ENT:Draw()

		self.BaseClass.Draw( self )

	end

	function ENT:DrawTranslucent()

		self.BaseClass.DrawTranslucent( self )

		-- No glow if we're not switched on!
		if ( not IsValid(self:GetHeli()) or not self:GetHeli():IsEngineRunning() ) then return end

		local LightNrm = self:GetAngles():Forward()
		local ViewNormal = self:GetPos() - EyePos()
		local Distance = ViewNormal:Length()
		ViewNormal:Normalize()
		local ViewDot = ViewNormal:Dot( LightNrm * -1 )
		local LightPos = self:GetPos() + LightNrm * 5

		-- glow sprite
		--[[
		render.SetMaterial( matBeam )
		local BeamDot = BeamDot = 0.25
		render.StartBeam( 3 )
		render.AddBeam( LightPos + LightNrm * 1, 128, 0.0, Color( r, g, b, 255 * BeamDot) )
		render.AddBeam( LightPos - LightNrm * 100, 128, 0.5, Color( r, g, b, 64 * BeamDot) )
		render.AddBeam( LightPos - LightNrm * 200, 128, 1, Color( r, g, b, 0) )
		render.EndBeam()
		--]]

		if ( ViewDot >= 0 ) then

			render.SetMaterial( matLight )
			local Visibile	= util.PixelVisible( LightPos, 16, self.PixVis )	

			if (!Visibile) then return end

			local Size = math.Clamp( Distance * Visibile * ViewDot * 1.5, 64, 512 )

			Distance = math.Clamp( Distance, 32, 800 )
			local Alpha = math.Clamp( (1000 - Distance) * Visibile * ViewDot, 0, 100 )
			local Col = self:GetColor()
			Col.a = Alpha

			render.DrawSprite( LightPos, Size, Size, Col, Visibile * ViewDot )
			render.DrawSprite( LightPos, Size*0.4, Size*0.4, Color(255, 255, 255, Alpha), Visibile * ViewDot )

		end

	end


	function ENT:AddComponents(hguiframe)
		
	end

end