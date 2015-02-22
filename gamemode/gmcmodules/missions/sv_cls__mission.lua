local Mission = gmc.class("Mission")

function Mission:initialize()
	self.plys = {}
	self.npcs = {}
end

function Mission:add_player(ply)
	table.insert(self.plys, ply)
end

function Mission:add_npc(npc)
	table.insert(self.npcs, npc)
	npc:SetMission(self)
end

function Mission:npc_think(npc)
end

function Mission:is_in_progress()
	return self.state == "inprog"
end

function Mission:start()
	self.state = "inprog"

	timer.Create("MissionHighlighter", 0.2, 0, function()
		if not self:is_in_progress() or self.npcs[1]:IsInHelicopter() then hook.Remove("Think", "MissionHighlighter") return end

		net.Start("PosHighlighter") net.WriteVector(self.npcs[1]:GetPos()) net.Send(self.plys[1])
	end)
end

function Mission:set_accomplished()
	self.state = "done"
end

function Mission:set_failed()
	self.state = "failed"
end