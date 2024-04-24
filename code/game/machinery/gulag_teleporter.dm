
#define BREAKOUT_MESSAGE_DELAY 5 SECONDS
#define BRRR_TIME 5 SECONDS

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
	///The radio the console can speak into
	var/obj/item/radio/radio
	/// CD for attempting to break out
	COOLDOWN_DECLARE(breakout_message_cd)

/obj/machinery/gulag_teleporter/Initialize(mapload)
	. = ..()

	radio = new(src)
	component_parts += radio
	radio.keyslot = new /obj/item/encryptionkey/headset_sec()
	radio.set_listening(FALSE)
	radio.recalculateChannels()

/obj/machinery/gulag_teleporter/interact(mob/user)
	. = ..()

	toggle_open(user)


/obj/machinery/gulag_teleporter/open_machine(drop, density_to_set)
	. = ..()
	playsound(src, 'sound/machines/door_open.ogg', 50, TRUE)


/obj/machinery/gulag_teleporter/close_machine(atom/movable/target, density_to_set)
	. = ..()
	playsound(src, 'sound/machines/doorclick.ogg', 50, TRUE)


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
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(src) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user))
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

	if(QDELETED(user) || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
		return

	locked = FALSE
	user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
		span_notice("You successfully break out of [src]!"))
	open_machine()


/// Handler for the prisoner making noises (how grim)
/obj/machinery/gulag_teleporter/proc/do_emote()
	if(!is_operational || QDELETED(occupant) || occupant.loc != src)
		return

	var/mob/living/victim = occupant
	if(!isliving(victim))
		return

	victim.emote(prob(95) ? "scream" : "laugh")


/// Gets wanted status of the teleporter occupant.
/obj/machinery/gulag_teleporter/proc/get_occupant_record() as /datum/record/crew
	if(!ishuman(occupant) || isnull(GLOB.manifest.general))
		return

	for(var/datum/record/crew/record as anything in GLOB.manifest.general)
		if(record.name == occupant.name)
			return record


/// Shake a bit and call process_occupant() after a delay.
/obj/machinery/gulag_teleporter/proc/handle_prisoner()
	if(!isliving(occupant))
		reset()
		return

	locked = TRUE
	processing = TRUE

	var/mob/living/victim = occupant

	update_use_power(ACTIVE_POWER_USE)
	playsound(src, 'sound/machines/juicer.ogg', 50, TRUE)
	victim.Paralyze(7)
	Shake(duration = BRRR_TIME)
	if(prob(10))
		addtimer((CALLBACK(src, PROC_REF(do_emote))), rand(1 SECONDS, 3.5 SECONDS), TIMER_DELETE_ME|TIMER_UNIQUE|TIMER_STOPPABLE)

	addtimer(CALLBACK(src, PROC_REF(process_occupant)), BRRR_TIME, TIMER_DELETE_ME|TIMER_UNIQUE|TIMER_STOPPABLE)


/// Teleport the occupant to "the labor camp".
/obj/machinery/gulag_teleporter/proc/process_occupant()
	if(QDELETED(src))
		return

	if(!is_operational || QDELETED(occupant) || occupant.loc != src)
		reset()
		return

	var/mob/living/victim = occupant

	var/datum/record/crew/record = get_occupant_record()
	record?.wanted_status = WANTED_PRISONER

	victim.investigate_log("has been teleported at [src] to the labor camp.", INVESTIGATE_DEATHS)
	victim.drop_everything()
	victim.ghostize()
	victim.death(TRUE)

	if(DSsecurity.add_new_criminal(victim))
		playsound(src, 'sound/machines/chime.ogg', 75, TRUE)
		radio.talk_into(src, "Dissident logged. New points are available at security consoles.", RADIO_CHANNEL_SECURITY)
	else
		playsound(src, 'sound/machines/buzz-two.ogg', 75, TRUE)

	qdel(victim)

	reset()


/// Reset the machine to its default state.
/obj/machinery/gulag_teleporter/proc/reset()
	update_use_power(IDLE_POWER_USE)
	locked = FALSE
	processing = FALSE
	open_machine()


/// Toggles the door open or closed.
/obj/machinery/gulag_teleporter/proc/toggle_open(mob/viewer)
	if(panel_open)
		to_chat(usr, span_notice("Close the maintenance panel first."))
		return

	if(state_open)
		close_machine()
		return

	if(locked)
		balloon_alert(viewer, "locked")
		return

	open_machine()


#undef BREAKOUT_MESSAGE_DELAY
