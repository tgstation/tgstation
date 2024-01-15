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

// .980 grenades
// Grenades that can be given a range to detonate at by their firing gun

/obj/item/ammo_casing/c980grenade
	name = ".980 Tydhouer practice grenade"
	desc = "A large grenade shell that will detonate at a range given to it by the gun that fires it. Practice shells disintegrate into harmless sparks."

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
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


/obj/projectile/bullet/c980grenade/on_hit(atom/target, blocked = FALSE)
	..()
	fuse_activation(target)
	return BULLET_ACT_HIT


/obj/projectile/bullet/c980grenade/on_range()
	fuse_activation(get_turf(src))
	return ..()


/// Generic proc that is called when the projectile should 'detonate', being either on impact or when the range runs out
/obj/projectile/bullet/c980grenade/proc/fuse_activation(atom/target)
	playsound(src, 'modular_skyrat/modules/modular_weapons/sounds/grenade_burst.ogg', 50, TRUE, -3)
	do_sparks(3, FALSE, src)


/obj/item/ammo_box/c980grenade
	name = "ammo box (.980 Tydhouer practice)"
	desc = "A box of four .980 Tydhouer practice grenades. Instructions on the box indicate these are dummy practice rounds that will disintegrate into sparks on detonation. Neat!"

	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/company_and_or_faction_based/carwo_defense_systems/ammo.dmi'
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
	playsound(src, 'modular_skyrat/modules/modular_weapons/sounds/grenade_burst.ogg', 50, TRUE, -3)
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

	playsound(src, 'modular_skyrat/modules/modular_weapons/sounds/grenade_burst.ogg', 50, TRUE, -3)


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
	playsound(src, 'modular_skyrat/modules/modular_weapons/sounds/grenade_burst.ogg', 50, TRUE, -3)
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
