
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

	-- contains X tables which contain Y values
	local MMCache = {}

	local function RoundTens(x)
		return math.floor(x/100)*100
	end

	function PANEL:Paint( att )
		
		local x,y = self:GetPos()
		local w,h = self:GetSize()

		local midx, midy = w/20, h/20

		local heli = LocalPlayer():GetHelicopter()
		local helipos = heli:GetPos()
		local downvec = Vector(0, 0, -10000)
		local filtertbl = {LocalPlayer():GetHelicopter()}

		-- TODO clear MMCache

		for x=0,w/10 do
			for y=0, h/10 do

				local targx = RoundTens(helipos.x + (x-midx)*100)
				local targy = RoundTens(helipos.y + (y-midy)*100)

				local cl

				if MMCache[targx] then
					cl = MMCache[targx][targy]
				end

				if not cl then
					if not MMCache[targx] then
						MMCache[targx] = {}
					end

					local startvec = Vector(targx, targy, helipos.z)
					local tr = util.QuickTrace(startvec, downvec, filtertbl)

					local pc = util.PointContents(tr.HitPos - tr.HitNormal*5)

					cl = clrs.Other
					if bit.band(pc, CONTENTS_TRANSLUCENT) == CONTENTS_TRANSLUCENT then
						cl = clrs.Water
					end

					MMCache[targx][targy] = cl
				end

				surface.SetDrawColor(cl)
				surface.DrawRect(x*10, y*10, 10, 10)
			end
		end

		do
			surface.SetDrawColor(Color(255, 255, 0))
			surface.DrawRect(midx*10-5, midy*10-5, 10, 10)

			local yaw = math.rad(heli:GetAngles().y)

			-- TODO rotate line to right when turning right, etc

			local xadd = math.cos(yaw)
			local yadd = math.sin(yaw)

			surface.DrawLine(midx*10, midy*10, midx*10 + xadd*25, midy*10 + yadd*25)
		end

	end

	gmchgui.Create("MiniMap", PANEL)

end