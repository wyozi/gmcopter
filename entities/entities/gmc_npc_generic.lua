AddCSLuaFile()

ENT.Base = "gmc_npc_base"

AccessorFunc(ENT, "mission", "Mission")

function ENT:BehaviourTick()
    local mission = self:GetMission()
    if mission and mission:is_in_progress() then
        mission:npc_think(self)
    elseif self.WalkAroundTarg and self.WalkAroundTarg:Distance(self:GetPos()) > 150 then
        self:StartActivity(ACT_WALK)
        self.loco:SetDesiredSpeed(100)

        local s = self:MoveToPos(self.WalkAroundTarg, {
            tolerance = 150,
            terminate_condition = function()
                local mission = self:GetMission()
                return mission and mission:is_in_progress()
            end
        })
        if s == "ok" and self.WalkAroundTarg:Distance(self:GetPos()) < 200 then
            self.WalkAroundTarg = nil
            self.NextWalkAround = CurTime() + math.random(60, 600)
        end
    elseif self.NextWalkAround and self.NextWalkAround <= CurTime() then
        self.WalkAroundTarg = table.Random(gmc.npcs.POIs)
    else
        if not self.NextWalkAround then
            self.NextWalkAround = CurTime() + math.random(0, 600)
        end
        self:StartActivity(ACT_IDLE)
    end
end