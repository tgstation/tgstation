// MARK: .35 Sol
/obj/projectile/bullet/c35sol
	name = ".35 Sol Short bullet"
	damage = 17
	wound_bonus = -5
	exposed_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c35sol/rubber
	name = ".35 Sol Short rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -40
	exposed_wound_bonus = -20
	weak_against_armour = TRUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c35sol/hp
	name = ".35 Sol hollow-point bullet"
	damage = 15
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 20
	exposed_wound_bonus = 20
	embed_type = /datum/embedding/bullet/c35sol/hp
	embed_falloff_tile = -15

/datum/embedding/bullet/c35sol/hp
	embed_chance = 75
	fall_chance = 3
	jostle_chance = 4
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 5
	jostle_pain_mult = 6
	rip_time = 1 SECONDS

/obj/projectile/bullet/c35sol/ap
	name = ".35 Sol Short armor-piercing bullet"
	damage = 15
	exposed_wound_bonus = -30
	armour_penetration = 40
	shrapnel_type = null
	embed_type = null

//  MARK: 7.62x39mm
/obj/projectile/bullet/c762x39
	name = "7.62x39mm bullet"
	damage = 30
	wound_bonus = 5
	armour_penetration = 10
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c762x39/rubber
	name = "7.62x39mm rubber bullet"
	damage = 5
	stamina = 25
	armour_penetration = 0
	ricochets_max = 4
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embed_type = null
	wound_bonus = -40
	exposed_wound_bonus = -20
	weak_against_armour = TRUE

/obj/projectile/bullet/c762x39/ricochet
	name = "7.62x39mm match bullet"
	damage = 25
	armour_penetration = 5
	ricochets_max = 5
	ricochet_chance = 100
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 15
	ricochet_incidence_leeway = 40
	ricochet_decay_damage = 1
	ricochet_shoots_firer = FALSE

/obj/projectile/bullet/incendiary/c762x39
	name = "7.62x39mm incendiary bullet"
	damage = 30
	wound_falloff_tile = -5
	fire_stacks = 2
	leaves_fire_trail = FALSE

/obj/projectile/bullet/c762x39/emp
	name = "7.62x39mm ion bullet"
	damage = 25
	wound_bonus = 0
	armour_penetration = 5
	var/heavy_emp_radius = -1
	var/light_emp_radius = 0

/obj/projectile/bullet/c762x39/emp/on_hit(atom/target, blocked = FALSE, pierce_hit)
	..()
	empulse(target, heavy_emp_radius, light_emp_radius)
	return BULLET_ACT_HIT

/obj/projectile/bullet/c762x39/civilian
	name = "7.62x39mm civilian bullet"
	damage = 25
	wound_bonus = 0
	armour_penetration = 0

/obj/projectile/bullet/c762x39/hunting
	name = "7.62x39mm hunting bullet"
	damage = 20
	wound_bonus = 10
	armour_penetration = 0
	weak_against_armour = TRUE
	/// Bonus force dealt against certain mobs
	var/nemesis_bonus_force = 30
	/// List (not really a list) of mobs we deal bonus damage to
	var/list/nemesis_path = /mob/living/basic

/obj/projectile/bullet/c762x39/hunting/prehit_pierce(mob/living/target, mob/living/carbon/human/user)
	if(istype(target, nemesis_path))
		damage += nemesis_bonus_force
	.=..()

/obj/projectile/bullet/c762x39/blank
	name = "hot gas"
	icon = 'icons/obj/weapons/guns/projectiles_muzzle.dmi'
	icon_state = "muzzle_bullet"
	damage = 5
	damage_type = BURN
	wound_bonus = -100
	armour_penetration = 0
	weak_against_armour = TRUE
	range = 0.01
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c762x39/ap
	name = "7.62x39mm armor-piercing bullet"
	damage = 25
	armour_penetration = 50
	wound_bonus = 0
	exposed_wound_bonus = 0
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c762x39/gauss
	icon = 'modular_bandastation/weapon/icons/ranged/projectiles.dmi'
	icon_state = "gauss_amk"
	name = "7.62x39mm gauss bullet"
	damage = 35
	wound_bonus = 15
	armour_penetration = 50
	projectile_piercing = PASSMOB | PASSTABLE | PASSGRILLE | PASSMACHINE | PASSDOORS
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_BLUE
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c762x39/gauss/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		if(blocked > 50 || pierces > 2)
			projectile_piercing = NONE
			damage = max(0, damage - 20)
			armour_penetration = max(0, armour_penetration - 20)
			wound_bonus = max(0, wound_bonus - 10)

	return ..()

// MARK: .40 Sol Long
/obj/projectile/bullet/c40sol
	name = ".40 Sol Long bullet"
	damage = 35
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c40sol/fragmentation
	name = ".40 Sol Long rubber-fragmentation bullet"
	damage = 5
	stamina = 25
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = -10
	exposed_wound_bonus = 10
	armour_penetration = 0
	shrapnel_type = /obj/item/shrapnel/stingball
	embed_type = /datum/embedding/c40sol_fragmentation
	embed_falloff_tile = -5

/datum/embedding/c40sol_fragmentation
	embed_chance = 50
	fall_chance = 5
	jostle_chance = 5
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 2
	jostle_pain_mult = 3
	rip_time = 0.5 SECONDS

/obj/projectile/bullet/c40sol/ap
	name = ".40 Sol armor-piercing bullet"
	icon_state = "gaussphase"
	damage = 30
	armour_penetration = 60
	speed = 2
	wound_bonus = 0
	exposed_wound_bonus = 0
	projectile_piercing = PASSMOB | PASSTABLE | PASSGRILLE | PASSMACHINE | PASSDOORS
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c40sol/ap/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		if(blocked > 40 || pierces > 2)
			projectile_piercing = NONE
			damage = max(0, damage - 15)
			armour_penetration = max(0, armour_penetration - 15)

	return ..()

/obj/projectile/bullet/incendiary/c40sol
	name = ".40 Sol Long incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 30
	fire_stacks = 2
	leaves_fire_trail = FALSE

// MARK: .50 BMG
/obj/projectile/bullet/p50/mmg
	name =".50 BMG caseless bullet"
	damage = 40
	armour_penetration = 0
	paralyze = 0
	dismemberment = 0
	catastropic_dismemberment = FALSE
	icon_state = "gaussstrong"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

// MARK: 9x25mm NT
/obj/projectile/bullet/c9x25mm
	name = "9x25mm NT bullet"
	damage = 17
	wound_bonus = -5
	exposed_wound_bonus = 5
	embed_falloff_tile = -4

/obj/projectile/bullet/c9x25mm/rubber
	name = "9x25mm NT rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -40
	exposed_wound_bonus = -20
	weak_against_armour = TRUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

/obj/projectile/bullet/c9x25mm/hp
	name = "9x25mm NT hollow-point bullet"
	damage = 15
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 20
	exposed_wound_bonus = 20
	embed_type = /datum/embedding/bullet/c9x25mm/hp
	embed_falloff_tile = -15

/datum/embedding/bullet/c9x25mm/hp
	embed_chance = 75
	fall_chance = 3
	jostle_chance = 4
	ignore_throwspeed_threshold = TRUE
	pain_stam_pct = 0.4
	pain_mult = 5
	jostle_pain_mult = 6
	rip_time = 1 SECONDS

/obj/projectile/bullet/c9x25mm/ap
	name = "9x25mm NT armor-piercing bullet"
	damage = 15
	exposed_wound_bonus = -30
	armour_penetration = 40
	shrapnel_type = null
	embed_type = null

// MARK: .223 aka 5.56mm
/obj/projectile/bullet/a223
	name = "5.56x45mm bullet"
	damage = 30
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/a223/rubber
	name = "5.56x45mm rubber bullet"
	damage = 5
	stamina = 25
	armour_penetration = 0
	wound_bonus = -40
	exposed_wound_bonus = -20
	weak_against_armour = TRUE

/obj/projectile/bullet/a223/hp
	name = "5.56x45mm hollow-point bullet"
	damage = 35
	armour_penetration = 0
	wound_bonus = 30
	exposed_wound_bonus = 30
	weak_against_armour = TRUE

/obj/projectile/bullet/a223/ap
	name = "5.56x45mm armor-piercing bullet"
	damage = 25
	armour_penetration = 50
	wound_bonus = 0
	exposed_wound_bonus = 0
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/incendiary/a223
	name = "5.56x45mm incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 25
	fire_stacks = 2
	leaves_fire_trail = FALSE

// MARK: 7.62x51mm
/obj/projectile/bullet/c762x51mm
	name = "7.62x51mm bullet"
	damage = 35
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c762x51mm/rubber
	name = "7.62x51mm rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -40
	exposed_wound_bonus = -20
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = NONE

/obj/projectile/bullet/c762x51mm/hp
	name = "7.62x51mm hollow-point bullet"
	damage = 40
	wound_bonus = 30
	exposed_wound_bonus = 30
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/c762x51mm/ap
	name = "7.62x51mm armor-piercing bullet"
	damage = 30
	wound_bonus = 0
	exposed_wound_bonus = 0
	armour_penetration = 60
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/incendiary/c762x51mm
	name = "7.62x51mm incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 30
	fire_stacks = 3
	leaves_fire_trail = FALSE

// MARK: .388 aka 8.6x70mm
/obj/projectile/bullet/c338
	name = ".338 bullet"
	damage = 55
	range = 80
	wound_bonus = 20
	exposed_wound_bonus = 15
	armour_penetration = 30
	wound_falloff_tile = -1
	speed = 2

/obj/projectile/bullet/c338/ap
	name = ".338 armor-piercing bullet"
	damage = 50
	wound_bonus = 0
	exposed_wound_bonus = 0
	armour_penetration = 75
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/c338/hp
	name = ".338 hollow-point bullet"
	damage = 60
	wound_bonus = 45
	exposed_wound_bonus = 45
	armour_penetration = 10
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/incendiary/c338
	name = ".338 incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 50
	fire_stacks = 4
	leaves_fire_trail = FALSE

// MARK: .38
/obj/projectile/bullet/c38/ap
	name = ".38 armor-piercing bullet"
	damage = 20
	ricochets_max = 0
	armour_penetration = 40

// MARK: 9mm
/obj/projectile/bullet/c9mm/rubber
	name = "9mm rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -20
	exposed_wound_bonus = -20
	weak_against_armour = TRUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

// MARK: 10mm
/obj/projectile/bullet/c10mm/rubber
	name = "10mm rubber bullet"
	damage = 5
	stamina = 25
	wound_bonus = -40
	exposed_wound_bonus = -20
	weak_against_armour = TRUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

// MARK: .45
/obj/projectile/bullet/c45/rubber
	name = ".45 rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -20
	exposed_wound_bonus = -20
	weak_against_armour = TRUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

// MARK: 4.6x30mm
/obj/projectile/bullet/c46x30mm/rubber
	name = "4.6x30mm rubber bullet"
	damage = 5
	stamina = 20
	wound_bonus = -20
	exposed_wound_bonus = -20
	weak_against_armour = TRUE
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = null
	sharpness = NONE
	embed_type = null

// MARK: .310 Strilka
/obj/projectile/bullet/strilka310/rubber
	name = ".310 Strilka rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -40
	exposed_wound_bonus = -20
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = NONE

/obj/projectile/bullet/strilka310/ap
	name = ".310 Strilka armor-piercing bullet"
	damage = 50
	armour_penetration = 60
	wound_bonus = 0

/obj/projectile/bullet/strilka310/hp
	name = ".310 Strilka hollow-point bullet"
	damage = 60
	wound_bonus = 45
	exposed_wound_bonus = 45
	armour_penetration = 10
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/incendiary/strilka310
	name = ".310 Strilka incendiary bullet"
	icon_state = "redtrac"
	damage = 40
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	fire_stacks = 3
	leaves_fire_trail = FALSE

// MARK: .60 Strela
/obj/projectile/bullet/p50/strela60
	name =".60 Strela bullet"
	damage = 80
	icon_state = "gaussstrong"
	speed = 2
	range = 100
	damage = 50
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

// MARK: 12.7x108mm
/obj/projectile/bullet/c127x108mm
	name ="12.7x108mm bullet"
	icon_state = "gaussstrong"
	speed = 2
	range = 100
	damage = 50
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

// MARK: 7.62x54mmR
/obj/projectile/bullet/c762x54mmr
	name = "7.62x54mmR bullet"
	damage = 35
	armour_penetration = 10
	wound_bonus = 5
	exposed_wound_bonus = 5
	wound_falloff_tile = -3

/obj/projectile/bullet/c762x54mmr/rubber
	name = "7.62x54mmR rubber bullet"
	damage = 5
	stamina = 30
	wound_bonus = -40
	exposed_wound_bonus = -20
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = NONE

/obj/projectile/bullet/c762x54mmr/hp
	name = "7.62x54mmR hollow-point bullet"
	damage = 40
	wound_bonus = 30
	exposed_wound_bonus = 30
	armour_penetration = 0
	weak_against_armour = TRUE
	sharpness = SHARP_EDGED

/obj/projectile/bullet/c762x54mmr/ap
	name = "7.62x54mmR armor-piercing bullet"
	damage = 30
	wound_bonus = 0
	exposed_wound_bonus = 0
	armour_penetration = 60
	shrapnel_type = null
	embed_type = null

/obj/projectile/bullet/incendiary/c762x54mmr
	name = "7.62x54mmR incendiary bullet"
	icon_state = "redtrac"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_INTENSE_RED
	damage = 30
	fire_stacks = 3
	leaves_fire_trail = FALSE

// MARK: .456 Magnum
/obj/projectile/bullet/c456magnum
	name = ".456 magnum bullet"
	damage = 60
	armour_penetration = 40
	wound_falloff_tile = -1

//MARK: Shotgun shells
/obj/projectile/bullet/shotgun_breaching/on_hit(atom/target, blocked = 0, pierce_hit)
	if(istype(target, /obj/structure/blob) || istype(target, /obj/structure/carp_rift) || istype(target, /obj/vehicle))
		target.take_damage(30, damage_type, 0)
		return BULLET_ACT_BLOCK
	return ..()

//MARK: NTR cane projectile

/obj/projectile/bullet/nt_cane_diamond
	name = "diamond shot"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "energy2"
	damage = 35
	speed = 2.5
	armour_penetration = 10
	paralyze = 5
	damage_type = BRUTE
