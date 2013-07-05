
AddCSLuaFile()

ENT.Model = Model("models/props_lab/reciever_cart.mdl") 

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then
	
	function ENT:Initialize()
		self:SetModel(self.Model)

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetUseType(SIMPLE_USE)

		self.HeliSpawns = self:GetHeliSpawns()

	end

	function ENT:GetHeliSpawns()
		if not self.HeliSpawnId then
			return
		end
		local helispawns = ents.FindByClass("gmc_helispawn")
		local rets = {}
		for _,hs in pairs(helispawns) do
			if hs.HeliSpawnId == self.HeliSpawnId then
				table.insert(rets, hs)
			end
		end
		return rets
	end

	function ENT:Use(activator)
		if not self.HeliSpawns then
			MsgN("!!!! NO SELF.HELISPAWNS FOUND")
			return
		end
		local HeliSize = Vector(370, 370, 130) -- TODO get proper size
		local SpawnZone = table.Random(self.HeliSpawns)
		local EmptyMins, EmptyMaxs = gmcutils.FindEmptySpaceInside(SpawnZone:LocalToWorld(SpawnZone:OBBMins()), SpawnZone:LocalToWorld(SpawnZone:OBBMaxs()), HeliSize, 1, {SpawnZone})
		if EmptyMins then
			gmcdebug.Msg("Found spawn pos! " , EmptyMins, EmptyMaxs)

			local SpawnPos = EmptyMins + HeliSize*0.5
			SpawnPos.z = EmptyMins.z + 10

			local ent = ents.Create("gmc_hc_base")
			ent.Owner = activator
			ent:SetPos(SpawnPos)
			ent:Spawn()
			ent:Activate()

			do
				local att = ents.Create("gmc_hc_attachment_light")
				ent:HeliAttach(att)
				att:Spawn()
			end

			do
				local att = ents.Create("gmc_hc_attachment_camera")
				ent:HeliAttach(att)
				att:Spawn()
			end

			do
				local att = ents.Create("gmc_hc_attachment_minimap")
				ent:HeliAttach(att)
				att:Spawn()
			end

		else
			gmcdebug.Msg("No spawn pos found :(")
		end
	end

	function ENT:KeyValue(key, value)
		if key == "helispawnid" then
			self.HeliSpawnId = value
		end
	end

end

--[[hook.Add("PostDrawTranslucentRenderables", "lel", function()
	local HeliSize = Vector(330, 130, 130) -- TODO get proper size
	local SpawnZoneMins, SpawnZoneMaxs = Vector(-2049.000000, -5889.000000, 63.000000), Vector(-639.000000, -5119.000000, 209.000000)
	local EmptyMins, EmptyMaxs = gmcutils.DrawSpottests(SpawnZoneMins, SpawnZoneMaxs, HeliSize, 1)
end)]]