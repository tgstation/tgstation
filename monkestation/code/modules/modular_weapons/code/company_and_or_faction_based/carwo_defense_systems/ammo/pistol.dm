// .35 Sol Short
// Pistol caliber caseless round used almost exclusively by SolFed weapons

/obj/item/ammo_casing/c35sol
	name = ".35 Sol Short lethal bullet casing"
	desc = "A SolFed standard caseless lethal pistol round."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "35sol"

	caliber = CALIBER_SOL35SHORT
	projectile_type = /obj/projectile/bullet/c35sol


/obj/item/ammo_casing/c35sol/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)


/obj/projectile/bullet/c35sol
	name = ".35 Sol Short bullet"
	damage = 25

	wound_bonus = 10 // Normal bullets are 20
	bare_wound_bonus = 20


/obj/item/ammo_box/c35sol
	name = "ammo box (.35 Sol Short lethal)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "35box"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	caliber = CALIBER_SOL35SHORT
	ammo_type = /obj/item/ammo_casing/c35sol
	max_ammo = 24


// .35 Sol's equivalent to a rubber bullet

/obj/item/ammo_casing/c35sol/incapacitator
	name = ".35 Sol Short incapacitator bullet casing"
	desc = "A SolFed standard caseless less-lethal pistol round. Exhausts targets on hit, has a tendency to bounce off walls at shallow angles."

	icon_state = "35sol_disabler"

	projectile_type = /obj/projectile/bullet/c35sol/incapacitator
	harmful = FALSE


/obj/projectile/bullet/c35sol/incapacitator
	name = ".35 Sol Short incapacitator bullet"
	damage = 5
	stamina = 30

	wound_bonus = -40
	bare_wound_bonus = -20

	weak_against_armour = TRUE

	// The stats of the ricochet are a nerfed version of detective revolver rubber ammo
	// This is due to the fact that there's a lot more rounds fired quickly from weapons that use this, over a revolver
	ricochet_auto_aim_angle = 30
	ricochet_auto_aim_range = 5
	ricochets_max = 4
	ricochet_incidence_leeway = 50
	ricochet_chance = 130
	ricochet_decay_damage = 0.8

	shrapnel_type = null
	sharpness = NONE
	embedding = null


/obj/item/ammo_box/c35sol/incapacitator
	name = "ammo box (.35 Sol Short incapacitator)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds. The blue stripe indicates this should hold less-lethal ammunition."

	icon_state = "35box_disabler"

	ammo_type = /obj/item/ammo_casing/c35sol/incapacitator


// .35 Sol ripper, similar to the detective revolver's dumdum rounds, causes slash wounds and is weak to armor

/obj/item/ammo_casing/c35sol/ripper
	name = ".35 Sol Short ripper bullet casing"
	desc = "A SolFed standard caseless ripper pistol round. Causes slashing wounds on targets, but is weak to armor."

	icon_state = "35sol_shrapnel"
	projectile_type = /obj/projectile/bullet/c35sol/ripper

	custom_materials = AMMO_MATS_RIPPER
	advanced_print_req = TRUE


/obj/projectile/bullet/c35sol/ripper
	name = ".35 Sol ripper bullet"
	damage = 15

	weak_against_armour = TRUE

	sharpness = SHARP_EDGED

	wound_bonus = 20
	bare_wound_bonus = 20

	embedding = list(
		embed_chance = 75,
		fall_chance = 3,
		jostle_chance = 4,
		ignore_throwspeed_threshold = TRUE,
		pain_stam_pct = 0.4,
		pain_mult = 5,
		jostle_pain_mult = 6,
		rip_time = 1 SECONDS,
	)

	embed_falloff_tile = -15


/obj/item/ammo_box/c35sol/ripper
	name = "ammo box (.35 Sol Short ripper)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds. The purple stripe indicates this should hold hollowpoint-like ammunition."

	icon_state = "35box_shrapnel"

	ammo_type = /obj/item/ammo_casing/c35sol/ripper
