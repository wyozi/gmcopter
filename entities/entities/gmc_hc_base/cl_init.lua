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

function ENT:DrawMeter(pnl, x, y, w, h, ang)
	pnl:DrawRect(x, y, w, h, Color(255, 255, 255))

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

hook.Add("HUDPaint", "GMCMinimapRenderer", function()
	
	render.PushRenderTarget(map_rt)

	local ortho = 13000
	render.RenderView {
		origin = Vector(0, 0, 2722.4045),
		angles = Angle(90, 90, 0),
		x = 0,
		y = 0,
		w = 1024,
		h = 1024,
		ortho = true,
		ortholeft = -ortho,
		orthoright = ortho,
		orthotop = -ortho,
		orthobottom = ortho
	}

	render.PopRenderTarget()
	
	hook.Remove("HUDPaint", "GMCMinimapRenderer")
end)

local marker_types = {
	transport = Material("icon16/user_go.png")
}


function ENT:DrawMinimap(pnl, x, y, w, h)
	pnl:DrawRect(x, y, w, h, Color(255, 255, 255), Color(255, 255, 255))
	pnl:EnableRectStencil(x+1, y+1, w-2, h-2)

	local p = self:GetPos()
	local normalp = Vector(p.x / 13000, p.y / 13000, 0)

	local mapx, mapy, mapw, maph = x, y, w, h

	local zoom = 3.5
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
			local mx, my = midx + (submarker.pos.x - p.x) / 13000 * mapw/2, midy - (submarker.pos.y - p.y) / 13000 * maph/2

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
end

ENT.RadioStations = {
	{
		name = "Smooth jazz",
		url = "http://listen.sky.fm/public3/uptemposmoothjazz.pls"
	},
	{
		name = "Classic rap",
		url = "http://listen.sky.fm/public3/classicrap.pls"
	},
}

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
		local alt = self:GetPos().z + 12800
		self:DrawMeter(p, 3, 0, 35, 35, math.rad((alt / 5000) * 360))

		-- Speed
		self:DrawMeter(p, -38, 38, 35, 35, math.rad((self:GetVelocity():Length() / 1000) * 360))

		--self:DrawMeter(p, 3, 38, 35, 35)
		
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

		local station = self.RadioStations[self.RadioStationIdx or 0]
		if p:DrawButton(station and station.name or "Off", "GMCHeliRadioFont", -28, 13, 56, 15) then
			-- Stop old channel
			if IsValid(self.RadioStationObj) then
				self.RadioStationObj:Stop()
			end

			self.RadioStationIdx = (self.RadioStationIdx or 0)
			self.RadioStationIdx = (self.RadioStationIdx + 1) % (#self.RadioStations + 1)

			local idx = self.RadioStationIdx
			station = self.RadioStations[self.RadioStationIdx]

			if station then
				sound.PlayURL(station.url, "noplay", function(chan)
					-- check if station was changed during loading
					if self.RadioStationIdx ~= idx then
						return
					end

					chan:Play()
					self.RadioStationObj = chan
				end)
			end
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

		if LocalPlayer():GetHelicopter() == self then
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
		if LocalPlayer():GetHelicopter() == self then
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
