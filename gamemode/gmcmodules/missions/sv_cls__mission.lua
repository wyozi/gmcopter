local Mission = gmc.class("Mission")

function Mission:initialize()
	self._id = UUID()

	self._plys = {}
	self._npcs = {}
	self._state = "awaiting"
end

function Mission:_hookname(nm)
	return "GMCMission" .. nm .. "." .. self._id
end

function Mission:add_player(ply)
	table.insert(self._plys, ply)
end

function Mission:add_npc(npc)
	table.insert(self._npcs, npc)
	npc:SetMission(self)
end

function Mission:is_in_progress()
	return self._state == "inprog"
end

util.AddNetworkString("GMCMissionCleanup")

function Mission:set_accomplished()
	self._state = "done"

	self:finished()
end

function Mission:set_failed()
	self._state = "failed"

	self:finished()
end

function Mission:finished()
	timer.Destroy(self:_hookname("Think"))

	net.Start("GMCMissionCleanup")
	net.WriteString(self._id)
	net.Send(self._plys)

	if self._state == "done" then
		for _,p in pairs(self._plys) do
			p:SendLua("simcopter.PlaySoundChain(simcopter.SoundMap.CDisp.thxforhelp)")
		end
	end
end

util.AddNetworkString("GMCMissionUpdate")
function Mission:send_full_upd(ply)
	local upd = {
		id = self._id,
		plys = self._plys,
		npcs = self._npcs
	}

	net.Start("GMCMissionUpdate")
	net.WriteTable(upd)
	net.Send(ply)
end

util.AddNetworkString("GMCMissionMarker")
function Mission:mark_pos(marker_type, marker_id, pos)
	net.Start("GMCMissionMarker")
	net.WriteString(self._id)
	net.WriteString(marker_type)
	net.WriteString(marker_id)
	net.WriteVector(pos)
	net.Send(self._plys)
end

function Mission:start()
	self._state = "inprog"

	self:on_start()

	local function TimerFunc()
		local t = self:think()
		if t then
			timer.Adjust(self:_hookname("Think"), t, 0, TimerFunc)
		end
	end
	timer.Create(self:_hookname("Think"), 0.1, 0, TimerFunc)

	for _,ply in pairs(self._plys) do
		self:send_full_upd(ply)
	end
end

function Mission:on_start()
end

function Mission:think()
end

function Mission:npc_think(npc)
end
