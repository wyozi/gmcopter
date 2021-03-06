GMC_CAMVIEW_FIRSTPERSON = 1
GMC_CAMVIEW_CHASE = 2
GMC_CAMVIEW_THIRDPERSON = 3
GMC_CAMVIEW_COCKPIT = 4

CreateClientConVar("gmc_camview", GMC_CAMVIEW_FIRSTPERSON, true, false)

concommand.Add("gmc_changeview", function()
	local oldview = GetConVar("gmc_camview"):GetInt()

	local newview
	if oldview == GMC_CAMVIEW_FIRSTPERSON then
		newview = GMC_CAMVIEW_CHASE
	else
		newview = GMC_CAMVIEW_FIRSTPERSON
	end

	RunConsoleCommand("gmc_camview", newview)
end)

local function CreateTRFilter(heli)
	return function(e)
		if e == heli then return false end
		if e.GetHelicopter and e:GetHelicopter() == heli then return false end
		if e:GetParent() == heli then return false end
		
		return true
	end
end

local function CalcView(ply, pos, angles, fov)
	local heli = ply:GetHelicopter()
	if IsValid(heli) then
		local view = {}

		view.origin = pos
		view.angles = angles
		view.fov = 100

		local camview = GetConVar("gmc_camview"):GetInt()
		if camview == GMC_CAMVIEW_CHASE then
			local hang = heli:GetAngles()

			local targ = heli:GetPos() - (hang:Forward()*400) + (hang:Up() * 250)
			local tr = util.TraceLine({
				start = heli:GetPos(),
				endpos = targ,
				filter = CreateTRFilter(heli)
			})
			view.origin = tr.Hit and tr.HitPos or targ
			view.angles = tr.Hit and (heli:GetPos() - view.origin):Angle() or hang

			view.angles.p = 32
			view.angles.r = 0 -- Looks better this way

			return view
		elseif camview == GMC_CAMVIEW_THIRDPERSON then
			local view = {}
			local hang = angles

			local targ = heli:GetPos() - (hang:Forward()*500)
			local tr = util.TraceLine({
				start = heli:GetPos(),
				endpos = targ,
				filter = CreateTRFilter(heli)
			})
			view.origin = tr.Hit and tr.HitPos or targ
			view.angles = angles

			return view
		elseif camview == GMC_CAMVIEW_COCKPIT then
			local view = {}
			local hang = heli:GetAngles()
			view.origin = heli:GetPos() + (hang:Up() * 50) + (hang:Forward() * 100)
			view.angles = heli:GetAngles() --(heli:GetPos() - view.origin):Angle()

			return view
		end

		return view
	end
end

hook.Add("CalcView", "CalcHeliView", CalcView)