simcopter = simcopter or {}

local base_url = "https://5eef22769387e0f1e43d663238172db4ce4fe17a.googledrive.com/host/0B6kXndv3L8sEfi16TVhqbkE2QnMyOFFhMExhVGdyejdxeUZfU0tQMVBENGg3aHdoeDNGek0/"
simcopter.SoundMap = {
	-- central dispatch
	CDisp = {
		alert = "d1000",
		assistreq = "d1005",

		Fire = {
			report = "d1001",
			building = "d1002",
			vehicle = "d1004",
		},

		Transport = {
			request = "d1006",
		},

		noinfo = "d2001", -- no additional information
		possinjuries = "d2002",
		airassist = "d2004", -- provide aerial assistance
		statelvl = "d2007", -- state level security mission

		firedepreq = "d2013", -- fire department requests aerial reconnaissance
		policereq = "d2014", -- police request aerial assistance

		strongwinds = "d2019", -- strong winds may hamper operation
	}
}

function simcopter.PlaySoundChain(...)
	local t = {...}

	local first = table.remove(t, 1)
	if not first then return end

	sound.PlayURL(base_url .. first .. ".wav", "", function(chan, err, errName)
		timer.Simple(chan:GetLength(), function()
			simcopter.PlaySoundChain(unpack(t))
		end)
	end)
end

concommand.Add("simcopter_voice", function()
	local map = simcopter.SoundMap
	simcopter.PlaySoundChain(
		map.CDisp.alert,
		map.CDisp.Fire.building,
		map.CDisp.strongwinds,
		map.CDisp.noinfo
	)
end)