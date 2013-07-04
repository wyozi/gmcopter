local meta = FindMetaTable("Vector")

function meta:AddX(v)
	self.x = self.x + v
end

function meta:AddY(v)
	self.y = self.y + v
end

function meta:AddZ(v)
	self.z = self.z + v
end

function meta:Add(v)
	self:AddX(v.x)
	self:AddY(v.y)
	self:AddZ(v.z)
end

function meta:ClampX(min, max)
	self.x = math.Clamp(self.x, min, max)
end

function meta:ClampY(min, max)
	self.y = math.Clamp(self.y, min, max)
end

function meta:ClampZ(min, max)
	self.z = math.Clamp(self.z, min, max)
end

function meta:SetX(x)
	self.x = x
end

function meta:SetY(x)
	self.y = x
end

function meta:SetZ(x)
	self.z = x
end

local angmeta = FindMetaTable("Angle")

-- Returns angle with only yaw of self
function angmeta:OnlyYaw()
	return Angle(0, self.y, 0)
end

function angmeta:IsPitchWithin(min, max)
	return self.p > min and self.p < max
end

function angmeta:IsYawWithin(min, max)
	return self.y > min and self.y < max
end

function angmeta:IsRollWithin(min, max)
	return self.r > min and self.r < max
end