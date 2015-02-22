gmc.utils = gmc.utils or {}

function gmc.utils.SetAngleVelocity(physobj, anglevel)
	physobj:AddAngleVelocity( -1 * physobj:GetAngleVelocity( ) + anglevel)
end