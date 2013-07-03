
local math = math

gmcmath = {}

function gmcmath.Approach(val, targ, amount)
	if val < targ then
		return math.min(val + amount, targ)
	elseif val > targ then
		return math.max(val - amount, targ)
	end
	return val
end 

function gmcmath.ApproachVectorMod(src, targ, amount)
	src.x = gmcmath.Approach(src.x, targ.x, amount)
	src.y = gmcmath.Approach(src.y, targ.y, amount)
	src.z = gmcmath.Approach(src.z, targ.z, amount)
	return src
end
function gmcmath.ApproachVector(src, targ, amount)
	local v = Vector(src)
	gmcmath.ApproachVectorMod(v, targ, amount)
	return v
end

function gmcmath.ApproachAngleMod(src, targ, amount)
	src.p = gmcmath.Approach(src.p, targ.p, amount)
	src.y = gmcmath.Approach(src.y, targ.y, amount)
	src.r = gmcmath.Approach(src.r, targ.r, amount)
	return src
end

function gmcmath.Diff(x, y)
	return math.abs(x - y)
end

function gmcmath.VectorDiff(x, y)
	return (x-y):Length()
end

function gmcmath.AngleDiff(x, y)
	local sub = (x-y)
	return math.sqrt(sub.p*sub.p + sub.y*sub.y + sub.r*sub.r)
end

function gmcmath.Signum(val)
	if val < 0 then
		return -1
	elseif val > 0 then
		return 1
	end
	return 0
end

function gmcmath.VectorSignum(vec)
	return Vector(gmcmath.Signum(vec.x), gmcmath.Signum(vec.y), gmcmath.Signum(vec.z))
end