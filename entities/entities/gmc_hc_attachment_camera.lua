
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

if CLIENT then

	--[[local matscreen = CreateMaterial("GMCRT","UnlitGeneric",{
	        ["$vertexcolor"] = 1,
	        ["$vertexalpha"] = 1,
	        ["$ignorez"] = 1,
	        ["$nolod"] = 1,
	})

	function ENT:Initialize()
		self.RTMaterial = GetRenderTarget("gmc_rt_" .. tostring(self:EntIndex()), 256, 256)
	end

	function ENT:Draw()

        self.OldWidth, self.OldHeight = ScrW(), ScrH()
        self.OldRT = render.GetRenderTarget()
        render.SetRenderTarget( self.RTMaterial )
        render.SetViewPort(0, 0, 512, 512)
        cam.Start3D( EyePos(), EyeAngles() )

        render.RenderView()

        cam.End3D()
        render.SetViewPort(0, 0, self.OldWidth, self.OldHeight)
        render.SetRenderTarget( self.OldRT )

	end
	
	hook.Add("HUDPaint", "test", function()
		local ea = ents.FindByClass("gmc_hc_attachment_camera")

		for _,e in pairs(ea) do
			local OldTex = matscreen:GetTexture("$basetexture")
	        matscreen:SetTexture("$basetexture", e.RTMaterial)
	       
	        surface.SetDrawColor( 255,255,255,255 )
	        surface.SetMaterial( matscreen )
	        surface.DrawTexturedRect( 0, 0, 512, 512 )
	 
	       
	        matscreen:SetTexture("$basetexture", OldTex)
		end
	end)]]

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