AddCSLuaFile()

ENT.Base = "gmc_npc_base"

function ENT:BehaviourTick()
    if self.MissionObj then
        self.MissionObj.Tick(self)
    elseif self.WalkAroundTarg and self.WalkAroundTarg:Distance(self:GetPos()) > 150 then
        self:StartActivity(ACT_WALK)
        self.loco:SetDesiredSpeed(100)

        local s = self:MoveToPos(self.WalkAroundTarg, {tolerance = 150})
        if s == "ok" and self.WalkAroundTarg:Distance(self:GetPos()) < 200 then
            self.WalkAroundTarg = nil
            self.NextWalkAround = CurTime() + math.random(60, 600)
        end
    elseif self.NextWalkAround and self.NextWalkAround <= CurTime() then
        self.WalkAroundTarg = table.Random(gmcnpcs.POIs)
    else
        if not self.NextWalkAround then
            self.NextWalkAround = CurTime() + math.random(0, 600)
        end
        self:StartActivity(ACT_IDLE)
    end
end