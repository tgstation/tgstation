/obj/projectile/bullet/shotgun_slug
	name = "12g shotgun slug"
	icon_state = "pellet"
	damage = 50
	sharpness = SHARP_POINTY
	wound_bonus = 0

/obj/projectile/bullet/shotgun/slug/syndie
	name = "12g syndicate shotgun slug"
	damage = 60

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
	icon_state = "pellet"
	damage = 10
	stamina = 55
	wound_bonus = 20
	sharpness = NONE
	embedding = null

/obj/projectile/bullet/shotgun_beanbag/a40mm
	name = "rubber slug"
	icon_state = "cannonball"
	damage = 20
	stamina = 160 //BONK
	wound_bonus = 30
	weak_against_armour = TRUE

/obj/projectile/bullet/incendiary/shotgun
	name = "incendiary slug"
	icon_state = "pellet"
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
	color = COLOR_YELLOW
	embedding = null

/obj/projectile/bullet/shotgun_frag12
	name ="frag12 slug"
	icon_state = "pellet"
	damage = 15
	paralyze = 10

/obj/projectile/bullet/shotgun_frag12/on_hit(atom/target, blocked = FALSE, pierce_hit)
	..()
	explosion(target, devastation_range = -1, light_impact_range = 1, explosion_cause = src)
	return BULLET_ACT_HIT

/obj/projectile/bullet/pellet/shotgun_buckshot
	name = "buckshot pellet"
	damage = 7.5
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -2.5 // low damage + additional dropoff will already curb wounding potential anything past point blank

/obj/projectile/bullet/pellet/shotgun_rubbershot
	name = "rubber shot pellet"
	damage = 3
	stamina = 11
	sharpness = NONE
	embedding = null
	speed = 1.2
	stamina_falloff_tile = -0.25
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
	damage = 5
	wound_bonus = -5
	demolition_mod = 3 //Very good at acts of vandalism

/obj/projectile/bullet/pellet/shotgun_improvised/Initialize(mapload)
	. = ..()
	range = rand(3, 8)

/obj/projectile/bullet/pellet/shotgun_improvised/on_range()
	do_sparks(1, TRUE, src)
	..()

/obj/projectile/bullet/pellet/shotgun_buckshot/syndie
	name = "syndicate buckshot pellet"
	damage = 14.5 //3.5 more damage so it sucks less?
	wound_bonus = 2
	bare_wound_bonus = 2
	armour_penetration = 0 //So it doesn't suffer against armor (it's for nukies only)

/obj/projectile/bullet/pellet/shotgun_flechette
	name = "flechette pellet"
	speed = 0.4 //You're special
	damage = 12
	wound_bonus = 4
	bare_wound_bonus = 4
	armour_penetration = 40
	wound_falloff_tile = -1

/obj/projectile/bullet/pellet/shotgun_clownshot
	name = "clownshot pellet"
	damage = 0
	hitsound = 'sound/items/bikehorn.ogg'

/obj/projectile/bullet/pellet/shotgun_cryoshot
	name = "cryoshot pellet"
	damage = 6
	var/temperature = 100

/obj/projectile/bullet/pellet/shotgun_cryoshot/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/carbon/H = target
		H.adjust_bodytemperature((temperature - H.bodytemperature))
		H.reagents.add_reagent(/datum/reagent/inverse/cryostylane, 10)

/obj/projectile/bullet/pellet/shotgun_thundershot
	name = "thundershot pellet"
	damage = 3
	hitsound = 'sound/magic/lightningbolt.ogg'
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN

/obj/projectile/bullet/pellet/shotgun_thundershot/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	tesla_zap(target, rand(2, 3), 17500, cutoff = 1e3, zap_flags = zap_flags)
	return BULLET_ACT_HIT

/obj/projectile/bullet/pellet/shotgun_anarchy
	name = "anarchy pellet"
	damage = 4 // 4x10 at point blank
	ricochets_max = 3
	reflect_range_decrease = 1
	ricochet_chance = 100
	ricochet_auto_aim_range = 5
	ricochet_auto_aim_angle = 30
	ricochet_incidence_leeway = 0

/obj/projectile/bullet/pellet/shotgun_anarchy/check_ricochet(atom/A)
	if(istype(A, /turf/closed))
		return TRUE
	return FALSE

/obj/projectile/bullet/pellet/shotgun_anarchy/check_ricochet_flag(atom/A)
	return TRUE

/obj/projectile/bullet/shotgun/slug/rip
	name = "ripslug"
	armour_penetration = -40 // aim for the legs :)
	damage =  50 //higher because two slugs at once, on par with syndi slugs but with negative AP out the whazoo, and more drop off

/obj/projectile/bullet/shotgun/slug/uranium
	name = "depleted uranium slug"
	icon_state = "ubullet"
	damage = 35 //Most certainly to drop below 3-shot threshold because of damage falloff
	armour_penetration = 60 // he he funny round go through armor
	wound_bonus = -40
	demolition_mod = 3 // very good at smashing through stuff
	projectile_piercing = ALL

/obj/projectile/bullet/pellet/hardlight
	name = "scattered hardlight beam"
	icon_state = "disabler_bullet"
	damage = 30
	armor_flag = ENERGY
	damage_type = STAMINA // Doesn't do "real" damage
	armour_penetration = -40

/obj/projectile/beam/laser/buckshot
	damage = 10

// Mech Scattershot

/obj/projectile/bullet/scattershot
	icon_state = "pellet"
	damage = 24

//Breaching Ammo

/obj/projectile/bullet/shotgun_breaching
	name = "12g breaching round"
	desc = "A breaching round designed to destroy airlocks and windows with only a few shots. Ineffective against other targets."
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	damage = 5 //does shit damage to everything except doors and windows
	demolition_mod = 200 //one shot to break a window or grille, or two shots to breach an airlock door
