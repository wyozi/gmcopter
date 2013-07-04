gmcparticles = {}

function gmcparticles.Smokey(pos, vel)

	if not vel then
		vel = Vector(math.random(), math.random(), 0) * math.Rand(-100, 100)
	end

	local emitter = ParticleEmitter( pos )

		local particle = emitter:Add( "particles/smokey", pos )
			particle:SetVelocity( vel )
			particle:SetDieTime( 2.0 )
			particle:SetStartAlpha( math.Rand( 50, 150 ) )
			particle:SetStartSize( math.Rand( 16, 32 ) )
			particle:SetEndSize( math.Rand( 64, 128 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 200, 200, 210 )

	emitter:Finish()
end