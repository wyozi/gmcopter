gmcwebradio = gmcwebradio or {}

GMCWR_OPENTYPE_HTML = 1
GMCWR_OPENTYPE_BASS = 2

-- Youtube video might be detected before YoutubePlaylist, but putting it as last thing seems to make it a bigger priority. TODO make priority system?
gmcwebradio.Services = {
	YoutubeVideo = {
		Patterns = {
			"^https?://youtu%.be/([A-Za-z0-9_%-]+)",
	        "^https?://youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
	        "^https?://[A-Za-z0-9%.%-]*%.youtube%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
	        "^https?://[A-Za-z0-9%.%-]*%.youtube%.com/v/([A-Za-z0-9_%-]+)",
	        "^https?://youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
	        "^https?://[A-Za-z0-9%.%-]*%.youtube%-nocookie%.com/watch%?.*v=([A-Za-z0-9_%-]+)",
		},
		TranslateURL = function(url) return url .. "&autoplay=1" --[[TODO this might break everything]] end,
		OpenType = GMCWR_OPENTYPE_HTML,
		VolumeSetter = function(html, vol) html:RunJavascript("document.getElementById(\"movie_player\").setVolume(" .. tostring(vol*100) .. ")") end
	},
	YoutubePlaylist = {
		Patterns = {
	        "^https?://youtube%.com/watch%?.*list=([A-Za-z0-9_%-]+)",
	        "^https?://[A-Za-z0-9%.%-]*%.youtube%.com/watch%?.*list=([A-Za-z0-9_%-]+)",
		},
		TranslateURL = function(url) return url end,
		OpenType = GMCWR_OPENTYPE_HTML,
		VolumeSetter = function(html, vol) html:RunJavascript("document.getElementById(\"movie_player\").setVolume(" .. tostring(vol*100) .. ")") end
	},
	WebSound = {
		Patterns = {
			"^https?://.*%.(mp3|ogg)"
		},
		TranslateURL = function(url) return url end,
		OpenType = GMCWR_OPENTYPE_BASS
	},
	WebRadio = {
		Patterns = {
			"^https?://([^(/|:)]*):%d.*",
			"^https?://.*%.pls"
		},
		TranslateURL = function(url) return url end,
		OpenType = GMCWR_OPENTYPE_BASS
	}
}

-- The service to use if we have no matches from gmcwebradio.Services
gmcwebradio.OtherService = {
	Pattern = "^https?://(.*)",
	OpenType = GMCWR_OPENTYPE_HTML,
	TranslateURL = function(url) return url end
}

function gmcwebradio.FindService(url)
	for sname, service in pairs(gmcwebradio.Services) do
		local matches 

		for _, pattern in pairs(service.Patterns) do
			local m = {url:match(pattern)}
			if m[1] then
				matches = m
				break
			end
		end

		if matches then
			return service, sname, matches -- sname is second because most usecases probably dont care about it
		end
	end

	local m = {url:match(gmcwebradio.OtherService.Pattern)}
	if m[1] then
		return gmcwebradio.OtherService, "Other", m
	end
end