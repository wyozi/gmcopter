function GM:GrabEarAnimation(ply)
	ply.ChatGestureWeight = ply.ChatGestureWeight or 0

	-- Don't show this when we're playing a taunt!
	if ply:IsPlayingTaunt() then return end

	if not ply:IsInHelicopter() and (ply:IsTyping() or ply:IsSpeaking()) then
		ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 1, FrameTime() * 5.0 );
	else
		ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 0, FrameTime() * 5.0 );
	end

	if ply.ChatGestureWeight > 0 then
		ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.ChatGestureWeight )
	end
end
