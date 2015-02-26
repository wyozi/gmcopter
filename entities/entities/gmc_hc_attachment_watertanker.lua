
AddCSLuaFile()

ENT.Base = "gmc_hc_attachment_base"
ENT.Model = Model("models/props_c17/FurnitureBathtub001a.mdl")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", 0, "Lowered")
	self:NetworkVar("Bool", 1, "Spraying")
	self:NetworkVar("Float", 0, "WaterStored")
end

if SERVER then
	util.AddNetworkString("GMCWaterTanker")
	net.Receive("GMCWaterTanker", function(len, cl)
		local heli = cl:GetHelicopter()
		if not IsValid(heli) then return end

		local att = heli:GetHeliAttachment("gmc_hc_attachment_watertanker")
		if not IsValid(att) then return end

		local act = net.ReadUInt(8)

		if act == 1 then
			att:SetLowered(not att:GetLowered())
		elseif act == 2 then
			att:SetSpraying(not att:GetSpraying())
		end
	end)

	function ENT:AttachToHeli(heli)
		self:SetModel(self.Model)

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )


		self:SetMaterial("models/debug/debugwhite")
	end

	function ENT:Think()
		self:SetLocalPos(Vector(0, 2.5, self:GetLowered() and -150 or 20))

		if self:GetSpraying() then
			if (self:GetWaterStored() <= 0 or self:GetLowered()) then
				self:SetSpraying(false)
			else
				local tr = util.TraceLine({
					start = self:GetPos(),
					endpos = self:GetPos() - self:GetUp() * 16000,
					filter = self
				})

				local pos = tr.HitPos

				for id, prop in pairs( ents.FindInSphere( pos, 80 ) ) do
					if prop:IsValid() then
						--if prop:IsOnFire() then prop:Extinguish() end

						local class = prop:GetClass()
						if string.find(class, "env_fire") then
							prop:SetHealth(prop:Health() - 20)
							if prop:Health() <= 0 then
								prop:Fire("Extinguish")
							end
						end
					end
				end

				self:SetWaterStored(math.Clamp(self:GetWaterStored() - 0.03, 0, 1))
			end
		end

		local fillspeed = math.Remap(self:WaterLevel(), 0, 3, 0, 1)
		if fillspeed > 0 then
			self:SetWaterStored(math.Clamp(self:GetWaterStored() + fillspeed * 0.02, 0, 1))
		end
	end

end

if CLIENT then
	function ENT:Think()
		if self:GetSpraying() then
			self.PEmitter = self.PEmitter or ParticleEmitter(self:GetPos(), false)

			-- Credits to rubar
			--for i = 1, 2 do
				local particle = self.PEmitter:Add("effects/splash4", self:GetPos() - Vector(0, 0, 0))
				if ( particle ) then
					local Spread = 0.3
					particle:SetVelocity( Vector(math.random(-150, 150), math.random(-150, 150), -600) )

					particle:SetDieTime( 5 )
					particle:SetColor( 255, 255, 255 )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 255 )
					particle:SetStartSize( 20 )
					particle:SetEndSize( 0 )
					particle:SetCollide( 1 )
					particle:SetCollideCallback(function( particleC, HitPos, normal )
						
						particleC:SetAngleVelocity( Angle( 0, 0, 0 ) )
						particleC:SetVelocity( Vector( 0, 0, 0 ) )
						particleC:SetGravity( Vector( 0, 0, 0 ) )

						local angles = normal:Angle()
						angles:RotateAroundAxis( normal, particleC:GetAngles().y )
						particleC:SetAngles( angles )

						particleC:SetLifeTime( 0 )
						particleC:SetDieTime( 10 )
						particleC:SetStartSize( 8 )
						particleC:SetEndSize( 0 )
						particleC:SetStartAlpha( 128 )
						particleC:SetEndAlpha( 0 )
					end)
				end
			--end
		end
	end
end