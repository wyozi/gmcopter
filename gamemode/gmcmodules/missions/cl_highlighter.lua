net.Receive("PosHighlighter", function()
	local pos = net.ReadVector()
	debugoverlay.Sphere(pos, 32, 0.25, Color(255, 127, 0), true)
end)