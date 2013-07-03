
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

function ENT:StartTouch (ent)
	if ent.IsHelicopter and (not ent.LastMEdgeTele or ent.LastMEdgeTele > CurTime() - 2) then -- TODO more dynamic last tele check
		local tent = self:GetTeleportEntity()
		if IsValid(tent) then
			ent:SetPos(self:FindTeleportTarget(tent))
			ent.LastMEdgeTele = CurTime()
		end
	end
end

function ENT:KeyValue(key, value)
	if key == "otheredge" then
		self.OtherEdgeName = value
	end
end
