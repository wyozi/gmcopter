gmchgui = {}

function gmchgui.Create(name, tbl)
	vgui.Register( gmchgui.Translate(name), tbl, "HGuiBase" )
end

function gmchgui.Translate(name)
	return "HGui_" .. name
end