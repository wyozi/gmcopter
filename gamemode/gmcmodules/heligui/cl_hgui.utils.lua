gmchgui = {}

function gmchgui.Create(name, tbl)
	vgui.Register( "HGui_" .. name, tbl, "HGuiBase" )
end