/datum/action/cooldown/mob_cooldown/flock_squawk
	name = "Squawk"
	background_icon = 'troutstation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_flock"
	overlay_icon_state = "bg_flock_border"
	button_icon = 'troutstation/icons/mob/actions/actions_flock.dmi'
	button_icon_state = "squawk"
	desc = "Forces nearby radios to be listening and broadcasting for a short time. Causes a bunch of useless messages, highly visible!"
	cooldown_time = 60 SECONDS
	shared_cooldown = NONE
	click_to_activate = FALSE
	/// What's the range on our squawk?
	var/squawk_range = 6
	/// How long do the radios remain in their receptive state?
	var/radio_forced_duration = 15 SECONDS
	/// Max effect stagger time for radios
	var/radio_stagger_max_duration = 3 SECONDS
	/// List of radios we need to put back to normal
	var/list/radios_affected = list()
	/// List of gobbledegook to spit out of radios
	var/static/list/radio_messages = list()
	/// List of Poly gobbledegook to spit out of radios
	var/static/list/poly_messages = list()


/datum/action/cooldown/mob_cooldown/flock_squawk/IsAvailable(feedback = FALSE)
	if(is_jaunting(owner)) // overriding for more flavourful feedback
		if (feedback)
			owner.balloon_alert(owner, "your signal is too weak in this form!")
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/flock_squawk/Activate(atom/target_atom)
	var/list/radios = get_nearby_active_radios(get_turf(owner))
	if(radios.len == 0)
		to_chat(owner, span_warning("No active radios to squawk into nearby."))
		return FALSE
	disable_cooldown_actions()
	force_radios(radios)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/flock_squawk/proc/get_nearby_active_radios(turf/origin, radio_radius)
	var/list/radios = get_radios_nearby(origin, radio_radius)
	var/list/active_radios = list()

	for(var/obj/item/radio/radio in radios)
		if(radio.is_on())
			active_radios += radio
	return active_radios

/datum/action/cooldown/mob_cooldown/flock_squawk/proc/force_radios(list/radios)
	playsound(owner, 'troutstation/sound/effects/flock/radio_squawk.ogg', 50, TRUE, -1)
	owner.visible_message(
		span_warning("[owner] emits strange static!"),
		span_notice("You transmit garbage data into the nearest compatible receivers, forcing them into full receptivity."),
		span_warning("You hear strange fuzzy distorted noises.")
	)
	for(var/obj/item/radio in radios)
		addtimer(CALLBACK(src, PROC_REF(force_radio), radio), rand(0, radio_stagger_max_duration))

/datum/action/cooldown/mob_cooldown/flock_squawk/proc/force_radio(obj/item/radio/radio)
	radios_affected[ref(radio)] = list(
		"broadcasting" = radio.get_broadcasting(),
		"listening" = radio.get_listening()
	)
	var/datum/wires/wires = radio.wires
	if(wires)
		// check that the wires allow what we're doing
		if(!wires.is_cut(WIRE_TX))
			radio.set_broadcasting(TRUE)
		if(!wires.is_cut(WIRE_RX))
			radio.set_listening(TRUE)
	else // no wires? no problem
		radio.set_broadcasting(TRUE)
		radio.set_listening(TRUE)
	send_message(radio)
	new /obj/effect/temp_visual/emp(radio.loc)
	playsound(radio, 'troutstation/sound/effects/flock/radio_sweep.ogg', 50, TRUE, -1)
	addtimer(CALLBACK(src, PROC_REF(restore_radio), radio), radio_forced_duration)

/datum/action/cooldown/mob_cooldown/flock_squawk/proc/send_message(obj/item/radio/radio)
	if(radio_messages.len == 0)
		radio_messages = world.file2list("strings/flock/squawk_messages.txt")
	if(poly_messages.len == 0)
		poly_messages = load_poly_lines()
	var/list/message_choices = radio_messages + poly_messages
	var/message = scramble_message_replace_chars(pick(message_choices), 5)
	radio.talk_into(radio, message, spans = list(SPAN_FLOCK))

/datum/action/cooldown/mob_cooldown/flock_squawk/proc/restore_radio(obj/item/radio/radio)
	var/list/radio_data = radios_affected?[ref(radio)]
	radios_affected -= ref(radio)
	if(isnull(radio_data) || radio_data.len == 0)
		// something already beat us here
		return
	radio.set_broadcasting(radio_data["broadcasting"])
	radio.set_listening(radio_data["listening"])

/datum/action/cooldown/mob_cooldown/flock_squawk/proc/load_poly_lines()
	var/json_file = file("data/npc_saves/Poly.json")
	if(!fexists(json_file))
		return list()
	var/list/json = json_decode(file2text(json_file))
	var/list/returnable_list = json["phrases"]
	return returnable_list
