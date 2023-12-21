#define RIGHTS_NONE "none"
//can be used to teleport to any other centcom_teleporter(admin teleporters can only be used by people with R_ADMIN)
/obj/structure/centcom_teleporter
	name = "centcom teleporter"
	desc = "Can teleport you to any other centcom teleporter you have access to."

	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE

	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	///static assoc list of lists of centcom teleporters, keyed to strings of what rights they require to use
	var/static/list/all_teleporters = list()
	///what rights do we need to be used
	var/needed_rights = RIGHTS_NONE

/obj/structure/centcom_teleporter/Initialize(mapload)
	. = ..()
	if(!all_teleporters["[needed_rights]"])
		all_teleporters["[needed_rights]"] = list(src)
	else
		all_teleporters["[needed_rights]"] += src

/obj/structure/centcom_teleporter/Destroy()
	all_teleporters["[needed_rights]"] -= src
	return ..()

/obj/structure/centcom_teleporter/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!user.client || (needed_rights != RIGHTS_NONE && !check_rights_for(user.client, needed_rights)))
		return

	var/list/choice_list = list()
	for(var/teleporter_list in all_teleporters)
		if((teleporter_list == RIGHTS_NONE) || check_rights_for(user.client, text2num(teleporter_list)))
			choice_list += all_teleporters[teleporter_list]

	var/obj/structure/centcom_teleporter/choice = tgui_input_list(user, "Where do you want to teleport to?", "Teleporter", choice_list)
	if(!istype(choice))
		return

	if((choice.needed_rights != RIGHTS_NONE) && !check_rights_for(user.client, choice.needed_rights))
		to_chat(user, span_warning("You dont have the admin rights to teleport here."))
		message_admins("[user][ADMIN_LOOKUPFLW(user)] is trying to use a centcom teleporter they dont have access to.") //these should not be visible to them so tell admins
		return

	do_teleport(user, get_turf(choice), no_effects = TRUE, forced = TRUE)

/obj/structure/centcom_teleporter/spawn_area
	name = "spawn area teleporter"

/obj/structure/centcom_teleporter/arena
	name = "arena teleporter"

/obj/structure/centcom_teleporter/cargo
	name = "centcom cargo teleporter"
	needed_rights = R_ADMIN

/obj/structure/centcom_teleporter/admin_offices
	name = "admin offices teleporter"
	needed_rights = R_ADMIN

#undef RIGHTS_NONE
