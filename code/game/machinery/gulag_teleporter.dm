
#define BREAKOUT_MESSAGE_DELAY 5 SECONDS

/obj/machinery/gulag_teleporter
	name = "labor camp teleporter"
	desc = "A bluespace teleporter used for teleporting prisoners to the labor camp."
	icon = 'icons/obj/machines/implant_chair.dmi'
	icon_state = "implantchair"
	base_icon_state = "implantchair"
	state_open = TRUE
	density = FALSE
	obj_flags = BLOCKS_CONSTRUCTION // Becomes undense when the door is open
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 5
	circuit = /obj/item/circuitboard/machine/gulag_teleporter
	/// Door cannot be opened by hand
	var/locked = FALSE
	/// Required time for do_after to break out of the door
	var/breakout_time = 60 SECONDS
	/// Currently processing someone
	var/processing = FALSE
	/// CD for attempting to break out
	COOLDOWN_DECLARE(breakout_message_cd)


/obj/machinery/gulag_teleporter/interact(mob/user)
	. = ..()

	if(locked)
		balloon_alert(user, "locked")
		return
	toggle_open()


/obj/machinery/gulag_teleporter/attackby(obj/item/tool, mob/user)
	if(!occupant && default_deconstruction_screwdriver(user, "[icon_state]", "[icon_state]", tool))
		update_appearance()
		return

	if(default_deconstruction_crowbar(tool))
		return

	if(default_pry_open(tool))
		return

	return ..()


/obj/machinery/gulag_teleporter/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational && occupant)
		open_machine()


/obj/machinery/gulag_teleporter/MouseDrop_T(mob/target, mob/user)
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user))
		return

	close_machine(target)


/obj/machinery/gulag_teleporter/update_icon_state()
	icon_state = "[base_icon_state][state_open ? "_open" : null]"

	if(!is_operational)
		icon_state += "_unpowered"
		if((machine_stat & MAINT) || panel_open)
			icon_state += "_maintenance"
		return ..()

	if((machine_stat & MAINT) || panel_open)
		icon_state += "_maintenance"
		return ..()

	if(occupant)
		icon_state += "_occupied"
	return ..()


/obj/machinery/gulag_teleporter/relaymove(mob/living/user, direction)
	if(user.stat != CONSCIOUS)
		return

	if(!locked)
		open_machine()
		return

	if(COOLDOWN_FINISHED(src, breakout_message_cd))
		balloon_alert(user, "won't budge")
		return

	COOLDOWN_START(src, breakout_message_cd, BREAKOUT_MESSAGE_DELAY)


/obj/machinery/gulag_teleporter/container_resist_act(mob/living/user)
	var/resist_time = breakout_time
	if(!locked)
		if(!HAS_TRAIT(user, TRAIT_RESTRAINED))
			open_machine()
			return
		resist_time *= 0.5

	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(
		span_notice("You see [user] kicking against the door of [src]!"),
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(resist_time)].)"),
		span_hear("You hear a metallic creaking from [src]."),
	)

	if(!do_after(user, resist_time, target = src))
		to_chat(user, span_warning("You failed to break out of [src]."))

	if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
		return

	locked = FALSE
	user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
		span_notice("You successfully break out of [src]!"))
	open_machine()


/// Opens the machine and sets the state to open.
/obj/machinery/gulag_teleporter/proc/toggle_open()
	if(panel_open)
		to_chat(usr, span_notice("Close the maintenance panel first."))
		return

	if(state_open)
		close_machine()
		return

	if(!locked)
		open_machine()


/// Shake a bit and call process_occupant() after a delay.
/obj/machinery/gulag_teleporter/proc/handle_prisoner(mob/living/processor)
	if(!ishuman(occupant))
		return

	processor.log_message("is teleporting [key_name(occupant)] to the labor camp.", LOG_GAME)

	locked = TRUE
	processing = TRUE

	var/mob/living/victim = occupant

	update_use_power(ACTIVE_POWER_USE)
	audible_message(span_hear("You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)

	victim.Paralyze(5)
	if(prob(10))
		INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob/living, emote), "scream")

	var/offset = prob(50) ? -5 : 5
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250)

	addtimer(CALLBACK(src, PROC_REF(process_occupant)), 2 SECONDS)


/// Teleport the occupant to "the labor camp".
/obj/machinery/gulag_teleporter/proc/process_occupant()
	if(!is_operational || QDELETED(occupant) || QDELETED(src))
		return

	var/mob/living/victim = occupant

	DSsecurity.add_new_criminal(victim)
	victim.drop_all_held_items()
	update_use_power(IDLE_POWER_USE)

	victim.investigate_log("has been teleported at [src] to the labor camp.", INVESTIGATE_DEATHS)
	victim.ghostize()
	victim.death(TRUE)
	qdel(victim)

	locked = FALSE
	processing = FALSE
	toggle_open()


/obj/item/circuitboard/machine/gulag_teleporter
	name = "labor camp teleporter (Machine Board)"
	build_path = /obj/machinery/gulag_teleporter
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/datum/stock_part/scanning_module = 1,
		/obj/item/stock_parts/servo = 1,
	)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)



#undef BREAKOUT_MESSAGE_DELAY
