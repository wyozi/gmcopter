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
    else
        self:Idle()
    end
end

local idle_anims = {
    "idle_subtle", "LineIdle01", "LineIdle02", "LineIdle03"
}

function ENT:LookAt(pos)
    local angdiff = (pos - self:GetPos() + Vector(0, 0, 60)):Angle()
    self:SetPoseParameter("head_yaw", math.NormalizeAngle(angdiff.y))
    self:SetPoseParameter("head_pitch", math.Clamp(-math.NormalizeAngle(angdiff.p), -15, 15))
    self:SetEyeTarget(pos)
end

function ENT:Idle()
    local rand = math.random(1, 10)
    if rand == 2 then
    else
        self.IdleAnim = self.IdleAnim or table.Random(idle_anims)

        if math.random(1, 1000) == 1 then
            self.IdleAnim = table.Random(idle_anims)
        end

        self:SetSequence(self.IdleAnim)

        for _,e in pairs(ents.FindInSphere(self:GetPos(), 512)) do
            if e:GetVelocity():Length() > 50 then
                self:LookAt(e.EyePos and e:EyePos() or e:GetPos())
                break
            end
        end
    end

    coroutine.wait(0.1)--2 + math.random(0, 2))
end