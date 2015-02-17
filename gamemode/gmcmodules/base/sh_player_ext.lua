local meta = FindMetaTable("Player")

function meta:GetHelicopter()
	return self:GetNWEntity("Helicopter")
end
function meta:SetHelicopter(hc)
	return self:SetNWEntity("Helicopter", hc)
end

function meta:IsInHelicopter()
	return IsValid(self:GetHelicopter())
end
