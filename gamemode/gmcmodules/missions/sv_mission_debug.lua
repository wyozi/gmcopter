util.AddNetworkString("PosHighlighter")
concommand.Add("mission", function(ply)
	local rand_npc = table.Random(ents.FindByClass("gmc_npc_generic"))
	local rand_poi = table.Random(gmcnpcs.POIs)

	hook.Add("Think", "MissionHighlighter", function()
		if not IsValid(rand_npc) then hook.Remove("Think", "MissionHighlighter") return end

		if not IsValid(rand_npc.InHeli) then
			net.Start("PosHighlighter") net.WriteVector(rand_npc:GetPos()) net.Send(ply)
		else
			net.Start("PosHighlighter") net.WriteVector(rand_poi) net.Send(ply)
		end
	end)

	rand_npc.MissionObj = {
		Tick = function(self)
			local heli = self:FindHelicopter()
		    local IsInHeli = IsValid(self.InHeli)

		    --gmcdebug.Msg(self:GetSequence())

		    if not heli and not IsInHeli and self:GetSequence() ~= 626 then -- No idea where 626 is from. Some magic value for sit_ground sequence
		        self:PlaySequenceAndWait( "idle_to_sit_ground" ) 
		        self:SetSequence( "sit_ground" )
		    end
		     
		    if heli and not IsInHeli and heli:IsJustAboveGround() then
		        if heli:GetPos():Distance(self:GetPos()) > 150 then
		            if self:GetSequence() == 626 then
		                self:PlayScene( "scenes/npc/female01/finally.vcd" )
		                self:PlaySequenceAndWait( "sit_ground_to_idle" )
		            end

		            self:StartActivity( ACT_WALK )
		            self.loco:SetDesiredSpeed( 100 )
		            self:MoveToPos(heli:GetPos(), {repath=0.5, tolerance=150})
		            self.loco:FaceTowards(heli:GetPos())
		            self:StartActivity( ACT_IDLE ) 
		            coroutine.wait(0.5)
		        else
	                self:SetSequence("silo_sit")
	                self:SetAngles(heli:GetAngles())
	                self:SetPos(heli:GetPos() + heli:GetForward() * 34 + heli:GetUp() * 35 + heli:GetRight() * 15)
	                self:SetMoveType(MOVETYPE_NONE)
	                self:SetParent(heli)
	                self.InHeli = heli
		        end
		    end

        	if IsValid(self.InHeli) and self.InHeli:IsJustAboveGround() and self.InHeli:GetPos():Distance(rand_poi) < 400 then
        		self:SetParent(nil)
        		self:SetPos(self.InHeli:GetPos() + self.InHeli:GetRight() * 150)

        		self:StartActivity(ACT_IDLE)
        		self:SetMoveType(MOVETYPE_PUSH)

        		rand_npc.MissionObj = nil
        	end
		end,
	}
end)