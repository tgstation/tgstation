#define MANUAL_TELEPORT_SOUND 'sound/machines/mining/manual_teleport.ogg'
#define AUTO_TELEPORT_SOUND 'sound/machines/mining/auto_teleport.ogg'

/obj/machinery/bouldertech/brm
	name = "boulder retrieval matrix"
	desc = "A teleportation matrix used to retrieve boulders excavated by mining NODEs from ore vents."
	icon_state = "brm"
	circuit = /obj/item/circuitboard/machine/brm
	usage_sound = MANUAL_TELEPORT_SOUND
	/// Are we trying to actively collect boulders automatically?
	var/toggled_on = FALSE
	/// How long does it take to collect a boulder?
	var/teleportation_time = 1.5 SECONDS
	// Cooldown used for left click teleportation.
	COOLDOWN_DECLARE(manual_teleport_cooldown)

/obj/machinery/bouldertech/brm/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSmachines, src) // Don't start processing until flipped on.
	set_wires(new /datum/wires/brm(src))

/obj/machinery/bouldertech/brm/Destroy()
	. = ..()
	QDEL_NULL(wires)

/obj/machinery/bouldertech/brm/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, manual_teleport_cooldown))
		return
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return
	playsound(src, MANUAL_TELEPORT_SOUND, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	pre_collect_boulder()

	COOLDOWN_START(src, manual_teleport_cooldown, teleportation_time)

/obj/machinery/bouldertech/brm/attackby(obj/item/attacking_item, mob/user, params)
	if(is_wire_tool(attacking_item) && panel_open)
		wires.interact(user)
		return TRUE
	return ..()

/obj/machinery/bouldertech/brm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	toggle_auto_on(user)

/obj/machinery/bouldertech/brm/process()
	balloon_alert_to_viewers("Bzzap!")
	if(SSore_generation.available_boulders.len < 1)
		say("No boulders to collect. Entering idle mode.")
		STOP_PROCESSING(SSmachines, src)
		icon_state = "brm"
		update_appearance(UPDATE_ICON_STATE)
		return
	for(var/i in 1 to boulders_processing_max)
		if(!pre_collect_boulder())
			i-- //Retry
	for(var/ground_rocks in loc.contents)
		if(istype(ground_rocks, /obj/item/boulder))
			boulders_contained += ground_rocks
			if(boulders_contained.len > boulders_held_max)
				STOP_PROCESSING(SSmachines, src)
				boulders_contained = list()
				icon_state = "brm"
				update_appearance(UPDATE_ICON_STATE)
				return

/obj/machinery/bouldertech/brm/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Teleport single boulder"
	context[SCREENTIP_CONTEXT_RMB] = "Toggle automatic boulder retrieval"
	return CONTEXTUAL_SCREENTIP_SET


/obj/machinery/bouldertech/brm/proc/pre_collect_boulder()
	if(!SSore_generation.available_boulders.len)
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		balloon_alert_to_viewers("no boulders to collect")
		return FALSE //Nothing to collect
	var/obj/item/boulder/random_boulder = pick(SSore_generation.available_boulders)
	if(random_boulder.processed_by)
		return FALSE
	if(!random_boulder)
		return FALSE
	random_boulder.processed_by = src
	random_boulder.Shake(duration = 1.5 SECONDS)
	SSore_generation.available_boulders -= random_boulder
	addtimer(CALLBACK(src, PROC_REF(collect_boulder), random_boulder), 1.5 SECONDS)

/obj/machinery/bouldertech/brm/proc/collect_boulder(obj/item/boulder/random_boulder)
	flick("brm-flash", src)
	if(QDELETED(random_boulder))
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		balloon_alert_to_viewers("target lost!")
		return FALSE
	playsound(src, AUTO_TELEPORT_SOUND, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	random_boulder.forceMove(drop_location())
	balloon_alert_to_viewers("boulder appears!")
	random_boulder.visible_message(span_warning("[random_boulder] suddenly appears!"))
	use_power(100)

/obj/machinery/bouldertech/brm/proc/toggle_auto_on(mob/user)
	if(panel_open)
		if(user)
			balloon_alert(user, "close panel first!")
		return
	START_PROCESSING(SSmachines, src)
	icon_state = "brm-toggled"
	update_appearance(UPDATE_ICON_STATE)
	usage_sound = AUTO_TELEPORT_SOUND

#undef MANUAL_TELEPORT_SOUND
#undef AUTO_TELEPORT_SOUND
