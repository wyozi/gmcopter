if SERVER then
	AddCSLuaFile()
end

ENT.Base = "gmc_npc_base"

function ENT:FindHelicopter()
	local heli
	for _,ent in pairs(ents.FindInSphere(self:GetPos(), 1000)) do
		if ent.IsHelicopter then
			heli = ent
		end
	end
	return heli
end

function ENT:RunBehaviour()
    while ( true ) do

    	local heli = self:FindHelicopter()
    	if heli and heli:GetPos():Distance(self:GetPos()) > 200 then
    		self:StartActivity( ACT_WALK )                            -- walk anims
	        self.loco:SetDesiredSpeed( 100 )                        -- walk speeds
	        self:PlayScene( "scenes/npc/female01/finally.vcd" )
	        self:MoveToPos( heli:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)
	        self.loco:FaceTowards(heli:GetPos())
	        self:StartActivity( ACT_IDLE )  
    	end

        coroutine.yield()
    end
end