local RiotControlMission = gmc.class("RiotControlMission", "Mission")

function RiotControlMission:on_start()

	for i,n in pairs(self._npcs) do
		local xa, ya = math.cos(math.pi*2/#self._npcs * i) * 100, math.sin(math.pi*2/#self._npcs * i) * 100
		n:SetPos(self.targetPOI + Vector(xa, ya, 50))

		n._RiotControlWatered = false
	end

	self.riotLeader = table.Random(self._npcs)
	self:mark_pos("riot", "target", self.targetPOI)
end

function RiotControlMission:think()
	self.NPCPackTick = self.NPCPackTick == 1 and 0 or 1

	local allWatered = true
	for _,n in pairs(self._npcs) do
		if not n._RiotControlWatered then
			allWatered = false
			break
		end
	end

	if allWatered then
		self:set_accomplished()
	end
	return 2.5
end

function RiotControlMission:npc_think(npc)
	if npc._RiotControlWatered then
		npc:SetSequence("cower")
		return
	end
	if npc._PackTick == self.NPCPackTick then return end

    if (self.NPCPackTick == 1 and npc ~= self.riotLeader) or npc == self.riotLeader then
		npc:EmitSound("vo/npc/male01/squad_follow02.wav")
        npc:PlaySequenceAndWait("Wave")
	end

	npc._PackTick = self.NPCPackTick
end

function RiotControlMission:handle_npc_watered(npc, heli)
	npc._RiotControlWatered = true
end