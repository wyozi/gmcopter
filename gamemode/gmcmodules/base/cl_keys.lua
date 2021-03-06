local GMCMenu

function GM:PlayerBindPress(ply, bind, pressed)
	if not IsValid(ply) then return end

	if ply:IsInHelicopter() then
		if bind == "+menu" or bind == "+jump" then
			RunConsoleCommand(pressed and "+gmc_incalt" or "-gmc_incalt")
			return true
		elseif bind == "undo" or bind == "+duck" then
			RunConsoleCommand(pressed and "+gmc_decalt" or "-gmc_decalt")
			return true
		elseif bind == "+reload" and pressed then
			RunConsoleCommand("gmc_changeview")
		end
	end

	if bind == "gm_showhelp" then
		if pressed then
			if IsValid(GMCMenu) then
				GMCMenu:Close()
			else
				GMCMenu = vgui.Create("GMCMenu")
				GMCMenu:MakePopup()
			end
		end
		return true
	end
end
