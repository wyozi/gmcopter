local BuildingFireMission = gmc.class("BuildingFireMission", "Mission")

local ceilings = {
	{
		Pos1 = Vector(4196.797363, -4162.784668, -7551.968750),
		Pos2 = Vector(5656.484375, -5175.751465, -7551.968750),
	}
}

function BuildingFireMission:on_start()
	self.ceiling = table.Random(ceilings)
	self.fires = {}

	for i=1,30 do
		local diff = self.ceiling.Pos2 - self.ceiling.Pos1
		local p = self.ceiling.Pos1 + Vector(math.random(0, diff.x), math.random(0, diff.y), math.random(0, diff.z))

		local fire = ents.Create("env_fire")
		if not IsValid(fire) then return end

		fire:SetPos(p)
		--no glow + delete when out + start on + last forever
		fire:SetKeyValue("spawnflags", tostring(128 + 32 + 4 + 2 + 1))
		fire:SetKeyValue("firesize", 512)
		fire:SetKeyValue("fireattack", 1)
		fire:SetKeyValue("health", 100)
		fire:SetKeyValue("damagescale", "-10") -- only neg. value prevents dmg

		fire:Spawn()
		fire:Activate()

		table.insert(self.fires, fire)
	end
end

function BuildingFireMission:think()
	self:mark_pos("fire", "fire", self.ceiling.Pos1)

	local valid_f = false
	for _,f in pairs(self.fires) do
		if IsValid(f) then
			valid_f = true
			break
		end
	end

	if not valid_f then
		self:set_accomplished()
	end

	return 0.5
end