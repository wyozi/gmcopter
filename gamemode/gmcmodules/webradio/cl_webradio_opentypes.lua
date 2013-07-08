gmcwebradio = gmcwebradio or {}

local htmlcontainer = {}
function htmlcontainer:Play()
	local html = vgui.Create("DHTML")
	html:SetVisible(false) -- ???

	html:OpenURL(self.url)

	self.html = html
end
function htmlcontainer:Stop()
	if self:IsValid() then
		self.html:Remove()
	end
end
function htmlcontainer:IsValid()
	return self.html and self.html:IsValid()
end
function htmlcontainer:SetVolume(vol)
	if self:IsValid() and self.service.VolumeSetter then
		self.service.VolumeSetter(self.html, vol)
	end
end

local basscontainer = {}
function basscontainer:Play()
	self.Stopped = false
	sound.PlayURL( self.url, "", function(snd)
		if not snd or not snd:IsValid() then
			MsgN("GMCOPTER: WebRadio couldn't load BASS sound!")
			return
		end
		if self.Stopped then
			gmcdebug.Msg("Stopped before starting")
			return
		end
		gmcdebug.Msg("Basscontainer succesfully loaded channel", snd)
		self.snd = snd
		snd:Play()
		self.PlayingStarted = CurTime()
	end) 
end
function basscontainer:Stop()
	if self:IsValid() then
		self.snd:Stop()
		self.Stopped = true
	end
end
function basscontainer:SetVolume(vol)
	if self:IsValid() then
		self.snd:SetVolume(vol)
	end
end
function basscontainer:IsValid()
	return self.snd and self.snd:IsValid()
end
function basscontainer:SetPos(pos)
	if self:IsValid() then self.snd:SetPos(pos) end
end

function gmcwebradio.Play(url, service)
	local tbl = {url=service.TranslateURL(url), service=service}
	if service.OpenType == GMCWR_OPENTYPE_HTML then
		setmetatable(tbl, {__index = htmlcontainer})
		tbl:Play()
		return tbl
	elseif service.OpenType == GMCWR_OPENTYPE_BASS then
		setmetatable(tbl, {__index = basscontainer})
		tbl:Play()
		return tbl
	end
end