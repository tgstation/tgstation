/obj/machinery/mod_installer
	name = "modular outerwear device installator"
	desc = "An ancient machine that mounts a MOD unit onto the occupant."
	icon = 'icons/obj/machines/mod_installer.dmi'
	icon_state = "mod_installer"
	base_icon_state = "mod_installer"
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	obj_flags = BLOCKS_CONSTRUCTION // Becomes undense when the door is open
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.5
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.3

	var/busy = FALSE
	var/busy_icon_state

	var/obj/item/mod/control/mod_unit = /obj/item/mod/control/pre_equipped/prototype

	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/mod_installer/Initialize(mapload)
	. = ..()
	occupant_typecache = typecacheof(/mob/living/carbon/human)
	if(ispath(mod_unit))
		mod_unit = new mod_unit()

/obj/machinery/mod_installer/Destroy()
	QDEL_NULL(mod_unit)
	return ..()

/obj/machinery/mod_installer/proc/set_busy(status, working_icon)
	busy = status
	busy_icon_state = working_icon
	update_appearance()

/obj/machinery/mod_installer/proc/play_install_sound()
	playsound(src, 'sound/items/tools/rped.ogg', 30, FALSE)

/obj/machinery/mod_installer/update_icon_state()
	icon_state = busy ? busy_icon_state : "[base_icon_state][state_open ? "_open" : null]"
	return ..()

/obj/machinery/mod_installer/update_overlays()
	var/list/overlays = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return overlays
	overlays += (busy || !mod_unit) ? "red" : "green"
	return overlays

/obj/machinery/mod_installer/proc/start_process()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!occupant || !mod_unit || busy)
		return
	set_busy(TRUE, "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_active"), 2.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(play_install_sound)), 2.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_falling"), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_process)), 7.5 SECONDS)

/obj/machinery/mod_installer/proc/complete_process()
	set_busy(FALSE)
	var/mob/living/carbon/human/human_occupant = occupant
	if(!istype(human_occupant))
		return
	if(!isnull(human_occupant.back) && !human_occupant.dropItemToGround(human_occupant.back))
		return
	if(!human_occupant.equip_to_slot_if_possible(mod_unit, mod_unit.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	human_occupant.update_action_buttons(TRUE)
	playsound(src, 'sound/machines/ping.ogg', 30, FALSE)
	if(!human_occupant.dropItemToGround(human_occupant.wear_suit) || !human_occupant.dropItemToGround(human_occupant.head))
		finish_completion()
		return
	mod_unit.quick_activation()
	finish_completion()

/obj/machinery/mod_installer/proc/finish_completion()
	mod_unit = null
	open_machine()

/obj/machinery/mod_installer/open_machine(drop = TRUE, density_to_set = FALSE)
	if(state_open)
		return FALSE
	..()
	return TRUE

/obj/machinery/mod_installer/close_machine(mob/living/carbon/user, density_to_set = TRUE)
	if(!state_open)
		return FALSE
	..()
	addtimer(CALLBACK(src, PROC_REF(start_process)), 1 SECONDS)
	return TRUE

/obj/machinery/mod_installer/relaymove(mob/living/user, direction)
	var/message
	if(busy)
		message = "it won't budge!"
	else if(user.stat != CONSCIOUS)
		message = "you don't have the energy!"
	if(!isnull(message))
		if (COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
			balloon_alert(user, message)
		return
	open_machine()

/obj/machinery/mod_installer/interact(mob/user)
	if(state_open)
		close_machine(null, user)
		return
	else if(busy)
		balloon_alert(user, "it's locked!")
		return
	open_machine()
