// Freeze Mob/Mech Verb -- adminoverlay sprite ported from ss220-space/Paradise
// Initially ported to ss220-space/Paradise from NSS Pheonix (Unbound Travels)
// Allows admins to right click on any mob/vehicle and freeze them in place

GLOBAL_LIST_EMPTY(frozen_atom_list) // A list of admin-frozen atoms.
var/obj/effect/overlay/adminoverlay = new /obj/effect/overlay/adminoverlay ()

// Freeze mob
ADMIN_VERB_AND_CONTEXT_MENU(admin_freeze, R_ADMIN, "Freeze (Mob)", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/living/M in world)
	if(!istype(M))
		tgui_alert(user,"Freeze cannot be called on this object. Supported types: mob/living")
		return
	if(!(M in GLOB.frozen_atom_list))
		GLOB.frozen_atom_list += M
		M.SetStun(INFINITY, ignore_canstun = TRUE)
		M.SetSleeping(INFINITY)
		M.add_overlay(adminoverlay)
		//We try to ensure, that the mob won't take any damage and won't be moved
		user.cmd_admin_godmode(M)
		M.anchored = TRUE
		to_chat(M, "<b><font color= red>You have been frozen by an admin!</b></font>")
	else
		GLOB.frozen_atom_list -= M
		user.cmd_admin_godmode(M)
		M.SetStun(0, ignore_canstun = TRUE)
		M.SetSleeping(0)
		M.cut_overlay(adminoverlay)
		M.anchored = FALSE
		to_chat(M, "<b><font color= red>You have been unfrozen by an admin!</b></font>")
	log_admin("[key_name_admin(user)] toggled admin-freeze on [key_name_admin(M)].")
	message_admins("[key_name_admin(user)] toggled admin-freeze on [ADMIN_LOOKUPFLW(M)].")
	admin_ticket_log(M, "[key_name_admin(user)] toggled admin-freeze on [key_name_admin(M)].")
	BLACKBOX_LOG_ADMIN_VERB("Admin Freeze")

// freeze any obj/vehicle
ADMIN_VERB_AND_CONTEXT_MENU(admin_freeze_vehicle, R_ADMIN, "Freeze (Vehicle)", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, obj/vehicle/vehicle in world)
	if(!istype(vehicle))
		tgui_alert(user,"Freeze cannot be called on this object. Supported types: obj/vehicle")
		return
	var/obj/vehicle/target = vehicle
	// For some reason, spawned/constructed mechs have an empty list(), while the ones that were used have occupants set to null.
	if(target.return_occupants() == null || target.occupants.len == 0)
		tgui_alert(user,"There is nobody in the vehicle!")
		return
	// We also want to freeze the occupants of the obj/vehicle
	if(!(vehicle in GLOB.frozen_atom_list))
		GLOB.frozen_atom_list += target
		for(var/mob/living/occupant in target.return_occupants())
			GLOB.frozen_atom_list += occupant
			occupant.SetStun(INFINITY, ignore_canstun = TRUE)
			occupant.SetSleeping(INFINITY)
			user.cmd_admin_godmode(occupant)
			to_chat(occupant, "<b><font color= red>You have been frozen by an admin!</b></font>")
			log_admin("[key_name_admin(user)] toggled admin-freeze on [key_name_admin(occupant)] in [target].")
			message_admins("[key_name_admin(user)] toggled admin-freeze on [ADMIN_LOOKUPFLW(occupant)] in [target].")
			admin_ticket_log(occupant, "[key_name_admin(user)] toggled admin-freeze on [key_name_admin(occupant)] in [target].")
		target.add_overlay(adminoverlay)
		target.canmove = FALSE
		// obj/vehicle won't take any damage
		target.resistance_flags += INDESTRUCTIBLE
	else
		GLOB.frozen_atom_list -= target
		for(var/mob/living/occupant in target.return_occupants())
			GLOB.frozen_atom_list -= occupant
			user.cmd_admin_godmode(occupant)
			occupant.SetStun(0, ignore_canstun = TRUE)
			occupant.SetSleeping(0)
			to_chat(occupant, "<b><font color= red>You have been unfrozen by an admin!</b></font>")
			log_admin("[key_name_admin(user)] toggled admin-freeze on [key_name_admin(occupant)] in [target].")
			message_admins("[key_name_admin(user)] toggled admin-freeze on [ADMIN_LOOKUPFLW(occupant)] in [target].")
			admin_ticket_log(occupant, "[key_name_admin(user)] toggled admin-freeze on [key_name_admin(occupant)] in [target].")
		target.cut_overlay(adminoverlay)
		target.resistance_flags -= INDESTRUCTIBLE
		target.canmove = TRUE
	BLACKBOX_LOG_ADMIN_VERB("Admin Freeze Vehicle")
