include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

--http://en.wikipedia.org/wiki/Attitude_indicator
function ENT:DrawAttitudeIndicator(pnl, x, y, w, h)
	local midx, midy = x+w/2, y+h/2

	local roll = self:GetAngles().r

	-- Convert to a mathematical angle
	local ang = 90 - roll

	local c1ang = ang + 90
	local c2ang = ang - 90

	local yoff = -self:GetAngles().p / math.pi

	local ground_poly = {
		{x = x, y = midy+math.sin(math.rad(c1ang))*15-1 + yoff},
		{x = x+w, y = midy+math.sin(math.rad(c2ang))*15-1 + yoff},
		{x = x+w, y = y+h},
		{x = x, y = y+h}
	}

	pnl:DrawPolygon(ground_poly, Color(139, 69, 19))

	local sky_poly = {
		{x = x, y = y},
		{x = x+w, y = y},
		{x = x+w, y = midy+math.sin(math.rad(c2ang))*15-1 + yoff},
		{x = x, y = midy+math.sin(math.rad(c1ang))*15-1 + yoff},
	}

	pnl:DrawPolygon(sky_poly, Color(25, 181, 254))

	--pnl:Rect(midx+math.cos(math.rad(c1ang))*15-1, midy+math.sin(math.rad(c1ang))*15-1 + yoff, 2, 2, Color(255, 0, 0))
	--pnl:Rect(midx+math.cos(math.rad(c2ang))*15-1, midy+math.sin(math.rad(c2ang))*15-1 + yoff, 2, 2, Color(255, 0, 0))
end

surface.CreateFont("GMCMeterLabel", {
	font = "Tahoma",
	size = 9
})

function ENT:DrawMeter(pnl, label, x, y, w, h, ang)
	pnl:DrawRect(x, y, w, h, Color(255, 255, 255))
	pnl:DrawText(label, "GMCMeterLabel", x+w/2, y+2, Color(0, 0, 0))

	local midx, midy = x + w/2, y + h/2

	local radius = w/2 - 1

	ang = ang - math.rad(90)

	local ang1 = ang-math.pi/2
	local ang2 = ang+math.pi/2

	local arrow_thickness = 1

	local arrow_poly = {
		{x = midx + math.cos(ang2)*arrow_thickness                       , y = midy + math.sin(ang2)*arrow_thickness},
		{x = midx + math.cos(ang1)*arrow_thickness                       , y = midy + math.sin(ang1)*arrow_thickness},
		{x = midx + math.cos(ang)*radius + math.cos(ang1)*arrow_thickness, y = midy + math.sin(ang)*radius + math.sin(ang1)*arrow_thickness},
		{x = midx + math.cos(ang)*radius + math.cos(ang2)*arrow_thickness, y = midy + math.sin(ang)*radius + math.sin(ang2)*arrow_thickness},
	}

	pnl:DrawPolygon(arrow_poly, Color(0, 0, 0))
end

local map_rt = GetRenderTarget( "GMCMinimapRT2", 1024, 1024, true )
local map_rt_mat = CreateMaterial( "GMCMinimapMat", "UnlitGeneric", { ["$basetexture"] = "GMCMinimapRT2" } )

local ORTHO_SIZE = 16000

hook.Add("HUDPaint", "GMCMinimapRenderer", function()
	
	render.PushRenderTarget(map_rt)

	render.RenderView {
		origin = Vector(0, 0, 2722.4045),
		angles = Angle(90, 90, 0),
		x = 0,
		y = 0,
		w = 1024,
		h = 1024,
		ortho = true,
		ortholeft = -ORTHO_SIZE,
		orthoright = ORTHO_SIZE,
		orthotop = -ORTHO_SIZE,
		orthobottom = ORTHO_SIZE
	}

	render.PopRenderTarget()
	
	hook.Remove("HUDPaint", "GMCMinimapRenderer")
end)

local marker_types = {
	transport = Material("icon16/user_go.png"),
	fire = Material("icon16/house.png"),
	roofrescue = Material("icon16/building.png"),
	riot = Material("icon16/group_error.png")
}


function ENT:DrawMinimap(pnl, x, y, w, h)
	pnl:DrawRect(x, y, w, h, Color(255, 255, 255), Color(255, 255, 255))
	pnl:EnableRectStencil(x+1, y+1, w-2, h-2)

	local p = self:GetPos()
	local normalp = Vector(p.x / ORTHO_SIZE, p.y / ORTHO_SIZE, 0)

	local mapx, mapy, mapw, maph = x, y, w, h

	local zoom = self.MinimapZoom or 3.5
	mapx = mapx - w*(zoom-1)/2
	mapy = mapy - h*(zoom-1)/2
	mapw = mapw * zoom
	maph = maph * zoom

	mapx = mapx - normalp.x*mapw/2
	mapy = mapy + normalp.y*maph/2

	pnl:DrawMat(map_rt_mat, mapx, mapy, mapw, maph)

	local midx, midy = x + w/2, y + h/2

	for _,markers in pairs(gmc.mission.Markers) do
		for _,submarker in pairs(markers) do
			local icon = marker_types[submarker.type]
			local mx, my = midx + (submarker.pos.x - p.x) / ORTHO_SIZE * mapw/2, midy - (submarker.pos.y - p.y) / ORTHO_SIZE * maph/2

			pnl:DrawRect(mx - 6, my - 6, 12, 12, Color(255, 255, 255, 60), Color(0, 0, 0, 150))
			pnl:DrawMat(icon, mx - 4, my - 4, 8, 8)

			pnl:DrawLine(midx, midy, mx, my)
		end
	end

	pnl:DrawRect(midx - 2, midy - 2, 4, 4, Color(255, 0, 0))

	local ang = math.rad(-self:GetAngles().y)
	local radius = 10

	--[[local ang1 = ang-math.pi/2
	local ang2 = ang+math.pi/2

	local arrow_thickness = 1

	local arrow_poly = {
		{x = midx + math.cos(ang2)*arrow_thickness                       , y = midy + math.sin(ang2)*arrow_thickness},
		{x = midx + math.cos(ang1)*arrow_thickness                       , y = midy + math.sin(ang1)*arrow_thickness},
		{x = midx + math.cos(ang)*radius + math.cos(ang1)*arrow_thickness, y = midy + math.sin(ang)*radius + math.sin(ang1)*arrow_thickness},
		{x = midx + math.cos(ang)*radius + math.cos(ang2)*arrow_thickness, y = midy + math.sin(ang)*radius + math.sin(ang2)*arrow_thickness},
	}

	pnl:DrawPolygon(arrow_poly, Color(255, 0, 0))]]

	pnl:DrawLine(midx, midy, midx + math.cos(ang)*radius, midy + math.sin(ang)*radius, Color(255, 0, 0))

	pnl:DisableStencil()

	if pnl:Button("", "DermaDefaultBold", x, y+h-12, 12, 12, Color(0, 0, 0)) then
		self.MinimapZoom = (self.MinimapZoom or 3.5) + 0.5
	end
	pnl:Rect(x+1, y+h-7, 8, 2, Color(0, 0, 0))
	pnl:Rect(x+4, y+h-10, 2, 8, Color(0, 0, 0))
	if pnl:Button("", "DermaDefaultBold", x+w-12, y+h-12, 12, 12, Color(0, 0, 0)) then
		self.MinimapZoom = (self.MinimapZoom or 3.5) - 0.5
	end
	pnl:Rect(x+w-10, y+h-7, 8, 2, Color(0, 0, 0))
end

surface.CreateFont("GMCHeliRadioFont", {
	font = "Tahoma",
	size = 11
})

local refresh_panels = true
function ENT:DrawCopterHUD(ang)
	if LocalPlayer():GetHelicopter() ~= self then return end

	-- We only want to draw copter HUD to the main screen, not any sub rendertargets
	if IsValid(render.GetRenderTarget()) then return end

	do -- Main controls
		local p = self.MainP
		if not p or refresh_panels then p = tdui.Create() end
		self.MainP = p

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Forward() * 60.6 + ang:Up() * 73.3 - ang:Right() * 1.2
		ang:RotateAroundAxis(ang:Right(), -6)
		ang:RotateAroundAxis(ang:Forward(), 1)

		p:BeginRender(pos, ang, 0.1)

		p:DrawRect(-45, 0, 90, 215, _, Color(255, 255, 255))

		--[[p:Text("AirSpeed:" .. math.Round(self:GetVelocity():Length(), 2), "DermaDefault", 0, 25)
		p:Text("VSpeed:" .. math.Round(self:GetVelocity().z, 2), "DermaDefault", 0, 40)
		p:Text("Altitude:" .. math.Round(self:GetPos().z, 2), "DermaDefault", 0, 55)
		p:Text("Pitch:" .. math.Round(self:GetAngles().p, 2), "DermaDefault", 0, 70)
		p:Text("Roll:" .. math.Round(self:GetAngles().r, 2), "DermaDefault", 0, 85)]]

		self:DrawAttitudeIndicator(p, -38, 0, 35, 35)

		-- Altitude
		local alt = self:GetAltitude()
		self:DrawMeter(p, "ALT", 3, 0, 35, 35, math.rad((alt / 1000) * 360))
		p:DrawText(math.floor(alt / 1000), "DermaDefaultBold", 3+35/2, 20, Color(0, 0, 0))

		-- Speed
		local vel = self:GetVelocity():Length()
		vel = gmc.math.SourceUnitsToFeet(vel)
		vel = gmc.math.FeetToMeters(vel)
		vel = gmc.math.MPSToKnots(vel)

		self:DrawMeter(p, "KNOTS", -38, 38, 35, 35, math.rad((vel / 100) * 360))

		-- Angular deviation = deviation of velocity from forward dir
		local normvel = math.abs(((math.NormalizeAngle(self:GetVelocity():Angle().y)+180)/360) - ((math.NormalizeAngle(self:GetAngles().y)+180)/360))
		self:DrawMeter(p, "ANG DEV", 3, 38, 35, 35, math.rad(math.abs(normvel) * 360))

		local att = self:GetHeliAttachment("gmc_hc_attachment_watertanker")

		p:Rect(-40, 80, 80 * att:GetWaterStored(), 8, Color(0, 0, 255))
		p:Rect(-40, 80, 80, 8, Color(0, 0, 0, 0), Color(255, 255, 255))

		if p:DrawButton(att:GetLowered() and "Pull up" or "Lower", "DermaDefaultBold", -40, 90, 80, 20) then
			net.Start("GMCWaterTanker")
			net.WriteUInt(1, 8)
			net.SendToServer()
		end
		if p:DrawButton(att:GetSpraying() and "Stop spraying" or "Spray", "DermaDefaultBold", -40, 112, 80, 20) then
			net.Start("GMCWaterTanker")
			net.WriteUInt(2, 8)
			net.SendToServer()
		end

		p:DrawCursor()

		p:EndRender()
	end
	do -- Radio

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Forward() * 60.2 + ang:Up() * 77.4 - ang:Right() * 1.2
		local p = self.RadioP
		if not p or refresh_panels then p = tdui.Create() end
		self.RadioP = p

		p:BeginRender(pos, ang, 0.1)

		p:DrawRect(-30, 0, 60, 30, _, Color(255, 255, 255))

		p:DrawText("Radio", "GMCHeliRadioFont", 0, 2)

		local stations = gmc.radio.Stations

		local att = self:GetHeliAttachment("gmc_hc_attachment_radio")
		local station = stations[att:GetStationIndex()]

		if IsValid(att) and p:DrawButton(station and station.name or "Off", "GMCHeliRadioFont", -28, 13, 56, 15) then
			net.Start("GMCRadio")
			net.SendToServer()
		end

		p:DrawCursor()

		p:EndRender()
	end
	do -- Left monitor

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Forward() * 59 + ang:Up() * 65.4 - ang:Right() * 9.8
		ang:RotateAroundAxis(ang:Forward(), 1)
		ang:RotateAroundAxis(ang:Right(), -15)
		local p = self.RadioP
		if not p or refresh_panels then p = tdui.Create() end
		self.RadioP = p

		p:BeginRender(pos, ang, 0.1)

		self:DrawMinimap(p, -30, 0, 60, 60)

		p:Cursor()

		p:EndRender()
	end
	do -- Right monitor

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Forward() * 59 + ang:Up() * 65.4 + ang:Right() * 7
		
		ang:RotateAroundAxis(ang:Right(), -15)
		local p = self.RadioP
		if not p or refresh_panels then p = tdui.Create() end
		self.RadioP = p

		p:BeginRender(pos, ang, 0.1)

		p:Rect(-30, 0, 60, 60, _, Color(255, 255, 255))
		p:Cursor()

		p:EndRender()
	end
	do -- Top panel

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Forward() * 35 + ang:Up() * 90 + ang:Right() * 1
		ang:RotateAroundAxis(ang:Right(), 60)

		local p = self.RadioP
		if not p or refresh_panels then p = tdui.Create() end
		self.RadioP = p

		p:BeginRender(pos, ang, 0.1)

		p:Rect(-250, 0, 500, 50, _, Color(255, 255, 255))

		p:Cursor()

		p:EndRender()
	end

	refresh_panels = false
end

function ENT:Draw()
	self:DrawModel()

	self:DrawCopterHUD()
end

function ENT:DrawTranslucent()
	if self:IsEngineRunning() then
		self:DrawLightSprites()
	end
end

function ENT:Think()
	-- Smoke
	if self:GetEngineStartFrac() > 0 then
		self:SpawnLaunchSmoke()
	end

	-- Lights
	if self:IsEngineRunning() then

		for k,ml in pairs(self.MLights) do
			local meta = self.Lights[k]
			if ml.LastBlink < CurTime() - meta.BlinkRate then
				ml.LastBlink = CurTime()

				local dlight = ml.DLight
				if not dlight then
					ml.DLight = DynamicLight( 0 )
					dlight = ml.DLight
				end

				local pos = self:LocalToWorld(meta.Pos)

				dlight.Pos = pos
				dlight.r = 255
				dlight.g = 0
				dlight.b = 0
				dlight.Brightness = meta.Brightness
				dlight.Size = 128
				dlight.Decay = 75 / meta.Decay
				dlight.DieTime = CurTime() + meta.BlinkRate
				dlight.Style = 0

			end
		end
	end

	if self:IsEngineRunning() then
		if not self.MSounds.Engine:IsPlaying() then
			self.MSounds.Engine:Play()
			self.MSounds.Engine:ChangeVolume(0, 0)
			self.MSounds.Engine:ChangeVolume(1, 2)
		end

		if LocalPlayer():GetHelicopter() == self and GetConVar("gmc_camview"):GetInt() == GMC_CAMVIEW_FIRSTPERSON then
			self.MSounds.Engine:ChangeVolume(self.Sounds.Engine.VolInside, 0)
			self.MSounds.Engine:ChangePitch(self.Sounds.Engine.PitchInside * 100, 0)
		else
			self.MSounds.Engine:ChangeVolume(1, 0)
			self.MSounds.Engine:ChangePitch(100, 0)
		end

	elseif self.MSounds.Engine:IsPlaying() then
		if self:GetEngineStartFrac() > 0 then
			self.MSounds.Engine:ChangeVolume(self:GetEngineStartFrac(), 0)
		else
			self.MSounds.Engine:Stop()
		end
	end

	local RotorFrac = self:GetRotorFrac()
	if RotorFrac > 0.01 then
		if not self.MSounds.Blades:IsPlaying() then
			self.MSounds.Blades:Play()
		end
		if LocalPlayer():GetHelicopter() == self and GetConVar("gmc_camview"):GetInt() == GMC_CAMVIEW_FIRSTPERSON then
			self.MSounds.Blades:ChangeVolume(RotorFrac * 0.3, 0)
		else
			self.MSounds.Blades:ChangeVolume(RotorFrac, 0)
		end

	elseif self.MSounds.Blades:IsPlaying() then
		self.MSounds.Blades:Stop()
	end

	self:NextThink(CurTime() + 0.1)
	return true

end

local mat = Material("gmcopter/sprites/light") -- redglow1
function ENT:DrawLightSprites()
	for k,ml in pairs(self.MLights) do
		local meta = self.Lights[k]

		local timealive = CurTime() - ml.LastBlink
		local timefrac = timealive
		local fulltime = meta.Decay

		if timefrac < fulltime then
			local pos = self:LocalToWorld(meta.Pos)
			local alpha = (fulltime-timefrac) * 255 * meta.Brightness
			--MsgN(alpha)

			cam.Start3D(EyePos(), EyeAngles())
				render.SetMaterial(mat)
				render.DrawSprite(pos, 64, 64, Color(255, 0, 0, alpha))
			cam.End3D()
		end
	end
end

function ENT:SpawnLaunchSmoke()

	local vPoint = self:GetGroundHitPos()
	local dist = vPoint:Distance(self:GetPos())

	if not self:IsJustAboveGround() then
		return
	end

	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	effectdata:SetNormal(Vector(0, 0, 1))
	effectdata:SetScale(10)
	util.Effect( "ThumperDust", effectdata )

	--gmc.particles.Smokey(vPoint, Vector(math.random(), math.random(), 0) * math.Rand(-300, 300))

end

function ENT:OnRemove()
	for _,snd in pairs(self.MSounds) do
		snd:Stop()
	end
end
