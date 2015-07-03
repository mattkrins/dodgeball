AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Dodge Ball"
ENT.Author			= "StealthPaw"
ENT.Information		= "Based on Garry Newman's Bouncy Ball"
ENT.Category		= "dodgeball"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= false
ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT
ENT.IsBall			= false
ENT.Bounced			= false

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "BallSize", { KeyName = "ballsize", Edit = { type = "Float", min = 4, max = 128, order = 1 } } )
	self:NetworkVar( "Float", 1, "Team", { KeyName = "team", Edit = { type = "Float", min = 1, max = 2, order = 1 } } )
	self:NetworkVar( "Vector", 0, "BallColor", { KeyName = "ballcolor", Edit = { type = "VectorColor", order = 2 } } )
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 23
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetBallSize( 23 )
	ent:SetBallColor( Vector(1,0.3,0.3) )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	if ( SERVER ) then
		local size = self:GetBallSize() / 2
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		self:PhysicsInitSphere( size, "metal_bouncy" )
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:Wake() end
		self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
		self:NetworkVarNotify( "BallSize", self.OnBallSizeChanged )
		self:NetworkVarNotify( "BallColor", self.OnBallColorChanged )
		timer.Simple( 0.1, function() if self and IsValid(self) then self.FlyTime = true end end )
	else 
		self.LightColor = Vector( 0, 0, 0 )
	end
end

function ENT:OnBallSizeChanged( varname, oldvalue, newvalue )
	local delta = oldvalue - newvalue
	local size = self:GetBallSize() / 2.1
	self:PhysicsInitSphere( size, "metal_bouncy" )
	size = self:GetBallSize() / 2.6
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
	self:PhysWake()
end

function ENT:OnBallColorChanged( varname, oldvalue, newvalue )
	if SERVER then
		if self.Trail and IsValid(self.Trail) then self.Trail:Remove() end
		local startWidth = 4
		local endWidth = 0
		self.Trail = util.SpriteTrail(self, 0, Color(newvalue.x*255, newvalue.y*255, newvalue.z*255-75, 255), false, startWidth, endWidth, 2, (1 / ( startWidth + endWidth ) * 0.5), "trails/Electric.vmt" )
	end
end

if ( CLIENT ) then
	local matBall = Material( "dodgeball/dodgeball" )
	function ENT:Draw()
		local pos = self:GetPos()
		local vel = self:GetVelocity()
		render.SetMaterial( matBall )
		local lcolor = render.ComputeLighting( self:GetPos(), Vector( 0, 0, 1 ) )
		local c = self:GetBallColor()
		lcolor.x = c.r * ( math.Clamp( lcolor.x, 0, 1 ) + 0.5 ) * 255
		lcolor.y = c.g * ( math.Clamp( lcolor.y, 0, 1 ) + 0.5 ) * 255
		lcolor.z = c.b * ( math.Clamp( lcolor.z, 0, 1 ) + 0.5 ) * 255
		render.DrawSprite( pos, self:GetBallSize(), self:GetBallSize(), Color( lcolor.x, lcolor.y, lcolor.z, 255 ) )
	end
end

function ENT:PhysicsCollide( data, physobj )
	if ( SERVER ) then timer.Simple( 0.8, function() if self and IsValid(self) and self.FlyTime then self.Bounced = true end end ) end
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then
		local pitch = 32 + 128 - self:GetBallSize()
		local Bounce = Sound( "weapons/dodgeball/bounce"..math.floor(math.random( 1, 4 ))..".wav" )
		sound.Play( Bounce, self:GetPos(), 75, math.random( pitch - 5, pitch + 5 ), math.Clamp( data.Speed / 150, 0, 1 ) )
	end
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()
	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	local TargetVelocity = NewVelocity * LastSpeed * 0.5
	physobj:SetVelocity( TargetVelocity )
end

function ENT:OnTakeDamage( dmginfo )
	self:TakePhysicsDamage( dmginfo )
end

function ENT:Use( activator, caller )
	local ply = activator or caller
	if !ply or !ply:IsPlayer() then return end
	self:Touch( ply )
end

function ENT:Touch( entity )
	if ( SERVER ) then
		if self.FlyTime and entity:IsPlayer() and (self.Bounced or self:GetTeam() == entity:Team()) and !entity:Ball() then
			entity:GiveBall()
			local Bounce = Sound( "weapons/dodgeball/bounce"..math.floor(math.random( 1, 4 ))..".wav" )
			sound.Play( Bounce, self:GetPos() )
			self:Remove()
			return
		end
		if entity:IsPlayer() and !self.Bounced and (self:GetTeam() and self:GetTeam() != entity:Team()) and !entity.Spawning then
			print('test')
			entity:TakeDamage( 1000, self.ServedBy or self, self )
			if self.ServedBy then self.ServedBy:Taunt() end
			self.Bounced = true
			return
		end
	end
end
