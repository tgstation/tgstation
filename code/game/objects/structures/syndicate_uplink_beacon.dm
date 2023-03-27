/// Device that traitors can craft in order to be sent a new, undisguised uplink
/obj/structure/syndicate_uplink_beacon
	name = "suspicious beacon"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster"
	desc = "This ramshackle device seems capable of recieving and sending signals for some odd purpose."
	/// Traitor's code that they speak into the radio
	var/uplink_code
	/// weakref to person who is going to use the beacon to get a replacement uplink
	var/datum/weakref/owner
	/// Datum that allows the beacon to listen to the radio
	var/datum/radio_frequency/traitor_frequency
	/// while constructed the teleport beacon is still active
	var/obj/item/beacon/teleport_beacon
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

	teleport_beacon = new(src)

/obj/structure/syndicate_uplink_beacon/attack_hand(mob/living/user, list/modifiers)
	if(!user.mind?.has_antag_datum(/datum/antagonist/traitor))
		balloon_alert(user, "don't know how to use!")
		return
	if(owner == WEAKREF(user))
		balloon_alert(user, "already synchronized to you!")
		return
	if(owner != null)
		balloon_alert(user, "already claimed!")
		return
	var/datum/looping_sound/typing/typing_sounds = new(src, TRUE)
	balloon_alert(user, "beginning synchronization...")
	if(!do_after(user = user, delay = 3 SECONDS, target = src, interaction_key = REF(src)))
		balloon_alert(user, "interrupted!")
		typing_sounds.stop()
		return
	typing_sounds.stop()
	probe_traitor(user)

/obj/structure/syndicate_uplink_beacon/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	balloon_alert(user, "deconstructing...")
	if (!do_after(user, 5 SECONDS, target = src))
		return FALSE
	new /obj/item/stack/sheet/iron/five
	new /obj/item/stack/cable_coil/five
	teleport_beacon.forceMove(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/syndicate_uplink_beacon/proc/probe_traitor(mob/living/user)
	owner = WEAKREF(user)
	var/datum/antagonist/traitor/traitor_datum = user.mind.has_antag_datum(/datum/antagonist/traitor)

	uplink_code = traitor_datum.replacement_uplink_code
	traitor_frequency = SSradio.add_object(src, traitor_datum.replacement_uplink_frequency, RADIO_SIGNALER)

/obj/structure/syndicate_uplink_beacon/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE

/obj/structure/syndicate_uplink_beacon/proc/teleport_uplink()
	if(!COOLDOWN_FINISHED(src, beacon_cooldown))
		return
	COOLDOWN_START(src, beacon_cooldown, 10 MINUTES)

	var/mob/living/resolved_owner = owner.resolve()
	if(!resolved_owner)
		return

	var/datum/antagonist/traitor/traitor_datum = resolved_owner.mind.has_antag_datum(/datum/antagonist/traitor)
	var/datum/uplink_handler/uplink_handler = traitor_datum.uplink_handler

	SEND_SIGNAL(uplink_handler, COMSIG_UPLINK_HANDLER_REPLACEMENT_ORDERED)
	new /obj/item/uplink(get_turf(src), resolved_owner, 0, uplink_handler)
	do_sparks(5, FALSE, src)
	log_traitor("[key_name(resolved_owner)] acquired a replacement uplink via the syndicate uplink beacon.")

/obj/structure/syndicate_uplink_beacon/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item)
		return NONE
	if(!user.mind?.has_antag_datum(/datum/antagonist/traitor))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Synchronize with beacon"
	return CONTEXTUAL_SCREENTIP_SET
