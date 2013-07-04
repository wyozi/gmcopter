
ENT.Type = "brush"
ENT.Base = "base_brush"


function ENT:GetTeleportEntity()

	if not self.OtherEdgeName then return end

	local entities = ents.FindByName(self.OtherEdgeName)
	if #entities > 0 then
		return table.Random(entities)
	end

end

function ENT:FindTeleportTarget(ent, heli)
	local mins = ent:LocalToWorld(ent:OBBMins())
	local maxs = ent:LocalToWorld(ent:OBBMaxs())

	local thebox = maxs - mins -- TODO something better..

	gmcdebug.Msg("Orig thebox vals: ", thebox, mins, maxs)

	thebox.x = thebox.x * 0.5
	thebox.y = thebox.y * 0.5
	thebox.z = heli:GetPos().z - mins.z

	local e = mins + thebox

	gmcdebug.Msg("Found teleport target ", heli:GetPos(), " --> ", e)

	return e

end

function ENT:StartTouch (ent)
	gmcdebug.Msg(ent, " hit map edge ", self)
	if ent.IsHelicopter and (not ent.LastMEdgeTele or ent.LastMEdgeTele < CurTime() - 2) then -- TODO more dynamic last tele check
		local tent = self:GetTeleportEntity()
		if IsValid(tent) then
			local oldvel = ent:GetVelocity()
			local oldvelnor = oldvel:GetNormalized()

			ent:SetPos(self:FindTeleportTarget(tent, ent))

			-- TODO do something with forcevelocity, addvelocity and mulvelocity

			ent.LastMEdgeTele = CurTime()
		end
	end
end

function ENT:KeyValue(key, value)
	if key == "otheredge" then
		self.OtherEdgeName = value
	elseif key == "forcevelocity" then
		self.ForceVel = gmcutils.ParseHammerVector(value)
	elseif key == "addvelocity" then
		self.AddVel = gmcutils.ParseHammerVector(value)
	elseif key == "mulvelocity" then
		self.MulVel = gmcutils.ParseHammerVector(value)
	end
end
