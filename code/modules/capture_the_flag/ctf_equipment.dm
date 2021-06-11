/obj/item/gun/ballistic/automatic/pistol/deagle/ctf
	desc = "This looks like it could really hurt in melee."
	force = 75
	mag_type = /obj/item/ammo_box/magazine/m50/ctf

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/m50/ctf
	ammo_type = /obj/item/ammo_casing/a50/ctf

/obj/item/ammo_casing/a50/ctf
	projectile_type = /obj/projectile/bullet/ctf

/obj/projectile/bullet/ctf
	damage = 0

/obj/projectile/bullet/ctf/prehit_pierce(atom/target)
	if(is_ctf_target(target))
		damage = 60
		return PROJECTILE_PIERCE_NONE /// hey uhh don't hit anyone behind them
	. = ..()

/obj/item/gun/ballistic/automatic/laser/ctf
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf
	desc = "This looks like it could really hurt in melee."
	force = 50

/obj/item/gun/ballistic/automatic/laser/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/gun/ballistic/automatic/laser/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/recharge/ctf
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf

/obj/item/ammo_box/magazine/recharge/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/ammo_box/magazine/recharge/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_casing/caseless/laser/ctf
	projectile_type = /obj/projectile/beam/ctf

/obj/projectile/beam/ctf
	damage = 0
	icon_state = "omnilaser"

/obj/projectile/beam/ctf/prehit_pierce(atom/target)
	if(is_ctf_target(target))
		damage = 150
		return PROJECTILE_PIERCE_NONE /// hey uhhh don't hit anyone behind them
	. = ..()

/proc/is_ctf_target(atom/target)
	. = FALSE
	if(istype(target, /obj/structure/barricade/security/ctf))
		. = TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
			if(H in CTF.spawned_mobs)
				. = TRUE
				break

// RED TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/red
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/red

/obj/item/ammo_box/magazine/recharge/ctf/red
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/red

/obj/item/ammo_casing/caseless/laser/ctf/red
	projectile_type = /obj/projectile/beam/ctf/red

/obj/projectile/beam/ctf/red
	icon_state = "laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

// BLUE TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/blue
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/blue

/obj/item/ammo_box/magazine/recharge/ctf/blue
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/blue

/obj/item/ammo_casing/caseless/laser/ctf/blue
	projectile_type = /obj/projectile/beam/ctf/blue

/obj/projectile/beam/ctf/blue
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// GREEN TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/green
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/green

/obj/item/ammo_box/magazine/recharge/ctf/green
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/green

/obj/item/ammo_casing/caseless/laser/ctf/green
	projectile_type = /obj/projectile/beam/ctf/green

/obj/projectile/beam/ctf/green
	icon_state = "xray"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

// YELLOW TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/yellow
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/yellow

/obj/item/ammo_box/magazine/recharge/ctf/yellow
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/yellow

/obj/item/ammo_casing/caseless/laser/ctf/yellow
	projectile_type = /obj/projectile/beam/ctf/yellow

/obj/projectile/beam/ctf/yellow
	icon_state = "gaussstrong"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
