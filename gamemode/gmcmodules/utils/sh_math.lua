
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

function gmcmath.ApproachVector(src, targ, amount)
	return Vector(
		gmcmath.Approach(src.x, targ.x, amount),
		gmcmath.Approach(src.y, targ.y, amount),
		gmcmath.Approach(src.z, targ.z, amount)
		)
end

function gmcmath.Diff(x, y)
	return math.abs(x - y)
end

function gmcmath.VectorDiff(x, y)
	return (x-y):Length()
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