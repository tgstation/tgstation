/// Device that traitors can craft in order to be sent a new, undisguised uplink
/obj/structure/syndicate_uplink_beacon
	name = "suspicious beacon"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "relay_traitor"
	desc = "This ramshackle device seems capable of receiving and sending signals for some nefarious purpose."
	density = TRUE
	anchored = TRUE
	/// Traitor's code that they speak into the radio
	var/uplink_code = ""
	/// weakref to person who is going to use the beacon to get a replacement uplink
	var/datum/weakref/owner
	/// while constructed the teleport beacon is still active
	var/obj/item/beacon/teleport_beacon
	/// Radio that the device needs to listen to the codeword from the traitor
	var/obj/item/radio/listening_radio
	/// prevents traitor from activating teleport_beacon proc too much in a small period of time
	COOLDOWN_DECLARE(beacon_cooldown)

/obj/structure/syndicate_uplink_beacon/Initialize(mapload)
	. = ..()
	register_context()

	var/static/list/tool_behaviors = list(
		TOOL_SCREWDRIVER = list(
			SCREENTIP_CONTEXT_RMB = "Deconstruct",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)
	listening_radio = new(src)
	listening_radio.canhear_range = 0
	teleport_beacon = new(src)

/obj/structure/syndicate_uplink_beacon/attack_hand(mob/living/user, list/modifiers)
	if(!IS_TRAITOR(user))
		balloon_alert(user, "don't know how to use!")
		return
	if(IS_WEAKREF_OF(owner, user))
		balloon_alert(user, "already synchronized to you!")
		return
	if(owner != null)
		balloon_alert(user, "already claimed!")
		return
	var/datum/looping_sound/typing/typing_sounds = new(src, start_immediately = TRUE)
	balloon_alert(user, "synchronizing...")
	if(!do_after(user = user, delay = 3 SECONDS, target = src, interaction_key = REF(src), hidden = TRUE))
		typing_sounds.stop()
		return
	typing_sounds.stop()
	probe_traitor(user)

/obj/structure/syndicate_uplink_beacon/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	balloon_alert(user, "deconstructing...")
	if (!do_after(user, 5 SECONDS, target = src, hidden = TRUE))
		return FALSE
	var/turf/beacon_tile = get_turf(src)
	new /obj/item/stack/sheet/iron/five(beacon_tile)
	new /obj/item/stack/cable_coil/five(beacon_tile)
	teleport_beacon.forceMove(beacon_tile)
	teleport_beacon = null
	qdel(src)
	return TRUE

/obj/structure/syndicate_uplink_beacon/Destroy()
	QDEL_NULL(listening_radio)
	if(teleport_beacon)
		QDEL_NULL(teleport_beacon)
	return ..()

/// Proc reads the user, sets radio to the correct frequency and starts to listen for the replacement uplink code
/obj/structure/syndicate_uplink_beacon/proc/probe_traitor(mob/living/user)
	owner = WEAKREF(user)
	var/datum/antagonist/traitor/traitor_datum = user.mind.has_antag_datum(/datum/antagonist/traitor)

	uplink_code = traitor_datum.replacement_uplink_code
	listening_radio.set_frequency(traitor_datum.replacement_uplink_frequency)
	become_hearing_sensitive()

/obj/structure/syndicate_uplink_beacon/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods, message_range)
	if(ismob(speaker) || radio_freq != listening_radio.get_frequency())
		return
	if(!findtext(message, uplink_code))
		return
	teleport_uplink()

/// Proc uses owners uplink handler to create replacement uplink and then lock or destroy their other uplinks
/obj/structure/syndicate_uplink_beacon/proc/teleport_uplink()
	if(!COOLDOWN_FINISHED(src, beacon_cooldown))
		return
	COOLDOWN_START(src, beacon_cooldown, 10 MINUTES)

	var/mob/living/resolved_owner = owner.resolve()
	if(isnull(resolved_owner))
		return

	var/datum/antagonist/traitor/traitor_datum = resolved_owner.mind.has_antag_datum(/datum/antagonist/traitor)
	if(isnull(traitor_datum))
		return

	var/datum/uplink_handler/uplink_handler = traitor_datum.uplink_handler

	SEND_SIGNAL(uplink_handler, COMSIG_UPLINK_HANDLER_REPLACEMENT_ORDERED)
	new /obj/item/uplink/replacement(get_turf(src), /*owner = */resolved_owner, /*tc_amount = */0, /*uplink_handler_override = */uplink_handler)
	flick("relay_traitor_activate", src)
	do_sparks(number = 5, cardinal_only = FALSE, source = src)
	log_traitor("[key_name(resolved_owner)] acquired a replacement uplink via the syndicate uplink beacon.")

// Adds screentips
/obj/structure/syndicate_uplink_beacon/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item || !IS_TRAITOR(user))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Synchronize with beacon"
	return CONTEXTUAL_SCREENTIP_SET
