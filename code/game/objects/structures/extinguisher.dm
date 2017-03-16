/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "extinguisher_closed"
	anchored = 1
	density = 0
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/weapon/extinguisher/stored_extinguisher
	var/opened = 0

/obj/structure/extinguisher_cabinet/Initialize()
	..()
	SetItemToReachConstructionState(EXTINGUISHER_CABINET_FULL, new /obj/item/weapon/extinguisher(src))

/obj/structure/extinguisher_cabinet/Construct(mob/user, ndir)
	..()
	pixel_x = (dir & 3)? 0 : (dir == 4 ? -27 : 27)
	pixel_y = (dir & 3)? (dir ==1 ? -30 : 30) : 0
	opened = 1

CONSTRUCTION_BLUEPRINT(/obj/structure/extinguisher_cabinet, TRUE, TRUE)
	. = newlist(
		/datum/construction_state/first{
			//required_type_to_construct = /obj/item/wallframe/extinguisher_cabinet
			required_amount_to_construct = 1
			always_drop_loot = 0
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/extinguisher
			required_amount_to_construct = 1
			stash_construction_item = 1
			required_type_to_deconstruct = /obj/item/weapon/wrench
			deconstruction_delay = 60
			construction_message = "place the extinguisher in"
			deconstruction_message = "unsecuring"
			deconstruction_sound = 'sound/items/Deconstruct.ogg'
			damage_reachable = 1
			always_drop_loot = 1
		},
		/datum/construction_state/last{
			deconstruction_message = "take the extinguisher from"
		}
	)
	
	//This is here to work around a byond bug
	//http://www.byond.com/forum/?post=2220240
	//When its fixed clean up this copypasta across the codebase OBJ_CONS_BAD_CONST

	var/datum/construction_state/first/X = .[1]
	X.required_type_to_construct = /obj/item/wallframe/extinguisher_cabinet

/obj/structure/extinguisher_cabinet/ConstructionChecks(state_started_id, constructing, obj/item, mob/user, skip)
	. = ..()
	if(!. || skip)
		return
	if(state_started_id == EXTINGUISHER_CABINET_FULL)
		if(iscyborg(user) || isalien(user))
			return FALSE
	else
		return !GetItemUsedToReachConstructionState(EXTINGUISHER_CABINET_FULL)

/obj/structure/extinguisher_cabinet/OnDeconstruction(state_id, mob/user, obj/item/created, forced)
	..()
	if(!opened)
		toggle_cabinet(user, TRUE)
	if(!state_id && forced)
		new /obj/item/stack/sheet/metal(loc, 2)

/obj/structure/extinguisher_cabinet/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/extinguisher_cabinet/AltClick(mob/living/user)
	if(user.incapacitated() || !istype(user))
		return
	toggle_cabinet(user)

/obj/structure/extinguisher_cabinet/proc/toggle_cabinet(mob/user, silent)
	if(broken)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is broken open.</span>")
		return

	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	var/I = GetItemUsedToReachConstructionState(EXTINGUISHER_CABINET_FULL)
	if(I)
		if(istype(I, /obj/item/weapon/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"

/obj/structure/extinguisher_cabinet/obj_break(damage_flag)
	if(!opened)
		toggle_cabinet(usr, TRUE)
	..()

/obj/item/wallframe/extinguisher_cabinet
	name = "extinguisher cabinet frame"
	desc = "Used for building wall-mounted extinguisher cabinets."
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "extinguisher_frame"
	result_path = /obj/structure/extinguisher_cabinet

CONSTRUCTION_BLUEPRINT(/obj/item/wallframe/extinguisher_cabinet, TRUE, TRUE)
	. = newlist(
		/datum/construction_state/first{
			//required_type_to_construct = /obj/item/stack/sheet/metal
			required_amount_to_construct = 2
		},
		/datum/construction_state/last{
			required_type_to_deconstruct = /obj/item/weapon/wrench
			deconstruction_message = "dismantle"
		}
	)
	
	//This is here to work around a byond bug
	//http://www.byond.com/forum/?post=2220240
	//When its fixed clean up this copypasta across the codebase OBJ_CONS_BAD_CONST

	var/datum/construction_state/first/X = .[1]
	X.required_type_to_construct = /obj/item/stack/sheet/metal