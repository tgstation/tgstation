/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	armor_flag = LASER
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 1
	light_color = COLOR_SOFT_RED
	ricochets_max = 50 //Honk!
	ricochet_chance = 80
	reflectable = REFLECT_NORMAL
	wound_bonus = -20
	bare_wound_bonus = 10


/obj/projectile/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser
	wound_bonus = -30
	bare_wound_bonus = 40

//overclocked laser, does a bit more damage but has much higher wound power (-0 vs -20)
/obj/projectile/beam/laser/hellfire
	name = "hellfire laser"
	wound_bonus = 0
	damage = 25
	speed = 0.6 // higher power = faster, that's how light works right

/obj/projectile/beam/laser/hellfire/Initialize(mapload)
	. = ..()
	transform *= 2

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/beam/laser/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.ignite_mob()
	else if(isturf(target))
		impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser/wall

/obj/projectile/beam/weak
	damage = 15

/obj/projectile/beam/weak/penetrator
	armour_penetration = 50

/obj/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = TRUE

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/projectile/beam/xray
	name = "\improper X-ray beam"
	icon_state = "xray"
	damage = 15
	range = 15
	armour_penetration = 100
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 30
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	wound_bonus = 10

/obj/projectile/beam/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

/obj/projectile/beam/pulse/shotgun
	damage = 30
	speed = 0.3

/obj/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	projectile_piercing = ALL
	var/pierce_hits = 2

/obj/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = FALSE)
	if(pierce_hits <= 0)
		projectile_piercing = NONE
	pierce_hits -= 1
	..()

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	wound_bonus = -40
	bare_wound_bonus = 70

/obj/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/projectile/beam/emitter/hitscan
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter
	tracer_type = /obj/effect/projectile/tracer/laser/emitter
	impact_type = /obj/effect/projectile/impact/laser/emitter
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = COLOR_LIME
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = COLOR_LIME
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = COLOR_LIME

/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)

/obj/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

//a shrink ray that shrinks stuff, which grows back after a short while.
/obj/projectile/beam/shrink
	name = "shrink ray"
	icon_state = "blue_laser"
	hitsound = 'sound/weapons/shrink_hit.ogg'
	damage = 0
	damage_type = STAMINA
	armor_flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/shrink
	light_color = LIGHT_COLOR_BLUE
	var/shrink_time = 90

/obj/projectile/beam/shrink/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isopenturf(target) || istype(target, /turf/closed/indestructible))//shrunk floors wouldnt do anything except look weird, i-walls shouldn't be bypassable
		return
	target.AddComponent(/datum/component/shrink, shrink_time)

/obj/projectile/beam/gravblast
	name = "gravity blast"
	icon_state = "void_pellet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 15
	damage_type = BRUTE
	armor_flag = ENERGY
	light_color = COLOR_PALE_PURPLE_GRAY
	speed = 0.2 //ZOOM

/obj/projectile/beam/gravblast/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/our_shot_target = target
		var/atom/throw_target = get_edge_target_turf(our_shot_target, get_dir(src, get_step_away(our_shot_target, src)))
		our_shot_target.safe_throw_at(throw_target, 3, 2, force = MOVE_FORCE_EXTREMELY_STRONG)

// Shotgun energy pellet projectiles

/obj/projectile/beam/pellet
	/// How much main damage we lose each tile we pass
	var/damage_dropoff_per_tile = 0.5
	/// How much extra stamina damage we lose each tile we pass. Not the same as main damage flagged as STAMINA
	var/stamina_dropoff_per_tile = 0.5
	/// This is added onto the speed for each tile the pellet travels (positive numbers making it slower)
	var/speed_dropoff = 0
	/// How many tiles the speed_dropoff applies for before it caps out
	var/speed_dropoff_tiles = 0
	/// How much extra armour penetration we lose each tile we pass
	var/armour_pen_dropoff_per_tile = 10

/obj/projectile/beam/pellet/Range()
	..()
	if(speed_dropoff_tiles > 0)
		speed = max(speed + speed_dropoff, 0.1) // so we can't cause a divide by 0 or negative if someone adds an accelerating bullet
		speed_dropoff_tiles--

	if(damage > 0)
		damage -= damage_dropoff_per_tile
	if(stamina > 0)
		stamina -= stamina_dropoff_per_tile
	if(armour_penetration > 0)
		armour_penetration = min(armour_penetration - armour_pen_dropoff_per_tile, 0) // We don't want this going into the negatives. Madness lies there.
	if(damage < 0 && stamina < 0)
		qdel(src)

/obj/projectile/beam/pellet/lethal
	name = "energized pellet"
	icon_state = "laser_pellet"
	damage = 10 // * 4 = 40 burn; can do very well into armor.
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -2.5
	speed = 0.3
	speed_dropoff = 0.3
	speed_dropoff_tiles = 5
	armour_penetration = 30 //Roughly 0% resistance into a secvest, very good for actually hitting armored targets

/obj/projectile/beam/pellet/voidshot
	name = "voidshot pellet"
	icon_state = "void_pellet"
	damage = 7 // * 5 pellets = 35 brute; not accounting for armor weakness
	damage_type = BRUTE
	armor_flag = ENERGY
	reflectable = FALSE
	wound_bonus = 6
	bare_wound_bonus = 10
	wound_falloff_tile = -1.5
	weak_against_armour = TRUE //turns most secvests into 80% resistance AKA not very good against an actually armored target unless limb aiming for wounds
	speed = 0.3
	speed_dropoff = 0.3
	speed_dropoff_tiles = 5
	ricochets_max = 2
	ricochet_chance = 100
	ricochet_decay_damage = 0.9
	light_color = COLOR_PALE_PURPLE_GRAY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser

/obj/projectile/beam/pellet/disable
	name = "static pellet"
	icon_state = "disabler_pellet"
	damage = 7.5 // * 4 = 30 stamina; equivalent to a disabler into an unarmored target, but against armored targets, does much better.
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler
	speed = 0.3
	speed_dropoff = 0.3
	speed_dropoff_tiles = 5
	armour_penetration = 30 //Roughly 0% resistance into a secvest, very good for actually hitting armored targets
