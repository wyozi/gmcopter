
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
	end

	function ENT:StartRadio(radio)
		self.music.snd = gmcwebradio.Play(radio.url, gmcwebradio.FindService(radio.url))
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

			local rand = table.Random(gmcwebradio.LocalRadios)
			if rand then
				self:StartRadio(rand)
				gmcdebug.Msg("Starting radio", rand)
			end
		end

		if self.music and self.music.snd then
			self.music.snd:SetPos(heli:GetPos())
		end

	end

end