local meta = FindMetaTable("Player")

function meta:GMC_IsDeveloper()
	return self:IsSuperAdmin()
end