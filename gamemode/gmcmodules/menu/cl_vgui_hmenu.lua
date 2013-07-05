local PANEL = {}

function PANEL:Init()

	--self:SetFocusTopLevel( true )

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	self:SetKeyboardInputEnabled( false )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

	self.Tabs = vgui.Create("DPropertySheet", self)

	local tabdata = {
		{
			Name = "Options",
			Panel = vgui.Create("DPanel", self.Tabs)
		}
	}

	for i,v in ipairs(tabnames) do
		local btn = vgui.Create("GMCMenuButton", self)
		btn:SetText(v.Name)
		btn:SetPos(0, 200 + i*42)
		btn:SetSize(250, 40)

		-- TODO OnClick open related tab
	end

	self.Tabs:SetPos(275, 50)
	self.Tabs:SetSize(ScrW() - 275, ScrH() - 100)

	self.Tabs:GetChildren()[1]:SetVisible(false) -- Hides the tab links. We b usin buttons for them.

	for i,v in ipairs(tabnames) do
		self.Tabs:AddSheet(v.Name, v.Panel, "icon16/book_open.png", false, false, "This be hovertext?")

	end

end

function PANEL:Paint()
	return true
end

vgui.Register( "GMCMenu", PANEL, "DFrame" )