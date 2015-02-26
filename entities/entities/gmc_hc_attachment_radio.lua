
AddCSLuaFile()

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)

	self:NetworkVar("Int", 0, "StationIndex")
end

ENT.Base = "gmc_hc_attachment_base"

if SERVER then
	util.AddNetworkString("GMCRadio")
	net.Receive("GMCRadio", function(len, cl)
		local heli = cl:GetHelicopter()
		if not IsValid(heli) then return end

		local att = heli:GetHeliAttachment("gmc_hc_attachment_radio")
		if not IsValid(att) then return end

		att:SetStationIndex(((att:GetStationIndex() or 0) + 1) % (#gmc.radio.Stations + 1))
	end)
end

if CLIENT then
	function ENT:Think()
		local idx_playing = self.PlayingIndex or 0
		local idx_shouldplay = self:GetStationIndex()
		if LocalPlayer():GetHelicopter() ~= self:GetHelicopter() then
			idx_shouldplay = 0
		end

		if idx_playing ~= idx_shouldplay then
			self.PlayingIndex = idx_shouldplay

			if IsValid(self.Channel) then
				self.Channel:Stop()
			end

			local url = gmc.radio.Stations[idx_shouldplay]
			url = url and url.url

			if url then
				sound.PlayURL(url, "noplay", function(chan)
					if not chan then return end -- TODO error report

					-- channel was changed during loading phase
					if idx_shouldplay ~= self.PlayingIndex then
						return
					end

					chan:Play()
					self.Channel = chan
				end)
			end
		end
	end
end


gmc.radio = {}
gmc.radio.Stations = {
	{
		name = "Smooth Jazz",
		url = "http://listen.sky.fm/public3/uptemposmoothjazz.pls"
	},
	{
		name = "Classic Rap",
		url = "http://listen.sky.fm/public3/classicrap.pls"
	},
	{
		name = "Classical",
		url = "http://listen.sky.fm/public3/classical.pls"
	},
	{
		name = "New Age",
		url = "http://listen.sky.fm/public3/newage.pls"
	},
	{
		name = "Roots Reggae",
		url = "http://listen.sky.fm/public3/rootsreggae.pls"
	}
}