include("shared.lua")

ENT.RenderGroup = RENDERGROUP_BOTH

--http://en.wikipedia.org/wiki/Attitude_indicator
function ENT:DrawAttitudeIndicator(pnl, x, y, w, h)
	pnl:Rect(x, y, w, h, Color(255, 255, 255))

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

	pnl:Polygon(ground_poly, Color(139, 69, 19))

	local sky_poly = {
		{x = x, y = y},
		{x = x+w, y = y},
		{x = x+w, y = midy+math.sin(math.rad(c2ang))*15-1 + yoff},
		{x = x, y = midy+math.sin(math.rad(c1ang))*15-1 + yoff},
	}

	pnl:Polygon(sky_poly, Color(25, 181, 254))

	--pnl:Rect(midx+math.cos(math.rad(c1ang))*15-1, midy+math.sin(math.rad(c1ang))*15-1 + yoff, 2, 2, Color(255, 0, 0))
	--pnl:Rect(midx+math.cos(math.rad(c2ang))*15-1, midy+math.sin(math.rad(c2ang))*15-1 + yoff, 2, 2, Color(255, 0, 0))
end

function ENT:DrawCopterHUD(ang)
	do -- Main controls
		local p = self.MainP or tdui.Create()
		self.MainP = p

		p:Rect(-45, 0, 90, 215, _, Color(255, 255, 255))

		p:Text("Hello there!", "DermaDefaultBold", 0, 5)

		p:Text("AirSpeed:" .. math.Round(self:GetVelocity():Length(), 2), "DermaDefault", 0, 25)
		p:Text("VSpeed:" .. math.Round(self:GetVelocity().z, 2), "DermaDefault", 0, 40)
		p:Text("Altitude:" .. math.Round(self:GetPos().z, 2), "DermaDefault", 0, 55)
		p:Text("Pitch:" .. math.Round(self:GetAngles().p, 2), "DermaDefault", 0, 70)
		p:Text("Roll:" .. math.Round(self:GetAngles().r, 2), "DermaDefault", 0, 85)

		self:DrawAttitudeIndicator(p, -38, 0, 35, 35)

		p:Cursor()

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Forward() * 60.6 + ang:Up() * 73.3 - ang:Right() * 1.2
		ang:RotateAroundAxis(ang:Right(), -6)
		ang:RotateAroundAxis(ang:Forward(), 1)
		p:Render(pos, ang, 0.1)
	end
	do -- Radio
		local p = self.RadioP or tdui.Create()
		self.RadioP = p

		p:Rect(-30, 0, 60, 30, _, Color(255, 255, 255))

		p:Text("Dubstep", "DermaDefault", 0, 5)

		p:Cursor()

		local pos = self:GetPos()
		local ang = self:GetAngles()

		pos = pos + ang:Forward() * 60.2 + ang:Up() * 77.4 - ang:Right() * 1.2
		--ang:RotateAroundAxis(ang:Forward(), 1)
		p:Render(pos, ang, 0.1)
	end
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

	--gmcparticles.Smokey(vPoint, Vector(math.random(), math.random(), 0) * math.Rand(-300, 300))

end

function ENT:OnRemove()
	for _,snd in pairs(self.MSounds) do
		snd:Stop()
	end
end
