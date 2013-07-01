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
	self.Player:NetworkVar( "Entity", 0, "Helicopter" )
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
	self.Player:Give("weapon_toolgun")

end

--
-- Return true to draw local (thirdperson) camera - false to prevent - nothing to use default behaviour
--
function PLAYER:ShouldDrawLocal()

	if IsValid(self.Player:GetHelicopter()) then return true end

end


player_manager.RegisterClass( "player_gmc", PLAYER, "player_default" )