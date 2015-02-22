if SERVER then
	AddCSLuaFile()
end

ENT.Base = "gmc_npc_base"

function ENT:BehaviourTick()
    local heli = self:FindHelicopter()
    local IsInHeli = IsValid(self.InHeli)

    --gmc.debug.Msg(self:GetSequence())

    if not heli and not IsInHeli and self:GetSequence() ~= 626 then -- No idea where 626 is from. Some magic value for sit_ground sequence
        self:PlaySequenceAndWait( "idle_to_sit_ground" ) 
        self:SetSequence( "sit_ground" )
    end
     
    if heli and not IsInHeli then
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
            if not self.InHeli then
                --PrintTable(self:GetSequenceList())
                self:SetSequence("silo_sit")
                self:SetAngles(heli:GetAngles())
                self:SetPos(heli:GetPos() + heli:GetForward() * 34 + heli:GetUp() * 35 + heli:GetRight() * 15)
                self:SetParent(heli)
                self.InHeli = true
                -- TODO
            end
        end
    end
end