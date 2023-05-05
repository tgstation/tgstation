/obj/structure/locker/secure
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor_type = /datum/armor/secure_locker
	secure = TRUE
	damage_deflection = 20

/datum/armor/secure_locker
	melee = 30
	bullet = 50
	laser = 50
	energy = 100
	fire = 80
	acid = 80

/obj/structure/locker/secure/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_GREY_TIDE, PROC_REF(grey_tide))

/obj/structure/locker/secure/proc/grey_tide(datum/source, list/grey_tide_areas)
	SIGNAL_HANDLER

	if(!is_station_level(z))
		return

	for(var/area_type in grey_tide_areas)
		if(!istype(get_area(src), area_type))
			continue
		locked = FALSE
		update_appearance(UPDATE_ICON)
