local PANEL = {}

function PANEL:Init()

	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	self:SetTitle("")

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

	gmchooks.Call("GMCAddMenuPanel", tabdata, self.Tabs)

	for i,v in ipairs(tabdata) do
		local btn = vgui.Create("GMCMenuButton", self)
		btn:SetText(v.Name)
		btn:SetPos(0, 200 + i*42)
		btn:SetSize(250, 40)

		btn.DoClick = function()
			self.Tabs:SetActiveTab(v.Sheet.Tab)
		end
	end

	self.Tabs:SetPos(275, 50)
	self.Tabs:SetSize(ScrW() - 300, ScrH() - 100)

	self.Tabs:GetChildren()[1]:SetVisible(false) -- Hides the tab links. We b usin buttons for them.

	for i,v in ipairs(tabdata) do
		v.Sheet = self.Tabs:AddSheet(v.Name, v.Panel, "icon16/book_open.png", false, false, "This be hovertext?")
	end

end

function PANEL:Think()
	local binding = input.LookupBinding("gm_showhelp")
	if not binding then return end

	if self.m_fCreateTime > SysTime() - 0.5 then
		return
	end

	local keynum = _G["KEY_" .. binding]
	if input.IsKeyDown( keynum ) then
		self:Close()
	end
end

function PANEL:Paint()
	return true
end

vgui.Register( "GMCMenu", PANEL, "DFrame" )