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

function meta:ClampX(min, max)
	self.x = math.Clamp(self.x, min, max)
end

function meta:ClampY(min, max)
	self.y = math.Clamp(self.y, min, max)
end

function meta:ClampZ(min, max)
	self.z = math.Clamp(self.z, min, max)
end