include("shared.lua")

function ENT:DrawCopterHUD(ang)

end


function ENT:Draw()
	self:DrawModel()

	local fwd = self:GetForward()
	local ri = self:GetRight()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ri, 90)
	ang:RotateAroundAxis(fwd, 90)

	self:DrawCopterHUD(ang, fwd, ri, self:GetUp())

end

function ENT:Think()
	self:SpawnLaunchSmoke()

	--[[ TODO

	for k,ml in pairs(self.MLights) do
		local meta = self.Lights[k]
		if ml.LastBlink < CurTime() - meta.BlinkRate then
			-- Blink()
			--MsgN("Blink()")
			ml.LastBlink = CurTime()

			local dlight = ml.DLight
			if not dlight then
				ml.DLight = DynamicLight( 0 )
				dlight = ml.DLight
			end

			--MsgN(self:LocalToWorld(meta.Pos))
			dlight.Pos = self:LocalToWorld(meta.Pos)
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.Brightness = 1
			dlight.Size = 128
			dlight.Decay = 128 * 3
			dlight.DieTime = CurTime() + 1
            dlight.Style = 0

		end
	end]]

end

function ENT:SpawnLaunchSmoke()

	if not self:IsEngineRunning() then return end

	local vPoint = self:GetGroundHitPos()
	local dist = vPoint:Distance(self:GetPos())

	if dist > 250 then
		return
	end

	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	effectdata:SetNormal(Vector(0, 0, 1))
	effectdata:SetScale(10)
	util.Effect( "ThumperDust", effectdata )	
 
end

hook.Add("CalcView", "CalcHeliView", function(ply, pos, angles, fov)
    local heli = ply:GetHelicopter()
    if IsValid(heli) then
		local camview = GetConVar("gmc_camview"):GetInt()
    	if camview == GMC_CAMVIEW_CHASE then
    		local view = {}
	    	local hang = heli:GetAngles()

	    	local targ = heli:GetPos() - (hang:Forward()*400) + (hang:Up() * 250)
	    	local tr = util.TraceLine({start=heli:GetPos(), endpos=targ, filter={heli, ply, heli:GetNWEntity("trotor"), heli:GetNWEntity("brotor")}})
		    view.origin = tr.Hit and tr.HitPos or targ
		    view.angles = tr.Hit and (heli:GetPos() - view.origin):Angle() or hang

		    view.angles.p = 32
		    view.angles.r = 0 -- Looks better this way

		    view.fov = fov
		 
		    return view
		elseif camview == GMC_CAMVIEW_THIRDPERSON then
    		local view = {}
    		local hang = angles

	    	local targ = heli:GetPos() - (hang:Forward()*500)
	    	local tr = util.TraceLine({start=heli:GetPos(), endpos=targ, filter={heli, ply, heli:GetNWEntity("trotor"), heli:GetNWEntity("brotor")}})
		    view.origin = tr.Hit and tr.HitPos or targ
		    view.angles = angles
		    view.fov = fov
		 
		    return view
		elseif camview == GMC_CAMVIEW_COCKPIT then
    		local view = {}
	    	local hang = heli:GetAngles()
		    view.origin = heli:GetPos() + (hang:Up() * 50) + (hang:Forward() * 100)
		    view.angles = heli:GetAngles() --(heli:GetPos() - view.origin):Angle()
		    view.fov = fov
		 
		    return view
    	end
    end
end)