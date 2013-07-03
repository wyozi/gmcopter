
AddCSLuaFile()

ENT.Model = Model("models/weapons/w_bugbait.mdl") 

ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then
	
	function ENT:Initialize()
		self:SetModel(self.Model)

		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)

		self.IsEnabled = not self:HasSpawnFlags(2048)

	end

	function ENT:KeyValue(key, value)
		if key == "missions" then
			if value and value:Trim() ~= "" then
				self.MissionFilter = value:Split(",")
			end
		elseif key == "delay" then
			self.MissionDelay = tonumber(value)
		elseif key == "delayrandomness" then
			self.MissionDelayRandomness = tonumber(value)
		end
	end

	function ENT:AcceptInput(name, activator)
		if name == "Enable" then
			self.IsEnabled = true
			return true
		elseif name == "Disable" then
			self.IsEnabled = false
			return true
		end
	end

end