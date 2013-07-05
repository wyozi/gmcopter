
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

	end

end

if CLIENT then

	function ENT:AddComponents(hguibase)
		hguibase:AddBottomComponent(vgui.Create(gmchgui.Translate("RadarView")))
	end

	local PANEL = {}

	function PANEL:Paint( att )
		
		local x,y = self:GetPos()
		local w,h = self:GetSize()

		local heli = LocalPlayer():GetHelicopter()
		local ang
		if IsValid(att) then
			ang = att:GetAngles()
		else
			ang = heli:GetAngles()
			ang:RotateAroundAxis(ang:Right(), -90)
		end

		local CamData = {}
		CamData.angles = ang
		CamData.origin = heli:GetPos()
		CamData.x = x
		CamData.y = y
		CamData.w = w
		CamData.h = h
		CamData.fov = 90
		render.RenderView( CamData )
	end

	gmchgui.Create("RadarView", PANEL)

end