/obj/vehicle/sealed/mecha/combat
	force = 30
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	internal_damage_threshold = 50
	armor = list(MELEE = 30, BULLET = 30, LASER = 15, ENERGY = 20, BOMB = 20, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	mouse_pointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'
	destruction_sleep_duration = 40
	exit_delay = 40

/obj/vehicle/sealed/mecha/combat/restore_equipment()
	mouse_pointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'
	return ..()


/obj/vehicle/sealed/mecha/combat/proc/max_ammo() //Max the ammo stored for Nuke Ops mechs, or anyone else that calls this
	for(var/obj/item/I in equipment)
		if(istype(I, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/))
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun = I
			gun.projectiles_cache = gun.projectiles_cache_max
