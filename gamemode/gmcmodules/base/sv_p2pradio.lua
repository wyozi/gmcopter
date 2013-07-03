function GM:PlayerCanHearPlayersVoice( listener, talker )
	if listener:GetHelicopter() == talker:GetHelicopter() then -- Doesn't matter if both null
		return true, true
	end
	-- TODO implement radio channels or something
	return false, false
end