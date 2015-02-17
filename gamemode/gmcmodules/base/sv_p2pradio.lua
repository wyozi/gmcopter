function GM:PlayerCanHearPlayersVoice(listener, talker)
	-- If both in same helicopter
	if listener:IsInHelicopter() and listener:GetHelicopter() == talker:GetHelicopter() then
		return true, false
	end
	
	-- If neither in helicopter
	if not listener:IsInHelicopter() and not talker:IsInHelicopter() then
		return true, true
	end

	return false
end
