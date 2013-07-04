
local PANEL = {}

function PANEL:Init()

end

function PANEL:Paint()
	surface.SetDrawColor(Color(255, 127, 0, 50))

	local x, y = self:GetPos()
	local w, h = self:GetSize()
	surface.DrawRect(x, y, w, h)
end

vgui.Register( "HGuiBase", PANEL, "DPanel" )