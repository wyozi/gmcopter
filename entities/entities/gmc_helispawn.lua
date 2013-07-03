
ENT.Type = "brush"
ENT.Base = "base_brush"

function ENT:GetTeleportEntity()

	if not self.OtherEdgeName then return end

	local entities = ents.FindByName(self.OtherEdgeName)
	if #entities > 0 then
		return table.Random(entities)
	end

end

function ENT:FindTeleportTarget(ent)
	local mins = ent:LocalToWorld(ent:OBBMins())
	local maxs = ent:LocalToWorld(ent:OBBMaxs())

	local thebox = maxs - mins -- TODO something better..
	thebox.x = thebox.x * math.Rand(0, 1)
	thebox.y = thebox.y * math.Rand(0, 1)
	thebox.z = thebox.z * math.Rand(0, 1)

	return mins + thebox

end


local function VectorInside(vec, mins, maxs)
   return (vec.x > mins.x and vec.x < maxs.x
           and vec.y > mins.y and vec.y < maxs.y
           and vec.z > mins.z and vec.z < maxs.z)
end

function ENT:Think()
	local mins = self:LocalToWorld(self:OBBMins())
	local maxs = self:LocalToWorld(self:OBBMaxs())

	local hi = ents.FindInBox(mins, maxs)
	for i=1,#hi do
		local ent = hi[i]
		if ent.IsHelicopter and not ent:IsEngineRunning() and ent:HasBeenOn() then
			-- TODO we have landed
		end
	end
end

function ENT:StartTouch (ent)
	if ent.IsHelicopter then
		
	end
end

function ENT:KeyValue(key, value)
	if key == "helispawnid" then
		self.HeliSpawnId = value
	end
end