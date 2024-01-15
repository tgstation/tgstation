// .40 Sol Long
// Rifle caliber caseless ammo that kills people good

/obj/item/ammo_casing/c40sol
	name = ".40 Sol Long lethal bullet casing"
	desc = "A SolFed standard caseless lethal rifle round."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "40sol"

	caliber = CALIBER_SOL40LONG
	projectile_type = /obj/projectile/bullet/c40sol


/obj/item/ammo_casing/c40sol/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)


/obj/projectile/bullet/c40sol
	name = ".40 Sol Long bullet"
	damage = 35

	wound_bonus = 10
	bare_wound_bonus = 20


/obj/item/ammo_box/c40sol
	name = "ammo box (.40 Sol Long lethal)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "40box"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	caliber = CALIBER_SOL40LONG
	ammo_type = /obj/item/ammo_casing/c40sol
	max_ammo = 30


// .40 Sol fragmentation rounds, embeds shrapnel in the target almost every time at close to medium range. Teeeechnically less lethals.

/obj/item/ammo_casing/c40sol/fragmentation
	name = ".40 Sol Long fragmentation bullet casing"
	desc = "A SolFed standard caseless fragmentation rifle round. Shatters upon impact, ejecting sharp shrapnel that can potentially incapacitate targets."

	icon_state = "40sol_disabler"

	projectile_type = /obj/projectile/bullet/c40sol/fragmentation

	advanced_print_req = TRUE

	harmful = FALSE


/obj/projectile/bullet/c40sol/fragmentation
	name = ".40 Sol Long fragmentation bullet"
	damage = 15
	stamina = 30

	weak_against_armour = TRUE

	sharpness = SHARP_EDGED
	wound_bonus = 0
	bare_wound_bonus = 10

	shrapnel_type = /obj/item/shrapnel/stingball
	embedding = list(
		embed_chance = 50,
		fall_chance = 5,
		jostle_chance = 5,
		ignore_throwspeed_threshold = TRUE,
		pain_stam_pct = 0.4,
		pain_mult = 2,
		jostle_pain_mult = 3,
		rip_time = 0.5 SECONDS,
	)

	embed_falloff_tile = -5


/obj/item/ammo_box/c40sol/fragmentation
	name = "ammo box (.40 Sol Long fragmentation)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets. The blue stripe indicates this should hold less lethal ammunition."

	icon_state = "40box_disabler"

	ammo_type = /obj/item/ammo_casing/c40sol/fragmentation


// .40 Sol match grade, bounces a lot, and if there's less than 20 bullet armor on wherever these hit, it'll go completely through the target and out the other side

/obj/item/ammo_casing/c40sol/pierce
	name = ".40 Sol Long match bullet casing"
	desc = "A SolFed standard caseless match grade rifle round. Fires at a higher pressure and thus fires slightly faster projectiles. \
		Rumors say you can do sick ass wall bounce trick shots with these, though the official suggestion is to just shoot your target and \
		not the wall next to them."

	icon_state = "40sol_pierce"

	projectile_type = /obj/projectile/bullet/c40sol/pierce

	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE


/obj/projectile/bullet/c40sol/pierce
	name = ".40 Sol match bullet"

	icon_state = "gaussphase"

	speed = 0.5

	damage = 25
	armour_penetration = 20

	wound_bonus = -30
	bare_wound_bonus = -10

	ricochets_max = 2
	ricochet_chance = 80
	ricochet_auto_aim_range = 4
	ricochet_incidence_leeway = 65

	projectile_piercing = PASSMOB


/obj/projectile/bullet/c40sol/pierce/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/poor_sap = target

		// If the target mob has enough armor to stop the bullet, or the bullet has already gone through two people, stop it on this hit
		if((poor_sap.run_armor_check(def_zone, BULLET, "", "", silent = TRUE) > 20) || (pierces > 2))
			projectile_piercing = NONE

			if(damage > 10) // Lets just be safe with this one
				damage -= 5
			armour_penetration -= 10

	return ..()


/obj/item/ammo_box/c40sol/pierce
	name = "ammo box (.40 Sol Long match)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets. The yellow stripe indicates this should hold high performance ammuniton."

	icon_state = "40box_pierce"

	ammo_type = /obj/item/ammo_casing/c40sol/pierce


// .40 Sol incendiary

/obj/item/ammo_casing/c40sol/incendiary
	name = ".40 Sol Long incendiary bullet casing"
	desc = "A SolFed standard caseless incendiary rifle round. Leaves no flaming trail, only igniting targets on impact."

	icon_state = "40sol_flame"

	projectile_type = /obj/projectile/bullet/c40sol/incendiary

	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE


/obj/projectile/bullet/c40sol/incendiary
	name = ".40 Sol Long incendiary bullet"
	icon_state = "redtrac"

	damage = 25

	/// How many firestacks the bullet should impart upon a target when impacting
	var/firestacks_to_give = 1


/obj/projectile/bullet/c40sol/incendiary/on_hit(atom/target, blocked = FALSE)
	. = ..()

	if(iscarbon(target))
		var/mob/living/carbon/gaslighter = target
		gaslighter.adjust_fire_stacks(firestacks_to_give)
		gaslighter.ignite_mob()


/obj/item/ammo_box/c40sol/incendiary
	name = "ammo box (.40 Sol Long incendiary)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets. The orange stripe indicates this should hold incendiary ammunition."

	icon_state = "40box_flame"

	ammo_type = /obj/item/ammo_casing/c40sol/incendiary
