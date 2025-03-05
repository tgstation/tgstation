#define GRENADE_SMOKE_RANGE 0.75
#define GRENADE_ECM_RANGE 1.5

// .980 grenades
// Grenades that can be given a range to detonate at by their firing gun

/obj/item/ammo_casing/c980grenade
	name = ".980 Tydhouer HEDP"
	desc = "A large grenade shell that will detonate at a range \
		given to it by the gun that fires it. HEDP explodes."
	icon = 'modular_doppler/cool_implants/icons/casings.dmi'
	icon_state = "tyd_hedp"
	caliber = CALIBER_980TYDHOUER
	projectile_type = /obj/projectile/bullet/c980grenade

/obj/item/ammo_casing/c980grenade/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	var/obj/item/gun/ballistic/shotgun/shell_launcher/firing_launcher = fired_from
	if(istype(firing_launcher))
		loaded_projectile.range = firing_launcher.target_range
	else
		loaded_projectile.range = 7
	. = ..()

/obj/projectile/bullet/c980grenade
	name = ".980 grenade"
	icon = 'modular_doppler/cool_implants/icons/projectiles.dmi'
	icon_state = "bigshot"
	damage = 20
	stamina = 30
	range = 14
	speed = 0.75
	sharpness = NONE

/obj/projectile/bullet/c980grenade/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	if(!pierce_hit)
		fuse_activation(target)
	return BULLET_ACT_HIT

/obj/projectile/bullet/c980grenade/on_range()
	fuse_activation(get_turf(src))
	return ..()

/// Generic proc that is called when the projectile should 'detonate', being either on impact or when the range runs out
/obj/projectile/bullet/c980grenade/proc/fuse_activation(atom/target)
	playsound(src, 'modular_doppler/cool_implants/sound/kiboko/grenade_burst.ogg', 50, TRUE, 5)
	explosion(target, heavy_impact_range = 1, light_impact_range = 3, flash_range = 2, adminlog = FALSE, explosion_cause = src)

// .980 APHE

/obj/item/ammo_casing/c980grenade/aphe
	name = ".980 Tydhouer APHE"
	desc = "A large grenade shell that will detonate at a range \
		given to it by the gun that fires it. APHE pierces one target before exploding."
	icon_state = "tyd_aphe"
	projectile_type = /obj/projectile/bullet/c980grenade/aphe

/obj/projectile/bullet/c980grenade/aphe
	damage = 30
	stamina = 30
	sharpness = SHARP_POINTY
	projectile_piercing = PASSMOB|PASSGRILLE|PASSCLOSEDTURF|PASSMACHINE|PASSSTRUCTURE|PASSDOORS|PASSFLAPS|PASSVEHICLE|PASSWINDOW

/obj/projectile/bullet/c980grenade/aphe/fuse_activation(atom/target)
	playsound(src, 'modular_doppler/cool_implants/sound/kiboko/grenade_burst.ogg', 50, TRUE, 5)
	explosion(target, light_impact_range = 2, flash_range = 2, adminlog = FALSE, explosion_cause = src)

/obj/projectile/bullet/c980grenade/aphe/on_hit(atom/target, blocked = FALSE, pierce_hit)
	if(pierces > 1)
		projectile_piercing = NONE
	return ..()

// .980 Thermobaric

/obj/item/ammo_casing/c980grenade/thermobaric
	name = ".980 Tydhouer Thermobaric"
	desc = "A large grenade shell that will detonate at a range \
		given to it by the gun that fires it. Thermobaric grenades make a heavier, but smaller explosion."
	icon_state = "tyd_thermobaric"
	projectile_type = /obj/projectile/bullet/c980grenade/thermobaric

/obj/projectile/bullet/c980grenade/thermobaric

/obj/projectile/bullet/c980grenade/thermobaric/fuse_activation(atom/target)
	playsound(src, 'modular_doppler/cool_implants/sound/kiboko/grenade_burst.ogg', 50, TRUE, 5)
	explosion(target, heavy_impact_range = 1, flame_range = 1, flash_range = 2, adminlog = FALSE, explosion_cause = src)

// .980 Flechette

/obj/item/ammo_casing/c980grenade/flechette
	name = ".980 Tydhouer Flechette"
	desc = "A large grenade shell that is filled with needle-like \
		flechettes. Typically, quite a bad day to be on the other side of this."
	icon_state = "tyd_flech"
	pellets = 10
	variance = 40
	projectile_type = /obj/projectile/bullet/tydhouer_flechette

/obj/projectile/bullet/tydhouer_flechette
	name = "flechette"
	icon = 'modular_doppler/cool_implants/icons/projectiles.dmi'
	icon_state = "shortbullet"
	damage = 5
	armour_penetration = 10
	damage_falloff_tile = -0.25
	range = 20

// .980 Flechette

/obj/item/ammo_casing/c980grenade/sabot
	name = ".980 Tydhouer Sabot"
	desc = "A large shell that has a single, pointed projectile within. \
		Highly effective at going through not just people, but everything."
	icon_state = "tyd_sabot"
	projectile_type = /obj/projectile/bullet/tydhouer_sabot

/obj/projectile/bullet/tydhouer_sabot
	name = ".980 sabot"
	icon = 'modular_doppler/cool_implants/icons/projectiles.dmi'
	damage = 20
	armour_penetration = 40
	damage_falloff_tile = -2
	range = 25
	max_pierces = 2
	projectile_piercing = PASSMOB|PASSGRILLE|PASSCLOSEDTURF|PASSMACHINE|PASSSTRUCTURE|PASSDOORS|PASSFLAPS|PASSVEHICLE|PASSWINDOW

// .980 smoke grenade

/obj/item/ammo_casing/c980grenade/smoke
	name = ".980 Tydhouer smoke grenade"
	desc = "A large grenade shell that will detonate at a range \
		given to it by the gun that fires it. Bursts into a laser-weakening smoke cloud."
	icon_state = "tyd_smoke"
	projectile_type = /obj/projectile/bullet/c980grenade/smoke

/obj/projectile/bullet/c980grenade/smoke

/obj/projectile/bullet/c980grenade/smoke/fuse_activation(atom/target)
	playsound(src, 'modular_doppler/cool_implants/sound/kiboko/grenade_burst.ogg', 50, TRUE, 5)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/bad/smoke = new
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()

// .980 ECM grenade

/obj/item/ammo_casing/c980grenade/ecm
	name = ".980 Tydhouer ECM chaff grenade"
	desc = "A large grenade shell that will detonate at a range \
		given to it by the gun that fires it. Bursts into a cloud of ECM chaff, distrupts some electronics."
	icon_state = "tyd_ecm"
	projectile_type = /obj/projectile/bullet/c980grenade/ecm

/obj/projectile/bullet/c980grenade/ecm

/obj/projectile/bullet/c980grenade/ecm/fuse_activation(atom/target)
	playsound(src, 'modular_doppler/cool_implants/sound/kiboko/grenade_burst.ogg', 50, TRUE, 5)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/ecm/smoke = new
	smoke.set_up(GRENADE_ECM_RANGE, holder = src, location = src)
	smoke.start()

/datum/effect_system/fluid_spread/smoke/ecm
	effect_type = /obj/effect/particle_effect/fluid/smoke/ecm

/obj/effect/particle_effect/fluid/smoke/ecm
	name = "ECM chaff"
	icon = 'modular_doppler/cool_implants/icons/projectiles.dmi'
	icon_state = "ecm_holder"
	opacity = FALSE
	lifetime = 20 SECONDS
	pixel_x = 0
	pixel_y = 0
	/// Holder for the chaff particles
	var/obj/effect/abstract/particle_holder/particle_effect

/obj/effect/particle_effect/fluid/smoke/ecm/Initialize(mapload)
	. = ..()
	particle_effect = new(src, /particles/ecm_chaff)

/obj/effect/particle_effect/fluid/smoke/ecm/smoke_mob(mob/living/carbon/smoker, seconds_per_tick)
	if(!istype(smoker))
		return FALSE
	if(lifetime < 1)
		return FALSE
	if(smoker.smoke_delay)
		return FALSE
	smoker.apply_status_effect(/datum/status_effect/ecm_jammed)
	smoker.smoke_delay = TRUE
	addtimer(VARSET_CALLBACK(smoker, smoke_delay, FALSE), 1 SECONDS)
	return TRUE

/particles/ecm_chaff
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list(
		"dot" = 1,
		"cross" = 1,
		"curl" = 1,
	)
	width = 32
	height = 32
	count = 7
	spawning = 5
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	color = "#ffffff"
	gravity = list(0, -0.25)
	position = generator(GEN_BOX, list(-32,-32,0), list(32,32,0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.9,0.9), list(1.1,1.1), NORMAL_RAND)
	spin = generator(GEN_NUM, list(-15,15), NORMAL_RAND)

// .980 shrapnel grenade

/obj/item/ammo_casing/c980grenade/shrapnel
	name = ".980 Tydhouer shrapnel grenade"
	desc = "A large grenade shell that will detonate at a range \
		given to it by the gun that fires it. Explodes into shrapnel on detonation."
	icon_state = "tyd_shrap"
	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel

/obj/projectile/bullet/c980grenade/shrapnel
	/// What type of grenade to we spawn and instantly explode
	var/grenade_to_spawn = /obj/item/grenade/c980payload

/obj/projectile/bullet/c980grenade/shrapnel/fuse_activation(atom/target)
	var/obj/item/grenade/shrapnel_maker = new grenade_to_spawn(get_turf(target))
	shrapnel_maker.detonate()
	playsound(src, 'modular_doppler/cool_implants/sound/kiboko/grenade_burst.ogg', 50, TRUE, -3)
	qdel(shrapnel_maker)

/obj/item/grenade/c980payload
	shrapnel_type = /obj/projectile/bullet/shrapnel/short_range
	shrapnel_radius = 3
	ex_dev = 0
	ex_heavy = 0
	ex_light = 0
	ex_flame = 0

/obj/projectile/bullet/shrapnel/short_range
	icon = 'modular_doppler/cool_implants/icons/projectiles.dmi'
	icon_state = "shortbullet"
	range = 2

// .980 phosphor grenade

/obj/item/ammo_casing/c980grenade/shrapnel/phosphor
	name = ".980 Tydhouer phosphor grenade"
	desc = "A large grenade shell that will detonate at a range \
		given to it by the gun that fires it. Explodes into smoke and flames on detonation."
	icon_state = "tyd_phosphor"
	projectile_type = /obj/projectile/bullet/c980grenade/shrapnel/phosphor

/obj/projectile/bullet/c980grenade/shrapnel/phosphor
	grenade_to_spawn = /obj/item/grenade/c980payload/phosphor

/obj/projectile/bullet/c980grenade/shrapnel/phosphor/fuse_activation(atom/target)
	. = ..()
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/fluid_spread/smoke/quick/smoke = new
	smoke.set_up(GRENADE_SMOKE_RANGE, holder = src, location = src)
	smoke.start()

/obj/item/grenade/c980payload/phosphor
	shrapnel_type = /obj/projectile/bullet/incendiary/fire/backblast/short_range

/obj/projectile/bullet/incendiary/fire/backblast/short_range
	range = 1

#undef GRENADE_SMOKE_RANGE
#undef GRENADE_ECM_RANGE
