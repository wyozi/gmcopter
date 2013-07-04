
local PANEL = {}

function PANEL:Init()

end

function PANEL:Paint()
	surface.SetDrawColor(Color(255, 127, 0, 50))

	local w, h = self:GetSize()
	surface.DrawRect(0, 0, w, h)
end

vgui.Register( "HGuiBase", PANEL, "DPanel" )