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

	self.BottomComponents = {}

end

function PANEL:Think()
	local me = LocalPlayer()
	local heli = me:GetHelicopter()
	if heli ~= self.LastStoredHeli then
		self.LastStoredHeli = heli
		for _,comp in pairs(self.BottomComponents) do
			comp:Remove() -- TODO?
		end
		table.Empty(self.BottomComponents)

		if IsValid(heli) then
			local atts = heli:GetHeliAttachments()
			for _,att in ipairs(atts) do
				att:AddComponents(self)
			end
		end

	end
end

local HudMatrix = Matrix()

function PANEL:Paint( w, h )
	local me = LocalPlayer()
	if me:IsInHelicopter() then
		HudMatrix:SetTranslation(Vector(0, 0, 0))

		for _,att in ipairs(self.BottomComponents) do
			local posx, posy = att:GetPos()
			HudMatrix:SetTranslation(Vector(posx, posy, 0))

			cam.PushModelMatrix(HudMatrix)
			att:Paint( att.ParentAttachment )
			cam.PopModelMatrix()
		end
	end
end

function PANEL:AddBottomComponent(comp, att)
	table.insert(self.BottomComponents, comp)

	local oldpar = comp:GetParent()
	comp:SetParent(self)
	comp:SetVisible(false)

	comp.ParentAttachment = att

	self:LayoutComponents()
end

function PANEL:LayoutComponents()
	local count = #self.BottomComponents
	if count > 0 then

		local usableWidth = ScrW()
		local usableCount = 0

		for _,comp in ipairs(self.BottomComponents) do
			if comp.OverrideWidth then
				usableWidth = usableWidth - comp.OverrideWidth
			else
				usableCount = usableCount + (comp.WidthCells or 1) -- WidthCells = amount of screen divisors to use
			end
		end

		local eawidth = usableCount > 0 and usableWidth/ usableCount or 0
		local wth = 0
		for idx,comp in ipairs(self.BottomComponents) do
			local owidth = comp.OverrideWidth or ( eawidth * ( comp.WidthCells or 1 ) )
			local height = comp.OverrideHeight or 200
			comp:SetSize(owidth, height)
			comp:SetPos(wth, ScrH() - height)

			wth = wth + owidth
		end
	end
end

vgui.Register( "HGuiFrame", PANEL, "DPanel" )