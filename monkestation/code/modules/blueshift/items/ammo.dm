#define AMMO_MATS_GRENADE list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4, \
)

#define AMMO_MATS_GRENADE_SHRAPNEL list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
	/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 2, \
)

#define AMMO_MATS_GRENADE_INCENDIARY list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
	/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 2, \
)

#define GRENADE_SMOKE_RANGE 0.75

/obj/item/ammo_box
	/// When inserted into an ammo workbench, does this ammo box check for parent ammunition to search for subtypes of? Relevant for surplus clips, multi-sprite magazines.
	/// Maybe don't enable this for shotgun ammo boxes.
	var/multitype = TRUE

// .980 grenades
// Grenades that can be given a range to detonate at by their firing gun

/obj/item/ammo_casing/c980grenade
	name = ".980 Tydhouer practice grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Practice shells disintegrate into harmless sparks."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "980_solid"

	caliber = CALIBER_980TYDHOUER
	projectile_type = /obj/projectile/bullet/c980grenade

	custom_materials = AMMO_MATS_GRENADE

	harmful = FALSE //Erm, technically


/obj/item/ammo_casing/c980grenade/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	var/obj/item/gun/ballistic/automatic/sol_grenade_launcher/firing_launcher = fired_from
	if(istype(firing_launcher))
		loaded_projectile.range = firing_launcher.target_range

	. = ..()


/obj/projectile/bullet/c980grenade
	name = ".980 Tydhouer practice grenade"
	damage = 20
	stamina = 30

	range = 14

	speed = 2 // Higher means slower, y'all

	sharpness = NONE


/obj/projectile/bullet/c980grenade/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	fuse_activation(target)
	return BULLET_ACT_HIT


/obj/projectile/bullet/c980grenade/on_range()
	fuse_activation(get_turf(src))
	return ..()


/// Generic proc that is called when the projectile should 'detonate', being either on impact or when the range runs out
/obj/projectile/bullet/c980grenade/proc/fuse_activation(atom/target)
	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)
	do_sparks(3, FALSE, src)


/obj/item/ammo_box/c980grenade
	name = "ammo box (.980 Tydhouer practice)"
	desc = "A box of four .980 Tydhouer practice grenades. Instructions on the box indicate these are dummy practice rounds that will disintegrate into sparks on detonation. Neat!"

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "980box_solid"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	caliber = CALIBER_980TYDHOUER
	ammo_type = /obj/item/ammo_casing/c980grenade
	max_ammo = 4


// .980 smoke grenade

/obj/item/ammo_casing/c980grenade/smoke
	name = ".980 Tydhouer smoke grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Bursts into a laser-weakening smoke cloud."

	icon_state = "980_smoke"

	projectile_type = /obj/projectile/bullet/c980grenade/smoke


/obj/projectile/bullet/c980grenade/smoke
	name = ".980 Tydhouer smoke grenade"


/obj/projectile/bullet/c980grenade/smoke/fuse_activation(atom/target)
	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()


/obj/item/ammo_box/c980grenade/smoke
	name = "ammo box (.980 Tydhouer smoke)"
	desc = "A box of four .980 Tydhouer smoke grenades. Instructions on the box indicate these are smoke rounds that will make a small cloud of laser-dampening smoke on detonation."

	icon_state = "980box_smoke"

	ammo_type = /obj/item/ammo_casing/c980grenade/smoke


// .980 shrapnel grenade

/obj/item/ammo_casing/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Explodes into shrapnel on detonation."

	icon_state = "980_explosive"

	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel

	custom_materials = AMMO_MATS_GRENADE_SHRAPNEL
	advanced_print_req = TRUE

	harmful = TRUE


/obj/projectile/bullet/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"

	/// What type of casing should we put inside the bullet to act as shrapnel later
	var/casing_to_spawn = /obj/item/grenade/c980payload


/obj/projectile/bullet/c980grenade/shrapnel/fuse_activation(atom/target)
	var/obj/item/grenade/shrapnel_maker = new casing_to_spawn(get_turf(src))

	shrapnel_maker.detonate()
	qdel(shrapnel_maker)

	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)


/obj/item/ammo_box/c980grenade/shrapnel
	name = "ammo box (.980 Tydhouer shrapnel)"
	desc = "A box of four .980 Tydhouer shrapnel grenades. Instructions on the box indicate these are shrapnel rounds. Its also covered in hazard signs, odd."

	icon_state = "980box_explosive"

	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel


/obj/item/grenade/c980payload
	shrapnel_type = /obj/projectile/bullet/shrapnel/short_range
	shrapnel_radius = 2
	ex_dev = 0
	ex_heavy = 0
	ex_light = 0
	ex_flame = 0


/obj/projectile/bullet/shrapnel/short_range
	range = 2


// .980 phosphor grenade

/obj/item/ammo_casing/c980grenade/shrapnel/phosphor
	name = ".980 Tydhouer phosphor grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Explodes into smoke and flames on detonation."

	icon_state = "980_gas_alternate"

	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel/phosphor

	custom_materials = AMMO_MATS_GRENADE_INCENDIARY


/obj/projectile/bullet/c980grenade/shrapnel/phosphor
	name = ".980 Tydhouer phosphor grenade"

	casing_to_spawn = /obj/item/grenade/c980payload/phosphor


/obj/projectile/bullet/c980grenade/shrapnel/phosphor/fuse_activation(atom/target)
	. = ..()

	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/quick/smoke = new
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()


/obj/item/ammo_box/c980grenade/shrapnel/phosphor
	name = "ammo box (.980 Tydhouer phosphor)"
	desc = "A box of four .980 Tydhouer phosphor grenades. Instructions on the box indicate these are incendiary explosive rounds. Its also covered in hazard signs, odd."

	icon_state = "980box_gas_alternate"

	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor


/obj/item/ammo_casing/shrapnel_exploder/phosphor
	pellets = 8

	projectile_type = /obj/projectile/bullet/incendiary/fire/backblast/short_range


/obj/item/grenade/c980payload/phosphor
	shrapnel_type = /obj/projectile/bullet/incendiary/fire/backblast/short_range


/obj/projectile/bullet/incendiary/fire/backblast/short_range
	range = 2


// .980 tear gas grenade

/obj/item/ammo_casing/c980grenade/riot
	name = ".980 Tydhouer tear gas grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Bursts into a tear gas cloud."

	icon_state = "980_gas"

	projectile_type = /obj/projectile/bullet/c980grenade/riot


/obj/projectile/bullet/c980grenade/riot
	name = ".980 Tydhouer tear gas grenade"

/obj/projectile/bullet/c980grenade/riot/fuse_activation(atom/target)
	playsound(src, 'monkestation/code/modules/blueshift/sounds/grenade_burst.ogg', 50, TRUE, -3)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new()
	smoke.chemholder.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10)
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()


/obj/item/ammo_box/c980grenade/riot
	name = "ammo box (.980 Tydhouer tear gas)"
	desc = "A box of four .980 Tydhouer tear gas grenades. Instructions on the box indicate these are smoke rounds that will make a small cloud of laser-dampening smoke on detonation."

	icon_state = "980box_gas"

	ammo_type = /obj/item/ammo_casing/c980grenade/riot

#undef AMMO_MATS_GRENADE
#undef AMMO_MATS_GRENADE_SHRAPNEL
#undef AMMO_MATS_GRENADE_INCENDIARY

#undef GRENADE_SMOKE_RANGE

// .35 Sol Short
// Pistol caliber caseless round used almost exclusively by SolFed weapons

/obj/item/ammo_casing/c35sol
	name = ".35 Sol Short lethal bullet casing"
	desc = "A SolFed standard caseless lethal pistol round."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "35sol"

	caliber = CALIBER_SOL35SHORT
	projectile_type = /obj/projectile/bullet/c35sol


/obj/item/ammo_casing/c35sol/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)


/obj/projectile/bullet/c35sol
	name = ".35 Sol Short bullet"
	damage = 20

	wound_bonus = -5 // Normal bullets are 20
	bare_wound_bonus = 5
	embed_falloff_tile = -4


/obj/item/ammo_box/c35sol
	name = "ammo box (.35 Sol Short lethal)"
	desc = "A box of .35 Sol Short pistol rounds, holds twenty-four rounds."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
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

// .40 Sol Long
// Rifle caliber caseless ammo that kills people good

/obj/item/ammo_casing/c40sol
	name = ".40 Sol Long lethal bullet casing"
	desc = "A SolFed standard caseless lethal rifle round."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
	icon_state = "40sol"

	caliber = CALIBER_SOL40LONG
	projectile_type = /obj/projectile/bullet/c40sol


/obj/item/ammo_casing/c40sol/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)


/obj/projectile/bullet/c40sol
	name = ".40 Sol Long bullet"
	damage = 20

	wound_bonus = 10
	bare_wound_bonus = 20


/obj/item/ammo_box/c40sol
	name = "ammo box (.40 Sol Long lethal)"
	desc = "A box of .40 Sol Long rifle rounds, holds thirty bullets."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
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
	damage = 10
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

	damage = 15
	armour_penetration = 20

	wound_bonus = -30
	bare_wound_bonus = -10

	ricochets_max = 2
	ricochet_chance = 80
	ricochet_auto_aim_range = 4
	ricochet_incidence_leeway = 65

	projectile_piercing = PASSMOB


/obj/projectile/bullet/c40sol/pierce/on_hit(atom/target, blocked = 0, pierce_hit)
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

	damage = 15

	/// How many firestacks the bullet should impart upon a target when impacting
	var/firestacks_to_give = 1


/obj/projectile/bullet/c40sol/incendiary/on_hit(atom/target, blocked = 0, pierce_hit)
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

/*
*	.310 Strilka
*/

/obj/item/ammo_casing/strilka310/rubber
	name = ".310 Strilka rubber bullet casing"
	desc = "A .310 rubber bullet casing. Casing is a bit of a fib, there isn't one.\
	<br><br>\
	<i>RUBBER: Less than lethal ammo. Deals both stamina damage and regular damage.</i>"

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/ammo.dmi'
	icon_state = "310-casing-rubber"

	projectile_type = /obj/projectile/bullet/strilka310/rubber
	harmful = FALSE

/obj/projectile/bullet/strilka310/rubber
	name = ".310 rubber bullet"
	damage = 10
	stamina = 55
	ricochets_max = 5
	ricochet_incidence_leeway = 0
	ricochet_chance = 130
	ricochet_decay_damage = 0.7
	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/item/ammo_casing/strilka310/ap
	name = ".310 Strilka armor-piercing bullet casing"
	desc = "A .310 armor-piercing bullet casing. Note, does not actually contain a casing.\
	<br><br>\
	<i>ARMOR-PIERCING: Improved armor-piercing capabilities, in return for less outright damage.</i>"

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/xhihao_light_arms/ammo.dmi'
	icon_state = "310-casing-ap"

	projectile_type = /obj/projectile/bullet/strilka310/ap
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/projectile/bullet/strilka310/ap
	name = ".310 armor-piercing bullet"
	damage = 50
	armour_penetration = 60

// .585 Trappiste
// High caliber round used in large pistols and revolvers

/obj/item/ammo_casing/c585trappiste
	name = ".585 Trappiste lethal bullet casing"
	desc = "A white polymer cased high caliber round commonly used in handguns."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/ammo.dmi'
	icon_state = "585trappiste"

	caliber = CALIBER_585TRAPPISTE
	projectile_type = /obj/projectile/bullet/c585trappiste

/obj/projectile/bullet/c585trappiste
	name = ".585 Trappiste bullet"
	damage = 25
	wound_bonus = 0 // Normal bullets are 20

/obj/item/ammo_box/c585trappiste
	name = "ammo box (.585 Trappiste lethal)"
	desc = "A box of .585 Trappiste pistol rounds, holds twelve cartridges."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/trappiste_fabriek/ammo.dmi'
	icon_state = "585box"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	caliber = CALIBER_585TRAPPISTE
	ammo_type = /obj/item/ammo_casing/c585trappiste
	max_ammo = 12

// .585 Trappiste equivalent to a rubber bullet

/obj/item/ammo_casing/c585trappiste/incapacitator
	name = ".585 Trappiste flathead bullet casing"
	desc = "A white polymer cased high caliber round with a relatively soft, flat tip. Designed to flatten against targets and usually not penetrate on impact."

	icon_state = "585trappiste_disabler"

	projectile_type = /obj/projectile/bullet/c585trappiste/incapacitator
	harmful = FALSE

/obj/projectile/bullet/c585trappiste/incapacitator
	name = ".585 Trappiste flathead bullet"
	damage = 9
	stamina = 40
	wound_bonus = 10

	weak_against_armour = TRUE

	shrapnel_type = null
	sharpness = NONE
	embedding = null

/obj/item/ammo_box/c585trappiste/incapacitator
	name = "ammo box (.585 Trappiste flathead)"
	desc = "A box of .585 Trappiste pistol rounds, holds twelve cartridges. The blue stripe indicates that it should hold less lethal rounds."

	icon_state = "585box_disabler"

	ammo_type = /obj/item/ammo_casing/c585trappiste/incapacitator

// .585 hollowpoint, made to cause nasty wounds

/obj/item/ammo_casing/c585trappiste/hollowpoint
	name = ".585 Trappiste hollowhead bullet casing"
	desc = "A white polymer cased high caliber round with a hollowed tip. Designed to cause as much damage on impact to fleshy targets as possible."

	icon_state = "585trappiste_shrapnel"
	projectile_type = /obj/projectile/bullet/c585trappiste/hollowpoint

	advanced_print_req = TRUE

/obj/projectile/bullet/c585trappiste/hollowpoint
	name = ".585 Trappiste hollowhead bullet"
	damage = 25

	weak_against_armour = TRUE

	wound_bonus = 30
	bare_wound_bonus = 40

/obj/item/ammo_box/c585trappiste/hollowpoint
	name = "ammo box (.585 Trappiste hollowhead)"
	desc = "A box of .585 Trappiste pistol rounds, holds twelve cartridges. The purple stripe indicates that it should hold hollowpoint-like rounds."

	icon_state = "585box_shrapnel"

	ammo_type = /obj/item/ammo_casing/c585trappiste/hollowpoint

// .27-54 Cesarzowa
// Small caliber pistol round meant to be fired out of something that shoots real quick like

/obj/item/ammo_casing/c27_54cesarzowa
	name = ".27-54 Cesarzowa piercing bullet casing"
	desc = "A purple-bodied caseless cartridge home to a small projectile with a fine point."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "27-54cesarzowa"

	caliber = CALIBER_CESARZOWA
	projectile_type = /obj/projectile/bullet/c27_54cesarzowa

/obj/item/ammo_casing/c27_54cesarzowa/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)

/obj/projectile/bullet/c27_54cesarzowa
	name = ".27-54 Cesarzowa piercing bullet"
	damage = 15
	armour_penetration = 30
	wound_bonus = -30
	bare_wound_bonus = -10

/obj/item/ammo_box/c27_54cesarzowa
	name = "ammo box (.27-54 Cesarzowa piercing)"
	desc = "A box of .27-54 Cesarzowa piercing pistol rounds, holds eighteen cartridges."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "27-54cesarzowa_box"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	caliber = CALIBER_CESARZOWA
	ammo_type = /obj/item/ammo_casing/c27_54cesarzowa
	max_ammo = 18

// .27-54 Cesarzowa rubber
// Small caliber pistol round meant to be fired out of something that shoots real quick like, this one is less lethal

/obj/item/ammo_casing/c27_54cesarzowa/rubber
	name = ".27-54 Cesarzowa rubber bullet casing"
	desc = "A purple-bodied caseless cartridge home to a small projectile with a flat rubber tip."

	icon_state = "27-54cesarzowa_rubber"

	projectile_type = /obj/projectile/bullet/c27_54cesarzowa/rubber

/obj/projectile/bullet/c27_54cesarzowa/rubber
	name = ".27-54 Cesarzowa rubber bullet"
	stamina = 30
	damage = 6
	weak_against_armour = TRUE
	wound_bonus = -30
	bare_wound_bonus = -10

/obj/item/ammo_box/c27_54cesarzowa/rubber
	name = "ammo box (.27-54 Cesarzowa rubber)"
	desc = "A box of .27-54 Cesarzowa rubber pistol rounds, holds eighteen cartridges."

	icon_state = "27-54cesarzowa_box_rubber"

	ammo_type = /obj/item/ammo_casing/c27_54cesarzowa/rubber

// Casing and projectile for the plasma thrower

/obj/item/ammo_casing/energy/laser/plasma_glob
	projectile_type = /obj/projectile/beam/laser/plasma_glob
	fire_sound = 'monkestation/code/modules/blueshift/sounds/incinerate.ogg'

/obj/item/ammo_casing/energy/laser/plasma_glob/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/caseless)

/obj/projectile/beam/laser/plasma_glob
	name = "plasma globule"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "plasma_glob"
	damage = 10
	speed = 1.5
	bare_wound_bonus = 55 // Lasers have a wound bonus of 40, this is a bit higher
	wound_bonus = -50 // However we do not very much against armor
	pass_flags = PASSTABLE | PASSGRILLE // His ass does NOT pass through glass!
	weak_against_armour = TRUE

// Various ammo boxes for .310

/obj/item/ammo_box/c310_cargo_box
	name = "ammo box (.310 Strilka lethal)"
	desc = "A box of .310 Strilka lethal rifle rounds, holds ten cartridges."

	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "310_box"

	multiple_sprites = AMMO_BOX_FULL_EMPTY

	w_class = WEIGHT_CLASS_NORMAL

	caliber = CALIBER_STRILKA310
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 10

// Rubber

/obj/item/ammo_box/c310_cargo_box/rubber
	name = "ammo box (.310 Strilka rubber)"
	desc = "A box of .310 Strilka rubber rifle rounds, holds ten cartridges."

	icon_state = "310_box_rubber"

	ammo_type = /obj/item/ammo_casing/strilka310/rubber

// AP

/obj/item/ammo_box/c310_cargo_box/piercing
	name = "ammo box (.310 Strilka piercing)"
	desc = "A box of .310 Strilka piercing rifle rounds, holds ten cartridges."

	icon_state = "310_box_ap"

	ammo_type = /obj/item/ammo_casing/strilka310/ap

// AMR bullet

/obj/item/ammo_casing/p60strela
	name = ".60 Strela caseless cartridge"
	desc = "A massive block of plasma-purple propellant with an equally massive round sticking out the top of it. \
		While good at killing a man, you'll find most effective use out of destroying things with it."
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/szot_dynamica/ammo.dmi'
	icon_state = "amr_bullet"
	caliber = CALIBER_60STRELA
	projectile_type = /obj/projectile/bullet/p60strela

/obj/item/ammo_casing/p60strela/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless)

/obj/projectile/bullet/p60strela // The funny thing is, these are wild but you only get three of them a magazine
	name =".60 Strela bullet"
	icon_state = "gaussphase"
	speed = 0.4
	damage = 50
	armour_penetration = 50
	wound_bonus = 20
	bare_wound_bonus = 30
	demolition_mod = 1.8
	/// How much damage we add to things that are weak to this bullet
	var/anti_materiel_damage_addition = 30

/obj/projectile/bullet/p60strela/Initialize(mapload)
	. = ..()
	// We do 80 total damage to anything robotic, namely borgs, and robotic simplemobs
	AddElement(/datum/element/bane, target_type = /mob/living, mob_biotypes = MOB_ROBOTIC, damage_multiplier = 0, added_damage = anti_materiel_damage_addition)

/obj/item/ammo_box/magazine/m10mm/rifle
	name = "rifle magazine (10mm)"
	desc = "A well-worn magazine fitted for the surplus rifle."
	icon_state = "75-full"
	base_icon_state = "75"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 10

/obj/item/ammo_box/magazine/m10mm/rifle/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[LAZYLEN(stored_ammo) ? "full" : "empty"]"

/obj/item/ammo_box/magazine/m223
	name = "toploader magazine (.223)"
	icon_state = ".223"
	ammo_type = /obj/item/ammo_casing/a223
	caliber = CALIBER_A223
	max_ammo = 30
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/m223/phasic
	name = "toploader magazine (.223 Phasic)"
	ammo_type = /obj/item/ammo_casing/a223/phasic

/obj/item/ammo_box/a40mm/rubber
	name = "ammo box (40mm rubber slug)"
	ammo_type = /obj/item/ammo_casing/a40mm/rubber

/obj/item/ammo_box/rocket
	name = "rocket bouquet (84mm HE)"
	icon_state = "rocketbundle"
	ammo_type = /obj/item/ammo_casing/rocket
	max_ammo = 3
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/rocket/can_load(mob/user)
	return FALSE

/obj/item/ammo_box/strilka310
	name = "stripper clip (.310 Strilka)"
	desc = "A stripper clip."
	icon_state = "310_strip"
	ammo_type = /obj/item/ammo_casing/strilka310
	max_ammo = 5
	caliber = CALIBER_STRILKA310
	multiple_sprites = AMMO_BOX_PER_BULLET

/obj/item/ammo_box/strilka310/surplus
	name = "stripper clip (.310 Surplus)"
	ammo_type = /obj/item/ammo_casing/strilka310/surplus

/obj/item/ammo_box/n762
	name = "ammo box (7.62x38mmR)"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/n762
	max_ammo = 14

/obj/item/ammo_box
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_box/magazine
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/strilka310
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/a357
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/c38
	w_class = WEIGHT_CLASS_SMALL

/obj/item/ammo_box/c9mm/ap
	name = "ammo box (9mm AP)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/c9mm/hp
	name = "ammo box (9mm HP)"
	ammo_type = /obj/item/ammo_casing/c9mm/hp

/obj/item/ammo_box/c9mm/fire
	name = "ammo box (9mm incendiary)"
	ammo_type = /obj/item/ammo_casing/c9mm/fire

/obj/item/ammo_box/c10mm/ap
	name = "ammo box (10mm AP)"
	ammo_type = /obj/item/ammo_casing/c10mm/ap
	max_ammo = 20

/obj/item/ammo_box/c10mm/hp
	name = "ammo box (10mm HP)"
	ammo_type = /obj/item/ammo_casing/c10mm/hp
	max_ammo = 20

/obj/item/ammo_box/c10mm/fire
	name = "ammo box (10mm incendiary)"
	ammo_type = /obj/item/ammo_casing/c10mm/fire
	max_ammo = 20

/obj/item/ammo_box/c46x30mm
	name = "ammo box (4.6x30mm)"
	icon = 'monkestation/code/modules/blueshift/icons/ammo.dmi'
	icon_state = "ammo_46"
	ammo_type = /obj/item/ammo_casing/c46x30mm
	max_ammo = 20

/obj/item/ammo_box/c46x30mm/ap
	name = "ammo box (4.6x30mm AP)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/ap

/obj/item/ammo_box/c46x30mm/rubber
	name = "ammo box (4.6x30mm rubber)"
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber

/obj/item/ammo_box/advanced/s12gauge
	name = "Slug ammo box"
	desc = "A box of 15 slug shells. Large, singular shots that pack a punch."
	icon = 'monkestation/code/modules/blueshift/icons/shotbox.dmi'
	icon_state = "slug"
	ammo_type = /obj/item/ammo_casing/shotgun
	max_ammo = 15
	multitype = FALSE // if you enable this and set the box's caliber var to CALIBER_SHOTGUN (at time of writing, "shotgun"), then you can have the fabled any-ammo shellbox

/obj/item/ammo_box/advanced/s12gauge/buckshot
	name = "Buckshot ammo box"
	desc = "A box of 15 buckshot shells. These have a modest spread of weaker projectiles."
	icon_state = "buckshot"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/rubber
	name = "Rubbershot ammo box"
	desc = "A box of 15 rubbershot shells. These have a modest spread of weaker, less-lethal projectiles."
	icon_state = "rubber"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/bean
	name = "Beanbag Slug ammo box"
	desc = "A box of 15 beanbag slug shells. These are large, singular beanbags that pack a less-lethal punch."
	icon_state = "bean"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/magnum
	name = "Magnum blockshot ammo box"
	desc = "A box of 15 magnum blockshot shells. The size of the pellet is larger in diameter than the typical shot, but there are less of them inside each shell."
	icon_state = "magnum"
	ammo_type = /obj/item/ammo_casing/shotgun/magnum
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/express
	name = "Express pelletshot ammo box"
	desc = "A box of 15 express pelletshot shells. The size of the pellet is smaller in diameter than the typical shot, but there are more of them inside each shell."
	icon_state = "express"
	ammo_type = /obj/item/ammo_casing/shotgun/express
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/hunter
	name = "Hunter slug ammo box"
	desc = "A box of 15 hunter slug shells. These shotgun slugs excel at damaging the local fauna."
	icon_state = "hunter"
	ammo_type = /obj/item/ammo_casing/shotgun/hunter
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/flechette
	name = "Flechette ammo box"
	desc = "A box of 15 flechette shells. Each shell contains a small group of tumbling blades that excel at causing terrible wounds."
	icon_state = "flechette"
	ammo_type = /obj/item/ammo_casing/shotgun/flechette
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/beehive
	name = "Hornet's nest ammo box"
	desc = "A box of 15 hornet's nest shells. These are less-lethal shells that will bounce off walls and direct themselves toward nearby targets."
	icon_state = "beehive"
	ammo_type = /obj/item/ammo_casing/shotgun/beehive
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/antitide
	name = "Stardust ammo box"
	desc = "A box of 15 express pelletshot shells. These are less-lethal and will embed in targets, causing pain on movement."
	icon_state = "antitide"
	ammo_type = /obj/item/ammo_casing/shotgun/antitide
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/incendiary
	name = "Incendiary Slug ammo box"
	desc = "A box of 15 incendiary slug shells. These will ignite targets and leave a trail of fire behind them."
	icon_state = "incendiary"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary
	max_ammo = 15

/obj/item/ammo_box/advanced/s12gauge/honkshot
	name = "Confetti Honkshot ammo box"
	desc = "A box of 35 shotgun shells."
	icon_state = "honk"
	ammo_type = /obj/item/ammo_casing/shotgun/honkshot
	max_ammo = 35

#define AMMO_MATS_SHOTGUN list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 4) // not quite as thick as a half-sheet

#define AMMO_MATS_SHOTGUN_FLECH list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/glass = SMALL_MATERIAL_AMOUNT * 2)

#define AMMO_MATS_SHOTGUN_HIVE list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 1,\
									/datum/material/silver = SMALL_MATERIAL_AMOUNT * 1)

#define AMMO_MATS_SHOTGUN_TIDE list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 1,\
									/datum/material/gold = SMALL_MATERIAL_AMOUNT * 1)

#define AMMO_MATS_SHOTGUN_PLASMA list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2,\
									/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 2)

/obj/item/ammo_casing/shotgun
	icon = 'monkestation/code/modules/blueshift/icons/shotshells.dmi'
	desc = "A 12 gauge iron slug."
	custom_materials = AMMO_MATS_SHOTGUN

// THE BELOW TWO SLUGS ARE NOTED AS ADMINONLY AND HAVE ***EIGHTY*** WOUND BONUS. NOT BARE WOUND BONUS. FLAT WOUND BONUS.
/obj/item/ammo_casing/shotgun/executioner
	name = "expanding shotgun slug"
	desc = "A 12 gauge fragmenting slug purpose-built to annihilate flesh on impact."
	can_be_printed = FALSE // noted as adminonly in code/modules/projectiles/projectile/bullets/shotgun.dm.

/obj/item/ammo_casing/shotgun/pulverizer
	name = "pulverizer shotgun slug"
	desc = "A 12 gauge uranium slug purpose-built to break bones on impact."
	can_be_printed = FALSE // noted as adminonly in code/modules/projectiles/projectile/bullets/shotgun.dm

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "A 12 gauge magnesium slug meant for \"setting shit on fire and looking cool while you do it\".\
	<br><br>\
	<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	advanced_print_req = TRUE
	custom_materials = AMMO_MATS_SHOTGUN_PLASMA

/obj/item/ammo_casing/shotgun/techshell
	can_be_printed = FALSE // techshell... casing! so not really usable on its own but if you're gonna make these go raid a seclathe.

/obj/item/ammo_casing/shotgun/improvised
	can_be_printed = FALSE // this is literally made out of scrap why would you use this if you have a perfectly good ammolathe

/obj/item/ammo_casing/shotgun/dart/bioterror
	can_be_printed = FALSE // PRELOADED WITH TERROR CHEMS MAYBE LET'S NOT

/obj/item/ammo_casing/shotgun/dragonsbreath
	can_be_printed = FALSE // techshell. assumed intended balance being a pain to assemble

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A 12 gauge silver slug with electrical microcomponents meant to incapacitate targets."
	can_be_printed = FALSE // comment out if you want rocket tag shotgun ammo being printable

/obj/item/ammo_casing/shotgun/meteorslug
	name = "meteor slug"
	desc = "A 12 gauge shell rigged with CMC technology which launches a heap of matter with great force when fired.\
	<br><br>\
	<i>METEOR: Fires a meteor-like projectile that knocks back movable objects like people and airlocks.</i>"
	can_be_printed = FALSE // techshell. assumed intended balance being a pain to assemble

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A 12 gauge shell containing high explosives designed for defeating some barriers and light vehicles, disrupting IEDs, or intercepting assistants.\
	<br><br>\
	<i>HIGH EXPLOSIVE: Explodes on impact.</i>"
	can_be_printed = FALSE // techshell. assumed intended balance being a pain to assemble

/obj/item/ammo_casing/shotgun/pulseslug
	can_be_printed = FALSE // techshell. assumed intended balance being a pain to assemble

/obj/item/ammo_casing/shotgun/laserslug
	can_be_printed = FALSE // techshell. assumed intended balance being a pain to assemble

/obj/item/ammo_casing/shotgun/ion
	can_be_printed = FALSE // techshell. assumed intended balance being a pain to assemble

/obj/item/ammo_casing/shotgun/incapacitate
	name = "hornet's nest shell"
	desc = "A 12 gauge shell filled with some kind of material that excels at incapacitating targets. Contains a lot of pellets, \
	sacrificing individual pellet strength for sheer stopping power in what's best described as \"spitting distance\".\
	<br><br>\
	<i>HORNET'S NEST: Fire an overwhelming amount of projectiles in a single shot.</i>"
	can_be_printed = FALSE

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot
	pellets = 8 // 8 * 6 for 48 damage if every pellet hits, we want to keep lethal shells ~50 damage
	variance = 25

/obj/projectile/bullet/pellet/shotgun_buckshot
	name = "buckshot pellet"
	damage = 6

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "rshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6 // 6 * 10 for 60 stamina damage, + some small amount of brute, we want to keep less lethal shells ~60
	variance = 20
	harmful = FALSE

/obj/projectile/bullet/pellet/shotgun_rubbershot
	stamina = 10

/obj/item/ammo_casing/shotgun/magnum
	name = "magnum blockshot shell"
	desc = "A 12 gauge shell that fires fewer, larger pellets than buckshot. A favorite of SolFed anti-piracy enforcers, \
		especially against the likes of vox."
	icon_state = "magshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/magnum
	pellets = 4 // Half as many pellets for twice the damage each pellet, same overall damage as buckshot
	variance = 20
	advanced_print_req = TRUE

/obj/projectile/bullet/pellet/shotgun_buckshot/magnum
	name = "magnum blockshot pellet"
	damage = 12
	wound_bonus = 10

/obj/projectile/bullet/pellet/shotgun_buckshot/magnum/Initialize(mapload)
	. = ..()
	transform = transform.Scale(1.25, 1.25)

/obj/item/ammo_casing/shotgun/express
	name = "express pelletshot shell"
	desc = "A 12 gauge shell that fires more and smaller projectiles than buckshot. Considered taboo to speak about \
		openly near teshari, for reasons you would be personally blessed to not know at least some of."
	icon_state = "expshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/express
	pellets = 12 // 1.3x The pellets for 0.6x the damage, same overall damage as buckshot
	variance = 30 // Slightly wider spread than buckshot

/obj/projectile/bullet/pellet/shotgun_buckshot/express
	name = "express buckshot pellet"
	damage = 4
	wound_bonus = 0

/obj/projectile/bullet/pellet/shotgun_buckshot/express/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.75, 0.75)

/obj/item/ammo_casing/shotgun/flechette
	name = "flechette shell"
	desc = "A 12 gauge flechette shell that specializes in ripping unarmored targets apart."
	icon_state = "fshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/flechette
	pellets = 8 //8 x 6 = 48 Damage Potential
	variance = 25
	custom_materials = AMMO_MATS_SHOTGUN_FLECH
	advanced_print_req = TRUE

/obj/projectile/bullet/pellet/shotgun_buckshot/flechette
	name = "flechette"
	icon = 'monkestation/code/modules/blueshift/icons/projectiles.dmi'
	icon_state = "flechette"
	damage = 6
	wound_bonus = 10
	bare_wound_bonus = 20
	sharpness = SHARP_EDGED //Did you knew flechettes fly sideways into people

/obj/projectile/bullet/pellet/shotgun_buckshot/flechette/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/item/ammo_casing/shotgun/beehive
	name = "hornet shell"
	desc = "A less-lethal 12 gauge shell that fires four pellets capable of bouncing off nearly any surface \
		and re-aiming themselves toward the nearest target. They will, however, go for <b>any target</b> nearby."
	icon_state = "cnrshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/beehive
	pellets = 4
	variance = 15
	fire_sound = 'sound/weapons/taser.ogg'
	harmful = FALSE
	custom_materials = AMMO_MATS_SHOTGUN_HIVE
	advanced_print_req = TRUE

/obj/projectile/bullet/pellet/shotgun_buckshot/beehive
	name = "hornet flechette"
	icon = 'monkestation/code/modules/blueshift/icons/projectiles.dmi'
	icon_state = "hornet"
	damage = 4
	stamina = 15
	wound_bonus = -5
	bare_wound_bonus = 5
	wound_falloff_tile = 0
	sharpness = NONE
	ricochets_max = 5
	ricochet_chance = 200
	ricochet_auto_aim_angle = 60
	ricochet_auto_aim_range = 8
	ricochet_decay_damage = 1
	ricochet_decay_chance = 1
	ricochet_incidence_leeway = 0 //nanomachines son

/obj/item/ammo_casing/shotgun/antitide
	name = "stardust shell"
	desc = "A highly experimental shell filled with nanite electrodes that will embed themselves in soft targets. The electrodes are charged from kinetic movement which means moving targets will get punished more."
	icon_state = "lasershell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/antitide
	pellets = 8 // 8 * 7 for 56 stamina damage, plus whatever the embedded shells do
	variance = 30
	harmful = FALSE
	fire_sound = 'sound/weapons/taser.ogg'
	custom_materials = AMMO_MATS_SHOTGUN_TIDE
	advanced_print_req = TRUE

/obj/projectile/bullet/pellet/shotgun_buckshot/antitide
	name = "electrode"
	icon = 'monkestation/code/modules/blueshift/icons/projectiles.dmi'
	icon_state = "stardust"
	damage = 2
	stamina = 16
	wound_bonus = 0
	bare_wound_bonus = 0
	stutter = 3 SECONDS
	jitter = 5 SECONDS
	eyeblur = 1 SECONDS
	sharpness = NONE
	range = 8
	embedding = list(embed_chance=70, pain_chance=25, fall_chance=15, jostle_chance=80, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.9, pain_mult=2, rip_time=10)

/obj/projectile/bullet/pellet/shotgun_buckshot/antitide/on_range()
	do_sparks(1, TRUE, src)
	..()

/obj/item/ammo_casing/shotgun/hunter
	name = "hunter slug shell"
	desc = "A 12 gauge slug shell that fires specially designed slugs that deal extra damage to the local planetary fauna"
	icon_state = "huntershell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/hunter

/obj/projectile/bullet/shotgun_slug/hunter
	name = "12g hunter slug"
	damage = 20
	range = 12
	/// How much the damage is multiplied by when we hit a mob with the correct biotype
	var/biotype_damage_multiplier = 5
	/// What biotype we look for
	var/biotype_we_look_for = MOB_BEAST

/obj/projectile/bullet/shotgun_slug/hunter/on_hit(atom/target, blocked, pierce_hit)
	if(ismineralturf(target))
		var/turf/closed/mineral/mineral_turf = target
		mineral_turf.gets_drilled(firer, FALSE)
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE
		return ..()
	if(!isliving(target) || (damage > initial(damage)))
		return ..()
	var/mob/living/target_mob = target
	if(target_mob.mob_biotypes & biotype_we_look_for || istype(target_mob, /mob/living/simple_animal/hostile/megafauna))
		damage *= biotype_damage_multiplier
	return ..()

/obj/projectile/bullet/shotgun_slug/hunter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bane, mob_biotypes = MOB_BEAST, damage_multiplier = 5)

/obj/projectile/bullet/pellet/shotgun_improvised
	weak_against_armour = TRUE // We will not have Improvised are Better 2.0

/obj/item/ammo_casing/shotgun/honkshot
	name = "confetti shell"
	desc = "A 12 gauge buckshot shell thats been filled to the brim with confetti, yippie!"
	icon_state = "honkshell"
	projectile_type = /obj/projectile/bullet/honkshot
	pellets = 12
	variance = 35
	fire_sound = 'sound/items/bikehorn.ogg'
	harmful = FALSE

/obj/projectile/bullet/honkshot
	name = "confetti"
	damage = 0
	sharpness = NONE
	shrapnel_type = NONE
	impact_effect_type = null
	ricochet_chance = 0
	jitter = 1 SECONDS
	eyeblur = 1 SECONDS
	hitsound = SFX_CLOWN_STEP
	range = 4
	icon_state = "guardian"

/obj/projectile/bullet/honkshot/Initialize(mapload)
	. = ..()
	SpinAnimation()
	range = rand(1, 4)
	color = pick(
		COLOR_PRIDE_RED,
		COLOR_PRIDE_ORANGE,
		COLOR_PRIDE_YELLOW,
		COLOR_PRIDE_GREEN,
		COLOR_PRIDE_BLUE,
		COLOR_PRIDE_PURPLE,
	)

// This proc addition will spawn a decal on each tile the projectile travels over
/obj/projectile/bullet/honkshot/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	new /obj/effect/decal/cleanable/confetti(get_turf(old_loc))
	return ..()

// This proc addition will make living humanoids do a flip animation when hit by the projectile
/obj/projectile/bullet/honkshot/on_hit(atom/target, blocked, pierce_hit)
	if(!isliving(target))
		return ..()
	target.SpinAnimation(7,1)
	return ..()

// This proc addition adds a spark effect when the projectile expires/hits
/obj/projectile/bullet/honkshot/on_range()
	do_sparks(1, TRUE, src)
	return ..()


/obj/item/ammo_box/magazine/c980_grenade/thunderdome_fire
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor

/obj/item/ammo_box/magazine/c980_grenade/thunderdome_shrapnel
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel

/obj/item/ammo_box/magazine/c980_grenade/thunderdome_smoke
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/magazine/c980_grenade/thunderdome_gas
	ammo_type = /obj/item/ammo_casing/c980grenade/riot

/obj/item/ammo_box/magazine/c980_grenade/drum
	name = "\improper Kiboko grenade drum"
	desc = "A drum for .980 grenades, holds six shells."

	icon_state = "granata_drum"

	w_class = WEIGHT_CLASS_NORMAL

	max_ammo = 6

/obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_fire
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_shrapnel
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_smoke
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/magazine/c980_grenade/drum/thunderdome_gas
	ammo_type = /obj/item/ammo_casing/c980grenade/riot
