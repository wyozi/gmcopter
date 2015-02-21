hook.Add("HUDPaint", "fds", function()
	
	local ortho = 13000
	render.RenderView {
		origin = Vector(0, 0, 2722.4045),
		angles = Angle(90, 0, 0),
		x = 0,
		y = 0,
		w = 1024,
		h = 1024,
		ortho = true,
		ortholeft = -ortho,
		orthoright = ortho,
		orthotop = -ortho,
		orthobottom = ortho
	}
	
	local RCD = { }

	RCD.format = "jpeg"
	RCD.h = 1024
	RCD.w = 1024
	RCD.quality = 70
	RCD.x = 0
	RCD.y = 0
	
	local data = render.Capture(RCD)
	local f = file.Open("minimap.txt", "wb", "DATA")
	f:Write(data)
	f:Close()
	
	hook.Remove("HUDPaint", "fds")
end)