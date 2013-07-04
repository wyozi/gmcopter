local PANEL = {}

function PANEL:Init()

	self:SetFocusTopLevel( true )

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	self:SetMouseInputEnabled( false )
	self:SetKeyboardInputEnabled( false )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

end

function PANEL:Paint( w, h )
	local me = LocalPlayer()
	if me:IsInHelicopter() then
		draw.DrawText( "Hello there!", "TargetID", w * 0.5, h * 0.25, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
	end
end

vgui.Register( "HGuiFrame", PANEL, "DPanel" )