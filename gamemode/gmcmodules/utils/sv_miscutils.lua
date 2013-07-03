gmcutils = gmcutils or {}

function gmcutils.SetAngleVelocity(physobj, anglevel)
	physobj:AddAngleVelocity( -1 * physobj:GetAngleVelocity( ) + anglevel)
end