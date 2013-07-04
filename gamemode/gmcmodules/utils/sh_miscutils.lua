gmcutils = gmcutils or {}

function AccessorFuncDT(tbl, varname, name)
   tbl["Get" .. name] = function(s) return s.dt and s.dt[varname] end
   tbl["Set" .. name] = function(s, v) if s.dt then s.dt[varname] = v end end
end

function string.Contains(haystack, needle)
	return haystack:find(needle, 1, true) ~= nil
end

function gmcutils.IsInside(spacemins, spacemaxs, targmins, targmaxs)
	return (spacemins.x <= targmins.x and spacemins.y <= targmins.y and spacemins.z <= targmins.z) and
		   (spacemaxs.x >= targmaxs.x and spacemaxs.y >= targmaxs.y and spacemaxs.z >= targmaxs.z)
end

function gmcutils.DrawSpottests(spacemins, spacemaxs, targoob, spottests)
	if not spottests then
		spottests = 2
	end

	local spacesize = spacemaxs - spacemins
	local fittimes = Vector(math.floor(spacesize.x / targoob.x), math.floor(spacesize.y / targoob.y), math.floor(spacesize.z / targoob.z)) -- How many times should we fit inside in total
	if fittimes.x < 1 or fittimes.y < 1 or fittimes.z < 1 then return end -- We won't fit at all

	--gmcdebug.Msg("Will fit ", fittimes)
	-- We're gonna test fittimes*spottests spots inside the space
	-- On every coordinate axis we're gonna test every targoob.xyz / spottests coord

	--  + (spottests) are to fix that math.ceil might leave out some delicious places that could be spawnable

	render.SetMaterial(Material( "widgets/disc.png", "nocull alphatest smooth mips" ))

	local x, y, z
	for x=0,fittimes.x*spottests + math.floor(spottests/2) do
		for y=0,fittimes.y*spottests + math.floor(spottests/2) do
			for z=0,fittimes.z*spottests + math.floor(spottests/2) do
				
				local startat = spacemins + targoob*(Vector(x/spottests, y/spottests, z/spottests)) -- The point at which we should start
				local endat = startat + targoob

				local IsInside = gmcutils.IsInside(spacemins, spacemaxs, startat, endat)
				if IsInside then
					continue
				end

				render.DrawBox(startat+targoob*0.5, Angle(0, 0, 0), -targoob*0.5, targoob*0.5, Color(255, 255, 255))

			end
		end
	end
end

-- TODO targoob to targobb..
function gmcutils.FindEmptySpaceInside(spacemins, spacemaxs, targoob, spottests, ignoreEnts)
	if not spottests then
		spottests = 2
	end

	local spacesize = spacemaxs - spacemins
	local fittimes = Vector(math.floor(spacesize.x / targoob.x), math.floor(spacesize.y / targoob.y), math.floor(spacesize.z / targoob.z)) -- How many times should we fit inside in total
	if fittimes.x < 1 or fittimes.y < 1 or fittimes.z < 1 then return end -- We won't fit at all

	--gmcdebug.Msg("Will fit ", fittimes)
	-- We're gonna test fittimes*spottests spots inside the space
	-- On every coordinate axis we're gonna test every targoob.xyz / spottests coord

	--  + (spottests) are to fix that math.ceil might leave out some delicious places that could be spawnable

	local x, y, z
	for x=0,fittimes.x*spottests + math.floor(spottests/2) do
		for y=0,fittimes.y*spottests + math.floor(spottests/2) do
			for z=0,fittimes.z*spottests + math.floor(spottests/2) do
				
				local startat = spacemins + targoob*(Vector(x/spottests, y/spottests, z/spottests)) -- The point at which we should start
				local endat = startat + targoob

				local IsInside = gmcutils.IsInside(spacemins, spacemaxs, startat, endat)
				if not IsInside then
					continue
				end

				local fe = ents.FindInBox(startat, endat)
				--PrintTable(fe)
				local cnt = #fe
				if cnt == 0 then
					return startat, endat
				end

				if ignoreEnts then
					for i=0,#fe do
						if table.HasValue(ignoreEnts, fe[i]) then
							cnt = cnt - 1
						end
					end

					if cnt == 0 then
						return startat, endat
					end
				end


			end
		end
	end
end

local sin,cos,rad = math.sin,math.cos,math.rad; --Only needed when you constantly calculate a new polygon, it slightly increases the speed.
function gmcutils.GenerateCirclePoly(x, y, radius, quality)
    local circle = {};
    local tmp = 0;
    for i=1,quality do
        tmp = rad(i*360)/quality
        circle[i] = {x = x + cos(tmp)*radius,y = y + sin(tmp)*radius};
    end
    return circle;
end

function gmcutils.ParseHammerVector(value)
	local spl = value:Split(" ")
	return Vector(tonumber(spl[1]), tonumber(spl[2]), tonumber(spl[3]))
end

function gmcutils.Range(from, to, step)
	step = step or 1
	local tbl = {}
	for i=from, to, step do
		table.insert(tbl, i)
	end
	return tbl
end

function gmcutils.MapSequentialTable(tbl, funct)
	local ntbl = {}
	for k,v in ipairs(tbl) do
		ntbl[k] = func(v)
	end
	return ntbl
end

function gmcutils.MapTable(tbl, func)
	local ntbl = {}
	for k,v in pairs(tbl) do
		ntbl[k] = func(v)
	end
	return ntbl
end