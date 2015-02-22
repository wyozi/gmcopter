if SERVER then
	AddCSLuaFile()
end

AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.IsGMCNPC = true

local models = {
	"models/mossman.mdl",
	"models/alyx.mdl",
	"models/Barney.mdl",
	"models/breen.mdl",
	"models/Eli.mdl",
	"models/gman_high.mdl",
	"models/Kleiner.mdl",
	"models/monk.mdl",
	"models/odessa.mdl",
	"models/Humans/Group01/Female_01.mdl",
	"models/Humans/Group01/Female_02.mdl",
	"models/Humans/Group01/Female_03.mdl",
	"models/Humans/Group01/Female_04.mdl",
	"models/Humans/Group01/Female_06.mdl",
	"models/Humans/Group01/Female_07.mdl",
	"models/Humans/Group01/Male_01.mdl",
	"models/Humans/Group01/male_02.mdl",
	"models/Humans/Group01/male_03.mdl",
	"models/Humans/Group01/Male_04.mdl",
	"models/Humans/Group01/Male_05.mdl",
	"models/Humans/Group01/male_06.mdl",
	"models/Humans/Group01/male_07.mdl",
	"models/Humans/Group01/male_08.mdl",
	"models/Humans/Group01/male_09.mdl",
}

function ENT:Initialize()
    self:SetModel(table.Random(models))
end

function ENT:FindHelicopter(range)
	if not range then
		range = 1000
	end
	local heli
	for _,ent in pairs(ents.FindInSphere(self:GetPos(), range)) do
		if ent.IsHelicopter then
			heli = ent
		end
	end
	return heli
end

-- Override MoveToPos with a better MoveToPos
function ENT:MoveToPos(pos, options)
	local options = options or {}

	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, pos)

	if not path:IsValid() then return "failed" end

	while ( path:IsValid() ) do
		if options.terminate_condition and options.terminate_condition() then
			return "terminated"
		end

		path:Update(self)

		-- Draw the path (only visible on listen servers or single player)
		if options.draw then
			path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if self.loco:IsStuck() then
			self:HandleStuck()
			return "stuck"
		end

		--
		-- If they set maxage on options then make sure the path is younger than it
		--
		if options.maxage then
			if (path:GetAge() > options.maxage) then return "timeout" end
		end

		--
		-- If they set repath then rebuild the path every x seconds
		--
		if options.repath then
			if (path:GetAge() > options.repath) then
				local newpos = (options.repath_pos and options.repath_pos() or pos)
				path:Compute(self, newpos)
			end
		end

		coroutine.yield()
	end
	return "ok"
end

AccessorFunc(ENT, "heli", "Helicopter")

function ENT:IsInHelicopter()
	return IsValid(self:GetHelicopter())
end

function ENT:EnterHelicopter(heli, seat)
	error("DEPRECATED")
end

function ENT:LeaveHelicopter()
	error("DEPRECATED")
end

function ENT:BehaviourTick()
end

function ENT:RunBehaviour()
    while true do
    	self:BehaviourTick()
        coroutine.yield()
    end
end