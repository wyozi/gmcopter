AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.DisplayName	= "GMC Class"

PLAYER.WalkSpeed = 200	-- How fast to move when not running
PLAYER.RunSpeed	= 300	-- How fast to move when running
PLAYER.CrouchedWalkSpeed = 0.2	-- Multiply move speed by this when crouching
PLAYER.DuckSpeed	= 0.3	-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed	= 0.3	-- How fast to go from ducking, to not ducking
PLAYER.JumpPower	= 120	-- How powerful our jump should be
PLAYER.CanUseFlashlight = true	-- Can we use the flashlight
PLAYER.MaxHealth	= 100	-- Max health we can have
PLAYER.StartHealth	= 100	-- How much health we start with
PLAYER.StartArmor	= 0	-- How much armour we start with
PLAYER.DropWeaponOnDie	= false	-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide = true	-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers	= false	-- Automatically swerves around other players


--
-- Set up the network table accessors
--
function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables( self )
end


--AccessorFunc(PLAYER, "Helicopter", "InHeli")

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()

	BaseClass.Spawn( self )

	--local col = self.Player:GetInfo( "cl_playercolor" )
	--self.Player:SetPlayerColor( Vector( col ) )
	--self.Player:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	--self.Player:SetFOV(85, 0)
	--self.Player:ClearPoseParameters()

end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()

	--self.Player:RemoveAllAmmo()
	--self.Player:SwitchToDefaultWeapon()
	self.Player:StripWeapons()
	self.Player:Give("weapon_physgun")
	self.Player:Give("gmod_tool")

end

--[[ If needed..
function PLAYER:Think()
end

hook.Add("Think", "PlyClassThink", function()
	local plys = player.GetAll()
	for i=1,#plys do
		player_manager.RunClass(plys[i], "Think")
	end
end)
]]

if CLIENT then -- TODO move out of here
	hook.Add("PostPlayerDraw", "DrawPlayerAccessories", function(ply)

		local hat = ply.Hat
		local glasses = ply.Glasses
		if not hat then
			hat = ClientsideModel("models/headset/headset.mdl", RENDERGROUP_OPAQUE)
			hat:SetNoDraw(true)
			ply.Hat = hat
		end
		if not glasses then
			glasses = ClientsideModel("models/Aviator/aviator.mdl", RENDERGROUP_OPAQUE)
			glasses:SetNoDraw(true)
			ply.Glasses = glasses
		end

		if not ply:Alive() or ( ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' and (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() == 0) ) then
			--hat:SetNoDraw(true)
			return
		end
		--hat:SetNoDraw(false)

		local pos = Vector()
		local ang = Angle()

		local attach_id = ply:LookupAttachment("eyes")
		if not attach_id then return end

		local attach = ply:GetAttachment(attach_id)

		if not attach then return end

		pos = attach.Pos
		ang = attach.Ang
		ang:RotateAroundAxis(ang:Up(), 180)

		do
			local hatpos = pos + (ang:Forward() * 3) - (ang:Up() * 3.5)

			hat:SetPos(hatpos)
			hat:SetAngles(ang)

			hat:SetRenderOrigin(hatpos)
			hat:SetRenderAngles(ang)

			hat:SetupBones()
			hat:DrawModel()

			hat:SetRenderOrigin()
			hat:SetRenderAngles()
		end

		do
			local glassespos = pos + (ang:Forward() * 0.8) - (ang:Up() * 1.2)
			ang:RotateAroundAxis(ang:Up(), 180)

			glasses:SetPos(glassespos)
			glasses:SetAngles(ang)

			glasses:SetRenderOrigin(glassespos)
			glasses:SetRenderAngles(ang)

			glasses:SetupBones()
			glasses:DrawModel()

			glasses:SetRenderOrigin()
			glasses:SetRenderAngles()

		end

	end)
end


--
-- Return true to draw local (thirdperson) camera - false to prevent - nothing to use default behaviour
--
function PLAYER:ShouldDrawLocal()

	if IsValid(self.Player:GetHelicopter()) and GetConVar("gmc_camview"):GetInt() ~= GMC_CAMVIEW_FIRSTPERSON then return true end

end


player_manager.RegisterClass( "player_gmc", PLAYER, "player_default" )
