
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

	function ENT:Think()
		--[[
		local heli = self:GetHelicopter()
		if IsValid(heli) then
			local driver = heli:GetDriver()
			if not IsValid(driver) then return end

			if driver:KeyDown( IN_WALK ) then
				local lang = self:GetLocalAngles()
				self:SetLocalAngles(Angle(lang.p+5, lang.y, lang.r))
			elseif driver:KeyDown( IN_RIGHT ) then
				local lang = self:GetLocalAngles()
				self:SetLocalAngles(Angle(lang.p-5, lang.y, lang.r))
			end

			gmcdebug.CMsg(self:GetLocalAngles(), driver:KeyDown(IN_WALK), driver:KeyDown(IN_RIGHT))

		end
		]]
	end

end

if CLIENT then

	function ENT:AddComponents(hguibase)
		hguibase:AddBottomComponent(vgui.Create(gmchgui.Translate("RadarView")), self)
	end

	local PANEL = {}

	local UpdateCView = {
		draw = false
	}

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

		UpdateCView.ang = ang
		UpdateCView.pos = heli:GetPos() + Vector(0, 0, 15)
		UpdateCView.x = x
		UpdateCView.y = y
		UpdateCView.w = w
		UpdateCView.h = h

		UpdateCView.draw = true
	end

	gmchgui.Create("RadarView", PANEL)

	-- render.RenderView doesn't work (leaves out world faces, "culling") if called from PANEL:Paint(), so we're using a workaround to call the renderview from HUDPaint to make it work properly
	hook.Add("HUDPaint", "RenderViewWorkaroundFix", function()

		if not UpdateCView.draw then return end
		UpdateCView.draw = false

		local CamData = {}
		CamData.angles = UpdateCView.ang
		CamData.origin = UpdateCView.pos
		CamData.x = UpdateCView.x
		CamData.y = UpdateCView.y
		CamData.w = UpdateCView.w
		CamData.h = UpdateCView.h
		CamData.fov = 90
		CamData.drawviewmodel = false
		render.RenderView( CamData )
	end)

end