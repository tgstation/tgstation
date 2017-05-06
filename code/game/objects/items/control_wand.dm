#define WAND_OPEN "Open Door"
#define WAND_BOLT "Toggle Bolts"
#define WAND_EMERGENCY "Toggle Emergency Access"

/obj/item/weapon/door_remote
	icon_state = "gangtool-white"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = WEIGHT_CLASS_TINY
	var/mode = WAND_OPEN
	var/region_access = 1 //See access.dm
	var/obj/item/weapon/card/id/ID

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
	to_chat(user, "Now in mode: [mode].")

/obj/item/weapon/door_remote/afterattack(obj/machinery/door/airlock/D, mob/user)
	if(!istype(D))
		return
	if(!(D.hasPower()))
		to_chat(user, "<span class='danger'>[D] has no power!</span>")
		return
	if(!D.requiresID())
		to_chat(user, "<span class='danger'>[D]'s ID scan is disabled!</span>")
		return
	if(D.check_access(ID) && D.canAIControl(user))
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
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")

/obj/item/weapon/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = 0

/obj/item/weapon/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = 7

/obj/item/weapon/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = 5

/obj/item/weapon/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = 4

/obj/item/weapon/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = 2

/obj/item/weapon/door_remote/quartermaster
	name = "supply door remote"
	icon_state = "gangtool-green"
	region_access = 6

/obj/item/weapon/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = 3

/obj/item/weapon/door_remote/civillian
	name = "civillian door remote"
	icon_state = "gangtool-white"
	region_access = 1

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY