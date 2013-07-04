if SERVER then
	AddCSLuaFile()
end

ENT.Base = "gmc_npc_base"

function ENT:RunBehaviour()
    while ( true ) do

    	local heli = self:FindHelicopter()
    	local IsInHeli = IsValid(self.InHeli)

    	--gmcdebug.Msg(self:GetSequence())

    	if not heli and not IsInHeli and self:GetSequence() ~= 626 then -- No idea where 626 is from. Some magic value for sit_ground sequence
    		self:PlaySequenceAndWait( "idle_to_sit_ground" ) 
        	self:SetSequence( "sit_ground" )
    	end
    	 
    	if heli and not IsInHeli then
    		if heli:GetPos():Distance(self:GetPos()) > 200 then
		        self:PlayScene( "scenes/npc/female01/finally.vcd" )
        		self:PlaySequenceAndWait( "sit_ground_to_idle" )                            -- Get up
	    		self:StartActivity( ACT_WALK )                            -- walk anims
		        self.loco:SetDesiredSpeed( 100 )                        -- walk speeds
		        self:MoveToPos( heli:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)
		        self.loco:FaceTowards(heli:GetPos())
		        self:StartActivity( ACT_IDLE )  
		    else
		    	--self.loco:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER )
		    	if not self.InHeli then
		    		local freeseat = heli:GetFreeSeatIdx(true)
			    	if freeseat then
			    		local seatent = heli:GetSeatIdx(freeseat)
			    		if self:EnterHelicopter(heli, seatent) then
				    		self:StartActivity(  ACT_BUSY_SIT_CHAIR  )
				    		self:SetNoDraw(true)

				    		gmcdebug.CMsg("Rollercoastering!")

			    		end
			    	else
			    		gmcdebug.CMsg("No free seats!")
			    	end
		    	end
		    end
    	end
        coroutine.yield()
    end
end