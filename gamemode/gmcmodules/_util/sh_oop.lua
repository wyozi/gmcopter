gmc.oopclasses = gmc.oopclasses or {}

gmc.class = function(name, super, ...)
	local cls = gmc.oopclasses[name]
	if cls then return cls end

	if type(super) == "string" then
		super = gmc.oopclasses[super]
	end

	cls = Middleclass(name, super, ...)
	gmc.oopclasses[name] = cls

	return cls
end