local TransportMission = gmc.class("TransportMission", "Mission")

function TransportMission:on_start()
	self.targetPOI = table.Random(gmc.npcs.POIs)
end

function TransportMission:think()
	local the_npc = self._npcs[1]
	if the_npc:IsInHelicopter() then
		self:mark_pos("transport", "target", self.targetPOI)
	else
		self:mark_pos("transport", "target", the_npc:GetPos())
	end

	return 0.5
end

function TransportMission:npc_think(npc)
	-- TODO find heli from mission helis, not all of them
	local heli = npc:FindHelicopter()
	 
	if heli and not npc:IsInHelicopter() and heli:IsJustAboveGround() then
		if heli:GetPos():Distance(npc:GetPos()) > 150 then
			if npc:GetSequence() == 626 then
				npc:PlayScene( "scenes/npc/female01/finally.vcd" )
				npc:PlaySequenceAndWait( "sit_ground_to_idle" )
			end

			npc:StartActivity( ACT_WALK )
			npc.loco:SetDesiredSpeed( 100 )

			local oldhelipos = heli:GetPos()
			local moved = npc:MoveToPos(oldhelipos, {
				repath=0.5,
				tolerance=150,
				terminate_condition = function()
					return IsValid(heli) and heli:GetPos():Distance(oldhelipos) >= 150
				end
			})
			npc:StartActivity(ACT_IDLE) 

			if moved == "ok" then
				npc.loco:FaceTowards(heli:GetPos())
				coroutine.wait(0.25)
			end
		else
			heli:EnterHelicopter(npc)
			coroutine.wait(1)
		end
	end

	if npc:IsInHelicopter() and npc:GetHelicopter():IsJustAboveGround() and npc:GetHelicopter():GetPos():Distance(self.targetPOI) < 400 then
		npc:GetHelicopter():LeaveHelicopter(npc)

		self:set_accomplished()
	end
end