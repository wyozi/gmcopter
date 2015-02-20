net.Receive("PosHighlighter", function()
	debugoverlay.Sphere(net.ReadVector(), 32, 0.25, Color(255, 127, 0), true)
end)