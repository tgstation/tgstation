
/obj/machinery/bouldertech/brm
	name = "boulder retrieval matrix"
	desc = "A teleportation matrix used to retrieve boulders excavated by mining NODEs from ore vents."
	icon_state = "brm"
	circuit = /obj/item/circuitboard/machine/brm
	usage_sound = 'sound/machines/mining/manual_teleport.ogg'
	// Are we trying to actively collect boulders automatically?
	var/toggled_on = FALSE
	// Cooldown used for left click teleportation.
	COOLDOWN_DECLARE(manual_teleport_cooldown)

/obj/machinery/bouldertech/brm/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!COOLDOWN_FINISHED(src, manual_teleport_cooldown))
		return
	collect_boulder()
	playsound(src, usage_sound, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	COOLDOWN_START(src, manual_teleport_cooldown, 1.5 SECONDS)

/obj/machinery/bouldertech/brm/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	START_PROCESSING(SSmachines, src)
	icon_state = "brm-toggled"
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/bouldertech/brm/process()
	boulders_held = 0
	balloon_alert_to_viewers("Bzzap!")
	if(SSore_generation.available_boulders.len < 1)
		say("No boulders to collect. Entering idle mode.")
		STOP_PROCESSING(SSmachines, src)
		icon_state = "brm"
		update_appearance(UPDATE_ICON_STATE)
		return
	for(var/i in 1 to boulders_processing_max)
		if(!collect_boulder())
			i-- //Retry
	for(var/ground_rocks in loc.contents)
		if(istype(ground_rocks, /obj/item/boulder))

			boulders_held++
			if(boulders_held > boulders_held_max)
				STOP_PROCESSING(SSmachines, src)
				icon_state = "brm"
				update_appearance(UPDATE_ICON_STATE)
				playsound(src, 'sound/machines/mining/automatic_teleport.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
				return

/obj/machinery/bouldertech/brm/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_LMB] = "Teleport single boulder"
	context[SCREENTIP_CONTEXT_RMB] = "Toggle automatic boulder retrieval"
	return CONTEXTUAL_SCREENTIP_SET

/**
 * So, this should be probably handed in a more elegant way going forward, like a small TGUI prompt to select which boulder you want to pull from.
 * However, in the attempt to make this really, REALLY basic but functional until I can actually sit down and get this done we're going to just grab a random entry from the global list and work with it.
 */
/obj/machinery/bouldertech/brm/proc/collect_boulder()
	var/obj/item/boulder/random_boulder = pick(SSore_generation.available_boulders)
	if(random_boulder.processed_by)
		return FALSE
	if(!random_boulder)
		return FALSE
	random_boulder.processed_by = src
	random_boulder.Shake(duration = 1.5 SECONDS)
	SSore_generation.available_boulders -= random_boulder
	//todo: Maybe add some kind of teleporation raster effect thing? filters? I can probably make something happen here...
	sleep(1.5 SECONDS)
	flick("brm-flash", src)
	if(QDELETED(random_boulder))
		playsound(loc, 'sound/machines/synth_no.ogg', 30 , TRUE)
		balloon_alert_to_viewers("Target lost!")
		return FALSE
	//todo:do the thing we do where we make sure the thing still exists and hasn't been deleted between the start of the recall and after.
	random_boulder.forceMove(drop_location())
	balloon_alert_to_viewers("boulder appears!")
	random_boulder.visible_message(span_warning("[random_boulder] suddenly appears!"))
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	use_power(100)
