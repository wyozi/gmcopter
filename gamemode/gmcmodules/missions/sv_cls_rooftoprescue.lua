local RooftopRescueMission = gmc.class("RooftopRescueMission", "Mission")

function RooftopRescueMission:think()
	local the_npc = self._npcs[1]
	if not the_npc:IsInHelicopter() then
		self:mark_pos("roofrescue", "target", the_npc:GetPos())
	end

	return 0.5
end

function RooftopRescueMission:npc_think(npc)
	if npc:IsInHelicopter() then
		local heli = npc:GetHelicopter()

		if heli:IsJustAboveGround() and heli:GetAltitude() < 500 then
			heli:LeaveHelicopter(npc)

			self:set_accomplished()
		end
	else
		local heli = npc:FindHelicopter()
		 
		if heli and heli:IsJustAboveGround() then
			if heli:GetPos():Distance(npc:GetPos()) > 150 then
				npc:StartActivity(ACT_WALK)
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
			else
				npc.loco:FaceTowards(heli:GetPos())
				coroutine.wait(0.5)
				heli:EnterHelicopter(npc)
			end
		end
	end

	
end