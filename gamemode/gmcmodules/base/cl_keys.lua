function GM:PlayerBindPress(ply, bind, pressed)
	if not IsValid(ply) then return end

	if bind == "+menu" then
		RunConsoleCommand(pressed and "+gmc_incalt" or "-gmc_incalt")
		return true
	elseif bind == "undo" then
		RunConsoleCommand(pressed and "+gmc_decalt" or "-gmc_decalt")
		return true
	end
end
