/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/items/weapons/sear.ogg'
	hitsound_wall = 'sound/items/weapons/effects/searwall.ogg'
	armor_flag = LASER
	eyeblur = 4 SECONDS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_system = OVERLAY_LIGHT
	light_range = 1
	light_power = 1.4
	light_color = COLOR_SOFT_RED
	ricochets_max = 50 //Honk!
	ricochet_chance = 80
	reflectable = TRUE
	wound_bonus = -20
	exposed_wound_bonus = 10


/obj/projectile/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser
	wound_bonus = -20
	damage = 25
	exposed_wound_bonus = 40

/obj/projectile/beam/laser/carbine
	icon_state = "carbine_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
	damage = 10

/obj/projectile/beam/laser/carbine/practice
	name = "practice laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
	damage = 0

/obj/projectile/beam/laser/carbine/cybersun
	name = "red plasma beam"
	icon_state = "lava"
	light_color = COLOR_DARK_RED
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	damage = 9
	wound_bonus = -40
	speed = 0.9

//overclocked laser, does a bit more damage but has much higher wound power (-0 vs -20)
/obj/projectile/beam/laser/hellfire
	name = "hellfire laser"
	icon_state = "hellfire"
	wound_bonus = 0
	damage = 30
	speed = 1.6
	light_color = "#FF969D"

/obj/projectile/beam/laser/flare
	name = "flare particle"
	icon_state = "flare"
	light_range = 2
	light_power = 3
	damage = 20
	wound_bonus = -15
	exposed_wound_bonus = 15

/obj/projectile/beam/laser/flare/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/designated_target = target
	designated_target.apply_status_effect(/datum/status_effect/designated_target)

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/beam/laser/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.ignite_mob()
	else if(isturf(target))
		impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser/wall

/obj/projectile/beam/laser/musket
	name = "low-power laser"
	icon_state = "laser_musket"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 28
	stamina = 35
	light_color = COLOR_STRONG_VIOLET
	weak_against_armour = TRUE

/obj/projectile/beam/laser/musket/prime
	name = "mid-power laser"
	damage = 25
	stamina = 20
	weak_against_armour = FALSE

/obj/projectile/beam/weak
	damage = 15

/obj/projectile/beam/weak/penetrator
	armour_penetration = 50

/obj/projectile/beam/practice
	name = "practice laser"
	damage = 0

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 7.5
	wound_bonus = 5
	exposed_wound_bonus = 5
	damage_falloff_tile = -0.45
	wound_falloff_tile = -2.5

/obj/projectile/beam/scatter/pathetic
	name = "extremely weak laser pellet"
	damage = 1
	wound_bonus = 0
	damage_falloff_tile = -0.1
	color = "#dbc11d"
	hitsound = 'sound/items/bikehorn.ogg' //honk
	hitsound_wall = 'sound/items/bikehorn.ogg'

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
	hitsound = 'sound/items/weapons/sear_disabler.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/disabler/weak
	damage = 15

/obj/projectile/beam/disabler/scatter
	name = "scatter disabler"
	icon_state = "scatterdisabler"
	damage = 5.5
	damage_falloff_tile = -0.5
	speed = 1.2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/beam/disabler/smoothbore
	name = "unfocused disabler beam"
	weak_against_armour = TRUE

/obj/projectile/beam/disabler/smoothbore/prime
	name = "focused disabler beam"
	weak_against_armour = FALSE
	damage = 35 //slight increase in damage just for the hell of it

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

/obj/projectile/beam/pulse/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || isstructure(target)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

/obj/projectile/beam/pulse/shotgun
	damage = 30

/obj/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	projectile_piercing = ALL
	var/pierce_hits = 2

/obj/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = 0, pierce_hit)
	if(pierce_hits <= 0)
		projectile_piercing = NONE
	pierce_hits -= 1
	return ..()

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	wound_bonus = -40
	exposed_wound_bonus = 70

/obj/projectile/beam/emitter/singularity_pull(atom/singularity, current_size)
	return //don't want the emitters to miss

/obj/projectile/beam/emitter/hitscan
	icon_state = null
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
	// Subtract this from SM damage on hit for lasers
	var/integrity_heal
	// Subtract this from SM energy on hit for lasers
	var/energy_reduction
	// Add this to SM psi coefficient on hit for lasers
	var/psi_change

/obj/projectile/beam/emitter/hitscan/bluelens
	name = "electrodisruptive beam"
	light_color = LIGHT_COLOR_BLUE
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/bluelens
	impact_type = /obj/effect/projectile/impact/pulse
	hitscan_light_color_override = COLOR_BLUE_LIGHT
	muzzle_flash_color_override = COLOR_BLUE_LIGHT
	impact_light_color_override = COLOR_BLUE_LIGHT
	damage_type = STAMINA
	integrity_heal = 0.25
	energy_reduction = 60

/obj/projectile/beam/emitter/hitscan/bioregen
	name = "bioregenerative beam"
	light_color = LIGHT_COLOR_BRIGHT_YELLOW
	muzzle_type = /obj/effect/projectile/muzzle/solar
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/bioregen
	impact_type = /obj/effect/projectile/impact/solar
	hitscan_light_color_override = COLOR_LIGHT_YELLOW
	muzzle_flash_color_override = COLOR_LIGHT_YELLOW
	impact_light_color_override = COLOR_LIGHT_YELLOW
	damage_type = STAMINA
	damage = 0
	var/healing_done = 5

/obj/projectile/beam/emitter/hitscan/bioregen/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/healed_guy = target
	healed_guy.heal_bodypart_damage(brute = healing_done, burn = healing_done, updating_health = FALSE)

/obj/projectile/beam/emitter/hitscan/incend
	name = "conflagratory beam"
	light_color = LIGHT_COLOR_ORANGE
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/redlens
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitscan_light_color_override = COLOR_ORANGE
	muzzle_flash_color_override = COLOR_ORANGE
	impact_light_color_override = COLOR_ORANGE
	damage = 20
	integrity_heal = -0.15
	energy_reduction = -150
	psi_change = -0.1

/obj/projectile/beam/emitter/hitscan/incend/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/burnt_guy = target
	burnt_guy.adjust_fire_stacks(5)
	burnt_guy.ignite_mob()

/obj/projectile/beam/emitter/hitscan/psy
	name = "psychosiphoning beam"
	light_color = LIGHT_COLOR_PINK
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter/psy
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/psy
	impact_type = /obj/effect/projectile/impact/laser/emitter/psy
	hitscan_light_color_override = COLOR_BLUSH_PINK
	muzzle_flash_color_override = COLOR_BLUSH_PINK
	impact_light_color_override = COLOR_BLUSH_PINK
	damage = 0
	energy_reduction = -25
	psi_change = 0.25

/obj/projectile/beam/emitter/hitscan/psy/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/siphoned = target
	siphoned.mob_mood.adjust_sanity(-25)
	to_chat(siphoned, span_warning("Suddenly, everything feels just a little bit worse!"))

/obj/projectile/beam/emitter/hitscan/magnetic
	name = "magnetogenerative beam"
	light_color = COLOR_SILVER
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter/magnetic
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/magnetic
	impact_type = /obj/effect/projectile/impact/laser/emitter/magnetic
	hitscan_light_color_override = COLOR_SILVER
	muzzle_flash_color_override = COLOR_SILVER
	impact_light_color_override = COLOR_SILVER
	damage = 0

/obj/projectile/beam/emitter/hitscan/magnetic/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/turf/turf_to_magnet = get_turf(target)
	goonchem_vortex(turf_to_magnet, FALSE, 4)

/obj/projectile/beam/emitter/hitscan/blast
	name = "hyperconcussive beam"
	light_color = LIGHT_COLOR_ORANGE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter/magnetic
	tracer_type = /obj/effect/projectile/tracer/laser/emitter/magnetic
	impact_type = /obj/effect/projectile/impact/laser/emitter/magnetic
	hitscan_light_color_override = COLOR_ORANGE
	muzzle_flash_color_override = COLOR_ORANGE
	impact_light_color_override = COLOR_ORANGE
	damage = 0
	integrity_heal = -2
	energy_reduction = -500


/obj/projectile/beam/emitter/hitscan/blast/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/turf/turf_to_explode = get_turf(target)
	explosion(turf_to_explode, 0, 1, 2)


/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = 0, pierce_hit)
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
	icon_state = null
	hitscan = TRUE

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/lasertag/bluetag/hitscan
	icon_state = null
	hitscan = TRUE

/obj/projectile/magic/shrink/alien
	antimagic_flags = NONE
	shrink_time = 9 SECONDS
