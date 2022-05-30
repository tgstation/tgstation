/obj/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	damage = 50
	sharpness = SHARP_POINTY
	wound_bonus = 0

/obj/projectile/bullet/shotgun_slug/executioner
	name = "executioner slug" // admin only, can dismember limbs
	sharpness = SHARP_EDGED
	wound_bonus = 80

/obj/projectile/bullet/shotgun_slug/pulverizer
	name = "pulverizer slug" // admin only, can crush bones
	sharpness = NONE
	wound_bonus = 80

/obj/projectile/bullet/shotgun_beanbag
	name = "beanbag slug"
	damage = 10
	stamina = 55
	wound_bonus = 20
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	damage = 20

/obj/projectile/bullet/incendiary/shotgun/no_trail
	name = "precision incendiary slug"
	damage = 35
	leaves_fire_trail = FALSE

/obj/projectile/bullet/incendiary/shotgun/dragonsbreath
	name = "dragonsbreath pellet"
	damage = 5

/obj/projectile/bullet/shotgun_stunslug
	name = "stunslug"
	damage = 5
	paralyze = 100
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	range = 7
	icon_state = "spark"
	color = "#FFFF00"
	embedding = null

/obj/projectile/bullet/shotgun_meteorslug
	name = "meteorslug"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	damage = 30
	paralyze = 15
	knockdown = 80
	hitsound = 'sound/effects/meteorimpact.ogg'

/obj/projectile/bullet/shotgun_meteorslug/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismovable(target))
		var/atom/movable/M = target
		var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
		M.safe_throw_at(throw_target, 3, 2, force = MOVE_FORCE_EXTREMELY_STRONG)

/obj/projectile/bullet/shotgun_meteorslug/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/projectile/bullet/shotgun_frag12
	name ="frag12 slug"
	damage = 15
	paralyze = 10

/obj/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = FALSE)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 1, explosion_cause = src)
	return BULLET_ACT_HIT

/obj/projectile/bullet/pellet
	/// How much main damage we lose each tile we pass
	var/damage_dropoff_per_tile = 0.45
	/// How much extra stamina damage we lose each tile we pass
	var/stamina_dropoff_per_tile = 0.25
	/// This is added onto the speed for each tile the pellet travels (positive numbers making it slower)
	var/speed_dropoff = 0
	/// How many tiles the speed_dropoff applies for before it caps out
	var/speed_dropoff_tiles = 0

/obj/projectile/bullet/pellet/Range()
	..()
	if(speed_dropoff_tiles > 0)
		speed = max(speed + speed_dropoff, 0.1) // so we can't cause a divide by 0 or negative if someone adds an accelerating bullet
		speed_dropoff_tiles--

	if(damage > 0)
		damage -= damage_dropoff_per_tile
	if(stamina > 0)
		stamina -= stamina_dropoff_per_tile
	if(damage < 0 && stamina < 0)
		qdel(src)

// classic buckshot, military/syndie aligned, kills outright, more close range
/obj/projectile/bullet/pellet/shotgun_buckshot
	name = "buckshot pellet"
	damage = 9 // * 6 pellets = 54 brute
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -1 // low damage + additional dropoff will already curb wounding potential anything past point blank
	speed = 0.6
	speed_dropoff = 0.2
	speed_dropoff_tiles = 5
	ricochets_max = 1
	ricochet_chance = 100
	ricochet_incidence_leeway = 50

// special cargo buckshot-lite for NT, less pellets & damage, weak against armor, greater wounding power and slightly longer ranged
/obj/projectile/bullet/pellet/shotgun_voidshot
	name = "voidshot pellet"
	icon_state = "voidshot"
	damage = 8 // * 5 pellets = 40 brute
	wound_bonus = 6
	bare_wound_bonus = 10
	wound_falloff_tile = -1.5
	weak_against_armour = TRUE
	speed = 0.5
	speed_dropoff = 0.3
	speed_dropoff_tiles = 5
	ricochets_max = 2
	ricochet_chance = 100
	ricochet_decay_damage = 0.9

/obj/projectile/bullet/pellet/shotgun_rubbershot
	name = "rubbershot pellet"
	damage = 3
	stamina = 11
	sharpness = NONE
	embedding = null
	speed = 0.6
	speed_dropoff = 0.4
	speed_dropoff_tiles = 5
	ricochets_max = 4
	ricochet_chance = 120
	ricochet_decay_chance = 0.9
	ricochet_decay_damage = 0.8
	ricochet_auto_aim_range = 2
	ricochet_auto_aim_angle = 30
	ricochet_incidence_leeway = 75
	/// Subtracted from the ricochet chance for each tile traveled
	var/tile_dropoff_ricochet = 4

/obj/projectile/bullet/pellet/shotgun_rubbershot/Range()
	if(ricochet_chance > 0)
		ricochet_chance -= tile_dropoff_ricochet
	. = ..()

/obj/projectile/bullet/pellet/shotgun_incapacitate
	name = "incapacitating pellet"
	damage = 1
	stamina = 6
	embedding = null

/obj/projectile/bullet/pellet/shotgun_improvised
	damage_dropoff_per_tile = 0.35 //Come on it does 6 damage don't be like that.
	damage = 6
	wound_bonus = 0
	bare_wound_bonus = 7.5

/obj/projectile/bullet/pellet/shotgun_improvised/Initialize(mapload)
	. = ..()
	range = rand(1, 8)

/obj/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()

// Mech Scattershot

/obj/projectile/bullet/scattershot
	damage = 24
