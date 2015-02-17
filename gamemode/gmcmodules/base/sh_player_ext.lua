local meta = FindMetaTable("Player")

function meta:IsInHelicopter()
	return IsValid(self:GetHelicopter())
end
