
AddCSLuaFile()

ENT.Base = "gmc_hc_attachment_base"
ENT.Model = Model("models/props_c17/FurnitureBathtub001a.mdl")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar("Bool", 0, "Lowered")
	self:NetworkVar("Float", 0, "WaterStored")
end

if SERVER then
	util.AddNetworkString("GMCWaterTanker")
	net.Receive("GMCWaterTanker", function(len, cl)
		local heli = cl:GetHelicopter()
		if not IsValid(heli) then return end

		local att = heli:GetHeliAttachment("gmc_hc_attachment_watertanker")
		if not IsValid(att) then return end

		att:SetLowered(not att:GetLowered())
	end)

	function ENT:AttachToHeli(heli)
		self:SetModel(self.Model)

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )


		self:SetMaterial("models/debug/debugwhite")
	end

	function ENT:Think()
		self:SetLocalPos(Vector(0, 2.5, self:GetLowered() and -90 or 20))

		local fillspeed = math.Remap(self:WaterLevel(), 0, 3, 0, 1)
		if fillspeed > 0 then
			self:SetWaterStored(math.Clamp(self:GetWaterStored() + fillspeed * 0.02, 0, 1))
		end

		self:SetNextThink(CurTime() + 0.1)
	end

end