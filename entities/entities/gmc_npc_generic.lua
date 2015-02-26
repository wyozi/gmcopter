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

    local yaw = math.NormalizeAngle(angdiff.y - self:GetAngles().y)

    if math.abs(yaw) > 60 then
        self.loco:FaceTowards(pos)
    end
    self:SetPoseParameter("head_yaw", yaw)

    local pitch = math.Clamp(-math.NormalizeAngle(angdiff.p), -15, 15)
    self:SetPoseParameter("head_pitch", pitch)

    self:SetEyeTarget(pos)
end

local rand_lines = {
    "vquestion01",
    "vquestion02",
    "vquestion03",
    "vquestion04",
    "vquestion05",
    "vquestion06",
    "vquestion07",

    "vanswer01",
    "vanswer02",
    "vanswer03",
    "vanswer04",
}

function ENT:Idle()
    local rand = math.random(1, 10)
    if rand == 2 then
    else
        self.IdleAnim = self.IdleAnim or table.Random(idle_anims)

        if math.random(1, 1000) == 2 then
            self.IdleAnim = table.Random(idle_anims)
        end

        self:SetSequence(self.IdleAnim)

        local possible_ents = ents.FindInSphere(self:GetPos(), 512)
        possible_ents = gmc.utils.FilterTable(possible_ents, function(e)
            return e:IsPlayer() or e.IsGMCNPC or e.IsHelicopter
        end)

        table.sort(possible_ents, function(a, b)
            if a:IsPlayer() and not b:IsPlayer() then return true end
            if b:IsPlayer() and not a:IsPlayer() then return false end

            local veldiff = (a:GetVelocity() - b:GetVelocity()):Length()
            if math.abs(veldiff) > 10 then return veldiff < 0 end

            return a:GetPos():Distance(b:GetPos()) < 0
        end)

        local e = possible_ents[1]
        if IsValid(e) then
            self:LookAt(e.EyePos and e:EyePos() or e:GetPos())

            if e:GetVelocity():Length() > 20 and math.random(1, 20) == 2 then
                self:EmitSound(string.format("vo/npc/%smale01/hi0%d.wav", self:IsMale() and "" or "fe", math.random(1, 2)))
            end

            if e.IsGMCNPC and math.random(1, 100) == 2 then
                self:EmitSound(string.format("vo/npc/%smale01/%s.wav", self:IsMale() and "" or "fe", table.Random(rand_lines)))
            end
        end
    end

    coroutine.wait(0.1)--2 + math.random(0, 2))
end