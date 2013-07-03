include("shared.lua")

function ENT:DrawCopterHUD(ang)

end

	

local sin,cos,rad = math.sin,math.cos,math.rad; --Only needed when you constantly calculate a new polygon, it slightly increases the speed.
local function GenerateCirclePoly(x,y,radius,quality)
    local circle = {};
    local tmp = 0;
    for i=1,quality do
        tmp = rad(i*360)/quality
        circle[i] = {x = x + cos(tmp)*radius,y = y + sin(tmp)*radius};
    end
    return circle;
end
 

GMCInstruments = {
	SupportingPitchAndBank = {
		draw = function(heli, x, y, scaleX, scaleY)
			-- TODO optimize
			surface.SetDrawColor(Color(0, 0, 255))
			surface.DrawPoly(GenerateCirclePoly(x+scaleX/2, y+scaleY/2, scaleX, 10))
		end
	}
}

function ENT:DrawInstrument(instr, x, y, scaleX, scaleY)
	GMCInstruments[instr].draw(self, x, y, scaleX, scaleY)
end

function ENT:Draw()
	self:DrawModel()

	local fwd = self:GetForward()
	local ri = self:GetRight()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ri, 90)
	ang:RotateAroundAxis(fwd, 90)

	self:DrawCopterHUD(ang, fwd, ri, self:GetUp())
	--MsgN("drawin")

	--[[
	local particle = self.Emitter:Add("sprites/heatwave",self:GetPos())
	particle:SetVelocity(self:GetVelocity()+self:GetForward()*-100)
	particle:SetDieTime(0.1)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(40)
	particle:SetEndSize(20)
	particle:SetColor(255,255,255)
	particle:SetRoll(math.Rand(-50,50))
	self.Emitter:Finish()]] 

end


function ENT:DrawCopterHUD(ang, fwd, ri, up)

	ang:RotateAroundAxis(ri, -6)

	cam.Start3D2D(self:LocalToWorld(self.Seats[1].Pos + Vector(40.2,3.75,37.75)), ang, 0.015)

	surface.SetDrawColor(Color(255, 0, 0, 255))
	surface.DrawOutlinedRect(870, 900, 590, 1000)

	self:DrawInstrument("SupportingPitchAndBank", 970, 935, 110, 110)

	cam.End3D2D()

end

function ENT:Think()
	self:SpawnLaunchSmoke()
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
    		
	    	local targ = heli:GetPos() - (hang:Forward()*400) + (hang:Up() * 250)
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