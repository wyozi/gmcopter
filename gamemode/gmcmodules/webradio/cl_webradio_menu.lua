hook.Add("GMCAddMenuPanel", "AddWebradioPanel", function(tbl, tabs)
	table.insert(tbl, {
		Name = "Web radio",
		Panel = vgui.Create("WebRadioMenu", tabs)
	})
end)

local PANEL = {}

function PANEL:Init()

	local top = vgui.Create("DPanel", self)
	top:Dock( TOP )

	local t = vgui.Create("DTextEntry", top)
	t:SetSize(1, 50)
	t:Dock(FILL)

	local b = vgui.Create("DButton", top)
	b:SetText("Check")
	b:SetSize(100, 50)
	b:Dock(RIGHT)

	local list = vgui.Create("DListView", self)
	list:Dock( FILL )
	list:SetMultiSelect( false )
	list:AddColumn( "Radio Station Number" )
	list:AddColumn( "URL" )
	list:AddColumn( "Service Name" )
	list:AddColumn( "URL Matches" )

	local function LineIdx(line)
		for k,v in pairs(list:GetLines()) do
			if v == line then return k end
		end
	end

	local function AddLine(idx, url, sname, matches)
		local line = list:AddLine(idx, url, sname, matches)

		line.OnRightClick = function()
			local menu = DermaMenu()
			menu:AddOption("Remove", function()
	            gmc.webradio.LocalRadios[idx] = nil
	            gmc.webradio.Save()
	            list:RemoveLine(LineIdx(line))
	        end)
	        menu:AddOption("Copy URL", function()
	            SetClipboardText( url )
	        end)
	        menu:Open()
		end
	end

	for idx,radio in SortedPairs(gmc.webradio.LocalRadios) do
		AddLine(idx, radio.url, radio.sname, gmc.debug.ToString(radio.matches))
	end

	b.DoClick = function()
		local s, sname, matches = gmc.webradio.FindService(t:GetText())
		if not s then
			return
		end
		local nidx = table.insert(gmc.webradio.LocalRadios, {url=t:GetText(), sname=sname, matches=matches})
		AddLine(nidx, t:GetText(), sname, gmc.debug.ToString(matches))
		gmc.webradio.Save()
	end

end

vgui.Register( "WebRadioMenu", PANEL, "DPanel" )