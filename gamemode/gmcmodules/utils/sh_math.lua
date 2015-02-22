
local math = math

gmc.math = {}

function gmc.math.Approach(val, targ, amount)
	if val < targ then
		return math.min(val + amount, targ)
	elseif val > targ then
		return math.max(val - amount, targ)
	end
	return val
end

function gmc.math.ApproachVectorMod(src, targ, amount)
	src.x = gmc.math.Approach(src.x, targ.x, amount)
	src.y = gmc.math.Approach(src.y, targ.y, amount)
	src.z = gmc.math.Approach(src.z, targ.z, amount)
	return src
end
function gmc.math.ApproachVector(src, targ, amount)
	local v = Vector(src)
	gmc.math.ApproachVectorMod(v, targ, amount)
	return v
end

function gmc.math.ApproachAngleMod(src, targ, amount)
	src.p = gmc.math.Approach(src.p, targ.p, amount)
	src.y = gmc.math.Approach(src.y, targ.y, amount)
	src.r = gmc.math.Approach(src.r, targ.r, amount)
	return src
end

function gmc.math.Diff(x, y)
	return math.abs(x - y)
end

function gmc.math.VectorDiff(x, y)
	return (x-y):Length()
end

function gmc.math.AngleDiff(x, y)
	local sub = (x-y)
	return math.sqrt(sub.p*sub.p + sub.y*sub.y + sub.r*sub.r)
end

function gmc.math.Signum(val)
	if val < 0 then
		return -1
	elseif val > 0 then
		return 1
	end
	return 0
end

function gmc.math.VectorSignum(vec)
	return Vector(gmc.math.Signum(vec.x), gmc.math.Signum(vec.y), gmc.math.Signum(vec.z))
end

function gmc.math.AngleSignum(ang)
	return Angle(gmc.math.Signum(ang.p), gmc.math.Signum(ang.y), gmc.math.Signum(ang.r))
end
