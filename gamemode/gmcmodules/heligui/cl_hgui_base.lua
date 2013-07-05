
local PANEL = {}

function PANEL:Init()

end

function PANEL:PaintBackground()	
	surface.SetDrawColor(Color(255, 127, 0, 50))

	local w, h = self:GetSize()
	surface.DrawRect(0, 0, w, h)
end

function PANEL:Paint()
	self:PaintBackground()
end

vgui.Register( "HGuiBase", PANEL, "DPanel" )