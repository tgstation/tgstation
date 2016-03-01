#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"

/obj/item/weapon/door_remote
	icon_state = "gangtool-white"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = 1
	var/mode = WAND_OPEN
	var/region_access = 1 //See access.dm
	var/obj/item/weapon/card/id/ID
	var/wand_access = /datum/job/assistant //This is for access. See access.dm for which jobs give what access. Use "Captain" if you want the wand to work on all doors.

/obj/item/weapon/door_remote/New()
	..()
	ID = new /obj/item/weapon/card/id
	ID.access = get_region_accesses(region_access)

/obj/item/weapon/door_remote/attack_self(mob/user)
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	user << "Now in mode: [mode]."

/obj/item/weapon/door_remote/afterattack(obj/machinery/door/airlock/D, mob/user)
	if(!istype(D))
		return
	if(!(D.hasPower()))
		user << "[D] has no power!"
		return
	if(!D.requiresID())
		user << "[D]'s ID scan is disabled!"
		return
	if(D.check_access(src.ID))
		switch(mode)
			if(WAND_OPEN)
				if(D.density)
					D.open()
				else
					D.close()
			if(WAND_BOLT)
				if(D.locked)
					D.unbolt()
				else
					D.bolt()
			if(WAND_EMERGENCY)
				if(D.emergency)
					D.emergency = 0
				else
					D.emergency = 1
				D.update_icon()
	else
		user << "[src] does not have access to this door."

/obj/item/weapon/door_remote/captain
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	wand_access = /datum/job/captain
	region_access = 0

/obj/item/weapon/door_remote/chief_engineer
	name = "engineering door remote"
	wand_access = /datum/job/chief_engineer
	icon_state = "gangtool-orange"
	region_access = 5

/obj/item/weapon/door_remote/research_director
	name = "research door remote"
	wand_access = /datum/job/rd
	icon_state = "gangtool-purple"
	region_access = 4

/obj/item/weapon/door_remote/head_of_security
	name = "security door remote"
	wand_access = /datum/job/hos
	icon_state = "gangtool-red"
	region_access = 2

/obj/item/weapon/door_remote/quartermaster
	name = "supply door remote"
	wand_access = /datum/job/qm
	icon_state = "gangtool-green"
	region_access = 6

/obj/item/weapon/door_remote/chief_medical_officer
	name = "medical door remote"
	wand_access = /datum/job/cmo
	icon_state = "gangtool-blue"
	region_access = 3

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY