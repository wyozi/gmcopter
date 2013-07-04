
AddCSLuaFile()

ENT.Base = "gmc_hc_attachment_base"

if SERVER then

	function ENT:AttachToHeli(heli)
		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
	end

end

if CLIENT then

	function ENT:AddComponents(hguiframe)
		local sg = self:GetNWString("coptergui")
		if sg and sg ~= "" then
			hguiframe:AddBottomComponent(vgui.Create(gmchgui.Translate(sg)))
		end
	end

end