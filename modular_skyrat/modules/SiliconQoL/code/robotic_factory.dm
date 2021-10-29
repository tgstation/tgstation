/obj/machinery/transformer_rp
	name = "\improper Automatic Robotic Factory 5000"
	desc = "A large metallic machine with an entrance and an exit. A sign on \
		the side reads, 'Mass robot production facility'"
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	density = TRUE
	/// How many cyborgs are we storing
	var/stored_cyborgs = 1
	/// How many cyborgs can we store?
	var/max_stored_cyborgs = 4
	/// How much between the construction of a cyborg?
	var/cooldown_duration = 5 MINUTES
	/// Handles the timer , shouldn't touch.
	var/cooldown_timer
	/// The countdown itself
	var/obj/effect/countdown/transformer/countdown
	/// The master AI , assigned when placed down with the ability.
	var/mob/living/silicon/ai/masterAI

/obj/machinery/transformer_rp/Initialize()
	// On us
	. = ..()
	new /obj/machinery/conveyor/auto(loc, WEST)
	countdown = new(src)
	countdown.start()

/obj/machinery/transformer_rp/examine(mob/user)
	. = ..()
	if(issilicon(user) || isobserver(user))
		. += "It will create a new cyborg in [DisplayTimeText(cooldown_timer - world.time)]."

/obj/machinery/transformer_rp/Destroy()
	QDEL_NULL(countdown)
	. = ..()

/obj/machinery/transformer_rp/update_icon_state()
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER))
		icon_state = "separator-AO0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer_rp/attack_ghost(mob/dead/observer/target_ghost)
	. = ..()
	create_a_cyborg(target_ghost)

/obj/machinery/transformer_rp/process()
	if(cooldown_timer <= world.time)
		cooldown_timer = world.time + cooldown_duration
		update_icon()
		if(stored_cyborgs > max_stored_cyborgs)
			return
		stored_cyborgs++
		notify_ghosts("A new cyborg shell has been created at the [src]", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "New malfunctioning cyborg created!")

/obj/machinery/transformer_rp/proc/create_a_cyborg(mob/dead/observer/target_ghost)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(stored_cyborgs<1)
		return
	var/cyborg_ask = tgui_alert(target_ghost, "Become a cyborg?", "Are you a terminator?", list("Yes", "No"))
	if(cyborg_ask == "No" || !src || QDELETED(src))
		return FALSE
	var/mob/living/silicon/robot/cyborg = new /mob/living/silicon/robot(loc)
	cyborg.key = target_ghost.key
	cyborg.set_connected_ai(masterAI)
	cyborg.lawsync()
	cyborg.lawupdate = TRUE
	stored_cyborgs--
