
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
		hguiframe:AddBottomComponent(vgui.Create(gmchgui.Translate("Radio")), self)
	end

	local PANEL = {}

	CreateClientConVar("gmc_webradio_volume", "50", true, false)
	CreateClientConVar("gmc_webradio_startonenter", "0", true, false)

	function PANEL:Init()

		local btn = vgui.Create("DButton", self)
		btn:SetText("Loading..")
		btn.DoClick = function()
			if table.Count(gmcwebradio.LocalRadios) == 0 then return end
			local cur = self.ParentAttachment:GetCurUrl()
			self.SetToUrl = cur and gmcwebradio.NextRadioUrl(cur) or table.GetFirstValue(gmcwebradio.LocalRadios).url
		end
		self.btn = btn

		local slider = vgui.Create( "DNumSlider", self )
		slider:SetMin(0)
		slider:SetMax(100)
		slider:SetValue(GetConVarNumber("gmc_webradio_volume")*100)
		slider.OnValueChanged = function(_, val)
			RunConsoleCommand("gmc_webradio_volume", math.Round(val)/100)
		end
		self.slider = slider
	end

	function PANEL:Think()
		local w, h = self:GetSize()
		self.slider:SetSize(w, 50)
		self.btn:SetSize(w, 50)
		self.btn:SetPos(0, 50)

		self.ParentAttachment:TrySetVol(self.slider:GetValue() / 100)

		local cururl = self.ParentAttachment:GetCurUrl()
		if cururl then
			self.btn:SetText("Current station: " .. tostring(cururl))
		elseif table.Count(gmcwebradio.LocalRadios) == 0 then
			self.btn:SetText("No stations. Add one from F1 menu.")
		else
			self.btn:SetText("No station loaded. Press to load.")
		end
		if self.SetToUrl and self.SetToUrl ~= cururl then
			self.ParentAttachment:StartRadio(self.SetToUrl)
			self.SetToUrl = nil
		end
	end

	function PANEL:Paint()
		self:PaintBackground()
		return true -- draw children
	end

	gmchgui.Create("Radio", PANEL)

	function ENT:StartRadio(radio)
		if self.music.snd then
			self.music.snd:Stop()
		end
		self.music.snd = gmcwebradio.Play(radio, gmcwebradio.FindService(radio))
		self.music.changed = CurTime()
	end

	function ENT:GetCurUrl()
		if self.music and self.music.snd then
			return self.music.snd.url
		end
	end

	function ENT:TrySetVol(vol)
		if self.music and self.music.snd and self.music.changed < CurTime() - 1 then -- changed check to prevent console spam for undefined setVolume
			self.music.snd:SetVolume(vol)
		end
	end

	function ENT:Think()
		local ply = LocalPlayer()
		local heli = self:GetHeli()

		if ply:GetHelicopter() ~= heli and self.music then
			if self.music.snd then
				self.music.snd:Stop()
			end
			self.music = nil
		elseif ply:GetHelicopter() == heli and not self.music then
			self.music = {}

			if GetConVar("gmc_webradio_startonenter"):GetBool() then
				local rand = table.Random(gmcwebradio.LocalRadios)
				if rand then
					self:StartRadio(rand.url)
					gmcdebug.Msg("Starting radio", rand)
				end
			end
		end

		if self.music and self.music.snd then
			--elf.music.snd:SetPos(heli:GetPos())
		end

	end

end