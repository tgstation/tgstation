/// The admin prison watcher datum this mob has been assigned
/mob/var/datum/admin_prison_watcher/admin_prison_holder

/// A datum dedicated to a mob to ensure they cannot perform any inputs until released from admin prison
/datum/admin_prison_watcher
	var/mob/parent
	var/turf/old_loc

/datum/admin_prison_watcher/New(mob/parent)
	if(!istype(parent))
		CRASH("Attempted to create [type] with a parent of [parent.type]")
	src.parent = parent

	parent.admin_prison_holder = src
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(on_mob_login))

/datum/admin_prison_watcher/Destroy()
	parent?.admin_prison_watcher = null
	if(parent && old_loc)
		message_admins("The [type] assigned to [parent.ckey] has been qdel'd. This was probably not intentional!")
		parent = null
		old_loc = null
	return ..()

/datum/admin_prison_watcher/proc/send_to_admin_prison()
	if(!parent)
		return

	old_loc = get_turf(parent)
	parent.forceMove(pick(GLOB.prisonwarp))
	parent.focus = src
	parent.block_inputs = TRUE
	to_chat(parent, span_adminnotice("You have been sent to Admin Prison!"), confidential=TRUE)
	log_admin("[key_name(usr)] has sent [key_name(parent)] to Admin Prison!")
	message_admins("[key_name_admin(usr)] has sent [key_name_admin(parent)] to Admin Prison!")

/datum/admin_prison_watcher/proc/release_from_admin_prison()
	if(!parent || !old_loc)
		return
	parent.block_inputs = FALSE
	parent.focus = parent
	parent.forceMove(old_loc)
	to_chat(parent, span_adminnotice("You have been released from Admin Prison!"), confidential=TRUE)
	log_admin("[key_name(usr)] has released [key_name(parent)] from Admin Prison!")
	message_admins("[key_name_admin(usr)] has released [key_name_admin(parent)] from Admin Prison!")
	parent = null
	old_loc = null
	qdel(src)

/datum/admin_prison_watcher/proc/on_mob_login()
	SIGNAL_HANDLER

	to_chat(parent, span_adminnotice("You are currently in prison. You may want to ask admins why."), confidential=TRUE)

/mob/forceMove(atom/destination)
	if(admin_input_block_enabled)
		return
	return ..()

/mob/abstract_move(atom/destination)
	if(admin_input_block_enabled)
		return
	return ..()
