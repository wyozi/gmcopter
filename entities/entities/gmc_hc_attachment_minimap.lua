
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

	function ENT:AddComponents(hguibase)
		hguibase:AddBottomComponent(vgui.Create(gmchgui.Translate("MiniMap")))
	end

	local PANEL = {}

	local clrs = {
		Water = Color(0, 0, 255),
		Solid = Color(0, 255, 0),
		Other = Color(0, 0, 0)
	}

	function PANEL:Paint( att )
		
		local x,y = self:GetPos()
		local w,h = self:GetSize()

		local midx, midy = w/20, h/20

		local heli = LocalPlayer():GetHelicopter()
		local helipos = heli:GetPos()
		local downvec = Vector(0, 0, -10000)
		local filtertbl = {LocalPlayer():GetHelicopter()}

		for x=0,w/10 do
			for y=0, h/10 do

				local startvec = helipos + Vector((x-midx)*100, (y-midy)*100, 0)
				local tr = util.QuickTrace(startvec, downvec, filtertbl)

				local pc = util.PointContents(tr.HitPos - tr.HitNormal*5)

				local cl = clrs.Other
				if bit.band(pc, CONTENTS_TRANSLUCENT) == CONTENTS_TRANSLUCENT then
					cl = clrs.Water
				end
				--MsgN(pc, clrs[pc])

				surface.SetDrawColor(cl)
				surface.DrawRect(x*10, y*10, 10, 10)
			end
		end

	end

	gmchgui.Create("MiniMap", PANEL)

end