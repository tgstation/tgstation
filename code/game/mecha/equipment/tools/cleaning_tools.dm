
// Janitor sprayer, cleaner grenade launcher

/obj/item/mecha_parts/mecha_equipment/janitor

/obj/item/mecha_parts/mecha_equipment/janitor/can_attach(obj/mecha/working/cleaner/M)
	if(..() && istype(M))
		return 1

/obj/item/mecha_parts/mecha_equipment/janitor/sprayer
	name = "space cleaner sprayer"
	desc = "For janitor mechs. Sprays space cleaner in a 3 tile radius. Regenerates automatically."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "chemsprayer_janitor"
	equip_cooldown = 100
	energy_drain = 1000
	range = RANGED
	var/obj/item/reagent_containers/spray/chemsprayer/janitor/spray

/obj/item/mecha_parts/mecha_equipment/janitor/sprayer/Initialize()
	. = ..()
	spray = new /obj/item/reagent_containers/spray/chemsprayer/janitor(usr, 1000)

/obj/item/mecha_parts/mecha_equipment/janitor/sprayer/action(atom/target)
	if(spray)
		spray.spray(target, src)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/cleaner
	name = "\improper cleaner grenade launcher"
	desc = "For janitor mechs. Launches a cleaner grenade."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/grenade/chem_grenade/cleaner
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 1
	missile_speed = 1.5
	projectile_energy_cost = 800
	equip_cooldown = 100
	var/det_time = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/cleaner/can_attach(obj/mecha/working/cleaner/M)
	if(istype(M))
		return 1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/cleaner/proj_init(var/obj/item/grenade/chem_grenade/cleaner/grenade)
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(chassis.occupant)] fired a [src] in [ADMIN_VERBOSEJMP(T)]")
	log_game("[key_name(chassis.occupant)] fired a [src] in [AREACOORD(T)]")
	addtimer(CALLBACK(grenade, /obj/item/grenade/chem_grenade/cleaner.proc/prime), det_time)