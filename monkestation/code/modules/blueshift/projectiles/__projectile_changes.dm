/obj/item/ammo_casing
	/// Can this bullet casing be printed at an ammunition workbench?
	var/can_be_printed = TRUE
	/// If it can be printed, does this casing require an advanced ammunition datadisk? Mainly for specialized ammo.
	/// Rubbers aren't advanced. Standard ammo (or FMJ if you're particularly pedantic) isn't advanced.
	/// Think more specialized or weird, niche ammo, like armor-piercing, incendiary, hollowpoint, or God forbid, phasic.
	var/advanced_print_req = FALSE

// whatever goblin decided to spread out bullets over like 3 files and god knows however many overrides i wish you a very stubbed toe

/*
*	.460 Ceres (renamed tgcode .45)
*/

/obj/item/ammo_casing/c45/rubber
	name = ".460 Ceres rubber bullet casing"
	desc = "A .460 bullet casing.\
	<br><br>\
	<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	projectile_type = /obj/projectile/bullet/c45/rubber
	harmful = FALSE

/obj/projectile/bullet/c45/rubber
	name = ".460 Ceres rubber bullet"
	damage = 10
	stamina = 50
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null
	wound_bonus = -50

/obj/item/ammo_casing/c45/hp
	name = ".460 Ceres hollow-point bullet casing"
	desc = "A .460 hollow-point bullet casing. Very lethal against unarmored opponents. Suffers against armor."
	projectile_type = /obj/projectile/bullet/c45/hp
	advanced_print_req = TRUE

/obj/projectile/bullet/c45/hp
	name = ".460 Ceres hollow-point bullet"
	damage = 40
	weak_against_armour = TRUE

/*
*	8mm Usurpator (renamed tg c46x30mm, used in the WT550)
*/

/obj/projectile/bullet/c46x30mm_rubber
	name = "8mm Usurpator rubber bullet"
	damage = 3
	stamina = 34
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null
	wound_bonus = -50

/obj/item/ammo_casing/c46x30mm/rubber
	name = "8mm Usurpator rubber bullet casing"
	desc = "An 8mm Usurpator rubber bullet casing.\
	<br><br>\
	<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	projectile_type = /obj/projectile/bullet/c46x30mm_rubber
	harmful = FALSE

/*
*	.277 Aestus (renamed tgcode .223, used in the M-90gl)
*/

/obj/item/ammo_casing/a223/rubber
	name = ".277 rubber bullet casing"
	desc = "A .277 rubber bullet casing.\
	<br><br>\
	<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"
	projectile_type = /obj/projectile/bullet/a223/rubber
	harmful = FALSE

/obj/projectile/bullet/a223/rubber
	name = ".277 rubber bullet"
	damage = 10
	armour_penetration = 10
	stamina = 50
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null
	wound_bonus = -50

/obj/item/ammo_casing/a223/ap
	name = ".277 Aestus armor-piercing bullet casing"
	desc = "A .277 armor-piercing bullet casing.\
	<br><br>\
	<i>ARMOR PIERCING: Increased armor piercing capabilities. What did you expect?"
	projectile_type = /obj/projectile/bullet/a223/ap
	advanced_print_req = TRUE
	custom_materials = AMMO_MATS_AP

/obj/projectile/bullet/a223/ap
	name = ".277 armor-piercing bullet"
	armour_penetration = 60

/*
*	.34 ACP
*/

// Why? Blame CFA, they want their bullets to be *proprietary*
/obj/item/ammo_casing/c34
	name = ".34 bullet casing"
	desc = "A .34 bullet casing."
	caliber = "c34acp"
	projectile_type = /obj/projectile/bullet/c34

/obj/projectile/bullet/c34
	name = ".34 bullet"
	damage = 15
	wound_bonus = 0

/obj/item/ammo_casing/c34/rubber
	name = ".34 rubber bullet casing"
	desc = "A .34 rubber bullet casing."
	caliber = "c34acp"
	projectile_type = /obj/projectile/bullet/c34/rubber
	harmful = FALSE

/obj/projectile/bullet/c34/rubber
	name = ".34 rubber bullet"
	damage = 5
	stamina = 35
	wound_bonus = -75
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/item/ammo_casing/c34/ap
	name = ".34 armor-piercing bullet casing"
	desc = "A .34 armor-piercing bullet casing."
	caliber = "c34acp"
	projectile_type = /obj/projectile/bullet/c34/ap
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/projectile/bullet/c34/ap
	name = ".34 armor-piercing bullet"
	damage = 15
	armour_penetration = 40
	wound_bonus = -75

/obj/item/ammo_casing/c34_incendiary
	name = ".34 incendiary bullet casing"
	desc = "A .34 incendiary bullet casing."
	caliber = "c34acp"
	projectile_type = /obj/projectile/bullet/incendiary/c34_incendiary
	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

/obj/projectile/bullet/incendiary/c34_incendiary
	name = ".34 incendiary bullet"
	damage = 8
	fire_stacks = 1
	wound_bonus = -90

/obj/item/ammo_casing/a40mm/rubber
	name = "40mm rubber shell"
	desc = "A cased rubber slug. The big brother of the beanbag slug, this thing will knock someone out in one. Doesn't do so great against anyone in armor."
	projectile_type = /obj/projectile/bullet/shotgun_beanbag/a40mm

/obj/item/ammo_casing/rocket
	name = "\improper Dardo HE rocket"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = CALIBER_84MM
	icon_state = "srm-8"
	base_icon_state = "srm-8"
	projectile_type = /obj/projectile/bullet/rocket

/obj/item/ammo_casing/rocket/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/rocket/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]"

/obj/item/ammo_casing/rocket/heap
	name = "\improper Dardo HE-AP rocket"
	desc = "An 84mm High Explosive All Purpose rocket. For when you just need something to not exist anymore."
	icon_state = "84mm-heap"
	base_icon_state = "84mm-heap"
	projectile_type = /obj/projectile/bullet/rocket/heap

/obj/item/ammo_casing/rocket/weak
	name = "\improper Dardo HE Low-Yield rocket"
	desc = "An 84mm High Explosive rocket. This one isn't quite as devastating."
	icon_state = "low_yield_rocket"
	base_icon_state = "low_yield_rocket"
	projectile_type = /obj/projectile/bullet/rocket/weak

/obj/item/ammo_casing/strilka310
	name = ".310 Strilka bullet casing"
	desc = "A .310 Strilka bullet casing. Casing is a bit of a fib, there is no case, its just a block of red powder."
	icon_state = "310-casing"
	caliber = CALIBER_STRILKA310
	projectile_type = /obj/projectile/bullet/strilka310

/obj/item/ammo_casing/strilka310/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)

/obj/item/ammo_casing/strilka310/surplus
	name = ".310 Strilka surplus bullet casing"
	desc = "A surplus .310 Strilka bullet casing. Casing is a bit of a fib, there is no case, its just a block of red powder. Damp red powder at that."
	projectile_type = /obj/projectile/bullet/strilka310/surplus

/obj/projectile/bullet/strilka310
	name = ".310 Strilka bullet"
	damage = 60
	armour_penetration = 10
	wound_bonus = -45
	wound_falloff_tile = 0

/obj/projectile/bullet/strilka310/surplus
	name = ".310 Strilka surplus bullet"
	weak_against_armour = TRUE //this is specifically more important for fighting carbons than fighting noncarbons. Against a simple mob, this is still a full force bullet
	armour_penetration = 0

/*
*	9x25mm Mk.12
*/

/obj/item/ammo_casing/c9mm
	name = "9x25mm Mk.12 bullet casing"
	desc = "A modern 9x25mm Mk.12 bullet casing."

/obj/item/ammo_casing/c9mm/ap
	name = "9x25mm Mk.12 armor-piercing bullet casing"
	desc = "A modern 9x25mm Mk.12 bullet casing. This one fires an armor-piercing projectile."
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c9mm/hp
	name = "9x25mm Mk.12 hollow-point bullet casing"
	desc = "A modern 9x25mm Mk.12 bullet casing. This one fires a hollow-point projectile. Very lethal to unarmored opponents."
	advanced_print_req = TRUE

/obj/item/ammo_casing/c9mm/fire
	name = "9x25mm Mk.12 incendiary bullet casing"
	desc = "A modern 9x25mm Mk.12 bullet casing. This incendiary round leaves a trail of fire and ignites its target."
	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c9mm/ihdf
	name = "9x25mm Mk.12 IHDF casing"
	desc = "A modern 9x25mm Mk.12 bullet casing. This one fires a bullet of 'Intelligent High-Impact Dispersal Foam', which is best compared to a riot-grade foam dart."
	projectile_type = /obj/projectile/bullet/c9mm/ihdf
	harmful = FALSE

/obj/projectile/bullet/c9mm/ihdf
	name = "9x25mm IHDF bullet"
	damage = 30
	damage_type = STAMINA
	embedding = list(embed_chance=0, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)

/obj/item/ammo_casing/c9mm/rubber
	name = "9x25mm Mk.12 rubber casing"
	desc = "A modern 9x25mm Mk.12 bullet casing. This less than lethal round sure hurts to get shot by, but causes little physical harm."
	projectile_type = /obj/projectile/bullet/c9mm/rubber
	harmful = FALSE

/obj/projectile/bullet/c9mm/rubber
	name = "9x25mm rubber bullet"
	icon_state = "pellet"
	damage = 5
	stamina = 34
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/*
*	10mm Auto
*/

/obj/item/ammo_casing/c10mm/ap
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c10mm/hp
	advanced_print_req = TRUE

/obj/item/ammo_casing/c10mm/fire
	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c10mm/reaper
	can_be_printed = FALSE
	// it's a hitscan 50 damage 40 AP bullet designed to be fired out of a gun with a 2rnd burst and 1.25x damage multiplier
	// Let's Not

/obj/item/ammo_casing/c10mm/rubber
	name = "10mm rubber bullet casing"
	desc = "A 10mm rubber bullet casing."
	projectile_type = /obj/projectile/bullet/c10mm/rubber
	harmful = FALSE

/obj/projectile/bullet/c10mm/rubber
	name = "10mm rubber bullet"
	damage = 10
	stamina = 37
	ricochets_max = 6
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/item/ammo_casing/c10mm/ihdf
	name = "10mm IHDF bullet casing"
	desc = "A 10mm intelligent high-impact dispersal foam bullet casing."
	projectile_type = /obj/projectile/bullet/c10mm/ihdf
	harmful = FALSE

/obj/projectile/bullet/c10mm/ihdf
	name = "10mm IHDF bullet"
	damage = 40
	damage_type = STAMINA
	embedding = list(embed_chance=0, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)

/obj/projectile/bullet/shotgun_beanbag/a40mm
	name = "rubber slug"
	icon_state = "cannonball"
	damage = 20
	stamina = 250 //BONK
	wound_bonus = 30
	weak_against_armour = TRUE

// Red kill lasers for the big gun

/obj/item/ammo_casing/energy/cybersun_big_kill
	projectile_type = /obj/projectile/beam/cybersun_laser
	e_cost = 200
	select_name = "Kill"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/laser.ogg'

/obj/projectile/beam/cybersun_laser
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/saibasan/projectiles.dmi'
	icon_state = "kill_large"
	damage = 15
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED
	wound_falloff_tile = 1

// Speedy sniper lasers for the big gun

/obj/item/ammo_casing/energy/cybersun_big_sniper
	projectile_type = /obj/projectile/beam/cybersun_laser/marksman
	e_cost = 300
	select_name = "Marksman"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/vaporize.ogg'

/obj/projectile/beam/cybersun_laser/marksman
	icon_state = "sniper"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
	speed = 0.4
	light_outer_range = 2
	light_color = COLOR_VERY_SOFT_YELLOW
	wound_falloff_tile = 0.1

// Disabler machinegun for the big gun

/obj/item/ammo_casing/energy/cybersun_big_disabler
	projectile_type = /obj/projectile/beam/cybersun_laser/disable
	e_cost = 75
	select_name = "Disable"
	harmful = FALSE

/obj/projectile/beam/cybersun_laser/disable
	icon_state = "disable_large"
	damage = 0
	stamina = 35
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = COLOR_BRIGHT_BLUE

// Plasma burst grenade for the big gun

/obj/item/ammo_casing/energy/cybersun_big_launcher
	projectile_type = /obj/projectile/beam/cybersun_laser/granata
	e_cost = 400
	select_name = "Launcher"

/obj/projectile/beam/cybersun_laser/granata
	name = "plasma grenade"
	icon_state = "grenade"
	damage = 50
	speed = 2
	range = 6
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = COLOR_PALE_GREEN
	pass_flags = PASSTABLE | PASSGRILLE // His ass does NOT pass through glass!
	/// What type of casing should we put inside the bullet to act as shrapnel later
	var/casing_to_spawn = /obj/item/grenade/c980payload/plasma_grenade

/obj/projectile/beam/cybersun_laser/granata/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	fuse_activation(target)
	return BULLET_ACT_HIT

/obj/projectile/beam/cybersun_laser/granata/on_range()
	fuse_activation(get_turf(src))
	return ..()

/// Called when the projectile reaches its max range, or hits something
/obj/projectile/beam/cybersun_laser/granata/proc/fuse_activation(atom/target)
	var/obj/item/grenade/shrapnel_maker = new casing_to_spawn(get_turf(target))
	shrapnel_maker.detonate()
	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)
	qdel(shrapnel_maker)

/obj/projectile/beam/cybersun_laser/granata_shrapnel
	name = "plasma globule"
	icon_state = "flare"
	damage = 10
	speed = 2.5
	bare_wound_bonus = 55 // Lasers have a wound bonus of 40, this is a bit higher
	wound_bonus = -50 // However we do not very much against armor
	range = 2
	pass_flags = PASSTABLE | PASSGRILLE // His ass does NOT pass through glass!
	weak_against_armour = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = COLOR_PALE_GREEN

/obj/item/grenade/c980payload/plasma_grenade
	shrapnel_type = /obj/projectile/beam/cybersun_laser/granata_shrapnel
	shrapnel_radius = 3

// Shotgun casing for the big gun

/obj/item/ammo_casing/energy/cybersun_big_shotgun
	projectile_type = /obj/projectile/beam/cybersun_laser/granata_shrapnel/shotgun_pellet
	e_cost = 100
	pellets = 5
	variance = 30
	select_name = "Shotgun"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/melt.ogg'

/obj/projectile/beam/cybersun_laser/granata_shrapnel/shotgun_pellet
	icon_state = "because_it_doesnt_miss"
	damage = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	speed = 0.8
	light_color = COLOR_SCIENCE_PINK
	range = 9

// Hellfire lasers for the little guy

/obj/item/ammo_casing/energy/cybersun_small_hellfire
	projectile_type = /obj/projectile/beam/cybersun_laser/hellfire
	e_cost = 100
	select_name = "Incinerate"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/incinerate.ogg'

/obj/projectile/beam/cybersun_laser/hellfire
	icon_state = "hellfire"
	damage = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	speed = 0.6
	wound_bonus = -15
	light_color = COLOR_SOFT_RED

// Bounce disabler lasers for the little guy

/obj/item/ammo_casing/energy/cybersun_small_disabler
	projectile_type = /obj/projectile/beam/cybersun_laser/disable_bounce
	e_cost = 100
	select_name = "Disable"
	harmful = FALSE

/obj/projectile/beam/cybersun_laser/disable_bounce
	icon_state = "disable_bounce"
	damage = 0
	stamina = 45
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = COLOR_BRIGHT_BLUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 2
	ricochet_incidence_leeway = 100
	ricochet_chance = 130
	ricochet_decay_damage = 0.8

/obj/projectile/beam/cybersun_laser/disable_bounce/check_ricochet_flag(atom/reflecting_atom)
	if((reflecting_atom.flags_ricochet & RICOCHET_HARD) || (reflecting_atom.flags_ricochet & RICOCHET_SHINY))
		return TRUE
	return FALSE

// Flare launcher

/obj/item/ammo_casing/energy/cybersun_small_launcher
	projectile_type = /obj/projectile/beam/cybersun_laser/flare
	e_cost = LASER_SHOTS(5, 1000)
	select_name = "Flare"

/obj/projectile/beam/cybersun_laser/flare
	name = "plasma flare"
	icon_state = "flare"
	damage = 15
	speed = 2
	range = 6
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = COLOR_PALE_GREEN
	pass_flags = PASSTABLE | PASSGRILLE // His ass does NOT pass through glass!
	/// How many firestacks the bullet should impart upon a target when impacting
	var/firestacks_to_give = 2
	/// What we spawn when we range out
	var/obj/illumination_flare = /obj/item/flashlight/flare/plasma_projectile

/obj/projectile/beam/cybersun_laser/flare/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/gaslighter = target
		gaslighter.adjust_fire_stacks(firestacks_to_give)
		gaslighter.ignite_mob()
	else
		new illumination_flare(get_turf(target))

/obj/projectile/beam/cybersun_laser/flare/on_range()
	new illumination_flare(get_turf(src))
	return ..()

/obj/item/flashlight/flare/plasma_projectile
	name = "plasma flare"
	desc = "A burning glob of green plasma, makes an effective temporary lighting source."
	light_outer_range = 4
	anchored = TRUE
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/saibasan/projectiles.dmi'
	icon_state = "flare_burn"
	light_color = COLOR_PALE_GREEN
	light_power = 2

/obj/item/flashlight/flare/plasma_projectile/Initialize(mapload)
	. = ..()
	if(randomize_fuel)
		fuel = rand(3 MINUTES, 5 MINUTES)
	ignition()

/obj/item/flashlight/flare/plasma_projectile/turn_off()
	. = ..()
	qdel(src)

// Shotgun casing for the small gun

/obj/item/ammo_casing/energy/cybersun_small_shotgun
	projectile_type = /obj/projectile/beam/cybersun_laser/granata_shrapnel/shotgun_pellet
	e_cost = 100
	pellets = 3
	variance = 15
	select_name = "Shotgun"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/melt.ogg'

// Dummy casing that does nothing but have a projectile that looks like a sword

/obj/item/ammo_casing/energy/cybersun_small_blade
	projectile_type = /obj/projectile/beam/cybersun_laser/blade
	select_name = "Blade"

/obj/projectile/beam/cybersun_laser/blade
	icon_state = "blade"

/obj/item/ammo_box/advanced
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/*
*	9mm
*/

/obj/item/ammo_box/c9mm/rubber
	name = "9x25mm rubber box"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_box/c9mm/ihdf
	name = "9x25mm IHDF box"
	ammo_type = /obj/item/ammo_casing/c9mm/ihdf

/*
*	10mm
*/

/obj/item/ammo_box/c10mm/rubber
	name = "10mm auto rubber box"
	ammo_type = /obj/item/ammo_casing/c10mm/rubber

/obj/item/ammo_box/c10mm/ihdf
	name = "peacekeeper ammo box (10mm ihdf)"
	ammo_type = /obj/item/ammo_casing/c10mm/ihdf
