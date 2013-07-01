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
end