local TransportMission = gmc.class("TransportMission", "Mission")

function TransportMission:npc_think(npc)
	-- TODO find heli from mission helis, not all of them
	local heli = npc:FindHelicopter()

	if not heli and not npc:IsInHelicopter() and npc:GetSequence() ~= 626 then -- No idea where 626 is from. Some magic value for sit_ground sequence
		npc:PlaySequenceAndWait( "idle_to_sit_ground" ) 
		npc:SetSequence( "sit_ground" )
	end
	 
	if heli and not npc:IsInHelicopter() and heli:IsJustAboveGround() then
		if heli:GetPos():Distance(npc:GetPos()) > 150 then
			if npc:GetSequence() == 626 then
				npc:PlayScene( "scenes/npc/female01/finally.vcd" )
				npc:PlaySequenceAndWait( "sit_ground_to_idle" )
			end

			npc:StartActivity( ACT_WALK )
			npc.loco:SetDesiredSpeed( 100 )
			npc:MoveToPos(heli:GetPos(), {repath=0.5, tolerance=150})
			npc.loco:FaceTowards(heli:GetPos())
			npc:StartActivity( ACT_IDLE ) 
			coroutine.wait(0.25)
		else
			heli:EnterHelicopter(npc)
			coroutine.wait(1)
		end
	end

	if npc:IsInHelicopter() and npc:GetHelicopter():IsJustAboveGround() then
		npc:GetHelicopter():LeaveHelicopter(npc)

		self:set_accomplished()
	end
end