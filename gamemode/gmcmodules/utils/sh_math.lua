
local math = math
local min, max, abs, sqrt = math.min, math.max, math.abs, math.sqrt

gmc.math = {}

function gmc.math.Approach(val, targ, amount)
	if val < targ then
		return min(val + amount, targ)
	elseif val > targ then
		return max(val - amount, targ)
	end
	return val
end

local function dist(x, y)
	return abs(x - y)
end

function gmc.math.ApproachOverflow(val, targ, amount, lowbound, highbound)
	if val < targ then
		local dist_direct = dist(val, targ)
		local dist_underflow = dist(val, lowbound) + dist(highbound, targ)
		if dist_direct < dist_underflow then
			return min(val + amount, targ)
		else
			local v = val - amount
			if v < lowbound then
				return highbound - (lowbound - v)
			end
			return v
		end
	end
	if val > targ then
		local dist_direct = dist(val, targ)
		local dist_overflow = dist(val, highbound) + dist(lowbound, targ)
		if dist_direct < dist_overflow then
			return min(val - amount, targ)
		else
			local v = val + amount
			if v > highbound then
				return lowbound + (v - highbound)
			end
			return v
		end
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
	return Vector(
		gmc.math.Approach(src.x, targ.x, amount),
		gmc.math.Approach(src.y, targ.y, amount),
		gmc.math.Approach(src.y, targ.y, amount)
	)
end

function gmc.math.ApproachAngleMod(src, targ, amount)
	src.p = gmc.math.Approach(src.p, targ.p, amount)
	src.y = gmc.math.Approach(src.y, targ.y, amount)
	src.r = gmc.math.Approach(src.r, targ.r, amount)
	return src
end

function gmc.math.Diff(x, y)
	return abs(x - y)
end

function gmc.math.VectorDiff(x, y)
	return (x-y):Length()
end

function gmc.math.AngleDiff(x, y)
	local sub = (x-y)
	return sqrt(sub.p*sub.p + sub.y*sub.y + sub.r*sub.r)
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

function gmc.math.SourceUnitsToFeet(units)
    return units / 16
end

function gmc.math.FeetToMeters(feet)
    return feet * 0.3048
end

function gmc.math.MPSToKnots(mps)
	return mps / 0.514
end
function gmc.math.KMHToKnots(kmh)
    return kmh / 1.852
end